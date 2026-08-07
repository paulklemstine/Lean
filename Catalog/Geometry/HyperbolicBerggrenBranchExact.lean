import Geometry.HyperbolicBerggrenResidual

/-!
# Hyperbolic–Pythagorean Geodesics, cycle VI: exact branch monotonicity of the residual

Cycle V (`Catalog/Geometry/HyperbolicBerggrenResidual.lean`) proved that the exact
hyperbolic residual

`resid m n = d(i, z(m,n)) - ½ log (m² + n²)`

agrees with its *slope model* `residAsym m n = ½ log (1 + (n/m)²)` up to an error of at most
`1/c`, `c = m² + n²` (`resid_sandwich`), and it settled the monotonicity of the slope model
along the three Berggren branches

`B₁ : (m,n) ↦ (2m - n, m)`,  `B₂ : (m,n) ↦ (2m + n, m)`,  `B₃ : (m,n) ↦ (m + 2n, n)`,

the answer being: `B₁` increases the slope residual, `B₃` decreases it, and `B₂` decreases it
exactly when `m² ≤ 2mn + n²` (slope above `√2 - 1`).

What cycle V left open — recorded as conjecture **E2** in `FUTURE_DIRECTIONS.md` — is the
*boundary layer*: does slope-model monotonicity survive the `O(1/c)` error, i.e. does it hold
for the **exact hyperbolic distance**?  This file closes that question for all three branches,
in both directions for `B₂`.

## Method

Two ingredients.

*A sharp sandwich.*  `resid_sub_residAsym_le_sharp` replaces the cycle-V error term `1/c` by
`(n² + 1)/(c(c+1))`, which for a small slope is smaller by a factor `≍ m²/n²`.  The proof is
exact: writing `d = log (cosh d + sinh d)` and `2m·sinh d = √((c+1)² - 4m²)`, the residual is
*identically* `log (((c+1) + 2m sinh d)/(2c))`, and `√(1-x) ≤ 1 - x/2` turns the square root
into the stated rational bound with no further loss.

*An algebraic slope gap.*  `residAsym_sub_ge` bounds a slope-model difference from below by
`(A - B)/(2A)` with `A = (m² + n²) m'²`, `B = m² (m'² + n'²)`, using only `log x ≥ 1 - 1/x`.
In each of the three branches `A - B` factors:

* `B₁` : `A - B = (m - n)² (m² + 2mn - n²)`,
* `B₂` : `A - B = ±(2mn + n² - m²)(m + n)²`,
* `B₃` : `A - B = 4n³ (m + n)`,

so what remains is a polynomial inequality in `m, n`.  For the unconditional branches those
inequalities become *coefficient-positive* after the substitution `n = a+1, m = a+b+2`
(`b1_poly_ineq`, `b3_poly_ineq`), which is what makes the guard-free statements possible.

## Main results

* `resid_sub_residAsym_le_sharp` : `resid m n - residAsym m n ≤ (n² + 1)/(c(c+1))`.
* `resid_seedL_ge` : `resid m n ≤ resid (2m - n) m` for **every** Euclid seed — the exact
  residual is non-decreasing along `B₁`, with no side condition.
* `resid_seedR_le` : `resid (m + 2n) n ≤ resid m n` for **every** Euclid seed — the exact
  residual is non-increasing along `B₃`, with no side condition.
* `resid_seedM_le_of_slope_gt` : **conjecture E2, in sharp form.**  If `m² < 2mn + n²` then
  `resid (2m + n) m ≤ resid m n`.  The criterion is exactly the slope-model criterion of
  `residAsym_seedM_le_iff`, with no loss whatsoever.
* `seed_threshold_ne` : no Euclid seed satisfies `m² = 2mn + n²` (coprimality forbids it), so
  for seeds the criterion `m² ≤ 2mn + n²` and the strict `m² < 2mn + n²` agree.  Hence
  `resid_seedM_le_of_residAsym_le` : **for a Berggren node the exact residual decreases along
  `B₂` whenever its slope model does** — the two monotonicity questions have the same answer.
* `resid_seedM_ge_of_slope_lt` : the converse below the threshold, `resid m n ≤ resid (2m+n) m`
  whenever `2mn + n² + 2 ≤ m²`.  The seeds left uncovered by this argument are exactly those
  with `m² = 2mn + n² + 1`, i.e. `(m - n)² = 2n² + 1` (`boundary_layer_pell`) — a Pell family,
  `(m,n) = (5,2), (29,12), (169,70), …`.
* `resid_seedM_ge_of_pell` : **the boundary layer, closed.**  On that Pell family the exact
  residual increases along `B₂` as well.  Here the real relaxation of the hypothesis is *not*
  enough (the corresponding real inequality fails near `(m,n) = (3.8, 1.48)`); the proof uses
  the integrality consequence `n ≥ 2` of the Pell equation, and at `(5,2)` the margin is only
  `0.9 %`.
* `resid_seedM_dichotomy` : consequently, for **every** Euclid seed the exact hyperbolic
  residual moves along `B₂` in exactly the direction the slope model predicts — decreasing
  above the threshold, increasing below it — with no case left open.
* `branch_exact_monotonicity_nonvacuous`, `pell_boundary_nonvacuous` : the statements are
  witnessed on the genuine Euclid seeds `(3,2)`, `(10,1)` and `(5,2)`.
-/

namespace HyperbolicBerggrenGeodesics

open Real UpperHalfPlane

noncomputable section

/-! ## Part A. Two elementary tools -/

/-- The logarithm beats its chord from below: `(A - B)/A ≤ log (A/B)` for positive `A, B`.
This is `log x ≥ 1 - 1/x` in disguise. -/
theorem sub_div_le_log_div {A B : ℝ} (hA : 0 < A) (hB : 0 < B) :
    (A - B) / A ≤ Real.log (A / B) := by
  have h := Real.log_le_sub_one_of_pos (show (0 : ℝ) < B / A by positivity)
  have hlog : Real.log (B / A) = - Real.log (A / B) := by
    rw [← inv_div A B, Real.log_inv]
  rw [hlog] at h
  have hrw : (A - B) / A = 1 - B / A := by field_simp
  rw [hrw]
  linarith

/-- The slope model in ratio form: `residAsym m n = ½ log ((m² + n²)/m²)`. -/
theorem residAsym_eq_log_div {m n : ℕ} (hm : 0 < m) :
    residAsym m n = 1 / 2 * Real.log (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) / (m : ℝ) ^ 2) := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  rw [residAsym]
  congr 2
  field_simp

