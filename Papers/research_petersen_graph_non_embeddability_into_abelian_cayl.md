# Non-Embeddability of the Petersen Graph into Bipartite Abelian Cayley Graphs

## Abstract

We prove that the Petersen graph does not admit an isometric embedding into any bipartite Cayley graph of a finite abelian group — in particular, into any hypercube $Q_k = \mathrm{Cay}\big((\mathbb{Z}/2)^k, \{e_1, \dots, e_k\}\big)$. Our argument isolates two independent ingredients. The first is a purely metric obstruction, valid for every number of colors: an isometric map pulls back proper colorings from the host to the source, so a graph requiring more than $n$ colors cannot embed isometrically into any $n$-colorable graph. The second is an algebraic certificate specific to abelian Cayley graphs: the existence of an additive character $\psi \colon A \to \mathbb{Z}/2$ that sends every element of the connection set to $1$ is equivalent to a proper $2$-coloring, so a single group homomorphism witnesses bipartiteness. Since the Petersen graph has odd girth five and hence chromatic number three, combining the two ingredients rules out every bipartite abelian Cayley host at once. We recover, and strengthen to the isometric setting, the classical fact that the Petersen graph is not a partial cube. We close with a family of conjectures extending the obstruction to non-bipartite abelian hosts and to the full family of Kneser graphs.

**Keywords:** Petersen graph, Cayley graph, abelian group, isometric embedding, partial cube, hypercube, bipartite graph, graph coloring, odd girth, Kneser graph.

**Mathematics Subject Classification:** 05C12 (metric graph theory), 05C25 (graphs and abstract algebra), 05C15 (graph coloring).

---

## 1. Introduction

The Petersen graph $P$ is the standard source of counterexamples in graph theory: a $3$-regular, vertex-transitive graph on ten vertices with girth five and chromatic number three. Among its many extremal properties is that it is *not a partial cube* — it does not embed isometrically into any hypercube. Partial cubes are exactly the graphs that can be encoded by binary addresses so that graph distance equals Hamming distance, and the class is central to metric graph theory, media theory, and the geometry of data.

Hypercubes are the most familiar members of a much larger family: the **Cayley graphs of finite abelian groups**. It is therefore natural to ask whether the failure of the Petersen graph to embed into hypercubes is a shadow of a broader phenomenon. Could a more exotic abelian group, with a cleverly chosen generating set, host the Petersen graph isometrically? This paper settles the question for all *bipartite* abelian Cayley hosts and frames the remaining non-bipartite case as a precise conjecture.

Our contribution is conceptual as much as technical. We separate the obstruction into two logically independent halves:

1. **A metric principle (Section 3).** Isometric maps pull colorings backward. This holds for every number of colors and every pair of graphs, and uses nothing about groups.
2. **A bipartite certificate for abelian Cayley graphs (Section 4).** A single additive character certifies bipartiteness of an abelian Cayley graph. This is where commutativity does its work — and it does so only at the level $n = 2$.

The clean separation identifies exactly which abelian hosts are handled (all bipartite ones) and exactly which are not (non-bipartite ones), turning the residual case into a sharply localized open problem (Section 7).

---

## 2. Definitions

Throughout, graphs are simple, undirected, and connected unless stated otherwise. We write $d_G(u,v)$ for the shortest-path distance in $G$.

**Definition 2.1 (Distance and adjacency).** In a connected graph $G$, the *distance* $d_G(u,v)$ is the number of edges on a shortest $u$–$v$ path. Two distinct vertices are *adjacent* precisely when their distance equals $1$. This equivalence — adjacency iff distance one — is the only property of distance our metric argument requires.

**Definition 2.2 (Isometric embedding).** A map $f \colon V(G) \to V(H)$ is an *isometric embedding* if
$$d_H\big(f(u), f(v)\big) = d_G(u,v) \qquad \text{for all } u,v \in V(G).$$
An isometric embedding is automatically injective (distinct vertices are at positive distance) and maps edges to edges (distance $1$ to distance $1$).

**Definition 2.3 (Proper coloring and colorability).** A *proper $n$-coloring* of $G$ is a map $c \colon V(G) \to C$ into an $n$-element set $C$ such that $c(u) \neq c(v)$ whenever $u$ and $v$ are adjacent. The graph $G$ is *$n$-colorable* if such a coloring exists. It is *bipartite* iff it is $2$-colorable, which holds iff $G$ contains no cycle of odd length.

