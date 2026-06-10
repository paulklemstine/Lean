# An Information-Geometric Bridge: The Fisher Metric on the Categorical Statistical Manifold and a Global KL–Fisher Sandwich

## Abstract

We develop, in fully verified form, a bridge between statistical inference and
differential geometry on the finite categorical model — the open probability
simplex over a finite index set. We define the **Fisher information bilinear
form** `g_p(v, w) = Σᵢ vᵢ wᵢ / pᵢ` and prove that, for strictly positive weight
vectors `p`, it satisfies every axiom of a Riemannian metric: it is symmetric,
bilinear in each argument, positive semidefinite, and positive definite — i.e. a
genuine inner product on each tangent space. This realises the differential
geometry of the statistical manifold with no chart or fibre-bundle machinery,
exposing the metric directly as the Gram form of the categorical score vectors
`∂ᵢ log p = δ/p`. On the inferential side we establish the **KL sandwich**

> `0 ≤ KL(p ‖ q) ≤ g_q(p − q, p − q)`

for probability vectors `p, q` with strictly positive entries. The lower bound is
Gibbs' inequality; the upper bound is the principal new result: the Fisher
quadratic form — shown to coincide exactly with the Pearson χ²-divergence at the
displacement `p − q` — is a *global* (not merely infinitesimal) upper bound for
the Kullback–Leibler divergence. A single convexity estimate,
`log y ≤ y − 1`, drives both ends of the sandwich, and the normalisation
constraint `Σ p = Σ q = 1` is precisely the hypothesis that makes the linear
remainder terms cancel. We discuss the necessity of normalisation, the relation
to the classical "Fisher = Hessian of KL" folklore, and the path toward a sharp
two-sided geometric control of KL (Pinsker's inequality and an f-divergence
dictionary).

**Keywords:** Fisher information metric, statistical manifold, information
geometry, Kullback–Leibler divergence, χ²-divergence, Gibbs' inequality,
Riemannian metric, categorical model.

---

## 1. Introduction

Information geometry studies families of probability distributions as smooth
manifolds equipped with the Fisher information metric and a family of dual affine
connections. Its central insight is that statistical concepts — estimation
efficiency, divergence between hypotheses, the curvature of likelihood — are
geometric concepts in disguise. The Fisher information metric, introduced by Rao,
endows a parametric statistical model with a Riemannian structure under which many
statistical quantities acquire invariant geometric meaning.

This paper focuses on the simplest non-trivial statistical manifold — the
**categorical model**, i.e. the open probability simplex `Δ°(ι)` of strictly
positive distributions over a finite outcome set `ι` — and makes two
contributions, both established with complete rigour.

1. **The geometry half.** We prove that the categorical Fisher information form is
   a genuine Riemannian metric: symmetric, bilinear, positive definite. On the
   categorical model this can be done with no abstract manifold machinery, because
   the metric collapses to the explicit Gram form `g_p(v, w) = Σᵢ vᵢ wᵢ / pᵢ`.

2. **The inference half (the bridge).** We prove a global, non-infinitesimal
   inequality controlling the Kullback–Leibler divergence by the Fisher quadratic
   form, `0 ≤ KL(p‖q) ≤ g_q(p − q, p − q)`, and we identify the right-hand side
   with the Pearson χ²-divergence. This upgrades the classical infinitesimal
   identity "Fisher metric = Hessian of KL at the diagonal" to a uniform bound for
   distributions arbitrarily far apart.

The unifying technical observation is that the entire argument is powered by a
single elementary convexity inequality for the logarithm, applied in two opposite
orientations, together with the normalisation constraint that converts a
term-wise estimate into a global one.

### 1.1 Notation

Throughout, `ι` is a finite type, and functions `p, q, v, w : ι → ℝ` are
identified with vectors indexed by `ι`. We write `Σᵢ` for the sum over all of
`ι`. A vector `p` is a *positive weight vector* if `pᵢ > 0` for all `i`, and a
*probability vector* if additionally `Σᵢ pᵢ = 1`. Tangent vectors to the simplex
are vectors `v` with `Σᵢ vᵢ = 0`, though several results hold for arbitrary `v`.

