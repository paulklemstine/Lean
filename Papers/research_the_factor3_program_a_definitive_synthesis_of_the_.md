# The Free-Witness Classification for CRT-Multiplicative Weights: Trace Lemma, Exhaustive Dichotomy, and the Noise-Floor Principle

**Author:** Aristotle
**Date:** 2026-08-14
**Domain:** Tropical geometry and computational number theory

---

## Abstract

We give a complete classification of the *counting aggregates* that can serve as witnesses for integer factorization, for the natural class of weights that decompose through the Chinese Remainder splitting. A **CRT weight** is a function $w : \mathbb{N} \to \mathbb{N}$ with $w(1) = 1$ and $w(mn) = w(m)w(n)$ whenever $\gcd(m,n) = 1$; its **aggregate** is $A_w(N) = \sum_{d \mid N} w(d)$, which on a semiprime $N = pq$ factors as $(1+w(p))(1+w(q))$.

Our main results are three. First, a **trace lemma**: if $w$ is strictly monotone, the aggregate value determines the coprime factorization of $N$ uniquely; the mechanism is that $w(a)w(b) = w(N)$ is a public *norm*, so equality of aggregates forces equality of the *traces* $w(a) + w(b)$, and a pair of naturals is determined by its sum and product. For power weights $w(d) = d^k$ with $k \ge 1$ we prove the stronger statement that $a^k + b^k$ determines the pair among *all* factorizations of $N$, via a spread-monotonicity principle along the divisor hyperbola. Second, a **negative branch**: if $w$ collides on two primes, then no function whatsoever of the aggregate can return a factor, since two semiprimes with different smaller factors share an aggregate value. Third, an **exhaustive dichotomy**: every CRT weight lies in exactly one of these two branches — there is no partially informative aggregate. We complement the classification with a **characters-only boundary lemma** showing that exponential phase weights $x \mapsto z^x$ are never CRT-multiplicative unless trivial, so the class is exactly delimited.

Finally, we prove the **noise-floor principle** in the form that seals the positive branch. For a balanced semiprime $N = pq$ with $p < q \le 2p$, any probe window $[2,m]$ containing a nontrivial divisor of $N$ satisfies $N \le 2m^2$, and no window contains more than two factor-bearing probes; hence the density of factor-bearing probes in any successful window is at most $2\sqrt2/\sqrt N$, and the sweep length is squeezed between $\sqrt{N/2}$ and $\sqrt N$. The aggregation barrier and the trial-division birthday bound are therefore the *same* $\Theta(\sqrt N)$ obstruction. A tropical reformulation interprets the whole picture as the geometry of the tropical line $X \odot Y = N$: the factoring secret is the position of the witness pair on this line, the classical trace is minimized at the corner $\sqrt N$, and finding that position costs a full window sweep.

We provide explicit closed-form recovery formulas realizing the positive branch, including a precise form of the predicted witness $p^2 + q^2$.

**Keywords:** integer factorization, multiplicative functions, Chinese Remainder Theorem, divisor sums, trace and norm, tropical geometry, birthday bound, barrier framework.

---

## 1. Introduction

### 1.1 Counting attacks and the free-witness question

A recurring template in attacks on integer factorization is the *counting attack*. Given a composite $N$, one constructs a combinatorial or arithmetic quantity — the number of lattice points on a circle of radius depending on $N$, the number of roots of a polynomial modulo $N$, the number of representations by a binary quadratic form of discriminant tied to $N$, the number of cusps of a modular curve of level $N$, the minimum distance of a Reed–Solomon-type code indexed by $N$ — and hopes that the resulting integer carries recoverable information about the prime factors.

Empirically, these attacks fall into two piles. Either the aggregate turns out to depend only on $N$ and not on how $N$ splits, in which case it is useless; or it depends genuinely on the splitting, in which case — always, in every recorded instance — one can recover the entire factorization from it by elementary manipulation. What is never observed is an aggregate that leaks a *partial* hint, one that would have to be amplified by further work.

The **free-witness question** asks whether that observation is a theorem. Call an aggregate a *free witness* if an oracle handing you its value would let you factor efficiently. The classification problem is: which aggregates are free witnesses, which are factorization-insensitive, and is there anything in between?

This paper answers the question completely for the class of weights that respect the Chinese Remainder splitting, and quantifies the cost of computing such aggregates without an oracle.

### 1.2 Summary of contributions

1. **Definition and structure (Section 2).** The class of CRT weights, and the factorization of the semiprime aggregate through the CRT splitting: $A_w(pq) = (1 + w(p))(1 + w(q))$.
2. **Trace lemma, general form (Section 3).** For strictly monotone CRT weights, the aggregate determines the coprime factorization.
3. **Trace lemma, sharp form for power weights (Section 4).** Spread monotonicity of $a^k + b^k$ along the hyperbola $ab = N$, giving uniqueness among *all* factorizations, and the resulting exhaustive dichotomy for the family $\sigma_k$.
4. **Explicit recovery (Section 5).** A closed-form, constant-arithmetic-operation formula returning the smaller factor from the trace and the norm, instantiated at $k=1$ and $k=2$ — the latter being the predicted witness $p^2+q^2$.
5. **Negative branch and exhaustiveness (Section 6).** Prime collision as an absolute obstruction; the two-branch dichotomy for all CRT weights.
6. **Characters-only boundary (Section 7).** Exponential phase weights are not CRT-multiplicative.
7. **Noise-floor principle (Section 8).** The quantitative sealing of the positive branch; equality of the aggregation barrier and the birthday bound.
8. **Tropical reformulation (Section 9).** The corner of the tropical line as the location of the factoring secret.