**Definition 2.4 (Cayley graph of an abelian group).** Let $A$ be an additive abelian group and let $S \subseteq A$ be a *connection set* satisfying
$$S = -S \quad (\text{symmetry: } s \in S \Rightarrow -s \in S) \qquad \text{and} \qquad 0 \notin S \quad (\text{looplessness}).$$
The *Cayley graph* $\mathrm{Cay}(A, S)$ has vertex set $A$, with $g$ and $h$ adjacent iff $h - g \in S$. Symmetry of $S$ makes adjacency symmetric ($h - g \in S \Rightarrow g - h = -(h-g) \in S$); looplessness forbids self-loops.

**Definition 2.5 (Hypercube).** For $k \in \mathbb{N}$, the *$k$-dimensional hypercube* is
$$Q_k = \mathrm{Cay}\Big((\mathbb{Z}/2)^k,\ \{\, e_i : 1 \le i \le k \,\}\Big),$$
where $e_i$ is the $i$-th standard basis vector (a $1$ in position $i$, zeros elsewhere). Its vertices are binary strings of length $k$, and $d_{Q_k}(x,y)$ equals the Hamming distance — the number of coordinates where $x$ and $y$ differ.

**Definition 2.6 (Partial cube).** A graph is a *partial cube* if it embeds isometrically into $Q_k$ for some $k$.

**Definition 2.7 (Petersen graph).** The *Petersen graph* $P$ is the Kneser graph $K(5,2)$: its vertices are the $\binom{5}{2} = 10$ two-element subsets of $\{1,2,3,4,5\}$, with two subsets adjacent iff they are disjoint. It is $3$-regular, vertex-transitive under the natural action of the symmetric group $S_5$, has girth five, and has chromatic number three. Its odd girth — the length of a shortest odd closed walk — is five.

---

## 3. The metric obstruction

The engine of the paper is the following pullback principle. It is elementary but powerful, and it makes no reference to groups.

**Lemma 3.1 (Colorings pull back along isometries).** Let $f \colon V(G) \to V(H)$ be an isometric embedding and let $n \in \mathbb{N}$. If $H$ is $n$-colorable, then $G$ is $n$-colorable.

*Proof.* Let $c$ be a proper $n$-coloring of $H$. Define $c' = c \circ f \colon V(G) \to C$; we claim $c'$ is a proper $n$-coloring of $G$. Let $uv$ be an edge of $G$. Then $d_G(u,v) = 1$. Since $f$ is isometric,
$$d_H\big(f(u), f(v)\big) = d_G(u,v) = 1,$$
so $f(u)$ and $f(v)$ are adjacent in $H$ (adjacency is equivalent to distance one). As $c$ is proper, $c(f(u)) \neq c(f(v))$, i.e. $c'(u) \neq c'(v)$. Hence $c'$ is proper. $\blacksquare$

The isometry hypothesis is used exactly once — to convert a $G$-edge into an $H$-edge — and it cannot be dropped. A non-isometric map may compress an odd cycle onto a single edge; for example, folding a triangle $K_3$ onto one edge of $K_2$ is a graph homomorphism but not an isometric embedding, and it would falsely "pull back" a $2$-coloring to the non-bipartite $K_3$. Isometry is precisely the condition that forbids such distance-collapsing folds.

Contrapositively:

**Theorem 3.2 (Chromatic obstruction to isometric embedding).** If $G$ is not $n$-colorable and $H$ is $n$-colorable, then there is no isometric embedding of $G$ into $H$. Equivalently, for any map $f \colon V(G) \to V(H)$,
$$\neg\, \forall u,v \colon\ d_H\big(f(u), f(v)\big) = d_G(u,v).$$

*Proof.* Immediate from Lemma 3.1: an isometric embedding would force $G$ to be $n$-colorable, contradicting the hypothesis. $\blacksquare$

Note the generality: Theorem 3.2 holds for every $n$. The chromatic number is a monotone-under-isometric-embedding invariant. Specializing to $n = 2$ gives the classical slogan *"an isometric image of a graph inside a bipartite graph must itself be bipartite,"* i.e. odd cycles obstruct isometric embedding into bipartite hosts.

---

## 4. The bipartite certificate for abelian Cayley graphs

We now show that bipartiteness of an abelian Cayley graph is witnessed by a single group homomorphism into $\mathbb{Z}/2$.

