%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. нояб. 2022 17:33
%%%-------------------------------------------------------------------
-module(nsd_modular_infinite_loop).
-author("hrami").

%% API
-export([sum_diagonals/1]).

sum_diagonals(1) -> 1;
sum_diagonals(N) when N > 2, N rem 2 /= 0 ->
  Quads = take_quads(N div 2),
  CornerSeq = [1 | lists:flatten(Quads)],
  fold_seq(CornerSeq).

take_quads(Count) ->
  ProducerPid = spawn(fun producer/0),
  ProducerPid ! {self(), Count},
  take_next_quad(Count, []).

take_next_quad(Count, QuadList) when Count > 0 ->
  receive
    [N1, N2, N3, N4] -> [N4, N3, N2, N1 | QuadList]
  end;
take_next_quad(_, QuadList) -> QuadList.


producer() ->
  receive
    {Sender, Count} -> gen_quads(Sender, Count, 1)
  end.


gen_quads(SenderPid, Count, CurrentNumber) ->
  next_quad(SenderPid, 1, Count, CurrentNumber).

next_quad(SenderPid, Nth, Count, CurrentNumber) when Count > 0 ->
  Quad = [CurrentNumber + Next * 2 * Nth || Next <- [1, 2, 3, 4]],
  SenderPid ! Quad,
  [Last|_] = lists:reverse(Quad),
  next_quad(SenderPid, Nth + 1, Count - 1, Last);
next_quad(_, _, _, _) -> ok.

fold_seq(Seq) -> lists:sum(Seq).
