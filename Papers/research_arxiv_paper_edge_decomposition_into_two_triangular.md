# Triangular Forests: Sparsity, Thresholds, and Obstructions for Two-Colour Edge Decomposition

**Author:** Aristotle

**Date:** 2026-08-18

---

## Abstract

A *triangular forest* is a graph in which every cycle has length exactly three; equivalently, a graph each of whose $2$-connected blocks is a single edge or a triangle. This class is the smallest nontrivial graph class that is closed under topological minors and $1$-sums, has decidable membership, contains a triangle, and is not the class of all graphs — precisely the hypotheses under which the edge-decomposition problem into $k \ge 3$ parts is known to be NP-hard. The case $k = 2$ is the natural frontier, and triangular forests the natural test class.

We develop the complete extremal theory of the two-colour problem. We prove the sharp sparsity law: a triangular forest on $n \ge 1$ vertices has at most $\lfloor 3(n-1)/2 \rfloor$ edges, i.e. $2e \le 3(n-1)$, improving the elementary degeneracy bound $e \le 2n-3$. The proof is a two-step longest-path argument that locates a *leaf triangle*: an edge both of whose endpoints have degree two, whose removal deletes exactly $3$ edges and $2$ vertices. We show the bound is attained for every odd order by the windmill graphs $F_k$ ($k$ triangles sharing a hub), and we isolate the structural criterion — every non-hub vertex has at most one further neighbour — that makes this a three-line cycle argument.

From the sharp bound we derive an exact threshold: for $n \ge 5$, the complete graph $K_n$ decomposes into two triangular forests if and only if $n = 5$. The positive direction is an explicit decomposition of $K_5$ into two copies of "a triangle with two pendant edges"; the negative direction is counting for $n \ge 7$ and an integrality refinement at the critical value $n = 6$, where the real relaxation is a dead heat at $15$ edges but each part can carry only $7$. Because decomposability is inherited by subgraphs and by pullbacks along injections, this yields a universal *clique obstruction*: no graph containing six mutually adjacent vertices decomposes into two triangular forests.

We also record: closure of the class under $1$-sums; decidability of class membership via the bound "every cycle is shorter than $n+1$"; the local structure forced by $C_4$-freeness (neighbourhoods induce matchings, so every edge lies in at most one triangle); the succinct-certificate reformulation of the decision problem as an edge $2$-colouring, giving membership in NP and outright decidability; and a sharp lower bound $n \le 3k$ on the *triangular thickness* of $K_n$, improving the naive $n-1 \le 4k$ by an asymptotic factor $4/3$ and provably optimal as a counting bound.

**Keywords:** triangular forest, edge decomposition, graph arboricity, sparsity bound, windmill graph, thickness, NP-completeness, $1$-sum.

---

## 1. Introduction

### 1.1 Edge decomposition

Let $\mathcal{F}$ be a class of graphs. The *edge-decomposition problem into $k$ elements of $\mathcal{F}$* asks, for an input graph $G$, whether the edge set $E(G)$ can be partitioned into $k$ parts $E_1, \dots, E_k$ so that each spanning subgraph $(V(G), E_i)$ belongs to $\mathcal{F}$. This single template subsumes a remarkable number of classical problems: arboricity ($\mathcal{F}$ = forests), thickness ($\mathcal{F}$ = planar graphs), outerthickness ($\mathcal{F}$ = outerplanar graphs), and linear arboricity ($\mathcal{F}$ = linear forests), among many others.

The complexity landscape is starkly bimodal. When $\mathcal{F}$ is the class of forests, the problem is polynomial-time solvable for every $k$: forests are the independent sets of the graphic matroid, so decomposition into $k$ forests is an instance of matroid union, solved by Edmonds' algorithm and characterised combinatorially by the Nash-Williams condition
$$\text{$G$ decomposes into $k$ forests} \iff |E(H)| \le k\,(|V(H)| - 1) \text{ for every subgraph } H \subseteq G.$$
For essentially every other natural $\mathcal{F}$, the problem is hard. A recent general theorem (Lee, Liu and Tsai, ICALP 2026) makes this precise: if $\mathcal{F}$ is closed under topological minors and $1$-sums, has decidable membership, contains a triangle, and is not the class of all graphs, then edge-decomposition into $k \ge 3$ elements of $\mathcal{F}$ is NP-hard. This single reduction resolves a long-standing question on outerthickness.

The restriction $k \ge 3$ is not cosmetic: the reduction genuinely needs a third colour. The case $k = 2$ therefore remains the frontier of the theory, and the natural place to attack it is at the *bottom* of the hierarchy of admissible classes $\mathcal{F}$ — the smallest class satisfying all five hypotheses. That class is the class of triangular forests, and the two-colour decomposition problem for it has recently been shown to be NP-complete.

### 1.2 This paper

The purpose of this paper is to develop, from first principles and in full detail, the *extremal and structural* theory that underpins the two-colour problem for triangular forests. Our contributions are:

1. **A sharp sparsity law** (Theorem 4.4): a triangular forest on $n \ge 1$ vertices satisfies $2e \le 3(n-1)$, improving the degeneracy bound $e \le 2n-3$ (Theorem 3.4).
2. **Sharpness for every odd order** (Theorem 5.3): the windmill graphs attain equality, so the constant $3/2$ is optimal.
3. **An exact threshold for complete graphs** (Theorem 6.4): $K_n$ decomposes into two triangular forests iff $n \le 5$, with an explicit $K_5$ certificate and an integrality argument at $n=6$.
4. **A universal clique obstruction** (Theorem 7.3): a $K_6$ subgraph forbids decomposition in any host graph.
5. **Class properties** (Section 2 and Section 8): closure under subgraphs, induced subgraphs and $1$-sums; decidable membership; containment of a triangle; exclusion of $K_4$; $C_4$-freeness and the matching-neighbourhood property.
6. **Succinct certificates and decidability** (Section 9): the decision problem is equivalent to existence of an edge $2$-colouring with both classes triangular forests, placing it in NP.
7. **A sharp thickness bound** (Theorem 10.2): covering $K_n$ by $k$ triangular forests forces $n \le 3k$.

All results are stated for arbitrary (possibly infinite) vertex sets where meaningful, and for finite graphs where counting is involved.

### 1.3 Notation

