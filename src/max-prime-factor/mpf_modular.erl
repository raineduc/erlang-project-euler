%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. окт. 2022 11:53
%%%-------------------------------------------------------------------
-module(mpf_modular).
-author("hrami").

%% API
-export([find_mpf/1]).

find_mpf(2) -> 2;
find_mpf(3) -> 3;
find_mpf(N) when N > 3 ->
  Seq = gen_seq(N, 2, []),
  lists:max(Seq).


gen_seq(RestNumber, PrimeFactor, Seq) when PrimeFactor * PrimeFactor > RestNumber, RestNumber > 1 ->
  [RestNumber|Seq];
gen_seq(RestNumber, PrimeFactor, Seq) when RestNumber > 1, RestNumber rem PrimeFactor == 0 ->
  NewRest = sieve_prime_factor(RestNumber, PrimeFactor),
  gen_seq(NewRest, PrimeFactor + 1, [PrimeFactor|Seq]);
gen_seq(RestNumber, PrimeFactor, Seq) when RestNumber > 1 -> gen_seq(RestNumber, PrimeFactor + 1, Seq);
gen_seq(_, _, Seq) -> Seq.


sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
  sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
sieve_prime_factor(RestNumber, _) -> RestNumber.
