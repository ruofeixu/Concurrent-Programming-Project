-module(lift).
-export([newLift/1]).

% Code for the lift agents. Things to think about:
% Challenge: does the process always have sufficient information
% e.g. about the floor agents so it can send the messages it needs to send.
liftProcess({request, FloorNum, FloorAgent, Direction}, {Now, Stoplist}) ->
    NewStoplist = Stoplist, % you have to compute this right
    {Now, NewStoplist}
;
% stop messages are received from the buttons inside the lift
% for our simulation they will be sent directly from the command line to the lift process
liftProcess({stop, FloorNum}, {Now, Stoplist}) ->
    NewStoplist = Stoplist, % you have to compute this right
    {Now, NewStoplist}
;
% arrived messages come from the Cabin agent that runs the lift cabin up and 
% down in its shaft. The lift agent should respond with an up, down, stop or wait message
% depending on what the lift needs to do next. Send stop if the lift should stop on this floor,
% send wait if the lift has nothing to do.
liftProcess({Cabin, arrived, FloorNum}, {Now, Stoplist}) -> 
    % for demonstration purposes the following controller is included so the GUI does something interesting
    % in the absence of actual control logic. Replace it with your own controller logic.
    % Note that the state for this controller is just an atom -- yours will really use a
    % list as the value of Stoplist.
    % Note also that you can have a different type of state if you need it -- the
    % generic agent code that is calling this is perfectly happy to manage whatever
    % kind of state you specify provided you use it consistently -- i.e. pass it as the
    % initial state and return it from each possible action of this function.
    case {FloorNum, Stoplist} of
	{FloorNum, stopUp} -> Cabin ! {self(), stop}, {FloorNum, up};
	{FloorNum, stopDown} -> Cabin ! {self(), stop}, {FloorNum, down};
	{FloorNum, up} when FloorNum < 5 -> Cabin ! {self(), up}, {FloorNum, stopUp};
	{FloorNum, _} when FloorNum == 5 -> Cabin ! {self(), down}, {FloorNum, stopDown};
	{FloorNum, down} when FloorNum > 1 -> Cabin ! {self(), down}, {FloorNum, stopDown};
	{FloorNum, _} when FloorNum == 1 -> Cabin ! {self(), up}, {FloorNum, stopUp}
    end
.

% Create a new lift agent with an empty stop list and located on Floor 1.
% Takes lift number as parameter but not used.
newLift(_N) ->
     agent:newAgent(fun liftProcess/2,  {1, []}).
