/-
Copyright (c) 2025 Non-Archimedean Information Theory Project. All rights reserved.

# Almost-Lossless Compression IX: Sub-linear Monte-Carlo Compression

## Bridge: Universal hashing (algebra) ↔ sorting/order theory ↔ verified complexity

This file combines the probabilistic analysis of
`AlmostLosslessRandomCoding` / `AlmostLosslessSharpSilent` with the logarithmic
decoder of `AlmostLosslessBinarySearch`, resolving Conjecture 1 of the previous
cycle in a **corrected** form.

The conjecture asked for a hash family that is simultaneously 2-universal and
monotone on every codebook.  That extra requirement is unnecessary: the encoder
picks the key *first* and then stores the codebook **sorted by hash value**
(`sortedCodebook`).  Sorting is a permutation of the codebook, so the entire
collision analysis is untouched, while the decoder becomes a binary search plus
two neighbour comparisons.

Main results:

* `sortedKey_mono` — the hash values along the sorted codebook are monotone;
* `bsHashScheme_succeeds`, `bsHashScheme_neverSilent_on_codebook` — the
  logarithmic decoder is correct on collision-free codebook symbols and never
  lies on a codebook symbol;
* `exists_sublinear_almost_lossless_scheme` — **the deliverable**: an explicit
  key with failure probability `≤ δ + 2|l|/M`, silent-corruption probability
  `≤ 2δ|l|/M`, and decoding cost at most `log₂|l| + 3` key evaluations instead
  of `|l|`;
* `sublinear_speedup` — the cost separation `log₂ n + 3 < n` for `n ≥ 6`.

## Impact: sublinear_almost_lossless, sorted_codebook_decoding
-/

import Mathlib
import Bridges.AlmostLosslessSharpSilent
import Bridges.AlmostLosslessLinearHash
import Bridges.AlmostLosslessBinarySearch

open Finset BigOperators NonArchInfoTheory

namespace AlmostLossless

section Sorted

variable {α : Type*} [Nonempty α] {M : ℕ}

/-- The codebook stored in increasing order of hash value.  Sorting happens
*after* the key is chosen, so it is a permutation of the codebook and changes
nothing in the probabilistic analysis. -/
def sortedCodebook (h : α → Fin M) (l : List α) : List α :=
  l.mergeSort (fun x y => decide ((h x).val ≤ (h y).val))

omit [Nonempty α] in
theorem sortedCodebook_perm (h : α → Fin M) (l : List α) :
    (sortedCodebook h l).Perm l := List.mergeSort_perm _ _

omit [Nonempty α] in
@[simp] theorem sortedCodebook_length (h : α → Fin M) (l : List α) :
    (sortedCodebook h l).length = l.length := List.length_mergeSort _

omit [Nonempty α] in
theorem mem_sortedCodebook {h : α → Fin M} {l : List α} {x : α} :
    x ∈ sortedCodebook h l ↔ x ∈ l := (sortedCodebook_perm h l).mem_iff

omit [Nonempty α] in
theorem sortedCodebook_nodup {h : α → Fin M} {l : List α} (hnd : l.Nodup) :
    (sortedCodebook h l).Nodup := (sortedCodebook_perm h l).nodup_iff.mpr hnd

omit [Nonempty α] in
theorem sortedCodebook_pairwise (h : α → Fin M) (l : List α) :
    List.Pairwise (fun x y => (h x).val ≤ (h y).val) (sortedCodebook h l) := by
  have htrans : ∀ a b c : α, (decide ((h a).val ≤ (h b).val)) = true →
      (decide ((h b).val ≤ (h c).val)) = true → (decide ((h a).val ≤ (h c).val)) = true := by
    intro a b c hab hbc
    simp only [decide_eq_true_eq] at *
    omega
  have htotal : ∀ a b : α,
      (decide ((h a).val ≤ (h b).val) || decide ((h b).val ≤ (h a).val)) = true := by
    intro a b
    simp only [Bool.or_eq_true, decide_eq_true_eq]
    omega
  have := List.pairwise_mergeSort htrans htotal l
  refine List.Pairwise.imp ?_ this
  intro a b hab
  simpa using hab

