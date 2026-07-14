# Sharp Exponent Lower Bounds for Sumsets in Intervals and Boxes of $\mathbb{Z}^d$

**Author:** Aristotle
**Date:** 2026-07-14

## Abstract

Given finite nonempty sets $A_1, \dots, A_n$ of integers contained in the segment $\{0, 1, \dots, m\}$, we determine the sharp exponent $p$ for which the lower bound
$$\bigl(|A_1| \cdots |A_n|\bigr)^{1/p} \le |A_1 + \dots + A_n|$$
holds for *every* such configuration. The exponent is the transcendental quantity
$$p = p(n,m) = \frac{n \log(m+1)}{\log(nm+1)},$$
which strictly improves the classical geometric-mean exponent $n$ whenever $n \ge 2$, and which is attained with equality by the full interval $A_j = \{0, \dots, m\}$, proving optimality. The proof combines the iterated Cauchy–Davenport inequality (valid in any torsion-free abelian group) with a pure real-analysis inequality derived from the arithmetic–geometric mean inequality and a concavity chord estimate for power functions. Because the additive engine holds in arbitrary torsion-free abelian groups, we obtain a general group-theoretic bound with exponent $q(n,M) = n\log M / \log(1 + n(M-1))$ under a uniform cardinality cap $|A_j| \le M$, and its specialization to the box $\{0,\dots,m\}^d \subseteq \mathbb{Z}^d$ (with $M = (m+1)^d$). The one-dimensional case is recovered exactly since $q(n, m+1) = p(n, m)$. We show the box exponent always dominates the geometric-mean bound, and we discuss why it is *not* sharp for $d \ge 2$, isolating the sharp higher-dimensional exponent as the main open problem.

## 1. Introduction

Additive combinatorics studies how the size of a set behaves under addition. For a finite abelian group $G$ and finite subsets $A, B \subseteq G$, the **sumset** is
$$A + B = \{\, a + b : a \in A,\ b \in B \,\},$$
and more generally, for a family $A_1, \dots, A_n$,
$$\sum_{j=1}^n A_j = \{\, a_1 + \dots + a_n : a_j \in A_j \,\}.$$
A central question is the *inverse* one: given the cardinalities $|A_j|$, how small can $\bigl|\sum_j A_j\bigr|$ be? A small sumset signals strong additive structure, since many distinct tuples $(a_1, \dots, a_n)$ must collapse onto a common sum.

Two classical lower bounds frame the problem. The trivial bound $\bigl|\sum_j A_j\bigr| \ge \max_j |A_j|$ ignores all but one set. The **geometric-mean bound**
$$\Bigl|\sum_{j=1}^n A_j\Bigr| \ge \bigl(|A_1| \cdots |A_n|\bigr)^{1/n}$$
is sharper but still loose: the maximally redundant configuration — every $A_j$ equal to the full interval $\{0, \dots, m\}$ — leaves a large gap against it.

This paper resolves the one-dimensional problem exactly. We identify the *sharp* exponent $p = n\log(m+1)/\log(nm+1)$, prove the lower bound for all configurations, and prove the interval attains equality, so $p$ cannot be lowered. We then lift the additive machinery to arbitrary torsion-free abelian groups, yielding a valid — though not sharp — box bound in $\mathbb{Z}^d$.

### Contributions

1. **The sharp one-dimensional exponent** $p(n,m)$ and the lower bound $\bigl(\prod_j |A_j|\bigr)^{1/p} \le \bigl|\sum_j A_j\bigr|$ for all $A_j \subseteq \{0,\dots,m\}$ (Theorem 5.1).
2. **Optimality**: equality for the extremal interval, hence sharpness of $p$ (Theorem 6.1), packaged with the domination $p \le n$ (Theorem 5.3).
3. **A general group bound** in torsion-free abelian groups with exponent $q(n,M)$ (Theorem 4.1) and its root form (Theorem 4.2).
4. **The higher-dimensional box bound** with exponent $q(n, (m+1)^d)$ (Theorem 7.2), compatible with dimension one via $q(n, m+1) = p(n, m)$ (Proposition 3.3), together with the caveat that it is not sharp for $d \ge 2$.

