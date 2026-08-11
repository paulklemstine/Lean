# The Largest Triangle in the World

## How a single integral, worth exactly $\pi$, pins down the geometry of a curved universe

### A triangle that cannot be beaten

Ask a schoolchild how big a triangle can be and you will get a puzzled look. In
the flat plane of Euclid, triangles come in every size: pick three points, spread
them out, and the area grows without bound. There is no largest triangle.

Now move to a *hyperbolic* plane — a surface of constant negative curvature, the
saddle-shaped geometry that Bolyai, Lobachevsky and Gauss discovered in the
nineteenth century — and something extraordinary happens. There *is* a largest
triangle. However cleverly you place your three points, however far apart you
push them, the area of the triangle they span never exceeds a single finite
number. If the curvature is $-\kappa$ (with $\kappa > 0$), that number is

$$A_{\max} = \frac{\pi}{\kappa}.$$

No triangle in a hyperbolic plane of curvature $-1$ has area more than $\pi
\approx 3.14159$. Not one. You may make the sides a light-year long, a googol
light-years long; the enclosed area creeps up towards $\pi$ and stops.

This article is about *why*, and about a chain of results that turns this slogan
into a fully explicit piece of mathematics: an exact integral, an exact formula
for the angles, a rigidity statement saying that the maximum is attained by
exactly one shape, an extension to polygons, an extension to spaces where the
curvature is allowed to wobble, and a symmetry argument showing that the whole
story is independent of where you look.

### Bending the plane: the upper half-plane model

To do calculations you need a model, and the most computable model of the
hyperbolic plane is Poincaré's **upper half-plane**. Take the set of points
$(x, y)$ in the ordinary Cartesian plane with $y > 0$ — everything strictly above
the $x$-axis — and equip it with the strange rule that lengths are measured by

$$ds^2 = \frac{dx^2 + dy^2}{\kappa\, y^2}.$$

In words: a small step of Euclidean size $\epsilon$ taken at height $y$ counts as
a hyperbolic step of size $\epsilon / (y\sqrt{\kappa})$. Near the $x$-axis, where
$y$ is tiny, this factor blows up: you can walk forever without reaching the axis.
The $x$-axis is therefore not part of the space at all; it is *infinitely far
away*, a horizon. Together with a single extra point $\infty$ "at the top", it
forms the **boundary circle** of the hyperbolic plane, the set of directions in
which you can escape to infinity.

Correspondingly, area is measured by

$$dA = \frac{dx\,dy}{\kappa\, y^{2}}.$$

The straight lines of this geometry — the *geodesics*, the paths of shortest
hyperbolic length — are not Euclidean straight lines. They are the vertical rays
$x = \text{const}$ and the semicircles that meet the $x$-axis at right angles.
A traveller who wants to get from one point to another as fast as possible
detours upwards, because altitude is cheap.

### The ideal triangle

The extremal triangle is the one whose three vertices are pushed all the way out
to the horizon. Such a triangle is called **ideal**. Its vertices are not points
of the hyperbolic plane at all; they are boundary points, unreachable
destinations. Its three sides are complete geodesics of infinite length, and its
three angles are all $0$: the sides become asymptotically parallel as they run
out to the boundary.

Here is the simplest one to describe. Fix two real numbers $a < b$ and take the
boundary points $a$, $b$, and $\infty$. The geodesic from $a$ to $\infty$ is the
vertical ray above $a$; the geodesic from $b$ to $\infty$ is the vertical ray
above $b$; and the geodesic from $a$ to $b$ is the Euclidean semicircle with
diameter $[a,b]$, whose height above the point $x$ is

$$\ell(x) = \sqrt{(x-a)(b-x)}.$$

The ideal triangle is the infinite region trapped between the two vertical walls
and above that semicircular floor. In Euclidean terms it is an unbounded region
of infinite Euclidean area — a chimney open at the top. In hyperbolic terms, as
we are about to see, its area is a perfectly finite number.

### Two integrals, and the whole theorem

Compute the area by slicing into vertical strips. Above the point $x$, the strip
runs from height $\ell(x)$ upwards to infinity, and it contributes

$$\int_{\ell(x)}^{\infty} \frac{dy}{\kappa y^{2}} = \frac{1}{\kappa\,\ell(x)}.$$

That is the first miracle: the infinite chimney has finite hyperbolic height,
inversely proportional to how high the floor sits. Now add up the strips:

$$\text{Area} \;=\; \frac{1}{\kappa} \int_{a}^{b} \frac{dx}{\sqrt{(x-a)(b-x)}}.$$

The integrand blows up at both endpoints like $1/\sqrt{\text{distance}}$, which
is exactly mild enough to be integrable, and the integral has a beautiful closed
form. The function

$$F(x) = \arcsin\!\left(\frac{2x - a - b}{b - a}\right)$$

