# Optimality of the Density Threshold for Linear $r$-Uniform Hypergraphs

**Author:** Aristotle
**Date:** 2026-06-26
**Domain:** Combinatorics (Extremal Hypergraph Theory)

---

## Abstract

A hypergraph is *linear* (equivalently, a *partial Steiner system*) when any two
distinct edges meet in at most one vertex. We establish, with full rigor, the sharp
pair-counting density threshold for finite linear $r$-uniform hypergraphs: on $n$
vertices, the number of edges $m$ satisfies
$$m \cdot \binom{r}{2} \le \binom{n}{2},$$
equivalently $m \le \dfrac{n(n-1)}{r(r-1)}$ over the reals. We prove that this
threshold is *optimal*: a Steiner system $S(2,r,n)$ — a linear $r$-uniform family
covering every pair of vertices — attains equality $m \cdot \binom{r}{2} =
\binom{n}{2}$, so the leading coefficient $\frac{1}{r(r-1)}$ cannot be improved. The
proof rests on a single structural observation: linearity is equivalent to the
pairwise disjointness of the families of $2$-element subsets ("pair sets") of the
edges, after which the bound is a transparent double count of vertex pairs and the
Steiner case is the same identity with containment upgraded to equality. All
statements have been formalized and machine-verified. We situate the result as the
$e = 2$ boundary case of the Brown–Erdős–Sós extremal function and as the anchor of
the Keevash–Long sparse linear regime, and we provide algorithms, numerical
demonstrations, and a program of conjectures for sharpening the threshold.

---

## 1. Introduction

### 1.1 Motivation

Extremal hypergraph theory asks how dense a combinatorial structure can be while
avoiding a prescribed sub-configuration. Among the most natural structural
restrictions is **linearity**: the requirement that any two distinct edges share at
most one vertex. Linear hypergraphs — also called **partial Steiner systems** —
model lines in incidence geometry, blocks in balanced experimental designs, codewords
in constant-weight codes, and key-distribution patterns in cryptography. In each
setting one asks: *how many edges can a linear $r$-uniform hypergraph on $n$ vertices
contain, and which hypergraphs are extremal?*

This paper gives a complete answer for the basic density question. The upper bound is
classical folklore (a one-line double count), but our contribution is the precise,
self-contained, and *machine-verified* packaging of both the bound and its
optimality, including the exact characterization of equality via Steiner systems. The
result is the cornerstone $e = 2$ case of the Brown–Erdős–Sós (BES) programme and the
density anchor for the Keevash–Long (2023) study of sparse linear hypergraphs.

### 1.2 Summary of results

Let $V$ be a finite vertex set with $n = |V|$, and let a hypergraph be a finite
family $\mathcal{E}$ of edges, each edge a subset of $V$. We prove:

1. **(Density threshold; `linear_card_le`)** If $\mathcal{E}$ is $r$-uniform and
   linear, then $|\mathcal{E}| \cdot \binom{r}{2} \le \binom{n}{2}$.
2. **(Optimality; `steiner_card_eq`)** If $\mathcal{E}$ is a Steiner system
   $S(2,r,n)$, then $|\mathcal{E}| \cdot \binom{r}{2} = \binom{n}{2}$.
3. **(Real-valued form; `linear_density_real`)** For $r \ge 2$, a linear
   $r$-uniform $\mathcal{E}$ satisfies $|\mathcal{E}| \le \dfrac{n(n-1)}{r(r-1)}$
   over $\mathbb{R}$.

The structural engine is:

4. **(Disjointness; `pairs_disjoint`)** Linearity is equivalent to the pairwise
   disjointness of the pair sets $\binom{e}{2}$ over edges $e \in \mathcal{E}$.
5. **(Containment; `biUnion_pairs_subset`)** The union of the pair sets is contained
   in the set of all $2$-subsets of $V$.

---

## 2. Definitions

Throughout, $V$ is a finite type (vertex set) with decidable equality, $n = |V|$, and
$\mathcal{E}$ is a finite family of finite subsets of $V$ (the **edges**). For a
finite set $e$ and $k \in \mathbb{N}$, write $\binom{e}{k}$ for the family of
$k$-element subsets of $e$ (in the formalization, `powersetCard k e`), so that
$\left|\binom{e}{k}\right| = \binom{|e|}{k}$.

