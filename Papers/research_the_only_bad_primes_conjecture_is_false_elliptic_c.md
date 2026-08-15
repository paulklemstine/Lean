# Good Primes Rule the Denominators: Refuting the "Only Bad Primes" Conjecture for Mordell Curves, and an Anti-Factoring Law

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

For a Mordell curve $E_N : y^2 = x^3 + N$ over $\mathbb{Q}$ with $N = pq$ a semiprime, it is tempting to conjecture that the denominators of the $x$-coordinates of the multiples $nP$ of a rational point $P$ are supported on the primes of bad reduction, namely the divisors $\{2,3,p,q\}$ of the discriminant $\Delta = -432N^2$. Such a statement would make the denominator sequence a factoring oracle. We prove that the conjecture is false, identify the exact mechanism that governs denominator primes, and then prove a converse law that is considerably stronger than a mere refutation.

Three groups of results are established. First, a *local law*: for a prime $\ell \geq 5$ with $\ell \nmid N$, one has $\ell \mid \operatorname{den} x(P)$ if and only if $P$ lies in the kernel of reduction modulo $\ell$, so that $\ell \mid \operatorname{den} x(nP)$ exactly when the order of the reduction of $P$ in $E_N(\mathbb{F}_\ell)$ divides $n$. The explicit witness $N = 55$, $P = (9,28)$ yields $x(2P) = 2601/3136$ with $3136 = 2^6 \cdot 7^2$ and $7 \nmid \Delta$, refuting the conjecture. Second, an *unbounded family of violations*: for every prime $\ell \geq 5$ and every $t \geq 1$, the modulus $N(\ell,t) = 4\ell^2t^2 - 1 = (2\ell t - 1)(2\ell t + 1)$ carries the integral point $(1, 2\ell t)$ whose doubled $x$-coordinate has $\ell$ in its denominator while no prime factor of $N(\ell,t)$ does; genuine semiprime instances include $899 = 29\cdot31$, $1763 = 41\cdot43$ and $39203 = 197\cdot199$. Third, an *anti-factoring law*: a prime $p \neq 2$ dividing $N$ can divide $\operatorname{den} x(2P)$ only if $P$ meets the singular locus modulo $p$; since integral points on squarefree moduli never do, for odd squarefree $N$ and any integral point $P$ the entire doubling orbit $\{2^k P\}$ has $x$-denominators coprime to $N$. The denominator sequence along a doubling orbit therefore carries no information at all about the factorization of $N$.

**Keywords:** Mordell curve, elliptic curve denominators, bad reduction, kernel of reduction, singular locus, elliptic divisibility, integer factorization.

---

## 1. Introduction

### 1.1 The object of study

Fix a nonzero integer $N$ and consider the *Mordell curve*
$$E_N : \quad y^2 = x^3 + N$$
over $\mathbb{Q}$. It is an elliptic curve of discriminant
$$\Delta(E_N) = -432 N^2, \qquad j(E_N) = 0,$$
whose rational points, together with a point at infinity $O$, form a finitely generated abelian group $E_N(\mathbb{Q})$ under the chord-and-tangent law. A prime $\ell$ is a prime of *bad reduction* for $E_N$ if $\ell \mid \Delta$, equivalently if $\ell \in \{2,3\}$ or $\ell \mid N$; all other primes are primes of *good reduction*.

For a nonzero rational number $r$ we write $\operatorname{num} r$ and $\operatorname{den} r$ for its numerator and (positive) denominator in lowest terms. Given $P \in E_N(\mathbb{Q}) \setminus \{O\}$ and $n \geq 1$ with $nP \neq O$, the *denominator sequence* of $P$ is
$$D_n(P) = \operatorname{den} x(nP), \qquad n = 1, 2, 3, \dots$$

These integers are the natural elliptic analogue of the denominators appearing in the classical theory of divisibility sequences, and their prime support is a delicate arithmetic invariant.

### 1.2 The conjecture and why it is attractive

Suppose $N = pq$ is a product of two distinct odd primes. Then the bad primes of $E_N$ are precisely $2, 3, p, q$. Both prime factors of $N$ are thus encoded in the geometry of the curve, which makes the following statement natural to guess.

> **Conjecture (Only bad primes).** For $N = pq$ and $P \in E_N(\mathbb{Q})$, every prime dividing $D_n(P)$ lies in $\{2,3,p,q\}$.

Were it true, the algorithmic consequence would be immediate and dramatic: compute $D_2(P)$ for any convenient rational point, strip the powers of $2$ and $3$, and read off $p$ and $q$. This would place integer factorization in polynomial time, since one doubling of a rational point costs a bounded number of integer multiplications.

### 1.3 Results

We disprove the conjecture and replace it by a sharp structural description. Throughout, "the doubling orbit of $P$" means the sequence $\{2^kP\}_{k \geq 0}$.

1. **(Local law, Theorem 3.1)** For $\ell \geq 5$ prime with $\ell \nmid N$, $\ell \mid \operatorname{den} x(P)$ if and only if $P$ reduces to the identity of $E_N(\mathbb{F}_\ell)$. Hence $\ell \mid D_n(P)$ if and only if $\operatorname{ord}(\bar{P}) \mid n$, where $\bar P$ is the reduction of $P$.

2. **(Refutation, Theorem 4.1)** For $N = 55$ and $P = (9,28)$ one has $x(2P) = 2601/3136$ with $3136 = 2^6 \cdot 7^2$, while $7 \nmid \Delta = -1306800$. The conjecture is false.

