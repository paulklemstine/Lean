# Inverse Stereographic Neural Field Theory: Exact Geometry, Planar Asymptotics, and Spherical-Mode Multiplicity

**Aristotle**  
**August 3, 2026**

## Abstract

Neural-field equations describe population-scale activity on spatially extended cortical domains. When the domain is modeled by the unit two-sphere, inverse stereographic projection gives a global planar chart whose sole omitted point is the north pole. This paper develops the exact geometric and combinatorial foundations needed to use that chart responsibly. For $p=(x,y)\in\mathbb R^2$, the map

$$
\sigma(x,y)=\left(\frac{2x}{1+x^2+y^2},\frac{2y}{1+x^2+y^2},
\frac{x^2+y^2-1}{1+x^2+y^2}\right)
$$

is shown to land on the unit sphere, avoid the north pole at every finite point, and have uniformly bounded coordinate modes. Along a radial ray, the first coordinate is exactly $2R/(1+R^2)$ and is bounded by $2/R$ for $R\ge 1$, whereas the third coordinate approaches $1$ with exact error $2/(1+R^2)$. Thus planar decay is conditional on vanishing at the projection pole; it is not automatic for spherical harmonics. We also derive the dimension $2k+1$ of the degree-$k$ spherical-harmonic space from the binomial-difference formula and obtain dimensions $3$, $5$, and $7$ for degrees $1$, $2$, and $3$. Under a separate spectral hypothesis that an interaction radius $r=1/k$ selects degree $k$, these are the corresponding selected-mode dimensions. We distinguish this rigorous multiplicity statement from the stronger claim of exactly $2k+1$ stable nonlinear patterns, which requires a specified kernel, response function, rotational equivalence relation, and bifurcation analysis. Algorithms and numerical diagnostics are given for projection, asymptotic testing, and multiplicity calculation.

## 1. Introduction

Continuum neural-field models replace individual neurons by a spatial activity field. Their equations may be local partial differential equations, nonlocal integral equations, or coupled systems. In every case, geometry influences the admissible modes and the way interactions propagate. A planar approximation is convenient, but a closed cortical surface has no physical boundary. The sphere $S^2$ is therefore a useful foundational geometry: it is compact, homogeneous under rotations, and equipped with an explicit spectral basis of spherical harmonics.

Inverse stereographic projection provides an exact connection between $S^2$ and $\mathbb R^2$. It is conformal, meaning that it preserves angles, although not lengths or areas. Its omitted north pole corresponds to planar infinity. This correspondence makes it possible to visualize spherical modes on a flat domain and, ultimately, to rewrite spherical differential equations as weighted planar equations.

The present work isolates what follows from geometry and elementary harmonic multiplicity alone. Four conclusions are central.

First, the inverse stereographic formula is globally regular on the finite plane and maps exactly into $S^2$. Second, all three pulled-back coordinate harmonics are bounded by one. Third, their far-field behavior is not uniform: the two coordinates vanishing at the north pole decay to zero, but the vertical coordinate tends to its pole value $1$. Fourth, the degree-$k$ spherical-harmonic eigenspace has dimension $2k+1$, yielding the small-degree values $3$, $5$, and $7$.

These conclusions clarify the status of a proposed neural-pattern count. If a rotationally invariant Mexican-hat interaction selects degree $k$, then the critical linear space has dimension $2k+1$. It does not follow that there are exactly $2k+1$ stable nonlinear solutions. Multiplicity is a statement about vector-space dimension; stable-solution counting is a bifurcation problem.

## 2. Geometric setting

### 2.1 The sphere and the planar chart

Let

$$
S^2=\{(X,Y,Z)\in\mathbb R^3:X^2+Y^2+Z^2=1\}
$$

be the unit two-sphere, and let $N=(0,0,1)$ be its north pole.

**Definition 2.1 (Stereographic denominator).** For $(x,y)\in\mathbb R^2$, define

$$
D(x,y)=1+x^2+y^2.
$$

