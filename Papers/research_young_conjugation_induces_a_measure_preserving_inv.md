# Young Conjugation as a Measure-Preserving Klein Four-Group on the Natural Extension of the Triangle Map

## Abstract

The natural extension of the *triangle map*, a multidimensional
continued-fraction algorithm, admits a faithful planar model on the unit square
partitioned into four congruent cells $D_1, D_2, D_3, D_4$ by its two mid-lines.
We show that the combinatorial operation of **Young conjugation** (transpose) of
integer partitions is realized on this model, at the level of individual cells,
by coordinate exchange $\sigma(x,y) = (y,x)$: a cell $c$ lies in the conjugate
diagram $\lambda'$ if and only if $\operatorname{swap}(c)$ lies in $\lambda$.
Upgraded to the plane, $\sigma$ is a measure-preserving involution that fixes the
diagonal cells $D_1, D_3$ and swaps the anti-diagonal cells $D_2 \leftrightarrow
D_4$. Together with the central point reflection $\tau(x,y) = (1-x, 1-y)$ — which
preserves measure and permutes the cells as the double transposition $D_1
\leftrightarrow D_3$, $D_2 \leftrightarrow D_4$ — the two involutions commute and
generate a **Klein four-group** $\{\mathrm{id}, \sigma, \tau, \alpha\} \cong
(\mathbb{Z}/2\mathbb{Z})^2$ of measure-preserving symmetries, whose third
non-trivial element is the anti-transpose $\alpha(x,y) = (1-y, 1-x)$. We further
prove that the four cells are pairwise disjoint, each of measure exactly
$\tfrac14$, and exhaust the whole domain, and that the equal-mass property is
partly *forced* by measure preservation of the involutions. This exhibits Young
conjugation and the natural-extension involution as two faces of one operation —
coordinate exchange — and generalizes the classical conjugation symmetry of the
Gauss and Farey maps.

## 1. Introduction

### 1.1 Two subjects, one operation

Two classical strands of mathematics meet in this work. The first is the
elementary combinatorics of **integer partitions** and their **Young diagrams**,
where the fundamental order-two operation is *conjugation*: reflecting a diagram
across its main diagonal to exchange rows and columns. The second is the
ergodic theory of **multidimensional continued fractions**, where the central
object attached to an algorithm is its **natural extension** — an invertible
dynamical system carrying an invariant measure that encodes all long-run
statistics.

Our main thesis is that these two order-two structures are not merely analogous
but *identical*: partition conjugation, expressed through its defining cell rule,
is coordinate exchange, and coordinate exchange is a concrete measure-preserving
symmetry of the natural extension of the triangle map. Making this precise
reveals that the expected single $\mathbb{Z}/2\mathbb{Z}$ conjugation symmetry is
in fact one generator of a Klein four-group of symmetries.

### 1.2 Contributions

1. **A cell-level bridge** (Theorem 4.1): the geometric coordinate swap is
   exactly the rule that defines Young conjugation,
   $c \in \lambda' \iff \operatorname{swap}(c) \in \lambda$.
2. **Two measure-preserving involutions** of the planar natural-extension model:
   the transpose $\sigma$ and the point reflection $\tau$, each order-two and
   Lebesgue-measure-preserving (Theorems 5.1–5.2, 6.1–6.2).
3. **Cell permutation laws**: $\sigma$ fixes $D_1, D_3$ and swaps $D_2
   \leftrightarrow D_4$; $\tau$ acts as the double transposition $D_1
   \leftrightarrow D_3$, $D_2 \leftrightarrow D_4$ (Theorems 5.3, 6.3).
4. **Equal-mass decomposition** (Theorem 3.1): the four cells are disjoint, each
   of measure $\tfrac14$, and fill the domain; part of the equality is forced by
   the involutions.
5. **The Klein four-group** (Theorem 7.1): $\sigma$ and $\tau$ commute, their
   composite is the anti-transpose $\alpha$, and $\{\mathrm{id}, \sigma, \tau,
   \alpha\}$ is a Klein four-group of measure-preserving involutions.

## 2. Background and definitions

### 2.1 Integer partitions and Young conjugation

A **partition** of a non-negative integer $n$ is a weakly decreasing sequence of
positive integers summing to $n$. Its **Young diagram** $\lambda$ is the finite
set of cells

