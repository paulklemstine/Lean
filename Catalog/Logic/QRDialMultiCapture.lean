/-
# The capture ceiling of a whole orthogonal family of dials

The named follow-up of exp 576 is a product-form dial over *all* primes `ℓ ≤ 10⁶`
(~78k Legendre symbols) rather than the `ℓ ≤ 100` / `ℓ ≤ 400` windows already tested.
This file supplies the decision rule that such an experiment has to meet, in the form of an
exact finite-sample theorem rather than a fitted number.

For a finite family of dials `s : κ → ι → ℝ` that are pairwise uncorrelated across the
sample (which is what the independent-character model predicts for distinct primes, and
what `Logic.QRDial.cov_Sindiv_Sprod_eq_zero` proves for the two dials of exp 576), the
least-squares residual of the *joint* affine recalibration
`y ≈ a + Σ_j b_j · s_j` obeys

`mseFamily y s a b ≥ var y − Σ_j cov(y, s_j)² / var s_j`

(`Logic.QRDial.family_capture_bound`), with equality at the coordinatewise OLS
coefficients (`Logic.QRDial.family_capture_bound_tight`).  Consequently the total explained
fraction of an orthogonal family is the *sum of the individual squared correlations*, so
the pre-registered H1 bar (`30%`) can only be met if `Σ_j r_j² ≥ 0.30`
(`Logic.QRDial.family_bar_missed`).

Applied to the recorded exp-576 dials — `r² = 0.0127` and `r² = 0.0781`, which are
orthogonal by `cov_Sindiv_Sprod_eq_zero` — the family bound gives at most `9.1%`, and any
extension of the family to more primes must supply, in aggregate, more than `0.30` of
squared correlation to change the verdict.  That is a sharp, falsifiable target for the
`ℓ ≤ 10⁶` follow-up.

The technical core is the bilinearity of the sample covariance over finite sums
(`Logic.QRDial.cov_sum_left`), from which the exact quadratic expansion
`Logic.QRDial.mseFamily_expand` follows.
-/
import Mathlib
import Logic.QRDialDispersionLaws

open Finset

namespace Logic.QRDial

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-! ## Bilinearity of the sample covariance -/

omit [Nonempty ι] in
lemma avg_sub (x y : ι → ℝ) : avg (fun i => x i - y i) = avg x - avg y := by
  have h : (fun i => x i - y i) = fun i => x i + (-1) * y i := by funext i; ring
  rw [h, avg_add, avg_mul_left]; ring

omit [Nonempty ι] in
/-- The sample average is additive over a finite sum. -/
lemma avg_sum {κ : Type*} [DecidableEq κ] (t : Finset κ) (f : κ → ι → ℝ) :
    avg (fun i => ∑ j ∈ t, f j i) = ∑ j ∈ t, avg (f j) := by
  classical
  induction t using Finset.induction with
  | empty => simp [avg]
  | insert a t ha ih =>
      have hfun : (fun i => ∑ j ∈ insert a t, f j i) = fun i => f a i + ∑ j ∈ t, f j i := by
        funext i; rw [Finset.sum_insert ha]
      rw [hfun, avg_add, ih, Finset.sum_insert ha]

lemma cov_add_left (x y z : ι → ℝ) :
    cov (fun i => x i + y i) z = cov x z + cov y z := by
  have h : (fun i => (x i + y i) * z i) = fun i => x i * z i + y i * z i := by
    funext i; ring
  rw [cov_eq, cov_eq, cov_eq, h]
  simp only [avg_add]
  ring

lemma cov_smul_left (c : ℝ) (x z : ι → ℝ) :
    cov (fun i => c * x i) z = c * cov x z := by
  have h : (fun i => c * x i * z i) = fun i => c * (x i * z i) := by funext i; ring
  rw [cov_eq, cov_eq, h]
  simp only [avg_mul_left]
  ring

lemma cov_smul_right (c : ℝ) (x z : ι → ℝ) :
    cov x (fun i => c * z i) = c * cov x z := by
  rw [cov_comm, cov_smul_left, cov_comm]

lemma cov_sub_left (x y z : ι → ℝ) :
    cov (fun i => x i - y i) z = cov x z - cov y z := by
  have h : (fun i => x i - y i) = fun i => x i + (-1) * y i := by funext i; ring
  rw [h, cov_add_left, cov_smul_left]; ring

lemma cov_sub_right (x y z : ι → ℝ) :
    cov x (fun i => y i - z i) = cov x y - cov x z := by
  rw [cov_comm, cov_sub_left, cov_comm y x, cov_comm z x]

lemma cov_zero_left (z : ι → ℝ) : cov (fun _ => (0:ℝ)) z = 0 := by
  rw [cov_eq]
  simp

