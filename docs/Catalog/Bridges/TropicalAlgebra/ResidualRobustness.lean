/-
# Certified Robustness for Multiclass Residual Score Maps

This file formalizes certified robustness theorems for multiclass residual
piecewise-linear score maps of the form `f(x) = h(x) + Σᵢ sᵢ(x)`, where
`h` is a base tropical/Hecke score map and each skip branch `sᵢ` has a
certified L∞ Lipschitz bound.

The main results convert pairwise tropical Satake separation margins for
the base classifier into robustness certificates for the full residual
architecture.
-/
import Mathlib

open scoped BigOperators
open Finset

/-! ## Core type abbreviations -/

/-- Input vector in ℝ^d -/
abbrev Input (d : ℕ) := Fin d → ℝ

/-- Score vector: maps inputs to per-class scores -/
abbrev ScoreVec (C d : ℕ) := Input d → Fin C → ℝ

/-! ## Definitions -/

/-- Residual score map: base `h` plus sum of skip branches `s` -/
def totalScore {C d n : ℕ}
    (h : ScoreVec C d) (s : Fin n → ScoreVec C d) : ScoreVec C d :=
  fun x c => h x c + ∑ i : Fin n, s i x c

/-- Pairwise gap between class `a` and class `b` scores -/
def pairGap {C d : ℕ} (f : ScoreVec C d) (a b : Fin C) (x : Input d) : ℝ :=
  f x a - f x b

/-- Class `y` is the strict top class: all other classes score strictly lower -/
def StrictTopClass {C d : ℕ} (f : ScoreVec C d) (y : Fin C) (x : Input d) : Prop :=
  ∀ b : Fin C, b ≠ y → f x b < f x y

/-! ## Helper lemmas -/

/-
The pairwise gap is additive over addition of score vectors
-/
lemma pairGap_add
    {C d : ℕ} (f g : ScoreVec C d) (a b : Fin C) (x : Input d) :
    pairGap (fun x c => f x c + g x c) a b x
      = pairGap f a b x + pairGap g a b x := by
  unfold pairGap; ring;

/-
The pairwise gap distributes over finite sums of score vectors
-/
lemma pairGap_sum
    {C d n : ℕ} (s : Fin n → ScoreVec C d) (a b : Fin C) (x : Input d) :
    pairGap (fun x c => ∑ i : Fin n, s i x c) a b x
      = ∑ i : Fin n, pairGap (s i) a b x := by
  unfold pairGap; simp +decide [ Finset.sum_sub_distrib ] ;

/-
The pairwise gap of the total residual score decomposes into
    the base gap plus the sum of branch gaps
-/
lemma pairGap_totalScore
    {C d n : ℕ}
    (h : ScoreVec C d) (s : Fin n → ScoreVec C d)
    (a b : Fin C) (x : Input d) :
    pairGap (totalScore h s) a b x
      = pairGap h a b x + ∑ i : Fin n, pairGap (s i) a b x := by
  unfold totalScore pairGap;
  rw [ Finset.sum_sub_distrib, add_sub_add_comm ]

/-
If each class score changes by at most `L`, the pairwise gap
    changes by at most `2 * L` (triangle inequality on differences)
-/
lemma abs_pairGap_le_of_logitwise
    {C d : ℕ} (f : ScoreVec C d) (L : ℝ) (x z : Input d) (a b : Fin C)
    (hf : ∀ c : Fin C, |f z c - f x c| ≤ L) :
    |pairGap f a b z - pairGap f a b x| ≤ 2 * L := by
  unfold pairGap; exact abs_le.mpr ⟨ by linarith [ abs_le.mp ( hf a ), abs_le.mp ( hf b ) ], by linarith [ abs_le.mp ( hf a ), abs_le.mp ( hf b ) ] ⟩ ;

/-! ## Main robustness theorems -/

/-
**Residual Pairwise Robustness from Gap Budget.**
    If the total pairwise margin at center `x` exceeds the branchwise
    perturbation budget `(K₀(y,b) + Σᵢ Kᵢ(y,b)) * r`, then class `y`
    remains strictly above every competitor `b` throughout the L∞ ball.
