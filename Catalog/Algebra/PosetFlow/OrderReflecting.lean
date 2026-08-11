import Algebra.PosetFlow.ChainPoset

/-!
# Order-reflecting inclusions and the chain replacement

The paper *The chain replacement of a poset flow* shows that the chain replacement
sends inclusions of finite posets to q-cofibrations, and that pushouts along the
chain replacement of an **order-reflecting** inclusion preserve spaces of execution
paths.  This file isolates the combinatorial content of these statements at the
level of the refinement posets of chains, which are the (models of the) spaces of
execution paths.

An order-reflecting inclusion is exactly an `OrderEmbedding` `f : P ↪o Q`.

## Main results

* `PosetFlow.ChainFrom.trace_map` : the *trace* along `f` (intersecting a chain of
  `Q` with the image of `P` and pulling it back) is a monotone retraction of the
  monotone map induced by `f` on chain posets.  Order-reflection is what makes the
  trace well defined.
* `PosetFlow.chainGaloisCoinsertion` : more precisely, the induced map on chain
  posets and the trace form a **Galois coinsertion**.  Adjoint monotone maps induce
  homotopy equivalences of nerves, so this is the combinatorial reason the induced
  map of path spaces is so well behaved.
* `PosetFlow.ChainFrom.isLowerSet_range_map` : the image of the chain poset of `P`
  inside the chain poset of `Q` is a *lower set* for refinement (a sieve): a chain
  coarser than a chain coming from `P` again comes from `P`.  This is the
  cofibration-flavoured statement.
* `PosetFlow.chainOrderEmbedding` : the induced map of chain posets is an order
  embedding, and `PosetFlow.ChainFrom.map_concat` says it is compatible with the
  composition law of the chain replacement.
* `PosetFlow.chainSumEquiv` : the chain poset of `Q` is the disjoint union of the
  chains transported from `P` and those not supported on `P`; combined with the
  lower/upper set statements this is the combinatorial form of "pushouts along the
  chain replacement preserve spaces of execution paths".
* `PosetFlow.orderReflecting_necessary` : a counterexample showing that
  order-reflection cannot be weakened to injective monotonicity: for the inclusion
  of the two-element antichain into the two-element chain there are chains of the
  target entirely supported on the image which are not traces of any chain of the
  source.
-/

namespace PosetFlow

open Finset

section Embedding

variable {P Q : Type*} [PartialOrder P] [PartialOrder Q] [DecidableEq P] [DecidableEq Q]
variable {x y : P}

namespace ChainFrom

/-- The chain of `Q` obtained by transporting a chain of `P` along an order
embedding. -/
def map (f : P ↪o Q) (C : ChainFrom x y) : ChainFrom (f x) (f y) where
  carrier := C.carrier.image f
  mem_source := Finset.mem_image_of_mem _ C.mem_source
  mem_target := Finset.mem_image_of_mem _ C.mem_target
  bounded := by
    rintro _ hb
    obtain ⟨a, ha, rfl⟩ := Finset.mem_image.1 hb
    exact ⟨f.map_rel_iff.2 (C.bounded ha).1, f.map_rel_iff.2 (C.bounded ha).2⟩
  total := by
    rintro u hu v hv
    obtain ⟨a, hamem, rfl⟩ := Finset.mem_image.1 hu
    obtain ⟨b, hbmem, rfl⟩ := Finset.mem_image.1 hv
    rcases C.total hamem hbmem with h | h
    · exact Or.inl (f.map_rel_iff.2 h)
    · exact Or.inr (f.map_rel_iff.2 h)

omit [DecidableEq P] in
@[simp] theorem map_carrier (f : P ↪o Q) (C : ChainFrom x y) :
    (map f C).carrier = C.carrier.image f := rfl

omit [DecidableEq P] in
theorem map_mono (f : P ↪o Q) {C D : ChainFrom x y} (h : C ≤ D) : map f C ≤ map f D :=
  Finset.image_subset_image h

