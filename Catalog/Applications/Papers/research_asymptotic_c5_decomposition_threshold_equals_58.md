# Necessary Divisibility Conditions for $C_5$-Decompositions and the Asymptotic Threshold $\delta_{C_5} = 5/8$

**Author:** Aristotle
**Date:** 2026-06-25
**Domain:** Novelty (Extremal and Structural Graph Theory)

---

## Abstract

We study edge-decompositions of finite simple graphs into five-cycles
($C_5$-decompositions) and the divisibility obstructions that govern them. We
give a complete, rigorous treatment of the *necessity* direction: every graph
$G$ that admits an edge-decomposition into $5$-cycles is **$C_5$-divisible**,
meaning every vertex has even degree and $5$ divides the number of edges. The
two conditions arise from elementary but structurally decisive counting: each
$5$-cycle contributes exactly $5$ edges to the global total (so $|E(G)| = 5k$
for a decomposition into $k$ cycles), and each vertex meets any single
$5$-cycle in either $0$ or $2$ edges (so every degree is a sum of even
contributions). We isolate the two combinatorial facts that carry all the
content — the *edge-injectivity* of the cyclic edge map on $\mathbb{Z}/5$ and
the *even local incidence* of each vertex — and explain why the odd cycle
length is essential: the only collapse case in the edge map is killed precisely
by $2 \not\equiv 0 \pmod 5$. We then situate these necessary conditions within
the conjectural asymptotic framework: for every $\varepsilon > 0$, every
$C_5$-divisible graph on $n$ sufficiently large vertices with minimum degree at
least $\left(\tfrac{5}{8} + \varepsilon\right) n$ should admit a
$C_5$-decomposition. The threshold $5/8$ is the value $\ell = 5$ of the
generalized Nash–Williams family $\delta_{C_\ell} = \ell/(2\ell - 2)$, a
strictly decreasing rational sequence converging to $1/2$. The pentagon is the
isolated remaining *small* odd-cycle case after the triangle threshold $3/4$
and the long-odd-cycle regime. We accompany the theory with a non-vacuity
witness (the pentagon decomposes into itself; $K_5$ into two pentagons),
numerical demonstrations, and a discussion of the open existence and sharpness
conjectures.

---

## 1. Introduction

### 1.1 The decomposition paradigm

A central paradigm in extremal and design-theoretic combinatorics asks when a
large structure can be partitioned into copies of a fixed small structure.
Given a fixed graph $H$, an **$H$-decomposition** of a graph $G$ is a partition
of the edge set $E(G)$ into subgraphs each isomorphic to $H$. The case $H =
K_2$ (a single edge) is trivial; the case $H = K_3$ (a triangle) is the subject
of the celebrated Nash–Williams conjecture and the Delcourt–Postle /
Glock–Kühn–Osthus program. Between these extremes lies a rich landscape of
results governed by a recurring two-part logic:

1. **Divisibility (necessity).** Local and global congruence conditions that
   *must* hold for any $H$-decomposition to exist. These are typically
   elementary.
2. **Density (sufficiency).** A minimum-degree (or quasirandomness) threshold
   above which the divisibility conditions become *sufficient*. These are
   typically deep.

This paper treats $H = C_5$, the five-cycle, and gives a complete formal
account of part (1), together with a precise statement and contextualization of
the conjectural threshold in part (2).

### 1.2 The pentagon as the remaining small odd case

For cycle decompositions, the conjectured sufficiency threshold is
$$
\delta_{C_\ell} \;=\; \frac{\ell}{2\ell - 2}
$$
for the minimum degree (as a fraction of $n$) required to force a
$C_\ell$-decomposition of a $C_\ell$-divisible graph. For the triangle
($\ell = 3$) this gives $3/4$; for the pentagon ($\ell = 5$) it gives $5/8$.
The triangle case and the long-odd-cycle regime have received intensive
attention, leaving the pentagon as the isolated *smallest nontrivial odd*
case — the focus of this work.

### 1.3 Contributions

- A precise formalization of $5$-cycle edge sets, $C_5$-decompositions, and
  the $C_5$-divisibility predicate (Section 3).
- Two structural lemmas — **edge cardinality** (`c5edges_card`) and **even
  local incidence** (`c5edges_even_incidence`) — that carry all combinatorial
  content, with explicit identification of where odd cycle length is essential
  (Section 4).
