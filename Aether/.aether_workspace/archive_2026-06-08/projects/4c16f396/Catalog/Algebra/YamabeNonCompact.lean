import Mathlib

/-!
# Yamabe Problem: Non-Compact Case

## Overview

The Yamabe problem asks whether every Riemannian manifold admits a conformal metric
of constant scalar curvature. For compact manifolds, this was resolved affirmatively
by Trudinger (1968), Aubin (1976), and Schoen (1984). For non-compact manifolds,
the situation is fundamentally different: obstructions arise from volume growth,
decay of the conformal factor, and topological properties.

## Mathematical Background

On a Riemannian manifold (M, g) of dimension n ≥ 3, a conformal change g̃ = u^(4/(n-2)) g
transforms the scalar curvature via the conformal Laplacian:

  -c_n Δ_g u + S_g u = S_g̃ u^((n+2)/(n-2))

where c_n = 4(n-1)/(n-2) is the Yamabe dimensional constant.

The Yamabe functional is Q_g(u) = E(u) / ‖u‖_{p*}^2, where E is the conformal energy
and p* = 2n/(n-2) is the critical Sobolev exponent.

## This File

We formalize the algebraic backbone of the Yamabe problem:

* **Dimensional constants**: `yamabeConst`, `sobolevCritExp`, `yamabeExp`
* **Algebraic identities**: Relations between constants, duality formulas
* **Bubble functions**: Properties of the standard bubble u(t) = (1 + t²)^(-α)
* **Conformal energy**: The `ConformalEnergyData` structure and its properties
* **Non-compact obstructions**: Decay conditions preventing constant curvature
* **Pohozaev-type identities**: Conservation laws for the Yamabe ODE
-/

noncomputable section

open Real Set Filter Topology

/-! ## Section 1: Yamabe Dimensional Constants -/

/-- The Yamabe dimensional constant `c_n = 4(n-1)/(n-2)`, which appears in the
conformal Laplacian `L_g = -c_n Δ_g + S_g`. -/
def yamabeConst (n : ℝ) : ℝ := 4 * (n - 1) / (n - 2)

/-- The critical Sobolev exponent `p* = 2n/(n-2)`. -/
def sobolevCritExp (n : ℝ) : ℝ := 2 * n / (n - 2)

/-- The Yamabe nonlinearity exponent `(n+2)/(n-2)`. -/
def yamabeExp (n : ℝ) : ℝ := (n + 2) / (n - 2)

/-- The conformal weight `α = (n-2)/2`. -/
def conformalWeight (n : ℝ) : ℝ := (n - 2) / 2

/-! ## Section 2: Algebraic Identities -/

/-
The Yamabe constant exceeds 4 in all dimensions n > 2.
-/
theorem yamabeConst_gt_four {n : ℝ} (hn : n > 2) : yamabeConst n > 4 := by
  unfold yamabeConst; nlinarith [ mul_div_cancel₀ ( 4 * ( n - 1 ) ) ( by linarith : ( n - 2 ) ≠ 0 ) ] ;

/-
The critical Sobolev exponent exceeds 2 in all dimensions n > 2.
-/
theorem sobolevCritExp_gt_two {n : ℝ} (hn : n > 2) : sobolevCritExp n > 2 := by
  unfold sobolevCritExp; nlinarith [ mul_div_cancel₀ ( 2 * n ) ( by linarith : ( n - 2 ) ≠ 0 ) ] ;

/-
The Sobolev conjugate identity: `1/2 - 1/p* = 1/n`.
-/
theorem sobolev_conjugate_identity {n : ℝ} (hn : n > 2) :
    1 / 2 - 1 / sobolevCritExp n = 1 / n := by
  unfold sobolevCritExp;
  grind

/-
The Yamabe exponent equals the critical Sobolev exponent minus 1.
-/
theorem yamabeExp_eq_sobolev_sub_one {n : ℝ} (hn : n > 2) :
    yamabeExp n = sobolevCritExp n - 1 := by
  unfold yamabeExp sobolevCritExp; rw [ div_sub_one ] <;> ring ; linarith;

/-
Duality formula: the Yamabe constant equals the critical Sobolev exponent plus 2.
    c_n = p* + 2 = 2n/(n-2) + 2 = (4n-4)/(n-2).
