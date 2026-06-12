import Mathlib
import Computation.CollatzParityContraction

/-!
# Collatz Sharp Contraction Threshold via Real Logarithms

This file extends the density-contraction foundations of
`Catalog/Computation/CollatzParityContraction.lean` from the *naive* sufficient
condition (odd-step density `< 1/2`, i.e. `2j < k`) to the **optimal** contraction
threshold (density `< log 2 / log 3 ≈ 0.6309`).

The Collatz "shortcut" dynamics multiply an orbit value by `3` once per odd step and
divide by `2` once per even step. Over a segment with `j` factors of `3` and `m`
factors of `2`, the segment contracts exactly when `3 ^ j < 2 ^ m`. The classical
combinatorial argument (`CollatzParity.pow3_lt_pow2_of_two_mul_lt`) only resolves the
case `2j < m` (using `3 < 4 = 2²`). Here we characterize the inequality `3 ^ j < 2 ^ m`
*exactly* by a real-logarithmic linear inequality, which yields the sharp density
threshold and strictly dominates the naive bound.

## Main Results

1. `pow3_lt_pow2_iff_log` — the exact logarithmic characterization:
   `(3:ℝ)^j < 2^m ↔ j · log 3 < m · log 2`.
2. `pow3_lt_pow2_of_density` — sharp contraction criterion on ℕ: if the odd-step
   density satisfies `j · (log 3 / log 2) < m`, then `3 ^ j < 2 ^ m`.
3. `log_of_two_mul_lt` — the sharp criterion is implied by the naive one (`2j < m`),
   so it is a genuine generalization.
4. `sharp_threshold_strictly_stronger` — an explicit witness `(j, m) = (1, 2)` that
   the sharp criterion fires where the naive one does not.
5. `log3_div_log2_mem_Ioo` — the threshold constant `log 3 / log 2` lies strictly
   between `1` and `2`, locating the optimal density between the trivial bounds.

These build on `CollatzParity.T`, `CollatzParity.pow3_lt_pow2_of_two_mul_lt`,
and the parity exclusion bound `CollatzParity.oddCount_le_half_ceil`.
-/

namespace CollatzSharp

open Real

/-! ## Section 1: Exact Logarithmic Characterization -/

-- !-- Lab Notebook: pow3_lt_pow2_iff_log -- !--
-- !-- Hypothesis: 3^j < 2^m over ℝ should be exactly equivalent to the linear
--     log inequality j·log3 < m·log2, since log is a strict order-iso on (0,∞). -- !--
-- !-- Result: Proved by rewriting j·log3 = log(3^j), m·log2 = log(2^m) via Real.log_pow
--     and applying Real.log_lt_log_iff. -- !--
-- !-- Insight: This turns a multiplicative power comparison into an additive density
--     comparison — the conceptual move that makes the *sharp* threshold visible. -- !--
-- !-- Failure analysis: log_lt_log_iff needs positivity of BOTH arguments (not one);
--     supplying both via positivity fixed the initial single-hypothesis attempt. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Rewrite both sides as logs of powers (Real.log_pow), then strict monotonicity
--     of log on positives (Real.log_lt_log_iff) gives the equivalence. -- !--
/-- **Exact logarithmic characterization** of the power comparison underlying Collatz
    contraction: `(3:ℝ)^j < 2^m` holds iff the linear inequality
    `j · log 3 < m · log 2` holds. -/
theorem pow3_lt_pow2_iff_log (j m : ℕ) :
    (3 : ℝ) ^ j < (2 : ℝ) ^ m ↔ (j : ℝ) * Real.log 3 < (m : ℝ) * Real.log 2 := by
  rw [show (j : ℝ) * Real.log 3 = Real.log ((3 : ℝ) ^ j) from (Real.log_pow 3 j).symm,
      show (m : ℝ) * Real.log 2 = Real.log ((2 : ℝ) ^ m) from (Real.log_pow 2 m).symm]
  exact (Real.log_lt_log_iff (by positivity) (by positivity)).symm

/-- The natural-number power comparison `3^j < 2^m` is equivalent to the real
    logarithmic density inequality. -/
theorem nat_pow3_lt_pow2_iff_log (j m : ℕ) :
    3 ^ j < 2 ^ m ↔ (j : ℝ) * Real.log 3 < (m : ℝ) * Real.log 2 := by
  rw [← pow3_lt_pow2_iff_log]
  constructor
  · intro h; exact_mod_cast h
  · intro h; exact_mod_cast h

