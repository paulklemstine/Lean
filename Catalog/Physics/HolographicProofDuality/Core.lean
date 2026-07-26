/-
# Holographic proof duality: a precise theorem and two no-go results

The informal slogan “induction in the bulk is coinduction on the boundary” is
made precise for complete lattices. The boundary is the order dual. Least fixed
points (inductive semantics) become greatest fixed points (coinductive
semantics), and pre-fixed certificates become post-fixed certificates.

The file also records two limitations which refute stronger, unqualified
versions of the slogan:

* the dualization preserves the number of local certificate steps exactly, so
  it cannot promise a strictly shorter proof;
* an arbitrary finite bulk with `n+1` distinguishable states cannot be encoded
  losslessly into a boundary with only `n` states.
-/

import Mathlib

open Function OrderDual

namespace HolographicProofDuality

universe u

section FixedPointDuality

variable {α : Type u} [CompleteLattice α]

/-- The boundary action of a monotone bulk evolution is the same action viewed
in the reversed order. -/
def boundaryMap (f : α →o α) : αᵒᵈ →o αᵒᵈ := f.dual

/-- A bulk induction certificate says that `a` is pre-fixed. -/
def BulkCertificate (f : α →o α) (a : α) : Prop := f a ≤ a

/-- A boundary coinduction certificate says that the dual state is post-fixed. -/
def BoundaryCertificate (f : α →o α) (a : αᵒᵈ) : Prop :=
  a ≤ boundaryMap f a

/-- Local proof obligations are unchanged by passage to the boundary: a
pre-fixed bulk certificate is exactly a post-fixed boundary certificate. -/
theorem certificate_duality (f : α →o α) (a : α) :
    BulkCertificate f a ↔ BoundaryCertificate f (toDual a) := by
  simp [BulkCertificate, BoundaryCertificate, boundaryMap]

/-- **Bulk-boundary fixed-point duality.** The inductively generated least
fixed point in the bulk is definitionally the coinductively generated greatest
fixed point on the order-dual boundary. -/
theorem lfp_eq_boundary_gfp (f : α →o α) :
    toDual f.lfp = (boundaryMap f).gfp := by
  apply le_antisymm
  · apply (boundaryMap f).le_gfp
    exact f.map_lfp.le
  · apply (boundaryMap f).gfp_le
    intro b hb
    exact f.lfp_le hb

/-- The usual induction bound is equivalent to a boundary coinduction bound.
This is the proof-level correspondence, not merely equality of denotations. -/
theorem induction_iff_boundary_coinduction (f : α →o α) (a : α) :
    f.lfp ≤ a ↔ toDual a ≤ (boundaryMap f).gfp := by
  constructor
  · intro h
    rw [← lfp_eq_boundary_gfp]
    exact h
  · intro h
    rw [← lfp_eq_boundary_gfp] at h
    exact h

/-- A pre-fixed bulk witness yields the corresponding coinductive boundary
bound. This packages certificate transport and the greatest-fixed-point rule. -/
theorem transport_inductive_proof_to_boundary (f : α →o α) (a : α)
    (h : BulkCertificate f a) :
    toDual a ≤ (boundaryMap f).gfp := by
  apply (boundaryMap f).le_gfp
  exact h

/-- Conversely, a boundary post-fixed witness recovers the ordinary bulk
induction conclusion. Thus the translation is an equivalence. -/
theorem transport_boundary_proof_to_bulk (f : α →o α) (a : α)
    (h : BoundaryCertificate f (toDual a)) :
    f.lfp ≤ a := by
  apply f.lfp_le
  exact h

end FixedPointDuality

section ProofComplexity

variable {α : Type u}

/-- A deliberately syntax-independent local proof trace. Dualization reverses
order-theoretic meaning but does not erase steps. -/
def dualTrace (xs : List α) : List αᵒᵈ := xs.map toDual

/-- Boundary dualization preserves trace length exactly. -/
theorem dualTrace_length (xs : List α) : (dualTrace xs).length = xs.length := by
  simp [dualTrace]

/-- **No strict-shortening theorem.** Every trace is a counterexample to the
claim that plain order dualization always produces a strictly shorter boundary
proof. -/
theorem strict_shortening_false (xs : List α) :
    ¬ (dualTrace xs).length < xs.length := by
  rw [dualTrace_length]
  exact Nat.lt_irrefl _

/-- The translation is lossless: dualizing a trace and returning to the bulk
recovers the original trace. -/
theorem dualTrace_lossless (xs : List α) :
    (dualTrace xs).map ofDual = xs := by
  simp [dualTrace]

end ProofComplexity

section DimensionalNoGo

/-- **Finite codimension no-go theorem.** Without additional structure, an
`n+1`-state bulk cannot be reconstructed from an `n`-state boundary. This
formally refutes any universal lossless “drop one dimension” principle based
only on state sets. -/
theorem no_lossless_codimension_one_encoding (n : ℕ) :
    ¬ ∃ encode : Fin (n + 1) → Fin n, Injective encode := by
  rintro ⟨encode, hencode⟩
  have hcard := Fintype.card_le_of_injective encode hencode
  simp only [Fintype.card_fin] at hcard
  omega

/-- The smallest explicit obstruction: a two-state bulk has no lossless map to
a one-state boundary. -/
theorem bit_not_reconstructible_from_unit_boundary :
    ¬ ∃ encode : Fin 2 → Fin 1, Injective encode := by
  simpa using no_lossless_codimension_one_encoding 1

end DimensionalNoGo

end HolographicProofDuality