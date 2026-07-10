# The Algebraic Geometry of Neural Decision Boundaries: A Tropical Framework

**Author:** Aristotle
**Date:** 2026-07-10

## Abstract

A feed-forward neural network with rectified-linear (ReLU) activations computes a piecewise linear function $f : \mathbb{R}^n \to \mathbb{R}^m$. For a binary classifier $f : \mathbb{R}^n \to \mathbb{R}$, the decision boundary $\{x : f(x) = 0\}$ is a piecewise linear hypersurface. We show that this boundary is precisely a *tropical hypersurface* — the piecewise linear skeleton of an algebraic variety in the max-plus semiring — and we identify the exact algebraic laws that control its complexity. Our central objects are *tropical polynomials* (pointwise maxima of affine monomials) and *tropical rational functions* (their differences). We prove that a tropical polynomial is always convex, continuous, and piecewise linear; that the pointwise maximum of two tropical polynomials is a tropical polynomial whose monomial family is the *disjoint union* of the two (so monomial counts **add**); and that their pointwise sum is a tropical polynomial whose monomial family is the *Cartesian product* of the two (so monomial counts **multiply**). We derive the pointwise ReLU identity $\max(p-q,0) = \max(p,q) - q$, which shows that each rectifying layer at most doubles the numerator monomial count of the tropical rational function computed by the network. Two combinatorial consequences follow: the algebraic degree of the boundary is bounded by $2^L$ for a network of depth $L$, and the number of linear regions is bounded by $2^L \prod_i w_i$ for layer widths $w_i$. We further characterize the decision boundary as the closed equalizer set $\{x : p(x) = q(x)\}$, describe its singular locus as a multiplicity-of-argmax condition, and outline curvature-free robustness certificates that follow from convexity.

**Keywords:** ReLU networks, tropical geometry, decision boundaries, max-plus algebra, piecewise linear functions, tropical hypersurface, linear regions, VC dimension.

---

## 1. Introduction

Neural networks with rectified-linear activations are, mathematically, compositions of affine maps and coordinatewise maxima with zero. Such compositions are piecewise linear, and a substantial literature studies the number of *linear regions* they induce as a proxy for expressive power. Separately, *tropical geometry* studies the combinatorial "shadows" of algebraic varieties obtained by replacing ordinary addition and multiplication with maximum and addition, respectively. The two subjects meet at a single observation: a piecewise linear convex function is exactly a tropical polynomial, and a general ReLU-computable function is a difference of two such — a tropical rational function.

This paper develops the algebraic structure underlying that correspondence and proves the growth laws that govern the complexity of a classifier's decision boundary. The results are stated for tropical polynomials over an arbitrary nonempty finite index set of monomials, so they apply uniformly to any layer width and depth.

Our contributions are:

1. **Structural regularity.** Every tropical polynomial is a convex, continuous, piecewise linear function, with each monomial lying below it and the maximum attained by some monomial (Section 3).
2. **The addition law.** The pointwise maximum of two tropical polynomials is a tropical polynomial whose monomial index set is the disjoint union of the two; monomial counts add (Section 4).
3. **The multiplication law.** The pointwise sum of two tropical polynomials is a tropical polynomial whose monomial index set is the Cartesian product of the two; monomial counts multiply (Section 4).
4. **The ReLU identity and layerwise doubling.** The identity $\max(p-q,0) = \max(p,q)-q$ shows a ReLU maps the tropical rational $p \ominus q$ to $\max(p,q) \ominus q$, at most doubling the numerator monomial count, yielding the $2^L$ degree bound and the $2^L\prod_i w_i$ region bound (Section 5).
5. **Boundary geometry.** The decision boundary is the closed set $\{p = q\}$; its sign is governed by the dominant monomial family, and its singular locus is a multiplicity-of-argmax stratum (Section 6).

---

## 2. The tropical semiring and tropical polynomials

### 2.1 The max-plus semiring

