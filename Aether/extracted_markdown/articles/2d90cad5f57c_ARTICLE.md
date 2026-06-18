# Cellular Automata at the Ordinals: When Computation Refuses to Stop

## A grid that thinks forever

Imagine an infinite row of light bulbs, stretching off to the horizon. Each
bulb is either on or off. A simple rule governs them: at every tick of a
universal clock, each bulb looks at itself and its two immediate neighbours,
and decides whether to be on or off in the next instant. That is all. No
central controller, no memory beyond the neighbourhood, no foresight. Just a
local rule, applied everywhere at once, again and again.

This is a **cellular automaton**, one of the most deceptively simple objects in
all of science. Conway's *Game of Life* is one. The famous *Rule 110*, which
turns out to be capable of running any computer program, is another. From these
microscopic, purely local instructions, vast and intricate behaviour emerges:
gliders that sail across the grid, factories that spawn them, logic gates,
counters, even universal computers built entirely out of blinking cells.

But every cellular automaton in the textbooks shares a hidden assumption, so
natural we rarely notice it: **time is the natural numbers**. Tick 0, tick 1,
tick 2, and so on. The clock counts $0, 1, 2, 3, \dots$ and never reaches any
kind of "end." If a pattern still hasn't settled down after a billion ticks,
we simply wait for tick a-billion-and-one.

This article is about what happens when we refuse to accept that limitation.
What if we let the clock run *past* infinity?

## The clock that counts past infinity

In ordinary arithmetic, there is no number after "all the natural numbers." But
mathematicians have a perfectly rigorous way to keep counting once the natural
numbers run out. These are the **ordinal numbers**.

The ordinals begin in the familiar way:

$$0, \; 1, \; 2, \; 3, \; \dots$$

and then, crucially, they keep going. After *every* natural number comes a brand
new number called $\omega$ ("omega"). It is not the largest natural number —
there is no such thing — it is the first number that lies *beyond* all of them.
And the ordinals do not stop there:

$$\omega, \; \omega+1, \; \omega+2, \; \dots, \; \omega\cdot 2, \; \dots, \; \omega^2, \; \dots$$

There are two flavours of ordinal. A **successor** ordinal, like $5$ or
$\omega+1$, is one that comes immediately after some other ordinal — you reach
it by taking a single step. A **limit** ordinal, like $\omega$ or $\omega\cdot 2$
or $\omega^2$, has *nothing* immediately before it. You cannot reach $\omega$ by
adding one to anything; you can only reach it by *running through the entire
infinite sequence that precedes it*.

This distinction is the whole story. At a successor stage, a cellular automaton
knows exactly what to do: apply the local rule once more. But what should it do
at a *limit* stage? There is no "previous tick" to update from. The configuration
at stage $\omega$ cannot be computed from the configuration "just before
$\omega$," because there is no such configuration.

The answer — the idea at the heart of this work — is to define the limit stage
not from a single predecessor, but from the **entire infinite history** that came
before it.

## Taking limits, cell by cell

Here is the rule. Run the automaton through stages $0, 1, 2, \dots$ in the usual
way. Each individual bulb traces out an infinite sequence of on/off values across
these stages — its personal **history**. To decide what that bulb should be at
the limit stage $\omega$, we look at its history and ask: *does it eventually
settle down?*

If a bulb is on, off, on, off, on, off forever, it never settles, and the limit
is genuinely ambiguous. But if a bulb is, say, off for a while and then turns on
and *stays* on — off, off, off, on, on, on, on, $\dots$ — then there is an
obvious value to assign at stage $\omega$: **on**. The bulb has made up its mind,
and the limit stage simply records the decision.

We make this precise with a notion we call *eventual constancy below a stage*. A
history $h$ is **eventually constant below $\lambda$ with value $v$** if there is
some earlier stage $\beta$ (still below $\lambda$) past which the history is
always equal to $v$:

> there exists $\beta < \lambda$ such that for every $\gamma$ with
> $\beta \le \gamma < \lambda$, we have $h(\gamma) = v$.

