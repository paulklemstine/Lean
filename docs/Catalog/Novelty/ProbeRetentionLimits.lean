import Novelty.AttentionRetentionKnee

/-!
# How much retention can a content probe buy? (NET-69, selection layer)

NET-69 runs the NET-58/61 eviction methodology on Python source instead of
prose.  Three arms select `B = 64` keys out of a context and are scored by the
**retained attention mass** of the selected set:

| arm                | retained @ B = 64 |
|--------------------|-------------------|
| accumulated-HH     | 0.9340            |
| probe-only         | 0.8149            |
| hybrid (λ = 1)     | 0.9371            |

and the linear content probe explains `R² = 0.3185` of the variance of the true
importances (prose: `0.329`).  The verdict advertised for the round is
*CONTENT-WEAKNESS-IS-DOMAIN-UNIVERSAL*.

This file is the **selection-theoretic layer** of that verdict.  A key insight
of the round — that a *low* `R²` is what makes the probe arm lose — is a claim
about the map

  `prediction accuracy  ↦  retained mass`,

and that map is exactly what can be analysed rigorously.  We fix a finite index
type of keys, true importances `a : ι → ℝ`, a score `s : ι → ℝ`, and define a
**top set** `IsTopSet s B S`: a set of `B` keys none of which is scored below a
discarded key.  This is the (possibly non-unique) output of a greedy budget-`B`
evictor driven by `s`.

The results:

* `sum_le_sum_of_isTopSet` — a top set maximises the *score* mass among all
  budget-`B` sets.  Everything else is a perturbation of this.
* `retained_le_of_isTopSet_true` — with `s = a` one recovers the oracle bound:
  no budget-`B` policy beats the top-`B` true set (`P2`, second clause, in its
  provable form).
* `retained_ge_of_isTopSet_sup` and `retained_ge_of_isTopSet_l2` — the two
  **transfer theorems**: a score whose error is small in `L∞` (resp. `L²`)
  retains almost as much as *any* competing budget-`B` set, with explicit
  losses `2Bε` and `2√(B · SSE)`.
* `retention_gap_le_of_Rsq` — the transfer theorem stated in the currency of the
  experiment: the loss of an `R²`-accurate probe against any rival arm is at
  most `2√(B (1 - R²) · SS_tot)`.
* `net69_dispersion_lower_bound` — read backwards, the *measured* 11.91-point
  loss of the probe arm at `B = 64, R² = 0.3185` is a **lower bound on the
  dispersion of the true importances**: `SS_tot > 8 · 10⁻⁵`.  A measurement of
  the probe deficit is therefore also a measurement of the key population; the
  two numbers are not independent.
* `bound_ratio_code_prose_lt_one_percent` — the code and prose `R²` values
  (`0.3185` vs `0.329`) give worst-case losses within `0.8 %` of each other.
  This is the *quantitative content* of "domain-universal": the two rounds are
  not merely qualitatively similar, they are numerically indistinguishable at
  the level of the guarantee.
* `exists_probe_perfect_retention_with_Rsq` — the **critical** result.  For
  *every* target `R² = ρ ∈ (0,1)` there is a probe with exactly that `R²` that
  reproduces the oracle set for *every* budget.  Hence `R² = 0.32` by itself
  cannot explain the 12-point loss: the loss is caused by the *direction* of
  the residual, never by its size alone.  The bound above is one-sided, and
  provably so.
-/

namespace Catalog.Novelty.ProbeRetentionLimits

open Finset

variable {ι : Type*} [Fintype ι]

/-! ### 1. Budget-`B` selection and top sets -/

/-- Attention mass retained by a selected set of keys. -/
def retained (a : ι → ℝ) (S : Finset ι) : ℝ := ∑ i ∈ S, a i

/-- `S` is a *top set* for the score `s` at budget `B`: it has `B` keys and no
retained key is scored below a discarded key.  This is what a greedy budget-`B`
evictor driven by `s` produces (ties make it non-unique). -/
def IsTopSet (s : ι → ℝ) (B : ℕ) (S : Finset ι) : Prop :=
  S.card = B ∧ ∀ i ∈ S, ∀ j ∉ S, s j ≤ s i

omit [Fintype ι] in
lemma IsTopSet.card {s : ι → ℝ} {B : ℕ} {S : Finset ι} (h : IsTopSet s B S) :
    S.card = B := h.1

