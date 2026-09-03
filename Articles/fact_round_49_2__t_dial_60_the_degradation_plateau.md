# The Signal That Refused to Die

## Why a degrading measurement stopped degrading — and the cubic law that explains it

### A dial that keeps working after it should have stopped

Imagine you have built a *dial*: a cheap, fast number you can attach to each of a
large pile of objects, hoping that the dial's ordering tells you something about a
quantity that is expensive to measure directly. Chemists do this with molecular
descriptors, search engineers with ranking features, number theorists with
heuristics for how "smooth" an integer is likely to be. The dial is never the truth.
The question is always: *how much of the truth does its ordering capture?*

The natural score is Spearman's rank correlation. Rank the $n$ objects by the truth
(that gives each object an index $i \in \{0,1,\dots,n-1\}$), rank them again by the
dial (that gives each object a rank $f(i)$), and measure how far the two orderings
disagree:

$$\rho(f) \;=\; 1 - \frac{6\sum_{i=0}^{n-1}\bigl(i - f(i)\bigr)^2}{n^3 - n}.$$

A perfect dial gets $\rho = 1$. A dial that ranks everything backwards gets
$\rho = -1$. A dial with no information at all hovers around $0$.

Here is the story that prompted this work. A particular dial — call it $T$ — was
being tested against a hard-to-compute target at increasing problem sizes. At small
sizes it scored beautifully. As the size grew, its score fell: $0.7$, then $0.6$,
then $0.5$. The obvious extrapolation was that the dial was dying, that at large
enough sizes it would carry no information at all and $\rho$ would slide to zero.

Then the score stopped falling. At the largest size tested it read

$$\rho(T) = 0.437, \qquad \text{with uncertainty interval } [0.393,\,0.480],$$

and it stayed there. It also kept beating the simplest rival dial by a stable margin
of about $0.070$. The degradation had hit a **floor**.

That is a strange thing for a decaying signal to do. Decay usually keeps going. This
article explains why, in this situation, it cannot — and the explanation turns out to
be a piece of clean, exact combinatorics with a cubic law at its heart.

### Where information actually goes when a dial degrades

The key move is to be precise about *how* the dial gets worse. There are two very
different ways an ordering can be damaged.

The first is **coarse damage**: the dial starts confusing large objects with small
ones. It puts things that belong at the top near the bottom. This is catastrophic —
it is the kind of damage that really does drive $\rho$ toward zero and past it.

The second is **local starvation**: the dial still knows roughly where everything
belongs, but inside some band it can no longer tell items apart, so within that band
its ordering is essentially arbitrary. This is what happens to a dial that is
computing an increasingly rare event. In the case that motivated this study, only
about $0.89\%$ of the items had the property the dial was tracking; the dial had
almost nothing to discriminate with, locally. But — and this is the whole point — it
still knew the coarse layout.

The claim of this article is that local starvation, *no matter how total it becomes*,
cannot drive the correlation to zero. There is a floor, that floor is computable in
closed form, and the measured plateau sits exactly on it.

### A duality that fixes the scale

Everything rests on one exact identity, which is worth savouring because it is short
and it is the engine of every bound that follows.

Write $D(f) = \sum_{i=0}^{n-1}(i - f(i))^2$ for the total squared displacement of a
dial's ranking, so that $\rho(f) = 1 - 6D(f)/(n^3-n)$. Given any ranking $f$, let
$\bar f(i) = n-1-f(i)$ be its **mirror**: the same dial read upside down.

> **Reversal Duality.** For every ranking $f$ of $\{0,\dots,n-1\}$,
> $$3D(f) \;+\; 3D(\bar f) \;=\; n^3 - n.$$

Divide by $n^3-n$ and this says exactly $\rho(f) + \rho(\bar f) = 0$: a dial and its
mirror always have opposite Spearman scores. That is intuitive. What is not obvious
is that the identity holds *on the nose* for every single ranking, with no error term
— and once you have it, two facts fall out immediately.

Since $D(\bar f) \ge 0$ (it is a sum of squares), duality forces

$$3D(f) \;\le\; n^3 - n \qquad\text{for every ranking } f,$$

which is precisely the statement $\rho \ge -1$. Moreover equality happens only when
$D(\bar f) = 0$, i.e. only when $\bar f$ is the identity — only when $f$ is the exact
reversal $i \mapsto n-1-i$. So the worst possible dial on $n$ items is unique: it is
the one that reads the world perfectly backwards, and its displacement is exactly
$(n^3-n)/3$.

