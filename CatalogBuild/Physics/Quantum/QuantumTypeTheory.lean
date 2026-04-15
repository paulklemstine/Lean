/-! # CatalogBuild.Physics.Quantum.QuantumTypeTheory

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 10
-/

import Mathlib

theorem identity_gate_unitary (n : ℕ) : IsUnitaryGate (1 : Matrix (Fin n) (Fin n) ℂ) := by
  constructor <;> norm_num

/-
PROBLEM
The product of two unitary gates is unitary.

PROVIDED SOLUTION
Unfold IsUnitaryGate. For (UV)(UV)* = UV V* U* = U(VV*)U* = U·1·U* = UU* = 1. Use Matrix.conjTranspose_mul, matrix mul_assoc, and the hypotheses hU and hV.
-/

theorem unitary_conjTranspose {n : ℕ} {U : Matrix (Fin n) (Fin n) ℂ}
    (hU : IsUnitaryGate U) :
    IsUnitaryGate U.conjTranspose := by
  unfold IsUnitaryGate at hU ⊢; aesop;

/-! ## Section 3: Tensor Products and Entanglement

Entanglement is the key quantum phenomenon. A state is entangled if it
cannot be written as a tensor product of subsystem states. -/

/-- A bipartite state on systems of dimension m and n. -/

def BipartiteState (m n : ℕ) := { v : Fin m × Fin n → ℂ // ∑ ij, ‖v ij‖ ^ 2 = 1 }

/-- A bipartite state is separable if it's a tensor product. -/

def isSeparable {m n : ℕ} (ψ : Fin m × Fin n → ℂ) : Prop :=
  ∃ (α : Fin m → ℂ) (β : Fin n → ℂ), ∀ i j, ψ (i, j) = α i * β j

/-- A state is entangled if it is not separable. -/

def isEntangled {m n : ℕ} (ψ : Fin m × Fin n → ℂ) : Prop :=
  ¬isSeparable ψ

/-
PROBLEM
**Theorem**: The tensor product of two states is separable (by definition).

PROVIDED SOLUTION
exact ⟨α, β, fun i j => rfl⟩
-/

theorem tensorProduct_separable {m n : ℕ} (α : Fin m → ℂ) (β : Fin n → ℂ) :
    isSeparable (fun ij => α ij.1 * β ij.2) := by
  exact ⟨ α, β, fun i j => rfl ⟩

/-
PROBLEM
**Novel Theorem (Bell State Entanglement)**: The Bell state
    |00⟩ + |11⟩ (unnormalized) on ℂ² ⊗ ℂ² is entangled.

PROVIDED SOLUTION
Unfold isEntangled and isSeparable. Assume separable: ψ(i,j) = α(i)·β(j). Then ψ(0,0)=1 gives α(0)β(0)=1, ψ(1,1)=1 gives α(1)β(1)=1, ψ(0,1)=0 gives α(0)β(1)=0, ψ(1,0)=0 gives α(1)β(0)=0. From α(0)β(0)=1 we get α(0)≠0 and β(0)≠0. From α(0)β(1)=0 and α(0)≠0 we get β(1)=0. But then α(1)β(1)=α(1)·0=0≠1, contradiction.
-/

def isLinearClone {n : ℕ} (clone : (Fin n → ℂ) → (Fin n × Fin n → ℂ)) : Prop :=
  ∀ (c : ℂ) (ψ : Fin n → ℂ), clone (c • ψ) = c • clone ψ

/-
PROBLEM
**Novel Theorem (No-Cloning, simplified)**: A cloning map cannot be linear.
    If clone(ψ) = ψ⊗ψ, then clone(cψ) = c²(ψ⊗ψ) ≠ c(ψ⊗ψ) = c·clone(ψ)
    for generic c, contradicting linearity.

PROVIDED SOLUTION
Assume isLinearClone clone. Then clone(2•ψ) = 2 • clone(ψ). But by hclone, clone(2•ψ)(i,j) = (2ψ i)(2ψ j) = 4·ψ(i)·ψ(j), while 2•clone(ψ)(i,j) = 2·ψ(i)·ψ(j). So 4·ψ(i)·ψ(j) = 2·ψ(i)·ψ(j) for all i,j. Since ∃ i, ψ i ≠ 0, take that i and j=i: 4·(ψ i)² = 2·(ψ i)², so 2·(ψ i)² = 0, so (ψ i)² = 0, so ψ i = 0, contradiction.
-/

theorem no_cloning_simplified {n : ℕ} (hn : 0 < n) (clone : (Fin n → ℂ) → (Fin n × Fin n → ℂ))
    (hclone : isCloningMap clone)
    (ψ : Fin n → ℂ) (hψ : ∃ i, ψ i ≠ 0) :
    ¬isLinearClone clone := by
  intro hL; obtain ⟨ i, hi ⟩ := hψ; specialize hL 2 ψ; have := congr_fun hL ( i, i ) ; simp_all +decide [ sq ] ;
  replace hL := congr_fun hL ( i, i ) ; simp_all +decide [ two_smul, isCloningMap ] ; ring_nf at hL ; aesop ( simp_config := { singlePass := true } ) ;

/-! ## Section 5: Quantum Channel Types

A quantum channel (completely positive trace-preserving map) is the most
general evolution of a quantum system. We define the type structure. -/

/-- A density matrix is a positive semidefinite trace-one matrix. -/

theorem id_channel_trace_preserving (n : ℕ) :
    ∀ ρ : Matrix (Fin n) (Fin n) ℂ, Matrix.trace (id ρ) = Matrix.trace ρ := by
  exact fun _ => rfl

/-
PROBLEM
Composition of trace-preserving maps is trace-preserving.

PROVIDED SOLUTION
intro ρ; rw [hg, hf]
-/

theorem compose_trace_preserving {n m k : ℕ}
    (f : Matrix (Fin n) (Fin n) ℂ → Matrix (Fin m) (Fin m) ℂ)
    (g : Matrix (Fin m) (Fin m) ℂ → Matrix (Fin k) (Fin k) ℂ)
    (hf : ∀ ρ, Matrix.trace (f ρ) = Matrix.trace ρ)
    (hg : ∀ ρ, Matrix.trace (g ρ) = Matrix.trace ρ) :
    ∀ ρ, Matrix.trace (g (f ρ)) = Matrix.trace ρ := by
  aesop
