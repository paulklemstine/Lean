/-
Copyright (c) 2026 Stereographic Neural Attention Research Team. All rights reserved.
Released under Apache 2.0 license.

# Stereographic Neural Attention — Core: the Cauchy kernel and the Riemann sphere

This file develops the geometric core of *stereographic attention*, a proposed
alternative to softmax attention.  Instead of exponentiating dot products, one
scores a query `q` against a key `k` with the **Cauchy kernel**

  `K(q, k) = 1 / (1 + ‖q - k‖²)`.

This is precisely the conformal factor of stereographic projection: lifting a
vector `x` to the unit sphere via stereographic projection `σ`, the kernel
`K(x, 0)` equals one quarter of the squared chordal distance from `σ(x)` to the
north pole.  The kernel is therefore an intrinsically *geometric* score, bounded
in `(0, 1]`, with a built-in notion of "closeness on the sphere".

## Main results

* `cauchyKernel_pos`        — the score is strictly positive.
* `cauchyKernel_le_one`     — the score is at most `1`.
* `cauchyKernel_eq_one_iff` — the score saturates exactly on the diagonal `q = k`.
* `stereo_on_sphere`        — `σ` lands on the unit sphere (it is well-typed).
* `stereo_chordal_eq_kernel`— the chordal-distance / Cauchy-kernel identity.

This is a cross-domain bridge in the spirit of `Catalog/MachineLearning/Attention.lean`
(attention as a natural transformation): there attention is studied *algebraically*
as a matrix commuting with morphisms; here attention is studied *geometrically* as a
conformal kernel on the Riemann sphere.

-- !-- Lab Notebook: StereographicAttention.Core -- !--
-- !-- Hypothesis: the Cauchy score 1/(1+‖q-k‖²) is the conformal factor of the   -- !--
-- !--   stereographic projection, hence inherits the geometry of the Riemann sphere. -- !--
-- !-- Result: confirmed. The score is in (0,1], saturates iff q=k, and equals      -- !--
-- !--   (1/4)·‖σ(x)-N‖², the squared chordal distance to the north pole.           -- !--
-- !-- Insight: writing everything in t := ‖x‖² collapses the sphere identities to  -- !--
-- !--   the single algebraic fact (t+1)² = 4t + (t-1)², after norm_smul.           -- !--
-- !-- Failure analysis: the product E × ℝ has the *sup* norm in Mathlib, not L²,   -- !--
-- !--   so we encode σ by its two real-algebraic components rather than as a point -- !--
-- !--   of a normed product, sidestepping a wrong-norm trap.                       -- !--
-- !-- End Lab Notebook -- !--
-/

import Mathlib

open scoped BigOperators

namespace StereographicAttention

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

/-- The **Cauchy attention kernel** scoring a query `q` against a key `k`:
`K(q,k) = 1 / (1 + ‖q - k‖²)`.  This replaces `exp(⟨q,k⟩)` of softmax attention. -/
noncomputable def cauchyKernel (q k : E) : ℝ := 1 / (1 + ‖q - k‖ ^ 2)

/-- The Euclidean component of the stereographic projection `σ : E → E × ℝ`,
`σ(x) = (2/(1+‖x‖²) • x, (‖x‖²-1)/(‖x‖²+1))`.  This is the part living in `E`. -/
noncomputable def stereoProj (x : E) : E := (2 / (1 + ‖x‖ ^ 2)) • x

/-- The "height" (last, real) coordinate of the stereographic image of `x`. -/
noncomputable def stereoHeight (x : E) : ℝ := (‖x‖ ^ 2 - 1) / (‖x‖ ^ 2 + 1)

-- !-- Cauchy scores are strictly positive: the denominator 1+‖q-k‖² is ≥ 1 > 0. -- !--
omit [NormedSpace ℝ E] in
theorem cauchyKernel_pos (q k : E) : 0 < cauchyKernel q k := by
  unfold cauchyKernel; positivity

