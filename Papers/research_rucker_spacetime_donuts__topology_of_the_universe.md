# Flat Toroidal Space, Wrapping Classes, and the Causal Role of Time Identification

**Aristotle**  
**21 July 2026**

## Abstract

We study the flat three-torus $T^3=(\mathbb R/\mathbb Z)^3$ through its universal covering projection and use it to separate two claims that are often conflated: the existence of closed spatial geodesics and the existence of closed timelike geodesics. Every integer vector $n\in\mathbb Z^3$ defines a periodic projected straight line $\gamma_n(t)=tn\pmod{\mathbb Z^3}$, and every nonzero such vector gives a nonconstant closed spatial geodesic. The kernel of the covering projection is exactly the integer lattice, whose three coordinate vectors are linearly independent; consequently, there are three independent winding directions and infinitely many distinct wrapping classes. We then analyze constant-velocity affine geodesics in the product spacetime $\mathbb R\times T^3$. Closure forces zero displacement in the unquotiented time coordinate, while timelikeness forces a nonzero time component. Hence no unit-period affine geodesic in this product is both closed and timelike. Spatial torus topology alone therefore does not imply closed timelike geodesics. By contrast, compactifying time gives $(\mathbb R/\mathbb Z)\times T^3$, where unit motion around the time circle is an explicit closed timelike affine geodesic. Finally, we formulate minimal volume abstractly and show that a distinguished candidate is volume-minimizing exactly when its volume is a lower bound of the range of the volume function. This last statement clarifies the logical shape of the Weeks-manifold question without asserting the geometric minimality theorem.

## 1. Introduction

A compact universe can be locally indistinguishable from an infinite one while possessing radically different global routes. The flat three-torus is the simplest three-dimensional example. It is obtained by identifying points of $\mathbb R^3$ that differ by an integer vector, or equivalently by identifying each pair of opposite faces of a unit cube. There is no boundary: crossing one face returns through its partner.

The model supports a precise version of “wrapping around the universe.” Straight lines in the universal cover project to geodesics, and lines with integer direction close after unit parameter time. The three coordinate directions generate independent winding data. These features motivate an intuitive leap: if space wraps, perhaps timelike geodesics must also close. That leap is false in the standard product spacetime. The topology of space and the topology of time play distinct causal roles.

Our purpose is to present an elementary, self-contained account of both sides of this distinction. The arguments use only quotient geometry, integer lattices, linear algebra, and the Minkowski timelike inequality. The main conclusions are:

1. every nonzero integer vector produces a nonconstant closed geodesic on the flat three-torus;
2. the covering-translation lattice is exactly $\mathbb Z^3$, with three independent standard generators;
3. the resulting wrapping classes are infinite in number;
4. no unit-period affine geodesic in $\mathbb R\times T^3$ can be both closed and timelike;
5. compactifying time produces an explicit closed timelike affine geodesic;
6. abstract volume minimality is equivalent to membership in the lower-bound set of all candidate volumes.

The qualification “affine” is important. We work with projections of constant-velocity lines in a flat covering spacetime. This captures the central obstruction transparently, without claiming a general classification of all causal curves in arbitrary Lorentzian manifolds.

## 2. The flat three-torus

### 2.1 Quotient construction

Let $\mathbb Z^3$ act on $\mathbb R^3$ by translations. Two points $x,y\in\mathbb R^3$ are equivalent when $x-y\in\mathbb Z^3$. The quotient is the flat three-torus

$$
T^3=\mathbb R^3/\mathbb Z^3\cong(\mathbb R/\mathbb Z)^3.
$$

Write

$$
p:\mathbb R^3\longrightarrow T^3,
\qquad
p(x_1,x_2,x_3)=(x_1\bmod 1,x_2\bmod 1,x_3\bmod 1)
$$

for the canonical projection. Addition on $T^3$ is coordinatewise addition modulo $1$. The quotient carries the flat metric induced locally from Euclidean space.

**Definition 2.1 (Integer-direction geodesic).** For $n=(n_1,n_2,n_3)\in\mathbb Z^3$, define

$$
\gamma_n:\mathbb R\to T^3,
\qquad
\gamma_n(t)=p(tn)=p(tn_1,tn_2,tn_3).
$$

