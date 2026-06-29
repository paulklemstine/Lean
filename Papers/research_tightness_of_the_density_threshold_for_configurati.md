# Exact Characterization of Tight Configurations in Linear $r$-Uniform Hypergraphs

**Author:** Aristotle
**Date:** 2026-06-28
**Domain:** Combinatorics / Extremal Set Theory (Novelty)

---

## Abstract

A hypergraph is *linear* (equivalently, a *partial Steiner system*) when any two
distinct edges share at most one vertex. For a linear $r$-uniform hypergraph on
$n$ vertices with $m$ edges, an elementary double count yields the *packing
bound* $m \binom{r}{2} \le \binom{n}{2}$, equivalently the density threshold
$m \le n(n-1)/\bigl(r(r-1)\bigr)$ with leading coefficient $1/(r(r-1))$. It is
classical that a Steiner system $S(2,r,n)$ attains equality, certifying that the
coefficient cannot be improved. In this paper we sharpen this one-sided
optimality into a complete characterization of the extremal configurations. We
prove that the packing bound is an equality **if and only if** the hypergraph
covers every pair of vertices, i.e. is a Steiner system (Theorem 1). We then
develop the local (per-vertex) analogue: each vertex satisfies
$\deg(v)(r-1) \le n-1$ (Theorem 2), with equality **if and only if** the edges
through $v$ cover every other vertex (Theorem 3). As a corollary, every covering
linear $r$-uniform hypergraph is degree-regular with
$\deg(v) = (n-1)/(r-1)$ for all $v$ (Theorem 4): tightness is global *and* local
simultaneously. We illustrate with the Fano plane $S(2,3,7)$, the minimal
simultaneously-tight witness, and discuss the relationship to the $e=2$ boundary
of the Brown–Erdős–Sós extremal function. All results have been formally
verified.

---

## 1. Introduction

### 1.1 Background and motivation

Let $V$ be a finite set of $n$ *vertices*. An **$r$-uniform hypergraph** on $V$
is a family $\mathcal{E}$ of $r$-element subsets of $V$, called *edges*; we write
$m = |\mathcal{E}|$ for the number of edges. The hypergraph is **linear** if
every two distinct edges intersect in at most one vertex. Linear hypergraphs
generalize simple graphs ($r = 2$) and coincide with *partial linear spaces* in
incidence geometry: vertices are points, edges are lines, and two lines meet in
at most one point.

Linearity is the cleanest density constraint in extremal hypergraph theory. It is
the $e = 2$ boundary of the Brown–Erdős–Sós (BES) programme, which studies the
maximum number of edges in an $r$-uniform hypergraph containing no $j$ edges
spanning at most $j(r-2) + 2$ vertices (or related "few vertices, many edges"
configurations). The case where the relevant overlap involves two vertices is
exactly the statement "no pair of vertices is covered twice," which is the
defining property of a linear hypergraph. Pinning down the extremal
configurations at this boundary is therefore a natural anchor for the broader
sparse-hypergraph literature, including the work of Keevash–Long on sparse
linear hypergraphs.

The fundamental quantitative fact about linear hypergraphs is the **packing
bound**: since the edges are pairwise "pair-disjoint," the total number of pairs
they cover cannot exceed the total number of pairs available, giving

$$m \binom{r}{2} \le \binom{n}{2}. \tag{1}$$

It is well known that a **Steiner system** $S(2,r,n)$ — a linear $r$-uniform
hypergraph in which every pair of vertices is covered (necessarily exactly once)
— attains equality in (1). This certifies that the density coefficient
$1/(r(r-1))$ is optimal whenever a Steiner system exists.

### 1.2 Contribution

The classical statement gives only one direction of optimality: an extremal
configuration *exists* (the Steiner system). It does not say that Steiner systems
are the *only* extremal configurations. This paper closes that gap.

Our contributions are:

1. **Global tightness characterization (Theorem 1).** Equality in (1) holds *if
   and only if* the hypergraph covers every pair, i.e. is a Steiner system. This
   upgrades the classical "Steiner $\Rightarrow$ equality" to a biconditional,
   completely characterizing the extremal family.

2. **Local packing bound (Theorem 2).** A per-vertex refinement:
   $\deg(v)(r-1) \le n-1$ for every vertex $v$.

3. **Local tightness characterization (Theorem 3).** Equality
   $\deg(v)(r-1) = n-1$ holds *if and only if* the edges through $v$ cover every
   other vertex (the *link* of $v$ is covering).

