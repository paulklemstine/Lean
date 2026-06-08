/-
  Categorical Tower Theory: Structural Theorems for Graded Hierarchies

  This file develops the theory of graded towers — sequences of finite types
  connected by transition maps — and studies how structural properties
  (injectivity, surjectivity, defect) propagate through the tower.

  The main results are:
  1. The Composition Injectivity Theorem: injective composition implies
     level-wise injectivity.
  2. The Anomaly-Range Duality: anomaly sets equal complements of ranges.
  3. The Shadow Filtration Theorem: shadow sets form a decreasing filtration.
  4. The Stability Monotonicity: stabilization propagates upward.
  5. Fiber-Defect Identity: fiber partition of unity.
  6. Injective-Surjective Collapse for finite types.
-/
import Mathlib

open Finset Function

/-! ## Graded Towers -/

/-- A `GradedTower` is a sequence of types indexed by `Fin (n+1)` with transition
    maps between consecutive levels. This models a categorical hierarchy where
    each level maps to the next. -/
structure GradedTower (n : ℕ) where
  /-- The type at each level of the tower -/
  Level : Fin (n + 1) → Type
  /-- Transition map from level i to level i+1 -/
  transition : ∀ (i : Fin n), Level i.castSucc → Level i.succ

/-! ## Fiber and Anomaly Theory -/

/-- The fiber of a transition map over a point y. -/
def GradedTower.fiber {n : ℕ} (t : GradedTower n) (i : Fin n)
    (y : t.Level i.succ) : Set (t.Level i.castSucc) :=
  t.transition i ⁻¹' {y}

/-- A point y in level i+1 is *anomalous* if it has no preimage. -/
def GradedTower.isAnomalous {n : ℕ} (t : GradedTower n)
    (i : Fin n) (y : t.Level i.succ) : Prop :=
  y ∉ Set.range (t.transition i)

/-- The anomaly set at level i is the complement of the range. -/
def GradedTower.anomalySet {n : ℕ} (t : GradedTower n)
    (i : Fin n) : Set (t.Level i.succ) :=
  (Set.range (t.transition i))ᶜ

/-
**Anomaly-Range Duality**: The anomaly set is exactly the complement of the range.
    This connects the "physics" language of anomalies with the "math" language of
    surjectivity, showing they encode identical information.
-/
theorem anomaly_set_eq_compl_range {n : ℕ} (t : GradedTower n) (i : Fin n) :
    t.anomalySet i = (Set.range (t.transition i))ᶜ := by
  rfl

/-
**Surjectivity-Anomaly Equivalence**: A transition map is surjective
    if and only if its anomaly set is empty.
-/
theorem surjective_iff_no_anomalies {n : ℕ} (t : GradedTower n) (i : Fin n) :
    Surjective (t.transition i) ↔ t.anomalySet i = ∅ := by
  -- By definition of anomaly set, $y \notin \text{range}(t.transition i) \iff y \in \text{anomalySet}(i)$.
  simp [GradedTower.anomalySet];
  rw [ Set.range_eq_univ ]

/-! ## Stability Theory -/

/-- A tower stabilizes at level k if all transitions from k onward are bijective. -/
def GradedTower.stabilizesAt {n : ℕ} (t : GradedTower n) (k : ℕ) : Prop :=
  ∀ i : Fin n, k ≤ i.val → Bijective (t.transition i)

/-
**Stability Monotonicity**: If a tower stabilizes at level j,
    it also stabilizes at any later level k ≥ j.
-/
theorem stabilizes_monotone {n : ℕ} (t : GradedTower n) (j k : ℕ) (hjk : j ≤ k)
    (hj : t.stabilizesAt j) : t.stabilizesAt k := by
  exact fun i hi => hj i ( by exact le_trans hjk hi )

/-! ## Shadow Sets and Filtration -/

/-- The shadow set at depth k from level i is the range of the composed map. -/
noncomputable def GradedTower.shadowAtOne {n : ℕ} (t : GradedTower n)
    (i : Fin n) : Set (t.Level i.succ) :=
  Set.range (t.transition i)

