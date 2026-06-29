# Probability Below Zero-Width: How Infinitesimals Rescue the Impossible Lottery

## A puzzle that should not have an answer

Imagine a lottery with infinitely many tickets — one for every point on a
line segment, say the interval from 0 to 1. You want the draw to be perfectly
fair: every single ticket has *exactly* the same chance of winning, and no
ticket is impossible. And, of course, the chance that *some* ticket wins must
be a certainty — probability 1.

Classical probability theory, the kind that underlies insurance, statistical
physics, and machine learning, says flatly: **this cannot be done.** If each
of infinitely many equally likely outcomes had any positive probability *p*,
then adding up enough of them would push the total past 1, and eventually past
any bound at all. So the only "fair" assignment is to give every individual
point probability zero. The fairness is preserved, but at an absurd cost: every
ticket is, individually, *impossible*, yet one of them is guaranteed to win.
The winner is an event of probability zero that nonetheless happens.

Mathematicians have long made peace with this. Measure theory teaches us to
stop asking about individual points and to ask only about *intervals* and their
combinations. The probability of landing in the left half is 1/2; the
probability of landing on the exact midpoint is 0; and we simply agree not to be
bothered by the fact that "probability 0" and "impossible" have quietly become
different things.

But what if we refused to make that peace? What if we insisted that each point
deserves a genuinely positive probability — just an unimaginably, infinitely
small one? This article is about a concrete, fully worked-out mathematical world
where exactly that is true. In it, every point of an outcome space carries a
*positive infinitesimal* probability, finitely many of them always add to
something strictly less than 1, and the whole space still has probability
exactly 1. The paradox does not get resolved by hand-waving. It dissolves
because we change the *number system* in which probabilities are allowed to
live.

## The trouble with real numbers

The reason the impossible lottery is impossible is not really about probability.
It is about the real numbers. The real number line has a property called the
*Archimedean property*, named after Archimedes: there are no infinitely small
positive numbers. Pick any positive real number, no matter how tiny — one
billionth, one googolth, anything — and you can always add finitely many copies
of it together until the sum exceeds 1. There is no positive real number small
enough to survive that test.

That single fact is the executioner of the fair infinite lottery. If a point's
probability is a positive real number, then "enough" points overflow the budget
of 1. The escape, then, is to work in a number system that is **not**
Archimedean — a system with genuine infinitesimals, positive quantities smaller
than every ordinary positive number, which can be added to themselves a *finite*
number of times without ever reaching 1.

Such number systems are not science fiction. They appear in nonstandard
analysis (the hyperreals), in the theory of formal power series, and — most
beautifully — in John Conway's *surreal numbers*, a single magnificent ordered
field that contains the reals, the infinite ordinals, and a luxuriant garden of
infinitesimals all at once. The dream that motivates this work is a probability
theory whose values live in such a field, where "infinitely unlikely but not
impossible" becomes a precise, computable statement.

## A laboratory you can hold in your hand

Grand number systems are powerful but unwieldy. To make the idea airtight, it
helps to build the smallest possible laboratory in which the magic still
happens — a toy field with exactly *one* infinitesimal, where every claim can be
checked by elementary algebra. That is what we do here.

Consider pairs of ordinary fractions, written `(a, b)`, and read each pair as
the expression

  **a + b·ε**,

where **ε** ("epsilon") is a single positive infinitesimal. The pair `(3, 0)`
is just the ordinary number 3. The pair `(0, 1)` is ε itself. The pair `(1, -5)`
is "one, minus five epsilons" — very slightly less than 1.

Adding these pairs is the obvious thing: `(a, b) + (c, d) = (a + c, b + d)`,
exactly as if you were collecting like terms in `a + b·ε`. Subtraction and
negation work the same way.

The clever part is the **order** — deciding which of two such quantities is
larger. We use *lexicographic* (dictionary) order. To compare `(a₁, b₁)` and
`(a₂, b₂)`, first look at the ordinary parts `a₁` and `a₂`. Whichever has the
bigger ordinary part is bigger, full stop. Only if the ordinary parts are
*equal* do we break the tie by comparing the infinitesimal parts `b₁` and `b₂`.