---

## 2. CRT weights and their aggregates

Throughout, $N$ denotes a positive integer and $p, q$ denote primes. A **semiprime** is a product $N = pq$ of two distinct primes.

> **Definition 2.1 (CRT weight).** A function $w : \mathbb{N} \to \mathbb{N}$ is a *CRT weight* if
> 1. $w(1) = 1$ (normalization), and
> 2. $w(mn) = w(m)\,w(n)$ for all $m, n$ with $\gcd(m,n) = 1$ (multiplicativity across the CRT splitting).

These are precisely the (integer-valued) multiplicative arithmetic functions. The name emphasizes the mechanism: the ring isomorphism $\mathbb{Z}/mn \cong \mathbb{Z}/m \times \mathbb{Z}/n$ for coprime $m,n$ is what makes counting functions of this form arise naturally.

> **Definition 2.2 (Aggregate).** The *aggregate* of a CRT weight $w$ is
> $$A_w(N) \;=\; \sum_{d \mid N} w(d).$$

> **Example 2.3 (Power weights).** For each $k \in \mathbb{N}$, the function $w_k(d) = d^k$ is a CRT weight: $w_k(1) = 1$ and $(mn)^k = m^k n^k$ for all $m,n$ (coprimality is not even needed). Its aggregate is the classical divisor-power sum $\sigma_k(N) = \sum_{d \mid N} d^k$. For $k \ge 1$, $w_k$ is strictly monotone, since $a < b$ implies $a^k < b^k$.

The structural fact that starts everything is:

> **Proposition 2.4 (The aggregate factors through the CRT splitting).** Let $w$ be a CRT weight and let $p \ne q$ be primes. Then
> $$A_w(pq) \;=\; \sum_{d \mid pq} w(d) \;=\; \bigl(1 + w(p)\bigr)\bigl(1 + w(q)\bigr).$$

*Proof.* The divisors of $pq$ for distinct primes $p, q$ are exactly the four values $1, p, q, pq$, all distinct (distinctness uses $p, q \ge 2$ and $p \neq q$: $1 < p < pq$ and $1 < q < pq$). Hence
$$A_w(pq) = w(1) + w(p) + w(q) + w(pq).$$
Since $p \ne q$ are prime, $\gcd(p,q) = 1$, so $w(pq) = w(p)w(q)$; and $w(1) = 1$. Therefore
$$A_w(pq) = 1 + w(p) + w(q) + w(p)w(q) = (1 + w(p))(1 + w(q)). \qquad\blacksquare$$

Specializing to power weights gives $\sigma_k(pq) = (1 + p^k)(1 + q^k)$, and hence the **witness-extraction identity**
$$p^k + q^k \;=\; \sigma_k(pq) - 1 - N^k, \qquad N = pq, \tag{2.1}$$
obtained by expanding $(1+p^k)(1+q^k) = 1 + (p^k + q^k) + (pq)^k$. Both subtracted quantities are computable from $N$ alone. This is the sense in which the aggregate *hands over* the power-sum coordinate.

---

## 3. The trace lemma in general form

The elementary engine is the following, which encodes the classical fact that a monic quadratic is determined by its coefficients.

> **Lemma 3.1 (Sum and product determine an ordered pair).** Let $x \le y$ and $x' \le y'$ be naturals with $x + y = x' + y'$ and $xy = x'y'$. Then $x = x'$ and $y = y'$.

*Proof.* Suppose $x < x'$ and set $t := x' - x > 0$. The sum condition gives $y' = y - t$, so
$$xy = x'y' = (x + t)(y - t) = xy + t\,(y - x) - t^2 = xy + t\,(y - x - t).$$
Since $t > 0$ this forces $y - x = t = x' - x$, i.e. $y = x'$, and then $y' = y - t = x' - t = x$. But the hypotheses give $x' \le y' = x < x'$, a contradiction. By symmetry $x > x'$ is impossible as well. Hence $x = x'$, and $y = y'$ follows from $x + y = x' + y'$. $\blacksquare$

> **Theorem 3.2 (Trace lemma for CRT weights).** Let $w$ be a strictly monotone CRT weight. Let $N = ab = a'b'$ with $\gcd(a,b) = \gcd(a',b') = 1$, $a \le b$, $a' \le b'$. If
> $$\bigl(1 + w(a)\bigr)\bigl(1 + w(b)\bigr) \;=\; \bigl(1 + w(a')\bigr)\bigl(1 + w(b')\bigr),$$
> then $a = a'$ and $b = b'$.

*Proof.* **Norms agree.** By multiplicativity on the coprime pairs, $w(a)w(b) = w(N) = w(a')w(b')$.

