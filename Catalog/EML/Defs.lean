/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Coherent Closure Self-Models: Definitions

This file defines the abstract framework of **coherent closure self-models**,
which package a formal system with:

1. **Self-referential capability** via a diagonal (Gödel–Lawvere) fixed-point schema
2. **Provability internalization** (necessitation / Hilbert–Bernays–Löb condition)
3. **Soundness for internalized propositions** (Σ₁-soundness)
4. **Thermodynamic structure**: free energy, complexity floor, and a fundamental
   lower bound axiom asserting that self-compression below the floor is
   semantically impossible.

## Mathematical context

These axioms abstract the essential properties of sufficiently strong arithmetical
theories (like Peano Arithmetic) enriched with thermodynamic semantics from the
Lawvere–Stone prime spectrum. The diagonal lemma is the syntactic engine
(Gödel 1931, Lawvere 1969), while the free-energy lower bound is the new
thermodynamic content connecting proof theory to statistical mechanics.

## References

* Gödel, K. — Über formal unentscheidbare Sätze (1931)
* Lawvere, F.W. — Diagonal arguments and cartesian closed categories (1969)
-/

import Mathlib

universe u

/-! ## The Coherent Closure Self-Model Typeclass -/

/-- A **coherent closure self-model** is an abstract formal system equipped with
self-referential capability, provability internalization, soundness for
internalized propositions, and thermodynamic structure.

The key axioms are:
- `ax_diagonal`: Gödel–Lawvere diagonal fixed-point schema
- `ax_necessitation`: Hilbert–Bernays derivability condition D1
- `ax_internalize_sound`: Σ₁-soundness for the internalization fragment
- `ax_freeEnergy_ge_floor`: thermodynamic lower bound on free energy -/
class CoherentClosureSelfModel (M : Type u) where
  /-- The type of sentences in the formal language -/
  Sentence : Type u
  /-- The type of Gödel codes -/
  Code : Type u
  /-- External derivability predicate -/
  proves : Sentence → Prop
  /-- Internal provability predicate (a sentence asserting provability) -/
  provSent : Sentence → Sentence
  /-- Sentence-level negation -/
  negSent : Sentence → Sentence
  /-- Sentence-level biconditional -/
  iffSent : Sentence → Sentence → Sentence
  /-- Internalization: convert an external Lean proposition into an internal sentence -/
  internalize : Prop → Sentence
  /-- The self-code (Gödel number) of a sentence -/
  selfCode : Sentence → Code
  /-- Free energy at inverse temperature β for a code -/
  freeEnergy : ℝ → Code → ℝ
  /-- Complexity floor at inverse temperature β for a sentence -/
  complexityFloor : ℝ → Sentence → ℝ
  -- === Logical Axioms ===
  /-- **Diagonal lemma (Gödel–Lawvere).**
  For any definable operation `Ψ` on sentences, there exists a diagonal
  fixed-point sentence `G` satisfying `G ↔ ¬Prov(Ψ(G))`.

  This is the syntactic engine of self-reference, abstracting the construction
  of Gödel sentences for arbitrary predicates. -/
  ax_diagonal : ∀ (Ψ : Sentence → Sentence),
    ∃ G, proves (iffSent G (negSent (provSent (Ψ G))))
  /-- **Necessitation (Hilbert–Bernays D1).**
  If `φ` is provable, then "φ is provable" is itself provable.
  This is the first Hilbert–Bernays derivability condition. -/
  ax_necessitation : ∀ {φ : Sentence}, proves φ → proves (provSent φ)
  /-- **Soundness for internalized propositions.**
  If M proves the internalization of an external proposition P,
  then P actually holds. This is a restricted form of Σ₁-soundness. -/
  ax_internalize_sound : ∀ {P : Prop}, proves (internalize P) → P
  /-- **Consistency of negation.**
  M does not prove both a sentence and its negation. -/
  ax_neg_consistent : ∀ {φ : Sentence}, proves φ → proves (negSent φ) → False
  /-- **Modus ponens for biconditional (forward).**
  From `proves (φ ↔ ψ)` and `proves φ`, derive `proves ψ`. -/
  ax_iff_mp : ∀ {φ ψ : Sentence}, proves (iffSent φ ψ) → proves φ → proves ψ
  /-- **Modus ponens for biconditional (backward).**
  From `proves (φ ↔ ψ)` and `proves ψ`, derive `proves φ`. -/
  ax_iff_mpr : ∀ {φ ψ : Sentence}, proves (iffSent φ ψ) → proves ψ → proves φ
  /-- **Introduction of negation from refutation.**
  If assuming `proves φ` leads to contradiction, then `proves (negSent φ)`. -/
  ax_neg_intro : ∀ {φ : Sentence}, (proves φ → False) → proves (negSent φ)
  -- === Thermodynamic Axioms ===
  /-- **Free-energy lower bound.**
  The free energy of any sentence's self-code is bounded below by the
  complexity floor. This is the fundamental thermodynamic content:
  self-compression below the floor is semantically impossible.

  Conceptually, this says that any encoding of a self-referential sentence
  must pay a minimum thermodynamic cost determined by the complexity floor. -/
  ax_freeEnergy_ge_floor : ∀ (β : ℝ) (G : Sentence),
    0 < β → complexityFloor β G ≤ freeEnergy β (selfCode G)
  /-- **Complexity floor nonnegativity.** -/
  ax_complexityFloor_nonneg : ∀ (β : ℝ) (G : Sentence),
    0 < β → 0 ≤ complexityFloor β G
  /-- **Complexity floor nontriviality.**
  The floor is genuinely nonzero for some sentence, ensuring the theorem
  is not vacuously about a degenerate system. -/
  ax_complexityFloor_nontrivial : ∀ (β : ℝ),
    0 < β → ∃ G : Sentence, 0 < complexityFloor β G

namespace CoherentClosureSelfModel

variable {M : Type u} [CoherentClosureSelfModel M]

/-! ## Public API and Derived Notions -/

/-- The compression predicate: `CompressesAt β G` holds when the free energy
of `G`'s self-code is strictly below the complexity floor. This is the
"self-compression" condition that the main theorem shows is unprovable. -/
def CompressesAt (beta : ℝ) (G : Sentence (M := M)) : Prop :=
  freeEnergy beta (selfCode G) < complexityFloor beta G

/-- The internalized compression sentence: the sentence asserting (internally
to M) that `G` achieves strict sub-floor compression at temperature `1/β`. -/
def CompressesAtSent (beta : ℝ) (G : Sentence (M := M)) : Sentence (M := M) :=
  internalize (CompressesAt beta G)

end CoherentClosureSelfModel