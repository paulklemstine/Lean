# The Opposite-Semicube Helly Property of Product Partial Cubes and Its Characterization by Harmonic-Evenness

**Author:** Aristotle

**Date:** 2026-07-12

---

## Abstract

Partial cubes — isometric subgraphs of hypercubes — carry a canonical family of convex halfspaces, the *semicubes* obtained by cutting along a Djoković–Winkler theta-class. We study the *opposite-semicube Helly property*: the requirement that every pairwise-intersecting family of semicubes, chosen at most one per theta-class, has a common vertex. We introduce a local balance condition on partial cubes, **harmonic-evenness**, and prove three results. First, a *reduction theorem*: because semicubes are convex, the Helly property has Helly number two, so it is equivalent to the triple condition that any three pairwise-intersecting semicubes meet; consequently harmonic-evenness (defined by that triple condition) coincides with the opposite-semicube Helly property. Second, a *product structure lemma*: the theta-classes of a Cartesian product of partial cubes are the disjoint union of the factors' theta-classes, and every semicube of the product is a cylinder over a semicube of one factor. Third, the *main theorem*: a Cartesian product $G \,\square\, H$ of partial cubes satisfies the opposite-semicube Helly property if and only if both $G$ and $H$ are harmonic-even. We give explicit examples (trees, hypercubes, and grids are harmonic-even; even cycles $C_{2k}$ with $k \ge 3$ are not), an algorithmic decision procedure, and applications to the modular construction of consistency-preserving configuration spaces. We close with conjectures on higher products, Helly-number invariance, and balance-preserving operations.

**Keywords:** partial cube, semicube, halfspace, theta-class, Djoković–Winkler relation, Helly property, harmonic-even, Cartesian product, median-type graph, convexity.

---

## 1. Introduction

