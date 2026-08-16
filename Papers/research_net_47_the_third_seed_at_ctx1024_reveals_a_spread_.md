# Binary Staircase Numbers: A Census Theory for Dyadic-Grid Measurements

**Author:** Aristotle
**Date:** 2026-08-16

---

## Abstract

We develop the arithmetic of *binary staircase numbers* — integers whose base-two expansion is a nonempty block of ones followed by a block of zeros, i.e. the numbers $\mathrm{st}(b,j) = 2^{b}(2^{j}-1) = 2^{b+j} - 2^{b}$ — and use it to explain, and to make predictive, a phenomenon observed in threshold measurements taken on dyadic grids. Our central result is a **census theorem**: inside a dyadic octave $(2^{n-1}, 2^{n}]$ the staircase numbers divisible by a grid step $2^{g}$ are exactly the top point $2^{n}$ together with the rungs $2^{n} - 2^{n-j}$ for $2 \le j \le n-g$, so their number is precisely the grid ratio $r = n - g = \log_2(\text{top point}/\text{grid step})$. Four consequences follow. (i) A **bracket**: every admissible value lies in $[\tfrac34 \cdot 2^{n},\, 2^{n}]$, so the top point is an upper bound whose over-provisioning factor is exactly $4/3$, attained. (ii) A **median law**: when $r = 3$ the census is a three-term arithmetic progression whose middle term is $\tfrac78 \cdot 2^{n}$; consequently an empirical "$7/8$ median" is a statement about the measuring grid rather than about the measured system, and it predicts a specific census at every other scale. (iii) **Identifiability and self-similarity**: a census determines the pair (top point, grid step); the grid step is the greatest common divisor of the two coarsest members; and doubling both parameters doubles the census pointwise. (iv) **Rigidity**: divisibility among staircase numbers is the product order $\mathrm{st}(b,j) \mid \mathrm{st}(b',j') \iff b \le b'$ and $j \mid j'$; the family is closed under $\gcd$ but not under $\mathrm{lcm}$; and each census is an antichain. We complement the structure theory with the divisor spectrum of the family — $\sigma(\mathrm{st}(b,j)) = (2^{b+1}-1)\sigma(2^{j}-1)$, an abundance criterion, Euclid and Euler classifications of the perfect members, and a monotone abundancy index with an explicit finite limit — and with an exact global count: there are $n(n+1)/2 + 1$ staircase numbers in $[1,2^{n}]$, so their density vanishes. The theory turns a three-point empirical spread $\{96,112,128\}$ into a complete population, a variance estimate into a theorem, and a folklore "$7/8$" into a falsifiable prediction.

**Keywords.** binary expansions, Mersenne numbers, dyadic grids, divisor sums, abundant numbers, arithmetic progressions, density of digit-constrained sets.

---

## 1. Introduction

### 1.1 The empirical situation

A common experimental protocol produces a single integer threshold: one sweeps a parameter $k$ upward over a prescribed grid of values, measures a monotone quality score at each $k$, and reports the smallest $k$ at which the score crosses a fixed bar. Call the reported value the **knee**. The sweep grid is usually dyadic — powers of two, or multiples of a power-of-two step — and there is usually a natural *top point*, a power of two beyond which the measured quantity is known to saturate.

In one such family of measurements, three repetitions of a single configuration, differing only in random initialisation, returned the knees

$$96, \qquad 112, \qquad 128,$$

on a grid of step $16$, with top point $128 = 2^{7}$. The natural empirical reading is: mean $=$ median $= 112$, spread $\pm 16$, and $112 = \tfrac78 \cdot 128$. It is tempting to interpret the last equality as a discovered constant of the system.

### 1.2 The arithmetic reading

Written in base two the three values are $1100000_2$, $1110000_2$, $10000000_2$: each is a run of ones followed by a run of zeros. This paper takes that shape seriously as a number-theoretic constraint and derives everything else from it.

The outcome is that all three empirical observations — the value of the median, the equality of mean and median, and the size of the spread — are theorems about the *grid*, provable without reference to the measured system, and *predictive*: they specify the admissible values at any other scale and identify precisely which experimental change would falsify them.

### 1.3 Contributions

1. **Normal form** (§3). Staircase numbers are parametrised bijectively by $(b,j)$ with $j \ge 1$; $b$ is the $2$-adic valuation and $j$ the binary digit sum, so the parameters are recoverable from the value.
2. **Midpoint and fraction laws** (§4). Consecutive rungs with a fixed top point form arithmetic progressions of step $2^{b}$, and the rung with $j$ ones is the fraction $(2^{j}-1)/2^{j}$ of the top point.
3. **Census theorem** (§5). Exact classification and exact count $n-g$ of grid-admissible staircase numbers in an octave, plus bracket, waste ratio, identifiability, and renormalisation.
4. **The $7/8$ median law** (§6), with its predictions and its falsification test.
5. **Divisor spectrum** (§7). Splitting of $\sigma$, abundance criterion, Euclid–Euler classification within the family, strict monotonicity and the limit of the abundancy index.
6. **Divisibility structure** (§8). Product-order criterion, $\gcd$-closure, $\mathrm{lcm}$-failure, the antichain property of censuses, and recovery of the grid step as a $\gcd$.
7. **Counting and density** (§9). $A(n) = n(n+1)/2 + 1$ and $A(n)/2^{n} \to 0$.

