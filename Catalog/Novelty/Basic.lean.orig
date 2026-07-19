import Mathlib

/-!
# Two-dimensional Newtonian gravity

This file formalizes the radial calculus behind planar Newtonian gravity.  It also
records an important correction to the motivating claim: the logarithmic force
law does have stable circular orbits.  What fails is Bertrand closure: the
linearized radial and angular frequencies have irrational ratio `√2`.
-/

open Real

namespace FlatlandGravity

/-- The potential energy per test body for attractive planar Newtonian gravity. -/
noncomputable def potential (k r : ℝ) : ℝ := k * Real.log r

/-- The radial force associated with the planar potential. -/
noncomputable def radialForce (k r : ℝ) : ℝ := -k / r

/-- The effective radial potential, including the centrifugal term. -/
noncomputable def effectivePotential (k m ell r : ℝ) : ℝ :=
  potential k r + ell ^ 2 / (2 * m * r ^ 2)

/-
The logarithmic potential has derivative `k/r`, hence force `-k/r`.
-/
theorem hasDerivAt_potential {k r : ℝ} (hr : r ≠ 0) :
    HasDerivAt (potential k) (k / r) r := by
  convert HasDerivAt.const_mul k ( Real.hasDerivAt_log hr ) using 1

/-
The force is the negative derivative of the logarithmic potential.
-/
theorem force_eq_neg_potential_deriv {k r : ℝ} (hr : r ≠ 0) :
    HasDerivAt (potential k) (-radialForce k r) r := by
  convert hasDerivAt_potential hr using 1 ; unfold radialForce ; ring

/-
First derivative of the effective radial potential.
-/
theorem hasDerivAt_effectivePotential {k m ell r : ℝ} (hm : m ≠ 0) (hr : r ≠ 0) :
    HasDerivAt (effectivePotential k m ell)
      (k / r - ell ^ 2 / (m * r ^ 3)) r := by
  convert HasDerivAt.add ( hasDerivAt_potential hr ) ( HasDerivAt.div ( hasDerivAt_const _ _ ) ( HasDerivAt.mul ( hasDerivAt_const _ _ ) ( hasDerivAt_pow 2 r ) ) _ ) using 1 <;> ring ; norm_num [ hm, hr ];
  · -- By simplifying, we can see that the two expressions are equal.
    field_simp
    ring;
  · norm_num [ hm, hr ]

/-
Algebraic characterization of a circular orbit (a critical point of the
 effective potential).
-/
theorem circular_critical_iff {k m ell r : ℝ}
    (hm : m ≠ 0) (hr : r ≠ 0) :
    k / r - ell ^ 2 / (m * r ^ 3) = 0 ↔ ell ^ 2 = m * k * r ^ 2 := by
  grind

/-- Second derivative expression for the effective potential. -/
noncomputable def effectiveSecondDeriv (k m ell r : ℝ) : ℝ :=
  -k / r ^ 2 + 3 * ell ^ 2 / (m * r ^ 4)

/-
At a circular orbit, the effective second derivative is `2k/r²`.
-/
theorem effectiveSecondDeriv_at_circular {k m ell r : ℝ}
    (hm : m ≠ 0) (hr : r ≠ 0) (hcirc : ell ^ 2 = m * k * r ^ 2) :
    effectiveSecondDeriv k m ell r = 2 * k / r ^ 2 := by
  unfold effectiveSecondDeriv; ring;
  grind

/-
Contrary to the motivating “no stable circular orbit” claim, every circular
orbit with positive coupling and positive radius is linearly stable.
-/
theorem circular_orbit_stable {k m ell r : ℝ}
    (hk : 0 < k) (hm : m ≠ 0) (hr : 0 < r)
    (hcirc : ell ^ 2 = m * k * r ^ 2) :
    0 < effectiveSecondDeriv k m ell r := by
  convert div_pos ( mul_pos zero_lt_two hk ) ( sq_pos_of_pos hr ) using 1 ; rw [ effectiveSecondDeriv_at_circular ] <;> aesop

/-- Linearized radial frequency squared at a circular orbit. -/
noncomputable def radialFrequencySq (k m r : ℝ) : ℝ := 2 * k / (m * r ^ 2)

/-- Angular frequency squared at a circular orbit. -/
noncomputable def angularFrequencySq (k m r : ℝ) : ℝ := k / (m * r ^ 2)

/-
The radial epicyclic frequency squared is twice the angular frequency squared.
-/
theorem radialFrequencySq_eq_two_mul_angular (k m r : ℝ) :
    radialFrequencySq k m r = 2 * angularFrequencySq k m r := by
  exact show 2 * k / ( m * r ^ 2 ) = 2 * ( k / ( m * r ^ 2 ) ) by ring;

/-
The positive frequencies therefore have ratio `√2`.
-/
theorem radialFrequency_eq_sqrtTwo_mul_angular {omegaR omegaTheta : ℝ}
    (hTheta : 0 < omegaTheta)
    (hR : 0 ≤ omegaR)
    (hsq : omegaR ^ 2 = 2 * omegaTheta ^ 2) :
    omegaR = Real.sqrt 2 * omegaTheta := by
  rw [ ← sq_eq_sq₀ ?_ ?_ ] <;> first | positivity | rw [ hsq, mul_pow, Real.sq_sqrt ] ; linarith;

/-
Irrationality of `√2` prevents exact commensurability of the two positive
frequencies.  This is the linearized Bertrand-closure obstruction.
-/
theorem no_frequency_commensurability {omegaR omegaTheta : ℝ}
    (hTheta : 0 < omegaTheta)
    (hR : 0 ≤ omegaR)
    (hsq : omegaR ^ 2 = 2 * omegaTheta ^ 2) :
    ¬ ∃ p q : ℕ, 0 < p ∧ 0 < q ∧ (p : ℝ) * omegaR = (q : ℝ) * omegaTheta := by
  -- By assumption, we have omegaR = sqrt(2) * omegaTheta.
  have h_ratio : omegaR = Real.sqrt 2 * omegaTheta := by
    rw [ ← sq_eq_sq₀ ?_ ?_ ] <;> first | positivity | rw [ hsq, mul_pow, Real.sq_sqrt ] ; linarith;
  simp_all +decide [mul_comm, mul_left_comm]
  exact fun x hx y hy => ⟨ fun h => irrational_sqrt_two <| ⟨ y / x, by push_cast; rw [ ← h, mul_div_cancel_left₀ _ <| by positivity ] ⟩, hTheta.ne' ⟩

/-
Combined diagnosis: planar gravity has stable circular motion, but its
linearized radial and angular oscillations cannot share an integer period.
-/
theorem flatland_diagnosis {k m ell r omegaR omegaTheta : ℝ}
    (hk : 0 < k) (hm : m ≠ 0) (hr : 0 < r)
    (hcirc : ell ^ 2 = m * k * r ^ 2)
    (hTheta : 0 < omegaTheta) (hR : 0 ≤ omegaR)
    (hsq : omegaR ^ 2 = 2 * omegaTheta ^ 2) :
    0 < effectiveSecondDeriv k m ell r ∧
      ¬ ∃ p q : ℕ, 0 < p ∧ 0 < q ∧ (p : ℝ) * omegaR = (q : ℝ) * omegaTheta := by
  convert circular_orbit_stable hk hm hr hcirc using 1;
  exact ⟨ fun h => h.1, fun h => ⟨ h, no_frequency_commensurability hTheta hR hsq ⟩ ⟩

end FlatlandGravity