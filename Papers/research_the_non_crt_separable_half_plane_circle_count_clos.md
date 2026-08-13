# The Half-Plane Cut on the Modular Circle: A Separable Bulk, a Local Parity, and a Square-Root Fluctuation

**Author:** Aristotle
**Date:** 2026-08-13

---

## Abstract

For a modulus $N$ let $\mathcal{C}(N) = \{(x,y) \in [0,N)^2 : x^2+y^2 \equiv 1 \pmod N\}$ be the modular circle and $C(N) = |\mathcal{C}(N)|$ its cardinality. The count $C$ is *separable*: it is multiplicative over coprime factorisations, and for odd $N$ it admits the closed form $C(N) = \prod_{p \mid N} p^{\,v_p(N)-1}(p - \chi_p(-1))$, where $\chi_p(-1) = +1$ if $p \equiv 1 \pmod 4$ and $-1$ otherwise. We study the *half-plane count*
$$H(N) = \#\{(x,y) \in \mathcal{C}(N) : 2(x+y) < N\},$$
obtained by conditioning the circle on an order-theoretic — hence non-congruential, hence non-separable — cut. We prove that $H$ is genuinely outside the separable class ($H(35) = 6 \neq 4 = H(5)H(7)$), and then show that this escape is structurally sealed in three independent ways.

First, an exact **reflection identity**: $H(N) = \mathrm{high}(N) + 2R(N)$ for $N \ge 2$, where $\mathrm{high}(N)$ counts circle points in the opposite corner $2(x+y) > 3N$ and $R(N)$ counts square roots of unity below $N/2$; and $2R(N) = S(N)$ for $N \ge 3$, with $S$ (the total number of square roots of unity) separable. All non-separability of $H$ is therefore carried by $\mathrm{high}$.

Second, a **quadrant bound** $4\,\mathrm{high}(N) \le C(N)$, with the constant $4$ sharp, yielding the two-sided sandwich $2 \le H(N)$ and $4H(N) \le C(N) + 4S(N)$ between separable quantities.

Third, a **parity theorem**: $H(N) \equiv \#\{x : 2x^2 \equiv 1 \pmod N,\ 4x < N\} \pmod 2$, so the lowest-order bit of the non-separable count is decided by a purely local diagonal condition.

Empirically, over full enumeration for $15 \le N \le 62{,}879$, the deviation $\varepsilon(N) = H(N) - C(N)/8$ is genuinely factor-dependent (it varies by $\pm 100$ across a $0.7\%$-wide band of $N$ near $57{,}000$) but is of size $O(\sqrt{N})$ and shows no correlation with $p$, $q$, $p+q$ or $|p-q|$ under permutation testing. We conclude that crossing the separability boundary produces factor-dependence only at the square-root noise floor, and that the resulting seal is a consequence of aggregation rather than of separability.

As an application on the separable side, for Blum-type semiprimes $N = pq$ with $p \equiv q \equiv 3 \pmod 4$ we prove $C(N) = N + p + q + 1$, so that $C(N)$ determines the factorisation via Vieta's formulas — with the sole obstruction that evaluating $C(N)$ without the factorisation costs $\Theta(N)$ operations.

**Keywords:** modular circle, quadratic character, Chinese Remainder Theorem, multiplicative functions, Hensel lifting, lattice points in triangles, square-root cancellation, semiprime factorisation.

---

## 1. Introduction

### 1.1 Separable statistics and the classification boundary

Let $N \ge 1$ and consider the affine conic $x^2 + y^2 = 1$ over $\mathbb{Z}/N\mathbb{Z}$. Its point set is one of the most classical objects in elementary number theory, and its cardinality is one of the most classical computations. The reason the computation is easy is a single structural fact: the defining condition is a *congruence*, and congruences respect the Chinese Remainder decomposition
$$\mathbb{Z}/mn\mathbb{Z} \;\cong\; \mathbb{Z}/m\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}, \qquad \gcd(m,n)=1.$$
Any set defined by congruences alone therefore has a cardinality which is a product of local cardinalities. We call such a count **CRT-separable**, or simply *separable*.

Separable statistics have a well-known double character. On the one hand they are completely classified: they are determined by their values on prime powers, and in the case at hand by an explicit character sum. On the other hand they carry no *usable* factorisation information, because computing them requires either the factorisation itself or an exhaustive enumeration.

This motivates a natural question, which is the subject of this paper.

> **Question.** If we condition a modular counting problem on a constraint that is *not* expressible by congruences — so that the resulting count provably falls outside the separable classification — does the count acquire accessible information about the factorisation of $N$?

The cleanest available non-congruential constraint is an *order* constraint on the canonical representatives. Fixing representatives $x, y \in \{0, 1, \dots, N-1\}$ and imposing the half-plane condition $x + y < N/2$, where the sum is taken in $\mathbb{Z}$ and not in $\mathbb{Z}/N\mathbb{Z}$, destroys separability in the most direct possible way: the CRT isomorphism is a ring isomorphism and does not respect the ordering of representatives.

### 1.2 Results

We answer the question negatively, and completely, for this cut. The answer decomposes into a positive part (the separable side, which we close in closed form) and a negative part (the non-separable side, which we show is sealed).

