# Gauge-Invariant Obstructions to Periodic Impossible Figures

**Aristotle**  
**19 July 2026**

## Abstract

Periodic impossible figures can be modeled by assigning horizontal and vertical increments to the edges of a finite grid with opposite sides identified. Such a field is developable when the increments are differences of a single-valued height function. This paper gives a self-contained classification over an arbitrary additive commutative coefficient group. The complete obstruction consists of local discrete curvature and two global periods around the fundamental cycles of the torus. A field is developable exactly when all three components vanish. Changing the local reference height adds a discrete gradient; we prove that curvature, both periods, and hence developability are invariant under every such gauge transformation. We give a constructive integration algorithm, linear-time decision procedures, explicit local and global counterexamples, and a uniformly descending periodic “waterfall” that remains impossible after a nonconstant checkerboard gauge change. We also distinguish periodic geometric staircases from the strictly descending filtration $2^k\mathbb Z$, whose intersection is zero but whose index set does not close into a cycle. The results identify the cohomological structure behind Escher-type staircases while clarifying why claims about Penrose figures in smooth manifolds require additional projection and depth-order semantics.

## 1. Introduction

Impossible staircases exploit a discrepancy between local and global perception. Every neighboring pair of steps can suggest a legitimate increase in height, while a complete circuit returns to the same visible location. A mathematical model should therefore answer three questions. What constitutes local consistency? Which global loops must be checked? Which features survive a change in the arbitrary reference used to label heights?

A periodic rectangular grid provides the simplest setting in which all three questions are nontrivial. Identifying opposite edges turns the grid into a discrete torus. Horizontal and vertical edge labels prescribe proposed increments in a coefficient group $A$. If they arise from a vertex potential, or height function, then the picture is developable. Otherwise it is impossible in the precise sense that no single-valued height assignment realizes all prescribed changes.

On a simply connected rectangular patch, vanishing circulation around every elementary tile is enough for integrability. On a torus it is not. Two noncontractible cycles remain: one winds horizontally and one vertically. Their accumulated increments are holonomies, or periods. Thus periodic impossibility has a local part, measured by curvature, and a global part, measured by two periods.

The principal theorem states that these are the only obstructions. The second principal theorem establishes gauge invariance: adding the gradient of any locally chosen reference function changes individual increments but changes neither curvature nor either period. The obstruction triple is therefore intrinsic to a gauge class rather than an artifact of labeling.

The development is entirely additive. Accordingly, the coefficients may lie in any additive commutative group, including $\mathbb Z$, $\mathbb R$, vector spaces, finite cyclic groups, and products of such groups. No order, metric, multiplication, or division is required.

## 2. Periodic grids and increment fields

Fix positive integers $m$ and $n$. Write

$$
T_{m,n}=\mathbb Z/m\mathbb Z\times\mathbb Z/n\mathbb Z
$$

for the vertices of the periodic grid. Let $A$ be an additive commutative group with identity $0$. All indices below are interpreted modulo $m$ or $n$.

### Definition 2.1 (Increment field)

An **increment field** is a pair of functions

$$
a,b:T_{m,n}\longrightarrow A.
$$

The value $a(i,j)$ labels the oriented edge from $(i,j)$ to $(i+1,j)$, and $b(i,j)$ labels the oriented edge from $(i,j)$ to $(i,j+1)$.

### Definition 2.2 (Discrete derivatives)

For a function $g:T_{m,n}\to A$, define its horizontal and vertical discrete derivatives by

$$
(\Delta_x g)(i,j)=g(i+1,j)-g(i,j),
$$

$$
(\Delta_y g)(i,j)=g(i,j+1)-g(i,j).
$$

The pair $(\Delta_x g,\Delta_y g)$ is the discrete gradient of $g$.

### Definition 2.3 (Developability)

The increment field $(a,b)$ is **developable** if there exists a height function $h:T_{m,n}\to A$ satisfying

$$
a=\Delta_x h,\qquad b=\Delta_y h.
$$

Thus every edge increment is the difference between the heights at its endpoint and start point.

Developability means more than the existence of a plausible local drawing. It demands one globally single-valued height on the periodic quotient.

## 3. Local curvature and global periods

### Definition 3.1 (Discrete curvature)

The curvature of $(a,b)$ at the elementary tile based at $(i,j)$ is

$$
C_{a,b}(i,j)
=a(i,j)+b(i+1,j)-a(i,j+1)-b(i,j).
$$

This is the oriented sum around the boundary of the tile: right, up, left, down. Equivalently,

