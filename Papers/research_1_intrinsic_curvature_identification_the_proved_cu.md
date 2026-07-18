# Intrinsic Curvature of an Anisotropic Hyperbolic-Coefficient Plane

## Abstract

We study the smooth Riemannian metric on $\mathbb R^2$ given by

$$
g=\cosh(y)^{-2}\,dx^2+\cosh(x)^2\,dy^2.
$$

Its coefficients create strong anisotropy: horizontal displacement becomes inexpensive as $|y|$ grows, whereas vertical displacement becomes expensive as $|x|$ grows. A coordinate Brioschi calculation yields the Gaussian-curvature expression

$$
K(x,y)=-\cosh^2 y+
\frac{1-\sinh^2 y}{\cosh^2x\cosh^2y}.
$$

The purpose of this paper is to identify this scalar intrinsically. We define the algebraic curvature tensor determined by $K$ and the metric, establish its alternating, pair-interchange, and Bianchi symmetries, and prove that its sectional quotient equals $K$ for every nondegenerate tangent frame. The key calculation is a Gram determinant identity: metric area squared equals the metric determinant multiplied by oriented coordinate area squared. We then establish that $K$ is nonpositive everywhere, vanishes exactly at $(0,0)$, and is strictly negative elsewhere. Algorithms for stable numerical evaluation, frame-invariance testing, and curvature-landscape sampling are given, together with consequences for area and a precise account of the global geometric questions that remain open.

## 1. Introduction

Consider the plane equipped not with the Euclidean metric, but with the diagonal line element

$$
ds^2=\frac{dx^2}{\cosh^2 y}+\cosh^2 x\,dy^2.
$$

The two coefficients pull in opposite geometric directions. At large $|y|$, the horizontal coefficient $\cosh(y)^{-2}$ is small, while at large $|x|$, the vertical coefficient $\cosh(x)^2$ is large. Since neither coefficient is uniformly comparable to a fixed positive constant on the full plane, global questions such as metric completeness cannot be answered by a simple comparison with the Euclidean metric.

A direct coordinate calculation provides the scalar

$$
K(x,y)=-\cosh^2 y+
\frac{1-\sinh^2 y}{\cosh^2x\cosh^2y}.
$$

A coordinate formula for Gaussian curvature is geometrically useful only once it is shown to agree with an invariant measurement. On a two-dimensional Riemannian manifold, the relevant invariant is sectional curvature: evaluate a curvature tensor on two independent tangent vectors and divide by the squared metric area of their parallelogram. Although there is only one tangent two-plane at each point, a complete argument must show that the quotient is independent of the selected frame and that its denominator is positive.

This paper gives that argument in elementary algebraic terms. Let $p=(x,y)$ and let $u=(u_1,u_2)$ and $v=(v_1,v_2)$ be tangent vectors. Their oriented coordinate area is

$$
\omega(u,v)=u_1v_2-u_2v_1.
$$

Their squared metric area is the Gram determinant

$$
\Gamma_p(u,v)=g_p(u,u)g_p(v,v)-g_p(u,v)^2.
$$

The identity

$$
\Gamma_p(u,v)=\frac{\cosh^2x}{\cosh^2y}\,\omega(u,v)^2
$$

shows that $\Gamma_p(u,v)>0$ precisely when $u$ and $v$ are independent. It also makes the frame cancellation in the sectional quotient transparent.

The main conclusions are as follows.

1. The scalar $K$ determines an algebraic curvature tensor with all standard Riemann symmetries.
2. Every nondegenerate tangent frame has sectional curvature $K(p)$.
3. The curvature is nonpositive everywhere, vanishes only at the origin, and is strictly negative at every other point.
4. The zero-curvature locus is an isolated point, not a boundary separating positive and negative regions.

These statements are local and algebraic. They provide the necessary curvature input for, but do not by themselves prove, completeness, global uniqueness of geodesics, injectivity of the exponential map, or quantitative divergence of Jacobi fields.

## 2. Metric, tangent frames, and area

### 2.1. The metric

Let $M=\mathbb R^2$. At $p=(x,y)$ define

$$
g_p(u,v)=E(p)u_1v_1+G(p)u_2v_2,
$$

where

$$
E(x,y)=\cosh(y)^{-2},
\qquad
G(x,y)=\cosh(x)^2.
$$

