# Antipodality of Hypercube Vertex Sets via the Opposite-Semicube Helly Property

## Abstract

We study finite sets of vertices of the $n$-dimensional hypercube $Q_n$, whose
vertices we identify with bit-vectors in $\{0,1\}^n$. A vertex set $S$ is
*antipodal* if it is closed under the bit-complement (antipode) map. For each
coordinate $i$ and bit $b$, the *semicube* $S_i^b$ collects the vertices of $S$
whose $i$-th coordinate equals $b$; the pair $S_i^0, S_i^1$ are *opposite
semicubes*. We prove a complete characterization: **under the Helly property for
its semicubes, a finite vertex set is antipodal if and only if all of its
opposite semicubes are isometrically isomorphic** with respect to the Hamming
metric. The forward direction exhibits the antipode map as a canonical isometric
isomorphism between opposite semicubes. The converse is proved without invoking
antipodality: it constructs the antipode of each vertex as the unique common
solution of a family of coordinate constraints, using a standalone Helly-number-2
theorem for hypercube semicubes together with a cardinality-balance argument that
guarantees pairwise satisfiability. We also isolate two results of independent
interest: the antipode map is a global Hamming isometry, and the semicubes of the
full hypercube satisfy the Helly property with Helly number exactly two. All
results hold in every dimension $n$.

**Keywords.** hypercube, partial cube, antipodal set, semicube, Helly property,
Hamming distance, isometric isomorphism, local-to-global principle.

---

## 1. Introduction

The hypercube $Q_n$ is among the most fundamental objects in discrete
mathematics. Its vertex set is $\{0,1\}^n$, and two vertices are adjacent exactly
when their bit-vectors differ in a single coordinate; the resulting graph metric
is the *Hamming distance*. Sitting inside $Q_n$ is a distinguished global
symmetry, the **antipode** or bit-complement map, which flips every coordinate
and sends each vertex to the unique vertex at maximal distance $n$ from it.

A finite vertex set $S \subseteq \{0,1\}^n$ is **antipodal** when it is closed
under this map. Antipodal sets are highly symmetric configurations that arise
naturally in coding theory (codes closed under complementation), in the theory of
partial cubes and median graphs, and in the combinatorics of the cube. The
purpose of this paper is to characterize antipodality through *local* data,
replacing a single global closure condition by a family of independent
direction-by-direction comparisons.

The local data are the **semicubes**. Fixing a coordinate $i$ partitions $S$ into
two halves according to the value of the $i$-th bit; these halves, $S_i^0$ and
$S_i^1$, are the opposite semicubes in direction $i$. Semicubes are the discrete
analogue of halfspaces, and comparing the two opposite semicubes in each
direction is a natural probe of the internal symmetry of $S$.

Our main result states that this probe is *complete*, provided the semicubes obey
a Helly-type principle:

> **Theorem (Main).** Let $S$ be a finite vertex set of $Q_n$ whose semicubes
> satisfy the Helly property. Then $S$ is antipodal if and only if, for every
> coordinate $i$, the opposite semicubes $S_i^0$ and $S_i^1$ are isometrically
> isomorphic.

The forward implication is direct: antipodality supplies the antipode map as a
canonical isometry between opposite halves. The converse is the substantive
direction and is proved *constructively and without circularity*: assuming only
that opposite semicubes are isometric (equivalently, of equal cardinality with
matching internal geometry) plus the Helly property, we *build* the antipode of
each vertex and show it lies in $S$.

The bridge between local and global is a classical convexity principle. Eduard
Helly's theorem upgrades pairwise intersection to total intersection for
sufficiently convex families. We prove a discrete counterpart for hypercube
semicubes with Helly number exactly two, and use it as the engine of the
converse.

### Contributions

1. **Antipode isometry (Section 3).** The bit-complement map preserves Hamming
   distance globally.
2. **Forward direction (Section 4).** Antipodal sets have isometrically
   isomorphic opposite semicubes, witnessed canonically by the antipode.
3. **Helly for semicubes (Section 5).** The semicubes of the full hypercube
   satisfy the Helly property; the Helly number is exactly two.
4. **Cardinality balance and pairwise flips (Section 6).** Isometric opposite
   semicubes force a quadrant-count balance that yields pairwise satisfiability
   of flip constraints.
