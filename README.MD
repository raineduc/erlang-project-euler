# Project Euler tasks
Министерство науки и высшего образования Российской Федерации федеральное государственное автономное образовательное учреждение высшего образования

«Национальный исследовательский университет ИТМО»

---
__ФПИиКТ, Системное и Прикладное Программное Обеспечение__

__Лабораторная работа №1__

по Функциональному программированию

Выполнил: Хузин Р.Р.

Группа: P34112

Преподаватель: Пенской Александр Владимирович

###### Санкт-Петербург
###### 2022 г.
---

## Описание проблемы
### [Largest prime factor](https://projecteuler.net/problem=3)

#### Problem 3

The prime factors of 13195 are 5, 7, 13 and 29.

What is the largest prime factor of the number 600851475143?

### [Number spiral diagonals](https://projecteuler.net/problem=28)

#### Problem 28

Starting with the number 1 and moving to the right in a clockwise direction a 5 by 5 spiral is formed as follows:

```
21 22 23 24 25
20  7  8  9 10
19  6  1  2 11
18  5  4  3 12
17 16 15 14 13
```

It can be verified that the sum of the numbers on the diagonals is 101.

What is the sum of the numbers on the diagonals in a 1001 by 1001 spiral formed in the same way?


## Ключевые элементы реализации с минимальными комментариями

### Задача 3

1. __Монолитная реализация__
    + __хвостовая рекурсия__
    ```erlang
    -module(mpf_monolith_tailed).
    -author("hrami").
    
    %% API
    -export([find_mpf/1]).
    
    find_mpf(2) -> 2;
    find_mpf(3) -> 3;
    find_mpf(N) when N > 3 -> find_max_prime_factor(N, 2, -1).
    
    
    find_max_prime_factor(RestNumber, PrimeFactor, _) when PrimeFactor * PrimeFactor > RestNumber, RestNumber > 1 ->
      RestNumber;
    
    find_max_prime_factor(RestNumber, PrimeFactor, MaxFactor) when RestNumber > 1 ->
      {NewRest, NewMaxFactor} =
        if RestNumber rem PrimeFactor == 0 ->
          {sieve_prime_factor(RestNumber, PrimeFactor), max(PrimeFactor, MaxFactor)};
          true -> {RestNumber, MaxFactor}
        end,
      find_max_prime_factor(NewRest, PrimeFactor + 1, NewMaxFactor);
    
    find_max_prime_factor(_, _, MaxFactor) -> MaxFactor.
    
    
    sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
      sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
    
    sieve_prime_factor(RestNumber, _) -> RestNumber.
    ```
    
    В качестве параметра передается текущий найденный максимальный множитель.
    + __рекурсия__
   ```erlang
   -module(mpf_monolith).
   -author("hrami").
   
   %% API
   -export([find_mpf/1]).
   
   find_mpf(2) -> 2;
   find_mpf(3) -> 3;
   find_mpf(N) when N > 3 -> find_max_prime_factor(N, 2).
   
   
   find_max_prime_factor(RestNumber, PrimeFactor) when PrimeFactor * PrimeFactor > RestNumber, RestNumber > 1 ->
     RestNumber;
   find_max_prime_factor(RestNumber, PrimeFactor) when RestNumber > 1 ->
     NewRest = sieve_prime_factor(RestNumber, PrimeFactor),
     MaxFactor = find_max_prime_factor(NewRest, PrimeFactor + 1),
     if
       RestNumber rem PrimeFactor == 0 ->
         max(PrimeFactor, MaxFactor);
       true -> MaxFactor
     end;
   find_max_prime_factor(_, _) -> 0.
   
   sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
     sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
   sieve_prime_factor(RestNumber, _) -> RestNumber.
   ```

   В рекурсивной функции обрабатывается текущий простой множитель, __RestNumber__ содержит число, из которого отсеяли все предыдущие множители