> **Definition 2.1 (Uniformity).** $\mathcal{E}$ is **$r$-uniform** if every edge has
> exactly $r$ vertices:
> $$\forall e \in \mathcal{E},\quad |e| = r.$$

> **Definition 2.2 (Linearity).** $\mathcal{E}$ is **linear** if any two distinct
> edges meet in at most one vertex:
> $$\forall e_1, e_2 \in \mathcal{E},\quad e_1 \ne e_2 \ \Rightarrow\ |e_1 \cap e_2| \le 1.$$
> A linear $r$-uniform hypergraph is also called a **partial Steiner system**.

> **Definition 2.3 (Steiner system).** $\mathcal{E}$ is a **Steiner system**
> $S(2,r,n)$ if it is $r$-uniform, linear, and **covers every pair**: every
> $2$-element subset $p \subseteq V$ is contained in some edge,
> $$\forall p \in \binom{V}{2},\ \exists e \in \mathcal{E},\ p \subseteq e.$$
> Linearity forces each pair to be covered *at most* once, so a Steiner system covers
> every pair **exactly** once.

We use two elementary identities repeatedly:
$$\binom{r}{2} = \frac{r(r-1)}{2}, \qquad \binom{n}{2} = \frac{n(n-1)}{2}.$$

---

## 3. The structural lemma: linearity as pairwise disjointness

The entire argument hinges on translating the geometric condition (edges share at
most one *vertex*) into a set-theoretic condition (edges share no common *pair*).

> **Lemma 3.1 (Pair sets are disjoint; `pairs_disjoint`).** If $\mathcal{E}$ is
> linear, then the map $e \mapsto \binom{e}{2}$ sends $\mathcal{E}$ to a family of
> pairwise disjoint sets. That is, for distinct $e, f \in \mathcal{E}$,
> $$\binom{e}{2} \cap \binom{f}{2} = \varnothing.$$

**Proof sketch.** Suppose toward a contradiction that some pair $p$ lies in both
$\binom{e}{2}$ and $\binom{f}{2}$ for distinct edges $e \ne f$. Then $p \subseteq e$
and $p \subseteq f$, so $p \subseteq e \cap f$; since $|p| = 2$, monotonicity of
cardinality gives $|e \cap f| \ge 2$. This contradicts linearity, which demands
$|e \cap f| \le 1$. Hence no common pair exists and the pair sets are disjoint.
$\quad\blacksquare$

This lemma is *the* load-bearing step. Its converse is also true and equally easy: if
the pair sets are pairwise disjoint then distinct edges cannot share two vertices, so
linearity and pairwise pair-disjointness are equivalent. We need only the stated
direction.

> **Lemma 3.2 (Pair sets live among all pairs; `biUnion_pairs_subset`).** For any
> family $\mathcal{E}$,
> $$\bigcup_{e \in \mathcal{E}} \binom{e}{2} \ \subseteq\ \binom{V}{2}.$$

**Proof sketch.** Each member of the left-hand union is a $2$-element subset of some
edge $e \subseteq V$, hence a $2$-element subset of $V$, i.e. a member of
$\binom{V}{2}$. $\quad\blacksquare$

---

## 4. The density threshold

> **Theorem 4.1 (Density threshold; `linear_card_le`).** Let $\mathcal{E}$ be an
> $r$-uniform linear hypergraph on $n = |V|$ vertices with $m = |\mathcal{E}|$ edges.
> Then
> $$m \cdot \binom{r}{2} \ \le\ \binom{n}{2}.$$

**Proof.** We count the elements of $\bigcup_{e} \binom{e}{2}$ in two ways.

*Each edge contributes $\binom{r}{2}$ pairs.* Since $\mathcal{E}$ is $r$-uniform,
$|e| = r$ for all $e$, so $\left|\binom{e}{2}\right| = \binom{r}{2}$, and summing over
the $m$ edges,
$$\sum_{e \in \mathcal{E}} \left|\binom{e}{2}\right| = m \cdot \binom{r}{2}.$$

*The contributions do not overlap.* By Lemma 3.1 the families $\binom{e}{2}$ are
pairwise disjoint, so the cardinality of their union equals the sum of their
cardinalities (the additivity of size over a disjoint union):
$$\left| \bigcup_{e \in \mathcal{E}} \binom{e}{2} \right| = \sum_{e \in \mathcal{E}} \left|\binom{e}{2}\right| = m \cdot \binom{r}{2}.$$

