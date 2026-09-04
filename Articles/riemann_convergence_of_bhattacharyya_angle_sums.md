# The Hidden Sphere Inside Statistics

## How a square root turns probability into geometry — and why the ruler finally has the right markings

### A ruler for beliefs

Suppose you are running a clinical trial, tuning a language model, or tracking a
weather forecast. In each case you carry around a *probability vector*: a list of
non-negative numbers $p = (p_1,\dots,p_n)$ that add up to $1$. As evidence arrives,
that vector moves. It traces a path through the set of all probability vectors —
the *simplex*.

An obvious question: how far did it move?

The naive answer is to treat $p$ as a point in ordinary Euclidean space and use the
straight-line distance. This is a bad ruler, and the reason is worth dwelling on.
Consider two coins. Coin A lands heads with probability $0.50$; coin B with
probability $0.51$. Now consider coin C, which lands heads with probability
$0.000001$, and coin D, heads with probability $0.010001$. In both cases the
probabilities differ by $0.01$. But you would need thousands of flips to tell A from
B, and only a handful to tell C from D — the second pair are wildly different
coins. Ordinary distance is blind to this. Near the boundary of the simplex, where
probabilities are tiny, a small absolute change is an enormous change in kind.

The fix, discovered independently by statisticians and physicists over the last
century, is to weight each coordinate by how surprising a change in it would be.
The resulting notion of *speed* along a moving probability vector $t \mapsto p_t$
with velocity $\dot p_t$ is

$$s(t) \;=\; \sqrt{\sum_i \frac{\dot p_i(t)^2}{p_i(t)}},$$

and the **Fisher–Rao length** of the path over a parameter interval $[a,b]$ is the
integral of that speed,

$$L(p;a,b) \;=\; \int_a^b \sqrt{\sum_i \frac{\dot p_i(t)^2}{p_i(t)}}\; dt .$$

Notice the $p_i$ in the denominator: a change of $0.01$ in a coordinate sitting at
$0.5$ costs almost nothing, while the same change in a coordinate sitting at
$10^{-6}$ costs a fortune. This is the ruler that statistics actually wants — it is
the one and only ruler (up to scale) that is unchanged when you re-describe your
data, and it is the ruler that appears when you measure how many samples it takes
to distinguish two hypotheses.

But an integral formula is an awkward object. It requires a differentiable path
and a velocity field. It measures curves, not pairs of points. What we want is a
*distance*: a single number attached to two probability vectors, with the triangle
inequality, computable from the two vectors alone.

### The square root that changes everything

Here is the trick, and it is the whole story in one line. Take the coordinatewise
square root:

$$p = (p_1,\dots,p_n) \;\longmapsto\; \sqrt{p} = (\sqrt{p_1},\dots,\sqrt{p_n}).$$

Because $\sum_i p_i = 1$, the image satisfies $\sum_i (\sqrt{p_i})^2 = 1$. The
square root map sends the simplex of probability vectors *exactly onto the positive
part of the unit sphere*. Probability distributions are points on a sphere.

Now the inner product of two such points has a name that statisticians already
knew:

$$\langle \sqrt{p}, \sqrt{q}\rangle \;=\; \sum_i \sqrt{p_i q_i} \;=\; BC(p,q),$$

the **Bhattacharyya coefficient** — a similarity score between distributions that
equals $1$ when they agree and drops toward $0$ as they become disjoint. Since both
vectors are unit vectors, the inner product is the cosine of the angle between
them. So the **Bhattacharyya angle**

$$\theta(p,q) \;=\; \arccos BC(p,q) \;=\; \arccos \sum_i \sqrt{p_i q_i}$$

is literally the angle you would measure at the centre of the sphere between the
two square-rooted distributions. And on a sphere, the angle *is* the distance: the
length of the great-circle arc between the points.

This gives, for free, that $\theta$ is a genuine metric on the simplex. It is
symmetric. It vanishes exactly when $p = q$, because $BC(p,q) = 1$ forces
$\sum_i(\sqrt{p_i}-\sqrt{q_i})^2 = 2 - 2BC(p,q) = 0$. And it satisfies the triangle
inequality

