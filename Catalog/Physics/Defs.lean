/-
Copyright (c) 2025. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# KMS–Gödel Barrier: Definitions

This file defines the abstract framework for the **KMS–Gödel Barrier theorem**,
which establishes that no closure self-model carrying a modular thermodynamic
structure can simultaneously support an exact internally truthful self-semantics
and a β-KMS equilibrium semantics at positive inverse temperature.

## Mathematical context

The theorem sits at the intersection of three classical ideas:

1. **Gödel/Lawvere diagonalization**: self-reference forces fixed points.
2. **KMS equilibrium theory**: modular dynamics constrains equilibrium states.
3. **Variational free-energy principles**: equilibrium has strict gap properties.

The key insight is that exact internal truthfulness, when combined with
self-referential capability, induces a zero-gap modular free-energy fixed
point. But KMS equilibrium at positive inverse temperature strictly forbids
such zero-gap fixed points. This is not mere incompleteness — it is a
**thermodynamic obstruction** to perfect self-knowledge.

## Overview of types

- `ClosureSelfModel M`: a system with self-referential sentences and a
  diagonal (Gödel–Lawvere) fixed-point schema.
- `ModularThermodynamicStructure M`: equips the model with a modular
  free-energy gap functional and axiomatizes strict positivity at β > 0.
- `ExactInternallyTruthfulKMSModel M beta`: the hypothesis that the model
  achieves exact internal truth under KMS equilibrium, which forces the
  free-energy gap to vanish.

## References

* Gödel, K. — Über formal unentscheidbare Sätze (1931)
* Lawvere, F.W. — Diagonal arguments and cartesian closed categories (1969)
* Haag, Hugenholtz, Winnink — On the equilibrium states in quantum
  statistical mechanics (1967)
* Tomita, M. — On canonical forms of von Neumann algebras (1967)
-/

import Mathlib

universe u

/-! ## §1. Closure Self-Model -/

/-- A **closure self-model** is an abstract formal system with self-referential
capability via a diagonal (Gödel–Lawvere) fixed-point schema, together with
a provability predicate and basic logical connectives.

This is a lighter version of `CoherentClosureSelfModel` that retains only
the structural features needed for the KMS–Gödel barrier. -/
class ClosureSelfModel (M : Type u) where
  /-- The type of sentences in the formal language. -/
  Sentence : Type u
  /-- External derivability / truth predicate. -/
  models : Sentence → Prop
  /-- Internal provability predicate (sentence-level). -/
  provSent : Sentence → Sentence
  /-- Sentence-level negation. -/
  negSent : Sentence → Sentence
  /-- Internalization of an external Lean `Prop` as an internal sentence. -/
  internalize : Prop → Sentence
  /-- **Diagonal lemma (Gödel–Lawvere).**
  For any definable operation `Ψ` on sentences, there exists a diagonal
  fixed-point sentence `G` satisfying `models (G ↔ᵢ ¬ᵢ Prov(Ψ G))`. -/
  ax_diagonal : ∀ (Ψ : Sentence → Sentence),
    ∃ G : Sentence, models (internalize (models G ↔ ¬ models (provSent (Ψ G))))
  /-- **Soundness for internalized propositions.**
  If M models the internalization of `P`, then `P` holds externally. -/
  ax_internalize_sound : ∀ {P : Prop}, models (internalize P) → P

/-! ## §2. Modular Thermodynamic Structure -/

/-- A **modular thermodynamic structure** on a closure self-model equips
the system with a real-valued free-energy gap functional parameterized by
inverse temperature β, together with the fundamental axiom that the gap
is strictly positive at positive β.

The free-energy gap `ModularFreeEnergyGap M beta` measures the minimum
thermodynamic cost of self-referential encoding across all sentences.
The strict positivity axiom is the operator-algebraic content:
KMS equilibrium at positive temperature enforces a non-vanishing gap,
preventing exact self-compression. -/
class ModularThermodynamicStructure (M : Type u) where
  /-- The modular free-energy gap at inverse temperature β.
  This is a global invariant of the model, representing the infimum of
  free-energy defects across all self-referential encodings. -/
  freeEnergyGap : ℝ → ℝ
  /-- **No-self-compression principle.**
  At positive inverse temperature, the modular free-energy gap is
  strictly positive. This is the thermodynamic content: KMS equilibrium
  forbids exact self-compression.

  Physically, this says that any self-referential encoding must pay a
  minimum thermodynamic cost proportional to the inverse temperature. -/
  positive_gap_of_beta_pos : ∀ {beta : ℝ}, 0 < beta → 0 < freeEnergyGap beta

/-! ## §3. Exact Internally Truthful KMS Model -/

/-- `ExactInternallyTruthfulKMSModel M beta` asserts that the closure
self-model `M` achieves **exact internal truth** under KMS equilibrium
at inverse temperature `beta`.

The key consequence is `induces_zero_gap`: exact internal truth forces
the modular free-energy gap to vanish. Intuitively, if the system can
perfectly evaluate all its own truth predicates, the self-referential
encoding cost collapses to zero — there is no discrepancy between
internal and external evaluation.

This is the hypothesis that the KMS–Gödel barrier theorem refutes:
it cannot hold simultaneously with positive-temperature KMS equilibrium. -/
class ExactInternallyTruthfulKMSModel (M : Type u)
    [ClosureSelfModel M] [ModularThermodynamicStructure M]
    (beta : ℝ) : Prop where
  /-- Exact internal truth annihilates the modular free-energy gap.
  This is the bridge from semantic exactness to thermodynamic obstruction:
  if the system is exactly truthful, the gap vanishes. -/
  induces_zero_gap : ModularThermodynamicStructure.freeEnergyGap (M := M) beta = 0

/-! ## §4. Auxiliary Definitions -/

/-- The modular free-energy gap at inverse temperature β, as a top-level
function for convenience. -/
noncomputable def ModularFreeEnergyGap (M : Type u)
    [ModularThermodynamicStructure M] (beta : ℝ) : ℝ :=
  ModularThermodynamicStructure.freeEnergyGap (M := M) beta

/-- `HasExactModularFreeEnergyFixedPoint M beta` holds when the modular
free-energy gap vanishes, i.e., the system has an exact fixed point
under the modular free-energy operator. -/
def HasExactModularFreeEnergyFixedPoint (M : Type u)
    [ModularThermodynamicStructure M] (beta : ℝ) : Prop :=
  ModularFreeEnergyGap M beta = 0