omit [Fintype ι] in
/-- **The exchange inequality.**  On the symmetric difference with a competing
set of the same size, the retained block of a top set carries at least as much
score mass as the discarded block.  Everything in this file is a perturbation
of this one inequality. -/
lemma sum_sdiff_le_of_isTopSet [DecidableEq ι] {s : ι → ℝ} {B : ℕ} {S T : Finset ι}
    (hS : IsTopSet s B S) (hT : T.card = B) :
    ∑ i ∈ T \ S, s i ≤ ∑ i ∈ S \ T, s i := by
  classical
  have hcard : S.card = T.card := by rw [hS.1, hT]
  have hdiff : (S \ T).card = (T \ S).card := Finset.card_sdiff_comm hcard
  rcases (T \ S).eq_empty_or_nonempty with he | hne
  · have : (S \ T).card = 0 := by rw [hdiff, he]; simp
    have hS' : S \ T = ∅ := Finset.card_eq_zero.mp this
    simp [he, hS']
  · have hne' : (S \ T).Nonempty := by
      rw [← Finset.card_pos, hdiff, Finset.card_pos]; exact hne
    obtain ⟨i₀, hi₀, hi₀min⟩ := Finset.exists_min_image (S \ T) s hne'
    obtain ⟨j₀, hj₀, hj₀max⟩ := Finset.exists_max_image (T \ S) s hne
    have hi₀S : i₀ ∈ S := (Finset.mem_sdiff.mp hi₀).1
    have hj₀S : j₀ ∉ S := (Finset.mem_sdiff.mp hj₀).2
    have hle : s j₀ ≤ s i₀ := hS.2 i₀ hi₀S j₀ hj₀S
    calc ∑ i ∈ T \ S, s i ≤ (T \ S).card • s j₀ :=
          Finset.sum_le_card_nsmul _ _ _ (fun x hx => hj₀max x hx)
      _ = (S \ T).card • s j₀ := by rw [hdiff]
      _ ≤ (S \ T).card • s i₀ := by
          simp only [nsmul_eq_mul]
          exact mul_le_mul_of_nonneg_left hle (Nat.cast_nonneg _)
      _ ≤ ∑ i ∈ S \ T, s i :=
          Finset.card_nsmul_le_sum _ _ _ (fun x hx => hi₀min x hx)

omit [Fintype ι] in
/-- **A top set maximises score mass.**  Every competing set of the same size
carries at most as much `s`-mass. -/
lemma sum_le_sum_of_isTopSet {s : ι → ℝ} {B : ℕ} {S T : Finset ι}
    (hS : IsTopSet s B S) (hT : T.card = B) : ∑ i ∈ T, s i ≤ ∑ i ∈ S, s i := by
  classical
  have key := sum_sdiff_le_of_isTopSet hS hT
  have hTsplit : ∑ i ∈ T ∩ S, s i + ∑ i ∈ T \ S, s i = ∑ i ∈ T, s i :=
    Finset.sum_inter_add_sum_diff T S s
  have hSsplit : ∑ i ∈ S ∩ T, s i + ∑ i ∈ S \ T, s i = ∑ i ∈ S, s i :=
    Finset.sum_inter_add_sum_diff S T s
  have hcomm : T ∩ S = S ∩ T := Finset.inter_comm T S
  rw [← hTsplit, ← hSsplit, hcomm]
  gcongr

omit [Fintype ι] in
/-- **Oracle bound.**  If the score *is* the true importance, its top set is the
best budget-`B` set: no policy retains more.  (This is the provable content of
the `P2` clause "probe ≤ accumulated ≤ oracle".) -/
theorem retained_le_of_isTopSet_true {a : ι → ℝ} {B : ℕ} {S T : Finset ι}
    (hT : IsTopSet a B T) (hS : S.card = B) : retained a S ≤ retained a T :=
  sum_le_sum_of_isTopSet hT hS

omit [Fintype ι] in
/-- **Uniqueness of a strictly separated selection.**  If a budget-`B` set is
*strictly* separated by the score, then it is the only top set. -/
theorem eq_of_isTopSet_of_strict {s : ι → ℝ} {B : ℕ} {S T : Finset ι}
    (hTcard : T.card = B) (hstrict : ∀ i ∈ T, ∀ j ∉ T, s j < s i)
    (hS : IsTopSet s B S) : S = T := by
  classical
  have hsub : T ⊆ S := by
    intro i hiT
    by_contra hiS
    have hne : (T \ S).Nonempty := ⟨i, Finset.mem_sdiff.mpr ⟨hiT, hiS⟩⟩
    have hcard : S.card = T.card := by rw [hS.1, hTcard]
    have hne' : (S \ T).Nonempty := by
      rw [← Finset.card_pos, Finset.card_sdiff_comm hcard, Finset.card_pos]
      exact hne
    obtain ⟨j, hj⟩ := hne'
    have hjS : j ∈ S := (Finset.mem_sdiff.mp hj).1
    have hjT : j ∉ T := (Finset.mem_sdiff.mp hj).2
    have h1 : s j < s i := hstrict i hiT j hjT
    have h2 : s i ≤ s j := hS.2 j hjS i hiS
    linarith
  exact (Finset.eq_of_subset_of_card_le hsub (by rw [hS.1, hTcard])).symm

/-! ### 2. The two transfer theorems -/

/-- Sum of squared prediction errors of the score `s` for the importances `a`. -/
def sse (a s : ι → ℝ) : ℝ := ∑ i, (a i - s i) ^ 2

lemma sse_nonneg (a s : ι → ℝ) : 0 ≤ sse a s :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- Cauchy–Schwarz on a selected block: the accumulated prediction error of any
`k`-element set is at most `√(k · SSE)`. -/
lemma abs_sum_error_le (a s : ι → ℝ) (S : Finset ι) :
    |∑ i ∈ S, (a i - s i)| ≤ Real.sqrt (S.card * sse a s) := by
  have h1 : (∑ i ∈ S, (a i - s i)) ^ 2 ≤ S.card * ∑ i ∈ S, (a i - s i) ^ 2 :=
    sq_sum_le_card_mul_sum_sq
  have h2 : ∑ i ∈ S, (a i - s i) ^ 2 ≤ sse a s :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ S)
      (fun i _ _ => sq_nonneg _)
  have h3 : (∑ i ∈ S, (a i - s i)) ^ 2 ≤ S.card * sse a s :=
    h1.trans (mul_le_mul_of_nonneg_left h2 (Nat.cast_nonneg _))
  exact Real.abs_le_sqrt h3

