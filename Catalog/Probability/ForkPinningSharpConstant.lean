/-
# The sharp constant of the semiprime dial (conjecture C6, closed)

`ForkPinningSemiprimeGeneral.semiprime_OR_mutualInfo_general` computes, for every finite group
`G` of order `n ≥ 2`, the exact information the class of a semiprime `N = p q` carries about the
fork `[p splits] ∨ [q splits]`:

`I(n) = log n + ( −(2n−1) log(2n−1) + (n−1)(3−2n) log(n−1) + 2(n−1) log 2
            + (n−1)(n−2) log(n−2) ) / n²`.

`ForkPinningCollapse.semiprime_collapse_rate` bounds it by `1/((2n−1)(n−1))`, which only shows
`n² I(n) ≲ 1/2` asymptotically.  This file identifies the *sharp* second-order constant, which
was conjecture **C6** of `FUTURE_DIRECTIONS.md`:

* `ForkPinning.semiprimeDial` : the closed form as a function of a real parameter `n`;
* `ForkPinning.semiprimeDial_eq` : it really is the mutual information of the group model;
* `ForkPinning.n_sq_semiprimeDial_eq` : the exact "log `n` cancels" identity
  `n² I(n) = −log 2 − (2n−1) log(1 − 1/(2n)) + (n−1)(3−2n) log(1 − 1/n) + (n−1)(n−2) log(1 − 2/n)`;
* `ForkPinning.abs_n_sq_semiprimeDial_sub_le` : the quantitative estimate
  `|n² I(n) − (1 − log 2)| ≤ 24/n` for every real `n ≥ 4`;
* `ForkPinning.semiprimeDial_sharp_constant` : hence `n² I(n) → 1 − log 2 = 0.30685…`;
* `ForkPinning.n_sq_mutualInfo_lt_one` : and `n² I(n) < 1` for *every* finite group with `n ≥ 2`
  (the case `n = 2` is the exact value `3 log(4/3) = 0.863…`, the case `n ≥ 3` follows from the
  `χ²` collapse bound).

The analytic engine is the third-order Taylor estimate `|log(1−x) + x + x²/2| ≤ 2x³` on
`[0, 1/2]` (`ForkPinning.abs_log_one_sub_taylor_le`), applied at the three scales
`x = 1/(2n), 1/n, 2/n`; the leading `2n` terms coming from `log(1−1/n)` and `log(1−2/n)` cancel
exactly, which is the reason a *finite* constant survives at order `n⁻²` at all.
-/

import Probability.ForkPinningCollapse

namespace ForkPinning

open Real Filter Topology

/-! ## The closed form as a function of a real parameter -/

/-- The universal semiprime dial as an explicit function of the group order. -/
noncomputable def semiprimeDial (n : ℝ) : ℝ :=
  Real.log n + (-(2 * n - 1) * Real.log (2 * n - 1)
      + (n - 1) * (3 - 2 * n) * Real.log (n - 1)
      + 2 * (n - 1) * Real.log 2
      + (n - 1) * (n - 2) * Real.log (n - 2)) / (n * n)

variable {G : Type*} [Group G] [Fintype G] [DecidableEq G]

/-- `semiprimeDial` is the semiprime-level mutual information of any finite group model. -/
theorem semiprimeDial_eq (n : ℝ) (hcard : (Fintype.card G : ℝ) = n) (hn : 2 ≤ n) :
    mutualInfo (prodClass : G × G → G) splitORG = semiprimeDial n :=
  semiprime_OR_mutualInfo_general n hcard hn

/-! ## The `log n` cancellation -/