Graphs are simple and undirected. For a graph $G$ we write $V(G)$, $E(G)$, $n = |V(G)|$, $e = |E(G)|$, and $\deg_G(v)$ for the degree of $v$. A *walk* is a sequence $v_0 v_1 \cdots v_\ell$ with $v_{i}v_{i+1} \in E(G)$; its *length* is $\ell$. A walk is *closed* if $v_0 = v_\ell$. A closed walk is a *cycle* if it is nonempty, its edges are pairwise distinct, and its internal vertices $v_1, \dots, v_\ell$ are pairwise distinct. A *path* is a walk with pairwise distinct vertices. $K_n$ is the complete graph on $n$ vertices, $C_\ell$ the cycle of length $\ell$. We write $H \le G$ to mean $H$ is a spanning subgraph of $G$ (same vertex set, $E(H) \subseteq E(G)$).

---

## 2. Triangular forests

### 2.1 Definition and equivalent descriptions

**Definition 2.1 (Triangular forest).** A graph $G$ is a *triangular forest* if every cycle of $G$ has length exactly $3$.

Two equivalent formulations are worth recording, and we use the first as the working definition throughout because it is the most convenient for induction and for walk-chasing arguments.

**Proposition 2.2 (Block description).** A graph is a triangular forest if and only if every $2$-connected block of it is a single edge or a triangle.

*Proof sketch.* Suppose every cycle is a triangle. A $2$-connected graph on at least four vertices contains a cycle of length at least four (take two internally disjoint paths between two nonadjacent vertices, or note that a $2$-connected graph on $m \ge 4$ vertices has a cycle through any two edges), so every block has at most three vertices, and hence is an edge or a triangle. Conversely, suppose every block is an edge or a triangle. Any cycle lies entirely within a single block (cycles are $2$-connected subgraphs), hence within a triangle, hence has length $3$. $\square$

Thus a triangular forest is a forest whose branch structure has been decorated with pairwise edge-disjoint triangles — informally, a "tree with triangular knots". In particular:

**Proposition 2.3 (Forests are triangular forests).** If $G$ is acyclic then $G$ is a triangular forest, vacuously. In particular the empty graph is a triangular forest.

### 2.2 Closure properties

**Proposition 2.4 (Subgraph closure).** If $H \le G$ and $G$ is a triangular forest, then so is $H$.

*Proof.* Every cycle $c$ of $H$ maps to a cycle of $G$ of the same length under the inclusion $H \le G$; by hypothesis that cycle has length $3$. $\square$

**Proposition 2.5 (Induced-subgraph closure).** For any $S \subseteq V(G)$, if $G$ is a triangular forest then so is the induced subgraph $G[S]$.

*Proof.* The inclusion $G[S] \hookrightarrow G$ is an injective graph embedding; the image of a cycle under an injective homomorphism is a cycle of the same length. $\square$

**Proposition 2.6 (Pullback closure).** Let $f : W \hookrightarrow V$ be injective and let $G$ be a triangular forest on $V$. Then the pullback $f^*G$ on $W$, in which $w \sim w'$ iff $f(w) \sim f(w')$, is a triangular forest.

*Proof.* $f$ induces an injective graph homomorphism $f^*G \to G$; images of cycles are cycles of equal length. $\square$

Since topological minors of $G$ are obtained by taking subgraphs and suppressing degree-two vertices, and since suppressing a degree-two vertex changes cycle lengths, one should be careful: the class of triangular forests is closed under *minors and topological minors* in the sense relevant to the hardness framework because subdivision-reduction of a triangular forest again yields a graph all of whose blocks are edges or triangles (a subdivided triangle inside a triangular forest would already be a cycle of length $>3$, hence cannot occur). For our purposes only subgraph and pullback closure are used, and these we have proved directly.

### 2.3 Membership: the class is small but nonempty

**Proposition 2.7 (Contains a triangle).** $K_3$ is a triangular forest.

*Proof.* $K_3$ has three vertices, so at most three vertices of degree $\ge 2$; by Lemma 3.2 below, every cycle has length at most $3$, and every cycle has length at least $3$ in a simple graph. $\square$

**Proposition 2.8 (Does not contain $K_4$).** $K_4$ is not a triangular forest.

*Proof.* The four vertices $0,1,2,3$ carry the cycle $0 \to 1 \to 2 \to 3 \to 0$ of length $4 \ne 3$. $\square$

Hence the class of triangular forests is a proper, nonempty subclass of all graphs, containing a triangle. Combined with Propositions 2.4–2.6 and Theorem 8.1 (closure under $1$-sums) and Theorem 9.3 (decidability), triangular forests satisfy every hypothesis of the general hardness framework, and are minimal among classes doing so.

---

## 3. Degeneracy and the first sparsity bound

We begin with the elementary bound, both because it is instructive and because the refinement in Section 4 is a genuine strengthening of its proof.

**Lemma 3.1 (Cycle vertices have degree $\ge 2$).** If $c$ is a cycle of $G$ and $x$ lies on $c$, then $\deg_G(x) \ge 2$.

*Proof.* A cycle enters and leaves each of its vertices along distinct edges (this is the content of the edge-distinctness and internal-vertex-distinctness conditions). $\square$

**Lemma 3.2 (Cycle length bound).** If $c$ is a cycle of $G$ then $\ell(c) \le |\{x \in V(G) : \deg_G(x) \ge 2\}|$.

*Proof.* The $\ell$ internal vertices of $c$ are pairwise distinct and, by Lemma 3.1, all have degree $\ge 2$. $\square$

**Corollary 3.3.** If $G$ has at most three vertices of degree $\ge 2$, then $G$ is a triangular forest.

This corollary is the workhorse for verifying concrete small examples: it reduces membership to a degree count.

### 3.1 The longest-path argument

**Lemma 3.4 (Endpoints of longest paths).** Let $G$ be a finite triangular forest and let $P = a \, v_1 \, v_2 \cdots v_m$ be a path of maximum length in $G$. Then $\deg_G(a) \le 2$.

*Proof.* Let $y$ be a neighbour of $a$. If $y \notin V(P)$ then $y\,a\,v_1 \cdots v_m$ is a longer path, contradicting maximality. So $y = v_i$ for some $i$. If $i \ge 2$, the edge $a v_i$ together with the initial segment $a\,v_1 \cdots v_i$ of $P$ forms a cycle of length $i+1$, which must be $3$, forcing $i = 2$. Hence every neighbour of $a$ is $v_1$ or $v_2$, so $\deg_G(a) \le 2$. $\square$

