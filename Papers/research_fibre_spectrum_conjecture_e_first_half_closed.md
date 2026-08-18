# The Fibre Spectrum of the Orbit–Pattern Map

**Author:** Aristotle
**Date:** 2026-08-18

---

## Abstract

Let a finite group $G$ act on a finite set $X$ with $|X| = n$, and let it act diagonally on the set $X^k$ of $k$-tuples. Every tuple carries a $G$-invariant *coincidence pattern*: the set partition of the index set $\{1,\dots,k\}$ recording which coordinates hold equal values. This produces the **orbit–pattern map** $\pi_k : X^k/G \to \Pi_k$ from the set of orbits onto the $B_k$ set partitions of $\{1,\dots,k\}$, whose fibre sizes $m_P$ satisfy $\sum_P m_P = \#(X^k/G)$, $m_P \ge 1$ whenever $k \le n$, and $m_P = 1$ for all $P$ exactly when the action is $k$-transitive. Those three statements yield the *Bell floor* $\#(X^k/G) \ge B_k$, sharp precisely for $k$-transitive actions.

This paper determines the fibre sizes completely. The main structural result is the **rank collapse**: $m_P$ depends only on the number of blocks of $P$, namely $m_P = t_{\operatorname{rank} P}$, where $t_r$ is the number of $G$-orbits of injective $r$-tuples. The proof is a natural, $G$-equivariant bijection between the fibre over $P$ and the fibre over the discrete pattern of rank $\operatorname{rank} P$, obtained by restricting a tuple to the block leaders of $P$ and, inversely, spreading a tuple along the blocks; it requires no hypothesis relating $k$ and $n$.

Summing the rank collapse over patterns of a fixed rank gives the **spectral expansion** $\#(X^k/G) = \sum_{r \le k} S(k,r)\,t_r$, where $S(k,r)$ is the number of patterns of rank $r$ — the Stirling numbers of the second kind, here shown from the pattern model to satisfy $S(k+1,r+1) = S(k,r) + (r+1)S(k,r+1)$ together with the classical boundary conditions, and characterised uniquely by them. Triangularity $S(k,k)=1$ makes the expansion invertible over $\mathbb{N}$, whence the **rigidity theorem**: the orbit-count sequence $k \mapsto \#(X^k/G)$ and the spectrum $r \mapsto t_r$ determine each other. The spectrum is monotone, $1 = t_0 \le t_1 \le \dots \le t_n$, and $t_r = 1$ is equivalent to $r$-transitivity; consequently a **single** fibre — the one over the discrete pattern — decides $k$-transitivity, sharpening the fibrewise criterion, and $t_r$ vanishes for $r > n$.

Finally, the spectrum is bounded from outside the combinatorics: $k$-transitivity forces the falling factorial $n^{\underline k}$ to divide $|G|$, so $|G| < n^{\underline k}$ implies $t_k \ge 2$ and hence the **strict Bell defect** $\#(X^k/G) \ge B_k + 1$, equivalently $\sum_{g \in G} |\mathrm{Fix}(g)|^k \ge (B_k+1)|G|$ for the $k$-th moment of the fixed-point statistic. Applied to the trivial action, the spectral expansion degenerates to the classical change of basis $n^k = \sum_r S(k,r)\,n^{\underline r}$.

**Keywords:** permutation group, $k$-transitivity, orbit counting, set partition, Stirling number of the second kind, Bell number, Burnside's lemma, fixed-point moments.

---

## 1. Introduction

### 1.1 The problem

Let $G$ be a finite group acting on a finite set $X$ with $|X| = n$. The action extends diagonally to the set $X^k$ of ordered $k$-tuples,
$$g \cdot (f_1, \dots, f_k) := (g\cdot f_1, \dots, g \cdot f_k),$$
and the counting function
$$k \;\longmapsto\; \#(X^k/G)$$
is a classical invariant. By Burnside's lemma applied to $X^k$, and since $\mathrm{Fix}_{X^k}(g) = \mathrm{Fix}_X(g)^k$,
$$\#(X^k/G) \cdot |G| \;=\; \sum_{g\in G} |\mathrm{Fix}_X(g)|^k, \tag{1.1}$$
so the orbit-count sequence is exactly the sequence of moments of the random variable "number of fixed points of a uniformly random group element". Determining these numbers is therefore simultaneously a combinatorial and a probabilistic question about the action.

### 1.2 Coincidence patterns and the fibration

The starting observation is that a tuple carries a $G$-invariant combinatorial shadow. Define the *kernel*, or *coincidence pattern*, of $f \in X^k$ to be the set partition
$$\ker f := \bigl\{\,\{j : f_j = f_i\} \;:\; 1 \le i \le k \,\bigr\}$$
of $\{1,\dots,k\}$. Since each $g$ acts on $X$ by a bijection, $\ker(g\cdot f) = \ker f$; the pattern is an invariant of the orbit. We therefore have the **orbit–pattern map**
$$\pi_k : X^k/G \longrightarrow \Pi_k, \qquad \pi_k([f]) = \ker f ,$$
where $\Pi_k$ is the set of set partitions of $\{1,\dots,k\}$, of cardinality the Bell number $B_k$.

Write $m_P := |\pi_k^{-1}(P)|$ for the **pattern multiplicity** of $P \in \Pi_k$. The following three facts constitute the starting point of the present work; the first is the fibre decomposition of a map with finite target, the second says that for $k \le n$ every pattern is realised (choose $\operatorname{rank}P$ distinct points of $X$), and the third is a reformulation of $k$-transitivity.

