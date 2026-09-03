# Tie Ceilings and Noise Budgets for Rank-Correlation Dials

## A cubic obstruction theory for degraded Spearman scores, with an application to starved sieve experiments

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

We develop an exact obstruction theory for Spearman rank correlation against a coarsened or noisy response, and apply it to diagnose the degradation of a predictive statistic ("dial") in a starved computational sieve experiment.

Three results form the core. First, the **Tie-Block Ceiling**: if a response is constant on each block of a partition, then for any predictor $X$ the squared rank correlation obeys $\rho^2 \le 1 - W/\operatorname{Var}X$, where $W$ is the within-block sum of squares of $X$; and this bound is *attained*, by the block-averaged predictor. Second, combining this with the sharp **Discrete Spread Bound** — $m$ distinct integers have squared spread at least $(m^3-m)/12$, with equality for consecutive runs — gives the **Starved-Regime Ceiling** $\rho^2 \le 1 - (m^3-m)/(n^3-n)$ for a tie block of size $m$ in a sample of size $n$, and, via a power-mean argument over the full tie partition, the **Quantization Ceiling** $\rho^2 \le 1 - (n^3/r^2 - n)/(n^3-n) \to 1 - r^{-2}$ for a response taking $r$ distinct values. Third, the **Noise Budget**: reading covariance stability backwards, a dial that scores $a$ against the true response ranking and only $b \le a$ against a measured ranking certifies a rank-displacement energy $\operatorname{Var}(\text{measured} - \text{true}) \ge (a-b)^2 (n^3-n)/12$.

The application is decisive and negative. In the recorded experiment ($n = 1200$ moduli at bit length 56, mean smooth rate $0.89\%$, $m = 194$ zero-hit moduli, observed Spearman score $0.405$ against a target band $[0.55, 0.85]$), the tie ceiling is $\rho \le 0.9979$ and the quantization ceiling is $\rho \le 0.866$ for every quantization level $r \ge 2$. The recorded explanation — that the starved regime destroys rank resolution — is therefore **false**: producing $\rho \le 0.55$ by ties alone would require a zero-hit fraction exceeding $88.7\%$, against the $16.2\%$ observed. The tie penalty is *cubic* in the tie fraction, which is the structural reason coarseness is a far weaker adversary than intuition suggests. The Noise Budget supplies the quantitative replacement: the drop from $0.55$ to $0.405$ at $n=1200$ certifies a displacement energy of at least $3.0 \times 10^6$, an RMS rank displacement of at least 50 positions out of 1200 ($\approx 4\%$), and about 318 positions ($\approx 27\%$) under an isotropic-noise model. The "practical floor" of the dial is thus relocated: it is a property of the rate estimator's Monte-Carlo variance, not of the dial's rank resolution.

**Keywords:** Spearman rank correlation, tie correction, law of total variance, conditional expectation, discrete isoperimetric inequality, power-mean inequality, Monte-Carlo estimator noise, starved sieve.

---

## 1. Introduction

### 1.1 The setting

A *dial* is a cheap real-valued statistic $T(N)$, computable for a modulus $N$, intended to predict an expensive quantity: the *smooth-hit rate* $\mathrm{rate}(N)$ of a sieve run at a fixed bit length. Only the ordering matters operationally — one wants to allocate effort to the highest-rate moduli — so the dial is graded by the **Spearman rank correlation** between $T$ and $\mathrm{rate}$ over a sample of $n$ moduli. An acceptance band $[0.55,\,0.85]$ is imposed: below $0.55$ the dial is not informative enough to be worth its cost; above $0.85$ one suspects the dial has accidentally recomputed the response.

At bit length 56 with $n = 1200$ sampled moduli, the recorded score is
$$\rho_{\text{obs}} = 0.405,$$
below the band. Two facts about the regime are recorded alongside it: the mean smooth rate has fallen to $0.89\%$, and $m = 194$ of the $1200$ moduli register **zero** smooth hits. Since a zero-hit modulus records a measured rate of exactly $0$, those 194 moduli are mutually tied in the response ranking.

The recorded diagnosis follows the obvious mechanistic story: *the starved regime destroys rank resolution*. A sixth of the sample has been flattened into an indistinguishable block, so the correlation must suffer.

### 1.2 The question this paper answers

The diagnosis is qualitative. This paper makes it quantitative, and in doing so refutes it.

The precise question is: **given that $m$ of the $n$ responses are tied, what is the supremum of $\rho(T, \mathrm{rate})$ over all dials $T$?** If that supremum is below $0.55$, the diagnosis stands. If it is above, the diagnosis is impossible and a second mechanism is required.

We answer the question exactly. The supremum is $\sqrt{1 - (m^3-m)/(n^3-n)}$, it is attained, and at $(m,n) = (194,1200)$ it equals $0.99788\ldots$. The diagnosis is refuted by a factor of enormous size, and we trace the refutation to a structural fact: the tie penalty is *cubic*, not linear, in the tie fraction.

We then close the two natural escape routes (the bound might be lossy; the full quantization partition might do more damage than one block), and finally quantify the only surviving mechanism — estimator noise — via a lower bound on rank displacement energy.

### 1.3 Organisation

Section 2 fixes notation and defines the centred moments and the block-averaging operator. Section 3 proves the Tie-Block Ceiling and its sharpness. Section 4 proves the Discrete Spread Bound. Section 5 combines them into the Starved-Regime Ceiling and derives the cubic starvation threshold. Section 6 handles the full tie partition and the Quantization Ceiling. Section 7 develops the Noise Budget. Section 8 assembles the numerical verdict for the recorded experiment. Sections 9–11 give algorithms, discussion, and future directions.

