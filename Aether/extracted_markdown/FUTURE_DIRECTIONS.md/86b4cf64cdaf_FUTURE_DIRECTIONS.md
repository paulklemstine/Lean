# Future Directions — Stereographic Neural Attention

## Synthesis

This cycle extended the geometric core of *stereographic attention*
(`StereographicAttention.Core`: the Cauchy score `K(q,k) = 1/(1+‖q-k‖²)` is the
conformal factor of stereographic projection onto the Riemann sphere) into its
**sparsity theory** (`StereographicAttention.Sparsity`). The headline finding is a
sharp dichotomy:

1. **The literal conjecture is false.** On the unit sphere, where queries and keys are
   forced to live in the original concept, `‖q-k‖² ≤ 4`, so every Cauchy score is
   `≥ 1/5` (`cauchyKernel_unitSphere_ge_fifth`). The mechanism has *no* sparsity there —
   it is maximally dense. The sphere's bounded diameter caps the decay of the kernel.

2. **Sparsity is recovered, exactly, by temperature.** Introducing the tempered kernel
   `Kβ(q,k) = 1/(1+β‖q-k‖²)`, the active set `{k : Kβ(q,k) ≥ τ}` is *precisely* a metric
   ball of squared radius `(1/τ - 1)/β` (`cauchyKernelT_ge_iff_ball`), shrinking like
   `1/β`. Temperature is a monotone sparsification dial (`cauchyKernelT_antitone_temp`).

3. **The `O(√N)` bound is now a two-factor theorem.** A Markov counting inequality
   (`markov_sparsity`: `τ · #active ≤ ∑ K`) is exact and unconditional; combined with a
   geometric *mass* bound `∑ K ≤ √N`, it yields `#active ≤ √N/τ` (`sqrt_sparsity`). The
   `√N` exponent therefore lives entirely in the data-spread hypothesis, cleanly isolated
   from the (now-proved) combinatorial half.

## Results Summary

| Theorem | Statement | Status |
|---|---|---|
| `cauchyKernel_unitSphere_ge_fifth` | unit-sphere scores `≥ 1/5` | proved |
| `cauchyKernelT_ge_iff_ball` | thresholding `=` metric ball, radius² `(1/τ-1)/β` | proved |
| `cauchyKernelT_antitone_temp` | hotter temperature lowers all scores | proved |
| `markov_sparsity` | `τ·#active ≤ ∑ K` | proved |
| `sqrt_sparsity` | `∑K ≤ √N ⇒ #active ≤ √N/τ` | proved |

All proofs are `sorry`-free and depend only on `propext`, `Classical.choice`, `Quot.sound`.

---

## Direction 1 — The geometric mass bound: `∑ K ≤ √N` for δ-separated keys

**Conjecture.** Let `k₁,…,k_N ∈ ℝ^d` be pairwise `δ`-separated (`‖kᵢ-kⱼ‖ ≥ δ`) and let
`β = β(N)` scale so that balls of radius `~1/√β` hold `O(1)` keys. Then for every query
`q`, `∑ᵢ Kβ(q,kᵢ) ≤ C_d · √N`. Feeding this into `sqrt_sparsity` upgrades the conditional
bound to an *unconditional* `O(√N)` active-set theorem.

The key insight is that a δ-separated packing makes the number of keys at squared
distance in the annulus `[r², (r+δ)²]` grow only polynomially in `r/δ`, so the Cauchy
tail `1/(1+βr²)` is summable against a packing measure; the `√N` is the crossover radius
where the linear "ball count" term and the quadratic "tail decay" term balance.

**Why now?** `markov_sparsity` and `cauchyKernelT_ge_iff_ball` already reduce the entire
problem to bounding one scalar sum `∑ K`; the metric-ball characterization turns the
analytic estimate into a clean packing/covering count, for which Mathlib now has
`Metric.exists_finset_... ` packing infrastructure. The hard combinatorics is done.

**Falsifiable test.** If a δ-separated configuration with `∑ K ≫ √N` exists for the
balanced `β`, the conjecture (and the headline sparsity claim) is dead.

## Direction 2 — Expected sparsity for random keys on the sphere

