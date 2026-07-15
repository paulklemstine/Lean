# Toughness Under Edge Addition and Exact Induced Thresholds in Complete Graphs

## Abstract

We study two elementary but complementary extremal principles for finite simple graphs. The first concerns component-count toughness. For a vertex set $S$, let $c_G(S)$ be the number of connected components remaining after $S$ is deleted from a graph $G$. A graph is $1$-tough when every deletion that disconnects it satisfies $c_G(S)\le |S|$. We prove that this property is monotone under edge addition: if $G$ is a spanning subgraph of $H$, then $c_H(S)\le c_G(S)$ for every $S$, and consequently $1$-toughness of $G$ implies $1$-toughness of $H$. We then derive the structural consequence that every $1$-tough graph of order at least three is $2$-connected. The second principle classifies induced containment in complete hosts. A finite pattern $F$ is an induced subgraph of $K_n$ if and only if $F$ is complete and $|V(F)|\le n$. Equivalently, $K_n$ is induced-$F$-free exactly when $F$ is noncomplete or $n<|V(F)|$. This yields a sharp order threshold for complete patterns and an absolute obstruction for noncomplete patterns. We give proofs, algorithms, examples, and applications, and discuss extensions to defective complete hosts, complete multipartite hosts, and toughness-constrained graph classes.

## 1. Introduction

Robustness and pattern containment are two basic concerns in graph theory. Robustness asks how a graph responds to the deletion of vertices. Pattern containment asks whether a prescribed graph can be represented inside a host while preserving specified relationships. Although both questions are controlled by adjacency, edge addition affects them in fundamentally different ways.

For robustness measured by component counts, an additional edge is beneficial or neutral. After any fixed vertex deletion, new edges may join surviving components but cannot split them. This gives an order-theoretic viewpoint: graph properties defined by upper bounds on component counts are naturally upward closed in the spanning-subgraph order.

Induced containment is subtler. An induced embedding must preserve edges and nonedges. Adding an edge may destroy an induced copy by filling a nonedge required by the pattern. Complete graphs, which sit at the maximum of the edge-inclusion order, therefore provide a rigid boundary case: every selected vertex set induces another complete graph. This observation leads to an exact classification rather than merely a necessary condition.

The principal results are as follows.

1. **Component monotonicity.** If finite simple graphs $G$ and $H$ have the same vertex set and $E(G)\subseteq E(H)$, then for every vertex set $S$,

   $$
   c(H-S)\le c(G-S).
   $$

2. **Toughness monotonicity.** Under the same hypothesis, if $G$ is $1$-tough, then $H$ is $1$-tough.

3. **Connectivity consequence.** Every $1$-tough graph with at least three vertices is $2$-connected.

4. **Complete-host classification.** For every finite graph $F$ and nonnegative integer $n$,

   $$
   F\text{ is an induced subgraph of }K_n
   \quad\Longleftrightarrow\quad
   F\text{ is complete and }|V(F)|\le n.
   $$

5. **Exact freeness threshold.** Consequently,

   $$
   K_n\text{ is induced-}F\text{-free}
   \quad\Longleftrightarrow\quad
   F\text{ is noncomplete or }n<|V(F)|.
   $$

The arguments are elementary, but their combination is useful. The first three results convert a deletion inequality into an upward-closed structural class with a guaranteed connectivity level. The last two replace a potentially expensive induced-subgraph search in a complete host with a completeness test and a cardinality comparison.

## 2. Preliminaries

Throughout, a graph is finite, simple, and undirected. For a graph $G$, its vertex and edge sets are denoted by $V(G)$ and $E(G)$. Its order is $v(G)=|V(G)|$.

### 2.1. Vertex deletion and components

For $S\subseteq V(G)$, the graph $G-S$ is the induced subgraph on $V(G)\setminus S$. Let

$$
c_G(S)=c(G-S)
$$

be the number of connected components of the survivor. If no vertices survive, we take the component count to be $0$.

A vertex $x$ is a **cut vertex** if $G-x$ has more connected components than $G$. For a connected graph, this is equivalent to $G-x$ being disconnected.

A graph is **$2$-connected** if it has at least three vertices, is connected, and has no cut vertex. Equivalently, deleting any single vertex leaves a connected graph.

### 2.2. Toughness

Let $t>0$. A noncomplete graph $G$ is **$t$-tough** if every vertex set $S$ for which $G-S$ is disconnected satisfies

$$
|S|\ge t\,c_G(S).
$$

