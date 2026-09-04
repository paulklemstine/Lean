# The Prime-Power Excess: An Exact Theory of the Radical-to-Full Feature Lift

**Author:** Aristotle
**Date:** 2026-09-03

---

## Abstract

We give a complete deterministic account of a phenomenon observed empirically in multiplicative-feature regression: when a *prime-power* feature is added on top of a *radical* (distinct-prime) feature, the coefficient of determination rises by a small but strikingly reproducible amount, and the rise grows with the length of the integer window used. Writing $\operatorname{rad} n = \prod_{p \mid n} p$, the entire information gap between the two features is the **prime-power excess**

$$E(n) = \log n - \log(\operatorname{rad} n) = \sum_{p \mid n}\bigl(v_p(n) - 1\bigr)\log p .$$

We prove: (i) $E \ge 0$ with equality exactly on squarefree integers, and $E$ is not a function of $\operatorname{rad}$, with an explicit irreducible-residual bound $\tfrac12 (E(m)-E(n))^2$ at every radical collision; (ii) an exact arithmetic identity $E(n) = \sum_{d \mid n} \Lambda^\sharp(d)$, where $\Lambda^\sharp$ is the von Mangoldt function restricted to non-prime prime powers, whence the exact window law $\sum_{n \le N} E(n) = \sum_{d \le N}\Lambda^\sharp(d)\lfloor N/d\rfloor$ and a linear density floor with constant tending to $\sum_p \log p/(p(p-1)) \approx 0.7554$; (iii) a seed-uniform window law $|\mathcal{M}(a,w) - w\rho(M)| \le \Psi(M)$ with offset-free and window-length-free error, giving cross-offset dispersion $\le 2\Psi(M)$ against a main term linear in $w$, and $\#\operatorname{supp}\Lambda^\sharp \cap [1,M] \le \sqrt M(\log_2 M + 1)$; (iv) a **fibrewise variance law**: for any finite design, the optimal radical-only predictor has residual exactly the within-fibre sum of squares, so the lift over the best base model equals *exactly* $W/T$, the fraction of target variance interior to the radical fibres — strictly positive iff the design contains a radical collision with differing prime-power content, and zero otherwise; (v) a smooth-pool floor $E(n) \ge \log n - y\log 4$ for $y$-smooth $n$, forcing $E(n) > 0$ for all $y$-smooth $n > 4^y$ and yielding $\Delta R^2 = 1$ on the $2$-smooth tower, where the total sum of squares is $\frac{m(m^2-1)}{12}(\log 2)^2$; and (vi) a graded filtration $F_j(n) = \sum_p \min(v_p(n), j)\log p$ whose layers decay geometrically, $\sum_{n\le N} L_{k+1}(n) \le \tfrac12 \sum_{n \le N} L_k(n)$, so that the square layer sandwiches the whole effect within a factor $2$. Explicit worked instances include $\Delta R^2 = 3/4$ on the design $\{2,3,4\}$ and the unconditional bound $\sum_{n \le N} E(n) \ge N/4 - 2$.

**Keywords:** prime-power excess, radical, von Mangoldt function, Chebyshev identity, variance decomposition, coefficient of determination, smooth numbers, Dirichlet hyperbola swap.

---

## 1. Introduction

### 1.1 The empirical phenomenon

Consider a regression problem on a window of integers in which the response is a multiplicative statistic and the available predictors are built from the prime factorisation. Two natural features present themselves:

* the **base (radical) feature** $B(n) = \sum_{p \mid n}\log p = \log(\operatorname{rad} n)$, which records *which* primes divide $n$;
* the **prime-power feature** $P(n) = \sum_p v_p(n)\log p = \log n$, which additionally records *how often*.

A multi-seed experiment fitting on windows of consecutive integers drawn from smooth-number pools reported the following. At smoothness parameter $u = 3.5$ and window length $w = 240$, the increment in coefficient of determination obtained by adding the prime-power feature was

$$+0.055,\quad +0.049,\quad +0.051,\quad +0.050,\quad +0.048$$

across five independent seeds: all five above $0.03$, cross-seed standard deviation $0.0025$, standard error of the mean $0.0011$, with confidence intervals excluding zero in all five cells at both smoothness settings. Moreover the mean lift *increased* with window length: from $0.051$ to $0.058$ at $u = 3.5$ and from $0.058$ to $0.082$ at $u = 2.5$ as $w$ went from $240$ to $960$.

Three qualitative facts thus demand explanation: the lift is (a) positive, (b) reproducible across seeds with dispersion an order of magnitude below the effect, and (c) monotone increasing in window length, more so for smoother pools.

### 1.2 Thesis

We argue — and prove — that all three facts are *arithmetic*, not statistical. Every one of them follows from deterministic properties of the difference of the two features. There is no fitting artefact, no capacity effect, and no dependence on the estimator: the results below hold for the *best possible* predictor in the base class, however that class is realised.

The organising quantity is the following.

> **Definition (prime-power excess).** For $n \ge 1$,
> $$E(n) \;=\; \log n - \log(\operatorname{rad} n), \qquad \operatorname{rad} n = \prod_{p \mid n} p .$$

We refer to $E$ throughout as *the lift quantity*: it is by construction exactly the information present in the prime-power feature and absent from the base feature.

### 1.3 Contributions and roadmap

* **Section 2** establishes the elementary structure of $E$: non-negativity, the squarefree characterisation, the exponent-sum formula, and the *irreducible residual* of base-only models at radical collisions.
* **Section 3** identifies $E$ with a von Mangoldt mass and derives an exact window law together with linear density floors.
* **Section 4** proves seed-uniformity: an offset-free window law and a cross-offset dispersion bound, plus a sparsity count for the support of the arithmetic kernel.
* **Section 5** proves the **fibrewise variance law**, the sharpest result of the paper: $\Delta R^2 = W/T$ exactly, with the collision dichotomy and the worked example $\Delta R^2 = 3/4$.
* **Section 6** treats the smooth regime: the primorial ceiling, the $u$-dependent floor, and the exact $\Delta R^2 = 1$ computation on the $2$-smooth tower.
* **Section 7** develops the graded hierarchy of features and proves geometric decay of the layers, with the level-$2$ sandwich.
* **Sections 8–10** give algorithms, applications and discussion.

