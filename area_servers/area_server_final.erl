-module(area_server_final).
-export([start/0, area/2, loop/0]).

start() -> spawn(area_server_final, loop, []).

area(Pid, What) ->
    rpc(Pid, What).

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
        {From , Other} ->
            From ! {error, Other},
            loop()
    end.
