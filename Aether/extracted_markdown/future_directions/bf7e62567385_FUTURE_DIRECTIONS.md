# FUTURE_DIRECTIONS — Information-Geometric Bridge (Cycle 2)

## Synthesis

This cycle pushed the categorical-model information-geometry program from Cycle 1
(`Speculative.AutoResearch.FisherInformationMetric`: the Fisher form
`g_p(v,w) = ∑ i, v i * w i / p i` proven to be a symmetric, bilinear,
positive-definite inner product, plus the KL sandwich
`0 ≤ KL(p‖q) ≤ g_q(p−q,p−q)`) into two of the directions it itself seeded:
the **Cramér–Rao bound** and the **f-divergence dictionary**. The new file is
`Speculative.AutoResearch.FisherCramerRao`. Every main result compiles with no
`sorry` and depends only on the standard axioms `propext`, `Classical.choice`,
`Quot.sound`.

The structural insight of the cycle is that *two apparently different inequalities
are the same Cauchy–Schwarz statement reweighted by `i ↦ · / √(p i)`*. We first
proved Cauchy–Schwarz for the Fisher form, `(g_p(v,w))² ≤ g_p(v,v)·g_p(w,w)`
(`fisherForm_cauchy_schwarz`), as a direct instance of
`Finset.sum_mul_sq_le_sq_mul_sq` applied to the reweighted vectors `v i / √(p i)`.
The very same lemma — now applied to the centred statistic `√(p i)·(T i − μ)` and
the score `w i / √(p i)` — yields the **discrete Cramér–Rao bound**
`(∑ i, T i·w i)² ≤ Var_p(T)·g_p(w,w)` (`cramerRao`, ratio form `cramerRao_div`).
The mean-zero/tangency condition `∑ w = 0` is exactly what turns the raw score
pairing into the covariance of the statistic with the score, so unbiasedness is
revealed as a geometric orthogonality bookkeeping condition rather than an analytic
one. This realises the Cycle-1 slogan "Cramér–Rao is literally Cauchy–Schwarz in
the Fisher metric" as a checked theorem.

The second thread builds the f-divergence dictionary. We defined the general
f-divergence `fDiv f p q = ∑ i, q i · f(p i / q i)` and proved that *one*
application of Jensen's inequality (`ConvexOn.map_sum_le`) gives nonnegativity for
every convex generator with `f 1 = 0` (`fDiv_nonneg`): the argument of `f` on the
Jensen side collapses to `∑ p i = 1` exactly because the weights are `q` and the
points are `p/q`. We then exhibited χ² and KL as instances
(`chiSquared_eq_fDiv`, `klDiv_eq_fDiv`) and **re-derived** their nonnegativity
(`chiSquared_nonneg_of_fDiv`, `klDiv_nonneg_of_fDiv`) from the single general
theorem — Gibbs' inequality is now a corollary of convexity of `t·log t`. Finally
`fDiv_le_fisher` upgrades Cycle 1's `klDiv_le_fisher` to the *whole family*: any
generator with a quadratic majorant `f t ≤ c(t−1)² + (t−1)` is globally bounded by
`c·g_q(p−q,p−q)`, with the linear `(t−1)` term telescoping to `∑(p−q) = 0` under
normalisation. The discovered failure mode is sharp: the global upper bound needs
the quadratic majorant and breaks for super-quadratic generators, pinpointing the
boundary between local and global information geometry.

## Results Summary

- `fisherForm_cauchy_schwarz`: proved — Cauchy–Schwarz for the Fisher inner product, the geometric engine of the cycle.
- `cramerRao`: proved — discrete Cramér–Rao bound (product form) `(∑ T·w)² ≤ Var_p(T)·g_p(w,w)`, i.e. Cauchy–Schwarz between statistic and score.
- `cramerRao_div`: proved — ratio form `Var_p(T) ≥ (∑ T·w)² / g_p(w,w)`, the textbook variance lower bound.
- `fDiv_nonneg`: proved — nonnegativity of every f-divergence with convex generator vanishing at 1, via a single Jensen step.
- `chiSquared_eq_fDiv`: proved — χ² is the f-divergence of `(t−1)²`.
- `klDiv_eq_fDiv`: proved — KL is the f-divergence of `t·log t`.
- `chiSquared_nonneg_of_fDiv`: proved — χ² ≥ 0 re-derived as an instance of the general theorem.
- `klDiv_nonneg_of_fDiv`: proved — Gibbs' inequality re-derived as an instance of the general theorem.
- `fDiv_le_fisher`: proved — global upper bound of any quadratically-majorised f-divergence by the Fisher/χ² form, generalising `klDiv_le_fisher`.
- `convexOn_sub_one_sq`: proved — supporting convexity of `(t−1)²` on `[0,∞)`.

## Research Directions

### Direction 1: Cramér–Rao equality case and efficient estimators
**Hypothesis**: Equality holds in `cramerRao`, `(∑ i, T i·w i)² = Var_p(T)·g_p(w,w)`,
if and only if the centred statistic is proportional to the score, i.e. there is a
scalar `λ` with `T i − pExp p T = λ · (w i / p i)` for all `i` (with `g_p(w,w) > 0`).
**Test**: Specialise the equality case of `Finset.sum_mul_sq_le_sq_mul_sq` (the
Cauchy–Schwarz equality criterion: the two reweighted vectors are linearly
dependent), then translate the proportionality of `√(p i)(T i−μ)` and `w i/√(p i)`
back to the stated form; prove both directions.
**Why now**: `cramerRao` is already exactly one Cauchy–Schwarz step, so the only new
ingredient is the Mathlib equality lemma for that inequality.
**If true**: A formal characterisation of *efficient* estimators (those attaining
the Cramér–Rao bound) as exactly the affine functions of the score — the geometric
content of the exponential-family efficiency theorem.
**If false**: It would reveal that the discrete (finite-support) score pairing has a
degenerate equality locus, flagging a mismatch with the smooth theory. The key
insight is that efficiency is *collinearity in the Fisher metric*, so equality must
be governed by the Cauchy–Schwarz equality case and nothing else.

