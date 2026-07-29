import Mathlib

/-!
# Wilson's epsilon expansion as a perturbative algebraic model

This file isolates the polynomial data produced by the one- and two-loop
Feynman-diagram calculation for the one-component `φ⁴` theory.  It does not
construct quantum fields or regularized integrals.  Instead, the diagrammatic
coefficients are explicit rational data, and all conclusions about the
truncated renormalization-group flow are proved from them.
-/

namespace WilsonEpsilon

/-- The one-loop truncated beta function, in a normalization where its
quadratic coefficient is `3`. -/
def beta (ε g : ℝ) : ℝ := -ε * g + 3 * g ^ 2

/-- The non-Gaussian (Wilson--Fisher) fixed point of the one-loop flow. -/
noncomputable def wilsonFisher (ε : ℝ) : ℝ := ε / 3

/-- The two-loop truncation of the anomalous dimension as a function of the
renormalized coupling. -/
noncomputable def etaOfCoupling (g : ℝ) : ℝ := g ^ 2 / 6

/-- A concrete encoding of the two equal sunset-diagram contributions after
substitution of the fixed-point coupling. -/
def sunsetWeights : Fin 2 → ℚ := fun _ => 1 / 108

/-- An elementary, self-contained meaning of `f(ε) = O(ε³)` at zero. -/
def IsOrderThreeAtZero (f : ℝ → ℝ) : Prop :=
  ∃ C > 0, ∃ δ > 0, ∀ ε, |ε| < δ → |f ε| ≤ C * |ε| ^ 3

/-- The finite diagram census gives the coefficient `1/54`. -/
theorem sunset_weights_sum : ∑ i, sunsetWeights i = 1 / 54 := by
  norm_num [sunsetWeights, Fin.sum_univ_two]

/-- Substitution of the Wilson--Fisher fixed point into the two-loop anomalous
 dimension gives Wilson's coefficient exactly. -/
theorem eta_at_wilsonFisher (ε : ℝ) :
    etaOfCoupling (wilsonFisher ε) = ε ^ 2 / 54 := by
  simp [etaOfCoupling, wilsonFisher]
  ring

/-- The fixed point obtained from the one-loop diagram is indeed a zero of the
truncated beta function. -/
theorem beta_wilsonFisher (ε : ℝ) : beta ε (wilsonFisher ε) = 0 := by
  simp [beta, wilsonFisher]
  ring

/-- Complete classification of fixed points of the one-loop beta function.
This also guards against silently discarding the Gaussian fixed point. -/
theorem beta_eq_zero_iff (ε g : ℝ) :
    beta ε g = 0 ↔ g = 0 ∨ g = wilsonFisher ε := by
  simp only [beta, wilsonFisher]
  constructor
  · intro h
    have hfac : g * (-ε + 3 * g) = 0 := by
      linarith [h]
    rcases mul_eq_zero.mp hfac with hg | hg
    · exact Or.inl hg
    · right
      field_simp
      linarith
  · rintro (rfl | rfl)
    · ring
    · ring

/-- For `d < 4`, i.e. `ε = 4-d > 0`, the non-Gaussian fixed point is positive
and distinct from the Gaussian fixed point. -/
theorem nontrivial_fixed_point_below_four {d : ℝ} (hd : d < 4) :
    0 < wilsonFisher (4 - d) ∧
    wilsonFisher (4 - d) ≠ 0 ∧
    beta (4 - d) (wilsonFisher (4 - d)) = 0 := by
  have hn : 0 < 4 - d := by linarith
  have hp : 0 < (4 - d) / 3 := div_pos hn (by norm_num)
  refine ⟨?_, ne_of_gt ?_, beta_wilsonFisher (4 - d)⟩
  · simpa [wilsonFisher] using hp
  · simpa [wilsonFisher] using hp

/-- The linearized beta function has positive slope at the non-Gaussian fixed
point when `ε > 0`.  The expression is the formal derivative of `beta`. -/
theorem wilsonFisher_linearization {ε : ℝ} (hε : 0 < ε) :
    -ε + 6 * wilsonFisher ε = ε ∧ 0 < -ε + 6 * wilsonFisher ε := by
  have heq : -ε + 6 * wilsonFisher ε = ε := by
    simp [wilsonFisher]
    ring
  exact ⟨heq, heq.symm ▸ hε⟩

/-- Rigorous propagation of the two-loop result: any omitted contribution of
order three leaves `η(ε) = ε²/54 + O(ε³)`. -/
theorem eta_epsilon_expansion (remainder : ℝ → ℝ)
    (hrem : IsOrderThreeAtZero remainder) :
    IsOrderThreeAtZero
      (fun ε => (etaOfCoupling (wilsonFisher ε) + remainder ε) - ε ^ 2 / 54) := by
  have hfun :
      (fun ε => (etaOfCoupling (wilsonFisher ε) + remainder ε) - ε ^ 2 / 54) =
        remainder := by
    funext ε
    rw [eta_at_wilsonFisher]
    ring
  rw [hfun]
  exact hrem

/-- A bold but false conjecture would assert uniqueness of the beta-function
zero for every `ε`.  The Gaussian and Wilson--Fisher zeros at `ε = 3` provide
an explicit disproof. -/
theorem disprove_unique_fixed_point :
    ¬ ∀ ε : ℝ, ∃! g : ℝ, beta ε g = 0 := by
  intro h
  obtain ⟨x, _hx, huniq⟩ := h 3
  have hz0 : beta 3 0 = 0 := by norm_num [beta]
  have hz1 : beta 3 1 = 0 := by norm_num [beta]
  have he0 := huniq 0 hz0
  have he1 := huniq 1 hz1
  linarith

/-- Another tempting extrapolation is false: the non-Gaussian fixed point is
not positive above four dimensions (`ε < 0`). -/
theorem disprove_positive_fixed_point_above_four :
    ¬ ∀ ε : ℝ, ε < 0 → 0 < wilsonFisher ε := by
  intro h
  have hh := h (-3) (by norm_num)
  norm_num [wilsonFisher] at hh

end WilsonEpsilon