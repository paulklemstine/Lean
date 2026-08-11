# Forbidden Subposets in the Boolean Lattice: Exact Antichain Numbers, a Knapsack Sharpening of the $k$-Sperner Bound, and the Butterfly Obstruction

**Author:** Aristotle
**Date:** 2026-08-11

---

## Abstract

Let $2^{[n]}$ denote the lattice of subsets of $[n]=\{1,\dots,n\}$ ordered by inclusion. For a finite poset $P$, a family $\mathcal F \subseteq 2^{[n]}$ is *weak $P$-free* if it contains no injective order-preserving image of $P$ (containments beyond those of $P$ being permitted), and *strong $P$-free* if it contains no induced such image. The corresponding extremal numbers are $\mathrm{La}(n,P)$ and $\mathrm{La}^*(n,P)$, with $\mathrm{La}(n,P) \le \mathrm{La}^*(n,P)$.

We prove five groups of results.

1. **The weak/strong gap is unbounded.** For the $m$-element antichain $A_m$, weak $A_m$-freeness is the purely numerical condition $|\mathcal F| < m$, so $\mathrm{La}(n,A_{m+1}) = m$; whereas $\mathrm{La}^*(n,A_2) = n+1$. Hence $\mathrm{La}^*(n,A_2) - \mathrm{La}(n,A_2) = n$ and $\mathrm{La}^*(n,A_2) = (n+1)\,\mathrm{La}(n,A_2)$: no inequality $\mathrm{La}^* \le c\cdot \mathrm{La}$ can hold with $c$ independent of $n$.

2. **The three-element antichain.** $\mathrm{La}^*(n,A_3) = 2n$ for all $n \ge 1$: the maximum size of a family of subsets of $[n]$ with no three pairwise incomparable members is exactly $2n$. The upper bound is a layer count; the lower bound is an explicit disjoint union of two chains — the $n+1$ initial segments and the $n-1$ complements of the proper nonempty initial segments. Neither Dilworth's theorem nor Greene–Kleitman theory is used. More generally $\mathrm{La}^*(n,A_m) \le \sum_{i=0}^{n}\min\!\big(m-1,\binom{n}{i}\big)$.

3. **The Lubell function and a knapsack sharpening.** With $\lambda(\mathcal F) = \sum_{A\in\mathcal F}\binom{n}{|A|}^{-1}$, a family with no chain of $k+1$ sets satisfies $\lambda(\mathcal F)\le k$ (Mirsky peeling plus LYM), and any family with $\lambda(\mathcal F)\le k$ has at most $\Sigma(n,k)$ members, where $\Sigma(n,k)$ is the sum of the $k$ largest binomial coefficients (a fractional-knapsack inequality). This yields Erdős' $k$-Sperner theorem and the exact value $\mathrm{La}(n,C_{k+1}) = \mathrm{La}^*(n,C_{k+1}) = \Sigma(n,k)$ for every chain $C_{k+1}$.

4. **A bracket for arbitrary posets.** For every finite poset $P$ of height $h(P)$,
$$\Sigma\big(n,\,h(P)-1\big) \;\le\; \mathrm{La}(n,P) \;\le\; \Sigma\big(n,\,|P|-1\big),$$
with the upper bound obtained from Szpilrajn's linear-extension theorem. Both ends are exact chain-poset values, and the bracket collapses exactly for chains. Since $\Sigma(n,k) < k\binom{n}{\lfloor n/2\rfloor}$ for $3\le k\le n+1$, this strictly improves the classical Mirsky/Sperner bound; e.g. $\mathrm{La}(10,B_3)\le 1002$ instead of $7\binom{10}{5}=1764$.

5. **The butterfly obstruction and rank rigidity.** If $P$ contains a *butterfly* (two distinct elements each strictly below two distinct elements), then any two consecutive layers of $2^{[n]}$ are weak $P$-free, regardless of $h(P)$; hence the height lower bound in the bracket is not tight. The general form: if $P$ has a *tall butterfly of height $m$* then $m+2$ consecutive layers are weak $P$-free. Its engine is a rank-rigidity lemma: a chain of $L$ sets inside $L$ consecutive layers meets each layer exactly once. The diamond $B_2$ contains no butterfly, isolating precisely why the diamond problem resists this method.

**Keywords:** extremal set theory, forbidden subposet, Lubell function, LYM inequality, $k$-Sperner theorem, Dilworth width, butterfly poset, Boolean lattice.

---

## 1. Introduction

### 1.1 The forbidden-subposet problem

Sperner's theorem (1928) states that a family of subsets of $[n]$ in which no member contains another has at most $\binom{n}{\lfloor n/2\rfloor}$ members, with equality for a middle layer. Erdős (1945) extended this to families with no chain of $k+1$ members, showing that the maximum is the total size of the $k$ largest layers.

Both are instances of the general **forbidden-subposet problem**: given a finite poset $P$, determine the largest family $\mathcal F \subseteq 2^{[n]}$ containing no copy of $P$. The problem is solved for chains, for a handful of small posets, and for various asymptotic regimes; even the four-element diamond is open. This paper contributes exact values, a systematic sharpening of the standard upper bound, a general two-sided bracket, and a structural obstruction that explains the lossiness of the standard lower bound.

### 1.2 Two notions of containment

The literature contains two inequivalent notions of "copy", and much of the subtlety of the subject lies in the distinction.

**Definition 1.1 (weak and strong copies).** Let $P$ be a finite poset and $\mathcal F \subseteq 2^{[n]}$. A map $\iota : P \to 2^{[n]}$ is a

* **weak copy** of $P$ if $\iota$ is injective and $p < q \implies \iota(p) \subsetneq \iota(q)$;
* **strong copy** (or *induced copy*) of $P$ if $\iota$ is injective and $\iota(p) \subsetneq \iota(q) \iff p < q$.

