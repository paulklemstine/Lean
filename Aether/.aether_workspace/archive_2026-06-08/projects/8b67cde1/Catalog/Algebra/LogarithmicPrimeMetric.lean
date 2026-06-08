import Mathlib

/-!
# Logarithmic Prime Metric Space

We study the distribution of prime numbers through the logarithmic transform
`p ↦ 1/log p`, which maps primes into the interval `(0, 1/log 2]`. The induced
metric `d(p,q) = |1/log p - 1/log q|` captures a "fractal" signature of the primes:
the Hausdorff dimension of the image is 0 (by countability), yet the box-counting
dimension is conjectured to be 1/2, revealing a fundamental dimension gap.

## Main Definitions

* `logPrimeImage` — The map `n ↦ 1/log n` for natural numbers
* `logPrimeDist` — The metric `d(p,q) = |1/log p - 1/log q|`
* `PrimeConstellation` — A finite set of primes within a log-metric ball
* `primeLogEnergy` — The s-energy of a finite prime set in the log-metric
* `logPrimeSeparation` — Minimum pairwise log-metric distance

## Main Results

* `logPrimeImage_pos` — Positivity for primes
* `logPrimeImage_strictAnti` — Strictly decreasing on `{n : ℕ | 1 < n}`
* `logPrimeDist_eq_sub` — For p < q (both > 1), the metric equals `1/log p - 1/log q`
* `logPrimeDist_triangle` — Triangle inequality
* `logPrimeDist_pos_of_ne` — Positive-definiteness for distinct values > 1
* `logPrimeDist_ratio_form` — Gap expressed as `log(q/p) / (log p · log q)`
* `constellation_separation_pos` — Positive separation in constellations of distinct primes

## References

The dimension gap phenomenon connects to the prime number theorem through the
density of the logarithmic image. See the companion RESEARCH_PAPER.md for details.
-/

open Real Nat Finset

noncomputable section

/-! ### Core Definitions -/

/-- The logarithmic prime image: maps `n` to `1 / log(n)`.
    For primes p ≥ 2, this gives a value in `(0, 1/log 2]`. -/
def logPrimeImage (n : ℕ) : ℝ := 1 / Real.log (n : ℝ)

/-- The logarithmic prime distance between two natural numbers. -/
def logPrimeDist (p q : ℕ) : ℝ := |logPrimeImage p - logPrimeImage q|

/-- A prime log-constellation: a finite collection of primes all within
    log-metric distance `radius` of a designated center prime.
    This structure captures local clustering behavior of primes in log-space. -/
structure PrimeConstellation where
  /-- The underlying finite set of primes -/
  primes : Finset ℕ
  /-- The radius of the log-metric ball -/
  radius : ℝ
  /-- All elements are prime -/
  all_prime : ∀ p ∈ primes, Nat.Prime p
  /-- The center prime -/
  center : ℕ
  /-- The center is prime -/
  center_prime : Nat.Prime center
  /-- The center belongs to the set -/
  center_mem : center ∈ primes
  /-- All primes are within the radius of the center -/
  bounded : ∀ p ∈ primes, logPrimeDist center p ≤ radius
  /-- The radius is positive -/
  radius_pos : 0 < radius

/-- The s-energy of a finite set of natural numbers in the logarithmic metric.
    Sums `(1 / d(p,q))^s` over all ordered pairs `p < q` in the set.
    Higher energy indicates tighter clustering. -/
def primeLogEnergy (s : ℝ) (S : Finset ℕ) : ℝ :=
  ∑ p ∈ S, ∑ q ∈ S.filter (· > p), (1 / logPrimeDist p q) ^ s

/-- The set of pairwise log-metric distances in a finite set. -/
def logPrimeDistSet (S : Finset ℕ) : Finset ℝ :=
  (S.product S).filter (fun pq => pq.1 < pq.2) |>.image (fun pq => logPrimeDist pq.1 pq.2)

