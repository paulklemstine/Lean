import Mathlib

/-!
# Profile form: why the positional hit profile is a power law

Context (experiment 579, paper 229).  Re-analysis of `exp578_positions.npz`
(128 bit-length-96 semiprimes, 9594 recorded hits) fitted the small-`j` hit
profile `T` on the window `x ∈ [0, 2]` and found

* a **power law** `T(x) ≈ 0.0295 · (1 + x)^(-1.104)` with bootstrap CI
  `b ∈ [0.991, 1.218]` and Akaike weight `0.987`;
* the three rival one-dimensional families -- exponential (`ΔAICc +9.2`),
  logistic (`+11.5`, degenerate) and linear (`+16.9`) -- all lose.

This file isolates the *mathematics* behind that empirical verdict.  Nothing
here depends on the data: we prove that the power-law family is characterised
by an exact structural law, and that this structural law is incompatible with
each of the three rival families.

Main results.

* `powerProfile_scaleMul` — the power-law profile satisfies the *shift-scale
  multiplicativity* law
  `T 0 * T ((1+x)(1+y) - 1) = T x * T y`, i.e. it is multiplicative for the
  group law `x ⋆ y = (1+x)(1+y) - 1` on the shifted half-line.
* `powerProfile_of_scaleMultiplicative` — **rigidity**: *every* positive
  continuous profile obeying that law is a power law `A (1+x)^(-b)`.  This is
  the exact sense in which "the positional layer gets a law": the harmonic
  decline is forced, only the exponent is free.
* `powerProfile_exponent_unique` — the exponent is identifiable.
* `powerProfile_log_mid_strictConvex` — for `b > 0` the profile is *strictly*
  log-midpoint-convex: `T(t-h) · T(t+h) > T(t)^2`.
* `expProfile_log_mid_concave`, `logisticProfile_log_mid_concave`,
  `affineProfile_log_mid_concave` — each rival family satisfies the reverse
  inequality `f(t-h) · f(t+h) ≤ f(t)^2`.
* `powerProfile_ne_expProfile`, `powerProfile_ne_logisticProfile`,
  `powerProfile_ne_affineProfile` — hence a genuine power law (`b > 0`) is not
  a member of any of the three rival families: one single convexity invariant
  separates the winner from all three losers simultaneously.
* `declineFactor_bracket` — the window decline factor `T(0)/T(2) = 3^b` lies in
  `(2.8, 4.1)` for every `b` in the bootstrap interval `[0.991, 1.218]`,
  a bracket that contains the measured raw decline `3.25`.
-/

namespace ProfileForm

open Real

/-! ## The power-law profile and its structural law -/

/-- The fitted positional profile `T(x) = A · (1 + x)^(-b)`. -/
noncomputable def powerProfile (A b x : ℝ) : ℝ := A * (1 + x) ^ (-b)

theorem powerProfile_pos {A b x : ℝ} (hA : 0 < A) (hx : -1 < x) :
    0 < powerProfile A b x := by
  have h1 : (0:ℝ) < 1 + x := by linarith
  exact mul_pos hA (Real.rpow_pos_of_pos h1 _)

@[simp] theorem powerProfile_zero (A b : ℝ) : powerProfile A b 0 = A := by
  simp [powerProfile]

/-- **The structural law of the positional layer.**  The power-law profile is
multiplicative for the group law `x ⋆ y = (1+x)(1+y) - 1`, normalised by its
value at `0`. -/
theorem powerProfile_scaleMul (A b : ℝ) {x y : ℝ} (hx : -1 < x) (hy : -1 < y) :
    powerProfile A b 0 * powerProfile A b ((1 + x) * (1 + y) - 1) =
      powerProfile A b x * powerProfile A b y := by
  have hx' : (0:ℝ) < 1 + x := by linarith
  have hy' : (0:ℝ) < 1 + y := by linarith
  have h : (1 : ℝ) + ((1 + x) * (1 + y) - 1) = (1 + x) * (1 + y) := by ring
  simp only [powerProfile, h]
  rw [Real.mul_rpow hx'.le hy'.le]
  simp
  ring

