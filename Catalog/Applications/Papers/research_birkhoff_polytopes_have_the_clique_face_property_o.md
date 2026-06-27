# The Clique-Face Property of Birkhoff Polytopes: A Complete Dimensional Dichotomy

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Applications (Discrete Geometry / Combinatorial Optimization)

---

## Abstract

The Birkhoff polytope $B_n$ is the convex hull in $\mathbb{R}^{n\times n}$ of the $n!$ permutation matrices, equivalently (Birkhoff–von Neumann) the polytope of doubly stochastic matrices. A polytope is said to have the **clique-face property** when every clique of its $1$-skeleton (graph) is the vertex set of a face. Since the vertex set of every face is automatically a clique, the property asserts the exact converse: that local pairwise adjacency always certifies membership in a common face. We give a complete answer for the Birkhoff family: **$B_n$ has the clique-face property if and only if $n \le 2$** (`birkhoff_cliqueFace_iff`). The forward direction is a finite verification in the two trivial dimensions. The reverse direction rests on a single explicit obstruction valid for all $n \ge 3$ (`not_cliqueFace_fin_of_three`): the three transpositions on three symbols form a triangle in the skeleton (the Brualdi–Gibson single-cycle adjacency criterion) whose support union is the full $3\times 3$ block, so the smallest face containing them also contains the identity and is therefore strictly larger than the clique. We formalize the controlling combinatorial predicate, *support-closedness* (`IsFaceVertexSet`), which reduces the geometric question to a finite check, and we discuss the resulting *disjoint-graph dichotomy*, algorithmic consequences for skeleton-walking methods, and several open generalizations to transportation polytopes.

---

## 1. Introduction

Polytope skeletons sit at the interface of geometry and combinatorics. The $1$-skeleton (or *graph*) $G(P)$ of a polytope $P$ records its vertices and the edges of its boundary; Balinski's theorem, the Hirsch-type diameter questions, and the behavior of the simplex method all live in $G(P)$. A natural structural question is how faithfully the cheap, low-dimensional graph $G(P)$ encodes the full face lattice of $P$.

One sharp formulation uses cliques. A **clique** of $G(P)$ is a set of pairwise-adjacent vertices. For any face $F \preceq P$, its vertex set $\mathrm{vert}(F)$ is a clique, because vertices of a face are pairwise joined by edges of that face. The reverse implication is special:

> **Definition (clique-face property).** A polytope $P$ has the *clique-face property* if for every clique $C \subseteq \mathrm{vert}(P)$ there exists a face $F \preceq P$ with $\mathrm{vert}(F) = C$.

When $P$ enjoys this property, its face lattice is recoverable from its graph: faces *are* exactly cliques. This is the discrete-geometry analogue of a graph being "perfectly readable" from local adjacency. Few polytopes satisfy it, and identifying which do is a recurring theme.

We resolve the question completely for the **Birkhoff polytope** $B_n$, the most studied of all $0/1$ transportation polytopes.

**Theorem (`birkhoff_cliqueFace_iff`).** *For every $n \ge 1$, the Birkhoff polytope $B_n$ has the clique-face property if and only if $n \le 2$.*

The result is a clean dimensional dichotomy: the property holds in the two degenerate dimensions (a point and a segment) and fails in every dimension where $B_n$ is genuinely high-dimensional. The mechanism is fully explicit and finitary, which is what makes the statement formalizable and the failure transparent.

### Contributions

1. A complete characterization (`birkhoff_cliqueFace_iff`) of the clique-face property across the entire Birkhoff family.
2. A combinatorial reduction of the geometric notion "vertex set of a face" to a finite predicate, *support-closedness* (`IsFaceVertexSet`).
3. An explicit, dimension-independent counterexample for $n \ge 3$ (`not_cliqueFace_fin_of_three`): three transpositions.
4. A structural account — the *disjoint-graph dichotomy* — explaining precisely why three swaps obstruct the property, together with algorithmic consequences and a slate of open problems on general transportation polytopes.

---

## 2. Preliminaries and Definitions