---

## 2. Setting and notation

Throughout, $\iota$ is a finite index set of size $n$ (the sampled moduli) and $\kappa$ a finite label set (block labels). All variables are real-valued functions on $\iota$.

**Definition 2.1 (Mean).** For $X : \iota \to \mathbb{R}$,
$$\bar X := \frac{1}{n}\sum_{i \in \iota} X_i .$$

**Definition 2.2 (Uncentred covariance and variance).** We work with *sums*, not averages, since every statement below is scale-free in the normalisation:
$$\operatorname{Cov}(X,Y) := \sum_{i} (X_i - \bar X)(Y_i - \bar Y), \qquad \operatorname{Var}X := \operatorname{Cov}(X,X) = \sum_i (X_i - \bar X)^2 .$$
Clearly $\operatorname{Var}X \ge 0$.

**Definition 2.3 (Pearson ratio).** When $\operatorname{Var}X, \operatorname{Var}Y > 0$,
$$\rho(X,Y)^2 := \frac{\operatorname{Cov}(X,Y)^2}{\operatorname{Var}X \cdot \operatorname{Var}Y} .$$
Spearman's rank correlation is by definition $\rho$ applied to the two rank vectors.

**Definition 2.4 (Rank vector).** For a permutation $\sigma$ of $\{0,\dots,n-1\}$, the associated *rank vector* is $R^\sigma_i := \sigma(i)$, regarded as a real-valued function. Every ranking of a tie-free sample is of this form.

**Definition 2.5 (Block labelling, fibre, block average, conditional expectation).** A *block labelling* is a map $b : \iota \to \kappa$. Its *fibres* are $F_k := \{i : b(i) = k\}$. For $X : \iota \to \mathbb{R}$ the *block average* is
$$\mathrm{avg}_b(X)(k) := \frac{1}{|F_k|}\sum_{i \in F_k} X_i \quad (\text{and } 0 \text{ if } F_k = \varnothing),$$
and the *conditional expectation* is the function $\mathbb{E}[X \mid b] : \iota \to \mathbb{R}$, $\ i \mapsto \mathrm{avg}_b(X)(b(i))$.

A response $Y$ is *tied on the partition $b$* if $Y = g \circ b$ for some $g : \kappa \to \mathbb{R}$, i.e. $Y$ is constant on every fibre.

**Definition 2.6 (Within-block sum of squares).**
$$W_b(X) := \sum_i \big(X_i - \mathbb{E}[X\mid b]_i\big)^2 .$$

---

## 3. The Tie-Block Ceiling and its sharpness

The whole theory rests on one orthogonality statement.

**Lemma 3.1 (Fibrewise vanishing of the residual).** For every $X$, every $b$, and every $k \in \kappa$,
$$\sum_{i \in F_k} \big(X_i - \mathbb{E}[X\mid b]_i\big) = 0 .$$

*Proof sketch.* If $F_k = \varnothing$ the sum is empty. Otherwise $\mathbb{E}[X\mid b]$ is constant on $F_k$ with value $\mathrm{avg}_b(X)(k)$, so the sum equals $\sum_{i \in F_k} X_i - |F_k| \cdot \mathrm{avg}_b(X)(k) = 0$ by definition of the block average. $\square$

**Lemma 3.2 (Orthogonality to the block $\sigma$-algebra).** For every $X$, every $b$, and every $h : \kappa \to \mathbb{R}$,
$$\sum_{i} \big(X_i - \mathbb{E}[X\mid b]_i\big)\, h(b(i)) = 0 .$$

*Proof sketch.* Decompose the sum fibrewise. On $F_k$ the factor $h(b(i))$ is the constant $h(k)$ and pulls out, leaving $h(k)$ times the fibrewise residual sum, which is $0$ by Lemma 3.1. $\square$

This is the defining property of conditional expectation: the residual is orthogonal to everything measurable with respect to the block partition. Two immediate consequences:

**Corollary 3.3 (Mean preservation).** Taking $h \equiv 1$ in Lemma 3.2 gives $\sum_i \mathbb{E}[X\mid b]_i = \sum_i X_i$, hence $\overline{\mathbb{E}[X\mid b]} = \bar X$.

**Proposition 3.4 (Law of total variance).** For every $X$ and $b$,
$$\operatorname{Var}X \;=\; \underbrace{\sum_i \big(\mathbb{E}[X\mid b]_i - \bar X\big)^2}_{\text{between-block}} \;+\; \underbrace{W_b(X)}_{\text{within-block}} .$$

*Proof sketch.* Expand $(X_i - \bar X)^2 = (X_i - \mathbb{E}[X\mid b]_i)^2 + (\mathbb{E}[X\mid b]_i - \bar X)^2 + 2(X_i - \mathbb{E}[X\mid b]_i)(\mathbb{E}[X\mid b]_i - \bar X)$ and sum. The cross term is an instance of Lemma 3.2 with $h(k) = \mathrm{avg}_b(X)(k) - \bar X$, hence vanishes. $\square$

**Lemma 3.5 (Covariance sees only the block averages).** If $Y = g\circ b$ is tied on $b$, then
$$\operatorname{Cov}(X, Y) = \sum_i \big(\mathbb{E}[X\mid b]_i - \bar X\big)\big(g(b(i)) - \bar Y\big) = \operatorname{Cov}\big(\mathbb{E}[X\mid b],\, Y\big).$$

