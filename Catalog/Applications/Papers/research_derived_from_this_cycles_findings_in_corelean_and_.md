# The Edge-Count Profile of Vietoris–Rips Filtrations: A Monotone, Functorial Invariant of Finite Metric Spaces

## Abstract

We develop a compact, fully rigorous theory of the **edge-count profile** of the
Vietoris–Rips 1-skeleton of a finite (pseudo)metric space. For a finite metric
space $\alpha$ and a scale parameter $r$, the edge count $E_\alpha(r)$ is the
number of edges of the Rips graph at scale $r$ — the graph whose vertices are the
points of $\alpha$ and whose edges join pairs at distance at most $r$. We
establish three structural results. First, **monotonicity**: $E_\alpha$ is a
nondecreasing function of the scale, with $E_\alpha(0) = 0$ in a genuine metric
space and a uniform ceiling given by the number of unordered pairs. Second,
**functoriality**: every injective, distance-nonincreasing (nonexpanding) map
$f : \alpha \to \beta$ induces, scale by scale, the domination
$E_\alpha(r) \le E_\beta(r)$; equivalently, the edge map $\mathrm{Sym}^2 f$
carries Rips edges injectively to Rips edges. Third, we record the
**boundary/normalization** facts that frame the profile as an element of a finite
lattice of monotone $\mathbb{N}$-valued functions. We discuss the interpretation
of the profile's jump set as the multiset of pairwise distances (a discrete
derivative of the distance distribution), the categorical reading of the
construction as a functor from finite metric spaces with injective nonexpanding
maps to monotone integer profiles under pointwise domination, and applications to
topological data analysis. We close with a program of conjectures extending the
profile to a complete invariant of the distance multiset, to a genuine partial
order, to a reversed bound for surjective (gluing) maps, and to a reconstruction
of ultrametric structure. All stated theorems have been formalized and
machine-checked.

**Keywords.** Vietoris–Rips complex, edge count, filtration, monotone invariant,
functoriality, nonexpanding map, topological data analysis, finite metric space.

---

## 1. Introduction

### 1.1 Motivation

The Vietoris–Rips construction is the workhorse of applied topology. Given a
finite metric space — a point cloud sampled from some underlying object — one
forms, at each scale $\varepsilon$, a graph (and, more generally, a simplicial
complex) recording which points are mutually close. As $\varepsilon$ increases,
these graphs grow, producing a *filtration* whose evolving topology is the raw
material of **persistent homology**.

The very first invariant attached to such a filtration is the most elementary
one: the number of edges present at each scale. Despite its simplicity, this
**edge-count profile** is a genuine and useful summary. It is monotone, it is
cheap to compute, it is stable under the maps one cares about, and its jump set
encodes the entire multiset of pairwise distances. This paper isolates this
invariant, states the structural theorems it obeys, and frames it categorically.

### 1.2 Contributions

We contribute a self-contained, formally verified API:

1. A definition of the edge count $E_\alpha(r)$ and the profile $r \mapsto
   E_\alpha(r)$ in two equivalent forms (real-valued and integer-threshold).
2. **Monotonicity** of the profile in the scale (Theorem 3.1) and its
   order-theoretic packaging (Corollary 3.2).
3. **Boundary normalization**: vanishing at scale $0$ (Theorem 3.3) and a
   uniform pairwise-count ceiling (Theorem 3.4).
4. **Functoriality**: the edge-transport lemma for injective nonexpanding maps
   (Lemma 4.1) and the resulting cross-space domination (Theorem 4.2).
5. A discussion of the jump-set interpretation, the categorical structure, and a
   conjectural program (Section 7).

### 1.3 Relation to prior structure

The development builds on a small metric-filtration substrate: the Rips graph
construction, its filtration monotonicity, and its boundary behavior. We treat
those as given primitives (Section 2) and focus on the *edge-counting* layer.

---

## 2. Preliminaries: the Rips graph and its filtration

Throughout, $\alpha$ denotes a finite type equipped with a (pseudo)metric
$d = \mathrm{dist}$. We write $\mathrm{Sym}^2 \alpha$ for the set of unordered
pairs of elements of $\alpha$ (including the diagonal).

**Definition 2.1 (Rips graph).** For $\varepsilon \in \mathbb{R}$, the *Rips
graph* $\mathrm{Rips}(\alpha, \varepsilon)$ is the simple graph on vertex set
$\alpha$ with adjacency
$$
x \sim y \iff x \ne y \ \text{and}\ d(x, y) \le \varepsilon .
$$
Symmetry follows from $d(x,y) = d(y,x)$, and the absence of loops from the
$x \ne y$ clause.

