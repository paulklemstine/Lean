# Inverse Stereographic Renormalization for the One-Dimensional Ising Decimation Map

## Abstract

We develop an exact geometric representation of the zero-field one-dimensional Ising decimation transformation. In the high-temperature coupling coordinate $g=\tanh K$, decimation of alternate spins is the polynomial map $R(g)=g^2$. We compactify the real coupling line by the inverse stereographic parametrization

$$
S(g)=\left(\frac{2g}{1+g^2},\frac{1-g^2}{1+g^2}\right)
$$

of the unit circle. We prove that $S$ conjugates the Ising map to the rational circle transformation

$$
C(x,y)=\left(\frac{x^2}{2-x^2},\frac{2y}{1+y^2}\right).
$$

We characterize the finite fixed couplings as exactly $0$ and $1$, define the discrete one-step beta observable $B(g)=R(g)-g$, and compute the derivatives $R'(g)=2g$ and $B'(g)=2g-1$. The construction gives a global, exact bridge between a real-space renormalization step and conformal compactification in a solvable model. It does not equate this discrete observable with a continuous field-theoretic beta function; instead, it isolates the additional structures required for such a comparison.

## 1. Introduction

The renormalization group organizes physical theories by scale. A coarse-graining operation removes short-distance variables, after which parameters are adjusted so that the effective model remains in a chosen family. Fixed points represent scale-invariant behavior, while the linearization near a fixed point measures the relevance or irrelevance of perturbations.

Geometric descriptions of renormalization can reveal structure hidden by a particular coupling coordinate. The simplest useful test is one in which the renormalization map is exact, global, and elementary. The zero-field one-dimensional Ising chain provides such a test. If $K$ denotes the dimensionless nearest-neighbor coupling and

$$
g=\tanh K,
$$

then eliminating alternate spins produces the exact recursion

$$
g'=g^2.
$$

The physical ferromagnetic finite-temperature range is $0\leq g<1$. The value $g=0$ is the infinite-temperature, uncoupled point, and $g\to1$ is the zero-temperature strong-coupling limit.

Our aim is to represent this dynamics on a compact geometric space. Inverse stereographic projection identifies the real line with the unit circle minus one point. Under this identification, the polynomial map $g\mapsto g^2$ becomes an explicit rational self-map of the circle. The resulting commutative relation is an exact conjugacy, not a metaphor or perturbative approximation.

The analysis has five principal results. First, the inverse stereographic formula lands on the unit circle for every real coupling. Second, Ising decimation is conjugate to a rational circle map. Third, the finite fixed couplings are exactly $0$ and $1$. Fourth, the linearized coupling update has multiplier $2g$. Fifth, the derivative of the discrete one-step beta observable is $2g-1$. We also give numerical algorithms and discuss what must be added before comparison with a continuous beta function or with $\phi^4$ field theory is mathematically meaningful.

## 2. The Ising decimation coordinate

Consider the zero-field one-dimensional Ising Hamiltonian on a chain,

$$
-\mathcal H/(k_B T)=K\sum_i \sigma_i\sigma_{i+1},
$$

where each spin satisfies $\sigma_i\in\{-1,1\}$. Introduce the high-temperature coupling

$$
g=\tanh K.
$$

This coordinate is convenient because the nearest-neighbor Boltzmann factor can be written as

$$
e^{K\sigma_i\sigma_{i+1}}=\cosh K\left(1+g\sigma_i\sigma_{i+1}\right).
$$

Summing over an intermediate spin joins two bonds. Up to a multiplicative factor independent of the two retained endpoint spins, the effective high-temperature coupling is the product of the original bond couplings. For two identical bonds this gives $g'=g^2$. Accordingly, we take the exact decimation update to be the following.

**Definition 2.1 (Ising decimation map).** For $g\in\mathbb R$, define

$$
R(g)=g^2.
$$

The extension from the physical interval to all real numbers is algebraically useful. Negative values may be viewed as an extended antiferromagnetic coordinate, and the full line is the natural domain for stereographic compactification.

**Definition 2.2 (Discrete one-step beta observable).** Define

$$
B(g)=R(g)-g=g^2-g.
$$

The word “discrete” is essential. In a continuous renormalization semigroup $R_t$, a beta function is normally the infinitesimal generator

$$
\beta(g)=\left.\frac{d}{dt}R_t(g)\right|_{t=0}.
$$

By contrast, $B(g)$ records displacement under one finite blocking step. It is useful for fixed points and direction of motion, but it is not automatically a continuous beta function.

## 3. Stereographic compactification

