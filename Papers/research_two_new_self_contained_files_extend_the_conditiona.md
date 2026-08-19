# Gaussian Binomial Coefficients over an Arbitrary Base, Subgroup Counts of Finite Groups, and the Intermediate Fields of a Hilbert Class Field

**Author:** Aristotle
**Date:** 2026-08-19

---

## Abstract

Let $K$ be a number field and $H$ an unramified abelian extension whose Galois group is identified with the ideal class group $\mathrm{Cl}(K)$ — the Hilbert class field situation. By the Galois correspondence, the intermediate fields of $H/K$ are in inclusion-reversing bijection with the subgroups of $\mathrm{Cl}(K)$, so the arithmetic question *how many intermediate fields?* is the group-theoretic question *how many subgroups?*. We develop the two halves of the answer.

On the arithmetic side we prove, entirely within the integers and for **every** base $q \ge 2$ (not merely for prime powers realised by a finite field), that the Gaussian binomial coefficient
$$\binom{n}{k}_{\!q} \;=\; \frac{\prod_{i<k}\bigl(q^{n}-q^{i}\bigr)}{\prod_{i<k}\bigl(q^{k}-q^{i}\bigr)}$$
is given by an exact division, satisfies the $q$-Pascal recursion $\binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{k+1}\binom{n}{k+1}_q$ and its dual $\binom{n+1}{k+1}_q = q^{n-k}\binom{n}{k}_q + \binom{n}{k+1}_q$, is symmetric, $\binom{n}{k}_q = \binom{n}{n-k}_q$ for $k \le n$, is strictly positive in that range, and obeys the $q$-factorial identity $[k]_q!\,[n-k]_q!\,\binom{n}{k}_q = [n]_q!$ with $[m]_q! = \prod_{j<m}(q^{j+1}-1)$. Summing rows gives the Galois numbers $G_q(n) = \sum_{k \le n}\binom{n}{k}_q$, for which we prove the three-term recursion
$$G_q(n+2) \;=\; 2\,G_q(n+1) \;+\; \bigl(q^{n+1}-1\bigr)G_q(n),$$
together with $G_q(0)=1$, $G_q(1)=2$, $G_q(2)=q+3$; for $q=2$ this generates $1,2,5,16,67,374$ and for $q=3$ it gives $G_3(4)=212$.

On the group-theoretic side we prove that the subgroup lattice of a direct product of two finite groups of coprime orders is the product of the two lattices — no commutativity required — whence $\#\mathrm{Sub}(G\times H) = \#\mathrm{Sub}(G)\cdot\#\mathrm{Sub}(H)$, and this extends to any finite pairwise-coprime family; that a finite cyclic group of order $n$ has exactly $d(n)$ subgroups, hence $r+1$ when the order is $p^{r}$; and that a group of order $p^{2}$ and exponent $p$ has exactly $p+1$ subgroups of order $p$ and $p+3$ in total.

Combining the two halves: a Hilbert class field with cyclic class group of order $n$ has $d(n)$ intermediate fields; with elementary abelian class group of rank $r$ and exponent $p$ it has $G_p(r)$ of them, exactly $\binom{r}{k}_p$ of degree $p^{k}$ over $K$; and with class group $(\mathbb{Z}/p)^r \times (\mathbb{Z}/q)^s$, $p \ne q$, it has $G_p(r)G_q(s)$. In particular the number of intermediate fields is **not** a function of the class number: at $h_K = 4$ it is $3$ or $5$, at $h_K = 12$ it is $6$ or $10$, and at $h_K = p^2$ it is $3$ or $p+3$.

**Keywords:** Gaussian binomial coefficient, $q$-Pascal recursion, Galois numbers, subgroup lattice, class group, Hilbert class field, elementary abelian group, divisor function.

---

## 1. Introduction

### 1.1 The counting problem

Let $K$ be an algebraic number field with ring of integers $\mathcal{O}_K$ and ideal class group $\mathrm{Cl}(K)$, a finite abelian group of order $h_K$, the class number. Class field theory attaches to $K$ its Hilbert class field $H$: the maximal unramified abelian extension of $K$, with the Artin map furnishing a canonical isomorphism
$$\mathrm{Gal}(H/K) \;\xrightarrow{\ \sim\ }\; \mathrm{Cl}(K).$$

We work throughout with the abstract shape of this situation, which we call a **class field datum**: a finite Galois extension $H/K$ together with a group isomorphism $e : \mathrm{Gal}(H/K) \to \mathrm{Cl}(K)$. Everything below is a consequence of that datum and requires no further arithmetic input.

The fundamental theorem of Galois theory gives an inclusion-reversing bijection
$$\{\,\text{intermediate fields } K \subseteq F \subseteq H\,\} \;\longleftrightarrow\; \{\,\text{subgroups of } \mathrm{Gal}(H/K)\,\}, \qquad F \mapsto \mathrm{Gal}(H/F),$$
under which $[F:K] = [\mathrm{Gal}(H/K) : \mathrm{Gal}(H/F)]$. Composing with $e$:

> **Principle.** A class field datum for $K$ has exactly $\#\mathrm{Sub}(\mathrm{Cl}(K))$ intermediate fields, and the degree over $K$ of the field corresponding to a subgroup $A \le \mathrm{Cl}(K)$ is the index $[\mathrm{Cl}(K):A]$.

Everything therefore reduces to counting subgroups of a finite abelian group, refined by index. The purpose of this paper is to carry out that count, and to develop from scratch the $q$-arithmetic it requires.

### 1.2 Why the class number is insufficient

Two abelian groups of the same order can have wildly different subgroup lattices. The smallest instance is order $4$: the cyclic group $\mathbb{Z}/4$ has $3$ subgroups, the Klein four group $(\mathbb{Z}/2)^2$ has $5$. Hence two number fields of class number $4$ may have Hilbert class fields with $3$ and $5$ intermediate fields respectively. At order $p^2$ the gap is $3$ versus $p+3$, unbounded in $p$. At order $12$ it is $6$ versus $10$. These are the falsifiable predictions that motivated the present development, and all are established below as instances of general theorems.

