# Upper-Bound-Driven Core and Truss Reductions for the Maximum Clique Problem

## Abstract

We develop a general mathematical framework for strengthening reduction rules for the Maximum Clique Problem by means of clique upper-bound functions. For a simple graph $G=(V,E)$ and a vertex region $S\subseteq V$, an upper-bound function $U(S)$ is required only to dominate the cardinality of every finite clique contained in $S$. Given a proposed pattern $D$, every clique containing $D$ consists of $D$ together with a clique in the common neighborhood of $D$. This yields the extension inequality

$$
|C|\le |D|+U(S\cap N(D)).
$$

We prove the associated exclusion criterion: if the right-hand side is below a target $k$, no clique of size at least $k$ in $S$ contains $D$. Singleton and two-vertex instances give upper-bound-enhanced core and truss tests. We then define certified vertex peeling and prove that one step, and hence every finite sequence of steps, preserves every finite clique of size at least $k$. We also show that the pointwise minimum of valid upper bounds remains valid, providing a principled basis for combining bounding procedures. Algorithms, illustrative computations, complexity parameters, and applications to exact clique search are discussed. The framework isolates correctness from the particular bound used and clarifies the relation between classical local-size reductions and stronger structural tests.

## 1. Introduction

Let $G=(V,E)$ be a simple undirected graph. A clique is a vertex set whose distinct members are pairwise adjacent. The Maximum Clique Problem asks for the largest such set. This elementary definition conceals a difficult global optimization problem: local adjacency decisions overlap, and a graph may contain an enormous family of candidate cliques.

Exact algorithms commonly reduce the input before or during search. If the algorithm already knows a clique of size $k-1$, for example, only cliques of size at least $k$ can improve the incumbent. Any vertex certified not to belong to such a clique can be deleted. Classical core reduction uses degree: a vertex in a $k$-clique must have at least $k-1$ neighbors. A truss-style argument uses edge support: the endpoints of an edge in a $k$-clique must have at least $k-2$ common neighbors.

These cardinality conditions ignore adjacency among the available neighbors. A vertex can have high degree while its neighborhood has small clique number. Likewise, an edge can have many common neighbors that are too fragmented to supply the remainder of a large clique. This motivates replacing raw neighborhood size with any valid upper bound on clique size in the neighborhood.

Our treatment is extensional. We do not require a specific construction of the bound, only its defining correctness property. This accommodates bounds obtained from proper colorings, degeneracy, relaxations, exact subroutines, or combinations thereof. It also permits a clean separation between the mathematical soundness of reduction and the engineering choices that determine speed and strength.

The principal contributions are:

1. a pointwise minimum theorem for combining valid clique upper bounds;
2. a general clique extension inequality for an arbitrary contained pattern;
3. a failed-test theorem excluding that pattern from every target-size clique;
4. upper-bound-enhanced core and truss criteria as singleton and pair specializations;
5. preservation of every target-size clique under one certified core deletion;
6. preservation under any finite sequence of certified core-peeling steps.

The scope should be stated precisely. The results establish the mathematical certificates behind vertex and edge tests and fully prove finite vertex-peeling correctness. An iterative edge-deletion theorem, radius-based generalized trusses, termination bounds, and implementation-specific running times are natural extensions rather than claims of the present paper.

## 2. Graph-theoretic setting

### 2.1 Simple graphs and cliques

A **simple undirected graph** is a pair $G=(V,E)$ in which $V$ is a set and $E$ is a symmetric, irreflexive adjacency relation. We write $x\sim y$ when $x$ and $y$ are adjacent.

A set $C\subseteq V$ is a **clique** if, for all distinct $x,y\in C$, one has $x\sim y$. We consider finite cliques whenever cardinality is used. The ambient graph itself need not be finite for the structural theorems, although algorithms naturally operate on finite instances.

For a search region $S\subseteq V$, a clique “inside $S$” means a clique $C$ satisfying $C\subseteq S$. Restricting attention to $S$ models a residual subproblem after previous reductions or branching decisions.

### 2.2 Common neighborhoods

For an arbitrary pattern $D\subseteq V$, define its **common neighborhood** by

$$
N(D)=\{x\in V:\forall w\in D,\ x\sim w\}.
$$

If $D=\{v\}$, then $N(D)$ is the ordinary open neighborhood of $v$. If $D=\{u,v\}$, it is the set of vertices adjacent to both endpoints. Because the graph has no loops, a member of $D$ cannot belong to $N(D)$ when $D$ is nonempty.

