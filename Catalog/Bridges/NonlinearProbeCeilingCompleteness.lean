import Bridges.NonlinearProbeCeilingDesign

/-!
# Exactly when is the measurable certificate complete?

Fourth pass over D3.  `NonlinearProbeCeilingD3` proved that a family of repeated-content pairs
whose squared importance gaps outweigh `SS_tot` certifies `ceiling < 1/2`, and
`NonlinearProbeCeilingDesign` showed that the certificate can fail on a population whose ceiling
is `0`.  Between those two facts sits a design question: *for which pooling designs does the
certificate see everything?*  This file answers it exactly, and then builds the dual certificate
that refutes D3 instead of confirming it.

## 1.  Completeness ⟺ at most two windows per content

`certificate_complete_of_fibers_card_le_two`: if no key content occurs in more than two pooled
windows, then `ceiling < 1/2` *implies* the existence of a firing certificate.  The proof takes
`Y` to be the set of contents seen exactly twice, chooses the two windows in each, and observes
that `SS_within` is then exactly half the sum of the gaps, so the certificate threshold is
precisely the ceiling threshold.  Contents seen zero or once contribute nothing
(`fiber_term_eq_zero_of_card_le_one`), which is why they may simply be dropped from `Y`.

## 2.  Three windows per content already breaks it

`tri_certificate_fails`: six windows, two contents, importances `(-6.5, -0.5, -0.5)` and
`(-1.5, 4.5, 4.5)`.  Here `SS_within = 48`, `SS_tot = 85.5`, so the ceiling is `0.4386… < 1/2`,
yet the largest gap inside each fiber is `6`, so every admissible pair family yields at most
`72 < 85.5`.  Together with §1 the completeness threshold is *exactly* two windows per key
content — which is precisely the canonical train/test pooling of
`ssWithin_eq_half_sum_pairs`.  (This refutes the "at most three" guess: a fiber of three points
can hold dispersion `2/3` of its squared diameter, more than the `1/2` a single gap reports.)

## 3.  The dual, refuting certificate

`sum_sq_dev_le_of_mem_Icc` is a Popoviciu-type bound: a block of values inside `[l,u]` has
dispersion at most `card·((u-l)/2)²`.  Summing it fiberwise gives
`ssWithin_le_sum_card_mul_range`, and hence `ceiling_ge_half_of_range_certificate`: *if the
observed within-content ranges satisfy `Σ_y card_y·(u_y - l_y)² ≤ 2·SS_tot`, then the ceiling is
at least `1/2` and the conditional mean is an explicit content head with `R² ≥ 1/2`.*  D3 is
therefore falsifiable as well as confirmable from observables alone — and a refutation comes
with the head it promises, which is exactly the "if false" branch of the roadmap.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the certificate should be complete for small fibers and fail for large
ones; the natural guess was "complete up to fiber size three", since a single gap of a three-point
fiber still sees most of its dispersion.

Experiment (Experimenter): the guess was tested numerically before formalisation and **failed**.
A three-point fiber with values `(-4, 2, 2)` (scaled) has `SS_within = 24` and squared diameter
`36`, so `2·SS_within = 48 > 36`: the gap under-reports.  Choosing the between-content amplitude
so that `SS_tot = 85.5 ∈ [72, 96)` produced the counterexample now formalised as
`tri_certificate_fails`; see `ComputationalEvidence.md` §6.

Analysis (Analyst): the mechanism is the ratio `SS_within / diam²` of a fiber, which is `1/2` for
two points, `2/3` for the extremal three-point configuration, and grows to `card/4`.  The
certificate reports `1/2` per fiber, so it is exact at two and lossy from three on; the same
ratio, read as an upper bound, is what makes §3's refuting certificate work.

Critique (Critic): §1 is stated as an existence result, so it cannot be read as "the certificate
you happened to pick fires"; and §3's certificate needs genuine observed ranges — supplying
`l = -∞`-style loose bounds makes the hypothesis unsatisfiable rather than the conclusion false.
Both certificates are therefore honest one-sided tests, and neither is vacuous: §2 exhibits a
population where the first fails, and the tunable family of `NonlinearProbeCeilingD3` §5 supplies
populations on either side of the second.
-/