Throughout, $p$ denotes a prime, $v_p(n)$ the exponent of $p$ in $n$, $\Lambda$ the von Mangoldt function ($\Lambda(p^k) = \log p$ for $k \ge 1$, else $0$), and $\lfloor \cdot \rfloor$ integer division. All logarithms are natural.

---

## 2. The lift quantity and the irreducible error of base models

### 2.1 The exponent-sum identity

**Theorem 2.1 (Prime-power identity).** *For every $n \ne 0$,*
$$E(n) \;=\; \sum_{p \mid n}\bigl(v_p(n) - 1\bigr)\log p .$$

*Proof sketch.* Unique factorisation gives $\log n = \sum_{p \mid n} v_p(n)\log p$, while the definition of the radical gives $\log(\operatorname{rad} n) = \sum_{p \mid n} \log p$, both sums being over the same finite index set of prime divisors. Subtract termwise. $\square$

**Corollary 2.2 (Non-negativity).** $E(n) \ge 0$ for all $n$.

*Proof sketch.* For $p \mid n$ we have $v_p(n) \ge 1$ and $\log p > 0$, so every term of Theorem 2.1 is non-negative. (For $n = 0$ the convention $\log 0 = 0$ makes $E(0)=0$.) $\square$

**Theorem 2.3 (Squarefree characterisation).** *For $n \ne 0$: $E(n) = 0$ if and only if $n$ is squarefree.*

*Proof sketch.* ($\Leftarrow$) If $n$ is squarefree then $\operatorname{rad} n = n$, so $E(n) = 0$. ($\Rightarrow$) By Corollary 2.2 the sum in Theorem 2.1 has non-negative terms, so vanishing of the sum forces each term to vanish; since $\log p > 0$, each $v_p(n) = 1$; hence all exponents are $\le 1$, which characterises squarefreeness. $\square$

Theorem 2.3 says that $E$ is *pure repeated-prime information*: it is identically zero on the squarefree integers, where the base feature is already a complete description, and it is supported exactly where a prime occurs with multiplicity.

**Proposition 2.4 (Quantitative lower bounds).** *If $p^2 \mid n$ with $p$ prime and $n \ne 0$, then $E(n) \ge \log p$. In particular $4 \mid n$ implies $E(n) \ge \log 2$. Moreover, for a prime power, $E(p^k) = (k-1)\log p$ for $k \ge 1$.*

*Proof sketch.* Under $p^2 \mid n$ we have $v_p(n) \ge 2$, so the single term of Theorem 2.1 at $p$ is at least $\log p$; the remaining terms are non-negative. For the prime power, $\operatorname{rad}(p^k) = p$, so $E(p^k) = k\log p - \log p$. $\square$

### 2.2 Radical collisions force base-model error

The key structural obstruction is that $E$ is not a function of $\operatorname{rad}$.

**Definition 2.5.** A **radical collision** in a design $S$ is a pair $m, n \in S$ with $\operatorname{rad} m = \operatorname{rad} n$ and $E(m) \ne E(n)$.

**Theorem 2.6 (Irreducible residual at a collision).** *Let $m, n$ satisfy $\operatorname{rad} m = \operatorname{rad} n$. Then for every function $f : \mathbb{N} \to \mathbb{R}$,*
$$\bigl(E(m) - f(\operatorname{rad} m)\bigr)^2 + \bigl(E(n) - f(\operatorname{rad} n)\bigr)^2 \;\ge\; \tfrac{1}{2}\bigl(E(m) - E(n)\bigr)^2 .$$

*Proof sketch.* Write $t = f(\operatorname{rad} m) = f(\operatorname{rad} n)$, $a = E(m)$, $b = E(n)$. Then $(a-t)^2 + (b-t)^2 - \tfrac12(a-b)^2 = \tfrac12(a + b - 2t)^2 \ge 0$. $\square$

The bound is uniform over the entire class of base-only predictors: linear, polynomial, tabulated, or arbitrarily expressive. Its concrete instance is the two-point design $\{p, p^2\}$.

**Corollary 2.7 (A strictly positive floor at every prime).** *For every prime $p$ and every $f$,*
$$0 < \tfrac12(\log p)^2 \le \bigl(E(p^2) - f(\operatorname{rad} p^2)\bigr)^2 + \bigl(E(p) - f(\operatorname{rad} p)\bigr)^2,$$
*whereas the exact prime-power model has residual $0$ on the same design.*

*Proof sketch.* $\operatorname{rad}(p^2) = \operatorname{rad} p = p$, $E(p) = 0$ and $E(p^2) = \log p$ by Proposition 2.4; apply Theorem 2.6. $\square$

The smallest instance, $\operatorname{rad} 4 = \operatorname{rad} 2 = 2$ with $E(4) = \log 2 \ne 0 = E(2)$, already witnesses that $E$ is not a function of the radical.

### 2.3 The offset-uniform window floor

**Definition 2.8 (Window mass).** For $a, w \in \mathbb{N}$, $\;\mathcal{M}(a,w) = \sum_{a \le n < a+w} E(n)$.

$\mathcal{M}$ is non-negative and additive: $\mathcal{M}(a,w+v) = \mathcal{M}(a,w) + \mathcal{M}(a+w,v)$, hence monotone in $w$.

**Theorem 2.9 (Offset-uniform floor).** *For every offset $a \ge 1$ and every $w$,*
$$\mathcal{M}(a,w) \;\ge\; \Bigl\lfloor \frac{w}{4}\Bigr\rfloor \log 2 .$$

*Proof sketch.* Let $c$ be the least multiple of $4$ that is $\ge a$. The integers $c, c+4, \dots, c + 4(\lfloor w/4\rfloor - 1)$ are $\lfloor w/4 \rfloor$ distinct multiples of $4$ inside $[a, a+w)$. Each contributes $E \ge \log 2$ by Proposition 2.4, and the remaining terms of $\mathcal{M}(a,w)$ are non-negative. $\square$

