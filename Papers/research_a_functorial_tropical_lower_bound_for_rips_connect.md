# A Functorial Tropical Lower Bound for Rips Connectivity via Valuation-Depth Sublevel Graphs

## Abstract

We study the relationship between path-connectivity in Vietoris–Rips graphs and the underlying metric distance, and we identify precisely the geometric hypothesis under which the two coincide. In an arbitrary pseudometric space, connectivity of two points $x, y$ in the Rips graph at scale $\varepsilon$ — the existence of a path all of whose edges have length at most $\varepsilon$ — controls the true distance only through the weak *Archimedean* bound $\mathrm{dist}(x,y) \le n\varepsilon$, where $n$ is the number of edges traversed. The factor $n$ encodes the "Archimedean leak": chains of short edges accumulate without bound. Our main theorem is that this leak is sealed completely under the *strong (ultrametric) triangle inequality* $\mathrm{dist}(x,z) \le \max(\mathrm{dist}(x,y), \mathrm{dist}(y,z))$. Over any ultrametric (non-Archimedean / valuation) space, Rips reachability at scale $\varepsilon \ge 0$ is *equivalent* to the single sublevel test $\mathrm{dist}(x,y) \le \varepsilon$; the entire path collapses to one edge. Consequently the connectivity classes are exactly closed metric balls, and the connectivity threshold $\mathrm{connThreshold}(x,y) := \mathrm{dist}(x,y)$ — the exact, tight scale of merging — itself satisfies the strong triangle inequality, i.e. it is a structure-preserving map into the tropical (max-plus) semiring. We frame this as a *functorial tropical lower bound*: $\mathrm{dist}(x,y)$ is a certified, tight lower bound on every scale capable of connecting $x$ and $y$, and the threshold functor lands in max-plus algebra. We give complete proof sketches, an algorithmic treatment via single-linkage / minimum spanning trees, numerical demonstrations, and applications to topological data analysis, hierarchical clustering, and $p$-adic geometry. All results have been formally verified.

**Keywords:** Vietoris–Rips complex, ultrametric, non-Archimedean geometry, persistent homology, tropical semiring, max-plus algebra, single-linkage clustering, bottleneck distance, $p$-adic valuation.

---

## 1. Introduction

### 1.1 Motivation

The Vietoris–Rips construction is among the most widely used tools in topological data analysis (TDA). Given a finite metric sample $X$ and a scale parameter $\varepsilon$, one forms a graph (its $1$-skeleton) by joining points within distance $\varepsilon$, and studies how the topology of the resulting filtration evolves as $\varepsilon$ increases. The degree-zero (connected-components) information of this filtration is exactly the *single-linkage hierarchical clustering* of $X$: as $\varepsilon$ grows, clusters merge, and the record of merge-scales is a dendrogram.

A subtle but fundamental phenomenon governs this process. Path-connectivity in the Rips graph is a *transitive closure*: two points are connected if there is **any** chain of short edges between them, however long. The length of that chain can be enormous, and the endpoints can be far apart even though every edge is short. We call this the **Archimedean leak**: in an Archimedean metric, $n$ steps of size $\varepsilon$ can span a distance up to $n\varepsilon$. This is the so-called *chaining effect* that makes single-linkage clustering notoriously sensitive to bridges of intermediate points.

The purpose of this paper is to pin down exactly when the leak disappears — when connectivity becomes a faithful, leak-free measurement of distance — and to recognize the resulting structure as a clean instance of tropical (max-plus) algebra.

### 1.2 Summary of results

Let $(\alpha, \mathrm{dist})$ be a pseudometric space and let $\mathrm{Rips}_\varepsilon(\alpha)$ denote the Rips graph at scale $\varepsilon$, with adjacency $x \sim y \iff x \ne y \wedge \mathrm{dist}(x,y) \le \varepsilon$. Write $\mathrm{Reach}_\varepsilon(x,y)$ for path-connectivity (reachability) in $\mathrm{Rips}_\varepsilon(\alpha)$.

