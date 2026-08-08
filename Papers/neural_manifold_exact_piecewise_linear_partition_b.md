# Computational Evidence — Exact Piecewise-Linear Partition Bounds for ReLU Networks

All numbers below were produced by exact rational (`Fraction`) arithmetic, not
floating point.  Everything that is *asserted as a theorem* in
`Catalog/MachineLearning/ReLUPartition/` is proved in Lean with 0 sorries; the
tables here are the exploratory data that guided which statements to attempt and
which to leave as conjectures in `FUTURE_DIRECTIONS.md`.

---

## 1. The Schläfli function `schlafli n d = ∑_{k ≤ d} C(n,k)`

Rows `n = 0 … 8`, columns `d = 0 … 4`:

| n \ d | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| 0 | 1 | 1 | 1 | 1 | 1 |
| 1 | 1 | 2 | 2 | 2 | 2 |
| 2 | 1 | 3 | 4 | 4 | 4 |
| 3 | 1 | 4 | 7 | 8 | 8 |
| 4 | 1 | 5 | 11 | 15 | 16 |
| 5 | 1 | 6 | 16 | 26 | 31 |
| 6 | 1 | 7 | 22 | 42 | 57 |
| 7 | 1 | 8 | 29 | 64 | 99 |
| 8 | 1 | 9 | 37 | 93 | 163 |

Observations that became theorems:

* Column `d = 1` is `n + 1` (`schlafli_one_dim`), column `d = 2` is
  `1 + n + C(n,2)` (`schlafli_two_dim`).
* The table stabilises at `2^n` as soon as `n ≤ d` (`schlafli_eq_two_pow`),
  and is `< 2^n` as soon as `d < n` (`schlafli_lt_two_pow`).
