/-
Copyright (c) 2026. All rights reserved.

# Stability of Cayley Digraphs — The Expected-Automorphism Embedding

This file develops a Lean framework for the *stability* of Cayley digraphs and
proves the universally valid half of the stability statement: the **expected
automorphisms always embed**.

## Setting

For a finite abelian group `G` and a connection set `S ⊆ G`, the Cayley digraph
`Cay(G, S)` has vertex set `G` and an arc `g → h` whenever `h - g ∈ S`
(`cayAdj`).  The *tensor product with the complete digraph `K₂`* (equivalently,
the bipartite double cover) has vertex set `G × Bool` with an arc
`(g,a) → (h,b)` whenever `h - g ∈ S` and `a ≠ b` (`dcAdj`).

A digraph `X` is **stable** when `Aut(X ⊗ K₂) ≅ Aut(X) × Aut(K₂)`.  Since
`Aut(K₂) = Sym(Bool) = Equiv.Perm Bool`, there is a canonical homomorphism
`expectedHom : Aut(Cay(G,S)) × Perm Bool →* Aut(Cay(G,S) ⊗ K₂)` given by
`(σ, π) ↦ σ ×ₚ π`.  Stability is precisely the assertion that this map is an
*isomorphism*; one direction — injectivity — holds for **every** digraph and is
the content of `expectedHom_injective`.

We additionally show (`dcCayleyIso`) that the double cover is itself a Cayley
digraph, over the group `G × ℤ/2` with connection set `S × {1}`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The map sending an automorphism `σ` of the base
digraph and a permutation `π` of the two layers to the product permutation
`σ ×ₚ π` of the double cover is an injective group homomorphism into the
automorphism group of the double cover, for *every* connection set (no oddness,
connectivity, or twin-freeness needed).

Experiment (Experimenter): Formalised `AutRel` (the automorphism group of a
relation, as a subgroup of `Equiv.Perm`), proved `prodCongr_mem` (product
permutations are automorphisms of the double cover) and bundled the map into
`expectedHom`.  Injectivity reduces to evaluating at `(g, false)` and `(0, b)`.

Analysis (Analyst): Injectivity needs `Nonempty G` (supplied by the additive
identity) to recover the `Perm Bool` factor; without a base vertex the second
factor cannot be detected.  The product structure also reveals the double cover
*is* a Cayley digraph over `G × ℤ/2` — recorded as `dcCayleyIso`.

Critique (Critic): The statements use real group/permutation machinery
(`Subgroup`, `MonoidHom`, `prodCongr`), evaluation arguments, and are not
definitional.  Surjectivity of `expectedHom` — the *hard* half, true exactly for
connected twin-free Cayley digraphs of odd order — is deliberately NOT claimed
here; it is studied in `OddOrderNecessity.lean` where the odd-order hypothesis
is shown to be necessary.

Synthesis (PI): `expectedHom_injective` is the universal backbone of any
stability proof; `dcCayleyIso` shows the double cover stays inside the same
category of objects, enabling inductive/structural attacks on the open half.
-- !-- end Lab Notes -- !--
-/
import Mathlib

open Equiv

namespace CayleyStability

variable {G : Type*} [AddCommGroup G]

/-- Adjacency of the Cayley digraph `Cay(G, S)`: an arc `g → h` exists iff
`h - g ∈ S`. -/
def cayAdj (S : Set G) (g h : G) : Prop := h - g ∈ S

/-- Adjacency of the tensor product `Cay(G, S) ⊗ K₂` (the bipartite double
cover): an arc `(g,a) → (h,b)` exists iff `h - g ∈ S` and `a ≠ b`. -/
def dcAdj (S : Set G) (p q : G × Bool) : Prop := (q.1 - p.1 ∈ S) ∧ (p.2 ≠ q.2)

/-- The automorphism group of a binary relation `r`, realised as a subgroup of
the permutation group of the vertex set. -/
def AutRel {V : Type*} (r : V → V → Prop) : Subgroup (Equiv.Perm V) where
  carrier := {σ | ∀ a b, r (σ a) (σ b) ↔ r a b}
  one_mem' := by intro a b; simp
  mul_mem' := by
    intro σ τ hσ hτ a b
    simp only [Equiv.Perm.coe_mul, Function.comp_apply]
    rw [hσ, hτ]
  inv_mem' := by
    intro σ hσ a b
    have h := hσ (σ⁻¹ a) (σ⁻¹ b)
    simpa using h.symm

