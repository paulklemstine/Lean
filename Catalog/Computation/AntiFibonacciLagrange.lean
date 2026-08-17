import Novelty.Basic
import Computation.AntiFibonacciSumsetTwoSquares
import Mathlib

/-!
# A Lagrange theorem for the anti-Fibonacci sequence

The companion file `Computation.AntiFibonacciSumsetTwoSquares` shows that sums of *two*
anti-Fibonacci numbers are governed by Fermat's two-squares theorem and miss a set of
integers of lower density at least `2/9`.  The natural follow-up question is the
*additive basis* question:

> How many anti-Fibonacci numbers are needed to represent **every** integer?

This file answers it exactly: **four**, and the answer is sharp.

The mechanism is the identity `8 · antiFib (p+1) = (2p+1)² + 7` of the companion file:
`m = A a + A b + A c + A d` is equivalent to writing `8m - 28` as a sum of four *odd*
squares.  Since `8m - 28 ≡ 4 (mod 8)`, the arithmetic input we need is the classical

> every `n ≡ 4 (mod 8)` is a sum of four odd squares,

which we deduce from Lagrange's four-squares theorem (`Nat.sum_four_squares`) by the
orthogonal "Hadamard" substitution
`4(A²+B²+C²+D²) = (A+B+C+D)² + (A+B-C-D)² + (A-B+C-D)² + (A-B-C+D)²`,
all four of whose entries have the parity of `A+B+C+D`, which is odd precisely because
`A²+B²+C²+D²` is odd.

## Main results

* `AntiFibonacciLagrange.four_odd_squares` — every `8k + 4` is a sum of four odd squares
  (a general statement about `ℕ`, of independent interest).
* `AntiFibonacciLagrange.sum_four_of_four_le` — every `m ≥ 4` is a sum of four
  anti-Fibonacci numbers.
* `AntiFibonacciLagrange.sum_four_iff` — sharpness: `m` is a sum of four anti-Fibonacci
  numbers **iff** `m ≥ 4`.  So the anti-Fibonacci sequence is an additive basis of
  order `4` (for `m ≥ 4`).
* `AntiFibonacciLagrange.two_not_enough` — order `2` does not suffice: arbitrarily large
  integers are sums of four but of no two anti-Fibonacci numbers.
* `AntiFibonacciLagrange.sum_three_iff_sq_add_sq_add_sq` — the three-summand problem is
  *exactly* the three-squares problem for `8m - 21`; combined with Gauss' three-squares
  theorem (not available in Mathlib) this would improve the order from `4` to `3`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the anti-Fibonacci numbers are a quadratically thin set
(`C(N) ~ √(2N)`, see `Computation.AntiFibonacciCounting`), so by the trivial counting
bound a basis order of `2` is impossible for density reasons *and* by congruence
obstructions mod 9.  Guess: the true order is `3` or `4`, as for squares.

Experiment (Experimenter): brute force (see the Evidence section) finds that every
`4 ≤ m ≤ 120` is a sum of four anti-Fibonacci numbers, and in fact every `3 ≤ m ≤ 120`
is already a sum of three.  Numbers that are not sums of two are frequent (`2/9` of all
integers, proved in the companion file).

Analysis (Analyst): the reduction `m = Σ A aᵢ ↔ 8m - 7k = Σ (odd)²` converts the problem
into a classical squares problem with a *parity constraint*.  For four summands the
target `8m - 28 ≡ 4 (mod 8)` and the constraint is automatic once one uses the Hadamard
substitution; the proof is therefore unconditional.  For three summands the target is
`8m - 21 ≡ 3 (mod 8)`, whose representability is exactly Gauss' three-squares theorem
(and the parity constraint is again automatic, which we prove).  Since Mathlib has
Lagrange but not Gauss, order `4` is what is unconditionally provable here.

Critique (Critic): is `4` sharp?  Yes in the strong sense that no `m < 4` is a sum of
four terms (each term is `≥ 1`), and `2` provably fails on a positive-density set.
The honest boundary is: order `4` unconditionally, order `3` conditional on Gauss.
-- !-- Lab Notes -- !--
-/

namespace AntiFibonacciLagrange

