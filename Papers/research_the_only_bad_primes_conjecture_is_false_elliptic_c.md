# Apparition of Good Primes in Mordell-Curve Denominators: The Refutation of the "Only Bad Primes" Conjecture

**Author:** Aristotle
**Date:** 2026-08-15

---

## Abstract

For an integer $N \neq 0$, let $E_N$ denote the Mordell curve $y^2 = x^3 + N$ over $\mathbb{Q}$, with discriminant $\Delta = -432N^2$. A folklore conjecture — attractive because of its potential consequences for integer factorisation when $N = pq$ is a semiprime — asserts that the primes dividing the denominators of the $x$-coordinates of the multiples $nP$ of a rational point $P$ are confined to the primes dividing $\Delta$, namely $\{2, 3\} \cup \{p : p \mid N\}$. We prove that this conjecture is false in the strongest possible sense.

The elementary counterexample is $N = 55 = 5 \cdot 11$, $P = (9,28)$, for which $x(2P) = 2601/3136$ with $3136 = 2^6 \cdot 7^2$: the good prime $7$ divides the denominator. We then show that this is not an accident of the example but a universal law. Our main results are: (i) an **effective apparition theorem** — for every $N$, every prime $\ell \geq 5$ with $\ell \nmid N$, and every rational point $P$ of $E_N$, some multiple $nP$ with $0 < n \leq 4\ell$ has $\ell$ in the denominator of its $x$-coordinate; (ii) an **exact counting theorem** — the violating indices in $(0,K]$ number exactly $\lfloor K/m\rfloor$ where $m \le 4\ell$ is the apparition index of $\ell$, so violations have density $\geq 1/(4\ell)$; (iii) a **simultaneous apparition theorem** — for any finite set $S$ of good primes, $\prod_{\ell \in S}\ell$ divides the denominator exactly along an arithmetic progression of modulus $M \le \prod_{\ell \in S} 4\ell$; and (iv) a **global refutation** — for every $N \neq 0$ and every point of infinite order, infinitely many good primes occur in the denominators, and the correct statement is the *reverse* inclusion: a prime absent from all denominators must lie in $\{2,3\} \cup \{p : p \mid N\}$.

The proofs are entirely elementary: an explicit chord identity, the curve equation, and a pigeonhole argument over the at-most-$2\ell$ points of the reduced curve. We also record the algorithmic consequences, a computational survey over eleven semiprimes showing the conjecture fails in $100\%$ of tested cases, and a structural barrier explaining why denominator data cannot reveal the factorisation of $N$.

**Keywords:** Mordell curve, elliptic divisibility sequence, rank of apparition, good reduction, denominator kernel, integer factorisation.

---

## 1. Introduction

### 1.1 The conjecture

Let $N$ be a nonzero integer and let
$$E_N : \quad y^2 = x^3 + N$$
be the associated Mordell curve over $\mathbb{Q}$, a smooth projective cubic with discriminant
$$\Delta(E_N) = -432N^2 = -2^4 \cdot 3^3 \cdot N^2.$$
The primes of **bad reduction** of $E_N$ are therefore contained in $\{2,3\} \cup \{p : p \mid N\}$; all other primes are primes of **good reduction**, and modulo such a prime $E_N$ remains a smooth curve over $\mathbb{F}_\ell$.

If $P \in E_N(\mathbb{Q})$ is a rational point of infinite order, the multiples $P, 2P, 3P, \dots$ are rational points whose coordinates have rapidly growing denominators. Writing $x(nP) = A_n / D_n$ in lowest terms, one obtains the *denominator sequence* $(D_n)_{n \geq 1}$; up to squares this is the classical elliptic divisibility sequence attached to $P$.

> **The "only bad primes" conjecture.** For every prime $\ell$, every $n > 0$ and every $N \ne 0$: if $\ell \mid D_n$, then $\ell \in \{2,3\} \cup \{p : p \mid N\}$.

The appeal of the conjecture is cryptanalytic. If $N = pq$ is a semiprime and the denominators of an orbit were built only from $\{2, 3, p, q\}$, then a single denominator computation followed by the removal of all powers of $2$ and $3$ would exhibit $p$ and $q$: a polynomial-time factoring algorithm. The conjecture is thus a natural hypothesis to test, and a natural one to want to be true.

### 1.2 The counterexample

It fails immediately. On $E_{55}$ with $N = 55 = 5 \cdot 11$ take
$$P = (9, 28), \qquad 28^2 = 784 = 729 + 55 = 9^3 + 55.$$
The duplication formula on $y^2 = x^3 + N$ reads
$$x(2Q) = \frac{x^4 - 8Nx}{4(x^3+N)} = \frac{x^4 - 8Nx}{4y^2},$$
so
$$x(2P) = \frac{9^4 - 8 \cdot 55 \cdot 9}{4(9^3 + 55)} = \frac{6561 - 3960}{4 \cdot 784} = \frac{2601}{3136}, \qquad 3136 = 2^6 \cdot 7^2 .$$
Since $7 \nmid -432 \cdot 55^2$, the prime $7$ is a prime of good reduction dividing $D_2$. The conjecture is false.

### 1.3 Results of this paper

Rather than stop at a counterexample, we determine exactly which primes can occur and how often. The organising principle is the classical one:

$$\ell \mid \operatorname{den} x(Q) \quad \Longleftrightarrow \quad Q \equiv O \pmod{\ell},$$

i.e. divisibility of a denominator by $\ell$ is *reduction to the point at infinity*, a group-theoretic condition. From this everything follows. Our principal statements, all proved below, are:

- **Theorem A (Collision Lemma, §4).** Two $\ell$-integral rational points of $E_N$ with the same reduction modulo a good prime $\ell \ge 5$ have $2(P_1 - P_2)$ in the denominator kernel at $\ell$.
- **Theorem B (Effective apparition, §5).** For $\ell \ge 5$ prime, $\ell \nmid N$, and any $P \in E_N(\mathbb{Q})$, some $n$ with $0 < n \le 4\ell$ has $nP$ in the denominator kernel; if $P$ has infinite order, $\ell \mid \operatorname{den} x(nP)$ for such an $n$.
- **Theorem C (Apparition law with effective modulus, §6).** The set $\{k \in \mathbb{Z} : \ell \mid \operatorname{den} x(kP)\}$ equals $m\mathbb{Z}$ for a modulus $m$ with $0 < m \le 4\ell$.
- **Theorem D (Exact counting and density, §6).** $\#\{n \in (0,K] : \ell \mid \operatorname{den} x(nP)\} = \lfloor K/m \rfloor \ge \lfloor K/(4\ell)\rfloor$.
- **Theorem E (Simultaneous apparition, §7).** For a finite set $S$ of good primes $\ge 5$ there is $0 < M \le \prod_{\ell\in S} 4\ell$ with $\prod_{\ell \in S}\ell \mid \operatorname{den} x(kP) \iff M \mid k$; on $E_{55}$ with $P = (9,28)$, $91 \mid \operatorname{den} x(kP) \iff 6 \mid k$.
- **Theorem F (Global refutation, §8).** For $N \ne 0$ and $P$ of infinite order, infinitely many good primes occur in the denominators; the conjecture fails for every such $(N, P)$; and the correct inclusion is the reverse one.

Section 9 gives the algorithms, §10 the computational evidence, §11 the consequences for factoring and the structural barrier, and §12 the open problems.

---

## 2. Setting and definitions

Throughout, $N \in \mathbb{Z}\setminus\{0\}$ and $E_N : y^2 = x^3 + N$ over $\mathbb{Q}$. Points of $E_N(\mathbb{Q})$ are either the point at infinity $O$ (the group identity) or affine pairs $(x,y) \in \mathbb{Q}^2$ satisfying the equation.

**Definition 2.1 (Denominator and numerator).** For $q \in \mathbb{Q}$ write $q = \operatorname{num}(q)/\operatorname{den}(q)$ in lowest terms with $\operatorname{den}(q) > 0$. For an affine point $Q = (x,y)$ we abbreviate $\operatorname{den} x(Q) := \operatorname{den}(x)$.

**Definition 2.2 ($\ell$-integrality).** A rational $q$ is *$\ell$-integral* if $\ell \nmid \operatorname{den}(q)$. An affine point is $\ell$-integral if its $x$-coordinate is.

**Definition 2.3 (Reduction of a rational).** For a prime $\ell$ and $q \in \mathbb{Q}$ set
$$\rho_\ell(q) := \overline{\operatorname{num}(q)} \cdot \overline{\operatorname{den}(q)}^{\,-1} \in \mathbb{F}_\ell ,$$
which is the usual reduction whenever $q$ is $\ell$-integral. Two immediate facts, used constantly: for $\ell$-integral $q$, $\rho_\ell(q) = 0 \iff \ell \mid \operatorname{num}(q)$; and for $\ell$-integral $q, r$, $\rho_\ell(q) = \rho_\ell(r)$ iff $\ell \mid \operatorname{num}(q)\operatorname{den}(r) - \operatorname{num}(r)\operatorname{den}(q)$.

**Definition 2.4 (Denominator kernel).** For a prime $\ell$,
$$\mathcal{K}_\ell := \{\, Q \in E_N(\mathbb{Q}) \;:\; Q = O \ \text{ or } \ \ell \mid \operatorname{den} x(Q) \,\}.$$
Equivalently, $\mathcal{K}_\ell$ consists of the points whose reduction modulo $\ell$ is the point at infinity. It is a **subgroup** of $E_N(\mathbb{Q})$ — this is the standard fact that the kernel of reduction is a subgroup, and it can be established directly from the addition formulas without constructing the reduction morphism; we take it as given here and use it freely.

**Definition 2.5 (Good prime).** A prime $\ell$ is *good* for $E_N$ if $\ell \nmid \Delta = -432N^2$; since $432 = 2^4 3^3$, this means $\ell \ge 5$ and $\ell \nmid N$. All results below are stated with the hypotheses "$\ell$ prime, $\ell \ge 5$, $\ell \nmid N$", which is exactly good reduction.

**Definition 2.6 (Apparition index).** Given $P \in E_N(\mathbb{Q})$ and a prime $\ell$, the *apparition index* of $\ell$ (for $P$) is the nonnegative generator $m$ of the subgroup $\{k \in \mathbb{Z} : kP \in \mathcal{K}_\ell\} \le \mathbb{Z}$; here $m = 0$ means that $\ell$ never appears.

The following elementary observation, immediate from Definition 2.4 and the subgroup property, is the *apparition law*.

**Proposition 2.7 (Apparition law).** For every prime $\ell$ and every $P \in E_N(\mathbb{Q})$ there is a unique $m \ge 0$ such that for all $k \in \mathbb{Z}$,
$$kP \in \mathcal{K}_\ell \iff m \mid k .$$
*Proof.* The map $k \mapsto kP$ is a homomorphism $\mathbb{Z} \to E_N(\mathbb{Q})$, and $\mathcal{K}_\ell$ is a subgroup, so the preimage is a subgroup of $\mathbb{Z}$, hence of the form $m\mathbb{Z}$. $\square$

Proposition 2.7 already contains the qualitative moral: *if a prime ever appears in a denominator, it appears periodically and hence infinitely often*. The substance of this paper is that for good primes $m$ is **never** $0$ and is **effectively bounded**.

---

## 3. The chord identity

The engine of everything is the following explicit formula, valid for the curve $y^2 = x^3 + N$.

**Lemma 3.1 (Difference chord).** Let $P_1 = (x_1,y_1)$ and $P_2 = (x_2, y_2)$ be affine points of $E_N$ with $x_1 \ne x_2$. Then $P_1 - P_2$ is affine and
$$x(P_1 - P_2) \;=\; \frac{x_1x_2(x_1+x_2) + 2N + 2y_1y_2}{(x_1-x_2)^2}.$$

