/-
# Synthesis: 2D Global Regularity as the Degenerate 3D Conditional Criterion

This file is the cross-file synthesis of `Physics.NavierStokes.Enstrophy2D`
(unconditional 2D enstrophy control) and `Physics.NavierStokes.Partial3D`
(conditional 3D enstrophy control).  It makes precise the slogan of the lab
notes: **2D global regularity is exactly the limiting case of the abstract 3D
conditional regularity criterion in which the vortex-stretching term vanishes.**

## Mathematical content

Every 2D model `Model2D` forgets to a 3D model `Model3D` (drop the cancellation
field `hB2`, keep self-adjointness).  The 2D cancellation `⟪B v v, A v⟫ = 0`
then makes the 3D *control hypothesis* `−⟪B(u,u), A u⟫ ≤ ν⟪A u, A u⟫` hold
automatically (its left side is `0`, its right side is `≥ 0`).  Feeding this into
the 3D conditional theorem reproduces the 2D enstrophy bound — without re-running
the differentiation argument.

## Main results

* `Model2D.toModel3D` — the forgetful map `Model2D → Model3D`.
* `Model2D.stretching_controlled` — the 2D cancellation implies the 3D control
  hypothesis (with the stretching term being exactly zero).
* `Model2D.no_enstrophy_blowup_via_3D` — the 2D enstrophy bound, re-derived as a
  corollary of the 3D conditional criterion `Model3D.no_enstrophy_blowup_of_stretching_controlled`.
-/

import Mathlib
import Physics.NavierStokes.Enstrophy2D
import Physics.NavierStokes.Partial3D

namespace NavierStokes

variable {V : Type*} [NormedAddCommGroup V] [InnerProductSpace ℝ V]

/-- The **forgetful map** from a 2D model to a 3D model: keep the underlying
`EnergyMethod.Model` and the self-adjointness of `A`, discard the 2D
vortex-stretching cancellation `hB2`. -/
def Model2D.toModel3D (M : Model2D V) : Model3D V :=
  { M.toModel with hA_symm := M.hA_symm }

/-- The two enstrophy observables agree: forgetting to the 3D model does not
change the enstrophy. -/
theorem Model2D.enstrophy_eq (M : Model2D V) (u : ℝ → V) :
    M.toModel3D.enstrophy u = M.enstrophy u := rfl

/-- **The 2D cancellation implies the 3D control hypothesis.**  Because the
stretching term is identically zero in 2D (`hB2`), it is trivially dominated by
the (nonnegative) viscous dissipation. -/
theorem Model2D.stretching_controlled (M : Model2D V) (u : ℝ → V) :
    ∀ t : ℝ,
      -inner ℝ (M.toModel3D.B (u t) (u t)) (M.toModel3D.A (u t))
        ≤ M.toModel3D.ν * inner ℝ (M.toModel3D.A (u t)) (M.toModel3D.A (u t)) := by
  intro t
  have hzero : (inner ℝ (M.B (u t) (u t)) (M.A (u t)) : ℝ) = 0 := M.hB2 (u t)
  have hnn : (0 : ℝ) ≤ M.ν * inner ℝ (M.A (u t)) (M.A (u t)) :=
    mul_nonneg M.hν real_inner_self_nonneg
  show -inner ℝ (M.B (u t) (u t)) (M.A (u t))
      ≤ M.ν * inner ℝ (M.A (u t)) (M.A (u t))
  rw [hzero]; simpa using hnn

/-- **2D no-blowup via the 3D conditional criterion.**  The unconditional 2D
enstrophy bound (`Model2D.no_enstrophy_blowup`) is recovered as a special case of
the abstract 3D conditional regularity theorem, by checking that the 2D
cancellation supplies the control hypothesis.  This is the formal statement that
2D regularity sits *inside* the 3D conditional theory. -/
theorem Model2D.no_enstrophy_blowup_via_3D (M : Model2D V) {u : ℝ → V}
    (hu : M.IsSolution u) {s t : ℝ} (hst : s ≤ t) :
    M.enstrophy u t ≤ M.enstrophy u s := by
  have h := M.toModel3D.no_enstrophy_blowup_of_stretching_controlled
    (u := u) hu (M.stretching_controlled u) hst
  simpa [Model2D.enstrophy_eq] using h

end NavierStokes

-- !-- Lab Notes -- !--
/-
HYPOTHESIS (Hypothesizer).
  If Partial3D's conditional criterion is the right abstraction, then 2D global
  regularity must be literally a corollary of it -- the 2D cancellation hB2
  should DISCHARGE the 3D control hypothesis, not merely resemble it. Conjecture:
  Model2D -> Model3D is forgetful, and along that map the 2D enstrophy bound
  factors through Model3D.no_enstrophy_blowup_of_stretching_controlled.

EXPERIMENT (Experimenter).
  Built the forgetful map Model2D.toModel3D (structure update keeping hA_symm,
  dropping hB2). Verified the enstrophy observables agree definitionally
  (enstrophy_eq : rfl). Proved stretching_controlled: the 2D term inner(Buu)(Au)
  is 0 by hB2, and 0 <= nu * inner(Au)(Au) by nu >= 0 and real_inner_self_nonneg,
  so the control inequality holds. Finally re-derived the 2D bound
  (no_enstrophy_blowup_via_3D) purely from the 3D theorem.

ANALYSIS (Analyst).
  True and structural -- and the rfl for enstrophy_eq confirms the two theories
  share the SAME observable, not merely isomorphic ones. The synthesis is real:
  one theorem from Enstrophy2D's world is obtained without any new analysis, only
  by supplying the 3D criterion's hypothesis. This is the cross-file bridge the
  research mission asks for, with genuine logical content (a factorization), not
  a cosmetic restatement.

CRITIQUE (Critic).
  Non-vacuous: toModel3D produces an honest Model3D, stretching_controlled uses
  both hB2 and hν (drop either and it fails), and the final corollary genuinely
  invokes the Partial3D theorem. No circularity: the 3D theorem never assumed
  hB2, so using it for the 2D model is sound specialization, not question-begging.

SYNTHESIS (PI).
  Unified picture now formal: ENERGY bound (always) ⊂ ENSTROPHY bound under
  stretching control (3D conditional) ⊃ ENSTROPHY bound unconditionally (2D, via
  zero stretching). The single dial is the trilinear stretching pairing; 2D
  pins it to 0, the conditional theory bounds it, 3D leaves it free. Next: make
  the dial self-regulating (FUTURE_DIRECTIONS.md).
-/