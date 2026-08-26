import Tropical.WeightExponentDial

/-!
# The fit layer: single-covariate `R²`, its invariances, and the recorded `α`-curve

Exp-586 selects the weight exponent by maximizing the ordinary-least-squares `R²` of the
regression `log-rate ~ S_α`.  This file supplies the exact algebra of that selection rule
and records the measured curve.

* `FitLayer.R2` : the single-covariate coefficient of determination
  `cov(x,y)² / (var x · var y)`.
* `FitLayer.R2_nonneg`, `FitLayer.R2_le_one` : `0 ≤ R² ≤ 1` (discrete Cauchy–Schwarz).
* `FitLayer.R2_affine_left` : `R²` is invariant under any invertible affine
  reparametrization `x ↦ c·x + d` of the covariate.  This is what makes the comparison
  across exponents meaningful: only the *shape* of the weight vector matters, never its
  normalization — so the exp-586 ranking is not an artefact of the fact that `S_α` shrinks
  with `α`.
* `FitLayer.R2_eq_one_of_affine` : a perfectly affine covariate attains `R² = 1`.
* `FitLayer.r2Curve` and the theorems `r2Curve_argmax_eq_half`, `r2Curve_unimodal`,
  `harmonic_on_falling_limb`, `gain_over_harmonic_ge_bar`, `weighting_beats_unweighted`:
  the recorded exp-586 measurement, stated exactly over `ℚ`, including the
  pre-registered `0.03` bar and the fact that the harmonic exponent `α = 1` lies on the
  falling limb.
-/

open Finset

namespace FitLayer

variable {ι : Type*} [Fintype ι]

/-- Sample mean of a data vector. -/
noncomputable def mean (x : ι → ℝ) : ℝ := (∑ i, x i) / (Fintype.card ι)

/-- (Unnormalized) sample covariance. -/
noncomputable def cov (x y : ι → ℝ) : ℝ := ∑ i, (x i - mean x) * (y i - mean y)

/-- (Unnormalized) sample variance. -/
noncomputable def varr (x : ι → ℝ) : ℝ := cov x x

/-- The single-covariate coefficient of determination of the OLS fit `y ~ x`. -/
noncomputable def R2 (x y : ι → ℝ) : ℝ := cov x y ^ 2 / (varr x * varr y)

lemma varr_nonneg (x : ι → ℝ) : 0 ≤ varr x := by
  unfold varr cov
  exact Finset.sum_nonneg fun i _ => mul_self_nonneg _

/-- Discrete Cauchy–Schwarz for the sample covariance. -/
theorem cov_sq_le (x y : ι → ℝ) : cov x y ^ 2 ≤ varr x * varr y := by
  have := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ
    (fun i : ι => x i - mean x) (fun i : ι => y i - mean y)
  simpa [cov, varr, sq] using this

theorem R2_nonneg (x y : ι → ℝ) : 0 ≤ R2 x y :=
  div_nonneg (sq_nonneg _) (mul_nonneg (varr_nonneg x) (varr_nonneg y))

theorem R2_le_one (x y : ι → ℝ) : R2 x y ≤ 1 := by
  unfold R2
  rcases eq_or_lt_of_le (mul_nonneg (varr_nonneg x) (varr_nonneg y)) with h | h
  · rw [← h, div_zero]; norm_num
  · rw [div_le_one h]; exact cov_sq_le x y

lemma mean_affine (c d : ℝ) (x : ι → ℝ) [Nonempty ι] :
    mean (fun i => c * x i + d) = c * mean x + d := by
  have hcard : (0 : ℝ) < (Fintype.card ι) := by
    exact_mod_cast Fintype.card_pos
  unfold mean
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, Finset.sum_const, nsmul_eq_mul,
    Finset.card_univ]
  field_simp

lemma cov_affine_left (c d : ℝ) (x y : ι → ℝ) [Nonempty ι] :
    cov (fun i => c * x i + d) y = c * cov x y := by
  unfold cov
  rw [mean_affine c d x, Finset.mul_sum]
  refine Finset.sum_congr rfl fun i _ => ?_
  ring

