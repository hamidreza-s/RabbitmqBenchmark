-module(rabbit_bench_native_handler).

-export([init/3]).
-export([handle/2]).
-export([terminate/3]).

init(_Transport, Req, []) ->
   {ok, Req, undefined}.

handle(Req, State) ->
   {Count, Req1} = cowboy_req:qs_val(<<"count">>, Req),
   {Msg, Req2} = cowboy_req:qs_val(<<"msg">>, Req1),
   rabbit_bench_main:start_test(undefined, native, binary_to_integer(Count), Msg),
   {ok, Rep} = cowboy_req:reply(200, [
      {<<"content-type">>, <<"text/plain">>}
   ], <<"done">>, Req2),
   {ok, Rep, State}.

terminate(_Reason, _Req, _State) ->
   ok.

