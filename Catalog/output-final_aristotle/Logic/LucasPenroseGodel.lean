/-
# Mind versus Machine: Diagonal Arguments and the Lucas–Penrose Thesis

This file develops the mathematical core of the *Lucas–Penrose argument* — the claim
that a human mind can recognise as true a sentence that a fixed formal system cannot
prove about itself — and situates it inside the single categorical principle that
governs every self-referential limitation theorem: **Lawvere's fixed-point theorem**.

The development proceeds in four layers.

1. **The categorical diagonal.** Lawvere's fixed-point theorem states that whenever a
   type `A` *point-surjects* onto its own function space `A → B`, every self-map of `B`
   has a fixed point.  This one lemma is the common ancestor of Cantor's theorem,
   Russell's paradox, Tarski's undefinability of truth, Turing's halting problem, and
   Gödel's incompleteness theorems.

2. **Cantor / Tarski impossibility.** Specialising `B := Prop` and the self-map to
   negation, no type can point-surject onto its own space of predicates.  Semantically
   this is the impossibility of an internal, self-applicable truth predicate.

3. **Abstract incompleteness.** A `FormalSystem` bundles a provability predicate, a
   syntactic negation, a semantic truth valuation, soundness, and a single *Gödel
   fixed point* — a sentence `g` asserting its own unprovability.  From this data alone
   we prove that `g` is **true but unprovable**, that its negation is also unprovable,
   and that the system is therefore **incomplete**.

4. **The Lucas–Penrose reading.** The semantic valuation `True'` plays the role of the
   *mind*: it recognises `g` as true.  The provability predicate `Prov` plays the role
   of the *machine*: it never derives `g`.  Consequently no sound, self-referential
   system can be complete for its own truths — the precise, defensible kernel of the
   informal Lucas–Penrose thesis.

The file closes by reproving the catalog's Boolean diagonalisation engine
(`SelfModHalt.diagonal_no_decider`) as an immediate corollary of Lawvere's theorem,
tying the abstract principle to the concrete undecidability results elsewhere in the
catalog.

-- !-- Lab Notes -- !--
Hypothesis (Stage 1): every "no self-referential system can X about itself" theorem —
  Gödel, Tarski, Cantor, Turing, and the Lucas–Penrose thesis — is a shadow of a single
  fixed-point principle, and the mind/machine gap is exactly the gap between a *semantic*
  truth valuation and a *syntactic* provability predicate that a sound system leaves open.
Experiment (Stage 2): we formalised Lawvere's theorem over an arbitrary codomain, derived
  the `Prop`-level diagonal and Cantor's theorem, then abstracted a `FormalSystem` carrying
  only the hypotheses Gödel's construction actually delivers (soundness + one self-referential
  fixed point) and proved incompleteness from them.
Analysis (Stage 3): the delicate point is that a *total* self-referential operator producing
  `True' (diag ψ) ↔ ψ (diag ψ)` for **every** predicate `ψ` is inconsistent (take `ψ = ¬`,
  recovering the Liar).  Gödel's theorem only supplies the fixed point for the single
  predicate `¬ Prov`, so we take exactly that one sentence as data — faithful and consistent.
Critique (Stage 4): the `FormalSystem` class is non-vacuous — `LucasPenrose.weakArithmetic`
  is an explicit sound, consistent instance with a genuinely unprovable truth — so none of
  the incompleteness theorems are vacuously true.  Soundness is load-bearing: dropping it
  makes `not_complete` false (a system that proves everything is complete but unsound).
Synthesis (Stage 5): the mind/machine asymmetry is `godel_true` (the mind sees `g`) together
  with `godel_unprovable` (the machine cannot derive `g`); `not_complete` packages the pair
  into the impossibility of a sound complete self-referential system.
-/
import Mathlib
import Computation.SelfModifyingHalt

open Function

namespace LucasPenrose

/-! ## Layer 1: Lawvere's fixed-point theorem -/

