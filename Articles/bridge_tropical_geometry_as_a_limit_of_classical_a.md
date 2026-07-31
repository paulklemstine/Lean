# When Algebra Freezes into Geometry

## Tropical geometry as the large-scale shadow of polynomial equations

A polynomial curve can be an unruly object. Even a modest equation may trace loops, intersect itself, disappear into complex coordinates, or depend delicately on its coefficients. Tropical geometry offers a startling change of scenery: replace addition by maximum, replace multiplication by addition, and smooth algebraic curves turn into angular, weighted graphs. The result looks less like a classical curve and more like a subway map.

This is not merely a visual analogy. A non-Archimedean valuation converts multiplication into multiplication of sizes and makes the size of a sum no larger than the largest size of its terms. When a polynomial vanishes, that simple inequality forces a tie among its largest terms. Those ties are exactly the corners of a tropical polynomial. Thus every classical zero casts a tropical shadow on a piecewise-linear skeleton.

The bridge rests on one elementary but powerful principle: **a vanishing sum of nonzero terms cannot have a uniquely largest valuation**. From it follow the hypersurface inclusion at the heart of tropicalization, the stability of tropical corner loci under positive rescaling, and a clean explanation of why intersection numbers survive whenever points and multiplicities correspond.

## A different arithmetic of size

Let $K$ be a field equipped with a non-Archimedean valuation $v$. We use a multiplicative convention: $v(0)=0$, nonzero elements have nonzero value, and

$$
v(ab)=v(a)v(b), \qquad v(a+b)\leq \max\{v(a),v(b)\}.
$$

The value set is linearly ordered, so finite collections have largest elements. Familiar examples arise from prime-adic arithmetic. For a prime $p$, one can measure a nonzero rational number by $|x|_p=p^{-\operatorname{ord}_p(x)}$. Divisibility by high powers of $p$ makes a number small, while a large denominator involving $p$ makes it large. In this geometry of size, the ordinary triangle inequality becomes the stronger ultrametric inequality

$$
|x+y|_p\leq \max\{|x|_p,|y|_p\}.
$$

Imagine several nonzero terms $a_1,\ldots,a_m$ adding to zero. Suppose one term, say $a_i$, had valuation strictly greater than all the others. Then the sum of the remaining terms would still have valuation strictly smaller than $v(a_i)$. But the equation

$$
\sum_{j\ne i}a_j=-a_i
$$

says that this remainder has exactly the same valuation as $a_i$, because changing sign does not change valuation. Contradiction.

This gives the **Non-Archimedean Cancellation Theorem**: if a finite family of nonzero elements satisfies $\sum_i a_i=0$, then no member has valuation strictly larger than every other member. Equivalently, every term is matched or exceeded in valuation by a different term. In particular, the maximum valuation is attained at least twice.

The statement captures the distinctive rigidity of ultrametric arithmetic. In ordinary absolute value, a large term can be cancelled by the combined effect of many smaller terms. Non-Archimedean size forbids that coalition: if every opponent is strictly smaller, their entire sum remains strictly smaller.

## Corners are ties

Now take finitely many real-valued functions $F_i(x)$ on a space $X$. Their max-tropical polynomial is

$$
F(x)=\max_i F_i(x).
$$

A point $x$ lies in the **max-corner locus** when at least two distinct indices $i$ and $j$ attain this maximum:

$$
F_i(x)=F_j(x)=\max_k F_k(x).
$$

For affine functions on Euclidean space, the maximum is convex and piecewise linear. Away from a tie, one affine piece wins and the graph is locally flat. At a tie, the winning piece changes, producing a ridge or corner. The corner locus is the visible tropical hypersurface.

For example, consider

$$
F(x,y)=\max\{0,x,y\}.
$$

Its corner locus consists of three rays meeting at the origin: the negative $x$-axis, the negative $y$-axis, and the ray $x=y\geq 0$. This three-armed graph is the tropical line. Each arm records a different pairwise tie among $0$, $x$, and $y$.

Some authors use minima rather than maxima. The two languages are equivalent. Negating every term reverses order, so the minimum of $-F_i(x)$ is attained at least twice exactly when the maximum of $F_i(x)$ is attained at least twice. This is the **Sign-Reversal Principle for Tropical Corners**: max and min conventions describe the same geometry after reflection of all values through zero.

## Why every zero lands on a corner

Suppose a polynomial or Laurent polynomial has been decomposed into finitely many terms,

$$
f(z)=\sum_{i\in I} T_i(z).
$$

Fix a point $z$ at which every $T_i(z)$ is nonzero. Associate to it the valuation data $v(T_i(z))$. If $f(z)=0$, then the terms form a vanishing finite sum. Non-Archimedean cancellation says their largest valuation must occur at least twice.

This proves the **Valuation-to-Corner Theorem**: for any finite family of nonzero terms over a non-Archimedean valued field, every point where their sum vanishes maps under termwise valuation to the max-corner locus. In symbols, if

$$
\sum_{i\in I}T_i(z)=0 \quad\text{and}\quad T_i(z)\ne 0\text{ for all }i,
$$

then there are distinct $i,j\in I$ such that

$$
v(T_i(z))=v(T_j(z))=\max_{k\in I}v(T_k(z)).
$$

This is one direction of the hypersurface form of the tropical fundamental theorem. It says that valuation images of classical zeros cannot wander into the open regions where one tropical monomial dominates. They are confined to the walls separating those regions.