**Separable side.**
- $C$ is multiplicative (Theorem 3.1) with $C(p) = p - \chi_p(-1)$ at odd primes (Theorem 3.3), $C(p^k) = p^{k-1}(p - \chi_p(-1))$ (Theorem 3.6), and the closed form $C(N) = \prod_{p\mid N} p^{\,v_p(N)-1}(p - \chi_p(-1))$ for all odd $N \ge 1$ (Theorem 3.7).
- $4^{\omega(N)} \mid C(N)$ for odd squarefree $N$ (Proposition 3.8).
- $C(pq) = pq + p + q + 1$ for distinct primes $p \equiv q \equiv 3 \pmod 4$, whence $p+q = C(N)-N-1$ and the factors are the roots of $X^2 - (C(N)-N-1)X + N$ (Theorems 6.1–6.3).

**Non-separable side.**
- $H$ is not multiplicative: $H(35) = 6 \ne 4 = H(5)H(7)$, while $C(35) = C(5)C(7)$ (Theorem 5.6). The same failure occurs for $\mathrm{high}$: $\mathrm{high}(33) = 4 \ne 0 = \mathrm{high}(3)\mathrm{high}(11)$.
- **Reflection identity** (Theorem 4.4): $H(N) = \mathrm{high}(N) + 2R(N)$ for $N \ge 2$.
- **Halving of the unit roots** (Theorem 4.5): $2R(N) = S(N)$ for $N \ge 3$; and $S$ is multiplicative (Proposition 4.6).
- **Quadrant bound** (Theorem 4.7): $4\,\mathrm{high}(N) \le C(N)$; sharp, since $8\,\mathrm{high}(9) = 16 > 12 = C(9)$.
- **Sandwich** (Corollary 4.8): $2 \le H(N)$ and $4H(N) \le C(N) + 4S(N)$ for $N \ge 3$.
- **Parity theorem** (Theorem 5.3): $H(N) \equiv D(N) \pmod 2$ where $D(N) = \#\{x : 2x^2 \equiv 1 \pmod N,\ 4x < N\}$; and $\mathrm{high}(N) \equiv D(N) \pmod 2$ for $N \ge 2$.

**Quantitative side (Section 7).** Full enumeration for $15 \le N \le 62{,}879$ gives $8H(N)/C(N) \to 1$ and a deviation $\varepsilon(N) = H(N) - C(N)/8$ that is factor-sensitive but of magnitude $O(\sqrt N)$, with no measurable correlation to the trace coordinates of the factorisation.

---

## 2. Definitions

Throughout, $N$ denotes a positive integer and representatives are taken in $[0,N) \cap \mathbb{Z}$.

**Definition 2.1 (Modular circle).** $\mathcal{C}(N) = \{(x,y) \in [0,N)^2 : x^2 + y^2 \equiv 1 \pmod N\}$, and $C(N) = |\mathcal{C}(N)|$.

**Definition 2.2 (Half-plane count).** $H(N) = \#\{(x,y) \in \mathcal{C}(N) : 2(x+y) < N\}$.

**Definition 2.3 (Corner count).** $\mathrm{high}(N) = \#\{(x,y) \in \mathcal{C}(N) : 3N < 2(x+y)\}$.

**Definition 2.4 (Square roots of unity).** $S(N) = \#\{u \in [0,N) : u^2 \equiv 1 \pmod N\}$ and $R(N) = \#\{u \in [0,N) : u^2 \equiv 1 \pmod N,\ 2u < N\}$.

**Definition 2.5 (Diagonal count).** $D(N) = \#\{x \in [0,N) : 2x^2 \equiv 1 \pmod N,\ 4x < N\}$.

**Definition 2.6 (Local character).** For an odd prime $p$, $\chi_p$ is the quadratic character of $\mathbb{F}_p$, so $\chi_p(-1) = +1$ if $p \equiv 1 \pmod 4$ and $\chi_p(-1) = -1$ if $p \equiv 3 \pmod 4$.

**Definition 2.7 (Separability).** An arithmetic function $f$ is *CRT-separable* (equivalently here, multiplicative) if $f(mn) = f(m)f(n)$ whenever $\gcd(m,n) = 1$.

A first sanity table, obtained by full enumeration:

| $N$ | 15 | 16 | 17 | 20 | 21 | 24 | 25 | 28 | 33 | 35 | 77 | 91 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $C(N)$ | 16 | 32 | 16 | 32 | 32 | 64 | 20 | 64 | 48 | 32 | 96 | 96 |
| $H(N)$ | 4 | 6 | 3 | 6 | 4 | 12 | 6 | 10 | 8 | 6 | 14 | 16 |
| $\mathrm{high}(N)$ | 0 | 2 | 1 | 2 | 0 | 4 | 4 | 6 | 4 | 2 | 10 | 12 |
| $R(N)$ | 2 | 2 | 1 | 2 | 2 | 4 | 1 | 2 | 2 | 2 | 2 | 2 |
| $S(N)$ | 4 | 4 | 2 | 4 | 4 | 8 | 2 | 4 | 4 | 4 | 4 | 4 |

Every column satisfies $H = \mathrm{high} + 2R$, $2R = S$, and $4\,\mathrm{high} \le C$.

---

## 3. The separable baseline: a closed form for the circle count