Let $S^1=\{(x,y)\in\mathbb R^2:x^2+y^2=1\}$ be the unit circle. We use the south pole $(0,-1)$ as the point omitted by the chart.

**Definition 3.1 (Inverse stereographic map).** Define $S:\mathbb R\to\mathbb R^2$ by

$$
S(g)=\left(\frac{2g}{1+g^2},\frac{1-g^2}{1+g^2}\right).
$$

The denominator $1+g^2$ is strictly positive for real $g$, so $S$ is globally defined. The first coordinate is odd and the second is even. Representative values are

$$
S(0)=(0,1),\qquad S(1)=(1,0),\qquad S(-1)=(-1,0).
$$

As $|g|\to\infty$, $S(g)\to(0,-1)$. Thus the missing south pole compactifies the two ends of the real line into a single point at infinity.

**Theorem 3.2 (Unit-circle image).** For every $g\in\mathbb R$, the point $S(g)$ lies on $S^1$; equivalently,

$$
\left(\frac{2g}{1+g^2}\right)^2+
\left(\frac{1-g^2}{1+g^2}\right)^2=1.
$$

**Proof sketch.** Put the two terms over the common denominator $(1+g^2)^2$. The numerator is

$$
4g^2+(1-g^2)^2=4g^2+1-2g^2+g^4=(1+g^2)^2.
$$

Division by the positive denominator gives $1$. $\square$

The inverse chart on $S^1\setminus\{(0,-1)\}$ is

$$
g=\frac{x}{1+y}.
$$

Indeed, for $(x,y)=S(g)$,

$$
\frac{x}{1+y}
=\frac{2g/(1+g^2)}{1+(1-g^2)/(1+g^2)}
=g.
$$

This confirms that $S$ is not merely a parametrized curve: it is a bijective coordinate identification between the real coupling line and the punctured circle.

## 4. The induced rational circle dynamics

We now give a circle-coordinate formula for the Ising update.

**Definition 4.1 (Rational circle update).** For a pair $(x,y)\in\mathbb R^2$ at which the denominators are nonzero, define

$$
C(x,y)=\left(\frac{x^2}{2-x^2},\frac{2y}{1+y^2}\right).
$$

On the unit circle, $x^2\leq1$, so $2-x^2\geq1$. Also, $1+y^2\geq1$. Hence both denominators are nonzero, and $C$ is defined everywhere on $S^1$.

**Theorem 4.2 (Stereographic conjugacy).** For every $g\in\mathbb R$,

$$
S(R(g))=C(S(g)).
$$

Equivalently, the diagram

$$
\begin{array}{ccc}
\mathbb R & \xrightarrow{R} & \mathbb R\\
\downarrow S & & \downarrow S\\
S^1\setminus\{(0,-1)\} & \xrightarrow{C} & S^1\setminus\{(0,-1)\}
\end{array}
$$

commutes.

**Proof sketch.** Write

$$
x=\frac{2g}{1+g^2},\qquad y=\frac{1-g^2}{1+g^2}.
$$

For the first coordinate,

$$
\frac{x^2}{2-x^2}
=\frac{4g^2/(1+g^2)^2}{2-4g^2/(1+g^2)^2}
=\frac{2g^2}{(1+g^2)^2-2g^2}.
$$

The denominator simplifies according to

$$
(1+g^2)^2-2g^2=1+g^4,
$$

so

$$
\frac{x^2}{2-x^2}=\frac{2g^2}{1+g^4}.
$$

For the second coordinate,

$$
\frac{2y}{1+y^2}
=\frac{2(1-g^2)/(1+g^2)}{1+(1-g^2)^2/(1+g^2)^2}
=\frac{2(1-g^2)(1+g^2)}{(1+g^2)^2+(1-g^2)^2}.
$$

The numerator is $2(1-g^4)$ and the denominator is $2(1+g^4)$, yielding

$$
\frac{2y}{1+y^2}=\frac{1-g^4}{1+g^4}.
$$

Therefore

$$
C(S(g))=\left(\frac{2g^2}{1+g^4},\frac{1-g^4}{1+g^4}\right)=S(g^2)=S(R(g)).
$$

All denominators appearing in the calculation are positive. $\square$

**Corollary 4.3 (Circle preservation along the stereographic image).** For every real $g$, $C(S(g))\in S^1$.

**Proof sketch.** By Theorem 4.2, $C(S(g))=S(g^2)$, and Theorem 3.2 places $S(g^2)$ on the unit circle. $\square$

