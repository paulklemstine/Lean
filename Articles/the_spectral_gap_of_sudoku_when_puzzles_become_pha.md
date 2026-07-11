# The Spectral Gap of Sudoku: When Puzzles Become Phase Transitions

## A puzzle inside the puzzle

Everyone who has filled in a Sudoku grid knows the two moods of the game. Some
puzzles melt away: fill in one forced square, and a cascade of others follows.
Others resist for an hour, every cell frustratingly ambiguous, the grid seeming
to shimmer between many possible answers. It feels as though there is a hidden
temperature to a puzzle — a quantity that decides whether it is frozen solid or
still liquid with possibility.

Physicists have a precise name for a system that abruptly changes character as
you turn a knob: a **phase transition**. Water becomes ice at a sharp
temperature; a magnet loses its magnetism at a sharp temperature. The tempting
story about Sudoku is that it has a phase transition too, governed by a single
knob — the number of *clues*, the pre-filled digits you are handed at the start.
Give a solver too few clues and the puzzle dissolves into countless solutions;
give it too many and the answer is rigidly unique. Somewhere in between, the
folklore says, sits a razor-thin critical point where puzzles are maximally
hard.

This article is about testing that story with the actual mathematics of random
sampling — and discovering that the popular version is *wrong in an instructive
way*. The number of clues is a red herring. The real order parameter, the true
knob behind the phase transition, is a geometric property of how a puzzle's
solutions are wired together. To see this, we need to turn a static puzzle into
something that moves.

## Turning a puzzle into a walk

Imagine you already have a completed, valid grid, and you want to produce a
*different* valid grid, chosen fairly at random. A natural way is to make small,
constraint-preserving edits. In Sudoku, the cleanest such edit is a **compatible
swap**: find two cells whose digits can be exchanged without breaking any row,
column, or box rule, and exchange them. Do this over and over, occasionally
choosing to stay put, and you perform a random walk through the space of valid
grids.

This is a **Markov chain** — a process that hops from state to state with fixed
probabilities. Its states are all the admissible completions of the puzzle. Two
states are joined by a step whenever a single compatible swap turns one into the
other. Collect these adjacencies into a graph $G$, the **move graph**, whose
vertices are the solutions and whose edges are the legal swaps. Everything about
how the walk behaves is encoded in $G$.

We can write the walk as a matrix. Fix a small step rate $c>0$. From a solution
$x$ with $\deg(x)$ available swaps, the transition probabilities are

$$P(x,y)=\begin{cases} 1-c\,\deg(x) & \text{if } y=x,\\ c & \text{if a compatible swap joins } x \text{ and } y,\\ 0 & \text{otherwise.}\end{cases}$$

As long as $c$ is no larger than $1/\Delta$, where $\Delta$ is the largest number
of swaps out of any solution, every row of $P$ is a genuine probability
distribution: the entries are nonnegative and, as one checks directly, they sum
to $1$. Moreover $P$ is **symmetric**, $P(x,y)=P(y,x)$, because a swap that takes
$x$ to $y$ is exactly the swap that takes $y$ back to $x$. A symmetric stochastic
matrix is *doubly* stochastic, and that single fact tells us the walk's
long-run distribution is **uniform**: run it long enough and every valid grid is
equally likely. That is precisely what we want from a fair sampler.

## Mixing time and the spectral gap

The question that matters is *how long is long enough?* How many swaps must we
make before the walk forgets where it started and delivers a genuinely random
solution? This waiting time is the **mixing time**, and it is controlled by the
eigenvalues of $P$.

Because $P$ is symmetric, all its eigenvalues are real, and because it is
stochastic the largest is always $\lambda_1 = 1$, carried by the constant vector.
The decisive quantity is the distance from $1$ down to the *second* eigenvalue
$\lambda_2$:

$$\text{spectral gap} = \lambda_1 - \lambda_2 = 1 - \lambda_2.$$

A **large** gap means fast mixing: the walk equilibrates in a small number of
steps, so random solutions are easy to generate. A gap **near zero** means the
walk crawls, trapped for enormous stretches before it explores freely. A gap of
**exactly zero** is the extreme case: the walk never mixes at all, because $1$ is
no longer the unique top eigenvalue.

So "how hard is it to sample a solution?" becomes "how big is the spectral gap?"
And the spectral gap, we will see, is a property of the geometry of $G$ — not of
the clue count.

## The Laplacian hiding in one step

Here is the small miracle that unlocks everything. Apply the transition matrix to
any function $f$ assigning a number to each solution, and a short computation
shows that one step does the following at each state $x$:

$$(Pf)(x) = f(x) + c\Big(\textstyle\sum_{y\sim x} f(y) - \deg(x)\,f(x)\Big).$$

The bracketed term is the **discrete Laplacian** of the move graph — the same
operator that governs heat flow on a network, the vibration of a spring mesh, and
the diffusion of a rumor through a social graph. In one clean identity, the walk
becomes $P = I - cL$, where $L$ is the graph Laplacian. The mixing of a Sudoku
sampler is heat diffusion on the graph of its solutions.

This identity immediately explains which functions the walk leaves *unchanged*.
A vector $f$ is fixed, $Pf=f$, exactly when the Laplacian term vanishes, i.e.

$$\deg(x)\,f(x) = \sum_{y\sim x} f(y) \quad\text{for every } x.$$

