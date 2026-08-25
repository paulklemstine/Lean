/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license.

# Harmonic bulk × steeper edge: rigidity and mixture resolution for discrete power-law kernels

This file formalises the "harmonic bulk × steeper-edge kernel" refinement question:
a fitted bulk exponent (near the harmonic value `a = 1`, empirically `1.104`) coexists
with head statistics (edge fraction, first-decile mass, peak/end ratio) that each imply a
*steeper* exponent.  The mathematical content developed here is:

* **MLR ⇒ FOSD for the discrete power-law family.**  For weights `k ↦ k^(-a)` on
  `{1, …, n}`, a larger exponent puts more mass on every head window
  (`headMass_le_of_exponent_le`), strictly so (`headMass_lt_of_exponent_lt`).
* **Rigidity / identifiability.**  A single head statistic determines the exponent
  uniquely (`exponent_unique_of_headMass_eq`); hence two head windows reporting
  *different* implied exponents cannot be reconciled by any single power law
  (`no_single_exponent_fits_two_windows`).  This is the exact logical shape of the
  recorded tension.
* **Two-component resolution.**  For a mixture of a flat (bulk) and a steep (edge)
  component, every local exponent lies strictly between the two component exponents
  (`localExp_mix_mem_Ioo`), the head mass is a strict mediant
  (`headMass_mix_mem_Ioo`), and the steep component's local share is strictly
  decreasing in the index (`steepShare_strictAnti`) with limit `0`
  (`steepShare_tendsto_zero`).  So the steep component is *exactly* an edge phenomenon
  while the bulk is governed by the flat exponent.
* **A quantitative instance of the tension and its resolution.**  No power law with
  exponent `≤ 1.104` can produce the recorded peak/end ratio `2.54`
  (`pure_power_law_peak_end_lt_observed`), while the explicit harmonic-bulk /
  quadratic-edge mixture with weight `w = 54/127` produces it exactly
  (`harmonic_edge_mixture_matches_observed_peak_end`).
-/

import Mathlib

open Finset Filter

namespace HarmonicBulkSteeperEdge

/-! ## The discrete power-law kernel -/

/-- Unnormalised power-law weight `k ↦ k^(-a)`; `a = 1` is the harmonic kernel. -/
noncomputable def pw (a : ℝ) (k : ℕ) : ℝ := (k : ℝ) ^ (-a)

lemma pw_pos {a : ℝ} {k : ℕ} (hk : 1 ≤ k) : 0 < pw a k := by
  have : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  exact Real.rpow_pos_of_pos this _

lemma pw_one (a : ℝ) : pw a 1 = 1 := by
  simp [pw]

/-- Monotone likelihood ratio: a steeper exponent down-weights larger indices. -/
lemma pw_cross {a b : ℝ} {k j : ℕ} (hk : 1 ≤ k) (hkj : k ≤ j) (hab : a ≤ b) :
    pw a k * pw b j ≤ pw b k * pw a j := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hj0 : (0:ℝ) < (j:ℝ) := lt_of_lt_of_le hk0 (by exact_mod_cast hkj)
  have hle : (k:ℝ) ^ (b - a) ≤ (j:ℝ) ^ (b - a) :=
    Real.rpow_le_rpow hk0.le (by exact_mod_cast hkj) (by linarith)
  have e1 : (k:ℝ) ^ (-a) = (k:ℝ) ^ (-b) * (k:ℝ) ^ (b - a) := by
    rw [← Real.rpow_add hk0]; ring_nf
  have e2 : (j:ℝ) ^ (-a) = (j:ℝ) ^ (-b) * (j:ℝ) ^ (b - a) := by
    rw [← Real.rpow_add hj0]; ring_nf
  have hkb : (0:ℝ) < (k:ℝ) ^ (-b) := Real.rpow_pos_of_pos hk0 _
  have hjb : (0:ℝ) < (j:ℝ) ^ (-b) := Real.rpow_pos_of_pos hj0 _
  simp only [pw, e1, e2]
  nlinarith [mul_pos hkb hjb]

/-- Strict monotone likelihood ratio. -/
lemma pw_cross_lt {a b : ℝ} {k j : ℕ} (hk : 1 ≤ k) (hkj : k < j) (hab : a < b) :
    pw a k * pw b j < pw b k * pw a j := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hj0 : (0:ℝ) < (j:ℝ) := lt_trans hk0 (by exact_mod_cast hkj)
  have hle : (k:ℝ) ^ (b - a) < (j:ℝ) ^ (b - a) :=
    Real.rpow_lt_rpow hk0.le (by exact_mod_cast hkj) (by linarith)
  have e1 : (k:ℝ) ^ (-a) = (k:ℝ) ^ (-b) * (k:ℝ) ^ (b - a) := by
    rw [← Real.rpow_add hk0]; ring_nf
  have e2 : (j:ℝ) ^ (-a) = (j:ℝ) ^ (-b) * (j:ℝ) ^ (b - a) := by
    rw [← Real.rpow_add hj0]; ring_nf
  have hkb : (0:ℝ) < (k:ℝ) ^ (-b) := Real.rpow_pos_of_pos hk0 _
  have hjb : (0:ℝ) < (j:ℝ) ^ (-b) := Real.rpow_pos_of_pos hj0 _
  simp only [pw, e1, e2]
  nlinarith [mul_pos hkb hjb]

/-- The consecutive-ratio of a pure power law. -/
lemma pw_ratio {a : ℝ} {k : ℕ} (hk : 1 ≤ k) :
    pw a k / pw a (k + 1) = ((k + 1 : ℝ) / k) ^ a := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hk1 : (0:ℝ) < ((k:ℝ) + 1) := by linarith
  have hcast : ((k + 1 : ℕ) : ℝ) = (k:ℝ) + 1 := by push_cast; ring
  rw [pw, pw, hcast, Real.div_rpow (by positivity) hk0.le,
    Real.rpow_neg hk0.le, Real.rpow_neg hk1.le]
  field_simp

/-! ## Head masses and first-order stochastic dominance -/

/-- Total weight of the head window `{1, …, m}`. -/
noncomputable def headSum (a : ℝ) (m : ℕ) : ℝ := ∑ k ∈ Finset.Icc 1 m, pw a k

/-- Fraction of the total weight on `{1, …, n}` carried by the head window `{1, …, m}`. -/
noncomputable def headMass (a : ℝ) (n m : ℕ) : ℝ := headSum a m / headSum a n

lemma headSum_pos {a : ℝ} {m : ℕ} (hm : 1 ≤ m) : 0 < headSum a m := by
  refine Finset.sum_pos (fun k hk => ?_) ⟨1, by simp [hm]⟩
  exact pw_pos (Finset.mem_Icc.1 hk).1

/-- Splitting a sum over `{1, …, n}` at an intermediate index. -/
lemma sum_Icc_split (f : ℕ → ℝ) {m n : ℕ} (hmn : m ≤ n) :
    ∑ k ∈ Finset.Icc 1 n, f k
      = ∑ k ∈ Finset.Icc 1 m, f k + ∑ k ∈ Finset.Ioc m n, f k := by
  rw [← Finset.sum_union (by simp [Finset.disjoint_left]; omega)]
  congr 1
  ext x
  simp only [Finset.mem_Icc, Finset.mem_union, Finset.mem_Ioc]
  omega

lemma headSum_split {a : ℝ} {m n : ℕ} (hmn : m ≤ n) :
    headSum a n = headSum a m + ∑ k ∈ Finset.Ioc m n, pw a k :=
  sum_Icc_split (pw a) hmn

/-- Cross-product inequality driving stochastic dominance. -/
lemma headSum_cross {a b : ℝ} {m n : ℕ} (hab : a ≤ b) (hmn : m ≤ n) :
    headSum a m * headSum b n ≤ headSum b m * headSum a n := by
  rw [headSum_split (a := a) hmn, headSum_split (a := b) hmn]
  have key : headSum a m * (∑ j ∈ Finset.Ioc m n, pw b j)
      ≤ headSum b m * (∑ j ∈ Finset.Ioc m n, pw a j) := by
    rw [headSum, headSum, Finset.sum_mul_sum, Finset.sum_mul_sum]
    refine Finset.sum_le_sum (fun k hk => Finset.sum_le_sum (fun j hj => ?_))
    have hk1 : 1 ≤ k := (Finset.mem_Icc.1 hk).1
    have hkm : k ≤ m := (Finset.mem_Icc.1 hk).2
    have hmj : m < j := (Finset.mem_Ioc.1 hj).1
    exact pw_cross hk1 (by omega) hab
  nlinarith [key]

