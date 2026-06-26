import Mathlib

/-!
# Quantitative rational approximation of the Euler–Mascheroni constant

Mathlib proves `Real.eulerMascheroniSeq n < γ < Real.eulerMascheroniSeq' n` where
`eulerMascheroniSeq n = harmonic n - log (n+1)` and
`eulerMascheroniSeq' n = harmonic n - log n`.  Here we turn the (qualitative)
convergence into an **explicit, effective error bound**:

`0 < γ - (harmonic n - log (n+1)) < 1/n`,

so `harmonic n - log (n+1)` approximates `γ` with error `< 1/n`.  This is the
Apéry-flavoured statement: a sequence of (harmonic-minus-log) values whose
distance to `γ` is controlled by an explicit decreasing rational `1/n`.

## Main results
* `EulerMascheroni.gamma_sub_seq_pos` — `γ` strictly exceeds the lower sequence.
* `EulerMascheroni.gamma_sub_seq_lt_log_gap` — the error is bounded by the log gap.
* `EulerMascheroni.gamma_sub_seq_lt_inv` — **error `< 1/n`**.
* `EulerMascheroni.abs_gamma_sub_approx_lt_inv` — absolute-value form of the bound.

-- !-- Lab Notes -- !--
HYPOTHESIS (Hypothesizer): The two-sided Mathlib enclosure of γ should yield an
  explicit `O(1/n)` error bound, because the gap between the upper and lower
  sequences is exactly `log(n+1) - log n = log(1 + 1/n)`, which is `< 1/n`.
EXPERIMENT (Experimenter): Computed `eulerMascheroniSeq' n - eulerMascheroniSeq n
  = log(n+1) - log n` directly, then bounded it strictly by `1/n` using the strict
  log inequality `Real.log_lt_sub_one_of_pos` at `x = (n+1)/n ≠ 1`.
ANALYSIS (Analyst): The strict inequality `log(1+1/n) < 1/n` (not just `≤`) is what
  makes the bound a clean *open* estimate; the non-strict `log_le_sub_one` would only
  give `≤ 1/n`. Edge case `n = 0` is genuinely excluded (the upper sequence uses a
  junk value at 0 and `1/0 = 0` would make the claim false).
CRITIQUE (Critic): Not vacuous — hypothesis `0 < n` is load-bearing and the
  conclusion is a strict numerical inequality, proved with `linarith` from a strict
  convexity fact, not `simp`/`decide`.
SYNTHESIS (PI): An effective approximation theorem usable as a certified error bound.
-/

open Real Filter Topology

namespace EulerMascheroni

/-- The lower sequence strictly underestimates `γ`. -/
theorem gamma_sub_seq_pos (n : ℕ) :
    0 < Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n :=
  sub_pos.mpr (Real.eulerMascheroniSeq_lt_eulerMascheroniConstant n)

/-- The approximation error is bounded by the logarithmic gap `log(n+1) - log n`. -/
theorem gamma_sub_seq_lt_log_gap (n : ℕ) (hn : 0 < n) :
    Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n
      < Real.log (n + 1) - Real.log n := by
  have h1 := Real.eulerMascheroniConstant_lt_eulerMascheroniSeq' n
  have hseq' : Real.eulerMascheroniSeq' n = (harmonic n : ℝ) - Real.log n := by
    rw [Real.eulerMascheroniSeq']; simp [hn.ne']
  have hgap : Real.eulerMascheroniSeq' n - Real.eulerMascheroniSeq n
      = Real.log (n + 1) - Real.log n := by
    rw [hseq', Real.eulerMascheroniSeq]; ring
  linarith [h1, hgap]

/-- **Effective error bound.** `harmonic n - log (n+1)` approximates `γ` to within
`1/n`: `γ - (harmonic n - log (n+1)) < 1/n`. -/
theorem gamma_sub_seq_lt_inv (n : ℕ) (hn : 0 < n) :
    Real.eulerMascheroniConstant - Real.eulerMascheroniSeq n < 1 / (n : ℝ) := by
  have hnR : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hgap := gamma_sub_seq_lt_log_gap n hn
  -- `log(n+1) - log n = log((n+1)/n) < (n+1)/n - 1 = 1/n`.
  have hx : (0 : ℝ) < ((n : ℝ) + 1) / (n : ℝ) := by positivity
  have hne : ((n : ℝ) + 1) / (n : ℝ) ≠ 1 := by
    intro hc; rw [div_eq_one_iff_eq hnR.ne'] at hc; linarith
  have hstrict := Real.log_lt_sub_one_of_pos hx hne
  rw [Real.log_div (by positivity) hnR.ne'] at hstrict
  have hsub : ((n : ℝ) + 1) / (n : ℝ) - 1 = 1 / (n : ℝ) := by field_simp; ring
  rw [hsub] at hstrict
  linarith

/-- Absolute-value form: `|γ - (harmonic n - log (n+1))| < 1/n`. -/
theorem abs_gamma_sub_approx_lt_inv (n : ℕ) (hn : 0 < n) :
    |Real.eulerMascheroniConstant - ((harmonic n : ℝ) - Real.log (n + 1))|
      < 1 / (n : ℝ) := by
  have hpos := gamma_sub_seq_pos n
  have hlt := gamma_sub_seq_lt_inv n hn
  have hseq : Real.eulerMascheroniSeq n = (harmonic n : ℝ) - Real.log (n + 1) := rfl
  rw [hseq] at hpos hlt
  rw [abs_of_pos hpos]
  exact hlt

end EulerMascheroni