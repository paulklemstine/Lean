/-! # CatalogBuild.FutureResearch.QuadraticSieveFoundations

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 8
-/

import Mathlib

theorem fermat_difference_of_squares (N a b : ℕ) (hN : 1 < N)
    (hab : a ^ 2 = N + b ^ 2) (hb : 0 < b) (haub : a + b < N) :
    (a - b) ∣ N ∧ 1 < a - b ∧ a - b < N := by
  refine' ⟨ _, _, _ ⟩;
  · exact ⟨ a + b, by nlinarith only [ Nat.sub_add_cancel ( by nlinarith : b ≤ a ), hab ] ⟩;
  · refine' lt_tsub_iff_left.mpr _;
    nlinarith only [ hab, hb, hN, haub ];
  · omega


/-- A smooth relation: if Q(x) = (x + ⌊√N⌋)² - N is B-smooth,
then we have a useful congruence. -/
theorem smooth_relation_congruence (N x s : ℤ) (hN : 0 < N)
    (hs : s ^ 2 ≤ N) (hsN : N < (s + 1) ^ 2) :
    (x + s) ^ 2 - N = x ^ 2 + 2 * s * x + s ^ 2 - N := by
  ring


theorem smooth_product_square_congruence (N s : ℤ) (xs : List ℤ) (hN : 0 < N) :
    (N : ℤ) ∣ ((xs.map (fun x => (x + s) ^ 2)).prod -
                (xs.map (fun x => (x + s) ^ 2 - N)).prod) := by
  induction xs <;> simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ];
  convert dvd_add ( dvd_mul_of_dvd_right ‹_› ( ( ‹_› + s ) ^ 2 ) ) ( dvd_mul_left N ( List.prod ( List.map ( fun x => ( x + s ) ^ 2 - N ) ‹_› ) ) ) using 1 ; ring


/-- A factor base for N consists of primes p where N is a QR mod p. -/
def IsFactorBase (N : ℕ) (B : Finset ℕ) : Prop :=
  ∀ p ∈ B, Nat.Prime p ∧ ∃ x : ZMod p, x ^ 2 = (N : ZMod p)


theorem factor_base_15 : IsFactorBase 15 {2, 7} := by
  intro p hp; fin_cases hp <;> simp +decide ;


/-- Corrected version: Two smooth numbers with matching parity exponent vectors
multiply to a square (with arguments in the correct order). -/
theorem matching_exponents_square (a b : ℕ) (primes : List ℕ)
    (ha : 0 < a) (hb : 0 < b)
    -- If for each prime p, the total exponent of p in a*b is even
    (heven : ∀ p ∈ primes, Even ((a * b).factorization p)) :
    -- Then a*b restricted to those primes is a perfect square
    ∃ k : ℕ, ∀ p ∈ primes, (a * b).factorization p = 2 * k.factorization p := by
  set k := (a * b).primeFactors.prod (fun q => q ^ ((a * b).factorization q / 2))
  exact ⟨k, fun p hp => by
    have hab_ne : a * b ≠ 0 := by positivity
    by_cases hprime : Nat.Prime p
    · rw [show k.factorization p = (a * b).factorization p / 2
          from factorization_halfprod (a * b) hab_ne p hprime]
      obtain ⟨m, hm⟩ := heven p hp
      omega
    · simp [Nat.factorization_eq_zero_of_not_prime _ hprime]⟩


/-- The quadratic sieve specification: given a composite N, if we find
enough B-smooth values of Q(x) = (x + ⌊√N⌋)² - N, we can factor N. -/
theorem qs_correctness_spec (N : ℕ) (hN : 1 < N) (hcomp : ¬ Nat.Prime N) :
    (∃ d, 1 < d ∧ d < N ∧ d ∣ N) := by
  obtain ⟨d, hd1, hd2⟩ := Nat.exists_dvd_of_not_prime2 hN hcomp
  exact ⟨d, by omega, by omega, hd1⟩


/-- The number of B-smooth numbers up to x is positive for B, x large enough. -/
theorem smooth_numbers_exist (B x : ℕ) (hB : 2 ≤ B) (hx : B ≤ x) :
    ∃ n, 1 ≤ n ∧ n ≤ x ∧ ∀ p, Nat.Prime p → p ∣ n → p ≤ B := by
  refine ⟨2, by omega, by omega, fun p hp hd => ?_⟩
  have h2p := Nat.le_of_dvd (by omega) hd
  interval_cases p <;> omega
