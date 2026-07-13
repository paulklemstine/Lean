# A Generalized Recursion Identity for the Mertens Function

## Abstract

The Mertens function $M(x) = \sum_{n \le x} \mu(n)$, the summatory function of the Möbius function, is a central object of analytic number theory whose growth is intimately tied to the Riemann Hypothesis. We present and rigorously establish a generalized recursion identity that expresses $M(x)$ in terms of its own values at smaller arguments and short sums along the Dirichlet hyperbola. Precisely, for every integer $x \ge 2$ and every integer $u$ with $\lfloor\sqrt{x}\rfloor < u < x$,
$$M(x) = \sum_{k=1}^{\lfloor x/u\rfloor} \mu(k)\, S\!\left(\left\lfloor \tfrac{x}{k}\right\rfloor, u\right),$$
where $S(y,u)$ is an explicit expression built from Mertens values and floor-quotient sums. The proof proceeds through a self-contained chain of results: the Möbius divisor-sum relation, a product-reindexing lemma for sums over lattice points beneath a hyperbola, the Fundamental Identity $\sum_{k=1}^{y} M(\lfloor y/k\rfloor) = 1$, an asymmetric Dirichlet-hyperbola identity with balanced split point, and a collapse lemma reducing $S(y,u)$ to a short partial sum of the Fundamental Identity. We describe the algorithm implied by the identity, its $O(x^{2/3})$ complexity, applications to related summatory functions, and directions for further work. All identities are verified exactly by numerical computation.

**Keywords:** Mertens function, Möbius function, Dirichlet hyperbola method, arithmetic functions, sublinear algorithms, divisor sums.

---

## 1. Introduction

The **Möbius function** $\mu : \mathbb{N}_{\ge 1} \to \{-1, 0, 1\}$ is defined by $\mu(1) = 1$, $\mu(n) = 0$ if $n$ is not squarefree, and $\mu(n) = (-1)^{\omega(n)}$ otherwise, where $\omega(n)$ counts the distinct prime factors of $n$. Its summatory function,
$$M(x) = \sum_{n \le x} \mu(n),$$
is the **Mertens function**. The size of $M(x)$ is one of the deepest questions in number theory: the statement $M(x) = O(x^{1/2 + \varepsilon})$ for all $\varepsilon > 0$ is equivalent to the Riemann Hypothesis, while the stronger **Mertens Conjecture** $|M(x)| < \sqrt{x}$ — long believed — was famously disproved by Odlyzko and te Riele in 1985.

Because $M(x)$ oscillates unpredictably, its large-scale computation is both a practical challenge and a source of empirical insight into the distribution of primes. The naive approach — sieve $\mu(n)$ for $n \le x$ and accumulate — costs $\Theta(x)$ time and space and becomes infeasible well before the ranges of interest. This motivates *sublinear* algorithms based on recursion identities in the spirit of the Dirichlet hyperbola method.

In this paper we establish, from first principles, a **generalized recursion identity** for $M(x)$ carrying a free split parameter $u$. The identity expresses $M(x)$ through short sums (of length $\sim\sqrt{\cdot}$) of Mertens values at the distinct floor-quotients $\lfloor x/k \rfloor$, which is exactly the structure needed for a fast, memoized evaluation. Our contribution is threefold: (i) a clean, modular derivation via a small number of reusable lemmas; (ii) an explicit, fully floor-based statement suitable for direct implementation; and (iii) numerical verification of every identity as an exact integer equality.

Throughout, $\lfloor\cdot\rfloor$ denotes the floor function, and all sums indexed over empty ranges are zero.

---

## 2. Definitions

**Definition 2.1 (Möbius function).** For $n \ge 1$, $\mu(n) \in \{-1,0,1\}$ is $1$ when $n=1$, $0$ when a square $p^2$ divides $n$, and $(-1)^{\omega(n)}$ when $n$ is squarefree with $\omega(n)$ distinct prime factors.

**Definition 2.2 (Mertens function).** $M(x) = \sum_{n=1}^{x} \mu(n)$, with $M(0) = 0$.

**Definition 2.3 (Split point).** For $y \ge 1$, write $\nu_y = \lfloor \sqrt{y} \rfloor$ for the standard hyperbola split point and define the companion
$$\kappa_y = \left\lfloor \frac{y}{\nu_y + 1} \right\rfloor.$$
The pair $(\kappa_y, \nu_y)$ marks the two arms of the Dirichlet hyperbola: one sums over $k \le \kappa_y$, the other over $m \le \nu_y$. One always has $\kappa_y \le \nu_y$, so both arms have length $O(\sqrt{y})$.

