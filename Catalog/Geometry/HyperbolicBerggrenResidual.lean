import Geometry.HyperbolicBerggrenDensity

/-!
# Hyperbolic–Pythagorean Geodesics, cycle V: the residual and its branch monotonicity

This file is the fifth research cycle of the Berggren-tree / Poincaré-half-plane thread.
It analyses the **residual**

`resid m n = d(i, z(m,n)) - ½ log (m² + n²)`,

the quantity that `trajectory_window` (cycle II) confined to `[0, ½ log 2 + o(1)]`, and
settles sub-conjecture **D3-lite** of `FUTURE_DIRECTIONS.md`.

## Main results

* `residAsym_le_resid`, `resid_le_residAsym_add` and the combined
  `resid_sandwich` : **the residual is a function of the slope `n/m` alone, up to
  `O(1/c)`.**  Precisely, with `residAsym m n = ½ log (1 + (n/m)²)`,
  `residAsym m n ≤ resid m n ≤ residAsym m n + log (1 + 1/(m²+n²))`.
  This identifies the shape of the residual exactly: the trajectory window of cycle II is
  the image of the slope interval `(0,1)` under `t ↦ ½ log (1+t²)`, and the error is at
  most `1/c`, i.e. the reciprocal of the hypotenuse.
* `residAsym_seedL_ge`, `residAsym_seedR_le` : **two thirds of D3-lite are true.**  The
  slope residual is non-decreasing along the Berggren branch `B₁` and non-increasing along
  `B₃`, with completely explicit algebraic reasons: `B₁` moves the slope `t` to `1/(2-t)`
  and `(m-n)² ≥ 0` gives `t ≤ 1/(2-t)`, while `B₃` moves `t` to `t/(1+2t) ≤ t`.
* `resid_four_one_lt_resid_nine_four`, `exists_seed_resid_seedM_gt`,
  `residAsym_seedM_not_antitone` : **the remaining third of D3-lite is false.**  The
  middle branch `B₂` does *not* decrease the residual: for the seed `(4,1)`, whose `B₂`
  child is `(9,4)`, the exact hyperbolic residual strictly *increases*
  (`0.0340 < 0.0918`).  So the residual is not monotone along `B₂`, and the D3-lite
  statement must be corrected to the two branches `B₁`, `B₃`.
* `residAsym_seedM_le_iff` : **the sharp criterion replacing the false third.**  `B₂`
  decreases the slope residual *exactly* when `m² ≤ 2mn + n²`, i.e. when the slope `n/m`
  exceeds `√2 - 1`.  So the middle branch is monotone above the threshold and anti-monotone
  below it, and `(4,1)` (slope `1/4`) is the smallest seed on the wrong side.

The counterexample is proved from the exact distance formula `cosh_dist_hpoint_I`, by
comparing `cosh (d(4,1) + ½ log (97/17))` with `cosh d(9,4)` — no numerical evaluation of
`arcosh` is involved.
-/

namespace HyperbolicBerggrenGeodesics

open Real UpperHalfPlane

noncomputable section

/-! ## Part A. The residual and its slope model -/

/-- The **residual** of a Berggren node: how much the hyperbolic distance from the base
point `i` exceeds the ideal value `½ log c`, `c = m² + n²` being the hypotenuse. -/
def resid (m n : ℕ) (hm : 0 < m) : ℝ :=
  dist (hpoint m n hm) UpperHalfPlane.I - (1 / 2) * Real.log ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)

/-- The **slope model** of the residual: a function of the ratio `t = n/m` alone. -/
def residAsym (m n : ℕ) : ℝ := (1 / 2) * Real.log (1 + ((n : ℝ) / (m : ℝ)) ^ 2)

/-- `cosh (log x) = (x + 1/x)/2`. -/
theorem cosh_log_eq {x : ℝ} (hx : 0 < x) : Real.cosh (Real.log x) = (x + 1 / x) / 2 := by
  rw [Real.cosh_eq, Real.exp_log hx, Real.exp_neg, Real.exp_log hx]
  ring

/-- `sinh (log x) = (x - 1/x)/2`. -/
theorem sinh_log_eq {x : ℝ} (hx : 0 < x) : Real.sinh (Real.log x) = (x - 1 / x) / 2 := by
  rw [Real.sinh_eq, Real.exp_log hx, Real.exp_neg, Real.exp_log hx]
  ring