This rule has a startling consequence. Take any positive ordinary fraction *q*,
written `(q, 0)`, and compare it to ε, written `(0, 1)`. The ordinary part of
*q* is *q* itself, which is positive; the ordinary part of ε is 0. Since
*q* > 0, the dictionary order declares `(q, 0)` strictly bigger than `(0, 1)`.
In other words:

> **ε is positive, yet ε is smaller than *every* positive fraction, no matter
> how small.**

That is exactly the defining property of an infinitesimal, and in this
laboratory it is a one-line consequence of how we chose to order pairs. In the
formal development this fact is the theorem named `eps_infinitesimal`: for every
positive rational *q*, we have ε < *q*. Its companion `eps_pos` certifies that
ε is genuinely positive (above the zero element `(0, 0)`), so ε occupies the
forbidden zone — strictly between 0 and every standard positive number — that
the real line does not possess.

## Building the impossible lottery

Now we use this infinitesimal currency to pay for a fair lottery. To keep
everything finite and verifiable, we build a whole family of models, one for
each whole number *n*, and let *n* grow as large as we like.

In the model of size *n*, the outcomes are *n* ordinary tickets — call them the
**visible atoms** — plus one special ticket we call the **reservoir**. Think of
the reservoir as a "leftover" outcome that quietly absorbs whatever probability
the visible tickets fail to use up.

The weights are assigned like this:

- **Each visible ticket gets probability ε** — a single positive infinitesimal.
  There are *n* of them, so together the visible tickets carry total weight
  *n·ε*, written as the pair `(0, n)`.
- **The reservoir gets probability 1 − n·ε**, written as the pair `(1, −n)`.

Add them up and the infinitesimal parts cancel perfectly:

  *n·ε* + (1 − *n·ε*) = 1.

The total is exactly the pair `(1, 0)` — the number 1, on the nose. This is the
theorem `prob_univ`: the probability of the entire outcome space is exactly 1.
No rounding, no limit, no approximation. The lottery is genuinely normalized.

Meanwhile, each visible ticket has a strictly *positive* probability ε, and yet
ε is smaller than every standard probability — it is below 1/100, below
1/10⁹, below any positive fraction you can name. None of the visible tickets is
impossible. Each is just infinitely unlikely. The formal statement
`visible_singleton_infinitesimal` records exactly this: the probability of a
single visible ticket equals ε, and ε is strictly less than 1.

Look at what we have achieved. We have *n* equally likely, individually possible
outcomes, plus a reservoir, and a total probability of exactly 1 — the very
configuration that the real numbers forbid. The reservoir is the secret. It is
allowed to carry a *negative* infinitesimal component (−n epsilons) while keeping
its ordinary part equal to 1. In dictionary order, anything with ordinary part 1
beats anything with ordinary part 0, so the reservoir's probability is safely
positive despite that negative infinitesimal piece. The reservoir is where the
bookkeeping deficit goes to hide, and the lexicographic order is what keeps it
honest.

## Is it really a probability measure?

A construction is only as good as the laws it obeys. A genuine probability
assignment must satisfy a short list of non-negotiable axioms, and the
laboratory passes every one of them — not by appeal to intuition, but by
explicit verification.

**Nothing has negative probability.** Every event — every collection of
tickets — receives a probability that is nonnegative in the dictionary order.
This is the theorem `prob_nonneg`. The proof splits into two cases. If the
reservoir is among the chosen tickets, the event's ordinary part is 1, which
already makes it positive. If the reservoir is absent, the ordinary part is 0
and the infinitesimal part is just the *count* of visible tickets in the event —
a nonnegative whole number times ε. Either way, no event dips below zero.

**Probabilities of separate events add up.** If two events share no tickets,
the probability of their combined event is the sum of their individual
probabilities. This is **finite additivity**, the theorem `prob_union_disjoint`,
and it is the beating heart of any probability theory. It holds here for the
cleanest possible reason: the probability of an event is *defined* as the sum of
the weights of its tickets, and the sum over a disjoint union is the sum over
each piece. Additivity is not imposed; it is inherited from honest counting.

