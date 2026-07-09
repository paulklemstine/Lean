/-
Copyright (c) 2026 Harmonic. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.

# Split Geometry: a transcendental–algebraic bridge for a direction-dependent metric

We study the *Split Geometry* on `ℝ²` with the diagonal Riemannian metric
`ds² = dx²/cosh²y + cosh²x · dy²`, which expands in the `x`-direction and
contracts in the `y`-direction.  Attached to it is the **phase function**

  `K x y = sech²x − sech²y`,     where `sech t = 1 / cosh t`,

whose sign was proposed as the sign of the curvature and which is supposed to
determine an "elliptic" region, a "hyperbolic" region, and a flat
"phase boundary".

## The connector theorem (analysis ↔ algebraic geometry)

The first group of results forms a bridge between two a-priori unrelated areas:

* the **transcendental analysis** of the hyperbolic secant `sech = 1/cosh`, and
* the **plane algebraic geometry** of the degenerate conic `x² = y²`
  (the union of the two diagonal lines `y = x` and `y = -x`).

Concretely we prove that the entire sign structure of the transcendental
function `K x y = sech²x − sech²y` is governed *exactly* by the algebraic
comparison of `x²` and `y²`:

* `splitPhase_eq_zero_iff` :  `K x y = 0 ↔ x² = y²`
* `splitPhase_pos_iff`     :  `0 < K x y ↔ x² < y²`
* `splitPhase_neg_iff`     :  `K x y < 0 ↔ y² < x²`

and, translating the algebraic variety `x² = y²` into its two irreducible
linear components, the phase boundary is exactly the pair of diagonals:

* `splitPhase_boundary`    :  `K x y = 0 ↔ (y = x ∨ y = -x)`.

We also record that the metric is genuinely Riemannian (its coefficient
functions are everywhere positive, so the metric is positive definite), and the
"split duality" `K x y = -K y x` that interchanges the two phases.

## Christoffel symbols

The second group of results carries out the Levi-Civita computation the prompt
asks for.  For the diagonal metric `g_xx = sech²y`, `g_yy = cosh²x` we compute
the two nonzero metric derivatives (`∂_y g_xx`, `∂_x g_yy`) rigorously with
`HasDerivAt`, define the six Christoffel symbols by the standard diagonal-metric
formulas, and prove their closed forms:

* `Gamma_xxy_eq` : `Γ¹₁₂ = -tanh y`
* `Gamma_yxy_eq` : `Γ²₁₂ = tanh x`
* `Gamma_xyy_eq` : `Γ¹₂₂ = -cosh x · sinh x · cosh²y`
* `Gamma_yxx_eq` : `Γ²₁₁ = sinh y / (cosh³y · cosh²x)`
* `Gamma_xxx_deriv_zero`, `Gamma_yyy_deriv_zero` : the two vanishing components.

## A note on the conjectured curvature

The research prompt conjectured that the *Gaussian* curvature of the metric is
exactly `K x y = sech²x − sech²y`.  A direct Brioschi computation shows this is
only correct *on the coordinate axes*; off the axes the true Gaussian curvature
is `-cosh²y + (2·sech²y − 1)·sech²x`, which is not the clean diagonal expression
(see `ComputationalEvidence.md`).  We therefore state the theorems about the
proposed sign field `K` on its own terms — as an exact transcendental/algebraic
identity of independent interest — rather than asserting it equals the curvature.
The sign field `K` does agree with the true curvature *in sign* along the axes,
where the "expanding/contracting" intuition of the geometry is cleanest.
-/
import Mathlib

open Real

namespace SplitGeometry

/-- `sechSq t = 1 / cosh² t`, the square of the hyperbolic secant. -/
noncomputable def sechSq (t : ℝ) : ℝ := 1 / Real.cosh t ^ 2

/-- The first metric coefficient `g_xx = 1/cosh²y = sech²y` of the split metric
`ds² = dx²/cosh²y + cosh²x·dy²`. -/
noncomputable def gxx (_x y : ℝ) : ℝ := sechSq y