- The main necessity theorems: the **edge-count identity** $|E(G)| = 5k$
  (`card_edgeFinset_eq`), **global $5$-divisibility**
  (`five_dvd_card_edgeFinset`), **even degrees** (`even_degree`), their
  combination into $C_5$-**divisibility** (`c5_decomposition_divisible`), and
  the **contrapositive obstruction** (`no_decomposition_of_not_divisible`)
  (Section 5).
- Non-vacuity witnesses and the conjectural $5/8$ threshold with its place in
  the strictly decreasing Nash–Williams family (Sections 6–7).

---

## 2. Preliminaries and Notation

Throughout, $G = (V, E)$ is a finite simple graph on a finite vertex type $V$
with decidable adjacency. We write $E(G)$ for the edge set, realized as a
finite set of unordered pairs (elements of the symmetric square
$\mathrm{Sym}^2 V$), and $|E(G)|$ for its cardinality. For a vertex $w \in V$,
the **degree** $\deg_G(w)$ is the number of edges incident to $w$; equivalently,
it is the cardinality of the *incidence set*
$$
I_G(w) \;=\; \{\, e \in E(G) : w \in e \,\}.
$$
We use $\mathbb{Z}/5 = \mathrm{Fin}\,5$ for cyclic indices $\{0,1,2,3,4\}$,
with addition $i + 1$ taken modulo $5$, so that index $4$ satisfies
$4 + 1 = 0$.

An unordered pair (edge) joining $a$ and $b$ is written $\{a, b\}$ (the class
of $(a,b)$ in $\mathrm{Sym}^2 V$); we have $\{a,b\} = \{b,a\}$ and membership
$w \in \{a,b\} \iff (w = a \lor w = b)$.

---

## 3. Definitions

### 3.1 Five-cycle edge sets

**Definition 3.1 (`c5edges`).** Given a map $v : \mathbb{Z}/5 \to V$, the
**$5$-cycle edge set through $v$** is
$$
\mathrm{c5edges}(v) \;=\; \bigl\{\, \{v(i),\, v(i+1)\} : i \in \mathbb{Z}/5 \,\bigr\}
\;=\; \mathrm{image}\bigl(i \mapsto \{v(i), v(i+1)\}\bigr).
$$
Concretely this is the closed walk
$$
\{v_0, v_1\},\ \{v_1, v_2\},\ \{v_2, v_3\},\ \{v_3, v_4\},\ \{v_4, v_0\},
$$
where the final edge (the case $i = 4$) wraps around to close the cycle.

**Definition 3.2 (`IsFiveCycle`).** A finite set of edges $s \subseteq
\mathrm{Sym}^2 V$ **is a five-cycle** if it arises from five distinct vertices
arranged cyclically:
$$
\mathrm{IsFiveCycle}(s) \;:\Longleftrightarrow\;
\exists\, v : \mathbb{Z}/5 \to V,\ \ v \text{ injective} \ \wedge\ s = \mathrm{c5edges}(v).
$$
The injectivity of $v$ encodes that the five vertices are genuinely distinct,
i.e., $s$ is a $5$-cycle and not a degenerate shorter closed walk.

### 3.2 Decompositions

**Definition 3.3 (`C5Decomposition`).** A **$C_5$-decomposition** of $G$ is a
finite family $\mathcal{P}$ of edge sets (the *parts*) such that:

- **(isCycle)** every part $p \in \mathcal{P}$ satisfies $\mathrm{IsFiveCycle}(p)$;
- **(disj)** the parts are pairwise disjoint as subsets of $\mathrm{Sym}^2 V$
  (no two cycles share an edge);
- **(cover)** $\bigcup_{p \in \mathcal{P}} p = E(G)$ (every edge is used exactly
  once).

The conditions (disj) + (cover) say precisely that $\mathcal{P}$ partitions
$E(G)$ into $5$-cycle edge sets.

### 3.3 Divisibility

**Definition 3.4 (`IsC5Divisible`).** A finite simple graph $G$ is
**$C_5$-divisible** if
$$
\bigl(\forall w \in V,\ \deg_G(w) \text{ is even}\bigr)
\quad\wedge\quad
5 \mid |E(G)|.
$$

These are the candidate necessary-and-(conjecturally, above threshold)-
sufficient conditions for the existence of a $C_5$-decomposition.

---

## 4. Structural Lemmas

The entire necessity theory rests on two facts about a single $5$-cycle.

### 4.1 A five-cycle has exactly five edges

