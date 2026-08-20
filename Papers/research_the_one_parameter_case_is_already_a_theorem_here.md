# The Two-Parameter $\pm$-Frame: Coefficients of Binary Cyclotomic Polynomials as Lattice Points in a Balance Box

**Author:** Aristotle
**Date:** 2026-08-20

---

## Abstract

We develop, from first principles, a complete and self-contained theory of the coefficients of the *$\pm$-frame* $\Phi_n \in \mathbb{Z}[X]$ — the $n$-th cyclotomic polynomial regarded as a signed coefficient frame — in the one- and two-parameter cases, and we isolate the precise mechanism that bounds those coefficients from below.

In the one-parameter case $n = p$ prime, every coefficient of $\Phi_p$ is $0$ or $1$; in particular every coefficient is $\ge -1$. In the two-parameter case $n = pq$ with $p \ne q$ prime, we prove the closed formula
$$\Phi_{pq}(X)\,(X^{pq}-1) = (X-1)\,G_{p,q}(X), \qquad G_{p,q}(X) = \Bigl(\sum_{i<q} X^{ip}\Bigr)\Bigl(\sum_{j<p} X^{jq}\Bigr),$$
which converts the coefficient problem into a question about **integer points of a two-dimensional region**: the coefficient of $X^n$ in $G_{p,q}$ equals the number of lattice points $(i,j)$ of the *balance box* $[0,q)\times[0,p)$ on the line $ip + jq = n$. The arithmetic core is a uniqueness statement — a coprime line meets the balance box at most once — whose proof is a divisibility step plus linear integer reasoning. From it we obtain Migotti's theorem ($\Phi_{pq}$ has all coefficients in $\{-1,0,1\}$), the exact sign pattern as the discrete derivative of the indicator function of the numerical semigroup $\langle p,q\rangle$, the balance law $\sum_k [X^k]\Phi_{pq} = 1$, sharpness of the lower bound $-1$ for *every* semiprime (the linear coefficient is always $-1$), Sylvester's symmetry and gap count $\tfrac{1}{2}(p-1)(q-1)$, and palindromicity of $\Phi_{pq}$. We also exhibit the exact boundary of the method: with the non-coprime steps $2$ and $4$, the line $2i+4j = 4$ meets the box $[0,4)\times[0,2)$ twice and the associated geometry acquires a coefficient $2$. Finally we explain, in the same geometric language, why three parameters are expected to destroy the bound: the ternary analogue replaces "a line inside a rectangle" by "a plane inside a three-dimensional box", where multiplicity one is no longer forced.

**Keywords:** cyclotomic polynomial, Migotti's theorem, numerical semigroup, Frobenius number, Sylvester's theorem, lattice points, coefficient bounds.

---

## 1. Introduction

### 1.1 The frame

For $n \ge 1$ let $\Phi_n \in \mathbb{Z}[X]$ denote the $n$-th cyclotomic polynomial, the monic polynomial whose roots are exactly the primitive $n$-th roots of unity. It satisfies the divisor factorisation
$$X^n - 1 = \prod_{d \mid n} \Phi_d(X). \tag{1.1}$$
We refer to $\Phi_n$, viewed as its sequence of coefficients, as the **$\pm$-frame of order $n$**, and we write $\Phi_n[k]$ for the coefficient of $X^k$. The governing question of this paper is:

> **Question.** How negative can $\Phi_n[k]$ be, and what structure controls it?

Numerically, the answer for small $n$ is: not negative at all beyond $-1$. Every coefficient of every $\Phi_n$ with $n < 105$ lies in $\{-1,0,1\}$, and it is a well-known historical fact that this observation was for a time conjectured to hold universally. It fails at $n = 105 = 3\cdot 5\cdot 7$. The purpose of this paper is not merely to confirm the bound in the cases where it holds, but to identify the *exact mechanism* responsible, in a form that explains simultaneously why the bound holds for one and two prime parameters and why it must be expected to fail for three.

### 1.2 The mechanism, in one sentence

The mechanism is dimensional. For two coprime steps $p, q$ the counting function
$$g_{p,q}(n) \;=\; \#\bigl\{(i,j) \in \mathbb{Z}^2 : 0 \le i < q,\ 0 \le j < p,\ ip + jq = n\bigr\}$$
takes only the values $0$ and $1$, because a line of coprime slope cannot meet a $q \times p$ box twice; and a closed formula expresses each frame coefficient as a *successive difference* of $g_{p,q}$, hence as a difference of two $\{0,1\}$-values.

### 1.3 Contributions

