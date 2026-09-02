/-
# NET-74, epistemic side: what a `|ρ| ≥ 0.7` bar can mean at five domains

The audit in `Physics/NET74SpearmanAudit.lean` recomputes the three reported
Spearman coefficients and finds the reported ranking inverted.  That raises the
prior question the round never asks: with `n = 5` domains, how often does a
*random* pairing of rankings clear the pre-registered `|ρ| ≥ 0.7` bar?

This file answers it exactly, by combining an algebraic identity with a complete
enumeration of the null.

* `two_zcov_eq_twenty_sub_dRank` — for rank vectors of two permutations of five
  items, `2·S_xy = 20 - ∑ (r i - s i)²`; equivalently `ρ = 1 - D/20`, the
  classical `1 - 6D/(n(n²-1))` identity at `n = 5`.  Proved from
  `sum_rankOf = 15` and `sum_rankOf_sq = 55`, not assumed.
* `dRank_rankOf` — the rank distance of two rankings is the displacement
  statistic `dsq` of the single permutation relating them, so the null
  distribution of `ρ` over pairs of rankings *is* the distribution of `dsq` over
  `S₅`.
* `card_bar`, `card_tail34`, `card_tail38` — complete enumeration of `S₅`:
  `28` of the `120` permutations satisfy `|ρ| ≥ 0.7`, `14` satisfy `ρ ≤ -0.7`,
  `5` satisfy `ρ ≤ -0.9`.
* `bar_false_positive_rate` — hence the two-sided size of the `|ρ| ≥ 0.7` test
  at `n = 5` is exactly `7/30 ≈ 0.233`: nearly one pairing in four clears the
  bar by chance.  `bar_is_not_a_five_percent_test` states the consequence.
* `headAgr_significance_hinges_on_tiebreak` — the strongest correlation in the
  NET-74 table, head agreement versus the knee, has exact one-sided permutation
  p-value `7/60 ≈ 0.117` under one admissible tie-break of the `k* = 16` tie and
  `1/24 ≈ 0.042` under the other.  The tie in the data, not the data, decides
  whether the strongest effect in the round is significant at 5%.

So the three "horns" of NET-74 are tested at a resolution the design cannot
deliver: at `n = 5` the bar itself fires 23% of the time, and the single result
that clears it does so only under one of two equally admissible conventions.
-/
import Mathlib
import Physics.NET74SpearmanAudit

namespace Catalog.NET74Power

open Finset Catalog.NET74

/-! ## 1. Rank vectors of permutations -/

/-- The rank vector of a permutation of the five domains: ranks `1,…,5`. -/
def rankOf (σ : Equiv.Perm (Fin 5)) : Dom → ℤ := fun i => ((σ i : ℕ) : ℤ) + 1

/-- Squared rank displacement of a permutation, `∑ (σ i - i)²`. -/
def dsq (σ : Equiv.Perm (Fin 5)) : ℤ := ∑ i, (((σ i : ℕ) : ℤ) - ((i : ℕ) : ℤ)) ^ 2

/-- Squared rank distance of two rank vectors, Spearman's `D`. -/
def dRank (r s : Dom → ℤ) : ℤ := ∑ i, (r i - s i) ^ 2

lemma sum_fin_five_cast : ∑ i : Fin 5, ((i : ℕ) : ℤ) = 10 := by decide

lemma sum_fin_five_cast_sq : ∑ i : Fin 5, (((i : ℕ) : ℤ) + 1) ^ 2 = 55 := by decide

lemma sum_rankOf (σ : Equiv.Perm (Fin 5)) : ∑ i, rankOf σ i = 15 := by
  have h : ∑ i, ((σ i : ℕ) : ℤ) = ∑ i : Fin 5, ((i : ℕ) : ℤ) :=
    Equiv.sum_comp σ (fun i => ((i : ℕ) : ℤ))
  simp only [rankOf, Finset.sum_add_distrib, h, sum_fin_five_cast]
  simp

lemma sum_rankOf_sq (σ : Equiv.Perm (Fin 5)) : ∑ i, (rankOf σ i) ^ 2 = 55 := by
  have h : ∑ i, (((σ i : ℕ) : ℤ) + 1) ^ 2 = ∑ i : Fin 5, (((i : ℕ) : ℤ) + 1) ^ 2 :=
    Equiv.sum_comp σ (fun i => (((i : ℕ) : ℤ) + 1) ^ 2)
  simpa [rankOf, sum_fin_five_cast_sq] using h.trans sum_fin_five_cast_sq

/-- **Spearman's `d²` identity at `n = 5`.**  For rank vectors of two
permutations, the rank covariance and the squared rank distance determine each
other: `2 S_xy = 20 - D`, i.e. `ρ = 1 - D/20 = 1 - 6D/(n(n²-1))`.  The proof
uses only `∑ r = 15` and `∑ r² = 55`. -/
theorem two_zcov_eq_twenty_sub_dRank (σ π : Equiv.Perm (Fin 5)) :
    2 * zcov (rankOf σ) (rankOf π) = 20 - dRank (rankOf σ) (rankOf π) := by
  have ha := sum_rankOf σ
  have hb := sum_rankOf π
  have ha2 := sum_rankOf_sq σ
  have hb2 := sum_rankOf_sq π
  simp only [zcov, dRank, Fin.sum_univ_five] at *
  linarith [ha, hb, ha2, hb2]

