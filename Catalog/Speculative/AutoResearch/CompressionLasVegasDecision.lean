/-
Copyright (c) 2025. All rights reserved.

# Las Vegas *decision* oracles for compressibility and the one-way boundary

## Overview

`Catalog/Novelty/CompressionLasVegasOWF.lean` showed that a one-way function
defeats every Las Vegas *search* algorithm (finitely many seeds) totally: some
value in the range is missed by all seeds at once.  Compression search, however,
is only one of the tasks in the compression ⇋ cryptography dictionary.  The
*decision* task — "does `y` have a `D`-program of length `n` extending the prefix
`w`?" — carries no verifiable certificate, so at first sight randomizing it might
be cheaper.

This file shows it is not.  The chain is:

1. `decisionToFinder_correct_at` : the bit-by-bit reconstruction of
   `Speculative.AutoResearch.CompressionSearchToDecision` needs the decision
   oracle to be correct **only at the one string being compressed** (proved by
   globalizing a locally correct oracle with a classical one, `globalize`);
2. `las_vegas_decider_inverts` : if, for every value in the range of `f`, *some*
   seed of a finite list carries a locally correct oracle, then a deterministic
   algorithm inverts `f` — the reconstruction produces a program, and the program
   is verifiable even though the oracle's answers are not;
3. `owf_defeats_las_vegas_decider` : consequently, under a one-way function there
   is a describable `y` at which **every** seeded decision oracle is wrong.
   Randomized *decision* of compressibility is blocked exactly like randomized
   search.

Finally `canonical_decision_finder` records that the obstruction is purely
computational: the classical (noncomputable) oracle is correct and does solve
compression search, so nothing information-theoretic stands in the way.

All results are proved from scratch; there are no axioms and no `sorry`.
-/
import Mathlib
import Speculative.AutoResearch.CompressionOneWayFunctions
import Speculative.AutoResearch.CompressionSearchToDecision
import Novelty.CompressionLasVegasOWF

namespace CompressionLasVegasDecision

open CompressionOWF CompressionLasVegas
open scoped Classical

/-! ## Section 1: local correctness suffices for reconstruction -/

/-- A decision oracle is *locally correct at `y`* if it answers the prefix
compressibility questions about `y` correctly (its answers about other strings
are unconstrained). -/
def LocallyCorrectAt (D : Str → Str) (dec : Str → Str → ℕ → Bool) (y : Str) : Prop :=
  ∀ w n, dec y w n = true ↔ ∃ p : Str, p.length = n ∧ D (w ++ p) = y

/-- Replace the answers of `dec` about strings other than `y₀` by the (classical)
correct answers.  This is a purely mathematical device: it turns a locally
correct oracle into a globally correct one without touching the queries that the
reconstruction at `y₀` actually makes. -/
noncomputable def globalize (D : Str → Str) (dec : Str → Str → ℕ → Bool) (y₀ : Str) :
    Str → Str → ℕ → Bool :=
  fun y w n => if y = y₀ then dec y w n else decide (∃ p : Str, p.length = n ∧ D (w ++ p) = y)

lemma globalize_at (D : Str → Str) (dec : Str → Str → ℕ → Bool) (y₀ : Str) :
    globalize D dec y₀ y₀ = dec y₀ := by
  funext w n
  simp [globalize]

lemma globalize_correct (D : Str → Str) (dec : Str → Str → ℕ → Bool) (y₀ : Str)
    (h : LocallyCorrectAt D dec y₀) :
    ∀ y w n, globalize D dec y₀ y w n = true ↔ ∃ p : Str, p.length = n ∧ D (w ++ p) = y := by
  intro y w n
  by_cases hy : y = y₀
  · subst hy
    simpa [globalize] using h w n
  · simp [globalize, hy]