The lifted curve $t\mapsto tn$ is a Euclidean straight line of constant velocity $n$. Its projection is therefore a geodesic of the flat quotient in the usual local sense.

### 2.2 Periodicity and nontriviality

**Theorem 2.2 (Integer-direction periodicity).** For every $n\in\mathbb Z^3$ and $t\in\mathbb R$,

$$
\gamma_n(t+1)=\gamma_n(t).
$$

**Proof sketch.** The lifted points differ by

$$
(t+1)n-tn=n\in\mathbb Z^3.
$$

The covering projection identifies points differing by an integer vector. Hence their projections agree. $\square$

Periodicity alone permits the zero vector, whose projected line is constant. The next result separates genuine motion from that degenerate case.

**Lemma 2.3 (Nontriviality criterion).** If $n\in\mathbb Z^3$ is nonzero, then $\gamma_n$ is not constant.

**Proof sketch.** Choose a coordinate $i$ for which $n_i\ne0$ and set $t=1/(2n_i)$. The $i$th coordinate of $tn$ equals $1/2$. Since $1/2$ is not an integer, it does not represent zero in $\mathbb R/\mathbb Z$. Thus $\gamma_n(t)\ne\gamma_n(0)$. $\square$

**Theorem 2.4 (Existence of nonconstant closed spatial geodesics).** The flat three-torus contains a nonconstant closed geodesic. More strongly, every nonzero $n\in\mathbb Z^3$ defines such a geodesic, periodic with period $1$.

**Proof sketch.** Combine Theorem 2.2 with Lemma 2.3. An explicit example is $n=(1,0,0)$; at $t=1/2$ its first coordinate is $1/2$ modulo $1$, while at $t=0$ it is zero. $\square$

The period $1$ need not be the primitive period. If the coordinates of $n$ have a common divisor, the route may close earlier. The theorem asserts a universal period and is sufficient for the existence and classification results below.

## 3. The integer lattice and wrapping data

### 3.1 Kernel of the projection

The key algebraic object is the set of translations invisible in the quotient.

**Theorem 3.1 (Kernel characterization).** For $x=(x_1,x_2,x_3)\in\mathbb R^3$,

$$
p(x)=0\quad\Longleftrightarrow\quad x_i\in\mathbb Z\text{ for }i=1,2,3.
$$

Consequently,

$$
\ker p=\mathbb Z^3,
$$

where $\mathbb Z^3$ is embedded coordinatewise in $\mathbb R^3$.

**Proof sketch.** In one coordinate, a real number represents zero in $\mathbb R/\mathbb Z$ exactly when it is an integer. Equality to zero in the product quotient holds exactly when this condition holds in every coordinate. $\square$

This kernel is also the group of translations of the universal cover that preserve every fiber of $p$. It is therefore the natural algebraic proxy for the deck-translation group. Standard covering-space theory further identifies it with the fundamental group of the torus, but the lattice computation itself already contains the winding information needed here.

### 3.2 Three independent generators

Let

$$
e_1=(1,0,0),\qquad e_2=(0,1,0),\qquad e_3=(0,0,1).
$$

**Theorem 3.2 (Independence of coordinate wrappings).** The vectors $e_1,e_2,e_3$ are linearly independent over $\mathbb Z$. Every $n\in\mathbb Z^3$ has the unique representation

$$
n=n_1e_1+n_2e_2+n_3e_3.
$$

**Proof sketch.** If $a_1e_1+a_2e_2+a_3e_3=0$, comparison of the three coordinates gives $a_1=a_2=a_3=0$. Existence of the displayed representation follows directly from coordinate addition, and independence gives uniqueness. $\square$

The phrase “three independent families of wrapping” now has a precise interpretation. A loop can wind independently in each coordinate direction, and its winding record is an integer triple. The signs indicate orientation and the magnitudes indicate multiplicity.

**Definition 3.3 (Wrapping class represented by an integer line).** Associate to $n\in\mathbb Z^3$ the covering displacement $n\in\ker p$ of the lifted path $t\mapsto tn$ over one period.

**Lemma 3.4 (Injectivity of wrapping data).** If two integer-direction lines have the same covering displacement, then their integer vectors are equal.

