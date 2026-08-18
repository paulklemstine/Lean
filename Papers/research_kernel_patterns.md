# Kernel Patterns: Complete Invariants for Symbol Renaming, the Bell Enumeration, and Kernel Spectra of Diophantine Equations

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

For a tuple $f = (f_0, \dots, f_{n-1})$ with entries in a set $A$, its *kernel* (or equality pattern) is the equivalence relation on indices defined by $i \sim j \iff f_i = f_j$. We develop the theory of kernels systematically. We prove that the kernel is a **complete invariant** for the action of the symmetric group of a finite alphabet $B$ on tuples $B^n$ by post-composition: two tuples lie in the same orbit if and only if their kernels agree. We introduce an explicit, computable canonical form $\mathrm{canon}(f)_i = \min\{j : f_j = f_i\}$ — the restricted-growth normal form — and show it is a complete computable invariant, so that orbit equivalence is decided by comparing two integer tuples in linear time.

On the enumerative side we prove that the number of kernel patterns of length $n$ is the Bell number $B_n$ for every $n$, thereby identifying the combinatorial count of set partitions with the binomially-defined recursion $B_{n+1} = \sum_i \binom{n}{i} B_{n-i}$. Refining patterns by their number of blocks yields a purely combinatorial definition of the Stirling numbers of the second kind $S(n,k)$; we prove the recursion $S(n+1,k+1) = S(n,k) + (k+1)S(n,k+1)$, the closed forms $S(n+1,2) = 2^n - 1$, $S(n+1,n) = \binom{n+1}{2}$, $S(n+2,n) = \binom{n+2}{3} + 3\binom{n+2}{4}$, the column formulas for $k = 3,4,5$, the falling-factorial expansion $m^n = \sum_k S(n,k)\, m^{\underline{k}}$, and the surjection count $k!\,S(n,k)$. We deduce the orbit count $\sum_{k \le |B|} S(n,k)$ over an arbitrary finite alphabet, with the Bell number recovered exactly when $|B| \ge n$. We prove strict super-multiplicativity $B_m B_n < B_{m+n}$ for $m,n \ge 1$, hence $B_n^k \le B_{nk}$ and $2^k \le B_{2k}$; strict monotonicity from $n = 1$; and Touchard's congruence $B_{p+n} \equiv B_{n+1} + B_n \pmod p$ for prime $p$, by a fixed-point argument for the cyclic action of order $p$.

Finally we introduce the **kernel spectrum** of a Diophantine equation: the set of equality patterns realised by its solutions. We compute the spectrum of $a^2 + b^2 = c^2$ over $\mathbb{N}$: it consists of four of the five patterns of a triple, the missing one being "equal legs, distinct hypotenuse"; the obstruction is the lemma that $ka^2 = c^2$ with $a \ne 0$ forces $k$ to be a perfect square. The same lemma shows that the $k$-dimensional equation $\sum_{i<k} x_i^2 = y^2$ admits an equal-legs solution precisely when $k$ is a perfect square, so the defect vanishes in dimension $4$. For $x^p + y^p = z^p$ with $p \ge 2$ we show that the equal-legs pattern is blocked by a $2$-adic valuation argument for every $p$, that all five patterns occur at $p = 1$, and that the spectrum has exactly three elements iff the equation has no positive solution and four otherwise — a combinatorial restatement of Fermat's Last Theorem at each exponent.

**Keywords:** equality pattern, kernel of a map, restricted growth string, complete invariant, Bell numbers, Stirling numbers of the second kind, Touchard congruence, orbit counting, Pythagorean triples, Fermat equation.

---

## 1. Introduction

Consider a finite list of symbols. Which of its features survive a consistent renaming of the symbols? Exactly one: the record of *which positions carry equal entries*. This record — the kernel, or equality pattern — is the subject of this paper.

The idea is elementary and appears throughout mathematics and computer science, usually unnamed. In model theory it is the type of a tuple in the pure theory of equality. In database theory it is the equality pattern of a row, the basis for query minimisation under renaming. In the theory of species and in Pólya theory it is the object that reduces counting-with-labels to counting-without-labels. In symmetry reduction for model checking, it is the canonical form used to collapse states that differ only in the identities of interchangeable processes.

What is less commonly presented is a single development in which (i) the completeness of the invariant, (ii) its computable normal form, (iii) its enumeration by the Bell numbers together with the full Stirling refinement, and (iv) its use as an invariant of Diophantine equations, all appear as consequences of one definition. That is what we do here.

The plan is:

- **§2** defines the kernel and the canonical form and establishes their basic calculus.
- **§3** proves the completeness theorem over a finite alphabet.
- **§4** proves that patterns of length $n$ are counted by the Bell number $B_n$, in every arity.
- **§5** develops the Stirling refinement: recursion, closed forms, tables, falling factorials, surjections.
- **§6** derives orbit counts over arbitrary finite alphabets and shows the sharpness of the size hypothesis.
- **§7** proves growth results (monotonicity, super-multiplicativity) and Touchard's congruence.
- **§8** introduces kernel spectra of Diophantine equations and computes them for the Pythagorean and Fermat families.
- **§9** discusses algorithms; **§10** discusses applications and future directions.

Throughout, $[n] = \{0, 1, \dots, n-1\}$ denotes the index set of an $n$-tuple, and tuples are functions $f : [n] \to A$.

---

## 2. Kernels and canonical forms

### 2.1 The kernel

**Definition 2.1 (Kernel).** For a tuple $f : [n] \to A$, the *kernel* of $f$ is the binary relation $\mathrm{Ker}(f)$ on $[n]$ given by
$$\mathrm{Ker}(f)(i,j) \iff f_i = f_j.$$

