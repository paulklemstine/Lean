# The Logic of Time Travel: When Can a Loop in Time Hold Together?

Imagine stepping into a machine, spinning the dial back to a summer afternoon
decades before you were born, and walking out into a world that has not yet made
you. Everything you touch there will ripple forward through the years and,
eventually, back to the moment you left. You are not just a visitor to the past;
you are now a *cause* of the present you came from. The future you knew depends
on what you do here — and what you do here depends on the future you knew.

This is the strange knot at the heart of every time-travel story: a loop in which
effect feeds back into cause. Physicists call such a loop a **closed timelike
curve**. Storytellers call it a paradox waiting to happen. For a long time both
groups treated the subject as a playground for intuition and contradiction. But
the question "when can a loop in time hold together?" turns out to have a crisp,
provable answer. This article is about that answer.

## A loop in time is a function

Strip away the romance and a time loop is a bookkeeping device. Something goes
around it — call it the **state of the world**, everything the loop can touch —
and comes back changed. Whatever the physics, the *net effect* of one trip
around the loop is captured by a single rule: give me the state of the world as
the loop begins, and I will tell you the state of the world as the loop closes.

We write that rule as a function $f$ that takes a world-state $s$ and returns a
new world-state $f(s)$. Traveling once around the loop turns $s$ into $f(s)$.

Now the paradox has a precise shape. A loop is a genuine, self-supporting piece
of history only if the world it hands back is the very world it started from.
The state you leave must be the state you arrive to create. In symbols, the loop
holds together exactly when there is a world-state $s$ with
$$f(s) = s.$$
A world-state that satisfies this equation is called a **fixed point** of $f$:
the loop maps it to itself. The whole subject of time-travel consistency reduces
to a single question about ordinary functions: *does this function have a fixed
point?*

This is the mathematical face of a principle that physicists have long invoked
to tame time travel — the **self-consistency principle**, which insists that the
only journeys into the past that can actually occur are the ones that produce the
history they departed from. In our language:

> **Self-consistency principle (fixed-point form).** A time loop with net effect
> $f$ admits a consistent history if and only if $f$ has a fixed point, a
> world-state $s$ with $f(s) = s$.

The principle stops being a philosophical stance and becomes a theorem about
functions. And once it is a theorem, we can actually decide, loop by loop,
whether a given piece of time travel is possible.

## Histories that close

A real time loop is not one instantaneous jump; it is a chain of events, each
causing the next: $e_1 \to e_2 \to \dots \to e_n \to e_1$. To model this, think
of the loop as a sequence of causal steps. Step $0$ turns the state at event
$e_1$ into the state at $e_2$; step $1$ turns that into the state at $e_3$; and
so on around the ring. Applying the first $k$ steps in order, starting from a
state $s$, produces what we might call *the state after $k$ steps*, and the full
loop of length $n$ is what you get after all $n$ steps.

A **closed timelike history** is an honest labeling of the events by
world-states — a value $h(0), h(1), \dots, h(n)$ at each event — with two
properties: every step does its job, so the effect $h(k+1)$ really is what the
cause $h(k)$ produces, and the loop actually closes, so $h(n) = h(0)$. This is
what a self-consistent journey *looks like* from the inside: a diary of the trip
in which every entry is caused by the one before and the last entry matches the
first.

The first theorem says these two viewpoints — the abstract "does the net map
have a fixed point?" and the concrete "is there a diary that closes?" — are one
and the same.

> **Theorem (Novikov equivalence).** A loop of length $n$ has a self-consistent
> net effect (its overall map has a fixed point) if and only if it admits a
> closed timelike history.

The proof is a pleasant round trip. From a fixed point $s$, define the diary by
letting $h(k)$ be the state after $k$ steps starting from $s$; because $s$ is
fixed, the last entry returns to the first, and every step obviously does its
job. Conversely, from a closed diary, its starting value $h(0)$ is fixed by the
full loop, because running all $n$ steps from $h(0)$ retraces the diary and lands
back at $h(n) = h(0)$. Consistency of the whole is exactly consistency step by
step.

## The grandfather paradox, made impossible on purpose

The most famous time-travel puzzle is the grandfather paradox: you go back and
prevent your own ancestor from ever having descendants — but then you were never
born, so you never went back, so your ancestor survives, so you *were* born. The
story spins forever precisely because it can never settle.

We can make this exact. Reduce the ancestor to a single bit of world-state:
*alive* or *dead*. The traveler's action, carried around the loop, flips that
bit — the whole point of the journey is to change the ancestor's fate. So the
net effect is the function that swaps *alive* with *dead* and *dead* with
*alive*. Call it $f$.

Does $f$ have a fixed point? A fixed point would be a status that the loop leaves
unchanged. But flipping never leaves anything unchanged: *alive* becomes *dead*
and *dead* becomes *alive*, so $f(s) \neq s$ for every $s$. We call such a loop
**paradoxical**: no world-state survives a trip around it. And a paradoxical loop
can have no fixed point, hence no consistent history.

> **Theorem (grandfather paradox is impossible).** The flip-the-ancestor loop
> has no fixed point, so it admits no self-consistent history whatsoever.