4. **Simultaneous global/local rigidity (Theorem 4).** Every covering (Steiner)
   linear $r$-uniform hypergraph is degree-regular with
   $\deg(v) = (n-1)/(r-1)$ for all $v$. Hence tightness is global *and* local at
   the same time: Steiner systems are exactly the configurations that are tight
   everywhere.

The proofs rest on a single reusable principle — *a disjoint family of subsets
fills its ambient set if and only if its total cardinality equals that of the
ambient set* — applied once globally (to pairs) and once locally (to the link of
a vertex). No geometry beyond linearity is required; the characterizations are
pure double-counting equalities.

---

## 2. Definitions

Throughout, $V$ is a finite set with $|V| = n$, and edges are finite subsets of
$V$. We write $\mathcal{P}_2(S) = \binom{S}{2}$ for the family of $2$-element
subsets of a set $S$, so $|\mathcal{P}_2(S)| = \binom{|S|}{2}$.

**Definition 2.1 (Uniformity).** A family $\mathcal{E}$ of edges is
**$r$-uniform** if $|e| = r$ for every $e \in \mathcal{E}$.

**Definition 2.2 (Linearity).** A family $\mathcal{E}$ is **linear** if for all
distinct $e_1, e_2 \in \mathcal{E}$ we have $|e_1 \cap e_2| \le 1$.

**Definition 2.3 (Covering).** A family $\mathcal{E}$ **covers** all pairs if for
every $p \in \mathcal{P}_2(V)$ there exists $e \in \mathcal{E}$ with
$p \subseteq e$.

**Definition 2.4 (Steiner system).** A **Steiner system** $S(2,r,n)$ is an
$r$-uniform linear family on $n$ vertices that covers all pairs. (In a linear
covering family every pair is covered *exactly* once, since two edges covering a
common pair would intersect in $\ge 2$ vertices.)

**Definition 2.5 (Degree).** The **degree** of a vertex $v$ is the number of
edges through it:

$$\deg(v) = \bigl|\{\, e \in \mathcal{E} : v \in e \,\}\bigr|.$$

The family $\{\, e \in \mathcal{E} : v \in e \,\}$ is called the **link** of $v$.

---

## 3. The pair-disjointness engine

The proofs of the global results flow from one structural lemma turning the
geometric hypothesis (linearity) into a combinatorial one (disjointness of
pair-bundles), together with a counting identity.

For an edge $e$, let $\mathcal{P}_2(e)$ denote the family of its $2$-element
subsets. For an $r$-edge, $|\mathcal{P}_2(e)| = \binom{r}{2}$.

**Lemma 3.1 (Pair-disjointness).** *If $\mathcal{E}$ is linear, then the families
$\{\mathcal{P}_2(e)\}_{e \in \mathcal{E}}$ are pairwise disjoint: for distinct
$e, f \in \mathcal{E}$, $\mathcal{P}_2(e) \cap \mathcal{P}_2(f) = \varnothing$.*

*Proof sketch.* Suppose a common pair $p$ lay in both $\mathcal{P}_2(e)$ and
$\mathcal{P}_2(f)$. Then $p \subseteq e$ and $p \subseteq f$, so
$p \subseteq e \cap f$, whence $|e \cap f| \ge |p| = 2$. This contradicts
linearity, which gives $|e \cap f| \le 1$ for $e \ne f$. $\qquad\blacksquare$

*(In the formal development this is `pairs_disjoint`, stated as a
`PairwiseDisjoint` property of $e \mapsto \mathcal{P}_2(e)$.)*

**Lemma 3.2 (Containment of covered pairs).** *For any family $\mathcal{E}$,*

$$\bigcup_{e \in \mathcal{E}} \mathcal{P}_2(e) \subseteq \mathcal{P}_2(V).$$

*Proof sketch.* Every $2$-subset of an edge $e \subseteq V$ is in particular a
$2$-subset of $V$. $\qquad\blacksquare$ *(Formally `biUnion_pairs_subset`.)*

**Lemma 3.3 (Pair count).** *If $\mathcal{E}$ is $r$-uniform and linear, then*

$$\Bigl|\bigcup_{e \in \mathcal{E}} \mathcal{P}_2(e)\Bigr| = m \binom{r}{2}.$$

*Proof sketch.* By Lemma 3.1 the union is disjoint, so its cardinality equals
$\sum_{e \in \mathcal{E}} |\mathcal{P}_2(e)|$. By $r$-uniformity each summand
equals $\binom{r}{2}$, giving $m\binom{r}{2}$. $\qquad\blacksquare$ *(Formally
`card_biUnion_pairs`, using `Finset.card_biUnion` and
`Finset.card_powersetCard`.)*