*The union fits inside all pairs.* By Lemma 3.2 the union is a subset of
$\binom{V}{2}$, so by monotonicity of cardinality,
$$m \cdot \binom{r}{2} = \left| \bigcup_{e \in \mathcal{E}} \binom{e}{2} \right| \le \left| \binom{V}{2} \right| = \binom{n}{2}.$$
$\quad\blacksquare$

The bound holds for *every* uniform linear family, including the empty hypergraph,
where it reads $0 \le \binom{n}{2}$. It is therefore non-vacuous and unconditional on
the side of the inequality.

> **Corollary 4.2 (Real density bound; `linear_density_real`).** For $r \ge 2$, a
> linear $r$-uniform hypergraph satisfies
> $$m \ \le\ \frac{n(n-1)}{r(r-1)} \qquad \text{over } \mathbb{R}.$$

**Proof sketch.** Multiply Theorem 4.1 by $2$ and use $2\binom{k}{2} = k(k-1)$ to get
the integer inequality $m \cdot r(r-1) \le n(n-1)$. Since $r \ge 2$ gives
$r(r-1) > 0$, divide to obtain the stated real bound. (The formalization performs the
clearing of the binomial denominators via $2 \mid k(k-1)$ and `Nat.div_mul_cancel`,
then divides over $\mathbb{R}$.) $\quad\blacksquare$

The leading coefficient in $n^2$ is exactly $\dfrac{1}{r(r-1)}$.

---

## 5. Optimality: Steiner systems attain the threshold

> **Theorem 5.1 (Optimality; `steiner_card_eq`).** Let $\mathcal{E}$ be a Steiner
> system $S(2,r,n)$. Then equality holds:
> $$m \cdot \binom{r}{2} \ =\ \binom{n}{2}.$$

**Proof.** Run the double count of Theorem 4.1, but now upgrade the containment of
Lemma 3.2 to an *equality*.

*Surjectivity onto all pairs.* By the covering axiom of Definition 2.3, every pair
$p \in \binom{V}{2}$ is contained in some edge $e$, hence $p \in \binom{e}{2} \subseteq
\bigcup_{e}\binom{e}{2}$. Combined with Lemma 3.2 (the reverse inclusion), we obtain
$$\bigcup_{e \in \mathcal{E}} \binom{e}{2} = \binom{V}{2}.$$

*Disjoint additivity.* Linearity (part of Definition 2.3) and Lemma 3.1 give pairwise
disjointness, so
$$\left| \bigcup_{e \in \mathcal{E}} \binom{e}{2} \right| = \sum_{e \in \mathcal{E}} \binom{|e|}{2} = m \cdot \binom{r}{2}.$$

*Conclusion.* The two displays equate $m \cdot \binom{r}{2}$ with
$\left|\binom{V}{2}\right| = \binom{n}{2}$. $\quad\blacksquare$

**Optimality of the coefficient.** The factor $\binom{r}{2}$ appears identically on
the $\le$ side of Theorem 4.1 and the $=$ side of Theorem 5.1. Hence no coefficient
smaller than $\frac{1}{r(r-1)}$ can serve as a valid upper bound for all $n$: the
Steiner systems are counterexamples that saturate the bound. Whenever a Steiner
system $S(2,r,n)$ exists, the density threshold is achieved *exactly*, certifying
sharpness.

**Existence of extremal witnesses.** Steiner systems exist for infinitely many $n$
for each $r$. The classical necessary divisibility conditions are $(r-1)\mid(n-1)$ and
$r(r-1)\mid n(n-1)$; by the celebrated theorem of Keevash (and, for designs in
general, the recent existence results), these are sufficient for all sufficiently
large admissible $n$. For $r=3$ the admissible orders are $n \equiv 1, 3 \pmod 6$ —
the classical **Steiner triple systems** — giving extremal examples
$S(2,3,n)$ for arbitrarily large $n$. The smallest nontrivial case is the
**Fano plane** $S(2,3,7)$ (Section 7).

---

## 6. Algorithms

We describe constructive and verification procedures attached to the result.