> **Proposition 1.1.** Let $k \le n$.
> 1. $\displaystyle \#(X^k/G) = \sum_{P \in \Pi_k} m_P$.
> 2. $m_P \ge 1$ for every $P \in \Pi_k$.
> 3. $m_P = 1$ for every $P \in \Pi_k$ if and only if the action is $k$-transitive, i.e. for all injective $u, v \in X^k$ there is $g \in G$ with $g \cdot u = v$.

Combining (1) and (2) yields the **Bell floor** $\#(X^k/G) \ge B_k$ for $k \le n$, with equality exactly for $k$-transitive actions, by (3); and, via (1.1), $\sum_{g}|\mathrm{Fix}(g)|^k \ge B_k |G|$.

The multiplicities $m_P$ are thus $B_k$ unknowns constraining a single count. The purpose of this paper is to show they are not unknowns at all, and to draw the consequences.

### 1.3 Results

Let
$$t_r := \#\{\text{$G$-orbits of injective $r$-tuples}\}, \qquad r \ge 0,$$
the **fibre spectrum** of the action. Our results are:

- **Rank collapse (Theorem 3.4).** $m_P = t_{\operatorname{rank} P}$ for every $P \in \Pi_k$, with no hypothesis relating $k$ and $n$.
- **Spectral expansion (Theorem 4.3).** $\#(X^k/G) = \sum_{r=0}^{k} S(k,r)\, t_r$, where $S(k,r) := |\{P \in \Pi_k : \operatorname{rank} P = r\}|$.
- **Stirling identification (Theorems 4.1, 8.1–8.3).** $S$ satisfies $S(0,0)=1$, $S(0,r+1) = S(k+1,0) = 0$, $S(k,k)=1$, and $S(k+1,r+1) = S(k,r) + (r+1)S(k,r+1)$; these determine $S$ uniquely, so $S$ is the classical Stirling triangle of the second kind. Row sums give $B_k = \sum_r S(k,r)$.
- **Monotonicity and vanishing (Theorems 5.2, 5.3, 6.3).** $1 = t_0 \le t_1 \le \dots \le t_n$, and $t_r = 0$ for $r > n$.
- **Transitivity (Theorems 5.4, 5.5).** $t_r = 1 \iff$ the action is $r$-transitive ($r \le n$); consequently the single fibre over the discrete pattern decides $k$-transitivity, and $m_{\mathrm{disc}} = 1$ forces $m_P = 1$ for all $P$.
- **Rigidity (Theorem 6.2).** Two finite actions have equal orbit counts on $k$-tuples for all $k$ if and only if they have equal spectra.
- **Degeneration (Theorem 6.4).** For the trivial action, $t_r = n^{\underline r}$, and the expansion becomes $n^k = \sum_r S(k,r)\,n^{\underline r}$.
- **Order bound and strict Bell defect (Theorems 7.1–7.4).** $k$-transitivity implies $n^{\underline k} \mid |G|$, hence $n^{\underline k} \le |G|$; and if $|G| < n^{\underline k}$ with $k \le n$, then $t_k \ge 2$, $\#(X^k/G) \ge B_k + 1$ and $\sum_g |\mathrm{Fix}(g)|^k \ge (B_k+1)|G|$.
- **Rank-resolved moment formula (Theorem 7.5).** $\displaystyle \frac{1}{|G|}\sum_{g\in G}|\mathrm{Fix}(g)|^k = B_k + \sum_{r=0}^k S(k,r)\,(t_r - 1)$ for $k \le n$.

---

## 2. Definitions and conventions

Throughout, $G$ is a group acting on a set $X$; finiteness hypotheses are stated where needed. We index tuples by $\{0,1,\dots,k-1\}$ or $\{1,\dots,k\}$ interchangeably; the set of $k$-tuples is $X^k$, viewed as the set of functions from the index set to $X$.

**Definition 2.1 (Pattern).** A *pattern* of length $k$ is a function $P : \{1,\dots,k\} \to \{1,\dots,k\}$ satisfying
$$P(i) \le i \quad\text{and}\quad P(P(i)) = P(i) \qquad \text{for all } i .$$
Patterns are in canonical bijection with set partitions of $\{1,\dots,k\}$: the blocks are the fibres of $P$, and $P(i)$ is the least element of the block containing $i$. We write $\Pi_k$ for the set of patterns of length $k$; $|\Pi_k| = B_k$, the $k$-th Bell number.

**Definition 2.2 (Kernel pattern).** For $f \in X^k$, its *kernel pattern* is
$$(\ker f)(i) := \min\{\, j : f_j = f_i \,\}.$$
It is a pattern, and $f_i = f_j \iff (\ker f)(i) = (\ker f)(j)$.

Two facts we use constantly:

**Lemma 2.3 (Recognition).** Let $P$ be a pattern and $w \in X^k$ with $w_i = w_j \iff P(i) = P(j)$ for all $i, j$. Then $\ker w = P$.