The common neighborhood is the unique natural extension region for a clique containing $D$: every additional clique vertex must be adjacent to every vertex already in $D$.

### 2.3 Clique upper-bound functions

A function $U:2^V\to\mathbb{N}$ is a **clique upper-bound function** if, for every $S\subseteq V$ and every finite clique $C\subseteq S$,

$$
|C|\le U(S).
$$

No monotonicity assumption is required. In applications, many natural bounds are monotone, but all arguments below use only validity on the set at which the function is evaluated.

Several examples motivate the definition.

- **Cardinality bound:** $U(S)=|S|$ for finite $S$.
- **Coloring bound:** if a proper coloring of the subgraph induced by $S$ uses $q$ colors, then $U(S)=q$, because a clique contains at most one vertex of each color.
- **Degeneracy bound:** if the induced subgraph on $S$ has degeneracy $d$, then its clique number is at most $d+1$.
- **Exact local value:** when affordable, the clique number of the induced subgraph on $S$ is the sharpest possible value.

The framework remains correct if different procedures are used on different sets, provided the returned value always satisfies the upper-bound condition.

## 3. Combining upper bounds

### Theorem 3.1 (Minimum Combination Theorem)

Let $U_1$ and $U_2$ be clique upper-bound functions. Define

$$
U(S)=\min\{U_1(S),U_2(S)\}.
$$

Then $U$ is also a clique upper-bound function.

**Proof sketch.** Let $C\subseteq S$ be a finite clique. Validity of $U_1$ gives $|C|\le U_1(S)$, and validity of $U_2$ gives $|C|\le U_2(S)$. Therefore $|C|$ is at most their minimum. $\square$

By induction, the same conclusion holds for the minimum of any finite nonempty family of valid upper bounds. This gives a modular design rule: bounds may be developed independently and combined without a new soundness argument. Computationally, one may also short-circuit evaluation. If a cheap bound is already small enough to trigger a reduction, a more expensive bound need not be computed.

## 4. The pattern-extension principle

The main theorem applies to any subset $D$ of a clique, not only a vertex or an edge.

### Theorem 4.1 (Clique Extension Bound)

Let $U$ be a clique upper-bound function. Let $S,C,D\subseteq V$ satisfy the following conditions:

1. $C$ is finite;
2. $C$ is a clique;
3. $D\subseteq C$;
4. $C\subseteq S$.

Then

$$
|C|\le |D|+U(S\cap N(D)).
$$

**Proof sketch.** Set $R=C\setminus D$. Since $R\subseteq C$, it is a finite clique. For any $x\in R$, the inclusion $C\subseteq S$ gives $x\in S$. For every $w\in D$, both $x$ and $w$ lie in $C$, and they are distinct because $x\notin D$; hence $x\sim w$. Thus $x\in N(D)$, proving $R\subseteq S\cap N(D)$. The upper-bound property gives

$$
|R|\le U(S\cap N(D)).
$$

Because $D\subseteq C$, the sets $D$ and $C\setminus D$ are disjoint and their union is $C$. Therefore $|C|=|D|+|R|$, which yields the result. $\square$

The theorem decomposes a candidate clique into a fixed pattern and a completion. Its force comes from evaluating the bound not on the whole search region but on the much smaller region in which a completion is logically forced to lie.

### Corollary 4.2 (Failed Extension Test)

Let $k\in\mathbb{N}$ and let $D,S\subseteq V$. If

$$
|D|+U(S\cap N(D))<k,
$$

then no finite clique $C\subseteq S$ with $|C|\ge k$ contains $D$.

**Proof sketch.** If such a clique contained $D$, Theorem 4.1 would imply

$$
k\le |C|\le |D|+U(S\cap N(D))<k,
$$

an impossibility. $\square$

This corollary is one-sided, as every safe pruning test must be. Failure certifies exclusion. Passing does not certify that an extension exists, because an upper bound can overestimate the true clique number.

### Remark 4.3 (Patterns need not initially be cliques)

The statement does not assume separately that $D$ is a clique. If $D\subseteq C$ and $C$ is a clique, that fact follows automatically. If $D$ is not a clique, then no clique contains it and the exclusion conclusion is already true. In algorithms, one normally applies the test to patterns known to be cliques, such as vertices and edges.

## 5. Core and truss specializations

### 5.1 Singleton patterns and enhanced cores

### Theorem 5.1 (Vertex Core Test)