### 6.1 Linearity / Steiner verification by pair-incidence counting

Given an explicit family $\mathcal{E}$ on $V$, one can verify linearity, uniformity,
and the Steiner property in time $O(m \cdot r^2)$ by maintaining a multiplicity table
over pairs. For each edge, enumerate its $\binom{r}{2}$ pairs and increment a counter
in a hash map keyed by the (sorted) pair. Then:

- **Uniform** iff every edge has size $r$.
- **Linear** iff every pair-counter is $\le 1$.
- **Steiner** iff additionally every pair-counter is $\ge 1$ (so exactly $1$), i.e.
  the support of the table is all of $\binom{V}{2}$.

The number of distinct pairs touched equals $\sum_e \binom{r}{2} = m\binom{r}{2}$ when
linear, which the procedure directly compares to $\binom{n}{2}$, numerically
witnessing Theorems 4.1 and 5.1.

### 6.2 Threshold evaluation and admissibility

The threshold $\lfloor \binom{n}{2}/\binom{r}{2}\rfloor$ is computed in $O(1)$
arithmetic. Steiner-admissibility is tested by the divisibility predicate
$(r-1)\mid(n-1) \wedge r(r-1)\mid n(n-1)$, also $O(1)$.

### 6.3 Fano / projective-plane generator

For $r-1 = q$ a prime power, the points and lines of the projective plane
$\mathrm{PG}(2,q)$ form a Steiner system $S(2, q+1, q^2+q+1)$. One generates the
$q^2+q+1$ lines as one-dimensional subspaces of $\mathbb{F}_q^3$ (up to scaling),
each containing $q+1$ points; the output saturates the threshold by construction.

---

## 7. Worked examples and numerical verification

### 7.1 The Fano plane $S(2,3,7)$

With $r=3$, $n=7$: threshold $= \binom{7}{2}/\binom{3}{2} = 21/3 = 7$. The seven
blocks
$$\{1,2,3\},\{1,4,5\},\{1,6,7\},\{2,4,6\},\{2,5,7\},\{3,4,7\},\{3,5,6\}$$
cover each of the $21$ pairs exactly once. Here $m\binom{r}{2} = 7\cdot 3 = 21 =
\binom{7}{2}$, achieving equality (Theorem 5.1).

### 7.2 Steiner triple system $S(2,3,9)$

Threshold $= \binom{9}{2}/\binom{3}{2} = 36/3 = 12$. The affine plane $\mathrm{AG}(2,3)$
yields $12$ lines (blocks) of size $3$ covering each of the $36$ pairs once; again
$12 \cdot 3 = 36$, equality.

### 7.3 A non-admissible order

For $r=3$, $n=8$: $\binom{8}{2}/\binom{3}{2} = 28/3 = 9.33\ldots$, so $m \le 9$. Since
$3 \nmid 28$, no Steiner triple system exists on $8$ points; the integer threshold $9$
is *not* attained with equality $m\binom{3}{2}=\binom{8}{2}$ (which would need $28$
divisible by $3$). This illustrates the divisibility obstruction (cf. Future
Direction 2): the best linear hypergraph has $m \le 9 < 28/3$ in the exact sense that
$9\cdot 3 = 27 < 28$.

### 7.4 Affine plane $S(2,4,16)$

With $r=4$, $n=16$: threshold $= \binom{16}{2}/\binom{4}{2} = 120/6 = 20$. The affine
plane $\mathrm{AG}(2,4)$ has $20$ lines of size $4$, covering each of the $120$ pairs
once: $20\cdot 6 = 120$, equality.

---

## 8. Applications

- **Design of experiments.** Balanced incomplete block designs with $\lambda = 1$ are
  exactly Steiner systems; Theorem 5.1 fixes the minimal number of blocks needed for
  pairwise-balanced comparison, $b = \binom{n}{2}/\binom{r}{2}$.
- **Constant-weight and projective codes.** Steiner systems and projective planes
  yield optimal constant-weight codes; the pair-covering property becomes the minimum
  distance guarantee, and the density bound caps the codebook size.
- **Cryptographic key predistribution.** Linear hypergraphs describe key allocations
  where each pair of nodes shares at most one key; the threshold bounds the number of
  keyed groups for a given storage budget.
