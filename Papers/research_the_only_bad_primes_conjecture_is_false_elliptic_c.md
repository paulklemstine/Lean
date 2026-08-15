# Good Primes in Bad Places: Denominators of Multiples of Integral Points on Mordell Curves

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

Let $N$ be a nonzero integer and let $E_N$ denote the Mordell curve
$$E_N : y^2 = x^3 + N,$$
whose discriminant is $\Delta = -432N^2$, so that the primes of bad reduction of $E_N$ lie in $\{2,3\} \cup \{\ell : \ell \mid N\}$. A folklore expectation — attractive because it would turn the arithmetic of $E_N$ into a factoring oracle for $N$ — asserts that, for $P$ an integral point of $E_N$ and $n \geq 2$, the denominator of the $x$-coordinate of $nP$ is divisible only by the primes of bad reduction; for $N = pq$ a semiprime this would mean only $2, 3, p, q$ can occur. We call this the **"only bad primes" conjecture**, and we prove that it is false, at every level of the multiplication tower, and in the strongest possible sense.

The smallest counterexample we exhibit is $N = 55 = 5 \cdot 11$ with the integral point $P = (9,28)$: one has
$$x(2P) = \frac{9^4 - 8 \cdot 55 \cdot 9}{4(9^3+55)} = \frac{2601}{3136}, \qquad 3136 = 2^6 \cdot 7^2,$$
and $7$ is a prime of *good* reduction, since $7 \nmid \Delta = -1306800$.

We then explain the phenomenon completely. Our **mechanism theorem** states that for an integral point $(x,y)$ with $y \neq 0$ and a prime $\ell \nmid 6N$,
$$\ell \mid \operatorname{den} x(2P) \iff \ell \mid y \iff 2\bar P = O \text{ in } E_N(\mathbb{F}_\ell),$$
and, sharply, $v_\ell(\operatorname{den} x(2P)) = 2\,v_\ell(y)$. The analogous statement at $n=3$ replaces $y = \tfrac12 \psi_2(P)$ by the third division polynomial $\psi_3(P) = 3x^4 + 12Nx$ and $2$-torsion by $3$-torsion. Thus the primes appearing in denominators are the primes at which $P$ reduces into torsion — a property of the *point*, not of the discriminant. Since a good prime is not forbidden from doing this, and indeed can be forced to do it, the conjecture never had a chance.

We prove three universality statements: every prime $\ell \geq 5$ occurs as an extraneous (good-reduction) prime in some denominator; arbitrarily many extraneous primes can occur in a single denominator; and infinitely many $N$ admit such a failure. Along the doubling tower we prove a sharp **dichotomy**: at an odd good prime the denominator exponent is *frozen*, $v_\ell(\operatorname{den} x(2^{k}P)) = 2v_\ell(y)$ for all $k \geq 1$, while at the bad prime $2$ it grows linearly, gaining exactly $2$ per doubling. Finally, we replace the false conjecture with a true one: every prime dividing $\operatorname{den} x(2P)$ divides $2y$, and in fact $\operatorname{den} x(2P) \mid 4y^2$.

A consequence for the "elliptic curves as factoring oracles" heuristic: the denominator of $x(nP)$ is determined by the value of a division polynomial at $P$; it neither excludes good primes nor reliably exhibits the factors of $N$. In a survey of semiprimes $N=pq$ with integral points, the "only bad primes" property failed in *every* case, while the larger prime factor $q$ never appeared at all.

**Keywords:** Mordell curve, elliptic curve, division polynomial, denominator, good reduction, elliptic divisibility sequence, torsion, integral point.

---

## 1. Introduction

### 1.1 The lure of the discriminant

Write a rational number $r$ in lowest terms as $a/b$ with $b > 0$ and $\gcd(a,b)=1$, and call $b = \operatorname{den}(r)$ its denominator. If $P$ is a rational point on an elliptic curve $E/\mathbb{Q}$ in Weierstrass form, the denominators of $x(nP)$ grow rapidly with $n$, and their prime factorisations encode a great deal of arithmetic. The sequence of "denominator square roots" is the classical elliptic divisibility sequence, and its divisibility properties are the engine behind Lenstra's elliptic curve factorisation method.

That last connection is seductive. Lenstra's method works because an elliptic curve over $\mathbb{Z}/N\mathbb{Z}$ can "fall apart" modulo one prime factor of $N$ before another. It is therefore tempting to believe that the denominators themselves *see* the factorisation: that for the Mordell curve
$$E_N : y^2 = x^3 + N,$$
whose discriminant is $\Delta = -432N^2$ and whose bad primes therefore lie in $\{2,3\} \cup \{\ell : \ell \mid N\}$, the primes appearing in the denominators of $x(nP)$ should be exactly the bad primes. For $N=pq$ a semiprime, this would say only $2, 3, p$ and $q$ can occur — and a single doubling of an integral point would hand you the factorisation of $N$.

This paper shows that expectation is false, identifies exactly what governs denominators instead, and shows that the failure is universal rather than sporadic.

### 1.2 Statement of the conjecture and its refutation

> **The "only bad primes" conjecture.** Let $p,q$ be primes, $N = pq$, and let $(x,y) \in \mathbb{Z}^2$ satisfy $y^2 = x^3 + N$. Then every prime dividing $\operatorname{den}\big(x(nP)\big)$ lies in $\{2,3,p,q\}$.

We refute it at $n = 2$, at $n = 3$, and along the whole doubling tower $n = 2^k$.

**Theorem A (refutation at $n=2$).** *The conjecture is false. For $N = 55 = 5 \cdot 11$ and $P = (9,28) \in E_{55}(\mathbb{Q})$,*
$$x(2P) = \frac{2601}{3136}, \qquad 3136 = 2^6 \cdot 7^2,$$
*so the prime $7$ divides the denominator, yet $7 \nmid \Delta = -432 \cdot 55^2$, i.e. $7$ is a prime of good reduction and $7 \notin \{2,3,5,11\}$.*

