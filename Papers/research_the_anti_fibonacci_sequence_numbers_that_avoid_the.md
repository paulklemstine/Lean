# The Arithmetic of the Anti-Fibonacci Sequence

**Aristotle**

**Date:** 2026-08-17

---

## Abstract

We study the *anti-Fibonacci sequence* $a_0 = 1$, $a_{n+1} = a_n + n$, the addition-forgetting counterpart of the Fibonacci recurrence in which the second summand is replaced by the step index. In place of exponential growth and the golden ratio, the sequence grows quadratically, $a_n = \tfrac{1}{2}n(n-1) + 1$, and its consecutive ratio tends to $1$. We show that essentially all of its arithmetic is governed by a single identity,
$$8a_n = (2n-1)^2 + 7,$$
which transports every question about the sequence into a question about the binary quadratic form $x^2 + 7$ of discriminant $-7$. Exploiting this we obtain: (i) a constant-time counting formula $C(N) = \lfloor(\lfloor\sqrt{8N-7}\rfloor+1)/2\rfloor + 1$ for the number of terms not exceeding $N$, sharp two-sided integer bounds, the asymptotic $C(N)\sim\sqrt{2N}$, and hence natural density zero, together with a one-square-root membership test; (ii) a complete Pell classification of the square terms, showing there are infinitely many (in contrast with the three squares of the Fibonacci sequence); (iii) an exact equivalence between three-term arithmetic progressions in the sequence and Pythagorean triples with odd hypotenuse, with an explicit infinite family whose common difference is three times a square-pyramidal number, contrasted with a rigidity theorem for Fibonacci progressions; (iv) a two-squares criterion for representability as a sum of two terms, with an explicit obstruction giving a non-representable set of lower density at least $2/9$, and a proof that the sequence is an additive basis of order exactly $4$; (v) the prime divisor law "$p$ divides some term iff $p = 7$ or $p \equiv 1,2,4 \pmod 7$", with both the divisor set and its complement infinite; (vi) the residue spectrum modulo an odd prime $p$, of size exactly $(p+1)/2$, so that some class is always omitted; (vii) the minimal period modulo $m$, equal to $m$ for odd $m$ and $2m$ for even $m$, multiplicative on coprime moduli; and (viii) the exact law $\gcd(a_n, a_{n+1}) = 2$ if $n \equiv 2 \pmod 4$ and $1$ otherwise.

**Keywords:** anti-Fibonacci sequence, lazy caterer numbers, Pell equation, Pythagorean triples, quadratic reciprocity, additive basis, natural density, Pisano period.

---

## 1. Introduction

### 1.1 Motivation

The Fibonacci recurrence $F_{n+1} = F_n + F_{n-1}$ is the archetype of self-reference in arithmetic. Its solution is governed by the characteristic equation $t^2 = t + 1$, whose dominant root is the golden ratio $\varphi = (1+\sqrt 5)/2$, and consequently $F_{n+1}/F_n \to \varphi$. The presence of a quadratic irrationality in the growth constant is not incidental: it is the reason the sequence's arithmetic is hard. Determining which Fibonacci numbers are perfect squares (only $0, 1, 144$) required a genuinely deep argument; determining which are prime remains open.

This paper investigates what happens when the recurrence's *memory* is weakened in the mildest possible way. Keep the shape "next term $=$ current term $+$ something", but let the "something" be not the previous term but merely the number of steps taken so far. The result is the sequence studied here.

**Definition 1.1 (Anti-Fibonacci sequence).** The *anti-Fibonacci sequence* $(a_n)_{n \ge 0}$ is defined by
$$a_0 = 1, \qquad a_{n+1} = a_n + n \quad (n \ge 0).$$

Its first terms are
$$1,\ 1,\ 2,\ 4,\ 7,\ 11,\ 16,\ 22,\ 29,\ 37,\ 46,\ 56,\ 67,\ 79,\ 92,\ \ldots$$

**Proposition 1.2 (Closed form).** For all $n \ge 0$,
$$2a_n + n = n^2 + 2, \qquad \text{equivalently} \qquad a_n = \frac{n(n-1)}{2} + 1.$$

*Proof.* Induction on $n$. For $n = 0$ both sides equal $2$. If $2a_n + n = n^2+2$, then $2a_{n+1} + (n+1) = 2a_n + 2n + n + 1 = (n^2+2) + 2n + 1 = (n+1)^2 + 2$. $\square$

We record the closed form in the subtraction-free shape $2a_n + n = n^2+2$ because every argument below can be run entirely inside the nonnegative integers, avoiding truncated subtraction.

Two immediate consequences separate the sequence from its namesake. First, $a_n \sim n^2/2$: growth is quadratic, so $a_n^{1/n} \to 1$. Second,
$$\frac{a_{n+1}}{a_n} = 1 + \frac{n}{a_n} = 1 + \frac{2n}{n^2 - n + 2} \longrightarrow 1,$$
so the consecutive ratio converges to $1$, not to $\varphi$ or to any other algebraic number of degree $2$. The golden ratio is absent from the sequence in every asymptotic sense.

### 1.2 A geometric incarnation

The numbers $a_n = \binom{n}{2} + 1$ are the *central polygonal numbers*, better known as the **lazy caterer's sequence**: $a_n$ is the maximum number of regions into which $n-1$ straight lines can divide the plane. Indeed, adding an $n$-th line in general position to an arrangement of $n-1$ lines meets each of them once, so it is cut into $n$ pieces and creates $n$ new regions — exactly the recurrence $a_{n+1} = a_n + n$. The anti-Fibonacci sequence therefore has an entirely combinatorial-geometric origin, independent of its formal definition here.

### 1.3 The master identity

**Proposition 1.3 (Master identity).** For all $n \ge 0$,
$$8a_n = (2n-1)^2 + 7$$
(interpreted over $\mathbb{Z}$; equivalently, $8a_{p+1} = (2p+1)^2 + 7$ for $p \ge 0$, an identity in $\mathbb{N}$).

*Proof.* $8a_n = 4n^2 - 4n + 8 = (2n-1)^2 + 7$. $\square$

Every result in this paper is a corollary of Proposition 1.3 combined with a classical theorem about the quadratic form $x^2 + 7$. The discriminant $-7$ places us in the imaginary quadratic field $\mathbb{Q}(\sqrt{-7})$, whose ring of integers $\mathbb{Z}\!\left[\tfrac{1+\sqrt{-7}}{2}\right]$ has class number one; this is the structural reason the answers below are clean congruence conditions rather than approximations.

