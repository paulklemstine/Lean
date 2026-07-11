# The Hidden Geometry of Reputation: How Credit Scores Fall onto a Cantor Dust

Imagine a society that keeps score. Every citizen carries a number — a *social
credit score* — that rises when the system approves of them and falls when it
does not. It sounds like a purely political idea, or a science-fiction dystopia.
But strip away the politics and ask a mathematician's question: *what shape does
the space of all possible scores actually have?* The answer is stranger and more
beautiful than one might expect. Under a natural model, reputations do not spread
smoothly across a range of values. They condense onto a **Cantor set** — an
infinitely intricate "dust" of points, riddled with gaps, where the smallest
nudge to a single early judgment can hurl a person across an unbridgeable chasm.

This article tells that story. It is a story about attractors, self-similarity,
and the surprising rigidity of any system that must sort a continuum of people
into a handful of discrete boxes.

## A number for everyone

Start with the most basic picture. A population is a collection of individuals,
and a credit system is nothing more than a rule that assigns each individual a
real number — their score. The real line $\mathbb{R}$ is the natural home for
such a value: it is totally ordered (any two scores can be compared) and
complete (there are no gaps in the number line itself).

The first thing to notice is a guarantee of *extremes*. Suppose the population is
"compact" — a technical way of saying it is closed and bounded, with no
individuals escaping to infinity — and suppose the scoring rule is continuous, so
that similar people receive similar scores. Then the system always produces a
highest-scoring member and a lowest-scoring member.

> **Theorem (Extremal members).** *If the population is a nonempty compact space
> and the scoring map is continuous, then there exist a member of maximal score
> and a member of minimal score.*

This is the classical Extreme Value Theorem wearing a sociological costume. A
continuous image of a compact set is compact, and a compact set of real numbers
contains its supremum and infimum. There is always a "best" and a "worst,"
whether we like it or not.

## Scores that remember

Credit is never static. Each round of judgment revises a member's score. A
simple and honest model of this revision is *affine*: your new score is a fixed
reward $c$ (the credit the system grants you this round) plus a **damped memory**
of your old score,

$$ x_{\text{new}} = c + k\,x_{\text{old}}, $$

where the damping factor $k$ controls how much the past clings to the present.
If $0 \le k < 1$, memory fades: each round, only a fraction $k$ of your history
survives. What happens after many rounds?

> **Theorem (Fixed-point attractor).** *If $0 \le k < 1$, then no matter where a
> member starts, their score converges to the single equilibrium value*
> $$ x^\star = \frac{c}{1-k}. $$

The proof is a short computation. Iterating the rule $n$ times gives the closed
form
$$ x_n = k^n x_0 + c\,\frac{1 - k^n}{1 - k}, $$
and since $k^n \to 0$ when $0 \le k < 1$, the starting score $x_0$ is forgotten
and $x_n \to c/(1-k)$. This equilibrium is a genuine attractor: it is the unique
fixed point of the update rule, and it pulls in every trajectory. Your ultimate
standing is decided not by where you began but by the balance between reward $c$
and the persistence $k$ of your reputation.

Even when we drop *all* smoothness and contraction assumptions, an equilibrium
survives — for order-theoretic reasons alone.

> **Theorem (Order-theoretic equilibrium).** *Any monotone scoring rule that
> keeps scores inside the interval $[0,1]$ has an equilibrium score in $[0,1]$.*

This is the Knaster–Tarski fixed-point theorem. The equilibrium is the supremum
of all scores $x$ that the rule pushes upward (those with $x \le f(x)$). Monotone
feedback, however jagged, cannot avoid a fixed point.

## The verdict machine and the birth of a fractal

Now comes the twist. In practice a score is not handed down by a single formula;
it accumulates from a long sequence of discrete **verdicts**. In each generation
the system renders a binary judgment: *commended* or *flagged*. Later verdicts
matter less than earlier ones, so we weight the $n$-th verdict by a factor that
shrinks geometrically. The particular choice that makes the geometry sing is to
weight generation $n$ by $2/3^{\,n+1}$ and to score a commendation as full weight
and a flag as zero. An infinite history of verdicts $a_0, a_1, a_2, \dots$ (each
either commended or flagged) then yields the score

$$ \Phi(a) = \sum_{n=0}^{\infty} \frac{2 \, [a_n = \text{commended}]}{3^{\,n+1}}, $$

where $[\cdot]$ is $1$ when the verdict is a commendation and $0$ otherwise.

Why base three? Because the digit $2/3^{n+1}$ leaves a deliberate *gap*: at every
generation, the middle third of the available range — the "no man's land"
between the commended basin and the flagged basin — is left empty. That gap is
the mathematical signature of a decision with no fence-sitting.

Every such score lands in the unit interval.

> **Theorem (Scores live in $[0,1]$).** *For every verdict history, $0 \le
> \Phi(a) \le 1$.*

