# The Price of Forgetting: How Information Becomes a Law of Computation

## A coin, a candle, and a question

Strike a match and the flame consumes the wood. Snap a twig and you cannot
un-snap it. Pour cream into coffee and you will wait forever for it to separate
again. The physical world has a built-in arrow: some changes are easy to make
and impossible to undo. Physicists gave that arrow a name more than a century
ago — the **second law of thermodynamics** — and a quantity to measure it:
**entropy**, the amount of disorder, of unrecoverable mixing, of information lost.

Here is a question that sounds like a riddle but turns out to be a theorem.
*When a computer computes, does it obey the same law?*

When a chip adds two numbers, sorts a list, or erases a memory cell, is it
quietly paying an entropy toll — the same toll a candle pays when it burns? In
1961 a physicist at IBM named Rolf Landauer argued that it must. His claim,
now called **Landauer's principle**, is startling: *erasing one bit of
information has an unavoidable minimum cost*. Logic, he said, is physics in
disguise.

This article tells the story of a small, sharp mathematical core that turns
that intuition into provable fact. We will treat a single step of computation
not as a swirl of electrons but as a clean mathematical object — a map from one
finite set of possibilities to another — and we will measure its information
content with a single number. Then we will watch the second law of computation
fall out, step by step, as theorems. No physics lab required; just counting and
logarithms.

## States, and the number that measures them

Strip a computer down to its essence and you find **states**. Before a step
runs, the machine could be in any one of some finite collection of
configurations. After the step, it lands in another collection. A bit of memory
has two states (0 and 1). A byte has 256. A chessboard position is one of a
staggering but finite number. The machine's job is to move from state to state.

How much information does a collection of states hold? The natural unit is the
**bit**. One bit distinguishes two possibilities; two bits distinguish four;
ten bits distinguish 1,024. In general, to tell apart `N` equally likely
possibilities you need `log₂ N` bits — the base-2 logarithm of the count. This
is exactly Claude Shannon's measure of information for a uniform distribution,
and it is the heartbeat of the whole framework.

So we make one definition, and everything else flows from it. For a finite
state space `S` with `|S|` states, its **entropy** is

> **Definition (Entropy of a state space).**
> `H(S) = log₂ |S|` bits.

A single light switch (two states) has entropy `log₂ 2 = 1` bit. A byte
has `log₂ 256 = 8` bits. A machine frozen in exactly one configuration has
`log₂ 1 = 0` bits — it tells you nothing, because there was never any doubt
about where it was. That last fact is our first theorem, and it is almost a
tautology, which is the point: the definition was chosen so that *no information*
and *zero entropy* mean the same thing.

> **Theorem 1 (No states, no secrets).** If a state space has exactly one
> state, its entropy is zero: `|S| = 1 ⟹ H(S) = 0`.

And entropy is never negative, as long as there is at least one state to begin
with — you cannot have *less* than no information.

> **Theorem 2 (Information is nonnegative).** Any nonempty finite state space
> has `H(S) ≥ 0`.

These look trivial. They are the foundation stones. A theory of information cost
that allowed negative information, or that let a doubt-free machine carry
information, would be broken before it started. Ours does neither.

## Reversible computation pays nothing

Now the first surprise. Suppose a computational step is a **bijection** — a
perfect one-to-one pairing between input states and output states, with nothing
merged and nothing lost. Flipping every bit in a register is like this. So is
rotating a Rubik's cube, or running a reversible logic gate. Every output came
from exactly one input, and you could always run the film backward.

What is the entropy cost of such a step? Zero. Because a bijection cannot change
the *number* of states — it just relabels them — and entropy depends only on the
count.

> **Theorem 3 (Reversibility is free).** If there is a bijection between state
> spaces `S` and `T` (a reversible computation), then `H(S) = H(T)`.

This is the computational echo of a deep physical fact: *reversible processes
generate no entropy.* A frictionless pendulum swings forever; an idealized
reversible computer could, in principle, compute without dissipating heat. The
toll is not charged for *doing* computation. It is charged for *forgetting*. We
are about to see exactly where the meter starts running.

## Two independent machines add up

Before we get to forgetting, one more piece of bookkeeping. Run two independent
machines side by side — say a 3-bit register and a 5-bit register — and the
combined system's states are all the *pairs* of individual states. The count
multiplies: `8 × 32 = 256` joint states. But information should *add*, not
multiply: 3 bits plus 5 bits ought to be 8 bits, and indeed `log₂ 256 = 8`.

This is the magic of the logarithm, which converts multiplication into addition,
and it gives entropy its most useful structural law.

> **Theorem 4 (Independent systems add).** For two nonempty finite state spaces,
> `H(S × T) = H(S) + H(T)`.

Additivity is what makes entropy a *currency*. You can total up the information
of a complex machine by adding the information of its parts, the way you total a
bill by adding line items. Without it, "the cost of a computation" would not be
a meaningful number. With it, cost composes — and composition is what real
programs are made of.

## The second law of computation

Now the centerpiece. A deterministic computer is, at each step, a **function**:
each input state produces exactly one output state. But several different inputs
can land on the *same* output. Think of integer division that throws away the
remainder, or a hash that crushes a huge input down to a short fingerprint, or
the simple act of overwriting a variable. Many befores, one after. Information
has been *merged* — and merging is forgetting.

What happens to entropy under such a step? It can only go down (or stay the
same). A deterministic map that reaches every output — a **surjection** — cannot
manufacture information out of nothing.

