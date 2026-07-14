# Building Spheres Out of Sign Vectors: The Suspension Tower

## A machine for making higher-dimensional spheres

There is a beautifully simple recipe for turning a shape into a shape one
dimension higher. Take two new points — call them the north and south poles — and
connect each of them to every point of the original shape, but never connect the
two poles to each other. If you start with two isolated points (a "$0$-sphere"),
this recipe produces a circle. Apply it again and you get a $2$-sphere, the
surface of a ball. Again, and you climb into the fourth dimension. This operation
is called **suspension**, and repeating it builds a *tower* of ever-taller
spheres, each one exactly one dimension above the last.

This article is about a particularly rigid, combinatorial version of that story —
one where the spheres are made not of continuous rubber but of finite lists of
*sign vectors*, and where the "one dimension per step" rule can be proved on the
nose. Along the way we will meet a discrete cousin of one of the most celebrated
results in topology, the Borsuk–Ulam theorem, and we will see how counting the
faces of a crystal-like polytope certifies exactly how tall our tower of spheres
has grown.

## Spheres with a mirror

The shapes we study all come with a built-in symmetry: a **free involution**, an
operation $\alpha$ that swaps every point with an "antipode," never fixing any
point, and doing nothing when applied twice ($\alpha(\alpha(x)) = x$). Think of
the antipodal map on a sphere, which sends each point to the diametrically
opposite one. A shape equipped with such an antipodal symmetry is called a **free
$\mathbb{Z}_2$-complex**: "$\mathbb{Z}_2$" because there are exactly two ways to
act (do nothing, or flip), and "free" because the flip never leaves anything
standing still.

Concretely, a complex here is a **simplicial complex**: a vertex set together with
a family of *faces* (finite subsets of vertices) that is closed downward — every
subset of a face is again a face. A face with $d+1$ vertices is a $d$-dimensional
simplex, and the **dimension** of the complex is the size of its largest face,
minus one.

The star example is the **octahedral $n$-sphere**, written $\mathrm{Oct}(n)$. Its
vertices are pairs $(i, b)$ where $i$ ranges over $n+1$ coordinate axes and
$b \in \{+, -\}$ is a sign. The antipodal map flips the sign: $(i,+) \leftrightarrow
(i,-)$. A set of vertices is declared a **face** precisely when it never contains
both signs of the same axis — that is, it never contains an antipodal pair. For
$n=0$ this is just two points $\{(0,+), (0,-)\}$ with no edge between them: the
$0$-sphere. For $n=1$ it is the boundary of a square (a combinatorial circle); for
$n=2$, the boundary of an octahedron — hence the name. In general $\mathrm{Oct}(n)$
is the boundary of the $(n{+}1)$-dimensional cross-polytope, a triangulated copy of
the ordinary $n$-sphere.

## The one true measure of a sphere

How big is $\mathrm{Oct}(n)$? Its largest faces are obtained by choosing *one*
sign for *each* of the $n+1$ axes. Choose too much — both signs of some axis — and
you have violated the "no antipodal pair" rule. Choose one sign per axis and you
get a face with exactly $n+1$ vertices, so a simplex of dimension $n$. This is the
combinatorial reflection of a familiar fact: the octahedral $n$-sphere really is
$n$-dimensional.

We package this into a clean, base-point-free notion. Say a complex **has
dimension $d$** when it contains at least one face of size $d+1$ *and* no face is
any larger. The first clause is essential: it forbids assigning a spurious
dimension to the empty complex, whose only face is the empty set. With this
definition:

> **The dimension of the octahedral sphere.** $\mathrm{Oct}(n)$ has dimension
> exactly $n$.

## The tower rises by exactly one, every time

Now the main event. Suspension, in the combinatorial world, glues two new apex
vertices onto a complex $K$: the new vertex set is $V \sqcup \{+, -\}$, a face is
allowed to include *at most one* apex, and its "base part" must be a face of $K$.
The antipodal map extends by flipping the two apexes.

Here is the phenomenon that anchors everything:

> **Dimension law, single step.** If a free $\mathbb{Z}_2$-complex has dimension
> $d$, then its suspension has dimension exactly $d+1$.

Why exactly one? A largest face of the suspension consists of a largest face of
the base (size $d+1$) together with *at most one* apex — you can never grab both
poles. So the biggest face grows from $d+1$ to $d+2$ vertices, and no further.
Crucially, this argument never mentions the octahedral structure. It is a property
of the suspension operation itself. Iterating it gives the headline theorem:

> **Dimension law of the tower.** For *every* finite free $\mathbb{Z}_2$-complex
> $K$ of dimension $d$, the $k$-fold suspension tower $S^k(K)$ has dimension
> exactly $d+k$.

Specializing to the octahedral base recovers $\dim S^k(\mathrm{Oct}(n)) = n+k$ as a
one-line corollary — but the law itself is now a structural truth about the
suspension machine, valid over any base whatsoever.

## Counting the facets: a crystal with $2^{n+1}$ faces