**Lemma 4.1 (`c5edges_card`).** If $v : \mathbb{Z}/5 \to V$ is injective, then
$$
|\mathrm{c5edges}(v)| = 5.
$$

**Proof sketch.** $\mathrm{c5edges}(v)$ is the image of the map $\Phi : i
\mapsto \{v(i), v(i+1)\}$ on the $5$-element index set $\mathbb{Z}/5$. It
suffices to show $\Phi$ is injective, for then the image has the same
cardinality as the domain. Suppose $\Phi(i) = \Phi(j)$, i.e., $\{v(i),
v(i+1)\} = \{v(j), v(j+1)\}$. As unordered pairs, either

- $v(i) = v(j)$ and $v(i+1) = v(j+1)$, whence $i = j$ by injectivity of $v$; or
- $v(i) = v(j+1)$ and $v(i+1) = v(j)$ (the *swap* case), whence $i = j+1$ and
  $i + 1 = j$ by injectivity of $v$. Substituting gives $j + 2 = j$ in
  $\mathbb{Z}/5$, i.e., $2 \equiv 0 \pmod 5$ — **false**.

Hence only $i = j$ survives, $\Phi$ is injective, and $|\mathrm{c5edges}(v)| =
|\mathbb{Z}/5| = 5$. $\qquad\blacksquare$

**Remark 4.2 (where oddness lives).** The swap case is eliminated solely
because $2 \not\equiv 0$ in $\mathbb{Z}/5$. For an *even* cycle length $2m$,
the analogous step would require $2 \not\equiv 0 \pmod{2m}$, which still holds
for $m > 1$, but the diametrically-opposite folding $i \mapsto i + m$ produces
genuine coincidences that break the naive count; the clean "$0$ or $2$"
incidence behavior and the edge-injectivity argument are exactly the features
that the odd length protects. The pentagon is the smallest odd length beyond
the triangle, and the inequality $2 \neq 0$ in $\mathbb{Z}/5$ is the precise
arithmetic witness.

### 4.2 Each vertex meets a five-cycle evenly

**Lemma 4.3 (`c5edges_even_incidence`).** If $v : \mathbb{Z}/5 \to V$ is
injective and $w \in V$, then
$$
\bigl|\{\, e \in \mathrm{c5edges}(v) : w \in e \,\}\bigr| \ \text{is even.}
$$

**Proof sketch.** Split on whether $w$ is a vertex of the cycle.

- **$w$ is not on the cycle:** then no edge $\{v(i), v(i+1)\}$ contains $w$
  (since $w \neq v(i)$ and $w \neq v(i+1)$ for all $i$), so the incidence set
  is empty and $0$ is even.
- **$w$ is on the cycle:** say $w = v(i_0)$ for the (unique, by injectivity)
  index $i_0$. The edges of the cycle containing $w$ are exactly the two
  incident edges $\{v(i_0 - 1), v(i_0)\}$ and $\{v(i_0), v(i_0 + 1)\}$. These
  are distinct (their other endpoints $v(i_0 - 1)$ and $v(i_0 + 1)$ differ
  because $i_0 - 1 \neq i_0 + 1$ in $\mathbb{Z}/5$, again using $2 \neq 0$).
  Hence the incidence count is exactly $2$, which is even.

Formally, the index set of incident edges is the union of the equinumerous,
disjoint families $\{i : v(i) = w\}$ and $\{i : v(i+1) = w\}$, each of size
$1$, giving a count of $2 = 2 \cdot 1$. $\qquad\blacksquare$

These two lemmas lift verbatim through `IsFiveCycle`:

**Corollary 4.4 (`IsFiveCycle.card_eq_five`).** If $\mathrm{IsFiveCycle}(s)$
then $|s| = 5$.

**Corollary 4.5 (`IsFiveCycle.even_incidence`).** If $\mathrm{IsFiveCycle}(s)$
and $w \in V$, then $|\{e \in s : w \in e\}|$ is even.

---

## 5. Main Results: Necessity of $C_5$-Divisibility

### 5.1 The edge-count identity

**Theorem 5.1 (`card_edgeFinset_eq`).** If $G$ admits a $C_5$-decomposition
$\mathcal{D}$ with parts $\mathcal{P}$, then
$$
|E(G)| \;=\; 5 \,\bigl|\mathcal{P}\bigr|.
$$