The lower bound is obvious; the upper bound is the geometric series
$\sum_{n\ge 0} 2/3^{n+1} = \tfrac{2}{3}\cdot\tfrac{1}{1-1/3} = 1$, attained when
every verdict is a commendation.

The magic is what $\Phi$ builds. Its range — the set $C$ of *all attainable
scores* — is precisely the **middle-thirds Cantor set**, the most famous fractal
in mathematics. And it satisfies a self-referential equation that captures its
entire structure in one line.

> **Theorem (Self-similarity).** *The set of attainable scores $C$ is the union
> of two shrunken copies of itself:*
> $$ C = \tfrac{1}{3}\,C \;\cup\; \left(\tfrac{1}{3}\,C + \tfrac{2}{3}\right). $$

The reason is a clean bookkeeping fact about prepending a verdict to a history.
If a member's *first* verdict is a flag, every later contribution is divided by
three, so the whole score shrinks: $\Phi(\text{flag}, a) = \Phi(a)/3$. If the
first verdict is a commendation, the same shrinking happens but the score is
shifted up by $2/3$: $\Phi(\text{commend}, a) = \Phi(a)/3 + 2/3$. The first
verdict alone decides which of two disjoint worlds you inhabit — the lower third
$[0,\tfrac13]$ or the upper third $[\tfrac23,1]$ — and each world is a perfect
miniature of the whole. This is an *iterated function system*: two contractions,
$x \mapsto x/3$ and $x \mapsto x/3 + 2/3$, whose unique invariant set is the
Cantor dust.

Finally, no information is ever lost.

> **Theorem (Injectivity).** *Distinct verdict histories produce distinct
> scores.*

The first verdict is legible in the score itself: a flag pins you to
$[0,\tfrac13]$, a commendation to $[\tfrac23,1]$, and the two never overlap. Peel
off that verdict, rescale, and read the next one; repeat forever. So the score
faithfully encodes the entire, infinite reputational biography. Because there are
uncountably many possible histories, the attractor is uncountable — a
"dust" with as many points as the whole continuum, yet so full of holes that it
contains no interval at all.

## Small nudges, large fates

The gaps are not a curiosity; they are the whole point. Because the commended and
flagged basins are separated by a void, changing a *single* early verdict does
not shift a score slightly — it teleports it across the gap. Flip your very first
judgment and your score leaps from somewhere in $[0,\tfrac13]$ to somewhere in
$[\tfrac23,1]$, never passing through the middle. This is the mathematics of a
**phase transition**: a discontinuous jump triggered by an infinitesimal cause.

To see why such jumps are unavoidable in any real system, consider how scores
become *tiers*. A system rarely publishes a raw number; it publishes a label —
"trusted" or "restricted" — obtained by thresholding at some cutoff $t$: you are
flagged as trusted exactly when your score is at least $t$.

> **Theorem (The cutoff is a critical point).** *The threshold classifier is
> discontinuous precisely at $t$ and continuous everywhere else. At $t$ it is
> maximally sensitive: within any distance $\delta > 0$ of the cutoff there is a
> score whose tier differs from the cutoff's.*

A member sitting exactly on the line is perfectly unstable — the tiniest tremor
flips their label. And this instability is not an artifact of a clumsy rule. It
is forced by topology.

> **Theorem (Inevitability of phase transitions).** *Any classifier that sorts
> the score line continuously into two labels must be constant. Consequently, any
> classifier that ever distinguishes two members must be discontinuous somewhere
> — a phase transition is unavoidable.*

The reason is that the real line is *connected*: it cannot be split into two
separated pieces. A continuous map into a two-point set (trusted / restricted)
would do exactly that splitting, so it can only ever output one label. The moment
a system draws a genuine distinction between two people, it must contain a cliff
edge — a critical score where destinies diverge.

## Why this matters

The picture that emerges is a warning dressed as a theorem. A reputation system
built from an unbounded stream of weighted binary judgments does not distribute
people evenly along a smooth spectrum. It funnels them onto a fractal skeleton,
the Cantor set, whose defining feature is that it is *all edges*. Between any two
attainable scores lies a gap; near every score lies a cliff. The Hausdorff
dimension of this attractor is $\log 2/\log 3 \approx 0.63$ — less than that of a
line, a set so sparse it has zero length yet so rich it is uncountable.

The consequences are stark. Such a system is exquisitely sensitive to early
verdicts and structurally incapable of smoothing over its boundaries: wherever it
draws a line, that line is a phase transition where small perturbations cause
disproportionate, discontinuous change. The comforting intuition that "a slightly
better record yields a slightly better score" is simply false in this geometry.

There is a deeper lesson here about the mathematics of judgment. The same
structures that make the Cantor set a jewel of pure analysis — self-similarity,
disconnection, the iterated function system — are exactly the structures that
make an automated reputation system brittle and unforgiving. Geometry is destiny.
When we quantify people, we inherit the shape of the numbers we choose, and some
shapes have no gentle slopes at all — only plateaus, and the cliffs between them.
