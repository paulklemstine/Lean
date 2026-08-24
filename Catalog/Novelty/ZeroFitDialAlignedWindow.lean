import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialExactBitlen48

/-!
# Dyadic-scale invariance of the zero-fit dial's tie ceiling

## Research context (FACT round-57 #1, exp 527, third cycle)

Cycle 1 (`Novelty.ZeroFitDialExactBitlen48`) showed that uniform sampling at
*exact* bitlen `b+1` — i.e. uniform on `[2^b, 2^(b+1))` — gives the trailing-zero
statistic exactly the dyadic tie profile of full-range bitlen `b`.  The natural
question is whether this is an accident of that particular window.

It is not.  This file proves the general **dyadic-scale invariance**: for *every*
aligned window `[c·2^s, (c+1)·2^s)`, whatever the offset `c`, the trailing-zero
tie profile is the same list `dyadicBlocks s`.  The ceiling of the dial therefore
depends on the *scale* of the sampling window and on nothing else — not on its
position, not on the magnitude of the integers drawn.

## Main results

* `alignedBlock_eq_image` — for `k < s`, translation by `c·2^s` is a bijection
  between the `k`-th 2-adic block of `[0, 2^s)` and that of `[c·2^s,(c+1)·2^s)`
  (valuations below `s` are invariant modulo `2^s`).
* `card_alignedBlock`, `alignedCap_eq_singleton` — the resulting block sizes:
  `2^(s-1-k)` for `k < s`, plus one exceptional point `c·2^s`.
* `alignedProfile_eq_dyadicBlocks` — **the invariance theorem**: the tie profile
  of any aligned window of scale `s` is `dyadicBlocks s`.
* `aligned_ceiling_invariant`, `aligned_ceiling_closed_form` — hence all windows
  of a common scale share one ceiling, in closed form
  `(6/7)·(1 + 1/(2^s(2^s+1)))`.
* `alignedProfile_one_eq_windowProfile`, `round57_window_placement_irrelevant`
  — the round-57 exact-bitlen-48 cell is the case `c = 1, s = 47`, and any other
  placement of a `2^47`-long aligned window would have exactly the same ceiling.

## Sequel

`Novelty.ZeroFitDialTranslationInvariance` drops the alignment hypothesis
altogether: *every* window of `2^s` consecutive integers has this profile.  The
aligned case proved here is the structurally transparent one — translation by a
multiple of `2^s` preserves valuations below `s` outright — and is recovered
there as `aligned_is_special_case`.

## The scientific payload

`round57_window_placement_irrelevant` removes an entire class of candidate
explanations for the seed-to-seed spread `0.7291 / 0.7286 / 0.7087`: sampling
window placement is *provably* invisible to the tie geometry, so the spread is
sampling noise or response-side structure, never window arithmetic.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Novelty.ZeroFitDialExactBitlen48

namespace Catalog.Novelty.ZeroFitDialAlignedWindow

/-! ## 1. Aligned windows and their 2-adic blocks -/

/-- The aligned dyadic window `[c·2^s, (c+1)·2^s)` of scale `s` and offset `c`. -/
def alignedWindow (c s : ℕ) : Finset ℕ := Finset.Ico (c * 2 ^ s) ((c + 1) * 2 ^ s)

/-- The `k`-th trailing-zero block of an aligned window. -/
def alignedBlock (c s k : ℕ) : Finset ℕ :=
  (alignedWindow c s).filter fun x => 2 ^ k ∣ x ∧ ¬ 2 ^ (k + 1) ∣ x

/-- The exceptional ("cap") block: the points of the window divisible by `2^s`. -/
def alignedCap (c s : ℕ) : Finset ℕ := (alignedWindow c s).filter fun x => 2 ^ s ∣ x