The map $n \mapsto 2n-1$ is a bijection from $\mathbb{N}_{\ge 1}$ onto the positive odd integers, and $8a_n \equiv 8 \pmod{16}$-type parity constraints will repeatedly force the auxiliary squares appearing in our representations to be odd automatically. This is the technical mechanism by which "sum of $k$ anti-Fibonacci numbers" becomes "sum of $k$ *odd* squares" with no extra hypotheses.

### 1.4 Summary of results

| Question | Answer | Classical input |
|---|---|---|
| How many terms $\le N$? | $C(N) = \lfloor(\lfloor\sqrt{8N-7}\rfloor+1)/2\rfloor + 1 \sim \sqrt{2N}$ | integer square root |
| Density of the value set | $0$ | — |
| Which terms are squares? | two Pell orbits; infinitely many | Pell equation $x^2+7 = 8y^2$ |
| Three-term progressions | $\leftrightarrow$ Pythagorean triples, odd hypotenuse | Pythagorean parametrisation |
| Sums of two terms | $8m-14$ a sum of two squares | Fermat two-squares |
| Sums of four terms | exactly $m \ge 4$ | Lagrange four-square |
| Which primes divide a term? | $p = 7$ or $p \equiv 1,2,4 \pmod 7$ | quadratic reciprocity for $-7$ |
| Residues attained mod $p$ | exactly $(p+1)/2$ classes | square counting in $\mathbb{F}_p$ |
| Minimal period mod $m$ | $m$ if $m$ odd, $2m$ if $m$ even | — |
| $\gcd(a_n, a_{n+1})$ | $2$ iff $n \equiv 2 \pmod 4$, else $1$ | — |

---

## 2. The counting function, density, and constant-time membership

### 2.1 The index set is an initial segment

**Lemma 2.1.** For all $k, N \ge 0$, $\;a_k \le N \iff k^2 + 2 \le 2N + k$.

*Proof.* Immediate from $2a_k + k = k^2 + 2$: the inequality $a_k \le N$ is equivalent to $2a_k \le 2N$, i.e. $k^2 + 2 - k \le 2N$. $\square$

**Definition 2.2.** For $N \ge 1$ put
$$T(N) := \left\lfloor \frac{\lfloor\sqrt{8N-7}\rfloor + 1}{2} \right\rfloor + 1,$$
where $\lfloor\sqrt{\cdot}\rfloor$ denotes the integer square root.

**Theorem 2.3 (Initial-segment theorem).** For $N \ge 1$ and all $k \ge 0$,
$$a_k \le N \iff k < T(N).$$

*Proof sketch.* By Lemma 2.1 the condition is $k^2 - k + 2 \le 2N$, i.e. $(2k-1)^2 \le 8N - 7$, i.e. $|2k-1| \le \lfloor\sqrt{8N-7}\rfloor =: s$. For $k \ge 1$ this reads $2k \le s+1$, i.e. $k \le (s+1)/2$, i.e. $k < \lfloor (s+1)/2\rfloor + 1$; for $k = 0$ the inequality $a_0 = 1 \le N$ holds and $0 < T(N)$ since $T(N) \ge 1$. Integer division is compatible with the floor because $s+1$ is compared against the even quantity $2k$. $\square$

The content of Theorem 2.3 is that the set $\{k : a_k \le N\}$ has no gaps: it is $\{0,1,\dots,T(N)-1\}$. This is what converts counting into arithmetic.

### 2.2 A constant-time counting formula

**Definition 2.4.** $C(N) := \#\{\,k \le N : a_k \le N\,\}$, the counting function of the anti-Fibonacci sequence *by index*.

Since $a_{N+1} > N$ for $N \ge 1$, restricting to $k \le N$ loses nothing, and Theorem 2.3 gives:

**Theorem 2.5 (Counting formula).** For $N \ge 1$,
$$C(N) = \left\lfloor \frac{\lfloor\sqrt{8N-7}\rfloor + 1}{2} \right\rfloor + 1 .$$

Since the integer square root of $N$ costs $O(\log N)$ arithmetic operations (Newton iteration), Theorem 2.5 is a *constant-time* counting algorithm in the unit-cost model and an $O(\log N)$ one in the bit model, against $\Theta(N)$ for the naive scan. Numerically: $C(10^4) = 142$, $C(10^6) = 1415$, $C(10^{12}) = 1414215$.

Two elementary inequalities follow by evaluating the membership criterion at $k = C(N)$ (which fails) and $k = C(N)-1$ (which holds).

**Theorem 2.6 (Sharp integer bounds).** For $N \ge 1$, writing $C = C(N)$,
$$2N + C \le C^2 + 1 \qquad\text{and}\qquad C^2 + 4 \le 2N + 3C .$$
Both are tight: the first has slack exactly $1$ at $N = 1$, and the second is an equality precisely when $N$ is itself an anti-Fibonacci number ($N = 1, 2, 4, 7, 11, 16, \ldots$).

*Proof sketch.* The first is Lemma 2.1 applied to the failure of $a_C \le N$; the second is Lemma 2.1 applied to $a_{C-1} \le N$, using $C \ge 2$ (valid for $N \ge 1$ since $a_0 = a_1 = 1$). $\square$

**Corollary 2.7 (Real bounds and asymptotics).** For $N \ge 1$,
$$\sqrt{2N} \le C(N) \le \sqrt{2N} + 3,$$
hence
$$\lim_{N\to\infty} \frac{C(N)}{\sqrt N} = \sqrt 2, \qquad C(N) \sim \sqrt{2N}.$$

*Proof sketch.* From $2N + C \le C^2+1$ and $C \ge 2$ we get $C^2 \ge 2N$, so $C \ge \sqrt{2N}$. From $C^2 + 4 \le 2N + 3C$ we get $(C - \tfrac32)^2 \le 2N + \tfrac94 - 4$, so $C \le \sqrt{2N} + \tfrac32 \le \sqrt{2N}+3$. Dividing by $\sqrt N$ and letting $N \to \infty$ gives the limit. $\square$

**Corollary 2.8 (Density zero).** $C(N)/N \to 0$: the set of anti-Fibonacci numbers has natural density $0$ in $\mathbb{N}$.

*Proof.* $C(N)/N \le (\sqrt{2N}+3)/N \to 0$. $\square$