1. **Filtration monotonicity** (Theorem 3.1): $\varepsilon_1 \le \varepsilon_2 \Rightarrow \mathrm{Rips}_{\varepsilon_1}(\alpha) \subseteq \mathrm{Rips}_{\varepsilon_2}(\alpha)$.
2. **Functoriality of connectivity** (Theorem 3.2): reachability is monotone in $\varepsilon$.
3. **The Archimedean bound** (Theorem 4.1): a walk of length $n$ from $x$ to $y$ certifies only $\mathrm{dist}(x,y) \le n\varepsilon$.
4. **Ultrametric collapse** (Theorem 5.1): if $\alpha$ is ultrametric and $\varepsilon \ge 0$, then $\mathrm{Reach}_\varepsilon(x,y) \Rightarrow \mathrm{dist}(x,y) \le \varepsilon$.
5. **Connectivity = sublevel test** (Theorem 5.2): over an ultrametric space, $\mathrm{Reach}_\varepsilon(x,y) \iff \mathrm{dist}(x,y) \le \varepsilon$.
6. **Connectivity classes are balls** (Theorem 5.3): the reachable set of $x$ equals the closed ball $\overline{B}(x,\varepsilon)$.
7. **The tropical threshold functor** (Theorem 6.1, 6.2): $\mathrm{connThreshold}(x,y) := \mathrm{dist}(x,y)$ satisfies $\mathrm{connThreshold}(x,z) \le \max(\mathrm{connThreshold}(x,y), \mathrm{connThreshold}(y,z))$, and is the tight lower bound on connecting scale.

The crucial dichotomy is between item 3 (general: $\mathrm{dist} \le n\varepsilon$) and items 4–5 (ultrametric: $\mathrm{dist} \le \varepsilon$): ultrametricity deletes the multiplier $n$.

### 1.3 The bridge

The paper sits at the intersection of three research strands:

- **Metric filtrations / Vietoris–Rips graphs** — the geometric/topological side (TDA, persistent homology).
- **Tropical (max-plus) valuation algebra** — the algebraic side, where the relevant arithmetic of bottlenecks lives.
- **Ultrametric / valuation depth** — the number-theoretic side ($p$-adic valuations, non-Archimedean fields).

The ultrametric collapse is the hinge that connects all three: it is simultaneously a statement about connected components of a filtration, an identity in max-plus algebra, and a manifestation of the non-Archimedean (valuation) triangle inequality.

---

## 2. Preliminaries and Definitions

### 2.1 Pseudometric and ultrametric spaces

**Definition 2.1 (Pseudometric space).** A *pseudometric space* is a set $\alpha$ with a function $\mathrm{dist} : \alpha \times \alpha \to \mathbb{R}_{\ge 0}$ satisfying $\mathrm{dist}(x,x) = 0$, symmetry $\mathrm{dist}(x,y) = \mathrm{dist}(y,x)$, and the triangle inequality $\mathrm{dist}(x,z) \le \mathrm{dist}(x,y) + \mathrm{dist}(y,z)$. (Unlike a metric, distinct points may be at distance $0$.)

**Definition 2.2 (Ultrametric / non-Archimedean space).** A pseudometric space $\alpha$ is *ultrametric* (equivalently *non-Archimedean*) if it satisfies the **strong triangle inequality**:
$$ \mathrm{dist}(x,z) \le \max\bigl(\mathrm{dist}(x,y),\, \mathrm{dist}(y,z)\bigr) \qquad \text{for all } x,y,z. $$
Since $\max(a,b) \le a + b$ for $a, b \ge 0$, every ultrametric space is a pseudometric space; the converse fails.

