# Idempotent Probability and Large Deviations: A Donsker–Varadhan Variational Principle for Max-Plus Measures

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Novelty (Idempotent / Tropical Probability)

---

## Abstract

We develop a theory of large deviations for *idempotent* (max-plus) probability
measures on finite outcome spaces. Replacing the field $(\mathbb{R}, +, \times)$
with the max-plus semiring $(\mathbb{R}\cup\{-\infty\}, \max, +)$ collapses
classical probability into a zero-temperature, order-theoretic calculus in which
the expectation operator is a maximum and the rate function of large-deviation
theory is simply the negative log-likelihood. Within this framework we prove an
**idempotent Donsker–Varadhan variational principle**: the max-plus integral
(idempotent free energy) of an observable $\varphi$ under a tropical probability
$P$ equals the greatest value, over all tropical probabilities $Q$, of the
$Q$-integral of $\varphi$ minus an **idempotent relative entropy**
$D(Q\,\|\,P) = \max_x\big(w_Q(x) - w_P(x)\big)$, and the maximum is attained at
$Q = P$. We establish the supporting structure: $D(P\,\|\,P)=0$, the idempotent
**Gibbs inequality** $D(Q\,\|\,P) \ge 0$, and the equality characterization
$D(Q\,\|\,P)=0 \iff w_Q \le w_P$ pointwise. We further record the idempotent
cumulant generating function and its exact $n$-fold scaling for max-plus random
walks, the idempotent Chernoff bound, the sharp idempotent large deviation
principle, the Fenchel–Young inequality, and the **finite Laplace principle**
(Maslov dequantization) with an explicit uniform rate $\log(\#X)/n$ linking the
classical exponential calculus to the idempotent one. A structural theme emerges:
the *order-theoretic* half of Cramér's program (Laplace, contraction,
Donsker–Varadhan) survives the idempotent collapse exactly and requires no
convexity, whereas the *Legendre–Fenchel* half genuinely does. All results have
been formally verified.

---

## 1. Introduction

### 1.1 Motivation

Large deviation theory quantifies the exponentially small probabilities of rare
events and identifies the *rate function* that governs their decay. Its
analytical backbone — Cramér's theorem, Varadhan's lemma, the contraction
principle, and the Donsker–Varadhan variational principle — is built on convex
duality and the interplay of the exponential map with sums of independent random
variables.

There is a parallel mathematical universe, **idempotent (tropical) analysis**, in
which the arithmetic field is replaced by the **max-plus semiring**: addition
becomes maximum and multiplication becomes addition. This is not a formal trick.
The substitution arises as a rigorous *zero-temperature limit* — Maslov
dequantization — under which $\frac1n\log\sum_x e^{n g(x)} \to \max_x g(x)$. Many
constructs of analysis and probability admit idempotent shadows obtained in
exactly this limit.

This paper asks: **what does large deviation theory look like in the max-plus
world, and which of its theorems survive the collapse?** We answer for finite
outcome spaces. The central finding is that the Donsker–Varadhan variational
principle — a result whose classical proof depends essentially on convexity — has
an exact idempotent counterpart whose proof needs only the subadditivity and
normalization of the maximum. The optimal law in the idempotent variational
problem is, surprisingly, the reference law itself: no tilting is required.

### 1.2 Contributions

1. A definition of **idempotent relative entropy**
   $D(Q\,\|\,P) = \max_x(w_Q(x) - w_P(x))$ and proof of its divergence
   properties: self-vanishing, the idempotent **Gibbs inequality**
   ($D \ge 0$), and the equality characterization $D = 0 \iff w_Q \le w_P$.
2. **Weak duality** $\int^{+}\varphi\,dQ - D(Q\,\|\,P) \le \int^{+}\varphi\,dP$
   for arbitrary test measures $Q$.
3. The **idempotent Donsker–Varadhan variational principle**, stated as an
   exact greatest-element identity with attainment at $Q = P$.
