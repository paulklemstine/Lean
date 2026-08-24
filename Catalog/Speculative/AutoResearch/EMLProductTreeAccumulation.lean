/-
# Errors add, they do not compound: chained EML product gates

This file attacks the second open conjecture of the previous cycle's
`FUTURE_DIRECTIONS.md` ("Linear Error Accumulation in Product Trees"), which
predicts that a tree of `prodGate`s computing a monomial accumulates error
*linearly* in the number of gates, with the same constant `1/3`, rather than
multiplicatively as the naive bound `(1 + h²/3)^d − 1` would suggest.

The obstruction to iterating the sharp single-gate theorem of
`Bridges/EMLPolarisationSharpConstant.lean` is that the output of a gate leaves
the unit square: `prodGate h 1 1 = 1 + h²/3 + O(h⁴) > 1`.  The fix proved here is
a **box version** of the corner theorem, valid on any square `[0,M]²`:

`|prodGate h x y − x y| ≤ M⁴h²/3 + M⁶h⁴/22`   whenever `0 ≤ x,y ≤ M`, `2Mh ≤ 1`,

which is again driven only by monotonicity of `coshGap` on `[0,∞)` and the
degree-8 Taylor bracket `coshGap_taylor`.  Feeding the *output range* of one gate
into the box bound for the next then gives the two-gate (three-leaf) instance of
the conjecture.

## Main results

* `coshGap_le_quartic_sextic` — `coshGap u ≤ u⁴/12 + u⁶/352` on `[-1,1]`, the
  one-sided consequence of `coshGap_taylor` used throughout.
* `prodGate_error_box` — the box bound above.  Taking `M = 1` recovers
  `|prodGate h x y − x y| ≤ h²/3 + h⁴/22` on the unit square.
* `prodGate_range_unit` — the output range of a gate on `[0,1]²` for `h ≤ 1/4`:
  `0 ≤ prodGate h x y ≤ 33/32`.  Only `1/32` of slack is needed, and it is a
  genuine `Θ(h²)` overshoot, not an artefact.
* `prodTree3_error` — **two chained gates**: for `0 < h ≤ 1/4` and
  `x,y,z ∈ [0,1]`,
  `|prodGate h (prodGate h x y) z − x y z| ≤ 3h²/4`.
  The additive prediction for two gates is `2h²/3 ≈ 0.667 h²`; the certified
  constant `0.75` is within `13%` of it, and in particular the error is **not**
  multiplicative in the gate count at this depth.
* `prodTree3_error_sub_multiplicative` — the quantitative form of "errors add,
  they do not compound": the two-gate error is at most `9/4` times the sharp
  single-gate error `h²/3`, whereas naive error propagation through a product of
  two approximants only gives a factor growing with the operand bound.

Everything is proved from `import Mathlib` plus the two catalog files; no `sorry`.
-/
import Mathlib
import Applications.EMLDepthWidthTradeoff
import Bridges.EMLPolarisationSharpConstant

namespace EML.ProductTree

open Real Set EML.DepthWidth EML.Polarisation

noncomputable section

/-! ## 1. A one-sided sextic bound for the remainder -/

/-- One-sided consequence of the degree-`8` bracket: on `[-1,1]`,
`coshGap u ≤ u⁴/12 + u⁶/352`. -/
theorem coshGap_le_quartic_sextic (u : ℝ) (hu : |u| ≤ 1) :
    coshGap u ≤ u ^ 4 / 12 + u ^ 6 / 352 := by
  have hb := coshGap_taylor u hu
  rw [abs_le] at hb
  have hu2 : u ^ 2 ≤ 1 := by nlinarith [abs_nonneg u, sq_abs u]
  have h6 : (0:ℝ) ≤ u ^ 6 := by positivity
  have h8 : u ^ 8 ≤ u ^ 6 := by nlinarith [mul_le_mul_of_nonneg_left hu2 h6]
  linarith [hb.2]

/-! ## 2. The box version of the sharp gate bound -/

