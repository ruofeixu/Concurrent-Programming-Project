% Construct a lift simulation scenario based on number of lifts and 
% number of floors.
% This is a transcription of the Oz version.


-module(simulation).
-export([newScenario/2]).


% To start the whole simulation, call simulation:newScenario().
% Note: if you call it a second time it will fail. But you can call
% it yet again and it will succeed. You don't have to restart erl for
% each test.

newScenario(NumLifts, NumFloors) ->
    NewCabin = cabin:newGui(NumLifts, NumFloors), % NewCabin is a function
    Lifts = [lift:newLift(X) || X <- lists:seq(1, NumLifts)], %forCons(1, NumLifts, fun lift:newLift/1),
    Floors = [floor:newFloor(X, Lifts) || X <- lists:seq(1, NumFloors)], %forCons(1, NumFloors, fun (I) -> floor:newFloor(I, Lifts) end),
    % Each lift needs to be attached to a new cabin.
    lists:foreach(fun({Lift, I}) -> NewCabin(Lift, I) end, lists:zip(Lifts, lists:seq(1,NumLifts))),
    {Lifts, Floors}
.
					    
% Construct a list by calling F(J) for each J in I<=J<=N.
%% forCons(I, N, _F) when I>N ->
%%     []
%% ;
%% forCons(I, N, F) -> [F(I)|forCons(I+1, N, F)]
%% .

% For each lift in the list construct a new cabin. Argument I provides
% an index number for the cabins.
%% linkLifts([], _I, _NewCabin) -> nothing;
%% linkLifts([L|Lr], I, NewCabin) -> NewCabin(L, I), linkLifts(Lr, I+1, NewCabin).
		 

% You can drive your simulation with a sequence of statements such as these:

% S=NewScenario(3, 5).

% {[L1, L2, L3], [F1, F2, F3, F4, F5]} = S.

% F3 ! up.
% F4 ! up.
% F2 ! up.
% L2 ! {stop, 4}.
