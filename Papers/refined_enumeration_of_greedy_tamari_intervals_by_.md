# Computational Evidence

Topic: *refined enumeration of greedy 1-Tamari intervals by valley count of the lower
endpoint vs. bipartite planar maps by black-vertex count.*

All computations below were performed by direct enumeration of Dyck paths encoded as
lattice words (`true` = up step `U`, `false` = down step `D`), filtering for the Dyck
condition (balanced, every prefix has at least as many `U`s as `D`s). A **valley** is a
factor `DU`, a **peak** is a factor `UD`.

## 1. Small-case calculations

### Total Dyck paths by semilength (Catalan numbers)

| n | 0 | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|---|
| #Dyck paths | 1 | 1 | 2 | 5 | 14 | 42 |

These are the Catalan numbers `C_n` (OEIS **A000108**), matching Mathlib's
`DyckWord.card_dyckWord_semilength_eq_catalan`.

### Valley distribution of Dyck paths (lower-endpoint statistic)

Number of Dyck paths of semilength `n` with exactly `k` valleys:

| n \ k | 0 | 1 | 2 | 3 | 4 |
|-------|---|----|----|----|---|
| 1 | 1 | | | | |
| 2 | 1 | 1 | | | |
| 3 | 1 | 3 | 1 | | |
| 4 | 1 | 6 | 6 | 1 | |
| 5 | 1 | 10 | 20 | 10 | 1 |

These rows are the **Narayana numbers** `N(n, k+1) = (1/n) C(n,k+1) C(n,k)` (OEIS
**A001263**). Row sums are the Catalan numbers, which is exactly the statement proved in
`refined_valley_enumeration`.

### Peak / valley identity

For **every** Dyck path of semilength `≤ 5` we verified `#peaks = #valleys + 1`. The empty
path (`n = 0`) is the sole exception (both counts are `0`), consistent with the `p ≠ 0`
hypothesis of `peaks_eq_valleys_succ`.

More strongly, on all `Bool`-words of length `≤ 5` we verified the boundary invariant
`#descents − #ascents = w(head) − w(last)` with `w(true)=1`, `w(false)=0` (formalised as
`SignChange.descents_sub_ascents`).

### Unique minimal endpoint

For each `n`, exactly one Dyck path has `0` valleys, namely `Uⁿ Dⁿ` (formalised as
`valleys_eq_zero_iff`); exactly one has the maximal `n − 1` valleys, namely the staircase
`(UD)ⁿ`.

## 2. OEIS search results

- Total Dyck paths: **A000108** (Catalan) `1, 1, 2, 5, 14, 42, …`.
- Valley distribution: **A001263** (Narayana triangle) `1; 1,1; 1,3,1; 1,6,6,1; …`.
- Bipartite planar maps by number of edges (the *interval-count* side, totals over the
  black-vertex grading): the classical rooted-bipartite-planar-map sequence
  **A000257** `1, 1, 3, 12, 56, 288, …`. This is the sequence the greedy `1`-Tamari
  interval totals are conjectured to equal (n+1 edges ↔ semilength n). It differs from the
  ordinary Tamari interval sequence **A000260** `1, 1, 3, 13, 68, …`, which is a useful
  sanity check that "greedy" Tamari is a genuinely different order.

## 3. Counterexample hunt

- `#peaks = #valleys + 1` on nonempty Dyck paths: no counterexample up to `n = 5`
  (`= 63` distinct paths beyond `n=0`).
- Row-sum = Catalan for the valley distribution: holds for all `n ≤ 5`.
- The boundary invariant `descents − ascents = w(head) − w(last)`: no counterexample among
  all `2^0 + … + 2^5 = 63` `Bool`-words.

## 4. Scope note

The *interval* refinement on the greedy `1`-Tamari side (counting pairs `x ≤ y` graded by
the valleys of `x`) and the bipartite-planar-map black-vertex refinement require the greedy
Tamari covering relation and a planar-map model, respectively. These are recorded as the
central conjecture in `FUTURE_DIRECTIONS.md`. The present formal development pins down the
lower-endpoint valley statistic itself — the object the conjectured refinement distributes —
including the exact aggregate identity (row sum = Catalan) that any such refinement must
respect.
