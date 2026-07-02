# How Many Ways Can You Split a Cloud of Points?

## The surprisingly deep question hiding inside a coin flip

Imagine you are handed a scattering of dots on a sheet of paper and a straight ruler. Your job is to draw one straight line that puts some dots on one side and the rest on the other. Now suppose someone assigns each dot a color — red or blue — completely at random, and challenges you: *can your line separate the reds from the blues?*

Sometimes you can. Sometimes the coloring is so tangled that no single straight line will ever do the job. A natural question follows, and it is deeper than it looks: **out of all the possible red/blue colorings of $N$ dots, how many can a straight line actually realize?**

This is not an idle puzzle. It sits at the mathematical foundation of machine learning. A "linear classifier" — the humblest and most fundamental learning machine — is exactly a ruler that tries to separate two classes of data. The number of colorings it can realize measures its raw expressive power: how many different patterns it could, in principle, ever learn. And the answer, first written down by Thomas Cover in 1965, is a beautiful piece of combinatorics that has quietly shaped how we think about the capacity of learning systems ever since.

## Cover's counting function

Let us make the question precise. Take $N$ points in a $d$-parameter space, arranged in **general position** — a technical way of saying no accidental alignments, no three points on a line when they shouldn't be, no degenerate coincidences. We count the *dichotomies*: the ways to split the points into two labeled groups using a homogeneous linear threshold (a separating hyperplane through the origin). The count is what we now call **Cover's counting function**:

$$C(N, d) = 2 \sum_{k=0}^{d-1} \binom{N-1}{k}.$$

The factor of $2$ accounts for the two orientations of every split (which side is "red"). The sum of binomial coefficients is where all the structure lives.

A couple of sanity checks make the formula feel alive. A single point can always be labeled either color, so $C(1, d) = 2$ whenever $d \geq 1$. A one-dimensional threshold — a single number acting as a cutoff — realizes exactly two labelings no matter how many points you have: $C(N, 1) = 2$.

## The "add one point" recurrence

Cover's genius was to see how the count changes when you drop in one more data point. Adding a point can only do one of two things to an existing separating rule: either the point falls cleanly on one side (the labeling survives untouched), or it lands exactly where the boundary could swing to include it either way (the labeling *splits into two*). Bookkeeping this doubling-versus-preserving dance yields a clean recursion. For $N \geq 1$,

$$C(N+1, d+1) = C(N, d+1) + C(N, d).$$

This is nothing but Pascal's triangle wearing a geometric disguise. The recursion *is* the geometry — the act of adding a sample — while the closed binomial formula is the combinatorics that solves it. One of the central facts we establish is that these two faces truly agree: the closed form satisfies the recursion exactly.

## Two regimes: saturation and collapse

The formula has a personality that changes dramatically depending on whether you have more data or more freedom.

**When freedom wins.** If the number of points is at most the number of parameters, $N \leq d$, then *every* conceivable labeling can be realized:

$$C(N, d) = 2^N \qquad (N \leq d).$$

There are $2^N$ colorings in total, and the classifier can produce all of them. It is infinitely flexible relative to the data — it *saturates*.

**When data wins.** The moment the data outnumbers the effective freedom, $d < N$, something irreversible happens. The count drops *strictly* below the maximum:

$$C(N, d) < 2^N \qquad (d < N).$$

Some labelings become forever unreachable. This strict collapse is the mathematical signature of *limited capacity*: a low-dimensional rule simply cannot express every pattern in a large dataset. As a concrete taste, five points governed by three parameters yield $C(5, 3) = 22$ realizable labelings — well short of the $2^5 = 32$ that exist. Ten labelings are lost to the geometry.

## The twist: what happens when data lives on a curved surface?

Here is where the story turns genuinely modern. Real data rarely fills up the high-dimensional space it nominally lives in. Photographs, sound recordings, sensor readings — they cluster along thin, curved, low-dimensional structures inside a vast ambient space. Mathematicians call such a structure a **manifold**. A sheet of paper crumpled inside a room is a two-dimensional manifold living in three dimensions; the pixels of a face photo trace out a surface of just a few dozen intrinsic dimensions inside a space of millions.

