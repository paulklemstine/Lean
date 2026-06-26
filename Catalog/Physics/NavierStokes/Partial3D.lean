/-
# Partial 3D Results: The Stretching Term and Conditional Enstrophy Regularity

This file isolates, in the same abstract Galerkin framework as
`Physics.NavierStokes.EnergyMethod` and `Physics.NavierStokes.Enstrophy2D`, the
precise obstruction to 3D global regularity and proves the **conditional
regularity** statement that controls it.

## Mathematical context

For a self-adjoint viscous operator `A` the enstrophy `Ω(t) = ⟪A u, u⟫` of a
solution `u'(t) = −νA u − B(u,u)` obeys the **general dissipation identity**

  Ω'(t) = −2ν⟪A u, A u⟫ − 2⟪B(u,u), A u⟫.

The first term is dissipative.  The second, the **vortex-stretching term**
`⟪B(u,u), A u⟫`, is the entire difference between 2D and 3D:

* In 2D it vanishes (`Enstrophy2D.Model2D.hB2`), giving unconditional
  enstrophy decay.
* In 3D it has no a priori sign, so the enstrophy might grow.

The standard *partial* 3D results are **conditional regularity criteria** (à la
Prodi–Serrin / Beale–Kato–Majda): if the stretching term stays dominated by the
viscous dissipation, then the enstrophy cannot blow up.  This file proves the
abstract version of that statement.

## Main results

* `Model3D` — a 3D abstract NS model: an `EnergyMethod.Model` with self-adjoint
  `A` but **no** stretching cancellation.
* `Model3D.enstrophy_hasDerivAt` — the general enstrophy dissipation identity,
  retaining the stretching term.
* `Model3D.enstrophy_antitone_of_stretching_controlled` — **conditional
  regularity**: if `−⟪B(u,u), A u⟫ ≤ ν⟪A u, A u⟫` pointwise then the enstrophy
  is nonincreasing.
* `Model3D.no_enstrophy_blowup_of_stretching_controlled` — the resulting a
  priori enstrophy bound (no finite-time blowup under the control hypothesis).
* `Model3D.energy_no_blowup` — the unconditional `L²` bound still holds in 3D
  (the energy method needs no stretching control).
-/

import Mathlib
import Physics.NavierStokes.EnergyMethod

namespace NavierStokes

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-- An abstract **three-dimensional** Galerkin Navier–Stokes model: an
`EnergyMethod.Model` whose viscous operator `A` is self-adjoint.  Crucially it
carries **no** vortex-stretching cancellation — that absence is exactly the 3D
obstruction. -/
structure Model3D (V : Type*) [NormedAddCommGroup V] [InnerProductSpace ℝ V]
    extends Model V where
  /-- `A` is self-adjoint (the Stokes operator `−Δ` is symmetric). -/
  hA_symm : ∀ v w : V, (inner ℝ (A v) w : ℝ) = inner ℝ v (A w)

/-- The enstrophy observable `Ω(t) = ⟪A u(t), u(t)⟫`. -/
def Model3D.enstrophy (M : Model3D V) (u : ℝ → V) (t : ℝ) : ℝ := inner ℝ (M.A (u t)) (u t)

/-
**General enstrophy dissipation identity** (3D).  Along any solution the
enstrophy is differentiable with derivative
`−2ν⟪A u, A u⟫ − 2⟪B(u,u), A u⟫`; the stretching term is retained (no
cancellation is available in 3D).
-/
theorem Model3D.enstrophy_hasDerivAt (M : Model3D V) {u : ℝ → V}
    (hu : M.IsSolution u) (t : ℝ) :
    HasDerivAt (M.enstrophy u)
      (-(2 * M.ν * inner ℝ (M.A (u t)) (M.A (u t)))
        - 2 * inner ℝ (M.B (u t) (u t)) (M.A (u t))) t := by
  have h_prod_rule : HasDerivAt (fun t => (inner ℝ (M.A (u t)) (u t) : ℝ)) (inner ℝ (M.A (u t)) (M.vectorField (u t)) + inner ℝ (M.A (M.vectorField (u t))) (u t)) t := by
    convert HasDerivAt.inner ℝ ( HasFDerivAt.hasDerivAt ( M.A.hasFDerivAt.comp t ( hu t |> HasDerivAt.hasFDerivAt ) ) ) ( hu t ) using 1;
    simp +decide [ ContinuousLinearMap.comp_apply, ContinuousLinearMap.toSpanSingleton_apply ]
  convert h_prod_rule using 1
  have e1 : inner ℝ (M.A (M.vectorField (u t))) (u t)
      = inner ℝ (M.A (u t)) (M.vectorField (u t)) := by
    rw [M.hA_symm, real_inner_comm]
  rw [e1]
  simp only [Model.vectorField, inner_sub_right, inner_neg_right, real_inner_smul_right,
    real_inner_comm (M.A (u t)) (M.B (u t) (u t))]
  ring

