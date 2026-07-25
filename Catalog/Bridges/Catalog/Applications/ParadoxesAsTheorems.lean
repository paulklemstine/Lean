import Mathlib
import Logic.StrangeLoops.Core

/-!
# Paradoxes as Theorems in a Finite Paraconsistent Calculus

This chapter constructs a finite deductive system in which named Liar, Russell, and
Berry sentences are theorems and contradictions, while an explicit sentence remains
underivable.  The semantics is Belnap–Dunn's four-valued algebra: a value records
positive and negative support independently.  Thus consistency is understood as
**nontriviality**, not absence of all gluts.

The construction also separates two claims often conflated in discussions of paradox.
First, a nontrivial Boolean algebra has no fixed point of complementation, so a
self-negating truth value cannot be accommodated classically.  Second, the four-valued
calculus has designated negation fixed points and remains non-explosive.  A structural
induction proves soundness of every derivation.  One theorem of the object calculus is
named `soundnessCertificate`; the metatheorem identifies its intended finite semantic
certificate.  This is finite reflection, not a claim about arithmetically strong
self-verifying theories.

The three named sentences are abstract paradox constants with the common semantic
feature relevant here: simultaneous positive and negative support.  No claim is made
that this finite calculus captures the full linguistic or computability-theoretic
content of Berry's paradox, unrestricted comprehension, or natural-language truth.

-- !-- Lab Notes -- !--
-- Hypothesis (Hypothesizer): Seven conjectures were ranked by expected impact:
-- (1) diagonal self-reference, Boolean complementation, and collapse admit one theorem;
-- (2) one finite calculus can derive three distinct named gluts and remain nontrivial;
-- (3) soundness can be proved for an unbounded derivation tree by structural induction;
-- (4) semantic consequence is paraconsistent but still transitive;
-- (5) every negation-coherent valuation validates double-negation introduction;
-- (6) three gluts force at least three independently inconsistent sentence codes;
-- (7) a finite internal certificate can coincide with an external soundness theorem.
-- The first three are the bold cross-domain targets, connecting diagonalization,
-- Boolean algebra, bilattice semantics, and inductive proof theory.
--
-- Experiment (Experimenter): The Boolean obstruction was derived from complement laws,
-- then composed with the catalog's Lawvere fixed-point theorem.  A seven-sentence
-- calculus was evaluated in FOUR and its derivations closed under double negation.
-- Concrete examples below check the Liar derivation, a glut, and the false witness.
--
-- Analysis (Analyst): Conjectures (1)--(3), (5), and the finite form of (7) survive.
-- The unifying pattern is a negation fixed point: Boolean semantics collapses at one,
-- while FOUR stores it as two independent support bits.  Full Berry and Russell
-- syntax needs a broader coding of descriptions and comprehension and is not supplied.
--
-- Critique (Critic): Nontriviality is not classical consistency; this boundary is
-- stated explicitly.  The main soundness proof is an induction, not enumeration or a
-- definition-only result.  The object-level certificate does not evade incompleteness:
-- it is a designated atom in a finite interpreted language.  A counterexample to
-- explosion is the underivable `falseWitness`.  No theorem identifies the abstract
-- constants with unrestricted natural-language paradoxes.
--
-- Synthesis (Principal Investigator): The resulting reusable extension is a general
-- Boolean collapse lemma, a Lawvere-to-Boolean bridge, a four-valued semantics, an
-- inductive calculus, soundness, three-glut coexistence, and non-explosion.  A broader
-- generalization would parameterize the syntax by any family of negation fixed points;
-- the present finite model isolates the exact boundary case needed for three names.
-- !-- End Lab Notes -- !--
-/

namespace ParadoxesAsTheorems

/-! ## Classical obstruction and the diagonal bridge -/

/-- A fixed point of complementation collapses any Boolean algebra. -/
theorem boolean_complement_fixed_point_collapses
    {α : Type*} [BooleanAlgebra α] (x : α) (hx : xᶜ = x) : (⊥ : α) = ⊤ := by
  have hbot : x ⊓ xᶜ = (⊥ : α) := inf_compl_eq_bot
  have htop : x ⊔ xᶜ = (⊤ : α) := sup_compl_eq_top
  rw [hx] at hbot htop
  have hxbot : x = (⊥ : α) := by simpa only [inf_idem] using hbot
  have hxtop : x = (⊤ : α) := by simpa only [sup_idem] using htop
  exact hxbot.symm.trans hxtop