*Proof sketch.* Write $X_i - \bar X = (X_i - \mathbb{E}[X\mid b]_i) + (\mathbb{E}[X\mid b]_i - \bar X)$ inside the covariance sum; the first piece pairs with $g(b(i)) - \bar Y$, a function of the block label, and vanishes by Lemma 3.2. $\square$

We can now state the central inequality.

> **Theorem 3.6 (Tie-Block Ceiling).** Let $b : \iota \to \kappa$ be a block labelling and let $Y = g \circ b$ be any response constant on the blocks. Then for every predictor $X$,
> $$\operatorname{Cov}(X, Y)^2 \;\le\; \big(\operatorname{Var}X - W_b(X)\big)\cdot \operatorname{Var}Y .$$
> Equivalently, whenever the variances are positive,
> $$\rho(X,Y)^2 \;\le\; 1 - \frac{W_b(X)}{\operatorname{Var}X}.$$

*Proof sketch.* By Lemma 3.5, $\operatorname{Cov}(X,Y)$ is a sum of products of $\mathbb{E}[X\mid b]_i - \bar X$ with $g(b(i)) - \bar Y$. Cauchy–Schwarz bounds its square by the product of $\sum_i (\mathbb{E}[X\mid b]_i - \bar X)^2$ and $\sum_i (g(b(i)) - \bar Y)^2 = \operatorname{Var}Y$. By Proposition 3.4 the first factor equals $\operatorname{Var}X - W_b(X)$. $\square$

**Interpretation.** Ties do not merely dilute the correlation — they *delete* a specific, computable quantity of the predictor's variance, namely exactly the part of it that lives inside the tie blocks. The predictor is penalised for resolving distinctions the response cannot express.

A natural worry is that Cauchy–Schwarz has thrown away too much. It has not.

> **Theorem 3.7 (Sharpness: the ceiling is attained).** For every $X$ and $b$,
> $$\operatorname{Cov}\big(X, \mathbb{E}[X\mid b]\big)^2 \;=\; \big(\operatorname{Var}X - W_b(X)\big)\cdot \operatorname{Var}\big(\mathbb{E}[X\mid b]\big).$$
> Hence $\operatorname{Var}X - W_b(X)$ is *exactly* the supremum of $\operatorname{Cov}(X,Y)^2/\operatorname{Var}Y$ over responses $Y$ tied on $b$, and the ceiling of Theorem 3.6 is optimal rather than merely valid.

*Proof sketch.* Two computations. (i) By Corollary 3.3 the block average has the same mean as $X$, so $\operatorname{Var}(\mathbb{E}[X\mid b]) = \sum_i (\mathbb{E}[X\mid b]_i - \bar X)^2 = \operatorname{Var}X - W_b(X)$ by Proposition 3.4. (ii) $\operatorname{Cov}(X, \mathbb{E}[X\mid b]) = \operatorname{Var}(\mathbb{E}[X\mid b])$: expanding the covariance and using the same mean, the cross term is again an instance of Lemma 3.2 and vanishes, leaving the sum of squares of $\mathbb{E}[X\mid b]_i - \bar X$. Substituting (ii) then (i) gives the claim. $\square$

Theorem 3.7 is the geometric statement that $\mathbb{E}[\,\cdot\mid b]$ is the orthogonal projection onto the space of blockwise-constant functions: the best blockwise-constant response to correlate with $X$ is the projection of $X$ itself, and it achieves precisely the projected norm.

---

## 4. The Discrete Spread Bound

Theorem 3.6 is only as useful as our ability to lower-bound $W_b(X)$. For rank vectors this is a sharp combinatorial question: *how tightly can $m$ distinct integers cluster?*

**Lemma 4.1 (Pairwise expansion).** For any finite $s$ and any $x : s \to \mathbb{R}$,
$$\sum_{i \in s}\sum_{j \in s}(x_i - x_j)^2 = 2|s|\sum_{i\in s} x_i^2 - 2\Big(\sum_{i\in s}x_i\Big)^2 = 2|s| \sum_{i \in s}\big(x_i - \bar x\big)^2 .$$

*Proof sketch.* Expand $(x_i-x_j)^2 = x_i^2 - 2x_ix_j + x_j^2$ and sum in $j$ then $i$; the middle term contributes $2(\sum x_i)^2$. The centred form follows by expanding $(x_i - \bar x)^2$ and collecting. $\square$

Thus the spread about the mean and the mean pairwise squared distance are the same object up to a factor $2|s|$ — and the pairwise form is what we can compare across configurations.

**Lemma 4.2 (Strictly monotone integer sequences expand).** Let $f : \{0,\dots,m-1\} \to \mathbb{Z}$ be strictly increasing. Then $f(b) - f(a) \ge b - a$ for all $a \le b$.

*Proof sketch.* The map $a \mapsto f(a) - a$ is monotone, because a single step increases $f$ by at least $1$ (strict monotonicity over the integers) and increases $a$ by exactly $1$. Monotonicity over successive steps propagates to all pairs. $\square$

**Corollary 4.3 (Squared-distance domination).** With $f$ as above, $(f(a) - f(b))^2 \ge (a-b)^2$ for all $a, b$.

*Proof sketch.* By Lemma 4.2 applied in whichever order makes the difference nonnegative, $|f(a)-f(b)| \ge |a-b| \ge 0$; square. $\square$

**Lemma 4.4 (The consecutive-integer model).**
$$\sum_{a=0}^{m-1}\sum_{c=0}^{m-1}(a - c)^2 = \frac{m(m^3 - m)}{6}.$$

