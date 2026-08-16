/-
# Mahler compactness for the moduli space of tori

`Geometry.Teichmuller.SystoleFunctional` builds the systolic functional `sys` of a marked torus
and shows that `log sys` is `2`-Lipschitz for the moduli distance, and
`Geometry.Teichmuller.CuspExhaustion` shows that `−log sys` is a proper exhaustion function of
the moduli space up to the additive constant `(1/2) · log 5`.  Both statements are *metric*.
This file turns them into *topological* statements: the thick part of the moduli space is
compact, and the moduli space is a proper metric space.

Main results:

* `Teichmuller.abs_log_sys_sub_le_dist` : `|log (sys z) − log (sys w)| ≤ dist z w`, i.e. the
  logarithmic systole is `1`-Lipschitz for the hyperbolic (equivalently, `2`-Lipschitz for the
  Teichmüller) metric.  This upgrades `log_sys_div_le_moduliDist` to a two-sided estimate.
* `Teichmuller.lipschitzWith_log_sys`, `Teichmuller.continuous_sys` : consequently `sys` is a
  continuous function on the Teichmüller space (a fact which is *not* formal: `sys` is defined
  as an infimum over the infinite set of nonzero lattice vectors).
* `Teichmuller.isCompact_fdThick` : for `ε > 0` the `ε`-thick part of the standard fundamental
  domain, `𝒟 ∩ {sys ≥ ε}`, is compact.
* `Teichmuller.mahler_compactness` : **Mahler's compactness criterion for rank-two lattices.**
  For every `ε > 0` there is a compact `K ⊆ ℍ` such that every marked torus with `sys ≥ ε` has a
  mapping-class-group translate in `K`; that is, the thick part of the moduli space is compact.
* `Teichmuller.lipschitzWith_moduliDist_rho`, `Teichmuller.continuous_moduliDist_rho` : the
  distance to the hexagonal point is `1/2`-Lipschitz, hence continuous.
* `Teichmuller.isCompact_moduliBall`, `Teichmuller.exists_smul_mem_moduliBall` : closed balls of
  the moduli space are compact, i.e. **the moduli space of tori is a proper metric space**.
* `Teichmuller.exists_isGreatest_sys_of_isCompact` and
  `Teichmuller.exists_max_sys_moduliBall` : the systole attains a maximum on every compact set
  and on every ball of the moduli space.

-- !-- Lab Notes -- !--
Hypothesizer (D4b): the metric properness of `−log sys` proved in `CuspExhaustion.lean` should
be equivalent to genuine topological compactness of the thick part — Mahler's criterion.
Experimenter: the missing analytic ingredient is *continuity* of `sys`, which is not obvious
from the definition (an infimum over `ℤ² ∖ 0`), but which drops out of the metric estimate
`log (sys z / sys w) ≤ 2 · moduliDist z w` once it is symmetrized: for any `z, w`,
`|log sys z − log sys w| ≤ 2 · moduliDist z w ≤ 2 · teichDist z w = dist z w`.  So `log ∘ sys`
is `1`-Lipschitz for the hyperbolic metric with no lattice combinatorics at all.
Analyst: with continuity in hand, the thick part of the fundamental domain is closed, and
`sys w = 1 / Im w` on `𝒟` (`sys_eq_one_div_im_of_fd`) confines it to the compact box
`|Re w| ≤ 1/2`, `√3/2 ≤ Im w ≤ 1/ε`.  Compactness of such a box in `ℍ` is transported from `ℂ`
along the open embedding `ℍ ↪ ℂ`.
Critic: the statement must be checked to be non-vacuous — `𝒟 ∩ {sys ≥ ε}` is nonempty for
`ε ≤ 2/√3` since it contains `ρ` (`sys_rho`), and the compact set produced by
`mahler_compactness` really does receive *every* `ε`-thick torus, not merely those already in
`𝒟`.  Both points are recorded as `rho_mem_fdThick` and in the statement itself.
-/
import Mathlib
import Geometry.Teichmuller.CuspExhaustion

namespace Teichmuller

