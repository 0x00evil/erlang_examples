-module(area_server2).
-export([rpc/2, loop/0]).

rpc(Pid, Request) ->
    Pid ! {self(), Request},
    receive
        {Pid, Response} ->
            Response
    end.

loop() ->
    receive
        {From, {rectangle, Width, Length}} ->
            From ! {self(), Width * Length},
            loop();
        {From, {square, Side}} ->
            From ! {self(), Side * Side},
            loop();
        {From, Other} ->
            From ! {self(), {error, Other}},
            loop()
    end.
