import Algebra.PosetFlow.OrderComplexEuler

/-!
# The refinement poset of strictly increasing chains of a poset

This file formalises the combinatorial core of the *chain replacement of a poset
flow*.  For a poset `P` and `x y : P`, the paper considers the poset of strictly
increasing chains from `x` to `y`, ordered by refinement, and takes its simplicial
nerve as the space of execution paths from `x` to `y` of the replacement flow.

Here a chain from `x` to `y` is recorded by its underlying finite set
(`PosetFlow.ChainFrom x y`): a finite, totally ordered subset of `P` containing `x`
and `y` and contained in the interval `[x, y]`.  Refinement is inclusion of
carriers.  We prove:

* `PosetFlow.ChainFrom.bot_le` : the chain `{x, y}` is the least element, so the
  refinement poset is a cone.  This is why the chain replacement of a poset flow is
  a *replacement*: its path spaces are contractible.
* `PosetFlow.alternatingSum_chainFrom_eq_zero` : the Euler-characteristic shadow of
  that contractibility, obtained from `OrderComplexEuler`.
* `PosetFlow.ChainFrom.concat` and `PosetFlow.ChainFrom.concat_assoc` : the
  composition law of the chain replacement (a poset-enriched semicategory
  structure), which is monotone in each variable.
* `PosetFlow.chainSplitOrderIso` : the *unique factorisation* of a chain through an
  intermediate point, as an order isomorphism
  `{E : ChainFrom x z // y ∈ E} ≃o ChainFrom x y × ChainFrom y z`.  This is the
  combinatorial statement which, at the level of flows, says that concatenation
  identifies path spaces of composites.
-/

namespace PosetFlow

open Finset

variable {P : Type*} [PartialOrder P] [DecidableEq P] [DecidableLE P]

/-- A (strictly increasing) chain from `x` to `y` in a poset, recorded by its
underlying finite set: it is totally ordered, contains `x` and `y`, and lies in the
interval `[x, y]`. -/
structure ChainFrom (x y : P) where
  /-- the underlying finite set of the chain -/
  carrier : Finset P
  mem_source : x ∈ carrier
  mem_target : y ∈ carrier
  bounded : ∀ ⦃a⦄, a ∈ carrier → x ≤ a ∧ a ≤ y
  total : ∀ ⦃a⦄, a ∈ carrier → ∀ ⦃b⦄, b ∈ carrier → a ≤ b ∨ b ≤ a

namespace ChainFrom

variable {x y z w : P}

omit [DecidableEq P] [DecidableLE P] in
@[ext] theorem ext {C D : ChainFrom x y} (h : C.carrier = D.carrier) : C = D := by
  cases C; cases D; simp_all

omit [DecidableEq P] [DecidableLE P] in
theorem carrier_injective : Function.Injective (ChainFrom.carrier : ChainFrom x y → Finset P) :=
  fun _ _ h => ext h

/-- Refinement order: a chain is below a chain refining it. -/
instance instPartialOrder : PartialOrder (ChainFrom x y) where
  le C D := C.carrier ⊆ D.carrier
  le_refl _ := Finset.Subset.refl _
  le_trans _ _ _ h₁ h₂ := Finset.Subset.trans h₁ h₂
  le_antisymm _ _ h₁ h₂ := ext (Finset.Subset.antisymm h₁ h₂)

omit [DecidableEq P] [DecidableLE P] in
theorem le_iff {C D : ChainFrom x y} : C ≤ D ↔ C.carrier ⊆ D.carrier := Iff.rfl

instance : DecidableEq (ChainFrom x y) := fun C D =>
  decidable_of_iff (C.carrier = D.carrier) ⟨ext, fun h => h ▸ rfl⟩

instance : DecidableLE (ChainFrom x y) := fun C D =>
  decidable_of_iff (C.carrier ⊆ D.carrier) le_iff.symm

noncomputable instance [Fintype P] : Fintype (ChainFrom x y) :=
  Fintype.ofInjective _ carrier_injective

omit [DecidableEq P] [DecidableLE P] in
/-- A chain from `x` to `y` can only exist when `x ≤ y`. -/
theorem source_le_target (C : ChainFrom x y) : x ≤ y := (C.bounded C.mem_target).1

