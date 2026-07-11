# Computational Evidence — Flag Complex of a Theorem Network

We model a theorem network as a finite simple graph `G` (theorems = vertices,
co-citation = edges) and study its **flag / clique complex**: the `k`-faces are the
`(k+1)`-cliques. Let `faceCount G k = #{(k+1)-cliques}` be the `f`-vector, and let
`n = #V` be the number of theorems.

## 1. Small-case calculations (complete network `⊤`)

For the complete network every subset is a clique, so `faceCount ⊤ k = C(n, k+1)`.

| n | f₀=C(n,1) | f₁=C(n,2) | f₂=C(n,3) | f₃=C(n,4) | Euler χ = Σ(-1)^k f_k |
|---|-----------|-----------|-----------|-----------|------------------------|
| 1 | 1         | 0         | 0         | 0         | 1                      |
| 2 | 2         | 1         | 0         | 0         | 2 - 1 = 1              |
| 3 | 3         | 3         | 1         | 0         | 3 - 3 + 1 = 1          |
| 4 | 4         | 6         | 4         | 1         | 4 - 6 + 4 - 1 = 1      |
| 5 | 5         | 10        | 10        | 5         | 5 - 10 + 10 - 5 + 1 =1 |

Every row sums (with alternating signs) to **1**: the full simplex is contractible.
This directly matches `euler_char_top`.

## 2. Growth of the f-vector

For fixed `k`, `faceCount ⊤ k = C(n, k+1)` is a polynomial in `n` of degree `k+1`
with leading term `n^(k+1)/(k+1)!`. The two-sided bounds proved in Lean are:

* upper: `C(n, k+1) ≤ n^(k+1)`                       (`faceCount_le_pow`)
* lower: `(n-k)^(k+1) ≤ (k+1)! · C(n, k+1)`           (`faceCount_top_lower`)

Numerical check for `k = 2` (so degree 3, faces = triangles), scaling `3! = 6`:

| n | (n-2)^3 | 6·C(n,3) | n^3 |
|---|---------|----------|-----|
| 3 | 1       | 6        | 27  |
| 4 | 8       | 24       | 64  |
| 5 | 27      | 60       | 125 |
| 6 | 64      | 120      | 216 |
| 10| 512     | 720      | 1000|

`(n-2)^3 ≤ 6·C(n,3) ≤ n^3` holds throughout, confirming cubic growth of the
number of triangles.

## 3. OEIS

The `f`-vectors `C(n, k+1)` are the rows/diagonals of Pascal's triangle,
**OEIS A007318** (1, 1,1, 1,2,1, 1,3,3,1, ...). The alternating row sum being `0`
for `n ≥ 1` (equivalently Euler characteristic `1` after removing the empty face)
is the classical identity `Σ_m (-1)^m C(n,m) = 0`.

## 4. Counterexample hunt for the literal conjecture

The mission conjecture states the **Betti numbers** grow as `β_k ≈ n^(k+1)`.
For the complete co-citation network the complex is a full simplex, which is
contractible, so `β₀ = 1` and `β_k = 0` for all `k ≥ 1`, and `χ = 1` for every `n`.
Thus the literal statement about Betti numbers is **false** for this natural model
(it is refuted for every `n ≥ 1`). What actually grows like `n^(k+1)` is the
`f`-vector (face counts), which is the honest, provable form of the claim and is
what the Lean file establishes.
