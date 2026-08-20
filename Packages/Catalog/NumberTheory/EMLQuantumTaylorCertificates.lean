import Mathlib

/-!
# Certified rational Taylor bounds for `arctan` and `log`

This file develops the *numerical certification toolkit* that is used in
`Catalog/NumberTheory/EMLQuantumScalarLogRootIsolation.lean` to isolate the
unique positive solution of the quantum EML scalar-log unit-circle equation
`‖log (1 + t i)‖ = 1` to within `4 · 10⁻⁵`.

The earlier instalments of this thread
(`Catalog/NumberTheory/EMLQuantumScalarLog.lean`,
`Catalog/NumberTheory/EMLQuantumScalarLogSharp.lean`,
`Catalog/NumberTheory/EMLQuantumUnitaryExponential.lean`) could only use the
crude one-term estimates `y / (1 + y ^ 2) ≤ arctan y ≤ y` and
`1 - x⁻¹ ≤ log x ≤ x - 1`, which certified the root only to within `1/20`.
The bounds proved here are *two-sided Taylor certificates with explicit
remainder control*:

* `QuantumEML.Certificates.sub_cube_div_three_le_arctan` :
  `y - y ^ 3 / 3 ≤ arctan y`,
* `QuantumEML.Certificates.arctan_le_taylor_five` :
  `arctan y ≤ y - y ^ 3 / 3 + y ^ 5 / 5`,
* `QuantumEML.Certificates.taylor_le_log_ratio` :
  `2 u + 2 u ^ 3 / 3 ≤ log (1 + u) - log (1 - u)`,
* `QuantumEML.Certificates.log_ratio_le_taylor` :
  `log (1 + u) - log (1 - u) ≤ 2 u + (2/3) u ^ 3 / (1 - u ^ 2)`,
  a *geometric-tail* remainder bound, i.e. the exact sum of the majorising
  geometric series `∑_{k ≥ 1} (2/3) u ^ (2k+1)`.

All four are proved by the same structural mechanism: the difference of the
two sides has derivative

* `y ^ 4 / (1 + y ^ 2)`, `y ^ 6 / (1 + y ^ 2)` (arctan case),
* `2 u ^ 4 / (1 - u ^ 2)`, `(4/3) u ^ 4 / (1 - u ^ 2) ^ 2` (logarithm case),

which is manifestly nonnegative, so the difference is monotone and vanishes at
the origin.  The pattern `remainder = (next power) / (denominator of the
generating rational function)` is the structural observation that makes the
two families uniform.

The Möbius change of variables `u = (x - 1) / (x + 1)` (`log_eq_log_ratio`)
turns the logarithm bounds into two-sided rational bounds for `log x` at any
rational `x ≥ 1`, and the tangent addition law (`arctan_eq_pi_div_four_add`)
does the same for `arctan` at arguments near `1`.  Together they give
certified rational enclosures of arbitrary (fixed) accuracy.
-/

noncomputable section

open Real Set

namespace QuantumEML.Certificates

/-! ### Two-sided Taylor certificates for `arctan` -/

/-- **Lower Taylor certificate for `arctan`.**  For `y ≥ 0` we have
`y - y ^ 3 / 3 ≤ arctan y`; the difference has derivative `y ^ 4 / (1 + y ^ 2) ≥ 0`. -/
theorem sub_cube_div_three_le_arctan {y : ℝ} (hy : 0 ≤ y) : y - y ^ 3 / 3 ≤ Real.arctan y := by
  set g : ℝ → ℝ := fun x => Real.arctan x - (x - x ^ 3 / 3) with hg
  have hd : ∀ x : ℝ, HasDerivAt g (x ^ 4 / (1 + x ^ 2)) x := by
    intro x
    have h1 : HasDerivAt Real.arctan (1 / (1 + x ^ 2)) x := Real.hasDerivAt_arctan x
    have h2 : HasDerivAt (fun x : ℝ => x - x ^ 3 / 3) (1 - x ^ 2) x := by
      simpa using ((hasDerivAt_id x).sub ((hasDerivAt_pow 3 x).div_const 3)).congr_deriv (by
        push_cast; ring)
    refine (h1.sub h2).congr_deriv ?_
    have hpos : (0:ℝ) < 1 + x ^ 2 := by positivity
    field_simp
    ring
  have hmono : Monotone g := monotone_of_hasDerivAt_nonneg hd (by intro x; positivity)
  have h := hmono hy
  simp only [hg] at h
  simpa using h

