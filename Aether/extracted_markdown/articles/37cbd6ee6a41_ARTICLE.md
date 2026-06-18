# The Origami of Deep Networks: Why Depth Beats Width

## A folded sheet of paper

Take a strip of paper and fold it in half. Then fold it again. And again.
After ten folds the paper is too thick and stubborn to continue — but
imagine you could keep going. Each fold doubles the number of layers. Ten
folds make a thousand layers; twenty folds make a million; thirty folds
would, in principle, stack a billion sheets into something a few kilometres
tall.

This explosive doubling is the secret behind one of the most important
phenomena in modern artificial intelligence: **depth separation**. It is
the mathematical reason that *deep* neural networks — networks with many
layers stacked one atop another — can express patterns that *shallow*
networks, no matter how wide, can never match without paying an
astronomical price.

This article tells the story of a single, beautifully simple function — the
**tent map** — that makes the folding metaphor exact, and of a chain of
theorems that turn the intuition "depth creates complexity" into airtight
mathematics.

## The simplest interesting machine

The basic building block of a modern neural network is almost
embarrassingly humble. It is the **ReLU** unit — short for *rectified
linear unit* — which takes a number `x` and returns

```
relu(x) = max(x, 0).
```

That's it. If the input is positive, pass it through; if it's negative,
flatten it to zero. A bent hinge. And yet by wiring together many of these
hinges, adjusting how strongly each feeds into the next, you can build the
image recognizers, language models, and game-playing engines that define
the current era of computing.

From two ReLU hinges we can assemble the hero of our story. Define the
**tent map**:

```
tent(x) = 1 − |2x − 1|.
```

On the interval from `0` to `1`, this draws a perfect symmetric triangle: a
straight line climbing from height `0` at `x = 0` up to height `1` at the
midpoint `x = 1/2`, then descending back to `0` at `x = 1`. It looks
exactly like a child's drawing of a tent.

Crucially, the tent is a genuine one-layer ReLU network of width two.
Because the absolute value `|y|` can be written as `relu(y) + relu(−y)`, a
little algebra gives the exact identity

```
tent(x) = 1 − relu(2x − 1) − relu(1 − 2x).
```

Two hinges, combined linearly, produce one tent. This is our atom of
computation.

## Folding by composition

Now comes the magic. What happens if we feed the output of one tent into
the input of another? In mathematics, applying a function to its own output
is called **composition**, and applying it `k` times in a row is written
`tent^[k]`.

Composing the tent with itself does something remarkable: it *folds the
graph*. A single tent has one peak. Compose it twice and you get two peaks.
Compose it three times and you get four peaks. In general, the `k`-fold tent
`tent^[k]` has **2^(k−1) peaks** packed into the unit interval — a comb of
spikes whose teeth double with every layer of depth.

We can pin this down with absolute precision using the **dyadic grid** — the
evenly spaced points `j / 2^k` for `j = 0, 1, 2, …, 2^k`. The central
theorem about the iterated tent says that on this grid it does nothing but
alternate between `0` and `1`:

> **Dyadic alternation.** For every `j` from `0` to `2^k`,
> `tent^[k](j / 2^k) = j mod 2`.
> In words: the deep tent is exactly `0` at every even grid point and
> exactly `1` at every odd grid point.

So the graph of `tent^[k]` is a zig-zag that shoots from `0` up to `1` and
back down `2^k` times as `x` sweeps across `[0, 1]`. Two special cases
deserve names: the tent vanishes at every even node
(`tent^[k](2j / 2^k) = 0`) and reaches its ceiling at every odd node
(`tent^[k]((2j+1)/2^k) = 1`). The fold count doubles with each layer, just
like our strip of paper.

## The two faces of explosion

Why should a shallow network struggle to reproduce this? There are two
complementary ways to see it — one about *steepness*, one about *counting*.

### Face one: the slope explosion

How steep can the tent get? A single tent has slopes of `+2` and `−2`; it
is **2-Lipschitz**, meaning the output can never change faster than twice
the rate of the input. Composition multiplies these slopes. The `k`-fold
tent is therefore **2^k-Lipschitz** — and that bound is achieved. Look at
the very first rising edge: the theorem says

```
tent^[k](0) = 0   and   tent^[k]((1/2)^k) = 1.
```

The function climbs the full distance from `0` to `1` across an interval of
width `(1/2)^k = 2^(−k)`, an interval that becomes microscopically thin as
depth grows. The slope on that edge is exactly `2^k`.

Now suppose a rival network `g` wants to imitate the deep tent to within a
small error `ε`. Suppose further that `g` is **K-Lipschitz** — its own
slope is capped at `K`, which is what happens when a shallow network is
built from bounded weights. Then `g`'s output at the two ends of that thin
rising edge can differ by at most `K · 2^(−k)`. But the *true* values
differ by a full `1`. Accounting for the wiggle room `ε` at each endpoint,
we are forced into the inequality

> **ReLU depth separation.** If `K · 2^(−k) + 2ε < 1`, then no
> `K`-Lipschitz function `g` can stay within `ε` of `tent^[k]` everywhere on
> `[0, 1]`.