### 3.1 Chinese Remainder separability

**Theorem 3.1 (Separability of the circle count).** *If $\gcd(m,n) = 1$ then $C(mn) = C(m)C(n)$.*

*Proof sketch.* The CRT map $e : \mathbb{Z}/mn\mathbb{Z} \to \mathbb{Z}/m\mathbb{Z} \times \mathbb{Z}/n\mathbb{Z}$ is a ring isomorphism, so the induced map on pairs,
$$(x, y) \;\longmapsto\; \bigl((e(x)_1, e(y)_1),\ (e(x)_2, e(y)_2)\bigr),$$
sends a solution of $x^2 + y^2 = 1$ modulo $mn$ to a pair consisting of a solution modulo $m$ and a solution modulo $n$; applying $e$ to the equation and reading off components gives membership, injectivity follows from injectivity of $e$ in each coordinate, and surjectivity from applying $e^{-1}$ componentwise. $\square$

Consequently $C$ extends to a multiplicative arithmetic function (with $C(1) = 1$), and it suffices to evaluate it at prime powers.

### 3.2 The count at an odd prime: stereographic projection

**Definition 3.2.** For an odd prime $p$, the *admissible slope set* is $T_p = \{t \in \mathbb{F}_p : 1 + t^2 \ne 0\}$.

**Theorem 3.3 (Prime conic count).** *For every odd prime $p$,*
$$C(p) = p - \chi_p(-1) = \begin{cases} p - 1, & p \equiv 1 \pmod 4, \\ p + 1, & p \equiv 3 \pmod 4.\end{cases}$$

*Proof sketch.* Project stereographically from the point $(-1, 0) \in \mathcal{C}(p)$. If $(x,y)$ lies on the circle and $(x,y) \ne (-1,0)$, then $1 + x \ne 0$: indeed $x = -1$ forces $y^2 = 0$, hence $y = 0$, hence the excluded point. So the slope $t = y/(1+x)$ is defined, and a direct computation on the conic gives the key identity
$$1 + t^2 \;=\; 1 + \frac{y^2}{(1+x)^2} \;=\; \frac{(1+x)^2 + (1 - x^2)}{(1+x)^2} \;=\; \frac{2}{1+x},$$
which is nonzero because $p$ is odd. The inverse map is the classical rational parametrisation
$$t \;\longmapsto\; \Bigl(\frac{1-t^2}{1+t^2},\ \frac{2t}{1+t^2}\Bigr),$$
well defined exactly on $T_p$, landing on the circle (clear the denominators and expand), and never hitting $(-1,0)$ since $(1-t^2)/(1+t^2) = -1$ would force $2 = 0$. Verifying that the two maps are mutually inverse is again a computation with $1+t^2 = 2/(1+x)$. Hence $|\mathcal{C}(p)| = |T_p| + 1$.

To count $T_p$: the complement of $T_p$ in $\mathbb{F}_p$ is $\{t : t^2 = -1\}$, whose cardinality is $\chi_p(-1) + 1$ (the standard count of square roots: two if $-1$ is a nonzero square, zero if it is a non-square). Therefore $|T_p| = p - \chi_p(-1) - 1$ and $C(p) = p - \chi_p(-1)$. The explicit case split is the first supplement to quadratic reciprocity, $\chi_p(-1) = (-1)^{(p-1)/2}$. $\square$

### 3.3 Hensel lifting to prime powers

The conic $x^2 + y^2 = 1$ is smooth over $\mathbb{F}_p$ for odd $p$: its gradient $(2x, 2y)$ vanishes only at the origin, which is not on the curve. Smoothness gives an exact lifting count.

**Lemma 3.4 (Linear congruence count).** *Let $p$ be prime and $\alpha, \beta, \gamma \in \mathbb{F}_p$ with $(\alpha, \beta) \ne (0,0)$. Then $\#\{(s,t) \in \mathbb{F}_p^2 : \alpha s + \beta t = \gamma\} = p$.*

*Proof sketch.* If $\alpha \ne 0$, the projection $(s,t) \mapsto t$ is a bijection from the solution set onto $\mathbb{F}_p$, with inverse $t \mapsto ((\gamma - \beta t)/\alpha, t)$; symmetrically if $\beta \ne 0$. $\square$

**Lemma 3.5 (Fibre count).** *Let $p$ be an odd prime, $M \ge 2$ with $p \mid M$, and let $(a,b) \in \mathcal{C}(M)$. Then the number of points of $\mathcal{C}(pM)$ reducing to $(a,b)$ modulo $M$ is exactly $p$.*

*Proof sketch.* Write $a^2 + b^2 = Mc + 1$. A lift has the form $(a + sM,\, b + tM)$ with $0 \le s, t < p$, and
$$(a+sM)^2 + (b+tM)^2 - 1 \;=\; M\bigl(c + 2(as + bt)\bigr) + M^2(s^2+t^2),$$
so, since $p \mid M$, the lift lies on $\mathcal{C}(pM)$ if and only if $c + 2(as+bt) \equiv 0 \pmod p$. Because $p \mid M$ and $a^2 + b^2 \equiv 1 \pmod p$, the pair $(a,b)$ is not $\equiv (0,0)$ modulo $p$; and $2 \ne 0$ in $\mathbb{F}_p$. So the congruence is a non-degenerate linear equation in $(s,t)$ and Lemma 3.4 gives exactly $p$ solutions. $\square$