3. **(Unbounded family, Theorem 5.4)** For every prime $\ell \geq 5$, every $t \geq 1$ and $N = N(\ell,t) = 4\ell^2t^2 - 1$, the point $P = (1, 2\ell t)$ lies on $E_N$, the curve has good reduction at $\ell$, $\ell \mid \operatorname{den} x(2P)$, and no prime factor of $N$ divides $\operatorname{den} x(2P)$. The moduli $N(\ell,t)$ are odd, factor nontrivially as $(2\ell t - 1)(2\ell t + 1)$, and are unbounded in $t$.

4. **(Singular-locus law, Theorem 6.4)** Let $p \neq 2$ be a prime dividing $N$ and let $P = (x,y) \in E_N(\mathbb{Q})$ with $y \neq 0$. If $p \mid \operatorname{den} x(2P)$ then $p \mid \operatorname{den} x(P)$, or $p$ divides both $\operatorname{num} x$ and $\operatorname{num} y$, i.e. $P$ reduces modulo $p$ to the singular point $(0,0)$ of $y^2 = x^3$.

5. **(Anti-factoring theorem, Theorem 7.3 and Corollary 7.4)** Let $N$ be odd and let $P \in E_N(\mathbb{Q})$ have $\operatorname{num} x(P)$ and $\operatorname{den} x(P)$ coprime to $N$. Then all $x$-numerators and $x$-denominators along the doubling orbit of $P$ are coprime to $N$; in particular no prime factor of $N$ divides any $\operatorname{den} x(2^kP)$. If $N$ is in addition squarefree, the hypothesis on $P$ is automatic for every integral point.

Results 4 and 5 are the substance of the paper. They explain, and upgrade to theorems, the empirical observation that a denominator oracle appears blind to the factorization of $N$.

---

## 2. Setup: the coprime parametrization and the duplication formula

### 2.1 Coprime coordinates

**Lemma 2.1 (Coprime parametrization).** *Let $P = (x,y) \in E_N(\mathbb{Q})$ be an affine point. Then there are integers $a, b$ and a positive integer $e$ with*
$$x = \frac{a}{e^2}, \qquad y = \frac{b}{e^3}, \qquad \gcd(a, e) = \gcd(b,e) = 1,$$
*and consequently*
$$b^2 = a^3 + N e^6 .$$
*In particular $\operatorname{den} x(P) = e^2$ is a perfect square, $\operatorname{den} y(P) = e^3$, $a = \operatorname{num} x(P)$ and $b = \operatorname{num} y(P)$.*

*Proof sketch.* Write $x = a/u$ and $y = b/v$ in lowest terms. Clearing denominators in $y^2 = x^3 + N$ yields $b^2 u^3 = v^2(a^3 + Nu^3)$. Comparing the exact power of each prime $\ell$ dividing $u$ or $v$ forces $3 v_\ell(u) = 2 v_\ell(v)$, so $v_\ell(u)$ is even and $v_\ell(v) = \tfrac32 v_\ell(u)$; writing $e^2 = u$ gives $v = e^3$. Substituting back gives $b^2 = a^3 + Ne^6$. $\square$

We refer to $(a, b, e)$ as the *coprime coordinates* of $P$ and freely use $e^2 = \operatorname{den} x(P)$.

### 2.2 Duplication

**Lemma 2.2 (Duplication formula).** *Let $P = (x,y) \in E_N(\mathbb{Q})$ with $y \neq 0$. Then*
$$x(2P) = \frac{x^4 - 8Nx}{4y^2},$$
*and in coprime coordinates*
$$x(2P) = \frac{a\,(a^3 - 8Ne^6)}{4\,b^2 e^2}. \tag{2.1}$$

*Proof sketch.* The tangent at $P$ has slope $\lambda = 3x^2/(2y)$, and $x(2P) = \lambda^2 - 2x$. Substituting $y^2 = x^3 + N$ and simplifying gives $x(2P) = (x^4 - 8Nx)/(4y^2)$. Replacing $x = a/e^2$, $y = b/e^3$ and clearing common factors of $e$ yields (2.1). $\square$

The identity (2.1) is *not* asserted to be in lowest terms; the whole of Sections 6 and 7 consists of controlling the cancellation.

**Lemma 2.3 (Integral bookkeeping for doubling).** *With the notation above,*
$$\operatorname{den} x(2P) \;\Big|\; 4\,b^2\,e^2 \qquad\text{and}\qquad \operatorname{num} x(2P) \;\Big|\; a\,\bigl(a^3 - 8N e^6\bigr).$$
*Equivalently, writing $D = \operatorname{den} x(P) = e^2$, the denominator of $x(2P)$ divides $4\,\operatorname{num}(y)^2 D$ and its numerator divides $\operatorname{num}(x)\bigl(\operatorname{num}(x)^3 - 8N D^3\bigr)$.*

*Proof sketch.* If a rational number is written as $A/B$ with $B \neq 0$, then its reduced denominator divides $B$ and its reduced numerator divides $A$. Apply this to (2.1) with $A = a(a^3 - 8Ne^6)$ and $B = 4b^2e^2$, and use $e^6 = D^3$, $e^2 = D$ to rewrite. $\square$

Lemma 2.3 is the engine of the paper: it says that *every prime of $\operatorname{den} x(2P)$ divides $2be$*. Whatever primes appear after doubling must already be visible in the numerator of $y$, the denominator of $x$, or the prime $2$.