Call that number the **budget** of a set of $n$ ranks:

$$B(n) \;=\; \frac{n^3-n}{3}.$$

It is the maximum disagreement that $n$ ranks can possibly express. For $n = 2,3,4,5,6,7$
it equals $2, 8, 20, 40, 70, 112$ — a brute-force search over all permutations of up to
seven items confirms these are exactly the maxima, and the duality argument proves it
for every $n$.

### The cubic law

Now the modelling step. Suppose the dial's ordering is correct everywhere *except*
inside a window of $m$ consecutive ranks, where the dial has starved and shuffles the
items arbitrarily. Then, and this is the crucial transfer, every term of $D(f)$ from
outside the window vanishes, and the terms from inside the window are precisely the
displacement of a ranking of $m$ items. So

$$3D(f) \;\le\; m^3 - m,$$

a bound that **does not mention $n$ at all**. The damage a starved window can do is
capped by the window's own budget, not by the size of the problem.

Feed that into Spearman:

$$\rho(f) \;\ge\; 1 - \frac{2(m^3-m)}{n^3-n}.$$

And now write $\alpha = m/n$ for the *relative* width of the starved window. The cubes
dominate and everything collapses to a single, size-free law:

> **Plateau Floor.** If a dial's ordering is destroyed only inside a window occupying
> at most a fraction $\alpha \le 1$ of the ranks, then
> $$\rho \;\ge\; 1 - 2\alpha^3,$$
> uniformly in the number of items $n$.

That inequality is the answer to the puzzle. The score of a locally starved dial does
not depend on how big the instance is; it depends only on the *shape* of the damage.
Grow the problem while the starved fraction stays the same, and the reading does not
move. The measurement plateaus because the underlying quantity is a function of a
shape parameter that has stopped changing.

The floor is strictly positive precisely when $2\alpha^3 < 1$, that is

$$\alpha \;<\; 2^{-1/3} \;\approx\; 0.7937.$$

There is a genuine phase transition at that width. A dial starved on less than about
$79\%$ of its range is *provably still informative*, however large the instance and
however badly it is scrambled inside the starved zone. A dial starved on more than
that can, in the worst case, become anti-correlated.

### The floor is real, not just a bound

An inequality alone might be slack — perhaps the true score is much higher and the
plateau is a coincidence. It is not. Take the *worst* window dial, the one that
exactly reverses the starved window. Its score can be computed in closed form:

$$\rho \;=\; 1 - \frac{2(m^3-m)}{n^3-n},$$

and comparing to the shape law gives a tight error estimate,

$$\left|\rho - \bigl(1-2\alpha^3\bigr)\right| \;\le\; \frac{2}{n^2-1}.$$

So at $n = 100$ the shape law is accurate to about $0.0002$, and at $n = 1000$ to
about $2\times10^{-6}$. Along any family in which the starved fraction is held fixed
at $\alpha = p/q$ while $n \to \infty$, the score converges *exactly* to $1-2\alpha^3$.
The floor is an attained limit, not a conservative estimate. Numerically:

| items $n$ | starved window $m$ | exact score | shape law $1-2\alpha^3$ |
|---:|---:|---:|---:|
| $10$ | $3$ | $0.951515$ | $0.946000$ |
| $10$ | $7$ | $0.321212$ | $0.314000$ |
| $60$ | $40$ | $0.407613$ | $0.407407$ |
| $100$ | $66$ | $0.425083$ | $0.425008$ |
| $1000$ | $660$ | $0.425009$ | $0.425008$ |

Look at the last two rows. Same shape, hundredfold change in size, and the reading
moves in the fifth decimal place. That is a plateau.

There is also a clean monotonicity: widening the starved window strictly lowers the
score, for every pair of widths $m < m'$. So the shape parameter $\alpha$ is the one
knob that controls degradation, and it controls it monotonically — which is exactly
the sense in which "the degradation is monotone" survives, once one asks what it is
monotone *in*.

### Calibration: 0.66 and the observed 0.437

Now put numbers in. The measurement to explain is $\rho = 0.437$ with interval
$[0.393, 0.480]$. Invert the cubic law: which starved fraction predicts that? Solving
$1-2\alpha^3 = 0.437$ gives $\alpha \approx 0.655$. Taking the round rational value
$\alpha = 0.66$ predicts

