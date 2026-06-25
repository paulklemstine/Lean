# Computational Evidence — Extremal Graph Theory (Turán, Roth, Kruskal–Katona)

Concise numerical sanity checks for the formalized claims. These motivated the exact
statements proved in the three `.lean` files; the Lean proofs (0 sorries) are the
authoritative verification.

## 1. Mantel / Turán edge bound `e(G) ≤ (1 - 1/r)·n²/2`

The bound is `2·r·e(G) ≤ (r-1)·n²` (integer form `turan_edge_bound_nat`).

Triangle-free (`r = 2`) extremal graphs are complete bipartite `K_{⌊n/2⌋,⌈n/2⌉}`:

| n | ⌊n²/4⌋ (Mantel max) | e(K_{⌊n/2⌋,⌈n/2⌉}) |
|---|---------------------|--------------------|
| 2 | 1                   | 1                  |
| 3 | 2                   | 2                  |
| 4 | 4                   | 4                  |
| 5 | 6                   | 6                  |
| 6 | 9                   | 9                  |

Matches `mantel_nat`/`mantel_real` (`e ≤ n²/4`) with equality at the balanced bipartite graph.

For `r = 3` (`K_4`-free), `(1 - 1/3)·n²/2 = n²/3`: n = 6 ⇒ bound 12, achieved by the
complete tripartite `K_{2,2,2}` with 12 edges. Consistent.

## 2. Roth numbers `rothNumberNat N` (largest 3AP-free subset of {0,…,N-1})

OEIS A065825 (max size of 3AP-free subset of {1,…,n}); first terms:
`1, 2, 2, 3, 4, 4, 4, 4, 5, 5, …`. The density `rothNumberNat N / N` is
`1, 1, 0.67, 0.75, 0.8, 0.67, …` and provably → 0 (`rothNumberNat_density_tendsto_zero`).

Counterexample hunt for `exists_threeAP_of_freq_dense`: any A with frequent density ≥ c > 0
must contain a 3-AP. Sampling A = even numbers (density 1/2): contains 0,2,4 (a 3-AP), as
predicted. A = {n : popcount even} (Thue–Morse-ish, density 1/2): still contains 3-APs,
consistent with the theorem (no positive-density 3AP-free set exists).

## 3. Kruskal–Katona shadow bounds

For `𝒜 = ` all `r`-subsets of `{0,…,k-1}` (size `k.choose r`), the `i`-th shadow is all
`(r-i)`-subsets, of size `k.choose (r-i)` — the equality case of
`kruskal_katona_lovasz_form`.

| k | r | #𝒜 = C(k,r) | #∂𝒜 = C(k,r-1) |
|---|---|-------------|-----------------|
| 4 | 2 | 6           | 4               |
| 5 | 3 | 10          | 10              |
| 6 | 3 | 20          | 15              |

The shadow is nonempty in all rows and stays nonempty through `∂^[r]` (reaching the empty
layer, `C(k,0)=1`), matching `kk_iterated_shadow_nonempty`.

All tables are small finite checks; the universal statements are proved in Lean.
