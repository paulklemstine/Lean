# Reading Shape from a Cloud of Points

## A Poincaré-inspired guide to what proximity complexes can—and cannot—tell us

A medical scanner does not see an organ as a smooth surface. A robot does not receive a perfect map of the room. A climate sensor network does not hand us a continuous atmospheric field. In each case, the raw object is a finite cloud of points: locations in a large coordinate space, perhaps noisy, perhaps incomplete, and certainly missing the continuous geometry we would like to understand.

The seductive question is whether topology can recover the hidden shape. If the points seem to arrange themselves like a sphere, can we certify that a sphere is really there?

The inspiration is the Poincaré theorem: every closed, simply connected three-dimensional manifold is topologically a three-sphere. But translating that statement to data requires care. A finite point cloud is not a manifold. Its homology may imitate that of a sphere without its geometry being close to one. Even a combinatorial complex with sphere-like global holes can hide singular local structure. The right first step is therefore not a grand sphere-recognition claim. It is to establish the dependable metric machinery beneath such a claim, to identify exact thresholds, and to state clearly where geometry ends and topology must begin.

That machinery starts with a ruler.

## Turning distance into a changing network

Let $X=\{x_1,\ldots,x_n\}$ be a finite collection in a metric space, and choose a scale $\varepsilon$. The **Rips graph at scale $\varepsilon$** joins two distinct observations $x_i$ and $x_j$ exactly when

$$
d(x_i,x_j)\leq \varepsilon.
$$

At a tiny scale, the graph may contain almost no edges. As the scale increases, nearby points connect, connected components merge, loops emerge, and eventually every pair may be joined. Filling every clique—every set of mutually adjacent vertices—with a simplex produces the **Rips flag complex**. An edge becomes a one-simplex, a triangle of three pairwise adjacent points becomes a filled two-simplex, and so on.

The first result is simple but fundamental: **Rips filtration monotonicity** says that if $\varepsilon\leq\eta$, then every edge present at scale $\varepsilon$ is present at scale $\eta$, and every simplex present at scale $\varepsilon$ is present at scale $\eta$. The proof is the one-line observation that $d(x_i,x_j)\leq\varepsilon\leq\eta$. Thus scale acts like time in a film whose geometry can only accumulate edges and simplices.

There are useful boundary checks. At every negative scale, the Rips graph is empty because distances are nonnegative. At scale zero it is also empty in a genuine metric space, where distinct points have positive distance. In a pseudometric space, however, distinct points may have distance zero, so that second statement can fail. This small distinction matters in data sets with duplicated or metrically indistinguishable observations.

For integer scales $r=0,1,2,\ldots$, define the **edge-count profile** $E(r)$ to be the number of edges in the Rips graph at scale $r$. Then $E$ is nondecreasing, $E(0)=0$ for a finite metric space, and it never exceeds the number of unordered vertex pairs. These facts offer a basic diagnostic curve: abrupt rises reveal scales at which many interpoint distances are crossed. But edge counts alone do not measure holes, and a graph with many edges need not resemble a sphere.

## Noise costs twice

Real measurements move. Suppose $X=(x_i)$ and $Y=(y_i)$ are two point clouds with matched labels, and every point moves by at most $\delta$:

$$
d(x_i,y_i)\leq\delta \qquad\text{for every }i.
$$

How much must the Rips scale change to preserve all relationships? The answer is exactly the natural triangle-inequality allowance: $2\delta$.

The **matched perturbation theorem** states that every Rips edge of $X$ at scale $\varepsilon$ is an edge of $Y$ at scale $\varepsilon+2\delta$. Indeed,

$$
d(y_i,y_j)\leq d(y_i,x_i)+d(x_i,x_j)+d(x_j,y_j)
\leq\delta+\varepsilon+\delta.
$$

Because a clique is defined entirely by its edges, every simplex of the Rips complex of $X$ at scale $\varepsilon$ also belongs to the Rips complex of $Y$ at scale $\varepsilon+2\delta$. Distance is symmetric, so the reverse inclusion holds after the same shift. The two filtrations therefore interleave under a scale translation of $2\delta$.

This theorem has an immediate numerical shadow: the number of simplices in the first complex at scale $\varepsilon$ is no greater than the number in the perturbed complex at scale $\varepsilon+2\delta$. More importantly, it gives a clean accounting rule for noise. Each endpoint of an edge may move by $\delta$, so an edge threshold may move by twice that amount.

The factor $2$ cannot be uniformly improved. Imagine two points initially $\varepsilon$ apart and move them directly away from each other by $\delta$ each. Their new distance is $\varepsilon+2\delta$.

## The exact moment everything fills in

As scale grows, every finite Rips complex eventually becomes the full simplex: every subset of the $n$ vertices is a face. A full simplex has exactly $2^n$ faces when the empty face is included. What controls this transition?

The answer is not homology and not sphericality. It is simply diameter.

The **full-simplex threshold theorem** states that, for $\varepsilon\geq0$, the Rips flag complex contains all $2^n$ vertex subsets if and only if every pair of sample points has distance at most $\varepsilon$:

$$
\#\operatorname{Rips}(X,\varepsilon)=2^n
\quad\Longleftrightarrow\quad
\max_{i,j}d(x_i,x_j)\leq\varepsilon.
$$