**Lemma 4.1 (Character certificate).** Let $A$ be an abelian group, and let $S \subseteq A$ be a connection set ($S = -S$, $0 \notin S$). Suppose there exists an additive character
$$\psi \colon A \to \mathbb{Z}/2, \qquad \psi(a+b) = \psi(a) + \psi(b),$$
such that $\psi(s) = 1$ for every $s \in S$. Then $\mathrm{Cay}(A, S)$ is bipartite (i.e. $2$-colorable), with $\psi$ itself a proper $2$-coloring.

*Proof.* Take $\psi \colon A \to \mathbb{Z}/2$ as the coloring, using the two-element codomain as the palette. Let $g, h$ be adjacent, so $h - g \in S$. Then
$$\psi(h) - \psi(g) = \psi(h - g) = 1 \neq 0 \quad \text{in } \mathbb{Z}/2,$$
using that $\psi$ is a homomorphism. Hence $\psi(g) \neq \psi(h)$: adjacent vertices receive distinct colors. Therefore $\psi$ is a proper $2$-coloring. $\blacksquare$

Only the level $n = 2$ enjoys such a compact certificate; the algebraic economy comes from the fact that $\mathbb{Z}/2$ characters and $2$-colorings coincide. (The converse also holds when the connection set generates $A$: a proper $2$-coloring, normalized so the identity gets color $0$, is a homomorphism sending each generator to $1$. We do not need the converse.)

**The hypercube instance.** For $Q_k$ the character is the coordinate-sum parity:
$$\psi \colon (\mathbb{Z}/2)^k \to \mathbb{Z}/2, \qquad \psi(x) = \sum_{i=1}^{k} x_i.$$
This is additive, and each basis vector $e_i$ satisfies $\psi(e_i) = 1$. Hence Lemma 4.1 recovers the bipartiteness of the hypercube, with even- and odd-weight strings as the two color classes.

---

## 5. Main results

We can now assemble the obstruction. The key numerical fact about the Petersen graph is the following.

**Proposition 5.1 (Petersen is not bipartite).** The Petersen graph $P$ is not $2$-colorable.

*Proof.* $P$ contains a $5$-cycle — indeed its girth is five, and five is odd. Any graph containing an odd cycle fails to be bipartite, since a proper $2$-coloring would force strictly alternating colors around the cycle, impossible on an odd number of vertices. Equivalently, $\chi(P) = 3 > 2$. $\blacksquare$

**Theorem 5.2 (Main theorem: no isometric embedding into bipartite abelian Cayley graphs).** Let $A$ be a finite abelian group with connection set $S$ ($S = -S$, $0 \notin S$), and suppose there is an additive character $\psi \colon A \to \mathbb{Z}/2$ with $\psi(s) = 1$ for all $s \in S$. Then the Petersen graph does not embed isometrically into $\mathrm{Cay}(A, S)$: for every map $f \colon V(P) \to A$,
$$\neg\, \forall u,v \in V(P) \colon\ d_{\mathrm{Cay}(A,S)}\big(f(u), f(v)\big) = d_P(u,v).$$

*Proof.* By Lemma 4.1, $\mathrm{Cay}(A, S)$ is $2$-colorable. By Proposition 5.1, $P$ is not $2$-colorable. Theorem 3.2 (with $n = 2$) then denies any isometric embedding of $P$ into $\mathrm{Cay}(A, S)$. $\blacksquare$

**Corollary 5.3 (Isometric partial-cube obstruction).** The Petersen graph does not embed isometrically into any hypercube $Q_k$; that is, $P$ is not a partial cube.

*Proof.* Apply Theorem 5.2 to $A = (\mathbb{Z}/2)^k$, $S = \{e_1, \dots, e_k\}$, and the coordinate-sum character $\psi(x) = \sum_i x_i$, which sends each $e_i$ to $1$ (Section 4). $\blacksquare$

Corollary 5.3 both recovers the classical statement that the Petersen graph is not a partial cube and *strengthens the framing*: the obstruction is not special to hypercubes but is a uniform consequence of the host being a bipartite abelian Cayley graph. The hypercube supplies an explicit, non-vacuous family of hosts to which the theorem applies with a concrete character, confirming the results are not empty.

---

## 6. Algorithms

The proof is constructive enough to yield decision procedures. We record three.

**Algorithm 6.1 (Character-based bipartiteness certificate).** *Given* a finite abelian group $A$ and connection set $S$, *decide* whether a character certificate exists and, if so, *return* the $2$-coloring. One searches the (finite) group $\mathrm{Hom}(A, \mathbb{Z}/2)$ of characters — for $A = \prod_j \mathbb{Z}/m_j$, a character is determined by its values on generators, subject to compatibility — and tests whether any character sends all of $S$ to $1$. Complexity is polynomial in $|A|$ once characters are enumerated; for elementary abelian $2$-groups it reduces to solving a linear system over $\mathbb{F}_2$.

