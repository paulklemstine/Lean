# Computational Evidence — Proof Automation IV (Fibonacci tactics)

All evidence below was produced inside Lean with `#eval` (exact integer / `ℕ`
arithmetic, no floating point). The corresponding statements are then *proved*
(0 sorries) in `Catalog/Applications/ProofAutomation/FibonacciTactics.lean`.

## 1. Two-term basis principle (engine)

`fib (n+k)` is a fixed `ℕ`-linear combination of `fib n` and `fib (n+1)`:

| shift k | fib(n+k) = a·fib n + b·fib(n+1) | (a,b) |
|---|---|---|
| 5 | `3 fib n + 5 fib(n+1)` | (3,5) |
| 6 | `5 fib n + 8 fib(n+1)` | (5,8) |
| 7 | `8 fib n + 13 fib(n+1)` | (8,13) |

The coefficients are themselves Fibonacci numbers `(F_{k-1}, F_k)`, matching
`fib_two_basis`.  `fib_ring` discovers them automatically through `ring`.

## 2. Cassini  `fib(n+2)·fib n − fib(n+1)^2 = (−1)^(n+1)`

`#eval` of the LHS for `n = 0..7`:
```
[-1, 1, -1, 1, -1, 1, -1, 1]   =  (−1)^(n+1)
```

## 3. d'Ocagne (k = 3)  `fib(n+3)fib(n+1) − fib(n+4)fib n = (−1)^n · fib 3`

`fib 3 = 2`; `#eval` of the LHS for `n = 0..5`:
```
[2, -2, 2, -2, 2, -2]   =  2·(−1)^n
```

## 4. Catalan (r = 2)  `fib(n+2)^2 − fib n · fib(n+4) = (−1)^n · fib 2 ^2`

`fib 2 = 1`; `#eval` of the LHS for `n = 0..5`:
```
[1, -1, 1, -1, 1, -1]   =  (−1)^n
```

## 5. Doubling (odd)  `fib(2n+1) = fib(n+1)^2 + fib n^2`

`(LHS, RHS)` for `n = 0..5`:
```
[(1,1), (2,2), (5,5), (13,13), (34,34), (89,89)]
```

## 6. Partial sums

`∑_{i<n} fib i` vs `fib(n+1) − 1` for `n = 0..7`:
```
[0,0,1,2,4,7,12,20]   ==   [0,0,1,2,4,7,12,20]
```

`∑_{i≤n} fib i^2` vs `fib n · fib(n+1)` for `n = 0..5`:
```
[(0,0),(1,1),(2,2),(6,6),(15,15),(40,40)]
```

## OEIS pointers
- Fibonacci `fib`: A000045.
- Coefficient pairs in the two-term basis are consecutive A000045 terms.

## Counterexample hunt
A draft "mixed" identity `fib(n+3)·fib(n+1) = fib(n+2)^2 + fib n·fib(n+2)` was
tested and **falsified** at `n = 1`:  LHS `= fib 4 · fib 2 = 3·1 = 3`, while
RHS `= fib 3 ^2 + fib 1 · fib 3 = 4 + 2 = 6`.  It was discarded and replaced by the
verified `fib(n+2)^2 = fib(n+1)^2 + fib n·fib(n+3)` (`fib_mixed_shift`).  See the
Lab Notes inside the Lean file for the full failure analysis.
