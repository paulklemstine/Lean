import Mathlib

/-!
# Dream Logic: Non-Monotone Paraconsistent Reasoning

## Overview

This module formalizes a paraconsistent, non-monotone logic system inspired by
dream-like reasoning where contradictions coexist without explosion. We establish:

1. **Belnap's Four-Valued Logic** as a De Morgan algebra
2. **Explosion Failure** contrasted with classical logic
3. **Pre-Topological Spaces** strictly generalizing topological spaces
4. **Non-Monotone Default Reasoning** where adding information retracts conclusions
5. **Dream-Topology Correspondence** linking paraconsistency to pre-topological structure

## Main Definitions

* `BelnapVal` — Four-valued truth values with independent truth and falsity support
* `PreTopologicalSpace` — Spaces with finite but not arbitrary union closure
* `DreamFrame` — Possible-worlds semantics with four-valued valuations
* `DefaultTheory` — Non-monotone reasoning with defaults and exceptions

## Main Results

* `deMorgan_conj` / `deMorgan_disj` — De Morgan laws in four-valued logic
* `belnap_explosion_fails` — Contradictions don't trivialize the system
* `finiteOrUniv_not_topology` — Pre-topologies strictly extend topologies
* `default_non_monotone` — Default reasoning is non-monotone
* `dream_explosion_failure` — Frame-theoretic explosion failure
* `designatedSet_bconj_eq_inter` — Logic-topology bridge
-/

namespace DreamLogic

-- ============================================================================
-- SECTION 1: Belnap's Four-Valued Logic
-- ============================================================================

/-- Belnap's four-valued truth value, encoded as a pair of Booleans representing
    independent evidence for truth and for falsity. This yields four values:
    - `⟨false, false⟩` — Neither (no information, unknown)
    - `⟨true, false⟩`  — True only (consistent truth)
    - `⟨false, true⟩`  — False only (consistent falsity)
    - `⟨true, true⟩`   — Both (contradictory information) -/
@[ext]
structure BelnapVal where
  truth : Bool
  falsity : Bool
  deriving DecidableEq

namespace BelnapVal

/-- Neither true nor false — represents complete ignorance -/
def neither : BelnapVal := ⟨false, false⟩
/-- True only — consistent positive evidence -/
def trueOnly : BelnapVal := ⟨true, false⟩
/-- False only — consistent negative evidence -/
def falseOnly : BelnapVal := ⟨false, true⟩
/-- Both true and false — contradictory evidence from different sources -/
def both : BelnapVal := ⟨true, true⟩

/-- A value is **designated** (accepted as "at least true") when it carries
    truth support. Both `trueOnly` and `both` are designated. -/
def isDesignated (v : BelnapVal) : Prop := v.truth = true

instance : DecidablePred isDesignated := fun v =>
  if h : v.truth = true then isTrue h else isFalse h

/-- Belnap negation swaps truth and falsity evidence.
    Critically, `bneg both = both` — contradictions are negation-fixed-points. -/
def bneg (v : BelnapVal) : BelnapVal := ⟨v.falsity, v.truth⟩

/-- Belnap conjunction: truth requires both; falsity requires either -/
def bconj (a b : BelnapVal) : BelnapVal := ⟨a.truth && b.truth, a.falsity || b.falsity⟩

/-- Belnap disjunction: truth requires either; falsity requires both -/
def bdisj (a b : BelnapVal) : BelnapVal := ⟨a.truth || b.truth, a.falsity && b.falsity⟩

-- ---- Core Algebraic Properties ----

/-- Negation is an involution: double negation returns the original value -/
@[simp] theorem bneg_involutive (v : BelnapVal) : bneg (bneg v) = v := by
  ext <;> simp [bneg]

/-- Both is a fixed point of negation — the hallmark of paraconsistency -/
@[simp] theorem bneg_both : bneg both = both := rfl

/-- Neither is a fixed point of negation — absence of evidence is symmetric -/
@[simp] theorem bneg_neither : bneg neither = neither := rfl

/-
**De Morgan's first law**: ¬(a ∧ b) = ¬a ∨ ¬b
-/
theorem deMorgan_conj (a b : BelnapVal) :
    bneg (bconj a b) = bdisj (bneg a) (bneg b) := by
  cases a ; cases b ; aesop

