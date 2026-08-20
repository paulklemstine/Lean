import Mathlib
import Catalog.Shared.RainbowAPSpectrumAsymptotics

/-!
# From full spectra to genuine rainbow arithmetic progressions

The threshold studied in `Shared.RainbowAPSpectrumThreshold` is about words over an alphabet.
Here we give that alphabet its combinatorial meaning: the alphabet `Fin l → Fin k` is the set of
*colour patterns* of an `l`-term arithmetic progression coloured with `k` colours, and a word of
length `m` over it is exactly the restriction of a `k`-colouring of the interval `[0, l m)` to the
`m` consecutive `l`-term progressions of common difference `1`.

Main results.

* `RainbowAP.exists_rainbow_block` : a full-spectrum word contains an injective (rainbow) pattern
  as soon as `l ≤ k`.
* `RainbowAP.exists_rainbow_AP` : consequently, a `k`-colouring of `ℕ` whose block word on
  `[0, l m)` has full spectrum contains a genuine rainbow `l`-term arithmetic progression inside
  `[0, l m)`.
* `RainbowAP.majority_rainbow` : above the union-bound threshold, a strict majority of all
  patterns of length `m` already contain a rainbow progression.
* `RainbowAP.patternThreshold_bounds` : the `l`-pattern threshold is
  `Θ(k^l log(k^l))`; for `l = 2` this is the `Θ(k² log k)` regime of `Shared.RainbowAPPairThreshold`.
-/

open Finset

namespace RainbowAP

variable {k l m : ℕ}

/-- The word of colour patterns read off from a colouring `chi` along the `m` consecutive
`l`-term arithmetic progressions of difference `1` inside `[0, l * m)`. -/
def blockWord (l m : ℕ) (chi : ℕ → Fin k) : Fin m → (Fin l → Fin k) :=
  fun t j => chi (l * (t : ℕ) + (j : ℕ))

/-- If there are at least as many colours as terms, a full-spectrum word contains a rainbow
(i.e. injectively coloured) block. -/
theorem exists_rainbow_block (hl : l ≤ k) (f : Fin m → (Fin l → Fin k))
    (hf : Function.Surjective f) : ∃ t : Fin m, Function.Injective (f t) := by
  set p : Fin l → Fin k := fun j => ⟨(j : ℕ), lt_of_lt_of_le j.isLt hl⟩ with hp
  have hpinj : Function.Injective p := by
    intro a b hab
    have h : ((p a : Fin k) : ℕ) = ((p b : Fin k) : ℕ) := congrArg Fin.val hab
    simp only [hp] at h
    exact Fin.ext h
  obtain ⟨t, ht⟩ := hf p
  exact ⟨t, ht ▸ hpinj⟩

/-- A colouring whose block word has full spectrum contains a genuine rainbow `l`-term
arithmetic progression (of common difference `1`) inside `[0, l * m)`. -/
theorem exists_rainbow_AP (hl : l ≤ k) (hl1 : 1 ≤ l) (chi : ℕ → Fin k)
    (hf : Function.Surjective (blockWord l m chi)) :
    ∃ a d : ℕ, 0 < d ∧ a + (l - 1) * d < l * m ∧
      Function.Injective (fun j : Fin l => chi (a + (j : ℕ) * d)) := by
  obtain ⟨t, ht⟩ := exists_rainbow_block hl _ hf
  refine ⟨l * (t : ℕ), 1, Nat.one_pos, ?_, ?_⟩
  · have h1 : (t : ℕ) + 1 ≤ m := t.isLt
    have h2 : l * ((t : ℕ) + 1) ≤ l * m := Nat.mul_le_mul_left l h1
    have h3 : l * (t : ℕ) + l ≤ l * m := by
      calc l * (t : ℕ) + l = l * ((t : ℕ) + 1) := by ring
        _ ≤ l * m := h2
    omega
  · intro a b hab
    simp only [mul_one] at hab
    exact ht (by simpa [blockWord] using hab)