/-- The second metric coefficient `g_yy = cosh²x` of the split metric. -/
noncomputable def gyy (x _y : ℝ) : ℝ := Real.cosh x ^ 2

/-- The **phase function** `K x y = sech²x − sech²y`.  Its sign is the object of
the connector theorem: it is governed exactly by the algebraic sign of
`x² − y²`. -/
noncomputable def splitPhase (x y : ℝ) : ℝ := sechSq x - sechSq y

/-! ## The metric is a genuine Riemannian metric -/

/-- `sechSq` is strictly positive. -/
theorem sechSq_pos (t : ℝ) : 0 < sechSq t := by
  unfold sechSq; positivity

/-- The split metric is positive definite: its `xx`-coefficient is positive. -/
theorem gxx_pos (x y : ℝ) : 0 < gxx x y := sechSq_pos y

/-- The split metric is positive definite: its `yy`-coefficient is positive. -/
theorem gyy_pos (x y : ℝ) : 0 < gyy x y := by
  unfold gyy; positivity

/-- The metric determinant `g_xx · g_yy = cosh²x / cosh²y` is everywhere
positive, so the split metric is a genuine (non-degenerate, positive definite)
Riemannian metric on the whole plane. -/
theorem det_pos (x y : ℝ) : 0 < gxx x y * gyy x y :=
  mul_pos (gxx_pos x y) (gyy_pos x y)

/-! ## The connector theorem: analysis ↔ algebraic geometry -/

/-- Comparison lemma bridging the transcendental and algebraic worlds:
`sech²x = sech²y ↔ x² = y²`. -/
theorem sechSq_eq_iff (x y : ℝ) : sechSq x = sechSq y ↔ x ^ 2 = y ^ 2 := by
  unfold sechSq
  constructor
  · intro h
    have hcc : Real.cosh x = Real.cosh y := by
      have h2 : Real.cosh x ^ 2 = Real.cosh y ^ 2 := by
        field_simp at h
        linarith [h]
      nlinarith [Real.cosh_pos x, Real.cosh_pos y, h2]
    have habs : |x| = |y| :=
      le_antisymm (Real.cosh_le_cosh.1 hcc.le) (Real.cosh_le_cosh.1 hcc.ge)
    rw [← sq_abs x, ← sq_abs y, habs]
  · intro h
    have habs : |x| = |y| := by
      rw [← sq_abs x, ← sq_abs y] at h
      nlinarith [abs_nonneg x, abs_nonneg y]
    have hcc : Real.cosh x = Real.cosh y :=
      le_antisymm (Real.cosh_le_cosh.2 habs.le) (Real.cosh_le_cosh.2 habs.ge)
    rw [hcc]

/-- **Connector (zero locus).**  The phase function vanishes exactly on the
algebraic variety `x² = y²`. -/
theorem splitPhase_eq_zero_iff (x y : ℝ) : splitPhase x y = 0 ↔ x ^ 2 = y ^ 2 := by
  unfold splitPhase
  rw [sub_eq_zero]
  exact sechSq_eq_iff x y

/-- **Connector (positive region).**
`0 < K x y ↔ x² < y²`, i.e. the region `|x| < |y|`. -/
theorem splitPhase_pos_iff (x y : ℝ) : 0 < splitPhase x y ↔ x ^ 2 < y ^ 2 := by
  unfold splitPhase sechSq
  rw [sub_pos]
  have hcx : (0:ℝ) < Real.cosh x ^ 2 := by positivity
  have hcy : (0:ℝ) < Real.cosh y ^ 2 := by positivity
  rw [one_div_lt_one_div hcy hcx]
  constructor
  · intro h
    have : Real.cosh x < Real.cosh y := by
      nlinarith [Real.one_le_cosh x, Real.one_le_cosh y]
    have := Real.cosh_lt_cosh.1 this
    rw [← sq_abs x, ← sq_abs y]; nlinarith [abs_nonneg x, abs_nonneg y, this]
  · intro h
    have hlt : |x| < |y| := by
      rw [← sq_abs x, ← sq_abs y] at h; nlinarith [abs_nonneg x, abs_nonneg y]
    have := Real.cosh_lt_cosh.2 hlt
    nlinarith [Real.one_le_cosh x, Real.one_le_cosh y]

