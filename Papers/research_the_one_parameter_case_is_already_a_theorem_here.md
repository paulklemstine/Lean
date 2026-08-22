# Height Reduction for Cyclotomic Polynomials: the Odd Radical, the Flat Class, and the Ternary Trichotomy

**Author:** Aristotle
**Date:** 2026-08-22

---

## Abstract

Let $\Phi_n \in \mathbb{Z}[X]$ denote the $n$-th cyclotomic polynomial and let its **height** $H(n)$ be the largest absolute value of its coefficients. We develop a complete reduction theory for $H$ built from two elementary symmetries — *inflation* $\Phi_{np}(X)=\Phi_n(X^p)$ for $p \mid n$, and *reflection* $\Phi_{2n}(X)=\Phi_n(-X)$ for odd $n>1$ — and prove the **height reduction theorem**: for every $n \ge 1$ and every $B$, all coefficients of $\Phi_n$ are bounded by $B$ in absolute value if and only if the same holds for $\Phi_{\mathrm{rad}_{\mathrm{odd}}(n)}$, where $\mathrm{rad}_{\mathrm{odd}}(n)$ is the product of the odd primes dividing $n$. Consequently $H(n) = H(\mathrm{rad}_{\mathrm{odd}}(n))$: the height is blind to the prime $2$ and to repeated prime factors.

Coupling this with the two-parameter (Migotti) theorem yields the **flatness classification**: $\Phi_n$ has all coefficients in $\{-1,0,1\}$ whenever the odd part of $n$ has at most two distinct prime divisors; and the bound is attained, since $[X^{p^{a-1}q^{b-1}}]\Phi_{p^aq^b} = -1$. Since $105 = 3\cdot5\cdot7$ is the least integer with three distinct odd prime divisors, this explains why every $\Phi_n$ with $n < 105$ is flat.

We then determine three ternary cyclotomic polynomials exactly, by cancellation in the associated Möbius identity, and read off their heights: $\Phi_{231}$ (degree $120$) is flat; $\Phi_{105}$ (degree $48$) has height exactly $2$, attained at $X^7$ and $X^{41}$; $\Phi_{385}$ (degree $240$) has height exactly $3$, attained at $X^{119}, X^{120}, X^{121}$. Since height reduction propagates each value to the whole odd-radical class, we obtain three infinite families of orders — with odd radicals $231$, $105$, $385$ — of heights $1$, $2$, $3$ respectively, **all having exactly three odd prime divisors**. Hence $\omega_{\mathrm{odd}}$ does not determine the height, while $\mathrm{rad}_{\mathrm{odd}}$ does; and the flatness classification is a strict implication, not an equivalence. Finally we show that height $1$ is exactly flatness (monicity forbids height $0$), and that every coefficient of the flat two-prime-power families is an explicit difference of indicator functions of the numerical semigroup $\langle p, q\rangle$, so that the whole flat theory is a lattice-point count.

**Keywords:** cyclotomic polynomial, coefficient height, flat polynomial, odd radical, numerical semigroup, Bang's bound, ternary cyclotomic polynomial.

---

## 1. Introduction

### 1.1 The problem

For $n \ge 1$ the $n$-th cyclotomic polynomial is
$$\Phi_n(X) = \prod_{\substack{1 \le k \le n\\ \gcd(k,n)=1}} \left(X - e^{2\pi i k/n}\right),$$
the minimal polynomial over $\mathbb{Q}$ of a primitive $n$-th root of unity. It is monic of degree $\varphi(n)$, it has integer coefficients, and it is characterized among integer polynomials by the divisor product identity
$$\prod_{d \mid n} \Phi_d(X) = X^n - 1. \tag{1.1}$$

Write $\Phi_n = \sum_k a_n(k)X^k$ and define the **height**
$$H(n) = \max_k |a_n(k)| = \min\{B \in \mathbb{Z} : |a_n(k)| \le B \text{ for all } k\}.$$

Empirically the height is stubbornly equal to $1$. The polynomial $\Phi_n$ is called **flat** when $a_n(k) \in \{-1,0,1\}$ for all $k$, i.e. when $H(n)=1$. Every $\Phi_n$ with $n < 105$ is flat, and the observation that heights exceed $1$ at all is a genuine nineteenth-century surprise. Our aim is to give a structural account of *why* flatness persists so long, *where* it stops, and *what invariant of $n$* actually controls the height.

### 1.2 Results

Let $\mathrm{rad}_{\mathrm{odd}}(n) = \prod_{p \mid n,\, p \ne 2,\, p \text{ prime}} p$ and let $\omega_{\mathrm{odd}}(n)$ be the number of odd primes dividing $n$.

