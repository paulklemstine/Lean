import Mathlib

/-!
# Oddomorphisms of finite graphs

This file develops a self-contained formalization of **oddomorphisms** between finite
graphs, a notion arising in the study of homomorphism indistinguishability and
quantum isomorphism (`roberson2022oddomorphisms`, `mancinska2020quantum`; the
underlying algebra of graph operations goes back to `lovasz1967operations`).

## The definition

Fix finite graphs `F` and `G` with adjacency matrices `A_F`, `A_G` taken over the
field `ZMod 2 = GF(2)`.  A function `φ : V(F) → V(G)` is represented by its
`0/1` *function matrix* `funMatrix φ`, the `V(F) × V(G)` matrix whose `(u, a)` entry
is `1` iff `φ u = a` (each **row** has exactly one `1`).

An **oddomorphism** from `F` to `G` is a function `φ` whose function matrix
intertwines the two adjacency matrices over `GF(2)`:
```
A_F * funMatrix φ = funMatrix φ * A_G     (over ZMod 2).
```
Entrywise (`isOddomorphism_iff_parity`) this says: for every vertex `u` of `F` and
every vertex `a` of `G`, the number of neighbours of `u` in `F` that `φ` sends to `a`
is **odd** iff `φ u` is adjacent to `a` in `G`.  This local parity condition is the
"mod-2 homomorphism" condition that gives oddomorphisms their name.

## Main results

* `funMatrix_mul` : the function matrix is (contravariantly) functorial:
  `funMatrix φ * funMatrix ψ = funMatrix (ψ ∘ φ)`.
* `isOddomorphism_id` : the identity is an oddomorphism (reflexivity).
* `IsOddomorphism.comp` : oddomorphisms compose (transitivity).
* `Oddomorphic` is therefore a **preorder** on graphs over a fixed vertex type
  (`oddomorphic_refl`, `oddomorphic_trans`, `oddomorphicPreorder`).
* `SimpleGraph.Iso.isOddomorphism` : every graph isomorphism is an oddomorphism,
  so isomorphic graphs are oddomorphism-equivalent (`oddomorphic_of_iso`).
* `isOddomorphism_iff_parity` : the transparent local parity characterization.

These establish the algebraic backbone of the oddomorphism relation.  The full
conjectural equivalence "there is an oddomorphism `F → G` iff `G` is a split-off
minor of `F`" has its forward direction in the literature and its converse open;
here we isolate and prove the structural (category / preorder) properties of the
oddomorphism side, together with the concrete local characterization.
-/

open scoped Classical

namespace OddomorphismSplitMinor

/-- The `0/1` matrix over `GF(2) = ZMod 2` of a function `φ : α → β`; the `(u, a)`
entry is `1` iff `φ u = a`. Each row has exactly one `1`. -/
def funMatrix {α β : Type*} [DecidableEq β] (φ : α → β) :
    Matrix α β (ZMod 2) :=
  Matrix.of (fun u a => if φ u = a then 1 else 0)

@[simp] lemma funMatrix_apply {α β : Type*} [DecidableEq β] (φ : α → β) (u : α) (a : β) :
    funMatrix φ u a = if φ u = a then 1 else 0 := rfl

/-- The function matrix is contravariantly functorial: composing functions
corresponds to multiplying their matrices. -/
lemma funMatrix_mul {α β γ : Type*} [Fintype β] [DecidableEq β] [DecidableEq γ]
    (φ : α → β) (ψ : β → γ) :
    funMatrix φ * funMatrix ψ = funMatrix (ψ ∘ φ) := by
  ext u c
  simp only [funMatrix, Matrix.mul_apply, Matrix.of_apply]
  rw [Finset.sum_eq_single (φ u)]
  · simp
  · intro b _ hb
    have : φ u ≠ b := fun h => hb h.symm
    simp [this]
  · intro h; simp at h

/-- The identity function has the identity matrix. -/
@[simp] lemma funMatrix_id {α : Type*} [DecidableEq α] :
    funMatrix (id : α → α) = (1 : Matrix α α (ZMod 2)) := by
  ext u a
  simp only [funMatrix, Matrix.of_apply, id_eq, Matrix.one_apply]

