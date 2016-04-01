-module(floor).
-export([newFloor/2]).

newFloor(N, Lifts) -> agent:newAgent(fun floor/2, {N, Lifts}).

% Note this code does not change the floor state from one iteration to the next.
% Add information to the state to handle lights on the buttons.
floor(up, {N, Lifts}=State) -> 
	% You fill in here: send a request message to all the lifts, 
	% gather all the responses, choose the best one, send an accept
	% to that lift and a reject to all the others.
        State
	;
floor(down, {N, Lifts}=State) ->
        % You fill in here: consider, whether this needs to be different
	% code than the up code. (Probably not, so write a function
	% that can handle either.)
        State
	;
floor(arriveUp, State) -> State;
floor(arriveDown, State) -> State.


% Choose the best {Lift, Time} from a list of such.
selectBest([], {Lift, Time}=Best) -> Lift ! accept, Best;
selectBest([{Lift, Time}|Rest], {BLift, BTime}=Best) when Time<Best -> BLift! reject, selectBest(Rest, {Lift, Time});
selectBest([{Lift, Time}|Rest], Best) -> Lift ! reject, selectBest(Rest, Best).
