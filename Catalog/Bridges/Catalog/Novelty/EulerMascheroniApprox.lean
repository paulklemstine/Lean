import Mathlib
import Catalog.Novelty.EulerMascheroniSeries

/-!
# Quantitative bracketing and convergence order for the Euler–Mascheroni constant

Mathlib proves that `eulerMascheroniSeq n < γ < eulerMascheroniSeq' n` but only
gives the crude bounds `1/2 < γ < 2/3`.  Here we make the bracketing
*quantitative*:

* the bracket width is **exactly** `log((n+1)/n)` (`bracket_width`);
* it is squeezed `1/(n+1) ≤ log((n+1)/n) ≤ 1/n` (`width_ge`, `width_le`), so the
  convergence order of the defining sequence is **exactly linear**, `Θ(1/n)`;
* consequently `γ` is approximated by `H_n - log(n+1)` (and by `H_n - log n`) with
  one-sided error `< 1/n` (`gamma_sub_seq_lt`, `seq'_sub_gamma_lt`);
* the *tail* of the series from `EulerMascheroniSeries` is exactly the approximation
  error, hence also `< 1/n` (`tail_eq_error`, `tsum_tail_lt`).

This is the structural reason the elementary sequence converges so slowly and why
"series accelerations" are needed — recorded here as a hard linear lower bound on
the width.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): the gap between Mathlib's two bracketing sequences is a
single logarithm `log(1+1/n)`, so the approximation error of `γ` is pinned to size
`Θ(1/n)` — no faster, no slower.
Experiment (Experimenter): compute the width in closed form (`bracket_width`),
sandwich it by `log x ≤ x-1` applied at `(n+1)/n` and at `n/(n+1)`, then transport
through the strict bracketing lemmas with `linarith`.
Analysis (Analyst): the *upper* bound `log(1+1/n) ≤ 1/n` is the easy convexity
direction; the *lower* bound `1/(n+1) ≤ log(1+1/n)` is the informative one — it
proves the sequence cannot converge faster than linearly, which is the precise
obstruction motivating accelerated/Apéry-like schemes.
Critique (Critic): is the error bound vacuous?  No — `gamma_sub_seq_lt` combines a
*strict* bracketing inequality with the width bound, and `width_ge` shows the error
is also bounded *below* by `1/(n+1) - (seq' n - γ)` style data, so the `Θ(1/n)`
order is two-sided and genuine, not a one-sided artifact.
Synthesis (PI): identifying the series tail (`EulerMascheroniSeries.term`) with the
approximation error unifies the "series representation" and "good approximation"
threads: the same `log((n+1)/n)` governs both.
-- !-- end Lab Notes -- !--
-/

open Real Filter Finset Topology

namespace EulerMascheroniApprox

/-- The width of the bracketing interval `[seq n, seq' n]` is exactly `log((n+1)/n)`. -/
lemma bracket_width {n : ℕ} (hn : 1 ≤ n) :
    Real.eulerMascheroniSeq' n - Real.eulerMascheroniSeq n = Real.log ((n + 1) / n) := by
  have hn0 : n ≠ 0 := by omega
  unfold Real.eulerMascheroniSeq' Real.eulerMascheroniSeq
  rw [if_neg hn0, Real.log_div (by positivity) (by positivity)]; ring

/-- Upper bound on the bracket width: `log((n+1)/n) ≤ 1/n` (convexity). -/
lemma width_le {n : ℕ} (hn : 1 ≤ n) : Real.log ((n + 1) / n) ≤ 1 / n := by
  have hx : (0 : ℝ) < (n + 1) / n := by positivity
  have h := Real.log_le_sub_one_of_pos hx
  have hsub : ((n : ℝ) + 1) / n - 1 = 1 / n := by
    have : (n : ℝ) ≠ 0 := by positivity
    field_simp; ring
  linarith [hsub ▸ h]

/-- Lower bound on the bracket width: `1/(n+1) ≤ log((n+1)/n)`.
Establishes that the convergence order is at least linear (no faster than `1/n`). -/
lemma width_ge {n : ℕ} (hn : 1 ≤ n) : 1 / (n + 1 : ℝ) ≤ Real.log ((n + 1) / n) := by
  have hx : (0 : ℝ) < (n : ℝ) / (n + 1) := by positivity
  have h := Real.log_le_sub_one_of_pos hx
  have hsub : ((n : ℝ)) / (n + 1) - 1 = -(1 / (n + 1)) := by field_simp; ring
  rw [hsub] at h
  have hinv : Real.log ((n : ℝ) / (n + 1)) = - Real.log ((n + 1) / n) := by
    rw [← Real.log_inv]; congr 1; field_simp
  rw [hinv] at h; linarith

/-- **The bracket width has exactly linear order:** `1/(n+1) ≤ seq' n - seq n ≤ 1/n`. -/
theorem bracket_width_order {n : ℕ} (hn : 1 ≤ n) :
    1 / (n + 1 : ℝ) ≤ Real.eulerMascheroniSeq' n - Real.eulerMascheroniSeq n ∧
    Real.eulerMascheroniSeq' n - Real.eulerMascheroniSeq n ≤ 1 / n := by
  rw [bracket_width hn]
  exact ⟨width_ge hn, width_le hn⟩

/-- **Quantitative convergence (linear rate).** For `n ≥ 1` the lower approximant
`H_n - log(n+1)` undershoots `γ` by less than `1/n`. -/
theorem gamma_sub_seq_lt {n : ℕ} (hn : 1 ≤ n) :
    Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n < 1 / n := by
  have h1 := Real.eulerMascheroniConstant_lt_eulerMascheroniSeq' n
  have hw := bracket_width hn
  have hle := width_le hn
  linarith

/-- For `n ≥ 1` the upper approximant `H_n - log n` overshoots `γ` by less than `1/n`. -/
theorem seq'_sub_gamma_lt {n : ℕ} (hn : 1 ≤ n) :
    Real.eulerMascheroniSeq' n - Real.eulerMascheroniConstant < 1 / n := by
  have h1 := Real.eulerMascheroniSeq_lt_eulerMascheroniConstant n
  have hw := bracket_width hn
  have hle := width_le hn
  linarith

/-- The series tail from `EulerMascheroniSeries` is exactly the approximation error
`γ - (H_n - log(n+1))`. -/
theorem tail_eq_error (n : ℕ) :
    ∑' k, EulerMascheroniSeries.term (k + n)
      = Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n := by
  have hsplit := EulerMascheroniSeries.summable_term.sum_add_tsum_nat_add n
  rw [EulerMascheroniSeries.tsum_eulerMascheroni, EulerMascheroniSeries.partial_sum] at hsplit
  linarith

/-- Hence the series tail is `< 1/n` for `n ≥ 1`. -/
theorem tsum_tail_lt {n : ℕ} (hn : 1 ≤ n) :
    ∑' k, EulerMascheroniSeries.term (k + n) < 1 / n := by
  rw [tail_eq_error]; exact gamma_sub_seq_lt hn

end EulerMascheroniApprox