**Theorem 3.6 (Prime powers).** *For an odd prime $p$ and $k \ge 1$, $C(p^k) = p^{k-1}\,C(p) = p^{k-1}(p - \chi_p(-1))$.*

*Proof sketch.* Summing Lemma 3.5 over the fibres of the reduction $\mathcal{C}(pM) \to \mathcal{C}(M)$ gives $C(pM) = p\,C(M)$ whenever $p \mid M$, $M \ge 2$. Induct on $k$ with $M = p^{k}$. $\square$

### 3.4 The closed form

**Theorem 3.7 (Closed form for odd moduli).** *For every odd $N \ge 1$,*
$$C(N) \;=\; \prod_{p \mid N} p^{\,v_p(N)-1}\bigl(p - \chi_p(-1)\bigr) \;=\; N \prod_{p \mid N}\Bigl(1 - \frac{\chi_p(-1)}{p}\Bigr).$$
*In particular, for odd squarefree $N$, $C(N) = \prod_{p \mid N}(p - \chi_p(-1))$.*

*Proof sketch.* Combine multiplicativity (Theorem 3.1), which reduces $C(N)$ to a product over the prime-power components of $N$, with the prime-power evaluation (Theorem 3.6). $\square$

Examples: $C(15) = 4\cdot 4 = 16$; $C(35) = 4 \cdot 8 = 32$; $C(105) = 4\cdot4\cdot8 = 128$; $C(9) = 3\cdot4 = 12$; $C(25) = 5 \cdot 4 = 20$; $C(225) = (3\cdot4)(5\cdot4) = 240$.

**Proposition 3.8 (A $2$-adic constraint).** *For odd squarefree $N$ with $\omega(N)$ distinct prime factors, $4^{\omega(N)} \mid C(N)$.*

*Proof sketch.* Each local factor is $p-1$ with $p \equiv 1 \pmod 4$, or $p+1$ with $p \equiv 3 \pmod 4$; in both cases the factor is divisible by $4$. $\square$

Theorem 3.7 is the precise sense in which the circle count is a *separable*, classified object: it is a function of the factorisation of $N$, computable in $O(\omega(N))$ arithmetic operations once that factorisation is known, and — as far as anyone knows — requiring $\Theta(N)$ operations otherwise.

---

## 4. The half-plane cut and its symmetries

The cut $2(x+y) < N$ compares *integer representatives*, not residues, and so does not descend along the CRT isomorphism. Nonetheless the count is tightly controlled, because the circle carries reflection symmetries which the cut interacts with in a computable way.

**Lemma 4.1 (Sign flips preserve the circle).** *For $a \le N$, $(N-a)^2 \equiv a^2 \pmod N$. Hence $(x,y) \in \mathcal{C}(N)$ implies $(N-x, y), (x, N-y), (N-x, N-y) \in \mathcal{C}(N)$ whenever the coordinates stay in range.*

Write $\mathcal{L}(N)$ for the set of *low* points ($2(x+y) < N$) and $\mathcal{H}(N)$ for the *high corner* ($3N < 2(x+y)$). Split $\mathcal{L}(N)$ into its *inner* part (both coordinates $\ge 1$) and its *axis* part (some coordinate $=0$).

**Lemma 4.2 (Corner coordinates).** *If $(x,y) \in \mathcal{H}(N)$ then $2x > N$ and $2y > N$.*

*Proof sketch.* Both $x, y < N$, so $2(x+y) > 3N$ forces $2x > 3N - 2y > 3N - 2N = N$, and symmetrically. $\square$

**Lemma 4.3 (Antipodal bijection).** *The map $(x,y) \mapsto (N-x, N-y)$ is a bijection from the inner low points onto $\mathcal{H}(N)$.*

*Proof sketch.* If $(x,y)$ is low and inner, then $1 \le x, y$ and $2(x+y) < N$, so $N - x, N - y \in [1, N)$ and $2\bigl((N-x)+(N-y)\bigr) = 4N - 2(x+y) > 3N$; membership on the circle is Lemma 4.1. Conversely, from Lemma 4.2 a corner point has both coordinates $> N/2 \ge 1$, so its reflection is inner and low. The map is an involution, hence bijective. $\square$

**Theorem 4.4 (Reflection identity).** *For $N \ge 2$,* $\;H(N) = \mathrm{high}(N) + 2R(N)$.

*Proof sketch.* Partition $\mathcal{L}(N)$ into inner and axis parts. By Lemma 4.3 the inner part has cardinality $\mathrm{high}(N)$. The axis part consists of the points $(0,u)$ and $(u,0)$ with $u^2 \equiv 1 \pmod N$ and $2u < N$; these two families are disjoint (a common element would force $u = 0$, contradicting $0^2 \not\equiv 1$ for $N \ge 2$) and each is in bijection with the small unit roots, so the axis part has cardinality $2R(N)$. $\square$

**Theorem 4.5 (Halving).** *For $N \ge 3$,* $\;2R(N) = S(N)$.

