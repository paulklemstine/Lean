# Kernel Patterns: Complete Invariants of Tuples, the Bell Numbers, and the Combinatorial Geometry of the Braid Arrangement

**Author:** Aristotle
**Date:** 2026-08-26

---

## Abstract

For a tuple $x=(x_1,\dots,x_n)$ with entries in a set $X$ we define its *kernel pattern* $\operatorname{pat}(x)$ by $\operatorname{pat}(x)_i=\min\{j: x_j=x_i\}$, the first-occurrence representative of the value at position $i$. We prove that the kernel pattern is a **complete invariant** of the diagonal action of the symmetric group $\operatorname{Sym}(X)$ on $X^n$ when $X$ is finite: two tuples lie in the same orbit if and only if they have the same kernel pattern. We show the result is sharp — for a proper subgroup the kernel is no longer complete — and that the set of realisable patterns *stabilises* once $|X| \ge n$.

We then count. Kernel patterns of length $n$ are in canonical bijection with equivalence relations on an $n$-element index set; the patterns using exactly $k$ distinct values are counted by the Stirling number of the second kind $S(n,k)$, and the patterns in total by the Bell number $B_n$. Both counts are obtained by an explicit delete-the-last-index recursion on the pattern model, giving as a by-product the identity $B_n=\sum_{k=0}^n S(n,k)$ relating two independently-defined recursions. The initial segment $1,1,2,5,15,52$ (OEIS A000110) is also confirmed by exhaustive enumeration of the fixed points of $\operatorname{pat}$.

Finally we give the geometry. The flat of the braid arrangement $\mathcal{A}_{n-1}=\{v_i=v_j\}_{i<j}$ in $\mathbb{R}^n$ cut out by a tuple $x$ depends on $x$ only through $\operatorname{pat}(x)$, and does so faithfully; inclusion of flats is reverse refinement of kernels; the dimension of a flat is its number of blocks. Hence the intersection lattice of the braid arrangement has exactly $B_n$ elements, with $S(n,k)$ of dimension $k$. Refining the pattern by the *ordering* of its blocks yields the *ordered pattern* $\operatorname{rank}(v)$, a complete invariant of the **face** of the arrangement. Each flat with $k$ blocks carries exactly $k!$ faces, so the number of faces is the Fubini number $\sum_{k=0}^n S(n,k)\,k!$, giving $1,1,3,13,75,541$ (OEIS A000670); the chambers are the faces of injective tuples, of which there are $n!$; and both $n!$ and $B_n$ are bounded above by the Fubini number.

**Keywords:** kernel pattern, set partition, Bell numbers, Stirling numbers of the second kind, braid arrangement, intersection lattice, faces and chambers, ordered Bell numbers, complete invariant.

---

## 1. Introduction

### 1.1 The question

Fix a set $X$ and an integer $n \ge 0$. The symmetric group $\operatorname{Sym}(X)$ acts on the configuration space $X^n$ of $n$-tuples *diagonally*, by relabelling all coordinates at once:

$$\sigma \cdot (x_1,\dots,x_n) = (\sigma x_1,\dots,\sigma x_n).$$

The orbit classification problem for this action asks: what data about a tuple survives an arbitrary relabelling of the alphabet, and is that data enough to reconstruct the orbit?

The answer is intuitively clear. A relabelling by a bijection can neither merge two distinct values nor split one value into two, so the only surviving datum is the *coincidence structure* of the tuple: the equivalence relation

$$i \sim_x j \iff x_i = x_j$$

on the index set $\{1,\dots,n\}$, called the **kernel** of $x$. What is not a priori clear is that the kernel is *sufficient* — that any two tuples with the same kernel are related by a global relabelling. This paper establishes that, quantifies it, and shows that the resulting classification is simultaneously an algebraic, a combinatorial and a geometric statement.

### 1.2 Canonical form

Rather than manipulate equivalence relations directly, it is convenient to encode them by a canonical tuple.

**Definition 1.1 (Kernel pattern).** Let $X$ be a set with decidable equality and $x : \{1,\dots,n\} \to X$ a tuple. Its **kernel pattern** is the tuple $\operatorname{pat}(x) : \{1,\dots,n\} \to \{1,\dots,n\}$ given by

$$\operatorname{pat}(x)_i \;=\; \min\{\,j \in \{1,\dots,n\} : x_j = x_i \,\}.$$

The minimum is over a nonempty set (it contains $i$), so $\operatorname{pat}$ is well defined and $\operatorname{pat}(x)_i \le i$.

**Example.** For $x = (\text{r},\text{b},\text{r},\text{g},\text{b})$ one has $\operatorname{pat}(x) = (1,2,1,4,2)$; the corresponding kernel is $\{\{1,3\},\{2,5\},\{4\}\}$.

The pattern is the "first-occurrence normal form" of the tuple: each entry is replaced by the position at which its value first appeared. The rest of the paper is an exploration of how much this object knows.

### 1.3 Overview of results

- **§2** establishes the elementary calculus of $\operatorname{pat}$: it records the kernel faithfully, is invariant under injective post-composition, is idempotent, and its fixed points are exactly the patterns.
- **§3** proves the Completeness Theorem for finite alphabets, its sharpness, and stabilisation.
- **§4** identifies patterns with set partitions and proves the counting theorems: $S(n,k)$ patterns with $k$ blocks, $B_n$ patterns in all, and the identity $B_n = \sum_k S(n,k)$.
- **§5** gives the geometry of flats in the braid arrangement.
- **§6** refines to ordered patterns, faces and chambers, and derives the Fubini count.
- **§7** presents the algorithms; **§8** discusses applications; **§9** future directions.

Throughout, $[n]$ denotes $\{1,\dots,n\}$ (empty when $n=0$), $B_n$ the $n$-th Bell number and $S(n,k)$ the Stirling number of the second kind.

---

## 2. The calculus of kernel patterns

We collect the basic properties. All are elementary, and all are used repeatedly.