The map $C$ has been written in a form that uses each Cartesian coordinate separately. This apparent separation is special to points constrained by $x^2+y^2=1$ and to the chosen stereographic chart. Away from the circle, $C$ is simply a rational plane map; the physical geometric statement concerns its restriction to the stereographic image.

## 5. Fixed couplings and flow direction

A finite coupling is fixed by one decimation step precisely when its discrete displacement vanishes.

**Theorem 5.1 (Finite fixed-coupling classification).** For $g\in\mathbb R$,

$$
B(g)=0
$$

if and only if

$$
g=0\quad\text{or}\quad g=1.
$$

**Proof sketch.** Factor the observable:

$$
B(g)=g^2-g=g(g-1).
$$

A product of real numbers is zero exactly when one factor is zero. Conversely, direct substitution shows $B(0)=B(1)=0$. $\square$

Under $S$, these fixed couplings correspond to

$$
S(0)=(0,1),\qquad S(1)=(1,0).
$$

Thus the north pole and the eastern equatorial point are the two finite-coupling fixed points in the compactified picture. The south pole represents infinite coupling and is not attained by any finite $g$ in this chart.

On the physical interval, the sign of $B$ gives the direction of the flow.

**Proposition 5.2 (One-step contraction in the physical interior).** If $0<g<1$, then

$$
0<R(g)<g
$$

and therefore $B(g)<0$.

**Proof sketch.** Positivity gives $g^2>0$. Multiplying $g<1$ by the positive number $g$ gives $g^2<g$. $\square$

The map therefore moves every interior physical coupling toward weak coupling. Although a full iteration theorem is beyond the core one-step results, repeated squaring makes the expected behavior transparent: each step doubles the exponent. This motivates the formula $R^n(g)=g^{2^n}$ and convergence to zero for $0\leq g<1$ as natural extensions.

## 6. Linearization and the discrete beta derivative

The local response of a renormalization map is encoded by its derivative.

**Theorem 6.1 (Derivative of the Ising update).** For every $g\in\mathbb R$, the map $R(g)=g^2$ is differentiable and

$$
R'(g)=2g.
$$

**Proof sketch.** Using the difference quotient,

$$
\frac{R(g+h)-R(g)}{h}
=\frac{(g+h)^2-g^2}{h}
=2g+h
$$

for $h\neq0$. Taking $h\to0$ yields $2g$. $\square$

At the fixed point $g=0$, the multiplier is $R'(0)=0$, expressing strong local contraction. At $g=1$, it is $R'(1)=2$, so perturbations are expanded to first order in the unrestricted real coordinate.

**Theorem 6.2 (Derivative of the discrete beta observable).** For every $g\in\mathbb R$, the function $B(g)=R(g)-g$ is differentiable and

$$
B'(g)=2g-1.
$$

**Proof sketch.** Differentiate $B(g)=g^2-g$ term by term and apply Theorem 6.1. $\square$

The derivative vanishes at $g=1/2$. Since $B''(g)=2>0$, the one-step displacement reaches its minimum there:

$$
B\left(\frac12\right)=-\frac14.
$$

This is the largest negative displacement in absolute coupling units on $[0,1]$. It is a coordinate-dependent statement: after a nonlinear reparametrization, numerical displacements and derivatives change.

Conjugacy provides the correct relation between derivatives in different coordinates. If a one-dimensional chart coordinate $u$ is changed by a differentiable bijection $u=h(g)$, then the transformed map is

$$
\widetilde R=h\circ R\circ h^{-1}.
$$

At corresponding points, its derivative satisfies

