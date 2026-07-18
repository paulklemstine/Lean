# The Saddle That Flattens at One Point

## How a coordinate formula becomes an intrinsic law of geometry

Imagine a sheet whose rulers change from place to place. Moving horizontally near a point $(x,y)$ costs distance according to the factor $1/\cosh y$, while moving vertically costs according to $\cosh x$. The resulting squared line element is

$$
ds^2=\frac{dx^2}{\cosh^2 y}+\cosh^2 x\,dy^2.
$$

This is not an ordinary rubber sheet sitting in three-dimensional space. It is a geometry specified from within: the formula tells an inhabitant how to measure every infinitesimal journey. The horizontal and vertical directions respond to different coordinates. Far from the horizontal axis, horizontal travel becomes cheap because $1/\cosh y$ decays rapidly. Far from the vertical axis, vertical travel becomes expensive because $\cosh x$ grows rapidly. The plane is therefore strongly anisotropic, stretched in one direction and compressed in the other.

What shape does such a world have? A direct curvature calculation gives a striking answer. Its curvature is never positive. It is exactly zero at the origin and strictly negative everywhere else. More importantly, this is not an artifact of the chosen horizontal and vertical coordinates: every genuine two-directional frame at a point measures exactly the same curvature.

That last sentence is the central idea. Coordinates are scaffolding; intrinsic geometry is the building.

## The metric behind the story

At a point $p=(x,y)$, represent tangent directions by pairs $u=(u_1,u_2)$ and $v=(v_1,v_2)$. Their metric inner product is

$$
g_p(u,v)=\frac{u_1v_1}{\cosh^2 y}+\cosh^2 x\,u_2v_2.
$$

Because $\cosh t>0$ for every real $t$, both coefficients are positive. Thus $g_p(u,u)>0$ whenever $u\ne 0$: the formula really defines a smooth positive-definite geometry on the whole plane.

The coordinate computation produces the Gaussian-curvature expression

$$
K(x,y)=-\cosh^2 y+
\frac{1-\sinh^2 y}{\cosh^2 x\cosh^2 y}.
$$

At first sight, this formula looks tied to the coordinate grid. It explicitly contains $x$ and $y$, and it arose by differentiating coordinate coefficients. Why should a tilted pair of directions agree with the coordinate axes? The answer comes from an elementary determinant identity that is special and powerful in two dimensions.

## Area is the bridge

For two tangent vectors $u$ and $v$, define their oriented coordinate area by

$$
\omega(u,v)=u_1v_2-u_2v_1.
$$

The value $\omega(u,v)$ vanishes exactly when the vectors are parallel. Its square is the Euclidean area squared of the parallelogram they span. In the varying metric, the corresponding squared area is the Gram determinant

$$
\Gamma_p(u,v)=g_p(u,u)g_p(v,v)-g_p(u,v)^2.
$$

Expanding the terms yields the Gram Determinant Identity:

$$
\Gamma_p(u,v)=rac{\cosh^2 x}{\cosh^2 y}\,\omega(u,v)^2.
$$

This compact equality does nearly all the conceptual work. The first factor is the determinant of the metric matrix. The second is the square of coordinate area. Since the metric determinant is positive, every nonparallel pair has $\Gamma_p(u,v)>0$. Such a pair spans the tangent plane and is called a nondegenerate frame.

The identity also tells us why two-dimensional curvature is unusually rigid. In two dimensions there is only one independent tangent two-plane. Different nondegenerate frames change its area, orientation, and shape, but they do not create a new plane.

## Reconstructing curvature from one scalar

The scalar $K(p)$ determines a four-direction curvature quantity by

$$
R_p(u,v,w,z)=K(p)
\bigl(g_p(u,w)g_p(v,z)-g_p(u,z)g_p(v,w)\bigr).
$$

This expression has the characteristic symmetries expected of curvature. Swapping $u$ and $v$ reverses its sign; swapping $w$ and $z$ does the same. Interchanging the two pairs leaves it unchanged. It also obeys the cyclic identity

$$
R_p(u,v,w,z)+R_p(v,w,u,z)+R_p(w,u,v,z)=0.
$$

These are not decorative algebraic facts. They show that the formula behaves like a genuine Riemann curvature tensor, independently of any preferred frame.

Evaluate it twice on the same pair of directions. One obtains

$$
R_p(u,v,u,v)=K(p)\Gamma_p(u,v).
$$

For a nondegenerate frame, the sectional curvature is the quotient of curvature by squared metric area:

$$
\operatorname{Sec}_p(u,v)=
\frac{R_p(u,v,u,v)}{\Gamma_p(u,v)}.
$$

The positive Gram determinant cancels, giving the Intrinsic Curvature Identification Theorem:

$$
\operatorname{Sec}_p(u,v)=K(p)
$$

for every point $p$ and every nonparallel pair $u,v$. Tilt the frame, stretch one vector, reverse its orientation, or choose wildly skew directions: the answer remains the same. The coordinate formula has become an intrinsic geometric law.

Parallel vectors are deliberately excluded. They enclose no area, so both numerator and denominator vanish and no two-plane is represented. This is geometry, not a removable numerical inconvenience.

## A world that is almost everywhere saddle-shaped

The curvature formula can be explored numerically, but its sign has an exact description. The Curvature Sign Theorem states that

$$
K(x,y)\le 0
$$

for every $(x,y)\in\mathbb R^2$, with

$$
K(x,y)=0 \quad\Longleftrightarrow\quad (x,y)=(0,0).
$$

Consequently every nondegenerate sectional curvature is strictly negative away from the origin.

The origin is therefore not a boundary between positive and negative regions. There is no positive-curvature side. Instead, one isolated flat point sits inside a sea of negative curvature. Near that point the geometry becomes flat to lowest order, yet any nonzero displacement restores saddle behavior.

Some sample values convey the anisotropy. At the origin, $K(0,0)=0$. Along the horizontal axis,

$$
K(x,0)=-1+\frac{1}{\cosh^2 x}=-\tanh^2 x,
$$

which decreases from $0$ toward $-1$ as $|x|$ grows. Along the vertical axis,

$$
K(0,y)=-\cosh^2 y+
\frac{1-\sinh^2 y}{\cosh^2 y},
$$

and the large negative term $-\cosh^2 y$ dominates rapidly. The curvature landscape is symmetric under $x\mapsto -x$ and $y\mapsto -y$, but it is far steeper vertically than horizontally.

## Why intrinsic identification matters

Curvature governs how nearby geodesics separate, how triangles differ from Euclidean triangles, and how waves and diffusion respond to the geometry. A coordinate-only value is not enough for these purposes. If changing the tangent frame changed the measured curvature, the number would describe the chart rather than the surface.

The sectional quotient solves that problem. Its numerator measures the curvature associated with a two-frame, while its denominator removes the arbitrary squared area of that frame. The Gram identity proves that this normalization is always legitimate for nonparallel vectors. The resulting scalar is available to every observer, regardless of how that observer labels directions.

This also clarifies the role of dimension. On a surface, every nondegenerate pair spans the entire tangent plane, so a single scalar controls the full algebraic curvature tensor. In higher dimensions, different two-planes can have different sectional curvatures; one number no longer suffices. The present geometry showcases the exceptional economy of two dimensions.

## What the theorem does not yet say

Negative curvature often suggests dramatic global behavior: geodesics may diverge, loops may be rigid, and shortest paths may be unique. Those expectations are reasonable here, but they do not follow from the algebraic curvature calculation alone.

The geodesic equations must first be derived from the smooth metric coefficients. Because the coefficients couple $x$ and $y$, the resulting differential equations are coupled and nonlinear. There is no basis for treating their solutions as merely piecewise exponential or trigonometric. Questions of existence for all time, repeated passage through the origin, and uniqueness of connecting geodesics demand careful analysis of that actual system.

Area questions require equal care. The metric area density is the square root of the metric determinant:

$$
dA=\sqrt{\frac{\cosh^2 x}{\cosh^2 y}}\,dx\,dy
=\frac{\cosh x}{\cosh y}\,dx\,dy.
$$

Thus the area of a specified region $\Omega$ is

$$
\operatorname{Area}(\Omega)=
\iint_\Omega \frac{\cosh x}{\cosh y}\,dx\,dy.
$$

For a geodesic triangle, one must specify three vertices and the geodesic segments joining them. Saying that vertices lie in different curvature regions cannot determine an area, because there is only one nonpositive region together with a single flat point.

## A small formula with a large reach

The geometry began with two coordinate weights. It ended with a frame-independent curvature theorem. The bridge was not a mysterious change of language, but the squared area of a parallelogram.

The complete picture is concise. The split metric is smooth and positive definite. Its Gram determinant equals the metric determinant times coordinate area squared. The scalar curvature reconstructs a four-tensor with the standard curvature symmetries. Dividing its value on a frame by the frame’s metric area returns the same scalar for every nondegenerate frame. That scalar is nonpositive everywhere, zero only at the origin, and strictly negative elsewhere.

So the plane is a saddle world with one perfectly flat point—not a phase transition, but an isolated moment of balance. The next chapter belongs to motion: whether geodesics exist forever, whether any can revisit the flat point, and whether the origin’s exponential map unfolds the entire plane without overlap. The curvature theorem does not settle those questions. It does something more foundational: it establishes the invariant landscape on which all of them must be asked.
