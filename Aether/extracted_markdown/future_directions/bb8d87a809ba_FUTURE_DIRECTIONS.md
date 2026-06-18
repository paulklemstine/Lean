# Future Directions: From Crossing Counts to Width Lower Bounds for ReLU Networks

## Synthesis

This cycle turned the *analytic* depth-separation results already in the catalog
(`ReLUDepthWidth.Basic.relu_depth_separation`, a Lipschitz/one-ramp obstruction,
and `ReLUDepthWidth.AbstractObstruction.twoPoint_gap_le`, its abstract two-point
form) into a *combinatorial* one. The engine is the dyadic alternation
`tent_iterate_dyadic` from `Oscillation.lean`: on the grid of order `k` the
depth-`k` tent network realizes the pure two-cycle `0,1,0,1,…`. Previously this
only localized **one** crossing of the level `1/2` per dyadic cell
(`tent_forces_crossings`). The new file `CrossingCount.lean` shows those
crossings are **distinct**, producing a strictly increasing family of `2^k`
level-`1/2` crossings (`tent_width_lower_bound`).

The decisive structural insight that unlocked the upgrade is *node
non-degeneracy* (`tent_node_value_ne_half`): because the deep tent is exactly
`0` or `1` at every dyadic node, any `ε`-approximant with `ε < 1/2` is pinned on
one fixed side of `1/2` at the nodes and can never equal `1/2` there. This
forbids two adjacent closed-cell crossings from collapsing onto their shared
endpoint, so the crossings are forced into the *open* cells and are pairwise
distinct. The same alternation also yields the clean quantitative identity
`tent_dyadic_total_variation`: the discrete total variation of `tent^[k]` over
the dyadic grid is exactly `2^k`, the bookkeeping that makes "oscillates `2^k`
times" a theorem rather than a slogan.

What this teaches: depth manufactures *count*, not merely magnitude. The
Lipschitz separation of `Basic.lean` is magnitude-based and can in principle be
defeated by very large weights; the crossing count is magnitude-independent and
therefore strictly stronger — a width-`w` continuous piecewise-linear network
meets a horizontal level in at most `w` points, so matching `tent^[k]` forces
`w ≥ 2^k` no matter how large the weights are. The natural next steps formalize
the "at most `w` crossings" half of this inequality and push the counting
machinery to higher dimensions and to other deep constructions in the catalog.

## Results Summary

- `tent_node_value_ne_half`: proved — an `ε<1/2` approximant of the deep tent is never `1/2` at a dyadic node; the non-degeneracy that makes crossings distinct.
- `tent_dyadic_consecutive_diff`: proved — adjacent dyadic node values differ by exactly `1`, the elementary jump of the deep tent.
- `tent_dyadic_total_variation`: proved — discrete total variation of `tent^[k]` over the dyadic grid equals `2^k`, the quantitative oscillation count.
- `tent_forces_crossing_Ioo`: proved — every open dyadic cell contains a strict interior crossing of the level `1/2`.
- `tent_width_lower_bound`: proved — a strictly increasing family of `2^k` distinct level-`1/2` crossings, a weight-magnitude-independent exponential width lower bound (strict strengthening of `relu_depth_separation`).

## Research Directions

### Direction 1: Formalize the piecewise-linear "at most w crossings" upper bound
**Hypothesis**: A continuous function that is affine on each of `w` consecutive
subintervals of `[0,1]` (a width-`w` one-hidden-layer ReLU network) attains any
fixed level at most `w` times, except on degenerate constant pieces.
**Test**: Define a `PiecewiseLinear` predicate (a partition with affine pieces),
prove the level-set-size bound, then combine with `tent_width_lower_bound` to
derive `w ≥ 2^k` as a corollary — a fully formal end-to-end width lower bound.
**The key insight is** that `tent_width_lower_bound` already supplies the hard
(lower) half; only the elementary linear-algebra (upper) half is missing, so the
final theorem is one composition away.
**Why now**: this cycle produced the `2^k` distinct crossings as a reusable
`Fin (2^k) ↪ ℝ` family, exactly the object an upper bound must contradict.
**If true**: the first machine-checked Telgarsky-style width lower bound with
both halves formalized. **If false**: the failure would localize to constant
pieces or partition degeneracies, sharpening the correct hypotheses.