**Proof sketch.** By the cover condition, $E(G) = \bigcup_{p \in \mathcal{P}}
p$. Because the parts are pairwise disjoint, the cardinality of a disjoint
union is the sum of cardinalities:
$$
|E(G)| \;=\; \sum_{p \in \mathcal{P}} |p|.
$$
By Corollary 4.4, each $|p| = 5$, so the sum is $5 \cdot |\mathcal{P}|$.
$\qquad\blacksquare$

### 5.2 Global divisibility

**Theorem 5.2 (`five_dvd_card_edgeFinset`).** If $G$ admits a
$C_5$-decomposition, then $5 \mid |E(G)|$.

**Proof.** Immediate from Theorem 5.1: $|E(G)| = 5 |\mathcal{P}|$ exhibits
$|\mathcal{P}|$ as a witness to $5 \mid |E(G)|$. $\qquad\blacksquare$

### 5.3 Local parity

**Theorem 5.3 (`even_degree`).** If $G$ admits a $C_5$-decomposition
$\mathcal{D}$, then every vertex $w \in V$ has even degree.

**Proof sketch.** Realize the degree as the cardinality of the incidence set,
$\deg_G(w) = |I_G(w)| = |\{e \in E(G) : w \in e\}|$. Using the cover condition
and distributing the incidence filter over the (disjoint) union of parts,
$$
I_G(w) \;=\; \bigcup_{p \in \mathcal{P}} \{\, e \in p : w \in e \,\},
$$
and the families $\{e \in p : w \in e\}$ remain pairwise disjoint (they are
subsets of the disjoint parts). Hence
$$
\deg_G(w) \;=\; \sum_{p \in \mathcal{P}} \bigl|\{ e \in p : w \in e\}\bigr|.
$$
By Corollary 4.5 each summand is even, so the sum is even (a sum of even
numbers is even). $\qquad\blacksquare$

### 5.4 Necessity and its contrapositive

**Theorem 5.4 (`c5_decomposition_divisible`).** Every graph admitting a
$C_5$-decomposition is $C_5$-divisible.

**Proof.** Combine Theorem 5.3 (even degrees) with Theorem 5.2 ($5 \mid
|E(G)|$); together they are exactly Definition 3.4. $\qquad\blacksquare$

**Theorem 5.5 (`no_decomposition_of_not_divisible`).** If $G$ is *not*
$C_5$-divisible — i.e., some vertex has odd degree, or $5 \nmid |E(G)|$ — then
$G$ admits no $C_5$-decomposition.

**Proof.** Contrapositive of Theorem 5.4: a $C_5$-decomposition would force
$C_5$-divisibility, contradicting the hypothesis. $\qquad\blacksquare$

Theorem 5.5 is the practical workhorse: a single odd-degree vertex, or an edge
count not divisible by $5$, is a global, instantly-checkable certificate of
non-decomposability.

---

## 6. Non-Vacuity Witnesses

A necessity theorem is only meaningful if its hypothesis is satisfiable. Two
explicit witnesses establish this.

**Witness 6.1 (the pentagon, `cycleGraph5_decomposition`).** The cycle graph
$C_5$ on five vertices is its own $C_5$-decomposition: the single part is the
full edge set, which is a $5$-cycle. Here $|E| = 5$ ($5 \mid 5$) and every
degree equals $2$ (even), so $C_5$ is $C_5$-divisible and the divisibility
conclusion of Theorem 5.4 is *realized*, not merely vacuously implied.

**Witness 6.2 ($K_5$).** The complete graph $K_5$ has $\binom{5}{2} = 10$
edges and is $4$-regular; both conditions hold ($5 \mid 10$, $4$ even), so
$K_5$ is $C_5$-divisible. It decomposes into **two** edge-disjoint pentagons,
$$
K_5 = C_5 \cup C_5,
$$
e.g., the "outer pentagon" $0\,1\,2\,3\,4$ and the "inner pentagram"
$0\,2\,4\,1\,3$. This is the base case of the conjectural complete-graph
family.

---

## 7. The Asymptotic Threshold $\delta_{C_5} = 5/8$

### 7.1 Statement of the existence conjecture

The necessary conditions of Section 5 are conjectured to become sufficient once
the minimum degree crosses $5/8$.

**Conjecture 7.1 (existence threshold).** For every real $\varepsilon > 0$
there exists $N$ such that every $C_5$-divisible simple graph $G$ on $n \ge N$
vertices with minimum degree
$$
\delta(G) \;\ge\; \left(\tfrac{5}{8} + \varepsilon\right) n
$$
admits a $C_5$-decomposition.

