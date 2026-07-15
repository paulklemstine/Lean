# Extremal Rigidity and Strict Growth of Finite Vietoris–Rips Clique Counts

## Abstract

For a simple graph on a finite vertex set of cardinality $n$, the clique complex is a subfamily of the power set and hence contains at most $2^n$ simplices. We establish the sharp equality characterization: the bound is attained if and only if the graph is complete. We also prove strict monotonicity under proper edge inclusion: adding at least one edge strictly increases the total number of cliques. These facts transfer directly to finite Vietoris–Rips complexes. For a symmetric dissimilarity $D$ whose diagonal lies below a scale $r$, the Vietoris–Rips complex equals the clique complex of the threshold proximity graph. Consequently, it has $2^n$ simplices exactly when every pair has dissimilarity at most $r$. Moreover, if $r\leq s$ and a distinct pair satisfies $r<D(i,j)\leq s$, then the simplex count at $s$ is strictly larger than at $r$. We present proofs, event-driven counting algorithms, examples, complexity analysis, applications, and quantitative directions suggested by the rigidity principle.

## 1. Introduction

Vietoris–Rips complexes convert pairwise proximity data into combinatorial topology. Given finitely many objects and a scale parameter, one includes a simplex whenever all pairs of its vertices are sufficiently close. As the scale increases, the complexes form a filtration. This construction is ubiquitous in topological data analysis because it requires only pairwise dissimilarities and because its clique-complex description permits graph-based computation.

The number of simplices is among the most elementary statistics of such a complex. It is also computationally consequential: a complex on $n$ vertices may contain exponentially many simplices, affecting storage and downstream homological computations. The trivial universal bound is $2^n$, the number of all subsets of the vertex set. The purpose of this paper is to show that this trivial-looking inequality has a rigid equality case and a strict dynamical form.

At the graph level, every clique of a graph $G$ remains a clique after edges are added. If the edge inclusion is proper, a newly added edge is itself a new two-vertex clique. Thus total clique count is strictly increasing along proper edge inclusion. At the extremum, all $2^n$ subsets are cliques if and only if all two-element subsets are edges, which is equivalent to completeness.

At the geometric level, a symmetric dissimilarity at scale $r$ defines a graph whose edges are the pairs at dissimilarity at most $r$. Under the natural diagonal condition, its clique complex is exactly the Vietoris–Rips complex. The graph statements therefore imply two geometric conclusions. First, maximal simplex count characterizes the scale at which every pair is close. Second, every edge birth in the threshold graph forces a strict increase in total simplex count.

These statements connect metric geometry, extremal and enumerative combinatorics, and filtration-based approximation. They require neither the triangle inequality nor positivity: symmetry and control of diagonal values suffice. This generality covers finite metric spaces, pseudometrics, weighted undirected networks, and symmetric data-derived dissimilarities.

## 2. Graphs, cliques, and finite complexes

Let $V$ be a finite set with $|V|=n$. A **simple graph** $G=(V,E)$ consists of a set $E$ of unordered two-element subsets of $V$. Equivalently, it has a symmetric, irreflexive adjacency relation. The **complete graph** on $V$, denoted $K_V$, contains every two-element subset of $V$ as an edge.

### Definition 2.1 (Clique)

A subset $S\subseteq V$ is a clique of $G$ if every pair of distinct elements of $S$ is adjacent in $G$. By this definition, the empty set and every singleton are cliques.

### Definition 2.2 (Clique complex)

The clique complex of $G$ is the finite family

$$
\mathrm{Cl}(G)=\{S\subseteq V:S\text{ is a clique of }G\}.
$$

It is an abstract simplicial complex: whenever $S$ is a clique and $T\subseteq S$, every distinct pair in $T$ is also a distinct pair in $S$, so $T$ is a clique.

The following elementary lemma provides the first half of the extremal result.

### Lemma 2.3 (Power-set bound)

For every simple graph $G$ on an $n$-element vertex set,

$$
|\mathrm{Cl}(G)|\leq 2^n.
$$

#### Proof sketch

Every clique is a subset of $V$, so $\mathrm{Cl}(G)\subseteq\mathcal P(V)$. Since the power set has cardinality $2^n$, the inequality follows.

### Lemma 2.4 (Complete-graph complex)

For the complete graph $K_V$,

$$
\mathrm{Cl}(K_V)=\mathcal P(V),
$$