/-- The coarsest chain from `x` to `y`, namely `{x, y}`. -/
def coarsest (h : x ≤ y) : ChainFrom x y where
  carrier := {x, y}
  mem_source := by simp
  mem_target := by simp
  bounded := by
    intro a ha
    rcases Finset.mem_insert.1 ha with rfl | ha
    · exact ⟨le_refl _, h⟩
    · rw [Finset.mem_singleton] at ha; subst ha; exact ⟨h, le_refl _⟩
  total := by
    intro a ha b hb
    have hx : ∀ c ∈ ({x, y} : Finset P), c = x ∨ c = y := by
      intro c hc
      rcases Finset.mem_insert.1 hc with rfl | hc
      · exact Or.inl rfl
      · exact Or.inr (Finset.mem_singleton.1 hc)
    rcases hx a ha with rfl | rfl <;> rcases hx b hb with rfl | rfl
    · exact Or.inl (le_refl _)
    · exact Or.inl h
    · exact Or.inr h
    · exact Or.inl (le_refl _)

omit [DecidableLE P] in
@[simp] theorem coarsest_carrier (h : x ≤ y) : (coarsest h).carrier = {x, y} := rfl

omit [DecidableLE P] in
/-- **The refinement poset of chains is a cone**: `{x, y}` refines into every chain
from `x` to `y`.  This is the combinatorial reason why the chain replacement of a
poset flow has contractible spaces of execution paths. -/
theorem coarsest_le (h : x ≤ y) (C : ChainFrom x y) : coarsest h ≤ C := by
  rw [le_iff, coarsest_carrier]
  intro a ha
  rcases Finset.mem_insert.1 ha with rfl | ha
  · exact C.mem_source
  · rw [Finset.mem_singleton] at ha; subst ha; exact C.mem_target

/-- The refinement poset of chains from `x` to `y` has a least element as soon as
`x ≤ y`. -/
def orderBot (h : x ≤ y) : OrderBot (ChainFrom x y) where
  bot := coarsest h
  bot_le := coarsest_le h

omit [DecidableLE P] in
theorem nonempty_iff : Nonempty (ChainFrom x y) ↔ x ≤ y :=
  ⟨fun ⟨C⟩ => C.source_le_target, fun h => ⟨coarsest h⟩⟩

/-- Concatenation of chains: the composition law of the chain replacement. -/
def concat (C : ChainFrom x y) (D : ChainFrom y z) : ChainFrom x z where
  carrier := C.carrier ∪ D.carrier
  mem_source := Finset.mem_union_left _ C.mem_source
  mem_target := Finset.mem_union_right _ D.mem_target
  bounded := by
    intro a ha
    rcases Finset.mem_union.1 ha with ha | ha
    · exact ⟨(C.bounded ha).1, le_trans (C.bounded ha).2 (D.source_le_target)⟩
    · exact ⟨le_trans C.source_le_target (D.bounded ha).1, (D.bounded ha).2⟩
  total := by
    intro a ha b hb
    rcases Finset.mem_union.1 ha with ha | ha <;> rcases Finset.mem_union.1 hb with hb | hb
    · exact C.total ha hb
    · exact Or.inl (le_trans (C.bounded ha).2 (D.bounded hb).1)
    · exact Or.inr (le_trans (C.bounded hb).2 (D.bounded ha).1)
    · exact D.total ha hb

omit [DecidableLE P] in
@[simp] theorem concat_carrier (C : ChainFrom x y) (D : ChainFrom y z) :
    (concat C D).carrier = C.carrier ∪ D.carrier := rfl

omit [DecidableLE P] in
/-- Concatenation is associative: the chain replacement is a semicategory enriched
in posets. -/
theorem concat_assoc (C : ChainFrom x y) (D : ChainFrom y z) (E : ChainFrom z w) :
    concat (concat C D) E = concat C (concat D E) := by
  ext1; simp [Finset.union_assoc]

omit [DecidableLE P] in
/-- Concatenating with a fixed chain on the right is monotone. -/
theorem concat_mono_left {C C' : ChainFrom x y} (D : ChainFrom y z) (h : C ≤ C') :
    concat C D ≤ concat C' D :=
  Finset.union_subset_union h (Finset.Subset.refl _)

