/-
# The yield dial as a regressor: explained variance, augmentation, and regime invariance

Companion to `Combinatorics.UniformDialDrawInvariance`.  There the *sign* of the dial was
shown to be draw-regime invariant; here we analyse the *variance-share* (R²) statistic
that the experiment reports, in the same finite-population / arbitrary-draw-regime setting.

Main results.

* `mse_decomposition` — the exact bias/variance decomposition of the weighted mean squared
  error of an affine predictor `a + b·x` of the rate `y`.
* `mse_optimal`, `mse_ge_optimal` — the ordinary-least-squares optimum and its value
  `Var y − Cov² / Var x`, valid in every draw regime.
* `wcov_sq_le` — weighted Cauchy–Schwarz, obtained as a *corollary* of the optimality
  statement; hence `R2_nonneg`, `R2_le_one`: the variance share is a genuine share.
* `mse_optimal_eq_R2` — `min MSE = Var y · (1 − R²)`, the identity that makes R² the
  "yield dial" reading.
* `augment_strict_gain` — adding a second regressor `z` to the fit strictly lowers the
  residual error, by exactly `⟨r,z⟩²/‖z‖²`, whenever the residual is not orthogonal to `z`.
  This is the *augmented* R² of the experiment, and the gain formula is regime-explicit.
* `footprint_beats_count_uniform`, `footprint_beats_count_unbalanced` — a concrete
  four-key population on which footprint weighting beats plain count by more than `0.2`
  under a uniform regime and by more than `0.13` under a `(0.7, 0.1, 0.1, 0.1)` regime:
  the ordering of the two dials survives a genuinely unbalanced draw, while the numerical
  gap does move.  `footprint_count_regimes_far` records that the two regimes are far
  apart in ℓ¹, so this is not a perturbative statement.
-/
import Combinatorics.UniformDialDrawInvariance

open Finset

namespace Catalog.UniformDial

variable {ι : Type*} [Fintype ι]

/-- Weighted mean squared error of the affine predictor `a + b * x` for the rate `y`. -/
noncomputable def mse (p x y : ι → ℝ) (a b : ℝ) : ℝ :=
  ∑ i, p i * (y i - (a + b * x i)) ^ 2

lemma centered_sum_eq_zero {p x : ι → ℝ} (hp : ∑ i, p i = 1) :
    ∑ i, p i * (x i - wmean p x) = 0 := by
  have : ∀ i, p i * (x i - wmean p x) = p i * x i - wmean p x * p i :=
    fun i => by ring
  rw [Finset.sum_congr rfl fun i _ => this i, Finset.sum_sub_distrib, ← Finset.mul_sum, hp,
    mul_one]
  simp [wmean]

lemma wvar_nonneg {p x : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) : 0 ≤ wvar p x := by
  refine Finset.sum_nonneg fun i _ => ?_
  have : p i * (x i - wmean p x) * (x i - wmean p x)
      = p i * (x i - wmean p x) ^ 2 := by ring
  rw [this]
  exact mul_nonneg (hp0 i) (sq_nonneg _)

lemma mse_nonneg {p x y : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (a b : ℝ) : 0 ≤ mse p x y a b :=
  Finset.sum_nonneg fun i _ => mul_nonneg (hp0 i) (sq_nonneg _)

/-- **Exact decomposition of the weighted MSE** into rate variance, dial covariance,
dial variance and a squared calibration bias. -/
theorem mse_decomposition {p x y : ι → ℝ} (hp : ∑ i, p i = 1) (a b : ℝ) :
    mse p x y a b = wvar p y - 2 * b * wcov p x y + b ^ 2 * wvar p x
      + (wmean p y - a - b * wmean p x) ^ 2 := by
  set mx := wmean p x with hmx
  set my := wmean p y with hmy
  set c := my - a - b * mx with hc
  have hx0 : ∑ i, p i * (x i - mx) = 0 := centered_sum_eq_zero hp
  have hy0 : ∑ i, p i * (y i - my) = 0 := centered_sum_eq_zero hp
  have expand : ∀ i, p i * (y i - (a + b * x i)) ^ 2
      = p i * (y i - my) * (y i - my) + b ^ 2 * (p i * (x i - mx) * (x i - mx))
        - 2 * b * (p i * (x i - mx) * (y i - my)) + 2 * c * (p i * (y i - my))
        - 2 * b * c * (p i * (x i - mx)) + c ^ 2 * p i := by
    intro i
    have : y i - (a + b * x i) = (y i - my) - b * (x i - mx) + c := by rw [hc]; ring
    rw [this]; ring
  rw [mse, Finset.sum_congr rfl fun i _ => expand i]
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum, hx0, hy0, hp,
    mul_zero, mul_one, add_zero, sub_zero]
  simp only [wvar, wcov, ← hmx, ← hmy]
  ring

