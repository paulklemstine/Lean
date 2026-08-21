# How Long Must You Poke a Machine Before It Betrays Itself?

## Two black boxes

Imagine two sealed boxes on a table. Each has a button — or several buttons, one per
letter of some alphabet $A$ — and a small display. Press a button, and the display
updates. Press another, and it updates again. Nothing else is visible: no wires, no
schematic, no internal state.

You are told the two boxes are supposed to behave identically. Your job is to find out
whether that is true.

The rules of the game are simple. You may press any sequence of buttons — a *word*
$w = a_1 a_2 \cdots a_\ell$ over the alphabet — and read off the display at the end.
Formally, each box is a **deterministic Moore machine**: a set of internal states $S$,
a transition function $\delta \colon S \times A \to S$ that says how a button press moves
the machine, and an output function $\lambda \colon S \to O$ that says what the display
shows in each state. Running the machine from a state $s$ along the word $w$ lands you
in a state $\delta^*(s, w)$, and the *observation* is

$$\mathrm{obs}(s, w) \;=\; \lambda\big(\delta^*(s, w)\big).$$

Two starting states $s$ (in the first box) and $t$ (in the second) are **behaviourally
equivalent** if $\mathrm{obs}(s,w) = \mathrm{obs}(t,w)$ for *every* word $w$ — including
the empty word, which just means "read the display before touching anything". If they
are not equivalent, some word $w$ makes the displays disagree; such a $w$ is a
**distinguishing experiment**.

Here is the uncomfortable part. "For every word" is an infinite quantifier. There are
infinitely many button sequences. If you press buttons all afternoon and the boxes never
disagree, have you learned anything? Or is the fatal sequence just one press longer than
whatever you tried?

This article is about the answer, and it is a genuinely satisfying one: **if the boxes
have finitely many states, you can stop after a specific, computable number of presses,
and your ignorance is over.** Not "probably over" — provably over.

## The naive bound, and why it is not naive at all

Start with the obvious idea: track both machines at once. If the first is in state $s$
and the second in state $t$, the pair $(s,t)$ is all the information that matters going
forward, because both machines are deterministic. So consider the *product* state space
$S \times T$, which has $|S| \cdot |T|$ elements.

Now define an increasing sequence of "guilt levels". Say that $s$ and $t$ are
**distinguishable within $k$ steps**, written $D_k(s,t)$, if some word of length at most
$k$ separates them. Then:

- $D_0(s,t)$ holds exactly when $\lambda(s) \neq \lambda(t)$: the displays already
  disagree before you press anything.
- $D_{k+1}(s,t)$ holds exactly when either $\lambda(s) \neq \lambda(t)$, or there is
  some button $a$ such that $D_k(\delta(s,a), \delta(t,a))$ — press $a$ once, then
  distinguish the successors in $k$ more presses.

That recursion is the entire engine. It says the levels are computed *backwards*, one
step at a time, from the raw output disagreement. Each $D_k$ is a subset of
$S \times T$, and the levels only grow: $D_0 \subseteq D_1 \subseteq D_2 \subseteq
\cdots$.

Two facts finish the job.

**Saturation.** If one level fails to add anything new — if $D_{k+1} = D_k$ — then
*nothing* is ever added again: $D_{k+j} = D_k$ for all $j$. This is not obvious, but it
follows from the one-step recursion by induction. Suppose $D_{k+1} = D_k$ and take a pair
distinguishable in $k+2$ steps. Either the outputs already differ (level $0$, done), or
some button leads to a pair distinguishable in $k+1$ steps, hence — by the stability
hypothesis — in $k$ steps; so the original pair is distinguishable in $k+1$ steps.
Repeating the argument transports stability upward forever. The chain, once it stops
growing, is frozen.

**Pigeonhole.** The chain lives inside a set of size $|S| \cdot |T|$, and it is nonempty
at level $0$ whenever the two states are inequivalent at all. So at each of the first
$|S| \cdot |T|$ levels, either the chain has already frozen, or it has strictly grown —
and it cannot strictly grow more than $|S| \cdot |T|$ times.

Put those together and you get the first theorem.

> **Theorem (Product bound).** Let $M$ and $N$ be deterministic Moore machines with
> finite state sets $S$ and $T$ over a common alphabet, and let $s \in S$, $t \in T$ be
> behaviourally inequivalent initial states. Then there is a distinguishing word $w$ with
> $$|w| < |S| \cdot |T|.$$

The consequence is the thing that makes the whole subject work:

> **Theorem (Finite test suite).** Two initial states are behaviourally equivalent if and
> only if they agree on all words of length less than $|S| \cdot |T|$.

An infinite quantifier has become a finite one. "Equivalent for all words" and
"equivalent for these finitely many words" are the same statement. Behavioural
equivalence is *decidable*: run the bounded recursion and read off the answer.

## Sharpening: the bound is really linear

The product bound is correct but generous. There is a better argument, and it changes the
shape of the answer from quadratic to linear.

