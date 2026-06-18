# The Finite Algebra of Softmax Policy Gradients: Score Identities, Fisher Geometry, and Optimal Baselines

## Abstract

We develop, from first principles, the complete first-order theory of softmax
policy gradients and the variance-reduction theory of baselines as a body of
*purely finite algebra over a probability vector*. Working with a finite action
set of size `n`, a softmax-parameterized policy, and expectations expressed as
weighted finite sums, we establish a coherent chain of results: the softmax policy
is strictly positive and normalizes to one; the score function has zero mean (the
log-derivative / REINFORCE identity); the Fisher information matrix admits the
closed form `F = diag(π) − π πᵀ`; this matrix is symmetric and positive
semidefinite, the latter realized explicitly as a variance; subtracting a constant
baseline from a return preserves the gradient's mean; the estimator's second
moment is an exact upward parabola in the baseline; and the optimal baseline
`b⋆ = E_π[R s²] / E_π[s²]` is the unique minimizer, with the exact excess
`M(b) − M(b⋆) = A (b − b⋆)²`. We emphasize that no measure theory is required:
every theorem reduces to expanding squares and products, distributing constants
through finite sums, collapsing indicator functions, and invoking the
sum-to-one law. We give proof sketches, an algorithmic reading of each result, and
a discussion of applications to natural policy gradients and actor-critic methods,
followed by a program of open directions including the `1 − ρ²` variance ratio,
state-dependent baselines, the natural-gradient projection picture, Bellman
contraction, and trust-region monotonicity.

**Keywords:** policy gradient, REINFORCE, score function, Fisher information,
positive semidefinite, control variate, optimal baseline, variance reduction,
softmax, reinforcement learning.

---

## 1. Introduction

Policy gradient methods occupy a central place in modern reinforcement learning.
They optimize a parameterized policy directly by ascending an estimate of the
gradient of expected return. Two facts dominate their practical behavior. First,
the gradient estimator is *unbiased* — it points in the correct direction on
average — owing to a remarkable identity stating that the **score function** has
zero mean under the policy's own distribution. Second, the estimator has *high
variance*, and controlling that variance, most simply by subtracting a
**baseline**, is what separates usable algorithms from unusable ones.

Both phenomena are usually framed in the heavy language of measure-theoretic
probability and stochastic optimization. The thesis of this paper is that, for the
canonical case of a softmax policy over a finite action set, the entire first-order
theory is **finite algebra**: it lives entirely in the world of a probability
vector `π ∈ ℝⁿ` with `π_j > 0` and `Σ_j π_j = 1`, and every theorem is a
manipulation of finite sums. This perspective is not merely aesthetic. It yields
short, transparent, fully rigorous proofs; it isolates a single reusable proof
engine; and it exposes the precise algebraic reason each classical result is true.

We organize the theory into two layers. The **foundations** layer (Section 3)
treats positivity, normalization, the score identity, and the Fisher geometry. The
**variance-reduction** layer (Section 4) treats the baseline-unbiasedness, the
quadratic second moment, the optimal baseline, and the exact variance-reduction
amount. Section 5 reads each result algorithmically; Section 6 discusses
applications; Section 7 lays out open directions.

### 1.1 The single proof engine

Before stating anything, we name the recurring technique, because it appears in
essentially every proof below:

> **Engine.** *Expand the square or product; distribute constants through the
> finite sum (`c · Σ_a f(a) = Σ_a c · f(a)`); collapse indicator terms
> (`Σ_a g(a) · [a = j] = g(j)`); and reduce to the normalization law
> `Σ_a π_a = 1`.*

Every theorem in Sections 3–4 is an instance of this engine. The only result that
demands genuine care beyond a one-line application is the positive-semidefiniteness
of the Fisher matrix, which requires a deliberate triple-sum reordering to expose
its identity as a variance.

---

## 2. Setup and definitions

Fix `n : ℕ` actions, indexed by `Fin n = {0, 1, ..., n−1}`. Scalars are real.