$$
C_{a,b}=\Delta_x b-\Delta_y a.
$$

The sign convention is immaterial for vanishing, but fixing it clarifies calculations.

### Definition 3.2 (Fundamental periods)

Choose the row $j=0$ and column $i=0$. The horizontal and vertical periods are

$$
P_x(a)=\sum_{i=0}^{m-1}a(i,0),
$$

$$
P_y(b)=\sum_{j=0}^{n-1}b(0,j).
$$

These are the accumulated increments along representatives of the two fundamental cycles of the torus.

### Lemma 3.3 (Row and column independence under flatness)

If $C_{a,b}(i,j)=0$ for every $(i,j)$, then the sum of $a$ along a complete horizontal row is independent of the row, and the sum of $b$ along a complete vertical column is independent of the column.

**Proof sketch.** Sum the identity $C_{a,b}(i,j)=0$ over all $i$ in one row. The horizontal sum of $b(i+1,j)$ is a cyclic reindexing of the sum of $b(i,j)$, so those terms cancel. What remains says that the horizontal sum of $a$ in row $j$ equals that in row $j+1$. Repeating around the vertical direction proves row independence. Summing over $j$ instead proves column independence. $\square$

### Lemma 3.4 (Gradients are flat)

For every $h:T_{m,n}\to A$,

$$
C_{\Delta_x h,\Delta_y h}(i,j)=0
$$

at every tile.

**Proof sketch.** Expand the four edge differences. Each of the four vertex values appears once with positive sign and once with negative sign. This is the discrete equality of mixed derivatives. $\square$

### Lemma 3.5 (Gradient periods vanish)

For every $h:T_{m,n}\to A$,

$$
P_x(\Delta_x h)=0,\qquad P_y(\Delta_y h)=0.
$$

**Proof sketch.** The horizontal sum is

$$
\sum_{i=0}^{m-1}\bigl(h(i+1,0)-h(i,0)\bigr),
$$

which telescopes cyclically. The vertical sum is identical in form. Because opposite boundaries are identified, the terminal value is the initial value. $\square$

## 4. Complete classification of developability

### Theorem 4.1 (Periodic Developability Theorem)

Let $(a,b)$ be an increment field on $T_{m,n}$ with values in an additive commutative group $A$. The following are equivalent:

1. There exists $h:T_{m,n}\to A$ such that $a=\Delta_x h$ and $b=\Delta_y h$.
2. The curvature vanishes at every tile and both fundamental periods vanish:

$$
C_{a,b}=0,\qquad P_x(a)=0,\qquad P_y(b)=0.
$$

**Proof sketch.** If $(a,b)$ is a gradient, Lemmas 3.4 and 3.5 give all three vanishing conditions.

Conversely, fix the base vertex $(0,0)$ and set $h(0,0)=0$. For any vertex $v$, select an edge path from $(0,0)$ to $v$ and define $h(v)$ to be the signed sum of increments along that path. Reversing an edge contributes the negative of its forward label.

It remains to prove path independence. Given two paths to $v$, follow the first and then the reverse of the second; this produces a closed walk. Elementary insertion or deletion of a tile boundary changes its sum by a curvature value, hence by zero. After removing contractible tile boundaries, any closed walk on the toroidal grid reduces to an integer combination of a horizontal fundamental cycle and a vertical fundamental cycle. Its sum is therefore an integer combination of $P_x(a)$ and $P_y(b)$, both zero. The two path sums agree.

The resulting $h$ is well defined. Appending one horizontal edge to a path shows $h(i+1,j)-h(i,j)=a(i,j)$, and appending one vertical edge shows $h(i,j+1)-h(i,j)=b(i,j)$. Thus $(a,b)$ is developable. $\square$

### Corollary 4.2 (Complete obstruction triple)

Define

$$
\mathcal O(a,b)=\bigl(C_{a,b},P_x(a),P_y(b)\bigr).
$$

Then $(a,b)$ is developable if and only if

$$
\mathcal O(a,b)=(0,0,0).
$$

The curvature component is a function on all tiles, while the final two components lie in $A$.

### Corollary 4.3 (Two modes of impossibility)

Every nondevelopable periodic increment field has at least one of the following witnesses:

- a tile with nonzero curvature;
- a nonzero horizontal period;
- a nonzero vertical period.

The first witness is local. The latter two are global and may occur even when every elementary tile is consistent.

## 5. Gauge transformations

Height is relative. Replacing a local reference value by another should not alter whether a field is intrinsically consistent.