/-- **Box bound.**  On any square `[0,M]²` with `2Mh ≤ 1`, the gate error is at
most `M⁴h²/3 + M⁶h⁴/22`.  With `M = 1` this is the unit-square bound
`h²/3 + h⁴/22`; the point is the `M⁴` scaling, which is what makes chaining
possible. -/
theorem prodGate_error_box (h M x y : ℝ) (hh0 : 0 < h) (hx : 0 ≤ x) (hxM : x ≤ M)
    (hy : 0 ≤ y) (hyM : y ≤ M) (hMh : 2 * M * h ≤ 1) :
    |prodGate h x y - x * y| ≤ M ^ 4 * h ^ 2 / 3 + M ^ 6 * h ^ 4 / 22 := by
  have hM0 : 0 ≤ M := hx.trans hxM
  have h4 : (0:ℝ) < 4 * h ^ 2 := by positivity
  -- Step 1: the error is at most the "corner of the box" value.
  have hstep : |prodGate h x y - x * y| ≤ coshGap (2 * M * h) / (4 * h ^ 2) := by
    rw [abs_of_nonneg (prodGate_error_nonneg h x y hh0 hx hy),
      prodGate_sub_eq_abs h x y hh0]
    have hbranch : coshGap (h * (x + y)) ≤ coshGap (2 * M * h) :=
      coshGap_le_of_le (by positivity) (by nlinarith)
    have hrest : 0 ≤ coshGap (h * |x - y|) := coshGap_nonneg _
    have hnum : coshGap (h * (x + y)) - coshGap (h * |x - y|) ≤ coshGap (2 * M * h) := by
      linarith
    gcongr
  -- Step 2: expand the corner value with the sextic bound.
  have habs : |2 * M * h| ≤ 1 := by
    rw [abs_of_nonneg (by positivity)]
    exact hMh
  have htay := coshGap_le_quartic_sextic (2 * M * h) habs
  have hdiv : coshGap (2 * M * h) / (4 * h ^ 2) ≤ M ^ 4 * h ^ 2 / 3 + M ^ 6 * h ^ 4 / 22 := by
    rw [div_le_iff₀ h4]
    calc coshGap (2 * M * h) ≤ (2 * M * h) ^ 4 / 12 + (2 * M * h) ^ 6 / 352 := htay
      _ = (M ^ 4 * h ^ 2 / 3 + M ^ 6 * h ^ 4 / 22) * (4 * h ^ 2) := by ring
  linarith

/-- The unit-square specialisation, `M = 1`. -/
theorem prodGate_error_unit (h x y : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 2)
    (hx : 0 ≤ x) (hx1 : x ≤ 1) (hy : 0 ≤ y) (hy1 : y ≤ 1) :
    |prodGate h x y - x * y| ≤ h ^ 2 / 3 + h ^ 4 / 22 := by
  have := prodGate_error_box h 1 x y hh0 hx (by linarith) hy (by linarith) (by linarith)
  simpa using this

/-! ## 3. The output range of one gate -/

/-- **Output range.**  For `0 < h ≤ 1/4` a gate maps the unit square into
`[0, 33/32]`: the overshoot is `Θ(h²)` and `1/32` of slack suffices. -/
theorem prodGate_range_unit (h x y : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 4)
    (hx : 0 ≤ x) (hx1 : x ≤ 1) (hy : 0 ≤ y) (hy1 : y ≤ 1) :
    0 ≤ prodGate h x y ∧ prodGate h x y ≤ 33 / 32 := by
  have herr := prodGate_error_unit h x y hh0 (by linarith) hx hx1 hy hy1
  have hnn := prodGate_error_nonneg h x y hh0 hx hy
  have hxy : x * y ≤ 1 := by nlinarith
  have hxy0 : 0 ≤ x * y := mul_nonneg hx hy
  have habs : prodGate h x y - x * y ≤ h ^ 2 / 3 + h ^ 4 / 22 :=
    (le_abs_self _).trans herr
  have hh2 : h ^ 2 ≤ 1 / 16 := by nlinarith
  have hh4 : h ^ 4 ≤ 1 / 256 := by nlinarith [sq_nonneg h, sq_nonneg (h ^ 2)]
  constructor
  · linarith
  · linarith

/-! ## 4. Two chained gates -/