**Definition 2.1 (Softmax policy).** Given a logit (preference) vector
`z : Fin n → ℝ`, the *softmax policy* is the function `softmaxPolicy z : Fin n → ℝ`
given by
> `softmaxPolicy z j = exp(z j) / Σ_{k} exp(z k)`.
We write `π_j := softmaxPolicy z j` when `z` is understood. The denominator
`Z := Σ_k exp(z k)` is the partition function.

**Definition 2.2 (Expectation over a distribution).** Given a weight vector
`p : Fin n → ℝ` and a function `f : Fin n → ℝ`, the *expectation* is the finite sum
> `expectVal p f = Σ_{a} p a · f a`.
When `p = π` we write `E_π[f] := expectVal π f`. All "probabilistic" statements
below are statements about this finite sum.

**Definition 2.3 (Score function).** For the softmax policy `π`, the *score* of
parameter `j` evaluated at action `a` is
> `softmaxScore π j a = [a = j] − π_j`,
where `[a = j]` denotes the `0/1` indicator (Kronecker delta `δ_{aj}`). This is the
partial derivative `∂/∂z_j log π(a)`; we take the closed form as the definition,
since it is what every downstream computation uses. We write `ψ_j(a)` for it.

**Definition 2.4 (Fisher information matrix).** The *Fisher information* is the
matrix `F : Fin n → Fin n → ℝ` of score correlations,
> `fisherInfo π j k = E_π[ ψ_j · ψ_k ] = Σ_a π_a · ([a = j] − π_j) · ([a = k] − π_k)`.

**Definition 2.5 (Baselined gradient estimator).** Fix a *return* function
`R : Fin n → ℝ` and a scalar *score* `s : Fin n → ℝ` (the one-parameter view of
`ψ`). For a *baseline* `b ∈ ℝ`, the estimator is `ĝ_b(a) = (R(a) − b) · s(a)`,
and its *second moment* is
> `secondMoment R s b = E_π[ ĝ_b² ] = Σ_a π_a · ((R a − b) · s a)²`.
We abbreviate the three moment coefficients
> `A := E_π[s²]`,   `B := E_π[R · s²]`,   `C := E_π[R² · s²]`.

Throughout, `[NeZero n]` (i.e. `n ≥ 1`) is assumed wherever normalization is
invoked; the action set must be nonempty.

---

## 3. Foundations: positivity, normalization, score, and Fisher geometry

### 3.1 The policy is a strictly positive distribution

**Theorem 3.1 (Strict positivity, `softmaxPolicy_pos`).** For every `z` and every
`j`, `softmaxPolicy z j > 0`.

*Proof sketch.* The numerator `exp(z j)` is strictly positive because the real
exponential is strictly positive everywhere. The denominator `Σ_k exp(z k)` is a
finite sum of strictly positive terms over a nonempty index set, hence strictly
positive. A positive number divided by a positive number is positive. ∎

The consequence is structural: strict positivity guarantees `log π_j` is finite
for all `j`, so every information-theoretic functional built from the policy —
entropy, cross-entropy, KL divergence — is well-defined, never producing the
forbidden `log 0`. This is the silent precondition behind every trust-region and
maximum-entropy argument.

**Theorem 3.2 (Normalization, `softmaxPolicy_sum_one`).** Assuming `n ≥ 1`,
`Σ_j softmaxPolicy z j = 1`.

*Proof sketch.* `Σ_j exp(z j) / Z = (1/Z) · Σ_j exp(z j) = Z / Z = 1`, where the
factoring of `1/Z` uses distribution of a constant through a finite sum, and
`Z ≠ 0` uses Theorem 3.1's denominator positivity. ∎

*Remark (the `n = 0` edge case).* Normalization genuinely requires nonemptiness.
For `n = 0` the empty sum equals `0 ≠ 1`, so the unguarded statement is false; the
`[NeZero n]` hypothesis is not decorative. Stating the precise hypothesis is part
of the result.

### 3.2 The score has zero mean — the log-derivative identity

**Theorem 3.3 (Zero-mean score, `softmaxScore_expect_zero`).** For each parameter
`j`, `E_π[ ψ_j ] = 0`; that is,
> `Σ_a π_a · ([a = j] − π_j) = 0`.

