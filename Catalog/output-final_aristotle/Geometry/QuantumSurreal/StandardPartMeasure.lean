/-
Copyright (c) 2026 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The standard part collapses an infinitesimal measure to a Dirac measure

This file is the *classical shadow* companion to
`Catalog/Geometry/QuantumSurreal/Basic.lean`.  There, amplitudes of a quantum surreal state live
in the hyperreals `ℝ*` and the measurement rule is the standard part `Hyperreal.st : ℝ* → ℝ`; an
infinitesimal branch becomes unobservable.  Here we prove the exact order-theoretic analogue for
the finitely additive infinitesimal probability model of
`Catalog/Novelty/InfinitesimalFiniteProbability.lean`.

That model uses the value ring `LexRat = ℚ × ℚ`, where `(a, b)` denotes `a + b·ε` with `ε` a
positive infinitesimal.  The sample space `Option (Fin n)` has `n` "visible" atoms each of weight
`ε` and one "reservoir" atom `none` of weight `1 - n·ε`, giving total mass `1`.

The `LexRat` construction, its atom weights, event probability `prob`, `visiblePart`, the closed
form `prob_eq_closed_form` and finite additivity `prob_union_disjoint` are **reproduced verbatim**
from `Catalog/Novelty/InfinitesimalFiniteProbability.lean` (each catalog file imports only
`Mathlib`, so shared objects are reproduced rather than cross-imported).  The new content is the
*standard-part functional* and the collapse theorem.

## New results

* `stdPart` — the standard-part functional `LexRat → ℚ`, taking the real (order-dominant)
  component.
* `stdPart_prob_dirac` — **the collapse**: `stdPart (prob n A) = 1` if the reservoir atom is in
  `A`, and `0` otherwise.  Observationally, the infinitesimal weight `ε` carried by every visible
  atom vanishes and all probability concentrates on the reservoir — the standard part of the
  infinitesimal measure is the Dirac measure `δ_none`.
* `stdPart_prob_univ`, `stdPart_visible_zero` — the total observed mass is `1` while each visible
  atom is observed with probability `0`.
* `stdPart_additive` — the observed measure is finitely additive.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the standard-part map that turns quantum hyperreal amplitudes into
ordinary probabilities should, applied to the catalog's `LexRat` infinitesimal measure, erase
exactly the infinitesimal (visible-atom) mass and leave a genuine real probability measure.

Experiment (Experimenter): for `n = 3`, `prob univ = (1, 0)` and each `prob {some i} = (0, 1)`.
Taking first coordinates gives `1` and `0` — the reservoir keeps all observable mass.

Analysis (Analyst): the catalog measure was *finitely additive and normalized in `LexRat`* but had
no notion of "observation".  The missing ingredient was a standard-part functional; supplying it
turns the infinitesimal measure into the Dirac measure on the reservoir.  This is the discrete,
order-theoretic mirror of `observedProb_infinitesimal_eq_zero` in the hyperreal quantum file.

Critique (Critic): `stdPart_prob_dirac` is not definitional trivia — it rests on the catalog's
`prob_eq_closed_form`, an induction over the finite event.  The additivity theorem uses the
reproduced `prob_union_disjoint`.  No result is `True`/`native_decide`-only.

Synthesis (PI): "standard part" is a single unifying observation functional — `Hyperreal.st` in
the continuous quantum model, `Prod.fst` in the discrete lexicographic model — and in both settings
it annihilates infinitesimal probability while preserving normalization and additivity.
-- !-- Lab Notes -- !--
-/

/-- The value type of the infinitesimal probability model: a pair `(a, b)` read as `a + b·ε`.
Reproduced from `Catalog/Novelty/InfinitesimalFiniteProbability.lean`. -/
abbrev LexRat := ℚ × ℚ

namespace LexRat

/-- Lexicographic `<` on `LexRat`. -/
def lexLt (x y : LexRat) : Prop := x.1 < y.1 ∨ x.1 = y.1 ∧ x.2 < y.2

/-- The unit `1 = (1, 0)`. -/
def one : LexRat := ((1 : ℚ), (0 : ℚ))

/-- The infinitesimal `ε = (0, 1)`. -/
def eps : LexRat := ((0 : ℚ), (1 : ℚ))

