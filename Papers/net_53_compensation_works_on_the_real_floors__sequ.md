# Computational Evidence — NET-53 (GPTQ as a Schur complement)

All numbers below that are labelled *Lean-checked* are proved by `norm_num` in
`Catalog/Shared/GPTQSchurCompensation.lean` (namespace `GPTQSchur.Net53`), using the measured
ΔCE values entered as exact rationals. Hand calculations are labelled as such.

## 1. Measured ladder (input data, NET-52/NET-53, Qwen2.5-0.5B, ctx 512)

| bits | per-channel RTN | grouped RTN (g128) | grouped GPTQ (g128) |
|---|---|---|---|
| 4 | 0.788 | 0.318 | 0.1512 (CORE L0–21: 0.1235) |
| 3 | 9.23 | 2.72 | 1.1932 |

## 2. Derived quantities (Lean-checked)

| quantity | value | theorem |
|---|---|---|
| GPTQ-4 minus the 0.15 bar | +0.0012 (bar **missed**) | `p1_bar_missed` |
| tail increment ALL − CORE | 0.0277 exactly | `tail_increment` |
| tail share | in (1/6, 1/5) ≈ 18.3 % | `tail_share_bounds` |
| compensation lever, 4-bit (grouped RTN / GPTQ) | in [2.10, 2.11) | `lever4` |
| lever drift 3-bit / 4-bit (compensation) | in (1, 1.09) | `compensation_lever_nearly_invariant` |
| lever drift 3-bit / 4-bit (grouping) | > 1.35 | `grouping_lever_not_invariant` |
| compounded lever per-channel → GPTQ | > 5 (4-bit), > 7.7 (3-bit) | `compounded_levers` |

## 3. Small-case sanity check of the GPTQ column formula (hand calculation)

`H = [[2, 1], [1, 2]]`, quantize coordinate 1 with error `e = 1`:
* RTN loss (no compensation): `H₁₁ e² = 2`.
* Optimal update `v* = −D⁻¹Bᵀu = −1/2`; loss `2 − 2·(1/2) + 2·(1/4) = 1.5`.
* Schur complement `2 − 1·(1/2)·1 = 1.5`; `[H⁻¹]₁₁ = 2/3`, so `e²/[H⁻¹]₁₁ = 1.5`. ✓
* `H₁₁ · [H⁻¹]₁₁ = 4/3 ≥ 1`. ✓
These agree with `gptq_column_formula`, `schur_le_rtn`, `diag_mul_inv_diag_ge_one`.
Uncorrelated case `H = diag(2, 2)`: `Bᵀu = 0`, compensated = RTN = 2 — the equality case of
`schur_lt_rtn_iff`.

## 4. Counterexample hunt

* The pre-registered P1 ("ΔCE ≤ 0.15") is **refuted by exact arithmetic**: 0.1512 > 0.15.
  The original write-up's "confirmed at the boundary" is a rounding artefact.
* Hypothesis "the 3-bit errors are a rescaling of the 4-bit errors under one quadratic model"
  is refuted (`no_rescaled_quadratic_model`): the GPTQ/RTN ratio would be bit-invariant
  (`compensation_ratio_scale_invariant`) but the measured ratios differ (2.103 vs 2.280).

No OEIS sequence is relevant (the data are real-valued measurements).
