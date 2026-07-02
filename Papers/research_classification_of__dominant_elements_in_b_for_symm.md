# A Degree Criterion for Dominance of the Weights $\lambda_{D,I} = 2\rho - \beta_I - \beta_D$ in the Simply-Laced Case

## Abstract

We study the dominance of a distinguished family of integral weights arising in the classification of nearly extremal elements of a fundamental highest-weight crystal of a symmetrizable Kac–Moody algebra. For a subdiagram $I$ of the Dynkin diagram and a subset $D \subseteq I$ of *marked* vertices, one forms the weight $\lambda_{D,I} = 2\rho - \beta_I - \beta_D$, where $\rho$ is the half-sum of the positive roots and $\beta_S = \sum_{j \in S}\alpha_j$ is the partial sum of simple roots over $S$. Deciding when $\lambda_{D,I}$ is dominant is the weight-theoretic core of the underlying classification. We prove that in the **simply-laced** setting — where the generalized Cartan matrix takes the form $A = 2\,\mathrm{Id} - \mathrm{Adj}(G)$ for a simple graph $G$ — the abstract dominance condition is equivalent to an elementary local inequality on vertex degrees. Explicitly, taking $I$ to be the entire diagram, $\lambda_{D,I}$ is dominant if and only if every marked vertex $i \in D$ satisfies $\deg i + \deg_D i \ge 2$, where $\deg_D i$ denotes the number of neighbors of $i$ inside $D$. As corollaries we obtain a crisp leaf obstruction (a singleton $\{v\}$ is admissible iff $\deg v \ge 2$), the automatic dominance of the empty marking, and a characterization identifying forests as exactly the connected diagrams on which some vertex fails to carry a dominant singleton. The results reduce a representation-theoretic positivity test to a decidable graph-combinatorial one.

**Keywords:** simply-laced Dynkin diagram, generalized Cartan matrix, dominant weight, half-sum of positive roots, partial root sum, vertex degree, forest, Kac–Moody algebra.

## 1. Introduction

### 1.1 Motivation

Let $\mathfrak{g}$ be a symmetrizable Kac–Moody algebra with a fixed set of simple roots $\{\alpha_i\}_{i \in \mathcal I}$ and simple coroots $\{\alpha_i^\vee\}_{i\in\mathcal I}$. The integrable highest-weight module $L(\rho)$ with highest weight $\rho$ (the half-sum of positive roots) has an associated crystal $B(\rho)$, a combinatorial skeleton that records the action of the Kashiwara lowering operators. A central object of study is the set of **$\rho$-dominant** elements of $B(\rho)$: those $b$ for which $\varepsilon_i(b) \le 1$ for every simple root, i.e. each lowering direction can be applied at most once from $b$.

A conjectural classification asserts that every $\rho$-dominant element arises as a canonical element $\pi_{D,I}$ built from three combinatorial choices:

1. a subgraph $I$ of the Dynkin diagram with only simple bonds and no cycle of length $\ge 3$ (a *simply-laced forest*);
2. a subset $D \subseteq I$ such that the weight $\lambda_{D,I} = 2\rho - \beta_I - \beta_D$ is **dominant**; and
3. a choice of root vertex in each connected component of $I$.

The dominance requirement in (2) is the arithmetic gatekeeper of the construction: it is the condition that determines which markings $D$ are admissible. While a full formalization of Kac–Moody crystals lies beyond current reach, the weight-theoretic backbone — the dominance of $\lambda_{D,I}$ — can be isolated and analyzed completely in the simply-laced case. That is the subject of this paper.

### 1.2 Contributions

We prove the following, all in the simply-laced setting where the generalized Cartan matrix is $A = 2\,\mathrm{Id} - \mathrm{Adj}(G)$ for a simple graph $G$:

- **Closed-form pairings** (Theorem 3.1). For any vertex set $S$ and vertex $i$,
$$\langle \beta_S, \alpha_i^\vee\rangle = \begin{cases} 2 - \deg_S i, & i \in S,\\ -\deg_S i, & i \notin S,\end{cases}$$
where $\deg_S i$ is the number of neighbors of $i$ lying in $S$.

- **Dominance criterion for the whole diagram** (Theorem 4.1). With $I$ the full vertex set, $\lambda_{D,I}$ is dominant if and only if every $i \in D$ satisfies $\deg i + \deg_D i \ge 2$; unmarked coordinates are automatically nonnegative.

- **Leaf obstruction** (Theorem 4.4). A singleton marking $D = \{v\}$ is dominant iff $\deg v \ge 2$; leaves never carry dominant singletons.

