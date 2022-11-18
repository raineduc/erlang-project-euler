-module(nsd_SUITE).

-include_lib("common_test/include/ct.hrl").
-include_lib("stdlib/include/assert.hrl").

-export([all/0, init_per_testcase/2, end_per_testcase/2]).
-export([odd_number_tests/1, even_number_tests/1, negative_and_zero_tests/1]).

all() ->
    [odd_number_tests, even_number_tests, negative_and_zero_tests].

init_per_testcase(odd_number_tests, Config) ->
    Cases = [{1, 1}, {3, 25}, {5, 101}, {21, 6421}, {1001, 669171001}],
    [{odd_numbers, Cases} | Config];
init_per_testcase(even_number_tests, Config) ->
    Cases = [2, 4, 6, 10, 20, 100, 500, 2000],
    [{even_numbers, Cases} | Config];
init_per_testcase(negative_and_zero_tests, Config) ->
    Cases = [-100, -99, -6, -5, -4, -3, -2, -1, 0],
    [{negative_and_zero, Cases} | Config].

end_per_testcase(odd_number_tests, _) ->
    ok;
end_per_testcase(even_number_tests, _) ->
    ok;
end_per_testcase(negative_and_zero_tests, _) ->
    ok.

test_odd([Case | Tail]) ->
    {Arg, Expected} = Case,
    Expected = nsd_monolith:sum_diagonals(Arg),
    Expected = nsd_monolith_tailed:sum_diagonals(Arg),
    Expected = nsd_modular:sum_diagonals(Arg),
    Expected = nsd_modular_with_map:sum_diagonals(Arg),
    Expected = nsd_modular_infinite_loop:sum_diagonals(Arg),
    test_odd(Tail);
test_odd([]) ->
    ok.

test_incorrect_case([Case | Tail]) ->
    ?assertError(function_clause, nsd_monolith:sum_diagonals(Case)),
    ?assertError(function_clause, nsd_monolith_tailed:sum_diagonals(Case)),
    ?assertError(function_clause, nsd_modular:sum_diagonals(Case)),
    ?assertError(function_clause, nsd_modular_with_map:sum_diagonals(Case)),
    ?assertError(function_clause, nsd_modular_infinite_loop:sum_diagonals(Case)),
    test_incorrect_case(Tail);
test_incorrect_case([]) ->
    ok.

%%--------------------------------------------------------------------
%% TEST CASES
%%--------------------------------------------------------------------

odd_number_tests(Config) ->
    Cases = ?config(odd_numbers, Config),
    test_odd(Cases).

even_number_tests(Config) ->
    Cases = ?config(even_numbers, Config),
    test_incorrect_case(Cases).

negative_and_zero_tests(Config) ->
    Cases = ?config(negative_and_zero, Config),
    test_incorrect_case(Cases).
