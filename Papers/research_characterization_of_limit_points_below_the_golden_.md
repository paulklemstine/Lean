# Limit Points of Largest Matching Roots Below the Golden-Ratio Threshold

**Author:** Aristotle
**Date:** 2026-07-13

## Abstract

Let $\tau = \tfrac{1}{2}(1+\sqrt5)$ denote the golden ratio and set the threshold
$$T = \sqrt{\tau} + \frac{1}{\sqrt{\tau}} = \sqrt{2+\sqrt5} \approx 2.058.$$
For a finite simple graph $G$, its *matching polynomial* has only real roots, and the *largest matching root* $\mu(G)$ is a natural spectral invariant. A conjectural picture — parallel to the Smith/Hoffman–Shearer theory of adjacency-eigenvalue limit points — asserts that the set of limit points of $\mu(G)$ lying below $T$ is a countable set of algebraic numbers manufactured by recursive constructions on the Dynkin families $A_n$ and $D_n$, with gaps at the transcendental values in between. This paper isolates and rigorously establishes the cleanest concrete instance of that picture: the **path family**. We define the path matching polynomials through the edge-deletion recurrence, prove the Chebyshev-type trigonometric evaluation $\mu(P_n)(2\cos\theta)\sin\theta = \sin((n+1)\theta)$, and deduce that the roots of $\mu(P_n)$ are exactly $\{2\cos(k\pi/(n+1)) : 1 \le k \le n\}$, so that the largest matching root of $P_n$ is $2\cos(\pi/(n+1))$. We show that these largest roots form a strictly increasing sequence contained in the open interval $(-T,T)$ and converging to $2$; that $2 < T$; and hence that $2$ is a genuine accumulation point of largest matching roots strictly below the golden threshold. As a decorative corollary, the largest matching root of $P_5$ equals the golden ratio exactly.

**Keywords:** matching polynomial, largest matching root, golden ratio, limit points, Chebyshev polynomials, Dynkin diagrams, spectral graph theory.

---

## 1. Introduction

### 1.1 Matchings and the matching polynomial

Let $G$ be a finite simple graph on $n$ vertices. A **$k$-matching** of $G$ is a set of $k$ pairwise vertex-disjoint edges, and we write $m(G,k)$ for the number of $k$-matchings, with the convention $m(G,0)=1$. The **matching polynomial** of $G$ is
$$\mu(G)(x) \;=\; \sum_{k\ge 0} (-1)^k\, m(G,k)\, x^{\,n-2k}.$$
It is a monic polynomial of degree $n$. The foundational analytic fact, due to Heilmann and Lieb, is that **all roots of $\mu(G)$ are real** and bounded in absolute value by $2\sqrt{\Delta-1}$, where $\Delta$ is the maximum degree. Consequently the **largest matching root**
$$\mu(G) := \max\{x\in\mathbb{R} : \mu(G)(x)=0\}$$
is well defined. (We follow the customary abuse of writing $\mu(G)$ both for the polynomial and for its largest root; context disambiguates.)

The largest matching root is a spectral invariant closely tied to adjacency eigenvalues: for a forest, the matching polynomial coincides with the characteristic polynomial of the adjacency matrix, so the matching roots are exactly the adjacency eigenvalues. Thus for trees, $\mu(G)$ is literally the spectral radius, and the study of its limit points continues the classical program of Smith, Hoffman, and Shearer for eigenvalue limit points.

### 1.2 The golden threshold and the conjectural picture

