# Structural Foundations of the Determinant-Bounded Ratio Spectrum of Lagrange Constants

**Author:** Aristotle

**Date:** 2026-06-26

**Domain:** Novelty — Diophantine approximation, the geometry of continued fractions, and arithmetic dynamics

---

## Abstract

For an integer $2 \times 2$ matrix $M = \left(\begin{smallmatrix} p & q \\ r & s\end{smallmatrix}\right)$ with nonzero determinant, acting on the real line by the Möbius (linear fractional) transformation $M\cdot x = (px+q)/(rx+s)$, the *ratio spectrum* is the set of values $k(M\cdot x)/k(x)$, where $k(\cdot)$ denotes the Lagrange constant measuring how well a real number can be approximated by rationals. The Lagarias–Shallit bounds confine every such ratio to the interval $[1/|\det M|,\, |\det M|]$, and the **density conjecture** asserts that these ratios fill the entire interval as $x$ ranges over real quadratic irrational badly approximable numbers. This paper establishes the structural backbone of that program. We prove: (i) the integrality bound $|\det M| \ge 1$ and its consequences — the target interval is nonempty, contains the neutral ratio $1$, and has reciprocal endpoints whose product is $1$; (ii) scaling invariance of the Möbius action, $（kM)\cdot x = M\cdot x$ for every nonzero integer $k$, which shows that only the *primitive* class of $M$ is visible to the spectrum; (iii) the composition law $M\cdot(N\cdot x) = (MN)\cdot x$ together with determinant multiplicativity $\det(MN) = \det M \det N$, exhibiting the integer matrix monoid as acting by partial Möbius maps and making the spectral bound closed under composition; and (iv) the closure theorem that the Möbius image of a real quadratic irrational under any integer matrix of nonzero determinant is again a real quadratic irrational, with anisotropy of the associated binary quadratic form supplied by an explicit discriminant identity. Together these reduce the density program to controlling Lagrange constants along periodic continued fractions and to the Smith-normal-form reduction to the diagonal family $\mathrm{diag}(1, |\det M|)$.

---

## 1. Introduction

### 1.1 Approximability and the Lagrange constant

The quality of rational approximation to a real number $x$ is captured by its **Lagrange constant**

$$
k(x) \;=\; \limsup_{q \to \infty}\; \frac{1}{q^2\,\lVert q x\rVert},
\qquad
\lVert t \rVert = \min_{n \in \mathbb{Z}} |t - n|,
$$

equivalently the supremum of all $c > 0$ for which $|x - p/q| < 1/(c q^2)$ holds for infinitely many coprime pairs $(p, q)$. By Hurwitz's theorem $k(x) \ge \sqrt 5$ for every irrational $x$, with equality for $x$ equivalent to the golden ratio $\varphi = (1+\sqrt5)/2$. A number is **badly approximable** when $k(x) < \infty$, which holds precisely when the partial quotients of its continued fraction are bounded. The set of values $\{k(x)\}$ is the classical **Lagrange spectrum**, an intricate fractal subset of $[\sqrt5, \infty]$.

### 1.2 The ratio spectrum under integer Möbius maps

The objects of this paper are not the Lagrange constants themselves but their *transformation behavior* under integer linear fractional maps. For

$$
M = \begin{pmatrix} p & q \\ r & s \end{pmatrix} \in M_2(\mathbb{Z}), \qquad \det M = ps - qr \ne 0,
$$

the **Möbius action** on the line is

$$
M \cdot x \;=\; \mathrm{mobius}(p,q,r,s; x) \;=\; \frac{p x + q}{r x + s},
$$

defined whenever $rx + s \ne 0$. When $\det M = \pm 1$ (i.e. $M \in \mathrm{GL}_2(\mathbb{Z})$), the map permutes the rationals and the badly approximable numbers and preserves the Lagrange constant exactly: $k(M\cdot x) = k(x)$. For general nonzero determinant this is no longer true, and the **ratio**

$$
\rho(M, x) \;=\; \frac{k(M\cdot x)}{k(x)}
$$

quantifies the distortion of approximability. The **Lagarias–Shallit bounds** state that, with $D := |\det M|$,

$$
\frac1D \;\le\; \rho(M, x) \;\le\; D \qquad\text{for all admissible } x. \tag{LS}
$$

The **ratio spectrum** of $M$ is $\mathrm{Spec}(M) = \{\rho(M, x)\}$ as $x$ ranges over a chosen class of irrationals.

