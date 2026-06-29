# The Tiny Swap That Shuffles Every Table

## A puzzle hidden in a spreadsheet

Imagine a market researcher with a grid of numbers. Down the side are age
groups; across the top are favorite ice-cream flavors. Each cell holds a count:
how many people of that age picked that flavor. The grid has totals — how many
people are in each age group, how many people chose each flavor. Statisticians
call this a *contingency table*, and the row-and-column totals are its *margins*.

Now ask a deceptively simple question. Suppose you only trust the margins — the
age totals and the flavor totals — but you suspect the individual cell counts
might be noise. How many *other* grids are consistent with exactly the same
margins? And can you reach every one of them, starting from the grid you have,
by making small, reversible adjustments that never break the totals and never
produce a negative count?

This is not an idle riddle. It sits at the center of how scientists decide
whether two variables — age and taste, treatment and recovery, neighborhood and
income — are genuinely related or merely look related by chance. The answer
turns out to depend on a single, almost laughably small gadget: a `2 × 2`
swap that we can prove, with complete rigor, is powerful enough to reach *every*
table sharing the same margins.

This article tells the story of that gadget, why it works, and why a result that
sounds like bookkeeping is actually one of the load-bearing theorems of modern
statistics.

## Why margins matter: the independence test

Return to the ice-cream grid. A scientist wants to know: does flavor preference
depend on age, or are the two independent? The honest way to answer is to
compare the table you actually observed against the *universe of all tables that
could have produced the same margins*. If your observed table looks utterly
ordinary inside that universe, you have no evidence of a relationship. If it
looks like a wild outlier, you do.