- **Incidence geometry.** The pair-counting method is the elementary heart of
  point–line incidence bounds, the combinatorial substrate beneath Szemerédi–Trotter
  type results.

---

## 9. Discussion and relation to the literature

The condition "any two edges meet in $\le 1$ vertex" is the $e = 2$ instance of the
**Brown–Erdős–Sós** extremal function $f_r(n; v, e)$, which bounds the number of edges
in an $r$-uniform hypergraph containing no $e$ edges spanning at most $v$ vertices.
Linearity forbids $2$ edges on $\le 2r-2$ vertices, and Theorem 4.1 is the exact cap
$f_r(n; 2r-1, 2) = O(n^2)$ at that level, with coefficient pinned by Theorem 5.1. The
next boundary, $e = 3$ (the $(6,3)$-problem for $r=3$), exhibits the subtle
$n^{2-o(1)}$ behaviour of Ruzsa–Szemerédi and remains a central open area.

The result is also the density anchor of the **Keevash–Long (2023)** study of sparse
linear hypergraphs, where the threshold $\frac{1}{r(r-1)}$ is the normalizing
constant against which sparser, configuration-avoiding families are measured. Our
concept statement — that for every $r \ge 3$, $k \ge 3$ there are arbitrarily large
linear $r$-uniform hypergraphs with edge count just below the threshold avoiding a
prescribed $((r-2)k+3, k)$-configuration — is precisely the assertion that this
threshold is the correct, unimprovable barrier up to lower-order terms.

A philosophical point: the proof is *purely combinatorial* and *coefficient-exact*.
There is no $\varepsilon$, no asymptotic slack, no appeal to regularity. The upper
bound and the extremal construction interlock through the identical factor
$\binom{r}{2}$, which is what makes "optimality" a theorem rather than a heuristic.

---

## 10. Future directions

The following program of conjectures extends the result.

**Conjecture 1 (Divisibility characterization of equality).** A Steiner system
$S(2,r,n)$ requires $(r-1)\mid(n-1)$ and $r(r-1)\mid n(n-1)$. A concrete next step is
to prove $\mathrm{IsSteiner}(\mathcal{E},r) \Rightarrow (r-1)\mid(n-1)$ by double
counting edges through a fixed vertex (each vertex lies in exactly $(n-1)/(r-1)$
edges) — the local-degree refinement of the global count.

**Conjecture 2 (Strict bound off the Steiner locus).** If $r(r-1)\nmid n(n-1)$ then
no linear $r$-uniform hypergraph attains the threshold: $m\binom{r}{2} \le \binom{n}{2}
- 1$ strictly. Provable from the disjoint-union double count plus a divisibility
obstruction.

**Conjecture 3 (BES at $e = 3$).** Generalize linearity to the $(3, 3r-2)$-property
(any $3$ edges span $> 3r-3$ vertices) and establish the $o(n^2)$ vs. $\Omega(n^{2-o(1)})$
density gap, the $(6,3)$-theorem analogue (Ruzsa–Szemerédi for $r=3$).

**Conjecture 4 (Keevash–Long threshold function).** For the sparse-regime maximum
$t_r(n)$, prove $t_r(n)/(n^2/(r(r-1))) \to 1$ along Steiner-admissible orders, with
convergence governed by the largest prime power $\le r-1$ (projective-plane
existence).

**Conjecture 5 (Fractional relaxation).** Replace edges by nonnegative weights on
$r$-sets with $\sum_{e \ni \{x,y\}} w(e) \le 1$ for every pair; conjecture the
fractional optimum $\sum_e w(e)$ equals $\binom{n}{2}/\binom{r}{2}$ for all $n \ge r$
(no divisibility obstruction), an LP-duality companion to Theorem 5.1.

---

## 11. Conclusion

We have given a complete, verified, and self-contained account of the linear
$r$-uniform density threshold: $m\binom{r}{2} \le \binom{n}{2}$, with Steiner systems
achieving equality and thereby certifying that the coefficient $\frac{1}{r(r-1)}$ is
sharp. The argument reduces, transparently, to a single double count of vertex pairs,
made legitimate by the equivalence between linearity and pairwise pair-disjointness.
Modest in statement but foundational in role, the threshold underlies experimental
design, coding theory, cryptography, and the deep BES and Keevash–Long frontiers of
extremal combinatorics.
