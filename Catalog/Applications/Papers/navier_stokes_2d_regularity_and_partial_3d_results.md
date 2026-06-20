# THEOREM_TRACE (internal)

Source of truth: the Concept ("Navier–Stokes: 2D Regularity and Partial 3D
Results") and the Phase A Future Directions, which describe the scalar
differential-inequality core (`Core.lean`) and its integrated dissipation-budget
consequences (`Estimates.lean`): 2D enstrophy monotonicity and global
boundedness, Poincaré energy decay with convergence to zero, the sharp 3D
supercritical blow-up rate, conditional and unconditional 3D small-data results,
and finite total dissipation via the FTC (11 theorems, 0 sorries).

The pasted "Phase A Lean output" block in the request was mismatched (it showed
MockTheta / SheafDataIntegration files unrelated to Navier–Stokes); the
mathematical ground truth used here is the Concept + Future Directions.

| Lean name | Mathematical statement | ARTICLE.md | RESEARCH_PAPER.md |
|---|---|---|---|
| `enstrophy_monotone_2D` | If `Z' = -2ν·D` with `D ≥ 0`, then `Z` is monotone non-increasing. | §"The two-dimensional miracle" | §3.1 Thm 1 |
| `enstrophy_global_bound_2D` | Under the same hypotheses, `Z(t) ≤ Z(0)` for all `t ≥ 0`. | §"The two-dimensional miracle" | §3.1 Thm 2 |
| `energy_decay_poincare` | If `E' = -2ν·F` and `F ≥ λ·E` (Poincaré), then `E(t) ≤ E(0)·exp(-2νλ t)`. | §"Energy runs downhill" | §3.2 Thm 3 |
| `energy_tendsto_zero` | Under the same hypotheses, `E(t) → 0` as `t → ∞`. | §"Energy runs downhill" | §3.2 Cor 4 |
| `blowup_rate_lower_bound_3D` | If `Z ≥ 0`, `Z' ≤ C·Z³` on `[0,T*)` and `Z` blows up at `T*`, then `Z(t) ≥ 1/√(2C(T*−t))`. | §"The three-dimensional cliff edge" | §3.3 Thm 5 |
| `lifespan_lower_bound_3D` | If `Z' ≤ C·Z³` then `Z` stays finite on `[0, 1/(2C·Z(0)²))`. | §"The three-dimensional cliff edge" | §3.3 Thm 6 |
| `small_data_global_conditional_3D` | If `Z' ≤ -a·Z + C·Z²` and `Z(0) ≤ a/C` and the solution exists on `[0,T]`, then `Z(t) ≤ Z(0)` on `[0,T]`. | §"Staying small forever" | §3.4 Thm 7 |
| `small_data_global_3D` | If `Z' ≤ -a·Z + C·Z²` and `Z(0) < a/C`, then `Z(t) ≤ Z(0)` for all `t ≥ 0` (no blow-up). | §"Staying small forever" | §3.4 Thm 8 |
| `total_dissipation_finite` | If `E' = -2ν·F`, `E ≥ 0`, then `∫₀^T F = (E(0)−E(T))/(2ν) ≤ E(0)/(2ν)`. | §"The dissipation budget" | §3.5 Thm 9 |
| `total_dissipation_bddAbove` | The partial dissipation integrals `T ↦ ∫₀^T F` are bounded above by `E(0)/(2ν)`. | §"The dissipation budget" | §3.5 Thm 10 |
| `energy_identity_FTC` | `E(T) = E(0) − 2ν ∫₀^T F` (energy identity via the FTC). | §"The dissipation budget" | §3.5 Thm 11 |
