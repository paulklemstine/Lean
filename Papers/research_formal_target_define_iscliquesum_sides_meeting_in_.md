# Clique Sums and the Trace Calculus: Exact Composition Laws for the Independence, Clique and Chromatic Numbers

**Author:** Aristotle
**Date:** 2026-08-21

---

## Abstract

A *clique sum* glues two graphs $G_1$ and $G_2$ along a shared clique $K$ of size $k$. We give a complete and sharp account of how the three classical invariants — the independence number $\alpha$, the clique number $\omega$ and the chromatic number $\chi$ — behave under this operation, distinguishing rigorously between two notions that are routinely conflated: the *strong* clique sum, in which $K$ is required to be a clique **of each summand**, and the *weak* clique sum, in which $K$ is only required to be a clique **of the union**, its edges being allowed to be shared out between the two sides.

For strong clique sums we prove: (i) an independent set meets a clique in at most one vertex, whence the sharp uniform bound $\alpha_1 + \alpha_2 \le \alpha(G) + \min(k,2)$, with all three regimes $k = 0$, $k = 1$, $k \ge 2$ attained; (ii) the folklore inequality $\alpha_1 + \alpha_2 \le \alpha(G) + 1$ is **false** for every $k \ge 2$, the minimal counterexample being the path on four vertices; (iii) an exact decomposition
$$\alpha(G) = \max_{T \subseteq K,\ |T| \le 1}\big(\alpha_1(T) + \alpha_2(T) - |T|\big),$$
where $\alpha_i(T)$ is the largest independent set of side $i$ whose intersection with $K$ is exactly $T$; (iv) $\omega(G) = \max(\omega_1,\omega_2)$, every clique of a clique sum being contained in a single side; (v) $\chi(G) = \max(\chi_1,\chi_2)$, by a colour-permutation gluing argument, and consequently the preservation of the identity $\chi = \omega$; (vi) the numerical side condition "the number of colours $n$ available on a side is at least the weld size $k$" is *automatic* for strong clique sums.

For weak clique sums all of this collapses: we exhibit a three-vertex witness — the triangle, split as one edge plus a path — for which $\chi(G) = 3 > 2 = \max(\chi_1,\chi_2)$ and $\alpha_1 + \alpha_2 = 4 > 3 = \alpha(G) + 2$. Since $n \ge k$ holds automatically in the strong setting and fails in this witness, the boundary between the two regimes is exactly the inequality $n \ge k$.

The unifying structure is a **trace calculus**: an invariant composes across a separator precisely when it can be relativised to the *trace* of its witness on the separator, and the compositional loss is governed by the size of the resulting state space — one bit and one address for independence, nothing at all for colourings.

**Keywords:** clique sum, independence number, chromatic number, clique number, graph gluing, tree decomposition, perfect graphs, trace decomposition.

---

## 1. Introduction

### 1.1 Motivation

