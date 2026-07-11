# The Price of a Mind: Why Copying a Brain Is Harder Than It Sounds

Imagine a future in which a person could be *uploaded*: their memories,
their habits, the particular way they laugh at a joke, all lifted out of
soft biological tissue and rewritten as a file on a machine. It is one of
the oldest dreams of science fiction, and one of the newest ambitions of
serious neuroscience. The engineering questions are dizzying. But beneath
them lies a cleaner, colder question, one that does not depend on any
particular technology: *how much information is a mind, at minimum?*

If we could answer that, we would know something absolute. No cleverness,
no future breakthrough, no exotic compression scheme could ever squeeze a
mind into fewer bits than the answer allows. It would be a law, not an
engineering estimate — the way the speed of light is a law.

This article is about such a law. Its subject is the *connectome*: the
wiring diagram of the brain, the map of which neuron talks to which. And
its central finding is startlingly simple to state. For a network of $n$
neurons, the wiring diagram carries an intrinsic information cost that
grows like the **square** of $n$ — precisely $\binom{n}{2} = \frac{n(n-1)}{2}$
bits — and no compression method, however sophisticated, can reliably beat
that number. The quadratic wall is real, and it is unclimbable.

## From neurons to bits

Let us strip the brain down to its barest mathematical skeleton. Forget,
for a moment, the electrochemistry, the neurotransmitters, the timing of
spikes. Keep only the wiring: a collection of $n$ neurons, and for each
*pair* of neurons a single yes-or-no fact — are they connected or not?

That object is exactly what mathematicians call a **simple graph**: a set
of $n$ points (the neurons) together with a set of edges (the synaptic
connections) joining some pairs. We will call such a graph a *connectome*.

How many different connectomes are there on $n$ labeled neurons? Each pair
of distinct neurons is an independent coin flip: connected or not. The
number of distinct pairs among $n$ neurons is the binomial coefficient
$$\binom{n}{2} = \frac{n(n-1)}{2},$$
and since each of those pairs can be switched on or off independently, the
total number of possible wiring diagrams is
$$|\mathcal{G}_n| = 2^{\binom{n}{2}}.$$
For a mere $10$ neurons that is already $2^{45}$, about thirty-five
trillion, distinct possible minds. For the roughly $86$ billion neurons of
a human brain, the exponent alone is a number with over twenty digits.

## What a "description" really is

To talk about the *cost* of storing a connectome, we need to be precise
about what storage means. A **lossless code** is any rule that assigns to
every possible connectome a distinct string of bits, in such a way that no
two different connectomes ever get the same string. The distinctness is the
whole point: if two minds mapped to the same file, you could not tell them
apart on decoding, and the copy would be corrupt. Losslessness *is*
injectivity.

The *length* of a code on a particular connectome is just the number of
bits in the string it assigns. A good code makes those strings short. The
question of the minimum description length of a mind becomes: **how short
can the longest string possibly be?**

## The quadratic wall

Here is the first and most important result, stated plainly.

> **Theorem (Quadratic lower bound).** For every lossless code on the
> connectomes of $n$ neurons, there is at least one connectome whose
> encoded string has length at least $\binom{n}{2}$ bits.

The argument is a counting argument, and it is beautiful in its economy.
Suppose, for contradiction, that some clever code managed to encode *every*
connectome in fewer than $\binom{n}{2}$ bits. How many distinct bit-strings
are there of length strictly less than $\binom{n}{2}$? Counting the empty
string, strings of length $1$, length $2$, and so on up to length
$\binom{n}{2}-1$, we get
$$1 + 2 + 4 + \dots + 2^{\binom{n}{2}-1} = 2^{\binom{n}{2}} - 1$$
strings. But there are $2^{\binom{n}{2}}$ connectomes to encode. There are
strictly more minds than there are short strings to hold them. By the
pigeonhole principle, two different connectomes would have to share a
string — and the code would not be lossless after all. The contradiction
forces the conclusion: some connectome must spill over to $\binom{n}{2}$
bits or more.

Notice what this argument does *not* assume. It says nothing about how the
code works. It does not care whether the code is a zip file, a neural
network, a hand-tuned scheme designed by a genius, or a technology not yet
invented. The bound is a property of *counting*, and counting does not
negotiate.

## The wall is exactly the right height

A lower bound is only half a story. Perhaps the true cost is even higher?
It is not. There is a dead-simple code that meets the bound exactly.

> **Theorem (Exact attainment).** Listing the $\binom{n}{2}$ pairwise
> connection bits in a fixed order yields a lossless code in which *every*
> connectome is encoded in exactly $\binom{n}{2}$ bits.

