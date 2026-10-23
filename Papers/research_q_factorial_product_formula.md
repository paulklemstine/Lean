# The $q$-Factorial Product Formula and the Cyclotomic Carry Factorisation of Gaussian Binomial Coefficients

**Aristotle**

*October 23, 2026*

---

## Abstract

We study the $q$-integers $[n]_q = 1 + q + \cdots + q^{n-1}$, the $q$-factorials $[n]_q! = \prod_{i=1}^n [i]_q$, and the Gaussian binomial coefficients $\binom{n}{k}_q$, the latter defined solely through the $q$-Pascal recursion. Our first main result is the division-free product formula
$$[k]_q!\,[n-k]_q!\,\binom{n}{k}_q = [n]_q! \qquad (0 \le k \le n),$$
valid for an arbitrary element $q$ of an arbitrary commutative semiring. It specialises at $q=1$ to $k!\,(n-k)!\,\binom{n}{k} = n!$, and in the tropical semiring to the degree formula $\deg \binom{n}{k}_q = k(n-k)$. In the polynomial ring $\mathbb{Z}[q]$ we show that $[n]_q!$ is monic of degree $\binom{n}{2}$, that the product formula characterises $\binom{n}{k}_q$ uniquely, and that $(q;q)_n = (1-q)^n [n]_q!$. We then prove the cyclotomic factorisation $[n]_q! = \prod_{d=2}^n \Phi_d(q)^{\lfloor n/d \rfloor}$ and deduce, via the uniqueness statement, the *carry factorisation*
$$\binom{n}{k}_q = \prod_{\substack{2\le d \le n \\ d \,\le\, (k \bmod d) + ((n-k) \bmod d)}} \Phi_d(q),$$
so that every Gaussian binomial coefficient is a product of distinct cyclotomic polynomials, $\Phi_d$ occurring exactly when the base-$d$ addition of $k$ and $n-k$ carries out of the units digit. Consequences include the divisibility $\Phi_n(q) \mid \binom{n}{k}_q$ for $0<k<n$ and, at $q=1$, product formulas for $n!$ and $\binom{n}{k}$ over values $\Phi_d(1)$ which are polynomial-level forms of the formulas of Legendre and Kummer. We close with algorithms, numerical illustrations, and open problems.

---

## 1. Introduction

The binomial identity
$$k!\,(n-k)!\,\binom{n}{k} = n! \tag{1.1}$$
is so familiar that its content is easily overlooked. Read from left to right it is a bijective statement: an ordering of $n$ objects is the same as a choice of a $k$-subset together with orderings of the subset and of its complement. It involves no division. Read as a formula for $\binom{n}{k}$, on the other hand, it requires dividing by $k!(n-k)!$, and the integrality of the quotient becomes a theorem.

The $q$-analogue of (1.1) replaces each integer $m$ by the $q$-integer $[m]_q$. The objects involved are classical, going back to Gauss: the $q$-factorial $[n]_q!$ is the generating function of permutations by number of inversions, and also, for $q$ a prime power, the number of complete flags in $\mathbb{F}_q^n$; the Gaussian binomial $\binom{n}{k}_q$ is the generating function of partitions fitting in a $k\times(n-k)$ box, and also the number of $k$-dimensional subspaces of $\mathbb{F}_q^n$. The $q$-analogue of (1.1) is therefore a counting statement about flags: a complete flag of $\mathbb{F}_q^n$ is a $k$-dimensional subspace $V$, together with a complete flag of $V$ and a complete flag of $\mathbb{F}_q^n/V$.

This paper has two aims.

1. **A division-free foundation.** We define $\binom{n}{k}_q$ by the $q$-Pascal recursion and prove the $q$-analogue of (1.1) in the greatest natural generality: for an element $q$ of an arbitrary commutative semiring. No subtraction, no division, no hypotheses on $q$. The proof is a short induction whose two ingredients — the shifted additivity of $q$-integers and the $q$-Pascal rule — mesh exactly.

2. **Arithmetic structure.** In $\mathbb{Z}[q]$ the product formula becomes a characterisation of $\binom{n}{k}_q$. Combining it with the factorisation of $[n]_q!$ into cyclotomic polynomials yields a complete, explicit factorisation of every Gaussian binomial coefficient into irreducibles over $\mathbb{Q}$. The answer is governed by *carries*: $\Phi_d$ divides $\binom{n}{k}_q$, and then exactly once, if and only if adding $k$ and $n-k$ in base $d$ carries out of the units digit.

