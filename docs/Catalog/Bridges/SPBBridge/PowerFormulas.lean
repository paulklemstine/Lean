import Mathlib
import Logic.StrangeLoops.Core
import Bridges.SPBBridge.AlgebraicIdentities

/-!
# SPB Power Formulas and Iterated Application

Closed forms for n-fold SPB (tangent multiple angle formulas).
-/

noncomputable section
open Real SPBResearch

namespace SPBPower

/-- SPB double: spb(t,t) = 2t/(1-t²). -/
theorem spb_double (t : ℝ) : spb t t = 2 * t / (1 - t ^ 2) := by
  unfold spb; ring

/-
SPB triple: spb(spb(t,t), t).
-/
theorem spb_triple (t : ℝ) (h1 : 1 - t ^ 2 ≠ 0) (h2 : 1 - 2 * t / (1 - t ^ 2) * t ≠ 0) :
    spb (spb t t) t = (3 * t - t ^ 3) / (1 - 3 * t ^ 2) := by
  unfold spb; field_simp [h1] ; ring;

/-- SPB quadruple: spb(spb(t,t), spb(t,t)). -/
theorem spb_quadruple (t : ℝ) (h1 : 1 - t ^ 2 ≠ 0)
    (_h2 : (1 - t ^ 2) ^ 2 - 4 * t ^ 2 ≠ 0) :
    spb (spb t t) (spb t t) =
    4 * t * (1 - t ^ 2) / ((1 - t ^ 2) ^ 2 - 4 * t ^ 2) := by
  unfold spb; field_simp; ring

/-- Note: 5·arctan(1/5) ≠ π/4, so there is no "five-fold SPB of 1/5 = 1" identity.
    Machin's formula is 4·arctan(1/5) - arctan(1/239) = π/4, verified elsewhere. -/
theorem spb_four_fifths_value :
    spb (spb (1/5 : ℝ) (1/5)) (spb (1/5) (1/5)) = 120/119 := by
  unfold spb; norm_num

/-- Iterated SPB from 1/2: spb(1/2, 1/2) = 4/3. -/
theorem spb_iter_half : spb (1/2 : ℝ) (1/2) = 4/3 := by
  unfold spb; norm_num

/-- Iterated SPB from 1/3: spb(1/3, 1/3) = 3/4. -/
theorem spb_iter_third : spb (1/3 : ℝ) (1/3) = 3/4 := by
  unfold spb; norm_num

end SPBPower
end