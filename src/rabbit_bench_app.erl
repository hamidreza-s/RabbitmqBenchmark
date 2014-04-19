-module(rabbit_bench_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

-include("include/amqp_client.hrl").

start(_StartType, _StartArgs) ->
   application:start(crypto),
   application:start(ranch),
   application:start(cowlib),
   application:start(cowboy),

   {ok, Connection} = amqp_connection:start(#amqp_params_network{
      username = <<"guest">>,
      password = <<"guest">>,
      virtual_host = <<"/">>
   }),
   {ok, Channel} = amqp_connection:open_channel(Connection),

	Dispatch = cowboy_router:compile([
		{'_', [
			{"/amqp", rabbit_bench_amqp_handler, [Channel]},
         {"/native", rabbit_bench_native_handler, []}
		]}
	]),
	{ok, _} = cowboy:start_http(http, 100, [{port, 8080}], [
		{env, [{dispatch, Dispatch}]}
	]),
	rabbit_bench_sup:start_link().

stop(_State) ->
    ok.