Lemmas 3.2 and 3.3 immediately reprove the packing bound (1): the left side of
Lemma 3.3 equals $m\binom{r}{2}$ and, being a subset of $\mathcal{P}_2(V)$ by
Lemma 3.2, has cardinality at most $\binom{n}{2}$.

---

## 4. Global tightness characterization

**Theorem 1 (Global tightness; `linear_card_eq_iff_covers`).** *Let
$\mathcal{E}$ be an $r$-uniform linear hypergraph on $V$, $|V| = n$, with $m$
edges. Then*

$$m \binom{r}{2} = \binom{n}{2} \iff \mathcal{E} \text{ covers every pair of }V,$$

*i.e. equality in the packing bound holds exactly when $\mathcal{E}$ is a Steiner
system $S(2,r,n)$.*

*Proof sketch.* Write $U = \bigcup_{e \in \mathcal{E}} \mathcal{P}_2(e)$. By
Lemma 3.3, $|U| = m\binom{r}{2}$, and by Lemma 3.2, $U \subseteq \mathcal{P}_2(V)$
with $|\mathcal{P}_2(V)| = \binom{n}{2}$.

The crux is the set-theoretic equivalence

$$m\binom{r}{2} = \binom{n}{2} \;\iff\; U = \mathcal{P}_2(V). \tag{2}$$

For ($\Leftarrow$) take cardinalities. For ($\Rightarrow$), $U \subseteq
\mathcal{P}_2(V)$ is a subset whose cardinality equals that of the ambient set;
a finite subset with cardinality equal to its superset must be the whole set
(`Finset.eq_of_subset_of_card_le`). This is the load-bearing step: it is exactly
the statement that *a disjoint family fills its container iff the sizes match.*

It remains to decode $U = \mathcal{P}_2(V)$ as full pair coverage. Indeed
$U = \mathcal{P}_2(V)$ means every pair $p \in \mathcal{P}_2(V)$ lies in some
$\mathcal{P}_2(e)$, i.e. $p \subseteq e$ for some edge $e$ — precisely
Definition 2.3 (covering). The reverse decoding is identical. Combining with (2)
yields the biconditional. $\qquad\blacksquare$

**Remark 4.1.** The ($\Leftarrow$) direction recovers the classical
"Steiner $\Rightarrow$ equality" (the previously known `steiner_card_eq`). The
($\Rightarrow$) direction is the new content: *no* linear $r$-uniform hypergraph
can attain the packing bound without being a Steiner system. The extremal family
is characterized completely, not merely shown to be nonempty.

---

## 5. Local (link) bound and its tightness

We now run the same engine vertex-locally. Fix a vertex $v$ and consider its
link $L_v = \{\, e \in \mathcal{E} : v \in e \,\}$, so $|L_v| = \deg(v)$. For
$e \in L_v$, the *erased edge* $e \setminus \{v\}$ is an $(r-1)$-subset of
$V \setminus \{v\}$.

**Lemma 5.1 (Erased-edge disjointness).** *If $\mathcal{E}$ is linear, then for
distinct $e, f \in L_v$ the sets $e \setminus \{v\}$ and $f \setminus \{v\}$ are
disjoint.*

*Proof sketch.* If $u \in (e \setminus \{v\}) \cap (f \setminus \{v\})$ then
$u, v \in e \cap f$ with $u \ne v$, so $|e \cap f| \ge 2$, contradicting
linearity. $\qquad\blacksquare$

**Theorem 2 (Local packing bound; `degree_mul_le`).** *For an $r$-uniform linear
hypergraph and every vertex $v$,*

$$\deg(v)\,(r-1) \le n - 1.$$

*Proof sketch.* The erased edges $\{e \setminus \{v\}\}_{e \in L_v}$ are pairwise
disjoint (Lemma 5.1), each of size $r-1$ (by $r$-uniformity, since $v \in e$),
and all contained in $V \setminus \{v\}$, a set of size $n-1$. Summing the sizes
of a disjoint subfamily,

$$\deg(v)\,(r-1) = \sum_{e \in L_v} |e \setminus \{v\}| =
\Bigl|\bigcup_{e \in L_v} (e \setminus \{v\})\Bigr| \le |V \setminus \{v\}| = n-1.$$

$\blacksquare$ *(The bound holds for every vertex including isolated ones, where
$\deg(v) = 0$ and the inequality reads $0 \le n-1$.)*

**Theorem 3 (Local tightness; `degree_eq_iff_link_covers`).** *For an
$r$-uniform linear hypergraph and a vertex $v$,*