Let $C\subseteq S$ be a finite clique, let $v\in C$, and suppose $|C|\ge k$. Then

$$
k\le 1+U(S\cap N(\{v\})).
$$

**Proof sketch.** Apply Theorem 4.1 with $D=\{v\}$. Since $|D|=1$, one obtains

$$
|C|\le 1+U(S\cap N(\{v\})).
$$

Combine this with $k\le |C|$. $\square$

Consequently, a vertex satisfying

$$
1+U(S\cap N(\{v\}))<k
$$

cannot occur in any clique of size at least $k$ contained in $S$. We call this the **upper-bound-enhanced core deletion criterion**.

If $U(X)=|X|$, the criterion reduces to the classical degree test

$$
1+\deg_S(v)<k.
$$

A structural bound can be strictly stronger. For example, if $v$ has ten neighbors but the induced neighborhood is properly colorable with three colors, then no clique containing $v$ has more than four vertices, regardless of the raw degree.

### 5.2 Pair patterns and enhanced trusses

### Theorem 5.2 (Edge Truss Test)

Let $C\subseteq S$ be a finite clique. Let $u,v\in C$ with $u\ne v$, and suppose $|C|\ge k$. Then

$$
k\le 2+U(S\cap N(\{u,v\})).
$$

**Proof sketch.** Apply Theorem 4.1 with $D=\{u,v\}$. Distinctness gives $|D|=2$, yielding the stated inequality. $\square$

Thus, if

$$
2+U(S\cap N(\{u,v\}))<k,
$$

then no target-size clique can contain both $u$ and $v$. When $uv\in E$, this is an upper-bound-enhanced truss certificate for removing the edge from consideration.

The cardinality bound gives the usual support condition: an edge in a $k$-clique must have at least $k-2$ common neighbors. A tighter bound studies the internal compatibility of those common neighbors. For instance, six common neighbors that induce a bipartite graph can contribute at most two vertices to a clique, so the edge belongs to no clique larger than four.

### 5.3 A unified hierarchy

Theorems 5.1 and 5.2 are not separate phenomena. For any finite pattern $D$, define its extension score in $S$ by

$$
B_S(D)=|D|+U(S\cap N(D)).
$$

Whenever $B_S(D)<k$, the pattern can be excluded from every clique of size at least $k$. Increasing $|D|$ can tighten the completion region but raises the number and cost of tests. Singleton tests are cheap and broadly applicable; pair tests are more numerous but can expose structure invisible at the vertex level; larger patterns continue the trade-off.

## 6. Certified core peeling

A single safe deletion is useful, but practical reductions repeatedly update the current graph. We now formalize this process mathematically.

### Definition 6.1 (Certified core-peeling step)

Fix a target $k$ and upper-bound function $U$. A set $T$ is obtained from $S$ by one **certified core-peeling step** if there exists $v\in S$ such that

$$
1+U(S\cap N(\{v\}))<k
$$

and

$$
T=S\setminus\{v\}.
$$

The bound is evaluated in the current set $S$, not necessarily in the original graph. This permits new failures to appear after earlier deletions.

### Theorem 6.2 (One-Step Clique Preservation)

Let $T$ be obtained from $S$ by a certified core-peeling step. If $C\subseteq S$ is a finite clique and $|C|\ge k$, then $C\subseteq T$.

**Proof sketch.** Let $v$ be the deleted vertex. If $v\in C$, Theorem 5.1 gives

$$
k\le 1+U(S\cap N(\{v\})),
$$

contradicting the strict inequality certifying deletion. Therefore $v\notin C$. Since $C\subseteq S$, every vertex of $C$ remains in $S\setminus\{v\}=T$. $\square$

The theorem preserves every qualifying clique, not merely the maximum clique number or one chosen optimum. This distinction supports enumeration and counting applications as well as optimization.

### Theorem 6.3 (Finite Core-Peeling Preservation)

Let

$$
S_0,S_1,\ldots,S_t
$$

be a finite sequence in which each $S_{i+1}$ is obtained from $S_i$ by a certified core-peeling step. If $C\subseteq S_0$ is a finite clique and $|C|\ge k$, then

$$
C\subseteq S_i
$$

for every $0\le i\le t$. In particular, $C\subseteq S_t$.

**Proof sketch.** Use induction on $i$. The base case is the assumption $C\subseteq S_0$. If $C\subseteq S_i$, Theorem 6.2 applied to the step from $S_i$ to $S_{i+1}$ gives $C\subseteq S_{i+1}$. $\square$