**Proposition 2.2.** $\mathrm{Ker}(f)$ is an equivalence relation on $[n]$; its classes are the nonempty fibres of $f$, transported to the index set. Two tuples $f : [n] \to A$ and $g : [n] \to B$ satisfy $\mathrm{Ker}(f) = \mathrm{Ker}(g)$ if and only if $f_i = f_j \iff g_i = g_j$ for all $i, j$.

*Proof.* Reflexivity, symmetry and transitivity are those of equality in $A$. The second statement is the pointwise reading of equality of relations. $\square$

**Proposition 2.3 (Invariance).** If $\sigma : A \to B$ is injective then $\mathrm{Ker}(\sigma \circ f) = \mathrm{Ker}(f)$. In particular, for the action of the symmetric group $\mathrm{Sym}(A)$ on $A^{[n]}$ by post-composition, $\mathrm{Ker}$ is a $\mathrm{Sym}(A)$-invariant.

*Proof.* $\sigma(f_i) = \sigma(f_j)$ implies $f_i = f_j$ by injectivity, and conversely by applying $\sigma$. $\square$

### 2.2 The canonical form

Equivalence relations are awkward as data. We replace them by a tuple of integers.

**Definition 2.4 (Canonical form).** Let $A$ have decidable equality. For $f : [n] \to A$ set
$$\mathrm{canon}(f)_i \;=\; \min\{\, j \in [n] : f_j = f_i \,\},$$
the least index in the fibre of $i$. (The minimum is over a nonempty set, since $i$ itself qualifies.)

Thus $\mathrm{canon}(f)$ labels each block of the kernel partition by its least element. For example, $(\text{b},\text{r},\text{g},\text{b},\text{r}) \mapsto (0,1,2,0,1)$ and $(7,7,4,7,4) \mapsto (0,0,2,0,2)$.

**Proposition 2.5 (Calculus of $\mathrm{canon}$).** For all $f, g$ and all $i, j$:

1. $f_{\mathrm{canon}(f)_i} = f_i$ and $\mathrm{canon}(f)_i \le i$.
2. $\mathrm{canon}(f)_i = c$ if and only if $f_c = f_i$ and $c \le j$ for every $j$ with $f_j = f_i$.
3. $f_i = f_j \iff \mathrm{canon}(f)_i = \mathrm{canon}(f)_j$; hence $\mathrm{Ker}(\mathrm{canon}(f)) = \mathrm{Ker}(f)$.
4. $\mathrm{canon}(f) = \mathrm{canon}(g) \iff \mathrm{Ker}(f) = \mathrm{Ker}(g)$.
5. $\mathrm{canon}$ is idempotent: $\mathrm{canon}(\mathrm{canon}(f)) = \mathrm{canon}(f)$, and $\mathrm{canon}(f)_{\mathrm{canon}(f)_i} = \mathrm{canon}(f)_i$.
6. If $\sigma$ is injective then $\mathrm{canon}(\sigma \circ f) = \mathrm{canon}(f)$; in particular $\mathrm{canon}$ is a $\mathrm{Sym}(A)$-invariant.
7. If $f$ is injective then $\mathrm{canon}(f) = \mathrm{id}$, the *discrete* pattern.

*Proof sketch.* (1) and (2) are immediate from the definition of a least element. (3): if $f_i = f_j$ then the two fibres coincide, hence so do their minima; conversely apply $f$ to $\mathrm{canon}(f)_i = \mathrm{canon}(f)_j$ and use (1). (4): the forward direction follows from (3) applied to both sides; the converse builds $\mathrm{canon}(g)_i$ as a least element for $f$ using Proposition 2.2. (5) is (4) applied with $g = \mathrm{canon}(f)$, using (3). (6) is (4) plus Proposition 2.3. (7): injectivity makes each fibre a singleton. $\square$

**Definition 2.6 (Patterns).** $P_n$ is the set of tuples $p : [n] \to [n]$ with $\mathrm{canon}(p) = p$; equivalently the image of $\mathrm{canon}$ on $[n]^{[n]}$. Elements of $P_n$ are called *patterns of length $n$*; classically they are the **restricted growth strings**: $p_0 = 0$ and $p_{i} \le 1 + \max_{j<i} p_j$.

By Proposition 2.5(5)–(6), every tuple over any alphabet with decidable equality has its canonical form in $P_n$, and $P_n$ is exactly the fixed-point set of the idempotent $\mathrm{canon}$.

---

## 3. The completeness theorem

Invariance (Proposition 2.3) says the kernel cannot distinguish tuples in the same orbit. Completeness is the converse, and it requires finiteness of the alphabet.

**Theorem 3.1 (Completeness).** Let $B$ be a finite set with decidable equality and let $f, g : [n] \to B$. Then
$$\bigl(\exists\, \sigma \in \mathrm{Sym}(B),\ \sigma \circ f = g\bigr) \iff \mathrm{Ker}(f) = \mathrm{Ker}(g) \iff \mathrm{canon}(f) = \mathrm{canon}(g).$$

*Proof sketch.* The implication from left to right is Proposition 2.3. Conversely, assume $f_i = f_j \iff g_i = g_j$ for all $i,j$. Define a map $e$ from the image of $f$ to the image of $g$ by choosing, for each $x \in \mathrm{im}(f)$, an index $i$ with $f_i = x$ and setting $e(x) = g_i$. The hypothesis makes this independent of the chosen index: if $f_i = f_{i'}$ then $g_i = g_{i'}$. The symmetric construction in the other direction is inverse to it, again by the hypothesis, so $e : \mathrm{im}(f) \to \mathrm{im}(g)$ is a bijection. Since $B$ is finite, the complements $B \setminus \mathrm{im}(f)$ and $B \setminus \mathrm{im}(g)$ have equal cardinality, so $e$ extends to a permutation $\sigma \in \mathrm{Sym}(B)$. By construction $\sigma(f_i) = g_i$ for every $i$. The second equivalence is Proposition 2.5(4). $\square$

