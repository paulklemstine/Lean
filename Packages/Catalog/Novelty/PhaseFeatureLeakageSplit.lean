import Novelty.PhaseFeatureWindowLocality

/-!
# Same-window leakage versus higher-prime phases: separating the two surviving candidates
# (paper 150, exp 482, second research cycle)

## Research context

After the phase block was shown to be sub-threshold (`Novelty.PhaseFeatureLiftCeiling`,
`Novelty.PhaseFeatureCharacterGram`) and window-local (`Novelty.PhaseFeatureWindowLocality`),
exactly two candidate explanations of paper 147's *split-ceiling excess* remained:

1. **higher-prime phase patterns** — the same construction, pushed past `p = 29`;
2. **same-window leakage of realized-divisibility features** — features whose value on the
   evaluation window is computed from the very realizations they are asked to predict.

This file turns both candidates into arithmetic that can be checked, and finds them very
differently constrained.

*Candidate 1 is quantitatively expensive.*  Each new prime contributes an orthogonal block
whose lift is capped by `3ε²/0.18`, so covering an excess `Δ` needs at least `0.06 Δ / ε²`
blocks: at the measured per-feature correlation scale `ε = 0.01`, an excess of `0.2` needs
`≥ 120` prime blocks — far more primes than the design has.  Candidate 1 therefore predicts a
*slow, additive* accumulation, not a step.

*Candidate 2 is cheap and matches the observed shape.*  A leaked feature `f = α e + g` with
`g ⟂ e` reproduces **any** in-window `R²` whatsoever with an arbitrarily small "true" signal,
while its cross-window covariance can be exactly zero.  The leakage fraction is pinned by the
split: an in-window `0.60` against a cross-window `0` forces the leaked component to carry a
correlation of exactly `√0.6 ≈ 0.775` with the realized target.

## Main results

* `gain_of_leak_decomposition` — the exact in-window gain of a leaked feature:
  `gain e (α e + g) = α²‖e‖⁴ / (α²‖e‖² + ‖g‖²)`.
* `leak_R2_eq` — hence the in-window `R²` is exactly the leak-to-total energy ratio.
* `leak_ratio_of_measured_R2` — inverting it: a measured in-window `R²` of `r` pins the leakage
  energy ratio to `r/(1-r)`; `r = 0.6` gives `1.5`.
* `leak_correlation_lower_bound` — a falsifiable prediction: any feature achieving in-window
  `R² ≥ 0.6` must correlate with the *realized* target at level `≥ √0.6 > 0.774`.  Measuring
  that correlation directly refutes or confirms candidate 2 without any model fitting.
* `leaked_feature_transfers_nothing` — the signature of leakage: the same feature has exactly
  zero cross-window gain when the leaked component is resampled, so its transported coefficient
  produces a *strictly negative* out-of-sample gain.
* `total_block_ceiling` — the aggregate ceiling over `n` orthogonal prime blocks.
* `prime_blocks_needed` — **the cost of candidate 1**: covering an excess `Δ` requires at least
  `0.06 Δ / ε²` blocks.
* `prime_blocks_needed_measured` — the numeric verdict: `Δ = 0.2` at `ε = 0.01` needs `≥ 120`
  prime blocks; the nine primes of exp 482 fall short by more than an order of magnitude.

## Lab notes (derived predictions for the next round)

```
candidate                     prediction                                   test
higher-prime phases    n ≥ 0.06·Δ/ε² = 120 blocks for Δ = 0.2, ε = 0.01    extend to p ≤ 700
same-window leakage    corr(feature, realized target) ≥ 0.775 in-window    direct correlation
                       cross-window gain ≤ -β²‖f‖² < 0                     already observed
```
-/

open Finset
open Catalog.Novelty.PhaseFeatureLiftCeiling
open Catalog.Novelty.PhaseFeatureWindowLocality

namespace Catalog.Novelty.PhaseFeatureLeakageSplit

variable {ι : Type*} [Fintype ι]

/-! ## 1. Same-window leakage -/