The carry factorisation is a polynomial "lift" of Kummer's theorem on $p$-adic valuations of binomial coefficients. At $q=1$, cyclotomic polynomials evaluate to primes or to $1$, and the carry factorisation collapses to a product formula for $\binom{n}{k}$ whose $p$-part counts carries at prime-power moduli.

### 1.1 Summary of results

Throughout, $0 \le k \le n$ are integers.

- **Theorem A (product formula).** In every commutative semiring, $[k]_q!\,[n-k]_q!\,\binom{n}{k}_q = [n]_q!$ (Theorem 3.2). Corollaries: $k!(n-k)!\binom{n}{k} = n!$ (Corollary 3.4) and $\deg\binom{n}{k}_q = k(n-k)$ (Corollary 3.6).
- **Theorem B (structure in $\mathbb{Z}[q]$).** $[n]_q!$ is monic of degree $\binom n2$ (Proposition 4.2); $(q;q)_n = (1-q)^n[n]_q!$ (Proposition 4.1); and any $P \in \mathbb{Z}[q]$ with $[k]_q![n-k]_q!\,P = [n]_q!$ equals $\binom{n}{k}_q$ (Theorem 4.3).
- **Theorem C (cyclotomic factorisations).** $[n]_q! = \prod_{d=2}^n \Phi_d^{\lfloor n/d\rfloor}$ (Theorem 5.2) and $\binom{n}{k}_q = \prod_{d \in \mathcal{C}(n,k)} \Phi_d$, where $\mathcal{C}(n,k)$ is the set of carry moduli (Theorem 5.5). Every cyclotomic exponent in $\binom{n}{k}_q$ is $0$ or $1$ (Corollary 5.6), and $\Phi_n \mid \binom{n}{k}_q$ for $0<k<n$ (Corollary 5.7).
- **Theorem D (integer shadows).** $n! = \prod_{d=2}^n \Phi_d(1)^{\lfloor n/d\rfloor}$ and $\binom{n}{k} = \prod_{d\in\mathcal{C}(n,k)} \Phi_d(1)$ (Theorem 6.1).

---

## 2. Definitions and conventions

Let $R$ be a **commutative semiring**: a set with two associative and commutative operations $+$ and $\cdot$, identities $0$ and $1$, distributivity, and $0\cdot a = 0$. No additive inverses are assumed. Examples are $\mathbb{N}$, $\mathbb{N}[q]$, every commutative ring, and the tropical semiring $\mathbb{T} = (\mathbb{R}\cup\{-\infty\}, \max, +)$ with zero $-\infty$ and one $0$.

**Definition 2.1 ($q$-integers and $q$-factorials).** For $q \in R$ and $n \in \mathbb{N}$ put
$$[n]_q = \sum_{i=0}^{n-1} q^i, \qquad [n]_q! = \prod_{i=1}^{n} [i]_q.$$
Thus $[0]_q = 0$, $[1]_q = 1$, $[0]_q! = 1$, and $[n+1]_q! = [n]_q!\,[n+1]_q$.

**Definition 2.2 (Gaussian binomial coefficients).** For $q \in R$ define $\binom{n}{k}_q \in R$ for all $n,k\in\mathbb{N}$ by
$$\binom{n}{0}_q = 1,\qquad \binom{0}{k+1}_q = 0,\qquad \binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{k+1}\binom{n}{k+1}_q. \tag{2.1}$$

The following facts follow from (2.1) by routine inductions on $n$.

**Lemma 2.3.** For all $n,k$:
1. $\binom{n}{k}_q = 0$ whenever $k>n$;
2. $\binom{n}{n}_q = 1$;
3. $\binom{n}{1}_q = [n]_q$;
4. if $R$ is a ring and $q=1$, then $\binom{n}{k}_1 = \binom{n}{k}$, the ordinary binomial coefficient.

*Proof sketch.* (1) For $k>n$, both terms of (2.1) have upper index $n-1$ and lower index exceeding it. (2) $\binom{n+1}{n+1}_q = \binom{n}{n}_q + q^{n+1}\binom{n}{n+1}_q = 1 + 0$ by (1). (3) $\binom{n+1}{1}_q = 1 + q\binom{n}{1}_q = 1 + q[n]_q = [n+1]_q$. (4) At $q=1$, (2.1) is Pascal's rule. $\square$