The copy *lies in* $\mathcal F$ if $\iota(p) \in \mathcal F$ for all $p$. The family $\mathcal F$ is **weak $P$-free** (resp. **strong $P$-free**) if no weak (resp. strong) copy of $P$ lies in $\mathcal F$.

**Definition 1.2 (extremal numbers).**
$$\mathrm{La}(n,P) = \max\{|\mathcal F| : \mathcal F \subseteq 2^{[n]} \text{ weak } P\text{-free}\},\qquad
\mathrm{La}^*(n,P) = \max\{|\mathcal F| : \mathcal F \subseteq 2^{[n]} \text{ strong } P\text{-free}\}.$$

Every strong copy is a weak copy; therefore weak $P$-freeness implies strong $P$-freeness and
$$\mathrm{La}(n,P) \;\le\; \mathrm{La}^*(n,P). \tag{1.1}$$

### 1.3 Notation

Layer $i$ of the cube is $\Lambda_i = \{A \subseteq [n] : |A| = i\}$, of size $\binom{n}{i}$. For $a,k \ge 0$ the **window family** is
$$\mathcal L(a,k) = \{A \subseteq [n] : a \le |A| < a+k\},$$
the union of $k$ consecutive layers, with $|\mathcal L(a,k)| = \sum_{i=a}^{a+k-1}\binom{n}{i}$.

The **central start** is
$$c(n,k) = \left\lceil \tfrac{n-k}{2} \right\rceil, \qquad\text{so that}\qquad n \;\le\; 2c(n,k)+k \;\le\; n+1 ,$$
and we write
$$\Sigma(n,k) \;=\; \sum_{i=c(n,k)}^{c(n,k)+k-1} \binom{n}{i}$$
for the total size of the $k$ **central layers**. The defining inequality on $c(n,k)$ makes the window symmetric about $n/2$ up to one step, and this is exactly what is needed for the following elementary but essential fact.

**Lemma 1.3 (the central window is optimal).** Let $k \le n+1$. Then $\binom{n}{i} \le \binom{n}{w}$ for every $i$ outside the window $[c(n,k),\,c(n,k)+k)$ and every $w$ inside it. Consequently $\Sigma(n,k)$ is the sum of the $k$ largest binomial coefficients in row $n$.

*Proof sketch.* The binomial row is unimodal and symmetric: $\binom{n}{i}\le\binom{n}{j}$ whenever $i<j$ and $i+j \le n$, and whenever $i>j$ and $i+j\ge n$. If $i$ lies below the window and $w$ inside it, then $i < w$ and $i + w \le 2c+k-1 \le n$, so $\binom{n}{i}\le\binom{n}{w}$; if $i$ lies above the window then $i > w$ and $i+w \ge 2c+k \ge n$, and symmetry gives the same conclusion. $\square$

Two posets recur below: $A_m$, the $m$-element antichain, and $B_d$, the Boolean lattice of all $2^d$ subsets of a $d$-set. $C_k$ denotes the chain with $k$ elements, and $h(P)$ the height of $P$ — the maximum number of elements of a chain in $P$.

---

## 2. The weak/strong gap

Inequality (1.1) invites the question whether the two extremal functions ever differ substantially. They do, already for the smallest nontrivial poset.

**Theorem 2.1 (weak antichain-freeness is a cardinality condition).** For every $m$ and every family $\mathcal F$,
$$\mathcal F \text{ is weak } A_m\text{-free} \iff |\mathcal F| < m .$$

*Proof sketch.* A weak copy of $A_m$ imposes no containment requirement whatsoever (the antichain has no strict relations), so it is precisely an injection $A_m \hookrightarrow \mathcal F$. Such an injection exists if and only if $|\mathcal F| \ge m$. $\square$

**Corollary 2.2.** If $m \le 2^n$ then $\mathrm{La}(n, A_{m+1}) = m$. In particular $\mathrm{La}(n,A_2)=1$.

*Proof sketch.* Upper bound from Theorem 2.1; for the lower bound take any $m$ distinct subsets, which is possible since $m \le 2^n$. $\square$

Strong freeness behaves completely differently.

**Theorem 2.3 (strong $A_2$-freeness is chain-ness).** $\mathcal F$ is strong $A_2$-free if and only if $\mathcal F$ is a chain: $A \subseteq B$ or $B \subseteq A$ for all $A, B \in \mathcal F$.

*Proof sketch.* A strong copy of $A_2$ is an injective map of the two-element antichain that reflects strict containment, i.e. an ordered pair of distinct sets that are *incomparable*. Absence of such a pair is exactly the chain condition. $\square$

**Theorem 2.4.** $\mathrm{La}^*(n,A_2) = n+1$.

*Proof sketch.* *Upper bound.* Distinct members of a chain have distinct cardinalities, so the map $A \mapsto |A|$ is injective on a chain and lands in $\{0,\dots,n\}$. *Lower bound.* The initial segments $S_i = \{1,\dots,i\}$, $0\le i\le n$, form a chain of $n+1$ sets. $\square$

**Corollary 2.5 (unbounded gap).** For every $n \ge 1$,
$$\mathrm{La}(n,A_2) = 1 < n+1 = \mathrm{La}^*(n,A_2), \qquad \mathrm{La}^*(n,A_2) - \mathrm{La}(n,A_2) = n,\qquad \mathrm{La}^*(n,A_2) = (n+1)\,\mathrm{La}(n,A_2).$$
Hence (1.1) is never an equality for $A_2$, and no bound of the form $\mathrm{La}^*(n,P) \le c\cdot\mathrm{La}(n,P)$ can hold with $c$ independent of $n$.

---

## 3. The three-element antichain: $\mathrm{La}^*(n,A_3) = 2n$

