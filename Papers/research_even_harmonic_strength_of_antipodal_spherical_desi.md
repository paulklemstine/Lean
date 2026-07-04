# The Even Harmonic Strength of Antipodal Spherical Designs

## Abstract

We study the *harmonic strength* of a finite set of points $X$ on the unit sphere in $\mathbb{R}^n$ — the set of degrees $k$ for which every homogeneous harmonic polynomial of degree $k$ averages to zero over $X$. We prove two foundational structural facts about **antipodal** sets (sets closed under negation, $X = -X$) and use them to isolate the essential difficulty of the theory into a single, sharply posed conjecture.

First, we show that for an antipodal set *every odd degree* automatically lies in the harmonic strength; consequently the harmonic strength of an antipodal set is always an infinite subset of $\mathbb{N}$. This result is dimension-free and requires no metric hypothesis on the sphere: it follows purely from the parity law $p(-x) = (-1)^k p(x)$ for homogeneous polynomials of degree $k$ together with the pairing $x \leftrightarrow -x$.

Second, we give a complete analysis of degree $2$, the smallest even candidate. Membership of degree $2$ in the harmonic strength is equivalent to *isotropy* of the moment matrix $M_{ij} = \sum_{x \in X} x_i x_j$, i.e. $M = (|X|/n) I$; equivalently, $X$ is a tight frame. We further prove the degree-$2$ Welch/Sidelnikov bound $\sum_{x,y \in X} \langle x, y\rangle^2 \ge |X|^2/n$ and identify its equality case with exactly this isotropy condition.

These results reduce the study of antipodal harmonic strength to its even part, and motivate the central conjecture: **for an antipodal set, if any even degree belongs to the harmonic strength, then degree $2$ does too**. We discuss the Gegenbauer-positivity mechanism behind this conjecture and outline a program for establishing the full even Welch tower and classifying its equality cases.

**Keywords:** spherical design, harmonic strength, antipodal set, Welch bound, tight frame, moment matrix, Gegenbauer polynomials, isotropy.

---

## 1. Introduction

Distributing points evenly on a sphere is a problem that arises across mathematics, physics, and engineering: from numerical cubature and potential-energy minimization to the construction of optimal signal ensembles and quantum measurements. The theory of **spherical designs**, introduced by Delsarte, Goethals, and Seidel, gives this an exact meaning: a finite set $X$ on the unit sphere $S^{n-1} \subset \mathbb{R}^n$ is a spherical $t$-design if the average of every polynomial of degree at most $t$ over $X$ equals its average over the whole sphere.

A clean and flexible refinement replaces the single threshold $t$ by the full **harmonic strength**: the set of *individual* degrees $k$ at which $X$ integrates harmonic polynomials exactly. This graded viewpoint separates the contribution of each degree and, crucially, interacts transparently with symmetry.

This paper concerns antipodal sets, $X = -X$. Such sets are ubiquitous (cross-polytopes, root systems, opposite-pole configurations, and any union of lines through the origin intersected with the sphere) and enjoy a strong parity symmetry. Our contributions are:

1. **(Odd degrees are free.)** For antipodal $X$, every odd degree lies in the harmonic strength (Theorem 3.4), whence the harmonic strength is infinite (Theorem 3.5).
2. **(Degree 2 is isotropy.)** Degree $2$ lies in the harmonic strength if and only if the moment matrix is a scalar multiple of the identity (Theorem 4.2).
3. **(Degree 2 is the base Welch bound.)** The degree-$2$ Welch bound holds with equality precisely under this isotropy condition (Theorem 4.4).

Together these show that all nontrivial content of an antipodal design's harmonic strength is concentrated in the even degrees, and that degree $2$ is the fundamental even constraint. We then formulate the conjecture that the even harmonic strength of an antipodal design, whenever nonempty, must contain $2$.

---

## 2. Definitions

Throughout, $n \ge 1$ and we work with real multivariate polynomials in the variables $x_1, \dots, x_n$. A point of $\mathbb{R}^n$ is written $x = (x_1, \dots, x_n)$, and $\langle x, y\rangle = \sum_i x_i y_i$ is the standard inner product. We write $|X|$ for the cardinality of a finite set $X$.

**Definition 2.1 (Laplacian).** The *Laplace operator* on real polynomials is
$$\Delta p \;=\; \sum_{i=1}^n \frac{\partial^2 p}{\partial x_i^2}.$$