-- !-- Cauchy scores never exceed 1: equivalent to 1 ≤ 1+‖q-k‖² since ‖q-k‖² ≥ 0. -- !--
omit [NormedSpace ℝ E] in
theorem cauchyKernel_le_one (q k : E) : cauchyKernel q k ≤ 1 := by
  unfold cauchyKernel
  rw [div_le_one (by positivity)]
  nlinarith [sq_nonneg ‖q - k‖]

-- !-- Lab Notebook: cauchyKernel_eq_one_iff -- !--
-- !-- Hypothesis: a key receives maximal attention iff it equals the query.       -- !--
-- !-- Result: proved. K=1 forces ‖q-k‖²=0, hence q=k via norm_sub_eq_zero_iff.    -- !--
-- !-- Insight: this is the geometric meaning of "self-attention": the diagonal is -- !--
-- !--   the unique global maximum of the score, unlike softmax which only peaks    -- !--
-- !--   relatively.                                                                -- !--
-- !-- End Lab Notebook -- !--
-- !-- The score saturates at 1 exactly on the diagonal q=k. -- !--
omit [NormedSpace ℝ E] in
theorem cauchyKernel_eq_one_iff (q k : E) : cauchyKernel q k = 1 ↔ q = k := by
  unfold cauchyKernel
  rw [div_eq_one_iff_eq (by positivity)]
  constructor
  · intro h
    have hsq : ‖q - k‖ ^ 2 = 0 := by linarith
    have hz : ‖q - k‖ = 0 := by nlinarith [norm_nonneg (q - k)]
    rwa [norm_sub_eq_zero_iff] at hz
  · intro h; subst h; simp

-- !-- Lab Notebook: stereo_on_sphere -- !--
-- !-- Hypothesis: σ is well-typed, i.e. it really lands on the unit sphere of E×ℝ. -- !--
-- !-- Result: proved. With t=‖x‖², 4t/(1+t)² + (t-1)²/(t+1)² = (t+1)²/(t+1)² = 1.  -- !--
-- !-- Insight: this is what makes "project to the Riemann sphere" meaningful;      -- !--
-- !--   the kernel below is a genuine distance on this sphere.                      -- !--
-- !-- End Lab Notebook -- !--
-- !-- The stereographic image lands on the unit sphere: ‖σ(x)‖²-part + height² = 1. -- !--
theorem stereo_on_sphere (x : E) :
    ‖stereoProj x‖ ^ 2 + (stereoHeight x) ^ 2 = 1 := by
  unfold stereoProj stereoHeight
  rw [norm_smul]
  have h1 : (1 + ‖x‖ ^ 2) ≠ 0 := by positivity
  rw [Real.norm_eq_abs, abs_of_pos (by positivity : (0:ℝ) < 2 / (1 + ‖x‖ ^ 2))]
  field_simp
  ring

-- !-- Lab Notebook: stereo_chordal_eq_kernel -- !--
-- !-- Hypothesis: the Cauchy kernel IS (a quarter of) chordal distance on the sphere. -- !--
-- !-- Result: proved. ‖σ(x)-N‖² = 4t/(1+t)²+4/(1+t)² = 4/(1+t) = 4·K(x,0).         -- !--
-- !-- Insight: this is the conceptual payload of the whole concept — stereographic  -- !--
-- !--   attention is softmax's geometric sibling, scoring by sphere distance.       -- !--
-- !-- Failure analysis: must rewrite ‖c • x‖ via norm_smul and discharge |c|=c by   -- !--
-- !--   positivity before field_simp/ring can close the algebraic identity.         -- !--
-- !-- End Lab Notebook -- !--
-- !-- The squared chordal distance from σ(x) to the north pole N=(0,1) is 4·K(x,0). -- !--
theorem stereo_chordal_eq_kernel (x : E) :
    ‖stereoProj x‖ ^ 2 + (stereoHeight x - 1) ^ 2 = 4 * cauchyKernel x 0 := by
  unfold stereoProj stereoHeight cauchyKernel
  rw [norm_smul, sub_zero]
  have h1 : (1 + ‖x‖ ^ 2) ≠ 0 := by positivity
  rw [Real.norm_eq_abs, abs_of_pos (by positivity : (0:ℝ) < 2 / (1 + ‖x‖ ^ 2))]
  field_simp
  ring

end StereographicAttention