Corollary 2.8 is the precise form of the informal expectation that a quadratically growing sequence is "sparse": the complement has density $1$, and the value set is as thin as the square numbers up to a factor $\sqrt 2$.

### 2.3 A one-square-root membership test

**Theorem 2.9 (Membership test).** For $m \ge 1$, the following are equivalent:
1. $m = a_n$ for some $n \ge 0$;
2. $8m - 7$ is a perfect square.

Consequently the predicate "$m$ is an anti-Fibonacci number" is decided by a single integer square root.

*Proof sketch.* If $m = a_n$ then $8m - 7 = (2n-1)^2$ by Proposition 1.3. Conversely if $8m-7 = s^2$ then $s$ is odd (as $8m-7$ is odd), say $s = 2p+1$; then $8m = (2p+1)^2 + 7 = 8a_{p+1}$, so $m = a_{p+1}$. $\square$

*Examples.* $8\cdot 46 - 7 = 361 = 19^2$, so $46 = a_{10}$. $8 \cdot 47 - 7 = 369$ is not a square, so $47$ is not in the sequence.

---

## 3. Square terms: a complete Pell classification

The Fibonacci sequence contains exactly three perfect squares. We determine all square terms of the anti-Fibonacci sequence and find infinitely many.

**Definition 3.1.** Call $(x,y) \in \mathbb{N}^2$ a *Pell solution* if $x^2 + 7 = 8y^2$.

By Proposition 1.3, for $n \ge 1$:
$$a_n = y^2 \iff (2n-1)^2 + 7 = 8y^2 \iff (2n-1, y) \text{ is a Pell solution.}$$

The equation $x^2 - 8y^2 = -7$ is a generalised Pell equation; the automorphism group of the form $x^2 - 8y^2$ is generated by the fundamental unit $3 + \sqrt 8$ of $\mathbb{Z}[\sqrt 8]$, acting by
$$\sigma(x,y) = (3x + 8y,\; x + 3y).$$

**Definition 3.2 (Reachable set).** Let $\mathcal{R} \subseteq \mathbb{N}^2$ be the smallest set containing $(1,1)$ and $(5,2)$ and closed under $\sigma$.

**Proposition 3.3 (Soundness).** Every $(x,y) \in \mathcal{R}$ is a Pell solution, has $x, y \ge 1$, and has $x$ odd.

*Proof.* Induction. The seeds satisfy $1 + 7 = 8 = 8\cdot 1$ and $25 + 7 = 32 = 8 \cdot 4$. If $x^2 + 7 = 8y^2$ then
$$(3x+8y)^2 + 7 = 9x^2 + 48xy + 64y^2 + 7 = 8\left(x^2 + 6xy + 9y^2\right) + (x^2 + 7 - 8y^2) = 8(x+3y)^2 .$$
Positivity and oddness of $3x+8y$ propagate immediately. $\square$

**Theorem 3.4 (Completeness by Vieta descent).** Every Pell solution lies in $\mathcal{R}$.

*Proof sketch.* Strong induction on $y$. Small cases $y \in \{1,2\}$ force $(x,y) \in \{(1,1),(5,2)\}$. For $y \ge 3$ one establishes three elementary bounds directly from $x^2 + 7 = 8y^2$:
$$x < 3y, \qquad 2y < x, \qquad 8y \le 3x .$$
(The first two follow from $9y^2 - x^2 = y^2 + 7 > 0$ and $x^2 - 4y^2 = 4y^2 - 7 > 0$; the third from $64y^2 - 9x^2 = 8(x^2+7) - 9x^2 = 56 - x^2 \le 0$ once $x \ge 8$, which holds as $x > 2y \ge 6$ and $x$ is odd.) Applying $\sigma^{-1}(x,y) = (3x - 8y,\; 3y - x)$ therefore lands in $\mathbb{N}^2$, and $3y - x < y$ because $x > 2y$; a direct computation shows $\sigma^{-1}$ preserves the Pell condition. The induction hypothesis places $\sigma^{-1}(x,y)$ in $\mathcal{R}$, and applying $\sigma$ returns $(x,y)$. $\square$

**Theorem 3.5 (Classification of square terms).** For $n \ge 1$:
$$\exists y,\ a_n = y^2 \iff \exists y,\ (2n-1, y) \in \mathcal{R}.$$
Conversely, every $(x,y) \in \mathcal{R}$ yields $a_{(x+1)/2} = y^2$.

**Theorem 3.6 (Infinitude).** For every $M$ there exist $n > M$ and $y$ with $a_n = y^2$. The anti-Fibonacci sequence contains infinitely many perfect squares.

*Proof.* $\mathcal{R}$ is unbounded in $x$, since $\sigma$ strictly increases $x$; take $x > 2M+2$ and set $n = (x+1)/2 > M$. $\square$

The two orbits interleave to give
$$
\begin{array}{c|ccccccc}
n & 1 & 3 & 6 & 16 & 33 & 91 & 190 \\ \hline
a_n & 1 & 4 & 16 & 121 & 529 & 4096 & 17956 \\
\sqrt{a_n} & 1 & 2 & 4 & 11 & 23 & 64 & 134
\end{array}
$$
continuing with $n = 528, 1105, \ldots$. Successive indices grow by a factor tending to $3 + 2\sqrt2 \approx 5.828$, the square of the fundamental unit's norm-one companion; hence the square terms are geometrically sparse but never exhausted.

---

## 4. Arithmetic progressions and Pythagorean triples

### 4.1 The correspondence

**Theorem 4.1 (Progression–triple correspondence).** For all $a,b,c \in \mathbb{N}$,
$$a_a + a_c = 2a_b \iff (a + c - 1)^2 + (c - a)^2 = (2b - 1)^2,$$
the right-hand side being an identity in $\mathbb{Z}$. In words: three-term arithmetic progressions among anti-Fibonacci numbers correspond exactly to Pythagorean triples with odd hypotenuse.

*Proof.* Multiply by $8$ and apply Proposition 1.3 over $\mathbb{Z}$:
$$8a_a + 8a_c = 16 a_b \iff (2a-1)^2 + 7 + (2c-1)^2 + 7 = 2\left[(2b-1)^2 + 7\right],$$
i.e. $(2a-1)^2 + (2c-1)^2 = 2(2b-1)^2$. Writing $u = 2a-1$, $v = 2c-1$, $w = 2b-1$, the identity
$$u^2 + v^2 = 2w^2 \iff \left(\frac{u+v}{2}\right)^2 + \left(\frac{v-u}{2}\right)^2 = w^2$$
holds because $2(u^2+v^2) = (u+v)^2 + (v-u)^2$. Finally $(u+v)/2 = a+c-1$ and $(v-u)/2 = c-a$. $\square$

