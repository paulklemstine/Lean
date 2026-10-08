# Computational evidence — NET-50 tropical limit (companion to `Catalog/Novelty/TropicalLimitRecovery.lean`)

All numbers below are computed with plain floating point arithmetic from the NET-50 table and gap map in the
assignment. Only the rows tagged **[Lean]** are also checked in Lean (by theorems in the file above);
the other rows are exploration and are not verified.

## 1. Sandwich `1 - e^{-g} ≤ Σp(1-p) ≤ 1 - e^{-2g}` evaluated at the measured median gaps

| gap g (nats) | argmax mass e^{-g} | crys. lower 1-e^{-g} | crys. upper 1-e^{-2g} | τe^{g} keys (τ=0.98) |
|---|---|---|---|---|
| 0.17 (sharpest bulk) | 0.844 | 0.156 | 0.288 | 1.2 |
| 1.46 (bulk max @2048) | 0.232 | 0.768 | 0.946 | 4.2 |
| 1.86 (bulk max @512/1024) | 0.156 | 0.844 | 0.976 | 6.3 |
| 2.33 (L22 @512) | 0.097 | 0.903 | 0.991 | 10.1 |
| 2.69 (L22 @2048) **[Lean: ≥13 keys]** | 0.068 | 0.932 | 0.995 | 14.4 |

Reading: P3 ("crystallization ≤ 0.25") can only hold on rows with gap ≤ log(4/3) ≈ 0.288 (**[Lean]**
`gap_le_of_crystallization_le_quarter`); every bulk layer with median gap above 1/3 nat breaks it
(**[Lean]** `crystallization_gt_quarter_of_gap`). Caveat: the sandwich holds row by row; the measured values
are medians and means over rows, so comparing them is only heuristic.

## 2. Doubling test on the measured recovery curve

| context | R(2)/R(1) | R(4)/R(2) | R(8)/R(4) | −log R(1) |
|---|---|---|---|---|
| 512 | 2.162 | 1.157 | 1.057 | 1.011 |
| 1024 | 2.564 | 1.204 | 1.065 | 1.243 |
| 2048 | 2.797 | 1.251 | 1.074 | 1.385 |

A sorted attention-mass curve satisfies R(2k) ≤ 2R(k) (**[Lean]** `retained_two_mul_le`). The k=1→2 step
breaks this at all three contexts (**[Lean]** `net50_recovery_not_attention_mass`), so the measured
retention is not the kept softmax mass of one row. It behaves like a nonlinear readout (for example one
compounded over layers). The later steps (k ≥ 2) satisfy the doubling bound.

## 3. Collision bound

The largest measured per-layer crystallization mean, 0.97, corresponds to collision 0.03. The bound
knee ≥ τ²/collision then gives at least 32.01, so at least 33 keys (**[Lean]**
`net50_crystallization_forces_33_keys`). The measured global knees {16, 32, 24} sit *below* this per-row
mass knee. This is consistent with §2: the diffuse-tail layers appear to tolerate sub-knee mass
truncation, which is evidence for the "prune only L22/L23" follow-up.

## 4. Counterexample hunt
- `argmaxFloor` monotonicity is false at n = 0 (the formula gives 1/(1−e^{−m})), so the Lean statement is
  restricted to n ≥ 1.
- No OEIS sequence is relevant: the data are real-valued measurements.
