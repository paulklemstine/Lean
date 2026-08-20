# Computational evidence for the two-scale PTX drift law

All numbers below were produced by `#eval` on `Float` inside Lean 4 (same toolchain as the
formal file). They are exploratory numerics that guided the statements; the *proved*
statements live in `Catalog/Novelty/RLHFPretrainingMixIn.lean` and are verified by the
kernel, not by these evaluations.

## Test instance

A three-point response space `Ω = {y₀, y₁, y₂}` with

```
p = (0.5, 0.3, 0.2)      -- SFT / reference policy
d = (0.1, 0.1, 0.8)      -- pretraining distribution
r = (0.0, 1.0, 3.0)      -- reward, so L = 0, M = 3
```

`‖d − p‖₁ = 1.2`.  Arithmetic mix-in anchor `p_γ = (1−γ)p + γd`.

## 1. `γ = 0.25`: the two-scale law

Predicted floor `γ‖d − p‖₁ = 0.30`.  Anchor statistics: `MAD_{p_γ}(r) = 1.190`,
`σ_{p_γ}(r) = 1.3077`, `σ²/(M−L) = 0.570`.

| β | ‖q*−p‖₁ | ‖q*−p_γ‖₁ | β·‖q*−p_γ‖₁ |
|---|---------|-----------|-------------|
| 1 | 1.33375 | 1.03375 | 1.0338 |
| 2 | 0.91772 | 0.61772 | 1.2354 |
| 5 | 0.54966 | 0.24966 | 1.2483 |
| 10 | 0.42255 | 0.12255 | 1.2255 |
| 50 | 0.32396 | 0.02396 | 1.1980 |
| 200 | 0.30596 | 0.00596 | 1.1921 |
| 1000 | 0.30119 | 0.00119 | 1.1904 |

Two readings:

* `‖q*−p‖₁ → 0.3012 → 0.30 = γ‖d−p‖₁`: the drift does **not** vanish — the alignment floor
  (`ptx_l1_tendsto`, `ptx_no_return_to_p`).
* `β·‖q*−p_γ‖₁ → 1.1904`, matching `MAD_{p_γ}(r) = 1.190` and *not* `σ_{p_γ}(r) = 1.308`
  (`gibbs_beta_l1_tendsto_mad`). This is the counterexample that killed the naive reading
  of the assignment's `Θ(σ/β)`: the sharp constant is the mean absolute deviation. The
  proved sandwich `σ²/(M−L) = 0.570 ≤ 1.190 ≤ 1.308 = σ` (`mad_sandwich`) is what survives.

### The `1/β` coefficient of the *total* drift

For this instance `p_γ = (0.40, 0.25, 0.35)`, so `p_γ − p = (−0.10, −0.05, +0.15)` with sign
pattern `(−1, −1, +1)`, and `𝔼_{p_γ} r = 1.3`. The signed covariance predicted by
`ptx_beta_l1_expansion` is

```
(−1)(0.40)(0−1.3) + (−1)(0.25)(1−1.3) + (+1)(0.35)(3−1.3) = 0.520 + 0.075 + 0.595 = 1.190 .
```

Measured: `β(‖q*−p‖₁ − 0.30) = 1000 · (0.301190 − 0.300000) = 1.190`. Exact agreement to the
digits shown. (Here the sign pattern happens to align with `sgn(r − 𝔼 r)`, so the covariance
coincides with `MAD`; in general the coefficient is signed and can be negative.)

## 2. `γ = 0` control: the cycle-2 regime is recovered

| β | ‖q*−p‖₁ | β·‖q*−p‖₁ |
|---|---------|-----------|
| 1 | 1.10662 | 1.1066 |
| 10 | 0.09217 | 0.9217 |
| 100 | 0.00902 | 0.9024 |
| 1000 | 0.00090 | 0.9002 |

Here `𝔼_p r = 0.9` and `MAD_p(r) = 0.5·0.9 + 0.3·0.1 + 0.2·2.1 = 0.90`, matching the limit
`0.9002` to four digits. With no mix-in the optimum does return to `p` at rate `MAD/β`.

## 3. Counterexample hunt: is the floor an artefact of the arithmetic mixture?

Replacing the anchor by the *geometric* mix-in `p^{1−γ}d^γ/Z` at `γ = 0.25` gives
`geoMix = (0.39563, 0.26971, 0.33466)` with `‖geoMix − p‖₁ = 0.26932`, and

| β | ‖q*−p‖₁ |
|---|---------|
| 10 | 0.38876 |
| 100 | 0.28092 |
| 1000 | 0.27048 |

converging to `0.26932`, again strictly positive. No mixture model tested removes the
floor; this motivated the general statement `anchor_return_iff` (the limit is `‖m − p‖₁`
for an arbitrary anchor `m`, hence `0` iff `m = p`), which is proved and covers both
models at once.

## 4. Sequences / OEIS

No integer sequence arises here (the objects are real-valued optima on a simplex), so no
OEIS search was applicable.
