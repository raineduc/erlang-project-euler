-module(mpf_SUITE).

-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

-export([all/0, init_per_testcase/2, end_per_testcase/2]).
-export([regular_data_tests/1, regular_data_tests_with_map/1, incorrect_data_tests/1]).

all() ->
    [regular_data_tests, regular_data_tests_with_map, incorrect_data_tests].

init_per_testcase(regular_data_tests, Config) ->
    Cases = [{2, 2}, {3, 3}, {4, 2}, {11, 11}, {476, 17}, {13195, 29}, {600851475143, 6857}],
    [{regular_cases, Cases} | Config];
%% Don't use too big numbers, because with map function's version is pretty slow
init_per_testcase(regular_data_tests_with_map, Config) ->
    Cases = [{2, 2}, {3, 3}, {4, 2}, {11, 11}, {476, 17}, {13195, 29}],
    [{regular_cases_with_map, Cases} | Config];
init_per_testcase(incorrect_data_tests, Config) ->
    Cases = [2, 3],
    [{incorrect_cases, Cases} | Config].

end_per_testcase(regular_data_tests, _) ->
    ok;
end_per_testcase(regular_data_tests_with_map, _) ->
    ok;
end_per_testcase(incorrect_data_tests, _) ->
    ok.

test_regular_case([Case | Tail]) ->
    {Arg, Expected} = Case,
    Expected = mpf_monolith:find_mpf(Arg),
    Expected = mpf_monolith_tailed:find_mpf(Arg),
    Expected = mpf_modular:find_mpf(Arg),
    Expected = mpf_modular_infinite_loop:find_mpf(Arg),
    test_regular_case(Tail);
test_regular_case([]) ->
    ok.

test_regular_case_with_map([Case | Tail]) ->
    {Arg, Expected} = Case,
    Expected = mpf_modular_with_map:find_mpf(Arg),
    test_regular_case(Tail);
test_regular_case_with_map([]) ->
    ok.

test_incorrect_case([Case | Tail]) ->
    ?assertError(function_clause, mpf_monolith:find_mpf(Case)),
    ?assertError(function_clause, mpf_monolith_tailed:find_mpf(Case)),
    ?assertError(function_clause, mpf_modular:find_mpf(Case)),
    ?assertError(function_clause, mpf_modular_with_map:find_mpf(Case)),
    test_incorrect_case(Tail);
test_incorrect_case([]) ->
    ok.

%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------

regular_data_tests(Config) ->
    Cases = ?config(regular_cases, Config),
    test_regular_case(Cases).

regular_data_tests_with_map(Config) ->
    Cases = ?config(regular_cases_with_map, Config),
    test_regular_case_with_map(Cases).

incorrect_data_tests(Config) ->
    Cases = ?config(incorrect_cases, Config),
    test_incorrect_case(Cases).
