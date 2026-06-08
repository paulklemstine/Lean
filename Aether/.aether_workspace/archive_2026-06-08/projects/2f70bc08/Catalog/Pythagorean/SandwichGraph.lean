import Mathlib
import Pythagorean.SandwichTheorems

/-!
# Graph Property Instantiation of Certified Sandwich Families

This file instantiates the certified sandwich family framework for concrete
graph properties on small vertex sets. We define graph instances as edge subsets
of `Fin n × Fin n`, define the triangle (3-clique) property, and prove that the
abstract lower-bound machinery applies.

## Main Definitions

- `GraphInst n` — graphs on `Fin n` as Boolean edge functions
- `graphInstPreorder` — subgraph ordering on graph instances
- `hasTriangleBool` — decidable 3-clique predicate
- `hasTriangleMono` — monotonicity of the triangle predicate

## Main Results

- `triangle_lower_bound_from_sandwich` — if a certified sandwich family for
  the triangle property is complete up to size `s`, then no monotone circuit
  of size ≤ `s` computes the triangle predicate
- `triangle_sandwich_equivalence` — completeness ↔ non-existence (instantiation
  of the finite duality theorem)
-/

noncomputable section
open Classical

namespace SandwichUniversality

/-! ## Graph Instances -/

/-- A graph on `Fin n` represented as a Boolean edge function.
    We use ordered pairs with `i < j` to avoid double-counting. -/
abbrev GraphInst (n : ℕ) := Fin n → Fin n → Bool

instance (n : ℕ) : DecidableEq (GraphInst n) :=
  inferInstanceAs (DecidableEq (Fin n → Fin n → Bool))

/-- The subgraph ordering: `G ≤ H` iff every edge of `G` is an edge of `H`. -/
instance graphInstPreorder (n : ℕ) : Preorder (GraphInst n) where
  le G H := ∀ i j, G i j = true → H i j = true
  le_refl G := fun _ _ h => h
  le_trans G H K hGH hHK := fun i j h => hHK i j (hGH i j h)

/-! ## Triangle (3-Clique) Property -/

/-- A graph has a triangle if there exist three distinct vertices forming a clique. -/
def hasTriangleProp (n : ℕ) (G : GraphInst n) : Prop :=
  ∃ (i j k : Fin n), i ≠ j ∧ j ≠ k ∧ i ≠ k ∧
    G i j = true ∧ G j k = true ∧ G i k = true

instance (n : ℕ) (G : GraphInst n) : Decidable (hasTriangleProp n G) :=
  inferInstanceAs (Decidable (∃ _, _))

/-- Boolean version of the triangle predicate. -/
def hasTriangleBool (n : ℕ) (G : GraphInst n) : Bool :=
  decide (hasTriangleProp n G)

/-- The triangle predicate is monotone: adding edges preserves triangles. -/
theorem hasTriangleMono (n : ℕ) : Monotone (hasTriangleBool n) := by
  intro G H hGH
  simp only [hasTriangleBool, Bool.le_iff_imp]
  intro hG
  rw [decide_eq_true_eq] at hG ⊢
  obtain ⟨i, j, k, hij, hjk, hik, e1, e2, e3⟩ := hG
  exact ⟨i, j, k, hij, hjk, hik, hGH i j e1, hGH j k e2, hGH i k e3⟩

/-! ## Sandwich Family for Triangle Property -/

/-- Apply the engine theorem: a complete sandwich family for the triangle
    property yields a lower bound. -/
theorem triangle_lower_bound_from_sandwich (n : ℕ)
    (S : CertifiedSandwichFamily (GraphInst n) (hasTriangleBool n))
    (s : ℕ)
    (hS : SandwichCompleteUpTo (hasTriangleBool n) S s) :
    ¬ ∃ C : MonoCircuitProfile (GraphInst n),
      C.size ≤ s ∧ ∀ G, C.eval G = hasTriangleBool n G :=
  no_small_circuit_of_sandwichCompleteUpTo (hasTriangleBool n) S s hS

/-- Instantiation of the finite duality theorem for the triangle property.
    On `GraphInst n`, existence of a complete sandwich family is equivalent
    to the non-existence of a small circuit computing the triangle predicate. -/
theorem triangle_sandwich_equivalence (n s : ℕ) :
    (∃ S : CertifiedSandwichFamily (GraphInst n) (hasTriangleBool n),
       SandwichCompleteUpTo (hasTriangleBool n) S s) ↔
    (¬ ∃ C : MonoCircuitProfile (GraphInst n),
       C.size ≤ s ∧ ∀ G, C.eval G = hasTriangleBool n G) :=
  sandwichCompleteUpTo_iff_no_small_circuit (hasTriangleBool n) s

/-! ## Verified Certificate Checking -/

/-- Verify that a given sandwich family is complete by checking all circuits
    in a given finite set. This is the specification-level correctness theorem
    for the algorithmic search procedure. -/
theorem verify_sandwich_complete_of_finite_check
    {n : ℕ}
    (S : CertifiedSandwichFamily (GraphInst n) (hasTriangleBool n))
    (Circs : Finset (MonoCircuitProfile (GraphInst n)))
    (hcover : ∀ C : MonoCircuitProfile (GraphInst n),
      C.size ≤ s → C ∈ Circs)
    (hcheck : ∀ C ∈ Circs, SandwichHitsCircuit (hasTriangleBool n) S C) :
    SandwichCompleteUpTo (hasTriangleBool n) S s :=
  fun C hC => hcheck C (hcover C hC)

/-! ## Connection to Proof-Theoretic Refutation Systems -/

/-- **Proof-Theoretic Interpretation.** A certified sandwich family that is
    complete up to size `s` constitutes a finite refutation system: for every
    candidate circuit (viewed as a "proof" that f is computable), the family
    provides a "countermodel" (a disagreement witness).

    This theorem packages this interpretation: completeness implies that
    the family serves as a sound refutation oracle. -/
theorem sandwich_as_refutation_system
    {α : Type*} [Preorder α] [Fintype α] [DecidableEq α]
    (f : α → Bool) (S : CertifiedSandwichFamily α f) (s : ℕ)
    (hcomplete : SandwichCompleteUpTo f S s) :
    ∀ C : MonoCircuitProfile α, C.size ≤ s →
      ∃ x ∈ S.Pos ∪ S.Neg, C.eval x ≠ f x := by
  intro C hC
  have h := hcomplete C hC
  rcases h with ⟨x, hxP, heval, hf⟩ | ⟨x, hxN, heval, hf⟩
  · exact ⟨x, Finset.mem_union_left _ hxP, by simp [heval, hf]⟩
  · exact ⟨x, Finset.mem_union_right _ hxN, by simp [heval, hf]⟩

end SandwichUniversality