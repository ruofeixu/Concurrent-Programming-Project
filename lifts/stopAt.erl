-module(stopAt).
-export([stopAt/3]).

stopAt(Stoplist, Now, Floor) ->
    insert:insert(Stoplist,Now,any,Floor).
