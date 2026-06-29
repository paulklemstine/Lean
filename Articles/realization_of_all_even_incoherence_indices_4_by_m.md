# The Shortest Way to Tie a Vote

## How a question about deadlocked elections turns into clean number theory

Imagine a committee that must reach decisions. On any given motion the members
break into camps, and the result is recorded as one of finitely many *outcomes*:
"yes wins," "no wins," "the amendment carries," "we are deadlocked." Over a long
session, the committee produces a stream of these outcomes. A natural worry for
anyone designing the rules is: **can the system tie itself in knots?** Can a run
of outcomes conspire so that, taken together, they perfectly cancel — leaving the
committee exactly where it started, with no net progress at all?

This is the intuition behind a notion social-choice theorists call *incoherence*.
A decision procedure is incoherent if there is a sequence of legitimate outcomes
that is, in a precise sense, *perfectly balanced*: it returns the system to
neutral. The shorter such a sequence can be, the more fragile the procedure — a
short balanced run is an easy-to-trigger deadlock. The longest the shortest such
run can be is, conversely, a measure of how robust the design is. That number —
the length of the shortest perfectly balanced sequence — is the **incoherence
index**.

It was already known that incoherence indices can be arbitrarily large: there is
no universal ceiling, no single number $N$ such that every decision procedure
deadlocks within $N$ steps. But "arbitrarily large" is a weak statement. It
leaves open a sharper question, the one this article is about:

> **Which numbers actually occur as incoherence indices?**

The headline result is crisp and complete for the even case:

> **Every even number $n \ge 4$ is the incoherence index of a *maximal* decision
> frame on $n$ states — and $n$ is the largest index that $n$ states can
> possibly produce.**

So the spectrum of incoherence indices is not merely unbounded; for even values
it is *fully realized*, and realized by the most "spread-out," structurally
richest frames. Let us see how a question about committees becomes a theorem
about adding numbers on a circle.

## The model: outcomes as points on a clock

The first move is to strip the committee down to arithmetic. Fix a number $n$ of
distinct social states — think of $n$ positions arranged evenly around a clock
face, the integers modulo $n$, written $\mathbb{Z}/n\mathbb{Z}$. Each possible
"majority-or-tie outcome" is one of these clock positions, which we call an
**atom**.

A **standard social decision frame** is simply a finite set $F$ of atoms — the
collection of outcomes the procedure can actually emit. Formally,
$F \subseteq \mathbb{Z}/n\mathbb{Z}$. That is the entire setup. Stripped of
political dressing, a frame is a set of residues on a clock.

## Balance: sequences that return to noon

Now we make "perfectly balanced" precise. A run of outcomes is a list of atoms,
$$a_1, a_2, \dots, a_k,$$
each $a_i$ drawn from the frame $F$. We say the run is **balanced** if it is
non-empty and the atoms sum to zero on the clock:
$$a_1 + a_2 + \cdots + a_k \equiv 0 \pmod{n}.$$
Geometrically, you start at noon, take $k$ steps around the clock (one per
outcome), and land exactly back at noon. The net displacement is nothing. The
committee has churned through $k$ decisions and ended precisely where it began.

The collection of all lengths $k$ for which *some* balanced run of that length
exists is the frame's set of balanced lengths. The **incoherence index** of $F$
is the smallest such length:
$$\mathrm{index}(F) = \min\{\, k : \text{there is a balanced run of length } k \,\}.$$
(If no balanced run exists at all, the index is set to $0$ by convention.) A
small index means the frame deadlocks quickly; a large index means you must wait
a long time before any cancellation is possible.

## A worked example: the lonely atom

Take the simplest non-trivial frame of all: a single atom, the unit step
$F = \{1\}$ on the clock $\mathbb{Z}/n\mathbb{Z}$. Every outcome the procedure
can emit is "advance by one." What is the shortest balanced run?

