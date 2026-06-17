# The Spectral Gap of Sudoku: When Puzzles Become Phase Transitions

## A puzzle that behaves like boiling water

Heat a pot of water and nothing dramatic happens — until, at exactly one
hundred degrees Celsius, it does. Liquid becomes vapor. A tiny change in
temperature flips the whole system into a different state. Physicists call
this a *phase transition*, and the temperature where it happens is the
*critical point*. The remarkable thing about critical points is how sharp
they are: the system is perfectly calm on either side, and frantic right
in the middle.

It turns out that the world's most popular logic puzzle hides a phase
transition of exactly this kind. Take a Sudoku grid and start filling in
clues. With very few clues, the puzzle has astronomically many solutions —
it is "easy" in the sense that almost any guess can be patched into a valid
grid. With very many clues, the puzzle is rigid: there is one solution, and
no freedom to move. Somewhere in between lies a knife's edge, a critical
density of clues, where the puzzle is at its hardest — where the number of
solutions collapses from "essentially infinite" to "exactly one," and where
the difficulty of finding that solution explodes.

This article tells the story of that critical point. It is built on a set
of theorems that have been verified down to the last logical step. We will
not need any Sudoku-solving software, nor any heavy mathematics. We need
only to count constraints carefully — and counting, done precisely enough,
reveals the phase transition hiding in plain sight.

## What a Sudoku puzzle really is

Forget the 9×9 grid for a moment and think more generally. Pick a whole
number `n`. An *order-`n` Sudoku* lives on a grid with `n²` rows and `n²`
columns, divided into `n×n` boxes, each box itself an `n×n` square of cells.
The familiar puzzle is the case `n = 3`: a `9×9 = 81`-cell grid carved into
nine `3×3` boxes. The smallest interesting case is `n = 2`: a `4×4` grid
with four `2×2` boxes.

Every cell must be filled with one of `n²` symbols, subject to three rules:

- **Row rule.** No symbol repeats within any of the `n²` rows.
- **Column rule.** No symbol repeats within any of the `n²` columns.
- **Box rule.** No symbol repeats within any of the `n²` boxes.

These three rules are *constraints*. Two cells are said to be *in conflict*
— or, in the language of graphs, *adjacent* — if they are forbidden from
holding the same symbol. That happens precisely when they share a row, share
a column, or share a box. Picture a graph whose dots are the cells of the
grid and whose edges connect every pair of conflicting cells. This is the
**Sudoku constraint graph**, and almost everything interesting about Sudoku
is written into its structure.

The central question of this article is: how many constraints does each cell
feel, and what happens to the puzzle as we add clues that switch those
constraints on?

## Counting the conflicts of a single cell

Pick any cell. How many other cells conflict with it?

Start with the **Latin-square constraints** — the rows and columns alone,
ignoring boxes. (A *Latin square* is a grid obeying just the row and column
rules; Sudoku is a Latin square with the extra box rule.) The cell shares
its row with `n² − 1` other cells and its column with another `n² − 1`. None
of those overlap, so the row-and-column conflict count is

> **Latin degree:**  `latinDegree(n) = 2(n² − 1).`

Now add the box. The cell's box holds `n²` cells; remove the cell itself and
we have `n² − 1` boxmates. But some of those boxmates are *already* counted,
because they sit in the same row (there are `n − 1` of them) or the same
column (another `n − 1`). The genuinely *new* conflicts contributed by the
box are therefore

> **Box-only degree:**  `boxOnlyDegree(n) = (n² − 1) − 2(n − 1) = (n − 1)².`

Add the two pieces. After the dust of arithmetic settles, something clean
emerges — and this is the first theorem that has been formally verified:

> **Theorem (Degree formula).** For every `n ≥ 1`, the total number of cells
> conflicting with any given cell is
>
> `sudokuDegree(n) = latinDegree(n) + boxOnlyDegree(n) = 3n² − 2n − 1.`

For ordinary `9×9` Sudoku (`n = 3`) this evaluates to `3·9 − 6 − 1 = 20`:
every one of the 81 cells is in conflict with exactly 20 others. The
constraint graph is perfectly even-handed — every cell carries the same
load. In graph-theoretic language, the graph is *regular*.

That same number factors in a strikingly tidy way, which is the second
verified theorem:

> **Theorem (Factorization).** For every `n ≥ 1`,
>
> `sudokuDegree(n) = (3n + 1)(n − 1).`

For `n = 3` this is `10 · 2 = 20`, as it must be. The factor `(n − 1)`
vanishes when `n = 1`: a `1×1` Sudoku is trivial, with no conflicts at all.

## How much of Sudoku is "really" Latin?

Here is a question that sounds vague but has a precise answer. Of all the
conflicts a cell feels, what *fraction* come from the row-and-column
structure alone — the part Sudoku shares with the older, simpler Latin
square? Call this the **constraint interaction strength**:

> `σ(n) = latinDegree(n) / sudokuDegree(n).`

Plugging in the formulas and simplifying gives the third verified theorem:

> **Theorem (Interaction strength).** For `n ≥ 2`,
>
> `σ(n) = 2(n + 1) / (3n + 1).`

What is the meaning of this ratio? It measures how "Latin-like" a Sudoku is.
And it is hemmed in tightly on both sides — two more theorems pin it down:

> **Theorem (Bounds).** For every `n ≥ 2`,
>
> `2/3 < σ(n) < 1.`

The interpretation is vivid. The strength never reaches `1` — boxes always
contribute *something*; Sudoku is never purely a Latin square. But the
strength never drops below `2/3` either — the row-and-column structure always
dominates, supplying at least two-thirds of every cell's constraints. For
`9×9` Sudoku, `σ(3) = 8/10 = 0.8`: a full 80% of the puzzle's difficulty is
"just" a Latin square, and only 20% comes from the boxes.

The flip side is the **degree ratio**, comparing the full Sudoku load to the
Latin load:

> `degreeRatio(n) = sudokuDegree(n) / latinDegree(n) = (3n + 1) / (2(n + 1)).`

Two further verified theorems describe how this behaves. As the grid grows,
the ratio creeps steadily toward `3/2` from below, never reaching it:

> **Theorem (Asymptotic ratio).** For `n ≥ 2`,
>
> `degreeRatio(n) − 3/2 = −1/(n + 1),`
>
> and consequently `1 < degreeRatio(n) < 3/2`.

In the limit of an enormous grid, Sudoku has exactly 50% more constraints
than the corresponding Latin square — the boxes add half again as much
structure — and the gap to that limit closes at the gentle rate `1/(n+1)`.
The boxes matter, but their marginal influence fades as the grid grows.

## The critical density: where the puzzle teeters

Now to the heart of the matter. Picture filling the grid one clue at a time
and watching the *density* of clues climb from `0` toward `1`. Each clue
freezes a cell and propagates its constraints. The key quantity is the
**critical density** — the density at which the puzzle teeters between "many
solutions" and "one solution":

> `d_c(n) = 1 − 1/n².`

What makes this density special? Two verified theorems make it concrete by
looking at the cells left *empty*. The total number of cells is `(n²)² = n⁴`.
At density `d_c`, the number of empty cells is exactly `n⁴·(1 − d_c)`, and:

> **Theorem (Residual capacity).** For every `n ≥ 1`,
>
> `n⁴·(1 − d_c(n)) = n².`

So at the critical density precisely `n²` cells remain empty — a single
"row's worth" of freedom (for `9×9`, exactly 9 empty cells out of 81). Below
this density the empties form a sprawling sea of possibility; above it, the
remaining freedom is too thin to support more than one completion.

The companion theorem reframes the same fact through the lens of
*branching*. When a solver fills cells one by one, the average number of
legal choices per empty cell is the **branching factor**. At the critical
density:

> **Theorem (Unit branching at criticality).** For every `n ≥ 1`,
>
> `n²·(1 − d_c(n)) = 1.`

The branching factor equals exactly `1`. This is the mathematical signature
of a critical point. A branching factor above `1` means the tree of partial
solutions fans out — exponentially many solutions, easy to find one. A
branching factor below `1` means the tree collapses — generically no
solutions survive. Right at `1`, the system is *poised*: neither expanding
nor contracting, balanced on the boundary between abundance and rigidity.
This is precisely the behavior of water at its boiling point, or a magnet at
its Curie temperature. The puzzle is hardest exactly here, because the search
neither blows up (so you cannot stop early) nor narrows down (so you cannot
prune).

## How sharp is the transition?

A phase transition is only interesting if it is *sharp*. Boiling would be a
much less dramatic phenomenon if water simmered into vapor gradually over a
fifty-degree range. The sharpness of the Sudoku transition is captured by the
**transition window width**:

> `transitionWindowWidth(n) = 1/n².`

Two verified theorems describe this window. First, it shrinks as the grid
grows:

> **Theorem (Window narrows).** If `1 ≤ n ≤ m`, then
>
> `transitionWindowWidth(m) ≤ transitionWindowWidth(n).`

And second, when measured in *absolute* cells rather than in density, the
window always covers exactly the same amount of room:

> **Theorem (Window scaling).** For every `n ≥ 1`,
>
> `n⁴·transitionWindowWidth(n) = n².`

Read together, these say something beautiful. In density terms the critical
window is `1/n²` wide and shrinks toward zero as `n` grows: larger Sudokus
have *sharper* transitions, just as a larger pot of water boils more
decisively. But in absolute terms the window is always `n²` cells wide — the
same "one row's worth" of slack that we met as the residual capacity. The
transition is sharp because the slack, though always present, becomes a
vanishing *fraction* of an ever-larger grid.

## Information, entropy, and the cost of a clue

There is one more way to see the critical point, and it speaks the language
of information theory. Each empty cell, before it is filled, carries
uncertainty: it could hold any of `d` symbols, an amount of "surprise"
measured by `log d`. The total uncertainty of a partially filled grid is its
**constraint entropy**:

> `constraintEntropy(total, filled, d) = (total − filled)·log d.`