-/
theorem residual_pairwise_robust_of_gap_budget
    {C d n : ℕ}
    (h : ScoreVec C d)
    (s : Fin n → ScoreVec C d)
    (K0 : Fin C → Fin C → ℝ)
    (K : Fin n → Fin C → Fin C → ℝ)
    (x z : Input d)
    (y : Fin C)
    (r : ℝ)
    (_hr : 0 ≤ r)
    (hz : ∀ i : Fin d, |z i - x i| ≤ r)
    (hbase_lip :
      ∀ a b : Fin C, ∀ x' z' : Input d,
        (∀ i : Fin d, |z' i - x' i| ≤ r) →
        |pairGap h a b z' - pairGap h a b x'| ≤ K0 a b * r)
    (hskip_lip :
      ∀ i : Fin n, ∀ a b : Fin C, ∀ x' z' : Input d,
        (∀ j : Fin d, |z' j - x' j| ≤ r) →
        |pairGap (s i) a b z' - pairGap (s i) a b x'| ≤ K i a b * r)
    (hmargin :
      ∀ b : Fin C, b ≠ y →
        pairGap (totalScore h s) y b x >
          (K0 y b + ∑ i : Fin n, K i y b) * r) :
    ∀ b : Fin C, b ≠ y → pairGap (totalScore h s) y b z > 0 := by
  intros b hb; specialize hmargin b hb; simp_all +decide [ pairGap_totalScore ] ;
  have h_sum_bound : |pairGap h y b z - pairGap h y b x| ≤ K0 y b * r ∧ ∀ i, |pairGap (s i) y b z - pairGap (s i) y b x| ≤ K i y b * r := by
    exact ⟨ hbase_lip y b x z hz, fun i => hskip_lip i y b x z hz ⟩;
  have h_sum_bound : |∑ i, pairGap (s i) y b z - ∑ i, pairGap (s i) y b x| ≤ ∑ i, K i y b * r := by
    simpa only [ ← Finset.sum_sub_distrib ] using Finset.abs_sum_le_sum_abs _ _ |> le_trans <| Finset.sum_le_sum fun i _ => h_sum_bound.2 i;
  rw [ ← Finset.sum_mul _ _ _ ] at *; linarith [ abs_le.mp ( by tauto : |pairGap h y b z - pairGap h y b x| ≤ K0 y b * r ), abs_le.mp h_sum_bound ] ;

/-
**Residual Robustness from Base Gap and Skip Budget.**
    A variant where a certified lower bound `Δ(y,b,x)` for the base
    pairwise gap is provided (e.g. from tropical Satake certificates),
    separating the base and skip contributions.
-/
theorem residual_robust_of_base_gap_and_skip_budget
    {C d n : ℕ}
    (h : ScoreVec C d)
    (s : Fin n → ScoreVec C d)
    (Δ : Fin C → Fin C → Input d → ℝ)
    (K0 : Fin C → Fin C → ℝ)
    (K : Fin n → Fin C → Fin C → ℝ)
    (x z : Input d)
    (y : Fin C)
    (r : ℝ)
    (_hr : 0 ≤ r)
    (hz : ∀ i : Fin d, |z i - x i| ≤ r)
    (hΔ : ∀ a b : Fin C, Δ a b x ≤ pairGap h a b x)
    (hbase_lip :
      ∀ a b : Fin C, ∀ x' z' : Input d,
        (∀ i : Fin d, |z' i - x' i| ≤ r) →
        |pairGap h a b z' - pairGap h a b x'| ≤ K0 a b * r)
    (hskip_lip :
      ∀ i : Fin n, ∀ a b : Fin C, ∀ x' z' : Input d,
        (∀ j : Fin d, |z' j - x' j| ≤ r) →
        |pairGap (s i) a b z' - pairGap (s i) a b x'| ≤ K i a b * r)
    (hcenter :
      ∀ b : Fin C, b ≠ y →
        Δ y b x + ∑ i : Fin n, pairGap (s i) y b x >
          (K0 y b + ∑ i : Fin n, K i y b) * r) :
    ∀ b : Fin C, b ≠ y → pairGap (totalScore h s) y b z > 0 := by
  intros b hb; specialize hcenter b hb; simp_all +decide [ pairGap_totalScore ] ;
  -- By the Lipschitz hypothesis, we have:
  have h_lip : pairGap h y b z ≥ pairGap h y b x - K0 y b * r := by
    linarith [ abs_le.mp ( hbase_lip y b x z hz ) ]
  have h_lip_s : ∀ i, pairGap (s i) y b z ≥ pairGap (s i) y b x - K i y b * r := by
    exact fun i => by linarith [ abs_le.mp ( hskip_lip i y b x z hz ) ] ;
  have := Finset.sum_le_sum fun i ( hi : i ∈ Finset.univ ) => h_lip_s i; norm_num [ Finset.sum_add_distrib, ← Finset.sum_mul _ _ _ ] at *; linarith [ hΔ y b ] ;

/-
**Uniform-Budget Robustness.**
    When using classwise uniform Lipschitz bounds (each class score
    changes by at most `Kh * r` for the base and `Ks i * r` per branch),
    the factor 2 appears from the triangle inequality on pairwise gaps.
    The margin condition `pairGap (totalScore h s) y b x > 2r(Kh + Σᵢ Ksᵢ)`
    uses the full residual score margin at the center point.

    Note: The original form `Δ y b x > 2r(...)` using only the base gap lower bound
    is valid only when skip branch gaps at x are nonnegative. This more general
    formulation uses the actual total score gap, which correctly accounts for
    potentially negative skip branch contributions at the center.
