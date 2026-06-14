/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Tightness and Energy-Free Schedules for the Logarithmic Hodge Depth Clock

This file *completes* the depth–accuracy theory begun in
`Catalog/Speculative/AutoResearch/HodgeDepthLogarithmic.lean`.  There the explicit depth
`hodgeDepth ρ E ε = ⌈log_ρ (ε / E)⌉₊` was proved *sufficient* to drive the residual
Dirichlet energy of a `ρ`-contracting layer below a tolerance `ε`
(`hodgeDepth_residual_bound`).  Two questions were left open and are settled here.

1. **Tightness (Research Direction 3).**  Is the logarithmic depth also *necessary*?  For a
   worst-case input that saturates the geometric decay with *equality*
   (`‖Tᵏ x‖² = ρᵏ ‖x‖²` — the bottom non-harmonic eigenvector), every layer strictly below
   `hodgeDepth` leaves residual energy `> ε`.  Hence `hodgeDepth` is the *exact* minimal
   depth, not merely an upper bound (`hodgeDepth_tight`).  The analytic engine is the exact
   mirror of `pow_le_of_logb_le`: the converse `pow_gt_of_logb_lt`.

2. **Energy-free schedules (Research Direction 5).**  For a decreasing tolerance schedule the
   *incremental* depth needed to pass from `ε₁` to `ε₂` depends only on the **ratio**
   `ε₂ / ε₁`, not on the signal energy `E`: the energy cancels in the continuous depth law
   (`logb_depth_energy_cancel`), so adaptive-smoothing networks add layers in batches sized by
   geometric tolerance ratios (`hodgeDepth_increment_le`).

## Main results

* `pow_gt_of_logb_lt`        — analytic converse: `N < log_ρ c ⇒ c < ρᴺ` for `0<ρ<1`.
* `hodgeDepth_tight`         — on a saturating input every depth `< hodgeDepth` overshoots `ε`.
* `logb_depth_energy_cancel` — the continuous depth law is energy-free: it depends only on `ε₂/ε₁`.
* `hodgeDepth_increment_le`  — the integer incremental depth is `≤ ⌈log_ρ(ε₂/ε₁)⌉₊` extra layers.
* `hodgeDepth_mono`          — the depth clock is monotone: tighter tolerance never needs fewer layers.

## Catalog synthesis

This realizes **Research Directions 3 and 5** of `HodgeFullDecomposition`/`HodgeDepthLogarithmic`'s
FUTURE_DIRECTIONS.  `pow_gt_of_logb_lt` is the term-by-term converse of
`HodgeDepthLogarithmic.pow_le_of_logb_le`, and `hodgeDepth_tight` couples it to the saturation
case of `HodgeDepthLogarithmic.quadform_iterate_bound`, turning the sufficient ceiling into a
genuine minimum.  The schedule law isolates the structural fact that `hodgeDepth` is a `⌈log⌉`
of a *quotient*, so energy is a pure additive offset and cancels in differences.
-/
import Mathlib

namespace HodgeDepthSchedule

open Matrix Real

variable {n : ℕ}

/-- The explicit logarithmic depth `⌈log_ρ (ε / E)⌉₊` (mirrors
`HodgeDepthLogarithmic.hodgeDepth`; restated here so this file is self-contained). -/
noncomputable def hodgeDepth (ρ E ε : ℝ) : ℕ := ⌈Real.logb ρ (ε / E)⌉₊

-- !-- Lab Notebook -- !--
-- Hypothesis: The sufficient logarithmic depth `⌈log_ρ(ε/E)⌉₊` is also *necessary* on the
--   worst-case (saturating) input, and the depth *schedule* between two tolerances is
--   governed only by their ratio, independent of the signal energy.
-- Result: All five statements are proven sorry-free.  `hodgeDepth_tight` shows the ceiling
--   is a genuine minimum; `logb_depth_energy_cancel` shows energy cancels exactly in the
--   continuous law; `hodgeDepth_increment_le` ports this to the integer depth via ceiling
--   sub-additivity (`Nat.ceil_add_le`) — no rounding slack beyond the single ceiling.
-- Insight: `Nat.lt_ceil : n < ⌈a⌉₊ ↔ (n:ℝ) < a` is the precise bridge that converts the
--   integer hypothesis `k < hodgeDepth` into the real hypothesis `(k:ℝ) < log_ρ(ε/E)`
--   needed by the analytic converse `pow_gt_of_logb_lt`.  The sign of `log ρ < 0` again
--   flips every inequality, so `lt_div_iff_of_neg` mirrors `div_le_iff_of_neg` exactly.
-- Failure analysis: an *exact* increment equality `D ε₂ = D ε₁ + ⌈log_ρ(ε₂/ε₁)⌉` is FALSE:
--   two independent `⌈·⌉` operations cannot generally be merged (only sub-additivity holds),
--   so the honest integer statement is the `≤` bound, while the clean *equality* lives at
--   the continuous (`logb`) level where no rounding occurs (`logb_depth_energy_cancel`).
-- !-- end Lab Notebook -- !--

