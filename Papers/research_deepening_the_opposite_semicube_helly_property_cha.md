# Harmonic-Even Balance and the Opposite-Semicube Helly Property: A Local, Multiplicative, and Parity-Constrained Invariant of Partial Cubes

## Abstract

A partial cube is a graph that embeds isometrically into a hypercube; in the
coordinate model its vertices are sign vectors and each coordinate ($\Theta$-class)
partitions the vertex set into two *opposite semicubes*. We study a single
structural invariant, **harmonic-evenness**: the requirement that every coordinate
splits the vertex set into two equinumerous opposite semicubes. We prove that
harmonic-evenness is equivalent to the **opposite-semicube Helly property**, the
matching (transversal) condition asserting that each cut admits a bijection between
its two sides. We then establish four structural facts about this invariant. First,
it is realized *canonically* by the antipodal involution whenever the vertex set is
closed under coordinatewise complementation, yielding an explicit involutive
matching and, as a corollary, the harmonic-evenness of the full hypercube. Second,
it imposes a **parity obstruction**: a harmonic-even vertex set over a nonempty
coordinate space has even cardinality, so odd sets (in particular singletons) are
never harmonic-even. Third, and centrally, it is **multiplicative across arbitrary
finite Cartesian products**: the product of a finite family of nonempty partial
cubes is harmonic-even if and only if every factor is, whence the product satisfies
the opposite-semicube Helly property if and only if every factor is harmonic-even.
The classical two-factor statement is the special case of a two-element index. The
engine of the product law is an exact cardinality formula for the semicubes of a
family product, obtained through a merge map onto the disjoint-union coordinate set
and cancellation of a positive product of factor sizes.

**Keywords.** partial cube, semicube, $\Theta$-class, Helly property, harmonic-even
balance, antipodal involution, Cartesian product, parity, matching.

---

## 1. Introduction

### 1.1 Partial cubes and their cuts

The $n$-dimensional hypercube $Q_n$ has vertex set $\{0,1\}^n$ with edges joining
vertices that differ in exactly one coordinate; its graph distance is the Hamming
distance. A **partial cube** is a connected graph admitting an isometric embedding
into some hypercube: distances in the graph coincide with Hamming distances of the
images. Partial cubes form one of the most studied classes of metric graphs, with
incarnations across discrete geometry (regions of hyperplane and pseudoline
arrangements), order theory (linear extensions and the Boolean lattice), theoretical
computer science (state spaces of chip-firing and other tokenization games), and
mathematical psychology (media theory).

We work throughout in the **coordinate model**. Fix a finite coordinate set
$\alpha$. A *sign vector* is a function $v : \alpha \to \{{\tt true}, {\tt false}\}$,
i.e. a vertex of the hypercube on $\alpha$. A finite family of vertices is a finite
set $V \subseteq \{{\tt true},{\tt false}\}^{\alpha}$. This is the correct level of
generality for the questions of this paper: all our invariants depend only on the
vertex set together with its coordinatewise structure.

Each coordinate $i \in \alpha$ induces a **cut**: it separates $V$ into two
**opposite semicubes**,
$$
S_i^{{\tt true}}(V) = \{ v \in V : v_i = {\tt true} \}, \qquad
S_i^{{\tt false}}(V) = \{ v \in V : v_i = {\tt false} \}.
$$
In the classical Djoković–Winkler theory these cuts are the $\Theta$-classes of the
graph, and the two semicubes are the two halfspaces they bound. The collection of
all cuts encodes the entire combinatorial geometry of a partial cube.

### 1.2 The invariant

**Definition (balanced coordinate; harmonic-even).** A coordinate $i$ is
*balanced* in $V$ if its opposite semicubes are equinumerous,
$$
\bigl| S_i^{{\tt true}}(V) \bigr| = \bigl| S_i^{{\tt false}}(V) \bigr|.
$$
The set $V$ is **harmonic-even** if every coordinate is balanced.

The terminology reflects the discrete analogy with the mean-value (harmonic)
property: harmonic-evenness is the statement that every cut halves the total mass,
a symmetric-averaging condition on the vertex distribution.

