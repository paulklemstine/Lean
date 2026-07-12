# Computational Evidence — Error-Correcting Neural Codes

This accompanies `Catalog/Novelty/NeuralErrorCorrection.lean`, which proves the
sphere-packing (Hamming) bound for binary neural codes.

## 1. Hamming ball volumes `V(N, r) = ∑_{k=0}^{r} C(N, k)`

| N | r=0 | r=1 | r=2 | r=3 |
|---|-----|-----|-----|-----|
| 3 | 1   | 4   | 7   | 8   |
| 4 | 1   | 5   | 11  | 15  |
| 7 | 1   | 8   | 29  | 64  |
| 8 | 1   | 9   | 37  | 93  |

For `r ≥ N` the volume saturates at `2^N` (since `C(N,k)=0` for `k>N`); this is
why the Lean statement `ball_card` uses `∑_{k∈range(r+1)} N.choose k` with no side
condition on `r ≤ N`.

## 2. The sphere-packing bound `|C| · V(N, t) ≤ 2^N`

For a `t`-error-correcting codebook (pairwise Hamming distance `≥ 2t+1`):

| N | t | V(N,t) | 2^N | ceiling `⌊2^N / V⌋` on `|C|` |
|---|---|--------|-----|------------------------------|
| 3 | 1 | 4      | 8   | 2   (repetition code, achieved) |
| 7 | 1 | 8      | 128 | 16  (Hamming(7,4) code, **perfect** — achieved with equality) |
| 15| 1 | 16     | 32768 | 2048 (Hamming(15,11), perfect) |
| 23| 3 | 2048   | 8388608 | 4096 (binary Golay code, perfect) |

The `t=1` row for `N=7` is the classic perfect Hamming code: the bound
`|C|·8 ≤ 128` is *tight*, so `≤ 16` codewords is achievable. This confirms the
bound is not merely an inequality artifact — it is met with equality by real
codes.

## 3. Special cases proved in Lean

- `t = 0`: `V(N,0) = 1`, so the bound reduces to `|C| ≤ 2^N`, recovering the raw
  coding capacity (`hamming_bound_capacity`).
- `t = 1`: `V(N,1) = N+1`, giving `|C|·(N+1) ≤ 2^N`
  (`singleton_error_correct_card`) — single-error correction costs a factor
  `1/(N+1)` of the capacity.

## 4. Sanity checks (all consistent with the formal statements)

- Ball volume is center-independent (translation invariance under neuron-wise
  XOR): computed for several centers at `N=4, r=2`, always `11`.
- `∑_{k=0}^{N} C(N,k) = 2^N` (partition of all patterns by weight): verified
  for `N ≤ 10` and proved via `Nat.sum_range_choose`.

No counterexamples were found to the sphere-packing inequality in any tested
case; on the contrary, perfect codes show it is sharp.