**Lemma 2.2 (Filtration monotonicity).** *If $\varepsilon_1 \le \varepsilon_2$
then $\mathrm{Rips}(\alpha, \varepsilon_1) \le \mathrm{Rips}(\alpha,
\varepsilon_2)$ as subgraphs (every edge of the former is an edge of the
latter).*

*Proof.* If $x \sim y$ at scale $\varepsilon_1$ then $x \ne y$ and
$d(x,y) \le \varepsilon_1 \le \varepsilon_2$, so $x \sim y$ at scale
$\varepsilon_2$. $\qquad\blacksquare$

**Lemma 2.3 (Boundary behavior).** *In a metric space,
$\mathrm{Rips}(\alpha, 0) = \bot$ (the empty graph). For any $\varepsilon < 0$,
$\mathrm{Rips}(\alpha, \varepsilon) = \bot$.*

*Proof.* If $x \sim y$ at scale $0$ then $d(x,y) \le 0$, and since
$d(x,y) \ge 0$ we get $d(x,y) = 0$, forcing $x = y$ in a metric space —
contradicting $x \ne y$. For $\varepsilon < 0$, no pair can satisfy
$d(x,y) \le \varepsilon < 0$ since distances are nonnegative.
$\qquad\blacksquare$

These primitives are the only external facts we use.

---

## 3. The edge-count profile and its monotonicity

**Definition 3.1 (Edge count and profile).** Let $E(G)$ denote the edge set of a
simple graph $G$, and $|{\cdot}|$ the (finite) cardinality. For a finite metric
space $\alpha$ define
$$
E_\alpha(r) \;:=\; \big|\, E\big(\mathrm{Rips}(\alpha, r)\big)\,\big|, \qquad r \in \mathbb{R}.
$$
The **Rips edge-count profile** is the function
$\mathrm{ripsProfile}_\alpha : \mathbb{R} \to \mathbb{N}$,
$\;r \mapsto E_\alpha(r)$. When restricting to integer thresholds we write
$\mathrm{edgeCountProfile}_\alpha : \mathbb{N} \to \mathbb{N}$,
$\;r \mapsto E_\alpha(r)$, counting edges as the cardinality of the edge set
$\subseteq \mathrm{Sym}^2 \alpha$.

(The two forms agree on integer inputs; the integer form is convenient because
its codomain $\mathbb{N}$ is well-ordered and the threshold lattice is
$(\mathbb{N}, \le)$. Finiteness of the edge set is automatic since
$\mathrm{Sym}^2\alpha$ is finite when $\alpha$ is.)

**Theorem 3.1 (Monotonicity in scale).** *For all $r \le s$,*
$$
E_\alpha(r) \;\le\; E_\alpha(s).
$$

*Proof.* By Lemma 2.2, $\mathrm{Rips}(\alpha, r)$ is a subgraph of
$\mathrm{Rips}(\alpha, s)$, hence $E(\mathrm{Rips}(\alpha, r)) \subseteq
E(\mathrm{Rips}(\alpha, s))$. Cardinality is monotone under inclusion of finite
sets, so $E_\alpha(r) \le E_\alpha(s)$. $\qquad\blacksquare$

**Corollary 3.2 (Order-theoretic packaging).** *The profile
$\mathrm{ripsProfile}_\alpha$ (resp. $\mathrm{edgeCountProfile}_\alpha$) is a
monotone function. Equivalently it is an order-preserving map
$(\mathbb{R}, \le) \to (\mathbb{N}, \le)$ (resp. $(\mathbb{N}, \le) \to
(\mathbb{N}, \le)$).*

*Proof.* Immediate from Theorem 3.1 and the definition of monotonicity.
$\qquad\blacksquare$

**Theorem 3.3 (Vanishing at scale $0$).** *In a metric space,
$E_\alpha(0) = 0$.*

*Proof.* By Lemma 2.3, $\mathrm{Rips}(\alpha, 0) = \bot$, whose edge set is
empty; the empty set has cardinality $0$. $\qquad\blacksquare$