**Proof sketch.** Equality of their embedded vectors in $\mathbb R^3$ gives equality coordinate by coordinate. The inclusion $\mathbb Z\hookrightarrow\mathbb R$ is injective, so the original integer coordinates agree. $\square$

**Theorem 3.5 (Infinitely many wrapping classes).** The set of wrapping classes represented by integer-direction geodesics is infinite.

**Proof sketch.** The map $n\mapsto n\in\ker p$ is injective by Lemma 3.4, and $\mathbb Z^3$ is infinite. For a concrete infinite subfamily, use $(k,0,0)$ for $k\in\mathbb Z$. $\square$

This result distinguishes “three independent generators” from “three possible loops.” There are infinitely many classes, organized by three integer coordinates.

## 4. Affine causal geometry on the product spacetime

### 4.1 Constant velocities and timelikeness

Consider the spacetime

$$
\mathcal M=\mathbb R\times T^3,
$$

with the flat product Lorentzian structure induced from Minkowski space $\mathbb R\times\mathbb R^3$. A constant velocity in the covering spacetime is a pair

$$
v=(\tau,s),
$$

where $\tau\in\mathbb R$ is the time component and $s=(s_1,s_2,s_3)\in\mathbb R^3$ is the spatial component. The corresponding affine curve is

$$
\widetilde\Gamma_v(u)=(u\tau,us)
$$

upstairs and

$$
\Gamma_v(u)=(u\tau,p(us))
$$

in $\mathcal M$.

**Definition 4.1 (Timelike velocity).** In units where the speed of light is $1$, the velocity $v=(\tau,s)$ is timelike when

$$
\|s\|^2<\tau^2,
\qquad
\|s\|^2=s_1^2+s_2^2+s_3^2.
$$

This convention corresponds to the Lorentzian quadratic form $-\tau^2+\|s\|^2$ being negative.

**Definition 4.2 (Unit-period closure in the product).** The affine curve closes after one unit of parameter time when

$$
\Gamma_v(1)=\Gamma_v(0).
$$

Because the time factor is not quotiented, this is equivalent to

$$
\tau=0
\quad\text{and}\quad
s_i\in\mathbb Z\text{ for }i=1,2,3.
$$

The spatial condition follows from Theorem 3.1, while the equality $\tau=0$ follows from ordinary equality on the real line.

### 4.2 The causal obstruction

**Theorem 4.3 (No closed timelike affine geodesic in the globally timed product).** No unit-period affine geodesic in $\mathbb R\times T^3$ is both closed and timelike.

**Proof.** Suppose a velocity $v=(\tau,s)$ closes after one unit. Definition 4.2 gives $\tau=0$. If $v$ were timelike, Definition 4.1 would yield

$$
s_1^2+s_2^2+s_3^2<0.
$$

Each square is nonnegative, so their sum is nonnegative, a contradiction. $\square$

**Corollary 4.4 (Spatial torus topology does not force affine time travel).** The existence of toroidal spatial topology, by itself, does not imply the existence of a closed timelike affine geodesic.

The corollary is a counterexample to the stronger implication: $\mathbb R\times T^3$ has toroidal spatial slices and abundant closed spatial geodesics, yet Theorem 4.3 excludes closed timelike affine geodesics.

The mechanism is elementary but fundamental. A closed spatial geodesic returns to the same point of $T^3$; it need not return to the same event of spacetime. Along a future-directed timelike trajectory, the unquotiented real time coordinate changes. Spatial recurrence therefore occurs at a different time.

The theorem concerns affine geodesics of the stated flat model. A broader claim about all causal curves would naturally be derived from global hyperbolicity or a global time function. The coordinate $t:\mathbb R\times T^3\to\mathbb R$ provides the relevant intuition: it is single-valued and cannot return along a consistently future-directed causal curve. Establishing that stronger intrinsic statement requires the standard Lorentzian definitions beyond the elementary affine framework adopted here.

## 5. Compact time and a repaired existence theorem

Now quotient the time coordinate as well:

$$
\mathcal M_c=(\mathbb R/\mathbb Z)\times T^3.
$$

A velocity $v=(\tau,s)$ closes after one unit precisely when all four displacements are integral:

$$
\tau\in\mathbb Z,
\qquad
s_i\in\mathbb Z\text{ for }i=1,2,3.
$$

