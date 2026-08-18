# The Square-Root Floor of the Signed Circle

### Character weights, exact Weil deficiency, two-adic content, and the degeneracy of conic witnesses

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

For an odd modulus $N$ let
$$W(N) \;=\; \sum_{\substack{x,y \bmod N \\ x^2+y^2 = 1}} \left(\frac{x}{N}\right) \;=\; \sum_{x \bmod N} \left(\frac{x-x^3}{N}\right)$$
be the Jacobi-signed count of the circle $x^2+y^2=1$ modulo $N$, where $\left(\frac{\cdot}{N}\right)$ is the Jacobi symbol. This statistic is computable from $N$ alone in time $N^{1+o(1)}$ without factoring $N$, is multiplicative in the modulus, and at a prime $p\equiv 1 \pmod 4$ equals $2a$, where $p = a^2+b^2$ with $a$ odd. It is therefore a natural candidate for a "free witness" to the factorisation of a semiprime, and it is bounded by the Weil floor $|W(p)| \le 2\sqrt p$.

We prove four structural theorems that together show the floor is unbreakable and the statistic is informationless about the split.

1. **Character weights are Jacobi sums, with an order-independent constant.** For any multiplicative character $\psi$ of $\mathbb{F}_p^\times$ with complex values, set $W_\psi(p) = \sum_{x^2+y^2=1}\psi(x)$. If $\psi(-1)=-1$ then $W_\psi(p)=0$ identically. If $\psi = \xi^2 \ne 1$ then $W_\psi(p) = J(\xi,\chi) + J(\chi\xi,\chi)$, a sum of exactly two Jacobi sums against the quadratic character $\chi$; since $|J| = \sqrt p$, we obtain $|W_\psi(p)| \le 2\sqrt p$ with an absolute constant, independent of the order of $\psi$.
2. **The Weil deficiency is exact.** $4p - W(p)^2 = 4b^2$, where $b$ is the even Gaussian leg of $p = a^2+b^2$. Hence the sharp improvement $W(p)^2 \le 4p - 16$, with equality exactly at primes of the form $a^2+4$; and near-attainment of the Weil floor is *equivalent* to a Diophantine smallness condition on $b$.
3. **The $2$-adic content counts prime factors and nothing else.** For squarefree $N$ with all prime factors $\equiv 1 \pmod 4$, $v_2(W(N)) = \omega(N)$; for semiprimes in this family $v_2(W(N)) = 2$ identically, so the valuation is constant on the family and blind to the split. We also refute a natural strengthening: the vanishing of $W$ is *not* determined by $N \bmod 4$, since $21 \equiv 85 \equiv 1 \pmod 4$ but $W(21)=0$ while $W(85)=-4$. A Brahmagupta refinement shows $W(pq) \equiv 4u \pmod{16}$ where $pq = u^2+v^2$ with $u$ odd — an invariant of the modulus, not of its factorisation.
4. **Multiplicativity is universal; conic weights are constants.** For *every* integer polynomial $f$, the statistic $S_f(N) = \sum_x \left(\frac{f(x)}{N}\right)$ is multiplicative in coprime moduli: multiplicativity is a theorem of the Chinese Remainder Theorem and carries no information. For a separable quadratic $f$, $S_f(p) = -1$ at every odd prime, hence $S_f(N) = (-1)^{\omega(N)}$ on squarefree moduli and $S_f(pq) = +1$ at every semiprime. Conic witnesses are degenerate; the $\sqrt N$-sized fluctuation begins exactly at the cubic (elliptic) degree.

---

## 1. Introduction

### 1.1 Free witnesses and the square-root barrier

Let $N = pq$ be a semiprime. A *free witness* is a function $S$ with two properties: $S(N)$ is computable from $N$ alone without knowledge of $p$ and $q$, and $S(N)$ constrains the pair $(p,q)$ enough to help recover it. The existence of such a function with subexponential cost would be a mathematical event of the first order.

A natural family of candidates comes from point counts on curves modulo $N$, weighted by the Jacobi symbol. The Jacobi symbol $\left(\frac{a}{N}\right)$ is the unique extension of the Legendre symbol that is completely multiplicative in the lower argument, and it is computable in $O(\log^2 N)$ bit operations by a quadratic-reciprocity-driven Euclidean algorithm — critically, *without* factoring $N$. Character sums built from it are thus genuinely free.

The candidate studied here is the Jacobi-signed circle count $W(N)$ defined in the abstract. It is attractive for three reasons: it is multiplicative, so it "knows" that $N$ splits; it is nonzero and fluctuating on the hard family of semiprimes with both factors $\equiv 1 \pmod 4$; and at each such prime it computes a genuine arithmetic invariant, the odd leg of the two-square decomposition.

It is also, as we shall show in four independent ways, useless as a witness — and the reasons why are considerably more interesting than the negative conclusion.

### 1.2 Notation and background

Throughout, $p$ denotes an odd prime and $N$ an odd positive integer. We write:

* $\chi = \left(\frac{\cdot}{p}\right)$ for the quadratic (Legendre) character of $\mathbb{F}_p = \mathbb{Z}/p$, extended by $\chi(0)=0$; and $\left(\frac{\cdot}{N}\right)$ for the Jacobi symbol modulo $N$.
* $\omega(N)$ for the number of distinct prime factors of $N$, and $v_2(m)$ for the $2$-adic valuation of a nonzero integer $m$.
* $\zeta$ for a complex root of unity; a *multiplicative character* $\psi$ of $\mathbb{F}_p$ is a homomorphism $\mathbb{F}_p^\times \to \mathbb{C}^\times$ extended by $\psi(0)=0$ (with the convention that the trivial character $\psi = 1$ also satisfies $1(0) = 0$).
* $J(\alpha,\beta) = \sum_{x \in \mathbb{F}_p} \alpha(x)\beta(1-x)$ for the **Jacobi sum** of two characters.

We shall use freely the following classical facts.

**(F1) Orthogonality.** If $\psi \ne 1$ then $\sum_{x \in \mathbb{F}_p} \psi(x) = 0$.

**(F2) Square-root counting.** For $a \in \mathbb{F}_p$ and $p$ odd, $\#\{y : y^2 = a\} = 1 + \chi(a)$.

**(F3) The character group.** $\mathbb{F}_p^\times$ is cyclic of order $p-1$, and its character group is cyclic of the same order. Writing $\psi_j$ for the character sending a fixed generator $g$ to $e^{2\pi i j/(p-1)}$, we have $\psi_j(-1) = (-1)^j$; hence $\psi$ is **even** ($\psi(-1)=1$) if and only if $\psi$ is a square in the character group, and $\chi = \psi_{(p-1)/2}$ is the unique character of order $2$.

**(F4) Jacobi sum modulus.** If $\alpha, \beta, \alpha\beta$ are all nontrivial then $J(\alpha,\beta)\overline{J(\alpha,\beta)} = p$.

**(F5) Fermat / Gauss.** Every prime $p \equiv 1 \pmod 4$ is $p = a^2+b^2$ with $a$ odd and $b$ even, uniquely up to signs; and the signed circle count satisfies $W(p) = 2a$ for a suitable choice of sign of $a$. For $p \equiv 3 \pmod 4$, $W(p) = 0$.

**(F6) Multiplicativity of $W$.** $W(mn) = W(m)W(n)$ for coprime odd $m,n$ (proved in general form as Theorem 5.1 below).

Facts (F5) and (F6) are the starting point of the present work; (F5) yields the *Weil floor* $W(p)^2 \le 4p$, which we sharpen in §3.

### 1.3 Reduction of the double sum

The identity that makes everything computable is the following. Fix $x$; by (F2) the number of $y$ with $x^2+y^2=1$, i.e. with $y^2 = 1-x^2$, equals $1 + \chi(1-x^2)$. Hence for any weight $w : \mathbb{F}_p \to \mathbb{C}$,
$$\sum_{x^2+y^2=1} w(x) \;=\; \sum_{x} w(x)\bigl(1 + \chi(1-x^2)\bigr). \tag{1.1}$$
Taking $w = \chi$ and using $\chi(x)\chi(1-x^2) = \chi(x-x^3)$ and (F1),
$$W(p) \;=\; \sum_{x \in \mathbb{F}_p} \chi(x-x^3), \tag{1.2}$$
which is (up to sign) the trace of Frobenius of the elliptic curve $y^2 = x^3-x$: the circle-with-quadratic-weight is an elliptic curve in disguise, and the Weil floor is the Hasse bound.

---

## 2. Character weights: the floor is a property of the circle

Fix an odd prime $p$ and let $\psi$ be any multiplicative character of $\mathbb{F}_p$ with complex values. Define the **$\psi$-weighted circle count**
$$W_\psi(p) \;=\; \sum_{\substack{x,y \in \mathbb{F}_p \\ x^2+y^2=1}} \psi(x).$$
For $\psi = \chi$ this is the Jacobi-signed count $W(p)$; for $\psi = 1$ it is $p-3$ when $p \equiv 1 \pmod 4$ (the circle has $p-1$ points, two of which have $x = 0$) and $p+1$ when $p \equiv 3 \pmod 4$.

The natural hope is that a weight of larger order produces a larger, more informative signal. It does not.

### 2.1 Odd weights vanish

**Theorem 2.1 (Odd weights are blind).** *If $\psi(-1) = -1$ then $W_\psi(p) = 0$.*

*Proof.* The involution $(x,y) \mapsto (-x,y)$ permutes the solutions of $x^2+y^2=1$, and $\psi(-x) = \psi(-1)\psi(x) = -\psi(x)$. Reindexing the sum by this involution therefore gives $W_\psi(p) = -W_\psi(p)$, whence $2W_\psi(p) = 0$ and, since $\mathbb{C}$ has characteristic zero, $W_\psi(p)=0$. $\blacksquare$

By (F3) the odd characters are exactly the $\psi_j$ with $j$ odd, i.e. exactly half of all characters. Theorem 2.1 also contains, as its $\psi = \chi$ case, the classical vanishing $W(p)=0$ for $p \equiv 3 \pmod 4$: for those primes $-1$ is a non-residue, so $\chi(-1) = -1$.

### 2.2 The Jacobi-sum decomposition of even weights

By (F3), the even characters are precisely the squares $\psi = \xi^2$. So it suffices to handle those.

**Lemma 2.2 (One-variable reduction).** *For every character $\psi$,*
$$W_\psi(p) = \sum_{x \in \mathbb{F}_p} \psi(x)\bigl(\chi(1-x^2)+1\bigr).$$