/-- **Connector (negative region).**
`K x y < 0 ↔ y² < x²`, i.e. the region `|y| < |x|`. -/
theorem splitPhase_neg_iff (x y : ℝ) : splitPhase x y < 0 ↔ y ^ 2 < x ^ 2 := by
  have h := splitPhase_pos_iff y x
  unfold splitPhase at h ⊢
  constructor
  · intro hlt
    exact h.1 (by linarith)
  · intro hlt
    have := h.2 hlt
    linarith

/-- Algebraic reformulation: `x² = y²` iff the point lies on one of the two
diagonals `y = x` or `y = -x`. -/
theorem sq_eq_sq_iff_diagonals (x y : ℝ) : x ^ 2 = y ^ 2 ↔ (y = x ∨ y = -x) := by
  constructor
  · intro h
    have hz : (y - x) * (y + x) = 0 := by nlinarith [h]
    rcases mul_eq_zero.1 hz with h1 | h1
    · left; linarith
    · right; linarith
  · rintro (h | h) <;> subst h <;> ring

/-- **Connector (phase boundary).**  The flat "phase boundary" `K x y = 0` is
exactly the union of the two diagonal lines `y = x` and `y = -x`.  This is the
bridge in its sharpest form: the zero set of the transcendental sign field is the
pair of diagonal lines, a genuine algebraic (indeed linear) variety. -/
theorem splitPhase_boundary (x y : ℝ) : splitPhase x y = 0 ↔ (y = x ∨ y = -x) := by
  rw [splitPhase_eq_zero_iff]
  exact sq_eq_sq_iff_diagonals x y

/-- **Split duality.**  Interchanging the two coordinates negates the phase
function, so the two regions are exchanged by the diagonal reflection
`(x,y) ↦ (y,x)`. -/
theorem splitPhase_swap (x y : ℝ) : splitPhase x y = - splitPhase y x := by
  unfold splitPhase; ring

/-- The phase function is even in the first variable, reflecting the metric's
symmetry under `x ↦ -x`. -/
theorem splitPhase_neg_left (x y : ℝ) : splitPhase (-x) y = splitPhase x y := by
  unfold splitPhase sechSq; rw [Real.cosh_neg]

/-- The phase function is even in the second variable, reflecting the metric's
symmetry under `y ↦ -y`. -/
theorem splitPhase_neg_right (x y : ℝ) : splitPhase x (-y) = splitPhase x y := by
  unfold splitPhase sechSq; rw [Real.cosh_neg]

/-- The three phases partition the plane: every point is in the negative region
(`K < 0`), the positive region (`0 < K`), or on the flat boundary (`K = 0`). -/
theorem splitPhase_trichotomy (x y : ℝ) :
    splitPhase x y < 0 ∨ splitPhase x y = 0 ∨ 0 < splitPhase x y :=
  lt_trichotomy (splitPhase x y) 0

/-! ## Christoffel symbols of the split metric -/

/-- The derivative of `sechSq`: `d/dt (sech²t) = -2 sinh t / cosh³t`. -/
theorem sechSq_hasDerivAt (t : ℝ) :
    HasDerivAt sechSq (-2 * Real.sinh t / Real.cosh t ^ 3) t := by
  have hbase : HasDerivAt (fun y => Real.cosh y ^ 2) (2 * Real.cosh t * Real.sinh t) t := by
    have h := (Real.hasDerivAt_cosh t).pow 2; convert h using 1; ring
  have h := hbase.inv (by positivity)
  have hfun : sechSq = fun t => (Real.cosh t ^ 2)⁻¹ := by
    funext s; simp [sechSq, one_div]
  rw [hfun]; convert h using 1; field_simp

/-- The only nonzero partial derivative of `g_xx = sech²y` is `∂_y g_xx`. -/
theorem gxx_deriv_y (x y : ℝ) :
    deriv (fun y' => gxx x y') y = -2 * Real.sinh y / Real.cosh y ^ 3 :=
  (sechSq_hasDerivAt y).deriv