*Proof sketch.* Fix $i$. Since $w_{P(i)} = w_i$ by hypothesis (as $P(P(i)) = P(i)$), the index $P(i)$ lies in the set whose minimum defines $(\ker w)(i)$, so $(\ker w)(i) \le P(i)$. Conversely $w_{(\ker w)(i)} = w_i$ gives $P((\ker w)(i)) = P(i)$, and $P$ is order-decreasing, so $P(i) = P((\ker w)(i)) \le (\ker w)(i)$. $\square$

This lemma is the technical key to the hypothesis-free character of the main theorem: it recognises a pattern from a *coincidence relation alone*, with no reference to an ambient injective tuple, hence no need for $k \le n$.

**Lemma 2.4.** $f$ is injective if and only if $\ker f = \mathrm{id}$, the *discrete pattern*.

**Definition 2.5 (Rank and leaders).** For a pattern $P$, its set of *leaders* is $L(P) := P(\{1,\dots,k\})$ — equivalently, the set of indices fixed by $P$, one per block — and its *rank* is $\operatorname{rank} P := |L(P)| \le k$, the number of blocks. Let $\iota_P : \{1,\dots,\operatorname{rank}P\} \xrightarrow{\ \sim\ } L(P)$ be the increasing enumeration.

**Definition 2.6 (Discrete pattern).** $\mathrm{disc}_r := \mathrm{id}$ on $\{1,\dots,r\}$; it is the unique pattern of length $r$ and rank $r$, and $\operatorname{rank}(\mathrm{disc}_r) = r$.

**Definition 2.7 ($k$-transitivity).** The action is *$k$-transitive* if for all injective $u,v \in X^k$ there is $g \in G$ with $g\cdot u = v$. (For $k \le n$ injective tuples exist, so this is the usual notion; for $k > n$ it holds vacuously.)

**Definition 2.8 (Pattern multiplicity and spectrum).**
$$m_P := \bigl|\{\,o \in X^k/G \;:\; \pi_k(o) = P \,\}\bigr|, \qquad t_r := m_{\mathrm{disc}_r} = \#\{\text{orbits of injective } r\text{-tuples}\}.$$

**Definition 2.9 (Stirling coefficient).** $S(k,r) := |\{P \in \Pi_k : \operatorname{rank}P = r\}|$.

Finally, $n^{\underline r} := n(n-1)\cdots(n-r+1)$ denotes the falling factorial ($n^{\underline 0} = 1$, and $n^{\underline r} = 0$ for $r > n$), and $\mathrm{Fix}(g) := \{x \in X : g \cdot x = x\}$.

---

## 3. The rank collapse

Fix a pattern $P$ of length $k$ and put $r := \operatorname{rank}P$.

**Definition 3.1 (Shrink and grow).** For $f \in X^k$ and $h \in X^{r}$ set
$$\mathrm{sh}_P(f) := \bigl(f_{\iota_P(1)}, \dots, f_{\iota_P(r)}\bigr) \in X^{r}, \qquad \bigl(\mathrm{gr}_P(h)\bigr)_i := h_{\iota_P^{-1}(P(i))} \quad (1 \le i \le k).$$
In words: $\mathrm{sh}_P$ restricts a $k$-tuple to the leader indices of $P$; $\mathrm{gr}_P$ spreads an $r$-tuple over $\{1,\dots,k\}$, giving every index of a block the value attached to that block's leader.

Both maps are visibly $G$-equivariant: $\mathrm{sh}_P(g\cdot f) = g\cdot \mathrm{sh}_P(f)$ and $\mathrm{gr}_P(g\cdot h) = g\cdot\mathrm{gr}_P(h)$, since they only permute and duplicate coordinates.

**Lemma 3.2.** Let $f \in X^k$ with $\ker f = P$, and let $h \in X^r$ be injective. Then:
1. $\mathrm{sh}_P(f)$ is injective;
2. $\ker(\mathrm{gr}_P(h)) = P$;
3. $\mathrm{gr}_P(\mathrm{sh}_P(f)) = f$ and $\mathrm{sh}_P(\mathrm{gr}_P(h)) = h$.

*Proof sketch.* (1) If $f_{\iota_P(a)} = f_{\iota_P(b)}$ then $P(\iota_P(a)) = P(\iota_P(b))$ because $\ker f = P$; leaders are fixed by $P$, so $\iota_P(a) = \iota_P(b)$, whence $a = b$.
(2) Write $w := \mathrm{gr}_P(h)$. If $P(i) = P(j)$ then $w_i = w_j$ by definition. Conversely $w_i = w_j$ means $h_{\iota_P^{-1}(P(i))} = h_{\iota_P^{-1}(P(j))}$, and injectivity of $h$ and of $\iota_P^{-1}$ give $P(i) = P(j)$. Now apply the Recognition Lemma 2.3.
(3) For the first identity, $\bigl(\mathrm{gr}_P(\mathrm{sh}_P(f))\bigr)_i = f_{P(i)} = f_i$, the last step because $\ker f = P$ puts $i$ and $P(i)$ in the same block. For the second, $\bigl(\mathrm{sh}_P(\mathrm{gr}_P(h))\bigr)_a = h_{\iota_P^{-1}(P(\iota_P(a)))} = h_a$, since leaders are fixed. $\square$

**Proposition 3.3 (Fibre bijection).** For every pattern $P$ of length $k$ with $r = \operatorname{rank}P$, the maps $\mathrm{sh}_P$ and $\mathrm{gr}_P$ descend to mutually inverse bijections
$$\pi_k^{-1}(P) \;\xrightarrow{\ \sim\ }\; \pi_{r}^{-1}(\mathrm{disc}_{r}).$$

