# The Single Move That Connects Every Table

## A puzzle hidden inside an ordinary spreadsheet

Imagine a small market research survey. You ask a group of people three
yes/no questions — say, *Do you drink coffee?*, *Do you exercise?*, and
*Do you sleep well?* — and you tally the answers. The result is a little
three-dimensional table of counts: how many people answered "yes, yes, yes",
how many answered "yes, yes, no", and so on. Because each question has two
possible answers, there are exactly **eight** numbers in this table. Picture
it as the eight corners of a cube, each corner holding a count.

Now a statistician walks in and asks a deceptively simple question: *Given
only the two-way summaries of this survey — how coffee relates to exercise,
how coffee relates to sleep, and how exercise relates to sleep — which
complete eight-number tables are even possible?*

This is not idle curiosity. It is the heart of a real statistical test. When
scientists want to know whether three variables interact in a genuinely
*three-way* manner (beyond what their pairwise relationships already explain),
they need to compare the table they actually observed against *all the other
tables that share the same pairwise summaries*. If the observed table looks
typical among that crowd, there is no evidence of three-way interaction. If it
looks like an extreme outlier, there is.

So the whole test depends on a single, concrete ability: **to roam freely
through the space of all tables that share a given set of two-way summaries.**

And here is where a small miracle occurs. This article is about that miracle —
and about a complete, machine-checked proof that it really happens.

## What the two-way summaries actually pin down

Let us be precise about the bookkeeping. Write a count as `u(i, j, k)`, where
each of `i`, `j`, `k` is either `0` ("no") or `1` ("yes"). The eight numbers
`u(0,0,0), u(0,0,1), …, u(1,1,1)` are our table — call it `Table3`.

The "two-way summaries" come in three families. Fixing the coffee/exercise
answers and adding over sleep gives the **coffee–exercise margins**:

> `m12(i, j) = u(i, j, 0) + u(i, j, 1)`.

Fixing the coffee/sleep answers and adding over exercise gives the
**coffee–sleep margins**:

> `m13(i, k) = u(i, 0, k) + u(i, 1, k)`.

And fixing exercise/sleep and adding over coffee gives the **exercise–sleep
margins**:

> `m23(j, k) = u(0, j, k) + u(1, j, k)`.

Two tables are said to have the **same margins** when all three families
agree, summary for summary. The statistical model that fixes exactly these
quantities — and nothing more — is the famous **no-three-way interaction
model**, introduced into algebraic statistics by Persi Diaconis and Bernd
Sturmfels in their landmark 1998 work.

A *fiber* is the collection of all valid tables (non-negative whole-number
counts — you cannot have minus three coffee drinkers) sharing a fixed set of
margins. To run the statistical test, we must be able to walk from any table
in a fiber to any other, using simple, reversible steps that never break the
margin constraints and never produce a negative count. Such a walk is a
**Markov chain**, and the set of allowed steps is called a **Markov basis**.

## The astonishing answer: one move rules them all

How complicated should the set of allowed moves be? There are eight cells and
twelve margin equations binding them together. One might expect a thicket of
intricate, interlocking adjustments. The reality is breathtakingly simple.

There is exactly **one** fundamental move. It is the *alternating move*

> `M3(i, j, k) = (−1)^(i + j + k)`,

which means: add `+1` to a cell when `i + j + k` is even, and `−1` when it is
odd. On our cube, this checkerboard-colors the eight corners and pushes the
"even" corners up by one while pulling the "odd" corners down by one.

Why does this single move respect every summary? Look at any one of the
two-way margins — say `m12(i, j)`, which adds two cells differing only in the
sleep coordinate `k`. Those two cells always have *opposite* checkerboard
colors (because flipping one coordinate flips the parity of `i + j + k`). So
the move adds `+1` to one of them and `−1` to the other. The summary doesn't
budge. The same cancellation happens for every single one of the twelve
summaries. Applying the move — or any whole-number multiple of it — leaves all
margins untouched. In the formal development this is the theorem
**`noThreeWay_move_preserves_margins`**: for any table `u` and any integer
`t`, the table `u + t·M3` has exactly the same margins as `u`.

That `M3` is a *legal* move is reassuring. The real surprise is that it is the
*only* move you ever need.

## Why nothing else is required

Suppose two tables `u` and `v` have identical margins. Consider their
difference `w = v − u`. All of `w`'s two-way summaries are zero — adding +5 and
−5 along every line. The question is: how much freedom does a table have if all
its two-way summaries vanish?

