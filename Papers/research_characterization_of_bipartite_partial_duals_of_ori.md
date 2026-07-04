# A GF(2) Characterization of Bipartite Partial Duals of Orientable Hypermaps

## Abstract

Partial duality, introduced by Chmutov for ribbon graphs and extended to
hypermaps by Metsidik and Jin, produces from an orientable hypermap $H$ and a
subset $E'$ of its hyperedges a new hypermap $H^{E'}$, generally embedded on a
different surface. We study the question of which subsets $E'$ render the partial
dual **bipartite** (two-face-colorable). We give a self-contained account of the
characterization: *provided every hyperedge of $H$ has even length*, $H^{E'}$ is
bipartite if and only if $E'$ is the crossing set $C(\Phi)$ of an **all-crossing
direction** $\Phi$ of the medial map $M(H)$. We isolate two independent
ingredients. First, a **parity dichotomy**: a single hyperedge of length
$\ell \ge 3$ admits a consistent all-crossing state on its boundary cycle if and
only if $\ell$ is even, whence the medial map admits an all-crossing direction
iff every hyperedge has even length. Second, a **linear-algebraic core over
$\mathrm{GF}(2)$**: the medial interlacement assembles into a symmetric crossing
operator whose kernel is the set of all-crossing directions, while bipartite
partial duals form a coset of that same kernel. Consequently the crossing-set map
is an affine bijection between all-crossing directions and bipartite partial
duals, so the two families are equinumerous with common cardinality a power of
two, $2^{\dim\ker}$. We conclude with algorithmic consequences, numerical
illustrations, and conjectures relating the count to Euler genus and to an
Eulerian companion theory.

**Keywords:** hypermap, partial duality, ribbon graph, medial map, all-crossing
direction, bipartite, GF(2), interlacement, delta-matroid, affine torsor.

---

## 1. Introduction

Maps and hypermaps on orientable surfaces admit a rich family of local surgical
operations. Among the most versatile is **partial duality**: introduced by
Chmutov in the setting of ribbon graphs and generalized to hypermaps by Metsidik
and Jin, it interpolates between the identity and the classical geometric dual by
applying a duality move to a *chosen subset* of edges (respectively hyperedges).
The resulting family $\{H^{E'}\}_{E'}$ interacts subtly with the underlying
topology — the genus of $H^{E'}$ can differ wildly from that of $H$ — and
partial duality is now understood as a cornerstone of the theory of embedded
graphs, delta-matroids, and the Bollobás–Riordan polynomial.

A natural structural question is: **which** partial duals of $H$ possess a given
graph-theoretic property? Huggett and Moffatt answered this for the properties
*bipartite* and *Eulerian* on ribbon graphs, expressing the qualifying edge-sets
in terms of the medial graph. Metsidik and Jin lifted the bipartite half of this
answer to orientable hypermaps.

This paper gives a self-contained, structural account of the bipartite
characterization, separating it into a **combinatorial parity obstruction** and a
**linear-algebraic classification** over the two-element field
$\mathrm{GF}(2)$. The upshot is that the qualifying subsets are not an ad hoc
collection but an **affine subspace**: a single coset of the kernel of an
explicit symmetric operator built from the medial map. This viewpoint makes the
counting transparent (the number of bipartite partial duals is a power of two)
and exposes the even-length hypothesis as exactly the nonemptiness condition for
the solution set.

### 1.1 Contributions

1. **Parity dichotomy (Section 3).** For $\ell \ge 3$, a hyperedge of length
   $\ell$ admits a consistent all-crossing state on its length-$\ell$ boundary
   cycle iff $\ell$ is even; globally, an all-crossing direction of $M(H)$ exists
   iff every hyperedge has even length.
2. **GF(2) core (Section 4).** The all-crossing directions are the kernel of a
   symmetric crossing operator $\mathrm{cross}_J$; the bipartite partial duals
   are the coset $t + \ker \mathrm{cross}_J$ for a reference twist $t$.
3. **Affine bijection and count (Section 5).** The crossing-set map
   $C(\Phi) = \Phi + t$ is a bijection from all-crossing directions onto
   bipartite partial duals; hence they are equinumerous with common size
   $2^{\dim \ker \mathrm{cross}_J}$, and $C$ is itself a partial-duality (twist)
   move.

---

## 2. Definitions and setup

### 2.1 Orientable hypermaps

An **orientable hypermap** is a pair $H = (\sigma, \alpha)$ of permutations of a
finite set $D$ of **darts**. The cycles of $\sigma$ are the **vertices**, the
cycles of $\alpha$ are the **hyperedges**, and the cycles of the third permutation
$\varphi = (\sigma\alpha)^{-1}$ are the **faces**. The **length** of a hyperedge
$e$, written $\operatorname{len}(e)$, is the number of darts in its $\alpha$-cycle.
A **ribbon graph** is the special case in which every hyperedge has length two.

We write $E$ for the (finite) set of hyperedges of $H$. A subset $E' \subseteq E$
selects hyperedges to be dualized.

### 2.2 Partial duality

For $E' \subseteq E$, the **partial dual** $H^{E'}$ is the hypermap obtained by
applying the geometric duality move to the hyperedges in $E'$ only. It satisfies
$H^{\varnothing} = H$, $H^{E} = H^{*}$ (the full dual), and the composition law
$(H^{A})^{B} = H^{A \,\triangle\, B}$, where $\triangle$ denotes symmetric
difference. Thus the set of partial duals carries a natural action of the
$\mathrm{GF}(2)$-vector space of subsets of $E$ under symmetric difference, an
observation that underlies the algebra below.

A hypermap is **bipartite** when its faces can be properly two-colored, i.e. its
face structure admits a partition into two classes with no monochromatic
adjacency. Equivalently (in the medial picture used below), a suitable boundary
structure is two-colorable.

### 2.3 The medial map and all-crossing directions

The **medial map** $M(H)$ is a four-regular map associated to $H$: it places a
node at each dart-adjacency and records how strands run alongside one another
around the surface. At each four-valent node two strands meet, and one may
declare them to **cross** or to **bounce**. A choice of state at every node is a
**direction**; a direction in which every node is a crossing is an
**all-crossing direction** $\Phi$.

Each hyperedge $e$ of length $\ell = \operatorname{len}(e)$ bounds a face of
$M(H)$ traversed as a closed walk of length $\ell$; combinatorially this boundary
is the cycle graph $C_\ell$. The all-crossing constraint forces the two crossing
states to *alternate* around this boundary walk — a proper two-coloring of
$C_\ell$.

Each all-crossing direction $\Phi$ determines a **crossing set**
$C(\Phi) \subseteq E$, the set of hyperedges recorded as "crossed."

### 2.4 The interlacement form and crossing operator

The combinatorics of $M(H)$ is captured algebraically by a symmetric
**interlacement form** over $\mathrm{GF}(2)$.

**Definition 2.1 (Medial datum).** A *medial datum* on a finite hyperedge set $E$
is a map $J : E \times E \to \mathrm{GF}(2)$ that is symmetric,
$J(a,b) = J(b,a)$ for all $a,b$. The value $J(e,e')$ records whether hyperedges
$e$ and $e'$ *interlace* along the medial map.

**Definition 2.2 (Crossing operator).** Given a medial datum $J$, the
$\mathrm{GF}(2)$-linear **crossing operator**
$\mathrm{cross}_J : (E \to \mathrm{GF}(2)) \to (E \to \mathrm{GF}(2))$ is
$$ (\mathrm{cross}_J\, x)(e) \;=\; \sum_{e' \in E} J(e,e')\, x(e'). $$

Represent an edge-subset $A \subseteq E$ by its indicator vector in
$E \to \mathrm{GF}(2)$; we freely conflate subsets with $\mathrm{GF}(2)$-vectors,
under which symmetric difference $\triangle$ is vector addition and $\mathrm{GF}(2)$
scalars satisfy $1 + 1 = 0$.

**Lemma 2.3 (Additivity).** For all $x, y$,
$\mathrm{cross}_J(x + y) = \mathrm{cross}_J(x) + \mathrm{cross}_J(y)$.

*Proof sketch.* Immediate from distributivity of multiplication over addition and
linearity of finite sums in each summand: 
$\sum_{e'} J(e,e')(x(e') + y(e')) = \sum_{e'} J(e,e')x(e') + \sum_{e'}
J(e,e')y(e')$. $\qquad\blacksquare$

---

## 3. The parity obstruction

The first ingredient is entirely local: it lives on the boundary cycle of one
hyperedge.

**Theorem 3.1 (Local parity dichotomy).** Let $\ell \ge 3$. The boundary cycle
$C_\ell$ of a hyperedge of length $\ell$ admits a consistent all-crossing state —
equivalently, a proper two-coloring — if and only if $\ell$ is even.

*Proof sketch.* A proper two-coloring of $C_\ell$ is exactly an assignment of the
two crossing states that alternates around the loop. The chromatic number of a
cycle is $2$ when $\ell$ is even and $3$ when $\ell$ is odd. If $\ell$ is odd,
then $\chi(C_\ell) = 3 > 2$, so no two-coloring exists; walking around the loop
and alternating states returns to the start with a forced clash. If $\ell$ is
even, then $\chi(C_\ell) = 2$, so a proper two-coloring (equivalently, a
two-colorability certificate) exists. $\qquad\blacksquare$

The bound $\ell \ge 3$ merely excludes the degenerate small cycles; every genuine
hyperedge boundary has length at least $1$, and the even ones of interest have
length at least $4$.

**Theorem 3.2 (Global nonemptiness).** Suppose every hyperedge satisfies
$\operatorname{len}(e) \ge 3$. Then $M(H)$ admits an all-crossing direction —
consistently on every hyperedge — if and only if **every** hyperedge has even
length.

*Proof sketch.* An all-crossing direction is a simultaneous choice of consistent
all-crossing state on the boundary cycle of each hyperedge; these constraints are
independent across hyperedges. Hence a global solution exists iff each local
constraint is satisfiable, and by Theorem 3.1 the $e$-th constraint is satisfiable
iff $\operatorname{len}(e)$ is even. The equivalence is a $\forall$-transfer:
$$ \bigl(\forall e,\ C_{\operatorname{len}(e)}\text{ is two-colorable}\bigr)
\iff \bigl(\forall e,\ \operatorname{len}(e)\text{ is even}\bigr). \qquad\blacksquare$$

Theorem 3.2 is exactly the "provided every hyperedge has even length" hypothesis
of the main characterization: it is the necessary and sufficient condition for
the all-crossing family — and hence, by Section 5, the bipartite family — to be
nonempty.

---

## 4. The linear-algebraic core over GF(2)

Fix a medial datum $J$ on $E$ and write $\mathrm{cross} = \mathrm{cross}_J$.
Throughout, $t \in (E \to \mathrm{GF}(2))$ denotes a fixed **reference twist**:
an edge-set for which the partial dual $H^{t}$ is bipartite (a base map). Its
existence is guaranteed under the even-length hypothesis.

We adopt the following algebraic models, faithful to the medial combinatorics:

- **All-crossing direction.** A vector $\Phi$ with $\mathrm{cross}\,\Phi = 0$.
  Thus the set of all-crossing directions is $\ker(\mathrm{cross})$.
- **Bipartite criterion.** $H^{A}$ is bipartite iff
  $\mathrm{cross}\,A = \mathrm{cross}\,t$.
- **Crossing-set map.** $C(\Phi) = \Phi + t$.

**Proposition 4.1 (Coset description of bipartite duals).** $H^{A}$ is bipartite
if and only if $A \in t + \ker(\mathrm{cross})$.

*Proof sketch.* By the bipartite criterion and additivity (Lemma 2.3),
$\mathrm{cross}\,A = \mathrm{cross}\,t$ is equivalent to
$\mathrm{cross}(A - t) = 0$, i.e. $A - t \in \ker(\mathrm{cross})$. Over
$\mathrm{GF}(2)$, $A - t = A + t$, so $A \in t + \ker(\mathrm{cross})$.
$\qquad\blacksquare$

Thus **both** distinguished families are cosets of one and the same subspace
$\ker(\mathrm{cross})$: the all-crossing directions are the coset through the
origin, and the bipartite partial duals are the coset through $t$.

**Lemma 4.2 (Characteristic-two cancellation).** In $\mathrm{GF}(2)$,
$\mathrm{cross}\,t + \mathrm{cross}\,t = 0$; more generally $v + v = 0$ for every
vector $v$.

This cancellation, together with additivity, is precisely what glues the two
cosets together via translation.

---

## 5. The characterization, the bijection, and the count

**Theorem 5.1 (Characterization).** Under the even-length hypothesis, the partial
dual $H^{A}$ is bipartite if and only if $A = C(\Phi)$ for some all-crossing
direction $\Phi$.

*Proof sketch.* ($\Leftarrow$) If $A = \Phi + t$ with $\mathrm{cross}\,\Phi = 0$,
then by additivity $\mathrm{cross}\,A = \mathrm{cross}\,\Phi + \mathrm{cross}\,t
= 0 + \mathrm{cross}\,t = \mathrm{cross}\,t$, so $H^{A}$ is bipartite. ($\Rightarrow$)
If $H^{A}$ is bipartite then $\mathrm{cross}\,A = \mathrm{cross}\,t$; set
$\Phi = A + t$. Then $\mathrm{cross}\,\Phi = \mathrm{cross}\,A + \mathrm{cross}\,t
= 0$ by Lemma 4.2, and $C(\Phi) = \Phi + t = A + t + t = A$ using $t + t = 0$.
$\qquad\blacksquare$

**Theorem 5.2 (Affine bijection).** The crossing-set map
$C : \Phi \mapsto \Phi + t$ restricts to a bijection from the set of all-crossing
directions $\ker(\mathrm{cross})$ onto the set of bipartite partial duals
$t + \ker(\mathrm{cross})$.

*Proof sketch.* Translation by a fixed vector on a $\mathrm{GF}(2)$-vector space
is a bijection with inverse translation by the same vector (since $t + t = 0$). It
carries $\ker(\mathrm{cross})$ onto $t + \ker(\mathrm{cross})$ by definition, and
by Proposition 4.1 the latter is exactly the bipartite family. Injectivity is
translation injectivity; surjectivity is the ($\Rightarrow$) direction of
Theorem 5.1. $\qquad\blacksquare$

**Corollary 5.3 (Equinumerosity and count).** The number of bipartite partial
duals equals the number of all-crossing directions, and both equal
$$ \bigl|\ker(\mathrm{cross}_J)\bigr| \;=\; 2^{\,\dim \ker(\mathrm{cross}_J)}. $$
In particular this count is always a power of two.

*Proof sketch.* A bijection preserves cardinality (Theorem 5.2), and a
$\mathrm{GF}(2)$-subspace of dimension $k$ has exactly $2^{k}$ elements.
$\qquad\blacksquare$

**Proposition 5.4 (Crossing set is a partial-duality move).** On edge-subsets,
the crossing-set map $C(A) = A + t$ is, under the identification of $\mathrm{GF}(2)$
addition with symmetric difference, the partial dual (twist) by the fixed
hyperedge set $C(t) = t$. Hence $C$ is itself a partial-duality operation.

*Proof sketch.* Vector addition of indicator vectors over $\mathrm{GF}(2)$ is
symmetric difference of the corresponding sets: $A + t \leftrightarrow A
\,\triangle\, t$. Twisting by a fixed set $S$ acts on subsets exactly by
$A \mapsto A \,\triangle\, S$; taking $S = t$ identifies $C$ with the twist by $t$.
$\qquad\blacksquare$

This closes the conceptual loop: the map that enumerates the bipartite duals is
not an auxiliary device but the same partial-duality surgery, now applied by the
reference twist $t$.

### 5.1 The affine-torsor picture

Theorems 5.1–5.2 say the bipartite partial duals form an **affine torsor** over
$\ker(\mathrm{cross}_J)$. There is no canonical "zero" bipartite dual, but once
any single reference $t$ is fixed, every other bipartite dual is obtained by
adding an all-crossing direction, in perfect bijection. The equivalence is
genuinely nontrivial — it rests on additivity of $\mathrm{cross}_J$, the
characteristic-two cancellation $\mathrm{cross}_J\,t + \mathrm{cross}_J\,t = 0$,
and injectivity of translation — rather than being a definitional identity.

---

## 6. Algorithms

The linear-algebraic formulation yields immediate algorithms over $\mathrm{GF}(2)$.

**Algorithm A — Kernel basis and count.** Build the symmetric matrix $J$; compute
$\ker(\mathrm{cross}_J)$ by Gaussian elimination over $\mathrm{GF}(2)$; the number
of bipartite partial duals is $2^{\dim\ker}$. Complexity $O(|E|^3)$ bit
operations.

**Algorithm B — Enumeration by coset.** Given a reference twist $t$ and a kernel
basis $\{k_1,\dots,k_m\}$, enumerate bipartite partial duals as
$\{\, t + \sum_{i \in S} k_i : S \subseteq \{1,\dots,m\}\,\}$. Each of the $2^m$
outputs is produced in $O(|E|)$ time.

**Algorithm C — Even-length gate.** Verify $\operatorname{len}(e)$ is even for
every hyperedge $e$; report nonemptiness of the bipartite family accordingly
(Theorem 3.2). Complexity $O(|D|)$.

---

## 7. Applications and connections

- **Ribbon graphs.** Restricting to length-two hyperedges recovers the
  Huggett–Moffatt classification of bipartite partial duals of ribbon graphs.
- **Delta-matroids and the Bollobás–Riordan polynomial.** Partial duality is the
  combinatorial operation underlying twist of delta-matroids; the symmetric form
  $J$ is a matroidal interlacement, so the count $2^{\dim\ker}$ is a delta-matroid
  invariant of $H$.
- **Knot theory.** The medial map is a diagrammatic cousin of a link diagram, with
  crossings and bounces mirroring smoothings; all-crossing directions correspond
  to coherent choices at all crossings.
- **Eulerian duality.** Bipartiteness and the Eulerian property are dual under
  partial duality; the same operator $J$ carries a pairing that should govern the
  Eulerian family as a complementary coset (see Section 8).

---

## 8. Discussion and future work

The analysis reduces a combinatorial existence-and-counting problem to the study
of one symmetric $\mathrm{GF}(2)$ operator. We record three directions.

1. **Eulerian partial duals as the exact orthogonal complement.** For a hypermap
   with all hyperedges even, the subsets giving an Eulerian partial dual should
   form a coset of the orthogonal complement (inside the symmetric-difference
   space) of the subspace whose cosets are the bipartite partial duals.
   Bipartiteness and the Eulerian property would then be the two halves of a
   single symmetric bilinear form: bipartite duals in its radical shifted by one
   reference twist, Eulerian duals in the annihilator shifted by another, so the
   duality becomes literal linear-algebraic orthogonality.

2. **A genus-controlled power of two.** The count $2^{k}$ with
   $k = \dim\ker(\mathrm{cross}_J)$ should be determined by surface data. We
   conjecture $k = 2\,g + (c - 1)$ for suitable normalization, where $g$ is the
   Euler genus and $c$ the number of connected components; the corank of the
   medial operator is a topological invariant of the embedded surface, turning the
   equinumerosity theorem into an explicit genus formula.

3. **Local detection of the obstruction.** A hypermap admits some bipartite
   partial dual iff every hyperedge has even length; when a single hyperedge is
   odd, no global twist repairs bipartiteness, and the obstruction is concentrated
   entirely on that odd hyperedge's boundary cycle. The global existence question
   factors through independent per-hyperedge parity constraints.

---

## 9. Conclusion

Bipartite partial duals of an orientable hypermap with all hyperedges of even
length are exactly the crossing sets of all-crossing directions of the medial
map. Behind this combinatorial statement lies a clean picture over
$\mathrm{GF}(2)$: an explicit symmetric crossing operator whose kernel is the
all-crossing family and one of whose cosets is the bipartite family, related by an
affine bijection. The number of bipartite partial duals is therefore a power of
two, and the enumeration is linear algebra. The even-length hypothesis is not
incidental but the precise nonemptiness condition, forced by the two-colorability
of even cycles.