A run can only use the atom $1$, so a run of length $k$ sums to
$1 + 1 + \cdots + 1 = k$. For this to be zero on the clock we need $k$ to be a
multiple of $n$. The smallest positive such $k$ is $n$ itself. So the shortest
balanced run is "$1$ repeated $n$ times" — you tick around the entire clock once
and only then return to noon.

Therefore
$$\mathrm{index}(\{1\}) = n.$$
This is the lemma the formal development calls `incoherenceIndex_singleton_one`,
and it is the engine of everything that follows. A single, lonely, unit-sized
atom produces the *longest possible delay* before the system can balance.

## A contrasting example: crowd the clock and it collapses

Compare that with a *crowded* frame. On the clock $\mathbb{Z}/4\mathbb{Z}$ take
$F = \{1, 3\}$. Now there is an instant shortcut: $1 + 3 = 4 \equiv 0$. A
balanced run of length $2$ exists, and length $1$ is impossible (neither $1$ nor
$3$ is zero). So
$$\mathrm{index}(\{1,3\}) = 2,$$
even though the bigger frame $\{1,3\}$ "contains" the lonely frame $\{1\}$ whose
index was $4$. Adding atoms gave the committee more ways to cancel, and the index
plummeted from $4$ to $2$. The moral, which we return to below, is that **more
options mean faster deadlock**.

## Maximal frames: spread out, yet fragile to deadlock — except they aren't

Here is the subtle part, and the reason the main theorem is interesting. One
might guess that the lonely frame $\{1\}$, being so sparse, is somehow
"degenerate" — that the truly *expressive* procedures, the ones whose outcomes
can reach every social state, must behave differently. Let us make "expressive"
precise.

Call a frame **maximal** if its atoms *generate* the entire decision space: by
adding and subtracting outcomes you can reach every position on the clock.
Formally, the subgroup generated by $F$ is everything,
$$\langle F \rangle = \mathbb{Z}/n\mathbb{Z}.$$
A maximal frame is one with no "blind spots": no social state is unreachable.

Is the lonely frame $\{1\}$ maximal? Yes! The single unit step generates the
whole clock — repeatedly adding $1$ visits every position. This is the lemma
`isMaximal_singleton_one`. So $\{1\}$ is simultaneously **maximal** (maximally
expressive — it reaches everywhere) and **extremal** (it has the largest possible
incoherence index). The sparse and the rich coincide.

That coincidence is what makes the realization theorem possible, and it is
genuinely surprising. Expressiveness and resistance-to-deadlock are usually in
tension — the crowded frame $\{1,3\}$ was also maximal, yet it deadlocked
twice as fast. Maximality alone does **not** pin down the index. What pins it
down is *sparseness within maximality*: be just barely able to reach everywhere,
using a single generator, and you maximize the delay.

## The ceiling: $n$ states can never stall longer than $n$

Before stating the main theorem, we need its other half: an upper bound. How
long can *any* non-empty frame on $n$ states delay balancing?

The answer is at most $n$, and the argument is a one-liner. Take any atom $a$ in
the frame and repeat it $n$ times. The sum is $n \cdot a$, and since we are on a
clock of size $n$, $n \cdot a \equiv 0$ for *every* $a$. So "$a$ repeated $n$
times" is always a balanced run of length $n$. Hence the shortest balanced run is
no longer than $n$:
$$\mathrm{index}(F) \le n \quad\text{for every non-empty frame } F.$$
This is the lemma `incoherenceIndex_le`. Combined with the lonely-atom
computation, we already see the shape of the result: $n$ is an upper bound, and
$\{1\}$ achieves it.

## The main theorem: every even $n \ge 4$ is realized

Putting the pieces together yields the centerpiece, the formal theorem
`realization_even`:

> **Realization.** For every even integer $n \ge 4$, there exists a maximal
> standard social decision frame on $n$ states whose incoherence index is exactly
> $n$.

The witness is the lonely frame $\{1\}$. It is maximal
(`isMaximal_singleton_one`), and its index is exactly $n$
(`incoherenceIndex_singleton_one`). The evenness assumption is the conjecture's
explicit constraint — the original question asked specifically about even indices
— but the construction in fact works for every $n \ge 1$; evenness is carried
along only to stay faithful to the way the problem was posed.

