# Computational evidence

Topic: *Towards a characterization of idempotent Schur multipliers* — boolean matrices, the
factorization norm `γ₂`, and decompositions into signed sums of blow-ups of identity
matrices.

All *claims* in this project are backed by machine-checked Lean proofs in
`Catalog/Pythagorean/SchurIdempotent*.lean`. The material below is exploratory numerical
work carried out **before** the Lean formalization, to decide what was true and worth
proving. It is explicitly **not** a verification; it is scratch evidence.

## 1. The exact value of `γ₂` for the `2 × 2` triangular truth matrix

`A = [[1,1],[1,0]]` is the smallest boolean matrix that is not a blow-up of an identity
matrix. Its `γ₂`-norm was estimated by bisection on `c` combined with a search over the two
free Gram entries `u = ⟨x₁,x₂⟩`, `v = ⟨y₁,y₂⟩`, testing positive semidefiniteness of

```
G = [[c, u, 1, 1],
     [u, c, 1, 0],
     [1, 1, c, v],
     [1, 0, v, c]]
```

by Cholesky. Result:

| quantity | numeric value |
|---|---|
| smallest feasible `c` | `1.15470053837907…` |
| `2/√3 = 2√3/3` | `1.15470053837925…` |
| optimal `u`, `v` | `0.57735026918…` (i.e. `c/2` for both) |

This matches the closed form `γ₂(A) = 2√3/3` and suggested both the primal witness (four
vectors of equal length `√(2√3/3)` at consecutive `30°` angles, formalized in
`tri2_gammaTwoLE_sharp`) and the dual sum-of-squares certificate

```
0 ≤ ‖√3·b − 2p + q‖² + 2‖−√3·a + p + q‖² = 6‖a‖² + 3‖b‖² + 6‖p‖² + 3‖q‖² − 12√3
```

which is formalized in `gammaTwo_ge_of_triPattern`. The two bounds coincide, so the value is
exact — this is proved in Lean as `gammaTwoLE_tri2_iff`.

## 2. Exhaustive check of the combinatorial step of the gap theorem

The Lean proof of the gap theorem factors through: *a boolean matrix is a blow-up iff it is
"row rigid" (two rows sharing a `1` in a common column are equal) iff it contains no
`[[1,1],[1,0]]` pattern*. Both equivalences were checked by brute force over all boolean
matrices of small size before being proved in general
(`isBlowUp_iff_rowRigid`, `exists_triPattern_of_not_rowRigid`):

| `m × n` | # boolean matrices | # blow-ups (= row rigid) | mismatches between "not rigid" and "contains the pattern" |
|---|---|---|---|
| 1 × 1 | 2 | 2 | 0 |
| 2 × 2 | 16 | 12 | 0 |
| 2 × 3 | 64 | 34 | 0 |
| 3 × 3 | 512 | 128 | 0 |
| 3 × 4 | 4096 | 466 | 0 |

The counts `2, 12, 34, 128, 466` are the numbers of contractive idempotent Schur
multipliers on matrices of the given shape. No online OEIS lookup was performed, so no OEIS
identifier is claimed here.

## 3. Counterexample hunt

* Searched for a boolean matrix with `1 < γ₂ < 2√3/3` among all `2 × 2` and `3 × 3` boolean
  matrices (using the criterion of §2 plus the SDP bisection of §1 on the non-rigid ones):
  none found, consistent with the gap theorem `gammaTwo_gap`.
* Checked that the bound `γ₂(A) ≤ L` for a signed sum of `L` blow-ups is *not* tight:
  `tri2` is a signed sum of `2` blow-ups but has `γ₂ = 1.1547… < 2`.

## 4. The next staircase, `T₃ = [[1,1,1],[1,1,0],[1,0,0]]`

Two independent crude searches (simulated annealing over the six free Gram parameters, with a
Cholesky feasibility test) returned inconsistent brackets for `γ₂(T₃)`, approximately `1.40`
and approximately `1.48`. The value is therefore **undetermined** by this exploration; the
only rigorous statements available are `2√3/3 ≤ γ₂(T₃) ≤ √3` (the lower bound from
`gammaTwo_ge_of_triPattern` applied to a `2 × 2` sub-pattern of `T₃`, the upper bound from
`gammaTwoLE_sqrt_of_boolean`); both are formalized in `tri3_bounds`. Determining it exactly is
Conjecture 1 of `FUTURE_DIRECTIONS.md`.
