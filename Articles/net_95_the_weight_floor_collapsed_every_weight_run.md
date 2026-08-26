# The Floor That Wasn't There

## How a "hard limit" on shrinking neural networks turned out to be a statement about *scales*, not about *bits*

There is a folk theorem in the world of running large language models on ordinary
hardware. It says: *you can compress a model's weights down to about six bits
apiece, and below that, the thing falls apart.* Six bits is the floor. Push past
it and the model stops being a model and starts being noise with good manners.

The folk theorem has an honest pedigree. Take a small network, replace each of
its 16-bit weights with the nearest value on a coarse grid, and watch what
happens. Down to six bits, fine. At five, wobbly. At four, gone. The curve does
not bend — it breaks. You can see the cliff with your own eyes.

This article is about what happened when we went looking for that cliff in a
seven-billion-parameter model, using the compression schemes that people
actually deploy — and found that it was not there. Not softened. Not shifted.
*Absent.* And about the mathematics that explains why: a clean statement
separating what a bit width can and cannot be responsible for, and a second
statement about which parts of a neural network are allowed to have a cliff at
all.

---

## Seven rungs of a ladder

Compression of a model's weights is measured in **bits per weight**, or bpw. The
uncompressed reference here uses 16 bits. The quality of the resulting model is
measured by **perplexity** on held-out text: roughly, the effective number of
choices the model believes it faces at each word. Lower is better. The reference
model scored $6.9825$.

We evaluated the same model, on the same held-out text, at seven precisions:

| precision | bits per weight | perplexity | change vs. reference |
|---|---|---|---|
| reference | 16 | 6.9825 | — |
| rung 1 | ≈ 8.5 | 6.9781 | $-0.063\%$ |
| rung 2 | ≈ 6.6 | 7.0006 | $+0.259\%$ |
| rung 3 | ≈ 5.5 | 7.0427 | $+0.862\%$ |
| rung 4 | ≈ 4.8 | 7.1093 | $+1.816\%$ |
| rung 5 | ≈ 3.9 | 7.2758 | $+4.201\%$ |
| rung 6 | ≈ 2.6 | 8.1105 | $+16.155\%$ |

The last row is the headline. At $2.6$ bits per weight — a factor of six smaller
than the reference, deep inside the region the folk theorem calls uninhabitable —
the model is $16\%$ worse. Degraded, certainly. Undeployable, no. That is the
difference between a model that says something slightly clumsier than it meant to
and a model that has stopped working.

And there is no cliff anywhere in between. Write $E(b)$ for the **excess
perplexity** at bit width $b$, meaning the amount by which perplexity exceeds the
reference:
$$E(b) \;=\; \mathrm{PPL}(b) - 6.9825 .$$
Then across the measured range the numbers are $0.0181$, $0.0602$, $0.1268$,
$0.2933$, $1.1280$. Each is a couple of times the one above it. Not "a couple of
times, and then suddenly a hundred times". A couple of times, every time.

**The Geometric Ladder Law.** *For every one of the ten ordered pairs of measured
rungs — not merely for adjacent ones — the excess perplexity is multiplied by a
factor between $2.5$ and $3$ for each bit of precision removed. Equivalently,*
$$E(b) \;\asymp\; C\, m^{-b}, \qquad m \in [2.5,\, 3],$$
*describes the entire range from $6.6$ down to $2.6$ bits per weight with a single
parameter.*

The extreme observed rates are $2.539$ and $2.982$. Ten pairs, one band, and the
band is tight enough that neither endpoint has much room to move. A single
exponential, fitted once, tells you the whole curve.

Two consequences follow immediately, and both are worth naming. The curve is
**strictly decreasing** in bit width (more bits, less damage — obvious, but worth
having) and **strictly convex**: every one of the ten triples of measured points
has its secant slopes increasing. Convexity is what "gentle curve" means
precisely. A cliff is the opposite of convexity in the relevant sense: it is a
place where the curve's behaviour changes character. This one never does.

---

## Why a geometric band forbids a floor

Here is the structural point, and it is almost embarrassingly simple once you see
it.