The *max-plus (tropical) semiring* is $(\mathbb{R} \cup \{-\infty\}, \oplus, \odot)$ with
$$a \oplus b := \max(a, b), \qquad a \odot b := a + b.$$
Tropical addition is idempotent ($a \oplus a = a$), tropical multiplication distributes over it, $-\infty$ is the additive identity, and $0$ is the multiplicative identity. A *tropical monomial* in variables $x = (x_1,\dots,x_n)$ with integer (or, here, real) exponent vector $w \in \mathbb{R}^n$ and coefficient $a \in \mathbb{R}$ evaluates, in ordinary arithmetic, to the affine function
$$a \odot x_1^{\odot w_1} \odot \cdots \odot x_n^{\odot w_n} = a + \langle w, x\rangle.$$

### 2.2 Tropical polynomials

**Definition 2.1 (Tropical polynomial).** Let $n \in \mathbb{N}$ and let $\mathcal{I}$ be a nonempty finite index set. Given coefficients $a : \mathcal{I} \to \mathbb{R}$ and exponent (weight) vectors $w : \mathcal{I} \to \mathbb{R}^n$, the associated *tropical polynomial* is the function $p : \mathbb{R}^n \to \mathbb{R}$,
$$p(x) = \bigoplus_{i \in \mathcal{I}} \Big( a_i \odot \prod_j x_j^{\odot w_{ij}} \Big) = \max_{i \in \mathcal{I}} \Big( a_i + \sum_{j=1}^n w_{ij}\, x_j \Big).$$

Each summand $m_i(x) = a_i + \langle w_i, x\rangle$ is an affine *monomial*. The polynomial is the upper envelope of finitely many affine functions.

**Definition 2.2 (Tropical rational function).** A *tropical rational function* is a difference $f = p \ominus q := p - q$ of two tropical polynomials $p$ and $q$. We call $p$ the *numerator* and $q$ the *denominator*.

**Definition 2.3 (Tropical hypersurface).** The *tropical hypersurface* of a tropical polynomial $p$ is the set of points where the maximum defining $p$ is attained by at least two distinct monomials — the non-smooth locus of $p$. For a tropical rational $f = p \ominus q$, the associated *variety* is the equalizer $\{x : p(x) = q(x)\} = \{x : f(x) = 0\}$.

---

## 3. Structural regularity of tropical polynomials

Throughout, fix $n \in \mathbb{N}$ and a nonempty finite index set $\mathcal{I}$, with data $a : \mathcal{I} \to \mathbb{R}$ and $w : \mathcal{I} \to \mathbb{R}^n$, and write $p(x) = \max_{i} (a_i + \langle w_i, x\rangle)$.

**Lemma 3.1 (Monomial lower bound).** For every $x$ and every $i \in \mathcal{I}$,
$$a_i + \langle w_i, x\rangle \le p(x).$$

*Proof.* Immediate from the definition of the maximum: each element of a finite family is at most its supremum. $\square$

**Lemma 3.2 (Attainment).** For every $x$ there exists $i \in \mathcal{I}$ with $p(x) = a_i + \langle w_i, x\rangle$.

*Proof.* The family $\{a_i + \langle w_i, x\rangle\}_{i \in \mathcal{I}}$ is finite and nonempty, hence attains its maximum at some index. $\square$

**Theorem 3.3 (Convexity).** $p$ is convex on $\mathbb{R}^n$.

*Proof.* Each monomial $m_i(x) = a_i + \langle w_i, x\rangle$ is affine, hence convex. For $x, y \in \mathbb{R}^n$ and weights $\alpha, \beta \ge 0$ with $\alpha + \beta = 1$, fix any index $i$. By affineness, $m_i(\alpha x + \beta y) = \alpha\, m_i(x) + \beta\, m_i(y) \le \alpha\, p(x) + \beta\, p(y)$ using Lemma 3.1. Taking the maximum over $i$ on the left gives $p(\alpha x + \beta y) \le \alpha p(x) + \beta p(y)$. $\square$

**Theorem 3.4 (Continuity).** $p$ is continuous.

