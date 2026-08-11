import Novelty.MultiwaySortingRadix

/-!
# Fluctuation penalty above the sorting Landauer bound

The previous cycle established the exact quasistatic baseline
`landauerGap (sortingFunction n) kT = kT · log (n!)` for irreversible sorting.  Here we
prove the conjectured *strict* surcharge for finite-time stochastic implementations.

A finite-time protocol is modelled by a `WorkEnsemble`: a finite set of trajectories with
positive probabilities and a work value on each.  The physical input is the Jarzynski
equality `⟨exp(-W/kT)⟩ = exp(-F/kT)`, with `F` the free-energy (here Landauer) baseline.

Main results:

* `expected_work_ge_baseline`: `F ≤ ⟨W⟩` (the second law for the ensemble).
* `expected_work_gt_of_nonconstant`: if the work distribution is **nonconstant** on its
  support, then `F < ⟨W⟩` strictly.
* `dissipated_work_eq_relEntropy`: the excess is *exactly* `kT` times the relative entropy
  (Kullback–Leibler divergence) between the forward trajectory distribution and the
  reverse-weighted one — the quantitative divergence control asked for by the conjecture.
* `sorting_fluctuation_penalty`: applied to sorting, any nonconstant work distribution
  forces `⟨W⟩ > kT log (n!)`, and the excess equals `kT · D(p ‖ p^R)`.
-/

open Finset

namespace SortingFluctuation

variable {Ω : Type*} [Fintype Ω]

/-- A finite-time stochastic work ensemble: trajectories with positive probabilities and a
work value each. -/
structure WorkEnsemble (Ω : Type*) [Fintype Ω] where
  /-- Probability of each trajectory. -/
  prob : Ω → ℝ
  /-- Work dissipated along each trajectory. -/
  work : Ω → ℝ
  /-- All listed trajectories are in the support. -/
  prob_pos : ∀ i, 0 < prob i
  /-- Normalisation. -/
  prob_sum : ∑ i, prob i = 1

namespace WorkEnsemble

/-- Expected work of the ensemble. -/
noncomputable def expectedWork (E : WorkEnsemble Ω) : ℝ := ∑ i, E.prob i * E.work i

/-- The Jarzynski equality relative to a free-energy baseline `F`. -/
def Jarzynski (E : WorkEnsemble Ω) (kT F : ℝ) : Prop :=
  ∑ i, E.prob i * Real.exp (-(E.work i) / kT) = Real.exp (-F / kT)

/-- The reverse (time-reversed) trajectory weight `p_i · exp(-(W_i - F)/kT)`. -/
noncomputable def reverseWeight (E : WorkEnsemble Ω) (kT F : ℝ) (i : Ω) : ℝ :=
  E.prob i * Real.exp (-(E.work i - F) / kT)

/-- Relative entropy (in nats) of the forward distribution with respect to the
reverse-weighted distribution. -/
noncomputable def relEntropy (E : WorkEnsemble Ω) (kT F : ℝ) : ℝ :=
  ∑ i, E.prob i * Real.log (E.prob i / E.reverseWeight kT F i)

/-- The reverse weights are positive. -/
theorem reverseWeight_pos (E : WorkEnsemble Ω) (kT F : ℝ) (i : Ω) :
    0 < E.reverseWeight kT F i :=
  mul_pos (E.prob_pos i) (Real.exp_pos _)

/-- **Normalisation of the reverse process.**  The Jarzynski equality says exactly that the
reverse weights form a probability distribution. -/
theorem reverseWeight_sum (E : WorkEnsemble Ω) {kT F : ℝ} (hkT : kT ≠ 0)
    (hJ : E.Jarzynski kT F) : ∑ i, E.reverseWeight kT F i = 1 := by
  have hsplit : ∀ i : Ω, E.reverseWeight kT F i
      = (E.prob i * Real.exp (-(E.work i) / kT)) * Real.exp (F / kT) := by
    intro i
    have hz : -(E.work i - F) / kT = -(E.work i) / kT + F / kT := by
      field_simp
      ring
    rw [reverseWeight, hz, Real.exp_add, ← mul_assoc]
  calc ∑ i, E.reverseWeight kT F i
      = (∑ i, E.prob i * Real.exp (-(E.work i) / kT)) * Real.exp (F / kT) := by
        rw [Finset.sum_mul]; exact Finset.sum_congr rfl fun i _ => hsplit i
    _ = Real.exp (-F / kT) * Real.exp (F / kT) := by rw [hJ]
    _ = 1 := by rw [← Real.exp_add, show -F / kT + F / kT = 0 by ring, Real.exp_zero]

