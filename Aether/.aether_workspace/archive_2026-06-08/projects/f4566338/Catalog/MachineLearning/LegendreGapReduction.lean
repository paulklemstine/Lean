import Mathlib

/-!
# Legendre's Conjecture: Formal Prime-Gap Reduction Framework

This file establishes a formal framework around Legendre's conjecture, which asserts
that for every positive integer `n`, there exists a prime `p` with `n² < p < (n+1)²`.

## Main results

### Definitions
- `squareInterval n` : the set `{n² + 1, ..., (n+1)² - 1}` as a `Finset ℕ`
- `squarePrimeCount n` : the number of primes in `squareInterval n`
- `LegendreHolds n` : the proposition that a prime exists in `(n², (n+1)²)`
- `cramerSquareExpectation n` : the Cramér-model expected prime count in the interval

### Unconditional theorems
- `not_prime_sq` : `m²` is not prime for `m ≥ 2`
- `exists_prime_between_sq_and_two_mul_sq` : Bertrand implies a prime in `(n², 2n²)` for `n ≥ 2`

### Reduction theorems
- `legendre_of_prime_in_short_intervals` : short-interval prime hypothesis implies Legendre
- `legendre_of_eventually_verified` : eventual short intervals + finite check implies full Legendre

### Cramér model
- `cramer_interval_expectation_lower_bound` : rigorous lower bound on expected prime count
- `cramer_square_interval_expectation_diverges` : the expected count diverges to infinity
-/

open Finset BigOperators Nat

/-! ## Definitions -/

/-- The interval of natural numbers strictly between consecutive squares:
    `{n² + 1, n² + 2, ..., (n+1)² - 1}`. -/
def squareInterval (n : ℕ) : Finset ℕ :=
  Finset.Icc (n ^ 2 + 1) ((n + 1) ^ 2 - 1)

/-- The number of primes in the open interval `(n², (n+1)²)`. -/
def squarePrimeCount (n : ℕ) : ℕ :=
  ((squareInterval n).filter Nat.Prime).card

/-- Legendre's conjecture for a specific `n`: there exists a prime in `(n², (n+1)²)`. -/
def LegendreHolds (n : ℕ) : Prop :=
  ∃ p : ℕ, Nat.Prime p ∧ n ^ 2 < p ∧ p < (n + 1) ^ 2

/-- The Cramér-model expected number of "primes" in `(n², (n+1)²)`, defined as
    `∑_{k ∈ squareInterval n} 1/log(k)`. -/
noncomputable def cramerSquareExpectation (n : ℕ) : ℝ :=
  ∑ k ∈ squareInterval n, (Real.log (k : ℝ))⁻¹

/-! ## Basic arithmetic lemmas -/

/-
A perfect square `m²` is not prime when `m ≥ 2`.
-/
theorem not_prime_sq {m : ℕ} (_hm : 2 ≤ m) : ¬ Nat.Prime (m ^ 2) := by
  exact not_irreducible_pow <| by decide;

/-
The cardinality of the square interval is `2n`.
-/
theorem squareInterval_card {n : ℕ} (hn : 1 ≤ n) :
    (squareInterval n).card = 2 * n := by
  convert Nat.card_Icc ( n ^ 2 + 1 ) ( ( n + 1 ) ^ 2 - 1 ) using 1 ; ring;
  omega

/-
Key identity: `(n+1)² - n² = 2n + 1`.
-/
theorem sq_succ_sub_sq (n : ℕ) : (n + 1) ^ 2 - n ^ 2 = 2 * n + 1 := by
  exact Nat.sub_eq_of_eq_add <| by ring;

/-
`Nat.sqrt (n * n) = n` (multiplication form).
-/
theorem nat_sqrt_mul_self (n : ℕ) : Nat.sqrt (n * n) = n := by
  norm_num [ ← sq ]

/-! ## Unconditional theorem from Bertrand's postulate -/

/-
For every `n ≥ 2`, there exists a prime `p` with `n² < p < 2n²`.
    This follows directly from Bertrand's postulate applied to `n²`.
-/
theorem exists_prime_between_sq_and_two_mul_sq
    {n : ℕ} (hn : 2 ≤ n) :
    ∃ p : ℕ, Nat.Prime p ∧ n ^ 2 < p ∧ p < 2 * n ^ 2 := by
  exact Nat.exists_prime_lt_and_le_two_mul ( n ^ 2 ) ( by positivity ) |> fun ⟨ p, hp₁, hp₂ ⟩ => ⟨ p, hp₁, hp₂.1, hp₂.2.lt_of_ne fun h => by have := hp₁.eq_two_or_odd; aesop ⟩