$$\deg(v)\,(r-1) = n-1 \iff \text{the edges through } v \text{ cover every } u \ne v,$$

*i.e. for every $u \in V \setminus \{v\}$ there is an edge $e \ni v$ with
$u \in e$.*

*Proof sketch.* By Lemma 5.1 the erased edges form a disjoint family inside
$V \setminus \{v\}$ whose total size is $\deg(v)(r-1)$. Equality with $n-1$ holds
iff this disjoint family *fills* $V \setminus \{v\}$, i.e.
$\bigcup_{e \in L_v} (e \setminus \{v\}) = V \setminus \{v\}$ — again the
"disjoint family fills iff sizes match" principle (`Finset.eq_of_subset_of_card_le`).
Filling $V \setminus \{v\}$ means every $u \ne v$ lies in some erased edge, i.e.
in some edge through $v$, which is exactly the covering of the link.
$\qquad\blacksquare$

---

## 6. Simultaneous global/local rigidity

**Theorem 4 (Regularity of covering hypergraphs; `covering_is_regular`).** *Let
$\mathcal{E}$ be a covering (Steiner) $r$-uniform linear hypergraph on $n$
vertices, with $r \ge 2$. Then every vertex $v$ satisfies the local equality*

$$\deg(v)\,(r-1) = n-1,$$

*and hence every vertex has the same degree $\deg(v) = (n-1)/(r-1)$.*

*Proof sketch.* Since $\mathcal{E}$ covers every pair (Theorem 1's
right-hand condition), in particular for each $u \ne v$ the pair $\{u,v\}$ is
covered by some edge $e$, which then contains $v$; thus the link of $v$ covers
every $u \ne v$. By Theorem 3 (the $\Leftarrow$ direction) this forces
$\deg(v)(r-1) = n-1$. As the right side $n-1$ is independent of $v$, all degrees
coincide: $\deg(v) = (n-1)/(r-1)$ for every $v$. $\qquad\blacksquare$

**Corollary 6.1 (Degrees-first edge count; `covering_edge_count`,
`sum_degree_eq`, `sum_degree_uniform`).** *Counting incidences two ways gives*

$$\sum_{v \in V} \deg(v) = m \cdot r \qquad(\text{each edge counted once per member}),$$

*and combining with Theorem 4's uniform degree $\deg(v) = (n-1)/(r-1)$ over $n$
vertices,*

$$m \cdot r \cdot (r-1) = n \cdot (n-1).$$

This is the packing equality $m\binom{r}{2} = \binom{n}{2}$ rewritten, so the
global count and the local counts are mutually derivable. Tightness, in a Steiner
system, is therefore both global and local — and uniformly so across all
vertices.

---

## 7. Worked example: the Fano plane $S(2,3,7)$

The smallest nontrivial Steiner system is the **Fano plane** $S(2,3,7)$, with
$n = 7$, $r = 3$, and $m = 7$. On vertices $\{1,\dots,7\}$ a standard block set is

$$\{1,2,3\},\ \{1,4,5\},\ \{1,6,7\},\ \{2,4,6\},\ \{2,5,7\},\ \{3,4,7\},\ \{3,5,6\}.$$

**Global tightness (Theorem 1).** Each block contributes $\binom{3}{2} = 3$
pairs, and the blocks are pair-disjoint, so they cover $7 \cdot 3 = 21$ pairs.
Since $\binom{7}{2} = 21$, every pair is covered exactly once and

$$m\binom{r}{2} = 7 \cdot 3 = 21 = \binom{7}{2}. \checkmark$$

**Local tightness (Theorem 3).** Each point lies on exactly $3$ blocks; each such
block introduces $r - 1 = 2$ new neighbors, reaching $3 \cdot 2 = 6$ vertices —
all $6$ others. Thus

$$\deg(v)(r-1) = 3 \cdot 2 = 6 = 7 - 1 = n - 1. \checkmark$$

**Regularity (Theorem 4).** Every vertex has degree exactly
$(n-1)/(r-1) = 6/2 = 3$. The Fano plane is the minimal configuration that is
tight globally *and* locally, simultaneously and uniformly.

---

## 8. Algorithms

The theory yields directly executable certifications. We summarize the two
central procedures (full Python with type hints accompanies this paper).

**Algorithm A — Linearity and packing-tightness certifier.**
Given $V$, $r$, and an edge family $\mathcal{E}$, verify $r$-uniformity and
linearity (all pairwise intersections $\le 1$), accumulate the set of covered
pairs as a disjoint union, and report whether $m\binom{r}{2} = \binom{n}{2}$.
By Theorem 1 the equality holds iff every pair is covered, which the routine also
checks directly as a cross-validation. Complexity: $O(m^2 r)$ for the pairwise
linearity test and $O(m r^2)$ for pair accumulation.