**Remark 3.2.** Finiteness is essential only for the extension step. Over an infinite alphabet the statement holds under the additional hypothesis that the complements of the two images are equinumerous; the kernel alone remains a complete invariant for the *monoid* of injections but not for the group of permutations.

**Corollary 3.3 (Effective classification).** Orbit equivalence of tuples over a finite alphabet is decided by computing two canonical forms and comparing them entrywise — no search over $|B|!$ permutations is required.

---

## 4. Enumeration: patterns are counted by the Bell numbers

Let $B_n$ denote the Bell numbers, defined by the recursion
$$B_0 = 1, \qquad B_{n+1} = \sum_{i=0}^{n} \binom{n}{i}\, B_{n-i}. \tag{4.1}$$

**Theorem 4.1 (Bell enumeration).** For every $n \ge 0$, $|P_n| = B_n$. Equivalently, for every finite index set $I$ the number of equivalence relations on $I$ (equivalently, of set partitions of $I$) is $B_{|I|}$.

The first values are $|P_0|,\dots,|P_5| = 1, 1, 2, 5, 15, 52$, agreeing with the classical sequence.

*Proof sketch.* Write $K(I)$ for the number of equivalence relations on a finite set $I$, and $K(n) = K([n])$.

*Step 1 (patterns $\leftrightarrow$ relations).* Sending a pattern $p$ to the relation $i \sim j \iff p_i = p_j$ is injective on $P_n$ (a pattern is recovered from its relation as the least-element labelling) and surjective onto equivalence relations (label each class by its minimum). Hence $|P_n| = K(n)$.

*Step 2 (transport).* $K(I)$ depends only on $|I|$: a bijection $I \to J$ conjugates equivalence relations bijectively.

*Step 3 (the adjoined point).* Let $I^+ = I \sqcup \{\star\}$. An equivalence relation on $I^+$ is the same data as a pair: the set $s \subseteq I$ of points equivalent to $\star$, together with an equivalence relation on $I \setminus s$. Indeed, given $\rho$ on $I^+$, take $s$ to be the block of $\star$ intersected with $I$ and restrict $\rho$ to the complement; conversely, given $(s, r)$, glue $s \cup \{\star\}$ into a single block and use $r$ elsewhere. The two constructions are mutually inverse. Hence
$$K(I^+) = \sum_{s \subseteq I} K(I \setminus s).$$

*Step 4 (binomial regrouping).* Grouping the subsets $s$ by cardinality $k$, of which there are $\binom{n}{k}$ when $|I| = n$, and using Step 2:
$$K(n+1) = \sum_{k=0}^{n} \binom{n}{k} K(n-k),$$
which is exactly recursion (4.1). With $K(0) = 1$, strong induction gives $K(n) = B_n$. $\square$

**Corollary 4.2.** For every finite set $I$ with decidable equality, the number of equivalence relations on $I$ is $B_{|I|}$; and $P_n$ is a system of representatives for tuples of length $n$ modulo renaming, over any sufficiently large alphabet.

---

## 5. The Stirling refinement

**Definition 5.1.** For a pattern $p \in P_n$, its *block count* $\mathrm{nb}(p)$ is the number of distinct values it takes; equivalently, the number of blocks of the corresponding partition. Note $\mathrm{nb}(p) \le n$. Define
$$S(n,k) \;=\; \#\{\, p \in P_n : \mathrm{nb}(p) = k \,\}.$$

**Proposition 5.2 (Row sums).** $\displaystyle\sum_{k=0}^{n} S(n,k) = |P_n| = B_n$.

*Proof.* Partition $P_n$ by the value of $\mathrm{nb}$, which lies in $\{0,\dots,n\}$, and apply Theorem 4.1. $\square$

**Proposition 5.3 (Boundary values).** $S(n,k) = 0$ for $k > n$; $S(n,n) = 1$ (only the discrete pattern has $n$ blocks); $S(0,0) = 1$; $S(n+1, 0) = 0$; $S(n+1, 1) = 1$ (only the constant pattern).

### 5.1 The recursion

**Theorem 5.4 (Stirling recursion).** For all $n, k \ge 0$,
$$S(n+1, k+1) \;=\; S(n,k) \;+\; (k+1)\, S(n, k+1).$$

*Proof sketch.* Split the patterns of length $n+1$ with $k+1$ blocks according to whether the last position is a singleton block.

*Case A: the last position is its own block.* Deleting it gives a bijection onto patterns of length $n$ with $k$ blocks. Explicitly, restriction $p \mapsto (p_0, \dots, p_{n-1})$ and extension $q \mapsto (q_0, \dots, q_{n-1}, n)$ are mutually inverse; one checks that restriction of a pattern is again a pattern (the least-element labelling of a block not containing the last position is unchanged) and that extension of a pattern by a fresh label is again a pattern.

*Case B: the last position joins an existing block.* Then the restriction $q$ is a pattern of length $n$ with $k+1$ blocks, and the extra datum is which of its $k+1$ blocks the new point joins, i.e. which of the $k+1$ block labels is assigned to position $n$. This is a $(k+1)$-to-one correspondence onto the patterns of length $n$ with $k+1$ blocks. Summing the fibres gives $(k+1)S(n,k+1)$.

Adding the two cases gives the identity. $\square$

Together with the boundary values, Theorem 5.4 determines the whole triangle; e.g. $S(5,3) = S(4,2) + 3 S(4,3) = 7 + 3\cdot 6 = 25$.

### 5.2 Closed forms

**Theorem 5.5 (Two blocks).** $S(n+1, 2) = 2^n - 1$.

