# Future Directions: Completing and Extending ReLU Depth Separation

## Synthesis

This cycle closed the central open loop of the catalog's ReLU depth-separation
program. The earlier files established the **demand side** of the argument — for
the depth-`k`, constant-width tent network `tent^[k]`, any continuous
`ε`-approximant with `ε < 1/2` is *forced* to cross the level `1/2` at `2^k`
distinct interior points (`ReLUDepthWidth.tent_width_lower_bound` in
`CrossingCount.lean`, itself resting on the dyadic alternation
`tent_iterate_dyadic` and the IVT crossing argument `tent_forces_crossings` of
`Oscillation.lean`). What was missing — and explicitly flagged in `Basic.lean`
as "the most promising immediate target" — was the **supply side**: a proof that
a shallow piecewise-linear network can only afford finitely many such crossings.

We supplied exactly that. `PiecewiseLinear.lean` proves
`piecewise_affine_level_crossing_bound`: a function that is affine on each of `n`
cells of a monotone partition, and never identically equal to a level `c` on a
cell, attains the value `c` at most `n` times. The engine is the one-line fact
`affine_slope_eq_zero_of_two_points` (a non-constant affine map is injective)
plus a finite covering lemma `exists_cell` and an injection from crossings to
cells. `DepthSeparationComplete.lean` then snaps the two halves together:
`tent_piecewise_linear_width_lower_bound` shows that a continuous
piecewise-linear `g` with `n` pieces matching `tent^[k]` to accuracy `ε < 1/2`
must satisfy `2^k ≤ n`, and its contrapositive `tent_piecewise_linear_separation`
states that fewer than `2^k` pieces provably cannot approximate `tent^[k]`.

The key structural realization is that depth separation is, at bottom, a single
**cardinality inequality between two independently-established integer counts**:
`2^k = (oscillations demanded by depth) ≤ (crossings affordable by width) = n`.
Neither weight magnitudes nor Lipschitz constants enter — this is strictly
stronger than, and conceptually orthogonal to, the analytic Lipschitz
obstruction `relu_depth_separation` of `Basic.lean`.

## Results Summary

| Theorem | File | Status | Significance |
|---------|------|--------|--------------|
| `affine_slope_eq_zero_of_two_points` | `PiecewiseLinear` | **proved** | A non-constant affine map is injective; one-crossing-per-piece atom |
| `exists_cell` | `PiecewiseLinear` | **proved** | A monotone partition covers its hull by closed cells |
| `piecewise_affine_level_crossing_bound` | `PiecewiseLinear` | **proved** | `n` affine pieces ⇒ at most `n` level crossings (the supply side) |
| `tent_piecewise_linear_width_lower_bound` | `DepthSeparationComplete` | **proved** | `2^k ≤ n`: exponential width is necessary to match exponential depth |
| `tent_piecewise_linear_separation` | `DepthSeparationComplete` | **proved** | Contrapositive: `n < 2^k` pieces cannot `ε`-approximate `tent^[k]` |

All main results depend only on `propext`, `Classical.choice`, and `Quot.sound`.

## Research Directions

### Direction 1: From "n pieces" to a structural ReLU network width bound
**Hypothesis.** The abstract piece-count `n` in
`tent_piecewise_linear_width_lower_bound` is *equal to* `w + 1` for a genuine
one-hidden-layer ReLU network of width `w`, so the theorem upgrades to the
literal statement "width `w ≥ 2^k - 1` is necessary to ε-match `tent^[k]`."
**Test.** Introduce a `structure ShallowReLUNet` (weights `a : Fin w → ℝ`,
biases `b : Fin w → ℝ`, output weights `c : Fin w → ℝ`, output bias `d`),
define its evaluation `x ↦ d + ∑ i, c i * relu (a i * x + b i)`, and prove a
`toPiecewiseAffine` lemma producing a monotone partition with at most `w + 1`
affine cells from the `w` breakpoints `-b i / a i`. Feed this into
`piecewise_affine_level_crossing_bound`.
**The key insight is** that every ReLU neuron contributes exactly one breakpoint,
so the number of affine pieces is controlled *syntactically* by the width — the
combinatorial bound is already proved, only the syntax-to-pieces dictionary is
missing.
**Why now?** The hard analytic content (`exists_cell`, the injection) is done; a
ReLU network is just a concrete instance of the piecewise-affine hypothesis, and
the breakpoint-counting lemma is elementary `Finset` bookkeeping.
**If false:** it would mean ReLU sums can manufacture more affine pieces than
neurons, contradicting standard piecewise-linear counting — a red flag worth
isolating.

