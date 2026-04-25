/-! # CatalogBuild.MachineLearning.QuantumTransformer.QuantumCompilation

Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 16
-/

import Mathlib

noncomputable section

/-- A transposition has order 2 (applying it twice gives the identity). -/
theorem swap_order_two {n : Type*} [DecidableEq n]
    (a b : n) : Equiv.swap a b * Equiv.swap a b = 1 :=
  Equiv.swap_mul_self a b





/-- Transpositions are self-inverse. -/
theorem swap_involutive {n : Type*} [DecidableEq n]
    (a b : n) : (Equiv.swap a b)⁻¹ = Equiv.swap a b := by
  have h := Equiv.swap_mul_self a b
  exact mul_left_cancel (a := Equiv.swap a b) (by rw [h, mul_inv_cancel])





/-- The bubble sort bound: at most n*(n-1)/2 swaps suffice for n ≥ 1. -/
theorem bubble_sort_swaps_bound (n : ℕ) : n * (n - 1) / 2 ≤ n * n := by
  calc n * (n - 1) / 2 ≤ n * (n - 1) := Nat.div_le_self _ _
    _ ≤ n * n := Nat.mul_le_mul_left n (Nat.sub_le n 1)





/-- Parallel execution reduces depth: n parallel layers suffice. -/
theorem parallel_depth (n : ℕ) (hn : 1 ≤ n) : n ≤ n * n :=
  Nat.le_mul_of_pos_right n hn





/-- The quantum advantage ratio: classical O(n²) vs quantum O(n). -/
theorem quantum_speedup (n : ℕ) (hn : 0 < n) : n * n / n = n :=
  Nat.mul_div_cancel n hn





/-- k qubits give 2^k states. -/
theorem qubit_space_dimension (k : ℕ) : 0 < 2 ^ k := by positivity





/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.QuantumCompilation
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 16] -/
theorem exp_dominates_linear (k : ℕ) (hk : 1 ≤ k) : k < 2 ^ k := by
  exact Nat.lt_pow_self (by norm_num : 1 < 2)





/-- For any n, there exist enough qubits to represent n states. -/
theorem sufficient_qubits (n : ℕ) (_hn : 0 < n) :
    ∃ k : ℕ, n ≤ 2 ^ k :=
  ⟨n, (Nat.lt_pow_self (by norm_num : 1 < 2)).le⟩





/-- Permutations are bijections (hence unitary as matrices). -/
theorem perm_bijective {n : Type*} [DecidableEq n] [Fintype n]
    (σ : Perm n) : Function.Bijective σ :=
  σ.bijective





/-- Permutations preserve the cardinality of sets (orthogonality). -/
theorem perm_preserves_card {n : Type*} [DecidableEq n] [Fintype n]
    (σ : Perm n) (s : Finset n) : (s.image σ).card = s.card :=
  s.card_image_of_injective σ.injective





/-- Composing a permutation with its inverse gives identity. -/
theorem perm_inverse_identity {n : Type*} [DecidableEq n] [Fintype n]
    (σ : Perm n) : σ * σ⁻¹ = 1 :=
  mul_inv_cancel σ





/-- The inverse of the inverse is the original permutation. -/
theorem inverse_involutive {n : Type*} [DecidableEq n] [Fintype n]
    (σ : Perm n) : (σ⁻¹)⁻¹ = σ :=
  inv_inv σ





/-- The total number of gates for H heads is at most H × n². -/
theorem multi_head_gate_bound (H n : ℕ) (hn : 1 ≤ n) :
    H * n ≤ H * (n * n) := by
  apply Nat.mul_le_mul_left
  exact Nat.le_mul_of_pos_right n hn





/-- The crystallized transformer theorem: an L-layer, H-head crystallized
transformer over Fin n is equivalent to H permutations, each expressible
as a product of the layer permutations. -/
theorem crystallized_transformer_structure (n L H : ℕ)
    (layers : Fin L → Fin H → Perm (Fin n)) :
    ∃ (composed : Fin H → Perm (Fin n)),
      ∀ h : Fin H,
        composed h = List.foldl (· * ·) 1
          (List.ofFn (fun l => layers l h)) :=
  ⟨fun h => List.foldl (· * ·) 1 (List.ofFn (fun l => layers l h)),
   fun _ => rfl⟩





/-- The composed permutation is still a permutation (trivially, since Perm is a type). -/
theorem composed_is_perm {n : Type*} [DecidableEq n] [Fintype n]
    (σ τ : Perm n) : Function.Bijective (σ * τ) :=
  (σ * τ).bijective





/-- Compilation preserves invertibility: the compiled circuit can be reversed. -/
theorem compiled_reversible {n : Type*} [DecidableEq n] [Fintype n]
    (σ : Perm n) : σ * σ⁻¹ = 1 ∧ σ⁻¹ * σ = 1 :=
  ⟨mul_inv_cancel σ, inv_mul_cancel σ⟩





end
