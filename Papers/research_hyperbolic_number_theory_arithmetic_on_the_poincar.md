# The Integer-Translation Orbit of the Modular Group in the Poincaré Disk

## Exact Radius, Faithfulness, Boundary Escape, and Counting

**Author:** Aristotle  
**Date:** 2026-07-17

## Abstract

We study an elementary but structurally informative arithmetic orbit in hyperbolic geometry. Starting with the integer translates $n+i$ of $i$ in the upper half-plane and applying the Cayley transform, we obtain the disk points

$$
p_n=\frac{n}{n+2i},\qquad n\in\mathbb Z.
$$

We derive the exact squared-radius formula $|p_n|^2=n^2/(n^2+4)$ and use it to prove that all orbit points lie in the open Poincaré disk, that the parametrization is injective, that negation corresponds to reflection across the real axis, and that the orbit converges radially to the ideal boundary. Radial comparison is shown to recover comparison of integer absolute values exactly. Consequently, the closed Euclidean radial cutoff through $p_N$ contains precisely the points indexed by $-N\le n\le N$, hence exactly $2N+1$ distinct points. We also derive the corresponding hyperbolic distance formula and present algorithms for point generation, membership testing, and exact counting. The results isolate a rigorous modular orbit while clarifying why an orbit, tessellation vertices, primitive geodesics, and prime elements must not be conflated in a broader theory of hyperbolic arithmetic.

## 1. Introduction

The classical integers combine three roles: they form a discrete ordered set, they carry ring operations, and they support prime factorization. Hyperbolic geometry supplies discrete group actions, tessellations, cusps, and length spectra that resemble familiar arithmetic structures without automatically reproducing them. A careful program in hyperbolic number theory must therefore begin by specifying its objects and distinguishing geometric analogy from transported algebra.

This paper develops one canonical and completely explicit object associated with the modular group. Let

$$
\mathbb H=\{z\in\mathbb C:\operatorname{Im}z>0\}
$$

be the upper half-plane. Integer translations $T_n(z)=z+n$ belong to the modular group action. The orbit of the base point $i$ under the translation subgroup is $\{n+i:n\in\mathbb Z\}$. The Cayley transform

$$
C(z)=\frac{z-i}{z+i}
$$

identifies $\mathbb H$ with the open unit disk

$$
\mathbb D=\{w\in\mathbb C:|w|<1\}.
$$

The transported orbit has the simple form

$$
p_n=C(n+i)=\frac{n}{n+2i}.
$$

Its simplicity permits exact answers to several basic questions. Does every point lie inside the disk? Does the image retain the integer index faithfully? How quickly does it approach the ideal boundary? Does radial order correspond to arithmetic order? How many orbit points lie inside a natural radial cutoff?

The answers are respectively yes, yes, quadratically in Euclidean boundary defect, exactly by absolute value, and $2N+1$ at the cutoff through the $N$th point. These statements provide a baseline against which broader proposals involving hyperbolic primes or zeta functions can be assessed.

Three methodological principles guide the analysis. First, all comparisons are reduced to exact rational identities before numerical approximation is considered. Second, Euclidean quantities in the disk picture are kept distinct from intrinsic hyperbolic quantities. Third, algebra transported from an indexing set is distinguished from algebra determined canonically by geometry. These principles are elementary, but they prevent several common category errors in attempts to interpret geometric populations arithmetically.

The paper is organized as follows. Section 2 fixes the geometric setting. Section 3 proves the exact coordinate and radius formulas. Sections 4 and 5 establish faithfulness, symmetry, escape, and radial ordering. Section 6 gives the exact counting theorem. Section 7 derives the hyperbolic-distance interpretation. Sections 8 and 9 describe transported arithmetic and algorithms. The final sections discuss applications, limitations, and future research.

## 2. Geometric setting and definitions

### 2.1 The two standard models

The upper half-plane $\mathbb H$ carries the hyperbolic metric

$$
ds_{\mathbb H}^2=\frac{dx^2+dy^2}{y^2},
$$

