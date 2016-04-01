% An agent factory: pass newAgent a function, Update, and an initial state.
% It spawns a process that repeatedly reads a message from M, calls Update,
% and recursively invokes itself on the new state returned from Update.

% Note that messages sent to the agent should be tuples containing the
% process id of the sender if you expect Update to reply to the message.

-module(agent).
-export([newAgent/2]).

newAgent(Update, InitState) ->
    spawn(fun() -> serve(Update, InitState) end).

serve(Update, InitState) ->
    receive
	M -> 
	    % Uncomment the following line to see the messages received by agents
	    % io:format("~p received ~p~n", [self(), M]),
	    serve(Update, Update(M, InitState))
    end.
	    
		  