And the companion theorem `incoherenceIndex_isGreatest` upgrades "achieved" to
"maximal possible":

> **Sharpness.** For even $n \ge 4$, the number $n$ is the *greatest* incoherence
> index attainable by any non-empty frame on $n$ states, and it is attained.

So on $n$ social states, the incoherence index ranges over some set of values
topping out at exactly $n$, and that ceiling is reached by a maximal frame. There
is no waste: the theoretical maximum is realized in practice.

## Parity: why even numbers are the natural habitat

Why does the conjecture single out *even* indices? Because there is a clean
structural reason a frame's index is forced to be even. Suppose $n$ is even and
look at the *parity character*: the map that sends each clock position to its
parity, $\mathbb{Z}/n\mathbb{Z} \to \mathbb{Z}/2\mathbb{Z}$. Call an atom **odd**
if it maps to $1$.

Now suppose every atom of a frame $F$ is odd. Take any balanced run
$a_1 + \cdots + a_k \equiv 0$. Apply the parity map: the left side becomes
$1 + 1 + \cdots + 1 = k \pmod 2$, while the right side is $0$. So $k$ must be
even. Every balanced run has even length, and in particular the *shortest* one
does. This is the theorem `even_incoherenceIndex`:

> **Parity.** If $n$ is even and every atom of $F$ is odd, then
> $\mathrm{index}(F)$ is even.

It explains why even indices are the right thing to chase: the all-odd frames
form a whole family living entirely in the even spectrum, and the realization
theorem shows that family's reach extends to every even value from $4$ upward.

## Unboundedness: no universal deadlock guarantee

Finally, stepping back from any fixed $n$, the spectrum as a whole has no
ceiling. The theorem `incoherence_unbounded` states:

> **Unboundedness.** For every number $N$, there is a frame whose incoherence
> index is even and strictly greater than $N$.

This is the qualitative backdrop the realization theorem refines. No matter how
patient a rule designer is — no matter how large an $N$ they are willing to
tolerate before a deadlock — some frame holds out longer. There is no finite
budget of decisions after which balance is guaranteed. The realization theorem
then says this unbounded growth happens in the most orderly way imaginable:
*every* even value, with no gaps, is hit, and hit by a maximal frame.

## Why this is more than a curiosity

Three ideas make this small theory satisfying.

**First, a complete answer.** "Unbounded" tells you the indices grow without
limit but says nothing about *which* values appear. The realization theorem fills
the even spectrum exactly — a transition from "there is no largest value" to
"here is precisely the set of values, and here are the frames that produce them."
In mathematics, going from *unboundedness* to *full realization* is a real
upgrade, the difference between knowing a staircase has no top step and knowing
the height of every step.

**Second, an unexpected coincidence.** The frame that maximizes deadlock-delay is
the *sparsest* maximal frame, the lonely single generator. Crowding the frame
with more outcomes — even while keeping it maximal — only shortens the balanced
runs, as $\{1,3\}$ on the $4$-clock dramatically shows. Robustness against
deadlock comes from minimalism, not abundance.

**Third, a bridge.** A question phrased about voting and committees dissolves
completely into the arithmetic of *zero-sum sequences* on a cyclic group — the
same circle of ideas (additive orders, the Davenport constant, zero-sum
combinatorics) that number theorists study for its own sake. The incoherence
index of a single-atom frame is nothing but the additive order of that atom. The
committee was a clock all along.

## The view from the top

We began with a fragile-sounding worry — can a decision procedure tie itself in
knots? — and ended with a complete description of how long it can hold out. On
$n$ social states the maximum delay is exactly $n$, achieved by the leanest
maximal frame; every even delay from $4$ upward is realized; all-odd frames are
trapped in the even spectrum; and no global ceiling exists. The committee's worst
deadlock, it turns out, is just one full lap around the clock — and you can build
a perfectly expressive procedure that takes exactly that long, for any even
number of laps' worth of states you like.