namespace Catalog.Bridges.NonlinearProbeCeilingCompleteness

open Finset Catalog.Novelty.ProbeRetentionLimits Catalog.Novelty.NET58RelationalImportance
  Catalog.Bridges.NonlinearProbeCeilingD3 Catalog.Bridges.NonlinearProbeCeilingAnova

/-! ### 1. Completeness when no content is seen in more than two windows -/

section Complete

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ]

omit [Fintype κ] in
lemma fiber_term_eq_zero_of_card_le_one (key : ι → κ) (a : ι → ℝ) (y : κ)
    (h : (fiber key y).card ≤ 1) :
    ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2 = 0 := by
  rcases Nat.le_one_iff_eq_zero_or_eq_one.mp h with h0 | h1
  · rw [Finset.card_eq_zero.mp h0]; simp
  · obtain ⟨i, hi⟩ := Finset.card_eq_one.mp h1
    rw [hi, condMean, hi]
    simp

/-- **Completeness of the certificate in the small-fiber regime.**  If no key content occurs in
more than two pooled windows, then `anovaCeiling < 1/2` is not merely *implied* by a repeated
pair certificate: a certificate always exists.  Measurement and truth coincide exactly in this
design. -/
theorem certificate_complete_of_fibers_card_le_two [DecidableEq ι] (key : ι → κ) (a : ι → ℝ)
    (h : 0 < sstot a) (hsmall : ∀ y, (fiber key y).card ≤ 2)
    (hceil : anovaCeiling key a < 1 / 2) :
    ∃ (Y : Finset κ) (p q : κ → ι), (∀ y ∈ Y, key (p y) = y) ∧ (∀ y ∈ Y, key (q y) = y) ∧
      (∀ y ∈ Y, p y ≠ q y) ∧ sstot a < ∑ y ∈ Y, (a (p y) - a (q y)) ^ 2 := by
  classical
  have hne : Nonempty ι := by
    by_contra hc
    rw [not_nonempty_iff] at hc
    rw [sstot] at h
    simp at h
  have hchoice : ∀ y : κ, ∃ pr : ι × ι, (fiber key y).card = 2 →
      (key pr.1 = y ∧ key pr.2 = y ∧ pr.1 ≠ pr.2 ∧
        ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2 = (a pr.1 - a pr.2) ^ 2 / 2) := by
    intro y
    by_cases h2 : (fiber key y).card = 2
    · obtain ⟨u, v, huv, hs⟩ := Finset.card_eq_two.mp h2
      refine ⟨(u, v), fun _ => ⟨?_, ?_, huv, ?_⟩⟩
      · have : u ∈ fiber key y := by rw [hs]; simp
        exact (Finset.mem_filter.mp this).2
      · have : v ∈ fiber key y := by rw [hs]; simp
        exact (Finset.mem_filter.mp this).2
      · exact fiber_dispersion_pair_eq key a hs huv
    · exact ⟨(Classical.arbitrary ι, Classical.arbitrary ι), fun hc => absurd hc h2⟩
  choose F hF using hchoice
  set Y : Finset κ := Finset.univ.filter (fun y => (fiber key y).card = 2) with hY
  refine ⟨Y, fun y => (F y).1, fun y => (F y).2, ?_, ?_, ?_, ?_⟩
  · exact fun y hy => (hF y (Finset.mem_filter.mp hy).2).1
  · exact fun y hy => (hF y (Finset.mem_filter.mp hy).2).2.1
  · exact fun y hy => (hF y (Finset.mem_filter.mp hy).2).2.2.1
  · have hsplit : ssWithin key a
        = ∑ y ∈ Y, ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2 := by
      rw [ssWithin, hY, ← Finset.sum_filter_add_sum_filter_not Finset.univ
        (fun y => (fiber key y).card = 2)]
      have hzero : ∑ y ∈ Finset.univ.filter (fun y => ¬ (fiber key y).card = 2),
          ∑ k ∈ fiber key y, (a k - condMean key a y) ^ 2 = 0 := by
        refine Finset.sum_eq_zero fun y hy => ?_
        have hy2 : (fiber key y).card ≠ 2 := (Finset.mem_filter.mp hy).2
        exact fiber_term_eq_zero_of_card_le_one key a y
          (by have := hsmall y; omega)
      rw [hzero, add_zero]
    have hpairs : ssWithin key a = (∑ y ∈ Y, (a (F y).1 - a (F y).2) ^ 2) / 2 := by
      rw [hsplit, Finset.sum_div]
      exact Finset.sum_congr rfl fun y hy =>
        (hF y (Finset.mem_filter.mp hy).2).2.2.2
    have hlt := (anovaCeiling_lt_half_iff key a h).mp hceil
    rw [hpairs] at hlt
    linarith

