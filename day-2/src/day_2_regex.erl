%%%-------------------------------------------------------------------
%%% @author chand
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Dec 2020 6:00 AM
%%%-------------------------------------------------------------------
-module(day_2_regex).
-author("chand").

%% API
-export([main/0]).

open_file(FilePath) ->
  {ok, Device} = file:open(FilePath, [read, binary]),
  Device.

read_line(Device) ->
  case file:read_line(Device) of
    {ok, Line} ->
      Line;
    eof ->
      eof
  end.

get_values(Line) ->
  [MinMax, ValueColon, Input] = binary:split(Line, <<" ">>, [global]),
  [Value, _] = binary:split(ValueColon, <<":">>),
  [Min, Max] = binary:split(MinMax, <<"-">>),
  {Min, Max, Value, Input}.

check_match(Vals) ->
  erlang:display(Vals),
  {Min, Max, Value, Input} = Vals,
  OpenCurl = <<"{">>,
  CloseCurl = <<"}">>,
  Comma = <<",">>,
  Regex = <<Value/binary, OpenCurl/binary, Min/binary, Comma/binary, Max/binary, CloseCurl/binary>>,
  erlang:display(Regex),
  case re:run(Input, Regex) of
    {match, _} ->
      erlang:display(match),
      {ok, true};
    nomatch ->
      erlang:display(nomatch),
      {ok, false}
  end.

read_match(Device, Valid) ->
  case read_line(Device) of
    eof ->
      Valid;
    Line ->
      Vals = get_values(Line),
      case check_match(Vals) of
        {ok, true} ->
          NewValid = Valid+1,
          read_match(Device, NewValid);
        {ok, false} ->
          read_match(Device, Valid)
      end
  end.

main() ->
  Device = open_file("../input/sample"),
  read_match(Device, 0).