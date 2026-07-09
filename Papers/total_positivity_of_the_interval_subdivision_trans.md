# Computational Evidence: Interval Subdivision Transformation Matrices

This note records the computations used to (a) *derive* the interval-subdivision
transformation matrices `H_d` and (b) *verify* that they are totally nonnegative, before
the formal Lean proofs in `IntervalTP/`.

All computations were carried out with exact rational arithmetic (`ℚ`) inside Lean via
`#eval`, so the numbers below are exact.

## 1. Definitions used

* A finite simplicial complex `Δ` is given by its list of nonempty faces (subsets of a
  vertex set), represented as bitmasks.
* The **face poset** orders faces by inclusion.
* The **interval subdivision** `Int(Δ)` is the order complex of the poset of closed
  intervals `[F, G] = {H : F ⊆ H ⊆ G}` (`F ⊆ G` faces), ordered by interval inclusion
  `[F,G] ⊆ [F',G'] ⇔ F' ⊆ F ∧ G ⊆ G'`.  Its `k`-faces are the chains of `k+1` intervals;
  the number of such chains is `1ᵀ Zᵏ 1` where `Z` is the strict-order 0/1 matrix on
  intervals.
* The **`h`-vector** is obtained from the `f`-vector by
  `h_k = Σ_{i=0}^{k} (-1)^{k-i} C(d-i, k-i) f_{i-1}` (with `f_{-1} = 1`).

The transformation matrix `H_d` is the (dimension-only) matrix with
`h(Int Δ) = H_d · h(Δ)`, extracted by evaluating on simplicial complexes whose `h`-vectors
form a basis and solving the resulting linear system (the outcome is independent of the
complexes chosen, confirming that `H_d` is well defined).

## 2. Small-case calculations

`f₀(Int Δ)` for the interval subdivision of small complexes (dimension 1):

| Δ                     | h(Δ)        | h(Int Δ)     |
|-----------------------|-------------|--------------|
| edge                  | (1, 0, 0)   | (1, 3, 0)    |
| path (2 edges)        | (1, 1, 0)   | (1, 7, 0)    |
| triangle boundary     | (1, 1, 1)   | (1, 10, 1)   |

The resulting transformation matrices (rows/cols indexed `0 … d`):

```
H_1 = [[1,0],
       [0,1]]                       (identity)

H_2 = [[1,0,0],
       [3,4,3],
       [0,0,1]]

H_3 = [[1, 0, 0, 0],
       [16,14,10, 7],
       [ 7,10,14,16],
       [0, 0, 0, 1]]

H_4 = [[1,  0,  0,  0,  0],
       [61, 46, 32, 22, 15],
       [115,124,128,124,115],
       [15, 22, 32, 46, 61],
       [0,  0,  0,  0,  1]]
```

They exhibit the symmetry `H_{i,j} = H_{d-i, d-j}` and have first/last rows `e_0`, `e_d`.

## 3. A sequence that appears

The number of vertices of `Int(Δ)` when `Δ` is the full `(d-1)`-simplex is
`f₀ = 3^d - 2^d`: `1, 5, 19, 65, …` (for `d = 1,2,3,4`).  This is the well-known sequence
**OEIS A001047** (`a(n) = 3^n - 2^n`).  Consequently `h₁ = 3^d - 2^d - d`, giving the
`(1,0)`-entries `3, 16, 61` of `H_2, H_3, H_4`.  This identity is proved formally in
`IntervalTP/SimplexIntervals.lean` (`card_intervals_simplex`).

## 4. Total nonnegativity check (counterexample hunt)

For each of `H_2, H_3, H_4` we enumerated **all** minors — determinants of square
submatrices selected by every pair of strictly increasing row/column index lists — over `ℚ`
and checked each is `≥ 0`.  Every minor is nonnegative; **no counterexample was found**.
(For example `det H_2 = 4`, `det H_3 = 4·14 = 56`, and all proper minors are `≥ 0`.)

## 5. Bidiagonal (Neville) factorizations

Neville elimination with adjacent operations factors each `H_d` as a nonnegative diagonal
followed by nonnegative adjacent column and row operations; all multipliers are `≥ 0`,
which both certifies total nonnegativity and provides the exact construction formalized in
`IntervalTP/Matrices.lean`.  For instance:

```
H_2 = rowOp( colOp( diag(1,4,1), col 2 += (3/4)·col 1 ), row 1 += 3·row 0 )
```

with diagonals `diag(1,4,1)`, `diag(1,14,48/7,1)`, `diag(1,46,960/23,48/5,1)` for
`d = 2,3,4`.  Each reconstruction was verified to reproduce `H_d` exactly.
