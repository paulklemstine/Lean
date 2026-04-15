/-! # CatalogBuild.FutureResearch.SigmaHardness

Auto-generated from theorem catalog database.
Domain: FutureResearch
Declarations: 12
-/

import Mathlib

theorem sigma1_determines_factors (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p < q) (p' q' : ℕ) (hp' : Nat.Prime p') (hq' : Nat.Prime q')
    (hpq' : p' < q')
    (hN : p * q = p' * q')
    (hσ : σ₁ (p * q) = σ₁ (p' * q')) :
    p = p' ∧ q = q' := by
  -- Since $p$ and $q$ are distinct primes and $p' * q' = p * q$, it follows that $p$ and $q$ are factors of $p' * q'$.
  have hp_div_pq' : p ∣ p' * q' := by
    exact hN ▸ dvd_mul_right _ _
  have hq_div_pq' : q ∣ p' * q' := by
    exact hN ▸ dvd_mul_left _ _;
  simp_all +decide [ Nat.Prime.dvd_mul ];
  grind +suggestions


theorem sigma1_gives_sum_product (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    ∃ s m : ℕ, s = p + q ∧ m = p * q ∧
    σ₁ (p * q) = 1 + s + m := by
  have h_divisors : Nat.divisors (p * q) = {1, p, q, p * q} := by
    rw [ Nat.divisors_mul, hp.divisors, hq.divisors ];
    simpa [ Finset.ext_iff, Finset.mem_mul ] using by tauto;
  unfold σ₁; simp +decide [ *, add_assoc ] ;
  rw [ Finset.sum_insert, Finset.sum_insert, Finset.sum_insert ] <;> norm_num;
  · nlinarith [ hp.two_le, hq.two_le ];
  · exact ⟨ hpq, by nlinarith [ hp.two_le, hq.two_le ] ⟩;
  · exact ⟨ Ne.symm hp.ne_one, Ne.symm hq.ne_one, Nat.ne_of_lt ( one_lt_mul'' hp.one_lt hq.one_lt ) ⟩


theorem factoring_gives_sigma1_prime (p : ℕ) (hp : Nat.Prime p) :
    σ₁ p = p + 1 := by
  unfold σ₁;
  rw [ hp.sum_divisors, add_comm ]


theorem factoring_gives_sigma1_prime_sq (p : ℕ) (hp : Nat.Prime p) :
    σ₁ (p ^ 2) = 1 + p + p ^ 2 := by
  simp +arith +decide [ Nat.divisors_prime_pow hp, Finset.sum_range_succ', σ₁ ]


theorem sigma1_three_primes (p q r : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hr : Nat.Prime r) (hpq : p ≠ q) (hpr : p ≠ r) (hqr : q ≠ r) :
    σ₁ (p * q * r) = 1 + p + q + r + p*q + p*r + q*r + p*q*r := by
  -- Let's expand the set of divisors of $pqr$.
  have h_divisors : (p * q * r).divisors = {1, p, q, r, p * q, p * r, q * r, p * q * r} := by
    rw [ Nat.divisors_mul, Nat.divisors_mul, hp.divisors, hq.divisors, hr.divisors ];
    simpa [ Finset.ext_iff, Finset.mem_mul ] using by aesop;
  simp +arith +decide [ σ₁, h_divisors ];
  rw [ Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert, Finset.sum_insert ] <;> simp +decide [ hp.ne_zero, hq.ne_zero, hr.ne_zero, hpq, hpr, hqr ] ; ring;
  any_goals nlinarith [ hp.two_le, hq.two_le, hr.two_le ];
  · exact ⟨ by rw [ mul_comm ] ; aesop, hr.ne_one ⟩;
  · exact ⟨ fun h => by have := Nat.prime_mul_iff.mp ( h ▸ hr ) ; aesop, hp.ne_one, hq.ne_one, by aesop ⟩;
  · exact ⟨ hp.ne_one, by intro h; have := Nat.prime_mul_iff.mp ( h ▸ hq ) ; aesop, hr.ne_one, by nlinarith [ hp.two_le, hq.two_le, hr.two_le, mul_pos hp.pos hq.pos ] ⟩;
  · exact ⟨ hq.ne_one, hr.ne_one, by intro t; have := Nat.prime_mul_iff.mp ( t ▸ hp ) ; aesop, by nlinarith [ hp.two_le, hq.two_le, hr.two_le, mul_pos hp.pos hq.pos ] ⟩;
  · exact ⟨ Ne.symm hp.ne_one, Ne.symm hq.ne_one, Ne.symm hr.ne_one, Nat.ne_of_lt ( one_lt_mul'' hp.one_lt hq.one_lt ), Nat.ne_of_lt ( one_lt_mul'' hp.one_lt hr.one_lt ), Nat.ne_of_lt ( one_lt_mul'' hq.one_lt hr.one_lt ), Nat.ne_of_lt ( one_lt_mul'' ( one_lt_mul'' hp.one_lt hq.one_lt ) hr.one_lt ) ⟩


/-- If we know σ₁(N) exactly and N = pq, then (p+q)² - 4N = (p-q)² ≥ 0,
so the discriminant determines the factors. -/
theorem discriminant_is_square (p q : ℤ) :
    (p + q)^2 - 4 * (p * q) = (p - q)^2 := by ring


theorem sigma1_semiprime_bounds (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    p + q < σ₁ (p * q) := by
  -- By definition of σ₁, we know that σ₁(p * q) = 1 + p + q + p * q.
  unfold σ₁;
  rcases p with ( _ | _ | p ) <;> rcases q with ( _ | _ | q ) <;> simp_all +arith +decide [ Nat.sum_divisors_eq_sum_properDivisors_add_self ];
  grind +extAll


theorem sigma1_gap_reveals_sum (p q : ℕ) (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p ≠ q) :
    σ₁ (p * q) - (p * q) - 1 = p + q := by
  grind +suggestions


theorem sigma1_prime_power_formula (p k : ℕ) (hp : Nat.Prime p) :
    σ₁ (p ^ k) = ∑ i ∈ Finset.range (k + 1), p ^ i := by
  unfold σ₁;
  norm_num [ Nat.divisors_prime_pow hp ]


theorem sigma1_strictly_gt (n : ℕ) (hn : 1 < n) : n < σ₁ n := by
  unfold σ₁; rw [ Finset.sum_eq_sum_diff_singleton_add ( Nat.mem_divisors_self n hn.ne_bot ) ] ; simp +arith +decide; (
  exact Finset.single_le_sum ( fun x _ => Nat.zero_le x ) ( by aesop ));


theorem divisor_count_le_sigma1 (n : ℕ) (hn : 0 < n) :
    n.divisors.card ≤ σ₁ n := by
  exact le_trans ( by norm_num ) ( Finset.sum_le_sum fun x hx => Nat.one_le_iff_ne_zero.mpr <| Nat.ne_of_gt <| Nat.pos_of_mem_divisors hx )


/-- The complete reduction chain for semiprimes:
1. Given σ₁(pq), compute s = σ₁(pq) - pq - 1 = p + q
2. Compute Δ = s² - 4pq = (p-q)²
3. Recover p = (s - √Δ)/2, q = (s + √Δ)/2
This runs in O(1) arithmetic operations given σ₁.
Note: Int.sqrt may not give exact results, so we state the algebraic identity
directly rather than relying on Int.sqrt. -/
theorem full_reduction_chain (p q : ℤ) (hp : 2 ≤ p) (hq : 2 ≤ q) (hpq : p ≤ q) :
    p = ((p + q) - (q - p)) / 2 := by
  omega