This is not hand-waving about causality; it is the observation that a function
with no fixed point cannot support a closed loop, together with the fact that a
flip has no fixed point. The grandfather paradox is impossible in the strongest
sense: not "it would be weird," but "there is provably no way to fill in the
diary." Under the self-consistency principle, nature simply does not allow such a
journey to happen.

## When loops are guaranteed to hold together

If some loops are impossible, are others *guaranteed* to be possible? Remarkably,
yes — and here mathematics hands time travel three separate safety certificates,
each springing from a classical fixed-point theorem.

**Order and monotonicity.** Suppose the world-states can be ranked, with a
richest possible state and a poorest, and every collection of states has a least
upper bound and a greatest lower bound. (Mathematicians call such a structure a
*complete lattice*; think of it as a space with no gaps at the top or bottom.)
Suppose too that the loop is **monotone**: feeding it a richer input never yields
a poorer output. Then the loop is *always* self-consistent. This is a form of
the celebrated Knaster–Tarski theorem, and the fixed point it produces is
canonical — the smallest self-consistent world the loop can settle into.

**Continuity on a dial.** Now imagine the world-state is a single continuous
parameter — a dial reading between $0$ and $1$, say the phase of some cyclic
process. If the loop's net effect varies continuously and never sends the dial
outside its range, then it must fix some setting.

> **Theorem (continuous loops are self-consistent).** A continuous map $f$ of the
> interval $[0,1]$ into itself has a point $s$ with $f(s) = s$.

The reason is the intermediate value theorem in disguise. Look at
$g(x) = f(x) - x$, the amount by which the loop *displaces* the dial. At the
bottom of the range $g(0) = f(0) \ge 0$, because $f(0)$ cannot fall below $0$. At
the top $g(1) = f(1) - 1 \le 0$, because $f(1)$ cannot rise above $1$. A
continuous quantity that starts nonnegative and ends nonpositive must pass
through zero, and where $g$ vanishes, $f$ fixes the dial. This one-dimensional
result is a toy model of a striking conjecture in general relativity: that every
closed timelike curve in the rotating cosmos known as the Gödel universe is
self-consistent. Where the state space is continuous and self-contained,
paradoxes cannot survive.

**Symmetry and parity.** Finally, suppose the loop is an **involution** — going
around it twice restores the world exactly, so $f(f(s)) = s$ — and suppose the
world has a finite, *odd* number of possible states. Then the loop must fix at
least one of them.

> **Theorem (odd involutive loops are self-consistent).** An involution on a
> finite set of odd size has a fixed point.

The argument is a parity count. An involution pairs up the states it moves: each
moved state $s$ is matched with its distinct partner $f(s)$, and these pairs use
up an *even* number of states. If the total count is odd, at least one state
cannot be paired off — and an unpaired state is one the loop leaves fixed. Odd
symmetry leaves no room for a paradox.

## The many-worlds escape hatch

There is one last twist, and it is the most satisfying. What happens to the
grandfather paradox if history is allowed to *branch*?

In the branching picture, the traveler who goes back and kills the ancestor does
not overwrite the timeline they came from. Instead they step into a *fresh
branch* of reality — a new copy of the world, tagged with a branch number — and
act freely there. The ancestor dies in the new branch; the traveler lives on in
it; and the original timeline, the one that produced the traveler, is left
untouched. No contradiction ever forms because no single timeline is ever asked
to close on itself.

We can model this precisely. A branching state is a world-state together with a
branch index, and each step applies the traveler's action *and* advances the
index to a new branch. Two facts follow, and together they are the whole
resolution.

First, branching never repeats a state: because the branch index strictly
increases every step, the traveler never returns to a multiverse-state they have
already occupied. Second — and this is the punchline — *every* action, even a
provably paradoxical one like flip-the-ancestor, admits a perfectly consistent
branching history.

> **Theorem (branching resolves every paradox).** For any action with no
> single-timeline fixed point, the branching model still produces a complete,
> self-consistent history: start at the original world in branch $0$, and at each
> step apply the action and move to a new branch. This history exists no matter
> how paradoxical the action is.

The grandfather paradox, impossible as a loop that must close, becomes an
ordinary sequence of events once we let the timeline fork. The traveler pulls the
trigger; the ancestor falls; a new world spins off; and mathematics registers no
complaint. Where the single-timeline story hit a brick wall — a function with no
fixed point — the branching story simply walks around it, because it never
demands that the function fix anything at all.

## Why this matters

It is tempting to see all this as clever bookkeeping for a physics we will never
build. But the mathematics reaches much further than time machines. A "loop that
must close" is one of the most common structures in all of science: an economy
whose expectations shape the prices that shape the expectations; a population
whose next generation is a function of this one; a numerical scheme searching for
the state that reproduces itself; a program whose output is fed back as its
input. Every one of these is a map $f$, and every one of them is asking the same
question the time traveler asks — *is there a state you leave unchanged?*

The theory laid out here answers that question with a small toolkit of guarantees
and one sharp impossibility. Flips and negations — systems built to overturn
their own inputs — can never settle, and that is the grandfather paradox in its
purest form. But order, continuity, and symmetry each force a resting point into
existence, and when none of these hold, allowing the system to branch dissolves
the deadlock entirely.

Time travel, it turns out, is not a licence for contradiction. It is a demand for
a fixed point — and mathematics knows exactly when that demand can be met.
