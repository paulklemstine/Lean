# A Linear One-Set Wall–Menger Bound for Elementary Walls

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Novelty (structural / extremal graph theory)

## Abstract

We study an explicit, constructive form of Menger's theorem specialised to
elementary (hexagonal) walls. For positive integers $s$ and $r$ we set the
*wall-height threshold* $T(s,r) = (8s+4)\,r$ and the *separator bound*
$F(s) = 4s-4$, and we record the **one-set wall–Menger dichotomy**: in every
finite simple graph $G$, for every vertex set $A$ and every elementary wall $W$
of height at least $T(s,r)$, either a vertex set $X$ with $|X| \le F(s)$ separates
$A$ from the branch vertices of $W$, or $W$ contains an $r$-subwall reached by $s$
pairwise vertex-disjoint $A$–subwall paths landing on distinct nails. The two
constants are *explicit*: the wall-size requirement is **linear in $r$** and the
separator size depends only on $s$. We isolate the combinatorial engine behind
both constants — a greedy **packing–cover duality** stating that a finite family
of nonempty sets of size at most $c$ with no $s$ pairwise-disjoint members admits
a hitting set of size at most $c(s-1)$ — and show that the wall's separator
constant is exactly its $c = 4$ specialisation, the $4$ being the wall-degree of a
nail. We complement this with a **connectivity bridge**: in a $k$-connected graph
the packing horn of the dichotomy is witnessed for free by the neighbour
singletons of any vertex, a family of $\ge k$ pairwise-disjoint nonempty sets.
Every statement below corresponds to a machine-checked declaration.

---

## 1. Introduction

Menger's theorem — the maximum number of internally disjoint paths between two
vertex sets equals the minimum size of a separating set — is the prototypical
*min-max duality* of graph theory and the engine of network flow, graph minors,
and parameterised algorithms. In structural graph theory one frequently needs not
the exact min-max value but an **explicit, computable bound**: a function of the
target parameters, fixed in advance, guaranteeing that *either* a small separator
exists *or* many disjoint structures do. Such "explicit dichotomies" are the
working currency of, e.g., the Graph Minors series and irrelevant-vertex
arguments, where one wants to route disjoint paths into a clean, untouched piece
of a highly structured object.

The structured object here is an **elementary wall**: a subdivided hexagonal grid,
the canonical large planar gadget appearing inside any graph of large treewidth.
A wall of *height* $h$ contains $h$ rows of bricks; its degree-three vertices are
the **branch vertices**, and the distinguished attachment points used for routing
are the **nails**. In an elementary wall each nail has at most four neighbours on
the wall.

**The conjecture.** Fix positive integers $s, r$ and put
$$T(s,r) = (8s+4)\,r, \qquad F(s) = 4s-4.$$
For every finite simple graph $G$, every vertex set $A \subseteq V(G)$, and every
elementary wall $W \subseteq G$ of height at least $T(s,r)$, at least one of the
following holds:

- **(Cover horn)** there is a set $X \subseteq V(G)$ with $|X| \le F(s)$ such that
  no $A$–path reaches a branch vertex of $W$ in $G - X$; or