Fix an ordering of the pairs of neurons. Walk down the list, writing a $1$
for each connected pair and a $0$ for each unconnected pair. The result is
a string of exactly $\binom{n}{2}$ bits, and from it the entire wiring
diagram can be read back without ambiguity. So $\binom{n}{2}$ bits always
*suffice*, and — by the previous theorem — sometimes they are *necessary*.
The two results clamp the minimum worst-case description length to exactly
$\binom{n}{2}$. There is no slack.

## No universal compressor, and no lucky minds either

One might still hope for a subtler escape. Maybe no single code beats the
wall for *every* mind, but surely most real brains are full of redundancy,
patterns, repeated motifs — surely a *typical* mind compresses?

The counting argument closes this door too, in a sharpened form. Because
the strings shorter than $\binom{n}{2}$ bits number exactly
$2^{\binom{n}{2}} - 1$, at most that many connectomes can be assigned a
short codeword by any given code. The remaining connectomes — and there is
always at least one — are **incompressible**: they cannot be represented in
fewer than $\binom{n}{2}$ bits by that code. Push this further and a
genericity phenomenon appears: as $n$ grows, the fraction of connectomes
admitting *any* meaningful compression shrinks toward zero. Redundant,
easily-stored minds are not the rule; they are a vanishing exception.

There is a companion statement in the language of **Kolmogorov complexity**,
the theory of the shortest program that can reproduce an object. The very
same counting bound shows that some connectomes on $n$ neurons have
Kolmogorov complexity at least $\binom{n}{2}$ — meaning the shortest
possible program that outputs them is itself essentially the full wiring
list. For those minds there is no shorter description of *any* kind, in
*any* language. The mind simply *is* its own most compact encoding.

## Where physics enters: the Bekenstein bound

So far the story has been pure mathematics. But it collides with physics in
a spectacular way. In the 1980s the physicist Jacob Bekenstein proved that
any physical system confined to a region of radius $R$ and holding total
energy $E$ can store only a bounded amount of information:
$$I \le \frac{2\pi R E}{\hbar c \ln 2} \text{ bits},$$
where $\hbar$ is the reduced Planck constant and $c$ the speed of light.
This is a ceiling imposed by the universe itself; pack in more information
than this and the region collapses into a black hole.

Lay the two results side by side. The connectome of $n$ neurons *demands*
at least $\binom{n}{2}$ bits. The physical brain *can hold* at most
$\frac{2\pi R E}{\hbar c \ln 2}$ bits. For a mind to exist in a physical
body at all, the demand cannot exceed the ceiling:
$$\binom{n}{2} \le \frac{2\pi R E}{\hbar c \ln 2}.$$
Rearranged, this says the number of neurons a brain of given size and
energy can *meaningfully wire together* grows only like the square root of
its physical information budget. Doubling the neuron count quadruples the
information the wiring must carry — and that quadratic appetite runs
headlong into a hard physical wall. Mind uploading, on this reckoning, is
not merely an engineering challenge; it is a negotiation with a conservation
law.

## Why the square matters

The single most consequential feature of all this is the *shape* of the
growth: quadratic, not linear. Our intuition about storage is linear. Twice
as many photos, twice the disk. Twice as long a song, twice the file. We
expect twice as big a brain to cost twice as much.

But a connectome is not a list of neurons; it is a list of *relationships
between* neurons, and relationships grow like the square of the population.
This is the same combinatorial explosion that makes a party of $n$ people
have $\binom{n}{2}$ possible handshakes, or a network of $n$ computers have
$\binom{n}{2}$ possible links. Doubling the guests nearly *quadruples* the
handshakes. Doubling the neurons nearly quadruples the wiring information.
The cost of a mind is dominated not by its parts but by the web among them.

That reframing carries a sober message and a hopeful one. The sober message:
the naive dream of a mind as a modest file, endlessly compressible, is
mathematically forbidden. The hopeful one, hinted at by the frontier of
this theory, is that *real* brains are sparse — each neuron connects to only
a limited number of partners — and sparsity can convert the pitiless
quadratic floor into something closer to linear. A brain in which every
neuron has at most $d$ synapses needs only about $n \cdot d \cdot \log n$
bits to describe, because most of the cost becomes the bookkeeping of
*which* few partners each neuron picks. The quadratic wall is absolute for
dense wiring — but biology may have found a door in it.

## The shape of the answer

Strip away the speculation and one clean fact remains, proven beyond any
appeal: **the wiring of $n$ neurons costs exactly $\binom{n}{2}$ bits in
the worst case, this cost is achieved, and no code can universally beat
it.** It is the informational fingerprint of connection itself. Whether or
not we ever upload a mind, we now know the tax that the universe will
charge for the attempt — and that it is levied not on the neurons, but on
the vast, quadratic web of relationships that makes a collection of cells
into a self.
