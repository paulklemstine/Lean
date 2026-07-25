import Mathlib.Order.Basic

/-!
# Strange loops and abstract incompleteness

This file isolates the order-theoretic core of a Gödel sentence.  A formal
system is represented externally by a predicate `Prov : Sentence → Prop`.
A strange loop is a sentence `g` satisfying `g ↔ ¬ Prov g`.

The results deliberately separate the diagonal/fixed-point hypothesis from
soundness.  They also give finite countermodels to two tempting but false
unqualified conjectures.
-/

namespace StrangeLoops

/-- A sentence that asserts its own unprovability (at the metalevel). -/
def IsGodelFixedPoint {Sentence : Type*} (Prov : Sentence → Prop)
    (meaning : Sentence → Prop) (g : Sentence) : Prop :=
  meaning g ↔ ¬ Prov g

/-- Semantic reflection/soundness for the represented provability predicate. -/
def Reflects {Sentence : Type*} (Prov : Sentence → Prop)
    (meaning : Sentence → Prop) : Prop :=
  ∀ s, Prov s → meaning s

/-- The abstract first incompleteness argument: a reflected Gödel fixed point
is true but unprovable. -/
theorem reflected_fixedPoint_true_unprovable
    {Sentence : Type*} {Prov meaning : Sentence → Prop} {g : Sentence}
    (hreflect : Reflects Prov meaning)
    (hfixed : IsGodelFixedPoint Prov meaning g) :
    meaning g ∧ ¬ Prov g := by
  have hnp : ¬ Prov g := by
    intro hp
    exact hfixed.mp (hreflect g hp) hp
  exact ⟨hfixed.mpr hnp, hnp⟩

/-- Hence a system with semantic reflection and a Gödel fixed point cannot
prove every semantically true sentence. -/
theorem reflected_system_incomplete
    {Sentence : Type*} {Prov meaning : Sentence → Prop} {g : Sentence}
    (hreflect : Reflects Prov meaning)
    (hfixed : IsGodelFixedPoint Prov meaning g) :
    ¬ (∀ s, meaning s → Prov s) := by
  intro hall
  have ⟨htrue, hnprovable⟩ := reflected_fixedPoint_true_unprovable hreflect hfixed
  exact hnprovable (hall g htrue)

section PropositionalLattice

/-- Monotonicity is the order-theoretic condition on a provability operator on
`Prop`, ordered by implication. -/
def MonotoneProv (P : Prop → Prop) : Prop :=
  ∀ ⦃a b : Prop⦄, (a → b) → P a → P b

/-- Fixed points of the order-reversing operator `a ↦ ¬ P a` form an
antichain: comparable fixed points are logically equivalent.  This is the
precise lattice-theoretic constraint behind the “strange loop” metaphor. -/
theorem godel_fixedPoints_antichain
    {P : Prop → Prop} (hmono : MonotoneProv P)
    {g h : Prop} (hg : g ↔ ¬ P g) (hh : h ↔ ¬ P h)
    (hgh : g → h) : g ↔ h := by
  refine ⟨hgh, ?_⟩
  intro hh'
  have hnh : ¬ P h := hh.mp hh'
  by_contra ng
  have hPg : P g := Classical.not_not.mp (hg.not.mp ng)
  exact hnh (hmono hgh hPg)

/-- **Disproof of an unconditional fixed-point conjecture.**  The monotone
identity provability operator has no proposition satisfying `g ↔ ¬ P g`.
Thus monotonicity and lattice completeness alone do not manufacture diagonal
sentences; a syntactic diagonal lemma is indispensable. -/
theorem monotone_operator_without_godel_fixedPoint :
    ∃ P : Prop → Prop, MonotoneProv P ∧ ¬ ∃ g : Prop, g ↔ ¬ P g := by
  refine ⟨(fun a => a), ?_, ?_⟩
  · intro a b hab ha
    exact hab ha
  · intro ⟨g, hg⟩
    have h1 : g → ¬g := hg.1
    have h2 : ¬g → g := hg.2
    by_cases h : g
    · exact h1 h h
    · exact h (h2 h)

/-- A provability predicate decides every proposition when it proves either it
or its negation. -/
def SyntacticallyComplete (P : Prop → Prop) : Prop :=
  ∀ a : Prop, P a ∨ P (¬ a)

/-- A minimal consistency condition. -/
def Consistent (P : Prop → Prop) : Prop := ¬ P False

/-- **Disproof that self-reference alone forces incompleteness.**  There is a
monotone predicate with a Gödel fixed point which is syntactically complete.
The same countermodel is inconsistent, pinpointing the missing hypothesis. -/
theorem fixedPoint_can_coexist_with_completeness :
    ∃ (P : Prop → Prop) (g : Prop),
      MonotoneProv P ∧ (g ↔ ¬ P g) ∧ SyntacticallyComplete P ∧ ¬ Consistent P := by
  refine ⟨fun _ => True, False, ?_, ?_, ?_, ?_⟩
  · intro a b _; simp
  · simp
  · intro a; simp
  · simp [Consistent]

/-- Reflection excludes the inconsistent countermodel: no reflected operator
can prove `False`. -/
theorem reflection_implies_consistent
    {P : Prop → Prop} (hreflect : ∀ a : Prop, P a → a) : Consistent P := by
  intro hPFalse
  exact hreflect False hPFalse

/-- Under reflection, every propositional Gödel fixed point witnesses failure
of semantic completeness. -/
theorem propositional_godel_incompleteness
    {P : Prop → Prop} (hreflect : ∀ a : Prop, P a → a)
    {g : Prop} (hfixed : g ↔ ¬ P g) :
    g ∧ ¬ P g ∧ ¬ (∀ a : Prop, a → P a) := by
  have hnp : ¬ P g := by
    intro hp
    exact hfixed.mp (hreflect g hp) hp
  exact ⟨hfixed.mpr hnp, hnp, fun hall => hnp (hall g (hfixed.mpr hnp))⟩

end PropositionalLattice

end StrangeLoops