Since $\cosh t>0$ for all $t\in\mathbb R$, both $E$ and $G$ are smooth and strictly positive. Hence $g$ is a smooth positive-definite Riemannian metric. Its matrix and determinant in the coordinate basis are

$$
[g_p]=
\begin{pmatrix}
\cosh(y)^{-2}&0\\
0&\cosh(x)^2
\end{pmatrix},
\qquad
\det g_p=\frac{\cosh^2x}{\cosh^2y}>0.
$$

The associated area element is therefore

$$
dA_g=\sqrt{\det g_p}\,dx\,dy
=\frac{\cosh x}{\cosh y}\,dx\,dy,
$$

where no absolute values are needed because $\cosh$ is positive.

### 2.2. Nondegenerate frames

A pair $(u,v)$ is called a nondegenerate tangent frame if it is linearly independent. In coordinates this is equivalent to

$$
\omega(u,v)=u_1v_2-u_2v_1\ne 0.
$$

The quantity $\omega$ changes sign when the frame orientation is reversed, but $\omega^2$ does not. Thus $\omega^2$ records squared coordinate area without orientation.

Define the Gram determinant by

$$
\Gamma_p(u,v)=
\det
\begin{pmatrix}
g_p(u,u)&g_p(u,v)\\
g_p(v,u)&g_p(v,v)
\end{pmatrix}.
$$

Equivalently,

$$
\Gamma_p(u,v)=g_p(u,u)g_p(v,v)-g_p(u,v)^2.
$$

This quantity is the squared area of the parallelogram spanned by $u$ and $v$, measured with $g$.

### Lemma 2.1 (Gram Determinant Identity)

For every $p=(x,y)$ and every pair of tangent vectors $u,v$,

$$
\Gamma_p(u,v)=E(p)G(p)\omega(u,v)^2
=\frac{\cosh^2x}{\cosh^2y}\,
(u_1v_2-u_2v_1)^2.
$$

#### Proof sketch

Substitute

$$
g_p(u,u)=Eu_1^2+Gu_2^2,
\quad
g_p(v,v)=Ev_1^2+Gv_2^2,
\quad
g_p(u,v)=Eu_1v_1+Gu_2v_2
$$

into the definition of $\Gamma_p$. The $E^2u_1^2v_1^2$ and $G^2u_2^2v_2^2$ terms cancel. The remaining terms factor as

$$
EG(u_1^2v_2^2+u_2^2v_1^2-2u_1u_2v_1v_2)
=EG(u_1v_2-u_2v_1)^2.
$$

Using $EG=\cosh^2x/\cosh^2y$ gives the stated formula.

### Corollary 2.2 (Positivity of frame area)

If $\omega(u,v)\ne 0$, then $\Gamma_p(u,v)>0$.

#### Proof sketch

The metric determinant $E(p)G(p)$ is strictly positive, and the square of a nonzero real number is strictly positive. Their product is therefore positive.

This positivity is essential: the sectional quotient is defined only for a genuine two-frame. If $u$ and $v$ are parallel, then $\omega(u,v)=0$ and $\Gamma_p(u,v)=0$, so the pair does not represent a two-dimensional direction.

## 3. Gaussian scalar and algebraic curvature tensor

Define

$$
K(p)=K(x,y)=-\cosh^2 y+
\frac{1-\sinh^2 y}{\cosh^2x\cosh^2y}.
$$

From $K$ and $g$, define the covariant four-tensor

$$
R_p(u,v,w,z)=K(p)
\left(g_p(u,w)g_p(v,z)-g_p(u,z)g_p(v,w)\right).
$$

This is the standard two-dimensional reconstruction of an algebraic curvature tensor from its Gaussian scalar, with the sign convention fixed by the ordering displayed above.

### Proposition 3.1 (Alternation in the first pair)

For all tangent vectors $u,v,w,z$,

$$
R_p(v,u,w,z)=-R_p(u,v,w,z).
$$

#### Proof sketch

Symmetry of the metric gives $g_p(v,w)g_p(u,z)-g_p(v,z)g_p(u,w)$ after swapping $u$ and $v$. Reordering scalar factors shows that this is the negative of the original bracket.

### Proposition 3.2 (Alternation in the second pair)

For all tangent vectors $u,v,w,z$,