Throughout, $[n] = \{1,\dots,n\}$, $S_n$ is the symmetric group on $[n]$, and $\iota$ is the identity permutation.

### 2.1 Permutation matrices and the Birkhoff polytope

**Definition 2.1 (permutation matrix).** For $\sigma \in S_n$, the permutation matrix $P_\sigma \in \mathbb{R}^{n\times n}$ has entries $(P_\sigma)_{ij} = [\,\sigma(i) = j\,]$ (Iverson bracket). It has exactly one $1$ per row and per column.

**Definition 2.2 (Birkhoff polytope).**
$$B_n := \operatorname{conv}\{\,P_\sigma : \sigma \in S_n\,\} \subseteq \mathbb{R}^{n\times n}.$$

**Theorem 2.3 (Birkhoff–von Neumann).** $B_n$ equals the set of doubly stochastic matrices,
$$B_n = \Bigl\{ X \in \mathbb{R}^{n\times n} : X_{ij}\ge 0,\ \textstyle\sum_{j} X_{ij}=1\ \forall i,\ \sum_{i} X_{ij}=1\ \forall j \Bigr\}.$$
Its vertices are exactly the $n!$ permutation matrices; $\dim B_n = (n-1)^2$; and for $n \ge 3$ its facets are the $n^2$ sets $\{X \in B_n : X_{ij} = 0\}$.

### 2.2 Support and faces

**Definition 2.4 (support).** The *support* of $\sigma \in S_n$ is the set of cells used by $P_\sigma$:
$$\operatorname{supp}(\sigma) := \{(i,\sigma(i)) : i \in [n]\} \subseteq [n]\times[n].$$
For a finite set $S \subseteq S_n$, its *support union* is $U(S) := \bigcup_{\sigma \in S}\operatorname{supp}(\sigma)$.

The faces of $B_n$ admit a classical combinatorial description. A nonempty face is obtained by fixing a set of cells to zero; the vertices of that face are the permutation matrices supported on the complementary (allowed) cells. Concretely, for a cell-pattern $A \subseteq [n]\times[n]$ that is a union of permutation supports, the corresponding face has vertex set $\{\,\sigma : \operatorname{supp}(\sigma)\subseteq A\,\}$. Hence the **smallest face** containing a set $S$ of vertices has vertex set
$$\operatorname{faceClosure}(S) = \{\,\pi \in S_n : \operatorname{supp}(\pi) \subseteq U(S)\,\}. \tag{2.1}$$

This motivates the central predicate, which is exactly $S = \operatorname{faceClosure}(S)$.

**Definition 2.5 (`IsFaceVertexSet`, support-closedness).** A finite set $S \subseteq S_n$ is a *face vertex set* if it is support-closed:
$$\operatorname{IsFaceVertexSet}(S) \iff S = \{\,\pi \in S_n : \operatorname{supp}(\pi) \subseteq U(S)\,\}.$$

**Lemma 2.6.** A set $S \subseteq \mathrm{vert}(B_n)$ is the vertex set of a face of $B_n$ if and only if $\operatorname{IsFaceVertexSet}(S)$ holds.

*Proof sketch.* The inclusion $S \subseteq \operatorname{faceClosure}(S)$ is automatic. By (2.1), $\operatorname{faceClosure}(S)$ is the vertex set of the smallest face $F$ containing $S$. If $S$ is the vertex set of *some* face, that face contains $F$ and is contained in it (minimality), so $S = \operatorname{faceClosure}(S)$. Conversely, if $S = \operatorname{faceClosure}(S)$ then $S = \mathrm{vert}(F)$. $\square$

The value of Definition 2.5 is that it is *finite and decidable*: to test whether $S$ is a face, compute $U(S)$ and check whether any permutation outside $S$ fits inside $U(S)$.

### 2.3 The skeleton of $B_n$

**Theorem 2.7 (Brualdi–Gibson adjacency).** Two distinct vertices $P_\sigma, P_\tau$ of $B_n$ are joined by an edge if and only if $\sigma^{-1}\tau$ is a *single cycle*, i.e. consists of exactly one nontrivial cycle and fixes all other points.

