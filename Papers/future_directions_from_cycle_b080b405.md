# Computational evidence — adjacent-sum polytopes, cycle 1

All numbers below were computed exactly (integer/rational arithmetic) before the
corresponding Lean formalisation was attempted.  Data marked **[Lean-verified]** is also
proved in `Catalog/Applications/AdjacentSumPolytopes/`; data marked **[numeric only]**
is floating-point evidence for a conjecture and is *not* machine-verified.

## 1. The counting sequences

`adjMat s` is the `(s+1) × (s+1)` transfer matrix with `(a,b)` entry `1` iff `a + b ≤ s`.

* Cyclic counts `tr(adjMat s ^ n)`, `n = 1..8`  **[Lean-verified as trace/count identity]**

  | s | sequence |
  |---|----------|
  | 1 | 1, 3, 4, 7, 11, 18, 29, 47  (Lucas) |
  | 2 | 2, 6, 11, 26, 57, 129, 289, 650 |
  | 3 | 2, 10, 23, 70, 197, 571, 1640, 4726 |

* Open counts (sum of all entries of `adjMat s ^ d`), `d = 0..7`

  | s | sequence |
  |---|----------|
  | 1 | 2, 3, 5, 8, 13, 21, 34, 55  (`F(d+3)`) |
  | 2 | 3, 6, 14, 31, 70, 157, 353, 793 |
  | 3 | 4, 10, 30, 85, 246, 707, 2037, 5864 |
  | 4 | 5, 15, 55, 190, 671, 2353 |

  The two-state identifications `#cyclic(d) = F(d+2)+F(d)` and `#open(d) = F(d+3)` are
  proved in `Growth.lean`.  No internet or OEIS lookup was available in this environment,
  so no OEIS identifiers are claimed.

## 2. Characteristic polynomials

Computed exactly by Faddeev–LeVerrier over ℚ (coefficients of `det(xI − adjMat s)`,
highest degree first):

```
s = 1 : 1, -1, -1
s = 2 : 1, -2, -1,  1
s = 3 : 1, -2, -3,  1,  1
s = 4 : 1, -3, -3,  4,  1, -1
s = 5 : 1, -3, -6,  4,  5, -1, -1
s = 6 : 1, -4, -6, 10,  5, -6, -1,  1
s = 7 : 1, -4,-10, 10, 15, -6, -7,  1,  1
s = 8 : 1, -5,-10, 20, 15,-21, -7,  8,  1, -1
s = 9 : 1, -5,-15, 20, 35,-21,-28,  8,  9, -1, -1
s =10 : 1, -6,-15, 35, 35,-56,-28, 36,  9,-10, -1,  1
```

The `s = 2` polynomial `x³ − 2x² − x + 1` is **[Lean-verified]** (`ThreeState.lean`), and
the shared order-`(s+2)` recurrence it induces for *both* parity classes is verified on
the data: `31 = 2·14 + 6 − 3`, `70 = 2·31 + 14 − 6` (open) and `26 = 2·11 + 6 − 2`,
`57 = 2·26 + 11 − 6` (cyclic).

Magnitudes look binomial and the signs run in a period-four pattern `+, −, −, +`; no
closed form is claimed.

## 3. Spectral conjecture (secant family)  **[numeric only]**

Evaluating the exact characteristic polynomial at the candidate values
`ε / (2 cos((2j−1)π/(2s+3)))`, `j = 1..s+1`:

| s | residuals at `ε = +1` | residuals at `ε = −1` |
|---|---|---|
| 1 | 1.2, 3.2 | 1e−16, 1e−15 |
| 2 | 0, 2e−15, 2e−16 | 0.77, 18, 0.57 |
| 3 | 0.46, 2.0, 90 | 2e−16, 7e−16, 1e−14 |
| 4 | 0, 4e−16, 1e−13 | 0.27, 0.63, 817 |
| 5 | 0.16, 0.25, 14 | 0, 1e−16, 9e−12 |
| 6 | 1e−16, 0, 7e−12 | 0.09, 0.11, 8.6e4 |
| 7 | 0.05, 0.05, 1e6 | 0, 1e−16, 9e−10 |

So the spectrum is the secant family with the parity-dependent sign `ε = (−1)^s`:

`spec(adjMat s) = { (−1)^s / (2 cos((2j−1)π/(2s+3))) : j = 1, …, s+1 }`.

The case `s = 1` is **[Lean-verified]** in `Spectral.lean`
(`−1/(2 cos 3π/5) = φ`, `−1/(2 cos π/5) = ψ`, and the resulting trigonometric closed
forms for both parity classes).  Consequences (numeric only): the dominant pole is
`λ_s = (−1)^s/(2 cos(m_s π/(2s+3)))` with `m_s` the odd (resp. even) integer nearest to
`(2s+3)/2`, giving `λ_s ≈ (2s+3)/π`; e.g. `λ_2 ≈ 2.2470` vs `7/π ≈ 2.228`,
`λ_3 ≈ 2.87` vs `9/π ≈ 2.865`.

