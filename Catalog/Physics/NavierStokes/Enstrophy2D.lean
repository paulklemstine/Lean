/-
# 2D Enstrophy Control: The Abstract Mechanism Behind 2D Global Regularity

This file extends the abstract Galerkin Navier–Stokes model of
`Physics.NavierStokes.EnergyMethod` to capture the structural reason why the
**two-dimensional** Navier–Stokes equations are globally regular while the
three-dimensional ones remain open.

## Mathematical context

The energy method (`EnergyMethod.lean`) controls only the `L²` norm `‖u‖`, via
the trilinear cancellation `⟪B v v, v⟫ = 0`.  To obtain *regularity* one must
control a higher norm, the **enstrophy**

  Ω(t) = ⟪A u(t), u(t)⟫ = ‖A^{1/2} u(t)‖²   (the `H¹` / vorticity norm).

Differentiating along a solution `u'(t) = −νA u − B(u,u)` and using that `A` is
self-adjoint gives

  Ω'(t) = 2⟪A u', u⟫ = −2ν⟪A u, A u⟫ − 2⟪B(u,u), A u⟫.

The viscous term `−2ν‖A u‖²` is dissipative.  The **vortex-stretching term**
`⟪B(u,u), A u⟫` is the crux:

* In **2D** the vorticity is a scalar transported by the flow, the stretching
  term *vanishes identically* — the abstract form is `⟪B v v, A v⟫ = 0`.  Then
  `Ω'(t) = −2ν‖A u‖² ≤ 0`, the enstrophy is a Lyapunov function, and one obtains
  global `H¹` control — the a priori estimate behind **2D global regularity**.

* In **3D** the stretching term has no definite sign and can a priori pump
  enstrophy; this is precisely the obstruction to a global regularity proof.

This file isolates the 2D structural hypothesis `⟪B v v, A v⟫ = 0` and proves the
resulting enstrophy dissipation identity, monotonicity, and a priori bound.

## Main results

* `Model2D` — a 2D abstract NS model: an `EnergyMethod.Model` together with
  self-adjointness of `A` and the 2D vortex-stretching cancellation.
* `Model2D.enstrophy_hasDerivAt` — the enstrophy dissipation identity.
* `Model2D.enstrophy_antitone` — the enstrophy is nonincreasing.
* `Model2D.enstrophy_le_initial` — a priori enstrophy bound (2D `H¹` control).
* `Model2D.no_enstrophy_blowup` — no finite-time enstrophy blowup in 2D.
-/

import Mathlib
import Physics.NavierStokes.EnergyMethod