In words: the value at every solution equals the average of the values at its
swap-neighbors. This is the **discrete mean-value property** — the defining
feature of *harmonic* functions. The eigenvalue $1$ of the walk is exactly the
space of harmonic functions on the move graph. To understand mixing, we must
understand how many harmonic functions there are.

## The true phase transition: connected or not

Now comes the heart of the matter, and it is a dichotomy as crisp as ice versus
water.

**If the move graph is disconnected**, the walk cannot mix — and the reason is
beautifully simple. Split the solutions into two groups that no compatible swap
can bridge. Let $f$ be the function that is $1$ on one group and $0$ on the other.
At any solution, all of its neighbors lie in the same group, so the mean of the
neighbors equals the value at the center: $f$ is harmonic. But $f$ is *not*
constant. So the eigenvalue $1$ is carried by at least two independent vectors,
which forces $\lambda_2 = 1$ and

$$\text{spectral gap} = 0.$$

Remarkably, this holds for *every* step rate $c$ — the obstruction is purely
combinatorial. A walk on a disconnected graph is trapped forever in whichever
component it started in; it can never reach the solutions on the other side. This
is the genuine "no mixing" regime.

**If the move graph is connected**, the opposite is true: the *only* harmonic
functions are the constants. This is the discrete **maximum principle**, and its
proof is a small gem. Pick a solution $x_M$ where $f$ attains its maximum value
$M$. The mean-value property says $M$ equals the average of $f$ over the
neighbors of $x_M$; but none of those neighbors can exceed $M$, and an average of
things no larger than $M$ can equal $M$ only if every one of them *is* $M$. So all
neighbors of $x_M$ also attain the maximum. Repeat: their neighbors attain it
too, and — because the graph is connected — the maximum spreads to every single
solution. Hence $f$ is constant. The eigenvalue $1$ is **simple**, exactly the
condition that leaves room for a strictly positive gap and genuine mixing.

The dividing line, then, is not a clue density. It is a single yes/no question:
**is the graph of compatible swaps connected?** Connectivity is the order
parameter; the "phase transition" is the reducible/irreducible dichotomy of the
move graph.

## Two puzzles, same clues, opposite fates

To see that the clue count is genuinely irrelevant, it helps to shrink Sudoku to
its skeleton and compute everything by hand. Consider a puzzle with exactly two
valid solutions.

If a single compatible swap turns one solution into the other, the move graph is
a single edge — the smallest connected graph. Its walk is the $2\times 2$ matrix
whose off-diagonal entries are $c$. The constant vector $(1,1)$ has eigenvalue
$1$; the alternating vector $(1,-1)$ has eigenvalue $1-2c$. The spectral gap is

$$1 - (1 - 2c) = 2c > 0.$$

The walk mixes, at a rate you can dial with $c$.

Now take a *different* puzzle that also has exactly two solutions, but where no
compatible swap connects them. The move graph is two isolated points, the walk
matrix is the identity, every vector is fixed, and the gap is $0$. The walk never
moves; it can never turn one solution into the other.

Two puzzles, identical in every count a folklore theory would notice — same
number of solutions, and one can even arrange the same number of clues — yet one
mixes and the other is frozen. The distinguishing feature is invisible to clue
counting and visible only in the wiring of the move graph. This is a direct,
concrete refutation of the slogan "the gap is a function of the number of clues."

## Why the graph breaks into pieces

If connectivity is everything, we should understand *why* the move graph of a
real Sudoku puzzle so often shatters into disconnected pieces. The answer is a
**conservation law**.

A compatible swap merely rearranges digits already present in a line; it never
introduces a new value or removes an old one. So it preserves the *multiset* of
values in each row, each column, and each box. Concretely, take any valid row: it
is a bijection onto the nine symbols $\{0,1,\dots,8\}$, so its entries always sum
to

$$0 + 1 + 2 + \cdots + 8 = 36,$$

no matter how the swaps shuffle them. That $36$ is an invariant — a quantity the
walk can never change. Every conserved statistic of this kind carves the solution
space into level sets, and no move can cross from one level set to another. The
move graph therefore lives inside these fibers, and the connected components of
the walk are refinements of them. Conserved multiset statistics are the reason
the graph splits into invariant blocks, and blocks are the reason a walk can be
trapped.

## What Sudoku was really telling us

The lesson generalizes far beyond a newspaper grid. *Every* constraint
satisfaction problem — scheduling, graph coloring, protein folding on a lattice,
error-correcting codes — comes with a sampler built from local, constraint-
preserving moves, and every such sampler is a random walk on a move graph. The
folklore instinct is always the same: blame the difficulty on some scalar count
of constraints. The mathematics says otherwise. Difficulty of sampling is a
**geometric** property of how solutions connect to one another under local moves.

A connected move graph guarantees the top eigenvalue is simple and mixing is
possible; a disconnected one guarantees a zero gap and a trapped walk; and the
size of the gap in between is governed by *bottlenecks* — narrow bridges between
otherwise well-connected regions — exactly the quantity that Cheeger-type
inequalities relate to graph conductance. What looked like a mysterious hardness
"temperature" of a puzzle turns out to be the humble, computable connectivity of
a network you can draw.

So the next time a Sudoku resists you, resist the urge to count its clues. The
real question is whether its solutions form one connected web or a scattering of
islands. That, and not the number of givens, is the phase transition hiding
inside the puzzle.