/-- The OLS optimum: at slope `Cov/Var x` and intercept `E y − slope · E x` the weighted
MSE equals `Var y − Cov²/Var x`. -/
theorem mse_optimal {p x y : ι → ℝ} (hp : ∑ i, p i = 1) (hvx : 0 < wvar p x) :
    mse p x y (wmean p y - (wcov p x y / wvar p x) * wmean p x) (wcov p x y / wvar p x)
      = wvar p y - (wcov p x y) ^ 2 / wvar p x := by
  rw [mse_decomposition hp]
  field_simp
  ring

/-- No affine predictor beats the OLS value, in any draw regime. -/
theorem mse_ge_optimal {p x y : ι → ℝ} (hp : ∑ i, p i = 1) (hvx : 0 < wvar p x) (a b : ℝ) :
    wvar p y - (wcov p x y) ^ 2 / wvar p x ≤ mse p x y a b := by
  rw [mse_decomposition hp]
  have key : b ^ 2 * wvar p x - 2 * b * wcov p x y + (wcov p x y) ^ 2 / wvar p x
      = (b * wvar p x - wcov p x y) ^ 2 / wvar p x := by
    field_simp; ring
  nlinarith [sq_nonneg (wmean p y - a - b * wmean p x),
    div_nonneg (sq_nonneg (b * wvar p x - wcov p x y)) hvx.le, key]