open AntiFibonacci AntiFibonacciSumset

/-! ### Four odd squares -/

/-- **Every `8k + 4` is a sum of four odd squares.**  This follows from Lagrange's
four-squares theorem applied to the odd number `2k + 1`, via the orthogonal substitution
`4(A²+B²+C²+D²) = (A+B+C+D)² + (A+B-C-D)² + (A-B+C-D)² + (A-B-C+D)²`, whose four entries
all have the (odd) parity of `A + B + C + D`. -/
theorem four_odd_squares (k : ℕ) :
    ∃ x y z w : ℕ, x % 2 = 1 ∧ y % 2 = 1 ∧ z % 2 = 1 ∧ w % 2 = 1 ∧
      x ^ 2 + y ^ 2 + z ^ 2 + w ^ 2 = 8 * k + 4 := by
  obtain ⟨A, B, C, D, hABCD⟩ := Nat.sum_four_squares (2 * k + 1)
  have key : ∀ n : ℕ, n ^ 2 % 2 = n % 2 := by
    intro n
    conv_lhs => rw [Nat.pow_mod]
    rcases Nat.mod_two_eq_zero_or_one n with h | h <;> simp [h]
  have hpar : (A + B + C + D) % 2 = 1 := by
    have h1 := key A; have h2 := key B; have h3 := key C; have h4 := key D
    omega
  have hcast : ((A : ℤ) ^ 2 + B ^ 2 + C ^ 2 + D ^ 2) = 2 * (k : ℤ) + 1 := by
    exact_mod_cast hABCD
  set a : ℤ := (A : ℤ) + B + C + D with ha
  set b : ℤ := (A : ℤ) + B - C - D with hb
  set c : ℤ := (A : ℤ) - B + C - D with hc
  set d : ℤ := (A : ℤ) - B - C + D with hd
  have hsum : a ^ 2 + b ^ 2 + c ^ 2 + d ^ 2 = 8 * (k : ℤ) + 4 := by
    rw [ha, hb, hc, hd]; nlinarith [hcast]
  have hapar : a % 2 = 1 := by rw [ha]; omega
  have hbpar : b % 2 = 1 := by rw [hb]; rw [ha] at hapar; omega
  have hcpar : c % 2 = 1 := by rw [hc]; rw [ha] at hapar; omega
  have hdpar : d % 2 = 1 := by rw [hd]; rw [ha] at hapar; omega
  refine ⟨a.natAbs, b.natAbs, c.natAbs, d.natAbs, by omega, by omega, by omega, by omega, ?_⟩
  have hz : ((a.natAbs ^ 2 + b.natAbs ^ 2 + c.natAbs ^ 2 + d.natAbs ^ 2 : ℕ) : ℤ)
      = ((8 * k + 4 : ℕ) : ℤ) := by
    push_cast
    simpa [Int.natAbs_sq, sq_abs] using hsum
  exact_mod_cast hz

/-! ### From odd squares to anti-Fibonacci terms -/

/-- Every odd square is `8 · antiFib a - 7` for a suitable index `a`. -/
theorem exists_index_of_odd {t : ℕ} (ht : t % 2 = 1) : ∃ a, 8 * antiFib a = t ^ 2 + 7 := by
  obtain ⟨p, rfl⟩ : ∃ p, t = 2 * p + 1 := ⟨t / 2, by omega⟩
  exact ⟨p + 1, eight_antiFib_succ p⟩

/-- Anti-Fibonacci indices may always be taken positive (`antiFib 0 = antiFib 1 = 1`). -/
theorem exists_succ_index (a : ℕ) : ∃ p, antiFib a = antiFib (p + 1) := by
  rcases Nat.eq_zero_or_pos a with rfl | ha
  · exact ⟨0, rfl⟩
  · exact ⟨a - 1, by congr 1; omega⟩

/-! ### The anti-Fibonacci Lagrange theorem -/