**Lemma 2.1 (Value stability).** For every $i$, $x_{\operatorname{pat}(x)_i} = x_i$.

*Proof.* $\operatorname{pat}(x)_i$ is by construction a member of $\{j : x_j = x_i\}$. $\square$

**Lemma 2.2 (Faithfulness).** $\operatorname{pat}(x)_i = \operatorname{pat}(x)_j \iff x_i = x_j$.

*Proof.* ($\Rightarrow$) By Lemma 2.1, $x_i = x_{\operatorname{pat}(x)_i} = x_{\operatorname{pat}(x)_j} = x_j$. ($\Leftarrow$) If $x_i = x_j$ then the two sets $\{k : x_k = x_i\}$ and $\{k : x_k = x_j\}$ coincide, hence so do their minima. $\square$

Thus $\operatorname{pat}(x)$ determines, and is determined by, the kernel of $x$ — the map from kernels to patterns is injective, and the next lemma says it is a *function of the kernel only*.

**Lemma 2.3 (Kernel congruence).** If $x : [n]\to X$ and $y:[n]\to Y$ satisfy $x_k = x_l \iff y_k=y_l$ for all $k,l$, then $\operatorname{pat}(x)=\operatorname{pat}(y)$.

*Proof.* Fix $i$. By Lemma 2.1, $y_{\operatorname{pat}(y)_i} = y_i$, which by hypothesis transfers to $x_{\operatorname{pat}(y)_i} = x_i$; hence $\operatorname{pat}(y)_i$ lies in the set whose minimum defines $\operatorname{pat}(x)_i$, giving $\operatorname{pat}(x)_i \le \operatorname{pat}(y)_i$. The symmetric argument gives the reverse inequality. $\square$

**Theorem 2.4 (Invariance).** If $f : X \to Y$ is injective then $\operatorname{pat}(f \circ x) = \operatorname{pat}(x)$. In particular $\operatorname{pat}(\sigma\circ x) = \operatorname{pat}(x)$ for every permutation $\sigma$ of $X$: the kernel pattern is a $\operatorname{Sym}(X)$-invariant.

*Proof.* Injectivity gives $f(x_k) = f(x_l) \iff x_k = x_l$; apply Lemma 2.3. $\square$

**Lemma 2.5 (Idempotence).** $\operatorname{pat}(\operatorname{pat}(x)) = \operatorname{pat}(x)$.

*Proof.* Lemma 2.2 says the kernels of $x$ and of $\operatorname{pat}(x)$ coincide; apply Lemma 2.3. $\square$

So $\operatorname{pat}$ is a retraction of $X^n$ onto the set of its own fixed points. The fixed points admit a purely local description.

**Proposition 2.6 (Pointwise characterisation).** For $p : [n]\to[n]$,

$$\operatorname{pat}(p) = p \iff \big(\forall i,\ p_i \le i\big) \ \wedge\ \big(\forall i,\ p_{p_i} = p_i\big).$$

*Proof.* ($\Rightarrow$) Both conditions hold for any pattern: $\operatorname{pat}(x)_i \le i$ by definition, and $\operatorname{pat}(x)_{\operatorname{pat}(x)_i} = \operatorname{pat}(x)_i$ by Lemma 2.2 applied to Lemma 2.1. ($\Leftarrow$) Suppose $p$ is weakly regressive and idempotent. Then $p_{p_i}=p_i$ exhibits $p_i$ as an element of $\{j : p_j = p_i\}$, whence $\operatorname{pat}(p)_i \le p_i$. Conversely, any $j$ with $p_j = p_i$ satisfies $p_i = p_j \le j$, so $p_i$ is a lower bound for that set and therefore $p_i \le \operatorname{pat}(p)_i$. $\square$

**Definition 2.7.** Write $\mathcal{P}_{n,m}$ for the set of patterns of $n$-tuples with values in an $m$-letter alphabet, and $\mathcal{P}_n := \mathcal{P}_{n,n}$.

**Proposition 2.8 (Membership test).** $p \in \mathcal{P}_{n,m}$ if and only if $\operatorname{pat}(p) = p$ and $|\operatorname{im}(p)| \le m$.

*Proof.* If $p = \operatorname{pat}(x)$ then $p$ is idempotent by Lemma 2.5, and the map $j \mapsto x_j$ is injective on $\operatorname{im}(\operatorname{pat}(x))$ (its members are fixed by $\operatorname{pat}(x)$, so Lemma 2.2 applies), so $|\operatorname{im}(p)| \le |\operatorname{im}(x)| \le m$. Conversely, given such a $p$, choose an injection $e$ from $\operatorname{im}(p)$ into the alphabet; then $e \circ p$ has the same kernel as $p$, so $\operatorname{pat}(e\circ p) = \operatorname{pat}(p) = p$ by Lemma 2.3. $\square$

**Corollary 2.9 (Stabilisation).** If $n \le m$ then $\mathcal{P}_{n,m} = \mathcal{P}_n$.

*Proof.* An $n$-tuple has at most $n$ distinct entries, so the cardinality constraint in Proposition 2.8 is vacuous once $m \ge n$. $\square$

Stabilisation is what makes the classification alphabet-independent: enlarging the alphabet beyond $n$ letters creates no new coincidence structure.

---

## 3. Completeness of the invariant

**Theorem 3.1 (Reconstruction).** Let $X$ be a **finite** set and $x,y : [n] \to X$ with $\operatorname{pat}(x) = \operatorname{pat}(y)$. Then there is a permutation $\sigma \in \operatorname{Sym}(X)$ with $\sigma \circ x = y$.

*Proof.* By Lemma 2.2, the hypothesis is equivalent to

$$(\star)\qquad x_i = x_j \iff y_i = y_j \quad\text{for all } i,j.$$