open Complex UpperHalfPlane Matrix MatrixGroups
open scoped NNReal

/-! ### The logarithmic systole is Lipschitz -/

/-- **Two-sided Lipschitz estimate for the systole.**  `|log (sys z) − log (sys w)| ≤ dist z w`;
equivalently `log sys` is `2`-Lipschitz for the Teichmüller metric `dist / 2`. -/
theorem abs_log_sys_sub_le_dist (z w : ℍ) :
    |Real.log (sys z) - Real.log (sys w)| ≤ dist z w := by
  have key : ∀ a b : ℍ, sys b ≤ sys a →
      Real.log (sys a) - Real.log (sys b) ≤ dist a b := by
    intro a b hab
    have h1 : Real.log (sys a / sys b) ≤ 2 * moduliDist a b :=
      log_sys_div_le_moduliDist a b hab
    have h2 : moduliDist a b ≤ teichDist a b := moduliDist_le_teichDist a b
    have h3 : teichDist a b = dist a b / 2 := teichDist_eq_half_dist a b
    have h4 : Real.log (sys a / sys b) = Real.log (sys a) - Real.log (sys b) :=
      Real.log_div (ne_of_gt (sys_pos a)) (ne_of_gt (sys_pos b))
    rw [h4] at h1
    linarith
  rcases le_total (sys w) (sys z) with h | h
  · rw [abs_le]
    refine ⟨?_, key z w h⟩
    have hmono : Real.log (sys w) ≤ Real.log (sys z) :=
      Real.log_le_log (sys_pos w) h
    have : (0:ℝ) ≤ dist z w := dist_nonneg
    linarith
  · rw [abs_le]
    refine ⟨?_, ?_⟩
    · have := key w z h
      rw [dist_comm] at this
      linarith
    · have hmono : Real.log (sys z) ≤ Real.log (sys w) :=
        Real.log_le_log (sys_pos z) h
      have : (0:ℝ) ≤ dist z w := dist_nonneg
      linarith

/-- `log ∘ sys` is `1`-Lipschitz for the hyperbolic metric of the Teichmüller space. -/
theorem lipschitzWith_log_sys : LipschitzWith 1 (fun z : ℍ => Real.log (sys z)) := by
  refine LipschitzWith.of_dist_le_mul fun z w => ?_
  simpa [Real.dist_eq] using abs_log_sys_sub_le_dist z w

theorem continuous_log_sys : Continuous fun z : ℍ => Real.log (sys z) :=
  lipschitzWith_log_sys.continuous

/-- **The systolic functional is continuous.**  It is defined as an infimum over the infinitely
many nonzero lattice vectors, so continuity is a genuine (if soft) analytic statement; it
follows from the Lipschitz estimate `abs_log_sys_sub_le_dist`. -/
theorem continuous_sys : Continuous sys := by
  have hEq : sys = fun z : ℍ => Real.exp (Real.log (sys z)) := by
    funext z
    rw [Real.exp_log (sys_pos z)]
  rw [hEq]
  exact Real.continuous_exp.comp continuous_log_sys

/-- The `ε`-thick part of the Teichmüller space is closed. -/
theorem isClosed_thick (eps : ℝ) : IsClosed {tau : ℍ | eps ≤ sys tau} :=
  isClosed_le continuous_const continuous_sys

/-! ### Compactness of boxes in `ℍ` -/

