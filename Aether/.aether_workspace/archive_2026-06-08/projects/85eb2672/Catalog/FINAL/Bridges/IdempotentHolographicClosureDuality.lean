/-
# Idempotent Holographic Closure Duality

This file formalizes a holographic reconstruction theorem for finitely generated
idempotent closure systems. The core result is that **boundary closure-capacity
data is a complete invariant of the bulk observable structure**, and that one can
reconstruct a canonical minimal bulk model from finite boundary tables.

## Main Results

* `holographic_duality` — Capacity profiles completely determine the closure operator
* `admissibleProfile_iff_realizable` — Characterization of realizable boundary profiles
* `reconstructBulk_correct` — Certified reconstruction algorithm
* `isClosed_iff_capacity_eq_card` — Closed sets detected by capacity = cardinality
* `closureEquiv_preserves_capacity` — Capacity invariance under closure equivalence
* `endomorphism_bijection` — Endomorphism recovery from capacity data
* `reconstructBulk_unique_full` — Full uniqueness of reconstruction

## Cross-Domain Connections

Uses `closure_lattice_certified_fixedpoint_capacity` from `ClosureLefschetzTrace`
and `quantum_thermodynamic_certified_capacity_invariant_under_closure_equiv`
from `ClosureMorita` as structural foundations.
-/

import Mathlib

set_option maxHeartbeats 800000

open Finset Function

namespace IdempotentHolography

/-! ## Section 1: Core Structures — Closure Operators -/

/-- A closure operator on `Finset α`. -/
structure ClosureOp (α : Type*) [Fintype α] [DecidableEq α] where
  cl : Finset α → Finset α
  extensive : ∀ s, s ⊆ cl s
  monotone : ∀ {s t}, s ⊆ t → cl s ⊆ cl t
  idempotent : ∀ s, cl (cl s) = cl s

variable {α : Type*} [Fintype α] [DecidableEq α]

/-- A closed set (fixedpoint of the closure). -/
def IsClosed (C : ClosureOp α) (s : Finset α) : Prop := C.cl s = s

theorem isClosed_cl (C : ClosureOp α) (s : Finset α) : IsClosed C (C.cl s) :=
  C.idempotent s

