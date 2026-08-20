import Mathlib

/-!
# High-precision isolation of the quantum EML scalar-log root

This file is the fourth instalment of the *quantum EML scalar logarithm*
thread.  Recall the situation from the earlier catalog files
(`Catalog/NumberTheory/EMLQuantumScalarLog.lean`,
`Catalog/NumberTheory/EMLQuantumScalarLogSharp.lean`,
`Catalog/NumberTheory/EMLQuantumUnitaryExponential.lean`): the raw activation
`exp (i H₁) log (I + i H₂)` is not unitary-valued, but the *scalar* logarithmic
factor `log (1 + t i)` becomes unimodular — hence a unitary of any complex star
algebra — at the unique positive parameter `t` solving

`‖log (1 + t i)‖ = 1`, equivalently `(log (1 + t²)/2)² + (arctan t)² = 1`.

The previous instalments certified this parameter only to lie in `[6/5, 5/4]`,
an interval of width `1/20`.  Since the catalog files are compiled
independently of one another, the basic definitions and the Taylor
certificates of `Catalog/NumberTheory/EMLQuantumTaylorCertificates.lean` are
restated here; everything from `§ 3` on is new.

## Main results

* `QuantumEML.scalarLogRoot` : the root itself, together with
  `QuantumEML.scalarLogNorm_scalarLogRoot` and
  `QuantumEML.eq_scalarLogRoot_of_pos` (uniqueness among positive parameters).
* `QuantumEML.scalarLogRoot_mem_Icc` : **certified isolation of width
  `1.1 · 10⁻⁶`**, namely `scalarLogRoot ∈ [1.2290370, 1.2290381]`; this improves
  the previously certified width `1/20` by a factor of more than `45000`.  The
  proof runs the
  two-sided Taylor certificates for `log` and `arctan` at the two rational
  endpoints, using the Möbius reduction `log x = log 2 + log (x/2)` and the
  tangent addition law `arctan t = π/4 + arctan ((t-1)/(t+1))` to make the
  expansions converge fast enough.
* `QuantumEML.hasDerivAt_scalarLogNormSq` : the closed-form derivative
  `(t log (1 + t²) + 2 arctan t) / (1 + t²)`.
* `QuantumEML.two_div_three_le_deriv_scalarLogNormSq` : the derivative is at
  least `2/3` on `[1, 3/2]`, hence the root is a **simple** zero.
* `QuantumEML.abs_sub_scalarLogRoot_le` : **effective root isolation.**  For
  every `t ∈ [1, 3/2]`, `|t - scalarLogRoot| ≤ (3/2) |scalarLogNormSq t - 1|`;
  any rational witness with small residual is automatically close to the root.
* `QuantumEML.scalarLogRoot_ne_rat_of_den_le` : **effective irrationality
  bound.**  `scalarLogRoot` is not equal to any rational number of denominator
  at most `1287`.  (Number-theoretic input: an interval of width `1.1 · 10⁻⁶`
  around `1.229` contains no fraction of small denominator; this is checked by
  a decision procedure over the `1287` possible denominators.)
* `QuantumEML.bijOn_scalarLogNorm` : the radius map `t ↦ ‖log (1 + t i)‖` is a
  strictly monotone bijection of `[0, ∞)` onto itself, so the unit-circle
  problem is the fibre over `1` of a global order isomorphism.
* `QuantumEML.scalarLogNorm_eq_one_iff` : **complete classification** of the
  solutions: exactly the two parameters `± scalarLogRoot`.
* `QuantumEML.spectral_log_activation_mem_unitary_iff` : **spectral rigidity.**
  A logarithmic activation `V · diag (log (1 + i d)) · V⋆` of a Hermitian matrix
  is unitary iff every eigenvalue equals `± scalarLogRoot`; unitarity therefore
  pins the whole spectrum to two certified transcendental-looking values.
* `QuantumEML.transcendental_scalarLogRoot` : **conditional transcendence.**
  Under the (open) hypothesis that a product of two principal logarithms of
  algebraic numbers is never `1`, the root is transcendental.  The hypothesis is
  an explicit assumption of the theorem, not an axiom.
-/

noncomputable section

open Complex Real Set

namespace QuantumEML

/-! ## 1.  Taylor certificates (restated from `EMLQuantumTaylorCertificates.lean`) -/

namespace Certificates

/-- `arctan y ≤ y - y ^ 3 / 3 + y ^ 5 / 5` for `y ≥ 0`. -/
theorem arctan_le_taylor_five {y : ℝ} (hy : 0 ≤ y) : Real.arctan y ≤ y - y ^ 3 / 3 + y ^ 5 / 5 := by
  set g : ℝ → ℝ := fun x => (x - x ^ 3 / 3 + x ^ 5 / 5) - Real.arctan x with hg
  have hd : ∀ x : ℝ, HasDerivAt g (x ^ 6 / (1 + x ^ 2)) x := by
    intro x
    have h1 : HasDerivAt Real.arctan (1 / (1 + x ^ 2)) x := Real.hasDerivAt_arctan x
    have h2 : HasDerivAt (fun x : ℝ => x - x ^ 3 / 3 + x ^ 5 / 5) (1 - x ^ 2 + x ^ 4) x := by
      have ha : HasDerivAt (fun x : ℝ => x - x ^ 3 / 3) (1 - x ^ 2) x := by
        simpa using ((hasDerivAt_id x).sub ((hasDerivAt_pow 3 x).div_const 3)).congr_deriv (by
          push_cast; ring)
      have hb : HasDerivAt (fun x : ℝ => x ^ 5 / 5) (x ^ 4) x := by
        simpa using ((hasDerivAt_pow 5 x).div_const 5).congr_deriv (by push_cast; ring)
      exact ha.add hb
    refine (h2.sub h1).congr_deriv ?_
    have hpos : (0:ℝ) < 1 + x ^ 2 := by positivity
    field_simp
    ring
  have hmono : Monotone g := monotone_of_hasDerivAt_nonneg hd (by intro x; positivity)
  have h := hmono hy
  simp only [hg] at h
  simpa using h

