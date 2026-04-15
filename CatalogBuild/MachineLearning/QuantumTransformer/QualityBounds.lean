/-! # CatalogBuild.MachineLearning.QuantumTransformer.QualityBounds

Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 9
-/

import Mathlib

noncomputable section

theorem tv_nonneg {n : ℕ} (p q : Fin n → ℝ) : 0 ≤ total_variation p q := by
  unfold total_variation
  apply mul_nonneg (by norm_num)
  exact Finset.sum_nonneg (fun i _ => abs_nonneg _)


theorem tv_symm {n : ℕ} (p q : Fin n → ℝ) :
    total_variation p q = total_variation q p := by
  unfold total_variation
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  rw [abs_sub_comm]

/-
PROVIDED SOLUTION
Unfold total_variation. Factor out 1/2. Then use sum_le_sum with |p i - r i| = |(p i - q i) + (q i - r i)| ≤ |p i - q i| + |q i - r i| (triangle inequality for absolute value, abs_add). Then use sum_add_distrib.
-/

theorem total_variation_triangle {n : ℕ} (p q r : Fin n → ℝ) :
    total_variation p r ≤ total_variation p q + total_variation q r := by
  unfold total_variation; norm_num; ring_nf;
  rw [ ← add_mul, ← Finset.sum_add_distrib ] ; exact mul_le_mul_of_nonneg_right ( Finset.sum_le_sum fun i _ => by cases abs_cases ( p i - r i ) <;> cases abs_cases ( p i - q i ) <;> cases abs_cases ( q i - r i ) <;> linarith ) ( by norm_num ) ;

/-
PROVIDED SOLUTION
Unfold total_variation. Show (1/2) * Σ |p i - q i| ≤ 1. Since |p i - q i| ≤ p i + q i (because both are nonneg), Σ |p i - q i| ≤ Σ (p i + q i) = Σ p i + Σ q i = 1 + 1 = 2. So (1/2) * 2 = 1.
-/

theorem tv_le_one {n : ℕ} (p q : Fin n → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    (hp_sum : ∑ i, p i = 1) (hq_sum : ∑ i, q i = 1) :
    total_variation p q ≤ 1 := by
  unfold total_variation;
  linarith [ show ∑ i : Fin n, |p i - q i| ≤ 2 by exact le_trans ( Finset.sum_le_sum fun _ _ => show |p _ - q _| ≤ p _ + q _ by cases abs_cases ( p ‹_› - q ‹_› ) <;> linarith [ hp ‹_›, hq ‹_› ] ) ( by norm_num [ Finset.sum_add_distrib, hp_sum, hq_sum ] ) ]

/-! ## §2: Pinsker-type Bounds -/

/-
PROBLEM
The crystallization loss p(1-p) upper bounds min(p, 1-p)².

PROVIDED SOLUTION
Case split on p ≤ 1-p vs p > 1-p. If p ≤ 1-p: min p (1-p) = p, need p^2 ≤ p(1-p) = p - p^2, i.e. 2p^2 ≤ p, i.e. p(2p-1) ≤ 0, which holds since p ≤ 1/2. If p > 1-p: min p (1-p) = 1-p, need (1-p)^2 ≤ p(1-p), i.e. 1-p ≤ p, i.e. p ≥ 1/2, which holds.
-/

theorem crystal_loss_bounds_tv_sq (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    min p (1 - p) ^ 2 ≤ p * (1 - p) := by
  cases min_cases p ( 1 - p ) <;> nlinarith

/-
PROBLEM
TV distance to crystallization is at most √(crystal_loss).

PROVIDED SOLUTION
Use that min p (1-p) ^ 2 ≤ p*(1-p) from crystal_loss_bounds_tv_sq. Since min p (1-p) ≥ 0, take sqrt of both sides: min p (1-p) ≤ sqrt(p*(1-p)). Use Real.sqrt_le_sqrt and Real.sqrt_sq.
-/

theorem pinsker_via_crystal_loss (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    min p (1 - p) ≤ Real.sqrt (p * (1 - p)) := by
  exact Real.le_sqrt_of_sq_le ( by cases min_cases p ( 1 - p ) <;> nlinarith )

/-! ## §3: Row Crystallization Bounds -/


theorem row_crystallization_error {n : ℕ} (w : Fin n → ℝ)
    (hw_nn : ∀ i, 0 ≤ w i) (hw_sum : ∑ i, w i = 1) :
    ∑ i, w i * (1 - w i) ≤ 1 := by
  have : ∑ i, w i * (1 - w i) = 1 - ∑ i, w i ^ 2 := by
    simp only [mul_sub, mul_one, sq]
    rw [Finset.sum_sub_distrib, hw_sum]
  rw [this]
  linarith [Finset.sum_nonneg (fun i (_ : i ∈ Finset.univ) => sq_nonneg (w i))]


theorem total_crystal_loss_identity {n : ℕ}
    (w : Fin n → ℝ) (hw_sum : ∑ i, w i = 1) :
    ∑ i, w i * (1 - w i) = 1 - ∑ i, w i ^ 2 := by
  simp only [mul_sub, mul_one, sq]
  rw [Finset.sum_sub_distrib, hw_sum]


theorem small_loss_implies_large_sq {n : ℕ} (w : Fin n → ℝ)
    (hw_nn : ∀ i, 0 ≤ w i) (hw_sum : ∑ i, w i = 1)
    (i : Fin n) (hi : 1 / 2 ≤ w i) :
    1 / 4 ≤ w i ^ 2 := by
  nlinarith


end