end Complete

/-! ### 2. Incompleteness already at three windows per content -/

section ThreeFibers

/-- Two key contents, each seen in three pooled windows. -/
def triKey : Fin 6 → Fin 2 := ![0, 0, 0, 1, 1, 1]

/-- Importances: within each content the pattern `(-4, 2, 2)` around a content mean `∓5/2`. -/
noncomputable def triImp : Fin 6 → ℝ := ![-13/2, -1/2, -1/2, -3/2, 9/2, 9/2]

lemma tri_fiber0 : fiber triKey 0 = {0, 1, 2} := by decide
lemma tri_fiber1 : fiber triKey 1 = {3, 4, 5} := by decide

lemma tri_mean : mean triImp = 0 := by
  have hsum : ∑ i, triImp i = 0 := by
    simp [triImp, Fin.sum_univ_six]
    norm_num
  rw [mean, hsum]
  simp

lemma tri_sstot : sstot triImp = 171 / 2 := by
  rw [sstot, tri_mean]
  simp [triImp, Fin.sum_univ_six]
  norm_num

lemma tri_condMean0 : condMean triKey triImp 0 = -5/2 := by
  rw [condMean, tri_fiber0]
  simp [triImp]
  norm_num

lemma tri_condMean1 : condMean triKey triImp 1 = 5/2 := by
  rw [condMean, tri_fiber1]
  simp [triImp]
  norm_num

lemma tri_ssWithin : ssWithin triKey triImp = 48 := by
  rw [ssWithin, Fin.sum_univ_two, tri_fiber0, tri_fiber1, tri_condMean0, tri_condMean1]
  simp [triImp]
  norm_num

/-- The ceiling of this population is `1 - 48/85.5 = 0.4386…`, comfortably below `1/2`. -/
theorem tri_ceiling_lt_half : anovaCeiling triKey triImp < 1 / 2 := by
  rw [anovaCeiling, tri_ssWithin, tri_sstot]
  norm_num

lemma tri_values0 : ∀ i : Fin 6, triKey i = 0 → triImp i = -13/2 ∨ triImp i = -1/2 := by
  intro i; fin_cases i <;> simp [triKey, triImp]

lemma tri_values1 : ∀ i : Fin 6, triKey i = 1 → triImp i = -3/2 ∨ triImp i = 9/2 := by
  intro i; fin_cases i <;> simp [triKey, triImp]

/-- **The completeness boundary is sharp.**  With three windows per content the certificate can
fail while the conjecture's conclusion holds: here the ceiling is `0.4386… < 1/2`, yet every
choice of one repeated pair per content produces at most `72 < 85.5 = SS_tot`.  Together with
`certificate_complete_of_fibers_card_le_two` this pins the completeness threshold exactly at two
windows per key content. -/
theorem tri_certificate_fails :
    anovaCeiling triKey triImp < 1 / 2 ∧
      ∀ p q : Fin 2 → Fin 6, (∀ y, triKey (p y) = y) → (∀ y, triKey (q y) = y) →
        ¬ (sstot triImp < ∑ y : Fin 2, (triImp (p y) - triImp (q y)) ^ 2) := by
  refine ⟨tri_ceiling_lt_half, ?_⟩
  intro p q hp hq
  rw [tri_sstot, Fin.sum_univ_two]
  simp only [not_lt]
  have h0p := tri_values0 (p 0) (hp 0)
  have h0q := tri_values0 (q 0) (hq 0)
  have h1p := tri_values1 (p 1) (hp 1)
  have h1q := tri_values1 (q 1) (hq 1)
  rcases h0p with h0p | h0p <;> rcases h0q with h0q | h0q <;>
    rcases h1p with h1p | h1p <;> rcases h1q with h1q | h1q <;>
      rw [h0p, h0q, h1p, h1q] <;> norm_num