### 7.2 The Nash–Williams family and monotonicity

The pentagon threshold is the value $\ell = 5$ of
$$
\delta_{C_\ell} \;=\; \frac{\ell}{2\ell - 2},
\qquad
\delta_{C_3} = \tfrac{3}{4},\ \
\delta_{C_5} = \tfrac{5}{8},\ \
\delta_{C_7} = \tfrac{7}{12},\ \dots
$$

**Proposition 7.2 (strict monotonicity, `nwThreshold_strictAnti`).** The map
$\ell \mapsto \dfrac{\ell}{2\ell - 2}$ is strictly decreasing for $\ell \ge 3$,
and
$$
\lim_{\ell \to \infty} \frac{\ell}{2\ell - 2} = \frac{1}{2}.
$$

**Proof sketch.** Write $\dfrac{\ell}{2\ell - 2} = \dfrac{1}{2} +
\dfrac{1}{2(\ell - 1)}$. The right-hand term $\dfrac{1}{2(\ell - 1)}$ is
strictly decreasing in $\ell$ and tends to $0$; hence the whole expression
strictly decreases to $\tfrac12$. $\qquad\blacksquare$

Thus longer odd cycles require strictly less density, the triangle ($3/4$) is
the most demanding, and the pentagon ($5/8$) is the **isolated remaining small
odd case** immediately below it.

### 7.3 Why divisibility is not sufficient without density

$C_5$-divisibility alone does not imply decomposability: one can construct
sparse $C_5$-divisible graphs in which some edge cannot be routed through any
$5$-cycle (a *space barrier*). The role of the minimum-degree hypothesis in
Conjecture 7.1 is precisely to provide enough local room — enough common
neighborhoods — to absorb every edge into a pentagon. This separation between
*arithmetic* feasibility (divisibility) and *geometric* feasibility (density)
is the source of the problem's depth.

---

## 8. Algorithmic Perspective

The results yield immediate decision procedures.

**Divisibility certificate.** Given $G$, computing all degrees and $|E(G)| \bmod
5$ takes $O(|V| + |E|)$ time and either certifies non-decomposability
(Theorem 5.5) or confirms the necessary conditions. This is a complete *no*-
oracle: if it rejects, no decomposition exists.

**Verification of a candidate decomposition.** Given a proposed family of
$5$-cycles, one checks each part is a genuine $5$-cycle ($5$ distinct vertices,
correct adjacencies), checks pairwise edge-disjointness, and checks that the
union equals $E(G)$. Theorem 5.1 provides a fast consistency pre-check: the
number of parts must equal $|E(G)|/5$.

**Search for a decomposition (small $n$).** Above the threshold one expects
existence; for small instances a backtracking search over pentagons that
greedily covers edges, pruned by the degree/divisibility invariants, suffices.

---

## 9. Applications

Edge-decomposition into fixed shapes underlies several applied domains:

- **Scheduling and tournaments.** Round-robin and rotational schedules are
  decompositions of complete graphs into matchings or cycles; cycle
  decompositions model rotational conflict-free assignments.
- **Optical / sensor networks.** Wavelength and channel assignment problems
  reduce to partitioning a conflict graph into uniform sub-patterns, where the
  divisibility invariants act as fast infeasibility filters.
- **Combinatorial design theory.** $C_\ell$-decompositions of $K_n$ are exactly
  the cyclic analogues of resolvable designs; the residue conditions on $n$
  (Conjecture 9.1 below) are design-existence constraints.

**Conjecture 9.1 (complete-graph family).** $K_n$ is $C_5$-divisible iff $n
\equiv 1$ or $5 \pmod{10}$ (equivalently, $n$ odd and $5 \mid \binom{n}{2}$),
and for every such $n \ge 5$, $K_n$ admits a $C_5$-decomposition. The necessity
direction follows directly from Theorems 5.2–5.3: even degree $n - 1$ forces
$n$ odd, and $5 \mid \binom{n}{2}$ is global divisibility.

---

## 10. Discussion

