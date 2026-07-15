# Upper-Bound Seed Reductions and Dynamic Peeling for the Maximum Clique Problem

**Aristotle**  
**July 15, 2026**

## Abstract

We develop a self-contained correctness theory for strengthening maximum-clique reductions with arbitrary valid upper-bound functions. Given a finite simple graph $G$, an incumbent clique size $k$, and a seed set $D$, every clique containing $D$ consists of the seed together with a clique in the common neighborhood of $D$. Consequently, if $U$ bounds clique size on queried vertex sets, then $|D|+U(N(D))\le k$ certifies that no clique larger than $k$ contains $D$. Singleton and two-vertex seeds yield upper-bound core and truss reductions, while general seeds give a unified reduction rule. We prove simultaneous preservation for finite families of successful reductions and a seed-cover criterion that converts local certificates into a global upper bound. We then treat dynamic ordered vertex peeling, allowing the upper-bound function to be recomputed at every step and requiring validity only on the current local neighborhood. Every clique capable of improving the incumbent survives all sound removals; if the final state has clique number at most $k$, then $k$ bounds the original graph. We present algorithms, complexity parameters, examples, implementation guidance, and extensions toward edge peeling, mixed fixed points, and transformation-based bounds.

## 1. Introduction

For a finite simple graph $G=(V,E)$, a clique is a set of pairwise adjacent vertices. The **maximum clique problem** asks for the clique number

$$
\omega(G)=\max\{|C|:C\subseteq V\text{ is a clique}\}.
$$

The problem is a central model of discrete compatibility. Vertices may represent mutually compatible assignments, correlated biological entities, communication terminals, or jointly feasible choices. Its computational difficulty makes preprocessing and upper bounding essential.

A typical exact solver maintains an incumbent clique of size $k$, so $k\le\omega(G)$. It then searches only for a clique with more than $k$ vertices. Reduction rules simplify the graph while preserving every such improving clique. Classical vertex-core rules use degree, and edge-truss rules use the number of common neighbors or triangles. These tests can be weak because cardinality ignores adjacency among the candidates. A neighborhood may contain many vertices but have small clique number.

The present framework replaces raw local counts by upper bounds on local clique size. The replacement is abstract: the upper bound may arise from coloring, relaxations, structural decompositions, or exact computation on a small subproblem. Correctness needs only one semantic property—that the returned number bounds every clique in the queried set.

Our first contribution is a general seed calculus. A seed $D$ may consist of one vertex, the endpoints of an edge, or an arbitrary finite vertex set. If a clique contains $D$, all its remaining vertices lie in the common neighborhood of $D$. This gives a universal counting inequality and a sound reduction test. Our second contribution lifts individual tests to finite families and gives a cover condition under which reductions certify a global upper bound. Our third contribution establishes dynamic peeling correctness when local bounds are recomputed after earlier removals. This state-sensitive form is necessary for iterative algorithms: validity on each current local neighborhood suffices, even if the bound varies from step to step.

The scope is correctness rather than a claim about a specific upper-bound routine or empirical speedup. The results identify the exact contracts an implementation must satisfy and isolate the parameters governing computational cost.

## 2. Graph-theoretic setting

### 2.1 Finite simple graphs and cliques

A **finite simple graph** is a pair $G=(V,E)$ where $V$ is finite and $E$ is an irreflexive, symmetric adjacency relation. Thus there are no loops or parallel edges. A finite set $C\subseteq V$ is a **clique** when every two distinct vertices $x,y\in C$ satisfy $xy\in E$.

For $S\subseteq V$, write $G[S]$ for the subgraph induced by $S$. Its clique number is

$$
\omega(G[S])=\max\{|C|:C\subseteq S\text{ is a clique in }G\}.
$$

An integer $k$ is called the **incumbent size** when a clique of size $k$ is already known. Correctness of the reductions below does not require the witness clique itself; it uses $k$ as the threshold separating improving cliques, whose sizes exceed $k$, from non-improving cliques.

### 2.2 Upper-bound functions

**Definition 2.1 (Valid upper-bound function).** A function $U:2^V\to\mathbb N$ is valid for $G$ if, for every $S\subseteq V$ and every clique $C\subseteq S$,

$$
|C|\le U(S).
$$

Equivalently, $\omega(G[S])\le U(S)$ for every $S$. We do not require $U$ to be monotone, exact, or polynomial-time computable. This generality is useful because correctness and cost can be analyzed separately.