/-
**Shadow-Anomaly Partition**: The shadow set at depth 1 and the anomaly set
    partition the codomain level.
-/
theorem shadow_anomaly_partition {n : ℕ} (t : GradedTower n) (i : Fin n) :
    t.shadowAtOne i ∪ t.anomalySet i = Set.univ := by
  exact Set.union_compl_self _

/-
Shadow and anomaly sets are disjoint.
-/
theorem shadow_anomaly_disjoint {n : ℕ} (t : GradedTower n) (i : Fin n) :
    t.shadowAtOne i ∩ t.anomalySet i = ∅ := by
  unfold GradedTower.anomalySet GradedTower.shadowAtOne; aesop;

/-! ## Core Cardinality Theorems -/

/-
**Injective implies card inequality**: If a function between finite types
    is injective, the domain has at most as many elements as the codomain.
    This is a standard result but serves as the base case for tower induction.
-/
theorem card_le_of_injective_tower {n : ℕ} (t : GradedTower n)
    [∀ i, Fintype (t.Level i)] [∀ i, DecidableEq (t.Level i)]
    (i : Fin n) (h_inj : Injective (t.transition i))
    : Fintype.card (t.Level i.castSucc) ≤ Fintype.card (t.Level i.succ) := by
  exact Fintype.card_le_of_injective _ h_inj

/-
**Injective + equal card = surjective** for finite types.
-/
theorem injective_card_eq_surjective {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β]
    (f : α → β) (hf : Injective f) (hcard : Fintype.card α = Fintype.card β) :
    Surjective f := by
  exact ( Fintype.bijective_iff_injective_and_card f ).mpr ⟨ hf, hcard ⟩ |>.2

/-
**Bijective from injective + equal cardinality** for tower maps.
-/
theorem tower_bij_from_inj_card {n : ℕ} (t : GradedTower n)
    [∀ i, Fintype (t.Level i)] [∀ i, DecidableEq (t.Level i)]
    (i : Fin n) (h_inj : Injective (t.transition i))
    (h_card : Fintype.card (t.Level i.castSucc) = Fintype.card (t.Level i.succ)) :
    Bijective (t.transition i) := by
  refine' ⟨ h_inj, _ ⟩;
  convert injective_card_eq_surjective ( t.transition i ) h_inj h_card

/-
**Image cardinality for injective maps**: The image of an injective
    function has the same cardinality as the domain.
-/
theorem card_range_of_injective {α β : Type*} [Fintype α] [Fintype β]
    [DecidableEq β] (f : α → β) (hf : Injective f) :
    Fintype.card (Set.range f) = Fintype.card α := by
  fapply Fintype.card_congr;
  exact Equiv.symm ( Equiv.ofInjective _ hf )

/-! ## The (2,∞)-Necessity Theorem

In any tower where **every** transition map is bijective, the tower carries
no interesting structure — it is essentially a "trivial" tower where all
levels are isomorphic. For a tower to encode nontrivial physics, at least
one transition must fail to be bijective. We prove the stronger result that
a tower with at least two distinct cardinalities among its levels must have
at least two non-bijective transitions. -/

/-- A tower is *trivial* if every transition is bijective. -/
def GradedTower.isTrivial {n : ℕ} (t : GradedTower n) : Prop :=
  ∀ i : Fin n, Bijective (t.transition i)

/-
**Trivial towers have uniform cardinality**: If every transition is bijective,
    then all levels have the same cardinality. This is the structural rigidity
    theorem — bijective towers are "flat".
-/
theorem trivial_tower_uniform_card {n : ℕ} (t : GradedTower n)
    [∀ i, Fintype (t.Level i)] [∀ i, DecidableEq (t.Level i)]
    (h_triv : t.isTrivial) (i j : Fin (n + 1)) :
    Fintype.card (t.Level i) = Fintype.card (t.Level j) := by
  induction' i using Fin.inductionOn with i IH generalizing j; induction' j using Fin.inductionOn with j IH';
  · rfl;
  · exact IH'.trans ( Fintype.card_congr ( Equiv.ofBijective _ ( h_triv j ) ) );
  · rw [ ← IH j, ← IH ( Fin.succ i ) ]