/-- Entrywise formula for `A_F * funMatrix φ`: the `(u, a)` entry is the mod-2 count
of neighbours of `u` in `F` that `φ` maps to `a`. -/
lemma adjMatrix_mul_funMatrix_apply {VF VG : Type*} [Fintype VF] [DecidableEq VG]
    (F : SimpleGraph VF) [DecidableRel F.Adj] (φ : VF → VG) (u : VF) (a : VG) :
    (F.adjMatrix (ZMod 2) * funMatrix φ) u a
      = ∑ v, if F.Adj u v ∧ φ v = a then (1 : ZMod 2) else 0 := by
  simp only [Matrix.mul_apply, SimpleGraph.adjMatrix_apply, funMatrix, Matrix.of_apply]
  apply Finset.sum_congr rfl
  intro v _
  by_cases h : F.Adj u v <;> by_cases h2 : φ v = a <;> simp [h, h2]

/-- Entrywise formula for `funMatrix φ * A_G`: the `(u, a)` entry is `1` iff `φ u` is
adjacent to `a` in `G`. -/
lemma funMatrix_mul_adjMatrix_apply {VF VG : Type*} [Fintype VG] [DecidableEq VG]
    (G : SimpleGraph VG) [DecidableRel G.Adj] (φ : VF → VG) (u : VF) (a : VG) :
    (funMatrix φ * G.adjMatrix (ZMod 2)) u a
      = if G.Adj (φ u) a then (1 : ZMod 2) else 0 := by
  simp only [Matrix.mul_apply, SimpleGraph.adjMatrix_apply, funMatrix, Matrix.of_apply]
  rw [Finset.sum_eq_single (φ u)]
  · simp
  · intro b _ hb; simp [Ne.symm hb]
  · intro h; simp at h

variable {VF VG VH : Type*}
  [Fintype VF] [Fintype VG] [Fintype VH]
  [DecidableEq VF] [DecidableEq VG] [DecidableEq VH]

/-- An **oddomorphism** from a finite graph `F` to a finite graph `G`: a function
`φ : V(F) → V(G)` whose function matrix intertwines the two adjacency matrices over
`GF(2)`. -/
structure IsOddomorphism (F : SimpleGraph VF) (G : SimpleGraph VG)
    [DecidableRel F.Adj] [DecidableRel G.Adj] (φ : VF → VG) : Prop where
  intertwine :
    F.adjMatrix (ZMod 2) * funMatrix φ = funMatrix φ * G.adjMatrix (ZMod 2)

/-- Reflexivity: the identity map is an oddomorphism. -/
theorem isOddomorphism_id (F : SimpleGraph VF) [DecidableRel F.Adj] :
    IsOddomorphism F F id :=
  ⟨by simp⟩

omit [DecidableEq VF] in
/-- Transitivity: oddomorphisms compose. -/
theorem IsOddomorphism.comp
    {F : SimpleGraph VF} {G : SimpleGraph VG} {H : SimpleGraph VH}
    [DecidableRel F.Adj] [DecidableRel G.Adj] [DecidableRel H.Adj]
    {φ : VF → VG} {ψ : VG → VH}
    (hφ : IsOddomorphism F G φ) (hψ : IsOddomorphism G H ψ) :
    IsOddomorphism F H (ψ ∘ φ) := by
  refine ⟨?_⟩
  rw [← funMatrix_mul]
  calc F.adjMatrix (ZMod 2) * (funMatrix φ * funMatrix ψ)
      = (F.adjMatrix (ZMod 2) * funMatrix φ) * funMatrix ψ := by rw [Matrix.mul_assoc]
    _ = (funMatrix φ * G.adjMatrix (ZMod 2)) * funMatrix ψ := by rw [hφ.intertwine]
    _ = funMatrix φ * (G.adjMatrix (ZMod 2) * funMatrix ψ) := by rw [Matrix.mul_assoc]
    _ = funMatrix φ * (funMatrix ψ * H.adjMatrix (ZMod 2)) := by rw [hψ.intertwine]
    _ = (funMatrix φ * funMatrix ψ) * H.adjMatrix (ZMod 2) := by rw [Matrix.mul_assoc]

omit [DecidableEq VF] in
/-- The transparent **local parity** characterization: `φ` is an oddomorphism iff for
every vertex `u` of `F` and vertex `a` of `G`, the mod-2 count of neighbours of `u`
mapped by `φ` to `a` equals `1` exactly when `φ u` is adjacent to `a` in `G`. -/
theorem isOddomorphism_iff_parity
    (F : SimpleGraph VF) (G : SimpleGraph VG)
    [DecidableRel F.Adj] [DecidableRel G.Adj] (φ : VF → VG) :
    IsOddomorphism F G φ ↔
      ∀ u a, (∑ v, if F.Adj u v ∧ φ v = a then (1 : ZMod 2) else 0)
        = if G.Adj (φ u) a then (1 : ZMod 2) else 0 := by
  constructor
  · rintro ⟨h⟩ u a
    have h2 := congrFun (congrFun h u) a
    rwa [adjMatrix_mul_funMatrix_apply, funMatrix_mul_adjMatrix_apply] at h2
  · intro h
    refine ⟨?_⟩
    ext u a
    rw [adjMatrix_mul_funMatrix_apply, funMatrix_mul_adjMatrix_apply]
    exact h u a

