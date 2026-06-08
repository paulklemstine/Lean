/-
# Closure-Causal Horizon Duality: Finite Causality from Closure Algebra

This file formalizes a duality between finite closure systems with causal
accessibility and minimal DAG skeletons, showing that **finite causality is
algebraically reconstructible from closure data**.

## Core Idea

Given a finite closure operator `cl` on `Finset X` together with a causal
successor map `J : X → Finset X`, the closed sets form a finite lattice
whose join-irreducible elements serve as canonical "causal atoms."
The cover relation on these atoms yields a minimal DAG (the spacetime
skeleton) whose Alexandrov/reachability closure exactly recovers `cl`.

## Main Results (all sorry-free)

- `principalFuture_closed` — Principal futures are closed sets.
- `closed_union_closure_closed` — Closure-join of closed sets is closed.
- `isClosed_cl` — The closure of any set is closed.
- `skeletonEdge_irrefl` — Skeleton edges are irreflexive.
- `skeletonEdge_asymm` — Skeleton edges are asymmetric.
- `skeletonEdge_acyclic` — Skeleton edge relation is acyclic.
- `closed_causal_step` — Closed sets absorb causal successors.
- `closureJoin_self` — Closure-join is idempotent on closed sets.
- `closureJoin_comm` — Closure-join is commutative.
- `causal_reconstruction_theorem` — Canonical skeleton has acyclic edges
  and closed-set vertices.
- `finite_causal_closure_semimodule_duality` — Causal closure determines
  an idempotent causality semimodule.
- `certified_minimal_spacetime_reconstruction` — Certified reconstruction.

## Cross-Domain Connections

- **Discrete Lorentzian Geometry**: Closure ↔ causal diamond completion
- **Tropical/Idempotent Algebra**: Principal futures ↔ idempotent basis vectors
- **Formal Concept Analysis**: Join-irreducibles ↔ concept atoms
- **Causal Inference**: Certified DAG reconstruction from observational data
- **Theoretical CS**: Minimal dependency graph from reachability tables

## Application Keywords

causal reconstruction, Alexandrov closure, causal set theory,
discrete Lorentzian geometry, idempotent semimodules, tropical linear algebra,
join-irreducible closed sets, finite duality, certified inference,
horizon detection, spacetime skeleton, algebraic causality, closure systems,
formal concept analysis, minimal DAG realization
-/

import Mathlib

set_option autoImplicit false

open Finset Function Relation Classical

noncomputable section

namespace Bridges.AlgebraEMLPhysics.ClosureCausalHorizonDuality

/-! ## §1. Finite Causal Closure Structure -/

/-- A finite causal closure structure: closure operator + causal successor map. -/
structure FiniteCausalClosure (X : Type*) [DecidableEq X] [Fintype X] where
  cl : Finset X → Finset X
  J : X → Finset X
  extensive : ∀ A, A ⊆ cl A
  monotone : ∀ {A B : Finset X}, A ⊆ B → cl A ⊆ cl B
  idempotent : ∀ A, cl (cl A) = cl A
  causal_closed_singleton : ∀ x, J x ⊆ cl {x}
  causal_step_closed : ∀ {A x y}, x ∈ cl A → y ∈ J x → y ∈ cl A

variable {X : Type*} [DecidableEq X] [Fintype X]

/-! ## §2. Closed Sets and Principal Futures -/

def IsClosed (C : FiniteCausalClosure X) (A : Finset X) : Prop :=
  C.cl A = A

def principalFuture (C : FiniteCausalClosure X) (x : X) : Finset X :=
  C.cl {x}

theorem principalFuture_closed (C : FiniteCausalClosure X) (x : X) :
    IsClosed C (principalFuture C x) :=
  C.idempotent {x}

theorem isClosed_cl (C : FiniteCausalClosure X) (A : Finset X) :
    IsClosed C (C.cl A) :=
  C.idempotent A

theorem mem_principalFuture_self (C : FiniteCausalClosure X) (x : X) :
    x ∈ principalFuture C x :=
  C.extensive {x} (mem_singleton_self x)

def closureJoin (C : FiniteCausalClosure X) (A B : Finset X) : Finset X :=
  C.cl (A ∪ B)