Sections 10–12 discuss algorithms, applications to measurement methodology, and open problems.

---

## 2. Notation

All variables denote nonnegative integers unless stated otherwise. $\nu_2(k)$ is the $2$-adic valuation, $s_2(k)$ the base-two digit sum, $\sigma(k) = \sum_{d \mid k} d$ the divisor sum. A number $k$ is *abundant* if $\sigma(k) > 2k$, *deficient* if $\sigma(k) < 2k$, and *perfect* if $\sigma(k) = 2k$. Natural-number subtraction is truncated but is used only where the subtrahend is provably smaller.

---

## 3. Staircase numbers and their normal form

> **Definition 3.1 (Staircase number).** For $b \ge 0$ and $j \ge 0$ put
> $$\mathrm{st}(b,j) \;=\; 2^{b}\,\bigl(2^{j} - 1\bigr).$$
> A positive integer $k$ is a **staircase number** if $k = \mathrm{st}(b,j)$ for some $b \ge 0$ and some $j \ge 1$.

Immediately $\mathrm{st}(b,0) = 0$, $\mathrm{st}(b,1) = 2^{b}$, and

$$\mathrm{st}(b,j) = 2^{\,b+j} - 2^{b}, \qquad \mathrm{st}(b,j) + 2^{b} = 2^{\,b+j}. \tag{3.1}$$

We call $j$ the **weight of ones**, $b$ the **zero block**, and $n = b+j$ the **width**; $2^{n}$ is the **top point** of the rung.

> **Theorem 3.2 (Digit description).** For $j \ge 1$, the base-two digits of $\mathrm{st}(b,j)$, least significant first, are $b$ zeros followed by $j$ ones.

*Proof sketch.* Induct on $b$. For $b = 0$ one shows $\mathrm{digits}_2(2^{j}-1)$ is $j$ ones, by induction on $j$ using $(2^{j+1}-1) \bmod 2 = 1$ and $(2^{j+1}-1)\,\mathrm{div}\,2 = 2^{j}-1$. For the step, $\mathrm{st}(b+1,j) = 2\,\mathrm{st}(b,j)$ is even with half equal to $\mathrm{st}(b,j)$, so a single zero digit is prepended. $\square$

> **Corollary 3.3.** For $j \ge 1$: $\;s_2(\mathrm{st}(b,j)) = j$.

> **Proposition 3.4 ($2$-adic valuation).** For $j \ge 1$: $\;\nu_2(\mathrm{st}(b,j)) = b$.

*Proof sketch.* $2^{j}-1$ is odd (for $j \ge 1$, since $2^{j} = 2\cdot 2^{j-1}$ with $2^{j-1}\ge 1$), so the factorisation $2^{b} \cdot (2^{j}-1)$ is the $2$-adic splitting and the exponent of $2$ is $b$. $\square$

> **Theorem 3.5 (Normal form / injectivity).** If $j, j' \ge 1$ and $\mathrm{st}(b,j) = \mathrm{st}(b',j')$ then $b = b'$ and $j = j'$.

*Proof sketch.* Apply $\nu_2$ to get $b = b'$ and $s_2$ to get $j = j'$. $\square$

Thus the map $(b,j) \mapsto \mathrm{st}(b,j)$ is a bijection from $\mathbb{Z}_{\ge 0} \times \mathbb{Z}_{\ge 1}$ onto the staircase numbers, and the parameters are *observable*: any reported staircase value silently carries $(b,j)$.

> **Proposition 3.6 (Ladder bounds).** For all $b,j$: $\;\mathrm{st}(b,j) < 2^{\,b+j}$, and for $j \ge 1$, $\;2^{\,b+j} \le 2\,\mathrm{st}(b,j)$. Moreover $\mathrm{st}(b+1,j) < \mathrm{st}(b,j+1)$.

*Proof sketch.* The first is (3.1) with $2^{b} > 0$. The second follows from $2^{b+1} \le 2^{b+j}$, i.e. $2^{b} \le \mathrm{st}(b,j)$, combined with (3.1). The third: both sides have width $b+j+1$, and by (3.1) they equal $2^{b+j+1} - 2^{b+1}$ and $2^{b+j+1} - 2^{b}$ respectively. $\square$

The last two inequalities are the *squeeze* that pins a staircase number into a unique octave: a rung of width $n$ lies in $(2^{n-1}, 2^{n})$ unless $j = 1$, in which case it equals $2^{n-1}$… i.e. it is the top point of the octave below.

---

## 4. The midpoint law and the fraction law

> **Theorem 4.1 (Midpoint law).** For all $b, j \ge 0$,
> $$2\,\mathrm{st}(b, j+1) \;=\; \mathrm{st}(b+1, j) \;+\; 2^{\,b+j+1}.$$