**Definition 2.2 (Inverse stereographic projection).** The inverse stereographic map $\sigma:\mathbb R^2\to\mathbb R^3$ is

$$
\sigma(x,y)=\bigl(X(x,y),Y(x,y),Z(x,y)\bigr),
$$

where

$$
X=\frac{2x}{D},\qquad
Y=\frac{2y}{D},\qquad
Z=\frac{x^2+y^2-1}{D}.
$$

Geometrically, $\sigma$ is the inverse of projection from $N$ onto the equatorial plane. The origin maps to the south pole $(0,0,-1)$, the unit circle maps to the equator, and paths escaping to infinity approach $N$.

### 2.2 Positivity and the omitted pole

**Lemma 2.3 (Positive denominator).** For every $(x,y)\in\mathbb R^2$,

$$
D(x,y)>0.
$$

**Proof sketch.** Since $x^2\ge 0$ and $y^2\ge 0$, one has $D=1+x^2+y^2\ge 1>0$. In particular, none of the coordinate fractions has a finite singularity. $\square$

**Lemma 2.4 (Exact north-pole complement).** For every $(x,y)\in\mathbb R^2$,

$$
1-Z(x,y)=\frac{2}{D(x,y)}.
$$

**Proof sketch.** Substitute the definition of $Z$ and combine over the common denominator:

$$
1-\frac{x^2+y^2-1}{1+x^2+y^2}
=\frac{1+x^2+y^2-x^2-y^2+1}{1+x^2+y^2}
=\frac{2}{D}.
$$

$\square$

**Corollary 2.5 (Finite points avoid the north pole).** For every finite $(x,y)$,

$$
Z(x,y)<1.
$$

**Proof sketch.** By Lemma 2.3, $2/D>0$. Lemma 2.4 therefore gives $1-Z>0$. $\square$

This result makes the compactification explicit: the north pole is approached only when $D\to\infty$, which occurs as $x^2+y^2\to\infty$.

## 3. Exact image and bounded coordinate modes

**Theorem 3.1 (Sphere-image theorem).** For every $(x,y)\in\mathbb R^2$,

$$
X(x,y)^2+Y(x,y)^2+Z(x,y)^2=1.
$$

Consequently, $\sigma(\mathbb R^2)\subset S^2$.

**Proof sketch.** Put $s=x^2+y^2$. Then

$$
X^2+Y^2+Z^2
=\frac{4x^2+4y^2+(s-1)^2}{(1+s)^2}
=\frac{4s+s^2-2s+1}{(1+s)^2}.
$$

The numerator is $s^2+2s+1=(1+s)^2$, so the quotient is one. $\square$

**Theorem 3.2 (Uniform coordinate bounds).** For every $(x,y)\in\mathbb R^2$,

$$
|X(x,y)|\le 1,\qquad |Y(x,y)|\le 1,\qquad |Z(x,y)|\le 1.
$$

**Proof sketch.** Theorem 3.1 expresses one as a sum of three nonnegative squares. Each square is therefore at most one, and taking square roots gives the bounds. $\square$

The restrictions to $S^2$ of the ambient coordinate functions $X$, $Y$, and $Z$ form the degree-one spherical-harmonic space. Theorem 3.2 therefore gives a global bound for their planar pullbacks. The statement is independent of direction and remains valid arbitrarily far from the origin.

## 4. Far-field asymptotics and the pole-value principle

The behavior at planar infinity is central to both analysis and numerical boundary conditions. Consider the horizontal ray $(R,0)$.

**Theorem 4.1 (Exact first-coordinate profile).** For every real $R$,

$$
X(R,0)=\frac{2R}{1+R^2}.
$$

**Proof sketch.** At $(R,0)$, the denominator is $1+R^2$ and the numerator of $X$ is $2R$. $\square$

**Theorem 4.2 (Quantitative first-coordinate decay).** If $R\ge 1$, then

$$
|X(R,0)|\le \frac{2}{R}.
$$

**Proof sketch.** For $R\ge 1$, all quantities are nonnegative. The claim is equivalent to

