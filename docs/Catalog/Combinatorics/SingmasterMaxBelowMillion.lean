/-
# The maximum multiplicity below `10^6` is `8`, attained only at `3003`

Seventh research cycle.  `Combinatorics.SingmasterExactCounts` proved `N(3003) = 8`;
this file proves that below `10^6` *nothing else even comes close*: every other number
occurs at most six times.  In particular `3003` is the unique number below `10^6` of
multiplicity eight, which is the sub-conjecture 6b of `FUTURE_DIRECTIONS.md`.

## The mechanism

The reflection decomposition of `Combinatorics.SingmasterParity` writes

`N(t) = 2 · #(left occurrences) + #(central occurrences)`,

and for `t ≥ 3` exactly one left occurrence is the trivial one `C(t,1) = t`, so

`N(t) = 2 + 2 · #(left interior occurrences) + #(central occurrences)`
  (`Singmaster.mult_eq_two_add_two_mul_leftInt`).

A left interior occurrence has column `k ≥ 2` and `2k < n`, and column uniqueness makes
its column determine its row.  Therefore:

* there is **at most one** left interior occurrence in the column `k = 2`;
* if `t < 10^6` then any left interior occurrence with `k ≥ 3` has `k < 20`
  (because `2^k ≤ C(n,k) = t`) and `n < 1415` (because `C(n,2) ≤ C(n,k) = t` and
  `C(1415,2) = 1000405 > 10^6`), i.e. it lies in the explicit `1415 × 20` box
  `Singmaster.bigCols`;
* a single kernel search over that box (`Singmaster.bigCols_pair_search`, `320` entries,
  all pairs compared) shows that **no value below `10^6` occurs twice with column
  `≥ 3`, except `3003 = C(15,5) = C(14,6)`**.

Hence for `t < 10^6`, `t ≠ 3003`, there are at most `1 + 1 = 2` left interior
occurrences, so `N(t) ≤ 2 + 4 + 1 = 7`; and `N(t) = 7` is impossible by
`Combinatorics.SingmasterCentralBinomialExtended.mult_ne_five_or_seven_of_lt_large`.

## Results

* `Singmaster.mult_eq_two_add_two_mul_leftInt` — the refined decomposition;
* `Singmaster.bigCols_pair_search` — the kernel search;
* `Singmaster.leftInt_card_le_two` — at most two left interior occurrences below `10^6`
  away from `3003`;
* `Singmaster.mult_le_six_of_lt_million` — **every `t` with `2 ≤ t < 10^6` and
  `t ≠ 3003` occurs at most six times**;
* `Singmaster.mult_eq_eight_iff_of_lt_million` — **`3003` is the unique number below
  `10^6` occurring exactly eight times**;
* `Singmaster.mult_le_eight_of_lt_million` — the multiplicity function is bounded by `8`
  on `[2, 10^6)`, a Singmaster-type bound with the conjectured optimal constant on that
  range;
* `Singmaster.mult_24310` — `N(24310) = 6`, a value out of reach of the earlier box
  search, obtained by combining the new upper bound with two explicit occurrences.
-/
import Mathlib
import Combinatorics.SingmasterOccurrences
import Combinatorics.SingmasterRefinements
import Combinatorics.SingmasterParity
import Combinatorics.SingmasterExactCounts
import Combinatorics.SingmasterCentralBinomialExtended

open Finset

set_option maxRecDepth 100000

namespace Singmaster

/-! ## Left interior occurrences -/

/-- The *left interior* occurrences of `t`: positions `(n,k)` with `C(n,k) = t`,
`2 ≤ k` and `2k < n`.  Together with the trivial occurrence `C(t,1) = t` these are all
the left occurrences. -/
def leftInt (t : ℕ) : Finset (ℕ × ℕ) := (leftOcc t).filter (fun p => 2 ≤ p.2)

theorem mem_leftInt {t n k : ℕ} (ht : 2 ≤ t) :
    (n, k) ∈ leftInt t ↔ (k ≤ n ∧ n.choose k = t) ∧ 2 * k < n ∧ 2 ≤ k := by
  simp only [leftInt, mem_filter, mem_leftOcc, mem_occ_iff ht]
  tauto