For adjacency eigenvalues, the spectral radii of connected graphs that do not exceed $2$ are exactly the Dynkin/extended-Dynkin diagrams (Smith's theorem), and the limit points of spectral radii just above $2$ are described by explicit algebraic families. The analogous programme for largest matching roots singles out the golden-ratio value
$$T = \sqrt{\tau} + \frac{1}{\sqrt{\tau}} = \sqrt{2+\sqrt5}, \qquad \tau = \frac{1+\sqrt5}{2}.$$

The governing conjecture is:

> **Conjecture (limit points below $T$).** There is a countable set $S \subseteq [-T,T]$ that is *exactly* the set of limit points of largest matching roots $\mu(G)$ over all finite graphs $G$ that are less than $T$ in absolute value. The elements of $S$ are algebraic numbers arising as accumulation points of spectra of specific infinite families built by recursive operations on the Dynkin diagrams $A_n$ and $D_n$; the complement $(-T,T)\setminus S$ consists of transcendental "gap" values at which no family accumulates.

The number $T$ plays the role of a phase-transition threshold: below it the achievable limit points are sparse and algebraic; the interesting structure — the $D_n$/$E$-type contributions — lives in the window $(2,T)$.

### 1.3 Contribution

This paper establishes the *cleanest concrete instance* of the picture: the family $\{A_n\} = \{P_n\}$ of paths. We give complete, self-contained proofs of the following.

1. The path matching polynomials $\mu(P_n)$ are monic of degree $n$, satisfy the edge-deletion recurrence, and take the value $n+1$ at $x=2$.
2. The Chebyshev-type evaluation $\mu(P_n)(2\cos\theta)\sin\theta = \sin((n+1)\theta)$.
3. The roots of $\mu(P_n)$ are exactly $2\cos(k\pi/(n+1))$ for $1\le k\le n$; hence the largest matching root of $P_n$ is $2\cos(\pi/(n+1))$.
4. The largest matching roots of paths form a strictly increasing sequence lying in $(-T,T)$ and converging to $2$.
5. The threshold arithmetic: $T = \sqrt{\tau}+1/\sqrt{\tau} = \sqrt{2+\sqrt5}$ and $2 < T$.
6. The capstone: $2$ is a genuine accumulation point of the set of largest matching roots, lying strictly below $T$.
7. A decorative identity: the largest matching root of $P_5$ is exactly $\tau$.

Everything rests only on elementary trigonometry, the degree–root count for real polynomials, and continuity of cosine.

---

## 2. The path matching polynomial

### 2.1 Definition via edge deletion

For the path $P_n$ on $n$ vertices, deleting the terminal edge yields the standard edge-deletion identity for matching polynomials. We take this recurrence as the definition.

**Definition 2.1.** The *path matching polynomials* $\mu(P_n) \in \mathbb{R}[x]$ are defined by
$$\mu(P_0) = 1, \qquad \mu(P_1) = x, \qquad \mu(P_{n+2}) = x\cdot \mu(P_{n+1}) - \mu(P_n).$$

The first few instances are
$$\mu(P_2) = x^2-1,\quad \mu(P_3) = x^3-2x,\quad \mu(P_4)=x^4-3x^2+1,\quad \mu(P_5)=x^5-4x^3+3x.$$
These are exactly $U_n(x/2)$, where $U_n$ is the Chebyshev polynomial of the second kind.

### 2.2 Degree and leading term

**Lemma 2.2 (Monicity).** For every $n$, $\mu(P_n)$ is monic.

*Proof sketch.* Two-step induction. The base cases $\mu(P_0)=1$ and $\mu(P_1)=x$ are monic. For the step, an auxiliary induction shows $\deg \mu(P_n) = n$; then $\deg \mu(P_n) < \deg\big(x\,\mu(P_{n+1})\big) = n+2$, so the leading coefficient of $x\,\mu(P_{n+1}) - \mu(P_n)$ equals that of $x\,\mu(P_{n+1})$, namely $1$. $\qquad\blacksquare$

**Lemma 2.3 (Degree).** For every $n$, $\deg \mu(P_n) = n$.

*Proof sketch.* Strong induction. The cases $n=0,1$ are immediate. For $n+2$, monicity gives $\deg(x\,\mu(P_{n+1})) = 1 + (n+1) = n+2$, which strictly exceeds $\deg \mu(P_n)=n$, so the subtraction does not cancel the top term and the degree is $n+2$. In particular $\mu(P_n) \ne 0$. $\qquad\blacksquare$

**Lemma 2.4 (Value at $2$).** $\mu(P_n)(2) = n+1$.

*Proof sketch.* Induction using the recurrence: $\mu(P_{n+2})(2) = 2(n+2) - (n+1) = n+3$. This confirms $x=2$ is never a root and, combined with §4, that the largest root approaches but never reaches $2$. $\qquad\blacksquare$

---

## 3. Roots via the trigonometric substitution

### 3.1 The Chebyshev evaluation

**Theorem 3.1 (Trigonometric evaluation).** For all $n\in\mathbb{N}$ and $\theta\in\mathbb{R}$,
$$\mu(P_n)(2\cos\theta)\cdot \sin\theta = \sin\big((n+1)\theta\big).$$

*Proof sketch.* Two-step induction on $n$. For $n=0$: $1\cdot\sin\theta = \sin\theta$. For $n=1$: $2\cos\theta\sin\theta = \sin 2\theta$. For the step, substitute $x=2\cos\theta$ into the recurrence and use the product-to-sum identities $\sin((n+2)\theta) = 2\cos\theta\,\sin((n+1)\theta) - \sin(n\theta)$, which is exactly the recurrence applied to the right-hand sides. $\qquad\blacksquare$

### 3.2 Locating the roots

**Lemma 3.2 (Roots).** For $1 \le k \le n$, the number $2\cos\!\big(\tfrac{k\pi}{n+1}\big)$ is a root of $\mu(P_n)$.

*Proof sketch.* Put $\theta = \tfrac{k\pi}{n+1}$ in Theorem 3.1. Then $\sin((n+1)\theta) = \sin(k\pi) = 0$, while $\theta\in(0,\pi)$ gives $\sin\theta > 0$. Dividing, $\mu(P_n)(2\cos\theta) = 0$. $\qquad\blacksquare$

**Theorem 3.3 (Complete root set and largest root).** For $n\ge 1$, the set of real roots of $\mu(P_n)$ is exactly
$$\Big\{\, 2\cos\!\Big(\tfrac{k\pi}{n+1}\Big) : 1 \le k \le n \,\Big\},$$
and its greatest element, attained at $k=1$, is
$$\mu(P_n) = 2\cos\!\Big(\frac{\pi}{n+1}\Big).$$

*Proof sketch.* The map $k \mapsto 2\cos(k\pi/(n+1))$ is injective on $\{1,\dots,n\}$: applying $\arccos$ (valid since the arguments lie in $(0,\pi)$) recovers $k$. This produces $n$ distinct roots of a degree-$n$ polynomial, which by the fundamental degree–root count are *all* of the roots. Since cosine is strictly decreasing on $[0,\pi]$, the largest value occurs at the smallest argument $k=1$, giving $2\cos(\pi/(n+1))$; monotonicity also shows every other root is no larger. $\qquad\blacksquare$

---

## 4. The sequence of largest matching roots

Write $a_n := \mu(P_n) = 2\cos\!\big(\tfrac{\pi}{n+1}\big)$ for the largest matching root of $P_n$ (Theorem 3.3), defined for $n \ge 1$.

**Lemma 4.1 (Positivity and boundedness).** $0 \le a_n < 2$ for all $n \ge 1$.

*Proof sketch.* The argument $\pi/(n+1)\in(0,\pi/2]$, so $\cos$ is nonnegative, giving $a_n\ge 0$. Strictly, $\cos(\pi/(n+1)) < \cos 0 = 1$ because $0 < \pi/(n+1)$, so $a_n < 2$. $\qquad\blacksquare$

**Lemma 4.2 (Strict monotonicity).** The sequence $(a_n)_{n\ge1}$ is strictly increasing.

*Proof sketch.* As $n$ increases, $\pi/(n+1)$ strictly decreases within $(0,\pi)$, and cosine is strictly decreasing there, so $\cos(\pi/(n+1))$ strictly increases; multiply by $2$. $\qquad\blacksquare$

**Lemma 4.3 (Convergence).** $\displaystyle\lim_{n\to\infty}a_n = 2$.

*Proof sketch.* $\pi/(n+1)\to 0$, and $\cos$ is continuous with $\cos 0 = 1$, so $2\cos(\pi/(n+1))\to 2$. $\qquad\blacksquare$

The concrete staircase begins
$$a_2 = 2\cos\tfrac{\pi}{3} = 1,\quad a_3 = 2\cos\tfrac{\pi}{4} = \sqrt2,\quad a_4 = 2\cos\tfrac{\pi}{5} = \tau,\quad a_5 = 2\cos\tfrac{\pi}{6} = \sqrt3,\quad a_6 = 2\cos\tfrac{\pi}{7} \approx 1.802,\ \ldots$$
(with $a_1 = 2\cos\tfrac{\pi}{2} = 0$).

---

## 5. The golden-ratio threshold

**Definition 5.1.** The golden ratio is $\tau = \tfrac12(1+\sqrt5)$ and the *golden threshold* is $T = \sqrt{2+\sqrt5}$.

**Lemma 5.2 ($\tau + 1/\tau = \sqrt5$).** Since $\tau^2 = \tau + 1$, we have $\tau + \tau^{-1} = \sqrt5$.

*Proof sketch.* Directly from $\tau = (1+\sqrt5)/2$: clearing denominators, $\tau + 1/\tau = \sqrt5$ reduces to the defining quadratic $\tau^2 - \sqrt5\,\tau + 1 = 0$, which $(1+\sqrt5)/2$ satisfies. $\qquad\blacksquare$

**Theorem 5.3 (Golden form of the threshold).**
$$T = \sqrt{\tau} + \frac{1}{\sqrt{\tau}}.$$

*Proof sketch.* Both sides are nonnegative, so it suffices to compare squares. We have $\big(\sqrt\tau + 1/\sqrt\tau\big)^2 = \tau + 2 + 1/\tau = 2 + (\tau + 1/\tau) = 2 + \sqrt5$ by Lemma 5.2, while $T^2 = 2+\sqrt5$ by definition. $\qquad\blacksquare$

**Theorem 5.4 (The threshold exceeds $2$).** $2 < T$.

*Proof sketch.* $T^2 = 2 + \sqrt5 > 4$ since $\sqrt5 > 2$; taking positive square roots gives $T > 2$. Numerically $T = \sqrt{2+\sqrt5} \approx 2.058$. $\qquad\blacksquare$

---

## 6. Capstone: accumulation below the golden fence

**Theorem 6.1 (Main theorem).** The largest matching roots $a_n = \mu(P_n)$ of the paths satisfy simultaneously:

1. **(Spectral meaning.)** For every $n\ge1$, $a_n = 2\cos(\pi/(n+1))$ is the largest matching root of $P_n$.
2. **(Monotonicity.)** $(a_n)_{n\ge1}$ is strictly increasing.
3. **(Confinement.)** $a_n \in (-T, T)$ for every $n\ge1$.
4. **(Limit.)** $a_n \to 2$.
5. **(Position of the limit.)** $2 < T$.

*Proof sketch.* Item 1 is Theorem 3.3; item 2 is Lemma 4.2; item 4 is Lemma 4.3; item 5 is Theorem 5.4. For item 3, Lemma 4.1 gives $0 \le a_n < 2 < T$, so $a_n < T$; and $a_n \ge 0 > -T$. $\qquad\blacksquare$

**Theorem 6.2 (Accumulation point).** The number $2$ is an accumulation point of the set $\{a_n : n\ge1\}$ of largest matching roots of paths.

*Proof sketch.* Given any neighborhood $U$ of $2$, convergence $a_n\to2$ (Lemma 4.3) yields $N$ with $a_n\in U$ for all $n\ge N$. Each such $a_n$ satisfies $a_n < 2$ (Lemma 4.1), so $a_n \ne 2$. Thus every neighborhood of $2$ contains a point of the set different from $2$: $2$ is an accumulation point. $\qquad\blacksquare$

Combining Theorems 6.1 and 6.2: **$2$ is a genuine accumulation point of largest matching roots that lies strictly below the golden threshold $T$**, and it is approached by an explicit, elementary, infinite family of graphs — the paths. This is the first fully rigorous landmark inside the golden fence.

**Corollary 6.3 (Golden identity).** The largest matching root of $P_4$ equals the golden ratio:
$$\mu(P_4) = 2\cos\frac{\pi}{5} = \frac{1+\sqrt5}{2} = \tau.$$

*Proof sketch.* By Theorem 3.3, $\mu(P_4) = 2\cos(\pi/5)$, and the classical value $\cos(\pi/5) = (1+\sqrt5)/4$ gives $2\cos(\pi/5) = \tau$. (Indeed $\mu(P_4) = x^4-3x^2+1$ has largest root $\sqrt{(3+\sqrt5)/2} = \tau$.) $\qquad\blacksquare$

---

## 7. Algorithms

The proofs are constructive and translate directly into computation.

### 7.1 Matching polynomial by recurrence

Compute $\mu(P_n)$ with the three-term recurrence, storing coefficient vectors. Cost: $O(n^2)$ arithmetic operations, $O(n)$ storage. This recovers the Chebyshev-of-the-second-kind coefficients.

### 7.2 Largest matching root in closed form

By Theorem 3.3 the largest root of $\mu(P_n)$ is $2\cos(\pi/(n+1))$ — an $O(1)$ closed-form evaluation, avoiding any numerical root-finding. As a cross-check, one may isolate the root numerically (e.g. by bisection on $[1,2)$ using the sign of the polynomial) and confirm agreement to machine precision.

### 7.3 Threshold and gap certification

Compute $T = \sqrt{2+\sqrt5}$ and verify $2 < T$ and $\mu_n < 2 < T$ for a range of $n$, certifying confinement inside the golden fence.

---

## 8. Applications and connections

- **Spectral graph theory.** For trees the matching polynomial is the adjacency characteristic polynomial, so the results here describe adjacency-spectral-radius limit points of paths and place them relative to the golden thresholds of Smith/Hoffman–Shearer theory.
- **Orthogonal polynomials.** The path matching polynomials are rescaled Chebyshev polynomials of the second kind; the trigonometric evaluation is the source of their orthogonality and root structure.
- **Statistical mechanics.** Matching polynomials are the monomer–dimer partition functions; the Heilmann–Lieb real-rootedness underlies the absence of phase transitions in dimer models, and largest roots control asymptotic growth rates.
- **Quasi-crystals and the golden ratio.** The exact appearance of $\tau$ as a matching frequency links combinatorial spectra to the golden-ratio structures pervasive in aperiodic tilings.

---

## 9. Discussion and future work

The path family is the $A_n$ backbone of a much larger conjectural landscape. Natural next steps:

1. **Cycles $C_n$.** Their matching polynomial satisfies $\mu(C_n) = \mu(P_n) - \mu(P_{n-2})$ and evaluates to $2\cos(n\theta)$ in disguise; the largest root is $2\cos(\pi/n)\to 2$. This gives a second family accumulating at $2$ and a warm-up for graph products and unions.

2. **The $D_n$ family and the window $(2,T)$.** The genuinely new content lives strictly between $2$ and $T$: limit points there arise from $D_n$/$E$-type recursive constructions (internal path subdivision à la Shearer/Hoffman). A tractable milestone is to exhibit a single explicit family — e.g. a fixed gadget attached to a growing path — whose largest matching roots converge to a value in $(2,T)$.

3. **General matching-polynomial API.** Define $\mu(G) = \sum_k (-1)^k m(G,k)\,x^{n-2k}$ for arbitrary finite simple graphs, prove the edge-deletion recurrence $\mu(G) = \mu(G-e) - \mu(G-u-v)$, and specialize to paths and forests (recovering adjacency eigenvalues), connecting $\mu(G)$ to Smith's theorem.

4. **Reality and interlacing.** Formalize Heilmann–Lieb real-rootedness (matching roots real, contained in $[-2\sqrt{\Delta-1}, 2\sqrt{\Delta-1}]$) via the recurrence and interlacing, making "largest matching root" well-defined for all graphs and putting the accumulation statements on the most general footing.

Completing this programme would yield a full determination of the limit-point set $S$ below the golden threshold — the algebraic values that are achievable and the transcendental gaps that are forbidden.

---

## Appendix: worked numerics

| path | $a_n = 2\cos\frac{\pi}{n+1}$ | value |
|----|----|----|
| $P_2$ | $2\cos\frac{\pi}{3}$ | $1$ |
| $P_3$ | $2\cos\frac{\pi}{4}$ | $\sqrt2\approx1.41421$ |
| $P_4$ | $2\cos\frac{\pi}{5}$ | $\tau\approx1.61803$ |
| $P_5$ | $2\cos\frac{\pi}{6}$ | $\sqrt3\approx1.73205$ |
| $P_{11}$ | $2\cos\frac{\pi}{12}$ | $\approx1.93185$ |
| $P_{101}$ | $2\cos\frac{\pi}{102}$ | $\approx1.99810$ |

The staircase climbs strictly, never reaching $2$, and stays below $T \approx 2.05817$.
