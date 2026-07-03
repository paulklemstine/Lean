# Computational Evidence — Path-Minimality of Positive p-Energies

All quantities below were computed numerically before the formal proofs were
attempted. The adjacency spectrum of the path `P_n` is
`λ_k = 2 cos((k+1)π/(n+1))`, `k = 0, …, n-1`.

## 1. Squared spectral energy of the path equals `2(n-1)`

`∑_k λ_k²` for `P_n`:

| n | ∑ λ_k² (computed) | 2(n-1) |
|---|-------------------|--------|
| 2 | 2.000000          | 2      |
| 3 | 4.000000          | 4      |
| 4 | 6.000000          | 6      |
| 5 | 8.000000          | 8      |

This matches the trace identity `∑ λ² = trace(A²) = ∑_v deg(v) = 2|E|`, and
`P_n` has exactly `n-1` edges. Formalized as `sum_pathEig_sq` (companion file)
and, at the level of an arbitrary graph's genuine adjacency spectrum, as
`sum_eigenvalues_sq_eq_two_card_edges`.

## 2. Positive 2-energy of the path equals `n-1`

`∑_{λ_k>0} λ_k²` for `P_n`:

| n | E_2^+(P_n) | n-1 |
|---|-----------|-----|
| 2 | 1.000000  | 1   |
| 3 | 2.000000  | 2   |
| 4 | 3.000000  | 3   |
| 5 | 4.000000  | 4   |

The path spectrum is sign-symmetric (`λ_{n-1-k} = -λ_k`), so
`E_2^+ = ½ ∑ λ² = (n-1)`. Formalized as `path_posEnergy_two`.

## 3. Counterexample hunt for path-minimality (n = 4, p = 3)

Connected graphs on 4 vertices, positive 3-energy `∑_{λ>0} λ³`:

| Graph | positive eigenvalues     | E_3^+     |
|-------|--------------------------|-----------|
| P_4   | {1.618…, 0.618…}         | 4.472136  |
| C_4   | {2, 0}                   | 8.000000  |
| K_4   | {3}                      | 27        |
| star  | {√3}                     | 5.196…    |

The path `P_4` attains the minimum (`4.472136`), consistent with the
conjecture `E_p^+(G) ≥ E_p^+(P_n)`. No connected 4-vertex counterexample was
found.

## 4. Sequence note

`E_2^+(P_n) = n - 1` is the trivial linear sequence; `∑ λ² = 2(n-1)` is
`2, 4, 6, 8, …` (OEIS A005843 shifted). The interesting content is the
extremal *inequality*, not the sequence.

## Scope of what is formally proved

* `∑ λ_i(G)² = 2|E(G)|` for **any** finite simple graph (spectral theorem +
  degree sum), file `PositivePEnergyGraphTwo.lean`.
* `connected_squaredEnergy_ge_path`: for connected `G` on `n` vertices,
  `∑_k λ_k(P_n)² ≤ ∑_i λ_i(G)²` — squared-energy path-minimality.
* For bipartite (reflection-antisymmetric) spectra,
  `∑ |λ|^p = 2 E_p^+` (file `PositivePEnergySchatten.lean`), so the squared
  identity gives `E_2^+(G) = |E(G)| ≥ n-1 = E_2^+(P_n)`.

The full `p ≥ 2` inequality for all positive eigenvalues remains open (needs
spectral majorization); see `FUTURE_DIRECTIONS.md`.
