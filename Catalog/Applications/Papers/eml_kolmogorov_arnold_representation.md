# Computational Evidence — EML Kolmogorov–Arnold Representation of the Product

Target: `f(x,y) = x·y` on `[0,1]²`, and the `n`-ary product `∏ xᵢ`.
EML functions = finite compositions of `exp, log, +, ×, const` (`EMLTerm`).

## 1. Small-case calculations

### Rank-one exp/log form  `x·y = exp(log x + log y)`
| x    | y    | log x      | log y      | exp(log x+log y) | x·y   |
|------|------|------------|------------|------------------|-------|
| 0.5  | 0.5  | -0.6931    | -0.6931    | 0.2500           | 0.25  |
| 0.2  | 0.8  | -1.6094    | -0.2231    | 0.1600           | 0.16  |
| 1.0  | 0.3  |  0.0000    | -1.2040    | 0.3000           | 0.30  |
| 0.0  | 1.0  | log 0 ⇒ 0 (junk) |  0.0000 | exp(0)=1.0000   | 0.00  |  ← MISMATCH

Confirms the formula on the open positive quadrant and the **boundary failure**
at `x=0`: Mathlib's junk value `Real.log 0 = 0` makes the EML term return `1`,
not `0`. Formalised as `expLog_fails_at_boundary`.

### Two-term polynomial (polarization) form  `x·y = ¼(x+y)² − ¼(x−y)²`
| x    | y    | ¼(x+y)² | ¼(x−y)² | difference | x·y  |
|------|------|---------|---------|------------|------|
| 0.0  | 1.0  | 0.2500  | 0.2500  | 0.0000     | 0.00 |  ← correct at boundary
| 0.5  | 0.5  | 0.2500  | 0.0000  | 0.2500     | 0.25 |
| -2.0 | 3.0  | 0.2500  | 6.2500  | -6.0000    | -6.0 |  ← valid off `[0,1]²` too

Confirms global validity (all `x,y ∈ ℝ`). Formalised as `mul_eq_polarization`.

### n-ary product  `∏ xᵢ = exp(∑ log xᵢ)`
| family            | ∑ log         | exp(∑ log) | ∏     |
|-------------------|---------------|------------|-------|
| {0.5, 0.5, 0.5}   | -2.0794       | 0.1250     | 0.125 |
| {0.2, 0.8, 1.0}   | -1.8326       | 0.1600     | 0.160 |
| {0.0, 1.0}        | junk(0)+0 = 0 | 1.0000     | 0.000 |  ← MISMATCH

Confirms `prod_eq_exp_sum_log` (positivity) and
`prod_exp_sum_log_fails_at_zero`.

## 2. OEIS

No integer sequence arises; the objects are real-analytic identities, so an OEIS
search is not applicable.

## 3. Counterexample hunt

* Universal claim "`exp(log x + log y) = x·y` for all `x,y ∈ [0,1]²`" — **FALSE**;
  counterexample `(0,1)` found above and proven (`expLog_fails_at_boundary`).
* Universal claim "`¼(x+y)² − ¼(x−y)² = x·y` for all `x,y ∈ ℝ`" — no counterexample
  over a sampled grid `{-3,-2,…,3}²`; proven for all reals (`mul_eq_polarization`).
* Positivity hypothesis in `prod_eq_exp_sum_log` is necessary — counterexample at a
  zero coordinate found and proven.

## 4. Summary

The product is EML-representable two ways — a transcendental rank-one form valid
only on the interior, and a polynomial two-term form valid globally — and the
exp/log-depth (`elDepth`) is exactly the invariant separating the two regimes.
All table rows above are reproduced as `0`-sorry Lean theorems in
`Catalog/Applications/KolmogorovArnoldEML.lean` and
`Catalog/Applications/KolmogorovArnoldEMLProduct.lean`.
