# Computational evidence (NET-43 bridge, cycles 1–2)

All computations below were run in Lean itself (`#eval` over `ℚ`, exact rational arithmetic),
so they are reproducible inside the project's toolchain; each one is also backed by a proved
theorem in `Catalog/Bridges/`.

## 1. Double-counting identity `∑_{|S|=k} mass(S) = C(n-1, k-1)`

`massSum n k p := ∑ S ∈ powersetCard k univ, ∑ i ∈ S, p i` for a probability vector `p`.

| profile | `k = 1..n` values of `massSum` | `C(n-1,k-1)` |
|---|---|---|
| uniform, `n = 5` | 1, 4, 6, 4, 1 | 1, 4, 6, 4, 1 |
| `(1/2, 1/4, 1/8, 1/8)`, `n = 4` | 1, 3, 3, 1 | 1, 3, 3, 1 |

The identity is exact for both a uniform and a strongly skewed profile, and is
profile-independent as the theorem `sum_mass_powersetCard` asserts.

## 2. Expected random-`k` mass equals `k/n`

Profile `(0.3, 0.2, 0.2, 0.1, 0.1, 0.1)` on `n = 6`; average of `mass(S)` over all
`C(6,k)` subsets of size `k`:

| `k` | 1 | 2 | 3 | 4 | 5 | 6 |
|---|---|---|---|---|---|---|
| measured average | 1/6 | 1/3 | 1/2 | 2/3 | 5/6 | 1 |
| `k/n` | 1/6 | 1/3 | 1/2 | 2/3 | 5/6 | 1 |

Exact match — proved as `expected_random_mass`.  At the NET-43 cell `(n,k) = (512,256)`
this gives expected random mass `0.5` against measured top-256 mass `0.922`
(`net43_random_control_gap`).

## 3. Chebyshev knee floor `k ≥ τ² · eff`

With the round's measured effective support `eff = 216.92`:

| `τ` | `τ² · eff` (exact rational) | decimal |
|---|---|---|
| 0.92 | 2868767/15625 | 183.6 |
| 0.98 | 13020623/62500 | 208.3 |

Both floors are below the measured knee `256` — the measurement is *consistent* with the
concentration bound, and any claimed knee below `184` at this concentration would be
mathematically impossible (`card_ge_of_bestMass_ge`,
`net43_concentration_forces_knee_gt_183`).

## 4. Measured doubling ratios versus the `2/3` exponent

Product of the reported per-doubling ratios `1.50 · 1.58 · 1.68 = 4977/1250 = 3.9816`,
strictly below `4 = 2²`.  Hence the empirical exponent `a` with `2^{3a} = 3.9816` satisfies
`0.6 < a < 2/3` (`empirical_exponent_bracket`); numerically `a ≈ 0.6644`.
The `2/3` law is therefore an *upper envelope* of the measured depth leg rather than an
exact fit — a falsifiable refinement of the round's claim, and the source of
Conjecture 2 in `FUTURE_DIRECTIONS.md`.

## 5. Power-law arithmetic at the deepest rung

`32^(2/3) ∈ (10.079, 10.080)` (cube pinned at `1024`), so `24.7 · 32^(2/3) ∈ (248.9, 249)`
— within 2.8% of the measured `256` (`net43_law_within_three_percent`), while the affine
model `8·32 + 32 = 288` overshoots by 12.5% (`net43_affine_over_predicts`).

## 6. Extremal profiles (cycle 3) and the tail ceiling (cycle 4)

| profile | `∑ pᵢ²` | `eff` | top-1 mass | floor `τ²·eff` at `τ=1/2` | linear floor `τ·eff` |
|---|---|---|---|---|---|
| spike `(1/2,1/8,1/8,1/8,1/8)` | 5/16 | 3.2 | 1/2 | 0.8 ≤ 1 (holds) | 1.6 > 1 (**fails**) |
| uniform on `n` | 1/n | n | 1/n | `τ²n` | `τn` = true knee |

So the quadratic dependence on `τ` is necessary (spike) and cannot be improved beyond a
factor `τ` (uniform).  Both rows are proved: `spike_refutes_linear_floor`,
`bestMass_uniform`, `uniform_floor_slack`.

Tail ceiling (`α = 2`): `∑_{j≥k} 1/(j+1)² ≤ 1/k` by telescoping `1/(j(j+1))`.  Numerically,
for `k = 256` the infinite tail is `0.0038976 ≤ 1/256 = 0.0039063` (tight to 0.2%), and the
finite tail over `j ∈ [256, 512)` actually used at the NET-43 cell is `0.0019474`
(these are floating-point checks, listed as evidence only; the proved statement is the
inequality `tail_sum_inv_sq_le`).  With tail constant `c = 20` this certifies mass `≥ 1 − 20/256 = 0.922` at width 256 —
exactly the round's measured top-256 mass (`net43_tail_ceiling_at_256` uses the weaker
rounded target `0.92`).

## 7. Counterexample hunt

* `card_powersetCard_filter_mem` and `sum_mass_powersetCard` are **false at `k = 0`**
  (LHS `0`, RHS `C(n-1,0) = 1`, because `0 - 1 = 0` in `ℕ`).  Both carry the hypothesis
  `1 ≤ k`; this was found by evaluation before the proof attempt.
* `lt_knee` (a failure at `a` certifies `a < knee`) is **false without upward closure**:
  for `P = {0, 2}`, `¬P 1` but `knee P = 0 < 1`.  The hypothesis `UpwardClosed P` is
  therefore load-bearing and appears in `knee_mem_bracket` and in the two-seed theorem.