The first thing one must check is that this is not self-contradictory: a history
cannot settle on two *different* answers. And indeed it cannot. If a history is
eventually $u$ and also eventually $v$, then far enough along it must equal both
$u$ and $v$ at the same stage — so $u = v$. This is our first rigorously
established fact:

> **Uniqueness of limits.** If a coordinate's history is eventually constant
> below $\lambda$ with value $u$, and also eventually constant with value $v$,
> then $u = v$.

Now apply this cell by cell. Suppose that at a limit stage $\lambda$, *every*
bulb's history has settled down. Then there is one and only one configuration of
the whole grid whose value at each cell is that cell's eventual value. This is
the **limit configuration**, and it is the genuinely new ingredient that lets a
cellular automaton survive the passage through infinity:

> **Limit stages exist and are unique.** If every cell's history is eventually
> constant below the limit stage $\lambda$, then there is a *unique* whole-grid
> configuration realizing all of those eventual values simultaneously.

This theorem is the foundation. It tells us that whenever the histories behave
well — whenever every bulb eventually makes up its mind — the automaton can be
continued past $\omega$, past $\omega\cdot 2$, in principle all the way up the
ordinals, and there is never any ambiguity about what the next limit looks like.

## When every cell is guaranteed to settle

A skeptic will object: that is a big "if." Why should every bulb's history settle
down? In general it need not — the blinking on/off/on/off bulb is a permanent
counterexample. So the interesting question becomes: **which rules guarantee that
the histories settle, so that the limit stage is always well-defined?**

There is a beautiful and broad class of rules for which the answer is "always,"
and the reason is a one-word idea: **monotonicity**.

Call a rule **inflationary** if it can only ever turn bulbs *on*, never off.
Formally, for every configuration $c$ and every cell $n$,

$$c(n) \le (F\,c)(n),$$

where we order the two states by $\text{off} < \text{on}$. An inflationary rule
is a ratchet: once a light comes on, it stays on.

Now watch what happens to a single bulb across the stages $0, 1, 2, \dots$. Its
history can only climb: it might be off for a while, but the moment it turns on it
is on forever. A history that only ever climbs from off to on is what
mathematicians call a **monotone** Boolean sequence, and such a sequence has the
simplest possible long-term behaviour:

> **Monotone Boolean sequences settle.** A sequence of on/off values that never
> decreases is eventually constant: it is off for a finite stretch and then on
> forever (or off the whole time).

The proof is almost a tautology, which is exactly why it is so powerful: either
the bulb turns on at some first stage $N$ — after which it is pinned at on — or it
never turns on, in which case it is off forever. Either way, it settles.

Chain these facts together. An inflationary rule makes every history monotone;
every monotone history settles; and when every history settles, the limit stage
exists and is unique. We arrive at the central existence theorem:

> **The $\omega$-limit exists.** For *any* inflationary rule $F$ and *any* starting
> configuration, the cell-by-cell histories of the iterates
> $c, \; F c, \; F^2 c, \; \dots$ are all eventually constant, so the $\omega$-stage
> configuration exists and is unique.

This is not an empty abstraction. It applies to a concrete, recognizable
automaton. Consider the **OR rule**: a cell turns on if it, or either of its
neighbours, is on. In symbols,

$$(\text{OR-step}\,c)(n) = c(n-1) \;\text{OR}\; c(n) \;\text{OR}\; c(n+1).$$

This rule models the spread of an unstoppable contagion across the row: switch on
a single bulb, and the "on" region grows by one cell in each direction at every
tick, advancing forever outward but never retreating. The OR rule is plainly
inflationary — it never switches anything off — so our theorem applies verbatim:

> **The OR automaton has a well-defined $\omega$-stage.** Running the OR rule from
> any initial pattern, every cell eventually turns on (or stays off forever if no
> "on" ever reaches it), and the limit configuration at stage $\omega$ exists and
> is unique.

For the OR rule the $\omega$-stage has a vivid meaning: a cell is on at stage
$\omega$ exactly when it would *ever* be reached by the spreading contagion. The
limit stage performs, in a single transfinite leap, a computation that no finite
number of ordinary ticks could finish — it answers the question "will this cell
ever light up?" for *all* cells at once.

## Why the leap past infinity matters

