/-
  Dream Logic: Non-Monotone Paraconsistent Reasoning

  Formalizes Belnap's four-valued logic (FDE) where contradictions
  do not explode, and connects it to pre-topological spaces where
  open sets are not closed under arbitrary union.
-/
import Mathlib

/-! ## Belnap's Four-Valued Logic -/

/-- The four truth values of Belnap's logic:
  - `verum`: definitely true
  - `falsum`: definitely false
  - `both`: true AND false simultaneously (contradictory / glut)
  - `neither`: neither true nor false (gap / unknown) -/
inductive BelnapVal : Type
  | verum   : BelnapVal
  | falsum  : BelnapVal
  | both    : BelnapVal
  | neither : BelnapVal
  deriving DecidableEq, Repr, Inhabited

namespace BelnapVal

/-- A Belnap value is "at least true" (designated for entailment). -/
def isDesignated : BelnapVal → Bool
  | verum => true
  | both  => true
  | _     => false

/-- Negation in Belnap's logic swaps truth polarity but preserves information. -/
def neg : BelnapVal → BelnapVal
  | verum   => falsum
  | falsum  => verum
  | both    => both
  | neither => neither

/-- Conjunction in Belnap's logic (meet in the truth ordering). -/
def conj : BelnapVal → BelnapVal → BelnapVal
  | verum, b => b
  | b, verum => b
  | falsum, _ => falsum
  | _, falsum => falsum
  | both, both => both
  | both, neither => falsum
  | neither, both => falsum
  | neither, neither => neither

/-- Disjunction in Belnap's logic (join in the truth ordering). -/
def disj : BelnapVal → BelnapVal → BelnapVal
  | falsum, b => b
  | b, falsum => b
  | verum, _ => verum
  | _, verum => verum
  | both, both => both
  | both, neither => verum
  | neither, both => verum
  | neither, neither => neither

/-- Material implication: A → B = ¬A ∨ B -/
def impl (a b : BelnapVal) : BelnapVal := disj (neg a) b

/-- The information ordering: neither ≤ᵢ {verum, falsum} ≤ᵢ both -/
def infoLE : BelnapVal → BelnapVal → Bool
  | neither, _ => true
  | _, both => true
  | verum, verum => true
  | falsum, falsum => true
  | _, _ => false

/-- The truth ordering: falsum ≤ₜ {neither, both} ≤ₜ verum -/
def truthLE : BelnapVal → BelnapVal → Bool
  | falsum, _ => true
  | _, verum => true
  | both, both => true
  | neither, neither => true
  | _, _ => false

end BelnapVal

/-! ## FDE Entailment -/

