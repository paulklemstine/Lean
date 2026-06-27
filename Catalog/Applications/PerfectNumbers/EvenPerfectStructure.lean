import Mathlib

/-!
# Structure of Even Perfect Numbers

This file refines the Euclid–Euler classification of even perfect numbers.
The classification itself (an even number is perfect iff it equals
`2^k * (2^(k+1) - 1)` with `2^(k+1) - 1` a Mersenne prime) lives in Mathlib's
`Archive` (Wiedijk 100 Theorems, #70); since the `Archive` library is not
importable from this project, the three core helper lemmas of that development are
reproduced here (`sigma_two_pow_eq_mersenne_succ`, `eq_two_pow_mul_odd`,
`euler_even_perfect_form`, `euclid_perfect`) as infrastructure.

On top of that infrastructure we prove genuinely new structural theorems:

* `PerfectNumbers.mersenne_dvd_of_dvd` — the Mersenne sequence `m ↦ 2^m - 1` is a
  *divisibility sequence*: `a ∣ b → mersenne a ∣ mersenne b`.  (This is the
  Mersenne instance highlighted in the catalog file
  `Catalog/Applications/StrongDivisibilitySequences.lean`, namely
  `StrongDivSeq.mersenne_isStrongDivSeq`.)
* `PerfectNumbers.mersenne_exponent_prime` — if `mersenne p = 2^p - 1` is prime
  then the exponent `p` is prime.  Proved here from `mersenne_dvd_of_dvd`, the
  divisibility-sequence route, rather than from `Nat.Prime.of_mersenne`.
* `PerfectNumbers.even_perfect_triangular` — **every even perfect number is a
  triangular number**: `n = T_{2^p - 1}` where `T_m = m(m+1)/2`.
* `PerfectNumbers.even_perfect_structure` — every even perfect number has the
  shape `2^(p-1) * (2^p - 1)` with **both** `p` and `2^p - 1` prime (the prime
  exponent being the new content over the bare Euclid–Euler form).
* `PerfectNumbers.even_perfect_iff_prime_exponent` — the sharpened Euclid–Euler
  equivalence stated with a prime exponent.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): Even perfect numbers are not just of Euclid's form;
they are exactly the triangular numbers `T_{2^p - 1}` for Mersenne-prime exponents
`p`, and the exponent `p` is itself forced to be prime.  Conjectured links:
`6 = T_3`, `28 = T_7`, `496 = T_31`, `8128 = T_127`.

Experiment (Experimenter): Confirmed `2^k (2^{k+1}-1) = T_{2^{k+1}-1}` symbolically:
`T_m = m(m+1)/2` with `m = 2^{k+1}-1`, so `m+1 = 2^{k+1}` and
`T_m = (2^{k+1}-1) 2^{k+1} / 2 = (2^{k+1}-1) 2^k`.  The division by 2 is exact.
For the prime exponent, used the divisibility-sequence lemma: a proper factor
`a` of `p` (with `1 < a < p`) yields a proper divisor `2^a - 1` of `2^p - 1`.

Analysis (Analyst): The triangular identity is purely formal once the Euler form
is available; the only subtlety is the exact halving, handled via
`Nat.mul_div_assoc` after showing `2 ∣ m + 1`.  The exponent-primality is where
the *divisibility sequence* structure of `2^n - 1` does real work — exactly the
catalog's `mersenne_isStrongDivSeq` phenomenon.

Critique (Critic): "Triangular" is meaningful only with the exact-division
definition `m(m+1)/2`; we therefore also record `2 * triangular m = m*(m+1)` to
certify the division is not lossy.  Edge cases `p = 0, 1` for the Mersenne
exponent are eliminated because `mersenne 0 = 0` and `mersenne 1 = 1` are not prime.

Synthesis (PI): Even perfect numbers = triangular numbers `T_{2^p-1}`, `p` prime,
`2^p-1` prime — a single clean structural statement.
-/

open ArithmeticFunction Finset
open scoped sigma

namespace PerfectNumbers

/-- The `m`-th triangular number `T_m = m(m+1)/2`. -/
def triangular (m : ℕ) : ℕ := m * (m + 1) / 2

/-
The defining identity certifying that the division in `triangular` is exact.
-/
theorem two_mul_triangular (m : ℕ) : 2 * triangular m = m * (m + 1) := by
  exact Nat.mul_div_cancel' ( even_iff_two_dvd.mp ( by simp +arith +decide [ mul_add, parity_simps ] ) )

