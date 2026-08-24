import Mathlib
import Novelty.ZeroFitDialU64
import Novelty.ZeroFitDialExactBitlen48
import Novelty.ZeroFitDialAlignedWindow

/-!
# Full translation invariance of the zero-fit dial's tie profile

## Research context (FACT round-57 #1, exp 527, fourth cycle)

Cycle 3 (`Novelty.ZeroFitDialAlignedWindow`) proved that every *aligned* dyadic
window `[c·2^s,(c+1)·2^s)` carries the tie profile `dyadicBlocks s`.  The natural
follow-up guess is that dropping alignment perturbs the profile, and hence the
ceiling, by `Θ(2^{-s})`.

That guess is **false**, and the truth is stronger: alignment is irrelevant.
A window of `2^s` consecutive integers starting *anywhere* meets each residue
class mod `2^(k+1)` exactly `2^(s-1-k)` times for every `k < s`, and contains
exactly one multiple of `2^s`.  So the trailing-zero tie profile of *any* window
of length `2^s` is `dyadicBlocks s`.

## Main results

* `modEq_iff_two_adic` — `x ≡ 2^k [MOD 2^(k+1)]` is exactly the statement that
  `x` has precisely `k` trailing binary zeros.
* `card_Ico_modEq` — a window of `M·r` consecutive integers meets each residue
  class mod `r` exactly `M` times (from `Nat.Ico_filter_modEq_card`).
* `card_slidingBlock`, `card_slidingCap` — the block sizes of an arbitrary
  window of length `2^s`: `2^(s-1-k)` for `k < s`, and a single capping point.
* `slidingProfile_eq_dyadicBlocks` — **translation invariance**: the profile of
  any length-`2^s` window is `dyadicBlocks s`, no alignment hypothesis.
* `sliding_ceiling_invariant`, `sliding_ceiling_closed_form` — one ceiling for
  all windows of a given length, in closed form.
* `aligned_is_special_case`, `exact_bitlen_is_special_case` — cycles 1 and 3
  recovered, and `round57_any_window_same_ceiling` for the recorded cell.

## The scientific payload

The tie ceiling of the zero-fit dial is a function of the *sample size* `2^s`
and of nothing else: not of the magnitude of the integers, not of the bitlen
conditioning, not of the alignment or placement of the sampling window.  Any
dependence of the measured dial on those knobs — including the recorded
seed-to-seed spread at exact bitlen 48 — is therefore response-side.
-/

open Finset

open Catalog.Novelty.ZeroFitDialU64
open Catalog.Novelty.ZeroFitDialExactBitlen48
open Catalog.Novelty.ZeroFitDialAlignedWindow

namespace Catalog.Novelty.ZeroFitDialTranslationInvariance

/-! ## 1. Trailing zeros as a residue condition -/

/-- Having exactly `k` trailing binary zeros is a single residue class mod `2^(k+1)`. -/
theorem modEq_iff_two_adic (k x : ℕ) :
    x ≡ 2 ^ k [MOD 2 ^ (k + 1)] ↔ (2 ^ k ∣ x ∧ ¬ 2 ^ (k + 1) ∣ x) := by
  have hlt : 2 ^ k < 2 ^ (k + 1) := by
    rw [pow_succ]
    have := Nat.two_pow_pos k
    omega
  have hmod : 2 ^ k % 2 ^ (k + 1) = 2 ^ k := Nat.mod_eq_of_lt hlt
  constructor
  · intro h
    have hx : x % 2 ^ (k + 1) = 2 ^ k := by
      rw [Nat.ModEq] at h; rw [h, hmod]
    obtain ⟨q, hq⟩ : ∃ q, x = 2 ^ (k + 1) * q + 2 ^ k := by
      refine ⟨x / 2 ^ (k + 1), ?_⟩
      conv_lhs => rw [← Nat.div_add_mod x (2 ^ (k + 1))]
      rw [hx]
    have hk : 2 ^ (k + 1) = 2 ^ k * 2 := pow_succ 2 k
    constructor
    · exact ⟨2 * q + 1, by rw [hq, hk]; ring⟩
    · rintro ⟨t, ht⟩
      have h1 : 2 ^ k * (2 * t) = 2 ^ k * (2 * q + 1) := by
        rw [show 2 ^ k * (2 * t) = 2 ^ (k + 1) * t by rw [hk]; ring, ← ht, hq, hk]
        ring
      have := Nat.eq_of_mul_eq_mul_left (Nat.two_pow_pos k) h1
      omega
  · rintro ⟨⟨u, rfl⟩, hnd⟩
    have hu : ¬ (2 ∣ u) := by
      rintro ⟨v, rfl⟩
      exact hnd ⟨v, by rw [pow_succ]; ring⟩
    obtain ⟨q, rfl⟩ : ∃ q, u = 2 * q + 1 := by
      rcases Nat.even_or_odd u with he | ho
      · exact absurd he.two_dvd hu
      · exact ⟨u / 2, by omega⟩
    have : 2 ^ k * (2 * q + 1) = 2 ^ (k + 1) * q + 2 ^ k := by rw [pow_succ]; ring
    rw [Nat.ModEq, this, Nat.mul_add_mod]

