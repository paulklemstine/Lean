import Novelty.Basic
import Mathlib.NumberTheory.SumTwoSquares

/-!
# The additive structure of the anti-Fibonacci sequence: sums of two terms

The research brief claims that "the numbers that ARE sums of two anti-Fibonacci numbers"
form a thin set.  This file determines that set **exactly**, by reducing it to Fermat's
two-squares theorem.

For the anti-Fibonacci sequence of `Novelty.Basic` we have `8·antiFib (p+1) = (2p+1)² + 7`,
so a representation `m = antiFib a + antiFib b` is precisely a representation
`8m - 14 = x² + y²` (and the two squares are automatically odd).  Hence:

> **`m` is a sum of two anti-Fibonacci numbers ⟺ `8m - 14` is a sum of two squares
> ⟺ every prime `q ≡ 3 (mod 4)` occurs to an even power in `8m - 14`.**

The criterion is effective, and it immediately *refutes* the idea that almost every
integer is such a sum: we prove that both residue classes `m ≡ 1, 7 (mod 9)` are
completely excluded, so at least `2/9` of all integers are **not** sums of two
anti-Fibonacci numbers.

## Main results

* `AntiFibonacciSumset.eight_antiFib_succ` — `8·antiFib (p+1) = (2p+1)² + 7`.
* `AntiFibonacciSumset.sum_two_iff_sq_add_sq` — for `m ≥ 2`,
  `(∃ a b, antiFib a + antiFib b = m) ↔ ∃ x y, 8m - 14 = x² + y²`.
* `AntiFibonacciSumset.sum_two_iff_primeFactors` — the complete criterion via
  Fermat's two-squares theorem (`Nat.eq_sq_add_sq_iff`).
* `AntiFibonacciSumset.not_sum_two_of_mod_nine` — the classes `m ≡ 1, 7 (mod 9)` are
  never sums of two anti-Fibonacci numbers.
* `AntiFibonacciSumset.card_not_sum_two_ge` — quantitatively: among the first `9K + 10`
  integers at least `2K` are not sums of two anti-Fibonacci numbers, so the
  non-representable set has lower density at least `2/9`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): sums of two anti-Fibonacci numbers should be governed by a
binary quadratic form, hence by congruence/class-field data rather than by size.

Experiment (Experimenter): brute force (below) says the non-representable `2 ≤ m ≤ 40`
are exactly `7, 10, 16, 19, 21, 25, 28, 34, 35, 37`.  Every member of the residue
classes `1` and `7` mod `9` in that range (`7, 10, 16, 19, 25, 28, 34, 37`) appears,
matching the `3 ‖ 8m - 14` obstruction; the two extra entries `21, 35` come from the
prime `7 ≡ 3 (mod 4)` dividing `8m - 14` exactly once.

Analysis (Analyst): `8m - 14 = (2a-1)² + (2b-1)²`, and mod `4` the sum of two squares
equal to `8m-14 ≡ 2 (mod 4)` forces both squares odd — so no parity side conditions are
needed.  Fermat's two-squares theorem then converts representability into a statement
about the exponents of primes `≡ 3 (mod 4)`.  The prime `3` gives the cheapest
obstruction: `3 ∣ x² + y² → 3 ∣ x ∧ 3 ∣ y → 9 ∣ x² + y²`.

Critique (Critic): `8m - 14` truncates for `m ≤ 1`, so all statements carry `2 ≤ m`
(and indeed `m = 1` is *not* a sum of two anti-Fibonacci numbers, the smallest sum being
`1 + 1 = 2`).  Representations with index `0` are harmless because `antiFib 0 = antiFib 1`,
which is handled explicitly rather than assumed.
-- !-- Lab Notes -- !--
-/

open AntiFibonacci

namespace AntiFibonacciSumset

/-- `8·antiFib (p+1) = (2p+1)² + 7`: the quadratic fingerprint of an anti-Fibonacci term. -/
theorem eight_antiFib_succ (p : ℕ) : 8 * antiFib (p + 1) = (2 * p + 1) ^ 2 + 7 := by
  have h := antiFib_closed (p + 1)
  nlinarith [h]

/-- Indices may always be taken positive, since `antiFib 0 = antiFib 1 = 1`. -/
theorem exists_pos_index {m : ℕ} (h : ∃ a b, antiFib a + antiFib b = m) :
    ∃ p q, antiFib (p + 1) + antiFib (q + 1) = m := by
  obtain ⟨a, b, hab⟩ := h
  refine ⟨max a 1 - 1, max b 1 - 1, ?_⟩
  have ha : antiFib (max a 1 - 1 + 1) = antiFib a := by
    rcases Nat.eq_zero_or_pos a with rfl | ha
    · rfl
    · congr 1; omega
  have hb : antiFib (max b 1 - 1 + 1) = antiFib b := by
    rcases Nat.eq_zero_or_pos b with rfl | hb
    · rfl
    · congr 1; omega
  rw [ha, hb]; exact hab