### Direction 2: A reverse (lower) f-divergence bound by the Fisher form
**Hypothesis**: For generators with a quadratic *minorant* `f t ≥ c'(t−1)² + (t−1)`
on a χ²-sublevel set, the f-divergence is bounded *below* by `c'·g_q(p−q,p−q)`,
giving a two-sided `c'·χ² ≤ D_f ≤ c·χ²` clamp dual to `fDiv_le_fisher`.
**Test**: Mirror the proof of `fDiv_le_fisher` with the inequality reversed
(`Finset.sum_le_sum` the other way), and supply the minorant for `t·log t` valid on
`[0, M]` to get a lower KL bound; identify the largest interval on which the minorant
holds.
**Why now**: `fDiv_le_fisher` already isolates the exact algebraic cancellation
(`∑(p−q)=0`) that makes a quadratic ± linear bound collapse onto the χ² form; the
reverse direction reuses that bookkeeping verbatim.
**If true**: KL (and every well-behaved f-divergence) is *sandwiched on both sides*
by explicit multiples of the χ²/Fisher quadratic form on bounded-ratio regions.
**If false**: The minorant must fail near the boundary of the simplex, exposing the
unbounded-ratio singularity. The key insight is that the χ² form is the universal
second-order kernel, so f-divergences should agree with it to leading order from
*both* sides whenever ratios stay bounded.

### Direction 3: Multivariate Cramér–Rao (matrix form)
**Hypothesis**: For a vector statistic `T : ι → (Fin k → ℝ)` and a score frame
`w : Fin k → ι → ℝ`, the covariance matrix `Σ` of `T` and the Fisher information
matrix `I` with `I a b = g_p(w a, w b)` satisfy the Loewner bound `Σ ⪰ B Iᵀ⁻¹ Bᵀ`
where `B a b = ∑ i, (T i) a · (w b) i` is the sensitivity matrix.
**Test**: Reduce the matrix inequality to the scalar `cramerRao` along every
direction `u : Fin k → ℝ` (i.e. test against `uᵀ Σ u` and `uᵀ B Iᵀ⁻¹ Bᵀ u`), using
positive-definiteness of `I` from Cycle 1's `fisherForm_eq_zero_iff`.
**Why now**: the scalar bound `cramerRao` and the positive-definiteness of the
Fisher form are both already proven; the matrix statement is their bilinear assembly.
**If true**: The full matrix Cramér–Rao bound — the cornerstone of multiparameter
estimation — derived purely from the inner-product axioms.
**If false**: The obstruction is invertibility of `I` on the constrained tangent
space `∑ w = 0`, indicating a need for a Moore–Penrose pseudo-inverse formulation.
The key insight is that the matrix bound is just the scalar bound tested in every
direction, so directional reduction must suffice.

### Direction 4: `fisherForm` as a Mathlib `InnerProductSpace` instance
**Hypothesis**: For fixed positive `p`, the explicit isometry
`v ↦ (i ↦ v i / √(p i))` exhibits `(ι → ℝ, g_p)` as isometric to the standard
Euclidean space `EuclideanSpace ℝ ι`, transporting an `InnerProductSpace ℝ`
structure onto the Fisher tangent space.
**Test**: Define the linear equivalence `L p`, prove `g_p(v,w) = ⟪L p v, L p w⟫`
(this is precisely the term identity already used inside `fisherForm_cauchy_schwarz`),
and pull back the inner-product structure with `InnerProductSpace.ofCoreOfIso`-style
plumbing.
**Why now**: `fisherForm_cauchy_schwarz` proves the isometry identity term-by-term
already; only the typeclass packaging remains. The key insight is that the Fisher
metric is a *diagonal reweighting* of Euclidean space, so the isometry is literally
coordinate-wise division by `√(p i)`.
**If true**: Fisher geometry inherits Mathlib's entire inner-product API (orthogonal
projection, Gram–Schmidt, adjoints), turning Directions 1 and 3 into one-liners.
**If false**: The friction is the tangent constraint `∑ v = 0` interacting with
subtype instances, signalling a quotient/subspace construction is needed.

### Direction 5: Pythagorean / projection theorem for KL on exponential families
**Hypothesis**: With the inner-product structure of Direction 4, KL satisfies the
information-geometric Pythagorean identity `KL(p‖r) = KL(p‖q) + KL(q‖r)` to second
order whenever `q` is the `g`-orthogonal projection of `p` onto the affine family
through `r`, i.e. the displacement `p−q` is `g_q`-orthogonal to `q−r`.
**Test**: Expand all three KL terms with the second-order law `KL ≈ ½ g` (provable
from `klDiv_le_fisher` plus a matching lower bound from Direction 2) and reduce the
cross term to `g_q(p−q, q−r) = 0`, the orthogonality hypothesis.
**Why now**: Direction 2 supplies the two-sided `KL ≈ χ²` control and Direction 4
supplies orthogonality; together they make the cross term vanish. The key insight is
that the Pythagorean theorem of information geometry is the *literal* Pythagorean
theorem in the Fisher inner product.
**If true**: A formal foundation for the `em`-algorithm and maximum-entropy
projections, the operational heart of applied information geometry.
**If false**: The second-order remainder does not vanish, quantifying the failure of
flatness (nonzero α-connection curvature) of the categorical model — itself a
measurable geometric invariant.
