# Monotone Forcing Dynamics and Local Triangle Structure in Claw-Free Cubic Graphs

**Aristotle**  
**July 16, 2026**

## Abstract

Zero forcing is a deterministic propagation process on a finite simple graph. Beginning with a colored vertex set, a colored vertex may force an uncolored neighbor precisely when that neighbor is its unique uncolored neighbor. This paper develops the finite-state foundations needed for extremal investigations of zero forcing in claw-free cubic graphs. We prove that a legal move adds exactly one vertex, that reachability by forcing sequences is monotone under inclusion and cardinality, and that forcing reachability is antisymmetric. We establish a certificate-composition principle, prove that the zero forcing number is attained, and derive upper bounds from explicit certificates. For every graph without isolated vertices, coloring all but one suitably chosen vertex gives the bound $Z(G)\le |V(G)|-1$. We prove sharpness on nontrivial complete graphs: $Z(K_n)=n-1$. Finally, we show that every vertex in a claw-free cubic graph lies in a triangle. This local structure excludes isolated vertices and yields the general bound $Z(G)\le |V(G)|-1$ for finite claw-free cubic graphs. We also present algorithms for validating forcing certificates, computing the zero forcing number by exhaustive search, and detecting the local triangle witnesses guaranteed by claw-freeness and cubicity.

## 1. Introduction

Let $G=(V,E)$ be a finite simple graph. Zero forcing begins from a set $S\subseteq V$ of colored vertices, with all other vertices uncolored. The color-change rule is local and deterministic: a colored vertex with exactly one uncolored neighbor may force that neighbor to become colored. A set from which repeated legal forces color all vertices is called a zero forcing set, and the minimum size of such a set is the zero forcing number $Z(G)$.

The invariant translates dynamic propagation into a static optimization problem. Its certificates are explicit: an initial set together with an ordered list of legal forces. This makes zero forcing suitable for network propagation, controllability-style questions, and graph-constrained linear algebra. It also creates a natural meeting point between algorithms and extremal structure. Upper bounds arise by constructing certificates; lower bounds arise by showing that smaller initial sets must encounter ambiguity.

Our focus is the foundational behavior of the process and its first consequences for claw-free cubic graphs. A cubic graph has degree three at every vertex. A claw is an induced copy of $K_{1,3}$, consisting of a center adjacent to three pairwise nonadjacent leaves. In a claw-free cubic graph, the three neighbors of any vertex cannot all be mutually nonadjacent. This elementary observation forces every vertex into a triangle and supplies the local structure from which finer decompositions may be built.

The principal contributions are as follows.

1. A single legal force strictly increases the colored-set cardinality by one and preserves every previously colored vertex.
2. Forcing reachability is monotone under inclusion and cardinality, and it is antisymmetric.
3. Forcing certificates compose through intermediate colored sets.
4. The minimum defining $Z(G)$ is achieved, and every certificate yields an upper bound.
5. Every finite graph without isolated vertices obeys $Z(G)\le |V|-1$.
6. Every complete graph $K_n$ with $n\ge 2$ satisfies $Z(K_n)=n-1$.
7. Every vertex of a claw-free cubic graph lies in a triangle; consequently, every finite claw-free cubic graph satisfies $Z(G)\le |V|-1$.

These results are deliberately foundational. They isolate the order-theoretic and local-structural mechanisms required for later arguments involving triangle and diamond blocks, independence number, contraction multigraphs, and Hamiltonian certificates.

## 2. Definitions and notation

A **finite simple graph** is a pair $G=(V,E)$ in which $V$ is a finite set and $E$ is a set of unordered pairs of distinct vertices. We write $u\sim v$ when $u$ and $v$ are adjacent. The open neighborhood of $u$ is

$$
N_G(u)=\{v\in V:u\sim v\}.
$$

The degree of $u$ is $\deg_G(u)=|N_G(u)|$. The graph is **cubic** when

$$
\deg_G(u)=3
$$

