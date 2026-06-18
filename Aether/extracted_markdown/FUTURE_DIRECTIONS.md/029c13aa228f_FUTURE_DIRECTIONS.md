# Future Directions: Quantitative Tournament Curvature

The file `Curvature.lean` promotes the binary "transitive vs. has-a-Condorcet-cycle"
dichotomy of Arrow/Condorcet theory into a continuous `[0,1]`-valued invariant
`κ(T)` — the fraction of 3-element vertex subsets that form directed 3-cycles. We
proved `0 ≤ κ ≤ 1`, the rigidity theorem `κ(T) = 0 ↔ T` transitive (the dictatorial
points sit exactly at curvature zero), `0 < κ ↔ T` has a 3-cycle, and the sharp
3-alternative dichotomy `κ ∈ {0,1}`. The following directions extend this frontier.

## 1. The ordered/unordered counting bridge: `cycleCount = 3 · |cyclicTriples|`

`Defs.lean` counts directed 3-cycles as *ordered* triples (`Tournament.cycleCount`),
while `Curvature.lean` counts *unordered* cyclic 3-subsets (`cyclicTriples`). These
should be related exactly by the factor of three cyclic rotations:
`T.cycleCount = 3 * T.cyclicTriples.card`, and consequently
`κ(T) = cycleCount / (3 · C(n,3))`.

The key insight is that every cyclic 3-subset `{a,b,c}` contributes exactly three
ordered cycle-triples `(a,b,c), (b,c,a), (c,a,b)` and no others, so the map
"ordered cycle-triple ↦ underlying subset" is exactly 3-to-1 onto `cyclicTriples`.
Why now? Both counting functions already exist and compile in the catalog; bridging
them is a finite combinatorial fibration argument (`Finset.card_eq_sum_card_fiberwise`)
that immediately upgrades every `cycleCount` lemma in `Defs.lean` into a statement
about the normalized curvature `κ`, unifying the two halves of the theory.

## 2. The Kendall–Babington-Smith ceiling: `sup κ → 1/4`

For `n = 3` the maximum curvature is `1`, but for large `n` not every triangle can be
cyclic. The classical maximum number of cyclic triangles in a tournament on `n`
vertices is `(n^3 - n)/24` for odd `n` (attained by doubly-regular / quadratic-residue
tournaments), which gives `κ_max(n) = (n+1) / (4(n-1)) → 1/4`.

The key insight is that the cyclic-triangle count is `C(n,3)` minus the number of
"transitive" triples, and the transitive count is minimized exactly when all out-degrees
are as equal as possible — a variance/convexity bound `∑ d_i (d_i - 1)/2` on the score
sequence. Why now? With `κ` formalized and bounded in `[0,1]`, the natural next theorem
is the *sharp* upper bound `κ(T) ≤ (n+1)/(4(n-1))` for odd `n`, plus the existence of an
extremal quadratic-residue tournament attaining it; this turns the abstract `[0,1]`
codomain into a precisely understood interval `[0, ~1/4]` for tournaments of fixed size.

## 3. Quantitative Arrow: an expected-curvature lower bound for non-dictatorial rules

`Defs.lean` defines `SocialWelfareFunction`, `IsDictatorial`, and `majorityTournament`,
and states the qualitative `arrow_curvature_conjecture`. The quantitative strengthening:
for any non-dictatorial aggregation rule `F` on `m ≥ 3` alternatives and `n` odd voters,
the expected curvature of the induced majority tournament over a suitable profile family
is bounded below, `E[κ(MajorityTournament(F))] ≥ 1/(4m)`.

The key insight is that non-dictatorship guarantees a "pivotal" configuration on some
triple where the majority relation must cycle for a positive-measure set of profiles, so
the indicator of a Condorcet cycle has expectation bounded away from zero by a pivotality
argument (a robust, measure-theoretic version of the Arrow pivotal-voter proof). Why now?
The deterministic machinery (`supportCount`, `majorityBeats`, `CondorcetCurvature`) is
already in the catalog; only an averaging layer over a finite profile distribution is
missing, making this the first genuinely *metric* (rather than impossibility) statement
in social-choice formalization.

## 4. Curvature isolates dictatorships: a discrete metric structure on rule space

Equip tournaments on `Fin n` with a Hamming-style edge-flip metric and view `κ` as a
function on this finite metric space. The rigidity theorem says the transitive
tournaments are exactly `κ⁻¹(0)`; we conjecture they are *metrically isolated minima*:
flipping a single edge of a transitive tournament that creates a cycle increases `κ` by
at least `1/C(n,3)`, so `κ` has a uniform "spectral gap" at its zero set.

The key insight is that a transitive tournament has a unique Hamiltonian ranking, and the
minimal perturbation that breaks transitivity creates exactly one new cyclic triangle, a
local-to-global step controlled by `cyclicTriples_nonempty_iff_has3cycle`. Why now? With
`κ` proven to land in `[0,1]` and to vanish iff transitive, the immediate question is the
*quantitative* gap near the zero set, which converts Arrow's "dictators are special" into
"dictators are uniformly separated", a statement now expressible entirely with existing
`Curvature.lean` lemmas.

## 5. Domain restriction kills curvature: a single-peaked Black's theorem in `κ` form

`Defs.lean` introduces `StrictRanking.IsSinglePeakedAt` and
`PreferenceProfile.IsSinglePeaked`. Black's theorem says single-peaked profiles yield a
transitive majority relation; in curvature language this is the sharp statement
`P.IsSinglePeaked → κ(P.majorityTournament …) = 0`, i.e. single-peaked domains are flat.

The key insight is that single-peakedness forces the majority winner among any triple to
be the median voter's peak, which is a Condorcet winner on every 3-subset, so no triangle
can cycle. Why now? `zero_curvature_majority_transitive` already links zero
`CondorcetCurvature` to transitivity of the majority tournament, so proving the single
remaining implication (single-peaked ⇒ `CondorcetCurvature = 0`) closes the loop and
exhibits an explicit, structurally-characterized family of curvature-zero ("flat")
preference domains — the geometric counterpart of Arrow's escape routes.