**Examples.** (i) Any set with the discrete metric ($\mathrm{dist}(x,y) = 1$ for $x \ne y$). (ii) The $p$-adic numbers $\mathbb{Q}_p$ with $\mathrm{dist}(x,y) = p^{-v_p(x-y)}$, where $v_p$ is the $p$-adic valuation. (iii) The leaves of any rooted weighted tree, with distance equal to the height of the lowest common ancestor — equivalently, any dendrogram. (iv) Strings under the longest-common-prefix metric $\mathrm{dist}(s,t) = 2^{-\ell}$ where $\ell$ is the length of the longest common prefix.

A defining structural feature: in an ultrametric space, *every triangle is isosceles with the unequal side shortest*, and closed balls are **nested** — any two balls are either disjoint or one contains the other. This is the geometric origin of the tree-like ("laminar") structure.

### 2.2 The Rips graph

**Definition 2.3 (Rips graph).** For a pseudometric space $\alpha$ and a scale $\varepsilon \in \mathbb{R}$, the *Rips graph* (Vietoris–Rips $1$-skeleton) $\mathrm{Rips}_\varepsilon(\alpha)$ is the simple graph on vertex set $\alpha$ with adjacency
$$ x \sim_\varepsilon y \quad :\Longleftrightarrow\quad x \ne y \ \wedge\ \mathrm{dist}(x,y) \le \varepsilon. $$
It is symmetric (by symmetry of $\mathrm{dist}$) and loopless (by the $x \ne y$ clause), hence a well-defined simple graph.

**Definition 2.4 (Walk, length, reachability).** A *walk* of length $n$ from $x$ to $y$ is a sequence $x = v_0 \sim_\varepsilon v_1 \sim_\varepsilon \cdots \sim_\varepsilon v_n = y$ of edges. Two points are *reachable*, written $\mathrm{Reach}_\varepsilon(x,y)$, if there exists a walk (of any length, including the empty walk when $x = y$) connecting them. Reachability is the equivalence relation generated by adjacency; its classes are the connected components.

**Definition 2.5 (Connectivity threshold).** The *connectivity threshold* of a pair $(x,y)$ is
$$ \mathrm{connThreshold}(x,y) := \mathrm{dist}(x,y). $$
The name is justified by the main theorem: in an ultrametric space this is exactly the infimal scale at which $x$ and $y$ become reachable.

### 2.3 The tropical (max-plus) semiring

**Definition 2.6 (Max-plus semiring).** The *tropical max-plus semiring* is $(\mathbb{R} \cup \{-\infty\}, \oplus, \odot)$ with $a \oplus b := \max(a,b)$ and $a \odot b := a + b$. Inequalities of the form $f(x,z) \le \max(f(x,y), f(y,z))$ are precisely "tropical (sub)additivity" / the tropical triangle inequality: they say $f$ behaves additively-by-max, i.e. lands compatibly in the $\oplus = \max$ structure.

---

## 3. Functoriality of the Filtration

**Theorem 3.1 (Filtration monotonicity).** If $\varepsilon_1 \le \varepsilon_2$ then $\mathrm{Rips}_{\varepsilon_1}(\alpha) \le \mathrm{Rips}_{\varepsilon_2}(\alpha)$ (as a subgraph: every edge of the first is an edge of the second).

*Proof.* Let $x \sim_{\varepsilon_1} y$, i.e. $x \ne y$ and $\mathrm{dist}(x,y) \le \varepsilon_1$. Then $\mathrm{dist}(x,y) \le \varepsilon_1 \le \varepsilon_2$, so $x \sim_{\varepsilon_2} y$. $\square$

**Theorem 3.2 (Monotonicity of reachability — functoriality).** If $\varepsilon_1 \le \varepsilon_2$ and $\mathrm{Reach}_{\varepsilon_1}(x,y)$ then $\mathrm{Reach}_{\varepsilon_2}(x,y)$.

*Proof.* A walk in $\mathrm{Rips}_{\varepsilon_1}(\alpha)$ is, edge by edge, a walk in $\mathrm{Rips}_{\varepsilon_2}(\alpha)$ by Theorem 3.1; reachability is preserved under graph inclusion. $\square$

