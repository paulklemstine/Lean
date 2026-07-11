# Digital Immortality: Can a Mind Be Encoded?

## The dream, and the accountant

For as long as we have feared death, we have dreamed of escaping it. The
modern version of that dream wears a lab coat: *mind uploading*. Scan a
brain in enough detail, the story goes, copy every neuron and every wire
between them into a computer, press "run," and you wake up inside a
machine — the same person, now indefinitely backed up.

It is a seductive idea, and most debates about it are about biology or
philosophy. Would the copy really be *you*? Would consciousness survive
the transfer? Those are hard, maybe unanswerable, questions. But there is
a prior question that is not philosophical at all. It is arithmetic. It is
the question an accountant would ask before signing off on the project:

**How many bits does a mind take up, and what does storing them cost?**

This article is about a clean, provable answer to that question — one that
does not depend on any theory of consciousness, only on counting and on
the laws of physics. The answer is surprisingly harsh, and surprisingly
beautiful. The information in a brain does not scale with the number of
neurons. It scales with the number of *pairs* of neurons. That single
shift — from neurons to pairs — turns a merely large number into an
astronomically larger one, and it drags the physics of any storage device
along with it.

## What actually carries your identity

Start with a deliberately crude picture of a brain. Forget chemistry,
forget timing, forget the exquisite biology. Keep only the wiring diagram:
$N$ neurons, and between any two of them, a wire that is either there or
not there. This wiring diagram is called the *connectome*, and there is a
growing scientific consensus that it is where most of "you" lives — your
memories, your habits, your particular way of being — encoded not in the
neurons themselves but in how they are connected.

Now count. How many possible wires are there among $N$ neurons? Each wire
joins a distinct *pair* of neurons, and the number of pairs is the famous
"choose two" quantity,

$$\binom{N}{2} = \frac{N(N-1)}{2}.$$

Call this the number of **synapse slots**. Each slot is a single yes/no
decision: is this connection present? A full wiring diagram is therefore
one particular pattern of yes/no answers across all the slots — like a
combination lock with $\binom{N}{2}$ switches.

The first result is a piece of pure combinatorics, but it sets the scale
for everything that follows.

> **State count.** The number of distinct wiring diagrams on $N$ neurons is
> exactly
> $$2^{\binom{N}{2}}.$$

Two raised to the number of slots. This is the size of the space of
possible minds in our stripped-down model. And because the exponent grows
like $N^2$, the number of minds grows like $2^{N^2}$ — a tower that leaves
ordinary "big numbers" far behind.

## Quadratic is the whole story

The crucial word above is *quadratic*. Let us pin it down precisely,
because the entire argument rests on it. The number of slots is squeezed
between two clean quantities:

$$(N-1)^2 \;\le\; 2\binom{N}{2} \;\le\; N^2.$$

Read this as: twice the slot count is trapped between $(N-1)^2$ and $N^2$.
The lower and upper bounds differ only in their linear correction; both
grow like the square of the neuron count. So the slot count is
$\Theta(N^2)$ — genuinely quadratic, no faster and no slower.

Why does this matter so much? Because our intuition about brains is linear.
We say "the human brain has about 86 billion neurons" as if neurons were
the unit of account. But information lives in the *connections*, and there
are quadratically many of those. If neurons number $N$, the wiring diagram
carries on the order of $N^2$ independent bits. For a human-scale $N$, the
gap between $N$ and $N^2$ is not a detail — it is the difference between a
number you can write down and one you cannot.

## You cannot compress your way out

Optimists have a ready reply: *sure, the raw wiring diagram is huge, but
real brains are structured, so surely we can compress it.* Compression is
real and powerful — it is how a two-hour movie fits on a small disk. Could
a clever enough algorithm shrink a mind down to something manageable?

Here mathematics delivers a firm no, in the worst case. Any lossless
encoding — any scheme at all that assigns each possible wiring diagram its
own distinct codeword, so that no two minds collide — must obey a counting
law. There are $2^{s}$ possible wiring diagrams, where $s = \binom{N}{2}$
is the slot count. To give each a unique codeword, you need at least
$2^{s}$ codewords. There is no way around it; this is the pigeonhole
principle in its starkest form.

> **No universal compressor.** There is no lossless encoding of the
> $N$-neuron wiring diagrams into fewer than $2^{\binom{N}{2}}$ codewords.
> Any injective scheme forces some diagram onto a codeword of numerical
> value at least $2^{\binom{N}{2}} - 1$, and therefore onto a codeword at
> least $\binom{N}{2}$ bits long.

