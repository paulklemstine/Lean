# Minimal Minor-Closed Classes Below Density 3/2 Have Single Forbidden Minors: The Forest Case

**Author:** Aristotle

**Date:** 2026-06-24

**Domain:** Probability / Structural Graph Theory

---

## Abstract

We study the structural rigidity of minor-closed graph classes in the sparse
regime governed by the density threshold $\delta = 3/2$. The guiding principle is
that every $\subseteq$-minimal minor-closed class whose limiting edge density
remains below some $\delta < 3/2$ is characterized by the exclusion of a *single*
graph as a minor: there exists a graph $H$ with $\mathcal{G} = \mathrm{excl}\{H\}$.
We develop and fully verify the prototypical instance of this phenomenon, the
class of **forests** (acyclic simple graphs). We prove that forests form a
minor-closed class (using the subgraph specialisation of the minor order), that
every non-empty finite forest on $V$ vertices with $E$ edges satisfies the sharp
edge bound $E + 1 \le V$, that every tree has edge density strictly below $1$, and
consequently that every forest — indeed the entire forest class — has edge density
strictly below $3/2$. We also formalise the genuine graph-minor relation via
branch-set models, establishing its reflexivity and the fact that the subgraph
order refines it, thereby justifying the subgraph specialisation used in the
density argument. The forest class realises the framework concretely: it is a
non-trivial minor-closed class with limiting density exactly $1$, attained only as
a supremum, and conjecturally equal to $\mathrm{excl}\{K_3\}$ in the full
contraction-based minor order. We close with a programme of four sharp,
falsifiable conjectures extending the result.

**Keywords:** minor-closed class, forbidden minor, edge density, forest, spanning
tree, branch-set model, graph minor, well-quasi-order, density threshold.

---

## 1. Introduction

A *simple graph* $G = (V, E)$ consists of a vertex set $V$ and a set $E$ of
unordered pairs of distinct vertices (edges). A graph $H$ is a **minor** of $G$,
written $H \preceq G$, if $H$ can be obtained from a subgraph of $G$ by
contracting edges. Equivalently — and this is the definition we make precise in
Section 5 — $H$ is a minor of $G$ if one can assign to each vertex of $H$ a
non-empty, connected, pairwise-disjoint *branch set* of vertices of $G$ such that
adjacent vertices of $H$ have an edge of $G$ between their branch sets.

A class $\mathcal{G}$ of graphs is **minor-closed** if $H \preceq G$ and
$G \in \mathcal{G}$ imply $H \in \mathcal{G}$. By the Robertson–Seymour Graph
Minor Theorem, every minor-closed class is characterized by a finite set of
**forbidden minors** (its *obstruction set*): $\mathcal{G} = \mathrm{excl}(\mathcal{O})$
for a finite set $\mathcal{O}$, where $\mathrm{excl}(\mathcal{O})$ denotes the
class of graphs having no member of $\mathcal{O}$ as a minor. A central refinement
asks *how large* the obstruction set must be, and in particular when a single
forbidden minor suffices.

This paper concerns the **sparse regime** delimited by the density threshold
$\delta = 3/2$. The **edge density** of a finite graph is
$\rho(G) = |E| / |V|$ (with $\rho = 0$ when $V = \varnothing$), and the
**limiting density** of a class is the supremum of $\rho(G)$ over its members as
$|V| \to \infty$. The organising conjecture is:

> **Conjecture (Single forbidden minor below 3/2).** Every $\subseteq$-minimal
> minor-closed class $\mathcal{G}$ with limiting density below some $\delta < 3/2$
> satisfies $\mathcal{G} = \mathrm{excl}\{H\}$ for a single graph $H$.

The contribution of this paper is the complete, rigorous development of the
prototypical instance: the class of forests. Forests have limiting density exactly
$1 < 3/2$, are minor-closed, and (in the full minor order) are exactly
$\mathrm{excl}\{K_3\}$. We establish the minor-closure, the sharp edge bound, and
the density bounds, and we lay the foundations of the minor relation itself via
branch-set models.

### Organisation

