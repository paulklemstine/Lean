# Canonical $\alpha$-Connections of Finite Exponential Families: Analytic Core, Rigidity, and Combinatorial Collapse

**Aristotle**

**Date:** 2026-08-26

---

## Abstract

We develop, for arbitrary finite exponential families, the complete analytic and structural theory of Amari's canonical one-parameter family of affine connections. Let $S$ be a finite sample space with strictly positive base weights $w$, let $T : S \to \mathbb{R}^d$ be a feature map, and let $p_\theta(x) \propto w(x)e^{\langle\theta, T(x)\rangle}$ be the associated exponential family in natural coordinates. We prove that the log-partition function is a cumulant generating function to third order, that expectations differentiate into covariances and covariances into third cumulants, and — the analytic keystone — that **the derivative of the Fisher information metric in natural coordinates is exactly the Amari–Chentsov cubic tensor**, $\partial_k g_{ij} = C_{ijk}$.

With this identity in hand, the canonical $\alpha$-connection, defined by its lower-index natural-coordinate coefficients $\Gamma^{(\alpha)}_{ij,k} = \frac{1-\alpha}{2}C_{ijk}$, acquires genuine geometric content. We prove that for *every* $\alpha$ the pair $(\nabla^{(\alpha)}, \nabla^{(-\alpha)})$ satisfies the Codazzi dual-connection compatibility equation with respect to the Fisher metric; that $e$-flatness at $\alpha = 1$ is the statement that the exponential connection carries none of the metric derivative, the dual mixture connection at $\alpha = -1$ carrying all of it; and that for $\alpha \neq 1$ a vanishing $\alpha$-coefficient is *equivalent* to stationarity of the corresponding metric component.

We then prove a **rigidity theorem**: the coefficient function $\alpha \mapsto \frac{1-\alpha}{2}$ is the unique continuous function satisfying $e$-flatness at $\alpha=1$, opposite-$\alpha$ duality, and affine increments. In particular the Levi–Civita midpoint value $F(0) = \tfrac12$ is a consequence of duality alone, not a convention, and continuity is essential (without it, Hamel-basis pathologies satisfy every algebraic axiom). We complement this with a degeneracy criterion: distinct members of the pencil have identical natural coefficients precisely when the cubic tensor vanishes identically, and the Levi–Civita member is the unique self-dual one wherever the tensor is nonzero.

Finally we give three combinatorial mechanisms that annihilate the cubic tensor and hence collapse the entire $\alpha$-pencil: a weight-preserving sign-reversing involution of the sample space (which forces $C(0) = 0$ and simultaneous flatness of all $\alpha$-connections at the origin); the exact skewness law $\kappa_3(f,f,f) = p(1-p)(1-2p)$ for an idempotent $\{0,1\}$-valued feature, yielding a sharp dichotomy between the geometric degeneracy $\alpha = 1$ and the statistical degeneracy $p = \tfrac12$; and block diagonality of the cubic tensor under independence. Exact computations for the symmetric two-point (Rademacher) family illustrate the collapse.

**Keywords:** information geometry, $\alpha$-connection, Amari–Chentsov tensor, Fisher information metric, exponential family, dual connections, Codazzi equation, cumulant generating function, Cauchy functional equation, sign-reversing involution.

---

## 1. Introduction

### 1.1 The problem of choosing a derivative

A statistical model is a family of probability distributions parameterized by a finite-dimensional coordinate. To do calculus on such a family — to differentiate a vector field, to say what a straight line is, to define a second-order Taylor expansion — one must choose an *affine connection*. Riemannian geometry offers a canonical answer: given a metric, take the Levi–Civita connection, the unique torsion-free metric-compatible one. Information geometry offers a *better* answer, and a stranger one: there is a whole one-parameter pencil of natural connections, indexed by $\alpha \in \mathbb{R}$, of which the Levi–Civita connection is merely the midpoint.

The two distinguished non-Riemannian members are the *exponential* connection $\nabla^{(1)}$ and the *mixture* connection $\nabla^{(-1)}$. They are not metric-compatible individually; instead they are *dual* to one another with respect to the Fisher metric. This duality, and not metric compatibility, is the correct structural axiom for statistics, and it is what makes the theory of dually flat spaces — with its Pythagorean theorem, its Legendre-conjugate coordinate systems, and its projection algorithms — possible.

### 1.2 What is proved here

Two logically separate things must be established before the $\alpha$-pencil is anything more than a definition.

**The analytic content.** One must show that the pencil's coefficients actually *describe the geometry* of a real family of distributions — that the object $C_{ijk}$ appearing in the formula $\Gamma^{(\alpha)}_{ij,k} = \frac{1-\alpha}{2}C_{ijk}$ is the derivative of the Fisher metric, and hence that the Codazzi equation holds. This requires genuine differentiation of expectations, covariances and third moments of an exponential family. Section 3 does this.

**The structural content.** One must show that the coefficient function $\frac{1-\alpha}{2}$ is *forced*, not chosen. Section 5 does this via a rigidity theorem of Cauchy-functional-equation type.

Section 6 then turns to combinatorics, identifying three mechanisms by which the cubic tensor — and with it the difference between all the geometries — is annihilated.

Throughout, everything is proved for an arbitrary finite sample space, arbitrary feature map, and arbitrary strictly positive base weights; there are no genericity or nondegeneracy hypotheses except where explicitly stated.

### 1.3 Notation

$S$ is a finite nonempty set, $d \in \mathbb{N}$, $w : S \to \mathbb{R}_{>0}$, $T : S \to \mathbb{R}^d$ with components $T_i(x) = T(x)_i$ for $i \in \{1,\dots,d\}$. Parameters $\theta, u \in \mathbb{R}^d$. We write $\langle u, v\rangle = \sum_i u_i v_i$.

---

## 2. The finite exponential family

### 2.1 Definitions

**Definition 2.1 (Directional score).** For $u \in \mathbb{R}^d$ the *directional score* is the observable
$$s_u(x) \;=\; \langle u, T(x)\rangle \;=\; \sum_{i=1}^d u_i\, T_i(x).$$