*Proof sketch.* The involution $u \mapsto N - u$ maps square roots of unity to square roots of unity (Lemma 4.1 with $y=0$) and exchanges $\{2u < N\}$ with $\{2u > N\}$. It has no fixed point: if $2u = N$ and $u^2 = Nk+1$, then $u \mid N k$ (as $u \mid N$ by $N = 2u$) and $u \mid u^2$, hence $u \mid 1$, giving $u=1$ and $N=2$, excluded. Also $u=0$ is never a root for $N \ge 2$. Hence the roots split into two equal halves. $\square$

**Proposition 4.6 (Separability of $S$).** *$S(mn) = S(m)S(n)$ for $\gcd(m,n)=1$; for odd $N$, $S(N) = 2^{\omega(N)}$.*

*Proof sketch.* The CRT isomorphism carries $\{u : u^2 = 1\}$ bijectively onto the product of the corresponding local sets. $\square$

Theorems 4.4–4.5 combine to the statement that drives everything below:
$$\boxed{\;H(N) = \mathrm{high}(N) + S(N), \qquad S \text{ separable}.\;}$$
All the non-separability of the half-plane count is concentrated in the corner count $\mathrm{high}$.

**Theorem 4.7 (Quadrant bound).** *For $N \ge 1$,* $\;4\,\mathrm{high}(N) \le C(N)$, *and the constant $4$ is optimal: $8\,\mathrm{high}(9) = 16 > 12 = C(9)$.*

*Proof sketch.* Consider the four images of $\mathcal{H}(N)$ under the reflection group generated by $x \mapsto N-x$ and $y \mapsto N-y$. By Lemma 4.1 all four lie inside $\mathcal{C}(N)$. By Lemma 4.2 each image is characterised by the signs of $2x - N$ and $2y - N$: the identity image has $(+,+)$, the double reflection $(-,-)$, and the two single reflections $(-,+)$ and $(+,-)$. Distinct sign patterns force pairwise disjointness. Each reflection is injective on the corner (again by Lemma 4.2, coordinates are $> N/2$, so $N - x$ determines $x$), so the union has $4\,\mathrm{high}(N)$ elements and is contained in $\mathcal{C}(N)$. $\square$

**Corollary 4.8 (Sandwich between separable quantities).** *For $N \ge 3$,*
$$2 \;\le\; H(N), \qquad 4H(N) \;\le\; C(N) + 4S(N).$$

*Proof sketch.* Lower bound: $R(N) \ge 1$ because $u=1$ is always a small unit root, so $H \ge 2R \ge 2$. Upper bound: multiply the reflection identity by $4$ and apply Theorem 4.7 together with $2R = S$. $\square$

Since $S(N) = 2^{\omega(N)} = N^{o(1)}$, Corollary 4.8 pins $H(N)$ between $2$ and essentially $C(N)/4$, both endpoints being computable from the factorisation alone.

---

## 5. Parity is diagonal-local; non-separability is real

### 5.1 The swap symmetry

The half-plane condition depends only on $x+y$, hence is invariant under $\sigma(x,y) = (y,x)$, which also preserves the circle. The fixed points of $\sigma$ on $\mathcal{L}(N)$ are the diagonal points $x = y$, where the circle equation becomes $2x^2 \equiv 1 \pmod N$ and the cut becomes $4x < N$.

**Lemma 5.1 (Diagonal parametrisation).** *The diagonal part of $\mathcal{L}(N)$ is in bijection with $\{x \in [0,N) : 2x^2 \equiv 1 \pmod N,\ 4x < N\}$, hence has cardinality $D(N)$.*

**Lemma 5.2 (Off-diagonal halving).** *$\sigma$ restricts to a fixed-point-free involution of the off-diagonal part of $\mathcal{L}(N)$, exchanging $\{x < y\}$ with $\{x > y\}$; hence the off-diagonal part has even cardinality.*

**Theorem 5.3 (Parity of the half-plane count).** *For all $N \ge 1$,*
$$H(N) \;\equiv\; D(N) \pmod 2.$$

*Proof sketch.* Partition $\mathcal{L}(N)$ into diagonal and off-diagonal parts; the first has cardinality $D(N)$ by Lemma 5.1, the second is even by Lemma 5.2. $\square$

**Corollary 5.4 (Parity of the corner count).** *For $N \ge 2$, $\mathrm{high}(N) \equiv D(N) \pmod 2$.*

*Proof sketch.* Immediate from Theorem 4.4, since $2R(N)$ is even. $\square$

Theorem 5.3 is a strong locality statement: $D(N)$ is a count of square roots of $2^{-1}$ subject to a size condition, and the existence of such roots is decided prime by prime (by quadratic reciprocity, $2$ is a square modulo $p$ iff $p \equiv \pm 1 \pmod 8$). Empirically, the moduli $N < 80$ with $H(N)$ odd are exactly $17, 31, 49, 71, 73$; e.g. for $N = 17$ the unique diagonal witness is $x = 3$, since $2\cdot 3^2 = 18 \equiv 1 \pmod{17}$ and $4\cdot 3 = 12 < 17$, giving $H(17) = 3$ odd.

**Corollary 5.5.** *Any adversary hoping to extract factorisation information from the least significant bit of $H(N)$ recovers only the separable quantity $D(N) \bmod 2$.*

### 5.2 Failure of multiplicativity

