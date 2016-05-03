-module(waitTime).
-export([waitTime/4,computeTime/2]).

%compute waitTime for floor request
waitTime(Stoplist, Now, Dir, Floor) ->
    %get new list with position index
    [NewList,Index] = insert:insertHelper(Stoplist,Now,Dir,Floor,1),
    %get the sublist we need to calculate time
    TimeList = lists:sublist(NewList,Index),
    computeTime(Now,TimeList).

computeTime(_,[]) -> error;
computeTime(Now,[H|T]) ->
    if
        T == [] ->
            abs(Now - H);
        true ->
            Time = computeTime(H,T),
            abs(Now-H) + 5 + Time
    end.

