-module(mobius).
-export([is_prime/1, prime_factors/1, is_square_multiple/1, find_square_multiples/2]).

% Проверка, является ли число N простым
is_prime(N) -> is_prime_helper(N, 2).
is_prime_helper(N, Divider) when Divider * Divider > N ->
	true;
is_prime_helper(N, Divider) ->
	if
		N rem Divider == 0 -> false;
		true -> is_prime_helper(N, Divider + 1)
	end.

% Список простых сомножителей числа N
prime_factors(N) when N > 1 ->
    prime_factors_helper(N, 2, []).

prime_factors_helper(1, _, Factors) ->
    Factors;
prime_factors_helper(N, Factor, Factors) when N rem Factor =:= 0 ->
    prime_factors_helper(N div Factor, Factor, [Factor | Factors]);
prime_factors_helper(N, Factor, Factors) ->
    NewFactor = next_prime(Factor),
    prime_factors_helper(N, NewFactor, Factors).

next_prime(N) ->
    case is_prime(N + 1) of
        true -> N + 1;
        false -> next_prime(N + 1)
    end.

% Проверка, делится ли число N на квадрат простого числа
is_square_multiple(N) when N > 0 ->
    is_square_multiple_helper(N, 2).

is_square_multiple_helper(N, Divider) when Divider * Divider =< N ->
    case is_prime(Divider) of
        true ->
            if
            	N rem (Divider * Divider) == 0 -> true;
                true -> is_square_multiple_helper(N, next_prime(Divider))
            end;
        false -> is_square_multiple_helper(N, next_prime(Divider))
    end;
is_square_multiple_helper(_, _) ->
    false.

% Поиск первого числа из послеовательности чисел, делящихся на квадрат простого числа в заданном диапазоне
find_square_multiples(Count, MaxN) when Count > 0, MaxN >= 2 ->
    find_square_multiples_helper(Count, MaxN, 2, 0, 0).

find_square_multiples_helper(Count, MaxN, Num, Consecutive, LastChecked) when Num =< MaxN ->
    case is_square_multiple(Num) of
        true ->
            if
                Consecutive + 1 == Count -> Num - (Count - 1);
                true -> find_square_multiples_helper(Count, MaxN, Num + 1, Consecutive + 1, LastChecked)
            end;
        false -> find_square_multiples_helper(Count, MaxN, Num + 1, 0, Num)
    end;
find_square_multiples_helper(_, _, _, _, _) ->
    fail.