**Definition 2.2 (Unnormalized expectation, partition function).** For $\theta \in \mathbb{R}^d$ and $f : S \to \mathbb{R}$,
$$\widetilde{\mathbb{E}}_\theta[f] \;=\; \sum_{x \in S} w(x)\, e^{s_\theta(x)}\, f(x), \qquad Z(\theta) \;=\; \widetilde{\mathbb{E}}_\theta[\mathbf{1}] \;=\; \sum_{x\in S} w(x)e^{s_\theta(x)}.$$

**Definition 2.3 (The family).** The exponential family weights are
$$p_\theta(x) \;=\; \frac{w(x)\,e^{s_\theta(x)}}{Z(\theta)},$$
and the expectation, covariance and third joint cumulant of observables under $p_\theta$ are
$$\mathbb{E}_\theta[f] = \frac{\widetilde{\mathbb{E}}_\theta[f]}{Z(\theta)}, \qquad
\mathrm{Cov}_\theta(f,g) = \mathbb{E}_\theta[fg] - \mathbb{E}_\theta[f]\,\mathbb{E}_\theta[g],$$
$$\kappa_3^\theta(f,g,h) = \mathbb{E}_\theta\big[(f - \mathbb{E}_\theta f)(g - \mathbb{E}_\theta g)(h - \mathbb{E}_\theta h)\big].$$

**Definition 2.4 (Fisher metric and Amari–Chentsov tensor).**
$$g_{ij}(\theta) = \mathrm{Cov}_\theta(T_i, T_j), \qquad C_{ijk}(\theta) = \kappa_3^\theta(T_i, T_j, T_k).$$

**Definition 2.5 (Log-partition function).** $\psi(\theta) = \log Z(\theta)$.

### 2.2 Basic algebra

**Lemma 2.6 (Positivity).** If $w(x) > 0$ for all $x$ and $S \neq \emptyset$, then $Z(\theta) > 0$; in particular $Z(\theta) \neq 0$ and $p_\theta$, $\mathbb{E}_\theta$ are well defined.

*Proof.* Each summand $w(x)e^{s_\theta(x)}$ is a product of two strictly positive reals, and the sum over a nonempty finite set of strictly positive terms is strictly positive. $\square$

**Lemma 2.7 (Linearity).** $\widetilde{\mathbb{E}}_\theta$ is $\mathbb{R}$-linear in $f$, and $\widetilde{\mathbb{E}}_\theta[c\mathbf{1}] = c\,Z(\theta)$. Consequently $\mathbb{E}_\theta$ is linear and normalized: $\mathbb{E}_\theta[c\mathbf{1}] = c$.

*Proof.* Immediate from finiteness of the sum and Lemma 2.6 for the normalization. $\square$

**Lemma 2.8 (Score affinity).** For all $\theta, u \in \mathbb{R}^d$, $t\in\mathbb{R}$ and $x \in S$,
$$s_{\theta + tu}(x) \;=\; s_\theta(x) + t\, s_u(x).$$

*Proof.* Expand $\sum_i(\theta_i + tu_i)T_i(x)$ and split the sum. $\square$

Lemma 2.8 is the reason exponential families are analytically tractable: the entire $t$-dependence of the tilted weights along a line $\theta + tu$ is a single scalar exponential $e^{t\,s_u(x)}$ per sample point.

**Lemma 2.9 (Polarization of the third cumulant).** For all observables $f,g,h$,
$$\kappa_3^\theta(f,g,h) = \mathbb{E}_\theta[fgh] - \mathbb{E}_\theta[fg]\mathbb{E}_\theta[h] - \mathbb{E}_\theta[fh]\mathbb{E}_\theta[g] - \mathbb{E}_\theta[gh]\mathbb{E}_\theta[f] + 2\,\mathbb{E}_\theta[f]\mathbb{E}_\theta[g]\mathbb{E}_\theta[h].$$

*Proof.* Write $a = \mathbb{E}_\theta[f]$, $b = \mathbb{E}_\theta[g]$, $c = \mathbb{E}_\theta[h]$ — these are *constants*, not functions of $x$. Expanding the pointwise product $(f-a)(g-b)(h-c)$ gives a sum of eight terms, each a constant multiple of one of $fgh$, $fg$, $fh$, $gh$, $f$, $g$, $h$, $\mathbf 1$. Apply linearity and normalization (Lemma 2.7) term by term and collect. $\square$

**Corollary 2.10 (Total symmetry).** $\kappa_3^\theta$ is symmetric under all permutations of its three arguments; in particular $C_{ijk}$ is a totally symmetric $3$-tensor.

*Proof.* The right-hand side of Lemma 2.9 is manifestly invariant under exchanging any two of $f, g, h$, since pointwise multiplication of observables is commutative. Transpositions $(1\,2)$ and $(2\,3)$ generate $\mathfrak{S}_3$. $\square$

Total symmetry is not cosmetic: it is what allows the Codazzi equation below to be written with a single tensor rather than with two distinct index contractions, and it is a defining feature of the Amari–Chentsov tensor among candidate $3$-tensors on a statistical model.

---

## 3. The cumulant hierarchy: differentiation

We differentiate along the line $t \mapsto \theta + tu$ and evaluate at an arbitrary base point $t_0$; taking $t_0 = 0$ and $u = e_k$ gives partial derivatives in the natural coordinates.

**Lemma 3.1 (Derivative of an unnormalized expectation).**
$$\frac{d}{dt}\,\widetilde{\mathbb{E}}_{\theta+tu}[f] \;=\; \widetilde{\mathbb{E}}_{\theta+tu}\big[s_u \cdot f\big].$$

*Proof.* By Lemma 2.8 the $x$-th summand is $w(x)e^{s_\theta(x) + t s_u(x)}f(x)$, whose $t$-derivative is $w(x)e^{s_\theta(x)+ts_u(x)}\,s_u(x)f(x)$ by the chain rule for $t \mapsto e^{a + bt}$. Differentiating a finite sum termwise is legitimate. $\square$

Taking $f = \mathbf 1$ gives $Z'(\theta + tu) = \widetilde{\mathbb{E}}_{\theta+tu}[s_u]$.

**Theorem 3.2 (Fundamental exponential-family identity).** For every observable $f$, every direction $u$, and every base point,
$$\frac{d}{dt}\,\mathbb{E}_{\theta + tu}[f] \;=\; \mathrm{Cov}_{\theta+tu}\big(f,\, s_u\big).$$