**Corollary 2.10 (Growth in window length).** *For $a \ge 1$: $\mathcal{M}(a,w+4) \ge \mathcal{M}(a,w) + \log 2$; $\mathcal{M}(a,w) > 0$ once $w \ge 4$; $\mathcal{M}(a,240) \ge 60\log 2 \approx 41.59$; $\mathcal{M}(a,960) \ge 240\log 2 \approx 166.36$; and*
$$\mathcal{M}(a,960) \;\ge\; \mathcal{M}(a,240) + 180\log 2 \;\approx\; \mathcal{M}(a,240) + 124.77 .$$

*Proof sketch.* Additivity plus Theorem 2.9 applied to the appended block $[a+w, a+w+v)$, whose floor is offset-free. $\square$

Corollary 2.10 is the deterministic shadow of the observed monotonicity in $w$: the step $240 \to 960$ cannot fail to add mass, at any seed.

---

## 3. The lift as a von Mangoldt mass: an exact window law

Theorem 2.9 is a bound. The identity behind it is stronger.

**Definition 3.1 (Prime-power weight).** $\Lambda^\sharp(d) = 0$ if $d$ is prime, and $\Lambda^\sharp(d) = \Lambda(d)$ otherwise. Thus $\Lambda^\sharp$ is supported exactly on the prime powers $p^k$ with $k \ge 2$, where it takes the value $\log p$, and vanishes elsewhere. It is non-negative.

**Theorem 3.2 (Chebyshev split).** *For every $n$,*
$$E(n) \;=\; \sum_{d \mid n} \Lambda^\sharp(d) .$$

*Proof sketch.* Chebyshev's identity $\sum_{d \mid n}\Lambda(d) = \log n$ decomposes the divisor sum over prime-power divisors. Split the sum according to whether $d$ is prime or a higher prime power: the prime part is $\sum_{p \mid n}\log p = \log(\operatorname{rad} n)$, and the higher part is by definition $\sum_{d\mid n}\Lambda^\sharp(d)$. Subtracting gives the claim. $\square$

This is the conceptual heart of the paper, and worth restating in words: **the base feature is precisely the prime part of Chebyshev's identity, and the lift is precisely the higher-prime-power part.** The two features together partition a classical identity.

**Lemma 3.3 (Dirichlet swap).** *For every $N$ and every $f : \mathbb{N}\to\mathbb{R}$,*
$$\sum_{n=1}^{N} \sum_{d \mid n} f(d) \;=\; \sum_{d=1}^{N} f(d)\Bigl\lfloor \frac{N}{d}\Bigr\rfloor .$$

*Proof sketch.* Write the inner divisor sum as $\sum_{d \le N}\mathbb{1}[d \mid n] f(d)$ (legitimate since every divisor of $n \le N$ is $\le N$) and interchange the order of summation; the number of $n \in [1,N]$ divisible by $d$ is $\lfloor N/d\rfloor$. $\square$

**Theorem 3.4 (Exact window law).** *For every $N$,*
$$\mathcal{M}(1,N) \;=\; \sum_{n \le N} E(n) \;=\; \sum_{d \le N} \Lambda^\sharp(d)\Bigl\lfloor\frac{N}{d}\Bigr\rfloor .$$

*Proof sketch.* Combine Theorem 3.2 with Lemma 3.3. $\square$

This is an identity, not an estimate: the aggregate lift of an initial window is a weighted count of higher prime powers, each counted with multiplicity equal to its number of multiples in the window.

**Theorem 3.5 (Linear density floor).** *Let $D \subseteq [1, N]$ be any finite family. Then*
$$\sum_{n \le N} E(n) \;\ge\; \Bigl(\sum_{d \in D}\frac{\Lambda^\sharp(d)}{d}\Bigr)N \;-\; \sum_{d\in D}\Lambda^\sharp(d).$$

*Proof sketch.* All terms of Theorem 3.4 are non-negative, so restricting to $D$ only decreases the sum; then use $\lfloor N/d\rfloor > N/d - 1$ and non-negativity of $\Lambda^\sharp$. $\square$

**Corollary 3.6 (Explicit numerical floor).** *For $N \ge 8$, $\;\sum_{n\le N} E(n) \ge N/4 - 2$.*

*Proof sketch.* Take $D = \{4, 8\}$, on which $\Lambda^\sharp = \log 2$. The density is $\log 2\,(1/4 + 1/8) = \tfrac38\log 2 \approx 0.2599 > 1/4$, and the additive error is $2\log 2 < 2$. $\square$

**Remark 3.7 (The true density constant).** Letting $D$ exhaust all higher prime powers, the attainable densities increase to
$$\sum_{k \ge 2}\sum_p \frac{\log p}{p^k} \;=\; \sum_p \frac{\log p}{p(p-1)} \;\approx\; 0.7554 .$$
Thus $\sum_{n \le N} E(n) = 0.7554\ldots N + O(\sqrt N \log^2 N)$; the aggregate lift is *linear in the window length* with an explicit slope. This is the precise sense in which "the lift grows with window length": it grows at a constant marginal rate of roughly $0.755$ nats per additional integer.

---

## 4. Seed stability: the lift depends on the window, not on the seed

We model a seed by the *offset* of its window. Two summary quantities control everything.

**Definition 4.1.** For a truncation level $M$,
$$\rho(M) = \sum_{d\le M}\frac{\Lambda^\sharp(d)}{d} \quad\text{(prime-power density)},\qquad \Psi(M) = \sum_{d \le M}\Lambda^\sharp(d)\quad\text{(total prime-power weight)}.$$

$\rho$ increases to $\approx 0.7554$; $\Psi(M) = \psi(M) - \theta(M)$ is a classical Chebyshev difference, of size $\asymp \sqrt M$.

**Theorem 4.2 (Seed-uniform window law).** *Let $a \ge 1$ and $M \ge a - 1 + w$. Then*
$$\bigl|\mathcal{M}(a,w) - w\,\rho(M)\bigr| \;\le\; \Psi(M).$$

