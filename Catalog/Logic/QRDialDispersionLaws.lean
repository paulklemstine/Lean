/-
# Dispersion accounting for a covariate dial: how much overdispersion can a dial explain?

This file supplies the exact finite-sample laws behind the FACT round-78 experiment
(exp 576, paper 226) in which a per-`N` hit count over 128 balanced bitlen-96 semiprimes
shows a variance-to-mean ratio `D_raw = 7.27` (Poisson would give `1`), and three
small-prime quadratic-residue "dials" are regressed against the per-`N` log rates.

The experiment reports two numbers per dial: a regression `R²` and a *dispersion
reduction* `D-red`.  The pre-registered H1 bar was `R² ≥ 0.25` **and** `D-red ≥ 30%`.
Measured: `R² = 0.0127 / 0.0781 / 0.0565` and `D-red = 0.88% / 14.22% / 9.07%`.

What is proved here is the mathematics that makes those two numbers comparable and that
turns "the dial misses the bar" into a *theorem* about every dial-based recalibration,
not merely about the particular fit that was run:

* `Logic.QRDial.mse_lower_bound` / `Logic.QRDial.mse_ols_eq` — the least-squares residual
  of *any* affine recalibration `y ↦ a + b·s` of a dial `s` is at least
  `var y − cov(y,s)² / var s`, with equality at the OLS coefficients.  So the linear
  explained fraction is exactly the squared correlation `r²`; no re-tuning of the dial's
  slope can do better (`Logic.QRDial.linear_capture_bound`).

* `Logic.QRDial.var_decomposition` — the exact ANOVA identity
  `var = withinVar + betweenVar` for the partition of the sample into the level sets of
  the dial, together with `Logic.QRDial.conditional_mean_optimal`: conditioning on the
  dial's level sets is the *best possible* use of the dial, linear or not.  Hence
  `Logic.QRDial.corr_sq_le_eta_sq`: `r² ≤ η²`, which is why the measured `D-red` (14.22%)
  can and does exceed the linear `R²` (7.81%).

* `Logic.QRDial.disp_reduction_eq_eta_sq` — the dispersion reduction achievable by a dial
  is *exactly* its explained-variance fraction `η²`.  This is the identification that lets
  the two H1 legs be compared at all.

* `Logic.QRDial.poisson_mixture_disp` — under Poisson calibration inside each dial cell,
  `D = 1 + betweenVar / mean`: all overdispersion is between-cell heterogeneity.

* `Logic.QRDial.exp576_residual_dispersion` and
  `Logic.QRDial.exp576_unexplained_excess_fraction` — the certified numeric readings of
  exp 576: from `D_raw = 7.27` and `η² ≤ 0.1422`, the residual dispersion is `≥ 6.23` and
  at least `83%` of the Poisson excess `D − 1` survives the dial, so the H1 bar of `30%`
  is missed by every dial-based recalibration, not just by the fitted one.

Everything is finite-sample and exact; no asymptotics and no distributional assumption
beyond the explicitly stated Poisson-calibration hypothesis.
-/
import Mathlib

open Finset

namespace Logic.QRDial

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Sample averages, variances, covariances -/

/-- The uniform sample average of `x` over the index type `ι`. -/
noncomputable def avg (x : ι → ℝ) : ℝ := (∑ i, x i) / (Fintype.card ι)

/-- The sample covariance of `x` and `y`. -/
noncomputable def cov (x y : ι → ℝ) : ℝ := avg (fun i => (x i - avg x) * (y i - avg y))

/-- The sample variance of `x`. -/
noncomputable def var (x : ι → ℝ) : ℝ := cov x x

/-- The dispersion index (variance-to-mean ratio).  Equals `1` for a Poisson sample. -/
noncomputable def disp (x : ι → ℝ) : ℝ := var x / avg x

lemma card_ne_zero : (Fintype.card ι : ℝ) ≠ 0 := by
  have := Fintype.card_pos (α := ι); positivity

omit [Nonempty ι] in
@[simp] lemma avg_add (f g : ι → ℝ) : avg (fun i => f i + g i) = avg f + avg g := by
  simp [avg, Finset.sum_add_distrib, add_div]