The catch is that this universe can be astronomically large. For even a modest
grid with modest totals, the number of valid tables can dwarf the number of
atoms you'd care to count. You cannot list them all. Instead, statisticians take
a *random walk*: start at one valid table, take a small random step to a
neighboring valid table, then another, and another, wandering through the
universe of possibilities. If the walk is set up correctly, the tables it visits
form a representative sample, and you can estimate how unusual your observed
table really is. This is the engine behind a whole family of exact tests
(Fisher's exact test is the famous `2 × 2` special case) and behind the
Monte Carlo methods that make those tests practical for large grids.

But a random walk is only trustworthy if it can, in principle, *reach
everywhere*. If some valid tables are stranded on islands the walk can never
visit, the sample is biased and the conclusions are wrong. So everything hinges
on one structural guarantee: that the small steps we allow are rich enough to
connect the entire universe of tables with a given set of margins.

## The basic move

Here is the small step. Pick two distinct rows — call them `i` and `i'` — and
two distinct columns — `j` and `j'`. They mark out a little `2 × 2`
rectangle inside the grid, four cells at the corners. Now adjust just those four
cells in a perfectly balanced pinwheel:

```
            column j     column j'
   row i   [   -1    ][   +1    ]
   row i'  [   +1    ][   -1    ]
```

Add one to two diagonal corners, subtract one from the other two. Everything
else in the grid is untouched. We call this the **basic move**
`B(i, i', j, j')`.

Look at what it does to the totals. In row `i`, we subtracted one in column `j`
and added one in column `j'`: net change zero. In row `i'`, the same balancing
act: net zero. So *no row total changes*. By the identical argument applied to
columns — each affected column gains one in one row and loses one in another —
*no column total changes either*. The pinwheel is invisible to the margins.

That is the first thing we prove rigorously:

> **Margins are preserved.** For any choice of two distinct rows and two distinct
> columns, adding the basic move to any table leaves every row sum and every
> column sum exactly as it was.

The basic move, in the language of the field, lies in the *kernel of the margin
map*. It is a legal step: it walks from one valid table to another. (There is a
small honesty clause here worth flagging — the rows must genuinely be distinct
and so must the columns. If you tried to use the same row twice the pinwheel
would collapse and the balancing would fail. The distinctness is exactly what
makes the cancellation work.)

There is one more requirement for a step to be *usable*, not just *legal*: it
must not push any cell below zero. You cannot have negative people in a cell.
A move is only allowed if, after applying it, every count is still
non-negative. This non-negativity constraint is what makes the problem
genuinely hard — it is easy to connect tables if you allow negative entries, but
the real universe lives in the non-negative corner.

## The real theorem: nothing is stranded

Now the headline. We want to show that these little pinwheels are enough — that
starting from *any* valid non-negative table, you can reach *any other* valid
non-negative table with the same margins, taking one legal, non-negative basic
move at a time.

> **The Fundamental Theorem of Markov Bases (independence model).**
> Any two non-negative integer tables with equal row margins and equal column
> margins are joined by a walk of basic `2 × 2` swap moves that stays
> non-negative at every single step.

No table is ever stranded. The universe is one connected continent, and the
basic move is the only vehicle you need. This is a classical result of Persi
Diaconis and Bernd Sturmfels from the 1990s, the cornerstone of the field they
named *algebraic statistics*. What we have done is build a complete,
machine-checked proof of it from first principles, with every logical gap
filled.

## How the proof works: walking downhill

The beauty of the argument is that it is constructive — it does not merely assert
a path exists, it tells you how to find one. The trick is to introduce a notion
of *distance* between two tables and then show you can always take a step that
shrinks it.

Define the distance `D(u, v)` between two tables `u` and `v` as the total
discrepancy: go cell by cell, take the absolute value of the difference, and add
them all up. This is the *taxicab* or `ℓ¹` distance. It has the obvious but
essential property:

> **Zero distance means identical.** `D(u, v) = 0` exactly when the two tables
> are the same in every cell.

So if we are at table `u`, want to reach table `v`, and the distance is not yet
zero, the tables differ somewhere. Our job is to take a single legal basic move
that brings us strictly closer — that decreases `D`. If we can always do that,
then since `D` is a non-negative whole number, it cannot decrease forever; the
walk must terminate, and it can only terminate at distance zero, which is `v`
itself.

The heart of the matter, then, is: *given two different tables with the same
margins, find a basic move that points downhill.* This is where a lovely
three-step pigeonhole argument enters.

### The three-step pigeonhole

Compare `u` and `v` cell by cell; call the difference grid `d = u - v`. Because
the two tables have *the same margins*, every row of `d` sums to zero and every
column of `d` sums to zero, and so the grand total of `d` is zero.

1. **Find a surplus.** Since `u ≠ v`, the difference grid `d` is not all zeros,
   but its entries sum to zero — so they cannot all be positive and cannot all be
   negative. There must be a strictly positive cell. Pick one; call it
   `(i, j)`. Here `u` overshoots `v`.

2. **Find a deficit in the same row.** Look along row `i` of the difference grid.
   It sums to zero, yet we just found a positive entry in it. To balance, there
   must be a *negative* entry in the same row — a column `j'` where `u`
   undershoots `v`. Now we have two corners of a pinwheel: a surplus at
   `(i, j)` and a deficit at `(i, j')`, and necessarily `j ≠ j'` because one
   entry is positive and the other negative.

3. **Find a surplus in the new column.** Look down column `j'` of the difference
   grid. It also sums to zero, and we just found a negative entry in it — so it
   must contain a *positive* entry, in some row `i'`. That gives the fourth
   corner, a surplus at `(i', j')`, with `i ≠ i'` forced again by the opposite
   signs.

We have located a `2 × 2` frame whose sign pattern is exactly aligned with
the pinwheel: surplus, deficit, surplus at three of its corners. Apply the basic
move oriented to push each of those corners toward `v`.

### Why the step really goes downhill

Three of the four corners we touch are corners where we *know* the move shifts
`u` one unit toward `v` — each of those three contributes a decrease of one to
the total distance. The fourth corner is a wildcard: in the worst case it moves
one unit *away*, adding one back. The arithmetic is then decisive: at worst
`−1 − 1 − 1 + 1 = −2`. The distance drops by at least two with every step. It
genuinely goes downhill.

> **Each aligned move strictly shrinks the distance.** Applying the sign-aligned
> basic move to `u` produces a table strictly closer to `v` in taxicab distance.

And crucially, the move stays in the legal, non-negative world: the three cells
we decrease were *above* their target values in `v`, which are themselves
non-negative, so subtracting one keeps them non-negative; the cells we increase
obviously stay non-negative. Every step is a real, usable step.

Chain these decreasing steps together and you have your walk. Formally, the
proof runs by strong induction on the distance: if the distance is zero we are
already there; otherwise take one downhill step and recurse on the strictly
smaller distance. This is the entire skeleton of the Fundamental Theorem.

## Two-way streets

One more elegant touch completes the picture. Every basic move is reversible.
The inverse of the pinwheel `B(i, i', j, j')` is simply the pinwheel with its two
rows swapped, `B(i', i, j, j')` — it negates every change, undoing the move
exactly. So if you can legally step from `u` to `v`, you can legally step back
from `v` to `u`.

> **Connectivity is an equivalence relation.** The "reachable by basic moves"
> relation is reflexive (you can stay put), transitive (chain two walks), and now
> symmetric (reverse any walk). It carves the universe of all non-negative tables
> into disjoint equivalence classes — and those classes are *exactly* the fibers,
> the bundles of tables sharing the same margins.

This is the clean conceptual payoff. The margins define an invariant; the basic
moves generate all transformations that preserve the invariant; and the orbits
of those moves recover the margins exactly. Nothing leaks, nothing is stranded,
nothing is missing. The algebra and the combinatorics fit together perfectly.

## Why this is more than bookkeeping

It is tempting to look at a pinwheel of plus and minus ones and see a triviality.
The depth is in the universal quantifier. The claim is not that *some* tables are
connected, or that *most* are, but that *every* pair of valid tables, in grids of
*any* size, with *any* margins, no matter how the counts are distributed, is
connected by these moves alone — and connected without ever stepping outside the
legal non-negative region. Proving a statement that ranges over an infinite,
unbounded family of grids requires a genuine idea, and the distance-reduction
argument with its three-step pigeonhole is that idea, distilled to its essence.

The practical stakes are real. Every time a scientist runs an exact test of
independence by Monte Carlo — in genetics, in ecology, in social science, in
clinical trials — they are implicitly trusting that their random walk can reach
the whole space. This theorem is the certificate that it can. It is the
difference between a sampler that explores the truth and one that quietly samples
a biased fragment of it and reports a confident, wrong answer.

And the basic move is the gateway to a vast generalization. Replace the
independence model with a more elaborate one — three-way tables, hierarchical
models, logistic regression designs — and you ask the same question: what is the
minimal toolkit of moves that connects every fiber? That toolkit is called a
*Markov basis*, and the surprising bridge that Diaconis and Sturmfels built is
that it corresponds, exactly, to the generators of a certain algebraic object (a
toric ideal). A question about random walks on grids becomes a question in
commutative algebra, and the two answer each other. The humble `2 × 2`
pinwheel is where that bridge touches down.

## The takeaway

Sometimes the most important theorems are the ones that promise *you cannot get
lost*. Here is a universe of tables, defined only by their edge totals,
potentially vaster than anything we could enumerate. Through it threads a single
kind of move — four cells, a balanced pinwheel, totals untouched, counts kept
honest. And the guarantee, proved with no gaps, is that this one move reaches
every corner of that universe. The map is connected. The walk goes everywhere.
The science built on top of it stands on solid ground.