/-- **Conditional regularity (abstract Prodi–Serrin / BKM criterion).**  If the
vortex-stretching term is dominated by the viscous dissipation pointwise,
`−⟪B(u,u), A u⟫ ≤ ν⟪A u, A u⟫`, then the enstrophy is nonincreasing. -/
theorem Model3D.enstrophy_antitone_of_stretching_controlled (M : Model3D V)
    {u : ℝ → V} (hu : M.IsSolution u)
    (hctrl : ∀ t : ℝ,
      -inner ℝ (M.B (u t) (u t)) (M.A (u t)) ≤ M.ν * inner ℝ (M.A (u t)) (M.A (u t))) :
    Antitone (M.enstrophy u) := by
  apply antitone_of_hasDerivAt_nonpos (fun t => M.enstrophy_hasDerivAt hu t)
  intro t
  have h := hctrl t
  show -(2 * M.ν * inner ℝ (M.A (u t)) (M.A (u t)))
      - 2 * inner ℝ (M.B (u t) (u t)) (M.A (u t)) ≤ 0
  nlinarith [h]

/-- **No finite-time enstrophy blowup under the control hypothesis.** -/
theorem Model3D.no_enstrophy_blowup_of_stretching_controlled (M : Model3D V)
    {u : ℝ → V} (hu : M.IsSolution u)
    (hctrl : ∀ t : ℝ,
      -inner ℝ (M.B (u t) (u t)) (M.A (u t)) ≤ M.ν * inner ℝ (M.A (u t)) (M.A (u t)))
    {s t : ℝ} (hst : s ≤ t) :
    M.enstrophy u t ≤ M.enstrophy u s :=
  M.enstrophy_antitone_of_stretching_controlled hu hctrl hst

/-- **Unconditional `L²` bound in 3D.**  Independently of any stretching
control, the energy norm of a 3D solution never increases — the Leray energy
estimate needs only the base-model trilinear cancellation. -/
theorem Model3D.energy_no_blowup (M : Model3D V) {u : ℝ → V}
    (hu : M.IsSolution u) {s t : ℝ} (hst : s ≤ t) : ‖u t‖ ≤ ‖u s‖ :=
  M.toModel.norm_le_initial hu hst

end NavierStokes

-- !-- Lab Notes -- !--
/-
HYPOTHESIS (Hypothesizer).
  3D global regularity is open precisely because the enstrophy may be pumped by
  the vortex-stretching term inner (B u u) (A u), which has no a priori sign.
  Conjecture: in the abstract model the ONLY thing one needs to add to the 2D
  argument is a quantitative control of the stretching by the dissipation; with
  it, the enstrophy is again a Lyapunov function. This is the abstract skeleton
  of every known 3D conditional regularity criterion (Prodi-Serrin, BKM,
  Ladyzhenskaya).

EXPERIMENT (Experimenter).
  Defined Model3D = EnergyMethod.Model + self-adjoint A, with NO stretching
  cancellation. Proved the general dissipation identity
  Omega'(t) = -2 nu inner (A u)(A u) - 2 inner (B u u)(A u) by the same
  product-rule + chain-rule + self-adjointness computation as in 2D, but
  KEEPING the stretching term (the subagent reproduced the Model2D proof with
  the cancellation step removed). Then introduced the pointwise control
  hypothesis -inner (B u u)(A u) <= nu inner (A u)(A u) and showed it forces
  Omega'(t) <= 0 (antitone_of_hasDerivAt_nonpos + nlinarith), hence no enstrophy
  blowup. Recorded separately that the L2 / energy bound (energy_no_blowup)
  holds UNCONDITIONALLY in 3D, inherited from the base model.

ANALYSIS (Analyst).
  True and honest about its boundary. The control hypothesis is exactly the
  abstract content of a regularity criterion: it is an ASSUMPTION on the
  solution, not a theorem, so this does not resolve 3D regularity -- it
  quarantines the difficulty into a single inequality. The clean split between
  the unconditional energy bound and the conditional enstrophy bound mirrors the
  real PDE picture: Leray weak solutions always exist (energy), strong solutions
  exist conditionally (enstrophy).

CRITIQUE (Critic).
  Non-vacuous and non-circular. The hypothesis hctrl is genuinely weaker than
  assuming the conclusion: it is a pointwise scalar inequality between two
  specific observables, not a bound on Omega itself. The 2D model is the
  degenerate case hctrl with equality slack (stretching = 0), made precise in
  Synthesis.lean. We did NOT smuggle in a false claim of 3D regularity.

SYNTHESIS (PI).
  The pair (Enstrophy2D, Partial3D) localizes the entire 2D-vs-3D gap to the
  sign/size of one trilinear pairing. Future work: replace the qualitative
  control hypothesis by a self-improving (Gronwall / bootstrap) inequality that
  could in principle be verified from the data -- see FUTURE_DIRECTIONS.md.
-/