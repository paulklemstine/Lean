# Polarization of Normalized Lattice Area and the Factor of Two in Plane Tropical Bézout Formulas

## Abstract

Mixed-area formulas connect the stable intersection multiplicity of plane tropical curves with the convex geometry of their Newton polygons. Their numerical form depends essentially on the convention used for area. This paper isolates the normalization issue for the standard Newton triangles of curves of degrees $d$ and $e$. If normalized lattice area assigns area $1$ to a primitive lattice triangle, then the raw Minkowski polarization is

$$
A((d+e)\Delta)-A(d\Delta)-A(e\Delta)=2de,
$$

not $de$. Consequently, the raw normalized-area difference disagrees with the plane Bézout number for every pair of positive degrees; the pair of tropical lines gives the minimal counterexample, with area difference $2$ and intersection number $1$. The corrected normalized-area convention divides the polarization by $2$. Equivalently, Euclidean area may be used without that factor. We prove the degree-triangle identity, the positive-degree incompatibility of the uncorrected formula, symmetry, and additivity, and we give exact algorithms for evaluating and auditing the resulting quantities. These elementary results fix the normalization required for a general polygonal mixed-area intersection theory.

## 1. Introduction

Tropical geometry translates algebraic data into piecewise-linear and polyhedral geometry. For a polynomial in two variables, its exponent vectors determine a Newton polygon. The associated tropical curve is a balanced weighted polyhedral complex in the plane, and intersections of such curves carry local multiplicities. A tropical analogue of Bézout's theorem relates the total stable intersection multiplicity to convex-geometric information derived from Newton polygons.

The relation is commonly expressed through an area polarization. For convex polygons $P$ and $Q$, their Minkowski sum is

$$
P+Q=\{p+q:p\in P,\ q\in Q\}.
$$

One then considers the difference

$$
A(P+Q)-A(P)-A(Q).
$$

This expression extracts a mixed term from the quadratic behavior of area under Minkowski addition. However, its exact relationship to intersection multiplicity depends on the scale of $A$. In the plane, normalized lattice area is twice ordinary Euclidean area. Therefore a formula written correctly for Euclidean area acquires a factor of $1/2$ when rewritten using normalized lattice area.

The issue is already completely visible for standard Newton triangles. Let

$$
\Delta=\operatorname{conv}\{(0,0),(1,0),(0,1)\}.
$$

The triangle $d\Delta$ is the standard Newton polygon for a plane curve of degree $d$. Under normalized lattice area, $A(\Delta)=1$ and $A(d\Delta)=d^2$. Since $d\Delta+e\Delta=(d+e)\Delta$, direct expansion yields

$$
A((d+e)\Delta)-A(d\Delta)-A(e\Delta)=2de.
$$

Thus an uncorrected assertion that the normalized-area difference itself equals $de$ is false. In fact, for $d,e>0$ it is always larger by $de$. The corrected formula is

$$
I(P,Q)=\frac{A(P+Q)-A(P)-A(Q)}{2},
$$

where $I(P,Q)$ denotes the mixed-area quantity entering the plane intersection formula.

The purpose of this paper is narrow but foundational: to state the conventions explicitly, derive the exact identities, and exhibit structural checks that prevent normalization errors. The calculation is elementary, yet it governs the compatibility between degree-based Bézout counts and polygonal mixed-area expressions.

## 2. Geometric and algebraic preliminaries

### 2.1. Lattice polygons and area conventions

A **lattice polygon** is a convex polygon in $\mathbb{R}^2$ whose vertices lie in $\mathbb{Z}^2$. There are two area conventions relevant here.

**Definition 2.1 (Euclidean area).** The ordinary area of a measurable plane region $P$ is denoted by $\operatorname{Area}_{\mathrm{Euc}}(P)$. Under this convention,

$$
\operatorname{Area}_{\mathrm{Euc}}(\Delta)=\frac12.
$$

**Definition 2.2 (Normalized lattice area).** For a lattice polygon $P$, its normalized lattice area is

$$
A(P)=2\operatorname{Area}_{\mathrm{Euc}}(P).
$$

Thus a primitive lattice triangle has normalized area $1$, and in particular $A(\Delta)=1$.

The factor $2$ is the two-dimensional instance of the general normalization by $n!$ in dimension $n$. The present discussion is entirely planar.

### 2.2. Dilations and standard Newton triangles

For $d\ge 0$, define the dilation

$$
d\Delta=\{dx:x\in\Delta\}.
$$

Explicitly,

$$
d\Delta=\operatorname{conv}\{(0,0),(d,0),(0,d)\}.
$$

