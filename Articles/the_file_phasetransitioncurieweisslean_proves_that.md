# One Threshold to Rule Them All: How Magnets and Family Trees Share a Secret

Heat a magnet and something remarkable happens. Below a certain temperature, the
iron on your refrigerator clings to itself with a stubborn collective loyalty —
its atoms point the same way, and the whole block behaves as a single magnet.
Raise the temperature past a sharp critical point, and that loyalty evaporates
all at once. The atoms scramble, the magnetism vanishes, and no amount of careful
cooling-just-short-of-the-line brings back even a trace of it. The transition is
not gradual; it is a genuine switch, flipped at a precise value.

Now picture something that seems to have nothing to do with magnets: a family
name passing down through generations, or a mutation spreading through a
population, or a single infected person at the start of an epidemic. Each
"parent" produces some random number of "children." If parents tend to have
fewer than one surviving offspring on average, the lineage is doomed — it will
die out with certainty, sooner or later. If they tend to have more than one, the
lineage has a fighting chance to survive forever. And here, too, there is a
razor-sharp dividing line.

This article is about a surprising fact: **these two thresholds are the same
threshold.** Not similar, not analogous in a vague hand-waving way — the *same*
mathematical mechanism, sitting at the *same* critical value, provable by the
*same* single lemma. The magnet and the family tree are two costumes worn by one
idea.

## The self-consistent magnet

Let us make the magnet precise. In the simplest useful model of magnetism — the
mean-field, or Curie–Weiss, model — every atom feels the *average* alignment of
all the others. Call that average alignment $m$, the **magnetization**. It ranges
from $-1$ (everyone points down) through $0$ (total disorder) to $+1$ (everyone
points up).

Each individual atom, sitting in the collective field produced by the average
$m$, wants to align with it, but thermal jostling fights back. The physics works
out to a beautifully self-referential equation. If $\beta$ measures the coupling
strength (large $\beta$ means cold and strongly interacting; small $\beta$ means
hot and weakly interacting), then the magnetization must satisfy

$$ m = \tanh(\beta\, m). $$

Read this as a demand for **self-consistency**: the average alignment $m$ that the
atoms produce must equal the average alignment $m$ that they respond to. The
hyperbolic tangent $\tanh$ is the gentle S-shaped curve that saturates at $\pm 1$;
it encodes the tug-of-war between alignment and thermal noise.

The equation always has the boring solution $m = 0$: perfect disorder is always
self-consistent. The question is whether it has any *other* solution — a
spontaneously ordered state where the material magnetizes itself with no outside
help. That is exactly what a permanent magnet is.

Here is the clean answer, and it is sharp:

> **The Curie–Weiss transition.** For $\beta \le 1$ the only solution is
> $m = 0$: the material cannot magnetize itself. For $\beta > 1$ a genuinely
> positive solution $m \in (0,1)$ appears (together with its mirror image
> $-m$): spontaneous magnetization switches on. The critical coupling is exactly
> $\beta_c = 1$.

Why $1$, and why so sharp? Look at the two curves $y = m$ and $y = \tanh(\beta m)$
near the origin. The straight line has slope $1$. The tanh curve leaves the
origin with slope $\beta$ and then bends *below* the line (it is concave for
positive argument). If the tanh curve starts out flatter than the diagonal
($\beta \le 1$), it stays below the diagonal forever and never meets it again
except at $0$ — no magnet. If it starts out *steeper* ($\beta > 1$), it must rise
above the diagonal immediately, and since it eventually saturates below $1$ while
the diagonal keeps climbing, the two curves are forced to cross exactly once in
between. That crossing is the spontaneous magnetization. The whole drama is
controlled by a single number: the slope of the curve where it leaves the
origin.

## The self-consistent family tree

Now the family tree. Suppose each individual, independently, has a random number
of children drawn from a Poisson distribution with mean $\mu$. Start with one
ancestor. Will the lineage survive forever, or fizzle out?

Let $q$ be the probability that the lineage *survives* — that the family tree is
infinite. A classic piece of probability shows that $q$ obeys its own
self-consistency equation. The reasoning is elegant: the whole tree goes extinct
exactly when every one of the founder's children starts a sub-tree that itself
goes extinct. Bookkeeping this with the Poisson law collapses to

$$ q = 1 - e^{-\mu q}. $$

Again there is the trivial solution $q = 0$ — extinction with certainty is always
self-consistent. And again the real question is whether a *positive* survival
probability can coexist.

The answer has the identical shape:

> **The survival transition.** For $0 < \mu \le 1$ the only solution is $q = 0$:
> the lineage dies out almost surely. For $\mu > 1$ a positive survival
> probability $q \in (0,1)$ appears, and it is unique. The critical mean is
> exactly $\mu_c = 1$.

The intuition is the same as the magnet's, told in the language of curves. The
survival map $F(q) = 1 - e^{-\mu q}$ passes through the origin, bends concavely,
and saturates below $1$. Its slope at the origin is precisely $\mu$. If $\mu \le
1$ it never overtakes the diagonal and only $q = 0$ survives; if $\mu > 1$ it must
cross the diagonal once at a positive value. A family survives if and only if
people have, on average, more than one child. Stated that baldly it sounds
obvious — but the *sharpness*, the fact that $\mu = 1$ is an exact knife-edge with
nothing at all on one side and a definite positive chance on the other, is the
subtle part.

