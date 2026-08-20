# Denominator Primes of Multiples of Points on Mordell Curves, IV: the Quadrupling Layer, a Reciprocity Dichotomy, and an Information Barrier

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

For an integral point $P=(x,y)$ on the Mordell curve $E_N : y^2 = x^3 + N$ we study the set of primes occurring in the denominator of the $x$-coordinate of the multiple $nP$. We complete the analysis of the quadrupling layer $n=4$.

Three groups of results are established. **(i) An exact criterion.** Starting from the polynomial identity
$$(x^4-8Nx)^3 + 64N(x^3+N)^3 = (x^6+20Nx^3-8N^2)^2,$$
valid over any commutative ring, we derive the quadrupling formula $x(4P) = \varphi_4(x)/\Delta_4(x)$ with $\varphi_4 = (x^4-8Nx)\bigl((x^4-8Nx)^3-512N(x^3+N)^3\bigr)$ and $\Delta_4 = 16(x^3+N)S(x)^2$, $S(x) = x^6+20Nx^3-8N^2$, and prove a non-cancellation theorem: on the vanishing locus of $\Psi_4 := (x^3+N)S(x)$ the numerator $\varphi_4$ reduces to $-3^8N^5x$ or to $-2^63^2N(x^4-8Nx)(x^3+N)^3$, so its exceptional values are $\{2,3\}$-units times powers of $N$ and of the vanishing factors. Consequently, for every prime $\ell\ge 5$ with $\ell\nmid N$,
$$\ell \mid \operatorname{den} x(4P) \iff \ell \mid (x^3+N)(x^6+20Nx^3-8N^2).$$

**(ii) A reciprocity dichotomy in the class counts, refuting a linear-growth conjecture.** Writing $V_4(c)$ for the set of residues $x \bmod \ell$ satisfying the layer-4 criterion when $N\equiv c$, we prove
$$\sum_{c \bmod \ell} \# V_4(c) = \begin{cases} 3\ell-2, & 3 \text{ a square mod } \ell,\\ \ell, & \text{otherwise,}\end{cases}$$
and deduce that no pair $(k,C)$ satisfies $\bigl|\sum_c \#V_4(c) - k\ell\bigr|\le C$ for all primes $\ell\ge 5$. This refutes the conjecture, natural from layers $2$ and $3$ (totals $\ell$ and $2\ell-1$), that the layer-$n$ total is (number of irreducible factors of the $n$-th division polynomial) $\cdot\,\ell + O(1)$. We further prove that layer $4$ activates no new residue classes of $N$: the layer-4 locus is nonempty exactly where the layer-2 locus is, via a hidden cube root supplied by the factorisation $\bigl(\tfrac{-1-\sqrt3}{2}\bigr)^3 = -\tfrac{5+3\sqrt3}{4}$.

**(iii) An information barrier.** For every bound $B$ and every semiprime $N=pq$ with $p,q>B$ there is a prime $M>N$ such that the layer-$2$, layer-$3$ and layer-$4$ criteria at all primes $\ell\le B$ agree verbatim for $E_N$ and $E_M$. The denominator profile of the first four layers below any fixed bound therefore carries no information about the factorisation of $N$.

**Keywords:** Mordell curve, elliptic divisibility, division polynomial, denominator prime, quadratic reciprocity, Chebotarev density, integer factorisation.

---

## 1. Introduction

### 1.1 The phenomenon

Let $N$ be a nonzero integer and let
$$E_N : y^2 = x^3 + N$$
be the associated Mordell curve, an elliptic curve over $\mathbb{Q}$ of discriminant $-432N^2$ and $j$-invariant $0$. Its rational points form a finitely generated abelian group under the chord-and-tangent law. An integral point $P=(x,y)\in E_N(\mathbb{Z})$ has, in general, non-integral multiples: writing $x(nP) = a_n/b_n$ in lowest terms, the denominators $b_n$ grow rapidly and factor into primes that are not visible in $N$, $x$ or $y$.

A concrete instance, used throughout as a running example, is $N=55$, $P=(9,28)$ (indeed $28^2=784=9^3+55$). One computes
$$x(2P) = \frac{2601}{3136} = \frac{3^2\cdot 17^2}{2^6\cdot 7^2}, \qquad x(4P) = \frac{-35249882584054239}{2^8\cdot 7^2\cdot 827^2\cdot 1583^2}.$$
The primes $7$, $827$, $1583$ have been *manufactured* by iterating the group law.

### 1.2 Reduction-theoretic meaning

The phenomenon has a clean interpretation. For a prime $\ell\nmid 6N$ the curve $E_N$ has good reduction at $\ell$, and reduction modulo $\ell$ is a group homomorphism
$$E_N(\mathbb{Q}) \longrightarrow E_N(\mathbb{F}_\ell)$$
whose kernel consists of the points whose coordinates are non-integral at $\ell$. Hence:

> $\ell \mid \operatorname{den} x(nP)$ $\iff$ the reduction $\bar P \in E_N(\mathbb{F}_\ell)$ satisfies $n\bar P = O$.

Denominator primes at layer $n$ are therefore exactly the primes at which $P$ becomes $n$-torsion. Since $n$-torsion is cut out by the $n$-th **division polynomial** $\psi_n$, the question becomes one about congruences of explicit polynomials. For the Mordell family:
$$\psi_2 = 2y, \qquad \psi_3 = 3x^4+12Nx = 3x(x^3+4N), \qquad \psi_4 = 4y\,(x^6+20Nx^3-8N^2).$$