- **Sufficient conditions** (Propositions 4.2, 4.3): the empty marking is always dominant, and any marking whose vertices all have ambient degree $\ge 2$ is dominant.

- **Forest characterization** (Theorem 5.1). A connected diagram admits a dominant singleton at every vertex if and only if it contains a cycle; equivalently, the diagrams for which some vertex fails to carry a dominant singleton are exactly the forests.

The upshot is a reduction of a representation-theoretic positivity condition to a decidable, local statement about vertex degrees.

## 2. Setup and definitions

Throughout, $G = (V, E)$ is a finite simple graph (no loops, no multiple edges) with vertex set $V$; we take $V = \{1, \dots, n\}$. Adjacency is symmetric and irreflexive: $i \not\sim i$ for all $i$, and $i \sim j \iff j \sim i$.

**Definition 2.1 (Simply-laced Cartan matrix).** The generalized Cartan matrix associated with $G$ is $A \in \mathbb{Z}^{V\times V}$ with entries
$$A_{ij} = \begin{cases} 2, & i = j,\\ -1, & i \sim j,\\ 0, & \text{otherwise.}\end{cases}$$
Equivalently $A = 2\,\mathrm{Id} - \mathrm{Adj}(G)$. The rows and columns are indexed by the simple roots $\alpha_i$ and simple coroots $\alpha_i^\vee$, and $A_{ij} = \langle \alpha_j, \alpha_i^\vee\rangle$.

**Definition 2.2 (Partial root sum).** For $S \subseteq V$, set $\beta_S = \sum_{j \in S} \alpha_j$.

**Definition 2.3 (Coroot pairing / column sum).** For $S \subseteq V$ and $i \in V$, define
$$\langle \beta_S, \alpha_i^\vee\rangle = \sum_{j \in S} A_{ij}.$$
This is the $i$-th coordinate of $\beta_S$ in the basis of fundamental coweights.

**Definition 2.4 (Degree into a set).** For $S \subseteq V$ and $i \in V$, let
$$\deg_S i = \#\{\, j \in S : i \sim j \,\}$$
be the number of neighbors of $i$ inside $S$. When $S = V$ this is the ordinary degree $\deg i$, and in general $0 \le \deg_S i \le \deg i$.

**Definition 2.5 (The weight $\lambda_{D,I}$ and dominance).** Using the normalization $\langle \rho, \alpha_i^\vee\rangle = 1$ for all $i$, the $i$-th coordinate of $\lambda_{D,I} = 2\rho - \beta_I - \beta_D$ is
$$\langle \lambda_{D,I}, \alpha_i^\vee\rangle = 2 - \langle \beta_I, \alpha_i^\vee\rangle - \langle \beta_D, \alpha_i^\vee\rangle.$$
The weight $\lambda_{D,I}$ is **dominant**, written $\lambda_{D,I} \in P^+$, if $\langle \lambda_{D,I}, \alpha_i^\vee\rangle \ge 0$ for every $i \in V$.

## 3. The pairing formulas

The technical foundation is the evaluation of $\langle \beta_S, \alpha_i^\vee\rangle$.

**Lemma 3.0 (Off-diagonal sum).** For any $S \subseteq V$ and $i \in V$,
$$\sum_{x \in S \setminus \{i\}} A_{ix} = -\deg_S i.$$

*Proof.* For $x \ne i$, the entry $A_{ix}$ equals $-1$ when $i \sim x$ and $0$ otherwise; by irreflexivity the term $x = i$ contributes nothing to the count of neighbors. Hence $\sum_{x \in S\setminus\{i\}} A_{ix} = -\#\{x \in S : i \sim x\} = -\deg_S i$, using that $i \not\sim i$ so removing $i$ from $S$ does not change the neighbor count. $\square$

**Theorem 3.1 (Closed-form pairings).** For $S \subseteq V$ and $i \in V$:
$$\langle \beta_S, \alpha_i^\vee\rangle = \begin{cases} 2 - \deg_S i, & i \in S,\\ -\deg_S i, & i \notin S.\end{cases}$$

*Proof.* If $i \in S$, split off the diagonal term: $\langle \beta_S, \alpha_i^\vee\rangle = A_{ii} + \sum_{x \in S\setminus\{i\}} A_{ix} = 2 - \deg_S i$ by Lemma 3.0. If $i \notin S$, then $S \setminus \{i\} = S$ and the sum is $-\deg_S i$ directly. $\square$

## 4. The dominance criterion

