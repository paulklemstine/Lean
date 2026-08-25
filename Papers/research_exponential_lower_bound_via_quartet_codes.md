# Quartet Codes: An Exponential Lower Bound for the Common-Quartet Threshold

**Author:** Aristotle
**Date:** 2026-08-25

---

## Abstract

A fully resolved (binary) unrooted phylogenetic tree on a finite leaf set $X$ displays, on every four-element subset $Q \subseteq X$, exactly one of three resolutions. Encoding a tree by the vector of these resolutions embeds the set of trees on $n$ leaves into the ternary cube $\{0,1,2\}^{\binom{n}{4}}$, and under this embedding the statement "the trees $T_1,\dots,T_k$ display a common quartet" becomes "the corresponding words carry a common letter in some coordinate". We develop this dictionary and use it to prove an exponential lower bound for the function
$$h(k) := \min\{\, n : \text{any } k \text{ binary trees on } n \text{ leaves display a common quartet} \,\}.$$

Our main results are: (i) an **exact ternary balance** theorem — for four fixed distinct leaves each of the three quartet types is displayed by exactly $n!/3$ of the $n!$ caterpillar trees on $n$ leaves, with no error term; (ii) an **exponential lower bound** $h(k) > 3^{(k-2)/4}$, obtained by a first-moment argument that is exact rather than asymptotic, and realised by explicit families of $4v+2$ trees on $3^v$ leaves with no common quartet; (iii) a **collapse theorem** showing that over a ternary alphabet a family of words at full pairwise Hamming distance has at most three members, so the lower bound cannot be obtained from a minimum-distance formulation and must use the weaker "no constant coordinate" condition; (iv) **local consistency rules** (parity-check analogues) satisfied by tree-realisable words, together with the exact five-leaf code size $15 = 5!/8$ and the packing bound $8 \cdot |\mathcal{C}_n| \leq n!$ for the caterpillar quartet code $\mathcal{C}_n$; and (v) matching upper bounds via Erdős–Szekeres, including the **sharp two-tree threshold** $h_{\mathrm{cat}}(2) = 6$ for caterpillar-shaped trees (with $h(2) \geq 6$ in general) and the bracket $10 \leq h(3)$, $h_{\mathrm{cat}}(3) \leq 6562$. We close by isolating the determination of the exponential rate $c$ with $h(k) = \Theta(c^k)$ as a packing problem in a constrained ternary code, and by presenting numerical evidence for $c \approx 1.7$.

**Keywords:** phylogenetic tree, quartet, agreement subtree, ternary code, first-moment method, Erdős–Szekeres, packing rate.

---

## 1. Introduction

### 1.1 The problem

An unrooted binary phylogenetic tree on a finite set $X$ of leaves is a tree whose leaves are bijectively labelled by $X$ and all of whose internal vertices have degree three. Such a tree is determined by its set of *splits*: for each edge $e$, deleting $e$ partitions $X$ into two nonempty blocks $A_e \mid X \setminus A_e$.

Given $A \subseteq X$, the *restriction* $T|_A$ is the tree on leaf set $A$ obtained by deleting all leaves outside $A$ and suppressing resulting degree-two vertices; concretely, its split system consists of the sets $S \cap A$ for splits $S$ of $T$, retaining only those which are nontrivial partitions of $A$.

For $|A| = 4$, say $A = \{a,b,c,d\}$, a binary tree $T|_A$ has exactly one internal edge, hence exactly one nontrivial split, and there are exactly three possibilities:
$$ab \mid cd, \qquad ac \mid bd, \qquad ad \mid bc.$$
This restriction is called the **quartet displayed by $T$ on $A$**. Two trees are said to *agree* on $A$ if $T_1|_A = T_2|_A$; a family $T_1,\dots,T_k$ displays a **common quartet** on $A$ if all restrictions $T_i|_A$ coincide. Equivalently, $A$ is a *common agreement subtree of size four* for the family.

We call $n$ an **agreement threshold for $k$ trees at size four** if every family of $k$ binary trees on any leaf set of size at least $n$ displays a common quartet on some four-element subset. Write
$$h(k) := \min \{ n : n \text{ is an agreement threshold for } k \text{ trees at size four}\}.$$
The existence of $h(k)$ is not obvious a priori; it follows from a Ramsey-type argument recalled in Section 7. The question addressed here is its growth rate.

