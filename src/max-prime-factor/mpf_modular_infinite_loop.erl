%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. нояб. 2022 16:53
%%%-------------------------------------------------------------------
-module(mpf_modular_infinite_loop).

%% API
-export([find_mpf/1]).

find_mpf(2) ->
    2;
find_mpf(3) ->
    3;
find_mpf(N) when N > 3 ->
    ProducerPid = spawn(fun producer/0),
    ProducerPid ! {self(), N},
    fold_seq(ProducerPid, 0).

producer() ->
    receive
        {Sender, Number} ->
            iterate_seq(Number, 2, Sender)
    after 5000 ->
        exit(timeout)
    end.

iterate_seq(RestNumber, PrimeFactor, SenderPid)
    when PrimeFactor * PrimeFactor > RestNumber, RestNumber > 1 ->
    SenderPid ! RestNumber,
    SenderPid ! finished;
iterate_seq(RestNumber, PrimeFactor, SenderPid)
    when RestNumber > 1, RestNumber rem PrimeFactor == 0 ->
    NewRest = sieve_prime_factor(RestNumber, PrimeFactor),
    SenderPid ! PrimeFactor,
    iterate_seq(NewRest, PrimeFactor + 1, SenderPid);
iterate_seq(RestNumber, PrimeFactor, SenderPid) when RestNumber > 1 ->
    iterate_seq(RestNumber, PrimeFactor + 1, SenderPid);
iterate_seq(_, _, SenderPid) ->
    SenderPid ! finished.

sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
    sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
sieve_prime_factor(RestNumber, _) ->
    RestNumber.

fold_seq(Pid, Acc) ->
    receive
        X when is_number(X) ->
            fold_seq(Pid, max(Acc, X));
        finished ->
            Acc
    after 5000 ->
        exit(timeout)
    end.
