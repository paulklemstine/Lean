# The Fisher Information Metric on Finite Statistical Manifolds: Metric Axioms, Tensoriality, Tensorization, and the Cramér–Rao Bound

## Abstract

We develop, from first principles and in full rigor, the information geometry of
statistical models on finite sample spaces. For a model parametrized by
\(\theta \in \mathbb{R}^d\) we define the Fisher information matrix as the expected
outer product of score functions and prove that it satisfies the defining axioms of a
Riemannian metric tensor: symmetry, positive semidefiniteness, and — under a
first-order identifiability (score nondegeneracy) hypothesis — positive definiteness.
We establish the two equivalent characterizations of Fisher information (covariance of
the score; negative expected Hessian of the log-likelihood) and connect them to the
Kullback–Leibler (KL) divergence, whose nonnegativity (Gibbs' inequality) and
vanishing on the diagonal we prove, and whose Hessian at the diagonal is the Fisher
metric. Generalizing the sample space from \(\mathrm{Fin}\,n\) to an arbitrary finite
type, we prove three structural theorems that promote "Fisher is a metric" to the full
toolkit of information geometry: (i) **tensorization** — Fisher information is additive
over independent observations sharing a parameter; (ii) the **tensorial transformation
law** \(G' = J^{\mathsf T} G J\) under reparametrization, certifying that the Fisher
matrix is a genuine \((0,2)\)-tensor; and (iii) the **Cramér–Rao lower bound** with its
**equality (efficiency) characterization**, derived from a weighted Cauchy–Schwarz
inequality over the score inner product. Finally, on the categorical model we exhibit
a two-sided sandwich \(\tfrac12\|p-q\|_1^2 \le \mathrm{KL}(p\|q) \le \chi^2(p\|q)\)
identifying the Fisher quadratic form with the Pearson \(\chi^2\)-divergence and
bounding KL above by it (a global form of "Fisher = Hessian of KL") and below by the
total-variation distance (Pinsker). All results have been formally verified.

**Keywords:** Fisher information, information geometry, statistical manifold,
Riemannian metric, Cramér–Rao bound, Kullback–Leibler divergence, Pinsker inequality,
tensorization, exponential family, score function.

---

## 1. Introduction

Information geometry studies families of probability distributions as smooth
manifolds equipped with a canonical Riemannian metric — the Fisher information metric
— together with a pair of dual affine connections. The central object, the Fisher
information matrix, simultaneously plays three roles: it is the covariance of the
score function, the curvature (Hessian) of the Kullback–Leibler divergence, and the
quantity that controls the achievable variance of statistical estimators through the
Cramér–Rao inequality. These three roles unify probability theory, differential
geometry, and statistical inference.

This paper presents a complete, self-contained development of this circle of ideas on
**finite** sample spaces, where every expectation is a finite sum and no measure-
theoretic regularity is needed beyond elementary smoothness assumptions encoded as
hypotheses. Working over finite sample spaces keeps every statement elementary while
losing none of the structural content: all the metric axioms, the tensoriality, the
additivity over independent data, and the Cramér–Rao bound with its equality case hold
verbatim. We state every definition and theorem precisely and give proof sketches that
identify the single decisive idea in each case. A recurring theme is the outsized role
of the **mean-zero score identity** \(\sum_x p(x;\theta)\,s_i(x;\theta) = 0\), which
follows from normalization \(\sum_x p = 1\) and powers the covariance identity, the
vanishing of cross terms in tensorization, and the reduction of the Cramér–Rao inner
product.

### 1.1 Contributions

1. A clean axiomatic verification that the Fisher matrix is a Riemannian metric
   tensor (symmetry, positive semidefiniteness, positive definiteness under
   identifiability), via the key collapse of the metric quadratic form into a single
   probability-weighted sum of squares (Section 3).
2. The two-forms identity (covariance = negative expected Hessian) and the KL bridge:
   Gibbs' inequality and \(\mathrm{KL}(p\|p)=0\) (Section 4).
3. Tensorization / additivity of Fisher information over independent models with a
   shared parameter, with the i.i.d. corollary (Section 5).
4. The Cramér–Rao lower bound from weighted Cauchy–Schwarz, its unbiased corollary,
   and the full equality (efficiency) characterization (Section 6).
5. The tensorial transformation law \(G' = J^{\mathsf T} G J\) (Section 7).
6. On the categorical model, identification of the Fisher quadratic form with the
   Pearson \(\chi^2\)-divergence and the two-sided KL sandwich, including Pinsker's
   inequality (Section 8).
7. A worked closed-form instance: the Bernoulli family (Section 9).

---

## 2. Definitions

### 2.1 Statistical models on a finite sample space

**Definition 2.1 (Statistical model).** A *statistical model* on the finite sample
space \(\mathrm{Fin}\,n\), parametrized by \(\mathbb{R}^d\) (written \(\mathrm{Fin}\,d
\to \mathbb{R}\)), consists of:
- a likelihood \(p : \mathbb{R}^d \to \mathrm{Fin}\,n \to \mathbb{R}\) with
  \(p(\theta, x) > 0\) for all \(\theta, x\) and \(\sum_x p(\theta, x) = 1\) for all
  \(\theta\);
- a score field \(s : \mathbb{R}^d \to \mathrm{Fin}\,n \to \mathrm{Fin}\,d \to
  \mathbb{R}\), written \(s_i(x;\theta)\), satisfying the regularity identity
  \[
    \sum_x p(x;\theta)\, s_i(x;\theta) = 0 \qquad \text{for all } \theta, i.
    \tag{Mean-zero score}
  \]

The score models \(\partial_i \log p(x;\theta)\). The mean-zero identity is the
finite-sample image of \(\sum_x \partial_i p = \partial_i \sum_x p = \partial_i 1 =
0\) divided through by \(p\); we take it as a structural axiom of the model.

For Section 5 we use the same definition with the sample space replaced by an
arbitrary finite type \(S\) (a *generalized statistical model* \(\mathrm{GenStatModel}\,
S\,d\)); this is needed to form product sample spaces \(S \times S'\).

### 2.2 The Fisher information matrix

**Definition 2.2 (Fisher matrix).** The Fisher information matrix of a model \(M\) at
\(\theta\) is
\[
  G_{ij}(\theta) \;=\; \sum_x p(x;\theta)\, s_i(x;\theta)\, s_j(x;\theta), \qquad i,j \in \mathrm{Fin}\,d.
\]

**Definition 2.3 (Expectation and variance).** For a statistic \(f : S \to
\mathbb{R}\), \(\mathbb{E}_\theta[f] = \sum_x p(x;\theta)\, f(x)\) and
\(\mathrm{Var}_\theta(f) = \mathbb{E}_\theta[(f - \mathbb{E}_\theta[f])^2]\).

### 2.3 Score nondegeneracy

**Definition 2.4 (Score nondegeneracy).** A model \(M\) is *score-nondegenerate* at
\(\theta\) if the only tangent direction annihilated by every outcome's score is zero:
\[
  \Big(\forall x,\; \sum_i v_i\, s_i(x;\theta) = 0\Big) \;\Longrightarrow\; v = 0.
\]
This is the first-order identifiability (rank) condition: the scores of the distinct
outcomes span a subspace large enough that no nonzero direction is statistically
invisible.

### 2.4 Divergences

**Definition 2.5 (Kullback–Leibler divergence).** \(\mathrm{KL}(p\|q) = \sum_x p(x)\,
\log\!\big(p(x)/q(x)\big)\).

**Definition 2.6 (Categorical Fisher form).** On the open simplex over a finite index
\(\iota\), with tangent vectors \(v, w\),
\[
  g_p(v, w) \;=\; \sum_i \frac{v_i\, w_i}{p_i}.
\]
This is the score Gram form for the categorical family \(p(x;\theta) = \theta_x\),
whose score is \(\partial_i \log p = \delta/p\).

**Definition 2.7 (Pearson \(\chi^2\)-divergence).** \(\chi^2(p\|q) = \sum_i (p_i -
q_i)^2 / q_i\).

---

## 3. The metric axioms

We treat the general finite sample space \(S\); the \(\mathrm{Fin}\,n\) case is a
specialization.

**Theorem 3.1 (Symmetry).** \(G_{ij}(\theta) = G_{ji}(\theta)\).

*Proof.* Each summand \(p\, s_i\, s_j\) is symmetric in \(i, j\) because real
multiplication is commutative. \(\square\)

**Lemma 3.2 (Quadratic-form collapse).** For every \(v\),
\[
  \sum_{i}\sum_{j} v_i\, G_{ij}(\theta)\, v_j \;=\; \sum_x p(x;\theta)\Big(\sum_i v_i\, s_i(x;\theta)\Big)^2.
\]

*Proof.* Substitute the definition of \(G_{ij}\), interchange the order of summation
(Fubini for finite sums) to bring the sum over \(x\) outermost, factor out
\(p(x;\theta)\), and recognize the inner double sum \(\sum_{i,j}(v_i s_i)(v_j s_j)\)
as the square \((\sum_i v_i s_i)^2\). \(\square\)

This collapse is the technical heart of the metric axioms.

**Theorem 3.3 (Positive semidefiniteness).** \(\sum_{i,j} v_i G_{ij}(\theta) v_j \ge
0\) for all \(v\).

*Proof.* By Lemma 3.2 the form is a sum of terms \(p(x;\theta)\cdot(\cdot)^2\); each
is nonnegative since \(p > 0\) and squares are nonnegative. \(\square\)

**Theorem 3.4 (Positive definiteness under identifiability).** If \(M\) is
score-nondegenerate at \(\theta\), then \(\sum_{i,j} v_i G_{ij}(\theta) v_j > 0\) for
every \(v \neq 0\).

*Proof.* Suppose not. By Theorem 3.3 the form is \(\ge 0\), so the failure of strict
positivity forces it to equal \(0\). By Lemma 3.2, \(\sum_x p(x;\theta)(\sum_i v_i
s_i)^2 = 0\); since each summand is nonnegative and \(p(x;\theta) > 0\), every factor
\(\sum_i v_i s_i(x;\theta)\) must vanish. Nondegeneracy then yields \(v = 0\),
contradicting \(v \neq 0\). \(\square\)

**Corollary 3.5.** Theorems 3.1, 3.3, 3.4 together establish that \(G(\theta)\) is a
symmetric positive-(semi)definite bilinear form on each tangent space — a Riemannian
metric tensor on the statistical manifold (subject to the global tensoriality of
Section 7).

---

## 4. The two forms of Fisher information and the KL bridge

**Theorem 4.1 (Fisher = score covariance).**
\[
  G_{ij}(\theta) = \sum_x p\, s_i\, s_j - \Big(\sum_x p\, s_i\Big)\Big(\sum_x p\, s_j\Big).
\]

*Proof.* By the mean-zero score identity each product of means \(\big(\sum_x p
s_i\big)\big(\sum_x p s_j\big)\) is \(0\cdot 0 = 0\); the right side reduces to the
definition of \(G_{ij}\). \(\square\)

**Theorem 4.2 (Fisher = negative expected Hessian).** Suppose at \(\theta\) the chain
rule holds termwise, \(h(x) = c(x) - s_i(x;\theta)\, s_j(x;\theta)\) where \(h\)
models \(\partial_i\partial_j \log p\) and \(c\) models \((\partial_i\partial_j p)/p\),
and the second-order regularity \(\sum_x p(x;\theta)\, c(x) = 0\) holds (the image of
\(\sum_x \partial_i\partial_j p = 0\)). Then
\[
  G_{ij}(\theta) = -\sum_x p(x;\theta)\, h(x) = -\,\mathbb{E}_\theta\big[\partial_i\partial_j \log p\big].
\]

*Proof.* Multiply the chain rule by \(p\) and sum: \(\sum_x p\, h = \sum_x p\, c -
\sum_x p\, s_i s_j = 0 - G_{ij} = -G_{ij}\). \(\square\)

Geometrically, the right side is the Hessian at \(\theta' = \theta\) of \(\theta'
\mapsto \mathrm{KL}(p_\theta\|p_{\theta'})\): the Fisher metric is the curvature of KL
at its diagonal minimum.

**Theorem 4.3 (KL on the diagonal).** If \(p(x) \neq 0\) for all \(x\), then
\(\mathrm{KL}(p\|p) = 0\).

*Proof.* Each term \(p(x)\log(p(x)/p(x)) = p(x)\log 1 = 0\). \(\square\)

**Theorem 4.4 (Gibbs' inequality).** For positive probability vectors \(p, q\) with
\(\sum_x p = \sum_x q = 1\), \(\mathrm{KL}(p\|q) \ge 0\).

*Proof.* Apply \(\log t \le t - 1\) with \(t = q(x)/p(x)\): then \(p(x)\log(q(x)/p(x))
\le p(x)(q(x)/p(x) - 1) = q(x) - p(x)\). Sum over \(x\): \(-\mathrm{KL}(p\|q) \le
\sum_x q - \sum_x p = 1 - 1 = 0\), so \(\mathrm{KL}(p\|q) \ge 0\). \(\square\)

---

## 5. Tensorization: additivity over independent data

**Definition 5.1 (Independent product model).** For models \(M\) on \(S\) and \(N\)
on \(S'\) sharing parameter \(\theta\), the *product model* on \(S \times S'\) has
likelihood \(p_{M\times N}(\theta, (x,y)) = p_M(\theta, x)\, p_N(\theta, y)\) and score
\(s_{M \times N}((x,y);\theta)_i = s_M(x;\theta)_i + s_N(y;\theta)_i\) (the log-
likelihood being additive). One verifies positivity, normalization (\(\sum_{x,y}
p_M p_N = (\sum_x p_M)(\sum_y p_N) = 1\)), and the mean-zero score property of the
product (each summand factors and uses the mean-zero property of one factor with
\(\sum p = 1\) of the other).

**Theorem 5.2 (Tensorization / additivity).**
\[
  G_{M \times N}(\theta)_{ij} = G_M(\theta)_{ij} + G_N(\theta)_{ij}.
\]

*Proof.* Expand
\[
  \sum_{x,y} p_M(x) p_N(y)\,(s_M(x)_i + s_N(y)_i)(s_M(x)_j + s_N(y)_j)
\]
into four terms. The two diagonal terms are \(\big(\sum_x p_M s_{M,i} s_{M,j}\big)\big(
\sum_y p_N\big) = G_M{}_{ij}\) and symmetrically \(G_N{}_{ij}\), using \(\sum p = 1\)
in the complementary factor. Each cross term factors as \(\big(\sum_x p_M s_{M,i}\big)
\big(\sum_y p_N s_{N,j}\big)\), a product containing a mean-zero score sum, hence
\(0\). \(\square\)

**Corollary 5.3 (i.i.d., \(k=2\)).** \(G_{M\times M}(\theta)_{ij} = 2\, G_M(\theta)_
{ij}\): two independent copies carry twice the information. By induction (not formalized
here) \(k\) i.i.d. observations carry \(k\) times the information — the statistical
basis of estimator consistency.

---

## 6. The Cramér–Rao lower bound

**Lemma 6.1 (Weighted Cauchy–Schwarz).** For any statistics \(a, b : S \to
\mathbb{R}\),
\[
  \big(\mathbb{E}_\theta[a\,b]\big)^2 \le \mathbb{E}_\theta[a^2]\,\mathbb{E}_\theta[b^2].
\]

*Proof.* Apply the discrete Cauchy–Schwarz inequality to the vectors \(x \mapsto
\sqrt{p(x;\theta)}\,a(x)\) and \(x \mapsto \sqrt{p(x;\theta)}\,b(x)\), using
\((\sqrt{p})^2 = p\) (valid as \(p > 0\)). \(\square\)

This is precisely Cauchy–Schwarz for the inner product whose Gram matrix is the Fisher
information.

**Theorem 6.2 (Cramér–Rao bound, single parameter).** Let \(T : S \to \mathbb{R}\) be
a statistic with \(\psi(\theta) = \mathbb{E}_\theta[T]\) and the regularity identity
\(\psi'(\theta) = \mathbb{E}_\theta[T \cdot s_0]\) (interchange of differentiation and
expectation). Then
\[
  \psi'(\theta)^2 \le \mathrm{Var}_\theta(T)\cdot G(\theta)_{00},
\]
equivalently \(\mathrm{Var}_\theta(T) \ge \psi'(\theta)^2 / G(\theta)_{00}\) when
\(G_{00} > 0\).

*Proof.* Let \(a(x) = T(x) - \mathbb{E}_\theta[T]\) and \(b(x) = s_0(x;\theta)\). By the
mean-zero score identity, \(\mathbb{E}_\theta[a\,b] = \mathbb{E}_\theta[T s_0] -
\mathbb{E}_\theta[T]\,\mathbb{E}_\theta[s_0] = \psi' - \mathbb{E}_\theta[T]\cdot 0 =
\psi'\). Also \(\mathbb{E}_\theta[a^2] = \mathrm{Var}_\theta(T)\) and
\(\mathbb{E}_\theta[b^2] = G(\theta)_{00}\). Lemma 6.1 gives the bound. \(\square\)

**Corollary 6.3 (Unbiased estimator).** If \(\mathbb{E}_\theta[T \cdot s_0] = 1\)
(the \(\psi' = 1\) case of an unbiased estimator of \(\theta_0\)), then
\(\mathrm{Var}_\theta(T)\cdot G(\theta)_{00} \ge 1\), i.e. \(\mathrm{Var}_\theta(T) \ge
1/G(\theta)_{00}\).

**Theorem 6.4 (Efficiency: equality case).** Assume \(G(\theta)_{00} > 0\) and the
regularity identity of Theorem 6.2. Then equality \(\psi'(\theta)^2 =
\mathrm{Var}_\theta(T)\cdot G(\theta)_{00}\) holds **iff** the centered statistic is
proportional to the score: there exists \(c \in \mathbb{R}\) with
\[
  T(x) - \mathbb{E}_\theta[T] = c\, s_0(x;\theta) \quad \text{for all } x.
\]

*Proof.* (\(\Rightarrow\)) Set \(c = \psi'/G_{00}\) and expand the nonnegative quantity
\(\mathbb{E}_\theta[(a - c\,b)^2] = \mathrm{Var}(T) - 2c\,\psi' + c^2 G_{00} =
\mathrm{Var}(T) - \psi'^2/G_{00}\), which equals \(0\) by hypothesis. As a sum of
nonnegative terms \(p(x)(a(x) - c\,b(x))^2\) with \(p(x) > 0\), each term vanishes,
giving \(a(x) = c\, b(x)\) pointwise. (\(\Leftarrow\)) Substituting \(a = c\,b\) gives
\(\mathrm{Var}(T) = c^2 G_{00}\) and \(\psi' = c\,G_{00}\), whence \(\psi'^2 = c^2
G_{00}^2 = \mathrm{Var}(T)\,G_{00}\). \(\square\)

Statistically, equality singles out one-parameter exponential families with \(T\) as
the natural sufficient statistic — the *efficient* estimators that attain the bound.

---

## 7. The tensorial transformation law

**Theorem 7.1 (Reparametrization congruence).** Let \(M\) be a model on \(S\) with
parameter \(\theta \in \mathbb{R}^d\), and \(M'\) a model on \(S\) with parameter
\(\eta \in \mathbb{R}^{d'}\) such that the likelihoods agree, \(p_{M'}(\eta, x) =
p_M(\theta, x)\), and the scores transform by the chain rule with Jacobian \(J : \mathrm
{Fin}\,d' \to \mathrm{Fin}\,d \to \mathbb{R}\),
\(s_{M'}(x;\eta)_a = \sum_i J_{ai}\, s_M(x;\theta)_i\). Then
\[
  G_{M'}(\eta)_{ab} = \sum_i \sum_j J_{ai}\, G_M(\theta)_{ij}\, J_{bj}, \qquad \text{i.e. } G' = J^{\mathsf T} G\, J.
\]

*Proof.* Substitute the transformed scores into \(G_{M'}{}_{ab} = \sum_x p_{M'}\,
s_{M'}{}_a\, s_{M'}{}_b\), use \(p_{M'} = p_M\), expand the product of the two finite
sums over \(i, j\), and pull the constants \(J_{ai}, J_{bj}\) outside the sum over
\(x\), recognizing \(\sum_x p_M\, s_{M,i}\, s_{M,j} = G_M{}_{ij}\). \(\square\)

This congruence is exactly the transformation law of a \((0,2)\)-tensor; combined with
Section 3 it certifies that the Fisher matrix is a coordinate-independent Riemannian
metric, not an artifact of parametrization.

---

## 8. The categorical model and the KL sandwich

On the open simplex over finite \(\iota\) we use the Fisher form \(g_p(v,w) = \sum_i
v_i w_i / p_i\) (Definition 2.6).

**Theorem 8.1 (Metric axioms for \(g_p\)).** \(g_p\) is symmetric (\(g_p(v,w) =
g_p(w,v)\)), bilinear (additive and homogeneous in each slot), positive semidefinite
(\(g_p(v,v) \ge 0\) for \(p > 0\)), and positive definite (\(g_p(v,v) = 0 \iff v = 0\)
for \(p > 0\)).

*Proof.* Symmetry and bilinearity are termwise algebra. Nonnegativity:
\(v_i^2/p_i \ge 0\). Definiteness: a sum of nonnegative terms vanishes iff each
\(v_i^2/p_i = 0\), i.e. \(v = 0\). \(\square\)

**Theorem 8.2 (\(\chi^2\) = Fisher quadratic form).** \(\chi^2(p\|q) = g_q(p-q, p-q)\).

*Proof.* Termwise, \((p_i - q_i)^2/q_i = (p-q)_i (p-q)_i / q_i\). \(\square\)

**Theorem 8.3 (Upper bound: KL \(\le\) Fisher form).** For positive probability
vectors with \(\sum p = \sum q = 1\),
\[
  \mathrm{KL}(p\|q) \le g_q(p-q, p-q) = \chi^2(p\|q) = \sum_i \frac{(p_i - q_i)^2}{q_i}.
\]

*Proof.* Apply \(\log t \le t - 1\) with \(t = p_i/q_i\): \(p_i \log(p_i/q_i) \le p_i
(p_i/q_i - 1)\). Sum, and observe \(\sum_i p_i(p_i/q_i - 1) = \sum_i (p_i - q_i)^2/q_i
+ \sum_i (p_i - q_i) = \chi^2(p\|q) + 0\) using normalization. Conclude via Theorem
8.2. \(\square\)

This is a genuine, non-infinitesimal realization of "Fisher metric = Hessian of KL":
the Fisher quadratic form at the displacement \(p - q\) dominates KL globally.

**Theorem 8.4 (Lower bound: Pinsker's inequality).** Under the same hypotheses,
\[
  \tfrac12\Big(\sum_i |p_i - q_i|\Big)^2 \le \mathrm{KL}(p\|q).
\]

*Proof sketch.* Reduce the finite case to the Bernoulli (two-point) Pinsker inequality
by the log-sum / data-processing inequality: partition outcomes by the sign of
\(p_i - q_i\), apply the binary bound to the coarse-grained two-cell distribution, and
use that coarse-graining cannot increase KL. The binary case is the elementary
calculus inequality \(\mathrm{KL}(\mathrm{Bern}(a)\|\mathrm{Bern}(b)) \ge 2(a-b)^2\).
\(\square\)

**Corollary 8.5 (Two-sided sandwich).** Combining Theorems 8.3 and 8.4,
\[
  \tfrac12\|p - q\|_1^2 \;\le\; \mathrm{KL}(p\|q) \;\le\; \chi^2(p\|q),
\]
controlling KL between the \(L^1\) (total-variation) and Fisher (\(\chi^2\)) worlds.

---

## 9. A worked instance: the Bernoulli family

**Definition 9.1 (Bernoulli model).** Sample space \(\mathrm{Fin}\,2\), one parameter,
with smooth success probability \(\sigma(\theta_0) \in (0,1)\) and derivative
\(\sigma'\):
\[
  p(0) = \sigma,\quad p(1) = 1 - \sigma,\quad s(0) = \frac{\sigma'}{\sigma},\quad s(1) = \frac{-\sigma'}{1-\sigma}.
\]
Positivity, normalization, and the mean-zero score identity (\(\sigma\cdot\sigma'/\sigma
+ (1-\sigma)\cdot(-\sigma'/(1-\sigma)) = \sigma' - \sigma' = 0\)) all hold.

**Theorem 9.2 (Bernoulli Fisher information).**
\[
  G(\theta)_{00} = \frac{\sigma'(\theta_0)^2}{\sigma(\theta_0)\,(1 - \sigma(\theta_0))}.
\]

*Proof.* Directly, \(G_{00} = \sigma\,(\sigma'/\sigma)^2 + (1-\sigma)\,(\sigma'/(1-\sigma))^2
= \sigma'^2/\sigma + \sigma'^2/(1-\sigma) = \sigma'^2/(\sigma(1-\sigma))\). \(\square\)

The denominator \(\sigma(1-\sigma)\) is the variance of the Bernoulli outcome:
information peaks where the outcome is most predictable and the parameter moves the
odds fastest, and the Cramér–Rao bound (Section 6) reads \(\mathrm{Var}(\hat\sigma)
\ge \sigma(1-\sigma)\) for an unbiased estimator of \(\sigma\) (taking \(\sigma(\theta)
= \theta\), \(\sigma' = 1\)).

---

## 10. Algorithms

The constructive content of the theory yields directly executable algorithms over
finite models. We summarize three (full pseudocode and code appear in the companion
material).

**A. Fisher matrix assembly.** Given arrays \(p[\,\cdot\,]\) and \(s[\,\cdot\,][\,\cdot\,]\),
compute \(G_{ij} = \sum_x p[x]\, s[x][i]\, s[x][j]\) in \(O(n d^2)\) time. The output is
symmetric by construction (Theorem 3.1).

**B. Cramér–Rao bound check.** Given a statistic \(T\), compute \(\mathbb{E}[T]\),
\(\mathrm{Var}(T)\), \(\psi' = \mathbb{E}[T\,s_0]\), and report the bound
\(\psi'^2/G_{00}\) and the efficiency residual \(\mathrm{Var}(T) - \psi'^2/G_{00} \ge 0\),
with equality flagged when \(T - \mathbb{E}[T] \propto s_0\) (Theorem 6.4). Complexity
\(O(n)\).

**C. KL sandwich evaluation.** For probability vectors \(p, q\), compute the total-
variation, KL, and \(\chi^2\) quantities and verify \(\tfrac12\|p-q\|_1^2 \le
\mathrm{KL} \le \chi^2\) numerically (Corollary 8.5). Complexity \(O(n)\).

---

## 11. Applications

- **Experiment design and sample-size calculation.** Tensorization (Section 5) makes
  the information of \(k\) i.i.d. observations equal to \(k\) times the single-sample
  information, so the Cramér–Rao bound scales as \(1/(k\,G)\); inverting this gives the
  number of observations needed to reach a target precision.
- **Fundamental precision limits.** The Cramér–Rao bound sets instrument-independent
  floors on estimation error in metrology, signal processing, and physics (e.g.
  parameter estimation in detectors), computable before any apparatus is built.
- **Natural-gradient optimization.** The Fisher metric is the preconditioner of
  natural gradient descent; its reparametrization invariance (Section 7) is exactly
  why natural gradient steps are independent of the model's coordinate choice, a
  desirable property in training probabilistic and machine-learning models.
- **Model comparison and concentration.** The KL sandwich (Section 8) converts between
  total-variation, KL, and \(\chi^2\) distances, the workhorse inequalities of
  concentration of measure and statistical learning theory.

---

## 12. Discussion

The development isolates a single algebraic fact — the mean-zero score identity — as
the common cause of seemingly distinct phenomena: the covariance interpretation
(Theorem 4.1), the vanishing of cross terms in tensorization (Theorem 5.2), and the
reduction of the Cramér–Rao inner product (Theorem 6.2). Likewise a single analytic
fact, \(\log t \le t - 1\), powers both Gibbs' inequality and the KL upper bound
(Theorems 4.4 and 8.3). The metric axioms hinge entirely on the quadratic-form
collapse (Lemma 3.2), which turns a double sum over parameter pairs into a single
probability-weighted sum of squares — making nonnegativity and the definiteness
dichotomy transparent. Finiteness of the sample space lets us prove everything with
elementary finite sums while preserving the full structural content of information
geometry.

---

## 13. Future work

Several deep extensions are natural and within reach of the present framework:

1. **The Loewner matrix Cramér–Rao bound \(\Sigma \succeq A G^{-1} A^{\mathsf T}\).**
   The directional/bilinear bound \((u^{\mathsf T} A w)^2 \le (u^{\mathsf T}\Sigma u)(
   w^{\mathsf T} G w)\) for a vector statistic with covariance \(\Sigma\) and
   sensitivity \(A\) should, on optimizing over \(w = G^{-1}A^{\mathsf T} u\), yield the
   full matrix bound \(\Sigma - A G^{-1} A^{\mathsf T} \succeq 0\), equivalently the
   Schur-complement positivity of the joint covariance \(\begin{psmallmatrix}\Sigma &
   A\\ A^{\mathsf T} & G\end{psmallmatrix}\). Equality recovers vector efficiency,
   generalizing Theorem 6.4. Positive definiteness of \(G\) (Theorem 3.4) supplies the
   needed invertibility.

2. **Chentsov monotonicity (data-processing for the Fisher metric).** Coarse-graining
   a model by a statistic \(T\) (pushing forward to \(T_*M\) with the conditional-
   expectation score \(\mathbb{E}[s \mid T]\)) should never increase Fisher information:
   \(G(T_*M) \preceq G(M)\) in the Loewner order. The equality case should characterize
   *sufficient statistics*: \(G(T_*M)(\theta) = G(M)(\theta)\) iff the score is
   \(T\)-measurable, the local form of the Fisher–Neyman factorization. The proof
   reduces to a fibrewise Cauchy–Schwarz defect, localizing the argument of Theorem 6.4
   to each fiber \(T^{-1}(y)\).

3. **From deterministic statistics to Markov kernels.** Replace deterministic
   coarse-graining by stochastic channels and prove the corresponding monotonicity,
   linking the Fisher metric to the broader theory of monotone metrics (Chentsov's
   uniqueness theorem) and to quantum generalizations.

---

## 14. Conclusion

We have given a complete, self-contained, and formally verified account of the Fisher
information metric on finite statistical manifolds: the metric axioms, the two-forms
identity, the KL bridge, additivity over independent data, tensoriality under
reparametrization, the Cramér–Rao bound with its efficiency characterization, and the
two-sided KL sandwich on the categorical model. The recurring lesson is that the
statistician's "how much can be learned?" and the geometer's "how curved is this
surface?" are one question, answered by one matrix — the Fisher information.