To beat this, the rival's Lipschitz constant `K` must grow like `2^k` —
exponentially in the depth. A shallow network can match a depth-`k` tent
only by smuggling exponentially large weights into its single layer.

How sharp is this threshold? Exactly sharp. Plug in the genuine slope
`K = 2^k` and zero error: `2^k · (1/2)^k + 0 = 1`, hitting the boundary
dead-on. The strict inequality cannot be relaxed to `≤` — the deep tent
sits precisely on the knife's edge of what a Lipschitz function can do.

### Face two: the counting explosion

The slope argument has a soft spot: it can be defeated, in principle, by a
network with *enormous* weights, since those raise `K`. The second face of
the argument closes that loophole, and it is stronger because it doesn't
care about weight magnitudes at all. It cares only about *how many times a
curve can cross a line*.

A continuous piecewise-linear function — which is exactly what a ReLU
network computes — is made of straight segments. With `w` segments it can
cross any fixed horizontal level at most `w` times. That is a hard ceiling
set purely by the number of pieces, i.e. by the **width** of the network,
and no amount of weight inflation can raise it.

Now watch the deep tent cross the level `1/2`. Because `tent^[k]`
alternates between `0` and `1` on consecutive dyadic nodes, it must pass
through `1/2` inside *every one* of the `2^k` little intervals
`[i/2^k, (i+1)/2^k]`. And any decent approximation must do the same:

> **Forced crossings.** If `g` is continuous and approximates `tent^[k]` to
> accuracy `ε < 1/2` on `[0, 1]`, then inside every dyadic subinterval
> `[i/2^k, (i+1)/2^k]` there is a point where `g` equals exactly `1/2`.

The reasoning is the **Intermediate Value Theorem** at its most elegant.
At the two ends of such a subinterval the true tent is `0` and `1` (in some
order). With error below `1/2`, the approximant `g` is dragged below `1/2`
at one end and above `1/2` at the other. A continuous curve that starts
below a line and ends above it must cross it somewhere in between. Repeat
across all `2^k` subintervals and you get `2^k` distinct crossings.

Put the two halves together: `g` must cross `1/2` at least `2^k` times, but
a width-`w` piecewise-linear network can cross at most `w` times. Therefore

```
w ≥ 2^k,
```

regardless of how large the weights are. Depth manufactures *count*, and
count is something width must pay for one piece at a time. This is the
weight-magnitude-independent form of depth separation — the strongest
version of the slogan "deep beats wide."

## One inequality to rule them both

Step back and the slope story has a sibling. Instead of a function that
stays bounded but gets steep, consider one that stays gently sloped but
grows astronomically tall: the **iterated exponential tower**, defined by
`iterExp(0, x) = x` and `iterExp(n+1, x) = exp(iterExp(n, x))`. Each layer
exponentiates the last, so `iterExp(k, 1)` is a tower of `k` exponentials —
a number beyond comprehension for even modest `k`. This function is
strictly increasing, so its values at the two endpoints of `[0, 1]` are far
apart.

The tent explodes in *slope*; the tower explodes in *range*. They seem
unrelated, yet they are governed by a single line of algebra:

> **The two-point obstruction.** Let `g` be `K`-Lipschitz and suppose it
> approximates a function `f` to within `ε` at two points `a` and `b`. Then
> `|f(a) − f(b)| ≤ K · |a − b| + 2ε`.

This is nothing but the triangle inequality, yet it is the master key. A
deep network defeats every shallow rival by arranging for the left-hand
**gap** `|f(a) − f(b)|` to overflow the right-hand **budget**
`K · |a − b| + 2ε`. The tent does it by shrinking the distance `|a − b|`
to `2^(−k)` while the gap stays at `1`. The tower does it by inflating the
gap `|f(a) − f(b)|` while the distance stays at `1`. Slope-blowup and
range-blowup are the two ways to break the same inequality.

There is even a security flavour to all this. Read the slope explosion as a
statement about *adversarial examples*: any classifier `g` whose Lipschitz
constant is below `2^k` admits two inputs separated by a mere `2^(−k)` whose
*true* deep-tent labels are maximally different (`0` and `1`), yet whose
predicted scores differ by less than `1`. The very steepness that defeats
shallow approximation also certifies a fragility — a tiny perturbation that
flips the truth while the smooth model barely notices.

## Why it matters

Depth separation is more than a curiosity. It is part of the theoretical
backbone explaining *why* the deep-learning revolution worked at all. For
decades the textbook result was that even a single hidden layer is a
"universal approximator" — wide enough, it can fit any function. True, but
silent on **cost**. The tent map shows the cost can be exponential: some
functions are cheap for a deep network and ruinously expensive for any
shallow one.

What makes this account special is that every claim above has been verified
by a proof assistant — checked symbol by symbol against the axioms of
mathematics, with no appeal to intuition or hand-waving. The folding
metaphor, the doubling of peaks, the exponential slope, the `2^k` forced
crossings, the one inequality unifying tent and tower — all of it is
machine-certified truth.

So the next time you fold a piece of paper and feel it fight back after the
seventh crease, remember: you are running, by hand, the very computation
that gives deep networks their power. Each fold doubles the structure.
Depth, it turns out, is just folding — and folding, done enough times,
outruns any amount of width.