/-! ### Reproduced Euclid–Euler infrastructure (Mathlib Archive, Theorem 70) -/

/-
`σ(2^k) = 2^(k+1) - 1` (a Mersenne number).
-/
theorem sigma_two_pow_eq_mersenne_succ (k : ℕ) : σ 1 (2 ^ k) = mersenne (k + 1) := by
  norm_num [ mersenne, ArithmeticFunction.sigma ];
  norm_num [ Nat.geomSum_eq ]

/-
Euclid's direction: a Mersenne prime gives a perfect number.
-/
theorem euclid_perfect (k : ℕ) (pr : (mersenne (k + 1)).Prime) :
    Nat.Perfect (2 ^ k * mersenne (k + 1)) := by
  -- Apply Euclid's theorem: if $2^{k+1} - 1$ is prime, then $2^k (2^{k+1} - 1)$ is perfect.
  have h_euclid : Nat.Perfect (2^k * (2^(k + 1) - 1)) := by
    have h_sigma : ∑ d ∈ Nat.divisors (2^k * (2^(k+1) - 1)), d = 2^(k+1) * (2^(k+1) - 1) := by
      -- Apply the multiplicativity of the sum of divisors function.
      have h_sigma_mul : ∑ d ∈ Nat.divisors (2^k * (2^(k+1) - 1)), d = (∑ d ∈ Nat.divisors (2^k), d) * (∑ d ∈ Nat.divisors (2^(k+1) - 1), d) := by
        -- Since $2^k$ and $2^{k+1} - 1$ are coprime, we can apply the multiplicativity of the sum of divisors function.
        have h_coprime : Nat.gcd (2^k) (2^(k+1) - 1) = 1 := by
          exact Nat.Coprime.pow_left _ ( Nat.prime_two.coprime_iff_not_dvd.mpr <| by simp +decide [ ← even_iff_two_dvd, Nat.one_le_iff_ne_zero, parity_simps ] );
        exact Nat.Coprime.sum_divisors_mul h_coprime
      simp_all +decide [ Nat.geomSum_eq, mersenne ];
      zify ; norm_num ; ring;
    simp_all +decide [ Nat.Perfect, Nat.sum_divisors_eq_sum_properDivisors_add_self ];
    grind;
  convert h_euclid using 1

/-
Any positive number factors as `2^k * (odd)`.
-/
theorem eq_two_pow_mul_odd {n : ℕ} (hpos : 0 < n) :
    ∃ k m : ℕ, n = 2 ^ k * m ∧ ¬Even m := by
  -- Let $k$ be the largest integer such that $2^k$ divides $n$.
  obtain ⟨k, hk⟩ : ∃ k : ℕ, 2 ^ k ∣ n ∧ ¬2^(k + 1) ∣ n := by
    exact ⟨ Nat.factorization n 2, Nat.ordProj_dvd _ _, Nat.pow_succ_factorization_not_dvd hpos.ne' ( by decide ) ⟩;
  exact ⟨ k, n / 2 ^ k, by rw [ Nat.mul_div_cancel' hk.1 ], by rw [ even_iff_two_dvd ] ; exact fun h => hk.2 <| by convert Nat.mul_dvd_mul_left ( 2 ^ k ) h using 1; rw [ Nat.mul_div_cancel' hk.1 ] ⟩

