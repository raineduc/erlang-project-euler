%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. окт. 2022 23:41
%%%-------------------------------------------------------------------
-module(nsd_modular_with_map).
-author("hrami").

%% API
-export([sum_diagonals/1]).

sum_diagonals(1) -> 1;
sum_diagonals(N) when N > 2, N rem 2 /= 0 ->
  Seq = lists:seq(2, N div 2 + 1),
  CornerSeq = [1 | map_seq(Seq)],
  fold_seq(CornerSeq).


map_seq(Seq) ->
  {Mapped, _} = lists:mapfoldl(
    fun(X, Last) ->
      Quad = generate_quad(X, Last),
      [LastElem | _] = lists:reverse(Quad),
      {Quad, LastElem}
    end,
    1,
    Seq
  ),
  lists:flatten(Mapped).


generate_quad(Nth, Last) when Nth > 1 ->
  [Last + Next * 2 * (Nth - 1) || Next <- [1, 2, 3, 4]].


fold_seq(Seq) -> lists:sum(Seq).
