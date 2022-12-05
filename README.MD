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
    ```
   Процесс __producer()__ отправляет последовательность чисел
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
   ```

   Процессор producer() отправляет список элементов по углам запрошенной спирали
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