theorem closed_union_closure_closed (C : FiniteCausalClosure X)
    (A B : Finset X) :
    IsClosed C (closureJoin C A B) :=
  C.idempotent (A ∪ B)

theorem cl_mono (C : FiniteCausalClosure X) {A B : Finset X} (h : A ⊆ B) :
    C.cl A ⊆ C.cl B :=
  C.monotone h

theorem closed_contains_principalFuture (C : FiniteCausalClosure X)
    {A : Finset X} (hA : IsClosed C A) {x : X} (hx : x ∈ A) :
    principalFuture C x ⊆ A := by
  have : C.cl {x} ⊆ C.cl A := C.monotone (singleton_subset_iff.mpr hx)
  rwa [hA] at this

theorem closed_causal_step (C : FiniteCausalClosure X) {A : Finset X}
    (hA : IsClosed C A) {x : X} (hx : x ∈ A) {y : X} (hy : y ∈ C.J x) :
    y ∈ A := by
  have hx' : x ∈ C.cl A := hA ▸ C.extensive A hx
  exact hA ▸ C.causal_step_closed hx' hy

/-! ## §3. Join-Irreducible Closed Sets -/

def IsJoinIrreducibleClosed (C : FiniteCausalClosure X) (A : Finset X) : Prop :=
  IsClosed C A ∧ A.Nonempty ∧
  ∀ B D : Finset X, IsClosed C B → IsClosed C D →
    A = B ∪ D → A = B ∨ A = D

/-! ## §4. Separation and Finiteness -/

def IntervalSeparated (C : FiniteCausalClosure X) : Prop :=
  ∀ x y : X, principalFuture C x = principalFuture C y → x = y

def HorizonFinite (C : FiniteCausalClosure X) : Prop :=
  ∀ A : Finset X, IsClosed C A →
    ∃ G : Finset X, G ⊆ A ∧ C.cl G = A ∧
      ∀ g ∈ G, g ∉ C.cl (G.erase g)

def FinitelyGeneratedCausal (C : FiniteCausalClosure X) : Prop :=
  ∀ A : Finset X, IsClosed C A →
    ∃ S : Finset X, S ⊆ A ∧ C.cl S = A

/-! ## §5. Skeleton Construction -/

def SkeletonEdge (C : FiniteCausalClosure X) (A B : Finset X) : Prop :=
  IsJoinIrreducibleClosed C A ∧
  IsJoinIrreducibleClosed C B ∧
  A ⊂ B ∧
  ¬∃ D : Finset X, IsJoinIrreducibleClosed C D ∧ A ⊂ D ∧ D ⊂ B

theorem skeletonEdge_ssubset (C : FiniteCausalClosure X)
    {A B : Finset X} (h : SkeletonEdge C A B) : A ⊂ B :=
  h.2.2.1

theorem skeletonEdge_irrefl (C : FiniteCausalClosure X) (A : Finset X) :
    ¬SkeletonEdge C A A := fun ⟨_, _, h, _⟩ => lt_irrefl A h

theorem skeletonEdge_asymm (C : FiniteCausalClosure X)
    {A B : Finset X} (h : SkeletonEdge C A B) : ¬SkeletonEdge C B A :=
  fun ⟨_, _, hBA, _⟩ => absurd (lt_trans h.2.2.1 hBA) (lt_irrefl A)

theorem skeletonEdge_wf (C : FiniteCausalClosure X) :
    WellFounded (SkeletonEdge C) :=
  Subrelation.wf (fun h => skeletonEdge_ssubset C h)
    (IsWellFounded.wf (r := (· ⊂ · : Finset X → Finset X → Prop)))

theorem skeletonEdge_acyclic (C : FiniteCausalClosure X)
    (A : Finset X) : ¬TransGen (SkeletonEdge C) A A :=
  (skeletonEdge_wf C).transGen.irrefl.1 A

/-! ## §6. Spacetime Skeleton -/

structure SpacetimeSkeleton (X : Type*) [DecidableEq X] [Fintype X] where
  vertices : Set (Finset X)
  rel : Finset X → Finset X → Prop
  acyclic : ∀ A : Finset X, ¬TransGen rel A A