$$
R_p(u,v,z,w)=-R_p(u,v,w,z).
$$

#### Proof sketch

Swapping $w$ and $z$ exchanges the two products in the defining difference, reversing its sign.

### Proposition 3.3 (Pair-interchange symmetry)

For all tangent vectors $u,v,w,z$,

$$
R_p(w,z,u,v)=R_p(u,v,w,z).
$$

#### Proof sketch

Use symmetry of $g_p$ to rewrite $g_p(w,u)$ as $g_p(u,w)$ and similarly for the other terms. Commutativity of scalar multiplication then returns the original expression.

### Proposition 3.4 (Algebraic first Bianchi identity)

For all tangent vectors $u,v,w,z$,

$$
R_p(u,v,w,z)+R_p(v,w,u,z)+R_p(w,u,v,z)=0.
$$

#### Proof sketch

Expand the three terms. Each product of two metric pairings occurs twice with opposite signs. The six terms cancel in pairs.

Together, Propositions 3.1–3.4 establish the standard algebraic symmetries of a Riemann curvature tensor. These results are basis-independent because their statements involve only vectors, the metric, and scalar operations.

## 4. Intrinsic curvature identification

### Lemma 4.1 (Curvature on a repeated frame)

For every point $p$ and tangent vectors $u,v$,

$$
R_p(u,v,u,v)=K(p)\Gamma_p(u,v).
$$

#### Proof sketch

Set $w=u$ and $z=v$ in the definition of $R$. The bracket becomes

$$
g_p(u,u)g_p(v,v)-g_p(u,v)g_p(v,u).
$$

Since the metric is symmetric, $g_p(v,u)=g_p(u,v)$, so the bracket is exactly $\Gamma_p(u,v)$.

For a nondegenerate frame, define its sectional quotient by

$$
\operatorname{Sec}_p(u,v)=
\frac{R_p(u,v,u,v)}{\Gamma_p(u,v)}.
$$

### Theorem 4.2 (Intrinsic Curvature Identification)

For every $p\in\mathbb R^2$ and every nondegenerate tangent frame $(u,v)$,

$$
\operatorname{Sec}_p(u,v)=K(p).
$$

#### Proof sketch

By Lemma 4.1, the numerator is $K(p)\Gamma_p(u,v)$. By Corollary 2.2, the Gram determinant is nonzero. Cancelling it gives the result.

### Discussion

The theorem converts a coordinate scalar into a frame-independent geometric invariant. Rescaling either frame vector multiplies both numerator and denominator by the same squared factor. Reversing orientation changes $\omega$ but leaves $\omega^2$ and the quotient unchanged. Replacing the frame by any other independent pair again leaves the quotient equal to $K(p)$.

The result reflects a special feature of surfaces. At a point of a two-dimensional manifold, every nondegenerate pair spans the same tangent two-plane. The one-dimensionality of the metric wedge square means that a single sectional value determines the full algebraic curvature tensor. In higher dimensions, distinct two-planes may carry distinct sectional curvatures, so a single scalar cannot generally reconstruct the tensor.

## 5. Sign and zero locus of curvature

### Theorem 5.1 (Global nonpositivity)

For every $(x,y)\in\mathbb R^2$,

$$
K(x,y)\le 0.
$$

#### Proof sketch

The denominators $\cosh^2x$ and $\cosh^2y$ are positive. One may combine terms over the positive denominator $\cosh^2x\cosh^2y$ and use the hyperbolic identity

$$
\cosh^2t-\sinh^2t=1.
$$

After replacing $\cosh^2x$ and $\cosh^2y$ by $1+\sinh^2x$ and $1+\sinh^2y$, the desired inequality reduces to a sum of products and squares of $\sinh^2x$ and $\sinh^2y$ with nonnegative coefficients. Equivalently, moving the numerator to the opposite side exhibits it as nonnegative. Since the common denominator is positive, the original curvature is nonpositive.

For a more explicit sign-transparent form, set

$$
a=\sinh^2x\ge0,
\qquad b=\sinh^2y\ge0.
$$

Then $\cosh^2x=1+a$ and $\cosh^2y=1+b$, and

$$
K(x,y)=-(1+b)+\frac{1-b}{(1+a)(1+b)}.
$$

