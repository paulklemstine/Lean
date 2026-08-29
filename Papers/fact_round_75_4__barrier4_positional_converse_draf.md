# Computational evidence — barrier-4 positional/magnitude converse (T1, T2, Conjecture D)

All numbers below were produced inside Lean (exact `ℚ` arithmetic where the value is rational,
`Float` only for display), against the same definitions that the theorems use.  They were used to
select and sanity-check the statements *before* they were proved; the proofs themselves are
symbolic and do not depend on these evaluations.

## 1. T1 — the three cost laws at the `5.19×` anchor `(μ, P) = (0.05, 0.85)`

| law | definition | exact cost | speedup |
|---|---|---|---|
| certified silence (protocol A) | `μP + (1−P)(1−μ)` | `37/200 = 0.1850` | `5.4054…` |
| fire-or-silent (drafted) | `1 − (1−μ)P` | `77/400 = 0.1925` | `5.1948…` |
| protocol B (block-first, full re-scan) | `μ + (1−P)` | `1/5 = 0.2000` | `5.0000` |

The three costs are **equally spaced** with common gap `μ(1−P) = 0.05·0.15 = 0.0075`
(`0.1850, 0.1925, 0.2000`).  This observation became `cost_arithmetic_progression`, and it is the
precise sense in which the drafted fire-or-silent form is *superseded*: it sits exactly one
non-certifying silence above the certified law and one below protocol B.

## 2. T1 — the four measured anchors, as exact rationals

Evaluated as `1 / (1 − (1−μ)P)` in `ℚ`:

| anchor | `(μ, P)` | exact speedup | decimal |
|---|---|---|---|
| 5.19× | `(1/20, 17/20)` | `400/77` | `5.194805` |
| 6.91× | `(1/20, 0.9003)` | `200000/28943` | `6.910134` |
| 4.35× | `(1/20, 0.8106)` | `100000/22993` | `4.349150` |
| 29.1× | `(1/50, 0.9853)` | `500000/17203` | `29.064698` |

All four reproduce the recorded anchors, and all four satisfy `(3/4)·S ≤ 1/μ`
(`3.90 ≤ 20`, `5.18 ≤ 20`, `3.26 ≤ 20`, `21.80 ≤ 50`), i.e. every anchor is realisable as
`S(R)·S(F)` with the residue factor pinned at its cap `4/3`.  These became `anchor_519`, …,
`anchor_291` and the corresponding `*_class_crossing` theorems.

## 3. T1 — counterexample hunt for block-first dominance (protocol B)

Grid sweep over `(μ, P) ∈ {0, 0.1, …, 1}²`, reporting all points where block-first is *worse*
than complement-first (`μ + (1−P) > (1−μ) + P`):

```
(0.1,0) (0.2,0) (0.2,0.1) (0.3,0) (0.3,0.1) (0.3,0.2) (0.4,0) … (1,0) … (1,0.9)
```

Every single violating point has `P < μ`; no violation with `P ≥ μ` was found.  This is exactly
the recorded "all counterexamples have `P < μ`", and it is now a theorem with an iff:
`blockFirst_dominance_B_iff : costRescan μ P ≤ costRescanComp μ P ↔ μ ≤ P`.
The same sweep for protocol A returns the empty list — dominance there is unconditional.

## 4. T2 — the census `C*` and the argmin offsets

Cost curve `netCost W k = W/2^(k+1) + k` on `W = 2^19` and `W = 2^20`, at
`k = pin−3, …, pin+1`:

```
W = 2^19 : k = 16,17,18,19,20  ->  20.00, 19.00, 19.00, 19.50, 20.25
W = 2^20 : k = 17,18,19,20,21  ->  21.00, 20.00, 20.00, 20.50, 21.25
```

* the **pinned** value (`k = log₂W`) is `19.5` at `2^19` and `20.5` at `2^20` — the recorded
  census `C*`, and exactly `log₂W + 1/2`;
* the **argmin** is attained at the two offsets `{−2, −1}` with value `log₂W`;
* so the pin sits exactly half a query above the optimum.

This is `saturation_exact`, `netCost_dyadic_ge`, `netCost_pin_sub_one`, `netCost_pin_sub_two`,
`pin_not_argmin` (gap `= 1/2` exactly, `pin_argmin_gap`).

## 5. T2 — the marginal-value identity, gross vs net

At `W = 4, k = 0`: `netCost 4 0 − netCost 4 1 = 2 − 2 = 0`, whereas the gross form would predict
`W/2^(k+2) = 1`.  The gross form fails; the net form `W/2^(k+2) − 1 = 0` is exact.  Formalised as
`marginal_net_identity` (exact, all `W`, all `k`) and `gross_marginal_identity_fails`.

## 6. Conjecture D — the residue cap

`residueCost θ = 1 − θ(1−θ)` sampled on `θ = 0, 0.1, …, 1` has minimum `3/4` at `θ = 1/2`,
so `sup_θ 1/residueCost θ = 4/3`, attained only at `θ = 1/2`.  Formalised as
`residue_cap_isGreatest` and `residue_speedup_eq_cap_iff`.

The identity check `residueCost θ = costFireOrSilent θ θ` holds symbolically
(`residueCost_eq_master_uninformative`): the residue law *is* the master law at its uninformative
point.

## 7. Axiom audit

`#print axioms` on the main theorems of all four files returns
`[propext, Classical.choice, Quot.sound]` only — no `sorry`, no custom axioms, no
`native_decide`.