/-- `Oddomorphic F G` : there exists an oddomorphism from `F` to `G`.
For a preorder we consider graphs on a fixed finite vertex type. -/
def Oddomorphic (F G : SimpleGraph VF) [DecidableRel F.Adj] [DecidableRel G.Adj] :
    Prop :=
  ∃ φ : VF → VF, IsOddomorphism F G φ

theorem oddomorphic_refl (F : SimpleGraph VF) [DecidableRel F.Adj] :
    Oddomorphic F F :=
  ⟨id, isOddomorphism_id F⟩

theorem oddomorphic_trans {F G H : SimpleGraph VF}
    [DecidableRel F.Adj] [DecidableRel G.Adj] [DecidableRel H.Adj]
    (hFG : Oddomorphic F G) (hGH : Oddomorphic G H) : Oddomorphic F H := by
  obtain ⟨φ, hφ⟩ := hFG
  obtain ⟨ψ, hψ⟩ := hGH
  exact ⟨ψ ∘ φ, hφ.comp hψ⟩

/-- The oddomorphism relation is a preorder on graphs over a fixed finite vertex type
(using classical decidability of adjacency). -/
noncomputable def oddomorphicPreorder : Preorder (SimpleGraph VF) where
  le F G := Oddomorphic F G
  lt F G := Oddomorphic F G ∧ ¬ Oddomorphic G F
  le_refl F := oddomorphic_refl F
  le_trans _ _ _ hFG hGH := oddomorphic_trans hFG hGH
  lt_iff_le_not_ge _ _ := Iff.rfl

omit [DecidableEq VF] in
/-- Every graph isomorphism is an oddomorphism. -/
theorem isOddomorphism_of_iso {F : SimpleGraph VF} {G : SimpleGraph VG}
    [DecidableRel F.Adj] [DecidableRel G.Adj] (e : F ≃g G) :
    IsOddomorphism F G (e : VF → VG) := by
  refine ⟨?_⟩
  ext u y
  rw [adjMatrix_mul_funMatrix_apply, funMatrix_mul_adjMatrix_apply]
  rw [Finset.sum_eq_single (e.symm y)]
  · simp only [RelIso.apply_symm_apply, and_true]
    have hiff : F.Adj u (e.symm y) ↔ G.Adj (e u) y := by
      rw [← e.map_adj_iff, RelIso.apply_symm_apply]
    by_cases h : G.Adj (e u) y <;> simp [h, hiff]
  · intro b _ hb
    have : ¬ (e b = y) := fun h => hb (by rw [← h]; simp)
    simp [this]
  · intro h; simp at h

/-- Isomorphic graphs are oddomorphism-equivalent (both directions hold). -/
theorem oddomorphic_of_iso {F G : SimpleGraph VF}
    [DecidableRel F.Adj] [DecidableRel G.Adj] (e : F ≃g G) :
    Oddomorphic F G ∧ Oddomorphic G F :=
  ⟨⟨(e : VF → VF), isOddomorphism_of_iso e⟩,
    ⟨(e.symm : VF → VF), isOddomorphism_of_iso e.symm⟩⟩

/-- Every graph automorphism is a self-oddomorphism. -/
theorem isOddomorphism_of_aut (F : SimpleGraph VF) [DecidableRel F.Adj]
    (e : F ≃g F) : IsOddomorphism F F (e : VF → VF) :=
  isOddomorphism_of_iso e

/-- The **self-oddomorphisms** of a fixed graph `F` form a submonoid of the monoid
`Function.End (V F)` of all self-maps under composition: the identity is a
self-oddomorphism and the composite of two self-oddomorphisms is one. -/
def oddEndSubmonoid (F : SimpleGraph VF) [DecidableRel F.Adj] :
    Submonoid (Function.End VF) where
  carrier := {φ | IsOddomorphism F F φ}
  one_mem' := isOddomorphism_id F
  mul_mem' := fun ha hb => IsOddomorphism.comp hb ha

@[simp] lemma mem_oddEndSubmonoid (F : SimpleGraph VF) [DecidableRel F.Adj]
    (φ : Function.End VF) :
    φ ∈ oddEndSubmonoid F ↔ IsOddomorphism F F φ := Iff.rfl

end OddomorphismSplitMinor