# The Sharp Density Threshold for Linear $r$-Uniform Hypergraphs

**Author:** Aristotle

**Date:** 2026-06-27

**Domain:** Extremal Combinatorics / Novelty

---

## Abstract

A hypergraph is *linear* (equivalently, a *partial Steiner system*) when any two
of its edges meet in at most one vertex. Linearity is the structural hypothesis
underlying the Brown–Erdős–Sós (BES) program and recent work on sparse linear
hypergraphs. We establish the sharp density threshold for linear $r$-uniform
hypergraphs: on $n$ vertices, such a hypergraph has at most
$\binom{n}{2}/\binom{r}{2}$ edges, equivalently $m \cdot \binom{r}{2} \le
\binom{n}{2}$ where $m$ is the number of edges. Over the reals this reads
$m \le \frac{n(n-1)}{r(r-1)}$, with leading coefficient $\frac{1}{r(r-1)}$. We
further prove that this coefficient is *optimal*: a Steiner system $S(2,r,n)$ —
a linear $r$-uniform hypergraph covering every pair of vertices exactly once —
attains equality, $m \cdot \binom{r}{2} = \binom{n}{2}$. The proof rests on a
single structural observation, that the families of $2$-subsets induced by the
edges of a linear hypergraph are pairwise disjoint, which converts the geometric
linearity constraint into a clean double count of vertex pairs. All results have
been formally verified.

---

## 1. Introduction

### 1.1 Motivation

Extremal set theory asks how large a combinatorial structure may be before it is
forced to contain a prescribed configuration. Among the most influential strands
of this subject is the **Brown–Erdős–Sós (BES) program**, which studies the
maximum number of edges in an $r$-uniform hypergraph avoiding small, dense
sub-configurations. A recurring and decisive hypothesis throughout the program
is **linearity**: the requirement that any two edges share at most one vertex.

Linearity is equivalent to the statement that *no pair of vertices is covered by
two distinct edges*. This is exactly the $e = 2$ boundary case of the general BES
extremal function, and it is the structural condition that powers the
Keevash–Long (2023) analysis of sparse linear hypergraphs. Understanding the
maximum density of a linear hypergraph is therefore both a natural question in
its own right and a cornerstone of the broader theory.

### 1.2 Results

Let $V$ be a finite vertex set with $|V| = n$, and let $H$ be an $r$-uniform
linear hypergraph on $V$ with edge set of size $m$. We prove:

- **(Upper bound, `linear_card_le`)** $\quad m \cdot \binom{r}{2} \le
  \binom{n}{2}.$
- **(Real density form, `linear_density_real`)** For $r \ge 2$, $\quad m \le
  \dfrac{n(n-1)}{r(r-1)}.$
- **(Optimality, `steiner_card_eq`)** If $H$ is a Steiner system $S(2,r,n)$, then
  $\quad m \cdot \binom{r}{2} = \binom{n}{2}.$

The upper bound and the optimality statement share the identical factor
$\binom{r}{2}$, which is precisely why the leading coefficient $\frac{1}{r(r-1)}$
in the density form cannot be improved.

### 1.3 Method

The entire argument turns on one structural lemma. Map each edge $e$ to the
family $\binom{e}{2}$ of its $2$-element subsets. Linearity forces these families
to be **pairwise disjoint** (`pairs_disjoint`): if two edges shared a common
$2$-subset, they would meet in at least two vertices, violating linearity. Their
union is contained in the family $\binom{V}{2}$ of all vertex pairs
(`biUnion_pairs_subset`). A disjoint-union cardinality count then yields the
upper bound, while in the Steiner case the union *equals* $\binom{V}{2}$,
upgrading the inequality to an equality.

---

## 2. Definitions

Throughout, $V$ is a finite type with decidable equality, and a hypergraph is
modeled by its edge set, a finite family $E \subseteq \mathcal{P}(V)$ of finite
subsets of $V$. We write $\binom{S}{2}$ for the family of $2$-element subsets of
a set $S$ (in the formalization, `Finset.powersetCard 2 S`), and $\binom{k}{2}$
for the binomial coefficient.

**Definition 2.1 ($r$-uniform, `IsUniform`).** An edge family $E$ is
*$r$-uniform* if every edge has exactly $r$ vertices:
$$ \mathrm{IsUniform}(E, r) \iff \forall e \in E,\ |e| = r. $$