omit [DecidableLE P] in
/-- Concatenating with a fixed chain on the left is monotone. -/
theorem concat_mono_right (C : ChainFrom x y) {D D' : ChainFrom y z} (h : D ≤ D') :
    concat C D ≤ concat C D' :=
  Finset.union_subset_union (Finset.Subset.refl _) h

omit [DecidableLE P] in
theorem mem_concat_middle (C : ChainFrom x y) (D : ChainFrom y z) :
    y ∈ (concat C D).carrier := Finset.mem_union_left _ C.mem_target

/-- The initial segment of a chain through an intermediate point `y`. -/
def restrictLeft (E : ChainFrom x z) (hy : y ∈ E.carrier) : ChainFrom x y where
  carrier := E.carrier.filter (· ≤ y)
  mem_source := Finset.mem_filter.2 ⟨E.mem_source, (E.bounded hy).1⟩
  mem_target := Finset.mem_filter.2 ⟨hy, le_refl _⟩
  bounded := by
    intro a ha
    rw [Finset.mem_filter] at ha
    exact ⟨(E.bounded ha.1).1, ha.2⟩
  total := by
    intro a ha b hb
    rw [Finset.mem_filter] at ha hb
    exact E.total ha.1 hb.1

/-- The terminal segment of a chain through an intermediate point `y`. -/
def restrictRight (E : ChainFrom x z) (hy : y ∈ E.carrier) : ChainFrom y z where
  carrier := E.carrier.filter (y ≤ ·)
  mem_source := Finset.mem_filter.2 ⟨hy, le_refl _⟩
  mem_target := Finset.mem_filter.2 ⟨E.mem_target, (E.bounded hy).2⟩
  bounded := by
    intro a ha
    rw [Finset.mem_filter] at ha
    exact ⟨ha.2, (E.bounded ha.1).2⟩
  total := by
    intro a ha b hb
    rw [Finset.mem_filter] at ha hb
    exact E.total ha.1 hb.1

omit [DecidableEq P] in
@[simp] theorem restrictLeft_carrier (E : ChainFrom x z) (hy : y ∈ E.carrier) :
    (restrictLeft E hy).carrier = E.carrier.filter (· ≤ y) := rfl

omit [DecidableEq P] in
@[simp] theorem restrictRight_carrier (E : ChainFrom x z) (hy : y ∈ E.carrier) :
    (restrictRight E hy).carrier = E.carrier.filter (y ≤ ·) := rfl