Complete graphs are customarily assigned infinite toughness and therefore satisfy every finite toughness requirement. For $t=1$, the condition becomes

$$
c_G(S)\le |S|
$$

whenever $c_G(S)>1$. We call this **$1$-toughness**.

The restriction to disconnecting sets is essential. If $G-S$ is connected, then $c_G(S)=1$, and requiring $1\le |S|$ would incorrectly reject the empty deletion set. Toughness measures fragmentation, not the mere existence of a surviving component.

An equivalent numerical invariant for a connected noncomplete graph is

$$
\tau(G)=\min_{S:\,c_G(S)>1}\frac{|S|}{c_G(S)}.
$$

Then $G$ is $t$-tough exactly when $\tau(G)\ge t$.

### 2.3. Spanning subgraphs and the edge order

If $G$ and $H$ have the same vertex set and $E(G)\subseteq E(H)$, then $G$ is a **spanning subgraph** of $H$, and $H$ is a **spanning supergraph** of $G$. This relation partially orders all graphs on a fixed vertex set.

A property $\mathcal P$ is **monotone under edge addition** if $G\in\mathcal P$ and $E(G)\subseteq E(H)$ imply $H\in\mathcal P$.

### 2.4. Induced embeddings

An **induced embedding** of a graph $F$ into a graph $G$ is an injective map

$$
\varphi:V(F)\to V(G)
$$

such that for all distinct $x,y\in V(F)$,

$$
xy\in E(F)\quad\Longleftrightarrow\quad
\varphi(x)\varphi(y)\in E(G).
$$

The forward implication preserves edges; the reverse implication reflects edges and therefore preserves nonedges. If such a map exists, $F$ is an **induced subgraph** of $G$. A graph $G$ is **induced-$F$-free** if no such map exists.

The complete graph on $n$ vertices is denoted by $K_n$. Every pair of distinct vertices in $K_n$ is adjacent.

## 3. Component counts are antitone under edge addition

We begin with the fundamental comparison.

### Lemma 3.1. Path preservation

Let $G$ and $H$ be graphs on the same vertex set with $E(G)\subseteq E(H)$. For any $S\subseteq V(G)$ and any surviving vertices $x,y\notin S$, if $x$ and $y$ are connected in $G-S$, then they are connected in $H-S$.

**Proof sketch.** A path from $x$ to $y$ in $G-S$ uses only vertices outside $S$ and edges of $G$. Every such edge belongs to $H$, so the same vertex sequence is a path in $H-S$.

### Theorem 3.2. Component-Count Monotonicity

Let $G$ be a spanning subgraph of $H$. Then for every $S\subseteq V(G)$,

$$
c_H(S)\le c_G(S).
$$

**Proof sketch.** By Lemma 3.1, every connected component of $G-S$ lies inside a connected component of $H-S$. Thus the partition of surviving vertices into $H-S$ components is obtained by merging zero or more blocks of the partition into $G-S$ components. Merging blocks cannot increase their number.

The terminology “antitone” is appropriate for the function $G\mapsto c_G(S)$: as the edge set increases, the component count decreases. Properties expressed as upper bounds on this antitone quantity are therefore candidates for upward closure.

### Corollary 3.3. Monotonicity of $t$-toughness

Fix $t>0$. If $G$ is $t$-tough and is a spanning subgraph of $H$, then $H$ is $t$-tough.

**Proof sketch.** Let $S$ disconnect $H$, so $c_H(S)>1$. Theorem 3.2 gives $c_G(S)\ge c_H(S)>1$, so $S$ also disconnects $G$. Toughness of $G$ yields

$$
|S|\ge t\,c_G(S)\ge t\,c_H(S),
$$

which is precisely the required inequality for $H$.

### Corollary 3.4. Edge-Addition Monotonicity of $1$-toughness

If $G$ is $1$-tough and $H$ is obtained from $G$ by adding edges on the same vertex set, then $H$ is $1$-tough.

**Proof sketch.** Apply Corollary 3.3 with $t=1$. Explicitly, whenever $H-S$ is disconnected,

$$
c_H(S)\le c_G(S)\le |S|.
$$

### Remark 3.5. Monotonicity of the toughness number

For connected graphs on a fixed vertex set, Theorem 3.2 also implies

$$
\tau(H)\ge \tau(G)
$$

when $G$ is a spanning subgraph of $H$, with the convention that complete graphs have infinite toughness. For each separating set $S$ that remains relevant in $H$, its denominator can only decrease, so its ratio $|S|/c_H(S)$ can only increase. Some separating sets may cease to separate at all, removing potential minimizers.

