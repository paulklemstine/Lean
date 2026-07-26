/-
# The Library of Babel: Combinatorics of the Universal Library (Core)

Borges' *Library of Babel* is the set of **all** books of a fixed length over a
fixed alphabet.  We formalise a *volume* as a function `Fin L → Fin A` (a string
of `L` symbols drawn from an alphabet of size `A`), and the whole Library as the
finite type of all such volumes.

## Main Results (this file)

1. **Library size** (`card_volume`): the Library has exactly `A ^ L` volumes.
   For Borges' parameters `A = 25`, `L = 1312000` this is `25 ^ 1312000`.

2. **Constrained-content count** (`card_matchesOn`): the number of volumes whose
   content is prescribed on a set `S` of `S.card` positions is exactly
   `A ^ (L - S.card)` — fixing a symbol removes exactly one factor of `A`.

3. **Pattern-occurrence count** (`card_occursAt`): for an injective family of
   `m` positions, the number of volumes carrying a prescribed length-`m` pattern
   there is `A ^ (L - m)`.  This is the exact "how many books contain this exact
   passage at this exact place" count that underlies the probability estimates.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the size of the Library is `A^L`, and fixing the text
on `d` positions divides the population by `A^d`.  Both are combinatorial
counting facts, but they are the quantitative backbone of every "probability of
finding meaning" statement in the theme.

Experiment (Experimenter): computed small cases.  `A=4, L=2` gives `16` volumes;
fixing one position leaves `4 = 4^(2-1)`.  `A=2, L=3` gives `8`; a fixed length-2
window leaves `2 = 2^(3-2)`.  All match `A^(L-d)`.

Analysis (Analyst): the clean proof is the bijection
`{s // s = p on S} ≃ (Sᶜ → Fin A)` (restrict / glue), giving `A^(L - S.card)`.
The pattern version follows by taking `S` to be the (injective) image of the
window index family, whose cardinality is `m`.  We phrase the counts with
`Nat.card` (instance-independent) to avoid a `Fintype` instance diamond that
appears once the whole of Mathlib is in scope.
-/
import Mathlib

open Finset Fintype Function

namespace LibraryOfBabel

/-- A **volume** of the Library: a book of `L` symbols over an alphabet of size `A`. -/
abbrev Volume (A L : ℕ) : Type := Fin L → Fin A

/-- **Library size.** The Library of all length-`L` books over an `A`-symbol
alphabet contains exactly `A ^ L` volumes.  For Borges' Library (`A = 25`,
`L = 1312000`) this is the famous `25 ^ 1312000`. -/
theorem card_volume (A L : ℕ) : Nat.card (Volume A L) = A ^ L := by
  simp [Nat.card_eq_fintype_card]

/-- `MatchesOn S p s` says the volume `s` agrees with the prescribed text `p` on
every position in the finite set `S`. -/
def MatchesOn {A L : ℕ} (S : Finset (Fin L)) (p : Fin L → Fin A) (s : Volume A L) : Prop :=
  ∀ i ∈ S, s i = p i

/-- **Constrained-content count.** The number of volumes whose content is
prescribed (equal to `p`) on a set `S` of positions is exactly `A ^ (L - S.card)`.
Fixing the symbol at a position removes exactly one factor of `A` from the count. -/
theorem card_matchesOn {A L : ℕ} (S : Finset (Fin L)) (p : Fin L → Fin A) :
    Nat.card {s : Volume A L // MatchesOn S p s} = A ^ (L - S.card) := by
  classical
  let e : {s : Volume A L // MatchesOn S p s} ≃ ((↥(Sᶜ)) → Fin A) :=
  { toFun := fun s i => s.1 i
    invFun := fun f => ⟨fun i => if h : i ∈ S then p i else f ⟨i, by simp [h]⟩, by
      intro i hi; simp [hi]⟩
    left_inv := by
      rintro ⟨s, hs⟩; ext i
      by_cases h : i ∈ S
      · simp [h, hs i h]
      · simp [h]
    right_inv := by
      intro f; ext i
      have : (i : Fin L) ∉ S := Finset.mem_compl.mp i.2
      simp [this] }
  rw [Nat.card_congr e, Nat.card_eq_fintype_card, Fintype.card_fun]
  simp [Fintype.card_coe]

/-- `OccursAt idx p s` says the volume `s` carries the length-`m` pattern `p` at
the positions listed by the family `idx : Fin m → Fin L`. -/
def OccursAt {A L m : ℕ} (idx : Fin m → Fin L) (p : Fin m → Fin A) (s : Volume A L) : Prop :=
  ∀ j, s (idx j) = p j

/-- **Pattern-occurrence count.** For an *injective* family of `m` positions
`idx`, the number of volumes carrying a prescribed length-`m` pattern `p` there
is exactly `A ^ (L - m)`.  This is the exact count "how many books contain this
exact passage at these exact positions". -/
theorem card_occursAt {A L m : ℕ} (idx : Fin m → Fin L) (hidx : Function.Injective idx)
    (p : Fin m → Fin A) :
    Nat.card {s : Volume A L // OccursAt idx p s} = A ^ (L - m) := by
  classical
  -- The `m = 0` case: the pattern constraint is vacuous.
  rcases Nat.eq_zero_or_pos m with hm0 | hmpos
  · subst hm0
    have hall : ∀ s : Volume A L, OccursAt idx p s := by
      intro s j; exact absurd j.2 (by omega)
    rw [Nat.card_congr (Equiv.subtypeUnivEquiv hall), card_volume, Nat.sub_zero]
  -- The `m > 0` case: we have a fallback symbol `p ⟨0, hmpos⟩ : Fin A`.
  set S : Finset (Fin L) := Finset.univ.image idx with hS
  have hScard : S.card = m := by
    rw [hS, Finset.card_image_of_injective _ hidx]; simp
  -- The volumes carrying the pattern are exactly those matching a suitable `q` on `S`.
  let q : Fin L → Fin A := fun k =>
    if h : ∃ j, idx j = k then p (Classical.choose h) else p ⟨0, hmpos⟩
  have hqidx : ∀ j, q (idx j) = p j := by
    intro j
    have hex : ∃ j', idx j' = idx j := ⟨j, rfl⟩
    simp only [q, dif_pos hex]
    have := Classical.choose_spec hex
    exact congrArg p (hidx this)
  have hiff : ∀ s : Volume A L, OccursAt idx p s ↔ MatchesOn S q s := by
    intro s
    constructor
    · intro h k hk
      rw [hS, Finset.mem_image] at hk
      obtain ⟨j, _, rfl⟩ := hk
      rw [h j, hqidx j]
    · intro h j
      have hk : idx j ∈ S := by rw [hS, Finset.mem_image]; exact ⟨j, by simp⟩
      rw [h (idx j) hk, hqidx j]
  rw [Nat.card_congr (Equiv.subtypeEquivRight hiff), card_matchesOn, hScard]

/-! Instances needed downstream. `Fin A` is nonempty exactly when `A > 0`. -/

/-- The Library is nonempty as soon as the alphabet is nonempty. -/
instance (A L : ℕ) [NeZero A] : Nonempty (Volume A L) := by
  refine ⟨fun _ => ?_⟩
  exact ⟨0, Nat.pos_of_ne_zero (NeZero.ne A)⟩

end LibraryOfBabel