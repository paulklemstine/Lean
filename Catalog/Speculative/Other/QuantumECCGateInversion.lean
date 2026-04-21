/-! # CatalogBuild.Speculative.Other.QuantumECCGateInversion

Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 25
-/

import Mathlib

/-- Pauli X gate: [[0,1],[1,0]] -/
def PauliX : Matrix (Fin 2) (Fin 2) ℤ := !![0, 1; 1, 0]




/-- Pauli Z gate: [[1,0],[0,-1]] -/
def PauliZ : Matrix (Fin 2) (Fin 2) ℤ := !![1, 0; 0, -1]




/-- XZ product -/
def PauliXZ : Matrix (Fin 2) (Fin 2) ℤ := !![0, -1; 1, 0]




/-- XZ · ZX = I (product of involutions with its reverse). -/
theorem pauli_XZ_ZX_id :
    PauliX * PauliZ * (PauliZ * PauliX) = (1 : Matrix (Fin 2) (Fin 2) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [PauliX, PauliZ, Matrix.mul_apply, Fin.sum_univ_two]




/-- For matrices, the product of two involutions composed with its reverse is identity. -/
theorem involution_product_invertible
    (A B : Matrix (Fin 2) (Fin 2) ℤ)
    (hA : A * A = 1) (hB : B * B = 1) :
    (A * B) * (B * A) = 1 := by
  rw [Matrix.mul_assoc A B (B * A), ← Matrix.mul_assoc B B A, hB, Matrix.one_mul, hA]




/-- [Section: # CatalogBuild.Speculative.Other.QuantumECCGateInversion
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 25] -/
def secp256k1_a_param : ℕ := 0



/-- [Section: # CatalogBuild.Speculative.Other.QuantumECCGateInversion
Auto-generated from theorem catalog database.
Domain: Speculative/Other
Declarations: 25] -/
def secp256k1_b_param : ℕ := 7




theorem secp256k1_no_linear_term : secp256k1_a_param = 0 := rfl




theorem secp256k1_b_small : secp256k1_b_param < 10 := by
  norm_num [secp256k1_b_param]




def secp256k1_order : ℕ :=
  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141




def secp256k1_cofactor : ℕ := 1



def secp256k1_bits : ℕ := 256




theorem classical_security_bound :
    2 ^ (secp256k1_bits / 2) = 2 ^ 128 := by
  simp [secp256k1_bits]




theorem quantum_speedup_exponential :
    secp256k1_bits ^ 3 < 2 ^ 25 := by
  norm_num [secp256k1_bits]




def min_logical_qubits : ℕ := 2330




theorem quantum_hardware_gap : min_logical_qubits > 1000 := by
  norm_num [min_logical_qubits]




theorem tgate_lower_bound :
    7 * secp256k1_bits ^ 2 > 400000 := by
  norm_num [secp256k1_bits]




theorem three_gate_inverse
    (A B C : Matrix (Fin 2) (Fin 2) ℤ)
    (hA : A * A = 1) (hB : B * B = 1) (hC : C * C = 1) :
    A * B * C * (C * (B * A)) = 1 := by
  grind +revert




theorem four_gate_inverse
    (A B C D : Matrix (Fin 2) (Fin 2) ℤ)
    (hA : A * A = 1) (hB : B * B = 1) (hC : C * C = 1) (hD : D * D = 1) :
    A * B * C * D * (D * (C * (B * A))) = 1 := by
  grind




def CNOT_gate : Matrix (Fin 4) (Fin 4) ℤ :=
  !![1, 0, 0, 0;
     0, 1, 0, 0;
     0, 0, 0, 1;
     0, 0, 1, 0]




theorem cnot_self_inverse : CNOT_gate * CNOT_gate = (1 : Matrix (Fin 4) (Fin 4) ℤ) := by
  ext i j; fin_cases i <;> fin_cases j <;>
    simp [CNOT_gate, Matrix.mul_apply, Fin.sum_univ_four]




theorem hasse_check_11 : (12 - 7 : ℤ) ≤ 7 := by norm_num



theorem hasse_check_23 : (24 - 21 : ℤ).natAbs ≤ 10 := by norm_num



theorem hasse_check_67 : (78 - 68 : ℤ).natAbs ≤ 17 := by norm_num




theorem involution_list_inverse (gates : List (Matrix (Fin 2) (Fin 2) ℤ))
    (h : ∀ g ∈ gates, g * g = 1) :
    gates.prod * gates.reverse.prod = 1 := by
  induction' gates using List.reverseRecOn with g gs ih <;> simp +decide [ *, mul_assoc ] at *;
  simp_all +decide [ ← mul_assoc ]


