/-
# The Uncanny Valley of Mathematics

The "uncanny valley" (Mori, 1970) describes how *acceptance* of a robot rises
with its human-likeness, then drops sharply as the robot becomes *almost* human,
before recovering once the resemblance is (near-)perfect.

This file formalizes a concrete mathematical model of that acceptance curve and
proves — as a chain of results, each building on the previous — that the model
genuinely exhibits the uncanny-valley shape:

  ascent  →  local peak (the "almost human" acceptance)  →  a strict DROP into a
  valley  →  monotone recovery that eventually *surpasses* the earlier peak.

The model is the cubic

    UV x = x^3 - 3*x   (acceptance as a function of human-likeness x)

whose two clean factorizations

    UV x - 2 = (x - 2)*(x + 1)^2      UV x + 2 = (x - 1)^2*(x + 2)

drive every quantitative claim.  Landmarks:

  * x = -1  : the near-human peak,  UV (-1) = 2
  * x =  1  : the valley bottom,    UV 1     = -2
  * x =  2  : recovery reaches the peak again, UV 2 = 2
  * x >  2  : full recovery, acceptance strictly exceeds the near-human peak.

All results are elementary and self-contained (`ring` / `nlinarith`), so the file
compiles independently.
-/
import Mathlib

namespace UncannyValley

/-- The acceptance curve: `UV x = x³ - 3x`, modelling acceptance of an artifact
as a function of its human-likeness `x`. -/
noncomputable def UV (x : ℝ) : ℝ := x ^ 3 - 3 * x

/-! ## Foundational identity

Every monotonicity statement is a corollary of a single algebraic identity for the
difference quotient of `UV`. -/

/-- The core difference identity: `UV b - UV a` factors through the symmetric
quadratic `a² + ab + b² - 3`.  This is the engine for all monotonicity results. -/
theorem uv_diff (a b : ℝ) :
    UV b - UV a = (b - a) * (a ^ 2 + a * b + b ^ 2 - 3) := by
  unfold UV; ring

/-! ## The three landmark values -/

/-- Acceptance at the near-human peak `x = -1`. -/
theorem uv_peak_value : UV (-1) = 2 := by unfold UV; norm_num

/-- Acceptance at the bottom of the valley `x = 1`. -/
theorem uv_valley_value : UV 1 = -2 := by unfold UV; norm_num

/-- Acceptance at the recovery point `x = 2`, equal to the near-human peak. -/
theorem uv_recovery_value : UV 2 = 2 := by unfold UV; norm_num

/-! ## Monotonicity on the three regimes

The domain `ℝ` splits at the critical points `-1` and `1` into three regimes on
which `UV` is strictly monotone. -/

/-- **Ascent.** On `(-∞, -1]` acceptance strictly increases with human-likeness:
the further from human, the lower the acceptance. -/
theorem uv_increasing_ascent {a b : ℝ} (hb : b ≤ -1) (hab : a < b) : UV a < UV b := by
  have hq : 3 < a ^ 2 + a * b + b ^ 2 := by nlinarith
  have := uv_diff a b
  nlinarith [mul_pos (by linarith : (0 : ℝ) < b - a)
      (by linarith : (0 : ℝ) < a ^ 2 + a * b + b ^ 2 - 3)]

/-- **The uncanny descent.** On `[-1, 1]` acceptance strictly *decreases*: as the
artifact becomes almost human, acceptance falls. -/
theorem uv_decreasing_valley {a b : ℝ} (ha : -1 ≤ a) (hb : b ≤ 1) (hab : a < b) :
    UV b < UV a := by
  have hq : a ^ 2 + a * b + b ^ 2 < 3 := by
    nlinarith [mul_nonneg (by linarith : (0 : ℝ) ≤ a + 1) (by linarith : (0 : ℝ) ≤ 1 - b),
      sq_nonneg (a - b)]
  have := uv_diff a b
  nlinarith [mul_pos (by linarith : (0 : ℝ) < b - a)
      (by linarith : (0 : ℝ) < 3 - (a ^ 2 + a * b + b ^ 2))]

