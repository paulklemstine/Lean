# How Many Thoughts Can a Brain Hold? The Hidden Geometry of Neural Codes

## A cube made of neurons

Imagine a tiny population of just three neurons. At any instant each one is
doing one of two things: firing or staying silent. Write a firing neuron as
$1$ and a silent one as $0$, and the momentary state of the whole population
becomes a short string of bits — $101$, say, or $011$. With three neurons
there are exactly $2^3 = 8$ such strings, from $000$ (total silence) to $111$
(everyone active).

This is the simplest possible model of a *neural code*: a pattern of activity
across a population of neurons that stands for some piece of information — a
color, a smell, a face, an idea. And the first question anyone asks is also the
most fundamental one in the theory of the brain as an information processor:

> **How many distinct things can $N$ neurons represent?**

The answer, in the idealized binary picture, is beautifully clean. Each of the
$N$ neurons contributes an independent yes-or-no choice, and $N$ independent
binary choices produce exactly

$$2^N$$

distinct patterns. Ten neurons already give more than a thousand possibilities;
thirty neurons give more than a billion; and the roughly eighty-six billion
neurons of a human brain give a number so large it dwarfs the count of atoms in
the observable universe. The raw representational capacity of the brain is not
the bottleneck. As a headline, *the maximum number of distinct concepts
representable by $N$ binary neurons is $2^N$.*

But raw capacity is a fantasy. Real neurons are noisy. They misfire, drop
spikes, and get jostled by the metabolic chaos of living tissue. If two
meaningful patterns differ in only a single neuron, then one stray flip turns
one thought into another. A code that uses *all* $2^N$ patterns is
maximally expressive and maximally fragile. The interesting question is not how
many patterns exist, but how many a population can safely *use* if it wants to
survive noise. That question turns out to have a precise, geometric answer — and
that geometry is the subject of this article.

## Distance is confusability

To reason about noise we need a notion of how "far apart" two patterns are. The
natural measure is the **Hamming distance**: the number of neurons on which two
patterns disagree. The patterns $10110$ and $10010$ differ in exactly one
position, so their Hamming distance is $1$; a single misfiring neuron can carry
you from one to the other. The patterns $00000$ and $11111$ differ in all five
positions, so their distance is $5$; you would need every neuron to be wrong at
once to confuse them.

Hamming distance is exactly the number of neuron flips needed to turn one
pattern into another, which makes it the right currency for noise. If a code
wants to tolerate up to $t$ misfiring neurons at once, then any two of its
meaningful patterns must be at Hamming distance **at least $2t+1$**. The reason
is a clean pigeonhole argument. Suppose every pair of codewords is separated by
at least $2t+1$. A received pattern corrupted by at most $t$ flips lands within
distance $t$ of the true codeword, and — because any *other* codeword is at
least $2t+1$ away — it stays strictly closer to the true one than to any
impostor. Decoding to the nearest codeword therefore always recovers the
intended message. We call such a collection a **$t$-error-correcting codebook**.

There is a lovely picture lurking here. Fix a codeword $c$ and collect every
pattern within Hamming distance $t$ of it — the patterns you might actually
*receive* if $c$ was sent and at most $t$ neurons misfired. This set is the
**Hamming ball** of radius $t$ around $c$. The error-correction condition says
precisely that the balls around different codewords never overlap: they pack
into the space of all $2^N$ patterns without colliding, like marbles dropped
into a box. And packing problems always come with a budget.

## Counting the marbles

Two facts turn this picture into a hard inequality.

**Every ball is the same size.** How many patterns lie within distance $t$ of a
given codeword? To be within distance $t$ you may flip any subset of at most $t$
of the $N$ neurons. The number of ways to flip exactly $k$ neurons is the
binomial coefficient $\binom{N}{k}$ — the number of ways to choose which $k$ of
the $N$ positions change — so the total ball size is

$$V(N,t) \;=\; \sum_{k=0}^{t}\binom{N}{k}.$$

Crucially this count *does not depend on which codeword sits at the center*.
The reason is a symmetry: flipping every pattern in the space by the same fixed
mask (a neuron-wise exclusive-or) slides one ball rigidly onto another while
preserving all distances. Every Hamming ball of radius $t$ is a translated copy
of every other, so they all contain exactly $V(N,t)$ patterns. When $t=0$ the
ball is a single point, $V(N,0)=1$; when $t=N$ it swallows the whole space,
$V(N,N)=\sum_{k=0}^{N}\binom{N}{k}=2^N$, recovering the fact that the binomial
coefficients of row $N$ of Pascal's triangle sum to $2^N$.