*Proof sketch (the engine in miniature).* Split the sum by linearity:
`Σ_a π_a · [a = j] − Σ_a π_a · π_j`. The first sum collapses by the indicator
(`Σ_a π_a · [a = j] = π_j`). The second sum factors the constant `π_j` out:
`π_j · Σ_a π_a = π_j · 1 = π_j`, using normalization (Theorem 3.2). The difference
is `π_j − π_j = 0`. ∎

This is the **REINFORCE** / log-derivative identity. Its importance cannot be
overstated: it is exactly what makes the policy gradient *unbiased*, because the
true gradient is `E_π[R · ψ]` and any additive perturbation proportional to `ψ`
that does not depend on the action contributes `(const) · E_π[ψ] = 0`. The whole of
Section 4 is downstream of this single zero.

### 3.3 The Fisher matrix in closed form

**Theorem 3.4 (Closed form, `fisherInfo_eq`).** For all `j, k`,
> `fisherInfo π j k = π_j · [j = k] − π_j · π_k`,
i.e. `F = diag(π) − π πᵀ`.

*Proof sketch.* Expand the product inside `Σ_a π_a ([a=j]−π_j)([a=k]−π_k)` into
four terms. Term `Σ_a π_a [a=j][a=k]` collapses to `π_j [j=k]` (both indicators
force `a = j = k`). Terms `−Σ_a π_a [a=j] π_k = −π_k π_j` and
`−Σ_a π_a π_j [a=k] = −π_j π_k` each collapse one indicator. The last term
`+Σ_a π_a π_j π_k = π_j π_k` uses normalization. Summing:
`π_j[j=k] − π_jπ_k − π_jπ_k + π_jπ_k = π_j[j=k] − π_jπ_k`. ∎

This generalizes the catalog's two-action softmax Jacobian identity to all `n` and
to off-diagonal entries: on the diagonal `F_{jj} = π_j(1 − π_j)`, the variance of a
Bernoulli with success probability `π_j`; off-diagonal `F_{jk} = −π_jπ_k`, the
negative covariance of mutually exclusive choices.

**Theorem 3.5 (Symmetry, `fisherInfo_symm`).** `fisherInfo π j k = fisherInfo π k j`.

*Proof sketch.* Immediate from the closed form: both `π_j[j=k] − π_jπ_k` and its
transpose equal `π_jπ_k`-corrected diagonal terms, and `[j=k] = [k=j]`,
`π_jπ_k = π_kπ_j`. ∎

### 3.4 The Fisher matrix is a variance — hence positive semidefinite

**Theorem 3.6 (Positive semidefiniteness, `fisherInfo_psd`).** For every vector
`v : Fin n → ℝ`,
> `vᵀ F v = Σ_{j,k} v_j F_{jk} v_k = E_π[ (Σ_j v_j ψ_j)² ] ≥ 0`.

*Proof sketch (the one result that resists one-shot automation).* Substitute the
definition `F_{jk} = E_π[ψ_jψ_k] = Σ_a π_a ψ_j(a) ψ_k(a)` and form the triple sum
`Σ_j Σ_k v_j (Σ_a π_a ψ_j(a)ψ_k(a)) v_k`. Reorder the summations to pull the
`a`-sum outermost (two applications of finite-sum commutation, with explicit index
annotations to keep the summand well-typed):
`Σ_a π_a · (Σ_j v_j ψ_j(a)) · (Σ_k v_k ψ_k(a)) = Σ_a π_a · (Σ_j v_j ψ_j(a))²`.
This is `E_π[ X² ]` for the random variable `X(a) = Σ_j v_j ψ_j(a)`. A weighted sum
of squares with nonnegative weights `π_a ≥ 0` is nonnegative. ∎

The conceptual payoff is decisive. The Fisher matrix is not "merely" positive
semidefinite — it *is* a variance, the variance of the directional score
`⟨v, ψ⟩`. This is the rigorous license for the **Fisher–Rao metric** used in
natural policy gradients: `F` defines a bona fide (semi-)inner product on the
tangent space of policies, and following the gradient through it yields updates
invariant to reparameterization. Its nullspace is exactly the direction in which
the score has no variation — the all-ones gauge direction of the softmax,
reflecting that adding a constant to every logit does not change the policy.

