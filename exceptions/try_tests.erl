-module(try_tests).
-export([demo1/0, demo2/0]).

demo1() ->
    [catcher(X) || X <- [1,2,3,4,5]].

catcher(N) ->
    try generate_exception(N) of
        Val ->
            {N, normal, Val}
    catch
        throw:X ->
            {N, caught, throw, X};
        exit:X ->
            {N, caught, exit, X};
        error:X ->
            {N, caught, X}
    end.

demo2() ->
    [{X, catch generate_exception(X)} || X <- [1,2,3,4,5]].

generate_exception(1) -> a;
generate_exception(2) -> throw(a);
generate_exception(3) -> {'EXIT',a};
generate_exception(4) -> exit(a);
generate_exception(5) -> error(a).