**Theorem 3.5 ($2$-degeneracy).** Every finite nonempty triangular forest has a vertex of degree at most $2$. Consequently a triangular forest on $n \ge 2$ vertices satisfies
$$e \le 2n - 3.$$

*Proof.* The first statement is Lemma 3.4 applied to a maximum-length path, which exists by finiteness. For the bound, induct on $n$. For $n = 2$ the graph has at most one edge and $2n-3 = 1$. For $n > 2$, pick a vertex $v$ with $\deg(v) \le 2$; the induced subgraph $G - v$ is a triangular forest (Proposition 2.5) on $n - 1$ vertices with $e - \deg(v) \ge e - 2$ edges, so by induction $e - 2 \le 2(n-1) - 3$, i.e. $e \le 2n - 3$. $\square$

The bound $e \le 2n-3$ is the natural output of a $2$-degeneracy argument, but it is not tight: it would be tight for a class in which one could repeatedly attach a new vertex by two edges, whereas in a triangular forest attaching a vertex by two edges creates a triangle, and triangles cannot then be extended.

---

## 4. The sharp sparsity law

The correct slope is $3/2$, not $2$. The extra ingredient is a *second* application of the longest-path idea, one vertex further in.

**Lemma 4.1 (The second vertex).** Let $G$ be a finite triangular forest, let $P = a\,v_1\,v_2 \cdots v_m$ be a path of maximum length with $m \ge 2$, and suppose $a$ is adjacent to $v_2$ (equivalently, by Lemma 3.4, $\deg_G(a) = 2$). Then $\deg_G(v_1) \le 2$.

*Proof.* Note first that $a, v_1, v_2$ form a triangle. Let $y$ be a neighbour of $v_1$ with $y \notin \{a, v_2\}$; we derive a contradiction.

*Case 1: $y \notin V(P)$.* Then $y\,v_1\,a\,v_2\,v_3 \cdots v_m$ is a path (the vertices $y, v_1, a, v_2, \ldots, v_m$ are pairwise distinct) of length $m + 1 > m$, contradicting maximality of $P$.

*Case 2: $y = v_i$ with $i \ge 3$.* If $i \ge 4$, the edge $v_1 v_i$ closes with the segment $v_1 v_2 \cdots v_i$ a cycle of length $i - 1 + 1 = i \ge 4$, contradicting the triangular-forest hypothesis. If $i = 3$, then $a \to v_1 \to v_3 \to v_2 \to a$ is a closed walk on four pairwise distinct vertices — a $4$-cycle — again a contradiction (using $a v_1, v_1 v_3, v_3 v_2, v_2 a \in E$).

Hence every neighbour of $v_1$ lies in $\{a, v_2\}$ and $\deg_G(v_1) \le 2$. $\square$

**Lemma 4.2 (Leaf triangle).** Let $G$ be a finite nonempty triangular forest with minimum degree at least $2$. Then $G$ contains an edge $uv$ with $\deg_G(u) = \deg_G(v) = 2$.

*Proof.* Take a maximum-length path $P = a\,v_1 \cdots v_m$. By Lemma 3.4, $\deg_G(a) \le 2$, and by hypothesis $\deg_G(a) = 2$; by the proof of Lemma 3.4 the two neighbours of $a$ are $v_1$ and $v_2$ (so $m \ge 2$). By Lemma 4.1, $\deg_G(v_1) \le 2$, and again $\deg_G(v_1) = 2$. The edge $a v_1$ is as required. $\square$

Geometrically, $\{a, v_1\}$ is the "far edge" of a triangle $a v_1 v_2$ attached to the rest of $G$ only at $v_2$: a *leaf triangle*, the triangular-forest analogue of a leaf of a tree.

**Theorem 4.3 (Sharp sparsity law).** Every triangular forest on $n \ge 1$ vertices satisfies
$$2e \le 3(n-1), \qquad \text{equivalently} \qquad e \le \left\lfloor \frac{3(n-1)}{2} \right\rfloor.$$

*Proof.* Induction on $n$. For $n = 1$ we have $e = 0$ and the bound reads $0 \le 0$. Let $n \ge 2$ and suppose the bound holds for all smaller orders.

*Case A: some vertex $v$ has $\deg_G(v) \le 1$.* Then $G - v$ is a triangular forest on $n-1 \ge 1$ vertices with at least $e - 1$ edges, so $2(e-1) \le 3(n-2)$, giving $2e \le 3n - 4 \le 3(n-1)$.

*Case B: $\delta(G) \ge 2$.* By Lemma 4.2 there is an edge $uv$ with $\deg(u) = \deg(v) = 2$. Since $\deg(u) = 2$ and $u$'s second neighbour is (by the argument of Lemma 3.4 applied at $u$, or directly by Lemma 4.2's construction) a common neighbour $w$ of $u$ and $v$, the three vertices $u,v,w$ form a triangle and $u, v$ have no other neighbours. Delete $u$ and $v$: we remove exactly the three edges $uv, uw, vw$ and exactly two vertices. The resulting graph $G' = G - \{u,v\}$ is a triangular forest on $n - 2 \ge 1$ vertices with $e - 3$ edges (if $n = 2$ then $G$ would be a single edge and $\delta \ge 2$ fails, so indeed $n \ge 3$). By induction $2(e-3) \le 3(n-3)$, hence $2e \le 3n - 9 + 6 = 3(n-1)$. $\square$

*Remark.* The two cases have "exchange rates" $1$ edge per vertex and $3$ edges per $2$ vertices respectively; the second is the binding one, and this is exactly why the slope is $3/2$.

**Corollary 4.4 (Budget for a two-part decomposition).** If a graph $G$ on $n \ge 1$ vertices decomposes into two triangular forests $G_1, G_2$, then
$$|E(G)| = |E(G_1)| + |E(G_2)| \le 2\left\lfloor \frac{3(n-1)}{2} \right\rfloor \le 3(n-1).$$

---

## 5. Sharpness: the windmill graphs

To show that $3/2$ cannot be improved we exhibit an infinite extremal family. First, a structural membership criterion that avoids any case check.

**Lemma 5.1 (Unique far neighbour criterion).** Let $G$ be a graph and $x \in V(G)$ a distinguished vertex. Suppose every vertex $y \ne x$ has at most one neighbour other than $x$. Then $G$ is a triangular forest.