$$\theta(p,r) \;\le\; \theta(p,q) + \theta(q,r),$$

not by any computation with square roots, but because angles between unit vectors
in Euclidean space always obey it. All of the analytic difficulty has been
converted into spherical trigonometry.

### The calibration problem

We now have two apparently unrelated measuring devices:

* the **integral** $L$, which measures the length of a smooth path, and
* the **angle** $\theta$, which measures the separation of two points.

Are they the same ruler? The question is not rhetorical. In any metric space there
is a canonical way to measure the length of a path: chop it into finitely many
pieces at times $a = t_0 \le t_1 \le \dots \le t_N = b$, add up the distances
between consecutive points, and see what happens as the chopping gets finer. If we
do this with the Bhattacharyya angle we get the *partition angle sums*

$$\Sigma(T) \;=\; \sum_{k=0}^{N-1} 2\,\theta\big(p_{t_k}, p_{t_{k+1}}\big)
\;=\; \sum_{k=0}^{N-1} 2 \arccos BC\big(p_{t_k}, p_{t_{k+1}}\big).$$

The factor $2$ is not decoration; it is the whole calibration question. Something
must be checked, and if the check fails, the Fisher–Rao length formula would need
to be rescaled to match the geometry — a genuinely awkward outcome, since the
integral formula is the one enshrined in the statistics literature.

**The answer is that the factor $2$ is exactly right.** The main theorem of this
work is the following.

> **Riemann Convergence Theorem.** Let $t\mapsto p_t$ be a continuously
> differentiable path of strictly positive probability vectors on $[a,b]$. Then for
> every $\varepsilon>0$ there is a $\delta>0$ such that every partition
> $a=t_0\le t_1\le\dots\le t_N=b$ with all steps shorter than $\delta$ satisfies
> $$\Big|\sum_{k=0}^{N-1} 2\arccos BC(p_{t_k},p_{t_{k+1}}) \;-\; L(p;a,b)\Big| \;\le\; \varepsilon .$$
> In words: the Bhattacharyya angle sums converge to the Fisher–Rao length as the
> mesh of the partition tends to zero.

So the Fisher–Rao length functional is not merely *reminiscent of* a spherical
length — it *is* the length induced by the Bhattacharyya angle metric, in the
standard metric-space sense, with the standard normalisation. No fudge factor is
needed.

There is an even cleaner way to say it. In a metric space the length of a path is
the *supremum* of all its partition sums; refining a partition can only increase
the sum, by the triangle inequality. The same is true here:

> **Least Upper Bound Theorem.** The Fisher–Rao length of a $C^1$ path of strictly
> positive probability vectors is the least upper bound of its Bhattacharyya angle
> sums over all partitions of $[a,b]$.

Every partition underestimates the length; the estimates exhaust it.

### Why the sphere has radius two

If you have been keeping score you may wonder where the $2$ comes from
geometrically. It is not a normalisation choice, it is a measurement. Take a path
$p_t$ and follow its square root $x_t = \sqrt{p_t}$ on the sphere. The chain rule
gives $\dot x_i = \dot p_i / (2\sqrt{p_i})$, so the Euclidean speed of the
square-rooted path is

$$\|\dot x_t\| \;=\; \sqrt{\sum_i \frac{\dot p_i^2}{4 p_i}} \;=\; \tfrac12\, s(t).$$

The square-root curve moves at exactly *half* the Fisher–Rao speed. The Fisher–Rao
geometry is therefore the round geometry of a sphere of radius $2$, not $1$ — and
distances on it are $2$ times the angles. That is the factor.

### The proof, in two squeezes

The theorem is proved by pinning the angle sums between two bounds that meet.

**From above: every partition undershoots.** For this we need to know that
$2\theta(p_a,p_b) \le L(p;a,b)$ for *any* $C^1$ path from $p_a$ to $p_b$ — the
*geodesic bound*, saying that the great-circle arc is the shortest route. Summing
this over the pieces of a partition, and using that the length integral is
additive, gives $\Sigma(T)\le L$ for every partition at once.

