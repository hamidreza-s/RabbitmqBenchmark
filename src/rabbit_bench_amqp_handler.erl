-module(rabbit_bench_amqp_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

-include("include/amqp_client.hrl").

init(_Transport, Req, [Channel]) ->
   {ok, Req, Channel}.

handle(Req, State) ->
   Channel = State,
   {Count, Req1} = cowboy_req:qs_val(<<"count">>, Req),
   {Msg, Req2} = cowboy_req:qs_val(<<"msg">>, Req1),
   rabbit_bench_main:start_test(Channel, amqp, binary_to_integer(Count), Msg),
   {ok, Rep} = cowboy_req:reply(200, [
      {<<"content-type">>, <<"text/plain">>}
   ], <<"done">>, Req2),
   {ok, Rep, State}.

terminate(_Reason, _Req, _State) ->
   ok.