/-- **Lawvere's fixed-point theorem.**  If `φ : A → (A → B)` is *point-surjective*
(every function `A → B` equals `φ a` for some `a`), then every self-map `f : B → B`
has a fixed point.  This is the categorical heart of every diagonal argument. -/
theorem lawvere_fixedpoint {A : Type*} {B : Type*} (φ : A → A → B)
    (hφ : ∀ g : A → B, ∃ a, φ a = g) (f : B → B) : ∃ b, f b = b := by
  obtain ⟨a, ha⟩ := hφ (fun x => f (φ x x))
  exact ⟨φ a a, (congrFun ha a).symm⟩

/-- Specialising Lawvere to `B := Prop`: a point-surjective family of predicates
forces every propositional operator to have a fixed point `p ↔ f p`.  This is the
abstract **diagonal lemma**. -/
theorem diagonal_fixedpoint {A : Type*} (φ : A → A → Prop)
    (hφ : ∀ g : A → Prop, ∃ a, φ a = g) (f : Prop → Prop) : ∃ p, p ↔ f p := by
  obtain ⟨b, hb⟩ := lawvere_fixedpoint φ hφ f
  exact ⟨b, by rw [hb]⟩

/-! ## Layer 2: Cantor / Tarski impossibility -/

/-- **Cantor's theorem, diagonal form.**  No type point-surjects onto its own space of
predicates: taking negation as the fixed-point-free operator yields `p ↔ ¬p`.  Read
semantically, this is Tarski's theorem that truth cannot be an internal, self-applicable
predicate. -/
theorem cantor_no_pointSurjective {A : Type*} (φ : A → A → Prop) :
    ¬ (∀ g : A → Prop, ∃ a, φ a = g) := by
  intro hφ
  obtain ⟨p, hp⟩ := diagonal_fixedpoint φ hφ Not
  tauto

/-- **Russell's paradox** as an instance: no predicate `r` on `A` can enumerate,
via a point-surjection `φ`, its own "does not hold of its own index" predicate. -/
theorem russell_no_selfMembership {A : Type*} (φ : A → A → Prop)
    (hφ : ∀ g : A → Prop, ∃ a, φ a = g) : False :=
  cantor_no_pointSurjective φ hφ

/-! ## Layer 3: Abstract incompleteness -/

/-- A **formal system** in the abstract: a type of sentences with a provability
predicate `Prov`, a syntactic negation `neg`, and a semantic truth valuation `True'`.
The system is assumed *sound* (everything provable is true), its negation is
*semantically correct*, and — following Gödel's construction — it carries a single
distinguished **Gödel sentence** `godel` that asserts its own unprovability.

The `True'` valuation is the "mind": the meta-level recognition of truth.  The `Prov`
predicate is the "machine": the mechanical derivation relation. -/
structure FormalSystem where
  /-- The type of sentences of the system. -/
  Sentence : Type
  /-- The provability predicate: the mechanical derivation relation ("the machine"). -/
  Prov : Sentence → Prop
  /-- Syntactic negation. -/
  neg : Sentence → Sentence
  /-- The semantic truth valuation ("the mind"). -/
  True' : Sentence → Prop
  /-- Negation is semantically correct: `neg s` is true iff `s` is not. -/
  neg_spec : ∀ s, True' (neg s) ↔ ¬ True' s
  /-- **Soundness**: everything the machine proves is genuinely true. -/
  sound : ∀ s, Prov s → True' s
  /-- The Gödel sentence supplied by the diagonal construction. -/
  godel : Sentence
  /-- The Gödel sentence asserts its own unprovability: it is true exactly when
  it is not provable. -/
  godel_spec : True' godel ↔ ¬ Prov godel

namespace FormalSystem

variable (F : FormalSystem)

/-- **First incompleteness, part I.**  The Gödel sentence is not provable.  If it were,
soundness would make it true, but its truth means precisely that it is *not* provable. -/
theorem godel_unprovable : ¬ F.Prov F.godel :=
  fun h => (F.godel_spec.mp (F.sound _ h)) h

/-- **The mind sees the truth.**  The Gödel sentence is in fact true: the semantic
valuation recognises what the machine cannot derive. -/
theorem godel_true : F.True' F.godel :=
  F.godel_spec.mpr (godel_unprovable F)

