# Computational evidence

All numbers below were produced by exact rational arithmetic (`ℚ`, no floating
point) in Lean 4 with Mathlib, by enumerating the full configuration space
`Fin n → Bool` and computing the Bernoulli weights
`w_p(η) = ∏_v (if η v then p else 1-p)` directly.

Test events on three sites (`n = 3`):

| name    | definition                                    | monotone? |
|---------|-----------------------------------------------|-----------|
| `maj3`  | at least two of the three sites open          | increasing |
| `all3`  | all three sites open                          | increasing |
| `dec1`  | site `0` closed                               | decreasing |
| `xor3`  | an odd number of sites open (parity)          | neither    |

## 1. Small-case calculations

`P(p) = bernProb p maj3`:

| p     | 1/4    | 1/3   | 1/2 |
|-------|--------|-------|-----|
| P(p)  | 5/32   | 7/27  | 1/2 |

(`P(p) = 3p² - 2p³`, so `P(1/2) = 1/2`, matching the self-dual symmetry of
majority.)

## 2. Poincaré / variance–influence inequality (`bernProb_poincare`)

Claim: `P(1-P) ≤ p(1-p) · Σ_v P(pivotal at v)`.

| event | p   | `P(1-P)`   | `p(1-p)·Σ influences` | holds |
|-------|-----|------------|-----------------------|-------|
| maj3  | 1/3 | 140/729    | 8/27 = 216/729        | ✓     |
| all3  | 1/4 | 63/4096    | 9/256 = 144/4096      | ✓     |

Both are strict, as expected for events depending on more than one site
(equality holds exactly for one-site events).

## 3. Sprinkling (`one_sub_bernProb_sprinkle_pow`, k = 2)

Claim: `1 - P(1-(1-p)²) ≤ (1-P(p))²`.

| event | p   | LHS       | RHS       | holds |
|-------|-----|-----------|-----------|-------|
| maj3  | 1/3 | 304/729   | 400/729   | ✓     |
| dec1  | 1/3 | 5/9       | 1/9       | ✗ (decreasing event) |
| xor3  | 1/3 | 364/729   | 196/729   | ✗ (non-monotone event) |

## 4. Thinning (`bernProb_and_le`)

Claim: `P(p·r) ≤ P(p)·P(r)`.

| event | p, r      | LHS    | RHS    | holds |
|-------|-----------|--------|--------|-------|
| maj3  | 1/2, 1/3  | 2/27   | 7/54   | ✓     |
| xor3  | 1/2, 1/3  | 19/54  | 13/54  | ✗ (non-monotone event) |

## 5. Odds-ratio monotonicity (`odds_ratio_mono`)

Claim: `P(p)(1-P(q))·q(1-p) ≤ P(q)(1-P(p))·p(1-q)` for `p ≤ q`.

| event | p, q      | LHS     | RHS     | holds |
|-------|-----------|---------|---------|-------|
| maj3  | 1/4, 1/2  | 15/512  | 27/512  | ✓     |
| dec1  | 1/4, 1/2  | 9/64    | 1/64    | ✗ (decreasing event) |

## 6. Bollobás–Thomason boosting (`bernProb_boost`, k = 2)

At `p = 2/5`, `P(maj3) = 44/125`; the boosting inequality predicts
`P(min(2p,1)) ≥ 1 - (1 - 44/125)² = 9064/15625 = 0.58…`, and the true value is
`P(4/5) = 112/125 = 0.896`, comfortably above the bound.

## 7. Counterexample hunt — where the hypotheses bite

The rows marked ✗ above are genuine counterexamples showing that
**monotonicity of the event is not removable** from any of the four main
inequalities: for the decreasing event `dec1` and for the parity event `xor3`
the sprinkling, thinning and odds-ratio conclusions all fail at explicit
rational densities. This is why every theorem in the new files carries the
`IsIncreasing A` hypothesis, and none of them is vacuous.

## 8. OEIS

No integer sequence is produced by this development: the objects are
polynomials in `p` with event-dependent coefficients (e.g. `3p² - 2p³` for
majority on three sites), so no OEIS lookup is applicable.

## 9. Reverse Poincaré inequality — exact rational data

All quantities below are exact rationals at `p = 1/3`, `q(p) = p(1-p) = 2/9`.
`I_v` is the influence `bernProb p (pivotalSet A v)`, `Var = P(1-P)`.

| event        | `P`     | `Var`      | `I_v` (all sites) | `p(1-p) I_v` | `p(1-p) I_v / Var` |
|--------------|---------|------------|-------------------|--------------|--------------------|
| dictator (3) | `1/3`   | `2/9`      | `1, 0, 0`         | `2/9`        | **`1` (equality)** |
| `maj3`       | `7/27`  | `140/729`  | `4/9`             | `8/81`       | `18/35 ≈ 0.514`    |
| `and3`       | `1/27`  | `26/729`   | `1/9`             | `2/81`       | `9/13 ≈ 0.692`     |
| `or3`        | `19/27` | `152/729`  | `4/9`             | `8/81`       | `9/19 ≈ 0.474`     |
| `or4`        | `65/81` | `1040/6561`| `8/27`            | `16/243`     | `27/65 ≈ 0.415`    |
| `maj5`       | `17/81` | `1088/6561`| `8/27`            | `16/243`     | `27/68 ≈ 0.397`    |

