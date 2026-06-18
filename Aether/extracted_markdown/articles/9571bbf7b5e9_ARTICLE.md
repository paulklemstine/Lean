# The Shortest Path Through a Table: How a Single Corner Becomes a Ruler

## A puzzle hidden in a spreadsheet

Imagine a public health agency releases a small report. It cross-tabulates three
yes/no questions for a population — say, *smoker?*, *over fifty?*, and *diagnosed
with a certain condition?* The result is a tiny cube of eight numbers, a
`2 × 2 × 2` table of counts. To protect privacy, the agency does not publish the
eight raw counts. Instead it publishes only the **margins**: how many smokers
there are in each age group, how many diagnosed people in each smoking group, and
so on — every two-way summary, but never the full three-way breakdown.

Now a natural and slightly unsettling question arises. Given only those margins,
how many different underlying tables could have produced them? Are the margins
enough to pin the data down, or do they leave room for many possibilities? And if
many tables are consistent with the published margins, how *far apart* can they
be? This is not idle curiosity. It is the mathematical heart of statistical
disclosure control, of goodness-of-fit testing, and of a beautiful corner of
mathematics called **algebraic statistics**.

This article tells the story of a clean and complete answer for the smallest
interesting case. The punchline is almost shockingly simple: the entire space of
tables consistent with the published margins lines up like beads on a string, and
a *single cell of the table* — one corner of the cube — acts as a perfect ruler
measuring the distance between any two of them. We will see exactly why.

## Tables, margins, and the model

Let us fix notation. A `2 × 2 × 2` table assigns an integer count to each of the
eight cells indexed by three binary coordinates `(i, j, k)`, each `0` or `1`. Write
the count in cell `(i, j, k)` as `u(i,j,k)`. The counts are nonnegative — you
cannot have minus three people.

The **two-way margins** are the totals you get by summing out one coordinate at a
time. Summing over `k` gives a `2 × 2` face; summing over `j` gives another; summing
over `i` gives a third. Fixing all of these two-way margins is exactly the
statistician's *no-three-way interaction model*: the hypothesis that there is no
genuine three-way interplay among the three variables beyond what the pairwise
relationships already explain. A **fiber** is the set of all nonnegative integer
tables sharing one prescribed collection of two-way margins. Two tables in the same
fiber are statistically indistinguishable from the published summaries.

How do you move from one table in a fiber to another without disturbing the
margins? You need a *move*: an integer adjustment to the cells that leaves every
two-way margin untouched. For this model there is, remarkably, essentially **one**
such move. Picture the cube colored like a three-dimensional checkerboard:
alternate cells get a `+1` and a `-1`. Concretely, the move — call it `M3` — places

```
M3(i,j,k) = +1  if i + j + k is even,
M3(i,j,k) = -1  if i + j + k is odd.
```

Add `M3` to a table and watch what happens to any line of two cells that share two
coordinates: one of them is "even", the other "odd", so one goes up by one and the
other down by one. The pair's sum — a two-way margin — does not budge. Every
margin is preserved, automatically, for the same reason. This single checkerboard
move is the *Markov basis* of the model, and a classical theorem (the Fundamental
Theorem of Markov Bases, due to Diaconis and Sturmfels) guarantees that repeatedly
adding or subtracting `M3` — never letting any cell go negative — lets you travel
between **any** two tables in the same fiber.

That is the qualitative story: one move connects everything. But it leaves the
quantitative question wide open. If two tables are consistent with the same
margins, how many moves does it take to get from one to the other? Which route is
shortest? That is the gap this work closes.

## The Markov graph and the question of distance

Turn the fiber into a graph. The vertices are the nonnegative tables sharing the
margins. Draw an edge between two tables whenever a single legal move — adding
`M3`, or subtracting it — turns one into the other while keeping all cells
nonnegative. This is the **Markov graph** of the fiber. Walking along its edges is
exactly the random-walk procedure statisticians use to sample tables for
goodness-of-fit tests (the Diaconis–Sturmfels algorithm runs a Markov chain on
precisely this graph). The *graph distance* between two tables — the least number
of edges in any path connecting them — is the honest measure of how far apart two
hypotheses-compatible datasets sit.

Computing graph distances is, in general, hard: you may have to search an
enormous web of vertices. So it is a small miracle when the distance turns out to
have a closed form. Here it does, and the proof is a model of clarity built from
three observations.

## Observation one: the corner is a one-Lipschitz potential

Single out one cell — the corner `u(0,0,0)`. Because `0 + 0 + 0` is even, the move
`M3` has value `+1` there. So **every legal step changes the corner by exactly
one**: adding `M3` raises the corner by one, subtracting it lowers the corner by
one. There is no other option. In the language of the formalization, a single step
`u → v` satisfies

> *(Step changes the corner by one.)* The corner displacement `|v(0,0,0) −
> u(0,0,0)|` is at most `1`.

