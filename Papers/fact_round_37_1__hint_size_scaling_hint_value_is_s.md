# Computational Evidence — HINT-SIZE-SCALING (FACT round 37 #1, exp 464)

All quantities in bits. "Exact" values are the Dirichlet–Chebotarev population values: factor
residues uniform on the unit group mod `m*`, and Frobenius uniform given the residue dial. The
same values are proved in Lean (`Catalog/Logic/HintSizeScalingInstances.lean`). The plug-in
replications below come from ad-hoc Python scripts and are **not** formally checked.

## 1. Small cases: exact enumeration of the dial boxes

| dial | box | label | I(L; pair) | I(L; N) | hint (exact) | Lean theorem |
|---|---|---|---|---|---|---|
| S3@31 (`x³+x+1`) | (±1)² × Fin3² = 36 points (8100-point residue box gives the same value) | unordered root counts | 3/2 | 1 | **1/2** | `s3_hint_exact` |
| D4@8 (`x⁴−2`) | (ℤ/8)ˣ² × Fin2² = 64 | unordered root counts | 9/2 − (5/4)log₂5 = 1.59759 | 0.54336 | **3/2 − (9/32)log₂3 = 1.054229** | `d4_hint_exact` |
| C3@7 | (ℤ/7)ˣ² = 36 | unordered residue degrees | H(L) = 1.39215 | 0.47385 | **log₂3 − 2/3 = 0.918296** | `c3_hint_exact` |
| C5@11 | (ℤ/11)ˣ² = 100 | unordered residue degrees | H(L) | — | **log₂5 − (12/25)log₂3 − 16/25 = 0.921146** | `c5_hint_exact` |

Fibre-count multisets used in the proofs (computed with Python, then checked by the Lean kernel
using `decide`):

* S3: L `[1,4,4,6,9,12]`, (L,pair) `[1,3,3,4,4,6,6,9]`, (L,N) `[1,4,4,6,9,12]`.
* D4: L `[1,4,4,10,20,25]`, (L,pair) `[1,1,2×13,4×9]`, (L,N) `[1,2,4×7,8,8,8,9]`.
* C3: (L,N) `[2×6, 4×6]`; C5: (L,N) `[2,2,4×8,6×8,8,8]`.

Residuals `H(L | p mod m*, q mod m*)`: S3 `log₂3 − 7/9 = 0.8072`, D4 `15/32 = 0.46875`, C3 `0`,
C5 `0` (Lean: `s3_residual`, `d4_residual`, `cyc_residual_zero`).

**Which label encoding fits D4@8?** With cycle-type labels the D4 box gives a hint of 1.193599,
which does not match the report. With root-count labels it gives 1.054229, which matches the
reported 1.0540/1.0536/1.0507. So the D4@8 battery uses root counts of `x⁴ − 2`.

## 2. Comparison with the reported table

| dial | k=14 | k=18 | k=22 | exact | max relative deviation |
|---|---|---|---|---|---|
| S3@31 | 0.5584 | 0.5425 | 0.5415 | 0.5 | +11.7% (systematic upward bias) |
| C3@7 | 0.9115 | 0.9140 | 0.9169 | 0.91830 | 0.74% |
| D4@8 | 1.0540 | 1.0536 | 1.0507 | 1.05423 | 0.33% |
| C5@11 | 0.9030 | 0.9190 | 0.9268 | 0.92115 | 1.97% |

**S3 bias check (not formally verified).** Three seeded plug-in replications of the ideal
law at mod 31 with n = 15000 gave 0.5532, 0.5453 and 0.5520. The Miller–Madow first-order bias
is `(#joint cells − #view cells − #labels + 1)/(2n ln 2)`. For the pair view this is
(1800 − 900 − 6 + 1)/20794 ≈ 0.0430; for the N view it is (90 − 30 − 6 + 1)/20794 ≈ 0.0026.
That predicts a reading of ≈ 0.5404. So the reported S3 "plateau ≈ 0.54" is the exact value 1/2
plus estimator bias. It is size-stable, but it does not equal the population value.

## 3. Pool-floor hunt

One prime per residue class mod 31: five quadratic-residue classes split completely, ten are
inert, and the fifteen non-residue classes are transpositions. Across six type assignments the
hint is 1.2805, 1.2725, 1.2816, 1.2779, 1.2871 and 1.2825. The theoretical ceiling
`H(L|N) = log₂3 − 5/18 = 1.3070` is reached exactly when the pool's own type proportions are
used (Lean: `hint_eq_condEnt_of_injective`, `s3_pool_ceiling`). The reported k = 10 value
0.7423 (2.5 primes per class) lies strictly inside the window (1/2, 1.3070)
(`s3_pool_floor_window`).

## 4. Counterexample hunt

* Which-factor wall: no counterexample can exist (Lean: `which_factor_wall`).
* Naive unconditional instrument: on the 2-sample battery {(2,3),(3,2)}, `I(O; p mod 5) = 1`
  while the conditional statistic is 0 (`naive_instrument_fails`). This is a concrete
  violation of the *unconditional* version.
* Dial laws: kernel-checked on all primes below 200 (`s3_rootCount_check`,
  `d4_rootCount_check`). No exceptions.

## 5. OEIS

Not applicable: no integer sequence is involved.
