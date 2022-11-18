%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 23. окт. 2022 16:32
%%%-------------------------------------------------------------------
-module(mpf_monolith_tailed).

%% API
-export([find_mpf/1]).

find_mpf(2) ->
    2;
find_mpf(3) ->
    3;
find_mpf(N) when N > 3 ->
    find_max_prime_factor(N, 2, -1).

find_max_prime_factor(RestNumber, PrimeFactor, _)
    when PrimeFactor * PrimeFactor > RestNumber, RestNumber > 1 ->
    RestNumber;
find_max_prime_factor(RestNumber, PrimeFactor, MaxFactor) when RestNumber > 1 ->
    {NewRest, NewMaxFactor} =
        case RestNumber rem PrimeFactor of
            0 ->
                {sieve_prime_factor(RestNumber, PrimeFactor), max(PrimeFactor, MaxFactor)};
            _ ->
                {RestNumber, MaxFactor}
        end,
    find_max_prime_factor(NewRest, PrimeFactor + 1, NewMaxFactor);
find_max_prime_factor(_, _, MaxFactor) ->
    MaxFactor.

sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
    sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
sieve_prime_factor(RestNumber, _) ->
    RestNumber.