We also write $h_{\mathrm{cat}}(k)$ for the same quantity when the trees are restricted to *caterpillars* (trees whose internal vertices lie on a single path; see Section 3). Caterpillars are binary trees, so $h_{\mathrm{cat}}(k) \leq h(k)$: every avoiding family of caterpillars is an avoiding family of trees, and all our lower bounds therefore apply to $h$ itself. Our upper bounds, on the other hand, are proved for caterpillars and so bound $h_{\mathrm{cat}}$; since every binary tree on at most five leaves is a caterpillar, the two functions agree in the range where our exact values live at the lower end.

### 1.2 The coding-theoretic reformulation

Since the quartet displayed on a four-set is one of three possibilities, a tree $T$ on $n$ leaves determines a word
$$\sigma(T) \in \{0,1,2\}^{\binom{X}{4}},$$
its **quartet signature**, whose $Q$-th letter records which of the three resolutions $T$ displays on $Q$. The dictionary is then:

| phylogenetics | coding theory |
|---|---|
| tree $T$ | word $\sigma(T)$ over a ternary alphabet |
| four-leaf subset $Q$ | coordinate of the word |
| quartet displayed on $Q$ | letter in coordinate $Q$ |
| $T_1,\dots,T_k$ agree on $Q$ | coordinate $Q$ is constant across the family |
| no common quartet | **no constant coordinate** |
| realisable signatures | a constrained subcode $\mathcal{C}_n \subseteq \{0,1,2\}^{\binom{n}{4}}$ |

Two features of this dictionary drive the paper. First, the avoidance condition ("no constant coordinate") is a *covering-type* condition on the whole family, not a pairwise distance condition; Theorem 6.1 shows that these are genuinely different and that the distance formulation is useless here. Second, the subcode $\mathcal{C}_n$ of realisable words is severely constrained by local rules on overlapping five-leaf subsets (Section 8) — the exact analogue of local parity checks — so the lower-bound argument must be carried out *inside* $\mathcal{C}_n$, which is what the caterpillar construction achieves.

### 1.3 Summary of results

* **Theorem 4.4 (Exact ternary balance).** For four distinct leaves and $n \geq 4$, each of the three quartet types is displayed by exactly $n!/3$ of the $n!$ caterpillars on $n$ leaves.
* **Theorem 5.3 (First-moment construction).** If $n^4 < 3^m$, there exist $m+1$ trees on $n$ leaves with no common quartet.
* **Corollary 5.4 (Exponential lower bound).** For every $v \geq 0$, some $4v+2$ trees on $3^v$ leaves display no common quartet; hence $h(k) > 3^{(k-2)/4}$.
* **Theorem 6.1 (Distance collapse).** Over a ternary alphabet, a family of words pairwise differing in every coordinate has at most three members.
* **Theorem 8.4 and 8.6 (Code structure).** Exactly $15$ of the $3^5$ ternary words of length five are realisable as five-leaf signatures, and $15 = 5!/8$; in general the caterpillar code satisfies $8\,|\mathcal{C}_n| \leq n!$ for $n \geq 4$.
* **Theorem 7.5 (Sharp two-tree threshold).** $h_{\mathrm{cat}}(2) = 6$, and $h(2) \geq 6$.
* **Theorem 7.3, 7.6.** Any $k$ caterpillars on more than $3^{2^k}$ leaves display a common quartet; in particular $10 \leq h(3)$ and $h_{\mathrm{cat}}(3) \leq 6562$.

---

## 2. Notation and conventions

Throughout, $X$ is a finite leaf set, usually identified with $\{0,1,\dots,n-1\}$. Permutations act on leaves; $S_n$ denotes the symmetric group. For $x \in \{0,1,2\}$ we speak of *types*: type $0$, $1$, $2$ refer to the pairings $ab|cd$, $ac|bd$, $ad|bc$ respectively, once an ordering $(a,b,c,d)$ of the four leaves is fixed. Since all our statements about a four-set are invariant under the relabelling induced by permuting $(a,b,c,d)$ up to a corresponding permutation of the three types, this convention is harmless: agreement of two trees on a four-set is equivalent to equality of the types computed with respect to any single fixed ordering of that four-set.

---

## 3. Caterpillars and the ternary letter

### 3.1 Definition

A **caterpillar** is a binary tree in which all internal vertices lie on a single path. Equivalently, a caterpillar on $n$ leaves is specified by a linear order of the leaves: leaf $x$ is attached at position $\pi(x)$ along the backbone, where $\pi \in S_n$. We denote this tree by $C_\pi$. Caterpillars are honest binary trees; every statement proved for caterpillars is therefore a statement about binary trees, which is why the lower bounds below apply to the general problem.

### 3.2 The letter of a caterpillar