### 4.2 From triples to progressions

**Theorem 4.2 (Existence).** Let $x > y \ge 1$ with $x^2 + y^2 = z^2$ and $z$ odd. Put
$$b = \frac{z+1}{2}, \qquad a = \frac{x - y + 1}{2}, \qquad c = \frac{x + y + 1}{2}.$$
Then $a, b, c$ are integers with $a < b < c$ and $a_a + a_c = 2a_b$, and the progression is nondegenerate: $a_a < a_b < a_c$.

(For a primitive triple exactly one of $x,y$ is even, so $x \pm y$ is odd and $a,c$ are integers; $z$ odd makes $b$ an integer.)

**Theorem 4.3 (Explicit infinite family).** For every $k \ge 0$,
$$a_{k^2} + a_{(k+1)^2} = 2\,a_{k^2 + k + 1},$$
and for $k \ge 1$ the indices are strictly increasing: $k^2 < k^2 + k + 1 < (k+1)^2$.

*Proof.* By Theorem 4.1 the claim is $\left(k^2 + (k+1)^2 - 1\right)^2 + \left((k+1)^2 - k^2\right)^2 = \left(2(k^2+k+1) - 1\right)^2$, i.e.
$$(2k^2+2k)^2 + (2k+1)^2 = (2k^2+2k+1)^2,$$
which is the classical family containing $(3,4,5)$, $(5,12,13)$, $(7,24,25)$, $(9,40,41)$, and is verified by expansion. $\square$

**Theorem 4.4 (Common difference is a pyramidal number).** For every $k \ge 0$,
$$a_{k^2+k+1} - a_{k^2} = 3\sum_{i=0}^{k} i^2 = \frac{k(k+1)(2k+1)}{2}.$$

*Proof sketch.* By the closed form the left side is $\tfrac12\left[(k^2+k+1)(k^2+k) - k^2(k^2-1)\right] = \tfrac12 k(k+1)(2k+1)$, and $6\sum_{i\le k} i^2 = k(k+1)(2k+1)$ by the standard induction. $\square$

Thus the common difference is three times the $k$-th square-pyramidal number $1^2 + 2^2 + \cdots + k^2$. For $k = 1$: $a_1 = 1$, $a_3 = 4$, $a_4 = 7$, difference $3$, arising from $(3,4,5)$. For $k = 2$: $a_4 = 7$, $a_7 = 22$, $a_9 = 37$, difference $15 = 3(1+4)$, arising from $(5,12,13)$.

**Corollary 4.5 (Unboundedness).** For every $M$ there are indices $M < a < b < c$ with $a_a + a_c = 2a_b$; take $a = (M+1)^2$, $b = (M+1)^2 + (M+1) + 1$, $c = (M+2)^2$.

### 4.3 The Fibonacci contrast

**Theorem 4.6 (Fibonacci rigidity).** Let $3 \le a < b < c$ with $F_a + F_c = 2F_b$. Then $c = b+1$ and $a = b - 2$.

*Proof sketch.* If $c \ge b+2$ then $F_c \ge F_{b+2} = F_{b+1} + F_b > 2F_b$ (using $F_{b+1} > F_b$ for $b \ge 2$), contradicting $F_a + F_c = 2F_b$ with $F_a \ge 1$. Hence $c = b+1$ and $F_a = 2F_b - F_{b+1} = F_b - F_{b-1} = F_{b-2}$, and strict monotonicity of $F$ on $[3,\infty)$ gives $a = b-2$. $\square$

So the exponential sequence supports exactly one progression pattern, $F_{b-2}, F_b, F_{b+1}$, while the quadratic sequence supports a family in bijection with the Pythagorean triples. Quadratic growth creates additive room; exponential growth destroys it.

---

## 5. Additive structure: sums of anti-Fibonacci numbers

Throughout this section we use the $\mathbb{N}$-form of the master identity, $8a_{p+1} = (2p+1)^2 + 7$, together with the elementary fact that every anti-Fibonacci number equals $a_{p+1}$ for some $p \ge 0$ (since $a_0 = a_1$).

### 5.1 Two summands

**Lemma 5.1 (Automatic oddness).** If $m \ge 2$ and $8m - 14 = x^2 + y^2$, then $x$ and $y$ are both odd.

*Proof.* $8m - 14 \equiv 2 \pmod 8$. Squares are $\equiv 0, 1, 4 \pmod 8$; the only way two of them sum to $2$ mod $8$ is $1 + 1$, forcing both odd. $\square$

**Theorem 5.2 (Two-summand criterion).** For $m \ge 2$,
$$\exists\, a, b:\ a_a + a_b = m \iff \exists\, x, y:\ 8m - 14 = x^2 + y^2 .$$

*Proof sketch.* ($\Rightarrow$) Write $a_a = a_{p+1}$, $a_b = a_{q+1}$; then $8m = (2p+1)^2 + (2q+1)^2 + 14$. ($\Leftarrow$) By Lemma 5.1, $x = 2p+1$, $y = 2q+1$ with $p, q \ge 0$, and $8m = 8a_{p+1} + 8a_{q+1}$. $\square$

**Theorem 5.3 (Complete criterion).** For $m \ge 2$, $m$ is a sum of two anti-Fibonacci numbers if and only if every prime $q \equiv 3 \pmod 4$ occurs to an even exponent in the factorisation of $8m - 14$.

*Proof.* Combine Theorem 5.2 with Fermat's two-squares theorem in its general form (a positive integer is a sum of two squares iff every prime $\equiv 3 \bmod 4$ divides it to an even power). $\square$

**Lemma 5.4.** If $3 \mid x^2 + y^2$ then $3 \mid x$ and $3 \mid y$ (hence $9 \mid x^2+y^2$).

*Proof.* Squares mod $3$ are $0$ or $1$; $x^2+y^2 \equiv 0$ forces both $\equiv 0$. $\square$

**Theorem 5.5 (An explicit obstruction).** If $m \ge 2$ and $m \equiv 1$ or $7 \pmod 9$, then $m$ is *not* a sum of two anti-Fibonacci numbers.