Theorem 2.4 is one-dimensional: a strong $A_2$-free family is a single chain. Strong $A_3$-freeness — *no three pairwise incomparable sets* — is the first genuinely two-dimensional case. By Dilworth's theorem such a family is a union of two chains, and the Greene–Kleitman philosophy predicts the answer to be the total length of the two longest chains of a symmetric chain decomposition of $2^{[n]}$, namely $(n+1)+(n-1) = 2n$. We prove this directly, using neither theorem.

### 3.1 The layer bound

**Lemma 3.1 (layer bound).** If $\mathcal F$ is strong $A_m$-free then, for every $i$,
$$\big|\{A \in \mathcal F : |A| = i\}\big| \;<\; m .$$

*Proof sketch.* Distinct sets of the same cardinality are incomparable (neither can be a strict subset of the other, as strict inclusion strictly increases cardinality). So if $m$ members of $\mathcal F$ had a common size $i$, any injection from $A_m$ onto them would reflect strict containment vacuously — both sides of the equivalence being false — hence would be a strong copy of $A_m$ inside $\mathcal F$. $\square$

**Lemma 3.2 (extreme layers).** For every family $\mathcal F$, $|\{A\in\mathcal F : |A|=0\}| \le 1$ and $|\{A\in\mathcal F : |A|=n\}| \le 1$, since $\emptyset$ and $[n]$ are the unique sets of those sizes.

**Lemma 3.3 (general antichain bound).** For every $m$,
$$\mathrm{La}^*(n,A_m) \;\le\; \sum_{i=0}^{n} \min\!\left(m-1,\ \binom{n}{i}\right).$$

*Proof sketch.* Partition a strong $A_m$-free family by cardinality; each fibre has at most $m-1$ members by Lemma 3.1 and at most $\binom{n}{i}$ members trivially. $\square$

For $m=2$ this evaluates to $n+1$ and for $m=3$ to $1 + 2(n-1) + 1 = 2n$ (all interior binomials being at least $2$ for $n\ge 2$); both are attained. The $m=3$ case is worth stating separately with a self-contained proof.

**Proposition 3.4 (upper bound).** For $n \ge 1$, every strong $A_3$-free family $\mathcal F \subseteq 2^{[n]}$ satisfies $|\mathcal F| \le 2n$.

*Proof sketch.* Write $f(i) = |\{A\in\mathcal F : |A| = i\}|$, so $|\mathcal F| = \sum_{i=0}^{n} f(i)$. Lemma 3.1 gives $f(i)\le 2$ for all $i$, and Lemma 3.2 gives $f(0)\le 1$, $f(n)\le 1$. Hence $|\mathcal F| \le 1 + 2(n-1) + 1 = 2n$. $\square$

### 3.2 The extremal construction

Fix the natural ordering of $[n]$ and set $S_i = \{1,2,\dots,i\}$ for $0 \le i \le n$ (so $S_0=\emptyset$, $S_n = [n]$).

**Definition 3.5.** The **initial-segment family** is $\mathcal I = \{S_0, S_1, \dots, S_n\}$ and the **complemented family** is $\mathcal I^{\,\mathrm c} = \{\,\overline{S_i} : 1 \le i \le n-1\,\}$, the complements of the *proper nonempty* initial segments.

**Lemma 3.6.** $\mathcal I$ is a chain with $|\mathcal I| = n+1$, and $\mathcal I^{\,\mathrm c}$ is a chain with $|\mathcal I^{\,\mathrm c}| = n-1$.

*Proof sketch.* $S_i \subseteq S_j$ for $i \le j$, and $S_i \subsetneq S_j$ for $i<j\le n$ because $i+1 \in S_j \setminus S_i$; complementation reverses inclusion and preserves distinctness, and $\overline{S_i} \ne \overline{S_j}$ for $1\le i<j\le n-1$ since $i+1$ belongs to $\overline{S_i}$ but not $\overline{S_j}$. $\square$

**Lemma 3.7 (disjointness).** $\mathcal I \cap \mathcal I^{\,\mathrm c} = \emptyset$.

*Proof sketch.* Suppose $S_j = \overline{S_i}$ with $1\le i\le n-1$. The element $n$ lies in $\overline{S_i}$ (as $i<n$), hence $n\in S_j$, forcing $j = n$, i.e. $S_j = [n]$; but $\overline{S_i} \ne [n]$ because $1 \in S_i$. Equivalently: every nonempty initial segment contains $1$, while no $\overline{S_i}$ with $i \ge 1$ does, and $\emptyset \ne \overline{S_i}$ since $i \le n-1$. $\square$

**Lemma 3.8 (a union of two chains is strong $A_3$-free).** If $\mathcal C_1$ and $\mathcal C_2$ are chains, then $\mathcal C_1 \cup \mathcal C_2$ contains no three pairwise incomparable sets.

*Proof sketch.* Three distinct sets distributed among two chains must, by pigeonhole, contain two lying in the same chain; those two are comparable, and being distinct they are strictly comparable, contradicting the requirement that a strong copy of $A_3$ reflects strict containment (no relation may hold). $\square$

**Theorem 3.9 (main result).** For every $n \ge 1$,
$$\mathrm{La}^*(n, A_3) = 2n .$$

*Proof sketch.* The upper bound is Proposition 3.4. For the lower bound, $\mathcal I \cup \mathcal I^{\,\mathrm c}$ is strong $A_3$-free by Lemmas 3.6 and 3.8, and by Lemma 3.7 its size is $(n+1)+(n-1) = 2n$. $\square$

**Corollary 3.10 (Greene–Kleitman prediction, first two cases).** $\mathrm{La}^*(n,A_3) = \mathrm{La}^*(n,A_2) + (n-1)$. Both values agree with the prediction
$$\mathrm{La}^*(n,A_m) \;\stackrel{?}{=}\; \sum_{i=0}^{m-2}\,(n+1-2i)$$
obtained by taking the $m-1$ longest chains of a symmetric chain decomposition: $n+1$ for $m=2$, and $2n$ for $m=3$.

