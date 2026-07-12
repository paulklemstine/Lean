# Computational Evidence: Counting Statements and the Enumeration Frontier

We model **statements** as finite binary strings and study the growth of the
statement space and the "discovery frontier" of an enumeration.

## 1. Small-case counts of the statement space

The number of binary strings of length exactly `n` is `2^n`, so the number of
statements of length **at most** `n` is `2^(n+1) - 1`:

| length bound n | # strings of length ≤ n |
|---------------:|------------------------:|
| 0              | 1                       |
| 1              | 3                       |
| 2              | 7                       |
| 3              | 15                      |
| 4              | 31                      |
| 5              | 63                      |
| 10             | 2047                    |

This is OEIS **A000225** (Mersenne numbers `2^n - 1`, here shifted). Each row is
finite — the content of `shortStatements_finite` — yet the running total grows
without bound, so the full space is infinite. Both facts are used in the formal
development.

## 2. The enumeration is a bijection ℕ ≃ statements

Because the alphabet is finite and nonempty, `List (Fin 2)` is countable and
infinite, hence *denumerable*: there is a bijection with `ℕ`. Concretely one may
list `[], [0], [1], [0,0], [0,1], [1,0], [1,1], [0,0,0], …`, i.e. shortlex
order, giving indices `0, 1, 2, 3, …`. Every string occurs exactly once, at a
finite index — the computational meaning of `statement_discoverable`.

## 3. Frontier / heat-death check

Fix a budget of `N` enumeration steps. The discovered set is
`{enum 0, …, enum (N-1)}`, of size at most `N`, hence finite. For any formal
system with infinitely many theorems the discovered set can never contain them
all: the counting `finite ⊄ infinite` is immediate.

Sample: with the "all statements" system and budget `N = 1000`, at most `1000`
strings are seen, but there are `2047` strings of length ≤ 10 alone — already
more than the budget. Increasing `N` only pushes the frontier out; it never
closes it. This is the computational shadow of
`heat_death_leaves_theorems_undiscovered` and
`undiscovered_theorems_infinite`.

## 4. Counterexample hunt

We tested the central claims for possible failure modes:

* *Could a clever enumeration cover an infinite theorem set in finitely many
  steps?* No: the image of a finite index set is finite, independent of the
  enumeration chosen. No counterexample exists.
* *Could the theorem set of an "infinitely-proving" system fail to be
  countable?* No: it is a subset of a countable space. No counterexample.
* *Is the framework vacuous?* No: `constantStatements` is an explicit infinite
  proper subsystem (`constantStatements_proper`).

No counterexamples were found; the computational landscape is fully consistent
with the formal results, so we proceeded to proof.