> **Theorem 5 (The data-processing inequality / second law).** If a
> deterministic computation `f : S → T` hits every output state (is surjective),
> then `H(T) ≤ H(S)`.

This is the computational second law of thermodynamics, and it is exact. Reading
left to right: the output of a computation carries no more information than its
input. You cannot learn more by processing data than the data already contained.
Statisticians know this as the **data-processing inequality**; physicists know
its cousin as the second law; cryptographers feel it every time they realize a
hash cannot be inverted. Here all three are the same one-line fact about
logarithms of cardinalities.

Notice how Theorems 3 and 5 fit together. A bijection is a surjection that
*also* loses nothing, so it sits exactly on the boundary `H(T) = H(S)`.
Reversible steps live on the knife's edge of equality; every genuinely
*forgetful* step falls strictly below it. The gap between them is the entropy a
computation throws away.

## Landauer's toll, made precise

We have arrived at forgetting in its purest form: **erasure**. To erase a
memory is to take a space of many possible states and force it down to a single
known one — "reset to zero," whatever the contents were before. Every input,
no matter what it held, ends at the same place. This is the most forgetful step
imaginable.

How much entropy does erasure dissipate? If the space being erased had at least
two states — at least one genuine bit of uncertainty — the cost is *strictly
positive*. You cannot erase for free.

> **Theorem 6 (Landauer's principle).** Erasing a state space with at least two
> states (`|S| ≥ 2`) down to a single fixed state dissipates strictly positive
> entropy: `H(S) > 0`.

And we can say exactly *how much*. Erasing to a single state means the
destination has entropy zero (Theorem 1), so the entropy released is the full
entropy of the source — no more, no less — and it is never negative.

> **Theorem 7 (Exact erasure cost).** Erasing `S` to a one-state space releases
> exactly `H(S)` of entropy, and `H(S) ≥ 0`.

This is Landauer's principle stated as arithmetic. Erase a single bit and you
pay `log₂ 2 = 1` bit of entropy — the irreducible toll Landauer predicted in
1961. Erase a byte and you pay 8 bits. The principle that launched the physics
of information, the principle behind the dream of reversible "zero-energy"
computing and the design of the most efficient chips imaginable, is here a clean
consequence of counting states and taking a logarithm.

## Why this matters beyond the chalkboard

It is tempting to file these results under "elegant trivialities." That would be
a mistake. The same logic reaches into corners of modern technology that look
nothing alike.

**Green computing.** The heat your laptop throws off is, in part, the price of
all the bits it erases — overwritten registers, discarded intermediate results.
Landauer's principle sets a hard physical floor on how cool a conventional
computer can ever run, and it is why researchers chase *reversible* and
*adiabatic* logic, which by Theorem 3 can in principle compute without paying the
toll. The entropy ledger here is the same ledger engineers balance when they
design low-power hardware.

**Cryptography.** A secure hash function is valuable precisely *because* it
forgets: many messages collapse to one digest, and Theorem 5 guarantees you
cannot recover what was lost. The one-way-ness that protects your passwords is
the data-processing inequality wearing a disguise.

**Compression and error tolerance.** The same circle of ideas governs how much
you can squeeze a signal before it breaks. Consider a linear compression map `f`
that shrinks a high-dimensional codeword, and a decoder that can tolerate a
little noise. A companion result to the entropy laws makes the trade-off exact:
if the noise `e` is small (`‖e‖ ≤ δ`) and the decoder forgives any disturbance
up to `‖f‖·δ`, then compression *cannot* cause an error.

> **Theorem 8 (Compression preserves correctness).** Let `f` be a continuous
> linear compression map with operator norm `‖f‖`. If the noise satisfies
> `‖e‖ ≤ δ` and the decoder correctly recovers the message whenever the received
> point lies within `‖f‖·δ` of the true codeword, then decoding the compressed,
> noisy codeword still returns the original message.

The proof is a single chain of inequalities — the compressed noise `‖f(e)‖` is at
most `‖f‖` times `‖e‖`, which is at most `‖f‖·δ`, which is inside the decoder's
forgiveness window. This is the mathematics behind why post-quantum encryption
schemes can compress their ciphertexts and still decrypt correctly, and behind
the "decryption failure probability is zero below threshold" guarantees that
security standards demand. The operator norm `‖f‖` is the exact amplification
factor by which compression magnifies noise — a single number you can certify and
plug into a compliance argument.

## The shape of the idea

Step back and the architecture is beautiful in its economy. From *one*
definition — entropy is the log of the number of states — a whole physics of
computation unfolds:

- Information is nonnegative, and a doubt-free machine has none (Theorems 1–2).
- Reversible computation is free (Theorem 3).
- Independent systems add their information (Theorem 4).
- Deterministic computation can only destroy information, never create it
  (Theorem 5).
- Erasure costs strictly more than nothing, and exactly the source's worth of
  entropy (Theorems 6–7).

These are not metaphors borrowed from physics. They are the *same statements*,
proved from scratch about finite sets and logarithms, with the physical
interpretation riding along for free. That is the quiet thesis of
**Entropy-Bounded Computation**: computational complexity is not merely *like* a
physical law. In its informational core, it *is* one.

Landauer's slogan was "information is physical." The framework sketched here
turns the slogan into a small tower of theorems — and in doing so, it makes
something profound feel almost obvious. Every time your computer forgets, it
pays. The receipt is written in bits, and the arithmetic always balances.