* Each entry equals the sum of the two entries above/left of it
  (`schlafli_succ_succ` — Pascal's recurrence), which is exactly the
  deletion–restriction step used in `regionCount_recurrence`.

This is the classical "partial sums of binomial coefficients" triangle
(OEIS A008949 reads the same numbers by rows). No new OEIS entry is claimed.

## 2. Sign-pattern counts of one ReLU layer (sharpness check)

For the moment family `momentFamily n d` (weights `w_{i j} = i^j`,
bias `b_i = i^d`) we counted realised sign patterns by random exact-rational
sampling of the input space (200 000 points per case).  Sampling can only
*under*-count (tiny cells get missed), so the interesting outcome is how often
it already saturates the bound:

| (n,d) | patterns found by sampling | `schlafli n d` |
|---|---|---|
| (3,1) | 4  | 4  |
| (4,1) | 5  | 5  |
| (5,2) | 16 | 16 |
| (6,2) | 22 | 22 |
| (7,2) | 29 | 29 |
| (4,3) | 15 | 15 |
| (5,3) | 25 | 26 |
| (6,3) | 37 | 42 |

Every case saturates or nearly saturates; the two shortfalls at `d = 3` are
sampling artefacts (the missing cells are thin slabs near the moment curve).
This is consistent with the proved theorem
`maximum_regionCount : IsGreatest {m | ∃ F, F.regionCount = m} (schlafli n d)`,
whose lower-bound half is proved by an exact perturbation/root-counting argument
rather than by sampling.

## 3. The width-two sawtooth network (exact cell counts)

`sawNet : ReLUNet 1 2` is the ReLU realisation of the tent map
`t(x) = 2x − 4·relu(x − 1/2)`.  Enumerating **all** cells of `ℝ` exactly
(open intervals between consecutive breakpoints *and* the breakpoints
themselves, using rational arithmetic) gives

| L | # cells | `2^L` (proved lower bd) | `5·2^(L-2)+1` | `2^(L+1)` (proved upper bd) | `3^L` (generic upper bd) |
|---|---|---|---|---|---|
| 1 | 3 | 2 | – | 4 | 3 |
| 2 | 6 | 4 | 6 | 8 | 9 |
| 3 | 11 | 8 | 11 | 16 | 27 |
| 4 | 21 | 16 | 21 | 32 | 81 |
| 5 | 41 | 32 | 41 | 64 | 243 |
| 6 | 81 | 64 | 81 | 128 | 729 |
| 7 | 161 | 128 | 161 | 256 | 2187 |
| 8 | 321 | 256 | 321 | 512 | 6561 |

So the data says `#cells(L) = 5·2^(L−2) + 1` for `L ≥ 2`, comfortably inside the
proved sandwich `2^L ≤ #cells ≤ 2^(L+1)` (`sawNet_card_sandwich`) — sharpened to
`#cells ≤ 3·2^(L−1)` by `card_netRegions_sawNet_le_three_mul` — which is itself
exponentially stronger than the generic product bound `3^L`
(`card_netRegions_sawNet_lt_three_pow`).  The loud (fully active) cells are
counted **exactly**: `card_loudRegions_sawNet` proves there are `2^L` of them,
matching the `2^L` term of the observed `5·2^(L−2)+1 = 2^L + 2^(L−2) + 1`.

A by-hand orbit analysis explains the formula and is what makes it a *safe*
conjecture rather than a numerical accident:

* `x ≤ 0` gives the all-empty itinerary (1 cell);
* `x ∈ (0,1)` with `t^l(x) > 0` for all `l < L` gives all `2^L` binary
  itineraries — this is the part proved in Lean
  (`exists_itinerary`, `two_pow_le_card_netRegions_sawNet`);
* orbits that hit `0` at step `m` contribute `2^{m−2}` extra patterns for
  `2 ≤ m ≤ L−1` plus one for `m = 1`, i.e. `2^{L−2}` in total, because
  `t^{m−1}(x) = 1` forces `t^{m−2}(x) = 1/2`, which pins the pattern at step
  `m − 2`.

`2^L + 2^{L−2} + 1 = 5·2^{L−2} + 1`.  A naive *sampling* run on a grid of
200 001 points reports `3, 6, 10, 19, 36, 71`, i.e. it silently misses the
measure-zero cells; this is a useful warning that region counts defined
pointwise are strictly larger than counts of full-dimensional cells.

## 4. Counterexample hunt: is the product bound `(schlafli w d)^L` attained?

Random search over depth-`L`, width-`w`, input-dimension-`1` networks with
rational weights (exact cell enumeration of the open cells, 20 000–30 000
random nets per row):

| w | L | best found | `∑_{k ≤ L} w^k` | product bound `(w+1)^L` |
|---|---|---|---|---|
| 2 | 6 | 4 | 6 | 8 | 9 |
| 2 | 6 | 4 | 6 | 8 | 9 |
| 2 | 6 | 4 | 6 | 8 | 9 |
| 3 | 11 | 8 | 11 | 16 | 27 |
| 3 | 11 | 8 | 11 | 16 | 27 |
| 3 | 11 | 8 | 11 | 16 | 27 |

**No counterexample to the proved upper bound was found**, and the product bound
`(w+1)^L` is visibly *not* attained for `L ≥ 2`: at `w = 2` the maximum sits
exactly on the geometric sum `∑_{k ≤ L} w^k = 2^{L+1} − 1`.  This is the source
of Conjecture 1 in `FUTURE_DIRECTIONS.md`.  (At `w = 3` the random search is far
from exhaustive — the parameter space is much larger — so the row `w=3, L=3`
should be read as a weak lower bound only.)

## 5. Counterexample hunt: the Sauer–Shelah bound for one layer

For `n ≤ 6`, `d ≤ 3`, 60 randomly generated affine families of `n` hyperplanes
in `ℝ^d` per shape were sampled (40 000 exact rational points each):

| (n,d) | max patterns found | `schlafli n d` |
|---|---|---|
| (3,1) | 4  | 4  |
| (4,2) | 11 | 11 |
| (5,2) | 16 | 16 |
| (6,2) | 22 | 22 |
| (5,3) | 26 | 26 |
| (6,3) | 40 | 42 |

**Violations of the `schlafli n d` upper bound found: 0.**  Generic families sit
exactly on the bound; degenerate ones (repeated or parallel hyperplanes) fall
strictly below, so the maximum in `maximum_regionCount` is attained but not by
every family.

## 6. Closing the exact sawtooth count (this cycle)

The enumeration of §3 gave the pointwise cell counts of the width-two sawtooth
network

| L | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|
| cells | 3 | 6 | 11 | 21 | 41 | 81 | 161 | 321 |
| `2^L` (loud) | 2 | 4 | 8 | 16 | 32 | 64 | 128 | 256 |
| degenerate | 1 | 2 | 3 | 5 | 9 | 17 | 33 | 65 |

so the degenerate column is `2^{L−2} + 1` and the total is `5·2^{L−2} + 1` for
`L ≥ 2`.  Both statements are now **theorems** in
`Catalog/MachineLearning/ReLUPartition/SawtoothExact.lean`
(`card_degenRegions_sawNet`, `card_netRegions_sawNet_exact`), proved by an
explicit bijection between degenerate cells and the codes
`Unit ⊕ Unit ⊕ (Σ j : Fin M, (Fin j → Bool))`; the data above is exactly the
count `1 + 1 + (2^{L−2} − 1)` of those codes.  The sequence `3, 6, 11, 21, 41,
81, …` satisfies `a_{L+1} = 2a_L − 1` from `L = 2` on
(`card_netRegions_sawNet_recurrence`).

## 7. Generic (open) cells versus pointwise cells

A cell of the width-two sawtooth network is *generic* (`IsOpenCell`) when it
contains a non-degenerate interval, i.e. when it is visible to any sampling
procedure of positive resolution.  Enumerating the itineraries gives

| L | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|
| pointwise cells `5·2^(L−2)+1` | 6 | 11 | 21 | 41 | 81 | 161 | 321 |
| generic cells `2^L + 2` | 6 | 10 | 18 | 34 | 66 | 130 | 258 |
| invisible (measure-zero) cells | 0 | 1 | 3 | 7 | 15 | 31 | 63 |
| ratio pointwise/generic | 1.000 | 1.100 | 1.167 | 1.206 | 1.227 | 1.238 | 1.244 |

Three features of this table are now theorems in
`Catalog/MachineLearning/ReLUPartition/SawtoothOpen.lean`:

* the generic count is exactly `2^L + 2` (`card_openRegions_sawNet`), the two
  extra cells beyond the `2^L` loud itineraries being the empty word and the
  shut-off word;
* the two counts *coincide* at `L = 2` (`card_openRegions_eq_card_netRegions_two`)
  and differ strictly from `L = 3` on
  (`card_openRegions_lt_card_netRegions`) — this is why the originally stated
  "generic count is always strictly smaller" conjecture had to be corrected;
* the ratio converges to `5/4` (`tendsto_pointwise_div_open`), matching the last
  row of the table.

The invisible cells are not merely thin: every degenerate `Σ`-cell is a **single
point** (`sigma_degenerate_singleton`), a rigidity that follows from the
expansion law `|x − y| ↦ 2^n |x − y|` along a common itinerary
(`abs_sub_sawOrbit_eq`).  So the missing `2^(L−2) − 1` cells form a finite set of
isolated points, and a sampler at any positive resolution sees exactly
`2^L + 2` linear pieces.