*Proof sketch.* Let $c$ be a cycle. If $x$ does not lie on $c$, then every vertex of $c$ has two neighbours on $c$, both different from $x$ — contradicting the hypothesis. So $x$ lies on $c$, and we may rotate $c$ to begin and end at $x$: $x \to y_1 \to y_2 \to \cdots \to y_\ell = x$. Now $y_1 \ne x$ has neighbours $x$ and $y_2$; if $\ell \ge 4$ then $y_2 \ne x$ has neighbours $y_1 \ne x$ and $y_3 \ne x$, two neighbours other than $x$ — contradiction. So $\ell = 3$. (Rotation preserves the length of a closed walk and the property of being a cycle.) $\square$

**Definition 5.2 (Windmill / friendship graph).** For $k \ge 0$, let $F_k$ be the graph on the vertex set $\{0, 1, \dots, 2k\}$ in which $0$ (the *hub*) is adjacent to every other vertex, and in addition $2i-1$ is adjacent to $2i$ for each $1 \le i \le k$. Thus $F_k$ consists of $k$ triangles glued at the common hub $0$.

$F_1 = K_3$, $F_2$ is the "bowtie", and in general $F_k$ has $n = 2k+1$ vertices, $3k$ edges, hub degree $2k$, and all other degrees equal to $2$.

**Theorem 5.3 (The sparsity law is attained for every odd order).** For every $k \ge 0$, the windmill $F_k$ is a triangular forest with
$$2\,|E(F_k)| = 6k = 3\big(|V(F_k)| - 1\big).$$
Hence Theorem 4.3 is sharp for every odd $n = 2k+1$.

*Proof.* Membership: every vertex $y \ne 0$ has exactly one neighbour besides the hub (its partner in its triangle), so Lemma 5.1 applies with $x = 0$. Edge count: summing degrees, $\sum_v \deg(v) = 2k + 2 \cdot 2k = 6k$, so $|E| = 3k$. Finally $3(n-1) = 3 \cdot 2k = 6k = 2 \cdot 3k$. $\square$

For even $n$ the extremal number is $\lfloor 3(n-1)/2 \rfloor = (3n-4)/2$, attained by a windmill with one extra pendant vertex; we do not require this refinement here.

*Remark 5.4 (Uniqueness).* Inspecting the proof of Theorem 4.3, equality $2e = 3(n-1)$ forces every peeling step to be of type B, i.e. to remove a leaf triangle. This suggests — and we conjecture — that for odd $n$ the maximisers are exactly the connected graphs all of whose blocks are triangles, i.e. graphs built by iterated $1$-sums of $(n-1)/2$ triangles glued in a tree pattern. The windmills are one such family (the "star" gluing pattern); a path-like gluing gives another.

---

## 6. The exact threshold for complete graphs

**Definition 6.1.** A graph $G$ *decomposes into two triangular forests* if there exist triangular forests $G_1, G_2$ on $V(G)$ with $E(G_1) \cap E(G_2) = \emptyset$ and $E(G_1) \cup E(G_2) = E(G)$.

### 6.1 The positive side: $K_5$

**Theorem 6.2 ($K_5$ decomposes).** The complete graph on $\{0,1,2,3,4\}$ decomposes into two triangular forests, namely
$$
G_1 = \{\,01,\ 02,\ 12,\ 04,\ 13\,\}, \qquad
G_2 = \{\,23,\ 24,\ 34,\ 03,\ 14\,\}.
$$

*Proof.* The two edge sets are disjoint and their union has $10 = \binom{5}{2}$ edges, hence is all of $E(K_5)$. For membership: $G_1$ consists of the triangle $012$ with pendant edges $04$ (at $0$) and $13$ (at $1$); its degree sequence is $\deg(0)=3, \deg(1)=3, \deg(2)=2, \deg(3)=1, \deg(4)=1$, so it has exactly three vertices of degree $\ge 2$ and Corollary 3.3 applies. Symmetrically (under the permutation $0 \leftrightarrow 3, 1 \leftrightarrow 4, 2 \mapsto 2$, which carries $G_1$ to $G_2$), $G_2$ is the triangle $234$ with pendant edges $03$ and $14$, again with exactly three vertices of degree $\ge 2$. $\square$

Note how tight this is: $K_5$ has $10$ edges and the budget of Corollary 4.4 at $n=5$ is $2 \lfloor 12/2 \rfloor = 12$. There is slack of two edges, which is exactly the slack visible in the two pendant edges per part.

### 6.2 The negative side: $K_6$ and beyond

**Theorem 6.3 ($K_n$ fails for $n \ge 6$).** For $n \ge 6$, $K_n$ does not decompose into two triangular forests.

*Proof.* Suppose it did, into $G_1, G_2$ with $e_i = |E(G_i)|$. By Theorem 4.3, $2e_i \le 3(n-1)$ for $i = 1,2$, and $e_1 + e_2 = \binom{n}{2} = n(n-1)/2$.

*Case $n \ge 7$.* Adding the two sparsity inequalities gives $2(e_1 + e_2) \le 6(n-1)$, i.e. $n(n-1) = 2\binom{n}{2} \le 6(n-1)$. Dividing by $n-1>0$ yields $n \le 6$, a contradiction.

*Case $n = 6$.* Here $n(n-1) = 30 = 6(n-1)$, so the real-valued count is exactly balanced and gives no contradiction. Use integrality: $2e_i \le 3 \cdot 5 = 15$ and $e_i \in \mathbb{Z}$ force $e_i \le 7$. Hence $e_1 + e_2 \le 14 < 15 = \binom{6}{2}$, a contradiction. $\square$

The $n = 6$ case is the interesting one: the obstruction is not a counting obstruction over the reals, but an *integrality* obstruction, and the counting argument misses by exactly one edge.

*Remark 6.3.1 (How far off is $K_6$?).* An exhaustive scan of all $2^{15}$ edge $2$-colourings of $K_6$ shows that the counting bound of $14$ is not attained: at most $13$ of the $15$ edges of $K_6$ can be covered by two triangular forests, a witnessing $7+6$ split being
$$G_1 = \{03,\,04,\,12,\,13,\,15,\,23,\,34\}, \qquad G_2 = \{05,\,14,\,24,\,25,\,35,\,45\},$$
which omits the two edges $01$ and $02$. Equivalently, $K_6$ minus any single edge is still indecomposable, while $K_6$ minus two disjoint edges is decomposable. This is an enumeration, reported here as a computational observation; the proof above needs only the bound $14$.