has derivative exactly $1/\sqrt{(x-a)(b-x)}$ — a computation that reduces, after
clearing denominators, to the identity $1 - \left(\frac{2x-a-b}{b-a}\right)^2 =
\frac{4(x-a)(b-x)}{(b-a)^2}$. At $x = a$ the argument of the arcsine is $-1$ and
at $x = b$ it is $+1$, so $F$ runs from $-\pi/2$ to $\pi/2$, and

$$\boxed{\;\int_{a}^{b} \frac{dx}{\sqrt{(x-a)(b-x)}} \;=\; \pi. \;}$$

Notice what has *not* appeared in the answer: $a$ and $b$. The integral is $\pi$
whether the two boundary vertices are a millimetre apart or a parsec apart. This
single identity is the whole geometry of the ideal triangle compressed into one
line, and it gives at once

$$\text{Area of the ideal triangle} \;=\; \frac{\pi}{\kappa}.$$

Every ideal triangle with a vertex at $\infty$ has the same area, and — by the
symmetry argument below — *every* ideal triangle whatsoever.

### Gauss–Bonnet: area is angle defect

The value $\pi/\kappa$ is a special case of one of the loveliest formulas in
geometry. In a hyperbolic plane of curvature $-\kappa$, a triangle with interior
angles $\alpha, \beta, \gamma$ has area

$$\text{Area} \;=\; \frac{\pi - (\alpha + \beta + \gamma)}{\kappa}.$$

The area is not determined by the side lengths; it is determined entirely by how
badly the angle sum fails to be $\pi$. Hyperbolic triangles are *thin*: their
angles always sum to less than $\pi$, and the deficit — the **angular defect** —
is precisely $\kappa$ times the area. This is the two-dimensional Gauss–Bonnet
theorem, and it makes the maximality statement obvious in retrospect. Angles are
nonnegative, so the defect is at most $\pi$, so the area is at most $\pi/\kappa$;
and equality forces $\alpha = \beta = \gamma = 0$, which is exactly the ideal
configuration. That is not just a bound but a **rigidity theorem**: among all
hyperbolic triangles, area $\pi/\kappa$ is attained only by the ideal triangle,
and the nonnegativity of the angles is essential — allow one angle to be
"negative" and a large positive angle could be cancelled by it, and the rigidity
collapses.

Of course, the argument above is only as good as the formula it starts from. The
integral we just computed *derives* the case $\alpha = \beta = \gamma = 0$ from
the metric itself, rather than assuming it. Can we derive more?

### Computing angles instead of assuming them

Yes — and here is the configuration that does it. Fix two numbers $0 \le \varphi <
\theta \le \pi$ and consider the triangle with vertices

$$P = (\cos\theta, \sin\theta), \qquad Q = (\cos\varphi, \sin\varphi), \qquad \infty,$$

both finite vertices lying on the **unit semicircle**, which is itself a geodesic.
The three sides are: the vertical ray above $\cos\theta$, the vertical ray above
$\cos\varphi$, and the arc of the unit semicircle between $P$ and $Q$. This is a
genuine hyperbolic triangle with one ideal vertex (at $\infty$) and two finite
ones.

Its angles can be *computed* rather than postulated, and here the half-plane
model pays a dividend. Because the hyperbolic metric is a positive multiple of
the Euclidean metric at every point — a *conformal* rescaling — the angle between
two curves is the same whether measured hyperbolically or Euclidean-ly. Rescaling
either tangent vector by a positive number leaves $\arccos\frac{\langle u,v
\rangle}{|u||v|}$ unchanged, and that is all conformality means for angles. So we
may just read off Euclidean angles between tangent vectors.

At $P$, the vertical side has upward tangent $(0,1)$ and the circular side has
tangent $(\sin\theta, -\cos\theta)$; their angle is $\arccos(-\cos\theta) = \pi -
\theta$. At $Q$, the tangents are $(0,1)$ and $(-\sin\varphi, \cos\varphi)$, at
angle $\arccos(\cos\varphi) = \varphi$. The third angle, at $\infty$, is $0$.

Now the area. The region sits over the interval $[\cos\theta, \cos\varphi]$ above
the unit semicircle $\ell(x) = \sqrt{1 - x^{2}}$, so the same slicing gives

$$\text{Area} = \frac{1}{\kappa}\int_{\cos\theta}^{\cos\varphi} \frac{dx}{\sqrt{1-x^{2}}}
= \frac{\arcsin(\cos\varphi) - \arcsin(\cos\theta)}{\kappa} = \frac{\theta - \varphi}{\kappa}.$$

Compare with the angle defect:

$$\pi - \big[(\pi - \theta) + \varphi + 0\big] = \theta - \varphi.$$

They agree exactly. Gauss–Bonnet is no longer an assumption for this family; it
is a computation, made from the metric and from angles read off tangent vectors.

