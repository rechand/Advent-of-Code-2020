%%%-------------------------------------------------------------------
%%% @author chand
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Dec 2020 3:09 PM
%%%-------------------------------------------------------------------
-module('day_1').
-author("chand").

%% API
-export([main/0]).

get_integer_list() ->
  {ok, Data} = file:read_file("../input"),
  DataList = binary:split(Data, <<"\r\n">>, [global]),
  [binary_to_integer(X) || X <- DataList].

two_sum_equal_2020([H1,H2|T]) ->
  case 2020 - H1 - H2 of
    0 ->
      {true, H1*H2};
    _ ->
      case T of
        [] ->
          false;
        _ ->
          two_sum_equal_2020([H1|T])
      end
  end.

<<<<<<< Updated upstream
two_sum_check_list(IntList) ->
=======
check_list(IntList) ->
>>>>>>> Stashed changes
  case two_sum_equal_2020(IntList) of
    {true, Ans} ->
      Ans;
    _ ->
      [_ | T] = IntList,
      two_sum_check_list(T)
  end.


three_sum_three_2020(IntList) ->
  case IntList of
    [H1,H2,H3|T] ->
      case (2020 - H1 - H2 - H3) of
        0 ->
          {true, H1*H2*H3};
        _  ->
          case T of
            [] ->
              [];
            _ ->
              three_sum_three_2020([H1,H2]++T)
          end
      end;
    _ ->
      []
  end.


three_sum_two_2020(IntList) ->
  case IntList of
    [H1,H2|T] ->
      case T of
        [] ->
          [];
        _ ->
          case three_sum_three_2020([H1,H2]++T) of
            {true,Ans} ->
              {true,Ans};
            [] ->
              three_sum_two_2020([H1]++T)
          end
      end
  end.


three_sum_check_list(IntList) ->
  case three_sum_two_2020(IntList) of
    {true, Ans} ->
      Ans;
    _ ->
      case IntList of
        [_|T] ->
          three_sum_check_list(T)
      end
  end.

main() ->
  IntList = get_integer_list(),
  PairAns = two_sum_check_list(IntList),
  TripletAns = three_sum_check_list(IntList),
  {PairAns, TripletAns}.