where $z=x+iy$ and $y>0$. The Poincaré disk $\mathbb D$ carries

$$
ds_{\mathbb D}^2=\frac{4(du^2+dv^2)}{(1-u^2-v^2)^2},
$$

where $w=u+iv$ and $u^2+v^2<1$. The Cayley transform $C(z)=(z-i)/(z+i)$ is an isometry between these models with the stated normalizations.

The Euclidean boundary $|w|=1$ is the ideal boundary of $\mathbb D$ and is not part of the hyperbolic plane. A sequence whose Euclidean modulus tends to $1$ escapes every compact hyperbolic region even though it remains in a bounded Euclidean set.

### 2.2 Modular translations

The modular group consists of fractional-linear transformations

$$
z\longmapsto\frac{az+b}{cz+d},
$$

where $a,b,c,d\in\mathbb Z$ and $ad-bc=1$, with a matrix and its negative defining the same transformation. The subgroup relevant here consists of integer translations

$$
T_n(z)=z+n.
$$

We use the base point $i$. Its translation orbit is the horizontal discrete set $n+i$.

### 2.3 The disk orbit

**Definition 2.1 (modular translation orbit in the disk).** For each $n\in\mathbb Z$, define

$$
p_n=C(T_n(i))=C(n+i)=\frac{n}{n+2i}.
$$

We call $\mathcal O=\{p_n:n\in\mathbb Z\}$ the Cayley-transformed integer-translation orbit.

This definition concerns a single orbit of a subgroup. It does not define all vertices of a modular tessellation, nor the primitive closed geodesics of the modular surface.

**Definition 2.2 (squared radial boundary defect).** For $p_n\in\mathbb D$, define

$$
\delta_n=1-|p_n|^2.
$$

This is a Euclidean radial quantity. It is useful for exact algebra, but it is not itself hyperbolic distance.

**Definition 2.3 (endpoint radial cutoff).** For $N\in\mathbb N$, define

$$
\mathcal O_N=\{p_n\in\mathcal O:|p_n|^2\le |p_N|^2\}.
$$

Because the orbit is indexed, the same geometric point must not be counted twice. Injectivity, proved below, ensures that index counting and point counting agree.

## 3. Exact coordinates and radius

The basic algebraic identity drives all later results.

**Theorem 3.1 (exact coordinate and squared-radius formulas).** For every integer $n$,

$$
p_n=\frac{n^2}{n^2+4}-i\frac{2n}{n^2+4}
$$

and

$$
|p_n|^2=\frac{n^2}{n^2+4}.
$$

**Proof sketch.** Multiply $n/(n+2i)$ by $(n-2i)/(n-2i)$. Since $(n+2i)(n-2i)=n^2+4$, the coordinate formula follows. Squaring and adding the real and imaginary parts gives

$$
\frac{n^4+4n^2}{(n^2+4)^2}=\frac{n^2}{n^2+4}.
$$

Equivalently, use $|n+2i|^2=n^2+4$. $\square$

**Corollary 3.2 (open-disk membership).** Every $p_n$ lies in $\mathbb D$.

**Proof sketch.** The squared modulus is nonnegative and

$$
\frac{n^2}{n^2+4}<1
$$

because $4>0$. Therefore $|p_n|<1$. $\square$

**Corollary 3.3 (exact boundary defect).** For every $n\in\mathbb Z$,

$$
\delta_n=\frac{4}{n^2+4}.
$$

**Proof sketch.** Subtract the squared-radius formula from $1$ over the common denominator $n^2+4$. $\square$

The first values are

$$
|p_0|^2=0,
\qquad |p_1|^2=\frac15,
\qquad |p_2|^2=\frac12,
\qquad |p_3|^2=\frac9{13}.
$$

These values provide immediate numerical checks of the general identity.

## 4. Faithfulness and reflection symmetry

The geometric embedding preserves the index exactly.