omit [Nonempty ι] in
@[simp] lemma avg_mul_left (c : ℝ) (f : ι → ℝ) : avg (fun i => c * f i) = c * avg f := by
  simp [avg, ← Finset.mul_sum, mul_div_assoc]

@[simp] lemma avg_const (c : ℝ) : avg (fun _ : ι => c) = c := by
  simp [avg, Finset.card_univ]

/-- Covariance in product form: `cov x y = avg (x·y) − avg x · avg y`. -/
lemma cov_eq (x y : ι → ℝ) : cov x y = avg (fun i => x i * y i) - avg x * avg y := by
  have h : (fun i => (x i - avg x) * (y i - avg y))
      = fun i => (x i * y i) + ((-avg x) * y i + ((-avg y) * x i + avg x * avg y)) := by
    funext i; ring
  rw [cov, h]
  simp only [avg_add, avg_mul_left, avg_const]
  ring

lemma cov_comm (x y : ι → ℝ) : cov x y = cov y x := by
  rw [cov_eq, cov_eq]
  have : (fun i => x i * y i) = fun i => y i * x i := by funext i; ring
  rw [this]; ring

/-- Variance in product form. -/
lemma var_eq (x : ι → ℝ) : var x = avg (fun i => x i * x i) - avg x * avg x := cov_eq x x

lemma avg_nonneg {f : ι → ℝ} (hf : ∀ i, 0 ≤ f i) : 0 ≤ avg f := by
  apply div_nonneg (Finset.sum_nonneg fun i _ => hf i)
  positivity

lemma var_nonneg (x : ι → ℝ) : 0 ≤ var x := by
  rw [var, cov]
  exact avg_nonneg fun i => mul_self_nonneg _

/-- **Cauchy–Schwarz** for the sample covariance. -/
lemma cov_sq_le_var_mul_var (x y : ι → ℝ) : (cov x y) ^ 2 ≤ var x * var y := by
  have hn : (0:ℝ) < (Fintype.card ι : ℝ) := by
    have := Fintype.card_pos (α := ι); positivity
  have key : (∑ i, (x i - avg x) * (y i - avg y)) ^ 2
      ≤ (∑ i, (x i - avg x) ^ 2) * ∑ i, (y i - avg y) ^ 2 :=
    Finset.sum_mul_sq_le_sq_mul_sq _ _ _
  have hx : var x = (∑ i, (x i - avg x) ^ 2) / (Fintype.card ι : ℝ) := by
    simp [var, cov, avg, sq]
  have hy : var y = (∑ i, (y i - avg y) ^ 2) / (Fintype.card ι : ℝ) := by
    simp [var, cov, avg, sq]
  have hc : cov x y = (∑ i, (x i - avg x) * (y i - avg y)) / (Fintype.card ι : ℝ) := by
    simp [cov, avg]
  rw [hx, hy, hc, div_pow, div_mul_div_comm]
  have hn2 : (0:ℝ) < (Fintype.card ι : ℝ) * (Fintype.card ι : ℝ) := by positivity
  have hpow : ((Fintype.card ι : ℝ)) ^ 2 = (Fintype.card ι : ℝ) * (Fintype.card ι : ℝ) := sq _
  rw [hpow]
  gcongr

/-! ## Affine recalibration of a dial: the linear capture bound -/

/-- Mean squared error of the affine dial recalibration `y ≈ a + b·s`. -/
noncomputable def mse (y s : ι → ℝ) (a b : ℝ) : ℝ := avg (fun i => (y i - (a + b * s i)) ^ 2)

/-- Exact expansion of the recalibration error. -/
lemma mse_expand (y s : ι → ℝ) (a b : ℝ) :
    mse y s a b = var y - 2 * b * cov y s + b ^ 2 * var s
      + (avg y - a - b * avg s) ^ 2 := by
  have h : (fun i => (y i - (a + b * s i)) ^ 2)
      = fun i => (y i * y i) + ((-2 * b) * (y i * s i)
        + ((b * b) * (s i * s i) + ((-2 * a) * y i + ((2 * a * b) * s i + a ^ 2)))) := by
    funext i; ring
  rw [mse, h]
  simp only [avg_add, avg_mul_left, avg_const]
  rw [var_eq, var_eq, cov_eq]
  ring