/-! ## Gap-to-Legendre reduction -/

/-
**Main reduction theorem.** If every `m ≥ N` has a prime in `(m, m + 2√m + 1]`,
    then Legendre's conjecture holds for all `n` with `n² ≥ N`.

    The key insight is that `(n+1)² - n² = 2n + 1` and `√(n²) = n`, so the
    short-interval hypothesis with `L(m) = 2√m + 1` exactly covers the gap
    between consecutive squares. The endpoint `(n+1)²` is excluded because
    it is composite for `n ≥ 1`.
-/
theorem legendre_of_prime_in_short_intervals
    (N : ℕ)
    (hgap : ∀ m ≥ N, ∃ p : ℕ, Nat.Prime p ∧ m < p ∧ p ≤ m + (2 * Nat.sqrt m + 1)) :
    ∀ n : ℕ, n * n ≥ N → ∃ p : ℕ, Nat.Prime p ∧ n * n < p ∧ p < (n + 1) * (n + 1) := by
  intro n hn;
  -- Apply the gap hypothesis to m = n*n.
  obtain ⟨p, hp_prime, hp_bounds⟩ := hgap (n * n) hn;
  refine' ⟨ p, hp_prime, hp_bounds.1, lt_of_le_of_ne ( by nlinarith only [ hp_bounds.2, Nat.sqrt_le ( n * n ) ] ) _ ⟩;
  rintro rfl;
  exact Nat.not_prime_mul ( by nlinarith only [ hp_prime.two_le ] ) ( by nlinarith only [ hp_prime.two_le ] ) hp_prime

/-! ## Finite verification reduction -/

/-
**Finite verification architecture.** If:
    1. For all `m ≥ N`, there is a prime in `(m, m + 2√m + 1]` (eventual short-interval theorem),
    2. Legendre is verified for all `n` with `n² < N` (finite computation),
    then Legendre holds for all `n`.
-/
theorem legendre_of_eventually_verified
    (N : ℕ)
    (hlarge : ∀ m ≥ N, ∃ p : ℕ, Nat.Prime p ∧ m < p ∧ p ≤ m + (2 * Nat.sqrt m + 1))
    (hsmall : ∀ n : ℕ, n * n < N → ∃ p : ℕ, Nat.Prime p ∧ n * n < p ∧ p < (n + 1) * (n + 1)) :
    ∀ n : ℕ, ∃ p : ℕ, Nat.Prime p ∧ n * n < p ∧ p < (n + 1) * (n + 1) := by
  intro n
  by_cases hn : n * n < N;
  · exact hsmall n hn;
  · exact legendre_of_prime_in_short_intervals N hlarge n ( by linarith )

/-! ## Cramér model lower bound -/

/-
**Cramér-model lower bound.** The expected number of model-primes in `(n², (n+1)²)`
    under the Cramér random model is at least `(2n - 1) / log((n+1)²)`.

    This follows from the fact that each term `1/log(k)` in the sum is at least
    `1/log((n+1)²)` (since `k < (n+1)²` implies `log(k) ≤ log((n+1)²)`),
    and the interval contains `2n` integers (for `n ≥ 1`). We use the slightly
    weaker bound with `2n - 1` to avoid boundary issues.
-/
theorem cramer_interval_expectation_lower_bound
    {n : ℕ} (hn : 2 ≤ n) :
    ((2 : ℝ) * n - 1) / Real.log ((↑n + 1) ^ 2 : ℝ) ≤ cramerSquareExpectation n := by
  refine' le_trans _ ( Finset.sum_le_sum fun x hx => inv_anti₀ ( Real.log_pos _ ) ( Real.log_le_log _ <| show ( x : ℝ ) ≤ ( n + 1 ) ^ 2 by norm_cast; exact le_trans ( Finset.mem_Icc.mp hx |>.2 ) <| Nat.sub_le _ _ ) );
  · norm_num [ div_eq_mul_inv, squareInterval_card ( by linarith : 1 ≤ n ) ];
    exact mul_le_mul_of_nonneg_right ( by linarith ) ( mul_nonneg ( inv_nonneg.2 ( Real.log_nonneg ( by linarith ) ) ) ( by norm_num ) );
  · norm_cast;
    exact lt_of_lt_of_le ( by nlinarith ) ( Finset.mem_Icc.mp hx |>.1 );
  · exact Nat.cast_pos.mpr ( by nlinarith [ Finset.mem_Icc.mp hx ] )