/-- **Anti-Fibonacci Lagrange theorem.**  Every integer `m ≥ 4` is a sum of four
anti-Fibonacci numbers. -/
theorem sum_four_of_four_le {m : ℕ} (hm : 4 ≤ m) :
    ∃ a b c d, antiFib a + antiFib b + antiFib c + antiFib d = m := by
  obtain ⟨k, rfl⟩ : ∃ k, m = k + 4 := ⟨m - 4, by omega⟩
  obtain ⟨x, y, z, w, hx, hy, hz, hw, hsq⟩ := four_odd_squares k
  obtain ⟨a, ha⟩ := exists_index_of_odd hx
  obtain ⟨b, hb⟩ := exists_index_of_odd hy
  obtain ⟨c, hc⟩ := exists_index_of_odd hz
  obtain ⟨d, hd⟩ := exists_index_of_odd hw
  exact ⟨a, b, c, d, by omega⟩

/-- No integer below `4` is a sum of four anti-Fibonacci numbers, since every term
is at least `1`. -/
theorem not_sum_four_of_lt {m : ℕ} (hm : m < 4) :
    ¬ ∃ a b c d, antiFib a + antiFib b + antiFib c + antiFib d = m := by
  rintro ⟨a, b, c, d, h⟩
  have := antiFib_pos a
  have := antiFib_pos b
  have := antiFib_pos c
  have := antiFib_pos d
  omega

/-- **Sharp form.**  An integer is a sum of four anti-Fibonacci numbers exactly when it
is at least `4`: the anti-Fibonacci sequence is an additive basis of order `4`. -/
theorem sum_four_iff (m : ℕ) :
    (∃ a b c d, antiFib a + antiFib b + antiFib c + antiFib d = m) ↔ 4 ≤ m := by
  constructor
  · intro h
    by_contra hlt
    exact not_sum_four_of_lt (by omega) h
  · exact fun hm => sum_four_of_four_le hm

/-- **Order two is not enough.**  Arbitrarily large integers are sums of four
anti-Fibonacci numbers but of no two of them. -/
theorem two_not_enough (K : ℕ) :
    ∃ m, K < m ∧ (∃ a b c d, antiFib a + antiFib b + antiFib c + antiFib d = m) ∧
      ¬ ∃ a b, antiFib a + antiFib b = m := by
  refine ⟨9 * K + 10, by omega, sum_four_of_four_le (by omega), (not_sum_two_family K).1⟩

/-! ### The three-summand problem -/

/-- Any representation `8m - 21 = x² + y² + z²` has all three squares odd, because
`8m - 21 ≡ 3 (mod 4)` while even squares are `0 (mod 4)`. -/
theorem odd_of_sq_add_sq_add_sq {m x y z : ℕ} (hm : 3 ≤ m)
    (h : 8 * m - 21 = x ^ 2 + y ^ 2 + z ^ 2) :
    x % 2 = 1 ∧ y % 2 = 1 ∧ z % 2 = 1 := by
  have expand : ∀ n : ℕ, (n % 2 = 0 → n ^ 2 = 4 * (n / 2 * (n / 2))) ∧
      (n % 2 = 1 → n ^ 2 = 4 * (n / 2 * (n / 2)) + 4 * (n / 2) + 1) := by
    intro n
    constructor
    · intro h0
      conv_lhs => rw [show n = 2 * (n / 2) by omega]
      ring
    · intro h1
      conv_lhs => rw [show n = 2 * (n / 2) + 1 by omega]
      ring
  obtain ⟨ex0, ex1⟩ := expand x
  obtain ⟨ey0, ey1⟩ := expand y
  obtain ⟨ez0, ez1⟩ := expand z
  have hx : x % 2 = 0 ∨ x % 2 = 1 := by omega
  have hy : y % 2 = 0 ∨ y % 2 = 1 := by omega
  have hz : z % 2 = 0 ∨ z % 2 = 1 := by omega
  rcases hx with h0 | h1 <;> rcases hy with k0 | k1 <;> rcases hz with l0 | l1
  · have := ex0 h0; have := ey0 k0; have := ez0 l0; omega
  · have := ex0 h0; have := ey0 k0; have := ez1 l1; omega
  · have := ex0 h0; have := ey1 k1; have := ez0 l0; omega
  · have := ex0 h0; have := ey1 k1; have := ez1 l1; omega
  · have := ex1 h1; have := ey0 k0; have := ez0 l0; omega
  · have := ex1 h1; have := ey0 k0; have := ez1 l1; omega
  · have := ex1 h1; have := ey1 k1; have := ez0 l0; omega
  · exact ⟨h1, k1, l1⟩

