%%%-------------------------------------------------------------------
%%% @author chand
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Dec 2020 6:00 AM
%%%-------------------------------------------------------------------
-module(day_4).
-author("chand").

%% API
-export([main/0]).

-record(passport, {birth_year, issue_year, expr_year, height, hair_color, eye_color, pass_id, country_id = not_valid}).

open_file(FilePath) ->
  {ok, Device} = file:open(FilePath, [read, binary]),
  Device.

record_element([Key, Val], Passport) ->
%%  erlang:display(Key),
%%  erlang:display(Val),
  case Key of
    <<"byr">> ->
      Passport#passport{birth_year = Val};
    <<"iyr">> ->
      Passport#passport{issue_year = Val};
    <<"eyr">> ->
      Passport#passport{expr_year = Val};
    <<"hgt">> ->
      Passport#passport{height = Val};
    <<"hcl">> ->
      Passport#passport{hair_color = Val};
    <<"ecl">> ->
      Passport#passport{eye_color = Val};
    <<"pid">> ->
      Passport#passport{pass_id = Val};
    <<"cid">> ->
      Passport#passport{country_id = Val}
  end.


scan_passport(Elements, Passport) ->
  [H|T] = Elements,
%%  erlang:display(H),
%%  erlang:display(T),
  case binary:split(H, <<":">>) of
    [Key, Val] ->
      NewPassport = record_element([Key, Val], Passport),
      case T of
        [] ->
          NewPassport;
        _ ->
          scan_passport(T, NewPassport)
      end;
    Err ->
      erlang:display(Err),
      Passport
  end.

process_passport(Line, Passport) ->
  Elements = binary:split(Line, <<" ">>, [global]),
  scan_passport(Elements, Passport).

read_passport(Device, Passport) ->
  case file:read_line(Device) of
    eof ->
      {eof, Passport};
    {ok, Line} ->
      case Line of
        <<"\n">> ->

          {ok, Passport};
        _ ->
          ProcPassport = process_passport(Line, Passport),
          read_passport(Device, ProcPassport)
      end
  end.

validate_passport(Passport) ->
  case Passport of
    [H|T] ->
      case H of
        undefined ->
          false;
        _ ->
          validate_passport(T)
      end;
    _ ->
      true
  end.

next_passport(Device, Passport, Valid) ->
  case read_passport(Device, Passport) of
    {ok, ProcPassport} ->
      [_|T] = tuple_to_list(ProcPassport),
      case validate_passport(T) of
        true ->
          next_passport(Device, #passport{}, Valid+1);
        false ->
          next_passport(Device, #passport{}, Valid)
      end;
    {eof, ProcPassport} ->
      [_|T] = tuple_to_list(ProcPassport),
      case validate_passport(T) of
        true ->
          Valid + 1;
        false ->
          Valid
      end
  end.

main() ->
  Device = open_file("../input/input"),
  next_passport(Device, #passport{}, 0).