**Definition 2.2 (Harmonic polynomial).** A polynomial $p$ is *harmonic* if $\Delta p = 0$.

**Definition 2.3 (Homogeneous polynomial).** A polynomial $p$ is *homogeneous of degree $k$* if every monomial appearing in $p$ has total degree exactly $k$; equivalently $p(\lambda x) = \lambda^k p(x)$ for all scalars $\lambda$.

**Definition 2.4 (Harmonic strength).** Let $X \subset \mathbb{R}^n$ be finite. A degree $k \in \mathbb{N}$ lies in the **harmonic strength** $\mathrm{Hst}(X)$ if every homogeneous harmonic polynomial $p$ of degree $k$ satisfies
$$\sum_{x \in X} p(x) = 0.$$

**Definition 2.5 (Antipodal set).** A finite set $X \subset \mathbb{R}^n$ is *antipodal* if it is closed under negation: $-x \in X$ whenever $x \in X$; equivalently $X = -X$.

**Definition 2.6 (Moment matrix).** For finite $X \subset \mathbb{R}^n$, the *moment matrix* is the symmetric $n \times n$ matrix
$$M_{ij} \;=\; \sum_{x \in X} x_i\, x_j, \qquad 1 \le i, j \le n.$$

**Remark 2.7.** The definition of harmonic strength does not, by itself, require $X$ to lie on the sphere; the sphere enters only through the normalization $|x| = 1$ used in the Welch bound (Section 4). The connection to spherical $t$-designs is that $X$ is a spherical $t$-design if and only if $\{1, 2, \dots, t\} \subseteq \mathrm{Hst}(X)$.

---

## 3. Odd degrees and infinite harmonic strength

The key algebraic input is the behavior of a homogeneous polynomial under negation of its argument.

**Lemma 3.1 (Parity under negation).** *If $p$ is homogeneous of degree $k$, then for every $x \in \mathbb{R}^n$,*
$$p(-x) \;=\; (-1)^k\, p(x).$$

*Proof sketch.* Evaluation of a polynomial is additive over its monomials, so it suffices to treat a single monomial $c \prod_i x_i^{d_i}$ with total degree $\sum_i d_i = k$. Substituting $-x$ replaces each factor $x_i^{d_i}$ by $(-1)^{d_i} x_i^{d_i}$, producing an overall sign $(-1)^{\sum_i d_i} = (-1)^k$. Summing over the monomials of $p$ — all of which share the total degree $k$ by homogeneity — yields $p(-x) = (-1)^k p(x)$. $\qquad\blacksquare$

**Lemma 3.2 (Negation invariance of antipodal sets).** *If $X$ is antipodal, the map $x \mapsto -x$ is a bijection of $X$ onto itself.*

*Proof sketch.* Negation is an involution on $\mathbb{R}^n$, hence injective. By Definition 2.5 it maps $X$ into $X$, and being injective on a finite set it is a bijection of $X$. $\qquad\blacksquare$

**Corollary 3.3 (Odd homogeneous forms sum to zero).** *If $X$ is antipodal and $p$ is homogeneous of odd degree $k$, then $\sum_{x \in X} p(x) = 0$.*

*Proof sketch.* By Lemma 3.1 with $k$ odd, $p(-x) = -p(x)$, so $p$ is an odd function. Reindex the sum using the bijection $x \mapsto -x$ of Lemma 3.2:
$$\sum_{x \in X} p(x) = \sum_{x \in X} p(-x) = -\sum_{x \in X} p(x),$$
whence $2\sum_{x\in X} p(x) = 0$ and the sum vanishes. $\qquad\blacksquare$

**Theorem 3.4 (Odd degrees are free).** *For any antipodal finite set $X \subset \mathbb{R}^n$ and any odd $k \in \mathbb{N}$, we have $k \in \mathrm{Hst}(X)$.*

*Proof sketch.* Let $p$ be any homogeneous harmonic polynomial of degree $k$. The harmonicity hypothesis is not even needed: by Corollary 3.3, homogeneity of odd degree together with antipodality already forces $\sum_{x \in X} p(x) = 0$. This holds for every such $p$, so $k \in \mathrm{Hst}(X)$. $\qquad\blacksquare$

**Theorem 3.5 (Infinite harmonic strength).** *For any antipodal finite set $X \subset \mathbb{R}^n$, the harmonic strength $\mathrm{Hst}(X)$ is an infinite subset of $\mathbb{N}$.*