The top-dimensional faces of a complex are called its **facets**. For
$\mathrm{Oct}(n)$ we can count them exactly, and the answer is gorgeous. Every
facet corresponds to choosing one sign per axis — that is, to a **sign vector**
$\sigma$ assigning $+$ or $-$ to each of the $n+1$ coordinates. Call the resulting
face the **orthant** of $\sigma$; geometrically it is one of the $2^{n+1}$
"quadrants" of space cut out by the coordinate hyperplanes.

> **Facet enumeration.** The facets of $\mathrm{Oct}(n)$ are *exactly* the
> orthants: a face is top-dimensional if and only if it is the orthant of some
> sign vector. Consequently $\mathrm{Oct}(n)$ has exactly $2^{n+1}$ facets.

The proof has two halves. Each orthant is genuinely a face (it never repeats an
axis) with exactly $n+1$ vertices, so it is a facet; and conversely a face of the
maximal size $n+1$ must, by a pigeonhole count across $n+1$ axes, pick exactly one
sign in each — so it *is* an orthant. Different sign vectors give different
orthants, so the count is precisely $2^{n+1}$: four edges for the square
($n=1$), eight triangles for the octahedron ($n=2$), and so on. This exact count
is more than a curiosity: it certifies the dimension *and* the symmetry structure
of the sphere from a single combinatorial datum.

## Co-index: how much sphere a shape can hold

Dimension measures how big a complex is. A subtler invariant measures how much
*symmetry* it can absorb. Say a complex $K$ **has co-index at least $m$** if there
is an **equivariant simplicial map** from $\mathrm{Oct}(m)$ into $K$ — a vertex
map that respects faces and commutes with the antipodal symmetries on both sides.
Intuitively, co-index counts the largest sphere you can map symmetrically into
$K$. Suspension respects this too:

> **Suspension raises co-index.** If $K$ has co-index at least $m$, then $S(K)$
> has co-index at least $m+1$; hence $k$ suspensions raise co-index by at least
> $k$.

The witnessing map is explicit: there is a natural equivariant embedding
$\mathrm{Oct}(m{+}1) \to S(\mathrm{Oct}(m))$, and suspension is *functorial* — it
turns a map between complexes into a map between their suspensions — so the co-index
witnesses compose all the way up the tower.

## Zero excess: co-index and dimension in lockstep

Put the two invariants side by side. Define the **excess** of a complex as its
co-index minus its dimension — a measure of "wasted room," how much bigger the
shape is than the largest sphere it can symmetrically hold. For the octahedral
tower these two quantities march upward in perfect step:

> **Zero-defect tower.** The tower $S^k(\mathrm{Oct}(n))$ has dimension exactly
> $n+k$ and co-index at least $n+k$. Its co-index reaches its dimension: the tower
> wastes no room, achieving zero excess at every height.

This makes the octahedral tower the canonical *reference family* — the perfectly
efficient staircase against which every other, more wasteful, complex can be
measured. It is the exact opposite of the "maximal excess" regime, where a single
suspension can repair a large gap between the two invariants all at once.

## A discrete Borsuk–Ulam obstruction

The classical Borsuk–Ulam theorem says there is no continuous antipode-preserving
map from a higher sphere to a lower one — famously implying that at every moment
two antipodal points on Earth share the same temperature and pressure. Our
combinatorial world carries a discrete shadow of this deep fact.

> **Combinatorial Borsuk–Ulam, base case.** Any equivariant simplicial map
> $\mathrm{Oct}(n) \to \mathrm{Oct}(0)$ forces $n = 0$. There is no
> antipode-respecting way to collapse a positive-dimensional octahedral sphere
> onto the two-point sphere.

The mechanism is purely combinatorial: two vertices lying on different axes of
$\mathrm{Oct}(n)$ can always be completed to a face together with an antipode,
and tracking where an equivariant map must send them collides with the fact that
the target has only two points and one forbidden antipodal pair. From this base
case, the tower promotes the obstruction to every height:

> **Iterated obstruction.** For every $k \geq 1$, there is no equivariant
> simplicial map from the $k$-fold suspension of the $0$-sphere back onto the
> $0$-sphere.

The proof is a satisfying pincer: the tower's co-index growth builds a map *into*
$S^k(\mathrm{Oct}(0))$ from a high sphere, while a hypothetical map *out* to
$\mathrm{Oct}(0)$ would compose with it to violate the base case. The suspension
that let us climb up is exactly what forbids us from climbing back down.

## Why it matters

Three threads come together here. First, the "grow by exactly one" rule of
suspension is revealed to be intrinsic to the operation, not an accident of any
particular sphere. Second, the octahedral spheres carry an exact facet
certificate, $2^{n+1}$ orthants, that reads off dimension and symmetry from one
combinatorial count. Third, these combine to make the octahedral tower a
zero-excess yardstick, and to give a fully discrete Borsuk–Ulam obstruction that
survives every level of suspension.

These are not idle abstractions. Equivariant maps and co-index bounds are the
engine behind topological lower bounds in combinatorics — most famously Lovász's
proof that certain graphs need many colors, where the "co-index plus two" of an
associated complex bounds the chromatic number from below. A tower that grows in
lockstep is the calibrated instrument that tells us when such bounds are tight and
when they leave room to spare. From two poles and a rule against joining them, an
entire hierarchy of spheres — and the obstructions that keep them apart — comes
into view.
