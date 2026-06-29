# How Many Neurons Does It Take to Draw a Curve?

## The promise, and the missing receipt

There is a famous reassurance at the heart of modern machine learning: a neural
network can approximate *any* reasonable function. Feed it enough neurons, and it
can learn to imitate the price of a stock, the shape of a coastline, the way a
photograph should be brightened. This is the **universal approximation theorem**,
and it has been quoted in a thousand lecture halls as a kind of permission slip:
go ahead, the network can represent whatever you need.

But there is a catch that the classic statement quietly skips. "Enough neurons"
is not a number. The original theorem says a good approximation *exists* somewhere
out in the infinite space of networks; it does not tell you how big the network
must be, or how the error shrinks as you make it bigger. It is like being told
that a staircase reaching the moon *exists* without being told how many steps it
has. For an engineer deciding whether to use a hundred neurons or a hundred
million, the abstract promise is almost useless.

This article is about turning that promise into a receipt — an explicit,
no-loopholes accounting of exactly how accuracy trades against size. We will
build a particular, transparent network out of the simplest possible parts, and
we will be able to say, with the certainty of arithmetic, things like: *use
$2n$ neurons and your error is at most $L/n$.* And then we will discover
something more surprising: how *fast* that error shrinks depends not on a clever
architecture, but on how *smooth* the target curve is.

## The humblest building block: the ramp

Everything here is built from one absurdly simple function, the **rectified
linear unit**, or ReLU:
$$\mathrm{relu}(x) = \max(x, 0).$$
Plotted, it is a flat line along the negative axis that suddenly kinks upward at
zero and rises at a perfect 45-degree angle. It is a hinge. A ramp. A function so
plain it seems incapable of sophistication. Yet ReLU is the workhorse of nearly
every deep network in use today, precisely because hinges, when you stack enough
of them, can bend into any shape.

The trick is to combine two hinges. Take the difference of two ramps offset from
each other:
$$\mathrm{relu}(x - a) - \mathrm{relu}(x - b), \qquad a \le b.$$
What does this make? To the **left** of $a$, both ramps are flat, so the
difference is zero. **Between** $a$ and $b$, the first ramp is rising while the
second is still flat, so the difference climbs with slope one — it equals exactly
$x - a$. To the **right** of $b$, both ramps are rising at the same rate, so
their difference levels off to the constant width $b - a$. The result is a single
clean *step that ramps up over one interval and then holds steady*. These three
facts — flat, then a unit slope, then a plateau — are the load-bearing wall of
everything that follows, and each can be checked by hand in a line.

## Drawing a curve with ramps

Now suppose we want to mimic some target function $f$ on the interval $[0,1]$.
Here is the plan, and it is the plan a child uses with a ruler. Chop $[0,1]$ into
$n$ equal pieces, with division points at
$$\mathrm{grid}(n,k) = \frac{k}{n}, \qquad k = 0, 1, \dots, n.$$
On each little piece, don't try to reproduce $f$'s wiggles — just draw the
straight line connecting $f$'s value at the left end to its value at the right
end. String these segments together and you get a connect-the-dots version of
$f$: a *piecewise-linear interpolant*. It is jagged where $f$ curves, but it
hugs the true curve at every grid point and never strays far in between.

The beautiful part is that this connect-the-dots picture is *exactly* a ReLU
network. For each cell we take one ramp-difference, scaled by the steepness of
$f$ across that cell. We measure that steepness with
$$\mathrm{cellSlope}(f,n,k) = n\bigl(f(\tfrac{k+1}{n}) - f(\tfrac{k}{n})\bigr),$$
the rise over the run on cell $k$. Adding up all the scaled ramps, and starting
from the height $f(0)$, gives our network:
$$\mathrm{reluInterpNet}(f,n,x) = f(0) + \sum_{k=0}^{n-1} \mathrm{cellSlope}(f,n,k)\,\bigl(\mathrm{relu}(x - \tfrac{k}{n}) - \mathrm{relu}(x - \tfrac{k+1}{n})\bigr).$$
Each cell contributes two ramps, so the whole thing uses $2n$ neurons. That is
the entire architecture: one hidden layer, $2n$ hinges, no hidden cleverness.

Why does this sum reproduce the connect-the-dots curve and not some tangle? Pick
any point $x$ and ask which cell it sits in, say cell number $k$. The ramps for
earlier cells (indices below $k$) have already saturated to their plateaus, and
because of the way ramps telescope, those plateaus add up neatly to exactly
$f(k/n) - f(0)$ — they reconstruct the curve's height up to the start of our
cell. The ramps for *later* cells haven't switched on yet, so they contribute
nothing. And the ramp for our own cell is in its rising phase, contributing the
straight-line piece. The grand total is
$$\mathrm{reluInterpNet}(f,n,x) = f\!\left(\tfrac{k}{n}\right) + \mathrm{cellSlope}(f,n,k)\cdot\left(x - \tfrac{k}{n}\right),$$
which is precisely the straight segment over that cell. The network *is* the
ruler-and-pencil interpolant, exactly, with no approximation hidden inside the
identity itself. This exact correspondence is the conceptual keystone of the
whole story.

## The first receipt: error $L/n$

Now we can finally count. How wrong can the connect-the-dots curve be?

Suppose $f$ doesn't change too violently — concretely, suppose it is
**$L$-Lipschitz**, meaning that between any two points its value can't jump faster
than a rate $L$:
$$|f(x) - f(y)| \le L\,|x - y|.$$
The number $L$ is a speed limit on the curve. A gentle, slowly varying signal has
a small $L$; a jittery one has a large $L$.

