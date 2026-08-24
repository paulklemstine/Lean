# All the Space Is in the Skin: Peeling High-Dimensional Oranges

## A children's question with a strange answer

Take an orange and peel it so that the peel weighs exactly as much as the fruit
inside. How thick should the peel be? For a spherical orange of radius $R$ in
our ordinary three-dimensional world, the answer is a healthy bite: the inner
sphere must have radius $R/2^{1/3} \approx 0.7937\,R$, so the peel is about
$20.6\%$ of the radius. Nobody would call that a thin skin.

Now do the same thing in a hundred dimensions. The peel that carries half the
volume of a $100$-dimensional ball of radius $R$ has thickness

$$R\left(1 - 2^{-1/100}\right) \approx 0.006908\,R,$$

less than seven thousandths of the radius. Half of the ball's volume lives in a
sliver so thin that, drawn to scale, you could not see it. This is the famous
statement that *in high dimension, all the volume of a ball is near its
boundary*, and it is the reason so many algorithms that work beautifully in the
plane fall apart in a thousand dimensions.

The statement is usually left at that: a slogan, plus the one-line computation
above. This article is about turning the slogan into a complete, quantitative
theory. What exactly is the thickness of that peel? How does it behave as the
dimension grows? What is the best possible constant in the estimate? And what
happens if you peel not once but repeatedly, slicing the ball into $N$ shells of
identical volume — what shape does the resulting family of shells converge to?

The answers are unexpectedly clean, and they converge on a single number that
has nothing to do with geometry: the **logarithm**.

## Setting up the peeling

Fix a dimension $d \ge 1$, a radius $R > 0$, and an integer $N \ge 2$. We want
to cut the ball $B(0,R) \subseteq \mathbb{R}^d$ into $N$ nested shells, each of
volume exactly $\frac{1}{N}$ of the whole. Because the volume of a ball of
radius $r$ in $\mathbb{R}^d$ is proportional to $r^d$, this is a one-line
computation. The $k$-th cutting sphere — the one that leaves exactly $k$ of the
$N$ equal portions outside it — must have radius

$$r_k \;=\; R\left(1 - \frac{k}{N}\right)^{1/d}, \qquad k = 0, 1, \dots, N-1.$$

So the whole configuration is described by a single formula. The **depth** of
the $k$-th sphere is how far it lies below the surface,

$$\delta_k \;=\; R - r_k \;=\; R\left(1 - \left(1 - \tfrac{k}{N}\right)^{1/d}\right),$$

and the **thickness of the outermost shell** is the case $k = 1$:

$$\delta_1 \;=\; R\left(1 - \left(1 - \tfrac{1}{N}\right)^{1/d}\right).$$

Everything below is a statement about this one expression, and about the profile
$k \mapsto \delta_k$ that it belongs to.

## First estimate: the peel is thin, of order $1/d$

Here is the elementary starting point. Write $s = (1-1/N)^{1/d}$, so that
$s^d = 1 - 1/N$. The factorisation

$$1 - s^d = (1-s)\left(1 + s + s^2 + \cdots + s^{d-1}\right)$$

is the whole engine. The geometric sum in brackets has $d$ terms, each of them
between $s^{d-1}$ and $1$ when $0 \le s \le 1$. Bounding it above by $d$ gives
$1 - s^d \le d(1-s)$; bounding it below by $d\,s^{d-1}$ gives the reverse
inequality with a correction. Translating both back into geometry yields the
following sandwich.

> **Theorem (Two-sided thickness bound).** For $d \ge 1$, $N \ge 2$, $R \ge 0$,
> the outermost equal-volume shell of $B(0,R) \subseteq \mathbb{R}^d$ has
> thickness
> $$\frac{R}{dN} \;\le\; R - r_1 \;\le\; \frac{R}{d(N-1)}.$$

Both ends are of order $R/d$: the peel is $d$ times thinner in dimension $d$
than the naive one-dimensional intuition suggests, and the window between the
two bounds is narrow — the ratio of the upper to the lower bound is $N/(N-1)$,
which is $2$ at $N=2$ and only $1.01$ at $N=100$.

Both ends are also *attained*, but in opposite regimes. In dimension one the
peeling is just chopping an interval into equal pieces, and the outer piece has
length exactly $R/N$ — the lower bound, on the nose. So no constant can be
shaved off the lower bound. And, as we shall see in a moment, the upper bound is
the correct order of magnitude but not the correct constant.