/-- The only nonzero partial derivative of `g_yy = cosh²x` is `∂_x g_yy`. -/
theorem gyy_deriv_x (x y : ℝ) :
    deriv (fun x' => gyy x' y) x = 2 * Real.cosh x * Real.sinh x := by
  have : HasDerivAt (fun x' => Real.cosh x' ^ 2) (2 * Real.cosh x * Real.sinh x) x := by
    have h := (Real.hasDerivAt_cosh x).pow 2; convert h using 1; ring
  exact this.deriv

/-- `Γ¹₁₂ = Γ¹₂₁ = (∂_y g_xx)/(2 g_xx)`. -/
noncomputable def Gamma_xxy (x y : ℝ) : ℝ := (deriv (fun y' => gxx x y') y) / (2 * gxx x y)

/-- `Γ¹₂₂ = -(∂_x g_yy)/(2 g_xx)`. -/
noncomputable def Gamma_xyy (x y : ℝ) : ℝ := - (deriv (fun x' => gyy x' y) x) / (2 * gxx x y)

/-- `Γ²₁₁ = -(∂_y g_xx)/(2 g_yy)`. -/
noncomputable def Gamma_yxx (x y : ℝ) : ℝ := - (deriv (fun y' => gxx x y') y) / (2 * gyy x y)

/-- `Γ²₁₂ = Γ²₂₁ = (∂_x g_yy)/(2 g_yy)`. -/
noncomputable def Gamma_yxy (x y : ℝ) : ℝ := (deriv (fun x' => gyy x' y) x) / (2 * gyy x y)

/-- Closed form: `Γ¹₁₂ = -tanh y`. -/
theorem Gamma_xxy_eq (x y : ℝ) : Gamma_xxy x y = - Real.tanh y := by
  unfold Gamma_xxy; rw [gxx_deriv_y]; unfold gxx sechSq
  rw [Real.tanh_eq_sinh_div_cosh]
  have hc : Real.cosh y ≠ 0 := (Real.cosh_pos y).ne'
  field_simp

/-- Closed form: `Γ²₁₂ = tanh x`. -/
theorem Gamma_yxy_eq (x y : ℝ) : Gamma_yxy x y = Real.tanh x := by
  unfold Gamma_yxy; rw [gyy_deriv_x]; unfold gyy
  rw [Real.tanh_eq_sinh_div_cosh]
  have hc : Real.cosh x ≠ 0 := (Real.cosh_pos x).ne'
  field_simp

/-- Closed form: `Γ¹₂₂ = -cosh x · sinh x · cosh²y`. -/
theorem Gamma_xyy_eq (x y : ℝ) :
    Gamma_xyy x y = - Real.cosh x * Real.sinh x * Real.cosh y ^ 2 := by
  unfold Gamma_xyy; rw [gyy_deriv_x]; unfold gxx sechSq
  have hc : Real.cosh y ≠ 0 := (Real.cosh_pos y).ne'
  field_simp

/-- Closed form: `Γ²₁₁ = sinh y / (cosh³y · cosh²x)`. -/
theorem Gamma_yxx_eq (x y : ℝ) :
    Gamma_yxx x y = Real.sinh y / (Real.cosh y ^ 3 * Real.cosh x ^ 2) := by
  unfold Gamma_yxx; rw [gxx_deriv_y]; unfold gyy
  have hcx : Real.cosh x ≠ 0 := (Real.cosh_pos x).ne'
  have hcy : Real.cosh y ≠ 0 := (Real.cosh_pos y).ne'
  field_simp

/-- `∂_x g_xx = 0`, so `Γ¹₁₁ = 0`: `g_xx` does not depend on `x`. -/
theorem Gamma_xxx_deriv_zero (x y : ℝ) : deriv (fun x' => gxx x' y) x = 0 := by
  simp [gxx]

/-- `∂_y g_yy = 0`, so `Γ²₂₂ = 0`: `g_yy` does not depend on `y`. -/
theorem Gamma_yyy_deriv_zero (x y : ℝ) : deriv (fun y' => gyy x y') y = 0 := by
  simp [gyy]

end SplitGeometry