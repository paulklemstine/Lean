import Mathlib

/-! # CatalogBuild.MachineLearning.QuantumTransformer.BiologicalCrystallization

Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 13
-/


noncomputable section

/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.BiologicalCrystallization
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 13] -/
def is_one_hot {n : ℕ} (v : Fin n → ℝ) : Prop :=
  ∃ k, v k = 1 ∧ ∀ j, j ≠ k → v j = 0




/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.BiologicalCrystallization
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 13] -/
theorem one_hot_sum_one {n : ℕ} (v : Fin n → ℝ) (hv : is_one_hot v) :
    ∑ i, v i = 1 := by
  obtain ⟨k, hk1, hk0⟩ := hv
  rw [← Finset.add_sum_erase _ _ (Finset.mem_univ k)]
  simp [hk1, Finset.sum_eq_zero (fun i hi => hk0 i (Finset.ne_of_mem_erase hi))]




theorem one_hot_binary {n : ℕ} (v : Fin n → ℝ) (hv : is_one_hot v) (i : Fin n) :
    v i = 0 ∨ v i = 1 := by
  obtain ⟨k, hk1, hk0⟩ := hv
  by_cases h : i = k
  · right; rw [h]; exact hk1
  · left; exact hk0 i h




theorem one_hot_crystal_loss_zero {n : ℕ} (v : Fin n → ℝ) (hv : is_one_hot v) :
    ∑ i, v i * (1 - v i) = 0 := by
  apply Finset.sum_eq_zero
  intro i _
  rcases one_hot_binary v hv i with h | h <;> simp [h]




def is_k_sparse {n : ℕ} (k : ℕ) (v : Fin n → ℝ) : Prop :=
  (Finset.univ.filter (fun i => v i ≠ 0)).card ≤ k




theorem one_hot_is_1_sparse {n : ℕ} (v : Fin n → ℝ) (hv : is_one_hot v) :
    is_k_sparse 1 v := by
  unfold is_k_sparse
  obtain ⟨k, hk1, hk0⟩ := hv
  calc (Finset.univ.filter (fun i => v i ≠ 0)).card
      ≤ ({k} : Finset (Fin n)).card := by
        apply Finset.card_le_card
        intro i hi
        simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hi
        simp only [Finset.mem_singleton]
        by_contra h
        exact hi (hk0 i h)
    _ = 1 := Finset.card_singleton k




theorem zero_is_0_sparse {n : ℕ} : is_k_sparse 0 (fun _ : Fin n => (0 : ℝ)) := by
  unfold is_k_sparse; simp




theorem sparse_monotone {n k : ℕ} {v : Fin n → ℝ}
    (hv : is_k_sparse k v) : is_k_sparse (k + 1) v := by
  unfold is_k_sparse at *; omega




theorem low_temp_crystallization (tau : ℝ) (htau : 0 < tau) (htau_small : tau < 1) :
    1 / tau > 1 := by
  rw [gt_iff_lt, one_lt_div htau]; linarith




theorem critical_temp_exists :
    ∃ tau_c : ℝ, 0 < tau_c ∧ tau_c < 1 :=
  ⟨1 / 2, by norm_num, by norm_num⟩




theorem neural_attention_states (n : ℕ) :
    Fintype.card (Equiv.Perm (Fin n)) = n.factorial := by
  simp [Fintype.card_perm, Fintype.card_fin]




/-- The order parameter for crystallization. -/
def order_parameter {n : ℕ} (w : Fin n → ℝ) : ℝ :=
  (1 / ↑n) * ∑ i, w i * (1 - w i)




theorem order_parameter_nonneg {n : ℕ} (hn : 0 < n) (w : Fin n → ℝ)
    (hw : ∀ i, 0 ≤ w i ∧ w i ≤ 1) :
    0 ≤ order_parameter w := by
  unfold order_parameter
  apply mul_nonneg (by positivity)
  apply Finset.sum_nonneg
  intro i _
  exact mul_nonneg (hw i).1 (by linarith [(hw i).2])




end
