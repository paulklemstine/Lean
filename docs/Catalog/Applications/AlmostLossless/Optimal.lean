/-
# Almost-lossless compression VI: the exact rate, and the price of error detection

Cycle 2 of the research loop.  Cycle 1 produced a converse
(`Core.epsilon_relaxed_pigeonhole`, `|goodSet| ≤ 2^(t+1) - 1`) and an achievability
scheme (`Enumerative.achievability`, `k + 1` bits for a typical set of size
`2 ^ k`).  These leave a gap of one to two bits.  Here we close it *exactly*.

The key structural discovery is that soundness — the ban on silent corruption —
has a precise price: **one codeword**.  A sound code that fails on at least one
source must reserve one bitstring as the failure marker, so with codewords of
length `≤ t` it can decode at most `2 ^ (t+1) - 2` sources, not `2 ^ (t+1) - 1`.
When the code never fails the full `2 ^ (t+1) - 1` are available.

## Main results

* `AlmostLossless.card_goodSet_add_two_le` — the sharpened converse: a sound code
  that fails somewhere satisfies `|goodSet| + 2 ≤ 2 ^ (t+1)`.
* `AlmostLossless.exists_sound_code_total` /
  `AlmostLossless.exists_sound_code_partial` — matching constructions.
* `AlmostLossless.sound_code_exists_iff` — **exact characterisation** of the sets
  that are the good set of some sound code of length `t`.
* `AlmostLossless.optimal_rate_iff` — **exact characterisation of the optimal
  ε-almost-lossless rate**: a sound code of length `t` failing with probability
  `≤ ε` exists *iff* some set `S` with `|S| + 2 ≤ 2 ^ (t+1)` (or `S = univ` with
  `|S| + 1 ≤ 2 ^ (t+1)`) carries mass `≥ 1 - ε`.  The optimal rate is therefore
  the `(1-ε)`-quantile of the source, and nothing else.
* `AlmostLossless.enumCode_within_two_bits` — the explicit linear-time scheme of
  `Enumerative` is never more than two bits above this optimum.
-/
import Mathlib
import Applications.AlmostLossless.Enumerative

namespace AlmostLossless

open Finset

variable {α : Type*} [Fintype α] [DecidableEq α]

/-! ## The sharpened converse: soundness costs one codeword -/

/-- **The price of error detection.**  If a sound code of codeword length `≤ t`
fails on at least one source, then the failing source's codeword can decode to
nothing, so it is *not* available for the good set: at most `2 ^ (t+1) - 2`
sources are decodable. -/
theorem card_goodSet_add_two_le {c : Code α} (hs : Sound c) {t : ℕ} (ht : LengthBound c t)
    (hne : goodSet c ≠ univ) : (goodSet c).card + 2 ≤ 2 ^ (t + 1) := by
  obtain ⟨x, -, hx⟩ : ∃ x : α, x ∈ univ ∧ x ∉ goodSet c := by
    by_contra hcon
    push_neg at hcon
    exact hne (Finset.eq_univ_of_forall fun a => hcon a (Finset.mem_univ a))
  -- the codeword of `x` is distinct from all codewords of the good set
  have hnotim : c.enc x ∉ (goodSet c).image c.enc := by
    intro hmem
    obtain ⟨y, hy, hxy⟩ := Finset.mem_image.mp hmem
    have hdec : c.dec (c.enc x) = some y := by
      rw [← hxy]
      exact (mem_goodSet).1 hy
    have : y = x := hs x y hdec
    exact hx (this ▸ hy)
  have hsub : insert (c.enc x) ((goodSet c).image c.enc) ⊆ CompressionDelta.shortStrings t := by
    intro w hw
    rcases Finset.mem_insert.mp hw with rfl | hw'
    · exact (CompressionDelta.mem_shortStrings t _).2 (ht x)
    · obtain ⟨y, -, rfl⟩ := Finset.mem_image.mp hw'
      exact (CompressionDelta.mem_shortStrings t _).2 (ht y)
  have hcardim : ((goodSet c).image c.enc).card = (goodSet c).card :=
    Finset.card_image_of_injOn (injOn_enc_goodSet hs)
  have hcard : (insert (c.enc x) ((goodSet c).image c.enc)).card = (goodSet c).card + 1 := by
    rw [Finset.card_insert_of_notMem hnotim, hcardim]
  have hle := Finset.card_le_card hsub
  rw [hcard] at hle
  have := CompressionDelta.card_shortStrings t
  omega

/-! ## Matching constructions -/

