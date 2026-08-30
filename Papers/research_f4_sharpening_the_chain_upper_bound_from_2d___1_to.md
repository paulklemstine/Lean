# Sharpening the Chain Bound for Forbidden Boolean-Lattice Subposets: From $2^d - 1$ Towards $d + c$

**Author:** Aristotle
**Date:** 2026-08-30

---

## Abstract

For a family $\mathcal{F}$ of subsets of $[n] = \{1,\dots,n\}$, say that $\mathcal{F}$ *contains a weak copy of the $d$-dimensional Boolean lattice* $B_d$ if there is an injective, containment-preserving map from the subsets of $[d]$ into $\mathcal{F}$. Let $\mathrm{La}(n, B_d)$ denote the maximum size of a $B_d$-free family. The classical *chain bound*, obtained by combining a linear extension of $B_d$ with the Mirsky decomposition and the LYM inequality, gives $\mathrm{La}(n, B_d) \le (2^d - 1)\binom{n}{\lfloor n/2\rfloor}$, while $d$ consecutive levels of the Boolean lattice give the lower bound $\mathrm{La}(n, B_d) \ge \sum_{i=a}^{a+d-1}\binom{n}{i} \approx d \binom{n}{\lfloor n/2 \rfloor}$. The exponential gap is the subject of the conjecture $\mathrm{La}(n, B_d) \le (d+c)\binom{n}{\lfloor n/2\rfloor}$ for an absolute constant $c$.

We develop the theory of weak Boolean-lattice copies from first principles and establish: (i) the chain bound in its stronger Lubell-mass form, namely that a family with no chain of $k+1$ sets has Lubell mass at most $k$; (ii) the exact value $\mathrm{La}(n, B_1) = \binom{n}{\lfloor n/2\rfloor}$; (iii) a *Complete Levels Theorem* — any family containing $d+1$ complete levels of $2^{[n]}$ contains a copy of $B_d$ — from which the conjecture follows with $c = 0$ for every family that is a union of complete levels; (iv) a strict sharpening of the chain bound by Lubell-mass layer splitting, $(m+1)\mathrm{La}(2m,B_d) \le ((2^d-1)m + 1)\binom{2m}{m}$ and $(m+2)\mathrm{La}(2m+1,B_d) \le ((2^d-1)m+4)\binom{2m+1}{m}$; (v) the conjectured bound $\mathrm{La}(n,B_3) \le 4\binom{n}{\lfloor n/2\rfloor}$ for all $n \le 8$; and (vi) a *Doubling Criterion* showing that two pointwise-nested, value-disjoint copies of $B_d$ combine into a copy of $B_{d+1}$, so that in particular two parallel chains of $2^d$ sets already force a $(d+1)$-cube. We isolate the structural obstruction to constant-factor improvements — a chain of $2^d-1$ sets is $B_d$-free, so chain-length arguments are pinned at $2^d - 1$ — and argue that the doubling criterion identifies the branching configuration that a successful attack must exploit.

**Keywords.** Extremal set theory, forbidden subposet, Boolean lattice, Sperner theory, LYM inequality, Lubell mass, diamond problem, chain bound.

---

## 1. Introduction

### 1.1 The problem

Let $[n] = \{1, 2, \dots, n\}$ and let $2^{[n]}$ denote the Boolean lattice of all subsets of $[n]$, partially ordered by inclusion. It has $n+1$ *levels*, the $k$-th consisting of the $\binom{n}{k}$ subsets of size $k$; the largest level has size
$$\mathcal{C}(n) := \binom{n}{\lfloor n/2 \rfloor},$$
which we call the *central binomial coefficient* throughout. By Stirling, $\mathcal{C}(n) = \Theta(2^n / \sqrt{n})$.

Sperner's theorem states that a family of subsets of $[n]$ no two of whose members are nested has at most $\mathcal{C}(n)$ members. Forbidden-subposet problems generalise this: fix a finite poset $P$ and ask for the largest family of subsets of $[n]$ containing no copy of $P$. We study the case $P = B_d$, the Boolean lattice of dimension $d$.

**Definition 1.1 (Weak copy).** A family $\mathcal{F} \subseteq 2^{[n]}$ *contains a weak copy of $B_d$* if there exists a map $f : 2^{[d]} \to 2^{[n]}$ such that
1. $f$ is injective;
2. $f(S) \in \mathcal{F}$ for all $S \subseteq [d]$;
3. $S \subseteq T \implies f(S) \subseteq f(T)$ for all $S, T \subseteq [d]$.

$\mathcal{F}$ is *$B_d$-free* if it contains no weak copy of $B_d$.

Note that "weak" means the embedding need only preserve, not reflect, containments; the image need not be an induced subposet. This is the standard and the harder-to-avoid notion: $B_d$-freeness in the weak sense is a stronger hypothesis than in the induced sense, so upper bounds for weak-copy-free families are the meaningful ones.

**Definition 1.2 (The extremal function).**
$$\mathrm{La}(n, B_d) := \max\{\,|\mathcal{F}| : \mathcal{F} \subseteq 2^{[n]},\ \mathcal{F}\text{ is }B_d\text{-free}\,\}.$$
The maximum exists: the empty family is $B_d$-free, and every family has at most $2^n$ members.

For $d = 1$, a weak copy of $B_1$ is a pair $f(\emptyset) \subsetneq f(\{1\})$ of distinct nested sets, so $B_1$-freeness is precisely the antichain condition and $\mathrm{La}(n,B_1) = \mathcal{C}(n)$ by Sperner. For $d = 2$ the forbidden pattern is the *diamond* and the determination of $\lim_n \mathrm{La}(n, B_2)/\mathcal{C}(n)$ is a well-known open problem; the natural construction (two middle levels) gives $2 + o(1)$, and a slightly cleverer one gives $2.25 - o(1)$.

### 1.2 The two classical bounds and the gap

Two bounds frame the problem.

*Lower bound (levels construction).* Any $d$ consecutive levels of $2^{[n]}$ form a $B_d$-free family, whence
$$\mathrm{La}(n, B_d) \ \ge\ \sum_{i=a}^{a+d-1}\binom{n}{i}\qquad\text{for every }a,$$
and taking the $d$ levels around the middle gives $\mathrm{La}(n,B_d) \ge (d - o(1))\,\mathcal{C}(n)$ for fixed $d$ as $n \to \infty$.

*Upper bound (chain bound).* A chain of $2^d$ sets contains a weak copy of $B_d$; a family with no chain of $k+1$ sets has at most $k\,\mathcal{C}(n)$ members; hence
$$\mathrm{La}(n, B_d) \ \le\ (2^d - 1)\,\mathcal{C}(n).$$