Suppose you know only this: *removing one more bit multiplies the damage by at
most $m$.* Then removing $k$ more bits multiplies the damage by at most $m^k$.
That is an induction two lines long. But it is exactly the statement that damage
can never blow up. A floor — a bit width at which the model dies — would require
the damage to become unbounded, or at least to leap by an enormous factor, at
some finite precision. A geometric bound forbids this at every finite $k$. The
damage is dominated by a geometric series; a geometric series does not have a
pole.

**Corollary (conditional extrapolation).** *If the fitted upper rate $m = 3$
continues to hold below the lowest measured rung, then even at $1.6$ bits per
weight — a full bit past anything measured — the relative excess perplexity is
still under $+50\%$*, the conventional "undeployable" threshold. Indeed
$3 \times 1.1280 / 6.9825 = 0.4846$. One does not have to believe the
extrapolation to appreciate its shape: the law you fit to the data does not
predict the cliff the folk theorem promised, even when you push it past its
domain.

---

## Where the floor actually comes from

If the floor is not a property of bit width, what is it a property of? The
answer, in one phrase: **quantiser quality times scale**. And the mathematics
lets us put both halves of that product into the same units — namely bits.

Start with the standard second-order picture. A trained network sits near a
minimum of its loss. Perturb the weights by a vector $e$ and, to second order,
the loss rises by
$$Q(e) \;=\; \tfrac12 \sum_i \lambda_i\, e_i^2 ,$$
where the $\lambda_i$ are the curvatures (Hessian eigenvalues) along each
direction. A $b$-bit quantiser with dynamic-range constant $c$ makes each
coordinate error at most $c/2^b$. Substituting gives the prediction

**The Curvature Bound.** *A $b$-bit quantiser with dynamic-range constant $c$
applied to a network with $n$ weights and curvatures bounded by $\Lambda$ raises
the loss by at most*
$$\frac{K}{4^{\,b}}, \qquad K = \frac{n\Lambda c^2}{2}.$$

Two things fall out. First, **the four-per-bit ceiling**: in this model,
degradation multiplies by *exactly* $4$ for each bit removed, because squared
error scales as $4^{-b}$. Four is therefore the theoretical worst case for a
smooth, second-order world. The measured ladder runs at $2.54$ to $2.98$ per
bit — strictly under the ceiling, at every one of the ten pairs. Calibration
recovers a factor the second-order model does not know about, but it never
*exceeds* the ceiling. The measurement lives inside the theory's envelope.

Second, and this is the load-bearing observation:

**Quality Is a Bit Shift.** *A quantiser that is $2^{\,j}$ times more accurate is
worth exactly $j$ bits. The curvature bound at width $b$ with constant $c/2^{\,j}$
is identically the bound at width $b+j$ with constant $c$.*

Read that slowly, because it dissolves the entire controversy. "Quantiser
quality" and "bit width" are not two different kinds of thing that have to be
traded off by taste. They are the same quantity in the same units. Improving your
quantiser by a factor of two *is* buying one more bit. Which means:

**No Intrinsic Floor.** *Fix any bit width $b$ whatsoever and any quality
tolerance $T > 0$. There exists a quantiser accuracy at which the curvature bound
at that very bit width is inside $T$.*

There is no such thing as a bit width that is undeployable. There are only
quantisers that are not yet good enough at that width. A floor observed with one
quantiser is displaced by $j$ bits by a quantiser $2^j$ times better, and $j$ can
be anything you like.

---

## Cashing out the confound: block scaling is worth $\log_2(R/\mathrm{rms})$ bits

The original toy experiment and the seven-rung ladder differ in *two* ways at
once: the quantiser got better, and the model got 14 times bigger. An honest
reading has to admit the confound. But the "quality is bits" theorem lets us
compute the quality half exactly, and see whether it is enough on its own.