/-- **The leading term cancels exactly.**  Multiplying the dial by `n²` and expanding every
logarithm around `log n` leaves only bounded logarithms of `1 − O(1/n)` and the constant
`−log 2`; in particular `n² I(n)` is bounded. -/
theorem n_sq_semiprimeDial_eq (n : ℝ) (hn : 3 ≤ n) :
    n ^ 2 * semiprimeDial n
      = -Real.log 2 - (2 * n - 1) * Real.log (1 - 1 / (2 * n))
        + (n - 1) * (3 - 2 * n) * Real.log (1 - 1 / n)
        + (n - 1) * (n - 2) * Real.log (1 - 2 / n) := by
  have hn0 : (0 : ℝ) < n := by linarith
  have h1 : Real.log (2 * n - 1) = Real.log 2 + Real.log n + Real.log (1 - 1 / (2 * n)) := by
    have h : (2 * n - 1) = (2 * n) * (1 - 1 / (2 * n)) := by field_simp
    rw [h, Real.log_mul (by positivity) (by intro hc; nlinarith [hc]),
      Real.log_mul (by norm_num) (by positivity)]
  have h2 : Real.log (n - 1) = Real.log n + Real.log (1 - 1 / n) := by
    have h : (n - 1) = n * (1 - 1 / n) := by field_simp
    rw [h, Real.log_mul (by positivity) (by intro hc; nlinarith [hc])]
  have h3 : Real.log (n - 2) = Real.log n + Real.log (1 - 2 / n) := by
    have h : (n - 2) = n * (1 - 2 / n) := by field_simp
    rw [h, Real.log_mul (by positivity) (by intro hc; nlinarith [hc])]
  rw [semiprimeDial, h1, h2, h3]
  field_simp
  ring

/-! ## A third-order Taylor estimate for `log (1 − x)` -/

/-- `|log (1 − x) + x + x²/2| ≤ 2 x³` for `0 ≤ x ≤ 1/2`. -/
theorem abs_log_one_sub_taylor_le {x : ℝ} (hx : 0 ≤ x) (hx2 : x ≤ 1 / 2) :
    |Real.log (1 - x) + x + x ^ 2 / 2| ≤ 2 * x ^ 3 := by
  have h := Real.abs_log_sub_add_sum_range_le (x := x) (by rw [abs_of_nonneg hx]; linarith) 2
  rw [abs_of_nonneg hx] at h
  simp [Finset.sum_range_succ] at h
  have hx3 : (0 : ℝ) ≤ x ^ 3 := by positivity
  calc |Real.log (1 - x) + x + x ^ 2 / 2| = |x + x ^ 2 / 2 + Real.log (1 - x)| := by ring_nf
    _ ≤ x ^ 3 / (1 - x) := by convert h using 2; ring
    _ ≤ 2 * x ^ 3 := by rw [div_le_iff₀ (by linarith)]; nlinarith

/-! ## The quantitative second-order estimate -/

