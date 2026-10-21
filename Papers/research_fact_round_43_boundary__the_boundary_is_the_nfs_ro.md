# The Boundary Is the Number Field Sieve: Column Sets Governed by the Field, Not by the Modulus

**Aristotle**

*October 2026*

---

## Abstract

In the quadratic sieve (QS) for factoring an integer $N$, the primes that can occur in relations (the *columns* of the exponent matrix) are exactly the odd primes $r$ with Legendre symbol $(N/r)=+1$. The column set is therefore fixed by the integer being factored. We show that the quadratic model of the number field sieve (NFS), which sieves over $\mathbb Z[\sqrt d]$, removes this dependence completely. For an odd prime $r$, the number of degree-one prime ideals of $\mathbb Z[\sqrt d]$ above $r$, which equals the number of ring homomorphisms $\mathbb Z[\sqrt d]\to\mathbb F_r$, is exactly $1+(d/r)$. Hence the NFS column set is $\{r : (d/r)=+1\}$, a set governed by the auxiliary parameter $d$ and not by $N$. Our main result is a *decoupling theorem*. Fix $N$, and even a root $m$. As $d$ ranges over the fields that are valid for $N$ (those with $N \mid m^2-d$), the NFS column pattern on the factor-base primes coprime to $N$ takes **every one** of its $2^{|S|}$ possible values. The QS column set is the single member $d=N$, $m=0$ of this family. We complement this with a *yield-cancellation* identity: summed over a full period $d=0,\dots,r-1$, the number of degree-one primes above $r$ is exactly $r$, so choosing the field redistributes split primes without raising their average. We also prove a *residual-coupling* statement: validity forces $(d/p)=+1$ at the hidden prime factors $p$ of $N$ with $p\nmid d$, and imposes nothing on the factor base. Explicit data at $B=200$ illustrate the results. The field $d=-7$ is valid for both $N=11$ and $N=23$ and has the same $21$ odd split primes for both, while the QS column sets of $11$ and $23$ have $20$ and $19$ elements and differ. The results identify the structural mechanism separating the two sieves. They do not claim a new running time.

---

## 1. Introduction

### 1.1 Congruences of squares

Both the quadratic sieve and the number field sieve factor a composite integer $N$ by producing a nontrivial congruence of squares
$$X^2\equiv Y^2 \pmod N,\qquad X\not\equiv\pm Y\pmod N,$$
from which $\gcd(X-Y,N)$ is a proper divisor of $N$. Each method collects *relations*: objects whose "norms" factor completely over a factor base of primes up to a bound $B$. It records the exponent vectors modulo $2$ and finds a linear dependency, whose product is a square on both sides of a ring homomorphism into $\mathbb Z/N\mathbb Z$.

The heuristic running times are
$$\text{QS: } L_N\!\left[\tfrac12,\,1\right],\qquad \text{NFS: } L_N\!\left[\tfrac13,\,\left(\tfrac{64}{9}\right)^{1/3}\right],\qquad L_N[\alpha,c]=\exp\!\big((c+o(1))(\ln N)^\alpha(\ln\ln N)^{1-\alpha}\big).$$
The standard explanation for the gap is size. NFS norms are of size $N^{o(1)}$, while QS sieve values are of size about $N^{1/2}$.

### 1.2 The question of control

A complementary question asks *which parameter controls the column set*. A column is a factor-base prime that can actually divide a relation's norm. Columns that cannot occur are dead weight. The set of live columns is the sieve's working vocabulary, and everything a sieve can tune (weights, thresholds, large-prime variations) lives on it.

Earlier analysis studied several proposed "decoupling channels" for the quadratic sieve: attempts to reweight or reprice its columns independently of $N$. All of them turned out to be provably closed, for a single shared reason. In QS every relation is a difference of squares tied to $N$, and this forces $(N/r)=+1$ at every prime $r$ that occurs. That analysis named a falsifiable boundary. Columns outside the $N$-split set can appear only if the sieved quantity is *not* a difference of squares tied to $N$.