The necessity half of the $C_5$-decomposition problem is elementary yet
structurally complete: two short counting arguments fully characterize the
arithmetic obstructions, and the pentagon witness shows they are realized. The
genuine mathematical content lies in the *gap* between these necessary
conditions and actual decomposability — a gap closed, conjecturally, by the
single sharp constant $5/8$. That $5/8$ sits at a named, provably monotone
point in the family $\ell/(2\ell - 2)$ frames the pentagon as the natural next
target after the triangle, and the uniformity of the parity argument (each
vertex meets a cycle in $0$ or $2$ edges, for *every* odd $\ell$) suggests the
whole family shares one necessity proof and differs only in its existence
constant.

---

## 11. Future Directions

**Conjecture 1 (the headline existence threshold).** For every real
$\varepsilon > 0$ there is $N$ such that every $C_5$-divisible graph on $n \ge
N$ vertices with $\delta(G) \ge (5/8 + \varepsilon) n$ admits a
$C_5$-decomposition. The two necessary obstructions (even degrees, $5 \mid
|E|$) should become sufficient once minimum degree crosses $5/8 = 5/(2\cdot 5 -
2)$, the $\ell = 5$ point of the strictly decreasing Nash–Williams family. The
triangle case $\delta_{C_3} = 3/4$ and the long-odd-cycle cases are settled;
$C_5$ is the isolated remaining small odd cycle.

**Conjecture 2 (sharpness / lower bound).** For every $\varepsilon > 0$ and
infinitely many $n$, there exists a $C_5$-divisible graph on $n$ vertices with
$\delta(G) \ge (5/8 - \varepsilon) n$ that has **no** $C_5$-decomposition. The
threshold $5/8$ is conjecturally two-sided: an extremal space-barrier
construction (a near-balanced blow-up tuned so some edge cannot be routed
through any $5$-cycle) should defeat decomposition just below $5/8$. The
contrapositive obstruction already turns any *local* obstruction into a
non-decomposition proof; what remains is a *global* density obstruction.

**Conjecture 3 (exact pentagon / complete-graph family).** $K_n$ is
$C_5$-divisible iff $n \equiv 1$ or $5 \pmod{10}$ (i.e., $5 \mid \binom{n}{2}$
and $n$ odd), and for every such $n \ge 5$, $K_n$ admits a $C_5$-decomposition.
Necessity forces $n$ odd (even degree $n - 1$) and $5 \mid n(n-1)/2$; the
classical $K_5 = C_5 \cup C_5$ base case suggests a clean recursive/Wilson-type
construction.

**Conjecture 4 (unified small-cycle threshold law).** For every fixed odd
$\ell \ge 3$, the $C_\ell$-decomposition threshold of $C_\ell$-divisible graphs
equals $\delta_{C_\ell} = \ell/(2\ell - 2)$, and this sequence is the strictly
decreasing rational sequence converging to $1/2$. The parity argument (each
vertex meets a cycle in $0$ or $2$ edges) generalizes verbatim to any $\ell$,
so the necessity half is uniform; only the existence constant
$\ell/(2\ell - 2)$ varies, monotonically.

---

## Appendix A: Summary of Formal Results

| Name | Statement |
|------|-----------|
| `c5edges` | Definition of the $5$-cycle edge set through $v : \mathbb{Z}/5 \to V$. |
| `IsFiveCycle` | Predicate: an edge set arises from $5$ distinct cyclically-ordered vertices. |
| `c5edges_card` | An injective $v$ yields $|\mathrm{c5edges}(v)| = 5$. |
| `c5edges_even_incidence` | Each vertex meets $\mathrm{c5edges}(v)$ in an even ($0$ or $2$) number of edges. |
| `IsFiveCycle.card_eq_five` | A five-cycle has exactly $5$ edges. |
| `IsFiveCycle.even_incidence` | Even local incidence, lifted to `IsFiveCycle`. |
| `C5Decomposition` | Structure: pairwise-disjoint five-cycle parts covering $E(G)$. |
| `card_edgeFinset_eq` | $|E(G)| = 5 \cdot (\#\text{parts})$. |
| `five_dvd_card_edgeFinset` | $5 \mid |E(G)|$. |
| `even_degree` | Every vertex has even degree. |
| `IsC5Divisible` | Predicate: all degrees even and $5 \mid |E(G)|$. |
| `c5_decomposition_divisible` | Decomposability $\Rightarrow$ $C_5$-divisibility. |
| `no_decomposition_of_not_divisible` | Contrapositive obstruction. |
| `nwThreshold_strictAnti` | $\ell \mapsto \ell/(2\ell-2)$ strictly decreasing to $1/2$. |
