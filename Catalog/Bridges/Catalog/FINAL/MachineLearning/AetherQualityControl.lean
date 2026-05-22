/-
# Aether Quality Control: Formal Stress-Testing of Conjectures

This module formalizes a framework for **finite counterexample stress testing**
of parameterized conjecture families, and proves that enlarging the test suite
monotonically reduces the number of surviving false conjectures.

## Key Results

1. **Soundness**: A stress test that finds a counterexample certifies falsehood.
2. **Antitonicity**: Enlarging the test set can only reduce false positives.
3. **Counting monotonicity**: Over a finite hypothesis class, the *number* of
   surviving false hypotheses is monotone decreasing in the test set.
4. **Kill monotonicity**: Larger test sets kill at least as many false hypotheses.
-/

import Mathlib

namespace AetherQC

open Finset

/-! ## Part 1: Propositional Framework -/

variable {α : Type*} [DecidableEq α]

/-- A conjecture (represented by `good`) **survives** a stress test `T`
    if every tested candidate satisfies the predicate. -/
def Survives (good : α → Prop) [DecidablePred good] (T : Finset α) : Prop :=
  ∀ a ∈ T, good a

/-- A conjecture is **false on** a universe `U` if some element of `U` violates it. -/
def FalseOn (good : α → Prop) (U : Finset α) : Prop :=
  ∃ a ∈ U, ¬ good a

/-- A **false positive** is a conjecture that is false on the universe `U`
    but survives the stress test `T`. -/
def FalsePositive (good : α → Prop) [DecidablePred good]
    (U T : Finset α) : Prop :=
  FalseOn good U ∧ Survives good T

omit [DecidableEq α] in
/-- **Soundness**: if any tested candidate falsifies the predicate,
    then the conjecture does not survive the stress test. -/
theorem stressTest_sound
    (good : α → Prop) [DecidablePred good] (T : Finset α) :
    (∃ a ∈ T, ¬ good a) → ¬ Survives good T :=
  fun ⟨a, ha₁, ha₂⟩ h => ha₂ <| h a ha₁

omit [DecidableEq α] in
/-- **Equivalence**: survival is exactly the absence of a tested counterexample. -/
theorem survives_iff_no_test_counterexample
    (good : α → Prop) [DecidablePred good] (T : Finset α) :
    Survives good T ↔ ¬ ∃ a ∈ T, ¬ good a :=
  ⟨fun h ⟨a, ha, had⟩ => had <| h a ha,
   fun h a ha => Classical.not_not.1 fun had => h ⟨a, ha, had⟩⟩

omit [DecidableEq α] in
/-- **Antitonicity of false positives**: enlarging the stress test can only
    eliminate false positives, never create new ones. -/
theorem falsePositive_antitone
    (good : α → Prop) [DecidablePred good]
    {T₁ T₂ U : Finset α}
    (hsub : T₁ ⊆ T₂) :
    FalsePositive good U T₂ → FalsePositive good U T₁ :=
  fun h => ⟨h.1, fun a ha => h.2 a (hsub ha)⟩

omit [DecidableEq α] in
/-- Survival is antitone: larger test sets are harder to survive. -/
theorem survives_antitone
    (good : α → Prop) [DecidablePred good]
    {T₁ T₂ : Finset α}
    (hsub : T₁ ⊆ T₂) :
    Survives good T₂ → Survives good T₁ :=
  fun h a ha => h a (hsub ha)

/-! ## Part 2: Boolean / Computable Framework

We use a finite index type `ι` for the hypothesis class, with an
interpretation map `eval : ι → α → Bool`. This avoids `DecidableEq`
issues on function types.

All filter predicates use `∀ a ∈ T, ...` / `∃ a ∈ T, ...` which are
`Decidable` over `Finset`. -/

variable {ι : Type*} [DecidableEq ι]

/-- A hypothesis `i` **survives** the test set `T` if `eval i a = true`
    for every `a ∈ T`. -/
def survivesBool (eval : ι → α → Bool) (i : ι) (T : Finset α) : Prop :=
  ∀ a ∈ T, eval i a = true

/-- A hypothesis `i` **is false** on universe `U` if some `a ∈ U` has
    `eval i a = false`. -/
def isFalseProp (eval : ι → α → Bool) (i : ι) (U : Finset α) : Prop :=
  ∃ a ∈ U, eval i a = false

/-- The number of **false positive** hypotheses: those that are false on `U`
    but survive the stress test `T`. -/
