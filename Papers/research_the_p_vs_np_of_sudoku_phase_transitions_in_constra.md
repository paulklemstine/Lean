# The Chromatic Number of the Sudoku Constraint Graph, and the Phase Transition of Random Sudoku

## Abstract

We study $n$-Sudoku — the natural generalization of the familiar $9\times 9$
puzzle to an $n^2\times n^2$ grid with $n^2$ symbols — as a constraint
satisfaction problem, and make precise its classical correspondence with graph
coloring. We introduce the **Sudoku constraint graph** $G_n$, whose vertices are
the $n^4$ cells and whose edges join any two distinct cells sharing a row, a
column, or an $n\times n$ block. Our main structural results are: (i) a **bridge
theorem** identifying valid Sudoku solutions with proper vertex colorings of
$G_n$; (ii) an explicit closed-form completion of the empty grid, proving that
every $n$-Sudoku is solvable; and (iii) the exact determination of the
**chromatic number** $\chi(G_n) = n^2$, with the lower bound coming from a
row-clique of size $n^2$ and the upper bound from the explicit construction. We
then place these deterministic facts inside the probabilistic theory of random
constraint satisfaction. We formulate the **phase-transition conjecture**: random
$n$-Sudoku instances undergo a sharp solvability transition at clue density
$d_c(n) = (n^2-1)/n^2$, with computational hardness for backtracking search
peaking at criticality and scaling as $\exp(\Theta(n^2))$. We explain how the
chromatic-number invariant is the deterministic backbone on which a rigorous
threshold analysis would rest, discuss algorithms and applications, and lay out
directions toward a proof.

---

## 1. Introduction

Sudoku is arguably the world's most popular constraint satisfaction problem
(CSP). Its rules are elementary, yet the difficulty of individual instances
varies enormously, and the decision problem for the generalized game is
NP-complete. This paper develops the mathematical structure that explains *why*,
by exploiting a bridge between two apparently different areas of combinatorics:
constraint satisfaction and graph coloring.

The central object is the *Sudoku constraint graph* $G_n$. We prove that valid
Sudoku solutions are exactly the proper colorings of $G_n$, that its chromatic
number is exactly $n^2$, and that the empty grid always admits a closed-form
completion. We then use these deterministic facts to frame — and to ground — the
probabilistic **phase-transition conjecture** for random Sudoku.

The contributions are:

1. A rigorous formulation of $n$-Sudoku and its constraint graph (Section 2).
2. The bridge theorem: solutions $\leftrightarrow$ proper colorings (Section 3).
3. An explicit arithmetic solution of the empty grid (Section 4).
4. The exact chromatic number $\chi(G_n)=n^2$ (Section 5).
5. The phase-transition conjecture and its relationship to the chromatic
   invariant, together with algorithmic and empirical discussion (Sections 6–8).

Throughout, all mathematical claims in Sections 2–5 are theorems with proof
sketches given inline; the claims in Section 6 are clearly labeled conjectures.

---

## 2. Definitions

Fix an integer $n \ge 1$, the *order* of the puzzle. The classic game is $n=3$.

**Definition 2.1 (Cells).** The set of *cells* of an $n$-Sudoku is
$$
\mathrm{Cell}(n) = \{0,1,\dots,n^2-1\} \times \{0,1,\dots,n^2-1\},
$$
one coordinate for the row and one for the column. There are $|\mathrm{Cell}(n)| =
n^4$ cells.

**Definition 2.2 (Constraint relations).** For cells $p=(r,c)$ and $q=(r',c')$:

- *same row*: $\mathrm{sameRow}(p,q) \iff r = r'$;
- *same column*: $\mathrm{sameCol}(p,q) \iff c = c'$;
- *same block*: $\mathrm{sameBox}(p,q) \iff \lfloor r/n\rfloor = \lfloor
  r'/n\rfloor \ \text{and}\ \lfloor c/n\rfloor = \lfloor c'/n\rfloor$.

