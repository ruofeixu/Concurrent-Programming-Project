-module(ring).
-export([test/0,timer/1,batch_init/2,forward/1,forward/3,ring2_count/3,ring1/2,ring2/2]).

%generate all the test casese
test() ->
  ProcessorList = [1000,2000,4000,8000],
  MessageList = [0,1000,2000,4000,8000],
  FunctionID = [1,2],
  PairList = pairs(ProcessorList,MessageList),
  InputArgs = pairs(FunctionID,PairList),
  %InputArgs = append_pair(FunctionID, PairList),
  loop_lists(InputArgs).

%loop all the test cases
loop_lists([H|T]) ->
    if
        T/=[] ->
            timer(H),
            loop_lists(T);
        H/=[] ->
            timer(H);
        true -> stop
    end.

%creat a pairs list from two lists
pairs(L1,L2) -> [[X,Y] || X <- L1, Y <- L2].

%timer for calculating time period of each test case
timer([F,[NumP,NumM]]) ->
  statistics(runtime),
  statistics(wall_clock),
  if
    F==1 -> ring1(NumP,NumM);
    true -> ring2(NumP,NumM)
  end,
  {_,Time1} = statistics(runtime),
  {_,Time2} = statistics(wall_clock),
  if
    F==1 ->
    ring1(NumP,NumM),
    io:format("~p with ~p processors and ~p messages took ~p cpu milliseconds and ~p wall­clock milliseconds~n", ["ring1",NumP,NumM,Time1, Time2]);
    true ->
    ring2(NumP,NumM),
    io:format("~p with ~p processors and ~p messages took ~p cpu milliseconds and ~p wall­clock milliseconds~n", ["ring2",NumP,NumM,Time1, Time2])
  end.

% 1) the first node can send a % message and wait for it to arrive before sending the next message
ring1(Processes, NumMsgs) ->
  Header = spawn(ring,batch_init, [Processes,self()]),
  %io:format("Frist message ~p sends to ~p~n", [self(),Header]),
  ring1_send_loop(Header, self(),lists:seq(1,NumMsgs)),
  receive
    done->
      %io:format("All message arrived~n")
      true
  end.

%send
ring1_send_loop(Head, Main, L)->
  if
    L == [] ->
      Main ! done;
    true ->
      [H|T]=L,
      if
        H /= [] ->
        Head ! {H,0},
          receive
          done->
            if
              T /= [] ->
              ring1_send_loop(Head,Main,T);
              true ->Main ! done
            end
          end
      end
  end.

% 2) the first node can send 
% all of the messages then wait for them all to arrive
ring2(Processes, Msgs) ->
  Counter = spawn(ring,ring2_count, [Msgs,0,self()]),
  Header = spawn(ring,batch_init, [Processes,Counter]),
  lists:map(fun(X) -> {Header ! {X,0} }end, lists:seq(1,Msgs)),
  receive
    done->
      io:format("All message arrived~n")
  end.


ring2_count(N,C,Main) ->
  receive
    done->
      if
        C < N-1 ->
          ring2_count(N,C+1,Main);
        true->
          Main ! done
      end
  end.

forward(Dest) ->
  %io:format("Process ~p sends to ~p~n", [self(),Dest]),
  forwarder(Dest,-1,-1).

forward(Dest,N,Main) ->
  %io:format("Process ~p sends to ~p~n", [self(),Dest]),
  forwarder(Dest,N,Main).

forwarder(Dest, N,Main) ->
  receive
    quit  ->
      Dest ! quit;
    {M,Counter} ->
      if
        N < 0 ->
          %io:format("Send ~p from ~p to ~p~n", [M, self(),Dest]),
          Dest ! {M,Counter+1}, forward(Dest,N,Main);
        Counter < N-1  ->
          %io:format("Send ~p from ~p to ~p~n", [M, self(),Dest]),
          Dest ! {M,Counter+1}, forward(Dest,N,Main);
        true ->
          %io:format("Stop sending ~p~n", [M]),
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


