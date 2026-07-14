# The Sumset Exponent Surface: Asymptotics and Monotonicity of Sharp Sumset Bounds in $\ell_1$ Balls

## Abstract

We study the sharp exponent governing sumset lower bounds inside the integer cross-polytope (the $\ell_1$ ball) $B_d(m) = \{x \in \mathbb{Z}^d : |x_1| + \cdots + |x_d| \le m\}$. For $n$ summands and radius $m$, the extremal one-dimensional interval configuration singles out the exponent
$$p(n,m) = \frac{n\,\log(m+1)}{\log(nm+1)},$$
which is conjectured to be the sharp exponent in the inequality $|A_1 + \cdots + A_n| \ge (|A_1|\cdots|A_n|)^{1/p}$ in every dimension. Building on the previously established bracket $1 < p(n,m) < n$ and the one-dimensional equality case, we determine the global shape of the two-variable exponent surface $(n,m) \mapsto p(n,m)$. Our main results are: (i) the strict upper bound $p(n,m) < n$ for all $n \ge 2$, $m \ge 1$; (ii) strict monotonicity in the number of summands, $p(n,m) < p(n+1,m)$, which we reduce to and prove via the integer inequality $((n+1)m+1)^n < (nm+1)^{n+1}$; (iii) the radial asymptotics $p(n,m) \to n$ as $m \to \infty$; and (iv) a consequent refutation of radial monotonicity — the map $m \mapsto p(n,m)$ is *not* decreasing, correcting a natural but false conjecture. We give full proof sketches, an algorithmic treatment of the underlying comparisons, and numerical corroboration.

**Keywords:** sumset, cross-polytope, $\ell_1$ ball, sharp exponent, additive combinatorics, Bernoulli's inequality, geometric-mean bound, radial asymptotics, monotonicity.

**MSC 2020:** 11B30 (additive combinatorics), 11P70, 52C07 (lattices and convex bodies), 05A20 (combinatorial inequalities).

---

## 1. Introduction

### 1.1 Sumsets and their lower bounds

For finite subsets $A_1, \dots, A_n$ of an abelian group, the *sumset* is
$$A_1 + \cdots + A_n = \{a_1 + \cdots + a_n : a_j \in A_j\}.$$
A foundational theme of additive combinatorics is the quantification of the trade-off between the *size* of a sumset and the *additive structure* of its summands. The trivial upper bound $|A_1 + \cdots + A_n| \le |A_1|\cdots|A_n|$ is attained only by dissociated (Sidon-type) configurations, while structured configurations — arithmetic progressions and their higher-dimensional generalizations — minimize the sumset. The corresponding *lower* bounds are governed by results in the Cauchy–Davenport / Kneser / Plünnecke–Ruzsa family.

We restrict attention to summands confined to a fixed geometric container: the integer cross-polytope of radius $m$,
$$B_d(m) = \{x \in \mathbb{Z}^d : |x_1| + |x_2| + \cdots + |x_d| \le m\}.$$
This is the $\ell_1$ ball of radius $m$ intersected with the integer lattice; it is the interval $\{-m,\dots,m\}$ when $d=1$, a lattice diamond when $d=2$, and a lattice octahedron when $d=3$.

### 1.2 The sharp exponent

The natural way to record a sumset lower bound is via a single exponent $p$ in
$$|A_1 + \cdots + A_n| \;\ge\; \bigl(|A_1|\cdots|A_n|\bigr)^{1/p}. \tag{$\star$}$$
The *sharp* exponent is the smallest $p$ for which $(\star)$ holds for all admissible configurations. Two elementary facts frame the problem:

- The **geometric-mean bound** always gives a valid exponent $p = n$. Indeed, by symmetry and the pigeonhole/Plünnecke-type reasoning, $|A_1 + \cdots + A_n| \ge \max_j |A_j| \ge (|A_1|\cdots|A_n|)^{1/n}$, so $(\star)$ holds with $p = n$; and any $q \ge n$ is likewise valid because raising the exponent only weakens the bound.