This paper settles the boundary. The way past it is the number field sieve. In its quadratic model, the column set is governed by an auxiliary integer $d$ that the factorer chooses. We prove the resulting freedom is total on the factor base (Theorem 5.1), that it is zero-sum in average yield (Theorem 6.1), and that the coupling to $N$ survives only at the hidden prime factors of $N$ (Theorem 7.1).

### 1.3 Summary of results

Let $B\ge 1$. Let $\mathcal P_B$ denote the odd primes $r\le B$. For an integer $N$ let $S_N=\{r\in\mathcal P_B : r\nmid N\}$.

1. **QS columns are slaved to $N$.** An odd prime $r\le B$, $r\nmid N$, divides some $x^2-N$ if and only if $(N/r)=+1$. Every homogeneous relation $r\mid x^2-Ny^2$ with $r\nmid Ny$ forces $(N/r)=+1$ (Propositions 3.2 and 3.3).
2. **Degree-one prime count.** For an odd prime $r$, $\#\operatorname{Hom}(\mathbb Z[\sqrt d],\mathbb F_r)=1+(d/r)$. Distinct homomorphisms have distinct kernels, which are maximal ideals with residue field $\mathbb F_r$ (Theorem 4.2, Proposition 4.3).
3. **Decoupling theorem.** For every $N$, every $m$ and every $T\subseteq S_N$ there is $d$ with $N\mid m^2-d$ whose NFS column set meets $S_N$ in exactly $T$. The attainable patterns are exactly the $2^{|S_N|}$ subsets of $S_N$ (Theorem 5.1, Corollary 5.2).
4. **Yield cancellation.** $\sum_{d=0}^{r-1}\#\operatorname{Hom}(\mathbb Z[\sqrt d],\mathbb F_r)=r$ (Theorem 6.1).
5. **Residual coupling.** If $N\mid m^2-d$, then $(d/p)=+1$ for every prime $p\mid N$ with $p\nmid d$ (Theorem 7.1).

---

## 2. Definitions and the split predicate

Throughout, $r$ and $p$ denote rational primes and $\mathbb F_r=\mathbb Z/r\mathbb Z$.

**Definition 2.1 (Odd factor base).** For $B\in\mathbb N$, the *odd factor base* is $\mathcal P_B=\{r\le B: r \text{ prime}, r\neq 2\}$.

**Definition 2.2 (Splitting).** For $a\in\mathbb Z$ and a prime $r$, we say that *$r$ splits $a$* if $r\nmid a$ and there is an $x\in\{0,1,\dots,r-1\}$ with $r\mid x^2-a$.

This definition is deliberately finite and computable. It quantifies over a bounded range of residues only.

**Definition 2.3 (Column sets).** For $N,d\in\mathbb Z$ and $B\in\mathbb N$,
$$\mathcal C_{\mathrm{QS}}(N,B)=\{r\in\mathcal P_B: r\text{ splits }N\},\qquad \mathcal C_{\mathrm{NFS}}(d,B)=\{r\in\mathcal P_B: r\text{ splits }d\}.$$

The two sets are the *same function* of different arguments. The whole content of this paper is about which argument the factorer controls.

**Definition 2.4 (Coprime base, validity).** The *coprime base* of $N$ is $S_N=\{r\in\mathcal P_B : r\nmid N\}$. An integer $d$ is *valid for $N$ with root $m$* if $N\mid m^2-d$, that is, $t^2-d$ has the root $t=m$ modulo $N$. Validity is what lets the NFS map $\sqrt d\mapsto m$ define a ring homomorphism $\mathbb Z[\sqrt d]\to\mathbb Z/N\mathbb Z$.