**Definition 2.2 (linear, `IsLinear`).** An edge family $E$ is *linear* if any
two distinct edges meet in at most one vertex:
$$ \mathrm{IsLinear}(E) \iff \forall e_1, e_2 \in E,\ e_1 \ne e_2 \implies
|e_1 \cap e_2| \le 1. $$

**Definition 2.3 (Steiner system, `IsSteiner`).** An edge family $E$ is a
*Steiner system* $S(2,r,n)$ if it is $r$-uniform, linear, and covers every pair
of vertices:
$$ \mathrm{IsSteiner}(E, r) \iff \mathrm{IsUniform}(E,r) \wedge
\mathrm{IsLinear}(E) \wedge \Big(\forall p \in \tbinom{V}{2},\ \exists e \in E,\
p \subseteq e\Big). $$

Note that linearity together with full pair coverage forces *exactly-once*
coverage: a pair contained in two edges would make those edges share two
vertices.

---

## 3. The Structural Lemma: Disjoint Pair Families

The whole development is anchored by a single combinatorial observation.

**Lemma 3.1 (Pairwise disjoint pair families, `pairs_disjoint`).** If $E$ is
linear, then the families $\{\binom{e}{2} : e \in E\}$ are pairwise disjoint as
subsets of $\binom{V}{2}$. Formally, $(E)$ is pairwise disjoint under the map
$e \mapsto \binom{e}{2}$.

*Proof sketch.* Suppose two distinct edges $e, f \in E$ had a common element in
their pair families, i.e. some $p$ with $p \in \binom{e}{2}$ and $p \in
\binom{f}{2}$. Then $p \subseteq e$ and $p \subseteq f$ with $|p| = 2$, so
$p \subseteq e \cap f$ and hence $|e \cap f| \ge |p| = 2$. This contradicts
linearity, which gives $|e \cap f| \le 1$. Therefore the pair families are
disjoint. $\qquad\blacksquare$

**Lemma 3.2 (Union sits inside all pairs, `biUnion_pairs_subset`).** For any
edge family $E$,
$$ \bigcup_{e \in E} \binom{e}{2} \subseteq \binom{V}{2}. $$

*Proof sketch.* Any $p \in \binom{e}{2}$ is a $2$-element subset of $e \subseteq
V$, hence a $2$-element subset of $V$, i.e. $p \in \binom{V}{2}$. $\qquad
\blacksquare$

These two facts are the only structural inputs; everything below is arithmetic.

---

## 4. The Density Threshold

**Theorem 4.1 (Upper bound, `linear_card_le`).** Let $E$ be an $r$-uniform
linear hypergraph on a finite vertex set $V$ with $|V| = n$ and $|E| = m$. Then
$$ m \cdot \binom{r}{2} \le \binom{n}{2}. $$

*Proof sketch.* We count the total number of induced vertex pairs in two ways.

1. **Per-edge count.** Each edge $e$ has $|e| = r$ vertices, so it induces
   $\big|\binom{e}{2}\big| = \binom{r}{2}$ pairs. Summing over all $m$ edges,
   $$ \sum_{e \in E} \Big|\tbinom{e}{2}\Big| = \sum_{e \in E} \binom{r}{2} =
   m \cdot \binom{r}{2}. $$
2. **Disjointness collapses the sum to a union.** By Lemma 3.1 the pair families
   are pairwise disjoint, so the cardinality of their union equals the sum of
   their cardinalities (`Finset.card_biUnion`):
   $$ \Big|\bigcup_{e \in E} \tbinom{e}{2}\Big| = \sum_{e \in E}
   \Big|\tbinom{e}{2}\Big| = m \cdot \binom{r}{2}. $$
3. **Containment caps the union.** By Lemma 3.2 the union is a subset of
   $\binom{V}{2}$, whose size is $\binom{n}{2}$ (`Finset.card_powersetCard`):
   $$ \Big|\bigcup_{e \in E} \tbinom{e}{2}\Big| \le \Big|\tbinom{V}{2}\Big| =
   \binom{n}{2}. $$

Chaining (1)–(3) gives $m \cdot \binom{r}{2} \le \binom{n}{2}$. $\qquad
\blacksquare$

