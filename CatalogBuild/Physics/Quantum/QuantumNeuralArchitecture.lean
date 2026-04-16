/-! # CatalogBuild.Physics.Quantum.QuantumNeuralArchitecture

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 15
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumNeuralArchitecture
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 15] -/
theorem mera_depth_logarithmic (n : ℕ) :
    Nat.log 2 n ≤ n := Nat.log_le_self 2 n



theorem mera_sites_halve (n : ℕ) : n / 2 ≤ n := Nat.div_le_self n 2



theorem mera_gate_count (n : ℕ) (hn : 0 < n) : 2 * n - 1 ≥ n := by omega



theorem transformer_params (L d : ℕ) (hd : 0 < d) : L * d ^ 2 ≥ L := by
  have : d ^ 2 ≥ 1 := Nat.one_le_pow 2 d hd; nlinarith



theorem attention_temperature_pos (d : ℕ) (hd : 0 < d) :
    Real.sqrt (d : ℝ) > 0 := Real.sqrt_pos_of_pos (Nat.cast_pos.mpr hd)



theorem softmax_sums_to_one' (n : ℕ) (x : Fin n → ℝ) (hn : 0 < n) :
    ∑ i, Real.exp (x i) / ∑ j, Real.exp (x j) = 1 := by
  rw [← Finset.sum_div]
  exact div_self (ne_of_gt (Finset.sum_pos (fun i _ => Real.exp_pos _)
    (Finset.univ_nonempty_iff.mpr ⟨⟨0, hn⟩⟩)))



theorem gradient_variance_bound' (n : ℕ) (hn : 0 < n) :
    (1 : ℝ) / 2 ^ n > 0 := by positivity



theorem barren_plateau_severity' (n : ℕ) (hn : 50 ≤ n) : 2 ^ n > 10 ^ 15 := by
  calc 2 ^ n ≥ 2 ^ 50 := Nat.pow_le_pow_right (by omega) hn
    _ > 10 ^ 15 := by norm_num



theorem local_cost_advantage' (n : ℕ) (hn : 5 ≤ n) : 2 ^ n > n ^ 2 := by
  induction hn with
  | refl => norm_num
  | @step k hk ih =>
    show 2 ^ (k + 1) > (k + 1) ^ 2
    have hk5 : (k : ℤ) ≥ 5 := by exact_mod_cast hk
    have h2 : 2 * k ^ 2 ≥ (k + 1) ^ 2 := by
      have : (2 : ℤ) * (k : ℤ) ^ 2 ≥ ((k : ℤ) + 1) ^ 2 := by nlinarith [sq_nonneg ((k : ℤ) - 1)]
      exact_mod_cast this
    calc (2 : ℕ) ^ (k + 1) = 2 ^ k * 2 := pow_succ 2 k
      _ ≥ (k ^ 2 + 1) * 2 := by omega
      _ = 2 * k ^ 2 + 2 := by ring
      _ > 2 * k ^ 2 := by omega
      _ ≥ (k + 1) ^ 2 := h2



theorem phase_encoding_qubits' (V : ℕ) : Nat.log 2 V ≤ V := Nat.log_le_self 2 V



theorem amplitude_encoding_advantage' (V : ℕ) (hV : 4 ≤ V) :
    Nat.log 2 V + 1 < V := by
      rcases V with ( _ | _ | _ | _ | _ | V ) <;> simp_all +arith +decide [ Nat.log_of_lt ];
      refine Nat.le_of_lt_succ ( Nat.log_lt_of_lt_pow ?_ ?_ ) <;> norm_num [ Nat.pow_succ' ];
      exact Nat.recOn V ( by norm_num ) fun n ihn => by norm_num [ Nat.pow_succ' ] at * ; linarith;



theorem dfs_dimension' (n : ℕ) : n + 1 ≥ 1 := by omega



theorem dfs_rate_decreasing' (n : ℕ) (hn : 1 ≤ n) : n + 1 ≤ 2 ^ n := by
  induction n with
  | zero => omega
  | succ k ih =>
    by_cases hk : 1 ≤ k
    · have := ih hk
      have h1 := Nat.one_le_pow k 2 (by omega)
      calc k + 1 + 1 ≤ 2 ^ k + 1 := by omega
        _ ≤ 2 ^ k + 2 ^ k := by omega
        _ = 2 ^ k * 2 := by ring
        _ = 2 ^ (k + 1) := (pow_succ 2 k).symm
    · interval_cases k; norm_num



/-- Bernoulli's inequality: (1-p)^T ≥ 1 - Tp -/
theorem decoherence_accumulation' (T : ℕ) (p : ℝ) (hp : 0 ≤ p) (hp1 : p ≤ 1) :
    (1 - p) ^ T ≥ 1 - T * p := by
  induction T with
  | zero => simp
  | succ k ih =>
    have h1 : (1 - p) ^ (k + 1) = (1 - p) * (1 - p) ^ k := by ring
    rw [h1]
    calc (1 - p) * (1 - p) ^ k
        ≥ (1 - p) * (1 - k * p) := by nlinarith
      _ = 1 - (↑(k + 1)) * p + k * p ^ 2 := by push_cast; ring
      _ ≥ 1 - (↑(k + 1)) * p := by nlinarith [sq_nonneg p]



theorem quantum_crossover' (n : ℕ) (hn : 10 ≤ n) : 2 ^ n > n ^ 3 := by
  induction hn with
  | refl => norm_num
  | @step k hk ih =>
    show 2 ^ (k + 1) > (k + 1) ^ 3
    have hk10 : (k : ℤ) ≥ 10 := by exact_mod_cast hk
    have h2 : 2 * k ^ 3 ≥ (k + 1) ^ 3 := by
      have : (2 : ℤ) * (k : ℤ) ^ 3 ≥ ((k : ℤ) + 1) ^ 3 := by
        nlinarith [sq_nonneg ((k : ℤ) - 3), sq_nonneg ((k : ℤ) * ((k : ℤ) - 3))]
      exact_mod_cast this
    calc (2 : ℕ) ^ (k + 1) = 2 ^ k * 2 := pow_succ 2 k
      _ ≥ (k ^ 3 + 1) * 2 := by omega
      _ = 2 * k ^ 3 + 2 := by ring
      _ > 2 * k ^ 3 := by omega
      _ ≥ (k + 1) ^ 3 := h2



end