**Remark 3.11.** The prediction for general $m$ remains open in this framework. Lemma 3.3 gives an upper bound of $\sum_i \min(m-1, \binom{n}{i})$, which for fixed $m$ and large $n$ equals $(m-1)(n+1) - O_m(1)$, whereas the conjectured value is $(m-1)(n+1) - (m-1)(m-2)$; the two agree for $m\le 3$ and diverge afterwards, since the layer bound cannot see that the extreme layers *near* the boundary are also thin.

---

## 4. The Lubell function and Erdős' $k$-Sperner theorem

We now return to weak freeness, where the essential tool is a weighting.

**Definition 4.1 (Lubell function).** For $\mathcal F \subseteq 2^{[n]}$,
$$\lambda(\mathcal F) \;=\; \sum_{A \in \mathcal F} \binom{n}{|A|}^{-1}.$$

A *maximal chain* is a sequence $\emptyset = X_0 \subsetneq X_1 \subsetneq \cdots \subsetneq X_n = [n]$; there are $n!$ of them, and exactly $|A|!\,(n-|A|)!$ pass through a given $A$. Hence a uniformly random maximal chain passes through $A$ with probability $\binom{n}{|A|}^{-1}$, and

$$\lambda(\mathcal F) = \mathbb{E}\big[\,\#\{\text{members of } \mathcal F \text{ on a random maximal chain}\}\,\big]. \tag{4.1}$$

**Theorem 4.2 (LYM inequality).** If $\mathcal F$ is an antichain then $\lambda(\mathcal F) \le 1$.

*Proof sketch.* Immediate from (4.1): a chain meets an antichain at most once, so the expectation is at most $1$. $\square$

**Theorem 4.3 (Mirsky peeling).** If $\mathcal F$ contains no chain of $k+1$ members, then $\lambda(\mathcal F) \le k$.

*Proof sketch.* Induction on $k$. For $k=0$ the family is empty. For the step, let $M$ be the set of $\subseteq$-maximal members of $\mathcal F$; $M$ is an antichain, so $\lambda(M)\le 1$ by Theorem 4.2. Moreover $\mathcal F \setminus M$ contains no chain of $k$ members: a chain of $k$ sets in $\mathcal F\setminus M$ can be extended upward by a maximal element of $\mathcal F$ above its top, producing a chain of $k+1$ sets in $\mathcal F$. By induction $\lambda(\mathcal F\setminus M)\le k-1$, and $\lambda(\mathcal F) = \lambda(\mathcal F\setminus M) + \lambda(M) \le k$. $\square$

The next step is the heart of the sharpening: it converts a *weight* bound into a *cardinality* bound with no loss.

**Theorem 4.4 (fractional knapsack inequality).** Let $N, k \ge 0$, let $C_0,\dots,C_{N-1} > 0$ be capacities and $0 \le m_i \le C_i$ occupancies. Let $W \subseteq \{0,\dots,N-1\}$ with $|W| = k$, and suppose there is $c > 0$ with $C_i \ge c$ for all $i \in W$ and $C_i \le c$ for all $i \notin W$. If
$$\sum_{i<N} \frac{m_i}{C_i} \;\le\; k,\qquad\text{then}\qquad \sum_{i<N} m_i \;\le\; \sum_{i \in W} C_i .$$

*Proof sketch.* For each $i$,
$$m_i - c\,\frac{m_i}{C_i} \;=\; m_i\left(1 - \frac{c}{C_i}\right) \;\le\; \begin{cases} C_i - c, & i \in W \quad (\text{factor} \ge 0,\ m_i \le C_i),\\[2pt] 0, & i \notin W \quad (\text{factor} \le 0,\ m_i \ge 0). \end{cases}$$
Summing over $i$ gives $\sum_i m_i - c\sum_i m_i/C_i \le \sum_{i\in W} C_i - ck$, and adding $c\big(\sum_i m_i/C_i\big) \le ck$ yields the claim. $\square$

**Theorem 4.5 (knapsack step).** Let $k \le n+1$ and $\lambda(\mathcal F) \le k$. Then $|\mathcal F| \le \Sigma(n,k)$.

*Proof sketch.* The case $k=0$ forces $\mathcal F=\emptyset$ because every member contributes positive weight. Otherwise, apply Theorem 4.4 with $N=n+1$, $C_i = \binom{n}{i}$, $m_i = |\{A\in\mathcal F : |A|=i\}| \le C_i$, window $W = [c(n,k), c(n,k)+k)$, and $c = \min_{w\in W}\binom{n}{w}$. Lemma 1.3 supplies the hypothesis $C_i \le c$ for $i \notin W$, while $C_i \ge c$ for $i \in W$ holds by choice of $c$. Fibrewise decomposition gives $|\mathcal F| = \sum_i m_i$ and $\lambda(\mathcal F) = \sum_i m_i/C_i$, so the conclusion reads $|\mathcal F| \le \sum_{i\in W}\binom{n}{i} = \Sigma(n,k)$. $\square$

**Theorem 4.6 (Erdős' $k$-Sperner theorem).** For $k \le n+1$, a family $\mathcal F \subseteq 2^{[n]}$ with no chain of $k+1$ members satisfies $|\mathcal F| \le \Sigma(n,k)$, the sum of the $k$ largest binomial coefficients.

*Proof sketch.* Theorem 4.3 followed by Theorem 4.5. $\square$

For $k=1$ this is Sperner's theorem, since $\Sigma(n,1) = \binom{n}{\lfloor n/2\rfloor}$.

### 4.1 Chains are completely solved

**Lemma 4.7.** For every $k$ and every family $\mathcal F$, the following are equivalent: (i) $\mathcal F$ is weak $C_k$-free; (ii) $\mathcal F$ is strong $C_k$-free; (iii) $\mathcal F$ contains no chain of $k$ sets.

*Proof sketch.* (i)$\iff$(iii): a weak copy of the chain $C_k$ is exactly a strictly increasing sequence of $k$ sets. (ii)$\iff$(iii): a chain of $k$ sets is automatically an *induced* copy of $C_k$, because in a chain the relation $\iota(p) \subsetneq \iota(q)$ holds precisely when $p < q$ (by trichotomy in a linear order and antisymmetry of $\subseteq$). $\square$

**Theorem 4.8 (exact chain values).** For $k \le n+1$,
$$\mathrm{La}(n, C_{k+1}) \;=\; \mathrm{La}^*(n, C_{k+1}) \;=\; \Sigma(n,k) .$$

*Proof sketch.* Upper bounds: Lemma 4.7 with Theorem 4.6. Lower bound: the window family $\mathcal L(c(n,k),k)$, being contained in $k$ layers, has no chain of $k+1$ sets (a chain has strictly increasing cardinalities, hence meets each layer at most once), so it is both weak and strong $C_{k+1}$-free, and it has $\Sigma(n,k)$ members. $\square$

Theorem 4.8 also holds for an arbitrary finite chain $P$ in place of $C_{k+1}$, with $k = |P|-1$: any finite linear order is order-isomorphic to $C_{|P|}$.

---

## 5. A two-sided bracket for an arbitrary finite poset

Only two order-theoretic facts are needed to bracket $\mathrm{La}(n,P)$ for arbitrary $P$.

**Lemma 5.1 (weak copies preserve chains).** If $\iota$ is a weak copy of $P$ in $\mathcal F$ and $c_1 < c_2 < \cdots < c_k$ is a chain in $P$, then $\iota(c_1) \subsetneq \cdots \subsetneq \iota(c_k)$ is a chain of $k$ sets in $\mathcal F$.

**Corollary 5.2 (height lower bound).** If $P$ has a chain of $k+1$ elements and $\mathcal F$ has no chain of $k+1$ sets, then $\mathcal F$ is weak $P$-free. Hence
$$\Sigma\big(n, h(P)-1\big) \;\le\; \mathrm{La}(n,P),$$
witnessed by the family of the $h(P)-1$ central layers.

**Theorem 5.3 (Szpilrajn, quantitative form).** Every finite poset $P$ admits an injective, strictly monotone map $P \to C_{|P|}$.

*Proof sketch.* Extend the partial order of $P$ to a linear order (Szpilrajn's extension theorem; for finite $P$, repeatedly compare an incomparable pair and take the transitive closure). Sorting the resulting linear order identifies it with $C_{|P|}$, and the identity map $P \to (P,\le_{\mathrm{lin}})$ is injective and strictly monotone since $p<q$ implies $p <_{\mathrm{lin}} q$. $\square$

**Corollary 5.4 (size upper bound).** If $\mathcal F$ is weak $P$-free then $\mathcal F$ has no chain of $|P|$ sets. Consequently, if $|P|-1 \le n+1$ then
$$\mathrm{La}(n,P) \;\le\; \Sigma\big(n, |P|-1\big).$$

*Proof sketch.* Given a chain $X_1\subsetneq\cdots\subsetneq X_{|P|}$ in $\mathcal F$ and the embedding $e : P \to C_{|P|}$ of Theorem 5.3, the composite $p \mapsto X_{e(p)}$ is a weak copy of $P$ in $\mathcal F$. Then apply Theorem 4.6 with $k = |P|-1$. $\square$

**Theorem 5.5 (the poset bracket).** For every finite nonempty poset $P$ with $|P| - 1 \le n+1$,
$$\Sigma\big(n, h(P)-1\big) \;\le\; \mathrm{La}(n,P) \;\le\; \Sigma\big(n, |P|-1\big).$$
Both bounds are exact extremal numbers of chain posets; they coincide if and only if $h(P) = |P|$, i.e. exactly when $P$ is a chain, in which case Theorem 4.8 determines $\mathrm{La}(n,P)$ and $\mathrm{La}^*(n,P)$.

### 5.1 The sharpening is strict

The traditional bound derived from Mirsky's theorem and Sperner's theorem reads $\mathrm{La}(n,P) \le (|P|-1)\binom{n}{\lfloor n/2\rfloor}$: each of the $|P|-1$ "levels" of a Mirsky decomposition is an antichain of size at most $\binom{n}{\lfloor n/2\rfloor}$. The bracket replaces this by $\Sigma(n,|P|-1)$, which is never larger and usually strictly smaller.

**Lemma 5.6 (strict unimodality).** If $2k+1 < n$ then $\binom{n}{k} < \binom{n}{k+1}$.

*Proof sketch.* From the identity $\binom{n}{k+1}(k+1) = \binom{n}{k}(n-k)$ and $n - k \ge k+2 > k+1$. $\square$

**Theorem 5.7 (strict improvement).** For $3 \le k \le n+1$,
$$\Sigma(n,k) \;<\; k \binom{n}{\lfloor n/2\rfloor}.$$

*Proof sketch.* Let $a = c(n,k)$. Since $k \ge 3$ and $2a + k \le n+1$, we have $2a+1 < n$, so Lemma 5.6 and unimodality give $\binom{n}{a} < \binom{n}{\lfloor n/2\rfloor}$. Bounding the remaining $k-1$ terms of $\Sigma(n,k)$ by $\binom{n}{\lfloor n/2\rfloor}$ each yields the strict inequality. $\square$

**Corollary 5.8 (Boolean patterns).** For $d \ge 2$ with $2^d - 1 \le n+1$,
$$\mathrm{La}(n, B_d) \;\le\; \Sigma(n, 2^d-1) \;<\; (2^d-1)\binom{n}{\lfloor n/2\rfloor},$$
and $\Sigma(n,d) \le \mathrm{La}(n,B_d)$ from the height side (the Boolean lattice $B_d$ has height $d+1$).

**Example 5.9.** For $d = 3$ and $n = 10$: $c(10,7) = 2$, so
$$\mathrm{La}(10,B_3) \;\le\; \binom{10}{2}+\binom{10}{3}+\cdots+\binom{10}{8} \;=\; 45+120+210+252+210+120+45 \;=\; 1002,$$
whereas the classical bound gives $7\binom{10}{5} = 1764$ — an improvement of $43\%$. From below, $\Sigma(10,3) = \binom{10}{4}+\binom{10}{5}+\binom{10}{6} = 210+252+210 = 672$.

---

## 6. The butterfly obstruction

The lower end of the bracket in Theorem 5.5 uses only $h(P)$. We now show it is genuinely lossy, by exhibiting a purely local configuration that forces layer-freeness independently of height.

**Definition 6.1 (butterfly).** A poset $P$ **contains a butterfly** if there exist $p_1 \ne p_2$ and $q_1 \ne q_2$ in $P$ with $p_i < q_j$ for all $i,j \in \{1,2\}$. Equivalently: some two distinct elements of $P$ have two distinct common strict upper bounds. Note that the two lower elements need not be incomparable to each other, nor the two upper ones.

The **butterfly poset** $\mathrm{Bf}$ has exactly four elements $a_1, a_2, b_1, b_2$ with $a_i < b_j$ for all $i,j$ and no other relations. It has $|\mathrm{Bf}| = 4$ and $h(\mathrm{Bf}) = 2$.

**Lemma 6.2.** If $X \ne Y$ are finite sets with $|X| = |Y|$, then $|X| < |X\cup Y|$.

*Proof sketch.* If $|X\cup Y| \le |X|$ then $X = X\cup Y \supseteq Y$, and $|Y|=|X|$ forces $Y = X$. $\square$

**Theorem 6.3 (two-layer rigidity).** If $P$ contains a butterfly, then for every $a$ the two-layer family $\mathcal L(a,2)$ is weak $P$-free.

*Proof sketch.* Suppose $\iota$ were a weak copy of $P$ inside $\mathcal L(a,2)$, and let $p_1,p_2,q_1,q_2$ witness the butterfly. Every member of $\mathcal L(a,2)$ has size $a$ or $a+1$, and $p_i < q_j$ forces $|\iota(p_i)| < |\iota(q_j)|$; with only two sizes available this pins $|\iota(p_1)| = |\iota(p_2)| = a$ and $|\iota(q_1)| = |\iota(q_2)| = a+1$. Since $\iota$ is injective, $\iota(p_1) \ne \iota(p_2)$, so by Lemma 6.2 $|\iota(p_1)\cup\iota(p_2)| \ge a+1$. Each $\iota(q_j)$ contains both $\iota(p_1)$ and $\iota(p_2)$, hence contains their union, and has size exactly $a+1$; therefore $\iota(q_j) = \iota(p_1)\cup\iota(p_2)$ for $j = 1,2$. Thus $\iota(q_1) = \iota(q_2)$, contradicting injectivity. $\square$

**Corollary 6.4 (butterfly lower bound).** If $P$ contains a butterfly, then $\Sigma(n,2) \le \mathrm{La}(n,P)$, regardless of $h(P)$.

**Theorem 6.5 (the height bound is not tight).** For the butterfly poset $\mathrm{Bf}$ and every $n\ge 1$,
$$\Sigma(n,1) \;<\; \Sigma(n,2) \;\le\; \mathrm{La}(n,\mathrm{Bf}) \;\le\; \Sigma(n,3),$$
while Corollary 5.2 only supplies the lower bound $\Sigma\big(n, h(\mathrm{Bf})-1\big) = \Sigma(n,1)$.

*Proof sketch.* $\Sigma(n,1) = \binom{n}{\lfloor n/2\rfloor}$ is one of the two summands of $\Sigma(n,2)$, and the other is a positive binomial coefficient; the upper bound is Corollary 5.4 with $|\mathrm{Bf}| = 4$. $\square$

**Proposition 6.6 (the diamond escapes).** The diamond $B_2$ (elements $\emptyset, \{1\}, \{2\}, \{1,2\}$) does **not** contain a butterfly: any two distinct elements of $B_2$ have at most one common strict upper bound. Consequently, two-layer freeness for $B_2$ — which does hold — cannot be derived from Theorem 6.3, and the diamond problem requires a different mechanism. By contrast $B_3$ does contain a butterfly, e.g. $p_1 = \emptyset$, $p_2 = \{1\}$, $q_1 = \{1,2\}$, $q_2 = \{1,2,3\}$.

### 6.1 Rank rigidity and tall butterflies

Theorem 6.3 and the classical statement "$d$ consecutive layers are weak $B_d$-free" turn out to be instances of one principle. Its engine is the following.

**Theorem 6.7 (rank rigidity).** Let $X_0 \subsetneq X_1 \subsetneq \cdots \subsetneq X_{L-1}$ be a chain of $L$ sets, all lying in $\mathcal L(a,L)$ (i.e. $a \le |X_i| < a+L$). Then $|X_i| = a+i$ for every $i$.

*Proof sketch.* Strict inclusion strictly increases cardinality, so $|X_i| \ge |X_0| + i \ge a+i$. Applying the same estimate to the reversed chain, measured downward from the top of the window, gives $|X_i| \le (a + L - 1) - (L-1-i) = a+i$. The two bounds agree. $\square$

**Definition 6.8 (tall butterfly).** $P$ has a **tall butterfly of height $m$** if there are $p_1 \ne p_2$, $q_1 \ne q_2$ in $P$ with $p_i < q_j$ for all $i,j$, and chains $c^{(1)}, c^{(2)}$ of $m+1$ elements of $P$ whose top elements are $p_1$ and $p_2$ respectively.

A tall butterfly of height $0$ is exactly a butterfly.

**Theorem 6.9 (tall butterfly obstruction).** If $P$ has a tall butterfly of height $m$, then $\mathcal L(a, m+2)$ is weak $P$-free for every $a$. Consequently
$$\Sigma(n, m+2) \;\le\; \mathrm{La}(n,P).$$

*Proof sketch.* Let $\iota$ be a hypothetical weak copy of $P$ inside $\mathcal L(a,m+2)$. Appending $q_j$ on top of the chain $c^{(i)}$ produces a chain of $m+2$ elements of $P$, whose image under $\iota$ is a chain of $m+2$ sets inside $m+2$ consecutive layers. Theorem 6.7 pins its cardinalities: $|\iota(p_i)| = a+m$ and $|\iota(q_j)| = a+m+1$ for all $i,j$. From here the butterfly argument of Theorem 6.3 applies verbatim: $\iota(p_1) \ne \iota(p_2)$ have equal size, so their union has size $\ge a+m+1$; each $\iota(q_j)$ contains the union and has size $a+m+1$, hence equals it; so $\iota(q_1) = \iota(q_2)$, contradicting injectivity. $\square$

**Corollary 6.10 (unification).** Taking $m=0$ recovers Theorem 6.3. Taking $m=1$ and $P = B_3$ — witnessed by the chains $\emptyset \subset \{1\}$ and $\emptyset \subset \{2\}$ below the distinct elements $\{1,2\}$ and $\{1,2,3\}$ — recovers the statement that three consecutive layers of $2^{[n]}$ are weak $B_3$-free, previously proved by a $B_d$-specific argument.

---

## 7. Algorithms

The results above are effective; the following procedures make them computable.

**Algorithm 7.1 (central window and $\Sigma(n,k)$).** Given $n$ and $k \le n+1$, return $a = \lceil (n-k)/2 \rceil$ and $\Sigma(n,k) = \sum_{i=a}^{a+k-1}\binom{n}{i}$. Cost: $O(k)$ arithmetic operations after computing one binomial coefficient, using the recurrence $\binom{n}{i+1} = \binom{n}{i}(n-i)/(i+1)$.

**Algorithm 7.2 (poset bracket).** Given the comparability relation of a finite poset $P$ on $|P| = N$ elements: compute the height $h(P)$ by longest-path dynamic programming on the strict-order DAG in $O(N^2)$ time; detect a butterfly by scanning all pairs $(p_1,p_2)$ and testing whether their common strict upper set has at least two elements, in $O(N^3)$ time; compute the largest $m$ admitting a tall butterfly by combining the butterfly scan with the longest downward chain terminating at each element (also $O(N^3)$). Output the interval
$$\Big[\ \Sigma\big(n, \max\{h(P)-1,\ m+2 \text{ over tall butterflies}\}\big),\ \ \Sigma\big(n, N-1\big)\ \Big].$$

**Algorithm 7.3 (Lubell certificate).** Given a family $\mathcal F$, compute $\lambda(\mathcal F) = \sum_{A\in\mathcal F}\binom{n}{|A|}^{-1}$ in $O(|\mathcal F|)$ time. If $\lambda(\mathcal F) \le k$ then $|\mathcal F| \le \Sigma(n,k)$ (Theorem 4.5); the converse fails, so $\lambda$ is a *certificate*, not a characterization. Peeling maximal elements iteratively computes the height of $\mathcal F$ and certifies $\lambda(\mathcal F) \le \mathrm{height}(\mathcal F)$.

**Algorithm 7.4 (exhaustive verification of $\mathrm{La}^*(n,A_3)$).** Enumerate maximal strong $A_3$-free families by depth-first search over $2^{[n]}$ in a fixed order, maintaining the set of *incomparable pairs* already chosen; a candidate $A$ may be added unless it is incomparable to both members of some already-chosen incomparable pair. Branch-and-bound with the bound "current size $+$ remaining candidates $\le$ best known" prunes the search drastically, and the optimum $2n$ is confirmed for $n \le 5$ in well under a second.

---

## 8. Discussion

### 8.1 What makes weight work, and where it stops

The Lubell function converts a counting problem into a probability computation (4.1), and this is what makes the chain problem trivially soluble: every antichain contributes at most $1$ to the expectation, so the height of a family controls its weight, and the knapsack inequality (Theorem 4.4) converts weight to cardinality without loss. The conversion is *tight*, in the sense that the central window achieves both the weight $k$ and the cardinality $\Sigma(n,k)$.

The method's limitation is equally sharp. The family
$$\mathcal G = \{\emptyset\} \cup \Lambda_1 \cup \{[n]\}$$
is butterfly-free for $n \ge 3$: any two distinct members of $\mathcal G$ have $[n]$ as their unique common strict upper bound inside $\mathcal G$, since no singleton strictly contains another member. Yet its Lubell value is exactly $1 + n\cdot\frac{1}{n} + 1 = 3$. So no bound of the form "butterfly-free $\Rightarrow \lambda \le 2$" is available, and the conjecture $\mathrm{La}(n,\mathrm{Bf}) = \Sigma(n,2)$ must be a cardinality statement, not a weight statement. In this precise sense, the butterfly marks the boundary of the Lubell method.

### 8.2 Weak versus strong

The results of Sections 2 and 3 quantify the difference between the two notions of containment. For patterns with rich order structure — chains, Boolean lattices — the weak and strong extremal numbers can coincide (Theorem 4.8). For antichains, they diverge maximally: the weak invariant degenerates to a cardinality condition, while the strong invariant becomes the Dilworth-type question "how large can a family of width $< m$ be?" The exact answers $n+1$ and $2n$ for widths $1$ and $2$ are the first two terms of the Greene–Kleitman prediction, and the constructions realizing them — one chain, then two disjoint chains — are the first two steps of a symmetric chain decomposition.

### 8.3 One local obstruction, many layer theorems

The tall butterfly is a single four-element-plus-chains configuration that implies all known "consecutive layers are $P$-free" statements considered here. Its proof is the rank rigidity lemma: within a window of $L$ layers, a chain of $L$ sets has no freedom at all, and the resulting cardinality constraints force distinct elements to map to the same union. That the diamond $B_2$ evades this obstruction is not an accident of the proof: in $B_2$, two elements never have two distinct common strict upper bounds, so any argument that exploits "two upper wings collapse to one union" is unavailable. Any resolution of the diamond problem must therefore use the branching structure of $B_2$ in a different way — for instance by charging the branching against Lubell weight, as suggested below.

---

## 9. Future directions

**Conjecture 9.1 (diamond).** $\mathrm{La}(n, B_2) = \binom{n}{\lfloor n/2\rfloor} + \binom{n}{\lfloor n/2\rfloor+1}$ for all $n \ge 1$.

The bracket of Theorem 5.5 gives $\Sigma(n,2)\le \mathrm{La}(n,B_2)\le\Sigma(n,3)$, and exhaustive search confirms the lower end for $n = 3, 4$. The upper bound loses a whole layer because it uses only the height of a weak copy (a $4$-chain) and never the *branching* of the diamond; a Lubell-function argument that charges the branching should remove the third layer. Because the knapsack step converts any improved weight bound $\lambda(\mathcal F) \le 2 + o(1)$ for diamond-free $\mathcal F$ immediately into the cardinality statement, only the local analysis remains to be done.

**Conjecture 9.2 (butterfly).** $\mathrm{La}(n, \mathrm{Bf}) = \Sigma(n,2)$, the sum of the two largest binomial coefficients, for $n \ge 3$.

We have $\Sigma(n,2)\le \mathrm{La}(n,\mathrm{Bf})\le\Sigma(n,3)$. The key insight is the rigidity behind Theorem 6.3: in a butterfly-free family, any two sets have at most one common strict upper bound in the family, so the "upper shadow" map from pairs of sets to their common upper set is injective — a counting statement that should close the remaining layer. The Lubell route alone cannot work, since $\{\emptyset\}\cup\Lambda_1\cup\{[n]\}$ is butterfly-free with Lubell value $3$; the conjecture is genuinely a cardinality, not a weight, statement.

**Conjecture 9.3 (the layer number is the tall-butterfly invariant).** For a finite poset $P$ define $e(P)$ as the largest $k$ such that $k$ consecutive layers of $2^{[n]}$ are weak $P$-free for all $n$ and all starting levels. We proved $e(P) \ge m+2$ whenever $P$ has a tall butterfly of height $m$ (Theorem 6.9), and $e(P) \ge h(P)-1$ always. **Conjecture:** $e(P)$ equals $1$ plus the largest $m+1$ over all tall butterflies of height $m$ in $P$; that is, the tall-butterfly obstruction is the *only* obstruction, and this purely local invariant determines the layer number exactly.

**Further problems.**

* *General antichains.* Determine $\mathrm{La}^*(n,A_m)$ for $m \ge 4$. The layer bound $\sum_i \min(m-1,\binom{n}{i})$ of Lemma 3.3 is not tight for $m \ge 4$; the conjectured value is $\sum_{i<m-1}(n+1-2i)$, attained by the $m-1$ longest chains of a symmetric chain decomposition. A proof would need a bound that recognizes the thinness of near-extreme layers, not merely of the two extreme ones.
* *Strong extremal numbers of Boolean patterns.* Is $\mathrm{La}^*(n,B_d)$ ever strictly larger than $\mathrm{La}(n,B_d)$ for $d \ge 2$ when $n$ is large?
* *Effective bracket width.* For which posets is the ratio $\Sigma(n,|P|-1) / \Sigma(n,h(P)-1)$ bounded as $n\to\infty$? Since $\Sigma(n,k) \sim k\binom{n}{\lfloor n/2\rfloor}$ for fixed $k$, the ratio tends to $(|P|-1)/(h(P)-1)$; closing the bracket therefore amounts to determining the "Lagrangian-like" constant $\lim_n \mathrm{La}(n,P)/\binom{n}{\lfloor n/2\rfloor}$, which is conjectured to be an integer for all $P$ and is not even known to exist in general.

---

## 10. Summary of results

| Statement | Result |
|---|---|
| Weak antichain freeness | $\mathcal F$ weak $A_m$-free $\iff |\mathcal F| < m$; $\mathrm{La}(n,A_{m+1}) = m$ |
| Strong $A_2$ | $\mathrm{La}^*(n,A_2) = n+1$; gap $\mathrm{La}^*-\mathrm{La} = n$ |
| Strong $A_3$ | $\mathrm{La}^*(n,A_3) = 2n$, attained by two disjoint chains |
| General antichains | $\mathrm{La}^*(n,A_m) \le \sum_i \min(m-1,\binom{n}{i})$ |
| Weight bound | no chain of $k+1$ $\Rightarrow \lambda(\mathcal F)\le k$ |
| Knapsack | $\lambda(\mathcal F)\le k \Rightarrow |\mathcal F| \le \Sigma(n,k)$ |
| Chains | $\mathrm{La}(n,C_{k+1}) = \mathrm{La}^*(n,C_{k+1}) = \Sigma(n,k)$ |
| Bracket | $\Sigma(n,h(P)-1)\le \mathrm{La}(n,P)\le \Sigma(n,|P|-1)$ |
| Strictness | $\Sigma(n,k) < k\binom{n}{\lfloor n/2\rfloor}$ for $3\le k\le n+1$; $\mathrm{La}(10,B_3)\le 1002 < 1764$ |
| Butterfly | butterfly in $P$ $\Rightarrow$ two consecutive layers weak $P$-free |
| Tall butterfly | tall butterfly of height $m$ $\Rightarrow$ $m+2$ consecutive layers weak $P$-free |
| Rigidity | chain of $L$ sets in $L$ consecutive layers has $|X_i| = a+i$ |