---

## 3. The local law: which primes appear, and when

Let $\ell \geq 5$ be a prime with $\ell \nmid N$, so that $E_N$ has good reduction at $\ell$ and $\ell \nmid \Delta$. Reduction modulo $\ell$ gives a group homomorphism
$$\rho_\ell : E_N(\mathbb{Q}) \longrightarrow E_N(\mathbb{F}_\ell),$$
defined on all of $E_N(\mathbb{Q})$ once one works with the projective model; its kernel is the *kernel of reduction* $E_1(\mathbb{Q}_\ell) \cap E_N(\mathbb{Q})$.

**Theorem 3.1 (Local law).** *Let $\ell \geq 5$ be a prime with $\ell \nmid N$ and let $P \in E_N(\mathbb{Q})$ be affine with coprime coordinates $(a,b,e)$. Then*
$$\ell \mid \operatorname{den} x(P) \iff \ell \mid e \iff \rho_\ell(P) = O .$$
*Consequently, if $P$ has integral coordinates and $\bar P = \rho_\ell(P)$ has order $m$ in $E_N(\mathbb{F}_\ell)$, then for all $n \geq 1$*
$$\ell \mid D_n(P) \iff m \mid n .$$

*Proof sketch.* The first equivalence is Lemma 2.1. For the second: in projective coordinates $P = (a e : b : e^3)$, and reduction sends $P$ to $O = (0:1:0)$ exactly when $\ell \mid e$ (using $\gcd(b,e)=1$, so $b$ is a unit mod $\ell$). For the consequence, $\rho_\ell$ is a group homomorphism because $\ell$ is a prime of good reduction, whence $\rho_\ell(nP) = n\bar{P}$; and $n\bar P = O$ iff $m \mid n$. $\square$

Two structural consequences deserve emphasis.

**Corollary 3.2 (Good primes are generic).** *Fix an integral point $P$ of infinite order. For every prime $\ell \geq 5$ of good reduction, $\ell$ divides $D_n(P)$ for infinitely many $n$ — namely all multiples of $\operatorname{ord}(\bar P)$ — unless $\bar P = O$ already, in which case $\ell \mid D_n(P)$ for all $n$. In particular the union over $n$ of the prime supports of $D_n(P)$ contains all but finitely many primes for which $\bar P \neq O$ never fails, and is in any case infinite.*

*Proof sketch.* Immediate from Theorem 3.1, since $E_N(\mathbb{F}_\ell)$ is finite so $\operatorname{ord}(\bar P)$ is finite; infinitude of the total support follows from the growth of the denominators, $\log D_n(P) \sim 2 \hat h(P) n^2$ by the theory of canonical heights, which cannot be sustained by a finite set of primes together with bounded exponents. $\square$

**Corollary 3.3 (The conjecture cannot survive).** *The condition "$\ell$ divides some $D_n(P)$" is a condition on the reduction of $P$ modulo $\ell$ and is entirely insensitive to whether $\ell$ divides $\Delta$. There is no mechanism by which the bad primes could monopolize the denominator support.*

Theorem 3.1 thus reframes the question. The denominator sequence is a record of *when a point's shadow in a finite field hits the identity*, which is a codimension-one event happening for every prime, good or bad — subject only to whether the point can reach the identity at all. Sections 6 and 7 show that at bad primes it usually cannot.

---

## 4. The counterexample

**Theorem 4.1 (Refutation of the conjecture).** *Let $N = 55 = 5 \cdot 11$ and $P = (9,28) \in E_{55}(\mathbb{Q})$. Then*
$$x(2P) = \frac{9^4 - 8\cdot 55\cdot 9}{4\,(9^3+55)} = \frac{2601}{3136}, \qquad 3136 = 2^6\cdot 7^2 ,$$
*so $7 \mid \operatorname{den} x(2P)$ while $7 \nmid \Delta(E_{55}) = -432\cdot 55^2 = -1306800$. The prime $7$ is a prime of good reduction. Hence the "only bad primes" conjecture is false.*

*Proof.* $28^2 = 784 = 729 + 55$, so $P \in E_{55}(\mathbb{Q})$ and $y \neq 0$. By Lemma 2.2, $x(2P) = (6561 - 3960)/(4\cdot 784) = 2601/3136$; the fraction is reduced because $2601 = 3^2\cdot 17^2$ is odd and not divisible by $7$. Finally $-1306800 = -2^4\cdot3^3\cdot5^2\cdot11^2$, which is prime to $7$. $\square$

Theorem 3.1 explains the appearance of $7$: the group $E_{55}(\mathbb{F}_7)$ has order $4$ and $\overline{(9,28)} = (2,0)$ has order $2$, so $7$ must divide $D_n$ for every even $n$. The higher terms are equally transparent:

| $n$ | $D_n(P)$ | prime support | orders modulo the good primes |
|---|---|---|---|
| $1$ | $1$ | — | — |
| $2$ | $3136 = 2^6\cdot7^2$ | $2, 7$ | $\operatorname{ord}_7 \bar P = 2$ |
| $3$ | $3^6\cdot13^2\cdot73^2$ | $3, 13, 73$ | $\operatorname{ord}_{13}\bar P = \operatorname{ord}_{73}\bar P = 3$ |
| $4$ | $2^8\cdot7^2\cdot827^2\cdot1583^2$ | $2,7,827,1583$ | $\operatorname{ord}_{827}\bar P = \operatorname{ord}_{1583}\bar P = 4$ |
| $5$ | $5^2\cdot 1785401475301^2$ | $5$, one $13$-digit prime | order $5$ |