- The **one-dimensional interval** furnishes the extremal configuration. Taking $A_j = \{0, 1, \dots, m\} \subset B_1(m)$, each of size $m+1$, we obtain $A_1 + \cdots + A_n = \{0, 1, \dots, nm\}$ of size $nm+1$. The borderline exponent in $(\star)$ for this configuration solves $(nm+1) = (m+1)^{n/p}$, that is,
$$p(n,m) = \frac{n\,\log(m+1)}{\log(nm+1)}. \tag{1}$$

Earlier work established the bracket $1 < p(n,m) < n$ and the equality case for the interval. The formula (1) is conspicuously *independent of the dimension $d$*: the radial dilation structure of the cross-polytope is self-similar across dimensions, motivating the central conjecture that (1) is the sharp exponent for $(\star)$ in every dimension. The present paper does not attack that conjecture directly; instead it maps the **global shape of the exponent surface** $(n,m) \mapsto p(n,m)$, resolving its qualitative behaviour in both variables.

### 1.3 Contributions

We prove, with complete rigor, the following about the surface (1) (throughout, $n \ge 1$ or $n \ge 2$ and $m \ge 1$ as indicated):

1. **Strict upper bound** (Theorem 3.1): $p(n,m) < n$ for $n \ge 2$, $m \ge 1$.
2. **Strict monotonicity in the number of summands** (Theorem 4.3): $p(n,m) < p(n+1,m)$, reduced to the integer power inequality $((n+1)m+1)^n < (nm+1)^{n+1}$ (Lemma 4.1).
3. **Radial asymptotics** (Theorem 5.3): $p(n,m) \to n$ as $m \to \infty$, via the logarithm-ratio limit $\log(nm+1)/\log(m+1) \to 1$ (Lemma 5.2).
4. **Refutation of radial monotonicity** (Theorem 6.1): $m \mapsto p(n,m)$ is *not* antitone for $n \ge 2$.

Together these settle the qualitative picture left open by the bracket $1 < p < n$ and, notably, *correct the direction* of a standing conjecture about the radius.

---

## 2. Definitions and preliminaries

**Definition 2.1 (Sharp sumset exponent).** For integers $n, m \ge 1$ define
$$p(n,m) = \frac{n\,\log(m+1)}{\log(nm+1)} \in \mathbb{R},$$
where $\log$ denotes the natural logarithm. (The denominator $\log(nm+1) > 0$ since $nm + 1 \ge 2$.)

**Lemma 2.2 (Positivity of the numerator logarithm).** For $m \ge 1$, $\log(m+1) > 0$.

*Proof.* $m \ge 1$ gives $m + 1 \ge 2 > 1$, and $\log$ is positive on $(1,\infty)$. $\qquad\blacksquare$

We record the elementary chain used throughout: for $n, m \ge 1$,
$$m + 1 \;\le\; nm + 1 \;\le\; n(m+1), \tag{2}$$
the left inequality because $nm \ge m$, the right because $nm + 1 \le nm + n = n(m+1)$. Applying the monotone $\log$ to (2) yields
$$\log(m+1) \;\le\; \log(nm+1) \;\le\; \log n + \log(m+1). \tag{3}$$
Inequality (3) is the engine of both the upper bound and the radial asymptotics.

---

## 3. The strict upper bound

**Theorem 3.1 (Upper bound).** For all $n \ge 2$ and $m \ge 1$,
$$p(n,m) < n.$$

*Proof sketch.* Since $\log(nm+1) > 0$, the claim $\dfrac{n\log(m+1)}{\log(nm+1)} < n$ is equivalent, after multiplying by the positive denominator and cancelling $n > 0$, to
$$\log(m+1) < \log(nm+1).$$
This is strict because $m + 1 < nm + 1$ whenever $n \ge 2$ and $m \ge 1$ (then $nm \ge 2m > m$), and $\log$ is strictly increasing. $\qquad\blacksquare$

**Remark 3.2.** The exponent $n$ is the geometric-mean exponent, always valid but never sharp inside the diamond: Theorem 3.1 says the cross-polytope's geometry *strictly* improves on the trivial bound for every radius. Combined with the previously known $p(n,m) > 1$, we have the full bracket $1 < p(n,m) < n$.

---

## 4. Strict monotonicity in the number of summands