$$
\frac{2R}{1+R^2}\le\frac{2}{R}.
$$

Multiplying by the positive number $R(1+R^2)$ gives $2R^2\le 2(1+R^2)$, which is immediate. $\square$

Thus $X(R,0)=O(R^{-1})$. In fact, $RX(R,0)\to 2$.

**Theorem 4.3 (Exact third-coordinate error).** For every real $R$,

$$
|1-Z(R,0)|=\frac{2}{1+R^2}.
$$

**Proof sketch.** Lemma 2.4 gives $1-Z=2/D$, and at $(R,0)$ the denominator is $1+R^2$. The expression is positive, so its absolute value is unchanged. $\square$

It follows that $Z(R,0)\to 1$ with error $O(R^{-2})$. This produces the main asymptotic qualification.

**Principle 4.4 (Pole-value principle).** If a continuous spherical field $u:S^2\to\mathbb R$ is pulled back to the plane as $v=u\circ\sigma$, then any limit of $v(x,y)$ as $x^2+y^2\to\infty$ must be governed by the north-pole value $u(N)$. In particular, decay of $v$ to zero requires $u(N)=0$; otherwise the natural decaying quantity is $v-u(N)$.

**Justification.** The exact coordinate formulas show that $\sigma(x,y)\to N$ as $x^2+y^2\to\infty$. Continuity then gives $u(\sigma(x,y))\to u(N)$. The coordinate examples exhibit both possibilities: $X(N)=Y(N)=0$, while $Z(N)=1$. $\square$

The principle prevents an overbroad assertion that all projected spherical harmonics decay. Degree-one already supplies a counterexample through $Z$. For numerical work, imposing a zero far-field condition is appropriate only after verifying the pole condition or subtracting the pole value.

## 5. Neural-field equations in stereographic coordinates

### 5.1 Local spherical equations

A schematic semilinear spherical neural-field equation is

$$
\Delta_{S^2}u=f(u),
$$

where $\Delta_{S^2}$ is the Laplace–Beltrami operator and $f$ is a response nonlinearity. A time-dependent version may take the form

$$
\partial_tu=\alpha\Delta_{S^2}u+f(u),
$$

with diffusion coefficient $\alpha>0$.

Stereographic coordinates are conformal. The pullback metric on $\mathbb R^2$ is

$$
g=\frac{4}{(1+x^2+y^2)^2}(dx^2+dy^2).
$$

Accordingly, with a consistent Laplacian sign convention, the two-dimensional transformation expected for smooth $u$ is

$$
(\Delta_{S^2}u)\circ\sigma
=\frac{(1+x^2+y^2)^2}{4}\,\Delta(u\circ\sigma).
$$

This identity is presented here as the analytic target built upon the exact chart geometry, not as one of the established results of Sections 2–4. Its derivation requires computing the pullback metric, its determinant, and the Laplace–Beltrami formula. It illustrates why flattening does not remove curvature: curvature reappears as a spatially varying coefficient.

### 5.2 Nonlocal interactions

A rotationally symmetric nonlocal neural field may be written schematically as

$$
\partial_tu(\omega,t)
=-u(\omega,t)+\int_{S^2}K(\omega\cdot\eta)
F(u(\eta,t))\,d\eta,
$$

where $\omega,\eta\in S^2$, $K$ is a zonal connectivity kernel, and $F$ is an activation function. A Mexican-hat kernel has local excitation and longer-range inhibition. Because $K$ depends only on $\omega\cdot\eta$, the associated linear integral operator commutes with rotations and acts by a scalar on each spherical-harmonic degree. Its Fourier–Legendre coefficients determine which degree becomes unstable.

The phrase “Mexican hat” alone does not determine those coefficients. Widths, amplitudes, normalization, and the definition of interaction radius all matter. Therefore the rule that radius $r=1/k$ selects degree $k$ must be treated as a spectral hypothesis until a concrete kernel is specified and analyzed.

## 6. Spherical-harmonic multiplicity

### 6.1 Dimension formula

