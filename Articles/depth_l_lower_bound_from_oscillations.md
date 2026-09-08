# The Folding Machine: Why Deep Networks Can Do What Shallow Ones Cannot

## A sheet of paper, folded

Take a strip of paper one unit long and fold it in half. Now imagine the fold as a *function*. Before folding, the point at position $y$ was simply at position $y$. After folding, the left half stretches to fill the whole strip and the right half stretches back again: the point $y$ lands at $2y$ if $y \le 1/2$, and at $2-2y$ if $y \ge 1/2$. Mathematicians call this the *tent map*, or the sawtooth:

$$\tau(y) = \begin{cases} 2y, & 0 \le y \le \tfrac12,\\ 2-2y, & \tfrac12 \le y \le 1.\end{cases}$$

Its graph is a single triangular tooth of height $1$ over the interval $[0,1]$.

Now fold again — that is, apply $\tau$ to its own output. The composite $\tau(\tau(y))$ has *two* teeth. Fold a third time and you get four teeth. After $k$ folds, the function $\tau^{\circ k}$ — $\tau$ applied $k$ times — is a zig-zag with $2^{k-1}$ teeth, rising and falling with slope $\pm 2^k$, hitting $0$ and $1$ alternately at the $2^k+1$ evenly spaced points $0, 1/2^k, 2/2^k, \dots, 1$.

This is exponential growth achieved by repetition. Each fold doubles the complexity of the picture, and $k$ folds cost you only $k$ operations. It is the same trick as repeated squaring, or the same trick your intestine uses to pack many square metres of surface into a small volume. And it is, as we shall see, exactly the trick that makes *deep* neural networks more expressive than *shallow* ones — up to a point, and that point turns out to be surprisingly subtle.

## Machines that are made of folds

A modern neural network with the *rectified linear unit* activation is, mathematically, nothing more exotic than a machine for building piecewise linear functions. The rectifier is
$$\mathrm{relu}(t) = \max(t,0),$$
a function that is flat to the left of the origin and rises with slope $1$ to the right. A *layer* of such a network takes the numbers produced by the previous layer, forms a handful of weighted sums of them, and passes each sum through the rectifier. The *width* $w$ is how many rectifiers you are allowed in a layer; the *depth* $L$ is how many layers you stack. The output is a final weighted sum, with no rectifier.

Everything such a machine can compute is continuous and piecewise linear: the plane is cut into intervals, and on each interval the output is a straight line. The interesting question — the one that has driven a decade of theory about why depth matters — is how many *pieces* a machine of depth $L$ and width $w$ can produce.

The sawtooth is the perfect test case, because it is cheap to build with depth. One rectifier layer of width $3$ realises a single fold exactly:
$$\tau(y) = 2\,\mathrm{relu}(y) - 4\,\mathrm{relu}\!\left(y-\tfrac12\right) + 2\,\mathrm{relu}(y-1).$$
(Check the slopes: $2$, then $2-4=-2$, then $-2+2=0$.) Stack $k$ such layers and you get $\tau^{\circ k}$ exactly, using $3k$ rectifiers in total — a machine whose size grows *linearly* in $k$ while the number of teeth in its output grows like $2^k$.

The question is what happens if you are forced to be shallow. Suppose someone hands you a budget of only $L$ layers and asks you to reproduce $\tau^{\circ k}$ — or even just to stay within a modest error of it. How wide must your layers be?

## Counting the corners

The answer comes from a bookkeeping exercise so simple it feels like cheating: **count the corners**.

Call a point a *knot* of a piecewise linear function if the function's slope may change there. A function with knot set $S$ is straight on every subinterval of $[0,1]$ that avoids $S$. Two facts drive everything.

**Weighted sums are free.** If several functions all have their corners inside the same set $S$, then any weighted sum of them (plus a constant) still has all its corners inside $S$. Adding straight lines to straight lines gives straight lines.

**Rectifying is cheap.** If $f$ is straight on each of the intervals cut out by $S$, then $\mathrm{relu}(f)$ can acquire at most one new corner per interval — namely the single point where that straight piece crosses zero. An affine function crosses zero at most once, so each existing piece contributes at most one new kink.