/-- The sample covariance is additive over a finite sum in its first argument. -/
lemma cov_sum_left {κ : Type*} [DecidableEq κ] (t : Finset κ) (f : κ → ι → ℝ) (z : ι → ℝ) :
    cov (fun i => ∑ j ∈ t, f j i) z = ∑ j ∈ t, cov (f j) z := by
  classical
  induction t using Finset.induction with
  | empty => simpa using cov_zero_left z
  | insert a t ha ih =>
      have hfun : (fun i => ∑ j ∈ insert a t, f j i) = fun i => f a i + ∑ j ∈ t, f j i := by
        funext i; rw [Finset.sum_insert ha]
      rw [hfun, cov_add_left, ih, Finset.sum_insert ha]

lemma cov_sum_right {κ : Type*} [DecidableEq κ] (t : Finset κ) (f : κ → ι → ℝ) (z : ι → ℝ) :
    cov z (fun i => ∑ j ∈ t, f j i) = ∑ j ∈ t, cov z (f j) := by
  rw [cov_comm, cov_sum_left]
  exact Finset.sum_congr rfl fun j _ => cov_comm (f j) z

/-- Squared error around an arbitrary centre splits into variance plus offset. -/
lemma avg_sq_sub_eq (u : ι → ℝ) (a : ℝ) :
    avg (fun i => (u i - a) ^ 2) = var u + (avg u - a) ^ 2 := by
  have h : (fun i => (u i - a) ^ 2)
      = fun i => (u i * u i) + ((-2 * a) * u i + a ^ 2) := by
    funext i; ring
  rw [h]
  simp only [avg_add, avg_mul_left, avg_const]
  rw [var_eq]
  ring

/-! ## The joint recalibration of a family of dials -/

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

/-- Mean squared error of the joint affine recalibration `y ≈ a + Σ_j b_j · s_j`. -/
noncomputable def mseFamily (y : ι → ℝ) (s : κ → ι → ℝ) (a : ℝ) (b : κ → ℝ) : ℝ :=
  avg (fun i => (y i - (a + ∑ j, b j * s j i)) ^ 2)

/-- Exact quadratic expansion of the family recalibration error. -/
lemma mseFamily_expand (y : ι → ℝ) (s : κ → ι → ℝ) (a : ℝ) (b : κ → ℝ) :
    mseFamily y s a b
      = var y - 2 * (∑ j, b j * cov y (s j))
        + (∑ j, ∑ l, b j * b l * cov (s j) (s l))
        + (avg y - a - ∑ j, b j * avg (s j)) ^ 2 := by
  classical
  set S : ι → ℝ := fun i => ∑ j, b j * s j i with hS
  have hmse : mseFamily y s a b = avg (fun i => ((y i - S i) - a) ^ 2) := by
    rw [mseFamily]
    exact congrArg avg (funext fun i => by rw [hS]; ring_nf)
  have havgS : avg S = ∑ j, b j * avg (s j) := by
    rw [hS, avg_sum]
    exact Finset.sum_congr rfl fun j _ => avg_mul_left _ _
  have hcovyS : cov y S = ∑ j, b j * cov y (s j) := by
    rw [hS, cov_sum_right]
    exact Finset.sum_congr rfl fun j _ => cov_smul_right _ _ _
  have hvarS : var S = ∑ j, ∑ l, b j * b l * cov (s j) (s l) := by
    rw [var, hS, cov_sum_left]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [cov_smul_left, cov_sum_right, Finset.mul_sum]
    exact Finset.sum_congr rfl fun l _ => by rw [cov_smul_right]; ring
  have hvaru : var (fun i => y i - S i) = var y - 2 * cov y S + var S := by
    rw [var, cov_sub_left, cov_sub_right, cov_sub_right, ← var, ← var, cov_comm S y]
    ring
  rw [hmse, avg_sq_sub_eq, hvaru, hcovyS, hvarS, avg_sub, havgS]
  ring

