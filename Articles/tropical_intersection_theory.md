# When Algebra Turns into Geometry: A Finite Guide to Tropical Intersections

## A landscape made of straight edges

A tropical curve looks less like a smooth loop and more like a railway map. Straight edges meet at vertices, rays stretch toward infinity, and integer weights ride along the tracks. Yet this angular geometry retains one of algebraic geometry’s most durable invariants: intersection number.

That persistence is the central idea of finite tropical intersection theory. When two ordinary algebraic curves are converted into tropical objects, much of their shape changes dramatically. Curvature gives way to line segments. Complicated equations become polyhedral patterns. Individual intersection points may merge in the picture. Nevertheless, if the conversion matches points correctly and preserves their local multiplicities, the total weighted number of intersections cannot change.

This statement is both simple and powerful. It separates a geometric problem into two parts. First, establish a correspondence between ordinary and tropical intersection points. Second, perform a finite weighted count on the tropical side. In the transverse plane model, that count becomes a rectangular grid: curves of degrees $d$ and $e$ contribute one unit for each of the $d e$ pairs of degree directions. Their intersection number is therefore

$$
I=d e.
$$

The same framework also explains why the number of visible intersection locations can never exceed the weighted total when all local multiplicities are positive. Weight records collisions and tangencies that an unweighted picture would miss.

## What tropicalization remembers

Tropical geometry is often introduced through an arithmetic change of language. Ordinary addition and multiplication are replaced by operations based on minimum or maximum and ordinary addition. A polynomial then determines a piecewise-linear function, and the places where two or more linear pieces tie form a tropical hypersurface.

For the present finite theory, however, only a compact amount of structure is needed. A **finite polyhedral tropical variety** consists of a finite polyhedral complex, a codimension, a nonnegative integer weight on each cell, a balancing condition, and a degree. The balancing condition is the local conservation law of tropical geometry: around each face, weighted primitive directions cancel. It is analogous to conservation of flow at a junction. Without balancing, a collection of segments is merely a drawing; with balancing, it behaves like a geometric cycle.

An intersection is encoded even more economically. A **finite weighted intersection** consists of a finite set $S$ of supported intersection points and a multiplicity function

$$
m:S\longrightarrow \mathbb{N}.
$$

Its total intersection number is

$$
I(S,m)=\sum_{p\in S}m(p).
$$

The distinction between points and multiplicities matters. Two curves might meet at three visible locations with multiplicities $1$, $2$, and $4$. The support has size $3$, but the intersection number is $7$. Multiplicity is not decorative bookkeeping; it is the mechanism that keeps the count stable as geometry degenerates.

## The first counting principle

Suppose every supported point has positive multiplicity. Since multiplicities are natural numbers, this means $m(p)\ge 1$ for every $p\in S$. Summing these elementary inequalities gives

$$
|S|=\sum_{p\in S}1\le \sum_{p\in S}m(p)=I(S,m).
$$

This is the **Positive-Multiplicity Support Bound**: the number of distinct supported points is at most the weighted intersection number.

The proof is one line, but its interpretation is substantial. Weighted intersection theory places a budget on distinct geometry. Every visible point consumes at least one unit of the total. A point of multiplicity $r$ consumes $r$ units while occupying only one location. Thus high multiplicity compresses several units of intersection into a single site.

The bound is sharp. Equality occurs whenever all supported multiplicities are $1$. Conversely, if every multiplicity is positive and equality holds, then no point can have multiplicity larger than $1$; otherwise the sum would strictly exceed the number of points. This equality characterization follows directly from the same budget picture, although the finite model’s essential bound requires only the inequality.

## A conservation law across two worlds

Now consider two finite weighted intersection models: an ordinary one and a tropical one. A **multiplicity-preserving tropicalization correspondence** is a bijection $\phi$ between their ambient finite point types satisfying two requirements.

First, it preserves support:

$$
p\in S_{\mathrm{ord}}\quad\Longleftrightarrow\quad \phi(p)\in S_{\mathrm{trop}}.
$$

Second, it preserves local multiplicity at every supported point:

$$
m_{\mathrm{ord}}(p)=m_{\mathrm{trop}}(\phi(p)).
$$

Under precisely these hypotheses, tropicalization preserves the total intersection number:

$$
I(S_{\mathrm{trop}},m_{\mathrm{trop}})
=
I(S_{\mathrm{ord}},m_{\mathrm{ord}}).
$$

Why? A finite sum does not care what its indices are called. Use the bijection to reindex the ordinary sum by tropical points, then replace each ordinary multiplicity by the corresponding tropical multiplicity. Support preservation ensures that exactly the same terms occur, and multiplicity preservation ensures that their values agree.

This theorem is conditional, and that qualification is mathematically important. It does not assert that every tropicalization automatically supplies such a correspondence. Rather, it identifies the exact finite data sufficient for invariance. In geometric applications, constructing the correspondence may require valuation theory, transversality, or realizability. Once that bridge has been built, invariance of the total is a clean combinatorial consequence.