/-- Any representation of `8m - 14` as a sum of two squares has both squares odd. -/
theorem odd_of_sq_add_sq {m x y : ℕ} (hm : 2 ≤ m) (h : 8 * m - 14 = x ^ 2 + y ^ 2) :
    x % 2 = 1 ∧ y % 2 = 1 := by
  by_contra hcon
  have hx : x = 2 * (x / 2) + x % 2 := by omega
  have hy : y = 2 * (y / 2) + y % 2 := by omega
  set u := x / 2
  set v := y / 2
  have hx2 : x % 2 = 0 ∨ x % 2 = 1 := by omega
  have hy2 : y % 2 = 0 ∨ y % 2 = 1 := by omega
  rcases hx2 with h0 | h1 <;> rcases hy2 with k0 | k1
  · have ex : x ^ 2 = 4 * (u * u) := by
      rw [show x = 2 * u by omega]; ring
    have ey : y ^ 2 = 4 * (v * v) := by
      rw [show y = 2 * v by omega]; ring
    omega
  · have ex : x ^ 2 = 4 * (u * u) := by
      rw [show x = 2 * u by omega]; ring
    have ey : y ^ 2 = 4 * (v * v) + 4 * v + 1 := by
      rw [show y = 2 * v + 1 by omega]; ring
    omega
  · have ex : x ^ 2 = 4 * (u * u) + 4 * u + 1 := by
      rw [show x = 2 * u + 1 by omega]; ring
    have ey : y ^ 2 = 4 * (v * v) := by
      rw [show y = 2 * v by omega]; ring
    omega
  · exact hcon ⟨h1, k1⟩

/-- **Reduction to two squares.**  For `m ≥ 2`, `m` is a sum of two anti-Fibonacci
numbers iff `8m - 14` is a sum of two squares. -/
theorem sum_two_iff_sq_add_sq {m : ℕ} (hm : 2 ≤ m) :
    (∃ a b, antiFib a + antiFib b = m) ↔ ∃ x y, 8 * m - 14 = x ^ 2 + y ^ 2 := by
  constructor
  · intro h
    obtain ⟨p, q, hpq⟩ := exists_pos_index h
    refine ⟨2 * p + 1, 2 * q + 1, ?_⟩
    have hp := eight_antiFib_succ p
    have hq := eight_antiFib_succ q
    have : 8 * (antiFib (p + 1) + antiFib (q + 1)) = (2 * p + 1) ^ 2 + (2 * q + 1) ^ 2 + 14 := by
      omega
    rw [hpq] at this
    omega
  · rintro ⟨x, y, hxy⟩
    obtain ⟨hx, hy⟩ := odd_of_sq_add_sq hm hxy
    obtain ⟨p, rfl⟩ : ∃ p, x = 2 * p + 1 := ⟨x / 2, by omega⟩
    obtain ⟨q, rfl⟩ : ∃ q, y = 2 * q + 1 := ⟨y / 2, by omega⟩
    refine ⟨p + 1, q + 1, ?_⟩
    have hp := eight_antiFib_succ p
    have hq := eight_antiFib_succ q
    omega