**Theorem 4.2 (Real density form, `linear_density_real`).** Under the hypotheses
of Theorem 4.1, if additionally $r \ge 2$, then over $\mathbb{R}$
$$ m \le \frac{n(n-1)}{r(r-1)}. $$

*Proof sketch.* Multiply the integer inequality of Theorem 4.1 by $2$ and use
$2\binom{k}{2} = k(k-1)$ to obtain $m \cdot r(r-1) \le n(n-1)$ in $\mathbb{N}$.
Cast to $\mathbb{R}$ and divide by $r(r-1) > 0$ (which holds since $r \ge 2$),
yielding $m \le \frac{n(n-1)}{r(r-1)}$. The division is justified by positivity
of the denominator; the integer-to-real cast preserves the inequality.
$\qquad\blacksquare$

The leading coefficient is $\frac{1}{r(r-1)}$, governing the $n^2$ growth rate of
the maximum edge count.

---

## 5. Optimality via Steiner Systems

The upper bound is tight: it is attained exactly by Steiner systems.

**Theorem 5.1 (Steiner equality, `steiner_card_eq`).** If $E$ is a Steiner
system $S(2,r,n)$, then
$$ m \cdot \binom{r}{2} = \binom{n}{2}. $$

*Proof sketch.* We strengthen the containment of Lemma 3.2 to an equality. By the
covering axiom of Definition 2.3, every $p \in \binom{V}{2}$ lies in some edge
$e \in E$, hence $p \in \binom{e}{2} \subseteq \bigcup_{e \in E} \binom{e}{2}$.
Combined with Lemma 3.2 this gives
$$ \bigcup_{e \in E} \binom{e}{2} = \binom{V}{2}. $$
Taking cardinalities and using disjointness (Lemma 3.1, applicable because a
Steiner system is linear) exactly as in Theorem 4.1,
$$ m \cdot \binom{r}{2} = \sum_{e \in E} \Big|\tbinom{e}{2}\Big| =
\Big|\bigcup_{e \in E} \tbinom{e}{2}\Big| = \Big|\tbinom{V}{2}\Big| =
\binom{n}{2}. $$
$\qquad\blacksquare$

**Corollary 5.2 (Sharpness of the coefficient).** The constant $\frac{1}{r(r-1)}$
in Theorem 4.2 cannot be lowered. Whenever a Steiner system $S(2,r,n)$ exists,
Theorem 5.1 furnishes a linear $r$-uniform hypergraph with exactly
$m = \binom{n}{2}/\binom{r}{2} = \frac{n(n-1)}{r(r-1)}$ edges, meeting the bound
of Theorem 4.2 with equality. Thus no constant $c < \frac{1}{r(r-1)}$ can serve
as a universal upper bound on $m/n^2$ in the limit.

By Keevash's existence theorem (2014), Steiner systems $S(2,r,n)$ exist for all
sufficiently large $n$ satisfying the divisibility conditions $r-1 \mid n-1$ and
$r(r-1) \mid n(n-1)$, so optimality is witnessed along an infinite family of
admissible $n$ for every fixed $r$.

---

## 6. Worked Example: The Fano Plane

The Fano plane is the Steiner system $S(2,3,7)$: $7$ points, $7$ lines (edges),
each line a $3$-element set, with every pair of points on exactly one line. With
$n = 7$, $r = 3$, $m = 7$:
$$ m \cdot \binom{r}{2} = 7 \cdot 3 = 21 = \binom{7}{2} = \binom{n}{2}, $$
confirming Theorem 5.1. The real density form gives $m \le \frac{7 \cdot
6}{3 \cdot 2} = 7$, attained exactly. One explicit realization on
$\{0,1,\dots,6\}$ is
$$ \{0,1,3\},\ \{1,2,4\},\ \{2,3,5\},\ \{3,4,6\},\ \{4,5,0\},\ \{5,6,1\},\
\{6,0,2\}, $$
the cyclic translates of $\{0,1,3\}$ modulo $7$; one checks each of the $21$
pairs appears exactly once.

---

## 7. Algorithms

### 7.1 Linearity verification

To certify that a given edge family is linear, it suffices to test all
$\binom{m}{2}$ pairs of edges for intersection size $\le 1$. This is the direct
computational counterpart of Definition 2.2 and runs in $O(m^2 \cdot r)$ time.

### 7.2 Threshold checking

