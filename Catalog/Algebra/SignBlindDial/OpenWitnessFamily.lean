/-
# A two-parameter open family of sign-masked population pairs

Companion to `Algebra.SignBlindDial.CorrelationInvariants`, and the robustness upgrade of
the flagship construction `sign_masking_nonreplication` of
`Combinatorics.ExtendedDialMomentGeometry`.

The catalog exhibits *one* pair of four-key populations (`rateSB`, `rateSC`) that agree on
every sign-blind dial reading and disagree on the increment.  A single pair leaves open the
possibility that the coincidence is an algebraic accident living on a measure-zero set of
moment data.  This file removes that possibility by embedding the pair in a genuine
two-parameter family and showing that the failure persists on a whole neighbourhood.

Set-up: four keys, uniform regime `pU`, footprint `foot = (1,2,3,4)`, prime-power feature
`pp = (1,1,0,0)`.  The residual space (centred and orthogonal to the footprint) is
two-dimensional, spanned by the partialled feature `ztA` and by `eVec = (1,-1,-1,1)`.  For
parameters `(b, u)` with `u > 0` put

* `rateFamB b u = b·foot + (u + 5b²/u)·eVec`     (pure `eVec` residual: increment `0`),
* `rateFamC b u = b·foot + (u − 5b²/u)·eVec + 20b·ztA`.

The coefficient `20b` is exactly the amount that flips the sign of `σ_zy`, and the shift
`±5b²/u` in the `eVec` coefficient is exactly the compensation that keeps the rate variance
equal — so the two populations agree on all three dial readings for *every* parameter value.

Main results.

* `rateFamB_at_base`, `rateFamC_at_base` — at `(b,u) = (1/10, 1/2)` the family reproduces the
  catalog pair `rateSB`, `rateSC` verbatim.
* `wvar_rateFamB_eq_wvar_rateFamC`, `R2_foot_fam_agree`, `R2_pp_fam_agree`,
  `wcov_pp_fam_sign_flip` — the whole family is sign-masked: identical dial readings,
  opposite signed covariances.
* `pgain_famB`, `pgain_famC_via_moments` — increments `0` and `20b²`, the second obtained
  through the catalog's `pgain_moment_formula` (the moment route, not a re-computation).
* `no_sign_blind_predictor` — **there is no function `F` with `ΔR² = F(R²(x,y), R²(z,y),
  R²(x,z))` valid on all finite populations.**
* `sign_blind_failure_contains_open_set` — the witnessing parameters contain a metric ball
  around the catalog point on which the increment gap is uniformly `≥ 1/3`.
* `dial_readings_nonconstant_on_ball` — the ball is not a single moment point in disguise:
  the dial readings genuinely vary over it, so the witness set has nonempty interior in
  moment space.
* `sign_bit_suffices_on_family` — the positive counterpart: recording the sign of the
  correlation triple product does separate the two populations of every pair in the family.
-/
import Algebra.SignBlindDial.CorrelationInvariants

open Finset

namespace Catalog.UniformDial

namespace ExtendedDial

/-! ## 1. The residual plane and the family -/

/-- The second residual direction: centred, orthogonal to the footprint, and orthogonal to
the partialled feature `ztA`.  Together with `ztA` it spans the two-dimensional residual
plane of the four-key population. -/
def eVec : Fin 4 → ℝ := ![1, -1, -1, 1]

/-- Residual of the *suppressed* member of the pair with parameters `(b, u)`. -/
noncomputable def residFamB (b u : ℝ) : Fin 4 → ℝ := fun i => (u + 5 * b ^ 2 / u) * eVec i

/-- Residual of the *active* member of the pair with parameters `(b, u)`. -/
noncomputable def residFamC (b u : ℝ) : Fin 4 → ℝ :=
  fun i => (u - 5 * b ^ 2 / u) * eVec i + (20 * b) * ztA i

/-- Rate profile of the suppressed member. -/
noncomputable def rateFamB (b u : ℝ) : Fin 4 → ℝ := fun i => b * foot i + residFamB b u i

/-- Rate profile of the active member. -/
noncomputable def rateFamC (b u : ℝ) : Fin 4 → ℝ := fun i => b * foot i + residFamC b u i

lemma rateFamB_decomp (b u : ℝ) (i : Fin 4) :
    rateFamB b u i = 0 + b * foot i + residFamB b u i := by
  simp [rateFamB]

lemma rateFamC_decomp (b u : ℝ) (i : Fin 4) :
    rateFamC b u i = 0 + b * foot i + residFamC b u i := by
  simp [rateFamC]

