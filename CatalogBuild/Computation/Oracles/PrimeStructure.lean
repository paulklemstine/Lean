/-! # CatalogBuild.Computation.Oracles.PrimeStructure

Auto-generated from theorem catalog database.
Domain: Computation/Oracles
Declarations: 11
-/

import Mathlib

theorem oracle_primes_infinite : ∀ n : ℕ, ∃ p, p > n ∧ Nat.Prime p := by
  exact fun n => Exists.imp ( by tauto ) ( Nat.exists_infinite_primes ( n + 1 ) )

/-
For every prime p, there exists a strictly larger prime.
    This is a reformulation emphasizing the successor structure.
-/

theorem oracle_prime_successor (p : ℕ) (hp : Nat.Prime p) : ∃ q, Nat.Prime q ∧ q > p := by
  exact Exists.imp ( by tauto ) ( Nat.exists_infinite_primes ( p + 1 ) )

/-! ## Section 2: Divisibility and Factorization -/

/-
Every natural number ≥ 2 has a prime divisor.
    This is the gateway to the Fundamental Theorem of Arithmetic.
-/

theorem oracle_exists_prime_divisor (n : ℕ) (hn : n ≥ 2) :
    ∃ p, Nat.Prime p ∧ p ∣ n := by
  exact Nat.exists_prime_and_dvd ( Nat.ne_of_gt hn )

/-
If p is prime and p divides a product, then p divides one of the factors.
    Euclid's lemma — the multiplicative soul of primality.
-/

theorem oracle_euclid_lemma (p a b : ℕ) (hp : Nat.Prime p) (h : p ∣ a * b) :
    p ∣ a ∨ p ∣ b := by
  exact hp.dvd_mul.mp h

/-! ## Section 3: Modular Arithmetic — Gateway to Riemann -/

/-
Fermat's Little Theorem: a^p ≡ a (mod p) for prime p.
    This is the discrete shadow of the zeta function's behavior at integer points.
    Connection to RH: Fermat's theorem governs the local behavior of
    L-functions, which are generalizations of the Riemann zeta function.
-/

theorem oracle_fermat_little (p : ℕ) (hp : Nat.Prime p) (a : ℕ) :
    a ^ p ≡ a [MOD p] := by
  haveI := Fact.mk hp; simp +decide [ ← ZMod.natCast_eq_natCast_iff ] ;

/-
Wilson's Theorem: (p-1)! ≡ -1 (mod p) iff p is prime.
    A beautiful characterization linking factorial growth to primality.
-/

theorem oracle_wilson (p : ℕ) (hp : Nat.Prime p) :
    (p - 1)! + 1 ≡ 0 [MOD p] := by
  haveI := Fact.mk hp; simp +decide [ ← ZMod.natCast_eq_natCast_iff ] ;

/-! ## Section 4: Prime Gaps — Toward Twin Primes -/

/-
There exist arbitrarily large gaps between consecutive primes.
    Connection to Twin Primes: While we prove gaps can be large,
    the Twin Prime Conjecture asks whether gaps of size 2 recur infinitely.
-/

theorem oracle_large_prime_gaps (k : ℕ) :
    ∃ n, n ≥ 2 ∧ ∀ i, 1 ≤ i → i ≤ k → ¬ Nat.Prime (n + i) := by
  -- Let $n = (k+2)! + 2$. This number is greater than or equal to 2.
  use (k + 2)! + 2;
  exact ⟨ Nat.le_add_left _ _, fun i hi₁ hi₂ => by rw [ show ( k + 2 ) ! + 2 + i = ( i + 2 ) * ( ( k + 2 ) ! / ( i + 2 ) + 1 ) by linarith [ Nat.div_mul_cancel ( show i + 2 ∣ ( k + 2 ) ! from Nat.dvd_factorial ( by linarith ) ( by linarith ) ) ] ] ; exact Nat.not_prime_mul ( by linarith ) ( by linarith [ Nat.div_pos ( show i + 2 ≤ ( k + 2 ) ! from Nat.self_le_factorial _ |> Nat.le_trans ( by linarith ) ) ( by linarith ) ] ) ⟩

/-
For any n ≥ 1, the interval (n, 2n] contains a prime (Bertrand's postulate).
-/

theorem oracle_bertrand (n : ℕ) (hn : n ≥ 1) :
    ∃ p, Nat.Prime p ∧ n < p ∧ p ≤ 2 * n := by
  exact Nat.exists_prime_lt_and_le_two_mul n ( by linarith )

/-! ## Section 5: Additive Structure — Toward Goldbach -/

/-
Every even number ≥ 2 can be written as a sum of at most 2n primes.
    This is a very weak form, but it's provable and gestures toward Goldbach.
    Connection to Goldbach: The full conjecture claims 2 primes suffice for n ≥ 4.
-/

theorem oracle_even_as_prime_sum (n : ℕ) (hn : n ≥ 1) :
    ∃ (primes : List ℕ), (∀ p, p ∈ primes → Nat.Prime p) ∧ primes.sum = 2 * n := by
  constructor;
  case w => exact List.replicate n 2;
  norm_num [ mul_comm ]

/-
2 is the only even prime. This structural fact is central to Goldbach:
    it means every even number > 2 must use two odd primes.
-/

theorem oracle_two_only_even_prime (p : ℕ) (hp : Nat.Prime p) (he : 2 ∣ p) :
    p = 2 := by
  simp_all +decide [ Nat.Prime.dvd_iff_eq hp ]

/-! ## Section 6: Quadratic Residues — Deep Structure -/

/-
Euler's criterion: a is a quadratic residue mod p iff a^((p-1)/2) ≡ 1 (mod p).
    Connection to RH: Quadratic residues are intimately connected to
    Dirichlet L-functions, whose zeros encode prime distribution in
    arithmetic progressions.
-/

theorem oracle_euler_criterion (p : ℕ) (hp : Nat.Prime p) (hodd : p ≠ 2)
    (a : ℕ) (ha : ¬ p ∣ a) (hqr : ∃ x : ZMod p, x ^ 2 = (a : ZMod p)) :
    (a : ZMod p) ^ ((p - 1) / 2) = 1 := by
  cases' hqr with x hx;
  rw [ ← hx, ← pow_mul, Nat.mul_div_cancel' ];
  · haveI := Fact.mk hp; exact ZMod.pow_card_sub_one_eq_one ( by rw [ ← ZMod.natCast_eq_zero_iff ] at ha; aesop ) ;
  · exact even_iff_two_dvd.mp ( hp.even_sub_one hodd )
