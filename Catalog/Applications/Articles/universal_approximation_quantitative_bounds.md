# How a Wall of Light Switches Learns Any Curve

## The promise machines couldn't keep

In the late 1980s, mathematicians proved something that sounded almost too
good to be true: a neural network with a single hidden layer can approximate
*any* continuous function to *any* accuracy. Want a machine that mimics the
shape of a coastline, the swing of a pendulum, or the price of a stock? In
principle, one layer of artificial neurons is enough.

This is the famous **Universal Approximation Theorem**, and for decades it has
been the philosophical license behind the entire field of machine learning. It
says the toolbox is, in principle, complete. But the classical theorem has a
quiet, frustrating flaw: it tells you that a good network *exists* without
telling you *how big* it needs to be, *what its numbers should be*, or *how
close* you actually are. It is a promise without a receipt.

This article is about turning that promise into a receipt. We will build — by
hand, with explicit formulas — a neural network that approximates any
reasonably smooth curve on the interval $[0,1]$, and we will know *exactly* how
good it is and *exactly* how wide it needs to be. No training, no guesswork, no
gradient descent. Just arithmetic and a guarantee.

## The humblest neuron in the world

Modern neural networks are built from a startlingly simple component called the
**ReLU**, short for *Rectified Linear Unit*. Despite the intimidating name, it
is the most modest function imaginable:

$$\sigma(x) = \max(0, x).$$

That is the whole thing. If the input is negative, the output is zero. If the
input is positive, the output is the input, unchanged. Plotted, it looks like a
flat road that suddenly tilts upward at the origin — a hockey stick, a ramp, a
bent wire.

It is hard to believe anything intelligent could be assembled from such a dull
ingredient. And yet, the magic of ReLU is precisely its *bend*. A single ReLU
introduces exactly one kink into an otherwise straight line. Stack enough kinks
in the right places, and you can trace the silhouette of any curve — the way a
folding carpenter's ruler can approximate a smooth arc by snapping into many
short straight segments.

The question is not *whether* this works, but *how precisely* and *how
cheaply*. That is where our story sharpens from folklore into theorem.

## Building a curve out of ramps

Imagine you want to approximate some target curve $f$ on the interval from $0$
to $1$ — say, the gentle rise and fall of $\sin(3x)$. Here is the recipe.

First, **chop the interval into $n$ equal pieces**, called cells, with grid
points at $0, \tfrac{1}{n}, \tfrac{2}{n}, \ldots, 1$. Think of these as the
positions where we are allowed to place a kink.

Second, on each cell we lay down a single **ramp difference**. Take two ReLU
ramps that turn on at neighboring grid points and subtract them:

$$\varphi_k(x) = \sigma\!\left(x - \tfrac{k}{n}\right) - \sigma\!\left(x -
\tfrac{k+1}{n}\right).$$

This little gadget is beautiful. To the left of cell $k$ it is flat at zero. On
cell $k$ it rises as a clean straight line. To the right of the cell it
flattens out again, frozen at the height it reached. It is a localized step — a
ramp that switches on, climbs across exactly one cell, and then holds. Each
ramp difference uses two ReLU neurons, so $n$ cells require $2n$ neurons in
total. That is the **width** of our network.

Third, we choose how steeply each ramp should climb. The natural choice is to
match the average slope of the target across that cell. We call this the
**cell slope**:

$$\text{cellSlope}(f, n, k) = n\left(f\!\left(\tfrac{k+1}{n}\right) -
f\!\left(\tfrac{k}{n}\right)\right).$$

This is just "rise over run" for the target on cell $k$ — the slope of the
straight chord connecting the two endpoints of the cell.

Finally, we stack everything together, starting from the target's value at the
left edge:

$$N(x) = f(0) + \sum_{k=0}^{n-1} \text{cellSlope}(f, n, k)\cdot \varphi_k(x).$$

This single formula *is* a neural network: a weighted sum of $2n$ ReLU units.
And it has a remarkable property.

## The exactness miracle

You might expect a network this simple to be a crude approximation — close, but
always a little off. The first of our main results says something stronger and
more surprising.

**On every cell, the network does not approximate the connect-the-dots curve.
It reproduces it *exactly*.**

In formal terms, for any point $x$ inside cell $k$, the network satisfies

$$N(x) = f\!\left(\tfrac{k}{n}\right) + \text{cellSlope}(f, n, k)\cdot
\left(x - \tfrac{k}{n}\right).$$

The right-hand side is precisely the straight line joining the target's value
at the two ends of the cell. In other words, our $2n$-neuron network is, on the
nose, the **piecewise-linear interpolant** of $f$: the function you would draw
by marking the value of $f$ at each grid point and connecting consecutive dots
with rulers. There is no error in the representation itself — the network and
the connect-the-dots curve are the *same function*.

Why does this happen? It is a telescoping trick. As you move from cell to cell,
each ramp difference contributes its full height of $\tfrac{1}{n}$ once and for
all to every cell after it. When you add the contributions up, the heights
collapse in a cascade: the accumulated rises telescope into exactly the
target's value at the current grid point, and the active ramp on the current
cell supplies the linear climb across it. The bookkeeping is exact, so the
output is exact. This is the lemma we call `reluInterpNet_eq_on_cell`, and it is
the engine of everything that follows.

## The receipt: how close, guaranteed

Reproducing the connect-the-dots curve is only useful if the connect-the-dots
curve is itself close to the original. This is where we need a mild assumption
on the target: that it does not change too fast. A function is called
**$L$-Lipschitz** if it never rises or falls faster than a fixed rate $L$:

$$|f(x) - f(y)| \le L\,|x - y| \quad \text{for all } x, y.$$

The constant $L$ is a speed limit on the curve's steepness. Most functions you
meet in practice — smooth signals, bounded-derivative models, physical
trajectories — satisfy this with some finite $L$.

Our second main result, the lemma `interp_error_le`, delivers the receipt: for
any $L$-Lipschitz target $f$ and any point $x$ in $[0,1]$,

$$\bigl|f(x) - N(x)\bigr| \le \frac{L}{n}.$$

Read that carefully, because it is the whole point. The error is **uniformly**
bounded — not just on average, not just at the grid points, but everywhere on
the interval. And it shrinks like $\tfrac{1}{n}$: double the number of cells,
halve the worst-case error. Want the network within one one-thousandth of the
target? Choose $n$ to be a thousand times the Lipschitz constant, wire up $2n$
ReLU neurons with the explicit cell slopes, and you are *provably* there.

The intuition is geometric. Inside a cell, both the true curve and the straight
chord are pinned to the same two endpoints. A speed-limited curve cannot stray
far from its own chord over a short span; the shorter the cell, the tighter the
leash. Since each cell has width $\tfrac{1}{n}$, the curve can wander at most a
distance proportional to $\tfrac{L}{n}$ away from the line our network draws.
Shrink the cells, and the gap vanishes at a guaranteed rate.

It is worth noting that this bound is honest but generous. A finer analysis
shows the true worst-case error is at most $\tfrac{L}{2n}$, attained at the
midpoint of a cell, and for curves with bounded curvature it drops all the way
to $\tfrac{M}{8n^2}$ where $M$ bounds the second derivative. The numerical
experiments accompanying this work confirm the curve hugs the target far more
tightly than the conservative guarantee demands — but the value of the theorem
is that the guarantee holds *no matter what*.

## From "exists" to "here it is"

Step back and notice what has changed. The classical universal approximation
theorem says: *for any target and any tolerance, a network exists.* Our version
says something operationally far stronger:

> Given any $L$-Lipschitz target $f$ and any tolerance $\varepsilon > 0$,
> choose $n \ge L/\varepsilon$. Then the explicit width-$2n$ ReLU network with
> coefficients $\text{cellSlope}(f, n, k)$, read directly off the values of $f$
> at the grid points, approximates $f$ uniformly within $\varepsilon$.

There is no training loop. There is no random initialization, no learning rate,
no hoping the optimizer converges. The network's weights are a closed-form
function of a handful of samples of the target. The width is known in advance.
The error is certified. The promise has become a receipt — a constructive,
checkable, end-to-end guarantee that turns a famous existence statement into an
algorithm you could run on a napkin.

This constructive flavor has a practical edge. In many real pipelines, a
function is known only through a table of measured values at grid points — a
lookup table for a sensor, a tabulated material property, a sampled control
law. Our recipe converts such a table, plus a single number bounding the
target's steepness, directly into a neural network *with a guaranteed error
bar*. It is a compiler from data-plus-regularity into a certified
approximation, no optimization required.

## Why depth is the next frontier

If one hidden layer already does everything, why does the modern world obsess
over *deep* networks with dozens or hundreds of layers? Because "can do
everything" and "can do everything *efficiently*" are very different claims.

Our shallow network pays for accuracy with width: to resolve $n$ wiggles you
need $2n$ neurons, all in a single layer. But there is a different currency —
**depth** — that can be dramatically cheaper for certain shapes. The classic
example is the *sawtooth*. A single ReLU triangle wave, composed with itself,
doubles its number of teeth each time. Compose it $d$ times and you obtain a
sawtooth with $2^d$ teeth using only about $d$ layers of constant width. To
draw that same jagged sawtooth with $2^d$ teeth using a *shallow* network, you
would need on the order of $2^d$ neurons — an exponential blow-up.

This is the heart of the **depth–width tradeoff**: a thin, deep network can
express functions whose linear-piece count grows exponentially with depth,
while a shallow network must grow exponentially in width to keep pace. Depth is
a compression scheme for complexity. The shallow, certified construction in
this work is the rigorous foundation on which such depth-separation results are
built; extending the same machine-checked guarantees to compositional, deep
sawtooth networks is the natural and exciting next chapter.

There are other frontiers, too. The one-dimensional ramp here is the $d=1$ case
of a richer family of "tent" functions that tile higher-dimensional cubes, so
the same exactness-plus-error strategy lifts to approximating surfaces and
volumes — at the cost of a width that grows with the number of cells in the
grid. And the conservative $\tfrac{L}{n}$ bound can be sharpened to the optimal
$\tfrac{L}{2n}$ for Lipschitz targets and $\tfrac{M}{8n^2}$ for curved ones,
squeezing the most accuracy out of every neuron.

## The bigger picture

What makes this story satisfying is not just that it works, but that *every
claim is pinned down*. The construction is explicit: you can write out the
weights. The reproduction is exact: the network *is* the interpolant, not
merely close to it. The error is quantitative: a clean $\tfrac{L}{n}$ bound,
honest everywhere on the interval. And the whole chain — from the humble
$\max(0,x)$ neuron, through the telescoping ramps, to the certified
approximation — fits together with the tight inevitability of good mathematics.

Neural networks are often described as inscrutable black boxes, and in their
trained, billion-parameter form they largely are. But underneath the mystery
lies a skeleton of startling clarity: a wall of simple light switches, each
flipping a single line into a bend, collectively tracing any curve you like to
a precision you can name in advance. The universal approximation theorem told
us the wall *could* learn any curve. Here, we have shown it exactly how — and
handed it the receipt.