The answer is **almost none**. Pin down a single corner, say `w(0,0,0)`.
Because the coffee–exercise summary over that line is zero, the neighbor
`w(0,0,1)` is forced to be `−w(0,0,0)`. Walking around the cube, each edge you
cross flips the sign, exactly like the checkerboard pattern of `M3`. By the
time you have visited all eight corners, every cell is determined: `w(i,j,k)`
must equal `(−1)^(i+j+k)` times the single number `w(0,0,0)`. In other words,

> `w = (v(0,0,0) − u(0,0,0)) · M3`.

There is exactly one degree of freedom, captured by the value at one corner,
and the alternating move `M3` *is* that degree of freedom. This is the theorem
**`noThreeWay_kernel`**: any two equal-margin tables differ by an integer
multiple of `M3`. In the language of lattices, the space of margin-preserving
moves is **rank one** — a single line through the eight-dimensional grid of
tables. The singleton set `{M3}` is, quite literally, *the* Markov basis.

This is what makes the no-three-way model the textbook first example beyond
the "easy" cases. For simpler models the moves are humble `2×2` swaps that
touch four cells. Here the one essential move has **degree four**: it touches
all eight cells at once. It is the smallest, cleanest example where the
generator of a Markov basis is something genuinely new.

## From algebra to a walk you can actually take

Knowing that `v − u` is a multiple of `M3` is an *algebraic* fact. The
statistical test needs something *dynamical*: a step-by-step walk from `u` to
`v` where every intermediate table is still a valid one — non-negative counts
throughout. You cannot, after all, pass through a table with `−2` coffee
drinkers on the way to a perfectly good destination.

Here a lovely geometric idea saves the day, an idea worth keeping in your
toolkit: **discrete convexity**. Think of the straight line of tables
`u, u + M3, u + 2·M3, …, u + t·M3 = v`. As you slide along this line, each
individual cell changes by a steady `+1` or `−1` per step — it moves
*monotonically*. A quantity that marches steadily up or down can only be
non-negative at *both* ends if it is non-negative at *every* step in between.
The set of valid tables on the line forms an unbroken integer interval, with no
gaps. So if the start `u` and the finish `v` are both valid, the entire walk
between them — taking one unit `±M3` step at a time, always heading toward the
target — stays valid the whole way.

This is the engine theorem **`connected_add_smul`**, proved by induction on
the number of steps: peel off one unit move toward the destination (the
discrete-convexity bound guarantees it keeps every count non-negative), then
repeat on what remains.

Put the algebra and the geometry together and you get the crown jewel, the
**Fundamental Theorem of Markov Bases** for this model
(**`noThreeWay_fiber_connected`**):

> *Any two non-negative tables with the same two-way margins can be joined by a
> walk of `±M3` moves that stays non-negative at every step.*

One move connects every fiber. The statistician's Markov chain is guaranteed
to roam the entire space it is supposed to explore — no table is ever stranded,
no region ever unreachable.

## Why a single move is such good news

It is tempting to treat "the Markov basis is just one move" as an anticlimax.
In fact it is the best possible outcome, for three reasons.

**It makes the test trustworthy.** A Markov chain that cannot reach every table
in a fiber will silently give wrong answers — it will conclude a table is
"typical" only because it never visited the tables that would prove otherwise.
The connectivity theorem is the guarantee that the chain's verdict reflects the
*whole* fiber, not a stranded corner of it. Without it, the entire procedure
rests on faith.

**It makes the test fast and simple.** With a single, explicit move, the
random walk is trivial to program: flip a coin, add or subtract the
checkerboard pattern, reject the step if it would make a count negative, repeat.
There are no exotic moves to enumerate, no special cases to handle.

**It is a window into a much larger theory.** The bridge from "the space of
moves is one-dimensional" (pure linear algebra over the whole numbers) to
"every valid table is reachable by valid steps" (pure combinatorics of walks)
is the small-scale model of the entire Diaconis–Sturmfels program. That program
connects three worlds — the algebra of polynomial ideals, the geometry of
lattices, and the statistics of contingency tables — and the `2×2×2`
no-three-way model is the gem where all three meet in their simplest
non-trivial form.

## The horizon

The natural next question is what happens with bigger tables — say `2 × 2 × n`,
where the third question has `n` possible answers instead of two. There the
magic of a single move ends: a Markov basis now needs one alternating move for
*every pair* of slices, and connecting the fibers requires juggling many
generators at once. That richer story is the genuine content of the general
Fundamental Theorem of Markov Bases, and it is the road ahead. But the
`2×2×2` case stands on its own as a small, perfect theorem: eight numbers,
twelve constraints, and one move — a checkerboard on a cube — that connects
them all.

The result above is not a sketch or a plausibility argument. Every step, from
the margin cancellation to the discrete-convexity walk, has been verified in
complete, gap-free formal detail. The miracle is real, and now it is certain.
