# Future Directions — Stereographic Neural Attention

The `StereographicAttention` development now rests on three layers. `Core.lean` identifies
the Cauchy score `K(q,k) = 1/(1+‖q-k‖²)` with the conformal factor of stereographic
projection (`stereo_chordal_eq_kernel`, `stereo_on_sphere`) and pins down its range
(`cauchyKernel_pos`, `cauchyKernel_le_one`, `cauchyKernel_eq_one_iff`). `Weights.lean`
promotes it to a probability law on keys (`attnWeight_sum_one`, `attnOutput_norm_le`).
`Sparsity.lean` (this cycle) proves the sparsity backbone: heaviness is *ball membership*
(`cauchyKernel_ge_iff`), heavy keys are *Markov-rare* (`card_heavy_weights_le`:
`#{i : τ ≤ wᵢ} ≤ ⌊1/τ⌋`), and the *participation ratio* `1/∑wᵢ²` is pinched in `[1, N]`
(`participation_ratio_mem_Icc`). These results are dimension-free; the conjectures below
push toward the geometric, dimension-*dependent* `O(√N)` regime that motivated the concept.

The following directions are stated as concrete, falsifiable Lean targets.

## 1. Packing sparsity: the active set is a spherical cap of bounded cardinality

In a `d`-dimensional inner-product space, if the keys are `δ`-separated
(`‖kᵢ - kⱼ‖ ≥ δ` for `i ≠ j`) then for every query `q` the number of `τ`-heavy keys is
bounded by a packing number of the ball of squared radius `(1-τ)/τ`, hence
`#heavyKeys ≤ (1 + 2√((1-τ)/τ)/δ)^d`, **independent of the total key count `N`**. This is the
honest geometric upgrade of the Markov bound `⌊1/τ⌋` proved in `card_heavy_weights_le`.

The key insight is that `cauchyKernel_ge_iff` already turns "heavy" into "lies in a metric
ball", so sparsity reduces to a *pure packing estimate* — counting `δ`-separated points in a
ball — with the kernel completely eliminated from the problem. Why now? `cauchyKernel_ge_iff`
makes the reduction a one-line rewrite, and Mathlib's `Metric.ball`, `Finset` packing, and
volume API (`MeasureTheory.measure_ball`) are mature enough to carry the counting argument.

## 2. `√N` sparsity for keys on the unit sphere via the second moment

For keys sampled `δ`-separated on the unit sphere `Sᵈ⁻¹` with `q` also on the sphere,
conjecture that the participation ratio obeys `1/∑wᵢ² = O(√N)` once `N ≍ δ^{-(d-1)}` keys
saturate the sphere — i.e. the effective active set grows like `√N`, strictly between the
one-hot (`1`) and uniform (`N`) walls established in `participation_ratio_mem_Icc`.

The key insight is that on the sphere `‖q-kᵢ‖² = 2 - 2⟨q,kᵢ⟩`, so `∑wᵢ²` is governed by the
*empirical inner-product distribution*, and a lower bound `∑wᵢ² ≥ c/√N` is exactly a
concentration statement for that distribution. Why now? The two walls `1/N ≤ ∑wᵢ² ≤ 1`
(`sum_sq_weight_ge_inv_card`, `sum_sq_weight_le_one`) are already proved, so only the
*middle* estimate remains, and it is a self-contained second-moment inequality.

## 3. Lipschitz stability of the stereographic attention output

Conjecture that `attnOutput` is Lipschitz in the query: there is `L(N, {kᵢ})` with
`‖attnOutput q ks vs - attnOutput q' ks vs‖ ≤ L · ‖q - q'‖`, and that `L` *shrinks* in the
sparse regime (small participation ratio) because only the active keys can move mass.

The key insight is that `K` is smooth with `‖∇_q K(q,k)‖ ≤ 1` (its derivative is the
bounded map `q ↦ -2(q-k)/(1+‖q-k‖²)²`), so the weight map inherits a Lipschitz constant
controlled by the *spread* of the kernel, which the participation ratio quantifies. Why now?
`attnOutput_norm_le` already shows the output is a contraction onto the convex hull of values;
upgrading "bounded" to "Lipschitz" is the natural next step and unlocks robustness guarantees.

## 4. Universal approximation: stereographic attention is dense in softmax attention

Conjecture that finite stereographic-attention layers approximate any softmax-attention map
uniformly on compacts: for every continuous target and `ε > 0`, a temperature-scaled kernel
family `K_β(q,k) = 1/(1+β‖q-k‖²)` and a key/value set realize the target to within `ε`.

The key insight is that as `β → ∞` the normalized Cauchy weights converge to a hard
nearest-key indicator (a consequence sharpened from `cauchyKernel_eq_one_iff` and
`cauchyKernel_antitone`), so stereographic attention contains the same "soft `argmax`"
primitive that makes softmax a universal approximator. Why now? The diagonal-saturation and
antitonicity lemmas are in place, so the `β → ∞` limit is a clean monotone-convergence
argument rather than a from-scratch analysis.

## 5. Entropy–sparsity duality on the attention simplex

Conjecture a two-sided bound linking Shannon entropy `H(w) = -∑ wᵢ log wᵢ` of the attention
distribution to the participation ratio: `log(1/∑wᵢ²) ≤ H(w) ≤ log N`, with the lower (Rényi)
side tight exactly in the sparse regime, giving an information-theoretic certificate that
"few keys are active".

The key insight is that `∑wᵢ² = exp(-H₂(w))` is the Rényi-2 entropy, so the inequality
`H₂ ≤ H₁ ≤ log N` is the monotonicity of Rényi entropies specialized to the simplex point we
already control via `sum_sq_weight_ge_inv_card` / `sum_sq_weight_le_one`. Why now? Both
squared-mass walls are proved, so the entropy bound is a direct application of Jensen /
Rényi monotonicity to an object whose extremes are already pinned down.