**Definition 3.1.** For four distinct natural numbers $p,q,r,s$ define
$$\mathrm{code}_3(p,q,r,s) := \begin{cases} 0 & \text{if } \max(p,q) < \min(r,s) \text{ or } \max(r,s) < \min(p,q),\\ 1 & \text{else if } \max(p,r) < \min(q,s) \text{ or } \max(q,s) < \min(p,r),\\ 2 & \text{otherwise.}\end{cases}$$
For a leaf order $\pi$ and leaves $a,b,c,d$, set $\mathrm{q}_\pi(a,b,c,d) := \mathrm{code}_3(\pi a, \pi b, \pi c, \pi d)$.

The three clauses are mutually exclusive and exhaustive on distinct arguments; moreover for distinct arguments one has the symmetric characterisation of the last case,
$$\mathrm{code}_3(p,q,r,s) = 2 \iff \max(p,s) < \min(q,r) \text{ or } \max(q,r) < \min(p,s),$$
so all three types are described by the same rule: **the type is determined by which two of the four leaves occupy the two lowest positions**.

**Proposition 3.2 (The letter records the restricted tree).** Let $C_\pi$ be the caterpillar of the leaf order $\pi$ and let $a,b,c,d$ be distinct leaves. Then $C_\pi|_{\{a,b,c,d\}}$ has nontrivial split $ab|cd$ if and only if $\mathrm{q}_\pi(a,b,c,d)=0$, split $ac|bd$ if and only if the letter is $1$, and split $ad|bc$ if and only if the letter is $2$.

*Proof sketch.* The splits of $C_\pi$ are the initial segments of the backbone: $A_j = \{x : \pi x < j\}$ for $1 \leq j \leq n-1$. Restricting to $\{a,b,c,d\}$, the sets $A_j \cap \{a,b,c,d\}$ that are of size two are exactly those with $j$ separating the two lowest positions from the two highest. Hence a two-element subset $\{u,v\}$ of $\{a,b,c,d\}$ is a side of the restricted split system iff $u,v$ occupy the two lowest (equivalently, the two highest) positions among the four. Comparing with Definition 3.1 gives the three equivalences. $\square$

**Corollary 3.3 (Agreement forces letter equality).** If $C_\pi$ and $C_\rho$ agree on the four distinct leaves $a,b,c,d$ — i.e. their restrictions to that set are equal as trees — then $\mathrm{q}_\pi(a,b,c,d) = \mathrm{q}_\rho(a,b,c,d)$.

This corollary is what makes a "no constant letter" statement into a genuine refutation of an agreement threshold: the ternary letter is not a convenient surrogate for the restricted tree, it *is* the restricted tree.

### 3.3 Order-invariance and restriction

**Proposition 3.4 (Order congruence).** $\mathrm{code}_3(p,q,r,s)$ depends only on the relative order of $p,q,r,s$: if $p<q \iff p'<q'$ and similarly for all twelve ordered pairs drawn from the two quadruples, then $\mathrm{code}_3(p,q,r,s) = \mathrm{code}_3(p',q',r',s')$.

**Theorem 3.5 (Restriction principle).** Let $\pi \in S_n$ and let $f : \{0,\dots,m-1\} \to \{0,\dots,n-1\}$ be injective. Then there is a leaf order $\sigma \in S_m$ such that
$$\mathrm{q}_\pi(f a, f b, f c, f d) = \mathrm{q}_\sigma(a,b,c,d) \quad \text{for all } a,b,c,d.$$

*Proof sketch.* Let $g(i) = \pi(f(i))$, an injection $\{0,\dots,m-1\} \to \{0,\dots,n-1\}$, and let $\sigma(i)$ be the *rank* of $g(i)$ among the values $g(0),\dots,g(m-1)$, i.e. $\sigma(i) = |\{j : g(j) < g(i)\}|$. Ranking is a bijection onto $\{0,\dots,m-1\}$ and preserves all order relations, so Proposition 3.4 applies. $\square$

Theorem 3.5 is the technical engine behind the sharp two-tree bound: a finite obstruction on $m$ leaves automatically transports to all $n \geq m$.

---

## 4. Exact ternary balance

Let $Q_t(a,b,c,d) := \{\pi \in S_n : \mathrm{q}_\pi(a,b,c,d) = t\}$ for $t \in \{0,1,2\}$.

