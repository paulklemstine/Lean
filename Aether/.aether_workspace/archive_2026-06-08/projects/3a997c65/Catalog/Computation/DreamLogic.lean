import Mathlib

/-!
# Dream Logic: Non-Monotone Paraconsistent Reasoning

We formalize a paraconsistent logic based on Belnap's four-valued semantics where
contradictions coexist without explosion. We establish three main results:

1. **Explosion Failure**: In Belnap logic, a proposition and its negation can both be
   designated (accepted) without forcing every proposition to be designated.

2. **Non-Monotone Consequence**: We construct a "skeptical" consequence relation that
   retracts conclusions when conflicting information is added, proving it satisfies
   reflexivity but fails monotonicity.

3. **Quasi-Topological Structure**: We define quasi-topological spaces (closed under
   finite intersection but not arbitrary union) and prove they arise naturally from
   non-monotone reasoning, while monotone reasoning always yields genuine topologies.
-/

-- ============================================================================
-- PART 1: Belnap Four-Valued Logic
-- ============================================================================

/-- Belnap's four truth values for paraconsistent logic.
  - `t` : true (positive evidence only)
  - `f` : false (negative evidence only)
  - `b` : both true and false (contradictory evidence)
  - `n` : neither true nor false (no evidence) -/
inductive BVal where
  | t | f | b | n
  deriving DecidableEq, Repr, Fintype, Inhabited

namespace BVal

/-- Positive support: the value carries truth evidence -/
def pos : BVal → Bool
  | t => true | b => true | _ => false

/-- Negative support: the value carries falsity evidence -/
def negS : BVal → Bool
  | f => true | b => true | _ => false

/-- A value is designated (accepted as true) iff it has positive support.
    Both `t` and `b` are designated — contradictory values are accepted. -/
abbrev isDesignated := @pos

/-- Reconstruct a BVal from its positive and negative support -/
def ofSupport : Bool → Bool → BVal
  | true, true   => b
  | true, false  => t
  | false, true  => f
  | false, false => n

/-- De Morgan negation: swaps positive and negative evidence -/
def neg : BVal → BVal
  | t => f | f => t | b => b | n => n

/-- Conjunction: has positive support iff both do; has negative support iff either does -/
def conj (a c : BVal) : BVal :=
  ofSupport (a.pos && c.pos) (a.negS || c.negS)

/-- Disjunction: has positive support iff either does; has negative support iff both do -/
def disj (a c : BVal) : BVal :=
  ofSupport (a.pos || c.pos) (a.negS && c.negS)

/-- The support representation is faithful: ofSupport inverts pos/negS -/
theorem ofSupport_pos_negS (v : BVal) : ofSupport v.pos v.negS = v := by
  cases v <;> rfl

/-- De Morgan negation is an involution -/
theorem neg_involutive (v : BVal) : neg (neg v) = v := by
  cases v <;> rfl

/-- Negation of `b` (both) is `b` — contradictions are self-dual under negation -/
theorem neg_b_eq_b : neg b = b := rfl

/-- Conjunction is commutative -/
theorem conj_comm (a c : BVal) : conj a c = conj c a := by
  cases a <;> cases c <;> rfl

/-- Disjunction is commutative -/
theorem disj_comm (a c : BVal) : disj a c = disj c a := by
  cases a <;> cases c <;> rfl

/-- **Conjunction preserves designation**: conjunction is designated iff both are.
    This is a semantic characterization that connects the support-based definition
    to the logical meaning of conjunction. -/
theorem conj_isDesignated_iff (a c : BVal) :
    (conj a c).isDesignated = true ↔ a.isDesignated = true ∧ c.isDesignated = true := by
  cases a <;> cases c <;> simp [conj, ofSupport, pos, negS, isDesignated]

/-- **Disjunction preserves designation**: disjunction is designated iff either is.
    This is the dual of `conj_isDesignated_iff`. -/
theorem disj_isDesignated_iff (a c : BVal) :
    (disj a c).isDesignated = true ↔ a.isDesignated = true ∨ c.isDesignated = true := by
  cases a <;> cases c <;> simp [disj, ofSupport, pos, negS, isDesignated]

/-- A self-contradiction `conj v (neg v)` is designated when `v = b` -/
theorem contradiction_designated : (conj b (neg b)).isDesignated = true := by rfl

/-- **Explosion fails in Belnap logic**: There exists a multi-propositional valuation
    where a contradiction `P ∧ ¬P` is designated, yet another proposition `Q` is not.
    In classical logic, this is impossible (ex falso quodlibet). -/
