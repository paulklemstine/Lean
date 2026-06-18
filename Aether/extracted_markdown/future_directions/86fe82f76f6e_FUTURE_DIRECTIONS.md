# FUTURE_DIRECTIONS — Information-Geometric Bridge (Cycle 1)

## Synthesis

This cycle established a fully formal bridge between statistical inference and
differential geometry on the finite categorical model (the open probability
simplex over a finite index `ι`). We defined the **Fisher information form**
`g_p(v, w) = ∑ i, v i * w i / p i` and proved it satisfies every axiom of a
Riemannian metric: it is symmetric (`fisherForm_symm`), bilinear
(`fisherForm_add_left`, `fisherForm_smul_left`), positive semidefinite
(`fisherForm_nonneg`), and in fact positive definite (`fisherForm_eq_zero_iff`) —
i.e. a genuine inner product on each tangent space whenever the weights are
strictly positive. This is the "differential geometry" half of the bridge,
realised with no manifold/charts machinery: the categorical model lets us expose
the metric as an explicit Gram form of the score vectors `∂ᵢ log p = δ/p`.

The "statistical inference" half is the **KL sandwich**
`0 ≤ KL(p‖q) ≤ g_q(p−q, p−q)`. The lower bound `klDiv_nonneg` is Gibbs'
inequality; the upper bound `klDiv_le_fisher` is the key new result: the Fisher
quadratic form (shown equal to the Pearson χ²-divergence via
`chiSquared_eq_fisher`) is a *global* upper bound for KL, not merely an
infinitesimal Hessian approximation. The structural insight that emerged is that
a single convexity lemma, `Real.log_le_sub_one_of_pos`, drives both ends of the
sandwich — applied to `q/p` it yields Gibbs, applied to `p/q` it yields the χ²
bound — and that the normalisation `∑p = ∑q = 1` is exactly the hypothesis that
makes the term-wise `−1` cancel so the χ² form appears. The naive term-wise
attempt `KL ≤ χ²` fails without normalisation; this was the main failure analysed.

What did not get done: Pinsker's inequality (the sharper lower bound
`KL ≥ ½‖p−q‖₁²`) is stated as a conjecture with `sorry`. It needs a genuinely
different argument (a 2-point reduction plus a scalar inequality) rather than the
term-wise log bound, which is why it is deferred. These results tie together into
a program: pin down the categorical Fisher metric as an honest inner product,
then control every classical divergence (KL, χ², total variation, Hellinger) by
that single quadratic form, building a dictionary between f-divergences and the
one Riemannian metric.

## Results Summary

- `fisherForm_symm`: proved — the Fisher form is symmetric, the first metric axiom.
- `fisherForm_add_left`: proved — additivity in the first slot (bilinearity).
- `fisherForm_smul_left`: proved — scalar homogeneity in the first slot (bilinearity).
- `fisherForm_nonneg`: proved — the Fisher quadratic form is positive semidefinite.
- `fisherForm_eq_zero_iff`: proved — positive definiteness, so the Fisher form is a true inner product on each tangent space.
- `chiSquared_eq_fisher`: proved — the Pearson χ²-divergence equals the Fisher quadratic form at the displacement `p−q`.
- `klDiv_nonneg`: proved — Gibbs' inequality, the lower end of the KL sandwich.
- `klDiv_le_fisher`: proved — the bridge: KL is globally upper-bounded by the Fisher/χ² quadratic form.
- `klDiv_ge_half_tv_sq`: conjecture (`sorry`) — Pinsker's inequality, the sharp lower end of the sandwich.

## Research Directions

### Direction 1: Pinsker closes the sandwich from below
**Hypothesis**: For positive probability vectors `p, q` on a finite set,
`KL(p‖q) ≥ ½ (∑ i, |p i − q i|)²` (the stated `klDiv_ge_half_tv_sq`).
**Test**: Prove it via the standard reduction to the two-point distribution: group
the index set into `{i : p i ≥ q i}` and its complement, reduce to the binary KL
versus binary TV inequality, then prove the scalar inequality
`a log(a/b) + (1−a) log((1−a)/(1−b)) ≥ 2(a−b)²` by calculus / `Real` convexity.
**Why now**: This cycle already isolated `Real.log_le_sub_one_of_pos` and the
normalisation bookkeeping; the only missing piece is the scalar binary bound. The
key insight is that TV is an L¹ object while Fisher/χ² is an L² object, so Pinsker
plus `klDiv_le_fisher` would sandwich KL between the L¹ and L² norms of `p−q`.
**If true**: A complete two-sided geometric control `½‖p−q‖₁² ≤ KL ≤ g_q(p−q,p−q)`,
turning KL into a quantity squeezed by two explicit metric norms.
**If false**: The constant ½ is sharp in the literature, so a failure would expose
a formalisation bug in the discrete TV definition rather than new mathematics.