/-- **Capture ceiling for an orthogonal family of dials.**  If the dials are pairwise
uncorrelated, no joint affine recalibration can push the residual below
`var y − Σ_j cov(y, s_j)² / var s_j`. -/
theorem family_capture_bound (y : ι → ℝ) (s : κ → ι → ℝ) (hs : ∀ j, 0 < var (s j))
    (horth : ∀ j l, j ≠ l → cov (s j) (s l) = 0) (a : ℝ) (b : κ → ℝ) :
    var y - ∑ j, (cov y (s j)) ^ 2 / var (s j) ≤ mseFamily y s a b := by
  classical
  rw [mseFamily_expand]
  have hdiag : ∑ j, ∑ l, b j * b l * cov (s j) (s l)
      = ∑ j, (b j) ^ 2 * var (s j) := by
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [Finset.sum_eq_single j]
    · rw [var]; ring
    · intro l _ hl
      rw [horth j l (Ne.symm hl), mul_zero]
    · intro hj; exact absurd (Finset.mem_univ j) hj
  rw [hdiag]
  have hterm : ∀ j : κ, - ((cov y (s j)) ^ 2 / var (s j))
      ≤ -2 * (b j * cov y (s j)) + (b j) ^ 2 * var (s j) := by
    intro j
    have h1 : 0 ≤ (cov y (s j) - b j * var (s j)) ^ 2 / var (s j) :=
      div_nonneg (sq_nonneg _) (hs j).le
    have h2 : (cov y (s j) - b j * var (s j)) ^ 2 / var (s j)
        = (cov y (s j)) ^ 2 / var (s j) - 2 * (b j * cov y (s j)) + (b j) ^ 2 * var (s j) := by
      field_simp [(hs j).ne']; ring
    rw [h2] at h1
    linarith
  have hsum : ∑ j, (- ((cov y (s j)) ^ 2 / var (s j)))
      ≤ ∑ j, (-2 * (b j * cov y (s j)) + (b j) ^ 2 * var (s j)) :=
    Finset.sum_le_sum fun j _ => hterm j
  have hL : ∑ j, (- ((cov y (s j)) ^ 2 / var (s j)))
      = -∑ j, (cov y (s j)) ^ 2 / var (s j) := by
    rw [← Finset.sum_neg_distrib]
  have hR : ∑ j, (-2 * (b j * cov y (s j)) + (b j) ^ 2 * var (s j))
      = -2 * (∑ j, b j * cov y (s j)) + ∑ j, (b j) ^ 2 * var (s j) := by
    rw [Finset.sum_add_distrib, ← Finset.mul_sum]
  rw [hL, hR] at hsum
  nlinarith [hsum, sq_nonneg (avg y - a - ∑ j, b j * avg (s j))]

/-- The family bound is attained: coordinatewise OLS achieves it exactly. -/
theorem family_capture_bound_tight (y : ι → ℝ) (s : κ → ι → ℝ) (hs : ∀ j, 0 < var (s j))
    (horth : ∀ j l, j ≠ l → cov (s j) (s l) = 0) :
    mseFamily y s (avg y - ∑ j, (cov y (s j) / var (s j)) * avg (s j))
        (fun j => cov y (s j) / var (s j))
      = var y - ∑ j, (cov y (s j)) ^ 2 / var (s j) := by
  classical
  rw [mseFamily_expand]
  have hdiag : ∑ j, ∑ l, (cov y (s j) / var (s j)) * (cov y (s l) / var (s l))
        * cov (s j) (s l)
      = ∑ j, (cov y (s j)) ^ 2 / var (s j) := by
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [Finset.sum_eq_single j]
    · rw [← var]
      field_simp [(hs j).ne']
    · intro l _ hl
      rw [horth j l (Ne.symm hl), mul_zero]
    · intro hj; exact absurd (Finset.mem_univ j) hj
  have hlin : ∑ j, (cov y (s j) / var (s j)) * cov y (s j)
      = ∑ j, (cov y (s j)) ^ 2 / var (s j) :=
    Finset.sum_congr rfl fun j _ => by field_simp [(hs j).ne']
  rw [hdiag, hlin]
  ring

/-- **The H1 bar for a whole dial family.**  If the total squared correlation of an
orthogonal family stays below the `30%` bar, then every joint affine recalibration leaves
more than `70%` of the variance of the target in the residual: no enlargement of the family
can rescue H1 unless it contributes, in aggregate, more than `0.30` of squared
correlation. -/
theorem family_bar_missed (y : ι → ℝ) (s : κ → ι → ℝ) (hy : 0 < var y)
    (hs : ∀ j, 0 < var (s j)) (horth : ∀ j l, j ≠ l → cov (s j) (s l) = 0)
    (hbar : ∑ j, corrSq y (s j) < 3 / 10) (a : ℝ) (b : κ → ℝ) :
    (7 / 10) * var y < mseFamily y s a b := by
  classical
  have hkey := family_capture_bound y s hs horth a b
  have hrw : ∑ j, (cov y (s j)) ^ 2 / var (s j) = (∑ j, corrSq y (s j)) * var y := by
    rw [Finset.sum_mul]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [corrSq]
    field_simp [(hs j).ne', hy.ne']
  rw [hrw] at hkey
  nlinarith [hkey, hbar, hy]

/-- **exp 576, family reading.**  The two recorded dials are orthogonal
(`cov_Sindiv_Sprod_eq_zero`) with squared correlations `0.0127` and `0.0781`; treated as a
family they explain at most `9.08%`, so the residual keeps more than `90%` of the
variance. -/
theorem exp576_family_reading (y : ι → ℝ) (s : κ → ι → ℝ) (hy : 0 < var y)
    (hs : ∀ j, 0 < var (s j)) (horth : ∀ j l, j ≠ l → cov (s j) (s l) = 0)
    (hbar : ∑ j, corrSq y (s j) ≤ 908 / 10000) (a : ℝ) (b : κ → ℝ) :
    (9092 / 10000) * var y ≤ mseFamily y s a b := by
  classical
  have hkey := family_capture_bound y s hs horth a b
  have hrw : ∑ j, (cov y (s j)) ^ 2 / var (s j) = (∑ j, corrSq y (s j)) * var y := by
    rw [Finset.sum_mul]
    refine Finset.sum_congr rfl fun j _ => ?_
    rw [corrSq]
    field_simp [(hs j).ne', hy.ne']
  rw [hrw] at hkey
  nlinarith [hkey, hbar, hy.le]

end Logic.QRDial