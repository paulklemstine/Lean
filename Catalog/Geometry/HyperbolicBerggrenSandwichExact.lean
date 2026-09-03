import Catalog.Geometry.HyperbolicBerggrenBranchExact

/-!
# Hyperbolic–Pythagorean Geodesics, cycle VII: the residual gap, exactly

Cycles V and VI bounded the *residual gap*

`gap m n = resid m n - residAsym m n
         = d(i, z(m,n)) - ½ log (m² + n²) - ½ log (1 + (n/m)²)`

from above, first by `1/c` (`resid_sandwich`) and then by `(n² + 1)/(c(c+1))`
(`resid_sub_residAsym_le_sharp`), where `c = m² + n²`.  Conjecture **F2** of
`FUTURE_DIRECTIONS.md` asked for the true size of the gap.  This file answers that question
with an *identity* and a two-sided bound that pins the gap to within a factor `(c+1)/(c-1)`.

## The identity

Writing `S = √((c+1)² - 4m²) = 2m·sinh d`, the exponential of the gap is *exactly*

`exp (gap m n) = ((c + 1) + S) / (2 c)`   (`exp_resid_sub_residAsym`),

so `exp (gap) - 1 = (S - (c - 1))/(2c)`.  The point of the whole cycle is the elementary
factorisation

`(S - (c-1))(S + (c-1)) = S² - (c-1)² = (c+1)² - 4m² - (c-1)² = 4(c - m²) = 4n²`,

which converts the *difference* of two nearly equal quantities into a *quotient*: no
cancellation is left, and since `2(c-1) ≤ S + (c-1) ≤ 2c` the quotient is squeezed between
`2n²/c` and `2n²/(c-1)`.

## Main results

* `exp_resid_sub_residAsym` : the exact formula `exp (gap) = ((c+1) + √((c+1)² - 4m²))/(2c)`.
* `exp_gap_bounds` : `n²/c² ≤ exp (gap) - 1 ≤ n²/(c(c-1))`.
* `resid_sub_residAsym_le_sharper` : `gap ≤ n²/(c(c-1))`, which is **strictly stronger** than
  the cycle-VI bound `(n²+1)/(c(c+1))` for every seed (`sharper_than_cycle_six`) — and
  qualitatively so: the true gap is of size `n²/c²`, whereas the cycle-VI bound never goes
  below `1/c²`, an overestimate by a factor `≍ m²/n²` at small slope.
* `resid_sub_residAsym_ge_sharp` : the matching lower bound `n²/(c² + n²) ≤ gap`.
* `resid_gap_two_sided_ratio` : **conjecture F2, closed.**  The two bounds differ by the
  factor `(c+1)/(c-1)`, so `gap = (n²/c²)(1 + O(1/c))` uniformly in the slope.
* `resid_gap_four_one` : at the seed `(4,1)`, where the cycle-VI bound gives only
  `gap ≤ 1/153 = 0.006536`, the new sandwich gives `1/290 ≤ gap ≤ 1/272`, i.e.
  `0.003448 ≤ gap ≤ 0.003676` (the true value is `0.0036543…`).
-/

namespace HyperbolicBerggrenGeodesics

open Real UpperHalfPlane

noncomputable section

/-! ## Part A. The exact formula for the exponential of the gap -/