### Definition 5.1 (Gauge shift)

Given $g:T_{m,n}\to A$, the gauge shift of $(a,b)$ by $g$ is the field $(a^g,b^g)$ defined by

$$
a^g=a+\Delta_x g,
$$

$$
b^g=b+\Delta_y g.
$$

The added gradient changes each edge label according to the difference between local reference values at its endpoints.

### Theorem 5.2 (Curvature invariance)

For every increment field $(a,b)$ and every gauge function $g$,

$$
C_{a^g,b^g}=C_{a,b}.
$$

**Proof sketch.** Curvature is additive in the edge field, so

$$
C_{a^g,b^g}=C_{a,b}+C_{\Delta_x g,\Delta_y g}.
$$

The second term vanishes by Lemma 3.4. Direct expansion yields the same conclusion by pairwise cancellation of mixed differences. $\square$

### Theorem 5.3 (Period invariance)

For every increment field $(a,b)$ and every gauge function $g$,

$$
P_x(a^g)=P_x(a),\qquad P_y(b^g)=P_y(b).
$$

**Proof sketch.** Additivity of finite sums gives

$$
P_x(a^g)=P_x(a)+P_x(\Delta_x g).
$$

The gradient period is zero by Lemma 3.5. The vertical argument is identical. $\square$

### Theorem 5.4 (Gauge-Invariant Classification)

For every gauge function $g$, the shifted field $(a^g,b^g)$ is developable if and only if $(a,b)$ is developable. More explicitly,

$$
(a^g,b^g)\text{ is developable}
\quad\Longleftrightarrow\quad
C_{a,b}=0\ \text{and}\ P_x(a)=0\ \text{and}\ P_y(b)=0.
$$

**Proof sketch.** Theorems 5.2 and 5.3 show

$$
\mathcal O(a^g,b^g)=\mathcal O(a,b).
$$

Apply Theorem 4.1 to either field. $\square$

This result admits a second direct interpretation. If $(a,b)=(\Delta_x h,\Delta_y h)$, then

$$
(a^g,b^g)=(\Delta_x(h+g),\Delta_y(h+g)).
$$

Conversely, subtracting $g$ from a potential for the shifted field gives a potential for the original one. The obstruction proof is stronger conceptually because it identifies the gauge-invariant data that determine the answer.

## 6. Examples and boundary cases

### 6.1 A local defect

Let $A=\mathbb Z$ and consider any periodic grid with at least one tile. Set all increments to zero except one horizontal edge, whose value is $1$. At a tile incident to that edge, curvature is nonzero. The field is therefore nondevelopable, regardless of its periods. The contradiction is visible within a small neighborhood.

### 6.2 A flat but globally impossible waterfall

On a $3\times3$ torus over $\mathbb R$, define

$$
a(i,j)=-1,
\qquad
b(i,j)=0
$$

for all vertices. Every tile has curvature

$$
-1+0-(-1)-0=0.
$$

The vertical period is $0$, but the horizontal period is

$$
P_x(a)=(-1)+(-1)+(-1)=-3.
$$

Thus the field is locally consistent and globally impossible. A traveler moving right returns to the same vertex after three steps while accumulating a drop of three units.

Now apply the nonconstant checker gauge

$$
g(i,j)=i-j,
$$

where $i,j\in\{0,1,2\}$ denote the standard representatives and subtraction is taken in $\mathbb R$. The transformed edge values are no longer uniform because the representative jumps at the periodic boundary. Nevertheless, Theorems 5.2 and 5.3 give

$$
C_{a^g,b^g}=0,
\qquad
P_x(a^g)=-3,
\qquad
P_y(b^g)=0.
$$

No choice of this local reference makes the waterfall developable. In fact, Theorem 5.4 says that no gauge choice whatsoever can do so.

### 6.3 A developable nonconstant field

Choose any nonconstant periodic height $h:T_{m,n}\to A$ and set

$$
a=\Delta_x h,
\qquad
b=\Delta_y h.
$$

The resulting field may contain many nonzero increments, yet it has zero curvature and zero periods. For a concrete real-valued example on a $4\times3$ grid, let

$$
h(i,j)=i^2-2j
$$

using standard representatives. Its boundary increments include compensating jumps caused by periodic identification. Integrating the field reconstructs $h$ up to an additive constant.

### 6.4 Degenerate dimensions

The theorem remains valid when $m=1$ or $n=1$. A one-column or one-row torus contains loop edges, and the corresponding period remains essential. Positivity of $m$ and $n$ is required only so that the cyclic index sets are nonempty and the fundamental cycles are defined.