/-- **Translation invariance of low valuations.**  For `k < s`, adding `c·2^s` maps the
`k`-th 2-adic block of `[0,2^s)` bijectively onto the `k`-th block of the aligned window. -/
theorem alignedBlock_eq_image (c s k : ℕ) (hk : k < s) :
    alignedBlock c s k = (twoAdicBlock s k).image fun x => x + c * 2 ^ s := by
  have hdvd : (2 : ℕ) ^ (k + 1) ∣ 2 ^ s := pow_dvd_pow 2 (by omega)
  have hdvd' : (2 : ℕ) ^ k ∣ 2 ^ s := pow_dvd_pow 2 (by omega)
  ext y
  simp only [alignedBlock, alignedWindow, twoAdicBlock, mem_filter, Finset.mem_Ico, mem_image,
    mem_range]
  constructor
  · rintro ⟨⟨hlo, hhi⟩, hd1, hd2⟩
    refine ⟨y - c * 2 ^ s, ⟨?_, ?_, ?_⟩, by omega⟩
    · have : (c + 1) * 2 ^ s = c * 2 ^ s + 2 ^ s := by ring
      omega
    · exact Nat.dvd_sub hd1 (Dvd.dvd.mul_left hdvd' c)
    · intro hcon
      exact hd2 (by
        have : y = (y - c * 2 ^ s) + c * 2 ^ s := by omega
        rw [this]
        exact Nat.dvd_add hcon (Dvd.dvd.mul_left hdvd c))
  · rintro ⟨x, ⟨hx, hd1, hd2⟩, rfl⟩
    refine ⟨⟨by omega, ?_⟩, Nat.dvd_add hd1 (Dvd.dvd.mul_left hdvd' c), ?_⟩
    · have : (c + 1) * 2 ^ s = c * 2 ^ s + 2 ^ s := by ring
      omega
    · intro hcon
      exact hd2 ((Nat.dvd_add_iff_left (Dvd.dvd.mul_left hdvd c)).2 hcon)

/-- Block sizes in an aligned window of scale `s`: `2^(s-1-k)` for every `k < s`, exactly as
in the full range `[0,2^s)`. -/
theorem card_alignedBlock (c s k : ℕ) (hk : k < s) :
    (alignedBlock c s k).card = 2 ^ (s - 1 - k) := by
  rw [alignedBlock_eq_image c s k hk, card_image_of_injective _ (add_left_injective _),
    card_two_adic_block s k hk]

/-- The cap block of an aligned window is the single point `c·2^s`. -/
theorem alignedCap_eq_singleton (c s : ℕ) : alignedCap c s = {c * 2 ^ s} := by
  ext x
  simp only [alignedCap, alignedWindow, mem_filter, Finset.mem_Ico, Finset.mem_singleton]
  constructor
  · rintro ⟨⟨hlo, hhi⟩, u, rfl⟩
    have hps : 0 < 2 ^ s := Nat.two_pow_pos s
    have h1 : c ≤ u := by
      by_contra hcon
      push_neg at hcon
      have : 2 ^ s * u < c * 2 ^ s := by
        calc 2 ^ s * u = u * 2 ^ s := by ring
          _ < c * 2 ^ s := (Nat.mul_lt_mul_right hps).2 hcon
      omega
    have h2 : u < c + 1 := by
      by_contra hcon
      push_neg at hcon
      have : (c + 1) * 2 ^ s ≤ 2 ^ s * u := by
        calc (c + 1) * 2 ^ s ≤ u * 2 ^ s := Nat.mul_le_mul_right _ hcon
          _ = 2 ^ s * u := by ring
      omega
    have : u = c := by omega
    rw [this]; ring
  · rintro rfl
    have hps : 0 < 2 ^ s := Nat.two_pow_pos s
    refine ⟨⟨le_refl _, ?_⟩, ⟨c, by ring⟩⟩
    have : (c + 1) * 2 ^ s = c * 2 ^ s + 2 ^ s := by ring
    omega

/-- Tie profile of the trailing-zero statistic on an aligned window of scale `s`. -/
def alignedProfile (c s : ℕ) : List ℕ :=
  ((List.range s).map fun k => (alignedBlock c s k).card) ++ [(alignedCap c s).card]

/-- **Dyadic-scale invariance.**  The tie profile of the trailing-zero statistic on *any*
aligned window of scale `s` is `dyadicBlocks s`, independently of the offset `c`. -/
theorem alignedProfile_eq_dyadicBlocks (c s : ℕ) : alignedProfile c s = dyadicBlocks s := by
  rw [alignedProfile, dyadicBlocks_eq_formula]
  congr 1
  · exact List.map_congr_left fun k hk => card_alignedBlock c s k (List.mem_range.1 hk)
  · rw [alignedCap_eq_singleton]; simp

/-- All aligned windows of a common scale have exactly the same tie ceiling. -/
theorem aligned_ceiling_invariant (c c' s : ℕ) :
    spearmanSq (alignedProfile c s) = spearmanSq (alignedProfile c' s) := by
  rw [alignedProfile_eq_dyadicBlocks, alignedProfile_eq_dyadicBlocks]

/-- Closed form of the common ceiling of all scale-`s` aligned windows. -/
theorem aligned_ceiling_closed_form (c s : ℕ) (hs : 1 ≤ s) :
    spearmanSq (alignedProfile c s) = (6 / 7) * (1 + 1 / ((2 : ℚ) ^ s * (2 ^ s + 1))) := by
  rw [alignedProfile_eq_dyadicBlocks]
  exact dyadic_spearmanSq s hs

/-- The exact-bitlen window of cycle 1 is the aligned window with offset `c = 1`. -/
theorem alignedProfile_one_eq_windowProfile (s : ℕ) :
    alignedProfile 1 s = windowProfile s := by
  rw [alignedProfile_eq_dyadicBlocks, windowProfile_eq_dyadicBlocks]

/-- The full range `[0,2^s)` of the earlier catalog work is the offset `c = 0` case. -/
theorem alignedProfile_zero_eq_dyadic (s : ℕ) : alignedProfile 0 s = dyadicBlocks s :=
  alignedProfile_eq_dyadicBlocks 0 s

/-- **Window placement is invisible to the dial.**  The round-57 cell samples the aligned
window of scale 47 with offset 1; every other placement of a scale-47 window — and the
full range `[0,2^47)` itself — carries the identical tie ceiling, so no part of the
recorded seed spread can be attributed to where the sampling window sits. -/
theorem round57_window_placement_irrelevant (c : ℕ) :
    spearmanSq (alignedProfile c 47) = spearmanSq (windowProfile 47) ∧
    spearmanSq (alignedProfile c 47) = (6 / 7) * (1 + 1 / ((2 : ℚ) ^ 47 * (2 ^ 47 + 1))) := by
  refine ⟨?_, aligned_ceiling_closed_form c 47 (by norm_num)⟩
  rw [alignedProfile_eq_dyadicBlocks, windowProfile_eq_dyadicBlocks]

end Catalog.Novelty.ZeroFitDialAlignedWindow