**Lemma 4.1 (Transposition swaps two types).** Let $a,b,c,d$ be distinct leaves. Then for every $\pi \in S_n$,
$$\mathrm{q}_{\pi \circ (b\,c)}(a,b,c,d) = \tau_{01}\bigl(\mathrm{q}_\pi(a,b,c,d)\bigr), \qquad \mathrm{q}_{\pi \circ (b\,d)}(a,b,c,d) = \tau_{02}\bigl(\mathrm{q}_\pi(a,b,c,d)\bigr),$$
where $\tau_{01}$ is the transposition $0 \leftrightarrow 1$ of types and $\tau_{02}$ is $0 \leftrightarrow 2$.

*Proof sketch.* Precomposing $\pi$ with the transposition $(b\,c)$ exchanges the positions of $b$ and $c$ and fixes those of $a$ and $d$. Substituting into Definition 3.1 turns the clause characterising type $0$ into the clause characterising type $1$ and vice versa, while the (symmetric) clause characterising type $2$ is invariant. The second identity is identical with the roles of $c$ and $d$ interchanged. $\square$

**Lemma 4.2 (Translation is a bijection of classes).** If $\tau \in S_n$ is an involution and $s$ a transposition of types with $\mathrm{q}_{\pi\tau} = s(\mathrm{q}_\pi)$ for all $\pi$, then $|Q_t| = |Q_{s(t)}|$ for every $t$.

*Proof sketch.* Right translation $\pi \mapsto \pi\tau$ is an involution of $S_n$, hence a bijection, and by hypothesis it maps $Q_t$ into $Q_{s(t)}$ and $Q_{s(t)}$ into $Q_t$. $\square$

**Lemma 4.3.** $|Q_0| = |Q_1| = |Q_2|$.

**Theorem 4.4 (Exact ternary balance).** For distinct leaves $a,b,c,d$ and each type $t$,
$$3 \cdot |Q_t(a,b,c,d)| = n! .$$

*Proof.* The three classes partition $S_n$, and by Lemmas 4.1–4.3 they are equinumerous. $\square$

Two remarks. First, the theorem is exact, not asymptotic: the probability that a uniformly random caterpillar displays a prescribed quartet type on four prescribed leaves is exactly $1/3$. Second, the balance is a statement about the *marginal* distribution at a single coordinate; the coordinates are of course far from independent, which is why the argument below uses only first moments and a union bound.

---

## 5. The first-moment lower bound

Fix $k = m+1$ and consider families $T = (T_0,\dots,T_m) \in S_n^{\,k}$ of leaf orders, viewed as an independent uniform sample.

**Lemma 5.1 (Agreement count).** For distinct leaves $a,b,c,d$, the number of families all of whose members display the same type on $(a,b,c,d)$ is
$$\bigl|\{T : \mathrm{q}_{T_i}(a,b,c,d) \text{ is independent of } i\}\bigr| = 3\,|Q_0|^{\,k}.$$

*Proof sketch.* Partition the agreeing families according to the common type $t$; the fibre over $t$ is the $k$-fold product $Q_t^{\,k}$, of size $|Q_t|^k = |Q_0|^k$ by Theorem 4.4. $\square$

**Lemma 5.2 (Exact first moment).** With $k = m+1$,
$$3^m \cdot 3\,|Q_0|^{\,k} = (n!)^{\,k},$$
i.e. the probability that $k$ independent uniform caterpillars agree on a fixed four-set is exactly $3^{-m} = 3^{-(k-1)}$.

*Proof.* Substitute $|Q_0| = n!/3$ from Theorem 4.4 into Lemma 5.1. $\square$

**Theorem 5.3 (First-moment construction).** If $n^4 < 3^m$, then there exists a family $T_0,\dots,T_m$ of $m+1$ caterpillars on $n$ leaves such that for every quadruple $a,b,c,d$ of pairwise distinct leaves there are indices $i,j$ with $\mathrm{q}_{T_i}(a,b,c,d) \neq \mathrm{q}_{T_j}(a,b,c,d)$.

*Proof.* For each ordered quadruple $Q$ of pairwise distinct leaves let $B_Q \subseteq S_n^{\,k}$ be the set of families agreeing on $Q$; by Lemma 5.2, $3^m |B_Q| = (n!)^k$. The number of such quadruples is at most $n^4$, so
$$3^m \Bigl|\bigcup_Q B_Q\Bigr| \leq \sum_Q 3^m |B_Q| \leq n^4 (n!)^k < 3^m (n!)^k,$$
whence $\bigl|\bigcup_Q B_Q\bigr| < (n!)^k = |S_n^{\,k}|$. Any family outside the union has the stated property. $\square$

**Corollary 5.4 (Exponential lower bound).** For every $v \geq 0$ there exist $4v+2$ binary trees on $3^v$ leaves with no common quartet. Consequently $3^v$ is not an agreement threshold for $4v+2$ trees, and
$$h(k) > 3^{\frac{k-2}{4}} \qquad \text{for all } k \geq 2 .$$