A second, structurally motivated counterexample uses twin primes: $N = 899 = 29 \cdot 31$ with $P = (1,30)$ gives $x(2P) = -799/400$ with $400 = 2^4 \cdot 5^2$, and $5$ is again a good prime outside $\{2,3,29,31\}$. This one comes from the identity $25m^2 - 1 = (5m-1)(5m+1)$, which produces semiprimes $N$ with the integral point $(1,5m)$ for free.

### 1.3 What actually controls the denominators

The counterexamples are not accidents; they are instances of a clean equivalence.

**Theorem B (mechanism theorem).** *Let $(x,y) \in \mathbb{Z}^2$ satisfy $y^2 = x^3 + N$ with $y \neq 0$, and let $\ell$ be a prime with $\ell \nmid 6N$ (equivalently $\ell \nmid \Delta$, a prime of good reduction). Then*
$$\ell \mid \operatorname{den}\big(x(2P)\big) \iff \ell \mid y.$$

Since $2y$ is the second division polynomial $\psi_2$ evaluated at $P$, and since $\ell \mid y$ says exactly that the reduction $\bar P \in E_N(\mathbb{F}_\ell)$ has order dividing $2$, Theorem B has a purely geometric restatement.

**Theorem C (reduction/torsion bridge).** *Under the hypotheses of Theorem B, with $\bar P$ the reduction of $P$ in $E_N(\mathbb{F}_\ell)$,*
$$\ell \mid \operatorname{den}\big(x(2P)\big) \iff \bar P + \bar P = O \text{ in } E_N(\mathbb{F}_\ell).$$

So a prime shows up in the denominator of $x(2P)$ precisely when doubling pushes the reduced point to the origin — that is, when $2P$ lands in the kernel of reduction, the formal group at $\ell$. Nothing in that condition mentions the discriminant. A good prime is perfectly free to satisfy it, and a curve can be engineered so that it must.

### 1.4 Universality of the failure

**Theorem D (no prime is excluded).** *Let $\ell \geq 5$ be prime and $m \geq 1$. Put $N = \ell^2m^2 - 1$ and $P = (1, \ell m)$, an integral point of $E_N$. Then $\ell \nmid 6N$ — so $\ell$ is a prime of good reduction — and $\ell \mid \operatorname{den} x(2P)$.*

**Theorem E (arbitrarily many extraneous primes).** *Let $S$ be any finite set of primes $\geq 5$, put $K = \prod_{\ell \in S}\ell$, let $m \geq 1$, $N = K^2m^2-1$ and $P = (1, Km)$. Then every $\ell \in S$ is a prime of good reduction of $E_N$ dividing $\operatorname{den} x(2P)$.*

**Theorem F (infinitely many failures).** *The set of integers $N$ for which some integral point of $E_N$ has a good-reduction prime in the denominator of the $x$-coordinate of its double is infinite; the family $N = 25m^2-1$, $P=(1,5m)$, $\ell = 5$ already witnesses this.*

### 1.5 The repaired statement

The conjecture is not merely false; it is false because it names the wrong object. The correct statement is about the point.

**Theorem G (repaired conjecture).** *Let $(x,y) \in \mathbb{Z}^2$ satisfy $y^2 = x^3+N$. Then $\operatorname{den}\big(x(2P)\big)$ divides $4y^2$; in particular every prime dividing $\operatorname{den}\big(x(2P)\big)$ divides $2y$.*

And sharply:

**Theorem H (exact exponent).** *With $(x,y)$ integral, $y \neq 0$, and $\ell \nmid 6N$ prime,*
$$v_\ell\big(\operatorname{den} x(2P)\big) = 2\,v_\ell(y).$$

### 1.6 Higher $n$ and the tower

At $n=3$ the same picture holds with the third division polynomial $\psi_3 = 3x^4+12Nx$ in place of $\psi_2 = 2y$ (Theorems I–L below), and the extraneous primes *move*: for $N=55$, $P=(9,28)$, the prime $7$ divides $\operatorname{den} x(2P)$ but not $\operatorname{den} x(3P)$, while $13$ and $73$ divide $\operatorname{den} x(3P) = 3^6\cdot 13^2\cdot 73^2$ but not $\operatorname{den} x(2P)$.

Along the doubling tower the behaviour is rigid and splits sharply by prime (Theorems M–P): at an odd prime the denominator exponent never changes after the first doubling, while at $2$ it increases by exactly $2$ each time.

---

## 2. Setup and definitions

Throughout, $N$ is a nonzero integer (occasionally a nonzero element of a field), and
$$E_N : y^2 = x^3 + N$$
is the Mordell curve, the Weierstrass curve with $a_1=a_2=a_3=a_4=0$ and $a_6=N$.

**Definition 2.1 (discriminant and bad primes).** For $E_N$ one computes $b_2 = 0$, $b_4=0$, $b_6=4N$, $b_8=0$, hence
$$\Delta(E_N) = -b_2^2b_8 - 8b_4^3 - 27b_6^2 + 9b_2b_4b_6 = -27 \cdot 16N^2 = -432N^2 .$$
The **bad primes** of $E_N$ are the primes dividing $\Delta$; explicitly, since $432 = 2^4\cdot 3^3$, they form the set
$$\mathcal{B}(N) = \{2,3\} \cup \{\ell \text{ prime}: \ell \mid N\}.$$
Equivalently, a prime $\ell$ lies in $\mathcal B(N)$ if and only if $\ell \mid 432N^2$, if and only if $\ell \mid 6N$.

**Definition 2.2 (nonsingularity).** Over a field $F$ with $2 \neq 0$, $3 \neq 0$ and $N \neq 0$, every point $(x,y)$ with $y^2 = x^3+N$ is a nonsingular point of $E_N$: the partial derivatives of $y^2 - x^3 - N$ are $-3x^2$ and $2y$, and they vanish simultaneously only if $y = 0$ and $x = 0$, forcing $N = 0$.

**Definition 2.3 (denominator).** For $r \in \mathbb{Q}$ written in lowest terms with positive denominator, $\operatorname{den}(r)$ is that denominator, and $v_\ell(r)$ is the $\ell$-adic valuation. One has $v_\ell(r) < 0 \iff \ell \mid \operatorname{den}(r)$, and in that case $v_\ell(r) = -v_\ell(\operatorname{den} r)$.