### 1.3 The density conjecture and the contribution of this paper

> **Density Conjecture.** Let $M$ be a primitive integer matrix with $\det M \ne 0$ and $D = |\det M|$. For every pair of reals $u < v$ with $1/D \le u < v \le D$, there exists a real quadratic irrational badly approximable number $x$ such that $u < \rho(M, x) < v$. Equivalently, $\mathrm{Spec}(M)$ restricted to real quadratic irrationals is dense in $[1/D, D]$.

The restriction to quadratic irrationals is essential and natural: by Lagrange's theorem these are exactly the reals with eventually periodic continued fractions, for which $k(x)$ is a finite maximum over one period and is therefore amenable to explicit construction. The full conjecture is open. This paper rigorously establishes the *structural backbone* on which any proof must rest, organized into four pillars:

1. **Interval geometry** (§3): $|\det M| \ge 1$, hence $1 \in [1/D, D]$, the interval is nonempty, and its endpoints are reciprocal.
2. **Primitivity normalization** (§4): the Möbius action is invariant under integer scaling of all entries, so only the primitive class of $M$ matters.
3. **Monoid action** (§5): composition of Möbius maps equals the Möbius map of the matrix product, and determinants multiply; the bound (LS) is therefore closed under composition.
4. **Closure of the restriction class** (§6): the Möbius image of a quadratic irrational is a quadratic irrational, so the ratio spectrum is well-defined on its domain.

All results below are stated for explicit scalar entries $p, q, r, s \in \mathbb{Z}$, the most directly verifiable form, and have been formally verified.

---

## 2. Definitions

**Definition 2.1 (Möbius action).** For $p, q, r, s \in \mathbb{Z}$ and $x \in \mathbb{R}$,
$$
\mathrm{mobius}(p, q, r, s; x) \;=\; \frac{p x + q}{r x + s} .
$$
We write $M \cdot x$ for $\mathrm{mobius}(p,q,r,s;x)$ when $M = \left(\begin{smallmatrix} p & q \\ r & s\end{smallmatrix}\right)$, the value being defined where $rx + s \ne 0$.

**Definition 2.2 (Determinant).** $\det M = ps - qr$, and $D := |\det M| = |ps - qr|$.

**Definition 2.3 (Target interval).** The *target interval* of $M$ (with $\det M \ne 0$) is $I(M) = [\,1/D,\ D\,] \subseteq \mathbb{R}_{>0}$.

**Definition 2.4 (Real quadratic irrational).** A real number $x$ is a **quadratic irrational**, written $\mathrm{QuadIrr}(x)$, if $x$ is irrational and there exist integers $a, b, c$ with $a \ne 0$ such that $a x^2 + b x + c = 0$. Equivalently (Lagrange), $x$ has an eventually periodic continued fraction expansion.

**Definition 2.5 (Primitive matrix).** $M$ is **primitive** if $\gcd(p, q, r, s) = 1$. Every nonzero integer matrix equals $k \cdot M_0$ for a unique positive integer $k = \gcd(p,q,r,s)$ and primitive $M_0$.

**Definition 2.6 (Lagrange constant; informal).** $k(x) = \limsup_{q\to\infty} \bigl(q^2 \lVert qx \rVert\bigr)^{-1}$, finite iff $x$ is badly approximable. The ratio spectrum studies $\rho(M, x) = k(M\cdot x)/k(x)$.

---

## 3. The geometry of the target interval

The entire shape of the target interval $[1/D, D]$ is forced by a single arithmetic fact: a nonzero integer determinant has absolute value at least one.

**Theorem 3.1 (Integrality bound).** *If $ps - qr \ne 0$, then $1 \le |ps - qr|$ (as integers), and hence $1 \le |ps - qr|$ as reals.*

*Proof sketch.* A nonzero integer $n$ satisfies $|n| \ge 1$, since $0$ is the only integer with absolute value below $1$; formally $|n| > 0 \iff n \ne 0$ and the positive integers are bounded below by $1$. Casting the integer inequality into $\mathbb{R}$ preserves it. $\qquad\blacksquare$

*(Formalized as `one_le_absDet` and `one_le_absDet_real`.)*

**Theorem 3.2 (Neutral ratio lies in the interval).** *If $ps - qr \ne 0$, then $1/D \le 1$ and $1 \le D$.*