5. **Converse direction (Section 7).** Isometry of opposite semicubes plus Helly
   implies antipodality, via an antipode construction that never assumes
   antipodality.
6. **Characterization (Section 8).** The biconditional assembling the two
   directions.

---

## 2. Definitions and setup

Throughout, fix a dimension $n \in \mathbb{N}$.

**Vertices.** We identify the vertices of $Q_n$ with functions $v : \{0,\dots,n-1\}
\to \{0,1\}$, i.e. bit-vectors of length $n$. We write $V_n = \{0,1\}^n$ for the
vertex set.

**Bit complement.** The complement on a single bit is
$$\overline{0} = 1, \qquad \overline{1} = 0.$$
It is an involution ($\overline{\overline{b}} = b$), a fixed-point-free bijection
($\overline{b} \neq b$), and injective.

**Antipode.** The **antipode** of a vertex $v$ is the vertex $\bar v$ obtained by
complementing every coordinate: $(\bar v)_i = \overline{v_i}$. It is an
involution ($\overline{\bar v} = v$) and injective.

**Hamming distance.** For vertices $u, v$,
$$d(u,v) = \#\{\, i : u_i \neq v_i \,\}$$
is the number of coordinates in which they differ. This is the graph metric of
$Q_n$.

**Semicubes.** For a finite set $S \subseteq V_n$, a coordinate $i$, and a bit
$b$,
$$S_i^b = \{\, v \in S : v_i = b \,\}.$$
The pair $S_i^0, S_i^1$ are the **opposite semicubes** at $i$; they partition
$S$.

**Isometric isomorphism.** Two finite vertex sets $A, B \subseteq V_n$ are
**isometrically isomorphic**, written $A \cong B$, if there is a map
$f : V_n \to V_n$ restricting to a bijection $A \to B$ and preserving Hamming
distance on $A$:
$$\forall\, x,y \in A,\quad d(f(x), f(y)) = d(x,y).$$
In particular $A \cong B$ implies $|A| = |B|$.

**Antipodality.** $S$ is **antipodal** if $v \in S \implies \bar v \in S$.

**Helly property.** We say the semicubes of $S$ satisfy the **Helly property** if,
for every finite family $F$ of coordinate constraints $(i, b) \in \{0,\dots,n-1\}
\times \{0,1\}$,
$$
\bigl(\forall p \in F,\ \exists x \in S,\ x_{p_1} = p_2\bigr)
\ \wedge\
\bigl(\forall p,q \in F,\ \exists x \in S,\ x_{p_1}=p_2 \ \wedge\ x_{q_1}=q_2\bigr)
$$
implies
$$
\exists x \in S,\ \forall p \in F,\ x_{p_1} = p_2.
$$
In words: individual satisfiability plus pairwise joint satisfiability inside $S$
imply global joint satisfiability inside $S$. This is Helly number $2$: checking
pairs suffices.

---

## 3. The antipode is a global isometry

**Lemma 3.1 (Antipode preserves distance).** For all vertices $u, v \in V_n$,
$$d(\bar u, \bar v) = d(u, v).$$

*Proof.* The complement map on bits is a bijection, so $u_i \neq v_i$ if and only
if $\overline{u_i} \neq \overline{v_i}$, i.e. $(\bar u)_i \neq (\bar v)_i$. Thus
the sets of differing coordinates for $(u,v)$ and for $(\bar u, \bar v)$ coincide,
and their cardinalities are equal. $\qquad\blacksquare$

Because $\bar{\bar v} = v$, the antipode is a self-inverse global isometry of
$Q_n$. It also swaps opposite semicubes: since $(\bar v)_i = \overline{v_i}$, we
have $v_i = 0 \iff (\bar v)_i = 1$, so bit-complementation carries $\{v : v_i =
0\}$ onto $\{v : v_i = 1\}$. These two observations underlie the forward
direction.

---

## 4. Forward direction: antipodal sets have twin halves

**Theorem 4.1 (Forward direction).** If $S$ is antipodal, then for every
coordinate $i$ the antipode map restricts to an isometric isomorphism
$$S_i^0 \ \cong\ S_i^1.$$

*Proof.* Take $f = $ the antipode map, $f(v) = \bar v$. We verify the three
requirements.

