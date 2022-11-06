%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. окт. 2022 17:34
%%%-------------------------------------------------------------------
-module(mpf_monolith).
-author("hrami").

%% API
-export([find_mpf/1]).

find_mpf(2) -> 2;
find_mpf(3) -> 3;
find_mpf(N) when N > 3 -> find_max_prime_factor(N, 2).


find_max_prime_factor(RestNumber, PrimeFactor) when PrimeFactor * PrimeFactor > RestNumber, RestNumber > 1 ->
  RestNumber;
find_max_prime_factor(RestNumber, PrimeFactor) when RestNumber > 1 ->
  NewRest = sieve_prime_factor(RestNumber, PrimeFactor),
  MaxFactor = find_max_prime_factor(NewRest, PrimeFactor + 1),
  if
    RestNumber rem PrimeFactor == 0 ->
      max(PrimeFactor, MaxFactor);
    true -> MaxFactor
  end;
find_max_prime_factor(_, _) -> 0.

sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
  sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
sieve_prime_factor(RestNumber, _) -> RestNumber.