for every $u\in V$.

Let $S\subseteq V$ be colored. A pair $(u,w)$ defines a **legal force**, denoted $u\to w$, if

$$
u\in S,\qquad w\notin S,\qquad u\sim w,
$$

and

$$
N_G(u)\setminus S=\{w\}.
$$

The colored set after this force is $S\cup\{w\}$. We write $S\leadsto T$ if there is a finite sequence, possibly empty, of legal forces that begins at $S$ and ends at $T$. Thus $S\leadsto S$ always holds.

A set $S\subseteq V$ is a **zero forcing set** if $S\leadsto V$. The **zero forcing number** is

$$
Z(G)=\min\{|S|:S\subseteq V\text{ and }S\leadsto V\}.
$$

The collection over which the minimum is taken is nonempty because $V\leadsto V$ by the empty sequence.

A **claw** is an induced subgraph isomorphic to $K_{1,3}$. Equivalently, a graph contains a claw if there are distinct vertices $v,a,b,c$ such that $v$ is adjacent to each of $a,b,c$, while $a,b,c$ are pairwise nonadjacent. A graph is **claw-free** if no such quadruple exists. In local form, for any vertex $v$ and any three distinct neighbors $a,b,c$ of $v$, at least one of $a\sim b$, $a\sim c$, or $b\sim c$ holds.

A **triangle through $v$** is a triple of vertices $v,a,b$ with all three edges $va$, $vb$, and $ab$ present.

## 3. Growth and monotonicity of forcing sequences

We begin with the exact effect of one move.

### Theorem 3.1 (single-step growth)

If a legal force transforms a colored set $S$ into $T$, then there is a vertex $w\notin S$ such that

$$
T=S\cup\{w\}.
$$

In particular,

$$
S\subseteq T
\qquad\text{and}\qquad
|T|=|S|+1.
$$

**Proof sketch.** By definition, a legal force colors one specified uncolored vertex $w$ and does not uncolor any vertex. Hence the resulting set is exactly $S\cup\{w\}$. Since $w\notin S$, adjoining it increases cardinality by one. $\square$

The theorem shows that cardinality is a rank function for the dynamics. Its iteration gives global monotonicity.

### Theorem 3.2 (sequence monotonicity)

If $S\leadsto T$, then

$$
S\subseteq T
\qquad\text{and}\qquad
|S|\le |T|.
$$

**Proof sketch.** Induct on the length of a forcing sequence. The empty sequence gives equality. For a nonempty sequence, apply the induction hypothesis up to the penultimate state, then apply Theorem 3.1 to the final move. Transitivity of inclusion gives $S\subseteq T$, and cardinality monotonicity for finite sets gives $|S|\le |T|$. $\square$

### Corollary 3.3 (equal-cardinality rigidity)

If $S\leadsto T$ and $|S|=|T|$, then $S=T$.

**Proof sketch.** Theorem 3.2 gives $S\subseteq T$. Two finite sets related by inclusion and having equal cardinality are equal. $\square$

### Theorem 3.4 (antisymmetry of forcing reachability)

If $S\leadsto T$ and $T\leadsto S$, then $S=T$.

**Proof sketch.** Sequence monotonicity gives both $|S|\le |T|$ and $|T|\le |S|$, hence equal cardinalities. Corollary 3.3 then implies equality. $\square$

Because reachability is reflexive by the empty sequence, transitive by concatenation, and antisymmetric by Theorem 3.4, it defines a partial order on the reachable colored states. Moreover, every nontrivial step raises cardinality exactly once. Therefore the directed state graph has no nontrivial directed cycle and every forcing sequence contains at most $|V|-|S|$ genuine moves.

## 4. Composition and extremal certificates

The transitivity of reachability has a direct certificate interpretation.

### Theorem 4.1 (certificate composition)

Suppose $S\leadsto T$ and $T$ is a zero forcing set. Then $S$ is a zero forcing set.

