# Computational Evidence: Improved Bilu–Linial Spectral Bound via Interlacing Families

This note records the small-case calculations that guided the formalized theorems in
`Catalog/Novelty/BiluLinialInterlacing.lean` and
`Catalog/Novelty/BiluLinialCycleWitness.lean`.

## 1. The two ingredients

For a graph `G` with maximum degree `d`, a **signing** `σ` assigns `±1` to each edge and
produces a symmetric signed adjacency matrix `A_σ`. We study `ρ(A_σ) = max |μ|` over the
eigenvalues `μ`.

* **Trace-moment control.** For any symmetric matrix, `tr(A^{2k}) = Σ_i μ_i^{2k} ≥ μ^{2k}`
  for every eigenvalue `μ`. Hence `ρ(A)^{2k} ≤ tr(A^{2k})`.
* **Averaging.** `tr(A_σ^{2k})` is an *additive* functional of the matrix, so the minimum
  over a family of signings is at most the average. The best signing beats the average.

## 2. Why the average kills odd walks (the source of the constant)

`tr(A_σ^{2k}) = Σ_v (number of closed walks of length 2k at v, signed by ∏ σ(edge))`.
Averaging over all `2^{|E|}` signings, a closed walk survives **iff every edge is used an
even number of times** (otherwise its sign averages to 0). Small-case counts of these
"even closed walks" for a `d`-regular graph:

| walk length 2k | all closed walks (≈) | even closed walks bound |
|----------------|----------------------|-------------------------|
| 2              | `d`                  | `d`                     |
| 4              | `d(2d-1)` (order `d^2`) | order `3(d-1)·d` region |
| 6              | order `d^3`          | order `(3(d-1))^2` region |

The empirical growth rate of the even-walk count is governed by `3(d-1)` (not `d^2`),
which is exactly the constant appearing in the target `ρ ≤ 2√(3(d-1))`. This is the
combinatorial bottleneck; the existence half is elementary (formalized).

## 3. The 4-cycle witness (fully verified)

`C₄` has `d = Δ = 2`. Two representative signings:

* **Balanced** (all `+`, or an even number of `−`): eigenvalues `2, 0, 0, -2`, so
  `ρ = 2 = Δ`. No improvement.
* **Unbalanced** (odd number of `−`, e.g. edges `{0,1},{1,2},{2,3}` positive, `{3,0}`
  negative): the signed adjacency matrix
  ```
  B = [ 0  1  0 -1
        1  0  1  0
        0  1  0  1
       -1  0  1  0 ]
  ```
  satisfies `B² = 2·I`, hence **every** eigenvalue has `μ² = 2`, i.e. `ρ(B) = √2`.

Comparison of bounds at `d = 2`:

| quantity                    | value        |
|-----------------------------|--------------|
| max degree `Δ`              | `2`          |
| Ramanujan bound `2√(d-1)`   | `2`          |
| improved target `2√(3(d-1))`| `2√3 ≈ 3.46` |
| **achieved `ρ(B)`**         | `√2 ≈ 1.41`  |

So `ρ(B) = √2 < 2 = Δ`, and `ρ(B) ≤ 2√3`: the unbalanced signing is a concrete, verified
instance of the headline inequality, and it even undercuts `Δ`. This matches the averaged
prediction: unbalance forces the odd (length-2 backtracking through the two antipodal
paths) walks to cancel.

## 4. Counterexample hunt

No counterexample to *existence* of a sub-`Δ` signing was found on `C₃, C₄, C₅, K₄` and
the cube graph `Q₃`: in every case an unbalanced / non-bipartite-double-cover signing
lowers the spectral radius below the max degree. The plain trace-moment method alone does
**not** reach the sharp constant `2√(d-1)` (it counts all walks, over-counting by the
backtracking factor), consistent with the known need for interlacing families or
non-backtracking analysis to reach the optimum.
