import Mathlib

/-!
# Euler-gap reveal density and the free `a ≤ b` pair filter

Formalises §3 and §5 of the round-33 corrections note.

## §5 — the Euler-gap reveal density is governed by the cofactors

Write `p - 1 = g·a`, `q - 1 = g·b` with `gcd(a, b) = 1`.  An exponent `e` *reveals*
a factor (the `p - 1`-style gcd step `gcd(x^e - 1, N)`, for every base `x`) when
exactly one of `p - 1 ∣ e`, `q - 1 ∣ e` holds.  Among the exponents that are
multiples of `g` in one period `[0, g·a·b)` we count the revealing ones:

* `reveal_count_cofactor` — `#{k < ab : a ∣ k xor b ∣ k} = a + b - 2`;
* `reveal_count_gap_cancels` — the same count `a + b - 2` for exponents
  `e < gab` with `g ∣ e`: **the gap `g` cancels**;
* hence the density is `ρ(a,b) = (a + b - 2)/(ab)`, and
  `revealDensity_lt_one`, `revealDensity_sup_one` (sup is `1`, approached along
  `a = 1`, i.e. `p - 1 ∣ q - 1`, never attained) and
  `revealDensity_le_half` (if `a, b ≥ 2` the density is `≤ 1/2`, with equality iff
  `a = 2` or `b = 2`).  So "sup = 1/2" is correct exactly on the class where neither
  of `p-1, q-1` divides the other; "sup = 1" needs `a = 1`.

## §3 — a free sound filter on Harvey's `(a, b)` family

* `good_pair_ordered` — soundness: if `p < q` and the pair `(a, b)` approximates
  `p/q` to Lehman accuracy `|a q - b p| < b`, then `a < b`.  So keeping only pairs
  with `a ≤ b` never discards the good pair.
* `two_mul_card_ordered_pairs` — exact accounting:
  `2·#{(a,b) : ab ≤ r, a ≤ b} = #{(a,b) : ab ≤ r} + ⌊√r⌋`.  The filter keeps
  half the pairs plus half the diagonal; its strength is `2` up to a lower-order
  `√r` term — a constant factor, not an exponent.
-/

namespace EulerGapPairFilter

open Finset

/-! ## §5. Reveal counting -/

/-- Number of exponents `k ∈ [0, ab)` with exactly one of `a ∣ k`, `b ∣ k`. -/
def revealCount (a b : ℕ) : ℕ := #{k ∈ range (a * b) | Xor' (a ∣ k) (b ∣ k)}

