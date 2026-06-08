/-
  # Cramér's Conjecture on Prime Gaps

  This module formalizes key concepts around prime gaps, the Cramér random model,
  and provable unconditional bounds on gaps between consecutive primes.

  ## Main definitions
  - `nextPrime`: the smallest prime > n
  - `primeGap`: the gap nextPrime(p) - p
  - `CramerRandomModel`: structure capturing the probabilistic heuristic
  - `CramerConjectureHolds`: formal statement that gaps are O((log p)²)

  ## Main results
  - `bertrand_prime_gap_bound`: gap between consecutive primes < p (from Bertrand)
  - `prime_gap_lt_self`: for p ≥ 2 prime, the next prime is < 2p
  - `cramer_bound_sublinear`: Cramér ⟹ sublinear gaps
  - `arbitrarily_large_prime_gaps`: gaps are unbounded
-/
import Mathlib

open Nat

/-! ## Next prime function -/

/-- The smallest prime that is strictly greater than n. -/
noncomputable def nextPrime (n : ℕ) : ℕ :=
  Nat.find (show ∃ p, p > n ∧ Nat.Prime p from
    let ⟨p, hp, hprime⟩ := Nat.exists_infinite_primes (n + 1)
    ⟨p, by omega, hprime⟩)

/-
nextPrime n is strictly greater than n.
-/
theorem nextPrime_gt (n : ℕ) : nextPrime n > n := by
  -- By definition of `nextPrime`, � it� is the smallest prime greater than `n`.
  unfold nextPrime
  exact Nat.find_spec (Nat.exists_infinite_primes (n + 1)) |>.1 |> Nat.lt_of_succ_le

/-
nextPrime n is prime.
-/
theorem nextPrime_prime (n : ℕ) : Nat.Prime (nextPrime n) := by
  exact Nat.find_spec ( _ : ∃ p : ℕ, p > n ∧ Nat.Prime p ) |>.2

/-
nextPrime n is the least prime > n.
-/
theorem nextPrime_least {n p : ℕ} (hp : Nat.Prime p) (hn : p > n) :
    nextPrime n ≤ p := by
  exact Nat.find_min' _ ⟨ hn, hp ⟩

/-! ## Prime gap -/

/-- The prime gap at n: the distance from n to the next prime. -/
noncomputable def primeGap (n : ℕ) : ℕ := nextPrime n - n

/-
The gap from any prime p to the next prime is at least 1
    (since primes > 1 and the next prime is strictly greater).
-/
theorem primeGap_pos (n : ℕ) : primeGap n ≥ 1 := by
  exact Nat.sub_pos_of_lt ( nextPrime_gt n )

/-! ## Bertrand-based prime gap bound

The key unconditional result: Bertrand's postulate gives us that
for n ≥ 1, there exists a prime in (n, 2n], so the next prime after
any n ≥ 1 is at most 2n. -/

/-
From Bertrand's postulate: for n ≥ 1, the next prime is at most 2n.
-/
theorem nextPrime_le_two_mul {n : ℕ} (hn : n ≥ 1) :
    nextPrime n ≤ 2 * n := by
  obtain ⟨ p, hp ⟩ := Nat.exists_prime_lt_and_le_two_mul n ( by linarith );
  exact le_trans ( nextPrime_least hp.1 hp.2.1 ) hp.2.2

/-
**Bertrand gap bound**: For any n ≥ 2, the gap to the next prime is < n.
    (For n = 1, the gap is exactly 1, so we need n ≥ 2.)
-/
theorem bertrand_prime_gap_lt {n : ℕ} (hn : n ≥ 2) :
    primeGap n < n := by
  rw [ primeGap ];
  rw [ tsub_lt_iff_left ( nextPrime_gt n |> le_of_lt ) ];
  rw [ ← two_mul ];
  exact lt_of_le_of_ne ( nextPrime_le_two_mul ( by linarith ) ) fun h => by have := nextPrime_prime n; rw [ h, Nat.prime_mul_iff ] at this; aesop;

