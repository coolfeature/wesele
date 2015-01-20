-module(whale_rest).

-export([init/3,rest_init/2,rest_terminate/2]).
-export([content_types_provided/2]).
-export([hello_to_html/2]).
-export([hello_to_json/2]).
-export([hello_to_text/2]).

-record(state,{templates_path="",sid=""}).

init(_Transport, _Req, _Opts) ->
  {upgrade, protocol, cowboy_rest}.

rest_init(Req,[]) ->
  {Sid,_Path,Req2} = whale_session:on_request(Req),
  TemplatePath = whale_utls:priv_dir() ++ "/app/templates",
  {ok,Req2,#'state'{templates_path=TemplatePath,sid=Sid}}.

content_types_provided(Req, State) ->
  {[
    {<<"text/html">>, hello_to_html},
    {<<"application/json">>, hello_to_json},
    {<<"text/plain">>, hello_to_text}
  ], Req, State}.

hello_to_html(Req, State) ->
  Template = State#'state'.'templates_path' ++ "/index.tpl",
  {ok,_Module} = erlydtl:compile_file(Template,index_dtl),
  Sid = State#'state'.'sid',
  Host = whale_utls:get_env(hostname),
  HttpPort = whale_utls:get_env(http_port),
  ClientTimeout = whale_utls:get_env(client_timeout),
  whale_session_sup:start_session(Sid),
  {ok,Body} = index_dtl:render([
    {sid,Sid}
    ,{hostname,Host}
    ,{http_port,HttpPort}
    ,{client_timeout,ClientTimeout}
    ,{authenticated,false}
  ]),
  {Body, Req, State}.

hello_to_json(Req, State) ->
  Body = <<"{\"rest\": \"Hello World!\"}">>,
  {Body, Req, State}.

hello_to_text(Req, State) ->
  {<<"REST Hello World as text!">>, Req, State}.

rest_terminate(_Req,_State) ->
  ok.
