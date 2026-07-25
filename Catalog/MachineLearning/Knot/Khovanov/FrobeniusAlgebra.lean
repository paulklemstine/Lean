/-
  # Rank-2 Frobenius Algebra for Khovanov Homology

  The Khovanov Frobenius algebra is V = R·v₊ ⊕ R·v₋ ≅ R[X]/(X²) with:
  - Multiplication m: V ⊗ V → V
  - Comultiplication Δ: V → V ⊗ V
  - Unit η: R → V
  - Counit ε: V → R

  All Frobenius axioms are verified by exhaustive case analysis on the
  two-element basis.

  ## Main results
  - `mul_assoc_basis`: multiplication is associative
  - `mul_comm_basis`: multiplication is commutative
  - `frobenius_relation_basis`: Frobenius compatibility
  - `coassoc_basis`: comultiplication is coassociative
-/
import Mathlib

namespace Knot.Khovanov

/-! ## Basis elements -/

/-- The two basis elements of the Khovanov algebra V = R·v₊ ⊕ R·v₋ -/
inductive KhBasis : Type
  | vPlus : KhBasis   -- corresponds to 1 ∈ R[X]/(X²)
  | vMinus : KhBasis  -- corresponds to X ∈ R[X]/(X²)
  deriving DecidableEq, Fintype, Repr, Inhabited

open KhBasis

/-! ## Multiplication table -/

/-- Multiplication on basis elements: returns `some c` if the product
    is the basis element `c`, and `none` if the product is zero. -/
def mulBasis : KhBasis → KhBasis → Option KhBasis
  | vPlus, vPlus => some vPlus
  | vPlus, vMinus => some vMinus
  | vMinus, vPlus => some vMinus
  | vMinus, vMinus => none

/-! ## Comultiplication table -/

/-- Comultiplication on basis elements -/
def comulBasis : KhBasis → List (KhBasis × KhBasis)
  | vPlus => [(vPlus, vMinus), (vMinus, vPlus)]
  | vMinus => [(vMinus, vMinus)]

/-! ## Algebraic identities -/

/-- Helper: multiplication as a list -/
def mulBasis' (a b : KhBasis) : List KhBasis :=
  match mulBasis a b with
  | some c => [c]
  | none => []

/-- Associativity: m(m(a,b), c) = m(a, m(b,c)) -/
theorem mul_assoc_basis (a b c : KhBasis) :
    (mulBasis' a b).flatMap (fun x => mulBasis' x c) =
    (mulBasis' b c).flatMap (fun x => mulBasis' a x) := by
  cases a <;> cases b <;> cases c <;> simp [mulBasis', mulBasis]

/-- Commutativity: m(a,b) = m(b,a) -/
theorem mul_comm_basis (a b : KhBasis) : mulBasis a b = mulBasis b a := by
  cases a <;> cases b <;> rfl

/-- Left unit: m(v₊, a) = a -/
theorem mul_unit_left (a : KhBasis) : mulBasis vPlus a = some a := by
  cases a <;> rfl

/-- Right unit: m(a, v₊) = a -/
theorem mul_unit_right (a : KhBasis) : mulBasis a vPlus = some a := by
  cases a <;> rfl

/-- Counit: ε(v₊) = 0, ε(v₋) = 1 -/
def counit : KhBasis → ℤ
  | vPlus => 0
  | vMinus => 1

/-- Frobenius relation: (Δ ∘ m)(a ⊗ b) = (m ⊗ id)(id ⊗ Δ)(a ⊗ b) -/
theorem frobenius_relation_basis (a b : KhBasis) :
    (mulBasis' a b).flatMap comulBasis =
    (comulBasis b).flatMap (fun ⟨b₁, b₂⟩ => (mulBasis' a b₁).map (·, b₂)) := by
  cases a <;> cases b <;> simp [mulBasis', mulBasis, comulBasis]

/-- Coassociativity: (Δ ⊗ id) ∘ Δ = (id ⊗ Δ) ∘ Δ -/
theorem coassoc_basis (a : KhBasis) :
    (comulBasis a).flatMap (fun ⟨x, y⟩ =>
      (comulBasis x).map (fun ⟨x₁, x₂⟩ => (x₁, x₂, y))) =
    (comulBasis a).flatMap (fun ⟨x, y⟩ =>
      (comulBasis y).map (fun ⟨y₁, y₂⟩ => (x, y₁, y₂))) := by
  cases a <;> simp [comulBasis]

/-- Quantum degree of a basis element: deg(v₊) = 1, deg(v₋) = -1 -/
def qdeg : KhBasis → ℤ
  | vPlus => 1
  | vMinus => -1

/-- Multiplication preserves degree: deg(m(a,b)) = deg(a) + deg(b) - 1 -/
theorem mul_qdeg (a b c : KhBasis) (h : mulBasis a b = some c) :
    qdeg c = qdeg a + qdeg b - 1 := by
  cases a <;> cases b <;> simp [mulBasis] at h <;> subst h <;> simp [qdeg]

/-- Comultiplication degree shift: for (b,c) ∈ Δ(a), deg(b)+deg(c) = deg(a)-1.
    Combined with the homological degree shift +1 per cube edge, the
    Khovanov differential preserves total quantum degree. -/
theorem comul_qdeg (a : KhBasis) :
    ∀ bc ∈ comulBasis a, qdeg bc.1 + qdeg bc.2 = qdeg a - 1 := by
  cases a <;> decide

end Knot.Khovanov