Multiplication by the positive quantity $(1+a)(1+b)$ gives

$$
(1+a)(1+b)K
=-(1+a)(1+b)^2+(1-b).
$$

The negative of the right-hand side is

$$
(1+a)(1+b)^2-(1-b)
=a+3b+2ab+b^2+ab^2,
$$

which is nonnegative. Hence $K\le0$.

### Theorem 5.2 (Unique flat point)

For every $(x,y)\in\mathbb R^2$,

$$
K(x,y)=0
\quad\Longleftrightarrow\quad
(x,y)=(0,0).
$$

#### Proof sketch

Using the variables $a=\sinh^2x$ and $b=\sinh^2y$ from the preceding proof, equality $K=0$ is equivalent to

$$
a+3b+2ab+b^2+ab^2=0.
$$

Every summand is nonnegative, so equality forces $a=0$ and $b=0$. The hyperbolic sine is zero exactly at zero; therefore $x=y=0$. Conversely, direct substitution gives

$$
K(0,0)=-1+1=0.
$$

### Corollary 5.3 (Strict sectional negativity off the origin)

If $p\ne(0,0)$ and $(u,v)$ is a nondegenerate tangent frame at $p$, then

$$
\operatorname{Sec}_p(u,v)<0.
$$

#### Proof sketch

Theorem 4.2 identifies the sectional quotient with $K(p)$. Theorem 5.1 gives $K(p)\le0$, while Theorem 5.2 excludes equality away from the origin. Thus $K(p)<0$.

### Geometric interpretation

The zero-curvature locus is the singleton $\{(0,0)\}$. It is not a curve and does not separate regions of opposite curvature. There is no positive-curvature region at all. The geometry is flat at one isolated point and negatively curved everywhere else.

Along the horizontal axis,

$$
K(x,0)=-1+\frac{1}{\cosh^2x}=-\tanh^2x.
$$

Thus $K(x,0)$ approaches $-1$ as $|x|\to\infty$. Along the vertical axis,

$$
K(0,y)=-(1+b)+\frac{1-b}{1+b},
\qquad b=\sinh^2y,
$$

which tends rapidly to $-\infty$ as $|y|\to\infty$. This contrast quantifies the anisotropic curvature landscape.

## 6. Numerical algorithms

The exact formulas support several transparent computational procedures.

### 6.1. Pointwise curvature evaluation

Given $(x,y)$, compute $c_x=\cosh x$, $c_y=\cosh y$, and $s_y=\sinh y$, then evaluate

$$
K=-c_y^2+\frac{1-s_y^2}{c_x^2c_y^2}.
$$

This uses a constant number of arithmetic and transcendental operations, so its arithmetic complexity is $O(1)$ per point and $O(N)$ for $N$ samples. For very large arguments, direct hyperbolic functions may overflow in floating-point arithmetic. Log-scaled or arbitrary-precision evaluation is then preferable.

### 6.2. Sectional quotient test

Given $p,u,v$, first compute

$$
\omega=u_1v_2-u_2v_1.
$$

If $|\omega|$ falls below a numerical tolerance, reject the frame as degenerate or ill-conditioned. Otherwise compute the three inner products defining $\Gamma$, evaluate $R(u,v,u,v)=K\Gamma$, and divide. The result should agree with $K$ up to floating-point error. The cost is $O(1)$ per frame.

For numerical reliability, the determinant identity

$$
\Gamma=\frac{\cosh^2x}{\cosh^2y}\omega^2
$$

can be compared against the direct Gram formula. Near parallelism, both sectional numerator and denominator become small; the mathematically exact cancellation can become numerically ill-conditioned. Reporting $K$ directly is more stable than dividing two tiny numbers, while the quotient remains useful as an invariance diagnostic.

### 6.3. Grid sampling and visualization

On a rectangular grid with $N_xN_y$ points, evaluate $K$ at each point and record the maximum. The theorem predicts that the maximum is $0$ if the origin is included and is negative otherwise. A heat map reveals even symmetry in each coordinate, a comparatively gentle horizontal approach toward $-1$, and rapid vertical decrease. Time and storage complexity are both $O(N_xN_y)$ if the full grid is retained; streaming extrema require only $O(1)$ auxiliary storage.

## 7. Applications and consequences

### 7.1. Metric area