### 1.3 What was known, and what this paper adds

Two earlier layers of this programme are settled.

- **Layer 2 (doubling).** For an integral point $P=(x,y)$ with $y\ne 0$ and every prime $\ell\ge 5$ with $\ell\nmid N$: $\ell\mid\operatorname{den} x(2P) \iff \ell \mid x^3+N$. Moreover, writing $V_2(c) = \{t\in\mathbb{F}_\ell : t^3+c=0\}$, one has $\sum_{c}\#V_2(c) = \ell$ exactly, and $V_2(c)\neq\emptyset$ iff $-c$ is a cube mod $\ell$; for $\ell\equiv 1 \pmod 3$ exactly $2(\ell-1)/3$ residues are *blind* (i.e. $V_2(c)=\emptyset$), the active density being $(\ell+2)/(3\ell)$; for $\ell\equiv 2\pmod 3$ every residue is active.
- **Layer 3 (tripling).** $\ell\mid\operatorname{den} x(3P) \iff \ell\mid 3x(x^3+4N)$, the two exceptional numerator values on the locus being $64N^3$ (branch $x\equiv 0$) and $-1728N^3$ (branch $x^3\equiv -4N$). The layer-3 total is $2\ell-1$, and layer 3 is active over *every* residue class of $N$, because the free root $x\equiv 0$ requires no condition on $N$.
- **Barrier at layers 2–3.** For every $B$ and every semiprime $N=pq$ with $p,q>B$ there is a prime $M$ whose layer-2 and layer-3 criteria below $B$ agree with those of $N$.

Extrapolating from the totals $\ell$ (one irreducible factor $T^3+N$) and $2\ell-1$ (two factors $T$ and $T^3+4N$), it is natural to conjecture that the layer-$n$ total is $k_n\ell + O(1)$ with $k_n$ the number of $\mathbb{Q}(N)$-irreducible factors of $\psi_n$; and, from the exceptional constants $9$, $64$, $1728$, that at every layer the numerator's exceptional values on the locus $\psi_n = 0$ are $\{2,3\}$-units times powers of $N$.

This paper settles layer $4$, the first layer at which the division polynomial acquires a factor which is not of Kummer type $T^k + cN^j$. The second conjecture is **confirmed**; the first is **refuted**, and replaced by a reciprocity-governed statement.

### 1.4 Organisation

Section 2 fixes notation and states the layer-4 algebraic identities. Section 3 proves the quadrupling formula and the non-cancellation theorem, yielding the layer-4 criterion, and works the running example. Section 4 computes the layer-4 class counts and derives the dichotomy and the refutation. Section 5 proves that layer 4 activates no new residues. Section 6 proves the information barrier through layer 4. Section 7 gives algorithms. Section 8 discusses consequences and open problems.

---

## 2. Setup and the layer-4 polynomials

Throughout, $N$ is a nonzero integer, $\ell$ a prime with $\ell\ge 5$, and $P=(x,y)$ an integral point of $E_N$. For $\alpha\in\mathbb{Q}$ we write $\operatorname{den}\alpha$ for the (positive) denominator of $\alpha$ in lowest terms.

**Definition 2.1 (layer-4 polynomials).** Over $\mathbb{Z}[N,x]$ set
$$S(N,x) := x^6 + 20Nx^3 - 8N^2, \qquad \Psi_4(N,x) := (x^3+N)\,S(N,x),$$
$$\varphi_4(N,x) := (x^4-8Nx)\Bigl((x^4-8Nx)^3 - 512N(x^3+N)^3\Bigr), \qquad \Delta_4(N,x) := 16\,(x^3+N)\,S(N,x)^2 .$$

Expanding, $\Psi_4(N,x) = x^9 + 21Nx^6 + 12N^2x^3 - 8N^3$, a polynomial of degree $9$ in $x$ — the $x$-locus of the $4$-torsion, of the expected degree $(4^2-4)/2\cdot\ldots$ once one accounts for the $2$-torsion factor $x^3+N$ contained in it.

**Lemma 2.2 (the layer-4 key identity).** In any commutative ring,
$$(x^4-8Nx)^3 + 64N\,(x^3+N)^3 = \bigl(x^6+20Nx^3-8N^2\bigr)^2 .$$

*Proof.* Both sides expand to $x^{12} + 40Nx^9 + 384N^2x^6 - 320N^3 x^3 + 64 N^4$; the identity is a formal consequence of the ring axioms. $\square$

The identity is the structural heart of the layer. The doubling formula (Lemma 3.1) gives $X := x(2P) = (x^4-8Nx)/\bigl(4(x^3+N)\bigr)$; dividing Lemma 2.2 by $64(x^3+N)^3$ yields

**Corollary 2.3.** With $X$ as above and $x^3+N \ne 0$,
$$X^3 + N = \frac{S(N,x)^2}{64\,(x^3+N)^3}.$$

In words: *the value of the defining cubic at the doubled point is a perfect square divided by the cube of the doubling denominator.* Equivalently, $y(2P) = \pm S(N,x)/\bigl(8(x^3+N)^2\bigr)$ is a rational function with square-free-in-$S$ numerator, which is precisely why $\psi_4 = 4y\,S(N,x)$: the sextic $S$ *is* the square root that Lemma 2.2 provides.

