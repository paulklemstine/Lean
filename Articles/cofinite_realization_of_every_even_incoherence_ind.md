# The Voter Count That Refuses to Cooperate

## When "big enough" isn't a number you can name

Imagine you are designing the rules for a committee, a parliament, or a
ranked-choice election. You want the system to be *coherent*: you do not want a
situation where a perfectly balanced tug-of-war among the voting blocs leaves the
group paralyzed, unable to settle on anything. Mathematicians who study collective
decision-making have a way to measure exactly how fragile a voting setup is. They
call it the **incoherence index** — and it is, roughly, the size of the *smallest
self-cancelling coalition* that the rules permit.

The story told here is about a tempting, clean-looking conjecture and the stubborn
little electorate that breaks it. The conjecture says: a certain kind of paralysis
of a given "size" should be possible as soon as the electorate passes a simple
threshold. The reality is more interesting. The paralysis you want *does* eventually
become possible — but never exactly when the clean formula promises. There is always
a gap, and at the very boundary the construction is provably impossible. We will see
precisely why, with a concrete counterexample on just **six voters**.

## Voters as clock positions

To make any of this precise we need a model, and the model is surprisingly simple
and visual. Picture a clock with $N$ positions, numbered $0, 1, 2, \dots, N-1$.
Adding two positions means moving around the clock and wrapping past $N$ back to
$0$. Mathematicians call this structure the cyclic group $\mathbb{Z}/N\mathbb{Z}$
(written $\mathbb{Z}_N$), the integers "mod $N$."

In our model of social decisions, a **frame** is simply a finite set $F$ of clock
positions — think of each chosen position as one allowable "majority-or-tie" voting
pattern, an *atom* of decision-making. So a frame is a finite subset
$F \subseteq \mathbb{Z}_N$.

Now the key idea. A **perfectly balanced obstruction** is a nonempty sequence of
atoms — repetitions allowed — whose clock positions add up to exactly $0$. In
symbols, a list $\ell = (x_1, x_2, \dots, x_m)$ with every $x_i \in F$ and
$$x_1 + x_2 + \cdots + x_m \equiv 0 \pmod{N}.$$
Such a sequence is a coalition of voting patterns that perfectly cancels out: it
goes all the way around the clock (possibly several times) and lands back at the
start. That is the mathematical fingerprint of a deadlock — a Condorcet-style cycle
that returns the group to where it began with nothing decided.

The **incoherence index** of a frame $F$, written $\operatorname{idx}(F)$, is the
*length of the shortest* such balanced obstruction:
$$\operatorname{idx}(F) = \min\{\,m : \text{some balanced obstruction of } F \text{ has length } m\,\}.$$
A small index means a small coalition can already deadlock the system — the rules
are fragile. A large index means you need a big, elaborate coalition before any
deadlock appears — the rules are robust.

One more notion. A frame is **maximal** when its atoms are rich enough to reach
every possible position on the clock by repeated addition — formally, when the atoms
*generate* the whole group $\mathbb{Z}_N$. Maximal frames are the "fully expressive"
voting systems, the ones rich enough that the group can, in principle, navigate to
any collective state.

## A tiny example to fix the picture

Take $N = 6$ — a six-position clock — and the simplest possible frame, the single
atom $F = \{1\}$. The only way to build a balanced obstruction is to add $1$ to
itself over and over: $1, 1+1, 1+1+1, \dots$. You return to $0$ for the first time
after exactly six steps, because $1+1+1+1+1+1 = 6 \equiv 0 \pmod 6$. So
$$\operatorname{idx}(\{1\}) = 6.$$
This is the *most robust* frame on six voters: nothing shorter than the full
six-element coalition cancels out. And $\{1\}$ is maximal, since the single atom $1$
already generates the whole clock.

This little computation is the seed of a general fact: repeating any one atom $a$
until it returns to zero always produces a balanced obstruction, so the index can
never exceed the **additive order** of $a$ — the number of steps it takes that atom
to march back to $0$. For $a = 1$ on a six-clock that order is $6$; for $a = 2$ it is
$3$ (since $2+2+2 = 6 \equiv 0$); for $a = 3$ it is $2$. This is the **order bound**:
$$\operatorname{idx}(F) \le \operatorname{order}(a) \quad \text{for every atom } a \in F.$$

## The conjecture, and the crack in it

Here is the clean conjecture that motivated this work. Fix a "target size"
parameter $k \ge 1$. The claim was that, as soon as the half-electorate $n$ reaches
$2k+1$, you can build a maximal frame on $2n$ voters whose incoherence index is
*exactly* $2k+2$. In other words, a specific even level of fragility should turn on
the moment the population crosses the simple threshold $n \ge 2k+1$.

It is a beautiful, tidy statement. It is also, taken literally, **false** — and it
fails at the very first opportunity.

The simplest case is $k = 1$. The threshold says $n \ge 3$, the smallest electorate
is $2n = 6$ voters, and the target index is $2k + 2 = 4$. So the literal conjecture
demands: *there is a maximal frame on six voters with incoherence index exactly 4.*

There is not. And here is the heart of the argument, in plain terms.

## Why six voters cannot deadlock at length four

The proof is a small masterpiece of "follow your nose." Suppose, for contradiction,
that some frame $F$ on the six-clock had index exactly $4$.

