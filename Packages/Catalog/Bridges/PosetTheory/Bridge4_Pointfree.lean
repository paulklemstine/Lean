import Mathlib

/-! # CatalogBuild.Speculative.RosettaStone.Bridge4_Pointfree

Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 13
-/

variable {α : Type*} {X : Type*} [TopologicalSpace X]

/-- In any semilattice, meet is idempotent. -/
theorem inf_idempotent [SemilatticeInf α] (a : α) : a ⊓ a = a := inf_idem a

/-- In any semilattice, join is idempotent. -/
theorem sup_idempotent [SemilatticeSup α] (a : α) : a ⊔ a = a := sup_idem a

/-- Absorption law: a ⊓ (a ⊔ b) = a. -/
theorem absorption_inf_sup [Lattice α] (a b : α) : a ⊓ (a ⊔ b) = a := inf_sup_self

/-- Absorption law: a ⊔ (a ⊓ b) = a. -/
theorem absorption_sup_inf [Lattice α] (a b : α) : a ⊔ (a ⊓ b) = a := sup_inf_self

/-- Distributivity: a ⊓ (b ⊔ c) = (a ⊓ b) ⊔ (a ⊓ c). -/
theorem frame_distrib [DistribLattice α] (a b c : α) :
    a ⊓ (b ⊔ c) = (a ⊓ b) ⊔ (a ⊓ c) := inf_sup_left a b c

/-- A complemented element decomposes any element. -/
theorem complemented_decomposition [DistribLattice α] [BoundedOrder α]
    (a b : α) (h_sup : a ⊔ b = ⊤) (h_inf : a ⊓ b = ⊥)
    (x : α) : x = (x ⊓ a) ⊔ (x ⊓ b) := by
  rw [← inf_sup_left, h_sup, inf_top_eq]

/-- Closure is idempotent. -/
theorem closure_idempotent_set (s : Set X) :
    closure (closure s) = closure s :=
  isClosed_closure.closure_eq

/-- Interior ⊆ set ⊆ closure.  (Renamed from `interior_subset_closure`, which clashes
with Mathlib's lemma of that name.) -/
theorem interior_subset_closure_of_set (s : Set X) :
    interior s ⊆ closure s :=
  interior_subset.trans subset_closure

/-- Clopen sets are exactly the fixed points of both interior and closure. -/
theorem clopen_iff_interior_eq_closure_eq (s : Set X) :
    IsClopen s ↔ (interior s = s ∧ closure s = s) := by
  constructor
  · intro ⟨hclosed, hopen⟩
    exact ⟨hopen.interior_eq, hclosed.closure_eq⟩
  · intro ⟨hint, hcl⟩
    exact ⟨closure_eq_iff_isClosed.mp hcl, hint ▸ isOpen_interior⟩

/-- [Section: # CatalogBuild.Speculative.RosettaStone.Bridge4_Pointfree
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 13] -/
theorem open_inter {U V : Set X} (hU : IsOpen U) (hV : IsOpen V) :
    IsOpen (U ∩ V) := hU.inter hV

/-- [Section: # CatalogBuild.Speculative.RosettaStone.Bridge4_Pointfree
Auto-generated from theorem catalog database.
Domain: Speculative/RosettaStone
Declarations: 13] -/
theorem open_union {U V : Set X} (hU : IsOpen U) (hV : IsOpen V) :
    IsOpen (U ∪ V) := hU.union hV

theorem open_univ_set : IsOpen (Set.univ : Set X) := isOpen_univ

theorem open_empty_set : IsOpen (∅ : Set X) := isOpen_empty