/-- **Rigidity of the profile form.**  A positive, continuous profile on
`(-1, ∞)` that is multiplicative for the shift-scale group law is *necessarily*
a power law; the exponent is the only free parameter. -/
theorem powerProfile_of_scaleMultiplicative (T : ℝ → ℝ)
    (hpos : ∀ x, -1 < x → 0 < T x)
    (hcont : ContinuousOn T (Set.Ioi (-1)))
    (hmul : ∀ x y, -1 < x → -1 < y →
      T 0 * T ((1 + x) * (1 + y) - 1) = T x * T y) :
    ∃ b : ℝ, ∀ x, -1 < x → T x = powerProfile (T 0) b x := by
  have hA : 0 < T 0 := hpos 0 (by norm_num)
  have hex : ∀ u : ℝ, -1 < Real.exp u - 1 := by
    intro u; have := Real.exp_pos u; linarith
  have hTpos : ∀ u : ℝ, 0 < T (Real.exp u - 1) := fun u => hpos _ (hex u)
  set g : ℝ → ℝ := fun u => Real.log (T (Real.exp u - 1) / T 0) with hg
  have hadd : ∀ u v, g (u + v) = g u + g v := by
    intro u v
    have h1 : (1 + (Real.exp u - 1)) * (1 + (Real.exp v - 1)) - 1
        = Real.exp (u + v) - 1 := by
      rw [Real.exp_add]; ring
    have h2 := hmul _ _ (hex u) (hex v)
    rw [h1] at h2
    have hEq : T (Real.exp (u + v) - 1) / T 0
        = (T (Real.exp u - 1) / T 0) * (T (Real.exp v - 1) / T 0) := by
      field_simp
      linarith [h2]
    simp only [hg, hEq]
    exact Real.log_mul (ne_of_gt (div_pos (hTpos u) hA))
      (ne_of_gt (div_pos (hTpos v) hA))
  have hcontg : Continuous g := by
    have h1 : Continuous fun u : ℝ => Real.exp u - 1 := by fun_prop
    have h2 : Continuous fun u : ℝ => T (Real.exp u - 1) :=
      hcont.comp_continuous h1 (fun u => Set.mem_Ioi.mpr (hex u))
    exact (h2.div_const (T 0)).log
      (fun u => ne_of_gt (div_pos (hTpos u) hA))
  have hlin : ∀ u : ℝ, g u = u * g 1 := by
    intro u
    have h := map_real_smul (AddMonoidHom.mk' g (fun u v => hadd u v)) hcontg u 1
    simpa [smul_eq_mul] using h
  refine ⟨-(g 1), fun x hx => ?_⟩
  have h1x : (0:ℝ) < 1 + x := by linarith
  have hTx : 0 < T x := hpos x hx
  have hux : Real.exp (Real.log (1 + x)) - 1 = x := by
    rw [Real.exp_log h1x]; ring
  have hgx : Real.log (T x / T 0) = Real.log (1 + x) * g 1 := by
    have h := hlin (Real.log (1 + x))
    simp only [hg, hux] at h
    exact h
  have hratio : T x / T 0 = Real.exp (Real.log (1 + x) * g 1) := by
    rw [← hgx, Real.exp_log (div_pos hTx hA)]
  have : T x = T 0 * Real.exp (Real.log (1 + x) * g 1) := by
    field_simp at hratio
    linarith [hratio]
  rw [this, powerProfile, Real.rpow_def_of_pos h1x]
  ring_nf

/-- The exponent of a power-law profile is identifiable from the profile. -/
theorem powerProfile_exponent_unique {A b b' : ℝ} (hA : 0 < A)
    (h : ∀ x, -1 < x → powerProfile A b x = powerProfile A b' x) : b = b' := by
  have h1 := h 1 (by norm_num)
  simp only [powerProfile] at h1
  have h2 : ((2:ℝ)) ^ (-b) = ((2:ℝ)) ^ (-b') := by
    have : (1:ℝ) + 1 = 2 := by norm_num
    rw [this] at h1
    exact mul_left_cancel₀ (ne_of_gt hA) h1
  have h3 : -b = -b' := by
    have hlog : Real.log ((2:ℝ) ^ (-b)) = Real.log ((2:ℝ) ^ (-b')) := by rw [h2]
    rw [Real.log_rpow (by norm_num), Real.log_rpow (by norm_num)] at hlog
    have hl2 : Real.log 2 ≠ 0 := by
      have : (0:ℝ) < Real.log 2 := Real.log_pos (by norm_num)
      exact ne_of_gt this
    exact mul_right_cancel₀ hl2 hlog
  linarith

/-! ## One convexity invariant separates the winner from all three losers

For a positive profile `f` put the *log-midpoint defect* at the three equally
spaced points `t - h < t < t + h`.  A power law with `b > 0` has
`f(t-h) f(t+h) > f(t)^2` (strict log-convexity), whereas exponential, logistic
and positive affine profiles all satisfy `f(t-h) f(t+h) ≤ f(t)^2`. -/

/-- Exponential rival family `C · exp (-k x)`. -/
noncomputable def expProfile (C k x : ℝ) : ℝ := C * Real.exp (-(k * x))

/-- Logistic rival family `C / (1 + exp (k (x - x₀)))`. -/
noncomputable def logisticProfile (C k x₀ x : ℝ) : ℝ :=
  C / (1 + Real.exp (k * (x - x₀)))

/-- Linear (affine) rival family `p + q x`. -/
def affineProfile (p q x : ℝ) : ℝ := p + q * x

/-- **Strict log-convexity of the power law.** -/
theorem powerProfile_log_mid_strictConvex {A b t h : ℝ} (hA : 0 < A) (hb : 0 < b)
    (hh : 0 < h) (ht : -1 < t - h) :
    powerProfile A b t ^ 2 < powerProfile A b (t - h) * powerProfile A b (t + h) := by
  have h1 : (0:ℝ) < 1 + (t - h) := by linarith
  have h2 : (0:ℝ) < 1 + (t + h) := by linarith
  have ht0 : (0:ℝ) < 1 + t := by linarith
  have hprod : (1 + (t - h)) * (1 + (t + h)) < (1 + t) * (1 + t) := by nlinarith
  have hpos : (0:ℝ) < (1 + (t - h)) * (1 + (t + h)) := mul_pos h1 h2
  have key : ((1 + t) * (1 + t)) ^ (-b) < ((1 + (t - h)) * (1 + (t + h))) ^ (-b) :=
    Real.rpow_lt_rpow_of_neg hpos hprod (by linarith)
  rw [Real.mul_rpow h1.le h2.le, Real.mul_rpow ht0.le ht0.le] at key
  have hA2 : (0:ℝ) < A ^ 2 := by positivity
  have hscaled := mul_lt_mul_of_pos_left key hA2
  simp only [powerProfile]
  nlinarith [hscaled]

/-- The exponential family is log-affine: the defect vanishes identically. -/
theorem expProfile_log_mid_concave (C k t h : ℝ) :
    expProfile C k (t - h) * expProfile C k (t + h) = expProfile C k t ^ 2 := by
  simp only [expProfile]
  rw [show -(k * (t - h)) = -(k*t) + k*h by ring, show -(k * (t + h)) = -(k*t) - k*h by ring,
    Real.exp_add, Real.exp_sub]
  field_simp

/-- The logistic family is log-concave. -/
theorem logisticProfile_log_mid_concave {C k t h x₀ : ℝ} (hC : 0 < C) :
    logisticProfile C k x₀ (t - h) * logisticProfile C k x₀ (t + h)
      ≤ logisticProfile C k x₀ t ^ 2 := by
  set u : ℝ := k * (t - x₀) with hu
  have e1 : k * (t - h - x₀) = u - k * h := by rw [hu]; ring
  have e2 : k * (t + h - x₀) = u + k * h := by rw [hu]; ring
  simp only [logisticProfile, e1, e2, ← hu]
  have hpu : (0:ℝ) < Real.exp u := Real.exp_pos u
  have hp1 : (0:ℝ) < 1 + Real.exp (u - k * h) := by positivity
  have hp2 : (0:ℝ) < 1 + Real.exp (u + k * h) := by positivity
  have hp3 : (0:ℝ) < 1 + Real.exp u := by positivity
  have hsplit : Real.exp (u - k * h) * Real.exp (u + k * h) = Real.exp u * Real.exp u := by
    rw [← Real.exp_add, ← Real.exp_add]; ring_nf
  have hsum : 2 * Real.exp u ≤ Real.exp (u - k * h) + Real.exp (u + k * h) := by
    have h2 : Real.exp (u - k * h) + Real.exp (u + k * h)
        = Real.exp u * (Real.exp (-(k * h)) + Real.exp (k * h)) := by
      rw [Real.exp_sub, Real.exp_add, Real.exp_neg]; field_simp
    have hcosh : 2 ≤ Real.exp (-(k * h)) + Real.exp (k * h) := by
      have hE : (0:ℝ) < Real.exp (k * h) := Real.exp_pos _
      have hinv : Real.exp (-(k * h)) = (Real.exp (k * h))⁻¹ := Real.exp_neg _
      have hipos : (0:ℝ) < (Real.exp (k * h))⁻¹ := inv_pos.mpr hE
      have hmul : (Real.exp (k * h))⁻¹ * Real.exp (k * h) = 1 :=
        inv_mul_cancel₀ (ne_of_gt hE)
      rw [hinv]
      nlinarith [mul_nonneg hipos.le (sq_nonneg (Real.exp (k * h) - 1)), hmul, hE, hipos]
    rw [h2]
    nlinarith [hpu]
  have hkey : (1 + Real.exp u) ^ 2
      ≤ (1 + Real.exp (u - k * h)) * (1 + Real.exp (u + k * h)) := by
    nlinarith [hsplit, hsum, hpu]
  have hrewrite : C / (1 + Real.exp (u - k * h)) * (C / (1 + Real.exp (u + k * h)))
      = C ^ 2 / ((1 + Real.exp (u - k * h)) * (1 + Real.exp (u + k * h))) := by
    field_simp
  rw [hrewrite, div_pow]
  gcongr

/-- An affine profile is log-concave (indeed the midpoint defect is exactly
`-q^2h^2 ≤ 0`, with no positivity hypothesis needed). -/
theorem affineProfile_log_mid_concave (p q t h : ℝ) :
    affineProfile p q (t - h) * affineProfile p q (t + h) ≤ affineProfile p q t ^ 2 := by
  simp only [affineProfile]
  nlinarith [sq_nonneg (q * h)]

/-! ### Separation corollaries -/

theorem powerProfile_ne_expProfile {A b C k : ℝ} (hA : 0 < A) (hb : 0 < b) :
    ¬ ∀ x, -1 < x → powerProfile A b x = expProfile C k x := by
  intro h
  have hs := powerProfile_log_mid_strictConvex (A := A) (b := b) (t := 1) (h := 1)
    hA hb one_pos (by norm_num)
  rw [h (1 - 1) (by norm_num), h (1 + 1) (by norm_num), h 1 (by norm_num)] at hs
  rw [expProfile_log_mid_concave] at hs
  exact lt_irrefl _ hs

theorem powerProfile_ne_logisticProfile {A b C k x₀ : ℝ} (hA : 0 < A) (hb : 0 < b)
    (hC : 0 < C) :
    ¬ ∀ x, -1 < x → powerProfile A b x = logisticProfile C k x₀ x := by
  intro h
  have hs := powerProfile_log_mid_strictConvex (A := A) (b := b) (t := 1) (h := 1)
    hA hb one_pos (by norm_num)
  rw [h (1 - 1) (by norm_num), h (1 + 1) (by norm_num), h 1 (by norm_num)] at hs
  exact absurd (logisticProfile_log_mid_concave (C := C) (k := k) (t := 1) (h := 1)
    (x₀ := x₀) hC) (not_le.mpr hs)

theorem powerProfile_ne_affineProfile {A b p q : ℝ} (hA : 0 < A) (hb : 0 < b) :
    ¬ ∀ x, -1 < x → powerProfile A b x = affineProfile p q x := by
  intro h
  have hs := powerProfile_log_mid_strictConvex (A := A) (b := b) (t := 1) (h := 1)
    hA hb one_pos (by norm_num)
  have hle := affineProfile_log_mid_concave p q 1 1
  rw [h (1 - 1) (by norm_num), h (1 + 1) (by norm_num), h 1 (by norm_num)] at hs
  exact absurd hle (not_le.mpr hs)

/-! ## The window decline factor

Over the measured window `x ∈ [0,2]` the power law declines by the factor
`T(0)/T(2) = 3^b`.  We bracket it over the bootstrap interval for `b`. -/

/-- The decline factor of the profile across the window `[0,2]`. -/
noncomputable def declineFactor (b : ℝ) : ℝ := (3:ℝ) ^ b

theorem declineFactor_eq {A b : ℝ} (hA : 0 < A) :
    powerProfile A b 0 / powerProfile A b 2 = declineFactor b := by
  have h3 : (0:ℝ) < (3:ℝ) ^ b := Real.rpow_pos_of_pos (by norm_num) _
  simp only [powerProfile, declineFactor, show (1:ℝ) + 0 = 1 by norm_num,
    show (1:ℝ) + 2 = 3 by norm_num, Real.one_rpow]
  rw [Real.rpow_neg (by norm_num : (0:ℝ) ≤ 3)]
  field_simp

theorem declineFactor_strictMono : StrictMono declineFactor := by
  intro a b hab
  exact Real.rpow_lt_rpow_of_exponent_lt (by norm_num) hab

/-- Elementary upper bound `exp y ≤ (1 - y)⁻¹` for `y < 1`. -/
theorem exp_le_inv_one_sub {y : ℝ} (hy : y < 1) : Real.exp y ≤ (1 - y)⁻¹ := by
  have h1 : (0:ℝ) < 1 - y := by linarith
  have h2 : 1 - y ≤ Real.exp (-y) := by
    have := Real.add_one_le_exp (-y)
    linarith
  have h3 : Real.exp (-y) = (Real.exp y)⁻¹ := Real.exp_neg y
  rw [h3] at h2
  have hey : (0:ℝ) < Real.exp y := Real.exp_pos y
  exact (le_inv_comm₀ hey h1).mpr h2

theorem log_three_gt : (1.05 : ℝ) < Real.log 3 := by
  have hexp : Real.exp (1.05 : ℝ) < 3 := by
    have h1 : Real.exp (1.05 : ℝ) = Real.exp 1 * Real.exp 0.05 := by
      rw [← Real.exp_add]; norm_num
    have h2 : Real.exp (0.05 : ℝ) ≤ (1 - 0.05 : ℝ)⁻¹ := exp_le_inv_one_sub (by norm_num)
    have h3 : Real.exp 1 < 2.7182818286 := Real.exp_one_lt_d9
    have h4 : (0:ℝ) < Real.exp 0.05 := Real.exp_pos _
    rw [h1]
    nlinarith
  have := Real.log_lt_log (Real.exp_pos _) hexp
  rwa [Real.log_exp] at this

theorem log_three_lt : Real.log 3 < (1.14 : ℝ) := by
  have hexp : (3:ℝ) < Real.exp (1.14 : ℝ) := by
    have h1 : Real.exp (1.14 : ℝ) = Real.exp 1 * Real.exp 0.14 := by
      rw [← Real.exp_add]; norm_num
    have h2 : (1.14 : ℝ) ≤ Real.exp 0.14 := by
      have := Real.add_one_le_exp (0.14 : ℝ); linarith
    have h3 : (2.7182818283 : ℝ) < Real.exp 1 := Real.exp_one_gt_d9
    rw [h1]
    nlinarith [Real.exp_pos (0.14 : ℝ)]
  have := Real.log_lt_log (by norm_num) hexp
  rwa [Real.log_exp] at this

/-- **Window decline bracket.**  For every exponent in the bootstrap interval
`[0.991, 1.218]` the decline factor across the window lies in `(2.8, 4.1)`;
in particular the bracket contains the measured raw decline `3.25`. -/
theorem declineFactor_bracket {b : ℝ} (h1 : 0.991 ≤ b) (h2 : b ≤ 1.218) :
    2.8 < declineFactor b ∧ declineFactor b < 4.1 := by
  have hlog := log_three_gt
  have hlog' := log_three_lt
  constructor
  · have hexp : Real.exp (1.04 : ℝ) ≤ declineFactor b := by
      have : declineFactor b = Real.exp (b * Real.log 3) := by
        simp only [declineFactor]
        rw [Real.rpow_def_of_pos (by norm_num)]
        ring_nf
      rw [this]
      apply Real.exp_le_exp.mpr
      calc (1.04:ℝ) ≤ 0.991 * 1.05 := by norm_num
        _ ≤ b * Real.log 3 :=
            mul_le_mul h1 hlog.le (by norm_num) (by linarith)
    have hlow : (2.8 : ℝ) < Real.exp (1.04 : ℝ) := by
      have h1' : Real.exp (1.04 : ℝ) = Real.exp 1 * Real.exp 0.04 := by
        rw [← Real.exp_add]; norm_num
      have h2' : (1.04 : ℝ) ≤ Real.exp 0.04 := by
        have := Real.add_one_le_exp (0.04 : ℝ); linarith
      have h3' : (2.7182818283 : ℝ) < Real.exp 1 := Real.exp_one_gt_d9
      rw [h1']
      nlinarith [Real.exp_pos (0.04 : ℝ)]
    linarith
  · have hexp : declineFactor b ≤ Real.exp (1.3886 : ℝ) := by
      have : declineFactor b = Real.exp (b * Real.log 3) := by
        simp only [declineFactor]
        rw [Real.rpow_def_of_pos (by norm_num)]
        ring_nf
      rw [this]
      apply Real.exp_le_exp.mpr
      calc b * Real.log 3 ≤ 1.218 * 1.14 :=
            mul_le_mul h2 hlog'.le (by linarith) (by norm_num)
        _ ≤ 1.3886 := by norm_num
    have hup : Real.exp (1.3886 : ℝ) < 4.1 := by
      have hstep : Real.exp (0.048575 : ℝ) ≤ (1 - 0.048575 : ℝ)⁻¹ :=
        exp_le_inv_one_sub (by norm_num)
      have hpow : Real.exp (0.3886 : ℝ) = (Real.exp (0.048575 : ℝ)) ^ (8:ℕ) := by
        rw [← Real.exp_nat_mul]; norm_num
      have hpow' : (Real.exp (0.048575:ℝ)) ^ (8:ℕ) ≤ ((1 - 0.048575 : ℝ)⁻¹) ^ (8:ℕ) :=
        pow_le_pow_left₀ (Real.exp_pos _).le hstep 8
      have hb : Real.exp (0.3886:ℝ) ≤ ((1 - 0.048575 : ℝ)⁻¹) ^ (8:ℕ) := by
        rw [hpow]; exact hpow'
      have hnum : ((1 - 0.048575 : ℝ)⁻¹) ^ (8:ℕ) < 1.49 := by norm_num
      have h1' : Real.exp (1.3886 : ℝ) = Real.exp 1 * Real.exp 0.3886 := by
        rw [← Real.exp_add]; norm_num
      have h3' : Real.exp 1 < 2.7182818286 := Real.exp_one_lt_d9
      rw [h1']
      nlinarith [Real.exp_pos (0.3886:ℝ), Real.exp_pos (1:ℝ)]
    linarith

end ProfileForm