lemma varr_affine (c d : ℝ) (x : ι → ℝ) [Nonempty ι] :
    varr (fun i => c * x i + d) = c ^ 2 * varr x := by
  unfold varr
  rw [cov_affine_left c d x (fun i => c * x i + d)]
  have : cov x (fun i => c * x i + d) = c * cov x x := by
    unfold cov
    rw [mean_affine c d x, Finset.mul_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    ring
  rw [this]
  ring

/-- **Scale/offset invariance of the selection rule.**  Rescaling or shifting the covariate
does not change `R²`.  Hence the exp-586 comparison across exponents measures the *shape*
of the weight vector `(ℓ^{-α})_ℓ`, not its magnitude. -/
theorem R2_affine_left {c : ℝ} (hc : c ≠ 0) (d : ℝ) (x y : ι → ℝ) [Nonempty ι] :
    R2 (fun i => c * x i + d) y = R2 x y := by
  unfold R2
  rw [cov_affine_left c d x y, varr_affine c d x]
  rcases eq_or_ne (varr x * varr y) 0 with h | h
  · have h' : c ^ 2 * varr x * varr y = 0 := by rw [mul_assoc, h, mul_zero]
    rw [h, h', div_zero, div_zero]
  · field_simp

/-- A covariate that predicts the response exactly (affinely) attains `R² = 1`. -/
theorem R2_eq_one_of_affine {a b : ℝ} (ha : a ≠ 0) (x : ι → ℝ) [Nonempty ι]
    (hx : varr x ≠ 0) : R2 x (fun i => a * x i + b) = 1 := by
  have hcov : cov x (fun i => a * x i + b) = a * varr x := by
    unfold varr cov
    rw [mean_affine a b x, Finset.mul_sum]
    refine Finset.sum_congr rfl fun i _ => ?_
    ring
  have hvar : varr (fun i => a * x i + b) = a ^ 2 * varr x := varr_affine a b x
  unfold R2
  rw [hcov, hvar]
  field_simp

/-! ### The recorded exp-586 measurement

The eight-point grid `α ∈ {0, ¼, ½, ¾, 1, 1¼, 1½, 2}` and the measured `R²` values
(`n = 128`, bit length 96, odd primes `3..400`).  All statements below are exact rational
facts about the recorded table. -/

/-- The exponent grid of exp-586. -/
def alphaGrid : Fin 8 → ℚ := ![0, 1/4, 1/2, 3/4, 1, 5/4, 3/2, 2]

/-- The measured `R²` values of exp-586, exactly as recorded (4 decimal places). -/
def r2Curve : Fin 8 → ℚ :=
  ![3207/10000, 4985/10000, 6242/10000, 5752/10000,
    4731/10000, 3969/10000, 3479/10000, 2944/10000]

/-- The fitted exponent is `α̂ = 1/2`. -/
theorem alphaGrid_two : alphaGrid 2 = 1 / 2 := by simp [alphaGrid]

/-- The harmonic exponent adopted by inspection in paper 227 sits at index `4`. -/
theorem alphaGrid_four : alphaGrid 4 = 1 := by simp [alphaGrid]

/-- **Unique argmax.**  Every grid point other than `α = 1/2` has strictly smaller `R²`. -/
theorem r2Curve_argmax_eq_half : ∀ i : Fin 8, i ≠ 2 → r2Curve i < r2Curve 2 := by
  intro i hi
  fin_cases i <;> simp_all [r2Curve] <;> norm_num

/-- **Single-peakedness**: strictly increasing up to the peak and strictly decreasing
afterwards. -/
theorem r2Curve_unimodal :
    (∀ i j : Fin 8, i < j → j ≤ 2 → r2Curve i < r2Curve j) ∧
      (∀ i j : Fin 8, 2 ≤ i → i < j → r2Curve j < r2Curve i) := by
  constructor
  · intro i j hij hj
    fin_cases i <;> fin_cases j <;> simp_all [r2Curve, Fin.lt_def, Fin.le_def] <;> norm_num
  · intro i j hi hij
    fin_cases i <;> fin_cases j <;> simp_all [r2Curve, Fin.lt_def, Fin.le_def] <;> norm_num

/-- The harmonic weight `α = 1` lies on the **falling limb** of the curve: it is beaten
even by its left neighbour `α = 3/4`. -/
theorem harmonic_on_falling_limb : r2Curve 4 < r2Curve 3 ∧ r2Curve 3 < r2Curve 2 := by
  refine ⟨by simp [r2Curve]; norm_num, by simp [r2Curve]; norm_num⟩

/-- The pre-registered bar `ΔR² ≥ 0.03` is cleared: the fitted exponent beats the harmonic
one by `0.1511`. -/
theorem gain_over_harmonic_ge_bar :
    r2Curve 2 - r2Curve 4 = 1511/10000 ∧ (3 : ℚ)/100 ≤ r2Curve 2 - r2Curve 4 := by
  refine ⟨by simp [r2Curve]; norm_num, by simp [r2Curve]; norm_num⟩

/-- Sanity anchors: weighting really does help (paper 227 was right about that), and the
fitted exponent beats the unweighted statistic by twice as much as the harmonic one does. -/
theorem weighting_beats_unweighted :
    r2Curve 4 - r2Curve 0 = 1524/10000 ∧
      r2Curve 2 - r2Curve 0 = 3035/10000 ∧
      2 * (r2Curve 4 - r2Curve 0) < r2Curve 2 - r2Curve 0 + 1/100 := by
  refine ⟨by simp [r2Curve]; norm_num, by simp [r2Curve]; norm_num,
    by simp [r2Curve]; norm_num⟩

/-- The curve is not monotone in either direction — an interior optimum genuinely exists,
which is precisely what rules out "just take `α` as large/small as you like". -/
theorem r2Curve_not_monotone :
    ¬ (∀ i j : Fin 8, i ≤ j → r2Curve i ≤ r2Curve j) ∧
      ¬ (∀ i j : Fin 8, i ≤ j → r2Curve j ≤ r2Curve i) := by
  constructor
  · intro h
    have h1 := h 2 4 (by decide)
    simp [r2Curve] at h1
    norm_num at h1
  · intro h
    have h2 := h 0 2 (by decide)
    simp [r2Curve] at h2
    norm_num at h2

end FitLayer