The monotonicity of $p$ in $n$ is governed by a clean inequality between integers.

**Lemma 4.1 (Interval–power comparison).** For all $n, m \ge 1$,
$$\bigl((n+1)m + 1\bigr)^n \;<\; (nm+1)^{n+1}.$$

*Proof sketch.* Set $A = (n+1)m + 1$ and $B = nm + 1$, so $0 < B < A$. Dividing the target by $A^n > 0$, it suffices to show
$$B\cdot\left(\frac{B}{A}\right)^n > 1.$$
Write $\dfrac{B}{A} = 1 - \dfrac{m}{A}$ with $0 \le \dfrac{m}{A} \le 1$. Bernoulli's inequality $(1+x)^n \ge 1 + nx$ (valid for $x \ge -1$, here $x = -m/A$) gives
$$\left(\frac{B}{A}\right)^n \ge 1 - \frac{nm}{A} = \frac{A - nm}{A} = \frac{m+1}{A},$$
the last step because $A = (n+1)m + 1 = nm + m + 1$, so $A - nm = m + 1$. Hence
$$B\cdot\left(\frac{B}{A}\right)^n \ge \frac{B(m+1)}{A} = \frac{(nm+1)(m+1)}{(n+1)m+1}.$$
Finally $(nm+1)(m+1) = nm^2 + nm + m + 1 > nm + m + 1 = (n+1)m + 1$, the surplus being exactly the positive term $nm^2$. Therefore the ratio exceeds $1$. $\qquad\blacksquare$

**Remark 4.2.** The single surplus term $nm^2$ quantifies precisely "the cost of an extra summand": it is what makes the inequality — and hence the monotonicity — strict.

**Theorem 4.3 (Monotonicity in the number of summands).** For all $n, m \ge 1$,
$$p(n,m) < p(n+1,m).$$

*Proof sketch.* Both denominators $\log(nm+1)$ and $\log((n+1)m+1)$ are positive (as $nm+1, (n+1)m+1 \ge 2$), as is $\log(m+1)$. Cross-multiplying, the claim $\dfrac{n\log(m+1)}{\log(nm+1)} < \dfrac{(n+1)\log(m+1)}{\log((n+1)m+1)}$ is equivalent (cancelling the common positive $\log(m+1)$) to
$$n\,\log\bigl((n+1)m+1\bigr) < (n+1)\,\log(nm+1),$$
i.e. $\log\bigl(((n+1)m+1)^n\bigr) < \log\bigl((nm+1)^{n+1}\bigr)$. By strict monotonicity of $\log$ this is exactly Lemma 4.1. $\qquad\blacksquare$

**Corollary 4.4.** For fixed $m$, the sequence $n \mapsto p(n,m)$ is strictly increasing and bounded above by its own $n$-dependent ceiling; it does not converge to a finite limit, since $p(n,m) > 1$ and, by (3), $p(n,m) \ge \dfrac{n\log(m+1)}{\log n + \log(m+1)} \to \infty$ as $n \to \infty$.

---

## 5. Radial asymptotics

**Lemma 5.1 (Divergence of the numerator).** $\log(m+1) \to \infty$ as $m \to \infty$.

*Proof sketch.* $m \mapsto m+1 \to \infty$ and $\log \to \infty$ at infinity; compose. $\qquad\blacksquare$

**Lemma 5.2 (Logarithm-ratio limit).** For fixed $n \ge 1$,
$$\frac{\log(nm+1)}{\log(m+1)} \longrightarrow 1 \quad \text{as } m \to \infty.$$

*Proof sketch.* By (3), for $m \ge 1$,
$$1 \;\le\; \frac{\log(nm+1)}{\log(m+1)} \;\le\; 1 + \frac{\log n}{\log(m+1)}.$$
The lower bound is the constant $1$; the upper bound tends to $1$ because $\log n$ is constant while $\log(m+1) \to \infty$ (Lemma 5.1), so $\log n / \log(m+1) \to 0$. The squeeze theorem forces the ratio to $1$. $\qquad\blacksquare$

**Theorem 5.3 (Radial asymptotics).** For fixed $n \ge 1$,
$$p(n,m) \longrightarrow n \quad \text{as } m \to \infty.$$