/-- **The algebraic lower bound on a slope gap.**  With `A = (m² + n²) m'²` and
`B = m² (m'² + n'²)`, the slope-model difference `residAsym m n - residAsym m' n'` is at
least `(A - B)/(2A)`.  (No sign hypothesis on `A - B` is needed: the estimate
`log (A/B) ≥ (A - B)/A` holds for all positive `A, B`.) -/
theorem residAsym_sub_ge {m n m' n' : ℕ} (hm : 0 < m) (hm' : 0 < m') :
    (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (m' : ℝ) ^ 2
        - (m : ℝ) ^ 2 * ((m' : ℝ) ^ 2 + (n' : ℝ) ^ 2))
      / (2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (m' : ℝ) ^ 2))
      ≤ residAsym m n - residAsym m' n' := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hM' : (0 : ℝ) < (m' : ℝ) := by exact_mod_cast hm'
  have hApos : (0 : ℝ) < ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (m' : ℝ) ^ 2 := by positivity
  have hBpos : (0 : ℝ) < (m : ℝ) ^ 2 * ((m' : ℝ) ^ 2 + (n' : ℝ) ^ 2) := by positivity
  have hP : (0 : ℝ) < ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) / (m : ℝ) ^ 2 := by positivity
  have hQ : (0 : ℝ) < ((m' : ℝ) ^ 2 + (n' : ℝ) ^ 2) / (m' : ℝ) ^ 2 := by positivity
  have hratio :
      (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) / (m : ℝ) ^ 2) / ((((m' : ℝ) ^ 2 + (n' : ℝ) ^ 2))
          / (m' : ℝ) ^ 2)
        = (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (m' : ℝ) ^ 2)
            / ((m : ℝ) ^ 2 * ((m' : ℝ) ^ 2 + (n' : ℝ) ^ 2)) := by
    field_simp
  have hdiff : residAsym m n - residAsym m' n'
      = 1 / 2 * Real.log ((((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (m' : ℝ) ^ 2)
          / ((m : ℝ) ^ 2 * ((m' : ℝ) ^ 2 + (n' : ℝ) ^ 2))) := by
    rw [residAsym_eq_log_div hm, residAsym_eq_log_div hm', ← hratio,
      Real.log_div (ne_of_gt hP) (ne_of_gt hQ)]
    ring
  rw [hdiff]
  have hlog := sub_div_le_log_div hApos hBpos
  have hhalf : (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (m' : ℝ) ^ 2
        - (m : ℝ) ^ 2 * ((m' : ℝ) ^ 2 + (n' : ℝ) ^ 2))
      / (2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (m' : ℝ) ^ 2))
      = 1 / 2 * ((((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (m' : ℝ) ^ 2
        - (m : ℝ) ^ 2 * ((m' : ℝ) ^ 2 + (n' : ℝ) ^ 2))
          / ((((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (m' : ℝ) ^ 2))) := by
    field_simp
  rw [hhalf]
  linarith

/-! ## Part B. The sharp sandwich and the bridge to the exact residual -/

theorem resid_sub_residAsym_le_sharp {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    resid m n (lt_trans hn hnm) - residAsym m n
      ≤ ((n : ℝ) ^ 2 + 1)
          / (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1)) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hM1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hcpos : 0 < c := by positivity
  have hcm : (m : ℝ) ^ 2 ≤ c := by nlinarith
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
  have hb0 : (0 : ℝ) ≤ (c + 1) - 2 * (m : ℝ) ^ 2 / (c + 1) := by
    rw [sub_nonneg, div_le_iff₀ (by linarith)]
    nlinarith [hcm, hM1]
  have ha0 : (0 : ℝ) ≤ 2 * (m : ℝ) * Real.sinh d := by positivity
  have hbound : 2 * (m : ℝ) * Real.sinh d ≤ (c + 1) - 2 * (m : ℝ) ^ 2 / (c + 1) := by
    have hb2 : ((c + 1) - 2 * (m : ℝ) ^ 2 / (c + 1)) ^ 2
        = (c + 1) ^ 2 - 4 * (m : ℝ) ^ 2 + 4 * (m : ℝ) ^ 4 / (c + 1) ^ 2 := by
      field_simp
      ring
    have hab2 : (2 * (m : ℝ) * Real.sinh d) ^ 2
        ≤ ((c + 1) - 2 * (m : ℝ) ^ 2 / (c + 1)) ^ 2 := by
      rw [hsq, hb2]
      have : (0 : ℝ) ≤ 4 * (m : ℝ) ^ 4 / (c + 1) ^ 2 := by positivity
      linarith
    nlinarith [hab2, ha0, hb0]
  have hpos1 : (0 : ℝ) < (c + 1) / (2 * (m : ℝ)) + Real.sinh d := by
    have : (0 : ℝ) < (c + 1) / (2 * (m : ℝ)) := by positivity
    linarith
  have hexp : Real.exp d = (c + 1) / (2 * (m : ℝ)) + Real.sinh d := by
    rw [← hcosh]; exact (Real.cosh_add_sinh d).symm
  have hdlog : d = Real.log ((c + 1) / (2 * (m : ℝ)) + Real.sinh d) := by
    rw [← hexp, Real.log_exp]
  have harg : ((c + 1) + 2 * (m : ℝ) * Real.sinh d) / (2 * c)
      = ((c + 1) / (2 * (m : ℝ)) + Real.sinh d) * (m : ℝ) / c := by
    field_simp
  have hEpos : (0 : ℝ) < ((c + 1) + 2 * (m : ℝ) * Real.sinh d) / (2 * c) := by
    rw [harg]; positivity
  have hlogE : Real.log (((c + 1) + 2 * (m : ℝ) * Real.sinh d) / (2 * c))
      = d - Real.log c + Real.log m := by
    rw [harg, Real.log_div (by positivity) (ne_of_gt hcpos),
      Real.log_mul (ne_of_gt hpos1) (ne_of_gt hM), ← hdlog]
    ring
  have hEle : ((c + 1) + 2 * (m : ℝ) * Real.sinh d) / (2 * c)
      ≤ 1 + ((n : ℝ) ^ 2 + 1) / (c * (c + 1)) := by
    rw [div_le_iff₀ (by positivity)]
    have hstep : (1 + ((n : ℝ) ^ 2 + 1) / (c * (c + 1))) * (2 * c)
        = 2 * c + 2 * ((n : ℝ) ^ 2 + 1) / (c + 1) := by
      field_simp
    have heq : (c + 1) + ((c + 1) - 2 * (m : ℝ) ^ 2 / (c + 1))
        = 2 * c + 2 * ((n : ℝ) ^ 2 + 1) / (c + 1) := by
      rw [hcdef]
      field_simp
      ring
    rw [hstep, ← heq]
    linarith [hbound]
  have hlog := Real.log_le_sub_one_of_pos hEpos
  rw [resid, residAsym_eq_sub hm, ← hd, ← hcdef]
  have : d - (1/2) * Real.log c - ((1/2) * Real.log c - Real.log m) = d - Real.log c + Real.log m := by
    ring
  rw [this, ← hlogE]
  linarith [hlog, hEle]
/-- **The bridge.**  An inequality between the *exact* hyperbolic residuals of two Berggren
nodes follows from the corresponding inequality between their slope models, as soon as the
slope gap exceeds the sharp sandwich error `(n² + 1)/(c(c+1))` of the smaller node. -/
theorem resid_le_resid_of_slope_gap {m n m' n' : ℕ} (hn : 0 < n) (hnm : n < m)
    (hn' : 0 < n') (hn'm : n' < m')
    (hgap : residAsym m n
        + ((n : ℝ) ^ 2 + 1)
            / (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1))
      ≤ residAsym m' n') :
    resid m n (lt_trans hn hnm) ≤ resid m' n' (lt_trans hn' hn'm) := by
  have h1 := resid_sub_residAsym_le_sharp hn hnm
  have h2 := residAsym_le_resid hn' hn'm
  linarith

/-! ## Part C. Branch `B₁` : the exact residual increases, unconditionally -/

/-- The polynomial heart of the `B₁` estimate.  After the substitution `n = a+1`,
`m = a+b+2` every coefficient of the difference is non-negative, so no side condition is
needed; the inequality is tight at the root seed `(2,1)`, where the two sides differ by `2`. -/
theorem b1_poly_ineq {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    ((n : ℝ) ^ 2 + 1) * (2 * (((2 * (m : ℝ) - (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2))
      ≤ (((m : ℝ) - (n : ℝ)) ^ 2 * ((m : ℝ) ^ 2 + 2 * (m : ℝ) * (n : ℝ) - (n : ℝ) ^ 2))
          * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1)) := by
  obtain ⟨a, rfl⟩ : ∃ a, n = a + 1 := ⟨n - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, m = a + b + 2 := ⟨m - a - 2, by omega⟩
  have hpoly : (0 : ℝ) ≤
      2 + 444 * (b:ℝ) + 1281 * (b:ℝ)^2 + 1572 * (b:ℝ)^3 + 1069 * (b:ℝ)^4 + 440 * (b:ℝ)^5 +
      111 * (b:ℝ)^6 + 16 * (b:ℝ)^7 + 1 * (b:ℝ)^8 + 126 * (a:ℝ) + 1682 * (a:ℝ) * (b:ℝ) + 3760
      * (a:ℝ) * (b:ℝ)^2 + 3736 * (a:ℝ) * (b:ℝ)^3 + 2022 * (a:ℝ) * (b:ℝ)^4 + 630 * (a:ℝ) *
      (b:ℝ)^5 + 108 * (a:ℝ) * (b:ℝ)^6 + 8 * (a:ℝ) * (b:ℝ)^7 + 278 * (a:ℝ)^2 + 2408 * (a:ℝ)^2
      * (b:ℝ) + 4372 * (a:ℝ)^2 * (b:ℝ)^2 + 3476 * (a:ℝ)^2 * (b:ℝ)^3 + 1424 * (a:ℝ)^2 *
      (b:ℝ)^4 + 300 * (a:ℝ)^2 * (b:ℝ)^5 + 26 * (a:ℝ)^2 * (b:ℝ)^6 + 264 * (a:ℝ)^3 + 1800 *
      (a:ℝ)^3 * (b:ℝ) + 2652 * (a:ℝ)^3 * (b:ℝ)^2 + 1612 * (a:ℝ)^3 * (b:ℝ)^3 + 448 * (a:ℝ)^3
      * (b:ℝ)^4 + 48 * (a:ℝ)^3 * (b:ℝ)^5 + 134 * (a:ℝ)^4 + 760 * (a:ℝ)^4 * (b:ℝ) + 878 *
      (a:ℝ)^4 * (b:ℝ)^2 + 368 * (a:ℝ)^4 * (b:ℝ)^3 + 52 * (a:ℝ)^4 * (b:ℝ)^4 + 36 * (a:ℝ)^5 +
      172 * (a:ℝ)^5 * (b:ℝ) + 144 * (a:ℝ)^5 * (b:ℝ)^2 + 32 * (a:ℝ)^5 * (b:ℝ)^3 + 4 * (a:ℝ)^6
      + 16 * (a:ℝ)^6 * (b:ℝ) + 8 * (a:ℝ)^6 * (b:ℝ)^2 := by positivity
  push_cast
  linarith [hpoly]

/-- **Exact monotonicity along `B₁`, with no side condition.**  For every Euclid seed the
exact hyperbolic residual does not decrease along `B₁ : (m,n) ↦ (2m - n, m)`. -/
theorem resid_seedL_ge {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    resid m n (lt_trans hn hnm) ≤ resid (2 * m - n) m (by omega) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hcast : ((2 * m - n : ℕ) : ℝ) = 2 * (m : ℝ) - (n : ℝ) := by
    have hle : n ≤ 2 * m := by omega
    push_cast [Nat.cast_sub hle]
    ring
  refine resid_le_resid_of_slope_gap (m := m) (n := n) (m' := 2 * m - n) (n' := m)
    hn hnm hm (by omega) ?_
  have hkey := residAsym_sub_ge (m := 2 * m - n) (n := m) (m' := m) (n' := n) (by omega) hm
  rw [hcast] at hkey
  have hApos : (0 : ℝ) < ((2 * (m : ℝ) - (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2 :=
    mul_pos (by nlinarith [sq_nonneg (2 * (m : ℝ) - (n : ℝ)), hM]) (by positivity)
  have hcpos : (0 : ℝ) < ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1) := by
    positivity
  have hstep : ((n : ℝ) ^ 2 + 1)
        / (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1))
      ≤ (((2 * (m : ℝ) - (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2
          - (2 * (m : ℝ) - (n : ℝ)) ^ 2 * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2))
        / (2 * ((((2 * (m : ℝ) - (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2))) := by
    rw [div_le_div_iff₀ hcpos (by positivity)]
    linarith [b1_poly_ineq hn hnm]
  linarith [hkey, hstep]

/-! ## Part D. Branch `B₃` : the exact residual decreases, unconditionally -/

/-- The polynomial heart of the `B₃` estimate; again coefficient-positive after the
substitution `n = a+1`, `m = a+b+2`. -/
theorem b3_poly_ineq {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    ((n : ℝ) ^ 2 + 1) * (2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) + 2 * (n : ℝ)) ^ 2))
      ≤ (4 * (n : ℝ) ^ 3 * ((m : ℝ) + (n : ℝ)))
          * ((((m : ℝ) + 2 * (n : ℝ)) ^ 2 + (n : ℝ) ^ 2)
              * ((((m : ℝ) + 2 * (n : ℝ)) ^ 2 + (n : ℝ) ^ 2) + 1)) := by
  obtain ⟨a, rfl⟩ : ∃ a, n = a + 1 := ⟨n - 1, by omega⟩
  obtain ⟨b, rfl⟩ : ∃ b, m = a + b + 2 := ⟨m - a - 2, by omega⟩
  have hpoly : (0 : ℝ) ≤
      3352 + 4168 * (b:ℝ) + 2096 * (b:ℝ)^2 + 540 * (b:ℝ)^3 + 72 * (b:ℝ)^4 + 4 * (b:ℝ)^5 +
      23200 * (a:ℝ) + 25904 * (a:ℝ) * (b:ℝ) + 11504 * (a:ℝ) * (b:ℝ)^2 + 2548 * (a:ℝ) *
      (b:ℝ)^3 + 280 * (a:ℝ) * (b:ℝ)^4 + 12 * (a:ℝ) * (b:ℝ)^5 + 68804 * (a:ℝ)^2 + 67128 *
      (a:ℝ)^2 * (b:ℝ) + 25406 * (a:ℝ)^2 * (b:ℝ)^2 + 4620 * (a:ℝ)^2 * (b:ℝ)^3 + 394 * (a:ℝ)^2
      * (b:ℝ)^4 + 12 * (a:ℝ)^2 * (b:ℝ)^5 + 115276 * (a:ℝ)^3 + 95308 * (a:ℝ)^3 * (b:ℝ) +
      29452 * (a:ℝ)^3 * (b:ℝ)^2 + 4124 * (a:ℝ)^3 * (b:ℝ)^3 + 244 * (a:ℝ)^3 * (b:ℝ)^4 + 4 *
      (a:ℝ)^3 * (b:ℝ)^5 + 119926 * (a:ℝ)^4 + 80576 * (a:ℝ)^4 * (b:ℝ) + 19042 * (a:ℝ)^4 *
      (b:ℝ)^2 + 1824 * (a:ℝ)^4 * (b:ℝ)^3 + 56 * (a:ℝ)^4 * (b:ℝ)^4 + 79540 * (a:ℝ)^5 + 40684
      * (a:ℝ)^5 * (b:ℝ) + 6528 * (a:ℝ)^5 * (b:ℝ)^2 + 320 * (a:ℝ)^5 * (b:ℝ)^3 + 32892 *
      (a:ℝ)^6 + 11376 * (a:ℝ)^6 * (b:ℝ) + 928 * (a:ℝ)^6 * (b:ℝ)^2 + 7760 * (a:ℝ)^7 + 1360 *
      (a:ℝ)^7 * (b:ℝ) + 800 * (a:ℝ)^8 := by positivity
  push_cast
  linarith [hpoly]

/-- **Exact monotonicity along `B₃`, with no side condition.**  For every Euclid seed the
exact hyperbolic residual does not increase along `B₃ : (m,n) ↦ (m + 2n, n)`. -/
theorem resid_seedR_le {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    resid (m + 2 * n) n (by omega) ≤ resid m n (lt_trans hn hnm) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hcast : ((m + 2 * n : ℕ) : ℝ) = (m : ℝ) + 2 * (n : ℝ) := by push_cast; ring
  refine resid_le_resid_of_slope_gap (m := m + 2 * n) (n := n) (m' := m) (n' := n)
    hn (by omega) hn hnm ?_
  have hkey := residAsym_sub_ge (m := m) (n := n) (m' := m + 2 * n) (n' := n) hm (by omega)
  rw [hcast] at hkey
  rw [hcast]
  have hcpos : (0 : ℝ) < (((m : ℝ) + 2 * (n : ℝ)) ^ 2 + (n : ℝ) ^ 2)
      * ((((m : ℝ) + 2 * (n : ℝ)) ^ 2 + (n : ℝ) ^ 2) + 1) := by positivity
  have hstep : ((n : ℝ) ^ 2 + 1)
        / ((((m : ℝ) + 2 * (n : ℝ)) ^ 2 + (n : ℝ) ^ 2)
            * ((((m : ℝ) + 2 * (n : ℝ)) ^ 2 + (n : ℝ) ^ 2) + 1))
      ≤ (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) + 2 * (n : ℝ)) ^ 2
          - (m : ℝ) ^ 2 * (((m : ℝ) + 2 * (n : ℝ)) ^ 2 + (n : ℝ) ^ 2))
        / (2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) + 2 * (n : ℝ)) ^ 2)) := by
    rw [div_le_div_iff₀ hcpos (by positivity)]
    linarith [b3_poly_ineq hn hnm]
  linarith [hkey, hstep]

/-! ## Part E. Branch `B₂` : conjecture E2 in sharp form, and its converse -/

/-- The polynomial heart of the `B₂` estimate above the threshold.  Here the constraint
`m² < 2mn + n²` is essential, and the chain is short: `c' ≥ S²` twice, `S² ≥ 4m²`, and
`4m² ≥ 2m² + 2`. -/
theorem b2above_poly {m n : ℕ} (hn : 0 < n) (hnm : n < m) (h : m ^ 2 + 1 ≤ 2 * m * n + n ^ 2) :
    ((m : ℝ) ^ 2 + 1) * (2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (2 * (m : ℝ) + (n : ℝ)) ^ 2))
      ≤ (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (2 * (m : ℝ) + (n : ℝ)) ^ 2
          - (m : ℝ) ^ 2 * ((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2))
        * (((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2)
            * ((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2 + 1)) := by
  have hM : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hnm.le.trans' hn
  have hN : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hD : (m : ℝ) ^ 2 + 1 ≤ 2 * (m : ℝ) * (n : ℝ) + (n : ℝ) ^ 2 := by exact_mod_cast h
  set S : ℝ := 2 * (m : ℝ) + (n : ℝ) with hS
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hc
  have hSpos : 0 < S := by rw [hS]; linarith
  have hcpos : 0 < c := by rw [hc]; nlinarith
  have hfac : c * S ^ 2 - (m : ℝ) ^ 2 * (S ^ 2 + (m : ℝ) ^ 2)
      = (2 * (m : ℝ) * (n : ℝ) + (n : ℝ) ^ 2 - (m : ℝ) ^ 2) * ((m : ℝ) + (n : ℝ)) ^ 2 := by
    rw [hS, hc]; ring
  have hD1 : (1 : ℝ) ≤ 2 * (m : ℝ) * (n : ℝ) + (n : ℝ) ^ 2 - (m : ℝ) ^ 2 := by linarith
  have hS4 : 4 * (m : ℝ) ^ 2 ≤ S ^ 2 := by rw [hS]; nlinarith
  have hmn : c ≤ ((m : ℝ) + (n : ℝ)) ^ 2 := by rw [hc]; nlinarith
  have hstep1 : 2 * ((m : ℝ) ^ 2 + 1) * c ≤ ((m : ℝ) + (n : ℝ)) ^ 2 * S ^ 2 := by
    nlinarith [hS4, hmn, hcpos, hM]
  have hchain : ((m : ℝ) ^ 2 + 1) * (2 * (c * S ^ 2)) ≤ (((m : ℝ) + (n : ℝ)) ^ 2 * S ^ 2) * S ^ 2 := by
    nlinarith [hstep1, sq_nonneg S, hSpos]
  have hbig : (((m : ℝ) + (n : ℝ)) ^ 2 * S ^ 2) * S ^ 2
      ≤ ((2 * (m : ℝ) * (n : ℝ) + (n : ℝ) ^ 2 - (m : ℝ) ^ 2) * ((m : ℝ) + (n : ℝ)) ^ 2)
        * ((S ^ 2 + (m : ℝ) ^ 2) * (S ^ 2 + (m : ℝ) ^ 2 + 1)) := by
    have h1 : S ^ 2 * S ^ 2 ≤ (S ^ 2 + (m : ℝ) ^ 2) * (S ^ 2 + (m : ℝ) ^ 2 + 1) := by
      nlinarith [sq_nonneg S, sq_nonneg ((m : ℝ)), hSpos]
    have h2 : (0 : ℝ) ≤ ((m : ℝ) + (n : ℝ)) ^ 2 := sq_nonneg _
    have hQ0 : (0 : ℝ) ≤ (S ^ 2 + (m : ℝ) ^ 2) * (S ^ 2 + (m : ℝ) ^ 2 + 1) := by positivity
    have step1 : ((m : ℝ) + (n : ℝ)) ^ 2 * (S ^ 2 * S ^ 2)
        ≤ ((m : ℝ) + (n : ℝ)) ^ 2 * ((S ^ 2 + (m : ℝ) ^ 2) * (S ^ 2 + (m : ℝ) ^ 2 + 1)) :=
      mul_le_mul_of_nonneg_left h1 h2
    have step2 : ((m : ℝ) + (n : ℝ)) ^ 2 * ((S ^ 2 + (m : ℝ) ^ 2) * (S ^ 2 + (m : ℝ) ^ 2 + 1))
        ≤ (2 * (m : ℝ) * (n : ℝ) + (n : ℝ) ^ 2 - (m : ℝ) ^ 2)
          * (((m : ℝ) + (n : ℝ)) ^ 2 * ((S ^ 2 + (m : ℝ) ^ 2) * (S ^ 2 + (m : ℝ) ^ 2 + 1))) :=
      le_mul_of_one_le_left (mul_nonneg h2 hQ0) hD1
    nlinarith [step1, step2]
  rw [hfac]
  linarith [hchain, hbig]

/-- The polynomial heart of the `B₂` estimate below the threshold.  The margin `+2` in the
hypothesis cannot be dropped by this method: with only `2mn + n² + 1 ≤ m²` the corresponding
inequality is false over the reals (it fails near `(m,n) = (3.8, 1.48)`), so the integrality
of the remaining Pell family would have to be used. -/
theorem b2below_poly {m n : ℕ} (hn : 0 < n) (hnm : n < m) (h : 2 * m * n + n ^ 2 + 2 ≤ m ^ 2) :
    ((n : ℝ) ^ 2 + 1) * (2 * (((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2))
      ≤ ((((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2
          - (2 * (m : ℝ) + (n : ℝ)) ^ 2 * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)))
        * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1)) := by
  have hN : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  have hmn2 : n + 2 ≤ m := by nlinarith [h, hn, hnm]
  have hM2 : (n : ℝ) + 2 ≤ (m : ℝ) := by exact_mod_cast hmn2
  have hD : 2 * (m : ℝ) * (n : ℝ) + (n : ℝ) ^ 2 + 2 ≤ (m : ℝ) ^ 2 := by exact_mod_cast h
  have hfac : (((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2
      - (2 * (m : ℝ) + (n : ℝ)) ^ 2 * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2))
      = ((m : ℝ) ^ 2 - 2 * (m : ℝ) * (n : ℝ) - (n : ℝ) ^ 2) * ((m : ℝ) + (n : ℝ)) ^ 2 := by
    ring
  rw [hfac]
  have hD2 : (2 : ℝ) ≤ (m : ℝ) ^ 2 - 2 * (m : ℝ) * (n : ℝ) - (n : ℝ) ^ 2 := by linarith
  -- reduce to (n²+1)(S²+m²)m² ≤ (m+n)² c²
  have hMpos : (0 : ℝ) < (m : ℝ) := by linarith
  have h7 : (2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2 ≤ 7 * (m : ℝ) ^ 2 := by nlinarith [hD, hN]
  have hnn : (0 : ℝ) ≤ ((n : ℝ) ^ 2 + 1) * (m : ℝ) ^ 2 := by positivity
  have hLHS : ((n : ℝ) ^ 2 + 1) * (((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2)
      ≤ 7 * ((n : ℝ) ^ 2 + 1) * (m : ℝ) ^ 4 := by nlinarith [h7, hnn]
  have hstep4 : 5 * (n : ℝ) ^ 2 + 7 ≤ (m : ℝ) ^ 2 + 2 * (m : ℝ) * (n : ℝ) := by
    nlinarith [hD, hM2, hN]
  have hm4 : (0 : ℝ) ≤ (m : ℝ) ^ 4 := by positivity
  have e2 : 7 * ((n : ℝ) ^ 2 + 1) * (m : ℝ) ^ 4
      ≤ ((m : ℝ) ^ 2 + 2 * (m : ℝ) * (n : ℝ)) * ((m : ℝ) ^ 4 + 2 * (m : ℝ) ^ 2 * (n : ℝ) ^ 2) := by
    have hm3n3 : (0 : ℝ) ≤ (m : ℝ) ^ 3 * (n : ℝ) ^ 3 := by positivity
    nlinarith [mul_le_mul_of_nonneg_left hstep4 hm4, hm3n3]
  have e1 : ((m : ℝ) ^ 2 + 2 * (m : ℝ) * (n : ℝ)) * ((m : ℝ) ^ 4 + 2 * (m : ℝ) ^ 2 * (n : ℝ) ^ 2)
      ≤ ((m : ℝ) + (n : ℝ)) ^ 2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) := by
    have hsplit : ((m : ℝ) + (n : ℝ)) ^ 2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2))
        - ((m : ℝ) ^ 2 + 2 * (m : ℝ) * (n : ℝ)) * ((m : ℝ) ^ 4 + 2 * (m : ℝ) ^ 2 * (n : ℝ) ^ 2)
        = (n : ℝ) ^ 2 * ((m : ℝ) ^ 4 + 2 * (m : ℝ) ^ 2 * (n : ℝ) ^ 2)
          + ((m : ℝ) ^ 2 + 2 * (m : ℝ) * (n : ℝ) + (n : ℝ) ^ 2) * (n : ℝ) ^ 4 := by
      ring
    have hnn2 : (0 : ℝ) ≤ (n : ℝ) ^ 2 * ((m : ℝ) ^ 4 + 2 * (m : ℝ) ^ 2 * (n : ℝ) ^ 2)
        + ((m : ℝ) ^ 2 + 2 * (m : ℝ) * (n : ℝ) + (n : ℝ) ^ 2) * (n : ℝ) ^ 4 := by positivity
    linarith [hsplit, hnn2]
  have hkey : ((n : ℝ) ^ 2 + 1) * ((((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2)) * (m : ℝ) ^ 2)
      ≤ ((m : ℝ) + (n : ℝ)) ^ 2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) := by
    linarith [hLHS, e2, e1]
  have hcc : (0 : ℝ) ≤ ((m : ℝ) + (n : ℝ)) ^ 2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2)
      * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) := by positivity
  have hgrow : ((m : ℝ) + (n : ℝ)) ^ 2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2))
      ≤ ((m : ℝ) + (n : ℝ)) ^ 2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1)) := by
    nlinarith [sq_nonneg ((m : ℝ) + (n : ℝ)), sq_nonneg ((m : ℝ) ^ 2 + (n : ℝ) ^ 2), hMpos]
  have hfinal : 2 * (((m : ℝ) + (n : ℝ)) ^ 2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2)
        * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1)))
      ≤ ((m : ℝ) ^ 2 - 2 * (m : ℝ) * (n : ℝ) - (n : ℝ) ^ 2) * ((m : ℝ) + (n : ℝ)) ^ 2
        * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1)) := by
    have hpos : (0 : ℝ) ≤ ((m : ℝ) + (n : ℝ)) ^ 2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2)
        * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1)) := by positivity
    nlinarith [hD2, hpos]
  linarith [hkey, hgrow, hfinal]

/-- **Conjecture E2, proved in sharp form.**  Above the slope threshold — with *no* loss at
all relative to the slope-model criterion of `residAsym_seedM_le_iff` — the exact hyperbolic
residual decreases along the middle Berggren branch `B₂ : (m,n) ↦ (2m + n, m)`. -/
theorem resid_seedM_le_of_slope_gt {m n : ℕ} (hn : 0 < n) (hnm : n < m)
    (h : m ^ 2 < 2 * m * n + n ^ 2) :
    resid (2 * m + n) m (by omega) ≤ resid m n (lt_trans hn hnm) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hcast : ((2 * m + n : ℕ) : ℝ) = 2 * (m : ℝ) + (n : ℝ) := by push_cast; ring
  refine resid_le_resid_of_slope_gap (m := 2 * m + n) (n := m) (m' := m) (n' := n)
    hm (by omega) hn hnm ?_
  have hkey := residAsym_sub_ge (m := m) (n := n) (m' := 2 * m + n) (n' := m) hm (by omega)
  rw [hcast] at hkey
  rw [hcast]
  have hcpos : (0 : ℝ) < ((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2)
      * ((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2 + 1) := by positivity
  have hstep : ((m : ℝ) ^ 2 + 1)
        / (((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2)
            * ((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2 + 1))
      ≤ (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (2 * (m : ℝ) + (n : ℝ)) ^ 2
          - (m : ℝ) ^ 2 * ((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2))
        / (2 * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * (2 * (m : ℝ) + (n : ℝ)) ^ 2)) := by
    rw [div_le_div_iff₀ hcpos (by positivity)]
    linarith [b2above_poly hn hnm h]
  linarith [hkey, hstep]

/-- **The converse below the threshold.**  If `2mn + n² + 2 ≤ m²` the exact hyperbolic
residual *increases* along `B₂`. -/
theorem resid_seedM_ge_of_slope_lt {m n : ℕ} (hn : 0 < n) (hnm : n < m)
    (h : 2 * m * n + n ^ 2 + 2 ≤ m ^ 2) :
    resid m n (lt_trans hn hnm) ≤ resid (2 * m + n) m (by omega) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hcast : ((2 * m + n : ℕ) : ℝ) = 2 * (m : ℝ) + (n : ℝ) := by push_cast; ring
  refine resid_le_resid_of_slope_gap (m := m) (n := n) (m' := 2 * m + n) (n' := m)
    hn hnm hm (by omega) ?_
  have hkey := residAsym_sub_ge (m := 2 * m + n) (n := m) (m' := m) (n' := n) (by omega) hm
  rw [hcast] at hkey
  have hcpos : (0 : ℝ) < ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1) := by
    positivity
  have hstep : ((n : ℝ) ^ 2 + 1)
        / (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1))
      ≤ ((((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2
          - (2 * (m : ℝ) + (n : ℝ)) ^ 2 * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)))
        / (2 * ((((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2)) * (m : ℝ) ^ 2)) := by
    rw [div_le_div_iff₀ hcpos (by positivity)]
    linarith [b2below_poly hn hnm h]
  linarith [hkey, hstep]

/-! ## Part F. Seeds: the threshold is never attained, and the leftover is a Pell family -/

/-- **No seed sits exactly on the threshold.**  For a Euclid seed `m² = 2mn + n²` is
impossible: it would give `m ∣ n²`, and coprimality then forces `m = 1`. -/
theorem seed_threshold_ne {m n : ℕ} (hn : 0 < n) (hnm : n < m) (hcop : Nat.Coprime m n) :
    m ^ 2 ≠ 2 * m * n + n ^ 2 := by
  intro h
  have hZ : (m : ℤ) ^ 2 = 2 * (m : ℤ) * (n : ℤ) + (n : ℤ) ^ 2 := by exact_mod_cast h
  have hdvd : (m : ℤ) ∣ (n : ℤ) ^ 2 := ⟨(m : ℤ) - 2 * (n : ℤ), by linear_combination -hZ⟩
  have hdvdN : m ∣ n ^ 2 := by exact_mod_cast hdvd
  have hone : m = 1 := (hcop.pow_right 2).eq_one_of_dvd hdvdN
  omega

/-- **For a Berggren node the exact residual decreases along `B₂` whenever its slope model
does.**  The two monotonicity questions therefore have the same answer on seeds: combining
`residAsym_seedM_le_iff` (the criterion `m² ≤ 2mn + n²`) with `seed_threshold_ne` (equality is
impossible) puts every seed strictly on one side of the threshold. -/
theorem resid_seedM_le_of_residAsym_le {m n : ℕ} (hs : IsSeed m n)
    (hle : residAsym (2 * m + n) m ≤ residAsym m n) :
    resid (2 * m + n) m (by have := hs.pos; omega) ≤ resid m n (lt_trans hs.pos hs.lt) := by
  have h := (residAsym_seedM_le_iff hs.pos hs.lt).1 hle
  have hne := seed_threshold_ne hs.pos hs.lt hs.cop
  exact resid_seedM_le_of_slope_gt hs.pos hs.lt (lt_of_le_of_ne h hne)

/-- **The remaining boundary layer is a Pell equation.**  The seeds not covered by
`resid_seedM_le_of_slope_gt` and `resid_seedM_ge_of_slope_lt` are exactly those with
`2mn + n² + 1 = m²`, i.e. `(m - n)² = 2n² + 1` — the Pell equation `x² - 2y² = 1`,
`(m,n) = (5,2), (29,12), (169,70), …`. -/
theorem boundary_layer_pell {m n : ℕ} (hnm : n < m) (h : 2 * m * n + n ^ 2 + 1 = m ^ 2) :
    (m - n) ^ 2 = 2 * n ^ 2 + 1 := by
  obtain ⟨k, rfl⟩ : ∃ k, m = n + k := ⟨m - n, by omega⟩
  have hk : n + k - n = k := by omega
  rw [hk]
  nlinarith [h]

/-! ## Part H. The boundary layer, closed: the Pell family -/

/-- On the boundary layer `2mn + n² + 1 = m²` the two crude bounds `n ≥ 2` and `m ≥ 2n + 1`
hold.  The first is the statement that `(m,n) = (m,1)` is impossible, i.e. `m² = 2m + 2` has
no solution; the second is `m² > 2mn`. -/
theorem pell_seed_bounds {m n : ℕ} (hn : 0 < n) (hnm : n < m)
    (h : 2 * m * n + n ^ 2 + 1 = m ^ 2) : 2 ≤ n ∧ 2 * n + 1 ≤ m := by
  have hn2 : 2 ≤ n := by
    rcases Nat.lt_or_ge n 2 with h1 | h1
    · have hn1 : n = 1 := by omega
      subst hn1
      rcases Nat.lt_or_ge m 3 with h2 | h2
      · interval_cases m
        omega
      · nlinarith
    · exact h1
  refine ⟨hn2, ?_⟩
  by_contra hc
  have hle : m ≤ 2 * n := by omega
  have : m * m ≤ 2 * n * m := Nat.mul_le_mul_right m hle
  nlinarith

/-- The polynomial heart of the boundary layer.  On the Pell locus `m² = 2mn + n² + 1` the
inequality that `b2below_poly` could only reach with the margin `+2` becomes true again — but
only because of *integrality*: after eliminating `m²` the difference of the two sides is
`mn(28n⁴ - 96n² - 34) + (12n⁶ - 30n⁴ - 50n² - 8)`, and both brackets are non-negative exactly
from `n ≥ 2`, which the Pell equation forces.  At the first solution `(m,n) = (5,2)` the two
sides are `42250` and `42630`, a margin of only `0.9 %`. -/
theorem b2pell_poly {m n : ℕ} (hn : 0 < n) (hnm : n < m)
    (h : 2 * m * n + n ^ 2 + 1 = m ^ 2) :
    ((n : ℝ) ^ 2 + 1) * (2 * (((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2))
      ≤ ((((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2
          - (2 * (m : ℝ) + (n : ℝ)) ^ 2 * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)))
        * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1)) := by
  obtain ⟨hn2, hm2⟩ := pell_seed_bounds hn hnm h
  have hN : (2 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn2
  have hM0 : (0 : ℝ) ≤ (m : ℝ) := Nat.cast_nonneg m
  have hN0 : (0 : ℝ) ≤ (n : ℝ) := Nat.cast_nonneg n
  have hDR : (m : ℝ) ^ 2 = 2 * (m : ℝ) * (n : ℝ) + (n : ℝ) ^ 2 + 1 := by exact_mod_cast h.symm
  have key :
      ((((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2
          - (2 * (m : ℝ) + (n : ℝ)) ^ 2 * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)))
        * (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1))
        - ((n : ℝ) ^ 2 + 1) * (2 * (((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2))
      = (m : ℝ) * (n : ℝ) * (28 * (n : ℝ) ^ 4 - 96 * (n : ℝ) ^ 2 - 34)
          + (12 * (n : ℝ) ^ 6 - 30 * (n : ℝ) ^ 4 - 50 * (n : ℝ) ^ 2 - 8) := by
    linear_combination
      ((m : ℝ) ^ 6 + 2 * (m : ℝ) ^ 5 * (n : ℝ) + 3 * (m : ℝ) ^ 4 * (n : ℝ) ^ 2
        + 2 * (m : ℝ) ^ 4 + 4 * (m : ℝ) ^ 3 * (n : ℝ) ^ 3 + 6 * (m : ℝ) ^ 3 * (n : ℝ)
        + 3 * (m : ℝ) ^ 2 * (n : ℝ) ^ 4 + 4 * (m : ℝ) ^ 2 * (n : ℝ) ^ 2 - 8 * (m : ℝ) ^ 2
        + 2 * (m : ℝ) * (n : ℝ) ^ 5 + 6 * (m : ℝ) * (n : ℝ) ^ 3 - 18 * (m : ℝ) * (n : ℝ)
        + (n : ℝ) ^ 6 + 12 * (n : ℝ) ^ 4 - 42 * (n : ℝ) ^ 2 - 8) * hDR
  have ht : (4 : ℝ) ≤ (n : ℝ) ^ 2 := by nlinarith [hN]
  have hsq : (0 : ℝ) ≤ ((n : ℝ) ^ 2 - 4) ^ 2 := sq_nonneg _
  have hcube : (0 : ℝ) ≤ ((n : ℝ) ^ 2 - 4) ^ 3 := pow_nonneg (by linarith) 3
  have h1 : (0 : ℝ) ≤ (m : ℝ) * (n : ℝ) * (28 * (n : ℝ) ^ 4 - 96 * (n : ℝ) ^ 2 - 34) := by
    have hbr : (0 : ℝ) ≤ 28 * (n : ℝ) ^ 4 - 96 * (n : ℝ) ^ 2 - 34 := by linarith [hsq, ht]
    exact mul_nonneg (mul_nonneg hM0 hN0) hbr
  have h2 : (0 : ℝ) ≤ 12 * (n : ℝ) ^ 6 - 30 * (n : ℝ) ^ 4 - 50 * (n : ℝ) ^ 2 - 8 := by
    linarith [hcube, hsq, ht]
  linarith

/-- **The boundary layer is settled.**  On the Pell family `2mn + n² + 1 = m²` — the only
seeds left uncovered by `resid_seedM_le_of_slope_gt` and `resid_seedM_ge_of_slope_lt` — the
exact hyperbolic residual increases along `B₂`, exactly as the slope model predicts.  Unlike
the two neighbouring regimes this statement is *not* true for the real relaxation of the
hypothesis (the corresponding real inequality fails near `(m,n) = (3.8, 1.48)`); the proof
goes through the integrality consequence `n ≥ 2` of the Pell equation. -/
theorem resid_seedM_ge_of_pell {m n : ℕ} (hn : 0 < n) (hnm : n < m)
    (h : 2 * m * n + n ^ 2 + 1 = m ^ 2) :
    resid m n (lt_trans hn hnm) ≤ resid (2 * m + n) m (by omega) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hcast : ((2 * m + n : ℕ) : ℝ) = 2 * (m : ℝ) + (n : ℝ) := by push_cast; ring
  refine resid_le_resid_of_slope_gap (m := m) (n := n) (m' := 2 * m + n) (n' := m)
    hn hnm hm (by omega) ?_
  have hkey := residAsym_sub_ge (m := 2 * m + n) (n := m) (m' := m) (n' := n) (by omega) hm
  rw [hcast] at hkey
  have hcpos : (0 : ℝ) < ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1) := by
    positivity
  have hstep : ((n : ℝ) ^ 2 + 1)
        / (((m : ℝ) ^ 2 + (n : ℝ) ^ 2) * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2 + 1))
      ≤ ((((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2) * (m : ℝ) ^ 2
          - (2 * (m : ℝ) + (n : ℝ)) ^ 2 * ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)))
        / (2 * ((((2 * (m : ℝ) + (n : ℝ)) ^ 2 + (m : ℝ) ^ 2)) * (m : ℝ) ^ 2)) := by
    rw [div_le_div_iff₀ hcpos (by positivity)]
    linarith [b2pell_poly hn hnm h]
  linarith [hkey, hstep]

/-- **The complete `B₂` dichotomy for Euclid seeds.**  Every seed lies strictly on one side of
the threshold (`seed_threshold_ne`), and on each side the exact hyperbolic residual moves in
the direction predicted by the slope model: it decreases along `B₂` above the threshold and
increases below it.  Together with `resid_seedL_ge` and `resid_seedR_le` this determines the
monotonicity of the exact residual along all three Berggren branches, with no gap left. -/
theorem resid_seedM_dichotomy {m n : ℕ} (hs : IsSeed m n) :
    (m ^ 2 < 2 * m * n + n ^ 2 →
        resid (2 * m + n) m (by have := hs.pos; omega) ≤ resid m n (lt_trans hs.pos hs.lt))
      ∧ (2 * m * n + n ^ 2 < m ^ 2 →
        resid m n (lt_trans hs.pos hs.lt) ≤ resid (2 * m + n) m (by have := hs.pos; omega)) := by
  refine ⟨fun h => resid_seedM_le_of_slope_gt hs.pos hs.lt h, fun h => ?_⟩
  rcases eq_or_lt_of_le (show 2 * m * n + n ^ 2 + 1 ≤ m ^ 2 by omega) with heq | hlt
  · exact resid_seedM_ge_of_pell hs.pos hs.lt heq
  · exact resid_seedM_ge_of_slope_lt hs.pos hs.lt (by omega)

/-! ## Part G. Non-vacuity -/

/-- **Non-vacuity.**  On the genuine Euclid seed `(3,2)` all three branch theorems apply and
give the three predicted comparisons, and the seed `(10,1)` witnesses the sub-threshold
statement.  So none of the results is vacuous. -/
theorem branch_exact_monotonicity_nonvacuous :
    (IsSeed 3 2 ∧ resid 3 2 (by norm_num) ≤ resid 4 3 (by norm_num)
      ∧ resid 7 2 (by norm_num) ≤ resid 3 2 (by norm_num)
      ∧ resid 8 3 (by norm_num) ≤ resid 3 2 (by norm_num))
    ∧ (IsSeed 10 1 ∧ resid 10 1 (by norm_num) ≤ resid 21 10 (by norm_num)) := by
  refine ⟨⟨⟨by norm_num, by norm_num, by decide, by decide⟩, ?_, ?_, ?_⟩,
    ⟨⟨by norm_num, by norm_num, by decide, by decide⟩, ?_⟩⟩
  · have := resid_seedL_ge (m := 3) (n := 2) (by norm_num) (by norm_num)
    norm_num at this
    exact this
  · have := resid_seedR_le (m := 3) (n := 2) (by norm_num) (by norm_num)
    norm_num at this
    exact this
  · have := resid_seedM_le_of_slope_gt (m := 3) (n := 2) (by norm_num) (by norm_num) (by norm_num)
    norm_num at this
    exact this
  · have := resid_seedM_ge_of_slope_lt (m := 10) (n := 1) (by norm_num) (by norm_num)
      (by norm_num)
    norm_num at this
    exact this

/-- **The boundary layer is non-vacuous too.**  `(5,2)` is a genuine Euclid seed lying exactly
on the Pell locus `2mn + n² + 1 = m²`, and there the exact residual does increase along `B₂`,
as `resid_seedM_ge_of_pell` predicts (numerically `0.079099 ≤ 0.080922`). -/
theorem pell_boundary_nonvacuous :
    IsSeed 5 2 ∧ 2 * 5 * 2 + 2 ^ 2 + 1 = 5 ^ 2
      ∧ resid 5 2 (by norm_num) ≤ resid 12 5 (by norm_num) := by
  refine ⟨⟨by norm_num, by norm_num, by decide, by decide⟩, by norm_num, ?_⟩
  have := resid_seedM_ge_of_pell (m := 5) (n := 2) (by norm_num) (by norm_num) (by norm_num)
  norm_num at this
  exact this

end

end HyperbolicBerggrenGeodesics