noncomputable def falsePositiveCount (eval : ι → α → Bool) (H : Finset ι)
    (U T : Finset α) : Nat :=
  (H.filter (fun i => (∃ a ∈ U, eval i a = false) ∧ (∀ a ∈ T, eval i a = true))).card

/-- The set of hypotheses **killed** by test set `T`: those with at least one
    tested counterexample. -/
noncomputable def killedBy (eval : ι → α → Bool) (H : Finset ι)
    (T : Finset α) : Finset ι :=
  H.filter (fun i => ∃ a ∈ T, eval i a = false)

/-! ### Key lemma: survival is antitone in the test set (Bool version) -/

omit [DecidableEq α] [DecidableEq ι] in
/-- Survival under the Boolean interpretation is antitone in the test set. -/
theorem survivesBool_antitone (eval : ι → α → Bool) (i : ι)
    {T₁ T₂ : Finset α} (hsub : T₁ ⊆ T₂) :
    survivesBool eval i T₂ → survivesBool eval i T₁ :=
  fun h a ha => h a (hsub ha)

/-! ### Monotonicity of killedBy -/

omit [DecidableEq α] [DecidableEq ι] in
/-- Larger test sets kill at least as many hypotheses. -/
theorem killedBy_mono (eval : ι → α → Bool) (H : Finset ι)
    {T₁ T₂ : Finset α} (hsub : T₁ ⊆ T₂) :
    killedBy eval H T₁ ⊆ killedBy eval H T₂ := by
  intro i hi
  simp [killedBy] at hi ⊢
  obtain ⟨hH, a, ha₁, ha₂⟩ := hi
  exact ⟨hH, a, hsub ha₁, ha₂⟩

/-! ### The main counting theorem -/

omit [DecidableEq α] [DecidableEq ι] in
/-- **Counting monotonicity**: enlarging the stress test can only decrease
    (or maintain) the count of surviving false hypotheses.

    This is the central theorem: every additional test point reduces the
    false-positive burden of the hypothesis class. -/
theorem falsePositiveCount_antitone (eval : ι → α → Bool)
    (H : Finset ι) {T₁ T₂ U : Finset α}
    (hsub : T₁ ⊆ T₂) :
    falsePositiveCount eval H U T₂ ≤ falsePositiveCount eval H U T₁ := by
  unfold falsePositiveCount
  apply Finset.card_le_card
  intro h hh
  simp_all +decide
  exact fun a ha => hh.2.2 a (hsub ha)

/-! ### Kills imply false-positive reduction (when all hypotheses are false) -/

omit [DecidableEq α] [DecidableEq ι] in
/-- If every hypothesis in `H` is false on `U`, then enlarging the killed set
    cannot increase the false-positive count. -/
theorem falsePositiveCount_decreases_by_kills (eval : ι → α → Bool)
    (H : Finset ι) {U T₁ T₂ : Finset α}
    (_hallfalse : ∀ i ∈ H, isFalseProp eval i U)
    (hkills : killedBy eval H T₁ ⊆ killedBy eval H T₂) :
    falsePositiveCount eval H U T₂ ≤ falsePositiveCount eval H U T₁ := by
  refine Finset.card_mono ?_
  simp_all +decide [Finset.subset_iff, killedBy]
  grind

/-! ## Part 3: Concrete example on `Fin n`

We demonstrate the framework with a simple conjecture family over `Fin 10`,
where hypothesis `i` claims that `(i + a) % 2 = 0` for all test points `a`. -/

/-- Example: test whether `(i + a) % 2 = 0`, over `Fin 10`. -/
def exampleEval : Fin 10 → Fin 10 → Bool :=
  fun i a => (i.val + a.val) % 2 == 0

/-- The full universe of `Fin 10`. -/
def fullUniverse : Finset (Fin 10) := Finset.univ

/-- A small test set: `{0, 1}`. -/
def smallTest : Finset (Fin 10) := {0, 1}

/-- A larger test set: `{0, 1, 2, 3}`, containing the small one. -/
def largeTest : Finset (Fin 10) := {0, 1, 2, 3}

/-- The small test set is indeed a subset of the large test set. -/
example : smallTest ⊆ largeTest := by decide

/-- The false-positive count cannot increase when we enlarge the test set.
    This is an instantiation of `falsePositiveCount_antitone`. -/
example : falsePositiveCount exampleEval Finset.univ fullUniverse largeTest ≤
          falsePositiveCount exampleEval Finset.univ fullUniverse smallTest :=
  falsePositiveCount_antitone exampleEval Finset.univ (by decide)

end AetherQC