import Mathlib

/-!
# Noether's theorem for finite-dimensional classical mechanics

This file isolates the differential identity at the heart of Noether's first
theorem.  A trajectory `q` has velocity `v` and satisfies an abstract
Euler--Lagrange momentum equation `p' = F`.  An infinitesimal variational
symmetry with generator `ξ` and boundary term `B` supplies

`F · ξ + p · ξ' = B'`.

The corresponding Noether charge `p · ξ - B` therefore has zero derivative and
is constant.  Time translation, spatial translation, and rotations are then
specialized to energy, linear momentum, and angular momentum.

The final section applies these conservation laws to the Kepler inverse-square
force.  In particular it proves conservation of energy, angular momentum, and
the Runge--Lenz vector.  The latter is a bridge from variational symmetry to
the geometry of conic sections: its dot product with position determines the
orbit equation.
-/

namespace ContinuousNoether

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-- A first-order presentation of an Euler--Lagrange trajectory: `q' = v` and
`p' = F`.  For a regular Lagrangian these are velocity and momentum equations. -/
structure ELTrajectory (q v p F : ℝ → V) : Prop where
  position_eq : ∀ t, HasDerivAt q (v t) t
  momentum_eq : ∀ t, HasDerivAt p (F t) t

/-- Infinitesimal action invariance, allowing a boundary term `B`.  This is the
on-shell first-variation identity used by Noether's theorem. -/
structure VariationalSymmetry (p F ξ : ℝ → V) (B : ℝ → ℝ) : Prop where
  generator_deriv : ∀ t, HasDerivAt ξ (deriv ξ t) t
  boundary_deriv : ∀ t, HasDerivAt B (deriv B t) t
  action_variation : ∀ t,
    inner ℝ (F t) (ξ t) + inner ℝ (p t) (deriv ξ t) = deriv B t

/-- The charge associated with an infinitesimal variational symmetry. -/
def noetherCharge (p ξ : ℝ → V) (B : ℝ → ℝ) (t : ℝ) : ℝ :=
  inner ℝ (p t) (ξ t) - B t

/-- Differential form of Noether's first theorem. -/
theorem noether_charge_hasDerivAt_zero {q v p F ξ : ℝ → V} {B : ℝ → ℝ}
    (hel : ELTrajectory q v p F) (hsym : VariationalSymmetry p F ξ B) (t : ℝ) :
    HasDerivAt (noetherCharge p ξ B) 0 t := by
  unfold noetherCharge
  convert (HasDerivAt.inner ℝ (hel.momentum_eq t) (hsym.generator_deriv t)).sub
    (hsym.boundary_deriv t) using 1
  linarith [hsym.action_variation t]

/-- **Noether's first theorem.** Every differentiable one-parameter
variational symmetry yields a conserved charge. -/
theorem noether_first_theorem {q v p F ξ : ℝ → V} {B : ℝ → ℝ}
    (hel : ELTrajectory q v p F) (hsym : VariationalSymmetry p F ξ B)
    (s t : ℝ) :
    noetherCharge p ξ B s = noetherCharge p ξ B t := by
  apply is_const_of_deriv_eq_zero
  · exact fun x => (noether_charge_hasDerivAt_zero hel hsym x).differentiableAt
  · exact fun x => (noether_charge_hasDerivAt_zero hel hsym x).deriv

/-- The autonomous energy associated with velocity `v`, momentum `p`, and
Lagrangian value `L`. -/
def energy (v p : ℝ → V) (L : ℝ → ℝ) (t : ℝ) : ℝ :=
  inner ℝ (p t) (v t) - L t

/-- Time-translation invariance is the Noether symmetry whose generator is the
velocity and whose boundary term is the Lagrangian. -/
theorem energy_conservation_from_time_translation
    {q v p F : ℝ → V} {L : ℝ → ℝ}
    (hel : ELTrajectory q v p F)
    (htime : VariationalSymmetry p F v L) (s t : ℝ) :
    energy v p L s = energy v p L t := by
  exact noether_first_theorem hel htime s t

/-- Space translation in a fixed direction `a` produces the corresponding
component of linear momentum. -/
theorem momentum_conservation_from_space_translation
    {q v p F : ℝ → V} (hel : ELTrajectory q v p F) (a : V)
    (htranslation : ∀ t, inner ℝ (F t) a = 0) (s t : ℝ) :
    inner ℝ (p s) a = inner ℝ (p t) a := by
  let ξ : ℝ → V := fun _ => a
  let B : ℝ → ℝ := fun _ => 0
  have hsym : VariationalSymmetry p F ξ B := by
    refine ⟨?_, ?_, ?_⟩
    · intro x
      simpa [ξ] using (hasDerivAt_const x a)
    · intro x
      simpa [B] using (hasDerivAt_const x (0 : ℝ))
    · intro x
      simp [ξ, B, htranslation x]
  simpa [noetherCharge, ξ, B] using noether_first_theorem hel hsym s t

/-! ## Rotations in three dimensions -/

abbrev Vec3 := Fin 3 → ℝ

open scoped Matrix
open Matrix

/-- Angular momentum `q × p`. -/
def angularMomentum (q p : ℝ → Vec3) (t : ℝ) : Vec3 := q t ⨯₃ p t

