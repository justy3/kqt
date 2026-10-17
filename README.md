embedpy -> python inside q/kdb
pykx -> q kdb inside python

scan/over
scan - 
(+\) 1 2 3  -> 1 3 6
scan[+; 1 2 3]

over - 
(+/) 1 2 3 -> 6
over[+; 1 2 3]

An accumulator is an iterator that takes an [applicable value/function] as argument and derives a function that evaluates the value, first on its entire (first) argument, then on the results of successive evaluations.

scan - gives value at each evaluation
over - only last result

sliding window - (n#0){1_x,y}\til 9


XBAR - xbar[x;y]
rounds y down to x

LOAD CSV 
0: operator
t:("SFI";enlist",") 0: `:path/to/example.csv

CUT
2 4 9 cut til[10]  
for this look at the left arg right to left. first make a cut at 9, left with 1 item (,9) then for remaining 9 cut at 4 then left with 5 elements. then for list of 4, a cut with 2 leaves 2 elements

MATCH ~
same dimension, value, type
dont need to have same attributes e.g. 1 2 3~`s#1 2 3


DICTIONARY:
-> stored as key value pair list
-> keys dont have to be unique q)(`Beeblebrox; `Beeblebrox; `Ford`Prefect)! 100 42 43 (first value during lookup)

FUNCTION
valence - no of input paramters (also called rank)
nullary function - 0 valence
max valence - 8, if more than 8 inputs required, use list or dict
a nullary function with no or arbitrary argument still works - 
const42:{[] 42}
const42[]
const42[98.6]

anonymous function - lambda expression

:: - null, identity function
difference with python - 
A local variable is not visible within the body of a local function defined in the same scope. Otherwise put,
q does not have lexical scoping.
projection - partial application of a function awaiting remaining argument

- map - both function and dictionary behave as map
- atomif function - The application of an atomic function is characterized by the fact that it recurses into an argument’s structure until it gets to atoms and then applies there. 

BENEFITS OF ENUMERATION
- saves storage (reference to symbol tho already interned takes 8 bytes but enumeration would take 2 to 4 bytes depending on no of unique symbols)
- cache benefits
- comparisons become faster - helpful in joins