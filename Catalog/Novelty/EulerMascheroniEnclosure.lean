/-
# An explicit certified enclosure of `γ` and a small-denominator obstruction

This file continues the Euler–Mascheroni research thread of
`Novelty/EulerMascheroniInformationBridge.lean` and
`Novelty/EulerMascheroniSharpTails.lean`.

The sharp two-sided tail estimate proved there,

  `1/(2(n+1)) + 1/(14(n+1)²) ≤ γ - eulerMascheroniSeq n ≤ 1/(2(n+1)) + 1/(12(n+1)²)`,

is *effective*: evaluating it at a value of `n` for which `log (n+1)` is a known
multiple of `log 2` turns it into an explicit rational enclosure of `γ`.  We take
`n = 15`, where `eulerMascheroniSeq 15 = H₁₅ - 4 log 2`, and combine it with
Mathlib's decimal bounds for `log 2`.  The result is

  `0.5771692 < γ < 0.5772158`,

an interval of width `4.66 · 10⁻⁵` (the true value is `0.5772156649…`, so the upper
bound is sharp to seven decimals — a reflection of the fact that `1/12` is the exact
Euler–Maclaurin coefficient while `1/14` is not).

As an arithmetic consequence we obtain a *falsifiable, finitely checked* irrationality
step: `γ` is not a rational number of denominator at most `148`.  The threshold is
optimal for this enclosure: `86/149 = 0.577181…` lies inside the interval, so no
denominator beyond `148` can be excluded without a sharper enclosure.

## Main results

* `eulerMascheroniSeq_fifteen` — `eulerMascheroniSeq 15 = 1195757/360360 - 4 log 2`.
* `gamma_gt`, `gamma_lt` — the certified enclosure `0.5771692 < γ < 0.5772158`.
* `gamma_ne_div_of_den_le` — `γ ≠ p/q` for every integer `p` and every `1 ≤ q ≤ 148`.
* `gamma_ne_rat_of_den_le` — the same statement phrased for rationals: no `r : ℚ`
  with `r.den ≤ 148` equals `γ`.
* `gamma_pos`, `gamma_lt_one` — elementary consequences.
-/
import Mathlib
import Novelty.EulerMascheroniSharpTails

open Real Filter Finset Topology
open EulerMascheroniSharpTails

namespace EulerMascheroniEnclosure

/-! ## 1. The approximant at `n = 15` -/

/-- `H₁₅ = 1195757/360360`. -/
theorem harmonic_fifteen : (harmonic 15 : ℚ) = 1195757 / 360360 := by
  simp [harmonic, Finset.sum_range_succ]
  norm_num

/-- `log 16 = 4 log 2`. -/
theorem log_sixteen : Real.log 16 = 4 * Real.log 2 := by
  rw [show (16 : ℝ) = 2 ^ 4 by norm_num, Real.log_pow]
  ring

/-- The Euler–Mascheroni approximant at `n = 15` is *rational up to a multiple of
`log 2`*: `eulerMascheroniSeq 15 = 1195757/360360 - 4 log 2`. -/
theorem eulerMascheroniSeq_fifteen :
    Real.eulerMascheroniSeq 15 = 1195757 / 360360 - 4 * Real.log 2 := by
  rw [Real.eulerMascheroniSeq]
  have h : ((harmonic 15 : ℚ) : ℝ) = (1195757 : ℝ) / 360360 := by
    rw [harmonic_fifteen]; norm_num
  rw [h]
  norm_num [log_sixteen]

/-! ## 2. The certified enclosure -/

/-- **Lower bound.** `0.5771692 < γ`.  Obtained from the sharp tail estimate at
`n = 15` together with `log 2 < 0.6931471808`. -/
theorem gamma_gt : (5771692 : ℝ) / 10 ^ 7 < Real.eulerMascheroniConstant := by
  have htail := tail_lower_sharp 15
  norm_num at htail
  rw [eulerMascheroniSeq_fifteen] at htail
  have hlog := Real.log_two_lt_d9
  norm_num at hlog ⊢
  linarith

/-- **Upper bound.** `γ < 0.5772158`.  Obtained from the tail estimate at `n = 15`
together with `0.6931471803 < log 2`.  The bound is sharp to seven decimals. -/
theorem gamma_lt : Real.eulerMascheroniConstant < (5772158 : ℝ) / 10 ^ 7 := by
  have htail := tail_upper 15
  norm_num at htail
  rw [eulerMascheroniSeq_fifteen] at htail
  have hlog := Real.log_two_gt_d9
  norm_num at hlog ⊢
  linarith