/-! ## 2. Residue counting in an arbitrary window -/

/-- A window of `M·r` consecutive integers meets every residue class mod `r` exactly `M`
times, wherever it starts. -/
theorem card_Ico_modEq (A M r v : ℕ) (hr : 0 < r) :
    #{x ∈ Finset.Ico A (A + M * r) | x ≡ v [MOD r]} = M := by
  have hcard := Nat.Ico_filter_modEq_card A (A + M * r) hr v
  have hrQ : ((r : ℚ)) ≠ 0 := by
    have : (0 : ℚ) < (r : ℚ) := by exact_mod_cast hr
    exact ne_of_gt this
  have hsplit : (((A + M * r : ℕ) : ℚ) - (v : ℚ)) / (r : ℚ)
      = ((A : ℚ) - (v : ℚ)) / (r : ℚ) + (M : ℚ) := by
    push_cast
    field_simp
    ring
  rw [hsplit, Int.ceil_add_natCast] at hcard
  simp only [add_sub_cancel_left] at hcard
  have : max (M : ℤ) 0 = (M : ℤ) := by simp
  rw [this] at hcard
  exact_mod_cast hcard

/-! ## 3. The sliding window and its profile -/

/-- An arbitrary window of `2^s` consecutive integers, starting at `A`. -/
def slidingWindow (A s : ℕ) : Finset ℕ := Finset.Ico A (A + 2 ^ s)

/-- The `k`-th trailing-zero block of a sliding window. -/
def slidingBlock (A s k : ℕ) : Finset ℕ :=
  (slidingWindow A s).filter fun x => 2 ^ k ∣ x ∧ ¬ 2 ^ (k + 1) ∣ x

/-- The capping block of a sliding window: its points divisible by `2^s`. -/
def slidingCap (A s : ℕ) : Finset ℕ := (slidingWindow A s).filter fun x => 2 ^ s ∣ x

/-- **Block sizes are placement independent.**  Every window of `2^s` consecutive integers
contains exactly `2^(s-1-k)` integers with precisely `k` trailing zeros, for each `k < s`. -/
theorem card_slidingBlock (A s k : ℕ) (hk : k < s) :
    (slidingBlock A s k).card = 2 ^ (s - 1 - k) := by
  have hpow : (2 : ℕ) ^ s = 2 ^ (s - 1 - k) * 2 ^ (k + 1) := by
    rw [← pow_add]
    congr 1
    omega
  have hfil : slidingBlock A s k = {x ∈ Finset.Ico A (A + 2 ^ (s - 1 - k) * 2 ^ (k + 1)) |
      x ≡ 2 ^ k [MOD 2 ^ (k + 1)]} := by
    rw [slidingBlock, slidingWindow, hpow]
    apply filter_congr
    intro x _
    simp [modEq_iff_two_adic k x]
  rw [hfil]
  exact card_Ico_modEq A (2 ^ (s - 1 - k)) (2 ^ (k + 1)) (2 ^ k) (Nat.two_pow_pos _)