The hypotheses $0 \le \varphi < \theta \le \pi$ are deliberately generous. Taking
$\varphi = 0$ slides the vertex $Q$ onto the boundary point $1$, giving a triangle
with **two** ideal vertices and area $\theta/\kappa$; taking also $\theta = \pi$
slides $P$ onto $-1$ and returns the fully ideal triangle of area $\pi/\kappa$. A
single formula covers one, two and three ideal vertices.

### Why the maximum is never actually reached

Two complementary statements make precise the sense in which the ideal triangle
is a limit rather than a member of the family of honest triangles.

First, **finite vertices carry strictly positive angles**. In the family above,
if $0 < \varphi < \theta < \pi$ then the two computed angles $\pi - \theta$ and
$\varphi$ are both strictly positive. There is no way to have a genuine corner in
the hyperbolic plane with zero angle: zero angle means the two sides are
asymptotic, and asymptotic geodesics meet only on the horizon. Consequently such
a triangle has area $(\theta - \varphi)/\kappa$ strictly less than $\pi/\kappa$.

Second, **the maximum is approached, and only in one way**. Truncate the ideal
triangle by cutting off a sliver of width $t$ at each end, retaining the part
over $[a+t, b-t]$. Its area is

$$\frac{1}{\kappa}\left[\arcsin\!\left(\frac{b-a-2t}{b-a}\right) - \arcsin\!\left(\frac{2t-(b-a)}{b-a}\right)\right],$$

which for every $t > 0$ is *strictly* below $\pi/\kappa$ and which increases to
$\pi/\kappa$ as $t \to 0^{+}$. Symmetrically, letting the two finite vertices of
the one-ideal-vertex family slide out to the boundary ($\theta \to \pi$,
$\varphi \to 0$) makes the area increase to $\pi/\kappa$.

And there is a converse on the angle side, a genuine rigidity-in-the-limit
statement: if a sequence of hyperbolic triangles, with nonnegative angles
$\alpha_n, \beta_n, \gamma_n$ summing to at most $\pi$, has area tending to the
maximum $\pi/\kappa$, then *all three* angles tend to $0$. The proof is a squeeze:
the areas converging to $\pi/\kappa$ forces $\alpha_n + \beta_n + \gamma_n \to 0$,
and each individual angle is trapped between $0$ and that sum. So the ideal
triangle is not merely *an* optimal shape; it is the unique limiting shape of any
maximising sequence.

### From triangles to polygons: $(n-2)\pi/\kappa$

Once you have the triangle, polygons come for free by triangulation. Take
boundary points $v_0 < v_1 < \cdots < v_m$ on the real line together with
$\infty$: an ideal polygon with $n = m + 2$ vertices. Slicing it along the
vertical geodesics through the finite vertices cuts it into exactly $m$ ideal
triangles, each of area $\pi/\kappa$. Hence

$$\text{Area of an ideal } n\text{-gon} \;=\; \frac{(n-2)\pi}{\kappa}.$$

The Euclidean echo is unmistakable: the angle sum of a Euclidean $n$-gon is
$(n-2)\pi$, and here that same quantity reappears as an *area*, divided by the
curvature. Moreover the decomposition is consistent: gluing an ideal $(m+2)$-gon
to an ideal $(k+2)$-gon along a shared edge produces an ideal $(m+k+2)$-gon whose
area is the sum of the two areas. The invariant does not care how you cut.

### Everywhere looks the same: the symmetry group

All of the calculations above put a vertex at the convenient boundary point
$\infty$. Why is that no loss of generality? Because the hyperbolic plane is
enormously symmetric, and the symmetries act transitively enough on the horizon
to move any configuration into the convenient position.

The relevant symmetries are the **real Möbius transformations**

$$T(z) = \frac{Az + B}{Cz + D}, \qquad A,B,C,D \in \mathbb{R},\; AD - BC > 0,$$

acting on the half-plane thought of as a set of complex numbers $z = x + iy$ with
$y > 0$. Two computations make them isometries. The first is the exact height
distortion,

$$\operatorname{Im} T(z) = \frac{(AD - BC)\,\operatorname{Im} z}{|Cz + D|^{2}},$$

which shows immediately that a positive determinant keeps the upper half-plane
inside itself: heights stay positive. The second is the conformality identity.
Since $T'(z) = (AD-BC)/(Cz+D)^{2}$, we get $|T'(z)| = (AD-BC)/|Cz+D|^{2}$, and
therefore