The last row is worth pausing on. The bad prime $5$ *does* eventually occur — at index $n = 5$. This is not an accident and is discussed in Section 8: at a bad prime $p$ the non-singular locus of the reduced curve $y^2 = x^3$ is isomorphic to the additive group $(\mathbb{F}_p, +)$, on which multiplication by $n$ is injective precisely when $p \nmid n$. Bad primes are therefore confined to indices divisible by themselves — invisible to any orbit whose indices are coprime to $N$, and useless as a factoring signal since locating them presupposes knowing $p$.

---

## 5. An unbounded, semiprime-shaped family of violations

A single counterexample refutes a conjecture but does not measure how badly it fails. We now exhibit a two-parameter family of violations that is unbounded, semiprime-shaped, and in which the conjecture fails *maximally*: the good prime appears and both intended bad primes are absent.

**Definition 5.1.** For integers $\ell, t \geq 1$ set
$$N(\ell,t) = 4\ell^2t^2 - 1, \qquad Y(\ell,t) = 2\ell t, \qquad P_{\ell,t} = (1, \, Y(\ell,t)) .$$

**Lemma 5.2 (Shape of the family).** *For all $\ell, t \geq 1$:*
1. $N(\ell,t) = (Y-1)(Y+1)$ *with $Y = 2\ell t$; if $\ell t \geq 1$ then $1 < Y - 1 < Y+1$, so the factorization is nontrivial.*
2. $N(\ell,t)$ *is odd, so $\gcd(2, N) = 1$.*
3. $Y^2 = 1^3 + N(\ell,t)$, *so $P_{\ell,t} \in E_{N(\ell,t)}(\mathbb{Z})$.*
4. *If $\ell \geq 2$ then $\ell \nmid N(\ell,t)$; if moreover $\ell \geq 5$ is prime then $\ell \nmid \Delta(E_{N(\ell,t)}) = -432N^2$, i.e. $E_{N(\ell,t)}$ has good reduction at $\ell$.*
5. *For fixed $\ell \geq 5$, $N(\ell,t) \to \infty$ as $t \to \infty$.*

*Proof sketch.* (1)–(3) are the identities $4\ell^2t^2 - 1 = (2\ell t-1)(2\ell t+1)$ and $(2\ell t)^2 = 1 + (4\ell^2t^2-1)$; oddness is clear. For (4), $\ell \mid 4\ell^2t^2$, so $\ell \mid N$ would give $\ell \mid 1$; since $\ell \geq 5$ is prime, $\ell \nmid 432$, and $\ell \nmid N$ gives $\ell \nmid -432N^2$. (5) is clear. $\square$

**Lemma 5.3 (Explicit doubling in the family).** *With $N = N(\ell,t)$ and $P = P_{\ell,t}$,*
$$x(2P) = \frac{1 - 8N}{4(N+1)} = \frac{1 - 8N}{16\,\ell^2 t^2}.$$
*In particular $\operatorname{den} x(2P)$ divides $16\ell^2t^2$, which is coprime to the odd number $N$.*

*Proof sketch.* Lemma 2.2 with $x = 1$, $y^2 = 1 + N$. $\square$

**Theorem 5.4 (Unbounded family of maximal violations).** *Let $\ell \geq 5$ be prime and $t \geq 1$, and put $N = N(\ell,t)$, $P = P_{\ell,t}$. Then:*
1. $N$ *is odd and factors nontrivially as $N = (2\ell t-1)(2\ell t+1)$ with both factors $> 1$;*
2. $E_N$ *has good reduction at $\ell$;*
3. $\ell \mid \operatorname{den} x(2P)$;
4. *no prime factor of $N$ divides $\operatorname{den} x(2P)$: in fact $\gcd(\operatorname{den} x(2P), N) = 1$.*

*Moreover, for every bound $B$ there is $t$ with $N(\ell,t) > B$ satisfying all of the above; so violations exist at arbitrarily large scale, for every good prime $\ell \geq 5$.*

*Proof sketch.* (1) and (2) are Lemma 5.2. For (3), apply the local law in its doubling form: for $\ell \geq 5$ with $\ell \nmid N$, one has $\ell \mid \operatorname{den} x(2P)$ if and only if $\ell \mid \operatorname{num} y(P)$ (this is Theorem 3.1 applied to $2P$, combined with the fact that for an integral point the reduction of $P$ is $2$-torsion modulo $\ell$ exactly when $\ell \mid y$); here $y = 2\ell t$ is divisible by $\ell$ by construction. For (4), apply Theorem 7.1 below with $x = 1$: the numerator $1$ and denominator $1$ of $x(P)$ are trivially coprime to $N$, and $N$ is odd. The unboundedness statement follows from Lemma 5.2(5). $\square$

Choosing $t$ so that $2\ell t \pm 1$ are twin primes produces genuine semiprimes. Three certified instances:

**Example 5.5.** $\ell = 5$, $t = 3$: $N = 899 = 29\cdot31$, $P = (1,30)$,
$$x(2P) = \frac{1 - 7192}{4\cdot 900} = -\frac{799}{400}, \qquad 400 = 2^4\cdot 5^2 .$$
The good prime $5$ divides the denominator; $29$ and $31$ do not.

