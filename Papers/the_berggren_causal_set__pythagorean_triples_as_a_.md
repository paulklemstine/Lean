# Computational Evidence — The Berggren Causal Set

All numbers below were produced by `#eval` inside the Lean project (kernel/compiler
evaluation of the same definitions that the theorems are stated about), not by an external
script.  Every qualitative pattern reported here is subsequently *proved* in
`Catalog/Novelty/BerggrenCausalSet*.lean`; the tables are what motivated the statements.

## 1. Small cases of the tree

Root `(3,4,5)`; the three Berggren children of the root:

```
A ↦ (5, 12, 13)    B ↦ (21, 20, 29)    C ↦ (15, 8, 17)
```

Depth 2 (all nine grandchildren, in the order `AA AB AC BA BB BC CA CB CC`):

```
(7,24,25) (55,48,73) (45,28,53) (39,80,89) (119,120,169) (77,36,85) (33,56,65)
(65,72,97) (35,12,37)
```

Counts of *distinct* events up to depth 4: `121 = 1 + 3 + 9 + 27 + 81`, i.e. no collisions
— the numeric shadow of the tree property (`run_word_unique`, `level_card`).
Level sizes `1, 3, 9, 27, 81` (evaluated via `levelFinset`).

## 2. The Minkowski interval of tree edges (the decisive experiment)

`mink t u = (a'−a)² + (b'−b)² − (c'−c)²`, the ambient interval of signature `(2,1)`.
Negative would mean *timelike* (causally related in spacetime), zero null, positive
spacelike.

| base event | A-edge | B-edge | C-edge |
|---|---|---|---|
| `(3,4,5)`   | 4   | 4   | 16  |
| `(5,12,13)` | 4   | 196 | 256 |

Every value is **positive**.  Over all `121·120 = 14520` ordered pairs of distinct events
of depth `≤ 3` (1560 ordered pairs at depth `≤ 3` were tabulated) the minimum of `mink`
is `4 > 0`: no pair of distinct events is ever null or timelike separated.
This is the experiment that falsified the "tree edge = causal relation of spacetime"
half of the hypothesis, and it is proved as `distinct_events_spacelike` and
`mink_edges_pos` (with the exact spectrum `4(c−b)², 4(a−b)², 4(c−a)²`).

Sanity checks over the same 121 events: all satisfy `a² + b² − c² = 0` (they live on the
null cone) and all satisfy `gcd(a,b) = 1` (primitivity is preserved).

## 3. The Pell spine (pure middle moves)

```
k :      0        1          2            3              4                5
event: (3,4,5) (21,20,29) (119,120,169) (697,696,985) (4059,4060,5741) (23661,23660,33461)
```

* Legs stay **twins**: `|a − b| = 1` for every `k` (proved: `spine_diff_sq`).
* Edge lengths `mink (spine k) (spine (k+1))` are `4, 4, 4, 4, 4, 4` — constant
  (proved: `spine_edge_length`).
* Hypotenuses `5, 29, 169, 985, 5741, 33461, 195025, 1136689` satisfy
  `x_{k+2} = 6 x_{k+1} − x_k` (a Pell-type recurrence; proved as `spine_hyp_rec`, and
  identified with the catalog sequence `bHyp` in `spine_hyp_eq_bHyp`).  No OEIS lookup was
  performed (this environment has no network access), so no OEIS identifier is claimed.
* Celestial directions `a/c` (floating point):
  `0.600000, 0.724138, 0.704142, 0.707614, 0.707020, 0.707122, 0.707104, 0.707107`
  — visibly converging to `√2/2 = 0.7071067…` (proved: `spine_dir_tendsto`).

## 4. Interval volumes

For the interval `[root, spine k]` the enumeration `{run (take j) : j ≤ k}` gives
cardinalities `1, 2, 3, 4, 5, 6` for `k = 0,…,5`: exactly `k+1`, linear in the proper
time, never quadratic or cubic.  Proved as `causalInterval_ncard` /
`interval_growth_linear`, and turned into the impossibility statement
`not_myrheim_meyer_dim_two`.

## 5. Counterexample hunt

Two universal claims were stress-tested before being formalised:

1. *"Some pair of tree events is causally related in the Minkowski sense"* — searched over
   all ordered pairs at depth `≤ 3`: **no instance** (minimum interval `4`).  The claim is
   false, and its negation is now a theorem.
2. *"Two different words can reach the same event"* — searched to depth 4: **no instance**
   (121 words, 121 distinct events).  The claim is false, and its negation is now the
   theorem `run_word_unique`.