*Proof sketch.* Equivariance makes $\mathrm{sh}_P$ and $\mathrm{gr}_P$ descend to maps of orbit sets. By Lemma 3.2(1) and Lemma 2.4, the descent of $\mathrm{sh}_P$ carries an orbit of pattern $P$ to an orbit of injective $r$-tuples, i.e. of pattern $\mathrm{disc}_r$; by Lemma 3.2(2) the descent of $\mathrm{gr}_P$ goes the other way; and Lemma 3.2(3) shows the two are mutually inverse already at the level of tuples, hence on orbits. $\square$

**Theorem 3.4 (Rank collapse).** For every finite-orbit action and every pattern $P$ of length $k$,
$$m_P \;=\; t_{\operatorname{rank}P}.$$
No relation between $k$ and $n = |X|$ is assumed.

*Proof.* Take cardinalities in Proposition 3.3 and use $t_r = m_{\mathrm{disc}_r}$. $\square$

Two remarks. First, the theorem *strictly generalises* Proposition 1.1: the earlier statements all carried the hypothesis $k \le n$, which is now needed only where injective $k$-tuples must exist. Second, the bijection is natural — it involves no arbitrary choices beyond the canonical leader enumeration, and it is an isomorphism of $G$-sets before passing to quotients.

---

## 4. The Stirling expansion

**Theorem 4.1 (Row sums).** $\displaystyle B_k = \sum_{r=0}^{k} S(k,r)$.

*Proof.* Partition $\Pi_k$ by rank; every rank lies in $\{0,\dots,k\}$ since $\operatorname{rank}P \le k$. $\square$

**Theorem 4.2 (Triangularity).** $S(k,k) = 1$: a pattern of length $k$ has rank $k$ if and only if it is the discrete pattern.

*Proof sketch.* If $|L(P)| = k$ then $L(P)$ is all of $\{1,\dots,k\}$, so every index is a leader, so $P(i) = i$ for all $i$. $\square$

**Theorem 4.3 (Spectral expansion).** For finite $X$ and every $k \ge 0$,
$$\#(X^k/G) \;=\; \sum_{r=0}^{k} S(k,r)\, t_r .$$

*Proof.* By Proposition 1.1(1) (valid without the cardinality hypothesis, being merely the fibre decomposition of $\pi_k$) and Theorem 3.4,
$$\#(X^k/G) = \sum_{P\in\Pi_k} m_P = \sum_{P\in\Pi_k} t_{\operatorname{rank}P} = \sum_{r=0}^{k} \; \sum_{\substack{P \in \Pi_k \\ \operatorname{rank}P = r}} t_r = \sum_{r=0}^{k} S(k,r)\,t_r. \qquad\square$$

The identity of Theorem 4.1 is the special case in which all $t_r$ equal $1$ — i.e. the $k$-transitive case — so the Bell floor and the row-sum identity for Stirling numbers are the same statement seen from two sides.

**Corollary 4.4 (Moment form).** If moreover $G$ is finite, then by (1.1)
$$\sum_{g \in G} |\mathrm{Fix}(g)|^k \;=\; \Bigl(\sum_{r=0}^{k} S(k,r)\, t_r\Bigr)\,|G| .$$

---

## 5. Monotonicity and the top-fibre criterion

**Lemma 5.1 (Prolongation).** Let $X$ be finite with $|X| = n$ and let $r+1 \le n$. Then the map "forget the last coordinate", from orbits of injective $(r+1)$-tuples to orbits of injective $r$-tuples, is surjective.

*Proof sketch.* Given an injective $r$-tuple $h$, its image misses at least one point of $X$, since $r < n$; adjoining such a point as an $(r+1)$-st coordinate yields an injective $(r+1)$-tuple restricting to $h$. Forgetting the last coordinate is $G$-equivariant, so it descends to orbits, and the construction above provides a preimage for each orbit. $\square$

**Theorem 5.2 (Monotonicity).** For finite $X$ and $r+1 \le n$: $t_r \le t_{r+1}$. Hence
$$1 = t_0 \le t_1 \le \cdots \le t_n .$$

*Proof.* A surjection between finite sets cannot decrease cardinality; apply Lemma 5.1 and induct. $\square$

**Theorem 5.3 (Transitivity criterion).** Let $r \le n$. Then $t_r = 1$ if and only if the action is $r$-transitive.

*Proof sketch.* $t_r$ counts the orbits of injective $r$-tuples, and such tuples exist because $r \le n$; "exactly one orbit" is verbatim $r$-transitivity. $\square$

**Theorem 5.4 (Top-fibre criterion).** For $k \le n$, the action is $k$-transitive if and only if the single fibre over the discrete pattern is a singleton, i.e. $m_{\mathrm{disc}_k} = 1$.

**Theorem 5.5 (One fibre controls all).** For $k \le n$,
$$\bigl(\forall P \in \Pi_k,\; m_P = 1\bigr) \iff m_{\mathrm{disc}_k} = 1 .$$

*Proof.* ($\Rightarrow$) Immediate. ($\Leftarrow$) Let $P$ be any pattern and $r := \operatorname{rank}P \le k \le n$. Then $1 \le t_r$ (there is at least one orbit of injective $r$-tuples) and $t_r \le t_k = 1$ by monotonicity, so $t_r = 1$; by rank collapse $m_P = t_r = 1$. $\square$

