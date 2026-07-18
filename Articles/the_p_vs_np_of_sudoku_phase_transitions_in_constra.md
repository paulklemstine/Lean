# Sudoku’s Hidden Graph: Why Density Alone Cannot Explain a Phase Transition

*By Aristotle — July 18, 2026*

A Sudoku grid looks like a quiet square of paper. Underneath, however, it is a network of prohibitions. Every cell is connected to all the other cells that it can “see”: those in the same row, the same column, or the same block. Give two connected cells the same symbol and the puzzle breaks.

That change of viewpoint—from boxes to a network—reveals the durable mathematics behind generalized Sudoku. It also exposes a trap in appealing stories about phase transitions. A density such as “the fraction of pre-filled cells” does not by itself specify a random puzzle. Two processes can produce exactly the same number of clues and utterly different chances of solvability. Before asking where Sudoku suddenly becomes impossible or computationally hard, one must say how the clues and their values are generated.

The central results are clean. For every positive integer $n$, an order-$n$ Sudoku has an $n^2\times n^2$ grid, divided into $n\times n$ blocks, and uses $n^2$ symbols. Its constraint network needs exactly $n^2$ colors. An explicit arithmetic formula completes the empty grid. Adding consistent clues can only remove solutions, never create them. Yet there are solvable instances with every possible clue count from $0$ through $n^4$. Consequently, no deterministic critical clue density separates all solvable instances from all unsolvable ones.

## From a puzzle to a graph

Let the rows and columns be numbered $0,1,\ldots,n^2-1$. A cell is a pair $(r,c)$. Two distinct cells are called peers if they have the same row, the same column, or the same block. In coordinates, the block condition is

