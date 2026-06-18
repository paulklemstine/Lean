# The Hidden Geometry of Counting: How One Move Shuffles Every Table

## A puzzle from the census office

Imagine you are a statistician handed a small table of counts. Three yes/no
questions were asked of a group of people — say, *Do you smoke?*, *Do you
exercise?*, and *Do you sleep well?* — and the survey software has, for privacy
reasons, thrown away the individual answers. All you are left with are the
**summaries**: how many people smoke and exercise, how many exercise and sleep
well, how many smoke and sleep well, and so on. Each of these is a two-way
summary, a *margin*, obtained by collapsing one of the three questions.

Here is the natural question. Given only those summaries, what could the original
table of counts have looked like? There are eight possible answer-combinations
(smoker/non-smoker × exerciser/non-exerciser × good-sleeper/bad-sleeper), so the
hidden table is a cube of eight numbers. The margins pin down many sums of these
numbers, but not the numbers themselves. The set of all eight-number tables that
are consistent with the given margins — and that use only non-negative whole
numbers, because you cannot have minus three people — is called a **fiber**.

Understanding the fiber matters enormously in practice. It is the engine behind
*exact tests* in statistics: to judge whether your data are surprising, you want
to wander randomly and uniformly through all the tables that share the same
summaries, and see whether your particular table looks typical or extreme. But to
wander through the fiber, you need a way to step from one valid table to another
**without ever changing the margins and without ever going negative**. You need a
set of legal moves. The deep and beautiful theory that answers this question is
called the theory of **Markov bases**, and it sits at the crossroads of algebra,
geometry, and statistics. This article tells the story of the smallest example
where that theory shows its true face — and of the single, elegant move that runs
the whole show.

## What is a legal move?

Let us be concrete. Write the hidden table as eight integers `u(i, j, k)`, where
each of `i`, `j`, `k` is either `0` or `1`. The three families of two-way margins
are:

- the **(i, j)-margins**: for each pair `(i, j)`, the sum `u(i, j, 0) + u(i, j, 1)`
  (collapse the third question);
- the **(i, k)-margins**: for each pair `(i, k)`, the sum `u(i, 0, k) + u(i, 1, k)`
  (collapse the second question);
- the **(j, k)-margins**: for each pair `(j, k)`, the sum `u(0, j, k) + u(1, j, k)`
  (collapse the first question).

This is the celebrated **no-three-way interaction model**. The name comes from
statistics: fixing all three families of two-way margins is exactly the act of
modelling the data with pairwise associations but *no genuine three-way
interaction* among the variables.

A **legal move** is a way of changing the table — adding some pattern of integers
to it — that leaves *all twelve* margins untouched. If a move keeps every margin
fixed, you can apply it to any valid table and land on another table with the same
summaries. The collection of all legal moves forms what algebraists call a
**lattice**: you can add moves together, subtract them, and scale them by whole
numbers, and you always get another legal move. A **Markov basis** is a finite set
of moves that is rich enough to reach every table in every fiber, taking small
steps that never stray into negative territory.

The grand result of the field, the **Fundamental Theorem of Markov Bases** of
Persi Diaconis and Bernd Sturmfels (1998), guarantees that such a finite generating
set always exists, and ties it to a piece of pure algebra (the generators of a
so-called toric ideal). In general, finding the Markov basis is hard. But for our
little cube something almost magical happens.

## One move to rule them all

How many independent legal moves are there for the 2×2×2 cube? There are eight
cells and a dozen margin equations, so you might expect a tangle of competing
adjustments. The astonishing answer is: **there is essentially only one.**

The single generating move is the **alternating sign pattern**

```
M3(i, j, k) = (-1)^(i + j + k),
```

that is, `+1` whenever `i + j + k` is even and `-1` whenever it is odd. Picture the
unit cube with its eight corners coloured like a 3-D checkerboard: four corners get
`+1`, the four diagonally opposite corners get `-1`. Adding this pattern to a table
nudges four cells up by one and four cells down by one, in a perfectly balanced
way.

Why does this preserve every margin? Take any *line* through the cube — fix two of
the coordinates and let the third run over `0` and `1`. Along that line the two
values of `M3` are always one `+1` and one `-1`, because flipping a single
coordinate flips the parity of `i + j + k`. So every line sums to `+1 + (-1) = 0`.
But the margins are precisely sums along lines. Therefore adding any whole-number
multiple of `M3` changes no margin at all. In the formal development this is the
theorem

> **Move preserves margins.** For every table `u` and every integer `t`, the table
> `u + t·M3` has exactly the same two-way margins as `u`.

So `M3` is genuinely a legal move. The surprise is that it is the *only* one you
ever need.

## Why a single move is enough: the rigidity of the cube

Suppose two tables `u` and `v` have identical margins. Their difference
`w = v − u` is then a legal move with **all margins zero**. The claim — the heart
of the matter — is that any such `w` must be a whole-number multiple of `M3`.

The argument is a cascade of forced choices. Pick the corner value `w(0, 0, 0)` and
call it `c`. The (i, j)-margin condition on the edge above it says
`w(0, 0, 0) + w(0, 0, 1) = 0`, so `w(0, 0, 1) = −c`. The (i, k)-margin says
`w(0, 0, 0) + w(0, 1, 0) = 0`, so `w(0, 1, 0) = −c`. The (j, k)-margin forces
`w(1, 0, 0) = −c`. Each single sign flip of a coordinate flips the value, and as
you walk to the far corner `w(1, 1, 1)` you flip three times, landing back on `+c`.
Working through all eight cells, every value is `±c`, and the sign is exactly
`(-1)^(i + j + k)`. In other words `w = c·M3`. Formally:

> **The move lattice has rank one.** If `u` and `v` have the same two-way margins,
> then `v = u + (v(0,0,0) − u(0,0,0))·M3`.

This single equation is the statement that **`{M3}` is a Markov basis** — the
entire lattice of legal moves is the set of integer multiples of one pattern. A
problem that looked eight-dimensional collapses to a single line.

## Staying positive: a walk that never goes negative

Knowing that `v − u` is a multiple of `M3` is not quite the end of the story. A
table of counts must stay non-negative throughout. If you need to add, say,
`5·M3` to get from `u` to `v`, can you do it in five unit steps `+M3, +M3, …`
such that *every intermediate table* still has only non-negative entries? Or might
the path dip below zero and out of the world of valid tables?

This is where a piece of quiet geometry takes over. Think of the whole journey as
sliding along a straight line — the **move line** — in the eight-dimensional space
of tables, parametrised by how many copies of `M3` you have added. Look at any one
cell. As you slide, that cell's value changes by `+1` or `−1` per step, depending
on the sign of `M3` there; it is a straight, monotone ramp. The condition "this
cell is non-negative" therefore holds on a single unbroken interval of the line.
Intersecting eight such conditions, the set of positions where the *whole table* is
non-negative is itself a single interval — a convex chunk of the line.

Both endpoints `u` and `v` are valid, so they sit inside that interval; and because
the interval is unbroken, **every integer point between them is valid too**. A
monotone walk of unit `±M3` steps from `u` straight toward `v` never leaves the
interval, hence never goes negative. This is the principle of **discrete
convexity**, and it is the technical engine of the whole result:

> **Connectivity of the move line.** If `u` and `u + t·M3` are both non-negative,
> then they are joined by a walk of `±M3` steps that stays non-negative at every
> step. (Proved by induction on the number of steps `|t|`: take one unit step
> toward the target; the convexity bound guarantees you are still non-negative,
> then repeat.)

Concretely, the induction reasons like this. Suppose a cell carries `M3 = −1`, so
the step `+M3` *decreases* it. If the far endpoint, after subtracting many copies,
is still `≥ 0`, then the near value must have been at least as large as the number
of steps remaining — so subtracting one keeps it `≥ 0`. Symmetrically for cells
with `M3 = +1`. Every cell stays safe, so the whole table stays safe. Chain the
steps and the walk is complete.

## The Fundamental Theorem, in miniature

Putting the two halves together gives the punchline, the Fundamental Theorem of
Markov Bases specialised to this model:

> **Every fiber is connected by the single move `M3`.** Any two non-negative
> tables with the same two-way margins are joined by a walk of `±M3` steps that
> stays non-negative throughout.

Take any two valid tables sharing all their summaries. Rigidity tells you they
differ by a whole-number multiple of `M3`. Discrete convexity tells you that the
straight walk between them, step by step, never goes negative. So you can reach any
table from any other, using nothing but the checkerboard move. The fiber, however
many tables it contains, is a single connected world, and one move is its map.

## Why this is the textbook first example

You might wonder why so much fuss is made over a 2×2×2 cube. The reason is that it
is the *smallest model whose Markov basis is not a boring swap*. For the simplest
models — two-way tables of independence — the only move you ever need is the humble
`2×2` swap: add one to two diagonal cells, subtract one from the other two. That
move has degree 2; it touches four cells in a flat rectangle. The no-three-way move
`M3` is different in kind: it has **degree 4**, it touches all eight cells of the
cube at once, and there is no way to break it into smaller legal pieces. It is the
first genuinely three-dimensional move in the subject, the place where the theory
stops being obvious. That is exactly why Diaconis and Sturmfels chose it as their
flagship illustration, and why it earns its place as a cornerstone example.

There is also a sharp boundary lurking nearby, and it is worth naming. The miracle
here is that the move lattice has **rank one** — a single generator. But this is a
feature of the cube being 2×2×2. The instant you enlarge even one dimension — to a
`2×2×n` model with more than two slices — the lattice sprouts several independent
generators, the single-line walk argument breaks, and you truly need the full
multi-generator strength of the Fundamental Theorem. The 2×2×2 cube is poised
exactly on the edge of simplicity: complex enough to be interesting, simple enough
to understand completely. Knowing precisely where rank-one stops working is itself
one of the most useful signposts the subject offers.

## The bigger picture

What makes this story lovely is how three different kinds of mathematics meet on a
single small object. There is **statistics**, in the guise of contingency tables,
margins, and the exact tests that wander through fibers. There is **linear algebra
over the integers**, in the lattice of legal moves and the rank-one kernel
computation. And there is **discrete geometry**, in the convexity argument that
keeps the walk positive. The no-three-way model is where these threads tie
themselves into a single, surprisingly tight knot.

The practical payoff is real. Markov bases power the random walks behind exact
goodness-of-fit testing for categorical data — the kind of analysis used to check
whether an apparent association in a survey, a clinical trial, or a genetics study
is real or just noise. Every time such a test runs, it is shuffling a table by
legal moves, exploring a fiber, asking the same question our census officer asked:
given only the summaries, what could the truth have been? For the 2×2×2 cube, the
answer is as clean as mathematics ever gets. One checkerboard move, applied again
and again, visits every possibility — and never has to imagine a negative person.