**Definition 2.4 (duplication value).** For $x \in \mathbb{Q}$ with $x^3 + N \neq 0$, set
$$\operatorname{dbl}_N(x) = \frac{x^4 - 8Nx}{4(x^3+N)} .$$

**Definition 2.5 (division polynomials).** For $E_N$ the first few division polynomials are
$$\psi_1 = 1, \quad \psi_2 = 2y, \quad \psi_3 = 3x^4 + 12Nx, \quad \psi_2\psi_4 = 8y^2\left(x^6 + 20Nx^3 - 8N^2\right).$$

**Definition 2.6 (triplication value).** For $x, y \in \mathbb{Q}$ with $\psi_3 = 3x^4+12Nx \neq 0$, set
$$\operatorname{tri}_N(x,y) = \frac{x\,\psi_3^2 - 8y^2(x^6+20Nx^3-8N^2)}{\psi_3^2} = x - \frac{\psi_2\psi_4}{\psi_3^{2}} .$$

**Definition 2.7 (doubling tower).** $\operatorname{dbl}^0_N(x) = x$ and $\operatorname{dbl}^{k+1}_N(x) = \operatorname{dbl}_N\!\big(\operatorname{dbl}^k_N(x)\big)$.

These closed forms are the classical ones, and they agree with the chord–tangent group law.

**Proposition 2.8 (duplication bridge).** *Let $P = (x,y)$ be a rational point of $E_N$ with $y \neq 0$. Then the chord–tangent group law gives $x(P+P) = \operatorname{dbl}_N(x)$.*

*Proof sketch.* The tangent slope at $P$ is $\lambda = 3x^2/(2y)$, obtained by implicit differentiation of $y^2 = x^3+N$ (this uses $y \neq 0$, i.e. $P$ is not $2$-torsion). The group law gives $x(2P) = \lambda^2 - 2x = \dfrac{9x^4 - 8xy^2}{4y^2}$. Substituting $y^2 = x^3+N$ in the denominator and simplifying the numerator, $9x^4 - 8x(x^3+N) = x^4 - 8Nx$, so $x(2P) = (x^4-8Nx)/(4(x^3+N))$. $\square$

**Proposition 2.9 (triplication bridge).** *Let $P=(x,y)$ be a rational point of $E_N$ with $y \neq 0$ and $\psi_3(P) \neq 0$. Then $2P \neq \pm P$ and $x(3P) = \operatorname{tri}_N(x,y)$.*

*Proof sketch.* A direct computation from Proposition 2.8 gives the identity
$$x - x(2P) = \frac{\psi_3}{4y^2} = \frac{\psi_3}{\psi_2^{2}},$$
so $\psi_3(P)\neq 0$ guarantees $x(2P) \neq x(P)$ and the sum $P + 2P$ is computed by the secant through $P$ and $2P$. Evaluating $\lambda^2 - x - x(2P)$ with $\lambda = \big(y(2P)-y\big)/\big(x(2P)-x\big)$ and clearing denominators yields exactly $x - \psi_2\psi_4/\psi_3^2$. $\square$

---

## 3. The mechanism at $n = 2$

The whole story at $n=2$ rests on one observation: after substituting the curve equation, the duplication formula reads
$$x(2P) = \frac{x^4-8Nx}{4y^2},$$
a quotient of two integers whose denominator is $4y^2$ *before* cancellation. Whether a prime survives cancellation is therefore a question about the numerator.

**Lemma 3.1 (numerator nonvanishing).** *Let $(x,y)\in\mathbb{Z}^2$ with $y^2=x^3+N$, and let $\ell$ be a prime with $\ell\nmid 6N$ and $\ell \mid y$. Then $\ell \nmid x^4 - 8Nx$.*

*Proof.* Suppose $\ell \mid x^4-8Nx = x(x^3-8N)$. From $\ell \mid y$ and $y^2 = x^3+N$ we get $x^3 \equiv -N \pmod \ell$. If $\ell \mid x$ then $N \equiv -x^3 \equiv 0$, contradicting $\ell \nmid N$. Hence $\ell \mid x^3 - 8N \equiv -N-8N = -9N$, so $\ell \mid 9N$, so $\ell \mid 3$ or $\ell \mid N$, contradicting $\ell \nmid 6N$. $\square$

**Theorem 3.2 (Theorem B: mechanism theorem).** *Let $(x,y)\in\mathbb{Z}^2$ with $y^2=x^3+N$ and $y\neq 0$, and let $\ell$ be a prime with $\ell \nmid 6N$. Then*
$$\ell \mid \operatorname{den}\big(\operatorname{dbl}_N(x)\big) \iff \ell \mid y .$$

*Proof.* Write $\operatorname{dbl}_N(x) = A/B$ with $A = x^4-8Nx$ and $B = 4(x^3+N) = 4y^2 \ne 0$.

($\Leftarrow$) If $\ell \mid y$, then $\ell \mid B$ and, by Lemma 3.1, $\ell \nmid A$. In general, if a prime divides the (unreduced) denominator but not the numerator, it survives to the reduced denominator: from $A\cdot \operatorname{den}(A/B) = \operatorname{num}(A/B)\cdot B$ and $\ell \mid B$ we get $\ell \mid A\cdot\operatorname{den}(A/B)$, whence $\ell \mid \operatorname{den}(A/B)$.

($\Rightarrow$) The reduced denominator always divides $B = 4y^2$. So $\ell \mid 4y^2$; as $\ell \nmid 6N$ we have $\ell \neq 2$, hence $\ell \mid y$. $\square$

**Theorem 3.3 (Theorem G: the repaired conjecture).** *For any integral point $(x,y)$ of $E_N$, $\operatorname{den}(\operatorname{dbl}_N(x)) \mid 4y^2$, and every prime $\ell$ dividing $\operatorname{den}(\operatorname{dbl}_N(x))$ divides $2y$.*

