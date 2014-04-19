-module(rabbit_bench_main).
-compile(export_all).
-include("include/amqp_client.hrl").

amqp_send(Channel, Publish, Props, Payload) ->
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

start_test(_Channel, Which, Count, Msg) ->
   Exc = <<"bench_exch">>,
   Key = <<"bench_key">>,
   Publish = #'basic.publish'{exchange = Exc, routing_key = Key},
   Props = #'P_basic'{delivery_mode = 2}, %% persistent msg!
   
   _Result = case Which of
      amqp ->
         {amqp, [amqp_send(_Channel, Publish, Props, Msg) || _ <- lists:seq(1,Count)]};
      native ->
         {native, [native_send(Publish, Props, Msg) || _ <- lists:seq(1,Count)]};
      _ -> {error, badarg}
   end,
   {Which}.