/-- **Linear capture bound.**  No affine recalibration of the dial `s` can push the
residual below `var y − cov(y,s)²/var s`. -/
theorem mse_lower_bound (y s : ι → ℝ) (hs : 0 < var s) (a b : ℝ) :
    var y - (cov y s) ^ 2 / var s ≤ mse y s a b := by
  rw [mse_expand]
  have h1 : 0 ≤ (cov y s - b * var s) ^ 2 / var s := by positivity
  have h2 : (cov y s - b * var s) ^ 2 / var s
      = (cov y s) ^ 2 / var s - 2 * b * cov y s + b ^ 2 * var s := by
    field_simp; ring
  have h0 : 0 ≤ (avg y - a - b * avg s) ^ 2 := sq_nonneg _
  rw [h2] at h1
  linarith

/-- The bound of `mse_lower_bound` is attained at the ordinary least squares coefficients. -/
theorem mse_ols_eq (y s : ι → ℝ) (hs : 0 < var s) :
    mse y s (avg y - (cov y s / var s) * avg s) (cov y s / var s)
      = var y - (cov y s) ^ 2 / var s := by
  rw [mse_expand]
  field_simp
  ring

/-- The squared sample correlation of `y` with the dial `s`. -/
noncomputable def corrSq (y s : ι → ℝ) : ℝ := (cov y s) ^ 2 / (var y * var s)

lemma corrSq_nonneg (y s : ι → ℝ) : 0 ≤ corrSq y s := by
  apply div_nonneg (sq_nonneg _)
  exact mul_nonneg (var_nonneg y) (var_nonneg s)

/-- The squared correlation never exceeds `1`. -/
lemma corrSq_le_one (y s : ι → ℝ) (hy : 0 < var y) (hs : 0 < var s) : corrSq y s ≤ 1 := by
  rw [corrSq, div_le_one (by positivity)]
  exact cov_sq_le_var_mul_var y s

/-- **The linear explained fraction is exactly `r²`.**  Every affine recalibration leaves at
least the fraction `1 − r²` of the variance in the residual. -/
theorem linear_capture_bound (y s : ι → ℝ) (hy : 0 < var y) (hs : 0 < var s) (a b : ℝ) :
    (1 - corrSq y s) * var y ≤ mse y s a b := by
  have := mse_lower_bound y s hs a b
  have hcalc : (1 - corrSq y s) * var y = var y - (cov y s) ^ 2 / var s := by
    rw [corrSq]; field_simp
  linarith [hcalc ▸ this]

/-! ## Conditioning on the dial's level sets: the ANOVA decomposition -/

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- The cell of the dial-induced partition with label `k`. -/
def cell (g : ι → κ) (k : κ) : Finset ι := Finset.univ.filter (fun i => g i = k)

/-- The mean of `x` over the cell labelled `k` (zero on empty cells). -/
noncomputable def cellMean (x : ι → ℝ) (g : ι → κ) (k : κ) : ℝ :=
  (∑ i ∈ cell g k, x i) / (cell g k).card

