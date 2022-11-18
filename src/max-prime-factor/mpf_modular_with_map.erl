%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 05. нояб. 2022 18:19
%%%-------------------------------------------------------------------
-module(mpf_modular_with_map).

%% API
-export([find_mpf/1]).

find_mpf(2) ->
    2;
find_mpf(3) ->
    3;
find_mpf(N) when N > 3 ->
    Seq = lists:seq(2, N, 1),
    MappedSeq = map_seq(Seq),
    FilteredSeq = filter_seq(MappedSeq),
    fold_seq(FilteredSeq).

map_seq(Seq) ->
    {Mapped, _} =
        lists:mapfoldl(fun(X, RestNumber) ->
                          case RestNumber rem X of
                              0 ->
                                  {{X, true}, sieve_prime_factor(RestNumber, X)};
                              _ ->
                                  {{X, false}, RestNumber}
                          end
                       end,
                       lists:last(Seq),
                       Seq),
    Mapped.

filter_seq(Seq) ->
    lists:filter(fun({_, IsPrimeFactor}) -> IsPrimeFactor end, Seq).

fold_seq(Seq) ->
    ElementList = lists:map(fun({Elem, _}) -> Elem end, Seq),
    lists:max(ElementList).

sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
    sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
sieve_prime_factor(RestNumber, _) ->
    RestNumber.