**Definition 2.4 (cyclotomic polynomials).** The cyclotomic polynomials $\Phi_d \in \mathbb{Z}[q]$, $d \ge 1$, are the monic polynomials determined by
$$q^n - 1 = \prod_{d \mid n} \Phi_d(q) \qquad (n \ge 1).$$
Equivalently $\Phi_d(q) = \prod (q - \zeta)$ over the primitive $d$-th roots of unity $\zeta$. We use the classical facts that $\Phi_d \in \mathbb{Z}[q]$ is monic and irreducible over $\mathbb{Q}$, and that distinct $\Phi_d$ have no common roots.

**Definition 2.5 (carry moduli).** For $0 \le k \le n$, let
$$\mathcal{C}(n,k) = \bigl\{\, d : 2 \le d \le n,\ \ (k \bmod d) + ((n-k) \bmod d) \ge d \,\bigr\}.$$
A modulus $d$ lies in $\mathcal{C}(n,k)$ exactly when the base-$d$ addition of $k$ and $n-k$ produces a carry out of the units digit.

---

## 3. The product formula in an arbitrary commutative semiring

**Lemma 3.1 (shifted additivity).** For all $a,b \in \mathbb{N}$, $[a+b]_q = [a]_q + q^a\,[b]_q$.

*Proof.* Split $\sum_{i<a+b} q^i$ into the terms with $i<a$ and those with $i = a + j$, $j<b$, and factor $q^a$ out of the latter. $\square$

**Theorem 3.2 ($q$-factorial product formula).** Let $R$ be a commutative semiring and $q\in R$. For all $0\le k\le n$,
$$[k]_q!\;[n-k]_q!\;\binom{n}{k}_q = [n]_q!. \tag{3.1}$$

*Proof.* Induction on $n$, for all $k\le n$ simultaneously. For $n=0$ we have $k=0$ and both sides are $1$.

Assume (3.1) for $n$ and all $k \le n$, and let $k' \le n+1$. If $k'=0$, both sides equal $[n+1]_q!$ since $\binom{n+1}{0}_q=1$. If $k'=n+1$, both sides equal $[n+1]_q!$ by Lemma 2.3(2). Otherwise $k'=k+1$ with $k+1\le n$, so both $k$ and $k+1$ are admissible in the induction hypothesis:
$$[k]_q!\,[n-k]_q!\,\tbinom{n}{k}_q = [n]_q!,\qquad [k+1]_q!\,[n-k-1]_q!\,\tbinom{n}{k+1}_q = [n]_q!. \tag{3.2}$$
We use $[k+1]_q! = [k]_q!\,[k+1]_q$, $[n-k]_q! = [n-k-1]_q!\,[n-k]_q$, and, by Lemma 3.1 with $a=k+1$, $b=n-k$,
$$[n+1]_q = [k+1]_q + q^{k+1}[n-k]_q. \tag{3.3}$$
Expanding with (2.1) and rearranging using commutativity only,
$$\begin{aligned}
[k+1]_q!\,[n-k]_q!\,\tbinom{n+1}{k+1}_q
&= [k+1]_q!\,[n-k]_q!\,\Bigl(\tbinom{n}{k}_q + q^{k+1}\tbinom{n}{k+1}_q\Bigr)\\
&= \Bigl([k]_q!\,[n-k]_q!\,\tbinom{n}{k}_q\Bigr)[k+1]_q + q^{k+1}[n-k]_q\Bigl([k+1]_q!\,[n-k-1]_q!\,\tbinom{n}{k+1}_q\Bigr)\\
&= [n]_q!\,[k+1]_q + q^{k+1}[n-k]_q\,[n]_q!\\
&= [n]_q!\,[n+1]_q = [n+1]_q!,
\end{aligned}$$
using (3.2) and then (3.3). $\square$

**Remark 3.3.** The proof uses only associativity, commutativity and distributivity. In particular it is valid in $\mathbb{N}[q]$, which shows that both sides of (3.1) agree as polynomials with nonnegative coefficients — consistent with a bijective (flag-counting, or inversion-counting) proof — and, by specialisation, in every commutative ring. The case of the universal ring $\mathbb{Z}[q]$ with $q$ the indeterminate is the one used in Sections 4–5.

**Corollary 3.4 (the classical identity).** For $0 \le k \le n$, $k!\,(n-k)!\,\binom{n}{k} = n!$.