**Definition (opposite-semicube Helly property).** $V$ satisfies the
*opposite-semicube Helly property* if for every coordinate $i$ there is a bijection
$$
S_i^{{\tt true}}(V) \;\simeq\; S_i^{{\tt false}}(V),
$$
i.e. every cut admits a matching between its two sides. This is a Hall/transversal-
type condition of the sort that governs Helly properties in partial cubes in the
sense of Polat.

### 1.3 Contributions

This paper develops the theory of harmonic-evenness along four axes and proves the
following, all in the coordinate model above.

1. **Equivalence (Theorem 3.1).** The opposite-semicube Helly property is
   equivalent to harmonic-evenness.
2. **Canonical realization (Theorem 4.3).** Antipodal closure implies
   harmonic-evenness, with the antipodal involution as an explicit matching; in
   particular the full hypercube is harmonic-even (Corollary 4.5).
3. **Parity (Theorem 5.1).** Over a nonempty coordinate set, harmonic-evenness
   forces an even vertex count; singletons are never harmonic-even (Corollary 5.2).
4. **Finite-family product law (Theorems 6.4 and 6.5).** For a finite family of
   nonempty partial cubes, the Cartesian product is harmonic-even iff every factor
   is, and hence satisfies the opposite-semicube Helly property iff every factor is
   harmonic-even. The two-factor case recovers the classical statement.

Taken together, harmonic-evenness emerges as an invariant that is simultaneously
*local* (decided coordinate-by-coordinate), *matchable* (equivalent to a
transversal condition), *parity-constraining*, and *multiplicative across products*
— and canonically witnessed by symmetry whenever symmetry is present.

---

## 2. Preliminaries and notation

Throughout, $\alpha$ is a finite coordinate set and $V \subseteq
\{{\tt true},{\tt false}\}^{\alpha}$ is finite. We write $S_i^b(V)$ for the
semicube of coordinate $i$ with sign $b \in \{{\tt true},{\tt false}\}$, defined by
filtering $V$ on the predicate $v_i = b$. All cardinalities are finite. We use the
elementary facts that (i) two finite sets admit a bijection iff they have equal
cardinality, and (ii) a finite set partitions into the two fibers of any
two-valued function on it, so
$$
|V| = \bigl| S_i^{{\tt true}}(V) \bigr| + \bigl| S_i^{{\tt false}}(V) \bigr|
\qquad \text{for every } i. \tag{2.1}
$$

---

## 3. The matching–balance equivalence

**Theorem 3.1 (Matching–Balance Equivalence).** For any finite $V$,
$$
\text{$V$ satisfies the opposite-semicube Helly property} \iff \text{$V$ is
harmonic-even}.
$$

*Proof sketch.* Both directions rest on the finite-set principle that a bijection
between finite sets exists iff their cardinalities agree.

($\Rightarrow$) Given a bijection $S_i^{{\tt true}}(V) \simeq S_i^{{\tt false}}(V)$
for a coordinate $i$, transporting cardinalities across it yields
$|S_i^{{\tt true}}(V)| = |S_i^{{\tt false}}(V)|$, i.e. coordinate $i$ is balanced.
As $i$ was arbitrary, $V$ is harmonic-even.

($\Leftarrow$) If coordinate $i$ is balanced then its two semicubes have equal
cardinality, so a bijection between them exists (choose any equinumerous
correspondence). Doing this for every $i$ gives the Helly property. $\qquad\square$

Theorem 3.1 is the conceptual pivot of the paper: it lets us prove statements about
the (seemingly deep) matching property by reasoning about the (elementary) counting
property, and conversely lets us realize an abstract balance condition by an
explicit pairing.

---

## 4. A canonical matching from antipodal symmetry

Theorem 3.1 guarantees *existence* of a matching but produces no distinguished one.
Symmetry supplies a canonical choice.

**Definition 4.1 (antipode).** The *antipodal involution* on sign vectors is the
coordinatewise complement
$$
(\mathrm{antipode}\; v)_i = \lnot\, v_i .
$$
It satisfies $\mathrm{antipode}(\mathrm{antipode}\; v) = v$ and is injective.