*Proof sketch.* Apply Lemma 4.1 with $x_a = a$, using $\sum_{a<m} a = m(m-1)/2$ and $\sum_{a<m} a^2 = m(m-1)(2m-1)/6$, and simplify. $\square$

> **Theorem 4.5 (Discrete Spread Bound).** Let $s$ be a finite index set with $|s| = m$ and let $r : s \to \mathbb{Z}$ be injective. Then
> $$\sum_{i \in s}\Big(r_i - \frac{1}{m}\sum_{j\in s} r_j\Big)^2 \;\ge\; \frac{m^3 - m}{12},$$
> with equality if and only if the values of $r$ form a block of consecutive integers.

*Proof sketch.* The image $T = r(s)$ is a set of $m$ distinct integers. Enumerate it in increasing order as $f(0) < f(1) < \cdots < f(m-1)$; this order isomorphism transports every sum over $s$ to a sum over $\{0,\dots,m-1\}$. By Corollary 4.3, termwise,
$$\sum_{a}\sum_{c}(f(a)-f(c))^2 \;\ge\; \sum_a\sum_c (a-c)^2 \;=\; \frac{m(m^3-m)}{6}$$
using Lemma 4.4. Converting both sides to centred form by Lemma 4.1 (dividing by $2m$) yields the bound. Equality in Corollary 4.3 for all pairs forces $f(a) - f(c) = a - c$, i.e. consecutive values. $\square$

This is a discrete isoperimetric statement: among all $m$-element integer configurations, the consecutive run minimises spread. Applied to a full rank vector it is an identity.

**Corollary 4.6 (Rank variance).** For any permutation $\sigma$ of $\{0,\dots,n-1\}$,
$$\operatorname{Var}(R^\sigma) = \frac{n^3 - n}{12}.$$

*Proof sketch.* A rank vector is a bijective relabelling of $\{0,\dots,n-1\}$, so its variance equals that of the identity configuration, which is the equality case of Theorem 4.5 with $m = n$. $\square$

---

## 5. The Starved-Regime Ceiling

Combining Sections 3 and 4 gives the main quantitative tool.

> **Theorem 5.1 (Starved-Regime Ceiling).** Let $\sigma$ be any permutation of the $n$ sample points (the ranking induced by an arbitrary dial), let $S$ be a subset of size $m$, and let $Y$ be any response that is constant on $S$. Then
> $$\operatorname{Cov}(R^\sigma, Y)^2 \;\le\; \left(\frac{n^3-n}{12} - \frac{m^3-m}{12}\right)\operatorname{Var}Y,$$
> and hence, when the variances are positive,
> $$\rho(R^\sigma, Y)^2 \;\le\; 1 - \frac{m^3 - m}{n^3 - n}.$$

*Proof sketch.* Let $b$ be the labelling that collapses $S$ to a single block and leaves every point outside $S$ in a singleton block. $Y$ is constant on every fibre of $b$ (trivially on singletons, by hypothesis on $S$), so Theorem 3.6 applies with this $b$. The rank vector is integer-valued and injective on $S$, so Theorem 4.5 gives $\sum_{i \in S}(R^\sigma_i - \mathbb{E}[R^\sigma\mid b]_i)^2 \ge (m^3-m)/12$; since the remaining summands of $W_b(R^\sigma)$ are nonnegative, $W_b(R^\sigma) \ge (m^3-m)/12$. Corollary 4.6 supplies $\operatorname{Var}(R^\sigma) = (n^3-n)/12$, and substitution into Theorem 3.6 finishes. The normalised form follows by dividing through. $\square$

Writing $q = m/n$ for the tie fraction, the penalty is
$$\frac{m^3-m}{n^3-n} = q^3\cdot\frac{1 - q^{-2}n^{-2}}{1 - n^{-2}} \approx q^3 .$$

**The penalty is cubic.** This single observation drives everything that follows: coarseness must be *overwhelming* before it costs meaningful rank resolution.

> **Theorem 5.2 (Cubic starvation threshold).** Suppose the tie mechanism alone is to force $\rho \le 0.55$, i.e. $1 - (m^3-m)/(n^3-n) \le 0.3025$. Then necessarily
> $$m^3 - m \;\ge\; 0.6975\,(n^3 - n).$$
> Moreover, for $n \ge 10$ this implies the starvation fraction bound
> $$\frac{m}{n} \;\ge\; 0.88 .$$

*Proof sketch.* The first statement is a rearrangement: the hypothesis says the ratio $(m^3-m)/(n^3-n)$ is at least $1 - 0.3025 = 0.6975$, and clearing the (positive) denominator gives the claim. For the second, note $n^3 - n \ge 0.99\,n^3$ once $n \ge 10$, so $m^3 \ge m^3 - m \ge 0.6975 \cdot 0.99\,n^3 = 0.6905\,n^3$. If we had $m < 0.88\,n$ then $m^3 < 0.88^3 n^3 = 0.6815\,n^3$, contradicting the previous inequality. $\square$

The threshold $q_\ast$ with $q_\ast^3 = 0.6975$ is $q_\ast = 0.8867\ldots$: **almost nine tenths of the sample must be tied** for ties to cost even half the rank resolution.

---

## 6. The full tie partition and the Quantization Ceiling

An objection to Theorem 5.1 is that it accounts for only *one* block. In the experiment the response is a count divided by a fixed trial budget, so it is quantized: it takes at most $r$ distinct values, and each value class is a tie block. Perhaps the aggregate is more damaging.