A standard example is a proper coloring of $G[S]$. If a coloring uses $q$ colors, every clique in $S$ has at most one vertex of each color, so $U(S)=q$ is valid. The trivial choice $U(S)=|S|$ is also valid and recovers size-based reductions.

### 2.3 Seeds and common neighborhoods

**Definition 2.2 (Common neighborhood).** For a finite seed $D\subseteq V$, define

$$
N(D)=\{x\in V:\text{ for every }d\in D,\ x\text{ is adjacent to }d\}.
$$

Because the graph has no loops, a seed vertex does not belong to $N(D)$ whenever $D$ is nonempty: it is not adjacent to itself. For a singleton, $N(\{v\})$ is the ordinary open neighborhood of $v$. For two vertices $u,v$, $N(\{u,v\})=N(u)\cap N(v)$.

**Definition 2.3 (Seed reducibility).** Given an incumbent $k$ and valid upper bound $U$, a seed $D$ is **reducible** if

$$
|D|+U(N(D))\le k.
$$

This inequality is meaningful even when $D$ is not a clique. A non-clique seed cannot be contained in any clique and is automatically irrelevant, although the numerical test may or may not detect that fact. For core and truss applications the seeds are, respectively, vertices and edge endpoints.

## 3. The seed counting principle

**Lemma 3.1 (Clique decomposition around a seed).** Let $C$ be a clique and let $D\subseteq C$. Then $C\setminus D$ is a clique contained in $N(D)$.

**Proof sketch.** Any subset of a clique is a clique, so $C\setminus D$ is a clique. If $x\in C\setminus D$ and $d\in D$, then $x$ and $d$ are distinct members of $C$ and hence adjacent. Thus $x$ is adjacent to every vertex of $D$, which places it in $N(D)$. $\square$

**Theorem 3.2 (Seed common-neighborhood bound).** Let $U$ be valid for $G$. If $C$ is a clique containing a finite seed $D$, then

$$
|C|\le |D|+U(N(D)).
$$

**Proof sketch.** By Lemma 3.1, $C\setminus D$ is a clique in $N(D)$, so validity gives $|C\setminus D|\le U(N(D))$. Since $D\subseteq C$, the disjoint union $C=D\mathbin{\dot\cup}(C\setminus D)$ yields $|C|=|D|+|C\setminus D|$. Combining the two relations proves the inequality. $\square$

The theorem is the basic bridge from local upper bounds to global reduction safety. It retains structural information that the weaker estimate $|C|\le |D|+|N(D)|$ discards.

**Theorem 3.3 (Seed Reduction Theorem).** Let $U$ be valid, let $k\in\mathbb N$, and let $D$ be reducible. No clique $C$ with $|C|>k$ contains $D$.

**Proof sketch.** If $D\subseteq C$, Theorem 3.2 and reducibility imply

$$
|C|\le |D|+U(N(D))\le k,
$$

contradicting $|C|>k$. $\square$

This theorem states precisely what deletion may preserve. It does not claim that a reducible seed belongs to no clique; it claims that the seed belongs to no clique capable of improving the incumbent.

## 4. Core, truss, and generalized seed reductions

### 4.1 Vertex reduction

**Corollary 4.1 (Upper-bound core reduction).** Let $v\in V$. If

$$
1+U(N(\{v\}))\le k,
$$

then no clique of size greater than $k$ contains $v$. Therefore deleting $v$ preserves every clique that can improve the incumbent.

**Proof sketch.** Apply Theorem 3.3 to the singleton seed $D=\{v\}$, whose cardinality is one. $\square$

With the trivial bound $U(S)=|S|$, the test becomes $1+\deg(v)\le k$, or $\deg(v)<k$, the familiar core-style deletion criterion. Any sharper valid $U$ can certify additional vertices.

### 4.2 Edge reduction

**Corollary 4.2 (Upper-bound truss reduction).** Let $u\ne v$. If

$$
2+U(N(\{u,v\}))\le k,
$$

then no clique of size greater than $k$ contains both $u$ and $v$. In particular, when $uv\in E$, deleting the edge $uv$ preserves every clique larger than $k$.

**Proof sketch.** Apply Theorem 3.3 to $D=\{u,v\}$, which has cardinality two. Any clique using edge $uv$ contains both endpoints and is therefore bounded by the displayed quantity. $\square$

Using $U(S)=|S|$ recovers a common-neighbor count. A structural upper bound can be much smaller than $|N(u)\cap N(v)|$.

### 4.3 Larger seeds

For $|D|=d$, the criterion