*Proof.* Write $\mathbb{E}_{\theta+tu}[f] = \widetilde{\mathbb{E}}_{\theta+tu}[f]/Z(\theta+tu)$ and apply the quotient rule, valid since $Z > 0$ (Lemma 2.6). Using Lemma 3.1 for both numerator and denominator,
$$\frac{d}{dt}\,\frac{\widetilde{\mathbb{E}}[f]}{Z} = \frac{\widetilde{\mathbb{E}}[s_u f]\,Z - \widetilde{\mathbb{E}}[f]\,\widetilde{\mathbb{E}}[s_u]}{Z^2} = \mathbb{E}[s_u f] - \mathbb{E}[f]\mathbb{E}[s_u] = \mathrm{Cov}(f, s_u). \qquad\square$$

This single identity — *differentiating an expectation produces a covariance with the score* — generates the entire hierarchy.

**Theorem 3.3 (Cumulant generating property of $\psi$).** Along $t\mapsto \theta+tu$,
$$\frac{d}{dt}\,\psi(\theta+tu) = \mathbb{E}_{\theta+tu}[s_u], \qquad
\frac{d^2}{dt^2}\,\psi(\theta+tu) = \mathrm{Var}_{\theta+tu}(s_u) = \mathrm{Cov}_{\theta+tu}(s_u,s_u),$$
and the third derivative is $\kappa_3^{\theta+tu}(s_u,s_u,s_u)$.

*Proof.* The first equation is the chain rule for $\log$ applied to $Z$, together with $Z' = \widetilde{\mathbb{E}}[s_u]$ and $\widetilde{\mathbb{E}}[s_u]/Z = \mathbb{E}[s_u]$. The second is Theorem 3.2 with $f = s_u$. The third is Theorem 3.4 below with $f = g = s_u$. $\square$

Contracting Theorem 3.3 with coordinate directions gives the classical facts $\partial_i \psi = \eta_i := \mathbb{E}_\theta[T_i]$ (the *expectation coordinates*), $\partial_i\partial_j\psi = g_{ij}$ and $\partial_i\partial_j\partial_k\psi = C_{ijk}$. In particular $\psi$ is convex, the map $\theta \mapsto \eta$ is the gradient of a convex potential, and $(\theta, \eta)$ is a Legendre-dual coordinate pair — the substrate of the dually flat structure.

**Theorem 3.4 (Derivative of a covariance).** For all observables $f,g$,
$$\frac{d}{dt}\,\mathrm{Cov}_{\theta+tu}(f,g) \;=\; \kappa_3^{\theta+tu}\big(f, g, s_u\big).$$

*Proof.* By definition $\mathrm{Cov}(f,g) = \mathbb{E}[fg] - \mathbb{E}[f]\mathbb{E}[g]$. Applying Theorem 3.2 three times and the product rule,
$$\frac{d}{dt}\mathrm{Cov}(f,g) = \mathrm{Cov}(fg, s_u) - \mathrm{Cov}(f,s_u)\mathbb{E}[g] - \mathbb{E}[f]\,\mathrm{Cov}(g,s_u).$$
Expanding each covariance into moments and comparing with the polarization identity of Lemma 2.9 applied to the triple $(f, g, s_u)$, the two expressions agree identically: both equal
$$\mathbb{E}[fgs_u] - \mathbb{E}[fg]\mathbb{E}[s_u] - \mathbb{E}[fs_u]\mathbb{E}[g] - \mathbb{E}[gs_u]\mathbb{E}[f] + 2\mathbb{E}[f]\mathbb{E}[g]\mathbb{E}[s_u]. \qquad\square$$

**Theorem 3.5 (Metric derivative law).** *The derivative of the Fisher metric in natural coordinates is the Amari–Chentsov cubic tensor:*
$$\frac{\partial g_{ij}}{\partial\theta^k}(\theta) \;=\; C_{ijk}(\theta).$$
More generally, in an arbitrary direction $u$, $\partial_u g_{ij} = \kappa_3^\theta(T_i, T_j, s_u)$.

*Proof.* The directional statement is Theorem 3.4 with $f = T_i$, $g = T_j$. For the coordinate statement take $u = e_k$ the $k$-th standard basis vector; then $s_{e_k}(x) = \sum_l (e_k)_l T_l(x) = T_k(x)$, so $\kappa_3^\theta(T_i,T_j,s_{e_k}) = \kappa_3^\theta(T_i,T_j,T_k) = C_{ijk}$. $\square$

Theorem 3.5 is the analytic keystone. Everything in Sections 4 and 5 is a consequence of it together with pure algebra.

---

## 4. The canonical $\alpha$-pencil

### 4.1 Definition and duality

**Definition 4.1 (Canonical $\alpha$-connection, natural coordinates).** For $\alpha \in \mathbb{R}$ and a totally symmetric $3$-tensor $C$, the *lower-index natural-coordinate coefficients* of the canonical $\alpha$-connection are
$$\Gamma^{(\alpha)}_{ij,k} \;=\; \frac{1-\alpha}{2}\; C_{ijk}.$$

**Definition 4.2 (Dual connections; Codazzi equation).** Two connections with lower-index coefficients $\Gamma, \Gamma^*$ are *dual with respect to the metric $g$* if
$$\partial_k\, g_{ij} \;=\; \Gamma_{ij,k} + \Gamma^*_{ij,k}$$
for all indices. Equivalently, parallel transport by $\nabla$ of one vector and by $\nabla^*$ of another preserves their $g$-inner product.

**Theorem 4.3 (Codazzi duality of the $\alpha$-pencil).** For a finite exponential family with strictly positive weights, and for *every* $\alpha \in \mathbb{R}$,
$$\frac{\partial g_{ij}}{\partial \theta^k} \;=\; \Gamma^{(\alpha)}_{ij,k} \;+\; \Gamma^{(-\alpha)}_{ij,k}.$$
That is, $\nabla^{(\alpha)}$ and $\nabla^{(-\alpha)}$ are dual with respect to the Fisher metric.

