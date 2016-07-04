-module(quick_sort).
-export([qsort/1]).

qsort([]) -> [];
qsort([H | T]) ->
    qsort([X || X <- T, X < H]) ++ [H] ++ qsort([X || X <- T, X >= H]).