/-- Rewriting the log-ratio of forward and reverse weights as a scaled work excess. -/
theorem log_ratio (E : WorkEnsemble Ω) (kT F : ℝ) (i : Ω) :
    Real.log (E.prob i / E.reverseWeight kT F i) = (E.work i - F) / kT := by
  have hp : E.prob i ≠ 0 := ne_of_gt (E.prob_pos i)
  have hepos : (0 : ℝ) < Real.exp (-(E.work i - F) / kT) := Real.exp_pos _
  unfold reverseWeight
  rw [Real.log_div hp (by positivity), Real.log_mul hp (ne_of_gt hepos), Real.log_exp]
  ring

/-- Auxiliary: the average log reverse/forward ratio is `-(⟨W⟩ - F)/kT`. -/
theorem sum_prob_mul_log_exp (E : WorkEnsemble Ω) {kT : ℝ} (hkT : kT ≠ 0) (F : ℝ) :
    ∑ i, E.prob i * Real.log (Real.exp (-(E.work i - F) / kT))
      = (F - E.expectedWork) / kT := by
  have hterm : ∀ i : Ω, E.prob i * Real.log (Real.exp (-(E.work i - F) / kT))
      = (E.prob i * F - E.prob i * E.work i) * (1 / kT) := by
    intro i
    rw [Real.log_exp]
    field_simp
    ring
  calc ∑ i, E.prob i * Real.log (Real.exp (-(E.work i - F) / kT))
      = ∑ i, (E.prob i * F - E.prob i * E.work i) * (1 / kT) :=
        Finset.sum_congr rfl fun i _ => hterm i
    _ = (∑ i, (E.prob i * F - E.prob i * E.work i)) * (1 / kT) := by rw [Finset.sum_mul]
    _ = ((∑ i, E.prob i) * F - ∑ i, E.prob i * E.work i) * (1 / kT) := by
        rw [Finset.sum_sub_distrib, Finset.sum_mul]
    _ = (F - E.expectedWork) / kT := by
        rw [E.prob_sum]; unfold expectedWork; ring

/-- **Second law for the ensemble.**  The Jarzynski equality forces the expected work to be
at least the baseline `F`. -/
theorem expected_work_ge_baseline (E : WorkEnsemble Ω) {kT F : ℝ} (hkT : 0 < kT)
    (hJ : E.Jarzynski kT F) : F ≤ E.expectedWork := by
  have hsum : ∑ i, E.reverseWeight kT F i = 1 := E.reverseWeight_sum (ne_of_gt hkT) hJ
  have hle : ∀ i ∈ (Finset.univ : Finset Ω),
      E.prob i * Real.log (Real.exp (-(E.work i - F) / kT))
        ≤ E.prob i * (Real.exp (-(E.work i - F) / kT) - 1) := by
    intro i _
    exact mul_le_mul_of_nonneg_left
      (Real.log_le_sub_one_of_pos (Real.exp_pos _)) (E.prob_pos i).le
  have hbound : ∑ i, E.prob i * Real.log (Real.exp (-(E.work i - F) / kT))
      ≤ ∑ i, E.prob i * (Real.exp (-(E.work i - F) / kT) - 1) := Finset.sum_le_sum hle
  have hrhs : ∑ i, E.prob i * (Real.exp (-(E.work i - F) / kT) - 1) = 0 := by
    have : ∀ i : Ω, E.prob i * (Real.exp (-(E.work i - F) / kT) - 1)
        = E.reverseWeight kT F i - E.prob i := by
      intro i; unfold reverseWeight; ring
    rw [Finset.sum_congr rfl fun i _ => this i, Finset.sum_sub_distrib, hsum, E.prob_sum, sub_self]
  have hlhs := E.sum_prob_mul_log_exp (ne_of_gt hkT) F
  rw [hlhs, hrhs] at hbound
  have h2 : F - E.expectedWork ≤ 0 := by
    by_contra h
    push_neg at h
    have : 0 < (F - E.expectedWork) / kT := div_pos h hkT
    linarith
  linarith