Given $n$, $r$, and a claimed edge count $m$, the bound $m \cdot \binom{r}{2} \le
\binom{n}{2}$ is verified in $O(1)$ arithmetic, and equality detection certifies
that the family is a Steiner system *candidate* (a necessary condition).

### 7.3 Steiner witness search

For small admissible parameters, a backtracking / cyclic-difference-set search
constructs Steiner systems explicitly (e.g. the Fano plane as cyclic translates
of a perfect difference set modulo $7$), providing concrete optimality
witnesses.

These are detailed with full pseudocode and reference implementations in the
accompanying package.

---

## 8. Applications

- **Combinatorial design theory.** The threshold is the capacity limit for
  packing $r$-subsets so that no pair repeats — exactly the partial-Steiner /
  resolvable-design setting used in experimental design and scheduling.
- **Coding theory.** Linear hypergraphs correspond to codes with prescribed
  intersection patterns; the density bound limits code size and the Steiner case
  yields perfect-packing constructions.
- **The Brown–Erdős–Sós program.** The result is the exact $e = 2$ boundary case
  of the general BES extremal function and the anchor for the conjectural
  vanishing-density thresholds in the linear regime.
- **Sparse / high-girth hypergraphs.** The coefficient $\frac{1}{r(r-1)}$ is the
  density regime isolated in Keevash–Long-type analyses of sparse linear
  hypergraphs.

---

## 9. Discussion

The strength of the argument is its economy: a single structural lemma
(`pairs_disjoint`) reduces a geometric constraint to a double count, and the same
count, run with containment replaced by equality, certifies optimality. This
"count the induced pairs" technique is the linear-hypergraph specialization of
the inclusion-exclusion double counts pervasive in design theory, and it
generalizes: counting induced $s$-subsets governs $s$-linear (partial Steiner
$S(s+1, r, n)$) packings via the analogous $\binom{r}{s+1}$ factor.

Two points deserve emphasis. First, the bound is non-vacuous for *every* uniform
linear hypergraph, including the empty one (where it reads $0 \le \binom{n}{2}$).
Second, the optimality claim is genuine equality, conditioned on the defining
property of a Steiner system, and not a one-sided artifact: the identical factor
$\binom{r}{2}$ on both sides is what makes the threshold sharp.

---

## 10. Future Directions

- **The greedy span bound at the BES threshold ($k=3$).** Characterize when the
  greedy span minimum $3r-3$ is achieved simultaneously by three edges; this is
  conjectured to be equivalent to the BES no-configuration hypothesis at $k=3$,
  collapsing the BES inequality to the equality case of the span bound.
- **Tightness along Steiner densities for $s$-linear packings.** Show that the
  $s$-linear packing bound $|E| \le \binom{n}{s+1}/\binom{r}{s+1}$ is attained
  asymptotically by Steiner systems $S(s+1, r, n)$, turning the one-sided bound
  into a $\Theta$.
- **A vanishing-density dichotomy for $k \ge 4$.** Establish $|E| = o(n^2)$ at the
  threshold $(r-2)k+3$ for $k \ge 4$, and show that lowering the threshold to
  $(r-2)k+2$ admits $\Theta(n^2)$-edge families, pinpointing where the conjecture
  has content.
- **A removal-lemma reformulation.** Recast the linear BES conjecture as a
  hypergraph removal statement: every linear $r$-uniform hypergraph with $\ge
  \varepsilon n^2$ edges contains $k$ edges spanning $\le (r-2)k+3$ vertices.

---

## 11. Conclusion

For linear $r$-uniform hypergraphs on $n$ vertices, the maximum number of edges
is sharply bounded by $m \le \frac{n(n-1)}{r(r-1)}$, with the leading coefficient
$\frac{1}{r(r-1)}$ provably optimal: Steiner systems $S(2,r,n)$ attain it with
equality. The proof reduces, via the disjointness of induced pair families, to a
two-line double count, and both the bound and its matching construction have been
formally verified. This sharp threshold is the firm $e = 2$ foundation of the
broader Brown–Erdős–Sós program.

---

## References

- W. G. Brown, P. Erdős, V. T. Sós, *Some extremal problems on $r$-graphs* (1973).
- P. Keevash, *The existence of designs* (2014).
- P. Keevash, J. Long, work on sparse linear hypergraphs (2023).
- J. Steiner, *Combinatorische Aufgabe* (1853).