$$
\left\lfloor\frac{r}{n}\right\rfloor=
\left\lfloor\frac{r'}{n}\right\rfloor
\quad\text{and}\quad
\left\lfloor\frac{c}{n}\right\rfloor=
\left\lfloor\frac{c'}{n}\right\rfloor.
$$

Now construct the **Sudoku constraint graph**. Its vertices are the $n^4$ cells, and an edge joins every pair of peers. A graph coloring assigns a color to every vertex so that adjacent vertices receive different colors. If the colors are the Sudoku symbols, the translation is exact:

**Sudoku–coloring equivalence.** A completed filling is a valid order-$n$ Sudoku if and only if it is a proper coloring of the Sudoku constraint graph with $n^2$ colors.

The proof is almost a change of language. The Sudoku rules say that peer cells differ. The graph has an edge precisely when two distinct cells are peers. Thus every Sudoku violation is a monochromatic edge, and every monochromatic edge is a Sudoku violation.

This equivalence matters because it connects a familiar puzzle to graph invariants. It lets us ask not merely whether one filling works, but how many symbols the network intrinsically requires.

## Exactly the right number of colors

The **chromatic number** of a graph is the smallest number of colors in any proper coloring. For the Sudoku constraint graph, it is exactly $n^2$.

The lower bound is visible in one row. Its $n^2$ cells are pairwise adjacent, forming a **clique**—a set in which every two distinct vertices share an edge. Every vertex in a clique needs a different color, so at least $n^2$ colors are unavoidable.

The upper bound is more constructive. Define the symbol in row $r$ and column $c$ by

$$
G_n(r,c)=
\bigl(n(r\bmod n)+\lfloor r/n\rfloor+c\bigr)\bmod n^2.
$$

This compact formula produces a completed Sudoku for every $n\ge 1$. Along a fixed row, increasing $c$ cycles through all residues modulo $n^2$. Along a fixed column, the row-dependent shift

$$
D_n(r)=n(r\bmod n)+\lfloor r/n\rfloor
$$

is unique for $0\le r<n^2$: it is simply a rearrangement of the two base-$n$ digits of $r$. Inside one block, the block coordinates are fixed while the within-block row and column coordinates range independently; the quantity $n(r\bmod n)+(c\bmod n)$ encodes that pair uniquely. Hence no row, column, or block repeats a symbol.

For $n=3$, this gives the familiar $9\times9$ cyclic pattern. For $n=2$, it gives a $4\times4$ solution; for $n=4$, a $16\times16$ solution. The formula proves two results at once:

**Universal completion theorem.** Every empty order-$n$ Sudoku with $n\ge1$ has a valid completion.

**Exact chromatic-number theorem.** The Sudoku constraint graph of order $n\ge1$ has chromatic number $n^2$.

A related consequence applies to any sound procedure that assigns upper bounds to clique sizes in induced portions of the graph. When applied to the entire constraint graph, such a procedure must return at least $n^2$, because the first row already exhibits a clique of that size. No sound clique-based preprocessing can pretend this canonical obstruction is smaller.

## Clues are restrictions, not just a percentage

A clue system assigns either a symbol or a blank to each cell. It is **solvable** if at least one valid completed Sudoku agrees with every displayed symbol. Say that one clue system extends another when it contains every clue of the first, with the same values, and perhaps more.

This ordering yields a fundamental monotonicity law:

**Antitonicity of solvability.** If a more heavily constrained clue system is solvable, then every clue system obtained by deleting some of its clues is also solvable.

The reason is direct: a completion satisfying all the clues also satisfies any subset of them. Equivalently, adding clues can destroy candidate completions but cannot manufacture new ones.

It is tempting to turn this monotonicity into a universal phase-transition story. The proposed density

$$
d_c(n)=\frac{n^2-1}{n^2}
$$

would be $3/4$ for $4\times4$ Sudoku, $8/9$ for standard $9\times9$ Sudoku, and $15/16$ for $16\times16$ Sudoku. But density is only a count. It says nothing about where clue values came from or how they are correlated.

Here is a decisive comparison. Start with any completed Sudoku and choose an arbitrary set $S$ of cells. Reveal the completed value exactly on $S$ and leave every other cell blank. The original completion still solves the resulting puzzle. This works for every geometric shape of $S$ and every size $k$ with

$$
0\le k\le n^4.
$$

Thus we obtain:

**Restriction theorem.** Every subset of the entries of a valid completed grid is solvable.

**Every-count theorem.** For every positive $n$ and every integer $k$ between $0$ and $n^4$, there exists a solvable order-$n$ clue system with exactly $k$ clues.

The support—the set of nonblank cells—is exactly $S$, so there is no hidden counting subtlety. If random instances are generated by choosing a completed grid and deleting entries, the probability of solvability is $1$ at every clue density. There is no satisfiability transition at $8/9$, or anywhere else.

By contrast, if one assigns random symbols to selected cells, conflicting values can make an instance impossible. Even conditioning on immediate row, column, and block consistency does not erase longer-range correlations. A third model might perturb a completed grid. These ensembles can share the same expected density while having different satisfiability curves.

## What “hardest near the threshold” must mean

Phase transitions are real and powerful ideas in constraint satisfaction, physics, and computation. Water changes phase when temperature crosses a boundary; random graphs suddenly acquire giant connected components; random logical formulas can shift from usually satisfiable to usually contradictory. But the control parameter works only after the probability space has been fixed.

Sudoku needs the same discipline. A credible experimental claim should specify at least:

1. how the set of clue cells is sampled;
2. how clue values are sampled and conditioned;
3. whether the observable is existence, uniqueness, or number of solutions;
4. which solver is run, including variable and value ordering;
5. which cost is measured, such as search-tree nodes, time, or proof width.

Satisfiability and computational hardness are not the same observable. A family can remain satisfiable while becoming difficult for one search rule. Unsatisfiable instances can be easy if a local contradiction appears immediately. Uniqueness can have its own transition even when existence does not. Likewise, saying “backtracking takes $\exp(O(n^2))$” is not a lower bound, and saying “backtracking is exponential” is ambiguous unless the algorithm is fixed.

The graph viewpoint suggests sharper questions. Can one transfer hard graph-coloring instances into Sudoku-shaped constraints? Do specific deterministic branching rules require $\exp(\Omega(n^2))$ nodes on an explicit family? Can bounded-width consistency detect contradictions that clique-only preprocessing misses? Does the density maximizing satisfiability variance differ from the density maximizing proof complexity?

These questions preserve the exciting phase-transition narrative while replacing a universal-density conjecture with testable mathematics.

## The broader lesson

Sudoku is not hard merely because a $9\times9$ board has many squares. Its structure lies in the interaction of three overlapping partitions: rows, columns, and blocks. The constraint graph makes that interaction visible. Its chromatic number $n^2$ says the symbol alphabet is exactly tight: one full row forces $n^2$ distinct symbols, and the arithmetic construction shows those symbols suffice globally.

Clues add a second layer. They select a partial coloring and ask whether it extends to a full one. Under deletion, solvability behaves monotonically. Under random generation, however, density alone discards the correlations that determine whether the partial coloring is compatible with any completion.

That distinction travels far beyond Sudoku. Scheduling, register allocation, frequency assignment, error-correcting codes, and many other constraint systems can be represented by graphs or hypergraphs. In each case, “how many constraints?” is only the beginning. One must also ask which constraints, how they overlap, and how their values were produced.

The enduring message is therefore not a numerical threshold. It is a rule for finding meaningful ones: first identify the constraint geometry, then define the random ensemble, and only then measure satisfiability or hardness. Sudoku’s hidden graph gives the geometry. The next phase-transition theorem must supply the probability model.