## 4. From $1$-toughness to $2$-connectivity

The toughness inequality immediately constrains deletion sets of cardinality one.

### Lemma 4.1. Connectivity of nontrivial tough graphs

A $1$-tough graph is connected under the standard convention that the empty set is tested whenever its deletion leaves more than one component.

**Proof sketch.** If $G$ were disconnected, then $S=\varnothing$ would satisfy $c_G(S)>1$. The toughness inequality would demand

$$
c_G(\varnothing)\le |\varnothing|=0,
$$

contradicting $c_G(\varnothing)>1$.

### Lemma 4.2. Absence of cut vertices

A $1$-tough graph has no cut vertex.

**Proof sketch.** By Lemma 4.1, $G$ is connected. If $v$ were a cut vertex, then $G-v$ would have at least two components. Taking $S=\{v\}$, $1$-toughness would give

$$
2\le c_G(\{v\})\le |\{v\}|=1,
$$

which is impossible.

### Theorem 4.3. Toughness–Connectivity Theorem

Every $1$-tough graph of order at least three is $2$-connected.

**Proof sketch.** Lemma 4.1 gives connectivity and Lemma 4.2 excludes cut vertices. Together with the order assumption $v(G)\ge 3$, these are exactly the defining conditions for $2$-connectivity.

### Corollary 4.4. Minimum degree

Every $1$-tough graph of order at least three has minimum degree at least $2$.

**Proof sketch.** A $2$-connected graph cannot contain a vertex of degree $0$ or $1$. A degree-zero vertex contradicts connectivity. If a vertex $x$ has unique neighbor $y$, deleting $y$ isolates $x$ from all other surviving vertices, making $y$ a cut vertex when the graph has at least three vertices.

### Sharpness discussion

The conclusion naturally stops at $2$-connectivity. The proof uses only singleton deletion sets and therefore detects cut vertices but not necessarily separating pairs. The cycle $C_n$ for $n\ge 4$ illustrates the distinction: it is $1$-tough and $2$-connected, but deleting two suitable nonadjacent vertices disconnects it, so it is not $3$-connected. Thus $1$-toughness alone cannot imply $3$-connectivity.

To check the toughness claim for $C_n$, delete a set $S$. If $S$ is empty, the cycle remains connected. If $S$ is nonempty and not all vertices are deleted, the surviving components are maximal runs of undeleted consecutive vertices around the cycle. Every such run must be preceded by a deleted vertex, giving an injection from components to deleted vertices and hence $c(C_n-S)\le |S|$.

## 5. Exact induced containment in complete hosts

We now turn from deletion resilience to exact pattern realization.

### Lemma 5.1. Induced subgraphs of complete graphs are complete

Every induced subgraph of a complete graph is complete.

**Proof sketch.** Select any subset $U$ of vertices of $K_n$. Any two distinct vertices of $U$ are adjacent in $K_n$, and induced subgraphs retain all host edges whose endpoints are selected. Thus the induced graph on $U$ contains every possible edge.

### Lemma 5.2. Cardinality obstruction

If a finite graph $F$ embeds into $K_n$, induced or otherwise, then $v(F)\le n$.

**Proof sketch.** An embedding is injective, so it maps $v(F)$ distinct pattern vertices to $v(F)$ distinct host vertices. The host has only $n$ vertices.

### Theorem 5.3. Complete-Host Induced-Containment Theorem

For every finite simple graph $F$ and every nonnegative integer $n$, the following are equivalent:

1. $F$ is an induced subgraph of $K_n$;
2. $F$ is complete and $v(F)\le n$.

**Proof sketch.** Suppose first that $F$ has an induced embedding into $K_n$. By Lemma 5.2, $v(F)\le n$. For distinct $x,y\in V(F)$, their images are distinct and therefore adjacent in $K_n$. Since the embedding reflects adjacency, $x$ and $y$ must be adjacent in $F$. Hence $F$ is complete.

Conversely, suppose $F$ is complete and $v(F)\le n$. Choose an injection from $V(F)$ into $V(K_n)$. Every distinct pair in $F$ is adjacent, and every distinct image pair in $K_n$ is adjacent. Since $F$ has no nonedges between distinct vertices, the injection preserves and reflects adjacency, so it is induced.

### Corollary 5.4. Complete-pattern threshold

For integers $r,n\ge 0$,