/-- A closed coordinate box lying strictly above the real axis is a compact subset of `ℍ`. -/
theorem isCompact_box {a b : ℝ} (ha : 0 < a) :
    IsCompact {w : ℍ | |w.re| ≤ 1 / 2 ∧ a ≤ w.im ∧ w.im ≤ b} := by
  rw [UpperHalfPlane.isOpenEmbedding_coe.isEmbedding.isCompact_iff]
  have himg : UpperHalfPlane.coe '' {w : ℍ | |w.re| ≤ 1 / 2 ∧ a ≤ w.im ∧ w.im ≤ b}
      = {z : ℂ | |z.re| ≤ 1 / 2} ∩ ({z : ℂ | a ≤ z.im} ∩ {z : ℂ | z.im ≤ b}) := by
    ext z
    constructor
    · rintro ⟨w, hw, rfl⟩
      exact ⟨hw.1, hw.2.1, hw.2.2⟩
    · rintro ⟨h1, h2, h3⟩
      exact ⟨⟨z, lt_of_lt_of_le ha h2⟩, ⟨h1, h2, h3⟩, rfl⟩
  rw [himg]
  refine Metric.isCompact_of_isClosed_isBounded ?_ ?_
  · exact (isClosed_le (continuous_abs.comp Complex.continuous_re) continuous_const).inter
      ((isClosed_le continuous_const Complex.continuous_im).inter
        (isClosed_le Complex.continuous_im continuous_const))
  · refine (Metric.isBounded_iff_subset_closedBall 0).mpr ⟨1 / 2 + |a| + |b|, ?_⟩
    rintro z ⟨h1, h2, h3⟩
    simp only [Set.mem_setOf_eq] at h1 h2 h3
    simp only [Metric.mem_closedBall, dist_zero_right]
    have him : |z.im| ≤ |a| + |b| := by
      rw [abs_le]
      constructor
      · have h4 := le_trans (neg_abs_le a) h2
        have h5 := abs_nonneg b
        linarith
      · have h4 := le_trans h3 (le_abs_self b)
        have h5 := abs_nonneg a
        linarith
    calc ‖z‖ ≤ |z.re| + |z.im| := Complex.norm_le_abs_re_add_abs_im z
      _ ≤ 1 / 2 + (|a| + |b|) := by linarith
      _ = 1 / 2 + |a| + |b| := by ring

/-! ### The thick part of the fundamental domain -/

/-- The `ε`-thick part of the standard fundamental domain of the modular group. -/
def fdThick (eps : ℝ) : Set ℍ := {w : ℍ | w ∈ ModularGroup.fd ∧ eps ≤ sys w}

theorem mem_fdThick_iff {eps : ℝ} {w : ℍ} :
    w ∈ fdThick eps ↔ (1 ≤ Complex.normSq (w : ℂ) ∧ |w.re| ≤ 1 / 2) ∧ eps ≤ sys w := by
  constructor
  · rintro ⟨hfd, hs⟩
    exact ⟨⟨hfd.1, by simpa using hfd.2⟩, hs⟩
  · rintro ⟨⟨h1, h2⟩, hs⟩
    exact ⟨⟨h1, by simpa using h2⟩, hs⟩

/-- The hexagonal torus is in the thick part whenever `ε ≤ 2/√3`, so the thick part is not
empty. -/
theorem rho_mem_fdThick {eps : ℝ} (heps : eps ≤ 2 / Real.sqrt 3) : rho ∈ fdThick eps := by
  refine mem_fdThick_iff.mpr ⟨⟨?_, ?_⟩, ?_⟩
  · have hnsq : Complex.normSq (rho : ℂ) = rho.re ^ 2 + rho.im ^ 2 := by
      rw [Complex.normSq_apply, UpperHalfPlane.coe_re, UpperHalfPlane.coe_im]; ring
    rw [hnsq, rho_re, rho_im]
    have hs3 : Real.sqrt 3 ^ 2 = 3 := Real.sq_sqrt (by norm_num)
    nlinarith
  · rw [rho_re]
    rw [abs_le]
    constructor <;> norm_num
  · rw [sys_rho]; exact heps

/-- Inside the fundamental domain a lower bound on the systole is an upper bound on the
imaginary part. -/
theorem im_le_of_mem_fdThick {eps : ℝ} (heps : 0 < eps) {w : ℍ} (hw : w ∈ fdThick eps) :
    w.im ≤ 1 / eps := by
  obtain ⟨⟨hns, hre⟩, hs⟩ := mem_fdThick_iff.mp hw
  have hsys : sys w = 1 / w.im := sys_eq_one_div_im_of_fd w hre hns
  rw [hsys] at hs
  have him := w.im_pos
  rw [le_div_iff₀ him] at hs
  rw [le_div_iff₀ heps]
  linarith