## The hidden monotonicity

The observation that the two endpoints of the interval $[R/(dN),\,R/(d(N-1))]$
are attained at the two extremes of the dimension range — $d = 1$ at the bottom,
$d \to \infty$ at the top — is a strong hint. It suggests that the *rescaled*
thickness

$$T(d) \;=\; d \cdot (R - r_1) \;=\; R\,d\left(1 - t^{1/d}\right), \qquad t = 1 - \tfrac{1}{N},$$

is not merely trapped in an interval but climbs steadily across it as the
dimension grows. That is exactly what happens.

> **Theorem (Monotonicity in the dimension).** For $0 < t \le 1$ the sequence
> $$d \;\longmapsto\; d\left(1 - t^{1/d}\right)$$
> is monotone increasing in $d$. Consequently, for any $N \ge 2$ and $R \ge 0$,
> the rescaled outer-shell thickness $d \cdot (R - r_1)$ increases with the
> dimension.

This is one of those statements that looks like it should need calculus —
differentiate in $d$, stare at the sign of the derivative — but in fact reduces
to a fact about averages of a decreasing sequence, which one can prove by
counting.

Here is the trick. Take integers $a \le b$ and a number $y \in [0,1]$. The
sequence $1, y, y^2, \dots$ is decreasing, so its running average is decreasing
too:

$$\frac{1}{b}\sum_{i<b} y^i \;\le\; \frac{1}{a}\sum_{i<a} y^i.$$

(To see this without any machinery: the first $a$ terms of the longer sum are
each at least $y^a$, while the remaining $b-a$ terms are each at most $y^a$, so
adding the tail can only drag the average down.) Multiply both sides by
$ab(1-y) \ge 0$ and use $(1-y)\sum_{i<n} y^i = 1 - y^n$ to get the beautifully
symmetric inequality

$$a\left(1 - y^b\right) \;\le\; b\left(1 - y^a\right).$$

Now comes the substitution that converts arithmetic into analysis. Put
$y = t^{1/(ab)}$. Then $y^b = t^{1/a}$ and $y^a = t^{1/b}$, and the displayed
inequality reads

$$a\left(1 - t^{1/a}\right) \;\le\; b\left(1 - t^{1/b}\right),$$

which is exactly the monotonicity we wanted. A statement about fractional powers
in a continuous variable has been reduced to a statement about geometric sums of
integer length, and the bridge is the single choice $y = t^{1/(ab)}$.

## The optimal constant is a logarithm

Monotone and bounded means convergent, and the limit is easy to identify. Since
$t^{1/d} = e^{(\log t)/d}$ and $e^u \approx 1 + u$ for small $u$,

$$d\left(1 - t^{1/d}\right) \;\longrightarrow\; -\log t \qquad (d \to \infty).$$

Making this rigorous needs nothing more than the inequality $1 + u \le e^u$,
applied at $u = (\log t)/d$ for the upper bound and at $u = -(\log t)/d$ for the
lower one. With $t = 1 - 1/N$, so $-\log t = \log\frac{N}{N-1}$, this gives the
scale of the phenomenon:

> **Theorem (Asymptotics of the outer shell).** For $N \ge 2$,
> $$d \cdot \left(R - r_1\right) \;\xrightarrow[d\to\infty]{}\; R\,\Lambda,
> \qquad \Lambda := \log\frac{N}{N-1}.$$

Because the sequence *increases* to its limit, the limit is its supremum, and we
get an inequality valid in every single dimension, not just asymptotically:

> **Theorem (Optimal concentration bound).** For all $d \ge 1$, $N \ge 2$,
> $R \ge 0$,
> $$R - r_1 \;\le\; \frac{R\,\Lambda}{d}, \qquad \Lambda = \log\frac{N}{N-1},$$
> and the constant $\Lambda$ cannot be improved: for $R > 0$ the bound
> $R - r_1 \le Rc/d$ holds for every dimension $d$ **if and only if**
> $c \ge \Lambda$.

That "if and only if" is what makes the result final. Any uniform-in-dimension
bound of the shape $Rc/d$ must have $c \ge \log\frac{N}{N-1}$, and $c = \Lambda$
works. There is nothing left to optimise.

It is worth pausing on how much this improves the elementary bound. Since
$\log x < x - 1$ for every $x \ne 1$, applied at $x = \frac{N}{N-1}$ we get

