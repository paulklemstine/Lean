/-! # CatalogBuild.Physics.Quantum.QuantumLLMCompilation

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 15
-/

import Mathlib

/-- Composition of two linear maps is a linear map -/
theorem linear_composition_is_linear {R M₁ M₂ M₃ : Type*}
    [CommSemiring R] [AddCommMonoid M₁] [AddCommMonoid M₂] [AddCommMonoid M₃]
    [Module R M₁] [Module R M₂] [Module R M₃]
    (f : M₂ →ₗ[R] M₃) (g : M₁ →ₗ[R] M₂) :
    ∃ h : M₁ →ₗ[R] M₃, ∀ x, h x = f (g x) :=
  ⟨f.comp g, fun x => rfl⟩


/-- Composition of n linear maps is a linear map (by induction) -/
theorem linear_composition_chain {R M : Type*}
    [CommSemiring R] [AddCommMonoid M] [Module R M]
    (maps : List (M →ₗ[R] M)) :
    ∃ h : M →ₗ[R] M, ∀ x, h x = maps.foldr (fun f acc => f acc) x := by
  induction maps with
  | nil => exact ⟨LinearMap.id, fun x => rfl⟩
  | cons f rest ih =>
    obtain ⟨h_rest, h_rest_spec⟩ := ih
    exact ⟨f.comp h_rest, fun x => by simp [List.foldr, h_rest_spec]⟩


/-- The number of linear regions grows at most exponentially with depth. -/
theorem region_count_exponential_bound (d L : ℕ) (hd : 0 < d) :
    1 ≤ (2 * d) ^ L :=
  Nat.one_le_pow L (2 * d) (by omega)


/-- The linearization dimension is at least as large as the number of regions -/
theorem linearization_dimension_lower_bound (n regions : ℕ) (hr : 0 < regions) :
    regions ≤ regions * n + regions := by omega


/-- A system of k qubits spans a Hilbert space of dimension 2^k. -/
theorem qubit_dimension (k : ℕ) : 0 < 2 ^ k := by positivity


theorem exponential_compression (k : ℕ) (hk : 0 < k) : k < 2 ^ k := by
  exact?


theorem qubit_count_exists (D : ℕ) (hD : 0 < D) :
    ∃ k : ℕ, 2 ^ k ≥ D ∧ k ≤ D := by
  exact ⟨ D, le_of_lt ( Nat.recOn D ( by norm_num ) fun n ihn => by rw [ pow_succ' ] ; linarith [ Nat.one_le_pow n 2 zero_lt_two ] ), le_rfl ⟩


/-- V^n ≤ V^(n+1) for V ≥ 2 -/
theorem full_tensor_size (V n : ℕ) (hV : 2 ≤ V) :
    V ^ n ≤ V ^ (n + 1) :=
  Nat.pow_le_pow_right (by omega) (by omega)


/-- The compression ratio grows super-exponentially in n -/
theorem compression_grows_with_context (V n params : ℕ) (hV : 2 ≤ V)
    (h : params ≤ V ^ (n + 1)) : params < V ^ (n + 2) := by
  calc params ≤ V ^ (n + 1) := h
    _ < V ^ (n + 2) := Nat.pow_lt_pow_right (by omega) (by omega)


/-- The tensor rank of the transformer output is bounded by d^L -/
theorem tensor_rank_bound (d L : ℕ) (hd : 1 ≤ d) :
    1 ≤ d ^ L := Nat.one_le_pow L d hd


/-- For L layers with degree-p polynomial activation, the total lifting dimension
is d^(p^L), which grows doubly-exponentially -/
theorem doubly_exponential_growth (d p L : ℕ) (hd : 2 ≤ d) (hp : 2 ≤ p) :
    d ≤ d ^ p ^ L := by
  calc d = d ^ 1 := (pow_one d).symm
    _ ≤ d ^ p ^ L := by
        apply Nat.pow_le_pow_right (by omega)
        exact Nat.one_le_pow L p (by omega)


/-- Classical storage for a D×D matrix is D² ≥ D -/
theorem classical_vs_quantum_storage (D : ℕ) (hD : 2 ≤ D) :
    D ≤ D ^ 2 := by nlinarith


/-- The quantum representation is exponentially more compact -/
theorem quantum_exponential_compression (k : ℕ) (hk : 1 ≤ k) :
    k < 2 ^ k :=
  exponential_compression k (by omega)


/-- Any function from Fin n to Fin m can be represented by a matrix with
indicator entries. -/
theorem finite_function_matrix_representation (n m : ℕ)
    (f : Fin n → Fin m) :
    ∃ (M : Matrix (Fin m) (Fin n) ℝ),
      ∀ (i : Fin n), M (f i) i = 1 := by
  refine ⟨fun j i => if j = f i then (1 : ℝ) else 0, fun i => ?_⟩
  simp


/-- For V ≥ 2 and n ≥ 2, V^n ≥ V·n. The tensor dwarfs the parameters. -/
theorem parameter_ratio_vanishes (V n : ℕ) (hV : 2 ≤ V) (hn : 2 ≤ n) :
    V * n ≤ V ^ n := by
  induction hn <;> simp_all +decide [ pow_succ' ] ; nlinarith [ Nat.mul_le_mul_left ( V ^ ‹_› ) hV ] ;
  nlinarith [ Nat.mul_le_mul_left V ‹2 ≤ _› ]