omit [Fintype α] in
/-- An injection of `S` into the bitstrings of length `≤ t`, given the counting
condition. -/
theorem exists_injOn_shortStrings (S : Finset α) (t : ℕ)
    (h : S.card ≤ (CompressionDelta.shortStrings t).card) :
    ∃ f : α → List Bool, Set.InjOn f S ∧ ∀ x ∈ S, f x ∈ CompressionDelta.shortStrings t := by
  classical
  obtain ⟨T, hTsub, hTcard⟩ := Finset.exists_subset_card_eq h
  have hequiv : (S : Finset α) ≃ (T : Finset (List Bool)) := Finset.equivOfCardEq hTcard.symm
  refine ⟨fun x => if hx : x ∈ S then ((hequiv ⟨x, hx⟩ : T) : List Bool) else [], ?_, ?_⟩
  · intro x hx y hy hxy
    simp only [Finset.mem_coe] at hx hy
    dsimp only at hxy
    rw [dif_pos hx, dif_pos hy] at hxy
    have : hequiv ⟨x, hx⟩ = hequiv ⟨y, hy⟩ := Subtype.ext hxy
    have := hequiv.injective this
    exact congrArg Subtype.val this
  · intro x hx
    dsimp only
    rw [dif_pos hx]
    exact hTsub (hequiv ⟨x, hx⟩).2

/-- **Construction, total case.**  If all of `α` fits into the bitstrings of length
`≤ t`, there is a sound code of length `t` that never fails. -/
theorem exists_sound_code_total (t : ℕ) (h : Fintype.card α + 1 ≤ 2 ^ (t + 1)) :
    ∃ c : Code α, Sound c ∧ LengthBound c t ∧ goodSet c = univ := by
  classical
  have hcard : (univ : Finset α).card ≤ (CompressionDelta.shortStrings t).card := by
    have := CompressionDelta.card_shortStrings t
    simp only [Finset.card_univ]
    omega
  obtain ⟨f, hinj, hmaps⟩ := exists_injOn_shortStrings (univ : Finset α) t hcard
  refine ⟨⟨f, fun w => if hw : ∃ x : α, f x = w then some hw.choose else none⟩, ?_, ?_, ?_⟩
  · intro x y hxy
    have hex : ∃ z : α, f z = f x := ⟨x, rfl⟩
    dsimp only at hxy
    simp only [dif_pos hex] at hxy
    have hchoose : f hex.choose = f x := hex.choose_spec
    have : hex.choose = x := hinj (by simp) (by simp) hchoose
    rw [← Option.some_inj.mp hxy, this]
  · intro x
    show (f x).length ≤ t
    exact (CompressionDelta.mem_shortStrings t _).1 (hmaps x (Finset.mem_univ x))
  · ext x
    simp only [mem_goodSet, Decodes, Finset.mem_univ, iff_true]
    have hex : ∃ z : α, f z = f x := ⟨x, rfl⟩
    show (if hw : ∃ z : α, f z = f x then some hw.choose else none) = some x
    rw [dif_pos hex]
    have hchoose : f hex.choose = f x := hex.choose_spec
    rw [hinj (by simp) (by simp) hchoose]

/-- **Construction, partial case.**  If `S` plus one spare codeword fits into the
bitstrings of length `≤ t`, there is a sound code of length `t` whose good set is
exactly `S`; the spare codeword is the explicit failure marker. -/
theorem exists_sound_code_partial (S : Finset α) (t : ℕ) (h : S.card + 2 ≤ 2 ^ (t + 1)) :
    ∃ c : Code α, Sound c ∧ LengthBound c t ∧ goodSet c = S := by
  classical
  have hshort := CompressionDelta.card_shortStrings t
  have hcard : S.card ≤ (CompressionDelta.shortStrings t).card := by omega
  obtain ⟨f, hinj, hmaps⟩ := exists_injOn_shortStrings S t hcard
  -- a spare bitstring outside the image of `S`
  have hlt : (S.image f).card < (CompressionDelta.shortStrings t).card := by
    have : (S.image f).card ≤ S.card := Finset.card_image_le
    omega
  obtain ⟨w₀, hw₀short, hw₀⟩ := Finset.exists_mem_notMem_of_card_lt_card hlt
  set enc : α → List Bool := fun x => if x ∈ S then f x else w₀ with hencdef
  have henc_mem : ∀ x ∈ S, enc x = f x := by intro x hx; simp [hencdef, hx]
  have henc_not : ∀ x ∉ S, enc x = w₀ := by intro x hx; simp [hencdef, hx]
  have hw₀_not_image : ∀ y ∈ S, f y ≠ w₀ := by
    intro y hy hcon
    exact hw₀ (by rw [← hcon]; exact Finset.mem_image_of_mem f hy)
  refine ⟨⟨enc, fun w => if hw : ∃ x ∈ S, f x = w then some hw.choose else none⟩, ?_, ?_, ?_⟩
  · -- soundness
    intro x y hxy
    dsimp only at hxy
    by_cases hx : x ∈ S
    · have hex : ∃ z ∈ S, f z = enc x := ⟨x, hx, (henc_mem x hx).symm⟩
      simp only [dif_pos hex] at hxy
      obtain ⟨hchoose_mem, hchoose_eq⟩ := hex.choose_spec
      have : hex.choose = x := by
        refine hinj hchoose_mem hx ?_
        rw [hchoose_eq, henc_mem x hx]
      rw [← Option.some_inj.mp hxy, this]
    · have hnex : ¬ ∃ z ∈ S, f z = enc x := by
        rintro ⟨z, hz, hfz⟩
        rw [henc_not x hx] at hfz
        exact hw₀_not_image z hz hfz
      simp only [dif_neg hnex] at hxy
      exact absurd hxy (by simp)
  · -- length bound
    intro x
    show (enc x).length ≤ t
    by_cases hx : x ∈ S
    · rw [henc_mem x hx]
      exact (CompressionDelta.mem_shortStrings t _).1 (hmaps x hx)
    · rw [henc_not x hx]
      exact (CompressionDelta.mem_shortStrings t _).1 hw₀short
  · -- good set
    ext x
    simp only [mem_goodSet, Decodes]
    constructor
    · intro hdec
      by_contra hx
      have hnex : ¬ ∃ z ∈ S, f z = enc x := by
        rintro ⟨z, hz, hfz⟩
        rw [henc_not x hx] at hfz
        exact hw₀_not_image z hz hfz
      rw [dif_neg hnex] at hdec
      exact absurd hdec (by simp)
    · intro hx
      have hex : ∃ z ∈ S, f z = enc x := ⟨x, hx, (henc_mem x hx).symm⟩
      show (if hw : ∃ z ∈ S, f z = enc x then some hw.choose else none) = some x
      rw [dif_pos hex]
      obtain ⟨hchoose_mem, hchoose_eq⟩ := hex.choose_spec
      have : hex.choose = x := by
        refine hinj hchoose_mem hx ?_
        rw [hchoose_eq, henc_mem x hx]
      rw [this]