The corner cell is what physicists call a **potential** and what mathematicians
call a *one-Lipschitz invariant*: it can change by at most one per step. This is
the engine of everything that follows.

## Observation two: the geodesic lower bound

Stack the steps. If a walk of `n` legal moves carries `u` to `v`, the corner can
have drifted by at most one per move, so over `n` moves it can have drifted by at
most `n` in total. Formally:

> *(Geodesic lower bound.)* For any walk of `n` legal moves from `u` to `v`,
> `|v(0,0,0) − u(0,0,0)| ≤ n`.

In plain terms: **no path can be shorter than the corner displacement.** If the
corner of your starting table reads `2` and the corner of your target reads `9`,
you will need at least seven moves, no matter how cleverly you route. This is a
genuine lower bound on *every* possible path, proved by a one-line induction on the
length of the walk.

## Observation three: a path that achieves the bound

A lower bound is only half a distance formula. We also need a route that is exactly
that short. Here the geometry of the fiber cooperates beautifully. Because the
no-three-way model in this size has only the single move `M3`, the kernel
calculation shows that *any* table `v` sharing margins with `u` is literally

```
v = u + t · M3,   where   t = v(0,0,0) − u(0,0,0).
```

The whole fiber is a one-parameter family! Every member is obtained from any other
by adding an integer multiple of the one checkerboard move, and that integer is
read off directly as the difference of corner cells. To travel from `u` to `v` you
simply add `M3` (or subtract it) one unit at a time, `|t|` times in total. The only
thing to check is that you never dip below zero along the way — and you don't,
because the cells move monotonically toward their targets, a discrete-convexity
fact: if the endpoints are nonnegative, so is every step in between. This gives:

> *(Existence of a shortest geodesic.)* If `u` and `u + t · M3` are both
> nonnegative, there is a walk of length exactly `|t|` between them, nonnegative at
> every step.

## The theorem: a corner that measures everything

Put the three observations together and the distance formula falls out, exact and
unconditional:

> **Markov-graph geodesic distance.** For any two nonnegative `2 × 2 × 2` tables
> `u` and `v` with the same two-way margins, the graph distance between them in the
> Markov graph of their fiber is *exactly*
>
> `|v(0,0,0) − u(0,0,0)|`,
>
> the absolute difference of their corner cells. Moreover this distance is realized
> by an explicit walk, and no walk is shorter.

This is a statement of real elegance. The Markov graph of every fiber is not some
tangled web — it is a simple **path graph**, a single string of beads. And the
corner cell is a perfect tape measure laid along that string: it is an **isometry**
from the fiber onto an interval of integers. To know how far apart two compatible
tables are, you do not run a search algorithm or a Markov chain. You subtract two
numbers.

## Why this matters

The result is small in scope — the `2 × 2 × 2` model is the toddler of contingency
tables — but it crystallizes ideas that scale.

**Statistical disclosure and privacy.** The diameter of a fiber measures exactly
how much wiggle room the published margins leave. If the corner can range over an
interval of length `d`, then the true table is one of `d + 1` possibilities, no
more and no fewer, and they are all reachable by the simplest possible
perturbations. An agency releasing margins can compute, in closed form, how much
uncertainty it has imposed on an attacker — and how little.

**Faster sampling.** Goodness-of-fit testing by the Diaconis–Sturmfels method runs
a random walk on the Markov graph and worries about *mixing time*, which is
governed by the graph's geometry. Knowing that the graph is a path of known length
turns a hard mixing-time question into a textbook one: a random walk on an interval.

**A reusable bridge.** The deepest idea here is the **potential-function
argument**. To prove that no path can be short, find a quantity that changes by at
most a fixed amount per step and by a lot between the endpoints. That single
trick — a discrete, one-Lipschitz invariant — connects the combinatorics of
lattice walks to the metric geometry of graphs, and it reappears across
mathematics, from the analysis of sorting algorithms to the study of expander
graphs and word metrics on groups. The corner cell is the cleanest possible
instance: a coordinate that *is* the distance.

## Coda: from one cube to the wider world

What makes this satisfying is the collapse of apparent complexity. You begin with
an intimidating-sounding object — the fiber of the no-three-way interaction model,
the set of all data tables consistent with a web of marginal constraints — and you
end with a line and a ruler. The eight numbers of the cube are bound together so
tightly by their margins that seven of them are mere shadows of the eighth. Fix the
corner, and the rest of the table is determined.

Larger tables — bigger cubes, more categories, higher-way interactions — do not
collapse so cleanly; their fibers become genuinely high-dimensional polytopes whose
Markov graphs hide real combinatorial richness, and finding their geodesics is an
open frontier. But the smallest case lights the way. It shows what to look for: a
potential function that is one-Lipschitz along moves, a parameterization of the
fiber that realizes the bound, and the resulting picture of distance as a
subtraction. Sometimes the shortest path through a table is just the difference of
two corners — and recognizing when that happens is the beginning of a much larger
geometry of data.
