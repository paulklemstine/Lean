# The One Move That Shuffles Every Table

## A puzzle hidden in a spreadsheet

Imagine a market researcher who has surveyed a city. For every person she
records three yes/no facts: *Do you drink coffee?* *Do you exercise?* *Do you
sleep well?* When she tallies the answers she gets a little cube of eight
numbers — a `2 × 2 × 2` table. One cell counts the coffee-drinking,
exercising, good-sleepers; the diagonally opposite cell counts the
coffee-avoiding, sedentary, poor-sleepers; and so on through all eight
combinations.

Now she asks a statistician's favorite question: *are these three habits
genuinely tangled together, or can the data be explained by their pairwise
relationships alone?* Maybe coffee and sleep are linked, and exercise and sleep
are linked, but there is no special **three-way** conspiracy among all of them
at once. To test this she needs to compare her actual cube against the universe
of *other* cubes that share the same pairwise summaries — the same number of
coffee-and-exercise people, the same number of exercise-and-sleep people, and so
on. If her real table looks unremarkable inside that universe, the three-way
effect is an illusion.

This is the **no-three-way interaction model**, and it sits at the heart of a
field called *algebraic statistics*. The deceptively simple question it raises
is: *how do you tour that universe of tables?* You cannot just write them all
down — for large counts there are astronomically many. Instead you want a set of
**moves**, small additions and subtractions you can apply to one valid table to
hop to a neighboring valid table, such that by chaining moves you can reach every
table in the universe. Such a generating set of moves is called a **Markov
basis**, and finding one is the founding problem of the subject, opened by
Persi Diaconis and Bernd Sturmfels in 1998.

This article is about a small, perfect crystal of that theory: the `2 × 2 × 2`
case. It turns out that the entire universe of tables — no matter how large the
counts — can be explored with **a single move**. And that move has a beautiful,
checkerboard shape.

## What "same pairwise summaries" really means

Let us be precise about the constraints, because the magic lives in their
interplay. Label the three binary axes `i`, `j`, `k`, each taking the value `0`
or `1`. A table `u` assigns an integer count `u(i,j,k)` to each of the eight
cells.

The researcher's pairwise summaries are the **two-way margins**. There are three
families of them:

- **`(i,j)`-margins:** for each combination of the first two axes, add up over
  the third. In symbols, `m₁₂(i,j) = u(i,j,0) + u(i,j,1)`. (How many
  coffee-and-exercise people are there, regardless of sleep?)
- **`(i,k)`-margins:** `m₁₃(i,k) = u(i,0,k) + u(i,1,k)`. (Sum over the middle
  axis.)
- **`(j,k)`-margins:** `m₂₃(j,k) = u(0,j,k) + u(1,j,k)`. (Sum over the first
  axis.)

Two tables `u` and `v` are said to have **the same margins** when all three
families agree, every one of these summary numbers matching. That is a lot of
constraints — twelve equations in total — pinning down eight numbers. You might
expect there to be essentially no freedom left, or alternatively a tangle of
independent directions you could wiggle in. The truth is far more elegant.

## The checkerboard move

Here is the single move that does everything. Define a table `M3` by

> **`M3(i,j,k) = +1` if `i + j + k` is even, and `-1` if `i + j + k` is odd.**

Picture the eight cells of the cube colored like a three-dimensional
checkerboard: four cells get `+1`, the four "diagonal" cells get `-1`. Adding
`M3` to a table means *bumping up the four even-parity cells by one and dropping
the four odd-parity cells by one*. Subtracting `M3` does the reverse.

Why does this preserve every margin? Look at any single line through the cube —
fix two coordinates and let the third vary over `0` and `1`. Along that line the
parity `i + j + k` flips exactly once, so the two cells carry opposite signs:
one `+1` and one `-1`. Their sum is zero. Every two-way margin is exactly such a
line sum. So adding any whole-number multiple of `M3` leaves all twelve summaries
untouched. In the language of the formal development:

> **Theorem (the move is legal).** For every table `u` and every integer `t`,
> the table `u + t·M3` has exactly the same two-way margins as `u`.

The checkerboard is the smallest interesting move in all of Markov-basis theory.
In simpler models, the connecting moves are humble `2 × 2` "swaps" that add one
to two cells and subtract one from two others — degree-2 gestures. The
no-three-way move is different: it touches **all eight cells at once**. Its
*degree* (the total positive mass it shuffles) is four. That is precisely why the
no-three-way model is the textbook first example that goes *beyond* the easy,
"decomposable" cases — and why it has become a rite of passage for students of
the field.

## The astonishing rigidity: one move is all there is

You might guess that `M3` is just *one* useful move among many — a handy
generator, but surely the universe of equal-margin tables is richly
multidimensional. It is not. The space of margin-preserving moves is **rank
one**: every single legal move is a whole-number multiple of the checkerboard.

> **Theorem (rank-one move lattice).** If two tables `u` and `v` have the same
> two-way margins, then their difference is exactly `(v(0,0,0) − u(0,0,0))·M3`.
> In other words, `v = u + t·M3` for the integer `t = v(0,0,0) − u(0,0,0)`.