*Proof.* Purely algebraically, $\frac{1-\alpha}{2} + \frac{1-(-\alpha)}{2} = \frac{1-\alpha}{2} + \frac{1+\alpha}{2} = 1$, so the right-hand side equals $C_{ijk}$. By Theorem 3.5 the left-hand side is also $C_{ijk}$. $\square$

The parenthetical to note is that the *entire* one-parameter family of dual pairs exists simultaneously; there is nothing special about $(\pm 1)$ from the point of view of duality alone. What distinguishes $\alpha = \pm 1$ is flatness.

### 4.2 Flatness at the endpoints

**Theorem 4.4 ($e$-flatness has content).** At $\alpha = 1$,
$$\Gamma^{(1)}_{ij,k} \;=\; 0 \quad \text{identically},$$
and consequently the whole derivative of the Fisher metric is carried by the dual mixture coefficients:
$$\frac{\partial g_{ij}}{\partial\theta^k} \;=\; \Gamma^{(-1)}_{ij,k} \;=\; C_{ijk}.$$

*Proof.* $\frac{1-1}{2} = 0$ gives the first claim. The second is Theorem 4.3 at $\alpha = 1$ combined with the first, or directly Theorem 3.5 with $\frac{1-(-1)}{2} = 1$. $\square$

Interpretively: the natural parameters $\theta$ are *affine coordinates* for $\nabla^{(1)}$. Straight lines $t\mapsto \theta_0 + tu$ are $\nabla^{(1)}$-geodesics, and the exponential family is $e$-flat. Dually, the expectation coordinates $\eta_i = \partial_i\psi$ are affine for $\nabla^{(-1)}$, and the family is $m$-flat in those coordinates; this is the geometric statement of Legendre duality between $\psi$ and its convex conjugate, the negative entropy.

**Theorem 4.5 (Sharp flatness criterion).** Fix $\alpha \neq 1$ and indices $i,j,k$. Then
$$\Gamma^{(\alpha)}_{ij,k}(\theta) = 0 \iff \frac{\partial g_{ij}}{\partial\theta^k}(\theta) = 0.$$

*Proof.* By Theorem 3.5 the right-hand condition is $C_{ijk}(\theta) = 0$. Since $\Gamma^{(\alpha)}_{ij,k} = \frac{1-\alpha}{2}C_{ijk}$ and a product of reals vanishes iff a factor does, $\Gamma^{(\alpha)}_{ij,k} = 0$ forces $\frac{1-\alpha}{2} = 0$ or $C_{ijk} = 0$; the former gives $\alpha = 1$, excluded. The converse is immediate. $\square$

Thus flatness of a *non-exponential* member of the pencil is never structural — it always reflects a genuine statistical degeneracy of the model, namely vanishing third-order structure in the relevant directions.

**Corollary 4.6 (Levi–Civita midpoint).** At $\alpha = 0$ the coefficients are $\Gamma^{(0)}_{ij,k} = \tfrac12 C_{ijk} = \tfrac12 \partial_k g_{ij}$, which is exactly the (lower-index) Levi–Civita coefficient for a metric whose derivative is a totally symmetric tensor. The $\alpha = 0$ member is self-dual: it is its own Codazzi partner, i.e. metric-compatible.

*Proof.* Self-duality is Theorem 4.3 at $\alpha = 0$, where $\Gamma^{(0)} + \Gamma^{(-0)} = 2\Gamma^{(0)} = \partial g$. Total symmetry of $C$ (Corollary 2.10) makes the three-term Christoffel expression $\tfrac12(\partial_i g_{jk} + \partial_j g_{ik} - \partial_k g_{ij})$ collapse to $\tfrac12 C_{ijk}$. $\square$

---

## 5. Rigidity: why $\frac{1-\alpha}{2}$ and nothing else

Definition 4.1 posits a coefficient function. Any function $F$ with $F(\alpha) + F(-\alpha) = 1$ would yield Codazzi-dual pairs. We now show that three structural axioms determine $F$ uniquely.

**Definition 5.1 (Admissible coefficient function).** A function $F : \mathbb{R}\to\mathbb{R}$ is *admissible* if it is continuous and:

- **(A1) $e$-flatness.** $F(1) = 0$.
- **(A2) Duality.** $F(\alpha) + F(-\alpha) = 1$ for all $\alpha$.
- **(A3) Affine increments.** $F(\alpha+\beta) = F(\alpha) + F(\beta) - F(0)$ for all $\alpha,\beta$.

Axiom (A1) says the family is $e$-flat at $\alpha = 1$: the connection at that parameter has vanishing natural coefficients. Axiom (A2) says that opposite parameters split the cubic tensor into a dual pair. Axiom (A3) says the pencil is *affine* in its parameter: the increment $F(\alpha + \beta) - F(\alpha)$ depends only on $\beta$, so the family is a one-parameter affine line in the space of connections rather than an arbitrary curve.

**Lemma 5.2 (Forced midpoint).** (A2) alone implies $F(0) = \tfrac12$.

*Proof.* Put $\alpha = 0$ in (A2): $F(0) + F(-0) = 2F(0) = 1$. $\square$

This is worth emphasizing. The Levi–Civita value $\tfrac12$ — the "midpoint identity" of the pencil — is not a normalization choice. It is the unique fixed point of the duality involution, and any dual family whatsoever must pass through it at $\alpha = 0$.

**Lemma 5.3 (Centred additivity).** Let $G(\alpha) := F(\alpha) - F(0)$. Then (A3) is equivalent to Cauchy additivity, $G(\alpha+\beta) = G(\alpha) + G(\beta)$, and $G(0) = 0$.

*Proof.* Subtract $F(0)$ from both sides of (A3). Setting $\alpha=\beta=0$ in the additive equation gives $G(0) = 2G(0)$, so $G(0)=0$. $\square$

**Theorem 5.4 (Rigidity of the canonical $\alpha$-family).** If $F$ is admissible then
$$F(\alpha) \;=\; \frac{1-\alpha}{2} \qquad \text{for all } \alpha\in\mathbb{R}.$$

