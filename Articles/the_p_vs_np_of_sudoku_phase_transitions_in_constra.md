# The Hidden Graph Inside Every Sudoku

## A puzzle that is secretly a coloring problem

Every day, millions of people pick up a pencil and start filling in a Sudoku
grid. The rules feel almost trivially simple: place the digits $1$ through $9$
so that every row, every column, and every $3\times 3$ block contains each digit
exactly once. And yet the puzzles range from a pleasant coffee-break diversion to
a maddening hour-long standoff. Where does that difficulty come from? Why are
some grids easy and others agonizing?

The surprising answer is that Sudoku is not really a puzzle about digits at all.
It is a puzzle about **graphs** — the mathematical objects made of dots (called
*vertices*) and lines connecting them (called *edges*). And once you see the
graph hiding inside a Sudoku grid, a whole landscape of deep mathematics opens
up: the theory of *constraint satisfaction*, the notion of *graph coloring*, and
even the shadow of the most famous open question in all of computer science,
$\mathrm{P}$ versus $\mathrm{NP}$.

This article tells the story of that hidden graph. Along the way we will make one
piece of folklore completely precise — that solving a Sudoku is *exactly* the
same as coloring a certain graph — and we will pin down a hard numerical
invariant of that graph, its *chromatic number*, showing it is exactly the number
of symbols the puzzle uses.

## Generalizing beyond $9\times 9$

To see the real structure, it helps to zoom out from the familiar $9\times 9$
board. Fix a whole number $n\ge 1$. An **$n$-Sudoku** is played on an
$n^2 \times n^2$ grid, divided into $n^2$ blocks each of size $n\times n$, using
$n^2$ different symbols. The classic game is the case $n=3$: a $9\times 9$ grid,
nine $3\times 3$ blocks, nine symbols. Taking $n=2$ gives the friendly $4\times 4$
"Shidoku" with four symbols; taking $n=4$ gives the sprawling $16\times 16$ grid
with sixteen symbols that hardcore enthusiasts enjoy.

A **cell** is just a coordinate pair $(r,c)$ with $0 \le r, c < n^2$: a row index
and a column index. Two cells can *interact* in three ways:

- they lie in the **same row** if $r = r'$;
- they lie in the **same column** if $c = c'$;
- they lie in the **same block** if $\lfloor r/n\rfloor = \lfloor r'/n\rfloor$ and
  $\lfloor c/n\rfloor = \lfloor c'/n\rfloor$ — that is, integer-dividing the
  coordinates by $n$ lands them in the same $n\times n$ box.

A completed grid is an assignment $g$ of a symbol to every cell. It is a **valid
solution** precisely when no two distinct cells that share a row, a column, or a
block ever receive the same symbol.

## Building the constraint graph

Here is the key move. Forget the symbols for a moment and look only at the
*constraints*. Make one vertex for every cell of the grid — that is $n^2 \times
n^2 = n^4$ vertices in all. Then draw an edge between two distinct cells whenever
they are forced to differ: whenever they share a row, a column, or a block. Call
the resulting network the **Sudoku constraint graph**, written $G_n$.

$$
G_n:\quad \text{vertices} = \text{cells}, \qquad
p \sim q \iff p \ne q \text{ and } p,q \text{ share a row, column, or block.}
$$

Now comes the payoff. A *proper coloring* of a graph is an assignment of colors
to vertices so that no edge ever connects two vertices of the same color — the
central object of study in a large branch of combinatorics, with applications
from scheduling exams to allocating radio frequencies. Compare that definition
with the Sudoku rule: symbols are colors, and the rule says adjacent cells (those
joined by an edge in $G_n$) must get different symbols. The two ideas coincide
exactly.

> **The Bridge Theorem.** *A filling $g$ of an $n$-Sudoku grid is a valid Sudoku
> solution if and only if $g$ is a proper coloring of the Sudoku constraint graph
> $G_n$.*

The proof is a matter of unwinding definitions, but its consequence is profound:
Sudoku, a *constraint satisfaction problem*, is *literally the same problem* as
graph coloring. Everything mathematicians know about coloring graphs suddenly
applies to Sudoku, and vice versa. This is what mathematicians call a *bridge*: a
dictionary that translates every statement on one side into a statement on the
other.

## How many colors do you need?

The single most important number attached to a graph is its **chromatic number**,
denoted $\chi(G)$: the smallest number of colors needed to properly color it. For
the Sudoku graph the answer is beautiful and clean.

> **Chromatic Number Theorem.** *The chromatic number of the Sudoku constraint
> graph is exactly the number of symbols:*
> $$\chi(G_n) = n^2.$$

The proof has two halves, one from each side of the bridge, and together they
squeeze the answer to exactly $n^2$.

**You need at least $n^2$ colors (the lower bound).** Look at a single row of the
grid: its $n^2$ cells all share that row, so in the graph they are pairwise
adjacent. A set of vertices that are all mutually connected is called a *clique*,
and it is a basic fact of graph theory that a clique of size $k$ forces you to use
at least $k$ colors — every one of its vertices needs a color no other member of
the clique has. A full row is a clique of size $n^2$, so $\chi(G_n) \ge n^2$. This
is pure graph theory: the geometry of the puzzle guarantees a large clique.

**You need at most $n^2$ colors (the upper bound).** To prove this we must
actually *color the graph with $n^2$ colors* — which, by the Bridge Theorem, means
exhibiting one genuine completed Sudoku grid. There is a lovely closed-form
recipe. Assign to the cell in row $r$, column $c$ the symbol