/-- **Upper Taylor certificate for `arctan`.**  For `y ≥ 0` we have
`arctan y ≤ y - y ^ 3 / 3 + y ^ 5 / 5`; the difference has derivative
`y ^ 6 / (1 + y ^ 2) ≥ 0`. -/
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

/-! ### Two-sided Taylor certificates for the logarithm -/

/-- **Lower Taylor certificate for the logarithmic ratio.**  For `0 ≤ u < 1`,
`2 u + 2 u ^ 3 / 3 ≤ log (1 + u) - log (1 - u)`. -/
theorem taylor_le_log_ratio {u : ℝ} (hu : 0 ≤ u) (hu1 : u < 1) :
    2 * u + 2 * u ^ 3 / 3 ≤ Real.log (1 + u) - Real.log (1 - u) := by
  set g : ℝ → ℝ := fun x => (Real.log (1 + x) - Real.log (1 - x)) - (2 * x + 2 * x ^ 3 / 3) with hg
  have hd : ∀ x ∈ Ico (0:ℝ) 1, HasDerivAt g (2 * x ^ 4 / (1 - x ^ 2)) x := by
    rintro x ⟨hx0, hx1⟩
    have hp : (0:ℝ) < 1 + x := by linarith
    have hm : (0:ℝ) < 1 - x := by linarith
    have h1 : HasDerivAt (fun y : ℝ => Real.log (1 + y)) (1 / (1 + x)) x := by
      simpa using ((hasDerivAt_id x).const_add (1:ℝ)).log hp.ne'
    have h2 : HasDerivAt (fun y : ℝ => Real.log (1 - y)) (-1 / (1 - x)) x := by
      simpa using ((hasDerivAt_id x).const_sub (1:ℝ)).log hm.ne'
    have h3 : HasDerivAt (fun y : ℝ => 2 * y + 2 * y ^ 3 / 3) (2 + 2 * x ^ 2) x := by
      have ha : HasDerivAt (fun y : ℝ => 2 * y) (2:ℝ) x := by
        simpa using (hasDerivAt_id x).const_mul (2:ℝ)
      have hb : HasDerivAt (fun y : ℝ => 2 * y ^ 3 / 3) (2 * x ^ 2) x := by
        simpa using (((hasDerivAt_pow 3 x).const_mul (2:ℝ)).div_const 3).congr_deriv (by
          push_cast; ring)
      exact ha.add hb
    refine ((h1.sub h2).sub h3).congr_deriv ?_
    have hne : (1 - x ^ 2) ≠ 0 := by nlinarith
    field_simp
    ring
  have hcont : ContinuousOn g (Ico 0 1) := fun x hx => (hd x hx).continuousAt.continuousWithinAt
  have hmono : MonotoneOn g (Ico (0:ℝ) 1) := by
    refine monotoneOn_of_hasDerivWithinAt_nonneg (convex_Ico _ _) hcont
      (f' := fun x => 2 * x ^ 4 / (1 - x ^ 2)) ?_ ?_
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

/-- **Upper Taylor certificate for the logarithmic ratio.**  For `0 ≤ u < 1`,
`log (1 + u) - log (1 - u) ≤ 2 u + (2/3) u ^ 3 / (1 - u ^ 2)`, the right-hand
side being the exact sum of the geometric majorant of the tail. -/
theorem log_ratio_le_taylor {u : ℝ} (hu : 0 ≤ u) (hu1 : u < 1) :
    Real.log (1 + u) - Real.log (1 - u) ≤ 2 * u + (2 / 3) * u ^ 3 / (1 - u ^ 2) := by
  set g : ℝ → ℝ := fun x => (2 * x + (2 / 3) * x ^ 3 / (1 - x ^ 2)) -
      (Real.log (1 + x) - Real.log (1 - x)) with hg
  have hd : ∀ x ∈ Ico (0:ℝ) 1, HasDerivAt g ((4 / 3) * x ^ 4 / (1 - x ^ 2) ^ 2) x := by
    rintro x ⟨hx0, hx1⟩
    have hp : (0:ℝ) < 1 + x := by linarith
    have hm : (0:ℝ) < 1 - x := by linarith
    have hs : (0:ℝ) < 1 - x ^ 2 := by nlinarith
    have h1 : HasDerivAt (fun y : ℝ => Real.log (1 + y)) (1 / (1 + x)) x := by
      simpa using ((hasDerivAt_id x).const_add (1:ℝ)).log hp.ne'
    have h2 : HasDerivAt (fun y : ℝ => Real.log (1 - y)) (-1 / (1 - x)) x := by
      simpa using ((hasDerivAt_id x).const_sub (1:ℝ)).log hm.ne'
    have hnum : HasDerivAt (fun y : ℝ => (2 / 3) * y ^ 3) (2 * x ^ 2) x := by
      simpa using ((hasDerivAt_pow 3 x).const_mul (2 / 3 : ℝ)).congr_deriv (by push_cast; ring)
    have hden : HasDerivAt (fun y : ℝ => 1 - y ^ 2) (-(2 * x)) x := by
      simpa using ((hasDerivAt_pow 2 x).const_sub (1:ℝ)).congr_deriv (by push_cast; ring)
    have hq : HasDerivAt (fun y : ℝ => (2 / 3) * y ^ 3 / (1 - y ^ 2))
        ((2 * x ^ 2 * (1 - x ^ 2) - (2 / 3) * x ^ 3 * (-(2 * x))) / (1 - x ^ 2) ^ 2) x :=
      hnum.div hden hs.ne'
    have hlin : HasDerivAt (fun y : ℝ => 2 * y) (2:ℝ) x := by
      simpa using (hasDerivAt_id x).const_mul (2:ℝ)
    refine ((hlin.add hq).sub (h1.sub h2)).congr_deriv ?_
    field_simp
    ring
  have hcont : ContinuousOn g (Ico 0 1) := fun x hx => (hd x hx).continuousAt.continuousWithinAt
  have hmono : MonotoneOn g (Ico (0:ℝ) 1) := by
    refine monotoneOn_of_hasDerivWithinAt_nonneg (convex_Ico _ _) hcont
      (f' := fun x => (4 / 3) * x ^ 4 / (1 - x ^ 2) ^ 2) ?_ ?_
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

/-! ### The Möbius change of variables and rational enclosures of `log` -/

/-- The Möbius substitution `u = (x - 1) / (x + 1)` maps `log x` to the
logarithmic ratio. -/
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

/-- **Rational lower enclosure of `log`.**  For `x ≥ 1` and `u = (x-1)/(x+1)`,
`2 u + 2 u ^ 3 / 3 ≤ log x`. -/
theorem taylor_le_log {x : ℝ} (hx : 1 ≤ x) :
    2 * ((x - 1) / (x + 1)) + 2 * ((x - 1) / (x + 1)) ^ 3 / 3 ≤ Real.log x := by
  have hx0 : (0:ℝ) < x := lt_of_lt_of_le one_pos hx
  have hx1 : (0:ℝ) < x + 1 := by linarith
  have hu0 : 0 ≤ (x - 1) / (x + 1) := div_nonneg (by linarith) hx1.le
  have hu1 : (x - 1) / (x + 1) < 1 := by
    rw [div_lt_one hx1]; linarith
  rw [log_eq_log_ratio hx0]
  exact taylor_le_log_ratio hu0 hu1

/-- **Rational upper enclosure of `log`.**  For `x ≥ 1` and `u = (x-1)/(x+1)`,
`log x ≤ 2 u + (2/3) u ^ 3 / (1 - u ^ 2)`. -/
theorem log_le_taylor {x : ℝ} (hx : 1 ≤ x) :
    Real.log x ≤ 2 * ((x - 1) / (x + 1)) +
      (2 / 3) * ((x - 1) / (x + 1)) ^ 3 / (1 - ((x - 1) / (x + 1)) ^ 2) := by
  have hx0 : (0:ℝ) < x := lt_of_lt_of_le one_pos hx
  have hx1 : (0:ℝ) < x + 1 := by linarith
  have hu0 : 0 ≤ (x - 1) / (x + 1) := div_nonneg (by linarith) hx1.le
  have hu1 : (x - 1) / (x + 1) < 1 := by
    rw [div_lt_one hx1]; linarith
  rw [log_eq_log_ratio hx0]
  exact log_ratio_le_taylor hu0 hu1

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

/-! ### The tangent addition law near `1` -/

/-- For `t > -1`, `arctan t = π/4 + arctan ((t - 1) / (t + 1))`; this is the
reduction that makes the Taylor certificates applicable at arguments near `1`. -/
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

end QuantumEML.Certificates