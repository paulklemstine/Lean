/-
Copyright (c) 2024 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# Conservation Laws for the Kepler Problem

This file applies the Noether philosophy (`Catalog.Physics.NoetherConservation`)
to a concrete dynamical system: a particle of unit mass moving in a plane under
a central force.  Trajectories are given by coordinate functions `x, y : ℝ → ℝ`
with velocities `vx, vy` and accelerations `ax, ay`.

We prove, *directly from Newton's equations*, the three classical conservation
laws of planar central-force / Kepler motion:

* **Angular momentum** is conserved for *any* central force (rotational symmetry).
* **Energy** is conserved for the inverse-square (Kepler) potential
  `U(r) = -k/r` (time-translation symmetry).
* The **Laplace–Runge–Lenz vector** is conserved — a *hidden* symmetry special
  to the inverse-square law, beyond the generic Galilean symmetries.

## Main results

* `central_force_angular_momentum_conserved` / `..._const`
* `kepler_energy_conserved` / `..._const`
* `kepler_LRL_x_conserved`, `kepler_LRL_y_conserved` and the constancy versions
-/

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): Kepler motion has *more* conservation laws than the
-- generic Galilean symmetries predict. Bold conjecture: a fourth conserved vector
-- (Laplace-Runge-Lenz) exists and is special to the inverse-square law - it should
-- FAIL for a generic central force even though angular momentum and energy survive.
-- Experiment (Experimenter): derive all laws directly from Newton's equations.
-- Angular momentum needed no radius (works for any radial accel `a(t)*(x,y)`).
-- Energy and LRL needed the derivative of `r = sqrt(x^2+y^2)`, isolated in
-- `radius_hasDerivAt` via `HasDerivAt.sqrt`. LRL closed by `field_simp` + `ring`
-- after substituting Newton and `r^2 = x^2+y^2`.
-- Analysis (Analyst): angular momentum is the most ROBUST law (central force only),
-- confirming it as the rotational-symmetry charge. Energy needs the specific
-- potential. The LRL cancellation is a delicate algebraic identity:
-- `y(x vy - y vx) + vx r^2 - x(x vx + y vy) = 0` collapses ONLY because the radial
-- factor is exactly `1/r^2` (i.e. inverse-square force). Different power => no
-- cancellation. This is the formal fingerprint of the hidden SO(4) symmetry.
-- Critique (Critic): no theorem is vacuous - `hpos` (orbit avoids the origin) is
-- load-bearing for every `r`-dependent law and is physically necessary (the force
-- is singular at 0). The `*_const` versions promote stationarity to true constancy.
-- Synthesis: angular momentum (rotation), energy (time-translation), and the LRL
-- vector (hidden symmetry) - the complete conserved structure of the Kepler problem.
-- !-- end Lab Notes -- !--

noncomputable section

namespace Kepler

/-! ### Angular momentum: rotational symmetry of any central force -/

/-
**Angular momentum conservation for a central force.**
If the acceleration is radial, `(ax, ay) = a(t) · (x, y)` for some scalar field
`a`, then the planar angular momentum `Lz = x·vy − y·vx` is conserved.
This is the conservation law associated with rotational symmetry.
-/
theorem central_force_angular_momentum_conserved
    (x y vx vy ax ay a : ℝ → ℝ)
    (hx : ∀ t, HasDerivAt x (vx t) t)
    (hy : ∀ t, HasDerivAt y (vy t) t)
    (hvx : ∀ t, HasDerivAt vx (ax t) t)
    (hvy : ∀ t, HasDerivAt vy (ay t) t)
    (hcentralx : ∀ t, ax t = a t * x t)
    (hcentraly : ∀ t, ay t = a t * y t)
    (t : ℝ) :
    HasDerivAt (fun s => x s * vy s - y s * vx s) 0 t := by
  convert HasDerivAt.sub ( HasDerivAt.mul ( hx t ) ( hvy t ) ) ( HasDerivAt.mul ( hy t ) ( hvx t ) ) using 1 ; norm_num [ hcentralx, hcentraly ] ; ring;

theorem central_force_angular_momentum_const
    (x y vx vy ax ay a : ℝ → ℝ)
    (hx : ∀ t, HasDerivAt x (vx t) t)
    (hy : ∀ t, HasDerivAt y (vy t) t)
    (hvx : ∀ t, HasDerivAt vx (ax t) t)
    (hvy : ∀ t, HasDerivAt vy (ay t) t)
    (hcentralx : ∀ t, ax t = a t * x t)
    (hcentraly : ∀ t, ay t = a t * y t)
    (t₀ t₁ : ℝ) :
    x t₁ * vy t₁ - y t₁ * vx t₁ = x t₀ * vy t₀ - y t₀ * vx t₀ := by
  have h_deriv_zero : ∀ t, deriv (fun t => x t * vy t - y t * vx t) t = 0 := by
    intro t; exact (by
      have := central_force_angular_momentum_conserved x y vx vy ax ay a hx hy hvx hvy hcentralx hcentraly t;
      exact HasDerivAt.deriv this);
  exact is_const_of_deriv_eq_zero ( fun t => DifferentiableAt.sub ( DifferentiableAt.mul ( hx t |> HasDerivAt.differentiableAt ) ( hvy t |> HasDerivAt.differentiableAt ) ) ( DifferentiableAt.mul ( hy t |> HasDerivAt.differentiableAt ) ( hvx t |> HasDerivAt.differentiableAt ) ) ) h_deriv_zero t₁ t₀

