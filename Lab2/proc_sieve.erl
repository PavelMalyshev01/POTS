-module(proc_sieve).

-export([generate/1, sieve_run/2, gen_print/1]).

-define(TIMEOUT, 100000).

generate(MaxN) ->
    Pid = sieve(),  %% Pid - идентификатор процесса
    generate_help(Pid, 2, MaxN). %% запуск помощника, передаём PID процесса, начальное значение и максимальное число

generate_help(Pid, End, End) ->
    Pid ! {done, self()}, %% отправка сообщения done обратно к себе, self() - Pid текущего процесса
    receive
            Res -> Res, %% список простых чисел
            lists:foreach(  %% вывод списка простых чисел на экран
                fun(N) ->   %% создаем объект функции, чтобы передать через аргумент
                    io:format("~w, ",  [N]) end, Res
            )
    end;

generate_help(Pid, N, End) ->
    Pid ! N, %% отправка следующего числа в решете
    generate_help(Pid, N + 1, End). %% повторный вызов generate_help с увеличенным значением N

sieve() ->
    spawn(proc_sieve, sieve_run, [0, void]). %% создание нового процесса, вызов sieve_run с аргументами [0, void]

sieve_run(0, InvalidPid) -> %% когда текущее простое число равно 0
    receive 
        P -> sieve_run(P, InvalidPid)   %% продолжаем принимать сообщения, пока не получим допустимый PID
    after ?TIMEOUT ->
        io:format("Timeout, P=0~n")
    end;

sieve_run(P, NextPid) when is_pid(NextPid) ->   %% когда есть действительный PID следующего процесса
    receive 
        {done, From} ->
            NextPid ! {done, self()},   %% отправляем сообщение следующему процессу, указывая, что текущий завершился
            receive 
                ListOfRes -> 
                    From ! [P] ++ ListOfRes     %% отправляем список простых чисел обратно процессу, который его запросил
            end;
        N when N rem P == 0 ->  %% если число N делится на текущее простое число P - просто отбрасываем
            sieve_run(P, NextPid);  %% рекурсивный вызов функции для ожидания следующего сообщения
        N when N rem P /= 0 ->  %% если число N не делится на текущее простое число P
            NextPid ! N,            %% отправляем N следующему процессу
            sieve_run(P, NextPid)   %% рекурсивный вызов процесса для следующего числа
    after ?TIMEOUT ->   %% если процесс не получает сообщение после ?TIMEOUT
        io:format("Timeout, P=~p~n", [P])
    end;

sieve_run(P, Invalid) ->    %% когда нет действительного PID следующего процесса
    receive 
        {done, From} ->     %% текущий процесс завершил работу, нет последующего процесса для передачи результата
            From ! [P];     %% отправка простого числа P обратно в From
        N when N rem P == 0 ->  %% если число N делится на текущее простое число P - просто отбрасываем
            sieve_run(P, Invalid);  %% рекурсивный вызов функции для ожидания следующего сообщения
        N when N rem P /= 0 ->  %% если число N не делится на текущее простое число P 
            Pid = spawn(proc_sieve, sieve_run, [0, void]), %% начинаем новый процесс
            Pid ! N,    %% отправляем ему число из предыдущего процесса для дальнейшей обработки
            sieve_run(P, Pid)   %% рекурсивный вызов функции для ожидания следующего сообщения
    after ?TIMEOUT ->
        io:format("Timeout, no pid, P=~p~n", [P])
    end. 

gen_print(MaxN) ->
    generate(MaxN).