### 1.3 What must be proved about $q$-binomials

For an elementary abelian class group $(\mathbb{Z}/p)^r$, subgroups are $\mathbb{F}_p$-subspaces, and their number in each dimension is the Gaussian binomial coefficient. The classical derivation of the formula is geometric — count linearly independent tuples and fibre them over their spans — and it therefore yields the classical identities only for bases $q$ that are the cardinality of an actual finite field. Two things are unsatisfactory about resting on that. First, the identities are needed at bases where no such field exists (e.g. $q = 6$), because Gaussian binomials occur throughout $q$-series combinatorics, partition theory and quantum algebra with $q$ a formal or arbitrary parameter. Second, the geometric proof does not, by itself, prove that the defining quotient is an exact division of integers; that fact is imported from the counting interpretation, which is unavailable off prime powers.

Section 2 therefore builds the theory arithmetically: we define a second function by the recursion, prove a factorial identity for it over $\mathbb{Z}$, and then show that the defining quotient is exact and equals it. Section 3 does the group theory. Section 4 assembles the class field consequences. Sections 5–7 give algorithms, applications and open directions.

### 1.4 Conventions

$q, n, k, r, s$ denote non-negative integers; $p$ denotes a prime. $d(n)$ is the number of positive divisors of $n$. $\#\mathrm{Sub}(G)$ is the number of subgroups of a finite group $G$. Empty products are $1$. All groups are finite unless stated otherwise.

---

## 2. Gaussian binomial coefficients over an arbitrary base

### 2.1 Definitions

**Definition 2.1 (Gaussian binomial coefficient).** For integers $q, n, k \ge 0$,
$$\binom{n}{k}_{\!q} \;=\; \left\lfloor \frac{\prod_{i=0}^{k-1}\bigl(q^{n}-q^{i}\bigr)}{\prod_{i=0}^{k-1}\bigl(q^{k}-q^{i}\bigr)} \right\rfloor,$$
the quotient of two non-negative integers, truncated. (A principal result below is that no truncation actually occurs when $q \ge 2$.)

**Definition 2.2 (recursive $q$-binomial).** Define $B_q(n,k)$ by
$$B_q(0,0) = 1, \qquad B_q(0,k+1)=0, \qquad B_q(n+1,0)=1,$$
$$B_q(n+1,k+1) \;=\; B_q(n,k) \;+\; q^{\,k+1}\,B_q(n,k+1).$$

**Definition 2.3 ($q$-factorial).** $[m]_q! \;=\; \prod_{j=0}^{m-1}\bigl(q^{\,j+1}-1\bigr) \;=\; (q-1)(q^2-1)\cdots(q^m-1) \in \mathbb{Z}$, with $[0]_q! = 1$.

The $q$-factorial is computed in $\mathbb{Z}$ rather than $\mathbb{N}$; this is not pedantry but the technical heart of the arithmetic approach, since all the algebra below involves differences and would be corrupted by truncated natural subtraction.

**Definition 2.4 (Galois number and $q$-weighted row sum).**
$$G_q(n) = \sum_{k=0}^{n}\binom{n}{k}_{\!q}, \qquad S_q(n) = \sum_{k=0}^{n} q^{k}\binom{n}{k}_{\!q}.$$

### 2.2 Elementary properties of the recursive $q$-binomial

**Lemma 2.5.** $B_q(n,0) = 1$ for all $n$; $B_q(0,k)=0$ for $k \ge 1$; $B_q(n,k) = 0$ whenever $n < k$; and $B_q(n,n) = 1$.

*Proof.* The first two are the defining clauses. Vanishing above the diagonal is an induction on $n$: for $n+1 < k+1$ both terms $B_q(n,k)$ and $B_q(n,k+1)$ vanish by the inductive hypothesis. Then $B_q(n+1,n+1) = B_q(n,n) + q^{n+1}B_q(n,n+1) = B_q(n,n)$, and induction gives $1$. $\square$

**Lemma 2.6.** If $q \ge 2$ then $[m]_q! > 0$ for all $m$.

*Proof.* Each factor $q^{j+1}-1$ is positive because $q^{j+1} \ge q \ge 2$. $\square$

### 2.3 The $q$-factorial identity

This is the engine of the section.

**Theorem 2.7 ($q$-factorial identity).** For all $q$ and all $k \le n$,
$$[k]_q! \cdot [n-k]_q! \cdot B_q(n,k) \;=\; [n]_q! \qquad \text{in } \mathbb{Z}.$$

*Proof sketch.* Induction on $n$. For $n=0$ only $k=0$ occurs and both sides are $1$. For the step, let $k+1 \le n+1$ and put $m = n-k \ge 0$.

If $k = n$, then $B_q(n+1,n+1) = B_q(n,n) + q^{n+1}B_q(n,n+1) = 1$ by Lemma 2.5, while $[n+1]_q!\,[0]_q! = [n+1]_q!$, so the identity holds.

If $k < n$, apply the recursion:
$$[k+1]_q!\,[m]_q!\,B_q(n+1,k+1) \;=\; [k+1]_q!\,[m]_q!\,B_q(n,k) \;+\; q^{k+1}\,[k+1]_q!\,[m]_q!\,B_q(n,k+1).$$
Write $[k+1]_q! = [k]_q!\,(q^{k+1}-1)$ in the first summand and $[m]_q! = [m-1]_q!\,(q^{m}-1)$ in the second (legitimate since $m \ge 1$). The inductive hypothesis applied at $(n,k)$ and at $(n,k+1)$ — note $n-(k+1) = m-1$ — converts the two summands into
$$\bigl(q^{k+1}-1\bigr)[n]_q! \;+\; q^{k+1}\bigl(q^{m}-1\bigr)[n]_q!.$$
The bracketed coefficients combine by the single algebraic identity
$$\bigl(q^{k+1}-1\bigr) + q^{k+1}\bigl(q^{\,n-k}-1\bigr) \;=\; q^{\,n+1}-1,$$
so the total is $(q^{n+1}-1)[n]_q! = [n+1]_q!$, as required. $\square$