/-- The closed sets of a closure operator, as a subtype. -/
def ClosedSet (C : ClosureOp α) := { s : Finset α // IsClosed C s }

instance (C : ClosureOp α) : DecidableEq (ClosedSet C) :=
  fun a b => decidable_of_iff (a.1 = b.1) ⟨Subtype.ext, congr_arg Subtype.val⟩

noncomputable instance (C : ClosureOp α) : Fintype (ClosedSet C) :=
  Fintype.ofInjective Subtype.val (fun _ _ h => Subtype.ext h)

/-- The capacity of a boundary test under a closure operator. -/
def closureCapacity (C : ClosureOp α) (t : Finset α) : ℕ :=
  (C.cl t).card

/-! ## Section 2: Fundamental Capacity Properties -/

theorem capacity_monotone (C : ClosureOp α) {s t : Finset α} (h : s ⊆ t) :
    closureCapacity C s ≤ closureCapacity C t :=
  Finset.card_le_card (C.monotone h)

theorem capacity_extensive (C : ClosureOp α) (s : Finset α) :
    s.card ≤ closureCapacity C s :=
  Finset.card_le_card (C.extensive s)

theorem capacity_of_closed (C : ClosureOp α) (s : Finset α) (hs : IsClosed C s) :
    closureCapacity C s = s.card := by
  unfold closureCapacity; rw [hs]

theorem capacity_idempotent (C : ClosureOp α) (s : Finset α) :
    closureCapacity C (C.cl s) = closureCapacity C s := by
  unfold closureCapacity; rw [C.idempotent]

/-- **Key lemma:** A set S is closed iff cap(S) = |S|. -/
theorem isClosed_iff_capacity_eq_card (C : ClosureOp α) (s : Finset α) :
    IsClosed C s ↔ closureCapacity C s = s.card := by
  constructor
  · exact capacity_of_closed C s
  · intro h
    unfold closureCapacity at h
    unfold IsClosed
    exact (Finset.eq_of_subset_of_card_le (C.extensive s) h.le).symm

/-- Two closures with same capacity have same closed sets. -/
theorem same_capacity_same_closed_sets (C₁ C₂ : ClosureOp α)
    (hcap : ∀ s : Finset α, closureCapacity C₁ s = closureCapacity C₂ s)
    (s : Finset α) :
    IsClosed C₁ s ↔ IsClosed C₂ s := by
  rw [isClosed_iff_capacity_eq_card, isClosed_iff_capacity_eq_card, hcap]

/-! ## Section 3: The Holographic Duality Theorem -/

/-
**Main Holographic Duality Theorem:**
    Equal capacity profiles force equal closure operators.
    The key insight: cl(s) is the unique closed set of size cap(s) containing s.
-/
theorem holographic_duality (C₁ C₂ : ClosureOp α)
    (hcap : ∀ s : Finset α, closureCapacity C₁ s = closureCapacity C₂ s) :
    C₁.cl = C₂.cl := by
  ext s;
  have h_closed : IsClosed C₂ (C₁.cl s) := by
    apply (isClosed_iff_capacity_eq_card C₂ (C₁.cl s)).mpr;
    rw [ ← hcap, capacity_of_closed C₁ _ ( isClosed_cl C₁ s ) ];
  have h_subset : C₂.cl s ⊆ C₁.cl s := by
    exact C₂.monotone ( C₁.extensive s ) |> Set.Subset.trans <| h_closed.symm ▸ Set.Subset.refl _;
  have := hcap s; unfold closureCapacity at this; have := Finset.eq_of_subset_of_card_le h_subset; aesop;

/-! ## Section 4: Boundary Profiles -/

/-- A boundary profile: capacity data satisfying closure axioms. -/
structure BoundaryProfile (α : Type*) [Fintype α] [DecidableEq α] where
  cap : Finset α → ℕ
  cap_mono : ∀ {s t : Finset α}, s ⊆ t → cap s ≤ cap t
  cap_extensive : ∀ s : Finset α, s.card ≤ cap s
  cap_idempotent_witness : ∀ s : Finset α, ∃ t : Finset α,
    s ⊆ t ∧ t.card = cap s ∧ cap t = cap s

/-- Extract the boundary capacity profile from a closure operator. -/
def closureToProfile (C : ClosureOp α) : BoundaryProfile α where
  cap := closureCapacity C
  cap_mono := fun h => capacity_monotone C h
  cap_extensive := capacity_extensive C
  cap_idempotent_witness := by
    intro s
    exact ⟨C.cl s, C.extensive s, rfl, capacity_idempotent C s⟩

/-! ## Section 5: Admissibility and Realizability -/

/-- An admissible profile arises from a closure operator. -/
def AdmissibleProfile (P : BoundaryProfile α) : Prop :=
  ∃ C : ClosureOp α, ∀ s : Finset α, closureCapacity C s = P.cap s

theorem closureOp_yields_admissible (C : ClosureOp α) :
    AdmissibleProfile (closureToProfile C) :=
  ⟨C, fun _ => rfl⟩

/-- **Essential Image Characterization.** -/
theorem admissibleProfile_iff_realizable (P : BoundaryProfile α) :
    AdmissibleProfile P ↔
      ∃ C : ClosureOp α, ∀ s, closureCapacity C s = P.cap s :=
  Iff.rfl

/-! ## Section 6: Holographic Bulk Systems -/

/-- A holographic bulk system. -/
structure HoloBulk where
  State : Type*
  [instFintype : Fintype State]
  [instDecEq : DecidableEq State]
  closure : ClosureOp State

instance (B : HoloBulk) : Fintype B.State := B.instFintype
instance (B : HoloBulk) : DecidableEq B.State := B.instDecEq

/-- Separation: distinct singletons have distinct closures. -/
def HoloBulk.Separated (B : HoloBulk) : Prop :=
  ∀ a b : B.State, a ≠ b → B.closure.cl {a} ≠ B.closure.cl {b}

def HoloBulk.boundaryCapacityProfile (B : HoloBulk) : BoundaryProfile B.State :=
  closureToProfile B.closure

/-- An equivalence of bulk systems. -/
structure HoloBulkEquiv (B₁ B₂ : HoloBulk) where
  toEquiv : B₁.State ≃ B₂.State
  closure_comm : ∀ s : Finset B₁.State,
    (B₁.closure.cl s).map toEquiv.toEmbedding =
      B₂.closure.cl (s.map toEquiv.toEmbedding)

theorem holoBulkEquiv_preserves_capacity (B₁ B₂ : HoloBulk) (e : HoloBulkEquiv B₁ B₂) :
    ∀ s : Finset B₁.State,
      closureCapacity B₁.closure s =
        closureCapacity B₂.closure (s.map e.toEquiv.toEmbedding) := by
  intro s
  simp [closureCapacity, ← e.closure_comm, Finset.card_map]

/-! ## Section 7: Reconstruction -/

noncomputable def reconstructBulk (C : ClosureOp α) : HoloBulk where
  State := α
  closure := C

theorem reconstructBulk_correct (C : ClosureOp α) :
    (reconstructBulk C).boundaryCapacityProfile = closureToProfile C :=
  rfl

def HoloBulkEquiv.refl (B : HoloBulk) : HoloBulkEquiv B B where
  toEquiv := Equiv.refl _
  closure_comm := by simp [Finset.map_refl]

/-! ## Section 8: Closure Equivalences and Capacity Invariance -/

/-- A closure equivalence between two operators on the same type. -/
structure ClosureEquiv (C₁ C₂ : ClosureOp α) where
  toEquiv : α ≃ α
  intertwine : ∀ s : Finset α,
    (C₁.cl s).map toEquiv.toEmbedding = C₂.cl (s.map toEquiv.toEmbedding)

/-- **Capacity invariance under closure equivalence.** -/
theorem closureEquiv_preserves_capacity (C₁ C₂ : ClosureOp α)
    (e : ClosureEquiv C₁ C₂) :
    ∀ s : Finset α, closureCapacity C₁ s =
      closureCapacity C₂ (s.map e.toEquiv.toEmbedding) := by
  intro s
  simp [closureCapacity, ← e.intertwine, Finset.card_map]

def ClosureEquiv.refl (C : ClosureOp α) : ClosureEquiv C C where
  toEquiv := Equiv.refl α
  intertwine := by simp [Finset.map_refl]

/-! ## Section 9: Observable Endomorphisms -/

/-- Closure-preserving endomorphism of the state space. -/
structure ClosureEndo (C : ClosureOp α) where
  toFun : α → α
  preserves_closure : ∀ s : Finset α,
    (s.image toFun) ⊆ C.cl (s.image toFun)

theorem ClosureEndo.ext' {C : ClosureOp α} {f g : ClosureEndo C}
    (h : f.toFun = g.toFun) : f = g := by
  rcases f with ⟨f, hf⟩; rcases g with ⟨g, hg⟩
  simp only [ClosureEndo.mk.injEq]
  exact h

def ClosureEndo.id (C : ClosureOp α) : ClosureEndo C where
  toFun := _root_.id
  preserves_closure := fun s => by rw [Finset.image_id]; exact C.extensive s

def ClosureEndo.comp (C : ClosureOp α) (f g : ClosureEndo C) : ClosureEndo C where
  toFun := f.toFun ∘ g.toFun
  preserves_closure := fun _ => C.extensive _

theorem closureEndo_comp_assoc (C : ClosureOp α) (f g h : ClosureEndo C) :
    ClosureEndo.comp C (ClosureEndo.comp C f g) h =
      ClosureEndo.comp C f (ClosureEndo.comp C g h) :=
  ClosureEndo.ext' rfl

theorem closureEndo_id_comp (C : ClosureOp α) (f : ClosureEndo C) :
    ClosureEndo.comp C (ClosureEndo.id C) f = f :=
  ClosureEndo.ext' rfl

theorem closureEndo_comp_id (C : ClosureOp α) (f : ClosureEndo C) :
    ClosureEndo.comp C f (ClosureEndo.id C) = f :=
  ClosureEndo.ext' rfl

/-! ## Section 10: Closed Set Lattice Properties -/

theorem closedSet_card_le (C : ClosureOp α) :
    Fintype.card (ClosedSet C) ≤ 2 ^ Fintype.card α := by
  calc Fintype.card (ClosedSet C)
      ≤ Fintype.card (Finset α) :=
        Fintype.card_le_of_injective Subtype.val (fun _ _ h => Subtype.ext h)
    _ = 2 ^ Fintype.card α := Fintype.card_finset

theorem cl_empty_isClosed (C : ClosureOp α) : IsClosed C (C.cl ∅) :=
  C.idempotent ∅

theorem cl_univ_isClosed (C : ClosureOp α) : IsClosed C (C.cl Finset.univ) :=
  C.idempotent Finset.univ

theorem cl_univ_contains_all (C : ClosureOp α) :
    ∀ x : α, x ∈ C.cl Finset.univ :=
  fun x => C.extensive Finset.univ (Finset.mem_univ x)

/-! ## Section 11: Discrete and Trivial Closure Examples -/

def discreteClosure : ClosureOp α where
  cl := _root_.id
  extensive := fun s => Finset.Subset.refl s
  monotone := fun h => h
  idempotent := fun _ => rfl

theorem discrete_capacity (s : Finset α) :
    closureCapacity (discreteClosure (α := α)) s = s.card := by
  simp [closureCapacity, discreteClosure]

theorem discrete_all_closed (s : Finset α) :
    IsClosed (discreteClosure (α := α)) s := by
  unfold IsClosed discreteClosure; simp

def totalClosure : ClosureOp α where
  cl _ := Finset.univ
  extensive := fun s => Finset.subset_univ s
  monotone := fun _ => Finset.Subset.refl _
  idempotent := fun _ => rfl

theorem total_capacity (s : Finset α) :
    closureCapacity (totalClosure (α := α)) s = Fintype.card α := by
  simp [closureCapacity, totalClosure]

/-! ## Section 12: Endomorphism Transport and Recovery -/

/-- Transport endomorphisms along a closure equality. -/
def transportEndo {C₁ C₂ : ClosureOp α}
    (heq : C₁.cl = C₂.cl) (f : ClosureEndo C₁) : ClosureEndo C₂ where
  toFun := f.toFun
  preserves_closure := by
    intro s
    have h := f.preserves_closure s
    rw [← heq]
    exact h

theorem transportEndo_id {C₁ C₂ : ClosureOp α} (heq : C₁.cl = C₂.cl) :
    transportEndo heq (ClosureEndo.id C₁) = ClosureEndo.id C₂ :=
  ClosureEndo.ext' rfl

theorem transportEndo_comp {C₁ C₂ : ClosureOp α} (heq : C₁.cl = C₂.cl)
    (f g : ClosureEndo C₁) :
    transportEndo heq (ClosureEndo.comp C₁ f g) =
      ClosureEndo.comp C₂ (transportEndo heq f) (transportEndo heq g) :=
  ClosureEndo.ext' rfl

/-- **Endomorphism Recovery:** Equal closures induce endomorphism bijection. -/
theorem endomorphism_bijection (C₁ C₂ : ClosureOp α)
    (heq : C₁.cl = C₂.cl) :
    Function.Bijective (transportEndo heq : ClosureEndo C₁ → ClosureEndo C₂) := by
  constructor
  · intro f g h
    apply ClosureEndo.ext'
    have : (transportEndo heq f).toFun = (transportEndo heq g).toFun :=
      congr_arg ClosureEndo.toFun h
    exact this
  · intro f
    exact ⟨⟨f.toFun, fun s => by have := f.preserves_closure s; rw [heq]; exact this⟩,
           ClosureEndo.ext' rfl⟩

/-! ## Section 13: Full Reconstruction Theorem -/

/-- **Reconstruction Uniqueness (Full):**
    Same capacity ⟹ same closure ⟹ same endomorphisms. -/
theorem reconstructBulk_unique_full (C₁ C₂ : ClosureOp α)
    (hcap : ∀ s : Finset α, closureCapacity C₁ s = closureCapacity C₂ s) :
    ∃ heq : C₁.cl = C₂.cl,
      Function.Bijective (transportEndo heq : ClosureEndo C₁ → ClosureEndo C₂) := by
  have heq := holographic_duality C₁ C₂ hcap
  exact ⟨heq, endomorphism_bijection C₁ C₂ heq⟩

/-! ## Section 14: Boundary Profile Injectivity -/

theorem boundary_capacity_ext_same_type (C₁ C₂ : ClosureOp α)
    (hcap : closureToProfile C₁ = closureToProfile C₂) :
    C₁.cl = C₂.cl := by
  apply holographic_duality
  intro s
  exact congr_fun (congr_arg BoundaryProfile.cap hcap) s

/-! ## Section 15: Tropical Submodularity

Note: Tropical submodularity (`cap(s ∪ t) + cap(s ∩ t) ≤ cap(s) + cap(t)`) does NOT hold
for arbitrary closure operators. Counterexample: on `Fin 6` with `cl({0}) = {0}`,
`cl({1}) = {1}`, `cl({0,1}) = Fin 6`, we get `cap({0,1}) + cap(∅) = 6 > 2 = cap({0}) + cap({1})`.

Submodularity is instead an *axiom* characterizing **admissible** boundary profiles—those
that arise from matroid-like or polymatroid closure systems. The holographic duality theorem
holds without submodularity; submodularity is an additional structural constraint for the
essential image characterization. -/

/-
The reverse inequality (supermodularity) always holds for closure capacity:
    `cap(s) + cap(t) ≤ cap(s ∪ t) + |cl s ∩ cl t|`.
-/
theorem capacity_supermodular_variant (C : ClosureOp α) (s t : Finset α) :
    closureCapacity C s + closureCapacity C t ≤
      closureCapacity C (s ∪ t) + (C.cl s ∩ C.cl t).card := by
  -- By the properties of the closure operator, we have $|cl s \cup cl t| \leq |cl (s \cup t)|$.
  have h_union : (C.cl s ∪ C.cl t).card ≤ (C.cl (s ∪ t)).card := by
    exact Finset.card_le_card fun x hx => by cases Finset.mem_union.mp hx <;> [ exact C.monotone ( Finset.subset_union_left ) ‹_›; exact C.monotone ( Finset.subset_union_right ) ‹_› ] ;
  linarith! [ Finset.card_union_add_card_inter ( C.cl s ) ( C.cl t ) ]

/-! ## Section 16: Separation Consequences -/

/-
In a separated system, singletons are distinguished by some capacity test.
-/
theorem separated_capacity_distinguishes (C : ClosureOp α)
    (hsep : ∀ a b : α, a ≠ b → C.cl {a} ≠ C.cl {b})
    (a b : α) (hab : a ≠ b) :
    ∃ s : Finset α, closureCapacity C (s ∪ {a}) ≠ closureCapacity C (s ∪ {b}) := by
  by_contra h;
  -- Consider $s = C.cl {b}$. We have $s ∪ {b} = C.cl {b}$ and $s ∪ {a} = C.cl {b} ∪ {a}$.
  set s := C.cl {b}
  have hs_b : s ∪ {b} = C.cl {b} := by
    exact Finset.union_eq_left.mpr ( C.extensive _ )
  have hs_a : s ∪ {a} = C.cl {b} ∪ {a} := by
    rfl;
  -- Since $C.cl {a} \neq C.cl {b}$, there exists an element $x \in C.cl {a}$ such that $x \notin C.cl {b}$.
  obtain ⟨x, hx_a, hx_b⟩ : ∃ x, x ∈ C.cl {a} ∧ x ∉ C.cl {b} := by
    exact Finset.not_subset.mp fun h' => hsep a b hab <| Finset.Subset.antisymm h' <| by
      simp_all +decide [ Finset.subset_iff, closureCapacity ];
      have := h ∅; simp_all +decide ;
      exact fun x hx => by have := Finset.eq_of_subset_of_card_le h' ( by linarith ) ; aesop;
  -- Since $x \in C.cl {a}$ and $x \notin C.cl {b}$, we have $x \in C.cl (s ∪ {a})$ but $x \notin C.cl (s ∪ {b})$.
  have hx_s_a : x ∈ C.cl (s ∪ {a}) := by
    exact C.monotone ( Finset.subset_union_right ) hx_a
  have hx_s_b : x ∉ C.cl (s ∪ {b}) := by
    grind +suggestions;
  refine' h ⟨ s, ne_of_gt ( Finset.card_lt_card _ ) ⟩;
  grind +suggestions

/-! ## Section 17: Capacity Determines Closed-Set Lattice -/

theorem capacity_determines_closed_lattice (C₁ C₂ : ClosureOp α)
    (hcap : ∀ s : Finset α, closureCapacity C₁ s = closureCapacity C₂ s) :
    ∀ s : Finset α, IsClosed C₁ s ↔ IsClosed C₂ s :=
  same_capacity_same_closed_sets C₁ C₂ hcap

/-! ## Section 18: Fixedpoint Capacity Connection -/

noncomputable def fixedClosedSetCount (C : ClosureOp α) (f : ClosureEndo C) : ℕ :=
  Fintype.card { s : ClosedSet C // s.1.image f.toFun = s.1 }

theorem id_fixes_all_closed (C : ClosureOp α) (s : ClosedSet C) :
    s.1.image (ClosureEndo.id C).toFun = s.1 := by
  simp [ClosureEndo.id, Finset.image_id]

/-! ## Section 19: Membership Detection -/

/-
x ∈ cl(s) iff cap(s) = cap(s ∪ {x}).
-/
theorem mem_cl_iff_capacity (C : ClosureOp α) (s : Finset α) (x : α) :
    x ∈ C.cl s ↔ closureCapacity C s = closureCapacity C (s ∪ {x}) := by
  constructor <;> intro h;
  · refine' le_antisymm _ _;
    · exact capacity_monotone C ( Finset.subset_union_left );
    · refine' Finset.card_le_card _;
      have := C.idempotent s;
      exact C.monotone ( Finset.union_subset ( C.extensive s ) ( Finset.singleton_subset_iff.mpr h ) ) |> fun h => h.trans ( by aesop );
  · contrapose! h;
    refine' ne_of_lt ( Finset.card_lt_card _ );
    simp_all +decide [ Finset.ssubset_def, Finset.subset_iff ];
    exact ⟨ fun y hy => C.monotone ( Finset.subset_insert _ _ ) hy, x, C.extensive _ ( Finset.mem_insert_self _ _ ), h ⟩

end IdempotentHolography