Two loci meet inside $\Psi_4$: the layer-2 locus $x^3+N=0$ and the *new* locus $S=0$.

**Lemma 2.4 (transversality).** If $x^3 + N = 0$ and $S(N,x)=0$ then $27N^2=0$.

*Proof.* From $x^3=-N$ we get $x^6=N^2$, so $S = N^2 - 20N^2 - 8N^2 = -27N^2$. $\square$

So over any field of characteristic $\ge 5$ the two branches are disjoint unless $N=0$. Note the recurrence of $27=3^3$: as at layer 3, the intersection constant is a discriminant constant of the Mordell family.

---

## 3. The quadrupling layer

### 3.1 The formula

**Lemma 3.1 (doubling).** Let $P=(x,y)$ be a nonsingular rational point of $E_N$ with $y\ne 0$. Then
$$x(2P) = \frac{x^4-8Nx}{4(x^3+N)} = \frac{x^4-8Nx}{4y^2}.$$

*Proof.* The tangent slope is $\lambda = 3x^2/(2y)$ and $x(2P) = \lambda^2-2x = (9x^4 - 8xy^2)/(4y^2)$; substituting $y^2=x^3+N$ gives $(9x^4-8x^4-8Nx)/(4y^2) = (x^4-8Nx)/(4y^2)$. $\square$

**Theorem 3.2 (quadrupling formula).** Let $P=(x,y)$ be a nonsingular rational point of $E_N$ with $y\ne 0$ (so $P$ is not $2$-torsion) and $S(N,x)\ne 0$ (so $2P$ is not $2$-torsion, i.e. $P$ is not $4$-torsion). Then
$$x(4P) \;=\; \frac{(x^4-8Nx)\bigl((x^4-8Nx)^3 - 512N(x^3+N)^3\bigr)}{16\,(x^3+N)\,\bigl(x^6+20Nx^3-8N^2\bigr)^2} \;=\; \frac{\varphi_4(N,x)}{\Delta_4(N,x)} .$$

*Proof sketch.* Write $2P = (X,Y)$. By Lemma 3.1, $X = (x^4-8Nx)/(4(x^3+N))$ and by Corollary 2.3, $Y^2 = X^3+N = S^2/\bigl(64(x^3+N)^3\bigr)$, which is nonzero exactly under the hypothesis $S\neq0$; hence $2P$ is again a non-$2$-torsion affine point and Lemma 3.1 applies to it:
$$x(4P) = \frac{X^4-8NX}{4(X^3+N)} = \frac{X(X^3-8N)}{4(X^3+N)}.$$
Substituting the two displayed expressions for $X$ and $X^3+N$ and clearing denominators gives the stated rational function; the computation is a single application of the field axioms. $\square$

### 3.2 Non-cancellation

The criterion we want requires knowing that the numerator does not share the primes of the denominator.

**Theorem 3.3 (non-cancellation at layer 4).** Let $\ell\ge5$ be a prime with $\ell\nmid N$, and suppose $\ell \mid \Psi_4(N,x)$. Then $\ell\nmid\varphi_4(N,x)$.

*Proof.* Work in $\mathbb{F}_\ell$; write $X$ for $x \bmod \ell$ and $M$ for $N\bmod\ell$, so $M\ne 0$. The hypothesis says $(X^3+M)\,S(M,X)=0$, so one of the two branches holds.

**Branch A: $X^3 = -M$.** Then $X\neq0$ (else $M=0$), and $X^4 - 8MX = X\cdot X^3 - 8MX = -MX - 8MX = -9MX$. Also $x^3+N\equiv 0$, so the second factor of $\varphi_4$ is $(-9MX)^3 - 0 = -729M^3X^3 = 729M^4$. Hence
$$\varphi_4 \equiv (-9MX)\cdot 729M^4 = -3^8\,M^5X ,$$
which is nonzero because $3$, $M$ and $X$ are all nonzero in $\mathbb{F}_\ell$ (using $\ell\ge5$ for $3\ne 0$).

**Branch B: $S(M,X)=0$.** By Lemma 2.4 and $M\ne0$, $27M^2\ne0$ forces $X^3+M\neq0$. Lemma 2.2 gives $(X^4-8MX)^3 = -64M(X^3+M)^3$, which is nonzero, so $A := X^4-8MX \ne 0$. Then
$$\varphi_4 = A\bigl(A^3 - 512M(X^3+M)^3\bigr) = A\bigl(-64M(X^3+M)^3 - 512M(X^3+M)^3\bigr) = -2^63^2\,M\,A\,(X^3+M)^3,$$
since $64+512 = 576 = 2^63^2$. Every factor is nonzero in $\mathbb{F}_\ell$, using $\ell\ge5$. $\square$

**Remark 3.4 (the $\{2,3\}$ pattern).** The two exceptional constants are $3^8 = 6561$ and $2^63^2 = 576$. They join the layer-2 constant $9=3^2$ and the layer-3 constants $64=2^6$, $1728 = 2^63^3$: at every layer computed so far, the exceptional evaluation of the numerator on the locus of the division polynomial is a $\{2,3\}$-unit times a power of $N$ and of the vanishing factors. The primes $2$ and $3$ are exactly those dividing the discriminant $-432N^2 = -2^4 3^3 N^2$ of the Mordell family; away from them, $\varphi_n$ and $\psi_n^2$ are coprime on the relevant locus. This confirms, at the first genuinely non-Kummer layer, the qualitative prediction that the hypothesis $\ell\ge5$ is the only one needed.