Put these together and you can follow the corner count layer by layer. Write $K_L$ for the maximum number of corners any unit in layer $L$ can have. The first fact says the weighted sums entering layer $L+1$ still have at most $K_L$ corners; the second says rectifying each of them yields at most about $2K_L$ corners; and there are at most $w$ of them, so
$$K_{L+1} \le w\,(2K_L + 4).$$
Unwinding this recursion, a network of depth $L$ and width $w$ produces a function with at most
$$2\,(2w+2)^L$$
corners. This is the *supply* side: corners are what a network can manufacture, and the formula says the supply grows exponentially in depth but only polynomially — indeed linearly, once you fix the depth — in width.

## Oscillation is a receipt for corners

The *demand* side is a lemma anybody can verify on a napkin: **a straight line cannot go down, up, and down again.** Formally, if $x_1 < x_2 < x_3$ and an affine function satisfies $f(x_1) \le 1/4$, $f(x_2) \ge 3/4$, $f(x_3) \le 1/4$, we get a contradiction, because an affine function is monotone.

Therefore, if a function alternates between the low band $[0,1/4]$ and the high band $[3/4,1]$ at $m+1$ successive points of $[0,1]$, its knot set $S$ must satisfy
$$m \le 2|S| + 1.$$
Every two alternations force a fresh corner.

And the sawtooth tower alternates a *lot*. At the $2^k+1$ dyadic points $i/2^k$, the tower $\tau^{\circ k}$ takes the value $0$ when $i$ is even and $1$ when $i$ is odd. Anything that stays within $1/4$ of the tower — the mildest possible notion of "approximately right" — must itself be low at the even points and high at the odd ones, so it must alternate $2^k$ times. Hence any approximator has at least about $2^{k-1}$ corners.

## The separation

Now collide supply with demand. If a network of depth $L$ and width $w$ stays within $1/4$ of $\tau^{\circ k}$ everywhere on $[0,1]$, then
$$2^k \;\le\; 4\,(2w+2)^L .$$
That single inequality contains the whole story. Read it as a constraint on the width:
$$w \;\ge\; \tfrac12\left(2^{k/L}/4^{1/L}\right) - 1 .$$
As long as the tower height $k$ grows faster than linearly in the depth $L$, the required width blows up exponentially.

Choosing the concrete witness $k = L^2+4$ gives the headline theorem:

> **Depth Separation Theorem.** For every depth $L \ge 1$, the function $\tau^{\circ(L^2+4)}$ is computed *exactly* by a rectifier network of depth $L^2+4$ and width $3$ — that is, with $3(L^2+4)$ neurons, a size polynomial in $L$. Yet every rectifier network of depth $L$ whose output stays within $1/4$ of it on $[0,1]$ must have width at least $2^{L-1}-1$.

An economical deep machine; an unaffordable shallow one. Depth is not a convenience here, it is the difference between $O(L^2)$ neurons and $2^{\Omega(L)}$ of them.

## Two refinements: it is not a knife-edge

Sceptics rightly ask whether such theorems are artefacts of the worst case — perhaps the shallow network is wrong at one unlucky point and fine elsewhere. It is not.

**Wrong on average.** Integrate, rather than take a maximum. A short computation shows an affine function cannot hug a tent: on a full tooth of width $2/2^k$ containing no corner of $f$, the integrated discrepancy between $f$ and the tower is at least $1/(16\cdot 2^k)$. There are $2^{k-1}$ teeth and only $|S|$ corners to spend, so summing the untouched teeth gives
$$\int_0^1 \bigl|f(x)-\tau^{\circ k}(x)\bigr|\,dx \;\ge\; \frac{2^{k-1}-|S|}{16\cdot 2^k}.$$
For a depth-$L$, width-$w$ network, $|S| \le 2(2w+2)^L$, so the average error is at least $\bigl(2^{k-1}-2(2w+2)^L\bigr)/(16\cdot 2^k)$, which approaches the absolute constant $1/32$ whenever the width is subexponential. The shallow machine is not wrong somewhere; it is wrong everywhere, on average.

**Wrong often.** The low-high-low obstruction is local, so one can localise the counting. A piecewise linear function with $|S|$ corners must miss the tower by more than $1/4$ at at least $2^k/3 - |S| - 2/3$ of the $2^k+1$ dyadic sample points. Failure has positive density on the natural test grid; a shallow network cannot pass even a random spot-check.