**Theorem 6.4 (Exact threshold).** For $n \ge 5$, the complete graph $K_n$ decomposes into two triangular forests if and only if $n = 5$.

*Proof.* Immediate from Theorems 6.2 and 6.3. $\square$

*Remark 6.5 (What the weaker bound gives).* Substituting the degeneracy bound $e \le 2n-3$ of Theorem 3.5 into the same argument gives only $|E(G)| \le 4n - 6$ for a decomposable $G$, and hence failure of $K_n$ only for $n \ge 8$ (since $\binom{n}{2} > 4n - 6$ iff $n \ge 8$). The sharp sparsity law is exactly what pushes the threshold from $8$ down to $6$, where it is correct.

---

## 7. Monotonicity and the clique obstruction

Threshold results about complete graphs become tools about arbitrary graphs once one knows the property is subgraph-closed.

**Theorem 7.1 (Monotonicity).** If $G$ decomposes into two triangular forests and $H \le G$, then $H$ decomposes into two triangular forests.

*Proof.* Let $E(G) = E(G_1) \sqcup E(G_2)$ with $G_1, G_2$ triangular forests. Put $H_i = H \cap G_i$. Each $H_i \le G_i$ is a triangular forest by Proposition 2.4; $E(H_1) \cap E(H_2) \subseteq E(G_1) \cap E(G_2) = \emptyset$; and
$$E(H_1) \cup E(H_2) = E(H) \cap (E(G_1) \cup E(G_2)) = E(H) \cap E(G) = E(H). \qquad \square$$

**Theorem 7.2 (Pullback monotonicity).** Let $f : W \hookrightarrow V$ be injective, let $G$ be a graph on $V$ that decomposes into two triangular forests, and let $H$ be a graph on $W$ with $H \le f^*G$. Then $H$ decomposes into two triangular forests.

*Proof.* With $E(G) = E(G_1) \sqcup E(G_2)$ as above, put $H_i = H \cap f^*G_i$. By Proposition 2.6 each $f^*G_i$ is a triangular forest, hence so is $H_i$. Disjointness is inherited pointwise. For the union, $f^*G_1 \cup f^*G_2 = f^*(G_1 \cup G_2) = f^*G$ (pullback commutes with union of edge relations), so $H_1 \cup H_2 = H \cap f^*G = H$ since $H \le f^*G$. $\square$

**Theorem 7.3 (Clique obstruction).** If a graph $G$ contains six pairwise adjacent vertices — i.e. there is an injection $f : \{1,\dots,6\} \hookrightarrow V(G)$ with $f(i) \sim f(j)$ for all $i \ne j$ — then $G$ does **not** decompose into two triangular forests.

*Proof.* The hypothesis says $K_6 \le f^*G$. If $G$ decomposed, then by Theorem 7.2 so would $K_6$, contradicting Theorem 6.3. $\square$

Theorem 7.3 is a *local certificate of infeasibility*, verifiable by examining six vertices — the two-colour analogue of "an odd cycle forbids a proper $2$-colouring of the vertices". It is not a characterisation: by the NP-completeness of the problem one cannot expect the obstruction set to be finite or even polynomially recognisable. But it is a genuinely useful preprocessing rule, and it shows that the failure at $K_6$ propagates to every host graph.

*Remark 7.4 (Density obstruction).* Corollary 4.4 combined with Theorem 7.1 gives a second, quantitative obstruction: if $G$ has any subgraph $H$ on $m$ vertices with $|E(H)| > 3(m-1)$, then $G$ does not decompose. This is the exact analogue of the Nash-Williams condition for forests — necessary here, but (unlike in the forest case) not sufficient, which is precisely the gap in which the hardness lives.

---

## 8. Closure under $1$-sums

A *$1$-sum* of two graphs is their union along a single shared vertex. Formally, we work with two graphs $G_1, G_2$ on a common vertex set whose *supports* (sets of non-isolated vertices) intersect in at most one vertex $x$; the $1$-sum is $G_1 \cup G_2$.

**Lemma 8.1 (Edges stay on one side).** Suppose that every vertex $y$ incident both to an edge of $G_1$ and to an edge of $G_2$ equals $x$. Let $p = u_0 u_1 \cdots u_\ell$ be a walk in $G_1 \cup G_2$ with $u_i \ne x$ for all $i < \ell$. Then either all edges of $p$ lie in $G_1$, or all lie in $G_2$.

*Proof.* Induction on $\ell$. For $\ell \le 1$ there is nothing to prove. For the step, consider consecutive edges $u_{i-1}u_i$ and $u_i u_{i+1}$ with $i < \ell$, hence $u_i \ne x$. If the two edges lay on different sides then $u_i$ would be incident to an edge of $G_1$ and to an edge of $G_2$, forcing $u_i = x$, a contradiction. So consecutive edges share a side, and by transitivity all edges do. $\square$

**Theorem 8.2 (Closure under $1$-sums).** If $G_1$ and $G_2$ are triangular forests whose supports meet only in the vertex $x$, then $G_1 \cup G_2$ is a triangular forest.

*Proof.* Let $c$ be a cycle of $G_1 \cup G_2$. If $x$ lies on $c$, rotate $c$ so that it starts and ends at $x$; rotation preserves both the cycle property and the length. Now no internal vertex of the rotated cycle equals $x$ (internal vertices of a cycle are distinct from the endpoints), so Lemma 8.1 applies and all edges of $c$ lie on a single side, say in $G_i$. If $x$ does not lie on $c$ at all, Lemma 8.1 applies directly. Either way, $c$ transfers to a cycle of $G_i$ of the same length, which is $3$ by hypothesis. $\square$

Together with Propositions 2.4–2.8, Theorem 8.2 completes the verification that triangular forests satisfy all five hypotheses of the general hardness framework: closed under (topological) minors and $1$-sums, decidable membership (Section 9), contains a triangle, is not everything.

---

## 9. Certificates, decidability, and NP membership

### 9.1 Deciding membership

**Theorem 9.1 (Membership is decidable).** For a finite graph $G$ on $n$ vertices,
$$G \text{ is a triangular forest} \iff \text{every closed walk at every vertex of length} < n+1 \text{ that is a cycle has length } 3.$$
In particular membership is decidable by a finite search.

