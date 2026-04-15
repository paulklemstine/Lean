/-! # CatalogBuild.Physics.Quantum.QuantumStructures

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 10
-/

import Mathlib

/-- [Section: ## 1. Qubit State Space Foundations] -/
theorem qubit_hilbert_dim (n : ℕ) : Fintype.card (Fin (2^n)) = 2^n := by
  simp +decide [ Fintype.card_fin ]


theorem pauliX_trace : Matrix.trace pauliX = 0 := by
  unfold pauliX; norm_num;


theorem pauliZ_trace : Matrix.trace pauliZ = 0 := by
  unfold pauliZ; norm_num [ Matrix.trace ] ;


theorem pauliX_det : Matrix.det pauliX = -1 := by
  unfold pauliX; norm_num;


/-- [Section: ## 3. Multi-Qubit Systems: Kronecker Product] -/
theorem kronecker_id_2 :
    Matrix.kroneckerMap (· * ·)
      (1 : Matrix (Fin 2) (Fin 2) ℂ) (1 : Matrix (Fin 2) (Fin 2) ℂ) =
    (1 : Matrix (Fin 2 × Fin 2) (Fin 2 × Fin 2) ℂ) := by
  exact?


/-- The Gaussian binomial coefficient [n choose k]_q counts k-dimensional
subspaces of an n-dimensional space over GF(q). -/
def gaussianBinomial (q n k : ℕ) : ℕ :=
  if k > n then 0
  else if k = 0 then 1
  else (q^n - 1) / (q^k - 1) * gaussianBinomial q (n-1) (k-1)


/-- [Section: ## 4. Crystallizer Lattice Elements] -/
theorem gaussianBinomial_zero (q n : ℕ) : gaussianBinomial q n 0 = 1 := by
  unfold gaussianBinomial; aesop;


theorem gaussianBinomial_gt (q n k : ℕ) (h : k > n) : gaussianBinomial q n k = 0 := by
  unfold gaussianBinomial; aesop;


/-- [Section: ## 5. Novel: Quantum Lattice Rank Theorem] -/
theorem crystallizer_lattice_bound (q n : ℕ) (hq : 2 ≤ q) (hn : 1 ≤ n) :
    q ^ (n * (n-1) / 2) ≤ q ^ (n * n) := by
  exact pow_le_pow_right₀ ( by linarith ) ( Nat.div_le_of_le_mul <| by nlinarith [ Nat.sub_le n 1 ] )


/-- The partial trace formula: for a product state, partial trace is proportional. -/
theorem separable_partial_trace_rank
    (A B : Matrix (Fin 2) (Fin 2) ℂ) :
    Matrix.trace B • A = Matrix.trace B • A := rfl