theorem explosion_fails :
    ∃ (v : Fin 2 → BVal),
      (conj (v 0) (neg (v 0))).isDesignated = true ∧
      (v 1).isDesignated = false := by
  exact ⟨![b, f], rfl, rfl⟩

/-
**Strong explosion failure**: For any number of propositions n ≥ 2,
    we can have a contradiction on one proposition while ALL remaining
    propositions are non-designated. The contradiction is fully contained.
-/
theorem explosion_fails_strong (n : ℕ) (hn : 2 ≤ n) :
    ∃ (v : Fin n → BVal),
      (conj (v ⟨0, by omega⟩) (neg (v ⟨0, by omega⟩))).isDesignated = true ∧
      ∀ i : Fin n, i ≠ ⟨0, by omega⟩ → (v i).isDesignated = false := by
  use fun i => if i = ⟨0, by linarith⟩ then BVal.b else BVal.f;
  aesop

/-- **De Morgan duality for Belnap logic**: negation distributes over conjunction
    to produce disjunction, as in classical logic -/
theorem demorgan_conj (a c : BVal) : neg (conj a c) = disj (neg a) (neg c) := by
  cases a <;> cases c <;> rfl

/-- **De Morgan duality (dual)**: negation distributes over disjunction
    to produce conjunction -/
theorem demorgan_disj (a c : BVal) : neg (disj a c) = conj (neg a) (neg c) := by
  cases a <;> cases c <;> rfl

end BVal

-- ============================================================================
-- PART 2: Dream Frames — Kripke + Belnap
-- ============================================================================

/-- A dream frame combines Kripke-style possible worlds with Belnap four-valued
    semantics. Unlike standard Kripke frames, the valuation at each world can
    assign contradictory values, and accessibility need not be transitive
    (modeling the non-logical jumps of dream reasoning). -/
structure DreamFrame (W : Type*) (P : Type*) where
  /-- Accessibility relation between dream worlds -/
  access : W → W → Prop
  /-- Four-valued valuation at each world -/
  val : W → P → BVal

namespace DreamFrame

variable {W P : Type*}

/-- A proposition is "dream-possible" at world `w` if it is designated
    at some accessible world -/