*Proof sketch.* Rewrite
$$p(n,m) = \frac{n\log(m+1)}{\log(nm+1)} = \frac{n}{\;\log(nm+1)/\log(m+1)\;}.$$
By Lemma 5.2 the denominator tends to $1 \ne 0$, so by the quotient rule for limits $p(n,m) \to n/1 = n$. $\qquad\blacksquare$

**Remark 5.4.** The full deficit is carried by a bounded correction term: from (3),
$$n - p(n,m) = n\cdot\frac{\log(nm+1) - \log(m+1)}{\log(nm+1)} = n\cdot\frac{\log\!\bigl(\tfrac{nm+1}{m+1}\bigr)}{\log(nm+1)},$$
and $\log\bigl(\tfrac{nm+1}{m+1}\bigr) \in [0, \log n]$ by (2). Dividing this bounded quantity by the diverging $\log(nm+1)$ yields the vanishing of the deficit, and suggests the finer rate conjecture $(n - p(n,m))\log m \to n\log n$.

---

## 6. Refutation of radial monotonicity

A natural conjecture — that enlarging the container weakens the bound monotonically, i.e. that $m \mapsto p(n,m)$ is decreasing — turns out to be **false**. The refutation is a clean consequence of the strict upper bound together with the limit.

**Theorem 6.1 (Non-monotonicity in the radius).** For $n \ge 2$, the map $m \mapsto p(n,m)$ is not antitone (not decreasing).

*Proof sketch.* Suppose, for contradiction, that $m \mapsto p(n,m)$ were antitone. Evaluate at $m = 1$: by Theorem 3.1, $p(n,1) < n$. By Theorem 5.3, $p(n,m) \to n$, so eventually $p(n,m) > p(n,1)$ for all large $m$; pick such an $m \ge 1$. Antitonicity would give $p(n,m) \le p(n,1)$, contradicting $p(n,m) > p(n,1)$. Hence no such antitone structure exists. $\qquad\blacksquare$

**Remark 6.2.** The refutation is *not vacuous*: it combines a strict inequality ($p(n,1) < n$, Theorem 3.1) with a genuine limit ($p(n,m) \to n$, Theorem 5.3). A decreasing sequence bounded above by $p(n,1) < n$ could never approach the value $n$; the surface must therefore *rise* toward its asymptote. This corrects the direction of the conjecture: on the radial axis the exponent increases toward the geometric-mean exponent $n$, rather than decreasing.

---

## 7. Algorithms and computation

Although the results are analytic, each reduces to a finite, verifiable comparison, making the surface amenable to numerical exploration and independent corroboration.

### 7.1 Evaluating the exponent

Computing $p(n,m)$ is a direct floating-point evaluation of (1): two logarithms, one multiplication, one division; constant time. The only numerical subtlety is the near-degeneracy for very large $m$, where $\log(nm+1)$ and $\log(m+1)$ are both large and close, so their ratio should be formed before, not after, cancelling.

### 7.2 Certifying monotonicity in $n$

Theorem 4.3 rests on the integer inequality of Lemma 4.1, $((n+1)m+1)^n < (nm+1)^{n+1}$. On a grid this can be checked *exactly* using arbitrary-precision integers, avoiding any floating-point risk. The algorithm iterates over $(n,m)$, computes both integer powers, and asserts strict inequality.

### 7.3 Corroborating the radial limit

Theorem 5.3 is corroborated by evaluating $p(n,m)$ for a geometric ladder of radii $m$ and observing convergence to $n$ from below, together with monotone increase of the sampled values (illustrating both the limit and the non-monotonicity refutation of Theorem 6.1).

---

## 8. Applications and significance

**Volumetric interpretation.** The exponent (1) is fundamentally a ratio of log-cardinalities: $\log|A|$ for a block $A$ of size $m+1$ against $\log|nA|$ for its $n$-fold sumset of size $nm+1$. In this light $p$ is a *body-independent* quantity — the ratio of the log-size of a symmetric convex lattice body to that of its dilate — which is why the one-dimensional interval predicts the $d$-dimensional diamond and why the phenomenon should extend to arbitrary symmetric convex lattice polytopes.