Three corollaries follow at once.

**Corollary 2.8 (positivity).** If $q \ge 2$ and $k \le n$ then $B_q(n,k) > 0$.

*Proof.* If $B_q(n,k)=0$ then Theorem 2.7 gives $[n]_q! = 0$, contradicting Lemma 2.6. $\square$

**Corollary 2.9 (symmetry).** If $q \ge 2$ and $k \le n$ then $B_q(n,k) = B_q(n,n-k)$.

*Proof.* Apply Theorem 2.7 at $k$ and at $n-k$ (using $n-(n-k)=k$): the left factor $[k]_q!\,[n-k]_q!$ is the same in both, and it is nonzero by Lemma 2.6, so the two $B$-values agree by cancellation in the integral domain $\mathbb{Z}$. $\square$

Note how cheap symmetry becomes once the identity is available; over a field it is the duality $W \mapsto W^{\perp}$, and here it is a cancellation.

### 2.4 Exactness: the two definitions agree

We must reconcile Definition 2.1, a truncated natural division, with Definition 2.2.

**Lemma 2.10 (numerator over $\mathbb{Z}$).** For $q \ge 1$,
$$\Bigl(\textstyle\prod_{i<k}(q^{n}-q^{i})\Bigr)_{\mathbb{N}} \;=\; \prod_{i<k}\bigl(q^{n}-q^{i}\bigr) \ \text{ computed in } \mathbb{Z}.$$

*Proof.* If $k \le n$ every factor has $q^{i} \le q^{n}$, so natural subtraction agrees with integer subtraction. If $k > n$, the index $i=n$ occurs in the range and contributes a zero factor on both sides. $\square$

**Lemma 2.11 (factoring out the power of $q$).** For $k \le n$, over $\mathbb{Z}$,
$$\prod_{i<k}\bigl(q^{n}-q^{i}\bigr) \;=\; q^{\binom{k}{2}}\prod_{i<k}\bigl(q^{\,n-i}-1\bigr), \qquad \binom{k}{2} = \sum_{i<k} i .$$

*Proof.* Pull $q^{i}$ out of the $i$-th factor: $q^{n}-q^{i} = q^{i}(q^{n-i}-1)$ for $i \le n$. $\square$

**Lemma 2.12 (descending product completes the factorial).** For $k \le n$, over $\mathbb{Z}$,
$$\Bigl(\prod_{i<k}\bigl(q^{\,n-i}-1\bigr)\Bigr)\cdot [n-k]_q! \;=\; [n]_q!.$$

*Proof.* Induction on $k$. At $k=0$ both sides are $[n]_q!$. The step peels the factor $q^{\,n-k}-1$ off the descending product and merges it with $[n-k-1]_q!$ to form $[n-k]_q!$. $\square$

Taking $n = k$ in Lemmas 2.11 and 2.12 gives the denominator:

**Lemma 2.13.** Over $\mathbb{Z}$, $\ \prod_{i<k}(q^{k}-q^{i}) = q^{\binom{k}{2}}\,[k]_q!$, and this is strictly positive for $q \ge 2$.

**Theorem 2.14 (exactness).** Let $q \ge 2$. For all $n,k$,
$$\Bigl(\prod_{i<k}(q^{k}-q^{i})\Bigr)\cdot B_q(n,k) \;=\; \prod_{i<k}(q^{n}-q^{i}),$$
so the division in Definition 2.1 is exact and
$$\binom{n}{k}_{\!q} \;=\; B_q(n,k).$$

*Proof sketch.* For $k > n$ both sides vanish (the index $i=n$ gives a zero factor, and $B_q(n,k)=0$). For $k \le n$, use Lemma 2.13 on the left and Lemma 2.11 on the right; after cancelling $q^{\binom{k}{2}} > 0$ the claim reads
$$[k]_q!\,B_q(n,k) \;=\; \prod_{i<k}\bigl(q^{\,n-i}-1\bigr),$$
which follows from Theorem 2.7 and Lemma 2.12 upon multiplying both sides by the positive integer $[n-k]_q!$. The integer statement transfers to $\mathbb{N}$ by Lemma 2.10, and dividing by the positive denominator gives the last claim. $\square$

From this point we write $\binom{n}{k}_q$ for both functions.

### 2.5 The main theorems for $\binom{n}{k}_q$

**Theorem 2.15 ($q$-Pascal recursion).** For every $q \ge 2$ and all $n,k \ge 0$,
$$\binom{n+1}{k+1}_{\!q} \;=\; \binom{n}{k}_{\!q} \;+\; q^{\,k+1}\binom{n}{k+1}_{\!q}.$$

**Theorem 2.16 (symmetry, arbitrary base).** For every $q \ge 2$ and $k \le n$, $\ \binom{n}{k}_q = \binom{n}{n-k}_q$.

**Theorem 2.17 (positivity and boundary values).** For $q \ge 2$: $\binom{n}{k}_q > 0$ for $k \le n$; $\binom{n}{k}_q = 0$ for $k > n$; $\binom{n}{0}_q = \binom{n}{n}_q = 1$.

**Theorem 2.18 (first column).** For $q \ge 2$, $\ \displaystyle\binom{n}{1}_{\!q} = \sum_{i=0}^{n-1} q^{i} = 1 + q + \cdots + q^{\,n-1}$, equivalently $\binom{n+1}{1}_q = 1 + q\binom{n}{1}_q$.

*Proof.* Induction on $n$ using Theorem 2.15 with $k=0$ and $\binom{n}{0}_q=1$. $\square$

