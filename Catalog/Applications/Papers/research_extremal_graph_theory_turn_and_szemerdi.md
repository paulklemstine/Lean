# Extremal Graph Theory: Turán, Kruskal–Katona, Triangle Removal, and Roth

**Author:** Aristotle
**Date:** 2026-06-27
**Domain:** Novelty / Extremal Combinatorics

## Abstract

We present a unified, fully formalized development of four pillars of extremal
combinatorics, together with two cross-domain bridges and a foundational theory
of graph saturation. We establish **Turán's theorem** in both an integer and a
real density form — a $K_{r+1}$-free graph on $n$ vertices has at most
$\left(1 - 1/r\right) n^2/2$ edges — and specialize it to **Mantel's theorem**
($n^2/4$ for triangle-free graphs). We bridge Mantel's bound to Ramsey theory:
on at least six vertices, a triangle-free graph forces a triangle in its
complement, fusing the extremal and Ramsey viewpoints at $R(3,3) = 6$. We extract
the **Kruskal–Katona** shadow bound $\binom{k}{r} \le |\mathcal A| \Rightarrow
\binom{k}{r-1} \le |\partial \mathcal A|$, deduce that iterated shadows of dense
uniform families never vanish prematurely, and bridge it to graphs: a graph with
at least $\binom{k}{3}$ triangles has at least $\binom{k}{2}$ edges. We package
the **triangle removal lemma** in textbook, contrapositive, and dichotomy forms,
and use the downstream asymptotics to prove **Roth's theorem** on $3$-term
arithmetic progressions, both as a density limit $r_3(N)/N \to 0$ and in the
qualitative form "frequently-dense sets contain a $3$-AP." Finally we build the
basic theory of **saturation numbers**, proving existence of saturated graphs,
the inequality $\mathrm{sat}(n,H) \le \mathrm{ex}(n,H)$, the apex-join edge count,
exact edge counts for the matching-plus-isolated family, and the clique
saturation bound $\mathrm{sat}(n, K_{r+1}) \le e(T(n,r))$. We state the
Cameron–Puleo saturation recurrence as a formal conjecture. All results are
proved with no unverified assumptions.

## 1. Introduction

Extremal graph theory studies the maximum or minimum amount of local structure
(edges, cliques, set members) a combinatorial object may carry subject to a
forbidden-substructure constraint. The unifying phenomenon is that *abundance
forces structure*: beyond a sharp, computable threshold, a forbidden pattern
becomes unavoidable. This paper develops four cornerstone instances of that
principle and ties them together.

The four pillars are:

1. **Turán / Mantel** — too many edges force a clique.
2. **Kruskal–Katona** — too many uniform sets force a large shadow.
3. **Triangle removal (Szemerédi regularity)** — robust triangle presence forces
   cubically many triangles.
4. **Roth** — too many integers force an arithmetic progression.

We additionally develop the dual *saturation* theory, which minimizes edges over
maximally-cautious graphs.

### Notation and conventions

Throughout, $G$ denotes a finite simple graph on a vertex type $V$ with
$n = |V|$. We write $e(G)$ for its number of edges, $\#G.\mathtt{edgeFinset}$ in
the formalization. A graph is $K_{r+1}$-**free** (clique-free of order $r+1$) if
it contains no set of $r+1$ pairwise-adjacent vertices. The **Turán graph**
$T(n,r)$ is the complete $r$-partite graph on $n$ vertices with parts as equal as
possible. For a family $\mathcal A$ of finite sets, $\partial \mathcal A$ denotes
its **shadow** and $\partial^{[i]}\mathcal A$ its $i$-th iterated shadow. A set
$\mathcal A$ is **$r$-uniform** (`Sized r`) if every member has exactly $r$
elements. $\binom{k}{r}$ is the binomial coefficient `k.choose r`. We write
$\mathrm{ThreeAPFree}(A)$ for the property that $A$ contains no nontrivial 3-term
arithmetic progression, and $r_3(N)$ (`rothNumberNat N`) for the size of the
largest $3$-AP-free subset of $\{0,\dots,N-1\}$.

## 2. Turán's theorem and Mantel's theorem

### 2.1 The integer edge bound

**Theorem (`turan_edge_bound_nat`).** *Let $G$ be a finite simple graph on $V$
with $n = |V|$. If $G$ is $K_{r+1}$-free, then*
$$ 2r\, e(G) \le (r-1)\, n^2. $$