### 3.3 The criterion

**Theorem 3.5 (layer-4 denominator criterion).** Let $P=(x,y)$ be an integral point of $E_N$ with $y\ne0$ and $S(N,x)\ne0$, and let $\ell\ge5$ be a prime with $\ell\nmid N$. Then
$$\ell \mid \operatorname{den} x(4P) \iff \ell \mid \Psi_4(N,x) = (x^3+N)\bigl(x^6+20Nx^3-8N^2\bigr).$$

*Proof sketch.* By Theorem 3.2, $x(4P) = \varphi_4/\Delta_4$ with $\Delta_4 = 16(x^3+N)S^2$. ($\Leftarrow$) If $\ell\mid\Psi_4$ then $\ell$ divides $(x^3+N)$ or $S$, hence in either case divides $\Delta_4$; by Theorem 3.3 it does not divide $\varphi_4$, so it survives to the reduced denominator. ($\Rightarrow$) The reduced denominator divides $\Delta_4$; since $\ell\ge5$ we have $\ell\nmid16$, so $\ell$ divides $(x^3+N)$ or $S^2$, hence (as $\ell$ is prime) divides $(x^3+N)S = \Psi_4$. $\square$

The criterion transfers verbatim to the group-law point $4P$: for any $X$ with $x(4P)=X$ computed by the chord–tangent law on $E_N$, one has $\ell \mid \operatorname{den} X \iff \ell\mid\Psi_4(N,x)$.

### 3.4 The running example

**Proposition 3.6.** For $N=55$, $P=(9,28)$,
$$\Psi_4(55,9) = (9^3+55)\bigl(9^6+20\cdot55\cdot 9^3 - 8\cdot 55^2\bigr) = 784\cdot 1309141 = 2^4\cdot 7^2\cdot 827\cdot 1583 .$$
Consequently each of $7$, $827$, $1583$ — none dividing the discriminant $-432\cdot 55^2$ nor $N$ — divides $\operatorname{den} x(4P)$.

Direct computation confirms $\operatorname{den}x(4P) = 2^8\cdot 7^2\cdot 827^2\cdot 1583^2$. At layer 2 only $7$ appears; at layer 3 only $13$ and $73$; layer 4 contributes two new large primes with a single polynomial evaluation. Note also the exponent doubling — the $\ell$-adic valuations grow along the tower, a phenomenon governed by the formal group at $\ell$ and not pursued here.

---

## 4. Class counts at layer 4: a reciprocity dichotomy

### 4.1 The counting problem

Fix a prime $\ell\ge5$ and work in $\mathbb{F}_\ell = \mathbb{Z}/\ell$.

**Definition 4.1.** For $c\in\mathbb{F}_\ell$ (thought of as $N \bmod \ell$) put
$$V_2(c) := \{t : t^3+c=0\}, \qquad W_4(c) := \{t : t^6+20ct^3-8c^2 = 0\}, \qquad V_4(c) := \{t : (t^3+c)(t^6+20ct^3-8c^2)=0\}.$$
Thus $V_4(c) = V_2(c)\cup W_4(c)$, and by Theorem 3.5, $x \bmod \ell \in V_4(N\bmod\ell)$ is exactly the layer-4 divisibility criterion. Define the **layer-4 total**
$$T_4(\ell) := \sum_{c\in\mathbb{F}_\ell} \# V_4(c).$$
Likewise $T_2(\ell) = \sum_c\#V_2(c)$ and $T_3(\ell)$ for the layer-3 locus $3t(t^3+4c)$.

**Lemma 4.2 (the Kummer layers).** $T_2(\ell) = \ell$ and $T_3(\ell) = 2\ell-1$.

*Proof sketch.* Transpose the count: $T_2(\ell) = \sum_t \#\{c : t^3+c=0\}$, and for each $t$ there is exactly one such $c$, namely $c = -t^3$. So $T_2 = \ell$. For layer 3 the locus is the union of $\{t=0\}$ (all $\ell$ values of $c$) and $\{t^3 = -4c\}$ (one $c$ per $t$, so $\ell$ pairs); the two overlap only at $(t,c)=(0,0)$, whence $2\ell-1$. $\square$

The mechanism is that a Kummer factor $T^k + \gamma N^{j}$ with $j=1$ is *linear in $N$*: transposing, each $t$ has exactly one $c$. This is what produces the clean "one $\ell$ per irreducible factor" law, and what suggested the conjecture $T_n(\ell) = k_n\ell + O(1)$ with $k_n$ the number of irreducible factors. Since $\Psi_4 = (T^3+N)\cdot S$ with $S$ irreducible over $\mathbb{Q}(N)$, that conjecture predicts $T_4(\ell) = 2\ell + O(1)$.

### 4.2 The fibres of the sextic

The new factor $S$ is *quadratic* in $N$, and this changes everything.

**Definition 4.3.** For $t\in\mathbb{F}_\ell$ let $W^{\mathrm{fib}}(t) := \{c\in\mathbb{F}_\ell : t^6+20ct^3-8c^2=0\}$, the transposed fibre.

**Lemma 4.4 (completing the square).** For $\ell\ge5$ and $t,c\in\mathbb{F}_\ell$,
$$t^6+20ct^3-8c^2 = 0 \iff (4c-5t^3)^2 = 27\,(t^3)^2 .$$