*Proof.* The reduced denominator of $A/B$ divides $B = 4(x^3+N) = 4y^2$. If $\ell \mid 4y^2$ then either $\ell \mid 4$, whence $\ell = 2 \mid 2y$, or $\ell \mid y^2$, whence $\ell \mid y \mid 2y$. $\square$

Theorem 3.3 is the honest replacement for the conjecture: the denominator is bounded by the point, not by the discriminant. The bad primes of $E_N$ have nothing to do with it beyond the harmless factor $4$.

**Theorem 3.4 (Theorem H: exact exponent).** *With $(x,y)$ integral on $E_N$, $y\neq 0$, and $\ell \nmid 6N$ prime,*
$$v_\ell\big(\operatorname{den}\operatorname{dbl}_N(x)\big) = 2\,v_\ell(y).$$

*Proof sketch.* If $\ell \nmid y$ then both sides vanish by Theorem 3.2. If $\ell \mid y$, then by Lemma 3.1 the numerator $A$ is prime to $\ell$, while $v_\ell(B) = v_\ell(4y^2) = 2v_\ell(y)$ because $\ell \nmid 4$. Hence $v_\ell(A/B) = -2v_\ell(y) < 0$ and the denominator exponent is $2v_\ell(y)$. $\square$

### 3.1 The reduction-theoretic reading

**Theorem 3.5 (Theorem C: reduction/torsion bridge).** *Let $(x,y)$ be an integral point of $E_N$ with $y \neq 0$, and let $\ell$ be a prime with $\ell \nmid 6N$. Let $\bar P = (\bar x, \bar y) \in E_N(\mathbb{F}_\ell)$ be its reduction, a nonsingular point of the reduced curve. Then*
$$\ell \mid \operatorname{den}\big(\operatorname{dbl}_N(x)\big) \iff \bar P + \bar P = O .$$

*Proof.* Since $\ell \nmid 6N$, the reduced curve $\bar E_N$ over $\mathbb{F}_\ell$ satisfies $2 \neq 0$, $3 \neq 0$, $\bar N \neq 0$, so $\bar P$ is nonsingular (Definition 2.2), and it is a point of $E_N(\mathbb{F}_\ell)$ because reducing $y^2 = x^3+N$ modulo $\ell$ preserves the equation. On the reduced curve, negation is $(\bar x,\bar y)\mapsto(\bar x,-\bar y)$, so $2\bar P = O$ iff $\bar P = -\bar P$ iff $\bar y = -\bar y$ iff $2\bar y = 0$ iff $\bar y = 0$ (as $2 \neq 0$), i.e. iff $\ell \mid y$. Now apply Theorem 3.2. $\square$

This is the conceptual heart of the paper. The denominator of $x(2P)$ detects exactly the primes at which $P$ reduces into the $2$-torsion; equivalently, the primes at which $2P$ lies in the kernel of reduction, the formal group $\hat E(\ell\mathbb{Z}_\ell)$. Bad reduction is irrelevant to that condition. Heuristically, for a fixed non-torsion $P$ the reduced point $\bar P$ has some order $m_\ell$ in the finite group $E_N(\mathbb{F}_\ell)$, and the event $m_\ell \mid 2$ occurs for a thin but nonempty set of primes $\ell$; the conjecture amounts to assuming that this set contains no good prime, which is simply not so.

---

## 4. The counterexamples

**Theorem 4.1 (Theorem A).** *Let $N = 55 = 5\cdot 11$ and $P = (9,28)$, so $28^2 = 784 = 729 + 55 = 9^3 + 55$. Then*
$$x(2P) = \frac{9^4 - 8\cdot 55\cdot 9}{4(9^3+55)} = \frac{6561-3960}{3136} = \frac{2601}{3136},\qquad 3136 = 2^6\cdot 7^2,$$
*and $7 \nmid \Delta = -432\cdot 55^2 = -1306800$ (indeed $-1306800 \equiv 2 \pmod 7$). Thus the prime $7$ of good reduction divides the denominator, and $7 \notin \{2,3,5,11\}$: the "only bad primes" conjecture is false.*

The reduced fraction is genuinely reduced: $2601 = 3^2\cdot 17^2$ is odd and prime to $7$. Consistently with Theorem 3.4: $y = 28 = 2^2\cdot 7$ has $v_7(y) = 1$, and the $7$-exponent of the denominator is $2 = 2\cdot 1$.

**Theorem 4.2 (a twin-prime counterexample).** *Let $N = 899 = 29\cdot 31$ and $P = (1,30)$, so $30^2 = 900 = 1 + 899$. Then $x(2P) = -799/400$ with $400 = 2^4\cdot 5^2$, and $5$ is a prime of good reduction with $5 \notin \{2,3,29,31\}$.*

This example is not found by search; it is manufactured. The identity $25m^2 - 1 = (5m-1)(5m+1)$ makes $N = 25m^2-1$ a product of twin-ish factors, gives the free integral point $(1,5m)$, and guarantees $5 \mid y$ while $5 \nmid 6N$ (since $6N \equiv -6 \not\equiv 0 \bmod 5$). Taking $m=6$ gives $N = 899 = 29\cdot 31$.

**Theorem 4.3 (Theorem F: infinitude).** *Let*
$$\mathcal{F} = \{N \in \mathbb{Z} : \exists\ (x,y)\in\mathbb{Z}^2,\ y^2 = x^3+N,\ \exists\ \ell \text{ prime},\ \ell \nmid 6N,\ \ell \mid \operatorname{den}\operatorname{dbl}_N(x)\}.$$
*Then $\mathcal F$ is infinite: it contains $25m^2-1$ for every $m \geq 1$.*

*Proof.* For $N = 25m^2-1$ and $P = (1,5m)$ we have $y^2 = 25m^2 = 1 + N = x^3+N$. Also $5 \nmid 6N$, because $5 \mid 6(25m^2-1)$ would force $5 \mid 6$. Since $5 \mid y = 5m$ and $y \ne 0$, Theorem 3.2 gives $5 \mid \operatorname{den}\operatorname{dbl}_N(1)$. The map $m \mapsto 25m^2-1$ is injective on positive $m$. $\square$