-/
theorem residual_robust_uniform_budget
    {C d n : ℕ}
    (h : ScoreVec C d)
    (s : Fin n → ScoreVec C d)
    (Kh : ℝ)
    (Ks : Fin n → ℝ)
    (x z : Input d)
    (y : Fin C)
    (r : ℝ)
    (_hr : 0 ≤ r)
    (hz : ∀ i : Fin d, |z i - x i| ≤ r)
    (hbase_lip :
      ∀ c : Fin C, ∀ x' z' : Input d,
        (∀ i : Fin d, |z' i - x' i| ≤ r) →
        |h z' c - h x' c| ≤ Kh * r)
    (hskip_lip :
      ∀ i : Fin n, ∀ c : Fin C, ∀ x' z' : Input d,
        (∀ j : Fin d, |z' j - x' j| ≤ r) →
        |s i z' c - s i x' c| ≤ Ks i * r)
    (hmargin :
      ∀ b : Fin C, b ≠ y →
        pairGap (totalScore h s) y b x > 2 * r * (Kh + ∑ i : Fin n, Ks i)) :
    ∀ b : Fin C, b ≠ y → pairGap (totalScore h s) y b z > 0 := by
  -- By Lemma abs_pairGap_le_of_logitwise, we can bound the absolute difference of pairwise gaps.
  have h_abs_diff : ∀ a b : Fin C, |pairGap h a b z - pairGap h a b x| ≤ 2 * Kh * r := by
    exact fun a b => by simpa only [ mul_assoc ] using abs_pairGap_le_of_logitwise h ( Kh * r ) x z a b fun c => hbase_lip c x z hz;
  have h_abs_diff_s : ∀ i : Fin n, ∀ a b : Fin C, |pairGap (s i) a b z - pairGap (s i) a b x| ≤ 2 * Ks i * r := by
    intros i a b;
    convert abs_pairGap_le_of_logitwise ( s i ) ( Ks i * r ) x z a b ( fun c => hskip_lip i c x z hz ) using 1 ; ring;
  have h_sum_abs_diff_s : ∀ a b : Fin C, |∑ i : Fin n, pairGap (s i) a b z - ∑ i : Fin n, pairGap (s i) a b x| ≤ 2 * r * ∑ i : Fin n, Ks i := by
    exact fun a b => by rw [ ← Finset.sum_sub_distrib ] ; exact le_trans ( Finset.abs_sum_le_sum_abs _ _ ) ( by rw [ Finset.mul_sum _ _ _ ] ; exact Finset.sum_le_sum fun i _ => by linarith [ h_abs_diff_s i a b ] ) ;
  intro b hb; specialize hmargin b hb; specialize h_abs_diff y b; specialize h_sum_abs_diff_s y b; rw [ abs_le ] at *; linarith [ pairGap_totalScore h s y b x, pairGap_totalScore h s y b z ] ;

/-
**Strict Top Class on Ball.**
    Combines pairwise robustness with the `StrictTopClass` predicate.
-/
theorem strictTopClass_on_ball
    {C d n : ℕ}
    (h : ScoreVec C d)
    (s : Fin n → ScoreVec C d)
    (K0 : Fin C → Fin C → ℝ)
    (K : Fin n → Fin C → Fin C → ℝ)
    (x : Input d)
    (y : Fin C)
    (r : ℝ)
    (hr : 0 ≤ r)
    (hbase_lip :
      ∀ a b : Fin C, ∀ x' z' : Input d,
        (∀ i : Fin d, |z' i - x' i| ≤ r) →
        |pairGap h a b z' - pairGap h a b x'| ≤ K0 a b * r)
    (hskip_lip :
      ∀ i : Fin n, ∀ a b : Fin C, ∀ x' z' : Input d,
        (∀ j : Fin d, |z' j - x' j| ≤ r) →
        |pairGap (s i) a b z' - pairGap (s i) a b x'| ≤ K i a b * r)
    (hmargin :
      ∀ b : Fin C, b ≠ y →
        pairGap (totalScore h s) y b x >
          (K0 y b + ∑ i : Fin n, K i y b) * r) :
    ∀ z : Input d, (∀ i, |z i - x i| ≤ r) →
      StrictTopClass (totalScore h s) y z := by
  intro z hz;
  exact fun b hb => sub_pos.mp ( residual_pairwise_robust_of_gap_budget h s K0 K x z y r hr hz hbase_lip hskip_lip hmargin b hb )