On any single cell of width $1/n$, our network's value is a blend of the two
endpoint heights of $f$. Every point in the cell is within $1/n$ of each
endpoint, and the speed limit $L$ says $f$ can't have drifted by more than
$L \cdot \tfrac{1}{n}$ over that distance. So the straight segment can be off from
the true curve by at most $L/n$. Since this holds on every cell, it holds
everywhere on $[0,1]$. That is the headline result, clean as a bell:
$$\bigl|\mathrm{reluInterpNet}(f,n,x) - f(x)\bigr| \le \frac{L}{n} \qquad \text{for all } x \in [0,1].$$
This is a genuine receipt. Want the error below some tolerance $\varepsilon$?
Just make $n$ large enough that $L \le \varepsilon\, n$, which is to say
$n \ge L/\varepsilon$. The network then uses $2n = O(1/\varepsilon)$ neurons and
is guaranteed — not "probably," but provably — to stay within $\varepsilon$ of
the target across the whole interval. The vague universal promise has become a
purchase order: tell me your accuracy, I'll tell you the neuron count.

## The twist: smoothness buys you a discount

Here is where the story turns from satisfying to surprising. We never changed the
network. It is still the same $2n$ ramps. But suppose the target function is not
merely continuous but *smooth* — suppose its **slope** itself varies gently. Make
that precise by asking the derivative $f'$ to be $M$-Lipschitz: the curve's
steepness can't change faster than rate $M$. (This is the class engineers call
$W^{2,\infty}$: functions whose second derivative, where it exists, is bounded by
$M$. A parabola qualifies; so does any curve without sudden kinks in its bending.)

For such a function, the *very same network* does dramatically better:
$$\bigl|\mathrm{reluInterpNet}(f,n,x) - f(x)\bigr| \le \frac{M}{n^2} \qquad \text{for all } x \in [0,1].$$
Look at the exponent. The Lipschitz world gave us error $\propto 1/n$. The smooth
world gives $\propto 1/n^2$. Double the neurons and a merely-continuous
approximation gets twice as good; a smooth approximation gets *four times* as
good. The improvement compounds.

The reason is a small gem of calculus. On a cell, the network is the straight
chord of $f$. The error between a chord and a curve depends on how much the curve
bends away from straightness — and bending is exactly what a controlled second
derivative limits. More carefully: the mean value theorem says the chord's slope
equals $f'(c)$ at some interior point $c$. So the error's own derivative is
$f'(x) - f'(c)$, and since $f'$ obeys the speed limit $M$, this is at most
$M$ times the cell width $h = 1/n$. An error that starts at zero (the chord
meets the curve at the left endpoint) and grows at a rate no bigger than $M h$
across a span $h$ can reach at most $M h^2 = M/n^2$. The single power of $h$ from
the Lipschitz argument has become two powers from the smoothness argument.

The practical payoff is steep. To hit accuracy $\varepsilon$ now requires only
$n \ge \sqrt{M/\varepsilon}$, so the network needs about
$2n = O(1/\sqrt{\varepsilon})$ neurons — the square root of the Lipschitz
requirement. For a target accuracy of one part in ten thousand, the rough regime
might demand tens of thousands of neurons while the smooth regime asks for
hundreds. Same hinges, same wiring; the savings come entirely from the target's
good manners.

## The real lesson: smoothness, not architecture

It is tempting to believe that better approximation always demands a cleverer
network — more layers, exotic activations, attention mechanisms. The two receipts
above tell a quieter, more fundamental story. We fixed the architecture
completely: one hidden layer, $2n$ plain ReLU hinges, arranged as connect-the-dots.
With that frozen, the rate at which error vanishes — the *exponent* on $1/n$ — was
governed not by the machine but by the curve it was chasing. A rough curve
yields $1/n$. A smooth one yields $1/n^2$. The smoothness class of the target is
the dial that sets the convergence speed.

This reframes the universal approximation theorem in a way that is both humbler
and more useful. The classic version says approximation is *possible*. The
quantitative version says approximation is *predictable*: given how smooth your
data is, you can read off, in advance, how many neurons buy how much accuracy.
That is the difference between a promise and a contract.

## Where this points

The same ideas reach further than the two receipts we proved. If a function is
smoother still — if not just its slope but its curvature varies gently — one
expects even faster rates, but a single shallow layer of hinges hits a ceiling:
a one-layer ReLU network is globally a connect-the-dots curve, and connect-the-dots
can only capture so much bending. Climbing past the $1/n^2$ rate provably requires
*depth* — extra layers that compose the squaring map and let the network bootstrap
straight pieces into genuine curves. There the architecture finally does matter,
and the trade between width and depth becomes the next chapter.

One can also chase the sharpest possible constant. Our smooth bound reads $M/n^2$,
but the textbook interpolation estimate suggests the true worst case is eight
times smaller, $M/(8n^2)$, achieved by the parabola at the midpoints of cells.
Closing that factor of eight is a single, satisfying optimization left for the
sequel.

And one can ask what universal quantity *really* measures how hard a function is
to draw with hinges. A strong candidate is **total variation** — the total
up-and-down travel of the curve — which appears to be both the floor and the
ceiling on what a shallow network can express, and the precise currency in which
the advantage of depth is paid.

But the heart of the matter is already in hand. A network of $2n$ humble hinges,
connecting the dots of a target on $[0,1]$, approximates any $L$-Lipschitz curve
to within $L/n$, and any smoothly-bending curve to within $M/n^2$ — exact,
explicit, and proven. The staircase to the moon, it turns out, has a knowable
number of steps. And how quickly it climbs depends not on how it is built, but on
how gently the ground beneath it rises.