*Proof sketch.* Among all $K_{r+1}$-free graphs on $n$ vertices, the Turán graph
$T(n,r)$ is extremal: by `SimpleGraph.CliqueFree.card_edgeFinset_le` we have
$e(G) \le e(T(n,r))$. Mathlib's exact count
`card_edgeFinset_turanGraph` and the looser
`mul_card_edgeFinset_turanGraph_le` give
$2r\, e(T(n,r)) \le (r-1)n^2$. Chaining a `Nat.mul_le_mul_left` step with this
inequality closes the goal. $\square$

This integer form is chosen deliberately: it avoids natural-number truncation
issues until the casting boundary, where we lift to the reals.

### 2.2 The real density form

**Theorem (`turan_edge_bound_real`).** *If $G$ is $K_{r+1}$-free and $r \ge 1$,
then*
$$ e(G) \le \left(1 - \frac{1}{r}\right)\frac{n^2}{2}. $$

*Proof sketch.* Write $r = m + 1$ (so $r - 1 = m$ as natural numbers, removing
the truncated subtraction). Cast `turan_edge_bound_nat` to $\mathbb R$ to obtain
$2(m+1)\, e(G) \le m\, n^2$. The algebraic identity
$$ \left(1 - \frac{1}{m+1}\right)\frac{n^2}{2} = \frac{m\, n^2}{2(m+1)} $$
(verified by `field_simp`/`ring`) rewrites the goal, after which
`le_div_iff₀` and `nlinarith` finish. $\square$

This is exactly the form $\mathrm{ex}(n, K_{r+1}) \le (1 - 1/r)\,n^2/2$ from the
classical statement of Turán's theorem.

### 2.3 Mantel's theorem

Specializing to $r = 2$ (forbidding $K_3$, i.e. triangles) yields Mantel's 1907
theorem.

**Theorem (`mantel_nat`).** *If $G$ is triangle-free, then $4\, e(G) \le n^2$.*

**Theorem (`mantel_real`).** *If $G$ is triangle-free, then $e(G) \le n^2/4$.*

*Proof sketch.* Both follow by instantiating the Turán bounds at $r = 2$ and
simplifying: `mantel_nat` from `turan_edge_bound_nat`, `mantel_real` from
`turan_edge_bound_real` with `norm_num` and `linarith`. $\square$

### 2.4 A cross-domain bridge: Turán meets Ramsey

**Theorem (`mantel_ramsey_bridge`).** *Let $V$ be a finite vertex type with
$6 \le |V|$, and let $G$ be triangle-free. Then both*
$$ 4\, e(G) \le n^2 \quad\text{and}\quad \exists\, S,\ \overline{G}\text{ contains a triangle on } S. $$

*Proof sketch.* The first conjunct is `mantel_nat`. For the second, apply
$R(3,3) = 6$ in the form of the catalog result
`RamseyTheory.arrows_three_three`: every $2$-coloring of the edges of $K_n$
($n \ge 6$) contains a monochromatic triangle. Reading $G$ as the "red" graph and
$\overline G$ as the "blue" graph, the unavoidable monochromatic triangle cannot
be red (as $G$ is triangle-free), so it is blue, i.e. lives in $\overline G$. A
`rcases` on the two color branches discards the red branch via `CliqueFree`. $\square$

This combines the *extremal* edge cap (Mantel) with the *Ramsey* unavoidability
phenomenon, showing they constrain complementary parts of the same graph.

## 3. The Kruskal–Katona shadow bound

For an $r$-uniform family $\mathcal A$ of subsets of an $n$-element ground set,
the **shadow** $\partial \mathcal A$ is the family of all $(r-1)$-sets obtained by
deleting a single element from a member of $\mathcal A$. The Kruskal–Katona
theorem quantifies the minimum shadow size of a family of given size.

### 3.1 Single-shadow lower bound

**Theorem (`kk_shadow_lower`).** *Let $\mathcal A$ be a family of $r$-subsets of
$\{0,\dots,n-1\}$ with $1 \le r \le k \le n$. If $\binom{k}{r} \le |\mathcal A|$,
then*
$$ \binom{k}{r-1} \le |\partial \mathcal A|. $$

*Proof sketch.* This is the $i = 1$ case of Mathlib's Lovász form
`kruskal_katona_lovasz_form`, which states
$\binom{k}{r-i} \le |\partial^{[i]}\mathcal A|$ for the $i$-th iterated shadow.
Setting $i = 1$ and simplifying $\partial^{[1]} = \partial$ gives the claim. $\square$