- **Maps $S_i^0$ into $S_i^1$.** If $v \in S_i^0$ then $v \in S$ and $v_i = 0$.
  Antipodality gives $\bar v \in S$, and $(\bar v)_i = \overline{0} = 1$, so
  $\bar v \in S_i^1$.
- **Bijection.** The antipode is injective (Section 2). Surjectivity onto $S_i^1$:
  given $w \in S_i^1$, its antipode $\bar w$ satisfies $\bar w \in S$ (antipodality)
  and $(\bar w)_i = \overline{1} = 0$, so $\bar w \in S_i^0$ and $f(\bar w) =
  \bar{\bar w} = w$.
- **Isometry.** This is exactly Lemma 3.1.

Hence $f$ is a distance-preserving bijection $S_i^0 \to S_i^1$. $\qquad\blacksquare$

The forward direction identifies the antipode not merely as *a* witnessing
isometry but as the *canonical* one, uniform across all coordinates.

---

## 5. The Helly property for hypercube semicubes

We now prove that, in the full hypercube, coordinate constraints obey Helly's
principle with Helly number two. This is a statement about $V_n$ itself (the
"ambient" cube), independent of any particular $S$.

**Theorem 5.1 (Helly for semicubes).** Let $F$ be a finite family of coordinate
constraints $(i,b) \in \{0,\dots,n-1\} \times \{0,1\}$. Suppose every two
constraints in $F$ are jointly satisfiable: for all $p, q \in F$ there is a vertex
$v \in V_n$ with $v_{p_1} = p_2$ and $v_{q_1} = q_2$. Then all of $F$ is jointly
satisfiable: there is a vertex $v \in V_n$ with $v_{p_1} = p_2$ for every $p \in
F$.