2. __Модульная реализация__
   ```erlang
   -module(mpf_modular).
   -author("hrami").
   
   %% API
   -export([find_mpf/1]).
   
   find_mpf(2) -> 2;
   find_mpf(3) -> 3;
   find_mpf(N) when N > 3 ->
      Seq = gen_seq(N, 2, []),
      lists:max(Seq).
   
   
   gen_seq(RestNumber, PrimeFactor, Seq) when PrimeFactor * PrimeFactor > RestNumber, RestNumber > 1 ->
      [RestNumber|Seq];
   gen_seq(RestNumber, PrimeFactor, Seq) when RestNumber > 1, RestNumber rem PrimeFactor == 0 ->
      NewRest = sieve_prime_factor(RestNumber, PrimeFactor),
      gen_seq(NewRest, PrimeFactor + 1, [PrimeFactor|Seq]);
   gen_seq(RestNumber, PrimeFactor, Seq) when RestNumber > 1 -> gen_seq(RestNumber, PrimeFactor + 1, Seq);
   gen_seq(_, _, Seq) -> Seq.
   
   
   sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
      sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
   sieve_prime_factor(RestNumber, _) -> RestNumber.
   ```
3. __Модульная реализация с применением отображения (map)__
    ```erlang
   -module(mpf_modular_with_map).
    -author("hrami").
    
    %% API
    -export([find_mpf/1]).
    
    find_mpf(2) -> 2;
    find_mpf(3) -> 3;
    find_mpf(N) when N > 3 ->
      Seq = lists:seq(2, N, 1),
      MappedSeq = map_seq(Seq),
      FilteredSeq = filter_seq(MappedSeq),
      fold_seq(FilteredSeq).
    
    
    map_seq(Seq) ->
      {Mapped, _} = lists:mapfoldl(
        fun(X, RestNumber) ->
          if
            RestNumber rem X == 0 -> {{X, true}, sieve_prime_factor(RestNumber, X)};
            true -> {{X, false}, RestNumber}
          end
        end,
        lists:last(Seq),
        Seq
      ),
      Mapped.
    
    filter_seq(Seq) ->
      lists:filter(
        fun({_, IsPrimeFactor}) -> IsPrimeFactor end,
        Seq
      ).
    
    fold_seq(Seq) ->
      ElementList = lists:map(
        fun({Elem, _}) -> Elem end,
        Seq
      ),
      lists:max(ElementList).
    
    sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
      sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
    sieve_prime_factor(RestNumber, _) -> RestNumber.
   ```
   
   __map_seq__ возвращает список с элементами __{N, IsPrimeFactor}__, __N__ - число в исходной последовательности
4. __Модульная реализация с имитацией бесконечных списков с помощью Erlang процессов__
    ```erlang
   -module(mpf_modular_infinite_loop).
   -author("hrami").
   
   %% API
   -export([find_mpf/1]).
   
   find_mpf(2) -> 2;
   find_mpf(3) -> 3;
   find_mpf(N) when N > 3 ->
     ProducerPid = spawn(fun producer/0),
     ProducerPid ! {self(), N},
     fold_seq(ProducerPid, 0).
   
   producer() ->
     receive
       {Sender, Number} ->
         iterate_seq(Number, 2, Sender)
     end.
   
   iterate_seq(RestNumber, PrimeFactor, SenderPid) when PrimeFactor * PrimeFactor > RestNumber, RestNumber > 1 ->
     SenderPid ! RestNumber,
     SenderPid ! finished;
   iterate_seq(RestNumber, PrimeFactor, SenderPid) when RestNumber > 1, RestNumber rem PrimeFactor == 0 ->
     NewRest = sieve_prime_factor(RestNumber, PrimeFactor),
     SenderPid ! PrimeFactor,
     iterate_seq(NewRest, PrimeFactor + 1, SenderPid);
   iterate_seq(RestNumber, PrimeFactor, SenderPid) when RestNumber > 1 -> iterate_seq(RestNumber, PrimeFactor + 1, SenderPid);
   iterate_seq(_, _, SenderPid) -> SenderPid ! finished.
   
   sieve_prime_factor(RestNumber, PrimeFactor) when RestNumber rem PrimeFactor == 0 ->
     sieve_prime_factor(RestNumber div PrimeFactor, PrimeFactor);
   sieve_prime_factor(RestNumber, _) -> RestNumber.
   
   fold_seq(Pid, Acc) ->
     receive
       X when is_number(X) -> fold_seq(Pid, max(Acc, X));
       finished -> Acc
     end.
    ```
   Процесс __producer()__ отправляет найденные простые множители, атом __finished__ при завершении поиска
