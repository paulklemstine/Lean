# Computational evidence — NET-56 oracle-to-policy eviction gap

All numbers below come from a brute-force enumeration of the abstract model that the two
Lean files formalise (`Catalog/Novelty/OracleOnlineEvictionGap.lean`,
`Catalog/Novelty/OracleOnlineEvictionSharp.lean`).  The enumeration is *exploratory*: it is
not itself machine-checked.  The claims it suggested are the ones proved in Lean, and the
Lean proofs — not this table — are the verification.

## 1. The adversarial family: oracle 1, any causal policy `B/n`

Family `adv n T j₀`: `T` uniform rows, then a one-hot row on key `j₀`.  Because the prefix
is identical across `j₀`, a causal policy commits to one cache `S` (`|S| ≤ B`) before the
one-hot row is revealed, so its retention on instance `j₀` is `1{j₀ ∈ S}`.  Enumerating all
caches and taking the *best possible* causal policy:

| n | B | oracle | best causal average | bound `B/n` |
|---|---|--------|---------------------|-------------|
| 4 | 1 | 1.0000 | 0.2500 | 0.2500 |
| 4 | 2 | 1.0000 | 0.5000 | 0.5000 |
| 4 | 3 | 1.0000 | 0.7500 | 0.7500 |
| 5 | 2 | 1.0000 | 0.4000 | 0.4000 |
| 8 | 1 | 1.0000 | 0.1250 | 0.1250 |
| 8 | 4 | 1.0000 | 0.5000 | 0.5000 |
| 8 | 7 | 1.0000 | 0.8750 | 0.8750 |

The bound `causal_average_le` is attained exactly by every `B`-subset, and the worst-case
instance gives retention `0` against oracle `1` (theorem `oracle_overstates`).

## 2. The two diagnostic families (accumulated score at the served row, `T = 3`)

`staleW`: prefix hammers key `0`, served row attends the current key `n-1`.
`pinW`: every row, including the served one, attends key `0`.

| n | B | HH cache | recency cache | hybrid cache | stale needs `n-1` | pinned needs `0` |
|---|---|----------|---------------|--------------|-------------------|------------------|
| 4 | 1 | {0} | {3} | {3} | HH 0, REC 1, HYB 1 | HH 1, REC 0, HYB 0 |
| 4 | 2 | {0,1} | {2,3} | {0,3} | HH 0, REC 1, HYB 1 | HH 1, REC 0, HYB 1 |
| 4 | 3 | {0,1,2} | {1,2,3} | {0,2,3} | HH 0, REC 1, HYB 1 | HH 1, REC 0, HYB 1 |
| 8 | 2 | {0,1} | {6,7} | {0,7} | HH 0, REC 1, HYB 1 | HH 1, REC 0, HYB 1 |
| 8 | 3 | {0,1,2} | {5,6,7} | {0,6,7} | HH 0, REC 1, HYB 1 | HH 1, REC 0, HYB 1 |

Two observations that shaped the formal statements:

* neither pure arm dominates (`no_policy_dominance`);
* the hybrid needs `B ≥ 2` — at `B = 1` the heavy-hitter half of the split is empty and the
  hybrid loses the pinned family.  This is exactly the hypothesis `2 ≤ B` carried by
  `hyb_hits_pin`, and the degenerate-split failures are `hybrid_split_necessary`.

## 3. The sharp instance for the `B·ε` price (`ε = 0.01`)

`sharpW`: the `B` best-scoring keys carry weight `0`, all others carry `ε`.

| B | n = 2B | top-by-score cache | its retention | oracle | gap | `B·ε` |
|---|--------|--------------------|---------------|--------|-----|-------|
| 1 | 2 | {0} | 0.0000 | 0.0100 | 0.0100 | 0.0100 |
| 2 | 4 | {0,1} | 0.0000 | 0.0200 | 0.0200 | 0.0200 |
| 4 | 8 | {0,1,2,3} | 0.0000 | 0.0400 | 0.0400 | 0.0400 |

The gap equals `B·ε` at every budget, which is `price_is_sharp`.

## 4. The recorded run

The NET-56 table itself (oracle 0.9913 / 0.9953; HH 0.8633 / 0.8822 / 0.9189;
HYB 0.9205 / 0.9384 / 0.9605) is encoded as `measured` and its three horns — the 11.31-point
gap at `B = 64`, the recency gain at every budget, the refutation of the 0.95 target — are
proved arithmetically (`measured_gap_at_64`, `measured_recency_gain`, `measured_P3_refuted`,
`measured_monotone`, `measured_in_band`).  No re-measurement of the model was performed here;
those theorems record the reported numbers and their relations, nothing more.
