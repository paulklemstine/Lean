/-
# GL3 Tropical Satake Certified Robustness for Borda-Count Hecke Score Aggregation

This module develops a formal robustness theory for multiclass classifiers whose
final prediction is obtained by Borda aggregation of pairwise score comparisons.

We work over a finite label type `α` with `[Fintype α] [DecidableEq α]`, proving:

1. **Pairwise margin perturbation bounds**: Each pairwise margin `S_i - S_j` changes
   by at most `2η` when individual scores change by at most `η`.

2. **Weighted Borda perturbation bounds**: The weighted Borda surrogate
   `Ω_i(S) = Σ_{j≠i} (S_i - S_j)` satisfies a Lipschitz bound with constant `2(n-1)`.

3. **Weighted Borda winner certification**: If the margin between the winner's weighted
   Borda score and every other candidate exceeds `4(n-1)η`, the winner is preserved.

4. **Pairwise sign stability**: Sufficiently large pairwise margins cannot flip sign.

5. **Thresholded Borda invariance**: Under uniform pairwise separation `2η < |S_i - S_j|`,
   the discrete Borda score `B_i = Σ_{j≠i} 1[S_i > S_j]` is preserved exactly.

6. **Borda winner certification**: Combining the above yields a certified robustness
   theorem for the Borda winner.

7. **Structural lemmas**: The weighted Borda score satisfies `Ω_i = n·S_i - Σ_k S_k`
   and `Ω_i - Ω_j = n·(S_i - S_j)`.
-/
import Mathlib

open Finset

noncomputable section

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## Core definitions -/

/-- The pairwise margin between classes `i` and `j` under score vector `S`. -/
def pairMargin (S : α → ℝ) (i j : α) : ℝ :=
  S i - S j

/-- The weighted Borda score (Copeland-margin surrogate) for class `i`:
    `Ω_i(S) = Σ_{j ≠ i} (S_i - S_j)`. -/
def weightedBorda (S : α → ℝ) (i : α) : ℝ :=
  ∑ j ∈ (univ.erase i), pairMargin S i j

/-- The thresholded Borda score for class `i`:
    `B_i(S) = Σ_{j ≠ i} 1[S_i > S_j]`. -/
def bordaScore (S : α → ℝ) (i : α) : ℕ :=
  ∑ j ∈ (univ.erase i), if 0 < pairMargin S i j then 1 else 0

/-- Class `w` is a (non-strict) weighted Borda winner. -/
def isWinnerWeighted (S : α → ℝ) (w : α) : Prop :=
  ∀ j, weightedBorda S j ≤ weightedBorda S w

/-- Class `w` is a strict weighted Borda winner. -/
def strictWinnerWeighted (S : α → ℝ) (w : α) : Prop :=
  ∀ j, j ≠ w → weightedBorda S j < weightedBorda S w

/-- Class `w` is a (non-strict) Borda winner. -/
def isWinnerBorda (S : α → ℝ) (w : α) : Prop :=
  ∀ j, bordaScore S j ≤ bordaScore S w

/-- Class `w` is a strict Borda winner. -/
def strictWinnerBorda (S : α → ℝ) (w : α) : Prop :=
  ∀ j, j ≠ w → bordaScore S j < bordaScore S w

/-! ## Primary Theorem 1: Pairwise margin perturbation bound -/

/-
Each pairwise margin changes by at most `2η` when individual scores change by at most `η`.
    This is the fundamental perturbation lemma from which all other bounds follow.
-/
theorem pairMargin_diff_le
    (S T : α → ℝ) (i j : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η) :
    |pairMargin T i j - pairMargin S i j| ≤ 2 * η := by
  unfold pairMargin; exact abs_sub_le_iff.2 ⟨ by linarith [ abs_le.mp ( hST i ), abs_le.mp ( hST j ) ], by linarith [ abs_le.mp ( hST i ), abs_le.mp ( hST j ) ] ⟩ ;

/-! ## Primary Theorem 1b: Weighted Borda perturbation bound -/

/-
The weighted Borda score changes by at most `2(n-1)η` when individual scores
    change by at most `η`. This is obtained by summing the pairwise margin bound.