**Theorem 4.1 (faithfulness of the orbit parametrization).** The map $n\mapsto p_n$ from $\mathbb Z$ to $\mathbb D$ is injective. Explicitly, if $p_m=p_n$, then $m=n$.

**Proof sketch.** Equality gives

$$
\frac{m}{m+2i}=\frac{n}{n+2i}.
$$

The denominators are nonzero, so cross-multiplication yields

$$
m(n+2i)=n(m+2i).
$$

After canceling $mn$, one obtains $2mi=2ni$, hence $m=n$. $\square$

**Corollary 4.2 (infinitude).** The orbit $\mathcal O$ contains infinitely many distinct points.

**Proof sketch.** The integers form an infinite set and their image under an injective map is infinite. $\square$

**Theorem 4.3 (reflection symmetry).** For every $n\in\mathbb Z$,

$$
p_{-n}=\overline{p_n}.
$$

**Proof sketch.** The coordinate formula shows that replacing $n$ by $-n$ leaves the real part $n^2/(n^2+4)$ fixed and reverses the sign of the imaginary part. That is precisely complex conjugation. $\square$

Thus the two signs of a nonzero integer appear as mirror images across the real axis. The origin corresponds to $n=0$ and is fixed by the reflection.

## 5. Boundary escape and radial order

### 5.1 Convergence to the ideal boundary

**Theorem 5.1 (radial boundary convergence).** Along the positive indices,

$$
\lim_{n\to\infty}|p_n|^2=1
\quad\text{and}\quad
\lim_{n\to\infty}|p_n|=1.
$$

**Proof sketch.** Rewrite

$$
|p_n|^2=\frac{1}{1+4/n^2}
$$

for $n>0$. Since $4/n^2\to0$, the squared modulus tends to $1$. The square-root function is continuous and the moduli are nonnegative, so $|p_n|\to1$. $\square$

The defect formula gives more than convergence:

$$
1-|p_n|^2=\frac{4}{n^2+4}\sim\frac4{n^2}.
$$

Hence the squared Euclidean radius approaches the boundary value with quadratic decay in the index.

### 5.2 Exact radial ordering

**Theorem 5.2 (radial order theorem).** For all $m,n\in\mathbb Z$,

$$
|p_m|^2\le |p_n|^2
\quad\Longleftrightarrow\quad
m^2\le n^2.
$$

Equivalently,

$$
|p_m|\le |p_n|
\quad\Longleftrightarrow\quad
|m|\le |n|.
$$

**Proof sketch.** Substitute the exact radius formula. Since both denominators are positive,

$$
\frac{m^2}{m^2+4}\le\frac{n^2}{n^2+4}
$$

is equivalent to

$$
m^2(n^2+4)\le n^2(m^2+4).
$$

Cancel $m^2n^2$ and divide by $4$ to obtain $m^2\le n^2$. The modulus version follows because all quantities are nonnegative. $\square$

This theorem states that radius is a complete statistic for the absolute value of the index. It cannot distinguish $n$ from $-n$, but reflection symmetry supplies that missing sign information.

The monotonicity can also be seen analytically. For $x\ge0$, the function $f(x)=x^2/(x^2+4)$ has derivative

$$
f'(x)=\frac{8x}{(x^2+4)^2},
$$

which is nonnegative and strictly positive for $x>0$. The algebraic proof above is stronger for exact computation because it works without calculus and reduces comparisons to integer arithmetic.

## 6. Exact orbit counting

**Theorem 6.1 (cutoff characterization).** Let $N\in\mathbb N$ and $n\in\mathbb Z$. Then

$$
|p_n|^2\le |p_N|^2
\quad\Longleftrightarrow\quad
|n|\le N.
$$

**Proof sketch.** Apply Theorem 5.2 with the integer $N$. The condition $n^2\le N^2$ is equivalent to $|n|\le N$ because $N$ is nonnegative. $\square$

**Theorem 6.2 (exact finite orbit count).** For every $N\in\mathbb N$, the radial cutoff $\mathcal O_N$ is

$$
\mathcal O_N=\{p_n:-N\le n\le N\}
$$

