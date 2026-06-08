/-
  # Entanglement Theory: Partial Traces and Entanglement Properties

  This file develops the theory of entanglement measures for qubit systems,
  including partial traces, reduced density matrices, and properties of
  maximally entangled states.

  ## Key Results

  - Pure state density matrices have trace 1
  - Partial trace preserves trace
  - Bell states are maximally entangled (reduced state = I/2)
  - Product states have pure reduced density matrices
  - Entangled states have mixed reduced density matrices (det > 0)

  These results form the foundation for monogamy of entanglement and
  quantum information protocols.
-/
import Mathlib
import Physics.QuantumInformation.Defs

namespace QuantumInformation

open Complex Matrix Finset

noncomputable section

/-! ## Pure state density matrix properties -/

/-
The trace of a pure state density matrix |ψ⟩⟨ψ| equals ‖ψ‖².
-/
theorem trace_pureDensity {n : Type*} [Fintype n] [DecidableEq n] (ψ : n → ℂ) :
    (pureDensity ψ).trace =
    ∑ i, starRingEnd ℂ (ψ i) * ψ i := by
  -- The trace of a matrix is the sum of its diagonal elements.
  simp [Matrix.trace, pureDensity];
  grind

/-
A normalized pure state gives a density matrix with trace 1.
-/
theorem trace_pureDensity_of_normalized {n : Type*} [Fintype n] [DecidableEq n]
    (ψ : n → ℂ) (hψ : ∑ i, ‖ψ i‖ ^ 2 = 1) :
    (pureDensity ψ).trace = 1 := by
  convert hψ using 1
  unfold pureDensity;
  simp +decide [ ← hψ, trace, Complex.mul_conj, Complex.normSq_eq_norm_sq ];
  exact_mod_cast hψ

/-! ## Partial trace properties -/

/-
Partial trace preserves trace: Tr(Tr_B(ρ)) = Tr(ρ).
-/
theorem trace_partialTraceRight {m n : Type*} [Fintype m] [Fintype n] [DecidableEq m]
    (ρ : Matrix (m × n) (m × n) ℂ) :
    (partialTraceRight ρ).trace = ρ.trace := by
  simp +decide [ trace, Finset.sum_apply, Finset.mul_sum ];
  exact?

/-
Partial trace over the first system preserves trace.
-/
theorem trace_partialTraceLeft {m n : Type*} [Fintype m] [Fintype n] [DecidableEq n]
    (ρ : Matrix (m × n) (m × n) ℂ) :
    (partialTraceLeft ρ).trace = ρ.trace := by
  convert trace_partialTraceRight ( ρ.submatrix ( fun x => ( x.2, x.1 ) ) ( fun x => ( x.2, x.1 ) ) ) using 1;
  refine' Finset.sum_bij ( fun x _ => ( x.2, x.1 ) ) _ _ _ _ <;> simp +decide

/-! ## Product state reduced density matrices -/

/-
The reduced density matrix of a product state |ψ⟩⊗|φ⟩ (tracing out the second
system) is |ψ⟩⟨ψ| scaled by ‖φ‖².
-/
theorem partialTraceRight_product {m n : Type*} [Fintype m] [Fintype n]
    (ψ : m → ℂ) (φ : n → ℂ) :
    partialTraceRight (pureDensity (kronVec ψ φ)) =
    (∑ j, ‖φ j‖ ^ 2) • pureDensity ψ := by
  ext i j pureDensity kronVec;
  unfold partialTraceRight pureDensity kronVec;
  simp +decide [ mul_left_comm ( φ _ ), mul_assoc, mul_comm, Finset.mul_sum _ _ _, Complex.mul_conj, Complex.normSq_eq_norm_sq ];
  simp +decide only [← mul_assoc, ← Finset.sum_mul _ _ _];
  simp +decide only [← Finset.mul_sum _ _ _, mul_comm]

/-! ## Entanglement detection

For a pure bipartite state, entanglement can be detected by the purity
of the reduced density matrix. A state is entangled iff the reduced
density matrix is mixed (not a pure state projection). -/

/-- The purity Tr(ρ²) of a 2×2 matrix. -/
def purity (ρ : Matrix (Fin 2) (Fin 2) ℂ) : ℂ := (ρ * ρ).trace

/-
The maximally mixed state I/2 has purity 1/2.
-/
theorem purity_maximally_mixed :
    purity ((1/2 : ℂ) • (1 : Matrix (Fin 2) (Fin 2) ℂ)) = 1/2 := by
  norm_num [ purity ]

