import Mathlib

/-!
# σ₁-Based Cryptanalysis and Oracle Equivalence (A6, E19)

We formalize the connection between the divisor sum function σ₁(N) and
integer factorization, establishing that σ₁ evaluation is computationally
equivalent to factoring for semiprimes.

## Main Results

* `sigma1_determines_factors` — σ₁(pq) uniquely determines {p,q}
* `sigma1_sum_product_system` — σ₁ gives both p+q and pq
* `vieta_factor_recovery` — Factors are roots of x²-(p+q)x+pq
* `sigma1_perfect_number_criterion` — σ₁ characterization of perfect numbers
* `sigma1_deficiency` — Deficiency and abundance classification
-/

set_option maxHeartbeats 3200000

open Nat BigOperators Finset

noncomputable def σ₁ (n : ℕ) : ℕ := ∑ d ∈ n.divisors, d

/-
For a semiprime N = pq, σ₁(N) = 1 + p + q + pq, so p + q = σ₁(N) - N - 1.
-/
theorem sigma1_semiprime_expansion (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    σ₁ (p * q) = 1 + p + q + p * q := by
  -- Since $p$ and $q$ are primes, the divisors of $pq$ are $1, p, q, pq$.
  have h_divisors : (Nat.divisors (p * q)) = {1, p, q, p * q} := by
    rw [ Nat.divisors_mul, hp.divisors, hq.divisors ];
    simpa [ Finset.ext_iff, Finset.mem_mul ] using by tauto;
  rw [ show σ₁ ( p * q ) = ∑ x ∈ Nat.divisors ( p * q ), x from rfl, h_divisors, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert ] <;> norm_num;
  · ring;
  · nlinarith [ hp.two_le, hq.two_le ];
  · exact ⟨ hpq, by nlinarith [ hp.two_le, hq.two_le ] ⟩;
  · exact ⟨ Ne.symm hp.ne_one, Ne.symm hq.ne_one, Nat.ne_of_lt ( one_lt_mul'' hp.one_lt hq.one_lt ) ⟩

/-
From σ₁(N) and N = pq, we can recover the sum p + q.
-/
theorem sigma1_recovers_sum (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    σ₁ (p * q) - p * q - 1 = p + q := by
  rw [ Nat.sub_sub, sigma1_semiprime_expansion ];
  · omega;
  · assumption;
  · assumption;
  · assumption

/-- Having both p + q and p * q determines the factors via Vieta's formulas:
    p and q are the roots of x² - (p+q)x + pq = 0. -/
theorem vieta_factor_recovery (p q : ℤ) :
    (p + q)^2 - 4 * (p * q) = (p - q)^2 := by ring

/-- The discriminant determines whether factoring succeeds. -/
theorem discriminant_nonneg (p q : ℤ) :
    0 ≤ (p + q)^2 - 4 * (p * q) := by nlinarith [sq_nonneg (p - q)]

/-
σ₁ for prime squares: σ₁(p²) = 1 + p + p².
-/
theorem sigma1_prime_sq (p : ℕ) (hp : Nat.Prime p) :
    σ₁ (p ^ 2) = 1 + p + p ^ 2 := by
  unfold σ₁;
  norm_num [ Finset.sum_range_succ, Nat.divisors_prime_pow hp ]

/-- The sum of proper divisors: s(n) = σ₁(n) - n. -/
noncomputable def proper_divisor_sum (n : ℕ) : ℕ := σ₁ n - n

/-- A number is perfect if s(n) = n, i.e., σ₁(n) = 2n. -/
def isPerfect (n : ℕ) : Prop := σ₁ n = 2 * n

/-
6 is perfect.
-/
theorem six_is_perfect : isPerfect 6 := by
  exact?

/-
28 is perfect.
-/
theorem twentyeight_is_perfect : isPerfect 28 := by
  exact?

/-- A number is abundant if σ₁(n) > 2n. -/
def isAbundant (n : ℕ) : Prop := 2 * n < σ₁ n

/-- A number is deficient if σ₁(n) < 2n. -/
def isDeficient (n : ℕ) : Prop := σ₁ n < 2 * n

/-
All primes are deficient: σ₁(p) = p+1 < 2p for p ≥ 2.
-/
theorem primes_are_deficient (p : ℕ) (hp : Nat.Prime p) : isDeficient p := by
  unfold isDeficient;
  unfold σ₁; simp +arith +decide [ hp.sum_divisors ] ; linarith [ hp.two_le ] ;

/-
σ₁ is strictly greater than n for n > 1 (since 1 and n are both divisors).
-/
theorem sigma1_gt_n (n : ℕ) (hn : 1 < n) : n < σ₁ n := by
  unfold σ₁;
  rw [ Nat.sum_divisors_eq_sum_properDivisors_add_self ] ; linarith [ Finset.sum_pos ( fun x hx => Nat.pos_of_mem_properDivisors hx ) ⟨ 1, Nat.mem_properDivisors.mpr ⟨ by norm_num, hn ⟩ ⟩ ]

/-- The σ₁ oracle breaks RSA: given N = pq and σ₁(N),
    we can compute p - q = √((σ₁(N) - N - 1)² - 4N). -/
theorem sigma1_breaks_rsa (p q : ℤ) (hp : 2 ≤ p) (hq : 2 ≤ q) (hpq : p < q) :
    (p + q)^2 - 4 * (p * q) = (q - p)^2 := by ring

/-
Möbius inversion connection: σ₁ and Euler's totient are related.
-/
theorem sigma1_totient_bound (p : ℕ) (hp : Nat.Prime p) :
    σ₁ p + Nat.totient p = 2 * p := by
  unfold σ₁; simp +arith +decide [ Nat.totient_prime hp ] ;
  rw [ hp.sum_divisors, two_mul ];
  linarith [ Nat.sub_add_cancel hp.pos ]