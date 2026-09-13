# Computational evidence — fibres of one-variable tropical polynomials

All numbers below were produced by evaluating the Lean definition
`TropicalDependentFibers.fiber` (which is computable over `ℚ`) inside the project, and
every phenomenon they exhibit is subsequently proved as a theorem in
`Catalog/Tropical/DependentFibers/`.  The lab-notes file
`Catalog/Tropical/DependentFibers/LabNotes.lean` records the individual data points as
kernel-checked theorems.

Notation: for a coefficient vector `c = (c₀, …, c_n)` the fibre at `x` is
`fiber n c x = {i ≤ n : c i + i·x = min_j (c j + j·x)}`.

## 1. The generic (ramp) polynomial `c i = i(i−1)/2`, degree 4

| `x`            | 0 | −1 | −2 | −3 | −4 | −5 | −6 | −7 | −8 |
|----------------|---|----|----|----|----|----|----|----|----|
| `|fibre|`      | 2 | 2  | 2  | 2  | 1  | 1  | 1  | 1  | 1  |

At half-integers `x = 0, −1/2, −1, −3/2, …` the cardinalities alternate
`2, 1, 2, 1, 2, 1, 2, 1`: corners sit exactly at the integers `0, −1, −2, −3`, and every
other point has a singleton fibre.  Four corners, each of multiplicity two, total
multiplicity excess `4 = n`.

*Proved as*: `fiber_rampCoeff`, `cornerSet_rampCoeff_ncard`, `multiplicity_sum_rampCoeff`.

## 2. Step polynomials `stepCoeff k` (first `k` coefficients `0`, rest `1`), degree 4

| `k`                 | 1 | 2 | 3 | 4 | 5 |
|---------------------|---|---|---|---|---|
| `|fibre at x = 0|`  | 1 | 2 | 3 | 4 | 5 |
| `|fibre at x = 1|`  | 1 | 1 | 1 | 1 | 1 |

Every cardinality in `1 … n+1` occurs, always together with a singleton fibre.

*Proved as*: `fiber_stepCoeff_zero`, `fiber_stepCoeff_one`,
`dependent_solutions_at_every_cardinality`.

## 3. Two-block Newton polygons, degree 6

Increments `1` on the first `m` steps and `2` afterwards; corners at `x = −1, −2`:

| `m`                          | 0 | 1 | 2 | 3 | 4 | 5 | 6 |
|------------------------------|---|---|---|---|---|---|---|
| `|fibre(−1)|`                | 1 | 2 | 3 | 4 | 5 | 6 | 7 |
| `|fibre(−2)|`                | 7 | 6 | 5 | 4 | 3 | 2 | 1 |

Every two-part composition of `6` is realised, and the excesses always add to `6`.

*Proved as*: `two_block_profile`, `two_block_multiplicity_sum`.

## 4. Counterexample hunt — is the degree bound always an equality?

No.  Scanning the non-convex vector `c = (0, 5, 1, 7)` (degree `3`) on a grid of
quarter-integers from `−7.5` to `2.5` finds exactly two corners:

| `x`     | fibre    | `|fibre|` |
|---------|----------|-----------|
| `−1/2`  | `{0, 2}` | 2         |
| `−6`    | `{2, 3}` | 2         |

Total multiplicity excess `1 + 1 = 2 < 3 = n`.  The monomial `i = 1` is *invisible*: the
point `(1, 5)` lies strictly above the lower hull, and the hull edge from `(0,0)` to
`(2,1)` has lattice length `2` but contributes only `1` because its interior lattice
point is not a monomial of the minimum.  So `multiplicity_sum_le` is genuinely an
inequality; equality is a convexity phenomenon.

*Proved as*: `labnote_ex_fiber_neg_six`, `labnote_ex_fiber_neg_half`,
`labnote_ex_strict_degree_bound`; and the positive counterpart
`multiplicity_sum_convex_eq` (equality for every convex coefficient vector).

## 5. Repeated slopes

For the convex vector `c = (0, 0, 0, 3)` (increments `0, 0, 3`) the scan finds corners at
`x = 0` with `|fibre| = 3` and at `x = −3` with `|fibre| = 2`; the excesses `2 + 1 = 3 = n`.
This is the data behind "multiplicity = number of increments of that slope, plus one"
(`fiber_card_convex`).

## 6. Sequences and OEIS

What is *proved* here is that the multiplicity excesses of a convex degree-`n`
polynomial sum to `n` (`multiplicity_sum_convex_eq`) and that **every** composition of
`n`, with any number of parts, is realised as the multiplicity profile of the staircase
polynomial of that composition (`composition_profile`, `composition_spectrum` in
`Catalog/Tropical/DependentFibers/Compositions.lean`); the two-part case
(`two_block_profile`) is the special case `r = 2`.  Since the realisable profiles are
therefore exactly the compositions of `n`, their number in degree `n` is the classical
`2^(n−1)`.  A kernel-checked instance is `labnote_composition_two_one_three`: the
composition `6 = 2 + 1 + 3` gives fibres of cardinalities `3, 2, 4` at `x = 0, −1, −2`.
No new integer sequence arose, so no OEIS identifier is claimed.
