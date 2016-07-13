-module(socket_example).
-export([nano_get_url/0, nano_get_url/1]).
-compile(export_all).
-import(lists, [reverse/1]).
nano_get_url() ->
    nano_get_url("www.google.com"). %% 这里不能是http://www.baidu.com

nano_get_url(Host) ->
    {ok, Socket} = gen_tcp:connect(Host, 80, [binary, {packet, 0}]),
    ok = gen_tcp:send(Socket, "GET / HTTP/1.0\r\n\r\n"),
    receive_data(Socket, [], 0). %% 统计收到多少packets

receive_data(Socket, SoFar, PacketCounter) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("~pth packets is ~p",[PacketCounter + 1, Bin]),
            receive_data(Socket, [Bin | SoFar], PacketCounter + 1);
        {tcp_closed, Socket} ->
            io:format("~p~n", [list_to_binary(reverse(SoFar))]), %% 打印出来的都是而仅是数据
            io:format("received ~p packets ~n",[PacketCounter]),
            io:format("received ~p packets ~n", [length(SoFar)]),
            list_to_binary(reverse(SoFar)) %% 可以显示文字

    end.

start_nano_server() ->
    io:format("start listening\n"),
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4},
                                         {reuseaddr, true},
                                         {active, true}]),
    io:format("start accepting\n"),
    {ok, Socket} = gen_tcp:accept(Listen),
    {ok, {IP, Port}} = inet:peername(Socket),
    io:format("~p ~p~n", [IP, Port]),
    {ok, {Address, SPort}} = inet:sockname(Socket),
    io:format("~p ~p ~n", [Address, SPort]),
    gen_tcp:close(Listen),
    loop(Socket, 0).

start_seq_server() ->
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4},
                                         {reuseaddr, true},
                                         {active, true}]),
    seq_loop(Listen).

seq_loop(Listen) ->
    {ok, Socket} = gen_tcp:accept(Listen),
    {ok, {IP, Port}} = inet:peername(Socket),
    io:format("~p ~p~n", [IP, Port]),
    loop(Socket, 0),
    seq_loop(Listen).

start_parallel_server() ->
    io:format("start listening\n"),
    {ok, Listen} = gen_tcp:listen(2345, [binary, {packet, 4},
                                         {reuseaddr, true},
                                         {active, true}]),
    spawn(fun() -> par_connect(Listen) end).

par_connect(Listen) ->
    io:format("start accepting\n"),
    {ok, Socket} = gen_tcp:accept(Listen),
    {ok, {LocalIP, LocalPort}} = inet:sockname(Socket),
    io:format("Local address and port are ~p,~p~n", [LocalIP, LocalPort]),
    {ok, {RemoteIP, RemotePort}} = inet:peername(Socket),
    io:format("Remote address and port are ~p,~p~n", [RemoteIP, RemotePort]),
    spawn(fun() -> par_connect(Listen) end),
    loop(Socket, 0).

loop(Socket, PacketCounter) ->
    receive
        {tcp, Socket, Bin} ->
            io:format("Server received binary = ~p~n", [Bin]),
            Str = binary_to_term(Bin),
            io:format("Server unpacked ~p~n", [Str]),
            %% Reply = string2value(Str),
            Reply = [Str | ["fff"]],
            io:format("Server reply = ~p~n", [Reply]),
            gen_tcp:send(Socket, term_to_binary(Reply)),
            io:format("\n"),
            loop(Socket, PacketCounter + 1);
        {tcp_closed, Socket} ->
            io:format("server received ~p packets~n", [PacketCounter]),
            io:format("Server socket closed~n")
    end.

nano_client_eval(Str) ->
    {ok, Socket} = gen_tcp:connect("localhost", 2345, [binary, {packet, 4}]),
    ok = gen_tcp:send(Socket, term_to_binary(Str)),
    receive
        {tcp, Socket, Bin} ->
            io:format("Client received binary = ~p~n", [Bin]),
            Val = binary_to_term(Bin),
            io:format("Client result = ~p~n", [Val]),
            gen_tcp:close(Socket)
    end.

string2value(Str) ->
    {ok, Tokens, _} = erl_scan:string(Str ++ "."),
    {ok, Exprs} = erl_parse:parse_exprs(Tokens),
    Bindings = erl_eval:new_bindings(),
    {value, Value, _} = erl_eval:exprs(Exprs, Bindings),
    Value.