*Proof.* $(4c-5t^3)^2 - 27t^6 = 16c^2 - 40ct^3 + 25t^6 - 27t^6 = -2\,(t^6+20ct^3-8c^2)$, and $2$ is invertible. $\square$

**Lemma 4.5 (fibre sizes).** Let $\ell\ge5$.
1. $\#W^{\mathrm{fib}}(0) = 1$ (namely $c=0$).
2. If $3$ is a square modulo $\ell$ then $\#W^{\mathrm{fib}}(t) = 2$ for every $t\ne0$.
3. If $3$ is not a square modulo $\ell$ then $\#W^{\mathrm{fib}}(t) = 0$ for every $t\ne0$.

*Proof.* (1) At $t=0$ the equation reads $-8c^2=0$, and $8$ is invertible. For $t\ne 0$, Lemma 4.4 says $c$ is a solution iff $4c - 5t^3$ is a square root of $27t^6$. Since $27 = 3^3$ and $t^6$ is a square, $27t^6$ is a square iff $3$ is. (2) If $3=r^2$ then $s := 3r$ satisfies $s^2 = 27$, and the two solutions are $c_{1,2} = (5t^3 \pm s t^3)/4$, distinct because $2$, $s$ and $t$ are nonzero. (3) If some $c$ existed, then $\bigl((4c-5t^3)/(3t^3)\bigr)^2 = 27t^6/(9t^6) = 3$ would exhibit $3$ as a square. $\square$

**Theorem 4.6 (the new locus).** For $\ell\ge5$,
$$\sum_{c\in\mathbb{F}_\ell} \#W_4(c) \;=\; \sum_{t\in\mathbb{F}_\ell}\#W^{\mathrm{fib}}(t) \;=\; \begin{cases} 2\ell-1, & 3 \text{ a square mod } \ell,\\ 1, & \text{otherwise.}\end{cases}$$

*Proof.* The first equality is Fubini for the finite incidence set $\{(c,t) : S(c,t)=0\}$. The second is Lemma 4.5: split off $t=0$, contributing $1$, and sum $2$ (resp. $0$) over the $\ell-1$ nonzero $t$. $\square$

**Lemma 4.7 (overlap).** For $\ell\ge5$, $\sum_{c} \#\bigl(V_2(c)\cap W_4(c)\bigr) = 1$.

*Proof.* If $t\in V_2(c)\cap W_4(c)$ then $t^3=-c$ and, substituting, $c^2 - 20c^2 - 8c^2 = -27c^2 = 0$, so $c=0$ (as $27$ is invertible) and then $t=0$. Conversely $(c,t)=(0,0)$ does lie in both. $\square$

**Theorem 4.8 (layer-4 total).** For every prime $\ell\ge5$,
$$T_4(\ell) = \begin{cases} 3\ell-2, & 3 \text{ a square mod } \ell,\\ \ell, & 3 \text{ not a square mod } \ell.\end{cases}$$

*Proof.* Inclusion–exclusion classwise, $\#V_4(c) + \#(V_2(c)\cap W_4(c)) = \#V_2(c) + \#W_4(c)$. Summing over $c$ and using Lemma 4.2 ($T_2=\ell$), Theorem 4.6 and Lemma 4.7 gives $T_4(\ell)+1 = \ell + (2\ell-1)$ or $T_4(\ell)+1 = \ell+1$ respectively. $\square$

**Corollary 4.9 (explicit values).** $T_4(7)=7$, $T_4(13)=37$, $T_4(19)=19$.

By quadratic reciprocity, $3$ is a square modulo $\ell$ precisely when $\ell\equiv\pm1\pmod{12}$:

**Proposition 4.10.** For a prime $\ell\ge5$: if $\ell\equiv1\pmod{12}$ then $3$ is a square mod $\ell$; if $\ell\equiv5$ or $7\pmod{12}$ then it is not. (And $\ell\equiv11\pmod{12}$ again gives a square.)

*Proof sketch.* Quadratic reciprocity for the odd primes $3$ and $\ell$ gives $\bigl(\tfrac3\ell\bigr)\bigl(\tfrac\ell3\bigr) = (-1)^{(\ell-1)/2}$; combining with the evaluation of $\bigl(\tfrac\ell3\bigr)$ (which is $+1$ iff $\ell\equiv1\bmod3$) and the sign $(-1)^{(\ell-1)/2}$ (governed by $\ell\bmod4$) yields the four cases modulo $12$. In the case $\ell\equiv 5 \pmod{12}$ one uses that $2$ is not a square modulo $3$. $\square$

### 4.3 Refutation of linear growth

**Theorem 4.11.** There is no pair of natural numbers $(k,C)$ with
$$k\ell - C \;\le\; T_4(\ell)\;\le\; k\ell + C \qquad \text{for all primes } \ell\ge5 .$$

*Proof.* By Dirichlet's theorem there are arbitrarily large primes $\ell_2\equiv 5\pmod{12}$; for these $T_4(\ell_2)=\ell_2$, so $k\ell_2 \le \ell_2 + C$ and $\ell_2 \le k\ell_2 + C$. Choosing $\ell_2 > C+10$ forces $k=1$ (for $k\ge 2$ we would need $2\ell_2\le \ell_2+C$; for $k=0$, $\ell_2\le C$). Now take a prime $\ell_1\equiv1\pmod{12}$ with $\ell_1 > C+10$: then $T_4(\ell_1)=3\ell_1-2 \le \ell_1+C$, i.e. $2\ell_1\le C+2$, a contradiction. $\square$

