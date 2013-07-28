-module(util).
-include("common.hrl").
-export([gen_proto/0, get_p/1, set_p/2]).

gen_proto() ->
    {ok, Cwd} = file:get_cwd(),
    ProtoDIR = Cwd ++ "/proto/",
    {ok, Files} = file:list_dir(ProtoDIR),
    ?INFO("Files is ~s~n",[Files]),
    Option = [{output_include_dir, Cwd ++ "/include"}, {output_ebin_dir, Cwd ++ "/ebin"}],
    gen_proto(Files, ProtoDIR, Option).

gen_proto([], _ProtoDIR, _Option) ->ok;
gen_proto([FileName|RestFiles], ProtoDIR, Option) ->
    ?INFO("generate ~s~n",[ProtoDIR ++ FileName]),
    case string:str(FileName, ".proto") of
        0 ->
		ok;
    	_ ->
		protobuffs_compile:scan_file(ProtoDIR ++ FileName, Option)
    end,
    gen_proto(RestFiles, ProtoDIR, Option).

get_p(Pname) ->
    case ets:lookup(ets_p, Pname) of
        [] ->
            {ok, Pid} = pig_sup:start_db(),
			set_p(db, Pid),
			Pid;
        [{Pname, Pid}] ->
              Pid
        end.

set_p(Pname, Pid) ->
    ets:insert(ets_p, {Pname, Pid}).