omit [DecidableEq P] in
theorem restrictLeft_mono {E E' : ChainFrom x z} (hy : y ∈ E.carrier) (hy' : y ∈ E'.carrier)
    (h : E ≤ E') : restrictLeft E hy ≤ restrictLeft E' hy' := by
  rw [le_iff, restrictLeft_carrier, restrictLeft_carrier]
  exact Finset.filter_subset_filter _ h

omit [DecidableEq P] in
theorem restrictRight_mono {E E' : ChainFrom x z} (hy : y ∈ E.carrier) (hy' : y ∈ E'.carrier)
    (h : E ≤ E') : restrictRight E hy ≤ restrictRight E' hy' := by
  rw [le_iff, restrictRight_carrier, restrictRight_carrier]
  exact Finset.filter_subset_filter _ h

/-- A chain through `y` is the concatenation of its two segments at `y`. -/
theorem concat_restrict (E : ChainFrom x z) (hy : y ∈ E.carrier) :
    concat (restrictLeft E hy) (restrictRight E hy) = E := by
  ext1
  apply Finset.Subset.antisymm
  · intro a ha
    simp only [concat_carrier, restrictLeft_carrier, restrictRight_carrier,
      Finset.mem_union, Finset.mem_filter] at ha
    tauto
  · intro a ha
    simp only [concat_carrier, restrictLeft_carrier, restrictRight_carrier,
      Finset.mem_union, Finset.mem_filter]
    rcases E.total ha hy with h | h
    · exact Or.inl ⟨ha, h⟩
    · exact Or.inr ⟨ha, h⟩

theorem restrictLeft_concat (C : ChainFrom x y) (D : ChainFrom y z) :
    restrictLeft (concat C D) (mem_concat_middle C D) = C := by
  ext1
  apply Finset.Subset.antisymm
  · intro a ha
    simp only [restrictLeft_carrier, Finset.mem_filter, concat_carrier] at ha
    rcases Finset.mem_union.1 ha.1 with h | h
    · exact h
    · have : a = y := le_antisymm ha.2 (D.bounded h).1
      exact this ▸ C.mem_target
  · intro a ha
    simp only [restrictLeft_carrier, Finset.mem_filter, concat_carrier]
    exact ⟨Finset.mem_union_left _ ha, (C.bounded ha).2⟩

theorem restrictRight_concat (C : ChainFrom x y) (D : ChainFrom y z) :
    restrictRight (concat C D) (mem_concat_middle C D) = D := by
  ext1
  apply Finset.Subset.antisymm
  · intro a ha
    simp only [restrictRight_carrier, Finset.mem_filter, concat_carrier] at ha
    rcases Finset.mem_union.1 ha.1 with h | h
    · have : a = y := le_antisymm (C.bounded h).2 ha.2
      exact this ▸ D.mem_source
    · exact h
  · intro a ha
    simp only [restrictRight_carrier, Finset.mem_filter, concat_carrier]
    exact ⟨Finset.mem_union_right _ ha, (D.bounded ha).1⟩

end ChainFrom

open ChainFrom

/-- **Unique factorisation of chains through an intermediate point.**
Concatenation is an order isomorphism from the product of the refinement posets
`ChainFrom x y` and `ChainFrom y z` onto the sub-poset of chains from `x` to `z`
passing through `y`.  At the level of flows this is the statement that the
composition law of the chain replacement identifies the path spaces of composable
pairs with the corresponding piece of the path space of the composite. -/
def chainSplitOrderIso (x y z : P) :
    ChainFrom x y × ChainFrom y z ≃o {E : ChainFrom x z // y ∈ E.carrier} where
  toFun p := ⟨concat p.1 p.2, mem_concat_middle p.1 p.2⟩
  invFun E := (restrictLeft E.1 E.2, restrictRight E.1 E.2)
  left_inv p := by
    ext1
    · exact restrictLeft_concat p.1 p.2
    · exact restrictRight_concat p.1 p.2
  right_inv E := by
    ext1
    exact concat_restrict E.1 E.2
  map_rel_iff' := by
    rintro ⟨C, D⟩ ⟨C', D'⟩
    constructor
    · intro h
      have h' : concat C D ≤ concat C' D' := h
      refine ⟨?_, ?_⟩
      · have h2 := restrictLeft_mono (mem_concat_middle C D) (mem_concat_middle C' D') h'
        rwa [restrictLeft_concat, restrictLeft_concat] at h2
      · have h2 := restrictRight_mono (mem_concat_middle C D) (mem_concat_middle C' D') h'
        rwa [restrictRight_concat, restrictRight_concat] at h2
    · rintro ⟨h₁, h₂⟩
      exact Finset.union_subset_union h₁ h₂

omit [DecidableLE P] in
/-- **Euler-contractibility of the spaces of execution paths of the chain
replacement.**  For `x ≤ y` in a finite poset, the order complex of the refinement
poset of chains from `x` to `y` has vanishing reduced Euler characteristic; this is
the numerical shadow of the contractibility of the simplicial nerve used to define
the chain replacement of a poset flow. -/
theorem alternatingSum_chainFrom_eq_zero [Fintype P] {x y : P} (h : x ≤ y) :
    ∑ C ∈ orderComplex (ChainFrom x y), (-1 : ℤ) ^ C.card = 0 :=
  alternatingSum_orderComplex_eq_zero_of_conePoint (coarsest h)
    fun C => Or.inl (coarsest_le h C)

omit [DecidableLE P] in
/-- Reduced form of `alternatingSum_chainFrom_eq_zero`: the alternating sum over the
nonempty faces of the order complex of the chain poset is `-1`, i.e. its Euler
characteristic is that of a point. -/
theorem reducedEuler_chainFrom [Fintype P] {x y : P} (h : x ≤ y) :
    ∑ C ∈ (orderComplex (ChainFrom x y)).erase ∅, (-1 : ℤ) ^ C.card = -1 :=
  reducedEuler_eq_zero_of_conePoint (coarsest h) fun C => Or.inl (coarsest_le h C)

end PosetFlow