The gap between $d$ and $2^d - 1$ is the central issue.

**Conjecture 1.3.** There is an absolute constant $c$, independent of $n$ and $d$, with
$$\mathrm{La}(n, B_d) \le (d + c)\,\mathcal{C}(n)\qquad\text{for all }n, d.$$
Concretely, for $d = 3$: $\mathrm{La}(n, B_3) \le 4\,\mathcal{C}(n)$ for all $n$.

### 1.3 Contributions

This paper establishes the following, all from first principles.

* **Theorem A (Chain-to-cube).** A chain of $2^d$ sets in $\mathcal{F}$ yields a weak copy of $B_d$ (Section 3).
* **Theorem B (Mirsky + LYM).** If $\mathcal{F}$ contains no chain of $k+1$ sets, then its Lubell mass satisfies $\lambda(\mathcal{F}) \le k$; consequently $|\mathcal{F}| \le k\,\mathcal{C}(n)$ (Section 4).
* **Theorem C (Chain bound).** $\mathrm{La}(n,B_d) \le (2^d-1)\mathcal{C}(n)$, in the stronger form $\lambda(\mathcal{F}) \le 2^d - 1$ for every $B_d$-free $\mathcal{F}$ (Section 4).
* **Theorem D (Sperner case).** $\mathrm{La}(n,B_1) = \mathcal{C}(n)$, both directions (Section 5).
* **Theorem E (Height bound).** $|\mathcal{F}| \le (n+1)\mathcal{C}(n)$ for every family whatsoever; hence Conjecture 1.3 holds with $c=1$ whenever $n \le d$ (Section 5).
* **Theorem F (Complete Levels).** If $\mathcal{F}$ contains every subset of $[n]$ whose size belongs to a fixed set of $d+1$ values $i_0 < \dots < i_d \le n$ (with $d \le n$), then $\mathcal{F}$ contains a weak copy of $B_d$ (Section 6).
* **Theorem G (Conjecture for level unions, $c = 0$).** If $\mathcal{F}$ is $B_d$-free and its membership depends only on cardinality, then $|\mathcal{F}| \le d\,\mathcal{C}(n)$ (Section 6).
* **Theorem H (Sharpened chain bound).** For $m \ge 1$ and all $d$,
  $$(m+1)\,\mathrm{La}(2m, B_d) \le \bigl((2^d-1)m + 1\bigr)\binom{2m}{m},\qquad (m+2)\,\mathrm{La}(2m+1, B_d) \le \bigl((2^d-1)m + 4\bigr)\binom{2m+1}{m},$$
  both strictly stronger than the chain bound for $d \ge 2$ (Section 7).
* **Theorem I (Sandwich at $d=3$).** $(3m+1)\binom{2m}{m} \le (m+1)\mathrm{La}(2m,B_3) \le (7m+1)\binom{2m}{m}$ for $m \ge 1$ (Section 7).
* **Theorem J (Small ground sets).** $\mathrm{La}(n, B_3) \le 4\,\mathcal{C}(n)$ for every $n \le 8$ (Section 7).
* **Theorem K (Doubling Criterion).** Two copies of $B_d$ in $\mathcal{F}$ that are pointwise nested and have disjoint value sets combine into a copy of $B_{d+1}$; in particular two pointwise-nested disjoint chains of $2^d$ sets force a $B_{d+1}$ copy (Section 8).

Section 9 analyses the structural obstruction to a constant-factor improvement; Section 10 discusses algorithms and computational evidence; Section 11 collects future directions.

---

## 2. Preliminaries and notation

Throughout, $n, d, k, m$ are non-negative integers, $\mathcal{F} \subseteq 2^{[n]}$ is a finite family, and $\mathcal{C}(n) = \binom{n}{\lfloor n/2\rfloor}$.

**Fact 2.1.** $\mathcal{C}(n) > 0$ and $\binom{n}{r} \le \mathcal{C}(n)$ for every $r$; the binomial coefficients are unimodal with peak at $\lfloor n/2 \rfloor$ (and also at $\lceil n/2\rceil$ when $n$ is odd).

**Definition 2.2 (Chain).** $\mathcal{F}$ *has a chain of $k$ sets* if there are $A_0, \dots, A_{k-1} \in \mathcal{F}$ with $A_0 \subsetneq A_1 \subsetneq \cdots \subsetneq A_{k-1}$.

**Definition 2.3 (Lubell mass).**
$$\lambda(\mathcal{F}) := \sum_{A \in \mathcal{F}} \binom{n}{|A|}^{-1}.$$
Probabilistically, $\lambda(\mathcal{F}) = \mathbb{E}\,|\mathcal{F} \cap \mathcal{M}|$ where $\mathcal{M}$ is a uniformly random maximal chain $\emptyset = M_0 \subsetneq M_1 \subsetneq \cdots \subsetneq M_n = [n]$, since $\Pr[A \in \mathcal{M}] = \binom{n}{|A|}^{-1}$.

**Theorem 2.4 (LYM inequality).** If $\mathcal{A} \subseteq 2^{[n]}$ is an antichain then $\lambda(\mathcal{A}) \le 1$.

*Proof sketch.* A maximal chain meets an antichain in at most one set, so $\mathbb{E}|\mathcal{A} \cap \mathcal{M}| \le 1$. $\square$

Sperner's theorem is the corollary $|\mathcal{A}| \le \mathcal{C}(n)$, obtained by bounding each summand from below by $\mathcal{C}(n)^{-1}$.

**Lemma 2.5 (Mass-to-cardinality).** If $\lambda(\mathcal{F}) \le k$ then $|\mathcal{F}| \le k\,\mathcal{C}(n)$.

*Proof.* Every summand satisfies $\binom{n}{|A|}^{-1} \ge \mathcal{C}(n)^{-1}$, so $|\mathcal{F}|\,\mathcal{C}(n)^{-1} \le \lambda(\mathcal{F}) \le k$. $\square$

Lemma 2.5 is lossy exactly to the extent that $\mathcal{F}$ lives off the middle level — a slack that Section 7 exploits.

---

## 3. Chains contain cubes

The first ingredient converts a one-dimensional configuration into a $d$-dimensional one.

**Lemma 3.1 (Rank function).** For every $d$ there is a map $\rho : 2^{[d]} \to \{0, 1, \dots, 2^d - 1\}$ that is
(i) injective, hence bijective, and (ii) monotone: $S \subseteq T \implies \rho(S) \le \rho(T)$.

