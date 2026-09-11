# Computational evidence — rung budget for plateau identification

All numbers below were computed in exact rational arithmetic (`ℚ`) inside Lean, and every
qualitative claim they support is separately *proved* in
`Catalog/Combinatorics/PlateauRungBudget.lean` and
`Catalog/Combinatorics/PlateauTwoSidedBudget.lean`.
Nothing in this note is used as a substitute for a proof.

## 1. The one-sided admissible-plateau interval

For an exactly geometric fade with initial step `d₀` and deceleration ratio `r`, the exact
admissible interval after `m` further measured rungs has length `d₀·r^{m+1}/(1−r)`
(proved: `plateauLength_geoFade`).  At the U108 reading `d₀ = 0.0259`, `r = 1/2`:

| m (further rungs) | interval length (exact) | ≈ decimal | ≤ 0.0445 (CI half-width)? | ≤ 0.001? |
|---|---|---|---|---|
| 0 | 259/10000 | 0.02590 | yes | no |
| 1 | 259/20000 | 0.01295 | yes | no |
| 2 | 259/40000 | 0.006475 | yes | no |
| 3 | 259/80000 | 0.0032375 | yes | no |
| 4 | 259/160000 | 0.00161875 | yes | no |
| 5 | 259/320000 | 0.000809375 | yes | **yes** |
| 6 | 259/640000 | 0.0004046875 | yes | yes |

Two facts jump out.

* The mission's target `0.0445` is **already met at m = 0**.  The claim "three further rungs
  are needed at `r = 1/2`, `d₀ = 0.0259`" is false; even the mission's own formula returns a
  negative number, `log(0.0445·(1−r)/(d₀ r))/log r = log(1.7181)/log(0.5) ≈ −0.781`, whose
  ceiling is `0`.  Proved as `u108_rung_budget_zero` / `u108_three_rungs_not_needed`.
* The first genuinely informative target is an order of magnitude finer: `ε = 0.001` costs
  exactly five further rungs (`m = 4` fails, `m = 5` succeeds).  Proved as
  `u108_rung_budget_for_milli`.

## 2. The budget constant

`ε(1−r)/d₀ = 0.0445·(1/2)/0.0259 = 445/518 ≈ 0.859` (exact value confirmed in `ℚ`).  Since
`1/2 < 445/518 < 1`, the ratio `log(445/518)/log(1/2)` lies in `(0, 1]`, so its ceiling is
`1` and `rungBudget = 1 − 1 = 0`.  This is exactly the route taken by the Lean proof — no
floating-point evaluation of a logarithm is needed anywhere.

## 3. Contraction factor: exact only on the extremal ladder

The table's lengths halve at every step, matching the conjecture "each additional rung
contracts the interval by exactly `r`".  But that is a property of the *worst-case* ladder.
Counterexample hunt (one hit, immediately): take the prefix `p₀ = d₀`, `p₁ = p₂ = 0`.  It is
admissible for every `r ∈ (0,1)`, the interval after one rung has length `r·d₀/(1−r) > 0`,
and after the second rung the length is `r·(p₁ − p₂)/(1−r) = 0` — a contraction by the factor
`0`, not `r`.  Formalised as `contraction_not_exact_in_general`; the surviving universal
statement is the inequality `plateau_contraction_le`.

## 4. Two-sided information

If the experiment also certifies a *lower* ratio `rmin`, the interval becomes
`dₘ(rmax − rmin)/((1−rmax)(1−rmin))`.  With `rmin = 2/5`, `rmax = 1/2`, `d₀ = 0.0259`, on the
`rmax`-ladder:

| m | two-sided length (exact) | ≈ decimal |
|---|---|---|
| 0 | 259/30000 | 0.008633 |
| 1 | 259/60000 | 0.004317 |
| 2 | 259/120000 | 0.002158 |
| 3 | 259/240000 | 0.001079 |

so the U108 window is already three times inside the CI half-width before any new rung is
measured (`u108_two_sided_window`), and even `ε = 0.001` is reached after four rungs instead
of five.

## 5. Corner cases probed

* `r = 0`: the interval collapses to a point — the plateau is the last measured value.
  Consistent with the general formula.
* `r = 1` (no deceleration certificate): the formula `r·dₘ/(1−r)` diverges.  The correct
  statement is that the admissible set is the whole half-line `(−∞, p(m+1)]`, proved as
  `plateauSet_ratio_one_eq_Iic`; no ladder of any length identifies the plateau.
* `dₘ = 0`: interval of length `0`; the two-sided theorem then forces `L = p(m+1)`.

## 6. Noise floor at U108 (added in cycle 3)

The rung values themselves carry the CI half-width `η = 0.0445`.  The rigid-shift construction
places `p(m+1) ± η` in the admissible set for every prefix length, so the identification floor
is `2η = 0.089` — exact rational arithmetic gives `0.089 / 0.0259 ≈ 3.44`, i.e. the floor is
more than three times the one-rung interval.  Proved as `noisy_diameter_ge` and
`u108_noise_floor_dominates`.  Conclusion: at current measurement precision the U108 ladder is
noise-limited, and the rung budget of Section 1 is the *idealised* cost, attainable only after
the per-rung uncertainty is reduced below `d₀r/(1−r) = 0.0259`.
