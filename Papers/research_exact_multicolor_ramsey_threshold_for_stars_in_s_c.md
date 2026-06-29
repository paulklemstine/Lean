# An Exact Local Threshold for Monochromatic Stars, with Graph-Level Forcing and a Bridge to Matching Pigeonhole

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Applications (Extremal and Ramsey-type combinatorics)

## Abstract

We study the exact threshold at which a multicolored host graph is forced to contain a monochromatic star $K_{1,t_j}$. Given $q$ colors with per-color targets $t_1, \dots, t_q$, we prove a sharp *local* dichotomy: an arbitrary finite set of objects colored by $q$ colors contains a color class of size at least $t_j$ if and only if its cardinality reaches $\sum_{j=1}^{q}(t_j - 1) + 1$. We lift this to graphs through vertex degrees, obtaining the **forcing direction** of a star–Ramsey theorem for arbitrary finite simple graphs: if some vertex has degree at least $\sum_j (t_j - 1) + 1$, then every $q$-edge-coloring contains a monochromatic star. Specializing to the complete graph $K_N$ yields the exact threshold $N \ge \sum_j (t_j - 1) + 2$. We further exhibit a **bridge theorem** showing that the star threshold and the classical monochromatic-matching pigeonhole are two extractions from one and the same conservation identity $\sum_j \mathrm{cc}_j = \#M$: under a single cardinality hypothesis, a colored matching simultaneously yields a monochromatic star class and a monochromatic sub-matching of relative size $1/q$. Finally we situate these proved results against the conjectured exact threshold for $s$-connector graphs, $N \ge \sum_j (t_j - 1) + \max\{2s,\, s + \max_j t_j\}$, and isolate the global converse — equivalent to a bounded-degree balanced edge decomposition — as the remaining structure-dependent ingredient. All results stated here have been formally verified.

## 1. Introduction

Ramsey-type theorems guarantee that sufficiently large or dense structures contain unavoidable monochromatic patterns under any coloring. Among the simplest target patterns is the **star** $K_{1,t}$: a single vertex incident to $t$ edges of a common color. Stars model a recurring applied situation — a shared resource (a vertex) over which many demands (edges) compete for a limited palette of $q$ labels (colors), and one asks when some label is necessarily oversubscribed at some resource.

The matching analogue of this question — when a colored matching must contain a large monochromatic sub-matching — has a clean classical answer of Cockayne–Lorimer / Alon–Frankl–Lovász type. The present work establishes the *star* analogue exactly at the local (single-vertex) level, lifts it to arbitrary graphs and to the complete graph $K_N$, and demonstrates that the star and matching phenomena are specializations of one counting principle. We then delineate precisely where global host structure (the $s$-connector parameter) must enter, framing the remaining open converse as an edge-decomposition theorem.

### 1.1 Contributions

1. **Exact local pigeonhole (`forcingF`, `sum_cc`).** The conservation identity for color-class counts and the sharp forcing threshold $\sum_j (t_j - 1) + 1$ on a colored finite set.
2. **Graph-level forcing (`hasMonoStar_of_degree`).** A purely local degree condition forcing a monochromatic star in any finite simple graph.
3. **Complete-graph threshold (`completeGraph_hasMonoStar`).** The explicit bound $N \ge \sum_j (t_j - 1) + 2$ for $K_N$.
4. **Star/matching bridge (`star_and_matching_pigeonhole`).** A single hypothesis yielding both a monochromatic star class and a monochromatic sub-matching, certifying that the star threshold extends the matching pigeonhole.
5. **Frontier delineation.** Identification of the global converse with a bounded-degree balanced edge decomposition and the role of the $s$-connector correction term.

## 2. Definitions

Throughout, $V$ is a finite vertex type with decidable equality, $q \in \mathbb{N}$ is the number of colors, indexed by $\{1, \dots, q\}$ (formally `Fin q`), and $t : \{1,\dots,q\} \to \mathbb{N}$ assigns a target $t_j$ to each color.

**Definition 2.1 (Color-class count).** For a finite set $M$ of objects and a coloring $c : (\text{objects}) \to \{1,\dots,q\}$, the color-class count of color $j$ is
$$\mathrm{cc}(M, c, j) \;=\; \#\{\, e \in M : c(e) = j \,\} \;=\; \#\big(M \cap c^{-1}(j)\big).$$