*Proof.* $p$ is the pointwise maximum of finitely many affine (hence continuous) functions. A finite maximum of continuous functions is continuous: at any point $x$, one may check the two one-sided order conditions. For a threshold $y < p(x)$, pick a maximizing index $i$ (Lemma 3.2); the affine function $m_i$ exceeds $y$ on an open neighborhood, and $p \ge m_i$ there. For a threshold $y > p(x)$, every $m_i(x) < y$, and each affine $m_i$ stays below $y$ on a neighborhood; the finite intersection of these neighborhoods keeps $p < y$. $\square$

Together, Theorems 3.3 and 3.4 establish that a tropical polynomial is a convex, continuous, piecewise linear function — the geometry of an upper envelope of hyperplanes.

---

## 4. The two growth laws

The complexity of a ReLU network's boundary is governed by how the number of monomials evolves under two operations: pointwise maximum (produced by rectification) and pointwise sum (produced by composing independent contributions).

Let $\mathcal{I}, \mathcal{J}$ be nonempty finite index sets with tropical-polynomial data $(a_1, w_1)$ over $\mathcal{I}$ and $(a_2, w_2)$ over $\mathcal{J}$, defining $p_1(x) = \max_{i\in\mathcal I}(a_1(i) + \langle w_1(i), x\rangle)$ and $p_2(x) = \max_{k\in\mathcal J}(a_2(k) + \langle w_2(k), x\rangle)$.

**Theorem 4.1 (Addition law — tropical addition / ReLU law).** The pointwise maximum of two tropical polynomials is a tropical polynomial whose monomial family is the disjoint union of the two:
$$\max\big(p_1(x), p_2(x)\big) = \max_{k \in \mathcal{I} \sqcup \mathcal{J}} \big( \tilde a_k + \langle \tilde w_k, x\rangle\big),$$
where $(\tilde a, \tilde w)$ restricts to $(a_1, w_1)$ on the $\mathcal{I}$-summand and to $(a_2, w_2)$ on the $\mathcal{J}$-summand. In particular the monomial count of the maximum is $|\mathcal{I}| + |\mathcal{J}|$.

*Proof.* ($\le$) $\max(p_1,p_2)$ equals whichever of $p_1, p_2$ is larger; by Lemma 3.2 that value is attained by some monomial of the corresponding family, which is one of the monomials of the disjoint union. ($\ge$) Every monomial of the disjoint union is a monomial of either $p_1$ or $p_2$, hence bounded above by $p_1$ or $p_2$ respectively (Lemma 3.1), hence by $\max(p_1,p_2)$; taking the maximum over the disjoint union preserves the inequality. $\square$

**Theorem 4.2 (Multiplication law — tropical multiplication).** The pointwise sum of two tropical polynomials is a tropical polynomial whose monomial family is the Cartesian product of the two:
$$p_1(x) + p_2(x) = \max_{(i,k) \in \mathcal{I}\times\mathcal{J}} \Big( \big(a_1(i) + a_2(k)\big) + \big\langle w_1(i) + w_2(k),\, x\big\rangle \Big).$$
In particular the monomial count of the sum is $|\mathcal{I}| \cdot |\mathcal{J}|$.

*Proof.* ($\le$) Choose maximizing indices $i^\star$ for $p_1(x)$ and $k^\star$ for $p_2(x)$ (Lemma 3.2). Then $p_1(x) + p_2(x)$ equals the $(i^\star, k^\star)$ monomial of the product family, which is at most the maximum over the product. ($\ge$) For any $(i,k)$, the product monomial equals $m^{(1)}_i(x) + m^{(2)}_k(x) \le p_1(x) + p_2(x)$ by Lemma 3.1 applied to each factor; taking the maximum over $(i,k)$ preserves the bound. $\square$

These two theorems are the arithmetic core: **rectification (max) adds monomial counts; composition (sum) multiplies them.** Both identities are exact and independent of the numerical weights.

---

## 5. ReLU on tropical rational functions and layerwise doubling

A ReLU network computes a tropical rational function $f = p \ominus q$. The following pointwise identity is the algebraic engine of layerwise complexity growth.

**Lemma 5.1 (ReLU identity).** For all real $p, q$,
$$\max(p - q,\, 0) = \max(p, q) - q.$$