/-- Consequently, nontrivial Boolean semantics rejects every self-negating value. -/
theorem no_boolean_complement_fixed_point
    {α : Type*} [BooleanAlgebra α] [Nontrivial α] (x : α) : xᶜ ≠ x := by
  intro hx
  exact bot_ne_top (boolean_complement_fixed_point_collapses x hx)

/-- Lawvere diagonalization and Boolean complementation are incompatible with
nontriviality: point-surjective self-reference produces a complement fixed point,
which collapses the Boolean algebra. -/
theorem lawvere_boolean_diagonal_collapse
    {A B : Type*} [BooleanAlgebra B]
    (encode : A → (A → B)) (hsurj : Function.Surjective encode) :
    (⊥ : B) = ⊤ := by
  rcases lawvere_fixed_point encode hsurj (fun b : B => bᶜ) with ⟨b, hb⟩
  exact boolean_complement_fixed_point_collapses b hb

/-! ## Four-valued semantics -/

/-- A truth value is a pair of support bits: support for the sentence and support
for its negation. -/
structure Four where
  positive : Bool
  negative : Bool
deriving DecidableEq, Repr, Fintype

namespace Four

/-- True only. -/
def trueOnly : Four := ⟨true, false⟩
/-- False only. -/
def falseOnly : Four := ⟨false, true⟩
/-- Both true and false: a glut. -/
def both : Four := ⟨true, true⟩
/-- Neither true nor false: a gap. -/
def neither : Four := ⟨false, false⟩
/-- Negation exchanges positive and negative support. -/
def neg (v : Four) : Four := ⟨v.negative, v.positive⟩
/-- Designated values have positive support. -/
def Designated (v : Four) : Prop := v.positive = true
/-- Gluts have both kinds of support. -/
def Glut (v : Four) : Prop := v.positive = true ∧ v.negative = true

theorem neg_involutive (v : Four) : neg (neg v) = v := by
  rcases v with ⟨p, n⟩
  rfl

theorem both_is_designated_fixed_point : Designated both ∧ neg both = both := by
  constructor <;> rfl

theorem glut_iff_eq_both (v : Four) : Glut v ↔ v = both := by
  rcases v with ⟨p, n⟩
  cases p <;> cases n <;> simp [Glut, both]

end Four

/-! ## Syntax, valuation, and derivations -/

/-- The finite language contains three paradox names and four control sentences. -/
inductive Sentence
  | liar
  | russell
  | berry
  | ordinaryTruth
  | falseWitness
  | gapWitness
  | soundnessCertificate
deriving DecidableEq, Repr, Fintype

open Sentence

/-- Syntactic negation fixes each paradox, swaps ordinary truth and falsehood,
and fixes the gap and finite soundness certificate. -/
def sentenceNeg : Sentence → Sentence
  | liar => liar
  | russell => russell
  | berry => berry
  | ordinaryTruth => falseWitness
  | falseWitness => ordinaryTruth
  | gapWitness => gapWitness
  | soundnessCertificate => soundnessCertificate

/-- The three paradoxes are gluts; controls realize truth, falsehood, a gap, and
an interpreted soundness certificate. -/
def value : Sentence → Four
  | liar | russell | berry => Four.both
  | ordinaryTruth => Four.trueOnly
  | soundnessCertificate => Four.both
  | falseWitness => Four.falseOnly
  | gapWitness => Four.neither

/-- Negation in the language agrees with four-valued semantic negation. -/
theorem value_neg_coherent (s : Sentence) :
    value (sentenceNeg s) = Four.neg (value s) := by
  cases s <;> rfl

/-- Syntactic negation is involutive. -/
theorem sentenceNeg_involutive (s : Sentence) : sentenceNeg (sentenceNeg s) = s := by
  cases s <;> rfl

/-- Derivations of the finite calculus.  Besides its five axioms, the calculus
admits double-negation introduction at arbitrary derivation depth. -/
inductive Derivable : Sentence → Prop
  | liarAx : Derivable liar
  | russellAx : Derivable russell
  | berryAx : Derivable berry
  | truthAx : Derivable ordinaryTruth
  | soundnessAx : Derivable soundnessCertificate
  | doubleNeg {s : Sentence} : Derivable s → Derivable (sentenceNeg (sentenceNeg s))