**Definition 4.2 (antipodal closure).** $V$ is *antipodally closed* if
$v \in V \Rightarrow \mathrm{antipode}\; v \in V$.

**Lemma 4.2$'$ (semicube exchange).** If $V$ is antipodally closed then for every
coordinate $i$,
$$
S_i^{{\tt false}}(V) = \mathrm{antipode}\bigl( S_i^{{\tt true}}(V) \bigr),
$$
the antipode carrying each side of a cut bijectively onto the other.

*Proof sketch.* If $v_i = {\tt true}$ and $v \in V$, then $\mathrm{antipode}\; v \in
V$ (closure) and $(\mathrm{antipode}\; v)_i = {\tt false}$, so the antipode maps
$S_i^{{\tt true}}$ into $S_i^{{\tt false}}$; the involution property gives the reverse
inclusion. Both maps are restrictions of an injective involution. $\qquad\square$

**Theorem 4.3 (Canonical Mirror).** If $V$ is antipodally closed then $V$ is
harmonic-even, and the antipodal involution is an explicit fixed-point-free matching
of every cut.

*Proof sketch.* By Lemma 4.2$'$, $S_i^{{\tt false}}(V)$ is the injective image of
$S_i^{{\tt true}}(V)$ under the antipode, so the two semicubes have equal cardinality
(the image of an injective map preserves cardinality). Thus every coordinate is
balanced. The antipode is fixed-point-free because no sign vector equals its own
complement. $\qquad\square$

**Lemma 4.4.** The full hypercube $\{{\tt true},{\tt false}\}^{\alpha}$ is
antipodally closed.

**Corollary 4.5.** The full hypercube is harmonic-even: every cut halves it, matched
by the antipode.

Theorem 4.3 upgrades the abstract Helly property to a concrete, involutive system of
representatives, and does so without any nonemptiness hypothesis: the bijection is
built directly from the symmetry rather than inferred from a cardinality count.

---

## 5. Parity of the vertex count

**Theorem 5.1 (Parity Obstruction).** If $\alpha$ is nonempty and $V$ is
harmonic-even then $|V|$ is even.

*Proof sketch.* Choose any coordinate $i \in \alpha$. Balance gives
$|S_i^{{\tt true}}(V)| = |S_i^{{\tt false}}(V)|$, and the two-fiber decomposition
(2.1) gives $|V| = |S_i^{{\tt true}}(V)| + |S_i^{{\tt false}}(V)| = 2\,
|S_i^{{\tt true}}(V)|$, an even number. $\qquad\square$

**Corollary 5.2.** A singleton vertex set is never harmonic-even over a nonempty
coordinate set: its unique cut is maximally unbalanced (one side empty), and $1$ is
odd.

Theorem 5.1 furnishes an $O(1)$ *negative* certificate: any partial cube with an odd
number of vertices fails harmonic-evenness — hence fails the opposite-semicube Helly
property — without inspecting a single cut in detail.

---

## 6. The finite-family product law

### 6.1 The product construction

For an index type $\iota$ (finite) and, for each $k \in \iota$, a coordinate set
$\beta_k$ with a partial cube $V_k \subseteq \{{\tt true},{\tt false}\}^{\beta_k}$,
the **Cartesian product** lives on the disjoint-union coordinate set
$\Sigma_{k} \beta_k = \{ \langle k, i\rangle : k \in \iota,\ i \in \beta_k \}$.

**Definition 6.1 (merge map).** The merge map assembles a family of sign vectors
into a single sign vector on the disjoint union:
$$
\mathrm{merge}(f)\langle k, i\rangle = f_k(i), \qquad f = (f_k)_{k\in\iota},\
f_k : \beta_k \to \{{\tt true},{\tt false}\}.
$$
It is injective (a merged vector determines each component by restriction).

**Definition 6.2 (family product cube).** With $\prod_k V_k$ the set of families
$(f_k)$ with $f_k \in V_k$,
$$
\textstyle\prod^{\square}_k V_k \;=\; \mathrm{merge}\Bigl( \prod_k V_k \Bigr)
\;\subseteq\; \{{\tt true},{\tt false}\}^{\Sigma_k \beta_k}.
$$
A coordinate of the product is a pair $\langle k, i\rangle$ with $i$ a coordinate of
the factor $V_k$.

