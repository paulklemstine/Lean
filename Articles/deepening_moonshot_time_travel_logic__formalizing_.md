# The Mathematics of a Consistent Time Loop

## A grandfather, a paradox, and a fixed point

Imagine you build a time machine, travel back sixty years, and — through some
catastrophe of clumsiness or malice — prevent your own grandfather from ever
meeting your grandmother. If they never meet, you are never born. If you are
never born, you never build the time machine, never travel back, and never
interfere. So your grandfather *does* meet your grandmother, you *are* born, and
around we go again. This is the **grandfather paradox**, the most famous knot in
the logic of time travel.

For most of the twentieth century the grandfather paradox was treated as a
knockout argument: time travel into the past must be impossible, because it leads
to contradictions. But in the 1980s the physicist Igor Novikov proposed a
strikingly different resolution. Perhaps time travel is possible, he suggested,
and the universe simply refuses to realize the contradictory histories. Whatever
actually happens must be *self-consistent*: the only timelines that occur are the
ones that hang together without contradiction. This is the **Novikov
self-consistency principle**. It does not forbid the time machine; it forbids the
paradox.

That is a beautiful physical idea. But is it *mathematics*? Can we say precisely
what a "self-consistent history" is, prove exactly when one exists, and pin down
why the grandfather paradox is genuinely different from a benign time loop? The
answer, it turns out, is yes — and the whole subject collapses to one of the
oldest and most versatile ideas in mathematics: the **fixed point**.

## What is a causal loop?

Strip away the science fiction and a time loop is a very simple object. There is
a finite ring of events,

$$e_0 \to e_1 \to e_2 \to \cdots \to e_{n-1} \to e_0,$$

each one causing the next, with the last one looping back to cause the first.
Each event has a *state* drawn from some set $X$ — think of $X$ as the list of
all the ways the world could be at that moment. The causal link from one event to
the next is a rule that reads off the state of the current event and produces the
state of the next. We write this rule as a function $\text{step}_i : X \to X$: it
transports the state of event $e_i$ to the state of event $e_{i+1}$, with the
indices wrapping around modulo $n$ so that $\text{step}_{n-1}$ carries us back to
$e_0$.

We call this data — the number of events $n$, the transition rules
$\text{step}_0, \ldots, \text{step}_{n-1}$ — a **causal loop**.

Now, what does it mean to actually *live inside* such a loop consistently? We
need to assign a definite state to every event, in a way that respects all the
causal arrows *and* respects the fact that the loop closes up. Concretely, a
**consistent history** is an assignment $h$ of a state $h(k)$ to each event $k$
such that two conditions hold:

1. **Causality:** each state produces the next, $h(k+1) = \text{step}_k(h(k))$.
2. **Closure:** the assignment repeats with period $n$, so $h(k+n) = h(k)$ for
   all $k$ — event $n$ really is event $0$ again.

The Novikov self-consistency principle, made mathematical, is now the plain
assertion: *a consistent history exists.* When it does, we call the loop
**self-consistent**.

## The round trip

Here is the key move. Fix a starting state $x$ for event $e_0$ and just *let the
causality run*. The first step sends $x$ to $\text{step}_0(x)$; the next sends
that to $\text{step}_1(\text{step}_0(x))$; and so on. After following all $n$
arrows once around the ring we arrive back at event $e_0$ — but carrying whatever
state the loop has cooked up. Call that final state the **round-trip map**
applied to $x$, and write it $R(x)$.

The round trip $R$ is a single function from the state set to itself, and it
encodes the entire loop in one stroke. The whole question of consistency now has
a one-line answer.

A history is consistent exactly when going all the way around brings the initial
state back **to itself**:

$$R(x) = x.$$

Such an $x$ is called a **fixed point** of $R$. If the round trip returns $x$
unchanged, we can unroll it into a genuine, closed, contradiction-free timeline;
and if it changes $x$ into something else, the loop fails to close and no
consistent assignment starting from $x$ can exist.

This is the heart of the matter, and we can state it as a clean theorem.

> **Structure Theorem.** For any causal loop, the consistent histories are in
> exact one-to-one correspondence with the fixed points of the round-trip map. A
> history is completely determined by its value at event $0$, which must be a
> fixed point; and conversely every fixed point unrolls, via the running of
> causality, into one and only one consistent history.

The proof is almost a tautology once you see it. Running the causality forward
from any state $x$ produces a candidate history automatically; the causality
condition is then satisfied by construction. The *only* extra thing consistency
demands is that the loop close up, and — because each state is forced by the one
before — that closure happens if and only if the very first state returns to
itself after one lap. So the histories and the fixed points are two views of the
same thing, and counting one counts the other.

From the Structure Theorem the mathematical Novikov principle drops out
immediately:

> **Novikov Fixed-Point Criterion.** A causal loop admits a consistent history if
> and only if its round-trip map has a fixed point.

Self-consistency, that grand-sounding physical postulate, is *nothing more and
nothing less* than the existence of a fixed point.

## Why the grandfather paradox is really impossible

Now we can be honest about the grandfather. Model it in the simplest possible
way: one event, and a state that is either "you are born" or "you are not born" —
a single bit, true or false. The causal rule of the paradox is that being born
leads to the catastrophe that prevents your birth, and *not* being born means
nobody interferes so you *are* born. In other words, the transition rule is
logical **negation**: it flips the bit.

$$\text{step}(b) = \lnot\, b.$$

The round trip of this loop is just negation again: $R(b) = \lnot b$. Does it
have a fixed point? We would need a truth value equal to its own opposite,
$b = \lnot b$ — a state that is true exactly when it is false. There is no such
thing. Negation has no fixed point.

> **Grandfather Paradox Theorem.** The one-event loop whose causal rule negates
> the state admits no consistent history.

So the paradox is not a fuzzy philosophical worry; it is a precise, provable
impossibility. The grandfather loop is exactly a demand for a fixed point of
negation, and that demand can never be met. The universe of this loop is empty of
consistent timelines — which is precisely why, under Novikov's principle, such a
loop can never physically occur.

## Time loops that *do* close

The fixed-point picture also tells us which loops are safe. Any transition rule
with a fixed point yields a consistent history. A loop whose causal rule is the
identity — nothing changes as you go around — is trivially consistent: *every*
state is a fixed point. A loop whose rule always outputs the same value $c$
(a "constant" causal law) is consistent with the single history that sits at $c$
forever. The classic benign time-travel story — you go back, and everything you
do was always already part of history — is the fixed-point story: the timeline
you help create is the very one you came from.

## Going around more than once

There is a lovely twist. Suppose a single lap of the loop is *not* consistent —
the round trip $R$ moves your state. What if you go around **twice**, or three
times, or $k$ times? Traversing the loop $k$ times is, quite literally, applying
the round-trip map $k$ times over:

$$\underbrace{R \circ R \circ \cdots \circ R}_{k} .$$

So the $k$-times-repeated loop is consistent exactly when this $k$-fold
composition has a fixed point — that is, when $R$ has a **periodic point** of
period $k$, a state that comes back to itself after $k$ laps even if not after
one.

And now a counting miracle takes over. Suppose the state set $X$ is **finite**
and non-empty. Start anywhere and follow the round trip: $x$, $R(x)$, $R(R(x))$,
and so on. Because there are only finitely many states, this list must eventually
repeat a value — you cannot generate an endless stream of distinct states from a
finite bag. The moment a value recurs, you have found a cycle, and hence a
periodic point. This is nothing but the **pigeonhole principle**, one of the
humblest tools in mathematics, doing profound work.

> **Consistency in the Limit.** On any finite, non-empty space of states, no
> matter how paradoxical the causal rules, there is always some positive number
> of repetitions $k$ after which the loop admits a consistent history.

Even the grandfather paradox obeys this! Go around the negation loop **twice**
and you get: flip, then flip again — which returns every bit to itself. The
two-lap grandfather loop has two consistent histories: "born, unborn, born,
unborn, …" and "unborn, born, unborn, born, …". A contradiction over one lap
becomes a perfectly consistent oscillation over two. The single loop had no fixed
point, but its square does. Paradox at one scale, harmony at another.

## Counting timelines

Because consistent histories correspond one-for-one with fixed points, the
*number* of possible consistent timelines equals the number of fixed points of
the round trip. A loop can have no consistent history (the grandfather), exactly
one (deterministic time travel, where fate is sealed), or many (a loop with
genuine freedom in how it closes). This turns a metaphysical question — "how many
ways could this time loop have played out?" — into an ordinary, computable count.

## The wider view

What makes this story satisfying is not the science fiction but the compression.
An entire zoo of time-travel puzzles — the grandfather paradox, the benign
"self-fulfilling" loop, the bootstrap paradox where information seems to come from
nowhere — reduces to a single, ancient question: *does this map fix a point?*
Fixed points are everywhere in mathematics. They govern the equilibria of
economies, the stable states of dynamical systems, the solutions of differential
equations, and the convergence of algorithms. That the logic of time travel
speaks the same language is a small reminder of how few genuinely different ideas
mathematics contains — and how far each one reaches.

Novikov's principle, once a bold conjecture at the edge of physics, becomes in
this light a theorem about functions: consistency is fixedness, paradox is the
absence of a fixed point, and even paradox dissolves if you are willing to go
around the loop enough times. The universe, it seems, is a very careful
accountant of its own history — and the ledger it keeps is written in fixed
points.