/-- **Complete criterion** (Fermat's two-squares theorem).  For `m ≥ 2`, `m` is a sum of
two anti-Fibonacci numbers iff every prime `q ≡ 3 (mod 4)` divides `8m - 14` to an even
power. -/
theorem sum_two_iff_primeFactors {m : ℕ} (hm : 2 ≤ m) :
    (∃ a b, antiFib a + antiFib b = m) ↔
      ∀ q ∈ (8 * m - 14).primeFactors, q % 4 = 3 → Even (padicValNat q (8 * m - 14)) := by
  rw [sum_two_iff_sq_add_sq hm]
  exact Nat.eq_sq_add_sq_iff

/-! ### The prime `3` obstruction and a positive density of non-representable integers -/

/-- If `3` divides a sum of two squares, it divides both of them. -/
theorem three_dvd_of_sq_add_sq {x y : ℕ} (h : 3 ∣ x ^ 2 + y ^ 2) : 3 ∣ x ∧ 3 ∣ y := by
  obtain ⟨u, r, hr, rfl⟩ : ∃ u r, r < 3 ∧ x = 3 * u + r :=
    ⟨x / 3, x % 3, by omega, by omega⟩
  obtain ⟨v, t, ht, rfl⟩ : ∃ v t, t < 3 ∧ y = 3 * v + t :=
    ⟨y / 3, y % 3, by omega, by omega⟩
  have hxsq : (3 * u + r) ^ 2 = 3 * (3 * (u * u) + 2 * u * r) + r * r := by ring
  have hysq : (3 * v + t) ^ 2 = 3 * (3 * (v * v) + 2 * v * t) + t * t := by ring
  have hrs : 3 ∣ r * r + t * t := by omega
  have hzero : r = 0 ∧ t = 0 := by
    interval_cases r <;> interval_cases t <;> omega
  exact ⟨⟨u, by omega⟩, ⟨v, by omega⟩⟩

/-- A number divisible by `3` but not by `9` is not a sum of two squares. -/
theorem not_sq_add_sq_of_three_exact {n : ℕ} (h3 : 3 ∣ n) (h9 : ¬ (9 ∣ n)) :
    ¬ ∃ x y, n = x ^ 2 + y ^ 2 := by
  rintro ⟨x, y, rfl⟩
  obtain ⟨hx, hy⟩ := three_dvd_of_sq_add_sq h3
  obtain ⟨u, rfl⟩ := hx
  obtain ⟨v, rfl⟩ := hy
  exact h9 ⟨u ^ 2 + v ^ 2, by ring⟩

/-- **The excluded residue classes.**  No integer congruent to `1` or `7` modulo `9`
is a sum of two anti-Fibonacci numbers. -/
theorem not_sum_two_of_mod_nine {m : ℕ} (hm : 2 ≤ m) (h : m % 9 = 1 ∨ m % 9 = 7) :
    ¬ ∃ a b, antiFib a + antiFib b = m := by
  rw [sum_two_iff_sq_add_sq hm]
  refine not_sq_add_sq_of_three_exact ?_ ?_
  · omega
  · omega

/-- Concretely: `9k + 10` and `9k + 7` are never sums of two anti-Fibonacci numbers. -/
theorem not_sum_two_family (k : ℕ) :
    (¬ ∃ a b, antiFib a + antiFib b = 9 * k + 10) ∧
      (¬ ∃ a b, antiFib a + antiFib b = 9 * k + 7) := by
  constructor
  · exact not_sum_two_of_mod_nine (by omega) (Or.inl (by omega))
  · exact not_sum_two_of_mod_nine (by omega) (Or.inr (by omega))

open Finset Classical in
/-- **Positive lower density of non-representable integers.**  Among `0, …, 9K + 9` at
least `2K` integers are not sums of two anti-Fibonacci numbers; hence the
non-representable set has lower density at least `2/9`, refuting any claim that almost
all integers are sums of two anti-Fibonacci numbers. -/
theorem card_not_sum_two_ge (K : ℕ) :
    2 * K ≤ ((range (9 * K + 10)).filter
      fun m => ¬ ∃ a b, antiFib a + antiFib b = m).card := by
  classical
  set S : Finset ℕ := (range K).image fun k => 9 * k + 7 with hS
  set T : Finset ℕ := (range K).image fun k => 9 * k + 10 with hT
  have hSinj : S.card = K := by
    rw [hS, Finset.card_image_of_injective _ (fun a b hab => by omega), Finset.card_range]
  have hTinj : T.card = K := by
    rw [hT, Finset.card_image_of_injective _ (fun a b hab => by omega), Finset.card_range]
  have hdisj : Disjoint S T := by
    rw [Finset.disjoint_left]
    intro x hx hxT
    rw [hS, Finset.mem_image] at hx
    rw [hT, Finset.mem_image] at hxT
    obtain ⟨k, -, hk⟩ := hx
    obtain ⟨l, -, hl⟩ := hxT
    omega
  have hsub : S ∪ T ⊆ (range (9 * K + 10)).filter
      fun m => ¬ ∃ a b, antiFib a + antiFib b = m := by
    intro x hx
    rw [Finset.mem_union] at hx
    rw [Finset.mem_filter, Finset.mem_range]
    rcases hx with hx | hx
    · rw [hS, Finset.mem_image] at hx
      obtain ⟨k, hk, rfl⟩ := hx
      rw [Finset.mem_range] at hk
      exact ⟨by omega, (not_sum_two_family k).2⟩
    · rw [hT, Finset.mem_image] at hx
      obtain ⟨k, hk, rfl⟩ := hx
      rw [Finset.mem_range] at hk
      exact ⟨by omega, (not_sum_two_family k).1⟩
  have hcard : (S ∪ T).card = 2 * K := by
    rw [Finset.card_union_of_disjoint hdisj, hSinj, hTinj]; ring
  calc 2 * K = (S ∪ T).card := hcard.symm
    _ ≤ _ := Finset.card_le_card hsub

/-! ### Experimental data -/

section Evidence

/-- Brute-force test of representability as a sum of two anti-Fibonacci numbers. -/
def representable (m : ℕ) : Bool :=
  (List.range (m + 1)).any fun a =>
    (List.range (m + 1)).any fun b => antiFib a + antiFib b == m

/-- info: [7, 10, 16, 19, 21, 25, 28, 34, 35, 37] -/
#guard_msgs in
#eval ((List.range 41).filter fun m => 2 ≤ m && !representable m)

/-- info: true -/
#guard_msgs in
#eval (List.range 60).all fun m => m < 2 ||
  (representable m == ((List.range (8 * m)).any fun x =>
    (List.range (8 * m)).any fun y => 8 * m - 14 == x ^ 2 + y ^ 2))

/-- info: true -/
#guard_msgs in
#eval (List.range 30).all fun k => !representable (9 * k + 7) && !representable (9 * k + 10)

end Evidence

end AntiFibonacciSumset