/-- **The gap, exactly.**  `exp (resid m n - residAsym m n) = ((c+1) + √((c+1)² - 4m²))/(2c)`
with `c = m² + n²`.  Both ingredients are exact: `cosh d = (c+1)/(2m)` and
`2m·sinh d = √((c+1)² - 4m²)`. -/
theorem exp_resid_sub_residAsym {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    Real.exp (resid m n (lt_trans hn hnm) - residAsym m n)
      = (((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1)
          + Real.sqrt ((((m : ℝ) ^ 2 + (n : ℝ) ^ 2) + 1) ^ 2 - 4 * (m : ℝ) ^ 2))
        / (2 * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hcpos : 0 < c := by positivity
  set d := dist (hpoint m n hm) UpperHalfPlane.I with hd
  have hd0 : 0 ≤ d := dist_nonneg
  have hcosh : Real.cosh d = (c + 1) / (2 * m) := by rw [hd, cosh_dist_hpoint_I]
  have hsinh0 : 0 ≤ Real.sinh d := Real.sinh_nonneg_iff.mpr hd0
  have hsq : (2 * (m : ℝ) * Real.sinh d) ^ 2 = (c + 1) ^ 2 - 4 * (m : ℝ) ^ 2 := by
    have h := Real.cosh_sq_sub_sinh_sq d
    rw [hcosh] at h
    have h2 : ((c + 1) / (2 * (m : ℝ))) ^ 2 - Real.sinh d ^ 2 = 1 := h
    field_simp at h2
    nlinarith [h2]
  have hsqrt : Real.sqrt ((c + 1) ^ 2 - 4 * (m : ℝ) ^ 2) = 2 * (m : ℝ) * Real.sinh d := by
    rw [← hsq, Real.sqrt_sq (by positivity)]
  have hgap : resid m n (lt_trans hn hnm) - residAsym m n = d - Real.log c + Real.log m := by
    rw [resid, residAsym_eq_sub hm, ← hd, ← hcdef]; ring
  rw [hgap, hsqrt, Real.exp_add, Real.exp_sub, Real.exp_log hcpos, Real.exp_log hM]
  have hexp : Real.exp d = (c + 1) / (2 * (m : ℝ)) + Real.sinh d := by
    rw [← hcosh]; exact (Real.cosh_add_sinh d).symm
  rw [hexp]
  field_simp

/-! ## Part B. The two-sided bound on the gap -/

/-- **The heart of the cycle.**  `n²/c² ≤ exp (gap) - 1 ≤ n²/(c(c-1))`.  The proof is the
factorisation `(S - (c-1))(S + (c-1)) = 4n²` together with `2(c-1) ≤ S + (c-1) ≤ 2c`. -/
theorem exp_gap_bounds {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    (n : ℝ) ^ 2 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) ^ 2
        ≤ Real.exp (resid m n (lt_trans hn hnm) - residAsym m n) - 1
      ∧ Real.exp (resid m n (lt_trans hn hnm) - residAsym m n) - 1
        ≤ (n : ℝ) ^ 2 / (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) - 1)) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hN1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hNM : (n : ℝ) < (m : ℝ) := by exact_mod_cast hnm
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hc2 : (2 : ℝ) ≤ c := by nlinarith
  have hcpos : 0 < c := by linarith
  have harg : (0 : ℝ) ≤ (c + 1) ^ 2 - 4 * (m : ℝ) ^ 2 := by nlinarith [sq_nonneg ((m : ℝ) - 1)]
  set S : ℝ := Real.sqrt ((c + 1) ^ 2 - 4 * (m : ℝ) ^ 2) with hSdef
  have hS0 : 0 ≤ S := Real.sqrt_nonneg _
  have hS2 : S ^ 2 = (c + 1) ^ 2 - 4 * (m : ℝ) ^ 2 := Real.sq_sqrt harg
  -- the factorisation
  have hfac : (S - (c - 1)) * (S + (c - 1)) = 4 * (n : ℝ) ^ 2 := by
    have : S ^ 2 - (c - 1) ^ 2 = 4 * (n : ℝ) ^ 2 := by rw [hS2, hcdef]; ring
    nlinarith [this]
  have hSge : c - 1 ≤ S := by nlinarith [hS2, hS0, sq_nonneg (S - (c - 1)), hc2]
  have hSle : S ≤ c + 1 := by nlinarith [hS2, hS0, hc2]
  have hexp := exp_resid_sub_residAsym hn hnm
  rw [← hcdef, ← hSdef] at hexp
  have hEsub : Real.exp (resid m n (lt_trans hn hnm) - residAsym m n) - 1
      = (S - (c - 1)) / (2 * c) := by
    rw [hexp]; field_simp; ring
  rw [hEsub]
  have hSnn : (0 : ℝ) ≤ S - (c - 1) := by linarith
  have hlow2 : 2 * (n : ℝ) ^ 2 ≤ c * (S - (c - 1)) := by
    nlinarith [hfac, mul_nonneg hSnn (show (0 : ℝ) ≤ 2 * c - (S + (c - 1)) by linarith)]
  have hup2 : (S - (c - 1)) * (c - 1) ≤ 2 * (n : ℝ) ^ 2 := by
    nlinarith [hfac, sq_nonneg (S - (c - 1))]
  constructor
  · rw [div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [hlow2, hcpos]
  · rw [div_le_div_iff₀ (by positivity) (by nlinarith)]
    nlinarith [hup2, hcpos]

/-- **The sharper upper bound.**  `resid - residAsym ≤ n²/(c(c-1))`. -/
theorem resid_sub_residAsym_le_sharper {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    resid m n (lt_trans hn hnm) - residAsym m n
      ≤ (n : ℝ) ^ 2 / (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) - 1)) := by
  have h := (exp_gap_bounds hn hnm).2
  have hlin := Real.add_one_le_exp (resid m n (lt_trans hn hnm) - residAsym m n)
  linarith

/-- **The matching lower bound.**  `n²/(c² + n²) ≤ resid - residAsym`.  It comes from
`1 - 1/E ≤ log E` applied to the exact `E` of `exp_resid_sub_residAsym`. -/
theorem resid_sub_residAsym_ge_sharp {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    (n : ℝ) ^ 2 / ((((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) ^ 2 + (n : ℝ) ^ 2)
      ≤ resid m n (lt_trans hn hnm) - residAsym m n := by
  have hm : 0 < m := lt_trans hn hnm
  have hM1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hN1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hcpos : (0 : ℝ) < c := by positivity
  set g := resid m n (lt_trans hn hnm) - residAsym m n with hgdef
  have hlow := (exp_gap_bounds hn hnm).1
  rw [← hcdef, ← hgdef] at hlow
  have hEpos : (0 : ℝ) < Real.exp g := Real.exp_pos g
  -- `1 - exp (-g) ≤ g` is `x + 1 ≤ exp x` at `x = -g`
  have hlin := Real.add_one_le_exp (-g)
  have hinv : Real.exp (-g) = 1 / Real.exp g := by
    rw [Real.exp_neg]; ring
  rw [hinv] at hlin
  have hstep : 1 - 1 / Real.exp g ≤ g := by linarith
  have hE1 : 1 + (n : ℝ) ^ 2 / c ^ 2 ≤ Real.exp g := by linarith
  have hcalc : (n : ℝ) ^ 2 / (c ^ 2 + (n : ℝ) ^ 2) ≤ 1 - 1 / Real.exp g := by
    have hpos : (0 : ℝ) < 1 + (n : ℝ) ^ 2 / c ^ 2 := by positivity
    have h1 : 1 / Real.exp g ≤ 1 / (1 + (n : ℝ) ^ 2 / c ^ 2) :=
      one_div_le_one_div_of_le hpos hE1
    have h2 : 1 - 1 / (1 + (n : ℝ) ^ 2 / c ^ 2) = (n : ℝ) ^ 2 / (c ^ 2 + (n : ℝ) ^ 2) := by
      field_simp
      ring
    linarith [h1, h2]
  linarith

/-! ## Part C. Consequences -/

/-- **The new bound is strictly stronger than the cycle-VI one.**  For every Euclid seed
`n²/(c(c-1)) < (n²+1)/(c(c+1))`; the difference is a factor `≍ m²/n²` when the slope is
small, which is exactly the regime where the cycle-VI bound was weakest. -/
theorem sharper_than_cycle_six {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    (n : ℝ) ^ 2 / (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) - 1))
      < ((n : ℝ) ^ 2 + 1)
          / (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) + 1)) := by
  have hM1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast lt_trans hn hnm
  have hN1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hNM : (n : ℝ) < (m : ℝ) := by exact_mod_cast hnm
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hc2 : (2 : ℝ) ≤ c := by nlinarith
  have hkey : c - 1 - 2 * (n : ℝ) ^ 2 > 0 := by
    have : (n : ℝ) + 1 ≤ (m : ℝ) := by
      have : (n : ℕ) + 1 ≤ m := hnm
      exact_mod_cast this
    nlinarith
  rw [div_lt_div_iff₀ (by nlinarith) (by nlinarith)]
  nlinarith [hkey, hc2]

/-- **Conjecture F2, closed.**  The residual gap is determined to within the factor
`(c+1)/(c-1) = 1 + 2/(c-1)`: it lies between `n²/(c² + n²)` and `(c+1)/(c-1)` times that
quantity.  In particular `gap = (n²/c²)(1 + O(1/c))`, uniformly in the slope. -/
theorem resid_gap_two_sided_ratio {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    (n : ℝ) ^ 2 / ((((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) ^ 2 + (n : ℝ) ^ 2)
        ≤ resid m n (lt_trans hn hnm) - residAsym m n
      ∧ resid m n (lt_trans hn hnm) - residAsym m n
        ≤ (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) + 1) / (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) - 1)
            * ((n : ℝ) ^ 2 / ((((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) ^ 2 + (n : ℝ) ^ 2)) := by
  have hM1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast lt_trans hn hnm
  have hN1 : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hNM : (n : ℝ) < (m : ℝ) := by exact_mod_cast hnm
  refine ⟨resid_sub_residAsym_ge_sharp hn hnm, le_trans (resid_sub_residAsym_le_sharper hn hnm) ?_⟩
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hc2 : (2 : ℝ) ≤ c := by nlinarith
  have hnc : (n : ℝ) ^ 2 ≤ c := by nlinarith
  have hc1 : c - 1 ≠ 0 := ne_of_gt (by linarith)
  have hcne : c ≠ 0 := ne_of_gt (by linarith)
  have hden : c ^ 2 + (n : ℝ) ^ 2 ≠ 0 := by positivity
  rw [div_le_iff₀ (by nlinarith)]
  have hrw : (c + 1) / (c - 1) * ((n : ℝ) ^ 2 / (c ^ 2 + (n : ℝ) ^ 2)) * (c * (c - 1))
      = (c + 1) * c * (n : ℝ) ^ 2 / (c ^ 2 + (n : ℝ) ^ 2) := by
    field_simp
  rw [hrw, le_div_iff₀ (by positivity)]
  nlinarith [hnc, hc2, sq_nonneg ((n : ℝ))]

/-- **A concrete gain.**  At the Euclid seed `(4,1)` the cycle-VI bound gives only
`gap ≤ 2/(17·18) = 1/153`, while the new sandwich pins the gap into `[1/290, 1/272]`; the
true value is `0.0036543…`. -/
theorem resid_gap_four_one :
    (1 : ℝ) / 290 ≤ resid 4 1 (by norm_num) - residAsym 4 1
      ∧ resid 4 1 (by norm_num) - residAsym 4 1 ≤ (1 : ℝ) / 272 := by
  constructor
  · have h := resid_sub_residAsym_ge_sharp (m := 4) (n := 1) (by norm_num) (by norm_num)
    norm_num at h
    linarith
  · have h := resid_sub_residAsym_le_sharper (m := 4) (n := 1) (by norm_num) (by norm_num)
    norm_num at h
    linarith

end

end HyperbolicBerggrenGeodesics