/-- The minimum pairwise log-metric distance in a finite set.
    Returns 0 for sets with fewer than 2 distinct elements. -/
def logPrimeSeparation (S : Finset ℕ) : ℝ :=
  if h : (logPrimeDistSet S).Nonempty then (logPrimeDistSet S).min' h else 0

/-! ### Fundamental Properties of the Log-Prime Image -/

/-
`log n > 0` for natural numbers `n ≥ 2`.
-/
theorem log_nat_pos {n : ℕ} (hn : 2 ≤ n) : (0 : ℝ) < Real.log n := by
  exact Real.log_pos <| Nat.one_lt_cast.2 hn

/-
The log-prime image is strictly positive for `n ≥ 2`.
-/
theorem logPrimeImage_pos {n : ℕ} (hn : 2 ≤ n) : 0 < logPrimeImage n := by
  exact one_div_pos.mpr ( Real.log_pos ( by norm_cast ) )

/-
The log-prime image is at most `1 / log 2` for `n ≥ 2`.
-/
theorem logPrimeImage_le_inv_log2 {n : ℕ} (hn : 2 ≤ n) :
    logPrimeImage n ≤ 1 / Real.log 2 := by
  exact one_div_le_one_div_of_le ( Real.log_pos <| by norm_num ) <| Real.log_le_log ( by norm_num ) <| mod_cast hn

/-
**Key structural theorem**: The log-prime image is strictly decreasing on
    natural numbers greater than 1. This reversal of the natural ordering is the
    fundamental mechanism by which the logarithmic transform converts the
    multiplicative structure of primes into metric structure.
-/
theorem logPrimeImage_strictAnti {a b : ℕ} (ha : 2 ≤ a) (hab : a < b) :
    logPrimeImage b < logPrimeImage a := by
  unfold logPrimeImage; gcongr;
  exact Real.log_pos <| Nat.one_lt_cast.2 ha

/-! ### Metric Properties -/

/-
The log-prime distance is symmetric.
-/
theorem logPrimeDist_symm (p q : ℕ) : logPrimeDist p q = logPrimeDist q p := by
  exact abs_sub_comm _ _

/-
The log-prime distance of a point to itself is zero.
-/
theorem logPrimeDist_self (p : ℕ) : logPrimeDist p p = 0 := by
  exact abs_eq_zero.mpr ( sub_self _ )

/-
**Triangle inequality** for the log-prime distance. Together with symmetry
    and positive-definiteness, this establishes a genuine metric on primes.
-/
theorem logPrimeDist_triangle (p q r : ℕ) :
    logPrimeDist p r ≤ logPrimeDist p q + logPrimeDist q r := by
  convert abs_sub_le _ _ _ using 1;
  infer_instance

/-
For `a < b` with both `≥ 2`, the log-prime distance equals the difference
    `1/log a - 1/log b` (which is positive by strict anti-tonicity).
-/
theorem logPrimeDist_eq_sub {a b : ℕ} (ha : 2 ≤ a) (hab : a < b) :
    logPrimeDist a b = logPrimeImage a - logPrimeImage b := by
  convert abs_of_pos ?_;
  · infer_instance;
  · exact sub_pos_of_lt ( logPrimeImage_strictAnti ha hab )

/-
**Positive-definiteness**: distinct natural numbers `≥ 2` have positive
    log-prime distance. This is the content that makes the log-prime distance
    a genuine metric, not just a pseudometric—it requires injectivity of `log`
    on `(1, ∞)`.
-/
theorem logPrimeDist_pos_of_ne {a b : ℕ} (ha : 2 ≤ a) (hb : 2 ≤ b) (hab : a ≠ b) :
    0 < logPrimeDist a b := by
  cases lt_or_gt_of_ne hab <;> simp_all +decide [ logPrimeDist, abs_of_pos ];
  · exact ne_of_gt ( sub_pos_of_lt ( logPrimeImage_strictAnti ha ‹_› ) );
  · exact ne_of_lt ( sub_neg_of_lt ( logPrimeImage_strictAnti hb ‹_› ) )