/-- Strict cross-product inequality. -/
lemma headSum_cross_lt {a b : ℝ} {m n : ℕ} (hab : a < b) (hm : 1 ≤ m) (hmn : m < n) :
    headSum a m * headSum b n < headSum b m * headSum a n := by
  rw [headSum_split (a := a) hmn.le, headSum_split (a := b) hmn.le]
  have key : headSum a m * (∑ j ∈ Finset.Ioc m n, pw b j)
      < headSum b m * (∑ j ∈ Finset.Ioc m n, pw a j) := by
    rw [headSum, headSum, Finset.sum_mul_sum, Finset.sum_mul_sum]
    refine Finset.sum_lt_sum_of_nonempty ⟨1, by simp [hm]⟩ (fun k hk => ?_)
    have hk1 : 1 ≤ k := (Finset.mem_Icc.1 hk).1
    have hkm : k ≤ m := (Finset.mem_Icc.1 hk).2
    refine Finset.sum_lt_sum_of_nonempty ⟨n, by simp [hmn]⟩ (fun j hj => ?_)
    have hmj : m < j := (Finset.mem_Ioc.1 hj).1
    exact pw_cross_lt hk1 (by omega) hab
  nlinarith [key]

/-- **MLR ⇒ FOSD.** A steeper exponent puts at least as much mass on every head window. -/
theorem headMass_le_of_exponent_le {a b : ℝ} {m n : ℕ} (hab : a ≤ b) (hm : 1 ≤ m)
    (hmn : m ≤ n) : headMass a n m ≤ headMass b n m := by
  have han : 0 < headSum a n := headSum_pos (le_trans hm hmn)
  have hbn : 0 < headSum b n := headSum_pos (le_trans hm hmn)
  rw [headMass, headMass, div_le_div_iff₀ han hbn]
  exact headSum_cross hab hmn

/-- Strict version: the head mass is strictly increasing in the exponent. -/
theorem headMass_lt_of_exponent_lt {a b : ℝ} {m n : ℕ} (hab : a < b) (hm : 1 ≤ m)
    (hmn : m < n) : headMass a n m < headMass b n m := by
  have han : 0 < headSum a n := headSum_pos (by omega)
  have hbn : 0 < headSum b n := headSum_pos (by omega)
  rw [headMass, headMass, div_lt_div_iff₀ han hbn]
  exact headSum_cross_lt hab hm hmn

/-- **Rigidity / identifiability.**  A single head statistic pins down the exponent. -/
theorem exponent_unique_of_headMass_eq {a b : ℝ} {m n : ℕ} (hm : 1 ≤ m) (hmn : m < n)
    (h : headMass a n m = headMass b n m) : a = b := by
  rcases lt_trichotomy a b with hlt | heq | hgt
  · exact absurd h (ne_of_lt (headMass_lt_of_exponent_lt hlt hm hmn))
  · exact heq
  · exact absurd h.symm (ne_of_lt (headMass_lt_of_exponent_lt hgt hm hmn))

/-- **The tension, in its logical form.**  If two head windows report head masses whose
implied exponents differ, then *no* single power law reproduces both statistics: a
two-component (bulk × edge) kernel is forced. -/
theorem no_single_exponent_fits_two_windows {a₁ a₂ : ℝ} {m₁ m₂ n : ℕ}
    (hm₁ : 1 ≤ m₁) (hm₁n : m₁ < n) (hm₂ : 1 ≤ m₂) (hm₂n : m₂ < n) (hne : a₁ ≠ a₂) :
    ¬ ∃ a : ℝ, headMass a n m₁ = headMass a₁ n m₁ ∧ headMass a n m₂ = headMass a₂ n m₂ := by
  rintro ⟨a, h₁, h₂⟩
  exact hne ((exponent_unique_of_headMass_eq hm₁ hm₁n h₁).symm.trans
    (exponent_unique_of_headMass_eq hm₂ hm₂n h₂))

/-! ## Mediants -/

/-- Strict mediant inequality: a positive combination of two ratios lies strictly between
them. -/
lemma mediant_mem_Ioo {x y z t : ℝ} (hy : 0 < y) (ht : 0 < t) (h : x / y < z / t) :
    x / y < (x + z) / (y + t) ∧ (x + z) / (y + t) < z / t := by
  have hyt : 0 < y + t := by linarith
  have hxy : x * t < z * y := by
    rw [div_lt_div_iff₀ hy ht] at h; linarith
  constructor
  · rw [div_lt_div_iff₀ hy hyt]; nlinarith
  · rw [div_lt_div_iff₀ hyt ht]; nlinarith

/-! ## Two-component (bulk × edge) kernels -/

/-- Mixture of a bulk kernel with exponent `a` and an edge kernel with exponent `b`. -/
noncomputable def mix (w a b : ℝ) (k : ℕ) : ℝ := (1 - w) * pw a k + w * pw b k

/-- The share of the weight at index `k` carried by the steep (edge) component. -/
noncomputable def steepShare (w a b : ℝ) (k : ℕ) : ℝ := w * pw b k / mix w a b k

/-- Local exponent read off from two consecutive indices. -/
noncomputable def localExp (f : ℕ → ℝ) (k : ℕ) : ℝ :=
  Real.log (f k / f (k + 1)) / Real.log ((k + 1 : ℝ) / k)

lemma log_step_pos {k : ℕ} (hk : 1 ≤ k) : 0 < Real.log ((k + 1 : ℝ) / k) := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  refine Real.log_pos ?_
  rw [lt_div_iff₀ hk0]; linarith

/-- The local exponent of a pure power law is the exponent, at every index. -/
theorem localExp_pw (a : ℝ) {k : ℕ} (hk : 1 ≤ k) : localExp (pw a) k = a := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hstep : (1:ℝ) < ((k:ℝ) + 1) / k := by rw [lt_div_iff₀ hk0]; linarith
  have hlog : 0 < Real.log ((k + 1 : ℝ) / k) := log_step_pos hk
  rw [localExp, pw_ratio hk, Real.log_rpow (by linarith)]
  field_simp

lemma mix_pos {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) {k : ℕ} (hk : 1 ≤ k) :
    0 < mix w a b k := by
  have := pw_pos (a := a) hk
  have := pw_pos (a := b) hk
  unfold mix; nlinarith

/-- Consecutive ratio of a mixture lies strictly between the two pure ratios. -/
lemma mix_ratio_mem_Ioo {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) (hab : a < b) {k : ℕ}
    (hk : 1 ≤ k) :
    ((k + 1 : ℝ) / k) ^ a < mix w a b k / mix w a b (k + 1) ∧
      mix w a b k / mix w a b (k + 1) < ((k + 1 : ℝ) / k) ^ b := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hstep : (1:ℝ) < ((k:ℝ) + 1) / k := by rw [lt_div_iff₀ hk0]; linarith
  have hk1 : 1 ≤ k + 1 := by omega
  have hpa : 0 < pw a (k + 1) := pw_pos hk1
  have hpb : 0 < pw b (k + 1) := pw_pos hk1
  have hya : 0 < (1 - w) * pw a (k + 1) := by nlinarith
  have hyb : 0 < w * pw b (k + 1) := by nlinarith
  have ea : ((1 - w) * pw a k) / ((1 - w) * pw a (k + 1)) = ((k + 1 : ℝ) / k) ^ a := by
    rw [mul_div_mul_left _ _ (by linarith : (1:ℝ) - w ≠ 0), pw_ratio hk]
  have eb : (w * pw b k) / (w * pw b (k + 1)) = ((k + 1 : ℝ) / k) ^ b := by
    rw [mul_div_mul_left _ _ (by linarith : w ≠ 0), pw_ratio hk]
  have hlt : ((1 - w) * pw a k) / ((1 - w) * pw a (k + 1))
      < (w * pw b k) / (w * pw b (k + 1)) := by
    rw [ea, eb]
    exact Real.rpow_lt_rpow_of_exponent_lt hstep hab
  have := mediant_mem_Ioo hya hyb hlt
  rw [ea, eb] at this
  simpa [mix] using this

