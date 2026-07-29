# The Geometry That Refused to Split

## A metric designed to mix expansion and contraction reveals a subtler world

Geometry begins with a question that sounds almost childish: what happens to lines when they travel? On a flat sheet, parallel lines keep their distance. On a sphere, initially parallel paths can bend toward one another. On a saddle, neighboring paths tend to spread apart. These three behaviors—neutral, converging, and diverging—are encoded by zero, positive, and negative Gaussian curvature.

That picture invites an audacious design problem. Could one build a smooth surface whose geometry behaves spherically in one region and hyperbolically in another, with flat diagonal seams separating the two? Better still, could the same coordinate system expand lengths in one direction while contracting them in the other?

A particularly elegant candidate is the metric

$$
ds^2=\frac{dx^2}{\cosh^2 y}+\cosh^2 x\,dy^2.
$$

Here $\cosh t=(e^t+e^{-t})/2$ is the hyperbolic cosine. A metric is a local ruler: it tells us the squared length of a tiny displacement $(dx,dy)$. In this geometry, a small horizontal move has length $|dx|/\cosh y$, while a small vertical move has length $\cosh x\,|dy|$. Far from the horizontal axis, horizontal distances shrink. Far from the vertical axis, vertical distances grow. The plane is therefore pulled and compressed at once.

This construction looks like a natural stage for “split geometry.” One might guess that its curvature is the simple difference

$$
P(x,y)=\operatorname{sech}^2 x-\operatorname{sech}^2 y,
$$

where $\operatorname{sech}t=1/\cosh t$. That field really does change sign across the diagonals $y=x$ and $y=-x$. It is positive where $|x|<|y|$, negative where $|x|>|y|$, and zero on the diagonals. If $P$ were the Gaussian curvature, the plane would contain elliptic and hyperbolic phases joined along two flat boundaries.

But geometry is not governed by visual analogy. Curvature depends not only on the sizes of the metric coefficients but also on how their derivatives interact. When that interaction is computed, the proposed phase portrait disappears.

## The actual curvature

For the metric above, the Gaussian curvature is

$$
K(x,y)=-\cosh^2 y-\operatorname{sech}^2 x
+2\operatorname{sech}^2 x\operatorname{sech}^2 y.
$$

This formula is the central result. Its first term is always at most $-1$. Its second term is negative. Only the final interaction term is positive. The question is whether that positive contribution can ever outweigh the others.

It cannot.

**Global Curvature Theorem.** For every point $(x,y)$ in the plane,

$$
K(x,y)\le 0.
$$

Moreover,

$$
K(x,y)=0 \quad\Longleftrightarrow\quad (x,y)=(0,0).
$$

Thus the curvature is strictly negative at every point except the origin. The proposed geometry does not split into positive and negative regions. Instead, it is a globally saddle-like plane with one isolated flat point.

The diagonals are especially revealing. At every nonzero $t$,

$$
K(t,t)<0
\qquad\text{and}\qquad
K(t,-t)<0.
$$

So the supposed phase boundaries are not flat seams. Their only flat point is their intersection at the origin.

## Why the sign is forced

The proof can be understood through a change of variables. Put

$$
a=\operatorname{sech}^2 x,
\qquad
b=\operatorname{sech}^2 y.
$$

Hyperbolic cosine satisfies $\cosh t\ge 1$, with equality exactly when $t=0$. Consequently,

$$
0<a\le 1,
\qquad
0<b\le 1,
$$

and $\cosh^2 y=1/b$. The curvature becomes

$$
K=-\frac1b-a+2ab.
$$

Multiplying by the positive number $b$ reduces the sign question to

$$
bK=-1-ab+2ab^2.
$$

The positive part can be rearranged as

$$
ab(2b-1).
$$

If $2b-1\le 0$, then this term is nonpositive and cannot cancel the $-1$. If $2b-1>0$, the bounds $a\le1$ and $b\le1$ give

$$
ab(2b-1)\le 2b-1\le1.
$$

Hence $bK\le0$, and therefore $K\le0$. Equality requires every bound in the second case to be sharp. That forces $a=1$ and $b=1$, which in turn forces $x=0$ and $y=0$.

This compact inequality explains the whole landscape. The metric contains an expansive coefficient and a contractive coefficient, but their derivative coupling creates an overwhelmingly negative intrinsic curvature. Direction-dependent stretching is not the same thing as sign-changing curvature.

## A false map that remains useful

The field $P(x,y)=\operatorname{sech}^2x-\operatorname{sech}^2y$ was not meaningless. It accurately records a symmetry in the coordinate scaling. Since $\operatorname{sech}^2 t$ decreases with $|t|$, its zero set consists of the two diagonals. It is a useful schematic “phase field,” just not the Gaussian curvature.

The distinction matters. A phase field may be chosen to summarize a contrast between coordinates. Gaussian curvature, by comparison, is intrinsic: it can be detected by measurements made entirely within the geometry. One can change coordinates without changing it. The two fields agree on being zero simultaneously only at the origin:

$$
P(x,y)=0\ \text{and}\ K(x,y)=0
\quad\Longleftrightarrow\quad
(x,y)=(0,0).
$$

Away from the origin, even points on $P=0$ remain negatively curved.

