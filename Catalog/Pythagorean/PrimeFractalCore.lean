import Mathlib

/-!
# Prime Fractal Number Theory: Core Definitions and Metric Properties

This file establishes the mathematical foundations of the **prime fractal** — a metric
space obtained by embedding the natural numbers via the map `n ↦ 1/log(n)` and measuring
distances as `|1/log(p) − 1/log(q)|`.

## Main Definitions

* `primeFractalEmbed` — the embedding `n ↦ 1 / log(n)` for `n ≥ 2`, zero otherwise
* `primeFractalDist` — the induced distance `|1/log(p) − 1/log(q)|`
* `ProbDist` — a probability distribution on a finite type
* `ProbDist.entropy` — Shannon entropy, connecting information theory to prime distributions

## Main Results

* `primeFractalDist_self` — d(p, p) = 0
* `primeFractalDist_symm` — d(p, q) = d(q, p)
* `primeFractalDist_triangle` — triangle inequality
* `primeFractalDist_nonneg` — d(p, q) ≥ 0
* `primeFractalEmbed_strictAntiOn` — the embedding is strictly decreasing on [2, ∞)
* `primeFractalEmbed_injOn` — the embedding is injective on [2, ∞)
* `primeFractalEmbed_pos` — the embedding is positive for n ≥ 2
* `neg_mul_log_nonneg` — -x log x ≥ 0 for x ∈ [0,1]
* `ProbDist.entropy_nonneg` — entropy of any probability distribution is non-negative
-/

open Real Finset

noncomputable section

/-- The prime fractal embedding: maps n to 1/log(n) for n ≥ 2, and 0 otherwise.
This embedding maps larger primes to smaller positive values, creating a
convergent sequence in (0, 1/log 2]. -/
def primeFractalEmbed (n : ℕ) : ℝ :=
  if (n : ℝ) ≥ 2 then 1 / Real.log n else 0

/-- The prime fractal distance between two natural numbers. -/
def primeFractalDist (p q : ℕ) : ℝ :=
  |primeFractalEmbed p - primeFractalEmbed q|

/-! ## Basic Metric Properties -/

theorem primeFractalDist_self (p : ℕ) : primeFractalDist p p = 0 := by
  simp [primeFractalDist]

theorem primeFractalDist_symm (p q : ℕ) : primeFractalDist p q = primeFractalDist q p := by
  simp [primeFractalDist, abs_sub_comm]

theorem primeFractalDist_nonneg (p q : ℕ) : 0 ≤ primeFractalDist p q :=
  abs_nonneg _

theorem primeFractalDist_triangle (p q r : ℕ) :
    primeFractalDist p r ≤ primeFractalDist p q + primeFractalDist q r := by
  exact abs_sub_le (primeFractalEmbed p) (primeFractalEmbed q) (primeFractalEmbed r)

/-! ## Embedding Properties -/

theorem log_pos_of_cast_ge_two {n : ℕ} (hn : (n : ℝ) ≥ 2) : Real.log (n : ℝ) > 0 :=
  Real.log_pos (by linarith)

theorem primeFractalEmbed_eq {n : ℕ} (hn : n ≥ 2) :
    primeFractalEmbed n = 1 / Real.log n := by
  simp only [primeFractalEmbed, show (n : ℝ) ≥ 2 from by exact_mod_cast hn, ↓reduceIte]

theorem primeFractalEmbed_pos {n : ℕ} (hn : n ≥ 2) : primeFractalEmbed n > 0 := by
  rw [primeFractalEmbed_eq hn]
  exact div_pos one_pos (log_pos_of_cast_ge_two (by exact_mod_cast hn))