## Bézout as a rectangle

The classical Bézout principle says that two suitably positioned plane curves of degrees $d$ and $e$ have total intersection multiplicity $d e$. Tropical geometry turns this product into a finite model that can be seen and counted.

Define the **transverse plane intersection model** for degrees $d$ and $e$ as follows. Its points are ordered pairs

$$
(i,j)\in \{0,\ldots,d-1\}\times\{0,\ldots,e-1\}.
$$

Every pair lies in the support, and every pair has multiplicity $1$. The first coordinate labels one of the $d$ degree directions of the first curve; the second labels one of the $e$ degree directions of the second. The model therefore contains one intersection cell for each possible pairing.

There are $d$ choices for $i$ and $e$ choices for $j$, so the product rule gives $d e$ cells. Because each contributes one unit, the **Transverse Tropical Bézout Theorem** states

$$
I_{\mathrm{trop}}(d,e)
=
\sum_{i=0}^{d-1}\sum_{j=0}^{e-1}1
=d e.
$$

For example, degrees $3$ and $4$ produce a $3$-by-$4$ array of twelve unit contributions. Degrees $0$ and $e$ produce the empty array and total $0$, so the formula also handles boundary cases without special conventions.

The accompanying **Tropical Bézout Cell Bound** says that the number of distinct cells is at most $d e$. In this transverse model the inequality is an equality, because every cell is present and has multiplicity $1$:

$$
|S_{d,e}|=d e=I_{\mathrm{trop}}(d,e).
$$

The product is thus simultaneously a weighted count and a sharp support bound.

## Carrying the count back

Suppose an ordinary finite intersection admits a multiplicity-preserving correspondence with the transverse tropical model of degrees $d$ and $e$. Combining the conservation theorem with the rectangular tropical count gives the **Transported Bézout Theorem**:

$$
I_{\mathrm{ord}}=I_{\mathrm{trop}}=d e.
$$

This is not circular. The ordinary count is not assumed. The tropical side is computed independently by counting pairs, and the correspondence transports that computed value.

There is also a direct bound on the ordinary support. The point bijection identifies its finite ambient point type with the $d$-by-$e$ product type. The ordinary support is a subset of that ambient type, so

$$
|S_{\mathrm{ord}}|
\le d e.
$$

This **Transported Support Bound** agrees with the positive-multiplicity argument, but it uses only containment and the finite correspondence. In a transverse unit-multiplicity situation, all $d e$ positions are occupied; when multiplicities concentrate, fewer visible points can carry the same total.

## A small numerical journey

Take degrees $d=2$ and $e=5$. The transverse tropical model has the ten labels

$$
(0,0),(0,1),\ldots,(0,4),(1,0),(1,1),\ldots,(1,4).
$$

Each label contributes $1$, so the total is $10$. Now imagine an ordinary representation whose supported points correspond bijectively to these labels and whose local multiplicities are preserved. Its total is also $10$.

A different finite intersection might display only four points with multiplicities $1$, $2$, $3$, and $4$. Its total is still $10$, and its support size $4$ satisfies $4\le 10$. It is not the unit-multiplicity transverse model, but it illustrates why weighted counting survives geometric compression: four locations can carry ten units of intersection.

This arithmetic is easy to automate. Given a list of multiplicities, sum it for the intersection number, count its entries for support size, and check positivity before applying the support bound. For the transverse model, generate all pairs in a Cartesian product and assign the value $1$ to each. The running time is proportional to $d e$, which is also the number of output cells. If only the total is needed, multiplication computes it immediately.

## Why this finite model matters

The model captures a recurring strategy in modern mathematics: replace fragile geometric detail by stable weighted combinatorics. A tropical picture can be easier to inspect, enumerate, and compute than its algebraic ancestor. Multiplicities retain information that would otherwise vanish when points collide or when curved objects become polyhedral.

This has practical echoes beyond algebraic geometry. Polyhedral complexes appear in optimization, discrete geometry, and computational topology. Balanced weighted networks resemble conserved flows. Reindexing a weighted sum across a bijection is the same invariant principle used whenever data are transported between equivalent representations. The special content of tropical geometry lies in finding representations where hard algebra becomes countable geometry.

The finite theory also draws a clear boundary around what remains difficult. Counting the transverse model is elementary; proving that a geometric situation genuinely tropicalizes to that model can be deep. Future developments can replace the rectangular degree model by Newton polygons and mixed area, prove invariance under small perturbations, construct correspondences over complete non-Archimedean fields, and extend the product formula to $n$ hypersurfaces with total multiplicity $\prod_i d_i$.

The lesson is not that tropicalization makes every problem trivial. It is that it reveals the correct invariant. Shapes may bend into graphs, points may merge, and equations may fade into polyhedra, but the weighted total remains—provided support and local multiplicity cross the bridge intact. In the transverse plane, that invariant resolves into the simplest possible image: a rectangle with $d e$ unit cells, each one carrying a piece of Bézout’s enduring count.