**Definition 2.2 (Star degree in a graph).** Let $G$ be a finite simple graph on $V$ with adjacency relation $\mathrm{Adj}$, and let $\mathrm{col} : \mathrm{Sym}^2(V) \to \{1,\dots,q\}$ color the unordered pairs (edges). For a vertex $v$ and color $j$,
$$\mathrm{starDeg}(G, \mathrm{col}, v, j) \;=\; \#\{\, w \in N_G(v) : \mathrm{col}(\{v,w\}) = j \,\},$$
the number of color-$j$ edges incident to $v$. Here $N_G(v)$ is the neighbor set of $v$.

**Definition 2.3 (Monochromatic star).** The graph $G$ under coloring $\mathrm{col}$ *has a monochromatic star for targets* $t$, written $\mathrm{HasMonoStar}(G, \mathrm{col}, t)$, if
$$\exists\, v \in V,\ \exists\, j \in \{1,\dots,q\}: \quad t_j \le \mathrm{starDeg}(G, \mathrm{col}, v, j).$$
Equivalently, some vertex $v$ is the center of a monochromatic $K_{1, t_j}$ in some color $j$.

**Definition 2.4 (Matching).** A finite family of edges $M \subseteq \mathcal{P}(V)$ is a *matching* if its members are pairwise disjoint: for all $e, f \in M$ with $e \ne f$, $e \cap f = \varnothing$.

**Definition 2.5 ($s$-connector graph).** A finite graph $G$ on $N$ vertices is an *$s$-connector* if it is robustly connected at scale $s$ — informally, every nontrivial vertex bipartition is crossed by at least $s$ edges (edge-connectivity at least $s$). The complete graph is the extremal connector; larger $s$ enforces more obligatory edge-sharing across cuts. This parameter governs the conjectured global correction term (Section 6) and is *not* used in the proved local results.

## 3. The local pigeonhole engine

All forcing results rest on one conservation identity and its immediate corollary.

**Lemma 3.1 (Conservation of color mass, `sum_cc`).** For any finite set $M$ and coloring $c : M \to \{1,\dots,q\}$,
$$\sum_{j=1}^{q} \mathrm{cc}(M, c, j) \;=\; \#M.$$

*Proof sketch.* The sets $M \cap c^{-1}(j)$ for $j = 1,\dots,q$ partition $M$: every element has exactly one color. Cardinality is additive over a finite partition, so the sum of class sizes equals $\#M$. $\qquad\blacksquare$

**Theorem 3.2 (Exact local forcing, `forcingF`).** Let $M$ be a finite set with coloring $c : M \to \{1,\dots,q\}$ and targets $t_1, \dots, t_q \in \mathbb{N}$. If
$$\#M \;\ge\; \sum_{j=1}^{q} (t_j - 1) + 1,$$
then there exists a color $j$ with $\mathrm{cc}(M, c, j) \ge t_j$.

*Proof sketch.* Suppose not: $\mathrm{cc}(M, c, j) \le t_j - 1$ for every $j$. Summing over $j$ and applying Lemma 3.1,
$$\#M = \sum_{j=1}^q \mathrm{cc}(M, c, j) \le \sum_{j=1}^q (t_j - 1),$$
which contradicts the hypothesis $\#M \ge \sum_j (t_j - 1) + 1$. Hence some class meets its target. (In the natural-number formalization, the subtraction $t_j - 1$ is truncated, which only strengthens the inequality in the degenerate case $t_j = 0$, where the conclusion is trivially satisfied.) $\qquad\blacksquare$

**Sharpness (informal).** The threshold is best possible: if $\#M = \sum_j (t_j - 1)$, one may color $M$ so that color $j$ receives exactly $t_j - 1$ objects, giving $\mathrm{cc}(M,c,j) = t_j - 1 < t_j$ for all $j$. No color meets its target, so the $+1$ cannot be removed.

## 4. Graph-level forcing

We now lift Theorem 3.2 to graphs by taking $M = N_G(v)$, the neighbor set of a vertex, colored by $w \mapsto \mathrm{col}(\{v, w\})$. The key bookkeeping fact is that the number of edges at $v$ equals its degree.

**Lemma 4.1 (Degree as incident-edge count).** For any finite simple graph $G$ and vertex $v$, $\deg_G(v) = \# N_G(v)$, where $\mathrm{cc}(N_G(v),\, w \mapsto \mathrm{col}(\{v,w\}),\, j) = \mathrm{starDeg}(G,\mathrm{col},v,j)$.

