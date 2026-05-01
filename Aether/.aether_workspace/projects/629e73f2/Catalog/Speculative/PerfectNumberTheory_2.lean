
import Mathlib

/-! # CatalogBuild.Speculative.PerfectNumberTheory_2

Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 4
-/

/-- [Section: # CatalogBuild.Speculative.PerfectNumberTheory_2
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 4] -/
theorem mersenne_prime_exponent_prime' (p : ℕ) (hp : 1 < p)
    (hm : Nat.Prime (2 ^ p - 1)) : Nat.Prime p := by
  -- By contradiction, assume $p$ is composite. Then $p = ab$ for some $a, b > 1$.
  by_contra h_composite
  obtain ⟨a, b, ha, hb, hab⟩ : ∃ a b, 1 < a ∧ 1 < b ∧ p = a * b := by
    rcases Nat.exists_dvd_of_not_prime2 hp h_composite with ⟨ q, hq1, hq2 ⟩ ; exact ⟨ q, p / q, by nlinarith [ Nat.div_mul_cancel hq1 ], by nlinarith [ Nat.div_mul_cancel hq1 ], by rw [ Nat.mul_div_cancel' hq1 ] ⟩;
  -- Then $2^p - 1 = (2^a - 1)(2^{a(b-1)} + 2^{a(b-2)} + \cdots + 1)$.
  have h_factor : 2 ^ p - 1 = (2 ^ a - 1) * ∑ i ∈ Finset.range b, 2 ^ (a * i) := by
    zify [ hab, pow_mul ];
    norm_num [ mul_geom_sum ];
  simp_all +decide [ Nat.prime_mul_iff ];
  rcases b with ( _ | _ | b ) <;> rcases a with ( _ | _ | a ) <;> simp_all +decide [ Finset.sum_range_succ', pow_succ' ]

/-- If n is prime and perfect, that's a contradiction (σ₁(p) = p+1 ≠ 2p for p ≥ 2). -/
theorem perfect_has_two_prime_factors (n : ℕ) (hn : 1 < n) (hperf : σ₁ n = 2 * n)
    (hp : Nat.Prime n) : False := by
  have : σ₁ n = n + 1 := by simp [σ₁, hp.sum_divisors]
  omega

/-- [Section: # CatalogBuild.Speculative.PerfectNumberTheory_2
Auto-generated from theorem catalog database.
Domain: Speculative
Declarations: 4] -/
theorem sigma1_le_sq (n : ℕ) (hn : 0 < n) : σ₁ n ≤ n * n := by
  -- By definition of divisors, each divisor $d$ of $n$ satisfies $1 \leq d \leq n$.
  have h_divisors : ∀ d ∈ n.divisors, d ≤ n := by
    exact fun d hd => Nat.divisor_le hd;
  exact le_trans ( Finset.sum_le_sum h_divisors ) ( by norm_num; nlinarith [ show n.divisors.card ≤ n from le_trans ( Finset.card_filter_le _ _ ) ( by norm_num ) ] )

theorem sigma1_multiplicative_coprime (m n : ℕ) (hm : 0 < m) (hn : 0 < n)
    (hcop : Nat.Coprime m n) : σ₁ (m * n) = σ₁ m * σ₁ n := by
  unfold σ₁;
  grind +suggestions