**Wrong in every dimension.** Finally, the phenomenon has nothing to do with the input being one-dimensional. Restrict a network on $\mathbb{R}^D$ to a straight line in input space and you obtain a network on $\mathbb{R}$ of exactly the same depth and width — the composition with an affine map is absorbed into the first layer's weights. Consequently, for the *ridge* witness $x \mapsto \tau^{\circ(L^2+4)}(x_{i_0})$, which depends on a single coordinate, the same bound $2^L \le 2w+2$ holds for networks on the unit cube in $\mathbb{R}^D$, with no dependence on $D$ whatsoever. Extra input dimensions do not help a shallow machine imitate a fold.

## The twist: one extra layer buys you nothing

Here the story takes a turn that is easy to miss, and which is the most interesting thing about this circle of ideas.

The natural conjecture is aggressive: for each $L$, there should be a function computed by a depth-$(L{+}1)$ network of polynomial size that every depth-$L$ network needs exponential size to approximate. One extra layer, exponential payoff. The sawtooth tower $\tau^{\circ(L+1)}$ is the obvious candidate.

It fails — and it fails spectacularly, not marginally. Compose the fold with itself and expand:
$$\tau(\tau(y)) = 4\,\mathrm{relu}(y)-8\,\mathrm{relu}\!\left(y-\tfrac14\right)+8\,\mathrm{relu}\!\left(y-\tfrac12\right)-8\,\mathrm{relu}\!\left(y-\tfrac34\right)+4\,\mathrm{relu}(y-1).$$
A double fold is *one* layer of width $5$. So the depth-$(L{+}1)$ witness $\tau^{\circ(L+1)}$ is computed **exactly** — not approximately — by a network of depth $L$ and width $5$, i.e. by $5L$ neurons. No approximation error, no exponential price.

The general pattern is just as clean. For any $c \ge 1$,
$$\tau^{\circ c}(y) = \sum_{i=0}^{2^c} a_i\,\mathrm{relu}\!\left(y - \frac{i}{2^c}\right), \qquad a_0 = a_{2^c} = 2^c,\quad a_i = (-1)^i 2^{c+1} \text{ otherwise}.$$
A single layer of width $2^c+1$ realises an entire tower of height $c$: the coefficients alternate in sign to reverse the slope at every dyadic breakpoint, and the two end coefficients are halved so the total slope returns to zero. Stack $L$ such layers and you compute $\tau^{\circ cL}$ exactly at depth $L$ and width $2^c+1$.

The consequences are sharp:

* **Logarithmic depth gaps are free.** Take $c = \lfloor \log_2 L\rfloor$. Then the depth-$(L+c-1)$ witness — a tower of height $L + \log_2 L - 1$ — is computed exactly by a depth-$L$ network of width at most $L+1$, that is, $O(L^2)$ neurons. Polynomial, not exponential.
* **The exact trade-off is $\Theta(L\log w)$.** At depth $L$ and width $2^c+1$, the largest tower height computable exactly lies between $cL$ and $(c+3)L+2$. The lower bound is a construction, the upper bound is the corner-counting inequality; they match up to the additive $3$ in the base. At width $5$, for example, the achievable height $k$ satisfies $2L \le k \le 4L+2$ — linear in depth, with the constant pinned between $2$ and $4$.

So the mission conjecture is true in its quadratic form and false in its literal one-step form, at least for the canonical witnesses. The governing quantity is neither $k$ nor $L$ alone but the *ratio* $k/L$: it must be unbounded for any exponential separation to be possible, and it must grow at least like $\log w$ for the separation to bite at width $w$.

## What to take away

Three ideas do all the work here, and none of them requires machinery beyond high-school geometry.

1. **Complexity is corners.** For a rectifier network, expressive power is exactly the ability to manufacture breakpoints, and breakpoints multiply with depth and add with width. That asymmetry — multiplication versus addition — is what "depth is powerful" means, quantitatively.
2. **Oscillation is a receipt.** You cannot fake oscillation. Every two alternations between a low band and a high band require a genuine corner, and no amount of clever weight-tuning evades the tally. This turns an approximation-theoretic question into arithmetic.
3. **The gap must be super-linear.** A single extra layer, or even $\log L$ extra layers, can be simulated by widening modestly. Depth separations are real, but they are separations between depth $L$ and depth $\omega(L)$, not between $L$ and $L+1$ — a distinction the folklore often blurs.

Anyone who has folded a strip of paper knows the first idea in their fingers. The mathematics only insists on writing down the receipt.