**Theorem 3.4 (Uniform pairwise ceiling).** *For every $r$,*
$$
E_\alpha(r) \;\le\; \big|\mathrm{Sym}^2 \alpha\big|.
$$
*In particular, for $|\alpha| = n$ the count is bounded by
$\binom{n}{2} + n = \tfrac{n(n+1)}{2}$, and by the tighter
$\binom{n}{2} = \tfrac{n(n-1)}{2}$ since edges avoid the diagonal.*

*Proof.* Every edge of $\mathrm{Rips}(\alpha, r)$ is an unordered pair, i.e. an
element of $\mathrm{Sym}^2\alpha$; thus the edge set is a subset of
$\mathrm{Sym}^2\alpha$, and cardinality is monotone under inclusion. The numeric
bounds follow from $|\mathrm{Sym}^2\alpha| = \tfrac{n(n+1)}{2}$ and the exclusion
of loops. $\qquad\blacksquare$

Theorems 3.1, 3.3, and 3.4 together place the profile inside a finite box: it
begins at $0$, is nondecreasing, and is capped by a function of $n$ alone. The
*content* of a particular space is in **where** and **by how much** the staircase
jumps.

---

## 4. Functoriality under injective nonexpanding maps

We now examine how the profile transforms under maps between metric spaces. Let
$\alpha, \beta$ be finite metric spaces and $f : \alpha \to \beta$ a function.

**Definition 4.1.** The map $f$ is **nonexpanding** (distance-nonincreasing) if
$d(f(x), f(y)) \le d(x, y)$ for all $x, y$. It is **injective** if
$f(x) = f(y) \Rightarrow x = y$.

**Lemma 4.1 (Edge transport).** *If $f$ is injective and nonexpanding, then for
all $x, y$ and every scale $r$,*
$$
x \sim y \text{ in } \mathrm{Rips}(\alpha, r) \;\Longrightarrow\; f(x) \sim f(y) \text{ in } \mathrm{Rips}(\beta, r).
$$

*Proof.* Suppose $x \sim y$ at scale $r$, i.e. $x \ne y$ and $d(x,y) \le r$.
Injectivity gives $f(x) \ne f(y)$ (else $x = y$). Nonexpansiveness gives
$d(f(x), f(y)) \le d(x, y) \le r$. Hence $f(x) \sim f(y)$ at scale $r$.
$\qquad\blacksquare$

Let $\mathrm{Sym}^2 f : \mathrm{Sym}^2\alpha \to \mathrm{Sym}^2\beta$ denote the
induced map on unordered pairs, $\{x, y\} \mapsto \{f(x), f(y)\}$.

**Theorem 4.2 (Cross-space domination).** *If $f : \alpha \to \beta$ is injective
and nonexpanding, then for every scale $r$,*
$$
E_\alpha(r) \;\le\; E_\beta(r).
$$

*Proof.* Lemma 4.1 says $\mathrm{Sym}^2 f$ sends each edge of
$\mathrm{Rips}(\alpha, r)$ to an edge of $\mathrm{Rips}(\beta, r)$; thus it
restricts to a map from $E(\mathrm{Rips}(\alpha, r))$ into
$E(\mathrm{Rips}(\beta, r))$. Because $f$ is injective, $\mathrm{Sym}^2 f$ is
injective on $\mathrm{Sym}^2\alpha$, and in particular injective on the edge set.
An injection between finite sets forces the domain's cardinality to be at most the
codomain's, giving $E_\alpha(r) \le E_\beta(r)$. $\qquad\blacksquare$

**Remark 4.3 (Necessity of injectivity).** Injectivity cannot be dropped. A
constant (hence non-injective) map collapses all points to one image, where there
are no edges at all, while the source may have many. More generally a gluing
(surjective, non-injective) map can *decrease* the edge count after collapse, so
the forward bound $E_\alpha(r) \le E_\beta(r)$ fails. The correct statement for
collapsing maps is a *reversed*, fiber-weighted bound (Conjecture C4 in
Section 7).

**Remark 4.4 (Necessity of nonexpansiveness).** Nonexpansiveness cannot be
dropped either: an expanding map can push two close points apart beyond scale
$r$, destroying an edge and again breaking the forward bound.

---

## 5. The categorical picture

Theorems 3.1 and 4.2 combine into a single functorial statement. Consider:

- **Source category $\mathbf{FinMet}_{\mathrm{inj}}$**: objects are finite metric
  spaces; morphisms are injective nonexpanding maps. Composition and identities
  are the usual ones (the composite of injective nonexpanding maps is injective
  and nonexpanding).