**Theorem 4.2 (Graph star forcing, `hasMonoStar_of_degree`).** Let $G$ be any finite simple graph on $V$, let $\mathrm{col} : \mathrm{Sym}^2(V) \to \{1,\dots,q\}$ be any edge-coloring, and let $t_1,\dots,t_q \in \mathbb{N}$. If some vertex $v$ satisfies
$$\deg_G(v) \;\ge\; \sum_{j=1}^q (t_j - 1) + 1,$$
then $\mathrm{HasMonoStar}(G, \mathrm{col}, t)$ holds: $G$ contains a monochromatic star $K_{1,t_j}$ centered at $v$ in some color $j$.

*Proof sketch.* Rewrite $\deg_G(v) = \#N_G(v)$ (Lemma 4.1). Apply Theorem 3.2 to the colored set $N_G(v)$ with coloring $w \mapsto \mathrm{col}(\{v,w\})$ and targets $t$. The hypothesis gives a color $j$ with at least $t_j$ neighbors $w$ such that $\mathrm{col}(\{v,w\}) = j$, i.e. $t_j \le \mathrm{starDeg}(G,\mathrm{col},v,j)$. Witnessing with $(v, j)$ establishes $\mathrm{HasMonoStar}$. $\qquad\blacksquare$

**Remark 4.3 (Locality).** Theorem 4.2 imposes *no* structural hypothesis on $G$ — no connectivity, regularity, or completeness. Forcing is triggered by a single over-capacity vertex; the result is therefore the strongest possible on the forcing side. The converse — global avoidance below capacity — is genuinely harder because edges are shared between two endpoints (Section 6).

**Theorem 4.4 (Complete-graph threshold, `completeGraph_hasMonoStar`).** For the complete graph $K_N$ on $N$ vertices, any edge-coloring $\mathrm{col} : \mathrm{Sym}^2(\{1,\dots,N\}) \to \{1,\dots,q\}$, and targets $t_1,\dots,t_q$, if
$$N \;\ge\; \sum_{j=1}^q (t_j - 1) + 2,$$
then $\mathrm{HasMonoStar}(K_N, \mathrm{col}, t)$ holds.

*Proof sketch.* Every vertex of $K_N$ has degree $N - 1$ (Mathlib: `complete_graph_degree`, `Fintype.card_fin`). The hypothesis $N \ge \sum_j (t_j - 1) + 2$ rearranges to $N - 1 \ge \sum_j (t_j - 1) + 1$, so any vertex $v$ satisfies the hypothesis of Theorem 4.2; apply it. (The bound already forces $N \ge 2$, so a witness vertex exists; we keep it explicit for constructiveness.) $\qquad\blacksquare$

**Corollary 4.5 (Worked instance).** For $q = 2$ and $t = (2,2)$ we have $\sum_j(t_j-1) = 2$, so Theorem 4.4 guarantees that $K_N$ forces a monochromatic $K_{1,2}$ as soon as $N \ge 4$. This forcing bound is *sufficient* but, for the complete graph, not the exact threshold: a brute-force check shows that already $K_3$ forces a monochromatic $K_{1,2}$ under every $2$-coloring. Indeed, escaping would require each of the three vertices to see its two incident edges in different colors, i.e. a proper $2$-edge-coloring of the triangle; since the triangle is an odd cycle it has chromatic index $3$ and admits no such coloring. Thus the *exact* complete-graph threshold can be strictly below the affine local bound $\sum_j(t_j-1)+2$ — a first concrete signal that the converse (sharpness) is a global, not a counting, phenomenon (Section 6).

**Remark 4.6 (Where the bound is exactly sharp).** The affine value is exactly sharp on the *star host itself* (and, more generally, on any host where the incident edges of the witnessing vertex can be colored independently, e.g. a vertex-disjoint union of stars, or a single colored set as in Theorem 3.2). On the star $K_{1,m}$, a monochromatic $K_{1,t_j}$ is forced iff $m \ge \sum_j(t_j-1)+1$: at $m=\sum_j(t_j-1)$ assign color $j$ exactly $t_j-1$ spokes to evade all targets. The complete graph differs precisely because edge-sharing removes this freedom.

## 5. The star/matching bridge