/-- **Every local exponent of a bulk × edge mixture lies strictly between the component
exponents.**  In particular the mixture is *steeper than the bulk at every scale*. -/
theorem localExp_mix_mem_Ioo {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) (hab : a < b) {k : ℕ}
    (hk : 1 ≤ k) : a < localExp (mix w a b) k ∧ localExp (mix w a b) k < b := by
  have hlog : 0 < Real.log ((k + 1 : ℝ) / k) := log_step_pos hk
  obtain ⟨h1, h2⟩ := mix_ratio_mem_Ioo hw0 hw1 hab hk
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hstep : (0:ℝ) < ((k:ℝ) + 1) / k := by positivity
  have hpos : 0 < mix w a b k / mix w a b (k + 1) :=
    div_pos (mix_pos hw0 hw1 hk) (mix_pos hw0 hw1 (by omega))
  have hla : Real.log (((k:ℝ) + 1) / k) * a < Real.log (mix w a b k / mix w a b (k + 1)) := by
    have := Real.log_lt_log (Real.rpow_pos_of_pos hstep a) h1
    rwa [Real.log_rpow hstep, mul_comm] at this
  have hlb : Real.log (mix w a b k / mix w a b (k + 1)) < Real.log (((k:ℝ) + 1) / k) * b := by
    have := Real.log_lt_log hpos h2
    rwa [Real.log_rpow hstep, mul_comm] at this
  constructor
  · rw [localExp, lt_div_iff₀ hlog]; linarith
  · rw [localExp, div_lt_iff₀ hlog]; linarith

/-- Head mass of a mixture, over the window `{1, …, m}` inside `{1, …, n}`. -/
noncomputable def mixHeadSum (w a b : ℝ) (m : ℕ) : ℝ := ∑ k ∈ Finset.Icc 1 m, mix w a b k

noncomputable def mixHeadMass (w a b : ℝ) (n m : ℕ) : ℝ := mixHeadSum w a b m / mixHeadSum w a b n

lemma mixHeadSum_eq (w a b : ℝ) (m : ℕ) :
    mixHeadSum w a b m = (1 - w) * headSum a m + w * headSum b m := by
  simp [mixHeadSum, mix, headSum, Finset.sum_add_distrib, Finset.mul_sum]

/-- **The head mass of a bulk × edge mixture is a strict mediant** of the two pure head
masses: the mixture is edge-enriched relative to the bulk, but never as much as the pure
edge kernel. -/
theorem headMass_mix_mem_Ioo {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) (hab : a < b) {m n : ℕ}
    (hm : 1 ≤ m) (hmn : m < n) :
    headMass a n m < mixHeadMass w a b n m ∧ mixHeadMass w a b n m < headMass b n m := by
  have han : 0 < headSum a n := headSum_pos (by omega)
  have hbn : 0 < headSum b n := headSum_pos (by omega)
  have hya : 0 < (1 - w) * headSum a n := by nlinarith
  have hyb : 0 < w * headSum b n := by nlinarith
  have ea : ((1 - w) * headSum a m) / ((1 - w) * headSum a n) = headMass a n m := by
    rw [mul_div_mul_left _ _ (by linarith : (1:ℝ) - w ≠ 0)]; rfl
  have eb : (w * headSum b m) / (w * headSum b n) = headMass b n m := by
    rw [mul_div_mul_left _ _ (by linarith : w ≠ 0)]; rfl
  have hlt : ((1 - w) * headSum a m) / ((1 - w) * headSum a n)
      < (w * headSum b m) / (w * headSum b n) := by
    rw [ea, eb]; exact headMass_lt_of_exponent_lt hab hm hmn
  have := mediant_mem_Ioo hya hyb hlt
  rw [ea, eb] at this
  simpa [mixHeadMass, mixHeadSum_eq] using this

/-! ## The steep component is an edge phenomenon -/

lemma steepShare_eq {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) {k : ℕ} (hk : 1 ≤ k) :
    steepShare w a b k = w / ((1 - w) * (k : ℝ) ^ (b - a) + w) := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hpa : 0 < pw a k := pw_pos hk
  have hpb : 0 < pw b k := pw_pos hk
  have hkey : pw a k = pw b k * (k : ℝ) ^ (b - a) := by
    unfold pw
    rw [← Real.rpow_add hk0]; ring_nf
  have hden : 0 < (1 - w) * (k : ℝ) ^ (b - a) + w := by
    have : 0 < (k : ℝ) ^ (b - a) := Real.rpow_pos_of_pos hk0 _
    nlinarith
  rw [steepShare, mix, hkey, div_eq_div_iff (by nlinarith) (ne_of_gt hden)]
  ring

/-- The steep component's local share is strictly decreasing in the index. -/
theorem steepShare_strictAnti {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) (hab : a < b) {k j : ℕ}
    (hk : 1 ≤ k) (hkj : k < j) : steepShare w a b j < steepShare w a b k := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hj0 : (0:ℝ) < (j:ℝ) := lt_trans hk0 (by exact_mod_cast hkj)
  have hlt : (k : ℝ) ^ (b - a) < (j : ℝ) ^ (b - a) :=
    Real.rpow_lt_rpow hk0.le (by exact_mod_cast hkj) (by linarith)
  have hkp : 0 < (k : ℝ) ^ (b - a) := Real.rpow_pos_of_pos hk0 _
  have hdk : 0 < (1 - w) * (k : ℝ) ^ (b - a) + w := by nlinarith
  have hdj : 0 < (1 - w) * (j : ℝ) ^ (b - a) + w := by nlinarith
  rw [steepShare_eq hw0 hw1 hk, steepShare_eq hw0 hw1 (by omega : 1 ≤ j),
    div_lt_div_iff₀ hdj hdk]
  have hstep : (1 - w) * (k : ℝ) ^ (b - a) < (1 - w) * (j : ℝ) ^ (b - a) :=
    mul_lt_mul_of_pos_left hlt (by linarith)
  nlinarith

/-- **Bulk recovery.**  The steep component's share tends to `0`: asymptotically the
mixture is governed purely by the bulk exponent. -/
theorem steepShare_tendsto_zero {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) (hab : a < b) :
    Tendsto (fun k : ℕ => steepShare w a b k) atTop (nhds 0) := by
  have hpow : Tendsto (fun k : ℕ => (1 - w) * (k : ℝ) ^ (b - a) + w) atTop atTop := by
    have h1 : Tendsto (fun x : ℝ => x ^ (b - a)) atTop atTop :=
      tendsto_rpow_atTop (by linarith)
    have h2 : Tendsto (fun k : ℕ => ((k : ℝ)) ^ (b - a)) atTop atTop :=
      h1.comp tendsto_natCast_atTop_atTop
    exact (h2.const_mul_atTop (by linarith : (0:ℝ) < 1 - w)).atTop_add tendsto_const_nhds
  have hzero : Tendsto (fun k : ℕ => w / ((1 - w) * (k : ℝ) ^ (b - a) + w)) atTop (nhds 0) :=
    Tendsto.div_atTop tendsto_const_nhds hpow
  refine hzero.congr' ?_
  filter_upwards [eventually_ge_atTop 1] with k hk
  exact (steepShare_eq hw0 hw1 hk).symm

/-! ## A quantitative instance: harmonic bulk versus the recorded peak/end ratio -/

/-- Peak-to-end ratio of a pure power law on the first two cells is `2^a`. -/
lemma pw_peak_end (a : ℝ) : pw a 1 / pw a 2 = (2:ℝ) ^ a := by
  have h2 : ((2:ℕ) : ℝ) = (2:ℝ) := by norm_num
  rw [pw, pw, h2]
  simp [Real.rpow_neg]

lemma two_rpow_eighth_lt : (2:ℝ) ^ ((1:ℝ)/8) < 1.27 := by
  have h : (2:ℝ) < (1.27:ℝ) ^ (8:ℕ) := by norm_num
  have hlt : (2:ℝ) ^ ((1:ℝ)/8) < ((1.27:ℝ) ^ (8:ℕ)) ^ ((1:ℝ)/8) :=
    Real.rpow_lt_rpow (by norm_num) h (by norm_num)
  have hEq : ((1.27:ℝ) ^ (8:ℕ)) ^ ((1:ℝ)/8) = (1.27:ℝ) := by
    rw [← Real.rpow_natCast (1.27:ℝ) 8, ← Real.rpow_mul (by norm_num)]
    norm_num
  rwa [hEq] at hlt