/-
The embedding is strictly decreasing: if 2 ≤ a < b, then
1/log(b) < 1/log(a), so the embedding reverses the natural order.
-/
theorem primeFractalEmbed_strictAntiOn :
    StrictAntiOn (fun n : ℕ => primeFractalEmbed n) {n | n ≥ 2} := by
  intros a ha b hb hab; have h_log : Real.log (a : ℝ) < Real.log (b : ℝ) := by
    exact Real.log_lt_log ( Nat.cast_pos.mpr ( by linarith [ ha.out ] ) ) ( Nat.cast_lt.mpr hab );
  convert one_div_lt_one_div_of_lt ( Real.log_pos <| Nat.one_lt_cast.mpr ha ) h_log using 1 <;> norm_num [ primeFractalEmbed_eq, ha.out, hb.out ]

/-
Injectivity of the embedding on [2, ∞).
-/
theorem primeFractalEmbed_injOn :
    Set.InjOn (fun n : ℕ => primeFractalEmbed n) {n | n ≥ 2} := by
  exact fun a ha b hb hab => by have := primeFractalEmbed_strictAntiOn.injOn ha hb hab; aesop;

/-
If p ≠ q and both ≥ 2, the distance is strictly positive (separation axiom).
-/
theorem primeFractalDist_pos {p q : ℕ} (hp : p ≥ 2) (hq : q ≥ 2) (hne : p ≠ q) :
    primeFractalDist p q > 0 := by
  exact abs_pos.mpr ( sub_ne_zero.mpr <| primeFractalEmbed_injOn.ne hp hq hne )

/-! ## Distance Closed-Form for Ordered Pairs -/

/-
For 2 ≤ p < q, the distance equals 1/log(p) - 1/log(q).
-/
theorem primeFractalDist_ordered {p q : ℕ} (hp : p ≥ 2) (hpq : p < q) :
    primeFractalDist p q = 1 / Real.log p - 1 / Real.log q := by
  unfold primeFractalDist primeFractalEmbed;
  rw [ if_pos ( mod_cast hp ), if_pos ( mod_cast hpq.le.trans_lt' hp ), abs_of_nonneg ( sub_nonneg_of_le <| one_div_le_one_div_of_le ( Real.log_pos <| mod_cast hp ) <| Real.log_le_log ( by positivity ) <| mod_cast hpq.le ) ]

/-! ## Shannon Entropy and Information Theory Bridge -/

/-- A valid probability distribution: all weights non-negative and summing to 1. -/
structure ProbDist (n : ℕ) where
  weights : Fin n → ℝ
  nonneg : ∀ i, 0 ≤ weights i
  sum_one : ∑ i, weights i = 1

/-- Shannon entropy of a probability distribution. -/
def ProbDist.entropy {n : ℕ} (d : ProbDist n) : ℝ :=
  -∑ i, d.weights i * Real.log (d.weights i)

/-
Each weight in a probability distribution is at most 1.
-/
theorem ProbDist.weight_le_one {n : ℕ} (d : ProbDist n) (i : Fin n) :
    d.weights i ≤ 1 := by
  exact le_trans ( Finset.single_le_sum ( fun i _ => d.nonneg i ) ( Finset.mem_univ i ) ) d.sum_one.le

/-
Key lemma: -x * log(x) ≥ 0 for x ∈ [0, 1].
-/
theorem neg_mul_log_nonneg {x : ℝ} (hx0 : 0 ≤ x) (hx1 : x ≤ 1) :
    0 ≤ -(x * Real.log x) := by
  exact neg_nonneg_of_nonpos ( mul_nonpos_of_nonneg_of_nonpos hx0 ( Real.log_nonpos hx0 hx1 ) )

/-
**Shannon Entropy Non-Negativity**: The entropy of any probability distribution
is non-negative. This is the information-theoretic bridge to prime fractal theory:
the information content of any prime distribution scheme is always non-negative.
-/
theorem ProbDist.entropy_nonneg {n : ℕ} (d : ProbDist n) : 0 ≤ d.entropy := by
  exact neg_nonneg_of_nonpos ( Finset.sum_nonpos fun i _ => mul_nonpos_of_nonneg_of_nonpos ( d.nonneg i ) ( Real.log_nonpos ( d.nonneg i ) ( d.weight_le_one i ) ) )

end