### Direction 2: Two-sided sharpness — an explicit width-`2^k` matching net
**Hypothesis.** The bound `2^k ≤ n` is tight: there exists a piecewise-linear
`g` with exactly `n = 2^k` pieces (in fact `g = tent^[k]` itself) achieving
`ε = 0`, so no smaller piece-count can work and `2^k` is optimal.
**Test.** Prove `tent^[k]` is itself piecewise-affine with exactly `2^k` cells on
`[0,1]` — partition `p i = i / 2^k`, with `tent^[k]` affine of slope `±2^k` on
each cell (this follows from `tent_iterate_dyadic` plus the branch identities
`tent_eq_two_mul`/`tent_eq_two_sub` already in `Oscillation.lean`). Then exhibit
the explicit `slope`, `inter` data.
**The key insight is** that the very grid theorem `tent_iterate_dyadic` that
*demands* `2^k` crossings also *certifies* that `2^k` pieces *suffice*, closing
the gap between lower and upper bounds.
**Why now?** The dyadic-grid values are fully characterized; turning them into an
affine-piece description is a finite, mechanical determination of two slopes per
cell.
**If false:** the optimal piece count would exceed `2^k`, revealing slack in the
crossing argument and a genuinely sharper combinatorial obstruction.

### Direction 3: Continuity of `tent^[k]` as a hypothesis-eliminator
**Hypothesis.** `ContinuousOn (tent^[k]) (Icc 0 1)` holds for all `k`, and more
usefully every piecewise-affine `g` built from a *consistent* partition (adjacent
pieces agreeing at shared breakpoints) is automatically continuous — letting us
*drop* the standalone `hgcont` hypothesis from
`tent_piecewise_linear_width_lower_bound`.
**Test.** Prove `Continuous tent` via `continuous_const.sub (continuous_abs.comp
(by continuity))`, lift to `tent^[k]` by `Continuous.iterate`, and prove a
`PiecewiseAffine.continuous_of_matching` lemma using `ContinuousOn` gluing on a
finite closed cover (`ContinuousOn.if`-style or `LocallyFinite` gluing).
**The key insight is** that continuity is currently an *external* assumption but
is in fact *intrinsic* to the piecewise-affine data once endpoints match, so the
separation theorem can be stated with strictly fewer hypotheses.
**Why now?** The branch identities make `tent` manifestly continuous, and the
gluing lemma is a self-contained real-analysis fact independent of the depth
machinery.
**If false** (impossible for `tent` itself): the difficulty would localize in the
gluing lemma, exposing exactly which matching condition continuity requires.

### Direction 4: Replacing the level `1/2` by an arbitrary regular value
**Hypothesis.** The crossing bound holds for *every* level `c`, not just `1/2`,
and the depth-separation conclusion `2^k ≤ n` survives for any approximation
target whose forced oscillation count is `2^k` — e.g. affine rescalings
`α · tent^[k] + β` of the tent tower.
**Test.** `piecewise_affine_level_crossing_bound` is *already* stated for general
`c`; the work is to generalize `tent_width_lower_bound` from the hard-coded
`1/2` to an arbitrary interior level by re-running `tent_forces_crossings` with
the threshold `c ∈ (0,1)` and `ε < min c (1-c)`.
**The key insight is** that the supply side is *already* level-agnostic, so the
entire generalization burden falls on a single parameterization of the demand
side — a localized, low-risk edit.
**Why now?** It immediately broadens the class of certified-hard targets from one
specific function to a whole affine family, multiplying the theorem's reach for
essentially free.
**If false:** some interior levels would be crossed fewer than `2^k` times,
pinpointing a non-genericity in the tent tower's oscillation structure.

### Direction 5: Depth-vs-depth — pieces grow geometrically with each layer
**Hypothesis.** For `0 ≤ j ≤ k`, matching `tent^[k]` with a depth-`j`
constant-width network requires at least `2^{k-j}` neurons per layer (or total
size `≥ 2^{k-j}`), interpolating between the shallow bound (`j = 1`, width
`≥ 2^{k-1}`) and the trivial deep realization (`j = k`, width `2`).
**Test.** Show a depth-`j` width-`w` ReLU network computes a piecewise-affine
function with at most `(w+1)^j` (more precisely `O(w^j)`) pieces — the standard
composition bound on linear regions — and combine with the `2^k`-crossing demand
to force `(w+1)^j ≥ 2^k`, i.e. `w ≥ 2^{k/j} - 1`.
**The key insight is** that linear-region counts *multiply* under composition
while crossings demanded by the target are *fixed at* `2^k`, so the same
cardinality inequality yields a full depth-resolved hierarchy rather than a
single shallow-vs-deep dichotomy.
**Why now?** Direction 1 supplies the depth-1 region count; the composition bound
is the natural inductive generalization, and the demand side `2^k` is already
nailed down independently of depth.
**If false:** linear regions would compose sub-multiplicatively, overturning a
cornerstone of expressivity theory and demanding a new region-counting calculus.