Equivalently, $P_\sigma$ and $P_\tau$ are adjacent iff the symmetric difference of their supports forms a single alternating cycle in the bipartite "rows–columns" graph. A consequence used repeatedly below: every transposition is adjacent to the identity (a $2$-cycle is a single cycle), and any two transpositions on three common symbols differ by a $3$-cycle, hence are adjacent.

**Definition 2.8 (clique).** $C \subseteq \mathrm{vert}(B_n)$ is a *clique* if every two distinct elements of $C$ are adjacent in the sense of Theorem 2.7.

---

## 3. Main Results

### 3.1 The positive cases $n \le 2$

**Proposition 3.1.** $B_1$ and $B_2$ have the clique-face property.

*Proof sketch.* For $n=1$, $S_1 = \{\iota\}$; $B_1$ is a point. Its only cliques are $\varnothing$ and $\{\iota\}$, each a face. For $n=2$, $S_2 = \{\iota, (1\,2)\}$ and $B_2$ is a segment. The cliques are $\varnothing$, $\{\iota\}$, $\{(1\,2)\}$, and $\{\iota,(1\,2)\}$. Each is support-closed: the singletons have support unions equal to a single permutation matrix's footprint (a $2\times2$ diagonal or antidiagonal), which admits no second permutation; the full pair has support union all of $[2]\times[2]$ and equals all of $S_2$, the whole segment. By Lemma 2.6 each clique is a face. $\square$

The decisive observation is that for $n \le 2$ no proper, nonempty support union can admit a permutation outside the clique that generated it; the polytope is too small to host a stranger.

### 3.2 The obstruction for $n \ge 3$

**Lemma 3.2 (three transpositions form a clique).** Let $n \ge 3$ and consider, as elements of $S_n$ fixing $\{4,\dots,n\}$,
$$\tau_{12} = (1\,2),\quad \tau_{13} = (1\,3),\quad \tau_{23} = (2\,3).$$
Then $\{\tau_{12},\tau_{13},\tau_{23}\}$ is a clique in the skeleton of $B_n$.

*Proof sketch.* For any two distinct transpositions among these, their product is a $3$-cycle on $\{1,2,3\}$; e.g. $\tau_{12}^{-1}\tau_{13} = (1\,2)(1\,3) = (1\,3\,2)$. A $3$-cycle is a single cycle, so by Theorem 2.7 each pair is adjacent. $\square$

**Lemma 3.3 (their support union is full on the $3\times3$ block).** With the $\tau$'s of Lemma 3.2, the support union $U = U(\{\tau_{12},\tau_{13},\tau_{23}\})$ contains every cell of $\{1,2,3\}\times\{1,2,3\}$ together with the diagonal cells $(k,k)$ for $k > 3$.

*Proof sketch.* Direct computation of the three footprints:
$$\operatorname{supp}(\tau_{12}) \supseteq \{(1,2),(2,1),(3,3)\},\quad \operatorname{supp}(\tau_{13}) \supseteq \{(1,3),(3,1),(2,2)\},\quad \operatorname{supp}(\tau_{23}) \supseteq \{(1,1),(2,3),(3,2)\},$$
whose union is all nine cells of the top-left $3\times3$ block; outside the block all three agree with the identity, contributing $(k,k)$ for $k>3$. $\square$

**Theorem 3.4 (`not_cliqueFace_fin_of_three`).** For every $n \ge 3$, the clique $C = \{\tau_{12},\tau_{13},\tau_{23}\}$ is **not** the vertex set of any face of $B_n$. Hence $B_n$ does not have the clique-face property.

*Proof sketch.* By Lemma 3.2, $C$ is a clique. The identity $\iota \in S_n$ has $\operatorname{supp}(\iota) = \{(k,k):k\in[n]\}$, every cell of which lies in $U(C)$ by Lemma 3.3 (the block diagonal $(1,1),(2,2),(3,3)$ and the cells $(k,k)$, $k>3$). Thus $\operatorname{supp}(\iota)\subseteq U(C)$, so $\iota \in \operatorname{faceClosure}(C)$. But $\iota \notin C$ (the identity is not a transposition). Therefore $C \ne \operatorname{faceClosure}(C)$, so $\operatorname{IsFaceVertexSet}(C)$ fails, and by Lemma 2.6 $C$ is not a face vertex set. A clique that is not a face exhibits the failure of the clique-face property. $\square$

