import Mathlib

/-!
# The Abundancy Index σ(n)/n

This file develops the **abundancy index** framework for the structural study of
perfect numbers.  For a positive integer `n` the abundancy index is the rational
number `σ(n) / n`, where `σ` is the sum-of-divisors arithmetic function.  A number
is *perfect* exactly when its abundancy index equals `2`, *deficient* when it is
`< 2`, and *abundant* when it is `> 2`.

Main results:

* `PerfectNumbers.abundancy_eq_two_iff_perfect` — `n` is perfect ↔ abundancy `n = 2`.
* `PerfectNumbers.abundancy_mul_coprime` — abundancy is multiplicative on coprime
  arguments (it is a quotient of multiplicative functions).
* `PerfectNumbers.abundancy_prime` — `σ(p)/p = (p+1)/p` for a prime `p`.
* `PerfectNumbers.prime_deficient` — every prime is deficient.
* `PerfectNumbers.primePow_deficient` — every prime power `p^k` (`k ≥ 1`) is deficient.
  This is the key structural lever: a perfect number cannot be a prime power.
* `PerfectNumbers.perfect_not_isPrimePow` — no perfect number is a prime power.
* `PerfectNumbers.perfect_sum_reciprocal_divisors` — for a perfect number,
  `∑_{d ∣ n} 1/d = 2`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The single rational invariant `σ(n)/n` controls the
entire perfect/deficient/abundant trichotomy, and its multiplicativity on coprime
factors plus the strict deficiency of prime powers should already force a perfect
number to have at least two distinct prime factors — a baby version of Nielsen's
"≥ 101 prime factors" bound for odd perfects.

Experiment (Experimenter): Verified `σ(p^k)/p^k < 2` algebraically: clearing the
positive denominator `p - 1` reduces the strict inequality to `0 < p^k (p-2) + 1`,
which `nlinarith`/`positivity` discharge for every prime `p ≥ 2` (note `p = 2`
gives the term `1`).  The multiplicativity uses `isMultiplicative_sigma`.

Analysis (Analyst): The framework cleanly separates the two halves of the
Euclid–Euler picture: the *value* `= 2` (perfection) is a `σ`-identity, while the
*comparison* with `2` is a geometric-series estimate.  Prime powers are uniformly
deficient, so perfection genuinely requires interaction between several primes.

Critique (Critic): All statements quantify over `0 < n`; the `n = 0` edge case is
excluded because `σ(0)/0` is the meaningless `0/0`.  The reciprocal-sum identity
is proved via the involution `d ↦ n/d` on divisors, not by `decide`.

Synthesis (PI): A reusable abundancy API on which the even-perfect structure
theorems (companion file `EvenPerfectStructure.lean`) rest.
-/

open ArithmeticFunction
open scoped sigma

namespace PerfectNumbers

/-- The **abundancy index** of `n`: the rational number `σ(n)/n`. -/
def abundancy (n : ℕ) : ℚ := (σ 1 n : ℚ) / (n : ℚ)

/-- `n` is **deficient** when its abundancy index is `< 2`. -/
def Deficient (n : ℕ) : Prop := abundancy n < 2

/-- `n` is **abundant** when its abundancy index is `> 2`. -/
def Abundant (n : ℕ) : Prop := 2 < abundancy n