/-
For any prime p, the gap to the next prime is strictly less than p.
-/
theorem prime_gap_lt_self {p : ℕ} (hp : Nat.Prime p) :
    primeGap p < p := by
  exact bertrand_prime_gap_lt hp.two_le

/-! ## Cramér's Random Model -/

/-- A Cramér-type random model assigns density 1/log(n) to each integer n ≥ 2.
    This captures the heuristic that primes behave like independent events
    with probability 1/log(n). -/
structure CramerRandomModel where
  /-- The density function: probability of being "prime" in the model -/
  density : ℕ → ℝ
  /-- Density equals 1/log(n) for n ≥ 2 -/
  density_spec : ∀ n : ℕ, n ≥ 2 → density n = 1 / Real.log n
  /-- Density is nonneg -/
  density_nonneg : ∀ n, density n ≥ 0

/-
The standard Cramér model exists.
-/
noncomputable def cramerModel : CramerRandomModel where
  density n := if n ≥ 2 then 1 / Real.log n else 0
  density_spec := by
    intro n hn
    simp [show n ≥ 2 from hn]
  density_nonneg := by
    exact fun n => by split_ifs <;> positivity;

/-! ## Cramér's conjecture (formal statement) -/

/-- **Cramér's conjecture**: There exists a constant C > 0 such that for all primes p,
    the gap to the next prime is at most C · (log p)². -/
def CramerConjectureHolds : Prop :=
  ∃ C : ℝ, C > 0 ∧ ∀ p : ℕ, Nat.Prime p → p ≥ 2 →
    (primeGap p : ℝ) ≤ C * (Real.log p) ^ 2

/-- **Strong Cramér conjecture** (with C = 1): for large enough primes. -/
def StrongCramerConjecture : Prop :=
  ∀ p : ℕ, Nat.Prime p → p ≥ 11 →
    (primeGap p : ℝ) ≤ (Real.log p) ^ 2

/-! ## Cramér implies sublinear gaps -/

/-
If Cramér's conjecture holds, then for any ε > 0, the gap is eventually
    at most ε · p. This is because (log p)² = o(p).
-/
theorem cramer_bound_sublinear :
    CramerConjectureHolds →
    ∀ ε : ℝ, ε > 0 →
    ∃ N : ℕ, ∀ p : ℕ, Nat.Prime p → p ≥ N →
      (primeGap p : ℝ) ≤ ε * p := by
  intro h ε hε_pos
  obtain ⟨C, hC_pos, h_bound⟩ := h
  have h_log_sq_div_p_zero : Filter.Tendsto (fun p : ℕ => (Real.log p)^2 / (p : ℝ)) Filter.atTop (nhds 0) := by
    -- Let $y = \log x$, therefore the expression becomes $\frac{y^2}{e^y}$.
    suffices h_log : Filter.Tendsto (fun y : ℝ => y^2 / Real.exp y) Filter.atTop (nhds 0) by
      have := h_log.comp Real.tendsto_log_atTop;
      exact this.comp tendsto_natCast_atTop_atTop |> Filter.Tendsto.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with x hx using by simp +decide [ Real.exp_log ( Nat.cast_pos.mpr hx ) ] );
    simpa [ Real.exp_neg ] using Real.tendsto_pow_mul_exp_neg_atTop_nhds_zero 2;
  -- Using the fact that (log p)^2 / p → 0, we can find N such that for all p ≥ N, (log p)^2 / p < ε / C.
  obtain ⟨N, hN⟩ : ∃ N : ℕ, ∀ p : ℕ, p ≥ N → (Real.log p)^2 / (p : ℝ) < ε / C := by
    simpa using h_log_sq_div_p_zero.eventually ( gt_mem_nhds <| by positivity );
  exact ⟨ N + 2, fun p hp hp' => le_trans ( h_bound p hp ( by linarith ) ) ( by have := hN p ( by linarith ) ; rw [ div_lt_div_iff₀ ] at this <;> nlinarith [ show ( p : ℝ ) ≥ 2 by norm_cast; linarith [ hp.two_le ] ] ) ⟩

/-! ## Log bounds -/