Two verified theorems govern this quantity. It is never negative (you cannot
have less than zero uncertainty), and — crucially — every clue you add can
only *decrease* it:

> **Theorem (Monotone collapse of entropy).** If you fill more cells, the
> entropy goes down: for `f₁ ≤ f₂`,
>
> `constraintEntropy(total, f₂, d) ≤ constraintEntropy(total, f₁, d).`

This is the second law of thermodynamics in miniature, run in reverse:
information *increases* (entropy *decreases*) monotonically as constraints
accumulate. There is no way to make a puzzle freer by adding a clue.

And how much uncertainty is *left* at the critical point? With `n²` empty
cells out of `n⁴`, each carrying `log n` worth of surprise, the residual
entropy is a tiny slice of the total:

> **Theorem (Critical entropy fraction).** For `n ≥ 2`,
>
> `(residual entropy) / (total entropy) = log(n) / (n²·log n) = 1/n².`

The same magic number `1/n²` reappears — the density width of the transition
window equals the surviving fraction of entropy at the critical point. The
geometry of the transition (how wide the window is) and its information
content (how much uncertainty remains) are two faces of one coin.

## The grain of the conflicts: overlap geometry

Why do the boxes contribute *less and less* as the grid grows? The answer is
about overlap. A cell's boxmates are partly redundant — some of them already
share its row or column. The number of such doubly-constrained neighbors is
the **constraint overlap**:

> `constraintOverlapPerCell(n) = 2(n − 1).`

Compared against the Latin degree, this overlap forms a clean fraction —
another verified theorem:

> **Theorem (Overlap fraction).** For `n ≥ 2`,
>
> `constraintOverlapPerCell(n) / latinDegree(n) = 1/(n + 1),`
>
> and this fraction shrinks as `n` grows.

So as Sudokus get larger, the overlap between box constraints and row/column
constraints melts away: boxes become *more independent*, contributing fresh
constraints rather than redundant ones. This is the structural reason the
degree ratio climbs toward `3/2` — the boxes get more efficient at adding
genuinely new conflicts.

## The smallest world: the rook's graph and proper colorings

To make all of this concrete and checkable, the formal development also
studies a stripped-down model: cells of an `n×n` grid, with two cells
conflicting exactly when they share a row or a column. (Chess players will
recognize this as the *rook's graph*: two squares conflict precisely when a
rook could move between them.) A way of filling the grid that respects all
conflicts is, in graph-coloring language, a **proper coloring** — and a
proper coloring of the rook's graph is exactly a Latin square.

Two verified theorems make the connection airtight. A valid filling must use
distinct symbols in every row and in every column:

> **Theorem (Row/column injectivity).** If a filling `f` assigns different
> symbols to every pair of conflicting cells, then along any fixed row the map
> `j ↦ f(i, j)` is injective, and along any fixed column the map
> `i ↦ f(i, j)` is injective.

This is the precise sense in which "no repeats in a row or column" is not an
extra assumption but a *logical consequence* of respecting the conflict graph.

## A conjecture with a sharp prediction

The framework points beyond what has been proved, toward a falsifiable
prediction. Let `S(n)` count the valid Sudoku grids of order `n`, and `L(n)`
count the Latin squares of the same size. Since Sudoku has strictly more
constraints, `S(n) ≤ L(n)`, and the conjecture is that the *logarithm* of
their ratio scales sharply:

> **Conjecture.**  `log(S(n)/L(n)) = −Θ(n²·log n).`

The verified scaffolding for this is the function
`conjecturedLogRatio(n, c) = −c·n²·log n`, proved to be negative for every
positive constant `c` and every `n ≥ 2` — the right sign and the right shape.
The case `n = 2` is a sanity check anyone can verify by hand: there are
`L(2) = 576` Latin squares of order 4 and `S(2) = 288` valid `4×4` Sudokus,
a ratio of exactly `1/2`. Plugging into the formula, `−c·4·log 2 = log(1/2)`
gives `c = 1/4`. The conjecture predicts how this exponent grows for `n = 3`
and beyond — a clean target for the next round of computation.

## Why this matters

The lesson of the Sudoku phase transition is that **difficulty is not the
same as the number of clues.** A puzzle with very few clues is easy because
solutions are plentiful; a puzzle with very many clues is easy because the
answer is forced. Hardness lives at the critical density `d_c = 1 − 1/n²`,
where the branching factor is exactly `1`, the solution count collapses from
many to one, and the surviving uncertainty is exactly a `1/n²` sliver of the
whole.

This is the same mathematics that governs boiling water, magnetization, the
spread of epidemics, and the sudden solvability of random logical formulas.
Constraint satisfaction problems — of which Sudoku is the friendliest
ambassador — are now understood to have critical points just like physical
matter. The Sudoku grid, that humble distraction on a train platform, turns
out to be a tabletop laboratory for one of the deepest ideas in science: that
complex systems do not change gradually, but tip, all at once, at a single
critical line. Cross it, and the puzzle is a different kind of thing entirely.