/-- **Local correctness suffices.**  The search-to-decision reconstruction
`decisionToFinder` returns a shortest program for `y` as soon as the oracle is
correct at `y` alone.  (The catalog version assumes a globally correct oracle.) -/
theorem decisionToFinder_correct_at (D : Str → Str) (dec : Str → Str → ℕ → Bool)
    (fuel : ℕ → ℕ) (y : Str) (h : LocallyCorrectAt D dec y)
    (hy : Describable D y) (hfuel : K D y ≤ fuel y.length) :
    D (decisionToFinder dec fuel y) = y ∧ (decisionToFinder dec fuel y).length = K D y := by
  classical
  have hglob := decisionToFinder_correct D (globalize D dec y) fuel
    (globalize_correct D dec y h) y hy hfuel
  have heq : decisionToFinder (globalize D dec y) fuel y = decisionToFinder dec fuel y := by
    show rebuild (globalize D dec y y) _ [] = rebuild (dec y) _ []
    rw [globalize_at]
  rwa [heq] at hglob

/-! ## Section 2: Las Vegas decision oracles still invert -/

/-- The deterministic algorithm assembled from a seeded family of decision
oracles: reconstruct a program from each seed's oracle, then keep the first
reconstruction that verifies. -/
noncomputable def decisionTryList (f : Str → Str) (dec : Str → Str → Str → ℕ → Bool)
    (fuel : ℕ → ℕ) (R : List Str) : Str → Str :=
  tryList f (fun r => decisionToFinder (dec r) fuel) R

/-- **Las Vegas decision oracles derandomize into an inverter.**  If for every
value in the range of `f` at least one seed of the finite list carries a locally
correct decision oracle, then `decisionTryList` inverts `f` deterministically.

The point is that the oracle's answers need not be checkable — only the
*reconstructed program* is, and that is enough. -/
theorem las_vegas_decider_inverts (f : Str → Str) (dec : Str → Str → Str → ℕ → Bool)
    (fuel : ℕ → ℕ) (R : List Str)
    (hfuel : ∀ y : Str, Describable f y → K f y ≤ fuel y.length)
    (hgood : ∀ y : Str, Describable f y → ∃ r ∈ R, LocallyCorrectAt f (dec r) y) :
    Inverts f (decisionTryList f dec fuel R) := by
  refine tryList_inverts f (fun r => decisionToFinder (dec r) fuel) R ?_
  intro y hy
  obtain ⟨r, hrR, hr⟩ := hgood y hy
  exact ⟨r, hrR, (decisionToFinder_correct_at f (dec r) fuel y hr hy (hfuel y hy)).1⟩

/-- **One-way functions defeat Las Vegas decision oracles totally.**  For a
one-way `f` and any finite seed list, there is a value in the range of `f` at
which *every* seeded decision oracle gives a wrong answer to some prefix query.

Randomizing the decision version of compressibility therefore buys nothing: it
hits the same cryptographic wall as randomized compression search. -/
theorem owf_defeats_las_vegas_decider (C : LasVegasClass) (f : Str → Str)
    (hf : OneWayIn C.toSearchClosedClass f) (dec : Str → Str → Str → ℕ → Bool)
    (fuel : ℕ → ℕ) (hfuel : ∀ y : Str, Describable f y → K f y ≤ fuel y.length)
    (hmem : ∀ r : Str, decisionToFinder (dec r) fuel ∈ C.Comp) (R : List Str) :
    ∃ y : Str, Describable f y ∧ ∀ r ∈ R, ¬ LocallyCorrectAt f (dec r) y := by
  obtain ⟨y, hy, hbad⟩ :=
    owf_defeats_las_vegas C f hf (fun r => decisionToFinder (dec r) fuel) hmem R
  refine ⟨y, hy, fun r hrR hr => ?_⟩
  exact hbad r hrR (decisionToFinder_correct_at f (dec r) fuel y hr hy (hfuel y hy)).1