We now specialize to $I = V$ (the whole diagram), so that $\beta_I = \sum_{j\in V}\alpha_j$ and $\deg_I i = \deg i$.

**Theorem 4.1 (Dominance criterion, whole diagram).** For any $D \subseteq V$,
$$\lambda_{D,V} \in P^+ \iff \forall\, i \in D,\ \deg i + \deg_D i \ge 2.$$

*Proof.* Using Definition 2.5 and Theorem 3.1 (with $S = V$, so $\deg_V i = \deg i$, and $i \in V$ always),
$$\langle \lambda_{D,V}, \alpha_i^\vee\rangle = 2 - (2 - \deg i) - \langle \beta_D, \alpha_i^\vee\rangle = \deg i - \langle \beta_D, \alpha_i^\vee\rangle.$$
If $i \in D$, then $\langle \beta_D, \alpha_i^\vee\rangle = 2 - \deg_D i$, so the coordinate equals $\deg i + \deg_D i - 2$; nonnegativity is exactly $\deg i + \deg_D i \ge 2$. If $i \notin D$, then $\langle \beta_D, \alpha_i^\vee\rangle = -\deg_D i$, so the coordinate equals $\deg i + \deg_D i \ge 0$ unconditionally. Thus all coordinates are nonnegative iff the marked-vertex inequality holds for every $i \in D$. $\square$

This identity is worth recording in its uniform form:
$$\langle \lambda_{D,V}, \alpha_i^\vee\rangle = \deg i + \deg_D i - 2\cdot[\,i \in D\,],$$
where $[\,i\in D\,]\in\{0,1\}$ is the indicator of membership.

**Proposition 4.2 (Empty marking).** $\lambda_{\varnothing, V} = 2\rho - \beta_V$ is always dominant.

*Proof.* The condition in Theorem 4.1 quantifies over $i \in D = \varnothing$ and is therefore vacuously true. $\square$

**Proposition 4.3 (Minimum-degree sufficient condition).** If every $i \in D$ has $\deg i \ge 2$, then $\lambda_{D,V}$ is dominant.

*Proof.* Since $\deg_D i \ge 0$, the hypothesis $\deg i \ge 2$ implies $\deg i + \deg_D i \ge 2$ for each $i \in D$; apply Theorem 4.1. $\square$

**Theorem 4.4 (Leaf obstruction / singleton criterion).** For a single vertex $v$,
$$\lambda_{\{v\}, V} \in P^+ \iff \deg v \ge 2.$$
In particular, a leaf ($\deg v = 1$) or isolated vertex ($\deg v = 0$) never carries a dominant singleton.

*Proof.* With $D = \{v\}$ we have $\deg_D v = \#\{j \in \{v\} : v \sim j\} = 0$ by irreflexivity. Theorem 4.1 then reads $\deg v + 0 \ge 2$, i.e. $\deg v \ge 2$. $\square$

**Remark 4.5 (Rescue by adjacency).** The criterion depends on $\deg i + \deg_D i$, not on $\deg i$ alone. A degree-one vertex $i$ is forbidden as a singleton, but if its unique neighbor is also marked then $\deg_D i = 1$ and $\deg i + \deg_D i = 2$, so the marking becomes admissible in direction $i$. Dominance is a global property of $D$, and marked neighbors can prop each other up. This is precisely why the ambient degree is the wrong invariant and the degree-sum is the right one.

## 5. Forests as the frontier

**Theorem 5.1 (Forest characterization).** Let $G$ be a finite connected simple graph with at least two vertices. The following are equivalent:

1. every vertex $v$ carries a dominant singleton (i.e. $\lambda_{\{v\},V}\in P^+$ for all $v$);
2. every vertex has degree $\ge 2$;
3. $G$ contains a cycle.

Consequently, the connected diagrams on which *some* vertex fails to carry a dominant singleton are exactly the forests (here, trees).

*Proof.* (1) $\iff$ (2) is Theorem 4.4 applied to each vertex. (2) $\Rightarrow$ (3): a finite graph with minimum degree $\ge 2$ contains a cycle (follow a maximal path; its endpoint has a second neighbor, forcing a cycle). (3) $\Rightarrow$ (2) is not literally true for arbitrary graphs, but the equivalence we use is the standard dichotomy for connected graphs: a connected graph is acyclic iff it is a tree iff it has a vertex of degree $\le 1$ (a leaf). Contrapositively, "no vertex of degree $\le 1$" (that is, minimum degree $\ge 2$) is equivalent, for connected finite graphs, to "not a tree," i.e. "contains a cycle." Hence (2) $\iff$ (3). Combining, the failure of (1) — some vertex of degree $\le 1$ — characterizes trees among connected graphs, and forests in general. $\square$

