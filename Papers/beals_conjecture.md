# Computational Evidence: Beal-Type Equations

## Small-case calculations

The search enumerated positive bases `A,B,C ≤ 40` and exponents
`3 ≤ x,y,z ≤ 6`, testing the exact integer equality

`A^x + B^y = C^z`.

The exploratory calculation reported 23 ordered solutions and no solution with
`gcd(A,B,C)=1`. This finite search is reported as computational evidence rather
than as an independently certified theorem. Representative rows are:

| A | B | C | x | y | z | gcd(A,B,C) |
|---:|---:|---:|---:|---:|---:|---:|
| 2 | 2 | 2 | 3 | 3 | 4 | 2 |
| 2 | 2 | 4 | 5 | 5 | 3 | 2 |
| 7 | 7 | 14 | 3 | 4 | 3 | 7 |
| 3 | 18 | 9 | 6 | 3 | 4 | 3 |
| 8 | 32 | 16 | 5 | 3 | 4 | 8 |
| 17 | 34 | 17 | 4 | 4 | 5 | 17 |

The complete search also contains the solutions obtained by interchanging the
first two powered terms when their exponents are interchanged.

## Counterexample hunt

No primitive counterexample occurred in this finite box.  This agrees with the
conjecture but cannot establish it.  The unconditional structural theorem proved
in the accompanying chapter explains a stronger local pattern: in any exact
solution with positive exponents, a prime dividing any two bases necessarily
divides all three.

## Sequence-database search

The output is a sparse collection of six-parameter tuples rather than a canonical
one-dimensional integer sequence, so no OEIS identifier was assigned.  Projecting
the tuples to one coordinate would discard the exponent signature and would not
provide reliable evidence about the conjecture.

## Table interpretation

Every displayed equality can be checked directly by exact integer arithmetic.
The count of 23 and the exhaustion of the stated box come from the exploratory
search and are not independently certified in the accompanying theorem set. The
table is intended to expose the common-divisor pattern and to guide the structural
reduction; it is not presented as evidence for cases outside the stated bounds.