**Theorem 4.4 (Theorem D: no prime is excluded).** *Let $\ell \geq 5$ be prime and $m \geq 1$. Put $N = \ell^2m^2-1$ and $P = (1,\ell m)$. Then $\ell \nmid 6N$ and $\ell \mid \operatorname{den}\operatorname{dbl}_N(1)$.*

*Proof.* $(1,\ell m)$ is on $E_N$ since $(\ell m)^2 = 1 + N$. If $\ell \mid 6N = 6(\ell^2m^2-1)$, then since $\ell \mid 6\ell^2m^2$ we get $\ell \mid 6$, impossible for $\ell \geq 5$. As $\ell \mid y = \ell m \ne 0$, Theorem 3.2 applies. $\square$

**Theorem 4.5 (Theorem E: unboundedly many extraneous primes).** *Let $S$ be a finite set of primes, each $\geq 5$, let $K = \prod_{\ell\in S}\ell$, let $m\geq 1$, put $N = K^2m^2-1$ and $P = (1,Km)$. Then for every $\ell \in S$: $\ell \nmid 6N$ and $\ell \mid \operatorname{den}\operatorname{dbl}_N(1)$.*

*Proof.* Identical to Theorem 4.4, using $\ell \mid K$: if $\ell \mid 6(K^2m^2-1)$ then, since $\ell \mid 6K^2m^2$, we get $\ell \mid 6$, impossible. And $\ell \mid K \mid y = Km$. $\square$

So the number of good-reduction primes in a single denominator is unbounded. For instance $S = \{5,7,11,13\}$, $K = 5005$, $m=1$ gives $N = 25050024$ and
$$\operatorname{den} x(2P) = 2^2\cdot 5^2\cdot 7^2\cdot 11^2\cdot 13^2,$$
four extraneous primes at once.

---

## 5. The mechanism at $n = 3$

At $n = 3$ the role of $\psi_2 = 2y$ passes to $\psi_3 = 3x^4+12Nx$. Since $\operatorname{tri}_N(x,y)$ is a fraction with denominator $\psi_3^2$ before cancellation, the same two-step analysis applies: identify when a prime divides $\psi_3$, and show that it then misses the numerator.

**Lemma 5.1 (numerator nonvanishing at $n=3$).** *Let $(x,y)$ be integral on $E_N$ and $\ell \nmid 6N$ a prime with $\ell \mid \psi_3(P)$. Then $\ell \nmid \psi_2\psi_4(P) = 8y^2(x^6+20Nx^3-8N^2)$.*

*Proof sketch.* Work on the reduced curve over $\mathbb{F}_\ell$, which is nonsingular because $\ell \nmid 6N$. By Theorem 5.3 below, $\ell \mid \psi_3(P)$ means $\bar P$ has order dividing $3$; since $\bar P \ne O$ (it is an affine point), $\bar P$ has exact order $3$. A point of order $3$ is neither $2$-torsion nor $4$-torsion, so $\psi_2(\bar P) = 2\bar y \ne 0$ and $\psi_4(\bar P)\ne 0$; equivalently, one checks the resultant identity expressing a power of $2^6 3^3 N^3$ as a polynomial combination of $\psi_3$ and $x^6+20Nx^3-8N^2$, which forces $\ell \mid 6N$ if both vanish. $\square$

**Theorem 5.2 (mechanism theorem at $n=3$).** *Let $(x,y)$ be integral on $E_N$ with $\psi_3(P) = 3x^4+12Nx \neq 0$, and let $\ell\nmid 6N$ be prime. Then*
$$\ell \mid \operatorname{den}\big(\operatorname{tri}_N(x,y)\big) \iff \ell \mid x^4+4Nx,$$
*equivalently iff $\ell \mid \psi_3(P)$ (the two conditions agree because $\ell \nmid 3$).*

*Proof sketch.* Write $\operatorname{tri}_N(x,y) = A/\psi_3^2$ with $A = x\psi_3^2 - \psi_2\psi_4$. If $\ell \mid \psi_3$ then Lemma 5.1 gives $\ell \nmid A$, so $\ell$ survives into the reduced denominator, and in fact $v_\ell$ of the denominator is $2v_\ell(\psi_3)$. Conversely the reduced denominator divides $\psi_3^2$, so $\ell$ dividing it forces $\ell \mid \psi_3$. $\square$

**Theorem 5.3 (the third division polynomial cuts out the $3$-torsion).** *Let $F$ be a field with $2 \neq 0$, $3 \neq 0$, let $N \in F^\times$, and let $P = (X,Y)$ be a point of $E_N(F)$. Then*
$$3P = O \iff X^4 + 4NX = 0 .$$

*Proof sketch.* If $Y = 0$ then $P$ is $2$-torsion, so $3P = P \neq O$; and $X^3 = -N$ with $X \ne 0$ gives $X^4+4NX = X(X^3+4N) = 3NX \ne 0$, consistent. If $Y \ne 0$, the identity $X - x(2P) = \psi_3/(4Y^2)$ of Proposition 2.9 shows that $x(2P) = X$ exactly when $\psi_3 = 3(X^4+4NX) = 0$. Now $3P = O$ iff $2P = -P$, which (since $2P$ and $-P$ are affine points here) holds iff $x(2P) = X$ and $y(2P) = -Y$; a short computation shows the $x$-coordinate condition already forces the $y$-coordinate one on this curve. $\square$

**Theorem 5.4 (reduction/torsion bridge at $n=3$).** *Let $(x,y)$ be integral on $E_N$ with $\psi_3(P)\neq0$ and let $\ell \nmid 6N$ be prime, with reduction $\bar P \in E_N(\mathbb{F}_\ell)$. Then*
$$\ell \mid \operatorname{den}\big(\operatorname{tri}_N(x,y)\big) \iff \bar P + \bar P + \bar P = O .$$

*Proof.* Combine Theorem 5.2 with Theorem 5.3 over $F = \mathbb{F}_\ell$, noting $\ell \mid x^4+4Nx$ iff $\bar x^4 + 4\bar N\bar x = 0$. $\square$

### 5.1 The extraneous primes move with $n$