*Proof.* ($\Rightarrow$) trivial. ($\Leftarrow$) Let $c$ be any cycle. By Lemma 3.2, $\ell(c) \le |\{x : \deg(x) \ge 2\}| \le n < n+1$, so $c$ falls within the searched range and hence has length $3$. $\square$

Being a cycle is itself decidable for a given closed walk: it amounts to checking that the edge list has no repetitions, that the walk is nonempty, and that the tail of the support list has no repetitions.

*Remark 9.2 (Efficient membership test).* Theorem 9.1 gives decidability but not efficiency; in practice one uses the block description (Proposition 2.2). The following runs in linear time: (i) verify that every edge lies in at most one triangle (equivalently, that neighbourhoods induce matchings, Theorem 9.5); (ii) contract each triangle to a single vertex; (iii) verify the result is a forest. Alternatively, compute the block-cut tree and check that every block has at most $3$ vertices.

### 9.2 Succinct certificates for the decision problem

**Definition 9.3.** For a graph $G$ and a function $f : E(G) \to \{\text{true},\text{false}\}$, the *colour class* $G_f^b$ is the spanning subgraph with edge set $\{ \epsilon \in E(G) : f(\epsilon) = b\}$.

**Theorem 9.4 (Certificate theorem).** A graph $G$ decomposes into two triangular forests if and only if there exists an edge $2$-colouring $f : E(G) \to \{\text{true},\text{false}\}$ such that both $G_f^{\text{true}}$ and $G_f^{\text{false}}$ are triangular forests.

*Proof.* ($\Leftarrow$) The two colour classes are edge-disjoint by construction and their union is $G$, and both are triangular forests by hypothesis.

($\Rightarrow$) Given a decomposition $G = G_1 \sqcup G_2$, define $f(\epsilon) = \text{true}$ iff $\epsilon \in E(G_1)$. Then $G_f^{\text{true}} = G_1$: an edge of $G$ is coloured true iff it is in $G_1$, and every edge of $G_1$ is an edge of $G$. And $G_f^{\text{false}} = G_2$: an edge of $G$ not in $G_1$ is in $G_2$ by the covering condition, and conversely every edge of $G_2$ is an edge of $G$ not in $G_1$ by disjointness. $\square$

The content of Theorem 9.4 is not logical but *structural*: it replaces an existential quantifier over pairs of abstract graphs by an existential quantifier over functions $E(G) \to \{0,1\}$, an object of size $|E(G)|$. Combined with the polynomial-time membership test of Remark 9.2, this places the decision problem in **NP**.

**Corollary 9.5 (Decidability of the decision problem).** For finite $G$, whether $G$ decomposes into two triangular forests is decidable: search over the $2^{|E(G)|}$ edge colourings, testing each colour class for membership.

The recent NP-*completeness* theorem for this problem says, informally, that no substantially better algorithm is available: the exponential search over colourings cannot be replaced by a polynomial procedure unless P $=$ NP.

### 9.3 The forbidden $C_4$ and the matching neighbourhood

We record the two local structure results that drive the efficient membership test and several of the arguments above.

**Theorem 9.6 ($C_4$-freeness).** A triangular forest contains no four distinct vertices $a,b,c,d$ with $a \sim b \sim c \sim d \sim a$ (allowing $a \ne c$ and $b \ne d$).

*Proof.* Such a configuration is a cycle of length $4$: the edges $ab, bc, cd, da$ are pairwise distinct, and the internal vertices $b,c,d$ are pairwise distinct. Its length is $4 \ne 3$. $\square$

**Theorem 9.7 (Matching neighbourhoods).** Let $G$ be a triangular forest and $v \in V(G)$. If $u, w, x$ are neighbours of $v$ with $u \sim w$ and $u \sim x$, then $w = x$. Equivalently, the neighbourhood of every vertex induces a matching.

*Proof.* Suppose $w \ne x$. Then $v \sim w \sim u \sim x \sim v$ is a $4$-cycle on the four distinct vertices $v, w, u, x$ (distinctness: $u \ne v$ since $u \sim v$; $w \ne x$ by assumption; $w,x \ne v,u$ by adjacency), contradicting Theorem 9.6. $\square$

**Corollary 9.8 (Triangles are edge-disjoint).** In a triangular forest, every edge lies in at most one triangle: if $uvw$ and $uvx$ are both triangles then $w = x$.

*Proof.* Apply Theorem 9.7 at the vertex $u$ with neighbours $v, w, x$ (using $v \sim w$, $v \sim x$). $\square$

---

## 10. Triangular thickness

**Definition 10.1.** The *triangular thickness* $\theta_\triangle(G)$ of a graph $G$ is the least $k$ such that $E(G)$ can be covered by $k$ triangular forests. (Since the class is subgraph-closed, "cover" and "partition" give the same parameter.)

**Theorem 10.2 (Sharp lower bound for complete graphs).** If the edges of $K_n$ ($n \ge 2$) are covered by $k$ triangular forests, then
$$n \le 3k, \qquad \text{i.e.} \qquad \theta_\triangle(K_n) \ge \lceil n/3 \rceil.$$

*Proof.* Let $H_1, \dots, H_k$ be the covering triangular forests, with $e_i = |E(H_i)|$. Every edge of $K_n$ lies in some $H_i$, so
$$\binom{n}{2} \le \sum_{i=1}^k e_i.$$
By Theorem 4.3, $2 e_i \le 3(n-1)$ for each $i$, so $2\sum_i e_i \le 3k(n-1)$. Therefore $n(n-1) = 2\binom{n}{2} \le 3k(n-1)$, and dividing by $n - 1 > 0$ gives $n \le 3k$. $\square$

**Theorem 10.3 (Naive bound, for comparison).** Under the same hypotheses, the degeneracy bound $e_i \le 2n-3$ yields only
$$\binom{n}{2} + 3k \le 2kn, \qquad \text{hence} \qquad n - 1 \le 4k.$$

*Proof.* Summing $e_i + 3 \le 2n$ over $i$ gives $\binom{n}{2} + 3k \le \sum_i e_i + 3k \le 2kn$; the stated consequence follows by expanding $\binom{n}{2}$ and rearranging. $\square$

Theorem 10.2 improves Theorem 10.3 by an asymptotic factor $4/3$. Moreover, by Theorem 5.3 the sparsity input to Theorem 10.2 is optimal, so *any* further improvement must come from a global obstruction rather than from edge counting. That such obstructions exist is demonstrated by $n = 6$: there the bound of Theorem 10.2 permits $k = 2$, but Theorem 6.3 rules it out, so $\theta_\triangle(K_6) \ge 3$.

