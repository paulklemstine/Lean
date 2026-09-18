# Computational evidence — DIAL-INDEPENDENCE (paper 91, SYNERGY-AND-OVERLAP)

This note records the *exploratory* numerics run before formalisation. It is
exploration only: every claim that matters is proved in Lean in
`Catalog/MachineLearning/BatterySynergy/` and is verified by the build, not by
these scripts.

## 1. The three rows, reproduced on a four-element population

Population `Bool × Bool` (uniform, four individuals); dial `0` reads the first
bit, dial `1` the second bit, dial `2` duplicates dial `0`. Empirical
information in bits:

| label | pair | `I(joint)` | `I₁` | `I₂` | `Δ = I − I₁ − I₂` |
|---|---|---|---|---|---|
| parity | `{0,1}` | 1.000 | 0.000 | 0.000 | **+1.000** (synergy) |
| first bit | `{0,1}` | 1.000 | 1.000 | 0.000 | **0.000** (additive) |
| first bit | `{0,2}` | 1.000 | 1.000 | 1.000 | **−1.000** (overlap) |

This is the qualitative shape of the measured table (`+0.129`, `+0.005`,
`−0.992`), pushed to its extreme values. All three rows are proved in
`OverlapWitness.lean` (`synergy_row_pos`, `synergy_row_zero`,
`synergy_row_neg`).

## 2. Counterexample hunt for the two laws

* Pair co-information identity `Δ = I(f;g|L) − I(f;g)`: tested on 2000 random
  empirical populations (sizes 2–12, label alphabet 3, reading alphabets 4).
  Violations: **0**. Conditional dependence `I(f;g|L) < 0`: **0** occurrences.
* Width-`k` law `Σᵢ I(L;fᵢ) − I(L;joint) = TC(reads) − TC(reads | L)` with both
  correlation terms nonnegative: tested on 1000 random batteries of width 1–4.
  Violations: **0**.

These searches motivated the two identities; both are now theorems
(`pairSynergy_eq_condMI_sub_readMI`, `multi_coinformation_identity`) with the
nonnegativity facts proved from the data processing inequality
(`condMI_nonneg`, `condTotalCorr_nonneg`, `totalCorr_nonneg`), so the numerics
play no role in the final result.

## 3. Sharpness probe

For `k` copies of one dial read against that dial's own reading, the numerics
gave `TC = (k−1)·H(u)` and `Δ = −(k−1)·H(u)` for `k = 2,3,4`, i.e. equality in
the overlap bound. This is now the theorem `multiSynergy_const_eq`.

## 4. What the numerics did *not* settle

The published marginals (`1.0012`, `0.4733`, `1.4342`) and the measured
deviations (`+0.129`, `+0.005`, `−0.992`) are inputs from the experiment; no
attempt was made to recompute number-field dial statistics here. The formal
content is structural: the exact law that constrains such tables, its two-sided
bounds, and witnesses attaining both signs.