**Proof sketch.** Since $T$ is zero forcing, there is a sequence $T\leadsto V$. Concatenate it after the sequence $S\leadsto T$ to obtain $S\leadsto V$. $\square$

This theorem permits modular constructions. A proof may first force a strategically chosen intermediate configuration and then use any certificate already known from that configuration.

### Theorem 4.2 (attainment of the zero forcing number)

For every finite simple graph $G$, there exists a zero forcing set $S$ such that

$$
|S|=Z(G).
$$

**Proof sketch.** The power set of $V$ is finite. Its subcollection of zero forcing sets is nonempty because $V$ itself is zero forcing. The finite, nonempty set of their cardinalities therefore has a least element, realized by at least one zero forcing set. $\square$

### Proposition 4.3 (certificate upper bound)

If $S$ is a zero forcing set of $G$, then

$$
Z(G)\le |S|.
$$

**Proof sketch.** The quantity $Z(G)$ is the minimum cardinality among all zero forcing sets, and $S$ is one member of that family. $\square$

The proposition is the standard route to upper bounds: construct an initial set and a legal forcing sequence, then count the initial vertices.

## 5. Co-singleton certificates and graphs without isolated vertices

A vertex is isolated when it has no neighbors. When a chosen vertex is not isolated, coloring every other vertex produces a one-step certificate.

### Theorem 5.1 (co-singleton certificate)

Let $w\in V$. If $w$ has a neighbor $u$, then

$$
V\setminus\{w\}
$$

is a zero forcing set.

**Proof sketch.** Initially only $w$ is uncolored. Its neighbor $u$ is colored, and every neighbor of $u$ other than $w$ is colored because every vertex except $w$ is colored. Thus $w$ is the unique uncolored neighbor of $u$, so $u\to w$ is legal. One move colors all of $V$. $\square$

### Corollary 5.2 (elementary non-isolation bound)

If a finite graph $G$ has no isolated vertices and $V$ is nonempty, then

$$
Z(G)\le |V|-1.
$$

**Proof sketch.** Choose any $w\in V$. By non-isolation it has a neighbor, so Theorem 5.1 makes $V\setminus\{w\}$ zero forcing. Its cardinality is $|V|-1$, and Proposition 4.3 gives the bound. $\square$

The hypothesis is natural for this certificate. An isolated vertex can never be forced by another vertex and must be colored initially. The theorem does not claim the bound is optimal for all graphs without isolated vertices; paths, for example, may have zero forcing number one. It supplies a universal baseline.

## 6. Exact zero forcing number of complete graphs

The complete graph demonstrates that the preceding universal bound can be sharp. Let $K_n$ denote the complete graph on $n$ vertices.

### Lemma 6.1 (forces in a complete graph)

Suppose a legal force is available from a colored set $S$ in $K_n$. Then exactly one vertex is uncolored, and therefore

$$
|S|=n-1.
$$

**Proof sketch.** Let $u\to w$ be legal. Every vertex distinct from $u$ is adjacent to $u$. Legality says $w$ is the unique uncolored neighbor of $u$. Since $u$ is colored, every vertex other than $w$ must therefore be colored. $\square$

### Lemma 6.2 (complete-graph lower bound)

Every zero forcing set $S$ of $K_n$ satisfies

$$
|S|\ge n-1.
$$

**Proof sketch.** If $S=V$, the claim is immediate. Otherwise a successful forcing sequence must have a first move. Lemma 6.1 applied to that move says the initial colored set already has size $n-1$. Equivalently, if at least two vertices are uncolored, each colored vertex is adjacent to both and therefore has more than one uncolored neighbor, so no first force exists. $\square$

### Theorem 6.3 (complete-graph formula)

For every $n\ge 2$,

$$
Z(K_n)=n-1.
$$

**Proof sketch.** The lower bound is Lemma 6.2. For the upper bound, choose any vertex $w$. Since $n\ge 2$, it has a neighbor, and Theorem 5.1 shows that the other $n-1$ vertices form a zero forcing set. The two bounds agree. $\square$

