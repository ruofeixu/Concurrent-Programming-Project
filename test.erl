-module(test).
-export([t1/1]).

t1(N) ->
  [{A,B,C} ||
    A <- lists:seq(1,N),
    B <- lists:seq(1,N),
    C <- lists:seq(1,N),
    A+B+C =< N,
    A*A + B*B =:=C*C
  ].

