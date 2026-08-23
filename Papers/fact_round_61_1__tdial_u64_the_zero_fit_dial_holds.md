# Computational Evidence — zero-fit dial at bitlen 64 (round-61 #1, exp 530)

All computations below were run inside Lean 4 (exact rational arithmetic, `#eval`),
so the numbers are reproducible from the same toolchain that checks the proofs.
Everything reported here is subsequently *proved* in
`Catalog/Novelty/ZeroFitDialU64.lean` and `Catalog/Novelty/ZeroFitDialNested.lean`;
this file only records the exploratory stage that guided the formalisation.

## 1. Brute-force test of the tie-attenuation law

For a tie profile `L = [m₁, …, m_g]` we built the explicit pair list
`(midrank of the block, raw rank)` for all `n = Σ mⱼ` observations and computed the
squared Pearson correlation exactly in `ℚ`, then compared it with the closed form
`1 − Σ(mⱼ³ − mⱼ)/(n³ − n)`.

| profile `L` | brute-force `ρ²` | closed form | equal? |
|---|---|---|---|
| `[2,1,1]` | 9/10 | 9/10 | ✔ |
| `[4,2,1,1]` | 73/84 | 73/84 | ✔ |
| `[3,3,3]` | 9/10 | 9/10 | ✔ |
| `[5,2,2,1]` | 13/15 | 13/15 | ✔ |
| `[1,1,1,1]` | 1 | 1 | ✔ |
| `[8,4,2,1,1]` | 117/136 | 117/136 | ✔ |
| `[2,2,2,2]` | 20/21 | 20/21 | ✔ |
| `[6,1,1,1,1]` | 26/33 | 26/33 | ✔ |

No counterexample was found; the law then became `spearmanSq_eq` (proved, 0 sorries).

## 2. The dyadic (trailing-zero) ceiling

Tie profile of `v₂` on `{0,…,2^b−1}`: block sizes `2^{b−1}, 2^{b−2}, …, 2, 1` plus the
singleton `{0}` (verified in `card_two_adic_block`).

| bitlen `b` | ceiling `ρ²` | ceiling `ρ` |
|---|---|---|
| 1 | 1.000000 | 1.000000 |
| 2 | 0.900000 | 0.948683 |
| 3 | 0.869048 | 0.932227 |
| 4 | 0.860294 | 0.927520 |
| 8 | 0.857156 | 0.925827 |
| 16 | 0.857143 | 0.925820 |
| 44 | 0.857143 | 0.925820 |
| 64 | 0.857143 | 0.925820 |

The closed form conjectured from this table, `ρ² = (6/7)(1 + 1/(2^b(2^b+1)))`, is proved
as `dyadic_spearmanSq`. The limit is `√(6/7) = 0.9258200…`.

**Key numerical observation.** Between `b = 44` and `b = 64` the ceiling moves by
`< 10⁻²⁶`, while the recorded dial moves from `0.78` to `0.648`
(`ρ²: 0.6084 → 0.419904`, a drop of `0.188…`). Tie granularity of the zero-count
statistic is therefore ruled out as the cause of the decline
(`tie_ceiling_insufficient`).

## 3. Binary-response hypothesis

Checking `spearmanSq [j, k] = 3jk/((j+k)² − 1)` exactly for
`(j,n) ∈ {(2,4), (3,10), (1,5), (17,100)}`: all four exact rational identities hold
(`true, true, true, true`). Asymptotically this is `ρ = √(3q(1−q))`, maximised at
`√3/2 = 0.8660…` for a balanced response.

Solving `3q(1−q) = 0.648² = 0.419904` gives `q = 0.16829…` (or its complement).
The nearest tractable rational instance, `j = 1683`, `k = 8317`, reproduces the recorded
`ρ²` to `2.1·10⁻⁵` (`u64_binary_calibration` proves the `10⁻⁴` bound).
Conversely any binary response with minority mass `≥ 25 %` gives `ρ² ≥ 9/16 = 0.5625`,
which the recorded value excludes (`u64_excludes_balanced_binary`).

## 4. OEIS

The dyadic tie masses `Σ(mⱼ³ − mⱼ)` for `b = 1,2,3,4,…` are `0, 6, 66, 570, 4650, …`,
i.e. `(8^b − 1)/7 + 1 − 2^b`. This is the sequence of partial sums of `8^i − 2^i`; no
dedicated OEIS entry was consulted or is claimed here — the closed form is proved
directly (`tieCorr_dyadic`), which supersedes any lookup.

## 5. Counterexample hunt

* Universal claim tested: `spearmanSq L ≤ 1` with equality iff every block has size `≤ 1`.
  All eight profiles in §1 conform; the general statement is proved
  (`spearmanSq_le_one`, `spearmanSq_eq_one_iff`).
* `binary_response_lt_one` initially failed for `j = k = 1`: there `spearmanSq [1,1] = 1`
  because the "binary response" is then tie-free. The hypothesis `3 ≤ j + k` was added,
  and the corner case is documented in the theorem statement.
* Truncation hypothesis (cycle 3): capping the zero-count at `c` gives the exact ceiling
  `(6/7)(8^b − 8^{b−c})/(8^b − 2^b)`. Evaluated at `b = 64`: `c = 1 → 0.750000…`,
  `c = 2 → 0.843750…`, `c = 3 → 0.855469…`, rising to `0.857143…`. The minimum over all caps
  is `3/4`, well above the recorded `0.419904`, so the truncation explanation is refuted
  (`no_truncation_explains_u64`).
* `pooled_is_seed_mean` initially claimed a `2·10⁻⁴` agreement between the pooled value and
  the seed mean; the exact discrepancy is `1/3000 ≈ 3.34·10⁻⁴`, so the bound was corrected
  to `5·10⁻⁴` rather than left as a false claim.
