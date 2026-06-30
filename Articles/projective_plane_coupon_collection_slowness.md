# When Geometry Slows You Down: The Surprising Cost of Orderly Coupons

## A children's game with a grown-up secret

Almost everyone has played some version of the **coupon collector's problem**, even
if they never called it that. You buy cereal boxes hoping to complete a set of
toy figurines; each box hides one figurine, chosen at random. How many boxes must
you buy, on average, before you own all of them? The answer is famous: if there
are $n$ different figurines, you expect to buy roughly $n \ln n$ boxes. The last
few coupons are agonizing — you keep pulling duplicates of toys you already have.

Now change the rules slightly. Instead of revealing one coupon at a time, each
purchase reveals a small *batch* of coupons at once. Intuitively, batches should
speed things up — and they do. But here is the subtle question that turns a
playground puzzle into real mathematics:

> **Does it matter *how* the batches are chosen?**

Suppose every batch has the same fixed size. One option is to choose each batch
*uniformly at random* — every group of that size is equally likely. Another
option is to draw batches from some rigid, pre-designed family of "good" sets,
engineered so that the batches overlap as little as possible and spread their
coverage evenly across all the coupons. Common sense says the second, *structured*
strategy ought to be at least as efficient. After all, we deliberately arranged
the batches to avoid waste.

The startling discovery at the heart of this article is that common sense is
**wrong**. There is a beautiful family of highly structured batches — the *lines
of a finite projective plane* — for which the orderly strategy is provably
**slower** than blind random batching. Structure, it turns out, can be a
liability.

## The geometry of perfect balance

To state the result we need one geometric object: the **finite projective plane**.

Fix a number $q \ge 2$ that is a prime or a power of a prime ($q = 2, 3, 4, 5, 7,
8, 9, \dots$). The projective plane of order $q$ is a finite geometry with a
remarkable, almost suspiciously perfect, symmetry. It has

$$n = q^2 + q + 1$$

**points** and exactly the same number of **lines**. The defining rules are:

- every line contains exactly $q + 1$ points;
- every point lies on exactly $q + 1$ lines;
- **any two distinct points lie on exactly one common line**.

That last rule is the Euclidean axiom we all learned in school — "two points
determine a line" — but now realized in a finite world with no parallels at all:
any two lines also meet in exactly one point. The smallest example, $q = 2$, is
the celebrated **Fano plane**: $7$ points, $7$ lines, each line a triple of
points, drawn as a triangle with its three midpoints and inscribed circle.

These planes are the gold standard of *balanced design*. Every point is treated
identically; every pair of points is treated identically. If you wanted to design
batches that cover a set as evenly as possible, the lines of a projective plane
are exactly what you would draw up.

## Two ways to collect $q^2 + q + 1$ coupons

Take the $n = q^2 + q + 1$ points of the plane as our coupons. We compare two
batch-collection mechanisms, both drawing batches of the same size $q + 1$:

- **The plane mechanism.** Each draw is a uniformly random *line* of the plane.
  You reveal the $q + 1$ coupons lying on that line. There are only $n$ possible
  batches — the lines — and they are the perfectly balanced sets described above.

- **The uniform mechanism.** Each draw is a uniformly random $(q+1)$-element
  subset of the points — *any* group of $q+1$ coupons, with all
  $\binom{n}{q+1}$ groups equally likely.

Both mechanisms reveal the same number of coupons per draw, on the same ground
set of the same size. The only difference is that the plane mechanism restricts
itself to the elegant, hand-picked family of lines, while the uniform mechanism
draws wildly and without discrimination.

**Which finishes first, on average?**

## Inclusion–exclusion: the universal stopwatch

To measure "how long until everything is covered," there is a clean formula. For
any covering process, let $p_A$ be the probability that a *single* draw **avoids**
a fixed set of coupons $A$ — that is, the draw touches none of the coupons in $A$.
Then the expected time to collect *all* coupons is the alternating sum

$$E \;=\; \sum_{\varnothing \neq A \subseteq \text{points}} (-1)^{|A|+1}\,
\frac{1}{1 - p_A}.$$

This is the coupon collector's inclusion–exclusion identity. The single number
$p_A$ is the only thing that distinguishes the two mechanisms, so the whole
contest comes down to comparing avoid-probabilities.

For the **uniform mechanism**, $p_A$ depends only on the *size* $k = |A|$, never on
which coupons are in $A$. A random $(q+1)$-subset avoids a fixed $k$-set exactly
when it is chosen from the other $n - k$ points:

$$p_A^{\text{unif}} \;=\; \frac{\binom{n-k}{\,q+1\,}}{\binom{n}{\,q+1\,}}.$$

For the **plane mechanism**, $p_A$ depends on the *geometry* of $A$: how many of
the $n$ lines happen to miss $A$ entirely. And here the projective plane reveals
its hand through a sequence of exact counts.

## Counting the lines that miss you

How many of the $n$ lines avoid a given configuration of points? The answer
depends, with crystalline precision, on the shape of the configuration:

- **A single point** is missed by exactly $q^2$ lines. (It lies on $q+1$ of the
  $q^2 + q + 1$ lines, so the rest miss it.)
- **A pair of distinct points** is missed by exactly $q^2 - q$ lines.
- **A collinear triple** — three points already lying on a common line — is missed
  by exactly $q^2 - 2q$ lines.
- **A generic (non-collinear) triple** is missed by exactly $(q-1)^2$ lines.

For the Fano plane $q=2$ these numbers are $4$, $2$, $0$, and $1$. A point is
missed by $4$ of the $7$ lines; a pair by $2$; a collinear triple — which in the
Fano plane is a whole line — is missed by $0$ lines, because in this geometry
every two lines meet; and a generic triple is missed by exactly $1$ line.