/-- The `i`-th codebook symbol in hash order. -/
noncomputable def sortedIndex (h : α → Fin M) (l : List α) (i : ℕ) : α :=
  (sortedCodebook h l).getD i (Classical.arbitrary α)

/-- The hash value of the `i`-th codebook symbol, as a natural number. -/
noncomputable def sortedKey (h : α → Fin M) (l : List α) (i : ℕ) : ℕ :=
  (h (sortedIndex h l i)).val

theorem sortedIndex_eq_getElem {h : α → Fin M} {l : List α} {i : ℕ}
    (hi : i < l.length) :
    sortedIndex h l i = (sortedCodebook h l)[i]'(by simpa using hi) := by
  unfold sortedIndex
  exact List.getD_eq_getElem _ _ (by simpa using hi)

theorem sortedIndex_mem {h : α → Fin M} {l : List α} {i : ℕ} (hi : i < l.length) :
    sortedIndex h l i ∈ l := by
  rw [sortedIndex_eq_getElem hi]
  exact mem_sortedCodebook.mp (List.getElem_mem _)

theorem sortedIndex_injOn {h : α → Fin M} {l : List α} (hnd : l.Nodup) {i j : ℕ}
    (hi : i < l.length) (hj : j < l.length)
    (hij : sortedIndex h l i = sortedIndex h l j) : i = j := by
  rw [sortedIndex_eq_getElem hi, sortedIndex_eq_getElem hj] at hij
  exact (List.Nodup.getElem_inj_iff (sortedCodebook_nodup hnd)).mp hij

theorem exists_sortedIndex {h : α → Fin M} {l : List α} {x : α} (hx : x ∈ l) :
    ∃ j, j < l.length ∧ sortedIndex h l j = x := by
  have hx' : x ∈ sortedCodebook h l := mem_sortedCodebook.mpr hx
  obtain ⟨j, hj, hjx⟩ := List.getElem_of_mem hx'
  refine ⟨j, by simpa using hj, ?_⟩
  rw [sortedIndex_eq_getElem (by simpa using hj)]
  exact hjx