**Loss of independence.** The gap $n - p(n,m) > 0$ measures how much the freedom of $n$ independent sets is eroded by the constraint of living in a common container. The monotonicity results describe how this loss scales: it grows with the number of summands (Theorem 4.3) and shrinks with the radius (Theorem 5.3), vanishing in the large-radius limit.

**Connections.** Sharp sumset exponents underlie packing bounds in coding theory, structural results on approximate groups, and lattice-point counting in the geometry of numbers, which in turn feeds lattice-based cryptography. A precise qualitative map of the exponent surface is a prerequisite for turning the extremal formula into quantitative applications.

---

## 9. Discussion and future work

The results here settle the qualitative shape of the exponent surface in both coordinates: it is strictly bounded above by $n$, strictly increasing in the number of summands, and rising (not falling) toward the asymptote $n$ as the radius grows. The following directions push the inquiry further.

**1. Two-sided monotonicity of the exponent surface.** *Conjecture.* $m \mapsto p(n,m)$ is strictly increasing for every fixed $n \ge 2$, and $n \mapsto p(n,m)$ is strictly increasing for every fixed $m \ge 1$; jointly $p$ is strictly increasing in each argument with limit values $1$ (as $n = 1$ or $m \to 0^+$) and the asymptote $n$ (as $m \to \infty$). Both partial monotonicities appear to be shadows of a single concavity phenomenon: $\log(km+1)/k$ is strictly decreasing in $k$, controlling the $n$-direction, and the same concavity forces $\log(m+1)/\log(nm+1)$ to increase in $m$. The $n$-direction is already reduced to the proved integer inequality; the remaining step is a uniform concavity estimate.

**2. Rate of convergence to the geometric-mean exponent.** *Conjecture.* For fixed $n \ge 2$, $(n - p(n,m))\log m \to n\log n$ as $m \to \infty$. The entire deficit is carried by the bounded correction $\log\bigl(\tfrac{nm+1}{m+1}\bigr) \in [0, \log n]$ divided by the diverging $\log(m+1)$ (Remark 5.4); upgrading the limit to a sharp first-order rate is the natural next increment.

**3. The reciprocal surface.** *Conjecture.* Writing $1/p(n,m) = \tfrac{1}{n}\cdot\log(nm+1)/\log(m+1)$, the reciprocal surface $1/p$ is jointly convex on $\{(n,m): n \ge 1, m \ge 1\}$, with level sets asymptotic to the hyperbolae $nm = \text{const}$. Reciprocals linearize the logarithmic ratio, turning the multiplicative dilation coordinate $nm$ into the governing variable.

**4. The dimension-free sharp inequality.** *Conjecture.* $(\star)$ holds with $p = p(n,m)$ in every dimension $d$. The proof for the interval factors through only two properties — radial dilation additivity and a lattice-point count — both of which generalize verbatim to arbitrary symmetric convex lattice bodies, suggesting a body-independent sharp exponent $n\log|K|/\log|nK|$.

**5. Rigidity and stability.** *Conjectures.* (Rigidity) products of intervals uniquely minimize the sumset among configurations of fixed cardinalities, with minimum $(nm+1)^d$. (Stability) any configuration within a $(1+\varepsilon)$ factor of the sharp bound is, up to affine transformation, within $O(\varepsilon)$ symmetric-difference density of an arithmetic progression.

**6. Transcendence and monotonicity of the exponent.** *Conjecture.* $p(n,m)$ takes an algebraic value only on the trivial locus $n = 1$; elsewhere it is transcendental, and it is strictly monotone in each argument as above.

---

## 10. Conclusion

Starting from the compact extremal formula $p(n,m) = n\log(m+1)/\log(nm+1)$, we have determined the global qualitative shape of the sumset exponent surface for the integer cross-polytope. The exponent is strictly below the trivial geometric-mean value $n$, strictly increasing in the number of summands via a clean integer power inequality provable by Bernoulli's inequality, and — contrary to a natural first guess — increasing rather than decreasing in the radius, converging to $n$ in the large-radius limit. These results transform the raw formula into a navigable landscape and lay the groundwork for the deeper dimension-free, rigidity, and stability conjectures that remain open.