/-- At the base parameters the family reproduces the catalog's suppressed population. -/
theorem rateFamB_at_base : rateFamB (1/10) (1/2) = rateSB := by
  funext i
  fin_cases i <;>
    norm_num [rateFamB, residFamB, eVec, foot, rateSB]

/-- At the base parameters the family reproduces the catalog's active population. -/
theorem rateFamC_at_base : rateFamC (1/10) (1/2) = rateSC := by
  funext i
  fin_cases i <;>
    norm_num [rateFamC, residFamC, eVec, ztA, foot, rateSC]

theorem residFamB_at_base : residFamB (1/10) (1/2) = residSB := by
  funext i
  fin_cases i <;> norm_num [residFamB, eVec, residSB]

theorem residFamC_at_base : residFamC (1/10) (1/2) = residSC := by
  funext i
  fin_cases i <;> norm_num [residFamC, eVec, ztA, residSC]

/-! ## 2. Moments of the family -/

lemma wvar_foot : wvar pU foot = 5/4 := by
  norm_num [wvar, wcov, wmean, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, foot]

lemma wvar_pp : wvar pU pp = 1/4 := by
  norm_num [wvar, wcov, wmean, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, pp]

lemma wcov_foot_pp : wcov pU foot pp = -1/2 := by
  norm_num [wcov, wmean, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, foot, pp]

lemma wip_ztA_ztA : wip pU ztA ztA = 1/20 := by
  norm_num [wip, Fin.sum_univ_four, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons, pU, ztA]

lemma residFamB_isResidual (b u : ℝ) : IsResidual pU foot (residFamB b u) := by
  refine ⟨?_, ?_⟩ <;>
    · simp only [wip, residFamB, eVec, foot, pU, Fin.sum_univ_four, Matrix.cons_val_zero,
        Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
        Matrix.tail_cons]
      ring

lemma residFamC_isResidual (b u : ℝ) : IsResidual pU foot (residFamC b u) := by
  refine ⟨?_, ?_⟩ <;>
    · simp only [wip, residFamC, eVec, ztA, foot, pU, Fin.sum_univ_four, Matrix.cons_val_zero,
        Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
        Matrix.tail_cons]
      ring

/-- The common denominator-cleared rate variance of both members of the pair. -/
noncomputable def famVar (b u : ℝ) : ℝ := (5 * b ^ 2 * u ^ 2 + 4 * (u ^ 2 + 5 * b ^ 2) ^ 2) / (4 * u ^ 2)

lemma famVar_pos {b u : ℝ} (hu : 0 < u) : 0 < famVar b u := by
  have h1 : 0 < u ^ 2 := by positivity
  have h2 : 0 < (u ^ 2 + 5 * b ^ 2) ^ 2 := by positivity
  have : 0 ≤ 5 * b ^ 2 * u ^ 2 := by positivity
  rw [famVar]
  apply div_pos <;> linarith

lemma wvar_rateFamB {b u : ℝ} (hu : u ≠ 0) : wvar pU (rateFamB b u) = famVar b u := by
  simp only [wvar, wcov, wmean, rateFamB, residFamB, eVec, foot, pU, famVar, Fin.sum_univ_four,
    Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons]
  field_simp
  ring

lemma wvar_rateFamC {b u : ℝ} (hu : u ≠ 0) : wvar pU (rateFamC b u) = famVar b u := by
  simp only [wvar, wcov, wmean, rateFamC, residFamC, eVec, ztA, foot, pU, famVar,
    Fin.sum_univ_four, Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two,
    Matrix.cons_val_three, Matrix.head_cons, Matrix.tail_cons]
  field_simp
  ring

/-- **Equal rate variances.**  The `±5b²/u` shift in the `eVec` coefficient exactly
compensates the energy the active member puts along the partialled feature. -/
theorem wvar_rateFamB_eq_wvar_rateFamC {b u : ℝ} (hu : u ≠ 0) :
    wvar pU (rateFamB b u) = wvar pU (rateFamC b u) := by
  rw [wvar_rateFamB hu, wvar_rateFamC hu]

lemma wcov_foot_rateFamB {b u : ℝ} (hu : u ≠ 0) : wcov pU foot (rateFamB b u) = 5 * b / 4 := by
  simp only [wcov, wmean, rateFamB, residFamB, eVec, foot, pU, Fin.sum_univ_four,
    Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons]
  field_simp
  ring