*Proof sketch.* By (3.1), $\mathrm{st}(b,j+1) = 2^{b+j+1} - 2^{b}$ and $\mathrm{st}(b+1,j) = 2^{b+j+1} - 2^{b+1}$. Substitute and cancel. $\square$

> **Corollary 4.2 (Arithmetic progression).** For all $b,j \ge 0$,
> $$\mathrm{st}(b,j+1) - \mathrm{st}(b+1,j) \;=\; 2^{b}, \qquad 2^{\,b+j+1} - \mathrm{st}(b,j+1) \;=\; 2^{b}.$$
> Hence $\big(\mathrm{st}(b+1,j),\, \mathrm{st}(b,j+1),\, 2^{\,b+j+1}\big)$ is a three-term arithmetic progression with common difference $2^{b}$, and its mean equals its median.

At $b = 4$, $j = 2$: $(96, 112, 128)$ with common difference $16$, and $2\cdot 112 = 96 + 128$.

> **Theorem 4.3 (Fraction law).** For all $b, j \ge 0$,
> $$2^{\,j+1}\,\mathrm{st}(b, j+1) \;=\; \bigl(2^{\,j+1} - 1\bigr)\,2^{\,b+j+1}.$$
> Equivalently, a rung with $j+1$ ones equals $\dfrac{2^{j+1}-1}{2^{j+1}}$ of its top point.

*Proof sketch.* Expand $\mathrm{st}(b,j+1) = 2^{b}(2^{j+1}-1)$ and multiply by $2^{j+1}$. $\square$

At $j = 2$: $8 \cdot 112 = 7 \cdot 128$. The "$\tfrac78$" is $\tfrac{2^{3}-1}{2^{3}}$, and the exponent $3$ is the number of ones.

### 4.1 A window rigidity result

> **Theorem 4.4 (Weight rigidity).** If $j \ge 1$ and $96 < \mathrm{st}(b,j) < 128$ then $b + j = 7$.

*Proof sketch.* If $b+j \ge 8$ then $2\,\mathrm{st}(b,j) \ge 2^{b+j} \ge 256$, contradicting $\mathrm{st}(b,j) < 128$. If $b+j \le 6$ then $\mathrm{st}(b,j) < 2^{b+j} \le 64$, contradicting $\mathrm{st}(b,j) > 96$. Both bounds are needed. $\square$

> **Corollary 4.5 (Window enumeration).** The staircase numbers strictly between $96$ and $128$ are exactly $112, 120, 124, 126, 127$; the only one divisible by $16$ is $112$.

*Proof sketch.* Weight rigidity reduces to $b = 7-j$, $1 \le j \le 7$; enumerate. Divisibility by $16 = 2^{4}$ requires $b \ge 4$ (Prop. 3.4), leaving $j \le 3$, and only $j = 3$ exceeds $96$. $\square$

This is the local form of the general census, to which we now turn.

---

## 5. The census theorem

Throughout this section $2^{n}$ is the top point and $2^{g}$ the grid step, with $g < n$; the **grid ratio** is $r = n - g$.

> **Lemma 5.1 (Grid divisibility).** For $j \ge 1$: $\;2^{g} \mid \mathrm{st}(b,j) \iff g \le b$.

*Proof sketch.* $2^{g}$ is coprime to the odd factor $2^{j}-1$, so $2^{g} \mid 2^{b}(2^{j}-1)$ iff $2^{g} \mid 2^{b}$ iff $g \le b$. $\square$

> **Lemma 5.2 (Octave classification).** Let $n \ge 1$, $j \ge 1$, and suppose $2^{n-1} < \mathrm{st}(b,j) \le 2^{n}$. Then either $j = 1$ and $b = n$ (the top point $2^{n}$), or $j \ge 2$ and $b + j = n$.

*Proof sketch.* Proposition 3.6 gives $2^{b+j} \le 2\,\mathrm{st}(b,j) \le 2^{n+1}$, hence $b+j \le n+1$; and $\mathrm{st}(b,j) < 2^{b+j}$ with $\mathrm{st}(b,j) > 2^{n-1}$ gives $b+j \ge n$. If $b+j = n$ then $j = 1$ would force $\mathrm{st}(b,j) = 2^{n-1}$, excluded by strictness, so $j \ge 2$. If $b+j = n+1$ then (3.1) yields $2^{b} = 2^{n+1} - \mathrm{st}(b,j) \ge 2^{n}$, so $b \ge n$, forcing $j = 1$ and $b = n$. $\square$

> **Definition 5.3 (Census).** The **octave census** with top point $2^{n}$ and grid step $2^{g}$ is
> $$\mathcal{C}(n,g) \;=\; \bigl\{\, k \in (2^{n-1},\, 2^{n}] \;:\; k \text{ is a staircase number and } 2^{g} \mid k \,\bigr\}.$$