Here is the mechanism the modern quantisers use and the toy one did not. Split a
tensor into $B$ blocks. The toy quantiser uses one scale factor for the whole
tensor, so its grid spacing is set by the tensor's *global* dynamic range
$R$ — one wild outlier anywhere coarsens the grid everywhere. A block quantiser
gives each block its own scale, so block $i$ is quantised at spacing set by its
*own* range $r_i$. The mean squared error is then governed not by $R$ but by the
root mean square of the block ranges,
$$\mathrm{rms}(r) \;=\; \sqrt{\frac1B \sum_{i=1}^{B} r_i^2}.$$
Define the **scale gain** as the ratio $G = R/\mathrm{rms}(r)$: the factor by
which blocking shrinks the effective range.

Three facts, and they close the story.

**Blocking never hurts:** $G \ge 1$, always. (The root mean square of numbers each
at most $R$ is at most $R$.)

**Blocking has a budget:** $G \le \sqrt{B}$, always. (The largest block range is
at most $\sqrt{B}$ times the root mean square — a one-term-versus-whole-sum
comparison.)

**The budget is exactly outlier concentration:** if a single block carries the
entire dynamic range and the rest are flat, then $G = \sqrt{B}$ exactly. So the
advantage of a calibration-aware block quantiser over naive rounding is *precisely
and only* a statement about how concentrated the outliers are. No outliers, no
gain. All the range in one block, maximal gain.

And by the same algebra as before, a gain of $2^{\,j}$ shifts the whole
degradation curve by exactly $j$ bits.

Now the arithmetic. Real block quantisers use $B = 256$. The budget is
$\sqrt{256} = 16 = 2^4$: **at most four bits**, whatever the weights look like.
The observed collapse of the floor was from $6.0$ bits per weight to $2.6$ — a
shift of $3.4$ bits.

$3.4 < 4$.

The floor's collapse fits *entirely* inside the block-scaling budget. Quantiser
quality alone can account for all of it; the fourteen-fold jump in model size is
not needed as an explanation. That converts a documented confound into a
falsifiable prediction: compare naive rounding against block quantisation *at
fixed model scale* and you should see a rigid horizontal translation of the whole
ladder, by at most four bits, and by exactly $\log_2(R/\mathrm{rms}(r))$ bits for
the measured range profile of the tensors — a number computable from the weights
alone, without evaluating perplexity even once.

---

## The other axis: why cache keys *do* have a cliff

Everything so far says degradation is smooth. But somewhere in these systems
there *is* a cliff — a real one, measured on a different axis. When you quantise
the model's attention cache, the stored *values* tolerate four bits happily,
while the stored *keys* fall off a wall somewhere between eight bits and five.
Same tensors, same arithmetic, same hardware. Why the asymmetry?

Because of what the numbers are *for*. And this, it turns out, is a theorem.

Weights and cached values are **content**: they are consumed by a
probability-weighted average. If your quantiser is accurate to within $\delta$ and
$p$ is a probability distribution, then
$$\Big|\sum_i p_i\, q(v_i) - \sum_i p_i v_i\Big| \;\le\; \delta .$$
The proof is the triangle inequality and $\sum_i p_i = 1$. And the bound is
*sharp*: a single coordinate with error exactly $\delta$ attains it. So content
channels have a **modulus of continuity**: the output error is linear in the
quantiser step and vanishes with it. Smoothness is not a lucky empirical fact; it
is forced.

Cached keys are **selection**: they are consumed by an $\arg\max$. And here:

**Selection Has No Modulus of Continuity.** *For every quantiser step $\delta > 0$
and every target error $C$, there is a score configuration with a strict top-1
choice, a $\delta$-accurate quantiser that flips that choice, and a value pair
whose read-out then differs by exactly $C$.*

The construction is a two-element example: two scores separated by $\delta/2$, and
a quantiser that nudges each of them by $\delta/2$ in opposite directions. It is
$\delta$-accurate by fiat, and it reverses the ranking. Consequently no bound of
the form "selection error $\le f(\text{quantiser step})$" can ever hold, for any
function $f$ at all. Selection error is $\Theta(1)$ where content error is
$\Theta(\delta)$.

So: **selection interfaces carry precision requirements; content containers do
not.** That is the dissociation, stated as mathematics rather than as folklore.

