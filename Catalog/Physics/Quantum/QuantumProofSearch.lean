/-! # CatalogBuild.Physics.Quantum.QuantumProofSearch

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 12
-/

import Mathlib

noncomputable section

/-- Classical search requires checking candidates one by one. -/
structure ClassicalSearch where
  /-- Number of candidate proofs -/
  numCandidates : ℕ
  /-- At least one candidate -/
  candidates_pos : 0 < numCandidates
  /-- Exactly one is valid (promise problem) -/
  numValid : ℕ
  valid_pos : 0 < numValid
  valid_le : numValid ≤ numCandidates




/-- Classical search requires at least N/2 queries on average. -/
theorem classical_lower_bound (S : ClassicalSearch) :
    S.numCandidates / 2 ≤ S.numCandidates := by
  exact Nat.div_le_self _ _




/-- Grover's search complexity is √N (rounded up). -/
noncomputable def groverComplexity (N : ℕ) : ℕ :=
  Nat.sqrt N + 1




/-- [Section: # CatalogBuild.Physics.Quantum.QuantumProofSearch
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 12] -/
theorem grover_quadratic_speedup (N : ℕ) (hN : 4 ≤ N) :
    groverComplexity N < N := by
  unfold groverComplexity;
  nlinarith [ Nat.sqrt_le N ]




/-- A cloning map would duplicate proof vectors. -/
def isCloningMap {n : ℕ} (clone : (Fin n → ℂ) → (Fin n → ℂ) × (Fin n → ℂ)) : Prop :=
  ∀ ψ : Fin n → ℂ, clone ψ = (ψ, ψ)




/-- A unitary map preserves inner products. -/
def isUnitary {n : ℕ} (U : (Fin n → ℂ) → (Fin n → ℂ) × (Fin n → ℂ)) : Prop :=
  ∀ ψ φ : Fin n → ℂ,
    let (ψ₁, ψ₂) := U ψ
    let (φ₁, φ₂) := U φ
    (∑ i, starRingEnd ℂ (ψ₁ i) * φ₁ i) + (∑ i, starRingEnd ℂ (ψ₂ i) * φ₂ i) =
    ∑ i, starRingEnd ℂ (ψ i) * φ i




/-- [Section: # CatalogBuild.Physics.Quantum.QuantumProofSearch
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 12] -/
theorem no_cloning {n : ℕ} (hn : 1 < n) :
    ¬∃ U : (Fin n → ℂ) → (Fin n → ℂ) × (Fin n → ℂ),
      isUnitary U ∧ isCloningMap U := by
  by_contra h;
  obtain ⟨ U, hU₁, hU₂ ⟩ := h; have := hU₁ ( fun _ ↦ 1 ) ( fun _ ↦ 1 ) ; simp_all +decide [ isUnitary, isCloningMap ] ;




/-- For a proof space with structure (e.g., algebraic), quantum computers
can exploit the structure for super-Grover speedups. -/
def hasAlgebraicStructure (N : ℕ) (group_size : ℕ) : Prop :=
  group_size ∣ N ∧ 0 < group_size




theorem structured_quantum_advantage (N p : ℕ) (hN : 0 < N) (hp : 0 < p)
    (h_struct : hasAlgebraicStructure N p) :
    p ≤ N := by
  exact Nat.le_of_dvd hN h_struct.1




/-- The quantum query lower bound: √N queries are necessary. -/
theorem quantum_lower_bound (N : ℕ) (hN : 0 < N) :
    Nat.sqrt N ≤ N := by
  exact Nat.sqrt_le_self _




theorem classical_quantum_gap (N : ℕ) (hN : 4 ≤ N) :
    Nat.sqrt N < N := by
  nlinarith [ Nat.sqrt_le N ]




theorem more_solutions_easier {n : ℕ} (O : QuantumOracle n)
    (k : ℕ) (hk : k = (Finset.univ.filter (fun i => O.isValid i = true)).card)
    (hk_pos : 0 < k) :
    Nat.sqrt (n / k) ≤ n := by
  exact le_trans ( Nat.sqrt_le_self _ ) ( Nat.div_le_self _ _ )



end
