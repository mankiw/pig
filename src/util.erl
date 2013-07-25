-module(util).

-export([gen_proto/0]).

gen_proto() ->
    {ok, Cwd} = file:get_cwd(),
    ProtoDIR = Cwd ++ "/proto/",
    {ok, Files} = file:list_dir(ProtoDIR),
    io:format("Files is ~s~n",[Files]),
    Option = [{output_include_dir, Cwd ++ "/include"}, {output_ebin_dir, Cwd ++ "/ebin"}],
    gen_proto(Files, ProtoDIR, Option).

gen_proto([], _ProtoDIR, _Option) ->ok;
gen_proto([FileName|RestFiles], ProtoDIR, Option) ->
    io:format("generate ~s~n",[ProtoDIR ++ FileName]),
    case string:str(FileName, ".proto") of
        0 ->
		ok;
    	_ ->
		protobuffs_compile:scan_file(ProtoDIR ++ FileName, Option)
    end,
    gen_proto(RestFiles, ProtoDIR, Option).
