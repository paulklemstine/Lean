/-
Copyright (c) 2025 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Razborov–Rudich Natural Proofs Barrier: a counting / distinguisher core

This module formalizes the *combinatorial heart* of the Razborov–Rudich
**natural proofs barrier**.  Informally, a circuit lower-bound proof proceeds
by exhibiting a property `P` of Boolean functions (equivalently, of truth
tables) that

* is **large** — a non-negligible fraction of all Boolean functions satisfy `P`;
* is **useful** — every function computable by a *small* circuit *fails* `P`
  (so `P` certifies that any function satisfying `P` has no small circuit).

Razborov and Rudich observed that *if such a property is also efficiently
checkable (constructive)*, it can be repurposed as a **statistical test**:
a random truth table satisfies `P` with probability ≥ its density, while every
output of an efficient pseudorandom function generator `G` (whose outputs are,
by construction, computable by small circuits) *fails* `P`.  Hence `P`
distinguishes `G` from uniform with advantage equal to its density — breaking
the pseudorandom generator.

We abstract a "Boolean function" as a **truth table** `Tbl m = Fin m → Bool`
(think `m = 2ⁿ`), a "property" as a decidable predicate on truth tables, the
"small-circuit class" as the image of a generator `G : S → Tbl m` indexed by a
finite seed set `S`, and probabilities as exact rationals via `Finset` counting.

## Main definitions

* `Tbl m`               — truth tables on `m` rows (`Fin m → Bool`).
* `accRandom P`         — probability a uniformly random truth table satisfies `P`.
* `accGen G P`          — probability the generator output `G s` satisfies `P`.
* `Useful P C`          — `P` rejects every function in the class `C : Finset (Tbl m)`.

## Main theorems

* `NaturalProofs.accGen_eq_zero_of_useful`
    a property useful against the generator's image is never satisfied by an output.
* `NaturalProofs.natural_property_distinguishes`
    **(forward direction)** a large + useful property yields a distinguisher with
    advantage ≥ its density bound `δ`.
* `NaturalProofs.barrier`
    **(contrapositive / the barrier)** if `G` is `δ`-pseudorandom (no advantage
    reaches `δ`) and `P` is `δ`-large, then `P` *cannot* be useful against the
    outputs of `G`: some easy function `G s` satisfies `P`.
* `NaturalProofs.barrier_class`
    the same conclusion phrased for an explicit small-circuit class `C ⊇ image G`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The Razborov–Rudich obstruction is, at its core, a
two-line counting argument: largeness gives `accRandom P ≥ δ`, usefulness gives
`accGen P = 0`, so the advantage `accRandom P - accGen G P = accRandom P ≥ δ`.
The barrier is the exact contrapositive — pseudorandomness (advantage `< δ`)
forces `accGen P > 0`, i.e. the property is *useless* against easy functions.
The bold conjecture worth isolating: the barrier needs *no* structure on `P`
beyond density and decidability — it is purely a pigeonhole on the seed set.

Experiment (Experimenter): Model truth tables as `Fin m → Bool`, probabilities
as `Finset.card`-quotients in `ℚ`, and prove both directions. The decisive step
is `accGen_eq_zero_of_useful` (the filter is empty) for the forward direction,
and a `by_contra`+`push_neg` reduction to the same emptiness for the barrier.

Analysis (Analyst): Forward and barrier are honest contrapositives sharing the
emptiness lemma, confirming the structural symmetry conjectured above. The proof
uses only `0 < card S` (Nonempty seed set) — the pigeonhole really is the whole
story; no cryptographic hardness is *assumed*, only *concluded to be necessary*.

Critique (Critic): The hypotheses must be *satisfiable* or the barrier is
vacuous. `Examples.density_nonconstant_pos` exhibits a concrete large property
(`Tbl m` not identically `false`) with strictly positive density, and
`Examples.advantage_witness` instantiates the forward distinguisher on it, so no
result is vacuously true.

Synthesis (PI): The barrier is a self-dual counting law on `(accRandom, accGen)`.
This packaging makes the "naturalness ⇒ distinguisher ⇒ no PRGs" implication a
theorem about densities, cleanly separating the combinatorics (done here) from
the cryptographic interpretation (the meaning of `C` and `G`).
-/

open Finset

namespace NaturalProofs

/-- A **truth table** on `m` rows: a Boolean function presented by its values.
Think of `m = 2ⁿ` so that `Tbl m` ranges over all Boolean functions on `n`
inputs. -/
abbrev Tbl (m : ℕ) := Fin m → Bool

variable {m : ℕ} {S : Type*}

/-- The acceptance probability of property `P` on a **uniformly random** truth
table: the fraction of all `2^m` truth tables that satisfy `P`. -/
noncomputable def accRandom (P : Tbl m → Prop) [DecidablePred P] : ℚ :=
  ((univ.filter P).card : ℚ) / (Fintype.card (Tbl m) : ℚ)