Let $S = \operatorname{im}(x)$ and $T = \operatorname{im}(y)$. Define $\varphi : S \to T$ by choosing, for $a \in S$, some index $i_a$ with $x_{i_a}=a$ and setting $\varphi(a) = y_{i_a}$. This is well defined and injective: if $y_{i_a} = y_{i_b}$ then $x_{i_a}=x_{i_b}$ by $(\star)$, i.e. $a=b$; conversely if $a=b$ the two chosen indices satisfy $x_{i_a}=x_{i_b}$, hence $y_{i_a}=y_{i_b}$ by $(\star)$, so the value does not depend on the choice. It is surjective: any $b \in T$ is $y_j$ for some $j$, and $\varphi(x_j) = y_{i}$ for an index $i$ with $x_i = x_j$, hence $y_i = y_j = b$ by $(\star)$.

So $\varphi : S \xrightarrow{\ \sim\ } T$. Since $X$ is finite and $|S| = |T|$, the complements satisfy $|X \setminus S| = |X\setminus T|$, so there exists a bijection $\psi : X\setminus S \to X \setminus T$. Set $\sigma = \varphi \sqcup \psi$, a permutation of $X$. For each $i$, $x_i \in S$ and $\sigma(x_i) = \varphi(x_i) = y_i$ by the well-definedness computation above. Hence $\sigma \circ x = y$. $\square$

**Theorem 3.2 (Completeness).** Let $X$ be finite. For all $x,y \in X^n$,

$$\big(\exists\,\sigma\in\operatorname{Sym}(X):\ \sigma\circ x = y\big) \iff \operatorname{pat}(x)=\operatorname{pat}(y).$$

*Proof.* Forward: Theorem 2.4. Backward: Theorem 3.1. $\square$

Equivalently: $\operatorname{pat}$ induces a bijection from the orbit space $X^n/\operatorname{Sym}(X)$ onto $\mathcal{P}_{n,|X|}$.

**Theorem 3.3 (Orbit count).** For all $n,m$,

$$\big|\,(\,[m]^n)\big/\operatorname{Sym}([m])\,\big| \;=\; |\mathcal{P}_{n,m}|.$$

*Proof.* The map $x \mapsto \operatorname{pat}(x)$ is constant on orbits (Theorem 2.4), hence descends to the orbit space; it is injective by Theorem 3.1 and surjective onto $\mathcal{P}_{n,m}$ by definition. $\square$

**Proposition 3.4 (Sharpness).** The kernel pattern is *not* a complete invariant for a proper subgroup. Take $X=\{0,1\}$, $n=1$, and $G = \{\mathrm{id}\} \le \operatorname{Sym}(X)$. The tuples $x=(0)$ and $y=(1)$ satisfy $\operatorname{pat}(x)=\operatorname{pat}(y)=(1)$, yet no $\sigma \in G$ has $\sigma\circ x = y$.

*Proof.* Both patterns equal $(1)$ since in a one-entry tuple the unique value first occurs at position $1$. The only element of $G$ is the identity, and $\mathrm{id}\circ(0) = (0) \neq (1)$. $\square$

Finiteness of $X$ is also genuinely used: the reconstruction step needs $|X\setminus S| = |X\setminus T|$, which for infinite $X$ may fail to be witnessed by the naive argument. (For infinite $X$ the theorem remains true when the complements happen to be equinumerous, but the clean statement is the finite one.)

---

## 4. Patterns are set partitions, and the Bell numbers

### 4.1 The bijection with equivalence relations

**Definition 4.1.** For a tuple $x$, let $\ker(x)$ be the equivalence relation $i \sim j \iff x_i = x_j$ on $[n]$.

**Theorem 4.2 (Patterns = partitions).** The map $p \mapsto \ker(p)$ is a bijection from $\mathcal{P}_n$ onto the set of equivalence relations on $[n]$ (equivalently, onto the set partitions of $[n]$).

*Proof.* *Injectivity.* If $\ker(p)=\ker(q)$ for $p,q \in \mathcal{P}_n$, then $\operatorname{pat}(p)=\operatorname{pat}(q)$ by Lemma 2.3, and $p,q$ are fixed points of $\operatorname{pat}$, so $p=q$.

*Surjectivity.* Given an equivalence relation $\sim$ on $[n]$, let $q : [n] \to [n]/\!\sim$ be the quotient map and set $p = \operatorname{pat}(q)$. Then $p \in \mathcal{P}_n$ by Lemma 2.5 and Corollary 2.9, and $\ker(p) = \ker(q) = \sim$ by Lemma 2.2. $\square$

Concretely, the block of $i$ is $\{j : p_j = p_i\}$, and $p_i$ is the least element of that block: patterns are exactly the "name each block by its minimum" encodings of set partitions.

### 4.2 Refining by block count: the Stirling numbers

**Definition 4.3.** Let $\mathcal{P}_{n}^{(k)} = \{p \in \mathcal{P}_n : |\operatorname{im}(p)| = k\}$, the patterns with exactly $k$ blocks.

The counting proof uses an explicit delete/re-attach dictionary for the last index.

**Definition 4.4 (Restriction and extension).** For $p \in \mathcal{P}_{n+1}$ define $\operatorname{restr}(p) : [n] \to [n]$ by $\operatorname{restr}(p)_i = p_i$ (which lies in $[n]$ because $p_i \le i \le n$). Conversely, for $q \in \mathcal{P}_n$ and $a \in [n+1]$ define $\operatorname{ext}(q,a) : [n+1]\to[n+1]$ to agree with $q$ on $[n]$ and send $n+1$ to $a$.

**Lemma 4.5.** $\operatorname{restr}$ and $\operatorname{ext}$ are mutually inverse: $\operatorname{ext}(\operatorname{restr}(p),p_{n+1}) = p$ for $p \in \mathcal{P}_{n+1}$, and $\operatorname{restr}(\operatorname{ext}(q,a)) = q$. Moreover $\operatorname{ext}(q,a)$ is a pattern precisely when $a = n+1$ or $a \in \operatorname{im}(q)$.

*Proof.* The first two identities are immediate from the definitions. For the last, apply Proposition 2.6: regressivity forces $a \le n+1$, and idempotence forces $q_a = a$ when $a \le n$, i.e. $a$ is a block representative of $q$; conversely both conditions clearly suffice. $\square$

