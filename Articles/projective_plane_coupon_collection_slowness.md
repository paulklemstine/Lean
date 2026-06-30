# The Slow Geometry of Collecting Everything

## When structure makes you wait

Imagine a child collecting a set of cartoon stickers, one per cereal box, hoping
to complete the album. Each box hides a sticker chosen at random, and the painful
truth every collector eventually learns is that the *last few* stickers take
forever to arrive. This is the famous **coupon collector's problem**: if there
are $n$ different coupons and each box gives you a uniformly random one, the
expected number of boxes you must open before owning all of them grows like
$n \log n$.

Now change the rules in a small but important way. Instead of one coupon per box,
suppose each box gives you a whole *bundle* of coupons at once — say a fixed
number $k$ of them. Bundling obviously speeds things up: more coupons per box
means fewer boxes. But here is the subtle question at the heart of this article.
Suppose two different factories both ship bundles of exactly the same size $k$.
One factory assembles each bundle by picking $k$ coupons completely at random.
The other assembles its bundles according to a rigid geometric blueprint, so that
the bundles overlap and interlock in a highly organized way. Both factories use
bundles of identical size. Which one lets you finish your collection faster?

Intuition pulls hard in one direction. Surely *organized* is better than
*random*. A well-designed system, where the bundles are spread out to cover the
ground efficiently, ought to beat blind chance. This is exactly the kind of
belief that underlies the engineering of error-correcting codes, lottery
wheels, and combinatorial designs: clever structure beats luck.

The surprising answer, for one of the most beautiful structures in all of
mathematics, is that **structure makes you slower**. The organized factory loses.

## The blueprint: a projective plane

The rigid blueprint in question is a **finite projective plane**. Fix a number
$q \ge 2$ (technically a prime power: $2, 3, 4, 5, 7, 8, 9, \dots$). A projective
plane of order $q$ is a collection of *points* and *lines* obeying three crisp
rules:

- there are exactly $n = q^2 + q + 1$ points, and exactly the same number of
  lines;
- every line passes through exactly $q + 1$ points, and every point lies on
  exactly $q + 1$ lines;
- any two distinct points lie on exactly one common line.

The smallest interesting case is $q = 2$, giving $n = 7$ points and $7$ lines of
$3$ points each. This is the celebrated **Fano plane**, the little seven-point
diagram with seven lines (one of them drawn as a circle) that appears on
mathematicians' coffee mugs. For $q = 3$ we get $13$ points and $13$ lines of
$4$ points each, and so on.

Each line is a special $(q+1)$-element subset of the points. So here are our two
coupon factories, both shipping bundles of size $k = q + 1$ drawn from the same
$n$ points:

- the **plane mechanism**: each draw is a uniformly random *line* of the plane —
  one of the $n$ tightly interlocking $(q+1)$-point bundles;
- the **uniform mechanism**: each draw is a uniformly random $(q+1)$-element
  subset of the $n$ points, with no geometric constraint at all.

We collect points until we have seen all $n$ of them, and we ask: which
mechanism has the larger expected completion time? The geometric one is the
**slower** one.

## A conjecture, and its downfall

This question is not new. Decades ago, Grünbaum and Yaakobi raised the natural
guess that the structured, design-based mechanism — the one that covers the plane
"efficiently" — should finish *faster* than dumb uniform sampling. The
conjecture encodes the widespread faith that good designs cover quickly.

It is false. For the Fano plane ($q = 2$) one can compute both expected times
exactly. The uniform mechanism finishes in expected time
$$E_{\text{uniform}} \approx 5.4201,$$
while the plane mechanism needs
$$E_{\text{plane}} \approx 5.4333.$$

The structured plane is *strictly slower*. A direct computation for $q = 3$
(thirteen points, thirteen lines) tells the same story:
$E_{\text{plane}} \approx 9.4444$ against $E_{\text{uniform}} \approx 9.4297$.
The gap is small but real, and it always points the same way.

So the conjecture collapses. But a disproved guess in a single case is only the
beginning. The deeper question is *why*, and *whether it happens for every
$q$*. The answer turns out to rest on one of the most reliable engines in all of
probability: **convexity**.

## How to measure the wait

To see the mechanism behind the slowness we need a formula for the expected
completion time. There is a clean one. For any covering process, write $p_A$ for
the probability that a single draw *misses* (avoids entirely) a fixed target set
$A$ of points. Then the expected time to cover everything is the alternating
inclusion–exclusion sum over all nonempty target sets:
$$E = \sum_{\varnothing \ne A} (-1)^{|A|+1} \, \frac{1}{1 - p_A}.$$

Each term measures how stubbornly some particular set of points refuses to be
covered: the closer $p_A$ is to $1$ (the more often a draw avoids $A$), the
larger the harmonic weight $\tfrac{1}{1-p_A}$. The signs alternate by the size of
$A$: singletons add, pairs subtract, triples add, and so on.

Now compare our two mechanisms term by term, grouping the target sets by their
size $k = |A|$.

**Singletons agree.** For a single point, the plane mechanism misses it whenever
the random line avoids that point. In a projective plane of order $q$, exactly
$q^2$ of the $n$ lines miss any given point (each point lies on $q+1$ lines, and
$n - (q+1) = q^2$). So the plane's avoid-probability for one point is
$q^2 / n$. The uniform mechanism misses a single point with probability
$\binom{n-1}{q+1} / \binom{n}{q+1} = (n - q - 1)/n = q^2/n$ as well. They are
*identical*.