When $d$ is a nonnegative integer, this is a lattice polygon. It is the convex hull of the exponent vectors compatible with a generic polynomial of total degree at most $d$, and it serves as the standard Newton triangle of degree $d$.

**Lemma 2.3 (Area scaling).** For every nonnegative integer $d$,

$$
A(d\Delta)=d^2.
$$

**Proof sketch.** A dilation by $d$ multiplies each length by $d$ and two-dimensional Euclidean area by $d^2$. Since $\operatorname{Area}_{\mathrm{Euc}}(\Delta)=1/2$, one has $\operatorname{Area}_{\mathrm{Euc}}(d\Delta)=d^2/2$. Multiplication by $2$ gives normalized area $d^2$. $\square$

### 2.3. Minkowski addition

**Definition 2.4 (Minkowski sum).** For subsets $P,Q\subseteq\mathbb{R}^2$, their Minkowski sum is

$$
P+Q=\{p+q:p\in P,\ q\in Q\}.
$$

Minkowski addition is commutative and associative. It is also compatible with nonnegative scalar dilation of a fixed convex set.

**Lemma 2.5 (Addition of homothetic triangles).** For nonnegative integers $d$ and $e$,

$$
d\Delta+e\Delta=(d+e)\Delta.
$$

**Proof sketch.** If $x,y\in\Delta$, convexity implies

$$
\frac{d}{d+e}x+\frac{e}{d+e}y\in\Delta
$$

when $d+e>0$. Hence $dx+ey$ belongs to $(d+e)\Delta$, proving one inclusion. Conversely, for $z\in\Delta$, the point $(d+e)z$ decomposes as $dz+ez$, proving the reverse inclusion. The case $d=e=0$ is immediate. $\square$

## 3. Raw polarization and corrected mixed area

**Definition 3.1 (Raw normalized-area polarization for degree triangles).** For nonnegative integers $d$ and $e$, define

$$
D(d,e)=A((d+e)\Delta)-A(d\Delta)-A(e\Delta).
$$

This quantity is called raw because no compensating factor has yet been applied for the normalization of area.

**Theorem 3.2 (Degree-triangle polarization identity).** For all nonnegative integers $d$ and $e$,

$$
D(d,e)=2de.
$$

**Proof.** By Lemma 2.3,

$$
D(d,e)=(d+e)^2-d^2-e^2.
$$

Expanding the square gives

$$
(d+e)^2-d^2-e^2=d^2+2de+e^2-d^2-e^2=2de.
$$

Therefore $D(d,e)=2de$. $\square$

The theorem identifies the precise coefficient introduced by normalized lattice area. The mixed term appears twice, exactly as in the polarization of any quadratic form.

**Definition 3.3 (Corrected normalized mixed area).** For lattice polygons $P$ and $Q$ for which the displayed areas are defined, set

$$
I_A(P,Q)=\frac{A(P+Q)-A(P)-A(Q)}{2}.
$$

For degree triangles, this expression is integral and recovers the degree product.

**Corollary 3.4 (Corrected degree Bézout identity).** For all nonnegative integers $d$ and $e$,

$$
I_A(d\Delta,e\Delta)=de.
$$

**Proof.** Theorem 3.2 gives a numerator of $2de$. Dividing by $2$ yields $de$. $\square$

The Euclidean-area formulation is equivalent.

**Proposition 3.5 (Equivalence of conventions).** Let $P$ and $Q$ be lattice polygons. Then

$$
I_A(P,Q)=\operatorname{Area}_{\mathrm{Euc}}(P+Q)
-\operatorname{Area}_{\mathrm{Euc}}(P)
-\operatorname{Area}_{\mathrm{Euc}}(Q).
$$

**Proof.** Substitute $A(R)=2\operatorname{Area}_{\mathrm{Euc}}(R)$ for each polygon $R$ into Definition 3.3 and cancel the common factor $2$. $\square$

Thus there are two consistent presentations:

- use Euclidean area and take the raw area difference;
- use normalized lattice area and take half the raw area difference.

The two presentations encode the same number.

## 4. Counterexample and positive-degree obstruction

A normalization convention should first be tested on the smallest positive degrees.

**Theorem 4.1 (Two-line counterexample).** For $d=e=1$, the raw normalized-area polarization equals $2$:

$$
D(1,1)=2.
$$

In particular, it is not equal to the line-line Bézout number $1$.

**Proof.** The normalized areas are $A(2\Delta)=4$ and $A(\Delta)=1$, so

$$
D(1,1)=4-1-1=2.
$$

Since $2\ne1$, the raw normalized-area expression cannot itself be the desired intersection number. $\square$