### 6.5 Arbitrary additive coefficients

Nothing in the proofs uses an order or norm. With $A=\mathbb Z/q\mathbb Z$, developability means consistency modulo $q$. With $A=\mathbb R^d$, each edge can encode a vector displacement, and the theorem applies componentwise. With a product group, several independent measurements can be checked simultaneously.

## 7. Algorithms

### Algorithm 7.1 (Obstruction computation)

Given arrays $a$ and $b$ of shape $m\times n$:

1. For every $(i,j)$, compute

$$
C(i,j)=a(i,j)+b(i+1,j)-a(i,j+1)-b(i,j).
$$

2. Compute

$$
P_x=\sum_{i=0}^{m-1}a(i,0),
\qquad
P_y=\sum_{j=0}^{n-1}b(0,j).
$$

3. Return $(C,P_x,P_y)$.

The algorithm uses $O(mn)$ group operations and stores $O(mn)$ values if the full curvature array is retained. If only the decision is needed, it can stop at the first nonzero curvature and use $O(1)$ auxiliary storage.

### Algorithm 7.2 (Developability decision)

Compute the obstruction triple. Return “developable” exactly when every curvature entry and both periods are zero. Correctness is precisely Theorem 4.1. The running time is $O(mn)$, which is optimal up to constants when all input labels may need inspection.

### Algorithm 7.3 (Potential reconstruction)

When the obstruction vanishes, fix $h(0,0)=0$. First integrate horizontally along row $0$:

$$
h(i+1,0)=h(i,0)+a(i,0).
$$

Then integrate vertically in each column:

$$
h(i,j+1)=h(i,j)+b(i,j).
$$

Finally verify all horizontal edges and periodic closing edges. Theorem 4.1 guarantees success; explicit verification is useful for finite-precision or noisy data. Reconstruction takes $O(mn)$ operations and $O(mn)$ output storage. Any two reconstructed potentials differ by an additive constant when the grid is connected.

### Algorithm 7.4 (Gauge-invariance audit)

Given $(a,b)$ and $g$, form $(a^g,b^g)$ and compute both obstruction triples. Equality is guaranteed mathematically and serves as a diagnostic in numerical software. Exact integer or rational arithmetic gives exact equality. Floating-point implementations should compare with a scale-aware tolerance because cancellation may introduce roundoff.

## 8. A distinct notion of infinite staircase

The phrase “endless staircase” also appears in algebra, but not every infinite descent is a periodic contradiction.

### Theorem 8.1 (Power-of-two filtration)

For each nonnegative integer $k$, let

$$
I_k=2^k\mathbb Z.
$$

Then the sequence is strictly descending,

$$
I_0\supsetneq I_1\supsetneq I_2\supsetneq\cdots,
$$

and its intersection is

$$
\bigcap_{k=0}^{\infty}I_k=\{0\}.
$$

**Proof sketch.** Inclusion $I_{k+1}\subseteq I_k$ follows from $2^{k+1}\mathbb Z\subseteq2^k\mathbb Z$. It is strict because $2^k\in I_k$ but $2^k\notin I_{k+1}$. If an integer $z$ lies in every $I_k$, then every power of two divides $z$. A nonzero integer has finite absolute value; choosing $k$ with $2^k>|z|$ makes such divisibility impossible. Hence $z=0$. $\square$

This theorem describes a filtration indexed by the nonnegative integers. It has a beginning and continues indefinitely; it does not identify a later level with an earlier one. A periodic geometric staircase, by contrast, is indexed around a closed cycle. Its impossibility is caused by nonzero additive holonomy on that cycle. The power-of-two filtration is therefore a boundary example that sharpens, rather than realizes, the Escher analogy.

## 9. Cohomological interpretation

The model is a discrete instance of cochain theory. Vertex functions are $0$-cochains, edge increments are $1$-cochains, and tile curvatures are $2$-cochains. The discrete gradient is the coboundary map from degree $0$ to degree $1$, while curvature is the next coboundary. The identity that gradients have zero curvature is the relation

$$
d^2=0.
$$

A zero-curvature field is closed. A developable field is exact. On a torus, closed need not imply exact because the first cohomology is nontrivial. The horizontal and vertical periods evaluate a closed field on generators of the two independent cycle directions. Their vanishing characterizes exactness.

