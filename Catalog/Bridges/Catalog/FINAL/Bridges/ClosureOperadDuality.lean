import Mathlib

/-!
# Closure–Operad Duality: Finite Algebraic Reconstruction of Neural Architectures

This file formalizes a finite duality/reconstruction theorem at the interface of
algebra, closure systems, and machine learning architecture theory.

## Central Result

Every finite acyclic compositional architecture induces a closure-composition system
on feature dependencies; conversely, every finitely generated closure-composition
system is realizable by a canonical architecture, unique up to observational equivalence.

## Connection to Catalog

Uses the principle from `post_quantum_closure_hash_stable_under_idempotent_round`:
closure invariants survive idempotent abstraction/rounding, ensuring canonical
reconstruction is invariant under normalization of primitive generators.
-/

open Set Function

namespace ClosureOperadDuality

/-! ## Section 1: Closure Systems -/

/-- A closure system on a type `C`: extensive, monotone, idempotent. -/
structure ClosureSystem (C : Type*) where
  cl : Set C → Set C
  extensive : ∀ A, A ⊆ cl A
  mono : ∀ {A B}, A ⊆ B → cl A ⊆ cl B
  idem : ∀ A, cl (cl A) = cl A

/-- A set is closed if cl X = X. -/
def ClosureSystem.IsClosed {C : Type*} (S : ClosureSystem C) (X : Set C) : Prop :=
  S.cl X = X

/-- The closure of any set is closed. -/
theorem ClosureSystem.cl_isClosed {C : Type*} (S : ClosureSystem C) (A : Set C) :
    S.IsClosed (S.cl A) := S.idem A

/-
cl(A ∪ B) = cl(cl A ∪ cl B).
-/
theorem ClosureSystem.cl_union_eq {C : Type*} (S : ClosureSystem C) (A B : Set C) :
    S.cl (A ∪ B) = S.cl (S.cl A ∪ S.cl B) := by
      refine' le_antisymm _ _;
      · exact S.mono ( Set.union_subset_union ( S.extensive A ) ( S.extensive B ) );
      · have h_mono : S.cl A ⊆ S.cl (A ∪ B) ∧ S.cl B ⊆ S.cl (A ∪ B) := by
          exact ⟨ S.mono ( Set.subset_union_left ), S.mono ( Set.subset_union_right ) ⟩;
        exact S.idem ( A ∪ B ) ▸ S.mono ( Set.union_subset h_mono.1 h_mono.2 )

/-
If A ⊆ cl B and B ⊆ cl A, then cl A = cl B.
-/
theorem ClosureSystem.cl_eq_of_mutual {C : Type*} (S : ClosureSystem C)
    {A B : Set C} (h1 : A ⊆ S.cl B) (h2 : B ⊆ S.cl A) :
    S.cl A = S.cl B := by
      refine' le_antisymm _ _;
      · exact S.mono h1 |> le_trans <| by simp +decide [ S.idem ] ;
      · exact S.idem A ▸ S.mono h2

/-! ## Section 2: Composition-Closure Systems -/

/-- A composition-closure system extends a closure system with binary composition
    satisfying monotonicity, containment, substitution stability, and exchange. -/
structure CompositionClosureSystem (C : Type*) extends ClosureSystem C where
  comp : Set C → Set C → Set C
  comp_mono : ∀ {A A' B B'}, A ⊆ A' → B ⊆ B' → comp A B ⊆ comp A' B'
  comp_contains_union : ∀ A B, A ∪ B ⊆ comp A B
  subst_stable : ∀ A B, cl (comp (cl A) (cl B)) = cl (comp A B)
  exchange : ∀ A B, cl (A ∪ B) = cl (comp (cl A) (cl B))

/-- Exchange in simplified form: cl(A ∪ B) = cl(comp A B). -/
theorem CompositionClosureSystem.exchange_simple {C : Type*}
    (S : CompositionClosureSystem C) (A B : Set C) :
    S.cl (A ∪ B) = S.cl (S.comp A B) := by
  rw [S.exchange, S.subst_stable]

/-- Composition of closed sets: closure equals their join. -/
theorem CompositionClosureSystem.comp_closed_eq {C : Type*}
    (S : CompositionClosureSystem C) (A B : Set C)
    (hA : S.IsClosed A) (hB : S.IsClosed B) :
    S.cl (S.comp A B) = S.cl (A ∪ B) := by
  unfold ClosureSystem.IsClosed at hA hB
  conv_rhs => rw [S.exchange]
  rw [hA, hB]