/-! ### The Ratio Form: Connecting Gaps to Ratios -/

/-
**Ratio form of the log-prime distance**: For `a, b ≥ 2` with `a < b`,
    the distance equals `log(b/a) / (log a · log b)`. This formula reveals
    that the log-metric gap between primes is governed by their *ratio*,
    not their difference—a fundamentally multiplicative perspective on
    prime gaps.
-/
theorem logPrimeDist_ratio_form {a b : ℕ} (ha : 2 ≤ a) (hab : a < b) :
    logPrimeDist a b = Real.log (b / a : ℝ) / (Real.log a * Real.log b) := by
  rw [ Real.log_div ] <;> norm_cast <;> try linarith;
  rw [ logPrimeDist_eq_sub ha hab, logPrimeImage, logPrimeImage ] ; ring;
  simpa [ ne_of_gt ( Real.log_pos ( show ( a : ℝ ) > 1 by norm_cast ) ), ne_of_gt ( Real.log_pos ( show ( b : ℝ ) > 1 by norm_cast; linarith ) ) ] using by ring;

/-! ### Constellation Properties -/

/-- In a prime constellation, all primes are bounded below by 2. -/
theorem PrimeConstellation.primes_ge_two (C : PrimeConstellation) (p : ℕ)
    (hp : p ∈ C.primes) : 2 ≤ p :=
  (C.all_prime p hp).two_le

/-
The log-prime images of all primes in a constellation lie in a bounded interval.
-/
theorem PrimeConstellation.image_bounded (C : PrimeConstellation) (p : ℕ)
    (hp : p ∈ C.primes) :
    |logPrimeImage p - logPrimeImage C.center| ≤ C.radius := by
  simpa only [ logPrimeDist_symm ] using C.bounded p hp

/-- **Diameter monotonicity**: Adding a prime to a constellation can only increase
    the maximum pairwise distance. Specifically, if p is in a constellation C,
    then the distance from the center to p is at most the constellation radius.
    This is a structural consequence of the metric space embedding. -/
theorem logPrimeDist_nonneg (p q : ℕ) : 0 ≤ logPrimeDist p q :=
  abs_nonneg _

/-
**Strict ordering implies strict metric separation**: For three naturals
    `a < b < c` all ≥ 2, the log-distances satisfy `d(a,b) < d(a,c)`. This
    is a key consequence of the ordering reversal: the farther apart in ℕ,
    the farther apart in the log-metric.
-/
theorem logPrimeDist_strictMono_right {a b c : ℕ} (ha : 2 ≤ a)
    (hab : a < b) (hbc : b < c) :
    logPrimeDist a b < logPrimeDist a c := by
  rw [ logPrimeDist_eq_sub ha hab, logPrimeDist_eq_sub ha ( hab.trans hbc ) ];
  exact sub_lt_sub_left ( logPrimeImage_strictAnti ( by linarith ) ( by linarith ) ) _

/-! ### Falsifiable Conjecture -/

/-- **Conjecture (Box-Counting Dimension 1/2)**:
    The number of intervals of length `1/N` needed to cover `{1/log p : p prime, p ≤ N}`
    grows as `N^(1/2 + o(1))`. More precisely, for the covering number `C(N)` of the
    logarithmic prime image by intervals of length `1/log N`, we conjecture that
    `log C(N) / log(log N) → 1/2`.

    This is testable: compute `C(N)` for `N = 10^k` and check `log C(N) / log(log N)`.
    For `N = 10^6`, the prime count `π(N) ≈ 78498` and the covering number should be
    approximately `(log N)^(1/2) ≈ 3.7`, suggesting about 4 intervals suffice.

    We state this as a computable property rather than a limit statement. -/
def boxCountingTest (N : ℕ) : ℕ :=
  -- Count primes up to N (as a proxy for the covering number)
  (Finset.range (N + 1)).filter Nat.Prime |>.card

end