-module(nsd_SUITE).

-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

-export([all/0]).
-export([odd_number_tests/1, even_number_tests/1, negative_and_zero_tests/1]).

all() ->
    [odd_number_tests, even_number_tests, negative_and_zero_tests].

%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------

odd_number_tests(_) ->
    test_odd(1, 1),
    test_odd(3, 25),
    test_odd(5, 101),
    test_odd(21, 6421),
    test_odd(1001, 669171001).

even_number_tests(_) ->
    test_incorrect_case(2),
    test_incorrect_case(4),
    test_incorrect_case(6),
    test_incorrect_case(10),
    test_incorrect_case(150).

negative_and_zero_tests(_) ->
    test_incorrect_case(-100),
    test_incorrect_case(-99),
    test_incorrect_case(-3),
    test_incorrect_case(-2),
    test_incorrect_case(-1),
    test_incorrect_case(0).

test_odd(Arg, Expected) ->
    ?assertEqual(Expected, nsd_monolith:sum_diagonals(Arg)),
    ?assertEqual(Expected, nsd_monolith_tailed:sum_diagonals(Arg)),
    ?assertEqual(Expected, nsd_modular_with_map:sum_diagonals(Arg)),
    ?assertEqual(Expected, nsd_modular_infinite_loop:sum_diagonals(Arg)).

test_incorrect_case(Arg) ->
    ?assertError(function_clause, nsd_monolith:sum_diagonals(Arg)),
    ?assertError(function_clause, nsd_monolith_tailed:sum_diagonals(Arg)),
    ?assertError(function_clause, nsd_modular:sum_diagonals(Arg)),
    ?assertError(function_clause, nsd_modular_with_map:sum_diagonals(Arg)),
    ?assertError(function_clause, nsd_modular_infinite_loop:sum_diagonals(Arg)).