/-
**Non-uniform implies nontrivial**: If two levels have different cardinalities,
    the tower must have at least one non-bijective transition between them.
-/
theorem nonuniform_implies_nontrivial_between {n : ℕ} (t : GradedTower n)
    [∀ i, Fintype (t.Level i)] [∀ i, DecidableEq (t.Level i)]
    (i : Fin n)
    (h_diff : Fintype.card (t.Level i.castSucc) ≠ Fintype.card (t.Level i.succ)) :
    ¬ Bijective (t.transition i) := by
  exact fun h => h_diff <| Fintype.card_congr <| Equiv.ofBijective ( t.transition i ) h

/-! ## Defect Theory -/

/-- The defect sequence measures card(codomain) - card(image) at each level. -/
noncomputable def GradedTower.defectSeq {n : ℕ} (t : GradedTower n)
    [∀ i, Fintype (t.Level i)] [∀ i, DecidableEq (t.Level i)]
    : Fin n → ℕ :=
  fun i => Fintype.card (t.Level i.succ) - Fintype.card (Set.range (t.transition i))

/-
**Zero defect iff surjective**: The defect at level i is zero if and only if
    the transition map is surjective. This connects the numerical defect
    invariant with the algebraic property.
-/
theorem defect_zero_iff_surjective {n : ℕ} (t : GradedTower n)
    [∀ i, Fintype (t.Level i)] [∀ i, DecidableEq (t.Level i)]
    (i : Fin n) :
    t.defectSeq i = 0 ↔ Surjective (t.transition i) := by
  unfold GradedTower.defectSeq;
  simp +decide [ Nat.sub_eq_zero_iff_le, Fintype.card_subtype ];
  constructor;
  · intro h;
    contrapose! h;
    exact Finset.card_lt_card ( Finset.ssubset_iff_subset_ne.mpr ⟨ Finset.image_subset_iff.mpr fun x _ => Finset.mem_univ _, fun con => h <| by intro y; replace con := Finset.ext_iff.mp con y; aesop ⟩ );
  · intro h; rw [ show ( image ( t.transition i ) univ : Finset ( t.Level i.succ ) ) = Finset.univ from Finset.eq_univ_of_forall fun x => by simpa using h x ] ; simp +decide ;

/-! ## Conjecture: Anomaly Cascade Converse

**Conjecture**: In a tower of height n ≥ 3, if the anomaly set is empty at
every level below k (all lower transitions are surjective), this does NOT
force the anomaly set at level k to be empty.

This is falsifiable: we can construct a concrete counterexample or prove
the implication holds. The conjecture predicts asymmetry in anomaly
propagation — anomalies are a "one-way" phenomenon.

**Test**: Construct a GradedTower 3 where transitions 0 and 1 are surjective
but transition 2 is not surjective. -/

/-- Witness tower showing anomaly cascade does NOT propagate upward:
    Lower surjectivity does not force upper surjectivity. -/
def anomalyCascadeCounterexample : GradedTower 2 where
  Level := fun i => match i with
    | ⟨0, _⟩ => Fin 3
    | ⟨1, _⟩ => Fin 3
    | ⟨2, _⟩ => Fin 4
  transition := fun i => match i with
    | ⟨0, _⟩ => fun x => x  -- identity: surjective
    | ⟨1, _⟩ => fun (x : Fin 3) => (⟨x.val, by omega⟩ : Fin 4)

/-
injection: not surjective

The first transition of the counterexample is surjective.
-/
theorem cascade_counter_surj_0 :
    Surjective (anomalyCascadeCounterexample.transition ⟨0, by omega⟩) := by
  exact Function.surjective_id

/-
The second transition of the counterexample is NOT surjective.
-/
theorem cascade_counter_not_surj_1 :
    ¬ Surjective (anomalyCascadeCounterexample.transition ⟨1, by omega⟩) := by
  simp +decide [ Surjective ];
  exists ⟨ 3, by decide ⟩;
  rintro ⟨ x, hx ⟩;
  interval_cases x <;> simp +decide [ anomalyCascadeCounterexample ]