**Definition 2.4 (The summand $S$).** For integers $y \ge 1$ and $u \ge 1$, define
$$S(y, u) = 1 \;-\; \sum_{n = \lfloor y/u\rfloor + 1}^{\kappa_y} M\!\left(\left\lfloor \tfrac{y}{n}\right\rfloor\right) \;+\; \kappa_y\, M(\nu_y) \;-\; \sum_{n=1}^{\nu_y} \left\lfloor \tfrac{y}{n}\right\rfloor \mu(n).$$

---

## 3. Auxiliary Results

The recursion rests on four lemmas of independent interest. We state each with its full statement and a proof sketch.

### 3.1 The Möbius divisor-sum relation

**Lemma 3.1.** For every $n \ge 1$,
$$\sum_{d \mid n} \mu(d) = \begin{cases} 1 & n = 1, \\ 0 & n > 1. \end{cases}$$

*Proof sketch.* This is the statement that the Dirichlet convolution $\mu * \mathbf{1}$ equals the identity $\delta$ for Dirichlet convolution, where $\mathbf 1$ is the constant-one function. Equivalently, $\mu$ is the Dirichlet inverse of $\mathbf 1$. For $n = 1$ the sum is $\mu(1) = 1$. For $n > 1$ with prime factorization $n = p_1^{a_1}\cdots p_r^{a_r}$, only squarefree divisors contribute, and grouping them by the subset of $\{p_1,\dots,p_r\}$ they use gives $\sum_{j=0}^{r}\binom{r}{j}(-1)^j = (1-1)^r = 0$. $\qquad\blacksquare$

This is the arithmetic backbone: it is the exact sense in which $\mu$ "inverts" summation over divisors, and it drives every cancellation below.

### 3.2 Product-reindexing beneath the hyperbola

**Lemma 3.2 (Reindexing by product).** Let $A$ be an abelian group (or commutative monoid) and $h : \mathbb{N} \times \mathbb{N} \to A$. For every $w \ge 0$,
$$\sum_{k=1}^{w} \sum_{j=1}^{\lfloor w/k\rfloor} h(k, j) = \sum_{d=1}^{w} \sum_{(a,b): ab = d} h(a, b).$$

*Proof sketch.* Both sides sum $h(a,b)$ over exactly the lattice points $(a,b)$ with $a,b \ge 1$ and $ab \le w$. On the left, the constraint $j \le \lfloor w/k\rfloor$ is equivalent to $kj \le w$; on the right, the points are grouped by the value of their product $d = ab$, i.e., by the divisor-pairs (the *divisor antidiagonal*) of each $d \le w$. The equality is a bijective reindexing of the same finite index set. $\qquad\blacksquare$

**Lemma 3.3 (Iterated sum as a hyperbola region).** For $a, y \ge 0$ and any $f : \mathbb{N} \to A$,
$$\sum_{k=1}^{a} \sum_{m=1}^{\lfloor y/k\rfloor} f(m) = \sum_{\substack{(k,m) \in [1,a]\times[1,y] \\ km \le y}} f(m).$$

*Proof sketch.* For fixed $k$, the inner index range $1 \le m \le \lfloor y/k\rfloor$ is exactly the set of $m \in [1,y]$ with $km \le y$; assembling over $k$ gives the stated filtered sum over the product region. $\qquad\blacksquare$

These two reindexings are *convolution-agnostic*: they hold for any summand and are the reusable geometric core of the hyperbola method.

### 3.3 The Fundamental Identity

**Theorem 3.4 (Fundamental Identity of the Mertens function).** For every $y \ge 1$,
$$\sum_{k=1}^{y} M\!\left(\left\lfloor \tfrac{y}{k}\right\rfloor\right) = 1.$$

*Proof sketch.* Expand $M(\lfloor y/k\rfloor) = \sum_{m=1}^{\lfloor y/k\rfloor} \mu(m)$ and apply Lemma 3.2 with $h(k,m) = \mu(m)$:
$$\sum_{k=1}^{y} \sum_{m=1}^{\lfloor y/k\rfloor} \mu(m) = \sum_{d=1}^{y} \sum_{(a,b): ab=d} \mu(b).$$
For fixed $d$, summing $\mu(b)$ over all factorizations $d = ab$ is the same as summing $\mu(b)$ over all divisors $b \mid d$, which by Lemma 3.1 equals $[d = 1]$. Hence the total is $\sum_{d=1}^{y} [d=1] = 1$. $\qquad\blacksquare$