Consequently, the first full-simplex scale is the sample diameter. If even one pair lies farther apart than $\varepsilon$, the complex has strictly fewer than $2^n$ faces.

A two-point example makes the boundary vivid. Put the observations at $0$ and $2$ on the real line. At scale $1$, the edge is missing and the complex is not full. At scale $2$, the edge appears and all four faces—the empty face, two vertices, and their edge—are present.

This exact result prevents a common conceptual mistake. The diameter threshold is not a “Poincaré threshold.” Once a complex becomes a full simplex, it is contractible: all higher-dimensional holes have been filled. The transition says that all pairwise distances fit beneath one cutoff. It says nothing by itself about whether the original cloud sampled a sphere.

## What spherical geometry does guarantee

Suppose every point lies exactly on a sphere of radius $r$ centered at $c$, meaning

$$
d(x_i,c)=r \qquad\text{for every }i.
$$

The triangle inequality gives

$$
d(x_i,x_j)\leq d(x_i,c)+d(c,x_j)=2r.
$$

Thus the **spherical diameter bound** says that every pair is at distance at most $2r$, with equality possible for antipodal points. Combining this with the full-simplex theorem yields the **spherical completion theorem**: at scale $2r$, the Rips complex of any finite sample on that sphere is the full simplex and has $2^n$ faces.

There is also a robust version. Call a cloud **$\delta$-approximately spherical** about center $c$ and radius $r$ if

$$
\left|d(x_i,c)-r\right|\leq\delta
\qquad\text{for every }i.
$$

Then every point is at most $r+\delta$ from $c$, so every pair is at most $2(r+\delta)$ apart. The **approximate spherical completion theorem** follows: for $r\geq0$ and $\delta\geq0$, the Rips complex is full by scale $2(r+\delta)$.

Approximate sphericality itself is stable. If an exact spherical sample is perturbed pointwise by at most $\delta$, then the perturbed sample is $\delta$-approximately spherical around the same center and radius. This is the reverse triangle inequality in action: moving a point by $\delta$ changes its distance to the center by at most $\delta$.

These are strong geometric guarantees, but they are deliberately one-way. Points on a sphere must obey a diameter bound. A cloud obeying the same bound need not lie near any sphere. A ball, a cluster, or an irregular configuration can also have small diameter.

## Coverage: the missing half of sampling

Sphere detection needs more than an upper bound on pairwise distances. It needs evidence that the sample covers the candidate surface rather than merely occupying a small patch.

For a finite set $S$, an **$\varepsilon$-cover** is a finite collection $C$ such that every point of $S$ lies within $\varepsilon$ of some member of $C$. The **covering number** $N(S,\varepsilon)$ is the smallest possible size of such a cover. Increasing the radius makes covering easier, so if $0\leq\varepsilon_1\leq\varepsilon_2$, then

$$
N(S,\varepsilon_2)\leq N(S,\varepsilon_1).
$$

The empty set has covering number zero, and any finite set covers itself at every nonnegative radius, giving $N(S,\varepsilon)\leq\#S$.

A complementary notion is an **$\varepsilon$-packing**: a subset whose distinct points are all farther than $\varepsilon$ apart. If such a packing is maximal in the explicit sense that every omitted point lies within $\varepsilon$ of some packed point, then it is automatically an $\varepsilon$-cover. This packing-covering principle supplies a practical algorithm: repeatedly select a point not yet covered and discard everything within radius $\varepsilon$. The selected points are separated, and when the process stops they cover the data.

Coverage also clarifies the proposed sampling law. Typical point spacing on a $d$-dimensional object often has order $n^{-1/d}$, but uniform coverage is controlled by the largest empty region, an extreme event. For independent uniform samples, the more plausible coverage scale is often of order

$$
\left(\frac{\log n}{n}\right)^{1/d},
$$

rather than the bare power $n^{-1/d}$. Which scale is relevant depends on whether one asks about a typical neighbor, an average criterion, or the worst uncovered gap.

## Toward honest sphere detection

The emerging picture is a pipeline, not a single magical threshold.

First, use distances to build a monotone Rips filtration. Second, use the $2\delta$ interleaving law to account for measurement noise. Third, distinguish the sample diameter—the exact full-simplex threshold—from spacing and coverage scales. Fourth, inspect topology only in a range where the sample is dense enough and the underlying object is geometrically regular. Finally, supplement global homology with local tests, such as whether vertex links resemble spheres of one lower dimension, and with simple connectivity in the three-dimensional setting.

A sphere-like homology signature can be compelling evidence, but it is not a standalone recognition theorem. Global Betti numbers can be shared by singular spaces and by objects with very different local geometry. Likewise, reaching the full simplex is not evidence of a sphere; it merely means the scale has exceeded the diameter.

The durable insight is therefore both more modest and more useful than the original slogan. Manifold detection from data is indeed topological—but topology becomes reliable only when metric stability, sampling density, and local regularity are made explicit. The Rips filtration supplies the film, the $2\delta$ theorem tells us how noise shifts its frames, covering theory tells us whether the camera missed part of the scene, and local topology tells us whether the apparent surface is truly manifold-like.

That is how one begins to read a continuous shape from a finite cloud: not by declaring that a sphere has appeared, but by measuring exactly which conclusions the data can support.