Gauge transformations add exact $1$-cochains. Closed-loop periods do not change under such additions. Thus the obstruction triple packages the local coboundary and the global cohomology class. This viewpoint predicts the extension to more general finite cell complexes: test curvature on $2$-cells and periods on generators of the first homology.

## 10. Applications

### 10.1 Phase unwrapping

Sensors often observe phase modulo a fixed period. Neighboring phase differences can be represented as edge increments. Nonzero tile curvature signals a local residue, while nonzero global periods signal inconsistency caused by periodic boundary conditions. Gauge shifts correspond to changing local phase representatives.

### 10.2 Depth integration in computer vision

Estimated depth gradients must be integrated to recover a surface. Local curl tests detect incompatible neighboring estimates. On periodic textures or panoramas, global cycles add period constraints that ordinary local tests miss. The obstruction theorem separates these failure modes.

### 10.3 Loop closure in robotics

Relative displacement measurements along edges of a pose graph should sum to zero around closed loops. A gauge transformation changes the chosen origin at vertices but not loop error. The toroidal grid is a structured special case in which a small generating family of cycles gives a complete global test.

### 10.4 Periodic material and texture design

A repeated relief pattern may prescribe edge-to-edge height differences. Seamless fabrication requires zero local curvature and zero accumulated rise across each periodic direction. The same test applies before geometric embedding or metric constraints are considered.

## 11. Scope and geometric semantics

The additive theory does not by itself prove that every non-orientable three-manifold contains a Penrose triangle. Such a statement requires a definition of the purported object. A Penrose triangle depends not only on the topology of a loop but also on a projection, a depth-order relation, beam widths, intersections, and visibility. Moreover, an embedding and an immersion are distinct notions: an embedded surface cannot simultaneously be described merely as immersed without clarifying which structure is intended.

Non-orientability concerns reversal of orientation under transport. The periodic increment obstruction concerns additive holonomy. A future theory may connect them using coefficients twisted by the orientation local system, but non-orientability alone does not supply the optical or order-theoretic data of a Penrose figure. Withholding an underspecified universal claim is mathematically necessary; the present classification applies exactly to the explicitly defined periodic increment model.

Developability here also means integrability of prescribed increments, not automatically realization as a bendable sheet in three-dimensional Euclidean space. Metric developability imposes edge lengths, face shapes, and embedding conditions beyond additive height consistency. The obstruction theorem is a necessary foundational layer for such models, not a substitute for them.

## 12. Discussion and future work

The classification reveals a robust principle: local consistency and global consistency are independent. Curvature can vanish while holonomy remains nonzero, as the waterfall example demonstrates. Gauge transformations can alter every displayed edge while preserving both forms of inconsistency. This explains mathematically how an impossible staircase can look locally flawless and why relabeling cannot repair it.

Several extensions are natural. On an arbitrary finite connected two-dimensional cell complex, one expects developability exactly when cellular curvature vanishes and periods vanish on a generating family of one-cycles. This would replace the two torus periods by a basis adapted to the complex.

A certificate-extraction problem asks for the smallest witness of impossibility. On an $m\times n$ torus, local failure is witnessed by one tile. Global failure should admit a simple noncontractible cycle of controlled length, plausibly at most $m+n$.

For Penrose-type beam configurations, a rigorous piecewise-linear semantics should specify projection and depth order. The relevant obstruction may be a cyclic depth-order cocycle rather than an ordinary height increment. Subdivision could then reduce realizability to acyclicity of that data.

Non-orientable spaces suggest twisted increments valued in the orientation local system. One expects periods on the orientation double cover, together with anti-invariance under the deck transformation, to replace ordinary periods.

Finally, metric realization asks when a flat, period-free increment field can be represented by a piecewise-linear developable surface with prescribed edge lengths. Additive integrability is only the first condition; each tile must also satisfy its geometric compatibility constraints.

## 13. Conclusion

A periodic impossible figure is governed by a simple but complete obstruction. The tile curvature records local failure. Two periods record global failure around the fundamental directions of the torus. Their simultaneous vanishing is equivalent to the existence of a single-valued height function.

Changing local height references adds a gradient. Mixed differences cancel around tiles, and gradient sums telescope around periodic cycles. Therefore curvature, periods, the obstruction triple, and developability are all gauge invariant.

The theory distinguishes a truly periodic Escher staircase from an infinite but nonperiodic algebraic descent such as $2^k\mathbb Z$. It also marks the boundary between a precise additive model and broader geometric claims that require projection, orientation, or metric data. The central lesson is general: local increments become globally meaningful only after every contractible and noncontractible loop has been accounted for.