---

## 2. Definitions

We collect the three central definitions. Each is a finite sum, hence elementary
and computable.

**Definition 2.1 (Fisher information form).** For a weight vector `p` and vectors
`v, w : ι → ℝ`, the *Fisher information bilinear form* is
> g_p(v, w)  :=  Σᵢ  vᵢ · wᵢ / pᵢ.

For strictly positive `p` this is the Gram form of the categorical score vectors:
the score of the family `p(x; θ) = θ_x` is `∂ᵢ log p = δ_{·,i} / p_i`, and the
Fisher metric `E_p[ ∂ᵥ log p · ∂_w log p ]` specialises to exactly `g_p(v, w)`.

**Definition 2.2 (Kullback–Leibler divergence).** For weight vectors `p, q`,
> KL(p ‖ q)  :=  Σᵢ  pᵢ · log(pᵢ / qᵢ).

**Definition 2.3 (Pearson χ²-divergence).** For weight vectors `p, q`,
> χ²(p ‖ q)  :=  Σᵢ  (pᵢ − qᵢ)² / qᵢ.

---

## 3. The Fisher form is a Riemannian metric

We prove that `g_p` satisfies the axioms of a Riemannian metric. The proofs are
short because the categorical model removes all manifold overhead; nevertheless
each property is exactly the corresponding metric axiom.

**Theorem 3.1 (Symmetry).** For all `p, v, w`,  `g_p(v, w) = g_p(w, v)`.

*Proof sketch.* Term by term, `vᵢ wᵢ / pᵢ = wᵢ vᵢ / pᵢ` by commutativity of
multiplication; sum over `i`. ∎

**Theorem 3.2 (Additivity in the first argument).** For all `p, u, v, w`,
> g_p(u + v, w) = g_p(u, w) + g_p(v, w).

*Proof sketch.* Expand `(uᵢ + vᵢ) wᵢ / pᵢ = uᵢ wᵢ / pᵢ + vᵢ wᵢ / pᵢ` and use
linearity of the finite sum. ∎

**Theorem 3.3 (Homogeneity in the first argument).** For all scalars `c` and all
`p, v, w`,
> g_p(c · v, w) = c · g_p(v, w).

*Proof sketch.* Each term scales as `(c vᵢ) wᵢ / pᵢ = c (vᵢ wᵢ / pᵢ)`; factor `c`
out of the sum. ∎

Theorems 3.1–3.3, together with symmetry, give bilinearity in both slots, so `g_p`
is a symmetric bilinear form.

**Theorem 3.4 (Positive semidefiniteness).** If `pᵢ > 0` for all `i`, then
`g_p(v, v) ≥ 0` for all `v`.

*Proof sketch.* Each summand `vᵢ² / pᵢ` is a non-negative number (a square)
divided by a positive number, hence `≥ 0`; a sum of non-negatives is `≥ 0`. ∎

**Theorem 3.5 (Positive definiteness).** If `pᵢ > 0` for all `i`, then
> g_p(v, v) = 0  ⇔  v = 0.

*Proof sketch.* By Theorem 3.4 each summand `vᵢ²/pᵢ` is non-negative, so the sum
vanishes iff every summand vanishes. Since `pᵢ > 0`, `vᵢ²/pᵢ = 0` iff `vᵢ = 0`.
Hence the form vanishes iff `v` is identically zero. ∎

**Corollary 3.6 (Riemannian metric).** For every strictly positive weight vector
`p`, the Fisher form `g_p` is a symmetric, positive-definite bilinear form — a
genuine inner product on the tangent space at `p`. Letting `p` range over the open
simplex `Δ°(ι)` makes `(Δ°(ι), g)` a Riemannian manifold.

This is the **differential-geometry half of the bridge**, established with only
elementary algebra and order facts on `ℝ`. Notably, positive-definiteness requires
only `pᵢ > 0` — no normalisation.

---

## 4. The χ²–Fisher identity