### Corollary 6.4 (Decision equivalence above the target)

Under the hypotheses of Theorem 6.3, the original region $S_0$ contains a clique of size at least $k$ if and only if the residual region $S_t$ does.

**Proof sketch.** Every clique in $S_t$ is also in $S_0$ because $S_t\subseteq S_0$. Conversely, every qualifying clique in $S_0$ is preserved by Theorem 6.3. $\square$

### Corollary 6.5 (Preservation of the optimum when relevant)

If the maximum clique size in $S_0$ is at least $k$, then the maximum clique sizes in $S_0$ and $S_t$ are equal.

**Proof sketch.** A maximum clique in $S_0$ has size at least $k$ and survives in $S_t$, so the residual optimum is at least the original optimum. Since $S_t\subseteq S_0$, it cannot be larger. $\square$

## 7. Algorithms

### 7.1 Upper-bound-enhanced core peeling

For a finite graph and a target $k$, the direct algorithm maintains an active set $S$. It repeatedly scans active vertices, computes $U(S\cap N(v))$, and removes a vertex whenever $1+U(S\cap N(v))<k$. It stops when a complete scan makes no deletion.

A simple implementation is:

1. initialize $S\leftarrow V$;
2. find a vertex $v\in S$ with $1+U(S\cap N(v))<k$;
3. if none exists, return $S$;
4. otherwise replace $S$ by $S\setminus\{v\}$ and repeat.

On a graph with $n$ vertices, at most $n$ deletions occur. If a naive scan evaluates every active vertex after each deletion and one bound evaluation costs at most $T_U(n,m)$, a coarse bound is

$$
O(n^2T_U(n,m)+n^2)
$$

apart from graph-representation costs. This is not asserted as an optimal running time. Queues, dependency tracking, bitsets, incremental colorings, and batched deletion can substantially improve practice. The preservation theorem is independent of these implementation choices as long as every deletion carries the stated certificate in the current set.

### 7.2 Pattern exclusion

For a family $\mathcal{D}$ of patterns, compute

$$
B_S(D)=|D|+U(S\cap N(D))
$$

for each $D\in\mathcal{D}$. Mark every pattern with $B_S(D)<k$ as forbidden in a target-size clique. For singleton patterns this means vertex deletion. For edge patterns it means edge exclusion or branching restrictions. The cost is roughly the number of tested patterns multiplied by common-neighborhood construction and bound-evaluation costs.

### 7.3 Combining bounds adaptively

Suppose $U_1$ is cheap and $U_2$ is stronger but expensive. Since their minimum is valid, an adaptive test may proceed as follows:

1. compute $b_1=U_1(X)$;
2. if $|D|+b_1<k$, reject $D$ immediately;
3. otherwise compute $b_2=U_2(X)$;
4. reject if $|D|+\min\{b_1,b_2\}<k$.

This ordering preserves correctness while avoiding expensive work whenever the cheap bound suffices. More than two bounds can be organized as a cascade.

## 8. Numerical examples

### Example 8.1 (Coloring strengthens degree reduction)

Let $k=5$ and let $v$ have eight active neighbors. The cardinality bound gives

$$
1+8=9,
$$

so degree reduction cannot remove $v$. Suppose, however, that the induced neighborhood admits a proper coloring with three colors. The coloring bound gives $U(S\cap N(v))\le 3$, and therefore

$$
1+U(S\cap N(v))\le 4<5.
$$

The vertex is safely deleted.

### Example 8.2 (Structure strengthens edge support)

Let $k=5$ and suppose adjacent vertices $u$ and $v$ have six common active neighbors. Raw support gives $2+6=8$, so a cardinality test passes. If the common-neighbor graph is bipartite, its clique number is at most $2$. Hence

$$
2+U(S\cap N(\{u,v\}))\le 4<5,
$$

and the edge cannot belong to a $5$-clique.

### Example 8.3 (Iterative effects)

Suppose a first vertex fails because its neighborhood bound is below $k-1$. Removing it shrinks the neighborhoods of other vertices. A second vertex that previously had score $k$ may then have score $k-1$ and become deletable. Theorem 6.3 ensures that this cascade cannot touch a clique of size at least $k$: every member of such a clique passes the test at every stage in which the clique remains active, and the induction guarantees that it always remains active.

## 9. Applications

### 9.1 Exact maximum-clique search

