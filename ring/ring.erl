%cpts383 concurrent programming
%project2 erlang ring
%ruofei xu
%11237005

-module(ring).
-export([test/0,timer/1,batch_init/2,forward/1,forward/3,ring2_count/3,ring1/2,ring2/2]).

% generate all the test cases
test() ->
  ProcessorList = [1000,2000,4000,8000],
  MessageList = [0,1000,2000,4000,8000],
  FunctionID = [1,2],
  PairList = pairs(ProcessorList,MessageList),
  InputArgs = pairs(FunctionID,PairList),
  %io:format("~p ~n", [InputArgs]),
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
%F is function id, NumP is number of processor, and NumM is number
timer([F,[NumP,NumM]]) ->
  %io:format("timer start~n"),
  %start timer
  statistics(runtime),
  statistics(wall_clock),
  % start run function ring1 or ring2
  if
    F==1 -> ring1(NumP,NumM);
    F==2 -> ring2(NumP,NumM);
    true -> unkonwn
  end,
  %end timer
  {_,Time1} = statistics(runtime),
  {_,Time2} = statistics(wall_clock),
  %print out result
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
  %generate ring
  Header = spawn(ring,batch_init, [Processes,self()]),
  %io:format("Frist message ~p sends to ~p~n", [self(),Header]),

  %this is a loop keep sending message until all the message is sent
  ring1_send_loop(Header, self(),lists:seq(1,NumMsgs)),
  receive
    done->
      %io:format("All message arrived~n")
      %break the ring when everything done
      Header ! quit
  end.

%except first one send each message until last message arrived
%Head is the first processor, Main is the thread who generate the ring, L is the rest message in the List
ring1_send_loop(Head, Main, L)->
  if
    L == [] -> %if no message left its done
      Main ! done;
    true -> %otherwise keep sending message
      [H|T]=L,
      Head ! {H,0},
      receive
      done-> %if message received
        if
          T /= [] -> %if still messge left keep sending
          ring1_send_loop(Head,Main,T);
          true ->Main ! done %otehrwise nofity Main thread we are done
        end
      end
  end.

% 2) the first node can send 
% all of the messages then wait for them all to arrive
ring2(Processes, NumMsgs) ->
  % a counter thread keep for head processor to check if the message is sent already
  Counter = spawn(ring,ring2_count, [NumMsgs,0,self()]),
  % generate ring
  Header = spawn(ring,batch_init, [Processes,Counter]),
  if
    NumMsgs /= 0 ->
        %sent all message once
        %counter start from 0
        lists:map(fun(X) -> {Header ! {X,0} }end, lists:seq(1,NumMsgs)),
        receive
            alldone->
            Header ! quit
            %io:format("All message arrived~n")
        end;
    true ->
        done
  end.

%counter function, add one for each message received by head processor
% N is number of message that ring wants to send, C is a counter, Main is main thread pid
ring2_count(N,C,Main) ->
  receive
    done-> %when receive done from processor add 1
      if
        C < N-1 -> %if not all message are sent keep counting
          ring2_count(N,C+1,Main);
        true-> % if all message is reached then it's done
          Main ! alldone
      end
  end.

%forward receive message to next processor
forward(Dest) ->
  %io:format("Process ~p sends to ~p~n", [self(),Dest]),
  forwarder(Dest,-1,-1).

%Overwrite forward function only for headnode
%Dest is next processor's pid, N is number of processor and Counter is Counter thread's pid
forward(Dest,N,Pid) ->
  %io:format("Process ~p sends to ~p~n", [self(),Dest]),
  forwarder(Dest,N,Pid).

%forwarder forwared message received to next processeor
%if its head processor it will check if the message is finished the loop, if yes notify Pid thread, other wise keep sending
%N is size of ring
forwarder(Dest, N, Pid) ->
  receive
    quit  ->
      Dest ! quit;
    {M,C} ->
      if
        N < 0 -> % if N is negative, it represent it's not a head processor, then keep sending and counter add 1
          %io:format("Send ~p from ~p to ~p~n", [M, self(),Dest]),
          Dest ! {M,C+1}, forward(Dest,N,Pid);
        C < N-1  -> % if it's not finish the loop keep forwarding
          %io:format("Send ~p from ~p to ~p~n", [M, self(),Dest]),
          Dest ! {M,C+1}, forward(Dest,N,Pid);
        true -> %otherwise sending done to counter thread
          %io:format("Stop sending ~p~n", [M]),
          Pid ! done,
          forward(Dest,N,Pid)
      end
  end.

%init ring
%N is size of the ring
%Pid indicate a process you want to notify your ring's work is done
batch_init(N,Pid) ->
  batch_init_loop(N, self(),Pid).

%create a ring the first processor using differnt forward function
batch_init_loop(N, First,Pid) ->
  Last = lists:foldl(fun spawnForwarder/2, First, lists:seq(1,N)),
  forward(Last,N,Pid).

%spawn each processor
spawnForwarder(_,A) ->
  spawn(ring, forward, [A]).


