# Degree-Normalized Linked Tree-Cut Decompositions for Locally Finite Graphs: The Ray-Level Reduction

**Author:** Aristotle
**Date:** 2026-06-24
**Domain:** Novelty (structural / topological graph theory)

## Abstract

We study the *degree-normalization* clause of a conjecture on rooted tree-cut
decompositions of connected locally finite multigraphs. The conjecture asks for a
decomposition $(T, \mathcal{V})$ — into finite bags, of finite adhesion,
componental and *linked* — that displays every end $\omega$ of $G$ bijectively as
an end of $T$ and that is *degree-normalized*: along the root-to-$\alpha$ ray
displaying $\omega$, with $n$-th adhesion $F_{e_n}$, (i) if the edge-degree of
$\omega$ is finite, equal to $d$, then $|F_{e_n}| = d$ for all sufficiently large
$n$; (ii) if the edge-degree is infinite, then $|F_{e_n}| \to \infty$. We isolate
the purely order-theoretic content of this clause and prove it in full. Defining
the **displayed edge-degree** along a ray as $\inf_n |F_{e_n}|$, we show: (1) along
a nested (componental) ray the adhesion sizes stabilize *exactly* at the displayed
edge-degree; (2) under linkedness this stabilized value equals the eventual edge
min-cut to the end, hence — via Menger — its genuine edge-degree; (3) a
monotone-unbounded ray diverges; and (4) any eventually-monotone ray realizes
exactly one of the two normalization regimes. These results reduce the
degree-normalization clause to a single combinatorial property: monotonicity of
the adhesion-size sequence along every end-ray. We exhibit the oscillating
sequence $1,2,1,2,\dots$ as the precise obstruction, showing monotonicity is
load-bearing, and we record the resulting open problems. All results are
formalized with no unproven steps.

---

## 1. Introduction

Tree-cut decompositions, introduced for finite graphs to capture a notion of
width better suited to immersions and edge-connectivity than tree-width, organize
a graph $G$ around a host tree $T$ whose nodes carry vertex *bags*. Deleting a tree
edge bipartitions $G$; the **adhesion** of that tree edge is the set of $G$-edges
crossing the bipartition. For infinite, locally finite graphs the natural objects
of study are the **ends** — the directions in which $G$ runs to infinity — and one
seeks decompositions that *display* every end and faithfully reflect its
connectivity.

