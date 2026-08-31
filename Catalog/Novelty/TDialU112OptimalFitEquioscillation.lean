import Mathlib
import Probability.TDialU116ReboundFloor
import Novelty.TDialU112FadeReacceleration

/-!
# The optimal single-`λ` model of the U112 ladder: equioscillation, and an exact minimal noise

## Research context (FACT round-70 #1, exp 545, third cycle)

`Novelty.TDialU112FadeReacceleration` proved a *lower* bound on the noise of any single-`(L, λ)`
affine fade reproducing the five recorded rungs `0.5739 → 0.5436 → 0.5005 → 0.4880 → 0.4621`:

```
η ≥ 73943/7340000 = 0.0100739782…
```

obtained by eliminating `λ` between two step ratios.  A lower bound alone leaves the natural
question open: **is it attained?**  If the bound were loose, the "fade model needs a lot of
noise" reading would be an artefact of a crude elimination rather than a property of the data.

This cycle closes the gap.  The bound is exactly attained, by a model whose residuals
*equioscillate*: `+η, −η, +η` at the first three rungs.  That is the classical Chebyshev
alternation signature for a two-parameter linear fit, and it is what certifies optimality.

## Main results

### 1. General theory: alternation certifies optimality (Section 1)

* `affine_of_param_diff` — the residual of a ladder against parameters `(L, λ)` changes by an
  *affine function of the rung value* when the parameters change:
  `t_k − s_k = A + B ρ_k`.  Two-parameter fade fitting is a linear Chebyshev problem in
  disguise.
* `alternation_forces_noise` — **the alternation theorem.**  If some `(L', λ')` produces
  residuals `+η, −η, +η` at three consecutive strictly declining rungs, then *no* parameter
  pair produces residuals all of modulus `< η`.  The proof is the sign argument of Chebyshev
  alternation: an affine function cannot be negative, positive, negative along a monotone
  triple.
* `noisyFade_eta_ge_of_alternation` — restated for the catalog's `NoisyFade` predicate: an
  equioscillating triple is a certificate that the noise level of *every* noisy affine fade is
  at least `η`.

### 2. The U112 optimum (Sections 2–3)

* `u112_residual_zero`, `u112_residual_one`, `u112_residual_two`, `u112_residual_three` —
  with `λ* = 278/367` and `L* = 725197/1780000` the four residuals of the recorded ladder are
  exactly `+η*, −η*, +η*, −46663/7340000`.  Three alternations, as required.
* `rhoStar_isNoisyFade` — the explicit ladder `ρ*` (recorded rungs, continued by the exact
  affine rule) is a genuine `NoisyFade L* λ* η*`, so the noise level `η*` is *achieved*.
* `u112_minimal_noise_exact` — **the sharp statement**: the recorded ladder admits a
  single-`(L, λ)` affine model with noise `η* = 73943/7340000` and admits none with less.  The
  minimal noise of the U112 record is therefore *exactly* `0.0100739782…`.
* `u112_optimal_lambda_contractive`, `u112_optimal_floor_below_band` — the optimal ratio
  `λ* = 278/367 ≈ 0.7575` is contractive, and the optimal floor `L* ≈ 0.40741` lies far below
  the pre-registered band floor `0.55`.  Unconditionally now: no assumption on `λ` or `η` is
  needed, because both are determined by the data.
* `u112_optimal_floor_below_all_rungs` — the optimal floor lies below every recorded rung, so
  the best-fitting fade model predicts continued decline, in agreement with the recorded U120
  rung `0.43636` and against the U116 rebound.

## Lab notes (exp 545, optimal fit)

```
optimal ratio   λ* = 278/367        = 0.7574932…
optimal floor   L* = 725197/1780000 = 0.4074140…
minimal noise   η* = 73943/7340000  = 0.0100739782…
residuals       +η*, −η*, +η*, −46663/7340000   (equioscillation, 3 alternations)
band floor      0.55                (L* is 0.1426 below it)
```
-/

open Catalog.Probability.TDialU116ReboundFloor
open Catalog.Novelty.TDialU112FadeReacceleration

namespace Catalog.Novelty.TDialU112OptimalFitEquioscillation

/-! ## 1. Alternation certifies optimality -/

/-- The residual of a ladder rung against the parameters `(L, λ)`. -/
def residual (rho : ℕ → ℝ) (L lam : ℝ) (k : ℕ) : ℝ :=
  rho (k + 1) - (L + lam * (rho k - L))

