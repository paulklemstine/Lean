# How Many Thoughts Can a Brain Hold? The Hidden Arithmetic of Neural Codes

Imagine a wall of light switches. Flip some up, leave others down, and each
arrangement means something — a face you recognize, a word you're about to say,
the smell of rain. With just a handful of switches you can spell out a
surprising number of distinct messages. With a hundred, the number becomes
astronomical. This is, in a stripped-down but startlingly accurate cartoon, how
populations of neurons carry information: each cell is roughly *on* (firing) or
*off* (silent), and a pattern of on-and-off cells is a **neural code** for
whatever the brain is representing at that instant.

The question that has haunted neuroscience since its beginnings is deceptively
simple: **how much can such a system say?** And, just as importantly, how much
can it say *reliably*, when neurons are noisy, unreliable, and metabolically
expensive to fire? This article tells the story of a compact chain of theorems
that answers those questions with the crisp certainty of pure mathematics, and
reveals that the brain's coding budget is squeezed from two entirely different
directions at once.

## The raw capacity: a doubling law

Start with the counting. A population of $N$ neurons, each either active or
silent, can be in exactly

$$2^N$$

distinct states. This is the **capacity** of the code. It is not an
approximation or a bound — it is an exact count of the binary patterns
available. The consequence is a *doubling law*: **every additional neuron
doubles the number of representable concepts.** Ten neurons give a thousand
patterns; twenty give a million; a mere three hundred neurons could in principle
label more concepts than there are atoms in the observable universe. The brain's
representational headroom is not a scarce resource — it is spectacularly,
exponentially abundant.

If that is so, why do real brains fire so *sparingly*? On average, across all
$2^N$ possible patterns, exactly half the neurons are active, so the "typical"
dense pattern costs

$$\frac{N}{2}$$

spikes. Spikes are expensive: the brain is a few percent of body mass but burns
a fifth of its energy, much of it on electrical signaling. Firing half your
neurons for every thought is a metabolic extravagance. Evolution, it turns out,
prefers a thriftier dialect.

## The economy of sparseness

Suppose we insist that only $k$ of the $N$ neurons fire at once — a **sparse
code** of weight $k$. How many concepts can we still name? Exactly the number of
ways to choose $k$ neurons out of $N$:

$$\binom{N}{k}.$$

Here a beautiful efficiency emerges. The natural currency is *bits per spike*:
how much information each expensive action potential buys. A weight-$k$ code
carries $\log_2 \binom{N}{k}$ bits using $k$ spikes, so its efficiency is

$$\frac{\log_2 \binom{N}{k}}{k}.$$

The extreme case is the **one-hot code**, where exactly one neuron fires
($k = 1$). It names $N$ concepts with a single spike, for an efficiency of
$\log_2 N$ bits per spike. As the population grows, this *grows without bound* —
it is a $\Theta(\log N)$ advantage over dense coding, where each spike buys only
a constant amount of information. This is the mathematical heart of why "grandmother
cells" and sparse population codes are not a quirk but an optimum: **sparseness
is how a brain buys the most meaning per calorie.**

## Strength in numbers: the $1/\sqrt{N}$ law

Neurons are noisy. A single cell's estimate of, say, the angle of a line in your
visual field is jittery and unreliable. The classical remedy is to average many
noisy voices. If each of $N$ neurons gives an independent estimate with variance
$v$, the population average has variance

$$\frac{v}{N},$$

so its precision — the reciprocal of the standard deviation — improves as

$$\frac{1}{\sqrt{N}}.$$

Quadruple the neurons and you halve the error. This **population-coding
precision law** is why the brain can extract exquisitely accurate signals from
notoriously sloppy components, and it is the same $1/\sqrt{N}$ that governs
opinion polls, laboratory measurements, and the wisdom of crowds.

## Thoughts live on a low-dimensional stage

Modern recordings show that when thousands of neurons are active, their joint
activity does not wander freely through the full $2^N$-dimensional space. Instead
it clings to a thin, low-dimensional surface — a **neural manifold**. Why? Behavior
has only so many independent knobs (degrees of freedom): the joints of an arm,
the parameters of a planned movement. If neural activity is generated from those
few behavioral variables, then no matter how many neurons you record, the *rank*
of the activity — the number of genuinely independent directions it explores —
cannot exceed the number of behavioral degrees of freedom. In symbols, the
manifold dimension is bounded by the behavioral rank. The apparent complexity of
a million-neuron dataset collapses to the handful of variables the animal is
actually controlling. This **neural-manifold rank bound** is the theoretical
backbone of the "everything is low-dimensional" revolution in systems
neuroscience.

## The twist: coding *reliably* costs capacity