The formula highlights a defining feature of zero forcing: dense connectivity may obstruct propagation by creating ambiguity. In $K_n$, fewer than $n-1$ colored vertices leave at least two possible uncolored targets for every colored vertex.

## 7. Local structure of claw-free cubic graphs

We now combine the degree condition with the forbidden induced subgraph condition.

### Theorem 7.1 (local triangle theorem)

Let $G$ be a claw-free cubic graph. Every vertex $v\in V$ lies in a triangle. More explicitly, for each $v$ there exist vertices $a,b$ such that

$$
v\sim a,\qquad v\sim b,\qquad a\sim b.
$$

**Proof sketch.** Cubicity gives exactly three distinct neighbors $a,b,c$ of $v$. If these three vertices were pairwise nonadjacent, the subgraph induced by $\{v,a,b,c\}$ would be a claw centered at $v$. Since $G$ is claw-free, at least one pair among $a,b,c$ is adjacent. Relabel that pair as $a,b$. Then $v,a,b$ form a triangle. $\square$

The argument is local but strong: the neighborhood of every vertex contains an edge. In particular, every vertex has a neighbor, a fact already implied by cubicity but here witnessed as part of a triangle. The triangle conclusion is the first step toward viewing claw-free cubic graphs as assemblies of small dense blocks rather than arbitrary degree-three networks.

### Corollary 7.2 (elementary claw-free cubic bound)

If $G$ is a finite claw-free cubic graph with nonempty vertex set, then

$$
Z(G)\le |V|-1.
$$

**Proof sketch.** Choose a vertex $w$. Theorem 7.1 places $w$ in a triangle, so $w$ has a neighbor. Indeed the same is true for every vertex. Corollary 5.2 now applies. $\square$

The numerical bound uses only non-isolation once the local theorem has been established. Its importance lies in providing a sound baseline and a reusable certificate: color every vertex except one and use an edge of a triangle through that vertex for the final force.

## 8. Algorithms

### 8.1 Validating a proposed forcing certificate

Input consists of a graph $G$, an initial set $S$, and an ordered list of proposed forces $(u_i,w_i)$. Maintain the current colored set $C$, initially $S$. For each pair, verify that $u_i\in C$, $w_i\notin C$, $u_i\sim w_i$, and $N_G(u_i)\setminus C=\{w_i\}$. If so, insert $w_i$; otherwise reject. Accept as a zero forcing certificate exactly when the final set is $V$.

With adjacency lists and set membership in expected constant time, checking one force costs $O(\deg(u_i))$. Thus a sequence costs

$$
O\!\left(\sum_i \deg(u_i)\right),
$$

which is $O(|V|\Delta)$ because there are at most $|V|-|S|$ moves and $\Delta$ is maximum degree. In cubic graphs this becomes $O(|V|)$.

### 8.2 Deterministic propagation from an initial set

To test whether a set is zero forcing, repeatedly scan colored vertices and choose any vertex having exactly one uncolored neighbor. Perform that force and continue. If all vertices become colored, return the certificate; if a complete scan finds no legal force, report failure.

The choice among simultaneously available forces does not endanger already obtained progress because colored sets only increase. A simple rescanning implementation costs $O(|V||E|)$ in the worst case. A queue storing vertices whose number of uncolored neighbors may have changed improves practical performance and admits near-linear implementations.

### 8.3 Exact computation by subset enumeration

Enumerate subsets $S\subseteq V$ in nondecreasing cardinality. Run deterministic propagation on each. The first cardinality for which a zero forcing set is found equals $Z(G)$ by definition and Theorem 4.2. The worst-case search is exponential, involving up to $2^{|V|}$ subsets. Symmetry reduction, lower bounds, and cached intermediate certificates can reduce the explored space.

### 8.4 Triangle witnesses in claw-free cubic graphs