*Proof sketch.* A pattern of length $n+1$ with two blocks is determined by the block $s$ containing position $0$; $s$ may be any subset containing $0$ other than the whole index set, of which there are $2^n - 1$. Formally, one shows that $s \mapsto$ (the pattern that is $0$ on $s$ and constant on the complement) and $p \mapsto$ (the block of $0$) are mutually inverse between $P_{n+1} \cap \{\mathrm{nb} = 2\}$ and $\{s : 0 \in s,\ s \ne [n+1]\}$. $\square$

**Corollary 5.6.** $2^n \le B_{n+1}$.

*Proof.* $B_{n+1} \ge S(n+1,1) + S(n+1,2) = 1 + (2^n - 1)$. $\square$

**Theorem 5.7 (First subdiagonal).** $S(n+1, n) = \binom{n+1}{2}$.

*Proof sketch.* Induction using Theorem 5.4: $S(n+2,n+1) = S(n+1,n) + (n+1) S(n+1,n+1) = \binom{n+1}{2} + (n+1) = \binom{n+2}{2}$ by Pascal's rule. Combinatorially: a pattern of length $n+1$ with $n$ blocks merges exactly one pair of positions. $\square$

**Theorem 5.8 (Second subdiagonal).** $S(n+2, n) = \binom{n+2}{3} + 3\binom{n+2}{4}$.

