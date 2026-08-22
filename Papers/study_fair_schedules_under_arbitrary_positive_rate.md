# Computational Evidence — fair schedules from prefix sums

All numbers below were produced by `#eval` inside the Lean project itself, using the very
definitions that the theorems are stated about (`FairSchedule.owner`, `FairSchedule.cnt`,
`FairSchedule.bres`, `FairSchedule.nestCnt`, `FairSchedule.STree.sched`,
`FairSchedule.STree.bal`).  They are *exploratory* data: every claim that survives is proved
separately in the `.lean` files, and the discrepancy bounds quoted here are exactly the ones
the theorems assert.  Notation: `R = total r k` is the period, and the (un-normalised)
discrepancy of client `i` at time `t` is `D_i(t) = R · count_i(t) − r_i · t`.

## 1. Prefix-sum batches and the block schedule

Profile `r = (3,1,3)`, `k = 3`, so `R = 7`, prefix sums `pre = (0,3,4,7)`, batches
`{0,1,2}, {3}, {4,5,6}` — disjoint, of sizes exactly `3,1,3`, covering `{0,…,6}`
(`batch_card`, `batch_disjoint`, `batch_biUnion`).

First 21 slots of `owner r 3`:

```
0 0 0 1 2 2 2 | 0 0 0 1 2 2 2 | 0 0 0 1 2 2 2
```

Extremal discrepancies over `t ≤ 21`:

| client i | max D_i | min D_i | predicted max `r_i (R − pre_{i+1})` | predicted min `−r_i · pre_i` |
|---|---|---|---|---|
| 0 | 12 | 0   | 12 | 0   |
| 1 | 3  | −3  | 3  | −3  |
| 2 | 0  | −12 | 0  | −12 |

Both sides are attained exactly — this is the sharpness content of `cnt_disc_lower_sharp` /
`cnt_disc_upper_sharp`, and it is what makes the block schedule's normalised discrepancy grow
like `Θ(R)`.

## 2. The nested-floor obstruction

`nestCnt r 3 1 t` for `r = (3,1,3)` (the "multi-client Bresenham" candidate obtained by
differencing `⌊t · pre_i / R⌋`), `t = 0,…,5`:

```
0 0 1 0 1 0
```

The candidate count of the middle client **drops** from `1` at `t = 2` to `0` at `t = 3`.
Service counters are monotone, so no schedule realises these counts.  This single data point
is what the theorem `nested_floor_not_schedulable` turns into a proof; for `k = 2` no such
drop can occur, and indeed `nestCnt_eq_bres` proves the two-client nested-floor counter *is*
the Bresenham counter.

## 3. Two-client Bresenham (Beatty) schedule

`a = 3`, `R = 7`, first 14 slots of `bres 3 7` (`0` = client 0 served):

```
1 1 0 1 0 1 0 | 1 1 0 1 0 1 0
```

Period `7` (`bres_periodic`).  `D_0(t)` for `t = 0,…,14`:

```
0 −3 −6 −2 −5 −1 −4 0 −3 −6 −2 −5 −1 −4 0
```

All values lie in `(−7, 7)`, i.e. normalised discrepancy `< 1`, as `bres_isFair` asserts.
The service positions of client `0` are `2,4,6,9,11,13,…`, gaps `2,2,3,2,2,3` — the classical
two-gap (Beatty/Sturmian) structure; the upper gap `3 = ⌈7/3⌉` is exactly the window proved
in `bres_window_zero`.  (No OEIS lookup was performed — the environment is offline — but the
service indicator is the Sturmian word of slope `a/R`.)

## 4. Block schedule vs. Bresenham on balanced profiles

Profile `(c,c)`, `R = 2c`, worst `|D_1(t)|` over two periods:

| c | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
|---|---|---|---|---|---|---|---|
| block schedule | 1 | 4 | 9 | 16 | 25 | 36 | 49 |
| Bresenham      | 1 | 2 | 3 | 4  | 5  | 6  | 7  |

The block schedule attains `c² = r_1 · pre_1` (normalised `c/2 → ∞`), Bresenham attains `c`
(normalised `1/2 < 1`).  This is the separation proved in `bres_fair_block_unfair`.

## 5. Tree schedules for three and four clients

Rates `w = (1,2,4)`, `k = 3`, `R = 7`.  First 21 slots of `sched (bal w 0 3)`:

```
2 2 1 2 2 1 0 | 2 2 1 2 2 1 0 | 2 2 1 2 2 1 0
```

Worst `|D_i|` over two periods: `(6, 4, 8)`, all below the proved bound
`R · ⌈log₂ 3⌉ = 14` (`three_client_log_fair`).  The exact-rate block schedule on the same
profile reaches `(6, 8, 12)`.

Extreme profile `w = (1,1,1,100)`, `k = 4`, `R = 103`, over one period:

| client | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| balanced tree, worst `\|D_i\|` | 102 | 51 | 101 | 200 |
| block schedule, worst `\|D_i\|` | 102 | 101 | 100 | 300 |

Normalised, the tree stays at `200/103 ≈ 1.94 ≤ 2 = log₂ 4` — the bound of
`perfect_isFair` — while the block schedule reaches `300/103 ≈ 2.91`, i.e. it violates the
`log₂ k` bound.  Rate-independence of the tree bound is the phenomenon that the general
theorem `tree_disc` explains.

## 6. The greedy largest-lag schedule

Serving, at each slot, the client maximising `r_i (t+1) − R · count_i(t)`:

* over all `125` three-client profiles with rates in `{1,…,5}` and all `256` four-client
  profiles with rates in `{1,…,4}`, the worst `|D_i|` was **always `< R`**, i.e. normalised
  discrepancy `< 1`;
* over `480` pseudo-random profiles with `k = 2,…,9` and rates in `{1,…,17}`, again no
  profile reached normalised discrepancy `1`; the largest value observed was `0.831`.

The one-sided half of this phenomenon is now a theorem: `greedy_no_overshoot` proves the lead
`R · count_i(t) − r_i t ≤ R − 1` for *every* profile and time, and `greedy_isFair` turns it
into the two-sided bound `(k−1)(R−1)`.  The two-sided unit bound suggested by the data
(Tijdeman's conjecture-shaped statement) is Conjecture 1 of `FUTURE_DIRECTIONS.md`.

## 7. Counterexample hunt

* Drops of `nestCnt` (which certify non-schedulability): of the `64` three-client profiles
  with rates in `{1,…,4}`, **18** exhibit a drop within the first 40 slots — e.g. `(2,1,2)`,
  `(2,1,3)`, `(2,1,4)`, `(2,3,2)`, `(3,1,2)`, and `(3,1,3)`, the profile used in
  `nested_floor_not_schedulable`.  Of the `64` two-client profiles with rates in `{1,…,8}`,
  **none** drops — consistent with `nestCnt_eq_bres`.
* Balanced-tree bound: over all `125` three-client profiles with rates in `{1,…,5}`, the tree
  schedule never exceeded the proved bound `R·⌈log₂ 3⌉ = 2R` (0 violations), while the
  exact-rate block schedule exceeded that same bound for **66** of the `125` profiles.
* The tree bound is not a unit bound: `57` of those `125` profiles have tree discrepancy
  `> R` (e.g. `(1,1,3)`: worst `|D| = 6 > 5 = R`).  So `⌈log₂ k⌉` cannot be replaced by `1`
  for this construction — a genuinely different schedule (greedy) is needed, cf. §6.
* The uniform profile shows the tree bound is not optimal in general: round robin achieves
  normalised discrepancy `< 1` for every `k` (`roundRobin_optimal`).
