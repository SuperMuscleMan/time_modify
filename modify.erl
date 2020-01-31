-module(modify).
%%%=======================STATEMENT====================
%% @doc 修改所有文件的mtime属性，解决因往返修改系统时间导致rebar编译所有文件问题。
-description("modify").
-copyright('').
-author("wmh, SuperMuscleMan@outlook.com").
-vsn(1).
%%%=======================EXPORT=======================
-export([start/0, start/1]).
%%-export([test/2]).
%%%=======================INCLUDE======================
-include_lib("kernel/include/file.hrl").
%%%=======================RECORD=======================

%%%=======================DEFINE=======================
-define(Default_RootDir, "../").%%根目录
-define(Default_Suffix, [".erl", ".hrl"]).%%文件后缀
-define(Default_ErlCInfo, "../.rebar/erlcinfo").%%rebar记录文件路径
%%%=================EXPORTED FUNCTIONS=================

%% -----------------------------------------------------------------
%% Func: 
%% Description: 文件修改时间
%% Returns: 
%% -----------------------------------------------------------------
start() ->
	start(?Default_RootDir).
start(RootDir) ->
	erlang:statistics(wall_clock),
	io:format("[~p] [~p] | start.~n", [?MODULE, ?LINE]),
	All = all_regular(RootDir, ?Default_Suffix),
	io:format("[~p] [~p] | total num:~p~n", [?MODULE, ?LINE, {length(All)}]),
	CurTime = calendar:local_time(),
	modify_time(All, CurTime),
	del_file(?Default_ErlCInfo),
	{_, UsrTime} = erlang:statistics(wall_clock),
	io:format("[~p] [~p] | success, usrTime:~pms~n", [?MODULE, ?LINE, {UsrTime}]).
%% -----------------------------------------------------------------
%% Func:
%% Description:删除文件
%% Returns:
%% -----------------------------------------------------------------
del_file(Path) ->
	case file:delete(Path) of
		ok ->
			ok;
		Err ->
			exit({Err, Path})
	end.

%% -----------------------------------------------------------------
%% Func:
%% Description:修改时间
%% Returns:
%% -----------------------------------------------------------------
modify_time([{Path, FileInfo} | T], CurTime) ->
	case file:write_file_info(Path, FileInfo#file_info{mtime = CurTime}) of
		ok ->
			modify_time(T, CurTime);
		Err ->
			io:format("[~p] [~p] | Err:~p~n", [?MODULE, ?LINE, {Err, Path}]),
			modify_time(T, CurTime)
	end;
modify_time([], _) ->
	ok.

%% -----------------------------------------------------------------
%% Func:
%% Description:获取所有文件
%% Returns:
%% -----------------------------------------------------------------
all_regular(Dir, Suffix) ->
	List = list_dir(Dir),
	all_regular(List, Dir, [], Suffix, []).
all_regular([], _Dir, [], _Suffix, Result) ->
	Result;
all_regular([], _Dir, [{SubDir, SubList} | T], Suffix, Result) ->
	all_regular(SubList, SubDir, T, Suffix, Result);
all_regular([H | T], Dir, DirList, Suffix, Result) ->
	Path = Dir ++ [$/ | H],
	case file:read_file_info(Path) of
		{ok, #file_info{type = directory}} ->
			SubList = list_dir(Path),
			all_regular(T, Dir, [{Path, SubList} | DirList], Suffix, Result);
		{ok, #file_info{type = regular} = Info} ->
			NowResult =
				case lists:member(filename:extension(H), Suffix) of
					true ->
						[{Path, Info} | Result];
					_ ->
						Result
				end,
			all_regular(T, Dir, DirList, Suffix, NowResult);
		_ ->
			all_regular(T, Dir, DirList, Suffix, Result)
	end.

%==========================DEFINE=======================
%% -----------------------------------------------------------------
%% Func:
%% Description:获取dir目录下所有文件名
%% Returns:
%% -----------------------------------------------------------------
list_dir(Dir) ->
	case file:list_dir(Dir) of
		{ok, Var} -> Var;
		Err -> exit({Err, Dir})
	end.

%% -----------------------------------------------------------------
%% Func:
%% Description:测试
%% Returns:
%% -----------------------------------------------------------------
%%test(Dir, Suffix) ->
%%	all_regular(Dir, Suffix).
