# The Helly Number of Semicubes, and the Opposite-Semicube Property in Cartesian Products of Partial Cubes

## Abstract

We study the intersection combinatorics of *semicubes* — the coordinate halfspaces of a
finite hypercube — and establish that their **Helly number is exactly two**: any finite
family of semicubes that is pairwise intersecting has a common vertex. The proof is
constructive and yields the common vertex explicitly. The mechanism behind the result is
that the only obstruction to a common intersection is a single coordinate demanded in
both of its opposite values; semicubes attached to distinct coordinates never conflict.
This coordinatewise independence has an immediate structural payoff: because a hypercube
is a Cartesian product of lower-dimensional cubes, and cross-coordinate pairs impose no
constraint, the semicube Helly property of a product reduces trivially to that of its
factors. We then examine the natural refinement in which families are **closed under
passing to opposite semicubes**, and we explain, at the level of a precise conjecture,
why this refinement first forces the factors of a product to cooperate: a product of two
partial cubes satisfies the opposite-semicube Helly property if and only if both factors
are *harmonic-even*. We situate these results within the theory of partial cubes and
$\Theta$-classes, give algorithms, numerical demonstrations, and a program of open
problems.

**Keywords.** hypercube; semicube; halfspace; Helly number; partial cube;
$\Theta$-class; Cartesian product; harmonic-even; local-to-global; constraint
satisfaction.

## 1. Introduction

### 1.1 Helly numbers

A classical theme in combinatorial geometry is the passage from *local* to *global*
intersection. **Helly's theorem** asserts that if a finite family of convex sets in
$\mathbb{R}^d$ has the property that every $d+1$ of its members have a common point, then
the whole family has a common point. The integer $d+1$ is the **Helly number** of the
family: the largest size of a subfamily one must inspect to certify a global
intersection. Helly numbers quantify how "spread out" an intersection obstruction can
be, and they recur across discrete geometry, hypergraph theory, and optimization.

For a family $\mathcal{F}$ of sets we say $\mathcal{F}$ has **Helly number $k$** if the
following holds: whenever every subfamily of size at most $k$ has a common element, the
entire family has a common element. Small Helly numbers are desirable computationally,
because they reduce a global consistency question to the inspection of small
subfamilies.

### 1.2 The cube and its halfspaces

Let $\iota$ be a finite index (coordinate) set with $|\iota| = n$. The **hypercube**
$Q(\iota)$ has as vertices all binary strings indexed by $\iota$. We adopt the standard
subset encoding: a vertex is a subset $s \subseteq \iota$, where $i \in s$ means the
$i$-th coordinate is $1$ (or "true") and $i \notin s$ means it is $0$ (or "false"). The
graph structure joins two vertices when they differ in exactly one coordinate; the
resulting shortest-path distance is the **Hamming distance**
$d(s, t) = |s \,\triangle\, t|$, the number of coordinates in which $s$ and $t$ disagree.

The fundamental convex slabs of the cube are its coordinate halfspaces.

**Definition 1 (Semicube).** For a coordinate $i \in \iota$ and a bit
$b \in \{\text{true}, \text{false}\}$, the **semicube** $H(i,b)$ is
$$H(i, b) = \{\, s \subseteq \iota : [\,i \in s\,] = b \,\},$$
where $[\,i \in s\,]$ denotes the truth value of the membership $i \in s$. Equivalently,
$H(i,\text{true})$ is the set of vertices containing $i$, and $H(i,\text{false})$ is the
set of vertices not containing $i$. Each semicube contains exactly $2^{\,n-1}$ vertices.

The two semicubes of a fixed coordinate are the two opposite faces of the cube
perpendicular to that coordinate direction. They partition the vertex set: every vertex
lies in exactly one of $H(i, \text{true})$, $H(i, \text{false})$.

### 1.3 Results

Our central theorem is the following.

> **Theorem A (Helly number two for semicubes).** Let $F$ be a finite family of
> semicubes of $Q(\iota)$. If every two members of $F$ have a common vertex, then all
> members of $F$ have a common vertex. Equivalently, the semicubes of a finite hypercube
> have Helly number $2$.

Two supporting facts isolate the mechanism.

> **Lemma 1 (Opposite semicubes are disjoint).** For each coordinate $i$,
> $H(i,\text{true}) \cap H(i,\text{false}) = \varnothing$.