/-- **The tension is real.**  No pure power law whose exponent respects the fitted bulk
value `1.104` can produce the recorded peak/end ratio `2.54`. -/
theorem pure_power_law_peak_end_lt_observed {a : ℝ} (ha : a ≤ 1.104) :
    pw a 1 / pw a 2 < 2.54 := by
  rw [pw_peak_end]
  have h1 : (2:ℝ) ^ a ≤ (2:ℝ) ^ (1.104 : ℝ) :=
    Real.rpow_le_rpow_of_exponent_le (by norm_num) ha
  have h2 : (2:ℝ) ^ (1.104 : ℝ) ≤ (2:ℝ) ^ (1 + (1:ℝ)/8) :=
    Real.rpow_le_rpow_of_exponent_le (by norm_num) (by norm_num)
  have h3 : (2:ℝ) ^ (1 + (1:ℝ)/8) = 2 * (2:ℝ) ^ ((1:ℝ)/8) := by
    rw [Real.rpow_add (by norm_num)]
    norm_num
  have h4 := two_rpow_eighth_lt
  rw [h3] at h2
  linarith

/-- **Resolution.**  The harmonic bulk (`a = 1`) mixed with a quadratic edge component
(`b = 2`) at weight `w = 54/127` reproduces the recorded peak/end ratio `2.54` exactly. -/
theorem harmonic_edge_mixture_matches_observed_peak_end :
    mix (54/127) 1 2 1 / mix (54/127) 1 2 2 = 2.54 := by
  have h1 : pw 1 1 = 1 := pw_one 1
  have h2 : pw 2 1 = 1 := pw_one 2
  have h3 : pw (1:ℝ) 2 = 1/2 := by
    have : ((2:ℕ) : ℝ) = (2:ℝ) := by norm_num
    rw [pw, this]
    rw [show (-(1:ℝ)) = ((-1 : ℤ) : ℝ) by norm_num, Real.rpow_intCast]
    norm_num
  have h4 : pw (2:ℝ) 2 = 1/4 := by
    have : ((2:ℕ) : ℝ) = (2:ℝ) := by norm_num
    rw [pw, this]
    rw [show (-(2:ℝ)) = ((-2 : ℤ) : ℝ) by norm_num, Real.rpow_intCast]
    norm_num
  rw [mix, mix, h1, h2, h3, h4]
  norm_num

/-- The resolving mixture is genuinely two-component and genuinely steeper at the edge
than the harmonic bulk it refines: its local exponent lies strictly between `1` and `2`
at every index, while its steep share decays to zero. -/
theorem harmonic_edge_mixture_local_exponents {k : ℕ} (hk : 1 ≤ k) :
    1 < localExp (mix (54/127) 1 2) k ∧ localExp (mix (54/127) 1 2) k < 2 :=
  localExp_mix_mem_Ioo (by norm_num) (by norm_num) (by norm_num) hk

/-! ## Quantitative bulk recovery for the local exponent

The local exponent of a bulk × edge mixture exceeds the bulk exponent at every index, but
only by `O(k^{-(b-a)})`: the edge steepening is a genuinely local excess that decays at a
power rate, and the measured exponent converges to the bulk exponent. -/

lemma mix_eq_factor {w a b : ℝ} {k : ℕ} (hk : 1 ≤ k) :
    mix w a b k = pw a k * ((1 - w) + w * (k : ℝ) ^ (-(b - a))) := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have : (k:ℝ) ^ (-a) * (k:ℝ) ^ (-(b - a)) = (k:ℝ) ^ (-b) := by
    rw [← Real.rpow_add hk0]; ring_nf
  unfold mix pw
  rw [← this]
  ring

/-- `1 - d * log u ≤ u ^ (-d)` for `u ≥ 1`: the exponential bound behind the decay rate. -/
lemma one_sub_mul_log_le_rpow_neg {u d : ℝ} (hu : 1 ≤ u) :
    1 - d * Real.log u ≤ u ^ (-d) := by
  have hu0 : (0:ℝ) < u := lt_of_lt_of_le one_pos hu
  rw [Real.rpow_def_of_pos hu0]
  have h := Real.add_one_le_exp (Real.log u * (-d))
  nlinarith [h]

/-- **Quantitative edge excess.**  The local exponent of a bulk × edge mixture exceeds the
bulk exponent `a`, by at most `(w/(1-w)) * (b-a) * k^{-(b-a)}`. -/
theorem localExp_mix_le {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) (hab : a < b) {k : ℕ}
    (hk : 1 ≤ k) :
    localExp (mix w a b) k ≤ a + (w / (1 - w)) * (b - a) * (k : ℝ) ^ (-(b - a)) := by
  set d : ℝ := b - a with hd_def
  have hd : 0 < d := by simp [hd_def]; linarith
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hk1 : (1:ℝ) ≤ (k:ℝ) := by exact_mod_cast hk
  have hcast : ((k + 1 : ℕ) : ℝ) = (k:ℝ) + 1 := by push_cast; ring
  have hstep : (1:ℝ) < ((k:ℝ) + 1) / k := by rw [lt_div_iff₀ hk0]; linarith
  have hL : 0 < Real.log ((k + 1 : ℝ) / k) := log_step_pos hk
  set L : ℝ := Real.log (((k:ℝ) + 1) / k) with hL_def
  -- the two shape factors
  set Fk : ℝ := (1 - w) + w * (k : ℝ) ^ (-d) with hFk
  set Fk1 : ℝ := (1 - w) + w * ((k : ℝ) + 1) ^ (-d) with hFk1
  have hkd : 0 < (k : ℝ) ^ (-d) := Real.rpow_pos_of_pos hk0 _
  have hk1d : 0 < ((k : ℝ) + 1) ^ (-d) := Real.rpow_pos_of_pos (by linarith) _
  have hFkpos : 0 < Fk := by rw [hFk]; nlinarith
  have hFk1pos : 0 < Fk1 := by rw [hFk1]; nlinarith
  have hFk1ge : 1 - w ≤ Fk1 := by rw [hFk1]; nlinarith
  -- factorisation of the mixture
  have hm1 : mix w a b k = pw a k * Fk := mix_eq_factor hk
  have hm2 : mix w a b (k + 1) = pw a (k + 1) * Fk1 := by
    have := mix_eq_factor (w := w) (a := a) (b := b) (k := k + 1) (by omega)
    rwa [hcast] at this
  have hpa : 0 < pw a k := pw_pos hk
  have hpa1 : 0 < pw a (k + 1) := pw_pos (by omega)
  -- the ratio splits
  have hsplit : mix w a b k / mix w a b (k + 1)
      = (((k:ℝ) + 1) / k) ^ a * (Fk / Fk1) := by
    rw [hm1, hm2, mul_div_mul_comm, pw_ratio hk]
  have hloggt : Real.log (mix w a b k / mix w a b (k + 1)) = a * L + Real.log (Fk / Fk1) := by
    rw [hsplit, Real.log_mul (by positivity) (by positivity), Real.log_rpow (by positivity),
      hL_def]
  -- bound the shape correction
  have hdiff : (k : ℝ) ^ (-d) - ((k:ℝ) + 1) ^ (-d) ≤ d * (k : ℝ) ^ (-d) * L := by
    have hfac : ((k:ℝ) + 1) ^ (-d) = (k : ℝ) ^ (-d) * ((((k:ℝ) + 1) / k) ^ (-d)) := by
      rw [← Real.mul_rpow hk0.le (by positivity)]
      congr 1
      field_simp
    have hb := one_sub_mul_log_le_rpow_neg (u := ((k:ℝ) + 1) / k) (d := d) hstep.le
    rw [hfac]
    nlinarith [hkd, hb]
  have hratio_le : Fk / Fk1 - 1 ≤ (w / (1 - w)) * (d * (k : ℝ) ^ (-d) * L) := by
    have hnum : Fk - Fk1 = w * ((k : ℝ) ^ (-d) - ((k:ℝ) + 1) ^ (-d)) := by
      rw [hFk, hFk1]; ring
    have hnn : 0 ≤ (k : ℝ) ^ (-d) - ((k:ℝ) + 1) ^ (-d) := by
      have : ((k:ℝ) + 1) ^ (-d) ≤ (k : ℝ) ^ (-d) := by
        rw [Real.rpow_neg hk0.le, Real.rpow_neg (by linarith)]
        have : (k : ℝ) ^ d ≤ ((k:ℝ) + 1) ^ d :=
          Real.rpow_le_rpow hk0.le (by linarith) hd.le
        have h1 : (0:ℝ) < (k:ℝ) ^ d := Real.rpow_pos_of_pos hk0 _
        have h2 : (0:ℝ) < ((k:ℝ) + 1) ^ d := Real.rpow_pos_of_pos (by linarith) _
        exact inv_anti₀ h1 this
      linarith
    have hstep1 : Fk / Fk1 - 1 = (Fk - Fk1) / Fk1 := by field_simp
    rw [hstep1, hnum, div_le_iff₀ hFk1pos]
    have hwpos : 0 < w / (1 - w) := div_pos hw0 (by linarith)
    have hLnn : 0 ≤ L := hL.le
    have hkey : w * ((k : ℝ) ^ (-d) - ((k:ℝ) + 1) ^ (-d)) ≤ w * (d * (k : ℝ) ^ (-d) * L) :=
      mul_le_mul_of_nonneg_left hdiff hw0.le
    have hpos2 : 0 ≤ d * (k : ℝ) ^ (-d) * L := by positivity
    have hw' : (1:ℝ) - w ≠ 0 := by linarith
    have : (w / (1 - w)) * (d * (k : ℝ) ^ (-d) * L) * (1 - w)
        = w * (d * (k : ℝ) ^ (-d) * L) := by field_simp
    nlinarith [mul_le_mul_of_nonneg_left hFk1ge (mul_nonneg hwpos.le hpos2)]
  have hlogle : Real.log (Fk / Fk1) ≤ (w / (1 - w)) * (d * (k : ℝ) ^ (-d) * L) :=
    le_trans (Real.log_le_sub_one_of_pos (by positivity)) hratio_le
  rw [localExp, hloggt, ← hL_def, div_le_iff₀ hL]
  nlinarith [hlogle]