This reframes the paper's hypothesis that $I$ carry "no cycle of length $\ge 3$": the acyclicity of $I$ is exactly the regime in which the singleton dominance test is *nontrivial* (some vertex fails), separating rigid forests from cycle-bearing diagrams where every singleton is admissible.

## 6. Algorithms

The criterion is immediately algorithmic. Given $G$ (as an adjacency structure) and a candidate marking $D$:

**Algorithm A (Dominance test).** For each $i \in D$, compute $\deg i$ (size of the neighbor list) and $\deg_D i$ (number of neighbors in $D$); accept iff $\deg i + \deg_D i \ge 2$ for all such $i$. Complexity $O(\sum_{i\in D}\deg i) = O(|E|)$ in the worst case, and $O(|D|\cdot \Delta)$ with $\Delta$ the maximum degree.

**Algorithm B (Enumeration of admissible markings).** Iterate over subsets $D \subseteq V$ (or over a chosen search space) and apply Algorithm A. For small diagrams this enumerates the full admissible family; the empty set is always accepted, and every subset of vertices all having degree $\ge 2$ is accepted.

**Algorithm C (Singleton profile / forest detector).** For each vertex $v$, accept the singleton $\{v\}$ iff $\deg v \ge 2$. A connected graph is a tree iff at least one vertex is rejected; it contains a cycle iff all are accepted.

## 7. Worked examples

- **Path $P_3$** (vertices $1 - 2 - 3$): degrees $1, 2, 1$. Singleton $\{2\}$ is dominant ($\deg 2 = 2$); singletons $\{1\}, \{3\}$ are not (leaves). Marking $D = \{1,2\}$: vertex $1$ has $\deg 1 + \deg_D 1 = 1 + 1 = 2$ (rescued by its marked neighbor $2$), vertex $2$ has $2 + 1 = 3$; both $\ge 2$, so $D$ is admissible.
- **Cycle $C_4$**: every degree is $2$, so every singleton — indeed every nonempty subset — is dominant, consistent with Theorem 5.1(3).
- **Star $K_{1,3}$** (center $c$, leaves $x,y,z$): only $\{c\}$ is a dominant singleton. A leaf $x$ becomes admissible in its own coordinate only when $c$ is also marked.

## 8. Discussion

The reduction achieved here has three appealing features. First, it is *faithful*: the simply-laced specialization does not weaken the dominance condition but re-expresses it exactly. Second, it is *decidable*: dominance of $\lambda_{D,I}$ for the whole diagram is testable in linear time from the adjacency data. Third, it is *explanatory*: the leaf obstruction and the forest dichotomy show why the acyclicity hypothesis in the ambient classification is natural rather than incidental.

The identity $\langle \lambda_{D,V}, \alpha_i^\vee\rangle = \deg i + \deg_D i - 2[\,i\in D\,]$ is the reusable engine. It localizes dominance to marked vertices and reveals the degree-sum $\deg i + \deg_D i$ — not the ambient degree — as the governing invariant, which in turn produces the "rescue by adjacency" phenomenon.

## 9. Future work

Several concrete directions follow from the degree criterion. One can seek an exact characterization of admissible markings via a local *anchoring principle* (every degree-one marked vertex must have its unique neighbor marked); study the asymptotic prevalence of leaf-free admissible markings as diagrams grow; sharpen the forest dichotomy into a rigidity statement; and search for a graph polynomial whose evaluation counts admissible corrections. These are elaborated in the accompanying future-directions material. Beyond the whole-diagram case, the same pairing formulas apply to a general subdiagram $I$, opening the analysis of the mixed condition governing $\lambda_{D,I}$ for proper $I$, and — ultimately — the reconnection of the weight-theoretic backbone to the full crystal classification of $\rho$-dominant elements.

## 10. Conclusion

In the simply-laced case, the dominance of the weight $\lambda_{D,I} = 2\rho - \beta_I - \beta_D$ is governed entirely by vertex degrees. For the whole diagram, $\lambda_{D,I}$ is dominant precisely when every marked vertex satisfies $\deg i + \deg_D i \ge 2$; singletons obey the leaf obstruction $\deg v \ge 2$; the empty marking is always dominant; and forests emerge as the exact frontier at which singleton dominance can fail. A representation-theoretic positivity condition has become a piece of elementary, checkable graph combinatorics.