/-- The Las Vegas decision task is at least as hard as the Las Vegas search task:
locally correct oracles yield a seeded shortest-program finder. -/
theorem las_vegas_decider_gives_seeded_finder (D : Str → Str)
    (dec : Str → Str → Str → ℕ → Bool) (fuel : ℕ → ℕ) (R : List Str)
    (hfuel : ∀ y : Str, Describable D y → K D y ≤ fuel y.length)
    (hgood : ∀ y : Str, Describable D y → ∃ r ∈ R, LocallyCorrectAt D (dec r) y) :
    SeededShortestFinder D (fun r => decisionToFinder (dec r) fuel) R := by
  intro y hy
  obtain ⟨r, hrR, hr⟩ := hgood y hy
  obtain ⟨h1, h2⟩ := decisionToFinder_correct_at D (dec r) fuel y hr hy (hfuel y hy)
  exact ⟨r, hrR, h1, h2⟩

/-! ## Section 3: the obstruction is computational, not informational -/

/-- The classical (noncomputable) decision oracle for `D`. -/
noncomputable def canonicalDec (D : Str → Str) : Str → Str → ℕ → Bool :=
  fun y w n => decide (∃ p : Str, p.length = n ∧ D (w ++ p) = y)

lemma canonicalDec_correct (D : Str → Str) :
    ∀ y w n, canonicalDec D y w n = true ↔ ∃ p : Str, p.length = n ∧ D (w ++ p) = y := by
  intro y w n
  simp [canonicalDec]

/-- **No information-theoretic obstruction.**  With the classical oracle the
search-to-decision machinery really does produce shortest programs for every
describable string.  Hence everything proved above about the failure of Las Vegas
deciders is a statement about *computation*, not about information: the oracle
exists, it is just not in the class. -/
theorem canonical_decision_finder (D : Str → Str) (fuel : ℕ → ℕ)
    (hfuel : ∀ y : Str, Describable D y → K D y ≤ fuel y.length) :
    ShortestFinder D (decisionToFinder (canonicalDec D) fuel) := by
  classical
  intro y hy
  exact decisionToFinder_correct D (canonicalDec D) fuel (canonicalDec_correct D) y hy (hfuel y hy)

/-- **Summary of the dictionary.**  For a one-way function `f` in a Las Vegas
class, with an honest fuel bound, *all four* randomized compression tasks fail
totally on some describable input, while the classical oracle solves the same
task perfectly:

1. Las Vegas inversion;
2. Las Vegas exact compression search;
3. Las Vegas approximate compression search (any slack `g`);
4. Las Vegas prefix-decision of compressibility;

and yet `decisionToFinder (canonicalDec f)` is an exact shortest-program finder.
The barrier is exactly the cryptographic assumption. -/
theorem las_vegas_dictionary (C : LasVegasClass) (f : Str → Str)
    (hf : OneWayIn C.toSearchClosedClass f) (fuel : ℕ → ℕ)
    (hfuel : ∀ y : Str, Describable f y → K f y ≤ fuel y.length)
    (A : Str → Str → Str) (hA : ∀ r : Str, A r ∈ C.Comp) (R : List Str) (g : ℕ → ℕ)
    (dec : Str → Str → Str → ℕ → Bool)
    (hmem : ∀ r : Str, decisionToFinder (dec r) fuel ∈ C.Comp) :
    (∃ y : Str, Describable f y ∧ ∀ r ∈ R, f (A r y) ≠ y)
    ∧ ¬ SeededShortestFinder f A R
    ∧ ¬ SeededApproxFinder f A R g
    ∧ (∃ y : Str, Describable f y ∧ ∀ r ∈ R, ¬ LocallyCorrectAt f (dec r) y)
    ∧ ShortestFinder f (decisionToFinder (canonicalDec f) fuel) :=
  ⟨owf_defeats_las_vegas C f hf A hA R,
   owf_defeats_las_vegas_compression C f hf A hA R,
   owf_defeats_las_vegas_approx C f hf A hA R g,
   owf_defeats_las_vegas_decider C f hf dec fuel hfuel hmem R,
   canonical_decision_finder f fuel hfuel⟩

end CompressionLasVegasDecision