/-- For `t ≥ 3` the left occurrences are the trivial one `(t,1)` together with the left
interior ones. -/
theorem leftOcc_eq_insert {t : ℕ} (ht : 3 ≤ t) :
    leftOcc t = insert (t, 1) (leftInt t) := by
  have ht2 : 2 ≤ t := by omega
  ext ⟨n, k⟩
  simp only [mem_insert, mem_leftInt ht2, mem_leftOcc, mem_occ_iff ht2, Prod.mk.injEq]
  constructor
  · rintro ⟨⟨hk, hck⟩, hlt⟩
    rcases Nat.lt_or_ge k 2 with hk2 | hk2
    · interval_cases k
      · rw [Nat.choose_zero_right] at hck; omega
      · rw [Nat.choose_one_right] at hck; exact Or.inl ⟨hck, rfl⟩
    · exact Or.inr ⟨⟨hk, hck⟩, hlt, hk2⟩
  · rintro (⟨rfl, rfl⟩ | ⟨⟨hk, hck⟩, hlt, hk2⟩)
    · exact ⟨⟨by omega, Nat.choose_one_right _⟩, by omega⟩
    · exact ⟨⟨hk, hck⟩, hlt⟩

/-- **Refined reflection decomposition.**  For `t ≥ 3`,
`N(t) = 2 + 2·#(left interior occurrences) + #(central occurrences)`. -/
theorem mult_eq_two_add_two_mul_leftInt {t : ℕ} (ht : 3 ≤ t) :
    mult t = 2 + 2 * (leftInt t).card + (centerOcc t).card := by
  have ht2 : 2 ≤ t := by omega
  have hnot : (t, 1) ∉ leftInt t := by
    intro hmem
    rw [mem_leftInt ht2] at hmem
    omega
  have hcard : (leftOcc t).card = 1 + (leftInt t).card := by
    rw [leftOcc_eq_insert ht, Finset.card_insert_of_notMem hnot]
    omega
  rw [mult_eq_two_mul_add_center ht2, hcard]
  ring

/-! ## At most one left interior occurrence in the column `k = 2` -/