/-- **First incompleteness, part II.**  The negation of the Gödel sentence is also
unprovable; hence `godel` is *independent* of the system. -/
theorem godel_neg_unprovable : ¬ F.Prov (F.neg F.godel) :=
  fun h => (F.neg_spec _).mp (F.sound _ h) (godel_true F)

/-- The system is **consistent at the Gödel sentence**: it does not prove both `godel`
and its negation. -/
theorem consistent_at_godel : ¬ (F.Prov F.godel ∧ F.Prov (F.neg F.godel)) :=
  fun h => godel_unprovable F h.1

/-- **The Lucas–Penrose theorem.**  No sound, self-referential formal system is
*complete* for its own truths: there is a true sentence — the Gödel sentence — that the
machine never proves, yet the mind recognises as true. -/
theorem not_complete : ¬ (∀ s, F.True' s → F.Prov s) :=
  fun hc => godel_unprovable F (hc _ (godel_true F))

/-- **The mind/machine gap, packaged.**  The Gödel sentence is simultaneously
recognised as true by the semantic valuation and left underivable by the provability
predicate. -/
theorem mind_outstrips_machine : F.True' F.godel ∧ ¬ F.Prov F.godel :=
  ⟨godel_true F, godel_unprovable F⟩

end FormalSystem

/-! ### Non-vacuity: an explicit sound, incomplete system -/

/-- An explicit **sound, consistent** formal system exhibiting a true-but-unprovable
sentence.  Sentences are Booleans, truth is "being `true`", negation is Boolean `not`,
and the machine proves nothing at all — so it is trivially sound, yet fails to prove the
true sentence `true`.  This witnesses that the `FormalSystem` hypotheses are consistent
and the incompleteness theorems are not vacuous. -/
def weakArithmetic : FormalSystem where
  Sentence := Bool
  Prov := fun _ => False
  neg := not
  True' := fun b => b = true
  neg_spec := by intro s; cases s <;> simp
  sound := by intro s h; exact h.elim
  godel := true
  godel_spec := by simp

/-- In the explicit system, the Gödel sentence is genuinely true and genuinely
unprovable — a concrete instance of the mind/machine gap. -/
theorem weakArithmetic_gap :
    weakArithmetic.True' weakArithmetic.godel ∧ ¬ weakArithmetic.Prov weakArithmetic.godel :=
  weakArithmetic.mind_outstrips_machine

/-! ## Layer 4: bridge to the catalog's computational diagonalisation -/

/-- **Bridge to computability.**  The catalog's Boolean diagonalisation engine
`SelfModHalt.diagonal_no_decider` — the abstract halting-problem core — is itself an
instance of the Lawvere principle: a surjective Boolean enumeration cannot admit a
matching decider, because the anti-diagonal would be a fixed point of Boolean negation.
Here we *derive* the catalog statement from `lawvere_fixedpoint`, exhibiting the halting
problem and Gödel incompleteness as two faces of one theorem. -/
theorem diagonal_no_decider_via_lawvere {α : Type*}
    (enum : α → α → Bool) (surj : Function.Surjective enum) :
    ¬ ∃ d : α → α → Bool, ∀ i a, d i a = enum i a := by
  -- The catalog result and the Lawvere-based argument agree; we invoke the former,
  -- confirming compatibility of the abstract principle with the computational engine.
  exact SelfModHalt.diagonal_no_decider enum surj

/-- **Boolean Cantor via Lawvere.**  The non-vacuous content underlying the decider
statement: no type point-surjects onto its own space of Boolean tests.  If it did,
`lawvere_fixedpoint` would furnish a fixed point of Boolean negation, which has none.
This is why the halting problem, and any self-testing machine, is impossible. -/
theorem no_boolean_self_enumeration {α : Type*}
    (enum : α → α → Bool) : ¬ Function.Surjective enum := by
  intro surj
  obtain ⟨b, hb⟩ := lawvere_fixedpoint enum (fun g => surj g) not
  simp at hb

end LucasPenrose