/-- The rank distance between two rankings only depends on the permutation
relating them.  This is what makes the permutation null exact: uniform pairs of
rankings give a uniform relating permutation. -/
theorem dRank_rankOf (σ π : Equiv.Perm (Fin 5)) :
    dRank (rankOf σ) (rankOf π) = dsq (π * σ⁻¹) := by
  have h : ∑ i, ((((π * σ⁻¹) (σ i) : ℕ) : ℤ) - ((σ i : ℕ) : ℤ)) ^ 2
      = ∑ i, ((((π * σ⁻¹) i : ℕ) : ℤ) - ((i : ℕ) : ℤ)) ^ 2 :=
    Equiv.sum_comp σ (fun i => ((((π * σ⁻¹) i : ℕ) : ℤ) - ((i : ℕ) : ℤ)) ^ 2)
  simp only [dRank, dsq, rankOf]
  rw [← h]
  refine Finset.sum_congr rfl (fun i _ => ?_)
  simp [Equiv.Perm.mul_apply]
  ring

/-! ## 2. The exact null distribution of `ρ` at `n = 5` -/

/-- Spearman's `ρ` attached to a permutation of five items. -/
def spearmanOfPerm (σ : Equiv.Perm (Fin 5)) : ℚ := 1 - (dsq σ : ℚ) / 20

/-- Clearing the `0.7` bar is exactly a condition on the displacement `D`. -/
lemma abs_spearman_ge_iff (σ : Equiv.Perm (Fin 5)) :
    7/10 ≤ |spearmanOfPerm σ| ↔ (dsq σ ≤ 6 ∨ 34 ≤ dsq σ) := by
  rw [le_abs]
  constructor
  · rintro (h | h)
    · left
      have : (dsq σ : ℚ) ≤ 6 := by
        rw [spearmanOfPerm] at h; linarith
      exact_mod_cast this
    · right
      have : (34 : ℚ) ≤ (dsq σ : ℚ) := by
        rw [spearmanOfPerm] at h; linarith
      exact_mod_cast this
  · rintro (h | h)
    · left
      have : (dsq σ : ℚ) ≤ 6 := by exact_mod_cast h
      rw [spearmanOfPerm]; linarith
    · right
      have : (34 : ℚ) ≤ (dsq σ : ℚ) := by exact_mod_cast h
      rw [spearmanOfPerm]; linarith

set_option maxRecDepth 40000 in
/-- Complete enumeration: `28` of the `120` permutations of five items clear
`|ρ| ≥ 0.7`. -/
theorem card_bar :
    (univ.filter (fun σ : Equiv.Perm (Fin 5) => dsq σ ≤ 6 ∨ 34 ≤ dsq σ)).card = 28 := by
  decide

set_option maxRecDepth 40000 in
/-- `14` of the `120` reach `ρ ≤ -0.7`. -/
theorem card_tail34 :
    (univ.filter (fun σ : Equiv.Perm (Fin 5) => 34 ≤ dsq σ)).card = 14 := by
  decide

set_option maxRecDepth 40000 in
/-- Only `5` of the `120` reach `ρ ≤ -0.9`. -/
theorem card_tail38 :
    (univ.filter (fun σ : Equiv.Perm (Fin 5) => 38 ≤ dsq σ)).card = 5 := by
  decide

lemma card_perm_five : Fintype.card (Equiv.Perm (Fin 5)) = 120 := by
  simp [Fintype.card_perm, Nat.factorial]

/-- **The pre-registered bar has size `7/30` at five domains.**  Under the
permutation null, the probability that `|ρ| ≥ 0.7` is exactly `7/30 ≈ 0.233`. -/
theorem bar_false_positive_rate :
    ((univ.filter (fun σ : Equiv.Perm (Fin 5) => 7/10 ≤ |spearmanOfPerm σ|)).card : ℚ)
      / (Fintype.card (Equiv.Perm (Fin 5)) : ℚ) = 7/30 := by
  have hfilter :
      (univ.filter (fun σ : Equiv.Perm (Fin 5) => 7/10 ≤ |spearmanOfPerm σ|))
        = univ.filter (fun σ : Equiv.Perm (Fin 5) => dsq σ ≤ 6 ∨ 34 ≤ dsq σ) := by
    refine Finset.filter_congr (fun σ _ => ?_)
    simp [abs_spearman_ge_iff σ]
  rw [hfilter, card_bar, card_perm_five]
  norm_num