/-- **Weighted Cauchy–Schwarz**, derived from nonnegativity of the optimal MSE. -/
theorem wcov_sq_le {p x y : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (hvx : 0 < wvar p x) : (wcov p x y) ^ 2 ≤ wvar p x * wvar p y := by
  have hopt : mse p x y (wmean p y - (wcov p x y / wvar p x) * wmean p x)
      (wcov p x y / wvar p x) = wvar p y - (wcov p x y) ^ 2 / wvar p x := mse_optimal hp hvx
  have hnn : 0 ≤ mse p x y (wmean p y - (wcov p x y / wvar p x) * wmean p x)
      (wcov p x y / wvar p x) := mse_nonneg hp0 _ _
  rw [hopt] at hnn
  have hle : (wcov p x y) ^ 2 / wvar p x ≤ wvar p y := by linarith
  calc (wcov p x y) ^ 2 = ((wcov p x y) ^ 2 / wvar p x) * wvar p x := by field_simp
    _ ≤ wvar p y * wvar p x := mul_le_mul_of_nonneg_right hle hvx.le
    _ = wvar p x * wvar p y := by ring

/-- The variance share (R²) of the dial `x` for the rate `y` in draw regime `p`. -/
noncomputable def R2 (p x y : ι → ℝ) : ℝ := (wcov p x y) ^ 2 / (wvar p x * wvar p y)

theorem R2_nonneg {p x y : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) : 0 ≤ R2 p x y :=
  div_nonneg (sq_nonneg _) (mul_nonneg (wvar_nonneg hp0) (wvar_nonneg hp0))

theorem R2_le_one {p x y : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (hvx : 0 < wvar p x) (hvy : 0 < wvar p y) : R2 p x y ≤ 1 := by
  rw [R2, div_le_one (mul_pos hvx hvy)]
  exact wcov_sq_le hp0 hp hvx

/-- `min MSE = Var y · (1 − R²)`: the variance share really is the fraction of rate
variance the dial explains, in whichever draw regime it is measured. -/
theorem mse_optimal_eq_R2 {p x y : ι → ℝ} (hp : ∑ i, p i = 1) (hvx : 0 < wvar p x)
    (hvy : 0 < wvar p y) :
    mse p x y (wmean p y - (wcov p x y / wvar p x) * wmean p x) (wcov p x y / wvar p x)
      = wvar p y * (1 - R2 p x y) := by
  rw [mse_optimal hp hvx, R2]
  field_simp

/-- **Augmentation gain.**  Fitting a further regressor `z` to the current residual `r`
lowers the weighted squared error by exactly `⟨r,z⟩²/‖z‖²`. -/
theorem augment_gain_eq {p r z : ι → ℝ} (hz : 0 < ∑ i, p i * z i ^ 2) :
    ∑ i, p i * (r i - ((∑ j, p j * r j * z j) / (∑ j, p j * z j ^ 2)) * z i) ^ 2
      = (∑ i, p i * r i ^ 2) - (∑ i, p i * r i * z i) ^ 2 / (∑ i, p i * z i ^ 2) := by
  set c := (∑ j, p j * r j * z j) / (∑ j, p j * z j ^ 2) with hcdef
  have expand : ∀ i, p i * (r i - c * z i) ^ 2
      = p i * r i ^ 2 - 2 * c * (p i * r i * z i) + c ^ 2 * (p i * z i ^ 2) := by
    intro i; ring
  rw [Finset.sum_congr rfl fun i _ => expand i]
  simp only [Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum]
  rw [hcdef]
  field_simp
  ring

/-- **Augmented R² strictly exceeds the base R².**  If the residual of the current fit is
not orthogonal to the new regressor `z` (a regime-computable condition), the augmented fit
is strictly better; the improvement is the explicit quantity of `augment_gain_eq`. -/
theorem augment_strict_gain {p r z : ι → ℝ} (hz : 0 < ∑ i, p i * z i ^ 2)
    (hrz : (∑ i, p i * r i * z i) ≠ 0) :
    ∑ i, p i * (r i - ((∑ j, p j * r j * z j) / (∑ j, p j * z j ^ 2)) * z i) ^ 2
      < ∑ i, p i * r i ^ 2 := by
  rw [augment_gain_eq hz]
  have : 0 < (∑ i, p i * r i * z i) ^ 2 / (∑ i, p i * z i ^ 2) :=
    div_pos (by positivity) hz
  linarith

/-! ### Exact drivers: when the footprint *is* the mechanism -/

lemma wmean_affine {p x : ι → ℝ} (hp : ∑ i, p i = 1) (a b : ℝ) :
    wmean p (fun i => a + b * x i) = a + b * wmean p x := by
  simp only [wmean]
  have : ∀ i, p i * (a + b * x i) = a * p i + b * (p i * x i) := fun i => by ring
  rw [Finset.sum_congr rfl fun i _ => this i, Finset.sum_add_distrib, ← Finset.mul_sum,
    ← Finset.mul_sum, hp, mul_one]

lemma wcov_affine {p x : ι → ℝ} (hp : ∑ i, p i = 1) (a b : ℝ) :
    wcov p x (fun i => a + b * x i) = b * wvar p x := by
  simp only [wcov, wvar, wmean_affine hp]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by simp only [wmean]; ring

lemma wvar_affine {p x : ι → ℝ} (hp : ∑ i, p i = 1) (a b : ℝ) :
    wvar p (fun i => a + b * x i) = b ^ 2 * wvar p x := by
  simp only [wvar, wcov, wmean_affine hp]
  rw [Finset.mul_sum]
  exact Finset.sum_congr rfl fun i _ => by simp only [wmean]; ring

/-- If the rate is an exact nonconstant affine function of the footprint, the footprint
dial reads a full variance share `1` — in **every** draw regime. -/
theorem R2_affine_eq_one {p x : ι → ℝ} (hp : ∑ i, p i = 1) (hvx : 0 < wvar p x)
    {a b : ℝ} (hb : b ≠ 0) : R2 p x (fun i => a + b * x i) = 1 := by
  have hb2 : (0:ℝ) < b ^ 2 := by positivity
  rw [R2, wcov_affine hp, wvar_affine hp]
  field_simp

/-- **Draw-invariant dominance.**  When the footprint is the exact driver of the rate, no
competing dial can beat it, in any draw regime and for any competitor with nonzero
variance.  This is the structural ceiling behind the experimental observation that
footprint weighting beats plain count in both the balanced and the unbalanced regime. -/
theorem footprint_dominates {p x z : ι → ℝ} (hp0 : ∀ i, 0 ≤ p i) (hp : ∑ i, p i = 1)
    (hvx : 0 < wvar p x) {a b : ℝ} (hb : b ≠ 0) (hvz : 0 < wvar p z)
    (hvy : 0 < wvar p (fun i => a + b * x i)) :
    R2 p z (fun i => a + b * x i) ≤ R2 p x (fun i => a + b * x i) := by
  rw [R2_affine_eq_one hp hvx hb]
  exact R2_le_one hp0 hp hvz hvy

/-! ### A concrete four-key population, measured in two very different draw regimes -/

section Example

/-- Footprint weights of four keys. -/
def fw : Fin 4 → ℝ := ![1, 2, 4, 8]

/-- Plain counts of the same four keys. -/
def fc : Fin 4 → ℝ := ![1, 1, 2, 2]

/-- Observed yield rates. -/
def fy : Fin 4 → ℝ := ![1, 2, 5, 9]

/-- The uniform (balanced) draw regime. -/
noncomputable def pU : Fin 4 → ℝ := ![1/4, 1/4, 1/4, 1/4]

/-- A genuinely unbalanced draw regime. -/
noncomputable def pQ : Fin 4 → ℝ := ![7/10, 1/10, 1/10, 1/10]

lemma pU_nonneg (i : Fin 4) : 0 ≤ pU i := by
  fin_cases i <;> norm_num [pU]

lemma pQ_nonneg (i : Fin 4) : 0 ≤ pQ i := by
  fin_cases i <;> norm_num [pQ]

lemma pU_total : ∑ i, pU i = 1 := by
  norm_num [pU, Fin.sum_univ_four,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons, Matrix.head_cons]

lemma pQ_total : ∑ i, pQ i = 1 := by
  norm_num [pQ, Fin.sum_univ_four,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons, Matrix.head_cons]

/-- The two regimes are far apart: their ℓ¹ distance is `0.9`, i.e. total variation `0.45`.
So the comparisons below are not perturbations of one another. -/
theorem footprint_count_regimes_far : ∑ i, |pU i - pQ i| = 9/10 := by
  norm_num [pU, pQ, Fin.sum_univ_four,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons, Matrix.head_cons]

/-- Under the balanced regime, the footprint dial explains more than `0.2` more of the
rate variance than the plain count does. -/
theorem footprint_beats_count_uniform : R2 pU fc fy + 1/5 < R2 pU fw fy := by
  norm_num [R2, wcov, wvar, wmean, fw, fc, fy, pU, Fin.sum_univ_four,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons, Matrix.head_cons]

/-- The same ordering under the genuinely unbalanced regime, with gap more than `0.13`:
the dial's advantage is draw-regime invariant even though its size moves. -/
theorem footprint_beats_count_unbalanced : R2 pQ fc fy + 13/100 < R2 pQ fw fy := by
  norm_num [R2, wcov, wvar, wmean, fw, fc, fy, pQ, Fin.sum_univ_four,
    Matrix.cons_val_two, Matrix.cons_val_three, Matrix.tail_cons, Matrix.head_cons]

/-- The example population is comonotone, so the qualitative invariance theorems of
`Combinatorics.UniformDialDrawInvariance` apply to it. -/
theorem fw_fy_comonotone : Comonotone fw fy := by
  intro i j
  fin_cases i <;> fin_cases j <;> norm_num [fw, fy]

/-- The uniform regime as a `DrawRegime`. -/
noncomputable def regU : DrawRegime (Fin 4) := ⟨pU, pU_nonneg, pU_total⟩

/-- The unbalanced regime as a `DrawRegime`. -/
noncomputable def regQ : DrawRegime (Fin 4) := ⟨pQ, pQ_nonneg, pQ_total⟩

/-- Instantiating the qualitative invariance theorem: the footprint dial is strictly
positive in both the balanced and the genuinely unbalanced regime. -/
theorem example_dial_positive_both_regimes : 0 < wcov pU fw fy ∧ 0 < wcov pQ fw fy :=
  dial_sign_draw_invariant (x := fw) (y := fy) regU regQ
    (fun i => by fin_cases i <;> norm_num [regU, pU])
    (fun i => by fin_cases i <;> norm_num [regQ, pQ])
    fw_fy_comonotone (a := 3) (b := 0)
    (by norm_num [fw, fy, Matrix.cons_val_three, Matrix.tail_cons, Matrix.head_cons])

end Example

end Catalog.UniformDial