**Lemma 2.5 (Splitting is a square condition).** For any prime $r$,
$$r\text{ splits }a\iff a\not\equiv 0 \pmod r \text{ and } a \text{ is a square in } \mathbb F_r.$$
*Proof.* If $r\mid x^2-a$ then $a\equiv x^2$ in $\mathbb F_r$. Conversely, if $a\equiv s^2$, take $x$ to be the least nonnegative representative of $s$. Then $0\le x<r$ and $x^2\equiv a$. $\square$

**Corollary 2.6 (Splitting is the Legendre condition).** For an odd prime $r$, $r$ splits $a$ if and only if $(a/r)=+1$.

*Proof.* If $r\mid a$ both sides are false, since $(a/r)=0$. Otherwise $(a/r)=+1$ is by definition the statement that $a$ is a nonzero square modulo $r$, and Lemma 2.5 applies. $\square$

**Lemma 2.7 (Residue invariance).** If $r$ is prime and $r\mid b-a$, then $r$ splits $a$ iff $r$ splits $b$.

*Proof.* By Lemma 2.5 the predicate depends only on the image of $a$ in $\mathbb F_r$. $\square$

**Lemma 2.8 (Integer witnesses).** For $r\ge1$, there is $x\in\mathbb Z$ with $r\mid x^2-a$ iff $a$ is a square in $\mathbb Z/r\mathbb Z$.

*Proof.* Reduce an integer witness modulo $r$, or lift a square root to its least nonnegative representative. $\square$

---

## 3. The quadratic sieve: columns governed by $N$

The QS sieves the values $Q(x)=x^2-N$ (or, in its multiple-polynomial form, quadratic forms whose values are, up to a known factor, $x^2-Ny^2$).

**Proposition 3.1 (QS columns depend only on $N$ modulo the base).** If $N'\equiv N\pmod r$ for every $r\in\mathcal P_B$, then $\mathcal C_{\mathrm{QS}}(N',B)=\mathcal C_{\mathrm{QS}}(N,B)$.

*Proof.* Apply Lemma 2.7 to each $r\in\mathcal P_B$. $\square$

**Proposition 3.2 (QS columns are exactly the primes dividing sieve values).** Let $r\in\mathcal P_B$. Then
$$r\in\mathcal C_{\mathrm{QS}}(N,B)\iff r\nmid N\ \text{and}\ \exists x\in\mathbb Z:\ r\mid x^2-N.$$

*Proof.* Combine Lemma 2.5 with Lemma 2.8. $\square$

**Proposition 3.3 (Every homogeneous QS relation forces the $N$-Legendre condition).** Let $r$ be prime with $r\nmid N$, $r\nmid y$, and $r\mid x^2-Ny^2$. Then $r$ splits $N$. For $r$ odd this means $(N/r)=+1$.

*Proof.* In $\mathbb F_r$ we have $x^2=Ny^2$ with $y\neq0$, so $N=(x/y)^2$ is a nonzero square. Apply Lemma 2.5. $\square$

Propositions 3.1–3.3 together say that the QS column set is $\{r : (N/r)=+1\}$, and that no relation, however cleverly constructed, can place a prime $r\nmid N$ with $(N/r)\neq+1$ into a column. The integer being factored dictates the vocabulary.

---

## 4. The quadratic number field sieve: columns are degree-one prime ideals

### 4.1 The ring $\mathbb Z[\sqrt d]$

For $d\in\mathbb Z$, let $\mathbb Z[\sqrt d]=\{x+y\sqrt d: x,y\in\mathbb Z\}$ with multiplication $(x+y\sqrt d)(x'+y'\sqrt d)=(xx'+dyy')+(xy'+x'y)\sqrt d$. (When $d$ is a perfect square this is a ring with zero-divisors; nothing below requires $d$ to be squarefree.) Conjugation is $\overline{x+y\sqrt d}=x-y\sqrt d$, and the norm is
$$\mathrm N(x+y\sqrt d)=(x+y\sqrt d)(x-y\sqrt d)=x^2-dy^2\in\mathbb Z.$$

