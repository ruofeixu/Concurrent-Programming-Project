-module(cabin).
-export([newGui/2]).

% This cabin module is where the simulation work is done and the
% GUI is managed. This version only displays the lift cabins, showing them
% as yellow when the doors are closed and blue when the doors are open.

% To use: call newGui, which sets up the window for the GUI with the background
% information and returns a function (the fun at the end of newGui) that can 
% be used to create each of the rectangles representing the lifts as well as 
% process to manage that cabin.



-define(WaitTime, 1).
-define(StopTime, 5).
-define(Delta, 5).
-define(StepTime, 0.05).

-define(WidthLift, 80).
-define(HeightFloor, 100).
-define(Gap, 8).
-define(TextSize, 32).

-define(NormalColor, yellow).
-define(StopColor, blue).

% Call once to create the window layout.
newGui(NumLifts, NumFloors) ->
    Width = ?WidthLift * NumLifts, 
    Height = ?HeightFloor * NumFloors,
    Win = gs:window(gs:start(), [{width, Width+?TextSize},
				 {height, Height+?TextSize},
				 {bg, white},
				 {title, "Lift Simulation"}]),
    Canvas = gs:canvas(maincanvas, Win, [{x,0}, {y, 0},
			     {width, Width+?TextSize}, {height, Height+?TextSize}]),
    HalfG = ?Gap/2,
    NewLift = fun (I) -> 
		      X0 = ?WidthLift*(I-1),
		      gs:text(Canvas, [
				       {coords, [{X0+?WidthLift/2, Height+HalfG}]},
				       {font, {times, 18}},
				       {fg, red},
				       {text, io_lib:format("L~p", [I])}
				      ]),
		      gs:rectangle(Canvas, [{coords, [{X0+HalfG, HalfG}, {X0+?WidthLift-HalfG, Height-HalfG}]},
					    {fill, grey}])
		      end,
    lists:foreach(NewLift, lists:seq(1,NumLifts)),
    NewFloor = fun (I) ->
		       gs:text(Canvas, [
					{coords, [{Width+HalfG, ?HeightFloor * ((I-1)+0.5)}]},
					{font, {times, 18}},
					{fg, red},
					{text, io_lib:format("F~p", [NumFloors-I+1])}
				       ])
	       end,
    lists:foreach(NewFloor, lists:seq(1,NumFloors)),
    % Delay mapping the window 'til its contents are determined to avoid flashing
    gs:config(Win, {map, true}),
    % return a function to create new cabin processes and their images
    fun (Lift, N) ->
	    Image = newImage(N, NumFloors),
	    % Create the server process for a cabin
	    spawn(fun() -> serve(Lift, N, Image, 1) end)
    end
    .
    

% Create image rectangles for the cabins and place them at the lowest floor    
newImage(N, NumFloors) ->
    X = (N-1) * ?WidthLift,
    X0 = X + ?Gap,
    X1 = X + ?WidthLift - ?Gap,
    Y = (NumFloors-1) * ?HeightFloor,
    Y0 = Y + ?Gap,
    Y1 = Y + ?HeightFloor - ?Gap,
    Cabin = gs:rectangle(maincanvas, [
				  {coords, [{X0,Y0}, {X1,Y1}]},
				  {fill, ?NormalColor}
				  ]),
    Cabin
.

% image action animates the image of a cabin for one received message
imageAction(Image, up) ->
    % move the image up on the screen gradually
    UpIncrement = fun (_) -> delay(?StepTime), gs:config(Image, {move, {0, -?Delta}}) end,
    lists:foreach(UpIncrement, lists:seq(1, ?HeightFloor div ?Delta))
;
imageAction(Image, down) ->
    % move the image down on the screen gradually
    DownIncrement = fun (_) -> delay(?StepTime), gs:config(Image, {move, {0, ?Delta}}) end,
    lists:foreach(DownIncrement, lists:seq(1, ?HeightFloor div ?Delta))
;
imageAction(Image, stop) ->
    % open the doors and then close them again
    gs:config(Image, {fill, ?StopColor}),
    delay(?StopTime),
    gs:config(Image, {fill, ?NormalColor})
.


% serve is the simulation process for each cabin. It tells the lift controller
% in the lift module that the cabin is at a particular floor then waits for the
% controller to tell it what to do.
serve(Lift, N, Image, Floor) ->
    Lift ! {self(), arrived, Floor},
    receive 
	{Lift, wait} ->
	    delay(?WaitTime), serve(Lift, N, Image, Floor);
	{Lift, up}  -> imageAction(Image, up), serve(Lift, N, Image, Floor+1);
	{Lift, down} -> imageAction(Image, down), serve(Lift, N, Image, Floor-1);
	{Lift, stop} -> imageAction(Image, stop), serve(Lift, N, Image, Floor)
    end.

delay(Time) ->
    receive
	after round(Time*1000) ->
		nothing
    end.
		

%% /*

%% declare NC={NewEnvironment 3 5}


%% declare P S P={NewPort S} {NC P 1}

%% S.1.action=stop
%% S.2.1.action=up
%% S.2.2.1.action=up
%% S.2.2.2.1.action=down
%% {Inspect S}

%% */