and hence $|\mathrm{Cl}(K_V)|=2^n$.

#### Proof sketch

Every pair of distinct vertices in $K_V$ is adjacent. Therefore every subset of $V$ satisfies the clique condition.

## 3. Extremal rigidity

The upper bound becomes structurally informative when its equality case is identified.

### Theorem 3.1 (Extremal rigidity of clique count)

Let $G$ be a simple graph on a finite vertex set $V$ with $|V|=n$. Then

$$
|\mathrm{Cl}(G)|=2^n
$$

if and only if $G=K_V$.

#### Proof sketch

If $G=K_V$, Lemma 2.4 gives equality. Conversely, assume $|\mathrm{Cl}(G)|=2^n$. By Lemma 2.3, $\mathrm{Cl}(G)$ is a subfamily of $\mathcal P(V)$ with the same finite cardinality as $\mathcal P(V)$, so the two families are equal. For any distinct $u,v\in V$, the set $\{u,v\}$ therefore belongs to $\mathrm{Cl}(G)$. The clique condition for this two-element set says precisely that $u$ and $v$ are adjacent. Every distinct pair is an edge, and hence $G=K_V$.

### Corollary 3.2 (Strict extremal deficit)

If $G\neq K_V$, then

$$
|\mathrm{Cl}(G)|<2^n.
$$

#### Proof sketch

The power-set bound gives a weak inequality. Equality would imply $G=K_V$ by Theorem 3.1, contradicting the hypothesis.

The proof reveals why two-element simplices are decisive. Equality of the global count forces equality with the whole power set; equality with the power set includes every pair; and the set of pairs determines a simple graph completely.

## 4. Monotonicity under edge insertion

For graphs $G$ and $H$ on the same vertex set, write $G\subseteq H$ when every edge of $G$ is an edge of $H$, and write $G\subsetneq H$ when the inclusion is proper.

### Lemma 4.1 (Clique-family monotonicity)

If $G\subseteq H$, then

$$
\mathrm{Cl}(G)\subseteq\mathrm{Cl}(H).
$$

#### Proof sketch

Let $S$ be a clique of $G$. Every distinct pair in $S$ is an edge of $G$, hence an edge of $H$. Therefore $S$ is a clique of $H$.

### Theorem 4.2 (Strict clique-count monotonicity)

If $G\subsetneq H$, then

$$
|\mathrm{Cl}(G)|<|\mathrm{Cl}(H)|.
$$

#### Proof sketch

Lemma 4.1 gives inclusion of clique families. Proper edge inclusion supplies distinct vertices $u,v$ such that $\{u,v\}$ is an edge of $H$ but not of $G$. The set $\{u,v\}$ is consequently a clique of $H$ and not a clique of $G$. Thus the inclusion of clique families is proper. Strict inequality of finite cardinalities follows.

This theorem is stronger than weak monotonicity and requires no analysis of higher-dimensional faces. A new edge may complete many larger cliques, but the edge itself guarantees a positive increase.

### Remark 4.3 (Size of a single-edge jump)

Suppose $H$ is obtained from $G$ by adding one missing edge $uv$. A new clique must contain both $u$ and $v$; deleting these two vertices leaves a clique contained in the common neighborhood $N_G(u)\cap N_G(v)$. Conversely, every clique in the induced graph on this common neighborhood extends with $u$ and $v$ to a new clique of $H$. Hence the exact jump is

$$
|\mathrm{Cl}(H)|-|\mathrm{Cl}(G)|
=
|\mathrm{Cl}(G[N_G(u)\cap N_G(v)])|.
$$

The strict-growth theorem uses only the fact that the right-hand side is at least $1$, contributed by the empty clique. This identity also motivates dimension-refined and quantitative extensions.

## 5. Symmetric dissimilarities and Vietoris–Rips complexes

Let $D:V\times V\to\mathbb R$ be a function. We call $D$ a **symmetric dissimilarity** when

$$
D(x,y)=D(y,x)
$$

for all $x,y\in V$. No triangle inequality or nonnegativity is needed for the results below.

### Definition 5.1 (Threshold proximity graph)

For a scale $r\in\mathbb R$, the proximity graph $G_r(D)$ has vertex set $V$, and distinct vertices $x,y$ are adjacent exactly when

$$
D(x,y)\leq r.
$$

Symmetry of $D$ makes adjacency symmetric; requiring distinct endpoints makes the graph loopless.

