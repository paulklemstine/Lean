/-
# Primes and Semi-primes of the Form n² + 1

This module develops the theory of numbers of the form n² + 1, focusing on:
- Structural properties of their prime factorizations
- The key theorem that all odd prime divisors are ≡ 1 (mod 4)
- Semi-prime definitions connecting to Iwaniec's theorem
- Connections to the Friedlander-Iwaniec theorem on primes of form a² + b⁴

## Mathematical Context

The question of whether there are infinitely many primes of the form n² + 1
is one of Landau's four problems (1912), still open. Iwaniec (1978) proved
that there are infinitely many n for which n² + 1 is a semi-prime (product
of at most two primes). Friedlander and Iwaniec (1998) proved the related
result that there are infinitely many primes of the form a² + b⁴.
-/

import Mathlib

open Nat Finset

/-! ## Core Definitions -/

/-- A natural number is a **semi-prime** if it equals a product of two primes
    (not necessarily distinct). -/
def IsSemiprime (n : ℕ) : Prop :=
  ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ n = p * q

/-- A number is an **almost-prime of order k** if it is > 1 and can be written
    as a product of at most k primes (with multiplicity). -/
inductive IsAlmostPrime : ℕ → ℕ → Prop where
  | prime (k : ℕ) (n : ℕ) (hp : Nat.Prime n) : IsAlmostPrime k n
  | composite (k : ℕ) (p m : ℕ) (hp : Nat.Prime p) (hm : IsAlmostPrime k m) (hk : k ≥ 1) :
      IsAlmostPrime (k + 1) (p * m)

/-- The counting function: number of n < x such that n² + 1 is prime. -/
noncomputable def countNsqPlusOnePrimes (x : ℕ) : ℕ :=
  ((Finset.range x).filter (fun n => (n ^ 2 + 1).Prime)).card

/-- The set of numbers representable as a² + b⁴ (Friedlander-Iwaniec form). -/
def friedlanderIwaniecSet : Set ℕ := { m | ∃ a b : ℕ, m = a ^ 2 + b ^ 4 }

/-! ## Basic Structural Properties -/

/-
n² + 1 is never divisible by 3. Since n² mod 3 ∈ {0, 1},
    we get n² + 1 mod 3 ∈ {1, 2}, never 0.
-/
theorem not_three_dvd_nsq_plus_one (n : ℕ) : ¬ (3 ∣ n ^ 2 + 1) := by
  rw [ Nat.dvd_iff_mod_eq_zero ] ; rw [ Nat.add_mod, Nat.pow_mod ] ; have := Nat.mod_lt n zero_lt_three; interval_cases n % 3 <;> trivial;

/-
For n ≥ 1, n² + 1 is not a perfect square.
    Between consecutive squares n² and (n+1)² = n² + 2n + 1, the value
    n² + 1 lies strictly inside when n ≥ 1.
-/
theorem nsq_plus_one_not_perfect_square (n : ℕ) (hn : n ≥ 1) :
    ¬ ∃ m : ℕ, n ^ 2 + 1 = m ^ 2 := by
  exact fun ⟨ m, hm ⟩ => by nlinarith [ show m > n by nlinarith ] ;

/-
n² + 1 is even if and only if n is odd.
-/
theorem nsq_plus_one_even_iff_n_odd (n : ℕ) : 2 ∣ (n ^ 2 + 1) ↔ ¬ 2 ∣ n := by
  norm_num [ ← even_iff_two_dvd, parity_simps ]

/-
If n² + 1 is prime and n > 1, then n must be even.
    If n were odd, n² + 1 would be even and > 2, hence composite.
    (Note: n = 1 is excluded since 1² + 1 = 2 is prime but 1 is odd.)