**Step 1: a big index forces powerful atoms.** Recall the order bound: the index can
never exceed the order of any atom. So if $\operatorname{idx}(F) = 4$, every atom $a$
in $F$ must have order at least $4$. But an atom's order always *divides* $N = 6$
(this is a basic fact about clocks: marching by a fixed step returns to start after a
number of steps that evenly divides the clock size). The divisors of $6$ are
$1, 2, 3, 6$ — and the only one that is at least $4$ is $6$ itself. So *every atom of
$F$ must have order exactly $6$*: every atom must be a **generator** of the clock.
This is the general "generators-only" principle: whenever a frame's index strictly
exceeds half the electorate, $N/2$, every one of its atoms is forced to be a
generator. Here $4 > 6/2 = 3$, so the principle bites.

**Step 2: there are only two generators.** On a six-clock, exactly two positions
generate everything: $1$ and $5$. (The atom $2$ only reaches the even positions $0,
2, 4$; the atom $3$ only reaches $0, 3$; and so on.) So our hypothetical frame $F$
can contain nothing but $1$ and $5$.

**Step 3: but $1$ and $5$ deadlock in length two.** The atoms $1$ and $5$ are
opposites on the clock: $1 + 5 = 6 \equiv 0$. So the two-element coalition $(1, 5)$
is already a perfectly balanced obstruction! That means any frame containing both has
index at most $2$, not $4$. And a frame containing only $1$ (or only $5$) has index
exactly $6$. So the possible indices for a generator-only frame on six voters are
$6$, $6$, and $2$ — **never $4$**.

Every road leads to a contradiction. No maximal frame on six voters has incoherence
index $4$. The literal threshold conjecture is refuted at its very first case,
$k = 1$, $n = 3$.

The same mechanism dooms the next cases too. At $k = 2$ the boundary electorate is
$2n = 10$ voters with target index $6$; at $k = 3$ it is $14$ voters with target
index $8$. In each case the target is exactly $N/2 + 1$, just one notch above half
the electorate — landing squarely in a *forbidden zone* between $N/2$ and $N$ that
maximal frames on even electorates appear never to reach.

## The forbidden zone

Step back and the picture becomes elegant. For an electorate of even size $N$, the
incoherence indices that maximal frames can actually achieve seem to split into two
camps: the **robust** values up to half the electorate ($\operatorname{idx} \le N/2$)
and the single **maximally robust** value $\operatorname{idx} = N$ (achieved by a
lone generator like $\{1\}$). The open interval strictly between $N/2$ and $N$ — the
"forbidden zone" — is never hit.

Why? Because to land above $N/2$ you are forced (by the generators-only principle)
to build your frame entirely from generators. But a pair of distinct generators on
an even clock always cancels in a short coalition, dragging the index back down to at
most $N/2$. You are squeezed from both sides: a single generator overshoots all the
way to $N$, while two or more generators undershoot back below $N/2$. There is no way
to land in between.

The target $2k+2 = N/2 + 1$ of the literal conjecture sits exactly one step inside
this forbidden zone. That is the structural reason the clean threshold can never be
right at the boundary.

## What is actually true

None of this means the underlying dream is wrong — only that the *threshold* was too
optimistic. The fragility level $2k+2$ genuinely *is* realizable by a maximal frame,
but only once the electorate grows comfortably past the naïve boundary. This is the
**cofinite realization** phenomenon: every even target index is achievable for all
sufficiently large electorates, just not down to the literal cutoff $n = 2k+1$. The
honest threshold is strictly larger than the formula suggested.

The robust end of the story is concrete and complete. For every even electorate
$n \ge 4$ there really is a maximal frame whose incoherence index is exactly $n$ —
the single-generator frame $\{1\}$ does the job, and $n$ is provably the *largest*
index any nonempty frame on $n$ states can have. And the spectrum of achievable
incoherence indices is unbounded: pick any ceiling you like, and some electorate has
a frame whose (even) index sails past it. Fragility, in this model, has no upper
limit — it only has forbidden middle ground.

## Why a six-voter curiosity matters

It is tempting to dismiss a counterexample on six voters as a quirk. It is the
opposite: it is a warning about a pattern that recurs throughout mathematics and its
applications. We constantly conjecture that a desirable property "kicks in past a
simple threshold," because thresholds are easy to state and easy to believe. But the
arithmetic of the underlying structure — here, which clock positions can cancel which
others — often imposes hidden obstructions that no amount of wishful thinking
removes. The right statement is frequently "eventually, but not from the obvious
starting line."

The lesson generalizes far beyond voting. The same arithmetic of self-cancelling
coalitions governs **zero-sum problems** in number theory (the celebrated
Erdős–Ginzburg–Ziv style questions about when a collection of residues must contain a
subset summing to zero), the design of **error-correcting codes** (where short
"balanced" combinations are exactly the failures you must avoid), and the structure
of **chemical reaction networks** and **flow systems** (where a balanced cycle is a
loop that consumes and produces nothing net). In all of these, the difference
between "shortest cancelling combination" and "the size you wish it were" is the
difference between a system that works and one that quietly fails.

So the next time someone offers you a crisp threshold — "this works as soon as you
have at least this many" — remember the six voters who refused to deadlock at length
four. The clean line is often a little too clean. The truth lives just past it, in a
place you have to earn rather than name.