**Theorem 5.1 (Closed timelike geodesic with compact time).** The compact-time spacetime $(\mathbb R/\mathbb Z)\times T^3$ contains a closed timelike affine geodesic.

**Proof.** Choose

$$
v=(1,0,0,0).
$$

Every component is integral, so the associated affine curve closes after one unit. Its spatial squared speed is $0$, while its squared time component is $1$. Hence

$$
0<1,
$$

and the velocity is timelike. $\square$

This theorem repairs the false spatial-topology implication by adding exactly the missing causal ingredient: an identification with timelike displacement. It also suggests the following general diagnostic for quotients of Minkowski space.

**Principle 5.2 (Causal classification of affine quotient loops).** Let a discrete translation lattice act on Minkowski space. A projected affine line closes when its one-period displacement is a lattice vector. The causal type of the closed affine geodesic is the causal type of that vector under the Lorentzian quadratic form. Thus a timelike lattice vector yields a closed timelike affine geodesic, a null lattice vector yields a closed null affine geodesic, and a spacelike lattice vector yields a closed spacelike affine geodesic.

In $\mathbb R\times T^3$, all identification vectors have zero time component and are therefore spatial. In $(\mathbb R/\mathbb Z)\times T^3$, the lattice contains $(1,0,0,0)$, which is timelike under the chosen sign convention.

## 6. Algorithms and numerical demonstrations

The preceding results admit direct finite computations. These computations illustrate the exact statements; they are not substitutes for the proofs.

### 6.1 Sampling a projected geodesic

Given $n\in\mathbb Z^3$ and a sample count $N$, compute

$$
\gamma_n(k/N)=\left(\frac{kn_1}{N}\bmod1,\frac{kn_2}{N}\bmod1,\frac{kn_3}{N}\bmod1\right)
$$

for $k=0,\ldots,N$. This takes $O(N)$ arithmetic operations and $O(N)$ storage if all points are retained. The first and last points agree exactly in ideal arithmetic.

### 6.2 Testing closure and causal type

For $v=(\tau,s)$, product closure is tested by checking $\tau=0$ and integrality of each $s_i$. Compact-time closure instead checks integrality of all four components. Causal type is determined by

$$
q(v)=\|s\|^2-\tau^2.
$$

The velocity is timelike for $q(v)<0$, null for $q(v)=0$, and spacelike for $q(v)>0$. Each test uses constant time and storage in four dimensions.

Examples make the contrast immediate. The product velocity $(0,1,0,0)$ closes but is spacelike because $q=1$. The velocity $(1,0,0,0)$ is timelike because $q=-1$, but it does not close when time is real. It does close when time is circular.

### 6.3 Enumerating bounded wrapping vectors

For a bound $B\ge0$, enumerate all integer triples in $[-B,B]^3$. There are $(2B+1)^3$ vectors, one of which is zero. The nonzero vectors provide $(2B+1)^3-1$ sampled wrapping classes. The runtime is $O(B^3)$ and the output storage is $O(B^3)$. This finite enumeration displays the growth of the infinite lattice without confusing a bounded sample with the full set.

## 7. Minimal volume as an order-theoretic statement

The Weeks manifold belongs to a different geometric setting: closed orientable hyperbolic three-manifolds. Its volume is commonly quoted as approximately $0.94$ in the normalization of sectional curvature $-1$. The deep geometric statement that it has least volume among the relevant manifolds must not be conflated with the elementary order-theoretic form of such a claim.

Let $M$ be any class of candidates, let

$$
V:M\to\mathbb R
$$

be a volume function, and let $W\in M$ be distinguished.

**Definition 7.1 (Minimal volume).** The candidate $W$ has minimal volume when

$$
V(W)\le V(X)
\qquad\text{for every }X\in M.
$$

For a set $S\subseteq\mathbb R$, define its lower-bound set by

$$
\operatorname{LB}(S)=\{a\in\mathbb R: a\le s\text{ for every }s\in S\}.
$$

**Theorem 7.2 (Lower-bound characterization of minimality).** The candidate $W$ has minimal volume if and only if

$$
V(W)\in\operatorname{LB}(V(M)),
$$

where $V(M)=\{V(X):X\in M\}$ is the range of $V$.

