/-
Copyright (c) 2024 Harmonic Research. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
-/
import Mathlib

/-!
# The Library of Babel: finite combinatorics

This file formalizes the elementary finite combinatorics underlying Jorge Luis
Borges' short story *The Library of Babel*.  In Borges' library every book has
exactly the same length and is written using a fixed finite alphabet, so the set
of all possible books is a finite type whose cardinality is an exact power.

## Main definitions

* `LibraryOfBabel.Alphabet` — the alphabet, modelled as `Fin 25`.
* `LibraryOfBabel.Volume n` — a book of length `n`, modelled as `Fin n → Alphabet`.
* `LibraryOfBabel.BabelLength` — Borges' canonical length, `1312000`.
* `LibraryOfBabel.BabelVolume` — a canonical Borges book.
* `LibraryOfBabel.universalCatalog` — the bijective enumeration of all volumes.
* `LibraryOfBabel.countingProb` — the uniform counting probability of a finite
  set of volumes.

## Main results

* `card_volume` — there are exactly `25 ^ n` volumes of length `n`.
* `card_babel_volume` / `card_babel_volume_explicit` — the Borges specialization.
* `card_singleton_target` — a fixed target book is a singleton event.
* `universalCatalog_symm_apply_apply` / `universalCatalog_apply_symm_apply` —
  encode/decode correctness of the catalog.
* `countingProb_singleton` — the exact-target event has probability `1 / 25 ^ n`.

Semantic notions (whether a given book is "meaningful", contains a valid proof,
etc.) are intentionally **not** modelled here; see `RESEARCH_PAPER.md` and
`FUTURE_DIRECTIONS.md`.
-/

namespace LibraryOfBabel

/-- The Borges alphabet, modelled as a 25-letter alphabet. -/
abbrev Alphabet : Type := Fin 25

/-- A *volume* (book) of length `n` is a string of `n` letters, modelled as a
function from positions `Fin n` to the alphabet. -/
abbrev Volume (n : ℕ) : Type := Fin n → Alphabet

/-- Borges' canonical book length. -/
def BabelLength : ℕ := 1312000

/-- A volume of the canonical Borges length. -/
abbrev BabelVolume : Type := Volume BabelLength

/-! ### Counting volumes -/

/-- There are exactly `25 ^ n` volumes of length `n`: a volume is a function from
the `n` positions into the 25-letter alphabet. -/
theorem card_volume (n : ℕ) : Fintype.card (Volume n) = 25 ^ n := by
  simp [Volume, Alphabet]

/-- The Borges specialization: the number of books of length `BabelLength`. -/
theorem card_babel_volume : Fintype.card BabelVolume = 25 ^ BabelLength :=
  card_volume BabelLength

/-- The Borges specialization with the length written out explicitly. -/
theorem card_babel_volume_explicit :
    Fintype.card BabelVolume = 25 ^ (1312000 : ℕ) :=
  card_volume BabelLength

/-! ### A fixed target book -/

/-- The event consisting of exactly one prescribed book `target` is a singleton,
hence has cardinality `1`. -/
theorem card_singleton_target {n : ℕ} (target : Volume n) :
    ({target} : Finset (Volume n)).card = 1 :=
  Finset.card_singleton target

/-! ### The universal catalog -/

/-- The *universal catalog*: a bijection between the volumes of length `n` and an
initial segment `Fin (Fintype.card (Volume n))` of the natural numbers.  This is
the mathematical content of Borges' idea that the library can be exhaustively
indexed. -/
noncomputable def universalCatalog (n : ℕ) :
    Volume n ≃ Fin (Fintype.card (Volume n)) :=
  Fintype.equivFin (Volume n)

/-- Decoding a freshly encoded volume returns the original volume. -/
@[simp]
theorem universalCatalog_symm_apply_apply {n : ℕ} (v : Volume n) :
    (universalCatalog n).symm ((universalCatalog n) v) = v :=
  (universalCatalog n).symm_apply_apply v

/-- Encoding a freshly decoded index returns the original index. -/
@[simp]
theorem universalCatalog_apply_symm_apply {n : ℕ}
    (i : Fin (Fintype.card (Volume n))) :
    (universalCatalog n) ((universalCatalog n).symm i) = i :=
  (universalCatalog n).apply_symm_apply i

/-- The catalog is injective: distinct books receive distinct catalogue numbers. -/
theorem universalCatalog_injective (n : ℕ) :
    Function.Injective (universalCatalog n) :=
  (universalCatalog n).injective

/-- The catalog is surjective: every catalogue number is realised by some book. -/
theorem universalCatalog_surjective (n : ℕ) :
    Function.Surjective (universalCatalog n) :=
  (universalCatalog n).surjective

/-! ### Uniform counting probability -/

/-- The uniform counting probability of a finite set `S` of volumes of length
`n`: the fraction of all `25 ^ n` volumes that lie in `S`, as a rational number. -/
def countingProb {n : ℕ} (S : Finset (Volume n)) : ℚ :=
  (S.card : ℚ) / (25 ^ n : ℚ)

/-- The exact-target event `{target}` has uniform counting probability
`1 / 25 ^ n`. -/
theorem countingProb_singleton {n : ℕ} (target : Volume n) :
    countingProb ({target} : Finset (Volume n)) = 1 / (25 ^ n : ℚ) := by
  simp [countingProb, Finset.card_singleton]

end LibraryOfBabel