-- !-- Analytic converse of `pow_le_of_logb_le`.  Take logs: `N < log_ρ c = log c / log ρ`
--    with `log ρ < 0`, so `lt_div_iff_of_neg` flips it to `N·log ρ > log c`, i.e.
--    `log(ρᴺ) > log c`, hence `ρᴺ > c`. -- !--
theorem pow_gt_of_logb_lt (ρ c : ℝ) (h0 : 0 < ρ) (h1 : ρ < 1) (hc : 0 < c) (N : ℕ)
    (hN : (N : ℝ) < Real.logb ρ c) : c < ρ ^ N := by
  have hlogρ : Real.log ρ < 0 := Real.log_neg h0 h1
  rw [Real.logb, lt_div_iff_of_neg hlogρ] at hN
  have hkey : Real.log c < Real.log (ρ ^ N) := by rw [Real.log_pow]; exact_mod_cast hN
  have hpos : (0:ℝ) < ρ ^ N := pow_pos h0 N
  exact (Real.log_lt_log_iff hc hpos).mp hkey

-- !-- Tightness.  On a saturating input (`‖Tᵏx‖² = ρᵏ‖x‖²`), `k < hodgeDepth` unfolds via
--    `Nat.lt_ceil` to `(k:ℝ) < log_ρ(ε/E)`, then `pow_gt_of_logb_lt` gives `ρᵏ > ε/E`, so
--    the residual `ρᵏ E > ε`. -- !--
theorem hodgeDepth_tight (T : (Fin n → ℝ) → (Fin n → ℝ)) (ρ : ℝ)
    (h0 : 0 < ρ) (h1 : ρ < 1)
    (x : Fin n → ℝ) (hx : 0 < x ⬝ᵥ x)
    (hsat : ∀ k, (T^[k] x) ⬝ᵥ (T^[k] x) = ρ ^ k * (x ⬝ᵥ x))
    (ε : ℝ) (hε : 0 < ε) :
    ∀ k, k < hodgeDepth ρ (x ⬝ᵥ x) ε → ε < (T^[k] x) ⬝ᵥ (T^[k] x) := by
  intro k hk
  have hcpos : 0 < ε / (x ⬝ᵥ x) := div_pos hε hx
  have hreal : (k : ℝ) < Real.logb ρ (ε / (x ⬝ᵥ x)) := by
    rw [hodgeDepth, Nat.lt_ceil] at hk; exact hk
  have hpk : ε / (x ⬝ᵥ x) < ρ ^ k := pow_gt_of_logb_lt ρ _ h0 h1 hcpos k hreal
  rw [hsat k, div_lt_iff₀ hx] at *
  linarith [hpk]

-- !-- Energy-free continuous depth law.  Expand each `logb` as `log/log ρ` and split the
--    quotient logs with `Real.log_div`; the `log E` terms cancel, leaving `log_ρ(ε₂/ε₁)`. -- !--
theorem logb_depth_energy_cancel (ρ E ε₁ ε₂ : ℝ) (hE : 0 < E) (h1 : 0 < ε₁) (h2 : 0 < ε₂) :
    Real.logb ρ (ε₂ / E) - Real.logb ρ (ε₁ / E) = Real.logb ρ (ε₂ / ε₁) := by
  rw [Real.logb, Real.logb, Real.logb, Real.log_div (by positivity) (ne_of_gt hE),
      Real.log_div (by positivity) (ne_of_gt hE), Real.log_div (by positivity) (ne_of_gt h1)]
  field_simp
  ring

-- !-- Energy-free integer schedule.  Rewrite `log_ρ(ε₂/E)` as `log_ρ(ε₁/E) + log_ρ(ε₂/ε₁)`
--    via the cancellation above, then apply ceiling sub-additivity `Nat.ceil_add_le`.  Hence
--    the extra layers depend only on the tolerance *ratio*, not on the energy `E`. -- !--
theorem hodgeDepth_increment_le (ρ E ε₁ ε₂ : ℝ) (hE : 0 < E) (h1 : 0 < ε₁) (h2 : 0 < ε₂) :
    hodgeDepth ρ E ε₂ ≤ hodgeDepth ρ E ε₁ + ⌈Real.logb ρ (ε₂ / ε₁)⌉₊ := by
  have hcancel : Real.logb ρ (ε₂ / E) = Real.logb ρ (ε₁ / E) + Real.logb ρ (ε₂ / ε₁) := by
    rw [Real.logb, Real.logb, Real.logb, Real.log_div (by positivity) (ne_of_gt hE),
        Real.log_div (by positivity) (ne_of_gt hE), Real.log_div (by positivity) (ne_of_gt h1)]
    field_simp; ring
  unfold hodgeDepth
  rw [hcancel]
  exact Nat.ceil_add_le _ _

-- !-- Monotonicity of the depth clock in the tolerance.  For `0<ρ<1`, `log_ρ` is decreasing,
--    so a smaller `ε` gives a larger `log_ρ(ε/E)`, and `⌈·⌉₊` is monotone. -- !--
theorem hodgeDepth_mono (ρ E ε₁ ε₂ : ℝ) (h0 : 0 < ρ) (h1 : ρ < 1) (hE : 0 < E)
    (hpos : 0 < ε₂) (hle : ε₂ ≤ ε₁) :
    hodgeDepth ρ E ε₁ ≤ hodgeDepth ρ E ε₂ := by
  have hlogρ : Real.log ρ < 0 := Real.log_neg h0 h1
  unfold hodgeDepth
  apply Nat.ceil_le_ceil
  rw [Real.logb, Real.logb]
  apply (div_le_div_right_of_neg hlogρ).mpr
  apply Real.log_le_log (by positivity)
  gcongr

end HodgeDepthSchedule