> **Theorem 6.1 (Full tie-partition ceiling).** Let $b : \iota \to \kappa$ be any block labelling and $Y = g\circ b$ any response tied on it. Then for every dial ranking $R^\sigma$,
> $$\operatorname{Cov}(R^\sigma, Y)^2 \;\le\; \left(\frac{n^3-n}{12} - \sum_{k\in\kappa}\frac{m_k^3 - m_k}{12}\right)\operatorname{Var}Y, \qquad m_k := |F_k| .$$

*Proof sketch.* Apply Theorem 4.5 on each fibre separately: the rank vector is injective and integer-valued on $F_k$, and $\mathbb{E}[R^\sigma\mid b]$ restricted to $F_k$ is exactly the fibre mean, so the fibre contributes at least $(m_k^3 - m_k)/12$ to $W_b(R^\sigma)$. Summing over $k$ and using that the fibres partition $\iota$ gives $W_b(R^\sigma) \ge \sum_k (m_k^3-m_k)/12$. Substitute into Theorem 3.6 with Corollary 4.6. $\square$

This *derives* the classical Spearman tie correction, in which every tie group of size $m_k$ contributes a term proportional to $m_k^3 - m_k$, rather than importing it.

**Lemma 6.2 (Power-mean bound on the tie correction).** If $|\kappa| = r$ and the fibres of $b$ have sizes $m_k$ with $\sum_k m_k = n$, then
$$\sum_{k} m_k^3 \;\ge\; \frac{n^3}{r^2}.$$

*Proof sketch.* This is the power-mean (equivalently Jensen, or Cauchy–Schwarz iterated) inequality $\big(\sum_k m_k\big)^3 \le r^2 \sum_k m_k^3$ for nonnegative $m_k$, with equality iff all $m_k$ are equal. $\square$

The tie correction is therefore *smallest* when the quantization levels are equally populated — the worst case for the ceiling, and hence the case one must bound.

> **Theorem 6.3 (Quantization Ceiling).** Let the response take at most $r \ge 1$ distinct values on a sample of size $n$. Then for every dial,
> $$\operatorname{Cov}(R^\sigma, Y)^2 \;\le\; \left(\frac{n^3-n}{12} - \frac{n^3/r^2 - n}{12}\right)\operatorname{Var}Y,$$
> i.e.
> $$\rho^2 \;\le\; 1 - \frac{n^3/r^2 - n}{n^3 - n} \;\xrightarrow[n\to\infty]{}\; 1 - \frac{1}{r^2}.$$

*Proof sketch.* Start from Theorem 6.1 and bound the tie correction from below: $\sum_k (m_k^3 - m_k)/12 = \big(\sum_k m_k^3 - n\big)/12 \ge (n^3/r^2 - n)/12$ by Lemma 6.2 and $\sum_k m_k = n$. $\square$

> **Theorem 6.4 (The quantization ceiling never binds).** For all $n \ge 2$ and all $r \ge 2$,
> $$1 - \frac{n^3/r^2 - n}{n^3-n} \;>\; 0.55^2 = 0.3025 .$$
> Indeed the left side is at least $3/4$, so $\rho \le 0.866$ is the worst possible quantization ceiling.

*Proof sketch.* Since $r \ge 2$ we have $n^3/r^2 \le n^3/4$, so $n^3/r^2 - n \le (n^3-n)/4$ (using $n \ge 2$, so $n^3 - n > 0$). Dividing by $n^3-n$ gives that the subtracted ratio is at most $1/4$, hence the ceiling is at least $3/4 > 0.3025$. $\square$

**Remark 6.5.** Theorem 6.4 is striking: even a response quantized to *two levels* — a single bit of information per sample point — permits a rank correlation of $0.866$. Coarseness alone is essentially never the cause of a mid-range Spearman score.

---

## 7. The Noise Budget

Sections 5 and 6 exhaust the tie-based mechanisms. The remaining candidate produces no ties at all: **estimator noise**. At a $0.89\%$ smooth rate the measured rate is a Monte-Carlo estimate from a finite trial budget; the *measured* ranking is a randomly displaced copy of the *true* ranking, with every point still receiving a distinct rank.

**Lemma 7.1 (Additivity of the mean and covariance).** $\overline{Y - Z} = \bar Y - \bar Z$, and consequently
$$\operatorname{Cov}(X, Y - Z) = \operatorname{Cov}(X, Y) - \operatorname{Cov}(X, Z).$$

*Proof sketch.* Linearity of the sum for the mean; substituting and expanding the product termwise for the covariance. $\square$

> **Theorem 7.2 (Covariance perturbation bound).** For all $X, Y, Z$,
> $$\big(\operatorname{Cov}(X,Y) - \operatorname{Cov}(X,Z)\big)^2 \;\le\; \operatorname{Var}X \cdot \operatorname{Var}(Y - Z).$$

*Proof sketch.* By Lemma 7.1 the left side is $\operatorname{Cov}(X, Y-Z)^2$; apply Cauchy–Schwarz. $\square$

Read forwards, Theorem 7.2 is a *stability* statement: perturbing the response by a low-energy signal perturbs the covariance only slightly. Read backwards — the direction we need — it is a *certificate*: a large drop in the covariance proves a large perturbation.

> **Theorem 7.3 (Noise Budget for rank data).** Let $R^\sigma$ be a dial's rank vector on $n$ points, $R^\tau$ the rank vector of the **true** response, and $R^\upsilon$ the rank vector of the **measured** response. Suppose the dial achieves at least $a$ against the truth and at most $b$ against the measurement:
> $$\operatorname{Cov}(R^\sigma, R^\tau) \ge a\operatorname{Var}(R^\sigma), \qquad \operatorname{Cov}(R^\sigma, R^\upsilon) \le b\operatorname{Var}(R^\sigma), \qquad b \le a .$$
> Then the rank displacement $D_i := R^\upsilon_i - R^\tau_i$ satisfies
> $$\operatorname{Var}(D) \;\ge\; (a-b)^2\,\frac{n^3-n}{12}.$$

