-module(ring).
-export([batch_init/2,forward/1,forward/3,ring1/2]).

% 1) the first node can send a
% message and wait for it to arrive before sending the next message
ring1(Processes, Msgs) ->
  Header = spawn(ring,batch_init, [Processes,self()]),
  Header ! {1,Msgs}.

% 2) the first node can send 
% all of the messages then wait for them all to arrive
%ring2(nPRocesses, nMsgs) ->

forward(Dest) ->
  io:format("Process ~p sends to ~p~n", [self(),Dest]),
  forwarder(Dest,-1,-1).

forward(Dest,N,Main) ->
  io:format("Process ~p sends to ~p~n", [self(),Dest]),
  forwarder(Dest,N,Main).

forwarder(Dest, N,Main) ->
  receive
    quit  ->
      Dest ! quit;
    {M,Counter} ->
      if
        N < 0 ->
          io:format("Send ~p from ~p to ~p~n", [M, self(),Dest]),
          Dest ! {M,Counter+1}, forward(Dest,N,Main);
        Counter < N  ->
          io:format("Send ~p from ~p to ~p~n", [M, self(),Dest]),
          Dest ! {M,Counter+1}, forward(Dest,N,Main);
        true ->
          io:format("Stop sending"),
          Main ! done,
          forward(Dest,N,Main)
      end
  end.

batch_init(N,Main) ->
  batch_init_loop(N, self(),Main).

batch_init_loop(N, First,Main) ->
  Last = lists:foldl(fun spawnForwarder/2, First, lists:seq(1,N)),
  forward(Last,N,Main).

spawnForwarder(_,A) ->
  spawn(ring, forward, [A]).


