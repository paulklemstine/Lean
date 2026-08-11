# Spectral Bounds on Non-Homogeneous Quadratic Forms over the Integer Lattice

**Author:** Aristotle
**Date:** 2026-08-11

## Abstract

We develop a self-contained quantitative theory of non-homogeneous (shifted) quadratic Diophantine problems
$$Q(x - t) = c, \qquad x \in \mathbb{Z}^n,$$
where $Q(x) = \sum_{i,j} A_{ij} x_i x_j$ is a real quadratic form and $t \in \mathbb{R}^n$ a fixed shift. The only structural hypothesis is a *spectral sandwich*: $m\|x\|^2 \le Q(x) \le M\|x\|^2$ for all $x \in \mathbb{R}^n$, which for symmetric $A$ is equivalent to all eigenvalues lying in $[m, M]$.

We prove: (i) a **spectral gap** $Q(x-t) \ge m\, d(t, \mathbb{Z}^n)^2$ valid for all integer $x$, hence a Diophantine obstruction excluding every target value below the gap; (ii) an **effective rational gap** $m/q^2$ for shifts with denominator $q$; (iii) a matching **covering bound** $\min_x Q(x-t) \le Mn/4$ obtained by coordinatewise rounding, giving the two-sided sandwich $m\,d(t,\mathbb{Z}^n)^2 \le \mu(Q,t) \le Mn/4$ for the inhomogeneous minimum; (iv) **two-sided counting estimates** $\left(2\sqrt{R/(Mn)} - 1\right)^n \le N(R) \le \left(2\sqrt{R/m} + 1\right)^n$ for the number of integer solutions of $Q(x-t) \le R$ beyond the covering threshold, so $N(R) \asymp R^{n/2}$; (v) convergence, diagonal factorisation, an explicit lower bound, and gap-rate exponential decay for the **inhomogeneous theta series** $\Theta(s) = \sum_{x \in \mathbb{Z}^n} e^{-sQ(x-t)}$, together with $\Theta(s) \to 0$ as $s \to \infty$ whenever the shift is off the lattice; and (vi) a complete determination of the **extremal set** for the half-shifted sum of squares: $\sum_i (x_i - \tfrac12)^2 \ge n/4$ with equality exactly on the $2^n$ vertices of the unit cube.

All bounds are explicit in $m$, $M$, $n$, and the denominator of the shift, and all proofs are elementary — the deepest tool used is comparison of a Gaussian sum with a geometric series.

**Keywords:** non-homogeneous quadratic form, inhomogeneous minimum, spectral gap, lattice reduction, covering radius, theta series, Diophantine obstruction, representation numbers.

---

## 1. Introduction

### 1.1 The problem