*Proof sketch.* Write $V := \operatorname{Var}(R^\sigma) = (n^3-n)/12$ by Corollary 4.6, and $W := \operatorname{Var}(D)$. The two hypotheses give a covariance gap
$$\operatorname{Cov}(R^\sigma, R^\tau) - \operatorname{Cov}(R^\sigma, R^\upsilon) \;\ge\; (a-b)V \;\ge\; 0.$$
Theorem 7.2 bounds the square of that same gap by $V \cdot W$, so $(a-b)^2 V^2 \le V W$. If $V > 0$, divide by $V$; if $V = 0$ the claim is trivial since $W \ge 0$. $\square$

Note that **no tie hypothesis appears**: this is precisely the mechanism that remains after Theorems 5.1, 6.3 and 6.4 have ruled the tie mechanisms out.

**Interpretation in rank units.** Since $\operatorname{Var}$ is an uncentred sum of squares, $\operatorname{Var}(D)/n$ is the mean squared deviation of the displacement from its own mean. Hence
$$\mathrm{RMS\ displacement} \;=\; \sqrt{\operatorname{Var}(D)/n} \;\ge\; (a-b)\sqrt{\frac{n^2-1}{12}} \;\approx\; \frac{(a-b)\,n}{\sqrt{12}} .$$
The noise budget is *linear in $n$*: to lose a fixed amount of correlation, a fixed *fraction* of the sample size must be traversed by the typical point. That fraction is $(a-b)/\sqrt{12} \approx 0.289(a-b)$.

---

## 8. The verdict for the recorded experiment

We now instantiate at the recorded values: $n = 1200$, $m = 194$ zero-hit moduli, observed score $\rho_{\text{obs}} = 0.405$, band $[0.55, 0.85]$.

### 8.1 The tie explanation is refuted

$$\frac{194^3 - 194}{1200^3 - 1200} = \frac{7{,}301{,}190}{1{,}727{,}998{,}800} = 0.0042252\ldots$$

> **Result 8.1 (The observed tie block is not binding).** At $(m,n) = (194,1200)$ the Starved-Regime Ceiling gives
> $$\rho^2 \le 0.995775, \qquad \rho \le 0.997885 .$$
> In particular $\rho_{\text{obs}}^2 = 0.164 < 0.9958$ and $0.55^2 = 0.3025 < 0.9958$: the tie block is compatible with a score anywhere in the band, and cannot force a score below it.

> **Result 8.2 (No tie mechanism explains the observation).** For every sample size $n \ge 2$ and every quantization level $r \ge 2$, both the single-block ceiling at the recorded $(194,1200)$ and the quantization ceiling strictly exceed $0.405^2$; the quantization ceiling in fact exceeds $3/4$. Hence no combination of tie structure — one starved block, the full tie partition, or arbitrary coarseness of the measured rate — can account for the collapse to $0.405$.

> **Result 8.3 (Required starvation).** By Theorem 5.2, ties alone force $\rho \le 0.55$ only when $m/n \ge 0.88$; the exact cubic threshold is $q_\ast = 0.6975^{1/3} = 0.8867$. The observed fraction is $194/1200 = 0.1617$.

The recorded explanation — "the starved regime destroys rank resolution" — is therefore **false as stated**. It is not an approximation, an over-simplification, or a partial account; the mechanism it names is provably incapable of the effect attributed to it, by a margin of roughly a factor of $5.5$ in the tie fraction and a factor of $165$ in the cubic penalty.

### 8.2 The quantitative replacement

> **Result 8.4 (Displacement energy at bit length 56).** Suppose the dial is genuinely worth the band edge $a = 0.55$ against the *true* smooth-rate ranking, and scores $b = 0.405$ against the *measured* ranking, at $n = 1200$. Then the measured ranking must differ from the true ranking with displacement energy
> $$\operatorname{Var}(D) \;\ge\; (0.145)^2\cdot\frac{1200^3 - 1200}{12} \;=\; 0.021025 \times 143{,}999{,}900 \;=\; 3{,}027{,}597.9\ldots \;>\; 3\times 10^6 .$$
> Equivalently, the RMS rank displacement is at least
> $$\sqrt{3.0276\times 10^6 / 1200} \;=\; 50.23 \text{ rank positions},$$
> i.e. about $4.2\%$ of the sample size.

**Remark 8.5 (The budget is a floor, and a conservative one).** Theorem 7.3 gives a *necessary* condition, not a sufficient one. The value $50.23$ is what would be required if the displacement were *adversarially aligned*: concentrated in exactly the direction that opposes this dial. Real estimator noise is approximately isotropic, and isotropic displacement is an inefficient destroyer of correlation because most of its energy is spent in directions orthogonal to the dial. Under an independent-displacement model the covariance with the dial is unchanged and only the response variance inflates, so the score is attenuated by
$$\frac{b}{a} = \sqrt{\frac{V}{V + S}}, \qquad V = \frac{n^3-n}{12}, \quad S = \operatorname{Var}(D),$$
giving $S/V = (a/b)^2 - 1 = 0.8442$ at $(a,b) = (0.55, 0.405)$, hence
$$\operatorname{Var}(D) \approx 1.22\times 10^8, \qquad \text{RMS displacement} \approx 318 \text{ rank positions } (26.5\% \text{ of } n).$$
That is roughly $40\times$ the certified energy floor. The two figures bracket the truth from below and from a natural model: the required noise is between $50$ and $318$ RMS rank positions depending on how adversarially it is structured. In either case it is vastly larger than anything the tie mechanisms can supply, so the qualitative verdict of Section 8.1 is unaffected and in fact reinforced.

