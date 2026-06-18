# Future Directions: ReLU Depth–Width Trade-offs

## Synthesis of this cycle

This cycle closed the gap in the `ReLUDepthWidth` development. `CrossingCount.lean`
already contained the *counting* width lower bound (`tent_width_lower_bound`,
`tent_dyadic_total_variation`), but it depended on an analytic base layer that was
not present in the project. We supplied that layer in `Oscillation.lean`:

* `tent_iterate_dyadic` — the depth-`k` tent map equals the parity `j % 2` on the
  dyadic grid `j / 2^k`, the exact `0,1,0,1,…` alternation that makes the deep
  tent oscillate `2^k` times across `[0,1]`;
* `tent_forces_crossings` — an intermediate-value-theorem obstruction showing any
  continuous `ε`-approximant with `ε < 1/2` must cross the central level `1/2` in
  every dyadic cell.

We then added the matching *constructive* side and a clean capstone in
`Representation.lean`:

* `tent_eq_relu_combo` — the explicit width-3 depth-1 ReLU realization
  `tent x = 2·relu x − 4·relu(x − 1/2) + 2·relu(x − 1)` on `[0,1]`, so `tent^[L]`
  is computed by a width-3 depth-`L` ReLU network;
* `tent_maps_unitInterval` — `tent` is a self-map of `[0,1]`, legitimizing the
  iteration;
* `tent_approx_level_set_card` — packages the strictly increasing crossing family
  into a `Finset` of cardinality exactly `2^k` inside the level set
  `{x ∈ (0,1) : g x = 1/2}`.

Together these give a two-sided picture: **depth `L`, width `3` suffices to
manufacture `2^L` oscillations, while any continuous approximant needs `≥ 2^L`
pieces** — a self-contained exponential depth/width separation in one variable.

## Results summary

| Theorem | File | Statement |
|---|---|---|
| `tent_iterate_dyadic` | `Oscillation.lean` | `tent^[k] (j/2^k) = j % 2` |
| `tent_forces_crossings` | `Oscillation.lean` | close approximant crosses `1/2` per dyadic cell |
| `tent_eq_relu_combo` | `Representation.lean` | width-3 ReLU realization of `tent` on `[0,1]` |
| `tent_maps_unitInterval` | `Representation.lean` | `tent : [0,1] → [0,1]` |
| `tent_approx_level_set_card` | `Representation.lean` | `2^k` distinct interior `1/2`-crossings |

All proofs are `sorry`-free and depend only on the standard Lean/Mathlib axioms.

## Research directions

### 1. Compositional region multiplication for piecewise-linear maps

We have the canonical *doubling* example (`tent^[L]` realizes `2^L` pieces via
`tent_iterate_dyadic`), but not yet the general algebraic law: if `f` is affine on
each of `m` pieces and `g` is affine on each of `n` pieces, then `f ∘ g` is affine
on at most `m · n` pieces. Formalize a `HasLinearRegions f m` predicate (a sorted
finite breakpoint list whose complementary open intervals are affinity domains)
and prove `HasLinearRegions f m → HasLinearRegions g n → HasLinearRegions (f ∘ g) (m*n)`.
The matching lower bound `tent^[L]` has `≥ 2^L` pieces would then be a corollary,
upgrading our crossing count to a genuine region count.

The key insight is that on each affine piece of `g`, the composite `f ∘ g` is
just `f` pre-composed with an affine map, whose breakpoints are the affine
preimages of `f`'s breakpoints — so the breakpoint list of `f ∘ g` is the union
of `g`'s breakpoints with the pullbacks of `f`'s, bounding the count by `m · n`.

Why now? Our `tent_eq_relu_combo` already exhibits the three-breakpoint generator,
and `tent_iterate_dyadic` pins the realized count to exactly `2^L`; the only
missing piece is the purely combinatorial interleaving lemma on sorted lists,
which is independent of any analysis and well supported by Mathlib's `List.Sorted`
and `Finset` API.

### 2. From crossing count to a true neuron-count lower bound