**Theorem 5.5 (counterexample at $n=3$, and the shift).** *For $N=55$ and $P=(9,28)$,*
$$x(3P) = -\frac{2302089191}{656538129}, \qquad 656538129 = 3^6\cdot 13^2\cdot 73^2 .$$
*Both $13$ and $73$ are primes of good reduction ($13, 73 \nmid \Delta = -432\cdot 55^2$) lying outside $\{2,3,5,11\}$, so the conjecture also fails at $n=3$. Moreover the extraneous primes at levels $2$ and $3$ are disjoint here:*
$$7 \mid \operatorname{den}x(2P),\quad 7\nmid \operatorname{den}x(3P), \qquad 13,73 \mid \operatorname{den}x(3P),\quad 13,73 \nmid \operatorname{den}x(2P).$$

The reason is transparent from Theorem 5.2: $\psi_3(P) = 3\cdot 9^4 + 12\cdot 55\cdot 9 = 25623 = 3^3\cdot 13\cdot 73$, and the denominator of $x(3P)$ is exactly $\psi_3(P)^2 = 3^6\cdot13^2\cdot73^2$. The denominator reads off the value of the division polynomial at $P$ — nothing more, nothing less. There is no fixed finite set of primes attached to $N$ that could contain all of them.

**Theorem 5.6 (no prime is excluded at $n=3$).** *For every prime $\ell \geq 5$, take $N = 1-\ell^3$ and the integral point $P = (\ell, 1)$ of $E_N$. Then $\ell \nmid 6N$ and $\ell \mid \operatorname{den}x(3P)$.*

*Proof.* $1^2 = \ell^3 + (1-\ell^3)$, so $P$ is on the curve. If $\ell \mid 6(1-\ell^3)$ then $\ell \mid 6$, impossible for $\ell \ge 5$. Also $\psi_3(P) = 3\ell^4 + 12(1-\ell^3)\ell = \ell(12-9\ell^3) \ne 0$ for $\ell \geq 5$, and $x^4+4Nx = \ell^4 + 4(1-\ell^3)\ell = \ell(\ell^3+4-4\ell^3)$ is divisible by $\ell$. Apply Theorem 5.2. $\square$

---

## 6. The doubling tower: rigidity versus growth

Iterating duplication produces $x(2^kP)$, and one may ask what happens to a good prime once it has entered a denominator. The answer is that it never leaves, and its exponent never changes — while at the prime $2$ the exponent marches upward by exactly $2$ per step.

**Theorem 6.1 (persistence at odd primes).** *Let $\ell \neq 2$ be prime, $N \neq 0$ an integer, and $x \in \mathbb{Q}$ with $v_\ell(x) < 0$. Then $\operatorname{dbl}_N(x) \neq 0$ and*
$$v_\ell\big(\operatorname{dbl}_N(x)\big) = v_\ell(x).$$

*Proof.* Let $v = v_\ell(x) < 0$. Since $N$ is an integer, $v_\ell(8N)\geq 0$ (using $\ell \ne 2$, $v_\ell(8)=0$), so
$$v_\ell(x^4 - 8Nx) = \min\{4v,\ v_\ell(8N)+v\} = 4v,$$
because $4v < v \le v + v_\ell(8N)$ and the minimum is attained once (so there is no cancellation). Similarly $v_\ell(4(x^3+N)) = v_\ell(4) + \min\{3v, v_\ell(N)\} = 0 + 3v = 3v$. Hence $v_\ell(\operatorname{dbl}_N(x)) = 4v - 3v = v$, and the value is nonzero since its valuation is finite. $\square$

The content is that a negative valuation is a *formal group* phenomenon: on the kernel of reduction, the parameter $t = -x/y$ has $v_\ell(x) = -2v_\ell(t)$, and doubling multiplies $t$ by a unit-plus-higher-order term, so the leading valuation is untouched — as long as $\ell$ is odd, so that the factor $4$ in the denominator is invisible.

**Corollary 6.2 (rigidity along the tower).** *For $\ell \neq 2$ prime, $N \neq 0$, and $x$ with $\ell \mid \operatorname{den}(x)$: for every $k \geq 0$, $\operatorname{dbl}^k_N(x) \neq 0$, $\ell \mid \operatorname{den}(\operatorname{dbl}^k_N(x))$, and*
$$v_\ell\big(\operatorname{den}\operatorname{dbl}^k_N(x)\big) = v_\ell\big(\operatorname{den}(x)\big).$$

*Proof.* Induction on $k$ using Theorem 6.1, together with the identity $v_\ell(r) = -v_\ell(\operatorname{den} r)$ valid whenever $v_\ell(r)<0$. $\square$

**Theorem 6.3 (permanence of extraneous primes).** *Let $(x,y)$ be integral on $E_N$ with $N \neq 0$, $y \neq 0$, and let $\ell \nmid 6N$ be a prime with $\ell \mid y$. Then for every $k \geq 0$,*
$$\ell \mid \operatorname{den}\big(x(2^{k+1}P)\big) \quad\text{and}\quad v_\ell\big(\operatorname{den}x(2^{k+1}P)\big) = v_\ell\big(\operatorname{den}x(2P)\big) = 2v_\ell(y).$$

*Proof.* By Theorem 3.2, $\ell \mid \operatorname{den}x(2P)$, and by Theorem 3.4 the exponent there is $2v_\ell(y)$. Since $\ell \nmid 6N$ forces $\ell \neq 2$, Corollary 6.2 applied to the rational number $x(2P)$ freezes the exponent at every further level. $\square$

**Theorem 6.4 (dichotomy at the bad prime $2$).** *Let $N \neq 0$ and $x \in \mathbb{Q}$ with $v_2(x)<0$. Then $\operatorname{dbl}_N(x)\neq0$ and*
$$v_2\big(\operatorname{dbl}_N(x)\big) = v_2(x) - 2 .$$
*Consequently, if $2 \mid \operatorname{den}(x)$ then for all $k$,*
$$v_2\big(\operatorname{den}\operatorname{dbl}^k_N(x)\big) = v_2\big(\operatorname{den}(x)\big) + 2k .$$