4. The **idempotent Varadhan lemma**: $\int^{+}\varphi\,dP = \max_x(\varphi(x) -
   I_P(x))$, recasting the free energy through the rate function.
5. Supporting large-deviation infrastructure: exact CGF scaling for max-plus
   random walks, the idempotent Chernoff bound, the sharp LDP, the
   Fenchel–Young inequality, and the finite Laplace principle with a uniform
   $\log(\#X)/n$ rate.
6. A conceptual separation: the order-theoretic half of Cramér's program
   survives idempotency exactly and convexity-free; the Legendre–Fenchel half
   does not.

All theorems below have been formally machine-verified.

---

## 2. The max-plus framework

Throughout, $X$ is a **finite, nonempty** type of outcomes, and $\#X$ denotes its
cardinality.

### 2.1 The max-plus semiring

The **max-plus (tropical) semiring** is $(\mathbb{R}\cup\{-\infty\},\oplus,\otimes)$
with
$$a \oplus b = \max(a,b), \qquad a \otimes b = a + b,$$
additive identity $-\infty$ and multiplicative identity $0$. Addition is
**idempotent**: $a\oplus a = a$.

### 2.2 Measures, probabilities, integration

**Definition 2.1 (Max-plus measure).** A *max-plus measure* on $X$ is a weight
function $w_P \colon X \to \mathbb{R}$. We write $P$ for the measure and $w_P$ for
its weight.

**Definition 2.2 (Tropical probability).** A max-plus measure $P$ is a *tropical
probability measure* if it is normalized:
$$\max_{x\in X} w_P(x) = 0 \qquad\text{and}\qquad w_P(x) \le 0 \ \text{ for all } x.$$
We read $w_P(x)$ as a log-likelihood on the zero-temperature scale: the modal
outcome carries weight $0$, all others are penalized.

**Definition 2.3 (Max-plus integral / idempotent free energy).** For an
observable $\varphi \colon X \to \mathbb{R}$,
$$\int^{\!+}\!\varphi\,dP \;=\; \max_{x\in X}\big(\varphi(x) + w_P(x)\big).$$
This is the idempotent expectation $\mathbb{E}^{+}_P[\varphi]$.

Two elementary properties are used repeatedly. The integral is *monotone* in
$\varphi$ and *shift-equivariant*: $\int^{+}(\varphi + c)\,dP = \int^{+}\varphi\,dP
+ c$. Pointwise it dominates each summand:
$\varphi(x) + w_P(x) \le \int^{+}\varphi\,dP$ for all $x$.

**Definition 2.4 (Product measure).** For tropical probabilities $P$ on $X$ and
$Q$ on $Y$, the *independent product* $P\otimes Q$ has weight
$w_{P\otimes Q}(x,y) = w_P(x) + w_Q(y)$, again a tropical probability.

### 2.3 Rate function and cumulant generating function

**Definition 2.5 (Rate function).** The *idempotent rate function* of $P$ is
$$I_P(x) \;=\; -\,w_P(x).$$
For a tropical probability, $I_P \ge 0$ everywhere and $\min_x I_P(x) = 0$.

**Definition 2.6 (Idempotent CGF).** For an observable $\mathrm{val}\colon X\to
\mathbb{R}$ and $\lambda \in \mathbb{R}$, the *idempotent cumulant generating
function* is
$$\Lambda_P^{\mathrm{val}}(\lambda) \;=\; \int^{\!+}\!(\lambda\cdot\mathrm{val})\,dP
\;=\; \max_{x\in X}\big(\lambda\,\mathrm{val}(x) + w_P(x)\big).$$
This is the zero-temperature analogue of $\frac1n\log\mathbb{E}[e^{\lambda S_n}]$.

### 2.4 Idempotent relative entropy

**Definition 2.7 (Idempotent relative entropy).** For max-plus measures $Q, P$,
$$D(Q\,\|\,P) \;=\; \max_{x\in X}\big(w_Q(x) - w_P(x)\big).$$
This is the max-plus surrogate for the Kullback–Leibler divergence: the
worst-case log-likelihood excess of $Q$ over $P$.

---

## 3. Properties of the idempotent relative entropy

**Theorem 3.1 (`relEnt_self`).** For any max-plus measure $P$, $D(P\,\|\,P) = 0$.

*Proof.* $D(P\,\|\,P) = \max_x(w_P(x) - w_P(x)) = \max_x 0 = 0$. $\qquad\blacksquare$

**Theorem 3.2 (Idempotent Gibbs inequality, `relEnt_nonneg`).** If $Q$ and $P$
are tropical probabilities, then $D(Q\,\|\,P) \ge 0$.

*Proof.* By normalization of $Q$, the maximum $\max_x w_Q(x) = 0$ is attained at
some $x_0$, so $w_Q(x_0) = 0$. By normalization of $P$, $w_P(x_0) \le 0$, hence
$-w_P(x_0) \ge 0$. Therefore
$$w_Q(x_0) - w_P(x_0) = 0 - w_P(x_0) \ge 0,$$
and since $D(Q\,\|\,P) = \max_x(w_Q(x) - w_P(x)) \ge w_Q(x_0) - w_P(x_0)$, the
divergence is non-negative. $\qquad\blacksquare$

This proof consumes the normalization hypotheses of *both* measures
nontrivially: the peak of $Q$ supplies the witness, and the non-positivity of
$P$ supplies the sign. The classical Gibbs inequality requires Jensen's
inequality and the strict convexity of $t\mapsto t\log t$; here it is a
consequence of where a normalized peak sits.

**Theorem 3.3 (Equality characterization, `relEnt_eq_zero_iff`).** If $Q$ and
$P$ are tropical probabilities, then
$$D(Q\,\|\,P) = 0 \iff w_Q(x) \le w_P(x) \ \text{ for all } x.$$

*Proof.* ($\Rightarrow$) If $D(Q\,\|\,P)=0$ then for every $x$,
$w_Q(x) - w_P(x) \le \max_y(w_Q(y)-w_P(y)) = 0$, i.e. $w_Q(x) \le w_P(x)$.
($\Leftarrow$) If $w_Q \le w_P$ pointwise then each difference $w_Q(x)-w_P(x)$ is
$\le 0$, so $D(Q\,\|\,P) = \max_x(w_Q(x)-w_P(x)) \le 0$; combined with
Theorem 3.2, $D(Q\,\|\,P)=0$. $\qquad\blacksquare$

---

## 4. The idempotent Donsker–Varadhan principle

### 4.1 Weak duality

**Theorem 4.1 (Weak duality, `donsker_varadhan_le`).** For any max-plus measures
$P, Q$ and any observable $\varphi$,
$$\int^{\!+}\!\varphi\,dQ \;-\; D(Q\,\|\,P) \;\le\; \int^{\!+}\!\varphi\,dP.$$

*Proof.* It suffices to show
$\int^{+}\varphi\,dQ \le \int^{+}\varphi\,dP + D(Q\,\|\,P)$. Since
$\int^{+}\varphi\,dQ = \max_x(\varphi(x) + w_Q(x))$, it is enough to bound each
term. For every $x$,
$$\varphi(x) + w_Q(x) = \big(\varphi(x) + w_P(x)\big) + \big(w_Q(x) - w_P(x)\big)
\le \int^{\!+}\!\varphi\,dP + D(Q\,\|\,P),$$
using $\varphi(x)+w_P(x) \le \int^{+}\varphi\,dP$ and $w_Q(x)-w_P(x) \le
D(Q\,\|\,P)$. Taking the maximum over $x$ gives the claim. $\qquad\blacksquare$

The proof is exactly the subadditivity of the maximum, $\max(a+b) \le \max a +
\max b$, applied to $a_x = \varphi(x)+w_P(x)$ and $b_x = w_Q(x)-w_P(x)$. No
convexity enters. The statement holds for an *arbitrary* test measure $Q$, so the
principle is non-vacuous.

### 4.2 The variational principle

**Theorem 4.2 (Idempotent Donsker–Varadhan, `idempotent_donsker_varadhan`).**
For a tropical probability $P$ and observable $\varphi$, the value
$\int^{+}\varphi\,dP$ is the greatest element of the set
$$\Big\{\, r \in \mathbb{R} \;:\; \exists\,Q,\ r = \int^{\!+}\!\varphi\,dQ - D(Q\,\|\,P)\,\Big\},$$
i.e.
$$\int^{\!+}\!\varphi\,dP \;=\; \max_{Q}\Big(\int^{\!+}\!\varphi\,dQ - D(Q\,\|\,P)\Big),$$
the maximum being attained at $Q = P$.

*Proof.* *Membership / attainment.* Taking $Q = P$ and using $D(P\,\|\,P)=0$
(Theorem 3.1) gives $\int^{+}\varphi\,dP - 0 = \int^{+}\varphi\,dP$, so the value
is in the set. *Upper bound.* For any element $r = \int^{+}\varphi\,dQ -
D(Q\,\|\,P)$, weak duality (Theorem 4.1) yields $r \le \int^{+}\varphi\,dP$.
Hence $\int^{+}\varphi\,dP$ is an upper bound that is itself attained, i.e. the
greatest element. $\qquad\blacksquare$

**Remark 4.3 (No tilting).** In classical statistical mechanics the optimal $Q$
in the Donsker–Varadhan competition is the *tilted* Gibbs measure $dQ^\star
\propto e^{\varphi}\,dP$, distinct from $P$. The idempotent supremum is instead
attained at $P$ itself. The observable $\varphi$ is absorbed into the geometry of
the maximum; the reference law is its own optimal tilt. This is a genuine
structural divergence from the classical theory, not a notational coincidence.

### 4.3 The Varadhan form

**Theorem 4.4 (Idempotent Varadhan lemma, `idempotent_varadhan_variational`).**
For a tropical probability $P$ and observable $\varphi$,
$$\int^{\!+}\!\varphi\,dP \;=\; \max_{x\in X}\big(\varphi(x) - I_P(x)\big).$$

*Proof.* By definition $I_P(x) = -w_P(x)$, so $\varphi(x) - I_P(x) = \varphi(x) +
w_P(x)$, and the maximum over $x$ of the right-hand side is exactly
$\int^{+}\varphi\,dP$. $\qquad\blacksquare$

This is the idempotent Varadhan lemma: the free energy of $\varphi$ is the
supremum of $\varphi$ discounted by the rate function — the max-plus analogue of
$\frac1n\log\mathbb{E}[e^{n\varphi}] \to \sup_x(\varphi(x) - I(x))$, here exact.

---

## 5. Large-deviation infrastructure

The variational principle of §4 sits atop a coherent large-deviation calculus.
We record the key statements; all are formally verified.

### 5.1 Exact CGF scaling for max-plus random walks

**Definition 5.1 (Max-plus random walk).** The *$n$-step walk measure* on paths
$\omega \in X^{\{0,\dots,n-1\}}$ has weight $w(\omega) = \sum_i w_P(\omega_i)$,
and the walk observable is the displacement $S_n(\omega) = \sum_i
\mathrm{val}(\omega_i)$.

**Theorem 5.2 (CGF of the walk, `idempotentCGF_walk`).** The $n$-step walk has
cumulant generating function
$$\Lambda_{\text{walk}}^{S_n}(\lambda) \;=\; n\cdot\Lambda_P^{\mathrm{val}}(\lambda).$$

*Proof sketch.* The CGF is $\max_{\omega}\sum_i(\lambda\,\mathrm{val}(\omega_i) +
w_P(\omega_i))$. A separation lemma for finite suprema over product/function
types — the maximum of a sum of independent coordinates equals the sum of the
coordinate-wise maxima — splits this into $\sum_i \max_x(\lambda\,\mathrm{val}(x)
+ w_P(x)) = n\,\Lambda_P^{\mathrm{val}}(\lambda)$. The classical identity
$\mathbb{E}[e^{\lambda S_n}] = \prod_i \mathbb{E}[e^{\lambda X_i}]$ becomes, in
logarithms and at zero temperature, an exact additive scaling proved by
rearranging a maximum. $\qquad\blacksquare$

A companion result (`idempotentCGF_add`) gives additivity of the CGF under
independent products with additive observables, the direct idempotent analogue of
the multiplicativity of moment generating functions.

### 5.2 Convexity of the CGF

**Theorem 5.3 (`idempotentCGF_convex`).** For fixed $P$ and $\mathrm{val}$, the
map $\lambda \mapsto \Lambda_P^{\mathrm{val}}(\lambda)$ is convex on $\mathbb{R}$.

*Proof sketch.* $\Lambda$ is a finite maximum of the affine functions $\lambda
\mapsto \lambda\,\mathrm{val}(x) + w_P(x)$, and a pointwise supremum of affine
functions is convex. $\qquad\blacksquare$

Moreover $\Lambda_P^{\mathrm{val}}(0) = 0$ for a tropical probability
(`idempotentCGF_zero`), matching $\frac1n\log\mathbb{E}[e^{0}] = 0$.

### 5.3 Idempotent Chernoff bound

**Theorem 5.4 (`idempotent_chernoff`).** For $\lambda \ge 0$ and any outcome $x$
in the upper-tail event $\{\mathrm{val} \ge a\}$,
$$w_P(x) \;\le\; \Lambda_P^{\mathrm{val}}(\lambda) - \lambda\,a.$$

*Proof.* For such $x$, $\lambda\,\mathrm{val}(x) \ge \lambda a$, and
$\lambda\,\mathrm{val}(x) + w_P(x) \le \Lambda_P^{\mathrm{val}}(\lambda)$, so
$w_P(x) \le \Lambda_P^{\mathrm{val}}(\lambda) - \lambda\,\mathrm{val}(x) \le
\Lambda_P^{\mathrm{val}}(\lambda) - \lambda a$. $\qquad\blacksquare$

Optimizing over $\lambda \ge 0$ recovers the exponential upper bound of classical
Cramér theory, as a finite exact inequality.

### 5.4 Sharp idempotent LDP

**Theorem 5.5 (`idempotent_ldp_sharp`).** For a nonempty event $A \subseteq X$,
with cost $\mathrm{cost}(A) := -\max_{x\in A} w_P(x)$,
$$\mathrm{cost}(A) \;=\; \min_{x\in A} I_P(x).$$

*Proof.* $-\max_{x\in A} w_P(x) = \min_{x\in A}(-w_P(x)) = \min_{x\in A}
I_P(x)$, since negation reverses suprema into infima over a finite set.
$\qquad\blacksquare$

This is the LDP made *exact*: classically $\frac1n\log P(S_n/n \in A) \to
-\inf_{x\in A} I(x)$ holds only asymptotically, but idempotency removes the
$\log/\exp$ smoothing, turning the principle into an identity for the measure
itself.

### 5.5 Fenchel–Young inequality

**Theorem 5.6 (`fenchel_young_rate`).** For every $\lambda$ and outcome $x$,
$$\lambda\,\mathrm{val}(x) - \Lambda_P^{\mathrm{val}}(\lambda) \;\le\; I_P(x).$$

*Proof.* $\lambda\,\mathrm{val}(x) + w_P(x) \le \Lambda_P^{\mathrm{val}}(\lambda)$,
so $\lambda\,\mathrm{val}(x) - \Lambda_P^{\mathrm{val}}(\lambda) \le -w_P(x) =
I_P(x)$. $\qquad\blacksquare$

This weak-duality bound underlies Cramér's theorem. Its converse — equality after
optimizing over $\lambda$ — is exactly where convexity becomes indispensable: the
biconjugate $I_P^{\star\star}(a) = \sup_\lambda(\lambda a -
\Lambda_P^{\mathrm{val}}(\lambda))$ satisfies $I_P^{\star\star} \le I_P$ always
(`lfBiconj_le_rate`) but matches $I_P$ only at tilt-exposed (supporting-line)
points (`lfBiconj_eq_rate_of_support`).

---

## 6. The Laplace bridge (Maslov dequantization)

The idempotent objects above are genuine zero-temperature limits of classical
ones, via the **finite Laplace principle**.

**Theorem 6.1 (Finite Laplace principle).** For any profile $g\colon X\to
\mathbb{R}$ on a finite type,
$$\frac{1}{n}\log\!\sum_{x\in X} e^{\,n\,g(x)} \;\xrightarrow[n\to\infty]{}\; \max_{x\in X} g(x),$$
with the explicit two-sided, *profile-independent* error bound
$$0 \;\le\; \frac{1}{n}\log\!\sum_{x\in X} e^{\,n\,g(x)} - \max_{x\in X} g(x) \;\le\; \frac{\log(\#X)}{n}.$$

*Proof sketch.* Lower bound: the sum exceeds its largest term $e^{n\max_x g}$.
Upper bound: the sum is at most $\#X \cdot e^{n\max_x g}$; taking $\frac1n\log$
gives $\max_x g + \frac{\log(\#X)}{n}$. The bound is uniform in $g$ because $\#X$
is the only data that enters. $\qquad\blacksquare$

Specializing the profile gives the dequantization of the central objects:

- $g(x) = \lambda\,\mathrm{val}(x) + w_P(x)$ yields the idempotent CGF
  $\Lambda_P^{\mathrm{val}}(\lambda)$ as the $n\to\infty$ limit of the classical
  scaled log-moment generating function.
- $g(x) = \varphi(x) + w_P(x)$ yields the max-plus integral
  $\int^{+}\varphi\,dP$ as the limit of the classical free energy — the
  idempotent Varadhan lemma at the level of dequantization.

The same log-sum-exp expression is the **softmax / log-sum-exp** of machine
learning; as temperature $1/n \to 0$ it sharpens to a hard maximum, and the
idempotent integral describes the winner-take-all regime of classification and
attention layers. The uniform $\log(\#X)/n$ rate quantifies how fast softmax
becomes argmax.

---

## 7. Discussion: which half of Cramér's program survives?

The results above reveal a clean dichotomy in how classical large-deviation
theory behaves under the idempotent collapse.

**The order-theoretic half survives exactly.** Weak duality (Theorem 4.1), the
Donsker–Varadhan principle (Theorem 4.2), the Varadhan lemma (Theorem 4.4), the
CGF scaling for walks (Theorem 5.2), and the sharp LDP (Theorem 5.5) all hold as
*exact identities* and require nothing beyond two properties of the maximum:
**subadditivity** $\max(a+b) \le \max a + \max b$ and **normalization** (the peak
weight of a tropical probability is $0$). No convexity is used anywhere. The
idempotent Gibbs inequality (Theorem 3.2) is, in the same spirit, a statement
about where a normalized peak sits.

**The Legendre–Fenchel half does not survive for free.** The identification of
the rate function as the convex conjugate of the CGF — the analytic heart of
Cramér's theorem — is genuinely a convexity statement. In the idempotent setting
the Fenchel–Young inequality (Theorem 5.6) gives only one direction; the
biconjugate $I_P^{\star\star}$ is a lower bound for $I_P$ that closes the gap only
at supporting-line (tilt-exposed) points. The duality gap is real and persistent.

The upshot is that idempotent probability functions as an analytic centrifuge,
separating the parts of large-deviation theory that are really about *order* from
the parts that are really about *curvature*. The Donsker–Varadhan principle, long
regarded as a convex-duality result, turns out to have an order-theoretic core
that the idempotent reformulation isolates and proves with elementary means.

---

## 8. Algorithms

The constructions are fully computable on finite outcome spaces. We summarize the
core procedures (Python implementations accompany this paper).

**Algorithm 8.1 (Max-plus integral).** Input: weights $w\colon X\to\mathbb{R}$,
observable $\varphi$. Output: $\int^{+}\varphi\,dP$. Compute $\max_{x}(\varphi(x)
+ w(x))$ by a single pass. Complexity $O(\#X)$.

**Algorithm 8.2 (Idempotent relative entropy).** Input: weights $w_Q, w_P$.
Output: $D(Q\,\|\,P) = \max_x(w_Q(x)-w_P(x))$, one pass, $O(\#X)$.

**Algorithm 8.3 (Donsker–Varadhan certificate).** Input: $P$, $\varphi$, a finite
family of candidate measures $\{Q_k\}$. Output: the value $\int^{+}\varphi\,dP$
together with the verification that $\int^{+}\varphi\,dQ_k - D(Q_k\,\|\,P) \le
\int^{+}\varphi\,dP$ for each $k$, with equality at $Q_k = P$. Complexity
$O(K\cdot\#X)$ for $K$ candidates.

**Algorithm 8.4 (Laplace dequantization).** Input: profile $g$, temperature
parameter $n$. Output: $\frac1n\log\sum_x e^{n g(x)}$ and the certified gap
$\le \log(\#X)/n$ from $\max_x g(x)$. A numerically stable implementation
subtracts $\max_x g$ before exponentiating. Complexity $O(\#X)$.

---

## 9. Applications

- **Optimization / dynamic programming.** The max-plus integral is a Bellman
  value function; the Donsker–Varadhan principle expresses it as a robust
  optimization over reweightings, with the reference policy optimal.
- **Statistical mechanics at zero temperature.** The framework is the
  ground-state limit of the Gibbs formalism; the variational principle becomes a
  selection of the modal configuration.
- **Machine learning.** Log-sum-exp / softmax layers dequantize to max/argmax;
  the uniform $\log(\#X)/n$ rate bounds the softmax–argmax gap, and the
  idempotent rate function measures certified margins.
- **Tropical geometry and min-plus algebra.** The walk CGF identity connects the
  LDP to tropical matrix powers and inf-convolution.

---

## 10. Future directions

See the dedicated future-directions section of the accompanying package. In brief:
(1) uniform dequantization of the *entire* rate function with the explicit
$\log(\#X)/n$ rate, via composing the Laplace principle with supporting-line
constructions; (2) identifying the Cramér rate of the max-plus walk's empirical
mean with the $n$-fold min-plus (inf-)convolution of the single-step rate,
yielding a subadditive Fekete sequence; (3) a converse to Donsker–Varadhan,
characterizing idempotent probabilities as exactly those monotone,
shift-equivariant functionals satisfying the variational identity.

---

## 11. Conclusion

We have built a self-contained theory of idempotent large deviations on finite
spaces and proved an exact Donsker–Varadhan variational principle for max-plus
probability measures, with idempotent relative entropy
$D(Q\,\|\,P) = \max_x(w_Q - w_P)$ in place of Kullback–Leibler divergence and the
remarkable feature that the variational optimum is the reference law itself. The
supporting calculus — Gibbs inequality, CGF scaling, Chernoff bound, sharp LDP,
Fenchel–Young inequality, and the finite Laplace principle with a uniform rate —
locates a precise fault line in Cramér's program: its order-theoretic half
survives the idempotent collapse exactly and convexity-free, while its
Legendre–Fenchel half does not. All results have been formally verified.