**Example 5.6.** $\ell = 7$, $t = 3$: $N = 1763 = 41\cdot43$, $P = (1,42)$,
$$x(2P) = \frac{1 - 14104}{4\cdot 1764} = -\frac{1567}{784}, \qquad 784 = 2^4\cdot 7^2 .$$
The good prime $7$ divides the denominator; $41$ and $43$ do not.

**Example 5.7.** $\ell = 11$, $t = 9$: $N = 39203 = 197\cdot199$, $P = (1,198)$,
$$x(2P) = -\frac{34847}{17424}, \qquad 17424 = 2^4\cdot 3^2 \cdot 11^2 .$$
The good prime $11$ divides the denominator; $197$ and $199$ do not.

In every case the denominator's prime support is contained in $\{2,3,\ell\}$ — good primes only — and misses $\{p,q\}$ entirely. Note that whether infinitely many $t$ give twin primes is the twin prime conjecture; Theorem 5.4 is therefore stated with a nontrivial factorization rather than with primality of both factors, and supplemented by explicit genuinely semiprime instances.

---

## 6. The singular-locus law for bad primes

We now turn the question around. Section 3 explains why good primes appear. Why do bad primes not appear?

Modulo a prime $p \mid N$ the reduced curve is $y^2 = x^3$ over $\mathbb{F}_p$, a cuspidal cubic whose unique singular point is $(0,0)$. Its non-singular locus is a group isomorphic to $(\mathbb{F}_p,+)$ via $(x,y) \mapsto x/y$. A rational point of $E_N$ reduces either into this smooth additive group, or onto the cusp, or to the identity.

**Lemma 6.1 (Coprimality transfer from $x$ to $y$).** *Let $P \in E_N(\mathbb{Q})$ have coprime coordinates $(a,b,e)$. If $\gcd(a,N) = 1$ then $\gcd(b, N) = 1$.*

*Proof sketch.* From $b^2 = a^3 + Ne^6$: if $u a^3 + vN = 1$ is a Bézout relation (available because $a^3$ is coprime to $N$), then $u b^2 + (v - u e^6)N = 1$, so $b^2$, hence $b$, is coprime to $N$. $\square$

**Lemma 6.2 (Coprimality transfer under the shift).** *If $\gcd(a,N)=1$ then $\gcd\bigl(a^3 - 8Ne^6, \, N\bigr) = 1$.*

*Proof sketch.* Any common divisor divides $a^3$, and $\gcd(a^3, N) = 1$; concretely from $ua^3 + vN = 1$ one gets $u(a^3 - 8Ne^6) + (v + 8ue^6)N = 1$. $\square$

**Theorem 6.3 (Doubling preserves coprimality to an odd modulus).** *Let $N$ be odd, let $P = (x,y) \in E_N(\mathbb{Q})$ with $y \neq 0$, and suppose $\gcd(\operatorname{num} x, N) = \gcd(\operatorname{den} x, N) = 1$. Then*
$$\gcd\bigl(\operatorname{num} x(2P), N\bigr) = \gcd\bigl(\operatorname{den} x(2P), N\bigr) = 1 .$$

*Proof sketch.* Write $(a,b,e)$ for the coprime coordinates of $P$, so $\gcd(a,N) = \gcd(e^2,N) = 1$. By Lemma 6.1, $\gcd(b,N) = 1$; since $N$ is odd, $\gcd(4,N)=1$; hence $4b^2e^2$ is coprime to $N$. By Lemma 2.3, $\operatorname{den} x(2P)$ divides $4b^2e^2$, so it too is coprime to $N$. For the numerator, Lemma 2.3 gives $\operatorname{num} x(2P) \mid a(a^3 - 8Ne^6)$, and both factors are coprime to $N$ by hypothesis and Lemma 6.2. $\square$

**Theorem 6.4 (Singular-locus law).** *Let $p \neq 2$ be a prime dividing $N$, and let $P = (x,y) \in E_N(\mathbb{Q})$ with $y \neq 0$ and coprime coordinates $(a,b,e)$. If*
$$p \mid \operatorname{den} x(2P),$$
*then either $p \mid \operatorname{den} x(P)$ (equivalently $p \mid e$), or $p \mid a$ and $p \mid b$ — that is, $P$ reduces modulo $p$ to the singular point $(0,0)$ of the cuspidal curve $y^2 = x^3$ over $\mathbb{F}_p$.*

*Proof.* By Lemma 2.3, $p \mid \operatorname{den} x(2P)$ implies $p \mid 4 b^2 e^2$. Since $p$ is an odd prime, $p \nmid 4$, so $p \mid b$ or $p \mid e$. If $p \mid e$ we are in the first alternative. If $p \mid b$, reduce $b^2 = a^3 + Ne^6$ modulo $p$: as $p \mid N$ and $p \mid b$, we get $p \mid a^3$, hence $p \mid a$; so $p$ divides both $a$ and $b$, and $\bar P = (0,0)$. $\square$

The hypothesis $p \neq 2$ cannot be removed: the factor $4$ in the duplication formula places $2$ in the denominator essentially for free, which is why all family statements are made for odd $N$.

**Interpretation.** Good primes enter the denominator through a codimension-one event — the reduction hitting the identity — which occurs periodically in $n$ with period the local order. Bad primes are barred from that route: their identity component is reachable only after the point has already fallen onto the cusp. The two behaviours are governed by different geometry, and Theorem 6.4 makes the asymmetry precise.

---

## 7. The anti-factoring theorem

The remaining ingredient is that on squarefree moduli the escape route of Theorem 6.4 is closed for integral points.

