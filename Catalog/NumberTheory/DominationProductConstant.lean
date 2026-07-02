import Mathlib
import Catalog.Combinatorics.GraphDominationBox

/-!
# The improved Vizing-type constant `(19 - √73)/18`

Vizing's conjecture asserts `γ(G □ H) ≥ γ(G)·γ(H)`. Clark and Suen proved the
unconditional bound `γ(G □ H) ≥ ½·γ(G)·γ(H)`, and subsequent work (Suen–Tarr and
others) improved the constant. This file isolates the arithmetic of the improved
constant

`cST := (19 - √73)/18 ≈ 0.5809`,

showing it is the relevant root of `9x² - 19x + 8 = 0` and that it lies strictly
between the Clark–Suen constant `½` and the Vizing constant `1`. We then prove the
Vizing-type lower bound *with this constant* in every case where the projection
bound already forces it, namely when one factor has domination number `≤ 1`.

-- !-- Lab Notes -- !--
Hypothesis (Hypothesizer): The number `(19 - √73)/18` from the description is the
smaller root of a quadratic with integer coefficients. Guess: `9x² - 19x + 8`,
since its roots are `(19 ± √(361 - 288))/18 = (19 ± √73)/18`. If so, `cST` is
algebraic of degree 2 and the improvement over `½` is exact.

Experiment (Experimenter): `√73 ≈ 8.544`, so `cST ≈ 10.456/18 ≈ 0.5809`, which is
`> 0.5` and `< 1`, matching the requirement that it strictly beats Clark–Suen and
stays below Vizing. Plugging `cST` into `9x² - 19x + 8` numerically gives `≈ 0`.

Analysis (Analyst): The quadratic identity is proved by clearing denominators and
using `(√73)² = 73` (`Real.sq_sqrt`), then `nlinarith`. The strict bounds reduce to
`1 < √73 < 10`, i.e. `√1 < √73 < √100`, via monotonicity of `sqrt`. The
*conditional* Vizing bound then follows purely from `max(γG,γH) ≤ γ(G □ H)`
(proved in `GraphDominationBox`) together with `0 < cST < 1`: when `min(γG,γH) ≤ 1`
we get `cST·γG·γH ≤ max(γG,γH) ≤ γ(G □ H)`.

Critique (Critic): The unconditional constant bound is a deep open-adjacent result
and is *not* claimed here; we honestly restrict to `min(γG,γH) ≤ 1`, where the
inequality is a genuine consequence of the projection lower bound and the algebra
of `cST`. The constant lemmas are not `norm_num`-only: they manipulate `√73`
symbolically. `Nonempty` hypotheses are carried through from the projection bound.

Synthesis (PI): Together with `GraphDominationBox`, this gives a faithful formal
account of *why* `(19 - √73)/18` is the natural constant to aim for, and a proof of
the target inequality in the regime the elementary projection method already
covers.
-/

open Real

namespace GraphDom

/-- The improved Vizing-type constant `(19 - √73)/18`. -/
noncomputable def cST : ℝ := (19 - Real.sqrt 73) / 18

/-- `(√73)² = 73`. -/
lemma sqrt73_sq : Real.sqrt 73 ^ 2 = 73 := Real.sq_sqrt (by norm_num)

/-- `cST` is a root of `9x² - 19x + 8`. -/
theorem cST_root : 9 * cST ^ 2 - 19 * cST + 8 = 0 := by
  have h : Real.sqrt 73 ^ 2 = 73 := sqrt73_sq
  unfold cST
  field_simp
  nlinarith [h]

/-- `cST` strictly improves the Clark–Suen constant `½`. -/
theorem half_lt_cST : (1 : ℝ) / 2 < cST := by
  unfold cST
  have h : Real.sqrt 73 < 10 := by
    have : Real.sqrt 73 < Real.sqrt 100 := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    rwa [show (100 : ℝ) = 10 ^ 2 by norm_num, Real.sqrt_sq (by norm_num)] at this
  linarith

/-- `cST` stays strictly below the (conjectural) Vizing constant `1`. -/
theorem cST_lt_one : cST < 1 := by
  unfold cST
  have h : (1 : ℝ) < Real.sqrt 73 := by
    have : Real.sqrt 1 < Real.sqrt 73 := by
      apply Real.sqrt_lt_sqrt <;> norm_num
    rwa [Real.sqrt_one] at this
  linarith

/-- `cST` is positive. -/
lemma cST_pos : 0 < cST := lt_trans (by norm_num) half_lt_cST

variable {α β : Type*} [Fintype α] [DecidableEq α] [Fintype β] [DecidableEq β]

/-- **Conditional improved Vizing bound.** Whenever one of the two graphs has
domination number at most `1`, the Suen–Tarr-type inequality
`γ(G □ H) ≥ cST · γ(G) · γ(H)` holds, where `cST = (19 - √73)/18`. This is the
regime already forced by the elementary projection lower bound
`max(γ G, γ H) ≤ γ(G □ H)` together with `0 < cST < 1`. -/
theorem boxProd_vizing_bound_of_min_le_one
    (G : SimpleGraph α) (H : SimpleGraph β) [Nonempty α] [Nonempty β]
    (hmin : min (dominationNumber G) (dominationNumber H) ≤ 1) :
    cST * (dominationNumber G : ℝ) * (dominationNumber H : ℝ)
      ≤ (dominationNumber (G □ H) : ℝ) := by
  have haD : dominationNumber G ≤ dominationNumber (G □ H) :=
    le_boxProd_dominationNumber_left G H
  have hbD : dominationNumber H ≤ dominationNumber (G □ H) :=
    le_boxProd_dominationNumber_right G H
  have hcpos : 0 < cST := cST_pos
  have hc1 : cST < 1 := cST_lt_one
  set a := dominationNumber G
  set b := dominationNumber H
  set D := dominationNumber (G □ H)
  have hane : (0 : ℝ) ≤ (a : ℝ) := by positivity
  have hbne : (0 : ℝ) ≤ (b : ℝ) := by positivity
  rcases le_total a b with hab | hab
  · have ha1 : a ≤ 1 := le_trans (by simp [min_eq_left hab]) hmin
    have haR : (a : ℝ) ≤ 1 := by exact_mod_cast ha1
    have hbDR : (b : ℝ) ≤ (D : ℝ) := by exact_mod_cast hbD
    nlinarith [mul_nonneg (le_of_lt hcpos) hbne]
  · have hb1 : b ≤ 1 := le_trans (by simp [min_eq_right hab]) hmin
    have hbR : (b : ℝ) ≤ 1 := by exact_mod_cast hb1
    have haDR : (a : ℝ) ≤ (D : ℝ) := by exact_mod_cast haD
    nlinarith [mul_nonneg (le_of_lt hcpos) hane]

end GraphDom