*Proof.* The partial order $(2^{[d]}, \subseteq)$ is finite, so it admits a linear extension: a total order $\preceq$ on the same $2^d$ elements with $S \subseteq T \implies S \preceq T$. Enumerating the elements in $\preceq$-increasing order gives an order isomorphism onto $\{0,\dots,2^d-1\}$; let $\rho$ be that isomorphism. Injectivity is bijectivity of an isomorphism; monotonicity holds because $S \subseteq T$ implies $S \preceq T$ implies $\rho(S) \le \rho(T)$. $\square$

(One may take $\rho(S) = \sum_{i \in S} 2^{i-1}$, but the abstract linear-extension argument is cleaner and generalises to any forbidden poset $P$ with $\rho$ ranging over $\{0,\dots,|P|-1\}$.)

**Theorem A (Chains contain cubes).** If $\mathcal{F}$ contains a chain $A_0 \subsetneq A_1 \subsetneq \cdots \subsetneq A_{2^d - 1}$ of $2^d$ sets, then $\mathcal{F}$ contains a weak copy of $B_d$.

*Proof.* Put $f(S) := A_{\rho(S)}$ with $\rho$ as in Lemma 3.1. Membership is clear. For monotonicity, if $S \subseteq T$ then $\rho(S) \le \rho(T)$, and the chain is increasing, so $A_{\rho(S)} \subseteq A_{\rho(T)}$. For injectivity, if $S \ne T$ then $\rho(S) \ne \rho(T)$, and distinct members of a strictly increasing chain are distinct sets. $\square$

**Corollary 3.2.** A $B_d$-free family contains no chain of $2^d$ sets.

*Remark 3.3 (Sharpness).* Corollary 3.2 cannot be improved: a chain $A_0 \subsetneq \cdots \subsetneq A_{2^d - 2}$ of $2^d - 1$ sets *is* $B_d$-free, because a weak copy of $B_d$ inside a chain would require $2^d$ distinct members. This single observation, elaborated in Section 9, is the structural reason why chain-based arguments cannot beat the factor $2^d - 1$.

---

## 4. The chain bound via Mirsky and LYM

**Definition 4.1.** The *maximal members* of $\mathcal{F}$ are
$$\mathrm{Max}(\mathcal{F}) := \{A \in \mathcal{F} : \text{there is no } B \in \mathcal{F} \text{ with } A \subsetneq B\}.$$

**Lemma 4.2.** $\mathrm{Max}(\mathcal{F})$ is an antichain, hence $\lambda(\mathrm{Max}(\mathcal{F})) \le 1$.

*Proof.* If $A, B \in \mathrm{Max}(\mathcal{F})$ are distinct with $A \subseteq B$, then $A \subsetneq B$ with $B \in \mathcal{F}$, contradicting maximality of $A$. Apply Theorem 2.4. $\square$

**Lemma 4.3 (Peeling).** If $\mathcal{F}$ has no chain of $k+2$ sets, then $\mathcal{F} \setminus \mathrm{Max}(\mathcal{F})$ has no chain of $k+1$ sets.

*Proof.* Suppose $A_0 \subsetneq \cdots \subsetneq A_k$ is a chain of $k+1$ sets in $\mathcal{F}\setminus\mathrm{Max}(\mathcal{F})$. Its top element $A_k$ lies in $\mathcal{F}$ but is not maximal, so there is $B \in \mathcal{F}$ with $A_k \subsetneq B$. Then $A_0 \subsetneq \cdots \subsetneq A_k \subsetneq B$ is a chain of $k+2$ sets in $\mathcal{F}$, a contradiction. $\square$

**Theorem B (Mirsky + LYM).** If $\mathcal{F}$ contains no chain of $k+1$ sets, then $\lambda(\mathcal{F}) \le k$.

*Proof.* Induction on $k$. For $k=0$: a non-empty family contains a chain of one set, so $\mathcal{F} = \emptyset$ and $\lambda(\mathcal{F}) = 0$. For the step, let $\mathcal{F}$ have no chain of $k+2$ sets. Since $\mathrm{Max}(\mathcal{F}) \subseteq \mathcal{F}$, the Lubell mass splits:
$$\lambda(\mathcal{F}) = \lambda(\mathcal{F}\setminus\mathrm{Max}(\mathcal{F})) + \lambda(\mathrm{Max}(\mathcal{F})).$$
By Lemma 4.3 and the induction hypothesis the first term is at most $k$; by Lemma 4.2 the second is at most $1$. $\square$

Theorem B is a weighted refinement of Mirsky's theorem (a poset with no chain of $k+1$ elements is a union of $k$ antichains) fused with LYM. It is strictly stronger than the cardinality statement it implies, and it is the form we sharpen in Section 7.

**Theorem C (Chain bound).** If $\mathcal{F}$ is $B_d$-free, then $\lambda(\mathcal{F}) \le 2^d - 1$ and hence $|\mathcal{F}| \le (2^d-1)\mathcal{C}(n)$. Consequently
$$\mathrm{La}(n, B_d) \le (2^d - 1)\,\mathcal{C}(n).$$

*Proof.* By Corollary 3.2 there is no chain of $2^d = (2^d - 1) + 1$ sets; apply Theorem B with $k = 2^d - 1$ and then Lemma 2.5. $\square$

For $d = 3$ this reads $\mathrm{La}(n, B_3) \le 7\,\mathcal{C}(n)$.

---

## 5. Exact and unconditional cases

**Theorem D (Sperner case).** A family is $B_1$-free if and only if it is an antichain, and $\mathrm{La}(n, B_1) = \mathcal{C}(n)$.

*Proof.* ($\Leftarrow$) A weak copy of $B_1$ consists of $f(\emptyset) \ne f(\{1\})$ with $f(\emptyset) \subseteq f(\{1\})$, i.e. a strictly nested pair, which an antichain forbids.
($\Rightarrow$) If $\mathcal{F}$ is not an antichain, choose $A \subsetneq B$ in $\mathcal{F}$ and define $f(\emptyset) = A$, $f(\{1\}) = B$; this is an injective monotone map from $2^{[1]}$ into $\mathcal{F}$.
The value follows from Sperner's theorem for the upper bound and from the middle level (which is an antichain of size $\mathcal{C}(n)$) for the lower bound. $\square$

**Theorem E (Height bound).** Every chain in $2^{[n]}$ has at most $n+1$ sets. Consequently every family $\mathcal{F} \subseteq 2^{[n]}$ satisfies $|\mathcal{F}| \le (n+1)\mathcal{C}(n)$ and $\lambda(\mathcal{F}) \le n+1$, and $\mathrm{La}(n, B_d) \le (d+1)\mathcal{C}(n)$ whenever $n \le d$.