Let $\mathcal H_k(S^2)$ denote the real vector space of degree-$k$ spherical harmonics. Equivalently, it consists of restrictions to $S^2$ of homogeneous harmonic polynomials of degree $k$ in three variables.

**Theorem 6.1 (Harmonic multiplicity on the two-sphere).** For every nonnegative integer $k$,

$$
\dim\mathcal H_k(S^2)=2k+1.
$$

**Proof sketch.** The space of homogeneous polynomials of degree $k$ in three variables has dimension

$$
\binom{k+2}{2}.
$$

The standard harmonic decomposition separates such polynomials into a harmonic part and the radial quadratic $X^2+Y^2+Z^2$ times a homogeneous polynomial of degree $k-2$. The latter space has dimension $\binom{k}{2}$, interpreted as zero for $k<2$. Hence

$$
\dim\mathcal H_k(S^2)
=\binom{k+2}{2}-\binom{k}{2}.
$$

Using $\binom{n}{2}=n(n-1)/2$,

$$
\binom{k+2}{2}-\binom{k}{2}
=\frac{(k+2)(k+1)-k(k-1)}{2}
=2k+1.
$$

$\square$

This is the representation-theoretic multiplicity of angular degree $k$ under rotations. It describes the number of independent coefficients needed to specify a field in the degree-$k$ eigenspace.

### 6.2 Reciprocal-radius cases

Assume the following explicit spectral condition.

**Spectral selection hypothesis.** For a positive integer $k$, an interaction radius $r=1/k$ selects precisely the degree-$k$ spherical-harmonic eigenspace.

**Corollary 6.2 (Selected-mode dimension).** Under the spectral selection hypothesis, the selected eigenspace at radius $r=1/k$ has dimension

$$
2k+1.
$$

**Proof sketch.** Selection identifies the critical space with $\mathcal H_k(S^2)$; apply Theorem 6.1. $\square$

**Corollary 6.3 (First three reciprocal radii).** Under the same hypothesis:

$$
\begin{array}{c|c|c}
r & k & \dim\mathcal H_k(S^2)\\ \hline
1 & 1 & 3\\
1/2 & 2 & 5\\
1/3 & 3 & 7
\end{array}
$$

**Proof sketch.** Substitute $k=1,2,3$ into $2k+1$. $\square$

## 7. Dimension is not a stable-solution count

The multiplicity theorem is sometimes paraphrased as saying that degree $k$ supplies $2k+1$ “patterns.” This language is safe only if “patterns” means independent linear modes or basis elements. It is not an exact count of fields, rotational orbits, or stable nonlinear equilibria.

A vector space of dimension $2k+1$ contains infinitely many elements. Moreover, $SO(3)$ acts continuously on $\mathcal H_k(S^2)$, mixing basis functions. A chosen real basis has $2k+1$ members, but basis choice is not canonical enough to define $2k+1$ physical states. The orbit of a single generic field under rotation is itself continuous.

To obtain a finite count of stable solutions, one must specify:

1. the exact neural-field evolution equation;
2. the connectivity kernel and all parameters;
3. the activation function and operating point;
4. the bifurcation parameter and nondegeneracy assumptions;
5. the stability notion and function space;
6. whether rotated copies count as distinct;
7. how amplitude sign or other symmetries are identified.

Linear spectral theory locates the critical eigenspace. Equivariant nonlinear analysis then determines branches, isotropy subgroups, and stability. Depending on coefficients, there may be no stable branch, several isolated symmetry types, or continuous families. Consequently, the established statement is the conditional eigenspace dimension $2k+1$, not an unconditional count of stable solutions.

## 8. Computational algorithms and diagnostics

### 8.1 Inverse-projection algorithm

Given $(x,y)$, compute $s=x^2+y^2$, set $D=1+s$, and return

$$
\left(\frac{2x}{D},\frac{2y}{D},\frac{s-1}{D}\right).
$$

This uses a constant number of arithmetic operations, so its time and memory complexity are $O(1)$ per point. On a grid of $n$ points, both evaluation and checking the sphere residual cost $O(n)$ time.