/-- **Bulk recovery at the level of exponents.**  The local exponent of a bulk × edge
mixture converges to the bulk exponent. -/
theorem localExp_mix_tendsto {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) (hab : a < b) :
    Tendsto (fun k : ℕ => localExp (mix w a b) k) atTop (nhds a) := by
  have hpow : Tendsto (fun k : ℕ => (k : ℝ) ^ (-(b - a))) atTop (nhds 0) := by
    have h1 : Tendsto (fun x : ℝ => x ^ (b - a)) atTop atTop :=
      tendsto_rpow_atTop (by linarith)
    have h2 : Tendsto (fun k : ℕ => ((k : ℝ)) ^ (b - a)) atTop atTop :=
      h1.comp tendsto_natCast_atTop_atTop
    have h3 : Tendsto (fun k : ℕ => ((k : ℝ) ^ (b - a))⁻¹) atTop (nhds 0) := h2.inv_tendsto_atTop
    refine h3.congr ?_
    intro k
    rcases Nat.eq_zero_or_pos k with hk | hk
    · subst hk
      simp [Real.zero_rpow (by linarith : b - a ≠ 0),
        Real.zero_rpow (by linarith : a - b ≠ 0)]
    · have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
      rw [Real.rpow_neg hk0.le]
  have hupper : Tendsto
      (fun k : ℕ => a + (w / (1 - w)) * (b - a) * (k : ℝ) ^ (-(b - a))) atTop (nhds a) := by
    have := (hpow.const_mul ((w / (1 - w)) * (b - a))).const_add a
    simpa using this
  refine tendsto_of_tendsto_of_tendsto_of_le_of_le' tendsto_const_nhds hupper ?_ ?_
  · filter_upwards [eventually_ge_atTop 1] with k hk
    exact (localExp_mix_mem_Ioo hw0 hw1 hab hk).1.le
  · filter_upwards [eventually_ge_atTop 1] with k hk
    exact localExp_mix_le hw0 hw1 hab hk

/-! ## Well-posedness of the window-implied exponent

A head statistic is turned into an *implied exponent* by inverting `a ↦ headMass a n m`.
The map is continuous and strictly increasing, so the inversion is well posed, and the
implied exponent of a bulk × edge mixture always lies strictly between the two component
exponents — the formal content of "a steeper edge inflates the exponent read off from a
head window". -/

lemma continuous_pw (k : ℕ) (hk : 1 ≤ k) : Continuous (fun a : ℝ => pw a k) := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have : (fun a : ℝ => pw a k) = fun a : ℝ => Real.exp (Real.log (k:ℝ) * (-a)) := by
    funext a; rw [pw, Real.rpow_def_of_pos hk0]
  rw [this]
  fun_prop

lemma continuous_headSum (m : ℕ) : Continuous (fun a : ℝ => headSum a m) := by
  rw [show (fun a : ℝ => headSum a m) = fun a : ℝ => ∑ k ∈ Finset.Icc 1 m, pw a k from rfl]
  exact continuous_finset_sum _ (fun k hk => continuous_pw k (Finset.mem_Icc.1 hk).1)

lemma continuous_headMass {n : ℕ} (hn : 1 ≤ n) (m : ℕ) :
    Continuous (fun a : ℝ => headMass a n m) := by
  refine (continuous_headSum m).div (continuous_headSum n) (fun a => ?_)
  exact ne_of_gt (headSum_pos hn)

/-- **Well-posedness of the implied exponent.**  Any head-mass value strictly between two
achievable ones is achieved by exactly one exponent. -/
theorem exists_unique_exponent_of_headMass_between {a₀ a₁ v : ℝ} {m n : ℕ}
    (h01 : a₀ ≤ a₁) (hm : 1 ≤ m) (hmn : m < n)
    (hv : v ∈ Set.Ioo (headMass a₀ n m) (headMass a₁ n m)) :
    ∃! a : ℝ, headMass a n m = v := by
  have hn : 1 ≤ n := by omega
  obtain ⟨a, -, ha⟩ :=
    intermediate_value_Ioo h01 ((continuous_headMass hn m).continuousOn) hv
  refine ⟨a, ha, fun c hc => ?_⟩
  exact exponent_unique_of_headMass_eq hm hmn (hc.trans ha.symm)

/-- **The window-implied exponent of a bulk × edge mixture is strictly between the two
component exponents.**  Reading a single head window off a two-component kernel therefore
reports a value strictly steeper than the bulk. -/
theorem mix_implied_exponent_mem_Ioo {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) (hab : a < b)
    {m n : ℕ} (hm : 1 ≤ m) (hmn : m < n) :
    ∃ c ∈ Set.Ioo a b, headMass c n m = mixHeadMass w a b n m := by
  have hn : 1 ≤ n := by omega
  obtain ⟨hlo, hhi⟩ := headMass_mix_mem_Ioo hw0 hw1 hab hm hmn
  obtain ⟨c, hc, hcv⟩ :=
    intermediate_value_Ioo hab.le ((continuous_headMass hn m).continuousOn) ⟨hlo, hhi⟩
  exact ⟨c, hc, hcv⟩

/-- Consequently the harmonic-bulk / quadratic-edge kernel reports, on every head window,
an implied exponent strictly inside `(1, 2)` — steeper than harmonic, yet with harmonic
bulk (`steepShare_tendsto_zero`). -/
theorem harmonic_edge_mixture_window_exponent {m n : ℕ} (hm : 1 ≤ m) (hmn : m < n) :
    ∃ c ∈ Set.Ioo (1:ℝ) 2, headMass c n m = mixHeadMass (54/127) 1 2 n m :=
  mix_implied_exponent_mem_Ioo (by norm_num) (by norm_num) (by norm_num) hm hmn

/-! ## Single crossing: narrower windows report steeper exponents

The ratio of a two-component kernel to a pure power law is `U`-shaped in `log k` (a sum of
two exponentials, hence quasiconvex), so it can cross any level at most once from below.
This forces the *window-implied exponent* of a bulk × edge mixture to be antitone in the
window width: narrow head windows report steeper exponents than wide ones — precisely the
"steeper-than-harmonic left edge versus harmonic bulk" signature. -/

lemma exp_rpow (s t : ℝ) : (Real.exp s) ^ t = Real.exp (s * t) := by
  rw [Real.rpow_def_of_pos (Real.exp_pos s), Real.log_exp]