The witness is *uniform in $n$*: the same three transpositions, placed on the first three coordinates, break the property in every dimension $\ge 3$.

### 3.3 The full characterization

**Theorem 3.5 (`birkhoff_cliqueFace_iff`, main result).**
$$B_n \text{ has the clique-face property} \iff n \le 2.$$

*Proof.* ($\Leftarrow$) Proposition 3.1. ($\Rightarrow$) Contrapositive: if $n \ge 3$, Theorem 3.4 provides a clique that is not a face, so the property fails. $\square$

---

## 4. The Disjoint-Graph Dichotomy

The proof of Theorem 3.5 isolates a structural principle worth stating on its own. Whether a clique $C$ closes into a face is decided entirely by the *support union* $U(C)$:

- $C$ is a face $\iff$ no permutation outside $C$ is supported within $U(C)$.

Two forces pull against each other. Adjacency (Theorem 2.7) requires permutations to interact through shared rows and columns — single-cycle differences entangle their supports. But a *large* shared footprint is exactly what lets *extra* permutations slip inside $U(C)$. The transposition triangle is the minimal configuration where these forces collide: three permutations whose pairwise differences are single cycles, yet whose combined footprint is so large it readmits the identity.

This dichotomy explains both halves of the theorem at once. For $n \le 2$ the ambient grid is too small for any nontrivial support union to host an outsider, so cliques are forced to be faces. For $n \ge 3$ the symmetric group is rich enough that a triangle of swaps saturates a $3\times3$ block, and saturation always smuggles in the identity.

It also predicts the *minimal* failure size. Edges of $B_n$ are always faces (a $2$-clique $\{\sigma,\tau\}$ with $\sigma^{-1}\tau$ a single cycle has support union admitting no third permutation supported within it — the Brualdi–Gibson edge property). So no $2$-element clique can fail, and Theorem 3.4 shows a $3$-element clique does. The smallest counterexample has size exactly $3$.

---

## 5. Algorithms

We record the finite procedures underlying the formal development. All are polynomial in $|S|$ and $n$ except the global property check, which enumerates $S_n$.

### 5.1 Adjacency test (Brualdi–Gibson)

**Input:** $\sigma,\tau \in S_n$. **Output:** whether $P_\sigma, P_\tau$ are adjacent.
Compute $\rho = \sigma^{-1}\tau$; return *true* iff $\rho$ has exactly one nontrivial cycle (equivalently, the set $\{i : \rho(i)\ne i\}$ is a single cycle of $\rho$).

Complexity: $O(n)$.

### 5.2 Face-closure / support-closedness (`IsFaceVertexSet`)

**Input:** finite $S \subseteq S_n$. **Output:** whether $S$ is a face vertex set.
Compute $U = \bigcup_{\sigma\in S}\operatorname{supp}(\sigma)$. Return *true* iff every $\pi \in S_n$ with $\operatorname{supp}(\pi)\subseteq U$ already lies in $S$. Equivalently, enumerate the permutations supported on $U$ (a permanent-style enumeration of the $0/1$ pattern $U$) and compare with $S$.

Complexity: dominated by enumerating permutations supported on $U$.

### 5.3 Clique-face property check for fixed $n$

**Input:** $n$. **Output:** whether $B_n$ has the clique-face property.
Build the skeleton graph on $S_n$ using §5.1; enumerate maximal cliques; for each clique test §5.2. Return *true* iff all cliques are face vertex sets. For $n \ge 3$ the procedure terminates early upon the transposition triangle.

---

## 6. Numerical Illustrations

The companion `demo.py` exhibits, with no external dependencies:

1. Construction of permutation matrices and verification of the Birkhoff–von Neumann row/column-sum conditions.
2. The Brualdi–Gibson adjacency test and the full skeleton graph of $B_3$ ($6$ vertices), confirming it is the complete graph $K_6$ on the six permutations.
3. The transposition triangle $\{(1\,2),(1\,3),(2\,3)\}$: verification that it is a clique, computation of its support union (all nine cells), and the demonstration that the identity is supported inside that union — hence the clique is not a face.
4. Confirmation of `IsFaceVertexSet` for all cliques of $B_1$ and $B_2$, and its failure at the transposition triangle for $B_3, B_4$.
5. A scan over $n \in \{1,2,3,4\}$ reproducing `birkhoff_cliqueFace_iff`: the property holds exactly for $n \le 2$.

---

## 7. Applications and Discussion

**Skeleton-walking optimization.** The simplex method and combinatorial assignment algorithms traverse $G(B_n)$. A tempting heuristic is that a set of pairwise-improving (mutually adjacent) optimal vertices assembles into a single optimal *face*, yielding a structured solution set. Theorem 3.5 cautions against this for $n \ge 3$: mutually adjacent vertices can fail to lie on a common minimal face, so "local optimal adjacency" does not certify a face of optima.

**Graph-encoding of face lattices.** The clique-face property would let one recover the face lattice of $B_n$ from its graph alone. The theorem says this compression is available only in the degenerate dimensions; for $n \ge 3$ the graph genuinely loses face information, consistent with $B_n$'s skeleton being highly dense (for $n=3$ it is $K_6$).

**A clean formal target.** Because Lemma 2.6 reduces "is a face" to the finite predicate `IsFaceVertexSet`, the entire dichotomy is decidable for each fixed $n$ and the counterexample is a concrete finite object. This is what allows a fully rigorous, machine-checkable proof of an "iff across all $n$" statement: the hard direction is a single uniform witness, the easy direction a finite check.

---

## 8. Future Directions

1. **Exact count of "bad" cliques.** For $n \ge 3$, count cliques of $G(B_n)$ that are not face vertex sets, as a function of $n$. The face-closure characterization suggests these are counted by support patterns whose union strictly contains the clique (i.e. admits an extra perfect matching), plausibly with super-exponential growth and a clean closed form.

2. **Minimal bad clique size.** Prove that for $n \ge 3$ the smallest non-face clique has size exactly $3$, realized by three transpositions. The lower bound reduces to the Brualdi–Gibson fact that all $2$-cliques (edges) are faces; only the finite local check that all $2$-element cliques satisfy `IsFaceVertexSet` remains.

3. **General transportation polytopes.** Replace $B_n$ by the transportation polytope of nonnegative matrices with prescribed margins $(r,c)$. Conjecture: the clique-face property holds iff the bipartite support graph forced by $(r,c)$ admits no induced configuration of three pairwise-adjacent, full-support vertices — generalizing the $n \le 2$ threshold. The support-union face model ports directly to general margins.

4. **Graph-theoretic identity of failures.** For $n \ge 3$, restricted to any "support-saturated" set of permutations the skeleton appears complete multipartite, with clique-face failures being exactly its non-maximal cliques; the $n=3$ case is already $K_6$.

5. **Stability under symmetry quotients.** Study the clique-face property for quotients of $B_n$ by cyclic symmetries, asking whether the $n \le 2$ threshold survives such identifications.

---

## 9. Conclusion

The Birkhoff polytope, despite its rich structure, encodes its face lattice in its skeleton only in the two dimensions where there is nothing to encode. The transition is sharp, the cause concrete: three transpositions, pairwise adjacent by the single-cycle criterion, whose support union fills a $3\times3$ block and thereby readmits the identity. The result, `birkhoff_cliqueFace_iff`, is a complete dimensional dichotomy — clique-face exactly when $n \le 2$ — proved through a finite, decidable reformulation (`IsFaceVertexSet`) and a single uniform counterexample (`not_cliqueFace_fin_of_three`).

---

## References

The combinatorial structure used here is classical: the Birkhoff–von Neumann theorem on doubly stochastic matrices, and the Brualdi–Gibson description of the edges of the Birkhoff polytope via single-cycle differences. All statements above are self-contained and proved (or sketched) inline.
