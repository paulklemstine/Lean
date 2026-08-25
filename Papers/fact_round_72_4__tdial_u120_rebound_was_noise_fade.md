# Computational Evidence — U120 floor cycle (exp 554)

All numbers below were produced by short exploratory scripts *before* the Lean work, to
decide which conjectures were worth formalising. Anything reported here as a **theorem**
is proved in `Catalog/Algebra/ZeroFitDialU120*.lean` with no `sorry`; the tables
themselves are exploratory arithmetic and are not a substitute for those proofs.

## 1. The recorded ladder and its ratios

```
raw ladder      : 0.5739  0.5436  0.5005  0.4880  0.4621  [0.4847]  0.4364
raw ratios      : 0.9472  0.9207  0.9750  0.9469  1.0489  0.9004
de-noised ladder: 0.5739  0.5436  0.5005  0.4880  0.4621            0.4364
de-noised ratios: 0.9472  0.9207  0.9750  0.9469  0.9444
```

Every de-noised ratio is `≤ 0.975 < 0.98`. This is the hypothesis of
`u120_ladder_ratio_bound` (proved) and it is what feeds the geometric envelope.

Envelope check: `0.98^5 · 0.43636 = 0.394435 < 0.40`, matching
`u120_predicts_below_forty` (proved).

## 2. Capacity of the dial level (decorrelated families)

`⌊1/ρ²⌋` is the largest number of mutually orthonormal statistics that the capacity law
`k·ρ² ≤ 1` allows to all read at level `ρ`:

| reading | 0.5739 | 0.4847 | 0.43636 |
|---|---|---|---|
| `⌊1/ρ²⌋` | 3 | 4 | 5 |

Formalised as `dial_capacity_at_5739` (≤ 3) and `u120_decorrelated_family_at_most_five`
(≤ 5), with `dial_capacity_expansion` recording that a four-element decorrelated family
becomes admissible only after the fade. Cycle 4 turns the table into the function
`dialCapacity ρ = ⌊1/ρ²⌋` and proves `dialCapacity 0.5739 = 3`,
`dialCapacity 0.43636 = 5`, plus the duality between an unbounded capacity and the absence
of a positive floor.

## 3. Counterexample hunt: is the duality bound ever stronger than the ellipse bound?

Sampling 200 000 uniform pairs `(a, b) ∈ [-1,1]²` and computing
`E = ab + √((1-a²)(1-b²))` against `D = 1 - (a-b)²/2`:

```
max (E - D) observed = -7.2e-13   (numerical zero, attained near a = b)
```

No counterexample: the ellipse certificate never loses. The universal statement is proved
in Lean as `ellipse_dominates_duality`, and the equality locus `|a| = |b|` seen in the
sample is proved as `ellipse_eq_duality_of_abs_eq`.

## 4. Sharpness of the Kantorovich pooling constant

Minimising `κ(p) = E[λ]/√(E[λ²])` over two-point ratio distributions on `{α, β}` with mass
`p` at `β`:

| window `[α, β]` | numeric min `κ` | mass at `β` | `2√(αβ)/(α+β)` |
|---|---|---|---|
| [1, 3] | 0.866025 | 0.25 | 0.866025 |
| [1, 4] | 0.800000 | 0.20 | 0.800000 |
| [1, 9] | 0.600000 | 0.10 | 0.600000 |
| [2, 5] | 0.903508 | 0.286 | 0.903508 |

The numeric minimum matches `2√(αβ)/(α+β)` to six digits in every window, which is what
`pooled_kantorovich_bound` proves and `kantorovich_pooling_sharp` realises exactly (the
`[1,4]` row, with block energies `4 : 1`, pooled reading `4/5`).

## 5. New constant versus the cycle-1 constant

| `δ` | cycle-1 `(1-δ)/(1+δ)` | cycle-2 `√(1-δ²)` |
|---|---|---|
| 0.05 | 0.90476 | 0.99875 |
| 0.10 | 0.81818 | 0.99499 |
| 0.20 | 0.66667 | 0.97980 |
| 0.50 | 0.33333 | 0.86603 |

The improvement is large; the universal strict inequality is
`kantorovich_beats_cycle_one`.

## 6. How much imbalance would be needed to fake the fade