and contains exactly

$$
|\mathcal O_N|=2N+1
$$

distinct points.

**Proof sketch.** The cutoff characterization identifies precisely the integer interval $[-N,N]$. This interval contains the $N$ negative integers $-N,\ldots,-1$, the origin, and the $N$ positive integers $1,\ldots,N$, for a total of $2N+1$. Theorem 4.1 ensures that distinct indices yield distinct points. $\square$

**Corollary 6.3 (escape from smaller concentric disks).** Fix $0\le r<1$. Only finitely many orbit points satisfy $|p_n|\le r$.

**Proof sketch.** The inequality

$$
\frac{n^2}{n^2+4}\le r^2
$$

rearranges to

$$
(1-r^2)n^2\le4r^2.
$$

Because $1-r^2>0$, this bounds $|n|$. Only finitely many integers satisfy the bound. $\square$

The count $2N+1$ is exact but specific. It counts a one-dimensional cusp orbit under an endpoint-defined Euclidean radial cutoff. It is not a prime-counting law and should not be compared directly with two-dimensional lattice growth or the prime geodesic theorem.

For an arbitrary Euclidean radius $0\le r<1$, the same calculation gives a closed formula. The condition $|p_n|\le r$ is equivalent to

$$
|n|\le \frac{2r}{\sqrt{1-r^2}}.
$$

Hence the number of orbit points in the Euclidean disk of radius $r$ is

$$
2\left\lfloor\frac{2r}{\sqrt{1-r^2}}\right\rfloor+1.
$$

At $r=|p_N|$, the expression inside the floor equals $N$, recovering Theorem 6.2.

## 7. Hyperbolic-distance interpretation

The exact Euclidean radius can be translated into intrinsic hyperbolic distance.

**Definition 7.1 (radial hyperbolic distance).** In the Poincaré disk,

$$
d_{\mathbb D}(0,w)=2\operatorname{artanh}|w|
=\log\frac{1+|w|}{1-|w|}.
$$

**Proposition 7.2 (distance along the modular orbit).** For every $n\in\mathbb Z$,

$$
d_{\mathbb D}(0,p_n)
=2\operatorname{arsinh}\left(\frac{|n|}{2}\right).
$$

**Proof sketch.** Theorem 3.1 gives

$$
|p_n|=\frac{|n|}{\sqrt{n^2+4}}.
$$

Set $x=|n|/2$. Then $|p_n|=x/\sqrt{1+x^2}$. The identity

$$
\operatorname{artanh}\left(\frac{x}{\sqrt{1+x^2}}\right)=\operatorname{arsinh}(x)
$$

follows by writing both sides logarithmically or by applying the hyperbolic tangent to $\operatorname{arsinh}(x)$. Multiplying by $2$ yields the formula. $\square$

This proposition is also consistent with the upper-half-plane distance formula between $i$ and $n+i$.

**Corollary 7.3 (intrinsic growth).** As $|n|\to\infty$,

$$
d_{\mathbb D}(0,p_n)=2\log|n|+O(|n|^{-2}).
$$

**Proof sketch.** Use $\operatorname{arsinh}x=\log(x+\sqrt{x^2+1})$ with $x=|n|/2$. The leading expression is $\log|n|$, and multiplication by $2$ gives the result. $\square$

**Corollary 7.4 (hyperbolic-ball index criterion).** For $R\ge0$,

$$
d_{\mathbb D}(0,p_n)\le R
\quad\Longleftrightarrow\quad
|n|\le2\sinh(R/2).
$$

Consequently, the number of orbit points in the hyperbolic ball of radius $R$ centered at $0$ is

$$
2\left\lfloor2\sinh(R/2)\right\rfloor+1.
$$

**Proof sketch.** The function $\operatorname{arsinh}$ is increasing, so Proposition 7.2 may be inverted. Counting integral indices in the resulting symmetric interval gives the formula. $\square$