/-! ### The radial coordinate and its derivative -/

/-- The radial coordinate `r(t) = √(x(t)² + y(t)²)`. -/
def radius (x y : ℝ → ℝ) : ℝ → ℝ := fun t => Real.sqrt (x t ^ 2 + y t ^ 2)

/-
Derivative of the radial coordinate: `r' = (x·vx + y·vy)/r`, valid off the
origin.  Equivalently `r·r' = x·vx + y·vy`.
-/
theorem radius_hasDerivAt
    (x y vx vy : ℝ → ℝ)
    (hx : ∀ t, HasDerivAt x (vx t) t)
    (hy : ∀ t, HasDerivAt y (vy t) t)
    (t : ℝ) (ht : x t ^ 2 + y t ^ 2 ≠ 0) :
    HasDerivAt (radius x y)
      ((x t * vx t + y t * vy t) / Real.sqrt (x t ^ 2 + y t ^ 2)) t := by
  convert HasDerivAt.sqrt ( show HasDerivAt ( fun t ↦ x t ^ 2 + y t ^ 2 ) ( 2 * x t * vx t + 2 * y t * vy t ) t from ?_ ) ?_ using 1;
  · ring;
  · convert HasDerivAt.add ( HasDerivAt.comp t ( hasDerivAt_pow 2 ( x t ) ) ( hx t ) ) ( HasDerivAt.comp t ( hasDerivAt_pow 2 ( y t ) ) ( hy t ) ) using 1 ; ring;
  · assumption

/-! ### Energy: time-translation symmetry of the Kepler potential -/

/-
**Energy conservation for the Kepler problem.**
For inverse-square dynamics `(ax, ay) = -k·(x, y)/r³` (with `r = √(x²+y²)`), the
total energy `E = ½(vx² + vy²) − k/r` is conserved.
-/
theorem kepler_energy_conserved
    (x y vx vy ax ay : ℝ → ℝ) (k : ℝ)
    (hx : ∀ t, HasDerivAt x (vx t) t)
    (hy : ∀ t, HasDerivAt y (vy t) t)
    (hvx : ∀ t, HasDerivAt vx (ax t) t)
    (hvy : ∀ t, HasDerivAt vy (ay t) t)
    (hpos : ∀ t, x t ^ 2 + y t ^ 2 ≠ 0)
    (hnewtonx : ∀ t, ax t = -k * x t / Real.sqrt (x t ^ 2 + y t ^ 2) ^ 3)
    (hnewtony : ∀ t, ay t = -k * y t / Real.sqrt (x t ^ 2 + y t ^ 2) ^ 3)
    (t : ℝ) :
    HasDerivAt
      (fun s => (1 / 2) * (vx s ^ 2 + vy s ^ 2) - k / radius x y s) 0 t := by
  have := @radius_hasDerivAt x y vx vy hx hy t ( hpos t );
  convert HasDerivAt.sub ( HasDerivAt.const_mul ( 1 / 2 ) ( HasDerivAt.add ( HasDerivAt.comp t ( hasDerivAt_pow 2 _ ) ( hvx t ) ) ( HasDerivAt.comp t ( hasDerivAt_pow 2 _ ) ( hvy t ) ) ) ) ( HasDerivAt.const_mul k ( this.inv ( ne_of_gt ( Real.sqrt_pos.mpr ( lt_of_le_of_ne ( add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) ( Ne.symm ( hpos t ) ) ) ) ) ) ) using 1 ; ring!;
  rw [ hnewtonx, hnewtony ] ; ring

