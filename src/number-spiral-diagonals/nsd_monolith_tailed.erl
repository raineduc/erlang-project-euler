%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. окт. 2022 20:05
%%%-------------------------------------------------------------------
-module(nsd_monolith_tailed).
-author("hrami").

%% API
-export([sum_diagonals/1]).

sum_diagonals(1) -> 1;
sum_diagonals(N) when N > 2, N rem 2 /= 0 -> sum_spirals(1, N div 2 + 1, 1, 0).

sum_spirals(1, To, CurrentNumber, _) -> sum_spirals(2, To, CurrentNumber, CurrentNumber);
sum_spirals(Nth, To, CurrentNumber, Sum) when Nth > 1, To >= Nth ->
  Quad = [CurrentNumber + Next * 2 * (Nth - 1) || Next <- [1, 2, 3, 4]],
  [Last|_] = lists:reverse(Quad),
  sum_spirals(Nth + 1, To, Last, Sum + lists:sum(Quad));
sum_spirals(_, _, _, Sum) -> Sum.