The identity is remarkable: a sum of $y$ oscillating Mertens values collapses to the constant $1$. It is the source of all the cancellation exploited below.

### 3.4 The asymmetric hyperbola identity

**Theorem 3.5 (Asymmetric Dirichlet-hyperbola identity).** For every $y \ge 1$, with $\nu = \nu_y$ and $\kappa = \kappa_y$,
$$\sum_{k=1}^{\kappa} M\!\left(\left\lfloor \tfrac{y}{k}\right\rfloor\right) \;+\; \sum_{m=1}^{\nu} \left\lfloor \tfrac{y}{m}\right\rfloor \mu(m) \;-\; \kappa\, M(\nu) = 1.$$

*Proof sketch.* Start from the Fundamental Identity and split the outer range at $\kappa$:
$$\sum_{k=1}^{y} M\!\left(\left\lfloor \tfrac{y}{k}\right\rfloor\right) = \sum_{k=1}^{\kappa} M\!\left(\left\lfloor \tfrac{y}{k}\right\rfloor\right) + \sum_{k=\kappa+1}^{y} M\!\left(\left\lfloor \tfrac{y}{k}\right\rfloor\right).$$
For the tail range $k > \kappa$ one has $\lfloor y/k\rfloor \le \nu$; expanding $M(\lfloor y/k\rfloor) = \sum_{m \le \lfloor y/k\rfloor}\mu(m)$ and swapping the order of summation via Lemma 3.3 rewrites the tail as a sum over the hyperbola cells $(k,m)$ with $\kappa < k \le y$, $1 \le m \le \nu$, and $km \le y$. For each $m \le \nu$ the number of admissible $k$ is $\lfloor y/m\rfloor - \kappa$ (all $k \le \lfloor y/m\rfloor$ except the first $\kappa$, which were already counted in the head), giving
$$\sum_{k=\kappa+1}^{y} M\!\left(\left\lfloor \tfrac{y}{k}\right\rfloor\right) = \sum_{m=1}^{\nu} \left(\left\lfloor \tfrac{y}{m}\right\rfloor - \kappa\right)\mu(m) = \sum_{m=1}^{\nu}\left\lfloor \tfrac{y}{m}\right\rfloor\mu(m) - \kappa\,M(\nu).$$
Substituting and using the Fundamental Identity (left side $=1$) yields the claim. The choice $\nu = \lfloor\sqrt{y}\rfloor$ with $\kappa = \lfloor y/(\nu+1)\rfloor$ ensures both arms have length $O(\sqrt{y})$. $\qquad\blacksquare$

This asymmetric identity is the analytic heart of the recursion: it converts a length-$y$ sum into two length-$\sqrt{y}$ sums minus a single overlap term.

### 3.5 Collapse of the summand

**Lemma 3.6 (Collapse of $S$).** If $u > \nu_y = \lfloor\sqrt{y}\rfloor$, then
$$S(y, u) = \sum_{j=1}^{\lfloor y/u\rfloor} M\!\left(\left\lfloor \tfrac{y}{j}\right\rfloor\right).$$

*Proof sketch.* Rearranging the asymmetric hyperbola identity (Theorem 3.5) gives
$$1 + \kappa_y M(\nu_y) - \sum_{n=1}^{\nu_y}\left\lfloor\tfrac{y}{n}\right\rfloor\mu(n) = \sum_{k=1}^{\kappa_y} M\!\left(\left\lfloor\tfrac{y}{k}\right\rfloor\right).$$
Substituting this into Definition 2.4,
$$S(y,u) = \sum_{k=1}^{\kappa_y} M\!\left(\left\lfloor\tfrac{y}{k}\right\rfloor\right) - \sum_{n=\lfloor y/u\rfloor+1}^{\kappa_y} M\!\left(\left\lfloor\tfrac{y}{n}\right\rfloor\right) = \sum_{j=1}^{\lfloor y/u\rfloor} M\!\left(\left\lfloor\tfrac{y}{j}\right\rfloor\right),$$
valid because $u > \nu_y$ forces $\lfloor y/u\rfloor \le \lfloor y/(\nu_y+1)\rfloor = \kappa_y$, so the subtraction cleanly removes the tail $[\lfloor y/u\rfloor+1, \kappa_y]$. $\qquad\blacksquare$