**Lemma 4.1 (Universal property).** For any commutative ring $R$, ring homomorphisms $\mathbb Z[\sqrt d]\to R$ are in bijection with elements $s\in R$ satisfying $s^2=d$, via $f\mapsto f(\sqrt d)$.

*Proof.* A homomorphism is determined by the image of $\sqrt d$, which must square to $d$. Conversely $x+y\sqrt d\mapsto x+ys$ is multiplicative exactly when $s^2=d$. $\square$

### 4.2 Counting degree-one primes

**Theorem 4.2 (Degree-one prime count).** Let $r$ be an odd prime and $d\in\mathbb Z$. Then
$$\#\operatorname{Hom}_{\mathrm{ring}}(\mathbb Z[\sqrt d],\mathbb F_r)=1+\left(\frac dr\right).$$

*Proof.* By Lemma 4.1 the left side is the number of $s\in\mathbb F_r$ with $s^2=d$. In a field of odd characteristic, the number of square roots of $a$ is $2$ if $a$ is a nonzero square, $0$ if it is a non-square, and $1$ if $a=0$. That is $1+\chi(a)$, where $\chi$ is the quadratic character. For $\mathbb F_r$ this character is the Legendre symbol. $\square$

**Proposition 4.3 (Homomorphisms are degree-one prime ideals).** Let $r$ be prime.
1. The map $f\mapsto\ker f$ from $\operatorname{Hom}(\mathbb Z[\sqrt d],\mathbb F_r)$ to ideals of $\mathbb Z[\sqrt d]$ is injective.
2. Each $\ker f$ is a maximal ideal, with $\mathbb Z[\sqrt d]/\ker f\cong\mathbb F_r$.

*Proof.* (2) $f$ is surjective, since already the integers map onto $\mathbb F_r$, so its kernel is maximal with quotient $\mathbb F_r$. (1) Let $s=f(\sqrt d)$ and let $\tilde s\in\{0,\dots,r-1\}$ represent it. Then $\sqrt d-\tilde s\in\ker f$. If $\ker f=\ker g$, then $g(\sqrt d)-\tilde s=0$, so $g(\sqrt d)=s=f(\sqrt d)$, and $f=g$ by Lemma 4.1. $\square$

So the homomorphisms $\mathbb Z[\sqrt d]\to\mathbb F_r$ *are* the degree-one prime ideals above $r$ (prime ideals with residue field $\mathbb F_r$), and Theorem 4.2 counts them. For an odd prime $r$:

- $(d/r)=+1$: **split**. There are two degree-one primes, $\sqrt d\mapsto\pm s$, a conjugate pair.
- $(d/r)=-1$: **inert**. There are none.
- $r\mid d$: **ramified**. There is one, $\sqrt d\mapsto0$.

**Corollary 4.4 (NFS columns are pairs of degree-one primes).** For $r\in\mathcal P_B$,
$$r\in\mathcal C_{\mathrm{NFS}}(d,B)\iff \#\operatorname{Hom}(\mathbb Z[\sqrt d],\mathbb F_r)=2.$$

*Proof.* Corollary 2.6 and Theorem 4.2. $\square$

### 4.3 Relations localise at degree-one primes

An NFS relation is an element $x+y\sqrt d$, with $\gcd(x,y)=1$ in practice, whose norm $x^2-dy^2$ is $B$-smooth. Its factorisation into prime ideals is read off prime by prime.

**Proposition 4.5 (Relations land in a degree-one prime).** Let $r$ be prime, $r\nmid y$, and $r\mid x^2-dy^2$. Then there is a homomorphism $f:\mathbb Z[\sqrt d]\to\mathbb F_r$ with $f(x+y\sqrt d)=0$.

*Proof.* In $\mathbb F_r$, put $s=-x/y$. Then $s^2=x^2/y^2=d$, so by Lemma 4.1 there is $f$ with $f(\sqrt d)=s$, and $f(x+y\sqrt d)=x+y(-x/y)=0$. $\square$