1. **Height reduction (Theorem 4.1).** For $n \ge 1$ and $B \in \mathbb{Z}$: $|a_n(k)|\le B$ for all $k$ $\iff$ $|a_{\mathrm{rad}_{\mathrm{odd}}(n)}(k)| \le B$ for all $k$. Hence $H(n) = H(\mathrm{rad}_{\mathrm{odd}}(n))$.
2. **Flatness classification (Theorem 5.3).** If $\omega_{\mathrm{odd}}(n)\le 2$ then $\Phi_n$ is flat; the bound is sharp, since $a_{p^aq^b}(p^{a-1}q^{b-1}) = -1$ for distinct primes $p\neq q$ and $a,b\ge1$.
3. **The explicit $\Phi_{105}$ (Theorem 6.2).** $\Phi_{105}$ equals an explicit degree-$48$ polynomial with $a_{105}(7)=a_{105}(41) = -2$ and all other coefficients in $\{-1,0,1\}$; hence $H(105)=2$, and $H(2^a3^{b+1}5^{c+1}7^{d+1})=2$ for all $a,b,c,d\ge0$.
4. **The flat ternary order $231$ (Theorem 7.1).** $\Phi_{231}$ equals an explicit degree-$120$ polynomial with all coefficients in $\{-1,0,1\}$; hence $H(231)=1$ although $\omega_{\mathrm{odd}}(231)=3$, and the classification of (2) is not an equivalence. Every $n$ with $\mathrm{rad}_{\mathrm{odd}}(n)=231$ is flat.
5. **The height-three order $385$ (Theorem 8.1).** $\Phi_{385}$ equals an explicit degree-$240$ polynomial with $a_{385}(119)=a_{385}(120)=a_{385}(121)=-3$ and all coefficients in $[-3,3]$; hence $H(385)=3$, and $H(2^a5^{b+1}7^{c+1}11^{d+1})=3$.
6. **Height one is flatness; the ternary trichotomy (Theorems 9.1, 9.4).** $H(n)=1 \iff \Phi_n$ flat; $H$ is an invariant of $\mathrm{rad}_{\mathrm{odd}}$; and $H(231)=1$, $H(105)=2$, $H(385)=3$ with $\omega_{\mathrm{odd}} = 3$ throughout.
7. **The lattice-point formula for the flat family (Theorem 10.2).** Every coefficient of $\Phi_{2^{\alpha}p^{\beta+1}q^{\gamma+1}}$ at an inflated index is $\pm$ a difference of indicators of the numerical semigroup $\langle p,q \rangle$.

### 1.3 Method

Three techniques are used throughout, and they are worth isolating.

* **Symmetry transport.** Inflation and reflection are coefficient-level isometries: they permute indices and multiply by signs, so they preserve the multiset $\{|a_n(k)|\}$ of coefficient magnitudes exactly. Every height statement therefore descends along them.
* **Cancellation from the Möbius identity.** For squarefree $n=pqr$, grouping (1.1) by inclusion–exclusion produces a *cyclotomic-free* polynomial identity that determines $\Phi_{pqr}$ up to a non-zero-divisor factor. Verifying a candidate polynomial in that identity is a finite algebraic computation and constitutes a complete proof of the explicit form.
* **Lattice-point counting.** In the two-prime case coefficients are literally counts of solutions to $ip+jq=m$ in a box, which is why the flat bound is an identity and not an estimate.

---

## 2. Setup and notation

Throughout, $p, q, r$ denote primes and $n, m, k, a, b, c, d, \alpha, \beta, \gamma$ nonnegative integers. We work in $\mathbb{Z}[X]$.

**Definition 2.1 (Cyclotomic polynomial).** $\Phi_n \in \mathbb{Z}[X]$ is the monic polynomial of degree $\varphi(n)$ whose roots are the primitive $n$-th roots of unity; equivalently, it is determined recursively by $\Phi_1 = X-1$ and (1.1).

**Definition 2.2 (Coefficients, boundedness, height).** Write $a_n(k) = [X^k]\Phi_n$. Say $\Phi_n$ is **bounded by $B$**, written $\mathcal{B}(n,B)$, if $|a_n(k)| \le B$ for all $k \ge 0$. The **height** is $H(n) = \min\{B : \mathcal{B}(n,B)\}$, i.e. the least element of $\{B \in \mathbb{Z} : \mathcal{B}(n,B)\}$.

**Definition 2.3 (Flatness).** $\Phi_n$ is **flat** if $\mathcal{B}(n,1)$, i.e. $a_n(k) \in \{-1,0,1\}$ for all $k$.

**Definition 2.4 (Odd radical).** $\mathrm{rad}_{\mathrm{odd}}(n) = \prod_{p \in \mathrm{P}(n)\setminus\{2\}} p$, where $\mathrm{P}(n)$ is the set of primes dividing $n$. We write $\omega_{\mathrm{odd}}(n) = \#(\mathrm{P}(n)\setminus\{2\})$. Note $\mathrm{rad}_{\mathrm{odd}}(1)=\mathrm{rad}_{\mathrm{odd}}(2)=1$ and $\mathrm{rad}_{\mathrm{odd}}(2^a m)=\mathrm{rad}_{\mathrm{odd}}(m)$ for $m\ne0$.

**Definition 2.5 (Numerical semigroup and representability).** For distinct primes $p,q$, say $m \in \mathbb{Z}_{\ge0}$ is **$(p,q)$-representable**, written $m \in \langle p,q\rangle$, if $m = ip + jq$ for some $i,j \in \mathbb{Z}_{\ge0}$.

**Remark 2.6 (Trivial facts used freely).** $\Phi_n$ is monic, hence $a_n(\varphi(n)) = 1$ and $\mathcal{B}(n,B) \Rightarrow B \ge 1$. Also $\Phi_1 = X - 1$ and $\Phi_2 = X+1$ have the same coefficient magnitudes, so $\mathcal{B}(1,B) \iff \mathcal{B}(2,B)$.

---

## 3. The two structural symmetries

### 3.1 Inflation

**Lemma 3.1 (Inflation).** *Let $p$ be prime with $p \mid n$. Then $\Phi_{np}(X) = \Phi_n(X^p)$; equivalently, for all $k$,*
$$a_{np}(k) = \begin{cases} a_n(k/p) & \text{if } p \mid k,\\ 0 & \text{otherwise.}\end{cases}$$

*Proof sketch.* A primitive $np$-th root of unity is exactly a $p$-th root of a primitive $n$-th root of unity when $p \mid n$, since then $\varphi(np)=p\varphi(n)$ and no degeneration occurs; the identity is the classical prime-power substitution rule, and the coefficient form is the definition of substituting $X \mapsto X^p$. $\square$

