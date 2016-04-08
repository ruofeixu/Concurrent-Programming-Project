-module(waitTime).
-export([waitTime/4,computeTime/2]).

waitTime(Stoplist, Now, Dir, Floor) ->
    [NewList,Index] = insert:insertHelper(Stoplist,Now,Dir,Floor,1),
    TimeList = lists:sublist(NewList,Index),
io:format("a:~p check ~p~n", [Index, TimeList]),
    computeTime(Now,TimeList).

computeTime(_,[]) -> error;
computeTime(Now,[H|T]) ->
io:format("b:~p check ~p~n", [Now, H]),
    if
        T == [] ->
        abs(Now - H);
        true ->
        Time = computeTime(H,T),
        abs(Now-H) + 5 + Time
    end.