The next result is the linchpin connecting the geometric and inferential halves.

**Theorem 4.1 (χ² = Fisher quadratic form).** For all weight vectors `p, q`,
> χ²(p ‖ q) = g_q(p − q, p − q).

*Proof sketch.* Unfold both sides. The right-hand side is
`Σᵢ (p − q)ᵢ · (p − q)ᵢ / qᵢ = Σᵢ (pᵢ − qᵢ)² / qᵢ`, which is precisely
`χ²(p ‖ q)`. The identity is definitional once one observes `(p − q)ᵢ = pᵢ − qᵢ`
and `(pᵢ − qᵢ)·(pᵢ − qᵢ) = (pᵢ − qᵢ)²`. ∎

Theorem 4.1 says the Pearson χ² statistic is exactly the squared Fisher length of
the displacement vector `p − q`, measured at the base point `q`. Since
`Σᵢ (pᵢ − qᵢ) = Σᵢ pᵢ − Σᵢ qᵢ = 0` for probability vectors, the displacement is a
legitimate tangent vector, so feeding it to the metric is geometrically
meaningful.

---

## 5. The KL bridge

We now establish the two-sided control of KL. Both directions rest on a single
convexity lemma.

**Lemma 5.1 (Logarithmic convexity).** For every `y > 0`,  `log y ≤ y − 1`, with
equality iff `y = 1`.

This is the standard tangent-line bound for the concave logarithm at `1`. It is
the only analytic input to the entire bridge.

### 5.1 Lower bound: Gibbs' inequality