/-
`σ(n)` written through the abundancy index: `σ(n) = abundancy n * n`.
-/
theorem sigma_eq_abundancy_mul {n : ℕ} (hn : 0 < n) :
    (σ 1 n : ℚ) = abundancy n * n := by
  exact Eq.symm ( div_mul_cancel₀ _ ( Nat.cast_ne_zero.mpr hn.ne' ) )

/-
A number is perfect iff its abundancy index is exactly `2`.
-/
theorem abundancy_eq_two_iff_perfect {n : ℕ} (hn : 0 < n) :
    abundancy n = 2 ↔ n.Perfect := by
  -- By definition of abundancy, we have that abundancy n = 2 if and only if σ(n) = 2n.
  have h_abundancy : abundancy n = 2 ↔ (σ 1 n : ℚ) = 2 * n := by
    unfold abundancy; rw [ div_eq_iff ] ; norm_cast ; linarith;
  rw_mod_cast [ h_abundancy, Nat.perfect_iff_sum_divisors_eq_two_mul ];
  · simp +decide [ ArithmeticFunction.sigma ];
  · assumption

/-
The abundancy index is multiplicative on coprime arguments.
-/
theorem abundancy_mul_coprime {m n : ℕ} (h : Nat.Coprime m n) :
    abundancy (m * n) = abundancy m * abundancy n := by
  -- By definition of abundancy, we have:
  have h_abundancy : (σ 1 (m * n) : ℚ) = (σ 1 m : ℚ) * (σ 1 n : ℚ) := by
    exact_mod_cast isMultiplicative_sigma.map_mul_of_coprime h;
  unfold abundancy; simp +decide [ *, mul_div_mul_comm ] ;

/-
The abundancy index of a prime `p` is `(p+1)/p`.
-/
theorem abundancy_prime {p : ℕ} (hp : p.Prime) :
    abundancy p = (p + 1 : ℚ) / p := by
  unfold abundancy; rw [ ArithmeticFunction.sigma_one_apply ] ; norm_cast ; rcases p with ( _ | _ | p ) <;> simp_all +arith +decide ;

/-
Every prime is deficient.
-/
theorem prime_deficient {p : ℕ} (hp : p.Prime) : Deficient p := by
  unfold Deficient; rw [ abundancy_prime hp ] ; rw [ div_lt_iff₀ ] <;> norm_cast <;> linarith [ hp.two_le ] ;

/-
Every prime power `p^k` with `k ≥ 1` is deficient: `σ(p^k)/p^k < 2`.
This is the geometric-series estimate `∑_{i=0}^{k} p^{-i} < p/(p-1) ≤ 2`.
-/
theorem primePow_deficient {p k : ℕ} (hp : p.Prime) (hk : 1 ≤ k) :
    Deficient (p ^ k) := by
  -- By definition, the goal is `(σ 1 (p^k) : ℚ) / (p^k : ℚ) < 2` which simplifies to `(σ 1 (p^k) : ℚ) < 2 * (p^k : ℚ)` because `(p^k : ℚ)` is positive.
  -- Using the geometric series formula, we know that `σ 1 (p^k) = ∑_{i=0}^{k} p^i = (p^(k+1) - 1) / (p - 1)`.
  have h_sum : (σ 1 (p ^ k) : ℚ) = (p ^ (k + 1) - 1 : ℚ) / (p - 1) := by
    simp +decide [ ← geom_sum_mul, hp, ArithmeticFunction.sigma_apply ];
    rw [ mul_div_cancel_right₀ _ ( sub_ne_zero_of_ne ( mod_cast hp.ne_one ) ) ];
  refine' div_lt_iff₀ ( by norm_cast; exact pow_pos hp.pos _ ) |>.2 _;
  rcases p with ( _ | _ | p ) <;> simp_all +decide [ pow_succ' ];
  rw [ div_lt_iff₀ ] <;> nlinarith [ pow_le_pow_right₀ ( by linarith : 1 ≤ ( p : ℚ ) + 1 + 1 ) hk ]

/-
No perfect number is a prime power.  Hence every perfect number has at least
two distinct prime factors.
-/
theorem perfect_not_isPrimePow {n : ℕ} (h : n.Perfect) : ¬ IsPrimePow n := by
  -- Assume `IsPrimePow n`. Then there exists `p k` with `Prime p`, `0 < k`, `p^k = n`.
  by_contra h_prime_pow
  obtain ⟨p, k, hp, hk, rfl⟩ : ∃ p k : ℕ, Nat.Prime p ∧ 0 < k ∧ p^k = n := by
    rw [ isPrimePow_nat_iff ] at h_prime_pow ; aesop;
  -- Since `Prime p` in ℕ gives `p.Prime` (`Nat.prime_iff.mpr`), `primePow_deficient` yields `Deficient (p^k)`, i.e. `abundancy (p^k) < 2`.
  have h_deficient : Deficient (p^k) := by
    exact primePow_deficient hp hk;
  exact h_deficient.not_ge ( by rw [ abundancy_eq_two_iff_perfect ( pow_pos hp.pos _ ) |>.2 h ] )

/-
A perfect number has at least two distinct prime factors.
-/
theorem perfect_two_le_card_primeFactors {n : ℕ} (h : n.Perfect) :
    2 ≤ n.primeFactors.card := by
  by_contra h_contra;
  interval_cases _ : Finset.card n.primeFactors <;> simp_all +decide;
  · cases ‹_› <;> simp_all +decide [ Nat.Perfect ];
  · exact absurd ( perfect_not_isPrimePow h ) ( by rw [ isPrimePow_iff_card_primeFactors_eq_one ] ; aesop )

/-
For a perfect number, the sum of reciprocals of its divisors is exactly `2`.
-/
theorem perfect_sum_reciprocal_divisors {n : ℕ} (h : n.Perfect) :
    ∑ d ∈ n.divisors, (1 : ℚ) / d = 2 := by
  convert congr_arg ( fun x : ℚ => x / n ) ( show ∑ d ∈ n.divisors, ( d : ℚ ) = 2 * n from ?_ ) using 1;
  · rw [ Finset.sum_div _ _ _, ← Nat.sum_div_divisors ];
    exact Finset.sum_congr rfl fun x hx => by aesop;
  · rw [ mul_div_cancel_right₀ _ ( Nat.cast_ne_zero.mpr <| by rintro rfl; simp_all +decide [ Nat.Perfect ] ) ];
  · rw [ ← Nat.cast_sum, Nat.sum_divisors_eq_sum_properDivisors_add_self, two_mul, h.1 ];
    norm_cast

/-
`12` is abundant: a concrete witness that abundant numbers exist.
-/
theorem abundant_twelve : Abundant 12 := by
  show 2 < (σ 1 12 : ℚ) / 12
  have h : σ 1 12 = 28 := by decide
  rw [h]; norm_num

end PerfectNumbers