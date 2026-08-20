import Catalog.Novelty.ArgumentationCore

/-!
# Dream logic: contradictory evidence, revision, and finitary openness

This study separates three ideas often compressed into the phrase “dream logic.”
A signed information state can support both an assertion and its denial without
supporting every assertion. A revision operation may retract the opposite sign,
so accepted information is non-monotone in time. Finally, finite information
states form a finitary topology: they are stable under finite unions and finite
intersections, but an infinite union can escape the class.

The last structure is deliberately called a *finitary topology*, rather than a
topology. Ordinary topologies are closed under arbitrary unions by definition;
the failure of arbitrary-union closure is therefore a boundary theorem, not an
example of an exotic topology.
-/

namespace DreamLogic

/-- A literal is an atom equipped with a sign: `true` is positive evidence and
`false` is negative evidence. -/
abbrev Literal (Atom : Type*) := Atom × Bool

/-- Flip the sign of a literal. -/
def opposite {Atom : Type*} (l : Literal Atom) : Literal Atom := (l.1, !l.2)

@[simp] theorem opposite_fst {Atom : Type*} (l : Literal Atom) : (opposite l).1 = l.1 := by
  rcases l with ⟨a, s⟩
  rfl

@[simp] theorem opposite_ne {Atom : Type*} (l : Literal Atom) : opposite l ≠ l := by
  rcases l with ⟨a, s⟩
  cases s <;> simp [opposite]

@[simp] theorem opposite_involutive {Atom : Type*} (l : Literal Atom) :
    opposite (opposite l) = l := by
  rcases l with ⟨a, s⟩
  cases s <;> rfl

/-- A belief state accepts exactly the literals it contains. -/
def Entails {Atom : Type*} (B : Set (Literal Atom)) (l : Literal Atom) : Prop := l ∈ B

/-- An atom is contradictory in `B` when both signs are accepted. -/
def Contradictory {Atom : Type*} (B : Set (Literal Atom)) (a : Atom) : Prop :=
  (a, true) ∈ B ∧ (a, false) ∈ B

/-- Revision accepts `l` and retracts its opposite. -/
def revise {Atom : Type*} (B : Set (Literal Atom)) (l : Literal Atom) :
    Set (Literal Atom) := insert l (B \ {opposite l})

/-
Revision accepts its new literal while rejecting the contrary literal.
-/
theorem revise_accepts_and_retracts {Atom : Type*} (B : Set (Literal Atom))
    (l : Literal Atom) :
    Entails (revise B l) l ∧ ¬ Entails (revise B l) (opposite l) := by
  simp +decide [ Entails, revise ]

/-
A direct contradiction is not explosive: with at least two atoms, the state
containing both signs of `a` need not entail a positive assertion about `b`.
-/
theorem contradiction_without_explosion {Atom : Type*} {a b : Atom} (hab : a ≠ b) :
    Contradictory ({(a, true), (a, false)} : Set (Literal Atom)) a ∧
      ¬ Entails ({(a, true), (a, false)} : Set (Literal Atom)) (b, true) := by
  unfold Contradictory Entails; aesop;

/-
Retraction makes revision genuinely non-monotone: revising a contradictory
state by either of its literals loses information from the old state.
-/
theorem revision_is_nonmonotone {Atom : Type*} (l : Literal Atom) :
    ¬ ({l, opposite l} : Set (Literal Atom)) ⊆ revise {l, opposite l} l := by
  simp +decide [ Set.subset_def, revise ]

/-
Successive contrary revisions are order-sensitive. The latest sign wins.
-/
theorem contrary_revisions_do_not_commute {Atom : Type*} (B : Set (Literal Atom))
    (l : Literal Atom) :
    revise (revise B l) (opposite l) ≠ revise (revise B (opposite l)) l := by
  simp +decide [Set.ext_iff]
  use l.1; simp +decide [ revise ] ;
  cases l ; simp +decide [ opposite ];
  grind

/-- Complementary literals attack one another. This imports the argumentation
viewpoint into signed evidence. -/
def contraryAttack {Atom : Type*} (l k : Literal Atom) : Prop := k = opposite l

/-- Semantic consistency means that no atom carries both signs. -/
def Consistent {Atom : Type*} (B : Set (Literal Atom)) : Prop :=
  ∀ a, ¬ Contradictory B a

/-
Consistency is exactly conflict-freedom for the complementary attack graph.
-/
theorem consistent_iff_conflictFree {Atom : Type*} (B : Set (Literal Atom)) :
    Consistent B ↔ ArgTop.ConflictFree contraryAttack B := by
  constructor;
  · intro hB a ha b hb hab;
    cases' a with a₁ a₂ ; cases' b with b₁ b₂ ; simp_all +decide [ contraryAttack ];
    cases a₂ <;> cases b₂ <;> tauto;
  · intro h a ha
    have hno := h (a, true) ha.1 (a, false) ha.2
    simp_all +decide [contraryAttack]
    exact hno rfl

/-
Revision preserves global consistency: it removes the unique sign that could
conflict with the newly accepted literal.
-/
theorem consistent_revise {Atom : Type*} {B : Set (Literal Atom)}
    (hB : Consistent B) (l : Literal Atom) : Consistent (revise B l) := by
  intro a ha;
  unfold revise at ha;
  unfold Contradictory at *;
  by_cases h : a = l.1 <;> simp_all +decide [ opposite ];
  · grind;
  · exact hB a ⟨ ha.1.resolve_left ( by aesop ), ha.2.resolve_left ( by aesop ) ⟩