**Proposition 4.6 (Converse).** If $f:\mathbb Z[\sqrt d]\to\mathbb F_r$ is a homomorphism with $f(x+y\sqrt d)=0$, then $r\mid x^2-dy^2$.

*Proof.* Apply $f$ to the identity $x^2-dy^2=(x+y\sqrt d)(x-y\sqrt d)$. The left side maps to the residue of the integer $x^2-dy^2$, and the right side maps to $0$. $\square$

So with $r\nmid y$, $r$ divides the norm of a relation exactly when the relation lies in a degree-one prime above $r$. Such primes exist only when $r$ splits $d$ or ramifies, and the split ones come in pairs. **Nothing in Sections 4.1–4.3 mentions $N$.**

---

## 5. The decoupling theorem

The only link between $d$ and $N$ is validity, $N\mid m^2-d$. A careful critic should ask whether this link restricts the attainable column sets. It does not.

**Theorem 5.1 (Decoupling theorem).** Let $N,m\in\mathbb Z$, $B\in\mathbb N$, and let $T\subseteq S_N$ be arbitrary. Then there is $d\in\mathbb Z$ such that
$$N\mid m^2-d\qquad\text{and}\qquad \mathcal C_{\mathrm{NFS}}(d,B)\cap S_N=T.$$

*Proof.* For each $r\in S_N$ choose a residue $t_r$ as follows. If $r\in T$, let $t_r=1$, which is a nonzero square, so $r$ splits $t_r$. If $r\notin T$, let $t_r$ be a quadratic non-residue modulo $r$. One exists because $r$ is odd: squaring is two-to-one on $\mathbb F_r^\times$, so exactly $(r-1)/2$ nonzero residues are squares. Then $r$ does not split $t_r$.

Now consider the system
$$d\equiv m^2\pmod N,\qquad d\equiv t_r\pmod r\quad(r\in S_N).$$
The moduli are pairwise coprime. Each $r\in S_N$ is a prime not dividing $N$, so $\gcd(r,N)=1$, and distinct primes are coprime. In ideal-theoretic language the ideals $(N)$ and $(r)$, $r\in S_N$, are pairwise comaximal in $\mathbb Z$. By the Chinese Remainder Theorem the system has a solution $d$.

The first congruence gives $N\mid m^2-d$. For $r\in S_N$, Lemma 2.7 gives that $r$ splits $d$ iff $r$ splits $t_r$ iff $r\in T$. Hence $\mathcal C_{\mathrm{NFS}}(d,B)\cap S_N=T$. $\square$

**Corollary 5.2 (Attainable patterns).** For all $N,m,B$,
$$\big\{\,\mathcal C_{\mathrm{NFS}}(d,B)\cap S_N \;:\; d\in\mathbb Z,\ N\mid m^2-d\,\big\} \;=\; \mathcal P(S_N),$$
the full power set of $S_N$. In particular exactly $2^{|S_N|}$ patterns are attained.

*Proof.* Every attained set is a subset of $S_N$ by construction, and Theorem 5.1 attains every subset. $\square$

**Corollary 5.3 (The QS is the one point the attacker does not choose).** The QS pattern $\mathcal C_{\mathrm{QS}}(N,B)\cap S_N$ is the NFS pattern of the valid member $d=N$, $m=0$ (since $N\mid 0^2-N$). Unlike the NFS family it is pinned by $N$: if $N'\equiv N\pmod r$ for all $r\in\mathcal P_B$, then $\mathcal C_{\mathrm{QS}}(N',B)=\mathcal C_{\mathrm{QS}}(N,B)$.

*Proof.* The first statement holds by definition, since $\mathcal C_{\mathrm{QS}}(N,B)=\mathcal C_{\mathrm{NFS}}(N,B)$. The second is Proposition 3.1. $\square$