/-- Consequently the bar is not a 5%-level test at `n = 5`: its exact size
exceeds `1/5`. -/
theorem bar_is_not_a_five_percent_test :
    (1:ℚ)/20 < ((univ.filter
        (fun σ : Equiv.Perm (Fin 5) => 7/10 ≤ |spearmanOfPerm σ|)).card : ℚ)
      / (Fintype.card (Equiv.Perm (Fin 5)) : ℚ) := by
  rw [bar_false_positive_rate]; norm_num

/-! ## 3. The tie decides the verdict -/

/-- One-sided permutation p-value of an observed displacement `D`. -/
noncomputable def pval (D : ℤ) : ℚ :=
  ((univ.filter (fun σ : Equiv.Perm (Fin 5) => D ≤ dsq σ)).card : ℚ) / 120

local macro "data_eval" : tactic =>
  `(tactic| (simp only [kstar, headAgr, Matrix.cons_val_zero, Matrix.cons_val_one,
      Matrix.head_cons, Matrix.cons_val_two, Matrix.cons_val_three, Matrix.cons_val_four,
      Matrix.tail_cons]; norm_num))

/-- Head-agreement ranks: prose-fr lowest, math highest.  No ties, so this
ranking is forced. -/
lemma isRank_headAgr : IsOrdinalRank headAgr ![4, 3, 5, 2, 1] := by
  refine ⟨by decide, by decide, ?_⟩
  intro i j hij
  fin_cases i <;> fin_cases j <;> first
    | decide
    | (exfalso; revert hij; data_eval)

/-- The knee ranks with the `prose-en / math` tie broken in favour of
prose-en. -/
lemma isRank_kstar_A : IsOrdinalRank kstar ![1, 2, 3, 4, 5] := by
  refine ⟨by decide, by decide, ?_⟩
  intro i j hij
  fin_cases i <;> fin_cases j <;> first
    | decide
    | (exfalso; revert hij; data_eval)

/-- The knee ranks with the same tie broken in favour of math. -/
lemma isRank_kstar_B : IsOrdinalRank kstar ![1, 3, 2, 4, 5] := by
  refine ⟨by decide, by decide, ?_⟩
  intro i j hij
  fin_cases i <;> fin_cases j <;> first
    | decide
    | (exfalso; revert hij; data_eval)

lemma dRank_A : dRank ![4, 3, 5, 2, 1] ![1, 2, 3, 4, 5] = 34 := by decide

lemma dRank_B : dRank ![4, 3, 5, 2, 1] ![1, 3, 2, 4, 5] = 38 := by decide

/-- **The significance of the strongest effect in the round is decided by the
tie, not by the data.**  Both rankings of the `k* = 16` tie are admissible.  One
gives the head-agreement/knee comparison an exact one-sided p-value of
`7/60 ≈ 0.117`, which fails at 5%; the other gives `1/24 ≈ 0.042`, which
passes. -/
theorem headAgr_significance_hinges_on_tiebreak :
    ∃ r sA sB : Dom → ℤ,
      IsOrdinalRank headAgr r ∧ IsOrdinalRank kstar sA ∧ IsOrdinalRank kstar sB ∧
      pval (dRank r sA) = 7/60 ∧ pval (dRank r sB) = 1/24 ∧
      (1:ℚ)/20 < pval (dRank r sA) ∧ pval (dRank r sB) < 1/20 := by
  refine ⟨![4, 3, 5, 2, 1], ![1, 2, 3, 4, 5], ![1, 3, 2, 4, 5],
    isRank_headAgr, isRank_kstar_A, isRank_kstar_B, ?_, ?_, ?_, ?_⟩
  · rw [dRank_A, pval, card_tail34]; norm_num
  · rw [dRank_B, pval, card_tail38]; norm_num
  · rw [dRank_A, pval, card_tail34]; norm_num
  · rw [dRank_B, pval, card_tail38]; norm_num

/-- **Power summary.**  At five domains the `|ρ| ≥ 0.7` bar fires on `7/30` of
all rankings, and the one column of the NET-74 table that clears it is
significant at 5% under one tie-break and not under the other.  Three horns
cannot be separated at this resolution. -/
theorem net74_power_verdict :
    ((univ.filter (fun σ : Equiv.Perm (Fin 5) => 7/10 ≤ |spearmanOfPerm σ|)).card : ℚ)
        / (Fintype.card (Equiv.Perm (Fin 5)) : ℚ) = 7/30 ∧
    (∃ r sA sB : Dom → ℤ,
      IsOrdinalRank headAgr r ∧ IsOrdinalRank kstar sA ∧ IsOrdinalRank kstar sB ∧
      (1:ℚ)/20 < pval (dRank r sA) ∧ pval (dRank r sB) < 1/20) := by
  obtain ⟨r, sA, sB, h1, h2, h3, _, _, h6, h7⟩ := headAgr_significance_hinges_on_tiebreak
  exact ⟨bar_false_positive_rate, ⟨r, sA, sB, h1, h2, h3, h6, h7⟩⟩

end Catalog.NET74Power