-module(pig).

-export([start/0]).

start() ->
    ok = application:start(ranch),
    ok = application:start(pig).