### Definition 5.2 (Finite Vietoris–Rips complex)

The Vietoris–Rips complex at scale $r$ is

$$
\mathrm{VR}(D,r)
=
\{S\subseteq V:\text{ for all }x,y\in S,\ D(x,y)\leq r\}.
$$

This formulation includes pairs with $x=y$. We therefore assume the **diagonal condition**

$$
D(x,x)\leq r\qquad\text{for every }x\in V.
$$

For a metric or pseudometric and a nonnegative scale, this condition is automatic.

### Theorem 5.3 (Clique representation of the Vietoris–Rips complex)

If $D$ is symmetric and $D(x,x)\leq r$ for every $x\in V$, then

$$
\mathrm{VR}(D,r)=\mathrm{Cl}(G_r(D)).
$$

#### Proof sketch

Suppose $S\in\mathrm{VR}(D,r)$. For distinct $x,y\in S$, the defining condition gives $D(x,y)\leq r$, so $xy$ is an edge of $G_r(D)$. Hence $S$ is a clique. Conversely, suppose $S$ is a clique of $G_r(D)$. If $x,y\in S$ are distinct, adjacency gives $D(x,y)\leq r$. If $x=y$, the diagonal condition gives the same inequality. Thus every ordered pair in $S$ satisfies the threshold and $S\in\mathrm{VR}(D,r)$.

The result isolates exactly why the assumptions are present. Symmetry ensures an undirected proximity graph, while the diagonal condition reconciles a clique predicate on distinct pairs with the Vietoris–Rips predicate on all pairs.

## 6. Maximal size as a geometric certificate

Combining the clique representation with extremal rigidity gives the principal geometric equality characterization.

### Theorem 6.1 (Maximal Vietoris–Rips characterization)

Let $V$ have cardinality $n$. Let $D$ be symmetric, and assume $D(x,x)\leq r$ for all $x\in V$. Then

$$
|\mathrm{VR}(D,r)|=2^n
$$

if and only if

$$
D(x,y)\leq r
$$

for every $x,y\in V$.

#### Proof sketch

By Theorem 5.3, $\mathrm{VR}(D,r)$ is the clique complex of $G_r(D)$. By Theorem 3.1, it has $2^n$ simplices exactly when $G_r(D)$ is complete. Completeness says that $D(x,y)\leq r$ for every distinct pair. The diagonal condition supplies the remaining equal pairs. Conversely, if every pair lies within scale, then the graph is complete and every subset is a Vietoris–Rips simplex.

### Corollary 6.2 (Diameter threshold for finite metric spaces)

Let $(V,d)$ be a nonempty finite metric space with $|V|=n$, and define

$$
\operatorname{diam}(V)=\max_{x,y\in V}d(x,y).
$$

For every $r\geq 0$,

$$
|\mathrm{VR}(d,r)|=2^n
$$

if and only if $r\geq\operatorname{diam}(V)$.

#### Proof sketch

Theorem 6.1 reduces maximality to $d(x,y)\leq r$ for every pair. In a finite space, this is equivalent to the maximum pairwise distance being at most $r$.

Thus the terminal saturation scale of the total simplex count is exactly the diameter. This is stronger than graph connectivity, which can occur at a much smaller scale.

## 7. Strict growth at edge births

The threshold graphs are monotone in the scale: if $r\leq s$, then every edge of $G_r(D)$ is an edge of $G_s(D)$.

### Theorem 7.1 (Strict simplex growth at an edge birth)

Let $D$ be symmetric, let $r\leq s$, and assume $D(x,x)\leq r$ for all $x\in V$. If there exist distinct $i,j\in V$ such that

$$
r<D(i,j)\leq s,
$$

then

$$
|\mathrm{VR}(D,r)|<|\mathrm{VR}(D,s)|.
$$

#### Proof sketch

Since $r\leq s$, one has $G_r(D)\subseteq G_s(D)$. The pair $i,j$ is not adjacent in $G_r(D)$ because $D(i,j)>r$, but it is adjacent in $G_s(D)$ because $D(i,j)\leq s$. Hence the graph inclusion is proper. Theorem 4.2 gives strict growth of clique counts. The diagonal condition at $r$ also holds at $s$, so Theorem 5.3 identifies both clique complexes with the corresponding Vietoris–Rips complexes.

