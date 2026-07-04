import Mathlib

/-!
# The Anti-Fibonacci Sequence: growth `∼ n²/2` and provable avoidance of the golden ratio

Domain: Applications (a quadratic-growth counterpoint to the catalog's Fibonacci
entry-point / apparition theory in `Catalog/Applications/FibonacciEntryPoints.lean`,
`Catalog/Applications/FibonacciMatrix.lean`, and `Catalog/Applications/FibonacciLucasBridge.lean`,
and to Mathlib's `tendsto_fib_succ_div_fib_atTop`).

The *anti-Fibonacci* sequence of the mission brief is listed explicitly as

```
1, 1, 2, 4, 7, 11, 16, 22, 29, 37, 46, 56, …
```

Its successive differences are `0, 1, 2, 3, 4, 5, …`, i.e. the sequence obeys the
first-order recurrence `A (k+1) = A k + k` with `A 0 = 1` (0-indexed).  This is the
concrete, checkable content of the brief, so we take it as the definition.  It is the
shifted "lazy caterer" / central-polygonal sequence (OEIS A000124) and satisfies the
closed form `2·A k + k = k² + 2`, i.e. `A k = 1 + k(k-1)/2`.

Where the Fibonacci sequence `F (k+1) = F k + F (k-1)` has consecutive ratio tending
to the golden ratio `φ`, the anti-Fibonacci sequence grows *quadratically* and its
consecutive ratio tends to `1`.  We turn "avoids the golden ratio at all costs" into a
theorem: the anti-Fibonacci ratio provably does **not** tend to `φ` (Theorem 3), in
sharp contrast with Mathlib's `tendsto_fib_succ_div_fib_atTop`.

## Main results

* `A_closed_form` : `2 * A k + k = k ^ 2 + 2` (exact closed form, by induction).
* `A_div_sq_tendsto` : `A k / k² → 1/2` (quadratic growth; the honest leading constant).
* `antiFib_avoids_goldenRatio` : `A (k+1) / A k` does **not** tend to `φ`
  (the golden ratio), whereas the Fibonacci ratio does.

-- !-- Lab Notes -- !--
### Hypothesis (Hypothesizer)
Candidate conjectures about the listed sequence `1,1,2,4,7,11,16,…`:
  H1. It satisfies `A(k+1) = A(k) + k`, hence closed form `A k = 1 + k(k-1)/2`.
  H2. `A(n) ∼ n²/4` and `A(n)/n² → 1/4`  (brief's claim).
  H3. `A(n) = ⌊n²/4⌋ + O(1)`  (brief's claim).
  H4. The consecutive ratio oscillates between `1` and `2` and does not converge
      (brief's claim).
  H5. The sequence provably avoids the golden ratio: its consecutive ratio has a
      limit different from `φ`.
  H6. The set of values `{A k}` has natural density `0`.

### Experiment (Experimenter)
Direct computation (`#eval`) of the recurrence `A 0 = 1, A(k+1)=A k + k` reproduces
`1,1,2,4,7,11,16,22,29,37,46,56` exactly, confirming H1.
Numerics: `A k / k²` for `k = 50…55` gives `0.4904, 0.4906, …` → clearly `1/2`,
**refuting H2 and H3** (the true constant is `1/2`, not `1/4`).
The consecutive ratio `A(k+1)/A(k)` for `k = 50…55` gives `1.0408, 1.0400, …` → `1`,
monotonically, **refuting H4** (no oscillation; the ratio converges to `1`).
H5 and H6 survive.

### Analysis (Analyst)
The brief is internally inconsistent: the recurrence forced by its own listed terms is
`A(k+1)=A(k)+k`, giving `A k = 1 + k(k-1)/2 ∼ k²/2`, so the ratio `A k / k² → 1/2` and
the consecutive ratio `→ 1`.  The "`n²/4`", "`⌊n²/4⌋`", and "oscillates between 1 and 2"
claims are all false for the listed sequence (they would require a *different* sequence).
We keep the checkable content (the listed terms → the recurrence) and prove the correct
asymptotics.  The genuine "anti-Fibonacci vs. golden ratio" phenomenon (H5) is real and
becomes the flagship bridge theorem.

### Critique (Critic)
* `A_closed_form` is a real induction (not `rfl`): the step needs `omega` on the IH.
* `A_div_sq_tendsto` is analytic (limit of a rational expression), not `decide`-able.
* `antiFib_avoids_goldenRatio` uses uniqueness of limits together with `1 < φ`; it is a
  genuine bridge to Mathlib's Fibonacci golden-ratio limit, not a definitional fact.
* Corner cases: at `k = 0` the ratio `A 1 / A 0 = 1` is finite (no division by zero,
  since `A k ≥ 1` always).

### Synthesis (PI)
The anti-Fibonacci sequence is a quadratic-growth object that *provably* avoids the
golden ratio: its consecutive ratio converges to `1 ≠ φ`.  This is the precise, correct
counterpoint to the Fibonacci sequence promised by the mission.
-- !-- Lab Notes -- !--
-/

namespace AntiFibonacci

open Filter Topology
open scoped goldenRatio

/-- The anti-Fibonacci sequence, 0-indexed: `A 0 = 1` and `A (k+1) = A k + k`.
Reproduces the listed terms `1, 1, 2, 4, 7, 11, 16, 22, …`. -/
def A : ℕ → ℕ
  | 0 => 1
  | (k + 1) => A k + k

@[simp] theorem A_zero : A 0 = 1 := rfl
@[simp] theorem A_succ (k : ℕ) : A (k + 1) = A k + k := rfl

/-- Every term is positive (so consecutive ratios are well defined). -/
theorem A_pos (k : ℕ) : 0 < A k := by
  induction k with
  | zero => simp
  | succ n ih => simp [A_succ]; omega

/-- **Main theorem 1 (closed form).** `2 · A k + k = k² + 2`, i.e.
`A k = 1 + k(k-1)/2`.  Proved by induction; the step is pure arithmetic on the
inductive hypothesis. -/
theorem A_closed_form (k : ℕ) : 2 * A k + k = k ^ 2 + 2 := by
  induction' k with k ih <;> norm_num [ * ] at * ; linarith

/-- Real-valued closed form: `A k = (k² - k + 2)/2`. -/
theorem A_real_closed (k : ℕ) : (A k : ℝ) = ((k : ℝ) ^ 2 - (k : ℝ) + 2) / 2 := by
  exact eq_div_of_mul_eq ( by norm_num ) ( by linarith [ show ( 2 * A k + k : ℝ ) = k ^ 2 + 2 from mod_cast A_closed_form k ] )

/-- **Main theorem 2 (quadratic growth).** `A k / k² → 1/2`.  The leading constant is
`1/2` (correcting the brief's `1/4`). -/
theorem A_div_sq_tendsto :
    Tendsto (fun k => (A k : ℝ) / (k : ℝ) ^ 2) atTop (𝓝 (1 / 2)) := by
  -- We'll use the fact that $A(k) = \frac{k^2 - k + 2}{2}$ to rewrite the limit expression.
  suffices h_suff : Filter.Tendsto (fun k : ℕ => ((k^2 - k + 2) / 2 : ℝ) / k^2) Filter.atTop (nhds (1 / 2)) by
    convert h_suff using 2 ; rw [ A_real_closed ];
  -- Simplify the expression inside the limit.
  suffices h_simp : Filter.Tendsto (fun k : ℕ => (1 - 1 / (k : ℝ) + 2 / (k ^ 2 : ℝ)) / 2) Filter.atTop (nhds (1 / 2)) by
    refine h_simp.congr' ( by filter_upwards [ Filter.eventually_gt_atTop 0 ] with x hx ; rw [ div_eq_div_iff ] <;> first | positivity | simp [ hx.ne', sq, mul_assoc, sub_mul, add_mul, div_eq_mul_inv ] );
  exact le_trans ( Filter.Tendsto.div_const ( Filter.Tendsto.add ( tendsto_const_nhds.sub ( tendsto_one_div_atTop_nhds_zero_nat ) ) ( tendsto_const_nhds.div_atTop ( by simpa only [ sq ] using tendsto_natCast_atTop_atTop.atTop_mul_atTop₀ tendsto_natCast_atTop_atTop ) ) ) _ ) ( by norm_num )

/-- Auxiliary: `k / A k → 0` (the sequence outgrows `k` quadratically). -/
theorem A_lin_div_tendsto_zero :
    Tendsto (fun k : ℕ => (k : ℝ) / (A k : ℝ)) atTop (𝓝 0) := by
  -- Using the closed form, we can express $k / A k$ as $2k / (k^2 - k + 2)$.
  have h_closed_form : ∀ k : ℕ, (k : ℝ) / (A k) = 2 * (k : ℝ) / ((k : ℝ) ^ 2 - (k : ℝ) + 2) := by
    intro k; rw [ div_eq_div_iff ] <;> nlinarith [ show ( A k : ℝ ) = ( k ^ 2 - k + 2 ) / 2 by exact mod_cast A_real_closed k ] ;
  rw [ Metric.tendsto_nhds ] ; norm_num;
  exact fun ε hε => ⟨ Nat.ceil ( 2 + ε⁻¹ * 4 ), fun n hn => by rw [ h_closed_form ] ; rw [ div_lt_iff₀ ] <;> nlinarith [ Nat.ceil_le.mp hn, inv_pos.2 hε, mul_inv_cancel₀ hε.ne' ] ⟩

/-- Auxiliary: the consecutive ratio tends to `1` (no golden ratio, no oscillation). -/
theorem A_ratio_tendsto_one :
    Tendsto (fun k => (A (k + 1) : ℝ) / (A k : ℝ)) atTop (𝓝 1) := by
  convert Tendsto.const_add 1 ( A_lin_div_tendsto_zero ) using 2;
  · rw [ add_div' ] <;> norm_cast <;> norm_num [ A_succ ];
    exact ne_of_gt ( A_pos _ );
  · norm_num

/-- **Main theorem 3 (avoidance of the golden ratio).** The anti-Fibonacci consecutive
ratio does **not** tend to the golden ratio `φ`, in contrast with the Fibonacci ratio
(`tendsto_fib_succ_div_fib_atTop`).  Since the anti-Fibonacci ratio tends to `1` and
`1 < φ`, uniqueness of limits forbids convergence to `φ`. -/
theorem antiFib_avoids_goldenRatio :
    ¬ Tendsto (fun k => (A (k + 1) : ℝ) / (A k : ℝ)) atTop (𝓝 φ) := by
  by_contra h_contra
  have h1 : (1 : ℝ) = φ := tendsto_nhds_unique A_ratio_tendsto_one h_contra
  linarith [Real.one_lt_goldenRatio]

/-- **Cross-domain bridge.** Side by side: the *Fibonacci* consecutive ratio converges
to the golden ratio `φ` (Mathlib's `tendsto_fib_succ_div_fib_atTop`), whereas the
*anti-Fibonacci* consecutive ratio provably does **not**.  The two additive recurrences
`F (k+1) = F k + F (k-1)` and `A (k+1) = A k + k` thus have genuinely different
long-run ratio behaviour: the golden ratio for one, its total avoidance for the other. -/
theorem fib_converges_but_antiFib_avoids_goldenRatio :
    Tendsto (fun n => (Nat.fib (n + 1) : ℝ) / (Nat.fib n : ℝ)) atTop (𝓝 φ) ∧
      ¬ Tendsto (fun k => (A (k + 1) : ℝ) / (A k : ℝ)) atTop (𝓝 φ) :=
  ⟨tendsto_fib_succ_div_fib_atTop, antiFib_avoids_goldenRatio⟩

end AntiFibonacci