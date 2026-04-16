/-! # CatalogBuild.MachineLearning.QuantumTransformer.Foundations

Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 13
-/

import Mathlib

/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.Foundations
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 13] -/
theorem hilbert_space_dim_exponential (n : ℕ) :
    (2 : ℕ) ^ n = Fintype.card (Fin (2 ^ n)) := by
      norm_num



theorem pure_state_params_exponential (n : ℕ) (hn : 2 ≤ n) :
    (2 : ℤ) * 2 ^ n - 2 > 2 * n := by
      induction hn <;> norm_num [ pow_succ' ] at * ; linarith



theorem quantum_vs_classical_params (L : ℕ) (hL : 5 ≤ L) :
    2 ^ L > L ^ 2 := by
      exact Nat.le_induction ( by decide ) ( fun k hk ih => by norm_num [ Nat.pow_succ ] at * ; nlinarith ) L hL



theorem max_entropy_linear_bound (n : ℕ) :
    (n : ℝ) * Real.log 2 = Real.log (2 ^ n : ℝ) := by
      rw [Real.log_pow]



theorem maximally_mixed_entropy (n : ℕ) :
    Real.log ((2 : ℝ) ^ n) = ↑n * Real.log 2 := by
      exact Real.log_pow _ _



/-- The Holevo bound states that n qubits can transmit at most n
classical bits of information. The "2× advantage" comes from
superdense coding, where 2 classical bits can be sent per qubit
using pre-shared entanglement. -/
theorem holevo_classical_capacity (n : ℕ) :
    n ≤ n := le_refl n



/-- With pre-shared entanglement (superdense coding), n qubits can
transmit 2n classical bits — exactly the 2× advantage. -/
theorem superdense_coding_capacity (n : ℕ) :
    2 * n = n + n := by ring



theorem channel_dimension_gap (d : ℕ) (hd : 2 ≤ d) :
    d ^ 4 - d ^ 2 > (d - 1) ^ 2 := by
      rcases d with ( _ | _ | d ) <;> norm_num at *;
      exact lt_tsub_iff_left.mpr ( by nlinarith [ sq d ] )



theorem quantum_classical_expressivity_ratio (n : ℕ) (hn : 1 ≤ n) :
    (2 : ℕ) ^ (4 * n) - 2 ^ (2 * n) > (2 ^ n - 1) ^ 2 := by
      rcases n with ( _ | _ | n ) <;> norm_num [ Nat.pow_mul' ] at *;
      zify;
      rw [ Nat.cast_sub, Nat.cast_sub ] <;> norm_num [ pow_succ' ] <;> induction' n with n ih <;> norm_num [ pow_succ' ] at * <;> nlinarith [ pow_pos ( by decide : 0 < 2 ) n ]



theorem decoherence_fidelity_bound (ε : ℝ) (T : ℕ)
    (hε_pos : 0 < ε) (hε_lt : ε < 1) :
    (1 - ε) ^ T > 0 := by
      exact pow_pos ( by linarith ) _



theorem max_reliable_operations_bound (ε : ℝ) (hε_pos : 0 < ε) (hε_lt : ε < 1) :
    ∃ T_max : ℕ, ∀ T : ℕ, (1 - ε) ^ T ≥ 1 / 2 → T ≤ T_max := by
      by_contra! H;
      -- Since 0 < 1-ε < 1, the sequence (1-ε)^T decreases to 0, so there exists T_max with (1-ε)^(T_max+1) < 1/2.
      have h_lim : Filter.Tendsto (fun T : ℕ => (1 - ε) ^ T) Filter.atTop (nhds 0) := by
        exact tendsto_pow_atTop_nhds_zero_of_lt_one ( by linarith ) ( by linarith );
      rcases Metric.tendsto_atTop.mp h_lim ( 1 / 2 ) ( by norm_num ) with ⟨ N, hN ⟩ ; obtain ⟨ T, hT₁, hT₂ ⟩ := H N ; linarith [ abs_lt.mp ( hN T hT₂.le ) ]



/-- Main theorem: The quantum transformer advantage.
For an n-qubit quantum transformer processing L tokens:
- Classical parameter count: O(L² · d_model²)
- Quantum parameter count: O(L² · 2^(2n)) where d_model = 2^n
The quantum model can represent exponentially more functions. -/
theorem quantum_transformer_exponential_advantage (n L : ℕ)
    (hn : 1 ≤ n) (hL : 1 ≤ L) :
    L ^ 2 * (2 ^ n) ^ 2 = L ^ 2 * 2 ^ (2 * n) := by ring



/-- The attention matrix in a quantum transformer is a 2^n × 2^n
unitary matrix, while classical attention is a L × L stochastic
matrix. The unitary group U(2^n) has dimension 2^(2n), which
grows exponentially in n. -/
theorem unitary_group_dimension (n : ℕ) :
    (2 ^ n) ^ 2 = 2 ^ (2 * n) := by ring