*Proof.* If $p \ge q$ then the left side is $p - q \ge 0$ and the right side is $p - q$. If $p < q$ then the left side is $0$ and the right side is $q - q = 0$. $\square$

**Corollary 5.2 (ReLU on tropical rationals).** Let $f = p \ominus q$ be a tropical rational function. Then
$$\mathrm{ReLU}(f) = \max(f, 0) = \max(p, q) \ominus q.$$
By the addition law (Theorem 4.1), the new numerator $\max(p,q)$ has monomial family the disjoint union of the numerator and denominator families of $f$. Thus if $f$ has numerator count $m$ and denominator count $d$, then $\mathrm{ReLU}(f)$ has numerator count $m + d \le 2\max(m,d)$ and denominator count $d$.

*Proof.* Substitute $p \mapsto p(x)$, $q \mapsto q(x)$ in Lemma 5.1 and apply Corollary of Theorem 4.1 to $\max(p,q)$. $\square$

**Corollary 5.3 (Depth $\Rightarrow$ degree $\le 2^L$).** Consider a scalar quantity $m_0 = 1$ evolving under $L$ rectifying stages, each obeying $m_{k+1} \le 2\, m_k$. Then $m_L \le 2^L$. Consequently the algebraic degree of the tropical hypersurface computed by a depth-$L$ rectifier network is at most $2^L$.

*Proof.* An immediate induction: $m_{k+1} \le 2 m_k$ and $m_0 = 1$ give $m_k \le 2^k$. $\square$

**Corollary 5.4 (Width $\Rightarrow$ region count $\prod w_i$).** A tropical product (pointwise sum) over $L$ factors, where factor $i$ has $w_i$ monomials, has exactly $\prod_{i=1}^L w_i$ monomials.

*Proof.* Iterate Theorem 4.2: $|\mathcal{I}_1 \times \cdots \times \mathcal{I}_L| = \prod_i |\mathcal{I}_i| = \prod_i w_i$. $\square$

Combining Corollaries 5.3 and 5.4, the number of linear regions of the piecewise linear function computed by a depth-$L$ network with widths $w_1, \dots, w_L$ is bounded by $2^L \prod_i w_i$, matching classical region-counting bounds.

---

## 6. Geometry of the decision boundary

Let $f = p \ominus q$ be the tropical rational function of a binary classifier, with $p, q$ tropical polynomials.

**Proposition 6.1 (The boundary is the equalizer).** The decision boundary satisfies
$$\{x : f(x) = 0\} = \{x : p(x) = q(x)\}.$$

*Proof.* $f(x) = p(x) - q(x) = 0 \iff p(x) = q(x)$. $\square$

**Proposition 6.2 (Closedness).** The decision boundary is closed.

*Proof.* $p$ and $q$ are continuous (Theorem 3.4), so $f = p - q$ is continuous, and $\{x : f(x) = 0\} = f^{-1}(\{0\})$ is the preimage of a closed set. $\square$

**Proposition 6.3 (Sign is governed by the dominant family).** For $x$ off the boundary, $\mathrm{sign}(f(x))$ equals $+1$ when the maximizing monomial belongs to the numerator family $p$ (i.e. $p(x) > q(x)$) and $-1$ when it belongs to the denominator family $q$ (i.e. $q(x) > p(x)$). Thus the classification label at $x$ is determined by which tropical polynomial dominates there.

*Proof.* Immediate from $f = p - q$ and Lemma 3.2 applied to $\max(p, q)$. $\square$

**Singular locus (multiplicity of argmax).** A boundary point $x$ is *smooth* if the maximum defining the local dominant tropical polynomial is attained by a unique monomial; it is *singular* when three or more affine pieces meet (the argmax has multiplicity $\ge 3$). This is a codimension-two incidence condition of the same combinatorial type that governs vertices of tropical curves. The number of such singular strata is bounded by counting the ways monomial families can pairwise tie within each layer, giving a bound of the form $\prod_i \binom{w_i}{2}$.

---

## 7. Algorithms

### 7.1 Extracting the tropical rational representation of a ReLU network

