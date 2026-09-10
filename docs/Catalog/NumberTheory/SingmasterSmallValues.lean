/-
# Singmaster multiplicity: effective search and the small-value spectrum

Building on `Catalog/NumberTheory/SingmasterCore.lean`, this file turns the row bound
`N(N-1) ≤ 2n` into an *effective* finite search, and uses it to determine the
spectrum of `Singmaster.mult` below `3003`.

Main results.

* `Singmaster.mult_eq_two_add_count` — for any search radius `b` with `2n < b(b-1)`,
  the multiplicity of `n ≥ 3` is `2` plus the cardinality of an explicitly computable
  finite set.  This is the workhorse that makes multiplicities decidable.
* `Singmaster.mult_3003` — `mult 3003 = 8`, the largest multiplicity known.
* `Singmaster.mult_eq_three_of_odd_of_lt` — below `3003` an odd multiplicity is
  always exactly `3`.
* `Singmaster.mult_ne_five_or_seven_of_lt` — the values `5` and `7` are not attained
  below `3003`.
* `Singmaster.mult_le_eight_of_lt` — **Singmaster's conjecture with the sharp
  constant `8` is verified for every `n < 3003`**, via a single global enumeration of
  the ≤ 6-column strip of Pascal's triangle rather than one search per `n`.
-/
import NumberTheory.SingmasterCore

set_option maxRecDepth 100000

namespace Singmaster

open Finset

/-! ## Effective search radius -/

