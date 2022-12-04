%%%-------------------------------------------------------------------
%%% @author hrami
%%% @copyright (C) 2022, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 06. нояб. 2022 17:33
%%%-------------------------------------------------------------------
-module(nsd_modular_infinite_loop).

-record(inf_list, {producer, last_value}).
-record(last_value, {last_number, spiral_nth}).

%% API
-export([sum_diagonals/1]).

sum_diagonals(1) ->
    1;
sum_diagonals(N) when N > 2, N rem 2 /= 0 ->
    InfList = new_inf_list(),
    Count = N div 2,
    Result = 1 + fold_inf_seq(InfList, Count, 0),
    close_inf_list(InfList),
    Result.

new_inf_list() ->
    ProducerPid = spawn(fun producer/0),
    #inf_list{producer = ProducerPid,
              last_value = #last_value{last_number = 1, spiral_nth = 1}}.

close_inf_list(#inf_list{producer = ProducerPid}) ->
    ProducerPid ! close.

take_next_quad(#inf_list{producer = ProducerPid, last_value = LastValue}) ->
    ProducerPid ! {self(), take_next_quad, LastValue},
    receive
        {Quad, NewLastValue} ->
            {Quad, #inf_list{producer = ProducerPid, last_value = NewLastValue}}
    after 5000 ->
        exit(timeout)
    end.

producer() ->
    receive
        {Sender, take_next_quad, #last_value{last_number = LastNumber, spiral_nth = Nth}} ->
            Result = next_quad(Nth, LastNumber),
            Sender ! Result,
            producer();
        close ->
            closed
    end.

next_quad(Nth, CurrentNumber) ->
    Quad = [CurrentNumber + Next * 2 * Nth || Next <- [1, 2, 3, 4]],
    [Last | _] = lists:reverse(Quad),
    LastValue = #last_value{last_number = Last, spiral_nth = Nth + 1},
    {Quad, LastValue}.

fold_inf_seq(InfList, Count, Acc) when Count > 0 ->
    {Quad, Next} = take_next_quad(InfList),
    fold_inf_seq(Next, Count - 1, Acc + lists:sum(Quad));
fold_inf_seq(_, _, Acc) ->
    Acc.