- **Target category $\mathbf{Prof}$**: objects are monotone functions
  $\mathbb{N} \to \mathbb{N}$ (equivalently $\mathbb{R} \to \mathbb{N}$); there is
  a (unique) morphism $P \to Q$ exactly when $P(r) \le Q(r)$ for all $r$. This is
  the thin category of the pointwise-domination preorder on profiles.

**Proposition 5.1.** *The assignment*
$$
\alpha \;\longmapsto\; \mathrm{ripsProfile}_\alpha, \qquad
(f : \alpha \to \beta) \;\longmapsto\; \big(\mathrm{ripsProfile}_\alpha \le \mathrm{ripsProfile}_\beta\big)
$$
*is a functor $\mathbf{FinMet}_{\mathrm{inj}} \to \mathbf{Prof}$.*

*Proof.* On objects, Corollary 3.2 ensures each profile is indeed monotone, hence
an object of $\mathbf{Prof}$. On morphisms, Theorem 4.2 supplies the required
domination $\mathrm{ripsProfile}_\alpha \le \mathrm{ripsProfile}_\beta$ for each
injective nonexpanding $f$. Functoriality (preservation of identities and
composites) is automatic because $\mathbf{Prof}$ is *thin*: there is at most one
morphism between any two objects, so all coherence diagrams commute trivially.
$\qquad\blacksquare$

This is the precise sense in which "point cloud $\mapsto$ edge-count profile" is
not just a numerical summary but a *structure-preserving* one: it transports the
faithful, non-stretching maps of geometry to the domination order of monotone
profiles.

**Domination as a preorder.** On profiles, pointwise $\le$ is reflexive and
transitive — a preorder. It is moreover *antisymmetric on the quotient* by "equal
profile" (since two monotone $\mathbb{N}$-valued functions that dominate each
other are equal), so domination is a genuine **partial order** on profiles
themselves; this is the order-theoretic content underlying Conjecture C3.

---

## 6. The jump set: profiles as discrete derivatives of distance

Fix a finite metric space $\alpha$ with $|\alpha| = n$ and integer pairwise
distances. As $r$ runs over $\mathbb{N}$, the increments
$$
\Delta_\alpha(r) \;:=\; E_\alpha(r) - E_\alpha(r-1) \;\ge\; 0
$$
count exactly the pairs whose distance equals $r$:
$$
\Delta_\alpha(r) \;=\; \#\{\{x,y\} : x \ne y,\ d(x,y) = r\}.
$$
Indeed an edge $\{x,y\}$ is present at scale $r$ but absent at $r-1$ iff
$r-1 < d(x,y) \le r$, i.e. $d(x,y) = r$ for integer distances.

**Proposition 6.1 (Distance histogram recovery).** *For finite metric spaces
with integer distances, the family $\{\Delta_\alpha(r)\}_{r \ge 1}$ is exactly
the histogram of the multiset of pairwise distances, and*
$$
E_\alpha(r) = \sum_{k \le r} \Delta_\alpha(k).
$$
*Consequently the profile and the distance multiset determine one another.*

*Proof.* The increment identity above gives the histogram; summing the telescoping
increments from the base value $E_\alpha(0) = 0$ (Theorem 3.3) recovers the
profile, and conversely differencing the profile recovers the histogram.
$\qquad\blacksquare$

Thus the edge-count profile is literally the cumulative distribution function of
pairwise distances, and its discrete derivative is the distance histogram. This
exhibits the profile as a *complete invariant of the distance multiset* (though,
as with the distance multiset itself, not of the configuration up to isometry —
there exist non-isometric configurations sharing a distance multiset). The
ceiling of Theorem 3.4 is the statement $\sum_r \Delta_\alpha(r) = \binom{n}{2}$.

---

## 7. Conjectural program and future directions

The verified core suggests several natural extensions, each stated so it can be
formalized directly.

**C1 — Strict monotonicity at critical scales.** *For a finite metric space with
at least two points at distance $d$, the profile strictly increases at the
threshold $r = \lceil d \rceil$: $E_\alpha(r-1) < E_\alpha(r)$ whenever a pair
first becomes connected at $r$.* The increment identity of Section 6 reduces this
to exhibiting one witnessing edge in the difference set; this upgrades the weak
inequality of Theorem 3.1 to a genuine persistence statement.

