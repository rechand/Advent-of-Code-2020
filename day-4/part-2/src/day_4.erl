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

-record(passport, {birth_year, issue_year, expr_year, height, hair_color, eye_color, pass_id, country_id = {country_id, <<"not-valid">>}}).

open_file(FilePath) ->
  {ok, Device} = file:open(FilePath, [read, binary]),
  Device.

record_element([Key, Val], Passport) ->
  case Key of
    <<"byr">> ->
      Passport#passport{birth_year = {birth_year, Val}};
    <<"iyr">> ->
      Passport#passport{issue_year = {issue_year, Val}};
    <<"eyr">> ->
      Passport#passport{expr_year = {expr_year, Val}};
    <<"hgt">> ->
      Passport#passport{height = {height, Val}};
    <<"hcl">> ->
      Passport#passport{hair_color = {hair_color, Val}};
    <<"ecl">> ->
      Passport#passport{eye_color = {eye_color, Val}};
    <<"pid">> ->
      Passport#passport{pass_id = {pass_id, Val}};
    <<"cid">> ->
      Passport#passport{country_id = {country_id, Val}}
  end.


process_passport_helper(Elements, Passport) ->
  [H|T] = Elements,
  case binary:split(H, <<":">>) of
    [Key, Val] ->
      NewPassport = record_element([Key, Val], Passport),
      case T of
        [] ->
          NewPassport;
        _ ->
          process_passport_helper(T, NewPassport)
      end;
    Err ->
      erlang:display(Err),
      Passport
  end.

process_passport(Line, Passport) ->
  Elements = binary:split(Line, <<" ">>, [global]),
  process_passport_helper(Elements, Passport).

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

validate_integer_range(Val, R1, R2) ->
  case binary_to_integer(Val) of
    A when A >= R1, A =< R2 ->
      true;
    _ ->
      false
  end.

validate_passport_helper(Key, Val) ->
  [H|_] = binary:split(Val, <<"\n">>),
  case Key of
    birth_year ->
      validate_integer_range(H, 1920, 2002);
    issue_year ->
      validate_integer_range(H, 2010, 2020);
    expr_year ->
      validate_integer_range(H, 2020, 2030);
    height ->
      case binary:split(H, <<"cm">>) of
        [Cm|T] when T =/= [] ->
          validate_integer_range(Cm, 150, 193);
        [_] ->
          [In|_] = binary:split(H, <<"in">>),
          validate_integer_range(In, 59, 76)
      end;
    hair_color ->
     case re:run(H, "^#{1}[0-9a-f]{6}$") of
       {match, _} ->
         true;
       nomatch ->
         false
     end;
    eye_color ->
      case H of
        <<"amb">> ->
          true;
        <<"blu">> ->
          true;
        <<"brn">> ->
          true;
        <<"gry">> ->
          true;
        <<"grn">> ->
          true;
        <<"hzl">> ->
          true;
        <<"oth">> ->
          true;
        _ ->
          false
      end;
    pass_id ->
      case re:run(H, "^[0-9]{9}$") of
        {match, _} ->
          true;
        nomatch ->
          false
      end;
    country_id ->
      true;
    _ ->
      false
  end.

validate_passport(Passport) ->
  erlang:display(Passport),
  case Passport of
    [] ->
      true;
    [H|T] ->
      case H of
        undefined ->
          false;
        {Key, Value} ->
          erlang:display(Key),
          case validate_passport_helper(Key, Value) of
            true ->
              validate_passport(T);
            false ->
              erlang:display(false),
              false
          end
      end
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