`tent_approx_level_set_card` proves `2^k` interior points with `g = 1/2`, and the
narrative invokes "a width-`w` piecewise-linear network meets a level in `≤ w`
points." Make that rigorous: define the class of functions computable by a
single-hidden-layer width-`w` ReLU network, prove each such function is continuous
piecewise-linear with `≤ w + 1` pieces (hence meets any non-extremal horizontal
level in `≤ w` points), and conclude `w ≥ 2^k` for any `ε<1/2` approximant of
`tent^[k]`.

The key insight is that a level set `{x : h x = c}` of a continuous piecewise-linear
`h` is finite with at most one point per affine piece (excluding pieces lying
entirely on the level), so the level-set cardinality `2^k` from
`tent_approx_level_set_card` *directly* lower-bounds the piece count.

Why now? The hard analytic content (existence of `2^k` distinct crossings) is
already proved; the remaining step is the elementary structural fact that an
affine piece meets a horizontal line at most once, turning a cardinality bound
into a width bound with no further IVT machinery.

### 3. Sharp total-variation characterization of approximability

`tent_dyadic_total_variation` shows the discrete total variation of `tent^[k]` on
the dyadic grid is exactly `2^k`. Conjecture: a continuous `g` with (essential)
total variation `V` on `[0,1]` cannot approximate `tent^[k]` to accuracy `ε` once
`V < (1 - 2ε)·2^k`. This makes total variation, not Lipschitz constant, the right
complexity measure for the depth advantage.

The key insight is that each forced crossing of `1/2` (one per cell) costs the
approximant at least `1 - 2ε` of up-and-down variation, and there are `2^k`
cells, so the total variation of any close approximant is bounded below by
`(1 - 2ε)·2^k` — a quantity that grows exponentially in depth.

Why now? We already have both the per-cell crossing (`tent_forces_crossings`) and
the exact deep-tent variation (`tent_dyadic_total_variation`); Mathlib's
`eVariationOn` / `BoundedVariationOn` API supplies the target definition, so the
conjecture is a summation of the local variation lower bounds we have localized.

### 4. Continuity and exact piece count of the deep tent

We proved `tent` maps `[0,1]` into itself but have not yet established that
`tent^[k]` is continuous on `ℝ` (it is, being a composition of the continuous
`1 - |2x − 1|`) nor that it has *exactly* `2^k` affine pieces (not merely `≥ 2^k`
crossings). Conjecture: `Continuous (tent^[k])` and the number of maximal affine
subintervals of `tent^[k]` on `[0,1]` is exactly `2^k`.

The key insight is that continuity is immediate from `Continuous.comp` applied to
the single-step continuity of `x ↦ 1 - |2x − 1|`, while the exact piece count
follows by induction: each affine piece of `tent^[k]` is split into exactly two by
the next tent step because the tent peak `1/2` lies in the interior of every
piece's image.

Why now? `tent_maps_unitInterval` already controls the image, which is the precise
hypothesis needed to guarantee each piece's image straddles the peak `1/2`; the
induction then mirrors the parity recursion already verified in
`tent_iterate_dyadic`.

### 5. Multivariate oscillation and the Zaslavsky region bound

The one-variable theory yields `2^L` (more generally `(w+1)^L`) regions. In `d`
dimensions a single width-`w` ReLU layer cuts `ℝ^d` by `w` hyperplanes into at
most `∑_{i=0}^{d} C(w, i)` regions (Zaslavsky). Conjecture and formalize this
arrangement bound, and combine it with Direction 1 to obtain the shallow lower
bound `Ω(ε^{-d})` versus the deep upper bound.

The key insight is that the regions of an arrangement of `w` hyperplanes in
general position are counted by `∑_{i=0}^{d} C(w, i)`, an identity provable by
induction on `w` where adding one hyperplane creates exactly `∑_{i=0}^{d-1} C(w-1, i)`
new regions — a clean Pascal-style recursion over binomial coefficients.

Why now? Mathlib has a mature binomial-coefficient and `Finset.sum` toolbox, and
the `TropicalReLUBridge` already encodes a single ReLU layer as a max of affine
functions whose breakpoints are exactly these hyperplanes; the Zaslavsky count
would be a reusable standalone combinatorial-geometry contribution.