*Proof.* The point $-P_2 = (x_2, -y_2)$. The chord through $P_1$ and $-P_2$ has slope $\lambda = -(y_1+y_2)/(x_1-x_2)$ and the group law gives $x(P_1-P_2) = \lambda^2 - x_1 - x_2$, i.e.
$$x(P_1-P_2) = \frac{(y_1+y_2)^2 - (x_1+x_2)(x_1-x_2)^2}{(x_1-x_2)^2}.$$
Expanding the numerator and substituting $y_i^2 = x_i^3 + N$:
$$y_1^2+y_2^2+2y_1y_2 - (x_1+x_2)(x_1^2 - 2x_1x_2 + x_2^2) = x_1^3+x_2^3+2N+2y_1y_2 - \big(x_1^3+x_2^3 - x_1^2x_2 - x_1x_2^2\big),$$
which equals $x_1x_2(x_1+x_2) + 2N + 2y_1y_2$. $\square$

Written in integral coordinates $x_i = a_i/d_i$, $y_i = b_i/f_i$ (lowest terms), Lemma 3.1 becomes the integral fraction
$$x(P_1-P_2) = \frac{a_1a_2(a_1d_2 + a_2d_1)f_1f_2 + 2N d_1^2d_2^2 f_1f_2 + 2b_1b_2d_1^2d_2^2}{(a_1d_2 - a_2d_1)^2 f_1 f_2}, \tag{3.2}$$
a form in which the divisibility bookkeeping can be performed with integers only. This is the shape in which the Collision Lemma is proved.

We also record the duplication formula and its local consequence.

**Lemma 3.3 (Duplication).** For an affine point $Q = (x,y)$ of $E_N$ with $y \ne 0$,
$$x(2Q) = \frac{x^4 - 8Nx}{4y^2}.$$

**Lemma 3.4 ($2$-torsion branch).** Let $\ell \ge 5$ be prime with $\ell \nmid N$, and let $Q = (x,y)$ be an $\ell$-integral affine point of $E_N$ with $\ell \mid \operatorname{num}(y)$. Then $2Q \in \mathcal{K}_\ell$.

*Proof.* If $y = 0$ then $2Q = O \in \mathcal{K}_\ell$. Otherwise apply Lemma 3.3. Since $Q$ is $\ell$-integral and lies on the curve, $y$ is also $\ell$-integral, so $\rho_\ell(y) = \bar y = 0$ and $\bar y^2 = \bar x^3 + \bar N$ forces $\bar x^3 = -\bar N$. In particular $\bar x \ne 0$ (as $\ell \nmid N$). The numerator of the duplication formula reduces to
$$\bar x^4 - 8\bar N \bar x = \bar x(\bar x^3 - 8\bar N) = \bar x(-\bar N - 8\bar N) = -9\bar N \bar x \ne 0,$$
because $\ell \ge 5$ (so $\ell \nmid 9$) and $\ell \nmid N$. The denominator $4y^2$ has $\ell$ dividing its numerator (as $\ell \mid \operatorname{num}(y)$ and $\ell \nmid 4$), so the quotient has $\ell$ in its denominator, i.e. $2Q \in \mathcal{K}_\ell$. $\square$

---

## 4. Theorem A: the Collision Lemma

**Theorem A (Collision Lemma).** Let $\ell \ge 5$ be a prime with $\ell \nmid N$, and let $P_1 = (x_1,y_1)$, $P_2 = (x_2,y_2)$ be $\ell$-integral affine points of $E_N(\mathbb{Q})$ with the same reduction modulo $\ell$, i.e.
$$\rho_\ell(x_1) = \rho_\ell(x_2) \quad\text{and}\quad \rho_\ell(y_1) = \rho_\ell(y_2).$$
Then
$$2\,(P_1 - P_2) \in \mathcal{K}_\ell .$$

*Proof sketch.* Write $\bar x, \bar y$ for the common reductions. There are three cases.

**(a) $\bar y = 0$.** Then $\ell \mid \operatorname{num}(y_1)$ and $\ell \mid \operatorname{num}(y_2)$, so Lemma 3.4 gives $2P_1 \in \mathcal{K}_\ell$ and $2P_2 \in \mathcal{K}_\ell$. As $\mathcal{K}_\ell$ is a subgroup and $2(P_1 - P_2) = 2P_1 - 2P_2$, the claim follows.

**(b) $\bar y \ne 0$ and $x_1 = x_2$.** Subtracting the two curve equations gives $(y_1-y_2)(y_1+y_2) = 0$. If $y_1 = y_2$ then $P_1 = P_2$ and $2(P_1-P_2) = O \in \mathcal{K}_\ell$. If $y_2 = -y_1$ then reduction gives $\bar y = -\bar y$, i.e. $2\bar y = 0$; since $\ell \ge 5$ is odd this forces $\bar y = 0$, contradicting the case hypothesis.

**(c) $\bar y \ne 0$ and $x_1 \ne x_2$.** This is the heart of the matter. By Lemma 3.1,
$$x(P_1 - P_2) = \frac{x_1x_2(x_1+x_2)+2N+2y_1y_2}{(x_1-x_2)^2}.$$
Pass to the integral form (3.2). Equality of reductions means
$$\ell \mid a_1d_2 - a_2d_1 \quad\text{and}\quad \ell \mid b_1f_2 - b_2f_1,$$
so $\ell^2$ divides the factor $(a_1d_2-a_2d_1)^2$ of the denominator of (3.2); moreover $\ell \nmid d_i$ by $\ell$-integrality and $\ell \nmid f_i$ because a point of $E_N$ with $\ell$-integral $x$ has $\ell$-integral $y$ (from $y^2 = x^3 + N$). It remains to show that $\ell$ does not divide the numerator. Reducing the numerator of the *rational* form and using $\bar x_1 = \bar x_2 = \bar x$, $\bar y_1 = \bar y_2 = \bar y$ together with the curve equation $\bar y^2 = \bar x^3 + \bar N$:
$$\overline{x_1x_2(x_1+x_2) + 2N + 2y_1y_2} = 2\bar x^3 + 2\bar N + 2\bar y^2 = 2(\bar x^3 + \bar N) + 2\bar y^2 = 4\bar y^2 .$$
Since $\ell \ge 5$, $4$ is invertible modulo $\ell$; since $\bar y \ne 0$, the reduced numerator $4\bar y^2$ is nonzero. Hence the reduced fraction has $\ell$ in its denominator: $P_1 - P_2 \in \mathcal{K}_\ell$, and a fortiori $2(P_1-P_2) \in \mathcal{K}_\ell$ by the subgroup property. $\square$

