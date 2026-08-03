# How Much Room Is There on a Sphere?

## A packing problem with a deceptive shortcut

Imagine arranging identical radio transmitters around a planet. Each transmitter serves every point within a fixed angular distance, and no two service regions may overlap. Or imagine a molecular shell whose binding sites must remain separated, a satellite constellation designed to avoid directional interference, or a codebook of signals represented by points on a sphere. All of these become versions of one geometric question:

> How many equal circular caps of geodesic radius $r$ can fit without overlap on the unit sphere?

A **geodesic cap of radius $r$** consists of the points whose shortest distance along the spherical surface from a chosen center is less than $r$. Let $N(2,r)$ denote the greatest number of such non-overlapping caps that can be placed on the ordinary two-dimensional unit sphere. The first argument anyone should try is an area budget: every cap consumes area, and the sphere has only so much.

That elementary idea proves a clean universal bound. It also exposes why an attractive stereographic shortcut is less informative than it first appears, and why one familiar-looking tetrahedral calibration is actually impossible.

## The sphere’s area budget

The unit sphere has surface area

$$
A_{\mathrm{sphere}}=4\pi.
$$

A geodesic cap of radius $r$, for $0<r<\pi$, has area

$$
A_{\mathrm{cap}}(r)=2\pi(1-\cos r).
$$

This formula can be seen by taking the cap above latitude $\pi/2-r$. A horizontal spherical strip has area proportional to its vertical height; the cap’s height is $1-\cos r$, so its area is $2\pi(1-\cos r)$.

Now suppose $m$ caps do not overlap. Their union has area equal to the sum of their areas, up to harmless boundary tangencies. Since the union lies inside the sphere,

$$
m\,2\pi(1-\cos r)\le 4\pi.
$$

Cancelling $2\pi$ gives the **spherical cap area bound**:

$$
N(2,r)\le \frac{2}{1-\cos r}.
$$

Because the left-hand side is an integer, one may take the floor of the right-hand side in numerical use. The reasoning is even more general: in any finite measure space, if $m$ pairwise disjoint measurable pieces each have measure at least $v$ and all lie in a region of measure $M$, then

$$
mv\le M.
$$

The spherical result is simply this finite-additivity principle with $M=4\pi$ and $v=2\pi(1-\cos r)$.

The bound is necessary, not usually sufficient. It knows how much area the caps consume, but not whether their curved boundaries can be arranged efficiently. Empty gaps are the hidden cost of packing.

## Flattening the sphere—and paying attention to scale

Stereographic projection maps a sphere minus one point onto a plane. It preserves angles, which makes it one of geometry’s most beautiful bridges between curved and flat worlds. Circles map to circles or lines, and local shapes are preserved up to a change of scale. This invites a strategy: flatten the caps, solve a planar packing problem, and translate the answer back.

But stereographic projection is not area-preserving. Its scale varies with location and becomes unbounded near the omitted pole. A proposed two-dimensional correction factor is

$$
C(r)=\left(\frac{2}{\cos r}\right)^2.
$$

For $0<r<\pi/2$, this factor is positive and at least $1$. Therefore the direct area bound immediately implies the weaker inequality

$$
N(2,r)
\le C(r)\frac{A_{\mathrm{sphere}}}{A_{\mathrm{cap}}(r)}
=\left(\frac{2}{\cos r}\right)^2\frac{2}{1-\cos r}.
$$

So this proposed numerical upper bound is valid on that range—but not because flattening has extracted a sharper constraint. It follows simply by multiplying the stronger area-ratio bound by a number no smaller than $1$.

There is also an asymptotic warning. A correction advertised as $1+O(r^2)$ must approach $1$ as $r$ approaches $0$. Yet

$$
C(0)=\left(\frac{2}{\cos 0}\right)^2=4.
$$

The factor approaches $4$, not $1$. The normalized expression

$$
\widetilde C(r)=\frac{1}{\cos^2 r}
$$

does satisfy $\widetilde C(0)=1$, and its small-radius expansion begins with $1+r^2+O(r^4)$. That makes it a plausible normalized distortion factor, though normalization alone does not establish a packing theorem.

This distinction matters. Conformal maps preserve infinitesimal angles, not global area. A single stereographic chart has no finite global maximum distortion because its scale blows up near the missing pole. Any rigorous distortion argument must either stay within a controlled region, use several charts, or return to intrinsic spherical area.

## A tetrahedron that does not fit

The most revealing test comes at $r=\pi/3$, or $60$ degrees. It is tempting to associate four caps with the four vertices of a regular tetrahedron and declare that four such caps fit. The geometry says otherwise.

Two caps of radius $r$ can be non-overlapping only if their centers are separated by at least $2r$. At $r=\pi/3$, every pair of centers would therefore need angular separation at least

$$
2r=\frac{2\pi}{3},
$$

or $120$ degrees. If unit vectors $u$ and $v$ represent two centers, their inner product is the cosine of their angular separation. Thus the requirement becomes

$$
u\cdot v\le \cos\left(\frac{2\pi}{3}\right)=-\frac12.
$$

Suppose four unit vectors $a,b,c,d$ satisfied this condition for every pair. Expand the squared length of their sum:

$$
\begin{aligned}
\lVert a+b+c+d\rVert^2
&=\lVert a\rVert^2+\lVert b\rVert^2+\lVert c\rVert^2+\lVert d\rVert^2\\
&\quad+2\sum_{\{u,v\}}u\cdot v.
\end{aligned}
$$

There are four unit-length terms, contributing $4$, and six pairwise inner products, each at most $-1/2$. Hence

$$
\lVert a+b+c+d\rVert^2\le 4+2\cdot 6\left(-\frac12\right)=-2.
$$

But a squared length can never be negative. This contradiction proves that four caps of radius $\pi/3$ cannot be packed on the sphere—in fact, the argument works in any real inner-product space.

Where did the tetrahedral intuition go wrong? Distinct vertices of a regular tetrahedron inscribed in the unit sphere have inner product $-1/3$, so their angular separation is

$$
\arccos\left(-\frac13\right)\approx 1.9106\text{ radians}\approx 109.47^\circ.
$$

Equal caps centered there can have radius at most half that separation:

$$
r_{\mathrm{tet}}=\frac12\arccos\left(-\frac13\right)\approx 0.9553\text{ radians}\approx 54.74^\circ.
$$

That is smaller than $60$ degrees. The tetrahedral arrangement is real and important; only the claimed radius was wrong.

## What the numerical landmarks really say

The area bound gives a useful first audit of proposed configurations.

At $r=\pi/6$, the cap radius is $30$ degrees and

$$
\frac{2}{1-\cos(\pi/6)}=8+4\sqrt3\approx 14.93.
$$

Thus area alone permits at most $14$ caps. A twelve-center icosahedral arrangement is compatible with that upper bound, but the area calculation by itself neither proves that those particular $30$-degree caps are disjoint nor proves optimality.

At $r=\pi/4$, the cap radius is $45$ degrees and

$$
\frac{2}{1-\cos(\pi/4)}=4+2\sqrt2\approx 6.83.
$$

Therefore at most $6$ caps fit. Six centers at the vertices of an octahedron have minimum angular separation $90$ degrees, so open caps of radius $45$ degrees are disjoint and closed caps merely touch. This gives a matching construction and identifies the exact packing number under the corresponding tangency convention. The correct six-vertex solid is the octahedron, not the cuboctahedron, which has twelve vertices.

At $r=\pi/3$, the area ratio equals $4$. Area bookkeeping alone therefore says only $N(2,\pi/3)\le4$. The vector-sum obstruction improves this to

$$
N(2,\pi/3)\le3.
$$

Three centers equally spaced around a great circle have pairwise separation $120$ degrees, so three open caps of radius $60$ degrees fit, with tangencies at their boundaries. Consequently, under the open-cap convention,

$$
N(2,\pi/3)=3.
$$

The episode is a compact lesson in mathematical modeling: an area bound can look exact numerically while geometry still rules out equality.

## Why area is only the opening move

The area inequality is powerful precisely because it forgets almost everything. It sees the size of each cap but not its shape, its neighbors, or the pattern of gaps between them. Picture trying to cover a tabletop with identical coins. Dividing the tabletop’s area by one coin’s area gives an obvious ceiling, yet it does not tell us whether the coins can realize that ceiling. Curved surfaces add another complication: even highly symmetric arrangements may leave unavoidable defects.

Inner products restore some of the missing structure. Once centers are represented by unit vectors, every angular condition becomes an algebraic inequality. The matrix of all pairwise inner products—called the Gram matrix—must behave like genuine geometric data: every squared length assembled from the vectors must be nonnegative. The four-vector contradiction uses the simplest possible test, the squared length of their sum. More elaborate tests can place strong limits on spherical codes even when an area estimate is inconclusive.

This two-stage method is practical. First apply the inexpensive area screen. If a proposed number exceeds the screen, reject it immediately. If it survives, inspect angular compatibility through coordinates, symmetry, or Gram matrices. A surviving candidate still needs a construction, but the search has become focused. At $r=\pi/3$, the stages are especially vivid: the area screen returns $4$, angular compatibility lowers the ceiling to $3$, and an equatorial triangle supplies exactly $3$ centers.

## From satellite codes to molecular geometry

Spherical packing is not merely recreational geometry. A unit vector can encode a direction, a normalized signal, or a quantum or molecular orientation. Requiring a minimum angular separation makes signals robust against noise: a received direction can drift without being confused with a neighboring codeword. In such settings, cap packing and spherical coding are two views of the same design problem.

The area bound is valuable because it is immediate, explicit, and dimensionally transparent. It can reject impossible design targets before expensive optimization begins. The inner-product method adds a second layer: by studying Gram matrices and squared vector sums, it detects incompatibilities invisible to area alone.

The broader message is methodological. Flattening curved geometry can be powerful, but every projection carries a scale law. Before trusting a correction factor, test its normalization at a simple limit. Before naming a polyhedron, check its number of vertices and minimum angle. Before interpreting an area ratio as an attainable packing, examine the algebra of pairwise inner products.

On a sphere, space is not just a budget. It is a pattern of angles—and those angles can forbid arrangements even when the ledger says there is room.