*Proof sketch.* The map $m \mapsto 2m+1$ is an injection $\mathbb{N} \to \mathbb{N}$ whose image consists of odd numbers. By Theorem 3.4 every such value lies in $\mathrm{Hst}(X)$. An infinite set injects into $\mathrm{Hst}(X)$, so $\mathrm{Hst}(X)$ is infinite. $\qquad\blacksquare$

**Discussion.** Theorem 3.4 is remarkable for what it does *not* use: no sphere, no dimension bound, no harmonicity — only the group-theoretic fact that negation is an involution and the algebraic parity law. This is the precise sense in which the odd part of the harmonic strength is trivial. All the genuine geometry of an antipodal design is therefore concentrated in the even degrees, to which we now turn.

---

## 4. Degree two: isotropy and the Welch bound

We now assume the points of $X$ lie on the unit sphere, $|x| = 1$ for all $x \in X$, so that $\sum_i x_i^2 = 1$ and hence
$$\operatorname{tr} M = \sum_{i=1}^n M_{ii} = \sum_{x \in X} \sum_{i=1}^n x_i^2 = \sum_{x \in X} 1 = |X|. \tag{4.1}$$

### 4.1 The harmonic quadratics

The space of homogeneous quadratics is spanned by the products $x_i x_j$ ($i \le j$). Applying the Laplacian to a general quadratic $q(x) = \sum_{i \le j} a_{ij} x_i x_j$ produces the constant $2\sum_i a_{ii}$; thus $q$ is harmonic exactly when $\sum_i a_{ii} = 0$. The harmonic quadratics are therefore precisely the **traceless quadratic forms**, and they are spanned by the two explicit families
$$X_i X_j \ (i \neq j), \qquad X_i^2 - X_j^2 \ (i \neq j). \tag{4.2}$$

**Lemma 4.1 (Sum of a harmonic quadratic is a trace).** *For a traceless symmetric matrix $A$ and $q_A(x) = \sum_{i,j} A_{ij} x_i x_j$,*
$$\sum_{x \in X} q_A(x) = \sum_{i,j} A_{ij} M_{ij} = \operatorname{tr}(A M).$$

*Proof sketch.* Exchange the order of summation: $\sum_{x} \sum_{i,j} A_{ij} x_i x_j = \sum_{i,j} A_{ij} \sum_x x_i x_j = \sum_{i,j} A_{ij} M_{ij}$, which is $\operatorname{tr}(AM)$ since $A, M$ are symmetric. $\qquad\blacksquare$

**Theorem 4.2 (Degree two equals isotropy).** *Let $X$ lie on the unit sphere of $\mathbb{R}^n$. Then $2 \in \mathrm{Hst}(X)$ if and only if the moment matrix is a scalar multiple of the identity, namely*
$$M = \frac{|X|}{n}\, I,$$
*i.e. $M_{ij} = 0$ for $i \neq j$ and $M_{ii} = |X|/n$ for all $i$.*

*Proof sketch.* ($\Leftarrow$) If $M = cI$ then for any traceless $A$, Lemma 4.1 gives $\sum_x q_A(x) = \operatorname{tr}(A \cdot cI) = c\operatorname{tr}(A) = 0$; every harmonic quadratic sums to zero, so $2 \in \mathrm{Hst}(X)$.

($\Rightarrow$) Suppose $2 \in \mathrm{Hst}(X)$. Testing against the harmonic quadratic $X_iX_j$ ($i \neq j$) gives $M_{ij} = 0$, so $M$ is diagonal. Testing against $X_i^2 - X_j^2$ gives $M_{ii} = M_{jj}$ for all $i, j$, so the diagonal is constant, say $M_{ii} = c$. By the trace identity (4.1), $nc = |X|$, hence $c = |X|/n$ and $M = (|X|/n) I$. $\qquad\blacksquare$

**Interpretation.** The condition $M = (|X|/n)I$ says $X$ is a **tight frame**: $\sum_{x\in X}\langle x, u\rangle^2 = (|X|/n)|u|^2$ for every direction $u$, so the points distribute their second moment isotropically with no preferred axis. Thus "degree $2$ in the harmonic strength" is exactly the tight-frame / isotropy property.

### 4.2 The degree-two Welch bound

