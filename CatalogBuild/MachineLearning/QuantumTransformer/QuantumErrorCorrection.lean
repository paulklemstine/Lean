/-! # CatalogBuild.MachineLearning.QuantumTransformer.QuantumErrorCorrection

Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 10
-/

import Mathlib

noncomputable section

/-- [Section: # CatalogBuild.MachineLearning.QuantumTransformer.QuantumErrorCorrection
Auto-generated from theorem catalog database.
Domain: MachineLearning/QuantumTransformer
Declarations: 10] -/
theorem swap_involution {n : Type*} [DecidableEq n] (a b : n) :
    swap a b * swap a b = 1 := swap_mul_self a b



theorem swap_self_inverse {n : Type*} [DecidableEq n] (a b : n) :
    (swap a b)⁻¹ = swap a b := by
  rw [inv_eq_iff_mul_eq_one]; exact swap_involution a b



theorem swap_symmetric {n : Type*} [DecidableEq n] (a b : n) :
    swap a b = swap b a := swap_comm a b



def logical_qubits (n_physical n_stabilizers : ℕ) : ℕ :=
  n_physical - n_stabilizers



theorem steane_code_params : logical_qubits 7 6 = 1 := rfl



theorem swap_circuit_overhead (n_swaps d : ℕ) :
    n_swaps * (d * d) = n_swaps * d ^ 2 := by ring



theorem total_ec_gate_count (n d : ℕ) (hd : 1 ≤ d) :
    n * d ^ 2 ≥ n := by
  nlinarith [Nat.one_le_pow 2 d hd]



theorem clifford_simulation_cost (n : ℕ) (hn : 0 < n) :
    n ≤ n * n := Nat.le_mul_of_pos_left n hn



theorem simulation_advantage (n : ℕ) (hn : 1 ≤ n) :
    n < 2 ^ n := Nat.lt_pow_self (by norm_num : 1 < 2)



theorem transposition_count_bound (n : ℕ) (hn : 1 ≤ n) :
    n - 1 < n := Nat.sub_one_lt (by omega)



end