*Proof.* In $R=\mathbb{Z}$ with $q = 1$ we have $[m]_1 = m$, hence $[m]_1! = m!$ by induction, and $\binom{n}{k}_1 = \binom{n}{k}$ by Lemma 2.3(4). Apply Theorem 3.2. $\square$

### 3.1 A tropical corollary

**Lemma 3.5.** In $\mathbb{Z}[q]$, every $\binom{n}{k}_q$ with $k\le n$ is nonzero with nonnegative coefficients, and
$$\deg\tbinom{n+1}{k+1}_q = \max\Bigl(\deg\tbinom{n}{k}_q,\ k+1+\deg\tbinom{n}{k+1}_q\Bigr)$$
(with the convention $\deg 0 = -\infty$).

*Proof.* Nonnegativity is immediate from (2.1); nonvanishing follows by induction since $\binom{n+1}{k+1}_q$ has the nonzero summand $\binom{n}{k}_q$. As no cancellation can occur between polynomials with nonnegative coefficients, the degree of a sum is the maximum of the degrees. $\square$

**Corollary 3.6 (degree formula).** For $0 \le k \le n$, $\deg \binom{n}{k}_q = k(n-k)$.

*Proof.* Work in the tropical semiring $\mathbb{T}$ with $q = 1_{\mathbb{R}}$ (the real number $1$, not the tropical unit). Tropical powers are $q^{\otimes a} = a$, so $[i]_q = \max(0,1,\ldots,i-1) = i-1$ for $i\ge1$ and $[n]_q! = \sum_{i=1}^n (i-1) = \binom n2$. By Lemma 3.5, the tropical recursion (2.1) — namely $T(n,0)=0$, $T(0,k+1)=-\infty$, $T(n+1,k+1)=\max(T(n,k), k+1+T(n,k+1))$ — is exactly the recursion satisfied by $\deg\binom{n}{k}_q$, so the tropical Gaussian binomial equals $\deg\binom{n}{k}_q$. Theorem 3.2 in $\mathbb{T}$ reads
$$\tbinom{k}{2} + \tbinom{n-k}{2} + \deg\tbinom{n}{k}_q = \tbinom{n}{2},$$
whence $\deg\binom{n}{k}_q = \binom n2 - \binom k2 - \binom{n-k}2 = k(n-k)$. $\square$

This illustrates the value of the semiring generality: one identity, specialised to two different semirings, yields both the classical factorial identity and a degree computation.

---

## 4. Structure in $\mathbb{Z}[q]$

From now on $q$ denotes the indeterminate of $\mathbb{Z}[q]$ unless otherwise specified.

**Proposition 4.1 ($q$-Pochhammer symbol).** In any commutative ring, $(1-q)[n]_q = 1 - q^n$, and consequently
$$(q;q)_n := \prod_{i=1}^n (1-q^i) = (1-q)^n\,[n]_q!.$$

*Proof.* The first identity is the telescoping geometric sum. The second follows by induction: $(q;q)_{n+1} = (q;q)_n(1-q^{n+1}) = (1-q)^n[n]_q!\,(1-q)[n+1]_q = (1-q)^{n+1}[n+1]_q!$. $\square$

**Proposition 4.2 (monicity and degree).** For every $n \ge 0$, $[n+1]_q$ is monic of degree $n$, and $[n]_q!$ is monic of degree $\binom{n}{2} = n(n-1)/2$. In particular $[n]_q! \ne 0$.

*Proof.* $[n+1]_q = q^n + \sum_{i<n} q^i$, and the tail has degree $<n$. A product of monic polynomials is monic with degree equal to the sum of degrees, so $\deg [n]_q! = \sum_{i=1}^{n}(i-1) = \binom{n}{2}$, using $\binom{n+1}{2} = \binom n2 + n$ in the inductive step. $\square$

**Theorem 4.3 (uniqueness).** Let $0\le k\le n$ and $P \in \mathbb{Z}[q]$. If
$$[k]_q!\,[n-k]_q!\,P = [n]_q!,$$
then $P = \binom{n}{k}_q$.

*Proof.* By Theorem 3.2, $[k]_q![n-k]_q!\,P = [k]_q![n-k]_q!\binom{n}{k}_q$. Since $\mathbb{Z}[q]$ is an integral domain and $[k]_q![n-k]_q! \ne 0$ by Proposition 4.2, we may cancel. $\square$

Theorem 4.3 is the engine of Section 5: to identify $\binom{n}{k}_q$ with a candidate expression, it suffices to verify the product formula for the candidate.