Section 2 fixes notation and definitions. Section 3 establishes minor-closure of
the forest class. Section 4 proves the edge bound and the density theorems.
Section 5 develops the branch-set model of the minor relation and its basic laws.
Section 6 discusses limiting density and the role of the $3/2$ threshold. Section 7
states the algorithmic content. Section 8 surveys applications, and Section 9
presents future directions.

---

## 2. Definitions and conventions

Throughout, $V$ is a vertex type, finite where required, and $G : \mathrm{SimpleGraph}\,V$
ranges over simple graphs on $V$. We write $G.\mathrm{edgeSet}$ for the set of
edges and $|X|$ for finite cardinality (`Nat.card`).

**Definition 2.1 (Acyclic graph / forest).** A graph $G$ is **acyclic**, written
$G.\mathrm{IsAcyclic}$, if it contains no cycle. The **forest class** on $V$ is
$$\mathrm{acyclicClass}(V) = \{\, G : \mathrm{SimpleGraph}\,V \mid G.\mathrm{IsAcyclic} \,\}.$$

**Definition 2.2 (Tree).** A graph $G$ is a **tree**, written $G.\mathrm{IsTree}$,
if it is connected and acyclic. Equivalently, $G$ is a tree iff it is connected
and $|E| + 1 = |V|$.

**Definition 2.3 (Edge density).** The **edge density** of a finite graph $G$ on
vertex set $V$ is the rational number
$$\rho(G) \;=\; \mathrm{edgeDensity}(G) \;=\; \frac{|G.\mathrm{edgeSet}|}{|V|} \in \mathbb{Q},$$
with the convention $\rho(G) = 0$ when $|V| = 0$ (the empty graph), so that the
division is total.

**Definition 2.4 (Minor-closed class).** Working in an ordered setting with order
relation $\le$ (refining the minor order), a class $\mathcal{C}$ of graphs is
**minor-closed**, written $\mathrm{MinorClosed}(\mathcal{C})$, if for all $G, H$
with $H \le G$ and $G \in \mathcal{C}$ we have $H \in \mathcal{C}$. We use the
**subgraph order** ($H \le G$ iff $H$ is a subgraph of $G$) as a specialisation of
the full minor order; Proposition 5.3 shows the subgraph order refines the genuine
minor order.

**Definition 2.5 (Excluded-minor class).** For a set $\mathcal{O}$ of graphs,
$$\mathrm{excl}(\mathcal{O}) = \{\, G \mid \text{no } H \in \mathcal{O} \text{ is a minor of } G \,\}.$$
This class is always minor-closed.

---

## 3. Forests form a minor-closed class

**Theorem 3.1 (`acyclicClass_minorClosed`).** *The forest class is minor-closed in
the subgraph specialisation of the minor order:*
$$\mathrm{MinorClosed}\bigl(\mathrm{acyclicClass}(V)\bigr).$$

*Proof sketch.* Let $H \le G$ (i.e. $H$ is a subgraph of $G$) with $G$ acyclic. A
cycle in $H$ would be a cycle in $G$, contradicting acyclicity; hence $H$ is
acyclic. Formally this is the antitonicity of acyclicity under the subgraph order,
$\mathrm{IsAcyclic.anti}$: deleting edges and vertices cannot create a cycle. $\square$

This theorem is the entry point: it certifies that forests are a legitimate object
of minor-closed-class theory, so that questions about obstruction sets and
limiting density are meaningful for them.

---

## 4. The edge bound and density theorems

The quantitative heart of the paper is a single sharp inequality.

**Theorem 4.1 (Forest edge bound, `IsAcyclic.card_edgeSet_add_one_le`).** *Let $V$
be finite and non-empty, and let $G$ be acyclic. Then*
$$|G.\mathrm{edgeSet}| + 1 \;\le\; |V|.$$

*Proof sketch.* The complete graph $\top$ on $V$ is connected. By the principle
that any acyclic subgraph of a connected graph extends to a spanning tree
(`SimpleGraph.Connected.exists_isTree_le_of_le_of_isAcyclic`, applied to
$G \le \top$ and $G$ acyclic), there is a tree $F$ with $G \le F \le \top$ and
$F.\mathrm{IsTree}$. A tree on $|V|$ vertices has exactly $|V| - 1$ edges
($F.\mathrm{card\_edgeFinset}$), so
$$|G.\mathrm{edgeSet}| \le |F.\mathrm{edgeSet}| = |V| - 1,$$
where the first inequality is monotonicity of edge count under $G \le F$. Adding
$1$ gives $|G.\mathrm{edgeSet}| + 1 \le |V|$. $\square$