lemma wcov_foot_rateFamC {b u : ℝ} (hu : u ≠ 0) : wcov pU foot (rateFamC b u) = 5 * b / 4 := by
  simp only [wcov, wmean, rateFamC, residFamC, eVec, ztA, foot, pU, Fin.sum_univ_four,
    Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons]
  field_simp
  ring

lemma wcov_pp_rateFamB {b u : ℝ} (hu : u ≠ 0) : wcov pU pp (rateFamB b u) = -(b/2) := by
  simp only [wcov, wmean, rateFamB, residFamB, eVec, pp, foot, pU, Fin.sum_univ_four,
    Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons]
  field_simp
  ring

lemma wcov_pp_rateFamC {b u : ℝ} (hu : u ≠ 0) : wcov pU pp (rateFamC b u) = b/2 := by
  simp only [wcov, wmean, rateFamC, residFamC, eVec, ztA, pp, foot, pU, Fin.sum_univ_four,
    Matrix.cons_val_zero, Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three,
    Matrix.head_cons, Matrix.tail_cons]
  field_simp
  ring

/-- **The sign flip, for every parameter value.**  The signed prime-power covariance of the
two members of a pair are exact negatives of each other. -/
theorem wcov_pp_fam_sign_flip {b u : ℝ} (hu : u ≠ 0) :
    wcov pU pp (rateFamB b u) = -wcov pU pp (rateFamC b u) := by
  rw [wcov_pp_rateFamB hu, wcov_pp_rateFamC hu]

/-! ## 3. Identical dial readings, different increments -/

/-- The footprint dial reading agrees across each pair. -/
theorem R2_foot_fam_agree {b u : ℝ} (hu : u ≠ 0) :
    R2 pU foot (rateFamB b u) = R2 pU foot (rateFamC b u) := by
  rw [R2, R2, wcov_foot_rateFamB hu, wcov_foot_rateFamC hu, wvar_rateFamB hu, wvar_rateFamC hu]

/-- The marginal prime-power dial reading agrees across each pair: `R²` cannot see the sign
flip of `σ_zy`. -/
theorem R2_pp_fam_agree {b u : ℝ} (hu : u ≠ 0) :
    R2 pU pp (rateFamB b u) = R2 pU pp (rateFamC b u) := by
  rw [R2, R2, wcov_pp_rateFamB hu, wcov_pp_rateFamC hu, wvar_rateFamB hu, wvar_rateFamC hu]
  norm_num

/-- Closed form of the footprint dial reading along the family. -/
theorem R2_foot_famB_formula {b u : ℝ} (hu : 0 < u) :
    R2 pU foot (rateFamB b u)
      = 5 * b ^ 2 * u ^ 2 / (5 * b ^ 2 * u ^ 2 + 4 * (u ^ 2 + 5 * b ^ 2) ^ 2) := by
  have hden : (0 : ℝ) < 5 * b ^ 2 * u ^ 2 + 4 * (u ^ 2 + 5 * b ^ 2) ^ 2 := by
    have h1 : (0 : ℝ) < (u ^ 2 + 5 * b ^ 2) ^ 2 := by positivity
    have h2 : (0 : ℝ) ≤ 5 * b ^ 2 * u ^ 2 := by positivity
    linarith
  rw [R2, wcov_foot_rateFamB hu.ne', wvar_foot, wvar_rateFamB hu.ne', famVar]
  field_simp

/-- The suppressed member has partial covariance exactly zero. -/
lemma wip_residFamB_ztA (b u : ℝ) : wip pU (residFamB b u) ztA = 0 := by
  simp only [wip, residFamB, eVec, ztA, pU, Fin.sum_univ_four, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons]
  ring

/-- The active member has partial covariance `b`. -/
lemma wip_residFamC_ztA (b u : ℝ) : wip pU (residFamC b u) ztA = b := by
  simp only [wip, residFamC, eVec, ztA, pU, Fin.sum_univ_four, Matrix.cons_val_zero,
    Matrix.cons_val_one, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.head_cons,
    Matrix.tail_cons]
  ring

/-- Increment of the suppressed member: exactly zero, for every parameter value. -/
theorem pgain_famB (b u : ℝ) : pgain pU (residFamB b u) ztA = 0 := by
  rw [pgain, wip_residFamB_ztA]
  simp

