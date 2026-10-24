module

public import Mathlib

/-!
# Sums of two anti-Fibonacci numbers and sums of two squares

We work with the sequence `antiFib n = n * (n + 1) / 2 + 1` (`1, 2, 4, 7, 11, 16, …`),
normalised so that `8 * antiFib n = (2 * n + 1) ^ 2 + 7`.

Main results:

* `AntiFib.isAntiFibSum_iff_int` : `m` is a sum of two anti-Fibonacci numbers iff the
  integer `8 * m - 14` is a sum of two squares.
* `AntiFib.isAntiFibSum_iff_padicVal` : Fermat-type criterion: `m` is representable iff
  `2 ≤ m` and every prime `q ≡ 3 (mod 4)` divides `4 * m - 7` to an even power.
* `AntiFib.not_isAntiFibSum_of_exact_dvd` : local obstruction at a prime `q ≡ 3 (mod 4)`.
* `AntiFib.two_mul_le_card_nonrep` : at least `2/9` of all integers are not representable.
-/

@[expose] public section

open Finset

namespace AntiFib

/-- The anti-Fibonacci numbers `1, 2, 4, 7, 11, 16, …`. -/
def antiFib (n : ℕ) : ℕ := n * (n + 1) / 2 + 1

/-- `m` is a sum of two anti-Fibonacci numbers. -/
def IsAntiFibSum (m : ℕ) : Prop := ∃ a b : ℕ, m = antiFib a + antiFib b

lemma two_mul_triangle (n : ℕ) : 2 * (n * (n + 1) / 2) = n * (n + 1) := by
  have : 2 ∣ n * (n + 1) := (Nat.even_mul_succ_self n).two_dvd
  omega

/-- The basic identity `8 * antiFib n = (2n+1)^2 + 7`. -/
theorem eight_mul_antiFib (n : ℕ) : 8 * antiFib n = (2 * n + 1) ^ 2 + 7 := by
  have := two_mul_triangle n
  unfold antiFib
  nlinarith

lemma one_le_antiFib (n : ℕ) : 1 ≤ antiFib n := by
  unfold antiFib; omega

lemma two_le_of_isAntiFibSum {m : ℕ} (h : IsAntiFibSum m) : 2 ≤ m := by
  obtain ⟨a, b, rfl⟩ := h
  have := one_le_antiFib a; have := one_le_antiFib b; omega

/-- Odd squares are `1 mod 8`; a sum of two integer squares that is `2 mod 8` has both
summands odd. -/
lemma odd_of_sq_add_sq_mod_eight {x y : ℤ} (h : (x ^ 2 + y ^ 2) % 8 = 2) : Odd x ∧ Odd y := by
  rcases Int.even_or_odd x with ⟨a, rfl⟩ | ⟨a, rfl⟩ <;>
  rcases Int.even_or_odd y with ⟨b, rfl⟩ | ⟨b, rfl⟩
  · exfalso
    have : (a + a) ^ 2 + (b + b) ^ 2 = 4 * (a ^ 2 + b ^ 2) := by ring
    omega
  · exfalso
    have : (a + a) ^ 2 + (2 * b + 1) ^ 2 = 4 * (a ^ 2 + b ^ 2 + b) + 1 := by ring
    omega
  · exfalso
    have : (2 * a + 1) ^ 2 + (b + b) ^ 2 = 4 * (a ^ 2 + b ^ 2 + a) + 1 := by ring
    omega
  · exact ⟨⟨a, rfl⟩, ⟨b, rfl⟩⟩

/-- **Reduction to sums of two squares.** `m` is a sum of two anti-Fibonacci numbers iff
`8 m - 14` (computed in `ℤ`) is a sum of two squares. -/
theorem isAntiFibSum_iff_int (m : ℕ) :
    IsAntiFibSum m ↔ ∃ x y : ℤ, (8 * m - 14 : ℤ) = x ^ 2 + y ^ 2 := by
  constructor
  · rintro ⟨a, b, rfl⟩
    refine ⟨2 * a + 1, 2 * b + 1, ?_⟩
    have ha := eight_mul_antiFib a
    have hb := eight_mul_antiFib b
    push_cast
    have ha' : (8 * antiFib a : ℤ) = (2 * a + 1) ^ 2 + 7 := by exact_mod_cast ha
    have hb' : (8 * antiFib b : ℤ) = (2 * b + 1) ^ 2 + 7 := by exact_mod_cast hb
    linarith
  · rintro ⟨x, y, h⟩
    -- reduce to nonnegative representatives
    have hx2 : x ^ 2 = (x.natAbs : ℤ) ^ 2 := (Int.natAbs_sq x).symm
    have hy2 : y ^ 2 = (y.natAbs : ℤ) ^ 2 := (Int.natAbs_sq y).symm
    have hmod : ((x.natAbs : ℤ) ^ 2 + (y.natAbs : ℤ) ^ 2) % 8 = 2 := by
      rw [← hx2, ← hy2, ← h]; omega
    obtain ⟨⟨a, ha⟩, ⟨b, hb⟩⟩ := odd_of_sq_add_sq_mod_eight hmod
    have ha0 : 0 ≤ a := by omega
    have hb0 : 0 ≤ b := by omega
    refine ⟨a.toNat, b.toNat, ?_⟩
    have e1 := eight_mul_antiFib a.toNat
    have e2 := eight_mul_antiFib b.toNat
    have e1' : (8 * antiFib a.toNat : ℤ) = (2 * a + 1) ^ 2 + 7 := by
      have : ((a.toNat : ℕ) : ℤ) = a := Int.toNat_of_nonneg ha0
      exact_mod_cast (by rw [← this]; exact_mod_cast e1 :
        ((8 * antiFib a.toNat : ℕ) : ℤ) = (2 * a + 1) ^ 2 + 7)
    have e2' : (8 * antiFib b.toNat : ℤ) = (2 * b + 1) ^ 2 + 7 := by
      have : ((b.toNat : ℕ) : ℤ) = b := Int.toNat_of_nonneg hb0
      exact_mod_cast (by rw [← this]; exact_mod_cast e2 :
        ((8 * antiFib b.toNat : ℕ) : ℤ) = (2 * b + 1) ^ 2 + 7)
    rw [hx2, hy2, ha, hb] at h
    have : (m : ℤ) = antiFib a.toNat + antiFib b.toNat := by linarith
    exact_mod_cast this

