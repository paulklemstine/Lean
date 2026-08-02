import Mathlib
import Bridges.VoiceLeadingCategory

/-!
# First-species counterpoint and thin categories

This file tests the proposed categorical model against explicit local first-species
rules.  It reuses `VoiceLeading.Voicing` from the catalog.  A legal one-step motion
has consonant endpoints, stepwise motion in both voices, and no similar motion
between two perfect consonances.

The test has two outcomes.

* One-step legal motions are not closed under composition, so they are not the
  morphisms of a category.
* The reflexive-transitive closure does form the expected thin generated category.

For the usual simple consonances from unison through octave, there are seven
interval objects, not twelve.  Thus the proposed twelve-object identification is
refuted for this explicit standard encoding rather than asserted without a choice
of twelve musical states.
-/

open CategoryTheory

namespace SonicCounterpoint

abbrev Dyad := VoiceLeading.Voicing 2

/-- A two-voice sonority with lower voice `l` and upper voice `u`. -/
def dyad (l u : ℤ) : Dyad := ![l, u]

/-- Directed vertical interval of a dyad, in semitones. -/
def verticalInterval (x : Dyad) : ℤ := x 1 - x 0

/-- The simple consonances used in strict first species, through the octave. -/
def Consonant (k : ℤ) : Prop :=
  Int.natAbs k ∈ ({0, 3, 4, 7, 8, 9, 12} : Finset ℕ)

/-- Perfect consonances among the allowed simple consonances. -/
def Perfect (k : ℤ) : Prop :=
  Int.natAbs k ∈ ({0, 7, 12} : Finset ℕ)

/-- Both voices move by at most a whole tone. -/
def Stepwise (x y : Dyad) : Prop :=
  Int.natAbs (y 0 - x 0) ≤ 2 ∧ Int.natAbs (y 1 - x 1) ≤ 2

/-- Both voices move strictly in the same direction. -/
def SimilarMotion (x y : Dyad) : Prop :=
  (x 0 < y 0 ∧ x 1 < y 1) ∨ (y 0 < x 0 ∧ y 1 < x 1)

/-- The local first-species rule tested in this development. -/
def PermittedMotion (x y : Dyad) : Prop :=
  Consonant (verticalInterval x) ∧
  Consonant (verticalInterval y) ∧
  Stepwise x y ∧
  ¬ (Perfect (verticalInterval x) ∧ Perfect (verticalInterval y) ∧
      SimilarMotion x y)

instance permittedMotionDecidable (x y : Dyad) : Decidable (PermittedMotion x y) := by
  unfold PermittedMotion Consonant Perfect Stepwise SimilarMotion verticalInterval
  infer_instance

/-- Stationary motion is legal whenever its sonority is consonant. -/
theorem permittedMotion_refl_of_consonant (x : Dyad)
    (hx : Consonant (verticalInterval x)) : PermittedMotion x x := by
  refine ⟨hx, hx, ?_, ?_⟩
  · simp [Stepwise]
  · simp [SimilarMotion]

/-- Two successive legal stepwise motions need not compose to a legal one-step
motion.  The witness keeps a minor third while both parts move by two semitones
at each step. -/
theorem permittedMotion_not_transitive :
    ∃ x y z : Dyad,
      PermittedMotion x y ∧ PermittedMotion y z ∧ ¬ PermittedMotion x z := by
  refine ⟨dyad 0 3, dyad 2 5, dyad 4 7, ?_⟩
  norm_num [PermittedMotion, Consonant, Perfect, Stepwise, SimilarMotion,
    verticalInterval, dyad]

/-- Consequently, the raw one-step rule cannot itself be the hom relation of a
thin category: it violates the closure demanded by composition. -/
theorem no_preorder_with_exactly_permitted_motions :
    ¬ ∃ (_inst : Preorder Dyad),
        ∀ x y : Dyad, @LE.le Dyad _inst.toLE x y ↔ PermittedMotion x y := by
  rintro ⟨inst, h⟩
  obtain ⟨x, y, z, hxy, hyz, hxz⟩ := permittedMotion_not_transitive
  have hxy' : @LE.le Dyad inst.toLE x y := (h x y).2 hxy
  have hyz' : @LE.le Dyad inst.toLE y z := (h y z).2 hyz
  exact hxz ((h x z).1 (inst.le_trans x y z hxy' hyz'))

/-- Reachability by finitely many permitted motions. -/
def Reachable (x y : Dyad) : Prop := Relation.ReflTransGen PermittedMotion x y

/-- A wrapper ensures that the generated order is distinct from the catalog's
pointwise order on integer-valued voicings. -/
structure GeneratedState where
  voices : Dyad