---

## 4. Variance reduction: baselines

We now fix a return `R` and scalar score `s` with the crucial property inherited
from Theorem 3.3:
> **(Z) `E_π[s] = 0`.**

### 4.1 Baselines are unbiased

**Theorem 4.1 (Baseline unbiasedness, `baseline_unbiased`).** Under (Z), for every
baseline `b`,
> `E_π[ (R − b) · s ] = E_π[ R · s ]`.

*Proof sketch.* Expand: `E_π[(R−b)s] = E_π[Rs] − b · E_π[s] = E_π[Rs] − b·0`. The
constant `b` factors out of the expectation by distributivity, and the second term
vanishes by (Z). ∎

Thus the entire family of baselined estimators `{ĝ_b : b ∈ ℝ}` shares one mean.
The baseline is a free parameter that moves *only* the noise, never the signal —
the formal justification for the most common variance-reduction trick in
reinforcement learning.

### 4.2 The second moment is an exact parabola

**Theorem 4.2 (Quadratic second moment, `secondMoment_quadratic`).** With
`A = E_π[s²]`, `B = E_π[R s²]`, `C = E_π[R² s²]`,
> `M(b) := secondMoment R s b = A · b² − 2B · b + C`.

*Proof sketch.* Expand the square pointwise:
`((R a − b) s a)² = (R a)²(s a)² − 2 b R a (s a)² + b² (s a)²`. Take `E_π` of each
term, distributing the constants `b` and `b²` through the finite sum:
`E_π[R² s²] − 2b · E_π[R s²] + b² · E_π[s²] = C − 2Bb + Ab²`. ∎

Since `A = E_π[s²]` is a weighted sum of squares with nonnegative weights, `A ≥ 0`;
when `s` is not `π`-almost-surely zero, `A > 0` and `M` is a strictly convex upward
parabola with a unique vertex.

### 4.3 The exact variance-reduction amount, and its corollaries

Define the candidate optimal baseline `b⋆ := B / A` (well-defined when `A > 0`).

**Theorem 4.3 (Completed square, `variance_reduction_amount`).** For every `b`
(with `A > 0`),
> `M(b) − M(b⋆) = A · (b − b⋆)²`.

*Proof sketch.* Complete the square in Theorem 4.2: `M(b) = A(b − B/A)² + (C − B²/A)`.
Hence `M(b⋆) = C − B²/A` and `M(b) − M(b⋆) = A(b − B/A)² = A(b − b⋆)²`. Equivalently,
expand the right-hand side `A(b−b⋆)² = Ab² − 2Ab⋆ b + A b⋆²` and substitute
`Ab⋆ = B`, `Ab⋆² = B²/A` to recover `M(b) − (C − B²/A)`. ∎

This identity is the keystone: the three classical baseline results are immediate
corollaries, requiring no new computation.

**Corollary 4.4 (Optimality, `optimal_baseline_min`).** `b⋆` minimizes the second
moment: for all `b`, `M(b⋆) ≤ M(b)`. *Proof.* `M(b) − M(b⋆) = A(b−b⋆)² ≥ 0` since
`A ≥ 0` and squares are nonnegative. ∎ By Theorem 4.1 all `ĝ_b` share a mean, so
minimizing the second moment minimizes the variance: `b⋆` is the
*variance-optimal* baseline.

**Corollary 4.5 (Uniqueness / strictness, `optimal_baseline_strict`).** If `A > 0`
and `b ≠ b⋆`, then `M(b⋆) < M(b)` strictly. *Proof.* `(b − b⋆)² > 0` for `b ≠ b⋆`,
and `A > 0`, so `A(b−b⋆)² > 0`. ∎

The closed form of the optimum,
> `b⋆ = E_π[R · s²] / E_π[s²]`,
deserves emphasis: it is **not** the mean return `E_π[R]`, but the return averaged
with weights proportional to the squared score `s²`. Intuitively, the optimal
baseline cares most about returns at actions where the policy is most sensitive.
The naive "use the average return" heuristic is the special case where `R` and `s²`
are uncorrelated.