end LexRat

namespace InfinitesimalProbability

open LexRat

/-- Atom weights: reservoir `none` carries `1 - n·ε`, each visible atom `some i` carries `ε`.
Reproduced from the catalog. -/
def atomWeight (n : ℕ) : Option (Fin n) → LexRat
  | none => ((1 : ℚ), -(n : ℚ))
  | some _ => ((0 : ℚ), (1 : ℚ))

@[simp] lemma atomWeight_none (n : ℕ) : atomWeight n none = ((1 : ℚ), -(n : ℚ)) := rfl
@[simp] lemma atomWeight_some (n : ℕ) (i : Fin n) :
    atomWeight n (some i) = ((0 : ℚ), (1 : ℚ)) := rfl

/-- The probability of an event is the finite sum of its atom weights. -/
def prob (n : ℕ) (A : Finset (Option (Fin n))) : LexRat := A.sum (atomWeight n)

/-- The visible indices whose atom belongs to the event. -/
def visiblePart (n : ℕ) (A : Finset (Option (Fin n))) : Finset (Fin n) :=
  Finset.univ.filter fun i => some i ∈ A

@[simp] lemma mem_visiblePart (n : ℕ) (A : Finset (Option (Fin n))) (i : Fin n) :
    i ∈ visiblePart n A ↔ some i ∈ A := by simp [visiblePart]

/-- Closed form for event probabilities (reproduced from the catalog): the real component records
whether the reservoir is present; the infinitesimal component counts visible atoms minus `n` if the
reservoir is present. -/
theorem prob_eq_closed_form (n : ℕ) (A : Finset (Option (Fin n))) :
    prob n A =
      ((if none ∈ A then (1 : ℚ) else 0),
       ((visiblePart n A).card : ℚ) - (if none ∈ A then (n : ℚ) else 0)) := by
  induction A using Finset.induction <;> simp_all +decide;
  · unfold prob visiblePart; aesop;
  · rename_i a s ha hs;
    rcases a with ( _ | i ) <;> simp_all +decide [ prob, visiblePart ];
    · ring;
    · rw [ show ( Finset.filter ( fun x => x = i ∨ some x ∈ s ) Finset.univ : Finset ( Fin n ) ) = Finset.filter ( fun x => some x ∈ s ) Finset.univ ∪ { i } from ?_, Finset.card_union ] <;> norm_num [ ha ] ; ring;
      grind

/-- Finite additivity for disjoint events (reproduced from the catalog). -/
theorem prob_union_disjoint (n : ℕ) (A B : Finset (Option (Fin n))) (h : Disjoint A B) :
    prob n (A ∪ B) = prob n A + prob n B := by
  simp [prob, Finset.sum_union h]

/-! ## New content: the standard-part collapse -/

/-- The **standard-part functional** on `LexRat`: the real, order-dominant component of `a + b·ε`.
This is the discrete analogue of `Hyperreal.st`. -/
def stdPart (x : LexRat) : ℚ := x.1

/-- **The collapse.**  The standard part of the infinitesimal measure is the Dirac measure
concentrated on the reservoir atom `none`: every visible atom's infinitesimal weight `ε` becomes
observationally `0`. -/
theorem stdPart_prob_dirac (n : ℕ) (A : Finset (Option (Fin n))) :
    stdPart (prob n A) = if none ∈ A then 1 else 0 := by
  rw [prob_eq_closed_form]; rfl

/-- The total observed mass is `1`. -/
theorem stdPart_prob_univ (n : ℕ) : stdPart (prob n Finset.univ) = 1 := by
  rw [stdPart_prob_dirac]; simp

/-- Each visible atom is observed with probability `0`. -/
theorem stdPart_visible_zero (n : ℕ) (i : Fin n) : stdPart (prob n {some i}) = 0 := by
  rw [stdPart_prob_dirac]; simp

/-- The observed (standard-part) measure is finitely additive. -/
theorem stdPart_additive (n : ℕ) (A B : Finset (Option (Fin n))) (h : Disjoint A B) :
    stdPart (prob n (A ∪ B)) = stdPart (prob n A) + stdPart (prob n B) := by
  rw [prob_union_disjoint n A B h]; rfl

end InfinitesimalProbability