The reverse direction is subtler: realizing every tropical corner as the valuation of a classical zero requires additional hypotheses and deeper lifting arguments. The forward direction already reveals why tropical hypersurfaces have their characteristic shape. The graph is not an arbitrary approximation; it is forced by cancellation.

A simple three-term example makes the mechanism concrete. Over a prime-adic field, let $a+b+c=0$, with all three terms nonzero. If $|a|_p$ is maximal, at least one of $|b|_p$ and $|c|_p$ must equal or exceed it. Since $|a|_p$ was already maximal, equality follows. At the level of tropical functions, the associated point sits exactly where two or three pieces tie.

## Turning up the scale

Tropical geometry is often described as a large-scale or low-temperature limit of classical geometry. The precise meaning of “limit” depends on the setting, and one must distinguish genuine analytic convergence from exact invariance. For corner loci, there is an especially clean stabilization statement.

Let $c>0$ and multiply every tropical term by $c$. Because positive multiplication preserves order,

$$
F_k(x)\leq F_i(x) \quad\Longleftrightarrow\quad cF_k(x)\leq cF_i(x).
$$

Therefore the same indices are maximal before and after scaling. This gives the **Positive-Scale Invariance Theorem**: for every positive real $c$, the max-corner locus of the family $\{cF_i\}$ is exactly the max-corner locus of $\{F_i\}$.

In particular, at every positive integral scale $n+1$,

$$
\operatorname{Corner}\bigl((n+1)F_i\bigr)
=
\operatorname{Corner}(F_i).
$$

So along the sequence of scales $1,2,3,\ldots$, no asymptotic waiting is required: the tropical hypersurface has already stabilized setwise. The numerical heights stretch, but the walls where winners tie remain fixed. This is a rigorous core of the “valuation goes to infinity” picture. It does not, by itself, claim Hausdorff convergence of classical zero sets; rather, it identifies an exact scale-invariant skeleton once the tropical functions have been formed.

The phenomenon resembles zooming in on a map printed on elastic material. Distances between contour heights grow, but the borders separating regions do not move. Tropical geometry remembers the competition among terms, not their common unit of measurement.

## Counting intersections without losing weight

Geometry is not only about where objects meet; it is also about how strongly they meet. A tangency counts differently from a transverse crossing. To retain this information, assign each point $p$ in a finite intersection set $S$ a nonnegative integer multiplicity $m(p)$. Define the weighted intersection number by

$$
I(S,m)=\sum_{p\in S}m(p).
$$

Suppose a classical intersection set $S$ corresponds bijectively to a tropical intersection set $T$. Let $\phi:S\to T$ be the correspondence, and suppose it preserves multiplicity:

$$
m_S(p)=m_T(\phi(p)) \quad\text{for every }p\in S.
$$

Then simply reindexing the finite sum proves the **Weighted Correspondence Theorem**:

$$
I(S,m_S)=I(T,m_T).
$$

This elementary identity is the final counting bridge behind a conditional tropical Bézout statement. If two classical plane curves of degrees $d$ and $e$ have a finite intersection whose weighted classical count is $de$, and if their classical and tropical intersection points are linked by a multiplicity-preserving bijection, then the tropical weighted intersection number is also

$$
de.
$$

This is the **Conditional Tropical Bézout Theorem**. Its conditions matter. The theorem does not manufacture the geometric correspondence, prove properness, or define stable local tropical multiplicity. Instead, it isolates exactly what is needed to transfer Bézout’s classical count: matching points and matching weights. Once those geometric ingredients are established, the global numerical equality follows inevitably.

## The architecture of the bridge

The full picture now has three layers.

First comes **cancellation**. A classical zero is a balance among nonzero terms, and ultrametric arithmetic forces at least two terms to share the top valuation.

Second comes **polyhedral geometry**. A tie for the maximum is a corner of a piecewise-linear tropical polynomial. Positive rescaling changes heights but preserves every comparison, so the corner skeleton is stable at all positive scales.

Third comes **enumerative transfer**. When classical and tropical intersection points correspond and their multiplicities agree, weighted counts agree. Classical Bézout numbers then pass directly to the tropical side.

Each layer deliberately separates universal logic from deeper geometric input. Cancellation requires only a finite nonzero vanishing sum. Scale invariance requires only ordered real values and a positive multiplier. Weighted transfer requires only a finite multiplicity-preserving bijection. More ambitious conclusions—lifting every corner to a zero, proving convergence of logarithmic amoebas, or constructing stable intersection correspondences—demand additional geometry.

That separation is a strength. It tells researchers exactly where the hard work lives. The tropical shadow of a zero is forced by valuation. The persistence of the corner locus is forced by order. The preservation of a total intersection count is forced by reindexing. What remains is to build the geometric correspondences that connect these universal mechanisms in rich settings.

Tropical geometry earns its name from the image of a classical world under extreme conditions: as a landscape cools or a scale grows, smooth forms crystallize into linear facets. Yet the mathematics shows something sharper than a metaphor. At the decisive places, algebra cannot cancel unless leading sizes tie. Those ties draw the tropical skeleton; scaling leaves it motionless; and multiplicities carry classical counts across it. The subway map is not merely simpler than the city. It records the routes along which the city’s algebra is compelled to travel.