**Corollary 3.2 (Iterated inflation).** *If $p \mid n$ then for all $c, k \ge 0$: $a_{np^c}(k p^c) = a_n(k)$, and $a_{np^c}(j)=0$ unless $p^c \mid j$. In particular $\Phi_{np^c}$ and $\Phi_n$ have the same multiset of nonzero coefficients, so $\mathcal{B}(np^c,B) \iff \mathcal{B}(n,B)$ for every $B \ge 0$.*

*Proof sketch.* Induct on $c$ using Lemma 3.1, noting $p \mid np^{c}$ at each stage. For the equivalence: the forward direction restricts to indices $kp^c$; the backward direction covers the remaining indices, where the coefficient is $0$ and $B \ge 0$. $\square$

### 3.2 Reflection

**Lemma 3.3 (Odd half-frame product).** *For odd $n > 0$, $\prod_{d \mid n}\Phi_{2d}(X) = X^n + 1$.*

*Proof sketch.* Since $n$ is odd, every divisor of $2n$ is either a divisor $d$ of $n$ or of the form $2d$ with $d \mid n$, and these two families are disjoint. Applying (1.1) at $2n$ and factoring out $\prod_{d\mid n}\Phi_d = X^n-1$ from $X^{2n}-1=(X^n-1)(X^n+1)$ gives the claim after cancelling the non-zero factor $X^n-1$ in the integral domain $\mathbb{Z}[X]$. $\square$

**Lemma 3.4 (Reflected divisor product).** *For odd $n > 0$, $\prod_{d\mid n}\Phi_d(-X) = -(X^n+1)$.*

*Proof sketch.* Substitute $X \mapsto -X$ in (1.1); since $n$ is odd, $(-X)^n - 1 = -(X^n+1)$. $\square$

**Theorem 3.5 (Reflection law).** *For odd $n > 1$, $\Phi_{2n}(X) = \Phi_n(-X)$; equivalently $a_{2n}(k) = (-1)^k a_n(k)$, and therefore $|a_{2n}(k)| = |a_n(k)|$ for all $k$.*

*Proof sketch.* Strong induction on $n$. Split both products of Lemmas 3.3 and 3.4 over $\{n\} \cup \{1\} \cup (\text{proper divisors} > 1)$. The tails over proper divisors $d>1$ agree term by term by the induction hypothesis, each such $d$ being odd and $>1$. The $d=1$ factors are $\Phi_2 = X+1$ on one side and $\Phi_1(-X) = -X-1 = -(X+1)$ on the other, which accounts exactly for the sign discrepancy between the two lemmas. Cancelling the common non-zero factor $(X+1)\prod_{d}\Phi_d(-X)$ — non-zero because substitution by $-X$ is a ring automorphism of $\mathbb{Z}[X]$ and each $\Phi_d \ne 0$ — leaves $\Phi_{2n}(X)=\Phi_n(-X)$. The coefficient statement follows since composing with $-X$ multiplies the $k$-th coefficient by $(-1)^k$. $\square$

**Remark 3.6.** Both symmetries are *isometries of the coefficient vector*: inflation is an index dilation with zero padding, reflection is an alternating sign flip. Neither can change $H$.

---

## 4. Height reduction

**Theorem 4.1 (Height reduction).** *For every $n \ge 1$ and every $B \in \mathbb{Z}$,*
$$\mathcal{B}(n,B) \iff \mathcal{B}\bigl(\mathrm{rad}_{\mathrm{odd}}(n),\,B\bigr).$$
*Consequently $H(n) = H(\mathrm{rad}_{\mathrm{odd}}(n))$.*

*Proof sketch.* Strong induction on $n$. The cases $n=1$ and $n=2$ are Remark 2.6 together with $\mathrm{rad}_{\mathrm{odd}}(1)=\mathrm{rad}_{\mathrm{odd}}(2)=1$. For $n \ge 3$ distinguish:

*Case A: $n$ not squarefree.* Choose a prime $p$ with $p^2 \mid n$ and write $n = (n/p)\cdot p$ with $p \mid n/p$. Corollary 3.2 gives $\mathcal{B}(n,B)\iff\mathcal{B}(n/p,B)$, and $\mathrm{rad}_{\mathrm{odd}}(n)=\mathrm{rad}_{\mathrm{odd}}(n/p)$ because $n$ and $n/p$ have the same prime support. Apply the induction hypothesis to $n/p < n$.

*Case B: $n$ squarefree and odd.* Then $\mathrm{rad}_{\mathrm{odd}}(n)=n$ and there is nothing to prove.

*Case C: $n$ squarefree and even.* Write $n = 2m$ with $m$ odd; squarefreeness forces $4 \nmid n$, and $n \ge 3$ forces $m > 1$. Theorem 3.5 gives $\mathcal{B}(2m,B)\iff\mathcal{B}(m,B)$, and $\mathrm{rad}_{\mathrm{odd}}(2m)=\mathrm{rad}_{\mathrm{odd}}(m)$. Apply the induction hypothesis to $m<n$. $\square$

**Corollary 4.2.** *Flatness depends only on the odd radical: $\Phi_n$ is flat $\iff$ $\Phi_{\mathrm{rad}_{\mathrm{odd}}(n)}$ is flat.*

**Corollary 4.3 (Radical classes).** *If $\mathrm{rad}_{\mathrm{odd}}(m)=\mathrm{rad}_{\mathrm{odd}}(n)$ then $\{B : \mathcal{B}(m,B)\} = \{B : \mathcal{B}(n,B)\}$, so $H(m)=H(n)$. Contrapositively, $H(m)\ne H(n)$ forces $\mathrm{rad}_{\mathrm{odd}}(m)\ne\mathrm{rad}_{\mathrm{odd}}(n)$.*