**C2 — Profiles separate distance multisets.** *Two finite metric spaces with
integer distances have equal edge-count profiles for all $r$ iff they have the
same multiset of pairwise distances.* This is Proposition 6.1 promoted to an iff;
the forward direction is immediate and the reverse is a counting identity over
$\mathrm{Sym}^2\alpha$.

**C3 — Domination is a partial order.** *On the quotient of finite integer metric
spaces by "equal profile", $\mathrm{ripsProfile}_\alpha \le
\mathrm{ripsProfile}_\beta \le \mathrm{ripsProfile}_\alpha$ forces equal
profiles.* Reflexivity and transitivity are inherited from $(\mathbb{N}, \le)$;
antisymmetry of pointwise order on $\mathbb{N}$-valued functions upgrades the
preorder of Section 5 to a partial order.

**C4 — Reversed bound for gluing maps.** *A surjective nonexpanding map
$f : \alpha \to \beta$ satisfies a fiber-weighted reversed bound
$E_\beta(r) \le c_f \cdot E_\alpha(r)$ with $c_f$ explicit in the fiber sizes; in
particular gluing maps can only decrease edges after accounting for collapsed
pairs.* This makes Remark 4.3 quantitative and exposes a second, colimit-flavored
functor dual to the embedding functor of Section 5.

**C5 — Ultrametric reconstruction.** *The edge-count profile of a finite metric
space induces a separated ultrametric norm object whose norm is the threshold at
which two configurations first agree, with nonexpanding embeddings inducing
ultrametric morphisms.* This would close the loop between the combinatorial
profile and the tropical/ultrametric reconstruction machinery: the profile is a
$\mathbb{N}$-valued tropical datum, exactly the input a valuation-reconstruction
functor consumes.

---

## 8. Discussion

The edge-count profile sits at the very bottom of the persistent-homology
hierarchy — it is the $\beta_1$-ignorant, dimension-one-skeleton, cardinality-only
summary. Precisely because it is so simple, its structural guarantees are
unconditional and exact: monotonicity holds for *every* finite metric space, the
domination bound holds for *every* injective nonexpanding map, and the boundary
normalizations are sharp. These are the properties that the heavier invariants
(persistence diagrams, barcodes, persistence landscapes) inherit and refine.

The functorial framing is the conceptual payoff. By recording not just a number
per dataset but a domination per faithful map, the profile becomes a stable,
order-preserving probe: faithful sub-sampling cannot push a profile above its
parent, and non-stretching compression cannot inflate it. In applications — from
cosmic-web cartography to protein-landscape analysis to neural-cycle detection —
this is exactly the kind of robustness one wants from a first-pass shape summary.

We have stated and verified the core; Sections 6–7 chart the route from "a useful
number" to "a complete invariant of the distance multiset" and onward to
order-theoretic and ultrametric refinements.

---

## Appendix A. Summary of formalized results

| Name | Statement |
|------|-----------|
| `ripsGraph_mono` | $\varepsilon_1 \le \varepsilon_2 \Rightarrow \mathrm{Rips}(\alpha,\varepsilon_1) \le \mathrm{Rips}(\alpha,\varepsilon_2)$ |
| `ripsGraph_bot_of_metric` | $\mathrm{Rips}(\alpha, 0) = \bot$ in a metric space |
| `ripsGraph_bot_of_neg` | $\varepsilon < 0 \Rightarrow \mathrm{Rips}(\alpha, \varepsilon) = \bot$ |
| `edgeCount` / `edgeCountProfile` | $E_\alpha(r) = $ number of Rips edges at scale $r$ |
| `edgeCount_mono` / `edgeCountProfile_le` | $r \le s \Rightarrow E_\alpha(r) \le E_\alpha(s)$ (Thm 3.1) |
| `ripsProfile_monotone` / `edgeCountProfile_mono` | $\mathrm{Monotone}(r \mapsto E_\alpha(r))$ (Cor 3.2) |
| `edgeCountProfile_zero` | $E_\alpha(0) = 0$ (Thm 3.3) |
| `edgeCountProfile_le_card_sym2` | $E_\alpha(r) \le \lvert\mathrm{Sym}^2\alpha\rvert$ (Thm 3.4) |
| `ripsGraph_adj_map` | injective nonexpanding $f$ sends edges to edges (Lem 4.1) |
| `edgeCount_le_of_injective_nonexpanding` | $E_\alpha(r) \le E_\beta(r)$ for injective nonexpanding $f$ (Thm 4.2) |

All results are stated for finite (pseudo)metric spaces and are machine-checked.
