# Computational evidence

Small-scale numerical exploration carried out **before** and **while** formalising
the peeling results in `Catalog/Geometry/Peel*.lean`.  Everything here is
exploratory; the authoritative statements are the Lean theorems, each of which
compiles with no `sorry` and uses only the standard axioms
(`propext`, `Classical.choice`, `Quot.sound`).

## 1. Small cases of the peeling bound

A peeling profile is a nonincreasing nonnegative sequence `size : ℕ → ℝ`;
`gap k = size k − size (k+1)`, `budget = size 0 − size N`, `rate = budget/N`.

| profile (`N = 4`, `budget = 1`) | gaps | min gap | rate | min gap ≤ rate? |
|---|---|---|---|---|
| `1, ¾, ½, ¼, 0` (equipartition) | `¼,¼,¼,¼` | `0.25` | `0.25` | equality |
| `1, 0, 0, 0, 0` (front-loaded)  | `1,0,0,0` | `0`    | `0.25` | strict |
| `1, 1, 1, 1, 0` (back-loaded)   | `0,0,0,1` | `0`    | `0.25` | strict |
| `1, .9, .5, .45, 0` (mixed)     | `.1,.4,.05,.45` | `0.05` | `0.25` | strict |

Observations that drove the formalisation:

* the bound is an *equality for every step* only in the first row — this is the
  observation that became the rigidity theorem `peel_extremal_tfae`;
* the minimum can be `0`, arbitrarily far below the rate, so no lower bound on
  the *minimum* gap is possible: the sharpness statement has to be about the
  extremal family, which is what `no_better_peel_constant` and
  `ball_peel_stopping_time_sharp` assert.

## 2. Layer energy (variance) check

`peel_energy_identity` claims `∑ gap² − budget²/N = ∑ (gap − rate)²`.

| profile (`N = 4`, `budget = 1`) | `∑ gap²` | `budget²/N` | excess | `∑ (gap − ¼)²` |
|---|---|---|---|---|
| `¼,¼,¼,¼` | `0.25` | `0.25` | `0` | `0` |
| `1,0,0,0` | `1` | `0.25` | `0.75` | `0.5625 + 3(0.0625) = 0.75` |
| `.1,.4,.05,.45` | `0.375` | `0.25` | `0.125` | `.0225+.0225+.04+.04 = 0.125` |
| `0,0,0,1` | `1` | `0.25` | `0.75` | `3(0.0625) + 0.5625 = 0.75` |

The excess is exactly the (unnormalised) variance of the layer distribution in
every sampled case, which is what the square-completion proof of
`peel_energy_identity` establishes in general, and it vanishes precisely for
the uniform row — the equality case `peel_energy_eq_iff_extremal`.

## 3. Equal-volume shell radii (dimension dependence)

Radii of the equal-volume peeling of the unit ball, `r_k = (1 − k/N)^{1/d}`:

| `d \ k` (`N = 4`) | `k=0` | `k=1` | `k=2` | `k=3` | `k=4` |
|---|---|---|---|---|---|
| `d = 1` | `1` | `0.75` | `0.5` | `0.25` | `0` |
| `d = 2` | `1` | `0.8660` | `0.7071` | `0.5` | `0` |
| `d = 3` | `1` | `0.9086` | `0.7937` | `0.6300` | `0` |
| `d = 10`| `1` | `0.9716` | `0.9330` | `0.8706` | `0` |

Only in dimension `1` are the radii in arithmetic progression; in every
dimension the **volumes** are.  This is why the rigidity statement had to be
phrased through the volume profile (`ball_peel_rigidity`).

## 4. Boundary concentration: bound versus truth

Outermost shell thickness `1 − (1 − 1/N)^{1/d}` versus the proved bound
`1/(d(N−1))` (`shell_thickness_le`), `R = 1`:

| `d` | `N` | thickness (float) | bound `1/(d(N−1))` | ratio |
|---|---|---|---|---|
| `10`  | `2` | `0.066967` | `0.1`   | `0.67` |
| `100` | `2` | `0.006908` | `0.01`  | `0.69` |
| `2`   | `4` | `0.133975` | `0.1667`| `0.80` |
| `1`   | `4` | `0.25`     | `0.3333`| `0.75` |

The bound has the correct `1/d` decay and is never violated in the sampled
range, which is what the factorisation proof
`1 − s^d = (1−s)(1 + s + ⋯ + s^{d−1}) ≥ (1−s)·d·s^{d−1}` predicts.
(Floats computed with Lean's `Float` arithmetic; the inequality itself is a
theorem, the table is only illustrative.)

## 5. Counterexample hunt

* *Is the pigeonhole bound saturated by any non-arithmetic profile?*  Enumerated
  all gap triples (`N = 3`) drawn from the grid `{0, ¼, ½, ¾, 1}` and summing to
  `1`: none has all three gaps `≤ 1/3` (the uniform triple `(⅓,⅓,⅓)` is not on
  the grid).  Consistent with rigidity: off the arithmetic profile some layer
  must exceed the average.
* *Can a `c < 1` improvement hold?*  For the equipartition profile every gap
  equals `rate`, so `gap ≤ c·rate` fails for all steps; formalised as
  `no_better_peel_constant`.
* *Does dilation peeling work for non-star-shaped bodies?*  For the annulus
  `1 ≤ ‖x‖ ≤ 2` in `ℝ²` the dilates are **not** nested (`0.5·K ⊄ K`), so the
  set-difference layers are not a partition.  This is why `bodyLayer_volume`
  carries the `StarShaped` hypothesis, while `bodyPeel_gap` (a statement about
  the volume profile only) does not.

## 6. OEIS

No integer sequence arises: all objects here are real-valued profiles
parameterised by `(d, N)`, so an OEIS search is not applicable.