### Corollary 7.2 (Jumps occur at attained distances)

For a finite symmetric dissimilarity with controlled diagonal, the function

$$
N(r)=|\mathrm{VR}(D,r)|
$$

is nondecreasing and piecewise constant. If an interval $(r,s]$ contains an attained dissimilarity $D(i,j)$ of a distinct pair, then $N(r)<N(s)$. If it contains no such value, then $N(r)=N(s)$.

#### Proof sketch

Monotonicity follows from threshold inclusion. The strict statement is Theorem 7.1. If no off-diagonal value lies in $(r,s]$, every distinct pair passes the threshold at $r$ exactly when it passes at $s$, so the proximity graphs and their clique complexes coincide.

This identifies the critical event set of the filtration with the distinct off-diagonal dissimilarity values. Multiple edges can share a critical value and are then inserted simultaneously.

## 8. Examples

### Example 8.1 (Three points)

Let three points have distances $1$, $2$, and $3$. For $0\leq r<1$, the complex contains the empty simplex and three vertices, so $N(r)=4$. At $r=1$, one edge appears and $N(r)=5$. At $r=2$, a second edge appears and $N(r)=6$. At $r=3$, the final edge appears, completing both the three-cycle and the filled triangle. The new edge and the three-vertex simplex raise the count to $8=2^3$.

### Example 8.2 (Unit square)

For the four corners of a unit square, the six pairwise distances consist of four values equal to $1$ and two equal to $\sqrt 2$. Below $1$, only the empty set and vertices occur, giving $5$. At $1$, four side edges appear, giving $9$. No triangle appears because each triple contains a diagonal. At $\sqrt2$, both diagonals appear and the graph becomes complete. Every subset is now a simplex, so the count is $16$. The final jump has size $7$: two diagonals, four triangles, and one tetrahedral simplex.

### Example 8.3 (A missing edge near the maximum)

Let $G$ be obtained from $K_V$ by deleting one edge $uv$, where $|V|=n$. A subset fails to be a clique exactly when it contains both $u$ and $v$. The remaining $n-2$ vertices may be chosen arbitrarily, so exactly $2^{n-2}$ subsets are absent. Therefore

$$
|\mathrm{Cl}(G)|=2^n-2^{n-2}=3\cdot 2^{n-2}.
$$

Adding the missing edge creates precisely $2^{n-2}$ cliques. This illustrates that strict growth can be exponentially larger than the single witnessing edge.

## 9. Algorithms

### Algorithm 9.1 (Exhaustive Vietoris–Rips simplex count)

Given a symmetric $n\times n$ dissimilarity matrix and scale $r$:

1. Verify or assume that every diagonal entry is at most $r$.
2. Build a Boolean adjacency matrix with an edge between distinct $i,j$ when $D(i,j)\leq r$.
3. Enumerate all bit masks from $0$ to $2^n-1$.
4. For each mask, test every selected unordered pair for adjacency.
5. Count the masks passing the test.

The graph construction takes $O(n^2)$ time. The direct enumeration takes $O(n^2 2^n)$ time in the worst case and $O(n^2)$ auxiliary space for the matrix. Early termination on a missing edge improves practical behavior for sparse graphs.

Correctness follows from Theorem 5.3: accepted masks are exactly the Vietoris–Rips simplices.

### Algorithm 9.2 (Extremal saturation test)

To decide whether the simplex count equals $2^n$, exhaustive enumeration is unnecessary:

1. Check $D(i,i)\leq r$ for every $i$.
2. Check $D(i,j)\leq r$ for every unordered pair $i<j$.
3. Return true exactly when all checks pass.

This takes $O(n^2)$ time and $O(1)$ extra space beyond the input. Correctness is exactly Theorem 6.1.

### Algorithm 9.3 (Event-driven filtration profile)

To compute the full count profile:

1. Collect and sort all distinct off-diagonal dissimilarities.
2. Begin below the smallest value with the edgeless graph, whose clique count is $n+1$.
3. At each critical value, insert every edge having that value.
4. Recompute or incrementally update the clique count.
5. Record the scale, new count, and jump size.

Sorting costs $O(n^2\log n)$ comparisons. A simple recomputation at each of at most $\binom n2$ critical values costs $O(n^4 2^n)$ in a conservative implementation, while incremental clique-maintenance methods can be substantially faster on structured data. Corollary 7.2 guarantees that every nonempty insertion batch produces a positive jump and that no changes occur between critical values.