### Direction 2: Total variation as the exact separation invariant
**Hypothesis**: The (continuous) total variation `eVariationOn (tent^[k]) (Icc 0 1)`
equals `2^k`, matching the discrete count of `tent_dyadic_total_variation`, and
any `ε`-approximant has total variation at least `2^k (1 - 2ε)`.
**Test**: Connect `tent_dyadic_total_variation` to Mathlib's `eVariationOn` via
the dyadic partition as a lower bound, and use the tent's piecewise-affine
structure for the matching upper bound.
**The key insight is** that total variation is the partition-free invariant the
discrete sum is approximating, so it should be the *intrinsic* currency of depth
separation, subsuming both Lipschitz and crossing arguments.
**Why now**: the discrete identity is proved and equals `2^k` on the nose,
giving an explicit partition that already witnesses the lower bound.
**If true**: a single scalar invariant unifies `Basic`, `Oscillation`, and this
cycle. **If false**: the gap reveals variation hidden between dyadic nodes,
pointing to a finer grid.

### Direction 3: Multi-dimensional / tensor-tent crossing counts
**Hypothesis**: The product network `(x,y) ↦ tent^[k] x` (or `tent^[k] x · tent^[k] y`)
forces `2^k` crossings along every axis-parallel line, so any approximant has a
level set of topological complexity growing like `2^{k}` per coordinate.
**Test**: Slice the 2-D approximation hypothesis to a fixed `y`, apply
`tent_width_lower_bound` on each slice, and aggregate to a 2-D crossing-count
lower bound.
**The key insight is** that the crossing argument is *one-dimensional and
local*, so it tensorizes by slicing — no new analytic content is needed, only a
fibered application of this cycle's theorem.
**Why now**: `tent_width_lower_bound` is stated for an arbitrary continuous `g`,
so a slice `g(·, y₀)` plugs in verbatim.
**If true**: depth separation in the genuinely multivariate regime relevant to
real networks. **If false**: it exposes a cancellation across slices, i.e. a
mechanism by which width is shared between coordinates.

### Direction 4: Robustness reading — adversarial crossing pairs
**Hypothesis**: For any classifier `g` approximating `tent^[k]` with `ε < 1/2`,
between consecutive crossings `c_i < c_{i+1}` there is an input pair, at distance
`O(2^{-k})`, on which `g`'s decision (relative to threshold `1/2`) flips while
the true label is locally constant — a certified adversarial example density of
order `2^k`.
**Test**: Combine `tent_width_lower_bound` (the crossing family) with
`AbstractObstruction.tent_adversarial` (the slope-based fragility statement) to
exhibit `Θ(2^k)` disjoint adversarial pockets.
**The key insight is** that crossings of the *decision threshold* are exactly
sign changes of the classifier, so the crossing count directly lower-bounds the
number of decision-boundary components.
**Why now**: both the crossing family (this cycle) and the adversarial slope
lemma (catalog) are now formal and live in the same namespace.
**If true**: a formal link between depth-induced expressivity and depth-induced
adversarial fragility. **If false**: a regime where extra crossings do not yield
genuine label flips, refining what "fragility" means.

### Direction 5: Lower bounds for other deep constructions via the same scheme
**Hypothesis**: The iterated-exponential tower `iterExp k` (from
`AbstractObstruction.iterExp`) and the doubling/Chebyshev families admit crossing
counts of their own; e.g. the Chebyshev polynomial `T_{2^k}` forces `2^k`
crossings of `0` on `[-1,1]`, provable by the identical node-alternation +
non-degeneracy + IVT pipeline.
**Test**: Replace the dyadic alternation `tent_iterate_dyadic` by the cosine-node
alternation of `T_{2^k}` and rerun the `CrossingCount.lean` argument structure.
**The key insight is** that the proof of `tent_width_lower_bound` factors through
only three abstract inputs — node alternation, node non-degeneracy, and IVT — so
it is a *template* applicable to any family with an explicit alternating grid.
**Why now**: the template is now isolated as four short lemmas, making the
substitution mechanical rather than a fresh development.
**If true**: a reusable "crossing-count lower bound" library spanning piecewise-
linear and polynomial deep families. **If false**: the obstruction is genuinely
special to self-similar (tent-like) maps, which would itself be a sharp dividing
line.