**Pairs agree.** For two points, the plane misses both exactly when the line
avoids both. Each point sits on $q+1$ lines, and the two points share one common
line, so $2(q+1) - 1 = 2q + 1$ lines hit at least one of them, leaving $n -
(2q+1) = q^2 - q$ lines that miss both. A short calculation shows the uniform
mechanism reproduces this same probability exactly. Again, *identical*.

This is no accident. There is a clean **mean-matching identity**: averaged over
all $k$-element target sets, the plane mechanism avoids a set with exactly the
uniform probability, for *every* size $k$. The structured and the random
mechanisms are statistically indistinguishable at the level of averages, at every
order. If only averages mattered, the two would tie forever.

## The first crack: triples

Averages are not everything. The harmonic weight $\tfrac{1}{1-p}$ is a *convex*
function of $p$, and convex functions are exquisitely sensitive not to the mean
of their inputs but to their *spread*.

This is where the geometry finally bites, and it does so for the first time at
**triples** — sets of three points. Under the uniform mechanism, every triple is
the same: three points are three points, with a single avoid-probability. Under
the plane mechanism, triples come in two genuinely different flavors:

- **collinear** triples, whose three points all lie on one common line; these are
  missed by $q^2 - 2q$ lines;
- **generic** triples, not all on a line; these are missed by $(q-1)^2 = q^2 - 2q
  + 1$ lines.

The two avoid-counts differ by *exactly one line*. The collinear and generic
triples carry two distinct avoid-probabilities, $p_{\text{coll}} = (q^2-2q)/n$
and $p_{\text{gen}} = (q-1)^2/n$, and crucially these two numbers have the **same
weighted mean** as the single uniform value. The plane has taken one number and
split it into two, keeping the average fixed.

Here convexity delivers the verdict. If you replace a single value by two values
with the same mean, a strictly convex function's average *increases* — this is
the strict two-point Jensen inequality:
$$\tfrac{1}{2}\!\left(\frac{1}{1-x} + \frac{1}{1-y}\right) > \frac{1}{1 -
\tfrac{x+y}{2}} \qquad (x \ne y).$$
The order-three contribution to $E$ is therefore *strictly larger* for the plane
than for the uniform mechanism. And because the order-three sign in the
inclusion–exclusion expansion is positive, this surplus pushes the plane's
expected time *up*: it makes the plane slower.

Counting the two species confirms how lopsided the split is. The number of
collinear triples is $n \binom{q+1}{3}$, while the generic ones number
$\binom{n}{3} - n\binom{q+1}{3}$; the generic species satisfies the tidy identity
$6 \cdot (\#\text{generic}) = n\,q^3(q+1)$ and overwhelmingly dominates. The
plane really does carry two honestly different values at order three, and their
spread is what costs time.

## Putting the first three orders together

Collecting orders one, two, and three with their inclusion–exclusion signs gives
the cleanest rigorous statement of the phenomenon. Define the **truncated**
expected time as the sum of the first three orders. Then for *every* prime power
$q \ge 2$:

- orders one and two are exactly equal for the two mechanisms (singletons and
  pairs are geometrically uniform, so they cancel perfectly);
- order three is strictly larger for the plane (one value splits into two with
  the same mean, and convexity does the rest);
- therefore the truncated expected time of the plane mechanism strictly exceeds
  that of the uniform mechanism.

Numerically the order-three surplus is robust and growing: about $0.15$ at
$q = 2$, about $0.67$ at $q = 3$, about $4.6$ at $q = 5$, and into the hundreds
and thousands as $q$ climbs. The geometric mechanism is provably slower through
order three, for *all* $q$ — and for the small cases $q = 2, 3, 4, 5$ a full
all-orders computation confirms it is slower outright.

## Why the general case is hard — and what it teaches

If order three already tips the scales, why is the full statement (slower for
*every* $q$, summed over *all* orders) still open? Because the
inclusion–exclusion sum has alternating signs, and one must rule out the
possibility that the higher orders — quadruples, quintuples, and beyond —
collectively claw back the order-three surplus. The believed resolution is that
they cannot: the per-order gap between the two mechanisms is essentially the
*variance* of the line-incidence counts among same-size targets, weighted by the
convex harmonic function, and this variance shrinks rapidly because large
configurations are overwhelmingly "generic," concentrating on the uniform value.
Controlling that alternating tail is the one remaining quantitative estimate.

The moral reaches well beyond stickers and cereal boxes. We tend to assume that
balance and symmetry make a system efficient. Here the opposite holds, and the
reason is sharp: two mechanisms can be **identical in every average** and still
behave differently, because what governs the waiting time is not the mean but the
*spread*. A projective plane is the most balanced design imaginable — every pair
of points meets in exactly one line — and that very balance forces its triples to
split into collinear and generic types with a fixed mean but nonzero spread.
Convexity converts that spread directly into extra waiting time.

The slow geometry of collecting everything is, in the end, a story about a single
inequality between an average of two numbers and the number in the middle. That
inequality, repeated across the architecture of one of mathematics' most elegant
objects, is enough to overturn a decades-old conjecture and to suggest a new
organizing principle: among all designs whose bundles have a fixed size and whose
averages match, it is precisely the most *balanced* ones that cover the slowest.