**Lemma 7.0 (Integral points on squarefree moduli).** *Let $N$ be squarefree and let $(x,y) \in \mathbb{Z}^2$ satisfy $y^2 = x^3 + N$. Then $\gcd(x, N) = 1$.*

*Proof.* Suppose a prime $p$ divides both $x$ and $N$. Then $p \mid y^2 = x^3 + N$, so $p \mid y$. Hence $p^2 \mid y^2$ and $p^2 \mid x^3$, so $p^2 \mid y^2 - x^3 = N$, contradicting squarefreeness. $\square$

**Theorem 7.1 (No bad prime after one doubling, squarefree case).** *Let $N$ be squarefree, let $(x,y) \in \mathbb{Z}^2$ with $y^2 = x^3 + N$ and $y \neq 0$, and let $p \neq 2$ be a prime dividing $N$. Then $p \nmid \operatorname{den} x(2P)$.*

*Proof.* By Lemma 7.0, $\gcd(x, N) = 1$. Since $P$ is integral, $\operatorname{den} x(P) = 1$, so $p \nmid \operatorname{den} x(P)$; and $p \nmid \operatorname{num} x(P) = x$ because $\gcd(x,N) = 1$ and $p \mid N$. Both alternatives of Theorem 6.4 are excluded, so $p \nmid \operatorname{den} x(2P)$. $\square$

**Theorem 7.2 (Orbit stability).** *Let $N$ be odd and let $P \in E_N(\mathbb{Q})$ satisfy $\gcd(\operatorname{num} x(P), N) = \gcd(\operatorname{den} x(P), N) = 1$. Then for every $k \geq 0$, if $2^kP$ is affine, its $x$-coordinate again has numerator and denominator coprime to $N$.*

*Proof sketch.* Induction on $k$. The base case is the hypothesis. For the step, write $2^{k+1}P = 2^kP + 2^kP$; if the sum is affine then so is the summand $2^kP$, whose $x$-coordinate is coprime to $N$ in numerator and denominator by the inductive hypothesis, and whose $y$-coordinate is nonzero (otherwise the sum would be $O$). Apply Theorem 6.3. $\square$

**Theorem 7.3 (Anti-factoring theorem).** *Let $N$ be odd and let $P \in E_N(\mathbb{Q})$ have $\operatorname{num} x(P)$ and $\operatorname{den} x(P)$ coprime to $N$. Then for every prime $p \mid N$ and every $k \geq 0$,*
$$p \nmid \operatorname{den} x(2^kP) .$$

*Proof.* By Theorem 7.2 the denominator is coprime to $N$; a prime dividing both it and $N$ would be a unit. $\square$

**Corollary 7.4 (Capstone: integral points on odd squarefree moduli).** *Let $N$ be odd and squarefree — in particular let $N = pq$ be an odd semiprime — and let $P$ be **any** point of $E_N$ with integer coordinates. Then no prime factor of $N$ divides $\operatorname{den} x(2^kP)$, for any $k \geq 0$.*

*Proof.* Lemma 7.0 supplies $\gcd(x(P), N) = 1$; the denominator of $x(P)$ is $1$. Apply Theorem 7.3. $\square$

Corollary 7.4 is the precise converse of the refuted conjecture. The conjecture asserted that the denominators contain *only* the primes $2,3,p,q$; the truth is that along a doubling orbit the denominators contain *never* the primes $p,q$, while containing, over time, a great many good primes.

**Numerical illustration.** For $N = 1763 = 41\cdot 43$ and $P = (1,42)$, the denominators of $x(2^kP)$ for $k = 0,\dots,4$ are
$$1,\quad 784,\quad 2652193144304704,\quad (66\ \text{digits}),\quad (266\ \text{digits}),$$
each coprime to $1763$. For $N = 55$ and $P = (9,28)$ the corresponding denominators $1$, $3136$, $2^8\cdot7^2\cdot827^2\cdot1583^2$, and two further terms of $68$ and $274$ digits, are all coprime to $55$.

---

## 8. Discussion

### 8.1 What a denominator oracle can and cannot see

Combining the results:

- **Good primes are abundant.** By Theorem 3.1 every good prime $\ell \geq 5$ contributes to $D_n(P)$ for all $n$ in an arithmetic progression determined by the local order of $\bar P$. The denominator sequence is essentially a record of local orders.
- **Bad primes are structurally suppressed.** By Theorems 6.4 and 7.3, along a doubling orbit a bad prime cannot appear at all when $N$ is odd and the starting point is $N$-integral in the relevant sense.
- **Therefore the sequence is a function of $N$ that does not reveal the factorization of $N$.** This is a genuine barrier statement: it says that no amount of computation of $D_{2^k}(P)$, however deep, produces a factor.

The empirical picture matches exactly. In a survey of eleven semiprime moduli with integral base points, the conjectural support condition ("every denominator prime lies in $\{2,3,p,q\}$") held in $0\%$ of cases; the smaller prime factor $p$ appeared in some denominator about half the time ($54.5\%$ in the survey sample), and the larger factor $q$ never appeared. In an independently generated sample of eleven odd semiprimes with different base points, the corresponding figures were $81.8\%$, $9.1\%$ and $0\%$: the details of which bad prime is visible depend on the point and on the index range, but the conjecture fails universally, and the visible bad primes always occur at indices $n$ divisible by that prime.

### 8.2 Why bad primes surface at index $n = p$