---

## 5. Algorithmic reading

Each theorem corresponds to a finite, exact computation over the probability
vector. We highlight three.

**Algorithm A (Fisher quadratic form via variance realization).** To evaluate
`vᵀ F v` without forming the `n × n` matrix, use Theorem 3.6 directly: compute, for
each action `a`, the directional score `X(a) = Σ_j v_j ([a=j] − π_j) = v_a − ⟨v,π⟩`,
then return `Σ_a π_a X(a)²`. This is `O(n)` after an `O(n)` precomputation of
`⟨v,π⟩`, versus `O(n²)` for the explicit matrix–vector product, and it manifestly
returns a nonnegative number (a certificate of PSD-ness by construction).

**Algorithm B (Optimal baseline).** Given samples or exact `(π, R, s)`, accumulate
`A = Σ_a π_a s(a)²` and `B = Σ_a π_a R(a) s(a)²` in one pass, then return
`b⋆ = B / A` (guarding `A > 0`). Cost `O(n)`. This is exactly the estimator used in
practice, here derived as the provable global optimum.

**Algorithm C (Variance-reduction audit).** Given any baseline `b` actually in use,
report the *exact* excess noise `M(b) − M(b⋆) = A (b − b⋆)²`. This converts the
abstract guarantee into a concrete, auditable number: how many units of estimator
variance a suboptimal baseline is costing.

---

## 6. Applications and significance

**Unbiased policy gradients.** Theorem 3.3 is the algebraic certificate that the
REINFORCE estimator is unbiased and that any baseline (Theorem 4.1) preserves that
unbiasedness. These are the two load-bearing facts of every policy gradient method.

**Natural policy gradients and information geometry.** Theorems 3.4–3.6 furnish the
Fisher–Rao metric `F = diag(π) − π πᵀ` together with a proof that it is a genuine
positive-semidefinite form (a variance). This is the foundation of natural gradient
methods, whose central promise — reparameterization-invariant steepest descent —
requires exactly that `F` define a meaningful geometry.

**Actor-critic methods.** The optimal baseline `b⋆` is, in the state-dependent
generalization, precisely the value function. Corollaries 4.4–4.5 thus formalize
the core rationale for actor-critic architectures: subtracting a learned value
estimate is the variance-optimal control variate.

**Control variates beyond RL.** The baseline trick is an instance of the
control-variate method. The completed-square identity (Theorem 4.3) is a clean,
general statement of how much a control variate helps and when it is optimal,
transferable to Monte Carlo estimation broadly.

**Connections to neuroscience and statistics.** The score `ψ_j = [a=j] − π_j` is a
prediction-error signal; the Fisher matrix is the classical information matrix of
mathematical statistics; the PSD realization is the Cramér–Rao geometry. The
finite-algebraic treatment makes these correspondences exact and checkable.

---

## 7. Discussion: the measure-theory-free core

The unifying message is methodological. The first-order theory of softmax policy
gradients does not need measure theory, σ-algebras, or limits; it needs a
probability *vector* and the single proof engine of Section 1.1. Every theorem —
positivity, normalization, the zero-mean score, the Fisher closed form, symmetry,
positive semidefiniteness, baseline unbiasedness, the quadratic second moment, the
optimal baseline, and the exact reduction — is a finite-sum identity.

The one place the engine strains is the PSD identity (Theorem 3.6), which is not a
one-line indicator collapse but a triple-sum reordering culminating in the
realization of the quadratic form as `E_π[(⟨v,ψ⟩)²]`. This is the signpost for
where the *next* layer of theory lives: the matrix-level (rather than scalar) facts
want a clean, reusable, `Finset`-indexed quadratic-form API. Building that API is
the natural next investment.

---

## 8. Future directions