/-! ## Section 2: Sharp Contraction Criterion -/

-- !-- Lab Notebook: pow3_lt_pow2_of_density -- !--
-- !-- Hypothesis: The OPTIMAL density bound j/m < log2/log3 should suffice for
--     contraction 3^j < 2^m, beating the naive bound j/m < 1/2. -- !--
-- !-- Result: Proved by clearing the denominator log2 > 0 from
--     j·(log3/log2) < m to recover j·log3 < m·log2, then nat_pow3_lt_pow2_iff_log. -- !--
-- !-- Insight: log 3 / log 2 = log_2 3 ≈ 1.585; the density threshold is its
--     reciprocal ≈ 0.6309 — strictly larger than 1/2, so strictly more orbits qualify. -- !--
-- !-- Failure analysis: div_mul_cancel₀ requires the exact `a/b*b` shape; needed
--     mul_assoc first so the (log3/log2)*log2 cancellation pattern appeared. -- !--
-- !-- End Lab Notebook -- !--

-- !-- Multiply the density hypothesis by log 2 > 0 and cancel to get j·log3 < m·log2,
--     then apply the logarithmic characterization. -- !--
/-- **Sharp contraction criterion.** If the odd-step "density count" satisfies
    `j · (log 3 / log 2) < m` — i.e. `j` factors of `3` are dominated by `m`
    factors of `2` at the optimal threshold `log 2 / log 3` — then `3 ^ j < 2 ^ m`.

    This strictly generalizes `CollatzParity.pow3_lt_pow2_of_two_mul_lt`, whose
    threshold is the suboptimal `1/2`. -/
theorem pow3_lt_pow2_of_density {j m : ℕ}
    (h : (j : ℝ) * (Real.log 3 / Real.log 2) < (m : ℝ)) :
    3 ^ j < 2 ^ m := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have h' : (j : ℝ) * Real.log 3 < (m : ℝ) * Real.log 2 := by
    have hh := mul_lt_mul_of_pos_right h hlog2
    rwa [mul_assoc, div_mul_cancel₀ _ (ne_of_gt hlog2)] at hh
  exact (nat_pow3_lt_pow2_iff_log j m).mpr h'

/-! ## Section 3: The Sharp Criterion Dominates the Naive One -/

-- !-- Lab Notebook: log_of_two_mul_lt / sharp_threshold_strictly_stronger -- !--
-- !-- Hypothesis: Every segment captured by the naive bound 2j < m is captured by
--     the sharp log bound, but not conversely. -- !--
-- !-- Result: log_of_two_mul_lt proves the forward containment via log 3 < 2 log 2
--     (= log 4); the witness (1,2) shows strictness: 1·log3 < 2·log2 yet ¬(2·1 < 2). -- !--
-- !-- Insight: The naive bound is the rational underestimate 1/2 < log2/log3 of the
--     true threshold; the gap (1,2) realizes 3 < 4 — the single inequality 3 < 2² that
--     the naive proof actually uses, exposed as the first newly-captured case. -- !--
-- !-- Failure analysis: nlinarith needed the scaled product j·log3 ≤ j·(2 log2) AND
--     the strict integer slack 2j+1 ≤ m (not just 2j ≤ m) to close strictness at j=0. -- !--
-- !-- End Lab Notebook -- !--

-- !-- From log 3 < 2 log 2 and 2j+1 ≤ m, scale by j ≥ 0 and add log2 slack via nlinarith. -- !--
/-- The naive contraction condition `2j < m` implies the sharp logarithmic condition,
    so the sharp criterion captures every segment the naive one does. -/
theorem log_of_two_mul_lt {j m : ℕ} (h : 2 * j < m) :
    (j : ℝ) * Real.log 3 < (m : ℝ) * Real.log 2 := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hlog34 : Real.log 3 < 2 * Real.log 2 := by
    have h3 : Real.log 3 < Real.log 4 := Real.log_lt_log (by norm_num) (by norm_num)
    have h4 : Real.log 4 = 2 * Real.log 2 := by
      rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; push_cast; ring
    linarith
  have hjm : (2 * (j : ℝ)) + 1 ≤ (m : ℝ) := by exact_mod_cast Nat.succ_le_of_lt h
  have hjnn : (0 : ℝ) ≤ (j : ℝ) := Nat.cast_nonneg j
  nlinarith [mul_le_mul_of_nonneg_left (le_of_lt hlog34) hjnn, hlog2, hjm]