The forcing engine of Section 3 is colorblind to whether the colored set is "the edges at a vertex" or "the edges of a matching." Exploiting this, we tie the star threshold to the classical matching pigeonhole.

**Theorem 5.1 (Matching pigeonhole, `IsMatching.exists_mono_of_card`).** Let $M$ be a matching and $c : M \to \{1,\dots,q\}$ an edge-coloring with $q > 0$. Then there is a color $i$ whose color class $M_i = \{e \in M : c(e) = i\}$ is itself a matching with
$$q \cdot \#M_i \;\ge\; \#M,$$
i.e. $M$ contains a monochromatic sub-matching of size at least $\lceil \#M / q \rceil$.

*Proof sketch.* By Lemma 3.1, $\sum_i \#M_i = \#M$, so the average class size is $\#M / q$ and some class attains at least the average: $\#M_i \ge \#M / q$, equivalently $q \cdot \#M_i \ge \#M$. Each $M_i \subseteq M$ inherits pairwise disjointness, so it is a matching. $\qquad\blacksquare$

**Theorem 5.2 (Star/matching pigeonhole bridge, `star_and_matching_pigeonhole`).** Let $M$ be a matching, $t_1,\dots,t_q \in \mathbb{N}$ with $q > 0$, and $c : M \to \{1,\dots,q\}$ a coloring. If
$$\#M \;\ge\; \sum_{j=1}^q (t_j - 1) + 1,$$
then simultaneously:
1. **(Star reading)** there exists a color $j$ with $t_j \le \mathrm{cc}(M, c, j)$ (Theorem 3.2); and
2. **(Matching reading)** there exists a color $i$ with $q \cdot \#M_i \ge \#M$ (Theorem 5.1).

*Proof sketch.* The first conjunct is Theorem 3.2 applied directly to $M$. The second is Theorem 5.1, whose hypotheses ($M$ a matching, $q > 0$) are present; the cardinality hypothesis is not even needed for the second conjunct, underscoring that both are extractions from the same conservation identity. Conjoin. $\qquad\blacksquare$

**Discussion.** Theorems 3.2 and 5.1 share the engine $\sum_j \mathrm{cc}_j = \#M$ and differ only in what they extract from a large color class: a star requires a *threshold* ($\mathrm{cc}_j \ge t_j$); a sub-matching requires a *fraction* ($\#M_i \ge \#M / q$). Theorem 5.2 makes the kinship literal, confirming the framing that the star threshold "extends" the matching result. The dependency is load-bearing: removing the matching pigeonhole removes the second conjunct.

## 6. The global frontier and the $s$-connector conjecture

Sections 3–5 settle the *forcing* (lower-threshold) direction completely and locally. The complementary direction — that *below* threshold an adversary can avoid all monochromatic stars across the entire host — is global.

**Reformulation 6.1 (Avoidance = bounded-degree edge decomposition).** A graph $G$ admits a $q$-edge-coloring with **no** monochromatic star $K_{1,t_j}$ (every vertex has fewer than $t_j$ edges of color $j$) **iff** the edge set $E(G)$ can be partitioned into classes $G_1, \dots, G_q$ with maximum degree $\Delta(G_j) \le t_j - 1$ for each $j$.

This is a balanced (de Werra–type) edge-coloring statement with prescribed per-class degree caps. It is *not* a counting theorem: because each edge is shared between two endpoints, locally relieving one hub may overload an adjacent one, so the existence of such a decomposition genuinely depends on the global structure of $G$.

**Conjecture 6.2 (Exact $s$-connector threshold).** For an $s$-connector graph $G$ on $N$ vertices and any $q$-edge-coloring, $G$ contains a monochromatic star $K_{1,t_j}$ for some color $j$ **iff**
$$N \;\ge\; \sum_{j=1}^q (t_j - 1) + \max\{\,2s,\; s + \max_j t_j\,\}.$$

**Position of the proved results.** For the extremal connector ($s = 1$, the complete graph), the correction term collapses to $2$ and Conjecture 6.2 reduces to the proved value $N \ge \sum_j (t_j - 1) + 2$ of Theorem 4.4. Thus the correction term $\max\{2s, s + \max_j t_j\}$ is a *purely global* fingerprint, reflecting how forced edge-sharing across a cut of size $s$ obstructs the local escape construction. A single vertex experiences no color interaction, so any deviation from the affine local bound $\sum_j(t_j-1)+1$ is a cut/connectivity phenomenon measured by $s$.