-/
theorem weightedBorda_diff_le
    (S T : α → ℝ) (i : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η) :
    |weightedBorda T i - weightedBorda S i|
      ≤ 2 * ((Fintype.card α - 1 : ℕ) : ℝ) * η := by
  convert Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun j ( hj : j ∈ Finset.univ.erase i ) => pairMargin_diff_le S T i j η hST using 1 ; simp +decide [ mul_assoc, mul_left_comm ];
  · unfold weightedBorda; aesop;
  · simp +decide [ mul_assoc, mul_comm, mul_left_comm, Finset.mul_sum _ _ _ ]

/-! ## Primary Theorem 2: Weighted Borda winner certification -/

/-
If the weighted Borda margin exceeds `4(n-1)η`, the strict winner is preserved
    under any perturbation bounded by `η`. The factor 4 accounts for both the winner's
    score decreasing and the challenger's score increasing.
-/
theorem weightedBorda_certified_winner
    (S T : α → ℝ) (w : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hmargin : ∀ j, j ≠ w →
      (4 : ℝ) * ((Fintype.card α - 1 : ℕ) : ℝ) * η
      < weightedBorda S w - weightedBorda S j) :
    strictWinnerWeighted T w := by
  intro j hj
  have h_diff : |weightedBorda T w - weightedBorda S w| ≤ 2 * ((Fintype.card α - 1 : ℕ) : ℝ) * η ∧ |weightedBorda T j - weightedBorda S j| ≤ 2 * ((Fintype.card α - 1 : ℕ) : ℝ) * η := by
    exact ⟨ weightedBorda_diff_le S T w η hST, weightedBorda_diff_le S T j η hST ⟩;
  linarith [ abs_le.mp h_diff.1, abs_le.mp h_diff.2, hmargin j hj ]

/-! ## Primary Theorem 3: Pairwise sign stability -/

/-
If the pairwise margin `S_i - S_j` exceeds `2η`, then it remains positive
    under any perturbation bounded by `η`.
-/
omit [Fintype α] [DecidableEq α] in
theorem pairMargin_sign_stable
    (S T : α → ℝ) (i j : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hmargin : 2 * η < pairMargin S i j) :
    0 < pairMargin T i j := by
  unfold pairMargin at *; linarith [ abs_le.mp ( hST i ), abs_le.mp ( hST j ) ] ;

/-
Dual: if the pairwise margin is sufficiently negative, it remains negative.
-/
omit [Fintype α] [DecidableEq α] in
theorem pairMargin_sign_stable_neg
    (S T : α → ℝ) (i j : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hmargin : pairMargin S i j < -2 * η) :
    pairMargin T i j < 0 := by
  unfold pairMargin at *;
  linarith [ abs_le.mp ( hST i ), abs_le.mp ( hST j ) ]

/-
The sign of a pairwise margin is preserved when `2η < |margin|`.
-/
theorem pairMargin_no_flip
    (S T : α → ℝ) (i j : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hmargin : 2 * η < |pairMargin S i j|) :
    (0 < pairMargin S i j ↔ 0 < pairMargin T i j) := by
  cases abs_cases ( pairMargin S i j ) <;> constructor <;> intro h <;> cases' abs_cases ( pairMargin T i j - pairMargin S i j ) with h h <;> linarith [ hST i, hST j, pairMargin_diff_le S T i j η hST ]

/-! ## Primary Theorem 4: Thresholded Borda score invariance -/

/-
If every pairwise contest involving `i` has margin exceeding `2η`, then
    none of the indicator terms in `bordaScore` changes under perturbation.
-/
theorem bordaScore_eq_of_pairwise_margin
    (S T : α → ℝ) (i : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hsep : ∀ j, j ≠ i → 2 * η < |pairMargin S i j|) :
    bordaScore T i = bordaScore S i := by
  refine' Finset.sum_congr rfl fun j hj => _;
  grind +locals

/-
Global version: if all pairwise margins exceed `2η`, all Borda scores are preserved.
-/
theorem bordaScore_eq_of_all_pairwise_margin
    (S T : α → ℝ) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hsep : ∀ i j, i ≠ j → 2 * η < |pairMargin S i j|) :
    ∀ i, bordaScore T i = bordaScore S i := by
  exact fun i => bordaScore_eq_of_pairwise_margin S T i η hST fun j hj => hsep i j ( Ne.symm hj )