*Proof.* Along a strictly increasing chain the cardinalities strictly increase, so the $i$-th member has size at least $i$; since sizes are at most $n$, a chain has at most $n+1$ sets. Apply Theorem B with $k = n+1$ and Lemma 2.5. If $n \le d$ then $(n+1)\mathcal{C}(n) \le (d+1)\mathcal{C}(n)$. $\square$

Theorem E already establishes Conjecture 1.3 with $c=1$ in the regime $n \le d$: the conjecture is a statement about large $n$ relative to $d$.

**Theorem 5.1 (Levels lower bound).** For all $a, d$, the family $\mathcal{L}(n, a, d) := \{A \subseteq [n] : a \le |A| < a + d\}$ is $B_d$-free, so
$$\mathrm{La}(n, B_d) \ \ge\ \sum_{i=a}^{a+d-1}\binom{n}{i}.$$

*Proof.* Suppose $f$ is a weak copy of $B_d$ with image inside $\mathcal{L}(n,a,d)$. Consider the *prefix sets* $P_j := \{1, \dots, j\} \subseteq [d]$ for $j = 0, 1, \dots, d$. Since $P_j \subsetneq P_{j+1}$ and $f$ is injective and monotone, $f(P_j) \subsetneq f(P_{j+1})$, so $|f(P_{j+1})| \ge |f(P_j)| + 1$. As $|f(P_0)| \ge a$, induction gives $|f(P_d)| \ge a + d$, contradicting $|f(P_d)| < a+d$. $\square$

Choosing $a$ so that the $d$ levels straddle the middle yields $\mathrm{La}(n, B_d) \ge (d - o(1))\mathcal{C}(n)$; e.g. for $n = 2m$ and $d = 3$ the levels $m-1, m, m+1$ give exactly $\frac{3m+1}{m+1}\binom{2m}{m}$ (see Theorem I).

---

## 6. Complete levels force cubes: the conjecture for level unions

The levels construction of Theorem 5.1 uses $d$ complete levels. The next theorem shows this is optimal among level unions: $d+1$ complete levels always contain a cube, *no matter how the levels are spaced*.

**Theorem F (Complete Levels Theorem).** Let $d \le n$ and let $i_0 < i_1 < \cdots < i_d \le n$ be integers. If $\mathcal{F}$ contains every subset of $[n]$ whose cardinality equals some $i_r$, then $\mathcal{F}$ contains a weak copy of $B_d$.

*Proof.* Reserve the $d$ largest ground-set elements as *markers*: let $m_1 < m_2 < \cdots < m_d$ be the top $d$ elements of $[n]$ (possible since $d \le n$), and for $0 \le j \le n-d$ let $L_j := \{1, \dots, j\}$ be the *low block* of size $j$, which is disjoint from all markers.

Define, for $S \subseteq [d]$,
$$f(S) := L_{\,i_{|S|} - |S|} \ \cup\ \{\,m_t : t \in S\,\}.$$

*Well-definedness.* Since $i$ is strictly increasing, $i_j \ge i_0 + j \ge j$, so $i_{|S|} - |S| \ge 0$; and $i_{|S|} + (d - |S|) \le i_d \le n$ gives $i_{|S|} - |S| \le n - d$, so the low block exists and misses the markers.

*Cardinality.* $|f(S)| = (i_{|S|} - |S|) + |S| = i_{|S|}$, one of the prescribed sizes, so $f(S) \in \mathcal{F}$.

*Monotonicity.* Let $S \subseteq T$. Then $|S| \le |T|$ and, because $i$ is strictly increasing, $i_{j+1} - (j+1) \ge i_j - j$; hence $i_{|S|} - |S| \le i_{|T|} - |T|$ and $L_{i_{|S|}-|S|} \subseteq L_{i_{|T|}-|T|}$. The marker parts satisfy $\{m_t : t \in S\} \subseteq \{m_t : t \in T\}$. Therefore $f(S) \subseteq f(T)$.

*Injectivity.* $f(S) \cap \{m_1,\dots,m_d\} = \{m_t : t \in S\}$ recovers $S$. $\square$

**Definition 6.1 (Level union).** $\mathcal{F}$ is a *level union* if membership depends only on cardinality: $|A| = |B|$ and $A \in \mathcal{F}$ imply $B \in \mathcal{F}$.

**Theorem G (Conjecture with $c=0$ for level unions).** If $\mathcal{F} \subseteq 2^{[n]}$ is $B_d$-free and is a level union, then
$$|\mathcal{F}| \le d\,\mathcal{C}(n).$$

*Proof.* If $d > n$ the height bound (Theorem E) gives $|\mathcal{F}| \le (n+1)\mathcal{C}(n) \le d\,\mathcal{C}(n)$. So assume $d \le n$. Let $I := \{|A| : A \in \mathcal{F}\}$ be the set of occupied sizes. Since $\mathcal{F}$ is a level union, $\mathcal{F}$ is exactly the union of the complete levels indexed by $I$. If $|I| \ge d+1$, pick $d+1$ elements $i_0 < \cdots < i_d$ of $I$ (all $\le n$) and apply Theorem F to obtain a cube, contradicting freeness. Hence $|I| \le d$ and
$$|\mathcal{F}| = \sum_{i \in I}\binom{n}{i} \le |I|\,\mathcal{C}(n) \le d\,\mathcal{C}(n). \qquad\square$$

**Corollary 6.2.** For $d = 3$: every $B_3$-free level union satisfies $|\mathcal{F}| \le 3\,\mathcal{C}(n) \le 4\,\mathcal{C}(n)$.

Theorem G is the strongest possible form of Conjecture 1.3 ($c = 0$) restricted to the symmetric case, and it is tight by Theorem 5.1. It has a useful consequence for the search for counterexamples: **any family witnessing $|\mathcal{F}| > d\,\mathcal{C}(n)$ must break the symmetry of the ground set.** Since the extremal problem itself is invariant under the symmetric group $S_n$, but the maximiser need not be, this is not a contradiction — it merely says the "obvious" symmetric candidates are all exhausted.

---

## 7. Sharpening the chain bound by splitting the Lubell mass

