# Counting to Infinity, Twice: How Simple Rules Reach Beyond the Computable

Imagine a strip of light bulbs stretching off to the horizon, each either on or
off. At every tick of a clock, each bulb decides its next state by glancing at
itself and its two immediate neighbors. That is the entire universe of an
*elementary cellular automaton* — no memory, no long-range wires, no central
controller. And yet one particular choice of the "glance-and-decide" table,
famously known as **Rule 110**, is powerful enough to simulate any computer
program that has ever been written or ever will be. It is *Turing complete*: a
row of bulbs, updated by a three-cell rule, is a universal computer.

That is where the usual story ends. This article is about what happens when we
refuse to stop the clock.

## The clock that never ends — and then keeps going

Ordinary computation lives on the natural numbers $0, 1, 2, 3, \dots$. You take
a step, then another, then another. No matter how long you run, you are always
at some finite time $n$. The trouble is that many natural questions are *about*
the whole infinite run: Does this bulb ever settle down? Does this pattern
repeat forever? These are questions about the limit of the process, and the
finite clock can never quite arrive there.

The mathematics of the infinite gives us a way to *pass through* a limit and
keep counting. After all the finite stages $0, 1, 2, \dots$ comes a new stage,
traditionally called $\omega$ ("omega"), the first *infinite ordinal*. And
crucially, $\omega$ is not the end — we can keep going: $\omega + 1$, $\omega
+ 2$, and eventually a second limit $\omega + \omega = \omega \cdot 2$, and
then a third, and a fourth. Stacking infinitely many of these infinite blocks
on top of each other gives the order type

$$\omega^2 \;=\; \underbrace{\omega + \omega + \omega + \cdots}_{\omega \text{ copies}},$$

the natural home for a computation that runs for infinitely long, takes stock,
runs infinitely long again, takes stock again, and repeats this *infinitely
many times*.

The clean way to picture $\omega^2$ is as a pair of counters $(\text{block},
\text{tick})$, ordered like words in a dictionary: first compare blocks, and
only if the blocks agree do you compare ticks. The tick counter races through
$0, 1, 2, \dots$ within a block; when it has exhausted all finite values, the
block counter advances by one and the ticks reset. Two infinities, nested.

## Two kinds of time, two kinds of law

The heart of the story is a simple but far-reaching observation: a computation
indexed by $\omega^2$ obeys **two different laws**, one for each kind of moment.

- **Successor moments** — going from tick $n$ to tick $n+1$ inside a block —
  are governed by an ordinary local update. Nothing exotic happens; you just
  apply the rule once more. For our light bulbs, this is exactly Rule 110
  glancing at three neighbors.

- **Limit moments** — the very start of a fresh block, sitting just past the
  end of an entire infinite run — cannot be reached by "one more step,"
  because there is no last tick to step from. Instead, the state at a limit
  moment is decided by a **limit rule** that is allowed to inspect the *entire
  infinite history* of the block that just finished.

This split is the secret. Locality — the three-neighbor glance — is a
successor-moment phenomenon. It is perfectly happy to survive into the
transfinite world: if two configurations agree on a cell and its two neighbors,
their Rule 110 updates agree at that cell, at every transfinite time, exactly as
they do at finite times. The limit rule is where genuinely new power can enter,
because reading an unbounded history is something no single local step can do.

To make this precise we adopt a two-layer machine. A *successor law* is any map
$\text{step}: S \to S$ on the space $S$ of configurations; a *limit law* is any
functional $\text{limit}: (\mathbb{N} \to S) \to S$ that turns a complete
$\omega$-history into the configuration that opens the next block. The run
$R: \mathbb{N} \times \mathbb{N} \to S$ is then defined by
$$R(0, n) = \text{step}^n(\text{initial}), \qquad
  R(k+1, n) = \text{step}^n\big(\text{limit}(R(k, \cdot))\big).$$
Two structural facts fall out immediately and hold for *every* choice of laws:
each successor tick really does apply the step, $R(k, n+1) = \text{step}(R(k,
n))$, and each block boundary really is the chosen limit of the previous block,
$R(k+1, 0) = \text{limit}(R(k, \cdot))$. Inside any single block the run is just
ordinary iteration, $R(k, n) = \text{step}^n(R(k, 0))$ — so the transfinite
model is a faithful *extension* of finite computation, not a replacement for it.