5. __Реализация на языке Go__
   ```go
   func FindMPF(n int) int {
       if n < 1 {
           panic("n must be greater than 0")
       }
       maxFactor := -1
       d := 2
       for ; n > 1; {
           for ; n % d == 0; n /= d {
               if d > maxFactor {
                   maxFactor = d
               }
           }
           d += 1
           if d*d > n {
               if n > 1 && n > maxFactor {
                   maxFactor = n
               }
               break
           }
   
       }
       return maxFactor
   }
   ```
### Problem 28

1. __Монолитная реализация__
   + __Хвостовая рекурсия__
   ```erlang
   -module(nsd_monolith_tailed).
   -author("hrami").
   
   %% API
   -export([sum_diagonals/1]).
   
   sum_diagonals(1) -> 1;
   sum_diagonals(N) when N > 2, N rem 2 /= 0 -> sum_spirals(1, N div 2 + 1, 1, 0).
   
   sum_spirals(1, To, CurrentNumber, _) -> sum_spirals(2, To, CurrentNumber, CurrentNumber);
   sum_spirals(Nth, To, CurrentNumber, Sum) when Nth > 1, To >= Nth ->
     Quad = [CurrentNumber + Next * 2 * (Nth - 1) || Next <- [1, 2, 3, 4]],
     [Last|_] = lists:reverse(Quad),
     sum_spirals(Nth + 1, To, Last, Sum + lists:sum(Quad));
   sum_spirals(_, _, _, Sum) -> Sum.
   ```
   
   Sum накапливает сумму по спиралям.
   + __Рекурсия__
   ```erlang
   -module(nsd_monolith).
   -author("hrami").
   
   %% API
   -export([sum_diagonals/1]).
   
   sum_diagonals(1) -> 1;
   sum_diagonals(N) when N > 2, N rem 2 /= 0 -> add_spirals(1, N div 2 + 1, 1).
   
   add_spirals(1, To, CurrentNumber) -> CurrentNumber + add_spirals(2, To, CurrentNumber);
   add_spirals(Nth, To, CurrentNumber) when Nth > 1, To >= Nth ->
   Quad = [CurrentNumber + Next * 2 * (Nth - 1) || Next <- [1, 2, 3, 4]],
   [Last|_] = lists:reverse(Quad),
   lists:sum(Quad) + add_spirals(Nth + 1, To, Last);
   add_spirals(_, _, _) -> 0.
   ```
   Рекурсивная функция суммирует угловые элементы на спиралях (Nth и To – номера спиралей). На вход sum_diagonals передается размер сетки (исходя из задачи предполагается, что он должен быть нечетным)
2. __Модульная реализация__
   ```erlang
   -module(nsd_modular).
   -author("hrami").
   
   %% API
   -export([sum_diagonals/1]).
   
   sum_diagonals(1) -> 1;
   sum_diagonals(N) when N > 2, N rem 2 /= 0 ->
     Seq = generate_seq(1, N div 2 + 1, []),
     fold_seq(Seq).
   
   
   generate_seq(1, To, _) -> generate_seq(2, To, [1]);
   generate_seq(Nth, To, Seq) when Nth > 1, To >= Nth ->
     [CurrentNumber|_] = Seq,
     Quad = [CurrentNumber + Next * 2 * (Nth - 1) || Next <- [1, 2, 3, 4]],
     Ordered = lists:reverse(Quad),
     generate_seq(Nth + 1, To, Ordered ++ Seq);
   generate_seq(_, _, List) -> List.
   
   
   fold_seq(Seq) -> lists:sum(Seq).
   ```
   
   Генерируется последовательность чисел, которые должны быть задействованы, и далее список суммируется
