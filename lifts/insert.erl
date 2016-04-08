-module(insert).
-export([insert/4,insertHelper/5,insertHelper2/5,insertHelper3/4,insertAProperPostion/7,isContain/2]).

%insert for floor request, return new stop list
insert(Stoplist, Now, Dir, Floor) ->
    [H|_] = insertHelper(Stoplist,Now,Dir,Floor,1),
     H.

%check if target floor already on the list,now is floor
%otherwise find a proper position for new floor on the list.
insertHelper(Stoplist, Now, Dir, Floor,Index) ->
    Flag = isContain(Floor,Stoplist),
    if
        Flag ->
            [Stoplist,Index];
        Now == Floor ->
            [Stoplist,Index];
        true ->
            insertAProperPostion([],Stoplist,Now,Dir,Floor,unkown,Index)
    end.

%helper function for check if the element on the list
isContain(Element, List) ->
    if
        List == [] ->
            false;
        true ->
            [H|T] = List,
            if
                H == Element ->
                    true;
                true ->
                    isContain(Element,T)
            end
    end.

%insert a proper position for target floor, return a new list
%L is list before current position on the stoplist, L2 is after that
%Now is current postion, Floor is tartget position
%Trend it current trend based on StopList
%Index indicate the postion on the stop list.
insertAProperPostion([],[], _, _, Floor, _,Index) ->
    [[Floor],Index];
insertAProperPostion(L1,[], _, _, Floor,_,Index) ->
    [L1++[Floor],Index];
insertAProperPostion([],L2, Now, Dir, Floor,_,Index) ->
    [H2|T2] = L2,
    Flag = insertHelper3(Dir,Now,Floor,H2),
    if
        Flag ->
            [[Floor] ++ L2,Index];
        true->
             insertAProperPostion([H2],T2,Now,Dir,Floor,unkown,Index+1)
    end;
insertAProperPostion(L1,L2, Now, Dir, Floor,Trend,Index) ->
	io:format("L1:~p, L2: ~p, Floor:~p~n", [L1,L2,Floor]),
    L1_last = lists:last(L1),
    [H2|T2] = L2,
    Flag =insertHelper2(Dir,Now,Floor,H2,L1_last),
    if
        Flag ->
            [L1 ++ [Floor] ++ L2,Index];
        (L1_last < Floor) and (Trend == up) and (L1_last > H2) ->
            [L1 ++ [Floor] ++ L2,Index];
        (L1_last > Floor) and (Trend == down) and (L1_last < H2) ->
            [L1 ++ [Floor] ++ L2, Index];
        L1_last > H2 ->
            insertAProperPostion(L1++[H2],T2,Now,Dir,Floor,down,Index+1);
        L1_last < H2 ->
            insertAProperPostion(L1++[H2],T2,Now,Dir,Floor,up,Index+1)
    end.

%help differnt direction insert find right direction when current index between two floor
insertHelper2(any,Now,Floor,H2,_) ->
    ((Now > Floor) and (Floor > H2)) or ((Now < Floor) and (Floor < H2));
insertHelper2(up,Now,Floor,H2,L1_last) ->
    (L1_last < Floor) and (Floor < H2);
insertHelper2(down,Now,Floor,H2,L1_last) ->
    (L1_last > Floor) and (Floor > H2).

%help differnt direction insert find correct postion before the first elment on the list
insertHelper3(any,Now,Floor,H2) ->
    ((Now > Floor) and (Floor > H2)) or ((Now < Floor) and (Floor < H2));
insertHelper3(up,Now,Floor,H2) ->
    (Now < Floor) and (Floor < H2);
insertHelper3(down,Now,Floor,H2) ->
    insertHelper3(any,Now,Floor,H2).