**Lemma 4.3 (Energy equals moment-square sum).** *For any finite $X \subset \mathbb{R}^n$,*
$$\sum_{x \in X}\sum_{y \in X} \langle x, y\rangle^2 \;=\; \sum_{i=1}^n \sum_{j=1}^n M_{ij}^2.$$

*Proof sketch.* Expand $\langle x, y\rangle^2 = \big(\sum_i x_i y_i\big)\big(\sum_j x_j y_j\big) = \sum_{i,j} x_i x_j\, y_i y_j$. Summing over $x, y$ and separating the two independent sums,
$$\sum_{x,y}\langle x,y\rangle^2 = \sum_{i,j}\Big(\sum_x x_i x_j\Big)\Big(\sum_y y_i y_j\Big) = \sum_{i,j} M_{ij}^2. \qquad\blacksquare$$

**Theorem 4.4 (Degree-two Welch/Sidelnikov bound and its equality case).** *Let $X$ lie on the unit sphere of $\mathbb{R}^n$. Then*
$$\sum_{x \in X}\sum_{y \in X} \langle x, y\rangle^2 \;\ge\; \frac{|X|^2}{n},$$
*and equality holds if and only if $2 \in \mathrm{Hst}(X)$.*

*Proof sketch.* By Lemma 4.3 the left side is $\sum_{i,j} M_{ij}^2$. Split off the diagonal:
$$\sum_{i,j} M_{ij}^2 = \sum_i M_{ii}^2 + \sum_{i \neq j} M_{ij}^2 \;\ge\; \sum_i M_{ii}^2. \tag{4.3}$$
By Cauchy–Schwarz (equivalently, the power-mean inequality) applied to the $n$ numbers $M_{ii}$,
$$\sum_i M_{ii}^2 \;\ge\; \frac{1}{n}\Big(\sum_i M_{ii}\Big)^2 = \frac{(\operatorname{tr} M)^2}{n} = \frac{|X|^2}{n}, \tag{4.4}$$
using the trace identity (4.1). Chaining (4.3) and (4.4) proves the bound.

For equality, both inequalities must be tight. Equality in (4.3) forces $M_{ij} = 0$ for all $i \neq j$. Equality in Cauchy–Schwarz (4.4) forces all $M_{ii}$ equal. Together these say $M = (|X|/n)I$, which by Theorem 4.2 is exactly $2 \in \mathrm{Hst}(X)$. Conversely, if $2 \in \mathrm{Hst}(X)$ then $M = (|X|/n)I$, both inequalities are equalities, and the Welch bound is saturated. $\qquad\blacksquare$

**Discussion.** Theorem 4.4 casts degree $2$ as the *fundamental even constraint*: it is the first even degree whose moment functional $\sum_{x,y}\langle x,y\rangle^2$ is bounded below, and the bound is saturated exactly by the configurations containing $2$ in their harmonic strength. It is the base rung of a tower of higher even Welch/Sidelnikov bounds, one for each even degree $2m$, each saturated precisely when degree $2m$ lies in the harmonic strength.

---

## 5. The central conjecture

Combining Sections 3 and 4:

- For antipodal $X$ the **odd** part of $\mathrm{Hst}(X)$ is all of the odd numbers (Theorem 3.4), so $\mathrm{Hst}(X)$ is infinite (Theorem 3.5).
- The **even** part carries all nontrivial information, and degree $2$ — its smallest possible member — is completely characterized (Theorems 4.2, 4.4).

This structural reduction motivates the guiding conjecture of the program.

**Conjecture 5.1 (Even strength contains 2).** *Let $X$ be a finite antipodal set on the unit sphere of $\mathbb{R}^n$ with $n \ge 3$ (dimension $d = n-1 \ge 2$). If some even integer belongs to $\mathrm{Hst}(X)$, then $2 \in \mathrm{Hst}(X)$.*

Equivalently: the even part of the harmonic strength of an antipodal design, if nonempty, always begins at $2$; it can never quietly start at a higher even degree.