*Proof.* By Lemma 5.2, $F(0) = \tfrac12$. By Lemma 5.3 the centred function $G = F - \tfrac12$ is additive, and it is continuous because $F$ is. A continuous additive function $\mathbb{R}\to\mathbb{R}$ is $\mathbb{R}$-linear: additivity gives $\mathbb{Q}$-homogeneity, $G(q\alpha) = qG(\alpha)$ for rational $q$, and continuity upgrades this to real homogeneity by density of $\mathbb{Q}$ in $\mathbb{R}$; hence $G(\alpha) = \alpha\,G(1)$. By (A1), $G(1) = F(1) - F(0) = 0 - \tfrac12 = -\tfrac12$. Therefore $F(\alpha) = \tfrac12 + \alpha\cdot(-\tfrac12) = \frac{1-\alpha}{2}$. $\square$

**Remark 5.5 (Continuity is essential).** Without a regularity hypothesis, Theorem 5.4 is false. Choose a Hamel basis of $\mathbb{R}$ as a $\mathbb{Q}$-vector space and let $L$ be any $\mathbb{Q}$-linear map with $L(1) = -\tfrac12$ that is not $\mathbb{R}$-linear; then $F = \tfrac12 + L$ satisfies (A1), (A2) and (A3) but is everywhere discontinuous and takes values dense in $\mathbb{R}$ on every interval. Such an "$\alpha$-family" is algebraically flawless and geometrically meaningless. Regularity — continuity, or equivalently measurability or local boundedness, by standard results on the Cauchy equation — is precisely the hypothesis that excludes it. Any of these weaker regularity conditions would suffice in place of continuity.

**Corollary 5.6 (Rigidity for Christoffel coefficients).** If $F$ is admissible then for every totally symmetric $3$-tensor $C$, every $\alpha$ and all indices,
$$F(\alpha)\, C_{ijk} \;=\; \Gamma^{(\alpha)}_{ij,k}.$$
That is, any structurally admissible one-parameter family of lower-index coefficients *is* the canonical $\alpha$-family.

**Theorem 5.7 (Degeneracy criterion for the pencil).** Let $C$ be a $3$-tensor and $\alpha \neq \beta$. Then
$$\big(\forall i,j,k:\ \Gamma^{(\alpha)}_{ij,k} = \Gamma^{(\beta)}_{ij,k}\big) \iff \big(\forall i,j,k:\ C_{ijk} = 0\big).$$

*Proof.* ($\Rightarrow$) Subtracting, $\left(\frac{1-\alpha}{2} - \frac{1-\beta}{2}\right)C_{ijk} = \frac{\beta-\alpha}{2}C_{ijk} = 0$ for all indices; since $\alpha\neq\beta$ the scalar factor is nonzero, so $C_{ijk}=0$. ($\Leftarrow$) Both sides are zero. $\square$

**Theorem 5.8 (Levi–Civita is the unique self-dual member).** Fix indices with $C_{ijk} \neq 0$. Then
$$\Gamma^{(\alpha)}_{ij,k} = \Gamma^{(-\alpha)}_{ij,k} \iff \alpha = 0.$$

*Proof.* The difference is $\frac{1-\alpha}{2}C_{ijk} - \frac{1+\alpha}{2}C_{ijk} = -\alpha\, C_{ijk}$, which vanishes iff $\alpha = 0$ given $C_{ijk}\neq 0$. $\square$

Together, Theorems 5.4, 5.7 and 5.8 say: *the pencil is a genuine affine line of distinct connections whose unique self-dual point is Levi–Civita, and it degenerates to a single point exactly when the model has no third-order structure.* The Amari–Chentsov tensor is the precise obstruction to the collapse of information geometry into Riemannian geometry.

---

## 6. Combinatorial collapse of the pencil

Section 5 reduces every question about the difference between $\alpha$-geometries to a question about the vanishing of $C$. We now give three combinatorial mechanisms that force this vanishing.

### 6.1 Sign-reversing involutions

**Definition 6.1.** A permutation $\sigma$ of $S$ is a *weight-preserving sign reversal* for $(w,T)$ if $w(\sigma x) = w(x)$ and $T_i(\sigma x) = -T_i(x)$ for all $x \in S$ and all $i$.

The canonical example is $S = \{-1,+1\}^n$ with uniform weights, $\sigma$ the global spin flip, and $T$ any family of odd-degree monomials in the spins.

**Lemma 6.2 (Odd observables have zero mean at the origin).** Let $\sigma$ satisfy $w(\sigma x) = w(x)$, and let $f$ be *odd* for $\sigma$, meaning $f(\sigma x) = -f(x)$. Then $\mathbb{E}_0[f] = 0$, the expectation being taken at $\theta = 0$.

*Proof.* At $\theta = 0$ the score vanishes identically, so $\widetilde{\mathbb{E}}_0[f] = \sum_x w(x)f(x)$. Reindexing the sum by the bijection $\sigma$ and using the two hypotheses,
$$\sum_x w(x)f(x) = \sum_x w(\sigma x)f(\sigma x) = \sum_x w(x)\big(-f(x)\big) = -\sum_x w(x)f(x),$$
so the sum is zero, and dividing by $Z(0) > 0$ gives $\mathbb{E}_0[f]=0$. $\square$

**Theorem 6.3 (Involution collapse).** If $\sigma$ is a weight-preserving sign reversal, then at the origin of natural coordinates the Amari–Chentsov tensor vanishes identically:
$$C_{ijk}(0) = 0 \quad\text{for all } i,j,k,$$
and consequently $\Gamma^{(\alpha)}_{ij,k}(0) = 0$ for *every* $\alpha \in \mathbb{R}$: the entire $\alpha$-pencil is flat at the symmetric point, and the exponential, mixture and Levi–Civita connections coincide there.

*Proof.* Each $T_i$ is odd for $\sigma$, so $\mathbb{E}_0[T_i] = 0$ by Lemma 6.2. The triple product $T_iT_jT_k$ satisfies $(T_iT_jT_k)(\sigma x) = (-1)^3 (T_iT_jT_k)(x)$, hence is odd, so $\mathbb{E}_0[T_iT_jT_k] = 0$ likewise. Substituting these four vanishing quantities into the polarization identity of Lemma 2.9 kills every one of its five terms: the first is $\mathbb{E}[T_iT_jT_k] = 0$, and each of the remaining four contains a factor $\mathbb{E}[T_l] = 0$. Hence $C_{ijk}(0) = 0$, and $\Gamma^{(\alpha)}_{ij,k}(0) = \frac{1-\alpha}{2}\cdot 0 = 0$. $\square$