Thus $S(y,u)$ is exactly a *truncated* Fundamental Identity: the first $\lfloor y/u\rfloor$ terms of $\sum_k M(\lfloor y/k\rfloor)$.

---

## 4. Main Result

**Theorem 4.1 (Generalized Mertens Recursion Identity).** For every integer $x \ge 2$ and every integer $u$ with $\lfloor\sqrt{x}\rfloor < u < x$,
$$M(x) = \sum_{k=1}^{\lfloor x/u\rfloor} \mu(k)\, S\!\left(\left\lfloor \tfrac{x}{k}\right\rfloor, u\right),$$
where $S$ is given by Definition 2.4.

*Proof sketch.* By the collapse Lemma 3.6, since $u > \lfloor\sqrt{x}\rfloor \ge \lfloor\sqrt{\lfloor x/k\rfloor}\rfloor$ for each $k$ in range, we may replace each $S(\lfloor x/k\rfloor, u)$ with $\sum_{j=1}^{\lfloor \lfloor x/k\rfloor / u\rfloor} M(\lfloor \lfloor x/k\rfloor / j\rfloor)$. Using $\lfloor\lfloor x/k\rfloor/j\rfloor = \lfloor x/(kj)\rfloor$, the right-hand side becomes
$$\sum_{k=1}^{\lfloor x/u\rfloor} \mu(k) \sum_{j : kj \le x/u} M\!\left(\left\lfloor \tfrac{x}{kj}\right\rfloor\right) = \sum_{d=1}^{\lfloor x/u\rfloor} \left(\sum_{k \mid d} \mu(k)\right) M\!\left(\left\lfloor \tfrac{x}{d}\right\rfloor\right),$$
after grouping by $d = kj$ via Lemma 3.2. By the Möbius divisor-sum relation (Lemma 3.1), the inner sum $\sum_{k\mid d}\mu(k)$ is $1$ when $d=1$ and $0$ otherwise, leaving only the $d = 1$ term:
$$M\!\left(\left\lfloor \tfrac{x}{1}\right\rfloor\right) = M(x).$$
This establishes the identity. The constraint $\lfloor\sqrt{x}\rfloor < u$ guarantees every invocation of $S$ meets the collapse hypothesis; $u < x$ guarantees the outer sum is nonempty. $\qquad\blacksquare$

**Remark 4.2.** The identity is an exact integer equation with a free parameter $u$. Different admissible $u$ trade off the length of the outer sum ($\lfloor x/u\rfloor$ terms) against the size of the arguments $\lfloor x/k\rfloor$ passed to $S$. Taking $u \approx \sqrt{x}$ balances these and yields the sublinear complexity described below.

---

## 5. Algorithm and Complexity

The identity yields a memoized evaluator for $M(x)$.

**Key structural facts.**
1. The distinct values of $\lfloor x/k\rfloor$ over $k = 1, \dots, x$ number only $O(\sqrt{x})$, so $M$ need be evaluated at only $O(\sqrt{x})$ distinct "large" arguments.
2. Each $S(y,u)$ is, by Definition 2.4, computable in $O(\sqrt{y})$ arithmetic operations given a table of small Mertens values and the small-argument Möbius values.
3. Small Mertens values $M(n)$ for $n \le x^{2/3}$ can be precomputed by a linear sieve in $O(x^{2/3})$ time.

**Complexity.** Precomputing $M(n)$ for $n \le x^{2/3}$ costs $O(x^{2/3})$. The remaining large values $M(\lfloor x/k\rfloor)$ are obtained top-down through the recursion; a standard analysis of the hyperbola method shows the total work is $O(x^{2/3})$ time (up to logarithmic factors for the memoization map) and $O(x^{2/3})$ space. This matches the well-known Lucy–Meissel/Deléglige–Rivat class of bounds for Mertens-function computation and is a decisive improvement over the $\Theta(x)$ naive method.

**Algorithm (top-down evaluation of $M(x)$).**
1. Precompute $\mu(n)$ and $M(n)$ for $n \le x^{2/3}$ via a linear sieve.
2. To evaluate $M(y)$ for a large $y$: if $y$ is already tabulated or cached, return it; otherwise choose $u = \lfloor\sqrt{y}\rfloor + 1$ and return $\sum_{k=1}^{\lfloor y/u\rfloor} \mu(k)\, S(\lfloor y/k\rfloor, u)$, caching the result.
3. Each $S(\cdot, u)$ is evaluated from Definition 2.4, recursing into $M$ at strictly smaller arguments.