*Proof.* This is (1.1), whose proof is (F2) applied to $a = 1-x^2$ for each fixed $x$. $\blacksquare$

**Lemma 2.3 (Pushforward along squaring).** *For every $F : \mathbb{F}_p \to \mathbb{C}$,*
$$\sum_{c \in \mathbb{F}_p} F(c^2) \;=\; \sum_{d \in \mathbb{F}_p} \bigl(\chi(d)+1\bigr)F(d).$$

*Proof.* Group the left-hand sum by the value $d = c^2$; the fibre over $d$ has $1+\chi(d)$ elements by (F2). $\blacksquare$

**Theorem 2.4 (Jacobi-sum decomposition).** *Let $\xi$ be a character with $\xi^2 \ne 1$. Then*
$$W_{\xi^2}(p) \;=\; J(\xi,\chi) \;+\; J(\chi\xi,\chi).$$

*Proof.* By Lemma 2.2 with $\psi = \xi^2$, and using $\xi^2(x) = \xi(x^2)$,
$$W_{\xi^2}(p) = \sum_x \xi^2(x) \;+\; \sum_x \xi(x^2)\chi(1-x^2).$$
The first sum vanishes by (F1), since $\xi^2 \ne 1$. To the second apply Lemma 2.3 with $F(d) = \xi(d)\chi(1-d)$:
$$\sum_x \xi(x^2)\chi(1-x^2) = \sum_d (\chi(d)+1)\,\xi(d)\chi(1-d) = \sum_d (\chi\xi)(d)\chi(1-d) + \sum_d \xi(d)\chi(1-d),$$
which is $J(\chi\xi,\chi) + J(\xi,\chi)$ by definition. $\blacksquare$

### 2.3 The modulus of a Jacobi sum

**Theorem 2.5.** *If $\alpha,\beta$ and $\alpha\beta$ are all nontrivial characters of $\mathbb{F}_p$ then $|J(\alpha,\beta)| = \sqrt p$.*

*Proof sketch.* Complex conjugation acts on character values by inversion, so $\overline{J(\alpha,\beta)} = J(\alpha^{-1},\beta^{-1})$. The classical identity $J(\alpha,\beta)J(\alpha^{-1},\beta^{-1}) = p$ — valid whenever $\alpha,\beta,\alpha\beta \ne 1$, and provable by expanding both Jacobi sums as Gauss-sum quotients or by a direct double-sum manipulation — then gives $|J(\alpha,\beta)|^2 = J\overline{J} = p$. $\blacksquare$

### 2.4 The classification of quadratic characters

To apply Theorem 2.5 to Theorem 2.4 we need to know exactly when the hypotheses hold. This requires the elementary but essential classification:

**Lemma 2.6.** *If $\xi^2 = 1$ then $\xi = 1$ or $\xi = \chi$.*

*Proof.* Let $g$ generate $\mathbb{F}_p^\times$. Then $\xi(g)^2=1$, so $\xi(g) = \pm 1$. A character is determined by its value at a generator. If $\xi(g)=1$ then $\xi = 1$. If $\xi(g)=-1$, then, since $g$ is a generator, $g$ is a quadratic non-residue (otherwise $g^{(p-1)/2}=1$ and the order of $g$ would be at most $(p-1)/2$), so $\chi(g) = -1 = \xi(g)$ and $\xi = \chi$. $\blacksquare$

Equivalently: $\xi^2 \ne 1$ if and only if $\xi \notin \{1,\chi\}$, i.e. if and only if both $\xi \ne 1$ and $\chi\xi \ne 1$.

### 2.5 The main bound

**Theorem 2.7 (Character-agnostic Weil floor).** *Let $p$ be an odd prime and $\xi$ a character with $\xi \ne 1$ and $\chi\xi \ne 1$. Then*
$$\bigl| W_{\xi^2}(p) \bigr| \;\le\; 2\sqrt p .$$
*The constant $2$ is absolute: it does not depend on the order of $\xi$.*

*Proof.* By Lemma 2.6 the hypotheses give $\xi^2 \ne 1$, so Theorem 2.4 applies:
$$W_{\xi^2}(p) = J(\xi,\chi)+J(\chi\xi,\chi).$$
For the first Jacobi sum: $\xi \ne 1$, $\chi \ne 1$ (as $p$ is odd), and $\xi\chi \ne 1$ by hypothesis; so $|J(\xi,\chi)| = \sqrt p$ by Theorem 2.5. For the second: $\chi\xi \ne 1$, $\chi\ne 1$, and $(\chi\xi)\chi = \xi\chi^2 = \xi \ne 1$; so again $|J(\chi\xi,\chi)| = \sqrt p$. The triangle inequality finishes the proof. $\blacksquare$

**Corollary 2.8 (Every nontrivial weight is at or below the floor).** *For every nontrivial multiplicative character $\psi$ of $\mathbb{F}_p$ one has $|W_\psi(p)| \le 2\sqrt p$; and if $\psi$ is odd, $W_\psi(p) = 0$ exactly.*