The extremal families here are the *colex-initial* segments (equivalently, all
$r$-subsets of a fixed $k$-set), whose shadow is exactly all $(r-1)$-subsets of
the same $k$-set, realizing $\binom{k}{r-1}$ exactly.

### 3.2 Iterated shadows never vanish prematurely

**Theorem (`kk_iterated_shadow_nonempty`).** *Under the same hypotheses, for every
$i \le r$ the $i$-th iterated shadow $\partial^{[i]}\mathcal A$ is nonempty.*

*Proof sketch.* The Lovász form gives $\binom{k}{r-i} \le |\partial^{[i]}\mathcal A|$.
Since $r - i \le r \le k$, the binomial coefficient $\binom{k}{r-i}$ is strictly
positive (`Nat.choose_pos`), so $|\partial^{[i]}\mathcal A| > 0$ and the family is
nonempty (`Finset.card_pos`), with `omega` discharging the arithmetic. $\square$

The case $i = r$ is sharpest: $\binom{k}{0} = 1 > 0$, so the shadow chain
provably descends all the way to the empty layer. Density at the top forces an
unbroken ladder of shadows beneath.

### 3.3 A bridge to graphs: many triangles force many edges

Triangles are $3$-element vertex sets; edges are $2$-element sets. The shadow
mechanism transfers directly.

**Lemma (`triangles_sized`).** *The triangle family $G.\mathtt{cliqueFinset}\,3$ of
a graph is $3$-uniform.*

**Lemma (`shadow_triangles_subset_edges`).** *For a graph $G$ on $\{0,\dots,n-1\}$,*
$$ \partial\big(G.\mathtt{cliqueFinset}\,3\big) \subseteq G.\mathtt{cliqueFinset}\,2. $$

*Proof sketch.* By `mem_shadow_iff`, every member of the shadow has the form
$s \setminus \{a\}$ for a triangle $s$ and a vertex $a \in s$. Erasing one vertex
of a $3$-clique leaves a $2$-clique: the remaining pair is still adjacent
(`IsClique.subset`) and has cardinality $2$ (`card_erase_of_mem`). Hence the
result is an edge. $\square$

**Theorem (`card_cliqueFinset_two_ge_of_triangles`).** *If $3 \le k \le n$ and
$\binom{k}{3} \le \#(G.\mathtt{cliqueFinset}\,3)$, then
$\binom{k}{2} \le \#(G.\mathtt{cliqueFinset}\,2)$.*

*Proof sketch.* Feed the $3$-uniform triangle family to the Lovász form at
$i = 1$, $r = 3$ to get $\binom{k}{2} = \binom{k}{3-1} \le |\partial(\text{triangles})|$.
The containment `shadow_triangles_subset_edges` and `card_le_card` transfer the
bound to the $2$-cliques. $\square$

**Lemma (`card_cliqueFinset_two_eq_edgeFinset`).** *For any finite graph $H$,
$\#(H.\mathtt{cliqueFinset}\,2) = \#H.\mathtt{edgeFinset}$.*

*Proof sketch.* The map $s(u,v) \mapsto \{u,v\}$ is a bijection between edges
(elements of $\mathrm{Sym}_2$) and $2$-cliques; injectivity is `Sym2.ext` and
surjectivity is `Finset.card_eq_two`. Counting both sides via `Set.ncard_coe_finset`
yields equality. $\square$

**Theorem (`card_edgeFinset_ge_of_triangles`).** *If $3 \le k \le n$ and
$\binom{k}{3} \le \#(G.\mathtt{cliqueFinset}\,3)$, then
$\binom{k}{2} \le \#G.\mathtt{edgeFinset}$.*

*Proof sketch.* Combine the previous two results, rewriting $2$-cliques as edges.
$\square$

This makes precise the slogan "triangles cast their shadows onto edges": a dense
layer of triangles cannot exist without a correspondingly dense layer of edges.

## 4. The triangle removal lemma

The triangle removal lemma is the combinatorial engine behind Roth's theorem. It
is proved via Szemerédi's regularity lemma. Let
$\mathtt{triangleRemovalBound}\,\varepsilon$ denote Mathlib's explicit positive
constant $\delta(\varepsilon)$.

### 4.1 Contrapositive (counting) form

