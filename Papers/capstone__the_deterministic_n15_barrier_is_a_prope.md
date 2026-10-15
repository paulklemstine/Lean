# Computational Evidence — divisibility coverings of `[n]`

Brute-force search (Python, exploratory; **not** a Lean artifact) for the least `M` such that
there are disjoint `S, T ⊆ [0, M]` with `|S| = |T| = k` and every `i ∈ [n]` dividing some `s − t`
(WLOG `0, M ∈ S ∪ T` by translation).  Search cap `M ≤ 60` for `k ≥ 2`.

| n | k = 1 (least `M`) | k = 2 (least `M`, witness) | k = 3 (least `M`, witness) |
|---|---|---|---|
| 4  | 12      | 4  `{0,1},{2,4}`   | 5  `{0,1,2},{3,4,5}` |
| 6  | 60      | 6  `{0,1},{4,6}`   | 6  `{0,1,2},{3,4,6}` |
| 8  | 840     | 8  `{0,1},{6,8}`   | 8  `{0,1,2},{3,5,8}` |
| 9  | 2520    | 18 `{0,2},{7,18}`  | 9  `{0,1,2},{3,6,9}` |
| 10 | 2520    | 20 `{0,2},{16,20}` | 10 `{0,1,2},{3,7,10}` |
| 11 | 27720   | 40 `{0,4},{11,40}` | 11 `{0,1,2},{3,8,11}` |
| 12 | 27720   | 40 `{0,4},{11,40}` | 12 `{0,1,2},{3,9,12}` |
| 13 | 360360  | > 60               | 13 `{0,1,2},{7,10,13}` |
| 14 | 360360  | > 60               | 14 `{0,1,2},{8,11,14}` |
| 15 | 360360  | —                  | 15 `{0,1,2},{9,12,15}` |
| 16 | 720720  | —                  | 16 `{0,1,2},{10,13,16}` |

Observations.
* `k = 1`: the least `M` equals `lcm(1..n)` in every row (OEIS A003418: 1, 2, 6, 12, 60, 60, 420,
  840, 2520, 2520, 27720, …).  This is now a **theorem** (`UMW.single_pair_optimal` +
  `UMW.lcm_covering`), not just data.
* `k = 3`, `n ≤ 14`: the least `M` is `n` — once `k² ≥ n` the covering is "free" (interval-type,
  as in the BSGS covering `UMW.bsgs_covering`, which handles `n = k²` with `M = 2k²`).
* `k = 2`: `M` jumps as soon as `n > k² + O(1)` (`n = 9`): beyond the interval regime the sets
  must carry divisibility "by design", and the cost grows fast (no covering of `[13]` with `M ≤ 60`).
* Counterexample hunt for the exact wall `4^n ≤ (2n+1)·M^{k²}` (`UMW.counting_wall`): no violation
  in any row (as it must be, since it is proved).  E.g. `n = 12` (`2n' = 12`, `n' = 6`), `k = 2`,
  `M = 40`: `4^6 = 4096 ≤ 13·40^4`.