/-! ## Finitary openness -/

/-- A finitary topology consists of the finite subsets. It contains the empty
set and is closed under binary intersections and unions, but need not admit
infinite unions. -/
def FinitaryOpen (X : Type*) := {U : Set X // U.Finite}

namespace FinitaryOpen

variable {X : Type*}

/-- The empty information state is finitarily open. -/
def empty : FinitaryOpen X := ⟨∅, Set.finite_empty⟩

/-- Binary intersection of finitary opens. -/
def inter (U V : FinitaryOpen X) : FinitaryOpen X :=
  ⟨U.1 ∩ V.1, U.2.inter_of_left V.1⟩

/-- Binary union of finitary opens. -/
def union (U V : FinitaryOpen X) : FinitaryOpen X :=
  ⟨U.1 ∪ V.1, U.2.union V.2⟩

/-
Any finite union of finitary opens remains finitarily open.
-/
theorem finite_sUnion {𝒰 : Set (Set X)} (h𝒰 : 𝒰.Finite)
    (hopen : ∀ U ∈ 𝒰, U.Finite) : (⋃₀ 𝒰).Finite := by
  exact h𝒰.sUnion hopen

/-- Singleton information states are finitarily open. -/
def singleton (x : X) : FinitaryOpen X := ⟨{x}, Set.finite_singleton x⟩

/-
The union of all singleton states on `ℕ` is the whole space.
-/
theorem iUnion_singletons_nat : (⋃ n : ℕ, ({n} : Set ℕ)) = Set.univ := by
  aesop

/-
**Arbitrary-union obstruction.** Although every singleton of `ℕ` is
finitarily open, their countable union is not. Thus these opens satisfy the
finite lattice laws but cannot be the opens of a topology containing the whole
space.
-/
theorem arbitrary_union_not_finitary :
    ¬ (⋃ n : ℕ, ({n} : Set ℕ)).Finite := by
  rw [iUnion_singletons_nat]
  exact Set.infinite_univ

end FinitaryOpen

/-- Finite belief states are precisely finitary opens in the literal space. -/
def beliefOpen {Atom : Type*} (B : Set (Literal Atom)) (hB : B.Finite) :
    FinitaryOpen (Literal Atom) := ⟨B, hB⟩

/-
Revision is an internal dynamic on finite opens.
-/
theorem finite_revise {Atom : Type*} {B : Set (Literal Atom)}
    (hB : B.Finite) (l : Literal Atom) : (revise B l).Finite := by
  exact Set.Finite.insert l ( hB.subset fun x hx => hx.1 )

/-
**Logic–argumentation–topology bridge.** A finite consistent dream state is
simultaneously a finitary open and a conflict-free set in the complementary
attack graph; revision remains inside both classes.
-/
theorem revision_bridge {Atom : Type*} {B : Set (Literal Atom)}
    (hfinite : B.Finite) (hconsistent : Consistent B) (l : Literal Atom) :
    (revise B l).Finite ∧ ArgTop.ConflictFree contraryAttack (revise B l) := by
  constructor
  · exact finite_revise hfinite l
  · exact (consistent_iff_conflictFree _).1 (consistent_revise hconsistent l)

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer), ranked by expected impact:
-- (1) signed paraconsistent states admit a common representation as
--     conflict-free argument sets and finitary opens after revision;
-- (2) every finite sequence of revisions has a canonical normal form determined
--     by the last occurrence of each atom;
-- (3) revision trajectories form directed paths in the face graph of the
--     complementary-attack complex;
-- (4) compactness of an ambient information topology characterizes when local
--     finite dream fragments assemble into a global state;
-- (5) arbitrary-union failure is exactly the obstruction to treating finite
--     epistemic states as an ordinary topology;
-- (6) contradiction without explosion persists under every irrelevant revision.
-- The first four are cross-domain conjectures joining dynamics, argumentation,
-- combinatorial topology, and compactness.
-- Experiment (Experimenter): the four states over one atom were enumerated.
-- Revision by the positive sign sends the empty, positive-only, negative-only,
-- and contradictory states respectively to positive-only in every case; negative
-- revision behaves symmetrically. On two atoms, the contradictory state at the
-- first atom omits both signs of the second, directly falsifying explosion.
-- Analysis (Analyst): two independent boundaries emerged. Complementary attack
-- converts consistency into conflict-freedom, while revision removes exactly one
-- attacker before inserting its target. Separately, finite subsets have all
-- finite lattice operations but the union of the natural-number singletons is
-- infinite. These combine in `revision_bridge` but should not be conflated:
-- paraconsistency is semantic, arbitrary-union failure is a size restriction.
-- Critique (Critic): ordinary topological spaces cannot have opens that fail
-- arbitrary-union closure. The correct object is therefore explicitly named a
-- finitary topology. Non-explosion requires distinct atoms; without that guard,
-- the alleged unrelated conclusion could be one side of the contradiction.
-- None of the bridge results identifies consistency with absence of all attacks;
-- it uses the specific complementary attack relation.
-- Synthesis (Principal Investigator): signed sets provide the smallest model
-- supporting coexistence and retraction. The imported conflict-free semantics
-- supplies the argumentation bridge, and finite support supplies a precise
-- pretopological boundary. The resulting revision dynamic preserves both the
-- semantic and finitary invariants.
-- !-- End Lab Notes -- !--

end DreamLogic