**Proof.** If $W$ is minimal and $y\in V(M)$, then $y=V(X)$ for some $X\in M$, so $V(W)\le y$. Therefore $V(W)$ is a lower bound of $V(M)$. Conversely, if $V(W)$ is a lower bound of $V(M)$, then $V(X)\in V(M)$ for every $X\in M$, and hence $V(W)\le V(X)$. This is exactly minimality. $\square$

The theorem is fully general and contains no hyperbolic geometry. To apply it substantively to the Weeks manifold one must define the candidate class and volume, establish invariance under isometry, construct the manifold, certify its volume, and prove the global comparison against every competitor. Accordingly, the approximate value $0.94$ is contextual here rather than a derived numerical conclusion.

## 8. Applications and interpretation

### 8.1 Cosmic topology

A spatial three-torus is locally Euclidean but globally compact. In an idealized cosmological model, radiation could reach an observer along paths with different winding vectors, potentially producing repeated images or matched large-scale patterns. The lattice $\mathbb Z^3$ supplies the bookkeeping: each route is labeled by three winding integers.

The results do not establish that physical space is toroidal. They instead specify the mathematical consequences of that hypothesis. In particular, they prevent a causal overinterpretation: repeated spatial routes do not imply return to an earlier event.

### 8.2 Periodic simulation domains

Computational physics frequently uses periodic boundary conditions. A simulation box with opposite faces identified is precisely a finite representation of a toroidal quotient. Particle paths are often tracked both modulo the box and through an “unwrapped” displacement. The latter is an integer lattice vector and records boundary crossings. The kernel and injectivity results explain why this unwrapped vector is the correct invariant for distinguishing routes that look identical inside one cell.

### 8.3 Causal quotient design

The compact-time example illustrates a general design rule. Quotient identifications must be inspected with the Lorentzian metric, not merely with topology. A quotient containing timelike translation vectors creates closed timelike affine geodesics. This provides a fast preliminary test for proposed flat spacetime quotients before undertaking a more global causal analysis.

## 9. Limitations and future work

Several natural extensions require additional geometry.

First, the lattice computation should be connected explicitly to the topological fundamental group, yielding a group isomorphism $\pi_1(T^3)\cong\mathbb Z^3$ and classifications of based and free homotopy classes.

Second, affine projected lines should be related intrinsically to Levi-Civita geodesics for a Lorentzian product metric. This would support a proof that $\mathbb R\times T^3$ is globally hyperbolic and contains no closed causal curves at all, not merely no closed timelike affine geodesics.

Third, the quotient classification in Principle 5.2 can be developed for general Minkowski lattices. One expects a clean trichotomy according to whether the lattice contains timelike, null, or only spacelike nonzero vectors.

Fourth, a genuine treatment of hyperbolic volume requires complete finite-volume hyperbolic manifolds, orientability, isometry classes, Riemannian volume, triangulations, certified volume bounds, and the rigidity and surgery tools needed for global minimality.

Finally, the algebraic independence of the three coordinate loops can be enriched geometrically by studying intersections, first homology, and unique decomposition of arbitrary winding classes.

## 10. Conclusion

The flat three-torus has an elementary but consequential structure. Integer straight lines project to closed spatial geodesics; nonzero integer vectors make those geodesics nonconstant. The invisible translations of the covering projection form exactly $\mathbb Z^3$, whose standard coordinate vectors are independent and whose infinitely many elements encode infinitely many wrapping classes.

The causal analysis draws a sharp boundary around these facts. In $\mathbb R\times T^3$, closure forces zero time displacement, which is incompatible with timelikeness. Toroidal spatial topology alone therefore does not force closed timelike affine geodesics. When time is compactified, the vector $(1,0,0,0)$ becomes an explicit closed timelike direction. The decisive datum is not compactness alone but the causal character of the identification lattice.

This separation of topology, geometry, and causality is the central lesson. Topology determines global return, geometry determines geodesic motion, and the Lorentzian metric determines whether that motion can represent a massive observer. A rigorous account of a “donut-shaped universe” must keep all three roles in view.

The framework also supplies a practical order of analysis for future models: compute the identification group, determine its independent generators, construct the projected geodesics, and only then classify those generators using the ambient metric. This order prevents topological recurrence from being mistaken for causal recurrence and applies equally to conceptual cosmology and periodic computational domains.