Each relation is reflexive and symmetric. The block relation partitions the grid
into $n^2$ disjoint $n\times n$ boxes indexed by $(\lfloor r/n\rfloor, \lfloor
c/n\rfloor)$.

**Definition 2.3 (Filling and solution).** A *filling* is a function $g :
\mathrm{Cell}(n) \to \{0,\dots,n^2-1\}$ assigning a symbol to every cell. A
filling $g$ is a *valid Sudoku solution* if no two distinct cells sharing a row, a
column, or a block receive the same symbol:
$$
\begin{aligned}
&\forall p\ne q,\ \mathrm{sameRow}(p,q) \Rightarrow g(p)\ne g(q),\\
&\forall p\ne q,\ \mathrm{sameCol}(p,q) \Rightarrow g(p)\ne g(q),\\
&\forall p\ne q,\ \mathrm{sameBox}(p,q) \Rightarrow g(p)\ne g(q).
\end{aligned}
$$

**Definition 2.4 (Sudoku constraint graph).** The *Sudoku constraint graph* $G_n$
is the simple graph with vertex set $\mathrm{Cell}(n)$ and adjacency
$$
p \sim q \iff p \ne q \ \text{and}\ \bigl(\mathrm{sameRow}(p,q) \lor
\mathrm{sameCol}(p,q) \lor \mathrm{sameBox}(p,q)\bigr).
$$
Symmetry of adjacency follows from symmetry of the three relations; the graph is
loopless because adjacency requires $p\ne q$.

**Definition 2.5 (Proper coloring, chromatic number).** A *proper coloring* of a
graph $G$ with color set $S$ is a function $g: V(G)\to S$ such that $g(p)\ne g(q)$
whenever $p\sim q$. The *chromatic number* $\chi(G)$ is the least $k$ for which a
proper coloring with $k$ colors exists.

**Definition 2.6 (Clique).** A *clique* in $G$ is a set of pairwise adjacent
vertices. If $G$ contains a clique of size $k$, then $\chi(G)\ge k$, since the $k$
mutually adjacent vertices must all receive distinct colors.

---

## 3. The Bridge Theorem: solutions are colorings

**Theorem 3.1 (Bridge).** *Let $g:\mathrm{Cell}(n)\to\{0,\dots,n^2-1\}$. Then $g$
is a valid Sudoku solution if and only if $g$ is a proper coloring of $G_n$:*
$$
\mathrm{IsSudokuSolution}(g) \iff \bigl(\forall p,q,\ p\sim_{G_n} q \Rightarrow
g(p)\ne g(q)\bigr).
$$

*Proof sketch.* ($\Rightarrow$) Suppose $g$ is a valid solution and $p\sim q$. By
definition of adjacency, $p\ne q$ and $p,q$ share a row, column, or block. In each
case the corresponding solution clause gives $g(p)\ne g(q)$. ($\Leftarrow$)
Suppose $g$ is a proper coloring. For any distinct $p,q$ in the same row, they are
adjacent (an edge of type "same row"), so $g(p)\ne g(q)$; likewise for columns and
blocks. Thus all three solution clauses hold. $\qquad\blacksquare$

The theorem is an *identification*: the CSP notion of solution and the
graph-theoretic notion of proper coloring are literally the same predicate on
fillings. Every downstream question — existence, counting, complexity — can be
posed on either side of the bridge.

**Corollary 3.2.** *The number of completed $n$-Sudoku grids equals the number of
proper $n^2$-colorings of $G_n$, i.e. the value $P(G_n, n^2)$ of the chromatic
polynomial of $G_n$ at $n^2$.* (For $n=3$ this number is famously
$6{,}670{,}903{,}752{,}021{,}072{,}936{,}960$.)

---

## 4. An explicit solution of the empty grid

To bound the chromatic number from above and to prove solvability, we exhibit one
explicit completed grid.