**Remark 5.4 (Fixing even the root).** The theorem holds for *every* fixed root $m$, including $m=0$. So even the most rigid NFS variant, in which the map $\mathbb Z[\sqrt d]\to\mathbb Z/N\mathbb Z$ is prescribed in advance, keeps full column freedom. The QS is rigid not because it fixes $m$ but because it also fixes $d=N$.

**Remark 5.5 (Cost of the freedom).** The CRT solution is determined modulo $|N|\prod_{r\in S_N}r$, so the least nonnegative solution may be as large as this modulus. Larger $|d|$ inflates the norms $x^2-dy^2$ and lowers the smoothness probability. The decoupling is a statement about *which* columns can be selected, not a claim that every selection is cheap.

---

## 6. Yield cancellation

If the factorer can choose the column pattern, can they choose more columns on average? No.

**Theorem 6.1 (Yield cancellation).** For an odd prime $r$,
$$\sum_{d=0}^{r-1}\#\operatorname{Hom}(\mathbb Z[\sqrt d],\mathbb F_r)=r.$$

*Proof.* By Theorem 4.2 the summand is $1+(d/r)$. As $d$ runs over $0,\dots,r-1$ it runs over $\mathbb F_r$ exactly once, and the quadratic character of a finite field of odd characteristic sums to zero over the field. There are $(r-1)/2$ values $+1$, $(r-1)/2$ values $-1$, and one $0$. Hence the sum is $r+0=r$. $\square$

Equivalently, a uniformly random field residue has on average exactly one degree-one prime above $r$, the same as a "generic" prime of a degree-one extension. Choosing $d$ moves split primes from one field to another (Theorem 5.1) but cannot increase the total. This is the ideal-sieve analogue of the relation-pool cancellation familiar from the quadratic sieve.

A double-counting reformulation is often useful. The number of pairs $(d,s)\in\mathbb F_r^2$ with $s^2=d$ is $r$, since each $s$ determines $d$. Theorem 6.1 is just this count grouped by $d$.

---

## 7. Residual coupling: where the dependence on $N$ goes

Validity must constrain $d$ somewhere. It does so only at the prime divisors of $N$.

**Theorem 7.1 (Residual coupling).** Let $N\mid m^2-d$, and let $p$ be a prime with $p\mid N$ and $p\nmid d$. Then $p$ splits $d$. For $p$ odd this means $(d/p)=+1$.

*Proof.* $p\mid N\mid m^2-d$, so $m$ is an integer witness. Apply Lemma 2.8 and Lemma 2.5. $\square$

**Proposition 7.2 (Exactness at a prime).** For a prime $p\nmid d$, there is $m\in\mathbb Z$ with $p\mid m^2-d$ if and only if $p$ splits $d$.

*Proof.* Lemmas 2.8 and 2.5. $\square$

Combined with Theorem 5.1, this gives a precise picture of the coupling.

| primes | constraint imposed by validity |
|---|---|
| factor-base primes $r\in S_N$ | **none**: all $2^{|S_N|}$ patterns occur |
| hidden primes $p\mid N$, $p\nmid d$ | **forced**: $(d/p)=+1$ |

The dependence on $N$ has not vanished. It has *moved* onto the secret factors of $N$, which by design never belong to the factor base. This is the exact sense in which the NFS escapes the QS no-decoupling phenomenon.

---

## 8. Numerical data

All counts below are over the odd factor base $\mathcal P_{200}$, which has $45$ primes. They were obtained by exhaustive evaluation of Definition 2.2.

**8.1 One field, two moduli.** The field $d=-7$ is valid for $N=11$ (root $m=2$, since $2^2+7=11$) and for $N=23$ (root $m=4$, since $4^2+7=23$). Its NFS column set $\mathcal C_{\mathrm{NFS}}(-7,200)$ has $21$ elements. It is a single object, identical for both moduli. Counting also the prime $2$, which splits in $\mathbb Q(\sqrt{-7})$ because $-7\equiv1\pmod 8$, there are $22$ split primes up to $200$. By contrast:

| $N$ | $\lvert\mathcal C_{\mathrm{QS}}(N,200)\rvert$ |
|---|---|
| $11$ | $20$ |
| $23$ | $19$ |
| $15$ | $21$ |
| $47$ | $25$ |

and $\mathcal C_{\mathrm{QS}}(11,200)\neq\mathcal C_{\mathrm{QS}}(23,200)$.

**8.2 Decoupling in miniature.** Take $N=253=11\cdot23$, $m=5$, $B=13$. Then $S_N=\{3,5,7,13\}$, and the QS pattern on $S_N$ is $\{3,7\}$. Running the CRT construction of Theorem 5.1 for each of the $16$ subsets $T\subseteq S_N$ yields $16$ valid fields with $16$ distinct patterns. For instance $T=\varnothing$ gives $d=327407$, $T=S_N$ gives $d=318046$, and $T=\{3,7\}$ gives $d=195847$. Each satisfies $253\mid 25-d$.

**8.3 Yield cancellation.** For each of the first ten odd primes $r=3,\dots,31$, summing the number of square roots of $d$ modulo $r$ over $d=0,\dots,r-1$ returns exactly $r$.

**8.4 Residual coupling.** For $N=1009\cdot1013$ and fields $d=m^2-kN$ with various $m,k$, both $(d/1009)$ and $(d/1013)$ equal $+1$ in every case, as Theorem 7.1 predicts.

---

## 9. Algorithms

