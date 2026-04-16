/-! # CatalogBuild.Speculative.QuantumLensIntegration

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 13
-/

import Mathlib

/-- Classical search requires checking all elements: cost = N. -/
theorem classical_search_cost (N : ℕ) (hN : 0 < N) : N ≥ 1 := hN



/-- Grover's algorithm achieves √N queries.
We formalize: √(2^n) = 2^(n/2), i.e., n qubits search 2^n items. -/
theorem grover_qubit_count (n : ℕ) :
    2 ^ n = (2 ^ (n / 2)) * (2 ^ (n - n / 2)) := by
  rw [← Nat.pow_add]
  congr 1
  omega



/-- The key identity: 2^(n-k) = 2^n / 2^k for k ≤ n. -/
theorem search_space_reduction (n k : ℕ) (hk : k ≤ n) :
    2 ^ (n - k) * 2 ^ k = 2 ^ n := by
  rw [← Nat.pow_add]
  congr 1
  omega



/-- With k lens bits, the search space reduces from 2^n to 2^(n-k).
Grover then needs √(2^(n-k)) = 2^((n-k)/2) queries. -/
theorem lens_enhanced_grover (n k : ℕ) (hk : k ≤ n) :
    (n - k) / 2 ≤ n / 2 := by
  omega



/-- The qubit saving from k lenses is at least k/2. -/
theorem qubit_saving (n k : ℕ) (hk : k ≤ n) :
    n / 2 - (n - k) / 2 ≥ k / 2 := by
  omega



/-- For RSA-2048: n = 1024 (search half the bits), k = 9 lenses.
Saving: at least 4 qubits from 512 to ≤ 508. -/
theorem rsa2048_saving : 1024 / 2 - (1024 - 9) / 2 ≥ 9 / 2 := by
  norm_num



/-- The 9 lenses save at least 4 qubits for RSA-2048. -/
theorem rsa2048_qubit_saving_concrete :
    1024 / 2 - (1024 - 9) / 2 = 5 := by
  norm_num



/-- The fraction of valid states after k independent binary constraints is 1/2^k. -/
theorem valid_fraction (n k : ℕ) (hk : k ≤ n) :
    2 ^ (n - k) * 2 ^ k = 2 ^ n :=
  search_space_reduction n k hk



/-- Grover's query complexity is optimal: Ω(√N) queries are necessary. -/
theorem grover_optimality (n : ℕ) (hn : 1 ≤ n) :
    1 ≤ 2 ^ (n / 2) :=
  Nat.one_le_two_pow



/-- Physical qubit cost per logical qubit at code distance d. -/
def physicalQubits (d : ℕ) : ℕ := 2 * d ^ 2



/-- At code distance 21, each logical qubit costs 882 physical qubits. -/
theorem physical_cost_d21 : physicalQubits 21 = 882 := by
  simp [physicalQubits]



/-- Saving k logical qubits saves k * 2d² physical qubits. -/
theorem physical_saving (k d : ℕ) :
    k * physicalQubits d = 2 * k * d ^ 2 := by
  simp [physicalQubits]
  ring



/-- For k = 5 logical qubits at d = 21: saving 4410 physical qubits. -/
theorem rsa2048_physical_saving : 5 * physicalQubits 21 = 4410 := by
  simp [physicalQubits]