In plain terms: **some mind will always need the full $\binom{N}{2}$ bits.**
You can compress the easy, redundant brains, but the space of possible
minds is so vast that most of them are incompressible — their shortest
description is essentially the wiring diagram itself. This is the
information-theoretic core of the result: the *minimum description length*
of a mind grows quadratically in the neuron count, and no computable
compressor can beat that in the worst case.

This is a statement about the fundamental limits of information, close in
spirit to the theory of algorithmic (Kolmogorov) complexity, which studies
the shortest program that can reproduce a given object. Most objects have
no short program; they are their own shortest description. Our theorem says
minds are, generically, exactly this kind of object.

## From bits to physics: the Bekenstein bound

So a mind needs a certain irreducible number of bits. So what? Bits sound
abstract, cheap, weightless. Here comes the twist that turns an
information-theoretic curiosity into a hard physical law.

Information is not free of physics. There is a fundamental ceiling on how
much information you can pack into a region of space with a given size and
a given amount of energy. It is called the **Bekenstein bound**, and it
comes from black-hole thermodynamics. For a region of radius $R$ enclosing
total energy $E$, the number of bits it can possibly hold is at most

$$I \;\le\; \frac{2\pi R E}{\hbar c \ln 2},$$

where $\hbar$ is the reduced Planck constant and $c$ the speed of light.
This is not an engineering limit that better technology might beat; it is a
limit imposed by quantum mechanics and gravity together. Cross it, and your
storage device collapses into a black hole.

Now combine the two ideas. Storing a mind requires at least $s = \binom{N}{2}$
bits. The Bekenstein bound says a region can hold at most $2\pi R E /
(\hbar c \ln 2)$ bits. For the region to hold the mind at all, its capacity
must exceed the requirement. Rearranging that single inequality gives a
lower bound on the physical resources:

> **Energy–radius bound.** Any region capable of storing an $N$-neuron mind
> must satisfy
> $$R \cdot E \;\ge\; \frac{\hbar c \ln 2}{2\pi}\,\binom{N}{2}.$$

And feeding in the quadratic growth of the slot count, $(N-1)^2 \le
2\binom{N}{2}$, we get the headline law:

> **Quadratic physical barrier.** For any device storing an $N$-neuron mind
> (with $N \ge 1$),
> $$R \cdot E \;\ge\; \frac{\hbar c \ln 2}{4\pi}\,(N-1)^2.$$

The product of the device's size and its energy content must grow *at least
quadratically* in the neuron count. This is the moment the argument crosses
a border: a fact about counting pairs of neurons becomes a constraint on
energy and space, enforced by the same physics that governs black holes.

## What this does and does not say

It is worth being precise about the reach of these claims, because the
subject invites overreach.

First, the model is intentionally impoverished. It records only whether
each connection exists — not its strength, not its direction, not the
neuron's internal state. That is a feature, not a bug. Because the model
*throws away* information, any more faithful model can only need *more*
bits, never fewer. The quadratic bound is a floor, and refinements raise
the ceiling. Add $b$-bit synaptic weights and directionality and the count
becomes $b \cdot N(N-1)$; let the precision itself grow with connectivity
and you climb toward $N^2 \log N$. The quadratic core never shrinks.

Second, the bound is about the *worst case* and about *most* minds. Some
special, highly structured brains might compress beautifully. But the
overwhelming majority of possible wiring diagrams cannot be shortened at
all, so any honest uploading system must budget for the full quadratic
cost.

Third — and this is the sober part — the numbers are staggering. With $N$
in the tens of billions, $\binom{N}{2}$ is on the order of $10^{21}$
connections, and the space of possible minds has $2^{10^{21}}$ elements.
The Bekenstein bound then imposes a floor on energy and size that, while
finite, is a serious constraint on any imaginable device. Digital
immortality, if it is possible at all, is not cheap, and it is not
compressible, and it is not exempt from physics.

## The shape of the idea

Strip away the science-fiction framing and a clean intellectual arc
remains. We began with a question about counting: how many wiring diagrams
are there? We found the answer is governed by *pairs*, giving a quadratic
number of bits. We showed those bits are genuinely incompressible in the
worst case — a statement about the limits of information itself. And then we
watched that abstract bit count reach out and grab the physical world,
through a bound born in the thermodynamics of black holes, forcing energy
and space to grow quadratically too.

That is the quiet thrill of this kind of mathematics: three very different
worlds — combinatorics, information theory, and gravitational physics —
turn out to be talking about the same number, $\binom{N}{2}$. Whether or
not we ever upload a single mind, the accounting is now on the books. A
mind is a quadratic object, incompressible and physically expensive, and no
amount of cleverness rewrites that ledger.
