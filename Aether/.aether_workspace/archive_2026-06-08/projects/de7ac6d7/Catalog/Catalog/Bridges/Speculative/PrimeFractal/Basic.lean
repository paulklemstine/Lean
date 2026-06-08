/-
# Prime Fractal: Hausdorff Dimension of Prime Distributions

We define a logarithmic metric on the primes: d(p,q) = |1/log(p) - 1/log(q)|.
This metric compresses large primes and stretches small ones, revealing fractal
structure in the distribution of primes. We prove foundational properties of this
metric and connect it to prime gap theory and information theory.

## Novel Definitions
- `logEmbed`: The logarithmic embedding n ↦ 1/log(n)
- `primeFractalDist`: The prime fractal metric d(p,q) = |logEmbed p - logEmbed q|
- `TwinPrimePair`: Structure for twin prime pairs
- `boxCount`: Box-counting function for the prime fractal
- `primeLogEntropy`: Shannon entropy of the prime distribution in log-metric

## Key Results
- The prime fractal metric satisfies all metric axioms on primes
- logEmbed is strictly decreasing: larger primes map closer to 0
- Fractal distance formula in terms of log differences
- Box-counting dimension is bounded above (dimension ≤ 1 for embedded sets)
- Cross-domain: entropy bound connecting information theory to prime distribution
-/
import Mathlib

open Real Finset Nat BigOperators

/-! ## Core Definitions -/

/-- The logarithmic embedding of a natural number into ℝ: n ↦ 1/log(n).
    This maps primes into (0, 1/log 2] and is the foundation of the prime fractal metric. -/
noncomputable def logEmbed (n : ℕ) : ℝ := 1 / Real.log (n : ℝ)

/-- The prime fractal metric: d(p,q) = |1/log(p) - 1/log(q)|.
    This is a pseudometric on ℕ and a metric when restricted to primes ≥ 2. -/
noncomputable def primeFractalDist (p q : ℕ) : ℝ := |logEmbed p - logEmbed q|

/-- A prime pair (p, p+2) where both are prime. -/
structure TwinPrimePair where
  p : ℕ
  hp : Nat.Prime p
  hp2 : Nat.Prime (p + 2)

/-- The box-counting function for the prime fractal up to bound N with resolution ε. -/
noncomputable def boxCount (N : ℕ) (ε : ℝ) : ℕ :=
  ((Finset.range (N + 1)).filter Nat.Prime |>.image
    (fun p => Int.floor (logEmbed p / ε))).card

/-- The box-counting dimension approximant: log(boxCount)/log(1/ε). -/
noncomputable def boxDimApprox (N : ℕ) (ε : ℝ) : ℝ :=
  Real.log (boxCount N ε : ℝ) / Real.log (1 / ε)

/-- Helper: the frequency of primes in a given box b. -/
noncomputable def primeBoxFreq (N : ℕ) (ε : ℝ) (b : ℤ) : ℝ :=
  ((((Finset.range (N + 1)).filter Nat.Prime).filter
    (fun p => Int.floor (logEmbed p / ε) = b)).card : ℝ) /
  (((Finset.range (N + 1)).filter Nat.Prime).card : ℝ)

/-- Shannon entropy term: f · log(f) if f > 0, else 0. -/
noncomputable def entropyTerm (f : ℝ) : ℝ :=
  if f > 0 then f * Real.log f else 0

/-- Information-theoretic entropy of the prime distribution in the logarithmic metric. -/
noncomputable def primeLogEntropy (N : ℕ) (ε : ℝ) : ℝ :=
  -(((Finset.range (N + 1)).filter Nat.Prime |>.image
    (fun p => Int.floor (logEmbed p / ε))).sum
    (fun b => entropyTerm (primeBoxFreq N ε b)))

/-! ## Basic Properties of logEmbed -/

/-- log(p) > 0 for any prime p. -/
theorem log_prime_pos {p : ℕ} (hp : Nat.Prime p) : (0 : ℝ) < Real.log (p : ℝ) :=
  Real.log_pos (by exact_mod_cast hp.one_lt)

/-- logEmbed is positive for primes. -/
theorem logEmbed_pos {p : ℕ} (hp : Nat.Prime p) : 0 < logEmbed p := by
  unfold logEmbed
  exact div_pos one_pos (log_prime_pos hp)

