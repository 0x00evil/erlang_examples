-module(naive_tcp).
-export([start_server/1]).

start_server(Port) ->
  io:format("server port is ~p~n", [Port]),
  Pid = spawn(fun() ->
        {ok, LSocket} = gen_tcp:listen(Port, [binary, {active, false}]),
        spawn(fun() -> acceptor(LSocket) end),
        receive
          stop -> ok
        end
    end),
  {ok, Pid}.

acceptor(LSocket) ->
  {ok, CSocket} = gen_tcp:accept(LSocket),
  spawn(fun() -> acceptor(LSocket) end),
  handle(CSocket).

handle(CSocket) ->
  inet:setopts(CSocket, [{active, once}]),
  receive
    {tcp, CSocket, <<"quit", _/binary>>} ->
      gen_tcp:close(CSocket);
    {tcp, CSocket, Msg} ->
      io:format("message from client is ~p~n", [Msg]),
      gen_tcp:send(CSocket, Msg),
      handle(CSocket)
  end.