/-- The slope model in logarithmic form: `residAsym = ½ log c - log m`. -/
theorem residAsym_eq_sub {m n : ℕ} (hm : 0 < m) :
    residAsym m n = (1 / 2) * Real.log ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) - Real.log m := by
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hc : (0 : ℝ) < (m : ℝ) ^ 2 + (n : ℝ) ^ 2 := by positivity
  have hkey : 1 + ((n : ℝ) / (m : ℝ)) ^ 2 = ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) / (m : ℝ) ^ 2 := by
    field_simp
  rw [residAsym, hkey, Real.log_div (ne_of_gt hc) (by positivity), Real.log_pow]
  push_cast
  ring

/-- **Lower half of the sandwich.**  The true residual dominates its slope model. -/
theorem residAsym_le_resid {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    residAsym m n ≤ resid m n (lt_trans hn hnm) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hcpos : 0 < c := by positivity
  have hcm : (m : ℝ) ^ 2 ≤ c := by nlinarith
  set d := dist (hpoint m n hm) UpperHalfPlane.I with hd
  have hd0 : 0 ≤ d := dist_nonneg
  have hcosh : Real.cosh d = (c + 1) / (2 * m) := by rw [hd, cosh_dist_hpoint_I]
  -- the target distance `log (c/m)`
  have hcmpos : (0 : ℝ) < c / (m : ℝ) := by positivity
  have hM1 : (1 : ℝ) ≤ (m : ℝ) := by exact_mod_cast hm
  have hlog0 : 0 ≤ Real.log (c / (m : ℝ)) := by
    refine Real.log_nonneg ?_
    rw [le_div_iff₀ hM]
    nlinarith [hcm, hM1]
  have hmc : (m : ℝ) / c ≤ 1 / (m : ℝ) := by
    rw [div_le_div_iff₀ hcpos hM]
    nlinarith [hcm]
  have hkey : Real.cosh (Real.log (c / (m : ℝ))) ≤ Real.cosh d := by
    rw [cosh_log_eq hcmpos, hcosh, one_div_div]
    have e1 : (c / (m : ℝ) + 1 / (m : ℝ)) / 2 = (c + 1) / (2 * (m : ℝ)) := by
      field_simp
    rw [← e1]
    linarith
  have hle : Real.log (c / (m : ℝ)) ≤ d := by
    have habs := (Real.cosh_le_cosh).1 hkey
    rwa [abs_of_nonneg hlog0, abs_of_nonneg hd0] at habs
  have hsplit : Real.log (c / (m : ℝ)) = Real.log c - Real.log m :=
    Real.log_div (ne_of_gt hcpos) (ne_of_gt hM)
  rw [resid, residAsym_eq_sub hm, ← hd, ← hcdef]
  rw [hsplit] at hle
  linarith

/-- **Upper half of the sandwich.**  The true residual exceeds its slope model by at most
`log (1 + 1/c)`, i.e. by `O(1/c)`. -/
theorem resid_le_residAsym_add {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    resid m n (lt_trans hn hnm) ≤
      residAsym m n + Real.log (1 + 1 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (1 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
  set c : ℝ := (m : ℝ) ^ 2 + (n : ℝ) ^ 2 with hcdef
  have hcpos : 0 < c := by positivity
  set d := dist (hpoint m n hm) UpperHalfPlane.I with hd
  have hd0 : 0 ≤ d := dist_nonneg
  have hcosh : Real.cosh d = (c + 1) / (2 * m) := by rw [hd, cosh_dist_hpoint_I]
  obtain ⟨-, hhigh⟩ := log_cosh_sandwich hd0
  have h2c : 2 * Real.cosh d = (c + 1) / (m : ℝ) := by rw [hcosh]; field_simp
  rw [h2c] at hhigh
  have hsplit : Real.log ((c + 1) / (m : ℝ)) = Real.log (c + 1) - Real.log m :=
    Real.log_div (by positivity) (ne_of_gt hM)
  have hone : 1 + 1 / c = (c + 1) / c := by field_simp
  have hsplit2 : Real.log (1 + 1 / c) = Real.log (c + 1) - Real.log c := by
    rw [hone, Real.log_div (by positivity) (ne_of_gt hcpos)]
  rw [resid, residAsym_eq_sub hm, ← hd, ← hcdef, hsplit2]
  rw [hsplit] at hhigh
  linarith

/-- **The residual sandwich.**  The residual of a Berggren node is its slope model
`½ log (1 + (n/m)²)` up to an error of at most `log (1 + 1/c) ≤ 1/c`. -/
theorem resid_sandwich {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    residAsym m n ≤ resid m n (lt_trans hn hnm) ∧
      resid m n (lt_trans hn hnm) - residAsym m n ≤ 1 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) := by
  refine ⟨residAsym_le_resid hn hnm, ?_⟩
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hcpos : (0 : ℝ) < (m : ℝ) ^ 2 + (n : ℝ) ^ 2 := by positivity
  have h := resid_le_residAsym_add hn hnm
  have hlog : Real.log (1 + 1 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2)) ≤
      1 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) := by
    have := Real.add_one_le_exp (1 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2))
    have hpos : (0 : ℝ) < 1 + 1 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) := by positivity
    calc Real.log (1 + 1 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2))
        ≤ Real.log (Real.exp (1 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2))) :=
          Real.log_le_log hpos (by linarith)
      _ = 1 / ((m : ℝ) ^ 2 + (n : ℝ) ^ 2) := Real.log_exp _
  linarith