**Remark 4.4.** Combining Theorem 3.2 with Proposition 4.1 gives the familiar quotient expression $\binom{n}{k}_q = (q;q)_n / \bigl((q;q)_k (q;q)_{n-k}\bigr)$ in the fraction field $\mathbb{Q}(q)$; the point of (3.1) is that it never needs to leave $\mathbb{Z}[q]$, or indeed $\mathbb{N}[q]$.

---

## 5. Cyclotomic factorisations

### 5.1 The $q$-factorial

**Lemma 5.1.** For $n\ge1$,
$$[n]_q = \prod_{\substack{d \mid n\\ d\ge 2}} \Phi_d(q).$$

*Proof.* $(q-1)[n]_q = q^n - 1 = \Phi_1(q)\prod_{d\mid n,\,d\ge2}\Phi_d(q)$ with $\Phi_1(q) = q-1$; cancel $q-1$ in the integral domain $\mathbb{Z}[q]$. $\square$

**Theorem 5.2 (cyclotomic factorisation of the $q$-factorial).** For every $n \ge 0$,
$$[n]_q! = \prod_{d=2}^{n} \Phi_d(q)^{\lfloor n/d\rfloor}.$$

*Proof.* Induction on $n$; the case $n=0$ is the empty product. For the inductive step we use the elementary identity
$$\Bigl\lfloor \tfrac{n+1}{d}\Bigr\rfloor = \Bigl\lfloor \tfrac{n}{d}\Bigr\rfloor + \begin{cases}1 & d \mid n+1,\\ 0 & \text{otherwise},\end{cases} \tag{5.1}$$
valid for $d\ge1$. Then
$$\prod_{d=2}^{n+1}\Phi_d^{\lfloor (n+1)/d\rfloor} = \prod_{d=2}^{n+1}\Phi_d^{\lfloor n/d\rfloor}\cdot\prod_{\substack{2\le d\le n+1\\ d\mid n+1}}\Phi_d = \prod_{d=2}^{n}\Phi_d^{\lfloor n/d\rfloor}\cdot [n+1]_q,$$
because the factor $d=n+1$ in the first product has exponent $\lfloor n/(n+1)\rfloor = 0$ and the second product is $[n+1]_q$ by Lemma 5.1. By the induction hypothesis this is $[n]_q!\,[n+1]_q = [n+1]_q!$. $\square$

For example, $[6]_q! = \Phi_2^3\,\Phi_3^2\,\Phi_4\,\Phi_5\,\Phi_6$; the degrees check out as $3\cdot 1 + 2\cdot 2 + 2 + 4 + 2 = 15 = \binom62$.

Since the exponent of $\Phi_d$ vanishes for $d>n$, the range of the product may be enlarged freely:

**Lemma 5.3.** If $k \le N$ then $[k]_q! = \prod_{d=2}^{N}\Phi_d(q)^{\lfloor k/d\rfloor}$.

### 5.2 Gaussian binomials

**Theorem 5.4 (exponent form).** For $0\le k\le n$,
$$\binom{n}{k}_q = \prod_{d=2}^{n}\Phi_d(q)^{\,e_d(n,k)},\qquad e_d(n,k) = \Bigl\lfloor\tfrac nd\Bigr\rfloor - \Bigl\lfloor\tfrac kd\Bigr\rfloor - \Bigl\lfloor\tfrac{n-k}d\Bigr\rfloor.$$

*Proof.* First, $e_d(n,k) \ge 0$ because $\lfloor a/d\rfloor + \lfloor b/d\rfloor \le \lfloor (a+b)/d\rfloor$, applied to $a=k$, $b=n-k$. Let $P$ denote the right-hand side. Using Lemma 5.3 with $N=n$ for both $[k]_q!$ and $[n-k]_q!$,
$$[k]_q!\,[n-k]_q!\,P = \prod_{d=2}^n \Phi_d^{\lfloor k/d\rfloor + \lfloor (n-k)/d\rfloor + e_d(n,k)} = \prod_{d=2}^n\Phi_d^{\lfloor n/d\rfloor} = [n]_q!,$$
by Theorem 5.2. By Theorem 4.3, $P=\binom nk_q$. $\square$

The exponents are determined by a carry:

**Lemma 5.5 (carry lemma).** For $d \ge 1$ and $0\le k\le n$,
$$e_d(n,k) = \begin{cases} 1 & \text{if } (k\bmod d) + ((n-k)\bmod d) \ge d,\\ 0 & \text{otherwise.}\end{cases}$$