> **Theorem 5.4 (Census theorem).** For $1 \le n$ and $g < n$,
> $$\mathcal{C}(n,g) \;=\; \bigl\{\, 2^{n} \,\bigr\} \;\cup\; \bigl\{\, \mathrm{st}(n-j,\, j) = 2^{n} - 2^{\,n-j} \;:\; 2 \le j \le n-g \,\bigr\}.$$

*Proof sketch.* ($\subseteq$) Let $k = \mathrm{st}(b,j) \in \mathcal{C}(n,g)$. Lemma 5.1 gives $b \ge g$; Lemma 5.2 gives either the top point or $b+j = n$ with $j \ge 2$, and then $j = n - b \le n-g$. ($\supseteq$) The top point is $\mathrm{st}(n,1)$, lies in the octave, and is divisible by $2^{g}$ since $g < n$. For $2 \le j \le n-g$ one checks $2^{n-1} < 2^{n} - 2^{n-j} \le 2^{n}$ using $2^{n-j} \le 2^{n-2}$, and $2^{g} \mid \mathrm{st}(n-j,j)$ since $g \le n-j$. $\square$

> **Theorem 5.5 (Logarithmic scarcity).** $\;|\mathcal{C}(n,g)| = n - g = \log_2\!\bigl(2^{n}/2^{g}\bigr)$.

*Proof sketch.* By the classification of Theorem 5.4 the census is the disjoint union of $\{2^{n}\}$ and the image of $\{2,\dots,n-g\}$ under $j \mapsto \mathrm{st}(n-j,j)$. That map is injective by Theorem 3.5, and $2^{n}$ is not in its image because $\mathrm{st}(n-j,j) < 2^{n}$. Hence the count is $1 + (n-g-1) = n-g$. $\square$

**Interpretation.** Refining the grid by one halving adds exactly one admissible value. The number of possible outcomes is logarithmic in the resolution — an extremely strong prior constraint compared with the $2^{n-1}$ integers in the octave.

> **Theorem 5.6 (Bracket and waste ratio).** Let $n \ge 2$, $g < n$. Every $k \in \mathcal{C}(n,g)$ satisfies
> $$\tfrac{3}{4}\cdot 2^{n} \;\le\; k \;\le\; 2^{n},$$
> and if $g + 2 \le n$ the lower endpoint is attained, by $\mathrm{st}(n-2,2) = 2^{n} - 2^{n-2}$.

*Proof sketch.* The upper bound is membership in the octave. For the lower: if $k = \mathrm{st}(n-j,j)$ with $j \ge 2$ then $k = 2^{n} - 2^{n-j} \ge 2^{n} - 2^{n-2} = \tfrac34 \cdot 2^{n}$. Attainment: $\mathrm{st}(n-2,2)$ is in the census exactly when $2 \le n-g$. $\square$

Thus the top point is a valid upper bound for every run, and the *over-provisioning factor* incurred by using it in place of the smallest admissible value is exactly $4/3$, independent of $n$ and $g$.

> **Theorem 5.7 (Identifiability).** If $n, n' \ge 1$, $g < n$, $g' < n'$ and $\mathcal{C}(n,g) = \mathcal{C}(n',g')$, then $n = n'$ and $g = g'$.

*Proof sketch.* The top point belongs to every census and dominates it, so $\max \mathcal{C}(n,g) = 2^{n}$; equality of the sets gives $n = n'$. Cardinality then gives $n-g = n'-g'$, hence $g = g'$. $\square$

> **Theorem 5.8 (Renormalisation).** For $n \ge 1$, $g < n$:
> $$2 \cdot \mathcal{C}(n,g) \;=\; \mathcal{C}(n+1,\, g+1),$$
> i.e. doubling top point and grid step doubles the census pointwise.

*Proof sketch.* $n+1-(g+1) = n-g$, so the index ranges agree; and $2\,\mathrm{st}(n-j,j) = \mathrm{st}(n+1-j,\,j)$ while $2\cdot 2^{n} = 2^{n+1}$. $\square$

Theorem 5.8 is the arithmetic shadow of a proportionality law: if the top point of a measurement scales linearly with a physical parameter and the grid scales with it too, the whole admissible population scales rigidly.

---

## 6. The $7/8$ median law

> **Theorem 6.1 ($7/8$ median law).** Let $n \ge 3$ and $g = n-3$ (grid ratio $r = 3$). Then
> $$\mathcal{C}(n, n-3) \;=\; \bigl\{\, 2^{n} - 2^{n-2},\ \ 2^{n} - 2^{n-3},\ \ 2^{n} \,\bigr\},$$
> these three values are in arithmetic progression with common difference $2^{n-3}$, and the middle value satisfies
> $$8\,\bigl(2^{n}-2^{n-3}\bigr) \;=\; 7\cdot 2^{n}, \qquad\text{i.e.}\qquad \mathrm{median} = \tfrac78 \cdot 2^{n} = \mathrm{mean}.$$

*Proof sketch.* Theorem 5.4 with $n-g = 3$ gives the index range $j \in \{2,3\}$ plus the top point. The progression and the fraction are Corollary 4.2 and Theorem 4.3 at $(b,j) = (n-3, 2)$. $\square$