## The bridge

Put the two equations side by side:

$$ m = \tanh(\beta\, m), \qquad q = 1 - e^{-\mu q}. $$

They look different. One involves a hyperbolic tangent, the other an exponential.
One is about spins in a crystal, the other about offspring in a genealogy. But
strip away the costumes and each is an instance of the same abstract question:

> *When does a curve that starts at the origin, rises, and bends over cross the
> diagonal line $y = x$ at a positive point?*

The map $F$ — whether it is $\tanh(\beta\,\cdot)$ or $1 - e^{-\mu\,\cdot}$ — is in
both cases smooth, increasing, and concave, with $F(0) = 0$. Its slope at the
origin is the coupling ($\beta$ or $\mu$). And the answer is a single clean
criterion, the heart of the whole story:

> **The order-parameter dichotomy.** A concave increasing map through the origin
> acquires a positive fixed point exactly when its slope at the origin exceeds
> $1$.

This is not a metaphor connecting the two models; it is a theorem that *contains*
both. Prove it once, in the abstract, and the magnet's ordered phase and the
family tree's survival phase both fall out as one-line corollaries. The critical
value is $1$ in both cases for the simplest of reasons: $1$ is the slope of the
diagonal you are trying to overtake.

The proof of the criterion is itself a small gem. If the origin-slope exceeds
$1$, then just to the right of $0$ the curve is momentarily *above* the diagonal
(it is climbing faster than the line). But far to the right the curve has
saturated and sits *below* the diagonal. A continuous curve that is above a line
here and below it there must cross it somewhere in between — that is the
Intermediate Value Theorem, the same principle that guarantees a thermometer
passing from cold to hot must, at some instant, read exactly room temperature.
That crossing point is the order parameter. Conversely, if the curve never climbs
faster than the diagonal, it can never get above it, so it never crosses, and only
the trivial solution survives.

Two supporting facts do the delicate work of keeping the curves below the diagonal
in the subcritical regime. For the magnet, $\tanh y < y$ for every $y > 0$: the
hyperbolic tangent always lags behind the identity. For the family tree,
$1 - e^{-x} < x$ for every $x > 0$: the survival map does too. Both are elementary
inequalities, and both say the same geometric thing — a concave curve through the
origin never rises above its own tangent line.

## The same law, different fingerprints

If the two models were *identical*, the story would be a cute coincidence and
nothing more. What makes it genuinely interesting is where they *differ* — and
that the difference, too, is governed by a clean principle.

Ask how fast the order parameter turns on as you nudge the coupling just past the
critical point. For the magnet, the answer is a square-root law:

$$ m(\beta) \approx \sqrt{3(\beta - 1)} \qquad \text{as } \beta \to 1^+. $$

The magnetization rises with infinite initial steepness — double the distance past
the threshold and the magnetization grows by a factor of only $\sqrt 2$. The
exponent is $1/2$.

For the family tree, the onset is a *linear* law:

$$ q(\mu) \ge \frac{2(\mu - 1)}{\mu^2}, $$

so the survival probability climbs in direct proportion to how far $\mu$ exceeds
$1$. The exponent is $1$.

Same threshold, same underlying lemma, but different "critical exponents." Where
does the difference come from? From **symmetry**. The tanh map is *odd*:
$\tanh(-y) = -\tanh(y)$. Its Taylor expansion has no quadratic term — the first
correction beyond the straight-line slope is cubic, $\tanh y \approx y - y^3/3$.
That missing quadratic term is exactly why the magnet's onset is a square root.
The survival map, by contrast, is *not* odd; its expansion keeps a quadratic term,
$1 - e^{-x} \approx x - x^2/2$, and that surviving quadratic term forces the
linear onset.

So the shape of the transition — how gently or abruptly the ordered phase emerges
— is written in the symmetry of the update map. An odd map gives the square-root
signature familiar from ferromagnets; a lopsided map gives the linear signature of
branching survival. One principle sets the *location* of the transition (slope
crosses $1$); a finer principle, the parity of the map, sets its *character*.

## Why it matters

Physicists have long spoken of "universality" — the empirical miracle that wildly
different systems, from magnets to fluids to superconductors, share identical
critical behavior near their phase transitions. The story here is a crisp,
completely provable instance of that philosophy. Two models from utterly separate
corners of science — condensed-matter physics and probability theory — turn out to
be governed by one abstract fixed-point criterion, with a shared critical value and
a symmetry rule that predicts their differences.

The reach extends well past these two examples. The survival transition is the
mathematical skeleton of epidemic outbreaks (an infection spreads if and only if
each case infects more than one other on average — the basic reproduction number
$R_0 = 1$ is *this* threshold), of nuclear chain reactions, of viral content on
social networks, and of percolation through porous or networked media. The
Curie–Weiss transition is the prototype for collective ordering everywhere, from
magnetism to the synchronization of neurons and the emergence of consensus in
opinion dynamics.

That all of these hinge on the same one-line question — *does the curve leave the
origin steeper than the diagonal?* — is the kind of unification that makes
mathematics feel less like a collection of tricks and more like the discovery of a
hidden order. One threshold, wearing many disguises, sitting quietly at the number
$1$.