These two results express that $\varepsilon \mapsto \mathrm{Rips}_\varepsilon(\alpha)$ is a functor from the poset $(\mathbb{R}, \le)$ to graphs (and onward to $\pi_0$, the set of connected components). This is the standard filtration functoriality underlying persistent homology; we record it here in the self-contained setting because everything downstream is "what this functor does."

---

## 4. The General (Archimedean) Bound

**Theorem 4.1 (Archimedean leak bound).** In an arbitrary pseudometric space, if there is a walk $p$ of length $n$ from $x$ to $y$ in $\mathrm{Rips}_\varepsilon(\alpha)$, then
$$ \mathrm{dist}(x,y) \le n \cdot \varepsilon. $$

*Proof sketch.* Induct on the structure of the walk. The empty walk ($x = y$, $n = 0$) gives $\mathrm{dist}(x,x) = 0 \le 0 = 0 \cdot \varepsilon$. For a walk $x \sim_\varepsilon u$ followed by a walk $p'$ of length $n-1$ from $u$ to $y$, the inductive hypothesis gives $\mathrm{dist}(u,y) \le (n-1)\varepsilon$, and the first edge gives $\mathrm{dist}(x,u) \le \varepsilon$. The ordinary triangle inequality then yields
$$ \mathrm{dist}(x,y) \le \mathrm{dist}(x,u) + \mathrm{dist}(u,y) \le \varepsilon + (n-1)\varepsilon = n\varepsilon. \quad\square $$

**Remark 4.2 (Tightness and the leak).** The bound is tight: on the real line, the points $0, \varepsilon, 2\varepsilon, \ldots, n\varepsilon$ form a walk of length $n$ at scale $\varepsilon$ whose endpoints are exactly $n\varepsilon$ apart. The factor $n$ is unavoidable and is the quantitative content of the chaining effect. Notice the proof uses the "+" in the triangle inequality essentially: each step *adds* $\varepsilon$. The hypothesis $\varepsilon \ge 0$ is not even needed here — a positive-length walk forces $\varepsilon \ge \mathrm{dist} \ge 0$ automatically.

---

## 5. The Ultrametric Collapse

We now assume $\alpha$ is ultrametric. The strong triangle inequality replaces the "+" of Theorem 4.1 with a "max", and the multiplier $n$ vanishes.

**Theorem 5.1 (Ultrametric collapse, lower bound).** Let $\alpha$ be ultrametric and $\varepsilon \ge 0$. If $\mathrm{Reach}_\varepsilon(x,y)$, then $\mathrm{dist}(x,y) \le \varepsilon$.

*Proof sketch.* Choose any walk witnessing reachability and induct on its structure.
- **Base case (empty walk, $x = y$):** $\mathrm{dist}(x,y) = \mathrm{dist}(x,x) = 0 \le \varepsilon$, using $\varepsilon \ge 0$. (This is the only place $\varepsilon \ge 0$ is used, and it is essential — see Remark 5.4.)
- **Inductive step:** a walk from $x$ to $y$ decomposes as a first edge $x \sim_\varepsilon u$ (so $\mathrm{dist}(x,u) \le \varepsilon$) followed by a walk from $u$ to $y$; the inductive hypothesis gives $\mathrm{dist}(u,y) \le \varepsilon$. By the **strong** triangle inequality,
$$ \mathrm{dist}(x,y) \le \max\bigl(\mathrm{dist}(x,u),\, \mathrm{dist}(u,y)\bigr) \le \max(\varepsilon, \varepsilon) = \varepsilon. $$
The crucial difference from Theorem 4.1 is that $\max(\varepsilon,\varepsilon) = \varepsilon$, whereas $\varepsilon + \varepsilon = 2\varepsilon$. The max does not accumulate, so an arbitrarily long chain stays within $\varepsilon$. $\square$

**Theorem 5.2 (Connectivity = sublevel test).** Let $\alpha$ be ultrametric and $\varepsilon \ge 0$. Then
$$ \mathrm{Reach}_\varepsilon(x,y) \quad\Longleftrightarrow\quad \mathrm{dist}(x,y) \le \varepsilon. $$