The pooled decline would be an artefact only if the attenuation factor could reach
`0.43636 / 0.5739 = 0.76034`. A four-fold ratio window gives `2·2/5 = 0.8 > 0.76034`
(not enough); a five-fold window gives `2√5/6 = 0.7454 < 0.76034` (enough). Formalised as
`imbalance_needed_for_artefactual_fade`, and the `±10%` case as `u120_fade_is_seedwise`.
The inverse direction (`u120_seed_window`) gives the per-seed window
`[0.43636, 0.43835]` implied by the pooled value under the same `±10%` assumption:
`0.43636 · 2.21/2.2 = 0.4383436…`.

## 7. OEIS

No integer sequence arises in this cycle: every object is a real-valued correlation or an
attenuation constant, so an OEIS search is not applicable.

## 8. Cycle 5: hunting for a non-endpoint Kantorovich extremiser

A random search (200 000 normalised profiles per window, support sizes 2–4, ratios drawn
uniformly from the window) minimised the Kantorovich slack
`g = (α+β)²M² − 4αβ·S·Q`. Below, the "predicted" profile is the one that
`kantorovich_equality_mass` forces: mass `β/(α+β)` at `α` and `α/(α+β)` at `β`.

| window `[α, β]` | best random `g` | best random profile (mass at `α`, mass at `β`) | best random ratios | predicted masses | `g` at predicted profile |
|---|---|---|---|---|---|
| `[1, 4]`    | 0.899615  | (0.7922, 0.2078) | (1.0010, 3.9110) | (0.8000, 0.2000) | 0 (exact) |
| `[1, 1.21]` | 0.0013142 | (0.5428, 0.4572) | (1.0013, 1.2087) | (0.5475, 0.4525) | `−8.9e−16` (float noise) |
| `[2, 3]`    | 0.123535  | (0.6169, 0.3831) | (2.0006, 2.9886) | (0.6000, 0.4000) | `2.8e−14` (float noise) |

Every search run drifted to the *endpoints* of the window with masses converging to the
predicted split, and no profile with an interior atom ever came close: e.g. the single-atom
profile at the midpoint `(α+β)/2` has slack `56.25`, `0.0538` and `6.25` in the three
windows. This is exactly the counterexample hunt for the rigidity claim, and it found
none — consistent with `kantorovich_equality_rigidity`, `kantorovich_equality_mass` and
`kantorovich_strict_of_interior`, which together prove no counterexample exists.

## 9. Cycle 5: how the `±10%` window bounds the pooling artefact

At `[α, β] = [1, 1.21]` the worst-case attenuation factor is exactly
`2√1.21/2.21 = 2.2/2.21 = 0.9954751…`. Holding every seed at the previous rung `0.4847`
therefore forces the pooled reading to be at least `0.4847 · 0.9954751 = 0.4825069…`,
comfortably above the recorded `0.43636` (`u120_step_not_imbalance_artefact`). Running the
requirement backwards, imbalance alone would need a factor `≤ 0.43636/0.4847 = 0.900268…`,
which by `u120_extremal_window_needed` forces `β ≥ 1.9α` (the exact threshold is
`β/α ≥ 2.5415…`, the larger root of `0.9003 t − 2√t + 0.9003 = 0`).

## 10. Cycle 6: the proved stability envelope versus the search data

`kantorovich_stability` bounds the weighted `L¹` distance of a profile from the window
endpoints by `ε/(2αβ(β−α))`, where `ε` is its Kantorovich slack. For the three searched
windows the envelope constants are:

| window `[α, β]` | envelope `ε / (2αβ(β−α))` | best random `ε` | envelope at that `ε` | actual `L¹` distance of the argmin |
|---|---|---|---|---|
| `[1, 4]`    | `ε/24`     | 0.899615  | 0.0374840 | 0.0192864 |
| `[1, 1.21]` | `ε/0.5082` | 0.0013142 | 0.0025860 | 0.0013000 |
| `[2, 3]`    | `ε/12`     | 0.123535  | 0.0102946 | 0.0047375 |

(The last column is `∑ wₖ·min(λₖ−α, β−λₖ)` for the best profile found by the search.)
Each measured distance sits inside its proved envelope by a factor of about `2`, which is
the expected loss from the convexity step `((β−α)/2)·min(λ−α, β−λ) ≤ (λ−α)(β−λ)` — the
envelope is therefore tight to within a small constant on real profiles.
The envelope collapses to `0` with `ε`, matching `kantorovich_stability_recovers_rigidity`.