## 4. Gauss congruence data

Möbius transforms `primCyc s n = ∑_{d|n} μ(n/d) tr(Mⁿ)` for `s = 2` from the trace
sequence `2, 6, 11, 26, 57, 129, 289`:

```
primCyc 1 = 2       1 ∣ 2
primCyc 2 = 4       2 ∣ 4
primCyc 3 = 9       3 ∣ 9
primCyc 4 = 20      4 ∣ 20
primCyc 5 = 55      5 ∣ 55
primCyc 6 = 114     6 ∣ 114 = 6·19
```

The composite cases (`4`, `6`) are exactly the ones the prime-only fixed-point argument
of the previous cycle could not reach; the divisibility for **all** `n` is now
**[Lean-verified]** in `GaussCongruence.lean` (`gauss_congruence`), together with the
combinatorial meaning `primCyc s n = #{aperiodic cyclic words of length n}`.

## 5. Exact-period decomposition (`s = 2`, length 4)

`tr(M⁴) = 26 = 2 + 4 + 20`, the summands being the words of exact period `1`, `2`, `4`
(`2 = tr M`, `4 = tr(M²) − tr(M)`, `20 = tr(M⁴) − tr(M²)`), each divisible by its period.
This is the numerical shadow of `card_eq_sum_divisors_card_minimalPeriod` together with
`dvd_card_minimalPeriod_eq` (`Periodicity.lean`).

---

# Cycle 2 addendum

Status update on the earlier sections: the secant spectrum of §3, listed there as
**[numeric only]**, is now **[Lean-verified]** for *every* `s` in `SecantSpectrum.lean`
(eigenvectors, diagonalisation, `charpoly = ∏_t (X − λ_t)` and the trace formula), with
the eigenvalues written in the equivalent cosecant form
`λ_t = (−1)^t / (2 sin((2t+1)π/(2(2s+3))))`.  The data below is new to this cycle.

## 6. The characteristic polynomial is a binomial staircase  **[numeric only]**

Exact Faddeev–LeVerrier over ℚ gives, for the coefficient of `x^{s+1−m}` in
`det(x I − adjMat s)`, agreement with

`(−1)^{⌊(m+1)/2⌋} · C(⌊(s+1+m)/2⌋, m)`

for **every** `s ≤ 11` and every `m`, coefficient by coefficient (exact integer equality,
not a numerical fit).  Examples:

```
s =  4 : 1, -3, -3,  4,  1, -1
s =  9 : 1, -5,-15, 20, 35,-21,-28,  8,  9, -1, -1
s = 11 : 1, -6,-21, 35, 70,-56,-84, 36, 45,-10,-11,  1,  1
```

The `m = 0, 1, 2` cases are **[Lean-verified]**: `1`, `−tr(A) = −(⌊s/2⌋+1)`
(`Necklace.trace_adjMat`), and `e₂ = −C(⌊(s+3)/2⌋, 2)` (`TraceMoments.trace_sq_newton`
together with `TraceMoments.trace_adjMat_sq : tr(A²) = C(s+2,2)`).  This is Conjecture 1 of
`FUTURE_DIRECTIONS.md`.

## 7. Principal minors of the staircase matrix  **[numeric only]**

Brute-force enumeration of *all* principal minors for `s ≤ 6`: every minor is `0` or `±1`,
all nonzero minors of a given size share one sign, and the number of nonzero `m × m`
principal minors is

| s \ m | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|---|
| 2 | 1 | 2 | 1 | 1 | | | | |
| 3 | 1 | 2 | 3 | 1 | 1 | | | |
| 4 | 1 | 3 | 3 | 4 | 1 | 1 | | |
| 5 | 1 | 3 | 6 | 4 | 5 | 1 | 1 | |
| 6 | 1 | 4 | 6 |10 | 5 | 6 | 1 | 1 |

which is exactly `C(⌊(s+1+m)/2⌋, m)`.  Also `det(adjMat s) = (−1)^{⌊(s+1)/2⌋}` for
`s ≤ 9` (`1, −1, −1, 1, 1, −1, −1, 1, 1, −1`); the determinant formula is now
**[Lean-verified]** for every `s` (`Determinant.det_adjMatZ`), the minor count remains
sub-conjecture (S1).

## 8. Aperiodic densities  **[Lean-verified as a limit]**

For `s = 1` the trace counts `tr(Mⁿ) = 1, 3, 4, 7, 11, 18, 29, 47, 76, 123` (Lucas) split
into aperiodic counts `aperN(n) = 1, 2, 3, 4, 10, 12, 28, 40, 72, 110` with ratios