**Theorem 2.19 (dual $q$-Pascal recursion).** For every $q \ge 2$ and all $n,k$,
$$\binom{n+1}{k+1}_{\!q} \;=\; q^{\,n-k}\binom{n}{k}_{\!q} \;+\; \binom{n}{k+1}_{\!q}.$$

*Proof sketch.* For $k > n$ all three terms vanish. For $k = n$ both sides equal $1$. For $k < n$, write $n-k = m+1$ and apply Theorem 2.16 to the left-hand side: $\binom{n+1}{k+1}_q = \binom{n+1}{n-k}_q = \binom{n+1}{m+1}_q$. Expand this by Theorem 2.15 as $\binom{n}{m}_q + q^{m+1}\binom{n}{m+1}_q$, and convert both terms back by symmetry, using $n-m = k+1$ and $m+1 = n-k$. $\square$

### 2.6 The Galois numbers

**Lemma 2.20.** For all $q,n$: $\ S_q(n) = \sum_{k=0}^{n} q^{k+1}\binom{n}{k+1}_q + 1$.

*Proof.* Reindex the defining sum, the $k=0$ term contributing $\binom{n}{0}_q = 1$, and note the added term at $k=n$ vanishes since $\binom{n}{n+1}_q=0$. $\square$

**Theorem 2.21.** For $q \ge 2$: $\ G_q(n+1) = G_q(n) + S_q(n)$.

*Proof sketch.* $G_q(n+1) = 1 + \sum_{k=0}^{n}\binom{n+1}{k+1}_q$. Apply $q$-Pascal termwise and split the sum: the first parts give $\sum_{k \le n}\binom{n}{k}_q = G_q(n)$, the second parts give $\sum_{k\le n} q^{k+1}\binom{n}{k+1}_q$, which together with the leading $1$ equals $S_q(n)$ by Lemma 2.20. $\square$

**Theorem 2.22.** For $q \ge 2$: $\ S_q(n+1) = q^{\,n+1}G_q(n) + S_q(n)$.

*Proof sketch.* Reindex $S_q(n+1) = 1 + \sum_{k=0}^{n} q^{k+1}\binom{n+1}{k+1}_q$. For $k \le n$ the dual recursion (Theorem 2.19) gives
$$q^{k+1}\binom{n+1}{k+1}_{\!q} \;=\; q^{k+1}q^{\,n-k}\binom{n}{k}_{\!q} + q^{k+1}\binom{n}{k+1}_{\!q} \;=\; q^{\,n+1}\binom{n}{k}_{\!q} + q^{k+1}\binom{n}{k+1}_{\!q},$$
using $q^{k+1}q^{n-k} = q^{n+1}$. Summing, the first parts give $q^{n+1}G_q(n)$ and the second parts plus the leading $1$ give $S_q(n)$ by Lemma 2.20. $\square$

**Theorem 2.23 (three-term recursion for the Galois numbers).** For $q \ge 2$ and all $n \ge 0$,
$$G_q(n+2) \;=\; 2\,G_q(n+1) \;+\; \bigl(q^{\,n+1}-1\bigr)G_q(n).$$

*Proof.* By Theorem 2.21, $G_q(n+2) = G_q(n+1)+S_q(n+1)$ and $S_q(n) = G_q(n+1)-G_q(n)$. Substituting Theorem 2.22,
$$G_q(n+2) = G_q(n+1) + q^{n+1}G_q(n) + S_q(n) = G_q(n+1) + q^{n+1}G_q(n) + G_q(n+1)-G_q(n),$$
which is the claim. $\square$

(In the integers one states this as $G_q(n+2) + G_q(n) = 2G_q(n+1) + q^{n+1}G_q(n)$, avoiding subtraction.)

**Proposition 2.24 (small values).** For $q \ge 2$: $G_q(0)=1$, $G_q(1)=2$, and $G_q(2) = q+3$.

*Proof.* The first two are immediate. For the third, $G_q(2) = \binom{2}{0}_q+\binom{2}{1}_q+\binom{2}{2}_q = 1 + (1+q) + 1 = q+3$ by Theorems 2.17 and 2.18. $\square$

**Corollary 2.25 (tables).** $G_2(n)$ for $n = 0,\dots,5$ is $1, 2, 5, 16, 67, 374$. $G_3(n)$ for $n=0,\dots,4$ is $1,2,6,28,212$; in particular $G_3(4) = 2\cdot 28 + (3^{3}-1)\cdot 6 = 212$ follows from Theorem 2.23 alone. At the non-prime base $q = 4$: $\binom{2}{1}_4 = 5$, $\binom{3}{1}_4 = \binom{3}{2}_4 = 21$ and $\sum_{k\le 3}\binom{3}{k}_4 = 44$; symmetry at the non-prime base $q=6$ reads $\binom{5}{2}_6 = \binom{5}{3}_6$.

The base $q=4$ and $q=6$ instances are exactly the cases inaccessible to the subspace argument as stated over $\mathbb{Z}/q$: no ring $\mathbb{Z}/4$ or $\mathbb{Z}/6$ is a field. They are unconditional consequences of Theorems 2.14–2.16.

---

## 3. Counting subgroups of a finite group

Write $\mathrm{Sub}(G)$ for the lattice of subgroups of a finite group $G$, and $\#\mathrm{Sub}(G)$ for its cardinality (finite, since a subgroup is determined by its underlying subset).

### 3.1 Coprime products

**Lemma 3.1 (root extraction in a subgroup).** Let $A$ be a finite group, $K \le A$, $x \in A$ and $n \ge 1$ with $\gcd(\mathrm{ord}(x),n) = 1$. If $x^{n} \in K$ then $x \in K$.

*Proof.* Clearly $\langle x^{n}\rangle \le \langle x\rangle$; and $\mathrm{ord}(x^{n}) = \mathrm{ord}(x)/\gcd(\mathrm{ord}(x),n) = \mathrm{ord}(x)$, so the two cyclic groups have equal order and hence coincide. Thus $x \in \langle x^{n}\rangle \le K$. $\square$