The geodesic bound itself is the subtle step. The seductive approach — differentiate
$t\mapsto \arccos\langle x_t,x_a\rangle$ and bound the derivative — is a trap: that
derivative blows up whenever the inner product hits $\pm 1$, exactly at the moments
you cannot avoid. The route that works is combinatorial. Chop $[a,b]$ into $N$
equal pieces. On each piece one has the elementary Euclidean estimate that the
straight chord is at most half the Fisher–Rao length of the piece,
$$\|\sqrt{p_t}-\sqrt{p_s}\| \;\le\; \tfrac12 L(p;s,t),$$
which is just "the straight line is shorter than the curve" applied to the
square-root path. Then convert chords to angles. The exact relation on the unit
sphere is
$$\|\sqrt{p}-\sqrt{q}\| \;=\; 2\sin\!\big(\theta(p,q)/2\big),$$
and from it two inequalities: the chord never exceeds the angle,
$\|\sqrt{p}-\sqrt{q}\|\le\theta$; and, in the other direction, if the chord is at
most $m$ then
$$\theta \sqrt{1-(m/2)^2}\;\le\; m .$$
The second is the sharp quantitative converse — a short chord forces a small angle,
with a distortion factor $\sqrt{1-(m/2)^2}$ that tends to $1$ as $m\to 0$. It rests
on the tangent inequality $x\cos x \le \sin x$ on $[0,\pi/2]$. Applying it on each
of the $N$ pieces, summing with the spherical triangle inequality, and letting
$N\to\infty$ so that the distortion factor tends to $1$, yields
$2\theta(p_a,p_b)\le L$. Notably, the Euclidean chord bound alone is *not* enough:
the whole point is the comparison constant tending to $1$.

**From below: fine partitions nearly reach the length.** Here the other inequality
does the work. Since chord $\le$ angle, each term of the angle sum is at least
twice the corresponding chord, so it suffices to show that the chord sums nearly
exhaust the length. On a short interval $[s,t]$ on which the velocity of the
square-root curve varies by at most $e$, test the displacement against the unit
vector $u$ pointing along the initial velocity. The fundamental theorem of calculus
plus Cauchy–Schwarz gives
$$\|\sqrt{p_t}-\sqrt{p_s}\| \;\ge\; \int_s^t \langle u,\dot x_r\rangle\,dr \;\ge\; (\|\dot x_s\| - e)(t-s),$$
while the length of the piece is at most $2(\|\dot x_s\|+e)(t-s)$. Combining,
$$\|\sqrt{p_t}-\sqrt{p_s}\| \;\ge\; \tfrac12 L(p;s,t) - 2e(t-s).$$
Summing over a partition all of whose steps are so short that the velocity varies
by less than $e$ — possible, by uniform continuity on the compact interval $[a,b]$ —
gives
$$L(p;a,b)\;\le\;\Sigma(T) + 4e\,(b-a).$$
Choosing $e$ small makes the error as small as we like. The two squeezes close.

### The shortest path, written down

Calibration has a companion result that makes the picture complete: the geodesic
bound is *attained*. Given two distinct strictly positive probability vectors $p$
and $q$ with angle $\theta = \arccos BC(p,q)$, define, for $t\in[0,1]$,

$$x(t) \;=\; \frac{\sin\big((1-t)\theta\big)\sqrt{p} + \sin(t\theta)\sqrt{q}}{\sin\theta},
\qquad P(t)_i \;=\; x(t)_i^2 .$$

This is the classical spherical interpolation ("slerp") of the two square-rooted
vectors, pushed back down to the simplex. One checks by a two-line trigonometric
identity, $\sin^2 u + 2\sin u \sin w \cos(u+w) + \sin^2 w = \sin^2(u+w)$, that
$\sum_i P(t)_i = 1$ for every $t$, so the path stays in the simplex; it starts at
$p$, ends at $q$, and remains strictly positive. Its Fisher–Rao speed is *constant*,
equal to $2\theta$ — this uses the companion identity
$\cos^2 u - 2\cos u\cos w \cos(u+w) + \cos^2 w = \sin^2(u+w)$ — so its Fisher–Rao
length is exactly $2\theta$.

