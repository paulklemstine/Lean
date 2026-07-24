# Computational Evidence — Spectral Bridge for Cyclic Cayley Graphs

The formal file `QuantumWalkSpectralBridge.lean` proves that the adjacency (walk) operator of a
Cayley graph `Cay(ZMod n, S)` is diagonalised by the additive characters
`e_ζ(x) = ζ^x` of `ZMod n`, with eigenvalue the character sum `λ(ζ) = ∑_{s∈S} ζ^s`, and that for
the cycle `S = {±1}` this specialises to `λ_k = 2·cos(2πk/n)`.

The claims here are *exact algebraic identities*, so the "evidence" is confirmatory arithmetic
rather than statistics. Below are the small cases and the sanity checks performed.

## 1. The cycle graph `Cay(ZMod n, {±1})`

Eigenvalues are `λ_k = 2·cos(2πk/n)`, `k = 0,…,n-1`.

| n | eigenvalues `2·cos(2πk/n)` (k = 0,1,…,n-1)                     | degree = λ₀ |
|---|---------------------------------------------------------------|-------------|
| 3 | 2, -1, -1                                                     | 2           |
| 4 | 2, 0, -2, 0                                                   | 2           |
| 5 | 2, 0.618…, -1.618…, -1.618…, 0.618…                          | 2           |
| 6 | 2, 1, -1, -2, -1, 1                                           | 2           |

Consistency checks (all confirmed, and each is a *theorem* in the file):

* **Perron eigenvalue** (`eigenvalue_perron`): `λ₀ = 2·cos 0 = 2 = |S|`, the degree. ✔
* **Real spectrum** (`eigenvalue_real`): `{±1}` is symmetric, so every `λ_k` is real —
  indeed `2·cos(θ) ∈ ℝ`. ✔
* **Degree bound** (`norm_eigenvalue_le`): `|λ_k| = |2·cos(2πk/n)| ≤ 2 = |S|`. ✔
* **Trace = 0**: `∑_k 2·cos(2πk/n) = 0` for `n ≥ 2` (no self-loops in the cycle). ✔ for the rows above.

## 2. Diagonalisation on a general connection set

For `ZMod 4` with `S = {1, 3}` (= `{±1}`), the adjacency matrix in the standard basis is the
circulant
```
0 1 0 1
1 0 1 0
0 1 0 1
1 0 1 0
```
Its characteristic polynomial is `x²(x-2)(x+2)`, eigenvalues `{2, 0, 0, -2}`, matching
`2·cos(2πk/4) = {2, 0, -2, 0}`. The eigenvectors are exactly the Fourier vectors
`e_k = (1, i^k, i^{2k}, i^{3k})`, confirming `char_is_eigenvector`.

## 3. Counterexample hunt

* The diagonalisation `char_is_eigenvector` was checked to *fail* if `ζ` is **not** an `n`-th root
  of unity — as expected, the character property `ζ^{(x+s)} = ζ^x·ζ^s mod n` breaks — confirming
  the hypothesis `ζ^n = 1` is load-bearing (it is used essentially in `zeta_pow_mod`).
* `cycle_eigenvalue` requires `n ≥ 3`: for `n = 2`, `1 = -1` in `ZMod 2`, so the connection
  multiset `{1, -1}` collapses to a single element and the pair-sum formula does not apply. The
  hypothesis `3 ≤ n` rules this out.
* No counterexample to the universal claims (real spectrum for symmetric `S`, degree bound) was
  found; both are proved unconditionally in the file.

## 4. Relation to the OEIS

The multiset of cycle eigenvalues `{2cos(2πk/n)}` are the roots of the Chebyshev-like polynomial
whose values are tabulated implicitly through cyclotomic data; the integer eigenvalues occurring
for `n | 12` reproduce the small-graph spectra recorded in standard spectral-graph references.
No single OEIS integer sequence is the object of the theorem, so no OEIS ID is claimed.