This intrinsic count is a mathematical consequence of the radius law and standard disk geometry. It grows like $2e^{R/2}$, reflecting the geometry of this particular horocyclic orbit rather than the full area growth of the hyperbolic plane.

## 8. Transported arithmetic and its interpretation

An injective parametrization permits algebraic transport.

**Definition 8.1 (transported operations).** For orbit points, define

$$
p_m\oplus p_n=p_{m+n},
\qquad
p_m\odot p_n=p_{mn}.
$$

These definitions are unambiguous because each orbit point has a unique integer index.

**Proposition 8.2 (transported integer ring).** The set $\mathcal O$, equipped with $\oplus$ and $\odot$, is a commutative ring, and the map

$$
\mathbb Z\longrightarrow\mathcal O,
\qquad n\longmapsto p_n,
$$

is a ring isomorphism.

**Proof sketch.** Every ring identity on $\mathcal O$ reduces through the definitions to the corresponding identity in $\mathbb Z$. The parametrization is bijective onto $\mathcal O$ by definition of the image and Theorem 4.1. It preserves both operations by construction. $\square$

**Corollary 8.3 (factorization under transported arithmetic).** Every nonzero nonunit of $\mathcal O$ factors into images of ordinary prime integers, uniquely up to order and multiplication by the images of $1$ and $-1$.

**Proof sketch.** Transfer the fundamental theorem of arithmetic through the ring isomorphism. $\square$

The interpretation is essential: this factorization property comes from transported ordinary arithmetic. It does not show that vertices of a hyperbolic tessellation have a canonical multiplication, nor that geometric primitive objects are prime elements of this ring.

## 9. Algorithms and numerical demonstrations

All principal quantities can be computed in constant arithmetic time for a fixed index, apart from the bit complexity of large-integer operations.

### 9.1 Orbit-point generation

Given $n\in\mathbb Z$, compute

$$
\operatorname{Re}p_n=\frac{n^2}{n^2+4},
\qquad
\operatorname{Im}p_n=-\frac{2n}{n^2+4}.
$$

Using integer numerator-denominator pairs preserves exactness. With fixed-width floating-point output, the algorithm uses $O(1)$ arithmetic operations. For a $b$-bit index, multiplication and division costs depend on the chosen $b$-bit arithmetic implementation.

### 9.2 Exact radial membership

To decide whether $p_n$ lies in the cutoff through $p_N$, it is unnecessary to evaluate complex numbers or divisions. Test

$$
|n|\le N.
$$

This follows from Theorem 6.1 and avoids rounding near the boundary.

### 9.3 Exact count

The count is returned directly as $2N+1$. If the points themselves are required, enumerate indices from $-N$ through $N$ and apply the coordinate formula. Returning only the count takes constant arithmetic time; materializing all points takes $O(N)$ point evaluations and $O(N)$ output space.

### 9.4 Numerical stability

For large $|n|$, direct floating-point evaluation of $1-|p_n|^2$ can suffer cancellation because $|p_n|^2$ is close to $1$. The exact defect formula

$$
\delta_n=\frac{4}{n^2+4}
$$

is preferable. Likewise, radial comparisons should use integer absolute values rather than nearly equal floating-point radii.

## 10. Applications

### 10.1 Visualization of cusps

The orbit gives a compact visualization of escape toward a cusp. Although $p_n\to1$ in the Euclidean closure, the intrinsic distance tends to infinity. This makes the construction useful in teaching the distinction between Euclidean compactness of the drawing and noncompactness of the represented hyperbolic surface.

### 10.2 Testing geometric software

The formulas provide exact benchmarks for implementations of Möbius transformations, the Cayley map, and hyperbolic distance. A correct program should reproduce reflection, squared radii, and the count $2N+1$. The defect formula is particularly useful for testing behavior near the boundary.

### 10.3 Arithmetic indexing of geometric data

Because radius recovers $|n|$ and the sign is recovered from the side of the real axis, the geometry encodes the integer index. Except at the origin, one can recover the sign from $\operatorname{Im}p_n$ and magnitude from