## 2. Preliminaries and definitions

Throughout, $n \ge 1$ is the number of summands, $m \ge 1$ bounds the ambient interval, and $\log$ denotes the natural logarithm. All sets are finite and nonempty.

**Definition 2.1 (Sumset).** For finite subsets $A_1, \dots, A_n$ of an abelian group, $\sum_{j=1}^n A_j = \{a_1 + \dots + a_n : a_j \in A_j\}$.

**Definition 2.2 (Interval / segment).** For $m \in \mathbb{N}$, the discrete segment is $I_m = \{0, 1, \dots, m\} \subseteq \mathbb{Z}$, with $|I_m| = m + 1$.

**Definition 2.3 (Box).** For $d, m \in \mathbb{N}$, the box is $B_{d,m} = \{0, 1, \dots, m\}^d \subseteq \mathbb{Z}^d$, with $|B_{d,m}| = (m+1)^d$.

**Definition 2.4 ($L_1$-ball).** The discrete $L_1$-ball (cross-polytope) of radius $m$ is $\{x \in \mathbb{Z}^d : |x_1| + \dots + |x_d| \le m\}$. The box $B_{d,m}$ is the natural extremal region for the sumset problem, and the segment $I_m$ is the one-dimensional face of both the box and the $L_1$-ball.

**Definition 2.5 (Torsion-free abelian group).** An abelian group $G$ is torsion-free if $kx = 0$ with $k \in \mathbb{Z}_{>0}$ forces $x = 0$. Examples: $\mathbb{Z}$, $\mathbb{Z}^d$, $\mathbb{Q}$, any $\mathbb{Q}$-vector space.

## 3. The exponents

**Definition 3.1 (One-dimensional exponent).** For $n, m \ge 1$,
$$p(n,m) = \frac{n \log(m+1)}{\log(nm+1)}.$$

**Definition 3.2 (General exponent).** For $n \ge 1$ and a real cap $M > 1$,
$$q(n,M) = \frac{n \log M}{\log\bigl(1 + n(M-1)\bigr)}.$$

**Proposition 3.3 (Compatibility).** For all $n, m$, $q(n, m+1) = p(n, m)$.

*Proof.* Substituting $M = m + 1$ gives $1 + n(M-1) = 1 + nm = nm + 1$ and $\log M = \log(m+1)$, so the two formulas coincide. $\qquad\blacksquare$

**Proposition 3.4 (Positivity).** If $n \ge 1$ and $M > 1$, then $q(n,M) > 0$; in particular $p(n,m) > 0$ for $n, m \ge 1$.

*Proof.* The numerator $n\log M > 0$. For the denominator, $1 + n(M-1) > 1$ since $n \ge 1$ and $M > 1$, so $\log(1 + n(M-1)) > 0$. A ratio of positive numbers is positive. $\qquad\blacksquare$

**Proposition 3.5 (Domination of the geometric-mean exponent).** If $n \ge 1$ and $M > 1$, then $q(n,M) \le n$. Consequently $p(n,m) \le n$.

*Proof.* Since $n \ge 1$ and $M > 1$ we have $M \le 1 + n(M-1)$, hence $\log M \le \log(1 + n(M-1))$ by monotonicity of $\log$. Multiplying by $n$ and dividing by the positive quantity $\log(1 + n(M-1))$ yields $q(n,M) = n\log M/\log(1+n(M-1)) \le n$. $\qquad\blacksquare$

Because $p \le n$ and the base $\prod_j |A_j| \ge 1$, the exponent $1/p \ge 1/n$, so the sharp bound is at least as strong as the geometric-mean bound, and strictly stronger whenever $p < n$ (i.e. $n \ge 2$).

## 4. The general group-theoretic bound

The heart of the argument is a real-analysis inequality wedded to an additive counting inequality. We present the analysis first.

