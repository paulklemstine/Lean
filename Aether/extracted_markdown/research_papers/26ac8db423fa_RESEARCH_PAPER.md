# The Information-Geometric Bridge: Tensorization, the Cramér–Rao Bound, and the Tensorial Law of the Fisher Metric

## Abstract

We develop, in full rigor, the bridge between statistical inference and Riemannian
geometry that is provided by the **Fisher information metric** on a finite-sample
statistical model. Working over an *arbitrary finite sample space* `S` and a
parameter space `ℝ^d`, we define the statistical model, its score functions, and
the Fisher information matrix as an expectation of the outer product of scores. We
prove that the Fisher matrix is a genuine Riemannian metric tensor — it is
**symmetric**, **positive semidefinite**, and **positive definite** under a
first-order identifiability (score nondegeneracy) condition. We then establish
three results that promote the bare "Fisher is a metric" statement to the complete
toolkit of an information geometer:

1. **Tensorization (additivity of Fisher information).** For two independent models
   sharing a parameter, the Fisher matrix of the product model is the sum of the
   two Fisher matrices; in particular, `N` i.i.d. observations carry `N` times the
   single-observation information.

2. **The Cramér–Rao lower bound.** For any regular statistic `T` with mean function
   `ψ(θ) = E_θ[T]`, the variance is bounded below by `ψ'(θ)² / G(θ)`. The proof is
   a weighted Cauchy–Schwarz inequality in the score inner product whose Gram
   matrix is the Fisher metric, and equality is characterized exactly: the centered
   statistic is proportional to the score.

3. **The tensorial transformation law.** Under a smooth reparametrization with
   Jacobian `J`, the Fisher matrix transforms by congruence `G' = Jᵀ G J`,
   certifying that the Fisher metric is a genuine `(0,2)`-tensor.

Each result has been formalized and machine-checked. This paper presents the
mathematical content — definitions, theorem statements, and proof sketches — in a
self-contained form.

---

## 1. Introduction

The space of probability distributions in a parametric family is not flat. The
**Fisher information metric**, introduced by Rao building on Fisher's notion of
information, equips the parameter space of a statistical model with a Riemannian
structure in which "distance" measures *statistical distinguishability*. This
single object simultaneously:

- quantifies the precision attainable in parameter estimation (the **Cramér–Rao
  bound**);
- equals the Hessian (infinitesimal curvature) of the **Kullback–Leibler
  divergence**;
- transforms tensorially, making it a coordinate-free geometric object;
- is additive over independent observations, explaining estimator consistency.

The present work treats the *finite-sample-space* setting, where all sums are
finite and every analytic subtlety (interchange of sum and derivative, integrability)
is removed, leaving the pure algebraic and geometric skeleton fully exposed. This is
the regime of categorical models, contingency tables, and discrete channels, and it
is the natural home for a completely rigorous treatment.

We generalize the classical development from the sample space `Fin n` to an
*arbitrary finite type* `S`. This generalization is not cosmetic: it is exactly
what is required to form **product sample spaces** `S × S'` and thereby state and
prove the tensorization theorem at the level of the models themselves.

### Relation to prior structure

This development extends a base construction in which the Fisher matrix over the
sample space `Fin n` is shown to satisfy the metric axioms, together with the
identities
- `fisher = covariance of the (zero-mean) score`, and
- `fisher = − E[Hessian of the log-likelihood]` (the *two forms of Fisher
  information*), which is the local statement that the Fisher metric is the
  curvature of the KL divergence,