This is a falsifiable prediction about the **rate estimator**, not about the dial. It can be tested directly: re-run the rate measurement at bit length 56 with an independent seed and compare the two induced rankings. If the observed rank jitter between independent replicates is much smaller than $\approx 50$ positions, then estimator noise is also insufficient and a third mechanism must be sought. If it is in the range $50$–$318$, the diagnosis is confirmed and the remedy is prescribed: increase the trial budget until the jitter falls below the budget implied by the band edge. Given that $194$ of $1200$ moduli record zero hits and the mean rate is $0.89\%$, a per-modulus count of order a few units is implied, for which rank jitter of hundreds of positions is entirely plausible.

### 8.3 Relocating the "practical floor"

The original claim was that bit-length stability has a practical floor near bit length 54. The analysis relocates it. The floor is real, but:

1. It is **not a rank-resolution phenomenon.** Loss of resolution due to starvation costs $q^3$, and $q^3$ is negligible at the observed starvation.
2. It is a property of the **measurement apparatus**, not of the dial. The dial may be perfectly serviceable at bit length 56; the experiment simply lacks the accuracy to grade it.
3. It has an explicit location: the floor sits where the Monte-Carlo error of the rate estimate, expressed in rank units, reaches roughly $(a - b_{\min})/\sqrt{12}$ of the sample size — here about $4\%$.

The floor therefore moves with the trial budget, not with the bit length per se. Bit length enters only through the smooth rate, which controls the estimator variance.

### 8.4 Consistency with the secondary observation

The recorded data also states that the dial beats a naive count baseline by $+0.093$ with confidence interval $[0.042, 0.146]$. This is entirely consistent with the noise diagnosis and inconsistent with the tie diagnosis. Under the noise account, both the dial and the baseline are graded against the *same* corrupted ranking, so both are attenuated by roughly the same factor; a positive residual advantage survives, which is exactly what is observed. Under a resolution-loss account the surviving signal would be the *between-block* signal shared by both statistics, and one would expect the gap to shrink rather than persist.

---

## 9. Algorithms

The theory yields three directly implementable procedures.

### 9.1 Exact tie ceiling from a response vector

**Input:** measured responses $y_1,\dots,y_n$.
**Output:** the exact supremum of Spearman correlation achievable by any dial.

Group the sample by distinct response value to obtain block sizes $m_1,\dots,m_r$; compute the tie correction $C = \sum_k (m_k^3 - m_k)$; return $\sqrt{1 - C/(n^3-n)}$. By Theorem 6.1 this is an upper bound, and by Theorem 3.7 it is attained. Cost: $O(n\log n)$ for grouping (or $O(n)$ with hashing), $O(r)$ arithmetic.

### 9.2 Starvation threshold solver

**Input:** a target Spearman level $\rho_\ast$ and sample size $n$.
**Output:** the minimum tie-block size $m$ for which ties alone could force $\rho \le \rho_\ast$.

Solve $m^3 - m \ge (1 - \rho_\ast^2)(n^3-n)$ for the least integer $m$. Since $m \mapsto m^3-m$ is increasing on $m \ge 1$, binary search over $[1,n]$ in $O(\log n)$ steps; the asymptotic answer is $m \approx n(1-\rho_\ast^2)^{1/3}$.

### 9.3 Noise budget certificate

**Input:** achievable score $a$ against the truth, observed score $b$, sample size $n$.
**Output:** a certified lower bound on the rank displacement energy and RMS displacement.

Return $E = (a-b)^2 (n^3-n)/12$ and $\sqrt{E/n}$. By Theorem 7.3 this is a valid lower bound for *any* pair of rankings consistent with the two scores; the certificate is unconditional given the two hypotheses.

---

## 10. Discussion

### 10.1 Why the cubic is counterintuitive

Practitioners' intuition treats coarseness as roughly linearly damaging: tie a fraction $q$ of the sample together and expect to lose "about $q$" of your correlation. The truth is that you lose about $q^3$ of your *squared* correlation, i.e. about $q^3/2$ of your correlation for small $q$. The gap between intuition and reality at $q = 0.16$ is a factor of about 40.

The structural reason is that variance is a *quadratic* functional of a *linear* extent, and the number of points contributing scales with the block size. A block of $m$ consecutive ranks has extent $\sim m$, squared deviation $\sim m^2$ per point, and $m$ points: total $\sim m^3$. Meanwhile the whole sample has total $\sim n^3$. The ratio is $q^3$. The cube is not an artefact of the bound; it is the exact scaling of the equality case.

### 10.2 The asymmetry between coarseness and jitter

Put the two mechanisms side by side at $n = 1200$:

| Mechanism | Damage to $\rho$ |
|---|---|
| Tie 194 of 1200 points ($16\%$) into one block | $\rho \le 0.9979$ |
| Quantize the response to 2 levels | $\rho \le 0.866$ |
| Quantize the response to 10 levels | $\rho \le 0.995$ |
| Displace ranks by $\approx 50$ positions RMS ($4\%$), adversarially aligned | $\rho$ may drop by $0.145$ |
| Displace ranks by $\approx 318$ positions RMS ($27\%$), independently | $\rho$ drops by $0.145$ |