Given a trained ReLU network, one propagates a symbolic tropical-rational representation $(p, q)$ layer by layer using Theorems 4.1, 4.2 and Corollary 5.2: an affine layer applies the multiplication/addition laws to update $(p,q)$; a ReLU layer applies $\max(p,q) \ominus q$. The monomial families are tracked as finite sets of $(a, w)$ pairs. This yields an exact piecewise linear description whose region count is bounded by $2^L\prod_i w_i$.

### 7.2 Region enumeration and boundary sampling

To visualize the boundary $\{p = q\}$, one samples a grid, evaluates $f = p - q$ by taking maxima over monomial families, and extracts the zero level set. The dominant monomial index at each point provides the region label; boundaries between regions where three or more indices tie are flagged as singular.

### 7.3 Curvature-free robustness certification

At a correctly classified point $x_0$ with margin $|f(x_0)|$, the local Lipschitz constant of $f$ is realized by the active affine pieces of $p$ and $q$. The certified robustness radius is $|f(x_0)| / (\|w^{(p)}_\star\| + \|w^{(q)}_\star\|)$, where $w^{(p)}_\star, w^{(q)}_\star$ are the dominant monomial slopes at $x_0$ — with no dependence on any second-order term, because convexity forces a single affine piece to realize the local slope.

---

## 8. Applications

- **Expressivity accounting.** The exact laws give architecture-dependent bounds on linear-region count ($2^L\prod_i w_i$), clarifying the classical trade-off between depth (exponential) and width (multiplicative).
- **Robustness.** Curvature-free certificates (Section 7.3) provide margins that are cheap to compute and provably tight for the active facet.
- **Interpretability.** The dominant-monomial index labels each input region with the affine rule the network applies there, turning a black box into a piecewise affine lookup.
- **Model comparison.** Two networks can be compared by the combinatorial structure (monomial families, singular strata) of their tropical rational functions rather than by opaque parameter counts.

---

## 9. Discussion

The correspondence "ReLU network $=$ tropical rational function" is exact, not asymptotic. It reduces expressivity questions to combinatorics of monomial families and reduces geometric questions about the boundary to incidence conditions among affine pieces. The convexity of tropical polynomials (Theorem 3.3) is especially consequential: it removes curvature from robustness analysis and guarantees that the boundary is a well-behaved piecewise linear hypersurface rather than an arbitrary level set.

A limitation is that the raw monomial families can be exponentially large; the bounds $2^L$ and $2^L\prod_i w_i$ are worst-case, and practical networks realize far fewer *active* regions. Understanding the typical (not worst-case) monomial count for trained weights is an important open direction.

---

## 10. Future directions

We highlight three testable conjectures distilled from the two arithmetic laws.

1. **Exact monomial-count recursion.** For a depth-$L$ network with widths $w_1,\dots,w_L$, the numerator monomial count obeys the exact recursion $m_{k+1} = m_k + d_k$ (with $d_k$ the current denominator count), hence is bounded by $2^L\prod_i w_i$, with the bound attained on an open set of weights. The mechanism is Corollary 5.2: rectification takes the disjoint union of numerator and denominator families.

2. **Codimension-two singular locus.** The non-smooth points of the boundary — where three or more affine pieces meet — form a codimension-two tropical stratum whose count is bounded by $\prod_i \binom{w_i}{2}$. The mechanism is that singularity is a multiplicity-$\ge 3$ argmax condition, of the same combinatorial type as vertices of tropical curves.

3. **Curvature-free certified robustness.** The certified robustness radius at a correctly classified point equals the margin divided by twice the sum of the two dominant monomial slopes, with no second-order term, because convexity forces the local Lipschitz constant to be realized by a single affine piece.

---

## 11. Conclusion

We have shown that the decision boundary of a rectified-linear classifier is a tropical hypersurface, and that its algebraic complexity is governed by two exact arithmetic laws of the max-plus algebra: monomial counts **add** under rectification and **multiply** under composition. From these follow the degree bound $2^L$, the region bound $2^L\prod_i w_i$, the closedness and equalizer description of the boundary, and curvature-free robustness certificates. The architecture of a network — its depth and its widths — thus directly determines the algebraic complexity of the frontier it draws between classes.