/-- **Recovery.** On `[1, ∞)` acceptance strictly increases again. -/
theorem uv_increasing_recovery {a b : ℝ} (ha : 1 ≤ a) (hab : a < b) : UV a < UV b := by
  have hq : 3 < a ^ 2 + a * b + b ^ 2 := by nlinarith
  have := uv_diff a b
  nlinarith [mul_pos (by linarith : (0 : ℝ) < b - a)
      (by linarith : (0 : ℝ) < a ^ 2 + a * b + b ^ 2 - 3)]

/-! ## The uncanny valley, quantified -/

/-- **The drop.** The valley bottom lies strictly below the near-human peak: the
hallmark of the uncanny valley.  Derived from the descent on `[-1, 1]`. -/
theorem uncanny_valley_drop : UV 1 < UV (-1) :=
  uv_decreasing_valley (le_refl _) (le_refl _) (by norm_num)

/-- Just past the peak, acceptance is already below it: `UV x < UV (-1)` for every
`x` strictly inside `(-1, 1]`. -/
theorem uv_below_peak {x : ℝ} (hx1 : -1 < x) (hx2 : x ≤ 1) : UV x < UV (-1) :=
  uv_decreasing_valley (le_refl _) hx2 hx1

/-- **Full recovery.** Beyond `x = 2`, acceptance strictly exceeds the near-human
peak: perfected resemblance is *more* accepted than the almost-human artifact.
Uses the factorization `UV x - 2 = (x - 2)(x + 1)²` together with the peak value. -/
theorem uv_full_recovery {x : ℝ} (hx : 2 < x) : UV (-1) < UV x := by
  have hfac : UV x - 2 = (x - 2) * (x + 1) ^ 2 := by unfold UV; ring
  rw [uv_peak_value]
  nlinarith [mul_pos (by linarith : (0 : ℝ) < x - 2)
      (by positivity : (0 : ℝ) < (x + 1) ^ 2)]

/-- The valley bottom is a global minimum of acceptance on `[-2, ∞)`:
`UV x ≥ UV 1` there, via `UV x + 2 = (x - 1)²(x + 2)`. -/
theorem uv_valley_is_min {x : ℝ} (hx : -2 ≤ x) : UV 1 ≤ UV x := by
  have hfac : UV x + 2 = (x - 1) ^ 2 * (x + 2) := by unfold UV; ring
  rw [uv_valley_value]
  nlinarith [mul_nonneg (sq_nonneg (x - 1)) (by linarith : (0 : ℝ) ≤ x + 2)]

/-! ## Capstone: the curve has the uncanny-valley shape -/

/-- **Uncanny-valley shape theorem.**  There are three landmarks
`x₀ = -1 < x₁ = 1 < x₂ = 3` such that the acceptance curve `UV`

* rises up to the near-human peak `x₀` (ascent),
* then *drops* strictly from `x₀` into the valley bottom `x₁`,
* then rises again from `x₁` onward,
* with the fully-human point `x₂` strictly *surpassing* the near-human peak.

This packages the whole chain (`uv_increasing_ascent`, `uncanny_valley_drop`,
`uv_increasing_recovery`, `uv_full_recovery`) into one statement, certifying that
the model reproduces Mori's uncanny valley. -/
theorem uncanny_valley_shape :
    ∃ x₀ x₁ x₂ : ℝ, x₀ < x₁ ∧ x₁ < x₂ ∧
      -- (1) ascent toward the near-human peak
      (∀ a b : ℝ, a < b → b ≤ x₀ → UV a < UV b) ∧
      -- (2) the uncanny descent from peak into the valley
      (∀ a b : ℝ, x₀ ≤ a → a < b → b ≤ x₁ → UV b < UV a) ∧
      -- (3) recovery from the valley onward
      (∀ a b : ℝ, x₁ ≤ a → a < b → UV a < UV b) ∧
      -- (4) the strict drop: valley bottom below the near-human peak
      UV x₁ < UV x₀ ∧
      -- (5) full recovery: the fully-human point surpasses the near-human peak
      UV x₀ < UV x₂ := by
  refine ⟨-1, 1, 3, by norm_num, by norm_num, ?_, ?_, ?_, ?_, ?_⟩
  · intro a b hab hb; exact uv_increasing_ascent hb hab
  · intro a b ha hab hb; exact uv_decreasing_valley ha hb hab
  · intro a b ha hab; exact uv_increasing_recovery ha hab
  · exact uncanny_valley_drop
  · exact uv_full_recovery (by norm_num)

end UncannyValley