/-- All interior occurrences of `n` live in the square `[0,b) × [0,b)` as soon as
`2n < b(b-1)`. -/
theorem interiorOcc_eq_filter {n b : ℕ} (hn : 2 ≤ n) (hb : 2 * n < b * (b - 1)) :
    interiorOcc n = ((range b) ×ˢ (range b)).filter
      (fun p => 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1 ∧ p.1.choose p.2 = n) := by
  ext p
  obtain ⟨N, k⟩ := p
  simp only [mem_interiorOcc hn, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
  constructor
  · rintro ⟨h2, h3, hc⟩
    have hrow : N * (N - 1) ≤ 2 * n := mul_pred_le_of_choose_eq h2 (by omega) hc
    have hNb : N < b := by
      by_contra hcon
      push_neg at hcon
      have : b * (b - 1) ≤ N * (N - 1) := Nat.mul_le_mul hcon (by omega)
      omega
    exact ⟨⟨hNb, by omega⟩, h2, h3, hc⟩
  · rintro ⟨-, h⟩; exact h

/-- The multiplicity of `n ≥ 3` as `2` plus an explicitly computable count. -/
theorem mult_eq_two_add_count {n b : ℕ} (hn : 3 ≤ n) (hb : 2 * n < b * (b - 1)) :
    mult n = 2 + (((range b) ×ˢ (range b)).filter
      (fun p => 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1 ∧ p.1.choose p.2 = n)).card := by
  rw [mult_eq_two_add_interior hn, interiorOcc_eq_filter (by omega) hb]

/-! ## Individual multiplicities -/

/-- **`3003` occurs eight times in Pascal's triangle**:
`C(3003,1) = C(3003,3002) = C(78,2) = C(78,76) = C(15,5) = C(15,10) = C(14,6) = C(14,8)`. -/
theorem mult_3003 : mult 3003 = 8 := by
  have hcount : (((range 79) ×ˢ (range 79)).filter
      (fun p => 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1 ∧ p.1.choose p.2 = 3003)).card = 6 := by decide
  rw [mult_eq_two_add_count (n := 3003) (b := 79) (by norm_num) (by norm_num), hcount]

theorem mult_6 : mult 6 = 3 := by
  have hcount : (((range 5) ×ˢ (range 5)).filter
      (fun p => 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1 ∧ p.1.choose p.2 = 6)).card = 1 := by decide
  rw [mult_eq_two_add_count (n := 6) (b := 5) (by norm_num) (by norm_num), hcount]

theorem mult_20 : mult 20 = 3 := by
  have hcount : (((range 7) ×ˢ (range 7)).filter
      (fun p => 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1 ∧ p.1.choose p.2 = 20)).card = 1 := by decide
  rw [mult_eq_two_add_count (n := 20) (b := 7) (by norm_num) (by norm_num), hcount]

theorem mult_70 : mult 70 = 3 := by
  have hcount : (((range 13) ×ˢ (range 13)).filter
      (fun p => 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1 ∧ p.1.choose p.2 = 70)).card = 1 := by decide
  rw [mult_eq_two_add_count (n := 70) (b := 13) (by norm_num) (by norm_num), hcount]

theorem mult_252 : mult 252 = 3 := by
  have hcount : (((range 23) ×ˢ (range 23)).filter
      (fun p => 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1 ∧ p.1.choose p.2 = 252)).card = 1 := by decide
  rw [mult_eq_two_add_count (n := 252) (b := 23) (by norm_num) (by norm_num), hcount]

theorem mult_924 : mult 924 = 3 := by
  have hcount : (((range 44) ×ˢ (range 44)).filter
      (fun p => 2 ≤ p.2 ∧ p.2 + 2 ≤ p.1 ∧ p.1.choose p.2 = 924)).card = 1 := by decide
  rw [mult_eq_two_add_count (n := 924) (b := 44) (by norm_num) (by norm_num), hcount]

/-! ## Odd multiplicities below 3003 -/

/-- Below `3003` the only central binomial coefficients `≥ 3` are `6, 20, 70, 252, 924`. -/
theorem centralBinom_small {m n : ℕ} (hn : 3 ≤ n) (hlt : n < 3003)
    (hm : Nat.centralBinom m = n) : n = 6 ∨ n = 20 ∨ n = 70 ∨ n = 252 ∨ n = 924 := by
  have hm7 : m < 7 := by
    by_contra hcon
    push_neg at hcon
    have hmono : Nat.centralBinom 7 ≤ Nat.centralBinom m := centralBinom_strictMono.monotone hcon
    have h7 : Nat.centralBinom 7 = 3432 := by decide
    omega
  have key : ∀ j ∈ Finset.range 7, 3 ≤ Nat.centralBinom j →
      Nat.centralBinom j = 6 ∨ Nat.centralBinom j = 20 ∨ Nat.centralBinom j = 70 ∨
        Nat.centralBinom j = 252 ∨ Nat.centralBinom j = 924 := by decide
  have := key m (Finset.mem_range.mpr hm7) (by omega)
  rw [hm] at this
  exact this

/-- **Odd multiplicities are rigid below `3003`.** -/
theorem mult_eq_three_of_odd_of_lt {n : ℕ} (hn : 3 ≤ n) (hlt : n < 3003) (hodd : Odd (mult n)) :
    mult n = 3 := by
  obtain ⟨m, hm⟩ := (odd_mult_iff (by omega)).mp hodd
  rcases centralBinom_small hn hlt hm with rfl | rfl | rfl | rfl | rfl
  · exact mult_6
  · exact mult_20
  · exact mult_70
  · exact mult_252
  · exact mult_924

/-- **The values `5` and `7` are missing from the Singmaster spectrum below `3003`.** -/
theorem mult_ne_five_or_seven_of_lt {n : ℕ} (hlt : n < 3003) : mult n ≠ 5 ∧ mult n ≠ 7 := by
  have hsmall : ∀ m < 3, mult m ≠ 5 ∧ mult m ≠ 7 := by decide
  rcases Nat.lt_or_ge n 3 with h | h
  · exact hsmall n h
  constructor <;> intro heq <;>
    · have hodd : Odd (mult n) := by rw [heq, Nat.odd_iff]
      have := mult_eq_three_of_odd_of_lt h hlt hodd
      omega

/-! ## Singmaster's conjecture, with the sharp constant, below 3003 -/

/-- The interior occurrences strictly left of the centre. -/
def interiorLower (n : ℕ) : Finset (ℕ × ℕ) := (interiorOcc n).filter (fun p => 2 * p.2 < p.1)

theorem lowerOcc_eq_insert {n : ℕ} (hn : 3 ≤ n) :
    lowerOcc n = insert (n, 1) (interiorLower n) := by
  have hn2 : 2 ≤ n := by omega
  ext p
  obtain ⟨N, k⟩ := p
  simp only [lowerOcc, interiorLower, Finset.mem_filter, mem_occ hn2, mem_interiorOcc hn2,
    Finset.mem_insert, Prod.mk.injEq]
  constructor
  · rintro ⟨⟨hk, hc⟩, hlt⟩
    rcases Nat.lt_or_ge k 2 with h2 | h2
    · interval_cases k
      · rw [Nat.choose_zero_right] at hc; omega
      · rw [Nat.choose_one_right] at hc; exact Or.inl ⟨hc, rfl⟩
    · exact Or.inr ⟨⟨h2, by omega, hc⟩, hlt⟩
  · rintro (⟨rfl, rfl⟩ | ⟨⟨h2, h3, hc⟩, hlt⟩)
    · exact ⟨⟨by omega, Nat.choose_one_right _⟩, by omega⟩
    · exact ⟨⟨by omega, hc⟩, hlt⟩

theorem card_lowerOcc {n : ℕ} (hn : 3 ≤ n) :
    (lowerOcc n).card = 1 + (interiorLower n).card := by
  have hn2 : 2 ≤ n := by omega
  have hnot : (n, 1) ∉ interiorLower n := by
    intro hmem
    simp only [interiorLower, Finset.mem_filter, mem_interiorOcc hn2] at hmem
    omega
  rw [lowerOcc_eq_insert hn, Finset.card_insert_of_notMem hnot]
  omega

/-- The global strip: all candidate positions `(N,k)` with `2 ≤ k ≤ 6`, `2k ≤ N < 79`
whose entry is `< 3003`.  Every interior occurrence, left of centre, of every `n < 3003`
lies in this strip. -/
def strip : Finset (ℕ × ℕ) :=
  ((range 79) ×ˢ (range 7)).filter
    (fun p => 2 ≤ p.2 ∧ 2 * p.2 ≤ p.1 ∧ p.1.choose p.2 < 3003)

/-- **Global enumeration.** No value is taken more than three times on the strip. -/
theorem strip_fiber_card_le_three' :
    ∀ p ∈ strip, (strip.filter (fun q => q.1.choose q.2 = p.1.choose p.2)).card ≤ 3 := by
  decide

theorem strip_fiber_card_le_three (n : ℕ) :
    (strip.filter (fun q => q.1.choose q.2 = n)).card ≤ 3 := by
  rcases Finset.eq_empty_or_nonempty (strip.filter (fun q => q.1.choose q.2 = n)) with h | ⟨p, hp⟩
  · rw [h]; simp
  · rw [Finset.mem_filter] at hp
    obtain ⟨hps, hpv⟩ := hp
    have := strip_fiber_card_le_three' p hps
    rwa [hpv] at this

theorem interiorLower_subset_strip {n : ℕ} (hn : 3 ≤ n) (hlt : n < 3003) :
    interiorLower n ⊆ strip.filter (fun q => q.1.choose q.2 = n) := by
  rintro ⟨N, k⟩ hmem
  simp only [interiorLower, Finset.mem_filter, mem_interiorOcc (by omega : 2 ≤ n)] at hmem
  obtain ⟨⟨h2, h3, hc⟩, hlt2⟩ := hmem
  have hrow : N * (N - 1) ≤ 2 * n := mul_pred_le_of_choose_eq h2 (by omega) hc
  have hNb : N < 79 := by
    by_contra hcon
    push_neg at hcon
    have : 79 * 78 ≤ N * (N - 1) := Nat.mul_le_mul hcon (by omega)
    omega
  have hk7 : k < 7 := by
    by_contra hcon
    push_neg at hcon
    have h1 : Nat.centralBinom k ≤ N.choose k := Nat.choose_le_choose k (by omega)
    have h2' : Nat.centralBinom 7 ≤ Nat.centralBinom k := centralBinom_strictMono.monotone hcon
    have h3' : Nat.centralBinom 7 = 3432 := by decide
    omega
  simp only [strip, Finset.mem_filter, Finset.mem_product, Finset.mem_range]
  exact ⟨⟨⟨hNb, hk7⟩, h2, by omega, by omega⟩, hc⟩

/-- **Singmaster's conjecture holds with the sharp constant `8` for every `n < 3003`.**
The proof combines the reflection decomposition, the parity rigidity of odd
multiplicities, and one global enumeration of the six-column strip. -/
theorem mult_le_eight_of_lt {n : ℕ} (hlt : n < 3003) : mult n ≤ 8 := by
  have hsmall : ∀ m < 3, mult m ≤ 8 := by decide
  rcases Nat.lt_or_ge n 3 with h | h
  · exact hsmall n h
  have hL : (interiorLower n).card ≤ 3 :=
    le_trans (Finset.card_le_card (interiorLower_subset_strip h hlt))
      (strip_fiber_card_le_three n)
  have hdec := mult_eq_two_mul_lower_add_central (n := n) (by omega)
  rw [card_lowerOcc h] at hdec
  have hc := centralOcc_card_le_one n
  by_contra hcon
  push_neg at hcon
  -- the only possibility left is `mult n = 9`, which is odd, hence forced to be `3`
  have h9 : mult n = 9 := by omega
  have hodd : Odd (mult n) := by rw [h9, Nat.odd_iff]
  have := mult_eq_three_of_odd_of_lt h hlt hodd
  omega

end Singmaster