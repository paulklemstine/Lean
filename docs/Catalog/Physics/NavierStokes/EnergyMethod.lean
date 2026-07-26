/-
# The Energy Method for an Abstract Galerkin Navier–Stokes Model

This file formalizes the central *a priori* estimate behind Leray's theory of
global weak solutions of the Navier–Stokes equations: the **energy dissipation
identity** and the resulting **no-blowup bound** for the abstract spectral /
Galerkin truncation of the equations.

## Mathematical context

After projecting the incompressible Navier–Stokes system

  ∂ₜu + (u·∇)u = ν Δu − ∇p,   div u = 0

onto a finite- or infinite-dimensional space of divergence-free fields, one
obtains an evolution equation of the form

  u'(t) = −ν A u − B(u, u)

on a real inner-product space `V`, where

* `A` is the (positive semidefinite) viscous operator coming from `−Δ`, and
* `B` is the quadratic transport nonlinearity.

The decisive structural fact is the **trilinear cancellation**

  ⟪B(u, u), u⟫ = 0,

which is the abstract form of the identity `∫ (u·∇)u · u = 0` valid for
divergence-free `u`. Because of it the nonlinearity is *energy preserving*, and
the energy `E(t) = ‖u(t)‖²` obeys

  E'(t) = −2ν ⟪A u, u⟫ ≤ 0.

Hence the energy is nonincreasing and the solution can never blow up in the
`L²`/energy norm. This is exactly the estimate that yields global existence of
Leray–Hopf weak solutions.

## Main results

* `NavierStokes.Model.energy_hasDerivAt` — the energy dissipation identity.
* `NavierStokes.Model.energy_deriv_nonpos` — the dissipation rate is `≤ 0`.
* `NavierStokes.Model.energy_antitone` — the energy is nonincreasing in time.
* `NavierStokes.Model.energy_le_initial` — *a priori* energy bound.
* `NavierStokes.Model.norm_le_initial` — no finite-time blowup in the energy norm.
-/

import Mathlib

namespace NavierStokes

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-- Abstract spectral / Galerkin Navier–Stokes model on a real inner-product
space `V`: a viscosity `ν ≥ 0`, a positive-semidefinite viscous operator `A`,
and an energy-preserving quadratic nonlinearity `B`.  The trilinear
cancellation `⟪B v v, v⟫ = 0` is the abstract form of the divergence-free
transport identity `∫ (u·∇)u · u = 0`. -/
structure Model (V : Type*) [NormedAddCommGroup V] [InnerProductSpace ℝ V] where
  /-- Kinematic viscosity. -/
  ν : ℝ
  /-- Viscosity is nonnegative. -/
  hν : 0 ≤ ν
  /-- Viscous (Stokes) operator, the abstract `−Δ`. -/
  A : V →L[ℝ] V
  /-- `A` is positive semidefinite (dissipativity of `−Δ`). -/
  hA : ∀ v : V, 0 ≤ (inner ℝ (A v) v : ℝ)
  /-- Quadratic transport nonlinearity. -/
  B : V → V → V
  /-- Trilinear cancellation: the nonlinearity preserves energy. -/
  hB : ∀ v : V, (inner ℝ (B v v) v : ℝ) = 0

/-- The vector field driving the model trajectory: `u ↦ −(ν A u) − B u u`. -/
def Model.vectorField (M : Model V) (v : V) : V := -(M.ν • M.A v) - M.B v v

/-- `u : ℝ → V` is a (strong) solution of the model on all of `ℝ`. -/
def Model.IsSolution (M : Model V) (u : ℝ → V) : Prop :=
  ∀ t : ℝ, HasDerivAt u (M.vectorField (u t)) t

/-- The energy observable `E(t) = ⟪u t, u t⟫ = ‖u t‖²`. -/
def energy (u : ℝ → V) (t : ℝ) : ℝ := inner ℝ (u t) (u t)

/-
**Energy dissipation identity.**  Along any solution, the energy is
differentiable with derivative `−2ν ⟪A u, u⟫`; all of the nonlinear transport
contribution cancels by `hB`.
-/
theorem Model.energy_hasDerivAt (M : Model V) {u : ℝ → V} (hu : M.IsSolution u)
    (t : ℝ) :
    HasDerivAt (energy u) (-(2 * M.ν * inner ℝ (M.A (u t)) (u t))) t := by
  -- product rule for the inner product applied to the trajectory
  convert HasDerivAt.inner ℝ (hu t) (hu t) using 1
  -- reduce the symmetric inner product to a single term and expand the vector field
  rw [← real_inner_comm (M.vectorField (u t)) (u t)]
  simp only [Model.vectorField, inner_sub_right, inner_neg_right, real_inner_smul_right]
  have hB0 : inner ℝ (u t) (M.B (u t) (u t)) = 0 := by
    rw [real_inner_comm]; exact M.hB (u t)
  have hAcomm : inner ℝ (u t) (M.A (u t)) = inner ℝ (M.A (u t)) (u t) :=
    real_inner_comm _ _
  rw [hB0, hAcomm]
  ring