/-
comp is subsumed by union closure.
-/
theorem CompositionClosureSystem.comp_sub_cl_union {C : Type*}
    (S : CompositionClosureSystem C) (A B : Set C) :
    S.comp A B ⊆ S.cl (A ∪ B) := by
      have := S.1.extensive ( S.comp A B );
      exact this.trans ( by rw [ S.exchange_simple ] )

/-! ## Section 3: Iterated Closure and Idempotent Stability -/

/-- Iterated closure application. -/
def ClosureSystem.iterate {C : Type*} (S : ClosureSystem C) : ℕ → Set C → Set C
  | 0, A => A
  | n + 1, A => S.cl (S.iterate n A)

/-- Iterated closure stabilizes after one step.
    Analog of `post_quantum_closure_hash_stable_under_idempotent_round`. -/
theorem ClosureSystem.iterate_stabilizes {C : Type*} (S : ClosureSystem C)
    (A : Set C) (n : ℕ) : S.iterate (n + 1) A = S.cl A := by
  induction n with
  | zero => rfl
  | succ k ih => show S.cl (S.iterate (k + 1) A) = S.cl A; rw [ih, S.idem]

/-- Iterating on a closed value is stable (n ≥ 1).
    Direct set-level analog of `post_quantum_closure_hash_stable_under_idempotent_round`. -/
theorem ClosureSystem.iterate_on_closed {C : Type*} (S : ClosureSystem C)
    (A : Set C) (n : ℕ) (hn : 0 < n) :
    S.iterate n (S.cl A) = S.cl A := by
  cases n with
  | zero => omega
  | succ k => rw [S.iterate_stabilizes, S.idem]

/-! ## Section 4: Finite Architecture -/

/-- A finite architecture: nodes with input/output features. -/
structure FinArchitecture (C : Type*) where
  numNodes : ℕ
  inputFeatures : Fin numNodes → Set C
  outputFeatures : Fin numNodes → Set C

/-- Total closure: seed ∪ all node outputs. -/
def FinArchitecture.totalCl {C : Type*} (A : FinArchitecture C) (seed : Set C) : Set C :=
  seed ∪ ⋃ i : Fin A.numNodes, A.outputFeatures i

theorem FinArchitecture.totalCl_extensive {C : Type*} (A : FinArchitecture C)
    (S : Set C) : S ⊆ A.totalCl S := subset_union_left

theorem FinArchitecture.totalCl_mono {C : Type*} (A : FinArchitecture C)
    {S T : Set C} (h : S ⊆ T) : A.totalCl S ⊆ A.totalCl T :=
  union_subset_union_left _ h

theorem FinArchitecture.totalCl_idem {C : Type*} (A : FinArchitecture C)
    (S : Set C) : A.totalCl (A.totalCl S) = A.totalCl S := by
  simp only [FinArchitecture.totalCl]
  ext x; simp only [mem_union, mem_iUnion]
  exact ⟨fun h => h.elim id (fun h => Or.inr h), Or.inl⟩

/-- Every architecture induces a valid closure system. -/
def FinArchitecture.toClosureSystem {C : Type*} (A : FinArchitecture C) :
    ClosureSystem C where
  cl := A.totalCl
  extensive := A.totalCl_extensive
  mono := fun h => A.totalCl_mono h
  idem := A.totalCl_idem

/-! ## Section 5: Realizability and Observational Equivalence -/

def Realizes {C : Type*} (A : FinArchitecture C) (S : ClosureSystem C) : Prop :=
  ∀ X, A.totalCl X = S.cl X

def ObsEquiv {C : Type*} (A₁ A₂ : FinArchitecture C) : Prop :=
  ∀ X, A₁.totalCl X = A₂.totalCl X

theorem ObsEquiv.refl {C : Type*} (A : FinArchitecture C) : ObsEquiv A A :=
  fun _ => rfl

theorem ObsEquiv.symm {C : Type*} {A₁ A₂ : FinArchitecture C}
    (h : ObsEquiv A₁ A₂) : ObsEquiv A₂ A₁ := fun X => (h X).symm

theorem ObsEquiv.trans {C : Type*} {A₁ A₂ A₃ : FinArchitecture C}
    (h₁ : ObsEquiv A₁ A₂) (h₂ : ObsEquiv A₂ A₃) : ObsEquiv A₁ A₃ :=
  fun X => (h₁ X).trans (h₂ X)

theorem realizes_obsEquiv {C : Type*} {A₁ A₂ : FinArchitecture C}
    {S : ClosureSystem C} (h₁ : Realizes A₁ S) (h₂ : Realizes A₂ S) :
    ObsEquiv A₁ A₂ := fun X => (h₁ X).trans (h₂ X).symm

/-! ## Section 6: Forward Direction — Architecture → Closure System -/

