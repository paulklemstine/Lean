# The Fisher Information Metric on Finite Statistical Manifolds: A Constructive Riemannian Bridge to Statistical Inference

## Abstract

We give a fully constructive development of the Fisher information metric for
statistical models on a finite sample space, parametrized by a finite-dimensional
real parameter. Rather than *postulating* a positive-definite metric tensor — as
is common in axiomatic treatments of information geometry — we *construct* the
Fisher information matrix as an explicit expectation of the outer product of
score functions and *derive*, from first principles, that it satisfies the axioms
of a Riemannian metric tensor: symmetry, a sum-of-squares representation of its
quadratic form, positive semidefiniteness, and positive definiteness under a
natural identifiability (score nondegeneracy) condition. We then erect two
bridges to classical statistics and differential geometry. First, using the
zero-mean property of the score, we show the Fisher matrix is precisely the
covariance of the score, connecting the metric to estimation theory and the
Cramér–Rao program. Second, we prove the "two forms of Fisher information"
identity — that the Fisher matrix equals the negative expected Hessian of the
log-likelihood — which, geometrically, identifies the Fisher metric with the
local curvature (Hessian) of the Kullback–Leibler divergence at the diagonal.
As a global companion we establish that the Kullback–Leibler divergence vanishes
on the diagonal and is nonnegative (Gibbs' inequality). A worked Bernoulli
instance pins the abstraction to the classical closed-form information
`G(σ) ∝ 1/(σ(1−σ))`. All results have been formally verified.

**Keywords.** Fisher information, information geometry, Riemannian metric,
Kullback–Leibler divergence, score function, Gibbs' inequality, Cramér–Rao,
statistical manifold, positive definiteness.

---

## 1. Introduction

### 1.1 Motivation

Information geometry studies families of probability distributions as
differential-geometric objects. The foundational insight, due to Rao and Fisher
and developed extensively by Chentsov, Amari, and Nagaoka, is that the parameter
space of a statistical model carries a canonical Riemannian metric — the *Fisher
information metric* — whose length element measures the local
*distinguishability* of nearby distributions. Under Chentsov's theorem, the
Fisher metric is (up to scale) the unique Riemannian metric invariant under
sufficient statistics, singling it out as *the* natural geometry of inference.

Two features make the Fisher metric central. First, it controls the precision of
statistical estimation: the Cramér–Rao bound states that the covariance of any
unbiased estimator is bounded below by the inverse Fisher information. Second, it
is the infinitesimal form of the Kullback–Leibler (KL) divergence: the second-
order Taylor expansion of `KL(θ‖θ′)` around `θ′ = θ` is the Fisher quadratic
form. The metric is therefore the hinge between the *global* theory of
divergences and the *local* theory of curvature.

### 1.2 Contribution

Many formal and informal treatments take a positive-definite metric tensor as a
primitive datum. We instead adopt a *constructive* stance on a finite sample
space, where no measure-theoretic subtleties intrude and every expectation is a
finite sum:

1. We define a `StatModel` capturing a parametrized probability model together
   with its score field and the regularity condition that the score has zero
   mean (Section 2).
2. We construct the Fisher matrix and prove the four Riemannian-metric axioms:
   symmetry, the sum-of-squares quadratic-form identity, positive
   semidefiniteness, and positive definiteness under score nondegeneracy
   (Section 3).
3. We prove the Fisher matrix equals the covariance of the score (Section 4).
4. We prove the two-forms identity `G = −E[Hessian of log-likelihood]` and
   interpret it as the curvature of KL (Section 5).
5. We define KL divergence and prove `KL(p‖p) = 0` and Gibbs' inequality
   `KL ≥ 0` (Section 6).
6. We instantiate the framework on the Bernoulli model with a closed-form
   computation (Section 7).

Throughout, the finiteness of the sample space lets us replace dominated-
convergence arguments with elementary manipulations of finite sums, so the
derivations are completely elementary while remaining fully rigorous.

---

## 2. Statistical models on a finite sample space

### 2.1 Notation and conventions

Throughout, the sample space is the finite type `Fin n = {0, 1, …, n−1}` and the
parameter space is `ℝ^d`, identified with functions `Fin d → ℝ`. Sums `∑ₓ` range
over all `n` outcomes and sums `∑ᵢ`, `∑ⱼ` over all `d` parameter coordinates. An
expectation `E_θ[f] := ∑ₓ p(x;θ)·f(x)` is always with respect to the model
distribution at the current parameter. All quantities are real; because the
sample space is finite, every sum is finite and every interchange of summation is
unconditional. We write `score(θ,x,i)` for the `i`-th score component and reserve
`v, w` for tangent vectors (parameter directions).

### 2.2 The model

We work with outcomes indexed by `Fin n = {0, 1, …, n−1}` and parameters in
`ℝ^d`, identified with functions `Fin d → ℝ`.

> **Definition 2.1 (Statistical model).** A *statistical model* on the finite
> sample space `Fin n` parametrized by `Fin d → ℝ` consists of
> - a probability kernel `p : (Fin d → ℝ) → Fin n → ℝ`,
> - a score field `score : (Fin d → ℝ) → Fin n → Fin d → ℝ`,
>
> subject to the axioms
> - **(positivity)** `p θ x > 0` for all `θ, x`;
> - **(normalization)** `∑ₓ p θ x = 1` for all `θ`;
> - **(zero-mean score)** `∑ₓ p θ x · score θ x i = 0` for all `θ, i`.

The score is to be understood as `score θ x i = ∂/∂θᵢ log p(x; θ)`, the gradient
of the log-likelihood. We carry it as data rather than deriving it via formal
differentiation, which keeps the development free of calculus prerequisites while
the zero-mean axiom encodes the one analytic fact we need.

> **Remark 2.2 (Origin of the zero-mean axiom).** Differentiating the
> normalization identity `∑ₓ p(x; θ) = 1` with respect to `θᵢ` gives
> `∑ₓ ∂ᵢ p = 0`. Since `∂ᵢ p = p · ∂ᵢ log p = p · scoreᵢ`, this is exactly
> `∑ₓ p · scoreᵢ = 0`. Thus the zero-mean property is not an extra assumption
> but the differential consequence of probability conservation; it holds for
> every smooth model.

---

## 3. The Fisher matrix is a Riemannian metric tensor

> **Definition 3.1 (Fisher information matrix).** For a model `M`, parameter `θ`,
> and indices `i, j`,
> ```
> G(θ)ᵢⱼ := fisher M θ i j = ∑ₓ p(θ,x) · score(θ,x,i) · score(θ,x,j).
> ```

This is the `p(·;θ)`-weighted second moment of the score, i.e. the expectation
`E_θ[scoreᵢ · scoreⱼ]`.

### 3.1 Symmetry

> **Theorem 3.2 (`fisher_symm`).** `G(θ)ᵢⱼ = G(θ)ⱼᵢ`.

*Proof.* Each summand `p · scoreᵢ · scoreⱼ` is symmetric under `i ↔ j` because
real multiplication is commutative; summing preserves the equality. ∎

### 3.2 The quadratic form is a sum of squares

> **Theorem 3.3 (`fisher_quadForm_eq`).** For every direction `v : Fin d → ℝ`,
> ```
> ∑ᵢ ∑ⱼ vᵢ · G(θ)ᵢⱼ · vⱼ = ∑ₓ p(θ,x) · ( ∑ᵢ vᵢ · score(θ,x,i) )².
> ```

*Proof.* Substitute the definition of `G` into the left side and expand:
```
∑ᵢ ∑ⱼ vᵢ ( ∑ₓ p · scoreᵢ · scoreⱼ ) vⱼ.
```
Interchange the order of summation to bring the sum over `x` outside (legitimate
for finite sums), factor out `p(θ,x)`, and recognize the remaining double sum
over `i, j` as a product of two identical linear forms:
```
∑ₓ p · ( ∑ᵢ vᵢ scoreᵢ )( ∑ⱼ vⱼ scoreⱼ ) = ∑ₓ p · ( ∑ᵢ vᵢ scoreᵢ )².
```
The reordering and the factorization `(∑ a)(∑ b) = ∑∑ ab` are the only steps. ∎

The inner form `s_v(x) := ∑ᵢ vᵢ · score(θ,x,i)` is the *directional score* in
direction `v`. Theorem 3.3 says the Fisher length of `v` is the second moment of
the directional score: `‖v‖²_G = E_θ[s_v²]`.

### 3.3 Positive semidefiniteness

> **Theorem 3.4 (`fisher_posSemidef`).** For every `v`,
> `0 ≤ ∑ᵢ ∑ⱼ vᵢ · G(θ)ᵢⱼ · vⱼ`.

*Proof.* By Theorem 3.3 the form equals `∑ₓ p · s_v(x)²`. Each term is a product
of a positive probability `p(θ,x) > 0` and a square `s_v(x)² ≥ 0`, hence
nonnegative; a finite sum of nonnegative terms is nonnegative. ∎

### 3.4 Positive definiteness under nondegeneracy

A direction of zero Fisher length is a first-order *unidentifiable* direction: a
parameter perturbation that does not change the likelihood of any outcome. We
exclude these.

> **Definition 3.5 (Score nondegeneracy).** A model `M` is *score-nondegenerate*
> at `θ` if the only direction annihilated by every outcome's score is zero:
> ```
> (∀x, ∑ᵢ vᵢ · score(θ,x,i) = 0) ⟹ v = 0.
> ```

> **Theorem 3.6 (`fisher_posDef`).** If `M` is score-nondegenerate at `θ`, then
> for every nonzero `v`, `0 < ∑ᵢ ∑ⱼ vᵢ · G(θ)ᵢⱼ · vⱼ`.

*Proof.* By Theorem 3.4 the form is `≥ 0`. Suppose, for contradiction, it is not
`> 0`; then it equals `0`. By Theorem 3.3, `∑ₓ p · s_v(x)² = 0`. A sum of
nonnegative terms is zero only if each term is zero, so for every `x`,
`p(θ,x) · s_v(x)² = 0`. Since `p(θ,x) > 0`, we get `s_v(x) = 0` for all `x`. By
nondegeneracy (Definition 3.5), `v = 0`, contradicting `v ≠ 0`. ∎

Theorems 3.2, 3.3, 3.4, 3.6 jointly certify that `θ ↦ G(θ)` is a symmetric,
positive-(semi)definite bilinear form on each tangent space — a Riemannian metric
tensor on the (open, identifiable locus of the) statistical manifold.

---

## 4. Bridge I: Fisher information is the covariance of the score

> **Theorem 4.1 (`fisher_eq_score_cov`).** For all `i, j`,
> ```
> G(θ)ᵢⱼ = ( ∑ₓ p·scoreᵢ·scoreⱼ ) − ( ∑ₓ p·scoreᵢ )( ∑ₓ p·scoreⱼ ).
> ```

*Proof.* The right-hand side is the covariance `Cov_θ(scoreᵢ, scoreⱼ)`. By the
zero-mean axiom, `∑ₓ p·scoreᵢ = 0` and `∑ₓ p·scoreⱼ = 0`, so the subtracted
product vanishes and the right-hand side reduces to `∑ₓ p·scoreᵢ·scoreⱼ`, which
is the definition of `G(θ)ᵢⱼ`. ∎

**Statistical reading.** The Fisher matrix is the covariance matrix of the score
vector. This is the entry point to estimation theory: the score is the gradient
that maximum-likelihood estimation follows, and its covariance controls the
sharpness of the likelihood peak. In particular, this identity is the algebraic
core of the Cramér–Rao inequality, in which `1/G(θ)` lower-bounds the variance of
unbiased estimators via Cauchy–Schwarz between the centered estimator and the
score.

---

## 5. Bridge II: Fisher information is the curvature of KL divergence

The deepest identity expresses the Fisher matrix through second derivatives of
the log-likelihood. Write `score θ x i = ∂ᵢ log p` and let `hess x = ∂ᵢ∂ⱼ log p`
denote the Hessian of the log-likelihood at outcome `x`. The chain rule for the
logarithm gives
```
∂ᵢ∂ⱼ log p = (∂ᵢ∂ⱼ p)/p − (∂ᵢ log p)(∂ⱼ log p) = secondScore − scoreᵢ·scoreⱼ,
```
where `secondScore x := (∂ᵢ∂ⱼ p)(x) / p(x)`. The regularity condition is that the
second derivatives of the probabilities sum to zero — the twice-differentiated
form of `∑ₓ p = 1`:
```
∑ₓ ∂ᵢ∂ⱼ p = 0  ⟺  ∑ₓ p · secondScore = 0.
```

> **Theorem 5.1 (`fisher_eq_neg_expected_hessian`).** Suppose
> - **(chain rule)** for all `x`, `hess x = secondScore x − score(θ,x,i)·score(θ,x,j)`, and
> - **(second regularity)** `∑ₓ p(θ,x)·secondScore x = 0`.
>
> Then `G(θ)ᵢⱼ = − ∑ₓ p(θ,x)·hess x`.

*Proof.* Multiply the chain-rule identity by `p(θ,x)` and sum over `x`:
```
∑ₓ p·hess = ∑ₓ p·secondScore − ∑ₓ p·scoreᵢ·scoreⱼ.
```
By second regularity the first term is `0`; by Definition 3.1 the second is
`G(θ)ᵢⱼ`. Hence `∑ₓ p·hess = −G(θ)ᵢⱼ`, i.e. `G(θ)ᵢⱼ = −∑ₓ p·hess`. ∎

**Geometric reading.** The quantity `−∑ₓ p(θ,x)·∂ᵢ∂ⱼ log p` is, up to sign, the
Hessian at `θ′ = θ` of the map `θ′ ↦ KL(θ‖θ′) = ∑ₓ p(θ,x) log(p(θ,x)/p(θ′,x))`,
because differentiating twice in `θ′` brings down `−∂ᵢ∂ⱼ log p(·;θ′)` weighted by
`p(·;θ)`. Therefore Theorem 5.1 is the statement
```
G(θ) = Hess_{θ′}  KL(θ‖θ′) |_{θ′=θ},
```
the **two forms of Fisher information**: the metric is simultaneously the second
moment of the score (Definition 3.1) and the negative expected Hessian of the
log-likelihood (Theorem 5.1), and the latter is the curvature of KL. The local
geometry of inference *is* the curvature of the global divergence.

---

## 6. The global companion: the Kullback–Leibler divergence

> **Definition 6.1 (KL divergence).** For `p, q : Fin n → ℝ`,
> `KL(p‖q) = ∑ₓ p(x) · log( p(x)/q(x) )`.

> **Theorem 6.2 (`KL_self_zero`).** If `p(x) ≠ 0` for all `x`, then `KL(p‖p)=0`.

*Proof.* When `q = p`, each ratio `p(x)/p(x) = 1` and `log 1 = 0`, so every
summand `p(x)·log 1 = 0` and the total is zero. ∎

> **Theorem 6.3 (Gibbs' inequality, `KL_nonneg`).** If `p(x), q(x) > 0` for all
> `x` and `∑ₓ p(x) = ∑ₓ q(x) = 1`, then `0 ≤ KL(p‖q)`.

*Proof.* Use the elementary bound `log t ≤ t − 1`, valid for all `t > 0`,
equivalently `−log t ≥ 1 − t`, with `t = q(x)/p(x) > 0`. Multiplying by
`p(x) > 0`,
```
p(x)·log( p(x)/q(x) ) = −p(x)·log( q(x)/p(x) ) ≥ p(x)·(1 − q(x)/p(x)) = p(x) − q(x).
```
Summing over `x`:
```
KL(p‖q) ≥ ∑ₓ ( p(x) − q(x) ) = 1 − 1 = 0. ∎
```

Together, Theorems 6.2 and 6.3 show KL behaves like a squared distance: zero on
the diagonal and strictly positive off it (positivity of the gap follows since
`log t < t−1` for `t ≠ 1`). The local statement of Section 5 (curvature) and the
global statement of Section 6 (a nonnegative divergence vanishing exactly on the
diagonal) are the two scales of one phenomenon: distinguishability of
distributions.

---

## 7. Worked instance: the Bernoulli model

The framework is instantiated on the one-parameter Bernoulli (biased coin) model,
`bernoulliModel`, with success probability controlled by a parameter and sample
space `Fin 2`. Carrying out Definition 3.1 in closed form yields the classical
result (`bernoulli_fisher`): the Fisher information per parameter is proportional
to `1/(σ(1−σ))`, where `σ` is the success probability. It diverges as `σ → 0` or
`σ → 1` (extreme, highly informative coins are easy to distinguish from their
neighbors) and is minimized at the fair coin `σ = 1/2` (the flattest, least
informative point of the manifold). The closed-form computation agrees with the
abstract construction, validating the definitions on a case where the answer is
known a priori.

---

## 8. Algorithms

The constructive content yields directly executable procedures (see the
accompanying `demo.py` and the `algorithms` field of the package). The principal
ones:

- **`fisher_matrix`.** Given probabilities `p[x]` and a score table
  `s[x][i]`, return the `d×d` matrix `G[i][j] = ∑ₓ p[x]·s[x][i]·s[x][j]`.
  Complexity `O(n·d²)`.

- **`quadratic_form`.** Given `G` and a direction `v`, evaluate
  `∑ᵢ∑ⱼ vᵢ G[i][j] vⱼ`, and verify Theorem 3.3 by also computing
  `∑ₓ p[x]·(∑ᵢ vᵢ s[x][i])²`. Complexity `O(d²)` (resp. `O(n·d)`).

- **`kl_divergence`.** Evaluate Definition 6.1 and verify Theorems 6.2–6.3.
  Complexity `O(n)`.

- **`scores_from_logp` / numerical Fisher–KL curvature check.** Build a score
  table by finite differences of `log p` and numerically confirm the curvature
  identity of Section 5 by twice-differentiating `θ′ ↦ KL(θ‖θ′)`.

---

## 9. Discussion

### 9.1 Relation to axiomatic information geometry

This development extends the axiomatic `MetricTensor`/Bregman picture in which a
positive-definite Fisher tensor is *assumed*. Here the tensor is *constructed*
from a probability model and its defining properties are *derived*. The payoff is
twofold: the metric axioms become theorems with explicit, finite-sum proofs, and
the bridges to covariance (Section 4) and to KL curvature (Section 5) connect the
abstract tensor to the statistical and information-theoretic quantities it is
supposed to represent.

### 9.2 Why finiteness is the right first step

On a finite sample space, expectations are finite sums, interchange of summation
is unconditional, and "differentiate under the integral" is "differentiate a
finite sum." This eliminates the analytic overhead (dominated convergence,
measurability of scores, integrability of the Hessian) that dominates the
general theory, isolating the *algebraic* skeleton: symmetry, sum-of-squares,
covariance, the chain rule, and Gibbs' inequality. The continuum theory layers
analysis on top of exactly this skeleton.

### 9.3 Scope and limitations

We carry the score and Hessian fields as data, with the zero-mean and second-
regularity conditions as hypotheses standing in for "differentiate `∑ p = 1`
once / twice." This is faithful for any smooth model but stops short of deriving
those identities from a genuine derivative. Section 10 addresses lifting them to
honest `deriv`/`fderiv` statements.

---

## 10. Future work

The following directions, carried over from the project's research agenda, are
concrete and falsifiable.

**1. The Fisher metric as the analytic Hessian of KL.** Replace the hypothesized
score/Hessian fields by genuine derivatives: take `p : ℝ → Fin n → ℝ` smooth in
`θ`, define `KL θ θ′ = ∑ₓ p θ x · log(p θ x / p θ′ x)`, and prove
`d²/ds² KL(θ‖s)|_{s=θ} = ∑ₓ p θ x · (∂ log p)²`. The two regularity hypotheses
(`chain` and `secondReg`) are then *theorems*: `∂² log p = ∂²p/p − (∂ log p)²`
and `∑ₓ ∂² p = 0`, both obtained by differentiating `∑ₓ p = 1` twice under a
finite sum. With mature one-variable calculus available (`deriv`, `HasDerivAt`,
chain rule, derivative of `log`) and a finite sample space, no measure-theoretic
machinery is required.

**2. Cramér–Rao from positive definiteness.** With `fisher_posDef` in hand,
derive the variance lower bound: for any unbiased estimator `T : Fin n → ℝ` of a
scalar functional, `Var_θ(T) ≥ 1/G(θ)`. Cramér–Rao is exactly Cauchy–Schwarz
between the centered estimator `T − E_θ[T]` and the score in the `p θ`-weighted
inner product, together with the unbiasedness identity
`E_θ[(T − E[T])·s] = 1`; both factors already live in the `StatModel`
vocabulary.

**3. Geodesics and the exponential family.** Compute the Levi-Civita connection
of the Fisher metric for exponential families and identify the dual affine
(e-/m-) connections of Amari, exhibiting the dually flat structure on which
natural-gradient methods rest.

**4. Natural gradient.** Formalize natural-gradient descent
`θ ← θ − η·G(θ)⁻¹∇L` and prove its invariance under reparametrization, the key
advantage over Euclidean gradient descent.

**5. Multi-parameter Bernoulli/categorical extensions.** Generalize the worked
instance to the categorical model on `Fin n` and to product models, deriving the
block structure of the Fisher matrix and confirming additivity of information
over independent observations.

---

## 10b. Worked numerics

The accompanying demonstrations exercise every theorem on concrete numbers. A
toy 3-outcome, 2-parameter model with a centered score field confirms symmetry
(Theorem 3.2), the exact agreement of the bilinear form and the sum-of-squares
form (Theorem 3.3) across several directions, and nonnegativity (Theorem 3.4).
A second model confirms that the mean score is numerically zero and that the
Fisher matrix coincides entry-by-entry with the score covariance (Theorem 4.1).
A Monte-Carlo sweep over one hundred thousand random distribution pairs finds the
minimum KL divergence to be nonnegative, in line with Gibbs' inequality (Theorem
6.3), while `KL(p‖p)` evaluates to exactly zero (Theorem 6.2). Finally, for the
Bernoulli model the closed-form information `1/(σ(1−σ))`, the numerically
computed second derivative of `σ′ ↦ KL(σ‖σ′)` at the diagonal, and the directly
summed second moment of the score `E_σ[score²]` all agree to four decimal places
across `σ ∈ {0.1, 0.25, 0.5, 0.75, 0.9, 0.98}`, empirically corroborating the
two-forms identity (Theorem 5.1) and the curvature interpretation of Section 5.

## 11. Conclusion

We have shown, constructively and with full rigor, that the Fisher information
matrix of a finite statistical model is a Riemannian metric — symmetric, with a
sum-of-squares quadratic form, positive semidefinite always and positive definite
under identifiability — and that it is simultaneously the covariance of the score
(the statistician's object) and the curvature of the Kullback–Leibler divergence
(the geometer's object). The bridge between statistical inference and differential
geometry is thereby realized not as analogy but as a chain of elementary,
verified theorems. Distinguishability is distance; information is geometry.
