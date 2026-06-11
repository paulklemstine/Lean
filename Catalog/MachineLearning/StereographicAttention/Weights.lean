/-
Copyright (c) 2026 Stereographic Neural Attention Research Team. All rights reserved.
Released under Apache 2.0 license.

# Stereographic Neural Attention — Weights: the Cauchy kernel defines a probability law

This file extends `Catalog/MachineLearning/StereographicAttention/Core.lean`, where the
**Cauchy kernel** `K(q,k) = 1/(1 + ‖q - k‖²)` was shown to be the conformal factor of
stereographic projection (`stereo_chordal_eq_kernel`), strictly positive
(`cauchyKernel_pos`), bounded by `1` (`cauchyKernel_le_one`), and saturating exactly on
the diagonal (`cauchyKernel_eq_one_iff`).

Here we promote the kernel to a full **attention mechanism**: given a query `q` and a
family of keys `k_i`, the normalized scores

  `w_i(q) = K(q, k_i) / ∑_j K(q, k_j)`

form a genuine probability distribution (positive, summing to one), and the attention
output `∑_i w_i • v_i` is a *convex combination* of the values, hence norm-bounded by the
largest value norm.  This is the geometric analogue of the softmax simplex: stereographic
attention lands on the probability simplex just like softmax, but via sphere geometry
rather than exponentiation.

## Main results

* `cauchyKernel_symm`             — the score is symmetric, `K(q,k) = K(k,q)`.
* `cauchyKernel_translation`      — the score is translation invariant.
* `cauchyKernel_antitone`         — the score decreases as the key moves away from the query.
* `attnDenom_pos`                 — the normalizing constant is strictly positive.
* `attnWeight_pos`                — every attention weight is strictly positive.
* `attnWeight_sum_one`            — the weights sum to one (a probability distribution).
* `attnOutput_norm_le`            — the output is a convex combination, hence bounded.
* `attnWeight_eq_uniform_of_const`— equidistant keys yield the uniform distribution.
-/

import Mathlib
import MachineLearning.StereographicAttention.Core

open scoped BigOperators

namespace StereographicAttention

variable {E : Type*} [NormedAddCommGroup E] [NormedSpace ℝ E]

-- !-- The Cauchy score is symmetric: ‖q-k‖ = ‖k-q‖, so the denominators agree. -- !--
omit [NormedSpace ℝ E] in
theorem cauchyKernel_symm (q k : E) : cauchyKernel q k = cauchyKernel k q := by
  unfold cauchyKernel; rw [norm_sub_rev]

-- !-- Translation invariance: (q+v)-(k+v) = q-k, so the kernel only sees relative position. -- !--
omit [NormedSpace ℝ E] in
theorem cauchyKernel_translation (q k v : E) :
    cauchyKernel (q + v) (k + v) = cauchyKernel q k := by
  unfold cauchyKernel; rw [add_sub_add_right_eq_sub]

-- !-- Antitone in distance: farther keys score lower, since x ↦ 1/(1+x²) is decreasing on x≥0. -- !--
omit [NormedSpace ℝ E] in
theorem cauchyKernel_antitone {q k₁ k₂ : E} (h : ‖q - k₁‖ ≤ ‖q - k₂‖) :
    cauchyKernel q k₂ ≤ cauchyKernel q k₁ := by
  exact one_div_le_one_div_of_le ( by positivity ) ( by nlinarith [ norm_nonneg ( q - k₁ ), norm_nonneg ( q - k₂ ) ] )

variable {ι : Type*} [Fintype ι] [Nonempty ι]

/-- The normalizing constant `∑_j K(q, k_j)` of stereographic attention. -/
noncomputable def attnDenom (q : E) (ks : ι → E) : ℝ := ∑ j, cauchyKernel q (ks j)

-- !-- A sum of strictly positive Cauchy scores over a nonempty index set is positive. -- !--
omit [NormedSpace ℝ E] in
theorem attnDenom_pos (q : E) (ks : ι → E) : 0 < attnDenom q ks := by
  exact Finset.sum_pos ( fun _ _ => by exact one_div_pos.mpr ( by positivity ) ) Finset.univ_nonempty