The theory even locates the wall. If the top-1 margin — the gap between the best
score and the runner-up — is $g$, then a $b$-bit quantiser accurate to $2^{-b}$
provably preserves the decision once $2/2^b < g$, and can already destroy it once
$g \le 2^{-b}$. The cliff sits at $b \approx \log_2(1/g)$: a property of the
*margin distribution*, not of the tensor. And over a whole sequence:

**Flip Counting.** *The number of attention positions whose top-1 decision is
destroyed by an $\varepsilon$-accurate quantisation of the keys is at most the
number of positions whose margin is below $2\varepsilon$.*

Which is to say: the cliff is the cumulative distribution function of the margin,
evaluated at twice the quantiser step. If most margins cluster in a narrow band,
that CDF has a near-vertical segment, and the system inherits a near-vertical
degradation curve. Weights have no selection step anywhere; that is exactly why
they cannot cliff.

---

## Stacking compressions

The practical question is what happens when you compose independent
compressions — small weights *and* a small cache. Do the costs add? Do they
conspire?

In the second-order picture, the excess loss $Q(e)$ is the *square of a seminorm*
in the perturbation. That is all one needs. Cauchy–Schwarz in the curvature
metric gives the triangle inequality $\sqrt{Q(e+f)} \le \sqrt{Q(e)} + \sqrt{Q(f)}$
— costs add in the square-root scale, never worse. Squaring:

**The Stack Budget.** *If one compression costs at most $a$ and another at most
$b$, the composed stack costs at most $a + b + 2\sqrt{ab}$, whatever the
correlation between the two perturbations.*

At the measured numbers — $+1.816\%$ for the weights, $+0.14\%$ for the cache —
that guarantees the whole stack stays **under $3\%$**, even in the pathological
case where the two perturbations point the same way. And if the perturbations are
orthogonal in the curvature metric, which is the natural "independent noise"
hypothesis, the costs are *exactly* additive: $1.816\% + 0.14\% = 1.956\%$. Two
numbers, a guaranteed ceiling and a sharp prediction, and an experiment that
would separate them has not yet been run.

The engineering upshot: weights at $4.8$ bits, an $8$-bit-key/$4$-bit-value
cache, and speculative decoding together give roughly one-eighth of the naive
memory footprint at a quality cost under two percent. On a CPU.

---

## What to take away

Three things.

First, **a claimed limit is a claim about a method until proved otherwise.** The
sub-six-bit floor was real, reproducible, and visible to the eye. It was also an
artefact of one quantiser at one scale, and it dissolves into a gentle convex
curve when either changes. Before you name a number as a physical constant of
your field, check whether it moves when you improve your instruments.

Second, **put your axes in the same units.** The confound between "better
quantiser" and "bigger model" looked like an unresolvable tangle. It stopped
looking that way the moment quality was measured in bits: a quantiser $2^j$ times
better is $j$ bits, block scaling with $B$ blocks buys at most $\frac12\log_2 B$
bits, and the observed $3.4$-bit shift fits inside the $4$-bit budget with room to
spare. What was a rhetorical dispute became arithmetic.

Third, **ask what a number is for.** The single sharpest predictor of whether a
tensor tolerates compression is not its size, its position in the network, or its
statistics. It is whether it is *content* — consumed by an average — or
*selection* — consumed by an $\arg\max$. Content degrades with a guaranteed
modulus of continuity. Selection has no modulus at all, and never will, because
one can always construct a configuration where an arbitrarily accurate quantiser
flips an arbitrarily consequential decision. Every cliff we have found in these
systems lives at a selection interface. Every smooth curve lives in a content
container.

That is a design principle, not just an observation: spend your bits where
decisions are made, and be generous with compression everywhere else.

---

*Caveats, stated plainly: the ladder is one model family, one held-out slice, one
family of calibrations, and per-arm standard errors were not captured. The
$-0.06\%$ at $8.5$ bits is treated as within noise, which is why it is excluded
from the multiplicative law. The comparison against the toy quantiser crosses
quantiser quality and model scale simultaneously — which is precisely why the
block-scaling budget above was computed: to show that the quality half suffices
on its own, and to hand the next experimenter a number to falsify.*
