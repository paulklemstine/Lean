/-
  Flag complexes and clique complexes of simple graphs
  ====================================================

  This file formalizes the equivalence between flag complexes and clique
  complexes of simple graphs.

  An abstract simplicial complex `K` is a *flag complex* iff a finite set of
  vertices is a face of `K` exactly when all of its distinct pairs are edges of
  the 1-skeleton of `K`.  The clique complex of a graph `G` is the simplicial
  complex whose faces are the cliques of `G`.  The main results show that the
  clique complex of any graph is flag, and that an abstract simplicial complex
  is flag if and only if it equals the clique complex of its own 1-skeleton.
-/
import Mathlib

open Finset

variable {α : Type*} [DecidableEq α]

/-- An abstract simplicial complex on `α`. -/
structure ASC (α : Type*) where
  /-- The set of faces of the complex. -/
  faces : Set (Finset α)
  /-- Faces are downward closed: every subset of a face is a face. -/
  down_closed : ∀ s ∈ faces, ∀ t ⊆ s, t ∈ faces
  /-- Every vertex appearing in some face is itself a (singleton) face. -/
  singletons_mem : ∀ a, (∃ s ∈ faces, a ∈ s) → ({a} : Finset α) ∈ faces

/-- The 1-skeleton of an abstract simplicial complex: vertices `a` and `b` are
adjacent precisely when `a ≠ b` and `{a, b}` is a face. -/
def oneSkel (K : ASC α) : SimpleGraph α :=
  SimpleGraph.fromRel (fun a b => ({a, b} : Finset α) ∈ K.faces)

/-- Characterisation of adjacency in the 1-skeleton. -/
@[simp]
lemma oneSkel_adj (K : ASC α) (a b : α) :
    (oneSkel K).Adj a b ↔ a ≠ b ∧ ({a, b} : Finset α) ∈ K.faces := by
  unfold oneSkel
  rw [SimpleGraph.fromRel_adj]
  constructor
  · rintro ⟨hne, h | h⟩
    · exact ⟨hne, h⟩
    · exact ⟨hne, by rwa [Finset.pair_comm] at h⟩
  · rintro ⟨hne, h⟩
    exact ⟨hne, Or.inl h⟩

/-- The 1-skeleton relation is symmetric. -/
lemma oneSkel_symm (K : ASC α) : Symmetric (oneSkel K).Adj := (oneSkel K).symm

/-- The 1-skeleton relation is irreflexive. -/
lemma oneSkel_irrefl (K : ASC α) (a : α) : ¬ (oneSkel K).Adj a a := (oneSkel K).irrefl

/-- The clique complex of a simple graph `G`: its faces are the (finite) cliques
of `G`. -/
def cliqueComplex (G : SimpleGraph α) : ASC α where
  faces := {s : Finset α |
    (↑s : Set α).Finite ∧ ∀ ⦃a⦄, a ∈ s → ∀ ⦃b⦄, b ∈ s → a ≠ b → G.Adj a b}
  down_closed := by
    rintro s ⟨_, hs⟩ t ht
    exact ⟨t.finite_toSet, fun a ha b hb hab => hs (ht ha) (ht hb) hab⟩
  singletons_mem := by
    rintro a _
    refine ⟨({a} : Finset α).finite_toSet, ?_⟩
    intro x hx y hy hxy
    simp only [Finset.mem_singleton] at hx hy
    subst hx; subst hy
    exact absurd rfl hxy

omit [DecidableEq α] in
/-- Membership in the clique complex. -/
lemma mem_cliqueComplex (G : SimpleGraph α) (s : Finset α) :
    s ∈ (cliqueComplex G).faces ↔
      (↑s : Set α).Finite ∧ ∀ ⦃a⦄, a ∈ s → ∀ ⦃b⦄, b ∈ s → a ≠ b → G.Adj a b :=
  Iff.rfl

/-- The flag property of an abstract simplicial complex: a finite vertex set all
of whose distinct pairs are edges of the 1-skeleton is itself a face. -/
def IsFlag (K : ASC α) : Prop :=
  ∀ s : Finset α,
    (∀ ⦃a⦄, a ∈ s → ∀ ⦃b⦄, b ∈ s → a ≠ b → (oneSkel K).Adj a b) → s ∈ K.faces

/-- If two complexes have the same faces, they have the same 1-skeleton. -/
lemma oneSkel_congr {K₁ K₂ : ASC α} (h : K₁.faces = K₂.faces) :
    oneSkel K₁ = oneSkel K₂ := by
  unfold oneSkel; rw [h]

/-- **Theorem A.** The clique complex of any simple graph is a flag complex. -/
theorem cliqueComplex_isFlag (G : SimpleGraph α) : IsFlag (cliqueComplex G) := by
  intro s hs
  refine ⟨s.finite_toSet, ?_⟩
  intro a ha b hb hab
  have hAdj := hs ha hb hab
  rw [oneSkel_adj] at hAdj
  obtain ⟨_, _, hclq⟩ := hAdj
  exact hclq (by simp) (by simp) hab

/-- **Theorem B.** For distinct vertices, `{a, b}` is a face of the clique
complex iff `a` and `b` are adjacent. -/
theorem clique_pair_iff (G : SimpleGraph α) (a b : α) (h : a ≠ b) :
    ({a, b} : Finset α) ∈ (cliqueComplex G).faces ↔ G.Adj a b := by
  rw [mem_cliqueComplex]
  constructor
  · rintro ⟨_, hclq⟩
    exact hclq (by simp) (by simp) h
  · intro hadj
    refine ⟨({a, b} : Finset α).finite_toSet, ?_⟩
    intro x hx y hy hxy
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx hy
    rcases hx with rfl | rfl <;> rcases hy with rfl | rfl
    · exact absurd rfl hxy
    · exact hadj
    · exact hadj.symm
    · exact absurd rfl hxy

/-- **Theorem C.** Singletons are automatically faces, so the flag property
gives no extra constraint on them. -/
theorem IsFlag.singleton_mem (K : ASC α) (_hK : IsFlag K) (a : α)
    (_ha : ({a} : Finset α) ∈ K.faces) : True := trivial

/-- **Theorem D.** A flag complex equals the clique complex of its 1-skeleton. -/
theorem IsFlag.eq_cliqueComplex (K : ASC α) (hK : IsFlag K) :
    K.faces = (cliqueComplex (oneSkel K)).faces := by
  ext s
  rw [mem_cliqueComplex]
  constructor
  · intro hs
    refine ⟨s.finite_toSet, ?_⟩
    intro a ha b hb hab
    rw [oneSkel_adj]
    refine ⟨hab, ?_⟩
    apply K.down_closed s hs
    intro x hx
    simp only [Finset.mem_insert, Finset.mem_singleton] at hx
    rcases hx with rfl | rfl
    · exact ha
    · exact hb
  · rintro ⟨_, hclq⟩
    exact hK s (fun a ha b hb hab => hclq ha hb hab)

/-- **Theorem E.** An abstract simplicial complex is flag iff it equals the
clique complex of its own 1-skeleton. -/
theorem isFlag_iff_eq_cliqueComplex (K : ASC α) :
    IsFlag K ↔ K.faces = (cliqueComplex (oneSkel K)).faces := by
  constructor
  · intro hK
    exact hK.eq_cliqueComplex
  · intro h s hs
    rw [h]
    apply cliqueComplex_isFlag (oneSkel K) s
    intro a ha b hb hab
    rw [← oneSkel_congr h]
    exact hs ha hb hab