```
1.000, 0.667, 0.750, 0.571, 0.909, 0.667, 0.966, 0.851, 0.947, 0.894
```

The dips are at highly composite `n`, matching the proved error bound
`tr(Mⁿ) − aperN(n) ≤ n (s+1)^{⌊n/2⌋}`.  The limit `aperN(n)/tr(Mⁿ) → 1` is
**[Lean-verified]** for every `s ≥ 1` (`AperiodicDensity.tendsto_aperN_div_traceCount`),
and the boundary case `s = 0` (density `0`) is proved as well.

## 9. The subdominant modulus  **[Lean-verified]**

```
s        : 1        2        3        4        5        6
|λ₁|     : 0.618034 0.801938 1.000000 1.203616 1.410020 1.618034
λ₀       : 1.618034 2.246980 2.879385 3.513337 4.148115 4.783386
```

`|λ₁|` crosses `1` exactly at `s = 3`, where `λ₁ = −1` on the nose (and indeed
`det(I + adjMat 3) = 0`).  The previous cycle's Conjecture 5 claim that `|λ₁| < 1` for all
`s ≥ 2` is therefore false; the corrected trichotomy is proved in `SubdominantModulus.lean`.

## 10. The arctangent series  **[Lean-verified]**

Open counts of odd dimension, `#open(1, 2i) = 2, 5, 13, 34, 89, 233`, and the partial sums
of `arctan(1/·)`:

```
0.463648, 0.661043, 0.737815, 0.767218, 0.778454, 0.782746 → π/4 = 0.785398
```

with error exactly `arctan(1/F(2N+2))`, as proved in `Arctangent.sum_arctan_fib_eq`.

---

# Addendum — cycle 2 (inverse transfer matrix, squared charpoly, binomial staircase)

All tables below were computed in exact integer/rational arithmetic (Faddeev–LeVerrier over
`Fraction`) before formalisation.

## 11. Characteristic polynomials of `adjMat s`  **[Lean-verified]**

Coefficient rows, from `x^{s+1}` down to the constant term:

```
s = 0 :  1, -1
s = 1 :  1, -1, -1
s = 2 :  1, -2, -1,  1
s = 3 :  1, -2, -3,  1,  1
s = 4 :  1, -3, -3,  4,  1, -1
s = 5 :  1, -3, -6,  4,  5, -1, -1
s = 6 :  1, -4, -6, 10,  5, -6, -1,  1
s = 7 :  1, -4,-10, 10, 15, -6, -7,  1,  1
s = 8 :  1, -5,-10, 20, 15,-21, -7,  8,  1, -1
```

Entry `m` of row `s` equals `(−1)^{⌊(m+1)/2⌋} · C(⌊(s+1+m)/2⌋, m)` in every case checked
(`s ≤ 11`).  This is now a **theorem**, `AdjSum.charpoly_coeff_adjMatZ` in
`BinomialStaircase.lean`, so the table is Lean-verified rather than merely suggestive.

## 12. The squared transfer matrix  **[Lean-verified]**

`charpoly(A²)` coefficients `(−1)^k C(s+1+k, 2k)` for `s ≤ 6`, checked coefficient by
coefficient against the exact Faddeev–LeVerrier output; proved as
`AdjSum.charpoly_adjMatZ_sq_coeff` in `LaplacianCharpoly.lean`.  The matrix `A^{-2}` is the
path Laplacian with one Dirichlet and one Neumann end (`AdjSum.invAdjMatZ_sq`), whose
characteristic polynomial is the tridiagonal continuant `lapPoly`.

## 13. Rational-root and quadratic-factor test for the cyclotomic factorisation
**[numeric only]**

`P_s(1)` and `P_s(−1)`, `s = 0..12` (exact integers):

```
s      :  0   1   2   3   4   5   6   7   8   9  10  11  12
2s+3   :  3   5   7   9  11  13  15  17  19  21  23  25  27
P_s(1) :  0  -1  -1  -2  -1  -1   0   1   1   2   1   1   0
P_s(-1): -2   1  -1   0   1  -1   2  -1   1   0  -1   1  -2
```

A linear factor occurs exactly at `s = 0, 3, 6, 9, 12`, i.e. exactly when `3 ∣ 2s+3`.
Similarly `x² − x − 1` or `x² + x − 1` divides `P_s` exactly at `s = 1, 6, 11`, i.e. exactly
when `5 ∣ 2s+3`.  Both patterns match the conjectured factorisation
`P_s = ∏_{d ∣ 2s+3, d > 1} Ψ_d` with `deg Ψ_d = φ(d)/2` (Conjecture C2 of
`FUTURE_DIRECTIONS.md`).  This is numeric evidence only; no factorisation statement is
formalised.