*Proof sketch.* ($\Rightarrow$) is Theorem 5.1. ($\Leftarrow$): if $x = y$ the empty walk witnesses reachability; if $x \ne y$ and $\mathrm{dist}(x,y) \le \varepsilon$, then $x \sim_\varepsilon y$ is a single edge, hence a walk of length $1$. $\square$

This is the "sublevel graph" of the title: connectivity in the Rips filtration is computed by a single sublevel test on the distance, with no transitive closure needed.

**Theorem 5.3 (Connectivity classes are closed balls).** Let $\alpha$ be ultrametric and $\varepsilon \ge 0$. The connected component of $x$ is exactly the closed ball:
$$ \{\, y \mid \mathrm{Reach}_\varepsilon(x,y) \,\} \;=\; \overline{B}(x,\varepsilon) \;=\; \{\, y \mid \mathrm{dist}(x,y) \le \varepsilon \,\}. $$

*Proof.* Immediate from Theorem 5.2 (with $\mathrm{dist}(y,x) = \mathrm{dist}(x,y)$ by symmetry). $\square$

**Corollary 5.5 (Laminar / hierarchical clustering).** Since closed balls in an ultrametric space are nested (any two are disjoint or comparable), the partition of $\alpha$ into connected components of $\mathrm{Rips}_\varepsilon(\alpha)$ refines coherently as $\varepsilon$ decreases: the family of all components over all $\varepsilon \ge 0$ is *laminar* and forms a tree (a dendrogram). The Rips filtration of an ultrametric space *is* its canonical hierarchical clustering.

**Remark 5.4 (Both hypotheses are load-bearing).** The collapse fails if either hypothesis is dropped.
- *Without $\varepsilon \ge 0$:* the empty walk always makes $x$ reachable from itself, forcing $\mathrm{dist}(x,x) = 0 \le \varepsilon$; if $\varepsilon < 0$ this is false. So $\varepsilon \ge 0$ is necessary even for the reflexive case.
- *Without ultrametricity:* the real line at scale $\varepsilon$ connects $0$ to $n\varepsilon$ through the chain $0, \varepsilon, \ldots, n\varepsilon$, yet $\mathrm{dist}(0, n\varepsilon) = n\varepsilon \gg \varepsilon$. Theorem 4.1 is then the best possible statement.

---

## 6. The Tropical Connectivity-Threshold Functor

**Theorem 6.1 (Tropical triangle inequality for the threshold).** In an ultrametric space, for all $x,y,z$,
$$ \mathrm{connThreshold}(x,z) \;\le\; \max\bigl(\mathrm{connThreshold}(x,y),\, \mathrm{connThreshold}(y,z)\bigr). $$

*Proof.* By definition $\mathrm{connThreshold} = \mathrm{dist}$, so this is *verbatim* the strong triangle inequality of Definition 2.2. $\square$

The content of Theorem 6.1 is conceptual rather than technical: the quantity *produced* by the connectivity analysis (the merge-scale) obeys the very inequality (max-subadditivity) that *made the analysis work*. In the language of Definition 2.6, $\mathrm{connThreshold}$ is a map into the tropical max-plus semiring respecting its order structure — a **tropical functor** from the data cloud to max-plus algebra.

**Theorem 6.2 (Functorial tropical lower bound).** Let $\alpha$ be ultrametric and $\varepsilon \ge 0$. Then
$$ \mathrm{Reach}_\varepsilon(x,y) \quad\Longleftrightarrow\quad \mathrm{connThreshold}(x,y) \le \varepsilon. $$
Consequently $\mathrm{connThreshold}(x,y)$ is the *least* scale connecting $x$ and $y$: it is connecting for every $\varepsilon \ge \mathrm{connThreshold}(x,y)$, and every connecting scale satisfies $\varepsilon \ge \mathrm{connThreshold}(x,y)$. It is therefore a *tight, certified lower bound* on the connecting scale.