**Lemma 3.2 (coordinate splitting).** Let $G,H$ be finite with $\gcd(|G|,|H|)=1$ and let $K \le G \times H$. If $(a,b) \in K$ then $(a,1) \in K$ and $(1,b) \in K$.

*Proof.* Put $m = |H|$. Then $(a,b)^{m} = (a^{m}, 1) \in K$ since $b^{m}=1$. Also $(a,1)^{m} = (a^{m},1)$, so the element $x = (a,1)$ satisfies $x^{m}\in K$. Its order divides $|G|$, which is coprime to $m = |H|$, so Lemma 3.1 gives $(a,1)\in K$. Symmetrically with $|G|$ in place of $|H|$ for $(1,b)$. $\square$

**Theorem 3.3 (product decomposition of subgroups).** If $\gcd(|G|,|H|)=1$ then every $K \le G\times H$ satisfies
$$K \;=\; \pi_1(K) \times \pi_2(K),$$
where $\pi_1,\pi_2$ are the two projections. No commutativity is assumed.

*Proof.* The inclusion $\subseteq$ is trivial. Conversely if $a \in \pi_1(K)$ and $b \in \pi_2(K)$, choose $(a,b_1),(a_2,b)\in K$; by Lemma 3.2, $(a,1)$ and $(1,b)$ lie in $K$, hence so does their product $(a,b)$. $\square$

**Theorem 3.4 (lattice splitting and multiplicativity).** If $\gcd(|G|,|H|)=1$ then
$$\mathrm{Sub}(G \times H) \;\cong\; \mathrm{Sub}(G)\times \mathrm{Sub}(H)$$
as ordered sets, via $K \mapsto (\pi_1(K),\pi_2(K))$ with inverse $(A,B)\mapsto A\times B$; consequently
$$\#\mathrm{Sub}(G\times H) \;=\; \#\mathrm{Sub}(G)\cdot\#\mathrm{Sub}(H).$$

*Proof sketch.* The two maps are mutually inverse: one direction is Theorem 3.3, the other is $\pi_1(A\times B) = A$, $\pi_2(A\times B)=B$. Monotonicity of $K \mapsto (\pi_1 K, \pi_2 K)$ is clear; conversely if the projections of $K$ are contained in those of $K'$ then, rewriting both by Theorem 3.3, $K \le K'$. $\square$

**Theorem 3.5 (finite coprime families).** Let $G_1,\dots,G_n$ be finite groups with $\gcd(|G_i|,|G_j|)=1$ for $i \ne j$. Then
$$\#\mathrm{Sub}\Bigl(\prod_{i=1}^{n} G_i\Bigr) \;=\; \prod_{i=1}^{n} \#\mathrm{Sub}(G_i).$$

*Proof sketch.* Induction on $n$, splitting off the first factor: $\prod_i G_i \cong G_1 \times \prod_{i\ge 2}G_i$, and $|G_1|$ is coprime to $\prod_{i \ge 2}|G_i|$ because coprimality to each factor is preserved by products. Apply Theorem 3.4 and the inductive hypothesis. The base case is the trivial group, which has one subgroup. $\square$

Since a finite abelian group is the direct product of its primary components, whose orders are pairwise coprime, Theorem 3.5 reduces the subgroup count of any finite abelian group to that of its $p$-parts.

### 3.2 Cyclic groups

**Lemma 3.6 (existence).** In a finite cyclic group $G$ of order $N$, for every $d \mid N$ there is a subgroup of order $d$, namely $\langle g^{N/d}\rangle$ for a generator $g$.

*Proof.* $\mathrm{ord}(g^{N/d}) = N/\gcd(N,N/d) = N/(N/d) = d$. $\square$

**Lemma 3.7 (uniqueness).** In a finite cyclic group $G$, a subgroup $L$ with $|L| = d$ equals the kernel of the endomorphism $x \mapsto x^{d}$.

*Proof.* Every $x \in L$ satisfies $x^{d} = 1$, so $L \le \ker$. In a cyclic group the kernel of $x\mapsto x^{d}$ has order $\gcd(d,|G|) = d$ (as $d \mid |G|$ by Lagrange), so the inclusion of equal finite orders is an equality. $\square$

**Theorem 3.8 (divisor count).** A finite cyclic group of order $N$ has exactly $d(N)$ subgroups, one of each order dividing $N$.

*Proof.* By Lemma 3.7 the order map $L \mapsto |L|$ is injective on $\mathrm{Sub}(G)$; by Lagrange it lands in the divisors of $N$; by Lemma 3.6 it is onto them. $\square$

**Corollary 3.9.** A cyclic group of order $p^{r}$ has exactly $r+1$ subgroups. In particular $\#\mathrm{Sub}(\mathbb{Z}/4) = 3$.

### 3.3 Groups of order $p^2$ and exponent $p$

**Lemma 3.10.** Let $G$ have exponent $p$, $p$ prime, and let $x \ne 1$. Then $|\langle x\rangle| = p$. Conversely, if $|L| = p$ and $1 \ne x \in L$ then $L = \langle x\rangle$.

*Proof.* $\mathrm{ord}(x)$ divides $p$ and is not $1$, hence is $p$. For the converse, $\langle x\rangle \le L$ and both have order $p$. $\square$

**Theorem 3.11 (the $p+1$ lines).** Let $|G| = p^{2}$ with exponent $p$ ($p$ prime). Then $G$ has exactly $p+1$ subgroups of order $p$.

*Proof.* Consider $F : \{x \in G : x \ne 1\} \to \{L \le G : |L| = p\}$, $F(x) = \langle x\rangle$, well defined by Lemma 3.10. By the converse in Lemma 3.10 the fibre $F^{-1}(L)$ is exactly the set of non-identity elements of $L$, of size $p-1$. Fibring the domain,
$$p^{2}-1 \;=\; \#\{L : |L| = p\}\cdot (p-1),$$
and dividing by $p-1 > 0$ gives $\#\{L\} = p+1$. $\square$