/-- **The thick part of the fundamental domain is compact.** -/
theorem isCompact_fdThick {eps : ℝ} (heps : 0 < eps) : IsCompact (fdThick eps) := by
  have hsub : fdThick eps ⊆
      {w : ℍ | |w.re| ≤ 1 / 2 ∧ Real.sqrt 3 / 2 ≤ w.im ∧ w.im ≤ 1 / eps} := by
    intro w hw
    obtain ⟨⟨hns, hre⟩, _⟩ := mem_fdThick_iff.mp hw
    exact ⟨hre, sqrt_three_div_two_le_im_of_fd w hre hns, im_le_of_mem_fdThick heps hw⟩
  have hclosed : IsClosed (fdThick eps) := by
    have hfd : IsClosed (ModularGroup.fd) := by
      have h : ModularGroup.fd
          = {w : ℍ | 1 ≤ Complex.normSq (w : ℂ)} ∩ {w : ℍ | |w.re| ≤ 1 / 2} := rfl
      rw [h]
      refine IsClosed.inter (isClosed_le continuous_const ?_) (isClosed_le ?_ continuous_const)
      · exact Complex.continuous_normSq.comp UpperHalfPlane.continuous_coe
      · exact continuous_abs.comp (Complex.continuous_re.comp UpperHalfPlane.continuous_coe)
    exact hfd.inter (isClosed_thick eps)
  have hs3 : 0 < Real.sqrt 3 / 2 := by positivity
  exact (isCompact_box hs3).of_isClosed_subset hclosed hsub

/-- **Mahler's compactness criterion for marked tori.**  For every `ε > 0` there is a compact
subset `K` of the Teichmüller space such that every marked torus whose systole is at least `ε`
is carried into `K` by some mapping class: the `ε`-thick part of the moduli space is compact.
-/
theorem mahler_compactness {eps : ℝ} (heps : 0 < eps) :
    ∃ K : Set ℍ, IsCompact K ∧ (∀ w ∈ K, eps ≤ sys w) ∧
      ∀ tau : ℍ, eps ≤ sys tau → ∃ g : SL(2, ℤ), g • tau ∈ K := by
  refine ⟨fdThick eps, isCompact_fdThick heps, fun w hw => hw.2, fun tau htau => ?_⟩
  obtain ⟨g, hg⟩ := ModularGroup.exists_smul_mem_fd tau
  exact ⟨g, hg, by rwa [sys_smul]⟩

/-! ### Properness of the moduli space -/

/-- The distance to the hexagonal point in the moduli space is `1/2`-Lipschitz on the
Teichmüller space. -/
theorem abs_moduliDist_rho_sub_le (z w : ℍ) :
    |moduliDist rho z - moduliDist rho w| ≤ dist z w / 2 := by
  have h1 : moduliDist rho z ≤ moduliDist rho w + moduliDist w z :=
    moduliDist_triangle rho w z
  have h2 : moduliDist rho w ≤ moduliDist rho z + moduliDist z w :=
    moduliDist_triangle rho z w
  have h3 : moduliDist z w ≤ teichDist z w := moduliDist_le_teichDist z w
  have h4 : moduliDist w z ≤ teichDist w z := moduliDist_le_teichDist w z
  have h5 : teichDist z w = dist z w / 2 := teichDist_eq_half_dist z w
  have h6 : teichDist w z = dist z w / 2 := by
    rw [teichDist_eq_half_dist, dist_comm]
  rw [abs_le]
  constructor <;> linarith

theorem lipschitzWith_moduliDist_rho :
    LipschitzWith (1 / 2 : ℝ≥0) (fun w : ℍ => moduliDist rho w) := by
  refine LipschitzWith.of_dist_le_mul fun z w => ?_
  have h := abs_moduliDist_rho_sub_le z w
  simp only [Real.dist_eq]
  have hcast : ((1 / 2 : ℝ≥0) : ℝ) = 1 / 2 := by norm_num
  rw [hcast]
  linarith

theorem continuous_moduliDist_rho : Continuous fun w : ℍ => moduliDist rho w :=
  lipschitzWith_moduliDist_rho.continuous