* The claim `bestMass a 1 = max pᵢ` needs `k ≥ 1`; more importantly
  `card_powersetCard_filter_mem` and the tail bound both degenerate at `k = 0`
  (`1/k` undefined / `∑` empty), so `1 ≤ k` is carried explicitly throughout.
* The naive relative-error claim `|24.7·32^(2/3) − 256| < 0.03·256` fails if the prediction
  is only pinned to `(248, 250)`; the tighter interval `(248.9, 249)` is needed, which is
  why `rpow_32_two_thirds_bounds` pins the cube to four digits.

## 8. Cycle 5 evidence: the general power tail and gap concavity

*Tangent-line (Bernoulli) step,* `(α−1)(x+1)^(−α) ≤ x^(1−α) − (x+1)^(1−α)` at `α = 3/2`
(floating-point `#eval`, evidence only — the proved statement is `rpow_tail_step`):

| `x` | LHS `(α−1)(x+1)^(−α)` | RHS `x^(1−α) − (x+1)^(1−α)` |
|---|---|---|
| 1 | 0.176777 | 0.292893 |
| 2 | 0.096225 | 0.129757 |

*Tail sum at the NET-43 cell.*  `∑_{j=256}^{511} (j+1)^(−3/2) = 0.036533`, comfortably under
the proved bound `k^(1−α)/(α−1) = 256^(−1/2)/(1/2) = 0.125`.  With tail constant `c = 0.6`
this gives mass `≥ 1 − 0.6·0.125 = 0.925 ≥ 0.92` at width 256 — the content of
`net43_power_tail_ceiling_at_256`.  The slack (`0.0365` vs `0.125`) shows the bound is an
envelope, not an equality: the sum-integral comparison loses a constant factor for `α` far
from `2`.

*Gap concavity, small case.*  For the profile `p = (0.5, 0.25, 0.15, 0.1)` on `n = 4` keys the
top-`k` masses are `0, 0.5, 0.75, 0.9, 1.0`, whose increments `0.5, 0.25, 0.15, 0.1` are
antitone — the discrete concavity proved in general by `bestMass_midpoint_concave`.  The
selection gaps `bestMass(k) − k/4` are

`0, 0.25, 0.25, 0.15, 0`,

which rise then fall and vanish at both ends: unimodality (`selectionGap_unimodal`) and the
endpoint identities (`selectionGap_zero`, `selectionGap_full`).

*Counterexample hunt (cycle 5).*  Dropping `α > 1` breaks Conjecture 1 at once: for `α = 1`
the tail `∑_{j≥k} 1/(j+1)` diverges, so no ceiling can hold — the hypothesis `1 < α` is
load-bearing and appears in every statement of the file.  Dropping concavity breaks the chord
extrapolation: the sequence `f(256) = 2.6, f(384) = 1.7, f(512) = 5` is a legal non-concave
interpolation of the two measured gaps, which is why `net43_gap_chord_extrapolation` carries
`ConcaveSeq f` explicitly.

## Cycle 6 — where the selection gap peaks (evidence for `DeepestRungPeakAndTransfer.lean`)

All numbers below are exact rational `#eval` computations in Lean (`ℚ`), not floating point.

*Small case A.*  `p = (1/2, 1/4, 3/20, 1/10)` on `n = 4` keys, uniform share `1/4`.

| `k` | 0 | 1 | 2 | 3 | 4 |
|---|---|---|---|---|---|
| `selectionGap(k) = bestMass(k) − k/4` | `0` | `1/4` | `1/4` | `3/20` | `0` |

Above-average keys: `|{i : pᵢ > 1/4}| = 1`.  Excess mass `∑ (pᵢ − 1/4)⁺ = 1/4`, total-variation
distance to uniform `½∑|pᵢ − 1/4| = 1/4`.  The maximum of the gap sequence is `1/4`, attained
at `k = 1 = |aboveAvg|` — exactly `selectionGap_aboveAvg` and `selectionGap_peak_at_aboveAvg`,
and `excessMass = tv` as in `excessMass_eq_tv`.  (The tie at `k = 2` comes from the key with
`p = 1/4` sitting exactly at the uniform share; the theorem asserts the peak is *attained* at
`|aboveAvg|`, not that it is unique.)

*Small case B (more concentrated).*  `q = (0.40, 0.30, 0.10, 0.05, 0.05, 0.04, 0.04, 0.02)` on
`n = 8`, uniform share `1/8`:

| `k` | 0 | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 |
|---|---|---|---|---|---|---|---|---|---|
| `selectionGap(k)` | `0` | `11/40` | `9/20` | `17/40` | `7/20` | `11/40` | `19/100` | `21/200` | `0` |

`|aboveAvg| = 2` and `excessMass = 9/20 = 0.45`, which is precisely the maximum of the row
(`k = 3` already gives only `0.425`).  Note this case has a *strict* interior peak, so the
peak-location theorem is not vacuous.

*Counterexample hunt (cycle 6).*  (i) Dropping `0 < n` makes `k/n` collapse to `0` in Lean's
convention and the statements degenerate, so `hn` is kept in every statement that divides by
`n`.  (ii) The peak location genuinely depends on the *strict* inequality `pᵢ > 1/n`: in case
A, using `≥` would give `|aboveAvg| = 2`, which still attains the max here but would over-count
whenever ties carry no excess mass; the proof of `excessMass_eq_sum_aboveAvg` uses strictness.
(iii) Concavity transfer needs monotonicity of `g` as well as concavity: with `g x = −x`
(concave, decreasing) and the concave mass curve of case A, `k ↦ g(bestMass k)` is *convex*,
so `Monotone g` is load-bearing in `ConcaveSeq.comp_concave`.