**Discussion 4.12 (what replaces it).** The failure is structural, not accidental. Transposing the count reduces the layer-$n$ total to a sum of *fibre sizes* $\#\{c : f(t,c)=0\}$ over the irreducible factors $f$ of $\psi_n$. A factor linear in $N$ has fibre size identically $1$ and contributes $\ell$; a factor of degree $d$ in $N$ contributes the average number of roots of a degree-$d$ polynomial, which by Chebotarev's density theorem is governed by the Frobenius class of $\ell$ in the splitting field of $f$ over $\mathbb{Q}(N)$. At layer 4 that splitting field is $\mathbb{Q}(\sqrt3)$ and the class function takes the two values $3$ and $1$; the naive prediction $2\ell$ is exactly the average of $3\ell-2$ and $\ell$, which is why it looked plausible from the mean. The correct general statement is therefore:
$$T_n(\ell) = f_n(\mathrm{Frob}_\ell)\cdot\ell + O_n(1)$$
for a class function $f_n$ on a finite Galois group attached to $\psi_n$, with $f_2\equiv1$, $f_3\equiv2$, and $f_4$ the $\{1,3\}$-valued character-derived function above.

---

## 5. Layer 4 activates no new residues

Beyond counting pairs, one may ask which residues $c=N\bmod\ell$ are *active*, i.e. have $V_n(c)\ne\emptyset$. Layer 2 is active iff $-c$ is a cube mod $\ell$; for $\ell\equiv1\pmod3$ this excludes $2(\ell-1)/3$ **blind** residues. Layer 3, thanks to the free root $t\equiv0$, is active everywhere. One might hope that layer 4, having strictly more roots on average, sees more; it does not.

**Theorem 5.1 (the hidden cube).** Let $\ell\ge5$ and $c\in\mathbb{F}_\ell$. If $W_4(c)\ne\emptyset$ then $V_2(c)\ne\emptyset$.

*Proof.* Let $t\in W_4(c)$. If $t=0$ then $8c^2=0$, so $c=0$ and $0\in V_2(0)$. Suppose $t\ne0$ and set
$$g := \frac{4c-5t^3}{3t^3}.$$
By Lemma 4.4, $g^2 = 27t^6/(9t^6) = 3$, and by construction $4c = t^3(5+3g)$. Now use the identity in $\mathbb{Z}[g]/(g^2-3)$:
$$\left(\frac{-1-g}{2}\right)^{3} = \frac{-(1+g)^3}{8} = \frac{-(1 + 3g + 3g^2 + g^3)}{8} = \frac{-(1+3g+9+3g)}{8} = -\frac{5+3g}{4}.$$
Hence $\bigl(\tfrac{-1-g}{2}\,t\bigr)^3 = -\tfrac{(5+3g)t^3}{4} = -c$, so $\tfrac{-1-g}{2}t \in V_2(c)$. $\square$

**Corollary 5.2.** For every prime $\ell\ge5$ and every $c$: $V_4(c)\ne\emptyset \iff V_2(c)\ne\emptyset$.

*Proof.* $V_4 = V_2\cup W_4$; combine with Theorem 5.1. $\square$

**Corollary 5.3 (blind residues stay blind).** Let $\ell\ge5$, $\ell\nmid N$, and suppose $-N$ is not a cube modulo $\ell$. Then for every integral point $P=(x,y)$ of $E_N$ with $y\ne0$ and $S(N,x)\ne0$, $\ell\nmid\operatorname{den}x(4P)$.

**Corollary 5.4 (structure when $3$ is a non-residue).** If $\ell\equiv\pm5\pmod{12}$ then $W_4(c)=\emptyset$ for every $c\ne0$, so $V_4(c)=V_2(c)$: at such primes the quadrupling layer sees literally the same classes as the doubling layer, with the same multiplicities.

So activity along the tower is **not monotone**: layer 2 is partially blind (active density $(\ell+2)/(3\ell)$ when $\ell\equiv1\bmod3$), layer 3 is totally active, layer 4 relapses to layer 2's set of active residues while possibly tripling the number of producing pairs. The distinguishing structural feature is the presence of an $N$-free root: $\psi_3$ has one ($x\equiv0$), $\psi_2$ and $\psi_4$ do not.

---

## 6. The information barrier through layer 4