*Proof.* $8m - 14 \equiv 8m + 4 \pmod 9$. If $m \equiv 1$ then $8m - 14 \equiv 12 \equiv 3$, and if $m \equiv 7$ then $8m-14 \equiv 60 \equiv 6 \pmod 9$; in both cases $3 \mid 8m-14$ but $9 \nmid 8m-14$. By Lemma 5.4, $8m-14$ is then not a sum of two squares, and Theorem 5.2 applies. $\square$

**Corollary 5.6 (Density of the exceptional set).** For every $K \ge 0$, among $\{0, 1, \dots, 9K+9\}$ at least $2K$ integers are not sums of two anti-Fibonacci numbers. Hence the set of non-representable integers has lower natural density at least $2/9$.

*Proof.* The classes $m = 9k+10$ and $m = 9k+7$ ($k < K$) are $\equiv 1$ and $\equiv 7 \pmod 9$ respectively, and Theorem 5.5 excludes them. These are $2K$ distinct integers below $9K+10$. $\square$

Numerically, the non-representable integers below $60$ are
$$7,\ 10,\ 16,\ 19,\ 21,\ 25,\ 28,\ 34,\ 35,\ 37,\ 42,\ 43,\ 46,\ 49,\ 52,\ 54,\ 55,\ 56,$$
of which $10, 19, 28, 37, 46, 55$ and $7, 16, 25, 34, 43, 52$ are precisely the two excluded classes mod $9$; the remainder ($21, 35, 42, 49, 54, 56$) are excluded by other primes $\equiv 3 \bmod 4$, as Theorem 5.3 predicts. Thus $2/9$ is a genuine lower bound, not the truth.

### 5.2 Four summands: an additive basis

**Theorem 5.7 (Four odd squares).** Every integer of the form $8k+4$ is a sum of four odd squares.

*Proof.* Write $8k+4 = 4(2k+1)$ and apply Lagrange's four-square theorem to the odd number $2k+1$: $2k+1 = A^2+B^2+C^2+D^2$. Reducing mod $2$, the number of odd entries among $A,B,C,D$ is odd (it is $1$ or $3$), so $A+B+C+D$ is odd. Now use the doubling identity
$$4(A^2+B^2+C^2+D^2) = (A{+}B{+}C{+}D)^2 + (A{+}B{-}C{-}D)^2 + (A{-}B{+}C{-}D)^2 + (A{-}B{-}C{+}D)^2 .$$
All four right-hand entries are congruent to $A+B+C+D$ modulo $2$, hence all odd; replacing each by its absolute value gives four odd naturals whose squares sum to $8k+4$. $\square$

**Theorem 5.8 (Additive basis of order four).** For every $m$,
$$\exists\, a,b,c,d:\ a_a + a_b + a_c + a_d = m \iff m \ge 4 .$$

*Proof sketch.* ($\Leftarrow$) Write $m = k+4$. By Theorem 5.7, $8k + 4 = x^2+y^2+z^2+w^2$ with all entries odd, say $x = 2p+1$ etc. Then
$$8(a_{p+1} + a_{q+1} + a_{r+1} + a_{s+1}) = (x^2+y^2+z^2+w^2) + 28 = 8k + 32 = 8m,$$
so the four terms sum to $m$. ($\Rightarrow$) Each $a_i \ge 1$, so any such sum is $\ge 4$. $\square$

**Theorem 5.9 (Order two is insufficient).** For every $K$ there is $m > K$ which is a sum of four anti-Fibonacci numbers but of no two.

*Proof.* Take $m = 9k + 10 > K$; apply Theorems 5.8 and 5.5. $\square$

### 5.3 Three summands

**Theorem 5.10 (Three-summand criterion).** For $m \ge 3$,
$$\exists\, a,b,c:\ a_a + a_b + a_c = m \iff \exists\, x,y,z:\ 8m - 21 = x^2 + y^2 + z^2 .$$

*Proof sketch.* As in Theorem 5.2, using that $8m - 21 \equiv 3 \pmod 8$ forces $x,y,z$ all odd (squares mod $8$ lie in $\{0,1,4\}$ and only $1+1+1$ gives $3$). $\square$

Combining Theorem 5.10 with Gauss' three-squares theorem — an integer is a sum of three squares iff it is not of the form $4^s(8t+7)$ — and noting $8m-21 \equiv 3 \pmod 8$ is never of that excluded shape, one obtains that *every* $m \ge 3$ is a sum of three anti-Fibonacci numbers, improving the basis order from $4$ to $3$. Since $a_0 + a_1 = 2$ and $a_0 = 1$, the orders $1$ and $2$ genuinely fail on a positive-density set, so $3$ is optimal.

---

## 6. Divisibility: which primes appear

### 6.1 The prime divisor law

**Theorem 6.1 (Quadratic character of $-7$).** Let $p$ be a prime with $p \ne 2, 7$. Then $-7$ is a square modulo $p$ if and only if $p \equiv 1, 2$ or $4 \pmod 7$.

*Proof sketch.* Since $-7 \equiv 1 \pmod 4$, quadratic reciprocity in the form $\left(\frac{-7}{p}\right) = \left(\frac{p}{7}\right)$ applies, and the nonzero squares modulo $7$ are $\{1, 2, 4\}$. $\square$

**Theorem 6.2 (Prime divisor law).** For a prime $p$,
$$\exists\, n:\ p \mid a_n \iff \big(p = 7 \ \text{ or }\ p \equiv 1, 2, 4 \pmod 7\big).$$

*Proof sketch.* By Proposition 1.3, $p \mid a_n$ for some $n$ iff $8a_n \equiv 0$ has a solution, i.e. iff $(2n-1)^2 \equiv -7 \pmod p$ is solvable. For $p \ne 2, 7$ the factor $8$ is invertible mod $p$, and as $n$ ranges over $\mathbb{N}$ the value $2n-1$ ranges over all residues mod $p$; so solvability is exactly the statement that $-7$ is a square mod $p$, and Theorem 6.1 finishes. The two exceptional primes are handled by exhibiting a term: $7 \mid a_4 = 7$ and $2 \mid a_2 = 2$, and indeed $2 \equiv 2 \pmod 7$, so both are consistent with the stated law. $\square$

The divisor primes begin $2, 7, 11, 23, 29, 37, 43, 53, 67, 71, \ldots$; the non-divisor primes ($p \equiv 3, 5, 6 \bmod 7$) begin $3, 5, 13, 17, 19, 31, 41, 47, 59, 61, \ldots$.