/-- The Möbius substitution `u = (x - 1) / (x + 1)`. -/
theorem log_eq_log_ratio {x : ℝ} (hx : 0 < x) :
    Real.log x = Real.log (1 + (x - 1) / (x + 1)) - Real.log (1 - (x - 1) / (x + 1)) := by
  have hx1 : (0:ℝ) < x + 1 := by linarith
  have e1 : 1 + (x - 1) / (x + 1) = 2 * x / (x + 1) := by field_simp; ring
  have e2 : 1 - (x - 1) / (x + 1) = 2 / (x + 1) := by
    field_simp
    linarith
  rw [e1, e2, Real.log_div (by positivity) hx1.ne', Real.log_div two_ne_zero hx1.ne',
    Real.log_mul two_ne_zero hx.ne']
  ring

/-! ### Higher-order certificates: the next rung of the ladder -/

/-- **Seventh-order lower certificate for `arctan`.**  For `y ≥ 0`,
`y - y³/3 + y⁵/5 - y⁷/7 ≤ arctan y`; the difference has derivative
`y ^ 8 / (1 + y ^ 2) ≥ 0`. -/
theorem arctan_taylor_seven_le {y : ℝ} (hy : 0 ≤ y) :
    y - y ^ 3 / 3 + y ^ 5 / 5 - y ^ 7 / 7 ≤ Real.arctan y := by
  set g : ℝ → ℝ := fun x => Real.arctan x - (x - x ^ 3 / 3 + x ^ 5 / 5 - x ^ 7 / 7) with hg
  have hd : ∀ x : ℝ, HasDerivAt g (x ^ 8 / (1 + x ^ 2)) x := by
    intro x
    have h1 : HasDerivAt Real.arctan (1 / (1 + x ^ 2)) x := Real.hasDerivAt_arctan x
    have h2 : HasDerivAt (fun x : ℝ => x - x ^ 3 / 3 + x ^ 5 / 5 - x ^ 7 / 7)
        (1 - x ^ 2 + x ^ 4 - x ^ 6) x := by
      have ha : HasDerivAt (fun x : ℝ => x - x ^ 3 / 3) (1 - x ^ 2) x := by
        simpa using ((hasDerivAt_id x).sub ((hasDerivAt_pow 3 x).div_const 3)).congr_deriv (by
          push_cast; ring)
      have hb : HasDerivAt (fun x : ℝ => x ^ 5 / 5) (x ^ 4) x := by
        simpa using ((hasDerivAt_pow 5 x).div_const 5).congr_deriv (by push_cast; ring)
      have hc : HasDerivAt (fun x : ℝ => x ^ 7 / 7) (x ^ 6) x := by
        simpa using ((hasDerivAt_pow 7 x).div_const 7).congr_deriv (by push_cast; ring)
      exact (ha.add hb).sub hc
    refine (h1.sub h2).congr_deriv ?_
    have hpos : (0:ℝ) < 1 + x ^ 2 := by positivity
    field_simp
    ring
  have hmono : Monotone g := monotone_of_hasDerivAt_nonneg hd (by intro x; positivity)
  have h := hmono hy
  simp only [hg] at h
  simpa using h

/-- **Fifth-order lower certificate for the logarithmic ratio.** -/
theorem taylor_five_le_log_ratio {u : ℝ} (hu : 0 ≤ u) (hu1 : u < 1) :
    2 * (u + u ^ 3 / 3 + u ^ 5 / 5) ≤ Real.log (1 + u) - Real.log (1 - u) := by
  set g : ℝ → ℝ := fun x => (Real.log (1 + x) - Real.log (1 - x)) -
      2 * (x + x ^ 3 / 3 + x ^ 5 / 5) with hg
  have hd : ∀ x ∈ Ico (0:ℝ) 1, HasDerivAt g (2 * x ^ 6 / (1 - x ^ 2)) x := by
    rintro x ⟨hx0, hx1⟩
    have hp : (0:ℝ) < 1 + x := by linarith
    have hm : (0:ℝ) < 1 - x := by linarith
    have h1 : HasDerivAt (fun y : ℝ => Real.log (1 + y)) (1 / (1 + x)) x := by
      simpa using ((hasDerivAt_id x).const_add (1:ℝ)).log hp.ne'
    have h2 : HasDerivAt (fun y : ℝ => Real.log (1 - y)) (-1 / (1 - x)) x := by
      simpa using ((hasDerivAt_id x).const_sub (1:ℝ)).log hm.ne'
    have h3 : HasDerivAt (fun y : ℝ => 2 * (y + y ^ 3 / 3 + y ^ 5 / 5))
        (2 * (1 + x ^ 2 + x ^ 4)) x := by
      have ha : HasDerivAt (fun y : ℝ => y + y ^ 3 / 3 + y ^ 5 / 5) (1 + x ^ 2 + x ^ 4) x := by
        have h1' : HasDerivAt (fun y : ℝ => y + y ^ 3 / 3) (1 + x ^ 2) x := by
          simpa using ((hasDerivAt_id x).add ((hasDerivAt_pow 3 x).div_const 3)).congr_deriv (by
            push_cast; ring)
        have h2' : HasDerivAt (fun y : ℝ => y ^ 5 / 5) (x ^ 4) x := by
          simpa using ((hasDerivAt_pow 5 x).div_const 5).congr_deriv (by push_cast; ring)
        exact h1'.add h2'
      simpa using ha.const_mul (2:ℝ)
    refine ((h1.sub h2).sub h3).congr_deriv ?_
    have hne : (1 - x ^ 2) ≠ 0 := by nlinarith
    field_simp
    ring
  have hcont : ContinuousOn g (Ico 0 1) := fun x hx => (hd x hx).continuousAt.continuousWithinAt
  have hmono : MonotoneOn g (Ico (0:ℝ) 1) := by
    refine monotoneOn_of_hasDerivWithinAt_nonneg (convex_Ico _ _) hcont
      (f' := fun x => 2 * x ^ 6 / (1 - x ^ 2)) ?_ ?_
    · intro x hx
      rw [interior_Ico] at hx
      exact (hd x ⟨hx.1.le, hx.2⟩).hasDerivWithinAt
    · intro x hx
      rw [interior_Ico] at hx
      have : (0:ℝ) < 1 - x ^ 2 := by nlinarith [hx.1, hx.2]
      positivity
  have h0 : (0:ℝ) ∈ Ico (0:ℝ) 1 := ⟨le_refl _, by norm_num⟩
  have h := hmono h0 ⟨hu, hu1⟩ hu
  simp only [hg] at h
  norm_num at h
  linarith

/-- **Quintic geometric-tail upper certificate for the logarithmic ratio.** -/
theorem log_ratio_le_taylor_five {u : ℝ} (hu : 0 ≤ u) (hu1 : u < 1) :
    Real.log (1 + u) - Real.log (1 - u) ≤ 2 * (u + u ^ 3 / 3) + (2 / 5) * u ^ 5 / (1 - u ^ 2) := by
  set g : ℝ → ℝ := fun x => (2 * (x + x ^ 3 / 3) + (2 / 5) * x ^ 5 / (1 - x ^ 2)) -
      (Real.log (1 + x) - Real.log (1 - x)) with hg
  have hd : ∀ x ∈ Ico (0:ℝ) 1, HasDerivAt g ((4 / 5) * x ^ 6 / (1 - x ^ 2) ^ 2) x := by
    rintro x ⟨hx0, hx1⟩
    have hp : (0:ℝ) < 1 + x := by linarith
    have hm : (0:ℝ) < 1 - x := by linarith
    have hs : (0:ℝ) < 1 - x ^ 2 := by nlinarith
    have h1 : HasDerivAt (fun y : ℝ => Real.log (1 + y)) (1 / (1 + x)) x := by
      simpa using ((hasDerivAt_id x).const_add (1:ℝ)).log hp.ne'
    have h2 : HasDerivAt (fun y : ℝ => Real.log (1 - y)) (-1 / (1 - x)) x := by
      simpa using ((hasDerivAt_id x).const_sub (1:ℝ)).log hm.ne'
    have hnum : HasDerivAt (fun y : ℝ => (2 / 5) * y ^ 5) (2 * x ^ 4) x := by
      simpa using ((hasDerivAt_pow 5 x).const_mul (2 / 5 : ℝ)).congr_deriv (by push_cast; ring)
    have hden : HasDerivAt (fun y : ℝ => 1 - y ^ 2) (-(2 * x)) x := by
      simpa using ((hasDerivAt_pow 2 x).const_sub (1:ℝ)).congr_deriv (by push_cast; ring)
    have hq : HasDerivAt (fun y : ℝ => (2 / 5) * y ^ 5 / (1 - y ^ 2))
        ((2 * x ^ 4 * (1 - x ^ 2) - (2 / 5) * x ^ 5 * (-(2 * x))) / (1 - x ^ 2) ^ 2) x :=
      hnum.div hden hs.ne'
    have hlin : HasDerivAt (fun y : ℝ => 2 * (y + y ^ 3 / 3)) (2 * (1 + x ^ 2)) x := by
      have h1' : HasDerivAt (fun y : ℝ => y + y ^ 3 / 3) (1 + x ^ 2) x := by
        simpa using ((hasDerivAt_id x).add ((hasDerivAt_pow 3 x).div_const 3)).congr_deriv (by
          push_cast; ring)
      simpa using h1'.const_mul (2:ℝ)
    refine ((hlin.add hq).sub (h1.sub h2)).congr_deriv ?_
    field_simp
    ring
  have hcont : ContinuousOn g (Ico 0 1) := fun x hx => (hd x hx).continuousAt.continuousWithinAt
  have hmono : MonotoneOn g (Ico (0:ℝ) 1) := by
    refine monotoneOn_of_hasDerivWithinAt_nonneg (convex_Ico _ _) hcont
      (f' := fun x => (4 / 5) * x ^ 6 / (1 - x ^ 2) ^ 2) ?_ ?_
    · intro x hx
      rw [interior_Ico] at hx
      exact (hd x ⟨hx.1.le, hx.2⟩).hasDerivWithinAt
    · intro x _
      positivity
  have h0 : (0:ℝ) ∈ Ico (0:ℝ) 1 := ⟨le_refl _, by norm_num⟩
  have h := hmono h0 ⟨hu, hu1⟩ hu
  simp only [hg] at h
  norm_num at h
  linarith

/-- Fifth-order rational lower enclosure of `log`. -/
theorem taylor_five_le_log {x : ℝ} (hx : 1 ≤ x) :
    2 * ((x - 1) / (x + 1) + ((x - 1) / (x + 1)) ^ 3 / 3 + ((x - 1) / (x + 1)) ^ 5 / 5) ≤
      Real.log x := by
  have hx0 : (0:ℝ) < x := lt_of_lt_of_le one_pos hx
  have hx1 : (0:ℝ) < x + 1 := by linarith
  have hu0 : 0 ≤ (x - 1) / (x + 1) := div_nonneg (by linarith) hx1.le
  have hu1 : (x - 1) / (x + 1) < 1 := by rw [div_lt_one hx1]; linarith
  rw [log_eq_log_ratio hx0]
  exact taylor_five_le_log_ratio hu0 hu1

/-- Quintic-tail rational upper enclosure of `log`. -/
theorem log_le_taylor_five {x : ℝ} (hx : 1 ≤ x) :
    Real.log x ≤ 2 * ((x - 1) / (x + 1) + ((x - 1) / (x + 1)) ^ 3 / 3) +
      (2 / 5) * ((x - 1) / (x + 1)) ^ 5 / (1 - ((x - 1) / (x + 1)) ^ 2) := by
  have hx0 : (0:ℝ) < x := lt_of_lt_of_le one_pos hx
  have hx1 : (0:ℝ) < x + 1 := by linarith
  have hu0 : 0 ≤ (x - 1) / (x + 1) := div_nonneg (by linarith) hx1.le
  have hu1 : (x - 1) / (x + 1) < 1 := by rw [div_lt_one hx1]; linarith
  rw [log_eq_log_ratio hx0]
  exact log_ratio_le_taylor_five hu0 hu1

/-- Tangent addition law at `1`. -/
theorem arctan_eq_pi_div_four_add {t : ℝ} (ht : -1 < t) :
    Real.arctan t = π / 4 + Real.arctan ((t - 1) / (t + 1)) := by
  have ht1 : (0:ℝ) < t + 1 := by linarith
  have hlt : (t - 1) / (t + 1) < 1 := by rw [div_lt_one ht1]; linarith
  have h := Real.arctan_add (x := 1) (y := (t - 1) / (t + 1)) (by simpa using hlt)
  rw [Real.arctan_one] at h
  have e : (1 + (t - 1) / (t + 1)) / (1 - 1 * ((t - 1) / (t + 1))) = t := by
    field_simp
    ring
  rw [e] at h
  linarith

end Certificates

open Certificates

/-! ## 2.  The scalar logarithmic norm (restated) -/

/-- The scalar logarithmic norm along the vertical line through `1`. -/
def scalarLogNorm (t : ℝ) : ℝ := ‖Complex.log (1 + (t : ℂ) * I)‖

/-- Closed form of its square. -/
def scalarLogNormSq (t : ℝ) : ℝ := (Real.log (1 + t ^ 2) / 2) ^ 2 + (Real.arctan t) ^ 2

theorem arg_one_add_mul_I (t : ℝ) : (1 + (t : ℂ) * I).arg = Real.arctan t := by
  rw [Complex.arg, if_pos (by simp), Real.arctan_eq_arcsin]
  congr 1
  rw [Complex.norm_def]
  simp [Complex.normSq]
  ring_nf

theorem norm_one_add_mul_I (t : ℝ) : ‖1 + (t : ℂ) * I‖ = Real.sqrt (1 + t ^ 2) := by
  rw [Complex.norm_def]
  congr 1
  simp [Complex.normSq]
  ring

theorem scalarLogNorm_sq (t : ℝ) : scalarLogNorm t ^ 2 = scalarLogNormSq t := by
  have hre : (Complex.log (1 + (t : ℂ) * I)).re = Real.log (1 + t ^ 2) / 2 := by
    rw [Complex.log_re, norm_one_add_mul_I, Real.log_sqrt (by positivity)]
  have him : (Complex.log (1 + (t : ℂ) * I)).im = Real.arctan t := by
    rw [Complex.log_im, arg_one_add_mul_I]
  rw [scalarLogNorm, scalarLogNormSq, ← Complex.normSq_eq_norm_sq, Complex.normSq_apply, hre, him]
  ring

theorem scalarLogNorm_nonneg (t : ℝ) : 0 ≤ scalarLogNorm t := norm_nonneg _

theorem scalarLogNormSq_nonneg (t : ℝ) : 0 ≤ scalarLogNormSq t := by
  rw [← scalarLogNorm_sq]; positivity

theorem scalarLogNorm_eq_sqrt (t : ℝ) : scalarLogNorm t = Real.sqrt (scalarLogNormSq t) := by
  rw [← scalarLogNorm_sq, Real.sqrt_sq (scalarLogNorm_nonneg t)]

theorem log_one_add_sq_nonneg (t : ℝ) : 0 ≤ Real.log (1 + t ^ 2) :=
  Real.log_nonneg (by nlinarith [sq_nonneg t])

theorem strictMonoOn_scalarLogNormSq : StrictMonoOn scalarLogNormSq (Ici (0 : ℝ)) := by
  intro a ha b hb hab
  simp only [mem_Ici] at ha hb
  have h1 : Real.log (1 + a ^ 2) < Real.log (1 + b ^ 2) := by
    apply Real.log_lt_log (by positivity)
    nlinarith
  have h2 : Real.arctan a < Real.arctan b := Real.arctan_strictMono hab
  have ha1 := log_one_add_sq_nonneg a
  have ha2 : 0 ≤ Real.arctan a := Real.arctan_nonneg.2 ha
  unfold scalarLogNormSq
  nlinarith

theorem strictMonoOn_scalarLogNorm : StrictMonoOn scalarLogNorm (Ici (0 : ℝ)) := by
  intro a ha b hb hab
  have h := strictMonoOn_scalarLogNormSq ha hb hab
  rw [scalarLogNorm_eq_sqrt, scalarLogNorm_eq_sqrt]
  exact Real.sqrt_lt_sqrt (scalarLogNormSq_nonneg a) h

theorem injOn_scalarLogNorm : InjOn scalarLogNorm (Ici (0 : ℝ)) :=
  strictMonoOn_scalarLogNorm.injOn

theorem continuous_scalarLogNorm : Continuous scalarLogNorm := by
  unfold scalarLogNorm
  apply Continuous.norm
  apply Continuous.clog
  · fun_prop
  · intro t
    rw [Complex.mem_slitPlane_iff]
    left
    simp

/-! ## 3.  The certified interval of width `1.1 · 10⁻⁶` -/

/-- Certified upper bound `log (1 + 1.2290370²) ≤ 0.9204946900`. -/
theorem log_one_add_sq_left_le :
    Real.log (1 + (12290370 / 10000000 : ℝ) ^ 2) ≤ 0.9204946900 := by
  have hx : (1 + (12290370 / 10000000 : ℝ) ^ 2)
      = 2 * (2510531947369 / 2000000000000) := by norm_num
  rw [hx, Real.log_mul (by norm_num) (by norm_num)]
  have h1 : Real.log 2 < 0.6931471808 := Real.log_two_lt_d9
  have h2 := log_le_taylor_five (x := (2510531947369 / 2000000000000 : ℝ)) (by norm_num)
  have h3 : 2 * (((2510531947369 / 2000000000000 : ℝ) - 1) /
        ((2510531947369 / 2000000000000 : ℝ) + 1) +
      (((2510531947369 / 2000000000000 : ℝ) - 1) /
        ((2510531947369 / 2000000000000 : ℝ) + 1)) ^ 3 / 3) +
      (2 / 5) * (((2510531947369 / 2000000000000 : ℝ) - 1) /
        ((2510531947369 / 2000000000000 : ℝ) + 1)) ^ 5 /
      (1 - (((2510531947369 / 2000000000000 : ℝ) - 1) /
        ((2510531947369 / 2000000000000 : ℝ) + 1)) ^ 2) ≤ 0.2273475092 := by norm_num
  linarith

/-- Certified lower bound `0.9204956699 ≤ log (1 + 1.2290381²)`. -/
theorem le_log_one_add_sq_right :
    (0.9204956699 : ℝ) ≤ Real.log (1 + (12290381 / 10000000 : ℝ) ^ 2) := by
  have hx : (1 + (12290381 / 10000000 : ℝ) ^ 2)
      = 2 * (251053465125161 / 200000000000000) := by norm_num
  rw [hx, Real.log_mul (by norm_num) (by norm_num)]
  have h1 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
  have h2 := taylor_five_le_log (x := (251053465125161 / 200000000000000 : ℝ)) (by norm_num)
  have h3 : (0.2273484896 : ℝ) ≤
      2 * (((251053465125161 / 200000000000000 : ℝ) - 1) /
          ((251053465125161 / 200000000000000 : ℝ) + 1) +
        (((251053465125161 / 200000000000000 : ℝ) - 1) /
          ((251053465125161 / 200000000000000 : ℝ) + 1)) ^ 3 / 3 +
        (((251053465125161 / 200000000000000 : ℝ) - 1) /
          ((251053465125161 / 200000000000000 : ℝ) + 1)) ^ 5 / 5) := by norm_num
  linarith

/-- Certified upper bound `arctan 1.2290370 ≤ 0.8877904749`. -/
theorem arctan_left_le : Real.arctan (12290370 / 10000000 : ℝ) ≤ 0.8877904749 := by
  rw [arctan_eq_pi_div_four_add (by norm_num)]
  have hpi : π < 3.141593 := Real.pi_lt_d6
  have h := arctan_le_taylor_five
    (y := ((12290370 / 10000000 - 1) / (12290370 / 10000000 + 1) : ℝ)) (by norm_num)
  have h3 : ((12290370 / 10000000 - 1) / (12290370 / 10000000 + 1) : ℝ) -
      ((12290370 / 10000000 - 1) / (12290370 / 10000000 + 1) : ℝ) ^ 3 / 3 +
      ((12290370 / 10000000 - 1) / (12290370 / 10000000 + 1) : ℝ) ^ 5 / 5
      ≤ 0.1023922249 := by norm_num
  linarith

/-- Certified lower bound `0.8877906457 ≤ arctan 1.2290381`. -/
theorem le_arctan_right : (0.8877906457 : ℝ) ≤ Real.arctan (12290381 / 10000000 : ℝ) := by
  rw [arctan_eq_pi_div_four_add (by norm_num)]
  have hpi : (3.141592 : ℝ) < π := Real.pi_gt_d6
  have h := arctan_taylor_seven_le
    (y := ((12290381 / 10000000 - 1) / (12290381 / 10000000 + 1) : ℝ)) (by norm_num)
  have h3 : (0.1023926457 : ℝ) ≤
      ((12290381 / 10000000 - 1) / (12290381 / 10000000 + 1) : ℝ) -
      ((12290381 / 10000000 - 1) / (12290381 / 10000000 + 1) : ℝ) ^ 3 / 3 +
      ((12290381 / 10000000 - 1) / (12290381 / 10000000 + 1) : ℝ) ^ 5 / 5 -
      ((12290381 / 10000000 - 1) / (12290381 / 10000000 + 1) : ℝ) ^ 7 / 7 := by norm_num
  linarith

/-- At `t = 1.2290370` the logarithm is still strictly inside the unit circle. -/
theorem scalarLogNormSq_left_lt_one : scalarLogNormSq (12290370 / 10000000) < 1 := by
  have hL := log_one_add_sq_left_le
  have hL0 := log_one_add_sq_nonneg (12290370 / 10000000 : ℝ)
  have hA := arctan_left_le
  have hA0 : 0 ≤ Real.arctan (12290370 / 10000000 : ℝ) := Real.arctan_nonneg.2 (by norm_num)
  unfold scalarLogNormSq
  nlinarith

/-- At `t = 1.2290381` the logarithm is already strictly outside the unit circle. -/
theorem one_lt_scalarLogNormSq_right : 1 < scalarLogNormSq (12290381 / 10000000) := by
  have hL := le_log_one_add_sq_right
  have hA := le_arctan_right
  unfold scalarLogNormSq
  nlinarith

theorem scalarLogNorm_left_lt_one : scalarLogNorm (12290370 / 10000000) < 1 := by
  have h := scalarLogNormSq_left_lt_one
  nlinarith [scalarLogNorm_sq (12290370 / 10000000 : ℝ),
    scalarLogNorm_nonneg (12290370 / 10000000 : ℝ)]

theorem one_lt_scalarLogNorm_right : 1 < scalarLogNorm (12290381 / 10000000) := by
  have h := one_lt_scalarLogNormSq_right
  nlinarith [scalarLogNorm_sq (12290381 / 10000000 : ℝ),
    scalarLogNorm_nonneg (12290381 / 10000000 : ℝ)]

/-- **Certified existence in an interval of width `1.1 · 10⁻⁶`.** -/
theorem exists_scalarLogNorm_eq_one_mem_Icc :
    ∃ t ∈ Icc (12290370 / 10000000 : ℝ) (12290381 / 10000000), scalarLogNorm t = 1 := by
  have hab : (12290370 / 10000000 : ℝ) ≤ 12290381 / 10000000 := by norm_num
  have hone : (1 : ℝ) ∈
      Icc (scalarLogNorm (12290370 / 10000000)) (scalarLogNorm (12290381 / 10000000)) :=
    ⟨scalarLogNorm_left_lt_one.le, one_lt_scalarLogNorm_right.le⟩
  obtain ⟨t, ht, heq⟩ := intermediate_value_Icc hab continuous_scalarLogNorm.continuousOn hone
  exact ⟨t, ht, heq⟩

/-! ## 4.  The root and its characterisation -/

/-- **The quantum EML scalar-log root**: the unique positive parameter whose
principal logarithm `log (1 + t i)` lies on the unit circle. -/
def scalarLogRoot : ℝ := exists_scalarLogNorm_eq_one_mem_Icc.choose

/-- **Certified isolation of width `1.1 · 10⁻⁶`**: `scalarLogRoot ∈ [1.2290370, 1.2290381]`. -/
theorem scalarLogRoot_mem_Icc :
    scalarLogRoot ∈ Icc (12290370 / 10000000 : ℝ) (12290381 / 10000000) :=
  exists_scalarLogNorm_eq_one_mem_Icc.choose_spec.1

theorem scalarLogNorm_scalarLogRoot : scalarLogNorm scalarLogRoot = 1 :=
  exists_scalarLogNorm_eq_one_mem_Icc.choose_spec.2

theorem scalarLogRoot_pos : 0 < scalarLogRoot :=
  lt_of_lt_of_le (by norm_num) scalarLogRoot_mem_Icc.1

theorem scalarLogNormSq_scalarLogRoot : scalarLogNormSq scalarLogRoot = 1 := by
  rw [← scalarLogNorm_sq, scalarLogNorm_scalarLogRoot, one_pow]

/-- **Uniqueness.**  Every positive solution of the unit-circle equation equals
`scalarLogRoot`. -/
theorem eq_scalarLogRoot_of_pos {t : ℝ} (ht : 0 < t) (h : scalarLogNorm t = 1) :
    t = scalarLogRoot :=
  injOn_scalarLogNorm (mem_Ici.2 ht.le) (mem_Ici.2 scalarLogRoot_pos.le)
    (h.trans scalarLogNorm_scalarLogRoot.symm)

/-- Every positive solution lies in the certified interval. -/
theorem root_mem_Icc_of_pos {t : ℝ} (ht : 0 < t) (h : scalarLogNorm t = 1) :
    t ∈ Icc (12290370 / 10000000 : ℝ) (12290381 / 10000000) := by
  rw [eq_scalarLogRoot_of_pos ht h]
  exact scalarLogRoot_mem_Icc

/-! ## 5.  The derivative, simplicity of the root, and effective isolation -/

/-- **Closed-form derivative** of the squared logarithmic norm. -/
theorem hasDerivAt_scalarLogNormSq (t : ℝ) :
    HasDerivAt scalarLogNormSq ((t * Real.log (1 + t ^ 2) + 2 * Real.arctan t) / (1 + t ^ 2)) t := by
  have hpos : (0:ℝ) < 1 + t ^ 2 := by positivity
  have hlog : HasDerivAt (fun x : ℝ => Real.log (1 + x ^ 2)) (2 * t / (1 + t ^ 2)) t := by
    have h := ((hasDerivAt_pow 2 t).const_add (1:ℝ)).log hpos.ne'
    simpa using h.congr_deriv (by push_cast; ring)
  have h1 : HasDerivAt (fun x : ℝ => (Real.log (1 + x ^ 2) / 2) ^ 2)
      (2 * (Real.log (1 + t ^ 2) / 2) * (2 * t / (1 + t ^ 2) / 2)) t := by
    simpa using (hlog.div_const 2).pow 2
  have h2 : HasDerivAt (fun x : ℝ => (Real.arctan x) ^ 2)
      (2 * Real.arctan t * (1 / (1 + t ^ 2))) t := by
    simpa using (Real.hasDerivAt_arctan t).pow 2
  refine (h1.add h2).congr_deriv ?_
  field_simp

theorem deriv_scalarLogNormSq (t : ℝ) :
    deriv scalarLogNormSq t = (t * Real.log (1 + t ^ 2) + 2 * Real.arctan t) / (1 + t ^ 2) :=
  (hasDerivAt_scalarLogNormSq t).deriv

/-- **The root is a simple zero**: the derivative is bounded below by `2/3`
throughout `[1, 3/2]`, an interval containing the root. -/
theorem two_div_three_le_deriv_scalarLogNormSq {t : ℝ} (ht : t ∈ Icc (1:ℝ) (3/2)) :
    (2:ℝ) / 3 ≤ deriv scalarLogNormSq t := by
  obtain ⟨ht1, ht2⟩ := ht
  have hpos : (0:ℝ) < 1 + t ^ 2 := by positivity
  have hden : 1 + t ^ 2 ≤ 13 / 4 := by nlinarith
  have hlog : (0.6931471803 : ℝ) ≤ Real.log (1 + t ^ 2) := by
    have h2 : (2:ℝ) ≤ 1 + t ^ 2 := by nlinarith
    have := Real.log_le_log (by norm_num : (0:ℝ) < 2) h2
    have hl2 : (0.6931471803 : ℝ) < Real.log 2 := Real.log_two_gt_d9
    linarith
  have harc : (0.785398 : ℝ) ≤ Real.arctan t := by
    have h := Real.arctan_mono ht1
    rw [Real.arctan_one] at h
    have hpi : (3.141592 : ℝ) < π := Real.pi_gt_d6
    linarith
  rw [deriv_scalarLogNormSq, le_div_iff₀ hpos]
  nlinarith

/-- Quantitative monotonicity: the increment of `scalarLogNormSq` dominates
`(2/3)` times the increment of the parameter on `[1, 3/2]`. -/
theorem two_div_three_mul_sub_le_sub {s t : ℝ} (hs : s ∈ Icc (1:ℝ) (3/2))
    (ht : t ∈ Icc (1:ℝ) (3/2)) (hst : s ≤ t) :
    (2:ℝ) / 3 * (t - s) ≤ scalarLogNormSq t - scalarLogNormSq s := by
  have hdiff : Differentiable ℝ scalarLogNormSq := fun x => (hasDerivAt_scalarLogNormSq x).differentiableAt
  refine (convex_Icc (1:ℝ) (3/2)).mul_sub_le_image_sub_of_le_deriv
    hdiff.continuous.continuousOn hdiff.differentiableOn ?_ s hs t ht hst
  intro x hx
  rw [interior_Icc] at hx
  exact two_div_three_le_deriv_scalarLogNormSq ⟨hx.1.le, hx.2.le⟩

theorem scalarLogRoot_mem_Icc_one_three_halves : scalarLogRoot ∈ Icc (1:ℝ) (3/2) := by
  obtain ⟨h1, h2⟩ := scalarLogRoot_mem_Icc
  exact ⟨by linarith, by linarith⟩

/-- **Effective root isolation.**  Any parameter in `[1, 3/2]` whose residual
`|scalarLogNormSq t - 1|` is small is correspondingly close to the root: this
converts numerical evidence into certified proximity. -/
theorem abs_sub_scalarLogRoot_le {t : ℝ} (ht : t ∈ Icc (1:ℝ) (3/2)) :
    |t - scalarLogRoot| ≤ 3 / 2 * |scalarLogNormSq t - 1| := by
  have hr := scalarLogRoot_mem_Icc_one_three_halves
  have hroot := scalarLogNormSq_scalarLogRoot
  have habs := le_abs_self (scalarLogNormSq t - 1)
  have habs' := neg_abs_le (scalarLogNormSq t - 1)
  rcases le_total t scalarLogRoot with h | h
  · have hle := two_div_three_mul_sub_le_sub ht hr h
    rw [hroot] at hle
    rw [abs_of_nonpos (by linarith)]
    linarith
  · have hle := two_div_three_mul_sub_le_sub hr ht h
    rw [hroot] at hle
    rw [abs_of_nonneg (by linarith)]
    linarith

/-! ## 6.  Effective irrationality: no rational with denominator `≤ 1287` -/

set_option maxRecDepth 40000 in
/-- The arithmetic core: for every denominator `q ≤ 1287`, the interval
`[1.2290370 q, 1.2290381 q]` contains no integer. -/
private theorem no_integer_in_scaled_interval :
    ∀ q < 1288, 0 < q → 12290381 * q < ((12290370 * q + 9999999) / 10000000) * 10000000 := by decide

/-- **Effective irrationality bound.**  The quantum EML scalar-log root is not
a rational number of denominator at most `1287`.  Equivalently, if
`scalarLogRoot = p / q` in lowest terms then `q ≥ 1288`. -/
theorem scalarLogRoot_ne_rat_of_den_le (r : ℚ) (hden : r.den ≤ 1287) :
    (r : ℝ) ≠ scalarLogRoot := by
  intro hr
  obtain ⟨h1, h2⟩ := scalarLogRoot_mem_Icc
  have hq0 : 0 < r.den := r.pos
  have ha : ((12290370 / 10000000 : ℚ) : ℝ) ≤ (r : ℝ) := by rw [hr]; push_cast; linarith
  have hb : ((r : ℚ) : ℝ) ≤ ((12290381 / 10000000 : ℚ) : ℝ) := by rw [hr]; push_cast; linarith
  have ha' : (12290370 / 10000000 : ℚ) ≤ r := by exact_mod_cast ha
  have hb' : r ≤ (12290381 / 10000000 : ℚ) := by exact_mod_cast hb
  have hnd : r * (r.den : ℚ) = (r.num : ℚ) := Rat.mul_den_eq_num r
  have hqpos : (0:ℚ) < (r.den : ℚ) := by exact_mod_cast hq0
  have hA : (12290370 : ℚ) * r.den ≤ 10000000 * r.num := by
    have := mul_le_mul_of_nonneg_right ha' hqpos.le
    rw [hnd] at this
    linarith
  have hB : (10000000 : ℚ) * r.num ≤ 12290381 * r.den := by
    have := mul_le_mul_of_nonneg_right hb' hqpos.le
    rw [hnd] at this
    linarith
  have hA' : (12290370 : ℤ) * r.den ≤ 10000000 * r.num := by exact_mod_cast hA
  have hB' : (10000000 : ℤ) * r.num ≤ 12290381 * r.den := by exact_mod_cast hB
  have hnum : 0 < r.num := by
    have : (0:ℤ) < 12290370 * r.den := by positivity
    omega
  obtain ⟨P, hP⟩ : ∃ P : ℕ, r.num = (P : ℤ) := ⟨r.num.toNat, by omega⟩
  rw [hP] at hA' hB'
  have hA'' : 12290370 * r.den ≤ 10000000 * P := by exact_mod_cast hA'
  have hB'' : 10000000 * P ≤ 12290381 * r.den := by exact_mod_cast hB'
  have hk := no_integer_in_scaled_interval r.den (by omega) hq0
  have hcb : (12290370 * r.den + 9999999) / 10000000 ≤ P := by
    rw [Nat.div_le_iff_le_mul_add_pred (by norm_num)]
    omega
  have h5 : ((12290370 * r.den + 9999999) / 10000000) * 10000000 ≤ 12290381 * r.den :=
    le_trans (Nat.mul_le_mul_right _ hcb) (by omega)
  omega

/-! ## 7.  The radius map is a bijection of `[0, ∞)` -/

theorem scalarLogNorm_zero : scalarLogNorm 0 = 0 := by simp [scalarLogNorm]

/-- A crude but explicit growth bound: `‖log (1 + e^r i)‖ ≥ r`. -/
theorem le_scalarLogNorm_exp (r : ℝ) : r ≤ scalarLogNorm (Real.exp r) := by
  have hlog : r ≤ Real.log (1 + Real.exp r ^ 2) / 2 := by
    have h1 : Real.exp r ^ 2 = Real.exp (2 * r) := by rw [← Real.exp_nat_mul]; ring_nf
    have h2 : Real.exp (2 * r) ≤ 1 + Real.exp r ^ 2 := by rw [h1]; linarith
    have h3 := Real.log_le_log (Real.exp_pos (2 * r)) h2
    rw [Real.log_exp] at h3
    linarith
  have hL0 : 0 ≤ Real.log (1 + Real.exp r ^ 2) := log_one_add_sq_nonneg _
  have hsq : (Real.log (1 + Real.exp r ^ 2) / 2) ^ 2 ≤ scalarLogNormSq (Real.exp r) := by
    unfold scalarLogNormSq; nlinarith [sq_nonneg (Real.arctan (Real.exp r))]
  rw [scalarLogNorm_eq_sqrt]
  calc r ≤ Real.log (1 + Real.exp r ^ 2) / 2 := hlog
    _ = Real.sqrt ((Real.log (1 + Real.exp r ^ 2) / 2) ^ 2) := by
        rw [Real.sqrt_sq (by linarith)]
    _ ≤ Real.sqrt (scalarLogNormSq (Real.exp r)) := Real.sqrt_le_sqrt hsq

/-- **The radius map is a bijection of `[0, ∞)`.**  Together with strict
monotonicity this exhibits `t ↦ ‖log (1 + t i)‖` as an order isomorphism of the
nonnegative half-line; the unit-circle problem is the fibre over `1`. -/
theorem bijOn_scalarLogNorm : BijOn scalarLogNorm (Ici (0:ℝ)) (Ici (0:ℝ)) := by
  refine ⟨fun t _ => mem_Ici.2 (scalarLogNorm_nonneg t), injOn_scalarLogNorm, ?_⟩
  intro r hr
  have hr0 : (0:ℝ) ≤ r := mem_Ici.1 hr
  have hT : (0:ℝ) ≤ Real.exp r := (Real.exp_pos r).le
  have hmem : r ∈ Icc (scalarLogNorm 0) (scalarLogNorm (Real.exp r)) := by
    rw [scalarLogNorm_zero]
    exact ⟨hr0, le_scalarLogNorm_exp r⟩
  obtain ⟨t, ht, hteq⟩ := intermediate_value_Icc hT continuous_scalarLogNorm.continuousOn hmem
  exact ⟨t, mem_Ici.2 ht.1, hteq⟩

/-- **The radius map as an order isomorphism.**  Packaging the previous two
results: `t ↦ ‖log (1 + t i)‖` is an order isomorphism of `[0, ∞)` with itself. -/
def scalarLogNormOrderIso : Ici (0:ℝ) ≃o Ici (0:ℝ) :=
  StrictMono.orderIsoOfSurjective
    (fun t : Ici (0:ℝ) => (⟨scalarLogNorm t, bijOn_scalarLogNorm.1 t.2⟩ : Ici (0:ℝ)))
    (fun a b hab => strictMonoOn_scalarLogNorm a.2 b.2 hab)
    (by
      rintro ⟨r, hr⟩
      obtain ⟨t, ht, hteq⟩ := bijOn_scalarLogNorm.2.2 hr
      exact ⟨⟨t, ht⟩, by simpa [Subtype.ext_iff] using hteq⟩)

@[simp] theorem scalarLogNormOrderIso_apply (t : Ici (0:ℝ)) :
    (scalarLogNormOrderIso t : ℝ) = scalarLogNorm t := rfl

/-! ## 8.  Reflection symmetry and the complete classification of solutions -/

theorem scalarLogNormSq_neg (t : ℝ) : scalarLogNormSq (-t) = scalarLogNormSq t := by
  unfold scalarLogNormSq
  rw [Real.arctan_neg, neg_pow, neg_pow]
  ring_nf

theorem scalarLogNorm_neg (t : ℝ) : scalarLogNorm (-t) = scalarLogNorm t := by
  rw [scalarLogNorm_eq_sqrt, scalarLogNorm_eq_sqrt, scalarLogNormSq_neg]

/-- **Complete classification.**  The principal logarithm `log (1 + t i)` lies
on the unit circle for exactly two real parameters, `± scalarLogRoot`. -/
theorem scalarLogNorm_eq_one_iff {t : ℝ} :
    scalarLogNorm t = 1 ↔ t = scalarLogRoot ∨ t = -scalarLogRoot := by
  constructor
  · intro h
    rcases lt_trichotomy t 0 with ht | ht | ht
    · right
      have hneg : scalarLogNorm (-t) = 1 := by rw [scalarLogNorm_neg]; exact h
      have := eq_scalarLogRoot_of_pos (by linarith) hneg
      linarith
    · exfalso
      rw [ht, scalarLogNorm_zero] at h
      norm_num at h
    · exact Or.inl (eq_scalarLogRoot_of_pos ht h)
  · rintro (rfl | rfl)
    · exact scalarLogNorm_scalarLogRoot
    · rw [scalarLogNorm_neg]; exact scalarLogNorm_scalarLogRoot

/-! ## 9.  Spectral rigidity of unitary logarithmic activations -/

section Spectral

variable {n : Type*} [Fintype n] [DecidableEq n]

theorem conj_mul_self_eq_one_iff (z : ℂ) : (starRingEnd ℂ) z * z = 1 ↔ ‖z‖ = 1 := by
  rw [mul_comm, Complex.mul_conj]
  constructor
  · intro h
    have hz : Complex.normSq z = 1 := by exact_mod_cast h
    rw [Complex.normSq_eq_norm_sq] at hz
    nlinarith [norm_nonneg z]
  · intro h
    rw [Complex.normSq_eq_norm_sq, h]
    norm_num

/-- A diagonal matrix is unitary exactly when all its diagonal entries are
unimodular. -/
theorem diagonal_mem_unitary_iff (v : n → ℂ) :
    Matrix.diagonal v ∈ unitary (Matrix n n ℂ) ↔ ∀ i, ‖v i‖ = 1 := by
  have hstar : star (Matrix.diagonal v) = Matrix.diagonal (fun i => (starRingEnd ℂ) (v i)) :=
    Matrix.diagonal_conjTranspose v
  constructor
  · intro h i
    have h1 := h.1
    rw [hstar, Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one] at h1
    have h2 := congrFun (Matrix.diagonal_injective h1) i
    exact (conj_mul_self_eq_one_iff (v i)).1 (by simpa using h2)
  · intro h
    have h1 : ∀ i, (starRingEnd ℂ) (v i) * v i = 1 :=
      fun i => (conj_mul_self_eq_one_iff (v i)).2 (h i)
    constructor
    · rw [hstar, Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
      congr 1
      funext i
      simpa using h1 i
    · rw [hstar, Matrix.diagonal_mul_diagonal, ← Matrix.diagonal_one]
      congr 1
      funext i
      have h2 := h1 i
      rw [mul_comm] at h2
      simpa using h2

/-- Unitary conjugation preserves and reflects unitarity. -/
theorem unitary_conj_mem_iff {V A : Matrix n n ℂ} (hV : V ∈ unitary (Matrix n n ℂ)) :
    V * A * star V ∈ unitary (Matrix n n ℂ) ↔ A ∈ unitary (Matrix n n ℂ) := by
  constructor
  · intro h
    have hA : A = star V * (V * A * star V) * V := by
      have h1 : star V * V = 1 := hV.1
      calc A = (star V * V) * A * (star V * V) := by rw [h1, one_mul, mul_one]
        _ = star V * (V * A * star V) * V := by noncomm_ring
    rw [hA]
    exact mul_mem (mul_mem (Unitary.star_mem hV) h) hV
  · intro h
    exact mul_mem (mul_mem hV h) (Unitary.star_mem hV)

/-- **Spectral rigidity of the logarithmic activation.**  Let `H = V D V⋆` be a
Hermitian matrix presented through its spectral decomposition, with real
eigenvalues `d i`.  The logarithmic activation `log (I + i H)`, i.e. the matrix
`V · diag (log (1 + i d)) · V⋆`, is unitary **iff every eigenvalue of `H` is
`± scalarLogRoot`**.  Thus unitarity of the quantum EML activation is not a
generic property: it pins the entire spectrum of the Hamiltonian to the two
certified values `± 1.2290375…`. -/
theorem spectral_log_activation_mem_unitary_iff {V : Matrix n n ℂ}
    (hV : V ∈ unitary (Matrix n n ℂ)) (d : n → ℝ) :
    V * Matrix.diagonal (fun i => Complex.log (1 + (d i : ℂ) * I)) * star V ∈
        unitary (Matrix n n ℂ) ↔ ∀ i, d i = scalarLogRoot ∨ d i = -scalarLogRoot := by
  rw [unitary_conj_mem_iff hV, diagonal_mem_unitary_iff]
  exact forall_congr' fun i => scalarLogNorm_eq_one_iff (t := d i)

/-- The scalar case `n = 1` of spectral rigidity, stated without a conjugating
unitary: `log (1 + t i) • 1` is unitary iff `t = ± scalarLogRoot`. -/
theorem smul_one_mem_unitary_iff [Nonempty n] (t : ℝ) :
    Complex.log (1 + (t : ℂ) * I) • (1 : Matrix n n ℂ) ∈ unitary (Matrix n n ℂ) ↔
      t = scalarLogRoot ∨ t = -scalarLogRoot := by
  rw [Matrix.smul_one_eq_diagonal, diagonal_mem_unitary_iff]
  constructor
  · intro h
    exact scalarLogNorm_eq_one_iff.1 (h (Classical.arbitrary n))
  · intro h _
    exact scalarLogNorm_eq_one_iff.2 h

/-- Unitary conjugation of a scalar matrix. -/
theorem conj_eq_smul_one_iff {V A : Matrix n n ℂ} (hV : V ∈ unitary (Matrix n n ℂ)) (c : ℂ) :
    V * A * star V = c • (1 : Matrix n n ℂ) ↔ A = c • (1 : Matrix n n ℂ) := by
  have h1 : star V * V = 1 := hV.1
  have h2 : V * star V = 1 := hV.2
  constructor
  · intro h
    calc A = star V * (V * A * star V) * V := by
          calc A = (star V * V) * A * (star V * V) := by rw [h1, one_mul, mul_one]
            _ = star V * (V * A * star V) * V := by noncomm_ring
      _ = star V * (c • (1 : Matrix n n ℂ)) * V := by rw [h]
      _ = c • (1 : Matrix n n ℂ) := by rw [mul_smul_comm, mul_one, smul_mul_assoc, h1]
  · rintro rfl
    rw [mul_smul_comm, mul_one, smul_mul_assoc, h2]

theorem conj_sq {V A : Matrix n n ℂ} (hV : V ∈ unitary (Matrix n n ℂ)) :
    (V * A * star V) ^ 2 = V * A ^ 2 * star V := by
  have h1 : star V * V = 1 := hV.1
  calc (V * A * star V) ^ 2 = V * A * (star V * V) * A * star V := by noncomm_ring
    _ = V * A ^ 2 * star V := by rw [h1]; noncomm_ring

theorem diagonal_sq_eq_smul_one_iff (d : n → ℝ) (c : ℝ) :
    (Matrix.diagonal (fun i => ((d i : ℝ) : ℂ))) ^ 2 = ((c ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ) ↔
      ∀ i, d i = c ∨ d i = -c := by
  rw [pow_two, Matrix.diagonal_mul_diagonal, Matrix.smul_one_eq_diagonal]
  constructor
  · intro h i
    have h2 := congrFun (Matrix.diagonal_injective h) i
    have h3 : (d i) ^ 2 = c ^ 2 := by
      have hc : ((d i : ℝ) : ℂ) * ((d i : ℝ) : ℂ) = ((c ^ 2 : ℝ) : ℂ) := h2
      have h4 : ((d i * d i : ℝ) : ℂ) = ((c ^ 2 : ℝ) : ℂ) := by
        push_cast at hc ⊢; linear_combination hc
      have h5 := Complex.ofReal_injective h4
      nlinarith [h5]
    have hf : (d i - c) * (d i + c) = 0 := by nlinarith
    rcases mul_eq_zero.1 hf with h5 | h5
    · left; linarith
    · right; linarith
  · intro h
    congr 1
    funext i
    rcases h i with h5 | h5 <;> rw [h5] <;> push_cast <;> ring

/-- **Two-level rigidity.**  In the same spectral presentation, the logarithmic
activation is unitary exactly when the Hermitian matrix `H = V D V⋆` satisfies
the quadratic relation `H ² = scalarLogRoot ² · I`; equivalently `H` is
`scalarLogRoot` times a self-adjoint involution, i.e. a two-level Hamiltonian
whose levels are the two certified values `± scalarLogRoot`. -/
theorem spectral_log_activation_mem_unitary_iff_sq {V : Matrix n n ℂ}
    (hV : V ∈ unitary (Matrix n n ℂ)) (d : n → ℝ) :
    V * Matrix.diagonal (fun i => Complex.log (1 + (d i : ℂ) * I)) * star V ∈
        unitary (Matrix n n ℂ) ↔
      (V * Matrix.diagonal (fun i => ((d i : ℝ) : ℂ)) * star V) ^ 2 =
        ((scalarLogRoot ^ 2 : ℝ) : ℂ) • (1 : Matrix n n ℂ) := by
  rw [spectral_log_activation_mem_unitary_iff hV, ← diagonal_sq_eq_smul_one_iff d scalarLogRoot,
    conj_sq hV, conj_eq_smul_one_iff hV]

end Spectral

/-! ## 10.  Conditional transcendence of the root -/

/-- Transfer of algebraicity from `ℝ` to `ℂ`. -/
theorem isAlgebraic_ofReal {t : ℝ} (h : IsAlgebraic ℚ t) : IsAlgebraic ℚ ((t : ℂ)) :=
  h.algHom (Complex.ofRealAm.restrictScalars ℚ)

theorem isAlgebraic_I : IsAlgebraic ℚ Complex.I := by
  refine ⟨Polynomial.X ^ 2 + 1, ?_, ?_⟩
  · intro hc
    have h := congrArg (Polynomial.coeff · 2) hc
    simp [Polynomial.coeff_one] at h
  · simp [Polynomial.aeval]

/-- The unit-circle equation at an algebraic parameter would produce two
logarithms of algebraic numbers whose product is `1`. -/
theorem log_mul_log_conj_eq_one_of_scalarLogNorm_eq_one {t : ℝ} (h : scalarLogNorm t = 1) :
    Complex.log (1 + (t : ℂ) * I) * Complex.log (1 + ((-t : ℝ) : ℂ) * I) = 1 := by
  have harg : (1 + (t : ℂ) * I).arg ≠ π := by
    rw [arg_one_add_mul_I]
    have h1 := Real.arctan_lt_pi_div_two t
    have h2 : π / 2 < π := by linarith [Real.pi_pos]
    linarith
  have hconj : (starRingEnd ℂ) (1 + (t : ℂ) * I) = 1 + ((-t : ℝ) : ℂ) * I := by
    simp
  have hlog : Complex.log (1 + ((-t : ℝ) : ℂ) * I) =
      (starRingEnd ℂ) (Complex.log (1 + (t : ℂ) * I)) := by
    rw [← hconj, Complex.log_conj _ harg]
  rw [hlog, Complex.mul_conj, Complex.normSq_eq_norm_sq]
  rw [show ‖Complex.log (1 + (t : ℂ) * I)‖ = 1 from h]
  norm_num

/-- **Conditional transcendence.**  Assume the (open) conjecture that the
product of the principal logarithms of two algebraic numbers is never `1` —
a statement implied by the four exponentials conjecture, and hence by
Schanuel's conjecture.  Then the quantum EML scalar-log root is
transcendental.

The hypothesis is supplied as an explicit assumption, not as an axiom; the
theorem is therefore an unconditional implication. -/
theorem transcendental_scalarLogRoot
    (H : ∀ z w : ℂ, IsAlgebraic ℚ z → IsAlgebraic ℚ w → Complex.log z * Complex.log w ≠ 1) :
    Transcendental ℚ scalarLogRoot := by
  intro halg
  have hz : IsAlgebraic ℚ (1 + (scalarLogRoot : ℂ) * I) :=
    (isAlgebraic_one).add ((isAlgebraic_ofReal halg).mul isAlgebraic_I)
  have hw : IsAlgebraic ℚ (1 + ((-scalarLogRoot : ℝ) : ℂ) * I) :=
    (isAlgebraic_one).add ((isAlgebraic_ofReal halg.neg).mul isAlgebraic_I)
  exact H _ _ hz hw (log_mul_log_conj_eq_one_of_scalarLogNorm_eq_one scalarLogNorm_scalarLogRoot)

end QuantumEML