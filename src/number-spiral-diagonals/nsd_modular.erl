%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. окт. 2022 22:47
%%%-------------------------------------------------------------------
-module(nsd_modular).

%% API
-export([sum_diagonals/1]).

sum_diagonals(1) ->
    1;
sum_diagonals(N) when N > 2, N rem 2 /= 0 ->
    Seq = generate_seq(1, N div 2 + 1, []),
    fold_seq(Seq).

generate_seq(1, To, _) ->
    generate_seq(2, To, [1]);
generate_seq(Nth, To, Seq) when Nth > 1, To >= Nth ->
    [CurrentNumber | _] = Seq,
    Quad = [CurrentNumber + Next * 2 * (Nth - 1) || Next <- [1, 2, 3, 4]],
    Ordered = lists:reverse(Quad),
    generate_seq(Nth + 1, To, Ordered ++ Seq);
generate_seq(_, _, List) ->
    List.

fold_seq(Seq) ->
    lists:sum(Seq).