/-- **Changing the parameters changes the residual by an affine function of the rung.**  This
is why fitting a fade is a linear Chebyshev approximation problem: the two-parameter family of
residual corrections is the two-dimensional space of affine functions of `ρ`. -/
theorem affine_of_param_diff (rho : ℕ → ℝ) (L lam L' lam' : ℝ) (k : ℕ) :
    residual rho L lam k - residual rho L' lam' k
      = (L' * (1 - lam') - L * (1 - lam)) + (lam' - lam) * rho k := by
  simp only [residual]
  ring

/-- **The alternation theorem.**  If one parameter pair produces residuals `+η, −η, +η` at
three consecutive strictly declining rungs, then no parameter pair produces residuals of
modulus `< η` at all three.  Equioscillation is a certificate of Chebyshev optimality. -/
theorem alternation_forces_noise {rho : ℕ → ℝ} {L' lam' eta : ℝ} {k : ℕ}
    (hmono1 : rho (k + 1) < rho k) (hmono2 : rho (k + 2) < rho (k + 1))
    (h0 : residual rho L' lam' k = eta)
    (h1 : residual rho L' lam' (k + 1) = -eta)
    (h2 : residual rho L' lam' (k + 2) = eta)
    {L lam : ℝ}
    (hb0 : |residual rho L lam k| < eta)
    (hb1 : |residual rho L lam (k + 1)| < eta)
    (hb2 : |residual rho L lam (k + 2)| < eta) : False := by
  set A := L' * (1 - lam') - L * (1 - lam) with hA
  set B := lam' - lam with hB
  have e0 := affine_of_param_diff rho L lam L' lam' k
  have e1 := affine_of_param_diff rho L lam L' lam' (k + 1)
  have e2 := affine_of_param_diff rho L lam L' lam' (k + 2)
  rw [h0] at e0
  rw [h1] at e1
  rw [h2] at e2
  have g0 : A + B * rho k < 0 := by
    have := (abs_lt.mp hb0).2
    linarith [e0]
  have g1 : 0 < A + B * rho (k + 1) := by
    have := (abs_lt.mp hb1).1
    linarith [e1]
  have g2 : A + B * rho (k + 2) < 0 := by
    have := (abs_lt.mp hb2).2
    linarith [e2]
  -- an affine function cannot be `< 0`, `> 0`, `< 0` along a strictly decreasing triple
  have hBneg : B < 0 := by
    by_contra hcon
    push_neg at hcon
    have : B * rho (k + 1) ≤ B * rho k := by
      exact mul_le_mul_of_nonneg_left hmono1.le hcon
    linarith
  have hBpos : 0 < B := by
    by_contra hcon
    push_neg at hcon
    have : B * rho (k + 1) ≤ B * rho (k + 2) :=
      mul_le_mul_of_nonpos_left hmono2.le hcon
    linarith
  linarith

/-- The alternation certificate in the catalog's `NoisyFade` language: an equioscillating
triple forces every noisy affine fade of the same ladder to carry noise at least `η`. -/
theorem noisyFade_eta_ge_of_alternation {rho : ℕ → ℝ} {L' lam' eta : ℝ} {k : ℕ}
    (hmono1 : rho (k + 1) < rho k) (hmono2 : rho (k + 2) < rho (k + 1))
    (h0 : residual rho L' lam' k = eta)
    (h1 : residual rho L' lam' (k + 1) = -eta)
    (h2 : residual rho L' lam' (k + 2) = eta)
    {L lam eta2 : ℝ} (hfit : NoisyFade L lam eta2 rho) :
    eta ≤ eta2 := by
  by_contra hcon
  push_neg at hcon
  refine alternation_forces_noise hmono1 hmono2 h0 h1 h2
    (L := L) (lam := lam) ?_ ?_ ?_
  · exact lt_of_le_of_lt (hfit k) hcon
  · exact lt_of_le_of_lt (hfit (k + 1)) hcon
  · exact lt_of_le_of_lt (hfit (k + 2)) hcon

/-! ## 2. The optimal parameters for the U112 ladder -/

/-- The optimal fade ratio for the recorded U96…U112 ladder. -/
noncomputable def lamStar : ℝ := 278 / 367

/-- The optimal floor for the recorded U96…U112 ladder. -/
noncomputable def floorStar : ℝ := 725197 / 1780000