end ThreeFibers

/-! ### 3. The dual certificate: a measurable *refutation* of D3 -/

section Refutation

variable {ι : Type*} [Fintype ι] {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- **Popoviciu-type bound.**  A block of values confined to `[l, u]` has dispersion at most
`card · ((u-l)/2)²`.  The mean-minimising property does all the work. -/
theorem sum_sq_dev_le_of_mem_Icc {α : Type*} (G : Finset α) (g : α → ℝ) (l u : ℝ)
    (h : ∀ i ∈ G, l ≤ g i ∧ g i ≤ u) :
    ∑ i ∈ G, (g i - (∑ j ∈ G, g j) / G.card) ^ 2 ≤ G.card * ((u - l) / 2) ^ 2 := by
  refine (sum_sq_mean_le G g ((l + u) / 2)).trans ?_
  have hterm : ∀ i ∈ G, (g i - (l + u) / 2) ^ 2 ≤ ((u - l) / 2) ^ 2 := by
    intro i hi
    obtain ⟨h1, h2⟩ := h i hi
    nlinarith [sq_nonneg (g i - (l + u) / 2)]
  calc ∑ i ∈ G, (g i - (l + u) / 2) ^ 2
      ≤ ∑ _i ∈ G, ((u - l) / 2) ^ 2 := Finset.sum_le_sum hterm
    _ = G.card * ((u - l) / 2) ^ 2 := by
        rw [Finset.sum_const, nsmul_eq_mul]

/-- The unexplainable dispersion is bounded above by the observed within-content ranges. -/
theorem ssWithin_le_sum_card_mul_range (key : ι → κ) (a : ι → ℝ) (l u : κ → ℝ)
    (h : ∀ y, ∀ i ∈ fiber key y, l y ≤ a i ∧ a i ≤ u y) :
    ssWithin key a ≤ ∑ y, (fiber key y).card * ((u y - l y) / 2) ^ 2 := by
  refine Finset.sum_le_sum fun y _ => ?_
  exact sum_sq_dev_le_of_mem_Icc (fiber key y) a (l y) (u y) (h y)

/-- **The refutation certificate.**  If the observed within-content ranges are small enough
relative to the total dispersion, then the ceiling is *at least* `1/2`: the D3 conjecture is
false for this population, and — by `intrinsic_ceiling_attained` — the conditional mean is an
explicit content head reaching `R² ≥ 1/2`.  Like the positive certificate, the hypothesis
involves only observables: fiber sizes and the ranges of the importances within them. -/
theorem ceiling_ge_half_of_range_certificate (key : ι → κ) (a : ι → ℝ) (h : 0 < sstot a)
    (l u : κ → ℝ) (hrange : ∀ y, ∀ i ∈ fiber key y, l y ≤ a i ∧ a i ≤ u y)
    (hcert : ∑ y, (fiber key y).card * (u y - l y) ^ 2 ≤ 2 * sstot a) :
    1 / 2 ≤ anovaCeiling key a ∧ 1 / 2 ≤ Rsq a (fun i => condMean key a (key i)) := by
  have hb := ssWithin_le_sum_card_mul_range key a l u hrange
  have hquarter : ∑ y, ((fiber key y).card : ℝ) * ((u y - l y) / 2) ^ 2
      = (∑ y, ((fiber key y).card : ℝ) * (u y - l y) ^ 2) / 4 := by
    rw [Finset.sum_div]
    exact Finset.sum_congr rfl fun y _ => by ring
  have hhalf : ssWithin key a ≤ sstot a / 2 := by
    rw [hquarter] at hb
    linarith
  have hceil : 1 / 2 ≤ anovaCeiling key a := by
    have hdiv : ssWithin key a / sstot a ≤ 1 / 2 := by
      rw [div_le_div_iff₀ h (by norm_num : (0:ℝ) < 2)]
      linarith
    simp only [anovaCeiling]
    linarith
  exact ⟨hceil, by rw [intrinsic_ceiling_attained key a]; exact hceil⟩

end Refutation

end Catalog.Bridges.NonlinearProbeCeilingCompleteness