This example has a direct tropical interpretation. Two generic plane tropical lines have total stable intersection multiplicity $1$. Their Newton polygons are both $\Delta$. Therefore any proposed polygon formula for that intersection count must return $1$ on $(\Delta,\Delta)$. The raw normalized polarization returns $2$, while the corrected expression returns $1$.

The failure extends uniformly to every positive degree pair.

**Theorem 4.2 (Positive-degree incompatibility).** If $d>0$ and $e>0$, then

$$
D(d,e)\ne de.
$$

More precisely,

$$
D(d,e)-de=de>0.
$$

**Proof.** By Theorem 3.2, $D(d,e)=2de$. Therefore

$$
D(d,e)-de=2de-de=de.
$$

The hypotheses imply $de>0$, so the difference is strictly positive. $\square$

**Corollary 4.3 (Characterization of accidental equality).** For nonnegative integers $d,e$,

$$
D(d,e)=de
$$

if and only if $d=0$ or $e=0$.

**Proof sketch.** The identity $2de=de$ is equivalent to $de=0$. Over the nonnegative integers this occurs exactly when one factor is zero. $\square$

The zero-degree cases do not rescue the uncorrected formula: they merely make both the mixed term and degree product vanish. Every nontrivial positive-degree case exhibits the factor of two.

## 5. Structural properties

Correct numerical normalization should coexist with the expected algebraic structure of mixed area.

**Theorem 5.1 (Symmetry).** For all nonnegative integers $d,e$,

$$
D(d,e)=D(e,d).
$$

The corrected quantity also satisfies

$$
I_A(d\Delta,e\Delta)=I_A(e\Delta,d\Delta).
$$

**Proof.** Theorem 3.2 yields $D(d,e)=2de=2ed=D(e,d)$. Division by $2$ preserves equality. $\square$

**Theorem 5.2 (Additivity in the first degree).** For all nonnegative integers $a,b,e$,

$$
D(a+b,e)=D(a,e)+D(b,e).
$$

Consequently,

$$
I_A((a+b)\Delta,e\Delta)
=I_A(a\Delta,e\Delta)+I_A(b\Delta,e\Delta).
$$

**Proof.** Using Theorem 3.2,

$$
D(a+b,e)=2(a+b)e=2ae+2be=D(a,e)+D(b,e).
$$

Dividing the identity by $2$ proves the corrected statement. $\square$

By symmetry, additivity also holds in the second degree.

**Corollary 5.3 (Bilinearity on degree parameters).** The function

$$
(d,e)\longmapsto I_A(d\Delta,e\Delta)
$$

is symmetric and additive in each argument, and it is explicitly the product $de$.

These facts explain the factor $2$ conceptually. The area map $d\mapsto d^2$ is quadratic. Its raw polarization,

$$
(d,e)\longmapsto(d+e)^2-d^2-e^2,
$$

is twice the associated symmetric bilinear form. This is analogous to the identity

$$
q(u+v)-q(u)-q(v)=2B(u,v)
$$

for a quadratic form $q$ with associated symmetric bilinear form $B$ under the usual convention $q(u)=B(u,u)$.

## 6. Exact computational procedures

Although the formulas are closed form, explicit algorithms are useful for auditing conventions, generating examples, and testing larger pipelines.

### 6.1. Degree-triangle normalization audit

**Algorithm 6.1 (Normalization audit).** Given nonnegative integer degrees $d$ and $e$:

1. Compute $A_d=d^2$.
2. Compute $A_e=e^2$.
3. Compute $A_{d+e}=(d+e)^2$.
4. Form the raw polarization $D=A_{d+e}-A_d-A_e$.
5. Form the corrected mixed area $I=D/2$.
6. Compare $D$ and $I$ with the Bézout product $B=de$.

The algorithm uses exact integer arithmetic. It performs a constant number of additions and multiplications, so it requires $O(1)$ arithmetic operations. In bit complexity, if $d$ and $e$ have at most $n$ bits, standard multiplication gives $O(n^2)$ time, while faster integer multiplication may improve this bound. Its storage requirement is $O(n)$ bits.

**Proposition 6.2 (Audit correctness).** For every nonnegative input pair $(d,e)$, Algorithm 6.1 returns

$$
D=2de,\qquad I=de,\qquad B=de.
$$

If both inputs are positive, it also certifies $D\ne B$.

**Proof sketch.** The first equality is Theorem 3.2. The second follows by exact halving, and the third is the definition of the degree product. Positivity invokes Theorem 4.2. $\square$

### 6.2. Additivity audit

A second procedure tests the polarization structure on a triple $(a,b,e)$:

1. Compute $D(a+b,e)$.
2. Compute $D(a,e)+D(b,e)$.
3. Assert equality.
4. Repeat after division by $2$ for the corrected quantity.

Theorem 5.2 guarantees success. This test is useful because a formula can match isolated values while failing the structural behavior expected of mixed area.

### 6.3. Exactness and parity

For standard degree triangles, the numerator $D(d,e)=2de$ is always even. Hence corrected mixed area can be computed using exact integer division. No floating-point arithmetic is required, and no rounding ambiguity occurs.

For a future implementation on arbitrary lattice polygons, exact rational or integer arithmetic should likewise be preferred. A shoelace computation naturally produces twice Euclidean area as an integer for lattice vertices, exactly matching normalized lattice area. The corrected polarization can then be tested for parity and divided by $2$.

## 7. Worked examples

The closed formulas permit exact evaluation without geometric approximation. The following examples illustrate the normalization, the exceptional zero-degree behavior, and additivity.

### 7.1. A line and a quartic

Take $d=1$ and $e=4$. The individual normalized areas and the area of the Minkowski sum are

$$
A(\Delta)=1,\qquad A(4\Delta)=16,\qquad A(5\Delta)=25.
$$

Hence

$$
D(1,4)=25-1-16=8.
$$

The corrected mixed area is $8/2=4$, agreeing with the Bézout product $1\cdot4=4$. The raw expression would overcount by $4$.

### 7.2. A conic and a cubic

For $d=2$ and $e=3$,

$$
A(2\Delta)=4,\qquad A(3\Delta)=9,\qquad A(5\Delta)=25.
$$

Therefore

$$
D(2,3)=25-4-9=12,
$$

while the corrected value is $6$, equal to $2\cdot3$. This example makes the scaling visible beyond the line case: the discrepancy is not a fixed additive error but exactly the Bézout product itself.

### 7.3. A vanishing degree

Let $d=0$ and $e=5$. Then

$$
A(0\Delta)=0,\qquad A(5\Delta)=25,
$$

and

$$
D(0,5)=25-0-25=0.
$$

Both the raw polarization and the degree product vanish. This explains why tests involving a zero degree cannot detect the normalization mistake. Positive inputs are essential for a diagnostic example.

### 7.4. Decomposing a degree

Set $a=2$, $b=3$, and $e=4$. Directly,

$$
D(5,4)=2\cdot5\cdot4=40.
$$

Separately,

$$
D(2,4)+D(3,4)=16+24=40.
$$

After halving, the corresponding corrected values are $20$ on the left and $8+12=20$ on the right. Thus decomposing a degree decomposes its mixed interaction exactly.

### 7.5. A geometric dissection

The algebraic identity can be represented by a square of side $d+e$. Cutting each side after lengths $d$ and $e$ partitions the square into one $d$-by-$d$ square, one $e$-by-$e$ square, and two $d$-by-$e$ rectangles. Removing the pure square areas leaves two rectangles of area $de$, so the remainder is $2de$. This dissection is not an alternative area convention; it is a visual model of why raw polarization of a quadratic function contains two copies of the symmetric mixed term.

## 8. Applications and interpretation

### 8.1. Tropical Bézout counting

For standard degree triangles, the corrected mixed-area value equals $de$, the expected total stable intersection multiplicity for plane tropical curves of degrees $d$ and $e$ under the usual hypotheses. The present result does not construct stable intersections or prove the full polygonal intersection theorem. Rather, it establishes the only normalization compatible with the degree case.

This distinction is important. A full tropical Bézout theorem combines balancedness, stable perturbation, determinant-valued local multiplicities, and a global conservation law. Once such a theorem is expressed in normalized lattice area, the triangle calculation requires the factor $1/2$.

### 8.2. Sparse polynomial systems

Newton polygons encode the monomial support of bivariate polynomials. Mixed-area quantities can bound or count isolated solutions in an algebraic torus under suitable nondegeneracy assumptions. Since changing area conventions changes numerical coefficients, an explicit normalization prevents a systematic doubling of predicted solution counts.

### 8.3. Software and numerical pipelines

Computational geometry libraries often expose Euclidean polygon area, while combinatorial packages often expose normalized lattice area or twice signed area. A pipeline that combines them can silently introduce the exact discrepancy analyzed here. The two-line test is an effective unit test:

$$
\text{input }(1,1)\quad\Longrightarrow\quad
\text{raw normalized difference }2,
\quad\text{corrected count }1.
$$

Any system returning raw value $1$ while claiming normalized area, or returning intersection count $2$ for two lines, has inconsistent conventions.

### 8.4. Polarization as a general principle