/-- **`L²` transfer theorem.**  A budget-`B` set chosen by the score `s` retains
at least as much as *any* competing budget-`B` set, up to `2√(B · SSE)`. -/
theorem retained_ge_of_isTopSet_l2 {a s : ι → ℝ} {B : ℕ} {S T : Finset ι}
    (hS : IsTopSet s B S) (hT : T.card = B) :
    retained a T - 2 * Real.sqrt (B * sse a s) ≤ retained a S := by
  have hscore : ∑ i ∈ T, s i ≤ ∑ i ∈ S, s i := sum_le_sum_of_isTopSet hS hT
  have hSe : |∑ i ∈ S, (a i - s i)| ≤ Real.sqrt (B * sse a s) := by
    have := abs_sum_error_le a s S
    rwa [hS.1] at this
  have hTe : |∑ i ∈ T, (a i - s i)| ≤ Real.sqrt (B * sse a s) := by
    have := abs_sum_error_le a s T
    rwa [hT] at this
  have hSsplit : retained a S = ∑ i ∈ S, s i + ∑ i ∈ S, (a i - s i) := by
    simp [retained, Finset.sum_sub_distrib]
  have hTsplit : retained a T = ∑ i ∈ T, s i + ∑ i ∈ T, (a i - s i) := by
    simp [retained, Finset.sum_sub_distrib]
  have h1 := (abs_le.mp hSe).1
  have h2 := (abs_le.mp hTe).2
  rw [hSsplit, hTsplit]
  linarith

