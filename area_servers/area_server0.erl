-module(area_server0).
-export([loop/0, test/1]).

loop() ->
    receive
        {rectangle, Width, Length} ->
            io:format("Area of rectangle is ~p~n", [Width * Length]),
            loop();
        {square, Side} ->
            io:format("Area of square is ~p~n", [Side * Side]),
            loop()
    end.

test(Text) ->
    io:format("~p~n", [Text]).