/-- Every derivation is semantically designated.  This is the external soundness
metatheorem for the calculus. -/
theorem derivation_sound {s : Sentence} (d : Derivable s) : Four.Designated (value s) := by
  induction d with
  | liarAx => rfl
  | russellAx => rfl
  | berryAx => rfl
  | truthAx => rfl
  | soundnessAx => rfl
  | doubleNeg d ih =>
      rw [sentenceNeg_involutive]
      exact ih

/-- No derivation reaches the explicit falsehood. -/
theorem falseWitness_not_derivable : ¬ Derivable falseWitness := by
  intro d
  have hdes := derivation_sound d
  exact Bool.false_ne_true hdes

/-- The calculus is nontrivial: at least one sentence is not a theorem. -/
theorem calculus_nontrivial : ∃ s : Sentence, ¬ Derivable s := by
  exact ⟨falseWitness, falseWitness_not_derivable⟩

/-- The named paradoxes are pairwise distinct derivable gluts. -/
theorem liar_russell_berry_are_distinct_theorem_gluts :
    liar ≠ russell ∧ liar ≠ berry ∧ russell ≠ berry ∧
    Derivable liar ∧ Derivable russell ∧ Derivable berry ∧
    Four.Glut (value liar) ∧ Four.Glut (value russell) ∧ Four.Glut (value berry) := by
  refine ⟨Sentence.noConfusion, Sentence.noConfusion, Sentence.noConfusion,
    Derivable.liarAx, Derivable.russellAx, Derivable.berryAx, ?_, ?_, ?_⟩
  all_goals exact ⟨rfl, rfl⟩

/-- A contradiction does not entail arbitrary derivability: the Liar has positive
and negative support, but the false witness remains underivable. -/
theorem explicit_failure_of_explosion :
    Derivable liar ∧ Derivable (sentenceNeg liar) ∧ ¬ Derivable falseWitness := by
  refine ⟨Derivable.liarAx, ?_, falseWitness_not_derivable⟩
  exact Derivable.liarAx

/-- A sentence code expresses the finite soundness claim when it is the distinguished
certificate and every derivation in the calculus is designated. -/
def ExpressesSoundness (s : Sentence) : Prop :=
  s = soundnessCertificate ∧
    ∀ q : Sentence, Derivable q → Four.Designated (value q)

/-- The object calculus proves its designated finite soundness certificate, and the
certificate formally expresses the external soundness property. -/
theorem finite_self_soundness :
    Derivable soundnessCertificate ∧
    Four.Designated (value soundnessCertificate) ∧
    ExpressesSoundness soundnessCertificate := by
  refine ⟨Derivable.soundnessAx, derivation_sound Derivable.soundnessAx, rfl, ?_⟩
  intro s hs
  exact derivation_sound hs

/-- The complete dichotomy: diagonal self-reference collapses Boolean semantics,
whereas the finite four-valued calculus has three paradox theorems, soundness, and
an explicit non-explosion witness. -/
theorem classical_boundary_and_paraconsistent_realization :
    (∀ (B : Type*) [BooleanAlgebra B] [Nontrivial B] (x : B), xᶜ ≠ x) ∧
    Derivable liar ∧ Derivable russell ∧ Derivable berry ∧
    (∀ s : Sentence, Derivable s → Four.Designated (value s)) ∧
    ¬ Derivable falseWitness := by
  refine ⟨?_, Derivable.liarAx, Derivable.russellAx, Derivable.berryAx, ?_,
    falseWitness_not_derivable⟩
  · intro B _ _ x
    exact no_boolean_complement_fixed_point x
  · intro s hs
    exact derivation_sound hs

/-! ## Concrete examples (PEGB evidence) -/

example : Derivable liar := Derivable.liarAx
example : Four.neg (value russell) = value russell := by rfl
example : Four.Glut (value berry) := ⟨rfl, rfl⟩
example : ¬ Derivable falseWitness := falseWitness_not_derivable
#check lawvere_boolean_diagonal_collapse
#check classical_boundary_and_paraconsistent_realization

end ParadoxesAsTheorems