omit [Fintype ι] [Nonempty ι] in
/-- Within a fixed finite set, squared deviations around an arbitrary centre split into
squared deviations around the set's own mean plus a centre-offset term. -/
lemma sum_sq_dev_cell (F : Finset ι) (x : ι → ℝ) (m : ℝ) :
    ∑ i ∈ F, (x i - m) ^ 2
      = (∑ i ∈ F, (x i - (∑ j ∈ F, x j) / F.card) ^ 2)
        + F.card * ((∑ j ∈ F, x j) / F.card - m) ^ 2 := by
  rcases Nat.eq_zero_or_pos F.card with h0 | hpos
  · rw [Finset.card_eq_zero.mp h0]; simp
  · have hc : (F.card : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr hpos.ne'
    set M : ℝ := (∑ j ∈ F, x j) / F.card with hM
    have hsum : ∑ j ∈ F, x j = F.card * M := by rw [hM]; field_simp
    have e1 : ∑ i ∈ F, (x i - m) ^ 2
        = (∑ i ∈ F, (x i) ^ 2) - 2 * m * (∑ i ∈ F, x i) + F.card * m ^ 2 := by
      simp only [sub_sq, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
        ← Finset.sum_mul, Finset.sum_const, nsmul_eq_mul]
      ring
    have e2 : ∑ i ∈ F, (x i - M) ^ 2
        = (∑ i ∈ F, (x i) ^ 2) - 2 * M * (∑ i ∈ F, x i) + F.card * M ^ 2 := by
      simp only [sub_sq, Finset.sum_add_distrib, Finset.sum_sub_distrib, ← Finset.mul_sum,
        ← Finset.sum_mul, Finset.sum_const, nsmul_eq_mul]
      ring
    rw [e1, e2, hsum]; ring

omit [Nonempty ι] in
/-- Summing over cells and then within cells is summing pointwise. -/
lemma sum_cellwise (g : ι → κ) (f : ι → ℝ) : ∑ k, ∑ i ∈ cell g k, f i = ∑ i, f i := by
  simpa [cell] using Finset.sum_fiberwise (Finset.univ : Finset ι) g f

omit [Nonempty ι] in
/-- The cell-dependent version: inside the cell labelled `k` the label may be read off
from the index. -/
lemma sum_cellwise_dep (g : ι → κ) (f : ι → κ → ℝ) :
    ∑ k, ∑ i ∈ cell g k, f i k = ∑ i, f i (g i) := by
  rw [← sum_cellwise g (fun i => f i (g i))]
  refine Finset.sum_congr rfl fun k _ => Finset.sum_congr rfl fun i hi => ?_
  have hk : g i = k := by simpa [cell] using hi
  rw [hk]

omit [Nonempty ι] in
/-- Summing a cell-indexed quantity over cells is the same as summing it pointwise. -/
lemma sum_over_cells (g : ι → κ) (F : κ → ℝ) :
    ∑ k, (cell g k).card * F k = ∑ i, F (g i) := by
  rw [← sum_cellwise_dep g (fun _ k => F k)]
  exact Finset.sum_congr rfl fun k _ => by
    rw [Finset.sum_const, nsmul_eq_mul]

omit [Nonempty ι] in
/-- **Conditional means are optimal.**  Replacing each observation by the mean of its dial
cell beats every other cell-measurable predictor `h`. -/
theorem conditional_mean_optimal (x : ι → ℝ) (g : ι → κ) (h : κ → ℝ) :
    ∑ i, (x i - cellMean x g (g i)) ^ 2 ≤ ∑ i, (x i - h (g i)) ^ 2 := by
  rw [← sum_cellwise_dep g (fun i k => (x i - cellMean x g k) ^ 2),
    ← sum_cellwise_dep g (fun i k => (x i - h k) ^ 2)]
  refine Finset.sum_le_sum fun k _ => ?_
  rw [sum_sq_dev_cell (cell g k) x (h k)]
  have hnn : (0:ℝ) ≤ (cell g k).card * ((∑ j ∈ cell g k, x j) / (cell g k).card - h k) ^ 2 := by
    positivity
  have hcm : cellMean x g k = (∑ j ∈ cell g k, x j) / (cell g k).card := rfl
  rw [hcm]
  linarith

/-- Within-cell (residual) variance of `x` given the dial partition. -/
noncomputable def withinVar (x : ι → ℝ) (g : ι → κ) : ℝ :=
  avg (fun i => (x i - cellMean x g (g i)) ^ 2)

/-- Between-cell (explained) variance of `x` given the dial partition. -/
noncomputable def betweenVar (x : ι → ℝ) (g : ι → κ) : ℝ :=
  avg (fun i => (cellMean x g (g i) - avg x) ^ 2)

omit [Fintype κ] in
lemma withinVar_nonneg (x : ι → ℝ) (g : ι → κ) : 0 ≤ withinVar x g :=
  avg_nonneg fun _ => sq_nonneg _

omit [Fintype κ] in
lemma betweenVar_nonneg (x : ι → ℝ) (g : ι → κ) : 0 ≤ betweenVar x g :=
  avg_nonneg fun _ => sq_nonneg _

omit [Nonempty ι] in
/-- **The ANOVA identity**: total variance splits exactly into within-cell and
between-cell parts. -/
theorem var_decomposition (x : ι → ℝ) (g : ι → κ) :
    var x = withinVar x g + betweenVar x g := by
  have hvar : var x = (∑ i, (x i - avg x) ^ 2) / (Fintype.card ι : ℝ) := by
    simp [var, cov, avg, sq]
  have hw : withinVar x g
      = (∑ i, (x i - cellMean x g (g i)) ^ 2) / (Fintype.card ι : ℝ) := rfl
  have hb : betweenVar x g
      = (∑ i, (cellMean x g (g i) - avg x) ^ 2) / (Fintype.card ι : ℝ) := rfl
  have hsplit : ∑ i, (x i - avg x) ^ 2
      = (∑ i, (x i - cellMean x g (g i)) ^ 2) + ∑ i, (cellMean x g (g i) - avg x) ^ 2 := by
    rw [← sum_cellwise_dep g (fun i k => (x i - cellMean x g k) ^ 2),
      ← sum_cellwise g (fun i => (x i - avg x) ^ 2),
      ← sum_over_cells g (fun k => (cellMean x g k - avg x) ^ 2), ← Finset.sum_add_distrib]
    refine Finset.sum_congr rfl fun k _ => ?_
    have hcm : cellMean x g k = (∑ j ∈ cell g k, x j) / (cell g k).card := rfl
    rw [hcm]
    exact sum_sq_dev_cell (cell g k) x (avg x)
  rw [hvar, hw, hb, hsplit, add_div]

/-- The explained-variance fraction (correlation ratio) `η²` of the dial partition. -/
noncomputable def etaSq (x : ι → ℝ) (g : ι → κ) : ℝ := betweenVar x g / var x

/-- The between-cell variance dominates the squared covariance with any dial that is
constant on cells. -/
lemma betweenVar_ge_cov_sq (y s : ι → ℝ) (g : ι → κ) (phi : κ → ℝ)
    (hs : ∀ i, s i = phi (g i)) (hsv : 0 < var s) :
    (cov y s) ^ 2 / var s ≤ betweenVar y g := by
  have hcard : (0:ℝ) < (Fintype.card ι : ℝ) := by
    have := Fintype.card_pos (α := ι); positivity
  set b : ℝ := cov y s / var s with hbdef
  set a : ℝ := avg y - b * avg s with hadef
  have hopt := conditional_mean_optimal y g (fun k => b * phi k + a)
  have hmse : mse y s a b
      = (∑ i, (y i - (b * phi (g i) + a)) ^ 2) / (Fintype.card ι : ℝ) := by
    rw [mse, avg]
    refine congrArg (fun t => t / (Fintype.card ι : ℝ)) (Finset.sum_congr rfl fun i _ => ?_)
    rw [hs i]; ring_nf
  have hwithin : withinVar y g
      = (∑ i, (y i - cellMean y g (g i)) ^ 2) / (Fintype.card ι : ℝ) := rfl
  have hle : withinVar y g ≤ mse y s a b := by
    rw [hwithin, hmse]
    gcongr
  rw [hadef, hbdef, mse_ols_eq y s hsv] at hle
  have hdec := var_decomposition y g
  linarith

/-- **`r² ≤ η²`**: an affine dial fit can never beat conditioning on the dial's level sets.
Here `s = φ ∘ g` says that the dial `s` is constant on the cells of `g`. -/
theorem corr_sq_le_eta_sq (y s : ι → ℝ) (g : ι → κ) (phi : κ → ℝ)
    (hs : ∀ i, s i = phi (g i)) (hy : 0 < var y) (hsv : 0 < var s) :
    corrSq y s ≤ etaSq y g := by
  have hkey := betweenVar_ge_cov_sq y s g phi hs hsv
  have hsplit : (cov y s) ^ 2 / (var y * var s) = ((cov y s) ^ 2 / var s) / var y := by
    rw [mul_comm, ← div_div]
  rw [corrSq, etaSq, hsplit]
  gcongr

/-! ## Dispersion: what a dial can and cannot remove -/

/-- Residual (within-cell) dispersion index after conditioning on the dial. -/
noncomputable def dispWithin (x : ι → ℝ) (g : ι → κ) : ℝ := withinVar x g / avg x

omit [Nonempty ι] in
/-- **Dispersion reduction equals the explained-variance fraction.**  The two legs of the
pre-registered H1 test measure the same quantity `η²`. -/
theorem disp_reduction_eq_eta_sq (x : ι → ℝ) (g : ι → κ) (hx : 0 < avg x) (hv : 0 < var x) :
    (disp x - dispWithin x g) / disp x = etaSq x g := by
  have hdec := var_decomposition x g
  rw [disp, dispWithin, etaSq]
  field_simp
  linarith

omit [Nonempty ι] in
/-- Under Poisson calibration inside each dial cell, the dispersion index is
`1 + betweenVar / mean`: all overdispersion is between-cell heterogeneity. -/
theorem poisson_mixture_disp (x : ι → ℝ) (g : ι → κ) (hx : 0 < avg x)
    (hpois : withinVar x g = avg x) :
    disp x = 1 + betweenVar x g / avg x := by
  rw [disp, var_decomposition x g, hpois, add_div, div_self hx.ne']

omit [Nonempty ι] in
/-- **Residual dispersion floor.**  A dial with explained fraction at most `e` leaves at
least the fraction `1 − e` of the raw dispersion. -/
theorem dispWithin_lower_bound (x : ι → ℝ) (g : ι → κ) (hx : 0 < avg x) (hv : 0 < var x)
    {e : ℝ} (he : etaSq x g ≤ e) :
    (1 - e) * disp x ≤ dispWithin x g := by
  have hdec := var_decomposition x g
  have hbe : betweenVar x g ≤ e * var x := by
    rw [etaSq, div_le_iff₀ hv] at he; linarith
  have key : (1 - e) * var x ≤ withinVar x g := by linarith
  calc (1 - e) * disp x = ((1 - e) * var x) / avg x := by rw [disp]; ring
    _ ≤ withinVar x g / avg x := by gcongr
    _ = dispWithin x g := rfl

/-! ## Certified numeric readings of exp 576 -/

omit [Nonempty ι] in
/-- **exp 576, primary reading.**  With raw dispersion `D_raw = 7.27` and a dial explaining
at most `η² = 0.1422` of the variance (the best of the three measured dials, the
mechanistic product-form `S_prod`), the residual dispersion is still at least `6.23`. -/
theorem exp576_residual_dispersion (x : ι → ℝ) (g : ι → κ) (hx : 0 < avg x) (hv : 0 < var x)
    (hD : disp x = 727 / 100) (he : etaSq x g ≤ 1422 / 10000) :
    623 / 100 ≤ dispWithin x g := by
  have h := dispWithin_lower_bound x g hx hv he
  rw [hD] at h
  linarith

omit [Nonempty ι] in
/-- **exp 576, excess reading.**  Under Poisson calibration the excess dispersion
`D − 1 = 6.27` is heterogeneity; the dial removes at most `17%` of it, so at least `83%`
of the Poisson excess is `N`-structure the dial does not see.  This is far below the
pre-registered H1 bar of a `30%` dispersion reduction. -/
theorem exp576_unexplained_excess_fraction (x : ι → ℝ) (g : ι → κ) (hx : 0 < avg x)
    (hv : 0 < var x) (hD : disp x = 727 / 100) (he : etaSq x g ≤ 1422 / 10000) :
    (83 / 100) * (disp x - 1) ≤ dispWithin x g - 1 := by
  have h := dispWithin_lower_bound x g hx hv he
  rw [hD] at h ⊢
  linarith

omit [Nonempty ι] in
/-- **The H1 bar is missed structurally.**  If the dial's explained fraction is below the
`30%` bar then no recalibration — affine or cell-wise — attains a `30%` dispersion
reduction; the residual dispersion index stays above `0.70 · D_raw`. -/
theorem h1_bar_missed (x : ι → ℝ) (g : ι → κ) (hx : 0 < avg x) (hv : 0 < var x)
    (he : etaSq x g < 3 / 10) :
    (7 / 10) * disp x < dispWithin x g := by
  have hdec := var_decomposition x g
  have hbe : betweenVar x g < (3 / 10) * var x := by
    rw [etaSq, div_lt_iff₀ hv] at he; linarith
  have key : (7 / 10) * var x < withinVar x g := by linarith
  calc (7 / 10) * disp x = ((7 / 10) * var x) / avg x := by rw [disp]; ring
    _ < withinVar x g / avg x := by gcongr
    _ = dispWithin x g := rfl

end Logic.QRDial