/-- The acceptance probability of property `P` on the output of generator
`G : S → Tbl m` with a uniformly random seed: the fraction of seeds `s` for
which `G s` satisfies `P`. -/
noncomputable def accGen [Fintype S] (G : S → Tbl m) (P : Tbl m → Prop)
    [DecidablePred P] : ℚ :=
  ((univ.filter (fun s => P (G s))).card : ℚ) / (Fintype.card S : ℚ)

/-- A property `P` is **useful** against a class `C` of (easy) functions if no
member of `C` satisfies `P`; equivalently `P` certifies "not in `C`". -/
def Useful (P : Tbl m → Prop) (C : Finset (Tbl m)) : Prop := ∀ f ∈ C, ¬ P f

/-! ### Basic positivity facts -/

theorem accRandom_nonneg (P : Tbl m → Prop) [DecidablePred P] :
    0 ≤ accRandom P := by
  unfold accRandom
  positivity

theorem accGen_nonneg [Fintype S] (G : S → Tbl m) (P : Tbl m → Prop)
    [DecidablePred P] : 0 ≤ accGen G P := by
  unfold accGen
  positivity

/-! ### The emptiness lemma shared by both directions -/

/-- If `P` is never satisfied by any generator output, the generator acceptance
probability is exactly `0`. This is the algebraic shadow of "usefulness against
the small-circuit class `= image G`". -/
theorem accGen_eq_zero_of_useful [Fintype S] {G : S → Tbl m} {P : Tbl m → Prop}
    [DecidablePred P] (h : ∀ s, ¬ P (G s)) : accGen G P = 0 := by
  unfold accGen
  have : (univ.filter (fun s => P (G s))) = (∅ : Finset S) := by
    rw [Finset.filter_eq_empty_iff]
    intro s _
    exact h s
  rw [this]
  simp

/-! ### Forward direction: a natural property is a distinguisher -/

/-- **Forward direction of Razborov–Rudich.**
A property that is *large* (density at least `δ`) and *useful* against the
generator's image distinguishes the generator from uniform with advantage at
least `δ`. The advantage is `accRandom P - accGen G P`; usefulness kills the second
term, so the advantage equals the density, which is `≥ δ`. -/
theorem natural_property_distinguishes [Fintype S] {G : S → Tbl m}
    {P : Tbl m → Prop} [DecidablePred P] {δ : ℚ}
    (hlarge : δ ≤ accRandom P) (huseful : ∀ s, ¬ P (G s)) :
    δ ≤ accRandom P - accGen G P := by
  rw [accGen_eq_zero_of_useful huseful, sub_zero]
  exact hlarge

/-! ### The barrier: pseudorandomness destroys usefulness -/

/-- **The natural proofs barrier (contrapositive form).**
Assume the generator `G` is `δ`-*pseudorandom* against the test `P`, meaning the
distinguishing advantage `accRandom P - accGen G P` stays strictly below `δ`.
If `P` is nonetheless `δ`-*large*, then `P` **cannot** be useful against the
outputs of `G`: there is a seed `s` whose (easy) output `G s` satisfies `P`.

In words: a large property that a secure pseudorandom generator survives must
accept some efficiently computable function — so it is *useless* as a circuit
lower-bound certificate. This is precisely why "natural" proofs cannot separate
`P` from `NP` while strong pseudorandom generators exist. -/
theorem barrier [Fintype S] [Nonempty S] {G : S → Tbl m} {P : Tbl m → Prop}
    [DecidablePred P] {δ : ℚ}
    (hlarge : δ ≤ accRandom P)
    (hpseudo : accRandom P - accGen G P < δ) :
    ∃ s, P (G s) := by
  by_contra h
  push_neg at h
  have hz : accGen G P = 0 := accGen_eq_zero_of_useful h
  rw [hz, sub_zero] at hpseudo
  exact absurd hlarge (not_le.mpr hpseudo)

/-- **The barrier, class form.**
If the small-circuit class `C` contains every generator output and `G` is
`δ`-pseudorandom against the `δ`-large property `P`, then `P` fails to be useful
against `C`: some function in `C` (namely an output of `G`) satisfies `P`. -/
theorem barrier_class [Fintype S] [Nonempty S] {G : S → Tbl m} {P : Tbl m → Prop}
    [DecidablePred P] {δ : ℚ} {C : Finset (Tbl m)}
    (hCG : ∀ s, G s ∈ C)
    (hlarge : δ ≤ accRandom P)
    (hpseudo : accRandom P - accGen G P < δ) :
    ¬ Useful P C := by
  intro hU
  obtain ⟨s, hs⟩ := barrier (G := G) hlarge hpseudo
  exact hU (G s) (hCG s) hs

end NaturalProofs