omit [Fintype ι] in
/-- **`L∞` transfer theorem.**  If the score is uniformly `ε`-accurate then the
loss against any competing budget-`B` set is at most `2Bε`. -/
theorem retained_ge_of_isTopSet_sup {a s : ι → ℝ} {B : ℕ} {S T : Finset ι} {ε : ℝ}
    (hS : IsTopSet s B S) (hT : T.card = B) (hε : ∀ i, |a i - s i| ≤ ε) :
    retained a T - 2 * B * ε ≤ retained a S := by
  have hscore : ∑ i ∈ T, s i ≤ ∑ i ∈ S, s i := sum_le_sum_of_isTopSet hS hT
  have hbound : ∀ U : Finset ι, U.card = B → |∑ i ∈ U, (a i - s i)| ≤ B * ε := by
    intro U hU
    calc |∑ i ∈ U, (a i - s i)| ≤ ∑ i ∈ U, |a i - s i| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _i ∈ U, ε := Finset.sum_le_sum (fun i _ => hε i)
      _ = B * ε := by rw [Finset.sum_const, hU, nsmul_eq_mul]
  have h1 := (abs_le.mp (hbound S hS.1)).1
  have h2 := (abs_le.mp (hbound T hT)).2
  have hSsplit : retained a S = ∑ i ∈ S, s i + ∑ i ∈ S, (a i - s i) := by
    simp [retained, Finset.sum_sub_distrib]
  have hTsplit : retained a T = ∑ i ∈ T, s i + ∑ i ∈ T, (a i - s i) := by
    simp [retained, Finset.sum_sub_distrib]
  rw [hSsplit, hTsplit]
  linarith

omit [Fintype ι] in
/-- **Sharp `L∞` transfer.**  The loss is governed by the number of keys that
are actually *exchanged*, `m = |S ∖ T| ≤ B`, not by the budget: an inaccurate
score that happens to disagree with the rival arm on few keys is nearly
harmless.  This strictly strengthens `retained_ge_of_isTopSet_sup`. -/
theorem retained_ge_of_isTopSet_sup_sharp [DecidableEq ι] {a s : ι → ℝ} {B : ℕ} {S T : Finset ι} {ε : ℝ}
    (hS : IsTopSet s B S) (hT : T.card = B) (hε : ∀ i, |a i - s i| ≤ ε) :
    retained a T - 2 * (S \ T).card * ε ≤ retained a S := by
  classical
  have key := sum_sdiff_le_of_isTopSet hS hT
  have hdiff : (S \ T).card = (T \ S).card :=
    Finset.card_sdiff_comm (by rw [hS.1, hT])
  have hbound : ∀ U : Finset ι, |∑ i ∈ U, (a i - s i)| ≤ U.card * ε := by
    intro U
    calc |∑ i ∈ U, (a i - s i)| ≤ ∑ i ∈ U, |a i - s i| := Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _i ∈ U, ε := Finset.sum_le_sum (fun i _ => hε i)
      _ = U.card * ε := by rw [Finset.sum_const, nsmul_eq_mul]
  have hSd : |∑ i ∈ S \ T, (a i - s i)| ≤ (S \ T).card * ε := hbound _
  have hTd : |∑ i ∈ T \ S, (a i - s i)| ≤ (T \ S).card * ε := hbound _
  rw [← hdiff] at hTd
  have hSsum : ∑ i ∈ S \ T, a i = ∑ i ∈ S \ T, s i + ∑ i ∈ S \ T, (a i - s i) := by
    simp [Finset.sum_sub_distrib]
  have hTsum : ∑ i ∈ T \ S, a i = ∑ i ∈ T \ S, s i + ∑ i ∈ T \ S, (a i - s i) := by
    simp [Finset.sum_sub_distrib]
  have hsplitS : ∑ i ∈ S ∩ T, a i + ∑ i ∈ S \ T, a i = retained a S :=
    Finset.sum_inter_add_sum_diff S T a
  have hsplitT : ∑ i ∈ T ∩ S, a i + ∑ i ∈ T \ S, a i = retained a T :=
    Finset.sum_inter_add_sum_diff T S a
  have hcomm : T ∩ S = S ∩ T := Finset.inter_comm T S
  rw [hcomm] at hsplitT
  have h1 := (abs_le.mp hSd).1
  have h2 := (abs_le.mp hTd).2
  rw [← hsplitS, ← hsplitT, hSsum, hTsum]
  linarith