/-
**De Morgan's second law**: ¬(a ∨ b) = ¬a ∧ ¬b
-/
theorem deMorgan_disj (a b : BelnapVal) :
    bneg (bdisj a b) = bconj (bneg a) (bneg b) := by
  cases a ; cases b ; aesop

/-
Designation distributes over conjunction: a ∧ b is designated iff both are
-/
theorem isDesignated_bconj_iff (a b : BelnapVal) :
    isDesignated (bconj a b) ↔ isDesignated a ∧ isDesignated b := by
  grind +locals

/-
Designation distributes over disjunction: a ∨ b is designated iff either is
-/
theorem isDesignated_bdisj_iff (a b : BelnapVal) :
    isDesignated (bdisj a b) ↔ isDesignated a ∨ isDesignated b := by
  cases a ; cases b ; simp +decide [ *, BelnapVal.isDesignated ];
  rename_i a b c d; cases a <;> cases b <;> cases c <;> cases d <;> trivial;

/-- **Information ordering**: v₁ ≤ᵢ v₂ when v₂ carries all evidence that v₁ carries.
    This orders BelnapVal as: neither ≤ trueOnly, neither ≤ falseOnly,
    trueOnly ≤ both, falseOnly ≤ both. -/
def infoLE (v₁ v₂ : BelnapVal) : Prop :=
  (v₁.truth = true → v₂.truth = true) ∧ (v₁.falsity = true → v₂.falsity = true)

/-- Neither is the bottom of the information ordering (carries no evidence) -/
theorem neither_is_info_bot (v : BelnapVal) : infoLE neither v :=
  ⟨fun h => by simp [neither] at h, fun h => by simp [neither] at h⟩

/-- Both is the top of the information ordering (carries all possible evidence) -/
theorem both_is_info_top (v : BelnapVal) : infoLE v both :=
  ⟨fun _ => rfl, fun _ => rfl⟩

/-
**Contradiction emergence**: If a value carries both truth evidence
    (like trueOnly) and falsity evidence (like falseOnly), it must be `both`.
    This shows contradictions arise necessarily from combining opposing evidence.
-/
theorem info_join_yields_contradiction :
    ∀ v : BelnapVal, infoLE trueOnly v → infoLE falseOnly v → v = both := by
  intros v hv1 hv2; cases v; simp_all +decide [ BelnapVal.infoLE ] ;

end BelnapVal

-- ============================================================================
-- SECTION 2: Explosion — Classical vs Paraconsistent
-- ============================================================================

/-- In classical two-valued logic, no Boolean value is simultaneously true
    with its negation. Explosion holds vacuously because the premise is
    always unsatisfiable. -/
theorem classical_no_contradiction :
    ∀ (v : Bool), ¬(v = true ∧ (!v) = true) := by
  intro v ⟨h1, h2⟩; cases v <;> simp_all

/-
**Fundamental theorem of paraconsistent logic**: In Belnap's four-valued
    system, a value and its negation can BOTH be designated, while other
    values remain undesignated.

    Witness: `both` is designated and `bneg both = both` is designated,
    while `falseOnly` is not designated. This is impossible in classical logic
    (see `classical_no_contradiction`).
-/
theorem belnap_explosion_fails :
    ∃ (vp vq : BelnapVal),
      vp.isDesignated ∧ (vp.bneg).isDesignated ∧ ¬vq.isDesignated := by
  exists BelnapVal.both, BelnapVal.falseOnly