**Algorithm 9.1 (Column sets).** *Input:* parameter $a$ (either $N$ or $d$), bound $B$. *Output:* $\{r\in\mathcal P_B : (a/r)=+1\}$.
For each odd prime $r\le B$, compute $t=a^{(r-1)/2}\bmod r$ by fast exponentiation and keep $r$ iff $t=1$ (Euler's criterion). Cost: $O(\pi(B)\log B)$ modular multiplications after a sieve of Eratosthenes for the primes.

**Algorithm 9.2 (Field with prescribed column pattern).** *Input:* $N,m,B$, target $T\subseteq S_N$. *Output:* $d$ with $N\mid m^2-d$ and $\mathcal C_{\mathrm{NFS}}(d,B)\cap S_N=T$.
1. Compute $S_N$.
2. For $r\in S_N$: set $t_r=1$ if $r\in T$, and otherwise set $t_r$ to the least non-residue modulo $r$. Under the Generalised Riemann Hypothesis this is $O(\log^2 r)$. Unconditionally it is found quickly by trial in practice.
3. Solve $d\equiv m^2\ (N)$, $d\equiv t_r\ (r)$ by incremental CRT.
4. Return $d$.

Cost: $O(|S_N|)$ CRT steps on integers of size up to $|N|\prod_{r\in S_N}r$.

**Algorithm 9.3 (Degree-one primes above $r$).** *Input:* $d$, odd prime $r$. *Output:* the list of $s\in\mathbb F_r$ with $s^2=d$. These correspond to the homomorphisms $\sqrt d\mapsto s$ and the prime ideals $(r,\sqrt d-s)$. Use Tonelli–Shanks when $(d/r)=1$, return $[0]$ when $r\mid d$, and return $[\,]$ otherwise. The length is $1+(d/r)$ by Theorem 4.2.

---

## 10. Discussion

**Mechanism versus exponent.** The NFS running time $L_N[1/3]$ is classical, and we make no running-time claim. What the present results add is the *mechanism* separating the two sieves at the level of the column set:

- *Why the QS channels are closed.* Every QS relation is a difference of squares tied to $N$ (Proposition 3.3), so every column-level quantity is a function of the Legendre symbols $(N/r)$, which the factorer cannot alter.
- *What the escape is.* In the NFS the corresponding quantities are functions of $(d/r)$ (Theorem 4.2, Corollary 4.4), and $d$ ranges over a family in which all $2^{|S_N|}$ patterns occur (Theorem 5.1).
- *What the escape costs.* On average nothing is gained in yield (Theorem 6.1), and selecting a lopsided pattern inflates $|d|$ (Remark 5.5).
- *Where $N$ still enters.* Only at the hidden primes of $N$ (Theorem 7.1).

**The QS as a degenerate NFS.** Corollary 5.3 makes precise a folklore remark that the QS is a "degree-two NFS with $f(x)=x^2-N$". In the family of valid quadratic fields for $N$, the QS is the single member $d=N$, $m=0$, and it is the member whose column pattern is determined by the problem rather than by the solver.

**Scope.** The analysis concerns the *quadratic* model $\mathbb Z[\sqrt d]$ of the algebraic side. Practical NFS uses polynomials of degree $k\approx(3\ln N/\ln\ln N)^{1/3}$. There, root counts modulo $r$ range over $\{0,\dots,k\}$, and the two-sided (rational plus algebraic) structure adds a rational column set independent of $d$. The prime $2$ is excluded from the odd factor base for uniformity, since its splitting is governed by $d \bmod 8$ rather than by a Legendre symbol. We also treat $\mathbb Z[\sqrt d]$ rather than the full ring of integers, which matches the practice of sieving with the order generated by a root of the defining polynomial.

---

## 11. Future directions

1. **Higher-degree column freedom.** *Conjecture.* For monic irreducible $f$ of degree $k$ with $f(m)\equiv0\pmod N$, the vector of root counts $\big(\#\{x\bmod r: f(x)\equiv0\}\big)_{r\in S}$ takes every value in $\prod_r\{0,1,\dots,k\}$ compatible with an admissible splitting type, as $f$ varies over polynomials valid for $N$. Validity is a congruence modulo $N$ only, and CRT separates it from every congruence modulo factor-base primes. The degree-two case is Theorem 5.1, and the same comaximal-ideal argument applies to coefficient vectors.
2. **Hidden-prime leakage bound.** *Conjecture.* Any statistic of the NFS column set computable from $\{(d/r)\}_{r\in S}$ is independent of the factorisation of $N$. The only $N$-information carried by a valid $d$ is the vector $((d/p))_{p\mid N}$, which is forced to be all $+1$. Both halves, freedom on $S$ (Theorem 5.1) and forcing at $p\mid N$ (Theorem 7.1), are established. A joint independence statement is a counting argument away.
3. **Two-sided column freedom.** *Conjecture.* In the two-sided quadratic NFS, with relation $a-bm$ on the rational side and $a-b\sqrt d$ on the algebraic side, the joint column pattern is free in $d$ for fixed $(N,m)$, and the expected number of algebraic columns over a CRT period of $d$ is $|S|$. Yield cancellation (Theorem 6.1) fixes the average and Theorem 5.1 frees the pattern. Only the rational side, which is independent of $d$, remains.
4. **Field-choice lever with a smoothness price.** *Conjecture.* Choosing $d$ to make every $r\in S$ split forces $|d|\gtrsim\prod_{r\in S}r/2^{|S|}$ for the least valid solution in natural families, so the lever trades column count against norm size. The optimum should reproduce the familiar degree-versus-coefficient balance of NFS polynomial selection. Existence is established (Theorem 5.1). The size side needs only a bound on the least CRT solution with prescribed quadratic-residue pattern.

---

## 12. Conclusion

The quadratic sieve and the quadratic number field sieve use the same column-set rule, "the primes at which the parameter is a nonzero square", applied to different parameters. In the QS the parameter is $N$, which is handed to the solver. In the NFS it is $d$, which the solver picks subject only to a congruence modulo $N$. By the Chinese Remainder Theorem that congruence is invisible on the factor base. The resulting freedom is complete (all $2^{|S|}$ patterns), zero-sum in average yield ($\sum_d(1+(d/r))=r$), and leaves a single trace of $N$, namely forced splitting at $N$'s own hidden primes. This is the boundary that the closure of the quadratic-sieve decoupling channels pointed to, and it is precisely the number field sieve.
