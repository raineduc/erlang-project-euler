%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. нояб. 2022 16:53
%%%-------------------------------------------------------------------
-module(mpf_modular_infinite_loop).

-record(inf_list, {producer, last_value}).

%% API
-export([find_mpf/1]).

find_mpf(2) ->
    2;
find_mpf(3) ->
    3;
find_mpf(N) when N > 3 ->
    InfSeq = new_inf_seq(),
    Result = fold_seq(InfSeq, N, 1),
    close_inf_list(InfSeq),
    Result.

new_inf_seq() ->
    ProducerPid = spawn(fun producer/0),
    #inf_list{producer = ProducerPid, last_value = 1}.

close_inf_list(#inf_list{producer = ProducerPid}) ->
    ProducerPid ! close.

take_next_number(#inf_list{producer = ProducerPid, last_value = LastValue}) ->
    ProducerPid ! {self(), take_next, LastValue},
    receive
        Value ->
            {Value, #inf_list{producer = ProducerPid, last_value = Value}}
    after 5000 ->
        exit(timeout)
    end.

producer() ->
    receive
        {Sender, take_next, LastValue} ->
            Sender ! LastValue + 1,
            producer();
        close ->
            closed
    end.

fold_seq(InfSeq, N, Acc) ->
    fold_seq(InfSeq, N, Acc, N).

fold_seq(InfSeq, N, Acc, RestNumber) when RestNumber > 1 ->
    {Value, Next} = take_next_number(InfSeq),
    case RestNumber rem Value of
        0 ->
            fold_seq(Next, N, max(Acc, Value), sieve_prime_factor(RestNumber, Value));
        _ ->
            fold_seq(Next, N, Acc, RestNumber)
    end;
fold_seq(_, _, Acc, _) ->
    Acc.

sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
    sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
sieve_prime_factor(RestNumber, _) ->
    RestNumber.