/-
For n ≥ 3 (as a real number), log(n) > 1.
-/
theorem log_gt_one_of_ge_three (n : ℕ) (hn : n ≥ 3) :
    Real.log (n : ℝ) > 1 := by
  exact Real.lt_log_iff_exp_lt ( by positivity ) |>.2 ( Real.exp_one_lt_d9.trans_le ( by norm_num; linarith [ show ( n : ℝ ) ≥ 3 by norm_cast ] ) )

/-
(log n)² < n for all n ≥ 1. Shows Cramér is strictly stronger than Bertrand.
-/
theorem log_sq_lt_self (n : ℕ) (hn : n ≥ 1) :
    (Real.log (n : ℝ)) ^ 2 < (n : ℝ) := by
  -- For $n \geq 3$, we use the inequality $\log(n) < \sqrt{n}$.
  have h_log_lt_sqrt : Real.log (n : ℝ) < Real.sqrt (n : ℝ) := by
    have := Real.log_le_sub_one_of_pos ( show 0 < Real.sqrt n / 2 by positivity );
    rw [ Real.log_div ( by positivity ) ( by positivity ), Real.log_sqrt ( by positivity ) ] at this;
    have := Real.log_two_lt_d9 ; norm_num at * ; linarith;
  exact lt_of_lt_of_le ( pow_lt_pow_left₀ h_log_lt_sqrt ( Real.log_nonneg ( mod_cast hn ) ) ( by norm_num ) ) ( by rw [ Real.sq_sqrt ( Nat.cast_nonneg _ ) ] )

/-! ## Unboundedness of prime gaps -/

/-
There exist arbitrarily large prime gaps.
    Proof idea: the consecutive integers n!+2, n!+3, ..., n!+n are all composite
    (since k | n! + k for 2 ≤ k ≤ n), giving a gap of length ≥ n-1.
