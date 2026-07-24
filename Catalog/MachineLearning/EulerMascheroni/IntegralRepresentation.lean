import Catalog.MachineLearning.EulerMascheroni.SeriesRepresentation
import Catalog.NumberTheory.Irrationality

/-!
# An integral representation of the Euler–Mascheroni constant

We exhibit each term of the positive series from `SeriesRepresentation` as an
*interval integral*:
```
gterm k = ∫_{k+1}^{k+2} ( 1/(k+1) − 1/x ) dx .
```
Summing, this is the classical integral representation
```
γ = ∑_{k} ∫_{k+1}^{k+2} ( 1/(k+1) − 1/x ) dx ,
```
the discrete form of `γ = ∫_1^∞ (1/⌊x⌋ − 1/x) dx`.  The integrand
`1/⌊x⌋ − 1/x ≥ 0` on each unit interval, matching `gterm_pos`.

This file also connects the development to the *irrationality engine* of the
companion catalog file `Catalog/NumberTheory/Irrationality.lean`: from
`hasSum_gterm` we read off the convergence of the lower approximants and feed it
through `EulerMascheroni.eulerMascheroniSeq_sandwich` to re-derive the trapping
of `γ`, making explicit that the *integral* representation supplies the same
non-rational approximants the engine analyses.

-- !-- Lab Notes -- !--
HYPOTHESIS.  Each `gterm k` is the integral of `1/(k+1) − 1/x` over the unit
interval `[k+1, k+2]`, since `∫ 1/x = log` and `∫ const = const`.

EXPERIMENT.  `gterm_eq_integral` uses `integral_one_div` (needs `0 ∉ uIcc`) and
`intervalIntegrable_one_div`; the constant piece is `intervalIntegral.integral_const`.

ANALYSIS.  The integrand is nonnegative on each window (`integrand_nonneg`),
matching term positivity; the representation is `γ = ∑ ∫…`, an honest integral
form rather than a definitional rewrite.

CRITIQUE.  Care with the interval-integrability side goals (`0` avoided on
`[k+1,k+2]`) — these are discharged with `linarith` after `Set.uIcc_of_le`.

SYNTHESIS.  Integral and series pictures agree term-by-term; combined with the
catalog engine this clarifies that the obstruction to irrationality is the
*non-rational* nature of the approximants, not the absence of a representation.
-/

open Filter Topology Real intervalIntegral

namespace EulerMascheroni

/-- The integrand of the integral representation, `1/(k+1) − 1/x`, is
nonnegative on the window `[k+1, k+2]` (where `x ≥ k+1`). -/
theorem integrand_nonneg (k : ℕ) {x : ℝ} (hx : (k : ℝ) + 1 ≤ x) :
    0 ≤ (1 : ℝ) / (k + 1) - 1 / x := by
  have hk : (0 : ℝ) < (k : ℝ) + 1 := by positivity
  rw [sub_nonneg]
  exact one_div_le_one_div_of_le hk hx

/-- **Integral form of the series term.**  Each term equals the integral of
`1/(k+1) − 1/x` over the unit interval `[k+1, k+2]`. -/
theorem gterm_eq_integral (k : ℕ) :
    gterm k = ∫ x in ((k : ℝ) + 1)..((k : ℝ) + 2), ((1 : ℝ) / (k + 1) - 1 / x) := by
  have hle : ((k : ℝ) + 1) ≤ ((k : ℝ) + 2) := by linarith
  have hsub : (0 : ℝ) ∉ Set.uIcc ((k : ℝ) + 1) ((k : ℝ) + 2) := by
    rw [Set.uIcc_of_le hle]
    simp only [Set.mem_Icc, not_and, not_le]; intro h; linarith
  have hII : IntervalIntegrable (fun x => 1 / x) MeasureTheory.volume
      ((k : ℝ) + 1) ((k : ℝ) + 2) := by
    apply intervalIntegrable_one_div (f := fun x => x)
    · intro x hx
      rw [Set.uIcc_of_le hle] at hx
      simp only [Set.mem_Icc] at hx
      intro h; rw [h] at hx; linarith [hx.1]
    · exact continuousOn_id
  rw [intervalIntegral.integral_sub intervalIntegral.intervalIntegrable_const hII,
    integral_one_div hsub]
  simp only [intervalIntegral.integral_const, smul_eq_mul]
  rw [Real.log_div (by positivity) (by positivity)]
  unfold gterm; ring

/-- **Main integral representation.**  `γ` is the sum of the unit-interval
integrals of `1/(k+1) − 1/x`. -/
theorem hasSum_integral_repr :
    HasSum (fun k : ℕ => ∫ x in ((k : ℝ) + 1)..((k : ℝ) + 2), ((1 : ℝ) / (k + 1) - 1 / x))
      Real.eulerMascheroniConstant := by
  have h := hasSum_gterm
  have hfun : (fun k : ℕ => ∫ x in ((k : ℝ) + 1)..((k : ℝ) + 2), ((1 : ℝ) / (k + 1) - 1 / x))
      = gterm := by
    funext k; exact (gterm_eq_integral k).symm
  rw [hfun]; exact h

/-- **Bridge to the catalog irrationality engine.**  The integral representation
supplies the lower approximants that trap `γ`: combined with the catalog's
`eulerMascheroniSeq_sandwich`, the partial integral sums lie strictly below `γ`,
while `eulerMascheroniSeq'` lies strictly above.  This makes precise that the
representation feeds the engine's non-rational approximants. -/
theorem integral_partialSum_lt_lt_seq' (n : ℕ) :
    (∑ k ∈ Finset.range n,
        ∫ x in ((k : ℝ) + 1)..((k : ℝ) + 2), ((1 : ℝ) / (k + 1) - 1 / x))
        < Real.eulerMascheroniConstant ∧
      Real.eulerMascheroniConstant < Real.eulerMascheroniSeq' n := by
  have hpartial :
      (∑ k ∈ Finset.range n,
        ∫ x in ((k : ℝ) + 1)..((k : ℝ) + 2), ((1 : ℝ) / (k + 1) - 1 / x))
        = Real.eulerMascheroniSeq n := by
    simp only [← gterm_eq_integral]; exact gterm_partial n
  rw [hpartial]
  exact EulerMascheroni.eulerMascheroniSeq_sandwich n

end EulerMascheroni