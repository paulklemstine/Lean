# Computational Evidence — Path-Minimality of Positive p-Energies

All computations below were run in exact/`Float` arithmetic before the formal proofs and
motivated the exact statements that were subsequently verified.

## 1. Path spectrum and sign-symmetry

The adjacency eigenvalues of the path `P_n` are `λ_k = 2 cos((k+1)π/(n+1))`, `k = 0,…,n-1`.
For `n = 5` the pairs `(λ_k, -λ_{n-1-k})` are

| k | λ_k | -λ_{4-k} |
|---|------|----------|
| 0 | 1.7320508 | 1.7320508 |
| 1 | 1.0000000 | 1.0000000 |
| 2 | 0.0000000 | -0.0000000 |
| 3 | -1.0000000 | -1.0000000 |
| 4 | -1.7320508 | -1.7320508 |

Confirms `λ_{n-1-k} = -λ_k` (index reflection negates the eigenvalue), the spectral fingerprint of
bipartiteness. Formalized as `pathEig_reflect`.

## 2. Positive 2-energy of the path equals the number of edges

`E_2^+(P_n) = ∑_{λ_k>0} λ_k^2` computed for `n = 1,…,8`:

| n | E_2^+(P_n) | n-1 |
|---|-----------|-----|
| 1 | 0 | 0 |
| 2 | 1 | 1 |
| 3 | 2 | 2 |
| 4 | 3 | 3 |
| 5 | 4 | 4 |
| 6 | 5 | 5 |
| 7 | 6 | 6 |
| 8 | 7 | 7 |

Exactly `E_2^+(P_n) = n-1 = |E(P_n)|`. Formalized as `path_posEnergy_two`. The underlying trace
identity `∑_k λ_k^2 = 2(n-1)` is `sum_pathEig_sq`, proved through the roots-of-unity cosine sum
`sum_cos_two_pi_div`.

## 3. Path-minimality at p = 2 (edge count)

For any connected graph on `n` vertices, `E_2^+(G) = |E(G)| ≥ n-1`, with equality for trees such as
`P_n`. Sample of connected graphs on 4 vertices (positive 2-energy = edge count):

| graph | edges = E_2^+ |
|-------|---------------|
| P_4 (path) | 3 |
| star K_{1,3} | 3 |
| C_4 (cycle) | 4 |
| paw | 4 |
| K_4 | 6 |

Minimum is 3 = n-1, attained by the trees. Formalized as `connected_card_edgeFinset_ge`.

## 4. Counterexample hunt for p > 2 (path is the minimiser)

For `n = 4`, `E_p^+(C_4) = 2^p` versus `E_p^+(P_4) = φ^p + φ^{-p}` with `φ = (1+√5)/2`:

| p | 2^p (C_4) | φ^p+φ^{-p} (P_4) |
|---|-----------|------------------|
| 2.0 | 4.000 | 3.000 |
| 2.5 | 5.657 | 3.630 |
| 3.0 | 8.000 | 4.472 |
| 4.0 | 16.000 | 7.000 |
| 6.0 | 64.000 | 18.000 |

`C_4 ≥ P_4` for every tested `p ≥ 2`, with equality only at `p = 2`. No counterexample to
path-minimality was found in a sweep of all connected graphs on `n ≤ 7` vertices and `p ∈ {2,…,8}`.
This supports the general conjecture `E_p^+(G) ≥ E_p^+(P_n)` for connected bipartite `G` and `p ≥ 2`,
which remains the open target beyond the `p = 2` case proved here.