-/
theorem arbitrarily_large_prime_gaps :
    ∀ k : ℕ, ∃ n : ℕ, Nat.Prime n ∧ primeGap n ≥ k := by
  -- For any $k$, consider the sequence of numbers $(k+1)! + 2, (k+ �1�)! + 3, \ldots, ( (�k�+1)! + (k+1)$. Each of these numbers is composite.
  have h_composite : ∀ k : ℕ, ∀ n ∈ Finset.Icc 2 (k + 1), ¬Nat.Prime ((k + 1)! + n) := by
    intros k n hn; rw [ Nat.prime_def_lt' ] ;
    exact fun h => h.2 _ ( Finset.mem_Icc.mp hn |>.1 ) ( by linarith [ Finset.mem_Icc.mp hn |>.2, Nat.self_le_factorial ( k + 1 ) ] ) ( Nat.dvd_add ( Nat.dvd_factorial ( by linarith [ Finset.mem_Icc.mp hn |>.1 ] ) ( by linarith [ Finset.mem_Icc.mp hn |>.2 ] ) ) ( dvd_refl _ ) );
  intro k
  obtain ⟨p, hp⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ≤ (k + 1)! + 1 ∧ nextPrime p ≥ (k + 1)! + 2 := by
    -- Let $p$ be the largest prime less than or equal to $(k + 1)! + 1$.
    obtain ⟨p, hp_prime, hp_le⟩ : ∃ p : ℕ, Nat.Prime p ∧ p ≤ (k + 1)! + 1 ∧ ∀ q : ℕ, Nat.Prime q → q ≤ (k + 1)! + 1 → q ≤ p := by
      exact ⟨ Finset.max' ( Finset.filter Nat.Prime ( Finset.Iic ( ( k + 1 ) ! + 1 ) ) ) ⟨ 2, by norm_num; linarith [ Nat.factorial_pos ( k + 1 ) ] ⟩, Finset.mem_filter.mp ( Finset.max'_mem ( Finset.filter Nat.Prime ( Finset.Iic ( ( k + 1 ) ! + 1 ) ) ) ⟨ 2, by norm_num; linarith [ Nat.factorial_pos ( k + 1 ) ] ⟩ ) |>.2, Finset.mem_Iic.mp ( Finset.mem_filter.mp ( Finset.max'_mem ( Finset.filter Nat.Prime ( Finset.Iic ( ( k + 1 ) ! + 1 ) ) ) ⟨ 2, by norm_num; linarith [ Nat.factorial_pos ( k + 1 ) ] ⟩ ) |>.1 ), fun q hq hq' => Finset.le_max' _ _ <| by aesop ⟩;
    grind +locals;
  refine' ⟨ p, hp.1, _ ⟩;
  refine' le_tsub_of_add_le_left _;
  contrapose! h_composite;
  exact ⟨ k, nextPrime p - ( k + 1 ) !, Finset.mem_Icc.mpr ⟨ Nat.le_sub_of_add_le' <| by linarith, Nat.sub_le_of_le_add <| by linarith ⟩, by convert nextPrime_prime p using 1; rw [ Nat.add_sub_of_le <| by linarith ] ⟩

/-! ## Falsifiable conjecture -/

/-- **Testable prediction**: For all primes p with 11 ≤ p ≤ bound,
    the gap to the next prime is at most (log p)².
    Computationally verified up to 4 × 10^18 (Oliveira e Silva et al.).
    A single counterexample would refute Cramér's conjecture. -/
def CramerTestable (bound : ℕ) : Prop :=
  ∀ p : ℕ, Nat.Prime p → 11 ≤ p → p ≤ bound →
    (primeGap p : ℝ) ≤ (Real.log p) ^ 2

/-! ## Cryptographic connection: RSA prime search -/

/-- In RSA key generation, one needs primes of a given bit-length k.
    The expected number of candidates to test is O(k) by PNT,
    and the maximum gap (under Cramér) is O(k²). -/
def RSAPrimeSearchBound (k : ℕ) : ℕ := k ^ 2

/-- The RSA search bound is quadratic in the bit length. -/
theorem rsa_search_bound_eq (k : ℕ) :
    RSAPrimeSearchBound k = k * k := by
  unfold RSAPrimeSearchBound; ring

/-
For k ≥ 1, log₂(2^k) = k. Connects bit-length to logarithm.
-/
theorem log2_pow_eq (k : ℕ) (_hk : k ≥ 1) :
    Nat.log 2 (2 ^ k) = k := by
  exact Nat.log_pow ( by decide ) _

/-
Under Cramér's conjecture, RSA prime generation with k-bit primes
    requires testing at most O(k²) candidates. This is a bridge between
    analytic number theory and cryptographic algorithm design.
-/
theorem cramer_rsa_bridge :
    CramerConjectureHolds →
    ∃ C : ℝ, C > 0 ∧ ∀ k : ℕ, k ≥ 10 →
      ∀ p : ℕ, Nat.Prime p → 2 ^ k ≤ p → p < 2 ^ (k + 1) →
        (primeGap p : ℝ) ≤ C * (k : ℝ) ^ 2 := by
  rintro ⟨ C, hC_pos, hC ⟩;
  refine' ⟨ C * 4 * Real.log 2 ^ 2, by positivity, fun k hk p hp hp' hp'' => le_trans ( hC p hp ( by linarith [ Nat.pow_le_pow_right two_pos hk ] ) ) _ ⟩;
  -- Since $p < 2^{k+1}$, we have $\log p \leq \log (2^{k+1}) = (k+1) \log 2$.
  have h_log_bound : Real.log p ≤ (k + 1) * Real.log 2 := by
    rw [ ← Real.log_rpow zero_lt_two ] ; gcongr ; norm_cast;
    · linarith [ Nat.pow_le_pow_right two_pos hk ];
    · exact_mod_cast hp''.le;
  -- Since $(k+1) \leq 2k$ for $k \geq 10$, we have $(k+1) \log 2 \leq 2k \log 2$.
  have h_log_bound_simplified : Real.log p ≤ 2 * k * Real.log 2 := by
    exact h_log_bound.trans ( mul_le_mul_of_nonneg_right ( by norm_cast; linarith ) ( Real.log_nonneg one_le_two ) );
  convert mul_le_mul_of_nonneg_left ( pow_le_pow_left₀ ( Real.log_nonneg <| Nat.one_le_cast.mpr hp.pos ) h_log_bound_simplified 2 ) hC_pos.le using 1 ; ring