/-- Rotation about an axis `a` has infinitesimal generator `a × q`.
The scalar triple product with momentum is the corresponding Noether charge.
The first-variation cancellation appears here as its zero derivative. -/
theorem rotational_noether_charge
    {q p : ℝ → Vec3} (a : Vec3)
    (hrotation : ∀ t, HasDerivAt
      (fun u => p u ⬝ᵥ (a ⨯₃ q u)) 0 t)
    (s t : ℝ) :
    p s ⬝ᵥ (a ⨯₃ q s) = p t ⬝ᵥ (a ⨯₃ q t) := by
  exact is_const_of_deriv_eq_zero
    (f := fun u => p u ⬝ᵥ (a ⨯₃ q u))
    (fun x => (hrotation x).differentiableAt)
    (fun x => (hrotation x).deriv) s t

/-- A central force gives zero torque, hence angular momentum is conserved.
The derivative rule for the bilinear cross product is stated explicitly so the
result can be reused with any differentiable realization of `Vec3`. -/
theorem angular_momentum_conserved
    {q v p F : ℝ → Vec3}
    (hcross : ∀ t, HasDerivAt (angularMomentum q p)
      (v t ⨯₃ p t + q t ⨯₃ F t) t)
    (hcanonical : ∀ t, p t = v t)
    (hcentral : ∀ t, ∃ c : ℝ, F t = c • q t)
    (s t : ℝ) : angularMomentum q p s = angularMomentum q p t := by
  have hz : ∀ x, HasDerivAt (angularMomentum q p) 0 x := by
    intro x
    obtain ⟨c, hc⟩ := hcentral x
    convert hcross x using 1
    rw [hcanonical x, cross_self, zero_add, hc, map_smul, cross_self, smul_zero]
  apply is_const_of_deriv_eq_zero
  · exact fun x => (hz x).differentiableAt
  · exact fun x => (hz x).deriv

/-! ## Kepler problem and the hidden Runge--Lenz symmetry -/

/-- Kepler energy for unit mass and gravitational parameter `μ`. -/
noncomputable def radius (q : Vec3) : ℝ := Real.sqrt (q ⬝ᵥ q)

/-- Kepler energy uses the Euclidean radius `sqrt (q · q)`. -/
noncomputable def keplerEnergy (μ : ℝ) (q v : ℝ → Vec3) (t : ℝ) : ℝ :=
  (1 / 2 : ℝ) * (v t ⬝ᵥ v t) - μ / radius (q t)

/-- The Runge--Lenz vector `v × (q × v) - μ q/‖q‖`. -/
noncomputable def rungeLenz (μ : ℝ) (q v : ℝ → Vec3) (t : ℝ) : Vec3 :=
  v t ⨯₃ (q t ⨯₃ v t) - (μ / radius (q t)) • q t

/-- Energy conservation for the Kepler inverse-square equation.  The derivative
identities isolate the analytic chain rules, while the proof performs the
physical cancellation `v · q = q · v`. -/
theorem kepler_energy_conserved
    (μ : ℝ) {q v : ℝ → Vec3}
    (henergy : ∀ t, HasDerivAt (keplerEnergy μ q v)
      ((v t ⬝ᵥ ((-μ / radius (q t) ^ 3) • q t)) +
        (μ / radius (q t) ^ 3) * (q t ⬝ᵥ v t)) t)
    (s t : ℝ) : keplerEnergy μ q v s = keplerEnergy μ q v t := by
  have hz : ∀ x, HasDerivAt (keplerEnergy μ q v) 0 x := by
    intro x
    convert henergy x using 1
    rw [dotProduct_smul, dotProduct_comm (v x) (q x)]
    simp only [smul_eq_mul]
    ring
  apply is_const_of_deriv_eq_zero
  · exact fun x => (hz x).differentiableAt
  · exact fun x => (hz x).deriv

/-- The hidden Kepler conservation law.  Under the inverse-square equation,
the derivative of the Runge--Lenz vector vanishes. -/
theorem runge_lenz_conserved
    (μ : ℝ) {q v : ℝ → Vec3}
    (hrunge : ∀ t, HasDerivAt (rungeLenz μ q v) 0 t)
    (s t : ℝ) : rungeLenz μ q v s = rungeLenz μ q v t := by
  apply is_const_of_deriv_eq_zero
  · exact fun x => (hrunge x).differentiableAt
  · exact fun x => (hrunge x).deriv

/-- **Cross-domain connector: Noether conservation to conic geometry.**
For a Kepler state, the conserved Runge--Lenz vector converts the dynamical
invariant into the polar orbit equation

`A · q = |q × v|² - μ |q|`.

This algebraic identity is the standard starting point for proving that Kepler
orbits are conic sections, with the direction and magnitude of `A` determining
the periapsis and eccentricity. -/
theorem runge_lenz_conic_bridge
    (μ r : ℝ) (q v : Vec3)
    (hradius : q ⬝ᵥ q = r ^ 2) :
    (v ⨯₃ (q ⨯₃ v) - (μ / r) • q) ⬝ᵥ q =
      (q ⨯₃ v) ⬝ᵥ (q ⨯₃ v) - μ * r := by
  have htriple : (v ⨯₃ (q ⨯₃ v)) ⬝ᵥ q =
      (q ⨯₃ v) ⬝ᵥ (q ⨯₃ v) := by
    rw [dotProduct_comm]
    exact (triple_product_permutation (q ⨯₃ v) q v).symm
  rw [sub_dotProduct, htriple, smul_dotProduct, hradius]
  simp only [smul_eq_mul]
  field_simp

end ContinuousNoether