*Proof.* As in Theorem 6.1, with $v = v_2(x)<0$: $v_2(x^4-8Nx) = 4v$ (since $v_2(8N)\geq 3 > 0 > v$ gives $4v < v + v_2(8N)$), whereas now $v_2(4(x^3+N)) = 2 + 3v$. Subtracting, $v_2(\operatorname{dbl}_N(x)) = 4v - (2+3v) = v-2$. Iterate. $\square$

So along the doubling tower the good-reduction primes are *frozen* and the bad prime $2$ grows *linearly*. This is the exact opposite of what the conjecture predicts: the primes it forbids are the stable ones.

**Theorem 6.5 (level four for $N=55$).** *For $N=55$, $P=(9,28)$:*
$$x(4P) = -\frac{35249882584054239}{21498536380459264},\qquad 21498536380459264 = 2^8\cdot 7^2\cdot 827^2\cdot 1583^2 .$$
*Here $827$ and $1583$ are primes; none of $7$, $827$, $1583$ divides $\Delta = -432\cdot55^2$. The exponent of $7$ is $2$ at level $2$ and $2$ at level $4$ — frozen, as Theorem 6.3 predicts — while the exponent of $2$ has grown from $6$ to $8$, exactly $+2$, as Theorem 6.4 predicts.*

In particular the tower form of the conjecture (every prime dividing $\operatorname{den} x(2^kP)$ lies in $\{2,3,p,q\}$) is false, witnessed at $k=2$ by $\ell = 827$.

---

## 7. Algorithms

Three procedures suffice to reproduce and explore everything above; all use exact rational arithmetic.

**Algorithm 7.1 (denominator spectrum of a multiple).** Given $N$, an integral point $P$, and $n$, compute $nP$ by double-and-add in $E_N(\mathbb{Q})$ with exact fractions, extract $\operatorname{den} x(nP)$ and factor it, then classify each prime as bad ($\ell \mid 6N$) or extraneous ($\ell \nmid 6N$). Cost: $O(\log n)$ group operations, each $O(1)$ rational operations; the bit-size of the coordinates grows like $\Theta(n^2)$ by the theory of canonical heights, so the arithmetic cost is dominated by the size of the final fraction, and factoring the denominator is the expensive step.

**Algorithm 7.2 (mechanism verification).** Given $N$ and an integral point $(x,y)$ with $y \ne 0$, compute $D = \operatorname{den}\operatorname{dbl}_N(x)$, and for every prime $\ell < B$ with $\ell \nmid 6N$ test the equivalence $\ell \mid D \iff \ell \mid y$; also test the exponent identity $v_\ell(D) = 2v_\ell(y)$. Cost: $O(B/\log B)$ divisibility tests. This is a direct empirical check of Theorems 3.2 and 3.4.

**Algorithm 7.3 (extraneous-prime constructor).** Given a finite set $S$ of primes $\geq 5$ and $m \geq 1$, output $K = \prod_{\ell\in S}\ell$, $N = K^2m^2-1$, $P = (1,Km)$. By Theorem 4.5 every $\ell \in S$ is a good prime dividing $\operatorname{den}x(2P)$, and indeed $\operatorname{den}x(2P) = 4K^2m^2/\gcd(\cdot)$ has $\ell$-exponent $2$. Cost: $O(|S|)$ multiplications; the construction is deterministic and requires no search.

---

## 8. A survey over semiprimes: no factoring signal

To test whether the denominators can be *used* — the practical motivation behind the conjecture — we surveyed semiprimes $N=pq$ with $p<q$ small, took every integral point $(x,y)$ with $|x|\le 200$ and $y>0$, and collected all primes occurring in the denominators of $x(2P)$ and $x(3P)$. Among the eleven semiprimes tried, eight possess such an integral point. The outcome:

* the "only bad primes" property held for **none** of them ($0\%$);
* **every** one exhibited at least one extraneous good-reduction prime ($100\%$);
* the smaller factor $p$ appeared in some denominator in $2$ of $8$ cases ($25\%$);
* the larger factor $q$ appeared in **no** case ($0\%$).

For example, $N = 15 = 3\cdot5$ produces the prime set $\{2,3,61,109,569,1295089\}$ across its integral points, and $N = 91 = 7\cdot 13$ produces $\{2,3,337\}$ — an extraneous prime larger than $N$ itself and no factor of $N$ in sight.

The interpretation follows from Theorems 3.2 and 5.2: the denominator of $x(nP)$ is (up to $6N$-primes) the square of the $n$-th division polynomial value $\psi_n(P)$, a quantity determined by $N$ *and the point*. Its factorisation is as hard as factoring an arbitrary integer of comparable size, and it exhibits $p$ or $q$ only by coincidence. There is no shortcut from denominators to factors.

---

## 9. Discussion

### 9.1 Why the conjecture was plausible, and why it fails

The intuition behind "only bad primes" is a conflation of two different notions of degeneracy. It is true that if $\ell$ is a prime of bad reduction, arithmetic modulo $\ell$ can behave badly; and it is true that denominators record where a point becomes "infinite" modulo $\ell$. But the second phenomenon is not about the curve degenerating — it is about the *point* falling into the kernel of reduction. A perfectly good curve over $\mathbb{F}_\ell$ has a finite group of points, and any given rational point reduces into a torsion class in it; when that class is killed by $n$, the multiple $nP$ falls into the formal group and the prime enters the denominator. Good reduction guarantees only that the reduced curve is smooth, not that it has no small-order points.

Put differently: bad primes are where the *curve* misbehaves; denominator primes are where the *point* is torsion. There is no reason for these to coincide, and Theorems 4.4–4.5 show one can make the second set contain any prescribed primes.

### 9.2 The sharp shape of the truth

The results assemble into a complete description at $n=2$ (and, mutatis mutandis, $n=3$):
$$\operatorname{den}\big(x(2P)\big) = 2^{e}\cdot \prod_{\ell \nmid 6N} \ell^{\,2v_\ell(y)} \cdot (\text{a }3\text{- and }N\text{-part}),$$
in which the good-reduction part is exactly $\big(\text{the prime-to-}6N\text{ part of } y\big)^2$, and along the doubling tower this good part is *invariant* while the $2$-part increases by $2$ at each step. The elliptic divisibility sequence perspective explains this uniformly: $\operatorname{den}x(nP)$ is, up to primes dividing $6N$, the square of $\psi_n(P)$, and the primes appearing are the zeros of the elliptic divisibility sequence modulo $\ell$ — a question about the *zero set of the sequence*, not about the discriminant.