$$
K_r\text{ is an induced subgraph of }K_n
\quad\Longleftrightarrow\quad
r\le n.
$$

Thus the least complete host containing an induced $K_r$ is exactly $K_r$ itself.

### Corollary 5.5. Exact induced-freeness dichotomy

For every finite graph $F$,

$$
K_n\text{ is induced-}F\text{-free}
\quad\Longleftrightarrow\quad
F\text{ is noncomplete or }n<v(F).
$$

**Proof sketch.** Negate the equivalence in Theorem 5.3 and apply De Morgan's law:

$$
\neg(F\text{ complete and }v(F)\le n)
$$

is equivalent to $F$ being noncomplete or $n<v(F)$.

### Examples

1. **Paths.** The path $P_3$ on three vertices is noncomplete, so no $K_n$ contains an induced $P_3$. Although any three vertices of $K_n$ contain the two path edges, they also contain the third edge, which violates inducedness.

2. **Cycles.** For $r\ge 4$, the cycle $C_r$ is noncomplete. It is therefore absent as an induced subgraph from every complete host, regardless of host order.

3. **Cliques.** The triangle $K_3$ is induced in $K_n$ exactly for $n\ge 3$. More generally, $K_r$ appears at the sharp threshold $n=r$.

4. **Empty patterns.** The graph on zero vertices is complete by vacuity and embeds into every $K_n$. The graph on one vertex is likewise complete and embeds exactly when $n\ge 1$.

## 6. Algorithms

The structural results lead to direct algorithms.

### 6.1. Complete-host induced-containment decision

**Input:** A finite pattern graph $F$ with $r$ vertices and an integer $n\ge 0$.

**Output:** Whether $F$ is an induced subgraph of $K_n$.

**Method:**

1. If $r>n$, return false.
2. Inspect every unordered pair of distinct vertices of $F$.
3. If any pair is nonadjacent, return false.
4. Otherwise return true.

With an adjacency matrix, the algorithm inspects $\binom r2$ entries and runs in $O(r^2)$ time using $O(1)$ auxiliary space. With adjacency lists and stored degrees, completeness can be tested by checking that every degree equals $r-1$, in $O(r+|E(F)|)$ time. This replaces naive induced-subgraph enumeration, which might inspect $\binom nr$ vertex subsets.

### 6.2. Exhaustive $1$-toughness testing

For a graph $G$ of order $q$, a direct test enumerates all subsets $S\subseteq V(G)$. For each $S$, compute $c_G(S)$ by breadth-first or depth-first search in $O(q+|E(G)|)$ time. If $c_G(S)>1$ and $c_G(S)>|S|$, report a violating deletion set. If none exists, report that $G$ is $1$-tough.

The worst-case complexity is

$$
O\bigl(2^q(q+|E(G)|)\bigr),
$$

with polynomial working memory beyond the subset enumeration. The exponential cost reflects the global nature of toughness. Nevertheless, the algorithm is practical for small examples and produces explicit certificates of failure.

### 6.3. A necessary linear-time filter

Theorem 4.3 yields a quick rejection test. Run a depth-first search to determine whether $G$ is connected and has a cut vertex. If $G$ is disconnected or has a cut vertex, then it is not $1$-tough. This takes $O(q+|E(G)|)$ time. Passing the test is not sufficient: $2$-connected graphs can still fail $1$-toughness after larger deletion sets.

### 6.4. Reusing certificates under edge addition

If exhaustive testing has established that $G$ is $1$-tough, no new component enumeration is required for a spanning supergraph $H$. Corollary 3.4 transfers the certificate conceptually: every deletion outcome in $H$ has no more components than the corresponding outcome in $G$. This can substantially reduce repeated testing in incremental network design.

## 7. Applications and interpretation

### 7.1. Infrastructure resilience

Vertices may represent stations, routers, substations, or transfer hubs. The inequality $c_G(S)\le |S|$ says that a failure set cannot create more surviving islands than the number of failed sites. Theorem 4.3 guarantees the absence of a single articulation point, while Corollary 3.4 ensures that adding links preserves the guarantee.

Toughness should not be confused with capacity, latency, or probabilistic reliability. It is a topological worst-case measure. Its advantage is interpretability: a violating set $S$ directly identifies a concentrated vulnerability and quantifies the resulting fragmentation.

### 7.2. Biological and social networks

