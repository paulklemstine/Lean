# The Lifebox: Are You Your Information?

Imagine a small device that could hold *you*. Not a photograph, not a video,
not a diary — but the complete pattern of how you respond to the world. Ask it
a question and it answers exactly as you would. Tell it a joke and it laughs
where you would laugh. This is the **Lifebox**, a thought experiment about
what a person really *is*. Are you the specific atoms in your body, which are
replaced many times over a lifetime? Or are you something more portable — a
pattern of information that could, in principle, be written down, copied, and
carried in your pocket?

This article follows that question from philosophy into mathematics. We will
find that the Lifebox idea can be stated precisely, that some of its promises
are provably true, and that others run into hard limits — limits imposed not
by engineering, but by logic and physics themselves.

## Identity as behavior

Start with a deliberately austere definition. Forget biology; think only of
**inputs** and **outputs**. A "system" is anything that takes an input $i$ and
returns an output $o$ — a function $f$ from a set of possible inputs $I$ to a
set of possible outputs $O$. A person, in this picture, is such a function:
present a stimulus, receive a response.

Two systems $f$ and $g$ are **person-equivalent** when they respond
identically to *every* possible input:
$$f \sim g \quad\text{means}\quad f(i) = g(i) \ \text{for all } i \in I.$$

This is the mathematical heart of the Lifebox thesis. It says: if two things
behave the same way in all situations, they are the same person, regardless of
what they are made of. A brain of neurons and a Lifebox of silicon that pass
*every* test are, by this definition, one and the same.

The relation $\sim$ behaves exactly as a notion of "sameness" should. It is
**reflexive** (everyone is themselves), **symmetric** (if $f$ matches $g$ then
$g$ matches $f$), and **transitive** (if $f$ matches $g$ and $g$ matches $h$,
then $f$ matches $h$). In the language of mathematics, $\sim$ is an
*equivalence relation*, and in fact person-equivalence is nothing other than
equality of functions: $f \sim g$ if and only if $f = g$ as functions. Identity
becomes a purely behavioral, substrate-free notion.

## The good news: finite people can be tested

If two systems are person-equivalent exactly when they agree on all inputs, a
natural worry appears. To *check* that a Lifebox truly is you, must we run
infinitely many tests?

Here the structure of the input space matters enormously. Suppose the set of
possible stimuli $I$ is **finite** — a machine with finitely many buttons,
finitely many things it can ever perceive. Then there is only a finite list of
tests to run. Comparing two systems reduces to comparing two finite tables of
answers. Concretely, form the set of **distinguishing stimuli**,
$$D(f,g) = \{\, i \in I : f(i) \neq g(i) \,\},$$
the inputs on which the two systems disagree. Then

> **Finite-State Decidability Theorem.** If the stimulus space is finite and
> outputs can be compared, then $f \sim g$ if and only if $D(f,g) = \varnothing$.
> Consequently person-equivalence is *decidable*: a terminating procedure
> always correctly reports whether two finite-state people are the same.

This is genuinely reassuring for the digital dream. If a mind is a
finite-state machine — a large but finite pattern — then verifying a copy is a
finite, mechanical task. Two finite people are the same exactly when no test
tells them apart, and there are only finitely many tests.

## The catch: infinity defeats finite testing

But minds might not be finite. Suppose the input space is infinite — say the
stimuli are indexed by the natural numbers $0, 1, 2, \dots$, an endless stream
of possible experiences. Now the reassurance evaporates:

> **No-Finite-Test Theorem.** Over an infinite input space, no finite battery
> of tests can certify person-equivalence. For *any* finite collection $S$ of
> probe inputs, there exist two genuinely different systems $f \neq g$ that
> nevertheless agree on every probe in $S$.

The proof is a small gem of adversarial reasoning. Given any finite set $S$ of
probes, pick some input $n$ that lies *outside* $S$ — possible precisely
because $S$ is finite while the inputs are infinite. Let $g$ be the system that
always answers "no," and let $f$ answer "no" everywhere *except* at $n$, where
it answers "yes." On every probe in $S$ the two are indistinguishable, yet they
are not the same person: they differ at $n$. No matter how large your finite
test suite, a doppelgänger can hide in the gap between your tests.