*Proof.* Take $n = 3^v$ and $m = 4v+1$; then $n^4 = 3^{4v} < 3^{4v+1} = 3^m$, so Theorem 5.3 gives $m + 1 = 4v+2$ avoiding caterpillars. By Corollary 3.3 these trees have pairwise unequal restrictions on every four-set, hence no common agreement subtree of size four. Solving $k = 4v+2$ for $v$ gives the stated bound. $\square$

The certified rate is $3^{1/4} \approx 1.3161$ additional leaves per additional tree. Section 9 gives numerical evidence that the truth is nearer $1.7$; by the analysis of the proof, the loss is entirely in the union bound over $n^4$ quadruples, not in the encoding, since Lemma 5.2 is an identity.

---

## 6. Why distance is the wrong invariant

A natural first attempt at the construction is to seek trees whose signatures are pairwise *far apart* in Hamming distance. The following shows that this cannot work, and that the "no constant coordinate" condition is not a weakening of convenience but of necessity.

**Theorem 6.1 (Full-distance collapse).** Let $N \geq 1$ and let $\mathcal{F} \subseteq \{0,1,2\}^N$ be a family of words such that any two distinct members differ in *every* coordinate. Then $|\mathcal{F}| \leq 3$.

*Proof.* The evaluation map $w \mapsto w_1$ (first coordinate) is injective on $\mathcal{F}$ by hypothesis, and its codomain has three elements. $\square$

The bound is attained by the three constant words, and it is independent of $N$: no amount of length helps. Thus a family of trees with pairwise maximum-distance signatures has at most three members, while Corollary 5.4 produces families of size growing linearly in $\log n$. The avoidance condition used there is strictly weaker than full distance — in each coordinate *some* pair disagrees, and the disagreeing pair may vary with the coordinate — and it is precisely this many-body, covering-type condition that the first-moment method handles well.

---

## 7. Upper bounds

### 7.1 Erdős–Szekeres

**Theorem 7.1 (Monotone subsets).** Let $f : \alpha \to \beta$ be an injective map from a finite linearly ordered set $\alpha$ to a linearly ordered set $\beta$. If $|\alpha| > r^2$ then there is a subset $t \subseteq \alpha$ with $|t| > r$ on which $f$ is strictly increasing or strictly decreasing.

*Proof sketch.* For $i \in \alpha$ let $u(i)$ (resp. $d(i)$) be the maximum size of an increasing (resp. decreasing) chain ending at $i$. If $i < j$ then $f(i) < f(j)$ forces $u(i) < u(j)$ and $f(j) < f(i)$ forces $d(i) < d(j)$; by injectivity one of the two holds, so $i \mapsto (u(i), d(i))$ is injective. If all chains had length at most $r$, the image would lie in an $r \times r$ grid, contradicting $|\alpha| > r^2$. $\square$

**Lemma 7.2 (Monotone quadruples carry type $0$).** If $a<b<c<d$ are leaves on which the leaf order $\pi$ is monotone (increasing or decreasing), then $\mathrm{q}_\pi(a,b,c,d) = 0$.

Indeed monotonicity places $a,b$ at the two lowest, or the two highest, of the four positions.

**Theorem 7.3 (Family upper bound).** Any $k$ caterpillars on more than $3^{2^k}$ leaves display a common quartet; more precisely there are four distinct leaves on which all $k$ trees display the *same* type-$0$ resolution.

*Proof sketch.* Iterate Theorem 7.1: choose a subset on which the first leaf order is monotone, then inside it a subset on which the second is monotone, and so on. Each step takes a set of size $N$ to one of size roughly $\sqrt{N}$; after $k$ steps a starting size exceeding $3^{2^k}$ leaves a set of size at least $4$ on which every one of the $k$ orders is monotone. Lemma 7.2 finishes. $\square$

Specialised to $k=2$ with $r=3$ this gives: any two caterpillars on at least $10$ leaves share a quartet. This is not sharp.

### 7.2 The sharp two-tree threshold

**Theorem 7.4 (Five leaves are not enough).** The caterpillars given by the leaf orders $\mathrm{id} = (0,1,2,3,4)$ and $(0,3,2,1,4)$ on five leaves display no common quartet: the first resolves all five of its quartets as type $0$, the second resolves them as $(2,1,1,1,2)$.

Hence $h(2) \geq 6$.

**Theorem 7.5 (Sharp two-tree bound).** Any two caterpillars on at least six leaves display a common quartet. Consequently $h_{\mathrm{cat}}(2) = 6$.