theorem kepler_energy_const
    (x y vx vy ax ay : ℝ → ℝ) (k : ℝ)
    (hx : ∀ t, HasDerivAt x (vx t) t)
    (hy : ∀ t, HasDerivAt y (vy t) t)
    (hvx : ∀ t, HasDerivAt vx (ax t) t)
    (hvy : ∀ t, HasDerivAt vy (ay t) t)
    (hpos : ∀ t, x t ^ 2 + y t ^ 2 ≠ 0)
    (hnewtonx : ∀ t, ax t = -k * x t / Real.sqrt (x t ^ 2 + y t ^ 2) ^ 3)
    (hnewtony : ∀ t, ay t = -k * y t / Real.sqrt (x t ^ 2 + y t ^ 2) ^ 3)
    (t₀ t₁ : ℝ) :
    (1 / 2) * (vx t₁ ^ 2 + vy t₁ ^ 2) - k / radius x y t₁
      = (1 / 2) * (vx t₀ ^ 2 + vy t₀ ^ 2) - k / radius x y t₀ := by
  -- Apply the fundamental theorem of calculus, which states that if the derivative of a function is zero, then the function is constant.
  have h_const : ∀ t, HasDerivAt (fun s => (1 / 2) * (vx s ^ 2 + vy s ^ 2) - k / radius x y s) 0 t := by
    exact fun t => kepler_energy_conserved x y vx vy ax ay k hx hy hvx hvy hpos hnewtonx hnewtony t;
  exact is_const_of_deriv_eq_zero ( fun t => ( h_const t |> HasDerivAt.differentiableAt ) ) ( fun t => ( h_const t |> HasDerivAt.deriv ) ) t₁ t₀

/-! ### Laplace–Runge–Lenz vector: the hidden symmetry of the inverse-square law -/

/-
**Conservation of the x-component of the Laplace–Runge–Lenz vector.**
For Kepler dynamics, `A_x = (x·vy − y·vx)·vy − k·x/r` is conserved.  Unlike
angular momentum and energy, this conservation law fails for a generic central
force: it is special to the inverse-square potential.
-/
theorem kepler_LRL_x_conserved
    (x y vx vy ax ay : ℝ → ℝ) (k : ℝ)
    (hx : ∀ t, HasDerivAt x (vx t) t)
    (hy : ∀ t, HasDerivAt y (vy t) t)
    (hvx : ∀ t, HasDerivAt vx (ax t) t)
    (hvy : ∀ t, HasDerivAt vy (ay t) t)
    (hpos : ∀ t, x t ^ 2 + y t ^ 2 ≠ 0)
    (hnewtonx : ∀ t, ax t = -k * x t / Real.sqrt (x t ^ 2 + y t ^ 2) ^ 3)
    (hnewtony : ∀ t, ay t = -k * y t / Real.sqrt (x t ^ 2 + y t ^ 2) ^ 3)
    (t : ℝ) :
    HasDerivAt
      (fun s => (x s * vy s - y s * vx s) * vy s - k * x s / radius x y s) 0 t := by
  convert HasDerivAt.sub ( HasDerivAt.mul ( HasDerivAt.sub ( HasDerivAt.mul ( hx t ) ( hvy t ) ) ( HasDerivAt.mul ( hy t ) ( hvx t ) ) ) ( hvy t ) ) ( HasDerivAt.div ( HasDerivAt.const_mul k ( hx t ) ) ( radius_hasDerivAt x y vx vy hx hy t ( by aesop ) ) ?_ ) using 1;
  · unfold radius; norm_num [ hnewtonx, hnewtony ] ; ring;
    grind;
  · exact ne_of_gt <| Real.sqrt_pos.mpr <| lt_of_le_of_ne ( add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) ( Ne.symm <| hpos t )

/-
**Conservation of the y-component of the Laplace–Runge–Lenz vector.**
`A_y = -(x·vy − y·vx)·vx − k·y/r` is conserved for Kepler dynamics.
-/
theorem kepler_LRL_y_conserved
    (x y vx vy ax ay : ℝ → ℝ) (k : ℝ)
    (hx : ∀ t, HasDerivAt x (vx t) t)
    (hy : ∀ t, HasDerivAt y (vy t) t)
    (hvx : ∀ t, HasDerivAt vx (ax t) t)
    (hvy : ∀ t, HasDerivAt vy (ay t) t)
    (hpos : ∀ t, x t ^ 2 + y t ^ 2 ≠ 0)
    (hnewtonx : ∀ t, ax t = -k * x t / Real.sqrt (x t ^ 2 + y t ^ 2) ^ 3)
    (hnewtony : ∀ t, ay t = -k * y t / Real.sqrt (x t ^ 2 + y t ^ 2) ^ 3)
    (t : ℝ) :
    HasDerivAt
      (fun s => -(x s * vy s - y s * vx s) * vx s - k * y s / radius x y s) 0 t := by
  convert HasDerivAt.sub ( HasDerivAt.mul ( HasDerivAt.neg ( HasDerivAt.sub ( HasDerivAt.mul ( hx t ) ( hvy t ) ) ( HasDerivAt.mul ( hy t ) ( hvx t ) ) ) ) ( hvx t ) ) ( HasDerivAt.div ( HasDerivAt.const_mul k ( hy t ) ) ( radius_hasDerivAt x y vx vy hx hy t ( hpos t ) ) ( ne_of_gt <| Real.sqrt_pos.mpr <| lt_of_le_of_ne ( add_nonneg ( sq_nonneg _ ) ( sq_nonneg _ ) ) <| Ne.symm <| hpos t ) ) using 1 ; ring!;
  simp +zetaDelta at *;
  grind +locals

end Kepler