/-- **Strict fluctuation penalty.**  If some trajectory in the support has work different
from the baseline, the expected work strictly exceeds it. -/
theorem expected_work_gt_of_exists_ne (E : WorkEnsemble Ω) {kT F : ℝ} (hkT : 0 < kT)
    (hJ : E.Jarzynski kT F) (hne : ∃ j, E.work j ≠ F) : F < E.expectedWork := by
  obtain ⟨j, hj⟩ := hne
  have hsum : ∑ i, E.reverseWeight kT F i = 1 := E.reverseWeight_sum (ne_of_gt hkT) hJ
  have hle : ∀ i ∈ (Finset.univ : Finset Ω),
      E.prob i * Real.log (Real.exp (-(E.work i - F) / kT))
        ≤ E.prob i * (Real.exp (-(E.work i - F) / kT) - 1) := by
    intro i _
    exact mul_le_mul_of_nonneg_left
      (Real.log_le_sub_one_of_pos (Real.exp_pos _)) (E.prob_pos i).le
  have hxj : Real.exp (-(E.work j - F) / kT) ≠ 1 := by
    intro h
    have hz : -(E.work j - F) / kT = 0 := (Real.exp_eq_one_iff _).1 h
    rcases div_eq_zero_iff.1 hz with h1 | h2
    · exact hj (by linarith)
    · exact absurd h2 (ne_of_gt hkT)
  have hstrict : E.prob j * Real.log (Real.exp (-(E.work j - F) / kT))
      < E.prob j * (Real.exp (-(E.work j - F) / kT) - 1) :=
    mul_lt_mul_of_pos_left (Real.log_lt_sub_one_of_pos (Real.exp_pos _) hxj) (E.prob_pos j)
  have hbound : ∑ i, E.prob i * Real.log (Real.exp (-(E.work i - F) / kT))
      < ∑ i, E.prob i * (Real.exp (-(E.work i - F) / kT) - 1) :=
    Finset.sum_lt_sum hle ⟨j, Finset.mem_univ j, hstrict⟩
  have hrhs : ∑ i, E.prob i * (Real.exp (-(E.work i - F) / kT) - 1) = 0 := by
    have : ∀ i : Ω, E.prob i * (Real.exp (-(E.work i - F) / kT) - 1)
        = E.reverseWeight kT F i - E.prob i := by
      intro i; unfold reverseWeight; ring
    rw [Finset.sum_congr rfl fun i _ => this i, Finset.sum_sub_distrib, hsum, E.prob_sum, sub_self]
  have hlhs := E.sum_prob_mul_log_exp (ne_of_gt hkT) F
  rw [hlhs, hrhs] at hbound
  have h2 : F - E.expectedWork < 0 := by
    by_contra h
    push_neg at h
    have : 0 ≤ (F - E.expectedWork) / kT := div_nonneg h hkT.le
    linarith
  linarith

/-- **Nonconstant work forces a strict penalty.** -/
theorem expected_work_gt_of_nonconstant (E : WorkEnsemble Ω) {kT F : ℝ} (hkT : 0 < kT)
    (hJ : E.Jarzynski kT F) (hnc : ∃ i j, E.work i ≠ E.work j) : F < E.expectedWork := by
  obtain ⟨i, j, hij⟩ := hnc
  refine E.expected_work_gt_of_exists_ne hkT hJ ?_
  by_contra h
  push_neg at h
  exact hij ((h i).trans (h j).symm)