**Definition 4.1 (Shift construction).** For integers $r,c$ define
$$
\mathrm{sudokuVal}(n,r,c) = \bigl(n\cdot(r \bmod n) + \lfloor r/n\rfloor + c\bigr)
\bmod n^2.
$$
For $n\ge 1$ the value lies in $\{0,\dots,n^2-1\}$, so it is a legal symbol.

**Lemma 4.2 (Base-$n$ digit uniqueness).** *If $b,b' < n$ and $n a + b = n a' +
b'$, then $a = a'$ and $b = b'$.*

*Proof.* Reducing mod $n$ gives $b = b'$; cancelling $n$ gives $a = a'$.
$\blacksquare$

**Lemma 4.3 (Modular cancellation).** *If $x, y < N$ and $(k+x)\bmod N =
(k+y)\bmod N$, then $x = y$ (and symmetrically for $(x+k)$).*

*Proof.* $x \equiv y \pmod N$ by left-cancellation of $k$; since both are reduced
mod $N$, they are equal. $\blacksquare$

**Theorem 4.4 (Correctness of the shift construction).** *For $n\ge 1$, the
filling $g(r,c) = \mathrm{sudokuVal}(n,r,c)$ is a valid Sudoku solution.*

*Proof sketch.* We verify the three constraints.