**Theorem 4.6 (Stirling recursion for patterns).** For all $n,k$,

$$\big|\mathcal{P}_{n+1}^{(k+1)}\big| \;=\; (k+1)\,\big|\mathcal{P}_{n}^{(k+1)}\big| \;+\; \big|\mathcal{P}_{n}^{(k)}\big|.$$

*Proof.* Split $\mathcal{P}_{n+1}^{(k+1)}$ according to whether $p_{n+1} = n+1$ or not.

*Case $p_{n+1}=n+1$:* the last index is its own representative, i.e. it forms a new singleton block; by Lemma 4.5 such $p$ correspond bijectively to $q \in \mathcal{P}_n$ with $|\operatorname{im}(q)| = k$, since removing the singleton block loses exactly one block.

*Case $p_{n+1} \le n$:* by Lemma 4.5 the last index maps into $\operatorname{im}(q)$, where $q = \operatorname{restr}(p)$; the image is unchanged, so $|\operatorname{im}(q)| = k+1$, and $p$ is determined by $q$ together with a choice of one of the $k+1$ representatives. $\square$

Together with the boundary values $|\mathcal{P}_0^{(0)}| = 1$, $|\mathcal{P}_0^{(k+1)}| = 0$, $|\mathcal{P}_{n+1}^{(0)}| = 0$, this is precisely the recursion defining the Stirling numbers of the second kind.

**Theorem 4.7.** $\big|\mathcal{P}_n^{(k)}\big| = S(n,k)$ for all $n,k$, and consequently

$$|\mathcal{P}_n| \;=\; \sum_{k=0}^{n} S(n,k).$$

*Proof.* Induction on $n$ using Theorem 4.6 and the boundary values. The sum formula is the fibre decomposition of $\mathcal{P}_n$ along $p \mapsto |\operatorname{im}(p)|$, whose values lie in $\{0,\dots,n\}$. $\square$

### 4.3 The total count: the Bell recursion

The Stirling route gives $|\mathcal{P}_n|$ as a sum. A second, independent decomposition gives it as a Bell number directly.

**Definition 4.8 (Last block).** For $p \in \mathcal{P}_{n+1}$, let $\operatorname{lastBlk}(p) = \{i \in [n] : p_i = p_{n+1}\} \subseteq [n]$: the block of the final index, with the final index itself removed.

**Theorem 4.9 (Fibre over the last block).** For each $S \subseteq [n]$, the patterns $p \in \mathcal{P}_{n+1}$ with $\operatorname{lastBlk}(p)=S$ are in bijection with the equivalence relations on the complement $[n]\setminus S$. Hence there are $B_{\,n-|S|}$ of them.

*Proof sketch.* Given $p$ in the fibre, restrict $\ker(p)$ to $[n]\setminus S$; this is the induced partition of the complement. Conversely, given an equivalence relation $t$ on $[n]\setminus S$, define $b : [n+1] \to \big(([n]\setminus S)/t\big) \sqcup \{\ast\}$ by sending every element of $S\cup\{n+1\}$ to the distinguished point $\ast$ and every $i \notin S$ to its $t$-class, and set $p = \operatorname{pat}(b)$. Then $p$ is a pattern (Lemma 2.5), its kernel is by construction "$S\cup\{n+1\}$ is one block, and the complement is partitioned by $t$", so $\operatorname{lastBlk}(p) = S$; and the two constructions invert one another by Lemma 2.3, since each determines the kernel of the other. The count follows from Theorem 4.2 applied to the $(n-|S|)$-element set $[n]\setminus S$. $\square$

**Theorem 4.10 (Bell recursion).**

$$|\mathcal{P}_{n+1}| \;=\; \sum_{S\subseteq[n]} |\mathcal{P}_{\,n-|S|}| \;=\; \sum_{i=0}^{n}\binom{n}{i}\,|\mathcal{P}_{\,n-i}|.$$

*Proof.* The first equality is the fibre decomposition along $p \mapsto \operatorname{lastBlk}(p)$ combined with Theorem 4.9 and Theorem 4.2. The second groups subsets by cardinality, there being $\binom{n}{i}$ subsets of size $i$. $\square$

**Theorem 4.11 (Bell count).** $|\mathcal{P}_n| = B_n$ for every $n \ge 0$. Equivalently, the number of equivalence relations on an $n$-element set is $B_n$, and by Theorem 3.3 the diagonal $\operatorname{Sym}([m])$-action on $[m]^n$ has exactly $B_n$ orbits whenever $m \ge n$.

*Proof.* Strong induction: $|\mathcal{P}_0| = 1 = B_0$, and Theorem 4.10 is the defining binomial recursion $B_{n+1} = \sum_i \binom{n}{i}B_{n-i}$. The orbit statement combines Theorem 3.3 with Corollary 2.9. $\square$

**Corollary 4.12 (Bell–Stirling identity).** $\displaystyle B_n = \sum_{k=0}^{n} S(n,k)$.

*Proof.* Combine Theorem 4.7 and Theorem 4.11. $\square$

This is a genuinely non-formal identity in the following sense: the Bell numbers are specified by the binomial recursion $B_{n+1}=\sum_i \binom{n}{i}B_{n-i}$ and the Stirling numbers by the triangle recursion $S(n+1,k+1)=(k+1)S(n,k+1)+S(n,k)$; neither recursion refers to the other. The identity holds because both recursions are counting kernel patterns, one grouped by last block and one grouped by block count.

### 4.4 The initial segment

Independently of the recursions, the fixed-point characterisation of Proposition 2.6 makes $|\mathcal{P}_n|$ directly computable by exhaustive search over the $n^n$ tuples $p : [n]\to[n]$. Doing so for $n \le 5$ yields

$$|\mathcal{P}_0|,\dots,|\mathcal{P}_5| \;=\; 1,\ 1,\ 2,\ 5,\ 15,\ 52,$$