Translating to probabilities (divide by $n = 7$): a point or a pair gives the
**identical** value under both mechanisms. Indeed, for $q=2$ the uniform avoid
probabilities for $k = 1$ and $k = 2$ are $\tfrac47$ and $\tfrac27$, exactly
matching the plane's $\tfrac{4}{7}$ and $\tfrac{2}{7}$. The plane and the chaos
look the same to the naked eye — until we reach triples.

## The crucial moment: triples split apart

At size three, the plane mechanism splits its avoid-probability into **two
distinct values**: collinear triples ($\tfrac{q^2-2q}{n}$) and generic triples
($\tfrac{(q-1)^2}{n}$). For $q=2$ these are $0$ and $\tfrac{1}{7}$. The uniform
mechanism, blind to geometry, offers a single value $\tfrac{4}{35}$.

Here is the punchline, and it is a gem of a fact:

> **The average of the plane's triple avoid-probabilities, taken over all
> triples, equals the uniform mechanism's single value.**

This *mean-matching* is not a coincidence of $q=2$; it holds at **every** order
$k$ and for every $q$. The reason is a counting symmetry: averaging "how often a
random batch avoids a random $k$-set" gives the same hypergeometric number whether
the batches are lines or arbitrary subsets, because both count the same disjoint
(batch, $k$-set) pairs. At orders one and two the plane's values are not just
equal on average but *constant* — every point alike, every pair alike — so there
is nothing to distinguish. The first place the plane's values genuinely *spread
out* around their common mean is at triples, and the cause of that spread is
**collinearity**.

Why does spreading hurt? Because the stopwatch function $t \mapsto \dfrac{1}{1-t}$
is **convex**. By Jensen's inequality, a quantity that is spread out around a
fixed mean produces a *larger* average value of a convex function than the mean
does. The plane's collinear-versus-generic split therefore contributes *more* to
the expected cover time than the uniform mechanism's single averaged value. The
order-three term of the inclusion–exclusion sum is strictly larger for the plane.
Geometry — specifically, the existence of collinear triples — is exactly what
creates the harmful variance.

## The verdict for the Fano plane

For the smallest plane, $q = 2$, one can carry the inclusion–exclusion sum all the
way to the end. It is a $127$-term alternating sum over the nonempty subsets of
seven coupons, and it evaluates exactly:

$$E_{\text{plane}} = \frac{163}{30} \approx 5.4333, \qquad
E_{\text{unif}} = \frac{85691}{15810} \approx 5.4200.$$

The structured, perfectly balanced line mechanism is **strictly slower**:

$$E_{\text{unif}} < E_{\text{plane}}, \qquad
E_{\text{plane}} - E_{\text{unif}} = \frac{163}{30} - \frac{85691}{15810}
\approx 0.0133.$$

The gap is small but unmistakably positive. This single computation overturns a
natural conjecture — associated with Grünbaum and Yaakobi — that the geometric
line mechanism could only help, or at worst not hinder, the collection process.
It does hinder. The order-three surplus generated by collinear triples survives
the cancellations of all the higher-order alternating terms, and the orderly
strategy loses the race.

The gap's tininess explains why the conjecture stood for so long. At "order three"
alone the plane is already heavier, but only barely; one has to track the entire
alternating tail of corrections to be sure the advantage is not reversed. For
$q = 2$ it is not.

## A conjecture for all of geometry

Is the Fano plane a fluke, or a herald? Exact and simulated computations for the
next planes — $q = 3$ (with $13$ points), $q = 4$ ($21$ points), and $q = 5$ ($31$
points) — all point the same way: the line mechanism is slower every time, and the
relative slowness appears to grow. This leads to a bold, sharply posed
conjecture:

> **Universal slowness.** For *every* prime power $q \ge 2$, collecting the
> $q^2 + q + 1$ coupons by drawing the lines of the projective plane of order $q$
> takes strictly longer, on average, than drawing uniformly random $(q+1)$-subsets
> of the same points.

The structural reason is now clear and is the same at every order: the two
mechanisms share identical avoid-probabilities at orders one and two, and from
order three onward the plane's geometry forces its avoid-probabilities to spread
around a fixed mean, which — by the convexity of the stopwatch function — can only
increase the expected time. Proving the general statement reduces to a single,
delicate estimate: show that the leading order-three surplus, which has an exact
closed form, dominates all the signed higher-order corrections combined.

A companion conjecture pins down *why* geometry is to blame. Among all balanced
batch designs on $q^2 + q + 1$ points — every point in $q+1$ batches, every pair in
exactly one — the projective plane is conjectured to be **extremal**: collinearity
is the unique mechanism that first creates the harmful variance, and any design
that reduces the spread of triple avoid-probabilities reduces the slowness, while
removing all collinear triples removes it entirely.

## Why a small number matters

Why should anyone care that an idealized collector finishes a hundredth of a draw
later? Because the lesson is general and counterintuitive: **balanced structure is
not the same as efficient coverage.** In sampling, experimental design, randomized
algorithms, and machine learning, practitioners routinely reach for highly
structured, low-overlap batches — Latin squares, combinatorial designs, balanced
mini-batches — in the belief that even, non-redundant coverage must be optimal.
The projective plane is a clean, exactly solvable warning that this instinct can
fail: a perfectly balanced design can carry a hidden, geometry-induced *variance*
that makes complete coverage slower than naive random sampling.

The mathematics also offers a precise diagnostic. The villain is not balance
itself but the *spread* of higher-order avoid-probabilities around their mean,
amplified by a convex cost. Wherever a design forces such a spread — and
collinearity is the simplest way to force it — completion slows. The projective
plane converts a vague intuition into an exact, testable, and quantifiable
phenomenon, and turns a children's coupon game into a window on the subtle costs
of order.