lemma card_multiples_range (a b : ℕ) (ha : 0 < a) :
    #{k ∈ range (a * b) | a ∣ k} = b := by
  have : {k ∈ range (a * b) | a ∣ k} = (range b).image (fun j => a * j) := by
    ext k
    simp only [mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨hk, j, rfl⟩
      exact ⟨j, by nlinarith, rfl⟩
    · rintro ⟨j, hj, rfl⟩
      exact ⟨by nlinarith, dvd_mul_right a j⟩
  rw [this, card_image_of_injective _ (fun x y h => by simpa [ha.ne'] using h)]
  simp

lemma card_both_range (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (hab : Nat.Coprime a b) :
    #{k ∈ range (a * b) | a ∣ k ∧ b ∣ k} = 1 := by
  rw [card_eq_one]
  refine ⟨0, ?_⟩
  ext k
  simp only [mem_filter, mem_range, mem_singleton]
  constructor
  · rintro ⟨hk, h1, h2⟩
    have := hab.mul_dvd_of_dvd_of_dvd h1 h2
    exact Nat.eq_zero_of_dvd_of_lt this hk
  · rintro rfl
    exact ⟨Nat.mul_pos ha hb, dvd_zero _, dvd_zero _⟩

/-- **Reveal count.** For coprime positive cofactors, exactly `a + b - 2`
exponents in one period reveal a factor. -/
theorem reveal_count_cofactor (a b : ℕ) (ha : 0 < a) (hb : 0 < b) (hab : Nat.Coprime a b) :
    revealCount a b + 2 = a + b := by
  have hA := card_multiples_range a b ha
  have hB : #{k ∈ range (a * b) | b ∣ k} = a := by
    rw [mul_comm]; exact card_multiples_range b a hb
  have hC := card_both_range a b ha hb hab
  calc revealCount a b + 2 = revealCount a b + 2 * #{k ∈ range (a * b) | a ∣ k ∧ b ∣ k} := by
        rw [hC]
    _ = #{k ∈ range (a * b) | a ∣ k} + #{k ∈ range (a * b) | b ∣ k} := by
        unfold revealCount
        simp only [card_filter]
        rw [mul_sum, ← sum_add_distrib, ← sum_add_distrib]
        apply sum_congr rfl
        intro k _
        by_cases h1 : a ∣ k <;> by_cases h2 : b ∣ k <;> simp [h1, h2, Xor']
    _ = a + b := by rw [hA, hB, add_comm]

/-- Exponents `e ∈ [0, gab)` that are multiples of the gap `g` and reveal
(exactly one of `ga ∣ e`, `gb ∣ e`). -/
def revealCountGap (g a b : ℕ) : ℕ :=
  #{e ∈ range (g * a * b) | g ∣ e ∧ Xor' (g * a ∣ e) (g * b ∣ e)}

/-- **The gap cancels.** The count of revealing exponents among multiples of `g`
does not depend on `g`. -/
theorem reveal_count_gap_cancels (g a b : ℕ) (hg : 0 < g) :
    revealCountGap g a b = revealCount a b := by
  unfold revealCountGap revealCount
  have : {e ∈ range (g * a * b) | g ∣ e ∧ Xor' (g * a ∣ e) (g * b ∣ e)} =
      ({k ∈ range (a * b) | Xor' (a ∣ k) (b ∣ k)}).image (fun k => g * k) := by
    ext e
    simp only [mem_filter, mem_range, mem_image]
    constructor
    · rintro ⟨he, ⟨k, rfl⟩, hx⟩
      refine ⟨k, ⟨?_, ?_⟩, rfl⟩
      · rw [mul_assoc] at he; exact Nat.lt_of_mul_lt_mul_left he
      · simpa [Nat.mul_dvd_mul_iff_left hg] using hx
    · rintro ⟨k, ⟨hk, hx⟩, rfl⟩
      refine ⟨?_, dvd_mul_right g k, ?_⟩
      · rw [mul_assoc]; exact Nat.mul_lt_mul_of_pos_left hk hg
      · simpa [Nat.mul_dvd_mul_iff_left hg] using hx
  rw [this, card_image_of_injective _ (fun x y h => by simpa [hg.ne'] using h)]

/-- The reveal density `ρ(a,b) = (a + b - 2)/(ab)`. -/
def revealDensity (a b : ℕ) : ℚ := ((a : ℚ) + b - 2) / (a * b)

/-- The density computed from the count over `g`-multiples equals `ρ(a,b)`, for
every gap `g ≥ 1`. -/
theorem density_eq_cofactor_formula (g a b : ℕ) (hg : 0 < g) (ha : 0 < a) (hb : 0 < b)
    (hab : Nat.Coprime a b) :
    (revealCountGap g a b : ℚ) / (a * b) = revealDensity a b := by
  rw [reveal_count_gap_cancels g a b hg, revealDensity]
  have h := reveal_count_cofactor a b ha hb hab
  have : (revealCount a b : ℚ) = a + b - 2 := by
    have : ((revealCount a b + 2 : ℕ) : ℚ) = ((a + b : ℕ) : ℚ) := by rw [h]
    push_cast at this; linarith
  rw [this]

theorem revealDensity_lt_one (a b : ℕ) (ha : 0 < a) (hb : 0 < b) : revealDensity a b < 1 := by
  unfold revealDensity
  have ha' : (1 : ℚ) ≤ a := by exact_mod_cast ha
  have hb' : (1 : ℚ) ≤ b := by exact_mod_cast hb
  rw [div_lt_one (by positivity)]
  nlinarith

/-- The supremum of the density is `1`: along `a = 1` (i.e. `p - 1 ∣ q - 1`)
the density `(b-1)/b` exceeds `1 - ε` for large `b`. -/
theorem revealDensity_sup_one (ε : ℚ) (hε : 0 < ε) :
    ∃ b : ℕ, 0 < b ∧ Nat.Coprime 1 b ∧ 1 - ε < revealDensity 1 b := by
  obtain ⟨n, hn⟩ := exists_nat_gt (1 / ε)
  refine ⟨n + 1, Nat.succ_pos n, Nat.coprime_one_left _, ?_⟩
  unfold revealDensity
  push_cast
  have hpos : (0 : ℚ) < n + 1 := by positivity
  have e : ((1 : ℚ) + (n + 1) - 2) / (1 * (n + 1)) = 1 - 1 / (n + 1) := by
    field_simp; ring
  rw [e]
  have : 1 / ((n : ℚ) + 1) < ε := by
    rw [div_lt_iff₀ hpos]
    have := (div_lt_iff₀ hε).1 hn
    nlinarith
  linarith

/-- On the class `a, b ≥ 2` (neither of `p-1`, `q-1` divides the other) the
density is at most `1/2`, with equality iff `a = 2` or `b = 2`. -/
theorem revealDensity_le_half (a b : ℕ) (ha : 2 ≤ a) (hb : 2 ≤ b) :
    revealDensity a b ≤ 1 / 2 ∧ (revealDensity a b = 1 / 2 ↔ a = 2 ∨ b = 2) := by
  unfold revealDensity
  have ha' : (2 : ℚ) ≤ a := by exact_mod_cast ha
  have hb' : (2 : ℚ) ≤ b := by exact_mod_cast hb
  have hpos : (0 : ℚ) < a * b := by positivity
  constructor
  · rw [div_le_iff₀ hpos]; nlinarith
  · rw [div_eq_iff hpos.ne']
    constructor
    · intro h
      have : ((a : ℚ) - 2) * (b - 2) = 0 := by linarith
      rcases mul_eq_zero.1 this with h1 | h1
      · left; exact_mod_cast (by linarith : (a : ℚ) = 2)
      · right; exact_mod_cast (by linarith : (b : ℚ) = 2)
    · rintro (rfl | rfl) <;> push_cast <;> ring

/-! ## §3. The free `a ≤ b` filter -/

/-- **Soundness of the `a ≤ b` filter.** If `p < q` and `(a, b)` approximates
`p/q` to Lehman accuracy `|a q - b p| < b`, then `a < b`.  (Positivity of `p`
is needed: `p = -2, q = -1, a = 2, b = 1` violates the conclusion.) -/
theorem good_pair_ordered (p q a b : ℤ) (hp : 0 < p) (hpq : p < q) (hb : 0 < b)
    (happrox : |a * q - b * p| < b) : a < b := by
  have h1 : a * q - b * p < b := lt_of_le_of_lt (le_abs_self _) happrox
  by_contra h
  push_neg at h
  have : b * q ≤ a * q := mul_le_mul_of_nonneg_right h (by linarith)
  nlinarith

/-- Harvey/Lehman pair family `{(a,b) : a, b ≥ 1, ab ≤ r}`. -/
def pairs (r : ℕ) : Finset (ℕ × ℕ) := {x ∈ Icc 1 r ×ˢ Icc 1 r | x.1 * x.2 ≤ r}

lemma diag_card (r : ℕ) : #{x ∈ pairs r | x.1 = x.2} = Nat.sqrt r := by
  have : {x ∈ pairs r | x.1 = x.2} = (Icc 1 (Nat.sqrt r)).image (fun a => (a, a)) := by
    ext ⟨a, b⟩
    simp only [pairs, mem_filter, mem_product, mem_Icc, mem_image, Prod.mk.injEq]
    constructor
    · rintro ⟨⟨⟨⟨h1, h2⟩, h3, h4⟩, h5⟩, rfl⟩
      exact ⟨a, ⟨h1, Nat.le_sqrt.2 h5⟩, rfl, rfl⟩
    · rintro ⟨c, ⟨h1, h2⟩, rfl, rfl⟩
      have h5 : c * c ≤ r := Nat.le_sqrt.1 h2
      have : c ≤ r := le_trans h2 (Nat.sqrt_le_self r)
      exact ⟨⟨⟨⟨h1, this⟩, h1, this⟩, h5⟩, rfl⟩
  rw [this, card_image_of_injective _ (fun x y h => by simpa using h)]
  simp

lemma lt_card_eq_gt_card (r : ℕ) :
    #{x ∈ pairs r | x.1 < x.2} = #{x ∈ pairs r | x.2 < x.1} := by
  apply card_bij (fun x _ => (x.2, x.1))
  · rintro ⟨a, b⟩ h
    simp only [pairs, mem_filter, mem_product, mem_Icc] at h ⊢
    exact ⟨⟨⟨h.1.1.2, h.1.1.1⟩, by rw [mul_comm]; exact h.1.2⟩, h.2⟩
  · rintro ⟨a, b⟩ _ ⟨c, d⟩ _ h
    simp only [Prod.mk.injEq] at h ⊢
    exact ⟨h.2, h.1⟩
  · rintro ⟨a, b⟩ h
    refine ⟨(b, a), ?_, rfl⟩
    simp only [pairs, mem_filter, mem_product, mem_Icc] at h ⊢
    exact ⟨⟨⟨h.1.1.2, h.1.1.1⟩, by rw [mul_comm]; exact h.1.2⟩, h.2⟩

/-- **Exact strength of the free filter.**
`2·#{ab ≤ r, a ≤ b} = #{ab ≤ r} + ⌊√r⌋`. -/
theorem two_mul_card_ordered_pairs (r : ℕ) :
    2 * #{x ∈ pairs r | x.1 ≤ x.2} = #(pairs r) + Nat.sqrt r := by
  have hsplit1 : #{x ∈ pairs r | x.1 ≤ x.2} =
      #{x ∈ pairs r | x.1 < x.2} + #{x ∈ pairs r | x.1 = x.2} := by
    rw [← card_union_of_disjoint]
    · congr 1; ext x; simp only [mem_filter, mem_union]
      constructor
      · rintro ⟨h, h'⟩; rcases lt_or_eq_of_le h' with h'' | h'' <;> simp_all
      · rintro (⟨h, h'⟩ | ⟨h, h'⟩) <;> exact ⟨h, by omega⟩
    · rw [disjoint_filter]; intro x _ h; omega
  have hsplit2 : #(pairs r) = #{x ∈ pairs r | x.1 ≤ x.2} + #{x ∈ pairs r | x.2 < x.1} := by
    rw [← card_union_of_disjoint]
    · congr 1; ext x; simp only [mem_filter, mem_union]
      constructor
      · intro h; rcases le_or_gt x.1 x.2 with h' | h' <;> simp_all
      · rintro (⟨h, _⟩ | ⟨h, _⟩) <;> exact h
    · rw [disjoint_filter]; intro x _ h; omega
  rw [hsplit2, hsplit1, lt_card_eq_gt_card, diag_card]
  ring

/-- Lab note: the exact filter accounting at `r = 100`. -/
example : #(pairs 100) = 482 ∧ #{x ∈ pairs 100 | x.1 ≤ x.2} = 246 := by decide +kernel

end EulerGapPairFilter