/-- A nonnegative combination of two real powers is quasiconvex in the logarithmic
variable: its value at an intermediate point never exceeds the larger endpoint value. -/
lemma two_term_rpow_quasiconvex {A B al ga x y z : ℝ} (hA : 0 ≤ A) (hB : 0 ≤ B)
    (hx : 0 < x) (hxy : x < y) (hyz : y < z) :
    A * y ^ al + B * y ^ ga
      ≤ max (A * x ^ al + B * x ^ ga) (A * z ^ al + B * z ^ ga) := by
  have hy : 0 < y := lt_trans hx hxy
  have hz : 0 < z := lt_trans hy hyz
  set l1 := Real.log x with hl1
  set l2 := Real.log y with hl2
  set l3 := Real.log z with hl3
  have h12 : l1 < l2 := Real.log_lt_log hx hxy
  have h23 : l2 < l3 := Real.log_lt_log hy hyz
  have hden : 0 < l3 - l1 := by linarith
  set lam := (l3 - l2) / (l3 - l1) with hlam
  have hlam0 : 0 ≤ lam := div_nonneg (by linarith) hden.le
  have hlam1 : lam ≤ 1 := by
    rw [hlam, div_le_one hden]
    linarith
  have hcomb : l2 = lam * l1 + (1 - lam) * l3 := by
    rw [hlam]
    field_simp
    ring
  have key : ∀ e : ℝ, y ^ e = (x ^ e) ^ lam * (z ^ e) ^ (1 - lam) := by
    intro e
    rw [Real.rpow_def_of_pos hx, Real.rpow_def_of_pos hy, Real.rpow_def_of_pos hz,
      exp_rpow, exp_rpow, ← Real.exp_add]
    congr 1
    rw [← hl1, ← hl2, ← hl3, hcomb]
    ring
  have hb1 : y ^ al ≤ lam * x ^ al + (1 - lam) * z ^ al := by
    rw [key al]
    exact Real.geom_mean_le_arith_mean2_weighted hlam0 (by linarith)
      (Real.rpow_nonneg hx.le _) (Real.rpow_nonneg hz.le _) (by ring)
  have hb2 : y ^ ga ≤ lam * x ^ ga + (1 - lam) * z ^ ga := by
    rw [key ga]
    exact Real.geom_mean_le_arith_mean2_weighted hlam0 (by linarith)
      (Real.rpow_nonneg hx.le _) (Real.rpow_nonneg hz.le _) (by ring)
  have hmid : A * y ^ al + B * y ^ ga
      ≤ lam * (A * x ^ al + B * x ^ ga) + (1 - lam) * (A * z ^ al + B * z ^ ga) := by
    nlinarith [mul_le_mul_of_nonneg_left hb1 hA, mul_le_mul_of_nonneg_left hb2 hB]
  have hmx : A * x ^ al + B * x ^ ga
      ≤ max (A * x ^ al + B * x ^ ga) (A * z ^ al + B * z ^ ga) := le_max_left _ _
  have hmz : A * z ^ al + B * z ^ ga
      ≤ max (A * x ^ al + B * x ^ ga) (A * z ^ al + B * z ^ ga) := le_max_right _ _
  nlinarith [mul_le_mul_of_nonneg_left hmx hlam0,
    mul_le_mul_of_nonneg_left hmz (by linarith : (0:ℝ) ≤ 1 - lam)]

/-- Ratio of the mixture to the pure power law with exponent `c`. -/
noncomputable def mixRatio (w a b c : ℝ) (k : ℕ) : ℝ := mix w a b k / pw c k

lemma mixRatio_eq (w a b c : ℝ) {k : ℕ} (hk : 1 ≤ k) :
    mixRatio w a b c k = (1 - w) * (k : ℝ) ^ (c - a) + w * (k : ℝ) ^ (c - b) := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hc : (k:ℝ) ^ (-c) ≠ 0 := ne_of_gt (Real.rpow_pos_of_pos hk0 _)
  have e1 : (k:ℝ) ^ (-a) / (k:ℝ) ^ (-c) = (k:ℝ) ^ (c - a) := by
    rw [← Real.rpow_sub hk0]; ring_nf
  have e2 : (k:ℝ) ^ (-b) / (k:ℝ) ^ (-c) = (k:ℝ) ^ (c - b) := by
    rw [← Real.rpow_sub hk0]; ring_nf
  rw [mixRatio, mix, pw, pw, pw, add_div, mul_div_assoc, mul_div_assoc, e1, e2]

/-- Quasiconvexity of the mixture-to-power-law ratio in the index. -/
lemma mixRatio_quasiconvex {w a b c : ℝ} (hw0 : 0 ≤ w) (hw1 : w ≤ 1) {i j l : ℕ}
    (hi : 1 ≤ i) (hij : i < j) (hjl : j < l) :
    mixRatio w a b c j ≤ max (mixRatio w a b c i) (mixRatio w a b c l) := by
  have hi0 : (0:ℝ) < (i:ℝ) := by exact_mod_cast hi
  have hij' : (i:ℝ) < (j:ℝ) := by exact_mod_cast hij
  have hjl' : (j:ℝ) < (l:ℝ) := by exact_mod_cast hjl
  rw [mixRatio_eq w a b c hi, mixRatio_eq w a b c (by omega : 1 ≤ j),
    mixRatio_eq w a b c (by omega : 1 ≤ l)]
  exact two_term_rpow_quasiconvex (by linarith) hw0 hi0 hij' hjl'

/-- **No return below a level.**  Once the mixture-to-power-law ratio has crossed a level
from below, it stays above that level. -/
lemma mixRatio_gt_of_crossed {w a b c theta : ℝ} (hw0 : 0 ≤ w) (hw1 : w ≤ 1) {k₁ k₀ k : ℕ}
    (hk₁ : 1 ≤ k₁) (h₁₀ : k₁ < k₀) (h₀k : k₀ < k)
    (hlow : mixRatio w a b c k₁ < theta) (hhigh : theta < mixRatio w a b c k₀) :
    theta < mixRatio w a b c k := by
  by_contra hcon
  push_neg at hcon
  have := mixRatio_quasiconvex (w := w) (a := a) (b := b) (c := c) hw0 hw1 hk₁ h₁₀ h₀k
  have hmax : max (mixRatio w a b c k₁) (mixRatio w a b c k) ≤ theta :=
    max_le hlow.le hcon
  linarith

lemma mix_head_sum_pos {w a b : ℝ} (hw0 : 0 < w) (hw1 : w < 1) {m : ℕ} (hm : 1 ≤ m) :
    0 < mixHeadSum w a b m := by
  refine Finset.sum_pos (fun k hk => ?_) ⟨1, by simp [hm]⟩
  exact mix_pos hw0 hw1 (Finset.mem_Icc.1 hk).1