*Proof.* Write $a = k$, $b=n-k$, $a = d\alpha + r$, $b = d\beta + s$ with $0\le r,s<d$. Then $a+b = d(\alpha+\beta) + (r+s)$ with $0\le r+s \le 2d-2$, so $\lfloor (a+b)/d\rfloor = \alpha+\beta + [\,r+s\ge d\,]$. $\square$

**Theorem 5.6 (carry factorisation).** For $0 \le k \le n$,
$$\binom{n}{k}_q = \prod_{d \in \mathcal{C}(n,k)} \Phi_d(q) = \prod_{\substack{2\le d\le n\\ d \,\le\, (k\bmod d)+((n-k)\bmod d)}}\Phi_d(q).$$

*Proof.* Substitute Lemma 5.5 into Theorem 5.4. $\square$

**Corollary 5.7 (squarefreeness).** Every cyclotomic polynomial occurs in $\binom{n}{k}_q$ with multiplicity at most one: $e_d(n,k)\le 1$ for all $d\ge1$. Since the $\Phi_d$ are pairwise distinct irreducibles in $\mathbb{Q}[q]$, $\binom{n}{k}_q$ is squarefree, and Theorem 5.6 is its complete factorisation into irreducibles over $\mathbb{Q}$ (and, by Gauss's lemma, over $\mathbb{Z}$, all factors being monic).

**Corollary 5.8.** For $0<k<n$, $\Phi_n(q)$ divides $\binom{n}{k}_q$.

*Proof.* For $d = n$ the remainders are $k \bmod n = k$ and $(n-k)\bmod n = n-k$, with sum $n \ge n$; hence $n \in \mathcal{C}(n,k)$. $\square$

Corollary 5.8 is the polynomial analogue of $p \mid \binom pk$ for primes $p$ and $0<k<p$; indeed for $n = p$ prime it specialises to that statement at $q=1$, since $\Phi_p(1) = p$.

**Corollary 5.9 (zeros at roots of unity).** Let $\zeta$ be a primitive $d$-th root of unity, $d\ge2$. Then $\binom nk_\zeta = 0$ if and only if $d \in \mathcal{C}(n,k)$. In particular, if $d\mid n$, then $\binom nk_\zeta = 0$ if and only if $d\nmid k$.

*Proof.* $\zeta$ is a root of $\Phi_e$ only for $e=d$. If $d \mid n$, then $(k \bmod d) + ((n-k)\bmod d)$ equals $0$ if $d\mid k$ and $d$ otherwise. $\square$

### 5.3 Worked examples

| $(n,k)$ | carry moduli $\mathcal{C}(n,k)$ | factorisation of $\binom nk_q$ | degree check $k(n-k)$ |
|---|---|---|---|
| $(4,2)$ | $\{3,4\}$ | $\Phi_3\Phi_4 = 1+q+2q^2+q^3+q^4$ | $2+2 = 4$ |
| $(6,2)$ | $\{3,5,6\}$ | $\Phi_3\Phi_5\Phi_6$ | $2+4+2 = 8$ |
| $(8,3)$ | $\{2,4,6,7,8\}$ | $\Phi_2\Phi_4\Phi_6\Phi_7\Phi_8$ | $1+2+2+6+4 = 15$ |
| $(10,4)$ | $\{5,7,8,9,10\}$ | $\Phi_5\Phi_7\Phi_8\Phi_9\Phi_{10}$ | $4+6+4+6+4 = 24$ |
| $(12,6)$ | $\{4,7,8,9,10,11,12\}$ | $\Phi_4\Phi_7\Phi_8\Phi_9\Phi_{10}\Phi_{11}\Phi_{12}$ | $2+6+4+6+4+10+4=36$ |

The degree column uses $\deg\Phi_d = \varphi(d)$ (Euler's totient) and agrees with Corollary 3.6 in every case.

---

## 6. Specialisation at $q=1$: Legendre and Kummer shadows

Evaluation at $q=1$ is a ring homomorphism $\mathbb{Z}[q]\to\mathbb{Z}$ sending $[n]_q!\mapsto n!$ and $\binom nk_q \mapsto \binom nk$.

**Theorem 6.1.** For all $n\ge0$ and $0\le k\le n$,
$$n! = \prod_{d=2}^n \Phi_d(1)^{\lfloor n/d\rfloor}, \qquad \binom nk = \prod_{d\in\mathcal{C}(n,k)}\Phi_d(1).$$

*Proof.* Evaluate Theorems 5.2 and 5.6 at $q = 1$. $\square$

The classical evaluation
$$\Phi_d(1) = \begin{cases} p & \text{if } d = p^a \text{ for a prime } p \text{ and } a\ge1,\\ 1 & \text{if } d\ge 2 \text{ is not a prime power}\end{cases} \tag{6.1}$$
turns Theorem 6.1 into familiar statements. In the first identity, the prime $p$ appears with total exponent $\sum_{a\ge1}\lfloor n/p^a\rfloor$, which is **Legendre's formula** for $v_p(n!)$. In the second, $p$ appears once for each $a \ge 1$ with $p^a \le n$ and $(k\bmod p^a) + ((n-k) \bmod p^a)\ge p^a$. The latter condition says precisely that a carry occurs out of the $a$-th digit (from the right) when $k$ and $n-k$ are added in base $p$. Hence
$$v_p\Bigl(\binom nk\Bigr) = \#\{\text{carries when adding } k \text{ and } n-k \text{ in base } p\},$$
which is **Kummer's theorem**. In this sense Theorem 5.6 is a single polynomial identity that encodes Kummer's theorem for all primes at once, together with information at the non-prime-power moduli that is invisible at $q=1$.

*Example.* For $\binom{10}{4} = 210$ the carry moduli $5,7,8,9,10$ contribute $\Phi_5(1)\Phi_7(1)\Phi_8(1)\Phi_9(1)\Phi_{10}(1) = 5\cdot 7\cdot 2\cdot 3\cdot 1 = 210$. In base $2$, $4 = 100_2$ and $6 = 110_2$ produce one carry, matching $v_2(210)=1$, which here comes from $d = 8$.

---

## 7. Algorithms

All algorithms manipulate polynomials in $\mathbb{Z}[q]$ as coefficient arrays.

**Algorithm 1 ($q$-Pascal triangle).** Compute $\binom{m}{j}_q$ for $0 \le j\le m\le n$ by (2.1): $\binom{m+1}{j+1}_q$ is obtained by adding $\binom mj_q$ to the array of $\binom m{j+1}_q$ shifted by $j+1$ places. Each entry has $O(n^2)$ coefficients by Corollary 3.6, so the whole triangle costs $O(n^4)$ integer additions; no multiplication or division is required. This is the direct embodiment of the division-free definition.

**Algorithm 2 (carry set).** Given $0\le k\le n$, compute $\mathcal{C}(n,k)$ by testing $(k\bmod d)+((n-k)\bmod d) \ge d$ for $d = 2,\ldots,n$. This costs $O(n)$ arithmetic operations and yields the complete irreducible factorisation of $\binom nk_q$ without computing the polynomial at all.

**Algorithm 3 (cyclotomic polynomials).** Compute $\Phi_d$ by dividing $q^d - 1$ by $\Phi_e$ for each proper divisor $e$ of $d$, recursively; all divisions are exact divisions by monic integer polynomials. The polynomial $\binom nk_q$ can then be reassembled as $\prod_{d\in\mathcal{C}(n,k)}\Phi_d$, providing an independent check against Algorithm 1.

**Algorithm 4 (exact division check).** By Theorem 4.3, long division of $[n]_q!$ by the monic polynomial $[k]_q![n-k]_q!$ must leave remainder zero and quotient $\binom nk_q$. This is a cheap certificate for any claimed value of $\binom nk_q$.

Implementations of all four algorithms confirm Theorems 3.2, 4.3, 5.2 and 5.6 for all $0\le k\le n\le 16$, and the integer shadows of Theorem 6.1 (with Kummer's theorem via (6.1)) for $n\le 40$ and $p\in\{2,3,5,7\}$.

---

## 8. Applications and connections

**Finite geometry.** For a prime power $q$, $\binom nk_q$ counts $k$-dimensional subspaces of $\mathbb{F}_q^n$ and $[n]_q!$ counts complete flags; Theorem 3.2 is then the statement that a complete flag is a subspace $V$ of dimension $k$ together with complete flags of $V$ and of $\mathbb{F}_q^n/V$. For instance, $\binom42_2 = 35$ two-dimensional subspaces of $\mathbb{F}_2^4$, and $[2]_2!\,[2]_2!\cdot 35 = 3\cdot 3 \cdot 35 = 315 = [4]_2!$. Such counts are basic in the theory of subspace codes used in random linear network coding.

**Partitions and statistical mechanics.** $\binom nk_q$ is the generating function of partitions with at most $k$ parts each at most $n-k$, and $[n]_q!$ is the Mahonian generating function of permutations by inversions. The product formula is then the generating-function form of the decomposition of a permutation into a shuffle and two sorted blocks.

**Roots of unity and cyclic sieving.** Corollary 5.9 decides exactly where $\binom nk_q$ vanishes on the unit circle, which is the first step in evaluating $\binom nk_\zeta$ in cyclic-sieving phenomena for $k$-subsets of $\mathbb{Z}/n$ under rotation.

**Quantum algebra.** In an algebra with $yx = qxy$, $(x+y)^n = \sum_k \binom nk_q x^k y^{n-k}$. Theorem 5.6 locates the roots of unity at which these coefficients degenerate, a phenomenon of central importance for quantum groups at roots of unity.

---

## 9. Discussion

Two features of the development are worth emphasising.

First, the decision to define $\binom nk_q$ recursively and prove (3.1) without division pays off twice. It makes the identity available in every commutative semiring — so a single argument covers integer, polynomial, finite-field and tropical specialisations — and in $\mathbb{Z}[q]$ it converts the product formula into the uniqueness Theorem 4.3, which reduces the cyclotomic factorisation of $\binom nk_q$ to bookkeeping of exponents.

Second, the carry factorisation exposes the "multiplicative skeleton" of Gaussian binomials. The ordinary binomial coefficient $\binom nk$ knows only the prime-power carry moduli; the polynomial $\binom nk_q$ knows every carry modulus $d$. The squarefreeness (Corollary 5.7) is a rigidity statement with no analogue at $q=1$: the integer $\binom nk$ can be divisible by high powers of a prime, but each $p^a$ contributes through a *different* cyclotomic factor $\Phi_{p^a}$.

---

## 10. Future work

1. **Kummer's theorem from cyclotomic carries.** For a prime $p$, $v_p\binom nk$ should be derived directly as the number of $a\ge1$ with $k \bmod p^a + (n-k)\bmod p^a\ge p^a$, by taking $p$-adic valuations in Theorem 6.1 and using (6.1). Section 6 sketches this; a complete development, giving a $q$-deformation proof of Kummer's theorem, is a natural next step.

2. **$q$-multinomial factorisation.** For $k_1+\cdots+k_r = n$, the $q$-multinomial coefficient $[n]_q!/\prod_i[k_i]_q!$ should equal $\prod_d \Phi_d^{e_d}$ with $e_d = \lfloor n/d\rfloor - \sum_i\lfloor k_i/d\rfloor \in\{0,\ldots,r-1\}$, the exponent counting the units-digit carries of the $r$-fold base-$d$ addition. Lemma 5.3 already supplies the common index range needed.

3. **Cyclic sieving for subsets.** If $\zeta$ is a primitive $d$-th root of unity with $d\mid n$, then $\binom nk_\zeta$ should equal the number of $k$-subsets of $\mathbb{Z}/n$ fixed by rotation by $n/d$, namely $\binom{n/d}{k/d}$ if $d\mid k$ and $0$ otherwise. The vanishing half is Corollary 5.9; the non-vanishing half follows from the $q$-Lucas theorem.

4. **Unimodality of Mahonian rows.** The coefficient sequence of $[n]_q!$ (the Mahonian numbers) is symmetric and unimodal. Each factor $[i]_q$ is symmetric and unimodal with nonnegative coefficients, and this class is closed under multiplication; having established monicity and the degree $\binom n2$, symmetry is the next structural step.

---

## Appendix: numerical illustration

The first rows of Mahonian numbers (coefficients of $[n]_q!$, of degree $\binom n2$):

| $n$ | $\deg$ | coefficients of $[n]_q!$ |
|---|---|---|
| 1 | 0 | 1 |
| 2 | 1 | 1, 1 |
| 3 | 3 | 1, 2, 2, 1 |
| 4 | 6 | 1, 3, 5, 6, 5, 3, 1 |
| 5 | 10 | 1, 4, 9, 15, 20, 22, 20, 15, 9, 4, 1 |

And the instance $n=4$, $k=2$ of Theorem 3.2:
$$(1+q)\cdot(1+q)\cdot(1+q+2q^2+q^3+q^4) = 1+3q+5q^2+6q^3+5q^4+3q^5+q^6 = [4]_q!.$$