/-
Euler's direction: an even perfect number has Euclid's form.
-/
theorem euler_even_perfect_form {n : ℕ} (ev : Even n) (perf : Nat.Perfect n) :
    ∃ k : ℕ, Nat.Prime (mersenne (k + 1)) ∧ n = 2 ^ k * mersenne (k + 1) := by
  -- Let $n = 2^k \cdot m$ where $m$ is odd.
  obtain ⟨k, m, hm⟩ : ∃ k m, n = 2 ^ k * m ∧ ¬Even m := by
    exact ⟨ Nat.factorization n 2, n / 2 ^ Nat.factorization n 2, by rw [ Nat.mul_div_cancel' ( Nat.ordProj_dvd _ _ ) ], by rw [ even_iff_two_dvd ] ; exact Nat.not_dvd_ordCompl ( by norm_num ) ( by rintro rfl; simp_all +decide [ Nat.Perfect ] ) ⟩;
  -- Since $n$ is perfect, we have $\sigma(n) = 2n$. Using the multiplicative property of the sum-of-divisors function, we get $\sigma(2^k \cdot m) = \sigma(2^k) \cdot \sigma(m) = (2^{k+1} - 1) \cdot \sigma(m)$.
  have h_sigma : (2 ^ (k + 1) - 1) * ∑ d ∈ Nat.divisors m, d = 2 ^ (k + 1) * m := by
    -- Using the multiplicative property of the sum-of-divisors function, we have $\sigma(2^k \cdot m) = \sigma(2^k) \cdot \sigma(m)$.
    have h_sigma_mul : ∑ d ∈ Nat.divisors (2^k * m), d = (∑ d ∈ Nat.divisors (2^k), d) * (∑ d ∈ Nat.divisors m, d) := by
      have h_sigma_mul : ∀ {a b : ℕ}, Nat.gcd a b = 1 → ∑ d ∈ Nat.divisors (a * b), d = (∑ d ∈ Nat.divisors a, d) * (∑ d ∈ Nat.divisors b, d) := by
        grind +suggestions;
      exact h_sigma_mul <| Nat.Coprime.pow_left _ <| Nat.prime_two.coprime_iff_not_dvd.mpr fun h => hm.2 <| even_iff_two_dvd.mpr h;
    simp_all +decide [ Nat.geomSum_eq, Nat.Perfect, Nat.sum_divisors_eq_sum_properDivisors_add_self ];
    exact h_sigma_mul ▸ by ring;
  -- Since $2^{k+1} - 1$ divides $2^{k+1} \cdot m$, it must also divide $m$.
  obtain ⟨j, hj⟩ : ∃ j, m = (2 ^ (k + 1) - 1) * j := by
    exact ( Nat.Coprime.dvd_of_dvd_mul_left ( show Nat.Coprime ( 2 ^ ( k + 1 ) - 1 ) ( 2 ^ ( k + 1 ) ) from by simp +decide [ Nat.one_le_iff_ne_zero, parity_simps ] ) <| h_sigma ▸ dvd_mul_right _ _ );
  by_cases hj1 : j = 1 <;> simp_all +decide [ Nat.Perfect, Nat.sum_divisors_eq_sum_properDivisors_add_self ];
  · simp_all +decide [ mersenne ];
    exact ⟨ k, by rw [ Nat.prime_def_lt' ] ; exact ⟨ Nat.le_sub_one_of_lt ( by linarith [ Nat.pow_le_pow_right two_pos ( show k + 1 ≥ 2 by linarith [ show k > 0 from Nat.pos_of_ne_zero ( by aesop_cat ) ] ) ] ), fun p hp₁ hp₂ hp₃ => by nlinarith [ Nat.sub_add_cancel ( Nat.one_le_pow ( k + 1 ) 2 zero_lt_two ), show ∑ x ∈ Nat.properDivisors ( 2 ^ ( k + 1 ) - 1 ), x ≥ p from Finset.single_le_sum ( fun x _ => Nat.zero_le x ) ( by aesop ) ] ⟩, rfl ⟩;
  · -- Since $j \neq 1$, we have $\sum_{x \in \text{proper divisors}(m)} x \geq 1 + j$.
    have h_sum_ge : ∑ x ∈ Nat.properDivisors ((2 ^ (k + 1) - 1) * j), x ≥ 1 + j := by
      have h_sum_ge : Nat.properDivisors ((2 ^ (k + 1) - 1) * j) ⊇ {1, j} := by
        simp +decide [ Finset.insert_subset_iff ];
        rcases j with ( _ | _ | j ) <;> simp_all +decide [ Nat.pow_succ' ];
        grind +qlia;
      exact le_trans ( by rw [ Finset.sum_pair ] ; omega ) ( Finset.sum_le_sum_of_subset h_sum_ge );
    nlinarith [ Nat.sub_add_cancel ( Nat.one_le_pow ( k + 1 ) 2 zero_lt_two ), pow_pos ( zero_lt_two' ℕ ) k, pow_succ' 2 k, mul_pos ( Nat.sub_pos_of_lt ( show 1 < 2 ^ ( k + 1 ) from one_lt_pow₀ one_lt_two ( by linarith ) ) ) perf.2 ]

/-! ### New structural theorems -/

/-
The Mersenne sequence `m ↦ 2^m - 1` is a divisibility sequence:
`a ∣ b → mersenne a ∣ mersenne b`.  (Mersenne instance of
`StrongDivSeq.mersenne_isStrongDivSeq` from the catalog.)
-/
theorem mersenne_dvd_of_dvd {a b : ℕ} (h : a ∣ b) : mersenne a ∣ mersenne b := by
  -- Write `b = a * k` with `k` a positive integer.
  obtain ⟨k, rfl⟩ : ∃ k, b = a * k := h;
  unfold mersenne;
  zify [ pow_mul ];
  norm_num [ ← geom_sum_mul ]

/-
If `2^p - 1` is prime then the exponent `p` is prime.  Proved via the
divisibility-sequence lemma `mersenne_dvd_of_dvd`.
-/
theorem mersenne_exponent_prime {p : ℕ} (hp : (mersenne p).Prime) : p.Prime := by
  have hp2 : 2 ≤ p := by
    rcases p with _ | _ | p
    · exact absurd hp (by rw [show mersenne 0 = 0 from rfl]; exact Nat.not_prime_zero)
    · exact absurd hp (by rw [show mersenne 1 = 1 from rfl]; exact Nat.not_prime_one)
    · omega
  rw [Nat.prime_def_lt]
  refine ⟨hp2, fun a halt hadvd => ?_⟩
  by_contra hane1
  have ha0 : a ≠ 0 := by rintro rfl; simp at hadvd; omega
  have ha2 : 2 ≤ a := by omega
  have hdvd : mersenne a ∣ mersenne p := mersenne_dvd_of_dvd hadvd
  have hlt : (2:ℕ) ^ a < 2 ^ p := Nat.pow_lt_pow_right (by norm_num) halt
  have h4 : (4:ℕ) ≤ 2 ^ a := by
    calc (4:ℕ) = 2 ^ 2 := by norm_num
      _ ≤ 2 ^ a := Nat.pow_le_pow_right (by norm_num) ha2
  rcases hp.eq_one_or_self_of_dvd _ hdvd with h1 | hself
  · unfold mersenne at h1; omega
  · unfold mersenne at hself; omega

/-
**Every even perfect number is a triangular number** `T_{2^p - 1}`.
-/
theorem even_perfect_triangular {n : ℕ} (ev : Even n) (perf : Nat.Perfect n) :
    ∃ m : ℕ, n = triangular m := by
  -- From `euler_even_perfect_form ev perf` obtain `k`, `(mersenne (k+1)).Prime`, and `n = 2^k * mersenne (k+1)`.
  obtain ⟨k, hk_prime, hk_eq⟩ := euler_even_perfect_form ev perf;
  use mersenne (k + 1);
  rw [ eq_comm, triangular, Nat.div_eq_of_eq_mul_left ] <;> norm_num;
  rw [ hk_eq ] ; ring

/-
**Structure of even perfect numbers**: every even perfect number equals
`2^(p-1) * (2^p - 1)` with both `p` and `2^p - 1 = mersenne p` prime.
-/
theorem even_perfect_structure {n : ℕ} (ev : Even n) (perf : Nat.Perfect n) :
    ∃ p : ℕ, p.Prime ∧ (mersenne p).Prime ∧ n = 2 ^ (p - 1) * mersenne p := by
  obtain ⟨ k, hk ⟩ := euler_even_perfect_form ev perf;
  exact ⟨ k + 1, mersenne_exponent_prime hk.1, hk.1, hk.2 ⟩

/-
The sharpened Euclid–Euler equivalence, with a **prime** exponent.
-/
theorem even_perfect_iff_prime_exponent {n : ℕ} :
    (Even n ∧ Nat.Perfect n) ↔
      ∃ p : ℕ, p.Prime ∧ (mersenne p).Prime ∧ n = 2 ^ (p - 1) * mersenne p := by
  constructor <;> intro h;
  · convert even_perfect_structure h.1 h.2 using 1;
  · obtain ⟨ p, hp₁, hp₂, rfl ⟩ := h;
    rcases p with ( _ | _ | p ) <;> simp_all +decide [ Nat.Perfect ];
    exact ⟨ even_iff_two_dvd.mpr ( dvd_mul_of_dvd_left ( dvd_pow_self _ ( Nat.succ_ne_zero _ ) ) _ ), euclid_perfect _ hp₂ |> fun h => h.1 ⟩

end PerfectNumbers