**Heuristic mechanism.** The membership of an even degree $2m$ in the harmonic strength is equivalent to the vanishing of a specific *Gegenbauer moment* of $X$ — a weighted average of $C_{2m}^{\lambda}(\langle x, y\rangle)$ over ordered pairs, where $C_{2m}^{\lambda}$ is the degree-$2m$ Gegenbauer polynomial associated with the dimension. The even Gegenbauer polynomials form a *positive-definite* family: the pairwise-inner-product distribution of $X$ couples their moments so that they cannot vanish independently. Heuristically, the vanishing of a higher even moment cannot coexist with a strictly positive degree-$2$ moment (equivalently, with a strict degree-$2$ Welch bound). Saturating any higher even Welch bound should force the base rung — degree $2$ — to be saturated as well, giving $2 \in \mathrm{Hst}(X)$.

**Why the base case is now tractable.** Theorem 4.4 makes the base of the tower fully explicit: degree $2$ is isotropy, and isotropy is equality in the degree-$2$ Welch bound. The remaining task is to propagate this base case *upward* through the Gegenbauer hierarchy — a well-posed, self-contained next step rather than an open-ended search.

---

## 6. Algorithms

The theory yields simple, exact algorithms over finite point sets.

**Algorithm A (Moment matrix and isotropy test).** Given $X \subset \mathbb{R}^n$, form $M_{ij} = \sum_{x\in X} x_i x_j$ in $O(|X| n^2)$ time. Test whether $M = (|X|/n)I$: check off-diagonal entries are $0$ and diagonal entries all equal $|X|/n$. By Theorem 4.2 this decides $2 \in \mathrm{Hst}(X)$.

**Algorithm B (Welch energy and defect).** Compute $E = \sum_{x,y}\langle x,y\rangle^2$ directly, or (faster) as $\sum_{i,j} M_{ij}^2$ via Lemma 4.3. The *Welch defect* $E - |X|^2/n \ge 0$ measures deviation from a degree-$2$ design; it is $0$ iff $2 \in \mathrm{Hst}(X)$ (Theorem 4.4).

**Algorithm C (Odd-degree verification).** For antipodal $X$, verify Theorem 3.4 empirically by sampling homogeneous harmonic polynomials of odd degree and confirming their sums over $X$ vanish (to machine precision). This is a check, not a proof — the proof is Corollary 3.3.

---

## 7. Applications

- **Numerical cubature.** A set with $\{1,\dots,t\} \subseteq \mathrm{Hst}(X)$ integrates all degree-$\le t$ polynomials exactly, replacing an integral over the sphere by an equal-weight finite average. Antipodality gives all odd degrees for free, halving the work of building high-strength rules.
- **Tight frames and signal design.** Theorem 4.2 identifies degree-$2$ designs with tight frames; Theorem 4.4 identifies them with Welch-bound-equality ensembles, the optimal low-coherence codebooks used in communications and compressed sensing.
- **Quantum measurement.** Tight frames of unit vectors are exactly the rank-one tight informationally complete measurements (up to normalization); the isotropy condition $M = (|X|/n)I$ is their defining resolution-of-identity property.
- **Energy minimization.** The Welch bound is the degree-$2$ instance of universal lower bounds on pairwise potential energy; its equality case pins down the most uniform antipodal configurations.

---

## 8. Discussion and future work

We have shown that the harmonic strength of an antipodal spherical set splits cleanly: the odd degrees are automatic and infinite, while the even degrees hold all the geometric content, anchored by a completely understood degree $2$. The natural next steps, in order of immediacy:

1. **Even strength contains 2.** Prove Conjecture 5.1 by propagating the degree-$2$ base case upward through the Gegenbauer hierarchy, using positive-definiteness to show no higher even moment can vanish while the degree-$2$ moment stays positive.

2. **A sharp Welch tower and its equality cases.** Establish the full family of higher even Welch/Sidelnikov bounds and classify their equality cases for antipodal sets, converting an analytic sequence of inequalities into a combinatorial ladder of design conditions, each rung saturated exactly when the corresponding even degree lies in the harmonic strength.

3. **Bounded even strength via inner-product distributions.** For a fixed antipodal set, the even degrees in the harmonic strength form (conjecturally) either the empty set or an initial segment starting at $2$, whose length is controlled by the number of distinct inner-product values realized by $X$. This ties the even strength directly to the two-point distance distribution.

4. **Rigidity.** Characterize the antipodal sets whose even strength begins at $2$ as exactly the tight frames, sharpening Theorem 4.2 into a rigidity statement across the whole even tower.

The overarching message is that antipodal symmetry both *gives* (every odd degree, for free) and *constrains* (the even degrees must be earned from degree $2$ upward). Understanding the even tower completely would close the theory of antipodal harmonic strength.