*Proof sketch.* Induction from Theorem 5.7 and the recursion, using the arithmetic identity $3\binom{n+2}{3} = n \binom{n+2}{2}$ (itself a consequence of the absorption identity and Pascal's rule). Combinatorially, a pattern with two "defects" either has one block of size $3$ ($\binom{n+2}{3}$ choices) or two blocks of size $2$ ($3\binom{n+2}{4}$ choices, the factor $3$ counting the pairings of four chosen points). $\square$

**Theorem 5.9 (Columns $k = 3, 4, 5$).** For all $n \ge 0$,
$$6\,S(n,3) = 3^n - 3\cdot 2^n + 3,$$
$$24\,S(n,4) = 4^n - 4\cdot 3^n + 6\cdot 2^n - 4,$$
$$120\,S(n,5) = 5^n - 5\cdot 4^n + 10\cdot 3^n - 10\cdot 2^n + 5.$$

*Proof sketch.* Each is proved by induction on $n$, feeding the previous column into the recursion $S(n+1,k+1) = S(n,k) + (k+1)S(n,k+1)$; the base case $k > n$ gives $0$. These are the inclusion–exclusion formulas $k!\,S(n,k) = \sum_{j}(-1)^j \binom{k}{j}(k-j)^n$ for $k \le 5$, obtained here without inclusion–exclusion. $\square$

### 5.3 Tables and Bell values

The recursion and closed forms give complete rows well beyond brute-force range:

| $n \backslash k$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | $B_n$ |
|---|---|---|---|---|---|---|---|---|---|---|
| 3 | 0 | 1 | 3 | 1 | | | | | | 5 |
| 4 | 0 | 1 | 7 | 6 | 1 | | | | | 15 |
| 5 | 0 | 1 | 15 | 25 | 10 | 1 | | | | 52 |
| 6 | 0 | 1 | 31 | 90 | 65 | 15 | 1 | | | 203 |
| 7 | 0 | 1 | 63 | 301 | 350 | 140 | 21 | 1 | | 877 |
| 8 | 0 | 1 | 127 | 966 | 1701 | 1050 | 266 | 28 | 1 | 4140 |

**Corollary 5.10.** $B_6 = 203$, $B_7 = 877$, $B_8 = 4140$.

### 5.4 Fibres, falling factorials and surjections

**Theorem 5.11 (Fibre size).** Let $B$ be a finite alphabet, $m = |B|$, and let $p \in P_n$ with $\mathrm{nb}(p) = k$. Then the number of tuples $f : [n] \to B$ with $\mathrm{canon}(f) = p$ is the falling factorial
$$m^{\underline{k}} = m(m-1)\cdots(m-k+1).$$

*Proof sketch.* A tuple with canonical form $p$ is exactly the composite of $p$ with an injection from the $k$ blocks of $p$ into $B$: choose the value on each block, all values distinct. The correspondence "tuple $\mapsto$ induced map on blocks" is a bijection onto the set of injections from a $k$-element set into $B$, and there are $m^{\underline{k}}$ of those. $\square$

**Theorem 5.12 (Falling-factorial expansion).** For all $n, m \ge 0$,
$$m^n = \sum_{k=0}^{n} S(n,k)\, m^{\underline{k}}.$$

*Proof.* Count $B^{[n]}$ by fibres of $\mathrm{canon}$ (Theorem 5.11) and group patterns by block count. $\square$

**Theorem 5.13 (Surjection count).** The number of surjections from $[n]$ onto $[k]$ is $k!\,S(n,k)$. In particular the number of surjections $[n] \to [n]$ is $n!$.

*Proof sketch.* A map $f : [n] \to [k]$ is surjective iff its pattern has exactly $k$ blocks; the fibre of $\mathrm{canon}$ over such a pattern has $k^{\underline{k}} = k!$ elements by Theorem 5.11. Summing over the $S(n,k)$ relevant patterns gives the count. The special case $k=n$ forces the discrete pattern, and $S(n,n)=1$. $\square$

---

## 6. Orbit counting over arbitrary alphabets

**Theorem 6.1 (Orbit count, large alphabet).** Let $B$ be finite with $|B| \ge n$. The number of orbits of $\mathrm{Sym}(B)$ acting on $B^{[n]}$ by post-composition is $B_n$.

*Proof.* By Theorem 3.1 the map $f \mapsto \mathrm{canon}(f)$ descends to an injection from the orbit set into $P_n$; by Theorem 5.11 (with $k \le n \le |B|$, so $m^{\underline{k}} > 0$) every pattern is realised, so the injection is onto. Now apply Theorem 4.1. $\square$

**Theorem 6.2 (Orbit count, arbitrary alphabet).** For any finite alphabet $B$,
$$\#\bigl(B^{[n]}/\mathrm{Sym}(B)\bigr) \;=\; \sum_{k=0}^{|B|} S(n,k).$$
This is $B_n$ when $|B| \ge n$, and strictly less than $B_n$ when $|B| < n$.

*Proof sketch.* The same map $f \mapsto \mathrm{canon}(f)$ is a bijection from the orbit set onto the set of patterns with at most $|B|$ blocks: a tuple over $B$ has at most $|B|$ distinct entries, so at most $|B|$ blocks (injectivity and well-definedness are Theorem 3.1); conversely a pattern with $k \le |B|$ blocks is realised by Theorem 5.11. Counting the patterns by block count gives the sum. If $|B| \ge n$ the truncation is harmless since $S(n,k) = 0$ for $k > n$; if $|B| < n$ the term $S(n,n) = 1$ is omitted, so the count is strictly smaller. $\square$

**Proposition 6.3 (Sharpness).** If $|B| < n$ then no tuple $f : [n] \to B$ has the discrete pattern: $\mathrm{canon}(f) \ne \mathrm{id}$. Indeed the image of $\mathrm{canon}(f)$ has at most $|B|$ elements, while the image of $\mathrm{id}$ has $n$.

---

## 7. Growth and congruences for the Bell numbers

### 7.1 Monotonicity

**Theorem 7.1.** $B_n < B_{n+1}$ for $n \ge 1$, and $B_n \le B_{n+1}$ for all $n$. Hence $B$ is monotone, strictly monotone on $[1,\infty)$, and $n \le B_n$.

*Proof sketch.* Appending a fresh singleton block gives an injection $P_n \hookrightarrow P_{n+1}$: $p \mapsto (p_0,\dots,p_{n-1}, n)$. Its image consists of patterns whose last position is a singleton, so the all-in-one-block (constant) pattern of length $n+1$ is not in the image whenever $n \ge 1$. Therefore $|P_n| < |P_{n+1}|$. The linear bound follows by induction. $\square$

### 7.2 Super-multiplicativity

**Theorem 7.2 (Super-multiplicativity).** For all $m,n \ge 0$, $B_m B_n \le B_{m+n}$; and if $m, n \ge 1$ the inequality is strict.

*Proof sketch.* Given equivalence relations $r$ on a set $A$ and $s$ on a disjoint set $C$, define $r \oplus s$ on $A \sqcup C$ by "$x \sim y$ iff both lie in $A$ and $r(x,y)$, or both lie in $C$ and $s(x,y)$". This is an equivalence relation, and $(r,s) \mapsto r \oplus s$ is injective (restrict to each summand to recover $r$ and $s$). Hence $K(A)K(C) \le K(A \sqcup C)$, i.e. $B_m B_n \le B_{m+n}$. If both $A$ and $C$ are nonempty, the total relation on $A \sqcup C$ (one block) has a block meeting both summands, so it is not of the form $r \oplus s$; the injection misses it, and the inequality is strict. $\square$

**Corollary 7.3 (Super-exponential growth).** $B_n^k \le B_{nk}$ for all $n,k$; in particular $2^k = B_2^k \le B_{2k}$.

*Proof.* Induction on $k$ using Theorem 7.2. $\square$

For instance $B_2 B_2 = 4 < 15 = B_4$, so the injection is far from surjective already in the smallest nontrivial case.

### 7.3 Touchard's congruence

**Theorem 7.4 (Touchard).** For every prime $p$ and every $n \ge 0$,
$$B_{p+n} \;\equiv\; B_{n+1} + B_n \pmod{p}.$$

*Proof sketch.* Let $X$ be the set of equivalence relations on the index set $\mathbb{Z}/p \sqcup [n]$; by Theorem 4.1, $|X| = B_{p+n}$. Let the cyclic group $C_p$ of order $p$ act on the index set by $a \cdot (\text{left } x) = \text{left } (x + a)$ and trivially on the right summand; this induces an action on $X$ by transporting relations, since each generator acts by a bijection of the index set.

For an action of a group of prime order $p$ on a finite set, every orbit has size $1$ or $p$, whence
$$|X| \equiv |X^{C_p}| \pmod p .$$

It remains to classify the invariant relations $\rho \in X^{C_p}$. Consider the block $\beta$ of the left point $0$.

*Case A: $\beta$ contains another left point,* say left $d$ with $d \ne 0$. Invariance under the rotation by $d$ then shows that left $x \sim$ left $(x + d)$ for every $x$; since $d$ generates $\mathbb{Z}/p$ (as $p$ is prime), chaining shows that all left points lie in one block. What remains is the induced relation on the right summand together with the datum of which right points lie in that one merged block — that is, exactly an equivalence relation on $[n] \sqcup \{\star\}$, where $\star$ stands for the merged left block. There are $B_{n+1}$ of these, and the correspondence is bijective.

*Case B: $\beta \cap (\text{left points}) = \{0\}$.* Invariance transports this to every left point, so every left point is a singleton block and no left point is related to any right point. What remains is an arbitrary equivalence relation on $[n]$: $B_n$ of these.

Hence $|X^{C_p}| = B_{n+1} + B_n$, and the congruence follows. $\square$

**Corollary 7.5.** For every prime $p$, $B_p \equiv 2 \pmod p$; for $p > 2$ this says $B_p \bmod p = 2$.

*Proof.* Set $n = 0$ in Theorem 7.4 and use $B_1 = B_0 = 1$. $\square$

For example $B_7 = 877 = 7\cdot 125 + 2$. As a second illustration, $p = 5$ and $n = 3$ give $B_8 \equiv B_4 + B_3 = 15 + 5 = 20 \equiv 0 \pmod 5$, so $5 \mid B_8$; consistently $B_8 = 4140 = 5 \cdot 828$, a value obtained independently in §5.3.

---

## 8. Kernel spectra of Diophantine equations

We now attach the invariant to arithmetic.

**Definition 8.1 (Kernel spectrum).** Let $E$ be an equation in $n$ unknowns over $\mathbb{N}$ and let $\mathcal{S}(E) \subseteq \mathbb{N}^{[n]}$ be its solution set. The *kernel spectrum* of $E$ is
$$\mathrm{Spec}(E) \;=\; \{\, \mathrm{canon}(t) : t \in \mathcal{S}(E) \,\} \subseteq P_n .$$
Its *defect* is $B_n - |\mathrm{Spec}(E)|$.

The spectrum is a finite invariant — at most $B_n$ elements — of a generally infinite solution set, and it is invariant under any symmetry of the equation that permutes the values.

For $n = 3$ there are $B_3 = 5$ patterns, which in canonical-form notation are
$$(0,1,2)\ \text{(discrete)},\quad (0,1,1),\quad (0,1,0),\quad (0,0,0),\quad (0,0,2)\ \text{(equal legs)} .$$

### 8.1 The arithmetic obstruction

**Lemma 8.2 (Square multiplier).** Let $k, a, c \in \mathbb{N}$ with $a \ne 0$ and $ka^2 = c^2$. Then $k$ is a perfect square. Conversely, if $k = m^2$ then $k \cdot 1^2 = m^2$.

*Proof sketch.* Let $g = \gcd(a,c)$ (nonzero since $a \ne 0$) and write $a = g a'$, $c = g c'$ with $\gcd(a',c') = 1$. Cancelling $g^2$ gives $k a'^2 = c'^2$. Then $a'^2 \mid c'^2$ while $\gcd(a'^2, c'^2) = 1$, so $a'^2 = 1$, i.e. $a' = 1$ and $k = c'^2$. $\square$

**Corollary 8.3.** $2a^2 = c^2$ has no solution with $a \ne 0$, since $2$ is not a perfect square.

### 8.2 The Pythagorean spectrum

Call $t = (t_0,t_1,t_2) \in \mathbb{N}^3$ a *Pythagorean triple* if $t_0^2 + t_1^2 = t_2^2$ (degenerate solutions are allowed).

**Theorem 8.4 (Kernel spectrum of $a^2+b^2=c^2$).** A pattern $p \in P_3$ is the kernel of some Pythagorean triple over $\mathbb{N}$ if and only if $p \ne (0,0,2)$. Consequently
$$\mathrm{Spec}(a^2+b^2=c^2) = \{(0,1,2),\ (0,1,1),\ (0,1,0),\ (0,0,0)\}, \qquad |\mathrm{Spec}| = 4 = B_3 - 1 .$$
The Pythagorean cone is kernel-deficient of defect exactly one.

*Proof sketch.* *Exclusion.* Suppose $\mathrm{canon}(t) = (0,0,2)$, i.e. $t_0 = t_1$ and $t_2 \ne t_0$. Then $2t_0^2 = t_2^2$. If $t_0 \ne 0$ this contradicts Corollary 8.3; if $t_0 = 0$ then $t_2 = 0 = t_0$, contradicting $t_2 \ne t_0$. Hence $(0,0,2)$ is never realised.

*Realisation.* $(3,4,5)$ has pattern $(0,1,2)$; $(0,1,1)$ has pattern $(0,1,1)$; $(1,0,1)$ has pattern $(0,1,0)$; $(0,0,0)$ has pattern $(0,0,0)$. All four are solutions. Since these exhaust $P_3 \setminus \{(0,0,2)\}$, the spectrum is as claimed. $\square$

**Proposition 8.5 (Positive triples form one class).** Every Pythagorean triple with all entries strictly positive has the discrete pattern $(0,1,2)$.

*Proof sketch.* The legs cannot be equal by Corollary 8.3; a leg cannot equal the hypotenuse, since $t_0 = t_2$ forces $t_1 = 0$. $\square$

### 8.3 Dimensional dependence

**Theorem 8.6 (Equal-legs criterion).** For $k \ge 0$, the equation $\sum_{i<k} x_i^2 = y^2$ has a solution with all $x_i$ equal to a common nonzero value if and only if $k$ is a perfect square.

*Proof.* Setting all legs to $a$ gives $ka^2 = y^2$; apply Lemma 8.2 in both directions. $\square$

**Corollary 8.7 (Dimension threshold).** The equal-legs configuration is impossible for $k = 2$ and $k = 3$, and possible for $k = 4$, realised by $1^2+1^2+1^2+1^2 = 2^2$.

Thus the missing pattern of Theorem 8.4 is not a defect of the invariant but a genuine arithmetic feature of dimension $2$: raise the number of legs to a perfect square and the pattern reappears.

### 8.4 Fermat spectra and a phase transition in the exponent

For an exponent $p$, call $t \in \mathbb{N}^3$ a *Fermat triple of exponent $p$* if $t_0^p + t_1^p = t_2^p$, and write $\mathrm{Spec}(p)$ for the corresponding kernel spectrum. Note $\mathrm{Spec}(2)$ is the Pythagorean spectrum.

**Lemma 8.8 ($2$-adic obstruction).** For $p \ge 2$ and $a \ne 0$, $2a^p \ne c^p$.

*Proof sketch.* Both sides are nonzero. Comparing the exponent of the prime $2$: the left side has $v_2 = 1 + p\, v_2(a)$, the right has $v_2 = p\, v_2(c)$. Hence $p \bigl(v_2(c) - v_2(a)\bigr) = 1$, so $p \mid 1$, contradicting $p \ge 2$. $\square$

**Corollary 8.9.** For every $p \ge 2$ the equal-legs pattern $(0,0,2)$ is not in $\mathrm{Spec}(p)$; hence $\mathrm{Spec}(p) \subseteq \mathrm{Spec}(2)$.

**Proposition 8.10 (Degenerate patterns).** For every $p \ge 1$, the three patterns $(0,1,1)$, $(0,1,0)$, $(0,0,0)$ lie in $\mathrm{Spec}(p)$, realised by $(0,1,1)$, $(1,0,1)$, $(0,0,0)$.

**Proposition 8.11 (All five at $p=1$).** $\mathrm{Spec}(1) = P_3$. Indeed $1 + 1 = 2$ realises the equal-legs pattern and $3 + 4 = 7$ the discrete one.

So the deficiency is strictly a $p \ge 2$ phenomenon: a phase transition in the exponent.

**Theorem 8.12 (Discrete pattern $=$ positive solvability).** For $p \ge 2$, the discrete pattern $(0,1,2)$ lies in $\mathrm{Spec}(p)$ if and only if there exist $x,y,z > 0$ with $x^p + y^p = z^p$.

*Proof sketch.* ($\Leftarrow$) Let $x,y,z > 0$ solve the equation. Then $x \ne y$ by Lemma 8.8, and $x \ne z$, $y \ne z$ since the other leg is positive. So the triple is injective and its pattern is discrete.
($\Rightarrow$) If some Fermat triple $t$ has discrete pattern, its three entries are distinct; the hypotenuse $t_2$ is then nonzero (else $t_0 = t_1 = 0$), and each leg is nonzero (if $t_0 = 0$ then $t_1 = t_2$, contradicting distinctness). Hence a positive solution exists. $\square$

**Theorem 8.13 (Kernel-theoretic Fermat's Last Theorem).** Let $p \ge 2$. Then
$$|\mathrm{Spec}(p)| = 3 \iff x^p + y^p = z^p \text{ has no solution with } x,y,z > 0,$$
$$|\mathrm{Spec}(p)| = 4 \iff x^p + y^p = z^p \text{ has a solution with } x,y,z > 0 .$$
In the first case $\mathrm{Spec}(p) = \{(0,1,1),(0,1,0),(0,0,0)\}$; in the second, $\mathrm{Spec}(p) = \{(0,1,2),(0,1,1),(0,1,0),(0,0,0)\}$.

*Proof.* By Corollary 8.9 the spectrum is contained in the four-element Pythagorean spectrum, and by Proposition 8.10 it contains the three degenerate patterns. So the only question is whether $(0,1,2)$ belongs, and Theorem 8.12 answers it. The two cardinalities $3$ and $4$ are therefore mutually exclusive and exhaust the possibilities. $\square$

**Corollary 8.14.** $|\mathrm{Spec}(2)| = 4$, witnessed by $(3,4,5)$. For $p \ge 3$, $|\mathrm{Spec}(p)| = 3$ — this is precisely Fermat's Last Theorem, in the form "the kernel spectrum of the Fermat equation of exponent $p \ge 3$ omits the discrete pattern".

The spectrum therefore compresses an entire family of Diophantine problems into the question of which of five combinatorial types occur, and it does so faithfully: no information about positive solvability is lost.

---

## 9. Algorithms

**Canonicalisation.** Computing $\mathrm{canon}(f)$ naively costs $O(n^2)$ comparisons (for each $i$, scan for the least $j$ with $f_j = f_i$). With a hash map from values to first occurrence it is $O(n)$ expected time and $O(n)$ space: scan left to right, and for each entry either look up its first occurrence or record the current index. Orbit equivalence of two tuples is then decided in linear time by comparing canonical forms (Corollary 3.3). This is the standard symmetry-reduction routine, here with a completeness proof attached.

**Pattern enumeration.** Patterns of length $n$ are exactly the restricted growth strings: $p_0 = 0$ and $p_i \le 1 + \max_{j<i} p_j$. Generating them by depth-first search, extending a prefix with maximum label $m$ by any of $0,1,\dots,m+1$, enumerates $P_n$ with no rejection: cost $O(n B_n)$ time and $O(n)$ space, optimal up to the output size. Refining the generation by the eventual number of blocks gives the Stirling counts directly.

**Bell and Stirling tables.** Rather than enumerate, one can iterate the recursion of Theorem 5.4 to fill the $n \times n$ Stirling triangle in $O(n^2)$ integer operations, then take row sums for the Bell numbers. (The classical Bell triangle is an equivalent $O(n^2)$ scheme.) This is how the values $B_6 = 203$, $B_7 = 877$, $B_8 = 4140$ of §5.3 are obtained without touching the $4140$ objects they count.

**Kernel spectra.** For an equation in $n$ unknowns, the spectrum is computed by (i) enumerating the $B_n$ patterns; (ii) for each pattern, substituting a single variable per block and asking whether the resulting reduced equation has a solution with the block-variables pairwise distinct. Step (ii) is exactly where arithmetic enters — for the Pythagorean case, the reduced equations are $2a^2 = c^2$ (unsolvable) and its siblings. The bookkeeping is finite and mechanical; the difficulty is concentrated in finitely many reduced Diophantine problems.

---

## 10. Discussion, applications and future directions

### 10.1 What the invariant buys

Three features distinguish kernel patterns from generic invariants. First, **completeness**: over a finite alphabet, nothing else is needed to decide the renaming-orbit question. Second, **computability**: the invariant is a tuple of small integers, computed in linear time, so it can be used as a dictionary key. Third, **exact enumeration**: the invariant's own state space is the Bell numbers, refined by the Stirling triangle, with growth and congruence properties one can prove directly from the combinatorial definitions.

The last point is worth emphasising. Once $S(n,k)$ is *defined* as a count of patterns, the recursion, the closed forms, the falling-factorial expansion, the surjection count, super-multiplicativity, and Touchard's congruence are all consequences of manipulating patterns, not of manipulating formulas. In particular, Touchard's congruence — usually derived from the umbral/Artin–Schreier identity $B^p \equiv B + 1$ in $\mathbb{F}_p[x]/(x^p - x - 1)$ — falls out here from a single application of the orbit–fixed-point congruence for a cyclic group of prime order.

### 10.2 Applications

*Symmetry reduction.* In model checking and constraint programming, states that differ only by permuting interchangeable components should be identified. Kernel canonicalisation is the correct, complete reduction when the only structure on the components is equality, and Theorem 6.2 quantifies exactly how much compression to expect: from $|B|^n$ states down to $\sum_{k\le |B|} S(n,k)$.

*Databases and privacy.* The kernel of a row is precisely the information that survives pseudonymisation of the field values. Theorem 3.1 says this is all that survives, so it delimits what an adversary can learn from a renamed dataset; the Bell numbers count the possible leak profiles.

*Diophantine bookkeeping.* Kernel spectra provide a coarse but sharp finite invariant of solution sets. Theorem 8.13 shows the invariant is not toy: it is faithful enough to encode a positive-solvability question exactly. Theorem 8.6 shows it detects genuine dimensional arithmetic.

### 10.3 Future directions

*The following research programme extends the results above; each item is stated so that it can be attacked directly.*

**Status of the previous cycle.** Five earlier conjectures are now settled and are no longer open problems.

* **C1 (Stirling recursion and closed forms) — proved.** The recursion $S(n+1,k+1) = (k+1)S(n,k+1) + S(n,k)$ holds for the *combinatorially defined* $S(n,k) = \#\{\text{patterns of length } n \text{ with } k \text{ blocks}\}$; $S(n+1,2) = 2^n - 1$ and $S(n+1,n) = \binom{n+1}{2}$ are the advertised closed forms, and the row sums evaluate to $B_6 = 203$, $B_7 = 877$, $B_8 = 4140$.
* **C4 (orbit counting over a small alphabet) — proved.** The orbits of the symmetric group of $\beta$ acting on $\beta^{[n]}$ number $\sum_{k \le |\beta|} S(n,k)$ for *every* finite alphabet $\beta$, with the strict inequality against $B_n$ holding exactly when $|\beta| < n$. The companion identity $m^n = \sum_k S(n,k)\, m^{\underline{k}}$ is proved alongside.
* **C5 (growth of the Bell numbers) — partially proved.** The bound $2^n \le B_{n+1}$ now follows from the two-block count, complementing strict monotonicity from $n=1$, monotonicity, and $n \le B_n$. In the present cycle this was strengthened to *super-multiplicativity*, $B_m B_n \le B_{m+n}$, strict for positive $m,n$, with the consequences $B_n^k \le B_{nk}$ and $2^k \le B_{2k}$. The proof is the injection sending a pair of equivalence relations on $A$ and on $B$ to the equivalence relation on $A \sqcup B$ no block of which crosses the two summands; the total relation witnesses strictness. The sharp asymptotics are folded into **D1** below.
* **C2, C3 (kernel spectra of Diophantine equations)** are refined into **D3** and **D4**.

**D1. Log-concavity and unimodality of the kernel-block statistic.** *Conjecture.* For all $n$ and all $1 \le k < n$, the pattern counts satisfy $S(n,k)^2 \ge S(n,k-1)\, S(n,k+1)$; consequently each row of the triangle is unimodal, with a single peak whose position is asymptotically $n/\log n$. A proof would also sharpen the growth results: log-concavity of the rows plus the row-sum identity yields the classical asymptotic $B_n = n^{n(1+o(1))/\log n}$, upgrading the current super-multiplicative bounds to the true order of growth.

**D2. Higher congruences.** Extend Touchard's congruence to prime powers and to iterated form: prove $B_{p^m + n} \equiv m\,B_{n} + B_{n+1} \pmod p$, and investigate the period of the Bell numbers modulo $p$ (conjecturally $(p^p-1)/(p-1)$), using the same cyclic-action machinery on equivalence relations of extended index sets.

**D3. Kernel spectra in higher arity.** Compute $\mathrm{Spec}$ for the $n$-variable equations $\sum_{i<k} x_i^m = y^m$ for all $k$ and $m$, generalising both the equal-legs criterion and the $2$-adic obstruction. The expected answer is a defect governed by which multiplicities $k$ are $m$-th powers, and by local obstructions at the primes dividing $k$.

**D4. Spectral rigidity of Diophantine families.** Determine which subsets of $P_n$ arise as kernel spectra of polynomial equations in $n$ variables over $\mathbb{N}$. Every spectrum is closed under nothing obvious, so the question is genuinely open even for $n = 3$; a classification would say exactly which "coincidence profiles" are arithmetically realisable.

**D5. Kernel patterns as a complexity measure.** For a fixed equation, study the pattern of solutions as a function of a height bound: how quickly does the finite spectrum stabilise, and can the stabilisation height be bounded effectively? This links the invariant to effective methods in Diophantine geometry.

---

## 11. Conclusion

The equality pattern of a tuple is the exact residue of the tuple under renaming of its entries: a complete invariant for the symmetric group action over a finite alphabet, computed in linear time by the least-element labelling. Its own combinatorics is the theory of set partitions — Bell numbers as the total count, Stirling numbers of the second kind as the refinement by block count, with recursion, closed forms, falling-factorial expansions, surjection counts, strict super-multiplicativity, and Touchard's congruence all obtainable by direct manipulation of patterns. Applied to Diophantine equations, the invariant yields kernel spectra: the Pythagorean equation realises exactly four of the five patterns of a triple, missing the equal-legs pattern because $2$ is not a square; the same obstruction shows the missing pattern returns in dimension $4$; and for the Fermat equations the spectrum has three elements or four according as the equation has no positive solution or some positive solution — Fermat's Last Theorem, restated as a count.