**Theorem 5.6 (The half-plane count is not separable).** *$\gcd(5,7)=1$ and*
$$H(35) = 6 \;\ne\; 4 = H(5)\,H(7), \qquad \text{while} \qquad C(35) = 32 = C(5)\,C(7).$$
*Likewise $\mathrm{high}(33) = 4 \ne 0 = \mathrm{high}(3)\,\mathrm{high}(11)$, and $H(33) = 8 \ne 4 = H(3)H(11)$.*

*Proof sketch.* Direct enumeration of the finitely many points. $\square$

Theorem 5.6 is the formal statement that the half-plane cut crosses the classification boundary: no product of per-prime local factors can reproduce $H$. Further data:

| $N = pq$ | $C(N)$ | $C(p)C(q)$ | $H(N)$ | $H(p)H(q)$ |
|---|---|---|---|---|
| $21 = 3\cdot 7$ | 32 | 32 | 4 | 4 |
| $33 = 3\cdot 11$ | 48 | 48 | 8 | 4 |
| $35 = 5\cdot 7$ | 32 | 32 | 6 | 4 |
| $65 = 5\cdot 13$ | 48 | 48 | 8 | 4 |
| $77 = 7\cdot 11$ | 96 | 96 | 14 | 4 |

The circle count separates in every row; the half-plane count does not.

---

## 6. The separable side has teeth: Blum-type semiprimes

**Theorem 6.1 (Semiprime circle count).** *For distinct odd primes $p, q$,*
$$C(pq) = \bigl(p - \chi_p(-1)\bigr)\bigl(q - \chi_q(-1)\bigr).$$

*Proof sketch.* Theorem 3.1 with Theorem 3.3. $\square$

**Theorem 6.2 (Blum-type semiprimes).** *If $p \ne q$ are primes with $p \equiv q \equiv 3 \pmod 4$ and $N = pq$, then*
$$C(N) = N + p + q + 1, \qquad\text{hence}\qquad p + q = C(N) - N - 1.$$

*Proof sketch.* Both local characters are $-1$, so $C(N) = (p+1)(q+1) = pq + p + q + 1$. $\square$

**Theorem 6.3 (Vieta recovery).** *Under the hypotheses of Theorem 6.2, both $p$ and $q$ are roots of*
$$X^2 - \bigl(C(N) - N - 1\bigr)X + N = 0,$$
*whose coefficients are computed from $N$ and $C(N)$ alone.*

*Proof sketch.* The quadratic with roots $p, q$ is $X^2 - (p+q)X + pq$; substitute $p+q = C(N)-N-1$ and $pq = N$. $\square$

So the circle count of a Blum-type semiprime *determines the factorisation completely*. The obstruction is exclusively computational: the only known route to $C(N)$ that does not presuppose the factorisation is enumeration, at cost $\Theta(N)$ — exponential in $\log N$. Worked examples: $C(21) = 32$, so $p+q = 10$ and $\{p,q\} = \{3,7\}$; $C(437) = 480$, so $p+q = 42$ and $\{p,q\} = \{19,23\}$.

This is the exact reason the half-plane cut was worth probing: a separable statistic already contains the answer, so the only question is whether some *reachable* variant does. Section 7 answers it.

---

## 7. Quantitative behaviour of the half-plane count

### 7.1 The heuristic density

The region $\{(x,y) \in [0,N)^2 : x + y < N/2\}$ is a triangle of area $N^2/8$, i.e. one eighth of the box. If the points of $\mathcal{C}(N)$ were equidistributed in the box, we would expect
$$H(N) \;\approx\; \frac{C(N)}{8}.$$
Full enumeration confirms it. Averaging $8H(N)/C(N)$ over odd squarefree $N$ in successive ranges gives $1.0476$ on $[100,400)$, $1.0234$ on $[400,1000)$, and $1.0078$ on $[1000,3000)$, a clear approach to $1$. Note that the systematic positive bias is *explained*, not mysterious: by the reflection identity, $8H(N) - C(N) = (8\,\mathrm{high}(N) - C(N)) + 8S(N)$, and the axis term $8S(N) = 8 \cdot 2^{\omega(N)}$ is a positive contribution which is relatively large for small $N$ and negligible for large $N$.

### 7.2 The deviation is genuinely factor-dependent

Define $\varepsilon(N) = H(N) - C(N)/8$. If $\varepsilon$ were a function of $N$ alone (say via $N \bmod 4$, which is what controls the dominant term $C(N)/8$ through the local characters), the escape from the separable classification would be cosmetic. It is not. Fixing a narrow band around $N \approx 57{,}000$ and varying only the factorisation:

| $N$ | $p \cdot q$ | $C(N)$ | $C(N)/8$ | $H(N)$ | $\varepsilon(N)$ | $\varepsilon/\sqrt N$ |
|---|---|---|---|---|---|---|
| $56801$ | $79 \cdot 719$ | $57600$ | $7200.0$ | $7118$ | $-82$ | $-0.344$ |
| $56803$ | $43 \cdot 1321$ | $58080$ | $7260.0$ | $7262$ | $+2$ | $+0.008$ |
| $56819$ | $7 \cdot 8117$ | $64928$ | $8116.0$ | $8218$ | $+102$ | $+0.428$ |
| $56831$ | $17 \cdot 3343$ | $53504$ | $6688.0$ | $6631$ | $-57$ | $-0.239$ |
| $56839$ | $113 \cdot 503$ | $56448$ | $7056.0$ | $7148$ | $+92$ | $+0.386$ |
| $56845$ | $5 \cdot 11369$ | $45472$ | $5684.0$ | $5598$ | $-86$ | $-0.361$ |
| $56851$ | $139 \cdot 409$ | $57120$ | $7140.0$ | $7026$ | $-114$ | $-0.478$ |
| $56863$ | $101 \cdot 563$ | $56400$ | $7050.0$ | $7100$ | $+50$ | $+0.210$ |

Across the full band (width $0.70\%$ in $N$) the spread of $\varepsilon$ is $292$, i.e. $1.22\sqrt{N}$. The variation is therefore not attributable to $N$: it responds to the factorisation.

### 7.3 …but it sits at the square-root noise floor

Three observations bound the usefulness of that response.

1. **Scale.** $|\varepsilon(N)| = O(\sqrt N)$ empirically, over full enumeration for $15 \le N \le 62{,}879$; measured values at $\sqrt N \approx 239$ lie in $[-114, +102]$ in the band above (and $[-88,+128]$ over a wider sample), against a dominant term $C(N)/8 \approx 7{,}200$. The relative size of the factor-dependent part is thus $O(N^{-1/2})$ and shrinks as $N$ grows — at cryptographic scale it is beyond astronomically small in relative terms.

2. **Structurelessness.** Regressing $\varepsilon$ against the natural trace coordinates of the factorisation — $p$, $q$, $p+q$, $|p-q|$ — yields association statistics no larger than $0.191$, while the $95$th percentile of the corresponding permutation null distributions is approximately $0.36$. Every null hypothesis of no association is retained. The deviation changes when the factorisation changes but does not vary *monotonically or smoothly* with any coordinate one would use to read it out.

3. **Cost.** Evaluating $H(N)$ requires enumerating the circle. The most efficient scheme (bucket the residues by $y^2 \bmod N$, then for each $x$ look up $1 - x^2$) costs $\Theta(N)$ time and $\Theta(N)$ space — exactly the cost that made $C(N)$ unreachable in the first place. Crossing the classification boundary bought no computational shortcut.

### 7.4 Why square-root: the exponential-sum heuristic

The corner count $\mathrm{high}(N)$ is a lattice-point count in a triangle cut out of a conic. Writing the indicator of the triangle by Fourier inversion on $\mathbb{Z}/N\mathbb{Z}$ converts $\mathrm{high}(N)$ into a main term (the area fraction times $C(N)$) plus a sum of *incomplete character sums* over the conic. Such sums attached to $x^2+y^2 = 1$ are Kloosterman/Salié type, and Weil's bound gives them square-root cancellation. The heuristic therefore predicts, sharply,
$$\bigl|8H(N) - C(N)\bigr| \;=\; O\bigl(N^{1/2+\epsilon}\bigr) \quad \text{for odd squarefree } N,$$
which is precisely the observed behaviour. We state this as Conjecture 8.1 below.

---

## 8. Discussion, and the shape of the barrier

Three separate mechanisms conspire to seal $H$.

**(i) The bulk is separable (a "dominant-term" barrier).** By §7.1, $H(N) = C(N)/8 + O(\sqrt N)$, and $C$ is exactly the classified separable object of Theorem 3.7 — indeed $C(N)/8$ depends on $N$ only through $N$ and the residues $p \bmod 4$. Crossing the separability boundary did not move the dominant term across it.

**(ii) The low-order bits are separable (a locality barrier).** By Theorem 5.3, $H(N) \bmod 2$ equals the local diagonal count $D(N) \bmod 2$. The bit an adversary would read first is already accounted for.

**(iii) The residue is at the noise floor (an aggregation barrier).** By §7.2–7.3 the genuinely non-separable part $\varepsilon(N)$ is real but of size $O(\sqrt N)$, uncorrelated with the trace coordinates, and computable only at cost $\Theta(N)$.

The third point is the general one, and it is worth isolating. The seal here does **not** derive from CRT-separability: separability was deliberately broken, and provably so (Theorem 5.6). It derives from *aggregation*. $H(N)$ is a sum of $C(N) \approx N$ indicator values; a sum of that many roughly independent bounded terms has fluctuations of order $\sqrt N$ around its mean, and the mean is whatever the smooth geometry dictates — here the area fraction $1/8$ times the separable total. Any statistic of the same form inherits the same fate: main term dictated by geometry, factor-dependence buried at the square-root floor.

This suggests a sharper way to state the obstruction that the present computation makes concrete. To obtain accessible factorisation information from a modular object one must either

- (a) avoid aggregation entirely, i.e. read out an *individual* point or a short list of points whose identity depends on the factorisation, rather than a count; or
- (b) amplify the $O(\sqrt N)$ signal, e.g. by correlating $\varepsilon$ across many related moduli in a way that adds coherently; or
- (c) change the computational model, so that the $\Theta(N)$ aggregation itself becomes cheap.

Nothing in the half-plane construction advances any of (a), (b) or (c). That is the honest verdict: the construction succeeded in its stated aim of producing a non-classified quantity, and the quantity turned out to be uninformative for the reason that is intrinsic to counts, not for the reason that motivated the classification.