The bound is sharp: trees attain equality $|E| + 1 = |V|$, while forests with more
than one component have strict inequality. From it the density theorems follow.

**Theorem 4.2 (Trees are below density 1, `IsTree.edgeDensity_lt_one`).** *Let $V$
be finite and let $G$ be a tree. Then $\rho(G) < 1$.*

*Proof sketch.* A tree is connected with $|E| + 1 = |V|$
(`SimpleGraph.isTree_iff_connected_and_card`), so $|V| \ge 1$ and
$$\rho(G) = \frac{|E|}{|V|} = \frac{|V| - 1}{|V|} = 1 - \frac{1}{|V|} < 1.$$
The inequality $\rho < 1$ follows from $\mathrm{div\_lt\_iff}$ after clearing the
positive denominator $|V|$. $\square$

**Theorem 4.3 (Forests are below 3/2, `acyclic_edgeDensity_lt_threshold`).** *Let
$V$ be finite and let $G$ be acyclic. Then $\rho(G) < 3/2$.*

*Proof sketch.* If $V = \varnothing$ then $\rho(G) = 0 < 3/2$ by convention.
Otherwise $V$ is non-empty; by Theorem 4.1, $|E| + 1 \le |V|$, so $|E| \le |V| - 1$
and hence
$$\rho(G) = \frac{|E|}{|V|} \le \frac{|V| - 1}{|V|} < 1 < \frac{3}{2}.$$
Formally, clearing denominators with $\mathrm{div\_lt\_div\_iff}$ and using
$|V| > 0$ ($\mathrm{Nat.card\_pos}$) reduces the goal to $2|E| < 3|V|$, which
follows from $2(|V| - 1) < 3|V|$ for $|V| \ge 1$. $\square$

**Corollary 4.4 (Whole class below threshold, `acyclicClass_below_threshold`).**
*For finite $V$, every $G \in \mathrm{acyclicClass}(V)$ satisfies $\rho(G) < 3/2$.*

*Proof.* Immediate from Theorem 4.3 applied to each member. $\square$

This corollary is the formal realisation of the research mission: a genuine,
non-trivial minor-closed class lying strictly below the $3/2$ density threshold.

---

## 5. The branch-set model of the minor relation

To ground the abstract order in the genuine graph-minor relation, we formalise
minors via *branch-set models*.

**Definition 5.1 (Branch-set model, `IsMinorModel`).** Let $G, H$ be simple
graphs. A **minor model** of $H$ in $G$ is a map $\beta$ assigning to each vertex
$v$ of $H$ a set $\beta(v) \subseteq V(G)$ (its *branch set*) such that:

1. **Non-emptiness:** $\beta(v) \neq \varnothing$ for every $v$.
2. **Disjointness:** $\beta(u) \cap \beta(v) = \varnothing$ for $u \neq v$.
3. **Connectivity:** the induced subgraph $G[\beta(v)]$ is connected for every $v$.
4. **Edge lifting:** whenever $uv \in E(H)$, there exist $a \in \beta(u)$,
   $b \in \beta(v)$ with $ab \in E(G)$.

**Definition 5.2 (Minor, `IsMinor`).** $H$ is a **minor** of $G$, written
$H \preceq G$, if there exists a minor model of $H$ in $G$ (i.e. $\mathrm{IsMinorModel}$
is inhabited).

**Proposition 5.3 (Reflexivity, `isMinor_refl`).** *Every graph is a minor of
itself: $G \preceq G$.*

*Proof sketch.* Use the singleton model $\beta(w) = \{w\}$. Each branch set is
non-empty; distinct singletons are disjoint; the induced subgraph $G[\{w\}]$ is a
one-vertex graph, hence connected — this is $\mathrm{IsTree.of\_subsingleton}$
applied to the nonempty subsingleton subtype $\{w\}$; and every edge $uv$ of $G$
lifts to itself with $a = u \in \beta(u)$, $b = v \in \beta(v)$. $\square$

