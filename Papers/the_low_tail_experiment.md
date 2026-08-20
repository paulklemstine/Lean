# Computational evidence — the low-tail experiment (NET-48, `16×` cell)

All numbers below were produced by `#eval` inside the project (computable definitions from
`Catalog/Physics/LowTail*.lean`), and each is matched by a proved theorem in the same files.
Nothing here is an unchecked scratch computation: the evaluations were re-derived as Lean
theorems before being reported.

Setting: `d = 4`, `ctx = 2048`, product point `P = d·ctx/32 = 256`; recorded knees
`{256, 224, 160}` (seeds 1, 2, 3), centre `224 = (7/8) P`, low tail `160 = (5/8) P`, tail bar
`τ = 192 = (3/4) P` (the midpoint of tail and centre).

## 1. Centre robustness versus sample size

`lowerMedianBreakdown n` (= the number of seeds an adversary must re-run to make the lower
median arbitrary), `n = 0 … 10`:

| n | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 |
|---|---|---|---|---|---|---|---|---|---|---|----|
| bd| 0 | 1 | 1 | 2 | **2** | **3** | 3 | 4 | 4 | 5 | 5 |

The staircase increases only at odd sample sizes: `bd(4) = bd(3) = 2`, `bd(5) = 3`.
Proved: `lowerMedianBreakdown_even_eq_pred`, `lowerMedianBreakdown_odd_gt`,
`breakdownNumber_eq`.

## 2. Breakdown number of every quota (no estimator escapes the parity)

`min k (n - k + 1)` for all quotas `k = 1 … n`:

| n | k=1 | k=2 | k=3 | k=4 | k=5 |
|---|-----|-----|-----|-----|-----|
| 3 | 1 | **2** | 1 | – | – |
| 4 | 1 | **2** | 2 | 1 | – |
| 5 | 1 | 2 | **3** | 2 | 1 |

Maximum at `n = 4` is `2`, the same as at `n = 3`.  Proved: `four_seed_no_rung_beats_three`.

## 3. Tail counts at the pre-registered outcomes

`countLE (knees4 x) 192` for `x ∈ {160, 192, 224, 256}`: `2, 2, 1, 1`.
`countLE (knees4 x) 160`: `2, 1, 1, 1`.

So the bar `192` splits the announced outcomes exactly as the plan claims, while the stricter
bar `160` separates the exact repeat from everything else.  Proved:
`lowtail_experiment_dichotomy`, `lowtail_experiment_informative`, `tail_three_way_reading`.

Five-seed ensembles: `countLE (knees5 192 160) 192 = 3`, `countLE (knees5 192 224) 192 = 2`.
Proved: `countLE_knees5`, `five_seed_tail`.

## 4. `ℓ¹` cost profiles (Fermat–Weber)

Four seeds, `x = 160` (sample `{256, 224, 160, 160}`):

| t | 140 | 160 | 180 | 192 | 200 | 224 | 240 | 256 | 280 |
|---|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| cost | 240 | **160** | **160** | **160** | **160** | **160** | 192 | 224 | 320 |

A flat segment `[160, 224]`: the low tail is an optimal centre too.  Proved:
`low_tail_is_also_a_centre`, `four_seed_centre_not_unique`.

Five seeds, `{256, 224, 160, 192, 224}`:

| t | 160 | 192 | 200 | 224 | 240 | 256 |
|---|-----|-----|-----|-----|-----|-----|
| cost | 256 | 160 | 152 | **128** | 176 | 224 |

A strict minimum at `224`.  Proved: `five_seed_centre`, `five_seed_centre_unique`,
`five_seed_low_tail_not_a_centre`.

## 5. Counterexample hunt

* *Could a fourth seed improve the centre's breakdown number?*  Searched all quotas `k` at
  `n = 4` (table 2): no.  Turned into the theorem `four_seed_no_rung_beats_three`.
* *Could some fourth seed both confirm the tail and calibrate the four-seed reading?*  The
  bias profile of `Probability.SeedFourSeedMedian` gives `bias 160 = 32`, `bias 192 = 16`,
  `bias 224 = 0`, `bias 256 = 16`, and tail stability requires `x ≤ 192`: no outcome does
  both.  Turned into `no_outcome_both_confirms_and_calibrates`.
* *Is the tail bit at least robust?*  No: the tail count sits exactly on the quota in both
  directions, so a single re-run flips the verdict (`tail_verdict_four_breakdown`,
  `tail_verdict_four_breakdown_false`).  This was the cycle-2 surprise; it is the reason for
  the design law of cycle 4.

## 6. Sequences

The breakdown staircase `0,1,1,2,2,3,3,4,4,5,5` is `⌊(n+1)/2⌋` (A004526 shifted); we did not
find, and do not claim, any deeper sequence-theoretic content.  No OEIS identification is
claimed for the cost profiles.