the Bell numbers $B_0,\dots,B_5$ (OEIS A000110), in agreement with Theorem 4.11.

---

## 5. Geometry I: flats of the braid arrangement

### 5.1 The arrangement

**Definition 5.1.** The **braid arrangement** in $\mathbb{R}^n$ is the finite family of hyperplanes

$$H_{ij} = \{v \in \mathbb{R}^n : v_i = v_j\}, \qquad 1 \le i < j \le n.$$

It is the reflection arrangement of the symmetric group $\operatorname{Sym}([n])$ acting on $\mathbb{R}^n$ by permuting coordinates: $H_{ij}$ is the fixed hyperplane of the transposition $(i\ j)$. Its **flats** are the intersections of subfamilies of the $H_{ij}$, ordered by inclusion; this poset is the **intersection lattice**.

**Definition 5.2.** For a tuple $x : [n]\to X$ put

$$L(x) \;=\; \{v\in\mathbb{R}^n : \forall i,j,\ x_i = x_j \Rightarrow v_i=v_j\},$$

the subspace of vectors constant on the blocks of $\ker(x)$.

$L(x)$ is a linear subspace (the conditions are linear), and it is precisely the intersection $\bigcap\{H_{ij} : x_i = x_j\}$. Conversely, an arbitrary intersection of hyperplanes $H_{ij}$ is of this form, because the set of pairs $(i,j)$ with $v_i=v_j$ for all $v$ in the intersection is an equivalence relation. So the flats of the braid arrangement are exactly the subspaces $L(x)$.

### 5.2 Patterns as complete invariants of flats

**Definition 5.3.** The **block indicator** of $i$ relative to $x$ is $\mathbf{1}_i^x \in \mathbb{R}^n$ with $(\mathbf{1}_i^x)_k = 1$ if $x_k = x_i$ and $0$ otherwise. Clearly $\mathbf{1}_i^x \in L(x)$.

**Theorem 5.4 (Order dictionary).** For tuples $x,y$ on $[n]$,

$$L(x) \subseteq L(y) \iff \big(\forall i,j,\ y_i=y_j \Rightarrow x_i=x_j\big),$$

i.e. inclusion of flats corresponds, order-reversingly, to refinement of kernels.

*Proof.* ($\Leftarrow$) immediate from the definition. ($\Rightarrow$) Suppose $L(x)\subseteq L(y)$ and $y_i = y_j$. Then $\mathbf{1}_i^x \in L(y)$, so its $i$- and $j$-coordinates agree; the $i$-coordinate is $1$, so the $j$-coordinate is $1$, i.e. $x_j = x_i$. $\square$

**Theorem 5.5 (Geometric completeness).** $L(x) = L(y) \iff \operatorname{pat}(x)=\operatorname{pat}(y)$.

*Proof.* ($\Rightarrow$) Apply Theorem 5.4 in both directions to get $x_i=x_j \iff y_i=y_j$, then Lemma 2.3. ($\Leftarrow$) The pattern determines the kernel (Lemma 2.2), and $L$ depends only on the kernel. $\square$

**Theorem 5.6 (Dimension = number of blocks).** $\dim_{\mathbb{R}} L(x) = |\operatorname{im}(\operatorname{pat}(x))|$, the number of blocks of $\ker(x)$.

*Proof.* The linear map $L(x) \to \mathbb{R}^{\operatorname{im}(\operatorname{pat}(x))}$, $v \mapsto (v_r)_{r}$, restricting a vector to the block representatives, is an isomorphism: it is injective because a vector in $L(x)$ is determined by its values on representatives ($v_i = v_{\operatorname{pat}(x)_i}$ by Lemma 2.1 and membership in $L(x)$), and surjective because any assignment on representatives extends by $v_i := w_{\operatorname{pat}(x)_i}$, which lies in $L(x)$ by Lemma 2.2. $\square$

**Corollary 5.7 (Extremes).** If $x$ is injective, $L(x)=\mathbb{R}^n$; if $x$ is constant and $n\ge 1$, $L(x)$ is the line of constant vectors, of dimension $1$.

**Theorem 5.8 (Enumeration of the intersection lattice).** The braid arrangement in $\mathbb{R}^n$ has exactly $B_n$ flats, of which exactly $S(n,k)$ have dimension $k$.

*Proof.* By Theorem 5.5 the map $p \mapsto L(p)$ is a bijection from $\mathcal{P}_n$ onto the set of flats; apply Theorem 4.11 for the total and Theorems 5.6 and 4.7 for the refinement. $\square$

For $n=5$: $52$ flats, of dimensions $1,2,3,4,5$ in quantities $1,15,25,10,1$.

---

## 6. Geometry II: faces, chambers, and the Fubini numbers

The kernel pattern deliberately forgets the order of the values. Restoring it produces a finer invariant that classifies the *faces* of the arrangement.

### 6.1 Ordered patterns

**Definition 6.1 (Ordered pattern / rank function).** Let $X$ be linearly ordered and $v : [n]\to X$. Set

$$\operatorname{rank}(v)_i \;=\; \#\{\,\text{blocks } b \text{ of } \ker(v) \text{ with value} < v_i\,\} \;=\; \#\{\,j : \operatorname{pat}(v)_j = j \ \wedge\ v_j < v_i\,\}.$$

Thus $\operatorname{rank}(v)_i \in \{0,1,\dots,n-1\}$ counts the distinct values of $v$ strictly below $v_i$.

**Example.** $v = (3.1, 7.0, 3.1, -2.0, 7.0)$ has distinct values $-2.0<3.1<7.0$ and $\operatorname{rank}(v) = (1,2,1,0,2)$.

**Theorem 6.2 (Order faithfulness).** $\operatorname{rank}(v)_i < \operatorname{rank}(v)_j \iff v_i < v_j$, and consequently $\operatorname{rank}(v)_i = \operatorname{rank}(v)_j \iff v_i = v_j$.