Classical Diophantine theory of quadratic forms concerns the *homogeneous* equation $Q(x) = c$ with $x \in \mathbb{Z}^n$; the local–global machinery (Hasse–Minkowski, the circle method, Siegel's mass formula) is largely built for that case. The *non-homogeneous*, or *shifted*, problem
$$Q(x - t) = c, \qquad x \in \mathbb{Z}^n, \; t \in \mathbb{R}^n \text{ fixed},$$
behaves quite differently. It has no trivial solution: the point $x = 0$ carries no privilege once the form is recentred at $t$. Congruence obstructions weaken or disappear when $t$ is irrational. And the fundamental invariant becomes a *geometric* one — the inhomogeneous minimum
$$\mu(Q, t) \;=\; \inf_{x \in \mathbb{Z}^n} Q(x - t),$$
which measures the radius of the smallest $Q$-ellipsoid centred at $t$ that meets $\mathbb{Z}^n$. Supremising $\mu$ over $t$ recovers the squared covering radius of the lattice in the geometry of $Q$.

This invariant is the crux of several modern subjects. In lattice-based cryptography it is the objective of the closest vector problem; in coding theory it is a minimum-distance guarantee; in statistical mechanics it is the ground-state energy of a lattice model whose partition function is the theta series of $Q$ shifted by $t$.

### 1.2 What we prove, and the hypothesis we use

We work under a single hypothesis that abstracts away everything about $A$ except its extremes of stretching. The resulting theory is deliberately *soft* and *uniform*: every bound depends only on the pair $(m, M)$, on the dimension $n$, and on the arithmetic of the shift, and every constant is explicit. The novelty is not in any individual inequality — several are folklore in one form or another — but in the systematic assembly: gap, covering, counting, and theta behaviour all follow from one elementary lattice-reduction estimate, and each of the four is sharp in the model case of the half-shifted sum of squares, where all inequalities collapse to equalities and the extremal set is determined exactly.

### 1.3 Organisation

Section 2 fixes definitions. Section 3 proves the lattice-reduction estimate and the spectral gap, with the effective rational refinement. Section 4 gives the covering bound and the sandwich for $\mu(Q,t)$, together with the solvability window. Section 5 proves the two-sided counting theorem. Section 6 treats the theta series. Section 7 determines the extremal set in the model case. Section 8 gives algorithms; Section 9 applications; Section 10 discussion and open problems.

---

## 2. Definitions and standing conventions

Throughout, $n \ge 0$ is an integer, indices run over $\{1, \dots, n\}$, and $x$ ranges over $\mathbb{R}^n$ or $\mathbb{Z}^n$ as indicated.

**Definition 2.1 (Squared norm).** For $x \in \mathbb{R}^n$, $\|x\|^2 = \sum_{i=1}^n x_i^2$.

**Definition 2.2 (Quadratic form of a matrix).** For a real $n \times n$ matrix $A$,
$$Q_A(x) \;=\; \sum_{i=1}^n \sum_{j=1}^n A_{ij}\, x_i x_j .$$
We write $Q$ for $Q_A$ when $A$ is clear. Note that only the symmetric part of $A$ affects $Q_A$.

**Definition 2.3 (Spectral bounds).** $A$ *has spectral bounds* $m, M \in \mathbb{R}$ if
$$m\,\|x\|^2 \;\le\; Q_A(x) \;\le\; M\,\|x\|^2 \qquad \text{for all } x \in \mathbb{R}^n .$$
For symmetric $A$ this holds precisely when every eigenvalue of $A$ lies in $[m, M]$ (Rayleigh's principle); the definition above is used in preference to eigenvalues because it is what every proof actually consumes, and because it applies verbatim to non-symmetric $A$.

**Definition 2.4 (Non-homogeneous evaluation).** For a shift $t \in \mathbb{R}^n$ and $x \in \mathbb{Z}^n$,
$$E_A(t, x) \;=\; Q_A\big( (x_i - t_i)_{i} \big) .$$
We write $Q(x-t)$ for $E_A(t,x)$ in prose.

**Definition 2.5 (Distance to $\mathbb{Z}$).** For $u \in \mathbb{R}$,
$$d_{\mathbb{Z}}(u) \;=\; \min\big(\{u\},\, 1 - \{u\}\big),$$
where $\{u\} = u - \lfloor u \rfloor$ is the fractional part. Then $0 \le d_{\mathbb{Z}}(u) \le \tfrac12$, with $d_{\mathbb{Z}}(u) = 0$ iff $u \in \mathbb{Z}$.

**Definition 2.6 (Squared lattice distance).** For $t \in \mathbb{R}^n$,
$$d(t, \mathbb{Z}^n)^2 \;=\; \sum_{i=1}^n d_{\mathbb{Z}}(t_i)^2 .$$

**Definition 2.7 (Inhomogeneous minimum).** $\displaystyle \mu(Q_A, t) \;=\; \inf_{x \in \mathbb{Z}^n} E_A(t, x)$.

**Definition 2.8 (Inhomogeneous theta series).** For $s > 0$,
$$\Theta_{A, t}(s) \;=\; \sum_{x \in \mathbb{Z}^n} \exp\big(-s\, E_A(t,x)\big),$$
whenever the family is summable (Theorem 6.1 guarantees this for $m > 0$).

**Example 2.9 (Diagonal forms).** If $A = \operatorname{diag}(d_1, \dots, d_n)$ then $Q_A(x) = \sum_i d_i x_i^2$. If $m \le d_i \le M$ for all $i$, then $A$ has spectral bounds $m, M$; the proof is termwise comparison, $m x_i^2 \le d_i x_i^2 \le M x_i^2$, summed. In particular the identity matrix gives the sum of squares with $m = M = 1$.

---

## 3. Lattice reduction and the spectral gap

### 3.1 The elementary estimate

**Lemma 3.1 (Nearest-integer estimate).** For all $u \in \mathbb{R}$ and $k \in \mathbb{Z}$,
$$d_{\mathbb{Z}}(u) \;\le\; |u - k| .$$

*Proof.* Write $u = \lfloor u \rfloor + \{u\}$. If $k \le \lfloor u \rfloor$ then $u - k \ge \{u\} \ge d_{\mathbb{Z}}(u)$, and $u-k \ge 0$, so $|u-k| \ge d_{\mathbb{Z}}(u)$. If $k \ge \lfloor u \rfloor + 1$ then $k - u \ge 1 - \{u\} \ge d_{\mathbb{Z}}(u)$ and again $|u - k| \ge d_{\mathbb{Z}}(u)$. $\square$

**Corollary 3.2.** $d_{\mathbb{Z}}(u)^2 \le (u - k)^2$ for all $u \in \mathbb{R}$, $k \in \mathbb{Z}$; and consequently, for all $t \in \mathbb{R}^n$, $x \in \mathbb{Z}^n$,
$$d(t, \mathbb{Z}^n)^2 \;\le\; \|x - t\|^2 .$$

*Proof.* Square Lemma 3.1 (both sides nonnegative) and sum over coordinates. $\square$

**Lemma 3.3 (Positivity off the lattice).** If $\{u\} \neq 0$ then $d_{\mathbb{Z}}(u) > 0$. Hence if some coordinate $t_{i}$ has $\{t_{i}\} \neq 0$, then $d(t, \mathbb{Z}^n)^2 > 0$.

*Proof.* $0 < \{u\} < 1$ forces both $\{u\} > 0$ and $1 - \{u\} > 0$; the sum $\sum_i d_{\mathbb{Z}}(t_i)^2$ has nonnegative terms and one strictly positive term. $\square$

### 3.2 The gap theorem

**Theorem 3.4 (Spectral gap lower bound).** Let $A$ have spectral bounds $m, M$ with $m \ge 0$, and let $t \in \mathbb{R}^n$. Then for every $x \in \mathbb{Z}^n$,
$$Q(x - t) \;\ge\; m\, d(t, \mathbb{Z}^n)^2 .$$

*Proof.* By Corollary 3.2 and $m \ge 0$, $m\,d(t,\mathbb{Z}^n)^2 \le m\|x - t\|^2$; by the lower spectral bound applied to the vector $x - t$, $m\|x-t\|^2 \le Q(x-t)$. $\square$

**Theorem 3.5 (Strict positivity).** If moreover $m > 0$ and some coordinate of $t$ is non-integral, then $Q(x - t) > 0$ for every $x \in \mathbb{Z}^n$.

*Proof.* Combine Theorem 3.4 with Lemma 3.3. $\square$

**Theorem 3.6 (Diophantine obstruction).** Under the hypotheses of Theorem 3.4, if $c < m\, d(t, \mathbb{Z}^n)^2$ then the equation $Q(x-t) = c$ has no solution $x \in \mathbb{Z}^n$.

*Proof.* A solution would give $c = Q(x-t) \ge m\,d(t,\mathbb{Z}^n)^2 > c$. $\square$

We call $[0,\; m\,d(t,\mathbb{Z}^n)^2)$ the **forbidden zone** of the pair $(Q, t)$. It is a purely geometric obstruction: no congruence or local condition is involved, and it persists for irrational shifts where congruence reasoning is unavailable.

**Theorem 3.7 (Half-integral shift).** If $\{t_i\} = \tfrac12$ for every $i$, then $d(t, \mathbb{Z}^n)^2 = n/4$, and hence $Q(x - t) \ge mn/4$ for all $x \in \mathbb{Z}^n$.

*Proof.* $d_{\mathbb{Z}}(t_i) = \min(\tfrac12, \tfrac12) = \tfrac12$, so the sum of squares is $n \cdot \tfrac14$. Apply Theorem 3.4. $\square$

**Corollary 3.8 (Half-shifted sum of squares).** For every $x \in \mathbb{Z}^n$,
$$\sum_{i=1}^n \left(x_i - \tfrac12\right)^2 \;\ge\; \frac n4 .$$
Consequently $\sum_i (x_i - \tfrac12)^2 = c$ has no integer solution for $c < n/4$.

*Proof.* Apply Theorem 3.7 to $A = I$ (spectral bounds $m = M = 1$ by Example 2.9) and $t = (\tfrac12, \dots, \tfrac12)$, noting $Q_I(x - t) = \sum_i (x_i - \tfrac12)^2$. $\square$

### 3.3 Effective gaps at rational shifts

The gap in Theorem 3.4 is stated with the real quantity $d(t,\mathbb{Z}^n)$, which may be hard to evaluate. For rational shifts it becomes explicit.

**Lemma 3.9 (Denominator bound).** Let $a, q \in \mathbb{Z}$ with $q > 0$ and $q \nmid a$. Then
$$d_{\mathbb{Z}}\!\left(\frac aq\right) \;\ge\; \frac 1q .$$

*Proof.* Write $L = \lfloor a/q \rfloor$ and $r = a - qL$, so $\{a/q\} = r/q$ with $0 \le r < q$ and $r \neq 0$ since $q \nmid a$. Thus $1 \le r \le q - 1$, whence $\{a/q\} = r/q \ge 1/q$ and $1 - \{a/q\} = (q - r)/q \ge 1/q$. The minimum of the two is therefore at least $1/q$. $\square$

**Theorem 3.10 (Effective spectral gap at a rational shift).** Let $A$ have spectral bounds $m \ge 0$, $M$, let $q \in \mathbb{Z}_{>0}$, and let $t_i = a_i/q$ with $a_i \in \mathbb{Z}$. If $q \nmid a_{i_0}$ for some index $i_0$, then for every $x \in \mathbb{Z}^n$,
$$Q(x - t) \;\ge\; \frac{m}{q^2} .$$

*Proof.* By Lemma 3.9, $d_{\mathbb{Z}}(t_{i_0})^2 \ge 1/q^2$, and $d(t,\mathbb{Z}^n)^2 \ge d_{\mathbb{Z}}(t_{i_0})^2$ since the omitted terms are nonnegative. Multiply by $m \ge 0$ and apply Theorem 3.4. $\square$

**Corollary 3.11.** Under the hypotheses of Theorem 3.10, $Q(x - t) = c$ has no integer solution for $c < m/q^2$.

The shape $m/q^2$ is exactly the quadratic-form analogue of the classical fact that a rational non-integer $a/q$ is at distance $\ge 1/q$ from $\mathbb{Z}$; the exponent $2$ reflects the quadratic nature of $Q$.

---

## 4. Covering: the matching upper bound

**Theorem 4.1 (Rounding / covering bound).** Let $A$ have spectral bounds $m$, $M$ with $M \ge 0$, and let $t \in \mathbb{R}^n$. Then there exists $x_0 \in \mathbb{Z}^n$ with
$$Q(x_0 - t) \;\le\; \frac{Mn}{4}.$$

*Proof.* Take $x_0 = (\operatorname{round}(t_i))_i$, rounding each coordinate to a nearest integer. Then $|t_i - \operatorname{round}(t_i)| \le \tfrac12$, so $\|x_0 - t\|^2 = \sum_i (x_{0,i} - t_i)^2 \le n/4$. The upper spectral bound gives $Q(x_0 - t) \le M\|x_0 - t\|^2 \le Mn/4$. $\square$

**Theorem 4.2 (Spectral sandwich for the inhomogeneous minimum).** Let $A$ have spectral bounds $m \ge 0$, $M \ge 0$, and $t \in \mathbb{R}^n$. Then
$$m\, d(t,\mathbb{Z}^n)^2 \;\le\; \mu(Q, t) \;\le\; \frac{Mn}{4}.$$

*Proof.* By Theorem 3.4 the set $\{Q(x-t) : x \in \mathbb{Z}^n\}$ is bounded below by $m\,d(t,\mathbb{Z}^n)^2$; hence the infimum exists and is at least that value. By Theorem 4.1 the infimum is at most $Q(x_0 - t) \le Mn/4$. $\square$

**Remark 4.3 (Sharpness).** For $A = I$ and $t$ half-integral, $m = M = 1$ and $d(t,\mathbb{Z}^n)^2 = n/4$, so both sides equal $n/4$: the sandwich is an equality and $\mu = n/4$ exactly. In general the two ends differ by the factor $(M/m) \cdot \big(n/(4 d(t,\mathbb{Z}^n)^2)\big) \ge M/m$, so the sandwich is tightest for well-conditioned forms and shifts near the deep hole.

**Theorem 4.4 (Solvability window).** Let $A$ have spectral bounds $m \ge 0$, $M \ge 0$. Then:

1. for every $R \ge Mn/4$, there exists $x \in \mathbb{Z}^n$ with $Q(x-t) \le R$;
2. for every $R < m\,d(t,\mathbb{Z}^n)^2$, there is no $x \in \mathbb{Z}^n$ with $Q(x-t) \le R$.

*Proof.* (1) is Theorem 4.1 plus transitivity; (2) is Theorem 3.4 plus transitivity. $\square$

Thus $[m\,d(t,\mathbb{Z}^n)^2,\; Mn/4]$ is the *undetermined band*: outside it, solvability of $Q(x-t) \le R$ is decided by the two constants alone; inside it, the answer depends on the finer arithmetic of $A$ and $t$.

---

## 5. Counting integer solutions

Let $N(R) = \#\{x \in \mathbb{Z}^n : Q(x - t) \le R\}$ (finite when $m>0$, by Theorem 5.2).

**Lemma 5.1 (Coordinatewise localisation).** Let $A$ have spectral bounds $m > 0$, $M$. If $Q(x - t) \le R$ then for every index $i$,
$$|x_i - t_i| \;\le\; \sqrt{R/m}.$$

*Proof.* $m\|x-t\|^2 \le Q(x-t) \le R$ gives $\|x-t\|^2 \le R/m$; since $(x_i - t_i)^2$ is one nonnegative term of $\|x-t\|^2$, it is at most $R/m$; take square roots. $\square$

**Theorem 5.2 (Counting upper bound).** Let $A$ have spectral bounds $m > 0$, $M$. Any finite set $S \subseteq \mathbb{Z}^n$ of solutions of $Q(x-t) \le R$ satisfies
$$\#S \;\le\; \left(2\sqrt{R/m} + 1\right)^n .$$
In particular $N(R) \le (2\sqrt{R/m}+1)^n$: representation numbers grow at most polynomially in $\sqrt R$.

*Proof.* Put $r = \sqrt{R/m}$. By Lemma 5.1, $S$ is contained in the product of integer intervals $\prod_i \big(\mathbb{Z} \cap [t_i - r,\, t_i + r]\big)$. The $i$-th factor is $\{\lceil t_i - r\rceil, \dots, \lfloor t_i + r \rfloor\}$, of cardinality $\max(0, \lfloor t_i + r\rfloor + 1 - \lceil t_i - r \rceil)$, and since $\lfloor t_i + r\rfloor \le t_i + r$ and $\lceil t_i - r\rceil \ge t_i - r$, this is at most $2r + 1$. Multiplying the $n$ factors gives the bound. $\square$

**Theorem 5.3 (Counting lower bound above the covering threshold).** Let $A$ have spectral bounds $m$, $M$ with $M > 0$, let $n \ge 1$, and let $R \ge Mn/4$. Then there exists a finite set $S$ of integer solutions of $Q(x-t) \le R$ with
$$\#S \;\ge\; \left(2\sqrt{\frac{R}{Mn}} - 1\right)^{n} .$$

*Proof.* Put $p = \sqrt{R/(Mn)}$; the hypothesis $R \ge Mn/4$ gives $p \ge \tfrac12$, so $2p - 1 \ge 0$. Let $S = \prod_i \big(\mathbb{Z} \cap [t_i - p, t_i + p]\big)$. Every $x \in S$ satisfies $(x_i - t_i)^2 \le p^2$ for each $i$, hence $\|x - t\|^2 \le n p^2 = R/M$, hence by the upper spectral bound $Q(x-t) \le M\|x-t\|^2 \le R$: all elements of $S$ are solutions. Each factor of $S$ has cardinality $\lfloor t_i + p\rfloor + 1 - \lceil t_i - p\rceil \ge (t_i + p - 1) + 1 - (t_i - p + 1) = 2p - 1$, and multiplying $n$ nonnegative factors gives the claim. $\square$

**Theorem 5.4 (Two-sided counting).** Let $A$ have spectral bounds $m > 0$, $M > 0$, let $n \ge 1$, and let $R \ge Mn/4$. Then there is a finite set $S$ of integer solutions of $Q(x - t) \le R$ with
$$\left(2\sqrt{\frac{R}{Mn}} - 1\right)^{n} \;\le\; \#S \;\le\; \left(2\sqrt{\frac{R}{m}} + 1\right)^{n} .$$

*Proof.* Take $S$ from Theorem 5.3 and apply Theorem 5.2 to it. $\square$

**Corollary 5.5 (Growth order).** For fixed $n, m, M$ and $R \to \infty$,
$$\left(\frac{2}{\sqrt{Mn}}\right)^{n} R^{n/2}(1 + o(1)) \;\le\; N(R) \;\le\; \left(\frac{2}{\sqrt m}\right)^{n} R^{n/2}(1+o(1)),$$
so $N(R) \asymp R^{n/2}$ with constants depending only on $m$, $M$, $n$.

The exponent $n/2$ is of course the correct volume-heuristic order: the region $\{Q(y) \le R\}$ is an ellipsoid of volume $\propto R^{n/2}$. What is gained here is that the constants are explicit and require no regularity or symmetry of $A$ whatsoever — only the sandwich.

---

## 6. The inhomogeneous theta series

Define $\Theta(s) = \Theta_{A,t}(s) = \sum_{x \in \mathbb{Z}^n} e^{-sQ(x-t)}$.

### 6.1 Convergence

**Lemma 6.0 (One-dimensional Gaussian sums).** For $c > 0$ and $a \in \mathbb{R}$, the family $\big(e^{-c(k-a)^2}\big)_{k \in \mathbb{Z}}$ is summable.

*Proof sketch.* For $k \in \mathbb{N}$, the elementary inequality $(k - a)^2 \ge k - \tfrac{(2a+1)^2}{4}$ (equivalent to $\big(k - \tfrac{2a+1}{2}\big)^2 \ge 0$ after expansion) gives $e^{-c(k-a)^2} \le e^{c(2a+1)^2/4}\, e^{-ck}$, a convergent geometric series. The sum over negative integers is the same statement with $a$ replaced by $-a$. $\square$

**Theorem 6.1 (Convergence of the inhomogeneous theta series).** Let $A$ have spectral bounds $m > 0$, $M$, let $t \in \mathbb{R}^n$ and $s > 0$. Then $\big(e^{-sQ(x-t)}\big)_{x \in \mathbb{Z}^n}$ is summable, so $\Theta(s)$ is well defined and positive.

*Proof.* By the lower spectral bound, $Q(x-t) \ge m\|x-t\|^2$, hence
$$e^{-sQ(x-t)} \;\le\; e^{-sm\|x-t\|^2} \;=\; \prod_{i=1}^n e^{-sm(x_i - t_i)^2}.$$
Each one-dimensional factor is summable over $\mathbb{Z}$ by Lemma 6.0 with $c = sm > 0$; a product over $n$ coordinates of nonnegative summable families is summable over $\mathbb{Z}^n$ (by induction on $n$, splitting $\mathbb{Z}^{n+1} \cong \mathbb{Z} \times \mathbb{Z}^n$ and using Fubini–Tonelli for nonnegative families). Domination by a summable family finishes the proof. $\square$

### 6.2 Bounds from the sandwich

**Theorem 6.2 (Lower bound from covering).** Let $A$ have spectral bounds $m > 0$, $M \ge 0$, and $s > 0$. Then
$$\Theta(s) \;\ge\; \exp\!\left(-\frac{sMn}{4}\right).$$

*Proof.* By Theorem 4.1 there is $x_0$ with $Q(x_0-t) \le Mn/4$, hence the single term $e^{-sQ(x_0-t)} \ge e^{-sMn/4}$; all other terms are positive, so the sum dominates it. $\square$

**Theorem 6.3 (Exponential decay at the gap rate).** Let $A$ have spectral bounds $m > 0$, $M$, and let $0 < s_0 \le s$. Then
$$\Theta(s) \;\le\; \exp\!\big(-(s - s_0)\,m\,d(t,\mathbb{Z}^n)^2\big)\;\Theta(s_0).$$

*Proof.* Fix $x \in \mathbb{Z}^n$ and write $g = m\,d(t,\mathbb{Z}^n)^2$. By Theorem 3.4, $Q(x-t) \ge g$, and since $s - s_0 \ge 0$,
$$-sQ(x-t) \;=\; -(s-s_0)Q(x-t) - s_0 Q(x-t) \;\le\; -(s - s_0) g - s_0 Q(x-t).$$
Exponentiating gives a termwise bound; summing over $x$ (both families summable by Theorem 6.1) and pulling out the constant yields the claim. $\square$

**Corollary 6.4 (Decay to zero).** If $m > 0$ and some coordinate of $t$ is non-integral, then $\Theta(s) \to 0$ as $s \to \infty$.

*Proof.* By Lemma 3.3 the gap $g = m\,d(t,\mathbb{Z}^n)^2$ is strictly positive. Taking $s_0 = 1$ in Theorem 6.3, $0 \le \Theta(s) \le e^{-(s-1)g}\,\Theta(1) \to 0$ as $s \to \infty$; squeeze. $\square$

This is the analytic shadow of Theorem 3.5: $\Theta(s) \to 0$ says exactly that no lattice point sits at zero energy, i.e. that $Q(x - t) = 0$ is unsolvable. By contrast, when $t \in \mathbb{Z}^n$ the term $x = t$ contributes $1$ for all $s$, and $\Theta(s) \to 1$.

Together, Theorems 6.2 and 6.3 sandwich the logarithmic decay rate:
$$m\,d(t,\mathbb{Z}^n)^2 \;\le\; \liminf_{s\to\infty} \frac{-\log \Theta(s)}{s} \;\le\; \limsup_{s\to\infty}\frac{-\log\Theta(s)}{s} \;\le\; \frac{Mn}{4},$$
i.e. the decay rate obeys the same sandwich as $\mu(Q,t)$ — as it must, since heuristically the rate *is* $\mu(Q,t)$ (see Section 10, Problem C2).

### 6.3 Factorisation for diagonal forms

**Theorem 6.5 (Diagonal factorisation).** Let $A = \operatorname{diag}(d_1,\dots,d_n)$ with all $d_i > 0$, let $t \in \mathbb{R}^n$ and $s > 0$. Then
$$\Theta(s) \;=\; \prod_{i=1}^{n} \; \sum_{k \in \mathbb{Z}} \exp\!\big(-s d_i (k - t_i)^2\big),$$
an $n$-fold product of one-dimensional shifted Jacobi theta values.

*Proof.* For diagonal $A$, $Q(x-t) = \sum_i d_i (x_i - t_i)^2$, so each summand of $\Theta$ factors as $\prod_i e^{-s d_i (x_i-t_i)^2}$. Each factor family is summable over $\mathbb{Z}$ (Lemma 6.0, $c = sd_i > 0$) and nonnegative, so the sum over $\mathbb{Z}^n$ of the product equals the product of the sums, by induction on $n$ with Fubini–Tonelli at each step. $\square$

In terms of the classical Jacobi theta function $\vartheta_3(z, q) = \sum_{k\in\mathbb{Z}} q^{k^2} e^{2\pi i k z}$, each factor is a shifted-argument value; the point of the theorem is structural, that all the difficulty of the $n$-dimensional problem sits in the off-diagonal entries of $A$.

---

## 7. Extremal structure: the half-shifted sum of squares

Take $A = I$, $t = (\tfrac12,\dots,\tfrac12)$, so $Q(x-t) = \sum_i (x_i - \tfrac12)^2$, $m = M = 1$, and by Remark 4.3 the sandwich is exact: $\mu = n/4$. We determine the full set of minimisers.

**Lemma 7.1 (One-coordinate extremality).** For every $k \in \mathbb{Z}$, $\big(k - \tfrac12\big)^2 \ge \tfrac14$, with equality if and only if $k \in \{0,1\}$.

*Proof.* $\big(k-\tfrac12\big)^2 - \tfrac14 = k^2 - k = k(k-1)$, which is a product of consecutive integers, hence $\ge 0$, and $= 0$ exactly when $k = 0$ or $k = 1$. $\square$

**Theorem 7.2 (Exact extremal set).** For $x \in \mathbb{Z}^n$,
$$\sum_{i=1}^n \left(x_i - \tfrac12\right)^2 \;\le\; \frac n4 \qquad \Longleftrightarrow \qquad x_i \in \{0,1\} \text{ for every } i .$$

*Proof.* ($\Leftarrow$) If every $x_i \in \{0,1\}$ then each term equals $\tfrac14$ by Lemma 7.1 and the sum is $n/4$. ($\Rightarrow$) By Lemma 7.1 each term is $\ge \tfrac14$; if the total is $\le n/4$ then the total equals $n/4$ and, a sum of terms each at least a fixed lower bound being equal to the sum of those bounds, every term must equal $\tfrac14$. Equality in Lemma 7.1 forces $x_i \in \{0,1\}$. $\square$

**Theorem 7.3 (Multiplicity of the minimum).** The set of $x \in \mathbb{Z}^n$ with $\sum_i (x_i - \tfrac12)^2 \le n/4$ is finite, equal to $\{0,1\}^n$ — the vertex set of the unit cube — and has cardinality exactly $2^n$.

*Proof.* Immediate from Theorem 7.2: the solution set is the product of $n$ copies of $\{0,1\}$, of cardinality $2^n$. $\square$

So the inhomogeneous minimum $n/4$ is attained with exponential multiplicity $2^n$. It is instructive to compare with the counting theorem: at $R = n/4$, Theorem 5.2 gives the upper bound $(2\sqrt{n/4} + 1)^n = (\sqrt n + 1)^n$ for the number of solutions, which is far larger than the truth $2^n$ but of the same *exponential type in $n$*; Theorem 7.3 shows the exact answer. This is the one place in the theory where the soft spectral input is replaced by a complete arithmetic analysis, and it calibrates how lossy the soft bounds are.

---

## 8. Algorithms

The theory yields three effective procedures.

### 8.1 Gap certificate

**Input:** matrix $A$, spectral lower bound $m > 0$, shift $t$, target $c$.
**Output:** either a certificate that $Q(x - t) = c$ is unsolvable over $\mathbb{Z}^n$, or "inconclusive".

Compute $g = m \sum_i d_{\mathbb{Z}}(t_i)^2$. If $c < g$, report unsolvable (Theorem 3.6). Otherwise inconclusive. Cost: $O(n)$ arithmetic operations after $m$ is known; obtaining $m$ for symmetric $A$ costs one smallest-eigenvalue computation, $O(n^3)$ by standard dense methods, or $O(n^2)$ per iteration by inverse power iteration. When $t$ is rational with common denominator $q$, the same test may be run with the certified value $g = m/q^2$ (Theorem 3.10), avoiding all floating point in the arithmetic part.

### 8.2 Rounding solver and sandwich report

**Input:** $A$, spectral bounds $m, M$, shift $t$.
**Output:** an integer point $x_0$ with $Q(x_0-t) \le Mn/4$, plus the certified interval $[m\,d(t,\mathbb{Z}^n)^2,\; Mn/4]$ containing $\mu(Q,t)$.

Set $x_0 = \operatorname{round}(t)$ coordinatewise; evaluate $Q(x_0 - t)$ in $O(n^2)$ operations; report the sandwich of Theorem 4.2. The value $Q(x_0-t)$ itself is an *upper* bound on $\mu$ that is often much better than $Mn/4$, so the practical output interval is $[m\,d(t,\mathbb{Z}^n)^2,\; \min(Q(x_0-t),\, Mn/4)]$.

### 8.3 Exhaustive enumeration in the certified box

**Input:** $A$, $m > 0$, $t$, radius $R$.
**Output:** all $x \in \mathbb{Z}^n$ with $Q(x-t) \le R$.

By Lemma 5.1 every solution lies in the box $\prod_i [\lceil t_i - r\rceil, \lfloor t_i + r\rfloor]$ with $r = \sqrt{R/m}$; enumerate it and filter. The box has at most $(2r+1)^n$ points (Theorem 5.2), so the cost is $O\big(n^2 (2\sqrt{R/m}+1)^n\big)$ — exponential in $n$, as expected for a closest-vector-type problem, but with a fully certified search region and no risk of missing a solution. Depth-first enumeration with partial-sum pruning (abandon a prefix once the accumulated diagonal contribution exceeds $R$) typically visits far fewer nodes; for diagonal $A$ the pruning is exact and the enumeration is optimal up to the output size.

---

## 9. Applications

**Diophantine non-solvability certificates.** Theorem 3.6 and Corollary 3.11 give one-line proofs of unsolvability for shifted quadratic equations to which congruence methods do not apply. Example: $2x_1^2 + 3x_2^2 + 5x_3^2$ evaluated at $x - (\tfrac13,\tfrac13,\tfrac13)$ has spectral bounds $m = 2$, $M = 5$, and shift denominator $q = 3$, so the value is always $\ge 2/9$, and no integer solution exists for any target below $2/9$; the sharper real bound gives $\ge 2 \cdot 3 \cdot (1/3)^2 = 2/3$.

**Lattice cryptography and the closest vector problem.** With $Q$ the Gram form of a lattice basis, $\mu(Q,t)$ is the squared distance from $t$ to the lattice. Theorem 4.2 is a certified two-sided estimate: the covering side $Mn/4$ says decoding always succeeds within that radius, while the gap side $m\,d(t,\mathbb{Z}^n)^2$ is a lower bound on the achievable decoding distance, hence a *security floor* — no lattice point is closer, so a ciphertext perturbed by less than half that distance is uniquely decodable. The counting theorem quantifies how quickly the number of candidate decodings explodes as the search radius grows, which is exactly the complexity driver of enumeration-based attacks.

**Coding theory over $\mathbb{Z}$.** For an integer code with quadratic energy $Q$ and coset representative $t$, the gap is the minimum coset energy, i.e. a minimum-distance guarantee for coset codes; the extremal analysis of Section 7 exhibits the standard binary cube as the extremal coset of the sum-of-squares code.

**Statistical mechanics.** $\Theta(s)$ is the canonical partition function of a classical lattice system with energy $Q(x-t)$ at inverse temperature $s$. Theorem 6.3 states that the free energy per unit inverse temperature is bounded below by the gap; Theorem 6.2 bounds it above by the covering value. Theorem 7.3 identifies the ground state of the half-shifted oscillator as $2^n$-fold degenerate — a residual entropy of $n \log 2$, i.e. exactly one bit per degree of freedom.

**Integer quadratic programming.** Theorem 4.4 is a certified feasibility test for the constraint $Q(x - t) \le R$: reject below the gap, accept above the covering threshold with the rounded point as witness, and only in the intermediate band is branch-and-bound needed.

---

## 10. Discussion and open problems

### 10.1 What is sharp and what is not

The gap bound of Theorem 3.4 is sharp whenever the minimising integer point realises the coordinatewise nearest-integer rounding *and* the form attains its lower spectral bound on the resulting displacement; for $A = I$ this always happens, and the bound is an equality. The covering bound $Mn/4$ is, by contrast, generally lossy: it replaces every eigenvalue by the largest one. Problem C1 below proposes the correct replacement.

The counting theorem has the correct order $R^{n/2}$ but constants differing by $(Mn/m)^{n/2}$; closing that gap would require volume asymptotics rather than box comparisons.

### 10.2 Open problems

**C1. Sharp covering constant: the inhomogeneous minimum is controlled by the *trace*, not by $n\lambda_{\max}$.**

*Conjecture.* For every symmetric positive definite $A$ with spectral bounds $m, M$ and every shift $t$,
$$\mu(Q, t) \;\le\; \tfrac14 \operatorname{tr}(A),$$
with equality if and only if $A$ is diagonal and $t$ is a half-integral shift. In particular the proved bound $\mu \le Mn/4$ is never sharp unless all eigenvalues coincide.

The key insight is that the rounding point $x = \operatorname{round}(t)$ used in Theorem 4.1 wastes information: it bounds $Q(x-t)$ by $\lambda_{\max}\|x-t\|^2$, whereas expanding $Q(x-t) = \sum_{i,j} A_{ij}(x_i - t_i)(x_j - t_j)$ and averaging over a random $\pm\tfrac12$ displacement gives expectation exactly $\operatorname{tr}(A)/4$, the off-diagonal terms cancelling in mean. The averaging argument needs only the finite probability space $\{\pm\tfrac12\}^n$, so it is a self-contained next step that would upgrade every corollary depending on $Mn/4$.

**C2. Gap–theta duality: the decay rate of $\Theta$ *equals* the inhomogeneous minimum.**

*Conjecture.* For a spectrally sandwiched form with $m > 0$,
$$\lim_{s \to \infty} -\frac{1}{s}\log \Theta(s) \;=\; \mu(Q, t),$$
and moreover $\Theta(s)\,e^{s\mu(Q,t)} \to r(\mu)$, the number of integer points attaining the minimum (finite by Theorem 5.2).

Theorem 6.3 proves one inequality (the rate is at least $m\,d(t,\mathbb{Z}^n)^2$) purely from the termwise bound, while the matching upper bound must come from isolating the minimising terms and dominating the rest using the counting estimate $N(R) \le (2\sqrt{R/m}+1)^n$. In other words the counting theorem and the decay theorem are two halves of a single Laplace-method statement: the counting bound controls the tail, and the discreteness of the value set controls the leading term. For the half-shifted sum of squares the conjecture is verifiable directly from Theorem 6.5 and Theorem 7.3, with $r(\mu) = 2^n$.

### 10.3 Further directions

Beyond C1 and C2, several avenues suggest themselves. (i) *Anisotropic covering*: replace the isotropic box by an ellipsoidal enumeration region adapted to $A$, sharpening the counting constants to the true volume ratio. (ii) *Inhomogeneous minima of families*: study $\sup_t \mu(Q,t)$, the squared covering radius, under the spectral hypothesis alone; the sandwich gives $\sup_t \mu \le Mn/4$, and the half-shift shows $\sup_t \mu \ge mn/4$ when $A$ is diagonal, so the covering radius is pinned to within the condition number. (iii) *Modular refinements*: for rational shifts, combine the denominator gap $m/q^2$ with congruence conditions mod $q$ to obtain obstructions in the intermediate band. (iv) *Non-symmetric and indefinite forms*: the lower bound uses only $Q \ge m\|\cdot\|^2$, so indefinite forms admit a signed variant in which the "gap" becomes a bound on how negative $Q(x-t)$ can be — a question closely related to the Oppenheim circle of ideas.

---

## 11. Summary of results

| Result | Statement |
|---|---|
| Spectral Gap Theorem | $Q(x-t) \ge m\,d(t,\mathbb{Z}^n)^2$ for all $x \in \mathbb{Z}^n$ |
| Diophantine obstruction | $Q(x-t) = c$ unsolvable for $c < m\,d(t,\mathbb{Z}^n)^2$ |
| Effective rational gap | $Q(x - a/q) \ge m/q^2$ when $q \nmid a_{i_0}$ |
| Covering bound | $\exists x_0:\; Q(x_0-t) \le Mn/4$ |
| Spectral sandwich | $m\,d(t,\mathbb{Z}^n)^2 \le \mu(Q,t) \le Mn/4$ |
| Solvability window | solvable for $R \ge Mn/4$; unsolvable for $R < m\,d(t,\mathbb{Z}^n)^2$ |
| Counting | $(2\sqrt{R/(Mn)}-1)^n \le N(R) \le (2\sqrt{R/m}+1)^n$ for $R \ge Mn/4$ |
| Theta convergence | $\Theta(s)$ converges for all $s>0$ when $m>0$ |
| Theta bounds | $e^{-sMn/4} \le \Theta(s)$; $\Theta(s) \le e^{-(s-s_0)m\,d(t,\mathbb{Z}^n)^2}\Theta(s_0)$ |
| Diagonal factorisation | $\Theta(s) = \prod_i \sum_{k\in\mathbb{Z}} e^{-sd_i(k-t_i)^2}$ |
| Extremal set | $\sum_i (x_i-\tfrac12)^2 \le n/4 \iff x \in \{0,1\}^n$; exactly $2^n$ minimisers |