/-- Every window of `2^s` consecutive integers contains exactly one multiple of `2^s`. -/
theorem card_slidingCap (A s : ℕ) : (slidingCap A s).card = 1 := by
  have hfil : slidingCap A s = {x ∈ Finset.Ico A (A + 1 * 2 ^ s) | x ≡ 0 [MOD 2 ^ s]} := by
    rw [slidingCap, slidingWindow, one_mul]
    apply filter_congr
    intro x _
    simp [Nat.modEq_zero_iff_dvd]
  rw [hfil]
  exact card_Ico_modEq A 1 (2 ^ s) 0 (Nat.two_pow_pos _)

/-- Tie profile of the trailing-zero statistic on an arbitrary window of length `2^s`. -/
def slidingProfile (A s : ℕ) : List ℕ :=
  ((List.range s).map fun k => (slidingBlock A s k).card) ++ [(slidingCap A s).card]

/-- **Translation invariance.**  The trailing-zero tie profile of *any* window of `2^s`
consecutive integers is `dyadicBlocks s` — no alignment, no bitlen conditioning. -/
theorem slidingProfile_eq_dyadicBlocks (A s : ℕ) : slidingProfile A s = dyadicBlocks s := by
  rw [slidingProfile, dyadicBlocks_eq_formula]
  congr 1
  · exact List.map_congr_left fun k hk => card_slidingBlock A s k (List.mem_range.1 hk)
  · rw [card_slidingCap]

/-- The profile accounts for every point of the window: it sums to the sample size `2^s`. -/
theorem slidingProfile_sum (A s : ℕ) : (slidingProfile A s).sum = (slidingWindow A s).card := by
  rw [slidingProfile_eq_dyadicBlocks, dyadicBlocks_sum, slidingWindow, Nat.card_Ico]
  simp

/-- All windows of a common length share one tie ceiling. -/
theorem sliding_ceiling_invariant (A A' s : ℕ) :
    spearmanSq (slidingProfile A s) = spearmanSq (slidingProfile A' s) := by
  rw [slidingProfile_eq_dyadicBlocks, slidingProfile_eq_dyadicBlocks]

/-- Closed form for the common ceiling of all length-`2^s` windows. -/
theorem sliding_ceiling_closed_form (A s : ℕ) (hs : 1 ≤ s) :
    spearmanSq (slidingProfile A s) = (6 / 7) * (1 + 1 / ((2 : ℚ) ^ s * (2 ^ s + 1))) := by
  rw [slidingProfile_eq_dyadicBlocks]
  exact dyadic_spearmanSq s hs

/-- Cycle 3's aligned windows are the special case `A = c·2^s`. -/
theorem aligned_is_special_case (c s : ℕ) :
    slidingProfile (c * 2 ^ s) s = alignedProfile c s := by
  rw [slidingProfile_eq_dyadicBlocks, alignedProfile_eq_dyadicBlocks]

/-- Cycle 1's exact-bitlen window is the special case `A = 2^s`. -/
theorem exact_bitlen_is_special_case (s : ℕ) :
    slidingProfile (2 ^ s) s = windowProfile s := by
  rw [slidingProfile_eq_dyadicBlocks, windowProfile_eq_dyadicBlocks]

/-- **The round-57 cell, in its strongest form.**  Any `2^47` consecutive integers — the exact
bitlen-48 window, any shifted window, or the full range `[0,2^47)` — give the trailing-zero
statistic exactly the same tie ceiling `(6/7)(1 + 1/(2^47(2^47+1)))`. -/
theorem round57_any_window_same_ceiling (A : ℕ) :
    spearmanSq (slidingProfile A 47) = spearmanSq (windowProfile 47) ∧
    spearmanSq (slidingProfile A 47) = (6 / 7) * (1 + 1 / ((2 : ℚ) ^ 47 * (2 ^ 47 + 1))) := by
  refine ⟨?_, sliding_ceiling_closed_form A 47 (by norm_num)⟩
  rw [slidingProfile_eq_dyadicBlocks, windowProfile_eq_dyadicBlocks]

end Catalog.Novelty.ZeroFitDialTranslationInvariance