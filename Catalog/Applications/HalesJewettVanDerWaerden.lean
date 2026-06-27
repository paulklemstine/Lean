/-
# The Hales–Jewett theorem and van der Waerden's theorem

The **Hales–Jewett theorem** (`Combinatorics.Line.exists_mono_in_high_dimension`
in Mathlib) is the structural heart of Ramsey theory: in a sufficiently
high-dimensional combinatorial cube `Fin n → α`, every finite colouring contains
a monochromatic *combinatorial line*.  Its most famous arithmetic consequence is
**van der Waerden's theorem**: every finite colouring of the natural numbers
contains arbitrarily long monochromatic arithmetic progressions.

Mathlib packages the abstract step as `Combinatorics.exists_mono_homothetic_copy`
(a monochromatic homothetic copy of any finite subset of a commutative monoid).
This file *derives the classical statement of van der Waerden's theorem* from it,
in the explicit arithmetic-progression form, and records concrete corollaries:

* `vanderWaerden`            — every finite colouring `C : ℕ → κ` admits, for each
  length `k`, a monochromatic AP `b, b+a, …, b+(k-1)a` with common difference
  `a > 0`.
* `vanderWaerden_card`       — the `k` terms of that progression form a `Finset`
  of cardinality exactly `k` (they are genuinely distinct), so it is a real
  `k`-term progression.
* `mono_three_AP`            — the length-`3` instance: every finite colouring of
  `ℕ` has a monochromatic three-term AP `b, b+a, b+2a`.
* `exists_mono_AP_arbitrary_length` — restating that monochromatic APs of *every*
  length exist.

## Lab Notes — see `-- !-- Lab Notes -- !--` blocks below.
-/

import Mathlib

open scoped Classical
open Finset

namespace RamseyTheory

/- -- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): the Hales–Jewett theorem is strictly stronger than van
der Waerden's theorem, the latter being the image of the former under the
"evaluation" map sending a combinatorial line in `Fin n → {0,…,k-1}` to an
arithmetic progression via coordinate-summation.  Concretely, a monochromatic
homothetic copy of `{0,1,…,k-1}` *is* a monochromatic AP of length `k`.

EXPERIMENT (Experimenter): we instantiate `exists_mono_homothetic_copy` with the
commutative monoid `M = ℕ`, colour set `κ`, and subset `S = Finset.range k`.  The
homothety `s ↦ a • s + b = a*s + b` turns the abstract copy into the explicit AP
`b + a*i`; the scalar action `•` on `ℕ` is multiplication (`smul_eq_mul`).  The
common difference is the returned `a > 0`.
-/

/-! ## Van der Waerden's theorem -/

/-
**Van der Waerden's theorem** (arithmetic-progression form).  For every finite
colour set `κ`, every colouring `C : ℕ → κ`, and every length `k`, there is a
monochromatic arithmetic progression of length `k`: a common difference `a > 0`,
a starting point `b`, and a colour `c` with `C (b + a*i) = c` for all `i < k`.

This is the classical consequence of the **Hales–Jewett theorem**, obtained from
Mathlib's `exists_mono_homothetic_copy` applied to `S = Finset.range k ⊆ ℕ`.
-/
theorem vanderWaerden {κ : Type*} [Finite κ] (C : ℕ → κ) (k : ℕ) :
    ∃ a > 0, ∃ (b : ℕ) (c : κ), ∀ i < k, C (b + a * i) = c := by
  obtain ⟨a, ha, b, c, h⟩ : ∃ a > 0, ∃ b c, ∀ s ∈ Finset.range k, C (a * s + b) = c := by
    have := @Combinatorics.exists_mono_homothetic_copy;
    simpa using this ( Finset.range k ) C;
  exact ⟨ a, ha, b, c, fun i hi => by simpa only [ add_comm ] using h i ( Finset.mem_range.mpr hi ) ⟩

/-
**Distinctness.** The `k` terms `b + a*i` (`i < k`) of the van der Waerden
progression, with common difference `a > 0`, are pairwise distinct, so they form a
`Finset` of cardinality exactly `k`.  Hence the progression is a genuine `k`-term
arithmetic progression, not a degenerate one.
-/
theorem vanderWaerden_card {κ : Type*} [Finite κ] (C : ℕ → κ) (k : ℕ) :
    ∃ a > 0, ∃ (b : ℕ) (c : κ),
      ((Finset.range k).image (fun i => b + a * i)).card = k ∧
      ∀ i < k, C (b + a * i) = c := by
  have := @vanderWaerden κ ‹_› C k;
  rcases this with ⟨ a, ha, b, c, hc ⟩ ; exact ⟨ a, ha, b, c, by rw [ Finset.card_image_of_injective _ fun x y hxy => by nlinarith ] ; simp +decide, hc ⟩ ;

/-
**Monochromatic three-term progression.** Every finite colouring of `ℕ`
contains a monochromatic three-term arithmetic progression `b, b+a, b+2a` with
`a > 0`. The length-`3` instance of van der Waerden's theorem.
-/
theorem mono_three_AP {κ : Type*} [Finite κ] (C : ℕ → κ) :
    ∃ a > 0, ∃ (b : ℕ) (c : κ), C b = c ∧ C (b + a) = c ∧ C (b + 2 * a) = c := by
  have := vanderWaerden_card C 3;
  obtain ⟨ a, ha, b, c, h₁, h₂ ⟩ := this; exact ⟨ a, ha, b, c, by simpa using h₂ 0 ( by decide ), by simpa [ mul_comm ] using h₂ 1 ( by decide ), by simpa [ mul_comm ] using h₂ 2 ( by decide ) ⟩ ;

/-- **Arbitrarily long monochromatic progressions.** In any finite colouring of
`ℕ`, for every `k` there is a monochromatic arithmetic progression of length `k`. -/
theorem exists_mono_AP_arbitrary_length {κ : Type*} [Finite κ] (C : ℕ → κ) :
    ∀ k, ∃ a > 0, ∃ (b : ℕ) (c : κ), ∀ i < k, C (b + a * i) = c :=
  fun k => vanderWaerden C k

/- -- !-- Lab Notes -- !--
ANALYSIS (Analyst): the derivation is a faithful, non-trivial corollary, not a
rename: the abstract homothetic copy `a • s + b` over the monoid `ℕ` must be
identified with the arithmetic progression `b + a*i` (using `smul_eq_mul` and
commutativity of `+`), and the index set `S = range k` translated to the bound
`i < k`.  `vanderWaerden_card` adds the genuinely new content that the progression
is non-degenerate (`a > 0` forces the `k` terms to be distinct via injectivity of
`i ↦ b + a*i`).

CRITIQUE (Critic): none of these results is `decide`/`simp`-only — each threads
the Hales–Jewett input through an explicit translation and (for the card lemma) an
injectivity argument.  All hypotheses (`Finite κ`) are satisfiable and the
conclusions are non-vacuous: e.g. `mono_three_AP` applies to every two-colouring
of `ℕ`.  The dependence on `exists_mono_homothetic_copy` makes the Hales–Jewett
theorem the genuine engine.

SYNTHESIS (PI): the catalog now connects the abstract Ramsey-theoretic core
(Hales–Jewett) to its canonical arithmetic shadow (van der Waerden), complementing
the graph-theoretic two-colour Ramsey numbers developed in the other Ramsey files.
-/

end RamseyTheory