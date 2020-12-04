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


validate(Entry, Count) ->
  {Min, Max, Elem, Data} = Entry,
  case Data of
    [] ->
      case Count of
        A when A>= Min, A=< Max ->
          true;
        _ ->
          false
      end;
    [H|T] ->
      NewEntry = {Min, Max, Elem, T},
      case list_to_binary([H]) == Elem of
        true ->
          validate(NewEntry, Count+1);
        false ->
          validate(NewEntry, Count)
      end
  end.

parse_line(Line) ->
  case binary:split(Line, <<" ">>, [global]) of
    [Range, ElemColon, DataNL] ->
      [Min, Max] = binary:split(Range, <<"-">>),
      [Elem, _] = binary:split(ElemColon, <<":">>),
      case binary:split(DataNL, <<"\n">>) of
        [H,_] ->
          Data = H;
        [H] ->
          Data = H
      end,
      {binary_to_integer(Min), binary_to_integer(Max), Elem, binary:bin_to_list(Data)}
  end.

read_line(Device) ->
  case file:read_line(Device) of
    {ok, Line} ->
      Line;
    eof ->
      eof
  end.

check_passwords(Device, Count) ->
  case read_line(Device) of
    eof ->
      Count;
    Line ->
      case validate(parse_line(Line), 0) of
        true ->
          check_passwords(Device, Count+1);
        false ->
          check_passwords(Device, Count)
      end
  end.

open_file(FilePath) ->
  {ok, Device} = file:open(FilePath, [read, binary]),
  Device.

main() ->
  Device = open_file("../input/input"),
  check_passwords(Device, 0).