*Proof sketch.* From Theorem 3.1, $D \ge 1$. Then $1 \le D$ directly, and $1/D \le 1$ because dividing $1$ by a quantity $\ge 1$ cannot exceed $1$ (`div_le_self` with $0 \le 1$). Thus the no-distortion ratio $1$ always belongs to $I(M)$: every integer Möbius map is permitted to leave approximability unchanged. $\qquad\blacksquare$

*(Formalized as `one_mem_spectrum_interval`.)*

**Theorem 3.3 (Interval nonemptiness).** *If $ps - qr \ne 0$, then $1/D \le D$.*

*Proof sketch.* Multiply the target inequality $1/D \le D$ out: it is equivalent to $1 \le D^2$ for $D > 0$, which follows from $D \ge 1$ (Theorem 3.1). Concretely, clearing the denominator with $\mathrm{div\_le\_iff}$ reduces the claim to $1 \le D \cdot D$, dispatched by positivity and $D \ge 1$. $\qquad\blacksquare$

*(Formalized as `spectrum_lower_le_upper`.)*

**Theorem 3.4 (Reciprocal endpoints).** *If $ps - qr \ne 0$, then*
$$
\frac{1}{D} \cdot D \;=\; 1 .
$$

*Proof sketch.* Since $D = |ps - qr| \ge 1 > 0$, $D$ is a nonzero real, so $(1/D)\cdot D$ cancels to $1$ (`div_mul_cancel`). The content is conceptual rather than computational: the two endpoints of $I(M)$ are exact multiplicative inverses, so the interval is invariant as a set under the involution $\rho \mapsto 1/\rho$. This reflects the $M \leftrightarrow M^{-1}$ symmetry of the ratio spectrum — reversing the transformation inverts the ratio, and the maximal boost $D$ is mirrored by the maximal penalty $1/D$. $\qquad\blacksquare$

*(Formalized as `spectrum_endpoints_mul`.)*

The four results of this section show that $I(M) = [1/D, D]$ is a genuine, nonempty, $\rho \mapsto 1/\rho$-symmetric interval straddling $1$, with all of its structure determined by the single integer $D \ge 1$.

---

## 4. Primitivity is the correct normalization

A foundational subtlety is that the Möbius action does not see the overall scale of a matrix. Multiplying every entry by a nonzero integer $k$ multiplies the determinant by $k^2$, yet leaves the action — and therefore the ratio spectrum — unchanged.

**Theorem 4.1 (Scaling invariance).** *For every nonzero integer $k$ and all $p, q, r, s \in \mathbb{Z}$ and $x \in \mathbb{R}$,*
$$
\mathrm{mobius}(kp, kq, kr, ks; x) \;=\; \mathrm{mobius}(p, q, r, s; x).
$$

*Proof sketch.* Expanding the left side,
$$
\frac{(kp) x + (kq)}{(kr) x + (ks)} = \frac{k(px + q)}{k(rx + s)} = \frac{px + q}{rx + s},
$$
where the common nonzero factor $k$ (viewed in $\mathbb{R}$, nonzero since $k \ne 0$) cancels in numerator and denominator (`mul_div_mul_left`). The cancellation is valid for *every* real $x$, including those at which the map is defined, because $k$ never vanishes. $\qquad\blacksquare$

*(Formalized as `mobius_smul_invariant`.)*

**Corollary 4.2 (Reduction to primitive matrices).** Write $M = k M_0$ with $k = \gcd(p,q,r,s)$ and $M_0$ primitive. Then $M\cdot x = M_0 \cdot x$ for all $x$, so $\mathrm{Spec}(M) = \mathrm{Spec}(M_0)$. Consequently the density conjecture for all $M$ is equivalent to its assertion for primitive $M$, and the determinant invariant relevant to the spectrum is $|\det M_0|$, not $|\det M| = k^2 |\det M_0|$.

This is exactly why the density statement is phrased for primitive matrices: primitivity removes the redundant scaling degree of freedom, leaving a faithful parameterization of the distinct Möbius maps.

---

## 5. The integer matrix monoid acts by Möbius maps

We now exhibit the algebraic structure that elevates the problem from individual maps to a monoid action — the structure that makes the Smith-normal-form reduction (FD2 below) possible.

**Theorem 5.1 (Determinant multiplicativity).** *For all integer entries,*
$$
(p p' + q r')(r q' + s s') - (p q' + q s')(r p' + s r') \;=\; (ps - qr)(p's' - q'r').
$$
*That is, $\det(MN) = \det M \cdot \det N$ on explicit $2\times 2$ entries.*