*Proof.* Restate Theorem 5.2 with $\mathrm{connThreshold} = \mathrm{dist}$. The "least scale" claim is the two directions of the iff: sufficiency for $\varepsilon \ge \mathrm{dist}(x,y)$, and necessity ($\varepsilon \ge \mathrm{dist}(x,y)$) for any connecting $\varepsilon$. $\square$

**Interpretation (the title, decoded).** "Functorial": $\varepsilon \mapsto \mathrm{Rips}_\varepsilon$ is a filtration functor (Theorems 3.1–3.2) and $\mathrm{connThreshold}$ is the induced map on merge-scales. "Tropical": the merge-scale lives in max-plus algebra (Theorem 6.1). "Lower bound": $\mathrm{dist}(x,y)$ certifies, tightly, every scale that can connect $x$ to $y$ (Theorem 6.2). "Valuation-depth sublevel graphs": over a valuation (ultrametric) space, the connectivity is computed by sublevel tests on distance (Theorem 5.2), the depth structure being the nested-ball tree.

---

## 7. Algorithms

The collapse has direct algorithmic content for finite point clouds. Throughout, $X = \{x_1, \ldots, x_m\}$ is a finite (pseudo)metric sample.

### 7.1 Bottleneck (min–max path) distance

For a general metric, the scale at which $x$ and $y$ first become Rips-connected is the **bottleneck distance**
$$ b(x,y) := \min_{\text{paths } \pi : x \to y} \ \max_{\text{edges } e \in \pi} \mathrm{dist}(e), $$
i.e. the minimum over all connecting paths of the longest edge on the path. This is exactly a min–max (tropical) shortest path. The Rips filtration connects $x$ and $y$ at scale $\varepsilon$ iff $b(x,y) \le \varepsilon$.

**Theorem 7.1 (Bottleneck = distance over ultrametrics).** If $\alpha$ is ultrametric, then $b(x,y) = \mathrm{dist}(x,y)$ for all $x,y$.

*Proof.* $b(x,y) \le \mathrm{dist}(x,y)$ always (take the one-edge path). Conversely $b(x,y) \ge \mathrm{dist}(x,y)$: any path realizing some max-edge value $\varepsilon$ exhibits reachability at scale $\varepsilon$, so by Theorem 5.1, $\mathrm{dist}(x,y) \le \varepsilon$; minimizing over paths gives $\mathrm{dist}(x,y) \le b(x,y)$. $\square$

This is the algorithmic restatement of the collapse: the bottleneck path distance and the metric distance, generally distinct, coincide exactly under the strong triangle inequality.

### 7.2 Minimum spanning tree / single-linkage

The bottleneck distances $b(x,y)$ for all pairs are read off from a **minimum spanning tree (MST)** of the complete distance graph: $b(x,y)$ equals the maximum edge weight on the unique MST path from $x$ to $y$ (the *minimax path* property). Building the MST (Kruskal/Prim, $O(m^2)$ for dense input) and recording the merge-scales yields the single-linkage dendrogram. Over an ultrametric space, Theorem 7.1 says these recorded merge-scales are exactly the pairwise distances — the dendrogram *reconstructs the ultrametric exactly*. This is the classical equivalence of single-linkage clustering and the *subdominant ultrametric*, here certified to be exact when the input is already ultrametric.

### 7.3 Sublevel-graph component counting

Because of Theorem 5.2, computing $\pi_0$ of $\mathrm{Rips}_\varepsilon(\alpha)$ over an ultrametric reduces to grouping points by the equivalence "$\mathrm{dist} \le \varepsilon$" (which is genuinely transitive there, by Theorem 6.1) — a union–find pass over only the edges with weight $\le \varepsilon$, no transitive closure beyond the (already transitive) thresholded relation. The component count is antitone in $\varepsilon$ and equals the number of distinct closed $\varepsilon$-balls.

---

## 8. Worked Numerical Examples

### 8.1 $p$-adic integers