The trick is to stop thinking about pairs and start thinking about *partitions*. Throw
both machines into one bag: form the disjoint union $U = S \sqcup T$, a single machine
with $|S| + |T|$ states, in which the two original machines sit side by side and never
interact. Behavioural equivalence between $s$ and $t$ in the original setting is exactly
behavioural equivalence between the two corresponding states inside $U$.

Now, for each $k$, the relation "$x$ and $y$ agree on all words of length $\le k$" is an
*equivalence relation* on $U$ — reflexive, symmetric, transitive, all obvious. And these
relations get finer as $k$ grows: $E_0 \supseteq E_1 \supseteq E_2 \supseteq \cdots$.
Each $E_k$ chops $U$ into blocks, and each refinement step chops some block into pieces.

The counting is now much better than before, and it is worth isolating as a stand-alone
combinatorial fact.

> **Theorem (Refinement stabilisation).** Let $U$ be a finite set and let
> $E_0 \supseteq E_1 \supseteq E_2 \supseteq \cdots$ be a decreasing chain of equivalence
> relations on $U$ in which $E_0$ is already non-trivial (some pair of elements is
> unrelated). Then the chain stabilises at some index $k \le |U| - 2$: that is,
> $E_k = E_{k+1}$.

*Why:* let $b_k$ be the number of blocks of $E_k$. Because $E_{k+1}$ refines $E_k$, the
operation "take a level-$(k+1)$ block and saturate it under $E_k$" maps the level-$(k+1)$
blocks *onto* the level-$k$ blocks; and this map fails to be injective precisely when the
refinement is proper — two distinct finer blocks sitting inside one coarser block. So
every proper refinement strictly increases the block count. The count starts at $b_0 \ge
2$ (non-triviality) and can never exceed $|U|$. Hence there are at most $|U| - 2$ proper
refinements, and stabilisation occurs by index $|U| - 2$.

Feed the chain of "agree up to length $k$" relations on $U = S \sqcup T$ into this
theorem and you get the sharp result. Once $E_k = E_{k+1}$, saturation (the same argument
as before) says the chain is frozen for good; and a frozen chain means every
distinguishing word, however long, can be shortened to one of length at most $k$.

> **Theorem (Moore bound).** If $s \in S$ and $t \in T$ are behaviourally inequivalent
> initial states of finite Moore machines, then some word $w$ with
> $$|w| \;\le\; |S| + |T| - 2$$
> distinguishes them.

For a single machine with state set $U$, the same statement reads: any two inequivalent
states are separated by an experiment of length at most $|U| - 2$.

And the linear bound really is stronger: for nonempty state sets one always has
$n + m - 2 < nm$, so the Moore bound implies the product bound rather than merely
competing with it.

## Is $|S| + |T| - 2$ the truth, or just the best we could prove?

It is the truth, and dramatically so — the bound is attained for *every* pair of state
counts, and already over an alphabet with a single button. This is where the story gets
pretty.

**The warm-up.** Take a *saturating counter* with $n+1$ states $0, 1, \dots, n$: each
button press advances the counter by one until it sticks at $n$, and the display reads
"true" only in state $n$. Race it against the one-state machine that always displays
"false". A word of length $\ell$ leaves the counter in state $\min(\ell, n)$, so the
displays differ precisely when $\ell \ge n$. The shortest distinguishing experiment has
length exactly $n = (n+1) \cdot 1 - 1$, and also exactly $(n+1) + 1 - 2$. Both bounds are
hit on the nose, for every $n$. In particular there can be no bound at all that does not
grow with the state counts: for any $k$ there is a machine pair whose every
distinguishing experiment has length at least $k$.

**The general construction.** Now suppose we want machines with exactly $n = n'+1$ and
$m = m'+1$ states that agree for as long as possible, namely for all words of length
$< n' + m'$, and then diverge at length exactly $n' + m' = |S| + |T| - 2$. There is one
button, so a machine's whole behaviour is just an infinite binary sequence: the display
readings at times $0, 1, 2, \dots$.

An $m$-state one-button machine can only produce a sequence that is *eventually
periodic* with period at most $m$ — in fact if you make it a pure cycle, the sequence is
periodic with period exactly $m$ from the start. An $n$-state one-button machine that
saturates at its last state produces a sequence that is arbitrary for the first $n-1$
readings and then constant forever.

So the question becomes purely about sequences: *how long can a periodic sequence of
period $m$ agree with a sequence that goes constant after $n-1$ terms, before they must
disagree?* Set $r = (n' + m') \bmod m$. Let the **cycle machine** be the $m$-cycle whose
display is "true" exactly when the cycle position equals $r$; its reading at time $\ell$
is "true" iff $\ell \equiv r \pmod m$. Let the **tail machine** be the saturating chain of
$n$ states whose reading at position $i$ copies the cycle for $i < n'$, and is "false" at
the top state $n'$.

Below time $n'$, the tail machine copies the cycle exactly, so they agree. From time
$n'$ onward, the tail machine is stuck displaying "false", while the cycle machine
displays "true" only when the time is $\equiv r \pmod m$. And here is the arithmetic
heart of it: the $m$ consecutive times $n', n'+1, \dots, n'+m'$ hit each residue class
mod $m$ exactly once, and by construction the one that hits $r$ is the very *last* of
them, $n' + m'$. So the machines agree at all times $< n' + m'$ and disagree at time
$n' + m'$ exactly.