This is a striking transfer of information: a purely *combinatorial* datum — the existence of a fixed-point-free-in-sign matching of the sample space — yields a *differential-geometric* conclusion about all connections in a continuum simultaneously.

**Example 6.4 (The symmetric two-point family).** Let $S = \{0,1\}$, $d=1$, $w \equiv 1$, and the Rademacher feature $T(0) = -1$, $T(1) = +1$. At $\theta = 0$ direct computation gives $Z(0) = 2$, $\mathbb{E}_0[T] = 0$, $\mathbb{E}_0[T^2] = 1$, hence
$$g_{11}(0) = 1, \qquad C_{111}(0) = 0.$$
The swap $\sigma = (0\ 1)$ is a weight-preserving sign reversal, so Theorem 6.3 applies and every $\alpha$-connection is flat at the origin. This is in sharp contrast to a *biased* Bernoulli family, where flatness at a given point occurs only at $\alpha = 1$ (Theorem 4.5 combined with Theorem 6.6 below).

### 6.2 Binary features and the skewness law

**Definition 6.5.** An observable $f$ is a *binary feature* if $f(x)^2 = f(x)$ for all $x$, i.e. $f$ takes values in $\{0,1\}$.

**Lemma 6.6a (Bernoulli variance).** If $f$ is binary with $p := \mathbb{E}_\theta[f]$, then $\mathrm{Cov}_\theta(f,f) = p(1-p)$.

*Proof.* $\mathbb{E}[f^2] = \mathbb{E}[f] = p$, so $\mathrm{Cov}(f,f) = p - p^2$. $\square$

**Theorem 6.6 (Skewness law of a binary feature).** If $f$ is binary with $p := \mathbb{E}_\theta[f]$, then
$$\kappa_3^\theta(f,f,f) \;=\; p\,(1-p)\,(1-2p).$$

*Proof.* Idempotence gives $f^2 = f$ and $f^3 = f$ pointwise, so all three of $\mathbb{E}[f^3], \mathbb{E}[f^2], \mathbb{E}[f]$ equal $p$. Substituting into the polarization identity (Lemma 2.9) with $f = g = h$:
$$\kappa_3 = p - 3p\cdot p + 2p^3 = p - 3p^2 + 2p^3 = p(1-p)(1-2p). \qquad\square$$

The factorization is interpretable: $p(1-p)$ is the Fisher information of the binary feature (Lemma 6.6a) and $(1-2p)$ is its *bias*, the signed distance of the mean from the unbiased value $\tfrac12$, doubled.

**Corollary 6.7 (Zero-skewness locus).** If $f$ is binary and nondegenerate ($p\neq 0$ and $p \neq 1$), then $\kappa_3^\theta(f,f,f) = 0 \iff p = \tfrac12$.

**Theorem 6.8 (Geometric/statistical dichotomy).** Let $f$ be binary and nondegenerate. Then for any $\alpha$,
$$\frac{1-\alpha}{2}\,\kappa_3^\theta(f,f,f) = 0 \iff \alpha = 1 \ \text{ or }\ p = \tfrac12.$$

*Proof.* A product of reals vanishes iff a factor does. $\frac{1-\alpha}{2} = 0$ iff $\alpha = 1$; $\kappa_3 = 0$ iff $p = \tfrac12$ by Corollary 6.7. $\square$