$$
d+U(N(D))\le k
$$

exposes a continuum between cheap coarse reductions and expensive refined ones. Larger seeds constrain extensions more strongly because their common neighborhoods tend to shrink, but there are potentially $\binom{|V|}{d}$ seeds to examine. This seed size is an explicit algorithmic trade-off parameter.

## 5. Families of reductions and global certification

Algorithms usually discover many reducible seeds in one pass. Their collective effect is governed by the following statement.

**Theorem 5.1 (Family Preservation Theorem).** Let $\mathcal R$ be a finite family of seeds such that

$$
|D|+U(N(D))\le k
$$

for every $D\in\mathcal R$. If $C$ is a clique with $|C|>k$, then no $D\in\mathcal R$ is contained in $C$.

**Proof sketch.** Fix $D\in\mathcal R$. Its assumed inequality makes it reducible, so Theorem 3.3 gives $D\nsubseteq C$. Since $D$ was arbitrary, the conclusion holds for all seeds in the family. $\square$

The theorem permits batched or parallel evaluation against a fixed graph state. Each successful certificate is independently incompatible with every improving clique.

**Definition 5.2 (Large-clique seed cover).** A family $\mathcal R$ is a **large-clique seed cover at threshold $k$** if every clique $C$ with $|C|>k$ contains at least one seed $D\in\mathcal R$.

**Theorem 5.3 (Certified Seed-Cover Upper Bound).** Let $U$ be valid. Suppose every seed in $\mathcal R$ is reducible at threshold $k$, and suppose $\mathcal R$ is a large-clique seed cover. Then

$$
\omega(G)\le k.
$$

**Proof sketch.** Assume a clique $C$ has size greater than $k$. The cover property supplies $D\in\mathcal R$ with $D\subseteq C$. Family preservation says no seed in $\mathcal R$ can be contained in $C$, a contradiction. Hence every clique has size at most $k$. $\square$

If a clique of size $k$ is already known, the theorem proves $\omega(G)=k$. This is a general upper-bound improvement framework: local reduction certificates plus a coverage argument become a global certificate.

## 6. Dynamic local validity

Iterative peeling changes the relevant graph. We therefore formulate validity relative to a current set.

**Definition 6.1 (Validity on a current set).** For $S\subseteq V$, a function $U_S:2^V\to\mathbb N$ is **valid on $S$** if every clique $C\subseteq S$ satisfies

$$
|C|\le U_S(S).
$$

More generally, when the function is queried at a particular set $T$, the required contract is that every clique contained in $T$ has size at most $U_S(T)$. No claim is required outside the queried set.

**Definition 6.2 (Current common neighborhood).** For a current vertex set $S$ and seed $D$, define

$$
N_S(D)=S\cap N(D).
$$

**Definition 6.3 (Locally peelable vertex).** A vertex $v$ is peelable from $S$ at threshold $k$ under a bound $U$ if $v\in S$ and

$$
1+U(N_S(\{v\}))\le k,
$$

where $U$ is valid for all cliques contained in $N_S(\{v\})$.

This definition allows bounds to be recomputed after every removal. It also avoids imposing a stronger global condition than correctness needs.

**Theorem 6.4 (One-Step Dynamic Peeling Soundness).** Let $C\subseteq S$ be a clique with $|C|>k$. If $v$ is locally peelable from $S$ at threshold $k$, then $v\notin C$.

**Proof sketch.** Suppose $v\in C$. Then $C\setminus\{v\}$ is a clique. Every one of its vertices lies in $S$ and is adjacent to $v$, so

$$
C\setminus\{v\}\subseteq N_S(\{v\}).
$$

Local validity yields $|C\setminus\{v\}|\le U(N_S(\{v\}))$. Since $v\in C$,

$$
|C|=1+|C\setminus\{v\}|\le 1+U(N_S(\{v\}))\le k,
$$

contrary to $|C|>k$. $\square$

## 7. Ordered peeling

Consider states $S_0,S_1,\ldots,S_n$ and removed vertices $v_0,v_1,\ldots,v_{n-1}$ satisfying

$$
S_{i+1}=S_i\setminus\{v_i\}
$$

for $0\le i<n$. At each step $i$, let $U_i$ be valid on the queried local set $N_{S_i}(\{v_i\})$, and assume

$$
1+U_i(N_{S_i}(\{v_i\}))\le k.
$$

**Theorem 7.1 (Ordered Peeling Preservation Theorem).** Under these assumptions, every clique $C\subseteq S_0$ with $|C|>k$ remains in every state. In particular,