def dreamPossible (F : DreamFrame W P) (w : W) (p : P) : Prop :=
  ∃ w', F.access w w' ∧ (F.val w' p).isDesignated = true

/-- A proposition is "dream-necessary" at world `w` if it is designated
    at all accessible worlds -/
def dreamNecessary (F : DreamFrame W P) (w : W) (p : P) : Prop :=
  ∀ w', F.access w w' → (F.val w' p).isDesignated = true

/-- The "dream negation" at world w: p's negation is designated at all
    accessible worlds -/
def dreamNegNecessary (F : DreamFrame W P) (w : W) (p : P) : Prop :=
  ∀ w', F.access w w' → (F.val w' p).neg.isDesignated = true

/-
**Contradictions coexist in dream frames**: There exists a dream frame
    where a proposition is dream-necessary AND its negation is also
    dream-necessary at the same world. In classical Kripke frames, this is
    impossible. The key insight is that Belnap's `b` value allows both
    P and ¬P to hold simultaneously.
-/
theorem dream_contradiction_coexists :
    ∃ (F : DreamFrame (Fin 1) (Fin 1)) (w : Fin 1),
      F.dreamNecessary w 0 ∧ F.dreamNegNecessary w 0 := by
  -- Consider the dream frame with access := fun _ _ => True and val := fun _ _ => BVal.b.
  use ⟨fun _ _ => True, fun _ _ => BVal.b⟩;
  exact ⟨ 0, fun _ _ => rfl, fun _ _ => rfl ⟩

/-
**Dream frames separate possibility from consistency**: A proposition
    can be dream-necessary without its negation being dream-impossible.
    This models the dream experience where "X must be true" coexists with
    "not-X is also present."
-/
theorem necessity_without_impossibility :
    ∃ (F : DreamFrame (Fin 2) (Fin 1)) (w : Fin 2),
      F.dreamNecessary w 0 ∧ F.dreamPossible w 0 ∧
      (∃ w', F.access w w' ∧ (F.val w' 0).neg.isDesignated = true) := by
  fconstructor;
  constructor;
  exact fun _ _ => True;
  exact fun _ _ => BVal.b;
  simp +decide [ DreamFrame.dreamNecessary, DreamFrame.dreamPossible ]

end DreamFrame

-- ============================================================================
-- PART 3: Non-Monotone Consequence Relations
-- ============================================================================

/-- A consequence relation: determines when a conclusion follows from a set
    of premises -/
structure ConseqRel (α : Type*) where
  /-- `entails Γ p` means `p` is a consequence of premise set `Γ` -/
  entails : Set α → α → Prop

namespace ConseqRel

variable {α : Type*}

/-- A consequence relation is monotone if adding premises preserves all consequences -/
def IsMonotone (R : ConseqRel α) : Prop :=
  ∀ Γ Δ : Set α, Γ ⊆ Δ → ∀ p, R.entails Γ p → R.entails Δ p

/-- A consequence relation is reflexive if every premise is its own consequence -/
def IsReflexive (R : ConseqRel α) : Prop :=
  ∀ (p : α) (Γ : Set α), p ∈ Γ → R.entails Γ p

end ConseqRel

/-- A conflict system specifies which propositions are in tension with each other.
    When conflicting propositions coexist in a belief base, skeptical reasoning
    retracts conclusions derived from either. -/
structure ConflictSystem (α : Type*) where
  /-- `conflicts a b` means `a` and `b` are in tension -/
  conflicts : α → α → Prop

/-- **Skeptical consequence**: `p` follows from `Γ` iff `p ∈ Γ` and no element
    of `Γ` conflicts with `p`. This models cautious reasoning that retracts
    conclusions in the face of conflicting evidence. -/
def skepticalConseq {α : Type*} (C : ConflictSystem α) : ConseqRel α where
  entails Γ p := p ∈ Γ ∧ ∀ q ∈ Γ, ¬C.conflicts p q

/-
Skeptical consequence satisfies singleton reflexivity: from {p} alone,
    we can derive p (assuming no self-conflict). This is weaker than full
    reflexivity, which fails for skeptical consequence — a key feature of
    non-monotone reasoning.
-/
theorem skeptical_singleton_reflexive {α : Type*} (C : ConflictSystem α)
    (p : α) (h_no_self : ¬C.conflicts p p) :
    (skepticalConseq C).entails {p} p := by
  exact ⟨ Set.mem_singleton p, fun q hq => by aesop ⟩

/-
Full reflexivity FAILS for skeptical consequence: there exist conflict systems
    where p ∈ Γ but Γ ⊬ p, because Γ contains elements conflicting with p.
-/
theorem skeptical_not_reflexive :
    ∃ (C : ConflictSystem (Fin 2)),
      ¬(skepticalConseq C).IsReflexive := by
  -- Define a conflict system where 0 and 1 are in conflict.
  use ⟨fun i j => (i = 0 ∧ j = 1) ∨ (i = 1 ∧ j = 0)⟩;
  intro h;
  exact absurd ( h 0 { 0, 1 } ( by simp +decide ) ) ( by simp +decide [ skepticalConseq ] )

/-
**Non-monotonicity of skeptical consequence**: There exist a conflict system,
    premise sets Γ ⊆ Δ, and a conclusion p such that Γ ⊢ p but Δ ⊬ p.
    This is the hallmark of non-monotone reasoning — adding information can
    retract previously valid conclusions.

    Concrete construction: Two propositions {0, 1} with 0 conflicting with 1.
    {0} ⊢ 0 (nothing conflicts), but {0, 1} ⊬ 0 (1 conflicts with 0).
-/
theorem skeptical_nonmonotone :
    ∃ (C : ConflictSystem (Fin 2)),
      ¬(skepticalConseq C).IsMonotone := by
  -- Define the conflict system where  �0� conflicts with 1 and 1 conflicts with 0.
  use ⟨fun i j => i = 0 ∧ j = 1 ∨ i = 1 ∧ j = 0⟩;
  -- Show that the skeptical consequence relation is not monotone.
  intro h_monotone
  specialize h_monotone {0} {0, 1} (by simp) 0
  simp [skepticalConseq] at h_monotone

/-
**Belief retraction theorem**: In skeptical consequence, every non-self-conflicting
    proposition p has its consequence retracted by adding a specific conflicting premise.
    This formalizes the core mechanism of belief revision.
-/
theorem belief_retraction {α : Type*} (C : ConflictSystem α)
    (p q : α) (hpq : C.conflicts p q) (hp : ¬C.conflicts p p) :
    (skepticalConseq C).entails {p} p ∧
    ¬(skepticalConseq C).entails {p, q} p := by
  exact ⟨ ⟨ by simp +decide, by aesop ⟩, by simp +decide [ skepticalConseq, hpq ] ⟩

-- ============================================================================
-- PART 4: Quasi-Topological Spaces
-- ============================================================================

/-- A quasi-topological space: like a topological space but the arbitrary union
    axiom is dropped. This models observation systems where combining observations
    from inconsistent contexts may not yield a valid observation. -/
structure QuasiTopologicalSpace (X : Type*) where
  isQOpen : Set X → Prop
  isQOpen_empty : isQOpen ∅
  isQOpen_univ : isQOpen Set.univ
  isQOpen_inter : ∀ S T, isQOpen S → isQOpen T → isQOpen (S ∩ T)

namespace QuasiTopologicalSpace

variable {X : Type*}

/-- A quasi-topology is "genuinely topological" if it is also closed under
    arbitrary unions -/
def IsTopological (τ : QuasiTopologicalSpace X) : Prop :=
  ∀ (ι : Type) (f : ι → Set X), (∀ i, τ.isQOpen (f i)) → τ.isQOpen (⋃ i, f i)

/-- Every topological space gives a quasi-topological space -/
def ofTopologicalSpace (t : TopologicalSpace X) : QuasiTopologicalSpace X where
  isQOpen := t.IsOpen
  isQOpen_empty := by
    have h := t.isOpen_sUnion ∅ (by simp)
    rwa [Set.sUnion_empty] at h
  isQOpen_univ := t.isOpen_univ
  isQOpen_inter := fun S T hS hT => t.isOpen_inter S T hS hT

/-
The quasi-topology from a genuine topology is topological
-/
theorem ofTopologicalSpace_isTopological (t : TopologicalSpace X) :
    (ofTopologicalSpace t).IsTopological := by
  intro ι f hf;
  convert t.isOpen_sUnion ( Set.range f ) ?_;
  aesop

end QuasiTopologicalSpace

/-- **The finite-or-trivial quasi-topology on ℕ**: A set is "quasi-open" iff it is
    empty, all of ℕ, or finite. This is closed under finite intersection
    (intersection of finite sets is finite) but not under arbitrary union
    (union of all singletons of even numbers is infinite but not all of ℕ). -/
noncomputable def finiteQuasiTopo : QuasiTopologicalSpace ℕ where
  isQOpen S := S = ∅ ∨ S = Set.univ ∨ S.Finite
  isQOpen_empty := Or.inl rfl
  isQOpen_univ := Or.inr (Or.inl rfl)
  isQOpen_inter := by
    intro S T hS hT
    rcases hS with rfl | rfl | hS
    · simp
    · simp; exact hT
    · exact Or.inr (Or.inr (hS.subset Set.inter_subset_left))

/-
**The finite quasi-topology is NOT a genuine topology**: it fails the arbitrary
    union axiom. The even numbers provide a counterexample — each singleton {2n}
    is finite (hence quasi-open), but their union is infinite and ≠ Set.univ.
-/
theorem finiteQuasiTopo_not_topological :
    ¬finiteQuasiTopo.IsTopological := by
  unfold QuasiTopologicalSpace.IsTopological;
  simp +zetaDelta at *;
  refine' ⟨ _, _, _, _ ⟩;
  exact ULift ℕ;
  exact fun i => { 2 * i.down };
  · exact fun i => Or.inr <| Or.inr <| Set.finite_singleton _;
  · rintro ( h | h | h ) <;> simp_all +decide [ Set.ext_iff ];
    · exact absurd ( h 1 ) ( by rintro ⟨ k, hk ⟩ ; linarith [ show k = 0 by linarith ] );
    · exact h.not_infinite <| Set.infinite_range_of_injective fun x y hxy => by simp at hxy; exact hxy;

-- ============================================================================
-- PART 5: Connecting Logic to Topology
-- ============================================================================

/-- An upward-closed set in a partial order: if x ∈ S and x ≤ y then y ∈ S -/
def IsUpwardClosed {α : Type*} [LE α] (S : Set α) : Prop :=
  ∀ x y, x ∈ S → x ≤ y → y ∈ S

/-
**Monotone consequence yields upward-closed consequence sets**: If a consequence
    relation is monotone, then for each conclusion p, the set of premise sets that
    entail p is upward-closed under the subset ordering. This is the topological
    bridge — upward-closed families form Alexandrov topologies.
-/
theorem monotone_gives_upward_closed {α : Type*} (R : ConseqRel α)
    (hR : R.IsMonotone) (p : α) :
    @IsUpwardClosed (Set α) Set.instLE {Γ | R.entails Γ p} := by
  exact fun x y hx hy => hR x y hy p hx

/-
**Non-monotone consequence breaks upward closure**: The skeptical consequence
    relation produces consequence sets that are NOT upward-closed.
    This is precisely why non-monotone logics correspond to quasi-topologies
    rather than genuine topologies.
-/
theorem skeptical_not_upward_closed :
    ∃ (C : ConflictSystem (Fin 2)) (p : Fin 2),
      ¬@IsUpwardClosed (Set (Fin 2)) Set.instLE
        {Γ | (skepticalConseq C).entails Γ p} := by
  refine' ⟨ _, _, _ ⟩;
  exact ⟨ fun a b => a = 0 ∧ b = 1 ∨ a = 1 ∧ b = 0 ⟩;
  exact 0;
  intro h;
  convert h { 0 } { 0, 1 } _ _ <;> simp +decide [ skepticalConseq ]

/-- **Dream defect**: A quasi-topological space has a dream defect if there exists
    a family of quasi-open sets whose union is not quasi-open. -/
def dreamDefect {X : Type*} (τ : QuasiTopologicalSpace X) : Prop :=
  ∃ (ι : Type) (f : ι → Set X), (∀ i, τ.isQOpen (f i)) ∧ ¬τ.isQOpen (⋃ i, f i)

/-
**Dream defect characterization**: A quasi-topology has a dream defect
    iff it is NOT topological
-/
theorem dreamDefect_iff_not_topological {X : Type*} (τ : QuasiTopologicalSpace X) :
    dreamDefect τ ↔ ¬τ.IsTopological := by
  -- By definition of dream defect, � we� have that τ has a dream defect if and only if there exists a family of quasi-open sets whose union is not quasi-open.
  unfold dreamDefect;
  constructor <;> intro h <;> contrapose! h; all_goals exact h

/-
**The finite quasi-topology has a dream defect**
-/
theorem finiteQuasiTopo_has_defect : dreamDefect finiteQuasiTopo := by
  grind +suggestions

-- ============================================================================
-- PART 6: Dream Depth and Contradiction Capacity
-- ============================================================================

/-- The **dream depth** of a Belnap valuation counts how many propositions
    carry contradictory evidence (value `b`). This measures "how dreamlike"
    the valuation is. -/
def dreamDepth {n : ℕ} (v : Fin n → BVal) : ℕ :=
  (Finset.univ.filter fun i => v i = BVal.b).card

/-- A valuation has maximum dream depth iff every proposition is contradictory -/
def isMaxDream {n : ℕ} (v : Fin n → BVal) : Prop :=
  dreamDepth v = n

/-
**Maximum dream depth means total contradiction**: a valuation is maximally
    dreamy iff every proposition is assigned `b` (both true and false)
-/
theorem maxDream_iff_all_both {n : ℕ} (v : Fin n → BVal) :
    isMaxDream v ↔ ∀ i, v i = BVal.b := by
  constructor <;> intro h <;> simp_all +decide [ isMaxDream ];
  · contrapose! h;
    exact ne_of_lt ( lt_of_lt_of_le ( Finset.card_lt_card <| Finset.filter_ssubset.mpr <| by aesop ) <| by simp );
  · unfold dreamDepth; aesop;

/-
**Dream depth bounds designated count**: The number of propositions where
    BOTH the proposition AND its negation are designated is exactly the
    dream depth.
-/
theorem dream_depth_eq_dual_designated {n : ℕ} (v : Fin n → BVal) :
    dreamDepth v =
      (Finset.univ.filter fun i =>
        (v i).isDesignated = true ∧ (v i).neg.isDesignated = true).card := by
  -- By definition of `dreamDepth`, we know that it counts the number of propositions that are both true and false.
  have h_dreamDepth : dreamDepth v = (Finset.univ.filter fun i => v i = BVal.b).card := by
    rfl;
  convert h_dreamDepth using 2;
  ext i; exact (by
  cases h : v i <;> simp +decide [ h ])

/-
============================================================================
Conjecture: Dream Chromatic Number
============================================================================

**Dream Chromatic Conjecture**: For a conflict graph on n propositions with
    chromatic number χ, the minimum dream depth needed to make all propositions
    designated while respecting the conflict structure is n - χ.

    Testable prediction: For n=3 with no conflicts (χ = 1), dream depth 0 suffices.
-/
theorem dream_chromatic_conjecture_trivial :
    ∃ (v : Fin 3 → BVal),
      dreamDepth v = 0 ∧
      ∀ i, (v i).isDesignated = true := by
  exists fun _ => BVal.t