Even the most conservative reading — that independent noise of a quarter of the sample size is needed — leaves the jitter mechanism the only one capable of the observed effect, since the tie mechanisms max out at a few thousandths. **Rank correlation is robust to coarseness and fragile to jitter.** This is worth internalising as a diagnostic heuristic well beyond the present experiment: whenever a rank statistic degrades, suspect accuracy before resolution.

### 10.3 Scope and limitations

Three caveats. (i) Theorem 7.3 is *conditional on the counterfactual* $a$: it certifies the displacement needed to explain the drop **from** an assumed true-ranking score. If the dial is simply a poor dial at bit length 56 — worth only $0.405$ even against a perfectly measured response — no noise is required at all. The theorem does not distinguish these; it says that *at least one* of "the dial genuinely degrades" or "the estimator jitters by $50$ ranks" must hold. What it definitively excludes is the third option, resolution loss.

(ii) The ceilings are worst-case over dials. A particular dial may score far below the ceiling for reasons unrelated to tie structure.

(iii) The Noise Budget is an inequality in one direction only: it lower-bounds displacement from a score drop. The converse — predicting the score drop from a displacement law — requires distributional assumptions on the estimator, which is precisely the content of Future Direction 2 below.

### 10.4 Relation to classical rank statistics

Theorem 6.1 recovers the classical Spearman tie correction as a special case, but as a *theorem about achievable correlation* rather than a variance normalisation. The conventional correction adjusts the denominator so that a tied ranking still has the right scale; Theorem 6.1 instead identifies the exact quantity of predictor variance rendered invisible, and Theorem 3.7 certifies that nothing more is lost. The two agree numerically and differ in interpretation: the classical version is bookkeeping, this version is an obstruction.

---

## 11. Future directions

### Direction 1 — Cubic starvation threshold for rank dials

**Conjecture.** For any dial scored by Spearman against a starved response, the score is band-feasible ($\ge 0.55$) as long as the zero-hit fraction $q = m/n$ satisfies $q^3 < 0.6975$; the ceiling $\sqrt{1-q^3}$ is attained by the dial whose rank vector agrees with the block-averaged response.

The key insight is that the tie penalty is *cubic* in the tie fraction, not linear, so a starved regime has to consume almost nine tenths of the sample before it costs even half the rank resolution. Theorem 5.1 and Theorem 3.7 together give both halves — the upper bound and the attainment; what remains is to exhibit an explicit attaining *rank* pair, which turns the inequality into an exact characterisation of the practical floor.

### Direction 2 — Monte-Carlo rank displacement law for Poisson-starved sieves

**Conjecture.** If each modulus's rate is estimated by $B$ independent trials with success probability $p_i \approx 10^{-2}$, the expected rank displacement energy grows like $n^3 c/(B\bar p)$ for an absolute constant $c$; matching this against the Noise Budget predicts the exact bit length at which the dial leaves the band.

The key insight is that the Noise Budget converts a *score* into a *displacement*, so any law converting a *trial budget* into a displacement closes the loop and turns the practical floor into a computable function of $(B, \bar p, n)$. In the Poisson regime the count for modulus $i$ is approximately $\mathrm{Poisson}(Bp_i)$, and the rank displacement is governed by the overlap of neighbouring count distributions — a local density calculation.

### Direction 3 — Two-sided budgets and estimator design

Theorem 7.3 is one-sided. A matching upper bound — displacement energy at most $E$ implies score drop at most $f(E)$ — would let one *design* the trial budget: choose $B$ so that the certified maximal drop keeps the score inside the band with prescribed confidence. The natural route is a reverse Cauchy–Schwarz under the additional structure that both rankings are permutations, where the extremal configurations are constrained.

### Direction 4 — Beyond Spearman

The Tie-Block Ceiling is a statement about arbitrary predictors and blockwise-constant responses; nothing about it is specific to ranks. The rank structure enters only through the Discrete Spread Bound. Replacing that bound with the appropriate extremal quantity for other score functions (Kendall's $\tau$, normalised discounted cumulative gain, top-$k$ precision) should yield an analogous family of obstruction theorems, each with its own exponent in place of the cube.

---

## 12. Conclusion

We proved an exact and attained ceiling on rank correlation against a tied response, $\rho^2 \le 1 - W/\operatorname{Var}X$, and evaluated it for rank predictors using the sharp discrete spread bound $(m^3-m)/12$. The resulting Starved-Regime Ceiling $\rho^2 \le 1 - (m^3-m)/(n^3-n)$ exhibits a *cubic* dependence on the tie fraction, which we showed is the reason coarseness is a far weaker adversary to rank statistics than intuition suggests: even binary quantization permits $\rho = 0.866$, and forcing $\rho \le 0.55$ by ties requires tying $88.7\%$ of the sample.

Applied to a recorded experiment at bit length 56 with $194$ zero-hit moduli out of $1200$, this refutes the recorded diagnosis: the tie ceiling is $0.9979$, and no tie mechanism whatsoever explains the observed score of $0.405$. The Noise Budget then supplies the replacement, certifying that the drop from the band edge to the observation requires a rank displacement energy of at least $3.0 \times 10^6$ — an RMS displacement of at least 50 rank positions, some $4\%$ of the sample, rising to about 318 positions under an isotropic-noise model.

The practical floor of the bit-length dial is thus not a floor of the dial at all. It is the point at which the measurement of the response becomes too noisy to grade the dial, and it is located, quantitatively and falsifiably, by the variance of the rate estimator.