**Theorem 3.12 (total count).** Let $|G| = p^{2}$ with exponent $p$. Then $\#\mathrm{Sub}(G) = p+3$.

*Proof.* By Lagrange every subgroup has order $1$, $p$ or $p^{2}$; the extremes occur exactly for the trivial subgroup and $G$, contributing $1$ each, and Theorem 3.11 supplies $p+1$ in the middle. $\square$

**Corollary 3.13 (the contrast at order $p^{2}$).** If $G$ is cyclic of order $p^{2}$ and $H$ has order $p^{2}$ and exponent $p$, then $\#\mathrm{Sub}(G) = 3$ and $\#\mathrm{Sub}(H) = p+3$; these differ for every prime $p$. In particular $\#\mathrm{Sub}(\mathbb{Z}/4) = 3 \ne 5 = \#\mathrm{Sub}\bigl((\mathbb{Z}/2)^{2}\bigr)$.

**Corollary 3.14 (order twelve).** $\#\mathrm{Sub}(\mathbb{Z}/12) = \#\mathrm{Sub}(\mathbb{Z}/4)\cdot\#\mathrm{Sub}(\mathbb{Z}/3) = 3\cdot 2 = 6 = d(12)$, while $\#\mathrm{Sub}\bigl((\mathbb{Z}/2)^2\times\mathbb{Z}/3\bigr) = 5\cdot 2 = 10$.

### 3.4 Elementary abelian groups and the Galois numbers

An elementary abelian group $(\mathbb{Z}/p)^{r}$ is an $r$-dimensional vector space over the field $\mathbb{F}_p$, and its subgroups are precisely its subspaces. The classical subspace count — choose an ordered linearly independent $k$-tuple in $\prod_{i<k}(p^{r}-p^{i})$ ways, and observe that the tuples spanning a fixed $k$-dimensional subspace $W$ are exactly the bases of $W$, of which there are $\prod_{i<k}(p^{k}-p^{i})$ — gives
$$\#\{\,W \le (\mathbb{Z}/p)^{r} : \dim W = k\,\} \;=\; \binom{r}{k}_{\!p}, \qquad k \le r,$$
and $0$ for $k>r$. Summing over $k$:

**Theorem 3.15.** $\ \#\mathrm{Sub}\bigl((\mathbb{Z}/p)^{r}\bigr) = G_p(r) = \sum_{k=0}^{r}\binom{r}{k}_{\!p}$.

Consistency with §3.3 is a pleasant check: $G_p(2) = p+3$ by Proposition 2.24, matching Theorem 3.12, and the $p+1$ lines of Theorem 3.11 are the $\binom{2}{1}_p = 1+p$ one-dimensional subspaces.

**Theorem 3.16 (mixed elementary abelian).** For distinct primes $p \ne q$ and $r,s \ge 0$,
$$\#\mathrm{Sub}\bigl((\mathbb{Z}/p)^{r}\times(\mathbb{Z}/q)^{s}\bigr) \;=\; G_p(r)\cdot G_q(s).$$

*Proof.* The orders $p^{r}$ and $q^{s}$ are coprime; apply Theorem 3.4 and Theorem 3.15. $\square$

---

## 4. Intermediate fields of a Hilbert class field

Let $(H/K, e)$ be a class field datum as in §1.1: $H/K$ finite Galois and $e : \mathrm{Gal}(H/K)\xrightarrow{\sim}\mathrm{Cl}(K)$.

**Theorem 4.1 (the counting principle).** The number of intermediate fields $K \subseteq F \subseteq H$ equals $\#\mathrm{Sub}(\mathrm{Cl}(K))$, and under the correspondence the field $F_A$ attached to $A \le \mathrm{Cl}(K)$ satisfies $[F_A:K] = [\mathrm{Cl}(K):A]$ and $[H:F_A] = |A|$.

*Proof.* Galois correspondence transported along the isomorphism $e$, which carries subgroups to subgroups and preserves index. $\square$

**Theorem 4.2 (cyclic class group).** If $\mathrm{Cl}(K)$ is cyclic of order $n$ then the datum has exactly $d(n)$ intermediate fields, exactly one of each degree $m \mid n$ over $K$.

*Proof.* Theorems 3.8 and 4.1; the field of degree $m$ corresponds to the unique subgroup of order $n/m$. $\square$

**Theorem 4.3 (elementary abelian class group).** If $\mathrm{Cl}(K) \cong (\mathbb{Z}/p)^{r}$ then the datum has exactly
$$G_p(r) \;=\; \sum_{k=0}^{r}\binom{r}{k}_{\!p}$$
intermediate fields, and for each $0 \le k \le r$ exactly $\binom{r}{k}_{p}$ of them have degree $p^{k}$ over $K$. The degrees that occur are exactly $p^{k}$ for $0 \le k \le r$, and the degreewise counts sum to the total.

*Proof.* Subgroups of $\mathrm{Cl}(K)$ are $\mathbb{F}_p$-subspaces of $\mathbb{F}_p^{r}$; a subspace $W$ of dimension $j$ has index $p^{\,r-j}$, so it produces a field of degree $p^{\,r-j}$ over $K$. Setting $k = r-j$, the number of such fields is the number of subspaces of dimension $r-k$, namely $\binom{r}{r-k}_p$, which equals $\binom{r}{k}_p$ by Theorem 2.16 (symmetry). Positivity, Theorem 2.17, shows each degree $p^{k}$, $k \le r$, actually occurs. $\square$

It is worth emphasising that symmetry of the Gaussian binomial is precisely the step which turns an index count into a degree count with the *same* index $k$; this is the arithmetic content behind the pleasing palindromic degree distributions below.

**Corollary 4.4 (Klein four class group; $p = r = 2$).** If $\mathrm{Cl}(K) \cong (\mathbb{Z}/2)^{2}$ the datum has exactly $G_2(2) = 5$ intermediate fields, of which $\binom{2}{1}_2 = 3$ are quadratic over $K$; the multiset of degrees is $\{1,2,2,2,4\}$.