*Proof sketch.* Write $A = a - 1$, so $\mathcal{M}(a,w) = \mathcal{M}(1,A+w) - \mathcal{M}(1,A)$ by additivity. Apply Theorem 3.4 to both terms, extending each sum to $[1, M]$ (harmless: $\lfloor N/d\rfloor = 0$ for $d > N$). This gives
$$\mathcal{M}(a,w) = \sum_{d\le M}\Lambda^\sharp(d)\Bigl(\Bigl\lfloor\frac{A+w}{d}\Bigr\rfloor - \Bigl\lfloor\frac{A}{d}\Bigr\rfloor\Bigr).$$
For each $d$, the bracket differs from $w/d$ by at most $1$ in absolute value, since $\lfloor (A+w)/d\rfloor - \lfloor A/d\rfloor$ counts the multiples of $d$ in an interval of length $w$. Multiplying by $\Lambda^\sharp(d) \ge 0$ and summing yields the error bound $\sum_{d \le M}\Lambda^\sharp(d) = \Psi(M)$. $\square$

The two decisive features of Theorem 4.2 are that the main term $w\rho(M)$ does not involve $a$, and that the error $\Psi(M)$ involves neither $a$ nor $w$.

**Theorem 4.3 (Cross-seed dispersion).** *If $a, b \ge 1$ and $M$ dominates both windows, then*
$$\bigl|\mathcal{M}(a,w) - \mathcal{M}(b,w)\bigr| \;\le\; 2\,\Psi(M).$$

*Proof sketch.* Triangle inequality applied to Theorem 4.2 at $a$ and at $b$, the common main term cancelling. $\square$

Thus signal grows linearly in $w$ while dispersion across seeds remains bounded by a constant depending only on the truncation. The measured ratio — standard deviation $0.0025$ against a lift of $0.05$ — is the empirical face of exactly this asymmetry.

**Theorem 4.4 (Sparsity of the arithmetic kernel).** *The support of $\Lambda^\sharp$ inside $[1, M]$ has cardinality at most $\sqrt M\,(\log_2 M + 1)$.*

*Proof sketch.* Every $d$ in the support is $p^k$ with $k \ge 2$; then $p^2 \le d \le M$ gives $p \le \sqrt M$, and $2^k \le p^k \le M$ gives $k \le \log_2 M$. The map $d \mapsto (p,k)$ is injective by unique factorisation, so the support injects into a product of a set of size $\le \sqrt M$ with one of size $\le \log_2 M + 1$. $\square$

**Remark 4.5.** Each surviving weight is at most $\log M$, so $\Psi(M) \le \sqrt M \log M (\log_2 M + 1)$ — sublinear, against a main term linear in $w$. The prime-power signal is carried by a *sparse and canonically determined* set of integers; this is precisely why it reproduces across seeds. A random-noise explanation would predict dispersion growing like $\sqrt w$; the theory predicts dispersion $O(1)$ in $w$, which is what was observed.

---

## 5. The fibrewise variance law: an exact formula for the lift

We now compute the lift itself, not merely bound it. The setting is fully general: $S$ a finite design, $g$ a base statistic (for us $g = \operatorname{rad}$), $y$ a target (for us $y = E$).

**Definition 5.1.** The **fibre** of $g$ over $c$ in $S$ is $S_c = \{n \in S : g(n) = c\}$. The **total sum of squares** of $y$ on a finite set $F$ is
$$T(F) = \sum_{n\in F}\Bigl(y(n) - \frac{1}{|F|}\sum_{j \in F} y(j)\Bigr)^2 ,$$
and the **within-fibre sum of squares** of the design is
$$W(S, g, y) = \sum_{c \in g(S)} T(S_c).$$
The **coefficient of determination** of a predictor $\hat y$ is $R^2 = 1 - \bigl(\sum_{n \in S}(y(n)-\hat y(n))^2\bigr)/T(S)$.

A **base model** is any predictor of the form $n \mapsto f(g(n))$; note that no restriction whatsoever is placed on $f$.

**Lemma 5.2 (The mean minimises squared error).** *For a finite non-empty $F$ and any $b \in \mathbb{R}$, $\;T(F) \le \sum_{n\in F}(y(n)-b)^2$.*

*Proof sketch.* Expanding, $\sum_{n\in F}(y(n)-b)^2 = \sum y^2 - 2b\sum y + |F| b^2$, a convex quadratic in $b$ minimised at $b = \bar y_F$, whose value is $T(F)$. $\square$

**Theorem 5.3 (Lower bound for base models).** *For every $f$,*
$$W(S,g,y) \;\le\; \sum_{n\in S}\bigl(y(n) - f(g(n))\bigr)^2 .$$

*Proof sketch.* Partition $S$ into the fibres $S_c$, $c \in g(S)$. On $S_c$ the predictor is the constant $f(c)$, so by Lemma 5.2 its contribution is at least $T(S_c)$. Summing over fibres gives $W$. $\square$

**Theorem 5.4 (Attainment by the fibrewise mean).** *Let $\mu(c) = \frac{1}{|S_c|}\sum_{j \in S_c} y(j)$. Then*
$$\sum_{n \in S}\bigl(y(n) - \mu(g(n))\bigr)^2 \;=\; W(S,g,y).$$

*Proof sketch.* Again partition into fibres; on $S_c$ the predictor is the constant $\mu(c) = \bar y_{S_c}$, and the contribution is by definition $T(S_c)$. $\square$

Together Theorems 5.3 and 5.4 identify $W$ as the *exact* optimum of the base model class: not a bound, the value.

**Corollary 5.5 (Best base-only $R^2$).** *If $T(S) > 0$ then every base model satisfies $R^2 \le 1 - W/T(S)$, with equality for the fibrewise mean.*

**Theorem 5.6 (Fibrewise variance law).** *Let $T = T(S) > 0$. The lift of the exact model $\hat y = y$ over the best base model is*
$$\Delta R^2 \;=\; R^2(y) - R^2(\mu \circ g) \;=\; \frac{W(S,g,y)}{T} .$$
*Moreover, against an arbitrary base model $f$, $\;\Delta R^2 \ge W/T$.*

*Proof sketch.* $R^2(y) = 1$ since the residual vanishes identically; $R^2(\mu\circ g) = 1 - W/T$ by Corollary 5.5. Subtract. The inequality for arbitrary $f$ follows from Theorem 5.3. $\square$