*Proof.* If $v_i<v_j$ then the set of representatives with value $<v_i$ is a proper subset of the set with value $<v_j$ — proper because $\operatorname{pat}(v)_i$ belongs to the second and not the first — so the cardinalities are strictly ordered. If $v_i \ge v_j$ then the second set is contained in the first, so the ranks are weakly ordered the other way. The equality statement follows by trichotomy. $\square$

**Theorem 6.3 (Invariance).** If $f$ is strictly monotone then $\operatorname{rank}(f\circ v) = \operatorname{rank}(v)$; more generally $\operatorname{rank}$ depends only on the weak order induced by $v$. Moreover $\operatorname{rank}(\operatorname{rank}(v)) = \operatorname{rank}(v)$ and $\operatorname{pat}(\operatorname{rank}(v)) = \operatorname{pat}(v)$.

*Proof.* By Theorem 6.2 the data $\{(i,j) : v_i<v_j\}$ determines $\operatorname{rank}(v)$, and a strictly monotone reparametrisation preserves that data. Idempotence and compatibility with $\operatorname{pat}$ follow by applying Theorem 6.2 and Lemma 2.3. $\square$

So $\operatorname{rank}$ is the canonical form for **weak orderings** of $[n]$ (total preorders), just as $\operatorname{pat}$ is the canonical form for partitions. Write $\mathcal{O}_n = \{r : \operatorname{rank}(r) = r\}$ for the set of ordered patterns, and $\mathcal{O}_n^{(k)}$ for those with $k$ distinct values.

### 6.2 Faces

**Definition 6.4.** The **face** of $v \in \mathbb{R}^n$ is

$$F(v) \;=\; \{w \in \mathbb{R}^n : \forall i,j,\ (v_i<v_j \iff w_i<w_j)\}.$$

Equivalently, $F(v)$ is the relatively open cone cut out by imposing, for each pair, the same one of $<,=,>$ that $v$ realises.

**Theorem 6.5 (Faces are convex).** Each $F(v)$ is convex, hence connected, and contains $v$.