Theorem 4.1 is the organizing principle of the paper: it reduces *all* height questions to squarefree odd orders, and it converts any single explicit computation into a statement about an infinite family.

---

## 5. The flat class

### 5.1 The two-parameter theorem and its lattice-point content

**Theorem 5.1 (Two-parameter / Migotti).** *For distinct primes $p\ne q$, $\Phi_{pq}$ is flat. More precisely, for $0 < m < pq$,*
$$a_{pq}(m) = \mathbf 1\{m \in \langle p,q\rangle\} - \mathbf 1\{m-1 \in \langle p,q\rangle\}. \tag{5.1}$$

*Proof sketch.* From $\Phi_{pq} = \frac{(X^{pq}-1)(X-1)}{(X^p-1)(X^q-1)}$ one gets, as formal power series modulo $X^{pq}$,
$$\Phi_{pq}(X) \equiv (1-X)\cdot\Bigl(\sum_{i\ge0}X^{ip}\Bigr)\Bigl(\sum_{j\ge0}X^{jq}\Bigr) \pmod{X^{pq}},$$
and the coefficient of $X^m$ in $\bigl(\sum_i X^{ip}\bigr)\bigl(\sum_j X^{jq}\bigr)$ is the number of representations $m = ip+jq$ with $i,j\ge0$. The key **box-uniqueness lemma** says that for $0 \le m < pq$ there is at most one such pair with $0\le i<q$, $0\le j<p$ — indeed if $ip+jq = i'p+j'q$ then $p \mid (j-j')q$, so $p \mid j-j'$, and $|j-j'|<p$ forces $j=j'$, then $i=i'$ — and for $m<pq$ any representation automatically lies in the box. Hence the representation count is $\mathbf 1\{m \in \langle p,q\rangle\}$ and multiplying by $(1-X)$ gives (5.1). Since a difference of two indicators lies in $\{-1,0,1\}$, flatness follows for $0<m<pq$; the remaining coefficients vanish beyond $\deg \Phi_{pq}=(p-1)(q-1)$ or are covered by the same formula. $\square$

**Lemma 5.2 (Sharpness at two primes).** *For distinct primes $p\ne q$ and $a,b\ge1$: $a_{p^aq^b}(p^{a-1}q^{b-1}) = -1$.*

*Proof sketch.* By (5.1) with $m=1$, $a_{pq}(1) = \mathbf1\{1\in\langle p,q\rangle\}-\mathbf1\{0\in\langle p,q\rangle\} = 0-1=-1$. Now inflate twice by Corollary 3.2: applying it with $p$ (exponent $a-1$) and then with $q$ (exponent $b-1$) transports the index $1$ to $p^{a-1}q^{b-1}$ and preserves the value. $\square$

### 5.2 The classification

**Theorem 5.3 (Flatness classification).** *Let $n \ge 1$. If $\omega_{\mathrm{odd}}(n) \le 2$ — equivalently, if the odd part of $n$ has at most two distinct prime divisors — then $\Phi_n$ is flat.*

*Proof sketch.* By Corollary 4.2 it suffices to treat $m = \mathrm{rad}_{\mathrm{odd}}(n)$, which is odd, squarefree, and has at most two prime factors, i.e. $m \in \{1, p, pq\}$. These are flat by $\Phi_1 = X-1$, by $\Phi_p = 1 + X + \cdots + X^{p-1}$, and by Theorem 5.1 respectively.

Equivalently, and without invoking Theorem 4.1, one can argue directly: write $n = 2^a m$ with $m$ odd. If $m=1$, $\Phi_n$ is a cyclotomic polynomial of prime-power order $2^a$, which is $\Phi_{2^a}=X^{2^{a-1}}+1$ (or $\Phi_1$), flat. If $m>1$ has at most two prime divisors, then $\Phi_m$ is flat by Theorem 5.1 plus prime-power inflation (Corollary 3.2), $\Phi_{2m}$ is flat by Theorem 3.5, and $\Phi_{2^am}=\Phi_{(2m)\cdot 2^{a-1}}$ is flat by Corollary 3.2 again. $\square$

**Corollary 5.4 (Why $105$ is the threshold).** *Every $n < 105$ satisfies $\omega_{\mathrm{odd}}(n) \le 2$, since the least integer with three distinct odd prime divisors is $3\cdot5\cdot7=105$. Hence $\Phi_n$ is flat for all $n<105$.*

This is the precise explanation for the classical illusion: flatness for $n<105$ is not numerology, it is Theorem 5.3 with a counting observation about smallest products.

---

## 6. The explicit $\Phi_{105}$ and height exactly two

### 6.1 The Möbius identity at a squarefree ternary order

**Lemma 6.1 (Ternary Möbius identity).** *For distinct odd primes $p,q,r$ with $n=pqr$,*
$$\Phi_{n}\cdot (X-1)(X^{pq}-1)(X^{pr}-1)(X^{qr}-1) \;=\; (X^{p}-1)(X^{q}-1)(X^{r}-1)(X^{n}-1). \tag{6.1}$$
*Specializing $(p,q,r)=(3,5,7)$:*
$$\Phi_{105}\cdot(X-1)(X^{15}-1)(X^{21}-1)(X^{35}-1) = (X^{3}-1)(X^{5}-1)(X^{7}-1)(X^{105}-1).$$

*Proof sketch.* Apply (1.1) at each of the eight divisors $1,p,q,r,pq,pr,qr,pqr$ of $n$: $X^{d}-1 = \prod_{e \mid d}\Phi_e$. Substituting these eight expansions into both sides of (6.1) and cancelling, every $\Phi_e$ occurs with total multiplicity $\sum_{e \mid d \mid n}\mu(n/d) = 0$ except for $e = n$, which survives once on the right; this is inclusion–exclusion over the divisor lattice of a squarefree number with three prime factors. $\square$

The right-hand side of (6.1) is *cyclotomic-free*, so (6.1) characterizes $\Phi_n$: the factor $(X-1)(X^{pq}-1)(X^{pr}-1)(X^{qr}-1)$ is a nonzero element of the integral domain $\mathbb{Z}[X]$ (each $X^m-1$ has value $-1$ at $X=0$), hence cancellable. This yields a *verification principle*:

> **Verification principle.** If $P \in \mathbb{Z}[X]$ satisfies $P \cdot (X-1)(X^{pq}-1)(X^{pr}-1)(X^{qr}-1) = (X^p-1)(X^q-1)(X^r-1)(X^{pqr}-1)$, then $P = \Phi_{pqr}$.

Verifying the hypothesis for an explicit candidate is a finite polynomial expansion — a complete proof, not a numerical check.

### 6.2 The polynomial

**Theorem 6.2 (Explicit $\Phi_{105}$).** *$\Phi_{105}$ has degree $\varphi(105)=48$ and*
$$\begin{aligned}
\Phi_{105} = \;& X^{48}+X^{47}+X^{46}-X^{43}-X^{42}-2X^{41}-X^{40}-X^{39}\\
&+X^{36}+X^{35}+X^{34}+X^{33}+X^{32}+X^{31}\\
&-X^{28}-X^{26}-X^{24}-X^{22}-X^{20}\\
&+X^{17}+X^{16}+X^{15}+X^{14}+X^{13}+X^{12}\\
&-X^{9}-X^{8}-2X^{7}-X^{6}-X^{5}+X^{2}+X+1 .
\end{aligned}$$
*Its coefficient vector, indices $0$ to $48$, is*
$$(1,1,1,0,0,-1,-1,-2,-1,-1,0,0,1,1,1,1,1,1,0,0,-1,0,-1,0,-1,0,-1,0,-1,0,0,1,1,1,1,1,1,0,0,-1,-1,-2,-1,-1,0,0,1,1,1).$$

*Proof sketch.* Let $P$ be the displayed polynomial. Expanding $P\cdot(X-1)(X^{15}-1)(X^{21}-1)(X^{35}-1)$ and comparing with $(X^3-1)(X^5-1)(X^7-1)(X^{105}-1)$ gives equality (a degree-$120$ identity, checkable term by term). By the verification principle, $P = \Phi_{105}$. $\square$

**Corollary 6.3 (Bang's bound at $105$, and its attainment).** *Every coefficient of $\Phi_{105}$ lies in $\{-2,-1,0,1,2\}$, and $a_{105}(7)=a_{105}(41)=-2$. Hence $H(105)=2$: the set $\{B : \mathcal B(105,B)\}$ has least element $2$.*

*Proof sketch.* Inspect the $49$ entries of the coefficient list for the upper bound and for the two values $-2$; the coefficients beyond index $48$ vanish. Minimality: any $B$ with $\mathcal B(105,B)$ satisfies $B \ge |a_{105}(7)| = 2$. $\square$

The bound $2$ is Bang's bound $p-1$ for the smallest odd prime $p=3$ of $105$: the ternary frame at $105$ is *extremal* for Bang.

### 6.3 An infinite family of height two

**Theorem 6.4.** *For all $a,b,c,d \ge 0$, $\mathrm{rad}_{\mathrm{odd}}\bigl(2^a3^{b+1}5^{c+1}7^{d+1}\bigr) = 105$, and hence*
$$H\bigl(2^a3^{b+1}5^{c+1}7^{d+1}\bigr) = 2 .$$
*In particular none of these cyclotomic polynomials is flat.*

*Proof sketch.* The prime support of $2^a3^{b+1}5^{c+1}7^{d+1}$ is contained in $\{2,3,5,7\}$ and contains $\{3,5,7\}$, so its odd radical is $3\cdot5\cdot7=105$. Apply Theorem 4.1 and Corollary 6.3. Non-flatness follows since $1 < 2 = H$. $\square$

**Corollary 6.5 (Two-sided delimitation of the flat class).** *If $\omega_{\mathrm{odd}}(m)\le2$ then $\Phi_m$ is flat (Theorem 5.3); and for every $n$ in the family of Theorem 6.4, $\Phi_n$ is not flat.*

---

## 7. A flat ternary order: $231 = 3\cdot7\cdot11$

**Theorem 7.1 (Explicit $\Phi_{231}$).** *$\Phi_{231}$ has degree $\varphi(231)=120$ and equals*
$$\begin{aligned}
\Phi_{231} = \;& 1+X+X^{2}-X^{7}-X^{8}-X^{9}-X^{11}-X^{12}-X^{13}\\
&+X^{18}+X^{19}+X^{20}+X^{21}+X^{22}+X^{23}\\
&-X^{28}-X^{29}-X^{30}-X^{32}+X^{35}+X^{39}+X^{43}\\
&-X^{45}-X^{46}-X^{49}-X^{50}+X^{52}+X^{56}+X^{60}+X^{64}+X^{68}\\
&-X^{70}-X^{71}-X^{74}-X^{75}+X^{77}+X^{81}+X^{85}\\
&-X^{88}-X^{90}-X^{91}-X^{92}+X^{97}+X^{98}+X^{99}+X^{100}+X^{101}+X^{102}\\
&-X^{107}-X^{108}-X^{109}-X^{111}-X^{112}-X^{113}+X^{118}+X^{119}+X^{120},
\end{aligned}$$
*all of whose $121$ coefficients lie in $\{-1,0,1\}$. Hence $\Phi_{231}$ is flat and $H(231)=1$.*

*Proof sketch.* Lemma 6.1 with $(p,q,r)=(3,7,11)$ reads
$$\Phi_{231}\cdot(X-1)(X^{21}-1)(X^{33}-1)(X^{77}-1) = (X^3-1)(X^7-1)(X^{11}-1)(X^{231}-1).$$
Expanding the displayed candidate against the left-hand side and matching the right-hand side, then cancelling the nonzero factor, identifies the candidate with $\Phi_{231}$. Flatness is then inspection of the $121$ coefficients. $\square$

**Theorem 7.2 (The classification is not an equivalence).** *There exists $n$ with $\omega_{\mathrm{odd}}(n) = 3$ and $\Phi_n$ flat; indeed $n=231$ works. Moreover, every $n$ with $\mathrm{rad}_{\mathrm{odd}}(n)=231$ — e.g. every $n = 2^a3^{b}7^{c}11^{d}$ with $b,c,d\ge1$ — has $\Phi_n$ flat.*

*Proof sketch.* The first claim is Theorem 7.1 and $\mathrm{P}(231)\setminus\{2\}=\{3,7,11\}$. The second is Corollary 4.2 applied to $\mathrm{rad}_{\mathrm{odd}}(n)=231$. $\square$

So the hypothesis $\omega_{\mathrm{odd}}\le2$ of Theorem 5.3 is sufficient but strictly not necessary, and the flat class contains infinitely many orders with three odd prime divisors.

---

## 8. Height three: $385 = 5\cdot7\cdot11$

**Theorem 8.1 (Explicit $\Phi_{385}$ and its height).** *$\Phi_{385}$ has degree $\varphi(385)=240$; all of its coefficients lie in $[-3,3]$, and*
$$a_{385}(119)=a_{385}(120)=a_{385}(121)=-3 .$$
*Hence $H(385)=3$. In particular $\Phi_{385}$ is not flat and is not bounded by $2$.*

*Proof sketch.* Lemma 6.1 with $(p,q,r)=(5,7,11)$ gives
$$\Phi_{385}\cdot(X-1)(X^{35}-1)(X^{55}-1)(X^{77}-1) = (X^{5}-1)(X^{7}-1)(X^{11}-1)(X^{385}-1),$$
which determines $\Phi_{385}$ uniquely by the verification principle; an explicit degree-$240$ candidate with $241$ integer coefficients satisfies it. Its extreme entries are three consecutive $-3$'s at indices $119,120,121$, symmetric about the centre $120 = \tfrac12\varphi(385)$, and no entry exceeds $3$ in absolute value. Minimality of $3$ follows from $|a_{385}(119)|=3$. $\square$

**Theorem 8.2 (An infinite family of height three).** *For all $a,b,c,d\ge0$, $\mathrm{rad}_{\mathrm{odd}}\bigl(2^a5^{b+1}7^{c+1}11^{d+1}\bigr)=385$, and hence $H\bigl(2^a5^{b+1}7^{c+1}11^{d+1}\bigr)=3$.*

*Proof sketch.* As in Theorem 6.4, via Theorem 4.1. $\square$

Note that Bang's bound for $385$ is $p-1=4$ with $p=5$; the actual height $3$ is strictly below it. Thus, unlike $105$, the order $385$ is not Bang-extremal, yet it already realizes a third height value.

---

## 9. The height spectrum and the ternary trichotomy

**Theorem 9.1 (Height one is flatness).** *For every $n\ge1$: $\mathcal{B}(n,B) \Rightarrow B \ge 1$, and $H(n)=1$ if and only if $\Phi_n$ is flat.*

*Proof sketch.* $\Phi_n$ is monic of degree $\varphi(n)$, so $a_n(\varphi(n))=1$ and any bound $B$ satisfies $B \ge 1$; there is no height $0$. Then $H(n)=1$ says exactly that $\mathcal B(n,1)$ holds and $1$ is least, and the second condition is automatic. $\square$

**Theorem 9.2 (Height is an odd-radical invariant).** *If $\mathrm{rad}_{\mathrm{odd}}(m)=\mathrm{rad}_{\mathrm{odd}}(n)$ (with $m,n \ge 1$), then for every $B$, $H(m)=B \iff H(n)=B$; in particular $H(m)=H(n)$.*

*Proof sketch.* Theorem 4.1 shows the two bound-sets $\{B : \mathcal B(m,B)\}$ and $\{B:\mathcal B(n,B)\}$ coincide, hence so do their least elements. $\square$

**Theorem 9.3 (Separation).** *If $H(m)\ne H(n)$ then $\mathrm{rad}_{\mathrm{odd}}(m)\ne\mathrm{rad}_{\mathrm{odd}}(n)$.*

*Proof sketch.* Contrapositive of Theorem 9.2, using uniqueness of least elements. $\square$

**Theorem 9.4 (Ternary trichotomy).** *Each of $231=3\cdot7\cdot11$, $105=3\cdot5\cdot7$, $385=5\cdot7\cdot11$ has exactly three odd prime divisors, and*
$$H(231)=1,\qquad H(105)=2,\qquad H(385)=3.$$
*Consequently $\omega_{\mathrm{odd}}$ does not determine the height, while $\mathrm{rad}_{\mathrm{odd}}$ does; and each of the values $1,2,3$ is attained by an infinite family of orders, namely those with odd radical $231$, $105$, $385$ respectively.*

*Proof sketch.* Combine Theorems 7.1, 6.3, 8.1 for the three heights; $\omega_{\mathrm{odd}}=3$ in each case is immediate from the factorizations. The infinitude of each class is Theorem 9.2 plus the fact that $\mathrm{rad}_{\mathrm{odd}}(2^aN^{\,\cdot})=\mathrm{rad}_{\mathrm{odd}}(N)$ for arbitrarily large multipliers. $\square$

**Corollary 9.5 (Three values in the spectrum).** *The set $\{H(n) : n \ge 1\}$ contains $1,2,3$; witnesses are $n=3$ (or $231$), $n=105$, $n=385$.*

The structural conclusion is that the height is a function of the finite set $\mathrm{P}(n)\setminus\{2\}$ — and, within the level $|\mathrm{P}(n)\setminus\{2\}|=3$, that function is already non-constant with at least three values.

---

## 10. Coefficients of the flat family as lattice-point counts

The final theme returns to (5.1) and shows that the entire flat two-prime theory has an exact combinatorial model, transported intact through both symmetries.

**Lemma 10.1 (Bi-inflation).** *For primes $p,q$ and $\beta,\gamma,k\ge0$,*
$$a_{p^{\beta+1}q^{\gamma+1}}\bigl(k\,p^{\beta}q^{\gamma}\bigr) = a_{pq}(k).$$

*Proof sketch.* Two applications of Corollary 3.2, first inflating $pq$ by $p^{\beta}$ and then by $q^{\gamma}$, tracking the index dilation $k \mapsto kp^{\beta} \mapsto kp^{\beta}q^{\gamma}$. $\square$

**Theorem 10.2 (Lattice-point formula for the flat family).** *Let $p\ne q$ be odd primes, and let $\alpha,\beta,\gamma\ge0$. For every $k$ with $0 \le k$ and $k+1 < pq$,*
$$a_{2^{\alpha+1}p^{\beta+1}q^{\gamma+1}}\Bigl((k+1)\,p^{\beta}q^{\gamma}\,2^{\alpha}\Bigr) \;=\; (-1)^{(k+1)p^{\beta}q^{\gamma}}\Bigl(\mathbf 1\{k+1 \in \langle p,q\rangle\} - \mathbf 1\{k \in \langle p,q\rangle\}\Bigr).$$
*Without the factor $2$: $a_{p^{\beta+1}q^{\gamma+1}}\bigl((k+1)p^{\beta}q^{\gamma}\bigr) = \mathbf 1\{k+1 \in \langle p,q\rangle\}-\mathbf 1\{k \in \langle p,q\rangle\}$.*

*Proof sketch.* Start from (5.1). Apply Lemma 10.1 to move from $pq$ to $p^{\beta+1}q^{\gamma+1}$; note $m=p^{\beta+1}q^{\gamma+1}$ is odd and $>1$ since $p,q$ are odd. Apply Theorem 3.5 to pass to $2m$, contributing the sign $(-1)^{j}$ at index $j = (k+1)p^{\beta}q^{\gamma}$; then apply Corollary 3.2 with the prime $2$ and exponent $\alpha$ to dilate the index by $2^{\alpha}$ without changing the value. $\square$

**Remark 10.3 (Why three primes is genuinely harder).** For $n=pq$ the coefficient counts lattice points on the *line* $ip+jq=m$ inside the box $[0,q)\times[0,p)$, and box-uniqueness makes the count $0$ or $1$. For $n=pqr$ the analogue is the *plane section* $ip+jq+kr=m$ inside a box; uniqueness fails, and the coefficient becomes the deviation of an actual lattice count from its expected value. Bang's bound $|a_{pqr}(m)| \le p-1$ (for $p<q<r$) is the assertion that the residues $jq+kr \bmod p$ are equidistributed enough over the $p$ classes for the deviation to stay below $p$. With box-uniqueness and the transport lemmas of §3 in hand, the ternary case is a self-contained counting problem, not a polynomial-algebra problem.

---

## 11. Algorithms

Three algorithms underlie the computational side of this work.

### 11.1 Divisor-recursive cyclotomic construction

Compute $\Phi_n$ by dividing $X^n-1$ successively by $\Phi_d$ for each proper divisor $d \mid n$, using exact integer polynomial division (each divisor is monic, so no denominators appear). The recursion is well-founded on the divisor lattice. Complexity is $O(\sigma_0(n)\cdot n^2)$ integer operations in a naive implementation, dominated by the divisions; with memoization over divisors it is very fast for $n$ in the thousands.

### 11.2 Height reduction as a preprocessing step

Given $n$, compute $R=\mathrm{rad}_{\mathrm{odd}}(n)$ by factoring $n$, deleting the prime $2$, and multiplying the remaining primes once each. By Theorem 4.1, $H(n)=H(R)$, so one computes $\Phi_R$ instead of $\Phi_n$. The saving is dramatic: e.g. $n = 2^{10}\cdot3^{4}\cdot5^{3}\cdot7^{2}$ has $\varphi(n) = 2^{9}\cdot(3^3\cdot 2)\cdot(5^2\cdot4)\cdot(7\cdot6) = 116{,}121{,}600$, while $R=105$ and $\varphi(R)=48$: a degree-$48$ computation replaces a degree-$1.16{\times}10^{8}$ one. Complexity: $O(\sqrt n)$ trial division plus the cost of $\Phi_R$.

### 11.3 Semigroup-indicator evaluation of flat coefficients

For distinct primes $p,q$ and $0<m<pq$, decide $m\in\langle p,q\rangle$ by testing whether $(m - ip)$ is a nonnegative multiple of $q$ for some $0 \le i \le \lfloor m/p\rfloor$; then apply (5.1). This evaluates a *single* coefficient of $\Phi_{pq}$ in $O(m/p)$ time and $O(1)$ space, without constructing the polynomial — and, through Theorem 10.2, evaluates single coefficients of the entire family $2^{\alpha}p^{\beta}q^{\gamma}$ at inflated indices, whose degrees can be astronomically large.

---

## 12. Applications and context

**Explaining a historical error.** Corollary 5.4 gives a one-line structural reason for the pre-$105$ illusion: the least integer with three distinct odd prime factors is exactly $105$, and everything below it is covered by the two-parameter theorem plus the two symmetries.

**Search space reduction.** Any exhaustive search for large cyclotomic coefficients — e.g. for orders realizing a prescribed height — may be restricted to *squarefree odd* $n$ without loss (Theorem 4.1). This removes the powers of $2$ and all repeated prime factors from the search entirely, which is exactly the multiplicative bulk of the integers.

**Structured lattices and coding.** The polynomials $\Phi_n$ are the irreducible factors of $X^n-1$ over $\mathbb{Q}$, so they organize the factorization theory behind cyclic codes and behind the quotient rings $\mathbb{Z}[X]/(\Phi_n)$ used in structured-lattice cryptography, where coefficient magnitudes bear directly on noise growth. Height reduction says that, from this point of view, only the squarefree odd part of the conductor matters.

**A sharper invariant.** Theorem 9.4 shows that the natural coarse invariant $\omega_{\mathrm{odd}}$ is inadequate and the correct one is $\mathrm{rad}_{\mathrm{odd}}$. Any conjecture about heights should therefore be phrased in terms of the *set* of odd primes, not their number.

---

## 13. Discussion and future work

### 13.1 Bang's bound as a lattice-point count

**Conjecture 13.1 (Bang).** *For odd primes $p<q<r$, every coefficient of $\Phi_{pqr}$ satisfies $|a| \le p-1$.*

The route suggested by §10 is to generalize the box-uniqueness argument from the line $ip+jq=m$ inside $[0,q)\times[0,p)$ to the plane section $ip+jq+kr=m$ inside a box, and to bound the deviation of the lattice count from its expected value by $p-1$ using the equidistribution of $jq+kr \bmod p$. Both ingredients — box uniqueness, and the transport of coefficients through inflation and reflection — are already available, so the ternary case is now a counting problem rather than a polynomial-algebra problem. If the conjecture holds, it globalizes immediately by Theorem 4.1 to *all* $n$ with three odd prime divisors. If it fails, the failure is a concrete triple $(p,q,r)$, which is itself a valuable object.

Note that our data are consistent with — and calibrate — the conjecture: at $p=3$ the bound is $2$ and $\Phi_{105}$ attains it while $\Phi_{231}$ does not; at $p=5$ the bound is $4$ and $\Phi_{385}$ reaches only $3$.

### 13.2 Characterizing flat ternary orders

$231$ is flat, $105$ is not, and both have smallest odd prime $3$. What distinguishes them? A precise characterization of the flat squarefree ternary orders — a condition on $(p,q,r)$, presumably congruential — would complete the picture that Theorems 5.3 and 7.2 leave open, and by Theorem 4.1 it would characterize the entire flat class.

### 13.3 The height spectrum

We have shown $\{1,2,3\} \subseteq \{H(n)\}$. Two questions are natural: is every positive integer a height (equivalently, is the spectrum all of $\mathbb{Z}_{\ge1}$)? And what is the least order realizing a given height? Both are approachable by the same explicit-cancellation machinery, one squarefree odd order at a time.

### 13.4 Beyond three primes

The reduction of §4 is uniform in the number of primes; only the explicit inputs change. A quaternary analogue of Lemma 6.1 with sixteen divisor factors is available, so orders $pqrs$ can in principle be pinned down the same way, at the cost of much larger expansions.

---

## 14. Summary of results

| Statement | Content |
|---|---|
| Inflation | $\Phi_{np}(X)=\Phi_n(X^p)$ for $p\mid n$; coefficient multiset preserved |
| Reflection | $\Phi_{2n}(X)=\Phi_n(-X)$ for odd $n>1$; $\lvert a_{2n}(k)\rvert=\lvert a_n(k)\rvert$ |
| Height reduction | $\mathcal B(n,B)\iff\mathcal B(\mathrm{rad}_{\mathrm{odd}}(n),B)$; $H(n)=H(\mathrm{rad}_{\mathrm{odd}}(n))$ |
| Two-parameter theorem | $a_{pq}(m)=\mathbf1\{m\in\langle p,q\rangle\}-\mathbf1\{m-1\in\langle p,q\rangle\}$; $\Phi_{pq}$ flat |
| Sharpness | $a_{p^aq^b}(p^{a-1}q^{b-1})=-1$ |
| Flatness classification | $\omega_{\mathrm{odd}}(n)\le2\Rightarrow\Phi_n$ flat; hence $\Phi_n$ flat for all $n<105$ |
| Explicit $\Phi_{105}$ | degree $48$; $a(7)=a(41)=-2$; $H(105)=2$ |
| Height-two family | $H(2^a3^{b+1}5^{c+1}7^{d+1})=2$ |
| Explicit $\Phi_{231}$ | degree $120$; flat; classification is not an equivalence |
| Flat family outside the class | $\mathrm{rad}_{\mathrm{odd}}(n)=231\Rightarrow\Phi_n$ flat |
| Explicit $\Phi_{385}$ | degree $240$; $a(119)=a(120)=a(121)=-3$; $H(385)=3$ |
| Height-three family | $H(2^a5^{b+1}7^{c+1}11^{d+1})=3$ |
| Height one $=$ flatness | monicity forbids height $0$ |
| Ternary trichotomy | $H(231)=1$, $H(105)=2$, $H(385)=3$, all with $\omega_{\mathrm{odd}}=3$ |
| Lattice-point formula | coefficients of $\Phi_{2^{\alpha}p^{\beta+1}q^{\gamma+1}}$ at inflated indices are $\pm$ semigroup indicator differences |