*Proof.* If $\psi$ is odd (which includes $\psi = \chi$ when $p \equiv 3 \pmod 4$), apply Theorem 2.1. If $\psi$ is even and $\psi \ne \chi$, write $\psi = \xi^2$ by (F3); then $\xi^2 \ne 1$, so $\xi \notin \{1,\chi\}$ by Lemma 2.6 and Theorem 2.7 applies. The one remaining case, $\psi = \chi$ with $p \equiv 1 \pmod 4$, is the classical Weil floor $|W(p)| = |2a| \le 2\sqrt p$ of (F5). $\blacksquare$

**Remark 2.9 (Non-vacuity).** The hypotheses are satisfiable. Whenever $p \equiv 1 \pmod 4$ we have $4 \mid p-1$, so $\mathbb{F}_p^\times$ carries a character $\xi$ of order exactly $4$; such a $\xi$ is neither trivial nor quadratic, so Theorem 2.7 applies to it. In that case $\xi^2$ has order $2$, i.e. $\xi^2 = \chi$, and Theorem 2.4 recovers $W(p) = J(\xi,\chi)+J(\chi\xi,\chi)$ — the classical expression of $2a$ as a sum of two conjugate Jacobi sums. When $8 \mid p-1$ one may take $\xi$ of order $8$ or more, and the decomposition then produces genuinely new even weights $\xi^2 \ne \chi$, still bounded by $2\sqrt p$.

**Remark 2.10 (What was conjectured, and what is true).** A natural conjecture is that a weight of order $d$ satisfies $|W_\psi(p)| \le d\sqrt p$, the factor $d$ measuring the complexity of the weight. Theorem 2.7 shows the truth is stronger and simpler: the number of Jacobi sums produced by the circle is always exactly two, no matter what the weight is. The floor is a property of the circle, not of the weight.

**Remark 2.11 (Consistency).** For $\psi = \chi$ one checks directly from Lemma 2.2 that $W_\chi(p) = \sum_x \chi(x)\chi(1-x^2) + \sum_x \chi(x) = \sum_x \chi(x-x^3) = W(p)$, so the complex-valued theory specialises correctly to the integer-valued signed count.

---

## 3. The exact Weil deficiency, and a sharp floor

Write $p \equiv 1 \pmod 4$ as $p = a^2+b^2$ with $W(p) = 2a$ and $a$ odd (F5).

**Lemma 3.1 (Parity of the companion leg).** *If $p \equiv 1 \pmod 4$, $p = a^2+b^2$ and $a$ is odd, then $b$ is even.*

*Proof.* If both $a$ and $b$ were odd, then writing $a = 2k+1$, $b = 2m+1$ gives $a^2+b^2 = 4(k^2+k+m^2+m)+2 \equiv 2 \pmod 4$, contradicting $p \equiv 1 \pmod 4$. $\blacksquare$

**Theorem 3.2 (Exact deficiency).** *For $p \equiv 1 \pmod 4$,*
$$4p - W(p)^2 \;=\; 4b^2 ,$$
*where $b$ is the even leg of $p = a^2+b^2$, $a$ odd, $W(p) = 2a$.*

*Proof.* $4p - W(p)^2 = 4(a^2+b^2) - (2a)^2 = 4b^2$. $\blacksquare$

Trivial as an identity, this is the structural content of the Weil bound in this case: the bound $W(p)^2 \le 4p$ is not an inequality obtained by estimation, it is an exact equation with a nonnegative correction term of known arithmetic meaning.

**Lemma 3.3.** *A prime is never a perfect square; hence $b \ne 0$ in any representation $p = a^2+b^2$.*

*Proof.* If $b=0$ then $p = a^2$, so $|a|$ divides $p$; $|a| = 1$ gives $p=1$ and $|a|=p$ gives $p = p^2$, both impossible for a prime. $\blacksquare$

**Theorem 3.4 (Sharp floor).** *For every prime $p \equiv 1 \pmod 4$,*
$$W(p)^2 \;\le\; 4p - 16 ,$$
*and the constant $16$ cannot be improved: equality holds precisely when $|b| = 2$, i.e. exactly at the primes $p = a^2+4$ — for instance $p = 5, 13, 29, 53, 173, 229, 293$.*

*Proof.* By Lemma 3.1, $b$ is even; by Lemma 3.3, $b \ne 0$; hence $b^2 \ge 4$ and $4b^2 \ge 16$. Apply Theorem 3.2. Equality is $b^2 = 4$. $\blacksquare$

**Theorem 3.5 (Near-attainment is Diophantine).** *Let $u,v$ be positive integers, $\varepsilon = u/v$. Then*
$$W(p)^2 \;>\; (1-\varepsilon)\cdot 4p \iff v\,b^2 \;<\; u\,p .$$

*Proof.* Multiply the left inequality by $v$ and substitute $W(p)^2 = 4p - 4b^2$ from Theorem 3.2: it becomes $v(4p-4b^2) > (v-u)4p$, i.e. $4up > 4vb^2$. $\blacksquare$

Thus the question "how often is the Weil floor nearly attained?" is *exactly* the question "how often does a prime have the form $a^2+b^2$ with $b = O(p^{\varepsilon/2})$?" — a question about primes represented by thin quadratic families, of the Landau–Ramanujan circle of ideas, where sieve methods are the relevant technology. The frequently-quoted numerical example $p = 173$, with attainment ratio $W(p)^2/4p = 676/692 = 97.69\%$, is now completely explained: $173 = 13^2+2^2$, the even leg is minimal, and $4 \cdot 173 - 26^2 = 16$ exactly.

