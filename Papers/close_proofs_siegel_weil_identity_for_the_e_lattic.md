# Computational Evidence — Contrarian conjectures for the E₈ / Siegel–Weil σ₃ system

All computations below were run in Lean 4 with Mathlib (`ArithmeticFunction.sigma`).
Here `σ₃ = sigma 3`, `σ₁ = sigma 1`, `σ₇ = sigma 7`, and the E₈ representation
number is `rE8 n = 240·σ₃(n)`.

## 1. Congruence `σ₃(n) ≡ σ₁(n) (mod 6)`  — CONJECTURED TRUE

`(σ₃(n) mod 6, σ₁(n) mod 6)` for `n = 0..19`:

```
(0,0) (1,1) (3,3) (4,4) (1,1) (0,0) (0,0) (2,2) (3,3) (1,1)
(0,0) (0,0) (4,4) (2,2) (0,0) (0,0) (1,1) (0,0) (3,3) (2,2)
```

Perfect agreement. Reason: `d³ ≡ d (mod 6)` for every `d` (since
`d³ − d = (d−1)d(d+1)` is a product of three consecutive integers),
so summing over the divisors gives `σ₃(n) ≡ σ₁(n) (mod 6)`.

## 2. `rE8` is NOT multiplicative — DISPROOF

`rE8(6) = 60480` but `rE8(2)·rE8(3) = 2160·6720 = 14515200`. Not equal.
The correct law carries a factor `240`: `240·rE8(mn) = rE8(m)·rE8(n)` for
coprime `m, n` (already in `SiegelWeilE8Theta.lean`).

## 3. Hecke three-term recurrence fails at a composite base — DISPROOF

For `p = 6` (composite), `r = 0`:
`σ₃(6²) + 6³·σ₃(1) = 55477` but `σ₃(6)·σ₃(6) = 63504`. Not equal.
Primality of `p` is essential to the recurrence `σ₃(p^{r+2}) + p³σ₃(pʳ) = σ₃(p)σ₃(p^{r+1})`.

## 4. Lower bound and prime characterization — CONJECTURED TRUE

For `n ≥ 2`, `σ₃(n) ≥ n³ + 1`, with equality **iff `n` is prime**:

```
n :  2   3   4   5   6   7   8   9  10  11
σ₃: 9  28  73 126 252 344 585 757 ...
n³+1: 9  28  65 126 217 344 513 730 ...
eq?  T   T   F   T   F   T   F   F  ...
prime? T T F T F T F F ...
```

Equality exactly on the primes `2,3,5,7,11,13`.

## 5. Flagship: `E₄² = E₈` coefficient identity — CONJECTURED TRUE (deep)

`σ₇(n) = σ₃(n) + 120·∑_{m=1}^{n-1} σ₃(m)·σ₃(n−m)`:

```
n :        1     2      3       4        5        6        7
σ₇(n):     1   129   2188   16513    78126   282252   823544
RHS   :    1   129   2188   16513    78126   282252   823544
```

Exact agreement — this is the arithmetic shadow of the fact that the space of
weight-8 modular forms for `SL₂(ℤ)` is one-dimensional (`E₄² = E₈`). Recorded in
`FUTURE_DIRECTIONS.md` as an open target; an elementary proof requires the
Lambert-series/modular-forms machinery not yet available at this coefficient level.

## 6. Diagonal Hecke identity — CONJECTURED TRUE

`σ₃(n)² = ∑_{d ∣ n} d³·σ₃(n²/d²)` (the `m = n` case of the global Hecke identity):

```
n :   1    2     3      4       5       6        7
σ₃²:  1   81   784   5329   15876   63504   118336
RHS:  1   81   784   5329   15876   63504   118336
```