*Proof.* Pairwise satisfiability means no two constraints in $F$ fix the same
coordinate to different bits: if $(i, b)$ and $(i, b')$ both lay in $F$ with $b
\neq b'$, no single vertex could satisfy both, contradicting pairwise
satisfiability. Consequently the assignment "coordinate $i \mapsto$ the demanded
bit" is well defined on the coordinates mentioned by $F$. Concretely, define
$$
g(i) = \begin{cases}
b & \text{if some } (i,b) \in F,\\
0 & \text{otherwise},
\end{cases}
$$
where the choice of $b$ is unambiguous by pairwise consistency. Then the vertex
$g$ satisfies $g_{p_1} = p_2$ for every $p \in F$. $\qquad\blacksquare$

The Helly number is *exactly* two, not one: a single constraint is trivially
satisfiable, yet without checking pairs one cannot detect a clash such as
$\{(i,0),(i,1)\}$, whose singletons are each satisfiable but whose pair is not.

**Remark 5.2.** Theorem 5.1 says the *ambient* cube always satisfies the Helly
property. The Main Theorem hypothesizes the Helly property for the semicubes of a
particular subset $S$; this is the natural relativization, requiring that the
common witness be found *inside $S$*. For $S = V_n$ the two coincide.

---

## 6. Cardinality balance and pairwise flips

The converse must manufacture antipodes from the isometry hypothesis. The first
step converts isometry into a counting statement.

**Lemma 6.1 (Isometry equalizes cardinality).** If $A \cong B$ then $|A| = |B|$.

*Proof.* An isometric isomorphism restricts to a bijection $A \to B$; a bijection
between finite sets equates their cardinalities. $\qquad\blacksquare$

**Corollary 6.2 (Balance of opposite semicubes).** If $S_i^0 \cong S_i^1$ for
every coordinate $i$, then $|S_i^0| = |S_i^1|$ for every $i$.

The crux is that pairwise balance in *two* directions forces a diagonal quadrant
balance.

**Lemma 6.3 (Pairwise flip from balance).** Suppose $|S_i^0| = |S_i^1|$ for every
coordinate $i$. Then for every $v \in S$ and every pair of coordinates $i, j$
there exists $w \in S$ with
$$w_i = \overline{v_i} \quad\text{and}\quad w_j = \overline{v_j}.$$

*Proof.* If $i = j$ the claim reduces to: the semicube opposite to $v$'s in
direction $i$ is nonempty. Since $v$ lies in one semicube (making it nonempty),
balance $|S_i^0| = |S_i^1|$ forces the opposite semicube to be nonempty as well,
providing the required $w$.

Suppose $i \neq j$. Partition $S$ into four *quadrants* by the values of
coordinates $i$ and $j$; write $N(c,d) = \#\{x \in S : x_i = c,\ x_j = d\}$ for
$c,d \in \{0,1\}$. Summing over the two values of $j$ (respectively $i$) gives the
marginal identities
$$
N(c,d) + N(c,\overline{d}) = |S_i^c|, \qquad
N(c,d) + N(\overline{c},d) = |S_j^d|.
$$
Using $|S_i^0| = |S_i^1|$ and $|S_j^0| = |S_j^1|$, these marginals yield
$$
N(c,d) = N(\overline{c},\overline{d}) \qquad\text{for all } c,d,
$$
i.e. diagonally opposite quadrants have equal counts. Applying this with $c = v_i,
d = v_j$: the quadrant of $v$ has $N(v_i, v_j) \geq 1$, hence
$N(\overline{v_i}, \overline{v_j}) \geq 1$, so some $w \in S$ satisfies $w_i =
\overline{v_i}$ and $w_j = \overline{v_j}$. $\qquad\blacksquare$

Lemma 6.3 gives *pairwise* satisfiability of the family of flip constraints
$\{(i, \overline{v_i})\}_i$ inside $S$: for any two coordinates we can flip both
simultaneously while staying in $S$. This is precisely the pairwise hypothesis
Helly needs.

---

## 7. Converse direction: matching halves force symmetry

**Theorem 7.1 (Converse direction).** Suppose the semicubes of $S$ satisfy the
Helly property, and $S_i^0 \cong S_i^1$ for every coordinate $i$. Then $S$ is
antipodal.

*Proof.* Fix $v \in S$; we must show $\bar v \in S$. Consider the finite family of
flip constraints
$$
F = \{\, (i, \overline{v_i}) : i \in \{0,\dots,n-1\} \,\}.
$$
A vertex $x \in S$ satisfies all of $F$ exactly when $x_i = \overline{v_i}$ for
every $i$, i.e. exactly when $x = \bar v$. So it suffices to produce a common
witness of $F$ inside $S$.

By Corollary 6.2 the opposite semicubes are cardinality-balanced. Lemma 6.3 then
supplies, for each single constraint (case $i = j$) and each pair of constraints,
a witness in $S$ — that is, $F$ is individually satisfiable and pairwise jointly
satisfiable inside $S$. The Helly property upgrades pairwise satisfiability to
global satisfiability: there exists $x \in S$ with $x_i = \overline{v_i}$ for all
$i$. This $x$ equals $\bar v$, so $\bar v \in S$.

The argument never assumed $S$ was antipodal; the antipode was constructed from
balance and Helly alone, avoiding circularity. $\qquad\blacksquare$

---

## 8. The characterization

**Theorem 8.1 (Antipodality characterization).** Let $S$ be a finite vertex set of
$Q_n$ whose semicubes satisfy the Helly property. Then
$$
S \text{ is antipodal} \iff \forall i,\ S_i^0 \cong S_i^1.
$$

*Proof.* ($\Rightarrow$) Theorem 4.1. ($\Leftarrow$) Theorem 7.1. $\qquad\blacksquare$

This is the promised bridge: a global closure property on the left, a family of
local isometry checks on the right, joined by Helly's principle.

---

## 9. Algorithms

The characterization translates into concrete decision procedures.

**Algorithm A (Antipodality by opposite-semicube comparison).** To test whether a
finite set $S$ whose semicubes satisfy the Helly property is antipodal: for each
coordinate $i$, form $S_i^0$ and $S_i^1$ and test whether they are isometrically
isomorphic. Return "antipodal" iff all $n$ tests pass. For the *canonical*
witness one need only check that the antipode map bijects $S_i^0$ onto $S_i^1$
for each $i$, which reduces to verifying closure of $S$ under complement; the
cardinality-balance test $|S_i^0| = |S_i^1|$ for all $i$ is a fast necessary
screen computable in a single pass.

**Algorithm B (Antipode construction via Helly).** Given $v \in S$ with balanced
opposite semicubes, build $\bar v$ inside $S$ by iteratively satisfying the flip
constraints $(i, \overline{v_i})$: maintain a set of consistent partial
assignments, add coordinates one at a time using the guaranteed pairwise flips,
and let Helly's principle certify the existence of the global witness. In the
hypercube the witness is simply the bit-complement, computable coordinate-wise in
linear time; the algorithm's value is as a *certificate scheme* that stays valid
in the relativized (inside-$S$) setting.

**Complexity.** With $|S| = m$ vertices in dimension $n$: computing all semicubes
and cardinality balances costs $O(mn)$. A direct isometry test between two
halves is the dominant cost; the canonical (antipode) witness collapses it to an
$O(mn)$ membership check for closure under complement.

---

## 10. Applications

- **Coding theory.** Binary codes closed under complementation (antipodal codes)
  are common and desirable for their symmetry. Theorem 8.1 certifies this global
  symmetry from local slice comparisons, enabling parallel, direction-by-direction
  verification.
- **Partial cubes and metric graph theory.** Semicubes are the halfspaces of
  partial-cube theory. The results place antipodality within the halfspace /
  Helly-number framework and suggest it as the extremal case in which every
  halfspace has an exact opposite.
- **Symmetry detection in configuration spaces.** Many combinatorial models embed
  in a hypercube. A local certificate for a global involutive symmetry turns an
  expensive global audit into independent local tests.

---

## 11. Discussion

The heart of the paper is a local-to-global principle. Antipodality is a global
closure condition, yet Theorem 8.1 shows it is fully detected by independent
per-direction comparisons of opposite semicubes — *provided* the geometry obeys
Helly's principle. Two features deserve emphasis.

First, the converse is *constructive and non-circular*. It does not assume the
symmetry it proves; it manufactures each antipode from cardinality balance
(supplied by isometry) and the Helly upgrade from pairwise to global
satisfiability. The counting core, Lemma 6.3, shows that balancing any two
directions forces diagonal quadrant equality — the discrete shadow of the
symmetry, visible two coordinates at a time.

Second, the Helly number for hypercube semicubes is *exactly two*. This mirrors
the classical Helly number of intervals on a line and reflects that semicubes are
one-dimensional halfspaces in each coordinate: clashes are always pairwise,
between a coordinate fixed to opposite bits.

---

## 12. Future directions

**Conjecture 1 — The abstract-isomorphism Helly converse.** The characterization
proved here uses the *canonical* isomorphism given by the antipode map. The bolder
statement drops the canonical map: a finite partial cube satisfying the
opposite-semicube Helly property is antipodal whenever all of its opposite
semicubes are *abstractly* isomorphic (matching cardinalities and internal
geometry, with no preferred matching supplied). The key insight is that abstract
isomorphism supplies, for each direction, some distance-preserving matching
between the two halves, and the Helly property is exactly the coherence condition
that lets these per-direction matchings be forced to coincide with the single
global involution — the antipode map — already known to witness the canonical
version.

**Conjecture 2 — Helly number is a partial-cube invariant.** For every finite
partial cube, the Helly number of its family of semicubes is at most two, with
equality unless the cube is a single vertex. The key insight is that a semicube is
a halfspace, and halfspace families in median-like geometries never require more
than pairwise checking; the antipodal case is merely the extremal instance where
every halfspace has an exact opposite.

**Conjecture 3 — Diameter rigidity.** A finite partial cube is antipodal if and
only if every vertex has a unique vertex at maximum distance and this
correspondence is a distance-preserving involution. The key insight is that the
uniqueness of the diametral mate already forces the correspondence to reverse
every semicube, and reversing every semicube is antipodality; the involution
hypothesis removes degenerate near-antipodal configurations.

---

## 13. Conclusion

We characterized antipodality of finite hypercube vertex sets through a local
comparison of opposite semicubes, bridged by a Helly-number-two principle for
semicubes. The forward direction exhibits the antipode as a canonical isometry
between opposite halves; the converse constructs antipodes from cardinality
balance and Helly's principle without circularity. Along the way we recorded that
the antipode map is a global isometry and that hypercube semicubes have Helly
number exactly two. The result is a clean dictionary between a global symmetry and
a family of local checks — a small but sharp instance of the local-to-global
philosophy that pervades geometry and combinatorics.