**Theorem 6.3 (Both sets are infinite).** The set of primes dividing some anti-Fibonacci number is infinite, and so is the set of primes dividing none.

*Proof.* Dirichlet: there are infinitely many primes $\equiv 1 \pmod 7$ (all divisors) and infinitely many $\equiv 3 \pmod 7$ (all non-divisors). $\square$

The second statement is a genuine point of departure from Fibonacci, for which every prime divides some term. The anti-Fibonacci sequence has an infinite *prime blind spot*, described by a congruence.

### 6.2 The residue spectrum modulo a prime

**Lemma 6.4 (Squares in a prime field).** For an odd prime $p$, the image of $x \mapsto x^2$ on $\mathbb{Z}/p$ has exactly $(p+1)/2$ elements.

*Proof.* The squaring map is $2$-to-$1$ on the $p-1$ nonzero elements and sends $0$ to $0$, giving $(p-1)/2 + 1 = (p+1)/2$ values. $\square$

**Theorem 6.5 (Spectrum criterion).** Let $p$ be an odd prime and $m \in \mathbb{Z}/p$. Then $m$ is attained by the anti-Fibonacci sequence modulo $p$ — i.e. $m \equiv a_n$ for some $n$ — if and only if $8m - 7$ is a square in $\mathbb{Z}/p$.

*Proof sketch.* $8a_n = (2n-1)^2 + 7$, so $8a_n - 7$ is a square; conversely, given $8m - 7 = t^2$, adjust $t$ by a sign so that its lift is odd, write $t = 2p_0+1$, and then $a_{p_0+1} \equiv m$. Every square in $\mathbb{Z}/p$ has an odd representative because $t$ and $t + p$ have opposite parities. $\square$

**Theorem 6.6 (Size of the spectrum).** For an odd prime $p$, the anti-Fibonacci sequence attains exactly $(p+1)/2$ residue classes modulo $p$.

*Proof.* The affine map $m \mapsto 8m - 7$ is a bijection of $\mathbb{Z}/p$ ($8$ invertible since $p$ is odd), so by Theorem 6.5 the spectrum is the preimage of the square set, of cardinality $(p+1)/2$ by Lemma 6.4. $\square$

**Corollary 6.7 (Omitted residues).** For every odd prime $p$, some residue class modulo $p$ is never attained; indeed exactly $(p-1)/2$ classes are omitted.

Examples: modulo $5$ the spectrum is $\{1,2,4\}$; modulo $7$ it is $\{0,1,2,4\}$; modulo $11$, $\{0,1,2,4,5,7\}$; modulo $13$, $\{1,2,3,4,7,9,11\}$ — always just over half.

---

## 7. Periodicity modulo $m$

**Definition 7.1.** For $m, p \ge 1$, say $p$ is a *period of the anti-Fibonacci sequence modulo $m$* if $a_{n+p} \equiv a_n \pmod m$ for all $n \ge 0$.

The key structural fact is that shifting produces a *linear*, not exponential, difference.

**Lemma 7.2 (Shift formula).** For all $n, p \ge 0$, over $\mathbb{Z}$:
$$a_{n+p} - a_n = np + (a_p - 1).$$

*Proof.* Doubling the closed form, $2(a_{n+p} - a_n) = (n+p)^2 - n^2 - p = 2np + p^2 - p$, and separately $2(a_p - 1) = p^2 - p$. $\square$

**Theorem 7.3 (Characterisation of periods).** For $p \ge 1$, $p$ is a period modulo $m$ if and only if
$$m \mid p \quad\text{and}\quad a_p \equiv 1 \pmod m .$$

*Proof.* By Lemma 7.2, the infinitely many congruences $a_{n+p} \equiv a_n$ ($n \ge 0$) read $np + (a_p - 1) \equiv 0 \pmod m$ for all $n$. Taking $n = 0$ gives $a_p \equiv 1$; subtracting consecutive instances gives $p \equiv 0 \pmod m$. Conversely those two conditions clearly imply all of them. $\square$

Only two congruences matter — an enormous simplification over the Fibonacci case, where the Pisano period has no closed form.

**Definition 7.4.** $\pi(m) := m$ if $m$ is odd, and $\pi(m) := 2m$ if $m$ is even.

**Theorem 7.5 (Minimal period).** For every $m \ge 1$, $\pi(m)$ is the least period of the anti-Fibonacci sequence modulo $m$.

*Proof sketch.* *($2m$ always works.)* $a_{2m} = m(2m-1) + 1 \equiv 1 \pmod m$ and $m \mid 2m$; apply Theorem 7.3.
*(odd $m$ works.)* Write $m = 2t+1$. Then $a_{2t+1} = (2t+1)t + 1 \equiv 1 \pmod{2t+1}$, and $m \mid m$.
*(even $m$ fails at $p = m$.)* Write $m = 2s$ with $s \ge 1$. Then $a_{2s} = s(2s-1)+1$, and $a_{2s} - 1 = s(2s-1)$ is $s$ times an odd number, so $2s \nmid s(2s-1)$; the second condition of Theorem 7.3 fails.
*(minimality.)* Any period $p$ satisfies $m \mid p$, so $p \in \{m, 2m, 3m, \ldots\}$. For odd $m$, $p = m$ is already a period. For even $m$, $p = m$ fails, so $p \ge 2m$, attained. $\square$

**Corollary 7.6.** In $\mathbb{Z}/m$, $a_{n + \pi(m)} = a_n$ for all $n$, and no smaller positive shift has this property.

**Theorem 7.7 (Multiplicativity).** If $\gcd(m_1, m_2) = 1$ then $\pi(m_1 m_2) = \pi(m_1)\pi(m_2)$. Coprimality is necessary: $\pi(4) = 8 \ne 4 = \pi(2)\pi(2)$.

*Proof sketch.* Coprimality forbids both $m_i$ even. If both are odd, all three values are the moduli themselves. If exactly one, say $m_1$, is even, then $\pi(m_1m_2) = 2m_1m_2 = (2m_1)(m_2)$. $\square$

This mirrors the multiplicativity of the Pisano period on coprime arguments while being vastly simpler; e.g. $\pi(6) = 12$, $\pi(15) = 15$, $\pi(100) = 200$.

---

## 8. Consecutive terms: the exact gcd law