/-- **The trace of a chain of `Q` along an order-reflecting inclusion.**  Only here
is order-reflection used: without it the intersection of a chain of `Q` with the
image of `P` need not be a chain of `P`. -/
noncomputable def trace (f : P ↪o Q) (E : ChainFrom (f x) (f y)) : ChainFrom x y where
  carrier := E.carrier.preimage f (f.injective.injOn)
  mem_source := Finset.mem_preimage.2 E.mem_source
  mem_target := Finset.mem_preimage.2 E.mem_target
  bounded := by
    intro a ha
    rw [Finset.mem_preimage] at ha
    exact ⟨f.map_rel_iff.1 (E.bounded ha).1, f.map_rel_iff.1 (E.bounded ha).2⟩
  total := by
    intro a ha b hb
    rw [Finset.mem_preimage] at ha hb
    rcases E.total ha hb with h | h
    · exact Or.inl (f.map_rel_iff.1 h)
    · exact Or.inr (f.map_rel_iff.1 h)

omit [DecidableEq P] [DecidableEq Q] in
@[simp] theorem mem_trace_carrier (f : P ↪o Q) (E : ChainFrom (f x) (f y)) {a : P} :
    a ∈ (trace f E).carrier ↔ f a ∈ E.carrier :=
  Finset.mem_preimage (hf := f.injective.injOn)

omit [DecidableEq P] [DecidableEq Q] in
theorem trace_mono (f : P ↪o Q) {E E' : ChainFrom (f x) (f y)} (h : E ≤ E') :
    trace f E ≤ trace f E' := by
  intro a ha
  rw [mem_trace_carrier] at ha ⊢
  exact h ha

omit [DecidableEq P] in
/-- The trace is a retraction of the transport map: chains of `P` are recovered from
their images. -/
@[simp] theorem trace_map (f : P ↪o Q) (C : ChainFrom x y) : trace f (map f C) = C := by
  ext1
  apply Finset.Subset.antisymm
  · intro a ha
    have : f a ∈ (map f C).carrier := (mem_trace_carrier f (map f C)).1 ha
    obtain ⟨b, hb, hfb⟩ := Finset.mem_image.1 this
    exact f.injective hfb ▸ hb
  · intro a ha
    exact (mem_trace_carrier f (map f C)).2 (Finset.mem_image_of_mem _ ha)

omit [DecidableEq P] in
/-- Transport along `f` is left adjoint to the trace along `f`. -/
theorem map_le_iff_le_trace (f : P ↪o Q) (C : ChainFrom x y) (E : ChainFrom (f x) (f y)) :
    map f C ≤ E ↔ C ≤ trace f E := by
  constructor
  · intro h a ha
    exact (mem_trace_carrier f E).2 (h (Finset.mem_image_of_mem _ ha))
  · intro h b hb
    obtain ⟨a, ha, rfl⟩ := Finset.mem_image.1 hb
    exact (mem_trace_carrier f E).1 (h ha)

omit [DecidableEq P] in
/-- A chain of `Q` between two points of `P` is the transport of a chain of `P` iff
it is supported on the image of `P`. -/
theorem exists_map_eq_iff (f : P ↪o Q) (E : ChainFrom (f x) (f y)) :
    (∃ C : ChainFrom x y, map f C = E) ↔ ∀ b ∈ E.carrier, b ∈ Set.range f := by
  constructor
  · rintro ⟨C, rfl⟩ b hb
    obtain ⟨a, _, rfl⟩ := Finset.mem_image.1 hb
    exact ⟨a, rfl⟩
  · intro h
    refine ⟨trace f E, ?_⟩
    ext1
    apply Finset.Subset.antisymm
    · intro b hb
      obtain ⟨a, ha, rfl⟩ := Finset.mem_image.1 hb
      exact (mem_trace_carrier f E).1 ha
    · intro b hb
      obtain ⟨a, rfl⟩ := h b hb
      exact Finset.mem_image_of_mem _ ((mem_trace_carrier f E).2 hb)

omit [DecidableEq P] in
/-- Being in the image of the chain map is detected by the trace. -/
theorem map_trace_eq_iff (f : P ↪o Q) (E : ChainFrom (f x) (f y)) :
    (∃ C : ChainFrom x y, map f C = E) ↔ map f (trace f E) = E := by
  constructor
  · rintro ⟨C, rfl⟩
    rw [trace_map]
  · intro h
    exact ⟨trace f E, h⟩