For each vertex $v$, list its three neighbors and inspect the three possible pairs. In a claw-free cubic graph at least one pair is adjacent by Theorem 7.1. Returning such a pair provides an explicit triangle through $v$. Since each vertex has degree three, this takes constant work per vertex with adjacency-set queries and $O(|V|)$ work overall.

## 9. Examples and applications

For the path $P_n$ with $n\ge 2$, coloring one endpoint triggers a chain of unique-neighbor forces, so $Z(P_n)=1$. This illustrates efficient propagation in a sparse, directional geometry.

For the cycle $C_n$ with $n\ge 3$, two adjacent colored vertices can force outward around the cycle, giving $Z(C_n)\le 2$. A single colored vertex initially has two uncolored neighbors, so no move is possible; hence $Z(C_n)=2$.

For $K_n$, Theorem 6.3 gives $Z(K_n)=n-1$. This contrasts sharply with paths and cycles and shows that edge density alone is not a measure of forcing efficiency.

The triangular prism is a claw-free cubic graph on six vertices. Every vertex lies in one of its two triangular faces, as predicted by Theorem 7.1. The general theorem gives $Z(G)\le 5$, while direct propagation finds smaller certificates. The gap between the universal baseline and graph-specific values motivates sharper arguments based on the organization of triangles.

In network terms, a legal force is a step with no local ambiguity. In matrix terms, the graph prescribes which coordinates may interact, while a unique unresolved neighbor permits deterministic elimination. In monitoring problems, a forcing set serves as a placement certificate from which the entire network can be resolved under the rule.

## 10. Discussion

The forcing relation has more structure than an arbitrary transition system. It is ranked by cardinality, monotone by inclusion, acyclic, and compositional. These properties justify dynamic programming and certificate reuse. They also clarify what an upper-bound proof must contain: an initial set and a sequence of uniquely determined local resolutions.

For claw-free cubic graphs, the local triangle theorem converts a negative condition into a positive witness. “No induced claw” might appear merely prohibitive, but together with degree three it says that each neighborhood contains an edge. The resulting triangle cover is not necessarily disjoint, and understanding its overlaps is essential for stronger global bounds. Diamonds—two triangles sharing an edge—are natural next blocks, while contractions can encode how blocks are connected.

The present bound $Z(G)\le |V|-1$ is intentionally elementary. It follows from a one-step co-singleton certificate and is attained by complete graphs, though complete graphs are cubic only at order four. Sharper bounds for broader claw-free cubic families require using many triangles simultaneously rather than using one triangle merely to witness a neighbor.

## 11. Future work

The next structural objective is to relate the local claw-free condition to the standard induced-subgraph formulation explicitly and then develop a triangle-and-diamond decomposition for connected claw-free cubic graphs. Once these blocks are available, one can define the independence number $\alpha(G)$ and investigate lower and upper bounds connecting $Z(G)$ with $\alpha(G)$.

A further step is to encode contraction multigraphs, where parallel edges may naturally arise after blocks are contracted. Hamiltonian cycles in such contractions should support explicit forcing certificates. A division-free target inequality is

$$
2Z(G)\le T+2D+4,
$$

where $T$ and $D$ count triangle and diamond blocks in the relevant decomposition. Another objective is to characterize exceptional graph families attaining

$$
Z(G)=\alpha(G)+1.
$$

Finally, exhaustive generation of small claw-free cubic graphs can test candidate decomposition statements and certificate constructions before general proofs are attempted.

## 12. Conclusion

Zero forcing turns a rule of local uniqueness into a global graph invariant. A legal move adds exactly one vertex; sequences grow monotonically; equal-sized reachable states coincide; and mutual reachability forces equality. Certificates concatenate, minimum certificates exist, and every explicit certificate supplies an upper bound. Coloring all but one non-isolated vertex proves $Z(G)\le |V|-1$, and complete graphs show that this bound can be exact. In claw-free cubic graphs, every vertex lies in a triangle, yielding the same universal bound and exposing the local clustered geometry needed for stronger results.
