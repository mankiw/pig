
-module(pig_sup).

-behaviour(supervisor).

%% API
-export([start_link/0, start_child/1, start_db/0]).

%% Supervisor callbacks
-export([init/1]).

%% Helper macro for declaring children of supervisor
-define(CHILD(I, Type), {I, {I, start_link, []}, permanent, 5000, Type, [I]}).

%% ===================================================================
%% API functions
%% ===================================================================

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% ===================================================================
%% Supervisor callbacks
%% ===================================================================

init([]) ->
    ets:new(ets_session, [ordered_set, public, named_table]),
    ChildSpec = {player_serv, {player, start_link, []}, temporary, brutal_kill, worker, [player]},
    {ok, { {simple_one_for_one, 5, 10}, [ChildSpec]} }.

start_db() ->
    {ok, C} = supervisor:start_child(pig_sup, []),
    util:set_p(db, C),
    C.

start_child(SocketPid) ->
    {ok, Pid} = supervisor:start_child(pig_sup, [SocketPid]),
    Pid.