/-- The minimal noise level of the recorded U96…U112 ladder. -/
noncomputable def etaStar : ℝ := 73943 / 7340000

/-- The optimal ladder: the recorded rungs, continued past U112 by the exact affine rule. -/
noncomputable def rhoStar : ℕ → ℝ
  | 0 => 5739 / 10000
  | 1 => 5436 / 10000
  | 2 => 5005 / 10000
  | 3 => 4880 / 10000
  | (n + 4) => floorStar + lamStar ^ n * (4621 / 10000 - floorStar)

lemma rhoStar_zero : rhoStar 0 = (rungU96 : ℝ) := by norm_num [rhoStar, rungU96]
lemma rhoStar_one : rhoStar 1 = (rungU100 : ℝ) := by norm_num [rhoStar, rungU100]
lemma rhoStar_two : rhoStar 2 = (rungU104 : ℝ) := by norm_num [rhoStar, rungU104]
lemma rhoStar_three : rhoStar 3 = (rungU108 : ℝ) := by norm_num [rhoStar, rungU108]

lemma rhoStar_four : rhoStar 4 = (rungU112 : ℝ) := by
  show floorStar + lamStar ^ 0 * (4621 / 10000 - floorStar) = (rungU112 : ℝ)
  norm_num [rungU112]

lemma rhoStar_succ_four (n : ℕ) :
    rhoStar (n + 5) = floorStar + lamStar * (rhoStar (n + 4) - floorStar) := by
  show floorStar + lamStar ^ (n + 1) * (4621 / 10000 - floorStar)
      = floorStar + lamStar * ((floorStar + lamStar ^ n * (4621 / 10000 - floorStar))
        - floorStar)
  ring

/-- The ladder declines strictly across the first three recorded rungs. -/
lemma rhoStar_decl_zero : rhoStar 1 < rhoStar 0 := by norm_num [rhoStar]
lemma rhoStar_decl_one : rhoStar 2 < rhoStar 1 := by norm_num [rhoStar]
lemma rhoStar_decl_two : rhoStar 3 < rhoStar 2 := by norm_num [rhoStar]

/-! ### The four residuals: `+η*, −η*, +η*, −0.006357` -/

theorem u112_residual_zero : residual rhoStar floorStar lamStar 0 = etaStar := by
  show rhoStar 1 - (floorStar + lamStar * (rhoStar 0 - floorStar)) = etaStar
  norm_num [rhoStar, floorStar, lamStar, etaStar]

theorem u112_residual_one : residual rhoStar floorStar lamStar 1 = -etaStar := by
  show rhoStar 2 - (floorStar + lamStar * (rhoStar 1 - floorStar)) = -etaStar
  norm_num [rhoStar, floorStar, lamStar, etaStar]

theorem u112_residual_two : residual rhoStar floorStar lamStar 2 = etaStar := by
  show rhoStar 3 - (floorStar + lamStar * (rhoStar 2 - floorStar)) = etaStar
  norm_num [rhoStar, floorStar, lamStar, etaStar]

theorem u112_residual_three :
    residual rhoStar floorStar lamStar 3 = -(46663 / 7340000) := by
  show rhoStar 4 - (floorStar + lamStar * (rhoStar 3 - floorStar)) = -(46663 / 7340000)
  rw [rhoStar_four]
  norm_num [rhoStar, floorStar, lamStar, rungU112]

/-- **The optimal fit equioscillates.**  Three sign alternations of equal magnitude `η*` — the
Chebyshev signature for a two-parameter fit. -/
theorem u112_equioscillation :
    residual rhoStar floorStar lamStar 0 = etaStar ∧
      residual rhoStar floorStar lamStar 1 = -etaStar ∧
      residual rhoStar floorStar lamStar 2 = etaStar :=
  ⟨u112_residual_zero, u112_residual_one, u112_residual_two⟩

/-! ## 3. The minimal noise of the U112 record is exactly `η*` -/