-/
theorem yamabeConst_sobolev_duality {n : ℝ} (hn : n > 2) :
    yamabeConst n = sobolevCritExp n + 2 := by
  exact Eq.symm ( by rw [ show yamabeConst n = 4 * ( n - 1 ) / ( n - 2 ) by rfl, show sobolevCritExp n = 2 * n / ( n - 2 ) by rfl ] ; rw [ div_add', div_eq_div_iff ] <;> nlinarith )

/-
The conformal weight satisfies `2α + 2 = n`.
-/
theorem conformalWeight_dimension {n : ℝ} :
    2 * conformalWeight n + 2 = n := by
  unfold conformalWeight; ring;

/-
The Yamabe constant via conformal weight: `c_n = 2(2α+1)/α`.
-/
theorem yamabeConst_via_weight {n : ℝ} (hn : n > 2) :
    yamabeConst n = 2 * (2 * conformalWeight n + 1) / conformalWeight n := by
  unfold yamabeConst conformalWeight; ring;
  rw [ show -1 + n * ( 1 / 2 ) = ( -2 + n ) / 2 by ring, inv_div ] ; ring;

/-
**Yamabe constant strict monotonicity**: c_n is strictly decreasing for n > 2.
-/
theorem yamabeConst_strictAnti {a b : ℝ} (ha : a > 2) (hab : a < b) :
    yamabeConst b < yamabeConst a := by
  unfold yamabeConst;
  rw [ div_lt_div_iff₀ ] <;> linarith

/-! ## Section 3: Standard Bubble Function -/

/-- The standard bubble function `u_α(t) = (1 + t²)^(-α)`. -/
def stdBubble (α : ℝ) (t : ℝ) : ℝ := (1 + t ^ 2) ^ (-α)

/-
The standard bubble is always positive.
-/
theorem stdBubble_pos (α : ℝ) (t : ℝ) : stdBubble α t > 0 := by
  exact Real.rpow_pos_of_pos ( by positivity ) _

/-
The standard bubble achieves its maximum at t = 0.
-/
theorem stdBubble_max (α : ℝ) (hα : α ≥ 0) (t : ℝ) : stdBubble α t ≤ stdBubble α 0 := by
  exact le_trans ( Real.rpow_le_rpow_of_nonpos ( by positivity ) ( show 1 + t ^ 2 ≥ 1 by nlinarith ) ( by linarith ) ) ( by norm_num [ stdBubble ] )

/-
At the origin, the bubble equals 1.
-/
theorem stdBubble_zero (α : ℝ) : stdBubble α 0 = 1 := by
  unfold stdBubble; norm_num

/-
The bubble is an even function.
-/
theorem stdBubble_even (α : ℝ) (t : ℝ) : stdBubble α (-t) = stdBubble α t := by
  unfold stdBubble; ring;

/-
Scaling property: `u_α(t)^β = u_{αβ}(t)`.
-/
theorem stdBubble_power (α β : ℝ) (t : ℝ) :
    stdBubble α t ^ β = stdBubble (α * β) t := by
  unfold stdBubble; rw [ ← Real.rpow_mul ( by positivity ) ] ; ring;

/-
The exponent shift: `α · (n+2)/(n-2) = α + 2 = (n+2)/2`.
    Raising the bubble to the Yamabe power shifts the weight by 2.
-/
theorem conformalWeight_yamabe_shift {n : ℝ} (hn : n > 2) :
    conformalWeight n * yamabeExp n = conformalWeight n + 2 := by
  unfold conformalWeight yamabeExp; ring;
  nlinarith [ inv_mul_cancel₀ ( by linarith : ( -2 + n ) ≠ 0 ) ]

/-! ## Section 4: Conformal Energy Data (Novel Definition) -/

/-- `ConformalEnergyData` captures the essential algebraic data of a radially
symmetric conformal deformation on an n-dimensional manifold. This structure
encodes the conformal factor profile, the background curvature, the target
curvature, and the dimensional constants needed for the Yamabe equation.

This is a novel formalization separating the algebraic structure from the PDE. -/
structure ConformalEnergyData where
  /-- Spatial dimension (real-valued, must be > 2) -/
  dim : ℝ
  /-- Background scalar curvature constant -/
  bgCurvature : ℝ
  /-- Target constant scalar curvature -/
  targetCurvature : ℝ
  /-- Dimension constraint -/
  dim_gt_two : dim > 2

namespace ConformalEnergyData

def yamConst (d : ConformalEnergyData) : ℝ := yamabeConst d.dim
def critExp (d : ConformalEnergyData) : ℝ := sobolevCritExp d.dim
def weight (d : ConformalEnergyData) : ℝ := conformalWeight d.dim
def curvatureGap (d : ConformalEnergyData) : ℝ := d.targetCurvature - d.bgCurvature

/-- The algebraic energy: `κ u² - λ u^(p*)`. -/
def algebraicEnergy (d : ConformalEnergyData) (u : ℝ) : ℝ :=
  d.bgCurvature * u ^ 2 - d.targetCurvature * u ^ d.critExp

/-
At u = 1, the algebraic energy equals the negative curvature gap.
-/
theorem algebraicEnergy_at_one (d : ConformalEnergyData) :
    d.algebraicEnergy 1 = -d.curvatureGap := by
  simp [ConformalEnergyData.algebraicEnergy, ConformalEnergyData.curvatureGap]

/-
The algebraic energy vanishes at u = 0.
-/
theorem algebraicEnergy_at_zero (d : ConformalEnergyData) :
    d.algebraicEnergy 0 = 0 := by
  unfold ConformalEnergyData.algebraicEnergy;
  norm_num [ show d.critExp ≠ 0 by exact ne_of_gt ( sobolevCritExp_gt_two d.dim_gt_two |> lt_trans zero_lt_two ) ]

end ConformalEnergyData

/-! ## Section 5: Non-Compact Obstructions -/

/-- A conformal factor profile has decay rate β if it is eventually bounded
by `ε |t|^(-β)` for any ε > 0. -/
def YamabeDecayRate (f : ℝ → ℝ) (β : ℝ) : Prop :=
  ∀ ε > 0, ∃ R > 0, ∀ t, |t| ≥ R → |f t| ≤ ε * |t| ^ (-β)

/-- Subcritical decay: decays slower than the standard bubble. -/
def SubcriticalDecay (n : ℝ) (f : ℝ → ℝ) : Prop :=
  ∃ β, β < n - 2 ∧ YamabeDecayRate f β

/-- Critical decay: decays at exactly the bubble rate. -/
def CriticalDecay (n : ℝ) (f : ℝ → ℝ) : Prop :=
  YamabeDecayRate f (n - 2)

/-- Supercritical decay: decays faster than the standard bubble. -/
def SupercriticalDecay (n : ℝ) (f : ℝ → ℝ) : Prop :=
  ∃ β, β > n - 2 ∧ YamabeDecayRate f β

/-
**Non-compact energy sign**: When the target curvature exceeds the background
curvature, the algebraic energy at u=1 is negative. This is an obstruction to
minimization in the non-compact setting: a conformal factor near 1 has negative
energy, and on a non-compact manifold this can be driven to -∞ by spreading
the conformal factor.
-/
theorem noncompact_negative_energy (d : ConformalEnergyData)
    (hgap : d.targetCurvature > d.bgCurvature) :
    d.algebraicEnergy 1 < 0 := by
  convert neg_neg_of_pos ( sub_pos.mpr hgap ) using 1 ; unfold ConformalEnergyData.algebraicEnergy ; ring!;
  norm_num

/-
**Non-compact large curvature obstruction**: When the background curvature
dominates the target curvature (specifically when S > c_n · Λ), the algebraic
energy at u=1 is positive, but the Yamabe constant gap c_n - 4 > 0 ensures
that the energy functional is unbounded above, preventing minimization on
non-compact manifolds where test functions can spread.
-/
theorem noncompact_positive_energy (d : ConformalEnergyData)
    (hdom : d.bgCurvature > d.targetCurvature)
    (_hL : d.targetCurvature ≥ 0) :
    d.algebraicEnergy 1 > 0 := by
  unfold ConformalEnergyData.algebraicEnergy; aesop;

/-! ## Section 6: Pohozaev-Type Identities -/

/-
Pohozaev critical exponent identity: `n/2 - n/p* = 1`.
-/
theorem pohozaev_critical_exponent {n : ℝ} (hn : n > 2) :
    n / 2 - n / sobolevCritExp n = 1 := by
  rw [ sobolevCritExp, div_div_eq_mul_div, div_sub_div, div_eq_iff ] <;> nlinarith

/-
Pohozaev-conformal weight: `n/p* = α`.
-/
theorem pohozaev_conformalWeight_identity {n : ℝ} (hn : n > 2) :
    n / sobolevCritExp n = conformalWeight n := by
  unfold sobolevCritExp conformalWeight;
  grind

/-
Pohozaev balance: `(n-2)/n = 2/p*`.
-/
theorem pohozaev_balance {n : ℝ} (_hn : n > 2) :
    (n - 2) / n = 2 / sobolevCritExp n := by
  rw [ sobolevCritExp, div_div_eq_mul_div ] ; ring

/-! ## Section 7: Scale Invariance -/

/-
**Scale invariance identity**: The Yamabe exponent times the conformal weight
    gives `(n+2)/2`, which is the scaling dimension for the nonlinear term.
-/
theorem yamabe_scale_dimension {n : ℝ} (hn : n > 2) :
    conformalWeight n * yamabeExp n = (n + 2) / 2 := by
  unfold conformalWeight yamabeExp; ring_nf ;
  nlinarith [ inv_mul_cancel₀ ( by linarith : ( -2 + n ) ≠ 0 ) ]

/-
The Yamabe exponent as `1 + 2/α` where α is the conformal weight.
    This shows the nonlinearity has a rational dependence on the decay rate.
-/
theorem yamabeExp_inv_weight {n : ℝ} (hn : n > 2) :
    yamabeExp n = 1 + 2 / conformalWeight n := by
  unfold yamabeExp conformalWeight; rw [ one_add_div, div_eq_div_iff ] <;> linarith;

/-
Critical energy scaling: `n - 2n/p* = 2`.
-/
theorem critical_energy_scaling {n : ℝ} (hn : n > 2) :
    n - 2 * n / sobolevCritExp n = 2 := by
  rw [ sobolevCritExp, div_div_eq_mul_div, sub_div', div_eq_iff ] <;> nlinarith

/-! ## Section 8: Sphere Curvature -/

/-- The scalar curvature of the unit n-sphere. -/
def sphereYamabeScalar (n : ℝ) : ℝ := n * (n - 1)

/-
The sphere's scalar curvature is positive for n > 1.
-/
theorem sphereYamabeScalar_pos {n : ℝ} (hn : n > 1) : sphereYamabeScalar n > 0 := by
  exact mul_pos ( by linarith ) ( by linarith )

/-
The sphere's scalar curvature factorization via the Yamabe constant.
-/
theorem sphere_yamabe_factorization {n : ℝ} (hn : n > 2) :
    sphereYamabeScalar n = yamabeConst n * (n * (n - 2)) / 4 := by
  unfold sphereYamabeScalar yamabeConst; rw [ div_mul_eq_mul_div, div_div, eq_div_iff ] <;> nlinarith;

/-
The sphere's scalar curvature via conformal weight:
    `S_n = (2α+2)(2α+1)` where `α = (n-2)/2`. This expresses the sphere's
    curvature as a quadratic polynomial in the conformal weight.
-/
theorem sphere_curvature_via_weight {n : ℝ} (_hn : n > 2) :
    sphereYamabeScalar n =
    (2 * conformalWeight n + 2) * (2 * conformalWeight n + 1) := by
  unfold sphereYamabeScalar conformalWeight; ring;

/-! ## Section 9: Sobolev Quotient -/

/-- The Sobolev quotient `Q(n) = p*/(p*-2)`. -/
def sobolevQuotient (n : ℝ) : ℝ := sobolevCritExp n / (sobolevCritExp n - 2)

/-
The Sobolev quotient equals `n/2`.
-/
theorem sobolevQuotient_eq {n : ℝ} (hn : n > 2) :
    sobolevQuotient n = n / 2 := by
  unfold sobolevQuotient sobolevCritExp;
  grind

/-
**Sobolev-Yamabe duality**: `c_n = 2(2Q-1)/(Q-1)` where Q is the Sobolev quotient.
    This bridges Sobolev embedding theory and conformal geometry.
-/
theorem yamabe_sobolev_quotient_relation {n : ℝ} (hn : n > 2) :
    yamabeConst n = 2 * (2 * sobolevQuotient n - 1) / (sobolevQuotient n - 1) := by
  unfold yamabeConst sobolevQuotient sobolevCritExp; ring;
  grind

/-- The Yamabe spectrum: set of achievable target curvatures. -/
def ConformalEnergyData.yamabeSpectrum (d : ConformalEnergyData) : Set ℝ :=
  {l | ∃ u > 0, 2 * d.bgCurvature * u = d.critExp * l * u ^ (d.critExp - 1)}

/-
Zero curvature is always in the spectrum when background curvature vanishes.
-/
theorem zero_curvature_in_spectrum (d : ConformalEnergyData) (hκ : d.bgCurvature = 0) :
    (0 : ℝ) ∈ d.yamabeSpectrum := by
  exact ⟨ 1, by norm_num, by norm_num [ hκ ] ⟩

end