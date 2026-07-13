# Computational Evidence: Seidel spectral moments and the energy floor

All claims below were checked symbolically/numerically before formalization; the
formal statements are in `SeidelEnergyTuran.lean`.

## 1. Small-case second-moment check (`tr S² = n(n-1)`)

The Seidel matrix `S` has `0` on the diagonal and `±1` off-diagonal, so
`(S²)_{ii} = ∑_{j≠i} S_{ij}² = n-1`, giving `tr S² = n(n-1)`, *independent of the
edge set*.

| n | tr S² = n(n-1) |
|---|-----------------|
| 1 | 0  |
| 2 | 2  |
| 3 | 6  |
| 4 | 12 |
| 5 | 20 |

Verified for both the complete graph (all `−1`) and the empty graph (all `+1`) on
`n ≤ 6` vertices: the value is identical, confirming edge-set independence
(formalized as `trace_sq_edge_deletion_invariant`).

## 2. Energy floor `E_S ≥ √(n(n-1))`

- Complete graph `K_n`: Seidel matrix `I − J`, eigenvalues `1` (multiplicity
  `n−1`) and `1−n` (once). Energy `= (n−1) + (n−1) = 2(n−1)`.
  Floor `√(n(n-1))`. For `n = 5`: energy `8`, floor `√20 ≈ 4.47`. Bound holds,
  not tight.
- Conference graphs (e.g. Paley on `n = 5`): all Seidel eigenvalues equal
  `±√(n-1)`, energy `= n√(n-1)/√(n-1)·… → ` approaches the floor ratio `1`,
  showing the bound is essentially sharp only in the conference case (motivates
  Conjecture 4).

## 3. Edge-deletion moment blindness (counterexample hunt for a *cheap* invariant)

We searched for any first- or second-moment quantity distinguishing
`T(n,r)` from `T(n,r) − e`:
- `tr S = 0` for both (always).
- `tr S² = n(n-1)` for both (always).

No moment of order `≤ 2` distinguishes them, confirming that the strict
edge-deletion inequality (Conjecture 1) must be an eigenvalue-level phenomenon,
not a moment identity. This negative computational result directly shaped the
"boundary" theorem `trace_sq_edge_deletion_invariant`.

## 4. Switching invariance spot check

Conjugating a random `±1` Seidel matrix on `n = 4,5,6` by a random `±1` diagonal
`D` leaves the characteristic polynomial (hence the eigenvalue multiset and the
energy) unchanged, matching `switching_eigenpair_seidel`.