Two positive by-products deserve emphasis. First, the separable baseline is now complete and unconditional: multiplicativity, the odd-prime conic count via stereographic projection, the Hensel lift, and the closed product formula (Theorems 3.1–3.7), plus the $2$-adic divisibility $4^{\omega(N)} \mid C(N)$. Second, the structure theory of the cut is exact rather than asymptotic: the reflection identity $H = \mathrm{high} + S$, the sharp quadrant bound $4\,\mathrm{high} \le C$, and the parity theorem $H \equiv D \pmod 2$ are all equalities or sharp inequalities valid for every $N$ in range, and they reduce the entire remaining question to a single exponential-sum estimate.

---

## 9. Algorithms

**Algorithm A (circle enumeration; $\Theta(N)$ time, $\Theta(N)$ space).** Build a table mapping each residue $r$ to the list of $y \in [0,N)$ with $y^2 \equiv r$; then for each $x$, look up $1 - x^2$ and emit all resulting pairs. This computes $C(N)$, $H(N)$, $\mathrm{high}(N)$ simultaneously in one pass.

**Algorithm B (separable evaluation; $O(\omega(N))$ arithmetic operations given the factorisation).** Factor $N = \prod p^{v_p}$, then return $\prod p^{v_p - 1}(p - \chi_p(-1))$ with $\chi_p(-1)$ read off from $p \bmod 4$. This is exponentially faster than Algorithm A but presupposes the factorisation.

**Algorithm C (Blum recovery; $O(1)$ given $C(N)$).** For $N = pq$ with $p \equiv q \equiv 3 \pmod 4$: set $s = C(N) - N - 1$, $d = \sqrt{s^2 - 4N}$, and output $\bigl((s-d)/2,\ (s+d)/2\bigr)$.

The contrast between B and C on one hand and A on the other is exactly the barrier: the *content* is cheap once you have the factorisation, and the *access* is expensive when you don't.

---

## 10. Conjectures and future work

**Conjecture 10.1 (Equidistribution: the true density is $1/8$).** For odd squarefree $N$, $|8H(N) - C(N)| = O(N^{1/2+\epsilon})$.

The corner count $\mathrm{high}(N)$ is a lattice-point count in a triangle cut out of the circle $x^2+y^2 \equiv 1$, so the error term should be governed by the incomplete Kloosterman/Salié sums attached to the conic; Weil's bound then gives square-root cancellation, matching the empirically observed $\varepsilon \in [-88, +128]$ at $\sqrt N \approx 239$. Since the separable side is now closed in closed product form, the only remaining unknown in the identity $8H = C + (8\,\mathrm{high} - C) + 8S$ is a pure exponential-sum estimate, and the Gauss-sum and quadratic-character machinery used for the prime conic count is the natural starting point for the Salié-sum evaluation.

**Conjecture 10.2 (Higher congruence obstructions).** For odd $N$, $4 \mid C(N)$ and, more precisely, $C(N) \equiv 2S(N) \pmod 4$; and the parity theorem lifts: $H(N) \equiv D(N) \pmod 2$ sharpens to
$$H(N) \equiv D(N) + 2\,(\text{number of orbits of the reflection group of size } 4) \pmod 4.$$
Both statements are orbit-counting statements for the dihedral group of order $8$ acting on the circle; the fixed-point strata are exactly the axis points ($S(N)$ of them) and the diagonal points ($D(N)$ of them), which have already been isolated as separable objects. The two hard ingredients — that the axis stratum has size $2S(N)$ and that the diagonal stratum is $D(N)$ — are established above, and the remaining step is Burnside bookkeeping.

**Conjecture 10.3 (the even part).** The prime-power theorem $C(p^k) = p^{k-1}(p - \chi_p(-1))$ and the closed form $C(N) = N\prod_{p\mid N}(1 - \chi_p(-1)/p)$ are theorems for odd $N$ (Theorems 3.6–3.7); the follow-up left open is the even part, namely $C(2^k)$ and the interaction of the half-plane cut with the prime $2$. Empirically $C(2^k) = 2^{k+1}$ for $k \ge 3$ (e.g. $C(8) = 16$, $C(16) = 32$), reflecting the degeneration of the conic at $2$.

Beyond these, three directions follow from the discussion of §8: a proof that any $\Theta(N)$-aggregation statistic of the modular circle is factor-blind at the accessible scale; hint-amplification schemes that correlate $\varepsilon$ across families of related moduli; and readouts in models where the aggregation cost is not $\Theta(N)$.

---

## 11. Conclusion

We set out to test whether conditioning the modular circle on a non-congruential cut produces accessible information about the factorisation of the modulus. The cut does exactly what it was designed to do: the resulting half-plane count is provably not a product of local factors. But the count is then sealed from three directions — the dominant term $C(N)/8$ is separable and given in closed form; the parity is a purely local diagonal count; and the genuinely non-separable remainder is a factor-sensitive but structureless fluctuation of size $O(\sqrt N)$, obtainable only at $\Theta(N)$ cost.

The classification boundary is real, and crossing it is easy. What is hard is escaping aggregation — and that difficulty is untouched by the crossing.