For any measurable region $\Omega$ for which the integral exists,

$$
\operatorname{Area}_g(\Omega)=
\iint_\Omega\frac{\cosh x}{\cosh y}\,dx\,dy.
$$

For a coordinate rectangle $[a,b]\times[c,d]$, the density separates, giving

$$
\operatorname{Area}_g
=\left(\int_a^b\cosh x\,dx\right)
\left(\int_c^d\frac{dy}{\cosh y}\right).
$$

This formula provides direct numerical checks and shows that metric area grows rapidly with horizontal extent but is damped at large vertical coordinate.

A geodesic triangle requires three specified vertices and selected geodesic segments joining them. Its area is the integral of the same density over the enclosed region. Curvature signs alone do not determine a numerical area, and the isolated flat point cannot serve as one of several “curvature regions.”

### 7.2. Frame-independent input for variational equations

Jacobi fields along a geodesic are controlled by sectional curvature in the plane generated by the geodesic tangent and a normal variation. Theorem 4.2 ensures that the explicit scalar $K(x,y)$ supplies this input independently of the coordinate representation of the two vectors. Strict negativity away from the origin suggests divergence of nearby geodesics, but quantitative statements require bounds on $K$ along actual geodesics.

### 7.3. Curvature tensor reconstruction

Because the surface is two-dimensional, the formula

$$
R=K(g\owedge g)
$$

in the sign convention used here is completely determined by one scalar function. The established symmetries and the sectional identification show algebraically why no additional directional curvature data are needed. This reconstruction is useful whenever a coordinate calculation produces $K$ but subsequent arguments require tensorial expressions.

## 8. Limitations and open problems

The present results concern the pointwise metric, its algebraic curvature tensor, and the sign of its sectional curvature. They do not establish that the reconstructed algebraic tensor equals the curvature of a particular connection merely by definition; that connection-level identification requires deriving the Levi-Civita connection and comparing its curvature operator with the displayed four-tensor. The coordinate Brioschi calculation motivates the scalar, while a full intrinsic differential-geometric treatment would connect all layers explicitly.

Several global questions are natural.

First, geodesic completeness is unresolved. Conserved speed may prevent finite-time escape because horizontal compression at large $|y|$ is coupled to vertical expansion at large $|x|$, but the metric is not uniformly Euclidean. Proving completeness requires quantitative estimates for the coupled geodesic equations.

Second, a nonconstant geodesic may plausibly pass through the origin at most once. A second passage would form a loop interacting with strict negative curvature away from one point. This intuition must be converted into an argument using geodesic uniqueness, completeness, and comparison geometry.

Third, if completeness is established, the global nonpositive curvature and simple connectivity suggest that the exponential map at the origin should be globally injective and surjective. The isolated zero does not obstruct the usual nonpositive-curvature heuristic, but the needed global hypothesis cannot be skipped.

Fourth, Jacobi-field growth should admit quantitative bounds for geodesics staying outside a fixed neighborhood of the origin. Since strict negativity is not uniform near the origin, an exclusion region or an integrated-curvature condition is necessary.

Finally, one expects rigidity of the two-dimensional curvature reconstruction: compatibility with the metric and one nondegenerate sectional value at each point should determine the full algebraic tensor. The one-dimensionality of the metric wedge square is the core mechanism.

## 9. Conclusion

For the anisotropic metric

$$
g=\cosh(y)^{-2}\,dx^2+\cosh(x)^2\,dy^2,
$$

the coordinate scalar

$$
K(x,y)=-\cosh^2 y+
\frac{1-\sinh^2 y}{\cosh^2x\cosh^2y}
$$

has a complete intrinsic algebraic interpretation. The Gram determinant of any tangent frame equals the positive metric determinant times squared oriented coordinate area. The reconstructed four-tensor satisfies alternation, pair-interchange symmetry, and the first Bianchi identity. On every nondegenerate frame its value is $K$ times squared metric area, so its sectional quotient is exactly $K$.

The sign classification is equally sharp: $K\le0$ everywhere, $K=0$ exactly at the origin, and $K<0$ elsewhere. The surface therefore has one isolated flat point in an otherwise strictly negatively curved landscape. These results provide a coordinate-independent foundation for future analysis of geodesics, completeness, exponential maps, Jacobi fields, and global rigidity.