namespace NavierStokes

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-- An abstract **two-dimensional** Galerkin Navier–Stokes model: an
`EnergyMethod.Model` whose viscous operator `A` is self-adjoint and whose
nonlinearity additionally satisfies the **2D vortex-stretching cancellation**
`⟪B v v, A v⟫ = 0`.  This last identity is the abstract expression of the fact
that in two dimensions the vorticity is merely transported (no stretching). -/
structure Model2D (V : Type*) [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    extends Model V where
  /-- `A` is self-adjoint (the Stokes operator `−Δ` is symmetric). -/
  hA_symm : ∀ v w : V, (inner ℝ (A v) w : ℝ) = inner ℝ v (A w)
  /-- **2D vortex-stretching cancellation**: in two dimensions the stretching
  term vanishes, `⟪B v v, A v⟫ = 0`. -/
  hB2 : ∀ v : V, (inner ℝ (B v v) (A v) : ℝ) = 0

/-- The enstrophy observable `Ω(t) = ⟪A u(t), u(t)⟫ = ‖A^{1/2} u(t)‖²`. -/
def Model2D.enstrophy (M : Model2D V) (u : ℝ → V) (t : ℝ) : ℝ := inner ℝ (M.A (u t)) (u t)

/-
**Enstrophy dissipation identity.**  Along any solution of the 2D model the
enstrophy is differentiable with derivative `−2ν ‖A u‖²`; the vortex-stretching
contribution cancels by `hB2`.
-/
theorem Model2D.enstrophy_hasDerivAt (M : Model2D V) {u : ℝ → V}
    (hu : M.IsSolution u) (t : ℝ) :
    HasDerivAt (M.enstrophy u) (-(2 * M.ν * inner ℝ (M.A (u t)) (M.A (u t)))) t := by
  -- Apply the product rule for the inner product:
  have h_prod_rule : HasDerivAt (fun t => (inner ℝ (M.A (u t)) (u t) : ℝ)) ((inner ℝ (M.A (u t)) (M.vectorField (u t)) : ℝ) + (inner ℝ (M.A (M.vectorField (u t))) (u t) : ℝ)) t := by
    convert HasDerivAt.inner ℝ ( HasFDerivAt.hasDerivAt ( M.A.hasFDerivAt.comp t ( hu t |> HasDerivAt.hasFDerivAt ) ) ) ( hu t ) using 1;
    simp +decide [ ContinuousLinearMap.comp_apply, ContinuousLinearMap.toSpanSingleton_apply ];
  convert h_prod_rule using 1;
  have := M.hA_symm ( u t ) ( M.vectorField ( u t ) ) ; simp_all +decide [ Model.vectorField ];
  simp_all +decide [ inner_sub_left, inner_sub_right, real_inner_comm ];
  simp_all +decide [ real_inner_smul_right, inner_self_eq_norm_sq_to_K ];
  linarith [ M.hB2 ( u t ) ]

/-- The instantaneous enstrophy dissipation rate is nonpositive. -/
theorem Model2D.enstrophy_deriv_nonpos (M : Model2D V) {u : ℝ → V} (t : ℝ) :
    -(2 * M.ν * inner ℝ (M.A (u t)) (M.A (u t))) ≤ 0 := by
  have h : (0 : ℝ) ≤ inner ℝ (M.A (u t)) (M.A (u t)) := real_inner_self_nonneg
  exact neg_nonpos_of_nonneg (mul_nonneg (mul_nonneg zero_le_two M.hν) h)

/-- **The enstrophy is nonincreasing along 2D solutions.** -/
theorem Model2D.enstrophy_antitone (M : Model2D V) {u : ℝ → V}
    (hu : M.IsSolution u) : Antitone (M.enstrophy u) :=
  antitone_of_hasDerivAt_nonpos (fun t => M.enstrophy_hasDerivAt hu t)
    (fun t => M.enstrophy_deriv_nonpos t)

/-- **A priori enstrophy bound** (2D `H¹` control): at any later time the
enstrophy is no larger than at an earlier time. -/
theorem Model2D.enstrophy_le_initial (M : Model2D V) {u : ℝ → V}
    (hu : M.IsSolution u) {s t : ℝ} (hst : s ≤ t) :
    M.enstrophy u t ≤ M.enstrophy u s :=
  M.enstrophy_antitone hu hst

/-- **No finite-time enstrophy blowup in 2D.**  The enstrophy of a solution is
bounded by its value at any earlier time; in particular it cannot blow up. This
is the abstract a priori estimate that underlies 2D global regularity, and it
fails in 3D precisely because the stretching cancellation `hB2` is unavailable. -/
theorem Model2D.no_enstrophy_blowup (M : Model2D V) {u : ℝ → V}
    (hu : M.IsSolution u) {s t : ℝ} (hst : s ≤ t) :
    M.enstrophy u t ≤ M.enstrophy u s :=
  M.enstrophy_le_initial hu hst

end NavierStokes

-- !-- Lab Notes -- !--
/-
HYPOTHESIS (Hypothesizer).
  The catalog energy method (EnergyMethod.lean) controls only the L2 norm via
  the trilinear cancellation inner (B v v) v = 0. The DIFFERENCE between 2D
  (globally regular) and 3D (open) Navier-Stokes is whether the next Lyapunov
  observable -- the enstrophy Omega = inner (A u) u = ‖A^{1/2} u‖^2 -- is also
  dissipated. Conjecture: adding exactly two structural facts to the abstract
  model, namely self-adjointness of A and the 2D vortex-stretching cancellation
  inner (B v v) (A v) = 0, makes the enstrophy a Lyapunov function and yields
  the a priori H^1 bound behind 2D global regularity.

EXPERIMENT (Experimenter).
  Defined Model2D extending EnergyMethod.Model with fields hA_symm (A symmetric)
  and hB2 (inner (B v v) (A v) = 0). Differentiated the enstrophy along a
  solution: the product rule for the inner product (HasDerivAt.inner), the
  continuous-linear-map chain rule for A (A.hasFDerivAt.comp_hasDerivAt), then
  self-adjointness to symmetrize, gives Omega'(t) = -2 nu inner (A u)(A u)
  - 2 inner (B u u)(A u). The stretching term is killed by hB2. Monotonicity
  follows from antitone_of_hasDerivAt_nonpos; the a priori bound and no-blowup
  statement are immediate corollaries.

ANALYSIS (Analyst).
  True and clean. The single new load-bearing fact is hB2; it is the abstract
  shadow of "in 2D vorticity is a passively transported scalar, so there is no
  vortex stretching". The viscous term -2 nu ‖A u‖^2 is automatically
  dissipative (real_inner_self_nonneg). Note the proof needs A self-adjoint to
  even differentiate cleanly -- this is the abstract -Delta being symmetric.

CRITIQUE (Critic).
  Non-vacuous: Model2D is inhabited (nu = 0, A = 0, B = 0 with constant
  trajectory satisfies hA_symm and hB2). The dissipation identity has genuine
  analytic content (HasDerivAt, not rfl). Boundary of validity: dropping hB2
  recovers the 3D situation where the sign of the stretching term is
  uncontrolled -- this is exactly why we cannot iterate the argument in 3D, and
  it motivates the conditional results in Partial3D.lean.

SYNTHESIS (PI).
  Cross-level takeaway: "regularity = one more dissipated observable". 2D works
  because the cancellation cascade reaches the enstrophy level; 3D stalls at the
  energy level. The clean separation of the stretching term as the SOLE
  obstruction is the reusable insight, made precise abstractly here.
-/