omit [Fintype ι] in
/-- **Near-ties are the whole story.**  If the oracle set is separated from the
discarded keys by a margin strictly larger than twice the score's `L∞` error,
then *every* selection driven by that score coincides with the oracle.  An
`R²`-weak probe is harmless in the absence of near-ties; conversely the observed
probe deficit is a statement about the *tie structure* of the key population. -/
theorem isTopSet_eq_oracle_of_margin {a s : ι → ℝ} {B : ℕ} {S T : Finset ι} {ε γ : ℝ}
    (hTcard : T.card = B) (hγ : 2 * ε < γ)
    (hmargin : ∀ i ∈ T, ∀ j ∉ T, a j + γ ≤ a i)
    (hε : ∀ i, |a i - s i| ≤ ε) (hS : IsTopSet s B S) : S = T := by
  refine eq_of_isTopSet_of_strict hTcard ?_ hS
  intro i hi j hj
  have h1 := abs_le.mp (hε i)
  have h2 := abs_le.mp (hε j)
  have h3 := hmargin i hi j hj
  linarith [h1.1, h1.2, h2.1, h2.2]

/-! ### 3. `R²` and the measured NET-69 numbers -/

/-- Mean true importance. -/
noncomputable def mean (a : ι → ℝ) : ℝ := (∑ i, a i) / Fintype.card ι

/-- Total dispersion of the true importances. -/
noncomputable def sstot (a : ι → ℝ) : ℝ := ∑ i, (a i - mean a) ^ 2

lemma sstot_nonneg (a : ι → ℝ) : 0 ≤ sstot a :=
  Finset.sum_nonneg fun _ _ => sq_nonneg _

/-- Coefficient of determination of a probe `s` for the importances `a`. -/
noncomputable def Rsq (a s : ι → ℝ) : ℝ := 1 - sse a s / sstot a

lemma sse_eq_of_Rsq {a s : ι → ℝ} (h : sstot a ≠ 0) :
    sse a s = (1 - Rsq a s) * sstot a := by
  rw [Rsq]
  field_simp
  ring

/-- **The retention gap of an `R²`-accurate probe.**  Whatever the rival arm
`T`, the probe's deficit is at most `2√(B (1 - R²) SS_tot)`. -/
theorem retention_gap_le_of_Rsq {a s : ι → ℝ} {B : ℕ} {S T : Finset ι}
    (hS : IsTopSet s B S) (hT : T.card = B) (h : sstot a ≠ 0) :
    retained a T - retained a S ≤ 2 * Real.sqrt (B * ((1 - Rsq a s) * sstot a)) := by
  have := retained_ge_of_isTopSet_l2 (a := a) hS hT
  rw [sse_eq_of_Rsq (s := s) h] at this
  linarith

/-- **NET-69 consistency law.**  The measured numbers are not independent: a
probe with `R² = 0.3185` losing `11.91` points of retained mass at `B = 64`
*forces* the true importances to be dispersed, `SS_tot > 8·10⁻⁵`.  A large
probe deficit at a fixed `R²` is evidence about the key population, not only
about the probe. -/
theorem net69_dispersion_lower_bound {a s : ι → ℝ} {S T : Finset ι}
    (hS : IsTopSet s 64 S) (hT : T.card = 64) (h : sstot a ≠ 0)
    (hR : Rsq a s = 0.3185)
    (hgap : 0.1191 ≤ retained a T - retained a S) :
    8 / 100000 < sstot a := by
  have hpos : 0 ≤ sstot a := sstot_nonneg a
  have hmain := retention_gap_le_of_Rsq hS hT h
  rw [hR] at hmain
  have hb : (0.1191 : ℝ) ≤ 2 * Real.sqrt ((64 : ℕ) * ((1 - 0.3185) * sstot a)) := by
    calc (0.1191 : ℝ) ≤ retained a T - retained a S := hgap
      _ ≤ _ := hmain
  have hsq : (0.1191 / 2 : ℝ) ≤ Real.sqrt ((64 : ℕ) * ((1 - 0.3185) * sstot a)) := by
    linarith
  have hnn : (0 : ℝ) ≤ (64 : ℕ) * ((1 - 0.3185) * sstot a) := by
    have : (0:ℝ) ≤ (1 - 0.3185) * sstot a := by nlinarith
    positivity
  have := Real.sq_sqrt hnn
  nlinarith [Real.sqrt_nonneg ((64 : ℕ) * ((1 - 0.3185) * sstot a)),
    Real.sq_sqrt hnn, hsq]

