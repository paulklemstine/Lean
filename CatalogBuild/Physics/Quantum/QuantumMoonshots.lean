/-! # CatalogBuild.Physics.Quantum.QuantumMoonshots

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 32
-/

import Mathlib

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumMoonshots
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 32] -/
def teleportation_network_ebits (n : ℕ) : ℕ := n * (n - 1) / 2


/-- [Section: # CatalogBuild.Physics.Quantum.QuantumMoonshots
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 32] -/
def star_network_ebits (n : ℕ) : ℕ := n - 1


/-- [Section: # CatalogBuild.Physics.Quantum.QuantumMoonshots
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 32] -/
theorem star_more_efficient (n : ℕ) (hn : 3 ≤ n) :
    star_network_ebits n < teleportation_network_ebits n := by
  simp only [star_network_ebits, teleportation_network_ebits]
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 3 := ⟨n - 3, by omega⟩
  simp only [show m + 3 - 1 = m + 2 from by omega]
  have h1 : (m + 3) * (m + 2) = m * m + 5 * m + 6 := by ring
  rw [h1]; omega


def black_hole_qubits (n_planck_masses : ℕ) : ℕ := n_planck_masses ^ 2


theorem baby_black_hole_feasible : black_hole_qubits 10 = 100 := by
  simp [black_hole_qubits]


theorem stellar_black_hole_impossible : black_hole_qubits (10^38) = 10^76 := by
  simp [black_hole_qubits, ← pow_mul]


theorem quantum_money_security (n : ℕ) (hn : 1 ≤ n) : 3 ^ n < 4 ^ n :=
  Nat.pow_lt_pow_left (by norm_num : 3 < 4) (by omega : n ≠ 0)


def chemistry_qubits (m_basis : ℕ) : ℕ := m_basis


def co2_qubits_accurate : ℕ := chemistry_qubits 60


theorem terraforming_qubits : 100 * co2_qubits_accurate = 6000 := by
  simp [co2_qubits_accurate, chemistry_qubits]


theorem classical_chemistry_intractable : (2 : ℕ) ^ 60 > 10 ^ 17 := by norm_num


theorem quantum_kernel_advantage (n : ℕ) : n < 2 ^ n := Nat.lt_two_pow_self


def protein_interactions (L : ℕ) : ℕ := L * (L - 1) / 2


def protein_folding_qubits (L : ℕ) : ℕ := L * L


theorem small_protein_feasible : protein_folding_qubits 100 = 10000 := by
  simp [protein_folding_qubits]


theorem levinthal_paradox (L : ℕ) : L < 3 ^ L := by
  calc L < 2 ^ L := Nat.lt_two_pow_self
    _ ≤ 3 ^ L := Nat.pow_le_pow_left (by norm_num) L


def dyson_configs (n : ℕ) : ℕ := Nat.factorial n


theorem dyson_20_configs : dyson_configs 20 > 10^18 := by native_decide


theorem dyson_quantum_tractable : Nat.sqrt (dyson_configs 20) < 10^10 := by native_decide


def concatenated_qubits (d k : ℕ) : ℕ := d ^ k


theorem concat_distance7_level3 : concatenated_qubits 7 3 = 343 := by
  simp [concatenated_qubits]


theorem concat_distance7_level5 : concatenated_qubits 7 5 = 16807 := by
  simp [concatenated_qubits]


def surface_code_qubits (d : ℕ) : ℕ := d * d + (d - 1) * (d - 1)


theorem surface_code_d21 : surface_code_qubits 21 = 841 := by
  simp [surface_code_qubits]


theorem million_qubit_logical : 1000000 / surface_code_qubits 21 = 1189 := by native_decide


inductive TRL where
  | level1 | level2 | level3 | level4 | level5
  | level6 | level7 | level8 | level9


structure MoonshotAssessment where
  name : String
  trl : TRL
  qubits_needed : ℕ
  timeline_years : ℕ


def teleportation_assessment : MoonshotAssessment :=
  { name := "Quantum Teleportation Network", trl := .level4,
    qubits_needed := 1000, timeline_years := 10 }


def gravity_sim_assessment : MoonshotAssessment :=
  { name := "Baby Black Hole Simulation", trl := .level2,
    qubits_needed := 100, timeline_years := 15 }


def quantum_money_assessment : MoonshotAssessment :=
  { name := "Quantum Cryptographic Money", trl := .level3,
    qubits_needed := 400, timeline_years := 20 }


def protein_assessment : MoonshotAssessment :=
  { name := "Quantum Protein Folding", trl := .level2,
    qubits_needed := 10000, timeline_years := 15 }


def quantum_ml_assessment : MoonshotAssessment :=
  { name := "Quantum ML Supremacy", trl := .level3,
    qubits_needed := 50, timeline_years := 5 }


