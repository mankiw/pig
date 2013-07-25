-module(pig).

-export([start/0]).

start() ->
    ok = application:start(ranch),
    util:gen_proto(),
    ok = application:start(pig).