On $E_{55}$ with $P = (9,28)$ the bad prime $5$ appears in $D_5(P) = 5^2\cdot 1785401475301^2$. The mechanism is the structure of the reduced curve at a bad prime. For $p \mid N$ the reduction is the cuspidal cubic $y^2 = x^3$, whose non-singular locus $E_{\mathrm{ns}}(\mathbb{F}_p)$ is isomorphic to $(\mathbb{F}_p, +)$ under $(x,y) \mapsto t = x/y$. Multiplication by $n$ on $(\mathbb{F}_p,+)$ is multiplication by the scalar $n$, injective if and only if $p \nmid n$. So a point whose reduction lies in the smooth locus can only be killed at indices divisible by $p$. For $n = 2^k$ and odd $p$ this never happens, which is Corollary 7.4 seen from the local side. Conversely, at $n = p$ the bad prime is *forced* to appear whenever the reduction lies in the smooth locus and is nonzero — exactly the observation for $5 \mid D_5$.

As a factoring strategy this is worthless: to look at index $n = p$ one must already know $p$, and computing $D_p(P)$ costs $\Theta(p^2)$ digits of output by the canonical-height growth $\log D_n(P) \sim 2\hat h(P)\,n^2$.

### 8.3 Comparison with Lenstra's elliptic curve method

It is instructive to contrast the refuted approach with the elliptic curve method (ECM), which genuinely does factor integers using elliptic curves. ECM differs in three decisive ways.

1. **It works modulo $N$, not over $\mathbb{Q}$.** ECM performs the group law in $\mathbb{Z}/N\mathbb{Z}$, treating it as if it were a field; a factor is discovered when a modular inverse fails, i.e. when a denominator shares a factor with $N$. There is no reduced rational fraction anywhere, so Lemma 2.3 does not apply.
2. **It randomizes the curve.** ECM tries many curves $y^2 = x^3 + ax + b$ chosen so that the group order modulo $p$ varies and is occasionally smooth. Here the curve is rigidly tied to $N$; there is no smoothness lottery to win.
3. **It exploits the good reduction group at $p$.** For ECM the target prime $p$ is a prime of *good* reduction of the random curve, so the group modulo $p$ has order about $p$ and can be reached by smooth multipliers. On $E_N$ with $p \mid N$, the prime $p$ is bad, its smooth locus is additive of order exactly $p$, and reaching the identity requires index divisible by $p$: the very structure that ECM exploits is destroyed.

In short, the failure documented here is not a failure of elliptic curves as a factoring tool; it is a failure of the specific idea that arithmetic performed *honestly over $\mathbb{Q}$ on the canonical curve of $N$* can localize the factors.

### 8.4 Positive content

Beyond the barrier statement, the results have positive uses.

- **Certified denominator-prime prediction.** Theorem 3.1 converts the question "does $\ell$ divide $D_n(P)$?" into a finite-field computation costing $O(\log \ell)$ group operations after a point count, instead of an exact rational computation with $\Theta(n^2)$-digit numbers. This is an exponential-to-polynomial speedup for the prediction problem.
- **Counterexample generation on demand.** Theorem 5.4 yields, for any target good prime $\ell$ and any size, a semiprime-shaped modulus whose doubled denominator is divisible by $\ell$ and coprime to the modulus. This is a useful stress-test generator for conjectures about denominator support.
- **A clean statement of the invariance.** Theorem 7.3 shows the doubling-orbit denominator sequence takes values in the $N$-units. Any invariant extracted from it is a function of $N$ and of the local orders at good primes, never of the splitting of $N$.

---

## 9. Algorithms

Three algorithms encapsulate the computational content.

### 9.1 Exact rational orbit computation

**Input:** $N$, an affine point $P = (x_0,y_0) \in E_N(\mathbb{Q})$, a bound $n_{\max}$.
**Output:** the denominators $D_n(P)$ for $n \le n_{\max}$.

Perform chord-and-tangent arithmetic in exact rational arithmetic. The cost is dominated by the size of the numbers: $\log D_n \sim 2\hat h(P)n^2$, so computing $D_n$ takes $\tilde{O}(n^2)$ bit operations per step and $\tilde O(n^3)$ overall, with output of $\Theta(n^2)$ digits. This is the honest but expensive route.

### 9.2 Local prediction of denominator primes

**Input:** $N$, an integral point $P$, a prime $\ell \geq 5$ with $\ell \nmid N$.
**Output:** the set $\{n : \ell \mid D_n(P)\}$, as an arithmetic progression.

Reduce $P$ modulo $\ell$ and compute the order $m$ of $\bar P$ in $E_N(\mathbb{F}_\ell)$ — by baby-step/giant-step or by factoring the group order obtained from point counting. By Theorem 3.1 the answer is $m\mathbb{Z}_{>0}$. Cost: $\tilde O(\sqrt{\ell})$ elementary field operations, versus $\Theta(m^2)$ digits for the naive rational route.

### 9.3 Counterexample family generator

**Input:** a prime $\ell \geq 5$, a size bound $B$.
**Output:** an odd modulus $N > B$ with a nontrivial two-factor factorization, an integral point $P$, and the exact value of $x(2P)$ witnessing $\ell \mid \operatorname{den} x(2P)$ and $\gcd(\operatorname{den} x(2P), N) = 1$.

Choose $t$ with $4\ell^2t^2 - 1 > B$ (optionally search $t$ so that $2\ell t \pm 1$ are both prime, giving a genuine semiprime), set $N = 4\ell^2t^2-1$, $P = (1,2\ell t)$, and return $x(2P) = (1-8N)/(4(N+1))$. Cost: $O(\log B)$ arithmetic operations, plus primality tests if twin factors are required.