/-- The explicit optimal ladder really is a noisy affine fade at level `η*`. -/
theorem rhoStar_isNoisyFade : NoisyFade floorStar lamStar etaStar rhoStar := by
  intro k
  match k with
  | 0 =>
      rw [show rhoStar 1 - (floorStar + lamStar * (rhoStar 0 - floorStar))
        = residual rhoStar floorStar lamStar 0 from rfl, u112_residual_zero,
        abs_of_nonneg (by norm_num [etaStar])]
  | 1 =>
      rw [show rhoStar 2 - (floorStar + lamStar * (rhoStar 1 - floorStar))
        = residual rhoStar floorStar lamStar 1 from rfl, u112_residual_one,
        abs_neg, abs_of_nonneg (by norm_num [etaStar])]
  | 2 =>
      rw [show rhoStar 3 - (floorStar + lamStar * (rhoStar 2 - floorStar))
        = residual rhoStar floorStar lamStar 2 from rfl, u112_residual_two,
        abs_of_nonneg (by norm_num [etaStar])]
  | 3 =>
      rw [show rhoStar 4 - (floorStar + lamStar * (rhoStar 3 - floorStar))
        = residual rhoStar floorStar lamStar 3 from rfl, u112_residual_three,
        abs_neg, abs_of_nonneg (by norm_num)]
      norm_num [etaStar]
  | (n + 4) =>
      rw [rhoStar_succ_four n]
      simp only [sub_self, abs_zero]
      norm_num [etaStar]

/-- Every noisy affine fade of the recorded ladder carries noise at least `η*`, by the
alternation certificate.  (An independent route to `u112_noise_floor`, from optimality theory
rather than from ratio elimination — the two agree exactly, so neither is loose.) -/
theorem u112_noise_floor_by_alternation {L lam eta : ℝ} (hfit : NoisyFade L lam eta rhoStar) :
    etaStar ≤ eta :=
  noisyFade_eta_ge_of_alternation rhoStar_decl_zero rhoStar_decl_one
    u112_residual_zero u112_residual_one u112_residual_two hfit

/-- **The minimal noise of the U112 record, exactly.**  The recorded ladder
`0.5739 → 0.5436 → 0.5005 → 0.4880 → 0.4621` admits a single-`(L, λ)` affine model with noise
`η* = 73943/7340000` and no model with less.  The lower bound of the previous cycle is
therefore attained: `0.0100739782…` is the true noise content of the record, not an artefact
of the elimination used to bound it. -/
theorem u112_minimal_noise_exact :
    NoisyFade floorStar lamStar etaStar rhoStar ∧
      (∀ L lam eta : ℝ, NoisyFade L lam eta rhoStar → etaStar ≤ eta) :=
  ⟨rhoStar_isNoisyFade, fun _ _ _ hfit => u112_noise_floor_by_alternation hfit⟩

/-- The optimal ratio is contractive: the best single-`λ` reading of the U112 record is a
genuine fade, not the expansive local fit of the last three rungs. -/
theorem u112_optimal_lambda_contractive : 0 < lamStar ∧ lamStar < 1 := by
  constructor <;> norm_num [lamStar]

/-- **The optimal floor is far below the band.**  Unconditionally — no assumption on `λ` or on
the noise level — the best-fitting fade of the recorded ladder has floor
`L* = 725197/1780000 ≈ 0.40741`, which is `0.1426` below the pre-registered floor `0.55`. -/
theorem u112_optimal_floor_below_band : floorStar < (bandFloor : ℝ) := by
  norm_num [floorStar, bandFloor]

/-- The optimal floor lies below every recorded rung, including the later U116 and U120
readings: the best-fitting model predicts continued decline. -/
theorem u112_optimal_floor_below_all_rungs :
    floorStar < (rungU112 : ℝ) ∧ floorStar < (rungU116 : ℝ) ∧
      floorStar < (43636 / 100000 : ℝ) := by
  refine ⟨by norm_num [floorStar, rungU112], by norm_num [floorStar, rungU116], ?_⟩
  norm_num [floorStar]

/-- The optimal model's own prediction for the rung after U112, `L* + λ*(ρ₄ − L*)`, and its
error against the recorded U116 value `0.4847`.  The optimal fade model *undershoots* by
`10529/293600 ≈ 0.0359` — less than half the error of the expansive three-rung fit of the
previous cycle (`0.0763`), but still more than three times the minimal noise: the rebound is
genuinely outside the single-`λ` model class. -/
theorem u112_optimal_prediction_error :
    (rungU116 : ℝ) - (floorStar + lamStar * ((rungU112 : ℝ) - floorStar))
      = 10529 / 293600 ∧ 3 * etaStar < 10529 / 293600 := by
  constructor
  · norm_num [floorStar, lamStar, rungU116, rungU112]
  · norm_num [etaStar]

end Catalog.Novelty.TDialU112OptimalFitEquioscillation