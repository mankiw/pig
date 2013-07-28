-module(pig).

-export([start/0]).

start() ->
	ok = lager:start(),
    ok = application:start(ranch),
    util:gen_proto(),
    ok = application:start(pig).