### 9.3 Relation to elliptic curve factorisation

Lenstra's factorisation method does exploit an asymmetry between the prime factors of $N$, but it does so by working with a curve *modulo $N$* and detecting a failed inversion — a gcd computation. The information there comes from the differing group orders $\#E(\mathbb{F}_p)$ and $\#E(\mathbb{F}_q)$, and one must search over many curves to find one with smooth order. The denominators of rational multiples on a single Mordell curve contain no such asymmetry: by Theorem 3.2 they see exactly the primes $\ell$ where $\bar P$ is $2$-torsion, and $p \mid N$ is no more likely to have that property than any other prime — indeed $p \mid N$ is excluded from the clean statement altogether, since then $\ell \mid 6N$.

### 9.4 Limitations

Our mechanism theorems assume $\ell \nmid 6N$; the behaviour at $\ell \in \{2,3\}$ or $\ell \mid N$ requires separate analysis (we prove the $\ell=2$ case for the tower, where the behaviour is genuinely different: $+2$ per doubling). We prove the division-polynomial mechanism for $n=2$ and $n=3$ and for the whole tower $n=2^k$; the general-$n$ statement is formulated as a conjecture in §10. Finally, the counterexamples and survey concern integral points of small height; nothing here depends on that, but the numerics do.

---

## 10. Future directions

Throughout, $E_N : y^2 = x^3 + N$, $P=(x,y)$ an integral point, $\Delta = -432N^2$.

**C1. Elliptic-divisibility rigidity for the full multiple $nP$.** *Status: proved for $n=2$ and $n=3$; open in general.* The case $\psi_2 = 2y$ is the mechanism theorem at $n=2$ and the case $\psi_3 = 3x^4+12Nx$ is the mechanism theorem at $n=3$, each with its reduction-theoretic counterpart ($\ell \mid \operatorname{den}x(2P) \iff 2\bar P = O$; $\ell \mid \operatorname{den}x(3P) \iff 3\bar P = O$).

> **Conjecture.** For an integral point $P$ on $E_N$ and a prime $\ell\nmid 6N$, and for every $n \geq 1$: $\ell \mid \operatorname{den}x(nP)$ if and only if $\ell \mid \psi_n(P)$; moreover $\operatorname{den}x(nP)$ equals $\psi_n(P)^2$ up to primes dividing $6N$.

The key insight is that the mechanism theorem for $n=2$ is the case $\psi_2 = 2y$ of a uniform statement: the elliptic divisibility sequence $W_n = \psi_n(P)$ is precisely the denominator bookkeeping of the formal group, so "which primes appear" is a question about the *zero set of an elliptic divisibility sequence*, not about the discriminant. A falsifiable form: exhibit $N$, $P$, $n$ and $\ell\nmid 6N$ with $\ell \mid \operatorname{den}x(nP)$ but $\ell \nmid \psi_n(P)$.

**C2. Density of extraneous primes.** Fix $N$ and a non-torsion integral point $P$. For which primes $\ell$ does $\bar P$ reduce into the $n$-torsion for some $n \le X$? Heuristically the number of such $\ell \le Y$ should grow like a positive-density-weighted count governed by the distribution of $\#E_N(\mathbb{F}_\ell)$ and the order of $\bar P$; making this precise (and proving positive density for the set of *extraneous* primes appearing in some denominator) is the natural quantitative sequel to Theorems 4.4–4.5.

**C3. Exact exponents at the bad primes $3$ and $\ell \mid N$.** We have complete control at good primes (exponent $2v_\ell(y)$, frozen along the tower) and at $2$ (linear growth, $+2$ per doubling). The remaining cases — $\ell = 3$ and $\ell \mid N$ — should admit a similar dichotomy depending on the reduction type (multiplicative versus additive) of $E_N$ at $\ell$.

**C4. Uniform bounds on extraneous primes.** Theorem 4.5 makes the *number* of extraneous primes in one denominator unbounded, but with $N$ growing. For fixed $N$, how many extraneous primes can $\operatorname{den}x(2P)$ have as $P$ ranges over integral points? By Theorem 3.3 the answer is bounded by $\omega(2y)$, so this becomes a question about the prime factorisations of $y$-coordinates of integral points, i.e. about the size and structure of the integral points of $E_N$.

**C5. Towers for other multiplication maps.** The dichotomy (frozen at odd good primes, $+2$ at the prime $2$) reflects the factor $4$ in the duplication denominator. For the tripling tower the analogous factor is $9$, suggesting that $3$ should behave the way $2$ does here, growing linearly while all other good primes freeze — a clean statement waiting to be proved.

---

## 11. Conclusion

The "only bad primes" conjecture for Mordell curves is false, and it is false for a reason that is both simple and structural. The primes appearing in the denominator of $x(nP)$ are the primes at which the point $P$ reduces into the $n$-torsion of a perfectly good reduction of the curve; they are read off from the value of the $n$-th division polynomial at $P$, and they have nothing to do with the discriminant beyond a bounded contribution from $2$, $3$ and the divisors of $N$. Concretely: $N = 55$, $P = (9,28)$, $x(2P) = 2601/3136$, and the prime $7$ — a prime of good reduction — sits in the denominator.

Once the mechanism is identified, everything else follows: the failure is universal (every prime $\ge5$ occurs; arbitrarily many at once; infinitely many $N$), the exponents are exactly computable ($2v_\ell(y)$ at good primes), the failure is permanent along the doubling tower (frozen exponents at odd primes, $+2$ per level at $2$), and the correct statement — every prime dividing $\operatorname{den}x(2P)$ divides $2y$ — is about the point, not the curve. And as a practical corollary, the denominators of multiples of integral points carry no signal about the factorisation of $N$.
