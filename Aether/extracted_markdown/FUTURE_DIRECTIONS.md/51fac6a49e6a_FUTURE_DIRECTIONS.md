# Future Directions: Perturbation-Stable Generalization Bounds

The file `Catalog/MachineLearning/PerturbedGeneralization.lean` isolates a single
algebraic fact — the Occam/MDL bound

```
occamBound R C n δ = R + sqrt ((C + log (1/δ)) / (2 n))
```

is an *exact translation* in its empirical-risk coordinate (`occamBound_translate`,
`occamBound_sub_eq`), hence an isometry (`occamBound_dist_eq`). From this we
derive a Lipschitz-transfer principle: any stability property of empirical risk
passes verbatim, with the same constant, to the certified generalization
guarantee (`lipschitz_bound_transfer`, `arch_perturbed_bound`,
`occamBound_chain_bound`, `perturbed_sample_complexity`), an exact ensemble
identity with no Jensen gap (`occamBound_ensemble_avg`), and a tightness witness
(`perturbed_bound_tight`). The concrete pseudometric `archDistReal` shows the
abstract theory is non-vacuous. The directions below push that bridge further.

## 1. From pseudometric to bona-fide isometric pushforward of metric spaces

**Conjecture.** Fix complexity `C`, sample size `n`, confidence `δ`. The map
`Φ : ℝ → ℝ`, `Φ R = occamBound R C n δ`, is a surjective isometry of `(ℝ, |·|)`,
and therefore the pushforward of any architecture pseudometric `(A, d)` under
`emp` composed with `Φ` is again a pseudometric whose induced uniformity equals
that of `d` scaled by the Lipschitz constant `L`.

The key insight is that `occamBound_dist_eq` already proves `Φ` preserves all
pairwise distances; promoting this from a pointwise identity to a
`Isometry`-class instance (in Mathlib's `Isometry`/`PseudoMetricSpace` API) makes
the entire downstream metric machinery — completions, Lipschitz extension,
Arzelà–Ascoli — available to certified guarantees for free.

**Why now?** The pointwise isometry is formalized; the only remaining work is to
package `Φ` as a Mathlib `Isometry` and transport `archDistReal` along it,
turning ad-hoc bound inequalities into structural statements about a metric
morphism `(A, L·d) → (guarantees, |·|)`.

## 2. Strict separation: nonlinear capacity measures must incur a Jensen gap

**Conjecture.** Replace the affine penalty by any strictly convex capacity
`cap : ℝ → ℝ` and define `bound' R = R + cap R`. Then for an ensemble with at
least two distinct empirical risks the averaged-model bound is *strictly smaller*
than the average of the bounds: `bound' (avg R) < avg (bound' ∘ R)`, with the gap
equal to the Bregman divergence of `cap` averaged over the ensemble.

The key insight is that `occamBound_ensemble_avg` is exactly the boundary case
`cap` constant (zero curvature); any positive curvature converts the equality
into Jensen's inequality, and the size of the violation is a quantitative,
falsifiable measure of how far a capacity measure is from being
compression-based.

**Why now?** The equality case is proven, so the contrast theorem only needs
Mathlib's `inner_le_nnorm` / `StrictConvexOn` and `Finset.inner_le_sum` style
Jensen lemmas; it would give the first formal statement that *only* MDL-type
penalties admit exact ensemble identities.

## 3. Cumulative-budget neural-architecture search with a certified envelope

**Conjecture.** Along a search path `a₀ → a₁ → ⋯ → a_k` of single edits, the
certified bound satisfies the telescoped envelope
`occamBound (emp a_k) C n δ ≤ occamBound (emp a₀) C n δ + L · ∑_{i<k} d(aᵢ, aᵢ₊₁)`,
and this envelope is the *tightest* path-monotone certificate: there is an
empirical risk realizing equality at every node simultaneously.

The key insight is that `occamBound_chain_bound` is the two-edit instance of a
`List.foldr` over the triangle inequality; iterating it gives a path functional
that is subadditive, and the `perturbed_bound_tight` witness extends to a whole
path because `emp x = L · archDistReal a₀ x` saturates every edge at once on the
total-width pseudometric.

**Why now?** Both the single-edit bound and the tightness witness are formalized;
chaining them through `List.foldr`/`Finset.sum` over a path is a direct induction
and would yield the first end-to-end certified-stability guarantee for an entire
architecture-search trajectory rather than a single step.

## 4. The δ ↔ ε ↔ η ↔ n exchange surface is separable and downward-closed

**Conjecture.** Fix a certified target `emp a + τ`. The set of admissible budgets
`{(δ, ε, η, n) : ε + η ≤ τ ∧ (C + log(1/δ))/(2 ε²) ≤ n}` is downward-closed in
`(η, n)` and upward-closed in `(ε, δ⁻¹)`, and its Pareto frontier factorizes as
the product of a pure data constraint `n = (C + log(1/δ))/(2 ε²)` and a pure
robustness constraint `ε + η = τ`, with no cross term.

The key insight is that in `perturbed_sample_complexity` the data budget enters
*only* through `ε` (via `occam_sample_complexity`) and the perturbation budget
*only* through `η` (via the additive `occamBound_sub_eq` translation); the two
channels never multiply, so the admissible region is a Cartesian product and its
frontier is a graph, not a curved trade-off.

**Why now?** All inequalities bounding the region are already theorems; proving
separability is a monotonicity argument in each coordinate, and it would give the
first formal data-vs-robustness exchange theorem with an explicit, differentiable
frontier suitable for budget allocation.

## 5. PAC-Bayes lift: isometry survives passage to posteriors

**Conjecture.** Replace the point hypothesis by a posterior `Q`, the empirical
risk `R` by the expectation `𝔼_{h∼Q}[R(h)]`, and the complexity `C` by the KL
divergence `KL(Q ‖ P)`. The resulting PAC-Bayes Occam bound is *still* a
translation in the expected-risk coordinate, so `lipschitz_bound_transfer` and
`perturbed_sample_complexity` lift verbatim with `archDistReal` replaced by a
Wasserstein/total-variation distance between posteriors.

The key insight is that expectation is linear, so `𝔼_Q[R]` enters the PAC-Bayes
bound through exactly the same affine-translation slot that powers
`occamBound_translate`; the KL term plays the role of the constant penalty and
never touches the risk coordinate, preserving the isometry argument unchanged.

**Why now?** The catalog already contains PAC-Bayes scaffolding (the
`MachineLearning.PACBayes` directory and Catoni-style bounds); composing it with
the isometry lemmas in this file is the natural next step and would unify
compression, perturbation, and PAC-Bayes generalization under one
Lipschitz-transfer principle.