Every ratio is `≤ 1`, as `bernProb_pivotal_le_variance` asserts, and the
dictator row attains equality — the per-site inequality is sharp.

## 10. How lossy is the factor `|ι|` in the summed form?

Exhaustive enumeration of *all* monotone (= increasing) events on `n` sites
(20 events for `n = 3`, 168 for `n = 4`), maximising
`p(1-p) ∑_v I_v / (P(1-P))` over all nondegenerate ones:

| `n` | `p = 1/2` | `p = 1/3` | `p = 2/3` | proved bound |
|-----|-----------|-----------|-----------|--------------|
| 3   | `12/7 ≈ 1.714` | `27/13 ≈ 2.077` | `27/13 ≈ 2.077` | `3` |
| 4   | `32/15 ≈ 2.133`| `27/10 = 2.700` | `27/10 = 2.700` | `4` |

So `sum_pivotal_le_card_variance` holds with room to spare: the factor `|ι|`
obtained by summing `|ι|` sharp per-site inequalities is *not* itself sharp.
This is the computational observation that prompted the square-root law of §11,
now proved in `Catalog/Combinatorics/BernoulliInfluenceSqrt.lean`.

## 11. The square-root law (now a theorem)

Maximum of `∑_v I_v` at `p = 1/2` over all monotone events:

| `n` | `max ∑_v I_v` | `sqrt n` | conjecture holds? |
|-----|---------------|----------|-------------------|
| 3   | `3/2 = 1.5`   | `1.732`  | ✓                 |
| 4   | `3/2 = 1.5`   | `2.000`  | ✓                 |

No counterexample was found by exhaustive search over `n ≤ 4`; the maximiser is
majority-on-three (padded by a dummy site for `n = 4`), which is exactly the
extremal family predicted by the Fourier heuristic.  This evidence prompted the
formal proof: `sum_influence_le_sqrt_card` in
`Catalog/Combinatorics/BernoulliInfluenceSqrt.lean` establishes the bound for
every finite site set, via the density-`p` refinement
`p(1-p) ∑_v I_v² ≤ P(1-P)` (`sum_sq_influence_le`), which the `n = 3`, `p = 1/3`
row of §9 saturates for the dictator (`(2/9)·1 = 2/9 = P(1-P)`).

## Lab notes

* The Poincaré constant `p(1-p)` cannot be improved: at `n = 1` the inequality
  is an equality for every `p`, which is also the equality case of the
  odds-ratio theorem.
* The gap in the `maj3` row of §2 (`140/729` versus `216/729`) is a factor
  `≈ 1.54`; experimentally the ratio `p(1-p)ΣI_v / P(1-P)` grows with the number
  of sites, as the sharp-threshold heuristics predict.
* The reverse Poincaré inequality is *sharp per site* (dictator, §9) but its
  summed form loses a factor of roughly `sqrt(|ι|)` (§10) — exactly the loss
  that a Fourier/Parseval argument would recover.
* Exact rational evaluation was essential: several of the inequalities above are
  tight to within a few percent and would not be convincingly distinguished by
  floating-point evaluation.

## 12. The Poincaré defect and its Fourier expansion (now a theorem)

Exact rational evaluation of both sides of the defect identity

`p(1-p) Σ_v E[(D_v g)²]/4 − P(1−P)  =  (1/4) Σ_{S ≠ ∅} (|S| − 1) (p(1-p))^{|S|} ĝ(S)²`

for the `±1`-indicator `g` of a monotone event (`D_v g` its discrete derivative,
so `E[(D_v g)²]/4 = I_v`):

| event                | sites | `p`   | `P`    | `Σ_v I_v` | defect (left side) | Fourier sum (right side) |
|----------------------|-------|-------|--------|-----------|--------------------|--------------------------|
| dictator             | 3     | `1/3` | `1/3`  | `1`       | `0`                | `0`                      |
| AND of two sites     | 4     | `1/3` | `1/9`  | `2/3`     | `4/81`             | `4/81`                   |
| majority of three    | 3     | `1/3` | `7/27` | `4/3`     | `76/729`           | `76/729`                 |
| at least 3 of 4 open | 4     | `1/2` | `5/16` | `3/2`     | `41/256`           | `41/256`                 |

The two columns agree in every case, and the total Fourier weight
`Σ_S (p(1-p))^{|S|} ĝ(S)²` evaluated to exactly `1` in each run, as Plancherel
requires.  The dictator row is the equality case: all its Fourier weight sits at
level one, and the defect vanishes.  These evaluations are exact rational
computations run before the formal proofs; the statements they support are now
theorems, namely `efron_stein_defect_identity`, `poincare_defect_identity`,
`poincare_eq_iff_degree_le_one` and `fourier_weight_sum` in
`Catalog/Combinatorics/BernoulliPoincareDefect.lean` and
`Catalog/Combinatorics/BernoulliFourierParseval.lean`.