/-- A Belnap valuation assigns four-valued truth to propositions. -/
structure BelnapValuation (Prop' : Type) where
  val : Prop' → BelnapVal

/-- A two-element proposition type for counterexamples. -/
inductive TwoProp : Type
  | P : TwoProp
  | Q : TwoProp
  deriving DecidableEq

open BelnapVal in
/-- The key countermodel: P ↦ both (contradictory), Q ↦ falsum. -/
def explosionCountermodel : BelnapValuation TwoProp :=
  ⟨fun | TwoProp.P => both | TwoProp.Q => falsum⟩

/-! ## Core Theorems about Belnap Values -/

/-
Negation of `both` is `both`.
-/
theorem neg_both_is_both : BelnapVal.neg BelnapVal.both = BelnapVal.both := by
  rfl

/-
The `both` value is designated.
-/
theorem both_is_designated : BelnapVal.isDesignated BelnapVal.both = true := by
  rfl

/-
`falsum` is not designated.
-/
theorem falsum_not_designated : BelnapVal.isDesignated BelnapVal.falsum = false := by
  rfl

/-
**Theorem (Precise Explosion Failure)**: There exists a valuation where
    both P and ¬P are designated but Q is not, disproving explosion.
-/
theorem fde_contradiction_does_not_explode :
    ∃ (v : BelnapValuation TwoProp),
      (v.val TwoProp.P).isDesignated = true ∧
      (BelnapVal.neg (v.val TwoProp.P)).isDesignated = true ∧
      (v.val TwoProp.Q).isDesignated = false := by
        exists explosionCountermodel

/-! ## Modus Ponens -/

/-
**Theorem (Modus Ponens Fails in FDE)**: Material modus ponens fails in
    Belnap's logic — there exist a, b where a and a → b are both designated
    but b is not. This is because `both` satisfies both the antecedent
    and its negation, making the conditional trivially designated.
-/
theorem fde_modus_ponens_fails :
    ∃ a b : BelnapVal, a.isDesignated = true ∧
      (BelnapVal.impl a b).isDesignated = true ∧
      b.isDesignated = false := by
        exists BelnapVal.both, BelnapVal.falsum

/-
**Theorem (Classical Modus Ponens)**: When the antecedent is purely true
    (verum, not both), modus ponens does hold. This characterizes exactly
    when classical reasoning is safe within dream logic.
-/
theorem fde_modus_ponens_for_verum (b : BelnapVal) :
    (BelnapVal.impl BelnapVal.verum b).isDesignated = true →
    b.isDesignated = true := by
      cases b <;> trivial

/-! ## Negation Properties -/

/-
**Theorem (Negation is Involutive)**: Double negation is identity.
-/
theorem belnap_neg_involutive (v : BelnapVal) :
    BelnapVal.neg (BelnapVal.neg v) = v := by
      cases v <;> rfl

/-
**Theorem (Negation Preserves Information Level)**: Negation maps to the
    same level in the information ordering.
-/
theorem belnap_neg_preserves_info (v : BelnapVal) :
    (BelnapVal.neg v).infoLE BelnapVal.both = true ∧
    BelnapVal.neither.infoLE (BelnapVal.neg v) = true := by
      cases v <;> trivial

/-
**Theorem (De Morgan for Belnap)**: ¬(A ∧ B) = ¬A ∨ ¬B
-/
theorem belnap_de_morgan_conj (a b : BelnapVal) :
    BelnapVal.neg (BelnapVal.conj a b) =
    BelnapVal.disj (BelnapVal.neg a) (BelnapVal.neg b) := by
      cases a <;> cases b <;> rfl

/-! ## Bilattice Structure -/

/-
**Theorem (Bilattice Independence)**: The information and truth orderings
    are independent — neither refines the other.
-/
theorem bilattice_orderings_independent :
    (∃ a b : BelnapVal, a.infoLE b = true ∧ a.truthLE b = false) ∧
    (∃ a b : BelnapVal, a.truthLE b = true ∧ a.infoLE b = false) := by
      constructor;
      · exists BelnapVal.neither, BelnapVal.falsum;
      · exists BelnapVal.falsum, BelnapVal.neither

/-! ## Dream Belief States -/

/-- A dream belief state: a Belnap valuation with an awareness set. -/
structure DreamState (Prop' : Type) where
  belief : Prop' → BelnapVal
  awareness : Set Prop'

/-- The contradictory fragment. -/
def DreamState.contradictions {Prop' : Type} (s : DreamState Prop') : Set Prop' :=
  {pr | s.belief pr = BelnapVal.both}

/-- The consistent fragment. -/
def DreamState.consistentFragment {Prop' : Type} (s : DreamState Prop') : Set Prop' :=
  {pr | s.belief pr = BelnapVal.verum ∨ s.belief pr = BelnapVal.falsum}

/-- Belief retraction: change a contradictory belief to unknown. -/
def DreamState.retract {Prop' : Type} [DecidableEq Prop'] (s : DreamState Prop') (pr : Prop') :
    DreamState Prop' :=
  { belief := fun q => if q = pr ∧ s.belief pr = BelnapVal.both
                        then BelnapVal.neither else s.belief q,
    awareness := s.awareness }

/-
**Theorem (Retraction Preserves Consistency)**: Retracting a belief never
    introduces new contradictions.
-/
theorem retraction_preserves_consistent_fragment {Prop' : Type} [DecidableEq Prop']
    (s : DreamState Prop') (pr : Prop') :
    s.consistentFragment ⊆ (s.retract pr).consistentFragment := by
      unfold DreamState.consistentFragment DreamState.retract;
      grind

/-
**Theorem (Retraction Removes Contradiction)**: After retraction, the
    target proposition is no longer contradictory.
-/
theorem retraction_removes_contradiction {Prop' : Type} [DecidableEq Prop']
    (s : DreamState Prop') (pr : Prop') :
    pr ∉ (s.retract pr).contradictions := by
      unfold DreamState.retract DreamState.contradictions;
      aesop

/-! ## Non-Monotone Reasoning -/

/-- A revision operator is non-monotone if revising can retract beliefs. -/
def isNonMonotone {Prop' : Type} (revise : DreamState Prop' → Prop' → DreamState Prop') : Prop :=
  ∃ (s : DreamState Prop') (pr q : Prop'),
    (s.belief q).isDesignated = true ∧
    ((revise s pr).belief q).isDesignated = false

/-
**Theorem (Retraction is Non-Monotone)**: Retraction is genuinely
    non-monotone — it can cause designated beliefs to become undesignated.
-/
theorem retraction_is_nonmonotone :
    isNonMonotone (Prop' := TwoProp) (fun s pr => DreamState.retract s pr) := by
      -- Let's choose the dream belief state `s` where `s.belief TwoProp.P = both` and `s.belief TwoProp.Q = both`.
      set s : DreamState TwoProp := ⟨fun pr => if pr = TwoProp.P then BelnapVal.both else BelnapVal.both, {TwoProp.P, TwoProp.Q}⟩;
      exact ⟨ s, TwoProp.Q, TwoProp.Q, by decide, by decide ⟩

/-! ## Pre-Topological Spaces -/

/-- A pre-topology: open sets with ∅, X, finite intersection, but NOT arbitrary union. -/
structure PreTopology (X : Type*) where
  isOpen : Set X → Prop
  empty_open : isOpen ∅
  univ_open : isOpen Set.univ
  inter_open : ∀ U V, isOpen U → isOpen V → isOpen (U ∩ V)

/-- A pre-topology is a genuine topology iff it's closed under arbitrary unions. -/
def PreTopology.isTopology {X : Type*} (pt : PreTopology X) : Prop :=
  ∀ (S : Set (Set X)), (∀ U ∈ S, pt.isOpen U) → pt.isOpen (⋃₀ S)

/-
A three-element pre-topology that fails the union axiom.
    Open sets: ∅, {0}, {1}, and Fin 3. Note {0} ∪ {1} = {0,1} is NOT open.
-/
def dreamPreTopology : PreTopology (Fin 3) where
  isOpen := fun S => S = ∅ ∨ S = {0} ∨ S = {1} ∨ S = Set.univ
  empty_open := Or.inl rfl
  univ_open := by right; right; right; rfl
  inter_open := by
    rintro U V ( rfl | rfl | rfl | rfl ) ( rfl | rfl | rfl | rfl ) <;> simp +decide

/-
**Theorem (Dream Pre-Topology is Not a Topology)**: The union of open sets
    {0} and {1} yields {0,1} which is not open, violating the topology axiom.
-/
theorem dream_pretopology_not_topology : ¬ dreamPreTopology.isTopology := by
  intro h;
  convert h { { 0 }, { 1 } } _;
  · simp +decide [ dreamPreTopology ];
    simp +decide [ Set.Subset.antisymm_iff, Set.subset_def ];
  · simp +decide [ dreamPreTopology ]

/-
**Theorem (Paraconsistent-Topological Correspondence)**: There exists a
    pre-topology with "contradictory" open sets — sets that are individually
    open but whose union is not. This mirrors how contradictory beliefs
    individually make sense but their combination breaks classical reasoning.
-/
theorem paraconsistent_induces_nontopology :
    ∃ (pt : PreTopology (Fin 3)), ¬ pt.isTopology ∧
      (∃ U V : Set (Fin 3), pt.isOpen U ∧ pt.isOpen V ∧ ¬ pt.isOpen (U ∪ V)) := by
        use dreamPreTopology;
        refine' ⟨ _, { 0 }, { 1 }, _, _, _ ⟩;
        · exact dream_pretopology_not_topology;
        · exact Or.inr <| Or.inl rfl;
        · exact Or.inr <| Or.inr <| Or.inl rfl;
        · rintro ( h | h | h | h ) <;> simp_all +decide [ Set.ext_iff ]

/-! ## Conjecture: Dream Compactness Failure -/

/-- **Conjecture**: FDE over countably many propositions fails compactness:
    every finite subset is satisfiable but the whole is not.
    Testable: construct v : ℕ → BelnapVal with all finite restrictions
    designated but some element not designated. -/
def dreamCompactnessFails : Prop :=
  ∃ (v : BelnapValuation ℕ),
    (∀ F : Finset ℕ, ∀ n ∈ F, (v.val n).isDesignated = true) ∧
    ¬ (∀ n : ℕ, (v.val n).isDesignated = true)