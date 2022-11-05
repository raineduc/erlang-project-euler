%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. окт. 2022 19:27
%%%-------------------------------------------------------------------
-module(nsd_monolith).
-author("hrami").

%% API
-export([sum_diagonals/1]).

sum_diagonals(1) -> 1;
sum_diagonals(N) when N > 2, N rem 2 /= 0 -> add_spirals(1, N div 2 + 1, 1).

add_spirals(1, To, CurrentNumber) -> CurrentNumber + add_spirals(2, To, CurrentNumber);
add_spirals(Nth, To, CurrentNumber) when Nth > 1, To >= Nth ->
  Quad = [CurrentNumber + Next * 2 * (Nth - 1) || Next <- [1, 2, 3, 4]],
  [Last|_] = lists:reverse(Quad),
  lists:sum(Quad) + add_spirals(Nth + 1, To, Last);
add_spirals(_, _, _) -> 0.