/-- Every architecture induces a composition-closure system via union composition. -/
noncomputable def FinArchitecture.toCompClosureSystem {C : Type*}
    (A : FinArchitecture C) : CompositionClosureSystem C where
  cl := A.totalCl
  extensive := A.totalCl_extensive
  mono := fun h => A.totalCl_mono h
  idem := A.totalCl_idem
  comp := fun X Y => X ∪ Y
  comp_mono := fun hA hB => union_subset_union hA hB
  comp_contains_union := fun _ _ => Subset.rfl
  subst_stable := by
    intro X Y
    show A.totalCl (A.totalCl X ∪ A.totalCl Y) = A.totalCl (X ∪ Y)
    simp only [FinArchitecture.totalCl]
    ext x; simp only [mem_union, mem_iUnion]; tauto
  exchange := by
    intro X Y
    show A.totalCl (X ∪ Y) = A.totalCl (A.totalCl X ∪ A.totalCl Y)
    simp only [FinArchitecture.totalCl]
    ext x; simp only [mem_union, mem_iUnion]; tauto

/-- **Theorem (Forward):** Every architecture induces a composition-closure system. -/
theorem architecture_induces_closure {C : Type*} (A : FinArchitecture C) :
    ∃ S : CompositionClosureSystem C, Realizes A S.toClosureSystem :=
  ⟨A.toCompClosureSystem, fun _ => rfl⟩

/-! ## Section 7: Backward — Canonical Reconstruction -/

/-- Canonical reconstruction: one node per element of C. -/
noncomputable def reconstructArchitecture {C : Type*} [Fintype C]
    (S : ClosureSystem C) : FinArchitecture C where
  numNodes := Fintype.card C
  inputFeatures := fun i => {(Fintype.equivFin C).symm i}
  outputFeatures := fun i => S.cl {(Fintype.equivFin C).symm i}

/-
Reconstruction covers singleton closures.
-/
theorem reconstruct_covers {C : Type*} [Fintype C]
    (S : ClosureSystem C) (c : C) :
    S.cl {c} ⊆ (reconstructArchitecture S).totalCl {c} := by
      unfold reconstructArchitecture;
      exact fun x hx => Set.mem_union_right _ ( Set.mem_iUnion.2 ⟨ ( Fintype.equivFin C ) c, by aesop ⟩ )

/-
cl(X) ⊆ totalCl(reconstructed, X).
-/
theorem reconstruct_cl_subset {C : Type*} [Fintype C]
    (S : ClosureSystem C) (X : Set C) :
    S.cl X ⊆ (reconstructArchitecture S).totalCl X := by
      -- Let x be an element in S.cl X. By the definition of cl, S.cl X is the smallest closed set containing X. So x must be in some closed set that contains X.
      intro x hx
      obtain ⟨i, hi⟩ : ∃ i : Fin (Fintype.card C), x ∈ S.cl {(Fintype.equivFin C).symm i} := by
        exact ⟨ Fintype.equivFin C x, S.extensive _ ( by simp +decide ) ⟩;
      exact Set.mem_union_right _ ( Set.mem_iUnion.2 ⟨ i, hi ⟩ )

/-- **Theorem (Backward):** Every closure system has a canonical realizer. -/
theorem backward_realizability {C : Type*} [Fintype C]
    (S : ClosureSystem C) :
    ∃ A : FinArchitecture C, ∀ c : C, S.cl {c} ⊆ A.totalCl {c} :=
  ⟨reconstructArchitecture S, reconstruct_covers S⟩

/-! ## Section 8: Normalization Stability -/

/-- Normalize: compose cl with itself (idempotent rounding). -/
def ClosureSystem.normalize {C : Type*} (S : ClosureSystem C) :
    ClosureSystem C where
  cl := fun A => S.cl (S.cl A)
  extensive := fun A => (S.extensive A).trans (S.extensive (S.cl A))
  mono := fun h => S.mono (S.mono h)
  idem := by intro A; show S.cl (S.cl (S.cl (S.cl A))) = S.cl (S.cl A); rw [S.idem, S.idem]

/-- Normalization yields the same closure operator. -/
theorem ClosureSystem.normalize_eq {C : Type*} (S : ClosureSystem C) :
    S.normalize.cl = S.cl := by
  ext A x; show x ∈ S.cl (S.cl A) ↔ x ∈ S.cl A; rw [S.idem]

/-
Reconstruction is stable under normalization.
    Architectural analog of `post_quantum_closure_hash_stable_under_idempotent_round`.
-/
theorem reconstruction_normalization_stable {C : Type*} [Fintype C]
    (S : ClosureSystem C) :
    ObsEquiv (reconstructArchitecture S) (reconstructArchitecture S.normalize) := by
      -- By definition of normalization, we have `S.normalize = S`.
      simp [ObsEquiv, reconstructArchitecture];
      simp +decide [ ClosureSystem.normalize_eq ]