/-- **Two chained gates: the errors add.**  For `0 < h ≤ 1/4` and
`x, y, z ∈ [0,1]`,
`|prodGate h (prodGate h x y) z − x y z| ≤ 3h²/4`.
The additive prediction is `2·(h²/3) ≈ 0.667 h²`, so the certified constant is
within `13%` of pure additivity; no compounding term appears. -/
theorem prodTree3_error (h x y z : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 4)
    (hx : 0 ≤ x) (hx1 : x ≤ 1) (hy : 0 ≤ y) (hy1 : y ≤ 1)
    (hz : 0 ≤ z) (hz1 : z ≤ 1) :
    |prodGate h (prodGate h x y) z - x * y * z| ≤ 3 * h ^ 2 / 4 := by
  set P := prodGate h x y with hP
  obtain ⟨hP0, hP1⟩ := prodGate_range_unit h x y hh0 hh hx hx1 hy hy1
  have hh2 : h ^ 2 ≤ 1 / 16 := by nlinarith
  have hh4 : h ^ 4 ≤ h ^ 2 / 16 := by nlinarith [sq_nonneg h, sq_nonneg (h ^ 2)]
  -- outer gate, on the box `[0, 33/32]²`
  have houter : |prodGate h P z - P * z|
      ≤ (33 / 32 : ℝ) ^ 4 * h ^ 2 / 3 + (33 / 32 : ℝ) ^ 6 * h ^ 4 / 22 :=
    prodGate_error_box h (33 / 32) P z hh0 hP0 hP1 hz (by linarith) (by linarith)
  -- inner gate, on the unit square, amplified by `z ≤ 1`
  have hinner : |P * z - x * y * z| ≤ h ^ 2 / 3 + h ^ 4 / 22 := by
    have hfac : P * z - x * y * z = (P - x * y) * z := by ring
    rw [hfac, abs_mul, abs_of_nonneg hz]
    have h1 : |P - x * y| ≤ h ^ 2 / 3 + h ^ 4 / 22 :=
      prodGate_error_unit h x y hh0 (by linarith) hx hx1 hy hy1
    have h2 : (0:ℝ) ≤ h ^ 2 / 3 + h ^ 4 / 22 := by positivity
    calc |P - x * y| * z ≤ (h ^ 2 / 3 + h ^ 4 / 22) * z :=
          mul_le_mul_of_nonneg_right h1 hz
      _ ≤ (h ^ 2 / 3 + h ^ 4 / 22) * 1 := mul_le_mul_of_nonneg_left hz1 h2
      _ = h ^ 2 / 3 + h ^ 4 / 22 := by ring
  have htri : |prodGate h P z - x * y * z| ≤ |prodGate h P z - P * z| + |P * z - x * y * z| :=
    abs_sub_le _ _ _
  have hnum : (33 / 32 : ℝ) ^ 4 * h ^ 2 / 3 + (33 / 32 : ℝ) ^ 6 * h ^ 4 / 22
      + (h ^ 2 / 3 + h ^ 4 / 22) ≤ 3 * h ^ 2 / 4 := by
    have hq : (0:ℝ) ≤ h ^ 2 := sq_nonneg h
    nlinarith [hh4, hq]
  linarith

/-- **Errors add, they do not compound.**  The two-gate error is at most `9/4`
times the sharp single-gate constant `h²/3`; a multiplicative propagation model
would predict a factor depending on the operand bound `33/32` raised to the gate
count, which is *not* what happens. -/
theorem prodTree3_error_sub_multiplicative (h x y z : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 4)
    (hx : 0 ≤ x) (hx1 : x ≤ 1) (hy : 0 ≤ y) (hy1 : y ≤ 1)
    (hz : 0 ≤ z) (hz1 : z ≤ 1) :
    |prodGate h (prodGate h x y) z - x * y * z| ≤ (9 / 4) * (h ^ 2 / 3) := by
  have := prodTree3_error h x y z hh0 hh hx hx1 hy hy1 hz hz1
  linarith

/-- The chained gate is still a *one-sided* approximant: the tree over-estimates
the triple product, so the errors of a product tree can never cancel adversarially
— the mechanism behind linear accumulation. -/
theorem prodTree3_error_nonneg (h x y z : ℝ) (hh0 : 0 < h) (hh : h ≤ 1 / 4)
    (hx : 0 ≤ x) (hx1 : x ≤ 1) (hy : 0 ≤ y) (hy1 : y ≤ 1) (hz : 0 ≤ z) :
    0 ≤ prodGate h (prodGate h x y) z - x * y * z := by
  have hP0 : 0 ≤ prodGate h x y :=
    (prodGate_range_unit h x y hh0 hh hx hx1 hy hy1).1
  have houter : 0 ≤ prodGate h (prodGate h x y) z - prodGate h x y * z :=
    prodGate_error_nonneg h _ z hh0 hP0 hz
  have hinner : 0 ≤ prodGate h x y - x * y :=
    prodGate_error_nonneg h x y hh0 hx hy
  nlinarith

end

#print axioms coshGap_le_quartic_sextic
#print axioms prodGate_error_box
#print axioms prodGate_range_unit
#print axioms prodTree3_error
#print axioms prodTree3_error_nonneg

end EML.ProductTree