%%% -------------------------------------------------------------------
%%% Author  : PXR
%%% Description :
%%%
%%% Created : 2013-7-16
%%% -------------------------------------------------------------------
-module(player).

-behaviour(gen_server).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% External exports
-export([start_link/1]).

%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-include("route_pb.hrl").

-record(state, {socket_pid, is_login = false}).

%% ====================================================================
%% External functions
%% ====================================================================

start_link(SocketPid) ->
    gen_server:start_link(?MODULE, [SocketPid], []).

%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([SocketPid]) ->
    process_flag(trap_exit, true),
    {ok, #state{socket_pid = SocketPid}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_call(Request, From, State) ->
    Reply = ok,
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_cast({do_send, Packet}, State) ->
    State#state.socket_pid ! Packet,
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------
handle_info({recevie, Data}, #state{is_login = false} = State) ->
    io:format("recevie Data ~w~n", [Data]),
    RouteRec = route_pb:decode_route(Data),
    case RouteRec#route.proto_number of
      10000 ->
         NewState = 
           case login(RouteRec#route.body) of
              ok ->
                 send_login_success_to_client,
                 State#state{is_login = true};
              failed ->
                 send_login_failed_to_client,
                 State;
              not_register ->
                 send_login_failed_to_client,
                 State
           end;
      _ ->
        NewState = State
    end,
    {noreply, NewState};

handle_info({recevie, Data}, #state{is_login = true} = State) ->
    io:format("recevie Data ~w~n", [Data]),
    RouteRec = route_pb:decode_route(Data),
    io:format("routeRec is ~s", [RouteRec]),
    {noreply, State};
handle_info({'EXIT',_ ,_}, State) ->
    {stop, normal, state};

handle_info(Info, State) ->
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(Reason, State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(OldVsn, State, Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------


login(Body) ->
    LoginRec = route_pb:decode_login(Body),
    io:format("loginRec is ~w~n", [LoginRec]).
    