### Direction 2: f-divergence dictionary over one metric
**Hypothesis**: Every smooth f-divergence `D_f(p‖q) = ∑ q i f(p i / q i)` with
`f` convex, `f(1)=0`, `f''(1)=1` satisfies the same second-order law
`D_f(q+v ‖ q) = ½ g_q(v,v) + o(‖v‖²)`, and admits a global bound of the form
`D_f ≤ c_f · g_q(p−q, p−q)` on a sublevel set of the χ² form.
**Test**: Formalise `fDiv`, prove the exact identity `χ²(p‖q) = g_q(p−q,p−q)`
generalises to `D_f` via a per-`f` constant; verify for `f(t)=t log t` (KL, done),
`f(t)=(t−1)²` (χ², exact), and `f(t)=(√t−1)²` (Hellinger).
**Why now**: `chiSquared_eq_fisher` already gives the χ² instance exactly, so the
template is in hand. The key insight is that the Fisher form is the *universal*
second-order kernel shared by all f-divergences. **Why now** specifically: with
the χ² = Fisher identity proven, each new divergence is a one-lemma extension.
**If true**: A unified Lean library where Fisher metric is the single geometric
object underlying the whole f-divergence zoo.
**If false**: It pinpoints which divergences fail the global (as opposed to local)
bound, sharpening the boundary between local and global information geometry.

### Direction 3: Positive definiteness without strict positivity (boundary faces)
**Hypothesis**: On the closed simplex, the Fisher form degenerates exactly on the
support-changing directions; restricted to the tangent space of a face
`{i : p i > 0}`, it remains positive definite, and `fisherForm_eq_zero_iff`
generalises with `v` supported on that face.
**Test**: State `fisherForm` with the convention `v i / p i = 0` when `p i = 0`
(or restrict the sum to the support) and prove the faceted positive-definiteness.
**Why now**: `fisherForm_eq_zero_iff` needs only `p i > 0`; the proof already keys
on `ne_of_gt (hp i)`. The key insight is that the singular behaviour of the Fisher
metric at the simplex boundary is *exactly* the loss of identifiability when a
category has zero probability. **Why now**: the existing proof localises the only
place positivity is used, making the boundary analysis a surgical edit.
**If true**: A formal account of why MLE/Fisher information blows up at boundary
distributions — directly relevant to statistical singular learning theory.
**If false**: It would reveal that the naive zero-convention breaks bilinearity,
flagging the need for a measure-theoretic (absolutely continuous) reformulation.

### Direction 4: The metric as a Mathlib `InnerProductSpace` instance
**Hypothesis**: For fixed positive `p`, `fisherForm p` endows the hyperplane
`{v : ι → ℝ // ∑ i, v i = 0}` (the simplex tangent space) with a bona fide
`InnerProductSpace ℝ` structure isometric to a reweighted Euclidean space.
**Test**: Build the bilinear map, discharge positivity from `fisherForm_eq_zero_iff`,
and exhibit the isometry `v ↦ (i ↦ v i / √(p i))` to the standard inner product.
**Why now**: All four metric axioms are already proven as standalone lemmas, so the
instance is an assembly job. The key insight is that the Fisher metric is a
*diagonal reweighting* of the Euclidean metric, which makes the isometry explicit.
**Why now**: with symmetry, bilinearity, and definiteness in hand, no new analysis
is required — only packaging into Mathlib's typeclass.
**If true**: Fisher geometry inherits Mathlib's entire inner-product API (Cauchy–
Schwarz, orthogonal projection, Gram–Schmidt) for free, enabling Cramér–Rao bounds.
**If false**: The obstruction would be the tangent-space constraint `∑ v i = 0`
interacting with subtype instances, indicating a need for a quotient construction.

### Direction 5: Cramér–Rao from Cauchy–Schwarz on the Fisher metric
**Hypothesis**: Given the inner-product structure of Direction 4, the Cauchy–
Schwarz inequality for `fisherForm` yields a discrete Cramér–Rao lower bound:
for any unbiased estimator gradient `b`, `Var ≥ (b · t)² / g_p(t,t)` along each
tangent direction `t`.
**Test**: Specialise Mathlib's `inner_mul_le_norm_mul_norm` to `fisherForm p` and
identify the two factors with estimator variance and Fisher information.
**Why now**: Direction 4 supplies the inner-product space; Cauchy–Schwarz is then
immediate. The key insight is that Cramér–Rao is *literally* Cauchy–Schwarz in the
Fisher metric — the statistical content is the geometric angle between score and
estimator. **Why now**: this is the payoff that justifies the whole bridge, and it
becomes one inequality away once Direction 4 lands.
**If true**: A formal, geometry-first proof of the foundational bound of estimation
theory, derived from the metric axioms proven in this cycle.
**If false**: It would mean the discrete estimator/score pairing does not match the
Fisher inner product, exposing a subtle mismatch between the algebraic and
statistical definitions of the score.