## Smuggling an oracle through the boundary

Now for the payoff. Fix any infinite sequence of yes/no answers — any Boolean
predicate $P: \mathbb{N} \to \{\text{true}, \text{false}\}$. Think of it as an
*oracle*: a black box that, when asked question number $k$, replies $P(k)$. Some
oracles encode perfectly ordinary computable facts; others encode famously
*uncomputable* ones, like "does the $k$-th computer program eventually halt?"

We wire this oracle into the limit law. Our limit rule, at the boundary that
opens block $k+1$, wipes the tape clean and writes a single bit — the oracle's
answer $P(k)$ — into cell zero:
$$\text{limit}_P(\text{history})(i) = \begin{cases} P(k) & i = 0, \\
  \text{false} & i \neq 0. \end{cases}$$
Everywhere else, and at every successor tick, the machine runs plain Rule 110.

Read the single distinguished cell at each block boundary and you get back
exactly the oracle's answers. The boundary right after block $k$ reports $P(k)$,
on the nose — the *boundary trace* of the run reconstructs the whole predicate
$P$. And because the boundary faithfully records the oracle, **different oracles
must produce different histories**: the map sending a predicate to its
transfinite Rule 110 history is injective. A single fixed local rule, run on
$\omega^2$ with an oracle-reading limit law, hosts a perfect, one-to-one copy of
the *entire* space of Boolean oracles.

## How big is that space? Exactly the continuum

The space of Boolean predicates is not merely infinite; it is *uncountably*
infinite. This is Cantor's diagonal argument in its purest form. Suppose someone
hands you a list $E_0, E_1, E_2, \dots$ claiming to enumerate every predicate.
Build a new predicate $D$ that disagrees with $E_n$ on question $n$: set $D(n) =
\text{not } E_n(n)$. Then $D$ differs from every $E_n$ somewhere, so it is
missing from the list. No enumeration can be complete — the predicates cannot be
counted off by the natural numbers.

Because the boundary trace turns any hypothetical enumeration of *histories* into
an enumeration of *predicates*, the same diagonal blow lands on the histories:
**no countable list can exhaust the transfinite Rule 110 histories either.**

We can say exactly how many there are. Each history is pinned down by its
oracle, and the oracles are the functions from $\mathbb{N}$ to a two-element set,
of which there are $2^{\aleph_0}$ — the cardinality of the continuum, written
$\mathfrak{c}$, the same size as the set of all real numbers. So the family of
scheduled Rule 110 histories has cardinality *exactly*
$$\mathfrak{c} = 2^{\aleph_0}.$$
A three-cell rule, given two nested infinities of time, realizes a continuum's
worth of distinct behaviors — one for every real number, one for every oracle,
computable or not.

## What this does, and does not, claim

Honesty about the boundary between the possible and the merely-hoped-for is part
of the mathematics. The results above establish **oracle capacity**: once you
allow an unrestricted limit law that can read an entire infinite history, a
fixed radius-one rule like Rule 110 can carry a faithful copy of every Boolean
oracle, including uncomputable ones. This is a genuine passage beyond the
Turing-computable — the boundary trace can be a function no ordinary computer
could ever produce.

What the results do **not** claim is that Rule 110 *manufactures* uncomputable
information out of computable data. The oracle $P$ enters as external input; the
limit law is handed the answers, it does not derive them. The magic, so to
speak, is smuggled in at the limit. Whether a *canonical*, computable limit
convention — such as taking the eventual (limsup) value of each cell across the
infinite history — already breaks past the Turing barrier is a beautiful open
question, and one this framework is designed to pose sharply.

## Why it matters

The appeal of this picture is that it pinpoints, with surgical clarity, *where*
super-Turing power can and cannot come from. Locality is innocent: the
three-cell glance survives into the transfinite unchanged and never, by itself,
reaches past the computable. All the leverage lives in the limit rule — in how a
machine summarizes an infinite past before starting its infinite future. That is
a lesson that echoes far beyond cellular automata, into the theory of infinite-
time computation, the logic of the transfinite, and the perennial question of
what it would even mean to "finish" an endless task. Two counters, two laws, and
a continuum of possibilities: sometimes the deepest ideas really do come from
learning to count to infinity — and then keeping right on counting.
