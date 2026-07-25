import Mathlib

/-! # CatalogBuild.MachineLearning.QuantumTransformer.QualityBounds

Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 9
-/


noncomputable section

/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.QualityBounds
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 9] -/
theorem tv_nonneg {n : ℕ} (p q : Fin n → ℝ) : 0 ≤ total_variation p q := by
  unfold total_variation
  apply mul_nonneg (by norm_num)
  exact Finset.sum_nonneg (fun i _ => abs_nonneg _)




/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.QualityBounds
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 9] -/
theorem tv_symm {n : ℕ} (p q : Fin n → ℝ) :
    total_variation p q = total_variation q p := by
  unfold total_variation
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  rw [abs_sub_comm]




theorem total_variation_triangle {n : ℕ} (p q r : Fin n → ℝ) :
    total_variation p r ≤ total_variation p q + total_variation q r := by
  unfold total_variation; norm_num; ring_nf;
  rw [ ← add_mul, ← Finset.sum_add_distrib ] ; exact mul_le_mul_of_nonneg_right ( Finset.sum_le_sum fun i _ => by cases abs_cases ( p i - r i ) <;> cases abs_cases ( p i - q i ) <;> cases abs_cases ( q i - r i ) <;> linarith ) ( by norm_num ) ;




theorem tv_le_one {n : ℕ} (p q : Fin n → ℝ)
    (hp : ∀ i, 0 ≤ p i) (hq : ∀ i, 0 ≤ q i)
    (hp_sum : ∑ i, p i = 1) (hq_sum : ∑ i, q i = 1) :
    total_variation p q ≤ 1 := by
  unfold total_variation;
  linarith [ show ∑ i : Fin n, |p i - q i| ≤ 2 by exact le_trans ( Finset.sum_le_sum fun _ _ => show |p _ - q _| ≤ p _ + q _ by cases abs_cases ( p ‹_› - q ‹_› ) <;> linarith [ hp ‹_›, hq ‹_› ] ) ( by norm_num [ Finset.sum_add_distrib, hp_sum, hq_sum ] ) ]




theorem crystal_loss_bounds_tv_sq (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    min p (1 - p) ^ 2 ≤ p * (1 - p) := by
  cases min_cases p ( 1 - p ) <;> nlinarith




theorem pinsker_via_crystal_loss (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    min p (1 - p) ≤ Real.sqrt (p * (1 - p)) := by
  exact Real.le_sqrt_of_sq_le ( by cases min_cases p ( 1 - p ) <;> nlinarith )




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