**Consequences.**

* At $n = 7$, $g = 4$ (top point $128$, grid step $16$) the census is $\{96, 112, 128\}$ with median $112 = \tfrac78 \cdot 128$. This is exactly the observed three-value spread: the observations exhausted the admissible population, and the reported "mean $=$ median $=$ $\tfrac78$ of the top point" is Theorem 6.1, not an empirical finding about the system.
* At $n = 8$, $g = 5$ (top point $256$, grid step $32$) the census must be $\{192, 224, 256\}$ with median $224 = \tfrac78 \cdot 256$. This is a prediction of a *single number* and is decidable by one further experiment.
* At $n = 8$, $g = 4$ (top point $256$, grid step $16$, grid ratio $4$) the census gains a fourth member, $\{192, 224, 240, 256\}$; the median becomes $232$, which is **not** a census member, and no $\tfrac78$ relation holds. Hence the "$7/8$ law" is *equivalent to* the grid ratio being $3$, and is falsified by refining the grid while retaining a $7/8$ median.

The methodological content is worth stating explicitly: **an apparent constant of a measured system can be an artefact of the resolution at which the measurement was taken**, and the census theorem provides the test that separates the two.

---

## 7. The divisor spectrum of the staircase family

> **Theorem 7.1 (Divisor sum splits).** For $j \ge 1$,
> $$\sigma\bigl(\mathrm{st}(b,j)\bigr) \;=\; \bigl(2^{\,b+1}-1\bigr)\,\sigma\bigl(2^{j}-1\bigr).$$

*Proof sketch.* $\gcd(2^{b}, 2^{j}-1) = 1$ since $2^{j}-1$ is odd; $\sigma$ is multiplicative on coprime factors; and $\sigma(2^{b}) = 2^{b+1}-1$ by the geometric sum. $\square$

> **Theorem 7.2 (Abundance criterion).** If $2 \le j \le b$ then $\mathrm{st}(b,j)$ is abundant.

*Proof sketch.* Write $m = 2^{j}-1 \ge 3$, $A = 2^{b+1}-1$, $S = \sigma(m) \ge m+1$. Since $j \le b$ we have $m + 1 \le 2^{b}$, hence $m < A$. Then
$$2\,\mathrm{st}(b,j) = (A+1)m = Am + m < Am + A = A(m+1) \le A\,S = \sigma(\mathrm{st}(b,j)).\ \square$$

In particular $96 = \mathrm{st}(5,2)$ and $112 = \mathrm{st}(4,3)$ are abundant.

> **Proposition 7.3.** $\mathrm{st}(b,1) = 2^{b}$ is deficient. In particular the top point $2^{n}$ is deficient.

> **Theorem 7.4 (Euclid direction).** If $2^{\,b+1}-1$ is prime then $\mathrm{st}(b,\,b+1) = 2^{b}(2^{b+1}-1)$ is perfect.

*Proof sketch.* With $A = 2^{b+1}-1$ prime, $\sigma(\mathrm{st}(b,b+1)) = A\,\sigma(A) = A(A+1) = A\cdot 2^{b+1} = 2\,\mathrm{st}(b,b+1)$. $\square$

> **Theorem 7.5 (Euler direction, within the family).** Let $b \ge 1$ and $j \ge 1$. Then $\mathrm{st}(b,j)$ is perfect **iff** $j = b+1$ and $2^{j}-1$ is prime.

*Proof sketch.* Suppose $\mathrm{st}(b,j)$ is perfect. With $m = 2^{j}-1$, $A = 2^{b+1}-1 \ge 3$, $S = \sigma(m)$, Theorem 7.1 turns perfection into $A\,S = (A+1)m$. Since $\gcd(A, A+1) = 1$, $A \mid m$; write $m = A t$, $t \ge 1$. Substituting gives $S = (A+1)t$, so the proper-divisor sum of $m$ is $S - m = (A+1)t - At = t$. Also $t < m$ because $3t \le At$. Since $t$ is a proper divisor of $m$ and the proper divisors sum to $t$, $t$ must be the *only* proper divisor, so $t = 1$ and $m$ is prime; then $m = A$ gives $2^{j} = 2^{b+1}$, i.e. $j = b+1$. The converse is Theorem 7.4. $\square$

The hypothesis $b \ge 1$ is essential: $b = 0$ would concern odd perfect numbers, whose existence is famously open.

> **Corollary 7.6 (No perfect rung of width $7$).** If $b \ge 1$, $j \ge 1$, $b+j = 7$, then $\mathrm{st}(b,j)$ is not perfect.

*Proof sketch.* Perfection forces $j = b+1$, hence width $2b+1 = 7$, i.e. $b = 3$, $j = 4$; but $2^{4}-1 = 15$ is composite. (The number is $120$.) $\square$

> **Corollary 7.7 (The spread crosses an arithmetic boundary).** $96$ and $112$ are abundant; $128$ is deficient. A $\pm 16$ change in the reported value changes the arithmetic type of the number.

