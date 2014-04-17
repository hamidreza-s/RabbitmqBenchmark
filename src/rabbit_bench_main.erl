-module(rabbit_bench_main).
-compile(export_all).
-include("include/amqp_client.hrl").

amqp_send(Publish, Props, Payload) ->
   {ok, Connection} = amqp_connection:start(#amqp_params_network{
      username = <<"guest">>,
      password = <<"guest">>,
      virtual_host = <<"/">>
   }),
   {ok, Channel} = amqp_connection:open_channel(Connection),
   Msg = #amqp_msg{props = Props, payload = Payload},
   amqp_channel:cast(Channel, Publish, Msg).

native_send(Publish, Props, Payload) ->
   Exc = Publish#'basic.publish'.exchange,
   Key = Publish#'basic.publish'.routing_key,
   Route = {resource, <<"/">>, exchange, Exc},
   rpc:call(
      rabbit@localhost, 
      rabbit_basic, 
      publish, 
      [Route, Key, Props, Payload]
   ).

start_test(Which) ->
   Exc = <<"sms">>,
   Key = <<"rcv">>,
   Publish = #'basic.publish'{exchange = Exc, routing_key = Key},
   Props = #'P_basic'{delivery_mode = 2}, %% persistent msg!
   Payload = <<"hello world!">>,
   
   T1 = erlang:now(),
   _Result = case Which of
      amqp ->
         {amqp, [amqp_send(Publish, Props, Payload) || _ <- lists:seq(1,100)]};
      native ->
         {native, [native_send(Publish, Props, Payload) || _ <- lists:seq(1,100)]};
      _ -> {error, badarg}
   end,
   {Which, timer(T1)}.

timer(T1) -> 
   T2 = erlang:now(),
   timer:now_diff(T2, T1).