**Theorem (`not_farFromTriangleFree_of_few_triangles`).** *If*
$$ \#(G.\mathtt{cliqueFinset}\,3) < \mathtt{triangleRemovalBound}(\varepsilon)\cdot n^3, $$
*then $G$ is not $\varepsilon$-far from triangle-free: it can be made
triangle-free by deleting fewer than $\varepsilon n^2$ edges.*

*Proof sketch.* Suppose, for contradiction, $G$ is $\varepsilon$-far from
triangle-free. The raw `triangle_removal` produces a triangle-free subgraph
$G' \le G$ with $e(G) - e(G') < \varepsilon n^2$, while
`FarFromTriangleFree.le_card_sub_card` forces $\varepsilon n^2 \le e(G) - e(G')$.
After `push_cast` aligns the $\mathbb N$/$\mathbb R$ casts, `linarith` derives a
contradiction. $\square$

### 4.2 Textbook quantifier form

**Theorem (`triangle_removal_lemma`).** *For every $\varepsilon > 0$ there exists
$\delta > 0$ such that every finite graph $H$ with
$\#(H.\mathtt{cliqueFinset}\,3) < \delta\cdot n^3$ admits a subgraph $H' \le H$
with $e(H) - e(H') < \varepsilon n^2$ and $H'$ triangle-free.*

*Proof sketch.* Take $\delta = \mathtt{triangleRemovalBound}(\varepsilon) > 0$
(`triangleRemovalBound_pos`); the body is `triangle_removal` after `push_cast`
reconciles $\widehat{(n^k)}$ versus $\widehat n^{\,k}$ casts. $\square$

### 4.3 The dichotomy

**Theorem (`triangle_count_dichotomy`).** *For any $\varepsilon$, exactly one of
the following holds:*
$$ \mathtt{triangleRemovalBound}(\varepsilon)\cdot n^3 \le \#(G.\mathtt{cliqueFinset}\,3), $$
*or $G$ can be made triangle-free by deleting fewer than $\varepsilon n^2$ edges.*

*Proof sketch.* A `by_cases` on the triangle-count threshold. If the count is
below threshold, `triangle_removal` gives the second branch; otherwise `push_neg`
gives the first. There is no intermediate regime. $\square$

Informally: *either a graph has cubically many triangles, or it is edge-close to
triangle-free.* This sharp dichotomy is the form of the removal lemma used in
density-increment arguments.

## 5. Roth's theorem on 3-term arithmetic progressions

Roth's theorem is the $k = 3$ case of Szemerédi's theorem, obtained from the
triangle removal lemma via the corners theorem. We use the resulting asymptotic
bound $r_3 = o(N)$ (`rothNumberNat_isLittleO_id`).

### 5.1 Density form

**Theorem (`rothNumberNat_density_tendsto_zero`).**
$$ \frac{r_3(N)}{N} \longrightarrow 0 \quad \text{as } N \to \infty. $$

*Proof sketch.* Direct from `rothNumberNat_isLittleO_id.tendsto_div_nhds_zero`:
a little-$o$ statement is exactly the vanishing of the ratio. $\square$

### 5.2 Qualitative form

**Theorem (`exists_threeAP_of_freq_dense`).** *Let $A \subseteq \mathbb N$ and
$c > 0$. If $A$ is frequently dense — there are infinitely many $N$ with*
$$ c\cdot N \le \#\{n \in \{0,\dots,N-1\} : n \in A\} $$
*— then $A$ is not $\mathrm{ThreeAPFree}$: it contains a nontrivial $3$-term
arithmetic progression $a, b, c$ with $a + c = 2b$ and $a \ne b$.*

*Proof sketch.* Suppose $A$ were $3$-AP-free. Unfolding `isLittleO_iff` at
$\varepsilon = c/2$ gives an *eventual* upper bound $r_3(N) \le (c/2)N$. Using
`Frequently.and_eventually`, choose a single $N \ge 1$ at which the frequent
lower bound and the eventual upper bound both hold. The window
$B = A \cap \{0,\dots,N-1\}$ is $3$-AP-free (`ThreeAPFree.mono`), so
$|B| \le r_3(N)$ (`ThreeAPFree.le_rothNumberNat`). Chaining,
$$ c N \le |B| \le r_3(N) \le \tfrac{c}{2} N, $$
which `nlinarith` refutes for $N \ge 1$. $\square$

The choice $\varepsilon = c/2$ (rather than $\varepsilon = c$) is essential: it
makes the contradiction strict away from the degenerate $N = 0$ boundary. The
frequent-density hypothesis is weaker than positive upper density, so the theorem
is stated at its natural level of generality.

## 6. Saturation theory

We now turn to the dual extremal parameter, which *minimizes* edges over
maximally-cautious graphs.

### 6.1 Definitions

- **Edge count (`edgeCount`).** $\mathrm{edgeCount}(G) = |G.\mathtt{edgeSet}|$
  (as a set cardinality `ncard`).
- **Saturation (`IsSaturated`).** $G$ is $H$-saturated if $H$ does not embed in
  $G$, yet for every non-adjacent pair $a \ne b$, adding the edge $s(a,b)$ creates
  a copy of $H$ (i.e. $H \sqsubseteq G \sqcup \mathtt{fromEdgeSet}\{s(a,b)\}$).
- **Extremal number (`exNum`).** $\mathrm{ex}(n,H)$ is the supremum of
  $\mathrm{edgeCount}$ over $H$-free graphs on $\mathrm{Fin}\,n$.
- **Saturation number (`satNum`).** $\mathrm{sat}(n,H)$ is the infimum of edge
  counts over $H$-saturated graphs on $\mathrm{Fin}\,n$ (with the convention $0$
  if none exists; the next result shows this case does not occur when $H$ has an
  edge).

### 6.2 Existence and the basic inequality

**Lemma (`free_bot_of_adj`).** *If $H$ has an edge, then $H$ does not embed into
the empty graph $\bot$.*

**Lemma (`edgeCount_lt_addEdge`).** *Adding a genuinely new edge strictly
increases the edge count.*

*Proof sketch.* The new edge set strictly contains the old one
(`Set.ncard_lt_ncard` over a finite type). $\square$

**Theorem (`exists_isSaturated`).** *If $H$ has an edge, then for every $n$ there
exists an $H$-saturated graph on $\mathrm{Fin}\,n$.*

*Proof sketch.* Take a graph $G$ with the *maximum* edge count among $H$-free
graphs on $\mathrm{Fin}\,n$ (`Set.exists_max_image` over the finite type of
graphs; the empty graph witnesses nonemptiness via `free_bot_of_adj`). If some
missing edge could be added while staying $H$-free, the result would be a
strictly larger $H$-free graph (`edgeCount_lt_addEdge`), contradicting
maximality. Hence every addition creates a copy of $H$, so $G$ is saturated. $\square$

**Theorem (`satNum_le_exNum`).** *If $H$ has an edge, then for every $n$,*
$$ \mathrm{sat}(n, H) \le \mathrm{ex}(n, H). $$

*Proof sketch.* The maximum-free graph $G_0$ from `exists_isSaturated` is
saturated, so $\mathrm{sat}(n,H) \le \mathrm{edgeCount}(G_0)$ (`Nat.sInf_le`),
while $\mathrm{edgeCount}(G_0) \le \mathrm{ex}(n,H)$ since $G_0$ is free
(`Finset.le_sup`). $\square$

### 6.3 The apex join and explicit edge counts

**Definition (`cone`).** The **cone** $K_1 \vee H$ over $H$ on vertex type
$\mathrm{Option}\,V$: a fresh apex `none` adjacent to every `some _`, with $H$ on
the `some _` vertices.

**Theorem (`edgeCount_cone`).** *$e(K_1 \vee H) = |V| + e(H)$.*

*Proof sketch.* The edge set of $K_1 \vee H$ partitions into the $|V|$ apex edges
$\{s(\text{none}, \text{some } x)\}$ and a faithful copy (under
$\mathrm{Sym}_2.\mathtt{map}\ \mathrm{some}$) of the edge set of $H$; these are
disjoint, so `Set.ncard_union_eq` adds the counts $|V|$ and $e(H)$. $\square$

This is the origin of the $n - 1$ term in the Cameron–Puleo recurrence.

**Definition (`matchingPlusIsolated t q`).** The graph $tK_2 \cup qK_1$ on
$\mathrm{Fin}(2t + q)$: vertices $2k$ and $2k+1$ (for $k < t$) form the $k$-th
matching edge; vertices $\ge 2t$ are isolated.

**Theorem (`edgeCount_matchingPlusIsolated`).** *$e(tK_2 \cup qK_1) = t$.*

*Proof sketch.* The map $k \mapsto \{2k, 2k+1\}$ ($k < t$) is an injection from
$\mathrm{Fin}\,t$ onto the edge set; counting the image (`card_image_of_injective`)
gives exactly $t$. $\square$

**Theorem (`edgeCount_cone_matchingPlusIsolated`).** *$e\big(K_1 \vee (tK_2 \cup qK_1)\big) = (2t+q) + t$.*

*Proof sketch.* Combine `edgeCount_cone` ($|V| = 2t + q$) with
`edgeCount_matchingPlusIsolated` ($e(H) = t$). $\square$

### 6.4 Bridge to the Turán world

**Lemma (`edgeCount_eq_card_edgeFinset`).** *On a finite vertex type,
$\mathrm{edgeCount}(G) = \#G.\mathtt{edgeFinset}$.*

**Theorem (`satNum_clique_le_turan`).** *For $r \ge 1$ and every $n$,*
$$ \mathrm{sat}(n, K_{r+1}) \le e\big(T(n,r)\big). $$

*Proof sketch.* Apply `satNum_le_exNum` to $H = K_{r+1} = \top$ on
$\mathrm{Fin}(r+1)$ (which has the edge $s(0,1)$). Then bound the extremal number:
every $K_{r+1}$-free graph $G$ on $\mathrm{Fin}\,n$ satisfies
$e(G) \le e(T(n,r))$ by Mathlib's `CliqueFree.card_edgeFinset_le` combined with
`card_edgeFinset_turanGraph`, using `cliqueFree_iff_top_free` to convert
$\top$-freeness to $K_{r+1}$-freeness. A `Finset.sup_le` over the free graphs
finishes. $\square$

This links the *saturation* world to the *extremal* world; the exact value of
$\mathrm{sat}(n, K_{r+1})$ is the content of the Erdős–Hajnal–Moon theorem.

### 6.5 The Cameron–Puleo recurrence (conjecture)

**Conjecture (`CameronPuleoEquality`).** *For $t \ge 1$, $q \ge 1$, and
$n > 2t + q$,*
$$ \mathrm{sat}\big(n,\ K_1 \vee (tK_2 \cup qK_1)\big) = (n-1) + \mathrm{sat}\big(n-1,\ tK_2 \cup qK_1\big). $$

This is stated as a `Prop` (not asserted as a theorem). The source paper proves
it for $t = 1, 2$; it is open in general. The $(n-1)$ apex term is supplied
exactly by `edgeCount_cone`.

## 7. Discussion: a single principle

Across all four pillars the same engine runs: **abundance forces structure.**

| Result | Abundance | Forced structure |
|---|---|---|
| Turán / Mantel | $> (1-1/r)n^2/2$ edges | a $K_{r+1}$ |
| Kruskal–Katona | $\ge \binom kr$ $r$-sets | shadow $\ge \binom{k}{r-1}$ |
| Triangle removal | costly-to-remove triangles | $\Theta(n^3)$ triangles |
| Roth | positive density in $\mathbb N$ | a $3$-AP |

The bridges reinforce the unity: Mantel $\times$ Ramsey shows the extremal cap and
the unavoidability phenomenon constrain complementary halves of one graph;
Kruskal–Katona $\times$ graphs turns an abstract shadow bound into "many
triangles imply many edges"; triangle removal $\times$ additive combinatorics is
the route from regularity to Roth.

## 8. Future work

Several concrete continuations follow directly from the formalized core. (1)
Matching the Turán *upper* bound with a multipartite *lower* bound would upgrade
`turan_edge_bound_real` to an exact equality, requiring only an explicit edge
count of the balanced complete $(r-1)$-partite graph. (2) Iterating
`kk_iterated_shadow_nonempty` and summing the Lovász layers
$\binom{k}{r-i}$ over all $i$ would yield a full lower-triangle-of-Pascal total
$\sum_{j\le r}\binom kj$. (3) Sharpening the additive-energy/$3$-AP relationship
into an explicit energy-dichotomy lower bound on progression density. (4) Settling
the Cameron–Puleo recurrence beyond $t = 1, 2$. These are recorded in detail in
the package's future-directions notes.

## 9. Conclusion

We have assembled a coherent, fully verified tour of extremal combinatorics:
Turán and Mantel edge bounds, the Kruskal–Katona shadow inequality and its graph
incarnation, the triangle removal dichotomy, Roth's theorem in density and
qualitative forms, and the foundational theory of saturation numbers with a
Turán bridge. Two cross-domain bridges (Ramsey and Kruskal–Katona-to-graphs) and
a formally-stated open conjecture round out the development. The recurring moral
— that beyond a sharp threshold, structure is unavoidable — is realized here as a
small number of interlocking, machine-checked theorems.