## 10. Applications and interpretation

### 10.1 Terminal-scale detection

In a finite metric space, saturation at $2^n$ occurs exactly at the diameter. A system tracking simplex count can therefore detect the final pairwise threshold through a scalar statistic. This can serve as a consistency check for filtration software or as a stopping criterion when the fully saturated complex no longer contains useful geometric discrimination.

### 10.2 Network and communication models

When vertices represent agents and an edge means mutual communication within range, clique simplices represent groups with all-to-all links. Extremal rigidity says that the presence of every possible group is equivalent to universal pairwise communication. Strict growth says that increasing communication range cannot add a genuine link without changing the family of mutually communicating groups.

### 10.3 Complexity forecasting

The count $2^n$ is an exact worst-case size, not merely an asymptotic warning. Near and beyond the diameter threshold, explicit simplex enumeration is infeasible for moderate $n$. The equality characterization allows algorithms to recognize this regime using only quadratic pair checks. It also motivates truncating by dimension: if only simplices of dimension at most $k$ are retained, the complete-complex count becomes $\sum_{j=0}^{k+1}\binom nj$ rather than $2^n$.

### 10.4 Approximation and interleavings

Approximate Rips filtrations are often compared with exact filtrations through scale shifts or multiplicative interleavings. The present results provide rigid landmarks for such comparisons. Exact saturation identifies universal pairwise proximity, while near-saturation raises a quantitative question: how many missing edges are compatible with a given simplex deficit? Answers would convert approximation guarantees on counts into structural information about threshold graphs.

## 11. Discussion

The arguments are intentionally elementary, but their combination is effective. The power-set bound alone says little. Its equality case says that total combinatorial saturation is equivalent to graph completeness. Strict monotonicity strengthens a static extremal statement into a filtration statement: every proper edge inclusion is visible to total clique count.

The assumptions are minimal for the chosen formulation. Finiteness is needed for cardinality comparisons and the numerical value $2^n$. Symmetry is needed to represent threshold relations by undirected simple graphs. The diagonal bound is needed because the Vietoris–Rips definition checks all ordered pairs, whereas graph cliques check only distinct vertices. The triangle inequality is irrelevant.

Total simplex count remains a coarse invariant. Different nonisomorphic graphs may have equal clique counts, and the count generally cannot identify which edges were added. The strict-growth theorem asserts event detection, not event reconstruction. Dimension-refined vectors or exact jump decompositions carry more information.

A useful quantitative perspective comes from missing edges. Each missing edge excludes all subsets containing its endpoints, but exclusions overlap when subsets contain endpoints of several missing edges. Determining the exact deficit is therefore an inclusion–exclusion problem governed by the missing-edge graph. The single-missing-edge example gives deficit $2^{n-2}$; multiple missing edges introduce overlap patterns that encode matching, star, and more general subgraph structure.

## 12. Future directions

First, one may seek **exact defect bounds**. If a graph is missing $m$ edges, bound

$$
2^n-|\mathrm{Cl}(G)|
$$

in terms of the missing-edge graph and characterize equality. This would make near-maximal clique count structurally meaningful.

Second, a **critical-scale decomposition** should express each filtration jump through cliques newly completed by edges at an attained distance. For a single edge, the common-neighborhood formula in Remark 4.3 gives the answer; simultaneous births require controlling overlaps.

Third, **dimension-refined counts** can replace the total by the vector counting $k$-simplices. Added edges always increase the one-dimensional count, while higher-dimensional coordinates increase exactly when the new edges complete cliques of the relevant size.

Fourth, **approximation transfer** may combine rigidity with additive or multiplicative interleavings. One would like to infer proximity-graph structure when an approximate complex has simplex count close to $2^n$.

Finally, **locally finite infinite filtrations** can be studied through finite windows. The finite theorems apply on each window; the main issue is compatibility as the windows exhaust the full vertex set.

## 13. Conclusion

For finite graphs, $2^n$ is the maximal clique-complex size, and equality holds exactly for the complete graph. Proper edge inclusion strictly increases clique count. Through the threshold-graph representation, these statements become geometric facts about Vietoris–Rips complexes: maximal size is equivalent to all pairwise dissimilarities lying within scale, and every edge birth forces strict simplex growth. The total count is therefore both an extremal certificate and an event detector for finite proximity filtrations.