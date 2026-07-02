/-
# The Library of Babel: Probability of Finding Meaning

Borges asks: what is the chance that a random volume contains a given passage —
a proof, a theorem, a sentence?  Here `p : Fin m → Fin A` is the target passage
(length `m`), and a volume *contains* it if the passage appears as a contiguous
window somewhere inside the book.

## Main Results (this file)

1. **Occurrence union bound** (`card_containsPattern_le`): the number of volumes
   containing a fixed length-`m` passage anywhere is at most
   `(L - m + 1) · A ^ (L - m)` — one term `A^(L-m)` per starting position, summed
   over the `L - m + 1` possible windows.

2. **Probability bound** (`prob_containsPattern_le`): dividing by the Library
   size `A ^ L`, the probability that a uniformly random volume contains the
   passage is at most `(L - m + 1) · A ^ (-m)`.  This is the rigorous form of the
   theme's heuristic `|T| · 25^{-k}`: the "meaning density" of the Library decays
   like the alphabet size raised to the *minus* passage length.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the theme claims the probability of a random volume
containing a proof of `T` is `≈ |T| · 25^{-k}`.  Read literally this is a union
bound: `#windows · Pr[match at a fixed window]`.

Experiment (Experimenter): a fixed window of length `m` is matched by exactly a
`A^{-m}` fraction of volumes (Basic.card_occursAt).  There are `L - m + 1`
windows, so a union bound gives `(L-m+1)·A^{-m}`.  Sanity check `A=2, L=3, m=2`:
`(3-2+1)·2^{-2} = 2·(1/4) = 1/2`.  Direct enumeration of the 8 binary strings of
length 3 shows exactly those containing "11" or "00" as a window — 6 of them, so
the true probability `6/8 = 3/4`.  The bound `1/2` is *not* an upper bound here?
Recheck: pattern is a *single fixed* `p`, not "any repeat".  For `p = (1,1)` the
strings of length 3 containing `11` are `110,011,111` → 3, and `3/8 ≤ 1/2 ✓`.

Analysis (Analyst): the inclusion–exclusion overcount (windows can overlap) means
the union bound is genuine (`≤`, not `=`).  The clean proof route is
`filter Contains = ⋃_i filter (OccursAt window_i)` then `card_biUnion_le` and the
exact per-window count from `Basic.card_occursAt`.

Critique (Critic): the heuristic's leading factor is `|T| = m`, but the honest
combinatorial factor is the number of *windows* `L - m + 1`, which for `m ≪ L`
is `≈ L`, not `m`.  So the theme's `|T|·25^{-k}` mis-identifies the polynomial
prefactor; the correct statement replaces `|T|` by the number of placements
`L - |T| + 1`.  We prove the corrected inequality.
-/
import Mathlib
import Cryptography.LibraryOfBabel.Basic

open Finset Fintype Function LibraryOfBabel

namespace LibraryOfBabel

/-- The window of `m` consecutive positions starting at offset `i`
(where `i : Fin (L - m + 1)` and `m ≤ L` guarantee the window fits inside the
book). -/
def window {L m : ℕ} (hm : m ≤ L) (i : Fin (L - m + 1)) (j : Fin m) : Fin L :=
  ⟨i.val + j.val, by have := i.2; have := j.2; omega⟩

/-- Each window is an injective family of positions. -/
theorem window_injective {L m : ℕ} (hm : m ≤ L) (i : Fin (L - m + 1)) :
    Function.Injective (window hm i) := by
  intro a b hab
  simp only [window, Fin.mk.injEq] at hab
  exact Fin.ext (by omega)

/-- A volume `s` **contains** the passage `p` if `p` appears as a contiguous
window somewhere inside the book. -/
def ContainsPattern {A L m : ℕ} (hm : m ≤ L) (p : Fin m → Fin A) (s : Volume A L) : Prop :=
  ∃ i : Fin (L - m + 1), OccursAt (window hm i) p s

/-- **Occurrence union bound.** The number of volumes that contain the passage
`p` anywhere is at most `(L - m + 1) · A ^ (L - m)`: at most `A^(L-m)` volumes per
starting window, and `L - m + 1` windows. -/
theorem card_containsPattern_le {A L m : ℕ} (hm : m ≤ L) (p : Fin m → Fin A) :
    Nat.card {s : Volume A L // ContainsPattern hm p s} ≤ (L - m + 1) * A ^ (L - m) := by
  classical
  -- Bridge `Nat.card` of the subtype to a `Finset.filter` cardinality.
  rw [Nat.card_eq_fintype_card, Fintype.card_subtype]
  -- The containing volumes are the union, over windows, of the per-window matches.
  have hsub :
      (univ.filter (fun s : Volume A L => ContainsPattern hm p s))
        ⊆ (univ : Finset (Fin (L - m + 1))).biUnion
            (fun i => univ.filter (fun s : Volume A L => OccursAt (window hm i) p s)) := by
    intro s hs
    simp only [mem_filter, mem_biUnion, mem_univ, true_and] at hs ⊢
    obtain ⟨i, hi⟩ := hs
    exact ⟨i, hi⟩
  refine le_trans (Finset.card_le_card hsub) ?_
  refine le_trans (Finset.card_biUnion_le) ?_
  -- Each per-window match set has exactly `A^(L-m)` elements.
  have hcard : ∀ i : Fin (L - m + 1),
      (univ.filter (fun s : Volume A L => OccursAt (window hm i) p s)).card = A ^ (L - m) := by
    intro i
    have := card_occursAt (window hm i) (window_injective hm i) p
    rwa [Nat.card_eq_fintype_card, Fintype.card_subtype] at this
  rw [Finset.sum_congr rfl (fun i _ => hcard i)]
  simp [mul_comm]

/-- **Probability bound.** The probability that a uniformly random volume
contains the passage `p` is at most `(L - m + 1) / A ^ m`.  Here the probability
is the exact ratio (matching volumes)/(all volumes), computed in `ℝ`.  This is the
rigorous form of the heuristic "meaning density `≈ |T|·A^{-|T|}`", with the honest
prefactor `L - m + 1` (the number of placements). -/
theorem prob_containsPattern_le {A L m : ℕ} (hA : 0 < A) (hm : m ≤ L)
    (p : Fin m → Fin A) :
    (Nat.card {s : Volume A L // ContainsPattern hm p s} : ℝ) / (A ^ L : ℝ)
      ≤ (L - m + 1 : ℝ) / (A : ℝ) ^ m := by
  have hApos : (0 : ℝ) < (A : ℝ) ^ L := by positivity
  have hAmpos : (0 : ℝ) < (A : ℝ) ^ m := by positivity
  rw [div_le_div_iff₀ hApos hAmpos]
  have hcount : (Nat.card {s : Volume A L // ContainsPattern hm p s} : ℝ)
      ≤ ((L - m + 1) * A ^ (L - m) : ℕ) := by
    exact_mod_cast card_containsPattern_le hm p
  have hpow : (A : ℝ) ^ (L - m) * (A : ℝ) ^ m = (A : ℝ) ^ L := by
    rw [← pow_add, Nat.sub_add_cancel hm]
  calc (Nat.card {s : Volume A L // ContainsPattern hm p s} : ℝ) * (A : ℝ) ^ m
      ≤ ((L - m + 1) * A ^ (L - m) : ℕ) * (A : ℝ) ^ m := by gcongr
    _ = (L - m + 1 : ℝ) * (A : ℝ) ^ L := by
        push_cast [Nat.cast_sub hm]
        rw [mul_assoc, hpow]

end LibraryOfBabel