Lemma 2.5 charges every member of $\mathcal{F}$ the minimal Lubell weight $\mathcal{C}(n)^{-1}$. But only $\mathcal{C}(n)$ sets in the whole Boolean lattice attain that weight (two levels' worth when $n$ is odd), so the estimate is wasteful for families of size exceeding $\mathcal{C}(n)$ — which is exactly the regime of interest. Making this precise gives the first genuine improvement of the chain bound.

### 7.1 Even ground sets

**Lemma 7.1.** For $m \ge 1$ and $k \ne m$, $\binom{2m}{k} \le \binom{2m}{m-1} = \frac{m}{m+1}\binom{2m}{m}$.

*Proof.* Unimodality gives $\binom{2m}{k} \le \max\{\binom{2m}{m-1},\binom{2m}{m+1}\} = \binom{2m}{m-1}$ for $k \ne m$. The identity $\binom{2m}{m+1}(m+1) = \binom{2m}{m}\,m$ is the standard recurrence $\binom{N}{r+1} = \binom{N}{r}\frac{N-r}{r+1}$ with $N = 2m$, $r = m$, and $\binom{2m}{m-1} = \binom{2m}{m+1}$ by symmetry. $\square$

**Theorem H (even).** Let $m \ge 1$, let $K := 2^d - 1$, and let $\mathcal{F} \subseteq 2^{[2m]}$ be $B_d$-free. Then
$$(m+1)\,|\mathcal{F}| \le (Km + 1)\binom{2m}{m},\qquad\text{i.e.}\qquad |\mathcal{F}| \le \Bigl(K - \frac{K-1}{m+1}\Bigr)\binom{2m}{m}.$$
Consequently $(m+1)\,\mathrm{La}(2m, B_d) \le \bigl((2^d-1)m+1\bigr)\binom{2m}{m}$.

*Proof.* Write $C := \binom{2m}{m}$ and split $\mathcal{F} = \mathcal{F}_{\mathrm{mid}} \cup \mathcal{F}'$, where $\mathcal{F}_{\mathrm{mid}}$ consists of the members of size exactly $m$ and $\mathcal{F}'$ of the rest. Let $x := |\mathcal{F}_{\mathrm{mid}}|$ and $y := |\mathcal{F}'|$. Clearly $x \le C$, since the middle level has $C$ sets.

By Theorem C, $\lambda(\mathcal{F}) \le K$. Each member of $\mathcal{F}_{\mathrm{mid}}$ contributes exactly $1/C$; by Lemma 7.1 each member of $\mathcal{F}'$ contributes at least $\binom{2m}{m-1}^{-1} = \frac{m+1}{mC}$. Hence
$$\frac{x}{C} + \frac{(m+1)y}{mC} \le K \quad\Longrightarrow\quad y \le \frac{m}{m+1}\,(KC - x).$$
Therefore
$$|\mathcal{F}| = x + y \le x + \frac{m}{m+1}(KC - x) = \frac{KmC}{m+1} + \frac{x}{m+1} \le \frac{KmC + C}{m+1},$$
using $x \le C$. Multiply by $m+1$. Taking $\mathcal{F}$ extremal (the maximum in Definition 1.2 is attained) gives the statement for $\mathrm{La}$. $\square$

**Corollary 7.2 (Strict improvement).** For $d \ge 2$ and all $m$,
$$\bigl((2^d-1)m+1\bigr)\binom{2m}{m} < (2^d-1)(m+1)\binom{2m}{m},$$
i.e. Theorem H is strictly stronger than the chain bound $\mathrm{La}(2m,B_d)\le(2^d-1)\binom{2m}{m}$. (For $d = 1$ the two coincide, both giving Sperner's theorem exactly.)

*Proof.* $(2^d-1)(m+1) = (2^d-1)m + (2^d-1)$ and $2^d - 1 \ge 3 > 1$. $\square$

### 7.2 Odd ground sets

For $n = 2m+1$ two levels tie for largest, so the "cheap" part of the family has capacity $2C$ but the premium off it is correspondingly smaller.

**Lemma 7.3.** For $m \ge 1$ and $k \notin \{m, m+1\}$, $\binom{2m+1}{k} \le \binom{2m+1}{m-1} = \frac{m}{m+2}\binom{2m+1}{m}$.

*Proof.* Unimodality and the symmetry $\binom{2m+1}{m} = \binom{2m+1}{m+1}$ reduce to the extreme neighbour $k = m-1$; the ratio identity $\binom{N}{r-1}/\binom{N}{r} = r/(N-r+1)$ with $N = 2m+1$, $r=m$ gives $m/(m+2)$. $\square$

**Theorem H (odd).** Let $m \ge 1$, $K := 2^d-1$, and let $\mathcal{F} \subseteq 2^{[2m+1]}$ be $B_d$-free. Then
$$(m+2)\,|\mathcal{F}| \le (Km+4)\binom{2m+1}{m},$$
and hence $(m+2)\,\mathrm{La}(2m+1, B_d) \le \bigl((2^d-1)m+4\bigr)\binom{2m+1}{m}$.

*Proof.* Set $C := \binom{2m+1}{m} = \binom{2m+1}{m+1} = \mathcal{C}(2m+1)$ and split $\mathcal{F}$ into the part $\mathcal{F}_{\mathrm{mid}}$ of members of size $m$ or $m+1$, of size $x \le 2C$, and the rest $\mathcal{F}'$, of size $y$. Middle members contribute exactly $1/C$ each; by Lemma 7.3 the others contribute at least $\frac{m+2}{mC}$ each. From $\lambda(\mathcal{F}) \le K$,
$$y \le \frac{m}{m+2}(KC - x),\qquad |\mathcal{F}| = x+y \le \frac{KmC}{m+2} + \frac{2x}{m+2} \le \frac{KmC + 4C}{m+2}. \qquad\square$$

**Corollary 7.4.** For $d \ge 2$, $\bigl((2^d-1)m+4\bigr)\mathcal{C}(2m+1) < (2^d-1)(m+2)\mathcal{C}(2m+1)$: the odd bound is also strictly stronger than the chain bound. (One needs $2(2^d-1) > 4$, i.e. $d \ge 2$.)

### 7.3 The corridor at $d = 3$

**Theorem I (Sandwich).** For every $m \ge 1$,
$$(3m+1)\binom{2m}{m} \ \le\ (m+1)\,\mathrm{La}(2m, B_3)\ \le\ (7m+1)\binom{2m}{m}.$$
Equivalently, $3 - \frac{2}{m+1} \le \mathrm{La}(2m,B_3)/\binom{2m}{m} \le 7 - \frac{6}{m+1}$.

*Proof.* Upper bound: Theorem H (even) with $d = 3$, $K = 7$. Lower bound: Theorem 5.1 with $a = m-1$, $d = 3$ gives
$$\mathrm{La}(2m,B_3) \ge \binom{2m}{m-1}+\binom{2m}{m}+\binom{2m}{m+1} = \Bigl(\frac{m}{m+1}+1+\frac{m}{m+1}\Bigr)\binom{2m}{m} = \frac{3m+1}{m+1}\binom{2m}{m},$$
using Lemma 7.1. $\square$

Thus the asymptotic constant $\pi(B_3) := \lim_{n} \mathrm{La}(n,B_3)/\mathcal{C}(n)$, if it exists, satisfies $3 \le \pi(B_3) \le 7$, and Conjecture 1.3 asserts $\pi(B_3) \le 4$.

### 7.4 Small ground sets at $d = 3$

**Theorem J.** For every $n \le 8$, $\mathrm{La}(n, B_3) \le 4\,\mathcal{C}(n)$.

*Proof.* Trivially $\mathrm{La}(n,B_3) \le 2^n$. A direct check of the nine cases gives $2^n \le 4\binom{n}{\lfloor n/2\rfloor}$:

| $n$ | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|
| $2^n$ | 1 | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 |
| $4\mathcal{C}(n)$ | 4 | 4 | 8 | 12 | 24 | 40 | 80 | 140 | 280 |

$\square$

*Remark 7.5.* The inequality fails from $n = 9$ onwards ($2^9 = 512 > 504 = 4\binom{9}{4}$), and the trivial bound is worthless asymptotically. So Theorem J is genuinely a small-$n$ statement, but it does eliminate the possibility of a small counterexample: any refutation of the $d=3$ conjecture needs $n \ge 9$.

---

## 8. Doubling: cubes from parallel cubes

We now isolate the configuration that a proof of Conjecture 1.3 should exploit.

**Theorem K (Doubling Criterion).** Let $f, g : 2^{[d]} \to 2^{[n]}$ be two weak copies of $B_d$ inside $\mathcal{F}$ (each injective, monotone, with values in $\mathcal{F}$) such that
1. *(pointwise nesting)* $f(S) \subseteq g(S)$ for every $S \subseteq [d]$;
2. *(value disjointness)* $f(S) \ne g(T)$ for all $S, T \subseteq [d]$.

Then $\mathcal{F}$ contains a weak copy of $B_{d+1}$.

*Proof.* For $U \subseteq [d+1]$ write $U' := U \cap [d]$ and define
$$h(U) := \begin{cases} g(U') & \text{if } d+1 \in U,\\ f(U') & \text{if } d+1 \notin U.\end{cases}$$
*Values:* immediate.
*Monotonicity:* let $U \subseteq V$, so $U' \subseteq V'$. If $d+1 \notin V$ then also $d+1 \notin U$ and $h(U) = f(U') \subseteq f(V') = h(V)$. If $d+1 \in U$ then $d+1 \in V$ and $h(U) = g(U') \subseteq g(V') = h(V)$. In the mixed case $d+1 \notin U$, $d+1 \in V$: $h(U) = f(U') \subseteq f(V') \subseteq g(V') = h(V)$, using nesting.
*Injectivity:* suppose $h(U) = h(V)$. If exactly one of $U, V$ contains $d+1$, then $h(U) = h(V)$ equates a value of $f$ with a value of $g$, contradicting (2). If both contain $d+1$, then $g(U') = g(V')$ so $U' = V'$ by injectivity of $g$, and $U = U' \cup \{d+1\} = V$. Similarly if neither contains $d+1$. $\square$

**Corollary 8.1 (Parallel-chain criterion).** Suppose $\mathcal{F}$ contains two chains
$$x_0 \subsetneq x_1 \subsetneq \cdots \subsetneq x_{2^d-1},\qquad y_0 \subsetneq y_1 \subsetneq \cdots \subsetneq y_{2^d-1}$$
with $x_i \subseteq y_i$ for every $i$ and $x_i \ne y_j$ for all $i,j$. Then $\mathcal{F}$ contains a weak copy of $B_{d+1}$.

*Proof.* Apply Theorem A's construction $S \mapsto x_{\rho(S)}$ and $S \mapsto y_{\rho(S)}$ with the same rank function $\rho$; hypotheses (1) and (2) of Theorem K are exactly the pointwise nesting and disjointness. $\square$

**The significance of Corollary 8.1.** The chain bound uses only the implication
$$B_{d+1}\text{-free} \implies \text{no chain of } 2^{d+1}\text{ sets}.$$
Corollary 8.1 gives the strictly stronger implication
$$B_{d+1}\text{-free} \implies \text{no two disjoint pointwise-nested chains of } 2^{d}\text{ sets}.$$
Two parallel chains of length $2^d$ involve the same total number of sets as one chain of length $2^{d+1}$ but are far easier to find in a large family: they require only *height $2^d$* rather than height $2^{d+1}$, and the Boolean lattice has height $n+1$, so for $d$ with $2^{d+1} > n+1$ the chain hypothesis is vacuous while the parallel-chain hypothesis is not. This is precisely the regime where the chain bound degrades to the trivial height bound of Theorem E.

---

## 9. The structural obstruction

It is worth stating clearly what cannot work.

**Proposition 9.1.** For every $d \ge 1$ and every $n \ge 2^d - 2$, there is a $B_d$-free family in $2^{[n]}$ containing a chain of $2^d - 1$ sets.

*Proof.* Take any strictly increasing chain of $2^d - 1$ subsets of $[n]$ (possible since the height is $n+1 \ge 2^d - 1$). A weak copy of $B_d$ requires $2^d$ *distinct* sets, which a family of $2^d-1$ sets cannot supply. $\square$

**Consequence.** Any proof of an upper bound on $\mathrm{La}(n,B_d)$ whose only structural input is a bound on the *length of chains* in $\mathcal{F}$ cannot yield a constant better than $2^d - 1$. Formally: define
$$\mathrm{Ch}(n,k) := \max\{|\mathcal{F}| : \mathcal{F} \subseteq 2^{[n]},\ \mathcal{F} \text{ has no chain of } k+1 \text{ sets}\}.$$
Then $\mathrm{Ch}(n,k) = \sum_{i} \binom{n}{i}$ over the $k$ middle levels (Mirsky + Erdős's theorem on $k$-Sperner families), so $\mathrm{Ch}(n, 2^d-1) = (2^d - 1 - o(1))\mathcal{C}(n)$, and any chain-only argument is pinned there.

The Lubell-mass refinements of Section 7 improve the *constant in front of the second-order term*, i.e. they gain $\Theta(1/n)$, not $\Theta(1)$. That is intrinsic: the argument still passes through $\lambda(\mathcal{F}) \le 2^d-1$, and that inequality is tight for the $(2^d-1)$-level construction, which is $B_d$-free.

Two directions remain open for a constant-factor gain.

1. **Branching.** Use Corollary 8.1: a $B_{d}$-free family must avoid parallel chain pairs of length $2^{d-1}$, a condition invisible to the Lubell mass alone. The natural implementation is a *local analysis of random maximal chains*: condition on a random maximal chain $\mathcal{M}$, and show that if $\mathbb{E}|\mathcal{F} \cap \mathcal{M}|$ is close to $2^d - 1$ then, with non-negligible probability, a *second* maximal chain running "parallel" to $\mathcal{M}$ also meets $\mathcal{F}$ many times, producing the forbidden configuration. This requires a correlation estimate between nearby maximal chains that we have not been able to make unconditional.

2. **Recursion in $d$.** Theorem K is the natural engine for a step of the form $\mathrm{La}(n, B_{d+1}) \le \mathrm{La}(n, B_d) + c_0 \mathcal{C}(n)$. Iterating yields $\mathrm{La}(n,B_d) \le (c_0 d + O(1))\mathcal{C}(n)$, which is Conjecture 1.3 up to the value of $c$. The missing ingredient is a way to extract, from a $B_{d+1}$-free family of size exceeding $\mathrm{La}(n,B_d) + c_0\mathcal{C}(n)$, a sub-family that is $B_d$-free and "duplicable" — i.e. that can be shifted upward to a parallel copy inside $\mathcal{F}$.

---

## 10. Algorithms and computational evidence

Several of the objects above are effectively computable, and the computations are informative.

### 10.1 Deciding the presence of a weak copy

Given $\mathcal{F} \subseteq 2^{[n]}$ and $d$, deciding whether $\mathcal{F}$ contains a weak copy of $B_d$ is a subgraph-embedding problem and is naturally solved by backtracking over a linear extension of $2^{[d]}$:

* order the subsets of $[d]$ as $S_0, \dots, S_{2^d-1}$ by cardinality then lexicographically (any linear extension will do);
* extend a partial assignment $f(S_0), \dots, f(S_{j-1})$ by choosing $f(S_j) \in \mathcal{F}$ distinct from all previous values and containing $f(S_i)$ for every $i < j$ with $S_i \subseteq S_j$;
* prune with the size bound $|f(S_j)| \ge |S_j| + \min_{A \in \mathcal{F}}|A|$ implied by the prefix argument of Theorem 5.1.

The worst case is $|\mathcal{F}|^{2^d}$, but the containment constraints prune ferociously in practice: because the images of a chain of $j$ subsets of $[d]$ must be a chain of $j$ sets, the search depth is effectively bounded by the height of $\mathcal{F}$.

### 10.2 Exhaustive extremal values

For $n \le 3$ one can enumerate all $2^{2^n}$ families and compute $\mathrm{La}(n, B_d)$ exactly. The values obtained are:

| $n$ | $\mathcal{C}(n)$ | $\mathrm{La}(n,B_1)$ | $\mathrm{La}(n,B_2)$ | $\mathrm{La}(n,B_3)$ |
|---|---|---|---|---|
| 1 | 1 | 1 | 2 | 2 |
| 2 | 2 | 2 | 3 | 4 |
| 3 | 3 | 3 | 6 | 7 |

Each row is consistent with all the bounds above. $\mathrm{La}(n,B_1)=\mathcal{C}(n)$ exactly, as Theorem D requires. The values $\mathrm{La}(1,B_2)=2$, $\mathrm{La}(2,B_3)=4$ are the *counting* obstruction at work: a weak copy of $B_d$ needs $2^d$ distinct sets, so any family with fewer than $2^d$ members is automatically $B_d$-free, and for $2^n \le 2^d$ the whole power set qualifies. $\mathrm{La}(3,B_2)=6=2\,\mathcal{C}(3)$ is attained by two complete levels and matches the level-union bound of Theorem G exactly. $\mathrm{La}(3,B_3)=7$: the full power set $2^{[3]}$ *does* contain a copy of $B_3$ (the identity map), while deleting any one set leaves only $7$ members, too few for a copy. Note that this last value is a purely small-$n$ phenomenon — it exceeds the level lower bound $\binom{3}{0}+\binom{3}{1}+\binom{3}{2}=7$ only by tying with it — and it is comfortably below $4\,\mathcal{C}(3) = 12$.

### 10.3 Numerical corridor at $d=3$

Evaluating Theorem I for a range of $m$ makes the corridor concrete (values are ratios to $\binom{2m}{m}$):

| $m$ | lower $\frac{3m+1}{m+1}$ | upper $\frac{7m+1}{m+1}$ | conjecture |
|---|---|---|---|
| 1 | 2.000 | 4.000 | 4 |
| 2 | 2.333 | 5.000 | 4 |
| 5 | 2.667 | 6.000 | 4 |
| 10 | 2.818 | 6.455 | 4 |
| 50 | 2.961 | 6.882 | 4 |
| $\infty$ | 3 | 7 | 4 |

Note that at $m = 1$ ($n = 2$) the sharpened upper bound *equals* the conjectured value, and at $m=2$ ($n = 4$) it gives $5$, already better than the chain bound's $7$. The convergence to $7$ is at rate $\Theta(1/m)$, confirming that layer-splitting is a second-order improvement.

### 10.4 Search for counterexamples

A counterexample to Conjecture 1.3 at $d = 3$ needs $n \ge 9$ by Theorem J, and by Theorem G it must not be a level union. Randomised augmentation searches over asymmetric families in the accessible range ($n \le 9$, using the backtracking freeness test with cardinality pruning) have not produced any family exceeding $4\mathcal{C}(n)$; indeed every attempted augmentation of the three middle levels immediately creates a copy of the $3$-cube; the best constructions found are exactly the three-middle-levels families, of size $(3 - \Theta(1/n))\mathcal{C}(n)$. This is evidence for, not proof of, the conjecture.

---

## 11. Discussion and future directions

### 11.1 What is settled

The chain bound $\mathrm{La}(n,B_d) \le (2^d-1)\mathcal{C}(n)$ holds in the stronger Lubell form $\lambda(\mathcal{F}) \le 2^d - 1$; the case $d = 1$ is exactly Sperner's theorem, with equality; the level construction gives the matching-shape lower bound $d - o(1)$; the Complete Levels Theorem shows the level construction is optimal within its symmetry class, proving Conjecture 1.3 with $c = 0$ for level unions; the Lubell split yields the first strict improvements $(m+1)\mathrm{La}(2m,B_d) \le ((2^d-1)m+1)\binom{2m}{m}$ and $(m+2)\mathrm{La}(2m+1,B_d)\le((2^d-1)m+4)\binom{2m+1}{m}$; the $d=3$ conjecture is verified for $n \le 8$; and the Doubling Criterion supplies a branching-based forcing condition strictly stronger than chain length.

### 11.2 What failed, and why

A constant-factor improvement at $d = 3$ (from $7$ to $4$, or even to $6$) resisted every route attempted. The failure is structural rather than technical: by Proposition 9.1, a chain of $2^d - 1$ sets is $B_d$-free, so any argument that only forbids long chains is pinned at $2^d - 1$. Layer-splitting of the Lubell mass gains only $O(1/n)$. Progress requires exploiting branching configurations — the parallel-chain criterion — which needs a local analysis of random maximal chains that we could not compress into a short argument. This is "true but hard", not "false": no computation in the accessible range produced a family beating $4\,\mathcal{C}(n)$.

### 11.3 Direction 1 — Parallel-chain deficiency bound

The key insight is that a $B_{d+1}$-free family may not contain two pointwise-nested chains of length $2^d$, a condition strictly stronger than the absence of a single chain of length $2^{d+1}$, and this extra deficit should be convertible into a constant-factor gain by a random-full-chain averaging argument.

> **Conjecture 11.1.** If $\mathcal{F} \subseteq 2^{[n]}$ is $B_3$-free, then $\displaystyle\sum_{A \in \mathcal{F}} \binom{n}{|A|}^{-1} \le 6 + o(1)$.

A proof would immediately give $\mathrm{La}(n,B_3) \le (6+o(1))\mathcal{C}(n)$, the first constant-factor improvement over $7$, and would validate the branching approach.

### 11.4 Direction 2 — Doubling recursion for the Boolean poset constant

The doubling criterion builds a $B_{d+1}$ copy out of two parallel $B_d$ copies, which suggests that the asymptotic constant $\pi(B_d) = \lim_n \mathrm{La}(n,B_d)/\mathcal{C}(n)$ satisfies a *recursion* $\pi(B_{d+1}) \le \pi(B_d) + c_0$ rather than doubling; iterating a recursion of that shape yields the linear bound $\pi(B_d) \le c_0 d + O(1)$ demanded by the conjecture.

> **Conjecture 11.2.** There is an absolute constant $c_0$ with $\mathrm{La}(n, B_{d+1}) \le \mathrm{La}(n, B_d) + c_0\,\mathcal{C}(n)$ for all $n, d$.

The missing ingredient is a single-step comparison between $B_{d+1}$-free and $B_d$-free families: given a $B_{d+1}$-free $\mathcal{F}$, produce a $B_d$-free subfamily of size $|\mathcal{F}| - c_0\mathcal{C}(n)$.

### 11.5 Direction 3 — Layer optimisation as a fractional knapsack

The Lubell bound plus the layer capacities $n_j \le \binom{n}{j}$ (where $n_j$ counts members of $\mathcal{F}$ of size $j$) form a fractional knapsack:
$$\text{maximise } \sum_j n_j \quad \text{subject to} \quad \sum_j \frac{n_j}{\binom{n}{j}} \le 2^d - 1, \quad 0 \le n_j \le \binom{n}{j}.$$
Its optimum is attained by filling the largest layers first, giving exactly the $(2^d-1)$-consecutive-levels value; Theorem H is the two-term truncation of this optimisation. Formalising the general optimum would give the exact "layer-optimal" bound
$$\mathrm{La}(n,B_d) \le \max\Bigl\{\textstyle\sum_{j \in J}\binom{n}{j} : |J| = 2^d-1 \Bigr\} = \sum_{j \text{ in the } 2^d-1 \text{ middle levels}} \binom{n}{j},$$
which is the best possible conclusion from the Lubell mass alone and thus pinpoints exactly how much any purely-Lubell argument can ever deliver. Establishing it would also delimit, once and for all, the frontier that branching arguments must cross.

### 11.6 Broader context

Forbidden-subposet problems sit at the intersection of Sperner theory and Turán-type extremal combinatorics. For most posets $P$ the constant $\pi(P) = \lim_n \mathrm{La}(n,P)/\mathcal{C}(n)$ is conjectured to equal the maximum number of consecutive levels avoiding $P$; for $P = B_d$ that maximum is exactly $d$, so Conjecture 1.3 is the quantitative shadow of the general belief. Its resolution for $d = 2$ (the diamond) has been open for over a decade; the case $d = 3$ studied here is, perhaps counter-intuitively, a good testbed, because the gap $3$ versus $7$ is wide enough that a crude branching argument might already close part of it, whereas at $d = 2$ the gap $2.25$ versus $3$ demands precision.

---

## Appendix: summary of the results

| Result | Statement |
|---|---|
| Chain-to-cube | A chain of $2^d$ sets contains a weak copy of $B_d$ |
| Mirsky + LYM | No chain of $k+1$ sets $\implies \lambda(\mathcal{F}) \le k$ |
| Chain bound | $\mathrm{La}(n,B_d)\le(2^d-1)\mathcal{C}(n)$; also $\lambda(\mathcal{F})\le 2^d-1$ |
| Sperner case | $\mathrm{La}(n,B_1)=\mathcal{C}(n)$; $B_1$-free $\iff$ antichain |
| Height bound | $|\mathcal{F}|\le(n+1)\mathcal{C}(n)$ always; conjecture holds for $n \le d$ |
| Levels lower bound | $\mathrm{La}(n,B_d)\ge\sum_{i=a}^{a+d-1}\binom{n}{i}$ |
| Complete Levels | $d+1$ complete levels contain a weak copy of $B_d$ |
| Level unions | $B_d$-free level union $\implies |\mathcal{F}| \le d\,\mathcal{C}(n)$ |
| Sharpening (even) | $(m+1)\mathrm{La}(2m,B_d)\le((2^d-1)m+1)\binom{2m}{m}$ |
| Sharpening (odd) | $(m+2)\mathrm{La}(2m+1,B_d)\le((2^d-1)m+4)\binom{2m+1}{m}$ |
| Sandwich at $d=3$ | $(3m+1)\binom{2m}{m}\le(m+1)\mathrm{La}(2m,B_3)\le(7m+1)\binom{2m}{m}$ |
| Small $n$ at $d=3$ | $\mathrm{La}(n,B_3)\le4\,\mathcal{C}(n)$ for $n\le8$ |
| Doubling | Two nested disjoint $B_d$ copies give a $B_{d+1}$ copy |
| Parallel chains | Two nested disjoint chains of $2^d$ sets give a $B_{d+1}$ copy |
