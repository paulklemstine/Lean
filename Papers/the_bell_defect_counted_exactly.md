# Computational evidence (cycle 4: the Bell defect, graded by blocks)

All numbers below were produced with `#eval` inside the project (Lean 4.28.0, mathlib
`v4.28.0`), using the project's own definitions `stirling`, `bell` (from
`Catalog/Speculative/AutoResearch/FibreSpectrumRank.lean` and
`Catalog/Bridges/MoonshineBellTransitivityBridge.lean`).  They are exploratory data, not
verification: every claim that is asserted as a result is a `sorry`-free Lean theorem in
`Catalog/Combinatorics/BellDefect*.lean`.

## 1. The Stirling triangle, computed from patterns

`stirling k r` is *defined* as the number of restricted-growth patterns of `Fin k` with `r`
blocks.  Evaluating rows `k = 0 … 5`:

```
[[1],
 [0, 1],
 [0, 1, 1],
 [0, 1, 3, 1],
 [0, 1, 7, 6, 1],
 [0, 1, 15, 25, 10, 1]]
```

This is the Stirling triangle of the second kind, OEIS **A008277**, and the row sums

```
bell 0 … bell 6  =  1, 1, 2, 5, 15, 52, 203
```

are the Bell numbers, OEIS **A000110**.  The boundary values visible here (`S(k,0) = 0` for
`k ≥ 1`, `S(k,1) = S(k,k) = 1`, columns non-decreasing in `k`) are exactly what is proved in
`Catalog/Combinatorics/BellDefectBlockPatterns.lean` (`stirling_zero_right`, `stirling_one`,
`stirling_self`) and `Catalog/Combinatorics/BellDefectMonotone.lean`
(`stirling_le_stirling_of_le`).

## 2. Counterexample hunt for Conjecture F

Write `D_j = Σ_{r ≤ j} S(j,r)·(t_r − 1)` (the defect divided by `|G|`, by
`bellDefect_eq_spectrum`).  The admissible spectra are the monotone vectors
`1 = t_0 ≤ t_1 ≤ … ≤ t_k` (monotonicity is the theorem `injOrbits_monotone` of the previous
cycle).  Enumerating **all 35** monotone spectra with `k = 4` and `t_r ≤ 4`:

| tested claim | result |
|---|---|
| `(B_3 − 1)·D_2 ≤ 2·D_3` and `(B_4 − 1)·D_2 ≤ 2·D_4` | `true` (no counterexample) |
| `D_2 ≤ D_3 ≤ D_4` (defect monotonicity) | `true` (no counterexample) |

Both are now theorems (`bellDefect_two_propagation`, `bellDefect_mono`).

## 3. Locating the extremal spectrum (sharpening the constant)

For every spectrum with `D_2 > 0` the table of `(t, 2·D_4, (B_4 − 1)·D_2)` was computed.  The
smallest slack occurs on the **constant** spectra:

| spectrum `t = (t_0,…,t_4)` | `2·D_4` | `(B_4 − 1)·D_2 = 14·D_2` | `B_4·D_2 = 15·D_2` |
|---|---|---|---|
| `(1,1,2,2,2)` | 28 | 14 | 15 |
| `(1,1,4,4,4)` | 84 | 42 | 45 |
| `(1,2,2,2,2)` | 30 | 28 | 30 |
| `(1,3,3,3,3)` | 60 | 56 | 60 |
| `(1,4,4,4,4)` | 90 | 84 | 90 |

The last column shows equality `2·D_4 = B_4·D_2` exactly on the constant spectra
`t_1 = t_2 = t_3 = t_4`.  This suggested — and then we proved — the sharp constant

`B_k·D_2 ≤ 2·D_k`  (`bellDefect_two_propagation_sharp`),

with equality on constant spectra (`bellDefect_sharp_constant_attained`).  The earlier constant
`(B_k − 1)/2` is therefore not optimal, while `B_k/2` is optimal for the spectral relaxation.

## 4. The separating pair

For the cyclic group `C₄` of order 4:

| action | `Σ_g fix(g)` | `Σ_g fix(g)²` | `t_1` |
|---|---|---|---|
| regular action on itself | 4 | 16 | 1 |
| trivial action on a 2-element set | 8 | 16 | 2 |

Equal second moments, different spectra — the content of `single_moment_not_separating`.  The
first moments differ, as the moment–spectrum equivalence theorem forces
(`separating_pair_first_moments_differ`).

## 5. After the sharp constant: the extremal ray

The equality case `2·D_k = B_k·D_2` of the sharp bound requires `t_1 = t_2`.  The spectra of the
three small actions below were computed by hand (orbit counts on points and on ordered pairs of
distinct points); the defects are then read off from the spectral formula
`D_j = Σ_r S(j,r)(t_r − 1)`:

| action | `t_1` | `t_2` | `2·D_3 / D_2` |
|---|---|---|---|
| trivial group on 3 points | 3 | 6 | 44/7 ≈ 6.29 |
| `C₂` swapping two of three points | 2 | 3 | 18/3 = 6 |
| `S₃` on 3 points | 1 | 1 | `D_2 = 0` |

Every sample has ratio `> B_3 = 5`, and none has `t_1 = t_2 > 1`.  This suggested Conjecture H,
now proved: `t_1 = t_2` with `|X| ≥ 3` forces `t_1 = 1`
(`injOrbits_one_eq_one_of_eq_two`), so the extremal ray of the relaxation degenerates
(`bellDefect_two_eq_zero_of_constant_spectrum`), and the multiplicative bound
`t_1(t_1 − 1) ≤ t_2` (`sq_le_injOrbits_two_add`) is what rules out `t_1 ≥ 3`.