/-- **Single-crossing window law.**  If a pure power law with exponent `c` matches the head
mass of a bulk × edge mixture on the window `{1, …, m₂}`, then on every narrower window it
reports *less* head mass than the mixture. -/
theorem headMass_le_mixHeadMass_of_match {w a b c : ℝ} (hw0 : 0 < w) (hw1 : w < 1)
    {m₁ m₂ n : ℕ} (hm₁ : 1 ≤ m₁) (h₁₂ : m₁ < m₂) (h₂n : m₂ < n)
    (hmatch : headMass c n m₂ = mixHeadMass w a b n m₂) :
    headMass c n m₁ ≤ mixHeadMass w a b n m₁ := by
  have hPn : 0 < headSum c n := headSum_pos (by omega)
  have hPm₁ : 0 < headSum c m₁ := headSum_pos hm₁
  have hQn : 0 < mixHeadSum w a b n := mix_head_sum_pos hw0 hw1 (by omega)
  set theta : ℝ := mixHeadSum w a b n / headSum c n with htheta
  have hthetapos : 0 < theta := div_pos hQn hPn
  -- the signed discrepancy
  set h : ℕ → ℝ := fun k => mix w a b k - theta * pw c k with hh
  have hT : ∀ m : ℕ, ∑ k ∈ Finset.Icc 1 m, h k
      = mixHeadSum w a b m - theta * headSum c m := by
    intro m
    simp [hh, mixHeadSum, headSum, Finset.sum_sub_distrib, Finset.mul_sum]
  have hsign : ∀ k : ℕ, 1 ≤ k → h k = pw c k * (mixRatio w a b c k - theta) := by
    intro k hk
    have hp : (0:ℝ) < pw c k := pw_pos hk
    simp only [hh, mixRatio]
    field_simp
  have hTn : ∑ k ∈ Finset.Icc 1 n, h k = 0 := by
    rw [hT, htheta]
    field_simp
    ring
  have hTm₂ : ∑ k ∈ Finset.Icc 1 m₂, h k = 0 := by
    rw [hT, htheta]
    have hQm₂ : mixHeadSum w a b m₂ = (mixHeadSum w a b n / headSum c n) * headSum c m₂ := by
      have := hmatch
      rw [headMass, mixHeadMass, div_eq_div_iff (ne_of_gt hPn) (ne_of_gt hQn)] at this
      field_simp
      linarith [this]
    rw [hQm₂]
    ring
  -- it suffices to show the discrepancy on the narrow window is nonnegative
  have hgoal : 0 ≤ ∑ k ∈ Finset.Icc 1 m₁, h k →
      headMass c n m₁ ≤ mixHeadMass w a b n m₁ := by
    intro hpos
    rw [hT] at hpos
    rw [headMass, mixHeadMass, div_le_div_iff₀ hPn hQn]
    have hle : theta * headSum c m₁ ≤ mixHeadSum w a b m₁ := by linarith
    have hth : theta * headSum c m₁ * headSum c n = mixHeadSum w a b n * headSum c m₁ := by
      rw [htheta]; field_simp
    nlinarith [mul_nonneg (by linarith : (0:ℝ) ≤ mixHeadSum w a b m₁ - theta * headSum c m₁)
      hPn.le, hth]
  refine hgoal ?_
  by_contra hneg
  push_neg at hneg
  -- a point of the narrow window sits strictly below the level
  obtain ⟨k₁, hk₁mem, hk₁lt⟩ :
      ∃ k₁ ∈ Finset.Icc 1 m₁, h k₁ < 0 := by
    by_contra hcon
    push_neg at hcon
    exact absurd (Finset.sum_nonneg (fun k hk => hcon k hk)) (by linarith)
  -- between the two windows the discrepancy is positive somewhere
  have hsplit₁ : ∑ k ∈ Finset.Icc 1 m₂, h k
      = ∑ k ∈ Finset.Icc 1 m₁, h k + ∑ k ∈ Finset.Ioc m₁ m₂, h k :=
    sum_Icc_split h h₁₂.le
  obtain ⟨k₀, hk₀mem, hk₀gt⟩ : ∃ k₀ ∈ Finset.Ioc m₁ m₂, 0 < h k₀ := by
    by_contra hcon
    push_neg at hcon
    have : ∑ k ∈ Finset.Ioc m₁ m₂, h k ≤ 0 :=
      Finset.sum_nonpos (fun k hk => hcon k hk)
    rw [hTm₂] at hsplit₁
    linarith
  -- past `k₀` the discrepancy stays positive
  have hk₁one : 1 ≤ k₁ := (Finset.mem_Icc.1 hk₁mem).1
  have hk₁le : k₁ ≤ m₁ := (Finset.mem_Icc.1 hk₁mem).2
  have hk₀lo : m₁ < k₀ := (Finset.mem_Ioc.1 hk₀mem).1
  have hk₀hi : k₀ ≤ m₂ := (Finset.mem_Ioc.1 hk₀mem).2
  have hk₁ratio : mixRatio w a b c k₁ < theta := by
    have hp : (0:ℝ) < pw c k₁ := pw_pos hk₁one
    have := hsign k₁ hk₁one
    nlinarith [hk₁lt, this]
  have hk₀ratio : theta < mixRatio w a b c k₀ := by
    have hp : (0:ℝ) < pw c k₀ := pw_pos (by omega)
    have := hsign k₀ (by omega)
    nlinarith [hk₀gt, this]
  have htail : ∀ k ∈ Finset.Ioc m₂ n, 0 < h k := by
    intro k hk
    have hkgt : m₂ < k := (Finset.mem_Ioc.1 hk).1
    have hkone : 1 ≤ k := by omega
    have hratio : theta < mixRatio w a b c k :=
      mixRatio_gt_of_crossed hw0.le hw1.le hk₁one (by omega) (by omega) hk₁ratio hk₀ratio
    have hp : (0:ℝ) < pw c k := pw_pos hkone
    have := hsign k hkone
    nlinarith [hratio, this]
  have hsplit₂ : ∑ k ∈ Finset.Icc 1 n, h k
      = ∑ k ∈ Finset.Icc 1 m₂, h k + ∑ k ∈ Finset.Ioc m₂ n, h k :=
    sum_Icc_split h h₂n.le
  have hpos2 : 0 < ∑ k ∈ Finset.Ioc m₂ n, h k :=
    Finset.sum_pos htail ⟨n, by simp [h₂n]⟩
  rw [hTn, hTm₂] at hsplit₂
  linarith

/-- **The window-implied exponent is antitone in the window width.**  For a bulk × edge
mixture, a narrower head window always reports an implied exponent at least as steep as a
wider one. -/
theorem implied_exponent_antitone {w a b c₁ c₂ : ℝ} (hw0 : 0 < w) (hw1 : w < 1)
    {m₁ m₂ n : ℕ} (hm₁ : 1 ≤ m₁) (h₁₂ : m₁ < m₂) (h₂n : m₂ < n)
    (h₁ : headMass c₁ n m₁ = mixHeadMass w a b n m₁)
    (h₂ : headMass c₂ n m₂ = mixHeadMass w a b n m₂) :
    c₂ ≤ c₁ := by
  by_contra hcon
  push_neg at hcon
  have hstrict : headMass c₁ n m₁ < headMass c₂ n m₁ :=
    headMass_lt_of_exponent_lt hcon hm₁ (by omega)
  have hle : headMass c₂ n m₁ ≤ mixHeadMass w a b n m₁ :=
    headMass_le_mixHeadMass_of_match hw0 hw1 hm₁ h₁₂ h₂n h₂
  rw [h₁] at hstrict
  linarith

/-- **Capstone.**  For the harmonic-bulk / quadratic-edge kernel and any two nested head
windows, both windows report implied exponents strictly inside `(1, 2)`, and the narrower
window's exponent is the steeper one. -/
theorem harmonic_edge_mixture_window_exponents_antitone {m₁ m₂ n : ℕ} (hm₁ : 1 ≤ m₁)
    (h₁₂ : m₁ < m₂) (h₂n : m₂ < n) :
    ∃ c₁ ∈ Set.Ioo (1:ℝ) 2, ∃ c₂ ∈ Set.Ioo (1:ℝ) 2,
      headMass c₁ n m₁ = mixHeadMass (54/127) 1 2 n m₁ ∧
      headMass c₂ n m₂ = mixHeadMass (54/127) 1 2 n m₂ ∧ c₂ ≤ c₁ := by
  obtain ⟨c₁, hc₁, h₁⟩ := harmonic_edge_mixture_window_exponent (n := n) hm₁ (by omega)
  obtain ⟨c₂, hc₂, h₂⟩ := harmonic_edge_mixture_window_exponent (by omega : 1 ≤ m₂) h₂n
  exact ⟨c₁, hc₁, c₂, hc₂, h₁, h₂,
    implied_exponent_antitone (by norm_num) (by norm_num) hm₁ h₁₂ h₂n h₁ h₂⟩

/-! ## Weighted versus equal-weight counting

Equal-weight counting is the degenerate exponent `a = 0`, for which the head statistic is
exactly `m/n`.  Any genuinely decaying weight is strictly head-biased, so head statistics
read off an equal-weight dial and a `1/ℓ`-weighted dial are never comparable. -/

lemma pw_strictAnti {a : ℝ} (ha : 0 < a) {k j : ℕ} (hk : 1 ≤ k) (hkj : k < j) :
    pw a j < pw a k := by
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk
  have hj0 : (0:ℝ) < (j:ℝ) := lt_trans hk0 (by exact_mod_cast hkj)
  have hlt : (k:ℝ) ^ a < (j:ℝ) ^ a :=
    Real.rpow_lt_rpow hk0.le (by exact_mod_cast hkj) ha
  have h1 : (0:ℝ) < (k:ℝ) ^ a := Real.rpow_pos_of_pos hk0 _
  rw [pw, pw, Real.rpow_neg hk0.le, Real.rpow_neg hj0.le]
  exact inv_strictAnti₀ h1 hlt