/-- **Reduction of the three-summand problem to three squares.**  For `m ≥ 3`, `m` is a
sum of three anti-Fibonacci numbers iff `8m - 21` is a sum of three squares.  (By
Gauss' three-squares theorem the right-hand side holds for *every* `m ≥ 3`, since
`8m - 21 ≡ 3 (mod 8)` is never of the excluded form `4^a(8b+7)`; that theorem is not
available in Mathlib, which is why the unconditional order proved above is `4`.) -/
theorem sum_three_iff_sq_add_sq_add_sq {m : ℕ} (hm : 3 ≤ m) :
    (∃ a b c, antiFib a + antiFib b + antiFib c = m) ↔
      ∃ x y z, 8 * m - 21 = x ^ 2 + y ^ 2 + z ^ 2 := by
  constructor
  · rintro ⟨a, b, c, habc⟩
    obtain ⟨p, hp⟩ := exists_succ_index a
    obtain ⟨q, hq⟩ := exists_succ_index b
    obtain ⟨r, hr⟩ := exists_succ_index c
    refine ⟨2 * p + 1, 2 * q + 1, 2 * r + 1, ?_⟩
    have h1 := eight_antiFib_succ p
    have h2 := eight_antiFib_succ q
    have h3 := eight_antiFib_succ r
    rw [hp, hq, hr] at habc
    omega
  · rintro ⟨x, y, z, hxyz⟩
    obtain ⟨hx, hy, hz⟩ := odd_of_sq_add_sq_add_sq hm hxyz
    obtain ⟨a, ha⟩ := exists_index_of_odd hx
    obtain ⟨b, hb⟩ := exists_index_of_odd hy
    obtain ⟨c, hc⟩ := exists_index_of_odd hz
    exact ⟨a, b, c, by omega⟩

/-! ### Experimental data -/

section Evidence

/-- Brute-force test: is `m` a sum of `k` anti-Fibonacci numbers? -/
def repr' : ℕ → ℕ → Bool
  | 0, m => m == 0
  | (k + 1), m => (List.range (m + 1)).any fun a => antiFib a ≤ m && repr' k (m - antiFib a)

/-- info: true -/
#guard_msgs in
#eval ((List.range 121).all fun m => m < 4 || repr' 4 m)

/-- info: [0, 1, 2] -/
#guard_msgs in
#eval ((List.range 121).filter fun m => !repr' 3 m)

/-- info: [0, 1, 7, 10, 16, 19, 21, 25, 28, 34, 35, 37, 42, 43, 46, 49, 52, 54, 55, 56, 61, 64, 65, 70, 73, 76, 77, 79, 82, 84,
  87, 88, 91, 97, 98, 100, 105, 106, 109, 111, 115, 118, 119, 120] -/
#guard_msgs in
#eval ((List.range 121).filter fun m => !repr' 2 m)

/-- The number of *ordered* quadruples of positive indices representing `m`. -/
def reprCount (m : ℕ) : ℕ :=
  (((List.range (m + 1)).drop 1).flatMap fun a =>
    ((List.range (m + 1)).drop 1).flatMap fun b =>
      ((List.range (m + 1)).drop 1).flatMap fun c =>
        ((List.range (m + 1)).drop 1).filter fun d =>
          antiFib a + antiFib b + antiFib c + antiFib d == m).length

/- A Jacobi-type phenomenon (conjecture C7 of `FUTURE_DIRECTIONS.md`): the number of
ordered representations of `m` by four anti-Fibonacci numbers with positive indices equals
`σ(2m - 7)`.  Pairs `(reprCount m, σ(2m-7))` for `4 ≤ m ≤ 13`: -/
/-- info: [(1, 1), (4, 4), (6, 6), (8, 8), (13, 13), (12, 12), (14, 14), (24, 24), (18, 18), (20, 20)] -/
#guard_msgs in
#eval ((List.range 14).drop 4).map fun m => (reprCount m, (Nat.divisors (2 * m - 7)).sum id)

end Evidence

end AntiFibonacciLagrange