/-- The words of length `m` over the pattern alphabet which contain a rainbow block. -/
def rainbowWords (k l m : ℕ) : Finset (Fin m → (Fin l → Fin k)) :=
  univ.filter (fun f => ∃ t : Fin m, Function.Injective (f t))

/-- Above the union-bound threshold, a strict majority of all pattern words already contains a
rainbow block, hence encodes a colouring with a rainbow `l`-term progression. -/
theorem majority_rainbow (hl : l ≤ k)
    (h : 2 * Fintype.card (Fin l → Fin k) * (Fintype.card (Fin l → Fin k) - 1) ^ m
        < Fintype.card (Fin l → Fin k) ^ m) :
    Fintype.card (Fin l → Fin k) ^ m < 2 * (rainbowWords k l m).card := by
  have hmaj := majority_surjective_of (α := Fin l → Fin k) m h
  have hsub : nonSurjSet (Fin l → Fin k) m ∪ rainbowWords k l m = univ := by
    ext f
    simp only [Finset.mem_union, Finset.mem_univ, iff_true]
    by_cases hs : Function.Surjective f
    · exact Or.inr (by
        simp only [rainbowWords, Finset.mem_filter, Finset.mem_univ, true_and]
        exact exists_rainbow_block hl f hs)
    · refine Or.inl ?_
      simp only [nonSurjSet, Finset.mem_filter, Finset.mem_univ, true_and]
      rcases Nat.eq_zero_or_pos (missCount f) with h0 | hpos
      · exact absurd ((missCount_eq_zero_iff f).1 h0) hs
      · exact hpos
  have hcard : Fintype.card (Fin m → (Fin l → Fin k))
      ≤ nonSurjCount (Fin l → Fin k) m + (rainbowWords k l m).card := by
    have := Finset.card_union_le (nonSurjSet (Fin l → Fin k) m) (rainbowWords k l m)
    have h2 : (univ : Finset (Fin m → (Fin l → Fin k))).card
        ≤ nonSurjCount (Fin l → Fin k) m + (rainbowWords k l m).card := by
      rw [← hsub]
      exact this
    simpa [Finset.card_univ] using h2
  have hpow : Fintype.card (Fin m → (Fin l → Fin k)) = Fintype.card (Fin l → Fin k) ^ m := by
    simp
  rw [hpow] at hcard
  omega

/-- The `l`-pattern threshold with `k` colours: the least number of `l`-term progressions after
which a majority of colourings shows every one of the `k ^ l` patterns. -/
noncomputable def patternThreshold (l k : ℕ) : ℕ := spectrumThreshold (Fin l → Fin k)

lemma card_pattern_alphabet (l k : ℕ) : Fintype.card (Fin l → Fin k) = k ^ l := by
  simp

/-- Two-sided bounds for the `l`-pattern threshold: it is `k^l log (k^l)` up to `1 + o(1)`. -/
theorem patternThreshold_bounds (l k : ℕ) (hk : 2 ≤ k ^ l) :
    (((k : ℝ) ^ l) - 1) * Real.log (((k : ℝ) ^ l) + 1) ≤ (patternThreshold l k : ℝ) ∧
    (patternThreshold l k : ℝ) ≤ ((k : ℝ) ^ l) * Real.log (2 * ((k : ℝ) ^ l)) + 1 := by
  have hcard : Fintype.card (Fin l → Fin k) = k ^ l := card_pattern_alphabet l k
  have hge : 2 ≤ Fintype.card (Fin l → Fin k) := by rw [hcard]; exact hk
  have hlow := le_spectrumThreshold (α := Fin l → Fin k) hge
  have hupp := spectrumThreshold_le (α := Fin l → Fin k) hge
  rw [hcard] at hlow hupp
  have hcast : (((k ^ l : ℕ)) : ℝ) = ((k : ℝ)) ^ l := by push_cast; ring
  rw [hcast] at hlow hupp
  exact ⟨by rw [patternThreshold]; exact hlow, by rw [patternThreshold]; exact hupp⟩

end RainbowAP