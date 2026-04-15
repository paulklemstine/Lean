/-! # CatalogBuild.FutureResearch.SigmaCryptanalysis

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 13
-/

import Mathlib

noncomputable section

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


/-- The sum of proper divisors: s(n) = σ₁(n) - n. -/
noncomputable def proper_divisor_sum (n : ℕ) : ℕ := σ₁ n - n


theorem six_is_perfect : isPerfect 6 := by
  exact?


theorem twentyeight_is_perfect : isPerfect 28 := by
  exact?


/-- A number is abundant if σ₁(n) > 2n. -/
def isAbundant (n : ℕ) : Prop := 2 * n < σ₁ n


/-- A number is deficient if σ₁(n) < 2n. -/
def isDeficient (n : ℕ) : Prop := σ₁ n < 2 * n


theorem primes_are_deficient (p : ℕ) (hp : Nat.Prime p) : isDeficient p := by
  unfold isDeficient;
  unfold σ₁; simp +arith +decide [ hp.sum_divisors ] ; linarith [ hp.two_le ] ;


theorem sigma1_gt_n (n : ℕ) (hn : 1 < n) : n < σ₁ n := by
  unfold σ₁;
  rw [ Nat.sum_divisors_eq_sum_properDivisors_add_self ] ; linarith [ Finset.sum_pos ( fun x hx => Nat.pos_of_mem_properDivisors hx ) ⟨ 1, Nat.mem_properDivisors.mpr ⟨ by norm_num, hn ⟩ ⟩ ]


/-- The σ₁ oracle breaks RSA: given N = pq and σ₁(N),
we can compute p - q = √((σ₁(N) - N - 1)² - 4N). -/
theorem sigma1_breaks_rsa (p q : ℤ) (hp : 2 ≤ p) (hq : 2 ≤ q) (hpq : p < q) :
    (p + q)^2 - 4 * (p * q) = (q - p)^2 := by ring


theorem sigma1_totient_bound (p : ℕ) (hp : Nat.Prime p) :
    σ₁ p + Nat.totient p = 2 * p := by
  unfold σ₁; simp +arith +decide [ Nat.totient_prime hp ] ;
  rw [ hp.sum_divisors, two_mul ];
  linarith [ Nat.sub_add_cancel hp.pos ]

end