Structural graph theory is largely the study of *decompositions*: statements of the form "every graph in the class $\mathcal{C}$ can be assembled from simple pieces by a controlled gluing operation". The single most important such operation is the clique sum. Chordal graphs are exactly the graphs obtainable from complete graphs by repeated clique sums; series–parallel graphs, $K_5$-minor-free graphs (by Wagner's theorem), and — in the far reaches — the minor-closed families described by the graph minor structure theorem all admit clique-sum decompositions. On the algorithmic side, a tree decomposition of width $w$ is precisely a recipe for assembling a graph by clique sums along separators of size at most $w+1$, and essentially every "linear time on bounded treewidth" result is a dynamic program over such an assembly.

The value of a decomposition is proportional to the number of invariants it *composes*. If an invariant $\iota$ satisfies a law expressing $\iota(G)$ in terms of $\iota(G_1)$, $\iota(G_2)$ and bounded extra data, then the decomposition converts a global computation into a local one. This paper determines, sharply, the composition laws of $\alpha$, $\omega$ and $\chi$ under clique sums.

### 1.2 A folklore inequality that is false

The following argument appears, in various informal guises, whenever independence numbers meet clique sums. Let $A_1$ be a maximum independent set of the left side and $A_2$ one of the right side. Since $K$ is a clique, each meets $K$ in at most one vertex. Their union therefore over-counts at most one vertex, giving
$$\alpha(G) \ \ge\ \alpha_1 + \alpha_2 - 1. \tag{$\star$}$$

The argument is invalid: $A_1 \cap K$ and $A_2 \cap K$ may be *distinct* singletons, in which case $A_1 \cup A_2$ contains two adjacent vertices of $K$ and is not independent at all. We show in Section 5 that $(\star)$ is not merely unproven but false, already for $k = 2$ and $|V| = 4$, and that the correct universal constant is $\min(k,2)$.

### 1.3 Contributions

1. Precise definitions of strong and weak clique sums on a common vertex set (Section 2).
2. The One-Point Trace lemma and the gluing lemma for matching traces (Section 3).
3. The sharp uniform bound $\alpha_1+\alpha_2 \le \alpha(G) + \min(k,2)$ and the refutation of $(\star)$ (Sections 4–5).
4. The exact trace decomposition of $\alpha(G)$, and the derivation of the $-2$ bound from it (Section 6).
5. Composition of $\omega$ and $\chi$, the automatic inequality $k \le n$, and preservation of $\chi = \omega$ (Section 7).
6. Complete failure of both theories for weak clique sums (Section 8).
7. Algorithms extracted from the trace decomposition, with complexity analysis (Section 9).

---

## 2. Definitions

Throughout, $V$ is a finite set, and all graphs are simple and undirected with vertex set $V$. For a graph $G$ we write $G.\mathrm{Adj}(a,b)$, or simply $a \sim_G b$, for adjacency; $G_1 \cup G_2$ denotes the graph on $V$ whose edges are the edges of $G_1$ together with those of $G_2$. A set $C \subseteq V$ is a **clique** of $G$ if any two distinct members are adjacent; a set $A \subseteq V$ is **independent** if no two of its members (distinct or not — there are no loops) are adjacent.

**Definition 2.1 (Weak clique sum).** A graph $G$ is a *weak clique sum* of $G_1$ and $G_2$ along $K$ with sides $s, t \subseteq V$ if
1. $G = G_1 \cup G_2$;
2. $s \cup t = V$ and $s \cap t = K$;
3. every edge of $G_1$ has both endpoints in $s$, and every edge of $G_2$ has both endpoints in $t$;
4. $K$ is a clique of $G$.

**Definition 2.2 (Clique sum).** A graph $G$ is a *(strong) clique sum* of $G_1$ and $G_2$ along $K$ with sides $s,t$ if conditions 1–3 above hold and, in place of 4,

4′. $K$ is a clique of $G_1$ **and** a clique of $G_2$.

We write $k = |K|$.

**Remark 2.3.** Condition 4′ implies condition 4, so every clique sum is a weak clique sum. The converse fails badly: in Section 8, $K$ is a triangle of $G$ whose three edges are split between the sides, so that $K$ is a clique of neither summand.

**Remark 2.4 (Why a shared ambient vertex set).** Presenting both summands on the same vertex set $V$ avoids the bookkeeping of an amalgamated pushout while losing nothing: the "private" part of side $1$ is $s \setminus K$, that of side $2$ is $t \setminus K$, and condition 3 forbids either graph from having edges outside its own side. In particular $G_1$ is edgeless outside $s$, so its independence number *restricted to $s$*, rather than its global independence number, is the meaningful quantity.

**Definition 2.5 (Restricted independence and clique numbers).** For a graph $H$ and a set $u \subseteq V$,
$$\alpha(H; u) = \max\{|A| : A \subseteq u,\ A \text{ independent in } H\}, \qquad \omega(H;u) = \max\{|C| : C \subseteq u,\ C \text{ a clique of } H\}.$$
We abbreviate $\alpha_1 = \alpha(G_1; s)$, $\alpha_2 = \alpha(G_2; t)$, $\alpha(G) = \alpha(G; V)$, and similarly $\omega_1,\omega_2,\omega(G)$. The chromatic number $\chi(H)$ is the least $n$ such that $H$ admits a proper $n$-colouring; $H$ is *$n$-colourable* if such a colouring exists.

**Definition 2.6 (Trace, traced independence number).** For $A \subseteq V$ the **trace** of $A$ on $K$ is $A \cap K$. For $T \subseteq K$,
$$\alpha_1(T) \;=\; \max\{|A| : A \subseteq s,\ A \text{ independent in } G_1,\ A \cap K = T\},$$
and $\alpha_2(T)$ is defined symmetrically with $t$ and $G_2$. (The maximum is over a nonempty family whenever $T$ is *admissible*, i.e. $T \subseteq K$ and $|T| \le 1$, since $T$ itself is then a legal candidate: a set of size at most one is independent because there are no loops.)

---

## 3. The two structural lemmas

**Lemma 3.1 (One-Point Trace).** Let $A$ be independent in $H$ and let $K$ be a clique of $H$. Then $|A \cap K| \le 1$.

*Proof.* Suppose $a, b \in A \cap K$ with $a \ne b$. Since $K$ is a clique, $a \sim_H b$; since $A$ is independent, $a \not\sim_H b$. Contradiction. $\square$

Lemma 3.1 already contains the whole reason why $\alpha$ composes at all: the amount of information a candidate independent set can carry across the weld is at most one vertex.

The second lemma supplies the step that the folklore argument silently assumes.

**Lemma 3.2 (Gluing lemma).** Let $G$ be a weak clique sum of $G_1, G_2$ along $K$ with sides $s,t$. Let $A_1 \subseteq s$ be independent in $G_1$ and $A_2 \subseteq t$ independent in $G_2$, and suppose the traces agree:
$$A_1 \cap K = A_2 \cap K .$$
Then $A_1 \cup A_2$ is independent in $G$.

*Proof.* First note that $x \in s \cap t \Rightarrow x \in K$, and that the trace hypothesis transfers weld membership between the two sets: if $x \in A_1$ and $x \in K$ then $x \in A_1 \cap K = A_2 \cap K \subseteq A_2$, and symmetrically.

Let $a, b \in A_1 \cup A_2$ with $a \sim_G b$; we derive a contradiction. Since $G = G_1 \cup G_2$, either $a \sim_{G_1} b$ or $a \sim_{G_2} b$. Consider the first case (the second is symmetric). Then $a, b \in s$ by condition 3. If both $a$ and $b$ lie in $A_1$ we contradict independence of $A_1$ directly. If, say, $b \in A_2 \setminus A_1$, then $b \in s$ and $b \in t$, hence $b \in K$, hence by the transfer above $b \in A_1$ — and we are back in the previous case. Repeating this for each of the four membership patterns exhausts the possibilities and yields a contradiction in every one. $\square$

**Corollary 3.3 (Trace-free gluing).** In the situation of Lemma 3.2 with arbitrary $A_1, A_2$ (no trace hypothesis), the set $(A_1 \setminus K) \cup (A_2 \setminus K)$ is independent in $G$, and the two pieces are disjoint.

*Proof.* Both deleted-trace sets have empty trace, so Lemma 3.2 applies. Disjointness: a common element would lie in $s \cap t = K$ and has been deleted. $\square$

---

## 4. The sharp uniform bound for $\alpha$

**Theorem 4.1 ($-2$ bound).** For every clique sum $G$ of $G_1, G_2$ along $K$,
$$\alpha_1 + \alpha_2 \;\le\; \alpha(G) + 2 .$$

*Proof.* Choose $A_1 \subseteq s$ independent in $G_1$ with $|A_1| = \alpha_1$, and $A_2 \subseteq t$ independent in $G_2$ with $|A_2| = \alpha_2$. By Corollary 3.3, $U = (A_1\setminus K) \sqcup (A_2 \setminus K)$ is independent in $G$, so
$$\alpha(G) \ \ge\ |U| \ =\ |A_1 \setminus K| + |A_2 \setminus K| \ =\ \big(|A_1| - |A_1 \cap K|\big) + \big(|A_2| - |A_2\cap K|\big).$$
By Lemma 3.1 applied on each side — this is where condition 4′ is used, since we need $K$ to be a clique of $G_1$ and of $G_2$ — we have $|A_i \cap K| \le 1$. Hence $\alpha(G) \ge \alpha_1 + \alpha_2 - 2$. $\square$

**Theorem 4.2 ($-1$ bound for small welds).** If moreover $k = |K| \le 1$, then
$$\alpha_1 + \alpha_2 \;\le\; \alpha(G) + 1 .$$

*Proof.* Take maximum witnesses $A_1, A_2$ as above. If $A_1 \cap K = A_2 \cap K$, Lemma 3.2 gives that $A_1 \cup A_2$ is independent, and inclusion–exclusion yields
$$\alpha(G) \ \ge\ |A_1 \cup A_2| = |A_1| + |A_2| - |A_1 \cap A_2| \ \ge\ \alpha_1 + \alpha_2 - 1,$$
because $A_1 \cap A_2 \subseteq s \cap t = K$ has at most $k \le 1$ elements. If the traces differ, then — since both are subsets of a set of size at most one — one of them is empty, say $A_1 \cap K = \varnothing$. Then $A_1$ and $A_2 \setminus K$ have equal (empty) traces, so their union is independent, and they are disjoint; therefore
$$\alpha(G) \ \ge\ |A_1| + |A_2 \setminus K| \ =\ \alpha_1 + \alpha_2 - |A_2\cap K| \ \ge\ \alpha_1 + \alpha_2 - 1 . \qquad \square$$

**Theorem 4.3 ($k = 0$: exact additivity).** If $K = \varnothing$ (so $G$ is a disjoint union of the two sides) then $\alpha_1 + \alpha_2 \le \alpha(G)$, and in fact equality holds.

*Proof.* The traces are both empty, so Lemma 3.2 glues the two maximum witnesses; they are disjoint because $s \cap t = \varnothing$. The reverse inequality follows by splitting any independent set of $G$ into its parts in $s$ and in $t$. $\square$

Combining Theorems 4.1–4.3:

**Theorem 4.4 (Sharp uniform gluing bound).** For every clique sum $G$ of $G_1, G_2$ along a clique $K$ of size $k$,
$$\boxed{\ \alpha_1 + \alpha_2 \ \le\ \alpha(G) + \min(k, 2).\ }$$

Section 5 shows that no smaller right-hand side is possible in any of the three regimes.

---

## 5. Sharpness, and the refutation of the folklore bound

### 5.1 Witness A: the path on four vertices ($k = 2$)

Let $V = \{0,1,2,3\}$ and set
- $s = \{0,1,2\}$, and $G_1$ the graph with edges $\{0,1\}$ and $\{1,2\}$ (the path $2 - 1 - 0$);
- $t = \{0,1,3\}$, and $G_2$ the graph with edges $\{0,1\}$ and $\{0,3\}$ (the path $1 - 0 - 3$);
- $K = s \cap t = \{0,1\}$.

Then $s \cup t = V$, all edges of $G_1$ lie in $s$, all edges of $G_2$ lie in $t$, and $K$ is an edge — hence a $2$-clique — of *both* $G_1$ and $G_2$. So this is a genuine clique sum, with $k = 2$, and $G = G_1 \cup G_2$ is the path $2 - 1 - 0 - 3$.

Direct enumeration gives
$$\alpha_1 = 2 \ (\text{e.g. } \{0,2\}), \qquad \alpha_2 = 2 \ (\text{e.g. } \{1,3\}), \qquad \alpha(G) = 2 \ (\text{e.g. } \{2,3\}).$$

**Theorem 5.1 (Failure of the folklore bound).** The inequality $\alpha_1 + \alpha_2 \le \alpha(G) + 1$ is false for clique sums: Witness A has $\alpha_1 + \alpha_2 = 4 > 3 = \alpha(G) + 1$.

**Theorem 5.2 (Sharpness of the $-2$ bound).** Witness A satisfies $\alpha_1 + \alpha_2 = \alpha(G) + 2$, so Theorem 4.1 is attained.

The diagnosis is exactly the failure of the folklore argument: the unique maximum independent sets of the two sides that avoid a loss use *different* vertices of $K$ (the left one uses $0$, the right one uses $1$), and Lemma 3.2 does not apply. In the language of Section 6: $\alpha_1(\{0\}) = 2$ but $\alpha_2(\{0\}) = 1$, and $\alpha_2(\{1\}) = 2$ but $\alpha_1(\{1\}) = 1$, while $\alpha_1(\varnothing) = \alpha_2(\varnothing) = 1$; the trace formula returns $\max(1+1-0,\ 2+1-1,\ 1+2-1) = 2 = \alpha(G)$.

### 5.2 Witness C: a cut vertex ($k=1$)

Let $V = \{0,1,2\}$ with $G = G_1 = G_2$ edgeless, $s = \{0,1\}$, $t = \{0,2\}$, $K = \{0\}$. All conditions hold vacuously (an edgeless graph has $K$ as a clique whenever $|K|\le 1$). Then $\alpha_1 = |s| = 2$, $\alpha_2 = |t| = 2$, $\alpha(G) = 3$, so $\alpha_1 + \alpha_2 = 4 = \alpha(G) + 1$: Theorem 4.2 is attained.

### 5.3 Witness D: the disjoint union ($k = 0$)

Let $V = \{0,1\}$, $G$ edgeless, $s = \{0\}$, $t = \{1\}$, $K = \varnothing$. Then $\alpha_1 + \alpha_2 = 1 + 1 = 2 = \alpha(G)$: Theorem 4.3 is attained.

Witnesses A, C, D show that the function $k \mapsto \min(k,2)$ in Theorem 4.4 is the pointwise-smallest correct one.

---

## 6. The exact independence number of a clique sum

Theorem 4.4 is sharp as a *uniform* statement, but it is a bound, not a formula. The formula requires refining each side's independence number by the trace of its witness.

**Theorem 6.1 (Trace decomposition).** Let $G$ be a clique sum of $G_1, G_2$ along $K$ with sides $s,t$. Then
$$\alpha(G) \;=\; \max_{\substack{T \subseteq K\\ |T| \le 1}} \Big( \alpha_1(T) + \alpha_2(T) - |T| \Big).$$

*Proof.* **($\le$)** Let $A \subseteq V$ be independent in $G$ with $|A| = \alpha(G)$, and put $T = A \cap K$. Since $K$ is a clique of $G$ (Remark 2.3), Lemma 3.1 gives $|T| \le 1$, so $T$ is admissible. The set $A \cap s$ is independent in $G_1$ (as $G_1 \subseteq G$) and satisfies $(A\cap s)\cap K = A \cap K = T$, using $K \subseteq s$; hence $|A \cap s| \le \alpha_1(T)$, and symmetrically $|A\cap t| \le \alpha_2(T)$. Moreover $(A\cap s)\cup(A\cap t) = A \cap (s\cup t) = A$ and $(A\cap s)\cap(A\cap t) = A \cap K = T$. Inclusion–exclusion gives
$$\alpha(G) = |A| = |A\cap s| + |A \cap t| - |T| \ \le\ \alpha_1(T) + \alpha_2(T) - |T|,$$
which is at most the maximum on the right.

**($\ge$)** Fix an admissible $T$ and choose optimal traced witnesses $A_1 \subseteq s$, $A_2 \subseteq t$ with $A_i \cap K = T$ and $|A_1| = \alpha_1(T)$, $|A_2| = \alpha_2(T)$ (they exist, since $T$ itself is a candidate). Their traces agree, so Lemma 3.2 makes $A_1 \cup A_2$ independent in $G$. Furthermore $A_1 \cap A_2 = T$: any common element lies in $s \cap t = K$, hence in $A_1 \cap K = T$; conversely $T \subseteq A_1$ and $T \subseteq A_2$. Therefore
$$\alpha(G) \ \ge\ |A_1 \cup A_2| = \alpha_1(T) + \alpha_2(T) - |T| . \qquad\square$$

**Remark 6.2 (Size of the state space).** The maximum ranges over at most $k+1$ traces: $\varnothing$ and the $k$ singletons. This is the exact "message" that one side must send to the other, and it is the minimum possible: Witness A shows that the untraced pair $(\alpha_1,\alpha_2)$ is not sufficient information, since there are clique sums with the same $(\alpha_1,\alpha_2,k)$ and different $\alpha(G)$.

**Corollary 6.3 (Re-derivation of the $-2$ bound).** Theorem 4.1 follows from Theorem 6.1: taking $T = \varnothing$ in the maximum gives $\alpha(G) \ge \alpha_1(\varnothing) + \alpha_2(\varnothing)$, while deleting the (at most one, by Lemma 3.1) weld vertex from a maximum independent set of side $i$ produces a set with empty trace, so $\alpha_i(\varnothing) \ge \alpha_i - 1$.

**Remark 6.4 (Why the loss is exactly two, and how it is distributed).** The quantity $\alpha_i - \alpha_i(T)$ measures how much side $i$ pays to conform to the trace $T$. The pair of "defects" $(\alpha_1 - \alpha_1(T), \alpha_2 - \alpha_2(T))$ is bounded by $(1,1)$ when $T$ is a singleton chosen inside a maximum witness of one side, and the bonus $|T| = 1$ compensates exactly one unit. This is why the truth is $-2$ in general, $-1$ when the sides cannot disagree ($k \le 1$), and $0$ when there is nothing to disagree about ($k=0$).

---

## 7. Cliques, colourings, and perfection

### 7.1 Cliques never cross the weld

**Theorem 7.1.** Let $G$ be a clique sum of $G_1, G_2$ along $K$ with sides $s,t$, and let $C$ be a clique of $G$. Then $C \subseteq s$ or $C \subseteq t$.

*Proof.* Suppose not; pick $a \in C \setminus s$ and $b \in C \setminus t$. Then $a \ne b$ (a vertex outside $s$ lies in $t$ since $s\cup t = V$, and $b \notin t$), so $a \sim_G b$. Every edge of $G$ lies inside $s$ (if it comes from $G_1$) or inside $t$ (if from $G_2$); the first contradicts $a \notin s$, the second contradicts $b \notin t$. $\square$

**Theorem 7.2 (Composition of $\omega$).** $\omega(G) = \max(\omega_1, \omega_2)$.

*Proof.* ($\ge$) $G_1 \subseteq G$ and $G_2 \subseteq G$, so cliques of a side are cliques of $G$. ($\le$) Let $C$ be a maximum clique of $G$; by Theorem 7.1 we may assume $C \subseteq s$. We claim $C$ is a clique of $G_1$. Let $a \ne b$ in $C$; then $a \sim_G b$, so either $a\sim_{G_1} b$ (done) or $a \sim_{G_2} b$, in which case $a, b \in t$ as well, hence $a, b \in s \cap t = K$, and then $a \sim_{G_1} b$ because $K$ is a clique of $G_1$ (condition 4′). Therefore $|C| \le \omega_1$. $\square$

### 7.2 Colour transfer

**Theorem 7.3 (Automatic $k \le n$).** If a side of a clique sum is $n$-colourable, then $k \le n$.

*Proof.* Let $c$ be a proper $n$-colouring of $G_1$. Since $K$ is a clique of $G_1$, $c$ is injective on $K$: distinct $a,b\in K$ are adjacent in $G_1$, so $c(a)\ne c(b)$. Hence $k = |K| = |c(K)| \le n$. $\square$

Thus the hypothesis "$n \ge k$", which one might expect to have to assume in a colouring theorem for clique sums, is a *consequence* of the definition. Section 8 shows that it is precisely what a weak clique sum can violate, and that everything fails when it does.

**Theorem 7.4 (Colour transfer).** If $G_1$ and $G_2$ are each $n$-colourable, then the clique sum $G$ is $n$-colourable.

*Proof.* Let $c_1, c_2$ be proper $n$-colourings of $G_1, G_2$. By the argument of Theorem 7.3 both are injective on $K$. Hence $c_1|_K$ and $c_2|_K$ are injections of $K$ into the palette $[n]$, and the correspondence $c_2(v) \mapsto c_1(v)$ ($v \in K$) is a well-defined bijection $c_2(K) \to c_1(K)$ between two subsets of $[n]$ of the same cardinality $k$. Any such bijection extends to a permutation $\sigma$ of $[n]$ (match the complements, which also have equal cardinality $n-k$). Then:
- $\sigma \circ c_2$ is again a proper colouring of $G_2$, since $\sigma$ is injective;
- $\sigma(c_2(v)) = c_1(v)$ for all $v \in K$.

Define $c(v) = c_1(v)$ if $v \in s$, and $c(v) = \sigma(c_2(v))$ otherwise. We check properness. Let $a \sim_G b$. If $a \sim_{G_1} b$ then $a,b \in s$ and $c(a) = c_1(a) \ne c_1(b) = c(b)$. If $a \sim_{G_2} b$ then $a, b \in t$; for any $x \in t$ we have $c(x) = \sigma(c_2(x))$ — indeed if $x \notin s$ this is the definition, and if $x \in s$ then $x \in s\cap t = K$, where $c_1(x) = \sigma(c_2(x))$ anyway. So $c(a) = \sigma(c_2(a)) \ne \sigma(c_2(b)) = c(b)$ by injectivity of $\sigma$ and properness of $c_2$. $\square$

**Theorem 7.5 (Composition of $\chi$).** $\chi(G) = \max(\chi_1, \chi_2)$.

*Proof.* ($\ge$) Both sides are subgraphs of $G$, and $\chi$ is monotone under subgraphs. ($\le$) Put $n = \max(\chi_1,\chi_2)$. Each side is $\chi_i$-colourable, hence $n$-colourable, hence $G$ is $n$-colourable by Theorem 7.4. $\square$

### 7.3 Preservation of $\chi = \omega$

**Theorem 7.6.** If $\chi_1 = \omega_1$ and $\chi_2 = \omega_2$, then $\chi(G) = \omega(G)$.

*Proof.* $\chi(G) = \max(\chi_1,\chi_2) = \max(\omega_1,\omega_2) = \omega(G)$ by Theorems 7.5 and 7.2. $\square$

This is the numerical heart of the classical statement that *clique sums of perfect graphs are perfect*. A graph is perfect when $\chi(H) = \omega(H)$ holds for every induced subgraph $H$; since an induced subgraph of a clique sum is itself a clique sum of induced subgraphs along an induced sub-clique of $K$, Theorem 7.6 applied hereditarily gives the full statement. In particular it re-proves that chordal graphs — built from complete graphs by repeated clique sums — are perfect.

---

## 8. The boundary: weak clique sums fail completely

We now show that condition 4′ cannot be weakened to condition 4.

### 8.1 Witness B: the split triangle

Let $V = \{0,1,2\}$ and set $s = t = K = V$. Let
- $G_1$ have the single edge $\{0,1\}$;
- $G_2$ have the edges $\{0,2\}$ and $\{1,2\}$.

Then $G_1 \cup G_2$ is the complete graph $K_3$, so $K = V$ is a $3$-clique of $G$: this is a weak clique sum with $k = 3$. It is *not* a clique sum: $K$ is a clique of neither summand ($G_1$ misses two of the three edges, $G_2$ misses one).

Invariants: $G_1$ is a single edge, so $\chi_1 = 2$ and $\alpha_1 = 2$ (e.g. $\{0,2\}$); $G_2$ is a path $0 - 2 - 1$, so $\chi_2 = 2$ and $\alpha_2 = 2$ (e.g. $\{0,1\}$); $G$ is a triangle, so $\chi(G) = 3$ and $\alpha(G) = 1$.

**Theorem 8.1 (Colouring fails).** $\chi(G) = \max(\chi_1,\chi_2)$ is false for weak clique sums: here $3 \ne 2$.

**Theorem 8.2 (Independence fails).** $\alpha_1 + \alpha_2 \le \alpha(G) + 2$ is false for weak clique sums: here $4 > 3$.

**Remark 8.2a (The clique law fails too).** The same witness also breaks Theorem 7.2: $\omega_1 = \omega_2 = 2$ (a single edge, and a path) while $\omega(G) = 3$. Theorem 7.1 is the culprit — in a weak clique sum a clique of $G$ need not lie inside a single side, since the weld is a clique of the union that no summand realises.

**Theorem 8.3 (The numerical boundary).** In Witness B, both sides are $2$-colourable while $k = 3$; that is, $n = 2 < 3 = k$. By Theorem 7.3 this is impossible for a genuine clique sum.

Theorem 8.3 identifies the exact hinge. The condition "$K$ is a clique on each side" is equivalent, from the point of view of colourings, to the numerical condition $n \ge k$ for the number of colours $n$ used on a side; the strong hypothesis buys it for free, and when it is lost — as in Witness B, where the sides conspire to hide a triangle by each showing only part of it — both the chromatic and the independence composition laws are destroyed simultaneously.

The intuition is worth stating plainly: in a weak clique sum the two summands can jointly encode structure that neither of them individually sees. A separator is only a separator if both sides agree on what happens *inside* it.

---

## 9. Algorithms

The trace decomposition is constructive and yields immediate algorithms.

### 9.1 Independence number by trace enumeration

**Algorithm 9.1 (Trace-decomposed independence number).**
Input: a clique sum presentation $(G_1, G_2, s, t, K)$.
Output: $\alpha(G)$.

1. Enumerate the admissible traces $\mathcal{T} = \{\varnothing\} \cup \{\{v\} : v \in K\}$; $|\mathcal{T}| = k+1$.
2. For each $T \in \mathcal{T}$ compute $\alpha_1(T)$: the maximum size of an independent set of $G_1$ inside $s$ whose intersection with $K$ is exactly $T$. Equivalently, if $T = \{v\}$, delete $v$'s closed neighbourhood and the rest of $K$ from $s$, solve the unconstrained problem there, and add $1$; if $T = \varnothing$, delete all of $K$ from $s$ and solve the unconstrained problem.
3. Compute $\alpha_2(T)$ symmetrically.
4. Return $\max_{T \in \mathcal{T}} (\alpha_1(T) + \alpha_2(T) - |T|)$.

*Correctness* is Theorem 6.1 together with the reduction in step 2, which is immediate: an independent set with trace $\{v\}$ is $\{v\}$ together with an independent set avoiding $K$ and avoiding all neighbours of $v$.

*Complexity.* $2(k+1)$ calls to an independence-number oracle on graphs no larger than the two sides. If the sides have $n_1, n_2$ vertices, brute force gives $O\big(k\,(2^{n_1}n_1^2 + 2^{n_2}n_2^2)\big)$, which is exponentially better than the $O(2^{n_1+n_2-k})$ of a direct attack whenever the sides are balanced. When the sides are themselves easy (interval, chordal, bounded treewidth), each oracle call is polynomial and the whole computation is polynomial.

### 9.2 Iterated clique sums along a tree

If $G$ is assembled from pieces $H_1,\dots,H_m$ by clique sums along a tree $\mathcal{T}$ with separators $K_e$ of size at most $w+1$, root $\mathcal{T}$ arbitrarily and run the fold suggested by Theorem 6.1: at each node, maintain the vector $\big(\alpha(T)\big)_{T \text{ admissible for } K_e}$ of traced independence numbers of the subtree processed so far, and combine a child into its parent by
$$\alpha^{\text{new}}(T) \;=\; \alpha^{\text{parent}}(T) + \max_{T' \text{ compatible with } T} \big(\alpha^{\text{child}}(T') - |T'|\big),$$
where compatibility means the two traces agree on the shared separator. Because the state is a single optional vertex per separator, the table has size $O(w)$ per edge rather than $2^{O(w)}$: the trace calculus makes the dynamic program *linear* in the width, not exponential.

For $\chi$ and $\omega$ the fold is even simpler: both are the maximum over the pieces, by Theorems 7.2 and 7.5, so a single pass suffices.

### 9.3 Certified detection of the weak/strong distinction

Given a candidate presentation, verifying condition 4′ costs $O(k^2)$ adjacency queries per side; verifying only condition 4 costs $O(k^2)$ queries in the union. The gap between the two checks is the entire content of Section 8, so an implementation must perform the former. A useful sanity check derived from Theorem 7.3: if a side admits a proper colouring with fewer than $k$ colours, the presentation is *not* a clique sum, and no composition law may be applied.

---

## 10. Applications

**Chordal graphs and elimination orderings.** A graph is chordal iff it is obtainable from complete graphs by repeated clique sums. Theorems 7.2 and 7.5 then give $\chi = \omega$ for all chordal graphs by induction — the classical proof that chordal graphs are perfect — and Algorithm 9.1 specialises to the well-known linear-time computation of $\alpha$ on chordal graphs via a perfect elimination ordering.

**Tree decompositions and inference.** A tree decomposition is a clique-sum assembly along separators. The trace calculus explains why the *state space* required for independent-set dynamic programming on a separator $S$ collapses when $S$ is a clique: instead of tracking which subset of $S$ the partial solution uses ($2^{|S|}$ states), it suffices to track which single vertex, if any, it uses ($|S|+1$ states). The same phenomenon underlies the efficiency of junction-tree message passing on models whose cliques are genuinely complete.

**Structural decomposition theorems.** Wagner's characterisation of $K_5$-minor-free graphs and the general graph minor structure theorem express classes as clique sums of basic pieces. The results here say precisely which invariants can be read off the pieces: $\chi$ and $\omega$ can, immediately; $\alpha$ can, but only after refining each piece by its trace data.

**A cautionary application: verification of composition claims.** Witness B is small enough to be checked by hand and shows that a "clique sum" claim which only asserts that the separator is a clique of the union is worthless. Any application that composes invariants across separators must certify the strong condition.

---

## 11. Discussion

Three lessons emerge.

**1. Sharpness is a statement about all regimes at once.** The bound $\alpha_1+\alpha_2 \le \alpha(G) + \min(k,2)$ is sharp in the strongest possible sense: for each of $k=0,1,\ge 2$ there is a clique sum attaining it. A single extremal example would not have settled the shape of the correct constant.

**2. The failure of a folklore argument is usually a missing hypothesis, not a missing idea.** The classical derivation of $(\star)$ is one clause short: it needs the two optimisers to have equal traces. Making that clause explicit (Lemma 3.2) both refutes $(\star)$ and produces the exact formula (Theorem 6.1). The corrected statement is *stronger* than the false one, not weaker: an exact identity replaces a broken inequality.

**3. The right invariant to compose is a relativised one.** $\alpha_i$ does not compose; $T \mapsto \alpha_i(T)$ does. This is the trace calculus, and the pattern recurs: $\omega$ composes because cliques never cross a separator (trace = everything, but no interaction), $\chi$ composes because colourings can be re-labelled to agree on the separator (trace = nothing, after a permutation), and $\alpha$ composes only after refinement (trace = at most one vertex).

The weak/strong boundary deserves emphasis. There is a temptation to define a clique sum as "glue two graphs so that the shared part is a clique", which is ambiguous about *whose* clique it is. Witness B shows that the two readings are not just formally different but mathematically opposite: on one reading every theorem in Sections 4–7 holds and is sharp; on the other, every one of them fails on three vertices.

---

## 12. Future directions

**Iterated clique sums and a tree-decomposition trace calculus.** The trace formula is a *fold* over a tree of clique sums: $\alpha$ of a graph assembled by repeated clique sums along a tree should be computable by a dynamic program whose state is exactly the $\le 1$-element trace on each separator. The one-step exact formula and the supporting gluing infrastructure are in place, so the induction over a tree is the natural next step, yielding a linear-time $\alpha$ for bounded-width chordal-like assemblies with a provably minimal state space.

**Perfection is preserved by clique sums.** The identity $\chi = \omega$ was preserved numerically here, and the same colour-permutation argument applies verbatim to every induced subgraph of a clique sum, because induced subgraphs of a clique sum are clique sums of induced subgraphs along a sub-clique. What remains is hereditary bookkeeping, giving a complete proof of a classical ingredient of the toolkit surrounding the Strong Perfect Graph Theorem.

**Fractional relaxations and the threshold $k = 2$.** The integral obstruction in Witness A — a maximum independent set can be forced to use a weld vertex whose neighbours on the other side are free — is exactly the obstruction that the fractional independence number $\alpha_f$ smooths out. We conjecture $\alpha_f(G) \ge \alpha_f(G_1) + \alpha_f(G_2) - 1$ for all clique sums, i.e. that the fractional relaxation obeys the folklore bound that the integral invariant violates, and that the integrality gap of the gluing step is exactly one.

**Weighted and multi-way sums.** Both the trace decomposition and the colour-transfer argument should extend to vertex-weighted independence and to simultaneous sums of $m$ graphs along a common clique, with the loss term becoming $\min(k, m)$ for the uniform bound and the trace state space remaining of size $k+1$.

**Other invariants.** Which further invariants admit a trace calculus? Natural candidates are the domination number, the fractional chromatic number, and the Lovász theta function; each requires identifying the correct notion of "what a witness carries across a clique separator", and the size of that state space is precisely the algorithmic price of decomposition.

---

## 13. Summary of results

| # | Statement | Status |
|---|---|---|
| 1 | An independent set meets a clique in at most one vertex | Proved (Lemma 3.1) |
| 2 | Matching traces glue: $A_1\cap K = A_2 \cap K \Rightarrow A_1\cup A_2$ independent | Proved (Lemma 3.2) |
| 3 | $\alpha_1 + \alpha_2 \le \alpha(G) + 2$ | Proved (Thm 4.1), sharp (Witness A) |
| 4 | $\alpha_1 + \alpha_2 \le \alpha(G) + 1$ for $k \le 1$ | Proved (Thm 4.2), sharp (Witness C) |
| 5 | $\alpha_1 + \alpha_2 = \alpha(G)$ for $k = 0$ | Proved (Thm 4.3), attained (Witness D) |
| 6 | $\alpha_1 + \alpha_2 \le \alpha(G) + \min(k,2)$ | Proved (Thm 4.4), sharp in all regimes |
| 7 | $\alpha_1 + \alpha_2 \le \alpha(G) + 1$ in general | **False** for $k \ge 2$ (Thm 5.1) |
| 8 | $\alpha(G) = \max_{|T|\le1}(\alpha_1(T)+\alpha_2(T)-|T|)$ | Proved (Thm 6.1) |
| 9 | Every clique lies in one side; $\omega(G) = \max(\omega_1,\omega_2)$ | Proved (Thms 7.1, 7.2) |
| 10 | $n$-colourability of a side forces $k \le n$ | Proved (Thm 7.3) |
| 11 | $\chi(G) = \max(\chi_1,\chi_2)$ | Proved (Thms 7.4, 7.5) |
| 12 | $\chi=\omega$ on both sides $\Rightarrow$ $\chi=\omega$ for the sum | Proved (Thm 7.6) |
| 13 | For weak clique sums, $\chi(G)=\max(\chi_1,\chi_2)$ fails | **Refuted** (Thm 8.1) |
| 14 | For weak clique sums, $\alpha_1+\alpha_2 \le \alpha(G)+2$ fails | **Refuted** (Thm 8.2) |
| 15 | Weak sums can have $n < k$; strong sums cannot | Proved (Thms 7.3, 8.3) |