1. **The frame geometry and its closed formula** (§4): the identity $\Phi_{pq}(X)(X^{pq}-1) = (X-1)G_{p,q}(X)$, proved from the divisor factorisation (1.1) and a telescoping identity, with no appeal to Möbius inversion.
2. **The arithmetic core** (§3): the balance box meets each line in at most one lattice point, with an elementary proof, and the resulting $\{0,1\}$-valuedness of $G_{p,q}$'s coefficients.
3. **Migotti's theorem** (§5) in the sharp trichotomy form $\Phi_{pq}[k] \in \{-1,0,1\}$ for all $k$, together with the two one-sided bounds.
4. **The exact sign pattern** (§6): $\Phi_{pq}[n+1] = \mathbb{1}[n+1 \in \langle p,q\rangle] - \mathbb{1}[n \in \langle p,q\rangle]$ for $n+1 < pq$, exhibiting the frame as a discrete derivative of a numerical-semigroup indicator.
5. **Sharpness for every semiprime** (§7): $\Phi_{pq}[0] = 1$ and $\Phi_{pq}[1] = -1$; consequently $-1$ is the *least* value attained by the coefficient sequence, for every pair of distinct primes.
6. **Balance** (§8): $\sum_{k \le \deg \Phi_{pq}} \Phi_{pq}[k] = 1$.
7. **Sylvester symmetry, gap count, and palindromicity** (§9–§10): $g_{p,q}(n) + g_{p,q}(F - n) = 1$ for $0 \le n \le F := pq-p-q$; exactly $\tfrac12 (p-1)(q-1)$ of the exponents below $\deg \Phi_{pq}$ are gaps; and $\Phi_{pq}[k] = \Phi_{pq}[D-k]$ with $D = (p-1)(q-1)$.
8. **The coprimality boundary** (§11): an explicit non-coprime pair for which the counting function takes the value $2$.
9. **The ternary outlook** (§12–§13): why the argument does not survive the passage to three parameters, phrased as falsifiable conjectures.

---

## 2. Definitions

Throughout, $p$ and $q$ are positive integers, usually distinct primes, and all polynomials have integer coefficients.

**Definition 2.1 ($\pm$-frame).** For $n \ge 1$, the **$\pm$-frame of order $n$** is the polynomial $\Phi_n \in \mathbb{Z}[X]$, the $n$-th cyclotomic polynomial. We write $\Phi_n[k] := [X^k]\Phi_n$.

**Definition 2.2 (Frame geometry).** For $p, q \ge 0$, the **two-parameter frame geometry** is
$$G_{p,q}(X) \;:=\; \Bigl(\sum_{i=0}^{q-1} X^{ip}\Bigr)\Bigl(\sum_{j=0}^{p-1} X^{jq}\Bigr) \;\in\; \mathbb{Z}[X].$$

**Definition 2.3 (Balance box and its lattice points).** The **balance box** is the integer rectangle
$$B_{p,q} := \{(i,j) \in \mathbb{Z}_{\ge 0}^2 : i < q,\ j < p\},$$
and for $n \ge 0$ the set of its lattice points on the line $ip + jq = n$ is
$$R_{p,q}(n) := \{(i,j) \in B_{p,q} : ip + jq = n\}, \qquad g_{p,q}(n) := \# R_{p,q}(n).$$

**Definition 2.4 (Frame representability).** An integer $n \ge 0$ is **frame-representable** for $(p,q)$, written $n \in \langle p,q\rangle$, if there exist integers $i, j \ge 0$ (with no upper bound imposed) such that $ip + jq = n$. The set $\langle p,q \rangle$ is the **numerical semigroup** generated by $p$ and $q$.

**Definition 2.5 (Gaps).** The **gaps of the balance region** are
$$\Gamma_{p,q} := \{\, n : 0 \le n < (p-1)(q-1),\ R_{p,q}(n) = \varnothing \,\}.$$

**Definition 2.6 (Frobenius number).** For coprime $p,q \ge 2$, put $F := pq - p - q$.

We record the elementary identity, used repeatedly, that for $p, q \ge 2$
$$(p-1)(q-1) = (pq - p - q) + 1 = F + 1. \tag{2.1}$$
(Write $p = a+2$, $q = b+2$ and expand both sides: $ab+a+b+1$.) In particular $\deg \Phi_{pq} = (p-1)(q-1) = F+1 < pq$, since $\deg \Phi_{pq} = \varphi(pq) = (p-1)(q-1)$ for distinct primes.

---

## 3. The arithmetic core: lattice-point uniqueness in the balance box

Everything below rests on a single elementary statement.

> **Theorem 3.1 (Two-dimensional integer-point uniqueness).** Let $p, q$ be coprime with $q > 0$. Let $i, i' \in [0, q)$ and $j, j' \ge 0$ be integers with
> $$ip + jq = i'p + j'q.$$
> Then $i = i'$ and $j = j'$.

*Proof.* It suffices to prove $i = i'$; cancelling $ip$ then gives $jq = j'q$ and hence $j = j'$ since $q > 0$.