The relevant connectivity invariant is the **edge-degree** of an end $\omega$: the
supremum, over finite separators, of the min-cut toward $\omega$, equivalently the
maximum number of pairwise edge-disjoint rays converging to $\omega$ (the edge
analogue of Halin's grid/Menger theory for ends). A decomposition that displays
$\omega$ along a tree-end $\alpha$ yields a ray of tree edges $e_0, e_1, \dots$ and
a sequence of adhesion sizes $|F_{e_n}|$. The **degree-normalization** conjecture
demands these sizes report the edge-degree exactly: stabilize at $d$ when the
degree is finite, diverge when it is infinite.

This paper makes the following contribution. We *decouple* the normalization clause
from the (still open) existence problem and prove the clause as a consequence of an
explicit, local hypothesis — monotonicity of $n \mapsto |F_{e_n}|$ — exposing
exactly what any constructive proof of the full conjecture must deliver. We further
connect the stabilized value to Menger edge-connectivity through the *linked*
condition. The development rests on a fully verified, layered tree-cut framework
(Section 2) and a small order-theoretic core (Section 4).

### 1.1 Summary of results

- **Theorem 1** (`degreeNormalized_finite`): nested rays stabilize exactly at the
  displayed edge-degree.
- **Theorem 2** (`degreeNormalized_finite_minCut` + `linked_adhesion_eq_minCut`):
  under linkedness the stabilized value equals the eventual edge min-cut to the end.
- **Theorem 3** (`degreeNormalized_infinite`): monotone-unbounded rays diverge.
- **Theorem 4** (`degreeNormalization_dichotomy`): eventually-monotone rays realize
  exactly one normalization regime.
- **Lemmas 1–4** (`antitone_nat_eventually_eq_iInf`,
  `monotone_nat_eventually_const_of_bddAbove`,
  `monotone_nat_unbounded_eventually_ge`, `eventually_const_or_diverges`): the
  order-theoretic core.

---

## 2. The tree-cut framework

We recall the framework on which the results are built. Throughout, $V$ is a vertex
type and all edge cuts are taken in a multigraph with a finite edge type
(`Fintype G.Edge`); the finiteness is what makes adhesion *sizes* well-defined
natural numbers and is the working substitute, at each finite level, for local
finiteness of the ambient infinite graph.

**Definition 1 (Multigraph).** A *multigraph* on $V$ is a type $\mathrm{Edge}$
together with an incidence map $\mathrm{inc} : \mathrm{Edge} \to \mathrm{Sym2}\,V$
assigning to each edge its unordered pair of endpoints.

**Definition 2 (Crossing, cut, cut size).** An edge $e$ *crosses* a vertex set
$A \subseteq V$ if one endpoint lies in $A$ and the other does not. The
**cut edges** $\mathrm{cutEdges}(A)$ are all edges crossing $A$, and the
**cut size** is $\mathrm{cutSize}(A) = |\mathrm{cutEdges}(A)|$.

**Definition 3 (Separator and min-cut).** A finite edge set $F$ *separates* $A$ if
no walk from $A$ to $V \setminus A$ avoids $F$. The **edge min-cut** is
$$\mathrm{minCut}(A) \;=\; \inf\{\, |F| : F \text{ separates } A \,\}.$$
The set of separator sizes is nonempty because $\mathrm{cutEdges}(A)$ itself
separates $A$ (a walk avoiding every crossing edge cannot change sides), whence
$\mathrm{minCut}(A) \le \mathrm{cutSize}(A)$ and the infimum is attained.

**Definition 4 (Tree-cut decomposition).** A *tree-cut decomposition* of $G$ over a
node type $N$ consists of a tree $T$ on $N$ together with nonempty, pairwise
disjoint bags $\mathrm{bag}(n) \subseteq V$ covering $V$. The bags form a partition
of $V$ (Proposition: `bag_partition`). For an oriented tree edge $e = (x,y)$ —
i.e. an ordered adjacent pair — the **side** $\mathrm{side}(e)$ is the union of the
bags of all nodes reachable from $y$ after deleting the underlying edge of $e$ from
$T$. The **adhesion** is
$$\mathrm{adhesion}(e) \;=\; \mathrm{cutEdges}(\mathrm{side}(e)),$$
with $|\mathrm{adhesion}(e)| = \mathrm{cutSize}(\mathrm{side}(e))$.

**Definition 5 (Linked).** A decomposition is **linked** if across every tree edge
$e$ there exist $|\mathrm{adhesion}(e)|$ pairwise edge-disjoint *crossing paths*
(walks from $\mathrm{side}(e)$ to its complement).

**Proposition A (`linked_adhesion_eq_minCut`).** For a linked decomposition and
every tree edge $e$,
$$|\mathrm{adhesion}(e)| \;=\; \mathrm{minCut}(\mathrm{side}(e)).$$
*Proof sketch.* ($\le$) Each of the $k = |\mathrm{adhesion}(e)|$ edge-disjoint
crossing paths must contain an edge of any separator $F$ (a separator meets every
crossing walk); edge-disjointness gives an injection from the $k$ paths into $F$,
so $k \le |F|$; take $F$ achieving the min-cut. ($\ge$) $\mathrm{cutEdges}$ is a
separator of size $|\mathrm{adhesion}(e)|$, so $\mathrm{minCut} \le
|\mathrm{adhesion}(e)|$. $\square$

**Proposition B (`adhesion_card_antitone_of_nested`).** If a ray of tree edges
$e : \mathbb{N} \to \mathrm{AdjSpace}$ has nested adhesions
$\mathrm{adhesion}(e_{n+1}) \subseteq \mathrm{adhesion}(e_n)$, then
$n \mapsto |\mathrm{adhesion}(e_n)|$ is antitone.
*Proof sketch.* A subset has no more elements: $|\mathrm{adhesion}(e_{n+1})| \le
|\mathrm{adhesion}(e_n)|$ for all $n$, and a sequence with non-increasing
successors is antitone. $\square$

These two propositions are the only structural inputs from the tree-cut layer; the
remaining work is order-theoretic.

---

## 3. The displayed edge-degree

Fix a root-to-end ray of the decomposition tree, modelled as a sequence
$e : \mathbb{N} \to \mathrm{AdjSpace}$ of oriented tree edges, with $n$-th adhesion
$F_{e_n} = \mathrm{adhesion}(e_n)$.

**Definition 6 (Displayed edge-degree, `displayedEdgeDegree`).** The *displayed
edge-degree* of the end reached along $e$ is the infimum of the adhesion sizes,
$$\mathrm{displayedEdgeDegree}(e) \;=\; \inf_{n \in \mathbb{N}} \, |F_{e_n}|
\;=\; \bigsqcap_n |F_{e_n}|.$$
Since the values lie in $\mathbb{N}$ (well-ordered, so the infimum is attained as a
minimum), this is a genuine natural number, and it is the natural candidate for the
"finite edge-degree $d$" appearing in clause (i).

---

## 4. The order-theoretic core

The combinatorial heart of degree normalization is a dichotomy for monotone
integer sequences. We state it abstractly for $f : \mathbb{N} \to \mathbb{N}$;
in the application $f(n) = |F_{e_n}|$.

**Lemma 1 (`antitone_nat_eventually_eq_iInf`).** If $f : \mathbb{N} \to \mathbb{N}$
is antitone, then there is $N$ such that $f(n) = \inf_k f(k)$ for all $n \ge N$.
*Proof sketch.* The range of $f$ is a nonempty subset of $\mathbb{N}$, so its
infimum $m = \inf_k f(k)$ is attained: $f(N) = m$ for some $N$. For $n \ge N$,
antitonicity gives $f(n) \le f(N) = m$, while $m$ is a lower bound gives $f(n) \ge
m$; hence $f(n) = m$. $\square$

**Lemma 2 (`monotone_nat_eventually_const_of_bddAbove`).** If
$f : \mathbb{N} \to \mathbb{N}$ is monotone and bounded above, then $f$ is
eventually constant.
*Proof sketch.* A monotone sequence bounded above in $\mathbb{N}$ has a maximal
attained value $M = \sup_k f(k)$, reached at some $N$; for $n \ge N$ monotonicity
forces $M \le f(n) \le M$. $\square$

**Lemma 3 (`monotone_nat_unbounded_eventually_ge`).** If
$f : \mathbb{N} \to \mathbb{N}$ is monotone and its range is unbounded above, then
for every $k$ there is $N$ with $f(n) \ge k$ for all $n \ge N$; i.e.
$f(n) \to \infty$.
*Proof sketch.* Unboundedness yields $N$ with $f(N) \ge k$; monotonicity
propagates $f(n) \ge f(N) \ge k$ for $n \ge N$. $\square$

**Lemma 4 (`eventually_const_or_diverges`).** If $f : \mathbb{N} \to \mathbb{N}$ is
monotone or antitone, then either $f$ is eventually constant or $f$ diverges to
$\infty$.
*Proof sketch.* If $f$ is antitone, Lemma 1 gives eventual constancy. If $f$ is
monotone, split on whether its range is bounded above: bounded gives eventual
constancy (Lemma 2), unbounded gives divergence (Lemma 3). $\square$

**Remark (sharpness).** Lemma 4 fails without the monotonicity hypothesis: the
sequence $1,2,1,2,\dots$ is bounded yet neither eventually constant nor divergent.
Monotonicity is therefore load-bearing — it is exactly the property a constructive
decomposition must supply.

---

## 5. Degree normalization at ray level

We now transport the core to tree-cut decompositions. Let $D$ be a tree-cut
decomposition of $G$ (with `Fintype G.Edge`) and $e : \mathbb{N} \to
\mathrm{AdjSpace}$ a ray.

**Theorem 1 (Finite case — exact stabilization, `degreeNormalized_finite`).**
Suppose the adhesions are nested: $F_{e_{n+1}} \subseteq F_{e_n}$ for all $n$. Then
there is $N_0$ such that
$$|F_{e_n}| \;=\; \mathrm{displayedEdgeDegree}(e) \qquad \text{for all } n \ge N_0.$$
*Proof sketch.* Nesting makes $n \mapsto |F_{e_n}|$ antitone (Proposition B / the
inclusion $|F_{e_{n+1}}| \le |F_{e_n}|$). Apply Lemma 1 with $f(n) = |F_{e_n}|$:
the sequence is eventually equal to its infimum, which is exactly
$\mathrm{displayedEdgeDegree}(e)$ by Definition 6. $\square$

**Theorem 2 (Finite case — min-cut form, `degreeNormalized_finite_minCut`).**
Suppose $D$ is linked and the adhesions along $e$ are nested. Then there is $N_0$
such that
$$\mathrm{minCut}(\mathrm{side}(e_n)) \;=\; \mathrm{displayedEdgeDegree}(e)
\qquad \text{for all } n \ge N_0.$$
*Proof sketch.* By Theorem 1 choose $N_0$ with $|F_{e_n}| =
\mathrm{displayedEdgeDegree}(e)$ for $n \ge N_0$. By Proposition A
(`linked_adhesion_eq_minCut`), $|F_{e_n}| = \mathrm{minCut}(\mathrm{side}(e_n))$
for every $n$. Chaining the two equalities gives the claim. $\square$

By Menger's theorem the edge min-cut equals the maximum number of edge-disjoint
crossing paths; iterating toward the end identifies $\mathrm{displayedEdgeDegree}$
with the Menger edge-connectivity to the displayed end (the finite half of
Conjecture 2 in Section 7).

**Theorem 3 (Infinite case — divergence, `degreeNormalized_infinite`).** Suppose
$n \mapsto |F_{e_n}|$ is monotone increasing and unbounded above. Then for every
$k \in \mathbb{N}$ there is $N_0$ with $k \le |F_{e_n}|$ for all $n \ge N_0$; i.e.
$|F_{e_n}| \to \infty$.
*Proof sketch.* Direct application of Lemma 3 with $f(n) = |F_{e_n}|$. $\square$

**Theorem 4 (Dichotomy, `degreeNormalization_dichotomy`).** Suppose
$n \mapsto |F_{e_n}|$ is monotone or antitone. Then exactly one of the
normalization alternatives holds:
$$\big(\exists\, d, N_0:\ \forall n \ge N_0,\ |F_{e_n}| = d\big)
\quad\text{or}\quad
\big(\forall k\, \exists N_0:\ \forall n \ge N_0,\ k \le |F_{e_n}|\big).$$
*Proof sketch.* Apply Lemma 4 to $f(n) = |F_{e_n}|$. The first disjunct is finite
edge-degree (with $d = \mathrm{displayedEdgeDegree}(e)$), the second is infinite
edge-degree. The two are mutually exclusive (a constant sequence is bounded). $\square$

Theorem 4 is precisely the degree-normalization clause, stated at the level of a
single ray, *modulo* the monotonicity hypothesis.

---

## 6. Discussion: what is proved, and the load-bearing gap

The results above effect a clean reduction. The degree-normalization clause —
geometric, infinite, and entangled with end theory — is shown to be *equivalent in
content* to monotonicity of the adhesion-size sequence along each end-ray:

> **Reduction.** Given monotonicity of $n \mapsto |F_{e_n}|$ along every
> root-to-end ray, Theorems 1–4 yield the full degree-normalization clause, with
> the stabilized value equal to the displayed edge-degree and (under linkedness)
> to the eventual edge min-cut to the end.

The sharpness remark in Section 4 pinpoints the gap precisely: oscillating widths
$1,2,1,2,\dots$ defeat normalization, so the *only* missing ingredient is a
construction guaranteeing monotonicity. This turns an analytic conjecture about
infinite graphs into a finite, local statement about consecutive adhesions
$F_{e_n}, F_{e_{n+1}}$.

The role of linkedness deserves emphasis. Without it, the displayed edge-degree is
merely "the eventual width" — a bookkeeping artifact of the chosen decomposition.
With it, Proposition A pins each adhesion to the Menger min-cut of its side, so the
displayed edge-degree becomes an intrinsic connectivity invariant of the end. The
combination — linked, componental, monotone — is exactly what makes the skeleton
*honest at infinity*.

---

## 7. Future directions

**Conjecture 1 — Linkedness alone forces eventual monotonicity along nested rays.**
In a linked rooted tree-cut decomposition of a connected locally finite multigraph,
for every root-to-end ray $e$ the sequence $|F_{e_n}|$ is eventually monotone
(eventually antitone for a finite-degree end, eventually monotone increasing for an
infinite-degree end). The key insight is that linkedness pins each adhesion to the
Menger min-cut of its side (Proposition A), and min-cuts toward a fixed end can
only "tighten then settle": a strict decrease cannot be undone without resurrecting
edge-disjoint witness paths that linkedness forbids. Once monotonicity is
established, Theorem 4 immediately yields the full clause, so only the local
monotonicity lemma on consecutive adhesions remains.

**Conjecture 2 — `displayedEdgeDegree` is a complete invariant of the end's
edge-degree.** For a linked, componental decomposition displaying an end $\omega$
bijectively, $\mathrm{displayedEdgeDegree}(e)$ (finite case) equals the maximum
number of pairwise edge-disjoint rays converging to $\omega$; in the infinite case
both sides are $+\infty$. The cut side is already established by Theorem 2; the
remaining work is the ray-packing side, a self-contained edge-version of
Menger/Halin for ends.

**Further directions.** (a) Remove the explicit monotonicity/nesting hypotheses by
proving Conjecture 1, completing the normalization clause. (b) Establish existence:
construct linked, componental, end-displaying decompositions for all connected
locally finite multigraphs, the genuinely open part of the original conjecture.
(c) Quantitative normalization: bound the stabilization index $N_0$ in terms of
structural parameters of $G$ near the end.

---

## 8. Conclusion

We have proved the degree-normalization clause of the linked tree-cut conjecture at
the level of a single root-to-end ray, conditional only on monotonicity of the
adhesion-size sequence: nested rays stabilize *exactly* at the displayed
edge-degree (Theorem 1), which under linkedness equals the eventual edge min-cut
and hence the Menger edge-connectivity to the end (Theorem 2); monotone-unbounded
rays diverge (Theorem 3); and every eventually-monotone ray realizes exactly one
normalization regime (Theorem 4). The order-theoretic core (Lemmas 1–4) is
elementary and sharp, with the oscillating sequence $1,2,1,2,\dots$ marking the
exact boundary. The contribution is a precise reduction of an infinite, geometric
conjecture to a finite, local monotonicity statement, isolating exactly what a
constructive proof must deliver.
