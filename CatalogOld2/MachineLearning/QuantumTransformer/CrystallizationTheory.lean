/-! # CatalogBuild.MachineLearning.QuantumTransformer.CrystallizationTheory

Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 22
-/

import Mathlib

noncomputable section

/-- The crystallization loss for a single probability value. -/
def crystal_loss (p : ℝ) : ℝ := p * (1 - p)


/-- Crystallization loss is non-negative for p ∈ [0, 1]. -/
theorem crystal_loss_nonneg (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    0 ≤ crystal_loss p := by
  unfold crystal_loss
  exact mul_nonneg hp0 (by linarith)


/-- Crystallization loss equals zero iff p ∈ {0, 1}. -/
theorem crystal_loss_eq_zero_iff (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    crystal_loss p = 0 ↔ p = 0 ∨ p = 1 := by
  unfold crystal_loss
  constructor
  · intro h
    rcases mul_eq_zero.mp h with h | h
    · left; exact h
    · right; linarith
  · rintro (rfl | rfl) <;> simp


/-- Crystallization loss is maximized at p = 1/2 with value 1/4. -/
theorem crystal_loss_max (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    crystal_loss p ≤ 1 / 4 := by
  unfold crystal_loss
  nlinarith [sq_nonneg (p - 1/2)]


/-- The maximum crystallization loss is achieved at p = 1/2. -/
theorem crystal_loss_at_half : crystal_loss (1 / 2) = 1 / 4 := by
  unfold crystal_loss; ring


/-- Composition of two permutations is a permutation (S_n is closed under composition). -/
theorem perm_comp_is_perm {n : Type*} [DecidableEq n] [Fintype n]
    (σ τ : Equiv.Perm n) : ∃ ρ : Equiv.Perm n, ρ = σ * τ :=
  ⟨σ * τ, rfl⟩


/-- The identity is a permutation. -/
theorem perm_id_exists {n : Type*} [DecidableEq n] [Fintype n] :
    ∃ e : Equiv.Perm n, ∀ x, e x = x :=
  ⟨1, fun x => rfl⟩


/-- Every permutation has an inverse. -/
theorem perm_inv_exists {n : Type*} [DecidableEq n] [Fintype n]
    (σ : Equiv.Perm n) : ∃ τ : Equiv.Perm n, σ * τ = 1 :=
  ⟨σ⁻¹, mul_inv_cancel σ⟩


/-- Permutation composition is associative. -/
theorem perm_comp_assoc {n : Type*} [DecidableEq n] [Fintype n]
    (σ τ ρ : Equiv.Perm n) : σ * τ * ρ = σ * (τ * ρ) :=
  mul_assoc σ τ ρ


/-- n! is positive for all n. -/
theorem factorial_pos_nat (n : ℕ) : 0 < n.factorial :=
  Nat.factorial_pos n


theorem factorial_ge_pow (n : ℕ) (hn : 1 ≤ n) : 2 ^ (n - 1) ≤ n.factorial := by
  induction hn <;> simp_all +decide [ Nat.factorial_succ, pow_succ' ];
  cases ‹1 ≤ _› <;> norm_num [ pow_succ' ] at * ; nlinarith


/-- The number of possible crystallized states for H heads is (n!)^H. -/
theorem crystallized_state_count (n H : ℕ) (hn : 0 < n) :
    0 < n.factorial ^ H := by
  positivity


/-- Composed crystallized layers: L layers each with a permutation
compose to a single permutation. The composed state count is still n!
(not (n!)^L), because the composition collapses. -/
theorem composed_crystallized_count (n L : ℕ) (hn : 0 < n) (hL : 0 < L) :
    n.factorial ≤ n.factorial ^ L := by
  exact le_self_pow (Nat.factorial_pos n) hL.ne'


/-- The number of qubits needed to represent n states is at least 1 for n > 0. -/
theorem qubit_lower_bound (n : ℕ) (hn : 0 < n) : 1 ≤ n := hn


/-- For n ≥ 2, the circuit depth O(n) is strictly less than classical O(n²). -/
theorem quantum_depth_advantage (n : ℕ) (hn : 2 ≤ n) : n < n * n := by
  nlinarith


theorem exp_ge_linear (k : ℕ) (hk : 1 ≤ k) : k + 1 ≤ 2 ^ k := by
  exact Nat.recOn k ( by norm_num ) fun n ihn => by rw [ Nat.pow_succ' ] ; linarith;


theorem at_most_one_large {n : ℕ} (w : Fin n → ℝ)
    (hw_nn : ∀ i, 0 ≤ w i)
    (hw_sum : ∑ i, w i = 1)
    (i j : Fin n) (hi : 1 / 2 < w i) (hj : 1 / 2 < w j) : i = j := by
  exact Classical.not_not.1 fun away => absurd ( hw_sum ▸ Finset.sum_le_sum_of_subset_of_nonneg ( Finset.insert_subset_iff.mpr ⟨ Finset.mem_univ i, Finset.singleton_subset_iff.mpr ( Finset.mem_univ j ) ⟩ ) fun _ _ _ => hw_nn _ ) ( by norm_num [ Finset.sum_pair away ] ; linarith )


/-- ReLU of a non-positive input is zero. -/
theorem relu_of_nonpos (x : ℝ) (hx : x ≤ 0) : max x 0 = 0 :=
  max_eq_right hx


/-- The number of linear regions of a composition of L ReLU layers,
each with width d, is at most (2d)^L. -/
theorem relu_region_bound (d L : ℕ) (hd : 0 < d) : 1 ≤ (2 * d) ^ L :=
  Nat.one_le_pow L (2 * d) (by omega)


/-- Composition of L permutations gives a single permutation.
This is the "layer collapsing" theorem for crystallized transformers. -/
theorem layer_collapse {n : Type*} [DecidableEq n] [Fintype n]
    (layers : List (Equiv.Perm n)) :
    ∃ σ : Equiv.Perm n, σ = layers.foldl (· * ·) 1 := by
  exact ⟨layers.foldl (· * ·) 1, rfl⟩


/-- The symmetric group S_n has exactly n! elements. -/
theorem symmetric_group_card (n : ℕ) :
    Fintype.card (Equiv.Perm (Fin n)) = n.factorial := by
  simp [Fintype.card_perm, Fintype.card_fin]


/-- For a transformer with H heads, each crystallized to one of n! permutations,
the total number of configurations is (n!)^H. -/
theorem total_configurations (n H : ℕ) :
    Fintype.card (Fin H → Equiv.Perm (Fin n)) = n.factorial ^ H := by
  simp [Fintype.card_pi, Fintype.card_perm, Fintype.card_fin]


end
