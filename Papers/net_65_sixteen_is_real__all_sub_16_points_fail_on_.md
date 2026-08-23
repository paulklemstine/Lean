# Computational evidence — attention-budget knee (NET-65 thread)

Small-scale numerical exploration used to choose and sanity-check the formal statements
in `Catalog/Shared/AttentionBudget*.lean`.

**Status of these numbers.** Everything in this file is *exploratory* floating-point
computation, not machine-verified. The verified content of this project is the set of
Lean theorems; the tables below only motivated which statements to formalise. All
theorem statements are gate- and profile-general and do not depend on these numbers.

## 1. Knee `k*(n)` of model profiles at gate `τ = 0.98`

`k*(n)` = least `k` with `(∑_{i<k} w i) / (∑_{i<n} w i) ≥ 0.98`.

| profile | n = 64 | 256 | 1024 | 4096 |
|---|---|---|---|---|
| geometric `r = 0.5` | 6 | 6 | 6 | 6 |
| geometric `r = 0.8` | 18 | 18 | 18 | 18 |
| uniform (flat) | 63 | 251 | 1004 | 4015 |

The geometric rows are *bounded* (flat chain); the uniform row grows linearly, with
slope ≈ `τ = 0.98`. This is exactly the dichotomy formalised in
`context_sensitivity_dichotomy` and quantified by `kstar_ge_of_bounded_ratio`
(`k*(n) ≥ τ n c / M`, here `c = M = 1`).

## 2. Closed-form budget versus measured knee

`geometricBudget r τ = ⌈log((1-τ)(1-r)) / log r⌉`:

| r | closed form `K(r, 0.98)` | observed knee (all n above) |
|---|---|---|
| 0.5 | 7 | 6 |
| 0.8 | 25 | 18 |

The formula is an upper bound in both cases, as `kstar_le_geometricBudget` asserts,
and is loose by ≤ 40 % — the slack is the `headMass w k ≥ w 0` step in the proof.

## 3. Zipf profiles: the critical exponent

`w i = (i+1)^(-s)`, gate `0.98`:

| s | n = 256 | 512 | 1024 | 2048 | 4096 |
|---|---|---|---|---|---|
| 0.5 | 247 | — | 985 | — | 3936 |
| 1.0 | 227 | — | 882 | — | 3429 |
| 1.5 | 131 | — | 311 | — | 582 |
| 2.0 | 27 | 29 | 30 | 30 | 30 |
| 2.1 | 20 | 21 | 21 | 21 | 21 |
| 2.2 | 16 | 16 | 16 | 16 | 16 |
| 2.3 | 12 | 12 | 13 | 13 | 13 |

Sub-critical rows (`s ≤ 1`) grow like `n`; supercritical rows saturate. The saturation
is visibly slower as `s ↓ 1` (`s = 1.5` has not saturated by `n = 4096`), consistent
with the criterion `CtxStable ↔ Summable` proved in `ctxStable_iff_summable` and with
its Zipf specialisation `zipf_phase_transition` (critical exponent exactly 1).

Note that `s = 2.3` shows `k*(256) = 12 < 13 = k*(1024)`: bounded, but *not* constant.
This is the numerical shadow of `exact_flatness_refuted`.

## 4. Comparison with the reported NET-65 sub-16 grid (ctx = 1024, gate 0.98)

| k | 4 | 6 | 8 | 12 | 16 |
|---|---|---|---|---|---|
| reported | 0.9318 | 0.9532 | 0.9660 | 0.9759 | pass |
| Zipf s = 2.2 | 0.9086 | 0.9411 | 0.9573 | 0.9732 | 0.9808 |
| Zipf s = 2.3 | 0.9245 | 0.9531 | 0.9669 | 0.9799 | 0.9860 |

A single-parameter Zipf profile with `s ≈ 2.2–2.3` reproduces the reported retained
masses to within ≈ 0.005 and reproduces the knee `k* = 16` at ctx = 1024 exactly
(`s = 2.2`). Under that fit the theory predicts a *bounded, essentially flat* chain
at ctx = 2048 and 4096 (`16, 16` in the table above) — a falsifiable prediction for the
next experiment in the thread.

## 5. Counterexample hunt

* Searched for a positive profile with `k*(2n) = k*(n)` for *all* `n` at an interior
  gate: none found among geometric/Zipf families; the geometric profile `(1/2)^i` at
  gate `3/4` already gives `k*(1) = 1`, `k*(2) = 2`. This refutation is formalised
  exactly (no floating point) in `exact_flatness_refuted`.
* Searched for a *non-summable* profile with bounded knee: none, as expected from
  `ctxStable_iff_summable`.
* Checked the mediant/max law on random pairs of profiles (`w₁` geometric, `w₂` Zipf):
  the mixture knee never exceeded the larger of the two knees, matching
  `kstar_add_le_max`.

## 6. OEIS

No integer sequence of independent interest arises: the knee sequences here are
determined by a real gate parameter and are not integer-sequence invariants, so no OEIS
lookup was applicable.