A useful diagnostic is

$$
\varepsilon_{S^2}=|X^2+Y^2+Z^2-1|.
$$

In exact arithmetic this is zero. In floating-point arithmetic it measures rounding error.

### 8.2 Radial asymptotic diagnostic

For radii $R>0$, evaluate

$$
X_R=\frac{2R}{1+R^2},\qquad
Z_R=\frac{R^2-1}{1+R^2}.
$$

Then compare $|X_R|$ with $2/R$ for $R\ge1$, and compare $|1-Z_R|$ with $2/(1+R^2)$. The ratios

$$
\frac{|X_R|}{2/R}=\frac{R^2}{1+R^2},
\qquad
\frac{|1-Z_R|}{2/(1+R^2)}=1
$$

show respectively an asymptotically sharp bound and an exact identity. For a list of $m$ radii the procedure costs $O(m)$ time and $O(m)$ output space.

### 8.3 Multiplicity algorithm

For integer $k\ge0$, compute either $2k+1$ directly or

$$
\binom{k+2}{2}-\binom{k}{2}.
$$

With fixed-width integers this is $O(1)$. With arbitrary-precision integers, the bit complexity depends on multiplication cost, although the direct formula remains minimal. A table for $k=1,2,3$ returns $3,5,7$.

These computations demonstrate exact formulas numerically; they do not test nonlinear stability or validate the spectral-selection hypothesis for an unspecified kernel.

## 9. Applications

### 9.1 Boundary conditions for planar simulations

When the plane stands for a punctured sphere, the edge of a large computational box approximates the north pole. The pole-value principle prescribes the far-field condition. If $u(N)=0$, homogeneous boundary conditions are natural. If $u(N)\ne0$, one should either impose the corresponding nonzero value or evolve the shifted field $u-u(N)$. Otherwise a boundary layer may be an artifact of an incompatible geometric condition.

### 9.2 Visualization of spherical modes

The rational coordinate formulas give distortion-aware planar images of spherical activity. Features near the north pole are spread over a large planar region, while the south pole maps to the origin. This can help distinguish a genuine mode asymptotic from truncation error. It also cautions against reading Euclidean wavelength directly from a stereographic image, because the local scale factor varies with position.

### 9.3 Pattern selection in neural fields

For rotationally symmetric interactions, the $2k+1$ multiplicity identifies the dimension of a critical angular sector. That dimension controls the number of amplitudes in a center-manifold or weakly nonlinear reduction. In the cases $k=1,2,3$, one expects reduced systems with $3$, $5$, and $7$ amplitude coordinates before symmetry reduction. Their nonlinear invariant terms, not dimension alone, determine stable pattern types.

### 9.4 Visual-hallucination modeling

Geometric hallucination models often relate cortical activity to perceived planar motifs. Stereographic transport provides a tractable model for how global closed-surface modes might appear in a plane. The framework predicts bounded projected degree-one modes and identifies whether they fade or approach a background level. Stronger perceptual predictions require a biologically calibrated map and a fully specified connectivity operator.

## 10. Discussion

### 10.1 Assumptions and scope

The unit sphere is an idealized cortical geometry. Real cortical surfaces have folds, variable curvature, topology, anisotropy, and heterogeneous tissue properties. The present conclusions should therefore be understood as a baseline theory in which rotational symmetry is exact. Their value is that geometric effects can be separated cleanly from biological heterogeneity. Perturbations away from the sphere may later be studied relative to this baseline.

The coordinate theorems are unconditional algebraic statements. They require only finite real planar coordinates and the displayed definition of inverse stereographic projection. The pole-value principle requires continuity of the spherical field. The multiplicity theorem is likewise unconditional for spherical harmonics. By contrast, assigning degree $k$ to radius $1/k$ is conditional on spectral selection by a particular interaction operator. No conclusion about that rule should be transferred between kernels without recalculating their spectra.