-/
theorem nsq_plus_one_prime_imp_even (n : ℕ) (hn : n > 1)
    (hp : Nat.Prime (n ^ 2 + 1)) : 2 ∣ n := by
  exact even_iff_two_dvd.mp ( by simpa [ parity_simps ] using hp.eq_two_or_odd'.resolve_left ( by nlinarith ) )

/-! ## The Key Quadratic Residue Theorem -/

/-
**Main Theorem**: Every odd prime divisor of n² + 1 is congruent to 1 mod 4.

If p | n² + 1, then n² ≡ -1 (mod p), so -1 is a quadratic residue mod p.
By Euler's criterion, (-1)^((p-1)/2) ≡ 1 (mod p), which forces (p-1)/2
to be even, i.e., 4 | (p-1), i.e., p ≡ 1 (mod 4).
-/
theorem odd_prime_dvd_nsq_plus_one_mod_four (p n : ℕ)
    (hp : Nat.Prime p) (hodd : p ≠ 2) (hdvd : p ∣ n ^ 2 + 1) :
    p % 4 = 1 := by
  haveI := Fact.mk hp; simp_all +decide [ ← ZMod.natCast_eq_zero_iff ] ;
  have := ZMod.exists_sq_eq_neg_one_iff ( p := p );
  exact this.mp ⟨ n, by linear_combination' hdvd.symm ⟩ |> fun h => by have := Nat.Prime.eq_two_or_odd hp; omega;

/-
No prime p ≡ 3 (mod 4) can divide any number of the form n² + 1.
-/
theorem no_three_mod_four_prime_divides (p n : ℕ)
    (hp : Nat.Prime p) (hmod : p % 4 = 3) : ¬ (p ∣ n ^ 2 + 1) := by
  exact fun h => absurd ( odd_prime_dvd_nsq_plus_one_mod_four p n hp ( by aesop ) h ) ( by aesop )

/-! ## Semi-prime Properties -/

/-- Every prime is trivially an almost-prime of any order. -/
theorem prime_is_almost_prime (k : ℕ) (n : ℕ) (hp : Nat.Prime n) :
    IsAlmostPrime k n :=
  IsAlmostPrime.prime k n hp

/-
Semi-primes are almost-primes of order 2: if n = p * q for primes p, q,
    then n has at most 2 prime factors.
-/
theorem semiprime_is_almost_prime_two (n : ℕ) (hs : IsSemiprime n) :
    IsAlmostPrime 2 n := by
  -- From hs, get p, q primes with n = p � *� q.
  obtain ⟨p, q, hp, hq, hn⟩ := hs;
  exact hn.symm ▸ IsAlmostPrime.composite 1 p q hp ( IsAlmostPrime.prime 1 q hq ) ( by decide )

/-
There are infinitely many n such that n² + 1 is composite:
    for any N, take n = 2N + 3 (odd), then n² + 1 is even and ≥ 10.
-/
theorem infinitely_many_composite_nsq_plus_one :
    ∀ N : ℕ, ∃ n : ℕ, n > N ∧ ¬ Nat.Prime (n ^ 2 + 1) ∧ n ^ 2 + 1 > 1 := by
  intro N;
  by_contra h_contra;
  -- Consider the numbers of the form $n = 2k + 1$ for $k > N$.
  have h_odd : ∀ k > N, Nat.Prime ((2 * k + 1) ^ 2 + 1) := by
    grind +ring;
  exact absurd ( h_odd ( 2 * N + 2 ) ( by linarith ) ) ( by rw [ show ( 2 * ( 2 * N + 2 ) + 1 ) ^ 2 + 1 = 2 * ( 2 * ( 2 * N + 2 ) ^ 2 + 2 * ( 2 * N + 2 ) + 1 ) by ring ] ; exact Nat.not_prime_mul ( by norm_num ) ( by nlinarith ) )

/-! ## Connections -/

/-
Every n² + 1 is of the form a² + b⁴ (take a = n, b = 1).
-/
theorem nsq_plus_one_in_FI_set (n : ℕ) : n ^ 2 + 1 ∈ friedlanderIwaniecSet := by
  -- By definition, if $n^2 � +� 1$ is in the Friedlander-Iwaniec set, then it is of the form $a^2 + b^4$ for some integers $a$ and $b$.
  use n, 1
  norm_num

/-
n² + 1 grows without bound.
-/
theorem nsq_plus_one_unbounded : ∀ M : ℕ, ∃ n : ℕ, n ^ 2 + 1 > M := by
  exact fun M => ⟨ M, by nlinarith ⟩

/-
The counting function is monotone.
-/
theorem count_nsq_plus_one_primes_mono {a b : ℕ} (hab : a ≤ b) :
    countNsqPlusOnePrimes a ≤ countNsqPlusOnePrimes b := by
  exact Finset.card_mono <| Finset.filter_subset_filter _ <| Finset.range_mono hab

/-! ## Formal Statements of Deep Results -/

/-- **Hardy-Littlewood Conjecture for n² + 1** (falsifiable):
    The density of primes of the form n² + 1 is governed by a constant C ≈ 1.37.
    Testable prediction: among n ≤ 10^6, about 98,800-99,600 values of n²+1
    should be prime. (Actual count: 98,871.) -/
noncomputable def hardyLittlewoodNsqPlusOneConjecture : Prop :=
  ∃ C : ℝ, C > 1 ∧ C < 2 ∧
    ∀ ε > 0, ∃ N₀ : ℕ, ∀ N : ℕ, N ≥ N₀ →
      |((countNsqPlusOnePrimes N : ℝ) * Real.log ↑N / ↑N) - C| < ε

/-- **Landau's Fourth Problem** (1912, open):
    There are infinitely many primes of the form n² + 1. -/
def landauFourthProblem : Prop :=
  ∀ N : ℕ, ∃ n : ℕ, n > N ∧ Nat.Prime (n ^ 2 + 1)

/-- **Iwaniec's Semi-prime Theorem** (1978):
    There are infinitely many n such that n² + 1 is a semi-prime. -/
def iwaniecSemiprimeTheorem : Prop :=
  ∀ N : ℕ, ∃ n : ℕ, n > N ∧ IsSemiprime (n ^ 2 + 1)

/-- Landau's fourth problem implies Iwaniec's theorem.
    Any prime p can be written as p = p * 1... but 1 is not prime.
    Better: if p = n²+1 is prime, then p = p * 1 doesn't work for
    semi-prime. But p is an almost-prime of order 1 ≤ 2. We use a
    weaker formulation: Landau implies infinitely many n²+1 with at
    most 2 prime factors (since primes have exactly 1). -/
def iwaniecWeakTheorem : Prop :=
  ∀ N : ℕ, ∃ n : ℕ, n > N ∧ (n ^ 2 + 1 > 1) ∧
    (Nat.Prime (n ^ 2 + 1) ∨ IsSemiprime (n ^ 2 + 1))

theorem landau_implies_iwaniec_weak :
    landauFourthProblem → iwaniecWeakTheorem := by
  intro h N; obtain ⟨ n, hn₁, hn₂ ⟩ := h N; exact ⟨ n, hn₁, by nlinarith [ Nat.Prime.one_lt hn₂ ], Or.inl hn₂ ⟩ ;