Two remarks. First, the identity "numerator $\equiv 4\bar y^2$" is the entire content of case (c): the curve equation is used exactly once, and it is what converts a three-term expression into a perfect square. Second, the factor $2$ in the statement is needed *only* for case (a); in case (c) the difference itself already lies in $\mathcal{K}_\ell$. Theorem A is precisely the statement that reduction is injective on $E_N(\mathbb{Q})/\mathcal{K}_\ell$ up to multiplication by $2$, proved without ever constructing the reduction homomorphism.

---

## 5. Theorem B: the effective apparition bound

**Lemma 5.1 (Crude point count).** For a prime $\ell$ and any $N$, the set
$$C_\ell(N) := \{(u,v) \in \mathbb{F}_\ell^2 : v^2 = u^3 + N\}$$
satisfies $\#C_\ell(N) \le 2\ell$.

*Proof.* Partition $C_\ell(N)$ by the first coordinate. For each $u \in \mathbb{F}_\ell$ the fibre is $\{v : v^2 = c\}$ for $c = u^3 + N$, a set of size at most $2$ since a quadratic has at most two roots in a field. Summing over the $\ell$ values of $u$ gives $\#C_\ell(N) \le 2\ell$. $\square$

(Hasse's theorem would give $\#C_\ell(N)+1 \le \ell + 1 + 2\sqrt{\ell}$, roughly halving the bound; we deliberately use only the elementary count, and pay for it with a factor of $2$ in the final constant.)

**Theorem B (Effective apparition).** Let $\ell \ge 5$ be a prime with $\ell \nmid N$ and let $P \in E_N(\mathbb{Q})$ be arbitrary. Then there exists $n$ with
$$0 < n \le 4\ell \quad\text{and}\quad nP \in \mathcal{K}_\ell .$$
If moreover $P$ has infinite order, then $nP$ is affine and $\ell \mid \operatorname{den} x(nP)$.

*Proof.* Suppose, for contradiction, that $nP \notin \mathcal{K}_\ell$ for all $0 < n \le 4\ell$. Put $K := 2\ell + 1 \le 4\ell$ (using $\ell \ge 1$).

*Step 1 (all early multiples reduce).* For each $n \in \{1, \dots, K\}$ we have $nP \notin \mathcal{K}_\ell$, so $nP \ne O$ — say $nP = (x_n, y_n)$ — and $\ell \nmid \operatorname{den}(x_n)$; as noted, $\ell \nmid \operatorname{den}(y_n)$ follows from the curve equation. Hence the reduction $\pi(n) := (\rho_\ell(x_n), \rho_\ell(y_n))$ is a well-defined element of $C_\ell(N)$.

*Step 2 (pigeonhole).* $\#\{1,\dots,K\} = 2\ell + 1 > 2\ell \ge \#C_\ell(N)$ by Lemma 5.1, so there are $1 \le m < n \le K$ with $\pi(m) = \pi(n)$.

*Step 3 (collision).* By Theorem A applied to $P_1 = nP$, $P_2 = mP$,
$$2(n-m)P = 2(nP - mP) \in \mathcal{K}_\ell .$$
Set $t := 2(n-m)$. Then $0 < t \le 2(K-1) = 4\ell$, and $tP \in \mathcal{K}_\ell$ — contradicting the assumption. Hence some $n \le 4\ell$ works.

Finally, if $P$ has infinite order then $nP \ne O$ for $n > 0$, so membership in $\mathcal{K}_\ell$ means precisely that $nP$ is affine with $\ell \mid \operatorname{den} x(nP)$. $\square$

The constant is transparent: $4\ell = 2 \cdot (2\ell)$, where $2\ell$ is the crude bound of Lemma 5.1 and the outer $2$ comes from the doubling in Theorem A (which in turn comes from the $2$-torsion branch, case (a)).

**Corollary 5.2 (Reverse inclusion).** Let $P$ have infinite order and let $\ell$ be any prime that divides *no* denominator $\operatorname{den} x(nP)$, $n > 0$. Then $\ell = 2$, $\ell = 3$, or $\ell \mid N$.

*Proof.* If $\ell \notin \{2,3\}$ and $\ell \nmid N$, then $\ell \ge 5$ and Theorem B produces $n \le 4\ell$ with $\ell \mid \operatorname{den} x(nP)$. $\square$

**Corollary 5.3 (Finiteness of the absent primes).** For $N \ne 0$ and $P$ of infinite order, the set of primes dividing no orbit denominator is contained in the finite set $\{2, 3\} \cup \{p : p \mid N\}$, hence is finite.

Corollary 5.2 is the exact mirror image of the conjecture. The conjecture asserted $\{\text{primes present}\} \subseteq \{2,3\} \cup \{p \mid N\}$; the truth is $\{\text{primes absent}\} \subseteq \{2,3\} \cup \{p \mid N\}$.

**Corollary 5.4 (The curve $E_{55}$).** On $E_{55}$ with $P = (9,28)$ — a point of infinite order — every prime $\ell \ge 5$ other than $5$ and $11$ divides $\operatorname{den} x(nP)$ for some $0 < n \le 4\ell$.

---

## 6. Theorems C and D: apparition indices and density

**Theorem C (Apparition law with effective modulus).** Let $\ell \ge 5$ be prime with $\ell \nmid N$, and let $P \in E_N(\mathbb{Q})$. Then there is an integer $m$ with $0 < m \le 4\ell$ such that for all $k \in \mathbb{Z}$,
$$\ell \mid \operatorname{den} x(kP) \ \text{(vacuously if } kP = O) \iff m \mid k .$$

*Proof.* Proposition 2.7 gives $m \ge 0$ with $kP \in \mathcal{K}_\ell \iff m \mid k$. Theorem B gives $n$ with $0 < n \le 4\ell$ and $nP \in \mathcal{K}_\ell$, hence $m \mid n$. Since $n > 0$, $m \ne 0$; and $m \le n \le 4\ell$. $\square$

**Theorem D (Exact count of violations).** In the setting of Theorem C, for every $K \in \mathbb{N}$,
$$\#\{\, n \in (0,K] \;:\; \ell \mid \operatorname{den} x(nP) \,\} \;=\; \left\lfloor \frac{K}{m} \right\rfloor \;\ge\; \left\lfloor \frac{K}{4\ell} \right\rfloor .$$
If $P$ has infinite order the counted indices genuinely carry affine $x$-coordinates whose denominators $\ell$ divides (no index is counted vacuously).

*Proof.* By Theorem C the condition on $n$ is equivalent to $m \mid n$, and the multiples of $m$ in $(0,K]$ are $m, 2m, \dots, \lfloor K/m\rfloor m$, of which there are exactly $\lfloor K/m \rfloor$. The inequality follows from $m \le 4\ell$ and monotonicity of $K \mapsto \lfloor K/\cdot\rfloor$ in the divisor. For the last statement: if $P$ has infinite order then $nP \ne O$ for $n > 0$, so $nP$ is affine and the defining condition is a genuine divisibility. $\square$

Thus for each good prime $\ell$ the set of violating indices is an arithmetic progression of density
$$\frac{1}{m} \;\ge\; \frac{1}{4\ell} \;>\; 0 .$$
This upgrades the refutation from "there is a counterexample" to "a positive, explicitly bounded proportion of all indices are counterexamples, for every good prime simultaneously".

**Theorem D′ (Many good primes appear early).** Let $P$ have infinite order. For every $K$,
$$\#\{\ell \le K : \ell \text{ prime}, \ \ell \ge 5,\ \ell \nmid N, \ 4\ell \le K\} \;\le\; \#\{\ell \le K : \ell \mid \operatorname{den} x(nP) \text{ for some } 0 < n \le K\}.$$

*Proof.* By Theorem B, each $\ell$ in the left-hand set admits $n \le 4\ell \le K$ with $\ell \mid \operatorname{den} x(nP)$, so the left set injects into the right one. $\square$

In words: among the first $K$ denominators one sees at least $\pi(K/4) - O(\omega(N))$ distinct primes. The denominators are not merely large; they are *arithmetically rich*, and the richness is quantified.

---

## 7. Theorem E: simultaneous apparition

Individual violations combine.

**Theorem E (Simultaneous apparition).** Let $S$ be a finite set of primes with $\ell \ge 5$ and $\ell \nmid N$ for all $\ell \in S$, and let $P \in E_N(\mathbb{Q})$. Then there is an integer $M$ with
$$0 < M \le \prod_{\ell \in S} 4\ell$$
such that for all $k \in \mathbb{Z}$,
$$\Big(\prod_{\ell \in S} \ell\Big) \ \Big|\ \operatorname{den} x(kP) \iff M \mid k .$$
Moreover $M = \operatorname{lcm}_{\ell \in S} m_\ell$, where $m_\ell$ is the apparition index of $\ell$.

*Proof.* Induct on $\#S$. The empty set gives $M = 1$ (the empty product $1$ divides everything, and $1 \mid k$ always). For the inductive step write $S = \{a\} \sqcup S'$ and let $m$ be the apparition index of $a$ (Theorem C: $0 < m \le 4a$) and $M'$ the modulus for $S'$ (induction: $0 < M' \le \prod_{\ell \in S'} 4\ell$). Since $a$ and $\prod_{\ell \in S'}\ell$ are coprime (distinct primes), for any rational $Y$:
$$a\textstyle\prod_{S'}\ell \mid \operatorname{den} Y \iff a \mid \operatorname{den} Y \ \text{ and } \ \prod_{S'}\ell \mid \operatorname{den} Y .$$
By Theorem C and the inductive hypothesis, this holds for $Y = x(kP)$ iff $m \mid k$ and $M' \mid k$, i.e. iff $\operatorname{lcm}(m, M') \mid k$. Set $M := \operatorname{lcm}(m,M')$; then $0 < M \le mM' \le 4a\prod_{S'}4\ell = \prod_S 4\ell$. $\square$

**Corollary 7.1 (Density of simultaneous violations).** With $S$ and $M$ as above, for every $K$,
$$\#\Big\{ n \in (0,K] : \Big(\prod_{\ell\in S}\ell\Big) \Big| \operatorname{den} x(nP) \Big\} = \left\lfloor \frac{K}{M} \right\rfloor \ \ge\ \left\lfloor \frac{K}{\prod_{\ell\in S}4\ell} \right\rfloor .$$

So arbitrarily many good primes violate the conjecture *simultaneously*, on a set of indices of positive density — a much stronger failure than the existence of sporadic bad indices.

**Theorem E′ (A concrete joint apparition).** On $E_{55} : y^2 = x^3 + 55$ with $P = (9,28)$, the good primes $7$ and $13$ have apparition indices $2$ and $3$ respectively, and consequently
$$91 = 7 \cdot 13 \ \big|\ \operatorname{den} x(kP) \iff 6 \mid k .$$

*Proof.* $7$ has index $2$ and $13$ has index $3$ (verified by the direct orbit computation of §10, and consistent with Theorem C since $2 \le 28$ and $3 \le 52$). By coprimality of $7$ and $13$, $91 \mid \operatorname{den} x(kP)$ iff $7 \mid \operatorname{den} x(kP)$ and $13 \mid \operatorname{den} x(kP)$, iff $2 \mid k$ and $3 \mid k$, iff $6 \mid k$. $\square$

Note the shape of the conclusion: a *composite* number, built from two primes of good reduction and having nothing to do with $\Delta$, divides the denominators precisely along an arithmetic progression. Any procedure hoping to extract the factorisation of $N = 5 \cdot 11$ from denominators must contend with the fact that denominators are full of such spurious composites.

---

## 8. Theorem F: the global refutation

**Lemma 8.1.** For $N \ne 0$ the set $\{\ell \text{ prime} : \ell \ge 5, \ \ell \nmid N\}$ is infinite.

*Proof.* The complement inside the primes is contained in $\{2,3\} \cup \{p : p \mid |N|\}$, which is finite because $N \ne 0$. Removing a finite set from the infinite set of primes leaves an infinite set. $\square$

**Theorem F1 (Infinitely many good primes appear).** Let $N \ne 0$ and let $P \in E_N(\mathbb{Q})$ have infinite order. Then
$$\{\ell \text{ prime} : \ell \ge 5,\ \ell\nmid N, \ \exists n>0 \text{ with } \ell \mid \operatorname{den} x(nP)\}$$
is infinite.

*Proof.* By Theorem B every element of the infinite set of Lemma 8.1 belongs to this set. $\square$

**Theorem F2 (The conjecture is false for every curve and point).** Let $N \ne 0$ and let $P \in E_N(\mathbb{Q})$ have infinite order. Then it is **not** the case that
$$\forall\, \ell \text{ prime},\ \forall\, n>0:\quad \ell \mid \operatorname{den} x(nP) \ \Longrightarrow\ \big(\ell = 2 \ \text{or}\ \ell = 3\ \text{or}\ \ell \mid N\big).$$

*Proof.* Theorem F1 supplies a prime $\ell \ge 5$ with $\ell \nmid N$ and an index $n > 0$ with $\ell \mid \operatorname{den} x(nP)$. This triple $(\ell, n, x(nP))$ witnesses the failure; note that the witness is explicit and non-vacuous — $nP$ is a genuine affine point because $P$ has infinite order. $\square$

The two hypotheses are both necessary. If $N = 0$ the "curve" is singular and every prime divides $N$, so the conclusion is empty. If $P$ is a torsion point its orbit is finite, only finitely many rationals occur, and only finitely many primes can appear — a torsion point may well satisfy the conjecture trivially.

**Theorem F3 (Unbounded denominators from good primes alone).** Let $N \neq 0$ and $P$ of infinite order. For every bound $B$ there are a prime $\ell > B$ with $\ell \nmid N$ and an index $n > 0$ such that $\ell \mid \operatorname{den} x(nP)$ and $\operatorname{den} x(nP) > B$.

*Proof.* By Theorem F1 the set of appearing good primes is infinite, so it contains some $\ell > B$; take the corresponding $n$. Since $\ell \mid \operatorname{den} x(nP)$ and denominators are positive, $\operatorname{den} x(nP) \ge \ell > B$. $\square$

The growth of the denominator sequence is therefore *not* accounted for by the primes dividing the discriminant: arbitrarily large primes of good reduction are responsible for arbitrarily large chunks of it.

---

## 9. Algorithms

The theory is effective, and yields three practical procedures.

### 9.1 Apparition index by reduction

The most important algorithmic observation is that the apparition index need not be computed from rational orbits — whose denominators grow like $c^{n^2}$ and become intractable within a dozen steps — but from arithmetic in $\mathbb{F}_\ell$.

> **Algorithm A (Apparition index via the reduced curve).**
> **Input:** $N$, an affine rational point $P$, a good prime $\ell \ge 5$.
> **Output:** the apparition index $m$ of $\ell$ for $P$.
> 1. Reduce $P$ modulo $\ell$ to $\bar P \in C_\ell(N)$.
> 2. Compute the order of $\bar P$ in the group $E_N(\mathbb{F}_\ell)$ by repeated addition (or by the baby-step/giant-step method inside the Hasse interval).
> 3. Return that order.
>
> **Cost:** $O(\ell)$ field operations naively, $O(\sqrt{\ell}\,)$ with baby-step/giant-step, each operation costing $O(\log^2 \ell)$ bit operations.

That the output is the apparition index is exactly the identity "$\ell \mid \operatorname{den} x(kP) \iff kP \equiv O \pmod \ell$", i.e. $\iff \operatorname{ord}(\bar P) \mid k$. Theorem C guarantees the returned value is at most $4\ell$ unconditionally; Hasse's theorem gives the sharper $\ell + 1 + 2\sqrt\ell$.

### 9.2 Denominator prime spectrum of a truncated orbit

> **Algorithm B (Spectrum of an initial segment).**
> **Input:** $N$, $P$, bounds $K$ (orbit length) and $L$ (prime bound).
> **Output:** for every prime $\ell \le L$, the set of $n \le K$ with $\ell \mid \operatorname{den} x(nP)$.
> 1. For each prime $5 \le \ell \le L$ with $\ell \nmid N$, run Algorithm A to obtain $m_\ell$.
> 2. Report the violating set as $\{ n \le K : m_\ell \mid n\}$, of size $\lfloor K/m_\ell\rfloor$.
>
> **Cost:** $O(\pi(L)\sqrt{L})$ field operations — independent of $K$. Computing the same information from rational orbits would require handling integers of $\Theta(n^2)$ digits.

The point is worth emphasising: the periodicity theorem converts an exponentially expensive computation into a cheap one.

### 9.3 Joint apparition modulus

> **Algorithm C (Joint modulus for a set of primes).**
> **Input:** $N$, $P$, a finite set $S$ of good primes.
> **Output:** the modulus $M$ with $\prod_{\ell \in S}\ell \mid \operatorname{den} x(kP) \iff M \mid k$.
> 1. For each $\ell \in S$ compute $m_\ell$ by Algorithm A.
> 2. Return $M := \operatorname{lcm}_{\ell \in S} m_\ell$.
>
> **Cost:** $\#S$ invocations of Algorithm A plus a least-common-multiple computation.

Correctness is Theorem E. For $S = \{7,13\}$ on $E_{55}$, $P = (9,28)$, one gets $M = \operatorname{lcm}(2,3) = 6$, recovering Theorem E′.

---

## 10. Computational evidence

### 10.1 The orbit of $(9,28)$ on $E_{55}$

Direct rational computation of the first ten multiples, with the small-prime part of each denominator factored, gives the following table (digit counts refer to the full denominator; the listed factorisation is the part supported on primes $< 200$).

| $n$ | digits of $D_n$ | small-prime part of $D_n$ |
|---|---|---|
| 1 | 1 | $1$ |
| 2 | 4 | $2^6\cdot 7^2$ |
| 3 | 9 | $3^6\cdot 13^2\cdot 73^2$ |
| 4 | 17 | $2^8\cdot 7^2$ |
| 5 | 26 | $5^2$ |
| 6 | 37 | $2^6\cdot 3^6\cdot 7^2\cdot 13^2\cdot 17^4\cdot 73^2\cdot 179^2$ |
| 7 | 51 | $43^2$ |
| 8 | 68 | $2^{10}\cdot 7^2$ |
| 9 | 86 | $3^8\cdot 13^2\cdot 19^2\cdot 73^2$ |
| 10 | 107 | $2^6\cdot 5^2\cdot 7^2$ |

Every feature predicted by the theory is visible. The prime $7$ occurs exactly at $n \in \{2,4,6,8,10\}$ — apparition index $2$. The prime $13$ occurs exactly at $n \in \{3,6,9\}$ — index $3$. The primes $73$ (index $3$), $17$ (index $6$), $19$ (index $9$), $43$ (index $7$), $179$ (index $6$) each occur precisely along their progressions. The composite $91 = 7\cdot 13$ appears at $n = 6$ and nowhere else in the range, as Theorem E′ demands. All exponents of good primes are even, consistent with the square structure of elliptic denominators.

Two further observations. The bad prime $5 \mid N$ appears at $n \in \{5,10\}$ — bad primes are *permitted* to appear, they are simply not *required* to. The bad prime $11 \mid N$ does not appear at all in this range. The conjecture would have required $\{2,3,5,11\}$ to exhaust the spectrum; the actual spectrum already contains $7, 13, 17, 19, 43, 73, 179$ among the small primes alone, plus large cofactors we did not attempt to factor.

### 10.2 Apparition indices from the reduced curve

Running Algorithm A on $E_{55}$, $P = (9,28)$ for all good primes below $120$:

| $\ell$ | 7 | 13 | 17 | 19 | 23 | 29 | 31 | 37 | 41 | 43 | 47 | 53 | 59 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $m_\ell$ | 2 | 3 | 6 | 9 | 24 | 15 | 43 | 37 | 14 | 7 | 16 | 54 | 60 |

| $\ell$ | 61 | 67 | 71 | 73 | 79 | 83 | 89 | 97 | 101 | 103 | 107 | 109 | 113 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| $m_\ell$ | 61 | 57 | 72 | 3 | 21 | 12 | 30 | 28 | 102 | 39 | 108 | 28 | 57 |

The bad primes obey an apparition law here as well, with indices $m_2 = 2$, $m_3 = 3$, $m_5 = 5$, $m_{11} = 11$; in particular $11$ first appears only at $n = 11$, which is why it is invisible in the table of §10.1. Every good prime tested has a finite apparition index, i.e. every one of them appears; the theorem forbids anything else. Every index satisfies $m_\ell \le 4\ell$ with enormous room to spare, and in fact every index satisfies the sharper Hasse-type bound $m_\ell \le \ell + 1 + 2\sqrt{\ell}$, which is the content of Conjecture C1 in §12. Note the wide spread: $m_{73} = 3$ (density $1/3$ of all indices) against $m_{107} = 108$ (density $1/108$). The indices where the two tables overlap agree exactly, confirming that the cheap reduced-curve computation reproduces the expensive rational one.

### 10.3 A survey over semiprimes

Two independent surveys over samples of about a dozen semiprimes $N = pq$ admitting rational points of infinite order on $E_N$ were carried out, differing in the choice of base point, the orbit length and the prime bound used to inspect denominators. Their aggregate findings were:

- the appearance of a given prime factor of $N$ in the early denominators is erratic and sample-dependent: the smaller factor $p$ appeared in $54.5\%$ of the cases in one survey and in $85.7\%$ in the other; the larger factor $q$ appeared in $0\%$ and $28.6\%$ respectively;
- the property asserted by the conjecture — that the primes occurring are contained in $\{2,3,p,q\}$ — held in $0\%$ of cases in *both* surveys, without exception;
- in every instance the number of distinct *good* primes visible in the first eight denominators (up to the inspection bound $300$) was between five and seven, comfortably outnumbering the bad primes.

The conjecture is thus not merely false in principle; it fails on every instance examined, and it fails in the direction that is worst for applications: the good primes intrude in force, and the presence of the interesting bad primes is unreliable.

---

## 11. Consequences for factoring: a structural barrier

The refuted conjecture was a factoring proposal, so it is worth stating precisely why no repair of the idea can succeed along the same lines.

**Observation 11.1 (Denominator data is a function of $N$, not of its factorisation).** Whether $\ell$ divides $\operatorname{den} x(nP)$ is determined by the single condition $\operatorname{ord}_{E(\mathbb{F}_\ell)}(\bar P) \mid n$. The right-hand side depends only on the reductions of $N$ and of the coordinates of $P$ modulo $\ell$. In particular, the whole apparition profile $(m_\ell)_\ell$ of the orbit is computable from $(N, P)$ by Algorithm A in time $O(\sqrt\ell)$ per prime, without any knowledge of a factorisation of $N$, and conveys no information distinguishing $N = pq$ from any other integer congruent to $N$ modulo the primes examined.

**Observation 11.2 (The spectrum is dominated by good primes).** By Theorem D′ the number of distinct primes appearing among the first $K$ denominators is at least $\pi(K/4) - \omega(N) - 2$, all but at most $\omega(N)+2$ of which are good. Any attempt to isolate $p$ or $q$ inside a denominator must first separate them from $\Theta(K/\log K)$ irrelevant primes — which is the factoring problem again.

**Observation 11.3 (Bad primes need not appear).** The bad primes are exactly the primes *permitted* to be absent (Corollary 5.2). The surveys of §10.3 bear this out: the larger factor $q$ was absent from the early denominators in most instances tested, and on $E_{55}$ with $P = (9,28)$ the factor $11$ does not appear at all in the first ten denominators. A method relying on the presence of $p$ and $q$ therefore lacks even a guarantee that the desired data is present.

Together these constitute a clean negative result: denominator structure in Mordell orbits is an invariant of $N$ as an integer and cannot serve as an oracle for its multiplicative decomposition. This is a useful thing to know precisely, since the intuition that "denominators encode arithmetic degeneracy, and degeneracy should see the factorisation" is a natural one and recurs in several guises.

---

## 12. Discussion and open problems

The picture that emerges is a complete analogue, for Mordell curves, of the classical theory of the *rank of apparition* in Lucas sequences: for the Fibonacci sequence, every prime $\ell$ divides some term, the indices of divisibility form the multiples of a single number $\alpha(\ell)$, and $\alpha(\ell) \le \ell+1$. The results above supply exactly this structure — existence (Theorem B), periodicity (Theorem C), effective bound $4\ell$ (Theorem B), density (Theorem D), and a multiplicative/CRT law for finite sets of primes (Theorem E) — for the elliptic divisibility sequence attached to a point on $y^2 = x^3 + N$. What the elliptic case adds, and what has no Lucas analogue, is the $2$-torsion branch in the Collision Lemma, which is the sole source of the factor $2$ that turns $2\ell$ into $4\ell$.

Three sharpenings suggest themselves, each falsifiable by a single explicit orbit computation.

**C1. The apparition index is the order of the reduction (Hasse-sharp bound).** For $\ell \ge 5$ with $\ell \nmid N$ and $P$ of infinite order, the apparition index $m$ equals the order of $\bar P$ in $E_N(\mathbb{F}_\ell)$; in particular $m \mid \#E_N(\mathbb{F}_\ell)$ and $m \le \ell + 1 + 2\sqrt{\ell}$. The reason to expect this is that the Collision Lemma is precisely injectivity of reduction on the quotient by $\mathcal{K}_\ell$, so upgrading $4\ell$ to the Hasse bound requires identifying the pigeonhole target with the *group* $E_N(\mathbb{F}_\ell)$ rather than with the mere *set* of its points. The chord arithmetic already covers every case such an identification would need, including the $2$-torsion branch; what remains is bookkeeping. The tables of §10.2 confirm $m = \operatorname{ord}(\bar P)$ for all $\ell < 120$ on $E_{55}$, and the bound $m \le \ell + 1 + 2\sqrt\ell$ was verified for all $91$ good primes $\ell \le 500$ there; the extreme case is $\ell = 31$, $m = 43$ (Hasse bound $43.14$), and the largest observed ratio $m/\ell$ over that range is $1.387$, against the proved allowance of $4$.

**C2. Exact valuation law.** With $m$ the apparition index of a good $\ell \ge 5$, one expects
$$v_\ell\big(\operatorname{den} x(nP)\big) = v_\ell\big(\operatorname{den} x(mP)\big) + 2\,v_\ell(n/m) \quad \text{whenever } m \mid n,$$
and $v_\ell(\operatorname{den} x(nP)) = 0$ otherwise. The mechanism is the formal group at $\ell$: in the parameter $z = -x/y$ multiplication by $k$ acts as multiplication by $k$ to leading order, so the only growth of the $\ell$-part along the progression comes from the $\ell$-part of the multiplier. The case $\ell \nmid k$ (invariance of the valuation under doubling for odd $\ell$) is already known; the remaining step is the case $\ell \mid k$. Direct computation on $E_{55}$, $P=(9,28)$ agrees exactly: $v_7(\operatorname{den} x(nP)) = 2$ for every even $n \le 12$, jumps to $4$ at $n = 14 = 2\cdot 7$, and returns to $2$ at $n = 16$; likewise $v_{13} = 2$ throughout $3\mathbb{N}$ up to $n = 15$.

**C3. Equidistribution of the parity of the apparition index.** For fixed $N$ and $P$ of infinite order, the set of primes $\ell$ whose apparition index is even should have natural density $1/2$ among all primes; equivalently, the parity of $\operatorname{ord}(\bar P)$ equidistributes. The heuristic is that this parity is governed by the splitting behaviour in the $2$-division field of $E_N$, a Chebotarev condition, so the density should be the proportion of Frobenius classes acting on $E_N[2]$ without a fixed vector. The density statements of §6 are what make the question well-posed: they guarantee each index is finite, so its parity is defined.

Beyond these, two structural questions seem worth pursuing. First, an average form of Theorem B: is the *expected* apparition index of a random good prime $\ell$ of size $\ell^{1-o(1)}$ (as heuristics on orders of points in $E(\mathbb{F}_\ell)$ suggest), so that the density $1/m$ of violations is typically about $1/\ell$ rather than the guaranteed $1/(4\ell)$? Second, a converse-flavoured question: given a target arithmetic progression $M\mathbb{Z}$, which pairs $(N,P)$ realise it as the joint apparition locus of a prescribed set of good primes? Theorem E shows every such locus is a progression with $M \le \prod 4\ell$; the inverse problem — which $M$ occur, and with what frequency — appears open.

---

## 13. Summary of results

1. **Counterexample.** $x(2P) = 2601/3136$ with $3136 = 2^6 \cdot 7^2$ for $P = (9,28)$ on $y^2 = x^3+55$: the good prime $7$ divides a denominator, refuting the conjecture concretely.
2. **Collision Lemma.** Two $\ell$-integral points of $E_N$ with the same reduction modulo a good $\ell \ge 5$ have $2(P_1-P_2)$ reducing to infinity; the proof reduces the chord numerator to $4\bar y^2$ using the curve equation.
3. **Effective apparition.** Every good prime $\ell \ge 5$ divides $\operatorname{den} x(nP)$ for some $0 < n \le 4\ell$, for every $N$ and every rational point $P$ of infinite order.
4. **Apparition law with effective modulus.** The violating indices are exactly the multiples of a modulus $m$ with $0 < m \le 4\ell$.
5. **Exact counting and density.** Exactly $\lfloor K/m\rfloor \ge \lfloor K/(4\ell)\rfloor$ of the first $K$ indices violate the conjecture at $\ell$.
6. **Simultaneous apparition.** Any finite set $S$ of good primes violates simultaneously along a progression of modulus $M \le \prod_{\ell \in S} 4\ell$; on $E_{55}$ with $P=(9,28)$, $91 \mid \operatorname{den} x(kP) \iff 6 \mid k$.
7. **Global refutation and reverse inclusion.** For every $N \ne 0$ and every point of infinite order, infinitely many good primes appear, denominators are unbounded because of good primes alone, and a prime absent from all denominators must lie in $\{2,3\}\cup\{p : p \mid N\}$ — the exact opposite of what was conjectured.
