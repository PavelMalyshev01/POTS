-module(fib).
-export([fib/1, fib_p/1, fib_g/1, tail_fib/1]).

% По спецификации
fib(0) -> 0;
fib(1) -> 1;
fib(N) -> fib(N - 1) + fib(N - 2).

% Без хвостовой рекурсии, сравнение с образцом
fib_p(0) -> 0;
fib_p(1) -> 1;
fib_p(N) -> fib_p(N - 1) + fib_p(N - 2).

% Без хвостовой рекурсии, со сторожевыми последовательностями
fib_g(N) when N > 1 -> fib_g(N - 1) + fib_g(N - 2);
fib_g(0) -> 0;
fib_g(1) -> 1.

% С хвостовой рекурсией
tail_fib(N) -> tail_fib_helper(N, 0, 1).
tail_fib_helper(0, Result1, _) -> Result1;
tail_fib_helper(N, Result1, Result2) ->
    tail_fib_helper(N - 1, Result2, Result2 + Result1).