/-! ## Primary Theorem 5: Borda winner certification -/

/-
**Main Borda Robustness Theorem**: If `w` is a strict Borda winner under score vector `S`,
    and all pairwise margins exceed `2η`, then `w` remains a strict Borda winner under any
    perturbation bounded by `η`. This is the discrete analogue of the weighted Borda
    certification theorem.
-/
theorem borda_certified_winner
    (S T : α → ℝ) (w : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η)
    (hwin : strictWinnerBorda S w)
    (hsep : ∀ i j, i ≠ j → 2 * η < |pairMargin S i j|) :
    strictWinnerBorda T w := by
  exact fun j hj => by have := bordaScore_eq_of_all_pairwise_margin S T η hST hsep; aesop;

/-! ## Structural lemmas -/

/-
The weighted Borda score satisfies `Ω_i = n·S_i - Σ_k S_k`.
    This shows weighted Borda is an affine transform of the original class score.
-/
theorem weightedBorda_eq_card_mul_sub_sum
    (S : α → ℝ) (i : α) :
    weightedBorda S i
      = ((Fintype.card α : ℕ) : ℝ) * S i - ∑ j, S j := by
  have h_sum : ∑ j ∈ Finset.univ.erase i, (S i - S j) = (Fintype.card α - 1 : ℝ) * S i - (∑ j, S j - S i) := by
    simp +decide [ Finset.sum_sub_distrib ];
    exact Or.inl ( Nat.cast_pred ( Fintype.card_pos_iff.mpr ⟨ i ⟩ ) );
  convert h_sum using 1 ; ring!

/-
The difference of weighted Borda scores satisfies `Ω_i - Ω_j = n·(S_i - S_j)`.
    This shows the weighted Borda winner agrees with the argmax of `S`.
-/
theorem weightedBorda_sub_weightedBorda
    (S : α → ℝ) (i j : α) :
    weightedBorda S i - weightedBorda S j
      = ((Fintype.card α : ℕ) : ℝ) * (S i - S j) := by
  rw [ weightedBorda_eq_card_mul_sub_sum, weightedBorda_eq_card_mul_sub_sum, mul_sub ];
  ring

/-
Specialization to `|α| = 3`: the weighted Borda perturbation constant is 4.
-/
theorem weightedBorda_diff_le_card3
    (hcard : Fintype.card α = 3)
    (S T : α → ℝ) (i : α) (η : ℝ)
    (hST : ∀ c, |T c - S c| ≤ η) :
    |weightedBorda T i - weightedBorda S i| ≤ 4 * η := by
  convert weightedBorda_diff_le S T i η hST using 1 ; norm_num [ hcard ]

/-! ## GL3 Specialization -/

/-
GL3 certified radius form: if the GL3 tropical Satake score perturbation satisfies
    `|S_c(x+δ) - S_c(x)| ≤ K·ε`, then the weighted Borda winner is preserved when
    the margin exceeds `4(n-1)·K·ε`.
-/
theorem gl3_weightedBorda_certified_radius
    (S T : α → ℝ) (w : α) (K ε : ℝ)
    (hscore : ∀ c, |T c - S c| ≤ K * ε)
    (hmargin : ∀ j, j ≠ w →
      (4 : ℝ) * ((Fintype.card α - 1 : ℕ) : ℝ) * K * ε
        < weightedBorda S w - weightedBorda S j) :
    strictWinnerWeighted T w := by
  convert weightedBorda_certified_winner S T w ( K * ε ) hscore _ using 1;
  simpa only [ mul_assoc ] using hmargin

/-
GL3 certified radius form for thresholded Borda: the Borda winner is preserved
    when all pairwise margins exceed `2·K·ε`.
-/
theorem gl3_borda_certified_radius
    (S T : α → ℝ) (w : α) (K ε : ℝ)
    (hscore : ∀ c, |T c - S c| ≤ K * ε)
    (hwin : strictWinnerBorda S w)
    (hsep : ∀ i j, i ≠ j → 2 * K * ε < |pairMargin S i j|) :
    strictWinnerBorda T w := by
  apply borda_certified_winner S T w (K * ε) hscore hwin (by intro i j hij; have := hsep i j hij; ring_nf at *; linarith)

end