**Corollary 4.5 (rank three at $p=2$).** If $\mathrm{Cl}(K)\cong(\mathbb{Z}/2)^{3}$ the datum has exactly $G_2(3) = 16$ intermediate fields, with degree distribution
$$\binom{3}{0}_2,\ \binom{3}{1}_2,\ \binom{3}{2}_2,\ \binom{3}{3}_2 \;=\; 1,\ 7,\ 7,\ 1$$
in degrees $1, 2, 4, 8$ over $K$.

**Theorem 4.6 (mixed class group).** If $\mathrm{Cl}(K)\cong(\mathbb{Z}/p)^{r}\times(\mathbb{Z}/q)^{s}$ with $p \ne q$ prime, the datum has exactly $G_p(r)\,G_q(s)$ intermediate fields.

*Proof.* Theorems 3.16 and 4.1. $\square$

**Corollary 4.7 (class number twelve).** If $\mathrm{Cl}(K)\cong(\mathbb{Z}/2)^{2}\times\mathbb{Z}/3$ the datum has $G_2(2)G_3(1) = 5\cdot 2 = 10$ intermediate fields, whereas a cyclic class group of the same order $12$ gives only $d(12) = 6$.

**Theorem 4.8 (the count is not a function of the class number).** There exist finite abelian groups of equal order with different subgroup counts — e.g. $3 \ne 5$ at order $4$, $6 \ne 10$ at order $12$, and $3 \ne p+3$ at order $p^{2}$ for every prime $p$. Consequently no function of $h_K$ alone can predict the number of intermediate fields of a Hilbert class field.

---

## 5. Algorithms

Three computational procedures fall out of the theory; all are elementary but the complexity statements are worth recording, since naive evaluation of Definition 2.1 involves integers with $\Theta(nk\log q)$ bits.

### 5.1 Row-by-row $q$-Pascal triangle

To tabulate $\binom{n}{k}_q$ for all $k \le n \le N$, initialise the row $n=0$ as $[1]$ and apply Theorem 2.15:
$$\text{row}_{n+1}[0] = 1, \qquad \text{row}_{n+1}[k+1] = \text{row}_{n}[k] + q^{k+1}\,\text{row}_{n}[k+1].$$
This performs $\Theta(N^{2})$ big-integer additions and multiplications by powers of $q$ and, unlike the defining quotient, never forms a large intermediate product only to divide it away. Correctness is Theorem 2.14.

### 5.2 Galois numbers by the three-term recursion

$G_q(0) = 1$, $G_q(1) = 2$, and thereafter $G_q(n+2) = 2G_q(n+1) + (q^{n+1}-1)G_q(n)$ (Theorem 2.23). This computes $G_q(N)$ in $\Theta(N)$ arithmetic operations, against $\Theta(N^{2})$ for summing a full triangle row — an asymptotically real saving because $G_q(N)$ has $\Theta(N^{2}\log q)$ bits, so the triangle route also pays for storing $\Theta(N)$ numbers of that size.

### 5.3 Subgroup count of a finite abelian group from its invariants

Given a finite abelian group as a list of invariant factors or as a primary decomposition $\bigoplus_p \bigoplus_i \mathbb{Z}/p^{\lambda_{p,i}}$:

1. Split into primary components (Theorem 3.5): the total count is $\prod_p \#\mathrm{Sub}(A_p)$.
2. For a cyclic component of order $N$, return $d(N)$ (Theorem 3.8); for a cyclic $p$-component of order $p^{r}$, return $r+1$.
3. For an elementary abelian component $(\mathbb{Z}/p)^{r}$, return $G_p(r)$ (Theorem 3.15), computed by §5.2.

Steps 1–3 settle every abelian group all of whose primary components are cyclic or elementary abelian, which covers all the class field applications of §4. For a general $p$-component of type $\lambda$ the count is given by the Birkhoff–Hall subgroup-counting formula; that case is listed among the open directions in §7.

---

## 6. Applications and cross-checks

**6.1 Prediction and falsification.** The framework yields sharply falsifiable numerical predictions. A field with Klein four class group has exactly five unramified abelian intermediate fields with degree multiset $\{1,2,2,2,4\}$ — the three quadratic ones are pairwise distinct because the three subgroups of order two are. A field with class group $(\mathbb{Z}/2)^{3}$ has exactly sixteen, distributed $1,7,7,1$. A field with class group $(\mathbb{Z}/2)^{2}\times\mathbb{Z}/3$ has exactly ten. Each is a single integer that a computation with an explicit field either confirms or refutes.

**6.2 Two independent proofs at order $p^{2}$.** The count $p+3$ arises twice: once by partitioning the $p^{2}-1$ non-identity elements into lines (Theorem 3.12), once as the Galois number $G_p(2) = p+3$ obtained from the boundary values of the $q$-binomial triangle (Proposition 2.24). The agreement is a check on both developments, and it is the smallest case where the geometric and arithmetic routes meet.

**6.3 Beyond finite geometry.** Because Theorems 2.14–2.19 hold for every $q \ge 2$, they apply where no field of $q$ elements exists. The identity $\binom{5}{2}_6 = \binom{5}{3}_6$ and the recursion instance $\binom{2}{1}_4 = \binom{1}{0}_4 + 4\binom{1}{1}_4 = 1+4 = 5$ are not statements about subspaces. This matters for the standard combinatorial readings of $\binom{n}{k}_q$ — as the generating polynomial, evaluated at $q$, of partitions fitting in a $k \times (n-k)$ box, and as the $q$-analogue occurring in $q$-series and quantum-group identities — where $q$ is an arbitrary parameter.