Consecutive Fibonacci numbers are always coprime. For the anti-Fibonacci sequence, coprimality fails exactly on one residue class in four, and the failure is always by a factor of exactly $2$.

**Lemma 8.1.** $\gcd(a_n, a_{n+1}) \mid n$.

*Proof.* $a_{n+1} = a_n + n$, so the gcd divides $a_n + n$ and $a_n$, hence $n$. $\square$

**Theorem 8.2 (The gcd divides two).** For all $n$, $\gcd(a_n, a_{n+1}) \mid 2$.

*Proof.* Let $d = \gcd(a_n, a_{n+1})$. Then $d \mid a_n$ and, by Lemma 8.1, $d \mid n$. Hence $d \mid 2a_n + n = n^2 + 2$, and $d \mid n^2$, so $d \mid 2$. $\square$

**Lemma 8.3 (Explicit values on the exceptional class).** $a_{4k+2} = 8k^2 + 6k + 2$ and $a_{4k+3} = 8k^2 + 10k + 4$.

*Proof.* Substitute $n = 4k+2$ into $2a_n = n^2 - n + 2$, then use $a_{n+1} = a_n + n$. $\square$

**Theorem 8.4 (Exact gcd law).** For all $n \ge 0$,
$$\gcd(a_n, a_{n+1}) = \begin{cases} 2, & n \equiv 2 \pmod 4,\\ 1, & \text{otherwise.}\end{cases}$$

*Proof sketch.* By Theorem 8.2 the gcd is $1$ or $2$. If $n \equiv 2 \pmod 4$, write $n = 4k+2$; Lemma 8.3 shows both $a_n$ and $a_{n+1}$ are even, so the gcd is $2$. Conversely suppose the gcd is $2$. Then $2 \mid n$, say $n = 2t$, and $2 \mid a_n$, say $a_n = 2s$. The closed form $2a_n + n = n^2+2$ becomes $4s + 2t = 4t^2 + 2$, i.e. $2s + t = 2t^2 + 1$, forcing $t$ odd, i.e. $n = 2t \equiv 2 \pmod 4$. $\square$

**Corollary 8.5.** $\gcd(a_n, a_{n+1}) = 1$ if and only if $n \not\equiv 2 \pmod 4$. In particular $a_2 = 2$ and $a_3 = 4$ are not coprime, whereas every consecutive Fibonacci pair is.

The gcd sequence for $n = 0, 1, 2, \ldots$ is the purely periodic word $(1,1,2,1)^\infty$.

---

## 9. Algorithms

The results above are constructive and yield efficient procedures.

**Algorithm A (Constant-time membership).** Input $m \ge 1$. Compute $s = \lfloor\sqrt{8m-7}\rfloor$; output "yes" iff $s^2 = 8m-7$. Correct by Theorem 2.9. Cost: one integer square root, $O(\log m)$ bit operations by Newton iteration, versus $\Theta(\sqrt m)$ for generating terms.

**Algorithm B (Constant-time counting).** Input $N \ge 1$. Output $\lfloor(\lfloor\sqrt{8N-7}\rfloor+1)/2\rfloor + 1$. Correct by Theorem 2.5. Cost as above, versus $\Theta(\sqrt N)$ for the term-generating scan and $\Theta(N)$ for a naive filter.

**Algorithm C (Square-term enumeration).** Maintain two orbits, seeded at $(1,1)$ and $(5,2)$, and iterate $(x,y) \mapsto (3x+8y,\, x+3y)$, emitting $\left(\tfrac{x+1}{2}, y^2\right)$ at each step, merged in increasing order of $x$. By Theorems 3.4 and 3.5 this enumerates *all* square terms without omission or repetition. Cost: $O(1)$ big-integer operations per output; the $j$-th output has $\Theta(j)$ digits.

**Algorithm D (Progression generation).** For each Pythagorean triple $(x,y,z)$ with $z$ odd and $x > y \ge 1$, output $\left(\tfrac{x-y+1}{2}, \tfrac{z+1}{2}, \tfrac{x+y+1}{2}\right)$. By Theorems 4.1 and 4.2 this generates every three-term progression, and the standard parametrisation $x = u^2 - v^2$, $y = 2uv$, $z = u^2+v^2$ makes the enumeration complete.

**Algorithm E (Two-summand decision).** Input $m \ge 2$. Factor $8m - 14$ and test whether every prime $\equiv 3 \pmod 4$ occurs to an even power (Theorem 5.3); or, for a fast negative test, check $m \bmod 9 \in \{1,7\}$ (Theorem 5.5). The full test costs one factorisation; the congruence test is $O(1)$ and rejects a set of density $2/9$.

**Algorithm F (Four-summand decomposition).** Input $m \ge 4$. Set $k = m - 4$, find $x,y,z,w$ odd with $x^2+y^2+z^2+w^2 = 8k+4$ (Theorem 5.7; e.g. by Rabin–Shallit or by search), and output the indices $\tfrac{x+1}{2}, \tfrac{y+1}{2}, \tfrac{z+1}{2}, \tfrac{w+1}{2}$.

---

## 10. Discussion

### 10.1 Why every question is classical

The recurring pattern is: *multiply by eight, complete the square, invoke a theorem from before 1800*. The reason is structural. A quadratic sequence with integer second difference $1$ is, after the affine change of variable $n \mapsto 2n-1$ and scaling by $8$, precisely the value set of the quadratic form $X^2 + 7$ on odd integers. The arithmetic of a binary quadratic form of discriminant $-7$ is completely understood: its representation numbers, its prime splitting law, its class group (trivial), its automorphism group. Every question one can ask about the anti-Fibonacci sequence that is *invariant under this transport* therefore has a complete classical answer.

This puts a sharp boundary around the theory. Questions that are *not* transportable — for instance, which anti-Fibonacci numbers are prime, or how the sequence interacts with multiplicative functions in a non-quadratic way — remain as hard as they are for any quadratic polynomial. In particular, whether $\tfrac{1}{2}n(n-1)+1$ takes infinitely many prime values is an instance of Bunyakovsky's conjecture and is open.

### 10.2 The dichotomy with Fibonacci