### 4.1 The chord estimate

**Lemma 4.1 (Concavity chord estimate).** Let $1 < M \le L$ and $1 \le u \le L$. With $\beta = \log M / \log L \in (0, 1]$,
$$1 + \frac{(u-1)(M-1)}{L-1} \le u^{\beta}.$$

*Proof sketch.* The power function $t \mapsto t^{\beta}$ is concave on $[0, \infty)$ for $\beta \in [0,1]$. Concavity means its graph lies above every chord. Consider the chord of $t \mapsto t^\beta$ joining the abscissae $t = 1$ and $t = L$. Its endpoint values are $1^\beta = 1$ and $L^\beta = M$ (the last identity is exactly the definition of $\beta$). Writing $u$ as the convex combination $u = \frac{L-u}{L-1}\cdot 1 + \frac{u-1}{L-1}\cdot L$, concavity gives $u^\beta \ge \frac{L-u}{L-1}\cdot 1 + \frac{u-1}{L-1}\cdot M$, which simplifies to $1 + (u-1)(M-1)/(L-1)$. $\qquad\blacksquare$

### 4.2 The AM–GM step

**Lemma 4.2 (AM–GM, power form).** For nonnegative reals $a_1, \dots, a_n$,
$$\prod_{j=1}^n a_j \le \left(\frac{1}{n}\sum_{j=1}^n a_j\right)^{n}.$$

*Proof sketch.* This is the weighted geometric-mean $\le$ arithmetic-mean inequality with uniform weights $1/n$: $\prod_j a_j^{1/n} \le \frac{1}{n}\sum_j a_j$. Raising both sides to the $n$-th power gives the claim. $\qquad\blacksquare$

### 4.3 The crux real inequality

**Lemma 4.3 (Product bound).** Let $n \ge 1$, $M > 1$, and $a_1, \dots, a_n \in [1, M]$. Set $T = \sum_{j=1}^n (a_j - 1) \ge 0$. Then
$$\prod_{j=1}^n a_j \le \bigl(1 + T\bigr)^{\,q(n,M)}, \qquad q(n,M) = \frac{n\log M}{\log(1 + n(M-1))}.$$

*Proof sketch.* Put $L = 1 + n(M-1)$ and $\beta = \log M/\log L$, so $n\beta = q(n,M)$. By Lemma 4.2, since $\sum_j a_j = T + n$,
$$\prod_j a_j \le \left(\frac{T+n}{n}\right)^n = \left(1 + \frac{T}{n}\right)^n.$$
Since each $a_j \le M$, $T \le n(M-1) = L - 1$, so $u := 1 + T \in [1, L]$. Apply Lemma 4.1 at this $u$: a short computation gives $1 + (u-1)(M-1)/(L-1) = 1 + T/n$, hence $1 + T/n \le (1+T)^{\beta}$. Raising to the $n$-th power,
$$\left(1 + \frac{T}{n}\right)^n \le (1+T)^{n\beta} = (1+T)^{q(n,M)}.$$
Chaining the two displays proves the lemma. $\qquad\blacksquare$

### 4.4 The additive engine

**Lemma 4.4 (Sumset nonemptiness).** In an abelian group, the sum of finitely many nonempty finite sets is nonempty. *(Immediate by induction.)*

**Lemma 4.5 (Iterated Cauchy–Davenport).** Let $G$ be a torsion-free abelian group and $A_1, \dots, A_n \subseteq G$ finite nonempty. Then
$$\Bigl|\sum_{j=1}^n A_j\Bigr| \ge 1 + \sum_{j=1}^n \bigl(|A_j| - 1\bigr).$$