### 3.1 A numerical table

| $p$ | $W(p)$ | $a$ | $b$ | $4p - W(p)^2 = 4b^2$ | $W(p)^2/4p$ |
|---|---|---|---|---|---|
| $5$ | $2$ | $1$ | $2$ | $16$ | $0.200$ |
| $13$ | $-6$ | $-3$ | $2$ | $16$ | $0.692$ |
| $17$ | $-2$ | $-1$ | $4$ | $64$ | $0.059$ |
| $29$ | $10$ | $5$ | $2$ | $16$ | $0.862$ |
| $37$ | $2$ | $1$ | $6$ | $144$ | $0.027$ |
| $53$ | $-14$ | $-7$ | $2$ | $16$ | $0.925$ |
| $97$ | $-18$ | $-9$ | $4$ | $64$ | $0.835$ |
| $173$ | $26$ | $13$ | $2$ | $16$ | $0.977$ |
| $229$ | $-30$ | $-15$ | $2$ | $16$ | $0.983$ |
| $293$ | $34$ | $17$ | $2$ | $16$ | $0.986$ |

Every row satisfies the exact deficiency identity, and the near-attaining rows are exactly the rows with $|b|=2$.

---

## 4. Two-adic content

### 4.1 The valuation counts prime factors

**Lemma 4.1.** *For $p \equiv 1 \pmod 4$, $W(p) = 2s$ with $s$ odd. For $p \equiv 3 \pmod 4$, $W(p) = 0$.*

This is (F5) together with Lemma 3.1.

**Theorem 4.2 (Semiprime valuation).** *Let $p \ne q$ be primes with $p \equiv q \equiv 1 \pmod 4$. Then $W(pq) = 4s$ with $s$ odd; equivalently $4 \mid W(pq)$ and $8 \nmid W(pq)$, i.e. $v_2(W(pq)) = 2$ exactly. In particular $W(pq) \ne 0$.*

*Proof.* Write $W(p)=2a$, $W(q)=2c$ with $a,c$ odd (Lemma 4.1). Multiplicativity (F6) gives $W(pq)=4ac$, and $ac$ is odd because $2$ is prime. $\blacksquare$

**Theorem 4.3 (Squarefree case).** *Let $N$ be squarefree with every prime factor $\equiv 1 \pmod 4$. Then $W(N) = 2^{\omega(N)}s$ with $s$ odd; equivalently $v_2(W(N)) = \omega(N)$.*

*Proof.* Induct on the set of prime factors, using $N = \prod_{p \mid N} p$ (valid since $N$ is squarefree), the coprimality of each prime with the product of the others, multiplicativity, Lemma 4.1 at each prime, and the fact that a product of odd integers is odd. The base case $N=1$ gives $W(1)=1$. $\blacksquare$

**Theorem 4.4 (Exact vanishing criterion).** *For distinct odd primes $p,q$:*
$$W(pq) = 0 \iff p \equiv 3 \pmod 4 \ \text{ or }\ q \equiv 3 \pmod 4 .$$

*Proof.* ($\Leftarrow$) is Lemma 4.1 plus multiplicativity. ($\Rightarrow$): if both are $\equiv 1 \pmod 4$ then $W(pq) \ne 0$ by Theorem 4.2. $\blacksquare$

### 4.2 What this does — and does not — leak

**Theorem 4.5 (Blindness to the split).** *On the family of semiprimes $N=pq$ with $p\ne q$ and $p \equiv q \equiv 1 \pmod 4$, the quantity $v_2(W(N))$ is the constant $2$. Hence for any two such $N, N'$ we have $v_2(W(N)) = v_2(W(N'))$: the $2$-adic valuation cannot distinguish one factorisation from another.*

This is the correct formulation of "the $2$-adic content carries no information". A tempting alternative formulation — that this content is *publicly computable from $N \bmod 4$* — is false:

**Theorem 4.6 (Refutation).** *There exist semiprimes $M, N$ with $M \equiv N \pmod 4$ but $W(M) = 0 \ne W(N)$. Explicitly, $M = 21 = 3\cdot 7$ and $N = 85 = 5 \cdot 17$ satisfy $21 \equiv 85 \equiv 1 \pmod 4$, while*
$$W(21) = 0, \qquad W(85) = -4 .$$

**Corollary 4.7.** *There is no function $f$ with $W(N) = f(N \bmod 4)$ for all odd $N$; the signed circle count is not a "residue dial".*

So the statistic does see beyond $N \bmod 4$ — it sees, for instance, the presence of a prime factor $\equiv 3 \pmod 4$, which is genuine arithmetic information about $N$. What it does not see is which of the many possible splits of $N$ is the true one, and Theorem 4.5 makes that precise on the family where it matters.

### 4.3 The Brahmagupta refinement

Brahmagupta's identity
$$(a^2+b^2)(c^2+d^2) = (ac-bd)^2+(ad+bc)^2$$
transports the two-square structure from the primes to their product.