The proof is a lovely cascade. Suppose a move `w` (the difference of two
equal-margin tables) has all margins zero. Start at the corner cell `w(0,0,0)`,
and call its value `t`. Because the `(i,j)`-margin along the line varying `k`
must be zero, `w(0,0,1) = −t`. Because another margin forces the next cell, you
get `w(0,1,0) = −t`, then `w(1,0,0) = −t`, and continuing the sign-flips around
the cube, each cell is forced to be exactly `±t` according to the parity of its
address — which is to say `w = t·M3`. The whole eight-dimensional cube collapses
onto a single line the moment you demand that the margins vanish. **Twelve
constraints conspire to leave exactly one degree of freedom.**

This is the precise sense in which the checkerboard *is* the Markov basis: the
singleton set `{M3}` generates every margin-preserving move. There is nothing
else to find.

## From algebra to a walk you can actually take

Knowing that `v = u + t·M3` is a statement about *integers*. But a statistician
needs something stronger: the tables in her universe must have **non-negative**
counts — you cannot survey `−3` people. So the real question is whether you can
walk from `u` to `v` *one step at a time, by adding or subtracting `M3`,* and
**stay non-negative at every intermediate table.** If a single move ever drives a
cell below zero, that step is illegal, and the path is broken.

Here the geometry saves us. Restrict attention to the line of tables `u + s·M3`
as `s` ranges over the integers. As `s` grows, the four even-parity cells
increase and the four odd-parity cells decrease (or vice versa). The set of `s`
for which *all eight cells stay non-negative* is an unbroken **interval** of
integers — a discrete convexity phenomenon. If both endpoints `u` (at `s = 0`)
and `v` (at `s = t`) are non-negative, then every integer between them is
non-negative too. So you can march from `u` to `v` in unit steps of `±M3`
without ever stumbling below zero.

> **Theorem (Fundamental Theorem of Markov Bases, this model).** Any two
> non-negative tables with the same two-way margins are joined by a walk of
> `±M3` moves that stays non-negative at every step. Equivalently, the single
> move `M3` connects every fiber of the no-three-way interaction model.

This is the punchline. The intimidating universe of equal-margin contingency
tables — potentially enormous, defined by a dozen simultaneous equations and a
positivity constraint — is in fact a single, gap-free *path*. You start at any
table, repeatedly stamp the checkerboard up or down, and you can reach any other
table with the same summaries, never leaving the legal region. The whole fiber is
a string of beads, and `M3` is the thread.

## Why this matters: sampling without enumerating

The reason Markov bases were invented is *computation*. To judge whether a real
table is surprising, you want to draw random samples from its fiber — the cloud
of tables with identical margins — and see where the real one falls. The
**Diaconis–Sturmfels algorithm** does exactly this: pick a move from the Markov
basis at random, propose adding or subtracting it, accept the step if it keeps
all counts non-negative (with a Metropolis-style acceptance rule for weighted
sampling), and repeat. After enough steps you have wandered the fiber as if you
had sampled it directly — *without ever listing its members.*

For this random walk to be valid, it must be able to reach every table in the
fiber; otherwise your sample is trapped in a corner and your statistical test is
biased. That reachability is *precisely* the connectivity guaranteed by a Markov
basis. So the theorem above is not an abstraction — it is the license that makes
the standard exact test for three-way independence trustworthy. When a
biologist tests whether three genetic markers interact, or a social scientist
tests whether three attitudes co-vary beyond their pairwise links, the
checkerboard move is quietly doing the work underneath.

## A glimpse beyond the cube

The clean miracle of "one move connects everything" is special to the
`2 × 2 × 2` case. Stretch the third axis to `n` categories — a `2 × 2 × n`
table — and the move lattice is no longer rank one. Now a Markov basis consists
of one checkerboard move for **every pair** of slices along the long axis: pick
two values of `k`, restrict to those two `2 × 2` faces, and place a checkerboard
there. The number of generators grows, and proving that they connect every fiber
becomes the genuine, hard content of the Fundamental Theorem — no longer a
single tidy line, but a web of intersecting walks.

That escalation is the real research frontier, and the `2 × 2 × 2` crystal is
the seed of intuition for it. In the small case you can *see* why margins force
sign-flips around a cube, why those flips line up into a single checkerboard, and
why the non-negative tables along a move form an unbroken interval. Carry those
three ideas — **sign propagation**, **rank collapse**, and **discrete
convexity** — into higher dimensions, and the architecture of the whole theory
comes into focus.

## The shape of the idea

Strip away the statistics and what remains is a small, sharp fact about a cube of
numbers. Twelve linear constraints, applied to eight unknowns, do not leave a
messy residue: they leave a single line, and along that line the legal
(non-negative) tables form one connected segment. The object that parametrizes
that line is a checkerboard of `+1`s and `−1`s — the most symmetric pattern the
cube admits.

It is a reminder of why mathematicians love their smallest examples. The
`2 × 2 × 2` no-three-way model is tiny enough to hold in your head and rich
enough to contain, in miniature, the entire logic of Markov-basis theory: a
question about *exploring* a constrained space, answered by *generating* it with
explicit moves, certified by a *connectivity* proof. One checkerboard, and the
whole universe of tables falls into a line.