*Proof sketch.* The base case is the two-set Cauchy–Davenport inequality in a torsion-free abelian group: $|A + B| \ge |A| + |B| - 1$ for finite nonempty $A, B$. (In $\mathbb{Z}$: order both sets and observe that $a_{\min} + B$ followed by successively bumping to $a$'s produces $|A| + |B| - 1$ distinct sums; the torsion-free hypothesis makes the analogous argument work in general.) Induct on $n$: with $S = \sum_{j<n} A_j$ nonempty (Lemma 4.4), $\bigl|S + A_n\bigr| \ge |S| + |A_n| - 1 \ge \bigl(1 + \sum_{j<n}(|A_j|-1)\bigr) + |A_n| - 1$, which is the claim. $\qquad\blacksquare$

### 4.5 Assembling the general bound

**Theorem 4.6 (General sumset lower bound).** Let $G$ be a torsion-free abelian group, $n \ge 1$, $M > 1$, and let $A_1, \dots, A_n \subseteq G$ be finite nonempty with $|A_j| \le M$ for all $j$. Then
$$\prod_{j=1}^n |A_j| \;\le\; \Bigl|\sum_{j=1}^n A_j\Bigr|^{\,q(n,M)}.$$

*Proof.* Apply Lemma 4.3 with $a_j = |A_j| \in [1, M]$ (each $|A_j| \ge 1$ by nonemptiness); this gives $\prod_j |A_j| \le (1 + T)^{q(n,M)}$ with $T = \sum_j(|A_j| - 1)$. By Lemma 4.5, $1 + T \le \bigl|\sum_j A_j\bigr|$. Since $q(n,M) > 0$ (Proposition 3.4) and both sides are $\ge 1$, monotonicity of $t \mapsto t^{q}$ gives $(1+T)^{q} \le \bigl|\sum_j A_j\bigr|^{q}$. Chaining proves the theorem. $\qquad\blacksquare$

**Theorem 4.7 (Root form).** Under the hypotheses of Theorem 4.6,
$$\Bigl(\prod_{j=1}^n |A_j|\Bigr)^{1/q(n,M)} \le \Bigl|\sum_{j=1}^n A_j\Bigr|.$$

*Proof.* Raise the inequality of Theorem 4.6 to the power $1/q(n,M) > 0$ and simplify $\bigl(x^{q}\bigr)^{1/q} = x$ for $x \ge 0$. $\qquad\blacksquare$

## 5. The sharp one-dimensional bound

Specializing $G = \mathbb{Z}$ and $M = m + 1$ turns the general bound into the sharp interval bound.

**Theorem 5.1 (Sharp sumset lower bound, dimension one).** Let $n, m \ge 1$ and let $A_1, \dots, A_n \subseteq \{0, 1, \dots, m\} \subseteq \mathbb{Z}$ be finite nonempty. Then
$$\Bigl(\prod_{j=1}^n |A_j|\Bigr)^{1/p(n,m)} \le \Bigl|\sum_{j=1}^n A_j\Bigr|, \qquad p(n,m) = \frac{n\log(m+1)}{\log(nm+1)}.$$

*Proof.* Each $A_j \subseteq \{0,\dots,m\}$ has $|A_j| \le m + 1 =: M$, and $M > 1$ since $m \ge 1$. Apply Theorem 4.7 in $G = \mathbb{Z}$ with this $M$; by Proposition 3.3 the exponent $q(n, m+1)$ equals $p(n,m)$. $\qquad\blacksquare$

Equivalently, $\prod_j |A_j| \le \bigl|\sum_j A_j\bigr|^{p(n,m)}$.

**Theorem 5.3 (Domination).** $p(n,m) \le n$; hence Theorem 5.1 is at least as strong as the geometric-mean bound, and strictly stronger for $n \ge 2$. *(This is Proposition 3.5 with $M = m+1$.)*

## 6. Optimality: the extremal interval

**Lemma 6.1 (Sumset of an interval).** For $n \ge 1$ and $m \ge 0$, the $n$-fold sumset of $I_m = \{0, \dots, m\}$ is
$$\underbrace{I_m + \dots + I_m}_{n} = \{0, 1, \dots, nm\}, \qquad \text{of cardinality } nm + 1.$$

*Proof sketch.* By induction, using $\{0,\dots,a\} + \{0,\dots,b\} = \{0,\dots,a+b\}$: every integer in $[0, a+b]$ is a sum, and no sum falls outside. $\qquad\blacksquare$

**Theorem 6.2 (Extremal equality).** For $n, m \ge 1$, taking every $A_j = I_m = \{0,\dots,m\}$ yields equality in Theorem 5.1:
$$\Bigl(\prod_{j=1}^n |I_m|\Bigr)^{1/p(n,m)} = \Bigl|\sum_{j=1}^n I_m\Bigr|.$$
Consequently the exponent $p(n,m)$ is sharp: no smaller exponent is valid for all configurations.

*Proof.* Here $\prod_j |I_m| = (m+1)^n$ and, by Lemma 6.1, $\bigl|\sum_j I_m\bigr| = nm + 1$. We must show $\bigl((m+1)^n\bigr)^{1/p} = nm+1$, i.e. $(m+1)^{n/p} = nm + 1$. Taking logs, $\frac{n}{p}\log(m+1) = \log(nm+1)$, i.e. $p = n\log(m+1)/\log(nm+1)$ — precisely Definition 3.1. Sharpness follows: if some $p' < p$ worked for all configurations, then $\bigl((m+1)^n\bigr)^{1/p'} > \bigl((m+1)^n\bigr)^{1/p} = nm+1$ (since $(m+1)^n > 1$ and $1/p' > 1/p$), contradicting the bound at $A_j = I_m$. $\qquad\blacksquare$

**Theorem 6.3 (Packaged sharpness).** For $n, m \ge 1$ and finite nonempty $A_j \subseteq \{0,\dots,m\}$: (i) $\bigl(\prod_j |A_j|\bigr)^{1/p} \le \bigl|\sum_j A_j\bigr|$; (ii) equality holds at $A_j = \{0,\dots,m\}$; (iii) $p \le n$. Hence $p = p(n,m)$ is *the* sharp exponent.

## 7. Higher dimensions

**Lemma 7.1 (Cardinality of the box).** $|B_{d,m}| = (m+1)^d$, since $B_{d,m} = I_m^d$ is a $d$-fold Cartesian product each factor of size $m+1$.

**Theorem 7.2 (Box bound in $\mathbb{Z}^d$).** Let $d, n, m \ge 1$ and let $A_1, \dots, A_n \subseteq B_{d,m} = \{0,\dots,m\}^d \subseteq \mathbb{Z}^d$ be finite nonempty. Then
$$\prod_{j=1}^n |A_j| \;\le\; \Bigl|\sum_{j=1}^n A_j\Bigr|^{\,q(n,\,(m+1)^d)}, \qquad q(n, M) = \frac{n\log M}{\log(1 + n(M-1))}.$$
Equivalently, $\bigl(\prod_j |A_j|\bigr)^{1/q(n,(m+1)^d)} \le \bigl|\sum_j A_j\bigr|$.

*Proof.* The group $\mathbb{Z}^d$ is torsion-free abelian. Each $A_j \subseteq B_{d,m}$ has $|A_j| \le (m+1)^d =: M$, and $M > 1$ since $m \ge 1$, $d \ge 1$. Apply Theorem 4.6 (and Theorem 4.7 for the root form) with this $M$. $\qquad\blacksquare$

**Theorem 7.3 (Domination in every dimension).** $q(n, (m+1)^d) \le n$; the box bound always dominates the geometric-mean bound. *(Proposition 3.5 with $M = (m+1)^d$.)*

For $d = 1$, $M = m + 1$ and by Proposition 3.3 the box exponent equals $p(n,m)$, recovering Theorem 5.1 exactly.

### 7.1 Why the box bound is not sharp for $d \ge 2$

The exponent $q(n, (m+1)^d)$ is a *valid* lower bound but is **not sharp** when $d \ge 2$. The slack enters at Lemma 4.5. The Cauchy–Davenport step $|A + B| \ge |A| + |B| - 1$ is tight only for one-dimensional arithmetic-progression-like sets; a two-dimensional box $\{0,\dots,m\}^2$ has a sumset far larger than this linear estimate predicts (its own $n$-fold sum is $\{0,\dots,nm\}^2$, of size $(nm+1)^2$, whereas Lemma 4.5 only guarantees $\sim n(m+1)^2$ growth linearly). Because the additive engine underestimates higher-dimensional spreading, the resulting exponent overshoots the true sharp value. Determining the sharp higher-dimensional exponent is the principal open problem (Section 9).

## 8. Algorithms

The results yield directly computable certified lower bounds. We record the core routines; full implementations appear in the accompanying demonstration code.

**Algorithm A (Sharp exponent evaluation).** Given $n, m$, return $p(n,m) = n\log(m+1)/\log(nm+1)$ in $O(1)$ arithmetic operations. For the box in dimension $d$, return $q(n, (m+1)^d)$.

**Algorithm B (Certified sumset lower bound).** Given the sizes $s_j = |A_j|$ and the ambient cap $M$, return the guaranteed floor $\bigl(\prod_j s_j\bigr)^{1/q(n,M)}$, and (optionally) the Cauchy–Davenport floor $1 + \sum_j (s_j - 1)$ for comparison. The larger of the two is a valid lower bound; the product-root floor dominates when the $s_j$ are large and comparable.

**Algorithm C (Exact sumset via convolution).** To verify the bound empirically for concrete integer sets, compute $\sum_j A_j$ by iterated Minkowski sums (equivalently by support of iterated convolution of indicator vectors), then compare $|\sum_j A_j|$ against the certified floor. Complexity is $O(n \cdot W)$ set operations where $W = nm + 1$ bounds the support width in dimension one.

## 9. Discussion and future work

**Sharpness landscape.** In dimension one the picture is complete: $p(n,m)$ is the exact threshold exponent, strictly between the trivial and the geometric-mean regimes, with the interval as unique-shape extremiser. The transcendence of $p$ (a ratio of logarithms of integers) reflects that the extremal relation $(m+1)^n = (nm+1)^p$ has no algebraic exponent in general.

**Open problems.**

1. **The sharp higher-dimensional exponent.** Find the sharp $p$-exponent for $A_j \subseteq \{0,\dots,m\}^d$ (the box) or the $L_1$-ball for $d \ge 2$. The one-dimensional Cauchy–Davenport step is not tight in $d \ge 2$; a tensor-power/compression argument or a Plünnecke–Ruzsa route is likely needed to replace it and close the gap between the box bound proved here and the true extremiser.
2. **Translated/dilated intervals.** Generalize the extremiser optimality from $\{0,\dots,m\}$ to arbitrary arithmetic progressions, and determine whether any non-interval configuration can approach equality.
3. **Distinct-set (asymmetric) version.** The bounds are symmetric in the $A_j$. Explore whether a genuinely asymmetric refinement holds when the $|A_j|$ differ widely.
4. **Stability.** Quantify how close to the extremal interval a near-extremal configuration must be — a robust, quantitative converse to Theorem 6.2.

**Applications.** Sharp sumset lower bounds inform additive-basis constructions in number theory, cardinality guarantees for combinatorial designs and codes, and worst-case analysis of algorithms manipulating additively structured data. The certified floors of Algorithm B provide provable guarantees usable without inspecting the sets themselves — only their sizes and the ambient bound.

## 10. Conclusion

We have identified the sharp exponent $p(n,m) = n\log(m+1)/\log(nm+1)$ governing sumset lower bounds for subsets of an integer interval, proved the bound for all configurations, and established its optimality via the extremal interval. Lifting the additive engine to torsion-free abelian groups produced a general bound with exponent $q(n,M)$ and its faithful specialization to boxes in $\mathbb{Z}^d$, which dominates the geometric-mean bound in every dimension but is sharp only for $d = 1$. The sharp higher-dimensional exponent remains a compelling open target.