By symmetry assume $i \le i'$. From $ip + jq = i'p + j'q$ and $i \le i'$ we get $j' \le j$, and subtracting,
$$(i' - i)\,p \;=\; (j - j')\,q .$$
Thus $q \mid (i'-i)p$. Since $\gcd(p,q) = 1$, Euclid's lemma (in the coprime form: $q \mid ab$ and $\gcd(q,a)=1$ imply $q \mid b$) yields $q \mid (i' - i)$. But $0 \le i' - i < q$, since both $i,i' \in [0,q)$. A nonzero multiple of $q$ has absolute value at least $q$; hence $i' - i = 0$. $\square$

The hypothesis used is exactly: *coprimality of the two steps*, and *the width of the box in the $i$-direction being at most $q$*. Both are sharp (see §11).

> **Corollary 3.2 (At most one point per line).** For coprime $p,q$ with $q > 0$ and any $n \ge 0$,
> $$g_{p,q}(n) = \# R_{p,q}(n) \le 1 .$$

*Proof.* Two elements $(i,j), (i',j')$ of $R_{p,q}(n)$ satisfy $ip+jq = n = i'p+j'q$ with $i,i' < q$; Theorem 3.1 forces them equal. $\square$

The geometric picture is worth stating explicitly. The line $ip + jq = n$ in the real plane has slope $-p/q$; its integer points form a one-dimensional lattice with primitive step vector $(q, -p)$, whose horizontal displacement is exactly $q$. The balance box has horizontal extent $q$ — one unit too narrow to contain two consecutive integer points of the line. Coprimality is what guarantees that the primitive step is $(q,-p)$ and not a shorter vector $(q/d, -p/d)$.

---

## 4. From lattice points to polynomials

> **Proposition 4.1 (Coefficients of the frame geometry count lattice points).** For all $p,q,n \ge 0$,
> $$[X^n]\,G_{p,q} \;=\; g_{p,q}(n).$$

*Proof.* Expanding the product of the two finite sums,
$$G_{p,q}(X) = \sum_{i<q}\sum_{j<p} X^{ip} X^{jq} = \sum_{(i,j) \in B_{p,q}} X^{ip + jq},$$
and extracting the coefficient of $X^n$ counts precisely those $(i,j) \in B_{p,q}$ with $ip + jq = n$. $\square$

> **Corollary 4.2.** If $p,q$ are coprime and $q > 0$, then $[X^n]G_{p,q} \in \{0,1\}$ for all $n$.

*Proof.* Combine Proposition 4.1 with Corollary 3.2, noting the count is nonnegative. $\square$

We next relate $G_{p,q}$ to $X^{pq}-1$ and to the frame.

> **Lemma 4.3 (Telescoping identity).** For all $p, q \ge 0$,
> $$(X^p - 1)(X^q - 1)\, G_{p,q}(X) \;=\; \bigl(X^{pq} - 1\bigr)^2 .$$

*Proof.* Reindex each factor as a geometric series in a power of $X$:
$$\sum_{i<q} X^{ip} = \sum_{i<q} (X^p)^i, \qquad \sum_{j<p} X^{jq} = \sum_{j<p}(X^q)^j .$$
The finite geometric identity $\bigl(\sum_{i<m} Y^i\bigr)(Y - 1) = Y^m - 1$ with $Y = X^p$, $m = q$ gives
$$\Bigl(\sum_{i<q} X^{ip}\Bigr)(X^p - 1) = X^{pq} - 1,$$
and with $Y = X^q$, $m = p$ gives $\bigl(\sum_{j<p} X^{jq}\bigr)(X^q-1) = X^{qp}-1$. Multiplying the two identities and rearranging factors yields the claim. $\square$

> **Lemma 4.4 (Cyclotomic factorisation for a semiprime).** Let $p \ne q$ be primes. Then
> $$(X^p - 1)(X^q - 1)\,\Phi_{pq}(X) \;=\; (X-1)\bigl(X^{pq}-1\bigr).$$

*Proof.* The divisors of $pq$ are exactly $1, p, q, pq$: any divisor factors as $ab$ with $a \mid p$, $b \mid q$, and primality leaves the four listed possibilities, which are pairwise distinct because $p \ne q$ and $p,q \ge 2$. Hence (1.1) reads
$$X^{pq} - 1 = \Phi_1 \Phi_p \Phi_q \Phi_{pq} = (X-1)\,\Phi_p\,\Phi_q\,\Phi_{pq}.$$
For a prime $r$, $(X-1)\Phi_r = X^r - 1$. Multiplying the display by $(X-1)$ and grouping the two resulting copies of $(X-1)$ with $\Phi_p$ and $\Phi_q$ respectively,
$$(X-1)\bigl(X^{pq}-1\bigr) = (X-1)^2\,\Phi_p\,\Phi_q\,\Phi_{pq} = \bigl((X-1)\Phi_p\bigr)\bigl((X-1)\Phi_q\bigr)\Phi_{pq} = (X^p-1)(X^q-1)\Phi_{pq}. \qquad\square$$

> **Theorem 4.5 (Closed formula).** Let $p \ne q$ be primes. Then
> $$\Phi_{pq}(X)\cdot\bigl(X^{pq} - 1\bigr) \;=\; (X-1)\cdot G_{p,q}(X).$$

*Proof.* The ring $\mathbb{Z}[X]$ is an integral domain and $u := (X^p-1)(X^q-1) \ne 0$, so it suffices to verify the identity after multiplying by $u$. Using Lemma 4.4 and then Lemma 4.3,
$$u \cdot \Phi_{pq}(X^{pq}-1) = \bigl(u\,\Phi_{pq}\bigr)(X^{pq}-1) = (X-1)(X^{pq}-1)^2 = (X-1)\bigl(u\,G_{p,q}\bigr) = u\cdot (X-1)G_{p,q}.$$
Cancelling $u$ gives the result. $\square$

The closed formula is the bridge advertised in the introduction: on the right, multiplication by $X-1$ is the *discrete-derivative* operator on coefficient sequences; on the left, multiplication by $X^{pq}-1$ acts, in the coefficient range below $pq$, simply as negation.

> **Proposition 4.6 (Coefficient recursion).** Let $p \ne q$ be primes.
> 1. If $pq > 0$ then $\Phi_{pq}[0] = g_{p,q}(0)$.
> 2. If $n + 1 < pq$ then $\Phi_{pq}[n+1] = g_{p,q}(n+1) - g_{p,q}(n)$.

*Proof.* Take the coefficient of $X^{m}$ on both sides of Theorem 4.5. On the left, $[X^m]\bigl(\Phi_{pq}\cdot(X^{pq}-1)\bigr) = \Phi_{pq}[m - pq] - \Phi_{pq}[m]$, and for $m < pq$ the first term is absent, giving $-\Phi_{pq}[m]$. On the right, $[X^m]\bigl((X-1)G_{p,q}\bigr) = G_{p,q}[m-1] - G_{p,q}[m]$, interpreted as $-G_{p,q}[0]$ when $m = 0$. Equating and using Proposition 4.1 gives both statements. $\square$

---

## 5. The main coefficient theorems

### 5.1 One parameter

> **Theorem 5.1 (One-parameter case).** Let $p$ be prime. Then for every $k \ge 0$,
> $$\Phi_p[k] \in \{0,1\}; \qquad \text{in particular } \Phi_p[k] \ge -1 .$$

*Proof.* From $X^p - 1 = (X-1)\Phi_p$ we get $\Phi_p = 1 + X + \cdots + X^{p-1} = \sum_{i<p} X^i$, whose $k$-th coefficient is $1$ if $k < p$ and $0$ otherwise. $\square$

Thus in the one-parameter case there are no signs at all: the frame is a block of $+1$'s. Every phenomenon of interest is a two-parameter phenomenon.

### 5.2 Degree and top coefficient

> **Proposition 5.2.** For distinct primes $p, q$: $\deg \Phi_{pq} = (p-1)(q-1)$ and $\Phi_{pq}[(p-1)(q-1)] = 1$.

*Proof.* $\deg \Phi_n = \varphi(n)$, and $\varphi(pq) = \varphi(p)\varphi(q) = (p-1)(q-1)$ by multiplicativity at coprime arguments. The top coefficient is $1$ because $\Phi_n$ is monic. $\square$

### 5.3 Two parameters: Migotti's theorem

> **Theorem 5.3 (Migotti).** Let $p \ne q$ be primes. Then for every $k \ge 0$,
> $$\bigl|\Phi_{pq}[k]\bigr| \le 1, \qquad\text{equivalently}\qquad \Phi_{pq}[k] \in \{-1, 0, 1\}.$$
> In particular $\Phi_{pq}[k] \ge -1$ and $\Phi_{pq}[k] \le 1$ for all $k$.

*Proof.* Write $g := g_{p,q}$ and note $p,q \ge 2$ are coprime, so Corollary 3.2 gives $g(m) \in \{0,1\}$ for all $m$.

*Case $k < pq$.* If $k = 0$, Proposition 4.6(1) gives $\Phi_{pq}[0] = g(0) \in \{0,1\}$, so $|\Phi_{pq}[0]| \le 1$. If $k = n+1$, Proposition 4.6(2) gives $\Phi_{pq}[k] = g(n+1) - g(n)$, a difference of two elements of $\{0,1\}$, hence in $\{-1,0,1\}$.

*Case $k \ge pq$.* Since $p, q\ge 2$ we have $p + q \le pq$, so by (2.1) $\deg \Phi_{pq} = (p-1)(q-1) = pq - p - q + 1 \le pq - 1 < k$, and the coefficient vanishes. $\square$

The trichotomy form follows since an integer of absolute value $\le 1$ is $-1$, $0$, or $1$.

---

## 6. The exact sign pattern: the frame is a semigroup derivative

Theorem 5.3 is a bound. The next result is an identification: it says exactly *which* coefficient occurs where.

> **Lemma 6.1 (Box constraints are automatic below $pq$).** Let $n < pq$ with $p,q \ge 1$. Then $R_{p,q}(n) \ne \varnothing$ if and only if $n \in \langle p,q\rangle$.

*Proof.* ($\Rightarrow$) Immediate: a point of the box is in particular a nonnegative representation. ($\Leftarrow$) Suppose $ip + jq = n$ with $i,j\ge 0$. If $i \ge q$ then $n \ge qp$, contradicting $n < pq$; so $i < q$. Symmetrically, if $j \ge p$ then $n \ge pq$, contradiction; so $j < p$. Hence $(i,j) \in R_{p,q}(n)$. $\square$

> **Proposition 6.2 (Indicator form).** Let $p,q$ be coprime with $q > 0$, and $n < pq$. Then
> $$g_{p,q}(n) = \mathbb{1}\bigl[\, n \in \langle p,q\rangle \,\bigr].$$

*Proof.* If $n \in \langle p,q\rangle$ then $R_{p,q}(n)$ is nonempty by Lemma 6.1 and has at most one element by Corollary 3.2, so $g_{p,q}(n) = 1$. Otherwise $R_{p,q}(n) = \varnothing$ and $g_{p,q}(n) = 0$. $\square$

> **Theorem 6.3 (Exact sign pattern).** Let $p \ne q$ be primes and $n + 1 < pq$. Then
> $$\Phi_{pq}[n+1] \;=\; \mathbb{1}\bigl[\,n+1 \in \langle p,q\rangle\,\bigr] \;-\; \mathbb{1}\bigl[\,n \in \langle p,q\rangle\,\bigr].$$

*Proof.* Combine Proposition 4.6(2) with Proposition 6.2 applied at $n+1$ and at $n$ (both $< pq$). $\square$

**Interpretation.** Let $S = \langle p,q\rangle \cap [0, pq)$, the payable amounts below $pq$ in the coin problem with denominations $p$ and $q$. Theorem 6.3 says the frame is the *discrete derivative* of the indicator of $S$: $\Phi_{pq}$ has a $+1$ exactly at each left endpoint of a maximal run of $S$ (other than possibly at $0$, treated by Proposition 4.6(1)), a $-1$ exactly one past each right endpoint, and $0$ elsewhere. The frame is an edge detector for the numerical semigroup.

**Worked example ($p=3, q=5$).** $S \cap [0,15) = \{0,3,5,6,8,9,10,11,12,13,14\}$. The indicator is
$$1,0,0,1,0,1,1,0,1,1,1,1,1,1,1 \quad (n = 0,\dots,14),$$
whose successive differences $\mathbb{1}[k \in S] - \mathbb{1}[k-1 \in S]$ for $k = 1,2,\dots$ are $-1, 0, +1, -1, +1, 0, -1, +1, 0, \dots$; prefixing the value $\Phi_{pq}[0]=1$ gives
$$\Phi_{15} = 1 - X + X^3 - X^4 + X^5 - X^7 + X^8 ,$$
in agreement with direct computation. Note $\Phi_{15}[7] = -1$: the exponent $7$ is the Frobenius number of $\langle 3,5\rangle$, and $6 \in \langle 3,5\rangle$ while $7 \notin \langle 3,5\rangle$.

> **Corollary 6.4 (Sharpness at $15$).** $\Phi_{15}[7] = -1$.

---

## 7. Sharpness for every semiprime

> **Lemma 7.1.** For $p, q \ge 1$: $R_{p,q}(0) = \{(0,0)\}$. For $p,q \ge 2$: $R_{p,q}(1) = \varnothing$.

*Proof.* If $ip + jq = 0$ with $i,j \ge 0$ and $p,q \ge 1$ then $i = j = 0$; conversely $(0,0)$ lies in the box. If $ip+jq = 1$ with $p,q\ge 2$ then $i = j = 0$ (any nonzero term is $\ge 2$), giving $0 = 1$, absurd. $\square$

> **Theorem 7.2 (Constant and linear coefficients).** Let $p \ne q$ be primes. Then
> $$\Phi_{pq}[0] = 1 \qquad\text{and}\qquad \Phi_{pq}[1] = -1 .$$

*Proof.* By Proposition 4.6(1) and Lemma 7.1, $\Phi_{pq}[0] = g_{p,q}(0) = 1$. Since $p,q \ge 2$ we have $1 < pq$, so Proposition 4.6(2) with $n = 0$ gives $\Phi_{pq}[1] = g_{p,q}(1) - g_{p,q}(0) = 0 - 1 = -1$. $\square$

> **Theorem 7.3 (The bound $-1$ is exactly attained, for every semiprime).** Let $p \ne q$ be primes. Then $-1$ is the least element of the set of coefficient values
> $$\mathcal{C}_{pq} := \{\, c \in \mathbb{Z} : c = \Phi_{pq}[k] \text{ for some } k \ge 0 \,\}.$$

*Proof.* $-1 \in \mathcal{C}_{pq}$ by Theorem 7.2 (witness $k=1$), and every element of $\mathcal{C}_{pq}$ is $\ge -1$ by Theorem 5.3. $\square$

This is a strengthening of the mere bound: not only does no coefficient dip below $-1$, but the value $-1$ *always occurs*, for structurally trivial reasons (the amount $1$ is never payable with coins of size $\ge 2$, while $0$ always is).

---

## 8. Balance

> **Theorem 8.1 (Balance law).** Let $p \ne q$ be primes and $D := \deg \Phi_{pq}$. Then
> $$\sum_{k=0}^{D} \Phi_{pq}[k] \;=\; 1 .$$
> Consequently, since all coefficients lie in $\{-1,0,1\}$, the number of $+1$'s exceeds the number of $-1$'s by exactly one.

*Proof.* The sum of the coefficients is $\Phi_{pq}(1)$. It is classical that $\Phi_n(1) = r$ if $n = r^k$ is a prime power ($k \ge 1$) and $\Phi_n(1) = 1$ otherwise. Here $pq$ is not a prime power: if $pq = r^k$ for a prime $r$, then $p \mid r^k$ forces $p = r$ and likewise $q = r$, contradicting $p \ne q$. Hence $\Phi_{pq}(1) = 1$. $\square$

Combining with Theorem 5.3 and Theorem 6.3: the frame consists of alternating $+1$'s and $-1$'s (separated by runs of zeros), beginning with the $+1$ at $k=0$ and ending with the $+1$ at $k=D$, so that the signs alternate strictly and the surplus is exactly one. The alternation is forced by the derivative interpretation: entries and exits of the semigroup necessarily interleave.

---

## 9. Sylvester symmetry and the gap count

Let $p,q \ge 2$ be coprime and $F = pq-p-q$ the Frobenius number.

> **Theorem 9.1 (Sylvester's reflection).** For $0 \le n \le F$:
> $$n \in \langle p,q\rangle \iff (F - n) \notin \langle p,q\rangle .$$

*Proof sketch.* *Not both.* If $n = ip + jq$ and $F - n = i'p + j'q$ with all parts $\ge 0$, then adding gives $F = (i+i')p + (j+j')q$, i.e. $pq - p - q$ representable, so $pq = (i+i'+1)p + (j+j'+1)q$ with both multipliers $\ge 1$. Reducing mod $p$: $p \mid (j+j'+1)q$, and $\gcd(p,q)=1$ gives $p \mid j+j'+1$, so $j+j'+1 \ge p$; symmetrically $i+i'+1 \ge q$. Then $pq = (i+i'+1)p + (j+j'+1)q \ge qp + pq = 2pq$, a contradiction as $pq>0$.

*At least one.* Suppose $n \notin \langle p,q\rangle$. Since $\gcd(p,q)=1$ there is a unique $j_0 \in [0,p)$ with $j_0 q \equiv n \pmod p$. Non-representability of $n$ forces $j_0 q > n$, i.e. $n = j_0 q - mp$ for some $m \ge 1$. Then
$$F - n = pq - p - q - j_0q + mp = (m-1)p + (p - 1 - j_0)q,$$
and both coefficients $m - 1 \ge 0$ and $p-1-j_0 \ge 0$ are nonnegative, so $F - n \in \langle p,q\rangle$. $\square$

> **Corollary 9.2 (Reflected balance of the frame geometry).** For $0 \le n \le F$,
> $$g_{p,q}(n) + g_{p,q}(F-n) = 1 .$$

*Proof.* Both $n$ and $F-n$ are $< pq$, so Proposition 6.2 turns the statement into Theorem 9.1. $\square$

> **Theorem 9.3 (Sylvester's gap count, frame form).** Let $p,q \ge 2$ be coprime and $D := (p-1)(q-1)$. Then exactly half of the exponents $0,1,\dots,D-1$ are gaps:
> $$2\,\bigl|\Gamma_{p,q}\bigr| \;=\; (p-1)(q-1).$$

*Proof.* By (2.1), $D = F + 1$, so the exponent range $[0, D)$ is exactly $[0, F]$, which is closed under the involution $n \mapsto F - n$. By Corollary 9.2 that involution exchanges gaps ($g = 0$) with non-gaps ($g = 1$). An involution of a finite set exchanging a subset with its complement is a bijection between the two, so the gaps number exactly half of $D$. $\square$

---

## 10. Palindromicity

> **Theorem 10.1 (Self-reciprocity).** Let $p \ne q$ be primes and $D = (p-1)(q-1) = \deg \Phi_{pq}$. Then for all $0 \le k \le D$,
> $$\Phi_{pq}[k] \;=\; \Phi_{pq}[D-k].$$

*Proof.* Write $F = D - 1$ (equation (2.1)).

*Boundary.* For $k = 0$: $\Phi_{pq}[0] = 1$ by Theorem 7.2 and $\Phi_{pq}[D] = 1$ since $\Phi_{pq}$ is monic of degree $D$; likewise for $k = D$.

*Interior.* Let $k = m+1$ with $1 \le k < D$, so $m + 1 \le F$. Both $k$ and $D - k$ are positive and $< pq$, so Proposition 4.6(2) applies to both:
$$\Phi_{pq}[k] = g(m+1) - g(m), \qquad \Phi_{pq}[D-k] = g(F-m) - g(F-m-1),$$
using $D - k = (F - m - 1) + 1$. Corollary 9.2 gives $g(m) + g(F-m) = 1$ and $g(m+1) + g(F-m-1) = 1$. Subtracting the two relations,
$$g(m+1) - g(m) = g(F - m) - g(F-m-1),$$
which is the assertion. $\square$

Thus the frame of a semiprime order is a palindrome; for instance the coefficient vector of $\Phi_{15}$ is $(1,-1,0,1,-1,1,0,-1,1)$.

---

## 11. The exact boundary of the method: coprimality

The whole edifice rests on Theorem 3.1, whose only hypothesis is coprimality of the two steps. It is worth confirming that this hypothesis is not an artefact.

> **Proposition 11.1 (Failure without coprimality).** For the steps $p = 2$, $q = 4$ (so $\gcd = 2$), the line $2i + 4j = 4$ contains **two** lattice points of the box $[0,4) \times [0,2)$, namely $(i,j) = (2,0)$ and $(i,j) = (0,1)$. Consequently
> $$g_{2,4}(4) = 2, \qquad [X^4]\,G_{2,4} = 2 .$$

*Proof.* Direct enumeration of the eight points of $[0,4)\times[0,2)$; then Proposition 4.1. $\square$

Since the entire coefficient bound was obtained from "$g \in \{0,1\}$", and $g$ here takes the value $2$, the difference-of-indicators argument genuinely collapses: coprimality is the exact frontier of the mechanism, not a technical convenience. (Of course $\Phi_8 = X^4+1$ is perfectly well behaved; the point is that the *geometry* of non-coprime steps ceases to control it, because $2 \cdot 4$ is a prime power and no longer a semiprime with distinct primes.)

---

## 12. Algorithms

The theory yields three natural algorithms, each of which we state with its complexity. Let $p<q$ be distinct primes and $D = (p-1)(q-1)$.

**Algorithm A (Frame coefficients by semigroup sieve).** Compute the indicator of $\langle p,q\rangle$ on $[0, pq)$ by a linear sieve, then take successive differences. Cost: $O(pq)$ time and space, versus $O(D^2) = O(p^2q^2)$ for naive polynomial division and $O(pq \log pq)$ for divisor-based recursive computation. The output is *exact*: no coefficient growth, no big-integer arithmetic — every intermediate value lies in $\{-1,0,1\}$.

*Correctness* is Theorem 6.3 together with Proposition 4.6(1).

**Algorithm B (Direct coefficient query in $O(1)$ arithmetic operations).** To answer "what is $\Phi_{pq}[k]$?" without computing the whole polynomial, decide membership $k \in \langle p,q\rangle$ and $k-1 \in \langle p,q\rangle$. Membership below $pq$ can be tested in $O(1)$: $n \in \langle p,q\rangle$ iff, with $j_0 \in [0,p)$ the unique residue with $j_0 q \equiv n \pmod p$, one has $j_0 q \le n$. (This is the standard Apéry-set test; $j_0$ is computed with one modular inverse.) Then apply Theorem 6.3.

**Algorithm C (Lattice-point certificate).** To *certify* a claimed coefficient value, enumerate $R_{p,q}(k)$ and $R_{p,q}(k-1)$ by looping $i$ over $[0,q)$ and testing whether $(k - ip)$ is a nonnegative multiple of $q$ below $pq$. Cost $O(q)$; the output is a human-checkable witness pair (or a proof of emptiness), and the coefficient equals $|R_{p,q}(k)| - |R_{p,q}(k-1)|$.

---

## 13. Discussion and future directions

### 13.1 What the geometry explains

The value of the closed formula is that it makes the coefficient bound *structural* rather than computational. Three separate classical facts — Migotti's $\{-1,0,1\}$ theorem, Sylvester's gap count, and the palindromicity of binary cyclotomic polynomials — are, in this presentation, three readings of a single statement about a rectangle:

* the rectangle is too thin for a coprime line to cross twice (Migotti);
* the rectangle is symmetric under the point reflection $n \mapsto F - n$, which exchanges hit lines with missed lines (Sylvester);
* that same reflection, transported through the discrete derivative, reverses the coefficient sequence (palindromicity).

### 13.2 Why three parameters must be different

For three distinct primes $p,q,r$, the natural analogue of the frame geometry is a triple product of truncated geometric series, whose $n$-th coefficient counts lattice points of a *three-dimensional* box on the *plane* $ip + jq + kr = n$. The obstruction that gave uniqueness in two dimensions — a one-dimensional solution lattice with a step too wide for the box — has no analogue: the solution set of $ip+jq+kr = n$ is a two-dimensional lattice, and a two-dimensional lattice inside a three-dimensional box generically contains many points. The excess multiplicity is precisely what a coefficient of $\Phi_{pqr}$ records; this is why $105 = 3\cdot5\cdot7$ is where the classical pattern first breaks, with $\Phi_{105}[7] = -2$.

### 13.3 Future directions

**Conjecture 1 (Three parameters break the bound, quantitatively).** For every integer $M \ge 1$ there exist three distinct primes $p<q<r$ and an exponent $k$ with $\Phi_{pqr}[k] \le -M$.

*Key insight.* The two-parameter closed formula $\Phi_{pq}(X^{pq}-1) = (X-1)G_{p,q}$ works because the balance box $[0,q)\times[0,p)$ meets every line $ip+jq = n$ at most once. In three parameters the analogous region is a three-dimensional box, the multiplicity of lattice points on a plane $ip+jq+kr = n$ is no longer bounded by one, and the excess multiplicity is exactly what the coefficient records.

*Why now.* The two-parameter case is now completely settled, including the exact mechanism responsible for the bound and a proved example showing the mechanism failing as soon as the uniqueness hypothesis is dropped. The remaining work is to build the ternary analogue of the frame geometry and to compute one multiplicity-two plane.

**Conjecture 2 (Gap-count controls the number of zero coefficients).** For distinct primes $p \ne q$, the number of exponents $k \in [0, (p-1)(q-1)]$ with $\Phi_{pq}[k] = 0$ equals $(p-1)(q-1) + 1 - 2s$, where $s$ is the number of $n \le pq - p - q$ such that $n$ lies in the numerical semigroup $\langle p,q\rangle$ while $n-1$ does not.

*Key insight.* The closed formula turns every coefficient into a discrete derivative of the semigroup indicator, so the nonzero coefficients count exactly the boundary points (entries and exits) of the semigroup inside $[0,pq)$, and the Sylvester symmetry pairs entries with exits.

*Why now.* The derivative description of each coefficient and the exact gap count are both in hand; what is missing is the combinatorial count of *blocks* rather than of points.

**Conjecture 3 (Carlitz count of nonzero coefficients).** For distinct odd primes $p \ne q$, let $\rho, \sigma$ be the unique integers with $1 \le \rho \le q-1$, $1 \le \sigma \le p-1$ and $\rho p + \sigma q = pq + 1$. Then the number of $k \le (p-1)(q-1)$ with $\Phi_{pq}[k] \ne 0$ equals $2\rho\sigma - 1$.

*Key insight.* Each coefficient is a discrete derivative of the semigroup indicator, so the nonzero coefficients are the boundary steps of $\langle p,q\rangle$ inside $[0,pq)$, and those steps are organised into a $\rho \times \sigma$ grid by the unique solution of $\rho p + \sigma q = pq+1$.

**Further directions.** (i) Effective versions: given $M$, produce explicit $p<q<r$ realising a coefficient $\le -M$, with bounds on $r$ in terms of $M$. (ii) Weighted balance boxes: replace $\{0,1\}$-multiplicity by multiplicity functions arising from inclusion–exclusion over more than three primes, and identify which box geometries still force bounded multiplicities. (iii) Algorithmic consequences: exploit the $O(pq)$ sieve of Algorithm A inside implementations of arithmetic in $\mathbb{Z}[X]/(\Phi_n)$, where guaranteed $\{-1,0,1\}$ coefficients bound expansion factors in ring multiplication.

---

## 14. Summary of results

| Result | Statement |
|---|---|
| Lattice-point uniqueness | For coprime $p,q$, the line $ip+jq=n$ meets $[0,q)\times[0,p)$ at most once |
| Frame geometry coefficients | $[X^n]G_{p,q} = \#\{(i,j) \in [0,q)\times[0,p) : ip+jq=n\} \in \{0,1\}$ when $\gcd(p,q)=1$ |
| Closed formula | $\Phi_{pq}(X)(X^{pq}-1) = (X-1)G_{p,q}(X)$ for distinct primes $p,q$ |
| One-parameter theorem | $\Phi_p[k] \in \{0,1\}$ for $p$ prime |
| Migotti's theorem | $\Phi_{pq}[k] \in \{-1,0,1\}$ for distinct primes $p,q$ |
| Exact sign pattern | $\Phi_{pq}[n+1] = \mathbb{1}[n+1\in\langle p,q\rangle] - \mathbb{1}[n \in \langle p,q\rangle]$, $n+1<pq$ |
| Sharpness | $\Phi_{pq}[0]=1$, $\Phi_{pq}[1]=-1$; $-1$ is the least coefficient value; e.g. $\Phi_{15}[7]=-1$ |
| Balance | $\sum_k \Phi_{pq}[k] = 1$ |
| Sylvester symmetry | $g_{p,q}(n) + g_{p,q}(F-n) = 1$ for $0 \le n \le F = pq-p-q$ |
| Gap count | Exactly $\tfrac12(p-1)(q-1)$ of the exponents in $[0,(p-1)(q-1))$ are gaps |
| Palindromicity | $\Phi_{pq}[k] = \Phi_{pq}[D-k]$, $D=(p-1)(q-1)$ |
| Coprimality boundary | $g_{2,4}(4) = 2$: without coprimality the multiplicity bound fails |
