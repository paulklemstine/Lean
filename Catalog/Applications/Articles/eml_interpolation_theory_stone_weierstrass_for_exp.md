# Drawing Curves with Straight Lines: A Speed Limit for Approximation

## A very old idea, made exact

Stand far enough back from a finely cut gemstone and its faceted surface looks
smooth. Zoom in on a circle drawn by a computer and you discover it is really a
chain of tiny straight segments. The eye is forgiving: enough short straight
pieces, joined end to end, will imitate any smooth curve you like.

Mathematicians have known a sharpened version of this since the nineteenth
century. The **Stone–Weierstrass theorem** says that *any* continuous function on
a closed, bounded region can be approximated, as closely as you wish, by simpler
building-block functions — provided those building blocks can "tell points apart"
and include the constants. It is one of the great existence theorems of analysis.
But like many existence theorems, it is frustratingly silent on the practical
question every engineer actually asks:

> *How many pieces do I need to hit an error of, say, one part in a thousand?*

Stone–Weierstrass promises a good enough approximation exists. It does not tell
you how big it has to be. This article is about closing exactly that gap — turning
a promise into a **guaranteed budget** — for a particular, surprisingly expressive
family of functions, and doing it with a construction so simple you could sketch
it on a napkin.

## The cast of characters: EML networks

The family in question is the **EML algebra**: all functions you can build by
finite combinations of the *exponential* ($\exp$), the *logarithm* ($\log$),
*addition*, and *multiplication*. The name is just the initials — **E**xp,
**M**ultiply, **L**og. These are precisely the operations at the heart of modern
machine-learning models, where layers stack exponentials, logarithms, sums, and
products into deep networks. So a theorem about EML functions is, in disguise, a
theorem about what such networks can and cannot do.

EML functions are wildly flexible. With $\exp$ and $\log$ in hand you can separate
any two distinct points and reproduce every constant, so Stone–Weierstrass
immediately tells you the EML algebra is *dense*: it can approximate any
continuous target. Good. Now we want the budget.

## The honest workhorse: connect the dots

Here is the construction at the center of the story, and it is gloriously humble.

Take your target function $f$ on the interval $[0,1]$. Chop the interval into $n$
equal cells of width $1/n$: the breakpoints sit at $0, \tfrac{1}{n},
\tfrac{2}{n}, \dots, 1$. At each breakpoint, sample the true value of $f$. Then
simply **connect consecutive samples with straight line segments**. The result is
a continuous, piecewise-linear "connect-the-dots" curve. Call it the
*interpolant* of width $n$.

Concretely, if a point $x$ falls in the cell $[a,b]$ — where $a$ and $b$ are two
neighbouring breakpoints — the interpolant reads off the straight line through the
endpoints:

$$\text{interpolant}(x) = f(a) + \frac{f(b) - f(a)}{b - a}\,(x - a).$$

Each straight segment is the *simplest possible* EML function: a constant plus a
scalar times the variable, $\text{const} + \text{slope}\cdot x$. No exponentials
or logarithms are even needed for the pieces — affine functions already live
inside the EML algebra. So the whole connect-the-dots curve is a bona fide EML
network, and its "width" is just the number of pieces, $n$.

The question is now sharp and quantitative: **how close does connect-the-dots get,
as a function of $n$?**

## What "well-behaved" means: Hölder functions

The answer depends on how wild $f$ is. We need a way to measure wildness. The
classical tool is the **Hölder condition**. A function $f$ is *$\alpha$-Hölder with
constant $L$* (for some exponent $0 < \alpha \le 1$) if for all points $x$ and $y$,

$$|f(x) - f(y)| \le L\,|x - y|^{\alpha}.$$

In words: when two inputs are close, the outputs cannot be too far apart, and the
rate is governed by the exponent $\alpha$.

- When $\alpha = 1$ this is the famous **Lipschitz condition**: the function never
  changes faster than slope $L$. Smooth functions on a closed interval are
  Lipschitz. For instance $f(x) = x^2$ on $[0,1]$ is Lipschitz with $L = 2$,
  because its slope $2x$ never exceeds $2$.
- When $\alpha < 1$ the function is allowed to be *spikier*. The square-root
  function $\sqrt{x}$ is the classic example: near zero it shoots up with infinite
  slope, so it is *not* Lipschitz — but it is $\tfrac{1}{2}$-Hölder with constant
  $1$, because $|\sqrt{x} - \sqrt{y}| \le |x - y|^{1/2}$.

The smaller $\alpha$ is, the rougher the function, and — as we will see — the more
pieces it takes to approximate.

## The main theorem: a guaranteed budget

Here is the headline result, stated plainly.

> **Theorem (Hölder Jackson rate).** Let $f$ be $\alpha$-Hölder on $[0,1]$ with
> constant $L$ and exponent $0 < \alpha \le 1$. Then for every width $n \ge 1$, the
> connect-the-dots interpolant approximates $f$ everywhere on $[0,1]$ with error at
> most
> $$\bigl|\,f(x) - \text{interpolant}(x)\,\bigr| \;\le\; \frac{2L}{n^{\alpha}}.$$

That is the whole promise, made concrete. No hidden constants, no "for $n$ large
enough." The bound holds for every $x$ in the interval and for every width $n$,
with an explicit constant of $2$.

Read the other way, it is a **width law**. To guarantee an error below a target
$\varepsilon$, it suffices to take

$$n \;\ge\; \left(\frac{2L}{\varepsilon}\right)^{1/\alpha},$$

so the number of pieces grows like $\varepsilon^{-1/\alpha}$. Halve your error
budget for a Lipschitz ($\alpha = 1$) function and you need only twice as many
pieces. Halve it for a $\tfrac{1}{2}$-Hölder function and you need four times as
many. Roughness is expensive, and the exponent $1/\alpha$ is the exact price tag.