**There is a clean formula for everything.** Perhaps the most satisfying result
is a single closed form, the theorem `prob_eq_closed_form`, that computes the
probability of *any* event at a glance. For an event *A*:

- its **ordinary part** is 1 if the reservoir is in *A*, and 0 otherwise;
- its **infinitesimal part** is the number of visible tickets in *A*, minus *n*
  if the reservoir is also present.

In symbols, the probability of *A* is the pair

  ( [reservoir in *A*? 1 : 0] , (number of visible tickets in *A*) − [reservoir in *A*? n : 0] ).

From this one formula, every other property tumbles out. Set *A* to be
everything: the reservoir is present (ordinary part 1) and all *n* visible
tickets are present, so the infinitesimal part is *n − n = 0*, giving exactly
`(1, 0) = 1`. Set *A* to a single visible ticket: ordinary part 0, infinitesimal
part 1, giving exactly ε. Set *A* to the empty event: `(0, 0)`, probability
zero. The formula is the master key.

## Why the original paradox never actually arrives

It is worth pausing on *why* this does not contradict the classical
impossibility theorem. The classical argument needs to add up the probabilities
of infinitely many points and watch the sum diverge. But in this world we only
ever add *finitely* many things at a time — that is what "finite additivity"
means. And finitely many copies of ε never reach 1, precisely because ε is a
true infinitesimal. The full interval is *not* presented as a disjoint union of
its individual points; it is presented as a finite arrangement of visible
tickets plus a reservoir. On the natural domain of *finite* combinations, the
contradiction simply never has the chance to form.

This is the deep lesson, and it points beyond the toy. In the larger program
that this laboratory models, the outcome space is the real interval [0, 1], the
value field is a rich non-Archimedean field built from formal power series (a
stand-in for Conway's surreals), and every single point of [0, 1] genuinely
carries a positive infinitesimal mass while the whole interval has mass exactly
1. The apparent paradox dissolves for the same reason it dissolves here: the
honest domain of the measure is the Boolean algebra of *finite* unions, and on
that domain [0, 1] is never a disjoint union of its points.

## Where this could lead

Once probabilities are allowed to be infinitesimal, doors open that were bolted
shut in the real-valued theory.

The most tantalizing is **conditioning on the impossible**. In classical
probability, conditioning on an event of probability 0 is the notorious "0/0"
problem — undefined, the source of endless paradoxes about random points on
spheres and lines. But in a *field* of values, an infinitesimal is a perfectly
good nonzero number, and you are allowed to divide by it. Conditioning on a
single point of mass ε becomes legal arithmetic. Ask "given that the winner is
one of these two specific points, what is the chance it is the first one?" and
the two infinitesimals cancel, leaving the sensible answer 1/2 — where the real
theory could only shrug and write 0/0.

A second door is a **standard-part map** that connects this exotic world back to
ordinary measure theory. By reading off only the ordinary (non-infinitesimal)
component of each probability, one recovers a familiar real-valued measure —
plausibly Lebesgue measure, the standard notion of length — as the "shadow" of
the infinitesimal one. The infinitesimal theory would then sit *above* classical
probability as a refinement, agreeing with it on the questions the classical
theory can answer, and saying something new on the questions it cannot.

A third is an **inclusion–exclusion law** that upgrades additivity from disjoint
events to arbitrary overlapping ones, turning the laboratory into a full Boolean
algebra of events with all the combinatorial machinery intact.

## The moral

For a century, students have been told a small lie of omission: that "an event
of probability zero" and "an impossible event" are the same thing, and that fair
infinite lotteries are forbidden. The truth is subtler and more beautiful. The
prohibition was never a law of probability — it was a limitation of the *real
numbers*. Move probability into a number system that knows about the infinitely
small, and the fair lottery snaps into existence, fully lawful: every outcome
possible, every outcome infinitely unlikely, the whole thing summing to a clean,
honest 1.

The laboratory built here is deliberately tiny — pairs of fractions, a single
infinitesimal, *n* tickets and a reservoir — but its every claim is verified
down to the last symbol, and its message is large. Probability does not have to
live on the real line. Given an infinitesimal to spend, it can afford to make
the impossible merely improbable.