**Conjecture.** If keys are i.i.d. uniform on the unit sphere `S^{d-1}` and `β` is fixed,
then `E_q[ #{i : Kβ(q,kᵢ) ≥ τ} ] = N · P(‖q-k‖² ≤ (1/τ-1)/β)`, and this probability
decays like `((1/τ-1)/β)^{(d-1)/2}` as `β → ∞`. Choosing `β ∝ N^{2/(d-1)}` yields an
expected active count of `Θ(√N)` for the threshold `τ = 1/2`.

The key insight is that `cauchyKernelT_ge_iff_ball` converts the *random* event
`{Kβ ≥ τ}` into the *geometric* event `{key falls in a spherical cap}`, whose measure is
an incomplete-beta cap area — exactly computable, so the expectation factorizes by
linearity over the `N` keys.

**Why now?** The exact ball/cap identity is in hand, and Mathlib's measure theory on the
sphere (`MeasureTheory`, surface measure via `EuclideanSpace`) suffices to state and
bound cap volumes. This turns a vague "random sparsity" claim into a precise expectation.

**Falsifiable test.** Simulate uniform keys; if the empirical active count under
`β ∝ N^{2/(d-1)}` does not track `√N`, the scaling law is wrong.

## Direction 3 — Universal approximation despite sparsity

**Conjecture.** Tempered stereographic attention with a learned temperature is a
universal approximator of continuous sequence-to-sequence maps on compacts: for any
continuous `F` and `ε > 0` there exist keys, values, and `β` such that the stereographic
attention layer is within `ε` of `F` in sup norm — *and* the per-query active set has
size `O(√N)`.

The key insight is that the Cauchy kernel is strictly positive-definite (it is a
reciprocal-quadratic, hence a scale mixture of Gaussians by the subordination
`1/(1+βr²) = ∫₀^∞ e^{-t(1+βr²)} dt`), so its RKHS is dense in `C(K)`; sparsity from
Direction 1 then says the dense approximation only ever needs `O(√N)` active terms.

**Why now?** The scale-mixture identity bridges this file's Cauchy kernel directly to the
Gaussian-kernel universality already formalizable in Mathlib, letting one *inherit*
universality instead of reproving it, while `sqrt_sparsity` controls the cost.

**Falsifiable test.** Exhibit a continuous target that provably cannot be `ε`-approximated
by any sparse Cauchy-kernel combination — this would break universality-with-sparsity.

## Direction 4 — Conformal invariance of the attention pattern

**Conjecture.** Möbius transformations of the Riemann sphere act on queries/keys by
conformal maps under which the *ranking* induced by `Kβ` (which keys are nearest a query)
is invariant, even though the scores themselves change. Hence stereographic attention has
a built-in `PSL(2,·)` symmetry group absent from softmax.

The key insight is that `Core.stereo_chordal_eq_kernel` already identifies the kernel with
chordal distance on the sphere; chordal distance is conformally covariant under Möbius
maps, so the argmax/top-k structure of attention is a Möbius invariant.

**Why now?** `Core` supplies the exact chordal-distance identity, and Mathlib's complex
analysis has the Möbius/`PSL(2,ℂ)` action; combining them makes "attention as conformal
geometry" a provable statement rather than an analogy.

**Falsifiable test.** Apply a random Möbius map to a key set; if the induced top-k
attention pattern changes, conformal invariance fails.

## Direction 5 — Sparsity–accuracy Pareto frontier via the threshold τ

**Conjecture.** There is an explicit trade-off curve: truncating stereographic attention
to its `{Kβ ≥ τ}` active set incurs an output error bounded by the discarded mass
`∑_{Kβ<τ} Kβ`, which by `markov_sparsity` applied to the complement is `≤ (N - #active)·τ`.
Optimizing over `τ` gives a closed-form Pareto frontier between active-set size and
approximation error.

The key insight is that the *same* Markov inequality that upper-bounds the active count
also upper-bounds the **discarded** mass (each inactive score is `< τ`), so one inequality
controls both axes of the sparsity/accuracy trade-off simultaneously.

**Why now?** `markov_sparsity` is already proved and is symmetric in "active vs inactive";
formalizing the error bound is a short corollary, turning a heuristic engineering
trade-off into a theorem with an explicit optimal `τ`.

**Falsifiable test.** Measure error vs active-set size while sweeping `τ`; deviation of the
empirical frontier from the predicted closed form refutes the bound's tightness.