/-- **The sharp constant, quantitatively.**  For every real `n ≥ 4`,
`|n² I(n) − (1 − log 2)| ≤ 24/n`. -/
theorem abs_n_sq_semiprimeDial_sub_le (n : ℝ) (hn : 4 ≤ n) :
    |n ^ 2 * semiprimeDial n - (1 - Real.log 2)| ≤ 24 / n := by
  have hn0 : (0 : ℝ) < n := by linarith
  set e1 := Real.log (1 - 1 / (2 * n)) + 1 / (2 * n) + (1 / (2 * n)) ^ 2 / 2 with he1
  set e2 := Real.log (1 - 1 / n) + 1 / n + (1 / n) ^ 2 / 2 with he2
  set e3 := Real.log (1 - 2 / n) + 2 / n + (2 / n) ^ 2 / 2 with he3
  have hb1 : |e1| ≤ 2 * (1 / (2 * n)) ^ 3 :=
    abs_log_one_sub_taylor_le (by positivity) (by rw [div_le_div_iff₀] <;> linarith)
  have hb2 : |e2| ≤ 2 * (1 / n) ^ 3 :=
    abs_log_one_sub_taylor_le (by positivity) (by rw [div_le_div_iff₀] <;> linarith)
  have hb3 : |e3| ≤ 2 * (2 / n) ^ 3 :=
    abs_log_one_sub_taylor_le (by positivity) (by rw [div_le_div_iff₀] <;> linarith)
  have hb1' : |e1| ≤ 1 / (4 * n ^ 3) := hb1.trans (le_of_eq (by field_simp; ring))
  have hb2' : |e2| ≤ 2 / n ^ 3 := hb2.trans (le_of_eq (by field_simp))
  have hb3' : |e3| ≤ 16 / n ^ 3 := hb3.trans (le_of_eq (by field_simp; ring))
  have hid : n ^ 2 * semiprimeDial n - (1 - Real.log 2)
      = 9 / (4 * n) - 21 / (8 * n ^ 2)
        + (-(2 * n - 1) * e1 + (n - 1) * (3 - 2 * n) * e2 + (n - 1) * (n - 2) * e3) := by
    rw [n_sq_semiprimeDial_eq n (by linarith), he1, he2, he3]
    field_simp
    ring
  have t1 : |(-(2 * n - 1)) * e1| ≤ 1 / (8 * n) := by
    rw [abs_mul, abs_neg, abs_of_nonneg (by linarith : (0 : ℝ) ≤ 2 * n - 1)]
    refine (mul_le_mul_of_nonneg_left hb1' (by linarith : (0 : ℝ) ≤ 2 * n - 1)).trans ?_
    rw [show (2 * n - 1) * (1 / (4 * n ^ 3)) = (2 * n - 1) / (4 * n ^ 3) by ring,
      div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [mul_nonneg hn0.le (by linarith : (0 : ℝ) ≤ n - 4)]
  have hc2 : (n - 1) * (3 - 2 * n) ≤ 0 :=
    mul_nonpos_of_nonneg_of_nonpos (by linarith) (by linarith)
  have hc3 : (0 : ℝ) ≤ (n - 1) * (n - 2) := mul_nonneg (by linarith) (by linarith)
  have t2 : |((n - 1) * (3 - 2 * n)) * e2| ≤ 4 / n := by
    rw [abs_mul, abs_of_nonpos hc2]
    refine (mul_le_mul_of_nonneg_left hb2'
      (by linarith : (0 : ℝ) ≤ -((n - 1) * (3 - 2 * n)))).trans ?_
    rw [show -((n - 1) * (3 - 2 * n)) * (2 / n ^ 3) = (2 * (n - 1) * (2 * n - 3)) / n ^ 3 by ring,
      div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [mul_nonneg hn0.le (by linarith : (0 : ℝ) ≤ n - 4)]
  have t3 : |((n - 1) * (n - 2)) * e3| ≤ 16 / n := by
    rw [abs_mul, abs_of_nonneg hc3]
    refine (mul_le_mul_of_nonneg_left hb3' hc3).trans ?_
    rw [show (n - 1) * (n - 2) * (16 / n ^ 3) = (16 * (n - 1) * (n - 2)) / n ^ 3 by ring,
      div_le_div_iff₀ (by positivity) (by positivity)]
    nlinarith [mul_nonneg hn0.le (by linarith : (0 : ℝ) ≤ n - 4)]
  have hlin : |9 / (4 * n) - 21 / (8 * n ^ 2)| ≤ 9 / (4 * n) + 21 / (8 * n ^ 2) := by
    refine (abs_sub _ _).trans ?_
    rw [abs_of_nonneg (by positivity : (0 : ℝ) ≤ 9 / (4 * n)),
      abs_of_nonneg (by positivity : (0 : ℝ) ≤ 21 / (8 * n ^ 2))]
  have hfinal : 9 / (4 * n) + 21 / (8 * n ^ 2) + (1 / (8 * n) + 4 / n + 16 / n) ≤ 24 / n := by
    have h : 24 / n - (9 / (4 * n) + 21 / (8 * n ^ 2) + (1 / (8 * n) + 4 / n + 16 / n))
        = (13 * n - 21) / (8 * n ^ 2) := by field_simp; ring
    have h2 : (0 : ℝ) ≤ (13 * n - 21) / (8 * n ^ 2) :=
      div_nonneg (by linarith) (by positivity)
    linarith
  rw [hid]
  refine (abs_add_le _ _).trans (le_trans (add_le_add hlin ?_) hfinal)
  exact (abs_add_le _ _).trans (add_le_add ((abs_add_le _ _).trans (add_le_add t1 t2)) t3)

/-- **C6, the sharp semiprime constant.**  `n² I(n) → 1 − log 2 = 0.3068528…`:
the semiprime dial of a group of order `n` is asymptotically `(1 − log 2)/n²`, half the naive
`χ²` bound `1/((2n−1)(n−1)) ∼ 1/(2n²)`. -/
theorem semiprimeDial_sharp_constant :
    Tendsto (fun n : ℕ => (n : ℝ) ^ 2 * semiprimeDial n) atTop (𝓝 (1 - Real.log 2)) := by
  have hzero : Tendsto (fun n : ℕ => ((n : ℝ) ^ 2 * semiprimeDial n) - (1 - Real.log 2))
      atTop (𝓝 0) := by
    refine squeeze_zero_norm' (a := fun n : ℕ => 24 / (n : ℝ)) ?_ ?_
    · filter_upwards [eventually_ge_atTop 4] with n hn
      have hn' : (4 : ℝ) ≤ (n : ℝ) := by exact_mod_cast hn
      simpa [Real.norm_eq_abs] using abs_n_sq_semiprimeDial_sub_le (n : ℝ) hn'
    · simpa using tendsto_const_div_atTop_nhds_zero_nat 24
  simpa using hzero.add_const (1 - Real.log 2)

/-! ## The dial never reaches the `1/n²` scale -/

/-- The exact `n = 2` value of the dial: `4 I(2) = 3 log (4/3)`. -/
theorem n_sq_semiprimeDial_two : (2 : ℝ) ^ 2 * semiprimeDial 2 = 3 * Real.log (4 / 3) := by
  have h : Real.log (4 / 3 : ℝ) = 2 * Real.log 2 - Real.log 3 := by
    rw [Real.log_div (by norm_num) (by norm_num),
      show (4 : ℝ) = 2 ^ 2 by norm_num, Real.log_pow]
    push_cast
    ring
  rw [semiprimeDial, h]
  norm_num
  ring

/-- **The dial is always below the `1/n²` threshold.**  For every finite group of order `n ≥ 2`,
`n² I(n) < 1`; combined with `semiprimeDial_sharp_constant` the true asymptotic value is
`1 − log 2 = 0.3069…`. -/
theorem n_sq_mutualInfo_lt_one (hn : 2 ≤ Fintype.card G) :
    (Fintype.card G : ℝ) ^ 2 * mutualInfo (prodClass : G × G → G) splitORG < 1 := by
  rcases eq_or_lt_of_le hn with h2 | h3
  · -- `n = 2`: the exact value `3 log (4/3) < 1`.
    have hcard : ((Fintype.card G : ℝ)) = 2 := by rw [← h2]; norm_num
    rw [semiprimeDial_eq 2 hcard (by norm_num), hcard, n_sq_semiprimeDial_two]
    nlinarith [Real.log_lt_sub_one_of_pos (x := (4 / 3 : ℝ)) (by norm_num) (by norm_num)]
  · -- `n ≥ 3`: the `χ²` collapse bound already gives `n²/((2n−1)(n−1)) < 1`.
    have h3' : (3 : ℝ) ≤ (Fintype.card G : ℝ) := by exact_mod_cast h3
    have hpos : (0 : ℝ) < (Fintype.card G : ℝ) := by linarith
    have hrate := semiprime_collapse_rate (G := G) (Fintype.card G : ℝ) rfl (by linarith)
    have hmul : (Fintype.card G : ℝ) ^ 2 * mutualInfo (prodClass : G × G → G) splitORG
        ≤ (Fintype.card G : ℝ) ^ 2 * (1 / ((2 * (Fintype.card G : ℝ) - 1)
            * ((Fintype.card G : ℝ) - 1))) :=
      mul_le_mul_of_nonneg_left hrate (by positivity)
    refine lt_of_le_of_lt hmul ?_
    rw [mul_one_div, div_lt_one (by nlinarith)]
    nlinarith

end ForkPinning