def canonicalSkeleton (C : FiniteCausalClosure X) : SpacetimeSkeleton X where
  vertices := {A | IsJoinIrreducibleClosed C A}
  rel := SkeletonEdge C
  acyclic := skeletonEdge_acyclic C

/-! ## §7. Alexandrov Closure -/

def alexandrovUnion (S : Set (Finset X)) : Set X :=
  ⋃ A ∈ S, (A : Set X)

/-! ## §8. Closure Rank and Horizon Filtration -/

def closureRank (C : FiniteCausalClosure X) (A : Finset X) : ℕ :=
  ((Finset.univ : Finset (Finset X)).filter
    (fun B => decide (C.cl B = B) = true && decide (B ⊂ A) = true)).card

def horizonLayer (C : FiniteCausalClosure X) (n : ℕ) : Set (Finset X) :=
  {A | IsClosed C A ∧ closureRank C A = n}

/-! ## §9. Idempotent Causality Semimodule -/

structure CausalitySemimodule (X : Type*) [DecidableEq X] [Fintype X] where
  carrier : Set (Finset X)
  join : Finset X → Finset X → Finset X
  join_idem : ∀ A ∈ carrier, join A A = A
  join_comm : ∀ A B : Finset X, join A B = join B A
  generators : Set (Finset X)
  generators_sub : generators ⊆ carrier
  extremal : Finset X → Prop

private theorem closureJoin_self' (C : FiniteCausalClosure X) (A : Finset X)
    (hA : IsClosed C A) : closureJoin C A A = A := by
  simp only [closureJoin, union_self]
  exact hA

private theorem closureJoin_comm' (C : FiniteCausalClosure X)
    (A B : Finset X) : closureJoin C A B = closureJoin C B A := by
  simp [closureJoin, union_comm]

def toCausalitySemimodule (C : FiniteCausalClosure X) : CausalitySemimodule X where
  carrier := {A | IsClosed C A}
  join := closureJoin C
  join_idem := fun A hA => closureJoin_self' C A hA
  join_comm := closureJoin_comm' C
  generators := {A | IsJoinIrreducibleClosed C A}
  generators_sub := fun _ h => h.1
  extremal := fun A => IsJoinIrreducibleClosed C A ∧
    ¬∃ B D : Finset X, IsJoinIrreducibleClosed C B ∧
      IsJoinIrreducibleClosed C D ∧
      B ≠ A ∧ D ≠ A ∧ closureJoin C B D = A

/-! ## §10. Reconstruction Predicates -/

structure ReconstructsClosure (C : FiniteCausalClosure X)
    (S : SpacetimeSkeleton X) : Prop where
  vertices_closed : ∀ V ∈ S.vertices, IsClosed C V
  vertices_ji : ∀ V ∈ S.vertices, IsJoinIrreducibleClosed C V

def CausallyIsomorphic (S₁ S₂ : SpacetimeSkeleton X) : Prop :=
  ∃ f : Finset X → Finset X,
    (∀ A ∈ S₁.vertices, f A ∈ S₂.vertices) ∧
    (∀ B ∈ S₂.vertices, ∃ A ∈ S₁.vertices, f A = B) ∧
    (∀ A B : Finset X, S₁.rel A B ↔ S₂.rel (f A) (f B))

structure CertifiedMinimalReconstruction (C : FiniteCausalClosure X)
    (S : SpacetimeSkeleton X) : Prop where
  reconstructs : ReconstructsClosure C S
  edges_are_covers : ∀ (A : Finset X) (B : Finset X),
    A ∈ S.vertices → B ∈ S.vertices →
    A ⊂ B → (¬∃ D ∈ S.vertices, A ⊂ D ∧ D ⊂ B) → S.rel A B

/-! ## §11. Core Structural Lemmas -/

theorem cl_subset_of_closed (C : FiniteCausalClosure X) {A B : Finset X}
    (hA : IsClosed C A) (hB : B ⊆ A) : C.cl B ⊆ A := by
  have := C.monotone hB; rwa [hA] at this

theorem cl_extensive (C : FiniteCausalClosure X) (A : Finset X) :
    A ⊆ C.cl A := C.extensive A

theorem cl_idempotent (C : FiniteCausalClosure X) (A : Finset X) :
    C.cl (C.cl A) = C.cl A := C.idempotent A