/-! ## The exact characterisation -/

/-- **Exactly which sets are good sets.**  For a proper subset `S ⊊ α` the answer
is `|S| + 2 ≤ 2 ^ (t+1)` — the extra unit is the failure marker demanded by
soundness — and for `S = α` it is `|α| + 1 ≤ 2 ^ (t+1)`. -/
theorem sound_code_exists_iff (S : Finset α) (t : ℕ) (hne : S ≠ univ) :
    (∃ c : Code α, Sound c ∧ LengthBound c t ∧ goodSet c = S) ↔ S.card + 2 ≤ 2 ^ (t + 1) := by
  constructor
  · rintro ⟨c, hs, ht, hgood⟩
    have := card_goodSet_add_two_le hs ht (by rw [hgood]; exact hne)
    rwa [hgood] at this
  · exact exists_sound_code_partial S t

/-- **The optimal ε-almost-lossless rate.**  A sound code of length `t` with
failure probability `≤ ε` exists precisely when the source has an `(1-ε)`-heavy set
that fits, with its failure marker, into the bitstrings of length `≤ t`. -/
theorem optimal_rate_iff {p : α → ℝ} (hsum : ∑ x, p x = 1) (t : ℕ) (ε : ℝ) :
    (∃ c : Code α, Sound c ∧ LengthBound c t ∧ failProb p c ≤ ε) ↔
      (∃ S : Finset α, (S = univ ∧ S.card + 1 ≤ 2 ^ (t + 1) ∨ S.card + 2 ≤ 2 ^ (t + 1)) ∧
        1 - ε ≤ ∑ x ∈ S, p x) := by
  constructor
  · rintro ⟨c, hs, ht, hfail⟩
    refine ⟨goodSet c, ?_, ?_⟩
    · by_cases hu : goodSet c = univ
      · exact Or.inl ⟨hu, card_goodSet_le hs ht⟩
      · exact Or.inr (card_goodSet_add_two_le hs ht hu)
    · rw [mass_goodSet hsum]
      linarith
  · rintro ⟨S, hcase, hmass⟩
    have hbuild : ∃ c : Code α, Sound c ∧ LengthBound c t ∧ goodSet c = S := by
      rcases hcase with ⟨hu, hc⟩ | hc
      · subst hu
        obtain ⟨c, hs, ht, hgood⟩ := exists_sound_code_total (α := α) t (by
          simpa [Finset.card_univ] using hc)
        exact ⟨c, hs, ht, hgood⟩
      · exact exists_sound_code_partial S t hc
    obtain ⟨c, hs, ht, hgood⟩ := hbuild
    refine ⟨c, hs, ht, ?_⟩
    have hmg : ∑ x ∈ goodSet c, p x = 1 - failProb p c := mass_goodSet hsum c
    rw [hgood] at hmg
    linarith

/-- **The explicit scheme is near-optimal.**  The optimum at codeword length `t`
serves `2 ^ (t+1) - 2` sources; the linear-time enumerative code of
`Enumerative.enumCode` serves `2 ^ k` sources with codewords of length `k + 1`.
Hence for every typical set that the optimal code of length `t` can serve, the
enumerative code serves it with at most `t + 2` bits: at most two bits of
redundancy buys a decoder that is exponentially faster. -/
theorem enumCode_within_two_bits (S : Finset α) (t : ℕ) (h : S.card + 2 ≤ 2 ^ (t + 1)) :
    Sound (enumCode S (t + 1)) ∧ LengthBound (enumCode S (t + 1)) (t + 2) ∧
      goodSet (enumCode S (t + 1)) = S := by
  have hcard : S.card ≤ 2 ^ (t + 1) := by omega
  exact ⟨enumCode_sound S (t + 1) hcard, enumCode_lengthBound S (t + 1),
    goodSet_enumCode S (t + 1) hcard⟩

end AlmostLossless