/-- **Increment of the active member, by the moment route.**  Computed from the catalog's
`pgain_moment_formula` — five second moments in, `20b²` out — rather than by re-evaluating
the inner products. -/
theorem pgain_famC_via_moments {b u : ℝ} (hu : 0 < u) :
    pgain pU (residFamC b u) ztA = 20 * b ^ 2 := by
  have hmom := pgain_moment_formula (p := pU) (x := foot) (y := rateFamC b u)
    (r := residFamC b u) (z := pp) (zt := ztA) (a := 0) (b := b) pU_total
    (rateFamC_decomp b u) (residFamC_isResidual b u) pp_isPartial (by rw [wvar_foot]; norm_num)
  rw [hmom, wvar_foot, wvar_pp, wcov_foot_pp, wcov_foot_rateFamC hu.ne']
  have hzy : wcov pU pp (rateFamC b u) = b / 2 := wcov_pp_rateFamC hu.ne'
  rw [hzy]
  ring

/-- Increment of the active member, as a share of the rate variance. -/
theorem increment_famC {b u : ℝ} (hu : 0 < u) :
    pgain pU (residFamC b u) ztA / wvar pU (rateFamC b u)
      = 80 * b ^ 2 * u ^ 2 / (5 * b ^ 2 * u ^ 2 + 4 * (u ^ 2 + 5 * b ^ 2) ^ 2) := by
  have hden : (0 : ℝ) < 5 * b ^ 2 * u ^ 2 + 4 * (u ^ 2 + 5 * b ^ 2) ^ 2 := by
    have h1 : (0 : ℝ) < (u ^ 2 + 5 * b ^ 2) ^ 2 := by positivity
    have h2 : (0 : ℝ) ≤ 5 * b ^ 2 * u ^ 2 := by positivity
    linarith
  rw [pgain_famC_via_moments hu, wvar_rateFamC hu.ne', famVar]
  field_simp
  ring

/-- Increment of the suppressed member, as a share of the rate variance: zero. -/
theorem increment_famB (b u : ℝ) :
    pgain pU (residFamB b u) ztA / wvar pU (rateFamB b u) = 0 := by
  rw [pgain_famB]
  simp

/-! ## 4. No sign-blind predictor exists -/

lemma wvar_rateFamB_pos {b u : ℝ} (hu : 0 < u) : 0 < wvar pU (rateFamB b u) := by
  rw [wvar_rateFamB hu.ne']; exact famVar_pos hu

lemma wvar_rateFamC_pos {b u : ℝ} (hu : 0 < u) : 0 < wvar pU (rateFamC b u) := by
  rw [wvar_rateFamC hu.ne']; exact famVar_pos hu

/-- **Inadmissibility of sign-blind dial reporting.**  There is no function `F` of the three
variance-share readings `R²(x,y)`, `R²(z,y)`, `R²(x,z)` that returns the augmentation
increment `ΔR²` on every finite population.  The two members of any pair in the family
(in particular the catalog pair `rateSB`, `rateSC`) present `F` with identical arguments and
demand different values. -/
theorem no_sign_blind_predictor :
    ¬ ∃ F : ℝ → ℝ → ℝ → ℝ,
      ∀ (p x y r z zt : Fin 4 → ℝ) (a b : ℝ),
        (∀ i, 0 ≤ p i) → (∑ i, p i = 1) →
        (∀ i, y i = a + b * x i + r i) → IsResidual p x r → IsPartial p x z zt →
        0 < wvar p x → 0 < wvar p y → 0 < wvar p z → 0 < wip p zt zt →
        pgain p r zt / wvar p y = F (R2 p x y) (R2 p z y) (R2 p x z) := by
  rintro ⟨F, hF⟩
  have hvx : 0 < wvar pU foot := by rw [wvar_foot]; norm_num
  have hvz : 0 < wvar pU pp := by rw [wvar_pp]; norm_num
  have hzt : 0 < wip pU ztA ztA := by rw [wip_ztA_ztA]; norm_num
  have hu : (0 : ℝ) < 1/2 := by norm_num
  have hB := hF pU foot (rateFamB (1/10) (1/2)) (residFamB (1/10) (1/2)) pp ztA 0 (1/10)
    pU_nonneg pU_total (rateFamB_decomp _ _) (residFamB_isResidual _ _) pp_isPartial
    hvx (wvar_rateFamB_pos hu) hvz hzt
  have hC := hF pU foot (rateFamC (1/10) (1/2)) (residFamC (1/10) (1/2)) pp ztA 0 (1/10)
    pU_nonneg pU_total (rateFamC_decomp _ _) (residFamC_isResidual _ _) pp_isPartial
    hvx (wvar_rateFamC_pos hu) hvz hzt
  rw [R2_foot_fam_agree (by norm_num), R2_pp_fam_agree (by norm_num)] at hB
  rw [increment_famB] at hB
  rw [increment_famC hu] at hC
  rw [← hB] at hC
  norm_num at hC

/-! ## 5. Robustness: the witness set contains an open set -/

/-- **Uniform gap on a neighbourhood.**  For every parameter pair in the box
`|b − 1/10| < 1/100`, `|u − 1/2| < 1/100`, the active member's increment is at least `1/3`
while the suppressed member's is `0`. -/
theorem increment_gap_uniform {b u : ℝ} (hb1 : 9/100 < b) (hb2 : b < 11/100)
    (hu1 : 49/100 < u) (hu2 : u < 51/100) :
    1/3 ≤ pgain pU (residFamC b u) ztA / wvar pU (rateFamC b u)
        - pgain pU (residFamB b u) ztA / wvar pU (rateFamB b u) := by
  have hu : 0 < u := by linarith
  have hden : (0 : ℝ) < 5 * b ^ 2 * u ^ 2 + 4 * (u ^ 2 + 5 * b ^ 2) ^ 2 := by
    have h1 : (0 : ℝ) < (u ^ 2 + 5 * b ^ 2) ^ 2 := by positivity
    have h2 : (0 : ℝ) ≤ 5 * b ^ 2 * u ^ 2 := by positivity
    linarith
  rw [increment_famB, increment_famC hu, sub_zero, le_div_iff₀ hden]
  -- reduce to a polynomial inequality on the box
  have hsum : u ^ 2 + 5 * b ^ 2 < 3206/10000 := by nlinarith
  have hsumpos : (0 : ℝ) < u ^ 2 + 5 * b ^ 2 := by positivity
  have hsq : (u ^ 2 + 5 * b ^ 2) ^ 2 < (3206/10000) ^ 2 := by nlinarith
  have hbsq : (9/100 : ℝ) ^ 2 < b ^ 2 := by nlinarith
  have husq : (49/100 : ℝ) ^ 2 < u ^ 2 := by nlinarith
  have hbu : (9/100 : ℝ) ^ 2 * (49/100) ^ 2 < b ^ 2 * u ^ 2 := by nlinarith
  nlinarith [hsq, hbu]

/-- **The failure set contains an open set of parameters.**  Around the catalog pair there is
a metric ball of parameter values on which: both members are legitimate populations, their
three dial readings agree exactly, and their increments differ by at least `1/3`.  The
counterexample to sign-blind reporting is therefore robust, not an algebraic accident. -/
theorem sign_blind_failure_contains_open_set :
    ∃ V : Set (ℝ × ℝ), IsOpen V ∧ ((1/10 : ℝ), (1/2 : ℝ)) ∈ V ∧
      ∀ q ∈ V, 0 < q.2 ∧
        R2 pU foot (rateFamB q.1 q.2) = R2 pU foot (rateFamC q.1 q.2) ∧
        R2 pU pp (rateFamB q.1 q.2) = R2 pU pp (rateFamC q.1 q.2) ∧
        wcov pU pp (rateFamB q.1 q.2) = -wcov pU pp (rateFamC q.1 q.2) ∧
        pgain pU (residFamB q.1 q.2) ztA / wvar pU (rateFamB q.1 q.2) = 0 ∧
        1/3 ≤ pgain pU (residFamC q.1 q.2) ztA / wvar pU (rateFamC q.1 q.2) := by
  refine ⟨Metric.ball ((1/10 : ℝ), (1/2 : ℝ)) (1/100), Metric.isOpen_ball, ?_, ?_⟩
  · simp [Metric.mem_ball]
  · rintro ⟨b, u⟩ hq
    have hd : dist ((b, u) : ℝ × ℝ) ((1/10 : ℝ), (1/2 : ℝ)) < 1/100 := Metric.mem_ball.mp hq
    have hb : |b - 1/10| < 1/100 := by
      have := (le_max_left (dist b (1/10)) (dist u (1/2))).trans_lt
        (by rwa [Prod.dist_eq] at hd)
      rwa [Real.dist_eq] at this
    have hu : |u - 1/2| < 1/100 := by
      have := (le_max_right (dist b (1/10)) (dist u (1/2))).trans_lt
        (by rwa [Prod.dist_eq] at hd)
      rwa [Real.dist_eq] at this
    rw [abs_lt] at hb hu
    have hb1 : 9/100 < b := by linarith [hb.1]
    have hb2 : b < 11/100 := by linarith [hb.2]
    have hu1 : 49/100 < u := by linarith [hu.1]
    have hu2 : u < 51/100 := by linarith [hu.2]
    have hupos : (0 : ℝ) < u := by linarith
    refine ⟨hupos, R2_foot_fam_agree hupos.ne', R2_pp_fam_agree hupos.ne',
      wcov_pp_fam_sign_flip hupos.ne', increment_famB _ _, ?_⟩
    have hgap := increment_gap_uniform hb1 hb2 hu1 hu2
    rw [increment_famB] at hgap
    linarith

/-- **The ball is a genuine open set of moment data.**  The dial readings are not constant on
the neighbourhood, so the witnessing pairs occupy an open region of moment space rather than
one repeated reading. -/
theorem dial_readings_nonconstant_on_ball :
    ((19/200 : ℝ), (1/2 : ℝ)) ∈ Metric.ball ((1/10 : ℝ), (1/2 : ℝ)) (1/100) ∧
      R2 pU foot (rateFamB (19/200) (1/2)) ≠ R2 pU foot (rateFamB (1/10) (1/2)) := by
  constructor
  · rw [Metric.mem_ball, Prod.dist_eq, Real.dist_eq, Real.dist_eq]
    norm_num
  · rw [R2_foot_famB_formula (by norm_num), R2_foot_famB_formula (by norm_num)]
    norm_num

/-! ## 6. The positive counterpart: one sign bit separates the pair -/

/-- **What a protocol must record.**  The correlation triple products of the two members of
each pair are nonzero and of opposite sign; recording that single bit (equivalently:
recording the *signed* covariance `σ_zy`) distinguishes the suppressed from the active
population, which no amount of sign-blind dial data can do. -/
theorem sign_bit_suffices_on_family {b u : ℝ} (hu : 0 < u) (hb : 0 < b) :
    tripleProd pU foot (rateFamC b u) pp < 0 ∧ tripleProd pU foot (rateFamB b u) pp > 0 := by
  have hvx : 0 < wvar pU foot := by rw [wvar_foot]; norm_num
  have hvz : 0 < wvar pU pp := by rw [wvar_pp]; norm_num
  have hsx : 0 < Real.sqrt (wvar pU foot) := Real.sqrt_pos.mpr hvx
  have hsz : 0 < Real.sqrt (wvar pU pp) := Real.sqrt_pos.mpr hvz
  have hxz : wcorr pU foot pp < 0 := by
    rw [wcorr_eq_div_sqrt_mul_sqrt hvx.le, wcov_foot_pp]
    apply div_neg_of_neg_of_pos <;> [norm_num; positivity]
  constructor
  · have hvy : 0 < wvar pU (rateFamC b u) := wvar_rateFamC_pos hu
    have hsy : 0 < Real.sqrt (wvar pU (rateFamC b u)) := Real.sqrt_pos.mpr hvy
    have hxy : 0 < wcorr pU foot (rateFamC b u) := by
      rw [wcorr_eq_div_sqrt_mul_sqrt hvx.le, wcov_foot_rateFamC hu.ne']
      positivity
    have hzy : 0 < wcorr pU pp (rateFamC b u) := by
      rw [wcorr_eq_div_sqrt_mul_sqrt hvz.le, wcov_pp_rateFamC hu.ne']
      positivity
    have : wcorr pU foot (rateFamC b u) * wcorr pU foot pp < 0 := mul_neg_of_pos_of_neg hxy hxz
    exact mul_neg_of_neg_of_pos this hzy
  · have hvy : 0 < wvar pU (rateFamB b u) := wvar_rateFamB_pos hu
    have hsy : 0 < Real.sqrt (wvar pU (rateFamB b u)) := Real.sqrt_pos.mpr hvy
    have hxy : 0 < wcorr pU foot (rateFamB b u) := by
      rw [wcorr_eq_div_sqrt_mul_sqrt hvx.le, wcov_foot_rateFamB hu.ne']
      positivity
    have hzy : wcorr pU pp (rateFamB b u) < 0 := by
      rw [wcorr_eq_div_sqrt_mul_sqrt hvz.le, wcov_pp_rateFamB hu.ne']
      apply div_neg_of_neg_of_pos
      · linarith
      · positivity
    have : wcorr pU foot (rateFamB b u) * wcorr pU foot pp < 0 := mul_neg_of_pos_of_neg hxy hxz
    exact mul_pos_of_neg_of_neg this hzy

end ExtendedDial

end Catalog.UniformDial