There are also two different uses of “radius.” The planar radial coordinate $R=\sqrt{x^2+y^2}$ measures position in the stereographic chart, while the interaction radius $r$ measures the scale of neural connectivity. They are not interchangeable. The former controls where a point lies and how close its image is to the north pole; the latter is a model parameter proposed to select an angular degree.

Finally, the coordinate estimates concern degree-one modes and one representative ray. Rotational symmetry gives analogous descriptions in other directions for the coordinate pair, but higher-degree harmonics can have more complicated nodal sets and asymptotics. Their limits are still governed by pole values under continuity, while quantitative rates depend on vanishing order near the pole. This distinction motivates a general pole-subtracted decay theorem rather than extrapolation from a few examples.

### 10.2 Interpretation

The results form a minimal but exact foundation for inverse stereographic neural-field theory. The map is globally defined on $\mathbb R^2$, lands on $S^2$, and compactifies all planar directions at a single pole. The coordinate bounds ensure that basic modes do not blow up under projection. The asymptotic formulas expose a condition that is easy to miss: compactness of the source does not imply zero decay of the planar pullback. Infinity carries the pole value.

The harmonic dimension theorem provides the exact representation-theoretic numbers motivating the sequence $3,5,7$. Its interpretation must remain precise. The theorem counts independent linear modes. The reciprocal-radius relation is an additional hypothesis about spectral selection. Stability is a further nonlinear question. Keeping these three layers—geometry, spectrum, and nonlinear dynamics—separate prevents a plausible narrative from becoming an unsupported counting claim.

The same separation suggests an efficient research program. Geometry supplies the chart and differential weights. Spectral analysis of a concrete zonal kernel supplies the selected degree. Equivariant bifurcation theory supplies branches and stability. Numerical simulations can then test the resulting predictions without being asked to stand in for missing definitions.

## 11. Future work

First, explicit real bases for spherical harmonics of degrees $1$, $2$, and $3$ should be constructed and stereographically pulled back. This would turn the dimensions $3$, $5$, and $7$ into concrete families of rational planar patterns.

Second, the pole-value principle should be strengthened quantitatively. For a smooth $u$, Taylor expansion near $N$ should relate the vanishing order of $u-u(N)$ to the decay rate of $(u-u(N))\circ\sigma$. The coordinate examples indicate $R^{-1}$ behavior for a nonzero tangential derivative and $R^{-2}$ behavior for the north-pole complement.

Third, the pullback metric and Laplace–Beltrami transformation should be derived with an explicit sign convention. This will produce the exact weighted planar PDE corresponding to $\Delta_{S^2}u=f(u)$.

Fourth, a specific zonal difference-of-Gaussians kernel should replace the generic Mexican-hat description. Its Fourier–Legendre coefficients can then be calculated, and the proposed relation between radius $1/k$ and selected degree $k$ can be proved, modified, or rejected.

Finally, after spectral selection is established, an $SO(3)$-equivariant bifurcation analysis should classify solution branches, rotational equivalence classes, and stability. Only at that stage can a finite claim about stable nonlinear patterns be justified.

## 12. Conclusion

Inverse stereographic projection gives a precise planar representation of spherical neural fields. Its denominator is strictly positive; its image lies exactly on the unit sphere; and its coordinate modes remain within $[-1,1]$. Along a radial ray, the first coordinate is $2R/(1+R^2)$ and obeys a $2/R$ decay bound, while the third approaches $1$ with exact error $2/(1+R^2)$. Hence decay to zero requires vanishing at the omitted pole or subtraction of the pole value.

Independently, the degree-$k$ spherical-harmonic space has dimension $2k+1$, obtained from the binomial difference $\binom{k+2}{2}-\binom{k}{2}$. If radii $1$, $1/2$, and $1/3$ select degrees $1$, $2$, and $3$, the corresponding selected spaces have dimensions $3$, $5$, and $7$. These are rigorous mode multiplicities, not counts of stable nonlinear solutions. Together, the geometric identities, asymptotic qualification, and representation-theoretic count define a clear platform for the next analytic step: a fully specified kernel and an equivariant stability theory.