/-- Column uniqueness in the column `k = 2`: the map `n ↦ C(n,2)` is injective. -/
theorem leftInt_two_subsingleton {t : ℕ} (ht : 2 ≤ t) :
    ((leftInt t).filter (fun p => p.2 = 2)).card ≤ 1 := by
  refine Finset.card_le_one.2 ?_
  rintro ⟨n, k⟩ h1 ⟨n', k'⟩ h2
  rw [mem_filter, mem_leftInt ht] at h1 h2
  obtain ⟨⟨⟨hk1, hv1⟩, _⟩, hk2⟩ := h1
  obtain ⟨⟨⟨hk1', hv1'⟩, _⟩, hk2'⟩ := h2
  simp only at hk2 hk2'
  subst hk2
  subst hk2'
  have : n = n' := row_unique (by norm_num) hk1 hk1' (by rw [hv1, hv1'])
  rw [this]

/-! ## The explicit box for the columns `k ≥ 3` -/

/-- The positions `(n,k)` with `3 ≤ k < K`, `2k < n < R` and `C(n,k) < B`, written with
descending factorials so that the kernel can enumerate them. -/
def bigCols (R K B : ℕ) : Finset (ℕ × ℕ) :=
  ((range R) ×ˢ (range K)).filter
    (fun p => 3 ≤ p.2 ∧ 2 * p.2 < p.1 ∧ p.1.descFactorial p.2 < Nat.factorial p.2 * B)

set_option maxRecDepth 4000000 in
/-- **The kernel search.**  Among the `320` positions of Pascal's triangle with column
`k ≥ 3`, row `n < 1415` and value `< 10^6`, no two distinct ones carry the same value —
except the pair `C(15,5) = C(14,6) = 3003`.

This is a genuine exhaustive comparison of all `320²` pairs, type-checked by the Lean
kernel (`decide +kernel`, *not* `native_decide`). -/
theorem bigCols_pair_search :
    ∀ p ∈ bigCols 1415 20 1000000, ∀ q ∈ bigCols 1415 20 1000000,
      p.1.descFactorial p.2 / Nat.factorial p.2
        = q.1.descFactorial q.2 / Nat.factorial q.2 →
      p = q ∨ p.1.descFactorial p.2 / Nat.factorial p.2 = 3003 := by
  decide +kernel

/-- A left interior occurrence of a value below `10^6` with column `≥ 3` lies in the
box `bigCols 1415 20 1000000`. -/
theorem mem_bigCols_of_leftInt {t n k : ℕ} (ht : 2 ≤ t) (hlt : t < 1000000)
    (hmem : (n, k) ∈ leftInt t) (hk3 : 3 ≤ k) : (n, k) ∈ bigCols 1415 20 1000000 := by
  rw [mem_leftInt ht] at hmem
  obtain ⟨⟨hkn, hck⟩, hlt2, _⟩ := hmem
  have hkbound : k < 20 := by
    have h2k : 2 ^ k ≤ n.choose k := two_pow_le_choose (by omega)
    have hpow : (2 : ℕ) ^ k < 2 ^ 20 := by
      rw [hck] at h2k
      have : (2 : ℕ) ^ 20 = 1048576 := by norm_num
      omega
    exact (Nat.pow_lt_pow_iff_right (by norm_num)).1 hpow
  have hnbound : n < 1415 := by
    by_contra hcon
    push_neg at hcon
    have hc2 : n.choose 2 ≤ t := by
      rw [← hck]
      exact choose_two_le_choose (by omega) (by omega)
    have hmono : (1415 : ℕ).choose 2 ≤ n.choose 2 := Nat.choose_le_choose 2 hcon
    have hval : (1415 : ℕ).choose 2 = 1000405 := by
      rw [Nat.choose_two_right]
    omega
  have hdesc : n.descFactorial k = Nat.factorial k * t := by
    rw [Nat.descFactorial_eq_factorial_mul_choose, hck]
  simp only [bigCols, mem_filter, mem_product, mem_range]
  refine ⟨⟨hnbound, hkbound⟩, hk3, hlt2, ?_⟩
  rw [hdesc]
  exact (Nat.mul_lt_mul_left (Nat.factorial_pos k)).2 hlt

/-- Away from `3003`, a value below `10^6` has at most one left interior occurrence with
column `≥ 3`. -/
theorem leftInt_big_subsingleton {t : ℕ} (ht : 2 ≤ t) (hlt : t < 1000000)
    (hne : t ≠ 3003) : ((leftInt t).filter (fun p => ¬ p.2 = 2)).card ≤ 1 := by
  refine Finset.card_le_one.2 ?_
  rintro ⟨n, k⟩ h1 ⟨n', k'⟩ h2
  rw [mem_filter] at h1 h2
  obtain ⟨hm1, hk1⟩ := h1
  obtain ⟨hm2, hk2⟩ := h2
  have hk3 : 3 ≤ k := by
    have := (mem_leftInt ht).1 hm1
    simp only at hk1
    omega
  have hk3' : 3 ≤ k' := by
    have := (mem_leftInt ht).1 hm2
    simp only at hk2
    omega
  have hb1 := mem_bigCols_of_leftInt ht hlt hm1 hk3
  have hb2 := mem_bigCols_of_leftInt ht hlt hm2 hk3'
  have hv1 : n.choose k = t := ((mem_leftInt ht).1 hm1).1.2
  have hv2 : n'.choose k' = t := ((mem_leftInt ht).1 hm2).1.2
  have he1 : n.descFactorial k / Nat.factorial k = t := by
    rw [← Nat.choose_eq_descFactorial_div_factorial, hv1]
  have he2 : n'.descFactorial k' / Nat.factorial k' = t := by
    rw [← Nat.choose_eq_descFactorial_div_factorial, hv2]
  rcases bigCols_pair_search (n, k) hb1 (n', k') hb2 (by rw [he1, he2]) with h | h
  · exact h
  · exact absurd (by rw [← he1]; exact h) hne

/-- **At most two left interior occurrences.**  For `2 ≤ t < 10^6` with `t ≠ 3003`. -/
theorem leftInt_card_le_two {t : ℕ} (ht : 2 ≤ t) (hlt : t < 1000000) (hne : t ≠ 3003) :
    (leftInt t).card ≤ 2 := by
  classical
  have hsplit :
      ((leftInt t).filter (fun p => p.2 = 2)).card
        + ((leftInt t).filter (fun p => ¬ p.2 = 2)).card = (leftInt t).card :=
    Finset.card_filter_add_card_filter_not _
  have h1 := leftInt_two_subsingleton (t := t) ht
  have h2 := leftInt_big_subsingleton ht hlt hne
  omega

/-! ## The multiplicity below `10^6` -/

/-- **Every number below `10^6` other than `3003` occurs at most six times.**

The bound `7` comes from the refined reflection decomposition together with the two
subsingleton statements; the value `7` is then excluded by
`Singmaster.mult_ne_five_or_seven_of_lt_large`. -/
theorem mult_le_six_of_lt_million {t : ℕ} (ht : 2 ≤ t) (hlt : t < 1000000)
    (hne : t ≠ 3003) : mult t ≤ 6 := by
  rcases Nat.lt_or_ge t 3 with hsmall | ht3
  · have : t = 2 := by omega
    subst this
    rw [mult_two]
    norm_num
  · have hdec := mult_eq_two_add_two_mul_leftInt ht3
    have h1 := leftInt_card_le_two ht hlt hne
    have h2 := centerOcc_card_le_one (t := t) ht
    have h7 : mult t ≤ 7 := by omega
    have hne7 : mult t ≠ 7 :=
      (mult_ne_five_or_seven_of_lt_large ht (by omega)).2
    omega

/-- **`3003` is the unique number below `10^6` that occurs exactly eight times.**  This
is the specimen singled out in Singmaster's problem: `3003 = C(3003,1) = C(3003,3002)
= C(78,2) = C(78,76) = C(15,5) = C(15,10) = C(14,6) = C(14,8)`. -/
theorem mult_eq_eight_iff_of_lt_million {t : ℕ} (ht : 2 ≤ t) (hlt : t < 1000000) :
    mult t = 8 ↔ t = 3003 := by
  constructor
  · intro h8
    by_contra hne
    have := mult_le_six_of_lt_million ht hlt hne
    omega
  · rintro rfl
    exact mult_3003

/-- **Singmaster's bound with the conjectured optimal constant, verified below `10^6`.**
Every `t` with `2 ≤ t < 10^6` occurs at most eight times, and eight is attained. -/
theorem mult_le_eight_of_lt_million {t : ℕ} (ht : 2 ≤ t) (hlt : t < 1000000) :
    mult t ≤ 8 := by
  by_cases hne : t = 3003
  · subst hne
    rw [mult_3003]
  · exact le_trans (mult_le_six_of_lt_million ht hlt hne) (by norm_num)

/-- `24310 = C(221,2) = C(221,219) = C(17,8) = C(17,9) = C(24310,1) = C(24310,24309)`
occurs **exactly** six times.

This value was out of reach of the box search of `Combinatorics.SingmasterExactCounts`
(its box has side `221`); here the upper bound comes from
`Singmaster.mult_le_six_of_lt_million` and the lower bound from two explicit left
interior occurrences. -/
theorem mult_24310 : mult 24310 = 6 := by
  have hub := mult_le_six_of_lt_million (t := 24310) (by norm_num) (by norm_num)
    (by norm_num)
  have hmem1 : (221, 2) ∈ leftInt 24310 := by
    rw [mem_leftInt (by norm_num)]
    exact ⟨⟨by norm_num, by norm_num [Nat.choose_two_right]⟩, by norm_num, by norm_num⟩
  have hmem2 : (17, 8) ∈ leftInt 24310 := by
    rw [mem_leftInt (by norm_num)]
    exact ⟨⟨by norm_num, choose_eq_iff_descFactorial.2 (by decide)⟩, by norm_num,
      by norm_num⟩
  have hsub : ({(221, 2), (17, 8)} : Finset (ℕ × ℕ)) ⊆ leftInt 24310 := by
    intro p hp
    simp only [mem_insert, mem_singleton] at hp
    rcases hp with rfl | rfl
    · exact hmem1
    · exact hmem2
  have hcard : ({(221, 2), (17, 8)} : Finset (ℕ × ℕ)).card = 2 := by decide
  have h2 : 2 ≤ (leftInt 24310).card := by
    rw [← hcard]
    exact Finset.card_le_card hsub
  have hdec := mult_eq_two_add_two_mul_leftInt (t := 24310) (by norm_num)
  omega

/-- The maximum of the multiplicity function on `[2, 10^6)` equals `8`, and it is
attained exactly once. -/
theorem max_mult_below_million :
    (∀ t, 2 ≤ t → t < 1000000 → mult t ≤ 8) ∧ mult 3003 = 8 :=
  ⟨fun _ ht hlt => mult_le_eight_of_lt_million ht hlt, mult_3003⟩

end Singmaster