$$
g(r,c) \;=\; \bigl(n\cdot (r \bmod n) + \lfloor r/n\rfloor + c\bigr) \bmod n^2.
$$

This is a "shift" construction: each row is a cyclic shift of the previous one,
with the shift amount cleverly chosen so that the block constraints are respected
too. One can check directly that this assignment never repeats a symbol within a
row, within a column, or within a block:

- **Rows.** Fixing $r$ and varying $c$, the value changes by exactly $c$ modulo
  $n^2$, so two columns give the same symbol only if $c = c'$.
- **Columns.** Fixing $c$, the "row contribution" $n\cdot(r\bmod n) + \lfloor
  r/n\rfloor$ is nothing but the base-$n$ representation of $r$ with its two digits
  swapped; swapping digits is reversible, so distinct rows give distinct symbols.
- **Blocks.** Within a block the row and column offsets each range over
  $0,\dots,n-1$, and the formula packages them into a base-$n$ pair that is again
  uniquely recoverable.

Because such a grid exists, $n^2$ colors suffice, giving $\chi(G_n) \le n^2$.
Combining the two bounds yields $\chi(G_n) = n^2$ exactly. As a bonus, the same
construction proves that **every empty $n$-Sudoku is solvable** — there is never a
board size for which the rules are secretly contradictory.

The number $n^2$ is doing double duty here. On the puzzle side it is the count of
symbols the game demands. On the graph side it is a hard, intrinsic invariant — a
quantity that does not care how you draw the graph or label its vertices. The
Chromatic Number Theorem says these two numbers are one and the same. The Sudoku
grid needs exactly $n^2$ symbols, and it has *exactly* enough room for them, no
more and no fewer.

## From coloring to hardness: the phase transition

So far we have talked about *empty* grids, which always have solutions. Real
Sudoku puzzles come with **clues**: some cells are pre-filled, and you must
complete the rest. In graph language, a puzzle is a *precoloring* — a few vertices
are colored in advance — and solving it is a *precoloring extension* problem. This
is where difficulty is born, and where Sudoku brushes up against the frontier of
computer science.

Imagine generating random puzzles by pre-filling cells at random. Let $d$ be the
*density* of clues, the fraction of cells that are filled in. When $d$ is small,
the board is nearly empty and almost any partial filling can be completed — most
instances are solvable. When $d$ is large, so many cells are fixed that the
constraints usually clash and the puzzle has no solution at all. Somewhere in
between, the probability of solvability plunges from nearly $1$ to nearly $0$.
This abrupt switch is a **phase transition**, the same phenomenon that turns water
to ice at a precise temperature.

The conjectured location of this transition is strikingly simple:

$$
d_c(n) = \frac{n^2 - 1}{n^2}.
$$

For $4\times 4$ boards ($n=2$) this predicts $d_c = 3/4 = 0.75$; for standard
$9\times 9$ Sudoku ($n=3$), $d_c = 8/9 \approx 0.889$; for $16\times 16$ boards
($n=4$), $d_c = 15/16 \approx 0.9375$. The intuition is that each cell sits in a
clique of $n^2$ mutually constrained cells — a full row, column, or block — and a
clue removes one degree of freedom from that clique. When roughly $n^2 - 1$ of
every $n^2$ cells are pinned down, the system tips over the edge from
under-constrained to over-constrained.

What makes the phase transition more than a curiosity is that it coincides with a
spike in *computational hardness*. Puzzles with very low or very high clue density
are quick to solve or quick to rule out. But puzzles poised right at $d_c$ are the
hardest of all: a backtracking search can be forced to explore an exponentially
growing tree of possibilities, and empirically the solving time near criticality
scales like $\exp(n^2)$. This "easy–hard–easy" pattern is a hallmark of hard
constraint satisfaction problems everywhere, from Boolean satisfiability to
graph coloring itself.

It is important to be honest about the status of this last picture. The bridge
between Sudoku and graph coloring, and the exact value $\chi(G_n) = n^2$, are
theorems — established beyond doubt. The phase-transition location $d_c(n) =
(n^2-1)/n^2$ and the exponential hardness at criticality are, at present,
*conjectures*: precise, testable, and well supported by experiment and by analogy
with random-satisfiability thresholds, but not yet proved. A rigorous proof would
call for the heavy machinery of random constraint satisfaction — second-moment
and interpolation methods of the sort used to locate the random $k$-SAT
threshold. The deterministic backbone of any such analysis is already in hand:
the clique of $n^2$ mutually constrained cells whose density governs the whole
story.

## Why this matters

The moral of the story is a change of perspective. Sudoku's difficulty is *not*
about the number $9$, and it is not really about squares of digits. It is about
the phase-transition structure that constraint satisfaction problems share.
Recognizing Sudoku as a graph-coloring problem places it in the company of
scheduling, register allocation in compilers, frequency assignment in wireless
networks, and countless other problems that are all, underneath, the same problem
of coloring a graph without conflicts.

That is the power of a mathematical bridge. By translating a familiar puzzle into
the language of graphs, we inherit a hard invariant — the chromatic number
$n^2$ — a constructive recipe that solves every empty board, and a roadmap toward
one of the deepest questions in the theory of computation. The next time a Sudoku
resists your pencil, take comfort: you are wrestling not with a grid of numbers,
but with a graph, at the very edge of what fast algorithms can do.
