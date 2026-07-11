# Computational Evidence — Spectral Gap of the Swap Chain

We test the intrinsic model: the swap chain is the symmetric, doubly stochastic walk
`P = swapP G c` on the graph `G` of *compatible swaps* between admissible completions,
with holding rate `c`.

## 1. Two-state calculations (exactly solvable)

Take two completions related (or not) by a single compatible swap.

* **Connected** (complete graph on 2 vertices), matrix
  `P = [[1-c, c], [c, 1-c]]`.
  Eigenvectors: `(1,1)` with eigenvalue `1`; `(1,-1)` with eigenvalue `1 - 2c`.
  Spectral gap `= 1 - (1 - 2c) = 2c`.

  | c    | λ₁ | λ₂    | gap = 2c |
  |------|----|-------|----------|
  | 0.1  | 1  | 0.8   | 0.2      |
  | 0.25 | 1  | 0.5   | 0.5      |
  | 0.5  | 1  | 0.0   | 1.0      |

* **Disconnected** (empty graph on 2 vertices), matrix `P = I`.
  Both eigenvalues equal `1`; gap `= 0`. The chain never moves.

These two puzzles have the **same** number of completions (2) and can be presented with
the **same** number of clues, yet their gaps are `2c` and `0`. Clue count does not
predict the gap; connectivity of the swap graph does.

## 2. General finite move graph

For `swapP G c` on any finite `G`:

* Row sums are `1` (stochastic); the matrix is symmetric (doubly stochastic); the
  uniform law is stationary and `(1,…,1)` is a top eigenvector with eigenvalue `1`.
* A vector `f` is fixed iff it is *harmonic*: `deg(x)·f(x) = Σ_{y∼x} f(y)` for all `x`.
* If `G` has `k ≥ 2` connected components, the `k` component indicators are linearly
  independent fixed vectors ⇒ eigenvalue `1` has multiplicity `≥ 2` ⇒ **gap = 0**.
* If `G` is connected, the maximum principle forces every fixed vector to be constant
  ⇒ eigenvalue `1` is **simple**, the prerequisite for a strictly positive gap.

## 3. Counterexample hunt against the folklore claim

The claim "gap is a decreasing function of clue count, vanishing above ~30 clues"
fails on the two-state family in §1: fixing clue/solution counts and toggling a single
compatible swap flips the gap between `2c > 0` and `0`. The order parameter is the
reducible/irreducible dichotomy of the move graph, not the clue count. No numerical
search over `81`-cell grids is needed — the two-state witness already refutes the
universal statement.

## 4. Sudoku fixture

A compatible swap inside a row permutes that row, preserving its value multiset; hence
every admissible row has fixed entry-sum `0+1+⋯+8 = 36`. Level sets of such conserved
quantities are exactly the invariant blocks into which the swap graph decomposes.
