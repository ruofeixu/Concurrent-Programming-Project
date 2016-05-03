-module(stopAt).
-export([stopAt/3]).

%stop at target floor
%for lift inside request
stopAt(Stoplist, Now, Floor) ->
    insert:insert(Stoplist,Now,any,Floor).