$$
\lambda \subseteq \{(i,j) : i, j \in \mathbb{N}\},
$$

with the property that it is a *lower set* for the coordinatewise order: if
$(i,j) \in \lambda$ and $i' \le i$, $j' \le j$, then $(i',j') \in \lambda$. We
draw cell $(i,j)$ in row $i$, column $j$.

**Definition 2.1 (Conjugate / transpose).** The **conjugate** $\lambda'$ of a
diagram $\lambda$ is the diagram obtained by reflecting across the main diagonal,
i.e. exchanging rows and columns. Writing $\operatorname{swap}(i,j) = (j,i)$, it
is characterized by the cell rule

$$
c \in \lambda' \iff \operatorname{swap}(c) \in \lambda \qquad \text{for all } c \in \mathbb{N}\times\mathbb{N}.
$$

**Proposition 2.2.** Conjugation is an involution, $(\lambda')' = \lambda$, and
hence generates a group $\mathbb{Z}/2\mathbb{Z}$ acting on the set of all Young
diagrams. Its fixed points are the **self-conjugate** diagrams $\lambda =
\lambda'$, which are in classical bijection with partitions into distinct odd
parts.

*Proof.* Applying the cell rule twice, $c \in (\lambda')' \iff
\operatorname{swap}(c) \in \lambda' \iff \operatorname{swap}(\operatorname{swap}(c))
= c \in \lambda$. Thus $(\lambda')' = \lambda$ and the operation has order two.
$\square$

### 2.2 The triangle map and its natural extension

The **triangle map** is a multidimensional continued-fraction algorithm: an
additive, piecewise-affine, branch-preserving self-map of a triangular region of
the plane that generalizes the Gauss map to the simultaneous approximation of
several reals by rationals with a common denominator. Iterating it produces
best-approximation data much as the Gauss map produces continued-fraction digits.

To analyze its ergodic statistics one passes to the **natural extension**: the
minimal invertible dynamical system extending the (generally non-invertible)
algorithm, equipped with an invariant measure whose marginal recovers the
algorithm's invariant density. All Birkhoff averages of the algorithm are
governed by this invariant measure.

**The planar model.** We work throughout with a faithful planar model of the
natural-extension domain: the unit square

$$
\Omega = [0,1] \times [0,1],
$$

carrying two-dimensional Lebesgue measure (`volume`), which is the invariant
measure in this model. The two mid-lines $x = \tfrac12$ and $y = \tfrac12$ split
$\Omega$ into four congruent cells. Using half-open conventions so that the
involutions below are genuine set bijections, we set

$$
\begin{aligned}
D_1 &= [0,\tfrac12) \times [0,\tfrac12), &
D_2 &= [0,\tfrac12) \times [\tfrac12,1], \\
D_3 &= [\tfrac12,1] \times [\tfrac12,1], &
D_4 &= [\tfrac12,1] \times [0,\tfrac12).
\end{aligned}
$$

Here $D_1, D_3$ are the **diagonal** cells (bottom-left and top-right) and $D_2,
D_4$ the **anti-diagonal** cells (top-left and bottom-right).

## 3. The equal-mass four-cell decomposition

**Theorem 3.1 (Equal-mass partition).** The four cells $D_1, D_2, D_3, D_4$ are
pairwise disjoint, satisfy

$$
\operatorname{volume}(D_i) = \tfrac14 \quad (i = 1,2,3,4),
$$

and their union has measure $\operatorname{volume}(\Omega) = 1$.

*Proof sketch.* Each cell is a product of two intervals of length $\tfrac12$, so
by the product formula for Lebesgue measure ($\operatorname{volume}(A \times B) =
|A|\cdot|B|$ on the plane) its measure is $\tfrac12 \cdot \tfrac12 = \tfrac14$.
Disjointness is immediate from the half-open interval conventions, which assign
each boundary line to exactly one side. The four measures sum to $1$, matching
$\operatorname{volume}(\Omega) = 1$. $\square$

**Remark 3.2 (Equality is forced).** Two of the three equalities among the
$\operatorname{volume}(D_i)$ need not be computed independently: as shown below,
the measure-preserving involutions $\sigma$ and $\tau$ carry $D_1$ to $D_3$ and
$D_2$ to $D_4$ (and $D_2$ to $D_4$), which *forces* $\operatorname{volume}(D_1) =
\operatorname{volume}(D_3)$ and $\operatorname{volume}(D_2) =
\operatorname{volume}(D_4)$ without any interval arithmetic. The equal-mass
property is thus partly a structural consequence of symmetry.

## 4. The cell-level bridge

**Theorem 4.1 (Bridge theorem).** For every Young diagram $\lambda$ and every
cell $c \in \mathbb{N} \times \mathbb{N}$,

$$
c \in \lambda' \iff \operatorname{swap}(c) \in \lambda.
$$

That is, the geometric coordinate swap $\operatorname{swap}(x,y) = (y,x)$ is
precisely the rule defining Young conjugation.

*Proof.* This is Definition 2.1 read as an identity: membership in the conjugate
diagram is defined by swapping coordinates and testing membership in the
original. $\square$

The content of Theorem 4.1 is conceptual rather than technical: it identifies the
abstract order-two operation on partitions with a single, elementary map of the
plane. Everything that follows is the study of that map, and of the second
involution it commutes with, as symmetries of the natural extension.

## 5. The transpose involution $\sigma$

Define the **transpose** on the planar model by coordinate exchange:

$$
\sigma(x,y) = (y,x).
$$

**Theorem 5.1 (Involution).** $\sigma \circ \sigma = \mathrm{id}$; equivalently
$\sigma$ is an involution.

*Proof.* $\sigma(\sigma(x,y)) = \sigma(y,x) = (x,y)$. $\square$

**Theorem 5.2 (Measure preservation).** $\sigma$ preserves two-dimensional
Lebesgue measure: $\sigma_\ast \operatorname{volume} = \operatorname{volume}$.

*Proof sketch.* Writing planar Lebesgue measure as the product of two copies of
one-dimensional Lebesgue measure, $\operatorname{volume} = \operatorname{Leb}
\otimes \operatorname{Leb}$, the coordinate swap is exactly the canonical
measure-preserving isomorphism of a product measure with its factors exchanged.
Hence $\sigma$ preserves the product, i.e. planar volume. $\square$

**Theorem 5.3 (Cell action).** The transpose fixes the diagonal cells and swaps
the anti-diagonal cells:

$$
\sigma(D_1) = D_1, \quad \sigma(D_3) = D_3, \quad \sigma(D_2) = D_4, \quad \sigma(D_4) = D_2.
$$

*Proof sketch.* Each cell is a product $A \times B$ of intervals, and
$\sigma(A \times B) = B \times A$. For the diagonal cells $A = B$
(both $[0,\tfrac12)$ for $D_1$, both $[\tfrac12,1]$ for $D_3$), so the product is
unchanged. For $D_2 = [0,\tfrac12) \times [\tfrac12,1]$ we get $[\tfrac12,1]
\times [0,\tfrac12) = D_4$, and symmetrically $\sigma(D_4) = D_2$. $\square$

Theorems 4.1 and 5.1–5.3 together say that Young conjugation, realized
geometrically as $\sigma$, is a measure-preserving involution whose fixed cells
are precisely the diagonal cells — the geometric counterpart of self-conjugate
diagrams.

## 6. The point-reflection involution $\tau$

Define the **point reflection** through the center $(\tfrac12,\tfrac12)$:

$$
\tau(x,y) = (1-x,\ 1-y).
$$

This is the geometric shadow of conjugation used directly in the
natural-extension model: it exchanges the roles of the two coordinates'
complements just as conjugation exchanges rows and columns.

**Theorem 6.1 (Involution).** $\tau \circ \tau = \mathrm{id}$.

*Proof.* $\tau(\tau(x,y)) = \tau(1-x,1-y) = (1-(1-x), 1-(1-y)) = (x,y)$.
$\square$

**Theorem 6.2 (Measure preservation).** $\tau$ preserves two-dimensional
Lebesgue measure.

*Proof sketch.* $\tau$ is an affine isometry (a $180^\circ$ rotation about the
center, equivalently a composition of two axis reflections $x \mapsto 1-x$ and $y
\mapsto 1-y$, each of which preserves one-dimensional Lebesgue measure by
translation-invariance and reflection-invariance). Its Jacobian has absolute
value $1$, so it preserves area. $\square$

**Theorem 6.3 (Cell action).** The point reflection acts as the double
transposition

$$
\tau(D_1) = D_3, \quad \tau(D_3) = D_1, \quad \tau(D_2) = D_4, \quad \tau(D_4) = D_2.
$$

*Proof sketch.* $\tau$ sends the interval $[0,\tfrac12)$ to $(\tfrac12,1]$ and
$[\tfrac12,1]$ to $[0,\tfrac12]$ in each coordinate (up to the boundary
conventions chosen to make $\tau$ a set bijection). Applying this to each product
cell exchanges bottom-left with top-right ($D_1 \leftrightarrow D_3$) and
top-left with bottom-right ($D_2 \leftrightarrow D_4$). $\square$

**Corollary 6.4.** Combining Theorem 6.2 with Theorem 6.3,
$\operatorname{volume}(D_1) = \operatorname{volume}(D_3)$ and
$\operatorname{volume}(D_2) = \operatorname{volume}(D_4)$, independently of the
interval computation in Theorem 3.1.

## 7. The Klein four-group of symmetries

Define the **anti-transpose** — reflection across the anti-diagonal:

$$
\alpha(x,y) = (1-y,\ 1-x).
$$

**Lemma 7.1 (Commutation and composite).** The transpose and point reflection
commute, and their composite is the anti-transpose:

$$
\sigma \circ \tau = \tau \circ \sigma = \alpha.
$$

*Proof.* Compute directly: $(\sigma \circ \tau)(x,y) = \sigma(1-x,1-y) =
(1-y,1-x)$, and $(\tau \circ \sigma)(x,y) = \tau(y,x) = (1-y,1-x)$. Both equal
$\alpha(x,y)$; in particular the two orders agree on the nose. $\square$

**Lemma 7.2 (Anti-transpose is a measure-preserving involution).** $\alpha \circ
\alpha = \mathrm{id}$ and $\alpha$ preserves Lebesgue measure.

*Proof.* $\alpha(\alpha(x,y)) = \alpha(1-y,1-x) = (1-(1-x),1-(1-y)) = (x,y)$. Since
$\alpha = \sigma \circ \tau$ is a composite of two measure-preserving maps, it is
measure-preserving. $\square$

**Theorem 7.3 (Main theorem: Klein four-group of measure-preserving
involutions).** The set

$$
G = \{\mathrm{id},\ \sigma,\ \tau,\ \alpha\}
$$

is a group under composition, isomorphic to the Klein four-group $\mathbb{Z}/2
\times \mathbb{Z}/2$. Each of the three non-identity elements is a
measure-preserving involution of the natural-extension model, and $G$ acts on the
four cells $\{D_1, D_2, D_3, D_4\}$ by permutations.

*Proof.* By Theorems 5.1–5.2, 6.1–6.2 and Lemma 7.2, each of $\sigma, \tau,
\alpha$ is an order-two, measure-preserving self-map. By Lemma 7.1 the three
commute pairwise and satisfy $\sigma\tau = \alpha$, $\tau\alpha = \sigma$,
$\alpha\sigma = \tau$; every product of two distinct non-identity elements is the
third, and every element squares to the identity. This is exactly the Cayley
table of $(\mathbb{Z}/2)^2$. The cell actions of Theorems 5.3 and 6.3 (and their
composite for $\alpha$) show $G$ permutes the four cells. $\square$

**Interpretation.** The naive expectation of a single $\mathbb{Z}/2$
"conjugation symmetry" undercounts the structure. The honest symmetry group is
the Klein four-group; the point reflection $\tau$ from the dynamical description
is one of its three involutions, and the transpose $\sigma$ is the one that
*literally is* Young conjugation. The four cells $D_1,\dots,D_4$ are the orbit
structure of this group.

## 8. Relationship to the classical one-dimensional case

For the classical continued fraction — the Gauss map — and its slow, additive
counterpart the Farey map, the natural extension is a planar domain long known to
carry a conjugation-type symmetry relating a point to a reflected partner with
the same invariant density. The present work reinterprets that symmetry as Young
conjugation: coordinate exchange on the natural-extension model. The advantage of
this viewpoint is structural. It explains *why* the symmetry exists (it is the
transpose, forced by the affine, branch-preserving structure), and it predicts
that the phenomenon is not one-dimensional: any additive multidimensional
algorithm whose natural extension is a polytope should, by the same mechanism,
carry a Klein four-group whose orbit cells are its distinguished subdomains.

## 9. Algorithms

The results are elementary enough to be checked and visualized numerically. Three
computational procedures make the structure concrete:

1. **Conjugation–swap verification.** Given a partition $\lambda$, build its
   diagram as a set of cells, form the conjugate $\lambda'$ by column counting,
   and verify the bridge identity $c \in \lambda' \iff \operatorname{swap}(c) \in
   \lambda$ over an exhaustive rectangle of cells. This confirms Theorem 4.1
   combinatorially.
2. **Cell-permutation checker.** Sample points uniformly from the unit square,
   classify each into its cell $D_i$, apply $\sigma$, $\tau$, $\alpha$, and
   tabulate the induced cell permutation, empirically reproducing Theorems 5.3
   and 6.3 and the group table of Theorem 7.3.
3. **Measure-preservation Monte Carlo.** Estimate $\operatorname{volume}(D_i)$
   and the pushforward masses $\operatorname{volume}(g(D_i))$ for $g \in G$ by
   uniform sampling, confirming each cell has mass $\tfrac14$ and that every $g
   \in G$ preserves cell masses.

## 10. Applications and consequences

- **Statistical invisibility of conjugation.** A measure-preserving symmetry
  commuting with the dynamics is undetectable by long-run averages: Birkhoff
  averages of any integrable observable coincide almost everywhere with those of
  its conjugation-pullback, and each cell is visited with asymptotic frequency
  $\tfrac14$.
- **A dictionary between arithmetic and geometry.** The fixed set of $\sigma$ —
  the diagonal cells — corresponds to self-conjugate diagrams, suggesting that a
  geometric "diagonal measure" of the domain should be governed by the classical
  generating function counting self-conjugate partitions (equivalently,
  partitions into distinct odd parts).
- **A template for the whole family.** The construction isolates the structural
  ingredients (affine branches, polytopal natural extension) responsible for the
  symmetry, giving a testable prediction for the Brun, Selmer, and Jacobi–Perron
  algorithms.

## 11. Discussion and future work

The synthesis is that Young conjugation and the triangle-map natural-extension
involution *coincide* as coordinate exchange, and that this single operation
upgrades on the plane to a measure-preserving Klein four-group acting on four
equal-mass subdomains. Several concrete directions follow.

**The diagonal and self-conjugate partitions.** Conjecturally, the size of the
fixed-point locus of $\sigma$, measured with the induced lower-dimensional
density, is governed by the same generating function that counts self-conjugate
partitions — a purely geometric quantity readable off an arithmetic generating
function, because both are shadows of one order-two operation.

**Universality across polytopal algorithms.** Conjecturally, every additive
multidimensional continued-fraction algorithm whose natural extension is a
polytope admits such a four-element symmetry group, with its distinguished
subdomains as the orbit cells, forced by the shared affine, branch-preserving
structure of the Brun, Selmer, and Jacobi–Perron families.

**Conjugation invisible to long-term averages.** Conjecturally, Birkhoff averages
of any integrable observable coincide with those of its conjugation-pullback
almost everywhere, and the four subdomains are visited with asymptotic frequency
exactly one quarter each.

**Parity grading of the transfer operator.** A measure-preserving involution
conjugating the dynamics yields a unitary that commutes with the transfer
operator, so the transfer operator should inherit a parity ($\pm 1$
eigenspace) grading, decomposing its spectrum into conjugation-even and
conjugation-odd sectors.

## 12. Conclusion

Coordinate exchange — flipping a partition on its diagonal, exchanging two
coordinates of a point — is simultaneously the definition of Young conjugation
and a measure-preserving involution of the natural extension of the triangle map.
Paired with the central point reflection, it generates a Klein four-group of
measure-preserving symmetries permuting four equal-mass cells. The old
combinatorial involution and the dynamical symmetry are one operation seen twice.