---

## 10. Future work

The following conjectures are the natural continuations.

**C1 (the $n$-coprime anti-factoring law).** Let $N$ be odd and squarefree, $P$ an integral point of $E_N$, and $n \geq 1$ with $\gcd(n,N) = 1$. Then $\gcd(D_n(P), N) = 1$; conversely, for each prime $p \mid N$ there are points $P$ with $p \mid D_p(P)$. The mechanism is the additive structure of the smooth locus at a bad prime described in §8.2; the case $n = 2^k$ is Corollary 7.4, and the observed $5 \mid D_5$ on $E_{55}$ is the predicted converse. Proving C1 requires only the additivity of $t = x/y$ modulo $p$ on the cuspidal locus, which in coprime coordinates is a polynomial congruence identity.

**C2 (the denominator filtration is a group filtration).** For a prime $\ell \geq 5$ with $\ell \nmid N$ and $m \geq 1$, the set $E_m(\ell) = \{O\} \cup \{P : \ell^{2m} \mid \operatorname{den} x(P)\}$ should be a subgroup of $E_N(\mathbb{Q})$, with $v(P+Q) \geq \min(v(P), v(Q))$ for $v(P) = \tfrac12 v_\ell(\operatorname{den} x(P))$. Then $d(P,Q) = \ell^{-v(P-Q)}$ is an ultrametric making $E_N(\mathbb{Q})$ a non-archimedean topological group. The chord identity $x_1x_2x_3 = \nu^2 - N$ for a line $y = \lambda x + \nu$ converts the subgroup property into a valuation computation on $\nu$, avoiding the full formal-group machinery.

**C3 (a Zsygmondy law for Mordell denominators).** For every non-torsion integral point $P$ of $E_N$ with $N$ squarefree there should be $n_0$ such that for all $n \geq n_0$ the denominator $D_n(P)$ has a *primitive* prime divisor $\ell$, one dividing no earlier $D_m(P)$ with $1 \leq m < n$; and every such primitive prime is a prime of good reduction once $n$ is large. Primitivity plus the singular-locus law forces the new prime to be good, since bad primes are confined to the finitely many indices divisible by a factor of $N$.

**C4 (quantitative support).** Estimate $\#\{\ell \leq X : \ell \mid D_n(P) \text{ for some } n \leq n_{\max}\}$. Theorem 3.1 reduces this to the distribution of local orders in $E_N(\mathbb{F}_\ell)$, an Artin-type problem for elliptic curves.

---

## 11. Conclusion

The "only bad primes" conjecture is false in the strongest sense available: not only do good primes appear in the denominators of $x(nP)$ on $E_N : y^2 = x^3 + N$ — as the witness $N = 55$, $P = (9,28)$, $x(2P) = 2601/3136 = 2601/(2^6\cdot 7^2)$ shows — but there is an unbounded, semiprime-shaped family of moduli on which the doubled denominator is divisible by a prescribed good prime and by no prime factor of the modulus at all. The explanation is a local law: a good prime divides a denominator exactly when the point reduces to the identity in the corresponding finite group.

The converse question turns out to have a sharper answer. A bad prime can enter a doubled denominator only through the singular point of the reduced cuspidal curve, and on odd squarefree moduli no integral point ever reaches it. Consequently the denominators along a doubling orbit are coprime to $N$ forever. The denominator sequence of a Mordell curve is a rich record of the curve's local behaviour at good primes and a provably empty record of its factorization.

---

## Appendix: reference data

**$E_{55}$, $P = (9,28)$.** $\Delta = -1306800 = -2^4\cdot3^3\cdot5^2\cdot11^2$. Denominators:
$$D_1 = 1,\quad D_2 = 2^6\cdot7^2, \quad D_3 = 3^6\cdot13^2\cdot73^2, \quad D_4 = 2^8\cdot7^2\cdot827^2\cdot1583^2, \quad D_5 = 5^2\cdot1785401475301^2 .$$
Local orders of $\bar P$: $2$ at $\ell = 7$ (group order $4$), $3$ at $\ell = 13$ (group order $9$) and at $\ell = 73$ (group order $81$), $4$ at $\ell = 827$ and $\ell = 1583$ (group orders $828$, $1584$), $6$ at $\ell=17$, $9$ at $\ell=19$, $7$ at $\ell=43$.

**Family instances.**

| $\ell$ | $t$ | $N = 4\ell^2t^2-1$ | factorization | $x(2P)$ | $\operatorname{den} x(2P)$ |
|---|---|---|---|---|---|
| $5$ | $3$ | $899$ | $29\cdot31$ (twin primes) | $-799/400$ | $2^4\cdot5^2$ |
| $7$ | $3$ | $1763$ | $41\cdot43$ (twin primes) | $-1567/784$ | $2^4\cdot7^2$ |
| $5$ | $6$ | $3599$ | $59\cdot61$ (twin primes) | $-3199/1600$ | $2^6\cdot5^2$ |
| $11$ | $9$ | $39203$ | $197\cdot199$ (twin primes) | $-34847/17424$ | $2^4\cdot3^2\cdot11^2$ |
| $17$ | $30$ | $1040399$ | $1019\cdot1021$ (twin primes) | — | $2^6\cdot5^2\cdot17^2$ |

In every row the denominator is coprime to $N$ and divisible by $\ell$.