/-- `0 < γ`. -/
theorem gamma_pos : 0 < Real.eulerMascheroniConstant := by
  have := gamma_gt; norm_num at this ⊢; linarith

/-- `γ < 1`. -/
theorem gamma_lt_one : Real.eulerMascheroniConstant < 1 := by
  have := gamma_lt; norm_num at this ⊢; linarith

/-! ## 3. A finitely checked small-denominator obstruction -/

/-- The finite arithmetic certificate: for every denominator `1 ≤ r ≤ 148` the open
interval `(0.5771692 · r, 0.5772158 · r)` contains no integer.  Equivalently, the
successor of `⌊0.5771692 · r⌋` already exceeds `0.5772158 · r`. -/
theorem no_integer_in_interval :
    ∀ r ∈ Finset.Icc 1 148, 5772158 * r ≤ 10000000 * ((5771692 * r) / 10000000 + 1) := by
  set_option maxRecDepth 4000 in decide

/-- **Small-denominator obstruction.** `γ` is not a fraction `p/q` with `1 ≤ q ≤ 148`.
This is a genuine (if finite) irrationality step: it rules out every rational of
denominator at most `148` by combining the certified enclosure with a finite integer
check.  The threshold `148` is optimal for this enclosure, since
`86/149 = 0.577181…` lies inside `(0.5771692, 0.5772158)`. -/
theorem gamma_ne_div_of_den_le (p : ℤ) (q : ℕ) (hq : 0 < q) (hqle : q ≤ 148) :
    Real.eulerMascheroniConstant ≠ (p : ℝ) / (q : ℝ) := by
  intro h
  have hq0 : (0 : ℝ) < (q : ℝ) := by exact_mod_cast hq
  have hL : (5771692 : ℝ) / 10 ^ 7 < (p : ℝ) / (q : ℝ) := h ▸ gamma_gt
  have hU : (p : ℝ) / (q : ℝ) < (5772158 : ℝ) / 10 ^ 7 := h ▸ gamma_lt
  rw [div_lt_div_iff₀ (by norm_num) hq0] at hL
  rw [div_lt_div_iff₀ hq0 (by norm_num)] at hU
  have h1 : (5771692 : ℤ) * (q : ℤ) < 10000000 * p := by
    have : (5771692 : ℝ) * (q : ℝ) < 10000000 * (p : ℝ) := by norm_num at hL ⊢; linarith
    exact_mod_cast this
  have h2 : (10000000 : ℤ) * p < 5772158 * (q : ℤ) := by
    have : (10000000 : ℝ) * (p : ℝ) < 5772158 * (q : ℝ) := by norm_num at hU ⊢; linarith
    exact_mod_cast this
  have hq1 : (1 : ℤ) ≤ (q : ℤ) := by exact_mod_cast hq
  have hp : 0 < p := by nlinarith
  obtain ⟨m, rfl⟩ := Int.eq_ofNat_of_zero_le hp.le
  have h1n : 5771692 * q < 10000000 * m := by exact_mod_cast h1
  have h2n : 10000000 * m < 5772158 * q := by exact_mod_cast h2
  have hcert := no_integer_in_interval q (Finset.mem_Icc.mpr ⟨hq, hqle⟩)
  have hfloor : (5771692 * q) / 10000000 < m :=
    (Nat.div_lt_iff_lt_mul (by norm_num)).mpr (by omega)
  have hstep : 10000000 * ((5771692 * q) / 10000000 + 1) ≤ 10000000 * m := by
    exact Nat.mul_le_mul_left _ hfloor
  omega

/-- **Rational form of the obstruction.** No rational number with denominator at most
`148` equals `γ`. -/
theorem gamma_ne_rat_of_den_le (r : ℚ) (hr : r.den ≤ 148) :
    Real.eulerMascheroniConstant ≠ (r : ℝ) := by
  have hden : 0 < r.den := r.pos
  have hcast : (r : ℝ) = (r.num : ℝ) / (r.den : ℝ) := by
    rw [← Rat.cast_def]
  rw [hcast]
  exact gamma_ne_div_of_den_le r.num r.den hden hr

end EulerMascheroniEnclosure