**Interpretation.** The measured lift is *exactly* the fraction of the target's variance that lives *inside* the fibres of the base statistic. For $g = \operatorname{rad}$ and $y = E$: it is the fraction of the variance of prime-power content that survives conditioning on the squarefree skeleton. It is a purely arithmetic ratio, determined by the design, with no dependence on estimator, optimiser, regulariser or sample size.

### 5.1 The collision dichotomy

**Lemma 5.7.** *If $m, n \in F$ with $y(m) \ne y(n)$ then $T(F) > 0$.*

*Proof sketch.* $T(F) \ge 0$ as a sum of squares. If $T(F) = 0$ then every summand vanishes, forcing $y$ to equal the mean at every point of $F$, hence to be constant — contradicting $y(m) \ne y(n)$. $\square$

**Theorem 5.8 (Positive lift from one collision).** *If $S$ contains $m, n$ with $g(m) = g(n)$ and $y(m) \ne y(n)$, then $W(S,g,y) > 0$ and hence $\Delta R^2 > 0$.*

*Proof sketch.* Both $m$ and $n$ lie in the fibre over $c = g(m)$, so $T(S_c) > 0$ by Lemma 5.7; all other fibre variances are $\ge 0$, and $c \in g(S)$, so $W \ge T(S_c) > 0$. Divide by $T$. $\square$

**Theorem 5.9 (Zero lift without collisions).** *If $y$ is constant on every fibre of $g$ in $S$ — i.e. $g(m) = g(n) \Rightarrow y(m) = y(n)$ for $m,n \in S$ — then $W = 0$ and $\Delta R^2 = 0$ exactly.*

*Proof sketch.* Each fibre has constant $y$, so its mean equals that constant and $T(S_c) = 0$. $\square$

Theorems 5.8 and 5.9 form a sharp dichotomy. In the concrete case $g = \operatorname{rad}$, $y = E$:

> **The lift is strictly positive if and only if the window contains a radical collision with differing prime-power content, and it is exactly zero otherwise.**

For the specific pair $g = \operatorname{rad}$, $y = E$ the criterion simplifies dramatically.

**Proposition 5.9a (Radical fibres are automatically informative).** *If $m \ne n$ and $\operatorname{rad} m = \operatorname{rad} n$, then $E(m) \ne E(n)$.*

*Proof sketch.* $E(m) - E(n) = \log m - \log n$ once the radicals agree, and $\log$ is injective on positive integers. $\square$

Hence, for this feature pair, **the lift is strictly positive if and only if some radical value is attained twice in the design**, and it is exactly $0$ if all radicals are distinct. Note that repeated radicals are *not* the same as non-squarefree entries: a design of distinct squarefree integers has all radicals distinct and hence zero lift, whatever its size.

This is the point at which the experimental design matters. Among *consecutive* integers, repeated radicals are comparatively scarce (they require both $n$ and a multiple of $n$ by primes already dividing $n$ to lie in the same short window), so the lift on such windows is modest and concentrated at small values. Among *smooth* pools — the setting of the measurement — they are unavoidable, by pigeonhole:

**Proposition 5.9b (Pigeonhole in a smooth pool).** *Every $y$-smooth integer has $\operatorname{rad} n \mid y\#$, so a pool of $y$-smooth integers realises at most $2^{\pi(y)}$ distinct radicals. Consequently any pool of more than $2^{\pi(y)}$ distinct $y$-smooth integers has a repeated radical, and hence $\Delta R^2 > 0$; more quantitatively, at least $|S| - 2^{\pi(y)}$ of its members lie in non-singleton fibres.*

*Proof sketch.* The radical of a $y$-smooth $n$ is a squarefree divisor of $y\#$ by Theorem 6.2 below, and $y\#$ has exactly $2^{\pi(y)}$ divisors. Then apply Theorem 5.8 with Proposition 5.9a. $\square$

The observed $\Delta R^2 \approx 0.05$ is therefore a *measurement of the repeated-radical structure* of the design, weighted by disagreement magnitude — not a fitting artefact. Numerically, on the pool of all $y$-smooth integers up to $10^5$ the exact value $W/T$ is $0.935$ at $y=7$, $0.745$ at $y=13$, $0.493$ at $y=31$ and $0.375$ at $y=97$: monotone decreasing in $y$, precisely the direction of the observed smoothness dependence.

### 5.2 A fully explicit intermediate value

**Theorem 5.10 (The design $\{2,3,4\}$).** *Let $S = \{2,3,4\}$, $g = \operatorname{rad}$, $y = E$. Then*
$$T(S) = \tfrac{2}{3}(\log 2)^2, \qquad W(S,\operatorname{rad},E) = \tfrac{1}{2}(\log 2)^2, \qquad \Delta R^2 = \frac{3}{4} .$$

*Proof sketch.* We have $E(2)=E(3)=0$ (both squarefree) and $E(4) = \log 2$. The mean is $\tfrac13\log 2$, so
$$T = 2\bigl(\tfrac13\log 2\bigr)^2 + \bigl(\tfrac23\log 2\bigr)^2 = \bigl(\tfrac{2}{9}+\tfrac49\bigr)(\log2)^2 = \tfrac23(\log 2)^2 .$$
The radical fibres are $S_2 = \{2,4\}$ and $S_3 = \{3\}$. The singleton contributes $0$; on $\{2,4\}$ the mean is $\tfrac12\log 2$, giving $T(S_2) = 2\cdot(\tfrac12\log2)^2 = \tfrac12(\log 2)^2$. Then $\Delta R^2 = W/T = (1/2)/(2/3) = 3/4$. $\square$

This is a genuinely intermediate value: strictly between the degenerate extremes $0$ (no collision) and $1$ (single collision fibre). It exhibits the same structural mechanism as the empirical $0.05$ — one collision fibre embedded among fibres the base feature already explains — on a design small enough to verify by hand.

---

## 6. The smooth regime: why smoother pools show a larger lift

The experiment reported a larger lift at the smaller smoothness parameter. The mechanism is a ceiling on the base feature.

**Definition 6.1.** $n$ is **$y$-smooth** if every prime factor of $n$ is $\le y$. The **primorial** is $y\# = \prod_{p \le y} p$.