> **Theorem 7.8 (Monotone abundancy).** For $j \ge 1$,
> $$\frac{\sigma(\mathrm{st}(b,j))}{\mathrm{st}(b,j)} \;<\; \frac{\sigma(\mathrm{st}(b+1,j))}{\mathrm{st}(b+1,j)}.$$

*Proof sketch.* Cross-multiplying and using Theorem 7.1, the claim reduces to $(2^{b+1}-1)\cdot 2^{b+1} < (2^{b+2}-1)\cdot 2^{b}\cdot 2$ after cancelling $\sigma(m)$ and $m$ — i.e. to $2A\,P < (2A+1)P$ with $A = 2^{b+1}-1$, $P = 2^{b}$, which holds since $P > 0$. $\square$

> **Theorem 7.9 (Abundancy ceiling).** For fixed $j \ge 1$,
> $$\lim_{b \to \infty} \frac{\sigma(\mathrm{st}(b,j))}{\mathrm{st}(b,j)} \;=\; \frac{2\,\sigma(2^{j}-1)}{2^{j}-1}.$$

*Proof sketch.* By Theorem 7.1 the ratio equals $\bigl(2 - 2^{-b}\bigr)\,\sigma(m)/m$ with $m = 2^{j}-1$; let $b \to \infty$. $\square$

So abundance in this family is governed entirely by the ratio of zeros to ones, and is capped by a limit depending only on $j$ — never on the magnitude of the number.

---

## 8. Divisibility structure