**The balls are disjoint.** This is the triangle inequality in disguise. If a
single pattern $z$ belonged to the radius-$t$ balls of two distinct codewords
$x$ and $y$, then $x$ and $y$ would each be within $t$ of $z$, and hence within
$2t$ of each other. But error correction demands they be at least $2t+1$ apart —
a contradiction. So the balls tile the pattern cube without overlap.

Now the budget writes itself. We have $|C|$ disjoint balls, each containing
$V(N,t)$ patterns, all crammed into a universe of only $2^N$ patterns. The total
volume occupied cannot exceed the total available:

$$\boxed{\,|C|\cdot\sum_{k=0}^{t}\binom{N}{k}\;\le\;2^N\,}$$

This is the **sphere-packing bound**, also called the **Hamming bound**. It is
the central theorem of this article, and it says something deep about the brain
as a physical device: *robustness is not free.* Every increment of noise
tolerance forces each meaningful pattern to claim a larger private territory, and
territory is finite. The exchange rate between reliability and capacity is
governed by the volume of a Hamming ball.

## Reading the bound

The bound is worth savoring at its extremes.

**No noise tolerance ($t=0$).** Here $V(N,0)=1$, and the inequality collapses to
$|C|\le 2^N$. This is exactly the raw-capacity headline we started with: with no
demand for robustness, a population may use all $2^N$ patterns. The
sphere-packing bound contains the naive count as its zero-noise special case.

**Single-error tolerance ($t=1$).** Now each codeword must own a ball of volume
$V(N,1)=1+N$ (the codeword itself plus the $N$ patterns one flip away). The
bound becomes

$$|C|\cdot(N+1)\;\le\;2^N,\qquad\text{i.e.}\qquad |C|\;\le\;\frac{2^N}{N+1}.$$

The price of surviving *any single misfire* is a factor of $N+1$ in capacity.
For $N=100$ neurons the population still commands about $2^{100}/101 \approx
10^{28}$ reliable patterns — a spectacular number — but it has given up a
hundredfold slice of its raw repertoire to buy that reliability. Robustness is
cheap in absolute terms and yet strictly, quantifiably costly.

This is not a vague biological intuition; it is a theorem, and it is *tight* in
the sense that it holds for every conceivable codebook with the stated distance
property, with no hidden assumptions about structure, linearity, or symmetry.
The only ingredients are counting, a symmetry that equalizes ball volumes, and
the triangle inequality.

## Why the brain should care

The sphere-packing bound is a founding result of coding theory, the mathematics
that lets deep-space probes whisper across billions of kilometers, lets a
scratched DVD still play, and lets your phone hold a call through a noisy tunnel.
Casting neural populations in the same language is more than an analogy. It says
that whatever strategy evolution has stumbled onto for representing information
in noisy tissue, it is bound by the same geometry that constrains a satellite
modem.

Neuroscientists have long observed that the brain favors **distributed,
population codes** rather than fragile "grandmother cells" that each stand for a
single concept. The sphere-packing bound gives this preference a mathematical
spine. Spreading a concept across many neurons, so that its pattern differs from
every other concept's pattern in *many* positions, is precisely the act of
keeping codewords far apart in Hamming distance — which is precisely what error
correction requires. A distributed code is a well-spaced code, and a well-spaced
code is a robust one. The geometry that protects a Mars rover's telemetry is the
same geometry that lets you still recognize a friend's face when a few thousand
neurons happen to be misbehaving.

The bound also sets an honest ceiling. It tells us that a population cannot be
simultaneously maximally expressive and maximally robust, and it quantifies the
trade — not with a hand-wave, but with a sum of binomial coefficients. If a
brain region devotes $N$ neurons to a task and must tolerate $t$ simultaneous
faults, then no matter how cleverly it arranges its patterns, it can reliably
distinguish at most $2^N / V(N,t)$ of them. That is a law, not a tendency.

## The shape of an idea

Strip away the biology and what remains is startlingly simple: a cube of bits, a
notion of distance, a fistful of non-overlapping balls, and the observation that
you cannot fit more marble than the box holds. From those humble pieces flows a
statement about the ultimate limits of representation in any noisy binary
substrate — silicon or synapse alike.

The raw capacity of $N$ neurons is $2^N$, a number of almost obscene
generosity. But the *useful* capacity, the number of thoughts a population can
hold and still trust, is smaller and sharper, carved down by the price of
reliability to $2^N$ divided by the volume of a Hamming ball. In that single
ratio lives the whole tension between richness and robustness — the eternal
bargain that any thinking machine, evolved or engineered, must strike with
noise. The brain, it seems, has been doing coding theory all along.