$$\frac{|T'(z)|}{\operatorname{Im} T(z)} = \frac{1}{\operatorname{Im} z}.$$

Read this as follows: the hyperbolic line element is $|dz| / y$; the map
multiplies $|dz|$ by $|T'(z)|$ and multiplies $y$ by *exactly the same factor*, so
the ratio — the hyperbolic length of an infinitesimal step — is unchanged. That is
what it means to be an isometry, expressed infinitesimally.

Finally, these maps act **sharply three-transitively** on the boundary. Given any
three boundary points $p < q < r$, the explicit cross-ratio map with coefficient
matrix

$$\begin{pmatrix} q - r & -p(q-r) \\ q - p & -r(q-p) \end{pmatrix}$$

sends $p \mapsto 0$, $q \mapsto 1$, $r \mapsto \infty$, and its determinant is
$(r-q)(q-p)(r-p) > 0$ — positive precisely because the three points occur in that
cyclic order. Uniqueness is elementary: a real Möbius map fixing $0$, $1$ and
$\infty$ must have no finite pole, no constant term, and equal leading
coefficients, hence be the identity. So any two normalising maps agree.

The consequence is the statement we wanted. Three distinct boundary points
determine an ideal triangle, uniquely up to a unique hyperbolic isometry; every
ideal triangle is congruent to the standard one with vertices $0$, $1$, $\infty$;
and therefore *every* ideal triangle has area $\pi/\kappa$. The convenience of
putting a vertex at $\infty$ cost us nothing at all.

### When the curvature wobbles

The final result relaxes the assumption that curvature is constant. Suppose the
area element is $dx\,dy / (K(x)\,y^{2})$ for a positive continuous function $K$ —
a space whose curvature varies from place to place, staying negative but not
staying still. The same slicing works, giving

$$\text{Area} = \int_{a}^{b} \frac{dx}{K(x)\,\sqrt{(x-a)(b-x)}},$$

and comparing pointwise with the constant-curvature integrand yields a clean
**pinching theorem**: if $\kappa_1 \le K \le \kappa_2$ with $\kappa_1 > 0$, then

$$\frac{\pi}{\kappa_{2}} \;\le\; \text{Area} \;\le\; \frac{\pi}{\kappa_{1}}.$$

More negative curvature means a *smaller* ideal triangle. The bounds are sharp:
when $K$ is the constant $\kappa$ they both collapse onto the exact value
$\pi/\kappa$, so neither inequality can be improved.

This is the germ of a large and important circle of ideas in modern geometry —
comparison theorems, which let you say something about a space you cannot compute
in by bracketing it between two you can. Here the bracketing is exact enough to
be checked by hand.

### Why any of this matters

The bounded-area phenomenon is not a curiosity. It is the reason hyperbolic
geometry is *rigid* where Euclidean geometry is floppy.

In a Euclidean plane, shape and size are independent: you can scale a triangle up
and nothing about its angles changes. In a hyperbolic plane there is no scaling
symmetry at all — the curvature sets an absolute unit of length — and the angles
of a triangle determine its area, hence, by further arguments, the triangle
itself. This is the seed of Mostow rigidity, the theorem that a hyperbolic
structure on a closed manifold of dimension at least three is determined by its
topology alone: geometry becomes a topological invariant. Every hyperbolic
surface of genus $g \ge 2$ has area exactly $4\pi(g-1)$, no matter how it is
deformed. The count of ideal triangles needed to triangulate a surface is a
topological count, and that is the modern face of Gauss–Bonnet.

The bounded ideal triangle also underwrites the theory of *thin triangles* in
geometric group theory: since every hyperbolic triangle fits inside an ideal one
of bounded area, every hyperbolic triangle is uniformly slim, each side lying
within a bounded distance of the other two. Gromov turned this observation into a
definition, and $\delta$-hyperbolic groups — a class capturing an enormous swath
of finitely generated groups — grew from it.

Farther afield, ideal triangles and their area appear as the building block of
the Bloch–Wigner dilogarithm and of hyperbolic volumes of knot complements; the
same $(n-2)\pi$ combinatorics governs the Teichmüller theory of punctured
surfaces; and negatively curved geometry is the arena of the AdS/CFT
correspondence in theoretical physics, where the boundary at infinity we have
been placing vertices on becomes a physical hologram of the bulk.

### The moral

A single definite integral,

$$\int_{a}^{b} \frac{dx}{\sqrt{(x-a)(b-x)}} = \pi,$$

independent of $a$ and $b$, is the reason a curved universe has a biggest
triangle. From it flow: the exact area $\pi/\kappa$ of an ideal triangle; the
Gauss–Bonnet identity, computed and not assumed, for triangles with one, two or
three vertices at infinity; the polygon formula $(n-2)\pi/\kappa$; a rigidity
theorem saying the maximum is approached only by degenerating all three angles to
zero; a symmetry argument showing that every ideal triangle is congruent to the
same standard one; and a comparison estimate for spaces whose curvature is merely
pinched. It is a rare pleasure in mathematics when the whole of a theory
condenses into an integral you can do in one line — and rarer still when the
answer is $\pi$.