/-! ## Part B. Branch monotonicity of the slope residual (D3-lite, true two thirds) -/

/-- **Branch `B₁` never decreases the residual.**  In slope coordinates `B₁` sends
`t = n/m` to `m/(2m-n) = 1/(2-t)`, and `t ≤ 1/(2-t)` because `(m-n)² ≥ 0`. -/
theorem residAsym_seedL_ge {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    residAsym m n ≤ residAsym (2 * m - n) m := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hnmR : (n : ℝ) < (m : ℝ) := by exact_mod_cast hnm
  have hcast : ((2 * m - n : ℕ) : ℝ) = 2 * (m : ℝ) - (n : ℝ) := by
    have : n ≤ 2 * m := by omega
    push_cast [Nat.cast_sub this]
    ring
  have hden : (0 : ℝ) < 2 * (m : ℝ) - (n : ℝ) := by linarith
  rw [residAsym, residAsym, hcast]
  have hA : (n : ℝ) * (2 * (m : ℝ) - (n : ℝ)) ≤ (m : ℝ) ^ 2 := by
    nlinarith [sq_nonneg ((m : ℝ) - (n : ℝ))]
  have hA0 : 0 ≤ (n : ℝ) * (2 * (m : ℝ) - (n : ℝ)) := by positivity
  have hstep : ((n : ℝ) / (m : ℝ)) ^ 2 ≤ ((m : ℝ) / (2 * (m : ℝ) - (n : ℝ))) ^ 2 := by
    rw [div_pow, div_pow, div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [hA, hA0]
  have hpos : (0 : ℝ) < 1 + ((n : ℝ) / (m : ℝ)) ^ 2 := by positivity
  have := Real.log_le_log hpos (by linarith : (1 : ℝ) + ((n : ℝ) / (m : ℝ)) ^ 2 ≤
    1 + ((m : ℝ) / (2 * (m : ℝ) - (n : ℝ))) ^ 2)
  linarith

/-- **Branch `B₃` never increases the residual.**  In slope coordinates `B₃` sends
`t = n/m` to `n/(m+2n) = t/(1+2t) ≤ t`. -/
theorem residAsym_seedR_le {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    residAsym (m + 2 * n) n ≤ residAsym m n := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hcast : ((m + 2 * n : ℕ) : ℝ) = (m : ℝ) + 2 * (n : ℝ) := by push_cast; ring
  rw [residAsym, residAsym, hcast]
  have hmm : (m : ℝ) ^ 2 ≤ ((m : ℝ) + 2 * (n : ℝ)) ^ 2 := by nlinarith
  have hstep : ((n : ℝ) / ((m : ℝ) + 2 * (n : ℝ))) ^ 2 ≤ ((n : ℝ) / (m : ℝ)) ^ 2 := by
    rw [div_pow, div_pow, div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [hmm, sq_nonneg ((n : ℝ))]
  have hpos : (0 : ℝ) < 1 + ((n : ℝ) / ((m : ℝ) + 2 * (n : ℝ))) ^ 2 := by positivity
  have := Real.log_le_log hpos (by linarith : (1 : ℝ) + ((n : ℝ) / ((m : ℝ) + 2 * (n : ℝ))) ^ 2 ≤
    1 + ((n : ℝ) / (m : ℝ)) ^ 2)
  linarith

/-! ## Part C. The middle branch: D3-lite is false there -/

/-- The slope model already refutes monotonicity along `B₂`: the `B₂`-child `(9,4)` of the
seed `(4,1)` has the strictly larger slope residual. -/
theorem residAsym_seedM_not_antitone : residAsym 4 1 < residAsym 9 4 := by
  rw [residAsym, residAsym]
  have h : (1 : ℝ) + ((1 : ℕ) / (4 : ℕ) : ℝ) ^ 2 < 1 + (((4 : ℕ) : ℝ) / ((9 : ℕ) : ℝ)) ^ 2 := by
    norm_num
  have := Real.log_lt_log (by norm_num) h
  linarith

/-- **The sharp criterion for the middle branch.**  `B₂` decreases the slope residual
exactly when `m² ≤ 2mn + n²`, i.e. when the slope `t = n/m` exceeds `√2 - 1`.  This is the
corrected form of the middle third of D3-lite: the conjectured inequality is not universal,
it holds precisely above the threshold. -/
theorem residAsym_seedM_le_iff {m n : ℕ} (hn : 0 < n) (hnm : n < m) :
    residAsym (2 * m + n) m ≤ residAsym m n ↔ m ^ 2 ≤ 2 * m * n + n ^ 2 := by
  have hm : 0 < m := lt_trans hn hnm
  have hM : (0 : ℝ) < (m : ℝ) := by exact_mod_cast hm
  have hN : (0 : ℝ) < (n : ℝ) := by exact_mod_cast hn
  have hcast : ((2 * m + n : ℕ) : ℝ) = 2 * (m : ℝ) + (n : ℝ) := by push_cast; ring
  have hden : (0 : ℝ) < 2 * (m : ℝ) + (n : ℝ) := by linarith
  have hposA : (0 : ℝ) < 1 + ((m : ℝ) / (2 * (m : ℝ) + (n : ℝ))) ^ 2 := by positivity
  have hposB : (0 : ℝ) < 1 + ((n : ℝ) / (m : ℝ)) ^ 2 := by positivity
  rw [residAsym, residAsym, hcast]
  rw [show ((1 : ℝ) / 2) * Real.log (1 + ((m : ℝ) / (2 * (m : ℝ) + (n : ℝ))) ^ 2) ≤
      (1 / 2) * Real.log (1 + ((n : ℝ) / (m : ℝ)) ^ 2) ↔
      Real.log (1 + ((m : ℝ) / (2 * (m : ℝ) + (n : ℝ))) ^ 2) ≤
        Real.log (1 + ((n : ℝ) / (m : ℝ)) ^ 2) from by constructor <;> intro h <;> linarith]
  rw [Real.log_le_log_iff hposA hposB]
  rw [add_le_add_iff_left, div_pow, div_pow,
    div_le_div_iff₀ (by positivity) (by positivity)]
  have hcastgoal : ((m : ℝ) ^ 2 ≤ 2 * (m : ℝ) * (n : ℝ) + (n : ℝ) ^ 2) ↔
      m ^ 2 ≤ 2 * m * n + n ^ 2 := by
    constructor
    · intro h; exact_mod_cast h
    · intro h; exact_mod_cast h
  rw [← hcastgoal]
  constructor
  · intro h
    by_contra hc
    push_neg at hc
    have h1 : (n : ℝ) * (2 * (m : ℝ) + (n : ℝ)) < (m : ℝ) ^ 2 := by nlinarith
    have h2 : (0 : ℝ) ≤ (n : ℝ) * (2 * (m : ℝ) + (n : ℝ)) := by positivity
    nlinarith [h, h1, h2]
  · intro h
    nlinarith [h, hM, hN, hden]

/-- **The exact counterexample to D3-lite for the middle branch.**
The seed `(4,1)` has `B₂`-child `(9,4)`, and the true hyperbolic residual *increases*:
`resid 4 1 ≈ 0.0340 < 0.0918 ≈ resid 9 4`.

The proof is exact: from `cosh d₁ = 9/4` and `cosh d₂ = 49/9` one shows
`cosh (d₁ + ½ log (97/17)) < cosh d₂` by the addition formula, using only
`sinh d₁ = √65/4` and `√(97/17) ≤ 2.389`. -/
theorem resid_four_one_lt_resid_nine_four (h₁ : (0 : ℕ) < 4) (h₂ : (0 : ℕ) < 9) :
    resid 4 1 h₁ < resid 9 4 h₂ := by
  set d₁ := dist (hpoint 4 1 h₁) UpperHalfPlane.I with hd₁
  set d₂ := dist (hpoint 9 4 h₂) UpperHalfPlane.I with hd₂
  have hc₁ : Real.cosh d₁ = 9 / 4 := by rw [hd₁, cosh_dist_hpoint_I]; norm_num
  have hc₂ : Real.cosh d₂ = 49 / 9 := by rw [hd₂, cosh_dist_hpoint_I]; norm_num
  have h10 : 0 ≤ d₁ := dist_nonneg
  have h20 : 0 ≤ d₂ := dist_nonneg
  -- the required gap `K = ½ log 97 - ½ log 17 = log r`
  set r : ℝ := Real.sqrt (97 / 17) with hr
  have hr0 : 0 < r := Real.sqrt_pos.2 (by norm_num)
  have hr2 : r ^ 2 = 97 / 17 := Real.sq_sqrt (by norm_num)
  have hK : Real.log r = (1 / 2) * Real.log 97 - (1 / 2) * Real.log 17 := by
    rw [hr, Real.log_sqrt (by norm_num), Real.log_div (by norm_num) (by norm_num)]
    ring
  -- numerical control on `sinh d₁` and on `r`
  have hsq : Real.sinh d₁ ^ 2 = 65 / 16 := by
    have h := Real.cosh_sq_sub_sinh_sq d₁
    rw [hc₁] at h
    nlinarith [h]
  have hs0 : 0 ≤ Real.sinh d₁ := Real.sinh_nonneg_iff.mpr h10
  have hsub : Real.sinh d₁ ≤ 2.016 := by nlinarith [hsq, hs0]
  have hrub : r ≤ 2.389 := by nlinarith [hr2, hr0]
  have hinv : 1 / r = 17 * r / 97 := by
    field_simp
    nlinarith [hr2]
  have hprod : Real.sinh d₁ * r ≤ 2.016 * 2.389 :=
    mul_le_mul hsub hrub hr0.le (by norm_num)
  have hlt : Real.cosh (d₁ + Real.log r) < Real.cosh d₂ := by
    rw [Real.cosh_add, cosh_log_eq hr0, sinh_log_eq hr0, hc₁, hc₂, hinv]
    nlinarith [hprod, hrub, hr0, hs0]
  have hlogr0 : 0 < Real.log r := Real.log_pos (by nlinarith [hr2, hr0])
  have hgap : d₁ + Real.log r < d₂ := by
    have habs := (Real.cosh_lt_cosh).1 hlt
    rwa [abs_of_nonneg (by linarith), abs_of_nonneg h20] at habs
  simp only [resid, ← hd₁, ← hd₂]
  norm_num
  linarith [hK, hgap]

/-- **D3-lite is false for the middle branch.**  There is a Euclid seed whose `B₂`-child
has a strictly larger residual, so the residual is not antitone along `B₂`. -/
theorem exists_seed_resid_seedM_gt :
    ∃ m n : ℕ, IsSeed m n ∧ ∃ (hm : 0 < m) (hm' : 0 < (seedM (m, n)).1),
      resid m n hm < resid (seedM (m, n)).1 (seedM (m, n)).2 hm' := by
  refine ⟨4, 1, ⟨by norm_num, by norm_num, by decide, by decide⟩, by norm_num, by norm_num [seedM], ?_⟩
  exact resid_four_one_lt_resid_nine_four _ _

end

end HyperbolicBerggrenGeodesics