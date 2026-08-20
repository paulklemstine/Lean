# Computational evidence

All numbers below were produced with `#eval` on `Float` inside the project's Lean
toolchain (Lean 4.28.0 / Mathlib), before the corresponding theorems were proved.
They are exploratory only; the verified statements are the Lean theorems in
`Catalog/Novelty/RLHF*.lean`, all of which compile without `sorry`.

## 1. The Padé lower bound for `log`

Conjecture (later `RLHF.log_ge_pade`): for `t > 0`,

```
log t ≥ R(t) := (5t² − 4t − 1) / (2t² + 4t).
```

Values of `log t − R(t)`:

| t | 0.1 | 0.5 | 0.9 | 1.0 | 1.5 | 2.0 | 10.0 |
|---|-----|-----|-----|-----|-----|-----|------|
| `log t − R(t)` | 0.9117 | 0.006853 | 0.0000034 | 0 | 0.000703 | 0.005647 | 0.3901 |

The defect vanishes to third order at `t = 1` — this is why the bound produces
Pinsker's inequality with the *optimal* constant.  A first attempt with the
denominator `2t + 1` instead of `t + 2` was falsified numerically at `t = 0.9`
(defect `−1.8·10⁻⁶`), which is what led to the correct Padé form.

## 2. Sharpness of Pinsker's constant

Two-point family `q_ε = (1/2+ε, 1/2−ε)` against the uniform reference; the table
shows `2 KL(q_ε ‖ q_0) / ‖q_ε − q_0‖₁²`:

| ε | 0.2 | 0.1 | 0.05 | 0.01 | 0.001 |
|---|-----|-----|------|------|-------|
| ratio | 1.02854 | 1.00678 | 1.00167 | 1.000067 | 1.0000007 |

The ratio approaches `1` from above, consistent with `RLHF.pinsker` (ratio ≥ 1) and
with the proved upper bound `1 + (8/3)ε²` (e.g. at `ε = 0.1`: `1.00678 ≤ 1.02667`).

## 3. Drift rate: `β^{-1/2}` versus `β^{-1}`

Two-point model, uniform reference, reward `1_{true}`; exact drift is
`(e^{1/β} − 1)/(e^{1/β} + 1)`:

| β | drift | `2/β` (proved upper bound) | `1/(3β)` (proved lower bound) | `√(2/β)` (Pinsker-only bound) |
|---|-------|------|--------|--------|
| 1 | 0.4621 | 2.000 | 0.3333 | 1.4142 |
| 2 | 0.2449 | 1.000 | 0.1667 | 1.0000 |
| 5 | 0.09967 | 0.4000 | 0.06667 | 0.6325 |
| 10 | 0.04996 | 0.2000 | 0.03333 | 0.4472 |
| 100 | 0.005000 | 0.02000 | 0.003333 | 0.14142 |

The measured drift is `Θ(1/β)` and is bracketed by the two proved bounds, while the
`√(2 range/β)` bound coming from Pinsker alone is off by an order of magnitude at
large `β`.  This computation is what motivated the quadratic KL bound
`RLHF.kl_gibbs_le_quadratic`.

## 4. Counterexample hunt

* Attempted pointwise bound `t log t − t + 1 ≥ 3(t−1)²/(2(2t+1))`: **false**
  (fails at `t = 0.9`), replaced by the `(t+2)` denominator.
* Attempted improvement of Pinsker's constant from `2` to `1.9`: falsified for
  `ε ≤ 0.05` by the table in §2; this is now a theorem
  (`RLHF.pinsker_constant_optimal`).
* Attempted claim "drift `→ 0` as `β ↓ 0`": falsified — drift `→ 1`
  (`RLHF.l1Dist_spike_tendsto_one`).

No OEIS sequence is involved: all objects here are continuous.

---

# Cycles 2–3: variance constant and covariance expansion

## 5. Is the drift constant the range or the standard deviation?

Scaled two-point model (uniform reference on `Bool`, reward `a · 1_{true}`), exact
drift `tanh(a/(2β))`, reference standard deviation `σ = a/2`:

| a | β | `σ/(2β)` (proved lower bound) | exact drift | `3σ/β` (proved upper bound) |
|---|---|--------|--------|--------|
| 1 | 1 | 0.2500 | 0.4621 | 1.500 |
| 1 | 2 | 0.1250 | 0.2449 | 0.750 |
| 1 | 10 | 0.02500 | 0.04996 | 0.150 |
| 2 | 4 | 0.1250 | 0.2449 | 0.750 |
| 0.5 | 5 | 0.02500 | 0.04996 | 0.150 |

The drift depends on `(a, β)` only through `a/β` and sits inside the sandwich for
every entry, which is exactly `RLHF.variance_constant_optimal`.

How much smaller than the range can the variance be?  For the reward `1_{true}` and
the reference `p(true) = ε`, the variance is `ε(1−ε)` while `range²/4 = 0.25`:

| ε | `Var_p(r)` | `range(r)²/4` |
|---|-----------|---------------|
| 0.5 | 0.2500 | 0.25 |
| 0.1 | 0.0900 | 0.25 |
| 0.01 | 0.00990 | 0.25 |
| 0.001 | 0.000999 | 0.25 |

So the variance-form bounds of `Novelty/RLHFVarianceDrift.lean` are unboundedly
stronger than the range-form bounds of `Novelty/RLHFQuadraticDrift.lean` on rare-spike
rewards — the regime that matters for safety-relevant rare behaviours.

## 6. Is the audit gap a covariance?

Three responses, uniform reference, reward `r = (1, 0, −1)`.

Correlated statistic `f = (1, 0, 0)`, `Cov_p(r,f) = 1/3`:

| β | measured gap | `Cov_p(r,f)/β` | remainder |
|---|--------------|----------------|-----------|
| 1 | 0.331908 | 0.333333 | −0.001426 |
| 2 | 0.173147 | 0.166667 | 0.006480 |
| 5 | 0.068426 | 0.066667 | 0.001760 |
| 20 | 0.016799 | 0.016667 | 0.000132 |
| 100 | 0.003339 | 0.003333 | 0.000005 |

The remainder falls by a factor ≈ 25 when `β` grows by a factor 5: it is `Θ(β⁻²)`,
matching `RLHF.audit_gap_first_order`.

Uncorrelated statistic `f = (1, −2, 1)`, `Cov_p(r,f) = 0`:

| β | measured gap |
|---|--------------|
| 1 | 0.265815 |
| 2 | 0.078412 |
| 5 | 0.013201 |
| 20 | 0.000833 |

Again `Θ(β⁻²)` and never `Θ(β⁻¹)`, which is `RLHF.audit_gap_of_uncorrelated`.
