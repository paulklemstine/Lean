import Mathlib

/-!
# Goldbach Representation Theory

This file develops the structural theory of Goldbach representations:
expressing even numbers as sums of two primes.

## Main results

* `Goldbach.goldbach_rep_odd_primes` — For even n ≥ 6, every Goldbach
  representation n = p + q has both p and q odd primes (neither can be 2).
  The key insight: if p = 2 then q = n − 2 is even and > 2, hence composite.

* `Goldbach.goldbach_rep_canonical` — Every Goldbach representation can be
  canonicalized to have p ≤ q.

* `Goldbach.goldbach_implies_chen` — Every Goldbach representation is also
  a Chen representation (sum of a prime and a number that is prime or semiprime).

* `Goldbach.semiprime_not_prime` — No semiprime is prime.

## Definitions

* `Goldbach.HasGoldbachRep` — n can be written as sum of two primes
* `Goldbach.IsSemiprime` — n is product of exactly two primes
* `Goldbach.HasChenRep` — n = p + m where p is prime, m is prime or semiprime
* `Goldbach.goldbachCount` — counts ordered Goldbach representations
-/

namespace Goldbach

/-- A natural number has a Goldbach representation if it equals the sum of two primes. -/
def HasGoldbachRep (n : ℕ) : Prop :=
  ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n

/-- A canonical Goldbach representation additionally requires p ≤ q. -/
def HasCanonicalGoldbachRep (n : ℕ) : Prop :=
  ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ p + q = n ∧ p ≤ q

/-- A natural number is semiprime if it equals the product of two primes
(not necessarily distinct). -/
def IsSemiprime (n : ℕ) : Prop :=
  ∃ p q : ℕ, Nat.Prime p ∧ Nat.Prime q ∧ n = p * q

/-- Chen representation: n = p + m where p is prime and m is either prime or semiprime.
This is the form appearing in Chen's theorem. -/
def HasChenRep (n : ℕ) : Prop :=
  ∃ p m : ℕ, Nat.Prime p ∧ (Nat.Prime m ∨ IsSemiprime m) ∧ p + m = n

/-- The Goldbach counting function: number of primes p in [2, n] such that n - p is also prime. -/
def goldbachCount (n : ℕ) : ℕ :=
  ((Finset.Icc 2 n).filter (fun p => Nat.Prime p ∧ Nat.Prime (n - p))).card

/-! ### Theorem 1: Canonicalization of Goldbach representations -/

/-
!-- Every Goldbach representation p + q = n can be rewritten with p ≤ q
by swapping p and q if necessary, using commutativity of addition. -- !--
-/
theorem goldbach_rep_canonical {n : ℕ} (h : HasGoldbachRep n) :
    HasCanonicalGoldbachRep n := by
  rcases h with ⟨ p, q, hp, hq, rfl ⟩ ; cases le_total p q <;> [ exact ⟨ p, q, hp, hq, rfl, by assumption ⟩ ; exact ⟨ q, p, hq, hp, by ring, by assumption ⟩ ] ;

/-! ### Theorem 2: Parity constraint for Goldbach representations -/

/-
!-- For even n ≥ 6, if n = p + q with p, q prime, then p ≠ 2 and q ≠ 2.
Proof: if p = 2, then q = n - 2, which is even (since n is even) and ≥ 4
(since n ≥ 6), hence not prime. Similarly for q = 2. -- !--
-/
theorem goldbach_rep_odd_primes {n p q : ℕ} (hn : Even n) (hn6 : 6 ≤ n)
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hsum : p + q = n) :
    p ≠ 2 ∧ q ≠ 2 := by
  constructor <;> intro h <;> simp_all +arith +decide [ Nat.even_iff ];
  · cases hq.eq_two_or_odd <;> omega;
  · cases Nat.Prime.eq_two_or_odd hp <;> omega

/-
Corollary: in Goldbach representations of even n ≥ 6, both primes are odd.
-/
theorem goldbach_rep_both_odd {n p q : ℕ} (hn : Even n) (hn6 : 6 ≤ n)
    (hp : Nat.Prime p) (hq : Nat.Prime q) (hsum : p + q = n) :
    ¬(2 ∣ p) ∧ ¬(2 ∣ q) := by
  have := goldbach_rep_odd_primes hn hn6 hp hq hsum;
  simp_all +decide [ Nat.Prime.dvd_iff_eq ]

/-! ### Theorem 3: Goldbach implies Chen -/

/-
!-- Every Goldbach representation is trivially a Chen representation,
since a prime is in particular "prime or semiprime". -- !--
-/
theorem goldbach_implies_chen {n : ℕ} (h : HasGoldbachRep n) :
    HasChenRep n := by
  exact ⟨ _, _, h.choose_spec.choose_spec.1, Or.inl h.choose_spec.choose_spec.2.1, h.choose_spec.choose_spec.2.2 ⟩

/-! ### Theorem 4: Semiprime structural results -/

/-
A semiprime is at least 4.
-/
theorem semiprime_ge_four {n : ℕ} (h : IsSemiprime n) : 4 ≤ n := by
  rcases h with ⟨ p, q, hp, hq, rfl ⟩ ; nlinarith [ Nat.Prime.two_le hp, Nat.Prime.two_le hq ]

/-
No semiprime is prime. This formalizes the key structural property for
Chen's theorem: the "semiprime" alternative in a Chen representation is
genuinely different from the "prime" alternative.
-/
theorem semiprime_not_prime {n : ℕ} (h : IsSemiprime n) : ¬Nat.Prime n := by
  obtain ⟨ p, q, hp, hq, rfl ⟩ := h;
  rw [ Nat.prime_mul_iff ] ; aesop

/-! ### Goldbach counting function -/

/-
The Goldbach counting function is zero for n < 4.
-/
theorem goldbachCount_lt_four {n : ℕ} (hn : n < 4) : goldbachCount n = 0 := by
  native_decide +revert

/-
If the Goldbach counting function is positive, n has a Goldbach representation.
-/
theorem goldbachCount_pos_imp_rep {n : ℕ} :
    0 < goldbachCount n → HasGoldbachRep n := by
  exact fun h => by obtain ⟨ p, hp ⟩ := Finset.card_pos.mp h; exact ⟨ p, n - p, by aesop, by aesop, by rw [ add_tsub_cancel_of_le ( by linarith [ Finset.mem_Icc.mp ( Finset.mem_filter.mp hp |>.1 ) ] ) ] ⟩ ;

end Goldbach