/-- Natural-number form of the reduction: for `m ≥ 2`, `m` is representable iff
`8 m - 14` is a sum of two squares of natural numbers. -/
theorem isAntiFibSum_iff_nat (m : ℕ) :
    IsAntiFibSum m ↔ 2 ≤ m ∧ ∃ x y : ℕ, 8 * m - 14 = x ^ 2 + y ^ 2 := by
  rw [isAntiFibSum_iff_int]
  constructor
  · rintro ⟨x, y, h⟩
    have hm : 2 ≤ m := by nlinarith [sq_nonneg x, sq_nonneg y, sq_nonneg (x + y)]
    refine ⟨hm, x.natAbs, y.natAbs, ?_⟩
    have : ((8 * m - 14 : ℕ) : ℤ) = 8 * m - 14 := by omega
    zify; rw [this, h, sq_abs, sq_abs]
  · rintro ⟨hm, x, y, h⟩
    refine ⟨x, y, ?_⟩
    have : ((8 * m - 14 : ℕ) : ℤ) = 8 * m - 14 := by omega
    rw [← this, h]; push_cast; ring

/-- A natural number `2 n` is a sum of two squares iff `n` is. -/
lemma sq_add_sq_two_mul_iff (n : ℕ) :
    (∃ x y : ℕ, 2 * n = x ^ 2 + y ^ 2) ↔ ∃ x y : ℕ, n = x ^ 2 + y ^ 2 := by
  constructor
  · rintro ⟨x, y, h⟩
    -- `x` and `y` have the same parity
    have hpar : (x + y) % 2 = 0 := by
      rcases Nat.even_or_odd x with ⟨a, rfl⟩ | ⟨a, rfl⟩ <;>
      rcases Nat.even_or_odd y with ⟨b, rfl⟩ | ⟨b, rfl⟩ <;> ring_nf at h ⊢ <;> omega
    rcases le_total y x with hxy | hxy
    · refine ⟨(x + y) / 2, (x - y) / 2, ?_⟩
      have h1 : 2 * ((x + y) / 2) = x + y := by omega
      have h2 : 2 * ((x - y) / 2) = x - y := by omega
      have h3 : ((x - y : ℕ) : ℤ) = x - y := by omega
      have h1' : (2 * ((x + y) / 2) : ℤ) = x + y := by exact_mod_cast h1
      have h2' : (2 * ((x - y) / 2 : ℕ) : ℤ) = x - y := by rw [← h3]; exact_mod_cast h2
      have h' : (2 * n : ℤ) = x ^ 2 + y ^ 2 := by exact_mod_cast h
      zify
      nlinarith
    · refine ⟨(x + y) / 2, (y - x) / 2, ?_⟩
      have h1 : 2 * ((x + y) / 2) = x + y := by omega
      have h2 : 2 * ((y - x) / 2) = y - x := by omega
      have h3 : ((y - x : ℕ) : ℤ) = y - x := by omega
      have h1' : (2 * ((x + y) / 2) : ℤ) = x + y := by exact_mod_cast h1
      have h2' : (2 * ((y - x) / 2 : ℕ) : ℤ) = y - x := by rw [← h3]; exact_mod_cast h2
      have h' : (2 * n : ℤ) = x ^ 2 + y ^ 2 := by exact_mod_cast h
      zify
      nlinarith
  · rintro ⟨x, y, h⟩
    refine ⟨x + y, max x y - min x y, ?_⟩
    rcases le_total y x with hxy | hxy
    · rw [max_eq_left hxy, min_eq_right hxy]
      zify [hxy]; rw [h]; push_cast; ring
    · rw [max_eq_right hxy, min_eq_left hxy]
      zify [hxy]; rw [h]; push_cast; ring