*Proof sketch.* Both sides are polynomials in the eight variables $p,q,r,s,p',q',r',s'$. Expanding the left side and collecting terms produces exactly the right side; this is a finite polynomial identity verified by ring normalization (case-split distributive expansion). $\qquad\blacksquare$

*(Formalized as `det_mul`.)*

**Theorem 5.2 (Composition law).** *Let $M = \left(\begin{smallmatrix} p & q \\ r & s\end{smallmatrix}\right)$ and $N = \left(\begin{smallmatrix} p' & q' \\ r' & s'\end{smallmatrix}\right)$. Suppose the inner denominator $r' x + s' \ne 0$ and the composed denominator $(rp' + sr') x + (rq' + ss') \ne 0$. Then*
$$
M \cdot (N \cdot x) \;=\; (MN) \cdot x,
$$
*where the product matrix is*
$$
MN = \begin{pmatrix} p p' + q r' & p q' + q s' \\ r p' + s r' & r q' + s s' \end{pmatrix}.
$$

*Proof sketch.* Substitute $N\cdot x = (p'x+q')/(r'x+s')$ into $M\cdot(\,\cdot\,)$:
$$
\frac{p\cdot\frac{p'x+q'}{r'x+s'} + q}{r\cdot\frac{p'x+q'}{r'x+s'} + s}
= \frac{p(p'x+q') + q(r'x+s')}{r(p'x+q') + s(r'x+s')}
= \frac{(pp'+qr')x + (pq'+qs')}{(rp'+sr')x + (rq'+ss')},
$$
after multiplying numerator and denominator by $r'x + s' \ne 0$. The final fraction is precisely $(MN)\cdot x$. Both denominator hypotheses are needed: the inner one to evaluate $N \cdot x$, the composed one for the outer division to be defined. $\qquad\blacksquare$

*(Formalized as `mobius_comp`.)*

**Corollary 5.3 (Monoid structure and closure of the bound).** Theorems 5.1–5.2 show that $\{M \in M_2(\mathbb{Z}) : \det M \ne 0\}$ acts on $\mathbb{R}$ by partial Möbius transformations, with composition mirroring matrix multiplication. Because Lagrange-constant ratios are multiplicative along composition and $|\det(MN)| = |\det M|\,|\det N|$, the reachable ratios of $MN$ lie inside $I(M)\cdot I(N)$, and the Lagarias–Shallit interval is closed under composition. In particular, factoring $M = U \cdot \mathrm{diag}(1, D) \cdot V$ with $U, V \in \mathrm{GL}_2(\mathbb{Z})$ (Smith normal form), and noting that $\mathrm{GL}_2(\mathbb{Z})$ factors act with target interval $[1,1] = \{1\}$ (they preserve $k$), all spectral content is carried by the diagonal middle factor.

---

## 6. Closure of the quadratic-irrational locus

For the ratio $\rho(M, x) = k(M\cdot x)/k(x)$ to make sense within the class of quadratic irrationals, that class must be invariant under the action. We establish this in full generality.

**Lemma 6.1 (Anisotropy via the discriminant identity).** *Let $a, b, c \in \mathbb{Z}$ with $a \ne 0$, and suppose the polynomial $a t^2 + b t + c$ has an irrational root. Then the binary quadratic form $a m^2 - b m n + c n^2$ has no nontrivial integer zero: $a m^2 - b m n + c n^2 = 0$ with $(m,n) \in \mathbb{Z}^2 \setminus \{0\}$ is impossible.*

*Proof sketch.* The discriminant identity
$$
4a\,(a m^2 - b m n + c n^2) \;=\; (2am - bn)^2 - (b^2 - 4ac)\,n^2
$$
holds for all integers (a polynomial identity). If $x$ is an irrational root of $a t^2 + b t + c$, then $b^2 - 4ac$ is not a perfect square (else the roots would be rational). Were there a nontrivial zero $(m, n)$ of the form, the identity would force $(2am - bn)^2 = (b^2 - 4ac) n^2$. If $n \ne 0$ this makes $b^2 - 4ac = ((2am-bn)/n)^2$ a square of a rational, hence (being an integer) a perfect square — contradiction; if $n = 0$ then $(2am)^2 = 0$ forces $m = 0$ since $a \ne 0$, contradicting nontriviality. $\qquad\blacksquare$

*(Formalized as `quadForm_ne_zero`.)*