So suppose our points do not roam freely in $\mathbb{R}^M$ but are confined to a $d$-dimensional manifold $E$ sitting inside it — and then we pass them through a smooth, injective **feature map** $\Phi : E \to \mathbb{R}^{M'}$ before classifying, exactly as a modern learning pipeline would. Which dimension controls the expressive power now: the huge ambient dimension $M$, the feature dimension $M'$, or the modest intrinsic dimension $d$?

The answer is the heart of this work, and it is striking. What governs everything is a quantity called the **Kruskal rank** of the data — informally, how many points you can pick before they become linearly entangled. For points in general position on a $d$-dimensional manifold, this rank obeys a hard ceiling:

$$s \leq d + 1.$$

The intrinsic dimension caps it. The ambient dimension $M$ — no matter how astronomically large — does not appear. And from this rank ceiling, the entire dichotomy count of the feature-mapped classifier is pinned down: it obeys *exactly the same* one-point recursion as Cover's function, now with an effective parameter budget of

$$p = d + M' + 1.$$

## The maximal-solution theorem

To make this rigorous we abstract away the geometry entirely. We say a quantity $g(N, d)$ is a **dichotomy system** if it starts from Cover's base values ($g(1, d) \leq 2$ and $g(N, 1) \leq 2$) and obeys the subadditive one-point recursion

$$g(N+1, d+1) \leq g(N, d+1) + g(N, d).$$

The central analytic theorem then says: **Cover's function is the maximal solution.** Any quantity obeying these geometric constraints is bounded above by Cover's counting function:

$$g(N, d) \leq C(N, d).$$

This is the engine of the whole theory. It converts a *geometric* fact — "adding a point at most doubles the affected labelings" — into a *closed-form* combinatorial bound. It is precisely the skeleton of Cover's original theorem, isolated and proved in full generality. And because Cover's own function satisfies every constraint with *equality*, the bound is tight: it cannot be improved.

Stitching the pieces together gives the manifold-constrained dichotomy bound:

$$C_F(N) \leq C(N,\, d + M' + 1),$$

and, whenever the budget is exhausted by the data ($d + M' + 1 < N$), the strict collapse

$$C_F(N) < 2^N.$$

## Why this matters

Three consequences deserve to be spoken plainly.

**Intrinsic dimension is what counts.** The bound depends on $d$, the dimension of the underlying structure, not on the ambient dimension $M$ in which the data happens to be embedded. You can drown your data in a million ambient coordinates; if it truly lives on a ten-dimensional surface, its classifiability is governed by that ten. This is a precise, provable version of a folk belief that runs through modern data science — that the "curse of dimensionality" is really a curse of *intrinsic* dimensionality, and low-dimensional data is fundamentally easier.

**Expressivity has a hard budget.** Once the sample size exceeds the effective parameter budget $p = d + M' + 1$, the classifier provably cannot realize all labelings. There is a crisp threshold separating "can memorize anything" from "must generalize." This is capacity, made exact.

**The bottleneck is geometric, not accidental.** Because the entire argument reduces to the Kruskal rank ceiling $s \leq d+1$, the loss of expressivity is a structural feature of low-dimensional data, not an artifact of a particular classifier or embedding. Smooth injective maps can preserve or shrink the rank, never inflate it.

## The bigger picture

There is something quietly wonderful about a formula from 1965, born of ruler-and-dot geometry, turning out to be the right language for the deep-learning era. Cover was counting linear separations of abstract points; today the same counting function bounds the expressive capacity of feature-mapped classifiers acting on data that lives on curved manifolds inside enormous spaces.

The through-line is a single, robust idea: **the complexity a learning machine can express is limited by the intrinsic geometry of its data, not by the size of the space that data is drawn in.** Enlarge the room all you like — what matters is the shape of the crumpled sheet inside it. That is a comforting thought in an age of ever-higher dimensions, and here it is not a slogan but a theorem.