This is what is known as a **Jackson-type rate**, after Dunham Jackson, who in the
early twentieth century proved the first results tying approximation error to the
smoothness of the target. Our version is special in three ways: it is for the EML
family that underlies machine learning, it comes from a single explicit
construction, and — crucially — it has been verified to the last symbol.

## Why it is true: a tale of two errors

The proof is a small marvel of bookkeeping, and worth seeing because it explains
*where the roughness bites*. Focus on one cell $[a,b]$ of width $h = b - a$, and on
a point $x$ inside it. The interpolant's error splits into two contributions.

**Error one — how far the true value drifts.** Because $f$ is $\alpha$-Hölder and
$x$ is within $h$ of the left endpoint $a$, the value $f(x)$ can differ from $f(a)$
by at most $L\,h^{\alpha}$. The function simply cannot run away faster than that
inside one short cell.

**Error two — how much the straight line tilts.** The interpolant's slope is the
*divided difference* $\frac{f(b) - f(a)}{h}$. The numerator is at most
$L\,h^{\alpha}$, so the slope itself can be as large as $L\,h^{\alpha - 1}$. When
$\alpha < 1$ that exponent is negative, and the slope *blows up* as the cells
shrink — an alarming sign. But the slope only acts over the distance $(x - a)$,
which is at most $h$. Multiplying the runaway slope $L\,h^{\alpha - 1}$ by the
short reach $h$ tames it perfectly back to $L\,h^{\alpha}$.

Add the two pieces: the total error on one cell is at most $2L\,h^{\alpha}$. This is
exactly the **one-cell estimate** at the heart of the proof. Now set the cell width
to $h = 1/n$, note that the cells cover all of $[0,1]$, and you arrive at the global
bound $2L/n^{\alpha}$.

The lesson is subtle and lovely: the divided difference *looks* dangerous for rough
functions, threatening to explode as the grid refines, but the short lever arm of a
narrow cell always cancels the danger. That cancellation is the entire reason
connect-the-dots works at the optimal rate, and not a worse one.

## The two regimes, side by side

The exponent $\alpha$ is a dial between smooth and rough, and the theorem covers
the whole dial at once.

- **Lipschitz ($\alpha = 1$).** The bound becomes $2L/n$. The companion result for
  this case sharpens the constant from $2$ to $1$, giving the clean rate $L/n$ — the
  classic linear interpolation error. Take $f(x) = x^2$ with $L = 2$: a
  connect-the-dots curve with $n$ pieces is guaranteed within $2/n$ of the
  parabola, and in fact within the sharper $2/n$ from the dedicated Lipschitz
  analysis. Twenty pieces already pin the parabola to better than one part in ten;
  two hundred pieces to one part in a hundred.

- **Genuinely rough ($\alpha < 1$).** The bound becomes $2L/n^{\alpha}$, which
  decays more slowly. For $\sqrt{x}$ (with $\alpha = \tfrac{1}{2}$, $L = 1$), the
  guarantee is $2/\sqrt{n}$. To match an accuracy that $x^2$ reaches with a hundred
  pieces, the square root needs on the order of ten thousand — the unavoidable
  surcharge for that infinite spike at the origin.

Both regimes flow from *one* construction and *one* inequality. That unity is the
mathematical payoff: the smooth and rough worlds are not two theorems but one,
parameterized continuously by $\alpha$.

## And in the limit, exactness

Finally, the construction does what intuition demands: refine forever and the error
vanishes. For every fixed point $x$ in $[0,1]$, as the width $n$ grows without
bound, the connect-the-dots value converges exactly to the true value $f(x)$. The
proof is a one-line consequence of the rate: since $n^{\alpha} \to \infty$, the
bound $2L/n^{\alpha} \to 0$, and the approximation is squeezed onto the target.
What Stone–Weierstrass promised abstractly, the explicit interpolant delivers
concretely, with a convergence speed written on the label.

## Why this matters beyond the napkin

It would be easy to dismiss connect-the-dots as too simple to be interesting. That
would be a mistake, for two reasons.

First, **simplicity is the point**. The universal approximation theorems that
underpin neural networks are almost all *existence* results: they assure you that
*some* network of *some* size works, with no usable handle on the size. Here we
have the opposite — a fully explicit network, a fully explicit error, and a fully
explicit width law $n = O(\varepsilon^{-1/\alpha})$. You can budget for it. You can
certify it. There is no gap between the theorem and the thing you build.

Second, **this is the one-dimensional cornerstone of a much larger building**. The
natural next step is many variables: tile a $d$-dimensional cube with a grid and
interpolate on each little box. The error then telescopes coordinate by
coordinate, and the width needed for accuracy $\varepsilon$ scales like
$\varepsilon^{-d/\alpha}$ — the same law, now with the dimension $d$ in the
exponent. That exponential dependence on dimension is the celebrated *curse of
dimensionality*, and the clean one-dimensional rate proved here is precisely the
brick from which the multivariate wall is laid. Other open frontiers beckon too:
*adaptive* grids that place more pieces where the function is rough and fewer where
it is calm, and matching *lower bounds* proving that no method with $n$ pieces can
ever beat $n^{-\alpha}$ — that the rate is not just achievable but optimal.

## The takeaway

Connect-the-dots, the first approximation method anyone ever learns, turns out to
be optimal in a precise and provable sense for the entire scale of Hölder
functions, realized inside the exp–log algebra that powers modern machine
learning. Its error is not merely "small for large $n$" — it is exactly
$2L/n^{\alpha}$, every point, every width, with a constant you can write down. The
nineteenth century told us smooth curves can be drawn with straight lines. The
result here tells us, to the digit, how many lines it takes.
