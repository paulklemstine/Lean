# The Sphere That Refused to Be Sparse

## A geometric stress test for a new kind of neural attention

Modern artificial intelligence spends an extraordinary amount of effort deciding what to notice. A language model reading a sentence compares each word with many other words. A vision model compares patches of an image. A scientific model may compare particles, atoms, or points in a cloud. The mechanism responsible for these comparisons is called **attention**, and its central object is a table of weights: large weights mark strong relationships, while small weights mark relationships that might safely be ignored.

This creates a tempting computational dream. If almost all weights were tiny, a model could discard them and calculate only the few important interactions. For a sequence of $N$ items, replacing $N$ meaningful interactions per query by roughly $\sqrt{N}$ would be a dramatic reduction. Geometry seems like a natural way to obtain such sparsity. Put queries and keys on a sphere, measure their separation, and let nearby points interact more strongly than distant ones.

One elegant proposal uses the Cauchy kernel. If $q$ is a query and $k$ is a key, define their attention weight by

$$
K(q,k)=\frac{1}{1+\lVert q-k\rVert^2}.
$$

The formula is smooth, positive, and geometrically meaningful. It is closely related to stereographic projection, the classical map that connects a sphere with a plane. The resulting mechanism may therefore be called **stereographic attention**. At first glance, it seems well suited to creating a long tail of negligible interactions.

But the sphere hides a decisive obstruction. On a unit sphere, no two points can be farther apart than $2$. That elementary fact forces every Cauchy weight to be at least $1/5$. The hoped-for cloud of near-zero weights never appears.

This is not a probabilistic caveat, an asymptotic technicality, or a rare bad configuration. It is a deterministic geometric barrier.

## From a sphere to an attention rule

Let the query and key vectors lie in any normed vector space, and require both to have norm one:

$$
\lVert q\rVert=\lVert k\rVert=1.
$$

Their Euclidean or norm-induced distance is $\lVert q-k\rVert$. The Cauchy attention rule assigns weight

$$
K(q,k)=\frac{1}{1+\lVert q-k\rVert^2}.
$$

When $q=k$, the distance is zero and the weight is $1$, its maximum possible value. As the points separate, the denominator grows and the weight falls. In an unbounded space, the distance can become arbitrarily large, so the weight can approach zero. That familiar intuition makes the kernel seem sparse-friendly.

The unit sphere changes the story because it is bounded. By the triangle inequality,

$$
\lVert q-k\rVert\leq \lVert q\rVert+\lVert k\rVert=2.
$$

Squaring gives $\lVert q-k\rVert^2\leq 4$. Therefore

$$
1+\lVert q-k\rVert^2\leq 5,
$$

and taking reciprocals yields the central result:

$$
K(q,k)\geq \frac15.
$$

Call this the **Uniform Weight-Floor Theorem**: for every pair of unit-sphere points, the unscaled Cauchy attention weight lies in the interval $[1/5,1]$.

The lower endpoint is sharp whenever antipodal points are available. If $k=-q$, then $\lVert q-k\rVert=\lVert 2q\rVert=2$, so $K(q,k)=1/5$. At the other endpoint, $k=q$ gives $K(q,k)=1$. Thus the entire dynamic range of the raw kernel on the sphere is only a factor of five.

## Why randomness cannot rescue the idea

A common response to an unfavorable worst-case bound is to appeal to random data. Perhaps most random points are much farther apart in high dimensions; perhaps typical weights behave better than the extreme cases suggest. Random geometry can indeed create powerful concentration effects. Yet it cannot produce values outside a deterministic range.

Suppose $q,k_1,\ldots,k_N$ are sampled by any procedure whatsoever, provided every sampled vector lies on the unit sphere. For every outcome and every index $i$,

$$
K(q,k_i)\geq \frac15.
$$

Consequently, the same statement holds with probability one under every probability distribution supported on the sphere. Uniform sampling, clustered sampling, adversarial sampling, and dimension-dependent sampling all face exactly the same floor.

This distinction matters. A probabilistic sparsity theorem normally estimates how many weights exceed a threshold $\tau$. Define a key to be active when

$$
K(q,k_i)\geq \tau.
$$

If $\tau\leq 1/5$, then every key is active. Equivalently, no key has weight below $\tau$. For a finite set of $N$ keys, the active count is therefore exactly

$$
A_\tau=N.
$$

This is the **Exact Active-Count Theorem**: at every threshold at most $1/5$, unscaled Cauchy attention on unit-sphere data retains all keys.

The theorem immediately rules out a literal square-root active-count bound. If $N>1$, then the integer square root satisfies $\lfloor\sqrt{N}\rfloor<N$. Since $A_\tau=N$, one has

$$
\lfloor\sqrt{N}\rfloor<A_\tau.
$$

So the active set is not merely larger than a constant multiple suggested by an optimistic experiment. It remains fully dense.

## A useful negative result