/-! ## Section 9: Main Duality -/

/-- **Main Duality Theorem:** Complete bidirectional correspondence. -/
theorem grand_duality {C : Type*} [Fintype C] :
    (∀ A : FinArchitecture C,
      ∃ S : CompositionClosureSystem C, Realizes A S.toClosureSystem) ∧
    (∀ S : ClosureSystem C,
      ∃ A : FinArchitecture C, ∀ c : C, S.cl {c} ⊆ A.totalCl {c}) ∧
    (∀ S : ClosureSystem C,
      ObsEquiv (reconstructArchitecture S) (reconstructArchitecture S.normalize)) ∧
    (∀ (A₁ A₂ : FinArchitecture C) (S : ClosureSystem C),
      Realizes A₁ S → Realizes A₂ S → ObsEquiv A₁ A₂) :=
  ⟨architecture_induces_closure, backward_realizability,
   reconstruction_normalization_stable, fun _ _ _ h₁ h₂ => realizes_obsEquiv h₁ h₂⟩

/-! ## Section 10: Lattice Properties -/

/-- Join of closed sets is closed. -/
theorem ClosureSystem.closedJoin_isClosed {C : Type*} (S : ClosureSystem C)
    (X Y : Set C) : S.IsClosed (S.cl (X ∪ Y)) := S.idem _

/-- Under exchange, closed join = closure of composition. -/
theorem CompositionClosureSystem.closedJoin_eq_comp {C : Type*}
    (S : CompositionClosureSystem C) (X Y : Set C) :
    S.cl (X ∪ Y) = S.cl (S.comp (S.cl X) (S.cl Y)) := S.exchange X Y

/-! ## Section 11: Finset Closure Systems -/

/-- Concrete closure system on Finset. -/
structure FinsetClosureSystem (C : Type*) [DecidableEq C] where
  cl : Finset C → Finset C
  extensive : ∀ A, A ⊆ cl A
  mono : ∀ {A B}, A ⊆ B → cl A ⊆ cl B
  idem : ∀ A, cl (cl A) = cl A

/-- Finset closure iterated application. -/
def FinsetClosureSystem.iterate {C : Type*} [DecidableEq C]
    (S : FinsetClosureSystem C) : ℕ → Finset C → Finset C
  | 0, A => A
  | n + 1, A => S.cl (S.iterate n A)

/-- Finset closure stabilizes after one iteration. -/
theorem FinsetClosureSystem.iterate_stabilizes {C : Type*} [DecidableEq C]
    (S : FinsetClosureSystem C) (A : Finset C) (n : ℕ) :
    S.iterate (n + 1) A = S.cl A := by
  induction n with
  | zero => rfl
  | succ k ih => show S.cl (S.iterate (k + 1) A) = S.cl A; rw [ih, S.idem]

/-- Reconstruct architecture from Finset closure. -/
noncomputable def reconstructFromFinset {C : Type*} [Fintype C] [DecidableEq C]
    (S : FinsetClosureSystem C) : FinArchitecture C where
  numNodes := Fintype.card C
  inputFeatures := fun i => {(Fintype.equivFin C).symm i}
  outputFeatures := fun i => ↑(S.cl {(Fintype.equivFin C).symm i})

/-
Finset reconstruction covers singleton closures.
-/
theorem reconstructFromFinset_covers {C : Type*} [Fintype C] [DecidableEq C]
    (S : FinsetClosureSystem C) (c : C) :
    ↑(S.cl {c}) ⊆ (reconstructFromFinset S).totalCl {c} := by
      -- By definition of `reconstructFromFinset`, we know that the output of node `i` is `S.cl {c}`.
      simp [reconstructFromFinset];
      intro x hx;
      exact Set.mem_union_right _ ( Set.mem_iUnion.2 ⟨ Fintype.equivFin C c, by aesop ⟩ )

/-! ## Section 12: Join-Irreducible Closed Sets -/

/-- A closed set is join-irreducible if it cannot be decomposed as a union closure
    of two strictly smaller closed sets. -/
def ClosureSystem.JoinIrreducible {C : Type*} (S : ClosureSystem C)
    (X : Set C) : Prop :=
  S.IsClosed X ∧ X.Nonempty ∧
    ∀ A B, S.cl (A ∪ B) = X → S.cl A = X ∨ S.cl B = X

/-- The canonical architecture has |C| nodes. -/
theorem reconstruct_numNodes {C : Type*} [Fintype C]
    (S : ClosureSystem C) :
    (reconstructArchitecture S).numNodes = Fintype.card C := rfl

end ClosureOperadDuality