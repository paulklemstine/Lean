# Computational Evidence — tie-profile headroom for Spearman's rho

Status legend: **[Lean]** = backed by a sorry-free theorem in `Catalog/Logic/TieHeadroom.lean`;
**[exploratory]** = exact rational arithmetic in a scratch script, *not* formally verified.

## Notation
Profile `L = [l₁,…,l_k]`, `n = Σ lⱼ`; canonical midranks; `f(L) = 1 − Σ(lⱼ³−lⱼ)/(n³−n)`;
`ρ_u = cov/((n³−n)/12)` (textbook normalisation); `ρ_c = cov/√(SS_L·SS_M)` (two-sided tie correction).

## Small cases

| L | M | f(L) | f(M) | max ρ_u | f(L)·f(M) | max ρ_u² | max ρ_c | source |
|---|---|---|---|---|---|---|---|---|
| [1,1,2] | [1,1,2] | 9/10 | 9/10 | 9/10 | 81/100 | 81/100 | 1 | [Lean] `maxRho_not_function_of_tieFactors` |
| [1,1,2] | [2,1,1] | 9/10 | 9/10 | 4/5 | 81/100 | 64/100 | 8/9 | [Lean] same theorem |
| [1,1,1,1] | [2,2] | 1 | 4/5 | 4/5 | 4/5 | 16/25 | √(4/5) | [Lean] `maxRho_untied`, `rhoCorr_untied_aligned` (general M) |

Row 1 vs row 2: identical marginal tie factors, different ceilings ⇒ the ceiling is not a
function of `(f(L), f(M))`.

## Exhaustive counterexample hunt [exploratory]
All ordered pairs of compositions of `n` (profiles), all `n!` pairings, exact fractions:

| n | profile pairs | aligned pairing optimal | `ρ_u² ≤ f(L)f(M)` violated | bound attained | `(f(L),f(M))` classes with >1 ceiling |
|---|---|---|---|---|---|
| 4 | 64 | 64/64 | 0 | 22 | 6 |
| 5 | 256 | 256/256 | 0 | 46 | 25 |
| 6 | 1024 | 1024/1024 | 0 | 94 | 67 |

The attainment counts equal `2^{n-1} + (2·2^{n-1} − 1) − 1`: exactly the pairs with `L = M`
or with one profile a single block (both factors 0). This suggests (not proved) the
equality characterisation "attained ⇔ `L = M` or a constant variable".
The "aligned optimal" and "no violation" columns are proved in general in Lean
(`rankCov_le_aligned`, `rhoUncorr_sq_le_tieFactor_mul`).

## Recorded pooled reading (0.669, +0.045)
No data file, tie profile or catalog module (`MachineLearning.ZeroFitDialWeighted56`,
`MachineLearning.ZeroFitDialWeightedSharpness`) was present in the project, so the numerical
check against the recorded pooled reading **could not be performed**. What the theorems do
fix is how such a check must be done: with a flat dial the uncorrected ceiling is `f(M)`
and the corrected ceiling is `√f(M)` (not `√(f(L)f(M))` with equality), so an observed 0.669
would require `f(M) ≥ 0.669` (textbook rho) or `f(M) ≥ 0.669² ≈ 0.448` (tie-corrected rho).

OEIS: the attainment counts 22, 46, 94 (= 3·2^{n-1} − 2) are the simple sequence `3·2^k − 2`; no further search needed.

## Ratio-headroom conjecture check [exploratory]
For all profile pairs with positive tie factors, `n = 3,…,8`, the aligned corrected rho satisfies
`ρ_c² ≤ min(f(L),f(M))/max(f(L),f(M))` with **0 violations** (exact fractions). Not formally
verified; recorded as Future Direction 3.