Combining with the geodesic bound:

> **Fisher–Rao Distance Theorem.** For strictly positive probability vectors $p,q$,
> the infimum of Fisher–Rao lengths over all $C^1$ paths of positive probability
> vectors joining $p$ to $q$ is attained, and equals
> $$2\arccos BC(p,q) \;=\; 2\arccos\sum_i \sqrt{p_i q_i}.$$

The infimum is a minimum, achieved by the great-circle arc. There is a closed-form
shortest path between any two distributions, and a closed-form distance.

### What this buys you

The payoff is that a hard variational quantity becomes an easy algebraic one.

*Computation.* The Fisher–Rao distance between two distributions no longer requires
solving a geodesic equation or evaluating an integral: one dot product of square
roots and one inverse cosine. That is a handful of arithmetic operations, exact and
stable. Likewise, the shortest interpolation between two distributions is available
in closed form — useful anywhere one wants to morph one distribution into another
along the statistically natural path rather than by naive linear blending, which
does not respect the geometry.

*Guarantees.* The convergence theorem says the discrete angle sum of a sampled
trajectory is a *consistent* estimator of the intrinsic length: sample your path
finely enough and the sum of Bhattacharyya angles is as close to the true
Fisher–Rao length as you like. And it always errs on the safe side, since every
partition sum is a lower bound. Anyone tracking the evolution of a distribution —
a posterior in Bayesian updating, an output distribution during training, a
population's allele frequencies over generations — can therefore quantify total
change with a computable, monotone, provably convergent quantity.

*Conceptual clarity.* The three objects that statisticians had been carrying
around separately — the Bhattacharyya coefficient, the Hellinger distance
$\|\sqrt p - \sqrt q\| = 2\sin(\theta/2)$, and the Fisher–Rao length — are now the
inner product, the chord, and the arc of one and the same sphere. The chord/arc
inequalities $2\sin(\theta/2)\le \theta$ and $\theta\sqrt{1-(m/2)^2}\le m$ are
exactly the classical statement that Hellinger and Fisher–Rao distances agree to
first order for nearby distributions, with explicit sharp constants.

### Where the story goes next

Two directions are open and appealing.

The first is the *rate* of convergence. Numerics show the deficit
$L - \Sigma(T)$ for a uniform partition of step $h$ decaying like $h^2$ with a
stable constant. The natural conjecture is that the constant is a curvature
functional: for a $C^3$ path,
$$L - \Sigma \;=\; \frac{h^2}{24}\int_a^b \|\kappa\|^2 s^3\, dt + O(h^3),$$
where $s$ is the Fisher–Rao speed and $\kappa$ the geodesic curvature of the
square-root curve on the sphere. The intuition is exactly right: a chord
underestimates an arc in proportion to how sharply the arc bends, and a geodesic —
zero curvature — has zero deficit, which the exact closed-form arc confirms.

The second is to drop smoothness altogether. For an arbitrary rectifiable path of
probability vectors, one expects the total variation of the path in the
Bhattacharyya angle metric to agree with the Fisher–Rao length whenever the latter
is defined, and to be finite exactly for absolutely continuous paths with
square-integrable Fisher–Rao speed. The least-upper-bound characterisation proved
here is precisely the bridge: it is stated without reference to derivatives, so it
is the right definition to carry into the non-smooth world.

### Coda

There is a certain justice in the fact that the natural geometry of probability is
the geometry of a sphere. The simplex looks flat — it is, after all, a piece of a
plane. But the ruler that statistics forces on it, the one that measures how
distinguishable two distributions are rather than how different their numbers look,
bends it into a sphere of radius $2$. Take a square root, and the whole apparatus of
spherical trigonometry — angles, chords, great circles, the triangle inequality —
descends onto the space of probability distributions. The distance between two
beliefs is an angle. The shortest way from one belief to another is a great-circle
arc. And the total change along any trajectory is, in the limit, nothing more than
the sum of the little angles it turns through.