/-- **Functoriality: the chain replacement is a map of flows.**  Transport along `f`
commutes with concatenation of chains, i.e. with the composition law of the chain
replacement. -/
theorem map_concat (f : P ↪o Q) {z : P} (C : ChainFrom x y) (D : ChainFrom y z) :
    map f (concat C D) = concat (map f C) (map f D) := by
  ext1
  simp [Finset.image_union]

/-- Transport along `f` preserves the coarsest chain, i.e. the least element of the
refinement poset. -/
theorem map_coarsest (f : P ↪o Q) (h : x ≤ y) :
    map f (coarsest h) = coarsest (f.monotone h) := by
  ext1
  simp [coarsest_carrier, Finset.image_insert]

omit [DecidableEq P] in
/-- Transport is functorial in the order embedding. -/
theorem map_map {R : Type*} [PartialOrder R] [DecidableEq R] (f : P ↪o Q) (g : Q ↪o R)
    (C : ChainFrom x y) : map g (map f C) = map (f.trans g) C := by
  ext1
  simp [Finset.image_image]

omit [DecidableEq P] in
/-- **Sieve property (cofibration flavour).**  The chains of `Q` that come from `P`
form a lower set for refinement: any chain coarser than the transport of a chain of
`P` is itself the transport of a chain of `P`. -/
theorem isLowerSet_range_map (f : P ↪o Q) :
    IsLowerSet {E : ChainFrom (f x) (f y) | ∃ C : ChainFrom x y, map f C = E} := by
  rintro E E' hle hE
  obtain ⟨C, hC⟩ := hE
  refine (exists_map_eq_iff f E').2 ?_
  intro b hb
  have hb' : b ∈ E.carrier := hle hb
  rw [← hC] at hb'
  obtain ⟨a, _, rfl⟩ := Finset.mem_image.1 hb'
  exact ⟨a, rfl⟩

end ChainFrom

open ChainFrom

/-- The map of refinement posets induced by an order-reflecting inclusion is an order
embedding: the chain replacement of an inclusion of finite posets is an inclusion. -/
def chainOrderEmbedding (f : P ↪o Q) (x y : P) : ChainFrom x y ↪o ChainFrom (f x) (f y) where
  toFun := map f
  inj' := by
    intro C D h
    have := congrArg (trace f) h
    rwa [trace_map, trace_map] at this
  map_rel_iff' := by
    intro C D
    constructor
    · intro h
      have h' : map f C ≤ map f D := h
      have := (map_le_iff_le_trace f C (map f D)).1 h'
      rwa [trace_map] at this
    · exact map_mono f

/-- **The chain replacement of an order-reflecting inclusion is a Galois
coinsertion.**  Transport along `f` is left adjoint to the trace along `f`, and the
trace of a transport is the identity.  Adjoint monotone maps induce homotopy
equivalences of nerves, which is the structural reason why the induced map of path
spaces is so well behaved. -/
noncomputable def chainGaloisCoinsertion (f : P ↪o Q) (x y : P) :
    GaloisCoinsertion (map f : ChainFrom x y → ChainFrom (f x) (f y)) (trace f) where
  choice E _ := trace f E
  gc := fun C E => map_le_iff_le_trace f C E
  u_l_le C := le_of_eq (trace_map f C)
  choice_eq _ _ := rfl

omit [DecidableEq P] in
/-- The chains of `Q` not coming from `P` form an upper set for refinement: a
refinement of a chain not supported on `P` is again not supported on `P`. -/
theorem isUpperSet_compl_range_map (f : P ↪o Q) :
    IsUpperSet {E : ChainFrom (f x) (f y) | ¬ ∃ C : ChainFrom x y, map f C = E} :=
  (ChainFrom.isLowerSet_range_map f).compl

open Classical in
/-- **Attaching along the chain replacement of an order-reflecting inclusion
preserves the space of execution paths.**  The refinement poset of chains of `Q`
from `f x` to `f y` splits as the disjoint union of the chains transported from `P`
and the chains not supported on `P`.  Hence forming a pushout that replaces the
first summand by another space leaves the second summand — and therefore the whole
path space of the pushout — under control: it is the pushout of the path spaces.
The first summand is a lower set and the second an upper set for refinement
(`ChainFrom.isLowerSet_range_map`, `isUpperSet_compl_range_map`). -/
noncomputable def chainSumEquiv (f : P ↪o Q) (x y : P) :
    ChainFrom x y ⊕ {E : ChainFrom (f x) (f y) // ¬ ∃ C : ChainFrom x y, map f C = E} ≃
      ChainFrom (f x) (f y) where
  toFun := Sum.elim (map f) Subtype.val
  invFun E := if h : ∃ C : ChainFrom x y, map f C = E then Sum.inl (trace f E)
    else Sum.inr ⟨E, h⟩
  left_inv := by
    rintro (C | ⟨E, hE⟩)
    · dsimp only [Sum.elim_inl]
      rw [dif_pos ⟨C, rfl⟩, trace_map]
    · dsimp only [Sum.elim_inr]
      rw [dif_neg hE]
  right_inv := by
    intro E
    dsimp only
    by_cases h : ∃ C : ChainFrom x y, map f C = E
    · rw [dif_pos h]
      exact (map_trace_eq_iff f E).1 h
    · rw [dif_neg h]
      rfl

end Embedding

/-!
### Order-reflection is necessary

The two-element antichain maps injectively and monotonically into the two-element
chain, but the unique chain from `0` to `1` of the target is supported on the image
and is not the transport of any chain of the source, since the source has no chain
from one point to the other at all.
-/

/-- The two-element antichain. -/
inductive Antichain2 : Type
  | a : Antichain2
  | b : Antichain2
  deriving DecidableEq

namespace Antichain2

instance : PartialOrder Antichain2 where
  le u v := u = v
  le_refl _ := rfl
  le_trans _ _ _ h₁ h₂ := h₁.trans h₂
  le_antisymm _ _ h _ := h

theorem le_iff {u v : Antichain2} : u ≤ v ↔ u = v := Iff.rfl

/-- The injective monotone (but not order-reflecting) comparison map to the
two-element chain. -/
def toChain2 : Antichain2 → Fin 2
  | a => 0
  | b => 1

theorem toChain2_injective : Function.Injective toChain2 := by
  intro u v h
  cases u <;> cases v <;> simp_all [toChain2]

theorem toChain2_monotone : Monotone toChain2 := by
  intro u v h
  rw [le_iff] at h
  exact le_of_eq (congrArg _ h)

theorem toChain2_not_orderReflecting : ¬ ∀ u v : Antichain2, toChain2 u ≤ toChain2 v → u ≤ v := by
  intro h
  have := h a b (by decide)
  exact absurd (le_iff.1 this) (by decide)

end Antichain2

open PosetFlow.ChainFrom in
/-- **Order-reflection cannot be dropped.**  `Antichain2.toChain2` is an injective
monotone map whose target has a chain from `toChain2 a` to `toChain2 b` supported
entirely on its image, while the source has no chain from `a` to `b` whatsoever.  So
the conclusion of `ChainFrom.exists_map_eq_iff` fails for merely injective monotone
maps. -/
theorem orderReflecting_necessary :
    Function.Injective Antichain2.toChain2 ∧ Monotone Antichain2.toChain2 ∧
      (∀ v ∈ (coarsest (show Antichain2.toChain2 Antichain2.a ≤ Antichain2.toChain2 Antichain2.b
          by decide)).carrier, v ∈ Set.range Antichain2.toChain2) ∧
      IsEmpty (ChainFrom Antichain2.a Antichain2.b) := by
  refine ⟨Antichain2.toChain2_injective, Antichain2.toChain2_monotone, ?_, ?_⟩
  · intro v hv
    rcases Finset.mem_insert.1 hv with rfl | hv
    · exact ⟨Antichain2.a, rfl⟩
    · rw [Finset.mem_singleton] at hv
      subst hv
      exact ⟨Antichain2.b, rfl⟩
  · refine ⟨fun C => ?_⟩
    have := C.source_le_target
    rw [Antichain2.le_iff] at this
    exact absurd this (by decide)

end PosetFlow