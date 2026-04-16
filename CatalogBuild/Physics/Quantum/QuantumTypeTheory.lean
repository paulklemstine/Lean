/-! # CatalogBuild.Physics.Quantum.QuantumTypeTheory

Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 10
-/

import Mathlib

/-- [Section: # CatalogBuild.Physics.Quantum.QuantumTypeTheory
Auto-generated from theorem catalog database.
Domain: Physics/Quantum
Declarations: 10] -/
theorem identity_gate_unitary (n : ℕ) : IsUnitaryGate (1 : Matrix (Fin n) (Fin n) ℂ) := by
  constructor <;> norm_num



theorem unitary_conjTranspose {n : ℕ} {U : Matrix (Fin n) (Fin n) ℂ}
    (hU : IsUnitaryGate U) :
    IsUnitaryGate U.conjTranspose := by
  unfold IsUnitaryGate at hU ⊢; aesop;



/-- A bipartite state on systems of dimension m and n. -/
def BipartiteState (m n : ℕ) := { v : Fin m × Fin n → ℂ // ∑ ij, ‖v ij‖ ^ 2 = 1 }



/-- A bipartite state is separable if it's a tensor product. -/
def isSeparable {m n : ℕ} (ψ : Fin m × Fin n → ℂ) : Prop :=
  ∃ (α : Fin m → ℂ) (β : Fin n → ℂ), ∀ i j, ψ (i, j) = α i * β j



/-- A state is entangled if it is not separable. -/
def isEntangled {m n : ℕ} (ψ : Fin m × Fin n → ℂ) : Prop :=
  ¬isSeparable ψ



theorem tensorProduct_separable {m n : ℕ} (α : Fin m → ℂ) (β : Fin n → ℂ) :
    isSeparable (fun ij => α ij.1 * β ij.2) := by
  exact ⟨ α, β, fun i j => rfl ⟩



/-- A cloning map is "linear" if it respects scalar multiplication. -/
def isLinearClone {n : ℕ} (clone : (Fin n → ℂ) → (Fin n × Fin n → ℂ)) : Prop :=
  ∀ (c : ℂ) (ψ : Fin n → ℂ), clone (c • ψ) = c • clone ψ



theorem no_cloning_simplified {n : ℕ} (hn : 0 < n) (clone : (Fin n → ℂ) → (Fin n × Fin n → ℂ))
    (hclone : isCloningMap clone)
    (ψ : Fin n → ℂ) (hψ : ∃ i, ψ i ≠ 0) :
    ¬isLinearClone clone := by
  intro hL; obtain ⟨ i, hi ⟩ := hψ; specialize hL 2 ψ; have := congr_fun hL ( i, i ) ; simp_all +decide [ sq ] ;
  replace hL := congr_fun hL ( i, i ) ; simp_all +decide [ two_smul, isCloningMap ] ; ring_nf at hL ; aesop ( simp_config := { singlePass := true } ) ;



theorem id_channel_trace_preserving (n : ℕ) :
    ∀ ρ : Matrix (Fin n) (Fin n) ℂ, Matrix.trace (id ρ) = Matrix.trace ρ := by
  exact fun _ => rfl



theorem compose_trace_preserving {n m k : ℕ}
    (f : Matrix (Fin n) (Fin n) ℂ → Matrix (Fin m) (Fin m) ℂ)
    (g : Matrix (Fin m) (Fin m) ℂ → Matrix (Fin k) (Fin k) ℂ)
    (hf : ∀ ρ, Matrix.trace (f ρ) = Matrix.trace ρ)
    (hg : ∀ ρ, Matrix.trace (g ρ) = Matrix.trace ρ) :
    ∀ ρ, Matrix.trace (g (f ρ)) = Matrix.trace ρ := by
  aesop

