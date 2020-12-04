%%%-------------------------------------------------------------------
%%% @author chand
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Dec 2020 6:00 AM
%%%-------------------------------------------------------------------
-module(day_2).
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
  [binary_to_integer(Min)-1, binary_to_integer(Max), Value, Input].

check_match([Min, Max, Value, Input]) ->
 erlang:display(Min),
 erlang:display(Max),
 erlang:display(Value),
 erlang:display(Input),
  case binary_to_list(Input) of
    [] ->
      case Max - Min of
        Res when Res >= 0 ->
          {ok, true};
        Res when Res < 0 ->
          {ok, false}
      end;
    [H|T] ->
      case Value == <<H>> of
        true ->
          check_match([Min+1, Max, Value, list_to_binary(T)]);
        false ->
          check_match([Min, Max, Value, list_to_binary(T)])
      end
  end.

read_match(Device, Valid) ->
  case read_line(Device) of
    eof ->
      Valid;
    Line ->
      Vals = get_values(Line),
      case check_match(Vals) of
        {ok, true} ->
          erlang:display(match),
          erlang:display(Vals),
          NewValid = Valid+1,
          read_match(Device, NewValid);
        {ok, false} ->
          erlang:display(nomatch),
          erlang:display(Vals),
          read_match(Device, Valid)
      end
  end.

main() ->
  Device = open_file("../input/input"),
  read_match(Device, 0).