Termination is guaranteed because every recursive call reduces the argument, and correctness is guaranteed by Theorem 4.1.

---

## 6. Numerical Verification

Because all quantities are exact integers, the identities admit direct verification. Using a linear Möbius sieve and prefix sums for $M$, we confirmed:

- **Fundamental Identity (Theorem 3.4):** $\sum_{k=1}^{y} M(\lfloor y/k\rfloor) = 1$ for $y \in \{1, 7, 50, 123, 1000\}$ and throughout the tested range.
- **Collapse (Lemma 3.6) and Main Recursion (Theorem 4.1):** verified for **every** valid pair $(x,u)$ with $2 \le x \le 300$ and $\lfloor\sqrt{x}\rfloor < u < x$ — $41{,}519$ pairs — with zero discrepancies.
- **Spot checks at larger scale:** with $u = \lfloor\sqrt{x}\rfloor + 1$, the recursion reproduces $M(500) = -6$, $M(1000) = 2$, $M(2500) = -1$, and $M(5000) = 2$ exactly.

Representative Mertens values: $M(1) = 1$, $M(2) = 0$, $M(10) = -1$, $M(100) = 1$, $M(1000) = 2$, $M(5000) = 2$.

---

## 7. Applications

**Fast computation of $M(x)$.** The immediate application is a verified sublinear algorithm for the Mertens function, of direct use in computational number theory — for instance in the search for counterexamples to the Mertens Conjecture, or in accumulating empirical evidence bearing on the Riemann Hypothesis.

**General summatory functions.** The reindexing lemmas (3.2, 3.3) and the hyperbola split are agnostic to the choice of arithmetic function. For any $f$ whose partial sums $F(x) = \sum_{n\le x} f(n)$ one wishes to compute, an analogous recursion follows by replacing $\mu$ with $f$ and the Möbius divisor-sum relation with the appropriate convolution identity for $f$. Concrete targets include the summatory Liouville function $L(x) = \sum_{n\le x}\lambda(n)$ and the totient summatory function $\Phi(x) = \sum_{n\le x}\varphi(n)$.

**A template for divisor-sum identities.** More broadly, Theorem 4.1 illustrates a reusable pattern: (i) express a summatory function through a Dirichlet convolution, (ii) reindex under the hyperbola, (iii) split asymmetrically at the balanced point, and (iv) collapse the resulting expression via the convolution's inverse. This template applies wherever a Dirichlet convolution with a known inverse is available.

---

## 8. Discussion and Future Work

**Arbitrary split point.** We fixed the standard $\nu_y = \lfloor\sqrt{y}\rfloor$. The hyperbola argument (Theorem 3.5) works for any $1 \le \nu \le y$ with the paired $\kappa = \lfloor y/(\nu+1)\rfloor$; abstracting $\nu$ yields a family of identities and makes explicit the balance that renders $\nu = \lfloor\sqrt{y}\rfloor$ computationally optimal.

**General Dirichlet convolutions.** Theorem 3.4 is the special case $\mu * \mathbf{1} = \delta$. Because the reindexing lemmas are convolution-agnostic, the same machinery drives analogous recursions for $\sum f(\lfloor x/k\rfloor)$ for arbitrary $f$.

**Complexity, made rigorous.** A natural next step is a fully rigorous statement and proof that evaluation through this recursion costs $O(x^{2/3})$ (or sharper bounds from the literature) — a genuine correctness proof for a sublinear Mertens algorithm — together with an executable implementation proven equal to $M$.

**Deeper number theory.** One may connect $M(x)$ to explicit bounds $|M(x)| \le \cdots$ and, aspirationally, to the Riemann-Hypothesis-equivalent statement $M(x) = O(x^{1/2+\varepsilon})$; and extend to Mertens functions of arithmetic progressions and to the Möbius function twisted by Dirichlet characters.

**Reusable infrastructure.** The product-reindexing lemma, the iterated-sum-as-hyperbola-region lemma, and the Möbius divisor-sum relation are broadly useful building blocks for any divisor-sum or hyperbola-method development.

---

## 9. Conclusion

We have established, through a compact and modular chain of results, a generalized recursion identity for the Mertens function with a free split parameter. The derivation isolates reusable geometric and arithmetic components — product reindexing, the Fundamental Identity, the asymmetric hyperbola split, and the collapse of the summand — and assembles them into an exact recursion that underpins a sublinear evaluation algorithm. Every identity has been confirmed as an exact integer equality, and the components generalize readily to a wide class of summatory functions.