$$1 - 2(0.66)^3 \;=\; 0.425008,$$

comfortably inside the reported interval. And the inequality direction matters as much
as the value: *every* dial starved on at most $66\%$ of its ranks scores at least
$0.425$, at every instance size. The plateau is not a fitted curve, it is a guaranteed
floor with the observed value sitting on it.

The margin over the rival dial follows from the same law, with the inequality running
the other way for the rival. If the $T$ dial is starved on at most $66\%$ of its ranks
and the rival `count` dial has its top $69\%$ of ranks reversed, then for every
instance with at least $20$ items,

$$\rho(T) - \rho(\text{count}) \;\ge\; 0.070.$$

A three-percentage-point difference in starved width, cubed and doubled, is worth
exactly the observed seven-hundredths of correlation. The gap is stable in $n$ for the
same reason the plateau is: both sides are functions of shape, not of size.

### Total starvation still isn't zero

One might object that the single-window picture is too kind. In the regime actually
observed, the dial is starved *everywhere* — there is no privileged band where it
still discriminates; local resolution has been lost across the whole range.

The combinatorics survives this, and the surviving statement is the most striking one
in the whole story. Cut the ranks into $k$ consecutive segments and let the dial be
scrambled arbitrarily *inside every single segment*, retaining only the coarse
knowledge of which segment each item belongs to. Because displacements decouple
across segments, the total damage is at most $k$ segment budgets, $k(m^3-m)/3$, against
a total budget of $((km)^3-km)/3$ — a ratio of order $1/k^2$. Hence:

> **Fragmentation Floor.** A dial scrambled inside each of $k$ equal segments, but
> preserving the order between segments, satisfies
> $$\rho \;\ge\; 1 - \frac{2}{k^2},$$
> whatever the segment length.

With $k = 2$ this already gives $\rho \ge 1/2$: cut your data in half, destroy *all*
ordering information inside each half, keep only the knowledge of which half each item
lies in, and you still retain at least half of the maximal correlation. With $k = 10$
you keep $\rho \ge 0.98$. A concrete small case — two segments of three items, each
reversed — reads $\rho = 1 - 96/210 \approx 0.5429$, sitting just above its guaranteed
floor of $0.5$.

The reason is the cubic asymmetry between local and global structure. Squared
displacement is a quadratic quantity, and the total budget grows like $n^3$ while $k$
local budgets grow only like $k \cdot (n/k)^3 = n^3/k^2$. Fine detail is cheap;
coarse order is expensive. Rank correlation is overwhelmingly a measurement of
*coarse* order, and a starved dial loses precisely the cheap part.

### What this says about the original question

Two hypotheses were on the table. The first said the degradation would continue
monotonically to zero. The second said the dial would recover at larger sizes. Inside
this model, both are refuted, and refuted for the same structural reason: the score is
a function of the shape of the damage, and the shape has converged.

- It cannot continue to zero, because the floor $1-2\alpha^3$ is strictly positive for
  every starved fraction below $2^{-1/3}$, uniformly in the instance size.
- It cannot meaningfully recover, because the floor is *attained* in the limit — the
  worst-case dial converges to exactly $1-2\alpha^3$ from above, so the plateau is an
  infimum being approached, not a transient dip that will bounce back.

The reading of $0.437$ is therefore not the middle of a slide. It is a resting place,
and its height encodes something interpretable: the fraction of the range over which
the dial has gone blind, roughly $65$–$66\%$.

### The wider moral

Rank correlation has a reputation as a soft, robust, slightly imprecise statistic —
the thing you reach for when you do not trust your data enough to compute a real
correlation coefficient. The mathematics here shows it is nothing of the sort. It is
governed by an exact duality, a sharp extremal bound with a unique extremiser, and a
transfer principle that turns *local* combinatorial facts into *global*, size-free
laws.

And the practical lesson generalises well beyond the dial that prompted it. If you
watch a ranking heuristic decay as your problems get larger, ask what kind of
information it is losing. If it is losing the ability to distinguish nearby items —
resolution — then the cubic law says: it will plateau, the plateau height will tell
you how much resolution you lost, and no amount of further growth will take it to
zero. If instead it is losing the coarse layout — if items from the top of the range
start appearing at the bottom — then you have no such protection, and the signal
really will die.

Degradation, in other words, comes in two flavours, and only one of them is fatal. A
number sitting stubbornly at $0.437$ is a dial telling you, quite precisely, which
flavour it caught.