/-
The instantaneous dissipation rate is nonpositive.
-/
theorem Model.energy_deriv_nonpos (M : Model V) {u : ℝ → V}
    (t : ℝ) :
    -(2 * M.ν * inner ℝ (M.A (u t)) (u t)) ≤ 0 := by
  exact neg_nonpos_of_nonneg ( mul_nonneg ( mul_nonneg zero_le_two M.hν ) ( M.hA _ ) )

/-
**The energy is nonincreasing along solutions.**
-/
theorem Model.energy_antitone (M : Model V) {u : ℝ → V} (hu : M.IsSolution u) :
    Antitone (energy u) := by
  exact antitone_of_hasDerivAt_nonpos (fun t => M.energy_hasDerivAt hu t)
    (fun t => M.energy_deriv_nonpos t)

/-- **A priori energy bound.**  At any later time the energy is no larger than
at an earlier time. -/
theorem Model.energy_le_initial (M : Model V) {u : ℝ → V} (hu : M.IsSolution u)
    {s t : ℝ} (hst : s ≤ t) : energy u t ≤ energy u s :=
  M.energy_antitone hu hst

/-
**No finite-time blowup in the energy norm.**  The norm of a solution is
bounded by its norm at any earlier time; in particular it cannot blow up.
-/
theorem Model.norm_le_initial (M : Model V) {u : ℝ → V} (hu : M.IsSolution u)
    {s t : ℝ} (hst : s ≤ t) : ‖u t‖ ≤ ‖u s‖ := by
  have h := M.energy_le_initial hu hst
  unfold energy at h
  rw [real_inner_self_eq_norm_sq, real_inner_self_eq_norm_sq] at h
  nlinarith [norm_nonneg (u t), norm_nonneg (u s)]

end NavierStokes

-- !-- Lab Notes -- !--
/-
HYPOTHESIS (Hypothesizer).
  The 3D Navier-Stokes global regularity problem is open, but the *mechanism*
  that controls the only universally available dissipated quantity -- the
  kinetic energy -- is fully rigorous in the Galerkin truncation. Conjecture:
  in any abstract model with (i) a positive semidefinite viscous operator and
  (ii) an energy-preserving quadratic nonlinearity (trilinear cancellation
  inner (B v v) v = 0), the energy is a Lyapunov function and the solution
  cannot blow up in the energy norm.

EXPERIMENT (Experimenter).
  Modelled the truncated equations as u'(t) = -(nu A u) - B u u on a real
  inner-product space V. Encoded the two structural hypotheses as fields of
  Model. Proved the energy dissipation identity E'(t) = -2 nu inner (A u) u
  via the product rule for inner products (HasDerivAt.inner) followed by the
  cancellation hB, then deduced monotonicity (antitone_of_hasDerivAt_nonpos)
  and the norm bound (real_inner_self_eq_norm_sq + nlinarith).

ANALYSIS (Analyst).
  The result is "true and clean": no finite dimension, smoothness of the data,
  or strict positivity of nu beyond nu >= 0 is needed. The single load-bearing
  fact is the trilinear cancellation; dropping hB makes the energy estimate
  FALSE (the nonlinearity could pump energy), which is exactly why the genuine
  3D problem is hard: cancellation controls energy but NOT higher norms
  (enstrophy), and it is the enstrophy that may blow up.

CRITIQUE (Critic).
  The theorems are non-vacuous: Model is inhabited (e.g. nu = 0, A = 0, B = 0
  with a constant trajectory), and the energy identity has real analytic
  content (it is not rfl/decide). The proof uses insight-bearing steps: the
  inner-product product rule, real_inner_comm, and nlinarith. Boundary noted:
  this controls only the L2 norm; it does NOT resolve regularity, by design.

SYNTHESIS (PI).
  This is the formal core of Leray's a priori estimate. It is reusable: any
  concrete spectral Navier-Stokes truncation that supplies the two structural
  fields inherits global energy-norm boundedness for free.
-/