### 6.2 The semicube cardinality formula

The heart of the argument is an exact count of the product's semicubes.

**Lemma 6.3 (slice identity).** For a coordinate $\langle k, i\rangle$ and sign $c$,
restricting the product family to $f_k(i) = c$ replaces exactly the $k$-th factor by
its semicube:
$$
\Bigl\{ f \in \textstyle\prod_j V_j : f_k(i) = c \Bigr\}
= \prod_j V_j'\quad\text{where } V_k' = S_i^{c}(V_k),\ V_j' = V_j\ (j \neq k).
$$

**Lemma 6.3$'$ (product semicube cardinality).** For every $\langle k,i\rangle$ and
$c$,
$$
\Bigl| S_{\langle k,i\rangle}^{c}\bigl(\textstyle\prod^{\square}_j V_j\bigr) \Bigr|
= \bigl| S_i^{c}(V_k) \bigr| \cdot \prod_{j \neq k} |V_j| .
$$

*Proof sketch.* The semicube of $\langle k,i\rangle$ in the product is the merge
image of the slice in Lemma 6.3. Since the merge map is injective it preserves
cardinality, and the cardinality of a product of finite families is the product of
their cardinalities; isolating the $k$-th (now $S_i^c(V_k)$) from the untouched
remaining factors yields the displayed formula. $\qquad\square$

### 6.3 Multiplicativity

**Theorem 6.4 (Product Balance Law).** Let $(V_k)_{k\in\iota}$ be a finite family of
**nonempty** partial cubes. Then
$$
\textstyle\prod^{\square}_k V_k \text{ is harmonic-even} \iff \text{every } V_k
\text{ is harmonic-even.}
$$

*Proof sketch.* Fix a coordinate $\langle k, i\rangle$ of the product. By Lemma
6.3$'$, its balance equation reads
$$
|S_i^{{\tt true}}(V_k)| \cdot P = |S_i^{{\tt false}}(V_k)| \cdot P, \qquad
P := \prod_{j\neq k} |V_j|.
$$
Because every factor is nonempty, $P > 0$, so the equation is equivalent to
$|S_i^{{\tt true}}(V_k)| = |S_i^{{\tt false}}(V_k)|$, i.e. balance of coordinate $i$
in $V_k$. Ranging over all $\langle k,i\rangle$: the product is balanced at every
coordinate iff each factor is balanced at every coordinate. Nonemptiness is
load-bearing exactly at the cancellation of $P$. $\qquad\square$

**Theorem 6.5 (Product Helly Law).** For a finite family of nonempty partial cubes,
$$
\textstyle\prod^{\square}_k V_k \text{ satisfies the opposite-semicube Helly
property} \iff \text{every } V_k \text{ is harmonic-even.}
$$

*Proof.* Combine Theorem 3.1 (applied to the product) with Theorem 6.4. $\square$

**Corollary 6.6 (Binary case — the classical statement).** For nonempty partial
cubes $G_1, G_2$, the Cartesian product $G_1 \,\square\, G_2$ satisfies the
opposite-semicube Helly property if and only if both $G_1$ and $G_2$ are
harmonic-even. (Take $\iota$ a two-element index in Theorem 6.5.)

---

## 7. Algorithms

The theory is fully constructive and yields simple decision procedures. Let $N =
|V|$ and $d = |\alpha|$.

**(A) Harmonic-evenness / Helly test.** For each coordinate, count the two
semicubes and compare. Total work $O(Nd)$ after a single pass tallying, per
coordinate, how many vertices carry ${\tt true}$. By Theorem 3.1 the same procedure
decides the opposite-semicube Helly property.

**(B) Parity pre-filter.** Compute $N \bmod 2$. If $d \geq 1$ and $N$ is odd, output
"not harmonic-even" immediately (Theorem 5.1). Cost $O(1)$ after $N$ is known — a
cheap short-circuit before the $O(Nd)$ test.