$$
C\subseteq S_n.
$$

**Proof sketch.** Induct on the number of removals. The base case is $C\subseteq S_0$. Suppose $C\subseteq S_i$. By Theorem 6.4, the peelable vertex $v_i$ is not in $C$. Therefore deleting $v_i$ leaves all vertices of $C$ present, so $C\subseteq S_{i+1}$. Repeating this argument through step $n-1$ proves the claim. $\square$

The upper-bound function may change with $i$. This flexibility covers algorithms that recolor neighborhoods, change heuristics, or spend different computational budgets as the instance shrinks.

**Theorem 7.2 (Peeling Certification Theorem).** Assume every clique of $G$ is contained in $S_0$. Perform an ordered peeling sequence satisfying the hypotheses of Theorem 7.1. If every clique contained in $S_n$ has cardinality at most $k$, then

$$
\omega(G)\le k.
$$

**Proof sketch.** If an original clique $C$ had $|C|>k$, the initial containment assumption would put it in $S_0$. Theorem 7.1 would then force $C\subseteq S_n$. This contradicts the final-state upper-bound condition. $\square$

Usually $S_0=V$, making initial containment automatic. The final condition can come from an exact solution of the reduced graph, a coloring bound, a seed-cover certificate, or any other valid argument.

## 8. Algorithms

### 8.1 Greedy-color upper bound

A proper coloring supplies a practical bound. Process vertices of $G[S]$ in a chosen order and assign each the smallest positive color absent from its already colored neighbors. If $q$ colors are used, return $q$.

The coloring is proper by construction. A clique has pairwise adjacent vertices and therefore cannot repeat a color, proving $\omega(G[S])\le q$. With adjacency sets, a straightforward implementation costs $O(|S|^2)$ time and $O(|S|)$ auxiliary space, excluding graph storage. Better ordering may strengthen the bound without changing validity.

### 8.2 Dynamic vertex peeling algorithm

Given $G$, $k$, and a valid bound routine:

1. Set $S\leftarrow V$.
2. Search for $v\in S$ satisfying $1+U(N_S(v))\le k$.
3. If found, replace $S$ by $S\setminus\{v\}$ and restart or update the search.
4. Stop when no vertex passes.

Correctness follows from Theorem 7.1. If evaluating a local bound on at most $n$ vertices costs $T_U(n)$ and a naive implementation scans at most $n$ vertices after each of at most $n$ removals, the total is

$$
O(n^2(T_U(n)+n))
$$

under a simple neighborhood-intersection model. Incremental queues and cached data can substantially reduce this bound, but cached bounds must continue to satisfy the local validity contract.

### 8.3 Batched seed-cover certification

Enumerate a candidate family $\mathcal R$, test reducibility for each seed, and retain successful certificates. Then determine whether every putative clique larger than $k$ contains a successful seed. If so, Theorem 5.3 certifies $\omega(G)\le k$.

For all seeds of fixed size $d$, enumeration alone costs $O(n^d)$. If common-neighborhood construction costs $T_N(n,d)$ and upper-bound evaluation costs $T_U(n)$, a direct pass costs

$$
O\!\left(n^d\bigl(T_N(n,d)+T_U(n)\bigr)\right).
$$

This explains why $d$ is a strength-cost control. In practice, one restricts to clique seeds, promising local structures, or seeds generated during search.

## 9. Numerical examples

### 9.1 A vertex beyond degree reduction

Let $k=4$ and let $v$ have six current neighbors. The cardinality bound gives $1+6=7$, so it cannot delete $v$. Suppose the induced graph on those neighbors is properly colorable with three colors. Then $U(N(v))=3$ is valid and

$$
1+U(N(v))=4\le k.
$$

Corollary 4.1 deletes $v$. The gain comes entirely from adjacency structure within the neighborhood.

### 9.2 An edge with a bipartite common neighborhood

Let $uv$ be an edge and again let $k=4$. Suppose $u$ and $v$ have five common neighbors, but the graph induced by them is bipartite. Two colors bound every clique there by $2$. Hence

$$
2+U(N(\{u,v\}))=2+2=4,
$$

and Corollary 4.2 permits deletion of $uv$. A raw common-neighbor count would give $2+5=7$ and fail.

### 9.3 A peeling cascade