Negative results are sometimes described as failures, but this one functions more like a design diagnostic. It identifies exactly which ingredients are incompatible:

1. queries and keys constrained to a unit sphere;
2. the unscaled kernel $K(q,k)=(1+\lVert q-k\rVert^2)^{-1}$;
3. pruning at a fixed threshold $\tau\leq 1/5$; and
4. a claim that only about $\sqrt{N}$ keys survive.

All four cannot hold simultaneously. No choice of dimension, random distribution, or sample size changes that conclusion.

The diagnosis also clarifies why the original intuition was misleading. Cauchy decay is useful when distances can grow. Spherical normalization deliberately removes radial scale and compresses every pairwise distance into $[0,2]$. The very operation that supplies geometric regularity also prevents the denominator from becoming large. The mechanism inherits smoothness and symmetry from the sphere, but not sparsity.

This lesson extends beyond one kernel. Whenever a decreasing radial kernel is placed on a bounded metric space, its minimum is controlled by the diameter. If a space has diameter $D$ and the kernel is $f(d)$ with $f$ decreasing, then every interaction is at least $f(D)$. Before searching for sophisticated concentration estimates, one should calculate this elementary floor.

## What can be changed?

The obstruction is specific enough to suggest repairs.

### Add a bandwidth

Introduce a scale $\beta>0$:

$$
K_\beta(q,k)=\frac{1}{1+\beta\lVert q-k\rVert^2}.
$$

The smallest possible weight becomes $1/(1+4\beta)$. Increasing $\beta$ lowers the floor and makes a fixed pruning threshold meaningful. Moreover, the active condition has a direct geometric interpretation:

$$
K_\beta(q,k)\geq\tau
\quad\Longleftrightarrow\quad
\lVert q-k\rVert^2\leq\frac{\tau^{-1}-1}{\beta}.
$$

Thus active keys occupy a spherical cap around the query. Sparsity becomes a question about cap area, dimension, and sample size.

### Raise the kernel to a power

Another option is

$$
K_p(q,k)=\bigl(1+\lVert q-k\rVert^2\bigr)^{-p}.
$$

Its floor is $5^{-p}$, which can be very small when $p$ is large. The exponent creates sharper contrast without abandoning the basic Cauchy geometry. The important research question is then quantitative: how should $p$ depend on dimension $d$, number of keys $N$, and threshold $\tau$ to leave about $\sqrt{N}$ active keys?

### Select by rank rather than absolute size

A top-$k$ rule always retains a prescribed number of keys, regardless of the kernel floor. Yet computational sparsity alone is not enough. One must also bound the mass discarded after weights are normalized. If many raw weights are comparable—as the factor-of-five range permits—then retaining only $O(\sqrt{N})$ entries may throw away most of the total attention mass.

## A practical test before implementation

The main result suggests a simple workflow for geometric attention design.

First, identify the diameter of the representation space. Second, evaluate the kernel at that diameter. Third, compare this minimum with the intended pruning threshold. Only then should one simulate random samples or derive concentration inequalities.

For the unit sphere and the unscaled Cauchy kernel, the calculation is immediate:

$$
D=2,
\qquad
K_{\min}=\frac{1}{1+D^2}=\frac15.
$$

A threshold below $0.2$ cannot prune anything. A numerical demonstration can sample thousands of random unit vectors, compute all query-key weights, and confirm that the smallest observed value stays above $0.2$. Such experiments illustrate the geometry, but the theorem is stronger: it covers every possible sample, including those never generated.

## The broader message

Stereographic attention remains an appealing geometric idea. Mapping representations to a sphere can remove irrelevant scale, preserve directional information, and connect neural computation with a rich body of conformal geometry. The Cauchy kernel is positive, smooth, and interpretable. None of those virtues, however, automatically supplies sparse computation.

The key mathematical fact is compact enough to fit on a blackboard: unit vectors are at distance at most $2$, so their unscaled Cauchy weight is at least $1/5$. From that one inequality follow the empty below-threshold set, the exact active count $N$, and the failure of a $\sqrt{N}$ active-count claim at low fixed thresholds.

That is the value of a sharp obstruction. It does not merely say that one experiment may disappoint. It tells us why, for an entire class of experiments, the desired effect cannot occur. Better still, it points toward mechanisms that might work: bandwidth scaling, powered kernels, spherical-cap calibration, concentration bounds, and carefully analyzed top-$k$ approximations.

Geometry did not deliver sparsity for free. It delivered something more useful first: a clear boundary between hope and possibility.

There is also a methodological moral. In fast-moving fields, plausible asymptotic stories can outrun the elementary constraints of a model. A diameter calculation costs almost nothing, yet here it decides the first and most important sparsity question. The right next step is not to abandon spherical attention, but to redesign it with the bound in view. Once a bandwidth or exponent is introduced, experiments and probability theory can address a genuinely open quantitative problem rather than searching for an effect that the original geometry forbids.