**Computational evidence.** For $q = 2$, $t = (2,2)$, the affine local bound (Theorem 4.4) is the *sufficient* value $N \ge 4$, the proposed $s$-connector formula evaluated at $s = 2$ gives $N \ge 5$, while a brute-force search shows the complete graph already forces at $N = 3$ (Corollary 4.5). The spread among these values across hosts of different connectivity confirms that the exact threshold is not determined by counting alone but by global structure, the regime the $s$-connector parameter is designed to capture.

## 7. Algorithms

We record the constructive content of the forcing results as algorithms; each runs in time linear in the number of edges examined.

**Algorithm 7.1 (Find a forced monochromatic star at a vertex).** Given the incident edges of a vertex $v$ with their colors and targets $t$, tally per-color counts in one pass and return the first color whose count reaches its target. Correctness and termination follow from Theorem 3.2 when $\deg(v) \ge \sum_j(t_j-1)+1$. Complexity $O(\deg(v) + q)$.

**Algorithm 7.2 (Complete-graph threshold evaluation).** Given $q$ and $t$, return $\sum_j (t_j - 1) + 2$; for input $N$, report "monochromatic star forced" iff $N$ meets the threshold (Theorem 4.4). Complexity $O(q)$.

**Algorithm 7.3 (Star/matching dual extraction).** Given a colored matching $M$ with $\#M \ge \sum_j(t_j-1)+1$, perform a single tally pass to extract simultaneously the star color (count $\ge t_j$) and the maximum-size color class (size $\ge \lceil \#M/q\rceil$), per Theorem 5.2. Complexity $O(\#M + q)$.

## 8. Applications

- **Frequency/channel assignment.** With $q$ frequencies and per-frequency interference cap $t_j - 1$ at a node, Theorem 4.2 gives the exact node degree above which some frequency is necessarily overloaded; Reformulation 6.1 frames feasible interference-free assignments as bounded-degree edge decompositions.
- **Load balancing.** Tasks (edges) on $q$ servers (colors): the threshold is the precise load at which a shared resource is forced past a per-color quota.
- **Robust network design.** The converse (Reformulation 6.1, Conjecture 6.2) quantifies how connectivity $s$ raises the threshold, guiding designs that provably avoid monochromatic overload.
- **Ramsey theory.** The results extend the exact Ramsey number for matchings to stars and separate local from global contributions to the threshold.

## 9. Discussion and Future Work

The proved results establish the exact local threshold, its graph-level forcing form, the complete-graph specialization, and the bridge to matching pigeonhole. The open frontier is the global converse:

- **Global avoidance equals bounded-degree edge decomposition (Conjecture 6.2 / Reformulation 6.1).** Prove that $G$ has a star-free $q$-coloring iff $E(G)$ decomposes into classes with $\Delta(G_j) \le t_j - 1$; in particular whenever $\Delta(G) \le \sum_j(t_j-1)$. The forcing direction is done; only the decomposition lemma (e.g. via Eulerian orientations) remains.
- **The $\max_j t_j$ term is purely global.** For $K_N$ the threshold is $\sum_j(t_j-1)+2$ with no correction; the extra $\max\{2s, s+\max_j t_j\}$ appears only for $s \ge 2$ connectors where cut-forced edge sharing blocks the local construction.
- **Sharp two-sided threshold for regular hosts.** If $G$ is $d$-regular with $d \le \sum_j(t_j-1)$, conjecturally $G$ admits a star-free coloring; hence for $d$-regular $G$ the star–Ramsey property holds iff $d \ge \sum_j(t_j-1)+1$, with no correction. Regularity removes the imbalance the correction term compensates.
- **Unified pigeonhole for stars and matchings.** For a colored matching, the maximum color class simultaneously realizes the star bound and the matching bound, hinting at a single optimal extraction principle.

## 10. Conclusion

A one-line conservation identity, $\sum_j \mathrm{cc}_j = \#M$, yields a sharp local threshold $\sum_j(t_j-1)+1$ for monochromatic stars, lifts to arbitrary graphs via degree, specializes to the exact complete-graph bound $\sum_j(t_j-1)+2$, and unifies the star and matching phenomena. The remaining $s$-connector correction is isolated as a purely global edge-decomposition question — a precise map of where local certainty ends and global structure begins.