The calculation illustrates a broad method: a homogeneous quadratic quantity contains a bilinear interaction term, and polarization extracts it. The coefficient depends on convention. In the present setting, normalized lattice area makes the primitive triangle integral but doubles Euclidean area, so the raw cross term is twice the desired mixed quantity.

This viewpoint is preferable to memorizing a correction factor. It predicts the factor from first principles and generalizes to other quadratic invariants.

## 9. Scope and limitations

The results established here concern the standard one-parameter family of triangular Newton polygons. They determine normalization completely for degree-based plane formulas, but they do not by themselves establish the full tropical Bézout theorem for arbitrary polygons. In particular, no claim is made here that every pair of balanced tropical curves meets transversely, that a finite intersection exists without perturbation, or that local determinant multiplicities sum to the polygonal invariant in complete generality. Those statements require additional geometric arguments.

The restriction to nonnegative integral degrees is also substantive. It ensures that $d\Delta$ and $e\Delta$ are lattice polygons and that $de$ is an integral count. The algebraic polarization identity extends to real scaling parameters, but its interpretation as a count of curve intersections belongs to the lattice setting.

Finally, the term “mixed area” is used with multiple conventions in the literature. Some authors define the mixed coefficient so that

$$
\operatorname{Area}_{\mathrm{Euc}}(sP+tQ)
=s^2\operatorname{Area}_{\mathrm{Euc}}(P)+2stV(P,Q)
+t^2\operatorname{Area}_{\mathrm{Euc}}(Q),
$$

while others attach the name to the full cross term. The safest practice is not to infer a coefficient from terminology. One should state the polarization formula explicitly and calibrate it on $P=Q=\Delta$. Under the convention of this paper, corrected normalized mixed area returns $1$ on that primitive pair.

## 10. Discussion

The principal lesson is that “normalized” does not mean “coefficient-free.” Normalized lattice area is advantageous because it assigns integral area to lattice polygons and gives a primitive triangle area $1$. Yet the same normalization rescales every area difference by $2$ relative to Euclidean area. Since the plane Bézout number remains $de$, the conversion must appear somewhere in the formula.

The degree-triangle case provides a complete diagnostic because all ingredients are explicit:

$$
A(d\Delta)=d^2,
$$

$$
d\Delta+e\Delta=(d+e)\Delta,
$$

and hence

$$
A((d+e)\Delta)-A(d\Delta)-A(e\Delta)=2de.
$$

No geometric degeneracy or multiplicity convention alters this algebraic identity. Therefore, if normalized area is fixed as above, the half-polarization is forced.

Symmetry and additivity further show that the correction is structurally natural. The raw expression is already symmetric and biadditive on degree parameters, but its diagonal scale is twice the intended one. Multiplication by $1/2$ preserves the structure while calibrating it against the primitive line-line intersection.

## 11. Future work

The next mathematical step is to move from homothetic triangles to arbitrary finite lattice polygons. This requires a precise polygon model, exact normalized area, and a proof that the area of Minkowski combinations is a homogeneous quadratic polynomial. The half-polarization should then define a symmetric, Minkowski-additive mixed-area invariant.

A second step is to connect that convex invariant to balanced tropical curves. One seeks a theorem asserting that the determinant-weighted total multiplicity of a finite stable intersection equals the corrected mixed area of the Newton polygons. Perturbation invariance must ensure that sufficiently small generic translations preserve the total weighted count.

Further directions include support bounds when every local multiplicity is positive, comparison with realizable curves over complete non-Archimedean fields, and higher-dimensional analogues. For $n$ transverse tropical hypersurfaces of degrees $d_1,\ldots,d_n$ in tropical projective $n$-space, the expected weighted zero-dimensional count is

$$
\prod_{i=1}^{n}d_i.
$$

In higher dimensions the normalization by $n!$ and the conventions for mixed volume must be stated just as carefully as the planar factor of $2$.

## 12. Conclusion

For standard Newton triangles and normalized lattice area, the raw polarization is exactly $2de$. This yields a minimal counterexample to the uncorrected formula at $(d,e)=(1,1)$ and proves incompatibility with $de$ for every positive degree pair. Dividing by $2$ restores the plane Bézout value, while preserving symmetry and additivity. Equivalently, one may use Euclidean area and omit the division.

The result is elementary, exact, and decisive: a mixed-area tropical Bézout formula must declare its area convention, and normalized lattice area requires the missing half.

The broader methodological point is equally direct. Before deploying a convex-geometric invariant as an enumerative count, one should calibrate it on the primitive objects whose intersections are already understood. Here that calibration is the pair of degree-one triangles. It distinguishes the two consistent area conventions, rules out the inconsistent hybrid, and supplies a reusable test for every later generalization.