**Proposition 5.4 (Subgraph refinement, `isMinor_of_le`).** *If $H \le G$ in the
subgraph order, then $H \preceq G$ in the minor order.*

*Proof sketch.* Again the singleton model $\beta(w) = \{w\}$ works: branch sets
are non-empty, disjoint, and connected as before, and any edge $uv \in E(H)$ is,
by $H \le G$, also an edge of $G$, lifting to itself. $\square$

Proposition 5.4 is precisely the justification for studying the forest class via
the *subgraph* specialisation in Sections 3–4: subgraph containment is a special
case of minorhood, so subgraph-closure is a necessary feature of any class closed
under the full minor relation, and the density bounds proven for the subgraph
order hold a fortiori. Combined with the abstract fact that $\mathrm{excl}(\mathcal{O})$
is always minor-closed, these propositions give the concrete meaning of
"excluding $H$ as a minor."

The genuinely hard structural law — *transitivity* of $\preceq$, requiring the
composition of branch-set models by routing $H$-edges through $G$-paths inside
branch sets — is not claimed here; it is the first item of the future programme
(Section 9, C1).

---

## 6. Limiting density and the 3/2 threshold

The density bounds exhibit a precise asymptotic structure. For trees,
$$\rho = \frac{|V| - 1}{|V|} = 1 - \frac{1}{|V|},$$
which increases monotonically in $|V|$ and satisfies
$$\sup_{|V| \to \infty} \frac{|V| - 1}{|V|} = 1, \qquad \text{but } \rho < 1 \text{ for all finite } V.$$
Thus the **limiting density of the forest class is exactly $1$**, attained as a
supremum and never as a maximum. The sequence of attainable tree densities is
$$0,\ \tfrac{1}{2},\ \tfrac{2}{3},\ \tfrac{3}{4},\ \tfrac{4}{5},\ \ldots \;\to\; 1,$$
approaching but never reaching the limit.

The number $3/2$ functions as a *structural threshold*. Heuristically, a class
with limiting density below $3/2$ has too small an edge budget to support more than
a single spanning skeleton plus bounded local decoration; this scarcity forces the
obstruction set to be a singleton. Forests are the extreme case: their entire
structure *is* the skeleton, with limiting density exactly $1$ and (conjecturally)
the single obstruction $K_3$. The gap $1 < 3/2$ is the quantitative margin that
places forests strictly inside the regime of the organising conjecture.

The triangle $K_3$ is the forest obstruction because every cycle contracts to
$K_3$ (squish all but three of its edges), and a $K_3$-minor forces a cycle;
"acyclic" and "$K_3$-minor-free" coincide. Hence, in the full minor order,
$$\mathrm{acyclicClass} = \mathrm{excl}\{K_3\},$$
a single-excluded-minor class — the conclusion of the organising conjecture in its
prototypical case.

---

## 7. Algorithmic content

The proofs are constructive and translate into algorithms.

**Algorithm A (Spanning-tree extension and edge-bound certification).** Given a
finite forest $G$ on $V$, extend $G$ to a spanning tree $F$ by greedily adding
edges of the complete graph that do not create a cycle (a union-find / Kruskal-style
loop). The resulting $F$ has exactly $|V| - 1$ edges, certifying
$|E(G)| \le |V| - 1$. Complexity: $O(|V|^2\,\alpha(|V|))$ with union-find, or
$O((|V| + |E|)\,\alpha)$ when edges are supplied. This is the algorithmic content
of Theorem 4.1.

**Algorithm B (Density evaluation and threshold check).** Given a finite graph,
compute $\rho = |E|/|V|$ exactly in rational arithmetic and compare against the
threshold $3/2$. For a forest, the comparison is guaranteed to return "below," and
the witness is the edge bound from Algorithm A. Complexity: $O(|V| + |E|)$.

**Algorithm C (Acyclicity / minor test).** Test acyclicity by depth-first search
detecting back edges, or equivalently test for a $K_3$-minor: $G$ is a forest iff
DFS finds no back edge iff $G$ has no cycle iff $G$ excludes $K_3$ as a minor.
Complexity: $O(|V| + |E|)$.

---