*Rows.* Fix $r$. Then $g(r,c) = (K + c)\bmod n^2$ where $K = n(r\bmod n) +
\lfloor r/n\rfloor$ is constant. If $g(r,c)=g(r,c')$ then modular cancellation
(Lemma 4.3) gives $c = c'$.

*Columns.* Fix $c$. Then $g(r,c) = (D_r + c)\bmod n^2$ where $D_r = n(r\bmod n) +
\lfloor r/n\rfloor$. One shows $0 \le D_r < n^2$ (since $r\bmod n \le n-1$ and
$\lfloor r/n\rfloor < n$ for $r<n^2$). Cancelling $c$ modulo $n^2$ yields $D_r =
D_{r'}$. But $D_r$ is exactly $r$ written in base $n$ with its two digits swapped:
$r = n\lfloor r/n\rfloor + (r\bmod n)$ maps to $D_r = n(r\bmod n)+\lfloor
r/n\rfloor$. By base-$n$ digit uniqueness (Lemma 4.2), $r\bmod n = r'\bmod n$ and
$\lfloor r/n\rfloor = \lfloor r'/n\rfloor$, hence $r = r'$.

*Blocks.* Suppose $\lfloor r/n\rfloor = \lfloor r'/n\rfloor$ and $\lfloor
c/n\rfloor = \lfloor c'/n\rfloor$ and $g(r,c)=g(r',c')$. Using the identity
$n(a\bmod n) + \lfloor a/n\rfloor + b = \bigl(n(a\bmod n)+ (b\bmod n)\bigr) +
\bigl(\lfloor a/n\rfloor + n\lfloor b/n\rfloor\bigr)$, the two "high" terms agree
because the block indices agree, so modular cancellation reduces the equality to
$n(r\bmod n) + (c\bmod n) = n(r'\bmod n) + (c'\bmod n)$, both sides $< n^2$. Base-
$n$ digit uniqueness gives $r\bmod n = r'\bmod n$ and $c\bmod n = c'\bmod n$;
combined with equal block indices, $r=r'$ and $c=c'$. $\qquad\blacksquare$

**Corollary 4.5 (Solvability).** *Every empty $n$-Sudoku ($n\ge 1$) is solvable.*
Equivalently, by the bridge, $G_n$ is $n^2$-colorable.

---

## 5. The chromatic number of the Sudoku graph

**Theorem 5.1 (Chromatic number).** *For $n \ge 1$,*
$$
\chi(G_n) = n^2.
$$

*Proof.* We prove matching bounds.

**Lower bound $\chi(G_n)\ge n^2$.** Consider the first row $R = \{(0,c) : 0\le c <
n^2\}$. Any two distinct cells of $R$ share row $0$, hence are adjacent in $G_n$.
Thus $R$ is a clique with $|R| = n^2$ vertices. A clique of size $n^2$ forces at
least $n^2$ colors (Definition 2.6), so $\chi(G_n)\ge n^2$.

**Upper bound $\chi(G_n)\le n^2$.** The shift construction of Theorem 4.4 is a
valid Sudoku solution, hence by the Bridge Theorem 3.1 a proper coloring of $G_n$
using the $n^2$ symbols as colors. Therefore $\chi(G_n)\le n^2$.

Combining the two bounds gives $\chi(G_n)=n^2$. $\qquad\blacksquare$

The chromatic number is a hard graph invariant — invariant under relabeling of
vertices and independent of any drawing. Theorem 5.1 says this invariant equals
the number of symbols demanded by the puzzle. In other words, the grid needs
exactly $n^2$ symbols and has exactly enough room for them. The clique number
satisfies $\omega(G_n) \ge n^2$ by the same row argument; since always
$\omega \le \chi$, and here $\chi = n^2$, we in fact obtain $\omega(G_n) = n^2$ as
well: the largest set of mutually constrained cells has size exactly $n^2$.

---

## 6. The phase-transition conjecture

Empty grids are always solvable; genuine puzzles come with *clues*. A **Sudoku
puzzle** is a partial filling $\phi$ defined on a subset $C \subseteq
\mathrm{Cell}(n)$ of *clue cells*; a *solution* is a valid completion $g$
extending $\phi$. In graph terms, $\phi$ is a *precoloring* of the vertices in
$C$, and solving the puzzle is a **precoloring extension** problem for $G_n$. This
is where computational difficulty enters: generalized Sudoku solvability is
NP-complete, and it is precisely the NP-completeness of precoloring extension for
the family $\{G_n\}$.

Consider the random model: choose a clue set of density $d = |C|/n^4$ uniformly at
random, and assign each clue a random symbol subject to local consistency. Let
$p_{\mathrm{sol}}(n,d)$ be the probability that the resulting puzzle is solvable.

**Conjecture 6.1 (Solvability phase transition).** *As $n\to\infty$, the
solvability probability exhibits a sharp threshold at clue density*
$$
d_c(n) = \frac{n^2 - 1}{n^2}.
$$
*That is, for any fixed $\varepsilon>0$, $p_{\mathrm{sol}}(n,d)\to 1$ when
$d \le d_c(n)-\varepsilon$ and $p_{\mathrm{sol}}(n,d)\to 0$ when $d \ge
d_c(n)+\varepsilon$.*

Numerically: $d_c(2) = 3/4 = 0.75$, $d_c(3) = 8/9 \approx 0.889$, $d_c(4) = 15/16
\approx 0.9375$, with $d_c(n)\to 1$ as $n\to\infty$.

The heuristic: every cell belongs to cliques of size $n^2$ (its row, its column,
its block). Within a clique of $n^2$ mutually distinct symbols, fixing values
removes degrees of freedom; when about $n^2-1$ of each $n^2$ cells are pinned, the
last degree of freedom vanishes and the system tips from under- to
over-constrained. The critical fraction of *free* cells is thus $\approx 1/n^2$,
i.e. clue density $1 - 1/n^2 = (n^2-1)/n^2$.

**Conjecture 6.2 (Hardness at criticality).** *For backtracking (DPLL-style)
search, the expected solving time of random $n$-Sudoku exhibits an
"easy–hard–easy" profile in $d$, peaking at $d_c(n)$, where it scales as*
$$
T(n, d_c) = \exp\bigl(\Theta(n^2)\bigr).
$$

Both conjectures are precise and empirically testable but, to our knowledge, not
proved. They are the Sudoku analogues of the extensively studied random $k$-SAT
threshold phenomena.

**The role of the chromatic invariant.** Theorem 5.1 is the deterministic backbone
of any rigorous threshold analysis. The clique of $n^2$ mutually constrained cells
is the local structure whose density governs hardness; the exact value $\chi(G_n)
= \omega(G_n) = n^2$ fixes the number of colors and the size of the critical
clique, which are the inputs a second-moment or interpolation argument would need.

---

## 7. Algorithms

We record the key algorithms implied by the theory.

**7.1 Constraint-graph construction.** Given $n$, enumerate all $n^4$ cells and add
an edge between each pair sharing a row, column, or block. Naively $O(n^8)$ pairs;
in practice one stores, for each cell, its three constraint groups, giving
$O(n^4\cdot n^2) = O(n^6)$ incidences. The adjacency test $p\sim q$ is $O(1)$.

**7.2 Shift-construction solver.** Compute $g(r,c) = (n(r\bmod n)+\lfloor
r/n\rfloor + c)\bmod n^2$ for every cell in $O(n^4)$ time. This produces a
guaranteed-valid completed grid, a constructive witness of $n^2$-colorability.

**7.3 Backtracking with constraint propagation (DPLL/AC-3 style).** To solve a
puzzle with clues, repeatedly pick an unfilled cell (e.g., minimum-remaining-
values heuristic), try each locally consistent symbol, propagate constraints, and
recurse; backtrack on conflict. This is the algorithm whose runtime is conjectured
to spike at $d_c(n)$.

**7.4 Chromatic verification.** To confirm $\chi(G_n)=n^2$ for a concrete $n$:
verify the shift construction is a proper $n^2$-coloring (upper bound) and exhibit
the first row as an $n^2$-clique (lower bound).

---

## 8. Applications and discussion

The bridge places Sudoku in the mainstream of applied combinatorics. Graph
coloring models exam and sports scheduling (colors = time slots), register
allocation in compilers (colors = registers), and frequency assignment in wireless
networks (colors = frequency bands). Every algorithmic advance for coloring
transfers to Sudoku and, via the phase-transition lens, to the broader question of
when large constraint systems are satisfiable and when they are hard.

Dropping the block constraints from $G_n$ yields the *rook's graph*, whose proper
$n^2$-colorings are exactly the Latin squares of order $n^2$. The Sudoku graph is a
refinement of the rook's graph by the block relation, so the tower
$\text{rook graph} \to \text{Sudoku graph}$ connects design theory to coloring and
explains why every Sudoku solution is in particular a Latin square.

---

## 9. Future directions

1. **Clique number and further invariants.** We showed $\omega(G_n)=\chi(G_n)=n^2$.
   Compute the independence number and fractional chromatic number of $G_n$.

2. **Counting solutions $\leftrightarrow$ counting colorings.** Corollary 3.2
   equates the number of completed grids with $P(G_n, n^2)$, the chromatic
   polynomial at $n^2$. Developing this would tie Sudoku enumeration (for $9\times
   9$: $6{,}670{,}903{,}752{,}021{,}072{,}936{,}960$) to graph polynomials.

3. **Latin squares and partial bridges.** Formalize the tower rook-graph $\to$
   Sudoku-graph connecting design theory to coloring.

4. **List coloring / precoloring extension.** A Sudoku *puzzle* is a precoloring-
   extension problem; the NP-completeness of generalized Sudoku is exactly that of
   precoloring extension for $\{G_n\}$ — a bridge to complexity theory.

5. **The phase-transition conjecture.** Conjectures 6.1–6.2 are asymptotic and
   probabilistic and, to our knowledge, unproved. A rigorous treatment would use
   second-moment / interpolation methods from random-CSP theory (analogous to
   random $k$-SAT thresholds), built on the deterministic clique/chromatic backbone
   established here.

---

## References (selected, widely known)

- Standard texts on graph coloring and chromatic numbers.
- The literature on random constraint satisfaction and the random $k$-SAT
  satisfiability threshold.
- Known enumeration of $9\times 9$ Sudoku grids.