The dichotomy is clean and exhaustive: for a Bernoulli-type family, an $\alpha$-connection coefficient is degenerate either because the *connection* is degenerate ($\alpha = 1$, the exponential connection, whose coefficients vanish for every model) or because the *model* is degenerate ($p = \tfrac12$, the unbiased point, at which every connection's coefficients vanish). There is no third possibility, and the two loci meet exactly at $(\alpha,p) = (1,\tfrac12)$. Note that the unbiased point $p=\tfrac12$ is precisely the fixed point of the value-swapping involution $f \mapsto 1-f$, tying this mechanism back to Theorem 6.3.

### 6.3 Independence and block diagonality

**Setting 6.9.** Let $S = S_1\times S_2$ be a product of finite nonempty sets, and suppose that at the parameter $\theta$ the tilted weights factorize: there exist $W_1 : S_1\to\mathbb{R}$ and $W_2 : S_2\to\mathbb{R}$ with
$$w(z)\,e^{s_\theta(z)} \;=\; W_1(z_1)\,W_2(z_2) \qquad \text{for all } z = (z_1,z_2)\in S.$$
This holds exactly when $p_\theta$ is a product measure, i.e. when the two blocks of the model are independent at $\theta$ — the situation for a graphical model with no edges between the blocks.

**Lemma 6.10 (Factorization of unnormalized expectations).** In Setting 6.9, for $f : S_1 \to \mathbb{R}$ and $h : S_2 \to \mathbb{R}$,
$$\widetilde{\mathbb{E}}_\theta\big[f\otimes h\big] = \Big(\sum_{x\in S_1} W_1(x)f(x)\Big)\Big(\sum_{y\in S_2}W_2(y)h(y)\Big),$$
where $(f\otimes h)(z) = f(z_1)h(z_2)$.

*Proof.* Expand the sum over $S_1\times S_2$ as an iterated sum and substitute the factorization; the double sum splits as a product of sums. $\square$

**Theorem 6.11 (Independence).** In Setting 6.9, for $f : S_1\to\mathbb{R}$ and $h : S_2\to\mathbb{R}$,
$$\mathbb{E}_\theta[f\otimes h] = \mathbb{E}_\theta[f\otimes \mathbf 1]\cdot\mathbb{E}_\theta[\mathbf 1\otimes h].$$

*Proof.* Write $A_1 = \sum W_1$, $A_2 = \sum W_2$, both nonzero since $Z(\theta) = A_1A_2 > 0$. By Lemma 6.10 the left side is $\frac{(\sum W_1 f)(\sum W_2 h)}{A_1A_2}$ and the right side is $\frac{(\sum W_1 f)A_2}{A_1A_2}\cdot\frac{A_1(\sum W_2 h)}{A_1A_2}$; these agree. $\square$

**Theorem 6.12 (Block diagonality of the Amari–Chentsov tensor).** In Setting 6.9, let $f, g$ depend only on the first coordinate and $h$ only on the second. Then
$$\kappa_3^\theta(f, g, h) = 0.$$
Consequently, if the feature index set splits into blocks corresponding to the two independent factors, the cubic tensor $C_{ijk}$ vanishes whenever the indices $i,j,k$ do not all lie in the same block, and the $\alpha$-connections of a product model are the direct sums of the factor $\alpha$-connections.

*Proof.* Apply Theorem 6.11 to the three mixed pairs appearing in the polarization identity: $\mathbb{E}[fgh] = \mathbb{E}[fg]\mathbb{E}[h]$ (taking the first-coordinate observable to be $fg$), $\mathbb{E}[fh] = \mathbb{E}[f]\mathbb{E}[h]$ and $\mathbb{E}[gh] = \mathbb{E}[g]\mathbb{E}[h]$. Lemma 2.9 becomes
$$\mathbb{E}[fg]\mathbb{E}[h] - \mathbb{E}[fg]\mathbb{E}[h] - \mathbb{E}[f]\mathbb{E}[h]\mathbb{E}[g] - \mathbb{E}[g]\mathbb{E}[h]\mathbb{E}[f] + 2\mathbb{E}[f]\mathbb{E}[g]\mathbb{E}[h] = 0. \qquad\square$$

Combinatorially this says: the cubic tensor of a model *sees the dependence graph*. A feature triple spanning two independent components contributes nothing. For a graphical model on a graph $G$, only triples of features whose supports lie in a common connected component can produce nonzero tensor entries — a sparsity statement that makes the $\alpha$-geometry of large factorized models computationally tractable.

---

## 7. Algorithms

The theory above is effective: all objects are finite sums, and every theorem yields a check that can be run exactly on a finite sample space.

### 7.1 Exact evaluation of the geometric data

Given $(S, w, T, \theta)$ with $|S| = n$ and $d$ features, one computes:

1. tilted weights $\tilde p(x) = w(x)e^{\langle\theta,T(x)\rangle}$ — cost $O(nd)$;
2. normalization $Z = \sum_x \tilde p(x)$ and $p_\theta = \tilde p / Z$ — cost $O(n)$;
3. means $\mu_i = \sum_x p_\theta(x)T_i(x)$ — cost $O(nd)$;
4. Fisher metric $g_{ij} = \sum_x p_\theta(x)(T_i(x)-\mu_i)(T_j(x)-\mu_j)$ — cost $O(nd^2)$;
5. cubic tensor $C_{ijk} = \sum_x p_\theta(x)\prod_{l\in\{i,j,k\}}(T_l(x)-\mu_l)$ — cost $O(nd^3)$, reducible to $O(nd^3/6)$ by total symmetry (Corollary 2.10).

Numerical stability is improved by subtracting $\max_x \langle\theta,T(x)\rangle$ before exponentiating (the log-sum-exp trick), which changes $\tilde p$ by a positive constant factor and leaves $p_\theta$, $g$ and $C$ invariant.

### 7.2 Certifying the metric derivative law

Theorem 3.5 can be checked to machine precision by a central finite difference: for step $\varepsilon$,
$$\frac{g_{ij}(\theta+\varepsilon e_k) - g_{ij}(\theta-\varepsilon e_k)}{2\varepsilon} \;=\; C_{ijk}(\theta) + O(\varepsilon^2).$$
Choosing $\varepsilon \approx 10^{-4}$ balances truncation and round-off, giving agreement to roughly $10^{-8}$ in double precision. The same procedure certifies the Codazzi identity of Theorem 4.3 for any $\alpha$, since the right-hand side is $\frac{1-\alpha}{2}C + \frac{1+\alpha}{2}C = C$ by construction.

### 7.3 Detecting a sign-reversing involution

Given $(S, w, T)$ finite, the existence of a weight-preserving sign reversal can be decided by a matching computation: build the bipartite compatibility relation $x \sim y$ iff $w(y) = w(x)$ and $T(y) = -T(x)$, and search for a perfect matching that is an involution. When the features are injective (distinct sample points have distinct feature vectors) the candidate partner of $x$ is unique — the point with feature vector $-T(x)$ — so the check is a single pass in $O(nd)$ time using a hash table keyed on feature vectors. If the check succeeds, Theorem 6.3 certifies $C(0) = 0$ without any floating-point arithmetic.

### 7.4 Fitting the coefficient function

Theorem 5.4 gives an empirical test of admissibility. Given a candidate coefficient function sampled at points $\alpha_1,\dots,\alpha_m$, check (A1) at $\alpha=1$, (A2) on symmetric pairs, and (A3) on random pairs; if all hold to tolerance and the samples are continuous, the values must lie on the line $\frac{1-\alpha}{2}$. Deviation at any sampled point is a certificate of non-admissibility.

---

## 8. Applications and discussion

### 8.1 Why duality replaces metric compatibility

In Riemannian geometry one demands $\partial_k g_{ij} = \Gamma_{ij,k} + \Gamma_{ji,k}$ with a *single* connection, obtaining Levi–Civita. In information geometry one allows *two*: $\partial_k g_{ij} = \Gamma_{ij,k} + \Gamma^*_{ij,k}$. The gain is that both connections can be flat, in different coordinate systems, and a dually flat manifold carries a Legendre-conjugate pair of global affine coordinates $(\theta,\eta)$, a canonical divergence, and a generalized Pythagorean theorem. Theorems 4.3 and 4.4 show that finite exponential families realize this: $\theta$ is $\nabla^{(1)}$-affine, $\eta = \nabla\psi$ is $\nabla^{(-1)}$-affine, and the Kullback–Leibler divergence is the Bregman divergence of $\psi$.

### 8.2 Statistical estimation

Maximum-likelihood estimation in an exponential family is exactly moment matching, $\eta(\hat\theta) = \bar\eta_{\text{data}}$, which is $m$-projection of the empirical distribution onto the model. The EM algorithm alternates $e$- and $m$-projections; its monotone convergence is the Pythagorean theorem for the dual pair. The efficiency and higher-order asymptotics of estimators are controlled by curvature quantities built from $g$ and $C$: the leading bias term of the MLE involves contractions of $C$ with $g^{-1}$, and the $\alpha$-connection dictates how a chosen estimator's second-order behaviour transforms under reparameterization.

### 8.3 Optimization

Natural gradient descent uses the update $\theta \leftarrow \theta - \lambda\, g^{-1}\nabla L$. Its second-order correction involves the connection coefficients, hence $\frac{1-\alpha}{2}C$. Theorem 6.6 quantifies this in the binary case: the correction is proportional to $p(1-p)(1-2p)$, which is maximized in magnitude at $p = \tfrac12 \pm \tfrac{1}{2\sqrt3}$ and vanishes at $p = \tfrac12$. Practically: strongly imbalanced binary features carry large third-order structure and therefore large discrepancies between the geometries used implicitly by different optimizers — a geometric account of a familiar empirical difficulty with rare-class classification.

### 8.4 Design principle: engineer the symmetry

Theorem 6.3 is a *constructive* statement: if one can arrange the working point to admit a weight-preserving sign reversal, then all $\alpha$-geometries agree there, every $\alpha$-connection is flat, and no choice of $\alpha$ needs to be made. Standard practice — centring features, symmetrizing encodings, using $\pm1$ instead of $\{0,1\}$ codings — is exactly the pursuit of such a point. Theorem 6.12 adds the complementary principle: independence localizes the geometry, so a sparsely coupled model has a sparse cubic tensor.

### 8.5 Limitations

The results are for *finite* sample spaces. The differentiation arguments (Section 3) use termwise differentiation of a finite sum and would require dominated-convergence or local-uniform-integrability hypotheses in the continuous or countably infinite case; the algebraic content (Sections 4, 5) and the involution and independence arguments are insensitive to finiteness, but the binary-feature computation and the exact evaluations are inherently finite. No claim is made about non-exponential families, where the metric derivative law fails and the $\alpha$-connections must be defined by their $\alpha$-representations of score functions rather than by $C$ alone. Finally, the rigidity theorem constrains only the *coefficient function*; it does not by itself single out the Amari–Chentsov tensor among symmetric $3$-tensors — that is Chentsov's uniqueness theorem, a separate statement about naturality under Markov morphisms.

---

## 9. Future directions

### 9.1 Quartic rigidity: the $\alpha$-pencil beyond the cubic tensor

**Conjecture.** For a finite exponential family, the *second* derivative of the Fisher metric is the fourth cumulant $K_{ijkl}$ minus a Gauss-type quadratic correction in the third cumulants, and the resulting $\alpha$-curvature tensor vanishes identically at $\alpha = \pm1$ while being a *quadratic* — not affine — function of $\alpha$.

The key insight is that the affinity of the $\alpha$-family in $\alpha$ is a statement about lower-index Christoffel symbols only; curvature is quadratic in the connection, so the pencil $\alpha \mapsto R^{(\alpha)}$ must be a parabola whose two roots are exactly the dually flat endpoints $\alpha = \pm1$.

*Why now?* The covariance-differentiation and polarization machinery of Section 3 already differentiates arbitrary moment polynomials of a finite exponential family; the fourth-order step is the same argument applied once more, so the quadratic $\alpha$-dependence becomes a finite computation rather than a research programme.

### 9.2 Chentsov uniqueness from the involution collapse

**Conjecture.** On the simplex of a finite sample space, a totally symmetric $3$-tensor field that is (i) natural under all Markov embeddings and (ii) annihilated at every point admitting a weight-preserving sign-reversing involution is a constant multiple of the Amari–Chentsov tensor.

The key insight is that the involution theorem produces an explicit, purely combinatorial family of *zeros* of any admissible tensor, and zeros at a Zariski-dense set of symmetric points plus naturality should be enough to pin the tensor down without the usual representation-theoretic machinery.

*Why now?* Theorem 6.3 gives the zero set in closed form, and finite Markov embeddings are combinatorial maps between finite index sets, so the whole statement lives in an elementary category.

### 9.3 Skewness dichotomy for graphical (Ising-type) models

**Conjecture.** For a binary graphical model on a graph $G$ with pairwise features, the diagonal Amari–Chentsov component $C_{eee}$ attached to an edge feature $e$ obeys a skewness law generalizing Theorem 6.6, with the mean $p$ replaced by the edge marginal and a correction determined by the local structure of $G$ around $e$; in particular $C_{eee}$ vanishes at the "free" symmetric point and the whole $\alpha$-pencil collapses there, by the spin-flip instance of Theorem 6.3.

This would combine all three mechanisms of Section 6 — involution symmetry, binary skewness, and block diagonality under conditional independence — into a single structural description of the $\alpha$-geometry of Ising-type models.

---

## 10. Conclusion

The canonical $\alpha$-connections of a finite exponential family rest on two pillars, one analytic and one structural, and both have been established here.

Analytically, the Fisher metric and the Amari–Chentsov tensor are not independent objects: the second is the derivative of the first, $\partial_k g_{ij} = C_{ijk}$, a fact that follows from a single identity — differentiating an expectation of an exponential family produces a covariance with the score — applied three times. This makes the log-partition function a cumulant generating function through third order and turns the Codazzi duality of $\nabla^{(\alpha)}$ and $\nabla^{(-\alpha)}$ into the observation that $\frac{1-\alpha}{2} + \frac{1+\alpha}{2} = 1$.

Structurally, the coefficient function $\frac{1-\alpha}{2}$ is not a convention: it is the unique continuous solution of $e$-flatness at $\alpha=1$, opposite-$\alpha$ duality, and affine increments; the Levi–Civita midpoint value $\tfrac12$ is forced by duality alone; and continuity is indispensable, since dropping it admits Hamel-basis monsters satisfying every algebraic axiom.

Combinatorially, the entire distinction between the members of the pencil is carried by the third cumulant, and three mechanisms annihilate it: a weight-preserving sign-reversing involution of the sample space, an unbiased binary feature, and independence of the observables involved. In each case the exponential, mixture and Levi–Civita geometries coincide, and information geometry degenerates — exactly and only there — into ordinary Riemannian geometry.