> **Lemma 2 (Coordinatewise determinacy).** Let $F$ be a pairwise-intersecting family of
> semicubes. If $F$ contains both $H(i,b)$ and $H(i,b')$ for the same coordinate $i$,
> then $b = b'$. In words, a pairwise-intersecting family assigns each coordinate a
> single well-defined bit.

Theorem A is sharp in a strong sense: the Helly number is $2$ **independently of the
dimension** $n$. A cube of any size, carrying arbitrarily many independent coordinate
directions, still requires only pairwise consistency for global consistency. This
already distinguishes semicubes from generic convex families, whose Helly number grows
with the ambient dimension.

The structural reason behind Theorem A is *coordinatewise independence*: two semicubes
belonging to different coordinates always intersect. Because a hypercube factors as a
Cartesian product $Q(\iota) = Q(\iota_1) \times Q(\iota_2)$ whenever
$\iota = \iota_1 \sqcup \iota_2$, and left–right coordinate pairs never obstruct, we
obtain:

> **Corollary B (Product reduction).** The semicube Helly property of a Cartesian
> product of hypercubes holds because it holds in each factor: cross-factor pairs impose
> no constraint, so the product's Helly number is the maximum of the factors' Helly
> numbers, namely $2$.

Finally, we study the refinement in which families are closed under passing to opposite
semicubes, motivating the following conjecture in the setting of general partial cubes
(§5).

> **Conjecture C (Opposite-semicube characterization).** A Cartesian product of two
> partial cubes satisfies the *opposite-semicube Helly property* — every
> pairwise-intersecting family closed under opposites has a common vertex — if and only
> if both factors are **harmonic-even**.

### 1.4 Organization

Section 2 fixes conventions. Section 3 proves Lemmas 1–2 and Theorem A. Section 4 gives
the product reduction and the isometric-host viewpoint that makes semicubes genuine
$\Theta$-classes. Section 5 develops the opposite-closed refinement and Conjecture C.
Section 6 gives algorithms and complexity. Section 7 discusses applications, and Section
8 lists open problems.

## 2. Preliminaries

Throughout, $\iota$ is a finite set of coordinates with decidable equality, and vertices
of $Q(\iota)$ are subsets $s \subseteq \iota$. We freely identify a semicube with the
pair $(i, b) \in \iota \times \{\text{true}, \text{false}\}$ that names it. A **family**
is a finite set $F$ of such pairs. Given $F$, the associated collection of vertex sets is
$\{\,H(i,b) : (i,b) \in F\,\}$.

**Pairwise intersection.** $F$ is *pairwise intersecting* if for all distinct
$(i,b), (j,c) \in F$ the set $H(i,b) \cap H(j,c)$ is nonempty.

**Common vertex.** A vertex $v$ is *common to $F$* if $v \in H(i,b)$ for all
$(i,b) \in F$; equivalently $v \in \bigcap_{(i,b)\in F} H(i,b)$.

**Partial cubes and $\Theta$-classes.** A connected graph $G$ is a **partial cube** if
it admits an isometric (distance-preserving) embedding into some hypercube; that is, its
vertices can be labeled by binary strings so that graph distance equals Hamming distance.
The **Djoković–Winkler relation** $\Theta$ groups the edges of $G$ into classes; each
$\Theta$-class $E_i$, when removed, splits $G$ into two convex halves $H_i^+$ and
$H_i^-$, the two opposite **semicubes** of that class. In the hypercube itself, the
$\Theta$-class of coordinate $i$ consists of all edges that flip coordinate $i$, and its
two halves are precisely $H(i,\text{true})$ and $H(i,\text{false})$. Thus the cube results
below describe the $\Theta$-classes of the universal isometric host.

**Harmonic-evenness.** A partial cube is **harmonic-even** if every $\Theta$-class
divides the vertex set into two parts of equal size, and this balance is inherited by
every convex subgraph. Even cycles $C_{2k}$ and the hypercubes themselves are
harmonic-even; a path with an odd number of vertices is not, since its central
$\Theta$-class splits the vertices unevenly.

## 3. The Helly number of semicubes

### 3.1 Opposite semicubes are disjoint

**Lemma 1.** For every coordinate $i$, $H(i,\text{true}) \cap H(i,\text{false}) = \varnothing$.

*Proof.* A vertex $s$ lies in $H(i,\text{true})$ iff $i \in s$, and in
$H(i,\text{false})$ iff $i \notin s$. No $s$ can satisfy both, so the intersection is
empty. $\qquad\blacksquare$

### 3.2 Coordinatewise determinacy

**Lemma 2.** Let $F$ be pairwise intersecting. If $(i,b) \in F$ and $(i,b') \in F$ with
the *same* coordinate $i$, then $b = b'$.

*Proof.* Suppose toward a contradiction that $b \neq b'$; for bits, this means
$\{b, b'\} = \{\text{true}, \text{false}\}$. Then $(i,b)$ and $(i,b')$ are distinct
members of $F$, so by pairwise intersection $H(i,b) \cap H(i,b')$ is nonempty. But that
set is $H(i,\text{true}) \cap H(i,\text{false})$, which is empty by Lemma 1 — a
contradiction. Hence $b = b'$. $\qquad\blacksquare$

Lemma 2 is the crux: it says a pairwise-intersecting family induces a **partial
assignment** $\alpha \colon \{\text{coordinates used by } F\} \to \{\text{true},
\text{false}\}$, $\alpha(i) = b$ whenever $(i,b) \in F$, and this assignment is
well-defined.

### 3.3 The theorem

**Theorem A.** If $F$ is a pairwise-intersecting finite family of semicubes, then $F$
has a common vertex; equivalently the semicubes of $Q(\iota)$ have Helly number $2$.

*Proof.* By Lemma 2 the family determines a well-defined partial assignment: for each
coordinate $i$ appearing in $F$, all pairs of $F$ mentioning $i$ carry the same bit.
Define the vertex
$$v = \{\, i \in \iota : (i, \text{true}) \in F \,\}.$$
We claim $v$ is common to $F$. Take any $(i, b) \in F$.

- If $b = \text{true}$, then by definition $i \in v$, so $v \in H(i,\text{true}) = H(i,b)$.
- If $b = \text{false}$, we must show $i \notin v$. Suppose instead $i \in v$; then by
  definition of $v$ we would have $(i, \text{true}) \in F$. But $(i, \text{false}) \in F$
  as well, and by Lemma 2 (or directly by pairwise intersection and Lemma 1) this is
  impossible when the two bits differ. Hence $i \notin v$, i.e.
  $v \in H(i,\text{false}) = H(i,b)$.

In both cases $v \in H(i,b)$. As $(i,b)$ was arbitrary, $v$ lies in every semicube of
$F$, so $\bigcap_{(i,b) \in F} H(i,b) \ne \varnothing$. Since a family with a global
intersection is a fortiori pairwise intersecting, the two conditions are equivalent and
the Helly number is exactly $2$ (it is not $1$: two opposite semicubes of one coordinate
are individually nonempty yet have empty intersection). $\qquad\blacksquare$

**Remark (sharpness).** The witness $v$ is *canonical*: it turns on precisely those
coordinates the family demands to be true and turns off all others. The construction uses
no search; it reads the answer directly off the family. This is what makes the Helly
number independent of the dimension $n$.

## 4. Independence, products, and the isometric host

### 4.1 Cross-coordinate pairs never obstruct

**Proposition 3.** If $i \neq j$, then for all bits $b, c$ the semicubes $H(i,b)$ and
$H(j,c)$ intersect.

*Proof.* Choose any vertex $s$ with $[\,i \in s\,] = b$ and $[\,j \in s\,] = c$; the
values of the remaining coordinates are free. Such $s$ exists because $i \ne j$, and it
lies in both semicubes. $\qquad\blacksquare$

Proposition 3 is the quantitative form of *coordinatewise independence*. Combined with
Lemma 1, it gives a complete description of when two semicubes intersect: **two semicubes
fail to intersect if and only if they are the two opposite halves of a single
coordinate.** Every non-intersecting pair is an opposite pair, and vice versa.

### 4.2 Product reduction

Suppose $\iota = \iota_1 \sqcup \iota_2$, so that $Q(\iota) \cong Q(\iota_1) \times
Q(\iota_2)$; a vertex of the product is a pair $(s_1, s_2)$ of vertices of the factors,
and each semicube of the product is a semicube of one factor "widened" over the other.

**Corollary B.** A pairwise-intersecting family $F$ of semicubes in the product has a
common vertex, obtained by solving each factor independently.

*Proof.* Partition $F$ into $F_1$ (pairs whose coordinate lies in $\iota_1$) and $F_2$
(pairs whose coordinate lies in $\iota_2$). Any two members of $F_1$ intersect within the
product, hence intersect as semicubes of $Q(\iota_1)$; so $F_1$ is pairwise
intersecting in the first factor, and by Theorem A has a common vertex $v_1$. Likewise
$F_2$ yields $v_2$. By Proposition 3 no cross pair (one member from $F_1$, one from $F_2$)
ever obstructs, so the combined vertex $(v_1, v_2)$ is common to all of $F$.
$\qquad\blacksquare$

Thus the plain semicube Helly property **factors for free**: the product inherits Helly
number $2$ from its factors, and the two factors interact not at all. This is the precise
sense in which the plain property is "too easy" to detect any cooperation between
factors — a point that motivates §5.

### 4.3 The cube as isometric host

Because the hypercube is an isometric host — graph distance equals Hamming distance — the
semicubes $H(i,b)$ are genuine $\Theta$-classes rather than arbitrary vertex bipartitions.
Consequently every statement above transfers to any partial cube $G$ by reading "$H(i,b)$"
as the two convex halves of the $i$-th $\Theta$-class of $G$: a family of $\Theta$-class
halves in a partial cube is pairwise intersecting iff no two of them are opposite halves
of the same class, and in that case it has a common vertex. Theorem A is therefore not
merely a fact about cubes but the base case of a general theory of $\Theta$-class
intersection in partial cubes.

## 5. The opposite-closed refinement

The plain property is insensitive to the structure of the factors (Corollary B). To
capture genuine cooperation, we strengthen the closure condition on families.

**Definition 2 (Opposite-closed family).** A family $F$ of semicubes is **closed under
opposites** if, whenever $(i, b) \in F$, its opposite $(i, \bar b)$ is *available* to
join the family (equivalently, we consider the closure of $F$ under the involution
$(i,b) \mapsto (i,\bar b)$ and demand consistency of the enlarged family).

**Definition 3 (Opposite-semicube Helly property).** A partial cube $G$ satisfies the
**opposite-semicube Helly property** if every pairwise-intersecting family of
$\Theta$-class halves that is closed under opposites has a common vertex.

For the plain (non-closed) property, the sole obstruction is an opposite pair present in
the family (Lemma 1 and Proposition 3). Once families are closed under opposites, that
obstruction changes character: an opposite pair is *always* formally present, so it can no
longer be the deciding obstacle. What replaces it is a **parity/balance condition**. A
coordinate can be circumvented — its two halves reconciled within a pairwise-intersecting,
opposite-closed family — only when the two opposite semicubes are *interchangeable*, i.e.
when swapping the two halves is a symmetry of the structure. Interchangeability of a
$\Theta$-class's two halves in every convex subgraph is exactly **harmonic-evenness**.

This reasoning leads to the central conjecture of the program.

**Conjecture C.** A Cartesian product $G_1 \times G_2$ of two partial cubes satisfies
the opposite-semicube Helly property if and only if both $G_1$ and $G_2$ are
harmonic-even.

*Heuristic justification.* By the product reduction (Corollary B), cross-factor pairs
never obstruct, so the property of the product decouples into a condition on each factor.
For a single factor, the opposite-closed pairwise-intersecting families that must be
reconciled are governed precisely by whether opposite halves of each $\Theta$-class can be
balanced against one another; the ability to do so uniformly across convex subgraphs is
the definition of harmonic-evenness. Necessity comes from exhibiting, in a factor that
fails harmonic-evenness, an unbalanced $\Theta$-class whose two halves cannot be
reconciled within an opposite-closed family; sufficiency comes from using the balance to
extend a factorwise common vertex across the closure. The plain cube is the degenerate
extreme: each $\Theta$-class splits the $2^n$ vertices into two equal halves of
$2^{n-1}$, harmonic-evenness is automatic, and the Helly number collapses to $2$. $\square$

Two companion conjectures complete the picture (stated for context; see §8).

**Conjecture D (Helly number equals isometric dimension).** For a partial cube $G$, the
Helly number of its family of $\Theta$-class halves equals the isometric dimension of $G$
— the least $n$ with an isometric embedding $G \hookrightarrow Q_n$ — measured by the
number of *independent* $\Theta$-classes, not their raw count. (The full cube shows the
raw count is the wrong invariant: it carries $n$ classes yet has Helly number $2$.)

**Conjecture E (Products create harmonic-evenness).** The Cartesian product of two
harmonic-even partial cubes is harmonic-even, and every harmonic-even partial cube that
is not a single vertex factors as a nontrivial product of harmonic-even partial cubes.

## 6. Algorithms

The constructive proof of Theorem A yields a fast decision-and-construction procedure.

### 6.1 Consistency by coordinate folding

Given a family $F$ presented as a list of pairs $(i, b)$, the family is pairwise
intersecting iff no coordinate carries two different bits (Lemma 2 with Proposition 3).
Hence:

**Algorithm (Semicube consistency and witness).**
1. Initialize an empty dictionary $\alpha$ mapping coordinates to bits.
2. For each pair $(i, b)$ in $F$: if $i \notin \alpha$, set $\alpha(i) = b$; else if
   $\alpha(i) \ne b$, report **inconsistent** and stop.
3. If no clash occurs, report **consistent** and output the witness vertex
   $v = \{\, i : \alpha(i) = \text{true} \,\}$.

Correctness is Theorem A: a clash is exactly an opposite pair, the unique obstruction; in
its absence, $v$ is common to $F$. The running time is $O(|F|)$ with hashing (or
$O(|F|\log|F|)$ by sorting on the coordinate), using $O(|\iota|)$ space. Crucially, the
algorithm never enumerates vertices, of which there are $2^n$.

### 6.2 Product decomposition

For a product $Q(\iota_1) \times Q(\iota_2)$, split $F$ by which factor each coordinate
lives in and run the above independently on $F_1$ and $F_2$; concatenate the witnesses.
By Corollary B this is correct, and it is embarrassingly parallel across factors.

## 7. Applications

**Constraint satisfaction.** A conjunction of "coordinate $i$ equals $b$" constraints —
a system of unit clauses over Boolean variables — is satisfiable iff it is pairwise
satisfiable. Theorem A is the geometric reason 2-consistency suffices for such systems,
and the folding algorithm is the standard unit-propagation check, recovered here as a
Helly phenomenon.

**Median spaces and cube complexes.** Hypercubes and partial cubes are the discrete
avatars of median algebras and CAT(0) cube complexes, where halfspaces (semicubes) are
the primary objects and the "no two opposite halfspaces both chosen" condition
underlies the Helly-type theorems that structure these spaces. The clean Helly number
$2$ for cube halfspaces is the local model for those global results.

**Distributed agreement.** When independent agents each constrain a single shared
coordinate, global agreement is reachable exactly when no coordinate is contested — a
condition checkable pairwise. The product reduction says agents acting on disjoint
coordinate blocks can be reconciled blockwise with no cross-negotiation.

## 8. Discussion and open problems

We proved that semicubes of a finite hypercube have Helly number $2$, exhibited the
canonical witness, identified opposite pairs as the *unique* obstruction, and showed the
plain property factors trivially across Cartesian products. The refinement to
opposite-closed families is where products stop being trivial: we conjecture (Conjecture
C) that the opposite-semicube Helly property of a product characterizes harmonic-evenness
of both factors, and we posed companion conjectures relating the Helly number to
isometric dimension (D) and describing how products preserve and generate
harmonic-evenness (E).

Open problems:

1. **Prove Conjecture C** in full, giving both the obstruction (necessity) in a
   non-harmonic-even factor and the balancing extension (sufficiency).
2. **Pin down the right dimension invariant in Conjecture D**: formalize "independent
   $\Theta$-classes" so that the Helly number of $\Theta$-class halves equals it, and
   reconcile it with the cube's Helly number $2$.
3. **Establish Conjecture E** (products preserve harmonic-evenness; nontrivial
   harmonic-even partial cubes factor), which would make harmonic-evenness a genuinely
   multiplicative invariant.
4. **Quantitative Helly / fractional and colorful variants** for semicubes: does a
   fractional Helly theorem hold with dimension-free constants, mirroring the exact Helly
   number $2$?

## Appendix: worked micro-examples

- **A single coordinate.** $F = \{(i,\text{true}), (i,\text{false})\}$ is *not* pairwise
  intersecting (Lemma 1); correctly, it has no common vertex. This is the minimal
  non-Helly family and shows the Helly number is not $1$.
- **Three coordinates, consistent.** In $Q_3$ with coordinates $\{1,2,3\}$, the family
  $\{(1,\text{true}), (2,\text{false}), (3,\text{true})\}$ is pairwise intersecting; the
  witness is $v = \{1,3\}$, i.e. the string $101$, which indeed lies in all three
  semicubes.
- **Product.** In $Q_2 \times Q_2$ with left coordinates $\{1,2\}$ and right coordinates
  $\{3,4\}$, the family $\{(1,\text{true}),(3,\text{false})\}$ splits as
  $F_1 = \{(1,\text{true})\}$, $F_2 = \{(3,\text{false})\}$; witnesses $v_1$ has
  coordinate $1$ true, $v_2$ has coordinate $3$ false, and their combination is common —
  the cross pair never obstructs (Proposition 3).
