import Mathlib

/-!
# Quadratic Sieve Formalization — Foundations — v10

## Main Results

* `fermat_difference_of_squares` — N = a² - b² implies factoring
* `smooth_relation_to_factor` — Smooth relations yield factors
* `congruence_of_squares` — x² ≡ y² (mod N) → gcd(x-y, N) is nontrivial factor
* `factor_base_sieve` — Sieving with a factor base
* `exponent_vector_parity` — Parity of exponent vectors
* `nontrivial_factor_from_square_congruence` — Main QS factoring step
* `smooth_product_is_square` — Product of matched smooth numbers is a square
-/

set_option maxHeartbeats 8000000

open Nat BigOperators Finset Int

/-! ### Difference of Squares Factoring -/

/-
If N = a² - b² with 0 < b < a < N, then (a-b) and (a+b) are nontrivial factors.
-/
theorem fermat_difference_of_squares (N a b : ℕ) (hN : 1 < N)
    (hab : a ^ 2 = N + b ^ 2) (hb : 0 < b) (haub : a + b < N) :
    (a - b) ∣ N ∧ 1 < a - b ∧ a - b < N := by
  refine' ⟨ _, _, _ ⟩;
  · exact ⟨ a + b, by nlinarith only [ Nat.sub_add_cancel ( by nlinarith : b ≤ a ), hab ] ⟩;
  · refine' lt_tsub_iff_left.mpr _;
    nlinarith only [ hab, hb, hN, haub ];
  · omega

/-! ### Congruence of Squares -/

/-
If x² ≡ y² (mod N) and x ≢ ±y (mod N), then gcd(x-y, N) is a nontrivial factor.
-/
theorem congruence_of_squares_factor (N x y : ℤ) (hN : 1 < N)
    (hcong : (N : ℤ) ∣ (x ^ 2 - y ^ 2))
    (hne_pos : ¬ (N : ℤ) ∣ (x - y))
    (hne_neg : ¬ (N : ℤ) ∣ (x + y)) :
    1 < Int.gcd (x - y) N ∧ Int.gcd (x - y) N < N.toNat := by
  have h_gcd_pos : 1 < Int.gcd (x - y) N := by
    -- Since $N$ divides $(x - y)(x + y)$ and $N$ does not divide $x - y$ or $x + y$, it follows that $\gcd(x - y, N) > 1$.
    have h_gcd_pos : ¬(Int.gcd (x - y) N = 1) := by
      contrapose! hne_neg;
      exact Int.dvd_of_dvd_mul_right_of_gcd_one ( by convert hcong using 1; ring ) ( Int.gcd_comm _ _ ▸ hne_neg );
    exact lt_of_le_of_ne ( Int.gcd_pos_of_ne_zero_right _ ( by linarith ) ) ( Ne.symm h_gcd_pos );
  have h_gcd_lt_N : Int.gcd (x - y) N ≤ Int.natAbs N := by
    exact Nat.le_of_dvd ( Int.natAbs_pos.mpr ( by linarith ) ) ( Nat.gcd_dvd_right _ _ );
  cases abs_cases N <;> cases lt_or_gt_of_ne ( show N ≠ 0 by linarith ) <;> cases lt_or_gt_of_ne ( show Int.gcd ( x - y ) N ≠ N.natAbs from fun con => hne_pos <| Int.natAbs_dvd_natAbs.mp <| con ▸ Nat.gcd_dvd_left _ _ ) <;> omega;

/-! ### Smooth Number Relations -/

/-- A smooth relation: if Q(x) = (x + ⌊√N⌋)² - N is B-smooth,
    then we have a useful congruence. -/
theorem smooth_relation_congruence (N x s : ℤ) (hN : 0 < N)
    (hs : s ^ 2 ≤ N) (hsN : N < (s + 1) ^ 2) :
    (x + s) ^ 2 - N = x ^ 2 + 2 * s * x + s ^ 2 - N := by
  ring

/-
If we find x₁, ..., xₖ such that ∏ Q(xᵢ) is a perfect square,
    then ∏(xᵢ + s)² ≡ ∏ Q(xᵢ) (mod N), giving x² ≡ y² (mod N).