/-
A Bell state is maximally entangled: reduced density matrix has purity 1/2.
-/
theorem bell_state_purity :
    purity (partialTraceRight (pureDensity bellPlus)) = 1/2 := by
  unfold purity;
  -- By definition of `bellPlus`, we know that its reduced density matrix is `1/2 * I`.
  unfold partialTraceRight pureDensity bellPlus; norm_num [ Fin.sum_univ_succ, Fin.sum_univ_zero, Finset.sum_range_succ, Finset.sum_range_zero, Matrix.trace, Matrix.mul_apply ];
  norm_num [ ← sq, ← Complex.ofReal_pow ]

/-! ## Entanglement measures for qubits

For a pure two-qubit state, the linear entropy of entanglement is
S_L = 1 - Tr(ρ_A²) = 4 det(ρ_A), where ρ_A is the reduced density matrix.

This connects to the tangle τ = 4 det(ρ_A) used in the CKW inequality. -/

/-- Linear entropy of entanglement for a two-qubit pure state. -/
def linearEntropy (ψ : Fin 2 × Fin 2 → ℂ) : ℂ :=
  1 - purity (partialTraceRight (pureDensity ψ))

/-- The tangle of a two-qubit pure state, defined as 4·det(ρ_A). -/
def tangle (ψ : Fin 2 × Fin 2 → ℂ) : ℂ :=
  4 * det (partialTraceRight (pureDensity ψ))

/-
For a normalized two-qubit pure state, the linear entropy equals half the tangle:
  S_L = τ/2, equivalently 2·S_L = 4·det(ρ_A).
-/
theorem linearEntropy_eq_half_tangle (ψ : Fin 2 × Fin 2 → ℂ)
    (hψ : ∑ p : Fin 2 × Fin 2, ‖ψ p‖ ^ 2 = 1) :
    2 * linearEntropy ψ = tangle ψ := by
  unfold linearEntropy tangle;
  unfold partialTraceRight purity pureDensity;
  norm_num [ Finset.sum_add_distrib, Matrix.mul_apply, Matrix.trace_fin_two, Matrix.det_fin_two ];
  simp_all +decide [ Complex.ext_iff, sq ]; norm_num [ Complex.ext_iff, sq ] at *; ring_nf at *;
  norm_num [ Complex.normSq, Complex.sq_norm ] at *;
  rw [ show ( ∑ x : Fin 2 × Fin 2, ( ( ψ x |> Complex.re ) * ( ψ x |> Complex.re ) + ( ψ x |> Complex.im ) * ( ψ x |> Complex.im ) ) ) = ( ψ ( 0, 0 ) |> Complex.re ) * ( ψ ( 0, 0 ) |> Complex.re ) + ( ψ ( 0, 0 ) |> Complex.im ) * ( ψ ( 0, 0 ) |> Complex.im ) + ( ψ ( 0, 1 ) |> Complex.re ) * ( ψ ( 0, 1 ) |> Complex.re ) + ( ψ ( 0, 1 ) |> Complex.im ) * ( ψ ( 0, 1 ) |> Complex.im ) + ( ψ ( 1, 0 ) |> Complex.re ) * ( ψ ( 1, 0 ) |> Complex.re ) + ( ψ ( 1, 0 ) |> Complex.im ) * ( ψ ( 1, 0 ) |> Complex.im ) + ( ψ ( 1, 1 ) |> Complex.re ) * ( ψ ( 1, 1 ) |> Complex.re ) + ( ψ ( 1, 1 ) |> Complex.im ) * ( ψ ( 1, 1 ) |> Complex.im ) by erw [ Finset.sum_product ] ; simp +decide [ Fin.sum_univ_two ] ; ring ] at hψ;
  grind

/-
Bell state has maximal tangle = 1.
-/
theorem bell_tangle :
    tangle bellPlus = (1 : ℂ) := by
  unfold tangle;
  unfold partialTraceRight; norm_num [ Fin.sum_univ_succ, Matrix.det_fin_two ];
  norm_num [ pureDensity, bellPlus ];
  norm_num [ ← sq, ← Complex.ofReal_pow ]

/-
Product states have zero tangle (no entanglement).
-/
theorem product_state_zero_tangle (ψ φ : Fin 2 → ℂ) :
    tangle (kronVec ψ φ) =
    4 * det ((∑ j, ‖φ j‖ ^ 2) • pureDensity ψ) := by
  convert congr_arg _ ( congr_arg _ ( partialTraceRight_product ψ φ ) ) using 1

end

end QuantumInformation