This is where the story connects to one of the deepest themes in the theory of
computation. An ordinary computer, in the mathematical idealization known as a
Turing machine, can run for any finite number of steps. But there are perfectly
well-posed questions it can never settle — most famously, *the halting problem*:
will a given program eventually stop, or run forever? No finite computation can
answer this in general, because to answer "no, it runs forever" you would have to
watch infinitely many steps.

In the 1990s, the logicians Joel David Hamkins and Andy Lewis proposed a daring
fix: the **Infinite Time Turing Machine**. It is an ordinary machine, but it is
allowed to run for transfinitely many steps. At limit stages, each memory cell is
set according to the *limit* of its past values. With this extra power, the
machine can simply run a program for $\omega$ steps and read off, at stage
$\omega$, whether it ever halted. Questions hopelessly beyond ordinary computers
become decidable. This is the realm of **super-Turing**, or **hypercomputation**.

The transfinite cellular automaton is the same revolutionary idea, transplanted
from the centralized, tape-and-head world of Turing machines into the radically
decentralized world of cellular automata. The limit rule "each cell takes the
limit of its history" is exactly the cellular analogue of the Infinite Time
Turing Machine's limit rule for its tape cells. And the theorems above are the
rigorous guarantee that this analogue is *coherent* — that the limit stages
genuinely exist and are unambiguous whenever the dynamics is well-behaved.

There is a striking tension lurking here, and it is worth naming. For a *nice*
(inflationary) rule, the $\omega$-stage adds nothing truly new: every cell has
already settled at some finite stage, so stage $\omega$ merely tallies the
verdicts. The transfinite machinery quietly *collapses* back to ordinary
computation. The genuinely super-Turing power lives at the boundary — in rules
whose histories *never* settle on their own, where the limit rule must *impose* a
verdict that no finite stage ever reached. The blinking on/off/on/off bulb is the
seed of that power: a finite computer sees only endless oscillation, but a
transfinite limit rule can be designed to read a definite answer out of it at
stage $\omega$. Distinguishing these two regimes — when the leap past infinity is
free, and when it is genuinely creative — is the frontier this work opens.

## Climbing higher: $\omega$, $\omega\cdot 2$, and $\omega^2$

Why stop at $\omega$? The limit-stage theorem is not special to $\omega$; it works
at *any* limit ordinal. Once you have passed $\omega$, you keep applying the local
rule — stages $\omega+1, \omega+2, \dots$ — until you reach the next limit,
$\omega\cdot 2$, where you take limits again. Then onward to $\omega\cdot 3$, and
so on through every $\omega\cdot k$, and finally to $\omega^2$, the limit of all of
them.

Each limit stage is a fresh opportunity to extract information that the stages
below could not finish computing. Stacking these opportunities suggests a
*hierarchy*: a computation that needs one transfinite leap, versus one that needs
two, versus one that needs $k$. The conjecture motivating future work is that
these levels are genuinely distinct — that there are automata whose answer first
crystallizes only at stage $\omega\cdot k$ and not a moment sooner, so that
running on the timeline $\omega^2$ is strictly more powerful than running on any
$\omega\cdot k$. The ordinal $\omega^2$ would then sit at the top of an infinite
tower of computational power, each floor built from a single trip past infinity.

## The view from the top

Strip away the formalism and a simple, almost philosophical, picture remains.
Computation, we usually think, is something that happens *in time*: step follows
step, and the answer arrives — if it arrives at all — after finitely many of them.
The transfinite cellular automaton challenges that picture at its root. It says:
let time itself be richer. Let it have *limit moments*, points reached not by one
more step but by the accumulated weight of an entire infinite past. At those
moments, ask not "what did the last step produce?" but "what did the whole history
converge to?"

The mathematics shows this can be done coherently. Whenever the histories settle —
and for an enormous, natural class of rules they always do — the limit stages
exist, they are unique, and the automaton glides through infinity without
stumbling. A humble row of light bulbs, governed by nothing more than "look at
your neighbours," can be made to compute not just for all time, but *beyond* it.

And in that beyond lies the answer to questions that no finite machine, running on
ordinary time, could ever resolve.
