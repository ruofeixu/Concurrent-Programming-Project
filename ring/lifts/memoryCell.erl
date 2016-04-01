% Example agent - a simple memory cell

-module(memoryCell).
-export([newMemoryCell/1]).

memoryCell({read, Requestor}, State) ->
     Requestor ! State,
     State
;
memoryCell({write, NewVal}, _State) -> NewVal
;
memoryCell({swap, Requestor, NewVal}, State) ->
    Requestor ! State,
    NewVal
.

newMemoryCell(InitVal) ->
    agent:newAgent(fun memoryCell/2, InitVal)
.
