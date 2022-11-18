-module(mpf_SUITE).

-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

-export([all/0]).
-export([regular_data_tests/1, regular_data_tests_with_map/1, incorrect_data_tests/1]).

all() ->
    [regular_data_tests, regular_data_tests_with_map, incorrect_data_tests].

%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------

%% Common test requires Config argument in test cases
regular_data_tests(_) ->
    test_regular_case(2, 2),
    test_regular_case(3, 3),
    test_regular_case(4, 2),
    test_regular_case(11, 11),
    test_regular_case(476, 17),
    test_regular_case(13195, 29),
    test_regular_case(600851475143, 6857).

regular_data_tests_with_map(_) ->
    test_regular_case_with_map(2, 2),
    test_regular_case_with_map(3, 3),
    test_regular_case_with_map(4, 2),
    test_regular_case_with_map(11, 11),
    test_regular_case_with_map(476, 17),
    test_regular_case_with_map(13195, 29).

incorrect_data_tests(_) ->
    test_incorrect_case(-13195),
    test_incorrect_case(-476),
    test_incorrect_case(-15),
    test_incorrect_case(-11),
    test_incorrect_case(-4),
    test_incorrect_case(-3),
    test_incorrect_case(-2),
    test_incorrect_case(-1),
    test_incorrect_case(0),
    test_incorrect_case(1).

test_regular_case(Arg, Expected) ->
    ?assertEqual(Expected, mpf_monolith:find_mpf(Arg)),
    ?assertEqual(Expected, mpf_monolith_tailed:find_mpf(Arg)),
    ?assertEqual(Expected, mpf_modular:find_mpf(Arg)),
    ?assertEqual(Expected, mpf_modular_infinite_loop:find_mpf(Arg)).

test_regular_case_with_map(Arg, Expected) ->
    ?assertEqual(Expected, mpf_modular_with_map:find_mpf(Arg)).

test_incorrect_case(Arg) ->
    ?assertError(function_clause, mpf_monolith:find_mpf(Arg)),
    ?assertError(function_clause, mpf_monolith_tailed:find_mpf(Arg)),
    ?assertError(function_clause, mpf_modular:find_mpf(Arg)),
    ?assertError(function_clause, mpf_modular_with_map:find_mpf(Arg)).