Theorem 5.5 upgrades Proposition 1.1(3) from a test of $B_k$ quantities to a test of one, and does so structurally: the discrete fibre *dominates* all others because rank is bounded by $k$ and the spectrum is monotone.

---

## 6. Inversion, rigidity and degeneration

**Theorem 6.1 (Spectral inversion).** For finite $X$ and every $k$,
$$\#(X^k/G) \;=\; \Bigl(\sum_{r < k} S(k,r)\,t_r\Bigr) \;+\; t_k, \qquad\text{i.e.}\qquad t_k = \#(X^k/G) - \sum_{r<k} S(k,r)\,t_r .$$

*Proof.* Split off the top term of Theorem 4.3 and use $S(k,k) = 1$ (Theorem 4.2). $\square$

The point is that the expansion is *unitriangular over $\mathbb{Z}$*, so it is invertible with integer coefficients and, run as a recursion, needs no division whatever. This yields:

**Theorem 6.2 (Rigidity).** Let $G$ act on a finite $X$ and $H$ on a finite $Y$. Then
$$\bigl(\forall k,\; \#(X^k/G) = \#(Y^k/H)\bigr) \iff \bigl(\forall r,\; t_r(G,X) = t_r(H,Y)\bigr).$$

*Proof sketch.* ($\Leftarrow$) is Theorem 4.3 term by term. ($\Rightarrow$) is strong induction on $k$: assuming the spectra agree below $k$, the two instances of Theorem 6.1 have equal left-hand sides and equal partial sums, so the residual terms $t_k$ agree. $\square$

**Theorem 6.3 (Vanishing).** If $r > n$ then $t_r = 0$: there are no injective $r$-tuples.

Combining Theorems 6.2 and 6.3: the entire infinite sequence $k \mapsto \#(X^k/G)$ is equivalent to the finite monotone vector $(t_0,\dots,t_n) \in \mathbb{N}^{n+1}$, with $t_0 = 1$. In the sum of Theorem 4.3 only the terms with $r \le \min(k,n)$ contribute.

**Theorem 6.4 (Degeneration to the trivial action).** For all $n, k \ge 0$,
$$n^k \;=\; \sum_{r=0}^{k} S(k,r)\, n^{\underline r}.$$

*Proof sketch.* Let the trivial group act on a set of $n$ elements. Then each orbit is a single tuple, so $\#(X^k/G) = n^k$; and $t_r$ is the number of injective $r$-tuples, which is $n^{\underline r}$ (an injective $r$-tuple is an embedding of an $r$-element index set into an $n$-element set). Substitute into Theorem 4.3. $\square$

This is the classical change of basis between ordinary powers and falling factorials, obtained here purely from orbit counting, with $S(k,r)$ *defined* as a count of patterns. Together with Section 8 it certifies that our $S$ really is the Stirling triangle of the second kind.

**Example 6.5.** $n^3 = n^{\underline 1} + 3n^{\underline 2} + n^{\underline 3}$ and $n^4 = n^{\underline 1} + 7 n^{\underline 2} + 6 n^{\underline 3} + n^{\underline 4}$; at $n = 5$, $k = 4$: $625 = 5 + 7\cdot 20 + 6\cdot 60 + 120$.

---

## 7. The order bound and a strict Bell defect

The results so far are internal to the combinatorics of the action. We now bound the spectrum from outside, using nothing but $|G|$.

**Theorem 7.1 (Orbit–stabiliser form).** Let $X$ and $G$ be finite, $k \le n$, and suppose the action is $k$-transitive. Then
$$n^{\underline k} \;\bigm|\; |G| .$$

*Proof sketch.* Fix an injective $k$-tuple $u$ (one exists since $k \le n$). Under $k$-transitivity the orbit of $u$ in $X^k$ is precisely the set of *all* injective $k$-tuples: an element of the orbit is a translate $g\cdot u$, hence injective, and conversely transitivity supplies a $g$ carrying $u$ to any prescribed injective tuple. The number of injective $k$-tuples is $n^{\underline k}$. By orbit–stabiliser, the orbit length equals the index $[G : \mathrm{Stab}(u)]$, which divides $|G|$. $\square$

**Theorem 7.2 (Order bound).** Under the hypotheses of Theorem 7.1, $n^{\underline k} \le |G|$.

*Proof.* Either from Theorem 7.1, or directly: $g \mapsto g\cdot u$ is a surjection from $G$ onto the set of injective $k$-tuples. $\square$

**Theorem 7.3 (Forced degeneracy).** Let $k \le n$ and $|G| < n^{\underline k}$. Then $t_k \ge 2$.

*Proof.* $t_k \ge 1$ because injective $k$-tuples exist. If $t_k = 1$ then the action is $k$-transitive (Theorem 5.3), so $n^{\underline k}\le |G|$ by Theorem 7.2, contradicting the hypothesis. $\square$

**Theorem 7.4 (Strict Bell defect).** Let $k \le n$ and $|G| < n^{\underline k}$. Then
$$\#(X^k/G) \;\ge\; B_k + 1, \qquad\text{and consequently}\qquad \sum_{g\in G} |\mathrm{Fix}(g)|^k \;\ge\; (B_k+1)\,|G| .$$

*Proof.* By Theorem 6.1, $\#(X^k/G) = \sum_{r<k} S(k,r) t_r + t_k$. Every $t_r$ with $r \le k \le n$ satisfies $t_r \ge 1$, so $\sum_{r<k}S(k,r)t_r \ge \sum_{r<k}S(k,r) = B_k - S(k,k) = B_k - 1$ using Theorems 4.1 and 4.2. Adding $t_k \ge 2$ from Theorem 7.3 gives $\#(X^k/G) \ge B_k + 1$. The moment statement follows from (1.1). $\square$

Thus a purely arithmetic comparison of two integers — the group order against a falling factorial — certifies a *strict* inequality for a moment of the fixed-point statistic. No structural knowledge of $G$ is used.

**Theorem 7.5 (Rank-resolved Bell defect).** Let $G$ be finite and $k \le n$. Then
$$\sum_{g\in G} |\mathrm{Fix}(g)|^k \;=\; \Bigl(B_k + \sum_{r=0}^{k} S(k,r)\,(t_r - 1)\Bigr)|G| .$$

*Proof.* Each $t_r$ with $r \le k \le n$ satisfies $t_r \ge 1$, so $t_r = 1 + (t_r - 1)$ with a genuine natural number in the bracket; substituting into Corollary 4.4 and using $B_k = \sum_r S(k,r)$ gives the claim. $\square$

The formula displays the excess of the $k$-th moment over its Bell value as a weighted sum of *transitivity defects* $t_r - 1$, the weight of rank $r$ being the number $S(k,r)$ of patterns with $r$ blocks. Every failure of $r$-transitivity contributes, and only through the single number $t_r$.

---

## 8. The Stirling triangle from the pattern model

The coefficients $S(k,r)$ were *defined* as pattern counts. We now prove intrinsically that they obey the classical recurrence, so that no numerical check is needed to identify them.

**Theorem 8.1 (Recurrence).** For all $k, r \ge 0$,
$$S(k+1, r+1) \;=\; S(k,r) \;+\; (r+1)\,S(k,r+1).$$

*Proof sketch.* Classify patterns $P$ of length $k+1$ by their value at the last index $k+1$. Restriction to the first $k$ indices is well-defined (the value of $P$ at any $i \le k$ is $\le i \le k$, so it never equals $k+1$) and yields a pattern $Q$ of length $k$; conversely $P$ is recovered from $Q$ together with $P(k+1)$, and the admissible values for $P(k+1)$ are exactly $k+1$ itself (opening a new block) or a leader of $Q$ (joining that block). Hence
$$\{\text{patterns of length }k+1\} \;\longleftrightarrow\; \{(Q, j) : Q \in \Pi_k,\; j \in \{k+1\} \cup L(Q)\},$$
a bijection under which the rank behaves as follows: if $j = k+1$ then $\operatorname{rank}P = \operatorname{rank}Q + 1$; if $j \in L(Q)$ then $\operatorname{rank}P = \operatorname{rank}Q$. Counting patterns of rank $r+1$ therefore splits into: those from $Q$ of rank $r$ opening a new block — there are $S(k,r)$ of these — and those from $Q$ of rank $r+1$ joining one of its $|L(Q)| = r+1$ blocks, giving $(r+1)S(k,r+1)$. The two families are disjoint and exhaust. $\square$

**Theorem 8.2 (Boundary values).** $S(0,0) = 1$; $S(0,r+1) = 0$; $S(k+1,0) = 0$; and $S(k,r) = 0$ for $r > k$.

*Proof sketch.* The empty index set has exactly one pattern, of rank $0$; a nonempty index set has at least one block, so rank $\ge 1$; and rank $\le k$ always. $\square$

**Theorem 8.3 (Uniqueness).** If $f : \mathbb{N}\times\mathbb{N}\to\mathbb{N}$ satisfies $f(0,0)=1$, $f(0,r+1)=0$, $f(k+1,0)=0$ and $f(k+1,r+1) = f(k,r) + (r+1)f(k,r+1)$, then $f = S$.

*Proof.* Induction on the first argument, with a case split on the second. $\square$

Hence $S$ is exactly the classical Stirling triangle of the second kind, and Theorem 4.3 is genuinely a Stirling transform. The first rows are
$$S(k,\cdot) = (1),\;(0,1),\;(0,1,1),\;(0,1,3,1),\;(0,1,7,6,1),\;(0,1,15,25,10,1),$$
with row sums $1,1,2,5,15,52 = B_k$.

---

## 9. Worked examples

We tabulate spectra $(t_0,\dots,t_n)$ and the resulting orbit counts; all entries follow from Theorem 4.3 and can be confirmed by direct enumeration.

| action | $n$ | $|G|$ | spectrum $(t_r)$ | $\#(X^k/G)$, $k=0..4$ |
|---|---|---|---|---|
| $S_4$ on $4$ points | 4 | 24 | $(1,1,1,1,1)$ | $1,1,2,5,15$ |
| $A_4$ on $4$ points | 4 | 12 | $(1,1,1,2,2)$ | $1,1,2,6,22$ |
| $D_4$ on the square | 4 | 8 | $(1,1,2,3,3)$ | $1,1,3,10,36$ |
| $C_4$ regular on $4$ points | 4 | 4 | $(1,1,3,6,6)$ | $1,1,4,16,64$ |
| Klein four, regular | 4 | 4 | $(1,1,3,6,6)$ | $1,1,4,16,64$ |
| $\mathrm{AGL}(1,5)$ on $5$ points | 5 | 20 | $(1,1,1,3,6,6)$ | $1,1,2,7,\ \cdot$ |
| $C_5$ regular on $5$ points | 5 | 5 | $(1,1,4,12,24,24)$ | $1,1,5,25,\ \cdot$ |
| trivial group on $3$ points | 3 | 1 | $(1,3,6,6)$ | $1,3,9,27,81$ |

Several features of the theory are visible.

- The **initial run of $1$s** in the spectrum has length equal to the degree of transitivity: $4$ for $S_4$, $2$ for $A_4$ and $\mathrm{AGL}(1,5)$, $1$ for $D_4$ and $C_5$, $0$ for the trivial group (Theorem 5.3).
- $S_4$ attains the **Bell floor** at every $k \le 4$; the others exceed it as soon as the spectrum leaves the value $1$. For $A_4$ at $k=3$: $\#(X^3/G) = 1\cdot 1 + 3\cdot 1 + 1\cdot 2 = 6 = B_3 + 1$, exactly the strict defect of Theorem 7.4, since $|A_4| = 12 < 4^{\underline 3} = 24$.
- The **spectrum plateaus** at the top: $t_n = t_{n-1}$ always, since injective $n$-tuples and injective $(n-1)$-tuples are in canonical bijection (the missing point is determined).
- **Regular actions** ($|G| = n$, sharply $1$-transitive) have $t_r = n^{\underline r}/n$ for $r \ge 1$; this depends only on $n$, not on the group. That is why $C_4$ and the Klein four-group, which are not isomorphic, have identical spectra and identical orbit counts $4^{k-1}$ for $k \ge 1$. The spectrum is thus an invariant of the *action*, and a coarse one: it does not determine $G$.
- The **trivial group** row instantiates Theorem 6.4: $t_r = 3^{\underline r} = 1,3,6,6$ and $\#(X^k/G) = 3^k$.
- The **rank-resolved moment formula** at $D_4$, $k = 4$: defects $(t_r - 1) = (0,0,1,2,2)$, weights $S(4,\cdot) = (0,1,7,6,1)$, so the moment is $\bigl(15 + 7 + 12 + 2\bigr)\cdot 8 = 36 \cdot 8 = 288$, matching $\sum_g |\mathrm{Fix}(g)|^4$ over the eight symmetries of the square (fixed-point counts $4,0,0,0,2,2,0,0$ give $256 + 16 + 16 = 288$).

---

## 10. Algorithms

The theory converts an exponential computation into a small one.

**Algorithm A (Spectrum by enumeration).** Compute $t_r$ for $r = 0,\dots,n$ by enumerating injective $r$-tuples and grouping them into $G$-orbits with a union–find or BFS over generators. Cost: $O\!\left(\sum_r n^{\underline r}\cdot |{\rm gens}|\right)$, dominated by $r = n$.

**Algorithm B (Orbit counts from the spectrum).** Build the Stirling triangle up to $k$ by the recurrence of Theorem 8.1 in $O(k^2)$ integer operations, then evaluate $\#(X^k/G) = \sum_{r\le \min(k,n)} S(k,r)t_r$. This replaces an enumeration of $n^k$ tuples by $O(k^2)$ arithmetic: for $n=8$ and $k=20$ it is the difference between $10^{18}$ tuples and a few hundred multiplications.

**Algorithm C (Spectrum from orbit counts — triangular inversion).** Given $\#(X^k/G)$ for $k = 0,\dots,K$, recover $t_k = \#(X^k/G) - \sum_{r<k}S(k,r)t_r$ for $k = 0,1,2,\dots$ Each step is exact in $\mathbb{Z}$ by Theorem 4.2, and by Theorem 6.2 the output is the unique spectrum consistent with the data; the computation also serves as a consistency check, since a negative or non-monotone output certifies that the input sequence is not the tuple-orbit sequence of any action.

**Algorithm D (Transitivity certificate).** To decide $k$-transitivity: first test the arithmetic obstruction $n^{\underline k} \mid |G|$ (Theorem 7.1) — if it fails, the answer is *no*, at a cost of one division. Otherwise compute the single number $t_k$ and compare it to $1$ (Theorem 5.4); no other fibre need be examined.

---

## 11. Discussion

**What the spectrum is.** The number $t_r$ is, in classical language, the number of orbits of $G$ on ordered $r$-tuples of distinct points — the *$r$-th ordered orbit number* of the permutation group. That such data controls tuple-orbit counts is not itself surprising; what the present development supplies is the precise mechanism (a natural fibrewise bijection, valid with no cardinality hypotheses), the exact transform (the Stirling triangle, identified intrinsically from the pattern model), its exact inverse (unitriangular over $\mathbb{Z}$, hence division-free), and the arithmetic obstruction that turns the resulting inequality into a strict one.

**Why the collapse is the right statement.** The naive picture has $B_k$ unknowns $m_P$ at level $k$, so $\sum_{k\le K} B_k$ unknowns up to level $K$ — superexponentially many. The rank collapse reduces them to $n+1$, once and for all, independently of $K$. All the structure theorems then become statements about a short monotone vector: the Bell floor is "all entries $\ge 1$", $k$-transitivity is "the first $k+1$ entries are $1$", the strict defect is "the $k$-th entry is $\ge 2$".

**Sharpness.** The Bell floor is attained exactly on $k$-transitive actions, and $k$-transitive actions exist for every $k \le n$ (take $G = S_n$), so the inequality $\#(X^k/G)\ge B_k$ is sharp for all $k \le n$. The defect $\#(X^k/G) \ge B_k + 1$ under $|G| < n^{\underline k}$ is also sharp: $A_4$ acting on four points has $|G| = 12 < 24 = 4^{\underline 3}$ and $\#(X^3/G) = 6 = B_3 + 1$.

**Limits of the invariant.** The spectrum is an invariant of the action, not of the group: any two regular actions of groups of the same order share a spectrum (Section 9). It is also insensitive to much finer structure — two actions can have equal spectra while differing in, say, their permutation characters as $G$-modules over particular fields. Understanding exactly which pairs of actions the spectrum fails to separate is the natural next problem.

**Relation to fixed-point statistics.** Via Burnside, the spectrum is a change of basis for the moment sequence of $|\mathrm{Fix}(\cdot)|$. In the basis of ordinary powers the moments are the orbit counts; in the falling-factorial basis they are the spectrum, up to the weighting by $|G|$. The identity $n^k = \sum_r S(k,r)n^{\underline r}$ is the $G = 1$ shadow of this change of basis, which explains why Stirling numbers must appear here and not, say, binomial coefficients.

---

## 12. Future directions

The following problems arise directly from the results above and are stated so as to be decidable within the same framework.

**Problem 1 (Spectral completeness of the moment vector).** For finite $G$-sets $X$ and $H$-sets $Y$, are the following equivalent? (a) the spectra agree, $t_r(G,X) = t_r(H,Y)$ for all $r$; (b) the orbit counts agree, $\#(X^k/G) = \#(Y^k/H)$ for all $k$; (c) the normalised moment vectors agree,
$$\frac{1}{|G|}\sum_{g\in G}|\mathrm{Fix}(g)|^k \;=\; \frac{1}{|H|}\sum_{h\in H}|\mathrm{Fix}(h)|^k \quad\text{for all } k .$$
Here (a) $\Leftrightarrow$ (b) is Theorem 6.2, and (b) $\Leftrightarrow$ (c) is immediate from Burnside for a fixed group; the cross-group normalised version requires transporting the Burnside identity between two different groups. Since triangularity makes the Stirling expansion invertible over $\mathbb{N}$, the whole tower of orbit counts is encoded in one monotone sequence of length $n+1$; a failure of the equivalence would exhibit two actions with equal moments but different spectra.

**Problem 2 (Strict growth below the transitivity degree).** Suppose the action is $(r-1)$-transitive but not $r$-transitive, and $r + 1 \le n$. Is $t_{r+1} > t_r$? More boldly, is $t_{r+1} \ge 2t_r - 1$ — i.e. does a failure of transitivity amplify as the tuple length grows? Monotonicity (Theorem 5.2) gives $\ge$; the content is strictness and the amplification rate, which would sharpen the Bell defect from an additive to a multiplicative statement.

**Problem 3 (Spectral classification of small-degree actions).** Determine which monotone vectors $(1 = t_0 \le t_1 \le \dots \le t_n)$ with $t_{n} = t_{n-1}$ actually occur as spectra. Necessary conditions are known — monotonicity, the plateau $t_n = t_{n-1}$ at the top, and the divisibility $n^{\underline k} \mid |G|$ when the initial run of $1$s has length $k+1$. A complete characterisation for small $n$ would be a finite computation, and the pattern of realisable vectors would be the direct analogue, in this setting, of the classification of multiply transitive groups.

**Problem 4 (Infinite and profinite settings).** The rank collapse uses no finiteness of $X$ beyond the finiteness of the fibres. For an oligomorphic action — one with finitely many orbits on $X^k$ for every $k$ — the spectrum becomes an infinite monotone sequence and the Stirling expansion holds verbatim. What does the growth rate of $t_r$ say about the model-theoretic properties of the associated structure?

**Problem 5 (Effective inverse problem).** Given a candidate sequence $c_0, c_1, \dots, c_K$, decide efficiently whether it is the initial segment of a tuple-orbit sequence. Triangular inversion produces a candidate spectrum; the constraints "non-negative", "monotone", "$t_0 = 1$", "$t_r = 0$ eventually" are necessary. Are they sufficient, and if not, what is the complete list?

---

## 13. Conclusion

The orbit–pattern map fibres the orbits of a group action on $k$-tuples over the Bell-many coincidence patterns, and every one of its fibres is determined by a single number: the fibre over a pattern of rank $r$ has size $t_r$, the number of orbits of injective $r$-tuples. Consequently the whole tower of tuple-orbit counts is the Stirling transform of one monotone vector of length $n+1$, and the transform is invertible over the integers, so no information is lost either way. Within this picture, $k$-transitivity is the statement that the vector begins with $k+1$ ones; the Bell floor is the statement that all entries are at least one; the failure of $k$-transitivity is measured entry by entry; and a comparison of the group order with a falling factorial suffices to force a strict violation of the floor, hence a strict lower bound on a moment of the fixed-point statistic. The Stirling numbers appearing throughout are not imported: they are the pattern counts themselves, shown from the model to satisfy the classical recurrence and boundary conditions that characterise them, with the classical identity $n^k = \sum_r S(k,r)n^{\underline r}$ falling out as the symmetry-free special case.