So far the story has been about abundance. But abundance assumes noiselessness.
Real neurons flip: a cell that should fire stays silent, or fires spuriously. If
two concepts are encoded by patterns that differ in only one neuron, a single
flip turns one thought into another. To be robust, the codewords we actually use
must be spread apart — they must differ in *many* neurons.

The right way to measure "differ in many neurons" is the **Hamming distance**:
the number of neurons on which two patterns disagree. A codebook has **minimum
distance $d$** if every pair of distinct codewords disagrees in at least $d$
places. Such a code still tells its concepts apart after up to $d-1$ adversarial
flips, and decodes them correctly after up to $\lfloor (d-1)/2 \rfloor$ flips.
Distance is armor against noise.

Armor is not free. Here is the surprisingly sharp result — a neural incarnation
of the classical **Singleton bound**:

> **Singleton bound.** Any codebook on $N$ neurons with minimum distance $d$
> (where $1 \le d \le N+1$) contains at most
> $$2^{\,N+1-d}$$
> codewords.

The proof is a small marvel of economy. Cover up any $d-1$ of the neurons — just
ignore them. Two codewords that looked different could now only have differed in
the $d-1$ hidden neurons, meaning their true distance was at most $d-1$, *below*
the minimum $d$. That's impossible unless they were the same codeword to begin
with. So the codewords remain distinct even when you only look at the
$N+1-d$ visible neurons — and there are only $2^{N+1-d}$ ways to fill those in.
The whole codebook fits inside that smaller wall of switches. Capacity is
controlled not by how tightly you can pack the patterns, but by how few
coordinates it takes to *tell them apart*.

## The exchange rate of robustness

Translate this into the language a neuroscientist cares about. To correct up to
$t$ neuron flips, a code needs minimum distance at least $2t+1$. Feed that into
the Singleton bound and the abundance of $2^N$ patterns collapses to

$$2^{\,N-2t}.$$

This is a clean **exchange rate**: *each error you want to correct costs you two
neurons of raw capacity.* Want single-flip correction? Sacrifice two neurons'
worth of patterns. Want to survive ten flips? Pay twenty. The exponential wealth
of the neural code is real, but noise-tolerance is a tax levied directly on the
exponent.

The same result restated in classical coding terms says that a code carrying $k$
message bits obeys $k \le N + 1 - d$, so its **redundancy** $N - k$ is at least
$d - 1$: you must "waste" at least $d-1$ neurons to buy minimum distance $d$.
Reliability and richness pull in opposite directions, and the Singleton bound
quantifies the tug-of-war exactly.

## Tight at both ends

A bound is only as impressive as its sharpness, and this one is sharp at both
extremes of the distance scale.

- **No robustness ($d = 1$).** Here $2^{N+1-1} = 2^N$: the full set of all
  patterns achieves the bound. Zero noise-tolerance recovers the raw capacity
  exactly. The two theories agree at the boundary.

- **Maximum robustness ($d = N$).** Consider the **repetition code** with just
  two words: all neurons silent, and all neurons firing. These disagree in every
  one of the $N$ neurons, so the minimum distance is $N$, and the bound reads
  $2^{N+1-N} = 2$ — attained exactly by those two codewords. This is the neural
  version of shouting the same bit through every channel at once for maximum
  safety.

Because the bound is met with equality at both $d = 1$ and $d = N$, no formula
depending only on the number of neurons and the minimum distance can do better.
The ceiling is not merely an upper estimate — it is the true shape of the
trade-off.

## Two ceilings, one cube

There is a deeper moral. A companion line of reasoning — the **sphere-packing**
(Hamming) bound — limits capacity by *volume*: each codeword must own a private
ball of nearby patterns that no other codeword may enter, and only so many
disjoint balls fit inside the space of all patterns. The Singleton bound limits
capacity by *projection*: spread the codewords far enough apart and a few
coordinates already pin down which one you have.

These are genuinely different obstructions — one metric and geometric, one
linear-algebraic — yet both descend to the same raw capacity $2^N$ when noise
tolerance drops to zero. A noise-tolerant neural population is therefore
squeezed from two sides at once: it cannot pack its concepts too densely, and it
cannot spread them too thinly without a handful of neurons giving the whole game
away. Between these two walls lies the true design space of a robust brain — a
space whose exact dimensions we can now write down.

## Why it matters

The arithmetic here is elementary in its ingredients — counting patterns,
measuring disagreements, hiding a few coordinates — but the conclusions reach
into the biggest questions about brains and machines. They explain why neural
populations are astronomically expressive yet metabolically sparse; why
averaging tames noise at a predictable rate; why million-neuron recordings look
low-dimensional; and why buying reliability against noise costs capacity at a
fixed, unforgiving exchange rate. The same mathematics governs the error-correcting
codes in your phone, the redundancy in your DNA, and — if these models are right
— the way a wall of a hundred billion switches manages to hold a mind.
