-module(area_server1).
-export([rpc/2, loop/0]).

rpc(Pid, Request) ->
    Pid ! {self(), Request},
    receive
        Response ->
            Response
    end.

loop() ->
    receive
        {From, {rectangle, Width, Length}} ->
            From ! Width * Length,
            loop();
        {From, {square, Side}} ->
            From ! Side * Side,
            loop();
        {From, Other} ->
            From ! {error, Other},
            loop()
    end.