Take $\mathbb{Z}$ with the $2$-adic distance $\mathrm{dist}(a,b) = 2^{-v_2(a-b)}$, where $v_2(n)$ is the exponent of $2$ in $n$ (and $v_2(0) = +\infty$, so $\mathrm{dist}(a,a) = 0$). Then:
- $\mathrm{dist}(0,1) = 2^0 = 1$ (since $v_2(1) = 0$);
- $\mathrm{dist}(0,2) = 2^{-1} = 0.5$;
- $\mathrm{dist}(0,4) = 2^{-2} = 0.25$;
- $\mathrm{dist}(2,4) = 2^{-v_2(2)} = 2^{-1} = 0.5$.

Check the strong triangle inequality on $(0,2,4)$: $\mathrm{dist}(0,4) = 0.25 \le \max(0.5, 0.5) = 0.5$. ✓. At scale $\varepsilon = 0.5$, the chain $0 \sim 2 \sim 4$ exists; the collapse predicts $\mathrm{dist}(0,4) \le 0.5$, confirmed (it is $0.25$). No leak: there is no way to chain $2$-adically small steps to reach a $2$-adically distant point.

### 8.2 Dendrogram (cophenetic) ultrametric

Consider four leaves $a,b,c,d$ of a tree, with merge heights: $\{a,b\}$ merge at $1$, $\{c,d\}$ merge at $2$, and $\{a,b\}\cup\{c,d\}$ merge at $3$. The cophenetic distances are $d(a,b)=1$, $d(c,d)=2$, and $d(a,c)=d(a,d)=d(b,c)=d(b,d)=3$. This is ultrametric. At $\varepsilon = 2$: components are $\{a,b\}$ and $\{c,d\}$ — exactly two closed $2$-balls. At $\varepsilon = 3$: a single component. The merge-scales recovered from the Rips filtration are precisely $1,2,3$.

### 8.3 Archimedean contrast on $\mathbb{R}$

On $\mathbb{R}$ with the usual metric, the five points $0,1,2,3,4$ at scale $\varepsilon = 1$ form a connected chain, yet $\mathrm{dist}(0,4) = 4 = 4\varepsilon$. Theorem 4.1 gives exactly $\mathrm{dist} \le 4\cdot 1$, tight; Theorem 5.1's conclusion $\mathrm{dist} \le 1$ is false here — as it must be, since $\mathbb{R}$ is not ultrametric.

---

## 9. Applications

- **Topological data analysis.** When data is (approximately) hierarchical, the degree-$0$ persistence barcode of the Rips filtration faithfully records the true pairwise distances as death-scales, with no chaining artifacts. The collapse is a guarantee of fidelity for $\pi_0$ persistence on ultrametric inputs.
- **Hierarchical clustering.** Single-linkage clustering computes the subdominant ultrametric; on inputs that are already ultrametric, the output dendrogram reconstructs the metric exactly (Sections 7.1–7.2). The collapse explains and certifies the well-known robustness of single-linkage on tree-structured data.
- **Phylogenetics.** Evolutionary distances under a molecular clock are ultrametric; the collapse says that clustering by reachability recovers divergence times exactly.
- **$p$-adic and valuation geometry.** Non-Archimedean fields are immune to chaining: connectivity equals proximity. This underlies the rigid, tree-like structure of Berkovich spaces and $p$-adic analytic geometry.
- **Tropical optimization.** The connectivity threshold is a bottleneck (min–max) quantity; recognizing it as a max-plus functor connects clustering to tropical shortest-path and scheduling algebra.

---

## 10. Discussion

The technical heart of the paper is a single substitution: in the inductive step bounding the distance across a walk, the ordinary triangle inequality contributes $\mathrm{dist}(x,u) + \mathrm{dist}(u,y) \le 2\varepsilon$, while the strong triangle inequality contributes $\max(\mathrm{dist}(x,u),\mathrm{dist}(u,y)) \le \varepsilon$. Iterated over a length-$n$ walk, the first gives $n\varepsilon$, the second gives $\varepsilon$. That the "+/max" dichotomy is exactly the Archimedean/non-Archimedean dichotomy, and exactly the classical-algebra/tropical-algebra dichotomy, is what makes the result a genuine bridge rather than a mere computation.

