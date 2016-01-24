-module(file_example).
-export([ls/1]).
ls(Dir) ->
    {ok, FileList} = file:list_dir(Dir),
    lists:map(fun(File) -> {File, file_size_and_type(File)} end, FileList).

file_size_and_type(File) ->
    filelib:file_size(File).