**(C) Product balance via factors.** To test a product, apply (A) to each factor and
combine by Theorem 6.4, avoiding materialization of the product whose size is
$\prod_k |V_k|$. Cost $\sum_k O(|V_k|\,|\beta_k|)$ versus $O\!\bigl((\prod_k
|V_k|)(\sum_k|\beta_k|)\bigr)$ for the naive test — an exponential saving in the
number of factors.

**(D) Canonical matching extraction.** If $V$ is antipodally closed, output the
antipode as the explicit per-cut matching (Theorem 4.3); verifying closure costs
$O(Nd)$ with hashing.

---

## 8. Applications and examples

- **Full hypercubes and their symmetric subcubes.** By Corollary 4.5 every
  hypercube is harmonic-even; more generally any antipodally symmetric code (a set
  closed under complementation, e.g. a linear binary code) is harmonic-even with the
  antipode as canonical matching.
- **Even cycles.** The $2m$-cycle is a partial cube whose $m$ cuts each split it
  into two equal arcs; it is harmonic-even and antipodally closed, and its parity
  ($2m$ vertices) is consistent with Theorem 5.1.
- **Odd-vertex families are excluded for free.** Any partial cube with an odd vertex
  count — a single vertex, a path on an even number of edges (odd number of
  vertices), etc. — fails the Helly property by the parity pre-filter alone.
- **Hamming-graph products.** Products of harmonic-even factors (e.g. products of
  hypercubes and even cycles) are harmonic-even by Theorem 6.4, and their cuts are
  matched cut-by-cut through the factor matchings.

---

## 9. Discussion

The four theorems assemble a single invariant wearing several hats. Harmonic-
evenness is *local* (Theorem 3.1 reduces the global matching condition to a
per-coordinate count), *canonical under symmetry* (Theorem 4.3), *parity-obstructed*
(Theorem 5.1), and *multiplicative* (Theorems 6.4–6.5). The unifying mechanism is
that a single coordinate slice of a product is again a product with one factor
replaced by a semicube (Lemma 6.3); this "coordinate-locality of the product"
propagates every one-coordinate statement through the entire family, and the only
analytic input is the cancellation of a positive product of factor sizes, which is
precisely where nonemptiness is required.

It is worth noting what is *not* needed. The canonical-matching route (Theorem 4.3)
uses no nonemptiness because it builds the bijection directly from the antipode;
nonemptiness enters only in the cancellation step of the product law. And none of
the results are definitional: the product law requires genuine cancellation, the
parity result uses the two-block decomposition of a cut, and the antipodal matching
is a true fixed-point-free involution rather than a relabeling.

---

## 10. Future work

Several refinements sharpen each facet:

1. **An exact enumeration of cut-matchings.** Existence of matchings is
   multiplicative; one expects the *number* of coordinatewise systems of
   cut-representatives of a family product to factor as a product over the factors,
   each factor's contribution raised to the power given by the product of the
   remaining factor sizes. The merge-map cardinality calculus already supplies the
   bookkeeping to carry counts through the disjoint-union coordinate set.
2. **Antipodal closure as the exact obstruction to involutive matchings.** We expect
   that a balanced partial cube admits a single involution restricting to a
   fixed-point-free matching on every cut *if and only if* its vertex set is
   antipodally closed — separating "balanced" from "symmetrically balanced."
3. **Alphabet independence.** Over a $q$-symbol alphabet, calling a coordinate
   balanced when all $q$ fibers are equinumerous, the family-product balance law and
   its Helly reformulation should persist verbatim, with the two-sided matching
   replaced by a transitive family of bijections among the $q$ fibers and the parity
   obstruction strengthened to divisibility of the vertex count by $q$. The merge-map
   argument never uses that the alphabet is binary.

---

## 11. Conclusion

Harmonic-evenness — the demand that every cut halves the vertex set — is equivalent
to the opposite-semicube Helly property and is governed by a single balance
invariant that is coordinate-local, canonically realized by antipodal symmetry, a
parity obstruction on the vertex count, and multiplicative across arbitrary finite
Cartesian products. In particular, a Cartesian product of partial cubes satisfies
the opposite-semicube Helly property exactly when each of its factors is
harmonic-even, generalizing the classical two-factor characterization to arbitrary
finite families.