In an interaction network, a cut vertex represents a single entity mediating all communication between otherwise separated modules. $1$-toughness forbids this architecture. The stronger component inequality constrains coordinated failures involving several entities. Monotonicity models the addition of verified interactions: such additions cannot worsen component-count resilience, even if they alter other properties such as modularity.

### 7.3. Motif realization

Induced subgraphs are appropriate when both interactions and noninteractions matter. The complete-host theorem warns that maximal density eliminates every motif containing a required nonedge. A complete communication cluster can realize induced cliques of all feasible sizes, but no induced path of length two, no induced cycle of length at least four, and no other noncomplete pattern.

This gives a design tradeoff. Edge addition is favorable for toughness but may be unfavorable for preserving sparse induced motifs. A network intended to be both resilient and modular must balance these objectives rather than treating density as universally beneficial.

## 8. Discussion

The results can be summarized in terms of order and extremality. Fix a vertex set. The family of graphs is partially ordered by edge inclusion. For each deletion set $S$, the component-count function is antitone in this order. Therefore every property asserting uniform upper bounds on these counts is upward closed. $1$-toughness is one such property, and its upward closure is not an accident of a particular proof but a consequence of the coordinate system used to define it.

Complete graphs are maximal elements of the same order. Their induced subgraphs inherit maximal density, so they admit exactly complete patterns. In this setting, cardinality is the only remaining variable. For a fixed complete pattern $K_r$, containment switches from false to true at $n=r$. For a fixed noncomplete pattern, it remains false for all $n$.

The contrast also clarifies why ordinary and induced containment behave differently. Every graph with at most $n$ vertices is an ordinary subgraph of $K_n$, because unwanted host edges may be ignored. Only complete graphs with at most $n$ vertices are induced subgraphs, because unwanted edges cannot be ignored. Adjacency reflection, rather than adjacency preservation, carries the substantive content.

Likewise, $2$-connectivity is necessary but not sufficient for $1$-toughness. The implication from toughness to connectivity uses only singleton deletions. The reverse would require every larger deletion set to satisfy a quantitative bound, information that cut-vertex testing does not capture.

## 9. Future directions

### 9.1. Stability under sparse edge deletion

For a finite pattern $F$, one may ask for the least edge deficit $d(F)$ such that every sufficiently large graph obtained from a complete graph by deleting fewer than $d(F)$ edges contains an induced copy of $F$, or determine that no such deficit exists. The complete-host theorem is the zero-defect boundary. Once host edges are deleted, the nonedge pattern of $F$ must be realized among those defects.

### 9.2. Complete multipartite hosts

A complete multipartite graph has nonadjacency exactly within its parts. Induced containment should therefore depend on whether the nonadjacency relation of the pattern can be represented by part membership, together with bounds on part sizes. Vertices of the pattern with identical external neighborhoods suggest a formulation through twin classes and their multiplicities.

### 9.3. Toughness and clique thresholds

Toughness controls global fragmentation, whereas induced clique containment requires local pairwise adjacency. In unrestricted graph classes, toughness alone need not force arbitrarily large cliques. Under hereditary restrictions, however, one may seek a threshold $N(r,t)$ such that every $t$-tough graph of order at least $N(r,t)$ contains an induced $K_r$, or construct infinite counterexample families proving that no finite threshold exists.

### 9.4. Robust failure of $3$-connectivity

Because $1$-toughness forbids cut vertices but allows separating pairs, it is natural to quantify the gap. One may seek, for each $m$, minimally $1$-tough graphs with at least $m$ distinct separating vertex pairs and study the auxiliary graph formed by those pairs. The organizing question is whether edge-minimality forces the separating pairs to form a connected spanning structure.

## 10. Conclusion

Component-count toughness and induced containment respond differently to density, but both admit exact statements at the edge-order boundary. Adding edges can only reduce the number of components surviving any fixed vertex deletion. Consequently, $t$-toughness is monotone under edge addition, and $1$-tough graphs of order at least three are necessarily $2$-connected. At maximal density, every induced subgraph is complete, yielding the exact criterion that $F$ occurs induced in $K_n$ if and only if $F$ is complete and $v(F)\le n$.

These results supply both structural insight and computational simplification. Toughness certificates persist under reinforcement; cut-vertex detection gives a fast necessary test; and induced containment in complete hosts reduces to completeness plus cardinality. They also expose a central tension in network design: adding links strengthens global resilience while potentially erasing sparse local motifs. Future work can investigate the intermediate regimes where complete hosts acquire a controlled defect and where toughness is combined with hereditary structural constraints.
