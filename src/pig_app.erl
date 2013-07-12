-module(pig_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    {ok, _} = ranch:start_listener(pig, 1,
    ranch_tcp, [{port, 5489}], pig_protocol, []),
    pig_sup:start_link().

stop(_State) ->
    ok.