/-- **Domain-universality, quantitatively.**  The code round (`R² = 0.3185`) and
the prose round (`R² = 0.329`) give worst-case retention guarantees within
`0.8 %` of one another: at the level of the bound the two domains are the same
experiment. -/
theorem bound_ratio_code_prose_lt_one_percent :
    Real.sqrt (1 - 0.3185) / Real.sqrt (1 - 0.329) < 1.008 := by
  have h1 : Real.sqrt (1 - 0.329) = Real.sqrt 0.671 := by norm_num
  have h2 : Real.sqrt (1 - 0.3185) = Real.sqrt 0.6815 := by norm_num
  have hpos : 0 < Real.sqrt 0.671 := Real.sqrt_pos.mpr (by norm_num)
  rw [h1, h2, div_lt_iff₀ hpos]
  have hle : Real.sqrt 0.6815 < 1.008 * Real.sqrt 0.671 := by
    have hkey : Real.sqrt 0.6815 < Real.sqrt (1.008 ^ 2 * 0.671) := by
      apply Real.sqrt_lt_sqrt (by norm_num)
      norm_num
    calc Real.sqrt 0.6815 < Real.sqrt (1.008 ^ 2 * 0.671) := hkey
      _ = 1.008 * Real.sqrt 0.671 := by
          rw [Real.sqrt_mul (by positivity), Real.sqrt_sq (by norm_num)]
  linarith

/-! ### 4. `R²` cannot be the mechanism -/

/-- The probe obtained by shrinking the true importances towards their mean by a
factor `c`. -/
noncomputable def shrink (a : ι → ℝ) (c : ℝ) : ι → ℝ :=
  fun i => mean a + c * (a i - mean a)