/-
**Divergence of expected prime count.** The Cramér-model expected number of primes
    in `(n², (n+1)²)` tends to infinity as `n → ∞`. This formalizes the heuristic
    prediction that primes become increasingly abundant between consecutive squares.
-/
theorem cramer_square_interval_expectation_diverges :
    Filter.Tendsto
      (fun n : ℕ => cramerSquareExpectation n)
      Filter.atTop
      Filter.atTop := by
  -- We'll use the fact that $(2n-1)/(2\log(n+1))$ tends to infinity as $n$ tends to infinity.
  have h_lower_bound : Filter.Tendsto (fun n : ℕ => ((2 : ℝ) * n - 1) / (2 * Real.log (n + 1))) Filter.atTop Filter.atTop := by
    -- We can use the fact that $\log(n+1)$ grows slower than $n$ to show that the limit is infinity.
    have h_log_growth : Filter.Tendsto (fun n : ℕ => (n : ℝ) / Real.log (n + 1)) Filter.atTop Filter.atTop := by
      -- We can use the change of variables $u = n + 1$ to simplify the expression.
      suffices h_change : Filter.Tendsto (fun u : ℕ => (u - 1 : ℝ) / Real.log u) Filter.atTop Filter.atTop by
        convert h_change.comp ( Filter.tendsto_add_atTop_nat 1 ) using 2 ; norm_num;
      -- We can use the fact that $\frac{u}{\log u}$ tends to infinity as $u$ tends to infinity.
      have h_log : Filter.Tendsto (fun u : ℕ => (u : ℝ) / Real.log u) Filter.atTop Filter.atTop := by
        -- We can use the change of variables $v = \log u$ to transform the limit expression.
        suffices h_log : Filter.Tendsto (fun v : ℝ => Real.exp v / v) Filter.atTop Filter.atTop by
          have := h_log.comp Real.tendsto_log_atTop;
          exact this.comp tendsto_natCast_atTop_atTop |> Filter.Tendsto.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with x hx using by simp +decide [ Real.exp_log ( Nat.cast_pos.mpr hx ) ] );
        simpa using Real.tendsto_exp_div_pow_atTop 1;
      simp_all +decide [ sub_div ];
      exact Filter.Tendsto.atTop_add ( h_log ) ( Filter.Tendsto.neg ( tendsto_inv_atTop_zero.comp ( Real.tendsto_log_atTop.comp tendsto_natCast_atTop_atTop ) ) );
    rw [ Filter.tendsto_atTop_atTop ] at *;
    exact fun b => by obtain ⟨ i, hi ⟩ := h_log_growth ( b * 2 ) ; exact ⟨ i + 2, fun n hin => by have := hi n ( by linarith ) ; rw [ le_div_iff₀ ] at * <;> nlinarith [ show ( n : ℝ ) ≥ i + 2 by norm_cast, Real.log_pos ( show ( n : ℝ ) + 1 > 1 by norm_cast; linarith ) ] ⟩ ;
  refine' Filter.tendsto_atTop_mono' _ _ h_lower_bound;
  filter_upwards [ Filter.eventually_ge_atTop 2 ] with n hn using by simpa [ mul_comm, Real.log_pow ] using cramer_interval_expectation_lower_bound hn;

/-! ## Legendre equivalence with squarePrimeCount -/

/-
Legendre holds at `n` if and only if `squarePrimeCount n ≥ 1`.
-/
theorem legendreHolds_iff_squarePrimeCount_pos {n : ℕ} (hn : 1 ≤ n) :
    LegendreHolds n ↔ 0 < squarePrimeCount n := by
  constructor;
  · rintro ⟨ p, hp₁, hp₂, hp₃ ⟩;
    exact Finset.card_pos.mpr ⟨ p, Finset.mem_filter.mpr ⟨ Finset.mem_Icc.mpr ⟨ by linarith, Nat.le_sub_one_of_lt hp₃ ⟩, hp₁ ⟩ ⟩;
  · intro h;
    obtain ⟨ p, hp ⟩ := Finset.card_pos.mp h;
    exact ⟨ p, Finset.mem_filter.mp hp |>.2, by linarith [ Finset.mem_Icc.mp ( Finset.mem_filter.mp hp |>.1 ) ], by linarith [ Finset.mem_Icc.mp ( Finset.mem_filter.mp hp |>.1 ), Nat.sub_add_cancel ( show 1 ≤ ( n + 1 ) ^ 2 from by nlinarith ) ] ⟩