In branch-and-bound, an incumbent clique of size $L$ establishes a lower bound. To improve it, the search needs a clique of size at least $k=L+1$. Certified peeling can reduce each residual subproblem before branching. If the active set becomes smaller than $k$, the branch is immediately impossible. If no deletion is possible, the residual graph still contains every potential improvement.

### 9.2 Clique decision and enumeration

For the decision problem “does a $k$-clique exist?”, Corollary 6.4 gives exact equivalence between the original and peeled regions. For enumeration of all cliques of size at least $k$, Theorem 6.3 guarantees that no qualifying clique loses a vertex. Additional bookkeeping may be needed if edge exclusions are used, but the underlying certificates remain the same.

### 9.3 Network analysis

Large cliques model mutually compatible or mutually connected groups. In collaboration, communication, biological, and market-basket networks, raw degree can be misleading. Upper-bound-enhanced tests distinguish a large but diffuse neighborhood from one capable of supporting a cohesive group. The method can therefore reduce candidate regions before exact analysis without changing any group meeting the chosen size threshold.

### 9.4 Constraint and compatibility systems

Many selection problems produce a graph whose edges encode pairwise compatibility. A feasible all-pairs-compatible selection is a clique. The extension bound says that once a partial selection $D$ is fixed, only objects compatible with every member of $D$ matter, and an upper bound on that residual compatibility graph limits the complete selection. This interpretation makes the pattern theorem useful beyond algorithms explicitly described as graph reductions.

## 10. Discussion

The framework’s main advantage is modularity. Correctness depends on one contract for $U$, while performance depends on how that contract is fulfilled. This allows a solver to mix bounds of different cost and origin. The minimum theorem ensures that adding a new valid bound can never weaken the pointwise estimate.

The extension theorem also clarifies what classical reductions approximate. Degree reduction uses the number of available completion vertices. Truss support uses the number of common completion vertices for an edge. Both replace the clique number of a completion region by its cardinality. The enhanced framework simply permits a better estimate of that clique number.

Strict inequality is essential. A pattern is excluded only when its maximum permitted size is **less than** $k$. Equality leaves open the possibility of a clique of size exactly $k$. Similarly, all tests must be evaluated against the current search region used in the certificate. Using a bound from a larger region remains safe when the bound itself is valid there, but may be weaker; using an unjustifiably smaller region could be unsound.

The preservation theorem makes no termination claim for arbitrary infinite graphs. For finite graphs, a procedure that deletes one vertex per successful step terminates after at most $|V|$ deletions. Establishing precise implementation-level complexity requires fixing graph representations, the upper-bound algorithm, update policies, and data structures.

The edge theorem proves the local certificate needed for truss reduction, but a complete iterative edge-peeling development requires an explicit evolving edge relation and a proof that every deletion preserves target cliques under that evolution. Radius-$d$ neighborhoods and transformations such as structions likewise require additional definitions and preservation arguments.

## 11. Future work

Several directions extend the present foundation.

- Define iterative edge-deletion peeling and prove preservation for upper-bound-enhanced trusses.
- Introduce radius-$d$ edge neighborhoods and establish generalized truss theorems that expose a strength-versus-cost parameter.
- Connect the abstract upper-bound contract to concrete greedy-coloring and degeneracy algorithms, including explicit complexity bounds.
- Prove termination and implementation-level running times for finite peeling procedures.
- Study combined core/truss fixed points and quantify improvements obtained by taking minima of their resulting bounds.
- Develop semantics-preserving graph transformations, including repeated structions, and prove their safe interaction with core and truss reductions.

A further algorithmic question is scheduling: given several valid bounds with different costs and expected strengths, in what order should they be evaluated? The minimum theorem guarantees correctness for every order, leaving room for data-driven policies that optimize expected running time without altering mathematical guarantees.

## 12. Conclusion

A clique containing a pattern $D$ can be completed only inside the common neighborhood $N(D)$. Bounding the clique size of that completion region yields the universal inequality

$$
|C|\le |D|+U(S\cap N(D)).
$$

This inequality supports a decisive failed-extension test, upper-bound-enhanced core and truss criteria, and a proof that repeated certified vertex peeling preserves every clique at or above the target size. The pointwise minimum theorem makes independent bounding methods composable.

The results provide a compact correctness foundation for stronger maximum-clique reductions. They replace local counts by structural upper bounds while retaining the familiar logic of cores and trusses. In algorithm design, this means that inexpensive impossibility certificates can safely remove large portions of a search space before expensive global exploration begins.