/-- **The codebook is monotone in hash value.**  This is the order-theoretic
input the binary search needs, and it holds by construction — no assumption on
the hash family. -/
theorem sortedKey_mono (h : α → Fin M) (l : List α) :
    ∀ i i' : ℕ, i ≤ i' → i' < l.length → sortedKey h l i ≤ sortedKey h l i' := by
  intro i i' hle hi'
  rcases eq_or_lt_of_le hle with rfl | hlt
  · exact le_rfl
  · have hi : i < l.length := lt_of_lt_of_le hlt (le_of_lt hi')
    have hp := sortedCodebook_pairwise h l
    rw [List.pairwise_iff_getElem] at hp
    have := hp i i' (by simpa using hi) (by simpa using hi') hlt
    unfold sortedKey
    rw [sortedIndex_eq_getElem hi, sortedIndex_eq_getElem hi']
    exact this

/-! ## The sub-linear scheme -/

/-- The compression scheme with the logarithmic decoder: encode by hashing,
decode by binary search over the hash-sorted codebook plus two neighbour
comparisons (which force abstention on a duplicate hash value). -/
noncomputable def bsHashScheme (h : α → Fin M) (l : List α) : Scheme α (Fin M) where
  enc := h
  dec := fun i =>
    (bsDecode (sortedKey h l) (sortedIndex h l) l.length i.val).1

/-- **Exact decoding cost**: `log₂|l| + 3` key evaluations per query. -/
theorem bsHashScheme_cost (h : α → Fin M) (l : List α) (i : Fin M) :
    (bsDecode (sortedKey h l) (sortedIndex h l) l.length i.val).2
      ≤ Nat.log 2 l.length + 3 :=
  bsDecode_cost_le _ _ _ _

end Sorted

section Probabilistic

variable {α : Type*} [Fintype α] [DecidableEq α] [Nonempty α] {M : ℕ}

omit [Fintype α] in
/-- Collision-free codebook symbols are decoded exactly by the binary-search
decoder. -/
theorem bsHashScheme_succeeds {h : α → Fin M} {l : List α} {x : α}
    (hnd : l.Nodup) (hx : x ∈ l)
    (hnc : ¬ ∃ y ∈ l.toFinset, y ≠ x ∧ h y = h x) :
    (bsHashScheme h l).Succeeds x := by
  obtain ⟨j, hj, hjx⟩ := exists_sortedIndex (h := h) hx
  have huniq : ∀ i < l.length, sortedKey h l i = sortedKey h l j → i = j := by
    intro i hi hkey
    have hh : h (sortedIndex h l i) = h (sortedIndex h l j) := by
      apply Fin.val_injective
      exact hkey
    have hmem : sortedIndex h l i ∈ l := sortedIndex_mem hi
    have : sortedIndex h l i = x := by
      by_contra hne
      exact hnc ⟨sortedIndex h l i, List.mem_toFinset.mpr hmem, hne, by rw [hh, hjx]⟩
    exact sortedIndex_injOn hnd hi hj (by rw [this, hjx])
  have hdec := bsDecode_eq_some_of_unique (a := sortedIndex h l)
    (sortedKey_mono h l) hj huniq
  show (bsHashScheme h l).dec ((bsHashScheme h l).enc x) = some x
  simp only [bsHashScheme]
  have hkeyx : sortedKey h l j = (h x).val := by
    unfold sortedKey; rw [hjx]
  rw [← hkeyx, hdec, hjx]

omit [Fintype α] [DecidableEq α] in
/-- Whatever the hash, the binary-search decoder never returns a *wrong*
codebook symbol: the uniqueness check makes it abstain instead. -/
theorem bsHashScheme_neverSilent_on_codebook {h : α → Fin M} {l : List α} {x : α}
    (hx : x ∈ l) : ¬ (bsHashScheme h l).SilentError x := by
  rintro ⟨y, hy, hne⟩
  obtain ⟨j, hj, hjx⟩ := exists_sortedIndex (h := h) hx
  have hkeyx : sortedKey h l j = (h x).val := by
    unfold sortedKey; rw [hjx]
  have hy' : (bsDecode (sortedKey h l) (sortedIndex h l) l.length
      (sortedKey h l j)).1 = some y := by
    rw [hkeyx]; exact hy
  have := bsDecode_never_wrong (a := sortedIndex h l) (sortedKey_mono h l) hj hy'
  rw [hjx] at this
  exact hne this

omit [Fintype α] in
/-- A silent error can only be caused by a codebook collision. -/
theorem bsHashScheme_silentError_imp_collides {h : α → Fin M} {l : List α} {x : α}
    (hs : (bsHashScheme h l).SilentError x) :
    ∃ y ∈ l.toFinset, y ≠ x ∧ h y = h x := by
  obtain ⟨y, hy, hne⟩ := hs
  obtain ⟨m, hmn, hym, hkm, _⟩ := bsDecode_sound (key := sortedKey h l)
    (a := sortedIndex h l) (n := l.length) (t := (h x).val) hy
  refine ⟨y, List.mem_toFinset.mpr ?_, hne, ?_⟩
  · rw [hym]; exact sortedIndex_mem hmn
  · rw [hym]
    apply Fin.val_injective
    exact hkm

/-- **Sub-linear Monte-Carlo compression (settles Conjecture 1).**

There is an explicit key `k` of the 2-universal family such that the scheme
`bsHashScheme (H k) l`:

1. fails with probability at most `δ + 2|l|/M`;
2. corrupts silently with probability at most `2δ|l|/M`, and never at all on the
   codebook (`bsHashScheme_neverSilent_on_codebook`);