/-- **Contradiction coexistence**: For any two disjoint families of propositions,
    there exists a four-valued valuation making the first family contradictory
    and the second family consistently true.

    This models dream logic: some beliefs are contradictory (the impossible
    staircase) while others remain consistent (the dreamer's identity). -/
theorem contradiction_coexistence {Prop' : Type*}
    (S_contra S_consist : Set Prop') (hDisj : Disjoint S_contra S_consist) :
    ∃ (v : Prop' → BelnapVal),
      (∀ p ∈ S_contra, v p = BelnapVal.both) ∧
      (∀ p ∈ S_consist, v p = BelnapVal.trueOnly) := by
  classical
  exact ⟨fun p => if p ∈ S_contra then BelnapVal.both else BelnapVal.trueOnly,
    fun p hp => if_pos hp,
    fun p hp => if_neg (Set.disjoint_right.mp hDisj hp)⟩

-- ============================================================================
-- SECTION 3: Pre-Topological Spaces
-- ============================================================================

/-- A **pre-topological space** has the finite closure properties of a topology
    (closed under ∅, univ, pairwise ∩, pairwise ∪) but is NOT required to be
    closed under arbitrary unions.

    This strictly generalizes topological spaces and models settings where
    finitely many observations can be combined but infinite observation
    families may not compose — precisely the situation in dream logic where
    each individual belief is coherent but their infinite conjunction may not be. -/
structure PreTopologicalSpace (α : Type*) where
  isPreOpen : Set α → Prop
  preOpen_empty : isPreOpen ∅
  preOpen_univ : isPreOpen Set.univ
  preOpen_inter : ∀ s t, isPreOpen s → isPreOpen t → isPreOpen (s ∩ t)
  preOpen_union : ∀ s t, isPreOpen s → isPreOpen t → isPreOpen (s ∪ t)

namespace PreTopologicalSpace

/-- The **finite-or-univ pre-topology** on ℕ: a set is pre-open iff it is
    finite or equals the entire space.

    This is the canonical example of a pre-topology that is NOT a topology:
    every singleton is pre-open, but their countable union (e.g., the even
    numbers) need not be pre-open. -/
noncomputable def finiteOrUniv : PreTopologicalSpace ℕ where
  isPreOpen S := S.Finite ∨ S = Set.univ
  preOpen_empty := Or.inl Set.finite_empty
  preOpen_univ := Or.inr rfl
  preOpen_inter := by
    intro s t hs ht
    cases hs with
    | inl hs =>
      exact Or.inl (Set.Finite.subset hs Set.inter_subset_left)
    | inr hs =>
      cases ht with
      | inl ht => exact Or.inl (Set.Finite.subset ht Set.inter_subset_right)
      | inr ht => exact Or.inr (by rw [hs, ht, Set.inter_self])
  preOpen_union := by
    intro s t hs ht
    cases hs with
    | inl hs =>
      cases ht with
      | inl ht => exact Or.inl (Set.Finite.union hs ht)
      | inr ht => exact Or.inr (by rw [ht, Set.union_univ])
    | inr hs =>
      exact Or.inr (by rw [hs, Set.univ_union])

/-- The set of even natural numbers -/
def evenNats : Set ℕ := {n | ∃ k, n = 2 * k}

/-
The even numbers form an infinite set
-/
theorem evenNats_infinite : ¬ evenNats.Finite := by
  exact Set.infinite_of_injective_forall_mem ( fun x y hxy => by simpa using hxy ) fun x => ⟨ x, rfl ⟩

/-
The even numbers are a proper subset of ℕ (1 is odd)
-/
theorem evenNats_ne_univ : evenNats ≠ Set.univ := by
  exact Set.nonempty_compl.1 ⟨ 1, fun ⟨ k, hk ⟩ => by linarith [ show k = 0 by linarith ] ⟩

/-- The even numbers are NOT pre-open in the finiteOrUniv pre-topology -/
theorem evenNats_not_preopen : ¬ finiteOrUniv.isPreOpen evenNats := by
  intro h
  rcases h with h | h
  · exact evenNats_infinite h
  · exact evenNats_ne_univ h

/-- Every singleton is pre-open in the finiteOrUniv pre-topology -/
theorem singleton_preopen (n : ℕ) : finiteOrUniv.isPreOpen {n} :=
  Or.inl (Set.finite_singleton n)

/-- **The finiteOrUniv pre-topology is NOT a topology**: there exists an
    indexed family of pre-open sets whose countable union is not pre-open.

    Witness: the family `{2k}` for k ∈ ℕ. Each is a finite set (pre-open),
    but ⋃ k, {2k} = evenNats, which is neither finite nor all of ℕ.

    This theorem establishes the strict separation between pre-topological
    and topological spaces, and demonstrates that "infinite combination of
    observations" is genuinely more powerful than finite combination. -/
theorem finiteOrUniv_not_topology :
    ∃ (f : ℕ → Set ℕ),
      (∀ i, finiteOrUniv.isPreOpen (f i)) ∧
      ¬ finiteOrUniv.isPreOpen (⋃ i, f i) := by
  refine ⟨fun k => {2 * k}, fun i => singleton_preopen (2 * i), ?_⟩
  have h : ⋃ i, ({2 * i} : Set ℕ) = evenNats := by
    ext n; simp only [Set.mem_iUnion, Set.mem_singleton_iff, evenNats, Set.mem_setOf_eq]
  rw [h]
  exact evenNats_not_preopen

end PreTopologicalSpace

-- ============================================================================
-- SECTION 4: Non-Monotone Default Reasoning
-- ============================================================================

/-- Propositions for the classic "birds fly" example of non-monotone reasoning -/
inductive BirdProp where
  | bird : BirdProp     -- "is a bird"
  | penguin : BirdProp  -- "is a penguin"
  | flies : BirdProp    -- "can fly"
  deriving DecidableEq

/-- A default theory consists of default rules ("normally, P implies Q")
    and exception rules ("P blocks the conclusion Q") -/
structure DefaultTheory (Prop' : Type*) where
  defaults : Prop' → Prop' → Prop
  exceptions : Prop' → Prop' → Prop

/-- Default consequence: φ follows from Γ if either φ is directly in Γ,
    or some premise in Γ triggers a default for φ that is not blocked by
    any exception in Γ -/
def DefaultTheory.defaultEntails {Prop' : Type*}
    (T : DefaultTheory Prop') (Γ : Set Prop') (φ : Prop') : Prop :=
  φ ∈ Γ ∨ (∃ p ∈ Γ, T.defaults p φ ∧ ¬∃ q ∈ Γ, T.exceptions q φ)

/-- The standard bird theory:
    - Default: being a bird implies flying
    - Exception: being a penguin blocks the conclusion of flying -/
def birdTheory : DefaultTheory BirdProp where
  defaults p q := p = BirdProp.bird ∧ q = BirdProp.flies
  exceptions p q := p = BirdProp.penguin ∧ q = BirdProp.flies

/-
**Non-monotonicity of default reasoning**: In the bird theory,
    `{bird} ⊢_d flies` (birds normally fly), but `{bird, penguin} ⊬_d flies`
    (penguins don't fly).

    This is the formal demonstration that default reasoning violates
    monotonicity: adding the premise "penguin" RETRACTS the conclusion
    "flies", even though all original premises are preserved.

    This models dream logic's retractability: a dreamer may believe they
    can fly (default), but realizing they're a penguin (new information)
    defeats this belief — yet the system remains consistent.
-/
theorem default_non_monotone :
    let Γ : Set BirdProp := {BirdProp.bird}
    let Δ : Set BirdProp := {BirdProp.bird, BirdProp.penguin}
    Γ ⊆ Δ ∧
    birdTheory.defaultEntails Γ BirdProp.flies ∧
    ¬birdTheory.defaultEntails Δ BirdProp.flies := by
  unfold birdTheory; simp +decide [ DefaultTheory.defaultEntails ] ;

-- ============================================================================
-- SECTION 5: Dream Frames and the Logic-Topology Bridge
-- ============================================================================

/-- A **dream frame** consists of a set of possible worlds and a four-valued
    valuation assigning Belnap truth values to each proposition at each world.

    Unlike classical Kripke frames, dream frames allow contradictions:
    a proposition can be both true and false at the same world, modeling
    the impossible objects that coexist in dreams. -/
structure DreamFrame (Prop' : Type*) where
  World : Type*
  val : World → Prop' → BelnapVal

namespace DreamFrame

variable {Prop' : Type*}

/-- The **designated set** of a proposition: the collection of worlds where
    it is accepted as (at least) true -/
def designatedSet (D : DreamFrame Prop') (p : Prop') : Set D.World :=
  {w | (D.val w p).isDesignated}

/-- **Semantic consequence** in a dream frame: Γ entails φ when every world
    satisfying all premises in Γ also satisfies φ -/
def entails (D : DreamFrame Prop') (Γ : Set Prop') (φ : Prop') : Prop :=
  ∀ w : D.World, (∀ p ∈ Γ, (D.val w p).isDesignated) → (D.val w φ).isDesignated

/-
**Dream explosion failure**: There exists a concrete dream frame with two
    propositions where proposition 0 is everywhere contradictory (both it and
    its negation hold at every world) yet proposition 1 is nowhere true.

    This demonstrates that contradiction at the frame level — not just the
    algebraic level — does not cause logical explosion.
-/
theorem dream_explosion_failure :
    ∃ (D : DreamFrame (Fin 2)),
      (∀ w : D.World, (D.val w 0).isDesignated) ∧
      (∀ w : D.World, ((D.val w 0).bneg).isDesignated) ∧
      ¬D.entails {0} 1 := by
  fconstructor;
  exact ⟨ PUnit, fun _ ↦ fun i ↦ if i = 0 then BelnapVal.both else BelnapVal.falseOnly ⟩;
  simp +decide [ DreamFrame.entails ]

/-
**Logic-Topology Bridge (Conjunction)**: The designated set of the
    Belnap conjunction of two propositions equals the intersection of
    their designated sets.

    This is the fundamental correspondence between logical operations
    and set-theoretic operations that links dream logic to topology:
    conjunction ↔ intersection, disjunction ↔ union.
-/
theorem designatedSet_bconj_eq_inter (D : DreamFrame Prop') (p q : Prop') :
    {w : D.World | (BelnapVal.bconj (D.val w p) (D.val w q)).isDesignated} =
    D.designatedSet p ∩ D.designatedSet q := by
  ext w; simp [BelnapVal.bconj, BelnapVal.isDesignated];
  rfl

/-
**Logic-Topology Bridge (Disjunction)**: The designated set of the
    Belnap disjunction equals the union of designated sets.
-/
theorem designatedSet_bdisj_eq_union (D : DreamFrame Prop') (p q : Prop') :
    {w : D.World | (BelnapVal.bdisj (D.val w p) (D.val w q)).isDesignated} =
    D.designatedSet p ∪ D.designatedSet q := by
  convert Set.ext _;
  simp +decide [ DreamFrame.designatedSet, BelnapVal.isDesignated, BelnapVal.bdisj ]

end DreamFrame

/-- The **pointwise dream model** on ℕ: proposition p is true only at world p.
    Each proposition is "locally real" — true in exactly one world.
    This creates a maximally dispersed dream where every proposition has
    its own private reality. -/
def pointwiseDream : DreamFrame ℕ where
  World := ℕ
  val w p := if w = p then BelnapVal.trueOnly else BelnapVal.neither

/-
In the pointwise model, each designated set is exactly a singleton
-/
theorem pointwise_designatedSet (p : ℕ) :
    pointwiseDream.designatedSet p = {p} := by
  ext w;
  unfold pointwiseDream;
  simp +decide [ DreamFrame.designatedSet, BelnapVal.isDesignated ];
  split_ifs <;> simp +decide [ * ]

-- ============================================================================
-- SECTION 6: Conjecture — Paraconsistent Compactness
-- ============================================================================

/-- **Conjecture (Paraconsistent Compactness)**: For any dream frame with
    countably many propositions, if every finite subset of a set of premises
    is satisfiable at some world, then the entire set is satisfiable at some world.

    This is the Belnap-logic analogue of the classical compactness theorem.
    Since Belnap logic is four-valued (finite-valued), compactness should follow
    from Tychonoff's theorem applied to the product space BelnapVal^Prop'.

    **Testable prediction**: Construct a specific countable family of Belnap
    constraints and verify computationally that finite satisfiability implies
    global satisfiability. For n propositions, check all 4^n valuations.
    For n = 10, this is 4^10 ≈ 10^6 valuations — easily enumerable. -/
theorem paraconsistent_compactness_conjecture
    (D : DreamFrame ℕ)
    (Γ : Set ℕ)
    (hFinSat : ∀ S : Finset ℕ, ↑S ⊆ Γ → ∃ w, ∀ p ∈ S, (D.val w p).isDesignated) :
    ∃ w, ∀ p ∈ Γ, (D.val w p).isDesignated := by
  sorry -- Conjecture: believed true via Tychonoff, not yet formally proved

end DreamLogic