/-- Representability in terms of `4 m - 7`. -/
theorem isAntiFibSum_iff_four (m : ℕ) :
    IsAntiFibSum m ↔ 2 ≤ m ∧ ∃ x y : ℕ, 4 * m - 7 = x ^ 2 + y ^ 2 := by
  rw [isAntiFibSum_iff_nat]
  have h2 : 2 * (4 * m - 7) = 8 * m - 14 := by omega
  constructor
  · rintro ⟨hm, h⟩
    exact ⟨hm, (sq_add_sq_two_mul_iff _).1 (by rwa [h2])⟩
  · rintro ⟨hm, h⟩
    exact ⟨hm, by rw [← h2]; exact (sq_add_sq_two_mul_iff _).2 h⟩

/-- **Fermat-type criterion.** `m` is a sum of two anti-Fibonacci numbers iff `2 ≤ m` and
every prime `q ≡ 3 (mod 4)` divides `4 m - 7` to an even power. -/
theorem isAntiFibSum_iff_padicVal (m : ℕ) :
    IsAntiFibSum m ↔
      2 ≤ m ∧ ∀ q : ℕ, q.Prime → q % 4 = 3 → Even (padicValNat q (4 * m - 7)) := by
  rw [isAntiFibSum_iff_four, Nat.eq_sq_add_sq_iff]
  constructor
  · rintro ⟨hm, h⟩
    refine ⟨hm, fun q hq hq4 => ?_⟩
    by_cases hd : q ∣ 4 * m - 7
    · exact h q (Nat.mem_primeFactors.2 ⟨hq, hd, by omega⟩) hq4
    · rw [padicValNat.eq_zero_of_not_dvd hd]; exact Even.zero
  · rintro ⟨hm, h⟩
    exact ⟨hm, fun q hq hq4 => h q (Nat.prime_of_mem_primeFactors hq) hq4⟩

/-- **Local obstruction.** If a prime `q ≡ 3 (mod 4)` divides `4 m - 7` exactly once,
then `m` is not a sum of two anti-Fibonacci numbers. -/
theorem not_isAntiFibSum_of_exact_dvd {m q : ℕ} (hq : q.Prime) (hq4 : q % 4 = 3)
    (h1 : q ∣ 4 * m - 7) (h2 : ¬ q ^ 2 ∣ 4 * m - 7) : ¬ IsAntiFibSum m := by
  intro hrep
  have hne : 4 * m - 7 ≠ 0 := by
    intro h0; rw [h0] at h2; exact h2 (dvd_zero _)
  haveI : Fact q.Prime := ⟨hq⟩
  have hv := ((isAntiFibSum_iff_padicVal m).1 hrep).2 q hq hq4
  have hge : 1 ≤ padicValNat q (4 * m - 7) := one_le_padicValNat_of_dvd hne h1
  have hlt : padicValNat q (4 * m - 7) < 2 := by
    by_contra hc
    exact h2 ((padicValNat_dvd_iff_le hne).2 (not_lt.1 hc))
  obtain ⟨k, hk⟩ := hv
  omega

/-- Every `m ≡ 1, 7 (mod 9)` is not representable (obstruction at `q = 3`). -/
theorem not_isAntiFibSum_of_mod_nine {m : ℕ} (h : m % 9 = 1 ∨ m % 9 = 7) :
    ¬ IsAntiFibSum m := by
  intro hrep
  have hm := two_le_of_isAntiFibSum hrep
  refine not_isAntiFibSum_of_exact_dvd (q := 3) Nat.prime_three rfl ?_ ?_ hrep <;> omega

open Classical in
/-- **The `2/9` bound.** Among `0, 1, …, 9k - 1` at least `2k` integers are not sums of two
anti-Fibonacci numbers. -/
theorem two_mul_le_card_nonrep (k : ℕ) :
    2 * k ≤ ((range (9 * k)).filter (fun m => ¬ IsAntiFibSum m)).card := by
  classical
  have hsub : (range k).image (fun j => 9 * j + 1) ∪ (range k).image (fun j => 9 * j + 7) ⊆
      (range (9 * k)).filter (fun m => ¬ IsAntiFibSum m) := by
    intro m hm
    simp only [mem_union, mem_image, mem_range] at hm
    simp only [mem_filter, mem_range]
    rcases hm with ⟨j, hj, rfl⟩ | ⟨j, hj, rfl⟩
    · exact ⟨by omega, not_isAntiFibSum_of_mod_nine (by omega)⟩
    · exact ⟨by omega, not_isAntiFibSum_of_mod_nine (by omega)⟩
  have hdisj : Disjoint ((range k).image (fun j => 9 * j + 1))
      ((range k).image (fun j => 9 * j + 7)) := by
    rw [Finset.disjoint_left]
    intro m h1 h2
    simp only [mem_image] at h1 h2
    obtain ⟨a, -, rfl⟩ := h1; obtain ⟨b, -, hb⟩ := h2; omega
  have := card_le_card hsub
  rw [card_union_of_disjoint hdisj, card_image_of_injective _ (by intro a b h; simp at h; omega),
    card_image_of_injective _ (by intro a b h; simp at h; omega), card_range] at this
  omega

end AntiFib