3. decodes in at most `log₂|l| + 3` key evaluations — **exponentially** fewer
   than the `|l|` of the linear scan.

No new hypothesis on the hash family is used: only that it is 2-universal. -/
theorem exists_sublinear_almost_lossless_scheme {K : ℕ} (μ : FinProbDist α)
    {H : Fin K → α → Fin M} (hU : Universal2 H) (hK : 0 < K) (hM : 0 < M)
    (l : List α) (hnd : l.Nodup) (δ : ℝ) (hδ : setMass μ (l.toFinset)ᶜ ≤ δ) :
    ∃ k : Fin K,
      setMass μ (Finset.univ.filter (fun x => ¬ (bsHashScheme (H k) l).Succeeds x))
          ≤ δ + 2 * (l.length : ℝ) / M
      ∧ setMass μ (Finset.univ.filter
            (fun x => (bsHashScheme (H k) l).SilentError x))
          ≤ 2 * δ * (l.length : ℝ) / M
      ∧ ∀ i : Fin M,
          (bsDecode (sortedKey (H k) l) (sortedIndex (H k) l) l.length i.val).2
            ≤ Nat.log 2 l.length + 3 := by
  classical
  obtain ⟨k, hsilent, hall⟩ := exists_doubly_good_key μ hU hK l.toFinset
  have hMR : (0 : ℝ) < M := by exact_mod_cast hM
  have hcard : (l.toFinset.card : ℝ) = (l.length : ℝ) := by
    rw [List.toFinset_card_of_nodup hnd]
  refine ⟨k, ?_, ?_, fun i => bsHashScheme_cost (H k) l i⟩
  · set C : Finset α := Finset.univ.filter (fun x => Collides H k l.toFinset x) with hC
    have hCbound : setMass μ C ≤ 2 * (l.length : ℝ) / M := by
      rw [le_div_iff₀ hMR]
      nlinarith [hall, hcard]
    have hsub : Finset.univ.filter (fun x => ¬ (bsHashScheme (H k) l).Succeeds x)
        ⊆ (l.toFinset)ᶜ ∪ C := by
      intro x hx
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
      rw [Finset.mem_union]
      by_cases hxl : x ∈ l.toFinset
      · right
        rw [hC, Finset.mem_filter]
        refine ⟨Finset.mem_univ _, ?_⟩
        rw [collides_iff]
        by_contra hnc
        exact hx (bsHashScheme_succeeds hnd (List.mem_toFinset.mp hxl) hnc)
      · left; exact Finset.mem_compl.mpr hxl
    calc setMass μ (Finset.univ.filter (fun x => ¬ (bsHashScheme (H k) l).Succeeds x))
        ≤ setMass μ ((l.toFinset)ᶜ ∪ C) := setMass_mono μ hsub
      _ ≤ setMass μ (l.toFinset)ᶜ + setMass μ C := setMass_union_le μ _ _
      _ ≤ δ + 2 * (l.length : ℝ) / M := add_le_add hδ hCbound
  · set D : Finset α := (l.toFinset)ᶜ.filter (fun x => Collides H k l.toFinset x)
      with hD
    have hsub : Finset.univ.filter
        (fun x => (bsHashScheme (H k) l).SilentError x) ⊆ D := by
      intro x hx
      simp only [Finset.mem_filter, Finset.mem_univ, true_and] at hx
      rw [hD, Finset.mem_filter]
      refine ⟨Finset.mem_compl.mpr ?_,
        collides_iff.mpr (bsHashScheme_silentError_imp_collides hx)⟩
      intro hxl
      exact bsHashScheme_neverSilent_on_codebook (List.mem_toFinset.mp hxl) hx
    have hcardnn : (0 : ℝ) ≤ (l.length : ℝ) := Nat.cast_nonneg _
    have hDb : (M : ℝ) * setMass μ D ≤ 2 * (l.length : ℝ) * δ := by
      have h1 : (M : ℝ) * setMass μ D
          ≤ 2 * (l.toFinset.card : ℝ) * setMass μ (l.toFinset)ᶜ := hsilent
      have h2 : 2 * (l.toFinset.card : ℝ) * setMass μ (l.toFinset)ᶜ
          ≤ 2 * (l.length : ℝ) * δ := by
        rw [hcard]
        nlinarith [hδ, hcardnn]
      linarith
    have hfinal : setMass μ D ≤ 2 * δ * (l.length : ℝ) / M := by
      rw [le_div_iff₀ hMR]
      nlinarith [hDb]
    exact le_trans (setMass_mono μ hsub) hfinal