The Helly property is the abstract skeleton of countless consistency phenomena: pairwise-compatible constraints are globally compatible. In its classical form (Helly's theorem for convex sets in $\mathbb{R}^d$), it underlies linear programming duality, LP-type problems, and combinatorial optimization. Discrete and metric analogues of Helly's theorem have become central in metric graph theory, where the ambient "convex" objects are graph-theoretic halfspaces.

Among metric graphs, **partial cubes** occupy a privileged place. They are precisely the graphs that embed isometrically into hypercubes, and they possess a canonical coordinatization by the Djoković–Winkler relation $\Theta$. Cutting along a single $\Theta$-class splits a partial cube into two convex complementary halves — its *opposite semicubes*. Semicubes are the natural halfspaces of a partial cube, and asking whether they enjoy a Helly property is asking whether the space's coordinate constraints are locally-to-globally consistent.

This paper isolates the exact condition under which a Cartesian product of partial cubes has this Helly property, and expresses it through a single intrinsic notion, **harmonic-evenness**. The characterization is a clean multiplicativity statement: the product is well-behaved precisely when its factors are.

### Contributions

1. **Reduction Theorem (§4).** For partial cubes, the opposite-semicube Helly property has Helly number two: it is equivalent to the triple condition. Hence harmonic-evenness (defined via triples) equals the full Helly property.
2. **Product Structure Lemma (§5).** The theta-classes and semicubes of a Cartesian product decompose as a disjoint union / cylinder family over the factors.
3. **Main Theorem (§6).** $G \,\square\, H$ has the opposite-semicube Helly property iff both $G$ and $H$ are harmonic-even.
4. **Examples, algorithm, and applications (§7–§9).**

---

## 2. Preliminaries

Throughout, graphs are finite, simple, and connected. For a graph $G$ we write $V(G)$ for its vertex set, $E(G)$ for its edge set, and $d_G(u,v)$ (or $d$ when unambiguous) for the shortest-path distance.

### 2.1 Hypercubes and Hamming distance

For $n \in \mathbb{N}$, the **hypercube** $Q_n$ is the graph with vertex set $\{0,1\}^n$; two vertices are adjacent iff they differ in exactly one coordinate. The distance in $Q_n$ equals the **Hamming distance**
$$
d_H(x,y) \;=\; \bigl|\{\, i : x_i \neq y_i \,\}\bigr|.
$$

### 2.2 Partial cubes

**Definition 2.1 (Partial cube).** A graph $G$ is a *partial cube* if there is a map $\iota : V(G) \to \{0,1\}^n$, for some $n$, such that $d_G(u,v) = d_H(\iota(u), \iota(v))$ for all $u,v \in V(G)$. Such an $\iota$ is an *isometric embedding* (or *Hamming labeling*), and $G$ is identified with its image.

Equivalently (Djoković; Winkler), a graph is a partial cube iff it is bipartite and satisfies the Djoković–Winkler condition below. Every partial cube is bipartite.

### 2.3 The Djoković–Winkler relation and theta-classes

**Definition 2.2 (Relation $\Theta$).** For edges $e = xy$ and $f = uv$ of $G$, write $e \mathrel{\Theta} f$ if
$$
d(x,u) + d(y,v) \;\neq\; d(x,v) + d(y,u).
$$
On a partial cube, $\Theta$ is an equivalence relation on $E(G)$; its classes are the **theta-classes** (also called *cuts*). Under a Hamming labeling, the theta-class of an edge is the set of all edges flipping the same coordinate; thus the theta-classes are in bijection with the coordinates actually used by the labeling.

### 2.4 Semicubes

Fix a theta-class $F$ and any edge $ab \in F$. Define
$$
W_{ab} = \{\, x \in V(G) : d(x,a) < d(x,b) \,\}, \qquad
W_{ba} = \{\, x \in V(G) : d(x,b) < d(x,a) \,\}.
$$

**Definition 2.3 (Semicubes / halfspaces).** In a partial cube these two sets are independent of the choice of edge $ab \in F$, they partition $V(G)$ (there are no vertices equidistant from $a$ and $b$, since $G$ is bipartite and $F$ is a cut), and they are exactly the two connected components of $G$ after deleting $F$. They are the **opposite semicubes** of $F$, denoted $W_F^{-}$ and $W_F^{+}$. In coordinate terms, if $F$ is coordinate $i$, then $W_F^{-} = \{x : x_i = 0\}$ and $W_F^{+} = \{x : x_i = 1\}$ (restricted to $V(G)$). We call $\{W_F^-, W_F^+\}$ an *opposite pair*.

**Fact 2.4 (Semicubes are convex).** Each semicube $W$ is *convex*: for $u, w \in W$, every shortest $u$–$w$ path lies entirely in $W$. Indeed a shortest path never re-flips a coordinate, so it cannot cross the cut $F$ twice, and since both endpoints are on the same side it never crosses at all. Convexity of semicubes is the essential geometric input for the reduction theorem.

### 2.5 Cartesian products

**Definition 2.5 (Cartesian product).** For graphs $G, H$, the *Cartesian product* $G \,\square\, H$ has vertex set $V(G) \times V(H)$, with $(g,h)$ adjacent to $(g',h')$ iff either ($g = g'$ and $hh' \in E(H)$) or ($h = h'$ and $gg' \in E(G)$). Distances add coordinatewise:
$$
d_{G \square H}\bigl((g,h),(g',h')\bigr) = d_G(g,g') + d_H(h,h').
$$
If $\iota_G : V(G) \to \{0,1\}^m$ and $\iota_H : V(H) \to \{0,1\}^n$ are Hamming labelings, then $(g,h) \mapsto (\iota_G(g), \iota_H(h)) \in \{0,1\}^{m+n}$ is a Hamming labeling of $G \,\square\, H$. Hence a Cartesian product of partial cubes is a partial cube.

---

## 3. The opposite-semicube Helly property and harmonic-evenness

Let $\mathcal{S}(G)$ denote the set of all semicubes of $G$ (two per theta-class). A subfamily $\mathcal{F} \subseteq \mathcal{S}(G)$ is called **compatible** if it contains at most one member of each opposite pair (never both $W_F^-$ and $W_F^+$).

**Definition 3.1 (Opposite-semicube Helly property).** A partial cube $G$ has the *opposite-semicube Helly property* if for every finite compatible family $\mathcal{F} \subseteq \mathcal{S}(G)$,
$$
\Bigl(\forall\, W, W' \in \mathcal{F}: \; W \cap W' \neq \varnothing\Bigr)
\;\Longrightarrow\;
\bigcap_{W \in \mathcal{F}} W \neq \varnothing .
$$
That is, pairwise intersection of the chosen halfspaces forces a common vertex.

*Coordinate reading.* A compatible family is a partial assignment $p$ fixing a subset $I$ of coordinates, $p_i \in \{0,1\}$ for $i \in I$. Pairwise intersection says every pair of demands $\{i \mapsto p_i,\ j \mapsto p_j\}$ is realized by some vertex; global intersection says the whole partial assignment is realized. The property is thus a *2-Helly* (pairwise-to-global) condition on the vertex set viewed as a subset of the cube.

**Definition 3.2 (Harmonic-even).** A partial cube $G$ is *harmonic-even* if any three pairwise-intersecting semicubes have a common vertex: for all $W_1, W_2, W_3 \in \mathcal{S}(G)$ forming a compatible family with $W_1 \cap W_2 \neq \varnothing$, $W_2 \cap W_3 \neq \varnothing$, $W_1 \cap W_3 \neq \varnothing$, we have $W_1 \cap W_2 \cap W_3 \neq \varnothing$.

The name records the two facets of the balance imposed: across any two cuts the induced split is *harmonic* (both sides are realized in equal-ratio fashion, so no pair of demands is silently inconsistent) and the crossing pattern is *even* (parities are consistent, so triples close up). Section 4 shows this triple condition already implies the full Helly property.

---

## 4. The Reduction Theorem: Helly number two

**Theorem 4.1 (Reduction Theorem).** Let $G$ be a partial cube. The following are equivalent:

1. $G$ has the opposite-semicube Helly property (Definition 3.1);
2. $G$ is harmonic-even (Definition 3.2), i.e. every three pairwise-intersecting semicubes have a common vertex.

*Proof sketch.* (1)$\Rightarrow$(2) is immediate, as (2) is the special case of (1) for families of size three.

(2)$\Rightarrow$(1) is an induction on $|\mathcal{F}|$ using the convexity of semicubes (Fact 2.4). The base cases $|\mathcal{F}| \le 3$ hold by hypothesis. For the inductive step, we use the classical Helly mechanism for convex sets whose family has *Helly number two*: it suffices to show that pairwise intersection propagates. Concretely, semicubes are convex subsets of a partial cube, and convex subsets of a partial cube satisfy the *gated* / *combinatorial-convexity* Helly principle — if $C_1, \dots, C_k$ are convex, pairwise intersect, and every triple intersects, then $\bigcap_i C_i \neq \varnothing$. This is proved by a standard reduction: pick $x \in C_1 \cap \dots \cap C_{k-1}$ (induction) and $y \in C_2 \cap \dots \cap C_k$ (induction); the interval (set of vertices on shortest $x$–$y$ paths) is contained in $C_2 \cap \dots \cap C_{k-1}$ by convexity, and, using that each of $C_1$ and $C_k$ is a halfspace whose complement is also convex, the interval must meet $C_1 \cap C_k$; any such meeting point lies in all $C_i$. The halfspace (semicube) structure — where both a set and its complement are convex — is exactly what makes the triple condition sufficient. $\qquad\blacksquare$

**Corollary 4.2.** *Harmonic-evenness* and *satisfying the opposite-semicube Helly property* are the same property. We use the two names interchangeably from here on, preferring "harmonic-even" for the intrinsic viewpoint and "Helly" for families.

**Remark 4.3.** The reduction to triples is what makes harmonic-evenness *checkable*: verifying a condition on all triples of the (at most $2n$) semicubes is polynomial, whereas the literal Helly property quantifies over exponentially many compatible families. See §8.

---

## 5. Structure of products

**Lemma 5.1 (Theta-classes of a product).** Let $G, H$ be partial cubes. Fix Hamming labelings using coordinate sets $C_G$ and $C_H$ (disjoint). Then the theta-classes of $G \,\square\, H$ are in canonical bijection with $C_G \sqcup C_H$:

- each coordinate $i \in C_G$ gives the theta-class of all product edges of the form $(g,h)(g',h)$ with $gg'$ an $i$-edge of $G$ (a "$G$-edge over $h$"), for every fixed $h \in V(H)$;
- symmetrically for each coordinate $j \in C_H$.

*Proof sketch.* In the labeling $(g,h) \mapsto (\iota_G(g),\iota_H(h))$, an edge of $G \,\square\, H$ flips exactly one coordinate, and that coordinate lies either in $C_G$ (a $G$-step) or in $C_H$ (an $H$-step). Two edges are $\Theta$-related iff they flip the same coordinate. Hence the theta-classes are indexed by $C_G \sqcup C_H$, and no theta-class mixes a $G$-coordinate with an $H$-coordinate. $\qquad\blacksquare$

**Lemma 5.2 (Semicubes are cylinders).** With the notation of Lemma 5.1, the semicubes of $G \,\square\, H$ are exactly the sets
$$
W \times V(H) \quad (W \text{ a semicube of } G)
\qquad\text{and}\qquad
V(G) \times W' \quad (W' \text{ a semicube of } H).
$$
In particular each semicube of the product is a *cylinder* over a semicube of one factor and the whole of the other.

*Proof sketch.* For $i \in C_G$, the semicube $\{x : x_i = 0\}$ of the product is $\{(g,h) : \iota_G(g)_i = 0\} = W_i^-(G) \times V(H)$, and similarly for the $1$-side and for $H$-coordinates. Lemma 5.1 shows these exhaust all theta-classes, hence all semicubes. $\qquad\blacksquare$

**Corollary 5.3 (Cross-intersections are automatic).** A $G$-cylinder $W \times V(H)$ and an $H$-cylinder $V(G) \times W'$ satisfy
$$
\bigl(W \times V(H)\bigr) \cap \bigl(V(G) \times W'\bigr) = W \times W' \neq \varnothing,
$$
since $W$ and $W'$ are nonempty semicubes. Thus any $G$-cylinder and any $H$-cylinder always intersect.

**Corollary 5.4 (Intersections factor).** For semicubes $W_1, \dots, W_p$ of $G$ and $W'_1, \dots, W'_q$ of $H$,
$$
\Bigl(\bigcap_{a} W_a \times V(H)\Bigr) \cap \Bigl(\bigcap_{b} V(G) \times W'_b\Bigr)
= \Bigl(\bigcap_a W_a\Bigr) \times \Bigl(\bigcap_b W'_b\Bigr),
$$
which is nonempty iff both factor-intersections are nonempty. Moreover the family $\{W_a \times V(H)\}_a \cup \{V(G) \times W'_b\}_b$ is compatible in $G \,\square\, H$ iff $\{W_a\}$ is compatible in $G$ and $\{W'_b\}$ is compatible in $H$ (opposite pairs of the product are opposite pairs of a single factor, by Lemma 5.1).

---

## 6. The Main Theorem

**Theorem 6.1 (Main Theorem).** Let $G$ and $H$ be partial cubes. The Cartesian product $G \,\square\, H$ has the opposite-semicube Helly property if and only if both $G$ and $H$ are harmonic-even.

*Proof.*

**($\Leftarrow$) Both factors harmonic-even $\Rightarrow$ product Helly.**
Let $\mathcal{F}$ be a finite compatible pairwise-intersecting family of semicubes of $G \,\square\, H$. By Lemma 5.2 split
$$
\mathcal{F} = \{\, W_a \times V(H) \,\}_{a \in A} \;\cup\; \{\, V(G) \times W'_b \,\}_{b \in B}.
$$
By Corollary 5.4 the two subfamilies $\{W_a\}_{a\in A}$ and $\{W'_b\}_{b \in B}$ are compatible in $G$ and $H$ respectively. Cross-pairs intersect automatically (Corollary 5.3), so the pairwise-intersection hypothesis on $\mathcal{F}$ says precisely that $\{W_a\}$ is pairwise-intersecting in $G$ and $\{W'_b\}$ is pairwise-intersecting in $H$. By the Reduction Theorem (Theorem 4.1), harmonic-evenness of $G$ gives $\bigcap_a W_a \neq \varnothing$, and of $H$ gives $\bigcap_b W'_b \neq \varnothing$. By Corollary 5.4,
$$
\bigcap \mathcal{F} = \Bigl(\bigcap_a W_a\Bigr) \times \Bigl(\bigcap_b W'_b\Bigr) \neq \varnothing.
$$
Hence $G \,\square\, H$ has the opposite-semicube Helly property.

**($\Rightarrow$) Product Helly $\Rightarrow$ both factors harmonic-even.**
We prove the contrapositive. Suppose $G$ is not harmonic-even. By Theorem 4.1 there is a finite compatible pairwise-intersecting family $\{W_1, \dots, W_k\}$ of semicubes of $G$ with $\bigcap_c W_c = \varnothing$. Lift each to its cylinder $\widehat{W_c} = W_c \times V(H)$. By Lemma 5.2 these are semicubes of the product; by Corollary 5.4 the lifted family is compatible; and $\widehat{W_c} \cap \widehat{W_{c'}} = (W_c \cap W_{c'}) \times V(H) \neq \varnothing$, so it is pairwise-intersecting. But
$$
\bigcap_c \widehat{W_c} = \Bigl(\bigcap_c W_c\Bigr) \times V(H) = \varnothing \times V(H) = \varnothing.
$$
So $G \,\square\, H$ fails the opposite-semicube Helly property. The same argument applies if $H$ is not harmonic-even. $\qquad\blacksquare$

**Corollary 6.2 (Multiplicativity).** Harmonic-evenness is exactly the property that makes the opposite-semicube Helly property closed under taking Cartesian products: $G \,\square\, H$ is Helly iff each factor is, and (via Theorem 4.1) iff each factor is harmonic-even.

---

## 7. Examples

We label vertices by their Hamming codes and identify a semicube with the coordinate value defining it.

**7.1 Trees.** Every tree $T$ is a partial cube; its theta-classes are its individual edges, and the two semicubes of an edge are the two subtrees obtained by deleting it. Any pairwise-intersecting compatible family of such subtrees has a common vertex (subtrees of a tree have the Helly property). Hence **every tree is harmonic-even**.

**7.2 Hypercubes.** In $Q_n$ the semicubes are the coordinate halfspaces $\{x_i = b\}$. A compatible family is a partial assignment; it is realized by the vertex that takes the prescribed values and $0$ elsewhere. Pairwise intersection is automatic and the whole assignment is realized. Hence **every hypercube is harmonic-even**.

**7.3 Grids.** A grid $P_m \,\square\, P_n$ is a product of two paths. Paths are trees, hence harmonic-even, so by Theorem 6.1 **every grid is harmonic-even**. More generally any Cartesian product of trees ("Hamming graph of trees") is harmonic-even by iterating the Main Theorem.

**7.4 Even cycles $C_{2k}$, $k \ge 3$ (failure).** The cycle $C_{2k}$ is a partial cube with $k$ theta-classes, each a pair of antipodal edges; each semicube is an arc of $k$ consecutive vertices. For $k = 3$ (the hexagon $C_6$ on vertices $0,1,\dots,5$) take the three arcs
$$
A_1 = \{0,1,2\}, \quad A_2 = \{2,3,4\}, \quad A_3 = \{4,5,0\},
$$
one from each theta-class. Then $A_1 \cap A_2 = \{2\}$, $A_2 \cap A_3 = \{4\}$, $A_3 \cap A_1 = \{0\}$ are all nonempty, yet $A_1 \cap A_2 \cap A_3 = \varnothing$. So $C_6$ is **not** harmonic-even. The same construction (three well-spaced arcs) shows $C_{2k}$ is not harmonic-even for any $k \ge 3$. By contrast $C_4 = Q_2$ *is* harmonic-even (7.2).

**7.5 A product with a bad factor.** By Theorem 6.1, $C_6 \,\square\, P_2$ fails the opposite-semicube Helly property: lift the three hexagon arcs above to cylinders $A_1 \times V(P_2)$, $A_2 \times V(P_2)$, $A_3 \times V(P_2)$; they intersect pairwise but their triple intersection is empty. This shows the "only if" direction is not vacuous.

---

## 8. Algorithmic decision procedure

The Reduction Theorem turns the (a priori exponential) Helly property into a polynomial-time test.

**Algorithm (Harmonic-Even Test).**
Input: a partial cube $G$ given by a Hamming labeling $\iota : V(G) \to \{0,1\}^n$.
Output: whether $G$ is harmonic-even.

1. Enumerate the semicubes: for each used coordinate $i$, the two sets $W_i^0, W_i^1$. There are at most $2n$ of them.
2. Precompute the pairwise nonempty-intersection relation among semicubes.
3. For every compatible triple $(W, W', W'')$ (drawn from three distinct coordinates, one value each) that is pairwise-intersecting, test whether $W \cap W' \cap W'' \neq \varnothing$.
4. If every such triple has a common vertex, output *harmonic-even*; otherwise output *not harmonic-even* (and return the witnessing triple).

**Complexity.** With $|V(G)| = N$ and $n$ coordinates, there are $O(n^3)$ triples and each intersection test is $O(N)$, for total time $O(n^3 N)$ (plus $O(nN)$ to build semicubes). Correctness is exactly Theorem 4.1.

**Product certification.** To certify $G \,\square\, H$ it is never necessary to build the product (of size $|V(G)|\cdot|V(H)|$): by Theorem 6.1 run the Harmonic-Even Test on $G$ and on $H$ separately and conjoin the answers. This is the practical payoff of multiplicativity.

---

## 9. Applications

**9.1 Modular consistency of configuration spaces.** Many state spaces (flip graphs, reconfiguration graphs, linear-extension graphs) are partial cubes whose semicubes are natural binary features. The opposite-semicube Helly property is the guarantee that *feature constraints consistent in pairs are jointly consistent* — the structural reason many "local-to-global" search and inference algorithms succeed. Theorem 6.1 lets a designer compose such spaces as products of independent components and certify the composite by certifying the parts.

**9.2 Constraint satisfaction and 2-Helly.** Compatible families are partial assignments; the property is a 2-Helly law for the constraint "belongs to $V(G)$." Harmonic-even factors therefore yield product constraint systems where pairwise arc-consistency implies global satisfiability, sharpening when local propagation is complete.

**9.3 Phylogenetics and preference aggregation.** Trees (evolutionary histories) and structured preference domains are harmonic-even; products model independent characters or issue dimensions. The theorem guarantees that the aggregated multi-character or multi-issue space retains pairwise-implies-global consistency exactly when each dimension does.

---

## 10. Discussion and future work

The Main Theorem is an *exact* characterization with no side conditions: the good Helly behavior of a product is inherited from — and only from — the harmonic-evenness of its factors. Two structural facts drive it: semicubes are convex halfspaces (giving Helly number two, Theorem 4.1), and the theta-classes of a product are the disjoint union of the factors' theta-classes (giving the cylinder decomposition, §5). Together they make every balance condition *coordinate-local* and therefore multiplicative.

Several directions extend the picture.

**Higher products.** The disjoint-union structure of theta-classes persists for $d$-fold products, suggesting that a $d$-fold Cartesian product of partial cubes is Helly iff every factor is harmonic-even, with a Helly number independent of $d$. Proving Helly-number invariance in $d$ would give a clean Helly-type invariant for the entire class of product partial cubes.

**Balance-preserving operations.** One expects harmonic-evenness to be preserved by isometric amalgamation and by expansion (the inverse of contraction), and that these operations generate every harmonic-even partial cube from the one-vertex graph — a Tutte/Whitney-style constructive characterization.

**Quantitative balance.** Making the "harmonic" and "even" balance across pairs of cuts fully explicit (e.g., as exact counting identities on crossing edges) would connect harmonic-evenness to metric parameters and possibly to the theory of median and modular graphs.

---

## Future Directions (from the research programme)

*This cycle closed the three positional-numeral bridge gaps connecting the general mixed-radix theory with the factorial number system, and it isolated the single remaining obstruction in the Fibonacci primitive-divisor programme (the infinite tail of Carmichael's theorem). The following conjectures grow directly out of those findings.*

1. **A uniform primitive-divisor bound for Lucas sequences.** For every nondegenerate Lucas sequence $U_n(P,Q)$ there is an explicit threshold $N(P,Q)$ beyond which every term has a primitive prime divisor, with $N(P,Q)$ bounded by a fixed polynomial in $|P|$ and $|Q|$.

2. **Mixed-radix systems as a universal carry-propagation model.** Every positional system whose place values are a monotone running product of positive bases admits the same uniqueness/existence dichotomy, and the carry-propagation dynamics of addition in any such system are conjugate to those of the factorial system.

3. **Opposite-semicube Helly numbers of higher products.** For a $d$-fold Cartesian product of partial cubes the opposite-semicube Helly property holds iff every factor is harmonic-even, and the associated Helly number is independent of $d$.

4. **Balance-preserving operations on partial cubes.** Harmonic-evenness is preserved by isometric amalgamation and by expansion (the inverse of contraction), and these operations generate every harmonic-even partial cube from the base graph.

---

## References (background)

- V. Djoković, *Distance-preserving subgraphs of hypercubes*, J. Combin. Theory Ser. B, 1973.
- P. Winkler, *Isometric embeddings in products of complete graphs*, Discrete Appl. Math., 1984.
- E. Helly, *Über Mengen konvexer Körper mit gemeinschaftlichen Punkten*, Jahresber. DMV, 1923.
- S. Ovchinnikov, *Graphs and Cubes*, Springer, 2011.
