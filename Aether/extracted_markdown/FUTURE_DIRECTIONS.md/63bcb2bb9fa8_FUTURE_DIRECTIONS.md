# Future Directions — Eastin–Knill & the Fault-Tolerance Threshold

This cycle extended `Catalog/Physics/EastinKnillThreshold.lean` with five new
machine-checked results that sharpen and unify the existing threshold theory:

- `errorRate_pos` — positivity of the level-`n` logical error rate.
- `errorRate_succ_lt` — strict per-level improvement below threshold
  (`p_{n+1} < p_n`): the engineering content of concatenation.
- `errorRate_tendsto_zero_iff` — the **sharp threshold dichotomy**: the logical
  error rate collapses to `0` *iff* `c·p < 1`, collapsing the three separate
  regime lemmas of the parent file into one biconditional that pins `1/c` as
  *the* threshold.
- `errorRateGen` / `errorRateGen_rescaled` — a **generalized doubly-exponential
  law** for distance-`d` codes with suppression exponent `t`, recovering the
  canonical `t = 2` law exactly.
- `eastin_knill_infinite_quotient` — a **quantitative Eastin–Knill**: a finite
  transversal gate group has infinitely many cosets in an infinite logical
  group, strictly stronger than mere properness.

What follows are five testable, falsifiable conjectures that drive the next
cycle, each building on these foundations and the surrounding catalog
(`Physics/GaugeCodeDistance.lean`, `Physics/ToricCode.lean`,
`Bridges/StabilizerGaloisConcatenation.lean`).

---

## Direction 1 — A monotone, exhaustive threshold functional

We proved `errorRate_succ_lt` (strict decrease) and `errorRate_tendsto_zero_iff`
(the sharp dichotomy) separately. The natural next object is the **threshold
functional** `Θ(c) := sSup { p : 0 ≤ p ∧ Tendsto (errorRate c p) atTop (𝓝 0) }`,
and the conjecture that `Θ(c) = 1/c` for every `c > 0`, together with
`StrictAnti (errorRate c p)` (full strict monotonicity, not just one step) on the
whole sub-threshold interval. A falsifiable sub-claim: there is *no* `p` with
`p = 1/c` for which the rate tends to `0` (the boundary is genuinely excluded).

The key insight is that the per-level map `f_c(x) = c·x²` is a contraction
*exactly* on `[0, 1/c)` and the supremum of its basin of attraction to `0` is its
non-trivial fixed point `1/c` — so the threshold is an order-theoretic invariant
(`sSup` of a basin), not merely an analytic limit. **Why now?** With
`errorRate_succ_lt` and the dichotomy already formalized, the basin description is
one `StrictAnti`/`sSup` argument away, and Mathlib's `Order` and
`Topology.Algebra.Order` APIs make the supremum characterization tractable today.

## Direction 2 — Generalized threshold `c^{-1/(t-1)}` and the distance/exponent law

`errorRateGen_rescaled` linearizes the distance-`d` recursion via a rescaling
constant `a` with `a^{t-1} = c`. The next step is to prove the **closed-form
generalized threshold** `p_th(t) = c^{-1/(t-1)}` (using `Real.rpow`), the
generalized dichotomy `Tendsto (errorRateGen c p t) atTop (𝓝 0) ↔ a·p < 1`, and
the **monotonicity in `t`**: better codes (larger `t = ⌈(d+1)/2⌉`) yield strictly
higher thresholds, `p_th(t) < p_th(t+1)` when `c > 1`.

The key insight is that the entire family of concatenation recursions is governed
by a *single* scalar invariant `a = c^{1/(t-1)}`, so all threshold phenomena are
images of the universal map `x ↦ x²` (or `x ↦ x^t`) under one rescaling — the
distance of the code enters only through the exponent. **Why now?** The rescaled
law is already proven for general `t`, so the remaining work is `rpow` algebra and
reuse of the `t = 2` dichotomy proof pattern, both well-supported in Mathlib.

## Direction 3 — Index lower bounds for transversal gate groups

`eastin_knill_infinite_quotient` shows `G ⧸ T` is infinite for finite `T`. The
sharper, quantitative conjecture: for a code on `n` physical qudits of dimension
`q`, the transversal group `T` embeds in `S_n ≀ (gate group on one qudit)`, so
`Nat.card T` is bounded by `n! · (finite local-gate count)`, while the logical
unitary group `PU(q^k)` is a positive-dimensional Lie group — giving an explicit,
diverging lower bound on the index `[G : T]` as the code distance grows.

The key insight is that transversality forces a **permutation-times-local**
factorization of every logical gate, so `T` is not merely finite but
*polynomially* sized in `n`, whereas universality requires covering a continuum —
the gap is quantitative, not just cardinal. **Why now?** Mathlib now has wreath
products, `Subgroup.index`, and `Subgroup.card_mul_index`; combined with
`StabilizerGaloisConcatenation` in the catalog, the permutation factorization can
be modeled abstractly without a full unitary-group formalization.

## Direction 4 — Bridge: spectral gap ⇒ threshold via `GaugeCodeDistance`

The catalog's `Physics/GaugeCodeDistance.lean` proves code distance `d ≥ Δ·L`
from a lattice gauge spectral gap `Δ`. Composing this with our generalized law,
the conjecture is a **gap-to-threshold bridge**: a uniform spectral gap `Δ > 0`
forces the suppression exponent `t = ⌈(Δ·L + 1)/2⌉ → ∞`, hence (by Direction 2)
the threshold `p_th(t) → 1` as `L → ∞` whenever `c > 1` — i.e. a gapped gauge
theory yields an *asymptotically perfect* fault-tolerance threshold.

The key insight is that the gauge spectral gap and the fault-tolerance threshold
are two faces of the same exponent: `Δ` controls the code distance, the code
distance controls the suppression exponent `t`, and `t` controls the threshold —
a single monotone chain linking condensed-matter physics to fault tolerance.
**Why now?** Both endpoints are already formalized in this repository
(`spectral_gap` distance bounds and `errorRateGen_rescaled`), so the bridge is a
composition lemma rather than new heavy theory.

## Direction 5 — Off-criticality and a finite-size threshold (boundary case)

Our dichotomy is asymptotic (`atTop`). Real devices run finitely many levels, so
the falsifiable conjecture is a **finite-`L` threshold law**: for a target logical
error `ε` and `L` concatenation levels, define `p_th(ε, L)` as the largest `p`
with `errorRate c p L ≤ ε`, and prove `p_th(ε, L) = (1/c)·(c·ε)^{1/2^L}`, with
`p_th(ε, L) ↗ 1/c` monotonically — and the boundary observation that *at* `c·p=1`
no finite `L` ever reaches `ε < 1/c` (`errorRate_at_threshold_const`), so the
asymptotic threshold is not attained at any finite resource budget.

The key insight is that inverting the closed form `errorRate_closed_form` gives an
*exact* finite-resource threshold, exposing the slow `2^{-L}` approach to the
ideal `1/c` — the practically relevant quantity that the asymptotic statement
hides. **Why now?** `errorRate_closed_form` is already proven, so the finite-size
law is a direct algebraic inversion plus a monotonicity argument, and it connects
to the catalog's `Pythagorean/SharpThresholdConcentration` finite-size results.