/-- **The dissipated work is exactly `kT` times a divergence.**  The excess of the expected
work over the baseline equals `kT · D(p ‖ p^R)`, the relative entropy between the forward
trajectory distribution and the reverse-weighted one. -/
theorem dissipated_work_eq_relEntropy (E : WorkEnsemble Ω) {kT : ℝ} (hkT : 0 < kT) (F : ℝ) :
    E.expectedWork - F = kT * E.relEntropy kT F := by
  have hterm : ∀ i : Ω, E.prob i * Real.log (E.prob i / E.reverseWeight kT F i)
      = E.prob i * ((E.work i - F) / kT) := by
    intro i
    rw [E.log_ratio kT F i]
  have : E.relEntropy kT F = (E.expectedWork - F) / kT := by
    unfold relEntropy
    rw [Finset.sum_congr rfl fun i _ => hterm i]
    have : ∀ i : Ω, E.prob i * ((E.work i - F) / kT)
        = (E.prob i * E.work i - E.prob i * F) * (1 / kT) := by
      intro i; field_simp
    rw [Finset.sum_congr rfl fun i _ => this i, ← Finset.sum_mul, Finset.sum_sub_distrib,
      ← Finset.sum_mul, E.prob_sum]
    unfold expectedWork
    ring
  rw [this]
  field_simp

end WorkEnsemble

/-- **Fluctuation penalty above the sorting Landauer bound.**  For a finite-time stochastic
implementation of irreversible sorting satisfying the Jarzynski equality with the exact
Landauer baseline `kT log (n!)`, a nonconstant work distribution forces expected work
strictly above the baseline, and the excess equals `kT` times the forward/reverse relative
entropy. -/
theorem sorting_fluctuation_penalty {Ω : Type*} [Fintype Ω] (E : WorkEnsemble Ω) (n : ℕ)
    {kT : ℝ} (hkT : 0 < kT)
    (hJ : E.Jarzynski kT (landauerGap (sortingFunction n) kT))
    (hnc : ∃ i j, E.work i ≠ E.work j) :
    kT * Real.log n.factorial < E.expectedWork ∧
    E.expectedWork - kT * Real.log n.factorial
      = kT * E.relEntropy kT (kT * Real.log n.factorial) := by
  have hF : landauerGap (sortingFunction n) kT = kT * Real.log n.factorial :=
    SortingEntropyWork.sorting_landauer_gap_exact n kT
  rw [hF] at hJ
  exact ⟨E.expected_work_gt_of_nonconstant hkT hJ hnc,
    E.dissipated_work_eq_relEntropy hkT _⟩

-- !-- Lab Notes -- !--
-- Hypothesis (Future Direction 4): any nonconstant work distribution on the support forces
-- expected work strictly above the quasistatic baseline `kT log(n!)`, with the excess
-- controlled by a forward/reverse divergence.
-- Experiment: two-outcome ensembles were tabulated at kT = 1, F = log 6 (n = 3).
-- Taking p = (1/2, 1/2) and demanding Jarzynski `½e^{-W₁} + ½e^{-W₂} = 1/6`, e.g.
-- W₁ = log 6 - 0.5 ⇒ e^{-W₁} = 0.2748, so e^{-W₂} = 1/3 - 0.2748 = 0.0585, W₂ = 2.838.
-- Then ⟨W⟩ = (1.2917 + 2.838)/2 = 2.065 > log 6 = 1.7918: excess 0.273 > 0, matching
-- kT·D(p‖p^R) with p^R = (0.824, 0.176): D = ½log(0.5/0.824) + ½log(0.5/0.176) = 0.273.
-- Analysis: the proof is the strict `log x ≤ x - 1` bound applied pointwise to
-- x_i = exp(-(W_i - F)/kT), whose p-average is 1 exactly by Jarzynski; strictness comes
-- from a single trajectory with x_j ≠ 1, i.e. W_j ≠ F.  The divergence identity is exact,
-- not an estimate: dissipation *is* kT times the relative entropy.
-- Critique: the hypothesis `prob_pos` restricts Ω to the support, which is the correct
-- reading of "nonconstant on the support"; without it, nonconstancy off the support would
-- (correctly) yield no penalty.  Note also that nonconstancy is needed: a deterministic
-- work value satisfying Jarzynski must equal F, and then equality holds.
-- !-- end Lab Notes -- !--

end SortingFluctuation