/-- **The complexity separation.**  For every codebook of size at least `6` the
logarithmic decoder is strictly cheaper than the linear scan, and the gap grows
without bound. -/
theorem sublinear_speedup (n : ℕ) (hn : 6 ≤ n) : Nat.log 2 n + 3 < n := by
  induction n using Nat.strong_induction_on with
  | _ n ih =>
    rcases Nat.lt_or_ge n 12 with hsmall | hbig
    · interval_cases n <;> simp_all <;> decide
    · have h2 : 6 ≤ n / 2 := by omega
      have hlt : n / 2 < n := by omega
      have hih := ih (n / 2) hlt h2
      have hlog : Nat.log 2 n = Nat.log 2 (n / 2) + 1 := by
        have hp : 0 < Nat.log 2 n := Nat.log_pos (by norm_num) (by omega)
        rw [Nat.log_div_base]
        omega
      omega

end Probabilistic

/-! ## A concrete instance with explicit figures -/

section ConcreteSublinear

instance : Fact (Nat.Prime 10007) := ⟨by norm_num⟩

/-- **A concrete sub-linear certified compressor.**

Source: `10007² = 100 140 049` symbols (`≈ 27` bits).  Codebook: a `1000`-element
typical set carrying all but `1/100` of the mass.  Code space: `10007` codewords
(`≈ 14` bits).  Then some key `k < 10007` gives

* failure probability `≤ 1/100 + 2000/10007 < 0.21`,
* silent-corruption probability `≤ 20/10007 < 0.002`,
* decoding cost **at most 12** key evaluations per query — against `1000` for the
  linear scan of the same codebook.
-/
theorem concrete_sublinear_almost_lossless
    (μ : FinProbDist (ZMod 10007 × ZMod 10007))
    (l : List (ZMod 10007 × ZMod 10007)) (hnd : l.Nodup) (hlen : l.length = 1000)
    (hδ : setMass μ (l.toFinset)ᶜ ≤ 1 / 100) :
    ∃ k : Fin 10007,
      setMass μ (Finset.univ.filter
          (fun x => ¬ (bsHashScheme (linHash 10007 k) l).Succeeds x))
          ≤ 1 / 100 + 2000 / 10007
      ∧ setMass μ (Finset.univ.filter
          (fun x => (bsHashScheme (linHash 10007 k) l).SilentError x))
          ≤ 20 / 10007
      ∧ ∀ i : Fin 10007,
          (bsDecode (sortedKey (linHash 10007 k) l) (sortedIndex (linHash 10007 k) l)
            l.length i.val).2 ≤ 12 := by
  have hp : 0 < 10007 := by norm_num
  obtain ⟨k, h1, h2, h3⟩ :=
    exists_sublinear_almost_lossless_scheme μ (linHash_universal2 10007) hp hp l hnd
      (1 / 100) hδ
  refine ⟨k, ?_, ?_, fun i => ?_⟩
  · rw [hlen] at h1; push_cast at h1; linarith
  · rw [hlen] at h2; push_cast at h2; linarith
  · have h := h3 i
    rw [hlen] at h ⊢
    have hlog : Nat.log 2 1000 = 9 := by decide
    omega

end ConcreteSublinear

end AlmostLossless