Elliptic curves furnish a genuine factoring algorithm (Lenstra's method), so it is natural to ask whether the rich prime structure in denominators leaks information about the factorisation of $N$. The answer, at least through layer 4 and below any fixed prime bound, is a provable no.

**Lemma 6.1 (polynomiality).** $\Psi_4(N,x) - \Psi_4(M,x) = (N-M)\bigl(21x^6 + 12x^3(N+M) - 8(N^2+NM+M^2)\bigr)$.

*Proof.* Expand both as $x^9 + 21Nx^6+12N^2x^3-8N^3$ and subtract. $\square$

**Corollary 6.2.** If $\ell \mid N-M$ then $\ell\mid\Psi_4(N,x) \iff \ell\mid\Psi_4(M,x)$, for every integer $x$. The same holds for the layer-2 polynomial $x^3+N$ and the layer-3 polynomial $3x^4+12Nx$.

**Theorem 6.3 (barrier through layer 4).** Let $B\in\mathbb{N}$ and let $N=pq$ with $p,q$ primes exceeding $B$. Then there exists a prime $M>N$ such that for every prime $\ell\le B$ and every integer $x$,
$$\ell\mid x^3+N \iff \ell\mid x^3+M, \qquad \ell\mid \psi_3(N,x)\iff \ell\mid\psi_3(M,x),\qquad \ell\mid\Psi_4(N,x)\iff\ell\mid\Psi_4(M,x).$$

*Proof.* Since $p,q>B$, $N=pq$ is coprime to $B!$. By Dirichlet's theorem on primes in arithmetic progressions the class $N \bmod B!$ contains infinitely many primes; pick one, $M > N$. For any prime $\ell\le B$ we have $\ell\mid B!$ and therefore $\ell \mid M-N$; Corollary 6.2 applies at all three layers. $\square$

**Discussion 6.4.** The barrier says the *entire* small-prime denominator profile of the first four layers is a function of $N \bmod B!$ alone. Since a prime $M$ shares that residue, no statistic computed from these data can distinguish a semiprime from a prime, let alone reveal $p$ or $q$. This is an information-theoretic statement, not a hardness assumption. It also isolates precisely what a hypothetical elliptic-denominator factoring method would have to use: either primes $\ell$ comparable to $p,q$ (where the criterion is no longer "small"), or the *valuations* rather than the mere occurrence of small primes, or the specific integral points available on $E_N$ — data not captured by residue-class criteria.

Note the contrast with Section 4: the *criterion* is perfectly uniform in $N \bmod \ell$, but the *number of solutions* is not uniform in $\ell$. Uniformity in $N$ produces the barrier; non-uniformity in $\ell$ produces the reciprocity dichotomy. The two coexist without tension.

---

## 7. Algorithms

We record the three procedures implicit above; all are elementary and fast.

**Algorithm A (layer-4 denominator primes of a point).** Input: $N$, an integral point $(x,y)$ on $E_N$, a bound $L$. Output: all primes $5\le\ell\le L$ with $\ell\nmid N$ dividing $\operatorname{den}x(4P)$.
Compute $\Psi_4(N,x) = (x^3+N)(x^6+20Nx^3-8N^2)$ once, then test $\ell\mid\Psi_4$ for each candidate. Cost: one evaluation of a degree-9 integer polynomial plus $O(\pi(L))$ divisions — versus a full exact rational quadrupling and factorisation of a much larger denominator. Correctness is Theorem 3.5.

**Algorithm B (layer totals and the dichotomy).** Input: prime $\ell\ge5$. Output: $T_4(\ell)$ together with the predicted value.
Brute-force $T_4(\ell)$ by iterating over the $\ell^2$ pairs $(c,t)$ — cost $O(\ell^2)$ field operations — and compare with $3\ell-2$ or $\ell$ according to whether $3$ is a quadratic residue mod $\ell$ (Euler's criterion, $O(\log \ell)$ multiplications; or the congruence $\ell\bmod12$). Correctness is Theorem 4.8. A refined $O(\ell)$ version counts fibres instead: for $t\ne0$, add $1+\chi(3)$ where $\chi$ is the quadratic character.

**Algorithm C (barrier witness).** Input: $B$ and a semiprime $N=pq$ with $p,q>B$. Output: a prime $M>N$ with $M\equiv N \pmod{B!}$.
Compute $B!$, then search $M = N + kB!$ for $k=1,2,\dots$, testing primality. Termination is guaranteed by Dirichlet's theorem; heuristically, primes in the progression have density $B!/\varphi(B!)$ times the ambient density, so the expected number of trials is $O\bigl(\tfrac{\varphi(B!)}{B!}\log N\bigr)$ — in practice a handful for moderate $B$. Correctness is Theorem 6.3.

---

## 8. Discussion and open problems

### 8.1 Summary

At the quadrupling layer of the Mordell family:

1. **Criterion.** For $\ell\ge5$, $\ell\nmid N$: $\ell\mid\operatorname{den}x(4P)\iff\ell\mid(x^3+N)(x^6+20Nx^3-8N^2)$, with the identity $(x^4-8Nx)^3+64N(x^3+N)^3 = (x^6+20Nx^3-8N^2)^2$ as the structural source.
2. **Non-cancellation constants.** $3^8$ and $2^63^2$ — $\{2,3\}$-units, as at layers 2 and 3.
3. **Counting.** $T_4(\ell) = 3\ell-2$ or $\ell$ according to the quadratic character of $3$; no linear law with bounded error exists.
4. **Activity.** Layer 4 is active exactly where layer 2 is; blind residues remain blind.
5. **Barrier.** Layers 2–4 below any bound $B$ are blind to the factorisation of a semiprime.

### 8.2 Open problems

**(E1) A Chebotarev law for the layer totals.** Conjecturally, for every $n\ge2$ there is a finite Galois extension $K_n/\mathbb{Q}(N)$ and a class function $f_n$ on its Galois group with $T_n(\ell) = f_n(\mathrm{Frob}_\ell)\cdot\ell + O_n(1)$ for all $\ell\ge5$ with $\ell\nmid n$, and $f_n$ is non-constant as soon as $\psi_n$ acquires a factor which is not linear in $N$. Known: $f_2\equiv1$, $f_3\equiv2$, $f_4\in\{1,3\}$ determined by the splitting of $\ell$ in $\mathbb{Q}(\sqrt3)$. The first test is layer 5: $\psi_5$ has degree $12$ in $x$, and the prediction is that $T_5(\ell)$ depends only on the Frobenius class of $\ell$ in the splitting field of the $\mathbb{Q}(N)$-factors of $\psi_5$. A dependence on $\ell$ beyond a Frobenius class would refute the conjecture.

**(E2) Blindness along the $2$-power tower.** Layers $2$ and $4$ have the same active residues. Is this true of all layers $2^k$ — i.e. is the cubic character of $-N$ the sole obstruction along the doubling tower, with the free-root mechanism confined to layers divisible by $3$?

**(E3) Valuations, not just occurrence.** The example $N=55$ shows exponent growth: $7^2$ at layer 2 becomes $7^2\cdot827^2\cdot1583^2$ at layer 4. The formal group at $\ell$ predicts $v_\ell(\operatorname{den}x(2^kP)) = v_\ell(\operatorname{den}x(2P)) + 2(k-1)$ for odd $\ell$ and $k\ge1$. Proving this exact arithmetic progression is pure $\ell$-adic bookkeeping on top of the criteria above, and would strengthen the barrier discussion of §6.4, since valuations are the natural next statistic an adversary might use.

**(E4) Realisability.** All counting statements above are about residue classes; upgrading them to statements about actual denominators requires exhibiting integral points of $E_N$ in the relevant classes. Conjecturally, for every prime $\ell\ge5$ and every residue $c$ mod $\ell$ there are infinitely many $N\equiv c\pmod\ell$ such that $E_N(\mathbb{Z})$ contains a point in every active class of $\ell$. One-parameter families such as $N=\ell^2-1$ with $P=(1,\ell)$, and $N=1-\ell^3$ with $P=(\ell,1)$, realise prescribed classes; the general statement is a question about representing residues by the binary form $y^2-x^3$.

**(E5) A quantitative "no factor oracle" theorem.** Fix a semiprime $N=pq$ and an integral point $P$ of infinite order. The heuristic is that $p$ divides $\operatorname{den}x(nP)$ only when $\bar P$ is trivial in $E_N(\mathbb{F}_p)$, an event of probability $\approx 1/\#E_N(\mathbb{F}_p)\approx 1/p$, whereas each good prime $\ell$ contributes at rate $\approx1/\ell$ and there are $\gg T$ of them below the height of $nP$ for $n\le T$. So the expected number of occurrences of $p$ or $q$ among the denominator primes for $n\le T$ should be $O(\log\log T)$ against $\gg T$ total. Making this a theorem requires height bounds along the orbit; the per-prime densities computed here are the arithmetic input.

### 8.3 Broader remarks

Two features of the layer-4 analysis seem likely to generalise beyond the Mordell family. First, the reduction of a torsion criterion to a *fibre-counting* problem after transposition ($x$ fixed, $N$ varying) turns division-polynomial combinatorics into character sums, and character sums into Frobenius data; the Kummer case is the degenerate one in which every fibre is a singleton. Second, the presence or absence of an $N$-free root of $\psi_n$ decides whether the layer can see all residues; for a general family this becomes the question of whether $\psi_n$ has a factor independent of the family parameter, which is a purely geometric condition on the universal curve.

Finally, the interplay found here — a criterion perfectly uniform in the parameter modulo $\ell$, but a solution count wildly non-uniform in $\ell$ — is a compact illustration of why local data can be simultaneously very rich (statistically) and completely uninformative (about global factorisation).

---

## Appendix: numerical data

Layer-4 totals $T_4(\ell)$ for small primes, with the predicted value:

| $\ell$ | $\ell \bmod 12$ | $3$ a square? | $T_4(\ell)$ | prediction |
|---|---|---|---|---|
| 5 | 5 | no | 5 | $\ell=5$ |
| 7 | 7 | no | 7 | $\ell=7$ |
| 11 | 11 | yes | 31 | $3\ell-2=31$ |
| 13 | 1 | yes | 37 | $3\ell-2=37$ |
| 17 | 5 | no | 17 | $\ell=17$ |
| 19 | 7 | no | 19 | $\ell=19$ |
| 23 | 11 | yes | 67 | $3\ell-2=67$ |
| 29 | 5 | no | 29 | $\ell=29$ |
| 31 | 7 | no | 31 | $\ell=31$ |
| 37 | 1 | yes | 109 | $3\ell-2=109$ |
| 41 | 5 | no | 41 | $\ell=41$ |
| 43 | 7 | no | 43 | $\ell=43$ |

Running example $N=55$, $P=(9,28)$:

| layer $n$ | criterion polynomial | value at $x=9$ | new good primes |
|---|---|---|---|
| 2 | $x^3+N$ | $784 = 2^4\cdot7^2$ | $7$ |
| 3 | $3x(x^3+4N)$ | $3\cdot9\cdot949 = 3^3\cdot13\cdot73$ | $13$, $73$ |
| 4 | $(x^3+N)(x^6+20Nx^3-8N^2)$ | $2^4\cdot7^2\cdot827\cdot1583$ | $827$, $1583$ |

and indeed $\operatorname{den}x(4P) = 2^8\cdot7^2\cdot827^2\cdot1583^2$.