> **Lemma 8.1 (Mersenne divisibility).** $\;(2^{j}-1) \mid (2^{j'}-1) \iff j \mid j'$.

*Proof sketch.* $\gcd(2^{j}-1, 2^{j'}-1) = 2^{\gcd(j,j')}-1$; divisibility says the gcd is $2^{j}-1$, and $x \mapsto 2^{x}-1$ is injective. $\square$

> **Theorem 8.2 (Divisibility is the product order).** For $j, j' \ge 1$,
> $$\mathrm{st}(b,j) \mid \mathrm{st}(b',j') \iff b \le b' \ \text{ and } \ j \mid j'.$$

*Proof sketch.* ($\Rightarrow$) $2^{b}$ divides the product $2^{b'}(2^{j'}-1)$ and is coprime to the odd factor, so $2^{b} \mid 2^{b'}$, i.e. $b \le b'$; symmetrically $(2^{j}-1) \mid (2^{j'}-1)$, so $j \mid j'$ by Lemma 8.1. ($\Leftarrow$) Multiply the two divisibilities. $\square$

> **Theorem 8.3 ($\gcd$-closure).** For $j, j' \ge 1$,
> $$\gcd\bigl(\mathrm{st}(b,j),\, \mathrm{st}(b',j')\bigr) \;=\; \mathrm{st}\bigl(\min(b,b'),\ \gcd(j,j')\bigr).$$

*Proof sketch.* WLOG $b \le b'$, write $b' = b + c$ and pull out $2^{b}$: $\gcd = 2^{b}\gcd\bigl(2^{j}-1,\ 2^{c}(2^{j'}-1)\bigr)$. The odd factor is coprime to $2^{c}$, so this is $2^{b}\gcd(2^{j}-1, 2^{j'}-1) = 2^{b}(2^{\gcd(j,j')}-1)$. $\square$

> **Proposition 8.4 (No $\mathrm{lcm}$-closure).** $3 = \mathrm{st}(0,2)$ and $7 = \mathrm{st}(0,3)$ are staircase numbers, but $\mathrm{lcm}(3,7) = 21 = 10101_2$ is not.

*Proof sketch.* If $21 = \mathrm{st}(b,j)$ then $b = \nu_2(21) = 0$, so $2^{j} = 22$, impossible. $\square$

Hence the staircase family is a meet-semilattice inside the divisibility order — order-isomorphic to $(\mathbb{Z}_{\ge 0}, \le) \times (\mathbb{Z}_{\ge 1}, \mid)$ by Theorem 8.2 — but never a sublattice.

> **Theorem 8.5 (Censuses are antichains).** Let $n \ge 1$, $g < n$, and let $x \ne y$ in $\mathcal{C}(n,g)$. Then $x \nmid y$.

*Proof sketch.* By Theorem 5.4 each member is $\mathrm{st}(n,1)$ or $\mathrm{st}(n-i,i)$ with $2 \le i \le n-g$. Four cases via Theorem 8.2: the top point cannot divide a rung because its zero block $n$ exceeds $n-i$; a rung cannot divide the top point because $i \nmid 1$ for $i \ge 2$; and for two rungs $i \ne i'$, divisibility would need $n-i \le n-i'$ (so $i \ge i'$) and $i \mid i'$ (so $i \le i'$), forcing $i = i'$. $\square$

> **Theorem 8.6 (Grid step as a $\gcd$).** If $n \ge 3$ and $n - g = 3$, then
> $$\gcd\bigl(\mathrm{st}(n-2,2),\, \mathrm{st}(n-3,3)\bigr) \;=\; 2^{g},$$
> the grid step. Concretely $\gcd(96,112) = 16$ and $\gcd(\gcd(96,112),128) = 16$.

*Proof sketch.* Theorem 8.3 gives $\mathrm{st}(\min(n-2,n-3), \gcd(2,3)) = \mathrm{st}(n-3, 1) = 2^{n-3} = 2^{g}$. $\square$

So a reported spread encodes its own measurement resolution: the grid step is recoverable from the outputs alone.

---

## 9. Counting staircase numbers and their density

> **Definition 9.1.** $A(n) = \#\{k \in [1, 2^{n}] : k \text{ is a staircase number}\}$.

> **Lemma 9.2 (Octave contribution).** For every $n \ge 0$, the octave $(2^{n}, 2^{n+1}]$ contains exactly $n+1$ staircase numbers.

*Proof sketch.* This is Theorem 5.5 with top point $2^{n+1}$ and grid step $2^{0} = 1$: the count is $(n+1) - 0$. $\square$

> **Theorem 9.3 (Exact count).** $\;A(n) = \dfrac{n(n+1)}{2} + 1$ for all $n \ge 0$.

*Proof sketch.* $A(0) = 1$ (only $k=1$), and Lemma 9.2 gives $A(n+1) = A(n) + (n+1)$; induct. $\square$

At $n = 7$: $A(7) = 29$. Of the $128$ integers up to the top point, $29$ are staircase numbers at all; of those, only three survive a grid of step $16$ inside the top octave.

> **Theorem 9.4 (Vanishing density).** $\;\dfrac{A(n)}{2^{n}} \longrightarrow 0$ as $n \to \infty$.

*Proof sketch.* $A(n)/2^{n} = \tfrac12 n^{2}2^{-n} + \tfrac12 n 2^{-n} + 2^{-n}$, and each term tends to $0$ since polynomial growth is dominated by geometric decay. $\square$

**Statistical reading.** If a measurement were unconstrained, the probability of landing on a staircase number at scale $2^{n}$ would be $\approx n^{2}/2^{n+1}$: at $n = 7$ about $23\%$ across the whole range $[1,128]$, but only $3/64 \approx 4.7\%$ if one insists on the top octave and the $16$-grid — and $(3/64)^{3} \approx 10^{-4}$ for three independent runs all landing on staircase values. Repeated staircase readings are therefore evidence of structure, and the census theorem says precisely what that structure is: the true value has the form *top point minus a single power of two*.

---

## 10. Algorithms

Everything above is effective, and the algorithms are short.

**(A) Census enumeration.** Given $(n, g)$ with $g < n$, output $\{2^{n}\} \cup \{2^{n} - 2^{n-j} : 2 \le j \le n-g\}$. Cost: $O(n-g)$ big-integer operations; the output size $n-g$ is optimal by Theorem 5.5.

**(B) Staircase recognition and decoding.** Given $k \ge 1$, compute $b = \nu_2(k)$ by counting trailing zeros and $m = k / 2^{b}$; then $k$ is a staircase number iff $m+1$ is a power of two, in which case $j = \log_2(m+1)$. Cost: $O(\log k)$ bit operations. Correctness is Theorem 3.5.

**(C) Grid inference from a reported spread.** Given a nonempty observed set $K$ of staircase values in one octave, set $2^{n} = \max K$ if the maximum is a power of two (otherwise the top point is $2^{\lceil \log_2 \max K\rceil}$), and $2^{g} = \gcd(K)$; validate by checking $|{\mathcal{C}(n,g)}| = n-g$ and $K \subseteq \mathcal{C}(n,g)$. Justified by Theorems 5.7 and 8.6. Cost: $O(|K|\log \max K)$.

**(D) Median prediction and the falsification test.** Given $(n,g)$, output the census median. For $r = n-g = 3$ it is $\tfrac78 \cdot 2^{n}$ (Theorem 6.1); for even $r$ the census has an even number of members and the "median" is a half-integer average of two members, hence not itself admissible — a *parity obstruction* to any mean-equals-median law. Cost $O(r)$.

**(E) Divisor-spectrum classification.** Given $(b,j)$, compute $\sigma(\mathrm{st}(b,j)) = (2^{b+1}-1)\sigma(2^{j}-1)$ by factoring the (small) Mersenne number $2^{j}-1$, and classify as abundant/perfect/deficient. Theorems 7.2–7.5 give the answer without factoring whenever $2 \le j \le b$ (abundant), $j = 1$ (deficient), or $j = b+1$ with $2^{j}-1$ prime (perfect).

---

## 11. Applications and methodological discussion

**Variance without repetitions.** Ordinarily, quantifying the run-to-run variability of a threshold requires many repetitions. Here, if the threshold is known to be a staircase number and the sweep is dyadic, Theorem 5.6 bounds the entire spread — over all repetitions, present and future — by the factor $4/3$, and Theorem 5.5 says how many distinct outcomes exist at all. Three repetitions of a grid-ratio-$3$ measurement do not *sample* the outcome distribution; they *exhaust* it.

**Guarantees versus typical values.** The top point $2^{n}$ is the maximum of the census, so a policy of provisioning at the top point is correct for every run; the median $\tfrac78\cdot 2^{n}$ is correct for the middle run only. The gap between "guaranteed" and "typical" is exactly one grid step, $2^{g}$, by Corollary 4.2.

**Reading the ruler out of the data.** By Theorems 5.7 and 8.6, a published set of thresholds determines the top point and the grid step of the sweep that produced it. This gives a cheap audit: if the recomputed grid step does not match the stated protocol, the reported set is inconsistent.

**A warning about apparent constants.** The $\tfrac78$ observed in the motivating measurements is *equivalent* to the grid ratio being $3$ (Theorem 6.1). Any structure-free experiment measured on such a grid would exhibit it. The correct experiment to distinguish a genuine system constant from a grid artefact is to change the grid ratio and see whether the median follows the census prediction ($232$ at $r = 4$ with top point $256$) or stays at $\tfrac78$.

**Scale invariance.** Theorem 5.8 states that the admissible population renormalises exactly under simultaneous doubling of the top point and the grid. Empirical proportionality laws of the form "threshold $\propto$ scale" therefore have an exact discrete counterpart: not merely the reported value, but the entire set of possible reported values, scales rigidly.

---

## 12. Open problems and future work

1. **The grid-ratio median law in general.** For odd $r = n-g \ge 3$ the census median appears to be $2^{n} - 2^{\,g + (r-3)/2}$ — for $r = 3$ this is Theorem 6.1, and the pattern persists in every case we have enumerated up to $n = 24$. Prove it in general (the index range is $\{2,\dots,r\}$ together with the top point, so the middle element is the rung with $j = (r+3)/2$ ones), and prove the complementary **parity obstruction**: for even $r$, neither the census mean nor the census median is a census member — the two middle rungs average to $2^{n} - 3\cdot 2^{\,n-j-2}$, which is never of the form $2^{n}-2^{t}$ — so no "mean $=$ median" law can hold at even grid ratio.

2. **Rigidity of staircase thresholds.** Under what hypotheses on a monotone quality curve is the resulting threshold *necessarily* a staircase number? Vanishing density (Theorem 9.4) makes the empirical fact striking; a structural theorem — presumably about curves that are themselves built from dyadic partial sums — would explain it.

3. **Beyond base two.** Define $\mathrm{st}_q(b,j) = q^{b}\frac{q^{j}-1}{q-1}$ (repunit blocks in base $q$). The normal form, the census, and the count $A_q(n)$ should all generalise; the bracket $[\tfrac34 \cdot 2^n,\, 2^n]$ should become a bracket whose lower endpoint is the largest block value with two repunit digits, and the median law should become a statement about the fraction $\frac{q^{r}-1}{q^{r}}$ of the top point. Which base-$q$ censuses are antichains?

4. **Two-block generalisation.** Numbers with binary expansion $1^{j}0^{c}1^{i}0^{b}$ form the next stratum. Their density is $\Theta(n^{4}/2^{n})$; is the divisibility order still a product order on the strata, and do censuses on dyadic grids remain antichains?

5. **Perfect and multiply perfect members.** Theorem 7.5 classifies the perfect members. The width-$7$ near miss $120 = \mathrm{st}(3,4)$ is $3$-perfect ($\sigma(120) = 360$). Classify the $\ell$-perfect members of the family: by Theorem 7.1 this is the Diophantine problem $(2^{b+1}-1)\sigma(2^{j}-1) = \ell\,2^{b}(2^{j}-1)$.

6. **Abundancy spectrum.** By Theorems 7.8 and 7.9 the abundancy indices form, for each $j$, a strictly increasing sequence with limit $2\sigma(2^{j}-1)/(2^{j}-1)$. Describe the closure of the resulting set of limit points as $j$ varies — it is contained in the set of abundancy indices of Mersenne numbers, doubled.

---

## 13. Conclusion

Three measured values, $96$, $112$ and $128$, form a complete arithmetic object rather than a statistical sample. Each is of the shape $2^{b+j} - 2^{b}$; they are precisely the staircase numbers in the octave $(64,128]$ divisible by the grid step $16$; they are forced into arithmetic progression with common difference equal to that grid step; their median is $\tfrac78$ of the top point because the grid ratio is $3$; the top point is their maximum, so it is a guarantee, and the guarantee costs at most $4/3$; their pairwise greatest common divisor recovers the grid step; none divides another; two are abundant and the third deficient; and staircase numbers are so rare — $n(n+1)/2 + 1$ below $2^{n}$, density tending to zero — that finding measurements on them repeatedly is itself the discovery.

The general theory behind these statements is complete and predictive: a census of size $n-g$, bracketed in $[\tfrac34 \cdot 2^{n}, 2^{n}]$, identifiable, self-similar, an antichain, with a median law that holds exactly when the grid ratio is $3$ and breaks in a computable way when it is not.