Two design choices deserve comment. First, we work with **pseudometrics** (allowing $\mathrm{dist}(x,y)=0$ for $x\ne y$), which costs nothing and broadens applicability (e.g., quotient metrics). Second, the hypothesis $\varepsilon \ge 0$ is genuinely needed only to handle the reflexive empty walk; we keep it because it is the natural regime for filtrations and because the statement is false without it.

The result is sharp in the precise sense of Remark 5.4: dropping either hypothesis produces an explicit counterexample, and the general bound (Theorem 4.1) is tight. This sharpness is what elevates the collapse from a sufficient condition to a near-characterization, motivating the converse conjecture below.

---

## 11. Future Directions

These are stated as falsifiable conjectures for follow-up work.

**C1 — Converse: bottleneck = distance characterizes ultrametricity.** For a pseudometric space, the equivalence $\mathrm{Reach}_\varepsilon(x,y) \iff \mathrm{dist}(x,y) \le \varepsilon$ holding for **all** $\varepsilon \ge 0$ and all $x,y$ should be *equivalent* to ultrametricity. The forward direction is Theorem 5.2; the converse would derive $\mathrm{dist}(x,z) \le \max(\mathrm{dist}(x,y),\mathrm{dist}(y,z))$ from the iff applied to the two-edge walk $x \to y \to z$. This would make the collapse a **characterization** of non-Archimedean geometry.

**C2 — Functorial component-count lower bound.** For a finite ultrametric space, the number of connected components of $\mathrm{Rips}_\varepsilon$ equals the number of distinct closed $\varepsilon$-balls, is antitone in $\varepsilon$, and is a certified lower bound for the component count of any dominating pseudometric $d' \ge d$ at the same scale (functoriality under $1$-Lipschitz domination), upgrading reachability monotonicity to a quantitative $\pi_0$ inequality.

**C3 — Valuation-depth = persistence-length identity.** Define the *valuation depth* of $(x,y)$ as the length of the maximal chain of nested $\varepsilon$-balls separating them as $\varepsilon$ ranges over $[0, \mathrm{dist}(x,y)]$. Conjecture: this depth equals the number of distinct finite death-scales in the $\pi_0$ persistence barcode of the Rips filtration restricted to $\{x,y\}$ and their ancestors — depth is the tropical length of the merge tree, bridging valuation depth and persistent homology.

**C4 — Monoidality on products.** The connectivity-threshold functor should be monoidal for the $\max$-product metric on $\alpha \times \beta$, $\mathrm{dist}((a,b),(a',b')) = \max(\mathrm{dist}(a,a'), \mathrm{dist}(b,b'))$, with $\mathrm{connThreshold}((a,b),(a',b')) = \max(\mathrm{connThreshold}(a,a'), \mathrm{connThreshold}(b,b'))$ — the tropical functor preserves products.

---

## 12. Conclusion

In a general metric space, connectivity in the Vietoris–Rips graph is a leaky proxy for distance: chains of short edges span long distances, and the best general guarantee is $\mathrm{dist} \le n\varepsilon$. The strong triangle inequality of ultrametric (non-Archimedean, valuation) geometry seals this leak completely: reachability at scale $\varepsilon \ge 0$ is *equivalent* to $\mathrm{dist} \le \varepsilon$, connectivity classes are exactly closed balls, and the merge-scale functor lands in the tropical max-plus semiring as a tight, certified lower bound on connecting scale. The "+/max" substitution at the heart of the proof is simultaneously the Archimedean/non-Archimedean and the classical/tropical dichotomy, making the ultrametric collapse a faithful bridge between metric filtrations, valuation geometry, and tropical algebra. All results have been formally verified.
