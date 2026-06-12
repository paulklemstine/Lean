# The Folded Ruler: Why Deep Networks See What Shallow Ones Cannot

## A simple paper-folding trick

Take a strip of paper one unit long. Fold it exactly in half, then unfold it and
look at the crease. Now imagine a machine that does something subtler: it takes a
number `x` between 0 and 1 and "folds" it according to one rule —

> rise straight up from 0 to 1 as `x` goes from 0 to one-half, then come straight
> back down from 1 to 0 as `x` goes from one-half to 1.

The graph is a perfect symmetric peak, a little mountain centered at `x = 1/2`.
Mathematicians call it the **tent map**, and we can write it in one line:

> **tent(x) = 1 − |2x − 1|.**

It looks innocent. But the tent map hides one of the most beautiful and
consequential phenomena in modern machine learning: the reason that *depth* — the
number of layers stacked in a neural network — is not a luxury but a genuine,
mathematically unavoidable source of power.

This article tells the story of a fully rigorous, machine-checked proof of that
fact. Every claim below has been verified down to the logical bedrock. But the
ideas are simple enough to hold in your hand, like a folded strip of paper.

## Neural networks are just folding machines

The workhorse of modern deep learning is a humble function called the **ReLU**,
short for "rectified linear unit." It does almost nothing:

> **relu(x) = max(x, 0).**

If the input is positive, pass it through unchanged; if it is negative, output
zero. That's it. A neural network is built by stacking layers, each of which adds
up several ReLUs with different slopes and offsets. The astonishing empirical fact
of the last fifteen years is that piling up enough of these trivial pieces lets
machines recognize faces, translate languages, and fold proteins.

Here is the first surprise. The tent map — that little mountain — is *exactly* one
layer of two ReLUs. You can check the identity by hand:

> **tent(x) = 1 − relu(2x − 1) − relu(1 − 2x).**

This is a real theorem in our formal development, named `tent_relu_repr`. The
absolute value `|y|` equals `relu(y) + relu(−y)`, and substituting `y = 2x − 1`
turns the one-line tent formula into a width-2 ReLU layer. So the tent map is not a
toy analogy for a neural network — it *is* the simplest interesting neural network,
written in its native language.

## The magic of doing it again

Now comes the trick that changes everything. What happens if you feed the tent
map's output back into the tent map? And then do it again? And again, `k` times in
all?

Composing the tent with itself is what a **deep** network does: each application is
one more layer. Write `tent^[k]` for the `k`-fold composition. Geometrically, each
new layer folds the previous graph in half. After one fold you have one peak. After
two folds, two peaks. After `k` folds, the graph of `tent^[k]` is a comb of **2^k**
identical spikes, each one a razor-thin triangle, packed into the same interval
from 0 to 1.

The output never escapes the range from 0 to 1 — the mountains never get taller.
What explodes instead is their **steepness**. Two facts pin this down exactly. The
first, which we call `tent_iterate_zero`, says the deep network still anchors the
left edge to the ground:

> **tent^[k](0) = 0.**

The second, `tent_iterate_peak`, locates the very first spike and measures its
height:

> **tent^[k]( (1/2)^k ) = 1.**

Read those two lines together and a stunning picture emerges. As the input slides
from `0` to `(1/2)^k` — a distance of just **2^{−k}**, astronomically small once
`k` is moderately large — the output of the deep network rockets from `0` all the
way to `1`. At depth 30, that ramp is squeezed into an interval about one part in a
billion wide. The function is climbing a cliff with slope on the order of **2^k**.

We made this precise. A function's "steepness budget" is captured by its
**Lipschitz constant**: the largest ratio of output change to input change. A
single tent has slope ±2 everywhere, so it is 2-Lipschitz (`tent_lipschitz`).
Composing `k` of them multiplies the steepness, giving the clean theorem
`tent_iterate_lipschitz`:

> **tent^[k] is 2^k-Lipschitz.**

A depth-`k` network, built from constant-width layers and a number of parts growing
only *linearly* in `k`, achieves a steepness that grows *exponentially* in `k`. That
mismatch is the whole game.

## Why shallow networks are doomed

Here is where the story turns into a genuine impossibility theorem — the kind of
result that says not "we don't know how" but "it cannot be done."

Suppose you have a rival network that is **shallow**: few layers, but as wide as you
like, with bounded weights. Any such network is itself a Lipschitz function with
some steepness budget `K`. The question is: can it imitate the deep tent network?

Imitation means approximation. Let's say the shallow network `g` is allowed an error
of at most `ε` at every point of the interval. We want to know whether it can stay
within `ε` of `tent^[k]` everywhere.

The deep network forces an impossible choice. Look at just two input points: `x = 0`,
where `tent^[k]` equals 0, and `x = (1/2)^k`, where it equals 1. They are only
`2^{−k}` apart. If `g` is to stay within `ε` of the deep network, then at `x = 0` it
must be near 0, and at `x = (1/2)^k` it must be near 1. So `g` itself has to climb
roughly the full unit height across that tiny gap. But `g` is `K`-Lipschitz: across a
gap of width `2^{−k}` it can rise by at most `K · 2^{−k}`. Account for the two
permitted error margins of `ε` each, and the arithmetic is forced:

> **1 ≤ K · 2^{−k} + 2ε.**

Turn that around. If a shallow network's budget satisfies

> **K · 2^{−k} + 2ε < 1,**

then it is *mathematically impossible* for it to approximate the depth-`k` tent
network within `ε`. This is our central theorem, `relu_depth_separation`, and its
proof is exactly the two-point argument above, made airtight.

The consequence is dramatic. To even have a chance of matching a depth-`k` network,
a shallow rival must drive `K · 2^{−k}` up toward 1, which means its Lipschitz
constant `K` — and therefore its weight-times-width budget — must grow like **2^k**.
Linear cost for depth; exponential cost for width. That gap never closes; it only
widens with `k`.

## The knife's edge is real

A skeptic might ask: is the threshold `K · 2^{−k} + 2ε < 1` just a loose bound that
clever engineering could beat? No — and we proved that too. The deep network
approximates *itself* perfectly, with zero error, and there its own budget hits the
boundary exactly. Plug in the deep network's true Lipschitz constant `K = 2^k` and
zero error:

> **2^k · 2^{−k} + 2·0 = 1.**

This identity, `relu_depth_separation_sharp`, lands precisely on `1`. The strict
inequality in the theorem cannot be relaxed to "less than or equal," because the
honest depth-`k` solution sits exactly on the knife's edge. The bound is not
conservative; it is sharp.

To make it concrete, consider depth `k = 3`, where the deep network has eight
spikes. Try to approximate it with the laziest possible shallow model: the constant
function that always outputs `1/2`. This constant is `0`-Lipschitz — the extreme
shallow case, `K = 0`. The theorem then says no accuracy better than the threshold
is possible, and indeed `1 · (1/2)^3 + 0 = 1/8 < 1`, so the constant cannot get
within `3/8` of the eight-spiked function. This exact example is checked in the
formal file. The constant guesser, and indeed any insufficiently steep shallow
network, is provably blind to the fine structure that three folds create.

## Two faces of the same coin: a robustness warning

There is a darker reading of the same inequality, and it matters for anyone who
deploys neural networks in the real world.

The very steepness that lets a deep network express rich structure also makes it
**fragile**. Because `tent^[k]` has local slope `2^k`, nudging the input by a mere
`2^{−k}` can swing the output across its entire range, from 0 to 1. If you imagine
the output as a confidence score or a classification boundary, then an
imperceptible perturbation — one part in `2^k` — can flip the verdict completely.

This is the mathematical seed of *adversarial examples*: tiny, carefully chosen
input changes that fool a network. The same quantity, the local slope `2^k`, that
defeats shallow approximation also certifies adversarial sensitivity. Expressive
power and brittleness turn out to be two readings of a single line of algebra:

> **(output gap) ≤ (steepness) × (input gap) + (slack).**

When the steepness is enormous, a vanishing input gap still permits a maximal output
gap. Depth buys you expressive richness and, in the same breath, hands you a
robustness liability. There is no free lunch — only an honest accounting.

## A bridge between two explosions

The tent map is not the only route to depth separation, and one of the prettiest
aspects of this work is seeing how it connects to a seemingly different story.

There is a companion construction based on the **iterated exponential**: a function
that, composed with itself `k` times, grows like a tower of exponentials. There, the
*range* of the function explodes — the outputs become astronomically large — while
the local slope stays moderate. In the tent map, exactly the opposite happens: the
range stays politely bounded in `[0,1]`, but the local slope explodes.

These look like opposite phenomena. Yet they are governed by the *same* inequality.
Whether the gap between two output values comes from a function that climbs to dizzy
heights (range blow-up) or from one that climbs a hidden cliff (slope blow-up), the
obstruction to shallow approximation reads identically:

> **(value gap) ≤ K · (point distance) + 2ε.**

Range-blow-up and slope-blow-up are two faces of one inequality. A single abstract
lemma, parameterized only by *how far apart* the two witness points are and *how
much* the function changes between them, contains both depth-separation theorems as
special cases. Unifying them is one of the natural next steps this work opens up.

## Why this matters

For most of the history of machine learning, the superiority of deep networks was an
empirical mystery — they simply *worked* better, for reasons that felt more like folk
wisdom than mathematics. Results like the one told here turn that folk wisdom into
theorem. They show that depth is not a tuning knob you could in principle trade for
width; it is a genuinely different and more efficient currency for buying complexity.

The tent map distills the entire phenomenon to its essence. One absolute value, one
fold repeated, two points, one inequality. From these you get an exponential
separation between deep and shallow, a sharp and unimprovable threshold, a built-in
warning about adversarial fragility, and a bridge to a whole family of related
results.

A strip of paper, folded again and again, becomes too intricate for any single
straight cut to follow. That is the mathematics of depth — and now, every fold of
the argument has been checked, crease by crease, and found to hold.