/-- Order in the generated category is precisely finite-path reachability. -/
instance generatedStatePreorder : Preorder GeneratedState where
  le x y := Reachable x.voices y.voices
  le_refl _ := Relation.ReflTransGen.refl
  le_trans _ _ _ := Relation.ReflTransGen.trans

/-- Every direct permitted motion gives a finite path and hence a morphism in
this generated category. -/
theorem permittedMotion_implies_generated_order {x y : GeneratedState}
    (h : PermittedMotion x.voices y.voices) : x ≤ y := by
  exact Relation.ReflTransGen.single h

/-- Morphisms in the generated category are exactly finite legal-motion paths. -/
def generatedHomEquiv (x y : GeneratedState) :
    (x ⟶ y) ≃ Reachable x.voices y.voices where
  toFun := leOfHom
  invFun := fun h => homOfLE h
  left_inv _ := Subsingleton.elim _ _
  right_inv _ := Subsingleton.elim _ _

/-- The generated counterpoint category is thin. -/
theorem generated_category_thin (x y : GeneratedState) :
    Subsingleton (x ⟶ y) := by
  infer_instance

/-- The seven named simple consonance objects used by the model. -/
inductive SimpleConsonance
  | unison | minorThird | majorThird | perfectFifth
  | minorSixth | majorSixth | octave
  deriving DecidableEq, Fintype

/-- Semitone realization of each named consonance. -/
def SimpleConsonance.semitones : SimpleConsonance → ℕ
  | .unison => 0
  | .minorThird => 3
  | .majorThird => 4
  | .perfectFifth => 7
  | .minorSixth => 8
  | .majorSixth => 9
  | .octave => 12

/-- Exhaustive enumeration of the simple consonance object type. -/
theorem simpleConsonance_card : Fintype.card SimpleConsonance = 7 := by
  decide

/-- The standard simple-consonance object type cannot have twelve elements. -/
theorem simpleConsonance_card_ne_twelve :
    Fintype.card SimpleConsonance ≠ 12 := by
  rw [simpleConsonance_card]
  norm_num

/-- The semitone realization is injective, so the seven-object count does not
arise by accidentally identifying two named consonances. -/
theorem SimpleConsonance.semitones_injective :
    Function.Injective SimpleConsonance.semitones := by
  intro a b h
  fin_cases a <;> fin_cases b <;> simp_all [SimpleConsonance.semitones]

/-- Every named interval realizes one of the declared consonant semitone values. -/
theorem SimpleConsonance.realization_is_consonant (i : SimpleConsonance) :
    Consonant (i.semitones : ℤ) := by
  cases i <;> norm_num [SimpleConsonance.semitones, Consonant]

/-- Canonical realization with a stationary bass at pitch zero. -/
def SimpleConsonance.canonicalDyad (i : SimpleConsonance) : Dyad :=
  dyad 0 i.semitones

/-- The explicit local motion relation on the seven canonical interval objects. -/
def CanonicalMotion (i j : SimpleConsonance) : Prop :=
  PermittedMotion i.canonicalDyad j.canonicalDyad

/-- The complete finite table of canonical legal motions. -/
instance canonicalMotionDecidable (i j : SimpleConsonance) :
    Decidable (CanonicalMotion i j) := permittedMotionDecidable _ _

def allCanonicalMotions : Finset (SimpleConsonance × SimpleConsonance) :=
  Finset.univ.filter fun p => CanonicalMotion p.1 p.2

/-- Exhaustive calculation: exactly fifteen ordered one-step motions are legal
among the seven canonical consonance representatives (including identities). -/
theorem allCanonicalMotions_card : allCanonicalMotions.card = 15 := by
  decide

/-- The canonical motion table contains a genuine directed edge between distinct
interval objects (minor third to major third). -/
theorem minorThird_to_majorThird :
    CanonicalMotion .minorThird .majorThird := by
  norm_num [CanonicalMotion, SimpleConsonance.canonicalDyad, PermittedMotion,
    Consonant, Perfect, Stepwise, SimilarMotion, verticalInterval, dyad,
    SimpleConsonance.semitones]

/-- The reverse edge is also legal.  Hence reachability on interval names is a
preorder rather than a partial order unless mutually reachable intervals are
quotiented. -/
theorem majorThird_to_minorThird :
    CanonicalMotion .majorThird .minorThird := by
  norm_num [CanonicalMotion, SimpleConsonance.canonicalDyad, PermittedMotion,
    Consonant, Perfect, Stepwise, SimilarMotion, verticalInterval, dyad,
    SimpleConsonance.semitones]

end SonicCounterpoint