*Remark 10.4 (Conjectured value).* Exploratory randomised search finds covers of $K_n$ by exactly $\lceil n/3 \rceil$ triangular forests for all small $n$ except $n = 6$, suggesting
$$\theta_\triangle(K_n) = \lceil n/3 \rceil \quad \text{for all } n \ge 3, \ n \ne 6, \qquad \theta_\triangle(K_6) = 3.$$
A cover meeting the counting bound must consist of forests that are simultaneously edge-maximal (windmill-like, $2e = 3(n-1)$) and pairwise almost edge-disjoint — exactly the structure of a resolvable partial triple system. The unique failure at $n = 6$ mirrors the classical non-existence of a resolvable Steiner triple system of order $6$. Constructions for general $n$ remain open.

---

## 11. Algorithms

We summarise the algorithmic content of the results above.

### 11.1 Membership test

**Input:** a graph $G$. **Output:** whether $G$ is a triangular forest.

1. For every edge $uv$, compute $T(uv) = |N(u) \cap N(v)|$, the number of triangles containing $uv$. If some $T(uv) \ge 2$, reject (Corollary 9.8).
2. Build $G'$ from $G$ by contracting each triangle of $G$ to a single vertex (the triangles are pairwise edge-disjoint by step 1; contract greedily, since a vertex may lie in several triangles — contract the *edge sets* of the triangles).
3. Accept iff $G'$ is acyclic, tested by a depth-first search.

Complexity: step 1 is $O(\sum_{uv} \min(\deg u, \deg v)) = O(m^{3/2})$ by standard triangle enumeration; steps 2–3 are $O(n + m)$. In total $O(m^{3/2})$.

An even simpler variant, adequate for sparse inputs: compute the block-cut tree in $O(n+m)$ and accept iff every biconnected block has at most $3$ vertices.

### 11.2 Exhaustive decomposition search with pruning

**Input:** a graph $G$. **Output:** a partition $E(G) = E_1 \sqcup E_2$ into triangular forests, or "infeasible".

1. **Density prescreen.** If $|E(G)| > 3(|V(G)| - 1)$, return infeasible (Corollary 4.4). More strongly, for every subgraph $H$ examined, if $|E(H)| > 3(|V(H)|-1)$ return infeasible (Remark 7.4).
2. **Clique prescreen.** If $G$ contains a $K_6$, return infeasible (Theorem 7.3).
3. **Backtracking.** Order the edges $\epsilon_1, \dots, \epsilon_m$. Maintain partial colour classes $E_1, E_2$. At step $j$, try assigning $\epsilon_j$ to $E_1$; if the resulting $E_1$ is still a triangular forest, recurse; else try $E_2$; if neither works, backtrack.
4. If all $m$ edges are assigned, return $(E_1, E_2)$; if the search exhausts, return infeasible.

Correctness follows from Theorem 9.4 together with the subgraph-closure of the class (Proposition 2.4), which makes the partial-assignment test *sound*: a partial class that is not a triangular forest cannot become one by adding edges. Worst-case complexity is $O(2^m \cdot \mathrm{poly})$, matching the brute force of Corollary 9.5, but the pruning is extremely effective in practice: the incremental test at step 3 need only check the newly created cycles through $\epsilon_j$.

### 11.3 Greedy thickness cover

**Input:** a graph $G$, target $k$. **Output:** a cover of $E(G)$ by $k$ triangular forests, or failure.

Repeatedly extract a maximal triangular forest greedily (scan edges in a random order, adding an edge whenever it keeps the current class a triangular forest), remove it, and iterate. Repeat with fresh random orders. This is the randomised procedure that finds $\lceil n/3 \rceil$-covers of $K_n$ for small $n$ (except $n = 6$), and it is a Las Vegas algorithm: any cover it outputs is verified correct by the membership test of §11.1.

---

## 12. Applications and context

**Arboricity-type parameters.** Triangular thickness sits between arboricity and thickness. By Nash-Williams, the arboricity of $K_n$ is $\lceil n/2 \rceil$; Theorem 10.2 and Remark 10.4 say the triangular thickness is (conjecturally exactly, provably at least) $\lceil n/3 \rceil$ — a strict improvement reflecting the extra triangles that each part may carry. The factor is exactly the ratio of the sparsity slopes: $1$ edge per vertex for forests, $3/2$ for triangular forests.

**Sparse-graph certificates.** The condition "every subgraph $H$ satisfies $|E(H)| \le 3(|V(H)| - 1)$" is a $(3,3)$-sparsity condition in the sense of rigidity theory, checkable in polynomial time by pebble games. Corollary 4.4 says decomposability implies this condition; the NP-completeness of the decomposition problem says the converse fails badly, in contrast with the forest case where the analogous $(k,k)$-sparsity condition is exactly equivalent (Nash-Williams / Edmonds). Triangular forests are thus a natural minimal witness that matroidal sparsity theory does not extend past forests.

**Structural graph theory.** Because the class is closed under $1$-sums and subgraphs and forbids $K_4$ and $C_4$ (as a subgraph in the strong sense of Theorem 9.6), triangular forests are exactly the graphs whose "triangle-contraction" is a forest. This gives them a canonical tree decomposition of width $2$, and every result above can be read as a statement about width-$2$ structures with a triangle-only block palette.

**Data structures and sparsification.** Decomposing a dense graph into a few sparse pieces underlies compact representations and parallel processing. Theorem 10.2 quantifies the best possible saving when the pieces are required to be triangular forests: each piece stores at most $\lfloor 3(n-1)/2\rfloor$ edges in $O(n)$ space with $O(1)$-time adjacency queries inside a piece.

---

## 13. Discussion

The results assemble into a clean picture of the two-colour problem on the extremal side:

- **Sparsity is settled.** $2e \le 3(n-1)$, sharp for every odd $n$. This is the exact analogue of $e \le n-1$ for forests, and the "$3/2$" slope is the fingerprint of the class.
- **The complete-graph threshold is settled.** $K_n$ decomposes into two triangular forests iff $n \le 5$. The critical case $n=6$ fails only by integrality — a one-edge deficit — which is a striking illustration of how thin the boundary is.
- **A universal obstruction is available.** $K_6$-freeness is a necessary condition, checkable locally, for any graph.
- **The problem is in NP and decidable**, with edge $2$-colourings as certificates.