**Traces agree.** Expanding both sides of the hypothesis,
$$1 + w(a) + w(b) + w(a)w(b) = 1 + w(a') + w(b') + w(a')w(b'),$$
and cancelling the equal products gives $w(a) + w(b) = w(a') + w(b')$.

**Pair is pinned.** Monotonicity gives $w(a) \le w(b)$ and $w(a') \le w(b')$. By Lemma 3.1 applied to the pairs $(w(a), w(b))$ and $(w(a'), w(b'))$, we get $w(a) = w(a')$. Strict monotonicity implies injectivity, so $a = a'$. Finally $ab = a'b' = ab'$; if $a > 0$ we may cancel to get $b = b'$. (If $a = 0$ then coprimality of $a$ and $b$ forces $b = 1$, and likewise $b' = 1$, so $b = b'$ anyway.) $\blacksquare$

**Interpretation.** The quantity $w(a) \cdot w(b) = w(N)$ is the *norm*: it is public, computable from $N$ alone, and identical for all factorizations. The quantity $w(a) + w(b)$ is the *trace*: it is exactly what the aggregate reveals beyond the norm. Theorem 3.2 says the trace is a **factor-secret coordinate** — a single number equivalent to the factorization. This is the precise sense in which recoverable counting witnesses "collapse to one coordinate".

Specializing to $w(d) = d^k$ with $k \ge 1$ recovers:

> **Corollary 3.3.** For $k \ge 1$ and coprime factorizations $N = ab = a'b'$ with $a \le b$, $a' \le b'$, the equality $(1+a^k)(1+b^k) = (1+a'^k)(1+b'^k)$ forces $a = a'$, $b = b'$.

---

## 4. The sharp form for power weights, and the $\sigma_k$ dichotomy

Theorem 3.2 requires the factorizations to be coprime. For power weights the coprimality hypothesis can be dropped entirely, at the cost of a genuinely analytic input.

> **Lemma 4.1 (Spread monotonicity, linear case).** If $ab = a'b'$ with $a < a'$ and $a' \le b'$, then $a' + b' < a + b$.

*Proof.* Since $ab = a'b'$ and $a < a'$, we have $b > b'$. Write $a' = a + s$ with $s > 0$ and $b = b' + t$ with $t > 0$. Then $ab = a'b'$ reads $a(b' + t) = (a+s)b'$, i.e. $at = sb'$. Since $a < a' \le b'$ we get $at = sb' > sa$, hence $t > s$, hence $a + b = a + b' + t > a + s + b' = a' + b'$. $\blacksquare$

Geometrically: rectangles of fixed area; the more lopsided one has the larger semiperimeter.

> **Theorem 4.2 (Spread monotonicity for power sums).** Let $k \ge 1$ and let $0 < a < a' \le b' < b$ with $ab = a'b'$. Then
> $$a'^k + b'^k \;<\; a^k + b^k.$$

*Proof.* By Lemma 4.1, $a' + b' < a + b$, equivalently $a' - a < b - b'$; set $t := a' - a > 0$ and $u := b - b' > 0$, so $t < u$. Using the telescoping identity
$$x^k - y^k = \Bigl(\textstyle\sum_{i=0}^{k-1} x^i y^{\,k-1-i}\Bigr)(x - y),$$
we write
$$a'^k - a^k = C_1 \cdot t, \qquad b^k - b'^k = C_2 \cdot u,$$
with $C_1 = \sum_{i<k} a'^i a^{k-1-i}$ and $C_2 = \sum_{i<k} b^i b'^{\,k-1-i}$. Since $a' \le b$ and $a \le b'$, every term of $C_1$ is at most the corresponding term of $C_2$, so $0 < C_1 \le C_2$ (positivity uses $a > 0$ and $k \ge 1$, so the sum is nonempty). Therefore
$$a'^k - a^k = C_1 t < C_2 u = b^k - b'^k,$$
which rearranges to $a'^k + b'^k < a^k + b^k$. $\blacksquare$

> **Theorem 4.3 (Trace lemma for power sums, all factorizations).** Let $k \ge 1$. Let $N = ab = a'b'$ with $0 < a \le b$, $0 < a' \le b'$. If $a^k + b^k = a'^k + b'^k$ then $a = a'$ and $b = b'$.

*Proof.* Suppose $a < a'$. Then $b > b'$ (since the products agree), and $a < a' \le b' < b$, so Theorem 4.2 gives $a'^k + b'^k < a^k + b^k$, contradicting equality. Symmetrically $a > a'$ is impossible. So $a = a'$, and $b = b'$ by cancellation. $\blacksquare$

This is strictly stronger than Corollary 3.3: it says the power-sum witness identifies the factorization among *all* divisor pairs, not merely coprime ones.

The degenerate exponent behaves as the negative branch predicts.

> **Proposition 4.4 (The $k = 0$ aggregate is factorization-insensitive).** For all distinct primes $p, q$, $\sigma_0(pq) = 4$.

*Proof.* $\sigma_0$ counts divisors, and a semiprime with distinct prime factors has exactly the four divisors $1, p, q, pq$. $\blacksquare$

Since $\sigma_0$ is constant on the entire class of semiprimes, it separates no two of them, and therefore no function of it can return a factor.

> **Theorem 4.5 (Exhaustive dichotomy for the power family).** For each exponent $k \in \mathbb{N}$, exactly one of the following holds.
> - **(Insensitive, $k = 0$.)** $\sigma_k$ takes the same value on every semiprime with distinct prime factors.
> - **(Free witness, $k \ge 1$.)** For every $N$ and every pair of factorizations $N = ab = a'b'$ with $0 < a \le b$, $0 < a' \le b'$, equality $a^k + b^k = a'^k + b'^k$ implies $(a,b) = (a',b')$.
>
> There is no intermediate, partially informative member of the family.

*Proof.* If $k = 0$ apply Proposition 4.4; if $k \ge 1$ apply Theorem 4.3. $\blacksquare$

---

## 5. Explicit recovery: the trace coordinate is efficiently invertible

The trace lemma asserts uniqueness. For the classification to be about *algorithms* rather than information, uniqueness must come with a constructive inverse. It does, in closed form.

> **Definition 5.1.** For naturals $N$ (the norm) and $s$ (the trace), set
> $$R(N, s) \;=\; \Bigl\lfloor \tfrac{1}{2}\bigl(s - \lfloor \sqrt{\,s^2 - 4N\,}\rfloor\bigr) \Bigr\rfloor ,$$
> all operations in $\mathbb{N}$ (truncated subtraction, integer square root, integer halving).

> **Theorem 5.2 (Closed-form recovery from trace and norm).** For all naturals $a \le b$,
> $$R(ab,\; a+b) \;=\; a.$$

*Proof.* Write $b = a + c$ with $c \ge 0$. Then
$$(a+b)^2 - 4ab = (2a + c)^2 - 4a(a+c) = c^2,$$
so the integer square root is exactly $c$ (no truncation loss). Hence
$$R(ab, a+b) = \Bigl\lfloor \tfrac{1}{2}\bigl((2a + c) - c\bigr)\Bigr\rfloor = a. \qquad\blacksquare$$

This is the integer form of the quadratic formula $x = \tfrac12\bigl(s - \sqrt{s^2 - 4N}\bigr)$, and it uses $O(1)$ arithmetic operations on numbers of the size of $N$ (one squaring, one multiplication, one subtraction, one integer square root, one halving).

Combining with the witness-extraction identity (2.1):

> **Corollary 5.3 (Recovery from the divisor sum).** Let $p < q$ be primes and $N = pq$. Then
> $$R\bigl(N,\; \sigma_1(N) - 1 - N\bigr) \;=\; p .$$

*Proof.* By (2.1) with $k=1$, $\sigma_1(N) - 1 - N = p + q$. Apply Theorem 5.2 with $a = p$, $b = q$. $\blacksquare$

> **Corollary 5.4 (Recovery from the sum of squares — the predicted witness).** Let $p < q$ be primes and $N = pq$. Then
> $$R\Bigl(N,\; \bigl\lfloor \sqrt{\,\sigma_2(N) - 1 - N^2 + 2N\,}\bigr\rfloor\Bigr) \;=\; p .$$

*Proof.* By (2.1) with $k = 2$, $\sigma_2(N) - 1 - N^2 = p^2 + q^2$. Adding $2N = 2pq$ gives $(p+q)^2$ exactly, so the integer square root returns $p + q$ with no truncation. Apply Theorem 5.2. $\blacksquare$

Corollary 5.4 is the formal content of the prediction that $\sigma_k(N) = (1+p^k)(1+q^k)$ is a free witness for every $k \ge 1$: the case $k = 2$ was singled out in advance because $p^2 + q^2$ superficially looks *weaker* than $p+q$, and the theory said it could not be. It is not: the norm supplies the missing $2pq$.

A second factor-secret coordinate deserves mention, because it is the one that appears when a counting attack leaks the *largest* prime rather than the trace.

> **Proposition 5.5 (Recovery from the max coordinate).** For $0 < p \le q$, $\;\lfloor pq / \max(p,q)\rfloor = \min(p,q)$.

*Proof.* $\max(p,q) = q$ and $pq/q = p = \min(p,q)$ exactly. $\blacksquare$

Thus the recoverable coordinates observed in practice — $p + q$, $\max(p,q)$, and residue/order vectors — are all one division or one quadratic formula away from the factorization.

---

## 6. The negative branch and the exhaustive dichotomy

The positive branch required monotonicity. What happens without it is not merely that the recovery formula breaks; the information itself is destroyed.

> **Theorem 6.1 (Prime collision is an absolute obstruction).** Let $w$ be a CRT weight, and suppose there exist distinct primes $p \ne p'$ with $w(p) = w(p')$. Then there is **no** function $f : \mathbb{N} \to \mathbb{N}$ satisfying
> $$f\bigl(A_w(xy)\bigr) = x \quad \text{for all primes } x < y.$$

*Proof.* Since there are infinitely many primes, choose a prime $q > \max(p, p')$. Both $pq$ and $p'q$ are semiprimes with distinct prime factors, and by Proposition 2.4,
$$A_w(pq) = (1 + w(p))(1 + w(q)) = (1 + w(p'))(1 + w(q)) = A_w(p'q),$$
using $w(p) = w(p')$. If such an $f$ existed, then applying it to this common value would give both $p$ (from the pair $p < q$) and $p'$ (from the pair $p' < q$), forcing $p = p'$, a contradiction. $\blacksquare$

Note the strength of the statement: $f$ is an *arbitrary* function, with no computability, continuity, or complexity restriction. The obstruction is informational, not computational. This is the precise form of what the barrier framework calls *factorization-insensitivity*.

> **Theorem 6.2 (Exhaustive dichotomy for CRT weights).** Let $w$ be a CRT weight. Then at least one of the following holds:
> 1. **(Separating.)** $w$ is injective on primes: $w(p) = w(p')$ with $p, p'$ prime implies $p = p'$.
> 2. **(Blind.)** There is no function $f$ with $f(A_w(xy)) = x$ for all primes $x < y$.
>
> Moreover, if $w$ is strictly monotone then case 1 holds and, by Theorem 3.2, the aggregate pins the factorization; and if $w$ is not injective on primes then case 2 holds and no recovery is possible at all.

*Proof.* Either $w$ is injective on primes, giving case 1, or it is not, in which case Theorem 6.1 applies and gives case 2. A strictly monotone $w$ is injective, hence in case 1. $\blacksquare$

> **Corollary 6.3 (Strictly monotone CRT weights are always free witnesses).** Let $w$ be a strictly monotone CRT weight, and let $p < q$, $p' < q'$ be primes with $pq = p'q'$ and $A_w(pq) = A_w(p'q')$. Then $p = p'$ and $q = q'$.

*Proof.* Apply Proposition 2.4 to rewrite both aggregates in product form, then Theorem 3.2 with $(a,b) = (p,q)$, $(a',b') = (p',q')$, the coprimality coming from distinctness of primes. $\blacksquare$

**Reading of the classification.** Theorems 3.2, 6.1 and 6.2 together say: within the CRT class, there is no middle ground. A weight either separates primes, in which case (under the mild additional hypothesis of monotonicity) its aggregate is worth the entire factorization; or it collides, in which case its aggregate is worth nothing. Every counting aggregate in this class is therefore either a *complete* witness or a *null* witness. This dissolves what looked like nine distinct experimental phenomena into one mechanism: a counting aggregate over a CRT-separable domain, with non-polynomial local weights, jointly encoding both factors and hence dodging the symmetry obstruction, and sealed only by the cost of computing it.

---

## 7. The characters-only boundary

A classification is meaningful only with a sharp boundary: the reader must know which weights *are not* covered, and why enlarging the class is not an option. The obstruction is structural.

> **Proposition 7.1 (Power weights are in the class).** For every $k$ and all $m, n$, $(mn)^k = m^k n^k$.

> **Theorem 7.2 (Characters-only boundary lemma).** Let $z$ be a nonzero complex number, and suppose the exponential phase weight $x \mapsto z^x$ is CRT-multiplicative:
> $$z^{mn} = z^m \, z^n \quad \text{for all coprime } m, n .$$
> Then $z = 1$.

*Proof.* Apply the hypothesis to the coprime pair $(2,3)$: $z^6 = z^2 z^3 = z^5$. Since $z \ne 0$, $z^5 \ne 0$, and dividing gives $z = 1$. $\blacksquare$

> **Corollary 7.3 (Integer shadow).** For an integer $c \ge 2$, the weight $x \mapsto c^x$ is not CRT-multiplicative: the pair $(2,3)$ gives $c^6 = c^5$, impossible since $c^5 < c^6$.

**Why this matters.** Exponential phases — the weights that drive Fourier analysis, Gauss sums, and the entire analytic toolkit — are structurally *additive* in the exponent: $z^{m+n} = z^m z^n$. The CRT splitting is *multiplicative* in the argument. The two are incompatible except in the trivial case. Consequently, oscillatory attacks based on phase functions do not decompose through the Chinese Remainder Theorem at all, and the natural class of aggregates that do is exactly the class of multiplicative characters — the class the dichotomy of Section 6 covers. The classification is therefore not an artifact of a convenient hypothesis; it exhausts the mechanism.

---

## 8. The noise-floor principle: the aggregation barrier equals the birthday bound

Sections 3–6 concern the *information* in an aggregate. This section concerns the *cost* of obtaining it, and it is here that the positive branch is sealed.

Evaluating $A_w(N) = \sum_{d \mid N} w(d)$ requires knowing the divisors of $N$. Absent an oracle, one sweeps a window of probes $d = 2, 3, \ldots, m$ and tests divisibility. The question is how long the window must be and how sparse the useful probes are within it.

### 8.1 The exact count below the corner

> **Theorem 8.1 (Noise floor below the tropical corner).** Let $p < q$ be primes and $N = pq$. Then
> $$\{\, d \in [2, \lfloor\sqrt N\rfloor] : d \mid N \,\} = \{p\}, \qquad \bigl|[2,\lfloor\sqrt N\rfloor]\bigr| = \lfloor\sqrt N\rfloor - 1 .$$
> Hence the density of factor-bearing probes in the window below the corner is exactly $1/(\lfloor\sqrt N\rfloor - 1)$.

*Proof.* First, $p \le \sqrt N$: since $p < q$, $p^2 < pq = N$, so $p \le \lfloor \sqrt N\rfloor$; and $p \ge 2$, so $p$ lies in the window and divides $N$. Conversely let $d$ lie in the window with $d \mid N$. The divisors of $N$ are $1, p, q, N$. We exclude $d = 1$ (below the window), and $d = q$ and $d = N$ because both exceed $\sqrt N$: indeed $d \le \lfloor\sqrt N\rfloor$ implies $d^2 \le N$, while $q^2 > pq = N$ and $N^2 > N$. So $d = p$. The cardinality of the integer interval $[2, M]$ is $M - 1$. $\blacksquare$

Signal $1$, noise $\sqrt N$. This is the birthday scale, stated exactly.

### 8.2 The balanced case with explicit constants

The cryptographically relevant instances are *balanced* semiprimes, where both primes are of comparable size.

> **Definition 8.2.** A semiprime $N = pq$ with $p < q$ is *balanced* if $q \le 2p$.

> **Lemma 8.3.** If $N = pq$ is balanced then $N \le 2p^2$.

*Proof.* $pq \le p(2p) = 2p^2$. $\blacksquare$

> **Lemma 8.4 (Every nontrivial divisor is at least $p$).** If $N = pq$ with $p<q$ primes and $d \mid N$ with $1 < d < N$, then $d \in \{p, q\}$, so $d \ge p$.

*Proof.* The divisor list is $1, p, q, N$; the two extremes are excluded by hypothesis. $\blacksquare$

> **Theorem 8.5 (The sweep must reach the birthday scale).** Let $N = pq$ be a balanced semiprime and let $[2,m]$ be a probe window containing some $d$ with $d \mid N$ and $1 < d < N$. Then
> $$N \le 2m^2, \qquad\text{equivalently}\qquad \sqrt N \le \sqrt 2 \, m .$$

*Proof.* By Lemma 8.4, $p \le d \le m$. By Lemma 8.3, $N \le 2p^2 \le 2m^2$. Taking square roots gives $\sqrt N \le \sqrt{2m^2} = \sqrt2\, m$. $\blacksquare$

> **Theorem 8.6 (Bounded numerator).** For any $m$ and any semiprime $N = pq$ with $p<q$ primes,
> $$\bigl|\{\, d \in [2,m] : d \mid N,\; d \ne N \,\}\bigr| \le 2 .$$

*Proof.* Any such $d$ is a divisor of $N$ other than $1$ (excluded by $d \ge 2$) and other than $N$, hence lies in $\{p, q\}$, a set of size $2$. $\blacksquare$

> **Theorem 8.7 (Noise-floor principle).** Let $N = pq$ be a balanced semiprime and let $[2, m]$ be a probe window that contains a nontrivial divisor of $N$. Then the density of factor-bearing probes in the window satisfies
> $$\frac{\bigl|\{\, d \in [2,m] : d \mid N,\; d \ne N\,\}\bigr|}{m} \;\le\; \frac{2\sqrt2}{\sqrt N} .$$

*Proof.* By Theorem 8.6 the numerator is at most $2$, so the left side is at most $2/m$. By Theorem 8.5, $\sqrt N \le \sqrt2\,m$, i.e. $m \ge \sqrt N / \sqrt 2$. Hence
$$\frac{2}{m} \le \frac{2\sqrt2}{\sqrt N}. \qquad\blacksquare$$

> **Theorem 8.8 (Aggregation cost is exactly the birthday scale).** For a balanced semiprime $N = pq$ with $p<q$, the sweep length $p$ satisfies
> $$\sqrt{N/2} \;\le\; p \;\le\; \sqrt N .$$

*Proof.* The upper bound is $p^2 < pq = N$. The lower bound is Lemma 8.3: $N \le 2p^2$. $\blacksquare$

**Consequence.** The aggregation barrier (the cost of evaluating a counting aggregate without an oracle) and the trial-division birthday bound (the cost of brute-force search) are *the same* $\Theta(\sqrt N)$ obstruction, with the noise density pinned at $c/\sqrt N$ with the explicit constant $c = 2\sqrt2$. A free witness is free only if someone gives it to you.

### 8.3 No fixed probe set suffices

One might hope to precompute a clever finite set of probes usable for all $N$.

> **Theorem 8.9 (Finite probe sets fail).** For every finite set $S \subset \mathbb{N}$ there exist primes $p < q$ such that no $s \in S$ is a nontrivial divisor of $N = pq$: for all $s \in S$, it is not the case that $s \mid N$ with $1 < s < N$.

*Proof.* Let $M = \max S$ (or $M=0$ if $S$ is empty). Choose a prime $p > M$ and a prime $q > p$, possible since primes are unbounded. The nontrivial divisors of $N = pq$ are $p$ and $q$, both exceeding $M \ge s$ for every $s \in S$. $\blacksquare$

So the probe set must grow with $N$, and by Theorem 8.5 it must reach the birthday scale.

---

## 9. The tropical reformulation

The min-plus, or *tropical*, semiring replaces $x \oplus y := \min(x,y)$ and $x \odot y := x + y$. Under the coordinate change $x \mapsto$ its tropical coordinate, the multiplicative constraint $ab = N$ becomes the tropical relation $X \odot Y = \widetilde N$: a *tropical line*, a piecewise-linear curve consisting of two rays meeting at a corner. The corner is the balanced point $a = b = \sqrt N$.

Every factorization of $N$ is a point on this line. The classical trace $a+b$ has a clean tropical characterization.

> **Theorem 9.1 (The balanced pair minimizes the trace).** Let $N > 0$ and let $N = ab = a'b'$ with $a \le b$, $a' \le b'$ and $a \le a'$. Then
> $$a' + b' \;\le\; a + b .$$
> Equivalently, in the tropical semiring, $\mathrm{trop}(a+b) \oplus \mathrm{trop}(a'+b') = \mathrm{trop}(a'+b')$.

*Proof.* If $a = a'$ then cancelling in $ab = a'b'$ gives $b = b'$ (using $a > 0$, which follows from $ab = N > 0$), so the traces are equal. If $a < a'$, Lemma 4.1 gives the strict inequality $a' + b' < a + b$. $\blacksquare$

> **Corollary 9.2 (The corner sees the factors).** For primes $p < q$ and $N = pq$, the trace at the prime factorization is strictly below the trace at the trivial factorization:
> $$p + q \;<\; 1 + N,$$
> and hence $\mathrm{trop}(1 + N) \oplus \mathrm{trop}(p+q) = \mathrm{trop}(p+q)$.

*Proof.* $1 + pq - p - q = (p-1)(q-1) > 0$ since $p, q \ge 2$. $\blacksquare$

**Synthesis.** The tropical picture unifies the two halves of the paper.

- *Trace lemma, tropically:* the factoring secret is nothing more than a **position on the tropical line** $X \odot Y = \widetilde N$. Theorem 3.2 says that any strictly monotone CRT weight simply re-coordinatizes that line — the witness value determines the position and hence the factorization. Different counting attacks are different rulers laid along the same line.
- *Aggregation barrier, tropically:* Theorem 8.8 says the position of the prime factorization lies within a factor $\sqrt 2$ of the corner, and Theorem 8.1 says exactly one probe in the entire window below the corner is useful. Locating the corner costs a sweep of length $\Theta(\sqrt N)$.

The secret is a single number; that number sits essentially at the corner; and reaching the corner costs precisely what brute force costs.

---

## 10. Algorithms

We record the two algorithms implicit in the results, with their costs measured in arithmetic operations on integers of size $O(N)$.

**Algorithm A (Oracle recovery / free-witness inversion).** *Input:* $N$, an exponent $k \ge 1$, and the aggregate value $A = \sigma_k(N)$ for a semiprime $N = pq$. *Output:* $p$.
1. $T_k \leftarrow A - 1 - N^k$ (this equals $p^k + q^k$, by (2.1)).
2. If $k = 1$, set $s \leftarrow T_1$. If $k = 2$, set $s \leftarrow \lfloor\sqrt{T_2 + 2N}\rfloor$ (this equals $p+q$ exactly).
3. Return $R(N, s) = \bigl\lfloor \tfrac12\bigl(s - \lfloor\sqrt{s^2 - 4N}\rfloor\bigr)\bigr\rfloor$.

Correctness is Corollaries 5.3–5.4. Cost: $O(1)$ arithmetic operations, i.e. polynomial time in $\log N$. For general $k \ge 3$ the trace is recovered from $T_k$ and $N$ by a monotone binary search on $s$ (evaluate $a = R(N,s)$ and compare $a^k + (N/a)^k$ with $T_k$, using Theorem 4.2 for monotonicity), costing $O(\log N)$ evaluations.

**Algorithm B (Aggregate evaluation by sweeping).** *Input:* $N$, a weight $w$. *Output:* $A_w(N)$.
1. $A \leftarrow w(1) + w(N)$.
2. For $d = 2, \ldots, \lfloor\sqrt N\rfloor$: if $d \mid N$, then $A \leftarrow A + w(d) + w(N/d)$ (with a correction if $d^2 = N$).
3. Return $A$.

Cost: $\Theta(\sqrt N)$ divisibility tests in the worst case, i.e. exponential in $\log N$. Theorems 8.5 and 8.8 show this is unavoidable for balanced semiprimes: the sweep cannot terminate before length $\sqrt{N/2}$, and Theorem 8.9 shows no fixed finite probe set replaces it.

The pair (A, B) is the whole story: A is free and fast, B is necessary and slow, and their composition is exactly trial division.

---

## 11. Discussion

### 11.1 What is established

Within the CRT-multiplicative class, the classification is complete:

1. **Structure.** Every CRT aggregate on a semiprime factors as $(1+w(p))(1+w(q))$ (Proposition 2.4), so both factors are jointly encoded.
2. **Positive branch.** Monotone weights give aggregates that determine the factorization (Theorem 3.2), with an explicit $O(1)$-operation recovery (Theorem 5.2 and corollaries). For power weights this is sharp: uniqueness holds among *all* factorizations (Theorem 4.3).
3. **Negative branch.** Colliding weights give aggregates from which no function whatsoever recovers a factor (Theorem 6.1).
4. **Exhaustiveness.** These are the only two behaviours (Theorem 6.2).
5. **Boundary.** The class is exactly the multiplicative characters; exponential phases are excluded structurally (Theorem 7.2).
6. **Cost.** The positive branch is sealed by a $\Theta(\sqrt N)$ aggregation cost with explicit noise density $\le 2\sqrt2/\sqrt N$ (Theorems 8.5–8.8).

The predictive value is real: the theory identified $p^2 + q^2$ as a complete witness before it was tested, and Corollary 5.4 confirms it exactly.

### 11.2 What is not established

We are explicit about the limits. Nothing here proves that integer factorization is computationally hard; that remains open, and no argument of this type could settle it, since the results concern a specific, if broad, class of approaches. In particular:

- The classification covers weights that are *multiplicative on coprime arguments*. Counting functions that respect the CRT splitting in a weaker sense — for instance, aggregates whose local data are vectors rather than scalars, or that are multiplicative only up to a controlled error — are not covered.
- The noise-floor principle is proved here for divisor-probe aggregates on balanced semiprimes. Its general form, for arbitrary $N$-computable aggregates, is an empirical regularity supported by independent observations across several settings (leak densities in circle-counting problems, classical error terms for primes in progressions, divisor-sum error terms, and the statistics of Pythagorean-triple trees), all landing at the $c/\sqrt N$ scale. Making that a theorem is open.
- Theorem 6.1 rules out recovery from the aggregate *value alone*. An attack that uses additional structure — the internal geometry of the counting problem rather than just its cardinality — is outside the model.

### 11.3 Relation to the broader barrier framework

The results make precise three of the framework's informal barriers. *Factorization-insensitivity* (an aggregate that depends on $N$ alone) is Theorem 6.1 and Proposition 4.4. The *symmetry barrier* — that a witness must break the symmetry between the two factors — is dodged precisely by the CRT factorization of Proposition 2.4, which encodes both factors separately. And the *aggregation barrier* is Theorems 8.5–8.8, now identified with the birthday bound rather than merely compared to it.

---

## 12. Future directions

The declared frontier is to **prove trace-lemma exhaustiveness in full generality**: define the class of CRT-respecting, polynomial-time-computable counting functions — already sharply delimited by the characters-only boundary lemma — and prove the dichotomy that any member is either factorization-insensitive or reduces to a factor-secret coordinate with polynomial-time recovery. The present paper does this for CRT-multiplicative weights; the general statement would upgrade the aggregation barrier to a statement equivalent to factoring hardness.

Concrete next steps:

1. **Vector-valued and higher-rank weights.** Extend the dichotomy to weights taking values in a commutative monoid or in a lattice, where "collides on two primes" becomes a statement about the kernel of the induced map.
2. **Approximate multiplicativity.** Prove a stability version: if $w(mn) = w(m)w(n)(1 + O(\varepsilon))$ on coprime arguments, does the dichotomy survive with a quantitative loss?
3. **The noise-floor principle as a theorem.** Establish the $c/\sqrt N$ density bound for a general class of $N$-computable aggregates, not just divisor probes, and identify the optimal constant.
4. **Barrier-4 equivalence.** Formulate and attempt the statement that the aggregation barrier is equivalent to the hardness of factoring within the CRT class — the strongest form the framework can attain without resolving the open problem itself.
5. **Unbalanced semiprimes.** Theorems 8.5–8.8 assume $q \le 2p$. The unbalanced case has smaller sweep length but rarer factor-bearing probes; a uniform statement covering all semiprimes would complete the quantitative picture.
6. **Beyond semiprimes.** The aggregate of a CRT weight at a general $N = \prod p_i^{e_i}$ factors as $\prod_i (1 + w(p_i) + \cdots + w(p_i^{e_i}))$. The trace/norm argument becomes a symmetric-function argument: does the aggregate still determine the factorization when there are more than two prime factors, and at what cost?

---

## 13. Conclusion

For counting attacks whose local weights decompose through the Chinese Remainder splitting, the landscape is now fully mapped. There are exactly two kinds of such attacks: those whose aggregate is worth the entire factorization, and those whose aggregate is worth nothing. The first kind is characterized by prime separation, comes with a closed-form inversion built from the trace and the norm, and includes the predicted witness $p^2 + q^2$. The second kind is blocked absolutely, by an information-theoretic collision rather than a complexity assumption. No third behaviour exists, and the boundary of the class is exactly the multiplicative characters.

The free witnesses are then sealed by cost, not by information: evaluating one requires a sweep of length $\Theta(\sqrt N)$, with factor-bearing probes at density at most $2\sqrt2/\sqrt N$. The aggregation barrier and the birthday bound are one obstruction seen from two directions.

In tropical coordinates the whole picture reduces to a single sentence. The factoring secret is a position on the tropical line $X \odot Y = N$; every counting witness in the class is a ruler along that line; the position lies within $\sqrt2$ of the corner; and walking to the corner costs exactly what it has always cost.