*Proof.* Let $w,w' \in F(v)$ and $a,b\ge 0$ with $a+b=1$. If $v_i<v_j$ then $w_i<w_j$ and $w'_i<w'_j$, and a convex combination of two strict inequalities with $(a,b)\neq(0,0)$ is strict, so $(aw+bw')_i < (aw+bw')_j$. If $v_i = v_j$ then $w_i=w_j$ and $w'_i=w'_j$ (by Theorem 6.2 applied to the definition of $F$), so the combination has equal coordinates; and if $v_j<v_i$ the previous case applies with $i,j$ swapped. Hence $aw+bw'$ realises exactly the comparisons of $v$. $\square$

**Theorem 6.6 (Ordered patterns classify faces).** $F(v) = F(w) \iff \operatorname{rank}(v)=\operatorname{rank}(w)$.

*Proof.* ($\Rightarrow$) $w \in F(w) = F(v)$ says $v$ and $w$ induce the same strict comparisons; apply Theorem 6.3. ($\Leftarrow$) By Theorem 6.2, equality of ranks gives $v_i<v_j \iff w_i<w_j$, so $F(v)$ and $F(w)$ are defined by the same conditions. $\square$

### 6.3 Chambers

**Definition 6.7.** For $\sigma \in \operatorname{Sym}([n])$ let

$$C_\sigma = \{v \in \mathbb{R}^n : v_{\sigma(1)} < v_{\sigma(2)} < \cdots < v_{\sigma(n)}\}.$$

**Theorem 6.8 (Chamber structure).** Each $C_\sigma$ is nonempty and convex; distinct permutations give disjoint chambers; $\sigma \mapsto C_\sigma$ is injective; the union $\bigcup_\sigma C_\sigma$ is exactly the set of injective vectors, i.e. the complement of the arrangement. Consequently the braid arrangement in $\mathbb{R}^n$ has exactly $n!$ chambers.

*Proof.* Nonemptiness: take $v_{\sigma(i)} = i$. Convexity: the defining conditions are strict linear inequalities. If $v \in C_\sigma$ then $v$ is injective, and $\sigma$ is recoverable as the unique permutation sorting $v$ increasingly, whence disjointness and injectivity of $\sigma \mapsto C_\sigma$. Conversely an injective $v$ lies in $C_\sigma$ for the sorting permutation $\sigma$. $\square$

**Theorem 6.9 (Chambers are faces).** If $v \in C_\sigma$ then $F(v) = C_\sigma$.

*Proof.* Both sets consist exactly of the vectors realising the strict order $w_{\sigma(1)}<\cdots<w_{\sigma(n)}$: any $w$ with the same comparisons as $v$ satisfies these inequalities, and conversely. $\square$

### 6.4 Counting faces: the Fubini numbers

**Theorem 6.10 (Fibre theorem).** Let $p \in \mathcal{P}_n$ have exactly $k$ blocks. Then the number of ordered patterns $r \in \mathcal{O}_n$ with $\operatorname{pat}(r)=p$ is exactly $k!$.

*Proof sketch.* An ordered pattern lying over $p$ is the same data as $p$ together with a linear order on its $k$ blocks: given such an order, define $r_i$ to be the number of blocks strictly preceding the block of $i$; this is an ordered pattern with $\operatorname{pat}(r)=p$ (Theorem 6.3), and every ordered pattern over $p$ arises exactly once this way, since by Theorem 6.2 the values $r_i$ are constant on blocks of $p$ and totally order them. A $k$-element set has $k!$ linear orders. (The rigidity input is that an ordered pattern with $k$ distinct values, viewed as a surjection onto $\{0,\dots,k-1\}$, equals its own rank function — its values are already the ranks.) $\square$

**Theorem 6.11 (Fubini formula).** For all $n,k$: $\ \big|\mathcal{O}_n^{(k)}\big| = S(n,k)\cdot k!$, and

$$|\mathcal{O}_n| \;=\; \sum_{k=0}^{n} S(n,k)\,k!.$$

*Proof.* Fibre the map $\operatorname{pat} : \mathcal{O}_n^{(k)} \to \mathcal{P}_n^{(k)}$; each fibre has $k!$ elements by Theorem 6.10 and the base has $S(n,k)$ elements by Theorem 4.7. Sum over $k \in \{0,\dots,n\}$. $\square$

The numbers $a_n = \sum_k S(n,k)k!$ are the **ordered Bell** (Fubini) numbers, OEIS A000670:

$$1,\ 1,\ 3,\ 13,\ 75,\ 541,\ 4683,\ \dots$$

They count the weak orderings of an $n$-set — equivalently the faces of the braid arrangement in $\mathbb{R}^n$, and equivalently the possible outcomes of an $n$-runner race with ties permitted.

**Theorem 6.12 (Comparisons).** For all $n$: $\ n! \le a_n$ and $B_n \le a_n$.

*Proof.* $n! = S(n,n)\cdot n!$ is the single $k=n$ term of the Fubini sum, and all terms are non-negative. For the second, $S(n,k) \le S(n,k)\cdot k!$ term by term since $k! \ge 1$, and $B_n = \sum_k S(n,k)$ by Corollary 4.12. $\square$

The two inequalities have transparent geometric content: *every chamber is a face* (Theorem 6.9), and *every flat carries at least one face* (its own relative interior, corresponding to $k! \ge 1$).

**Summary table ($n=5$).**

| object | invariant | count |
|---|---|---|
| orbits of $\operatorname{Sym}([5])$ on $[5]^5$ | kernel pattern | $52$ |
| flats of the braid arrangement in $\mathbb{R}^5$ | kernel pattern | $52$ |
| flats of dimension $k$ | pattern with $k$ blocks | $1,15,25,10,1$ |
| faces | ordered pattern | $541$ |
| chambers | total order | $120$ |

---

## 7. Algorithms

All the objects above are effectively computable, and the computations are short.

### 7.1 Canonical form

**Kernel pattern.** Scan the tuple once, maintaining a dictionary from value to first index:

```
input: x[1..n]
first := empty map
for i = 1..n:
    if x[i] not in first: first[x[i]] := i
    p[i] := first[x[i]]
return p
```

Time $O(n)$ expected with hashing, $O(n\log n)$ with a balanced map; space $O(n)$.

**Ordered pattern.** Sort the distinct values, then look up each entry's index in the sorted list:

```
input: v[1..n]
vals := sorted(distinct(v))
pos  := map from value to its index in vals   # 0-based
for i = 1..n: r[i] := pos[v[i]]
return r
```

Time $O(n\log n)$, space $O(n)$.

Both are canonical forms in the strict sense: two tuples are equivalent (respectively, $\operatorname{Sym}$-conjugate and order-isomorphic) if and only if their canonical forms are literally equal, so equivalence testing is a single comparison after $O(n\log n)$ preprocessing.

### 7.2 Enumeration

**Restricted growth strings.** By Proposition 2.6 and Theorem 4.2 the patterns are exactly the tuples $p$ with $p_i \le i$ and $p_{p_i}=p_i$; re-indexing block names $1,2,3,\dots$ in order of first appearance turns them into **restricted growth strings**: sequences $g_1 = 0$, $g_{i+1} \le 1 + \max(g_1,\dots,g_i)$. Enumerating these by depth-first search generates all $B_n$ partitions in constant amortised time each.

**Faces.** By Theorem 6.10, enumerating faces means enumerating each partition together with each of the $k!$ orderings of its blocks — a nested loop over restricted growth strings and permutations, generating all $a_n$ weak orders.

### 7.3 Counting

The recursions of §4 give the counts without enumeration:

```
S(0,0) = 1;  S(n,0) = 0 (n>0);  S(0,k) = 0 (k>0)
S(n+1,k+1) = (k+1)*S(n,k+1) + S(n,k)
B(0) = 1;   B(n+1) = sum_{i=0..n} C(n,i) * B(n-i)
```

The Stirling triangle costs $O(n^2)$ arithmetic operations, the Bell recursion $O(n^2)$ as well. Both use big integers: $B_n$ grows super-exponentially, faster than $c^n$ for every $c$ but slower than $n!$.

---

## 8. Applications and interpretations

**Group theory and Pólya theory.** Theorem 3.3 says the orbit space of the diagonal symmetric-group action on $X^n$ is the partition lattice of $[n]$ truncated at $|X|$ blocks. This is the "$\operatorname{Sym}(X)$ acts on the alphabet, not the positions" companion of the more familiar Pólya-theoretic count where the group acts on the positions.

**Databases and data processing.** A `GROUP BY` on a tuple of keys computes exactly the kernel of that tuple; the canonical form of §7.1 is precisely the standard "dictionary-encode by first occurrence" pass. Two datasets are relabelling-equivalent — anonymised versions of one another — exactly when their kernel patterns agree, which is Theorem 3.2 read as a privacy statement: pseudonymisation destroys value identity and nothing else.

**Clustering and model comparison.** Clustering algorithms output set partitions, and the space of outputs is exactly the $B_n$-element lattice, ordered by refinement — the same lattice as the flats of the braid arrangement under reverse inclusion (Theorem 5.4). The dimension formula (Theorem 5.6) says that the number of free parameters in a "one value per cluster" model is the number of clusters.

**Exchangeable random structures.** Probability distributions on set partitions — the Chinese restaurant process, the Ewens sampling formula, Kingman's coalescent — are distributions on precisely the $B_n$ kernel patterns; the Bell recursion of Theorem 4.10 is the normalising identity behind the sequential-construction view of these processes.

**Ranking with ties.** Theorem 6.11 counts the outcomes of a competition among $n$ contestants in which ties are allowed, and Theorem 6.6 says that two score vectors are indistinguishable to any tie-tolerant ranking criterion exactly when they lie in the same face. Rank-based statistics are exactly the functions constant on faces.

**Hyperplane arrangements and topology.** The braid arrangement is the running example of the theory: its complexified complement is the classifying space of the pure braid group, whose Poincaré polynomial $\prod_{i=1}^{n-1}(1+it)$ is computed from the intersection lattice enumerated in Theorem 5.8, and whose chamber count $n!$ (Theorem 6.8) is the order of the Coxeter group. The face poset counted in Theorem 6.11 is the underlying set of the *face monoid* whose random-walk theory (the Tsetlin library and its relatives) is driven by exactly these numbers.

---

## 9. Discussion and future directions

### 9.1 What makes the argument work

Three features of the development deserve emphasis.

*Separation of invariance from counting.* The proof that $\operatorname{pat}$ is a complete invariant (§3) never touches the counting, and the counting (§4) never touches the group action. The bridge is the single fixed-point characterisation of Proposition 2.6. This makes the whole apparatus portable: any equivalence on tuples that can be described as "same value under a group action on the alphabet" admits the same three-step treatment.

*One model, two recursions.* Corollary 4.12 is the clean payoff. Two classical recursions, each self-contained, are reconciled by exhibiting one set of objects that both count — grouped by last block for Bell, grouped by block count for Stirling.

*Two levels of order.* The unordered/ordered dichotomy $\operatorname{pat}$ vs $\operatorname{rank}$ maps precisely onto the flat/face dichotomy in the geometry, and the ratio between the two counts is the $k!$ of Theorem 6.10. The Fubini formula is the resulting Fubini-style interchange of summation.

### 9.2 Future directions

The following are the natural next questions.

**1. Signed kernel patterns for the hyperoctahedral arrangement.** *Conjecture.* For the type-$B_n$ reflection arrangement (hyperplanes $x_i = \pm x_j$ and $x_i = 0$) the complete invariant of a point's face is the *signed kernel pattern*: the kernel of the map $i \mapsto |x_i|$ together with the sign vector and the ordering of the resulting blocks. The flats should be counted by $\sum_k \binom{n}{k}\widetilde{S}(k)$ — the type-$B$ Dowling/partition numbers $1, 2, 6, 24, 116, 648$ — and the faces by the type-$B$ ordered analogue. The key insight is that the kernel pattern never used the linear structure of the index set, only the equivalence relation "same value"; so replacing "same value" by "same value up to the sign action of $(\mathbb{Z}/2)^n \rtimes \operatorname{Sym}(n)$" should produce a complete invariant by literally the same congruence argument (Lemma 2.3), with all the extra content concentrated in the counting. The delete-the-last-index recursion of §4 transfers verbatim, with the Dowling recursion replacing the Stirling one.

**2. Möbius rigidity of the kernel lattice.** *Conjecture.* The Möbius function of the interval $[\hat{0},\pi]$ in the lattice of kernel patterns ordered by refinement — equivalently, of the intersection lattice of the braid arrangement ordered by reverse inclusion — is determined by the block sizes alone: for a partition into blocks of sizes $b_1,\dots,b_k$ one should have $\mu(\hat{0},\pi) = \prod_{t}(-1)^{b_t-1}(b_t-1)!$, and hence $\mu(\hat 0,\hat 1) = (-1)^{n-1}(n-1)!$ for the full partition lattice. The corresponding characteristic polynomial $\chi(t) = t(t-1)\cdots(t-n+1)$ would then recover, via the standard finite-field and Zaslavsky counts, both the chamber count $n!$ of Theorem 6.8 and the face count of Theorem 6.11 from purely lattice-theoretic data — closing the loop between §4 and §6 by a third, independent route.

**3. Beyond finite alphabets and beyond the full symmetric group.** Proposition 3.4 shows completeness fails for proper subgroups. It is natural to ask, for a given permutation group $G \le \operatorname{Sym}(X)$, what the correct complete invariant of the diagonal $G$-action is, and how many orbits there are; the kernel pattern is then a coarse invariant, and the fibres of the map from $G$-orbits to patterns measure the failure. For $G$ transitive on $X$ this question is a refinement of the theory of *orbitals*.

**4. Metric and probabilistic refinements.** The flats form a graded lattice with rank the number of blocks (Theorem 5.6). Natural metrics on partitions — the transposition distance, the variation-of-information metric used in clustering evaluation — can be read off the lattice; understanding which of them are induced by the linear geometry of the flats (e.g. by principal angles between the subspaces $L(p)$) would connect the combinatorics of §4 with the Euclidean geometry of §5.

**5. Effective enumeration at scale.** Restricted growth strings give constant amortised time enumeration of the $B_n$ patterns, but $B_n$ grows super-exponentially. For statistical applications one wants *sampling* rather than enumeration; the Bell recursion of Theorem 4.10 is exactly the recursion needed for unranking and for exact uniform sampling of a random set partition in $O(n^2)$ arithmetic, and the analogous unranking for the $a_n$ faces follows from Theorem 6.11.

---

## 10. Conclusion

The kernel pattern of a tuple — replace each entry by the position at which its value first occurred — is a small, computable object that turns out to be the exact answer to three different classification problems. It is a complete invariant of the diagonal symmetric-group action on tuples over a finite alphabet, sharp in the sense that no proper subgroup admits it. It is a canonical form for set partitions, counted with $k$ blocks by the Stirling numbers of the second kind and in total by the Bell numbers $1,1,2,5,15,52,\dots$, and its two counting decompositions reconcile the Bell and Stirling recursions in the identity $B_n=\sum_k S(n,k)$. And it is a complete invariant of the flats of the braid arrangement in $\mathbb{R}^n$, with dimension equal to block count, so that the intersection lattice has $B_n$ elements with $S(n,k)$ of dimension $k$. Refining the pattern by the ordering of its blocks classifies the faces instead of the flats, multiplies each count by $k!$, and produces the ordered Bell numbers $1,1,3,13,75,541,\dots$, inside which the $n!$ chambers sit as the top-dimensional stratum.

The unifying moral is that coincidence structure — *which entries agree* — is the invariant content of a tuple under any symmetry that acts on values rather than positions, and that once this is made canonical, the algebra, the enumeration and the geometry are three readings of a single combinatorial object.