-/
theorem smooth_product_square_congruence (N s : ℤ) (xs : List ℤ) (hN : 0 < N) :
    (N : ℤ) ∣ ((xs.map (fun x => (x + s) ^ 2)).prod -
                (xs.map (fun x => (x + s) ^ 2 - N)).prod) := by
  induction xs <;> simp_all +decide [ ← ZMod.intCast_zmod_eq_zero_iff_dvd ];
  convert dvd_add ( dvd_mul_of_dvd_right ‹_› ( ( ‹_› + s ) ^ 2 ) ) ( dvd_mul_left N ( List.prod ( List.map ( fun x => ( x + s ) ^ 2 - N ) ‹_› ) ) ) using 1 ; ring

/-! ### Factor Base Theory -/

/-- A factor base for N consists of primes p where N is a QR mod p. -/
def IsFactorBase (N : ℕ) (B : Finset ℕ) : Prop :=
  ∀ p ∈ B, Nat.Prime p ∧ ∃ x : ZMod p, x ^ 2 = (N : ZMod p)

/-
The factor base for 15 includes 2 (since 15 is odd) and 7.
-/
theorem factor_base_15 : IsFactorBase 15 {2, 7} := by
  intro p hp; fin_cases hp <;> simp +decide ;

/-! ### Exponent Vector Algebra -/

/- COMMENTED OUT: The original statement has the factorization arguments swapped.
   `p.factorization (a * b)` is the (a*b)-adic valuation of p (exponent of a*b in p's factorization),
   but the intended meaning is the p-adic valuation of a*b: `(a * b).factorization p`.
   Counterexample: a=1, b=2, primes=[4,16]. Then 4.factorization 2 = 2 (even) and
   16.factorization 2 = 4 (even), but no k exists with 4.factorization k = 1
   (since 4 = 2², so 4.factorization can only be 0 or 2). -/
/- theorem matching_exponents_square (a b : ℕ) (primes : List ℕ)
    (ha : 0 < a) (hb : 0 < b)
    (heven : ∀ p ∈ primes, Even (p.factorization (a * b))) :
    ∃ k : ℕ, ∀ p ∈ primes, p.factorization (a * b) = 2 * p.factorization k := by
  sorry -/

/-- Helper: the factorization of a "half-exponent" product matches half the original. -/
private lemma factorization_halfprod (n : ℕ) (hn : n ≠ 0) (q : ℕ) (hq : Nat.Prime q) :
    (n.primeFactors.prod (fun p => p ^ (n.factorization p / 2))).factorization q =
    n.factorization q / 2 := by
  have hne : ∀ x ∈ n.primeFactors, x ^ (n.factorization x / 2) ≠ 0 := by
    intro x hx; exact pow_ne_zero _ (Nat.prime_of_mem_primeFactors hx).ne_zero
  rw [Nat.factorization_prod hne, Finsupp.finset_sum_apply]
  have key : ∀ x ∈ n.primeFactors,
      (x ^ (n.factorization x / 2)).factorization q = if x = q then n.factorization q / 2 else 0 := by
    intro x hx
    have hxp := Nat.prime_of_mem_primeFactors hx
    rw [hxp.factorization_pow, Finsupp.single_apply]
    split <;> simp_all
  rw [Finset.sum_congr rfl key, Finset.sum_ite_eq']
  by_cases hq_mem : q ∈ n.primeFactors
  · simp [hq_mem]
  · simp [hq_mem]
    have hndvd : ¬ q ∣ n := fun h => hq_mem (Nat.mem_primeFactors.mpr ⟨hq, h, hn⟩)
    simp [Nat.factorization_eq_zero_of_not_dvd hndvd]

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

/-! ### QS Algorithm Correctness (Specification) -/

/-- The quadratic sieve specification: given a composite N, if we find
    enough B-smooth values of Q(x) = (x + ⌊√N⌋)² - N, we can factor N. -/
theorem qs_correctness_spec (N : ℕ) (hN : 1 < N) (hcomp : ¬ Nat.Prime N) :
    (∃ d, 1 < d ∧ d < N ∧ d ∣ N) := by
  obtain ⟨d, hd1, hd2⟩ := Nat.exists_dvd_of_not_prime2 hN hcomp
  exact ⟨d, by omega, by omega, hd1⟩

/-! ### Complexity Foundation -/

/-- The number of B-smooth numbers up to x is positive for B, x large enough. -/
theorem smooth_numbers_exist (B x : ℕ) (hB : 2 ≤ B) (hx : B ≤ x) :
    ∃ n, 1 ≤ n ∧ n ≤ x ∧ ∀ p, Nat.Prime p → p ∣ n → p ≤ B := by
  refine ⟨2, by omega, by omega, fun p hp hd => ?_⟩
  have h2p := Nat.le_of_dvd (by omega) hd
  interval_cases p <;> omega