**Algorithm B — Link/degree-tightness certifier.**
For each vertex $v$, collect its link, erase $v$ from each incident edge, verify
disjointness, and test $\deg(v)(r-1) = n-1$ against full coverage of
$V \setminus \{v\}$ (Theorem 3). Aggregating over all vertices certifies the
regularity statement of Theorem 4. Complexity: $O(n + mr)$ to build links plus
$O\bigl(\sum_v \deg(v)^2\bigr)$ for the per-link disjointness checks.

---

## 9. Discussion and applications

**Relation to Brown–Erdős–Sós.** Linearity is the "$e = 2$" boundary of the BES
extremal function — "every pair covered at most once." Theorem 1 isolates this
boundary completely by characterizing which hypergraphs saturate it. The exact
extremal description is a clean fixed point against which the harder interior
cases ($e \ge 3$, configurations spanning more vertices) can be calibrated.

**Design theory and coding.** Steiner systems are the backbone of combinatorial
design theory; their perfect balance (Theorem 4) is precisely what makes them
useful for balanced statistical experiments and for constructing strong
error-correcting codes. The rigidity proven here explains *why* extremal density
and perfect regularity always coincide for these objects: both are equivalent
reformulations of the single condition "every pair covered exactly once."

**Methodological note.** Every result is a corollary of one principle — a
disjoint family fills its ambient set iff their cardinalities agree — instantiated
globally on the set of all pairs and locally on the link of a vertex. The
economy of the argument is itself a result: no algebraic or geometric machinery
beyond linearity is needed.

---

## 10. Future directions

The following conjectures are precise, falsifiable, and build directly on the
results above.

**Conjecture 1 (Near-extremal stability).** If a linear $r$-uniform hypergraph
satisfies $m\binom{r}{2} \ge \binom{n}{2} - t$, then the number of *uncovered*
pairs is exactly $\binom{n}{2} - m\binom{r}{2} \le t$; stronger, at most
$2t/(r-1)$ vertices fail the local equality $\deg(v)(r-1) = n-1$. The pair-count
identity follows now from Lemma 3.3 and Lemma 3.2 via a cardinality-of-difference
computation; the vertex-deficiency count follows by summing local deficiencies.

**Conjecture 2 (Resolvability raises the floor).** A *partial parallel class* is
a set of pairwise-disjoint edges. Conjecture: every partial parallel class has
size $\le \lfloor n/r \rfloor$, with equality (a perfect matching) iff its edges
partition $V$. This is the matching analogue of Theorem 2.

**Conjecture 3 (Fisher-type lower bound).** For a Steiner system $S(2,r,n)$ with
$r < n$, the number of edges satisfies $m \ge n$ (Fisher's inequality);
equivalently the incidence structure has full point-rank. In stages: derive
$m = n(n-1)/(r(r-1))$ over $\mathbb{Q}$ from Corollary 6.1, then prove
$n(n-1)/(r(r-1)) \ge n \iff n \ge 2r-1$, isolating the linear-algebraic residue.

**Conjecture 4 (Codegree threshold).** Define the codegree
$\deg(u,v) = |\{e : u,v \in e\}|$; linearity is exactly $\deg(u,v) \le 1$ for
$u \ne v$. Conjecture: $\sum_{u<v}\deg(u,v) = m\binom{r}{2}$ holds with *no*
linearity hypothesis, and linearity is equivalent to
$\sum \deg = \#\{\text{covered pairs}\}$. This removes linearity from Lemma 3.3
by replacing the disjoint union with a multiset count.

**Conjecture 5 (Linear Turán-type density).** Extend the threshold to forbidden
configurations spanning more than two vertices, calibrating the interior of the
Brown–Erdős–Sós landscape against the exact $e=2$ boundary established here.

---

## 11. Conclusion

We have given a complete characterization of the extremal configurations for the
density threshold of linear $r$-uniform hypergraphs. The packing bound
$m\binom{r}{2} \le \binom{n}{2}$ is an equality precisely for Steiner systems
(Theorem 1); the local bound $\deg(v)(r-1) \le n-1$ is an equality precisely when
the link of $v$ is covering (Theorem 3); and covering hypergraphs are exactly
those that are tight everywhere, globally and locally, with perfect degree
regularity (Theorem 4). The entire theory rests on a single counting principle,
applied globally and locally, with the Fano plane $S(2,3,7)$ as its minimal
simultaneously-tight witness. All results have been formally verified.