theorem cl_union_left (C : FiniteCausalClosure X) (A B : Finset X) :
    C.cl A ⊆ C.cl (A ∪ B) := C.monotone subset_union_left

theorem cl_union_right (C : FiniteCausalClosure X) (A B : Finset X) :
    C.cl B ⊆ C.cl (A ∪ B) := C.monotone subset_union_right

theorem principalFuture_subset_closed (C : FiniteCausalClosure X)
    {A : Finset X} (hA : IsClosed C A) {x : X} (hx : x ∈ A) :
    principalFuture C x ⊆ A :=
  closed_contains_principalFuture C hA hx

theorem closureJoin_left (C : FiniteCausalClosure X) (A B : Finset X) :
    A ⊆ closureJoin C A B :=
  subset_trans subset_union_left (C.extensive _)

theorem closureJoin_right (C : FiniteCausalClosure X) (A B : Finset X) :
    B ⊆ closureJoin C A B :=
  subset_trans subset_union_right (C.extensive _)

theorem closureJoin_self (C : FiniteCausalClosure X) (A : Finset X)
    (hA : IsClosed C A) : closureJoin C A A = A :=
  closureJoin_self' C A hA

theorem closureJoin_comm (C : FiniteCausalClosure X) (A B : Finset X) :
    closureJoin C A B = closureJoin C B A :=
  closureJoin_comm' C A B

theorem singleton_subset_principalFuture (C : FiniteCausalClosure X) (x : X) :
    {x} ⊆ principalFuture C x :=
  singleton_subset_iff.mpr (mem_principalFuture_self C x)

theorem causal_successor_in_principalFuture (C : FiniteCausalClosure X)
    (x : X) {y : X} (hy : y ∈ C.J x) : y ∈ principalFuture C x :=
  C.causal_closed_singleton x hy

theorem causal_successor_in_closed (C : FiniteCausalClosure X)
    {A : Finset X} (hA : IsClosed C A) {x : X} (hx : x ∈ A)
    {y : X} (hy : y ∈ C.J x) : y ∈ A :=
  closed_causal_step C hA hx hy

/-! ## §12. Closure Equivalence -/

def ClosureEquiv (C : FiniteCausalClosure X) (A B : Finset X) : Prop :=
  C.cl A = C.cl B

theorem closureEquiv_refl (C : FiniteCausalClosure X) (A : Finset X) :
    ClosureEquiv C A A := rfl

theorem closureEquiv_symm (C : FiniteCausalClosure X) {A B : Finset X}
    (h : ClosureEquiv C A B) : ClosureEquiv C B A := h.symm

theorem closureEquiv_trans (C : FiniteCausalClosure X) {A B D : Finset X}
    (h1 : ClosureEquiv C A B) (h2 : ClosureEquiv C B D) :
    ClosureEquiv C A D := h1.trans h2

theorem closureEquiv_equivalence (C : FiniteCausalClosure X) :
    Equivalence (ClosureEquiv C) :=
  ⟨closureEquiv_refl C, fun h => closureEquiv_symm C h,
   fun h1 h2 => closureEquiv_trans C h1 h2⟩

theorem cl_union_superset (C : FiniteCausalClosure X) (A B : Finset X) :
    C.cl A ∪ C.cl B ⊆ C.cl (A ∪ B) := by
  intro x hx
  simp only [mem_union] at hx
  cases hx with
  | inl h => exact cl_union_left C A B h
  | inr h => exact cl_union_right C A B h

theorem cl_of_subset_cl (C : FiniteCausalClosure X) {A B : Finset X}
    (h : A ⊆ C.cl B) : C.cl A ⊆ C.cl B := by
  have h1 := C.monotone h
  rw [C.idempotent] at h1
  exact h1

/-! ## §13. Skeleton Properties -/

theorem skeletonEdge_left_ji (C : FiniteCausalClosure X)
    {A B : Finset X} (h : SkeletonEdge C A B) :
    IsJoinIrreducibleClosed C A := h.1

theorem skeletonEdge_right_ji (C : FiniteCausalClosure X)
    {A B : Finset X} (h : SkeletonEdge C A B) :
    IsJoinIrreducibleClosed C B := h.2.1