**6.4 Integrality as a structural fact.** Exactness (Theorem 2.14) says that $\prod_{i<k}(q^{k}-q^{i})$ divides $\prod_{i<k}(q^{n}-q^{i})$ in $\mathbb{Z}$ for all $q \ge 2$ and $k \le n$ — a divisibility statement about cyclotomic-type products that is not obvious termwise, and whose proof here is by exhibiting the quotient as a solution of a recursion.

---

## 7. Discussion and future work

The methodological point of §2 is that a *quotient* definition can be replaced by a *recursive* one, with the equality of the two proved rather than assumed, and that this buys uniformity in the base. The methodological point of §3 is that subgroup counting is genuinely lattice-theoretic: the coprime splitting is an isomorphism of ordered sets, not merely a numerical coincidence, and it is available without commutativity.

Several directions remain open.

**(a) General finite abelian class groups.** Combining Theorem 3.5 with a count for arbitrary $p$-groups of type $\lambda = (\lambda_1 \ge \lambda_2 \ge \cdots)$ would give $\#\mathrm{Sub}(A)$ for every finite abelian $A$, hence the number of intermediate fields for every class group. The missing ingredient is the Birkhoff–Hall formula for the number of subgroups of type $\mu$ in an abelian $p$-group of type $\lambda$, whose generating function involves Hall polynomials. Already the two abelian groups of order $p^{2}$ separate — $3$ versus $p+3$ — and the first genuinely new case is $\lambda = (2,1)$, of order $p^{3}$.

**(b) $q$-analogues at $q=1$ and $q$-log-concavity.** The recursion degenerates correctly at $q=1$ to Pascal's rule and $G_1(n) = 2^{n}$. Beyond that, the unimodality and log-concavity of the row $\bigl(\binom{n}{k}_q\bigr)_{k}$, and the asymptotics $G_q(n) \sim c\, q^{n^{2}/4}$, are natural next targets that the recursion-based approach should reach.

**(c) Unconditional arithmetic instances.** The results of §4 are stated for a class field datum. Making them unconditional for a specific field requires computing an actual class group and exhibiting the extension: for $K = \mathbb{Q}(\sqrt{-5})$, class number $2$, the Hilbert class field is $K(i)$ and the count becomes the unconditional statement that there are exactly $G_2(1) = 2$ intermediate fields. For $K = \mathbb{Q}(\sqrt{-21})$, class group $(\mathbb{Z}/2)^{2}$, the prediction is five.

**(d) Splitting laws.** The Galois correspondence used here is degree-blind in the arithmetic sense: it counts fields but says nothing about primes. Demanding that the identification $\mathrm{Gal}(H/K)\cong\mathrm{Cl}(K)$ be the Artin map — sending the Frobenius at an unramified prime $\mathfrak{p}$ to the class $[\mathfrak{p}]$ — refines each count into a splitting law: in the elementary abelian case, the primes splitting completely in the degree-$p^{k}$ field attached to a subspace $W$ are exactly those whose ideal class lies in $W$.

**(e) Genus theory.** For imaginary quadratic $K$ with $t$ prime discriminant divisors, the quotient $\mathrm{Cl}/\mathrm{Cl}^{2}$ has order $2^{t-1}$ and cuts out the genus field. When $\mathrm{Cl}(K)$ is elementary abelian of rank $r$ the genus field is the whole Hilbert class field and $r = t-1$; combining this with Theorem 4.3 would convert a purely local count of ramified primes into the full intermediate field count.

---

## 8. Summary of results

**Arithmetic, for every base $q \ge 2$.**
1. The quotient $\prod_{i<k}(q^{n}-q^{i})/\prod_{i<k}(q^{k}-q^{i})$ is an exact division of integers, equal to the function $B_q(n,k)$ defined by $q$-Pascal.
2. $[k]_q!\,[n-k]_q!\,\binom{n}{k}_q = [n]_q!$ for $k \le n$, where $[m]_q! = \prod_{j<m}(q^{j+1}-1)$.
3. $\binom{n+1}{k+1}_q = \binom{n}{k}_q + q^{k+1}\binom{n}{k+1}_q$ and $\binom{n+1}{k+1}_q = q^{\,n-k}\binom{n}{k}_q + \binom{n}{k+1}_q$.
4. $\binom{n}{k}_q = \binom{n}{n-k}_q$ and $\binom{n}{k}_q > 0$ for $k \le n$; $\binom{n}{1}_q = 1+q+\cdots+q^{n-1}$.
5. $G_q(n+2) = 2G_q(n+1) + (q^{n+1}-1)G_q(n)$, with $G_q(0)=1$, $G_q(1)=2$, $G_q(2)=q+3$; $G_2$: $1,2,5,16,67,374$; $G_3(4) = 212$; $G_4(3) = 44$.

**Group theory.**
6. For coprime orders, $\mathrm{Sub}(G\times H)\cong \mathrm{Sub}(G)\times\mathrm{Sub}(H)$ as ordered sets, hence multiplicativity of the count, extended to finite pairwise-coprime families.
7. A cyclic group of order $N$ has $d(N)$ subgroups; of order $p^{r}$, exactly $r+1$.
8. A group of order $p^{2}$ and exponent $p$ has $p+1$ subgroups of order $p$ and $p+3$ subgroups in all; the cyclic group of the same order has $3$.

**Class fields.**
9. A class field datum has $\#\mathrm{Sub}(\mathrm{Cl}(K))$ intermediate fields: $d(n)$ for cyclic $\mathrm{Cl}(K)$ of order $n$; $G_p(r)$ for $\mathrm{Cl}(K)\cong(\mathbb{Z}/p)^{r}$, with exactly $\binom{r}{k}_p$ of degree $p^{k}$; and $G_p(r)G_q(s)$ in the mixed case.
10. Hence $5$ intermediate fields (degrees $1,2,2,2,4$) for a Klein four class group, $16$ (degrees $1,7,7,1$ in $1,2,4,8$) for $(\mathbb{Z}/2)^{3}$, and $10$ versus $6$ at class number twelve: the count depends on the class group, not the class number.