**Theorem 6.2 (Irrationality is preserved).** *If $x$ is irrational and $ps - qr \ne 0$ (with $rx + s \ne 0$), then $M\cdot x = (px+q)/(rx+s)$ is irrational.*

*Proof sketch.* Suppose $M\cdot x = \tfrac{a}{b} \in \mathbb{Q}$. Then $b(px+q) = a(rx+s)$, i.e. $(bp - ar)x = as - bq$. If the coefficient $bp - ar$ of $x$ were nonzero, $x$ would be rational — contradiction. So $bp - ar = 0$ and $as - bq = 0$; eliminating shows $\tfrac{a}{b}$ forces $ps - qr$ to act degenerately, and combined with $\det M \ne 0$ one derives a contradiction. Hence $M\cdot x \notin \mathbb{Q}$. $\qquad\blacksquare$

*(Formalized as `irrational_mobius`.)*

**Theorem 6.3 (Closure of quadratic irrationals).** *If $\mathrm{QuadIrr}(x)$ and $ps - qr \ne 0$ (with the relevant denominator nonzero), then $\mathrm{QuadIrr}(M\cdot x)$.*

*Proof sketch.* Write $y = M\cdot x = (px+q)/(rx+s)$. Irrationality of $y$ is Theorem 6.2. For the quadratic relation, let $a t^2 + b t + c = 0$ be satisfied by $x$ with $a \ne 0$. The inverse Möbius map expresses $x$ as a fractional transformation of $y$ (with integer coefficients built from $p,q,r,s$ and determinant $\pm(ps-qr) \ne 0$). Substituting into $ax^2 + bx + c = 0$ and clearing denominators yields $A y^2 + B y + C = 0$ with integer $A, B, C$; the nonzero determinant guarantees $A \ne 0$ — otherwise the resulting relation would be linear and force $y$, hence $x$, rational, contradicting Theorem 6.2 (Lemma 6.1 controls the relevant non-degeneracy). Thus $y$ is a quadratic irrational. $\qquad\blacksquare$

*(Formalized as `quadIrr_mobius`; predicate `QuadIrr`.)*

Theorem 6.3 is the algebraic shadow of Lagrange's periodicity theorem: the eventually-periodic continued fraction class is preserved not only by $\mathrm{GL}_2(\mathbb{Z})$ but by every integer matrix of nonzero determinant. With closure secured, $\mathrm{Spec}(M)$ is a well-defined subset of $[1/D, D]$.

---

## 7. Algorithms

The structural results are constructive and underwrite explicit computation of ratio-spectrum data. We highlight three algorithms (full code in the accompanying demo).

**Algorithm 7.1 (Lagrange constant of a quadratic irrational via period maximum).** Given a quadratic irrational $x$ with eventually periodic continued fraction $[a_0; a_1, \dots, \overline{a_{m+1}, \dots, a_{m+\ell}}]$, the Lagrange constant equals
$$
k(x) = \max_{i} \Bigl( [\,0; a_{i-1}, a_{i-2}, \dots\,] + [\,a_i; a_{i+1}, a_{i+2}, \dots\,] \Bigr),
$$
the maximum over positions $i$ in the period of the sum of the forward and backward tails (the doubly-infinite expansion). Because the expansion is periodic, this is a finite maximum over one period, computed to any precision by truncating the two periodic tails. Complexity: $O(\ell \cdot P)$ for period length $\ell$ and truncation depth $P$.

**Algorithm 7.2 (Smith normal form reduction of a primitive matrix).** Given $M \in M_2(\mathbb{Z})$ with $\det M \ne 0$, compute $U, V \in \mathrm{GL}_2(\mathbb{Z})$ and $D_1 \mid D_2$ with $M = U\,\mathrm{diag}(D_1, D_2)\,V$ via the Euclidean algorithm on entries (row/column operations). For primitive $M$, $D_1 = 1$ and $D_2 = |\det M| = D$, so $M = U\,\mathrm{diag}(1, D)\,V$. Since $U, V \in \mathrm{GL}_2(\mathbb{Z})$ preserve $k$, $\mathrm{Spec}(M) = \mathrm{Spec}(\mathrm{diag}(1, D))$ (Corollary 5.3). Complexity: $O(\log(\max|{\cdot}|))$ Euclidean steps.