/-- **Strict separation.** The sharp criterion fires at `(j, m) = (1, 2)` —
    `1 · log 3 < 2 · log 2` (equivalently `3 < 4`) — even though the naive bound
    `2 · 1 < 2` fails. Hence the sharp threshold is *strictly* stronger. -/
theorem sharp_threshold_strictly_stronger :
    ((1 : ℕ) : ℝ) * Real.log 3 < ((2 : ℕ) : ℝ) * Real.log 2 ∧ ¬ (2 * 1 < 2) := by
  refine ⟨?_, by norm_num⟩
  have : (3 : ℝ) ^ (1 : ℕ) < (2 : ℝ) ^ (2 : ℕ) := by norm_num
  exact (pow3_lt_pow2_iff_log 1 2).mp this

/-! ## Section 4: Locating the Threshold Constant -/

-- !-- Lab Notebook: log3_div_log2_mem_Ioo -- !--
-- !-- Hypothesis: The optimal contraction exponent log_2 3 = log3/log2 lies strictly
--     in (1, 2): above 1 (since 3 > 2) and below 2 (since 3 < 4). -- !--
-- !-- Result: Proved both bounds from strict monotonicity of log: 2 < 3 < 4 = 2². -- !--
-- !-- Insight: This pins the true density threshold (its reciprocal) into
--     (1/2, 1) ⊇ {1/2}; the naive 1/2 is the crude lower endpoint. -- !--
-- !-- Failure analysis: Needed log 4 = 2 log 2 expansion (via log_pow) to compare
--     against the upper bound 2; direct numeric bounds on log are unavailable. -- !--
-- !-- End Lab Notebook -- !--

-- !-- 1 < log3/log2 from 2 < 3; log3/log2 < 2 from 3 < 4 = 2² and log4 = 2 log2. -- !--
/-- The optimal Collatz contraction exponent `log 3 / log 2 = log₂ 3` lies strictly
    in the open interval `(1, 2)`. Its reciprocal is the sharp odd-step density
    threshold `≈ 0.6309`, strictly above the naive `1/2`. -/
theorem log3_div_log2_mem_Ioo : Real.log 3 / Real.log 2 ∈ Set.Ioo (1 : ℝ) 2 := by
  have hlog2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  constructor
  · rw [lt_div_iff₀ hlog2, one_mul]
    exact Real.log_lt_log (by norm_num) (by norm_num)
  · rw [div_lt_iff₀ hlog2]
    have h3 : Real.log 3 < Real.log 4 := Real.log_lt_log (by norm_num) (by norm_num)
    have h4 : Real.log 4 = 2 * Real.log 2 := by
      rw [show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]; push_cast; ring
    linarith

/-! ## Section 5: Generalization Conjecture (boundary of this cycle)

The natural next step is to turn the *segment* contraction `3^j < 2^m` into an
*orbit* contraction `T^[k] n < n` via the affine orbit bound. The obstruction is
the additive `+1` accumulated at each odd step, which contributes a geometric error
term. The following conjecture states the expected form; it is left as `sorry` (it is
a conjecture for the next cycle, not a claimed result). -/

-- !-- CONJECTURE (next cycle): when the realized odd-step count of an orbit segment
--     meets the sharp density bound, the segment contracts past a threshold N₀.
--     The `sorry` below marks this as OPEN — it is a conjecture, not a result. -- !--
/-- **Conjecture (sharp orbit contraction).** Let `j = oddCount n k` be the number of
    odd steps in the length-`k` Collatz segment from `n`. If the realized odd-step
    density meets the sharp threshold, `(j : ℝ) * (Real.log 3 / Real.log 2) < (k - j)`,
    then beyond some threshold `N₀` the segment strictly contracts: `T^[k] n < n`.
    The obstruction is the geometric `+1` error from odd steps; deferred to the next
    research cycle. Marked `sorry` to record it as an open conjecture, never a proof. -/
theorem sharp_orbit_contraction_conjecture :
    ∀ k : ℕ,
      ∃ N₀ : ℕ, ∀ n : ℕ, N₀ ≤ n →
        let j := CollatzParity.oddCount n k
        ((j : ℝ) * (Real.log 3 / Real.log 2) < ((k : ℝ) - j)) →
        (CollatzParity.T^[k]) n < n := by
  sorry

end CollatzSharp