Take an incumbent $k=3$. Suppose a first vertex $a$ has a local neighborhood with coloring bound $2$, so $1+2=3$ and $a$ is removed. Its deletion may reduce a second vertex’s current neighborhood enough that a recomputed coloring now uses only two colors. The second vertex becomes peelable, and so on. Theorem 7.1 certifies the whole cascade even though each bound is computed on a different current set.

## 10. Applications and implementation considerations

The framework applies wherever maximum clique models compatibility. In coding theory, vertices may represent candidate codewords and edges acceptable pairwise relations. In bioinformatics, cliques can represent mutually interacting entities. In scheduling and resource allocation, vertices can encode choices that are jointly feasible exactly when adjacent. In each setting, domain-specific upper bounds can be inserted without changing the reduction proofs.

Three engineering principles follow from the mathematics.

First, the incumbent matters. Increasing $k$ weakens the search objective but strengthens reduction inequalities, so heuristic discovery of a good clique can trigger extensive peeling.

Second, bound strength must be balanced against cost. The trivial cardinality bound is nearly free. Greedy coloring is stronger and still inexpensive. More elaborate relaxations may be worthwhile only on difficult neighborhoods. A tiered policy can try cheap bounds first and invoke stronger routines selectively.

Third, state management is part of correctness. At step $i$, the bound must apply to $N_{S_i}(v_i)$, not merely to an obsolete neighborhood. Recomputing is the simplest safe strategy. Incremental maintenance is also safe when it preserves the semantic upper-bound property on each queried current set.

For parallel processing, one may evaluate many seeds against a snapshot $S_i$. The Family Preservation Theorem justifies simultaneously applying all certificates derived from that same valid snapshot, provided the concrete deletions match the logical conclusion. Vertex certificates permit deletion of those vertices. Two-endpoint certificates permit deleting the corresponding edges, not necessarily both endpoints.

## 11. Discussion

The seed inequality unifies several reduction styles:

$$
|D|+U(N(D))\le k.
$$

Its proof uses only heredity of cliques under subsets, the common-neighbor property, and cardinality addition. This simplicity is an advantage: stronger upper-bound technology can be substituted without revisiting the safety argument.

The framework also clarifies the difference between preservation and certification. A reduction theorem says that improving cliques survive. It does not by itself say no improving clique exists. Global certification requires an additional terminal argument: a seed cover, a final-state upper bound, or an exact solution of the remainder. Keeping these logical roles separate prevents circular reasoning.

There are limitations. The theory does not determine which upper bound will be effective on a graph class. It does not establish a particular asymptotic running time without a specified data structure and bound routine. Nor does the vertex-peeling sequence alone establish correctness for edge removals or transformations that change the optimum by an offset. Those operations require their own state relations and preservation statements.

Nevertheless, the results provide a modular foundation. The upper-bound routine promises local validity; the reduction layer converts validity into preservation; and the terminal layer converts preservation plus a final certificate into a global upper bound.

## 12. Future work

Several directions extend the present theory.

1. Define exact parameterized upper-bound core and truss graph operators and identify them with singleton, pair, and size-$d$ seed rules.
2. Extend ordered correctness to edge-removal sequences and mixed vertex-edge fixed-point iteration.
3. Specify executable finite-graph implementations and prove that their outputs realize the abstract state transition $S_{i+1}=S_i\setminus\{v_i\}$.
4. State data-structure assumptions explicitly and derive operation counts and asymptotic running-time bounds.
5. Model graph transformations that preserve clique number up to a known offset, then integrate repeated transformations with reduction-based upper-bound improvement.
6. Study adaptive policies that choose seed size and upper-bound strength from local graph features.
7. Investigate certificate formats for seed covers and final-state bounds that can be checked independently and efficiently.

## 13. Conclusion

A valid upper bound can do more than estimate the answer to the maximum clique problem. Applied to a seed’s common neighborhood, it certifies that the seed cannot occur in any clique larger than the incumbent. Singleton seeds yield core-style vertex deletion, pair seeds yield truss-style edge deletion, and arbitrary seeds provide a general strength-cost hierarchy. Families of certificates preserve all improving cliques, while a covering family proves a global upper bound.

Dynamic peeling retains these guarantees under repeated recomputation. At each step, validity is needed only on the current local neighborhood. One-step soundness then composes by induction: every improving clique survives every removal. If the reduced final state admits no clique above the threshold, neither did the original graph.

The resulting architecture is concise and reusable: derive a local upper bound, turn it into a reduction certificate, compose certificates across a sequence or family, and close the argument with a cover or final-state bound. It transforms upper bounds from passive estimates into active tools for eliminating impossible parts of the search space.