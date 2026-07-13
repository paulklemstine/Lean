# Computational Evidence — Brouwer Laplacian Equality

We record small-case checks for the quantities formalized in
`EqualityCharacterization.lean`: the partial Laplacian spectral sums `s_k`, the
Brouwer bound `m + C(k+1,2)`, and the equality cases on threshold graphs.

## 1. Total spectral sum equals `2m`

Laplacian spectra of small graphs (eigenvalues in descending order):

| Graph            | n | m | Laplacian spectrum        | Σ λ | 2m |
|------------------|---|---|---------------------------|-----|----|
| K₂ (edge)        | 2 | 1 | 2, 0                      | 2   | 2  |
| P₃ (path)        | 3 | 2 | 3, 1, 0                   | 4   | 4  |
| K₃ (triangle)    | 3 | 3 | 3, 3, 0                   | 6   | 6  |
| star K₁,₃        | 4 | 3 | 4, 1, 1, 0                | 6   | 6  |
| K₄               | 4 | 6 | 4, 4, 4, 0                | 12  | 12 |

Every row confirms `Σ λ = 2m` (theorem `laplacian_total_spectralSum_eq_two_mul_edges`).

## 2. Brouwer equality on threshold graphs

The Brouwer bound is `s_k = m + C(k+1,2)`. Threshold graphs of clique number
`k+1` should saturate it.

* **P₃** (a threshold graph, clique number 2, so `k = 1`): `s_1 = 3`,
  `m + C(2,2) = 2 + 1 = 3`. Equality holds.
* **star K₁,₃** (threshold, clique number 2, `k = 1`): `s_1 = 4`,
  `m + C(2,2) = 3 + 1 = 4`. Equality holds.
* **K₄** (threshold, clique number 4, `k = 3 = n-1`): `s_3 = 12`,
  `m + C(4,2) = 6 + 6 = 12`. Equality holds.

## 3. Counterexample hunt (off the extremal family)

* **C₄** (4-cycle, *not* a threshold graph): spectrum `4, 2, 2, 0`. At `k = 1`:
  `s_1 = 4`, but `m + C(2,2) = 4 + 1 = 5`, so `s_1 < bound` — strict slack, as
  expected for a non-threshold graph.
* **Empty graph on 3 vertices** (`m = 0`): spectrum `0,0,0`, so `s_k = 0` while
  `C(k+1,2) ≥ 1` for `k ≥ 1`. Maximal slack; matches the boundary discussion in
  the source file.

No counterexample to the equality *characterization* was found: every graph that
saturated the bound in the sample is a threshold graph of the predicted clique
number, and every non-threshold sample had strict slack.

## 4. Sequence note

The saturating values `s_{n-1}(K_n) = n(n-1)` for the complete graph reproduce
`2 · C(n,2)` (OEIS A002378, oblong numbers `n(n-1)`), consistent with the
trace identity at the top level.