> **Theorem (Extremality).** For every pair $(n, m)$ of positive state counts there exist
> one-button Moore machines with $n$ and $m$ states, and initial states in each, which are
> behaviourally inequivalent, agree on every word of length $< n + m - 2$, and are
> separated by the word of length exactly $n + m - 2$.

This is the automata-theoretic shadow of a classical phenomenon about periodic words: two
sequences with different periodic structure can agree for a long stretch — a stretch
whose length is governed by the periods and the preperiod — and no longer. The
Fine–Wilf periodicity theorem is the sequence-theoretic version of the same tension. What
the construction above shows is that the bound $|S| + |T| - 2$ is not an artifact of a
clumsy proof; it is exactly how much agreement a preperiod and a period can conspire to
produce.

## From "a short word exists" to "here is the checklist"

A length bound is an existence statement. Engineers want a checklist. If the alphabet
$A$ is finite, we get one for free: let $W_k$ be the set of *all* words of length at most
$k$. This is a genuinely finite set, and a straightforward count gives

$$|W_k| \;\le\; (|A| + 1)^k.$$

> **Theorem (Complete test suite).** Fix finite Moore machines with state sets $S$ and
> $T$ over a finite alphabet $A$. Two initial states are behaviourally equivalent if and
> only if they produce the same observation on every word in the finite suite
> $W_{|S| + |T| - 2}$ — a suite of at most $(|A| + 1)^{|S| + |T| - 2}$ experiments.

Note what has happened. The verification problem "do these two implementations have the
same observable behaviour?", which looked like it required checking infinitely many
scenarios, is now a *finite, explicitly enumerable* test plan whose size depends only on
the alphabet and the state counts, not on the machines' internal wiring. This is the
theoretical backbone of conformance testing for protocol implementations, of equivalence
checking for sequential circuits, and of the "distinguishing sequence" machinery used in
model-based testing.

And the suite is not padded with useless words either: if a proposed finite suite omits
even one word $w$, it is not complete in general, because one can always cook up two
behaviours that differ only at $w$ — take the behaviour that displays "true" exactly at
$w$ and the behaviour that always displays "false".

## The wall: what happens when the state set is infinite

Every positive result deserves to be measured against its own limits. Here is the limit,
and it is stark.

Drop the finiteness of the state set — allow a "machine" whose states are all the words
read so far, with the display showing an arbitrary function $f$ of the word. This *free
machine* realises **every** function $f \colon A^* \to \{\text{true},\text{false}\}$ as a
behaviour: running it from the empty word along $w$ leaves it in state $w$, so its
observation is exactly $f(w)$. Behaviours of infinite-state machines are therefore
completely unconstrained.

> **Theorem (No finite test suite).** Over a nonempty alphabet, no finite set $W$ of test
> words can separate all pairs of distinct behaviours: for every finite $W$ there are two
> functions $f \neq g$ that agree on every word in $W$.

*Why:* let $\ell$ be one more than the length of the longest word in $W$, and let $u$ be
any word of length $\ell$. Then $u \notin W$. Take $f$ constantly false and $g$ the
function that is true exactly at $u$. They agree on all of $W$ and differ at $u$.

Translated into machines: for every finite test suite there are two initial states which
pass every single test and are nevertheless behaviourally inequivalent.

Together with the positive result, this is a clean dichotomy. Fix a length bound $k$ and
the suite $W_k$. Then:

1. $W_k$ is **complete** for every pair of finite-state machines whose sizes satisfy
   $|S| + |T| - 2 \le k$ — a genuinely universal guarantee over that whole size class,
   independent of the machines' structure; and
2. $W_k$ is **incomplete** for arbitrary behaviours: two infinite-state machines pass the
   entire suite and are still inequivalent.

Finiteness of the state space is *precisely* the dividing line. It is not that
infinite-state systems are harder to test; it is that no finite amount of testing says
anything at all about them, while for finite-state systems a bounded amount of testing
says everything.

## Why this shape of theorem keeps reappearing

Step back from machines and the pattern is familiar: an infinite verification obligation
collapses to a finite one because some monotone process on a finite object must stop.
The proof idea — a chain of relations that only refines, trapped inside a finite lattice,
with a saturation lemma saying that one stall means permanent stall — is one of the most
reusable arguments in computer science. It powers minimisation of finite automata, the
model-checking of temporal logics via fixpoint computation, bisimulation checking for
labelled transition systems, and coalgebraic notions of behavioural equivalence far
beyond automata.

What makes the version here satisfying is the tightness. The abstract argument gives
$|S| + |T| - 2$. The explicit family gives machines that agree for exactly that long.
There is no gap left to close, and no room to be cleverer: the extremal examples are, in
a precise sense, the arithmetic of a preperiod meeting a period.

So: how long must you poke a machine before it betrays itself? If it has $n$ internal
states and its rival has $m$, then at most $n + m - 2$ presses — and sometimes exactly
that many, no matter how you play. After that, silence is proof.