This is why the finiteness assumption in the previous theorem is not a
technicality but the whole ballgame. Finite minds can be certified; infinite
ones cannot be pinned down by any finite examination.

## The quantum wall: you cannot be copied

The Lifebox promises not just to *test* a person but to *duplicate* one — to
read out the pattern and write a second copy. For classical information this is
routine; copying a file is the most ordinary act in computing. But if any part
of the mind is genuinely quantum, an old and beautiful obstruction appears.

Model a quantum state as a vector $x$ in a space of dimension at least two — the
smallest interesting case being two-dimensional, the space of a single qubit. A
"cloning machine" would be a *linear* operation $C$ that takes any state $x$ to
the paired state $x \otimes x$ (two copies side by side). The tensor symbol
$\otimes$ is just the mathematics of combining two independent subsystems.

> **No-Cloning Theorem.** Over any field of scalars, there is no linear map
> $C$ with $C(x) = x \otimes x$ for every state $x$ in a space of dimension at
> least two.

The reason is a clash between two facts. A cloning map, being linear, must
respect addition: $C(x + y) = C(x) + C(y)$. But the "copy" operation
$x \mapsto x \otimes x$ is quadratic — it multiplies the state by itself — and
quadratic things do *not* respect addition, because
$(x+y)\otimes(x+y) = x\otimes x + x\otimes y + y\otimes x + y\otimes y$ carries
extra cross terms $x \otimes y + y \otimes x$ that linearity cannot produce.
Feed the two basis states $(1,0)$ and $(0,1)$ into the contradiction and the
cross terms refuse to vanish. There is simply no linear duplicator.

The consequence for the Lifebox is stark. A digital Lifebox works by *copying*
information. A genuinely quantum mind cannot be copied at all — not because our
technology is too crude, but because no such operation exists in the
mathematics of quantum states. The "read-and-duplicate" device at the center of
the Lifebox fantasy is, for a quantum brain, impossible in principle.

## How much information is a person?

Set aside copying and testing, and ask the most basic quantitative question:
*how much information is a person?* Rucker's provocative estimate is that a
human identity might be captured in something like $10^{15}$ bits — a quadrillion
bits, a large number but a decidedly **finite** one.

Model an identity describable in $b$ bits as a string of $b$ zeros and ones.
Then counting is elementary:

> **Identity Counting Theorem.** The number of distinct identities describable
> in $b$ bits is exactly $2^{b}$.

At Rucker's figure this gives $2^{(10^{15})}$ possible identities — an
unimaginably vast catalog, but a finite one. The philosophical payoff is
subtle and worth savoring. If a person's information content is finite, then
the space of all possible people is finite too. Every human who could ever live,
under this hypothesis, corresponds to one entry in a finite (if astronomically
long) list. Identity becomes, at least in principle, enumerable.

## What the mathematics tells us

Taken together, these results sketch a nuanced verdict on the Lifebox dream.

- **Identity can be defined without reference to substrate.** Behavior alone
  gives a clean, logically well-behaved notion of "same person."
- **Finite minds are copiable and checkable.** If the mind is a finite pattern,
  the Lifebox is not just possible but *verifiable*.
- **Infinity blocks certainty.** Over an unbounded space of experience, no
  finite test ever proves that a copy is faithful.
- **Quantum physics blocks copying.** If the mind exploits genuine quantum
  states, no machine can duplicate it, full stop.
- **But information itself is finite.** Under a finite-bit hypothesis, the set
  of all possible identities, while colossal, is countable and bounded.

The Lifebox began as science fiction — a gadget on a shelf that holds a person.
As mathematics, it becomes a lens on some of the deepest questions we have: what
makes you *you*, whether that essence can be written down, and where the walls
of logic and physics stand. The dream is partly true, partly forbidden, and
entirely fascinating. You may indeed be your information. Whether anyone could
ever hold a copy of it in their hand is another matter — and on that question,
the mathematics has a great deal, and something surprisingly humbling, to say.