/-- A **leaked feature**: it carries a copy `α e` of the realized target plus an orthogonal
part `g`.  This is what a realized-divisibility statistic computed on the evaluation window
looks like. -/
noncomputable def leakFeat (α : ℝ) (e g : ι → ℝ) : ι → ℝ := fun i => α * e i + g i

lemma dot_leakFeat (α : ℝ) (e g : ι → ℝ) (hg : dot e g = 0) :
    dot e (leakFeat α e g) = α * sqnorm e := by
  simp only [dot, leakFeat, sqnorm] at *
  rw [show ∑ i, e i * (α * e i + g i) = α * (∑ i, e i * e i) + ∑ i, e i * g i by
    rw [Finset.mul_sum, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring, hg, add_zero]

lemma sqnorm_leakFeat (α : ℝ) (e g : ι → ℝ) (hg : dot e g = 0) :
    sqnorm (leakFeat α e g) = α ^ 2 * sqnorm e + sqnorm g := by
  simp only [sqnorm, dot, leakFeat] at *
  rw [show ∑ i, (α * e i + g i) * (α * e i + g i)
      = α ^ 2 * (∑ i, e i * e i) + 2 * α * (∑ i, e i * g i) + ∑ i, g i * g i by
    rw [Finset.mul_sum, Finset.mul_sum, ← Finset.sum_add_distrib, ← Finset.sum_add_distrib]
    exact Finset.sum_congr rfl fun i _ => by ring, hg]
  ring

/-- **The leakage identity.**  A feature that carries a fraction `α` of the realized target has
in-window gain `α²‖e‖⁴/(α²‖e‖² + ‖g‖²)` — which tends to the *whole* target energy as the
orthogonal part shrinks, with no genuine predictive content at all. -/
theorem gain_of_leak_decomposition (α : ℝ) (e g : ι → ℝ) (hg : dot e g = 0) :
    gain e (leakFeat α e g) = α ^ 2 * sqnorm e ^ 2 / (α ^ 2 * sqnorm e + sqnorm g) := by
  rw [gain, dot_leakFeat α e g hg, sqnorm_leakFeat α e g hg]
  rw [mul_pow]

/-- The in-window `R²` of a leaked feature is exactly the leaked energy fraction. -/
theorem leak_R2_eq (α : ℝ) (e g : ι → ℝ) (hg : dot e g = 0) (he : 0 < sqnorm e)
    (hpos : 0 < α ^ 2 * sqnorm e + sqnorm g) :
    gain e (leakFeat α e g) / sqnorm e
      = α ^ 2 * sqnorm e / (α ^ 2 * sqnorm e + sqnorm g) := by
  rw [gain_of_leak_decomposition α e g hg]
  field_simp

/-- **Inverting the split.**  A measured in-window `R² = r` pins the ratio of leaked to
orthogonal energy at `r/(1-r)`; at the observed `r = 0.6` the leaked component carries `1.5`
times the energy of everything else in the feature. -/
theorem leak_ratio_of_measured_R2 (α r : ℝ) (e g : ι → ℝ) (hg : dot e g = 0) (he : 0 < sqnorm e)
    (hpos : 0 < α ^ 2 * sqnorm e + sqnorm g) (hr : r < 1)
    (hmeas : gain e (leakFeat α e g) / sqnorm e = r) :
    α ^ 2 * sqnorm e = (r / (1 - r)) * sqnorm g := by
  rw [leak_R2_eq α e g hg he hpos] at hmeas
  have h := (div_eq_iff (ne_of_gt hpos)).mp hmeas
  have hr1 : (1 : ℝ) - r ≠ 0 := by intro h0; linarith [h0]
  field_simp
  nlinarith [h]

/-- **A model-free falsification test for leakage.**  Any feature reaching in-window `R² ≥ 0.6`
must correlate with the *realized* target at level at least `√0.6 > 0.774`.  Measuring that
correlation directly decides candidate 2 without fitting anything. -/
theorem leak_correlation_lower_bound (e f : ι → ℝ) (hf : 0 < sqnorm f)
    (hR2 : (0.6 : ℝ) * sqnorm e ≤ gain e f) :
    (0.6 : ℝ) * (sqnorm e * sqnorm f) ≤ (dot e f) ^ 2 := by
  rw [gain, le_div_iff₀ hf] at hR2
  nlinarith [hR2]

/-- **The signature of leakage.**  If the leaked component is not present on the test window,
the very same feature has zero covariance there, and the coefficient fitted in-window then
produces a strictly negative out-of-sample gain — exactly the pattern H2 confirmed. -/
theorem leaked_feature_transfers_nothing (α : ℝ) (e g e' f' : ι → ℝ) (hg : dot e g = 0)
    (he : 0 < sqnorm e) (hleak : 0 < sqnorm (leakFeat α e g))
    (hpos' : 0 < sqnorm f') (hzero : dot e' f' = 0) (hαpos : 0 < α) :
    oosGain e' f' (optCoef e (leakFeat α e g)) < 0 := by
  have hnum : 0 < dot e (leakFeat α e g) := by
    rw [dot_leakFeat α e g hg]; positivity
  have hb : 0 < optCoef e (leakFeat α e g) := div_pos hnum hleak
  refine (oosGain_neg_of_sign_mismatch e' f' _ hpos' (ne_of_gt hb) ?_).2
  rw [hzero, mul_zero]

/-! ## 2. The cost of the higher-prime alternative -/

section Blocks

variable {β : Type*} [Fintype β] [Nonempty β]

/-- **Aggregate block ceiling.**  Orthogonal prime blocks, each capped at `c‖e‖², together cap
at `n c‖e‖²`. -/
theorem total_block_ceiling (e : ι → ℝ) (g : β → ι → ℝ) (c : ℝ)
    (hpos : ∀ b, 0 < sqnorm (g b))
    (hort : ∀ b b', b ≠ b' → dot (g b) (g b') = 0)
    (hb : ∀ b, gain e (g b) ≤ c * sqnorm e) :
    gain e (fun i => ∑ b, g b i) ≤ (Fintype.card β : ℝ) * c * sqnorm e := by
  refine le_trans (gain_le_sum_block_gains e g hpos hort) ?_
  calc ∑ b, gain e (g b) ≤ ∑ _b : β, c * sqnorm e := Finset.sum_le_sum fun b _ => hb b
    _ = (Fintype.card β : ℝ) * c * sqnorm e := by
        rw [Finset.sum_const, Finset.card_univ, nsmul_eq_mul, mul_assoc]

end Blocks

/-- **The cost of candidate 1.**  If `n` prime blocks, each capped at `3ε²/0.18` of the residual
energy, are to cover an excess of `Δ`, then `n ≥ 0.06 Δ / ε²`. -/
theorem prime_blocks_needed (Δ ε : ℝ) (n : ℕ) (hε : 0 < ε)
    (hcover : Δ ≤ (n : ℝ) * ((3 : ℝ) * ε ^ 2 / 0.18)) :
    (0.06 : ℝ) * Δ / ε ^ 2 ≤ (n : ℝ) := by
  have hε2 : 0 < ε ^ 2 := by positivity
  have hrw : (n : ℝ) * ((3 : ℝ) * ε ^ 2 / 0.18) = (50 / 3) * ((n : ℝ) * ε ^ 2) := by ring
  rw [hrw] at hcover
  rw [div_le_iff₀ hε2]
  linarith

/-- The numeric verdict: an excess of `Δ = 0.2` at the measured per-feature correlation scale
`ε = 0.01` needs at least `120` orthogonal prime blocks.  The nine primes of exp 482 supply
`9`; even the whole range `p ≤ 700` would be marginal.  Higher-prime phase patterns are
therefore an expensive explanation of the split-ceiling excess. -/
theorem prime_blocks_needed_measured (n : ℕ)
    (hcover : (0.2 : ℝ) ≤ (n : ℝ) * ((3 : ℝ) * (0.01 : ℝ) ^ 2 / 0.18)) :
    (120 : ℝ) ≤ (n : ℝ) := by
  have h := prime_blocks_needed 0.2 0.01 n (by norm_num) hcover
  norm_num at h
  linarith

end Catalog.Novelty.PhaseFeatureLeakageSplit