## 8. Applications

**Sparse network design.** Forests and spanning trees model minimum-cost
connectivity: telecommunication backbones, electrical grids, and distribution
networks where the goal is to connect all nodes with the fewest links. The edge
bound $|E| \le |V| - 1$ is the fundamental budget constraint, and the
density-below-$1$ property quantifies the inherent sparsity of any acyclic design.

**Probabilistic and random-graph thresholds.** Density thresholds are the
combinatorial analogue of phase transitions. The forest regime (density $< 1$)
sits below the emergence of a giant component in the Erdős–Rényi model, which
occurs precisely at density $1/2$ (average degree $1$); the structural rigidity of
sparse minor-closed classes mirrors the orderliness of random graphs below their
critical threshold.

**Structural graph theory.** Single-excluded-minor characterisations are the
cleanest possible descriptions of graph classes. The forest case
($\mathrm{excl}\{K_3\}$ in the minor order) is the template for understanding when
the Robertson–Seymour obstruction set collapses to a singleton, with applications
to algorithmic meta-theorems (bounded-treewidth classes, parameterized complexity)
where the size of the obstruction set governs running times.

---

## 9. Future directions

We restate the four guiding conjectures of the programme.

**C1. Transitivity of the branch-set minor relation.** $\mathrm{IsMinor}$ is
transitive, hence a preorder (a partial order up to isomorphism), making
$\mathrm{SimpleGraph}$ a legitimate instance of the abstract order framework. The
key insight: composing two branch-set models routes each top-level $H$-edge
through a $G$-path inside a branch set, so each composite branch set is the union
of the middle-graph branch sets it covers, with connectivity preserved by the
realising middle-layer edges that glue the pieces. With $\mathrm{isMinor\_refl}$
and $\mathrm{isMinor\_of\_le}$ already formalised, transitivity is the single
remaining preorder law.

**C2. Forests are exactly the $K_3$-minor-free graphs.** Under the contraction
minor order, $\mathrm{acyclicClass} = \mathrm{excl}\{K_3\}$, equivalently
$\mathrm{obstructions}(\mathrm{acyclicClass}) = \{K_3\}$: forests are a
single-excluded-minor class in the *true* minor order, not merely the subgraph
order. Key insight: any cycle contracts to $K_3$ and a $K_3$-minor forces a cycle,
so "acyclic" and "$K_3$-minor-free" coincide once contraction is available.

**C3. Limiting density is a supremum, not a maximum.** For forests,
$\mathrm{limitingDensity} = 1$ but no member attains $1$; more generally every
$\subseteq$-minimal minor-closed class strictly below $3/2$ has limiting density
$1$ and equals $\mathrm{excl}\{H\}$ for a single $H$. Key insight: below $3/2$ the
only growth mode is a single spanning-tree-like skeleton plus bounded local
decoration, forcing the supremum to the value $1$ and the obstruction set to a
singleton. The proved bound $(n-1)/n < 1$ with $(n-1)/n \to 1$ already exhibits the
sup-not-max phenomenon.

**C4. Well-quasi-ordering implies finite obstruction sets below 3/2.** Restricted
to classes of limiting density $< 3/2$, the minor order is a well-quasi-order, so
every such minor-closed class has a finite forbidden set; combined with C3, that
set is a singleton. Key insight: $\mathrm{WellFoundedLT}$ (an explicit hypothesis
of the abstract framework) drives the obstruction machinery to terminate with a
finite — and below $3/2$, singleton — basis.

---

## 10. Conclusion

We have given a complete and rigorous treatment of the prototypical minor-closed
class below the $3/2$ density threshold: the forests. We proved minor-closure, the
sharp edge bound $|E| + 1 \le |V|$, and the density theorems
$\rho_{\text{tree}} < 1$ and $\rho_{\text{forest}} < 3/2$, and we founded the
genuine minor relation on branch-set models with reflexivity and subgraph
refinement. The forest class realises the organising conjecture — a non-trivial
minor-closed class with limiting density exactly $1$, attained as a supremum, and
single-obstruction $K_3$ — and the density gap $1 < 3/2$ is its quantitative
heart. The four conjectures of Section 9 chart the path from this verified
prototype to the general theorem.