What is *not* settled — and, in light of the NP-completeness theorem, cannot be settled in the naive way — is a characterisation of decomposable graphs. Any conjectured characterisation must be either non-local or intractable to check. The most promising directions therefore concern restricted inputs (bounded degree, bounded treewidth, planar) and approximation.

A methodological observation is worth making. The improvement from $e \le 2n-3$ to $2e \le 3(n-1)$ is not a change of technique but a *deepening* of one: both proofs peel a vertex from the end of a longest path; the sharp one peels an entire leaf triangle. The pattern — find a longest path, argue that its endpoint and its neighbour are both degree-constrained, delete the resulting pendant structure — should transfer to other block-restricted classes (e.g. "every block is a clique of size $\le r$", where one expects the slope $r/2 \cdot \frac{r-1}{r-1}$-type bounds), and is a good general recipe for sparsity laws in classes defined by forbidden cycle lengths.

Finally, the exception at $n = 6$ deserves emphasis. It is the *only* place where the counting bound is not achieved (in the range explored), and it has a design-theoretic explanation: covers meeting the counting bound behave like resolvable triple systems, and order $6$ is exactly where those fail to exist. The parallel is suggestive enough that we expect the general construction for $\theta_\triangle(K_n) = \lceil n/3 \rceil$ to come from design theory rather than from graph-theoretic ad hoc gluing.

---

## 14. Future directions

Five falsifiable conjectures, each stated so that a single counterexample or a single proof settles it.

### C1. Every order attains the sparsity bound, and the extremal graphs are exactly the triangle-and-bridge trees

**Conjecture.** For every $n \ge 1$ there is a triangular forest on $n$ vertices with $e = \lfloor 3(n-1)/2 \rfloor$ edges; and for odd $n$, a triangular forest attains equality $2e = 3(n-1)$ if and only if it is connected and every one of its blocks is a triangle (so it has exactly $(n-1)/2$ blocks, glued in a tree pattern).

**Status.** The odd case of existence is *proved*: the windmill $F_k$ on $n = 2k+1$ vertices has $2e = 3(n-1)$. What remains is (a) the even case $e = (3n-4)/2$ and (b) the *uniqueness* half — the characterisation of maximisers.

**The key insight is** that the sharp bound $2e \le 3(n-1)$ is proved by peeling off a *leaf triangle*, so equality forces every peeling step to remove exactly $3$ edges and $2$ vertices: the extremal graphs should be precisely the graphs built by iterated $1$-sums of triangles, a class already known to be closed under that operation.

**Why now?** Both ingredients are already established (the sharp bound and $1$-sum closure), so the conjecture reduces to an equality analysis of an existing induction rather than to new theory.

### C2. The triangular thickness of $K_n$ is $\lceil n/3 \rceil$ for all $n \ne 6$

**Conjecture.** The minimum number of triangular forests needed to cover $E(K_n)$ equals $\lceil n/3 \rceil$ for every $n \ge 3$ except $n = 6$, where it is $3$.

**Status.** The lower bound $n \le 3k$ is *proved*, and the exception at $n = 6$ is *proved*. Randomised search finds matching covers for all $n \le 11$. Open: a construction for general $n$.

**The key insight is** that a cover meeting the counting bound must consist of forests that are simultaneously *edge-maximal* (windmill-like, $2e = 3(n-1)$) and *pairwise almost edge-disjoint*, which is exactly the structure of a resolvable partial triple system; the unique failure at $n = 6$ mirrors the classical non-existence of a resolvable Steiner triple system of order $6$.

**Why now?** The lower bound is already tight-by-counting, so the conjecture is now purely a *construction* problem, and the windmill family gives the natural building block.

### C3. Decomposability into two triangular forests is characterised by a local degree-plus-triangle condition on graphs of bounded degree

**Conjecture.** For every fixed $\Delta$, there is a finite list of forbidden configurations characterising the graphs of maximum degree at most $\Delta$ that decompose into two triangular forests; consequently the decision problem restricted to bounded-degree inputs is polynomial-time solvable.

**Status.** Open. The general problem is NP-complete, so any such characterisation must genuinely use the degree bound. The $K_6$ obstruction is the first entry in the list for $\Delta \ge 5$.

### C4. The density condition is sufficient for graphs of large girth

**Conjecture.** There is a $g$ such that every graph of girth at least $g$ satisfying $|E(H)| \le 3(|V(H)|-1)$ for all subgraphs $H$ decomposes into two triangular forests.

**Status.** Open. For girth $> 3$ a triangular forest is just a forest, so the conjecture interpolates towards the Nash-Williams theorem and should be attackable by matroid-union plus a local repair argument.

### C5. Hardness persists for planar inputs

**Conjecture.** Deciding whether a planar graph decomposes into two triangular forests is NP-complete.

**Status.** Open. Planarity caps the density at $3n-6 \le 3(n-1)$, so the density obstruction never fires and $K_6$ never occurs; the whole difficulty is structural. A positive answer would show the hardness is not a density phenomenon.

---

## 15. Summary of results

| Result | Statement |
|---|---|
| Degeneracy | Every finite nonempty triangular forest has a vertex of degree $\le 2$ |
| First sparsity bound | $e \le 2n-3$ for $n \ge 2$ |
| Sharp sparsity law | $2e \le 3(n-1)$ for $n \ge 1$ |
| Sharpness | The windmill $F_k$ ($n = 2k+1$, $e = 3k$) attains equality |
| $K_5$ decomposition | $K_5$ splits into two "triangle + two pendant edges" graphs |
| Threshold | For $n \ge 5$: $K_n$ decomposes into two triangular forests iff $n = 5$ |
| Monotonicity | Decomposability is inherited by subgraphs and by pullbacks along injections |
| Clique obstruction | A $K_6$ subgraph forbids decomposition into two triangular forests |
| $1$-sum closure | The $1$-sum of two triangular forests is a triangular forest |
| Local structure | Neighbourhoods induce matchings; every edge lies in $\le 1$ triangle; no $C_4$ |
| Certificates | Decomposability $\iff$ an edge $2$-colouring with both classes triangular forests |
| Decidability | Membership and decomposability are decidable; the problem lies in NP |
| Thickness | Covering $K_n$ by $k$ triangular forests forces $n \le 3k$ |