*Proof sketch.* Two ingredients. (a) *Reduction to six leaves*: by the restriction principle (Theorem 3.5), restricting both leaf orders along an injection from a six-element set yields two genuine six-leaf orders with the same letters; a common quartet there lifts to a common quartet upstairs. (b) *The six-leaf statement*: since $\mathrm{q}_{\pi}(\sigma a,\sigma b,\sigma c,\sigma d) = \mathrm{q}_{\pi\sigma}(a,b,c,d)$, comparing an arbitrary pair $(\pi,\rho)$ is equivalent, after right translation by $\pi^{-1}$, to comparing the identity order with $\rho\pi^{-1}$. So it suffices to check that every one of the $720$ leaf orders on six leaves shares a quartet with the identity order, which an exhaustive enumeration confirms (and $720$ cases replace $720^2 = 518400$). $\square$

Because on at most five leaves every binary tree is a caterpillar, Theorem 7.4 also gives the general lower bound $h(2) \geq 6$, while Theorem 7.5 pins the caterpillar threshold at exactly $6$.

### 7.3 Three trees

**Theorem 7.6 (Nine leaves, three trees).** The three leaf orders
$$\mathrm{id}, \quad (7,0,2,5,4,3,1,8,6), \quad (6,5,1,3,4,2,7,8,0)$$
on nine leaves (each written as the list of positions of leaves $0,\dots,8$) display no common quartet: on each of the $126$ four-element subsets at least two of the three trees disagree.

Combining with Theorem 7.3 for $k=3$, which requires more than $3^{8} = 6561$ leaves:
$$10 \leq h(3), \qquad h_{\mathrm{cat}}(3) \leq 6562 .$$

The width of this bracket is a measure of how lossy the iterated Erdős–Szekeres argument is; numerical evidence (Section 9) suggests $h(3) = h_{\mathrm{cat}}(3) = 10$.

---

## 8. Structure of the code

### 8.1 Local consistency: the parity checks

Realisable signatures are far from arbitrary. The following rules involve five leaves at a time and are the analogue of local parity checks.

**Theorem 8.1 (Cherry propagation).** For any leaf order $\pi$ and leaves $a,b,c,d,e$: if $\mathrm{q}_\pi(a,b,c,d) = 0$ and $\mathrm{q}_\pi(a,b,c,e) = 0$ then $\mathrm{q}_\pi(a,b,d,e) = 0$. In words: $ab|cd$ and $ab|ce$ force $ab|de$.

*Proof sketch.* Type $0$ on $(a,b,c,d)$ says the positions of $a,b$ are both below or both above those of $c,d$; the same for $c,e$. Combining the two systems of inequalities places $a,b$ on one side of both $d$ and $e$, which is type $0$ on $(a,b,d,e)$. $\square$

**Theorem 8.2 (Forbidden configuration).** No leaf order displays $ab|cd$, $ab|ce$ and $ac|de$ simultaneously. Hence the corresponding ternary word is not a codeword.

**Theorem 8.3 (Mixed rules).** For distinct leaves: $\mathrm{q}_\pi(a,b,c,d) = 0$ and $\mathrm{q}_\pi(a,b,c,e) = 1$ force $\mathrm{q}_\pi(a,c,d,e) = 2$; and $\mathrm{q}_\pi(a,b,c,d) = 0$ with $\mathrm{q}_\pi(a,b,c,e) = 2$ force $\mathrm{q}_\pi(b,c,d,e) = 2$.

All three rules are proved by translating the type characterisations into linear inequalities among the four or five positions and eliminating. An exhaustive scan over the $120$ five-leaf orders and all premise pairs on overlapping quadruples produces $210$ valid two-premise implications of this kind, of which the above are representatives.

### 8.2 The five-leaf code, counted exactly

**Theorem 8.4.** Exactly $15$ of the $3^5 = 243$ ternary words of length five arise as the quartet signature of a five-leaf tree, and
$$8 \cdot 15 = 120 = 5! .$$

Thus the code rate on five leaves is $\log_3(15)/5 \approx 0.493$: less than half the ambient ternary dimension is used. Any packing bound computed in the *unconstrained* cube is therefore far off, and it matters that the first-moment argument of Section 5 is carried out inside the realisable code (it samples trees, not words).

### 8.3 Symmetries and the packing bound

**Proposition 8.5 (Three symmetries).** The quartet signature of a caterpillar is unchanged by: (i) reversal of the leaf order, $\pi \mapsto \mathrm{rev} \circ \pi$; (ii) exchange of the two lowest positions; (iii) exchange of the two highest positions.

