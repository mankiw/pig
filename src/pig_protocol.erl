-module(pig_protocol).
-export([start_link/4, init/4]).

-include("common.hrl").

-export([handle_request/2, handle_response/2, handle_close/1]).

-define(RECEVIE_TIMEOUT, 90000).

start_link(Ref, Socket, Transport, Opts) ->
	Pid = spawn_link(?MODULE, init, [Ref, Socket, Transport, Opts]),
	{ok, Pid}.

init(Ref, Socket, Transport, _Opts = []) ->
	ok = ranch:accept_ack(Ref),
    PlayerPid = player_sup:start_child(self()),
    link(PlayerPid),
    Transport:recv(Socket, ?RECEVIE_TIMEOUT, PlayerPid).

handle_response(Socket, Packet) ->
    gen_tcp:send(Socket, Packet).

handle_request(PlayerPid, Data) ->
	?INFO("receive data ~w", [Data]),
    PlayerPid ! {recevie, Data},
    ok.



handle_close(Socket) ->
    gen_tcp:close(Socket).