/-- **Closed balls of the moduli space are compact.**  The intersection of the standard
fundamental domain with a closed ball around the hexagonal point is compact. -/
theorem isCompact_moduliBall (R : ℝ) :
    IsCompact (ModularGroup.fd ∩ {w : ℍ | moduliDist rho w ≤ R}) := by
  have hsub : ModularGroup.fd ∩ {w : ℍ | moduliDist rho w ≤ R} ⊆
      fdThick (Real.exp (-(2 * R))) := by
    rintro w ⟨hfd, hball⟩
    exact ⟨hfd, sys_ge_of_moduliDist_le hball⟩
  have hclosed : IsClosed (ModularGroup.fd ∩ {w : ℍ | moduliDist rho w ≤ R}) := by
    have hfd : IsClosed (ModularGroup.fd) := by
      have h : ModularGroup.fd
          = {w : ℍ | 1 ≤ Complex.normSq (w : ℂ)} ∩ {w : ℍ | |w.re| ≤ 1 / 2} := rfl
      rw [h]
      refine IsClosed.inter (isClosed_le continuous_const ?_) (isClosed_le ?_ continuous_const)
      · exact Complex.continuous_normSq.comp UpperHalfPlane.continuous_coe
      · exact continuous_abs.comp (Complex.continuous_re.comp UpperHalfPlane.continuous_coe)
    exact hfd.inter (isClosed_le continuous_moduliDist_rho continuous_const)
  exact (isCompact_fdThick (Real.exp_pos _)).of_isClosed_subset hclosed hsub

/-- **The moduli space of tori is proper.**  Every marked torus at moduli distance at most `R`
from the hexagonal point has a mapping class group translate in one fixed compact set. -/
theorem exists_smul_mem_moduliBall (R : ℝ) (tau : ℍ) (h : moduliDist rho tau ≤ R) :
    ∃ g : SL(2, ℤ), g • tau ∈ ModularGroup.fd ∩ {w : ℍ | moduliDist rho w ≤ R} := by
  obtain ⟨g, hg⟩ := ModularGroup.exists_smul_mem_fd tau
  refine ⟨g, hg, ?_⟩
  have hd : moduliDist rho (g • tau) = moduliDist rho tau := moduliDist_smul_right rho tau g
  show moduliDist rho (g • tau) ≤ R
  rw [hd]
  exact h

/-! ### Consequences of compactness -/

/-- On a nonempty compact set of marked tori the systole attains a maximum. -/
theorem exists_isGreatest_sys_of_isCompact {K : Set ℍ} (hK : IsCompact K) (hne : K.Nonempty) :
    ∃ w ∈ K, ∀ v ∈ K, sys v ≤ sys w := by
  obtain ⟨w, hwK, hw⟩ := hK.exists_isMaxOn hne continuous_sys.continuousOn
  exact ⟨w, hwK, fun v hv => hw hv⟩

/-- The systole attains a maximum on each ball of the moduli space; combined with
`sys_le_hermite` and `sys_rho` this maximum equals `2/√3` as soon as the ball contains `ρ`. -/
theorem exists_max_sys_moduliBall {R : ℝ} (hR : 0 ≤ R) :
    ∃ w ∈ ModularGroup.fd ∩ {v : ℍ | moduliDist rho v ≤ R},
      ∀ v ∈ ModularGroup.fd ∩ {v : ℍ | moduliDist rho v ≤ R}, sys v ≤ sys w := by
  have hne : (ModularGroup.fd ∩ {v : ℍ | moduliDist rho v ≤ R}).Nonempty := by
    refine ⟨rho, ?_, ?_⟩
    · exact (rho_mem_fdThick (le_refl (2 / Real.sqrt 3))).1
    · have : moduliDist rho rho = 0 := by
        have h := moduliDist_self_smul rho 1
        simpa using h
      show moduliDist rho rho ≤ R
      rw [this]; exact hR
  exact exists_isGreatest_sys_of_isCompact (isCompact_moduliBall R) hne

end Teichmuller