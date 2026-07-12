/-
Copyright (c) 2025. All rights reserved.

# Analogy on the Concept Lattice — the Adjoint (Galois) Model

Hofstadter's *Copycat* operates on a lattice of concepts.  In formal concept
analysis, the canonical structure-preserving analogy between two concept
lattices is a **Galois connection** `l ⊣ u`.  This file develops the adjoint
model of analogy: an analogy is *optimal* precisely when the round-trips
`u ∘ l` and `l ∘ u` are stable (closure / kernel operators), and the backward
map is then uniquely determined by the forward map.

## Main results

* `adjointAnalogy_extensive`      — `a ≤ u (l a)`: the concept is refined by the round trip.
* `adjointAnalogy_stable_closure` — `u ∘ l` is idempotent (a closure operator).
* `adjointAnalogy_stable_kernel`  — `l ∘ u` is idempotent (a kernel operator).
* `adjointAnalogy_monotone`       — the round trip `u ∘ l` is monotone.
* `adjoint_unique`                — **the inverse of an adjoint analogy is unique**:
  a given forward map has at most one adjoint backward map.
* `copycat_isAdjoint`             — the identity ("copycat") analogy on a single
  concept lattice is an adjoint analogy.
* `copycat_roundtrip_id`          — the copycat round trip is the identity (zero distortion).
-/
import Mathlib

namespace TropicalAnalogy

variable {L M : Type*}

/-- An **adjoint analogy** between concept (pre)orders `L` and `M` is a Galois
connection: monotone maps `l : L → M`, `u : M → L` with `l a ≤ b ↔ a ≤ u b`. -/
abbrev AdjointAnalogy [Preorder L] [Preorder M] (l : L → M) (u : M → L) : Prop :=
  GaloisConnection l u

/-
Every concept is refined by the analogical round trip: `a ≤ u (l a)`.
-/
theorem adjointAnalogy_extensive [Preorder L] [Preorder M]
    {l : L → M} {u : M → L} (h : AdjointAnalogy l u) (a : L) :
    a ≤ u (l a) := by
  exact h.le_iff_le.1 le_rfl

/-
The round trip `u ∘ l` of an adjoint analogy is **idempotent**: applying the
analogy twice gives the same refined concept as applying it once.  This is the
formal statement that `u ∘ l` is a closure operator.
-/
theorem adjointAnalogy_stable_closure [PartialOrder L] [Preorder M]
    {l : L → M} {u : M → L} (h : AdjointAnalogy l u) (a : L) :
    u (l (u (l a))) = u (l a) := by
  apply h.u_l_u_eq_u

/-
Dually, `l ∘ u` is idempotent (a kernel/interior operator).
-/
theorem adjointAnalogy_stable_kernel [Preorder L] [PartialOrder M]
    {l : L → M} {u : M → L} (h : AdjointAnalogy l u) (b : M) :
    l (u (l (u b))) = l (u b) := by
  apply h.l_u_l_eq_l

/-
The analogical round trip `u ∘ l` is monotone.
-/
theorem adjointAnalogy_monotone [Preorder L] [Preorder M]
    {l : L → M} {u : M → L} (h : AdjointAnalogy l u) :
    Monotone (u ∘ l) := by
  exact h.monotone_u.comp h.monotone_l

/-
**Uniqueness of the adjoint (the "best" backward analogy is unique).**
If a forward analogy `l` admits two adjoint backward maps `u₁` and `u₂`, they
must coincide.  So the optimal inverse of an analogy, when it exists, is
determined by the forward map.
-/
theorem adjoint_unique [PartialOrder L] [PartialOrder M]
    {l : L → M} {u₁ u₂ : M → L}
    (h₁ : AdjointAnalogy l u₁) (h₂ : AdjointAnalogy l u₂) : u₁ = u₂ := by
  ext b; exact le_antisymm ( by
    exact h₂ _ _ |>.1 ( h₁ _ _ |>.2 le_rfl ) ) ( by
    exact h₁ _ _ |>.1 ( h₂.l_u_le _ ) ) ;

/-
**The copycat analogy is an adjoint analogy.**  On a single concept lattice
`L`, the identity-on-both-sides analogy is a Galois connection.
-/
theorem copycat_isAdjoint [Preorder L] :
    AdjointAnalogy (@id L) (@id L) := by
  exact fun a b => Iff.rfl

/-
**The copycat analogy is rigid.**  On a concept lattice `L`, the copycat's
forward map (the identity) admits a *unique* adjoint backward map, namely the
identity itself.  Combined with `copycat_isAdjoint` this says the identity is
its own unique adjoint: the copycat is a perfect, self-dual analogy of a
lattice with itself (zero distortion, `u ∘ l = id`).
-/
theorem copycat_adjoint_unique [PartialOrder L] {u : L → L}
    (h : AdjointAnalogy (@id L) u) : u = id := by
  convert adjoint_unique ?_ ?_;
  exacts [ inferInstance, inferInstance, id, h, copycat_isAdjoint ]

end TropicalAnalogy