/-- **Strict head bias of decaying weights.**  For any positive exponent the head window
carries strictly more than its equal-weight share `m/n`. -/
theorem headMass_gt_uniform {a : ℝ} (ha : 0 < a) {m n : ℕ} (hm : 1 ≤ m) (hmn : m < n) :
    (m : ℝ) / n < headMass a n m := by
  have hn0 : (0:ℝ) < (n:ℝ) := by exact_mod_cast (by omega : 0 < n)
  have hHm : 0 < headSum a m := headSum_pos hm
  have hHn : 0 < headSum a n := headSum_pos (by omega)
  have hpm : 0 < pw a m := pw_pos hm
  -- head sum is at least `m` copies of the smallest head weight
  have hhead : (m : ℝ) * pw a m ≤ headSum a m := by
    have := Finset.card_nsmul_le_sum (Finset.Icc 1 m) (fun k => pw a k) (pw a m)
      (fun k hk => by
        rcases eq_or_lt_of_le (Finset.mem_Icc.1 hk).2 with h | h
        · rw [h]
        · exact (pw_strictAnti ha (Finset.mem_Icc.1 hk).1 h).le)
    simpa [headSum, nsmul_eq_mul] using this
  -- tail sum is strictly less than `n - m` copies of that weight
  have htail : (∑ k ∈ Finset.Ioc m n, pw a k) < ((n : ℝ) - m) * pw a m := by
    have hne : (Finset.Ioc m n).Nonempty := ⟨n, by simp [hmn]⟩
    have hlt : ∑ k ∈ Finset.Ioc m n, pw a k < ∑ _k ∈ Finset.Ioc m n, pw a m :=
      Finset.sum_lt_sum_of_nonempty hne (fun k hk =>
        pw_strictAnti ha hm (Finset.mem_Ioc.1 hk).1)
    have hcard : (((n - m : ℕ)) : ℝ) = (n : ℝ) - m := by
      push_cast [Nat.cast_sub hmn.le]
      ring
    simpa [Finset.sum_const, nsmul_eq_mul, Nat.card_Ioc, hcard] using hlt
  have hsplit : headSum a n = headSum a m + ∑ k ∈ Finset.Ioc m n, pw a k :=
    headSum_split hmn.le
  rw [headMass, div_lt_div_iff₀ hn0 hHn, hsplit]
  have hmn' : (m : ℝ) < (n : ℝ) := by exact_mod_cast hmn
  have hm' : (0:ℝ) < (m : ℝ) := by exact_mod_cast hm
  nlinarith [mul_le_mul_of_nonneg_left hhead (show (0:ℝ) ≤ (n:ℝ) - m by linarith),
    mul_lt_mul_of_pos_left htail hm']

/-! ## Saturation dichotomy for the head dial

As the truncation `n` grows, the head statistic either saturates at a positive limit or
collapses to `0`, according to whether the exponent exceeds the harmonic value `1`.  The
harmonic kernel itself sits exactly on the non-saturating side of the threshold. -/

lemma pw_zero {a : ℝ} (ha : a ≠ 0) : pw a 0 = 0 := by
  simp [pw, Real.zero_rpow (neg_ne_zero.mpr ha)]

lemma headSum_eq_range {a : ℝ} (ha : a ≠ 0) (n : ℕ) :
    headSum a n = ∑ k ∈ Finset.range (n + 1), pw a k := by
  induction n with
  | zero => simp [headSum, pw_zero ha]
  | succ n ih =>
      rw [headSum, Finset.sum_Icc_succ_top (by omega), ← headSum, ih,
        Finset.sum_range_succ (n := n + 1)]

lemma summable_pw {a : ℝ} (ha : 1 < a) : Summable (fun k : ℕ => pw a k) := by
  have h : (fun k : ℕ => pw a k) = fun k : ℕ => ((k : ℝ) ^ a)⁻¹ := by
    funext k
    rw [pw, Real.rpow_neg (Nat.cast_nonneg k)]
  rw [h]
  exact Real.summable_nat_rpow_inv.mpr ha

/-- Above the harmonic threshold the truncated total weight converges. -/
lemma headSum_tendsto_tsum {a : ℝ} (ha : 1 < a) :
    Tendsto (fun n : ℕ => headSum a n) atTop (nhds (∑' k : ℕ, pw a k)) := by
  have hne : a ≠ 0 := by linarith
  have hsum := (summable_pw ha).hasSum.tendsto_sum_nat
  have hshift : Tendsto (fun n : ℕ => n + 1) atTop atTop := tendsto_add_atTop_nat 1
  have := hsum.comp hshift
  refine this.congr ?_
  intro n
  exact (headSum_eq_range hne n).symm

/-- **Saturation above the harmonic threshold.**  For `a > 1` the head statistic converges
to a strictly positive limit as the truncation grows: the dial saturates. -/
theorem headMass_tendsto_pos_of_one_lt {a : ℝ} (ha : 1 < a) {m : ℕ} (hm : 1 ≤ m) :
    Tendsto (fun n : ℕ => headMass a n m) atTop (nhds (headSum a m / ∑' k : ℕ, pw a k)) ∧
      0 < headSum a m / ∑' k : ℕ, pw a k := by
  have hsummable := summable_pw ha
  have hnn : ∀ k : ℕ, 0 ≤ pw a k := by
    intro k
    rcases Nat.eq_zero_or_pos k with hk | hk
    · simp [hk, pw_zero (by linarith : a ≠ 0)]
    · exact (pw_pos hk).le
  have hpos : 0 < ∑' k : ℕ, pw a k := by
    have h1 : pw a 1 ≤ ∑' k : ℕ, pw a k := hsummable.le_tsum 1 (fun k _ => hnn k)
    have : (0:ℝ) < pw a 1 := pw_pos le_rfl
    linarith
  refine ⟨?_, div_pos (headSum_pos hm) hpos⟩
  exact Tendsto.div tendsto_const_nhds (headSum_tendsto_tsum ha) (ne_of_gt hpos)

lemma harmonic_range_eq_Icc (n : ℕ) :
    ∑ i ∈ Finset.range n, (1:ℝ) / (i + 1) = ∑ k ∈ Finset.Icc 1 n, (1:ℝ) / k := by
  induction n with
  | zero => simp
  | succ n ih =>
      rw [Finset.sum_range_succ, ih, Finset.sum_Icc_succ_top (by omega)]
      push_cast
      ring

/-- At or below the harmonic threshold the truncated total weight diverges. -/
lemma headSum_tendsto_atTop {a : ℝ} (ha : a ≤ 1) :
    Tendsto (fun n : ℕ => headSum a n) atTop atTop := by
  have hharm : Tendsto (fun n : ℕ => ∑ i ∈ Finset.range n, (1:ℝ) / (i + 1)) atTop atTop :=
    Real.tendsto_sum_range_one_div_nat_succ_atTop
  refine tendsto_atTop_mono (fun n => ?_) hharm
  rw [harmonic_range_eq_Icc n, headSum]
  refine Finset.sum_le_sum (fun k hk => ?_)
  have hk1 : 1 ≤ k := (Finset.mem_Icc.1 hk).1
  have hk0 : (0:ℝ) < (k:ℝ) := by exact_mod_cast hk1
  have hk1' : (1:ℝ) ≤ (k:ℝ) := by exact_mod_cast hk1
  have hmono : (k:ℝ) ^ (-(1:ℝ)) ≤ (k:ℝ) ^ (-a) :=
    Real.rpow_le_rpow_of_exponent_le hk1' (by linarith)
  have : (k:ℝ) ^ (-(1:ℝ)) = 1 / (k:ℝ) := by
    rw [Real.rpow_neg hk0.le, Real.rpow_one, one_div]
  rw [pw]
  linarith [this ▸ hmono]

/-- **No saturation at or below the harmonic threshold.**  For `a ≤ 1` — in particular for
the harmonic kernel itself — the head statistic collapses to `0` as the truncation grows. -/
theorem headMass_tendsto_zero_of_le_one {a : ℝ} (ha : a ≤ 1) {m : ℕ} :
    Tendsto (fun n : ℕ => headMass a n m) atTop (nhds 0) :=
  Tendsto.div_atTop tendsto_const_nhds (headSum_tendsto_atTop ha)

end HarmonicBulkSteeperEdge