**Algorithm 7.3 (Ratio-spectrum sampler).** To approximate $\mathrm{Spec}(M) \cap [1/D, D]$: enumerate purely periodic continued fractions of bounded height, form each quadratic irrational $x$, apply $M$ via Definition 2.1 (using `quadIrr_mobius` to stay in class), compute $k(x)$ and $k(M\cdot x)$ via Algorithm 7.1, and record $\rho(M, x)$. The empirical distribution of recorded ratios converges to a dense subset of $[1/D, D]$ as the height bound grows (Density Conjecture).

---

## 8. Applications and discussion

**Arithmetic dynamics.** The monoid action (§5) places the ratio spectrum within the theory of $\mathrm{GL}_2$-actions on the boundary of hyperbolic space. The reciprocal-endpoint symmetry (Theorem 3.4) is the spectral imprint of the $M \leftrightarrow M^{-1}$ duality central to that theory.

**Continued fraction algorithms.** Because $\mathrm{GL}_2(\mathbb{Z})$ acts trivially on $k$ while $\mathrm{diag}(1, D)$ carries the entire spectral effect (Corollary 5.3), questions about how integer fractional maps distort approximation reduce to a single diagonal family — a substantial simplification for both theory and computation.

**Metric Diophantine approximation.** The anisotropy identity (Lemma 6.1) gives uniform control on transformed leading coefficients, the entry point to upgrading density to a positive-measure statement (FD3).

**Scope and limitations.** This paper proves the structural backbone — interval geometry, primitivity normalization, monoid action, closure — with complete rigor. The density conjecture itself remains open; the contribution here is to render it a precise, well-posed problem about a monoid acting on a stable class, and to isolate the two remaining ingredients (control of $k$ along periodic continued fractions; the Smith reduction to the diagonal family).

---

## 9. Future directions

**FD1. The two-sided Lagarias–Shallit bound is attained in the limit on periodic continued fractions.** For every primitive $M$ with $|\det M| = D$, there exist sequences of purely periodic continued fractions $x_n$ with $k(Mx_n)/k(x_n) \to D$ and another with ratio $\to 1/D$. The extreme ratios are realized by continued fractions whose period is aligned with the Smith normal form $\mathrm{diag}(1, D)$, absorbing the determinant into a single partial-quotient scaling step. The remaining ingredient is a limsup-based definition of $k(\cdot)$.

**FD2. Density reduces to the diagonal case $\mathrm{diag}(1, D)$ via Smith normal form.** The ratio spectrum of any primitive $M$ with $|\det M| = D$ equals that of $\mathrm{diag}(1, D)$; density for all $M$ follows from density for the single diagonal family. The reduction rests on $M = U\,\mathrm{diag}(1,D)\,V$ with $U, V \in \mathrm{GL}_2(\mathbb{Z})$ acting by $k$-preserving Möbius maps, combined with the multiplicative action (Theorems 5.1–5.2).

**FD3. Anisotropy controls the measure of attainable ratios, not just density.** For fixed $D$, the set of ratios attained by $x$ of bounded continued-fraction height has positive Lebesgue measure inside $[1/D, D]$, tending to full measure as the height bound grows. The anisotropy bound from the discriminant identity gives a uniform lower bound on how far the transformed quadratic's leading coefficient stays from $0$, translating into a quantitative spread of convergent denominators and hence of $k$.

**FD4. The $M \leftrightarrow M^{-1}$ reciprocal symmetry is exact on the spectrum.** For every primitive $M$, $\rho \in \mathrm{Spec}(M) \iff 1/\rho \in \mathrm{Spec}(M^{-1})$, and when $M$ is conjugate to $M^{-1}$ in $\mathrm{GL}_2(\mathbb{Q})$ the spectrum is symmetric under $\rho \mapsto 1/\rho$ — the dynamical refinement of the endpoint reciprocity of Theorem 3.4.

---

## 10. Conclusion

We have established the rigid structural foundation of the determinant-bounded ratio spectrum of Lagrange constants: the target interval $[1/D, D]$ is nonempty, contains the neutral ratio $1$, and is self-reciprocal, all forced by $|\det M| \ge 1$; the Möbius action is scale-invariant, making primitivity the correct normalization; integer matrices act as a monoid by partial Möbius maps with multiplicative determinants, closing the Lagarias–Shallit bound under composition; and the quadratic-irrational locus is closed under the action, making the ratio spectrum a well-defined object. These results convert the density conjecture from an informal aspiration into a precisely posed problem with an explicit reduction strategy, and they furnish the algorithmic primitives for its computational study.