$$
|n|=\frac{2|p_n|}{\sqrt{1-|p_n|^2}}.
$$

For exact orbit points, this returns an integer. The construction is therefore a reversible arithmetic encoding inside the disk.

### 10.4 Baseline for spectral and prime-geodesic questions

More sophisticated hyperbolic counting theories concern conjugacy classes and primitive closed geodesics. The present orbit is a useful control case because its population, metric behavior, and multiplicity are explicit. Any proposed “hyperbolic prime” model should state clearly how its objects differ from these orbit points and why its counting function has a different asymptotic law.

## 11. Scope and limitations

The results establish an exact modular translation orbit, not a general system of hyperbolic integers. An orbit is initially only a set with a group action. Ring operations require an explicit transport such as Definition 8.1, and different parametrizations could induce different-looking operations.

Tessellation vertices are also distinct from orbit points. The full modular tessellation includes images under transformations beyond translations. Its vertices and edges carry combinatorial and geometric information, but no canonical commutative-ring structure follows merely from being vertices.

Primitive closed geodesics provide another distinct population. On a quotient hyperbolic surface, they correspond to primitive hyperbolic conjugacy classes and are the natural analogue underlying the prime geodesic theorem. Their lengths feed the Selberg zeta function. Parabolic translation orbits approaching cusps, such as the one studied here, are not primitive closed geodesics.

Finally, a zeta expression of the form

$$
\sum_x |x|^{-2s}
$$

is not defined until the set of $x$, the norm $|x|$, multiplicities, and treatment of zero are fixed. Its convergence region must be established before analytic continuation, functional equations, or zero locations can be discussed. Numerical evidence for zeros additionally requires rigorous error control if it is to support exact claims.

## 12. Future work

A first extension is to develop the full Möbius action of determinant-one real or integer matrices and show directly that it preserves the relevant hyperbolic metric. This would place the translation calculation inside a general action framework.

A second direction is to replace Euclidean radial cutoffs by intrinsic hyperbolic cutoffs throughout. Proposition 7.2 already supplies the expected formula for this orbit; further work could compare cusp-orbit growth with area growth and with counts from other subgroup orbits.

A third direction is algebraic. Transported addition and multiplication can be studied explicitly as rational functions of disk coordinates, while maintaining the distinction between parametrization-dependent operations and geometry intrinsic to the disk.

A fourth direction is the finite combinatorial encoding of primitive hyperbolic conjugacy classes of the modular group. Such an encoding would connect symbolic dynamics, continued fractions, closed geodesics, and genuine prime-geodesic counting.

A fifth direction is analytic. After selecting a canonical length spectrum and multiplicities, one can define finite Euler products or truncated zeta functions, establish convergence bounds, and only then seek continuation or functional equations. Reliable zero computations would require interval or ball arithmetic and argument-principle counts proving how many zeros lie in each region.

## 13. Conclusion

The Cayley-transformed integer-translation orbit

$$
p_n=\frac{n}{n+2i}
$$

is a faithful, symmetric, infinite copy of the integers inside the Poincaré disk. Its squared radius is exactly $n^2/(n^2+4)$, its boundary defect is $4/(n^2+4)$, and radial order is precisely absolute-value order on the indices. The cutoff through $p_N$ contains exactly the $2N+1$ points with $-N\le n\le N$. In intrinsic terms, the distance from the origin is $2\operatorname{arsinh}(|n|/2)$.

These formulas show how a discrete arithmetic index can be represented in curved geometry without ambiguity. The example is small enough that every step is explicit, yet rich enough to exhibit the central features of a cusp: Euclidean accumulation, intrinsic escape, reflection symmetry, and exponential counting under an intrinsic radius. It therefore serves simultaneously as a worked model and as a test case for more elaborate constructions.

They also enforce conceptual discipline: transported integer primes, tessellation vertices, cusp-orbit points, and primitive closed geodesics are different objects. A mature hyperbolic number theory must define each population and operation before assigning it arithmetic meaning. The explicit modular orbit offers a reliable starting point for that program.