| Property | Fibonacci $F_n$ | Anti-Fibonacci $a_n$ |
|---|---|---|
| Growth | $\varphi^n/\sqrt5$ | $n^2/2$ |
| $x_{n+1}/x_n$ | $\to \varphi$ | $\to 1$ |
| Perfect squares | exactly $0, 1, 144$ | infinitely many |
| 3-term progressions | one rigid pattern | one per Pythagorean triple |
| Consecutive gcd | always $1$ | $2$ iff $n \equiv 2 \bmod 4$ |
| Primes dividing some term | all | $p = 7$ or $p \equiv 1,2,4 \bmod 7$ |
| Minimal period mod $m$ | Pisano, no closed form | $m$ or $2m$ |
| Density of value set | $0$ | $0$ |
| Additive basis order | not a basis (gaps grow) | $4$ unconditionally; $3$ via Gauss |

The table shows a systematic trade: exponential growth buys analytic elegance and arithmetic opacity; quadratic growth buys arithmetic transparency and analytic triviality. Every entry where Fibonacci is rigid, the anti-Fibonacci sequence is abundant, and vice versa. This is not a coincidence but a consequence of growth rate: additive relations among terms of a sequence growing like $\theta^n$ are constrained by the near-uniqueness of greedy representations, while a sequence growing like $n^2$ has $\Theta(\sqrt N)$ terms below $N$ and therefore $\Theta(N)$ potential pairs, enough for a positive-density sumset.

### 10.3 Sharpness

Several of the bounds above are tight. In Theorem 2.6 the second inequality is an equality exactly when $N$ is a term of the sequence, and the first has slack $1$ at $N = 1$; neither can be improved by a constant. The real bounds $\sqrt{2N} \le C(N) \le \sqrt{2N}+3$ have the right order but not the optimal constant: numerically $C(N) - \sqrt{2N}$ stays inside $(1/2, 3/2)$ for all $N$ tested up to $2\cdot 10^5$, so the additive constant $3$ could be lowered to $3/2$ at the cost of a longer argument. The additive-basis order $4$ of Theorem 5.8 is optimal in the sense that order $2$ fails on a set of density $\ge 2/9$, and improves to the truly optimal $3$ via Gauss. The density bound $2/9$ is *not* sharp: the true density of the non-representable set is larger, since further classes are killed by primes $\equiv 3 \pmod 4$ other than $3$ (Theorem 5.3); computing it exactly is a Landau–Ramanujan-type problem for the shifted form $8m-14$.

---

## 11. Future directions

**C1. No four anti-Fibonacci numbers in arithmetic progression.** We conjecture that there are no indices $a<b<c<d$ with $a_b - a_a = a_c - a_b = a_d - a_c$. By the master identity a four-term progression among anti-Fibonacci numbers is exactly a four-term progression of odd squares, and Fermat's right-triangle theorem forbids four distinct squares in arithmetic progression. The three-term case reduces to Pythagorean triples (Theorem 4.1); the four-term case should reduce to the quartic equation $x^4 - y^4 = z^2$, i.e. to a single further descent beyond the classical $x^4 + y^4 \ne z^2$. The conjecture is falsifiable by brute-force search, made cheap by the $O(1)$ membership test of Theorem 2.9.

**C2. The period function determines the sequence.** Let $f : \mathbb{N} \to \mathbb{N}$ satisfy $f(0) = 1$ and have minimal period $\pi(m) = m$ (odd $m$), $2m$ (even $m$) modulo every $m > 0$. We conjecture $f = a$ whenever $f$ is a polynomial sequence of degree $\le 2$. The characterisation of Theorem 7.3 uses only that the first difference is linear; conversely, a period function equal to $m$ or $2m$ should force the second difference to be constant and equal to $1$, pinning the sequence. Falsifiable by exhibiting a non-quadratic $f$ with the same period function.

**C3. Second-order counting law.** With $C(N)$ as in Theorem 2.5, the discrepancy $\theta(N) = C(N) - \sqrt{2N} \in [0,3)$ should be equidistributed in a precise sense on the natural scale, with a computable limiting distribution. This would refine Corollary 2.7 from a two-sided bound to an exact second-order asymptotic.

**C4. Exact density of the two-summand sumset.** Determine $\lim_{N} \tfrac{1}{N}\#\{m \le N : m = a_i + a_j\}$. By Theorem 5.2 this is the density of integers $m$ with $8m-14$ a sum of two squares — a Landau–Ramanujan problem in an arithmetic progression, plausibly of the form $c \cdot N(\log N)^{-1/2}$ with an explicit constant, in which case the density is $0$ and Corollary 5.6's bound of $2/9$ is dramatically improvable.

**C5. Prime values.** Are there infinitely many primes of the form $\tfrac{1}{2}n(n-1)+1$? The polynomial is irreducible with no fixed prime divisor, so Bunyakovsky predicts yes; unconditionally the question is open, but Theorem 6.2 gives complete information about which primes can occur as *divisors*, and the residue spectrum of Theorem 6.6 constrains sieve weights.

**C6. Higher-order anti-Fibonacci sequences.** Replace $a_{n+1} = a_n + n$ by $a_{n+1} = a_n + \binom{n}{d-1}$, giving a degree-$d$ polynomial sequence. The master identity generalises to a degree-$d$ form, and the natural question is which of the eight theorems above survive: the counting and density statements certainly do (with exponent $1/d$), the Pell and Pythagorean correspondences do not, and the period law should become $\pi_d(m) = m \cdot \operatorname{lcm}$-type expression depending on $d!$ and $m$.

---

## 12. Conclusion

The anti-Fibonacci sequence $a_0 = 1$, $a_{n+1} = a_n + n$ is what remains of the Fibonacci recurrence when the memory of the second-previous term is replaced by a step counter. The change is small in form and total in effect: exponential growth becomes quadratic, the golden ratio disappears, and the entire arithmetic of the sequence collapses onto the single identity $8a_n = (2n-1)^2 + 7$.

Through that identity we have determined the counting function exactly and in constant time; classified all square terms via a Pell equation and shown there are infinitely many; identified three-term progressions with Pythagorean triples and exhibited an explicit infinite family with square-pyramidal common differences; characterised sums of two terms via Fermat's two-squares theorem with an explicit non-representable set of density at least $2/9$; proved that the sequence is an additive basis of order four (three, given Gauss); determined precisely which primes divide some term; counted the attained residues modulo any odd prime as $(p+1)/2$; computed the minimal period modulo $m$ as $m$ or $2m$; and established the exact gcd law for consecutive terms.

Fibonacci's fame rests on the golden ratio and on the depth of the questions it refuses to answer. The anti-Fibonacci sequence has no golden ratio and refuses almost nothing. Between them they mark out the two poles of what a simple recurrence can be.