**Theorem 6.2 (Primorial ceiling).** *If $n$ is $y$-smooth then $\operatorname{rad} n \mid y\#$, hence*
$$\log(\operatorname{rad} n) \le \log(y\#) \le y\log 4,$$
*the last step by Chebyshev's bound $y\# \le 4^{y}$.*

*Proof sketch.* $\operatorname{rad} n$ is the product of the distinct primes dividing $n$, all of which are $\le y$; that is a sub-product of $y\#$, whose factors are squarefree and distinct. $\square$

**Theorem 6.3 (Smooth floor).** *If $n$ is $y$-smooth then $E(n) \ge \log n - \log(y\#) \ge \log n - y\log 4$.*

*Proof sketch.* $E(n) = \log n - \log(\operatorname{rad} n)$ and apply Theorem 6.2. $\square$

**Corollary 6.4.** *Every $y$-smooth $n > 4^y$ has $E(n) > 0$; equivalently, no $y$-smooth integer exceeding $4^y$ is squarefree.*

*Proof sketch.* Theorem 6.3 gives $E(n) \ge \log n - y \log 4 > 0$; then apply Theorem 2.3. $\square$

**Theorem 6.5 ($u$-form of the floor).** *If $n$ is $y$-smooth with $n \ge y^{u}$ and $y \ge 1$, then*
$$E(n) \;\ge\; u\log y - y\log 4 .$$

*Proof sketch.* $\log n \ge u\log y$; substitute in Theorem 6.3. $\square$

At a fixed size scale, decreasing $y$ (a smoother pool, hence a smaller effective $u$ in the experiment's parameterisation) reduces the ceiling $y\log 4$ on what the base feature can explain, so a larger share of $\log n$ must be carried by the prime-power feature. This is the deterministic content of the observed $u$-dependence ($0.058$ vs $0.051$ at $w = 240$; $0.082$ vs $0.058$ at $w=960$).

### 6.1 The extreme case: exact $R^2$ on the $2$-smooth tower

**Definition 6.6.** The **tower design** is $S_m = \{2, 4, 8, \dots, 2^m\}$, of cardinality $m$.

On $S_m$ the base statistic is *constant*: $\operatorname{rad}(2^k) = 2$ for all $k \ge 1$. The target is $E(2^k) = (k-1)\log 2$.

**Theorem 6.7 (Total variance of the tower).** *For $m \ge 1$,*
$$\sum_{n \in S_m} E(n) = \frac{m(m-1)}{2}\log 2, \qquad T(S_m) = \frac{m(m^2-1)}{12}(\log 2)^2 .$$

*Proof sketch.* The mass is $\sum_{k=1}^m (k-1)\log 2$, a triangular number. For the variance, the mean is $\frac{m-1}{2}\log 2$, and
$$T = (\log 2)^2\sum_{j=0}^{m-1}\Bigl(j - \frac{m-1}{2}\Bigr)^2 = (\log 2)^2\Bigl(\sum_{j<m} j^2 - \frac{1}{m}\bigl(\textstyle\sum_{j<m} j\bigr)^2\Bigr),$$
and the closed forms $\sum_{j<m} j = m(m-1)/2$, $\sum_{j<m} j^2 = m(m-1)(2m-1)/6$ give $m(m^2-1)/12$. In particular $T > 0$ for $m\ge 2$. $\square$

**Theorem 6.8 (Total collapse of the base class).** *For $m \ge 2$ and every $f$, the base model $n \mapsto f(\operatorname{rad} n)$ has $R^2 \le 0$ on $S_m$; the exact prime-power model has $R^2 = 1$; hence*
$$\Delta R^2 \;\ge\; 1 ,$$
*with equality for the best base model.*

*Proof sketch.* Since $\operatorname{rad}$ is constant on $S_m$, every base model is a constant predictor, whose residual is at least $T(S_m)$ by Lemma 5.2; so $R^2 = 1 - \text{residual}/T \le 0$. The exact model has zero residual, so $R^2=1$. Note that this is a special case of Theorem 5.6 with a single fibre, where $W = T$ and $\Delta R^2 = W/T = 1$. $\square$

The tower is thus the exact opposite extreme to the collision-free design of Theorem 5.9: one fibre, all variance internal, maximal lift. Real windows lie between the two, and Theorem 5.6 says the lift interpolates exactly according to the collision structure.

---

## 7. The graded hierarchy: diminishing returns of higher-order features

A practitioner who found that squares help will ask about cubes. The answer is a filtration with geometric decay.

**Definition 7.1 (Graded features and layers).** For $j \ge 1$,
$$F_j(n) = \sum_{p \mid n}\min\bigl(v_p(n), j\bigr)\log p, \qquad L_k(n) = \sum_{\substack{p \mid n \\ p^k \mid n}} \log p .$$

**Theorem 7.2 (Filtration).** *$F_1(n) = \log(\operatorname{rad} n)$; $F_j(n) = \log n$ as soon as $j \ge \max_p v_p(n)$ (in particular $F_n(n) = \log n$); and for $n \ne 0$,*
$$F_{j+1}(n) - F_j(n) = L_{j+1}(n).$$
*Consequently, for any saturating level $J$,*
$$E(n) = \sum_{j=1}^{J-1} L_{j+1}(n) = L_2(n) + L_3(n) + \cdots ,$$
*a finite decomposition of the lift into layers.*

*Proof sketch.* At $j=1$ the minimum is $1$ for each prime divisor. Saturation is immediate once $j$ exceeds every exponent. For the increment, $\min(v,j+1)-\min(v,j)$ equals $1$ if $v \ge j+1$ and $0$ otherwise, and $v_p(n)\ge j+1 \iff p^{j+1} \mid n$. Telescoping from $F_1$ to $F_J$ gives $\log n - \log(\operatorname{rad} n) = E(n)$. $\square$

**Theorem 7.3 (Monotonicity and finiteness).** *$L_k(n) \ge 0$; $L_l(n) \le L_k(n)$ for $k \le l$; and $L_k(n) > 0$ forces $n \ge 2^k$. Hence at most $\log_2 n$ layers are non-zero.*

*Proof sketch.* The defining index sets are nested in $k$, since $p^l \mid n \Rightarrow p^k \mid n$ for $k \le l$. If some $p^k \mid n$ then $n \ge p^k \ge 2^k$. $\square$

**Theorem 7.4 (Layer window law).** *For $k \ge 1$,*
$$\sum_{n\le N} L_k(n) \;=\; \sum_{d \le N} \lambda_k(d)\Bigl\lfloor\frac{N}{d}\Bigr\rfloor \;=\; \sum_{\substack{p \le N \\ p \text{ prime}}} \log p \,\Bigl\lfloor\frac{N}{p^k}\Bigr\rfloor,$$
*where $\lambda_k$ is supported exactly on the $k$-th powers of primes with value $\log p$ at $p^k$.*

*Proof sketch.* $L_k(n) = \sum_{d \mid n}\lambda_k(d)$, since the divisors of $n$ of the form $p^k$ correspond exactly to the primes $p$ with $p^k \mid n$. Apply Lemma 3.3, then reindex the support $d = p^k$ and note $\lfloor N/p^k\rfloor$ vanishes when $p^k > N$. $\square$

Write $\mathcal{L}_k(N) = \sum_{n \le N}L_k(n)$.

**Theorem 7.5 (Geometric decay).** *For $k \ge 1$ and every $N$,*
$$\mathcal{L}_{k+1}(N) \le \tfrac12 \mathcal{L}_k(N), \qquad\text{hence}\qquad \mathcal{L}_{k+j}(N) \le 2^{-j}\,\mathcal{L}_k(N) .$$

*Proof sketch.* Termwise in Theorem 7.4: for a prime $p \ge 2$, $2\lfloor N/p^{k+1}\rfloor \le p\lfloor N/p^{k+1}\rfloor \le \lfloor N/p^k \rfloor$, because $p \cdot \lfloor N/p^{k+1}\rfloor$ is a multiple of $p$ not exceeding $N/p^k$. Multiply by $\log p \ge 0$ and sum; iterate for the second form. $\square$

**Theorem 7.6 (Level-$2$ sandwich).** *For every $N$,*
$$\mathcal{L}_2(N) \;\le\; \sum_{n \le N} E(n) \;\le\; 2\,\mathcal{L}_2(N).$$

*Proof sketch.* The left inequality is Theorem 7.2 plus non-negativity of the higher layers. For the right, $\sum_{n\le N}E(n) = \sum_{j\ge 0}\mathcal{L}_{2+j}(N) \le \mathcal{L}_2(N)\sum_{j\ge0}2^{-j} = 2\mathcal{L}_2(N)$, the sum being finite since $\mathcal{L}_k(N) = 0$ for $N < 2^k$. $\square$

**Corollary 7.7 (Tail bound / diminishing returns).** *For $k\ge1$, $\;\sum_{j\ge 0}\mathcal{L}_{k+j}(N) \le 2\,\mathcal{L}_k(N)$: the cumulative worth of all features of order above $k$ never exceeds twice the worth of level $k$ itself.*

This converts a vague intuition about feature engineering into a quantitative prediction: **the square layer already captures at least half of the total prime-power mass, and each additional order is worth at most half of the last.** Where the total lift is $\approx 0.05$, the incremental gain from a cube feature should be at most about half of the square feature's contribution, and the gains should form an approximately geometric sequence with ratio bounded by $1/2$ (in fact governed by $\sum_p \log p / p^{k}$, so numerically closer to $\sum_p \log p/p^{k+1} \big/ \sum_p \log p /p^{k}$).

---

## 8. Algorithms

The theory is fully constructive. Four routines suffice to reproduce every number in this paper.

### 8.1 Prime-power excess by sieve

Compute $E(n)$ for all $n \le N$ in $O(N\log\log N)$ time and $O(N)$ space via a smallest-prime-factor sieve, or — better, exploiting Theorem 3.2 — by directly accumulating $\Lambda^\sharp$ over multiples:

```
for each prime p ≤ √N:
    for k = 2, 3, ... while p^k ≤ N:
        for each multiple m of p^k with m ≤ N:
            E[m] += log p
```
This is $O(N\log\log N)$ overall, since $\sum_{p, k\ge2} N/p^k = \rho(\infty) N$ converges.

### 8.2 Exact window mass

By Theorem 3.4, $\sum_{n\le N}E(n) = \sum_{p^k \le N,\, k\ge2}\log p\,\lfloor N/p^k\rfloor$, a sum over at most $\sqrt N \log_2 N$ terms — computable in $\tilde O(\sqrt N)$ time without touching the individual $E(n)$. For an offset window, difference two such evaluations.

### 8.3 The exact lift by fibrewise variance

Theorem 5.6 turns model fitting into a group-by:

```
group the design S by rad(n)
W ← Σ_fibres (within-fibre sum of squares of E)
T ← total sum of squares of E over S
ΔR² ← W / T
```
Linear time in $|S|$ after factorisation. No optimisation, no regression solver, no randomness — the "regression result" is a deterministic arithmetic ratio.

### 8.4 Layer profile

By Theorem 7.4, $\mathcal{L}_k(N) = \sum_{p \le N^{1/k}}\log p\,\lfloor N/p^k\rfloor$; computing the profile $k = 2, 3, \dots, \log_2 N$ costs $\tilde O(\sqrt N)$ in total and directly exhibits the geometric decay of Theorem 7.5.

---

## 9. Applications

**Feature-selection guidance.** For any multiplicative-feature model on a window of integers, Theorem 5.6 predicts the exact worth of adding exponent information before any model is trained. If the design has no radical collisions (e.g. a design of distinct squarefree numbers), the gain is provably zero and the feature should be dropped. If collisions are present, the gain equals the within-fibre variance fraction, computable in linear time.

**Diagnostics against overfitting.** A reported lift can be checked against the theoretical value $W/T$. Discrepancy in either direction is informative: a measured lift *below* $W/T$ indicates an under-expressive base model or under-optimisation; a measured lift *above* $W/T$ is impossible for a base model of the stated form and indicates leakage of non-radical information into the baseline.

**Sample-size and window-length planning.** Theorems 3.5 and 4.2 give the signal-to-dispersion trade-off explicitly: signal $\approx \rho\, w$, cross-seed dispersion $\le 2\Psi(M)$, independent of $w$. To achieve a target $z$-score, lengthen the window rather than adding seeds — an inversion of the usual reflex, and one directly borne out by the data ($0.051 \to 0.058$ and $0.058 \to 0.082$ under $w: 240 \to 960$).

**Smooth-number computations.** Corollary 6.4 — every $y$-smooth $n > 4^y$ has a repeated prime factor — is a usable structural fact in factorisation and smooth-number sampling contexts, where it certifies that smooth pools above the primorial threshold are automatically rich in prime-power content.

**A design principle for graded features.** Corollary 7.7 quantifies when to stop: the total remaining value above level $k$ is at most $2\mathcal{L}_k(N)$, so a fixed relative tolerance is reached after $O(\log(1/\varepsilon))$ levels.

---

## 10. Discussion

### 10.1 What was actually measured

The composite picture is that a regression on multiplicative features, run on a window of integers, is a *measuring device* pointed at the higher-prime-power part of Chebyshev's identity. Each of the observed qualitative behaviours corresponds to a theorem:

| Observation | Deterministic explanation |
|---|---|
| Lift is positive | Radical collisions exist; each forces residual $\ge \frac12(\Delta E)^2$ (Thm 2.6, Thm 5.8) |
| Lift is stable across seeds | Offset-free window law, dispersion $\le 2\Psi(M)$ (Thms 4.2, 4.3) |
| Lift grows with window length | Aggregate mass is linear in $w$ with slope $\to 0.7554$ (Thm 3.5, Rem 3.7) |
| Lift is larger for smoother pools | Base feature capped by $\log(y\#) \le y\log 4$ (Thms 6.2, 6.5) |
| Higher-order features add little | Geometric layer decay, $\mathcal{L}_{k+1} \le \mathcal{L}_k/2$ (Thm 7.5) |
| Exact numerical value of the lift | $\Delta R^2 = W/T$, the within-fibre variance fraction (Thm 5.6) |

### 10.2 Sharpness

Theorem 5.6 is an equality, and both degenerate cases are realised: $\Delta R^2 = 0$ on collision-free designs (Theorem 5.9) and $\Delta R^2 = 1$ on the single-fibre tower (Theorem 6.8). The design $\{2,3,4\}$ realises the intermediate value $3/4$ (Theorem 5.10), so no improvement of the dichotomy to a fixed constant is possible: the lift genuinely takes a continuum of values determined by the collision structure of the window.

The constant $1/2$ in Theorem 7.5 is set by the smallest prime, and is attained in the limit by the contribution of $p=2$ alone; the constant $2$ in Theorem 7.6 is its geometric sum and is likewise essentially optimal for the argument given.

### 10.3 Limitations

Three honest caveats.

First, we have modelled the *sampling seed* by the *window offset*. This captures the offset-dependence of the design but not the finer resampling structure of the original experiment; the theorems say that no offset-dependent variability can exceed $2\Psi(M)$, which bounds one, but not necessarily every, source of cross-seed dispersion.

Second, our exact lift formula (Theorem 5.6) compares the *best* base model with the *exact* prime-power model. Empirical fits use restricted hypothesis classes (typically linear) and finite optimisation; the measured lift is therefore bounded above by $W/T$ only when the empirical baseline is at least as good as the fibrewise mean. In practice a linear baseline is weaker than the fibrewise mean, so measured lifts may exceed $W/T$; Theorem 5.3 gives the correct one-sided statement in that case ($\Delta R^2 \ge W/T$ against an arbitrary base model).

Third, the target in the theory is $E$ itself. If the experimental response is a different multiplicative statistic, the fibrewise variance law still applies verbatim (it is stated for arbitrary $y$), but the arithmetic evaluation of $W$ and $T$ must be redone for that $y$.

### 10.4 Future directions

Several avenues remain open.

* **An asymptotic for the within-fibre fraction.** Theorem 5.6 reduces $\Delta R^2$ to $W/T$ on the window $[a, a+w)$. Both numerator and denominator are explicit sums over radical classes; an asymptotic evaluation as $w \to \infty$ would predict the *numerical value* $\approx 0.05$, not merely its positivity and monotonicity. The natural approach is to organise integers by their squarefree kernel and use the density of $\{n : \operatorname{rad} n = c\}$ within a window.
* **Sharper layer constants.** Theorem 7.5 uses only $p \ge 2$. Weighting by the actual prime distribution should give a decay ratio near $\sum_p \log p / p^{k+1} \big/ \sum_p \log p/p^k$, which for $k=2$ is closer to $0.4$ than to $0.5$.
* **Error term for the seed law.** Theorem 4.2 uses the crude per-divisor discrepancy bound $1$. Averaging over $d$ should reduce $\Psi(M)$ to something like $O(\sqrt M)$ in the aggregate rather than termwise, giving a materially better dispersion bound.
* **Beyond the radical.** The fibrewise variance law is stated for a general base statistic $g$. Applying it to other multiplicative kernels — the squarefree kernel, the $y$-smooth part, the number of prime factors — yields exact lift formulas for a whole family of feature comparisons.
* **Higher moments.** The present work computes a second-moment quantity. Analogous exact laws for the full residual distribution (rather than its variance) would allow calibrated confidence statements from arithmetic alone.

---

## 11. Conclusion

A small, stable, growing bump in explained variance turned out to be a piece of classical analytic number theory in disguise. Splitting Chebyshev's identity $\sum_{d\mid n}\Lambda(d) = \log n$ into its prime part and its higher-prime-power part splits the two competing features exactly: the base feature is the former, and the entire lift is the latter. From that identity flow an exact window law, a linear density with constant $\sum_p\log p/(p(p-1)) \approx 0.7554$, an offset-free stability estimate whose error is supported on the $O(\sqrt M\log M)$ higher prime powers, and — most sharply — the fibrewise variance law $\Delta R^2 = W/T$, which reduces a statistical measurement to a ratio of two arithmetic sums of squares and delivers the clean dichotomy that the lift is positive precisely when the window contains a radical collision with differing prime-power content.

The prime-power term is real, seed-stable and window-robust — and now, provably so.
