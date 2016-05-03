-module(floor).
-export([newFloor/2,selectBest/2]).

newFloor(N, Lifts) -> agent:newAgent(fun floor/2, {N, Lifts}).

% Note this code does not change the floor state from one iteration to the next.
% Add information to the state to handle lights on the buttons.
floor(up, {N, Lifts}=State) -> 
	% You fill in here: send a request message to all the lifts, 
	% gather all the responses, choose the best one, send an accept
	% to that lift and a reject to all the others.
    floorHelper(down, {N, Lifts}=State)
	;
floor(down, {N, Lifts}=State) ->
        % You fill in here: consider, whether this needs to be different
	% code than the up code. (Probably not, so write a function
	% that can handle either.)
    floorHelper(down, {N, Lifts}=State)
	;
floor(arriveUp, State) -> State;
floor(arriveDown, State) -> State.


% Choose the best {Lift, Time} from a list of such.
selectBest([], {Lift, _}=Best) -> Lift ! accept, Best;
selectBest([{Lift, Time}|Rest], {BLift, BTime}) when Time<BTime -> BLift! reject, selectBest(Rest, {Lift, Time});
selectBest([{Lift, _}|Rest], Best) -> Lift ! reject, selectBest(Rest, Best).

%send one request to lift and receive wait time
sendRequest(LiftAgent,FloorNum,Dir) ->
    LiftAgent ! {request,FloorNum,self(),Dir},
    receive
        {propose,T}->
            {LiftAgent,T}
    end.

% a helper function for two diffrent direction request
floorHelper(Dir, {N, Lifts}=State) ->
    NumLift = length(Lifts),
    Responses = lists:map(fun({Lift, I , Direction}) -> sendRequest(Lift, I, Direction) end, lists:zip3(Lifts, lists:duplicate(NumLift,N),lists:duplicate(NumLift,Dir))),
    if
       Responses == [] -> fail;
       true->
           [H|T] = Responses,
           selectBest(T,H)
    end,
    State
.