@[simp] lemma mem_AutRel {V : Type*} (r : V → V → Prop) (σ : Equiv.Perm V) :
    σ ∈ AutRel r ↔ ∀ a b, r (σ a) (σ b) ↔ r a b := Iff.rfl

/-- A product permutation `σ ×ₚ π` (with `σ` an automorphism of the base
digraph and `π` an arbitrary permutation of the two layers) is an automorphism
of the double cover. -/
lemma prodCongr_mem (S : Set G) (σ : Equiv.Perm G) (π : Equiv.Perm Bool)
    (hσ : σ ∈ AutRel (cayAdj S)) : σ.prodCongr π ∈ AutRel (dcAdj S) := by
  intro a b
  have hkey := hσ a.1 b.1
  simp only [cayAdj] at hkey
  simp only [dcAdj, Equiv.prodCongr_apply, Prod.map_fst, Prod.map_snd]
  rw [hkey]
  exact ⟨fun ⟨h1, h2⟩ => ⟨h1, fun h => h2 (by rw [h])⟩,
         fun ⟨h1, h2⟩ => ⟨h1, fun h => h2 (π.injective h)⟩⟩

/-- The canonical embedding of the *expected* automorphism group
`Aut(Cay(G,S)) × Aut(K₂)` into `Aut(Cay(G,S) ⊗ K₂)`, sending `(σ, π)` to the
product permutation `σ ×ₚ π`.  Stability of `Cay(G,S)` is the assertion that
this homomorphism is surjective. -/
def expectedHom (S : Set G) :
    (AutRel (cayAdj S)) × (Equiv.Perm Bool) →* (AutRel (dcAdj S)) where
  toFun p := ⟨(p.1 : Equiv.Perm G).prodCongr p.2, prodCongr_mem S _ _ p.1.2⟩
  map_one' := by apply Subtype.ext; ext x <;> simp
  map_mul' a b := by apply Subtype.ext; ext x <;> simp [Subgroup.coe_mul]

/-- **Main theorem (universal embedding).**  The expected-automorphism
homomorphism is injective, for every finite abelian group and every connection
set.  This is the always-valid half of stability. -/
theorem expectedHom_injective (S : Set G) : Function.Injective (expectedHom S) := by
  rintro ⟨⟨σ, hσ⟩, π⟩ ⟨⟨σ', hσ'⟩, π'⟩ h
  simp only [expectedHom, MonoidHom.coe_mk, OneHom.coe_mk, Subtype.mk.injEq] at h
  have key : ∀ g b, ((σ.prodCongr π) (g, b) : G × Bool) = (σ'.prodCongr π') (g, b) :=
    fun g b => by rw [h]
  have e1 : σ = σ' := by
    ext g; have := key g false; simp [Equiv.prodCongr_apply] at this; exact this.1
  have e2 : π = π' := by
    ext b; have := key 0 b; simp [Equiv.prodCongr_apply] at this; exact this.2
  subst e1; subst e2; rfl

/-- `Bool ≃ ZMod 2`, sending `false ↦ 0` and `true ↦ 1`. -/
def boolEquivZMod2 : Bool ≃ ZMod 2 where
  toFun b := if b then 1 else 0
  invFun z := z = 1
  left_inv := by decide
  right_inv := by decide

/-- Connection set realising the double cover as a Cayley digraph over `G × ℤ/2`. -/
def dcConn (S : Set G) : Set (G × ZMod 2) := {p | p.1 ∈ S ∧ p.2 = 1}

/-- **Structural theorem.**  The bipartite double cover of `Cay(G, S)` is itself
a Cayley digraph: the relation `dcAdj S` on `G × Bool` is isomorphic to the
Cayley digraph of the group `G × ℤ/2` with connection set `S × {1}`. -/
def dcCayleyIso (S : Set G) :
    {f : (G × Bool) ≃ (G × ZMod 2) //
      ∀ p q, dcAdj S p q ↔ cayAdj (dcConn S) (f p) (f q)} :=
  ⟨Equiv.prodCongr (Equiv.refl G) boolEquivZMod2, by
    intro p q
    simp only [dcAdj, cayAdj, dcConn, Equiv.prodCongr_apply, Prod.map_fst, Prod.map_snd,
      Set.mem_setOf_eq, Prod.fst_sub, Prod.snd_sub]
    constructor
    · rintro ⟨h1, h2⟩
      exact ⟨h1, by revert h2; cases p.2 <;> cases q.2 <;> decide⟩
    · rintro ⟨h1, h2⟩
      exact ⟨h1, by revert h2; cases p.2 <;> cases q.2 <;> decide⟩⟩

end CayleyStability