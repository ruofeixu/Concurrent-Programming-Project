-module(ring).
-export([batch_init/1,forward/1,forward/2,ring1/2]).

% 1) the first node can send a
% message and wait for it to arrive before sending the next message
ring1(Processes, Msgs) ->
  Header = spawn(ring,batch_init, [Processes]),
  Header ! {1,Msgs}.

% 2) the first node can send 
% all of the messages then wait for them all to arrive
%ring2(nPRocesses, nMsgs) ->

forward(Dest) ->
  io:format("Process ~p sends to ~p~n", [self(),Dest]),
  forwarder(Dest,-1).

forward(Dest,N) ->
  io:format("Process ~p sends to ~p~n", [self(),Dest]),
  forwarder(Dest,N).

forwarder(Dest, N) ->
  receive
    quit  ->
      Dest ! quit;
    {M,Counter} ->
      if
        N < 0 ->
          io:format("Send ~p from ~p to ~p~n", [M, self(),Dest]),
          Dest ! {M,Counter+1}, forward(Dest,N);
        Counter < N  ->
          io:format("Send ~p from ~p to ~p~n", [M, self(),Dest]),
          Dest ! {M,Counter+1}, forward(Dest,N);
        true ->
          io:format("Stop sending"),
          forward(Dest,N)
      end
  end.

batch_init(N) ->
  batch_init_loop(N, self()).

batch_init_loop(N, First) ->
  Last = lists:foldl(fun spawnForwarder/2, First, lists:seq(1,N)),
  forward(Last,N).

spawnForwarder(_,A) ->
  spawn(ring, forward, [A]).