**Direction 1 — The optimal-baseline variance ratio `1 − ρ²`.** Define the
centered variance `V(b) = M(b) − (E_π[R s])²`. We conjecture the optimal baseline
achieves `V(b⋆)/V(0) = 1 − ρ²`, where `ρ² = B²/(A·C')` is a squared correlation
between the return and the `s²`-weighted score mass; equivalently
`V(b⋆) = C − B²/A − (E_π[Rs])²`. The exact numerator gain `A(b−b⋆)²` is already in
hand (Theorem 4.3); only a normalization and a Cauchy–Schwarz bound `B² ≤ A·C`
(provable by the same sum-of-squares logic as Theorem 3.6) remain. If true it ports
the textbook control-variate bound with an exact constant; if false, it pinpoints
the hidden centering/independence assumption in the folklore.

**Direction 2 — State-dependent baselines and `b⋆(s) = V^π(s)`.** Generalize the
expectation to a product index `State × Action` with conditional scores satisfying
`E[ψ | s] = 0`, prove a conditional `baseline_unbiased` and `optimal_baseline_min`
per state, and a tensorized total-variance decomposition
`Var = E[Var(·|s)] + Var(E[·|s])`. Because Corollaries 4.4–4.5 already hold for an
*arbitrary* distribution and arbitrary `R, s`, instantiating a conditional slice is
immediate. If true it yields the proof that the value function is the optimal
baseline — the cornerstone of actor-critic; if false it reveals where shared
parameters break separable optimality.

**Direction 3 — Natural gradient = projection, `F⁺F` a projector.** Using
`F = diag(π) − π πᵀ`, show the Moore–Penrose pseudoinverse satisfies
`F⁺F = I − (1/n) 𝟙𝟙ᵀ` on the tangent space, so the natural gradient is the
Euclidean gradient projected orthogonal to the all-ones (gauge) direction. The
nullspace direction is free from Theorem 3.3 (rows of `F` sum to zero); the rank/
range characterization and gauge-invariance under `z ↦ z + c𝟙` complete it. If true
it formalizes natural PG as reparameterization-invariant steepest descent; if false
it exposes a boundary-policy degeneracy that strict positivity (Theorem 3.1) is
meant to rule out.

**Direction 4 — Bellman γ-contraction ⇒ unique fixed point, geometric rate.** On
`Fin S → ℝ` with the sup norm, show the discounted Bellman operator `T` is a
`γ`-contraction (`γ < 1`), hence `Tᵏ V → V⋆` with
`‖Tᵏ V − V⋆‖∞ ≤ γᵏ ‖V − V⋆‖∞` and `V⋆` unique. Finite `S` makes the space complete
off the shelf; the missing piece is the metric contraction bound
`dist(Tu, Tv) ≤ γ · dist(u, v)`. If true it upgrades residual-decay stories to
fixed-point uniqueness with a geometric rate, enabling certified value iteration;
if false it sharpens which discounting is needed for uniqueness.

**Direction 5 — Pinsker + softmax positivity ⇒ KL trust-region monotonicity.** For
two softmax policies, show `KL(π_old ‖ π_new) = Σ_a π_old(a)(log π_old(a) −
log π_new(a))` is well-defined and nonnegative (Gibbs), then Pinsker
`‖π_old − π_new‖₁² ≤ 2·KL`, and combine with an advantage bound for monotone
improvement under a tight KL constraint `δ ≤ ε²(1−γ)³/(8γ)`. Strict positivity
(Theorem 3.1) already discharges the "no `log 0`" obligation that blocks every KL
formalization. If true it provides the analytic backbone of a trust-region
monotonic-improvement proof; if false a counterexample calibrates the constant.

---

## 9. Conclusion

We have presented the complete first-order theory of softmax policy gradients and
baseline variance reduction as finite algebra over a probability vector. The
results form a tight logical chain — from strict positivity and normalization,
through the zero-mean score and the variance-realized Fisher geometry, to the exact
optimal baseline and the completed-square variance-reduction identity — each proved
by the same elementary engine. The framework is deliberately measure-theory-free,
self-contained, and built to be extended: the open directions above all attach
directly to the objects defined here. The deeper lesson is that the randomness at
the heart of reinforcement learning, so forbidding in practice, rests on a
foundation of averages that is, at bottom, plain algebra.
