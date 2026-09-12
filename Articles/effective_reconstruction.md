# The Decoder That Cannot Be Built

## What a surveillance camera can and cannot tell you

Imagine a machine whose internal state you cannot see. All you get is a *record*: a
summary, a log line, a fingerprint, a sensor reading. Formally, there is a set $S$
of possible states, a set $M$ of possible records, and a **channel**
$$\mathrm{obs} : S \to M$$
that turns each state into the record you are allowed to see. You are interested in
some *quantity* of the state — a number $f(x)$ attached to each state $x$ — and you
would like to recover it from the record alone. That means finding a **decoder**
$$\mathrm{dec} : M \to S\text{'s answer},\qquad \mathrm{dec}(\mathrm{obs}(x)) = f(x)
\quad\text{for every state } x .$$

When is this possible? There is a beautifully simple classical answer, and it is
the first thing any student of the subject learns. A decoder exists **exactly when**
the quantity is *fibre constant*: whenever two states produce the same record, they
must have the same value of the quantity,
$$\mathrm{obs}(x) = \mathrm{obs}(y) \;\Longrightarrow\; f(x) = f(y).$$
The reason is almost tautological. If the quantity is fibre constant, then for each
record actually emitted by the channel, pick any state producing it and read off the
quantity there; the answer does not depend on which state you picked. Conversely, if
a decoder exists, then $f(x) = \mathrm{dec}(\mathrm{obs}(x)) = \mathrm{dec}(\mathrm{obs}(y)) = f(y)$
whenever the records agree. Case closed.

Except it isn't. The phrase hiding the whole difficulty is **"pick any state
producing it."**

## Picking is not free

In the real world you do not get to *pick*. You get to *compute*. A decoder is not a
Platonic function sitting in the space of all functions; it is a procedure, an
algorithm, something you can actually run. And the recipe above tells you to solve,
on demand, the problem: *given a record $m$, produce a state $x$ with
$\mathrm{obs}(x) = m$.* That is an inverse problem, and inverse problems are where
computation goes to die.

This article is about exactly how it dies, and about a surprisingly complete answer
to the question: **for which channels can the decoding recipe be made effective?**

Let us name the missing ingredient. Call a function
$$\mathrm{sel} : M \to S$$
a **uniform representative selection on the range** — a *selector*, for short — if
for every state $x$,
$$\mathrm{obs}(\mathrm{sel}(\mathrm{obs}(x))) = \mathrm{obs}(x).$$
In words: given a record that the channel really did emit, the selector hands you
back *some* state emitting that same record. It need not be the state you started
with; it only has to be in the same fibre. A selector is the machine-executable
version of "pick any state producing it."

Two sentences of algebra now give the positive half of the theory.

> **Selection gives decoding.** If a channel admits a computable selector, then
> every computable fibre-constant quantity has a total computable decoder, namely
> $f \circ \mathrm{sel}$.

Indeed $f(\mathrm{sel}(\mathrm{obs}(x)))=f(x)$ precisely because $\mathrm{sel}$ lands
in the fibre of $x$ and $f$ is constant there. Nothing more is needed. So *if* we can
effectively pick representatives, computability of the decoder comes for free.

## The three levels of "you can decode this"

Before we see the bad news, it is worth noticing how much of the classical picture
survives. Suppose the channel $\mathrm{obs}$ and the quantity $f$ are both computable
functions on the natural numbers, and $f$ is fibre constant. Then:

**Level 1 — partial computation always works.** Given a record $m$, start searching:
test $\mathrm{obs}(0), \mathrm{obs}(1), \mathrm{obs}(2), \dots$ until you hit $m$, then
output $f$ of the state you found. If $m$ was really emitted, the search terminates and
— by fibre constancy — the answer is right no matter which preimage you stumbled on.
So there is always a *partial* computable decoder, correct on every emitted record.
The obstruction is never the computing. It is the **halting**. If you feed the search
a record the channel never emits, it runs forever, and you have no way to know.

**Level 2 — approximation always works.** There is a computable two-argument table
$A(m,s)$, the *stage-$s$ approximation*, defined by scanning the states
$0,1,\dots,s-1$ and remembering the $f$-value of the last one whose record was $m$
(and $0$ if none matched). This is plainly computable. And it converges, with an
*explicit modulus*: once the stage $s$ exceeds any single state $x$ with
$\mathrm{obs}(x) = m$, the table has already locked onto the right answer,
$$A(\mathrm{obs}(x), s) = f(x) \qquad \text{for all } s > x .$$
So the decoder is always *limit-computable* — computable as a limit of a computable
sequence of guesses that change only finitely often. In the standard hierarchy of
logical complexity, decoders always sit at the second level and never higher. The
obstruction to genuine computability costs **exactly one limit**, never two.

**Level 3 — total computation sometimes fails.** And here the story turns.

## A channel that cannot be decoded

Here is the counterexample, and it is as concrete as they come. It is a channel
whose states are *traces of computations*.

Fix a standard enumeration of programs. A state is a pair $n = \langle a, s\rangle$
encoding "run program number $a$ on input $a$ for $s$ steps." The channel reports:

* if the run **halted** within $s$ steps: the record $a+1$ — "program $a$ halted on
  itself";
* if it did **not** halt within $s$ steps: the blank record $0$.

Call this the **diagonal trace channel**. Notice what the record does and does not
reveal: it tells you *which* program self-halted, but says nothing about *what it
computed*. The quantity the observer wants is precisely the missing part: the
**halting value**,
$$f(\langle a,s\rangle) = \begin{cases} v + 1, & \text{if program } a \text{ on input } a \text{ halts in } s \text{ steps with output } v,\\ 0, & \text{otherwise.}\end{cases}$$

Is this quantity fibre constant? Yes, and for a reason that feels like it *ought* to
make decoding easy: **determinism**. Two states with the same nonblank record run the
*same* program on the *same* input, differing only in how many steps they were allotted.
A deterministic machine that halts gives the same answer whenever it halts. So the
halting values agree. Two states with the same blank record both give $0$. Fibre
constancy holds, so a decoder exists — set-theoretically, and even as a partial
computable procedure, and even as a limit.

But no algorithm computes it. Suppose some total computable $\mathrm{dec}$ decoded
the halting value through this channel. Then $g(a) = \mathrm{dec}(a+1)$ would be a
total computable function that, for every self-halting program $a$, outputs
$\varphi_a(a) + 1$, where $\varphi_a(a)$ is the value that program $a$ returns on
input $a$. Now feed $g$ its own index. Since $g$ is total computable, it is program
number $a_0$ for some $a_0$, and $g$ halts on $a_0$; so the trace
$\langle a_0, s\rangle$ (for a large enough step bound $s$) is a state with record
$a_0 + 1$ and halting value $g(a_0) + 1$. Correctness of the decoder says
$$g(a_0) = \mathrm{dec}(a_0+1) = g(a_0) + 1,$$
which is absurd. **No total computable decoder exists.** Kleene's diagonal argument,
dressed as a surveillance problem.

By the positive half of the theory, running the implication backwards, this channel
also admits **no computable selector**, and — from a separate criterion — no
computable bound $b$ with the property that some preimage of $\mathrm{obs}(x)$ can be
found below $b(\mathrm{obs}(x))$. Unbounded search is unavoidable, and unbounded
search is exactly what cannot be totalised here.

## The obstruction has a name you already know

So effective decoding needs a selector. What *is* a selector, really? Here the theory
becomes clean in a way that is genuinely satisfying.

> **Effective selection is decidability of the range.** For a computable channel
> $\mathrm{obs}$, a computable selector exists **if and only if** the set of emitted
> records $\{\,m : \exists n,\ \mathrm{obs}(n)=m\,\}$ is a decidable set.

Both directions are short. If the range is decidable, run a *guarded* search: look for
a preimage, but first check whether the record is emitted at all, and bail out
immediately if it is not. The guard makes the search total. Conversely — and this is
the pretty direction — a selector *certifies* membership in the range all by itself:
$$m \text{ is emitted} \iff \mathrm{obs}(\mathrm{sel}(m)) = m,$$
and the right-hand side is a computation you can perform. So a selector *is* a
decision procedure for the range in disguise.

Meanwhile, the range of a computable channel is *always* recursively enumerable — you
can always list the records that get emitted, by dovetailing. So the whole theory
lives inside one classical dichotomy: **the emitted-record set is always
enumerable, and effective decoding is possible exactly when it is also decidable.**
Nothing else can go wrong. And since the diagonal trace channel is undecodable, we
get, as a free corollary of a *decoding* argument, the classical fact that the
self-halting set is undecidable.

This also settles when the phenomenon *cannot* happen. If the channel has **finite
rate** — only finitely many distinct records ever appear — then its range is a finite,
hence decidable, set. Selectors exist, and every computable fibre-constant quantity is
effectively decodable. All the pathology is infinitary. A finite-alphabet
information-theoretic analysis of accuracy loses nothing by ignoring definability.

## The hardest quantity of all

One question stubbornly remained. We know a selector buys you decoders for
*everything*. But could a channel be generous without being organised — could it decode
every computable fibre-constant quantity you throw at it, while still admitting no
selector? For channels that are injective the answer was known to be no, but
injectivity is a strong and unnatural hypothesis: it makes every fibre a singleton and
fibre constancy vacuous.

The resolution is to exhibit a single quantity that is *as hard as the whole decoding
problem*. Define the **canonical representative**
$$r(n) = \text{the least } m \text{ with } \mathrm{obs}(m) = \mathrm{obs}(n).$$
Three observations about $r$, each easy, and together decisive.

*It is fibre constant.* If $\mathrm{obs}(x)=\mathrm{obs}(y)$ then the two minimisation
problems defining $r(x)$ and $r(y)$ are literally the same problem, so $r(x)=r(y)$.

*It is computable.* This looks wrong at first — it is an unbounded minimisation, the
very thing we just said cannot be totalised. But the input here is a **state**, not a
record. Searching for the least $m$ with $\mathrm{obs}(m)=\mathrm{obs}(n)$ is a search
that is *guaranteed to succeed*, because $m=n$ is itself a solution. An unbounded
search that always terminates is a computable function. No guard is required.

*Any decoder for it is a selector.* If $\mathrm{dec}(\mathrm{obs}(x)) = r(x)$ for all
$x$, then $\mathrm{obs}(\mathrm{dec}(\mathrm{obs}(x))) = \mathrm{obs}(r(x)) = \mathrm{obs}(x)$,
because the canonical representative lies in the same fibre. That is precisely the
selector condition.

So $r$ is **complete** for the decoding problem on its channel: decode $r$ and you have
decoded everything. Putting the pieces together yields a four-way equivalence that
closes the theory.

> **Theorem (effective decoding, four equivalent forms).** For a computable channel
> $\mathrm{obs}$ on the natural numbers, the following are equivalent:
>
> 1. the set of emitted records is decidable;
> 2. the channel admits a computable uniform representative selection on its range;
> 3. *every* computable fibre-constant quantity has a total computable decoder;
> 4. the single quantity "the least state with the same record" has a total
>    computable decoder.

Statement (4) is the surprise. A channel that can decode one very specific, very
humble quantity — "which is the smallest state that would have looked like this?" —
can decode absolutely everything. There is no middle ground, no channel that is
partially cooperative. Effective decodability is an all-or-nothing property of the
channel, and it is a property you can state without mentioning decoders at all: is the
set of things you might see decidable?

Applied to the diagonal trace channel, completeness produces a canonical hard
instance: **given the index of a program known to halt on itself, no algorithm can
produce a trace witnessing that halting.** The existence of the trace is guaranteed;
its location is uncomputable. This is the failure of uniform effective representative
selection in its purest form.

## Being wrong, and being wrong infinitely often

"No perfect algorithm exists" is a weak statement. It is compatible with an algorithm
that is right everywhere except at one embarrassing point. The classical
information-theoretic bound of Fano says something much stronger in the finite case:
a decoder of limited rate must misreconstruct a definite *number* of configurations.
There is an effective counterpart, and it is sharp.

The engine is a **finite patching principle**, which is really the observation that a
computable function altered at finitely many inputs — altered to *arbitrary*,
even uncomputable, values — is still computable, because finitely many constants can
be hard-wired into the program. From it:

> **Repair lemma.** If a computable decoder is wrong only on records drawn from a
> finite list, it can be corrected into a *perfect* computable decoder. (Fibre
> constancy makes the correct value on each bad record well defined; patching keeps the
> result computable.)

Contrapose it, and the effective Fano bound falls out:

> **Theorem (effective Fano bound).** On a channel carrying a computable fibre-constant
> quantity with no computable decoder, *every* computable decoder is wrong on
> infinitely many records, and therefore misreconstructs infinitely many states.

For the diagonal trace channel this becomes unconditional and vivid: **every**
algorithm that attempts to recover a halting value from a halting index is wrong
infinitely often — and wrong on infinitely many *distinct records*, so the failure is
not concentrated on a handful of heavily repeated observations. The same holds for the
canonical representative: every computable attempt to compute the least state in a
fibre from the record errs on infinitely many states. In the finite theory the number
of errors is bounded below by (state count) minus (rate); here the lower bound is
simply infinity, uniformly over all algorithms.

## What the picture looks like from a distance

Three notions that the finite theory happily conflates have come apart, each with its
own exact characterisation:

| notion | what it buys | exact characterisation |
|---|---|---|
| fibre constancy of the quantity | a decoder *exists*; a partial computable one; a limit-computable one with an explicit modulus | constancy on fibres |
| uniform effective selection on the range | a *total computable* decoder, for every computable fibre-constant quantity at once | decidability of the emitted-record set |
| accuracy | how often a given decoder is right | on undecodable channels: wrong infinitely often |

And the gap between the second level and the first is exactly one limit — no more, no
less: decoders are always limit-computable, and sometimes not computable.

There is a moral here for anyone who has ever confused *"the information is present"*
with *"the information is available."* Fibre constancy is an information-theoretic
statement: the record does not conflate states with different answers, nothing has
been lost. The selector condition is an entirely different kind of statement: it says
the observer can *find their way back*. The diagonal trace channel loses nothing — the
record determines the answer uniquely — and yet delivers nothing. Determinism
guarantees the answer is well defined; diagonalisation guarantees you cannot compute
it. The information is there, perfectly preserved, and permanently out of reach.

That distinction shows up whenever someone claims a system is safe because a piece of
data "cannot be recovered," or unsafe because it "can in principle be recovered." *In
principle* and *in practice* are separated here by a precise, nameable, checkable
invariant: whether the set of things you might observe is decidable. If it is, one
uniform recipe decodes everything at once. If it is not, no algorithm decodes even the
humblest quantity, and every algorithm you write will be wrong infinitely often.

## Where this goes next

Two natural questions frame the road ahead. The first is *calibration*: the range of a
computable channel is always an enumerable set, and effective decoding is exactly its
decidability, so the difficulty of decoding a channel ought to range over the entire
landscape of enumerable degrees of unsolvability, not just the single halting
phenomenon. One expects that for every enumerable degree there is a channel whose
decoding problem has exactly that difficulty. The four-way equivalence reduces this to
a question about ranges of computable functions, where classical constructions of
simple and hypersimple sets are the natural tools.

The second is *rates of convergence*. Decoders are always limit-computable via the
canonical stage-$s$ approximation; the only question is how fast the approximation
settles. One expects a dichotomy: the decoder is computable exactly when the
convergence modulus is dominated by a computable function — and, more provocatively,
that there are channels whose modulus dominates every computable function while the
*density* of errors of the best budget-$N$ decoder still tends to zero. That would be a
channel which is uncomputable to decode and yet, statistically, almost always decoded
correctly: hopeless in the worst case, fine in practice. The whole obstruction is
concentrated in the growth rate of a single function — the least preimage — and that is
where the next theorem should live.