and the global companion facts `KL(p‖p) = 0` and `KL ≥ 0` (Gibbs' inequality). The
contributions formalized here — generality over `S`, tensorization, the Cramér–Rao
bound with its equality case, and tensoriality — complete the inference-geometry
package.

---

## 2. Definitions

Throughout, `S` and `S'` are finite types (finite sample spaces), and `d : ℕ` is
the number of parameters. All sums `Σₓ` range over the (finite) sample space.

### 2.1 Statistical models

**Definition (generalized statistical model).**
A statistical model `M` on a finite sample space `S` with parameter space `ℝ^d`
consists of:

- a probability kernel `p : ℝ^d → S → ℝ`, written `p(θ, x)`;
- a strict positivity condition `p_pos : 0 < p(θ, x)` for all `θ, x`;
- a normalization condition `p_sum : Σₓ p(θ, x) = 1` for all `θ`;
- a score map `score : ℝ^d → S → (Fin d → ℝ)`, written `score(θ, x, i)`,
  interpreted as `∂ᵢ log p(θ, x)`;
- the regularity condition `score_mean_zero`:
  `Σₓ p(θ, x) · score(θ, x, i) = 0` for all `θ, i`.

The condition `score_mean_zero` is not an extra hypothesis but a theorem about any
smooth model: since `Σₓ p(θ, x) = 1` is constant in `θ`, differentiating gives
`Σₓ ∂ᵢ p = Σₓ p · ∂ᵢ log p = 0`. We encode it as a field of the structure because
in the finite, axiomatic setting we take the scores as given data rather than as
literal derivatives.

### 2.2 The Fisher information matrix and moments

**Definition (Fisher information matrix).**
For a model `M` on `S` and parameter `θ`,
$$
G(\theta)_{ij} \;=\; \mathrm{gfisher}(M,\theta,i,j)
\;=\; \sum_{x \in S} p(\theta, x)\, \mathrm{score}(\theta, x, i)\,\mathrm{score}(\theta, x, j).
$$
This is the expectation, under `p(θ, ·)`, of the outer product of the score vector
with itself.

**Definition (expectation and variance).**
For a statistic `f : S → ℝ`,
$$
E_\theta[f] = \sum_x p(\theta,x)\, f(x), \qquad
\mathrm{Var}_\theta(f) = E_\theta\!\big[(f - E_\theta[f])^2\big].
$$

### 2.3 Identifiability

**Definition (score nondegeneracy).**
The model `M` is *score nondegenerate* at `θ` if the only direction annihilated by
every outcome's score is zero:
$$
\Big(\forall x,\ \sum_i v_i\, \mathrm{score}(\theta,x,i) = 0\Big) \;\Longrightarrow\; v = 0.
$$
Equivalently, the score vectors `{score(θ, x, ·) : x ∈ S}` span `ℝ^d`. This is the
first-order identifiability (rank) condition for the statistical manifold.

---

## 3. The metric axioms

We first record that the Fisher matrix is a Riemannian metric tensor on the
parameter space.

### 3.1 Symmetry

**Theorem (gfisher_symm).** For all `θ, i, j`,
$$
G(\theta)_{ij} = G(\theta)_{ji}.
$$

*Proof sketch.* Each summand `p(θ,x)·score(θ,x,i)·score(θ,x,j)` is invariant under
swapping `i` and `j` because real multiplication is commutative; the sum of
symmetric terms is symmetric. ∎

### 3.2 The quadratic form

**Lemma (gfisher_quadForm_eq).** For any direction `v : ℝ^d`,
$$
\sum_{i}\sum_{j} v_i\, G(\theta)_{ij}\, v_j
\;=\; \sum_x p(\theta,x)\Big(\sum_i v_i\, \mathrm{score}(\theta,x,i)\Big)^2.
$$

*Proof sketch.* Substitute the definition of `G`, interchange the order of the `i, j`
sums with the `x` sum (`Finset.sum_comm`), and factor the probability `p(θ,x)` out
of the inner double sum. The resulting inner double sum `Σᵢ Σⱼ vᵢ sᵢ sⱼ vⱼ` is the
square `(Σᵢ vᵢ sᵢ)²`. ∎

This identity is the workhorse: it re-expresses the abstract quadratic form as a
manifestly nonnegative expectation of a square.

### 3.3 Positive semidefiniteness

**Theorem (gfisher_posSemidef).** For all `θ, v`,
$$
0 \le \sum_i \sum_j v_i\, G(\theta)_{ij}\, v_j.
$$

*Proof sketch.* By `gfisher_quadForm_eq` the form equals `Σₓ p(θ,x)·(…)²`, a sum of
products of a positive probability and a square, hence nonnegative termwise. ∎

### 3.4 Positive definiteness

**Theorem (gfisher_posDef).** If `M` is score nondegenerate at `θ`, then for every
`v ≠ 0`,
$$
0 < \sum_i \sum_j v_i\, G(\theta)_{ij}\, v_j.
$$

*Proof sketch.* By semidefiniteness the form is `≥ 0`. Suppose it were `0`. Since
each summand `p(θ,x)·(Σᵢ vᵢ sᵢ)²` is nonnegative and `p(θ,x) > 0`, vanishing of the
total sum forces `Σᵢ vᵢ score(θ,x,i) = 0` for **every** `x`. Score nondegeneracy
then yields `v = 0`, contradicting `v ≠ 0`. (Formally: produce an `x` with nonzero
summand from `v ≠ 0` via nondegeneracy, then bound the whole sum below by that
single positive summand using `Finset.single_le_sum`.) ∎

Together these four statements establish that `G(θ)` is a symmetric
positive-definite bilinear form on each tangent space `ℝ^d` — a Riemannian metric.

---

## 4. Tensorization: additivity over independent data

### 4.1 The independent product model

**Definition (prodModel).** Given models `M` on `S` and `N` on `S'` sharing the
parameter space `ℝ^d`, the **independent product** `M ⊗ N` is the model on `S × S'`
with:

- probability `p_{M⊗N}(θ, (x,y)) = p_M(θ,x) · p_N(θ,y)` (factorized likelihood);
- score `score_{M⊗N}(θ, (x,y), i) = score_M(θ,x,i) + score_N(θ,y,i)` (the score of
  a product is the sum of scores, since `log` of a product is a sum).

*Well-definedness.* Positivity is the product of positives. Normalization follows
from `Σ_{x,y} p_M(x)p_N(y) = (Σ_x p_M(x))(Σ_y p_N(y)) = 1·1 = 1`. The mean-zero
condition follows because
`Σ_{x,y} p_M(x)p_N(y)(s^M_i + s^N_i)` splits into
`(Σ_x p_M s^M_i)(Σ_y p_N) + (Σ_x p_M)(Σ_y p_N s^N_i) = 0·1 + 1·0 = 0`.

### 4.2 The tensorization theorem

**Theorem (gfisher_prod_eq).** For all `θ, i, j`,
$$
G_{M\otimes N}(\theta)_{ij} \;=\; G_M(\theta)_{ij} + G_N(\theta)_{ij}.
$$

*Proof sketch.* Expand the product score
`(s^M_i + s^N_i)(s^M_j + s^N_j)` over `S × S'` into four terms and sum each against
`p_M(x) p_N(y)`:

- **Diagonal `M` term:** `(Σ_x p_M s^M_i s^M_j)(Σ_y p_N) = G_M(θ)_{ij}·1`.
- **Diagonal `N` term:** `(Σ_y p_N s^N_i s^N_j)(Σ_x p_M) = G_N(θ)_{ij}·1`.
- **Cross term 1:** `(Σ_x p_M s^M_i)(Σ_y p_N s^N_j) = 0·0 = 0` by `score_mean_zero`.
- **Cross term 2:** `(Σ_x p_M s^M_j)(Σ_y p_N s^N_i) = 0·0 = 0` by `score_mean_zero`.

The two cross terms vanish precisely because the score has zero mean — this is the
statistical content of independence. What remains is `G_M(θ)_{ij} + G_N(θ)_{ij}`. ∎

### 4.3 The i.i.d. corollary

**Corollary (gfisher_iid_two).** For two identical independent copies `M ⊗ M`,
$$
G_{M\otimes M}(\theta)_{ij} = 2\,G_M(\theta)_{ij}.
$$

By induction, `N` i.i.d. observations carry `N · G(θ)` information. This is the
statistical engine of consistency: paired with the Cramér–Rao bound below, it
forces the optimal variance to decay like `1/N` and the standard error like
`1/√N`.

---

## 5. The Cramér–Rao lower bound

### 5.1 The score inner product and Cauchy–Schwarz

Define the inner product on statistics `⟨f, g⟩_θ = E_θ[f·g] = Σₓ p(θ,x) f(x) g(x)`.
The Fisher matrix is precisely the Gram matrix of the score components in this inner
product: `G(θ)ᵢⱼ = ⟨sᵢ, sⱼ⟩_θ`.

**Lemma (expect_mul_sq_le, weighted Cauchy–Schwarz).** For statistics `f, g`,
$$
\Big(E_\theta[f\,g]\Big)^2 \;\le\; E_\theta[f^2]\; E_\theta[g^2].
$$

*Proof sketch.* This is the Cauchy–Schwarz inequality for the positive-semidefinite
bilinear form `⟨·,·⟩_θ` (weights `p(θ,x) > 0`). Concretely, the discriminant of the
nonnegative quadratic `t ↦ E_θ[(f + t g)^2] ≥ 0` must be `≤ 0`. ∎

### 5.2 The bound

Let `T : S → ℝ` be a statistic with mean function `ψ(θ) = E_θ[T]`. *Regularity*
means the derivative `ψ'(θ)` is delivered by differentiating under the sum, giving
the covariance identity
$$
\psi'(\theta) = \mathrm{Cov}_\theta(T, s_i) = E_\theta[(T - \psi)\, s_i],
$$
using `E_θ[s_i] = 0`. (In the single-parameter statement, `i` is the unique
parameter index.)

**Theorem (cramer_rao).** If `G(θ) > 0`, then for any regular statistic `T`,
$$
\boxed{\ \mathrm{Var}_\theta(T) \;\ge\; \dfrac{\psi'(\theta)^2}{G(\theta)}\ }.
$$

*Proof sketch.* Apply the weighted Cauchy–Schwarz lemma to the centered statistic
`f = T − ψ(θ)` and the score `g = s`:
$$
\psi'(\theta)^2 = \big(E_\theta[(T-\psi)\,s]\big)^2 \le E_\theta[(T-\psi)^2]\,E_\theta[s^2]
= \mathrm{Var}_\theta(T)\cdot G(\theta).
$$
Dividing by `G(θ) > 0` gives the bound. ∎

### 5.3 The unbiased case

**Corollary (cramer_rao_unbiased).** If `T` is unbiased for the parameter, `ψ(θ) = θ`
so `ψ'(θ) = 1`, then
$$
\mathrm{Var}_\theta(T) \ge \frac{1}{G(\theta)}.
$$
The inverse Fisher information is the intrinsic floor on the variance of any
unbiased estimator.

### 5.4 The equality (efficiency) case

**Theorem (cramer_rao_equality_iff).** Equality holds in the Cramér–Rao bound iff
the centered statistic is proportional to the score:
$$
\mathrm{Var}_\theta(T) = \frac{\psi'(\theta)^2}{G(\theta)}
\iff \exists\, c,\ \forall x,\ T(x) - \psi(\theta) = c\,\mathrm{score}(\theta, x).
$$

*Proof sketch.* This is the equality case of Cauchy–Schwarz: equality holds iff the
two vectors `T − ψ` and `s` are linearly dependent in the `⟨·,·⟩_θ` inner product.
The proportionality constant is `c = ψ'(θ)/G(θ)`. Estimators attaining the bound are
called **efficient**; they are exactly the linear-in-score statistics, i.e. the
exponential-family sufficient statistics. ∎

---

## 6. The tensorial transformation law

Let `φ : ℝ^d → ℝ^d` be a smooth reparametrization (a change of coordinates on the
parameter manifold) with Jacobian matrix `J(θ)ₐᵦ = ∂ φᵦ / ∂ θₐ`. By the chain rule
the scores in the new coordinates are linear combinations of the old:
`s̃_a = Σ_b J_{ab} s_b`.

**Theorem (gfisher_reparam).** The Fisher matrix transforms by congruence:
$$
G'(\theta) = J(\theta)^{\mathsf T}\, G(\theta)\, J(\theta),
\qquad\text{i.e.}\qquad
G'(\theta)_{ab} = \sum_{i,j} J_{ai}\, G(\theta)_{ij}\, J_{bj}.
$$

*Proof sketch.* Substitute `s̃_a = Σ_i J_{ai} s_i` into the definition of `G'` and
expand:
$$
G'_{ab} = \sum_x p\,\Big(\sum_i J_{ai} s_i\Big)\Big(\sum_j J_{bj} s_j\Big)
= \sum_{i,j} J_{ai}\Big(\sum_x p\, s_i s_j\Big) J_{bj} = \sum_{i,j} J_{ai} G_{ij} J_{bj}.
$$
∎

The congruence law `G' = Jᵀ G J` is the defining transformation rule of a covariant
`(0,2)`-tensor. It guarantees that all quantities built invariantly from `G` —
geodesic lengths, the Cramér–Rao bound (which transforms compatibly because `ψ`
and its derivative transform by the same Jacobian), and the scalar curvature — are
*intrinsic* to the model and independent of the chosen parametrization. This is the
differential-geometric content of the phrase "the Fisher information is a Riemannian
metric on the statistical manifold."

---

## 7. A worked instance: the Bernoulli family

To make the abstractions concrete, consider the Bernoulli model: sample space of
two outcomes, one parameter, with smooth success probability `σ(θ)` and derivative
`σ'(θ)`, where `0 < σ(θ) < 1`. Set
$$
p(0) = \sigma(\theta),\quad p(1) = 1-\sigma(\theta),\quad
s(0) = \frac{\sigma'}{\sigma},\quad s(1) = \frac{-\sigma'}{1-\sigma}.
$$
The mean-zero condition holds: `σ·(σ'/σ) + (1−σ)·(−σ'/(1−σ)) = σ' − σ' = 0`. The
Fisher information computes in closed form:
$$
G(\theta) = \sigma\Big(\frac{\sigma'}{\sigma}\Big)^2 + (1-\sigma)\Big(\frac{\sigma'}{1-\sigma}\Big)^2
= \frac{\sigma'^2}{\sigma} + \frac{\sigma'^2}{1-\sigma}
= \frac{\sigma'(\theta)^2}{\sigma(\theta)\,(1-\sigma(\theta))}.
$$
For the identity link `σ(θ) = θ` (so `σ' = 1`), this is the familiar
`G(θ) = 1/(θ(1−θ))`, and Cramér–Rao gives `Var ≥ θ(1−θ)` for any unbiased estimator
of the bias — saturated by the sample mean of `N` draws, which has variance
`θ(1−θ)/N`, matching `1/(N·G(θ))` exactly. Efficiency in action.

---

## 8. The Kullback–Leibler bridge: Fisher information as the curvature of relative entropy

The Fisher metric is not merely *a* Riemannian metric on the statistical manifold;
it is the canonical one, distinguished by its relationship to the **Kullback–Leibler
(KL) divergence**. For probability vectors `p, q` on the finite sample space with
positive entries,
$$
\mathrm{KL}(p\,\|\,q) = \sum_x p(x)\,\log\frac{p(x)}{q(x)}.
$$

**Proposition (Gibbs' inequality and the diagonal).** `KL(p‖p) = 0`, and
`KL(p‖q) ≥ 0` for all probability vectors `p, q` with positive entries.

*Proof sketch.* `KL(p‖p) = Σ p·log 1 = 0`. For nonnegativity, apply the elementary
bound `log t ≤ t − 1` (valid for `t > 0`) with `t = q(x)/p(x)`:
$$
-\mathrm{KL}(p\|q) = \sum_x p(x)\log\frac{q(x)}{p(x)} \le \sum_x p(x)\Big(\frac{q(x)}{p(x)} - 1\Big)
= \sum_x q(x) - \sum_x p(x) = 1 - 1 = 0.
$$
∎

Thus `q ↦ KL(p‖q)` attains its global minimum `0` at `q = p`. The connection to the
Fisher metric is **infinitesimal**: along a smooth parametric path `θ ↦ p(θ, ·)`, the
second-order Taylor expansion of the divergence about a base point `θ` is governed by
the Fisher matrix,
$$
\mathrm{KL}\big(p(\theta,\cdot)\,\|\,p(\theta+\delta,\cdot)\big)
= \tfrac12 \sum_{i,j} \delta_i\, G(\theta)_{ij}\, \delta_j + o(\|\delta\|^2).
$$
Equivalently, `G(θ)` is the **Hessian of the KL divergence** at the diagonal. This is
the content of the *two forms of Fisher information* identity: writing
`score = ∂ log p` and `hess = ∂² log p`, the chain rule gives
`∂_i∂_j log p = (∂_i∂_j p)/p − score_i·score_j`; multiplying by `p`, summing, and using
the second-order regularity `Σ_x ∂_i∂_j p = 0` (constancy of `Σ_x p = 1`) yields
$$
G(\theta)_{ij} = -\,E_\theta\big[\partial_i\partial_j \log p\big].
$$
The minus sign turns the (negative-definite) expected Hessian of the log-likelihood
into the (positive-definite) Fisher metric, identifying the metric with the local
curvature of relative entropy. The positive-definiteness we proved in Section 3 is
thus the local form of the strict convexity of KL at its minimum, and the
tensoriality of Section 6 is the coordinate-freeness of that curvature — KL is a
function of distributions, not of their labels, so its Hessian transforms as a
tensor.

## 9. Algorithms

The theory is constructive; the following algorithms compute its central objects for
any finite model given as numerical arrays.

**(A) Fisher matrix assembly.** Given `p(θ,·)` and `score(θ,·,·)`, compute
`G[i][j] = Σₓ p[x]·s[x][i]·s[x][j]`. Complexity `O(|S|·d²)`.

**(B) Cramér–Rao certificate.** Given a statistic `T` and the model, compute the
mean `ψ`, the covariance-with-score `ψ' = Σₓ p[x](T[x]−ψ)s[x]`, the variance, and
the Fisher information `G`; report the bound `ψ'²/G`, the achieved variance, and the
slack `Var − ψ'²/G ≥ 0`. Complexity `O(|S|·d)`.

**(C) Tensorization check.** Build the product model on `S × S'` and verify
`G_{M⊗N} = G_M + G_N` entrywise. Complexity `O(|S|·|S'|·d²)`.

**(D) Reparametrization congruence.** Given a Jacobian `J`, verify
`G' = Jᵀ G J`. Complexity `O(d³)`.

---

## 10. Applications and discussion

- **Optimal experimental design.** Maximizing a scalar functional of `G(θ)` (e.g.
  its determinant — *D-optimality*) over admissible designs minimizes estimation
  uncertainty; tensorization makes the information of a multi-experiment design
  additive and hence tractable.

- **Natural gradient and information geometry of learning.** The Fisher metric
  defines the *natural gradient* `G⁻¹ ∇L`, the steepest-descent direction in the
  intrinsic geometry; its parametrization-invariance (Section 6) is exactly why
  natural gradient is insensitive to network reparametrization.

- **Asymptotic statistics.** The combination of tensorization (`N·G`) and the
  Cramér–Rao bound (`1/G` for one sample) yields the `1/(N·G)` asymptotic variance
  of the maximum-likelihood estimator and the `√N`-consistency at the heart of
  classical asymptotic theory.

- **Quantum metrology.** The quantum Fisher information generalizes `G` and likewise
  sets, via a quantum Cramér–Rao bound, the ultimate precision of phase estimation
  in interferometers and atomic clocks; the finite, tensorial structure proved here
  is the classical shadow of that theory.

---

## 11. Future work

The natural next steps (developed at length in the package's future-directions note)
are: (1) the **multiparameter matrix Cramér–Rao bound** `Var(T) ⪰ bᵀ G⁻¹ b`, which
is the Schur-complement nonnegativity of the augmented Gram matrix
`{T − E[T], s₁, …, s_d}` and reduces to positive-semidefiniteness applied to an
augmented model; and (2) the **monotonicity of Fisher information under
coarse-graining** (data-processing): for a deterministic statistic `κ : S → S'` with
pushforward model `N`, `G_N(θ) ⪯ G_M(θ)` in the Loewner order, with equality iff `κ`
is sufficient — the information-geometric form of the data-processing inequality,
provable because the pushforward score is the conditional expectation of the
original score.

---

## 12. Conclusion

We have assembled, over an arbitrary finite sample space, the complete
information-geometric package for the Fisher metric: the Riemannian metric axioms
(symmetry, positive semidefiniteness, positive definiteness), the additivity of
information over independent data (tensorization, with the i.i.d. doubling
corollary), the Cramér–Rao lower bound and its sharp equality case via weighted
Cauchy–Schwarz, and the tensorial congruence law certifying `G` as a `(0,2)`-tensor.
Together these realize, with full rigor in the finite setting, the bridge from
statistical inference to differential geometry: the inverse Fisher metric is the
intrinsic floor on what any experiment can measure, and that floor is a piece of
geometry.