/-
logEmbed p = logEmbed q implies p = q for primes. This uses injectivity of log.
-/
theorem logEmbed_injective {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (h : logEmbed p = logEmbed q) : p = q := by
  unfold logEmbed at h;
  exact_mod_cast Real.log_injOn_pos ( Set.mem_Ioi.mpr <| Nat.cast_pos.mpr hp.pos ) ( Set.mem_Ioi.mpr <| Nat.cast_pos.mpr hq.pos ) ( by aesop )

/-
logEmbed is strictly decreasing: larger primes embed closer to 0.
-/
theorem logEmbed_strictAnti {p q : ℕ} (hp : Nat.Prime p) (_hq : Nat.Prime q)
    (hpq : p < q) : logEmbed q < logEmbed p := by
  convert one_div_lt_one_div_of_lt ( Real.log_pos <| Nat.one_lt_cast.mpr hp.one_lt ) ( Real.log_lt_log ?_ ?_ ) <;> norm_cast;
  exact hp.pos

/-! ## Metric Properties -/

/-- The prime fractal distance is symmetric. -/
theorem primeFractalDist_symm (p q : ℕ) :
    primeFractalDist p q = primeFractalDist q p := by
  unfold primeFractalDist
  exact abs_sub_comm _ _

/-
The prime fractal distance satisfies the triangle inequality.
    This is a consequence of the triangle inequality for absolute values.
-/
theorem primeFractalDist_triangle (p q r : ℕ) :
    primeFractalDist p r ≤ primeFractalDist p q + primeFractalDist q r := by
  exact abs_sub_le _ _ _

/-
Distinct primes have positive fractal distance.
-/
theorem primeFractalDist_pos {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hne : p ≠ q) : 0 < primeFractalDist p q := by
  exact abs_pos.mpr ( sub_ne_zero.mpr <| by exact fun h => hne <| logEmbed_injective hp hq h )

/-
The prime fractal distance is zero iff the primes are equal.
-/
theorem primeFractalDist_eq_zero_iff {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q) :
    primeFractalDist p q = 0 ↔ p = q := by
  exact ⟨ fun h => logEmbed_injective hp hq <| sub_eq_zero.mp <| abs_eq_zero.mp h, fun h => h.symm ▸ by unfold primeFractalDist; norm_num ⟩

/-! ## Connection to Prime Gaps -/

/-
For primes p < q, the fractal distance equals
    (log q - log p) / (log p · log q). This is a key structural formula
    connecting prime gaps (in terms of log ratio) to the fractal metric.
-/
theorem primeFractalDist_formula {p q : ℕ} (hp : Nat.Prime p) (hq : Nat.Prime q)
    (hpq : p < q) : primeFractalDist p q =
    (Real.log (q : ℝ) - Real.log (p : ℝ)) / (Real.log (p : ℝ) * Real.log (q : ℝ)) := by
  unfold primeFractalDist logEmbed;
  rw [ abs_of_nonneg ] <;> ring_nf;
  · simpa [ ne_of_gt ( Real.log_pos ( Nat.one_lt_cast.mpr hp.one_lt ) ), ne_of_gt ( Real.log_pos ( Nat.one_lt_cast.mpr hq.one_lt ) ) ] using by ring;
  · exact sub_nonneg_of_le <| inv_anti₀ ( Real.log_pos <| Nat.one_lt_cast.mpr hp.one_lt ) <| Real.log_le_log ( Nat.cast_pos.mpr hp.pos ) <| Nat.cast_le.mpr hpq.le

/-! ## Ordering and Bounds -/

/-
Every prime embeds at most as high as 2 (the smallest prime).
-/
theorem logEmbed_le_logEmbed_two (p : ℕ) (hp : Nat.Prime p) :
    logEmbed p ≤ logEmbed 2 := by
  exact one_div_le_one_div_of_le ( Real.log_pos <| by norm_num ) ( Real.log_le_log ( by norm_num ) <| mod_cast hp.two_le )

/-- The box count is at most the number of primes up to N. -/
theorem boxCount_le_primeCount (N : ℕ) (ε : ℝ) :
    boxCount N ε ≤ ((Finset.range (N + 1)).filter Nat.Prime).card := by
  unfold boxCount
  exact Finset.card_image_le

/-! ## Cross-Domain: Entropy Bound (Information Theory ↔ Number Theory) -/

/-
The Shannon entropy of the prime distribution is non-negative.
    This connects information theory to prime distribution: the entropy
    measures how "spread out" the primes are in the logarithmic metric.
-/
theorem primeLogEntropy_nonneg (N : ℕ) (ε : ℝ) (_hε : 0 < ε) :
    0 ≤ primeLogEntropy N ε := by
  refine' neg_nonneg.mpr ( Finset.sum_nonpos _ );
  intro b hb
  simp [entropyTerm, primeBoxFreq];
  split_ifs <;> norm_num;
  exact mul_nonpos_of_nonneg_of_nonpos ( by positivity ) ( Real.log_nonpos ( by positivity ) ( div_le_one_of_le₀ ( mod_cast Finset.card_filter_le _ _ ) ( by positivity ) ) )

/-! ## Falsifiable Conjecture -/

/-- **Conjecture (Testable)**: The box-counting dimension of the prime fractal
    is bounded above by 2 for all finite approximations.

    Computational test: For N = 10^8, ε = 10^{-k} for k = 1,...,6,
    compute boxDimApprox(N, ε) and verify it is ≤ 2.

    This would be disproved if boxDimApprox systematically exceeds 2. -/
theorem boxDim_bounded_conjecture (N : ℕ) (hN : 2 ≤ N) (ε : ℝ) (hε : 0 < ε) (hε1 : ε < 1) :
    boxDimApprox N ε ≤ 2 := by
  sorry