$$
\widetilde R'(h(g))=\frac{h'(R(g))}{h'(g)}R'(g),
$$

provided the derivatives exist and $h'(g)\neq0$. At a fixed point $R(g_*)=g_*$, the chart factors cancel, so the multiplier is invariant under regular one-dimensional coordinate changes:

$$
\widetilde R'(h(g_*))=R'(g_*).
$$

This distinction explains why fixed-point eigenvalues are geometrically robust while a beta formula away from a fixed point is scheme dependent.

## 7. Numerical algorithms and examples

The formulas require only elementary arithmetic and are stable on the real line because $1+g^2>0$. For a finite list of couplings, each update and stereographic conversion takes constant time and memory.

### 7.1 Direct decimation

Given $g$, compute $R(g)=g^2$ and $B(g)=g^2-g$. The derivative data are $2g$ and $2g-1$. A representative table is

| $g$ | $R(g)$ | $B(g)$ | $R'(g)$ | $B'(g)$ |
|---:|---:|---:|---:|---:|
| $0$ | $0$ | $0$ | $0$ | $-1$ |
| $1/4$ | $1/16$ | $-3/16$ | $1/2$ | $-1/2$ |
| $1/2$ | $1/4$ | $-1/4$ | $1$ | $0$ |
| $3/4$ | $9/16$ | $-3/16$ | $3/2$ | $1/2$ |
| $1$ | $1$ | $0$ | $2$ | $1$ |

### 7.2 Conjugacy check

For each input $g$, compute two paths:

$$
P_1=S(R(g)),\qquad P_2=C(S(g)).
$$

Theorem 4.2 says $P_1=P_2$ exactly. In floating-point arithmetic, the Euclidean residual

$$
\varepsilon(g)=\|P_1-P_2\|_2
$$

should be near machine precision. This residual is a numerical diagnostic, not a substitute for the algebraic theorem.

### 7.3 Iterated visualization

Starting from $g_0\in[0,1]$, define $g_{n+1}=g_n^2$ and plot $S(g_n)$ on the circle. Interior points move toward $(0,1)$, while $g_0=1$ remains at $(1,0)$. The corresponding coupling values shrink rapidly because squaring compounds at each step.

## 8. Physical interpretation and limitations

The conjugacy offers a compact global portrait of the exact Ising recursion. Weak coupling, strong coupling, negative coupling, and the point at infinity occupy a single bounded geometry. Rational circle coordinates may be useful when comparing maps under Möbius transformations or when constructing atlases with different stereographic poles.

Nevertheless, the result should be interpreted with precision.

First, $B(g)=R(g)-g$ is a finite-step observable. A continuous beta function requires a scale parameter and a semigroup or flow law. Without these, identifying $B$ with an infinitesimal generator would conflate discrete and continuous notions.

Second, derivatives depend on coordinates away from fixed points. The equality $R'(g)=2g$ is the derivative in the coupling chart $g$. A tangent derivative in another chart includes Jacobian factors. At a regular fixed point, the linear multiplier is preserved by conjugacy, but a global beta formula is not generally invariant.

Third, the construction does not establish a corresponding identity for four-dimensional $\phi^4$ theory. Such a comparison requires the spacetime dimension, regulator, subtraction prescription, coupling normalization, and perturbative order to be fixed. A more plausible coordinate-independent target is local conjugacy of flows near a hyperbolic fixed point rather than literal equality of formulas written in unrelated schemes.

Fourth, the recursion $g'=g^2$ has here been used as the standard exact decimation law. A complete statistical-mechanical development can derive it from the partition function or transfer matrix, tracking the additive constant in the effective free energy as well as the transformed coupling.

## 9. Applications

### 9.1 Compact phase portraits

The stereographic chart turns an unbounded coupling axis into a circle. This can improve qualitative visualization, particularly when extended models permit trajectories toward large positive or negative coupling. The omitted pole records infinity without assigning it a finite coupling value.

### 9.2 Fixed-point diagnostics

The factorization $B(g)=g(g-1)$ gives an exact fixed-point classifier. The derivatives $R'(0)=0$ and $R'(1)=2$ distinguish contraction from expansion. Because fixed-point multipliers survive regular coordinate conjugacy, they provide a natural bridge between algebraic and geometric descriptions.

### 9.3 Testing geometric renormalization proposals

Any proposed geometric representation of an RG map should satisfy at least three checks: the chart must land on its claimed manifold, the induced geometric map must be globally well-defined on the relevant image, and the conjugacy identity must hold. The present model meets all three exactly. It therefore provides a benchmark for more elaborate constructions involving changing poles or higher-dimensional coupling spaces.

### 9.4 Educational computation

The model is simple enough to compute by hand yet rich enough to illustrate compactification, conjugacy, fixed points, linearization, coordinate dependence, and discrete versus continuous scale evolution. Numerical plots can display both the coupling trajectory and its circle image without approximation in the underlying formulas.

## 10. Future work

A first extension is to establish the exact iterate

$$
R^n(g)=g^{2^n}
$$

and prove convergence to $0$ for every $0\leq g<1$. Conjugacy would immediately transport this theorem to convergence of circle trajectories toward $(0,1)$.

A second extension is to derive the recursion from spin summation or the transfer matrix. This would connect the geometric dynamics directly to the partition function and identify the free-energy normalization generated by decimation.

A third direction is to introduce a continuous family $R_t$ satisfying $R_{s+t}=R_s\circ R_t$. Its infinitesimal generator would define a genuine continuous beta function and permit a careful comparison with the one-step displacement.

A fourth direction is to vary the stereographic pole. Different poles are related by circle automorphisms, and scale-dependent chart choices lead naturally to cocycle conditions. Determining when these transformations define a consistent RG semigroup would turn the fixed-chart example into a broader geometric theory.

Finally, any comparison with $\phi^4$ theory should begin only after fixing dimension, regularization, subtraction scheme, and coupling normalization. Local flow conjugacy near a hyperbolic fixed point is a mathematically better-motivated objective than literal equality between coordinate-dependent beta expressions.

## 11. Relation to conformal geometry

Stereographic projection is conformal: wherever the chart is regular, it preserves angles between tangent directions. In the present one-dimensional coupling problem, this property is less visible than it would be for a multidimensional coupling manifold, because a one-dimensional tangent space has no nontrivial angle structure. The important immediate benefits are rational parametrization and compactification. Nevertheless, the construction identifies the correct architecture for higher-dimensional questions: choose a geometric compactification, transport the RG map by conjugacy, and distinguish invariant dynamical data from chart-dependent formulas.

The circle map also admits an angular description. If $g=\tan(\theta/2)$, then

$$
S(g)=(\sin\theta,\cos\theta).
$$

The decimation law becomes

$$
\tan\left(\frac{\theta'}{2}\right)=\tan^2\left(\frac{\theta}{2}\right).
$$

This equation is equivalent to the Cartesian rational map, but the Cartesian form avoids branch choices for inverse trigonometric functions. On the physical interval $0\leq g\leq1$, one has $0\leq\theta\leq\pi/2$, so the angular interpretation is unambiguous: decimation decreases $\theta$ in the interior and fixes both endpoints.

From a dynamical-systems perspective, the theorem is a global conjugacy between $R$ on the finite line and $C$ on the punctured circle. Extending to the south pole compactifies the dynamics continuously: as $|g|\to\infty$, $g^2\to+\infty$, and both the initial and updated images approach $(0,-1)$. Thus the south pole is a fixed point of the extended circle map, although it is not a finite solution of $B(g)=0$. Keeping these two classifications separate prevents compactification from being mistaken for the creation of an additional finite physical coupling.

## 12. Reproducibility of numerical illustrations

The numerical consequences can be reproduced with four elementary functions: squaring for $R$, subtraction for $B$, the two rational expressions for $S$, and the two rational expressions for $C$. A robust implementation should compare $S(R(g))$ with $C(S(g))$ using a tolerance scaled to floating-point precision, and should separately test the circle residual $|x^2+y^2-1|$. For $N$ sampled couplings, both tests require $O(N)$ arithmetic operations and $O(1)$ auxiliary memory if results are streamed.

Plots should distinguish exact mathematical claims from floating-point diagnostics. A residual near $10^{-16}$ illustrates that two evaluation paths agree at double precision, but the exact equality follows from the algebra in Theorem 4.2. Similarly, a plotted orbit suggests convergence, whereas a convergence theorem requires the iterate formula and an analytic limit argument. This separation of theorem, algorithm, and visualization is especially important when the same framework is extended to models whose RG recursions are available only numerically.

## 12.1 Scope of the established statements

The exact claims in this study are deliberately confined to one renormalization step and its local derivative. They require no asymptotic expansion: the circle identity holds for every finite real $g$, including values outside the physical ferromagnetic interval. The fixed-point classification likewise concerns all finite real couplings. Statements about repeated iteration, convergence, continuous-time generators, varying poles, and field-theory comparisons are proposed extensions rather than assumptions used in the proofs.

This limited scope is a strength. The model separates what follows from elementary rational algebra from what needs additional statistical mechanics or dynamical-systems structure. In particular, the conjugacy theorem needs only the formulas for $R$, $S$, and $C$; physical interpretation enters when selecting $0\leq g<1$ and identifying temperature regimes. The same separation can guide future applications: first establish a precise map and chart, then attach the physical meaning appropriate to the model.

## 13. Conclusion

The zero-field one-dimensional Ising decimation map in the coordinate $g=\tanh K$ is $R(g)=g^2$. Inverse stereographic projection sends the coupling line to the unit circle, and the rational transformation

$$
C(x,y)=\left(\frac{x^2}{2-x^2},\frac{2y}{1+y^2}\right)
$$

makes the relation exact:

$$
S\circ R=C\circ S.
$$

The finite fixed couplings are precisely $0$ and $1$, the update derivative is $2g$, and the derivative of the discrete displacement is $2g-1$. Together these statements give a complete one-step geometric portrait of the solvable recursion. The portrait is modest in scope but exact in content: coarse-graining on the coupling line and rational dynamics on the circle are the same transformation in two coordinate systems.