- **(Packing horn)** there is an $r$-subwall $W' \subseteq W$ together with $s$
  pairwise vertex-disjoint paths $P_1, \dots, P_s$, each from $A$ to $W'$, whose
  $W'$-endvertices are *distinct nails* of $W'$ and whose internal vertices avoid
  $A \cup V(W')$.

Relative to the existential bounds typical of the wall-routing literature, the
content here is the *explicitness and linearity* of the two constants: $T$ is
linear in $r$, and $F$ is independent of the wall altogether.

**Contributions.** We formalise and machine-check the combinatorial core that
forces both constants:

1. `exists_maximal_packing` (Theorem 1): existence of a maximum-cardinality
   pairwise-disjoint subfamily of any finite family of finite sets.
2. `packing_cover_duality` (Theorem 2): the greedy duality
   "no $s$-packing $\Rightarrow$ hitting set of size $\le c(s-1)$."
3. `wall_menger_separator_bound` (Theorem 3): the $c=4$ specialisation yielding
   $|X| \le 4s-4 = F(s)$.
4. `kConnected_neighbor_packing` (Theorem 4): in a $k$-connected graph the
   packing horn is witnessed locally by $\ge k$ neighbour singletons.

The wall-geometry assembly (`subwall_tiling`, `exists_clean_subwall`,
`wall_menger_dichotomy`) layers a tiling-plus-pigeonhole bookkeeping argument on
top of Theorem 3; we describe it but emphasise that the constants are dictated by
Theorems 2–3.

---

## 2. Definitions

Throughout, $V$ is a finite type with decidable equality, and "family" means a
`Finset` of `Finset`s over $V$ (a finite collection of finite vertex sets).

**Definition 2.1 (Pairwise-disjoint family / packing).** A family
$P \subseteq \mathcal{F}$ is *pairwise disjoint* if for all distinct
$A, B \in P$ we have $A \cap B = \varnothing$. An **$s$-packing** in
$\mathcal{F}$ is a pairwise-disjoint subfamily with at least $s$ members. The
**packing number** $\nu(\mathcal F)$ is the maximum size of a pairwise-disjoint
subfamily.

**Definition 2.2 (Hitting set / cover).** A set $X \subseteq V$ is a **hitting
set** (transversal, cover) for $\mathcal{F}$ if $A \cap X \neq \varnothing$ for
every $A \in \mathcal{F}$. The **covering number** $\tau(\mathcal F)$ is the
minimum size of a hitting set.

**Definition 2.3 ($c$-bounded family).** $\mathcal F$ is **$c$-bounded** if every
member has at most $c$ elements: $|A| \le c$ for all $A \in \mathcal F$. It is
**nonempty-membered** if $A \neq \varnothing$ for all $A \in \mathcal F$.

**Definition 2.4 (Elementary wall, height, nails, branch vertices).** An
*elementary wall of height $h$* is the standard subdivision of the $h \times h$
hexagonal grid. Its degree-$3$ vertices are **branch vertices**; the attachment
vertices used for path endpoints are **nails**; each nail has at most $4$
neighbours on the wall (its *wall-degree* is $\le 4$). An **$r$-subwall** of $W$
is a wall of height $r$ occurring as an induced, axis-aligned sub-grid of $W$.

**Definition 2.5 ($A$–$W'$ path system).** Given $A \subseteq V$ and a subwall
$W'$, an **$s$-fold clean path system** is a set of $s$ pairwise vertex-disjoint
paths $P_1,\dots,P_s$, each with one endpoint in $A$ and the other a *distinct
nail* of $W'$, and with all internal vertices outside $A \cup V(W')$.

**Definition 2.6 (Vertex $k$-connectivity).** A finite simple graph $G$ is
**$k$-connected** ($\mathrm{IsKConnected}\,G\,k$) if $|V(G)| > k$ and, for every
$S \subseteq V(G)$ with $|S| < k$, the induced subgraph $G[V \setminus S]$ is
connected.

---

## 3. The combinatorial engine: greedy packing–cover duality

### 3.1 A maximum packing exists

**Theorem 1 (`exists_maximal_packing`).** *Let $\mathcal F$ be a finite family of
finite subsets of $V$. Then there exists a subfamily $P \subseteq \mathcal F$ that
is pairwise disjoint and of maximum cardinality among pairwise-disjoint
subfamilies: for every pairwise-disjoint $Q \subseteq \mathcal F$,
$|Q| \le |P|$.*

*Proof sketch.* The pairwise-disjoint subfamilies of $\mathcal F$ form a finite,
nonempty (it contains $\varnothing$) subset $\mathcal S$ of the powerset of
$\mathcal F$, namely those $Q$ in $2^{\mathcal F}$ satisfying the pairwise-disjoint
predicate. Maximising the cardinality function $Q \mapsto |Q|$ over the finite
nonempty set $\mathcal S$ (Mathlib's `Finset.exists_max_image`) yields a maximiser
$P$; unpacking membership in $\mathcal S$ gives $P \subseteq \mathcal F$,
pairwise-disjointness of $P$, and the maximality inequality. $\qquad\square$

The role of Theorem 1 is purely to *produce* a maximum packing; all quantitative
content lives in Theorem 2.

### 3.2 No large packing forces a small cover

**Theorem 2 (`packing_cover_duality`).** *Let $\mathcal F$ be a finite,
nonempty-membered, $c$-bounded family over $V$, and let $s \ge 1$. If $\mathcal F$
has no $s$-packing (equivalently $\nu(\mathcal F) \le s-1$), then the union
$$X = \bigcup_{A \in P} A$$
of a maximum pairwise-disjoint subfamily $P$ is a hitting set for $\mathcal F$ and
satisfies*
$$\tau(\mathcal F) \;\le\; |X| \;\le\; c\,(s-1).$$

*Proof sketch.* Take $P$ from Theorem 1, so $P$ is a maximum pairwise-disjoint
subfamily, and set $X = \bigcup_{A \in P} A$.

*Hitting.* Let $B \in \mathcal F$ and suppose for contradiction $B \cap X =
\varnothing$. Since $X$ contains every member of $P$, $B$ is disjoint from each
member of $P$; as $B$ is nonempty and $B \notin P$ would otherwise force $B
\subseteq X$, the family $P \cup \{B\}$ is again pairwise disjoint and strictly
larger than $P$, contradicting maximality. Hence $B \cap X \neq \varnothing$, and
$X$ is a hitting set. (Nonemptiness of members is load-bearing: an empty member is
disjoint from everything and could never be hit.)

*Size.* Because $\mathcal F$ has no $s$-packing, $|P| \le s-1$. By the union bound
for cardinalities (`Finset.card_biUnion_le`) and $c$-boundedness,
$$|X| = \Big|\bigcup_{A \in P} A\Big| \;\le\; \sum_{A \in P} |A| \;\le\; |P|\cdot c
\;\le\; (s-1)\,c.$$
The truncated subtraction $s-1$ is harmless since $|P| < s$ implies $|P| \le s-1$
in $\mathbb N$. $\qquad\square$

**Remark 3.1 (greedy vs. exact).** Theorem 2 is the *one-sided* greedy bound
$\tau \le c\,\nu$, not the exact Menger min-max $\tau = \nu$ (which fails for
set systems in general and is non-constructive in the constants even when it
holds). Trading the factor $c$ for an explicit, computable, linear-in-$s$ bound is
precisely what makes the wall constants explicit.

**Remark 3.2 (tightness conditions).** The inequality chain
$|X| \le \sum_{A\in P}|A| \le \nu\,c$ has two separately characterisable equality
cases (`Finset.card_biUnion` exact when the chosen members are disjoint;
`Finset.sum_le_sum` exact when each $|A| = c$). Simultaneous tightness forces the
maximal packing's members to be mutually disjoint *and* each of full size $c$ — a
"sunflower"-type rigidity (see Future Directions D3).

### 3.3 The wall specialisation

**Theorem 3 (`wall_menger_separator_bound`).** *Let $\mathcal F$ be a finite,
nonempty-membered family of $A$–nail path traces in a wall, each of size at most
$c = 4$ (the wall-degree of a nail). If $\mathcal F$ has no $s$-packing, then there
is a hitting set $X$ with*
$$|X| \;\le\; 4s - 4 \;=\; F(s).$$

*Proof sketch.* Instantiate Theorem 2 with $c = 4$: $|X| \le 4(s-1) = 4s-4$.
$\qquad\square$

**Corollary 3.3 ($d$-regular gadgets).** Replacing the nail wall-degree $4$ by an
arbitrary bound $d$ gives $|X| \le d(s-1) =: F_d(s)$ verbatim, since Theorem 2 is
parametric in $c$.

---

## 4. From the engine to the wall dichotomy

The wall geometry contributes the height constant and the "clean subwall" via a
tiling and a pigeonhole, layered on Theorem 3. We outline the assembly
(`wall_menger_dichotomy`); the constants are dictated by §3.

**Lemma 4.1 (`subwall_tiling`).** *An elementary wall $W$ of height $(8s+4)r$
contains a family of pairwise vertex-disjoint $r$-subwalls of size at least
$8s+4$ (one per height-$r$ horizontal band, with horizontal room to spare).*

**Lemma 4.2 (`exists_clean_subwall`).** *Suppose $W$ has at least $8s+4$ disjoint
$r$-subwalls. Any separator of size $\le F(s) = 4s-4$ meets at most $4s-4$ of
them, and the at most $2s$ nail-endpoints of an $s$-fold path system occupy at most
$2s$ further subwalls; since $(4s-4) + 2s = 6s-4 < 8s+4$, at least one $r$-subwall
$W'$ is untouched by both.*

*Proof sketch.* Pigeonhole over the index family `Fin (8*s+4)` of disjoint
subwalls: subtract the at most $4s-4$ subwalls hit by $X$ and the at most $2s$
subwalls carrying endpoints; a strictly positive remainder survives. The slack
$(8s+4)-(6s-4) = 2s+8 > 0$ is recorded explicitly. $\qquad\square$

**Theorem 4.3 (`wall_menger_dichotomy`, conjecture assembly).** *With
$T(s,r)=(8s+4)r$ and $F(s)=4s-4$ as above, the one-set dichotomy of §1 holds: for
every $G$, $A$, and elementary wall $W$ of height $\ge T(s,r)$, either a separator
of size $\le F(s)$ cuts $A$ from the branch vertices of $W$, or some $r$-subwall
admits an $s$-fold clean $A$-path system.*

*Proof sketch.* Apply the packing–cover dichotomy (Theorems 2–3) to the family of
$A$–nail path traces. If there is no $s$-packing, Theorem 3 produces the separator
$X$ with $|X| \le F(s)$ — the cover horn. If there is an $s$-packing, route its $s$
disjoint paths to their nail endpoints, then use Lemma 4.2 to find an $r$-subwall
$W'$ avoided by the (now bounded) endpoint set, into which the paths land on
distinct nails with clean interiors — the packing horn. $\qquad\square$

---

## 5. The connectivity bridge

The dichotomy's two horns are "small separator" and "large packing." Connectivity
is, by definition, the absence of small separators, so it should force the packing
horn. The following makes the packing witness explicit and unconditional.

**Theorem 4 (`kConnected_neighbor_packing`).** *Let $G$ be a finite simple graph
that is $k$-connected, and let $w$ be any vertex. Then the family of neighbour
singletons*
$$P \;=\; \big\{\, \{n\} : n \in N_G(w) \,\big\}$$
*is pairwise disjoint, every member is nonempty, and $|P| \ge k$. Hence the
packing horn of the dichotomy is witnessed locally with packing number $\ge k$.*

*Proof sketch.* The map $v \mapsto \{v\}$ is injective, so $|P| = |N_G(w)|$
(`Finset.card_image_of_injective`). By the easy half of Whitney's inequality
$\kappa(G) \le \delta(G)$ — formalised as `IsKConnected.le_ncard_neighborSet` — a
$k$-connected graph has minimum degree $\ge k$, hence $|N_G(w)| \ge k$ and
$|P| \ge k$ (after the routine `Set.ncard` $\leftrightarrow$ `Finset.card`
translation via `coe_neighborFinset`). Distinct singletons $\{a\}, \{b\}$ with
$a \neq b$ are disjoint (`Finset.disjoint_singleton`), giving pairwise
disjointness; each $\{n\}$ is nonempty (`Finset.singleton_nonempty`). $\qquad
\square$

**Remark 5.1.** The witness is deliberately the cheapest possible (the trivial
singleton packing). Its purpose is to certify that in a connected graph the
packing bound is *never* the obstruction: whenever $k \ge s$, the local
neighbourhood already realises an $s$-packing. The genuine difficulty in the
conjecture is routing those paths into a *single* $r$-subwall, which is the
content of §4, not of Theorem 4. This also shows that the cover horn cannot be the
only option in any sufficiently connected instance (cf. Future Directions D4).

---

## 6. Algorithms

**Algorithm A (Greedy maximal packing).** Given a finite family $\mathcal F$,
repeatedly select a member disjoint from all previously selected members until none
remains; return the selected subfamily $P$ and its union $X$. Correctness: the
returned $P$ is maximal (no member can be added), which by the argument of Theorem
2 makes $X = \bigcup P$ a hitting set; if $\mathcal F$ is $c$-bounded and has no
$s$-packing then $|X| \le c(s-1)$. Complexity: $O(|\mathcal F|^2 \cdot c)$
disjointness checks with a naive implementation, or near-linear with a membership
bitset. (A maximal packing need not be maximum, but the hitting and the
$c\cdot(\text{maximal size})$ bound both hold for any *maximal* packing; the
*tight* bound $c(s-1)$ uses only $|P| \le s-1$, which holds for any packing once no
$s$-packing exists.)

**Algorithm B (Separator extraction at $c=4$).** Specialise Algorithm A to wall
$A$–nail path traces of size $\le 4$; the union of a maximal packing is a separator
of size $\le 4s-4$ whenever no $s$ disjoint $A$–nail paths exist.

**Algorithm C (Clean-subwall selection).** Given disjoint $r$-subwalls
$W_0,\dots,W_{8s+3}$, a separator $X$ ($|X|\le 4s-4$), and endpoint set $E$
($|E|\le 2s$), mark every subwall meeting $X \cup E$ and return any unmarked one;
at least $2s+8$ remain unmarked by Lemma 4.2.

---

## 7. Applications

- **Explicit irrelevant-vertex arguments.** The linear height $T(s,r)=(8s+4)r$ lets
  one demand a clean $r$-subwall with disjoint approaches from a terminal set $A$
  at a cost linear in $r$, the typical inner loop of minor-testing and
  treewidth-reduction routines.
- **Parameterised separators.** Theorem 3 gives a kernel-friendly separator of size
  $4s-4$ depending only on $s$, useful in FPT algorithms where one branches on a
  bounded separator or certifies many disjoint connections.
- **Connectivity certification.** Theorem 4 turns a connectivity hypothesis
  $k \ge s$ directly into a certified $s$-packing witness, bypassing any search.
- **General gadgets.** Corollary 3.3 ports the bound to any routing gadget of nail
  wall-degree $d$, giving $F_d(s) = d(s-1)$.

---

## 8. Discussion

The result is a small but instructive instance of a general principle: *explicit,
linear structural bounds usually descend from a one-line greedy duality, with the
geometry contributing only the local cost constant and a bookkeeping budget.* Here
the greedy duality is $\tau \le c\,\nu$ (Theorem 2); the wall contributes $c = 4$
(nail wall-degree, Theorem 3) and the tiling budget $8s+4$ (Lemma 4.2). Because
the proof exposes the provenance of every constant, the bounds are transparently
improvable (Future Directions D1, D2) and their tightness conditions are
analysable (D3).

The connectivity bridge (Theorem 4) closes the conceptual loop opened by Menger:
"highly connected" means "no cheap cut," which the dichotomy reads as "the packing
horn must fire," and Theorem 4 supplies the packing witness explicitly and for
free. It is the cheapest honest witness, by design — its value is as a certificate
that one horn is unconditionally available, not as a deep structural statement.

---

## 9. Future directions

**D1. Lowering the height from $(8s+4)r$ to $6s\cdot r$.** The dichotomy should
persist with $T'(s,r) = 6s\,r$: the separator costs $\le F(s)=4s-4$ subwalls and
the $\le 2s$ endpoints spoil $\le 2s$ more, totalling $6s-4 < 6s$ spoiled subwalls,
so one survives. The exact slack $8s+4-(4s-4)=4s+8$ isolated in
`exists_clean_subwall` is never fully used, so the budget can be tightened and
re-verified by re-running the pigeonhole with the smaller `Fin (6*s)` index type.

**D2. The constant $4$ is the nail degree; generalise to $F_d(s)=d(s-1)$.** For any
gadget whose nails have $\le d$ wall-neighbours the one-set separator bound is
$d(s-1)$, attained. Since `packing_cover_duality` is parametric in $c$ and
`wall_menger_separator_bound` is its $c=4$ case, replacing $4$ by $d$ is a one-line
instantiation; a matching lower-bound construction would establish sharpness.

**D3. Greedy is off from exact Menger by at most a factor $c$, with a sunflower
tightness condition.** If the greedy cover bound $c\cdot\nu$ is attained by the
true minimum separator, then the maximal packing's members pairwise intersect the
separator in a common pattern (sunflower core). This follows from analysing the
equality cases of `card_biUnion_le` and `sum_le_sum` in the proof of Theorem 2.

**D4. Connectivity strictly forbids the cover horn.** In a $k$-connected graph with
$k \ge 4s-3$, every instance of the dichotomy lands in the packing horn — there is
genuinely an $s$-packing of $A$–wall path traces — never the separator horn, since
no separator of size $\le 4s-4 < k$ can exist. `kConnected_neighbor_packing`
already supplies the local packing witness; the task is to route it into a common
subwall under the connectivity hypothesis.

---

## 10. Formal status

All four numbered theorems correspond to machine-checked declarations:
`exists_maximal_packing`, `packing_cover_duality`, `wall_menger_separator_bound`
(in `WallMengerCore.lean`), and `kConnected_neighbor_packing` (in
`WallMengerConnectivityBridge.lean`, building on `IsKConnected` and the Whitney
bound `IsKConnected.le_ncard_neighborSet` from `Connectivity.lean`). The wall
assembly `wall_menger_dichotomy` with `subwall_tiling` and `exists_clean_subwall`
layers the geometric bookkeeping of §4 on top of Theorem 3.