This is a useful lesson in mathematical model building. A suggestive quantity may organize intuition while failing to represent the invariant one actually cares about. The right response is not to discard the model, but to identify precisely what each quantity measures.

## What an explorer would see

Imagine carrying two tiny measuring rods, one aligned horizontally and one vertically. At $(x,y)$, the horizontal rod is scaled by $\operatorname{sech}y$ and the vertical rod by $\cosh x$. Along the line $x=0$, vertical lengths have their ordinary Euclidean scale, while horizontal lengths shrink as $|y|$ grows. Along $y=0$, horizontal lengths retain their ordinary scale, while vertical lengths expand as $|x|$ grows.

The area element combines these two effects. Since the diagonal metric has determinant

$$
\det g=\frac{\cosh^2x}{\cosh^2y},
$$

an infinitesimal coordinate rectangle has geometric area

$$
dA=\frac{\cosh x}{\cosh y}\,dx\,dy.
$$

Area expands strongly toward large $|x|$ and contracts toward large $|y|$. Thus the geometry is anisotropic even though its curvature never becomes positive. It can look directionally split to a local surveyor while remaining hyperbolic in its intrinsic bending.

Several numerical landmarks make the result tangible. At the origin,

$$
K(0,0)=-1-1+2=0.
$$

At $(1,0)$,

$$
K(1,0)=-1+\operatorname{sech}^2 1<0.
$$

At $(0,1)$,

$$
K(0,1)=-\cosh^2 1-1+2\operatorname{sech}^2 1<0.
$$

Far in the $y$ direction, the term $-\cosh^2 y$ drives the curvature rapidly toward negative infinity. Far in the $x$ direction with $y$ fixed, $\operatorname{sech}^2x$ fades to zero and the curvature approaches $-\cosh^2y$. There is no distant positive island waiting beyond the plotted window.

## Why this correction is more interesting than the conjecture

The original dream was a universe simultaneously elliptic and hyperbolic. The calculation says this particular universe is not that. Yet the failure is mathematically productive because it isolates a common misconception: one cannot infer curvature sign from directional expansion alone.

In cosmology, materials science, and geometric data analysis, anisotropy is everywhere. A medium may stretch more readily along one axis than another. A spacetime model may possess direction-dependent scale factors. A learned metric may amplify some features and suppress others. In all such settings, local scale factors do not by themselves determine intrinsic curvature. Their spatial variation and coupling do.

The metric here is a clean demonstration. Its two coefficients appear deliberately opposed:

$$
g_{xx}=\operatorname{sech}^2y,
\qquad
g_{yy}=\cosh^2x.
$$

Nevertheless, the full curvature calculation produces a single sign. The geometry expands and contracts directionally, but every non-origin point remains saddle-like.

## A laboratory for mathematical honesty

There is also a broader value in examples whose first interpretation fails. Mathematics advances not only by confirming attractive conjectures, but by replacing them with sharper statements. Here the replacement is unusually complete: the curvature has a closed formula, a global sign theorem, an exact equality case, and a clear comparison with the field that inspired the incorrect picture.

That hierarchy of claims matters. A numerical image may suggest that all visible values are negative. A symbolic expression may make that suggestion plausible. But the parameter inequality proves the claim simultaneously for every point of an unbounded plane. It also identifies the sole equality case, something no finite plot can guarantee. Computation can reveal the landscape; proof determines its borders.

The example therefore serves as a compact laboratory for responsible modeling. First define the local ruler. Next derive the invariant that answers the geometric question. Then isolate a dimensionless parameter range—in this case $0<a,b\le1$—and reduce the global problem to an elementary inequality. Finally, distinguish established consequences from open dynamical questions. This sequence is reusable wherever geometry is built from spatially varying costs.

## The road to a genuine split geometry

The corrected curvature portrait also sharpens the next questions.

First, the geodesic equations should be studied directly. Because the metric coefficients are smooth everywhere and do not change formula on the diagonals, there is no immediate reason for geodesics to switch between literal trigonometric and exponential pieces there. Any claim that a geodesic crosses a diagonal at most twice now needs independent evidence; curvature phases cannot supply it.

Second, one can investigate completeness. If every geodesic extends forever, global results for nonpositively curved spaces may imply strong uniqueness and convexity properties. If some paths escape in finite length, the incomplete directions themselves become part of the geometry’s story.

Third, areas of coordinate or geodesic triangles can be computed using

$$
dA=\frac{\cosh x}{\cosh y}\,dx\,dy.
$$

But a “split triangle” must be specified by actual vertices and by the kind of edges intended. Without those choices, there is no single area to calculate.

Finally, the design challenge remains open in a more precise form: choose positive functions $E(y)$ and $G(x)$ in a diagonal metric

$$
ds^2=E(y)\,dx^2+G(x)\,dy^2
$$

so that its Gaussian curvature truly changes sign along a prescribed set. The present example supplies both a warning and a method. Guessing from scale factors is unreliable; deriving the curvature and proving its inequalities is decisive.

The most compelling “impossible geometries” are not those that merely look paradoxical. They are those whose intrinsic invariants survive calculation. Here calculation transforms a seductive phase-boundary story into a different, exact picture: a smooth anisotropic plane, negatively curved everywhere except for one perfectly flat point. The geometry refused to split—and in doing so, revealed how subtle the relationship between stretching and curvature really is.