*Proof sketch.* (i) Reversal $v \mapsto (n-1)-v$ flips every comparison simultaneously, so every clause of Definition 3.1 is preserved — and this holds for all quadruples, degenerate ones included. (ii) Exchanging the values $0$ and $1$ preserves the type of every quadruple of distinct leaves, because the two swapped positions are the two global minima and hence remain the "low pair" of any quadruple containing both; a case analysis over the relative positions of the remaining leaves discharges the rest. (iii) is (ii) conjugated by (i). $\square$

**Theorem 8.6 (Packing bound).** For $n \geq 4$, the number of distinct caterpillar quartet signatures on $n$ leaves satisfies
$$8 \cdot |\mathcal{C}_n| \leq n! .$$

*Proof sketch.* Let $r$ be reversal, $a$ the exchange of the two lowest positions, $b = r a r$. The eight products of $\{1,r\}\times\{1,a\}\times\{1,b\}$ are pairwise distinct for $n \geq 4$, as one sees by evaluating each of them at the first and last position; by Proposition 8.5 each fibre of the signature map is a union of left cosets of this group of order eight acting freely on $S_n$, hence has size at least $8$. Summing the fibre sizes gives the bound. $\square$

Exhaustive computation gives $|\mathcal{C}_n| = 3, 15, 90, 630$ for $n = 4,5,6,7$, i.e. exactly $n!/8$ in each case: the signature map is precisely eight-to-one. Equality for all $n$ amounts to the statement that a caterpillar is reconstructible from its quartets up to its own automorphisms — the converse direction, which we do not prove here.

---

## 9. Algorithms and numerical results

### 9.1 Computing a signature

Given a leaf order $\pi$ on $n$ leaves, the signature is computed by iterating over the $\binom{n}{4}$ four-subsets and evaluating $\mathrm{code}_3$, at cost $O(n^4)$ arithmetic comparisons. This is the basic primitive of all computations below.

### 9.2 Verifying avoidance

To certify that a family $T_1,\dots,T_k$ has no common quartet, compute the $k$ signatures and scan for a constant coordinate: $O(k n^4)$ time. Certificates of this kind underlie Theorems 7.4 and 7.6.

### 9.3 Group-reduced exhaustive search

The identity $\mathrm{q}_\pi(\sigma a,\sigma b,\sigma c,\sigma d) = \mathrm{q}_{\pi\sigma}(a,b,c,d)$ reduces the verification of "every pair of $n$-leaf caterpillars shares a quartet" from $(n!)^2$ pairs to $n!$ single orders compared against the identity. For $n=6$ this is $720$ instead of $518400$ and makes the exhaustive proof of Theorem 7.5 feasible.

### 9.4 Local search for avoiding families

To probe the true growth of $h(k)$ we minimise the objective
$$\mathrm{cost}(T_1,\dots,T_k) := \#\{\,Q : \text{all } T_i \text{ agree on } Q \,\},$$
by randomised hill-climbing over transpositions of individual leaf orders, restarting from random families. A family with $\mathrm{cost} = 0$ is an avoidance certificate; repeated failure is evidence (not proof) that none exists.

### 9.5 Numerical summary

All of the following were obtained by direct computation.

| statement | value |
|---|---|
| type counts on a fixed quartet, $n=6$ | $240 : 240 : 240 = 6!/3$ each |
| agreement probability, $k$ caterpillars | exactly $3^{-(k-1)}$ for $k=2,3,4$; $n=4,5,6$ |
| distinct signatures, $n=4,5,6,7$ | $3,\,15,\,90,\,630$ ($=n!/8$) |
| six-leaf orders sharing no quartet with the identity | $0$ (out of $720$) |
| common quartets of the nine-leaf triple | $0$ (out of $126$) |
| largest full-distance ternary family, length $1..4$ | $3,3,3,3$ |
| largest avoiding leaf number found, $k = 2,3,4$ | $5,\ 9,\ 15$–$16$ |

The last row, extended by longer searches to $k=5,6$, gives largest avoiding leaf numbers around $20$ and $30$: the ratio between consecutive entries is close to $1.7$, comfortably above the certified $3^{1/4} \approx 1.32$ and far below the doubly exponential upper bound.

---

## 10. Discussion

### 10.1 What the dictionary buys

The reformulation does three concrete things.

1. **It makes agreement computable.** Agreement of trees on a four-set is equality of a single letter. This turns a statement about restrictions of split systems into a statement about a finite ternary array, which is why exhaustive verification at $n=6$ and $n=9$ is possible at all.