**Theorem 5.2 (Gibbs' inequality).** For probability vectors `p, q` with strictly
positive entries (`pᵢ, qᵢ > 0`, `Σ p = Σ q = 1`),
> KL(p ‖ q) ≥ 0.

*Proof sketch.* Apply Lemma 5.1 to `y = qᵢ / pᵢ > 0`: `log(qᵢ/pᵢ) ≤ qᵢ/pᵢ − 1`.
Equivalently, in terms of the KL summands, `−log(pᵢ/qᵢ) ≤ qᵢ/pᵢ − 1`, so
`pᵢ log(pᵢ/qᵢ) ≥ pᵢ(1 − qᵢ/pᵢ) = pᵢ − qᵢ`. Summing over `i`,
> KL(p ‖ q) = Σᵢ pᵢ log(pᵢ/qᵢ) ≥ Σᵢ (pᵢ − qᵢ) = (Σ p) − (Σ q) = 1 − 1 = 0.

The normalisation is used exactly once, to evaluate `Σ(pᵢ − qᵢ) = 0`. ∎

### 5.2 Upper bound: the Fisher control of KL

**Theorem 5.3 (KL ≤ Fisher).** For probability vectors `p, q` with strictly
positive entries,
> KL(p ‖ q) ≤ g_q(p − q, p − q)  =  χ²(p ‖ q).

*Proof sketch.* Apply Lemma 5.1 to `y = pᵢ / qᵢ > 0`:
`log(pᵢ/qᵢ) ≤ pᵢ/qᵢ − 1`. Multiply by `pᵢ ≥ 0` (preserving the inequality) and
sum:
> KL(p ‖ q) = Σᵢ pᵢ log(pᵢ/qᵢ) ≤ Σᵢ pᵢ (pᵢ/qᵢ − 1) = Σᵢ pᵢ²/qᵢ − Σᵢ pᵢ
>           = Σᵢ pᵢ²/qᵢ − 1.

It remains to show `Σᵢ pᵢ²/qᵢ − 1 = χ²(p ‖ q)`. Expand the χ² definition:
> χ²(p ‖ q) = Σᵢ (pᵢ − qᵢ)²/qᵢ = Σᵢ (pᵢ²/qᵢ − 2pᵢ + qᵢ)
>           = Σᵢ pᵢ²/qᵢ − 2Σᵢ pᵢ + Σᵢ qᵢ = Σᵢ pᵢ²/qᵢ − 2 + 1 = Σᵢ pᵢ²/qᵢ − 1.

Hence `KL(p ‖ q) ≤ χ²(p ‖ q)`, and by Theorem 4.1 the right-hand side equals
`g_q(p − q, p − q)`. Equivalently, the per-term identity
`pᵢ(pᵢ/qᵢ − 1) = (pᵢ − qᵢ)²/qᵢ + (pᵢ − qᵢ)` shows the summand splits into the χ²
term plus a linear remainder `(pᵢ − qᵢ)` whose sum is zero by normalisation. ∎

### 5.3 The sandwich

Combining Theorems 4.1, 5.2, and 5.3:

**Corollary 5.4 (KL sandwich).** For probability vectors `p, q` with strictly
positive entries,
> 0 ≤ KL(p ‖ q) ≤ g_q(p − q, p − q) = χ²(p ‖ q).

This is the **inference half of the bridge**, and the main new content. The
classical folklore "the Fisher metric is the Hessian of KL" is the infinitesimal
shadow of Corollary 5.4: as `p → q`, both KL and ½χ² behave like
`½ g_q(p − q, p − q)` to leading order, but Corollary 5.4 holds for *all* `p, q`,
not merely in the limit.

---

## 6. The role of normalisation

A central structural point is that the two halves of the bridge depend on
different hypotheses.

- **Positive-definiteness (Theorems 3.4–3.5)** requires only `pᵢ > 0`. No
  normalisation is needed: the Fisher form is a metric on the cone of positive
  vectors, restricting to the open simplex.

- **The KL upper bound (Theorem 5.3)** is *false* without `Σ p = Σ q = 1`. The
  term-wise estimate yields `KL ≤ Σ pᵢ²/qᵢ − Σ pᵢ`, and only when `Σ p = 1` and
  `Σ q = 1` does the remainder collapse to make `Σ pᵢ²/qᵢ − 1 = χ²`. A naive
  term-wise comparison "KL ≤ χ²" fails: the linear `−1` per term cancels *only
  after summing under the normalisation constraint.* This is the principal
  subtlety, and the principal failure mode encountered in developing the result.

The lesson is conceptual: the KL–Fisher bound is a property of the *whole*
distribution, not of any individual coordinate. Information lives globally.

---

## 7. Algorithms

The definitions are directly computable, yielding the following algorithms (full
type-hinted implementations appear in the accompanying demo and package code).

**Algorithm 7.1 (Fisher form evaluation).** Given `p, v, w`, return
`Σᵢ vᵢ wᵢ / pᵢ`. Complexity `O(|ι|)` time, `O(1)` extra space. This evaluates the
Riemannian inner product at `p` and, with `v = w = p − q`, the χ²-divergence.

**Algorithm 7.2 (KL divergence).** Given probability vectors `p, q`, return
`Σᵢ pᵢ log(pᵢ/qᵢ)`. Complexity `O(|ι|)`.

**Algorithm 7.3 (Sandwich verifier).** Given `p, q`, compute `KL(p‖q)` and
`g_q(p−q, p−q)` and assert `0 ≤ KL ≤ g_q(p−q,p−q)`. This numerically witnesses
Corollary 5.4 on any instance. Complexity `O(|ι|)`.

**Algorithm 7.4 (Natural-gradient step).** Given a loss `L` with Euclidean
gradient `∇L` at `p`, the natural-gradient direction is the Euclidean gradient
rescaled by the inverse Fisher metric. For the diagonal categorical metric the
inverse is itself diagonal, so the natural gradient component is `pᵢ · (∇L)ᵢ`,
computable in `O(|ι|)`. This is the standard application of the Fisher metric in
optimization and is exact here because the categorical metric is diagonal.

---

## 8. Applications

**Maximum-likelihood and cross-entropy training.** Minimizing KL(p‖q) over `q` (or
its empirical surrogate, cross-entropy) is the core objective of probabilistic
machine learning. Corollary 5.4 furnishes a *quadratic* upper surrogate
`χ² = g_q(p−q, p−q)`: minimizing the quadratic form decreases an upper bound on
KL, and the bound is tight to second order. Quadratic objectives are amenable to
closed-form and trust-region optimization, so the bound transfers analytical
tractability from χ² to KL.

**Hypothesis testing.** Theorem 4.1 identifies the Pearson χ² statistic with a
squared Fisher length, giving the classical goodness-of-fit test an exact
geometric interpretation: the test statistic is the squared Riemannian distance
(to leading order) between observed and expected distributions.

**Natural-gradient optimization.** Algorithm 7.4 implements steepest descent with
respect to `g`, which is invariant to reparametrization of the model and typically
converges faster than Euclidean gradient descent. Its correctness rests on `g`
being a genuine metric (Corollary 3.6).

**Bounding rare-event probabilities.** Because KL controls large-deviation rates
(Sanov's theorem) and Corollary 5.4 controls KL by an explicit quadratic, one
obtains computable quadratic envelopes for exponential decay rates.

---

## 9. Discussion and related work

The Fisher information metric and its status as the canonical Riemannian metric on
statistical manifolds (Chentsov's uniqueness theorem) are foundational to
information geometry. The infinitesimal relation between KL and the Fisher metric
is classical: the Hessian of `q ↦ KL(p‖q)` at `q = p` is the Fisher matrix. Our
contribution on the categorical model is to make this relationship *global and
elementary*: a single tangent-line bound for the logarithm yields both Gibbs'
inequality and the exact χ² = Fisher upper bound, with the normalisation
constraint as the sole structural hinge. The development requires none of the
heavy apparatus of charts, connections, or measure-theoretic likelihoods — the
categorical model exposes the metric as a transparent Gram form, making every step
a finite computation over the reals.

The ordering KL ≤ χ² among f-divergences is itself classical; what the present
treatment adds is the *geometric reading* of the right-hand side as the Fisher
quadratic form, packaged with a uniform proof of both bounds and a precise account
of why normalisation is indispensable for the upper bound but irrelevant for the
metric axioms.

---

## 10. Future directions

**Pinsker's inequality (sharp lower bound).** The sandwich's lower bound, mere
non-negativity, is loose. The sharp floor is Pinsker's inequality,
`KL(p‖q) ≥ ½ ‖p − q‖₁²`, controlling KL below by the squared total-variation
distance. Unlike the term-wise log bound used here, this requires a genuinely
different argument — a two-point reduction together with a scalar inequality — and
is the natural next target, currently stated as a conjecture.

**An f-divergence dictionary.** The program suggested by these results is to
control *every* classical divergence — KL, χ², total variation, Hellinger,
Rényi — by the single Fisher quadratic form, building a systematic dictionary
between f-divergences and the one Riemannian metric of the categorical model.

**Beyond the categorical model.** Extending the explicit Gram-form treatment to
exponential families and, ultimately, to general (non-finite) statistical models
would test how much of the elementary structure survives, and would connect the
present finite bridge to the full apparatus of information geometry.

**Curvature and geodesics.** Having established the metric, the natural sequel is
to compute the Levi-Civita connection, geodesics, and the dual (`±1`)-connections
of Amari, and to relate KL to the canonical divergence of the dually flat
structure on the simplex.

---

## 11. Conclusion

On the finite categorical model we have given a complete, elementary, and verified
bridge between statistical inference and differential geometry. The Fisher
information form `g_p(v, w) = Σᵢ vᵢ wᵢ / pᵢ` is a genuine Riemannian metric
(symmetric, bilinear, positive definite for strictly positive weights), the
Pearson χ²-divergence is exactly its quadratic form at the displacement `p − q`,
and the Kullback–Leibler divergence is sandwiched as `0 ≤ KL ≤ g_q(p−q, p−q)`.
A single logarithmic convexity inequality powers both ends of the sandwich, and
the normalisation constraint is the precise hinge that turns a term-wise estimate
into a global χ² = Fisher bound. The result upgrades the classical infinitesimal
"Fisher = Hessian of KL" to a uniform inequality and opens a clear path toward a
full dictionary between statistical divergences and the geometry of the simplex.