/-- The stereographic **attention weight** of key `i`:
`w_i(q) = K(q, k_i) / ∑_j K(q, k_j)`. -/
noncomputable def attnWeight (q : E) (ks : ι → E) (i : ι) : ℝ :=
  cauchyKernel q (ks i) / attnDenom q ks

-- !-- Each weight is a positive number divided by a positive denominator. -- !--
omit [NormedSpace ℝ E] in
theorem attnWeight_pos (q : E) (ks : ι → E) (i : ι) : 0 < attnWeight q ks i := by
  exact div_pos ( cauchyKernel_pos q ( ks i ) ) ( Finset.sum_pos ( fun j _ => cauchyKernel_pos q ( ks j ) ) Finset.univ_nonempty )

-- !-- The weights sum to one: ∑ K(q,k_i) / D = D / D = 1, a point of the simplex. -- !--
omit [NormedSpace ℝ E] in
theorem attnWeight_sum_one (q : E) (ks : ι → E) : ∑ i, attnWeight q ks i = 1 := by
  have h_sum : ∑ i, (cauchyKernel q (ks i)) / (∑ j, (cauchyKernel q (ks j))) = 1 := by
    rw [ ← Finset.sum_div, div_self ] ; exact ne_of_gt <| Finset.sum_pos ( fun _ _ => by exact ( by exact ( by exact ( by exact ( by exact ( by exact ( by exact by unfold cauchyKernel; positivity ) ) ) ) ) ) ) Finset.univ_nonempty;
  exact h_sum

/-- The stereographic **attention output**: the weighted barycenter `∑_i w_i • v_i`. -/
noncomputable def attnOutput (q : E) (ks vs : ι → E) : E :=
  ∑ i, attnWeight q ks i • vs i

-- !-- Convexity bound: the output is a convex combination of values, so its norm is at most C. -- !--
theorem attnOutput_norm_le (q : E) (ks vs : ι → E) (C : ℝ) (hC : ∀ i, ‖vs i‖ ≤ C) :
    ‖attnOutput q ks vs‖ ≤ C := by
  refine' le_trans ( norm_sum_le _ _ ) _;
  refine' le_trans ( Finset.sum_le_sum fun i _ => _ ) _;
  use fun i => attnWeight q ks i * C;
  · rw [ norm_smul, Real.norm_of_nonneg ( le_of_lt ( attnWeight_pos q ks i ) ) ] ; exact mul_le_mul_of_nonneg_left ( hC i ) ( le_of_lt ( attnWeight_pos q ks i ) );
  · rw [ ← Finset.sum_mul _ _ _, attnWeight_sum_one, one_mul ]

-- !-- When all keys are equidistant from q, the kernel is constant and attention is uniform. -- !--
omit [NormedSpace ℝ E] [Nonempty ι] in
theorem attnWeight_eq_uniform_of_const (q : E) (ks : ι → E) (r : ℝ)
    (hr : ∀ i, ‖q - ks i‖ = r) (i : ι) :
    attnWeight q ks i = 1 / (Fintype.card ι : ℝ) := by
  unfold attnWeight;
  unfold cauchyKernel attnDenom;
  simp +decide only [div_div, cauchyKernel];
  simp +decide [ hr ];
  rw [ mul_right_comm, mul_inv_cancel₀ ( by positivity ), one_mul ]

/-- **Showcase.** Stereographic attention over any nonempty finite key set is a genuine
probability law: positive weights summing to one, with output a norm-bounded barycenter. -/
example (q : E) (ks vs : Fin 3 → E) :
    (∀ i, 0 < attnWeight q ks i) ∧
    (∑ i, attnWeight q ks i = 1) ∧
    (∀ C, (∀ i, ‖vs i‖ ≤ C) → ‖attnOutput q ks vs‖ ≤ C) :=
  ⟨attnWeight_pos q ks, attnWeight_sum_one q ks, fun C hC => attnOutput_norm_le q ks vs C hC⟩

end StereographicAttention