$$\Lambda = \log\frac{N}{N-1} \;<\; \frac{1}{N-1},$$

so the new bound $R\Lambda/d$ is *strictly* smaller than the elementary
$R/(d(N-1))$ — in every dimension, for every $N$, for every positive radius. For
$N = 2$: $\log 2 = 0.693147$ against $1$, an improvement of over $30\%$. For
$N = 10$: $\log(10/9) = 0.105361$ against $1/9 = 0.111111$. And these are not
merely smaller numbers, they are the *smallest possible* numbers.

## How fast? An explicit rate

A limit without a rate is a promise without a deadline. The same exponential
inequality $1+u \le e^u$, used twice, pins down the speed of convergence.

> **Theorem (Rate of convergence).** For $d \ge 1$, $N \ge 2$, $R \ge 0$, with
> $\Lambda = \log\frac{N}{N-1}$,
> $$0 \;\le\; R\Lambda - d\,(R - r_1) \;\le\; \frac{R\,\Lambda^2}{d + \Lambda}.$$

So the true thickness is $\frac{R\Lambda}{d}\bigl(1 + O(1/d)\bigr)$, with the
error constant written out. Numerically, at $R = 1$, $N = 2$: the bound gives a
gap of at most $0.04496$ at $d = 10$ against a true gap of $0.023477$, and at
most $0.004774$ at $d = 100$ against a true gap of $0.002397$. The bound is
within a factor of two of the truth (the true leading behaviour is
$\Lambda^2/(2d)$) and has exactly the right order.

## The shape of the whole decomposition

So far we have looked only at the outermost shell. What about the whole family
of $N$ shells? Something rather lovely happens: the profile of the decomposition
is *exactly* exponential — not in a limit, not approximately, but identically,
once you look at it in the right variable.

Define, for each cutting sphere $k < N$, the **rescaled depth parameter**

$$\tau_k \;=\; \frac{-\log\left(1 - \frac{k}{N}\right)}{d}.$$

Then, with no approximation at all,

> **Theorem (Exact exponential profile).** For every $d \ge 1$ and every
> $k < N$,
> $$R - r_k \;=\; R\left(1 - e^{-\tau_k}\right).$$

The factor $1/d$ inside $\tau_k$ is the entire content of the concentration
phenomenon: it says that the natural depth coordinate in dimension $d$ is $d$
times finer than the radius. Strip the $1/d$ away — that is, look at $d$ times
the depth — and the decomposition converges to a fixed curve independent of the
dimension:

> **Theorem (Limit profile).** For every $k < N$,
> $$d \cdot \left(R - r_k\right) \;\xrightarrow[d\to\infty]{}\; R\,\log\frac{N}{N-k},$$
> and this limit profile is the exact inverse of the exponential: the sphere at
> limiting rescaled depth $\tau = \log\frac{N}{N-k}$ carries volume fraction
> $$1 - e^{-\tau} = \frac{k}{N}.$$

Read from the other side, the same statement is about volumes rather than
radii. Peel off a boundary layer of thickness $Ru/d$ from the ball of radius
$R$; what fraction of the volume remains? Exactly $(1 - u/d)^d$ — and that is
one of the oldest limits in mathematics:

> **Theorem (Exponential volume profile).** For $R > 0$ and any $u$,
> $$\frac{\operatorname{vol} B\bigl(0, R(1-u/d)\bigr)}{\operatorname{vol} B(0,R)}
> = \left(1 - \frac{u}{d}\right)^d \;\xrightarrow[d\to\infty]{}\; e^{-u},$$
> so the removed fraction tends to $1 - e^{-u}$.

This is why the logarithm appears: the exponential profile $R(1-e^{-\tau})$ is
the universal shape of a high-dimensional ball as seen from its boundary, and
the equal-volume shells are just the level sets of that profile at heights
$1/N, 2/N, \dots$. The depths $\log\frac{N}{N-k}$ are where those level sets
sit.

## The dichotomy: skins and a core

Put the pieces together and the geometry of a high-dimensional equal-volume
peeling becomes almost cartoonish.

The outermost shell has thickness $\to 0$: it collapses onto the boundary
sphere. So does the second, the third, and every fixed shell $k$, since its
depth $R(1 - (1-k/N)^{1/d})$ also tends to zero. But the innermost shell — the
ball $B(0, r_{N-1})$ with $r_{N-1} = R\,N^{-1/d}$ — has $r_{N-1} \to R$, so *it*
swells to fill the whole ball.

