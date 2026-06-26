/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Cryptography.NaturalProofs.Core

/-!
# Concrete non-vacuity witnesses for the natural proofs barrier

The barrier theorems in `Core` are only meaningful if their hypotheses
(largeness + usefulness, or pseudorandomness + largeness) are *satisfiable*.
This file pins down a fully explicit, computable witness so that none of the
abstract results are vacuous.

We use the property `nonConstFalse f := f ≠ (fun _ => false)` — "the truth table
is not identically false" — against the *constant generator* `G ≡ allFalse`,
which models a (degenerate but legitimate) family of easy functions that always
computes the zero function.

* `nonConstFalse` is **large**: its density is strictly positive for `m ≥ 1`.
* It is **useful** against the constant generator: `allFalse` is identically
  false, so it fails the test.
* Hence `natural_property_distinguishes` yields a *strictly positive* advantage,
  exhibiting a genuine, non-vacuous distinguisher.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The simplest non-trivial test "table is not all-false"
already separates the all-false generator from uniform with advantage equal to
its density. Conjecture: positivity of the density for `m ≥ 1` is enough; no
exact count is needed for non-vacuity.

Experiment (Experimenter): Show the filter `{f | f ≠ allFalse}` is nonempty for
`m ≥ 1` (the all-true table differs from the all-false table at index `⟨0,·⟩`),
hence the density is `> 0`; combine with usefulness via the Core forward lemma.

Analysis (Analyst): Non-vacuity confirmed — `advantage_witness` produces an
explicit `δ > 0` bounding the advantage from below, so the abstract barrier has
content. The only ingredient is `card ≥ 1 ⇒ density > 0`.

Critique (Critic): For `m = 0` the table space is a singleton (the empty table),
which *is* all-false, so the test is empty and the density is `0`; the hypothesis
`1 ≤ m` is therefore load-bearing and correctly stated.

Synthesis (PI): A one-line property already realizes the Razborov–Rudich
distinguisher schema, anchoring the abstract development in a concrete instance.
-/

open Finset

namespace NaturalProofs
namespace Examples

variable {m : ℕ}

/-- The identically-false truth table. -/
def allFalse (m : ℕ) : Tbl m := fun _ => false

/-- The test "the truth table is not identically false". -/
def nonConstFalse (m : ℕ) : Tbl m → Prop := fun f => f ≠ allFalse m

instance : DecidablePred (nonConstFalse m) := by
  unfold nonConstFalse; infer_instance

/-- For `m ≥ 1` the "not all-false" test has strictly positive density: a
non-negligible (in fact majority) fraction of truth tables satisfy it. -/
theorem density_nonconstant_pos (hm : 1 ≤ m) :
    0 < accRandom (nonConstFalse m) := by
  unfold accRandom
  apply div_pos
  · rw [Nat.cast_pos, Finset.card_pos]
    refine ⟨fun _ => true, ?_⟩
    rw [Finset.mem_filter]
    refine ⟨Finset.mem_univ _, ?_⟩
    unfold nonConstFalse
    intro h
    have hi := congrFun h ⟨0, by omega⟩
    simp [allFalse] at hi
  · rw [Nat.cast_pos]
    exact Fintype.card_pos

/-- The constant generator outputting `allFalse` fails the "not all-false" test,
so the test is useful against it. -/
theorem useful_const :
    ∀ _ : Fin 1, ¬ nonConstFalse m (allFalse m) := by
  intro _
  unfold nonConstFalse
  simp

/-- **Non-vacuous distinguisher witness.**
For `m ≥ 1` there is a strictly positive `δ` such that the "not all-false" test
distinguishes the constant all-false generator from uniform with advantage at
least `δ`. This instantiates `natural_property_distinguishes` concretely. -/
theorem advantage_witness (hm : 1 ≤ m) :
    ∃ δ : ℚ, 0 < δ ∧
      δ ≤ accRandom (nonConstFalse m)
            - accGen (fun _ : Fin 1 => allFalse m) (nonConstFalse m) := by
  refine ⟨accRandom (nonConstFalse m), density_nonconstant_pos hm, ?_⟩
  exact natural_property_distinguishes (le_refl _) useful_const

end Examples
end NaturalProofs