lemma sse_shrink (a : ι → ℝ) (c : ℝ) : sse a (shrink a c) = (1 - c) ^ 2 * sstot a := by
  unfold sse shrink sstot
  rw [Finset.mul_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  ring

lemma Rsq_shrink {a : ι → ℝ} (h : sstot a ≠ 0) (c : ℝ) :
    Rsq a (shrink a c) = 1 - (1 - c) ^ 2 := by
  unfold Rsq
  rw [sse_shrink]
  field_simp

/-- Shrinking towards the mean by a positive factor is a strictly monotone
reparametrisation, hence preserves the selection at *every* budget. -/
lemma isTopSet_shrink_iff {a : ι → ℝ} {c : ℝ} (hc : 0 < c) (B : ℕ) (S : Finset ι) :
    IsTopSet (shrink a c) B S ↔ IsTopSet a B S := by
  unfold IsTopSet shrink
  constructor
  · rintro ⟨hcard, h⟩
    refine ⟨hcard, fun i hi j hj => ?_⟩
    have := h i hi j hj
    nlinarith [this]
  · rintro ⟨hcard, h⟩
    refine ⟨hcard, fun i hi j hj => ?_⟩
    have := h i hi j hj
    nlinarith [this]

/-- **The critical theorem: `R²` does not determine retention.**  For every
target `ρ ∈ (0,1)` — in particular for the measured `ρ = 0.3185` — there is a
probe with *exactly* that `R²` whose selection agrees with the oracle at every
budget, hence which retains the maximum possible mass.  So the 12-point deficit
of the probe arm is *not* a consequence of `R² = 0.32`; the transfer bound is
one-sided, and the mechanism must be the direction of the residual (its
misordering of near-ties), not its size. -/
theorem exists_probe_perfect_retention_with_Rsq {a : ι → ℝ} (h : sstot a ≠ 0)
    {ρ : ℝ} (hρ0 : 0 < ρ) (hρ1 : ρ < 1) :
    ∃ s : ι → ℝ, Rsq a s = ρ ∧ ∀ (B : ℕ) (S : Finset ι), IsTopSet s B S ↔ IsTopSet a B S := by
  refine ⟨shrink a (1 - Real.sqrt (1 - ρ)), ?_, ?_⟩
  · rw [Rsq_shrink h]
    have : (1 - (1 - Real.sqrt (1 - ρ))) = Real.sqrt (1 - ρ) := by ring
    rw [this, Real.sq_sqrt (by linarith)]
    ring
  · intro B S
    refine isTopSet_shrink_iff ?_ B S
    have hlt : Real.sqrt (1 - ρ) < 1 := by
      have : Real.sqrt (1 - ρ) < Real.sqrt 1 := Real.sqrt_lt_sqrt (by linarith) (by linarith)
      simpa using this
    linarith

/-! ### 5. The boundary band: where the loss actually lives -/

omit [Fintype ι] in
open Classical in
/-- **Boundary-band bound.**  Let `μ` dominate the importance of every discarded
key of the rival selection `T`.  Then the entire retention loss of an
`ε`-accurate score is carried by the keys of `T` whose importance is within
`2ε` of that cut-off: the *safe core* of `T`, the keys that stand clear of the
boundary, is always retained.  This localises `retained_ge_of_isTopSet_sup`:
the relevant statistic is the mass sitting in the band, not the budget. -/
theorem retention_gap_le_band_mass [DecidableEq ι] {a s : ι → ℝ} {B : ℕ}
    {S T : Finset ι} {ε μ : ℝ} (hS : IsTopSet s B S) (hT : T.card = B)
    (hnn : ∀ i, 0 ≤ a i) (hε : ∀ i, |a i - s i| ≤ ε) (hμ : ∀ j ∉ T, a j ≤ μ) :
    retained a T - retained a S ≤ ∑ i ∈ T.filter (fun i => a i ≤ μ + 2 * ε), a i := by
  have hsub : T \ S ⊆ T.filter (fun i => a i ≤ μ + 2 * ε) := by
    intro i hi
    have hiT : i ∈ T := (Finset.mem_sdiff.mp hi).1
    have hiS : i ∉ S := (Finset.mem_sdiff.mp hi).2
    refine Finset.mem_filter.mpr ⟨hiT, ?_⟩
    have hcard : S.card = T.card := by rw [hS.1, hT]
    have hne : (S \ T).Nonempty := by
      rw [← Finset.card_pos, Finset.card_sdiff_comm hcard, Finset.card_pos]
      exact ⟨i, hi⟩
    obtain ⟨j, hj⟩ := hne
    have hjS : j ∈ S := (Finset.mem_sdiff.mp hj).1
    have hjT : j ∉ T := (Finset.mem_sdiff.mp hj).2
    have hij : s i ≤ s j := hS.2 j hjS i hiS
    have h1 := abs_le.mp (hε i)
    have h2 := abs_le.mp (hε j)
    have h3 : a j ≤ μ := hμ j hjT
    linarith [h1.1, h1.2, h2.1, h2.2]
  have hbandmass : ∑ i ∈ T \ S, a i ≤ ∑ i ∈ T.filter (fun i => a i ≤ μ + 2 * ε), a i :=
    Finset.sum_le_sum_of_subset_of_nonneg hsub (fun i _ _ => hnn i)
  have hsplitT : ∑ i ∈ T ∩ S, a i + ∑ i ∈ T \ S, a i = retained a T :=
    Finset.sum_inter_add_sum_diff T S a
  have hsplitS : ∑ i ∈ S ∩ T, a i + ∑ i ∈ S \ T, a i = retained a S :=
    Finset.sum_inter_add_sum_diff S T a
  have hcomm : T ∩ S = S ∩ T := Finset.inter_comm T S
  rw [hcomm] at hsplitT
  have hrest : 0 ≤ ∑ i ∈ S \ T, a i := Finset.sum_nonneg fun i _ => hnn i
  linarith

omit [Fintype ι] in
open Classical in
/-- **No band, no loss.**  If every key of the rival selection stands clear of
the cut-off by more than `2ε`, an `ε`-accurate score loses nothing at all — the
localised form of `isTopSet_eq_oracle_of_margin`. -/
theorem retained_le_of_empty_band [DecidableEq ι] {a s : ι → ℝ} {B : ℕ}
    {S T : Finset ι} {ε μ : ℝ} (hS : IsTopSet s B S) (hT : T.card = B)
    (hnn : ∀ i, 0 ≤ a i) (hε : ∀ i, |a i - s i| ≤ ε) (hμ : ∀ j ∉ T, a j ≤ μ)
    (hclear : ∀ i ∈ T, μ + 2 * ε < a i) : retained a T ≤ retained a S := by
  have hband := retention_gap_le_band_mass hS hT hnn hε hμ
  have hempty : T.filter (fun i => a i ≤ μ + 2 * ε) = ∅ := by
    refine Finset.filter_eq_empty_iff.mpr fun i hi => ?_
    exact not_le.mpr (hclear i hi)
  rw [hempty] at hband
  simpa using hband

end Catalog.Novelty.ProbeRetentionLimits