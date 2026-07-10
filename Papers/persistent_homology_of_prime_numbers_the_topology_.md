# Computational Evidence — Persistent Homology of the Prime Point Cloud

## Setup

Place the `n`-th prime `p_n` at position `p_n` on the real line and run the
Vietoris–Rips filtration: join `p_m, p_n` whenever `|p_m − p_n| ≤ ε`.  On a line
the zero-dimensional barcode is governed entirely by the consecutive gaps
`g_n = p_{n+1} − p_n`.

## Small-case calculation of the gap sequence

Primes: `2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47`.

Consecutive gaps `g_n = p_{n+1} − p_n`:

```
n :   0  1  2  3  4  5  6  7  8  9 10 11 12 13
p_n:  2  3  5  7 11 13 17 19 23 29 31 37 41 43
g_n:  1  2  2  4  2  4  2  4  6  2  6  4  2  4
```

The finite `H_0` barcode of the first 15 primes therefore has death scales equal
to the multiset `{1, 2, 2, 4, 2, 4, 2, 4, 6, 2, 6, 4, 2, 4}` (plus one infinite
bar for the ever-present global component).  This confirms the central claim
`adjacent_component_iff`: the `n`-th finite bar dies exactly at `g_n`.

## Number of components as a function of scale

At scale `ε` the number of connected components of the first `m+1` primes equals
`1 + #{ n < m : g_n > ε }`.  For the 15 primes above:

```
ε = 0 : 15 components   (nothing merged)
ε = 1 : 14 components   (only the 2–3 gap of length 1 has merged)
ε = 2 :  8 components   (all gaps of length ≤ 2 merged; 7 gaps exceed 2)
ε = 4 :  3 components   (only the two gaps of length 6 survive)
ε = 6 :  1 component    (everything merged)
```

The step-points are exactly the distinct gap values `{1, 2, 4, 6}`, matching
`line_component_iff`.

## The twin prime bar

Gap `g_n = 2` occurs at `n = 1, 2, 4, 6, 9, 12, …`, giving the twin pairs
`(3,5), (5,7), (11,13), (17,19), (29,31), (41,43), …`.  Each such `n` is an
`H_0` bar of death scale exactly `2`.  The twin prime conjecture is precisely the
statement that this length-`2` bar recurs infinitely often
(`twinPrime_iff_infinitely_many_gap_two`).

## OEIS

- Prime gaps `g_n = p_{n+1} − p_n`: **A001223** (`1, 2, 2, 4, 2, 4, 2, 4, 6, 2, …`).
- Twin primes: **A001359** (lesser of twin prime pairs `3, 5, 11, 17, 29, 41, …`).

## Counterexample hunt

The claims are equivalences over honest sets, so no counterexample is expected.
The single-linkage characterisation was stress-tested on scrambled index orders
(the `min/max` covering argument), and the gap/twin identifications were checked
against the tables above; no discrepancy was found.