**Theorem 4.8 (Four-square refinement).** *Let $p \ne q$ be primes $\equiv 1 \pmod 4$, with $p = a^2+b^2$, $q = c^2+d^2$, $a,c$ odd, $W(p)=2a$, $W(q)=2c$. Put $s = ac$, $u = ad$, $v = bc$, $w = bd$. Then*
$$pq = s^2+u^2+v^2+w^2, \qquad W(pq)=4s \ \text{ with } s \text{ odd},$$
*and*
$$16\,pq \;=\; W(pq)^2 + (4u)^2 + (4v)^2 + (4w)^2 .$$

*Proof.* Expand $(a^2+b^2)(c^2+d^2) = (ac)^2+(ad)^2+(bc)^2+(bd)^2$ (Euler's four-square form of the product), and multiply by $16$, using $W(pq)=4ac$. $\blacksquare$

The last display is an exact refinement of the semiprime Weil floor $W(N)^2 \le 16N$: the deficiency $16N - W(N)^2$ is itself an explicit sum of three squares.

**Theorem 4.9 (The statistic reads a Gaussian coordinate of $N$).** *In the situation of Theorem 4.8 there is a two-square representation $N = pq = u^2+v^2$ with $u$ odd such that*
$$W(N) \equiv 4u \pmod{16}.$$

*Proof.* Take $u = ac-bd$ and $v = ad+bc$ (Brahmagupta). Then $u$ is odd, since $ac$ is odd and $bd$ is even by Lemma 3.1. Writing $b = 2b'$, $d = 2d'$ we get $W(N) - 4u = 4ac - 4(ac-bd) = 4bd = 16b'd'$. $\blacksquare$

The interpretation is the crux of the matter. The Gaussian coordinates $(u,v)$ of $N$ are an invariant *of $N$ itself* — they can be computed from $N$ alone (given a square root of $-1$ modulo $N$, by lattice reduction; and in any case they are determined by $N$ up to the finitely many representations). So $W(N) \bmod 16$ reports a conserved quantity of the modulus, not a feature of the split. Any large "signal" in one Gaussian leg is compensated by the other, with $N = u^2+v^2$ conserved: this is the two-leg trade-off in exact form.

---

## 5. Universality: multiplicativity is free, conics are constants

The final block of results explains why *all* statistics of this type fail together.

### 5.1 Every polynomial weight is multiplicative

For an integer polynomial $f \in \mathbb{Z}[X]$ and odd $N$, define
$$S_f(N) \;=\; \sum_{x \in \mathbb{Z}/N} \left(\frac{f(x)}{N}\right),$$
where $f(x)$ is evaluated in $\mathbb{Z}/N$ and then fed to the Jacobi symbol. For $f = X - X^3$ this is $W$, by (1.2).

**Theorem 5.1 (Universal multiplicativity).** *For every $f \in \mathbb{Z}[X]$ and coprime odd $m,n$,*
$$S_f(mn) = S_f(m)\,S_f(n).$$

*Proof.* The Chinese Remainder Theorem gives a ring isomorphism $\mathbb{Z}/mn \cong \mathbb{Z}/m \times \mathbb{Z}/n$, under which $x \mapsto (x \bmod m, x \bmod n)$. Polynomial evaluation commutes with ring homomorphisms, so $f(x) \bmod m = f(x \bmod m)$ and likewise for $n$. The Jacobi symbol splits, $\left(\frac{a}{mn}\right) = \left(\frac{a}{m}\right)\left(\frac{a}{n}\right)$, and each factor depends only on $a$ modulo the respective modulus. Hence the summand factors as a product of a function of $x \bmod m$ and a function of $x \bmod n$, and the sum over $\mathbb{Z}/mn$ becomes the product of the two sums. $\blacksquare$

The moral is decisive for the "free witness" programme: *multiplicativity is a theorem about the Chinese Remainder Theorem, not about the curve.* The fact that $W(N)$ splits along the factorisation of $N$ is therefore no evidence at all that it leaks the factorisation. Every polynomial weight does it, including the ones that are provably constant.

### 5.2 Separable conic weights are constant

**Theorem 5.2 (Conic evaluation).** *Let $p$ be an odd prime and $r,s \in \mathbb{Z}$, and let $f(X)=(X-r)(X-s)$. Then*
$$S_f(p) = \begin{cases} p-1, & r \equiv s \pmod p, \\ -1, & r \not\equiv s \pmod p.\end{cases}$$

*Proof sketch.* Modulo $p$ the Jacobi symbol is the quadratic character $\chi$. If $r \equiv s$ the sum is $\sum_x \chi((x-r)^2) = \#\{x \ne r\} = p-1$. If $r \not\equiv s$, substitute $x = r + t$ and factor: $\sum_t \chi(t)\chi(t + (r-s))$. For $t \ne 0$ write $\chi(t)\chi(t+c) = \chi(t^2)\chi(1 + c t^{-1}) = \chi(1+ct^{-1})$; as $t$ runs over the nonzero residues, $1+ct^{-1}$ runs over all residues except $1$, so the sum equals $\sum_{z \ne 1}\chi(z) = -\chi(1) = -1$ by (F1). $\blacksquare$

**Corollary 5.3 (Squarefree law).** *If $N$ is squarefree, all its prime factors are odd and none divides $r-s$, then $S_f(N) = (-1)^{\omega(N)}$.*

*Proof.* Multiplicativity (Theorem 5.1) plus Theorem 5.2 at each prime, by induction on the prime factors. $\blacksquare$

**Corollary 5.4 (Conic witnesses are blind).** *For distinct odd primes $p \ne q$ with $r \not\equiv s$ modulo each, $S_f(pq) = (-1)(-1) = +1$.*

So a separable conic statistic returns the constant $+1$ at *every* semiprime in its range of validity. It carries not merely too little information — it carries none whatsoever, and it does not even reach the square-root floor: its fluctuation is zero.

### 5.3 The cubic is genuinely different

**Theorem 5.5 (Strict separation).** *There is a semiprime at which the circle statistic differs from every separable conic statistic: at $N = 85 = 5 \cdot 17$, every separable conic weight gives $+1$, while $W(85) = -4$.*

The dichotomy this exhibits is the heart of the matter:

* Degree $\le 2$: the statistic is a **constant** ($-1$ per odd prime for separable conics), because the curve $y^2 = f(x)$ is rational and its point count has no error term.
* Degree $3$: the statistic **fluctuates**, of size exactly $\sqrt p$, because $y^2=f(x)$ is an elliptic curve, and the Hasse–Weil bound both permits and caps the fluctuation.

The interesting regime and the impossible regime are the same regime. As soon as a weight is rich enough to fluctuate, it is governed by the square-root law; before that, it is constant. There is no window in between.

---

## 6. Algorithms

Three algorithms underlie the computations reported here. All are elementary; we record their complexity.

**A. Jacobi symbol.** Given odd $N > 0$ and $a$, compute $\left(\frac{a}{N}\right) \in \{-1,0,1\}$ by a Euclidean loop: reduce $a$ modulo $N$, extract powers of $2$ (flipping the sign when $N \equiv 3,5 \pmod 8$), then swap the arguments with a sign flip when both are $\equiv 3 \pmod 4$. Cost: $O(\log^2 N)$ bit operations. This is what makes the statistic "free" — it requires no factorisation of $N$.

**B. Direct signed circle count.** $W(N) = \sum_{x=0}^{N-1} \left(\frac{x-x^3}{N}\right)$. Cost: $N$ Jacobi symbols, so $N^{1+o(1)}$ — polynomial in $N$, exponential in $\log N$. This is the "from $N$ alone" cost.

**C. Factored evaluation.** If the factorisation $N = \prod p_i^{e_i}$ is known, compute $W(N) = \prod_i W(p_i)^{e_i}$ (for squarefree $N$: $\prod_i W(p_i)$), where each $W(p)$ is obtained from the two-square decomposition $p = a^2+b^2$ — computable in $\mathrm{polylog}(p)$ time by Cornacchia's algorithm — as $W(p) = \pm 2a$ with $a$ odd, and $W(p)=0$ for $p \equiv 3 \pmod 4$. Cost: $\mathrm{polylog}(N)$.

The gap between B and C — $N^{1+o(1)}$ versus $\mathrm{polylog}(N)$ — is exactly the "free-witness gap": the statistic is cheap for someone who already knows the factorisation and expensive for someone who does not. Crucially, the results above show that paying the expensive cost buys no information about the split, because the value obtained is pinned by the Weil floor and determined (modulo $16$, and in its $2$-adic content entirely) by invariants of $N$ itself.

**D. Character-weighted counts.** For the complex weights of §2, one fixes a primitive root $g$ modulo $p$, tabulates discrete logarithms in $O(p)$ time, and evaluates $\psi_j(x) = e^{2\pi i j \log_g x/(p-1)}$. The circle count is then a sum over the $p \pm 1$ points, and the Jacobi sums are single sums of length $p$; agreement of the two sides of Theorem 2.4 is verified numerically to machine precision.

---

## 7. Discussion

### 7.1 Why the four results are one result

Each of §§2–5 removes one degree of freedom from the search for a leaking statistic.

* §5 removes the *modulus* degree of freedom: multiplicativity holds for every weight, so nothing is learned from the fact that the statistic factors.
* §5 also removes the *low-degree* direction: conics are constants, so the only candidates that fluctuate at all are of degree $\ge 3$.
* §2 removes the *weight* degree of freedom for the circle: every character weight, of every order, produces at most two Jacobi sums, each of modulus exactly $\sqrt p$.
* §3 removes the *near-attainment* hope: the deficiency is an exact square, $4p - W(p)^2 = 4b^2$, so getting close to the ceiling is a statement about $p$ being just above a square, and even in the best case the bound only improves to $4p - 16$.
* §4 removes the *arithmetic-fine-structure* hope: the $2$-adic content is exactly $\omega(N)$ and is constant on the hard family, and $W(N) \bmod 16$ reports the odd Gaussian coordinate of $N$, an invariant of $N$ alone.

Together they say: the statistic is a number of size $\le 4\sqrt N$, whose coarse arithmetic ($2$-adic valuation, residue mod $16$) is determined by invariants of $N$, and whose fine arithmetic is capped by the Hasse–Weil bound. A semiprime's factorisation requires $\sim \tfrac12\log_2 N$ bits to specify; a single value bounded by $4\sqrt N$ has room for $\sim \tfrac12\log_2 N$ bits in principle, but the constraints above show the bits it holds are the wrong ones — they are functions of $N$, not of the split.

### 7.2 Relation to classical theory

Everything here has a classical shadow. Identity (1.2) exhibits $W(p)$ as the trace of Frobenius of $y^2 = x^3-x$, the congruent-number curve with complex multiplication by $\mathbb{Z}[i]$; the two-square formula $W(p) = 2a$ is Gauss's evaluation of the corresponding Jacobsthal sum. Theorem 2.4 is the circle-sum incarnation of the classical fact that CM point counts are Jacobi sums, and Theorem 2.5 is the Riemann hypothesis for curves in the one case Gauss could prove by hand. What is new here is the *uniformity*: the constant $2$ in Theorem 2.7 does not depend on the order of the weight, and the deficiency identity of Theorem 3.2 turns the analytic near-attainment question into a Diophantine one.

### 7.3 An information-theoretic reading

Say a statistic $S$ *leaks* on a family $\mathcal{F}$ of semiprimes if the conditional distribution of the split given $S(N)$ differs materially from the unconditional one. The results give three levels of non-leakage:

1. **Exact zero information.** Separable conic statistics are constant on all semiprimes (Corollary 5.4); a constant statistic has zero mutual information with anything.
2. **Constant coarse invariants.** $v_2(W(N)) = 2$ identically on semiprimes with both factors $\equiv 1 \pmod 4$ (Theorem 4.5); and $W(N) \bmod 16$ is a function of $N$'s Gaussian coordinates (Theorem 4.9).
3. **Capped fine information.** $|W(N)| \le 4\sqrt N$ with the per-prime constraint $|W(p)| \le \sqrt{4p-16}$; the value is a product of two bounded conjugate quantities and, given $N$, satisfies an exact conservation law $W(N)^2 + (\text{explicit squares}) = 16N$.

Only the third level is a quantitative claim, and it is the one where the Weil floor does its work.

---

## 8. Future directions

**D1. The cubic is the unique weight family with a nonconstant square-root signal.** For an integer polynomial $f$ of degree $d \ge 1$ that is not a constant times a square, the prime statistic $S_f(p)$ should satisfy $|S_f(p)| \le (d-1)\sqrt p$, with equality possible only for $d \ge 3$; for $d \le 2$ the statistic is *constant* in $p$ (namely $-1$ for a separable conic), so the entire conic-witness family is degenerate and the $\sqrt p$ fluctuation begins exactly at the elliptic degree $d = 3$. The transition from "constant" to "$\sqrt p$-fluctuating" is the transition from a rational conic to an elliptic curve, while Theorem 5.1 shows the behaviour in the modulus is identical on both sides.

**D2. The two-adic valuation of every character-weighted count is a factor counter.** For a general character weight $\psi$ and composite modulus, one expects an analogue of Theorem 4.3: the $2$-adic (or $\pi$-adic, for $\pi$ above $2$ in the relevant cyclotomic ring) content of $W_\psi(N)$ should count prime factors of $N$ of a prescribed splitting type, and hence be constant on each hard family.

**D3. Equidistribution on the Weil circle.** For semiprimes $N=pq$ with both factors $\equiv 1 \pmod 4$, the normalised value $W(N)/(4\sqrt N)$ should have a limiting distribution equal to the pushforward, under multiplication, of two independent arcsine laws (the Sato–Tate law for CM curves). Combined with the exact conservation law of Theorem 4.8, this would upgrade the qualitative "no leakage" statements to a quantitative $O(1)$-bit bound.

**D4. Density of near-attainment.** By Theorem 3.5, the assertion that $W(p)^2 > (1-\varepsilon)4p$ for a positive-density set of primes is equivalent to the assertion that a positive-density set of primes $p \equiv 1 \pmod 4$ has $p = a^2+b^2$ with $b = O(p^{\varepsilon/2})$. The case $b = 2$ — primes of the form $a^2+4$ — is already a well-known open problem of Landau type; sieve methods give upper bounds of the right order but no lower bounds.

**D5. Arbitrary conics and character products.** Both halves of the argument generalise mechanically: multiplicativity holds for any weight that is a product of Jacobi-type characters evaluated at polynomials, and the per-prime bound follows from the same second-moment/Jacobi-sum machinery. The expected general statement is that any statistic $S(N) = \sum_{(x,y)\in C(N)} w(x,y)$, with $C$ a conic and $w$ a product of character weights, is multiplicative in the modulus, of size $O(N^{1/2+o(1)})$, computable from $N$ in time $N^{1+o(1)}$ and from the factorisation in $\mathrm{polylog}(N)$ — so the free-witness gap is exactly the Weil floor, for every member of the family at once.

---

## 9. Conclusion

The Jacobi-signed circle count is a genuinely interesting arithmetic function: multiplicative, computable without factoring, and equal at each prime $p \equiv 1 \pmod 4$ to twice the odd leg of its two-square decomposition. It is also, provably, not a witness to factorisation. Every character weight yields at most two Jacobi sums and hence obeys $|W_\psi(p)| \le 2\sqrt p$ with an absolute constant; the deficiency in the Weil bound is exactly four times the square of the even Gaussian leg, giving the sharp inequality $W(p)^2 \le 4p-16$; the $2$-adic valuation counts prime factors and is constant on the hard semiprime family; and the whole phenomenon of multiplicativity is a free consequence of the Chinese Remainder Theorem, shared with conic weights that are outright constants.

The square-root floor is not an artefact of a particular sum. It is the shape of the curve.