> **Theorem (Concentration dichotomy).** For $N \ge 2$, as $d \to \infty$,
> $$R - r_1 \to 0 \qquad\text{and}\qquad r_{N-1} \to R.$$

Every one of the $N$ pieces has exactly the same volume, $\frac{1}{N}$ of the
total. Yet in the limit, $N-1$ of them are infinitesimally thin skins pressed
against the surface, and one of them is the entire ball. That is high-dimensional
volume in a sentence. At $N = 2$, $d = 100$: the outer half of the volume sits
in a shell of thickness $0.0069\,R$, while the inner half is a ball of radius
$0.993\,R$.

## A gift back to analysis

One last twist, and it runs in the unexpected direction: from geometry to
analysis. We proved, for *every* dimension $d$, the sandwich

$$\frac{R}{dN} \;\le\; R - r_1 \;\le\; \frac{R}{d(N-1)},$$

and separately that $d(R - r_1) \to R\log\frac{N}{N-1}$. Multiplying the
sandwich by $d/R$ and letting $d \to \infty$, the limit must lie in the same
interval, and we have proved a purely analytic inequality by geometric means:

> **Corollary.** For every integer $N \ge 2$,
> $$\frac{1}{N} \;\le\; \log\frac{N}{N-1} \;\le\; \frac{1}{N-1}.$$

This is the classical bound $\frac{x}{1+x} \le \log(1+x) \le x$ at
$x = \frac{1}{N-1}$, the estimate that makes the harmonic series diverge like
$\log n$. Here it falls out of peeling a ball. The chain of reasoning is worth
savouring: an inequality about geometric sums proves a monotonicity of shell
thicknesses, which proves an optimal constant, which is a logarithm, whose
classical bounds are recovered from the geometry that produced it.

## Why it matters beyond the orange

The thin-peel phenomenon is not a curiosity; it is the shape of the difficulty
in high-dimensional computation.

**Sampling and rejection.** Generating a uniform point in a ball by sampling in
the enclosing cube fails in high dimension because the ball occupies a vanishing
fraction of the cube. The results here quantify the companion problem: even
*inside* the ball, if you want a point at relative depth more than $u/d$ below
the surface, you are asking for an event of probability $e^{-u}$ approximately.
The natural coordinate is $d \times$ (depth), and in that coordinate the answer
is a standard exponential distribution.

**Nearest neighbours and the curse of dimensionality.** If points are drawn
uniformly from a ball, almost all of them lie in a boundary layer of thickness
$O(R/d)$, so almost all pairwise distances concentrate. The exponential profile
$1 - e^{-u}$ is the precise law of the rescaled depth, and the rate
$\Lambda^2/(d+\Lambda)$ says how quickly that law is reached.

**Numerical integration and quadrature design.** A scheme that stratifies a ball
into equal-volume shells and places nodes shell-by-shell must know how thin the
outer strata are. The bound $R\Lambda/d$ with $\Lambda = \log\frac{N}{N-1}$ is
the sharp answer, and unlike the elementary $R/(d(N-1))$ it cannot be beaten.

**Isotropic models in physics and statistics.** Whenever a uniform distribution
on a high-dimensional ball is used as a null model — random directions, random
unit vectors, isotropic priors — the dichotomy above is the reason such a model
behaves like a distribution on a sphere plus an exponential radial coordinate.

## The moral

Behind the slogan "all the volume is near the boundary" there is a complete and
exact story. The peeling of a $d$-dimensional ball into $N$ equal-volume shells
is described by a single formula $r_k = R(1-k/N)^{1/d}$, whose depths form an
exponential profile *identically*, not asymptotically. Rescaled by the
dimension, the thickness of the outer shell increases monotonically — a fact
that follows from nothing more than the observation that the running averages of
a decreasing geometric sequence decrease — and converges to $R\log\frac{N}{N-1}$
from below, at rate $\Theta(1/d)$ with an explicit constant. That logarithm is
the last word on the problem: it is the optimal constant in the
uniform-in-dimension bound, it strictly improves the naive estimate, and its own
classical bounds $\frac{1}{N} \le \log\frac{N}{N-1} \le \frac{1}{N-1}$ can be
read straight off the geometry.

The orange, in a hundred dimensions, is all peel. And the thickness of that
peel, measured correctly, is a logarithm.