2. **It makes the first moment exact.** Because the three types are *exactly* equinumerous (Theorem 4.4), the probability of $k$-fold agreement is exactly $3^{-(k-1)}$ with no correction term. Every inefficiency in Corollary 5.4 is therefore attributable to the union bound over $n^4$ quadruples.

3. **It identifies the right notion of avoidance.** Theorem 6.1 rules out the distance formulation decisively. The correct object is a family of codewords with no constant coordinate — a *covering code* condition read across the family rather than a packing condition read pairwise.

### 10.2 The rate

Write $h(k) = \Theta(c^k)$ as the conjectural shape of the answer. Corollary 5.4 gives $c \geq 3^{1/4}$; the data of Section 9 suggest $c \approx 1.7$; a trivial counting argument places $c \leq 2$ if the empirical pattern persists, and in any case Theorem 7.3 gives only the doubly exponential $3^{2^k}$. In the coding language, $c$ is a **packing rate in a constrained ternary code**: the supremum of rates at which one can place words of the tree code $\mathcal{C}_n$ so that no coordinate is constant. Both the constrained nature of $\mathcal{C}_n$ (Section 8) and the many-body nature of the condition (Section 6) are essential features of this quantity, and neither is captured by classical rate–distance theory.

### 10.3 Where the upper bound loses

The iterated Erdős–Szekeres argument extracts a *global* monotone pattern once per tree, and each extraction squares the required leaf number. But a common quartet is a local object: it needs four leaves to line up, not a monotone chain through the whole leaf set. The natural replacement is a Ramsey-type theorem for $4$-uniform hypergraphs with three colours, applied directly to the ternary colouring of $\binom{[n]}{4}$ induced by the family. Since agreement is now literally a colour coincidence, such a theorem would be applied to the signature array rather than to the trees, and would plausibly replace $3^{2^k}$ by $c^k$.

---

## 11. Future work

* **Determine the rate.** Prove $h(k) \leq C c^{k}$ for some absolute $c$, closing the gap between $3^{(k-2)/4}$ and $3^{2^k}$. The plausible attack is a Ramsey argument on $4$-uniform three-coloured hypergraphs, exploiting the local consistency rules of Section 8 to restrict the colourings that can occur.
* **Sharpen the lower bound.** The union bound wastes a factor; a Lovász-local-lemma or entropy-compression treatment of the (highly dependent, but locally structured) events $B_Q$ should improve $3^{1/4}$ towards the empirical $1.7$.
* **Complete the index-eight theorem.** Prove that the caterpillar signature map is exactly eight-to-one for all $n$, i.e. $|\mathcal{C}_n| = n!/8$; equivalently, that a caterpillar is reconstructible from its quartet signature up to its automorphism group.
* **Characterise the tree code.** Give a complete list of local rules whose satisfaction characterises realisable ternary words — a "parity check matrix" for phylogenetic trees. On five leaves the rules cut $243$ words down to $15$; the general description is open.
* **Confirm $h(3) = 10$.** The bracket $10 \leq h(3) \leq h_{\mathrm{cat}}(3) \leq 6562$ should collapse; the restriction principle means that a single exhaustive verification at $n = 10$, if it can be organised within reach of computation, would settle it for all larger $n$.
* **Beyond quartets.** Replace "agreement on four leaves" by "agreement on $q$ leaves". The alphabet size becomes the number of binary trees on $q$ leaves, and the analogous balance theorem should follow from the same translation-by-transposition mechanism, giving lower bounds of the shape $h_q(k) > A_q^{\,(k-2)/q}$.

---

## 12. Conclusion

Encoding phylogenetic trees by their quartet resolutions places the common-quartet problem inside coding theory in a way that is faithful (agreement is exactly letter equality), exact (the three types are exactly equinumerous among caterpillars), and productive (a two-line first moment yields an exponential lower bound $h(k) > 3^{(k-2)/4}$). The same dictionary shows why the naive distance reading of the problem fails — over a ternary alphabet, full pairwise distance permits only three codewords — and exposes the local "parity check" structure that makes the realisable code a small, highly constrained subset of the ternary cube: $15$ words out of $243$ on five leaves, and at most $n!/8$ in general. On the upper side, a self-contained Erdős–Szekeres argument gives a doubly exponential bound, sharpened for two trees to the exact value $h_{\mathrm{cat}}(2) = 6$ by a restriction principle and a finite verification. What remains is the constant: the growth rate of $h(k)$ is a packing rate in a constrained ternary code, empirically near $1.7$, and pinning it down is the natural next problem.