3. __Модульная реализация с применением отображения (map)__
   ```erlang
   -module(nsd_modular_with_map).
   -author("hrami").
   
   %% API
   -export([sum_diagonals/1]).
   
   sum_diagonals(1) -> 1;
   sum_diagonals(N) when N > 2, N rem 2 /= 0 ->
     Seq = lists:seq(2, N div 2 + 1),
     Quads = map_seq(Seq),
     CornerSeq = [1 | lists:flatten(Quads)],
     fold_seq(CornerSeq).
   
   
   map_seq(Seq) ->
     {Mapped, _} = lists:mapfoldl(
       fun(X, Last) ->
         Quad = generate_quad(X, Last),
         [LastElem | _] = lists:reverse(Quad),
         {Quad, LastElem}
       end,
       1,
       Seq
     ),
     Mapped.
   
   generate_quad(Nth, Last) when Nth > 1 ->
     [Last + Next * 2 * (Nth - 1) || Next <- [1, 2, 3, 4]].
   
   fold_seq(Seq) -> lists:sum(Seq).
   ```
   Генерируется последовательность 2,3,4,5…; по которой далее генерируется новая, необходимая для задачи последовательность
4. __Модульная реализация с имитацией бесконечных списков с помощью Erlang процессов__
   ```erlang
   -module(nsd_modular_infinite_loop).
   -author("hrami").
   
   %% API
   -export([sum_diagonals/1]).
   
   sum_diagonals(1) -> 1;
   sum_diagonals(N) when N > 2, N rem 2 /= 0 ->
     Quads = take_quads(N div 2),
     CornerSeq = [1 | lists:flatten(Quads)],
     fold_seq(CornerSeq).
   
   take_quads(Count) ->
     ProducerPid = spawn(fun producer/0),
     ProducerPid ! {self(), Count},
     take_next_quad(Count, []).
   
   take_next_quad(Count, QuadList) when Count > 0 ->
     receive
       [N1, N2, N3, N4] -> take_next_quad(Count - 1, [N4, N3, N2, N1 | QuadList])
     end;
   take_next_quad(_, QuadList) -> QuadList.
   
   
   producer() ->
     receive
       {Sender, Count} -> gen_quads(Sender, Count, 1)
     end.
   
   
   gen_quads(SenderPid, Count, CurrentNumber) ->
     next_quad(SenderPid, 1, Count, CurrentNumber).
   
   next_quad(SenderPid, Nth, Count, CurrentNumber) when Count > 0 ->
     Quad = [CurrentNumber + Next * 2 * Nth || Next <- [1, 2, 3, 4]],
     SenderPid ! Quad,
     [Last|_] = lists:reverse(Quad),
     next_quad(SenderPid, Nth + 1, Count - 1, Last);
   next_quad(_, _, _, _) -> ok.
   
   fold_seq(Seq) -> lists:sum(Seq).
   ```

   Процессор producer() отправляет список элементов по углам каждой спирали, при этом и получатель,
   и отправитель знают, сколько должно быть отправлено списков
5. __Реализация на языке Go__
   ```go
   func sumDiagonals(n int) int {
       if n % 2 == 0 {
           panic("n must be odd")
       }
   
       if n < 1 {
           panic("n must be greater than 0")
       }
   
       spiralsNumber := n / 2 + 1
   
       sum := 1
       last := 1
       for i := 1; i < spiralsNumber; i++ {
           for j := 1; j < 5; j++ {
               last += 2*i
               sum += last
           }
       }
       return sum
   }
   ```