**Algorithm 6.2 (Coloring pullback / embedding refutation).** *Given* an alleged isometric embedding $f \colon V(P) \to A$ into a certified-bipartite host, *produce* a proper $2$-coloring of $P$ by $v \mapsto \psi(f(v))$, then *exhibit* an edge of $P$ violating it (guaranteed to exist since $P$ is not $2$-colorable). This turns any purported embedding into an explicit contradiction — a monochromatic edge — in time linear in the number of edges of $P$.

**Algorithm 6.3 (Odd-cycle witness).** *Given* a graph, *search* by breadth-first layering for an edge joining two vertices in the same layer; such an edge closes an odd cycle and certifies non-bipartiteness. Applied to $P$ it returns a $5$-cycle, the concrete obstruction underlying Proposition 5.1. Complexity is linear in the size of the graph.

---

## 7. Discussion and future directions

The architecture "metric obstruction (any $n$) + cheap bipartite certificate ($n = 2$ via a character)" pinpoints the reach of the method. The metric half is fully general; the algebraic half applies only when a $\mathbb{Z}/2$ character kills the connection set. Consequently the argument is silent about **non-bipartite abelian Cayley hosts** — connection sets producing odd cycles, such as $C_5 = \mathrm{Cay}(\mathbb{Z}/5, \{\pm 1\})$ — where no such character exists. Closing that gap is the substance of the following conjectures.

**Conjecture 7.1 (Grand non-embeddability).** The Petersen graph admits no isometric embedding into $\mathrm{Cay}(A, S)$ for any finite abelian group $A$ and any symmetric connection set $S$, including generating sets that produce odd cycles. The heuristic is that commutativity forces the directions realized along shortest paths to behave like independent coordinates, and the Petersen graph's fivefold symmetry cannot be reconciled with any such coordinate system without collapsing two non-adjacent vertices to identical distance profiles. The missing ingredient is a coordinate-independence lemma for commutative connection graphs.

**Conjecture 7.2 (Odd girth versus abelian coordinates).** If a vertex-transitive graph of odd girth at least five embeds isometrically into a Cayley graph of a finite abelian group, then it is a Cartesian product of even cycles and complete graphs on at most two vertices. In particular no such embedding exists for graphs, like the Petersen graph, that are *prime* with respect to the Cartesian product. Odd girth five simultaneously forbids the bipartite (hypercube) factors and the short odd-cycle factors, squeezing the host into a product structure the Petersen graph cannot possess.

**Conjecture 7.3 (Kneser graphs as a non-embeddable family).** For every $n \ge 5$, the Kneser graph $K(n,2)$ on the two-element subsets of an $n$-element set (adjacent when disjoint), of which the Petersen graph is the case $n = 5$, admits no isometric embedding into any Cayley graph of a finite abelian group. The disjointness metric on two-element subsets encodes an odd $5$-cycle for every $n \ge 5$, so the same parity obstruction should propagate through the whole family.

## 8. Applications

Isometric embeddings into hypercubes and abelian Cayley graphs are the mathematical backbone of low-distortion binary coding: representing relational data by short addresses so that graph proximity becomes coordinate proximity. When such an embedding exists, distance queries reduce to arithmetic on codewords. Theorem 5.2 and Corollary 5.3 mark a hard boundary: no additive addressing scheme built on a bipartite abelian group can faithfully encode the Petersen graph's metric, and — conjecturally — no abelian scheme can at all. The Petersen graph thus serves as a compact certificate that certain relational geometries are intrinsically non-commutative in their coordinatization, an obstruction relevant to metric embedding theory, coding, and the design of similarity-preserving hash functions.

## 9. Conclusion

We have shown that the Petersen graph does not embed isometrically into any bipartite Cayley graph of a finite abelian group, cleanly recovering and strengthening its classical status as a non-partial-cube. The proof factors into a fully general metric pullback of colorings and a one-line character certificate of bipartiteness for abelian hosts, isolating precisely the frontier — non-bipartite abelian hosts — where the grand conjecture lives.

---

## References (indicative)

- General references on partial cubes and isometric subgraphs of hypercubes (Djoković–Winkler theory).
- Standard treatments of Cayley graphs of abelian groups and their spectral/metric structure.
- The Petersen graph as $K(5,2)$ and the Kneser graph coloring theorem.