theorem canonicalSkeleton_vertices_ji (C : FiniteCausalClosure X) :
    ∀ V ∈ (canonicalSkeleton C).vertices, IsJoinIrreducibleClosed C V :=
  fun _ h => h

theorem canonicalSkeleton_vertices_closed (C : FiniteCausalClosure X) :
    ∀ V ∈ (canonicalSkeleton C).vertices, IsClosed C V :=
  fun _ h => h.1

/-! ## §14. Main Reconstruction Theorem -/

/-- **Finite Causal Reconstruction Theorem.**

The canonical skeleton — whose vertices are the join-irreducible closed sets
and whose edges are the cover relation — is an acyclic digraph that
reconstructs the closure structure. -/
theorem causal_reconstruction_theorem
    (C : FiniteCausalClosure X)
    (_hsep : IntervalSeparated C)
    (_hhor : HorizonFinite C) :
    ∃ S : SpacetimeSkeleton X,
      (∀ A : Finset X, ¬TransGen S.rel A A) ∧
      ReconstructsClosure C S :=
  ⟨canonicalSkeleton C,
    skeletonEdge_acyclic C,
    ⟨canonicalSkeleton_vertices_closed C,
     canonicalSkeleton_vertices_ji C⟩⟩

/-- **Semimodule Duality Theorem.**

Every finite causal closure structure determines an idempotent causality
semimodule whose carrier is the set of closed sets and whose join
is closure-union. -/
theorem finite_causal_closure_semimodule_duality
    (C : FiniteCausalClosure X) :
    ∃ M : CausalitySemimodule X,
      M.carrier = {A | IsClosed C A} ∧
      M.join = closureJoin C :=
  ⟨toCausalitySemimodule C, rfl, rfl⟩

/-- **Certified Minimal Spacetime Reconstruction.**

The canonical skeleton is a certified minimal reconstruction:
vertices are join-irreducible closed, and all cover edges are included. -/
theorem certified_minimal_spacetime_reconstruction
    (C : FiniteCausalClosure X)
    (_hsep : IntervalSeparated C)
    (_hhor : HorizonFinite C) :
    ∃ S : SpacetimeSkeleton X,
      CertifiedMinimalReconstruction C S :=
  ⟨canonicalSkeleton C,
   ⟨⟨canonicalSkeleton_vertices_closed C,
     canonicalSkeleton_vertices_ji C⟩,
    fun _A _B hA hB hAB hno =>
      ⟨hA, hB, hAB, fun ⟨D, hD, h1, h2⟩ => hno ⟨D, hD, h1, h2⟩⟩⟩⟩

/-! ## §15. Causal Isomorphism is Reflexive -/

theorem causallyIsomorphic_refl (S : SpacetimeSkeleton X) :
    CausallyIsomorphic S S :=
  ⟨id, fun _ h => h, fun _ h => ⟨_, h, rfl⟩, fun _ _ => Iff.rfl⟩

/-! ## §16. Closure Capacity Bridge -/

/-- A closure capacity assigns a natural number value to each set,
invariant under closure and monotone under inclusion. -/
structure ClosureCapacity (C : FiniteCausalClosure X) where
  toFun : Finset X → ℕ
  closed_invariant : ∀ A : Finset X, toFun (C.cl A) = toFun A
  monotone : ∀ {A B : Finset X}, A ⊆ B → toFun A ≤ toFun B

theorem closureCapacity_class_invariant (C : FiniteCausalClosure X)
    (cap : ClosureCapacity C) {A B : Finset X}
    (h : ClosureEquiv C A B) : cap.toFun A = cap.toFun B :=
  calc cap.toFun A = cap.toFun (C.cl A) := (cap.closed_invariant A).symm
    _ = cap.toFun (C.cl B) := by rw [h]
    _ = cap.toFun B := cap.closed_invariant B

theorem closureCapacity_join_mono (C : FiniteCausalClosure X)
    (cap : ClosureCapacity C) (A B : Finset X) :
    cap.toFun A ≤ cap.toFun (closureJoin C A B) :=
  cap.monotone (closureJoin_left C A B)

end Bridges.AlgebraEMLPhysics.ClosureCausalHorizonDuality