# Future Directions: Impossible Geometries Where Parallel Lines Converge AND Diverge

## Synthesis

This cycle built, from a cold start, a self-contained combinatorial model of
"discrete parallel lines" (`Geometry/ImpossibleParallels.lean`) and proved a
sharp **rigidity vs. flexibility** dichotomy. A `ParallelPair` is two real
sequences `f, g : ℕ → ℝ` with gap `gap n = g n - f n`. The rigid side is
`gap_const_of_affine`: equal-slope affine lines have a *constant* gap, so they
can neither converge nor diverge. The flexible side is a single explicit witness
`impossible` (with `f = 0`, `g n = n+1` on evens and `1/(n+1)` on odds) whose
gap simultaneously drops below every `ε` and rises above every `M`
(`impossible_geometry`) while staying strictly positive (`gap_pos`) — the lines
get arbitrarily close and arbitrarily far yet never meet. We strengthened "two
cluster values" to genuine non-existence of a limit (`impossible_no_limit`) via
the boundedness of convergent sequences, and distilled the conceptual payoff in
`converges_not_affine`: *convergence detects curvature*.

We then pushed past the single witness toward structure, realizing two of the
originally seeded research directions inside the same file. Direction 1 became
`oscPair_realizes_spread`: the two-state pair `oscPair a b` realizes **every
bounded spread** `(a,b)` with `a ≤ b`, attaining `a` and `b` at arbitrarily
large indices while staying in the band `[a,b]`; `oscPair_not_affine` confirms
that any off-diagonal spread (`a < b`) is non-affine, so the diagonal `a = b` is
*exactly* the Euclidean locus. Direction 4 became a quantitative asymptotic:
`cesaroLower` gives the quadratic partial-sum bound `∑_{n<2k} impossibleGap n ≥ k²`
(a clean two-term induction peeling the even/odd pair `2k, 2k+1`), and
`impossible_cesaro_unbounded` concludes that the Cesàro means diverge — the
linear ("hyperbolic") even branch dominates the average and exposes one of the
two hidden temperatures.

The structural insight that emerged is that the lower and upper envelopes of the
gap (`liminf`, `limsup`) behave as **independent deformation parameters**: the
realization theorem shows the bounded region `{(a,b) : a ≤ b}` is fully
attainable, while `impossible` occupies the unbounded corner. Convergence,
divergence, and intersection genuinely decouple, which is what makes "parallel
lines that converge and diverge" a consistent object rather than a paradox.

## Results Summary

- `gap_const_of_affine`: proved — equal-slope affine pairs have a rigidly constant gap (the Euclidean rigidity).
- `gap_pos`: proved — the impossible pair's lines never meet (gap strictly positive everywhere).
- `impossible_geometry`: proved — the impossible gap is unbounded below by every `ε>0` and above by every `M` (converges AND diverges).
- `impossible_no_limit`: proved — the impossible gap has no limit at all (stronger than two cluster values).
- `converges_not_affine`: proved — a positive gap that becomes arbitrarily small forbids affineness (convergence detects curvature).
- `impossible_converges` / `impossible_not_affine`: proved — the witness instantiates the curvature-detection corollary.
- `oscPair_realizes_spread`: proved — every bounded spread `(a,b)`, `a ≤ b`, is realized by a two-state pair (Direction 1, surjectivity onto the bounded region).
- `oscPair_not_affine`: proved — any off-diagonal spread (`a<b`) is non-affine, pinning the diagonal as the Euclidean locus.
- `cesaroLower`: proved — `∑_{n<2k} impossibleGap n ≥ k²` (quadratic partial-sum lower bound).
- `impossible_cesaro_unbounded`: proved — the Cesàro means of the impossible gap diverge (Direction 4 at the level of unboundedness).

## Research Directions

### Direction 1: Exact Cesàro rate and the parity-split temperature decomposition
**Hypothesis**: `impossiblePartialSum (2k) / (2k) → ∞` with leading term `k/2`,
i.e. `impossiblePartialSum N = N²/4 + O(N) + O(log N)`, where the `O(log N)`
comes entirely from the odd (harmonic) branch and the `N²/4` from the even branch.
**Test**: Prove a matching upper bound `impossiblePartialSum (2k) ≤ k² + k + H_k`
(with `H_k` the harmonic sum) by the same two-term induction used in `cesaroLower`,
then sandwich the Cesàro mean. Verify the constant `1/4` against `#eval` of the
rational analogue for `k ≤ 50`.
**Why now**: `cesaroLower` already gives the exact lower induction; the upper
bound is its mirror image (the even term is an equality, the odd term is bounded
by `1/(2j+2) ≤ 1/2`), so the asymptotic is within immediate reach.
**If true**: Establishes the "two coexisting temperatures" claim rigorously — the
odd-restricted Cesàro mean tends to `0` while the full mean tends to `∞`.
**If false**: Would reveal an unexpected cross-term between the branches,
suggesting the parity split is not as clean a direct-sum as conjectured.

### Direction 2: A genuine `EReal`-valued spread invariant and its full image
**Hypothesis**: Define `spread P = (liminf gap, limsup gap) ∈ EReal × EReal`.
Then the image over all positive-gap pairs is exactly `{(x,y) : 0 ≤ x ≤ y ≤ ∞}`,
with the diagonal `{(c,c) : 0 < c < ∞}` equal to the set of asymptotically-affine
pairs.
**Test**: Compute `spread (oscPair a b) = (a,b)` and `spread impossible = (0,∞)`
using `Filter.liminf`/`limsup` API, then prove surjectivity by interpolating
`oscPair` for the finite interior and scaling `impossible` for the `∞` edge.
**Why now**: `oscPair_realizes_spread` already supplies the band membership and
the infinitely-often attainment of `a` and `b` — exactly the two facts a
`liminf`/`limsup` computation consumes.
**If true**: Turns the qualitative dichotomy into a complete classification map.
**If false**: The obstruction (likely at the `∞` boundary or at `x = 0`) would
pinpoint where unboundedness breaks the otherwise-clean lattice picture.

### Direction 3: Spread as a `(min,max)` monoid homomorphism (Geometry ↔ Tropical)
**Hypothesis**: Equip `ParallelPair` with a "stacking" operation (interleaving
two gap profiles index-wise). Then `liminf` distributes as `min` and `limsup` as
`max` over stacking, so `spread` is a monoid homomorphism into the tropical
semiring `(EReal, min, max)`; `impossible` is absorbing on the `max` axis and a
generator on the `min` axis.
**Test**: Define `stack P Q n = if Even n then P.gap (n/2) else Q.gap (n/2)` and
prove `liminf (stack) = min (liminf P) (liminf Q)` and the `max` analogue for
`limsup`, then package as a `MonoidHom`. Cross-check against the catalog's
`Tropical/` library for the target algebraic structure.
**Why now**: The two-state construction `oscPair` is literally `stack` of two
constant pairs, so the homomorphism identity is already validated on the
generating case.
**If true**: A real cross-domain bridge identifying impossible-parallel geometry
with tropical algebra.
**If false**: Failure of distributivity would show stacking mixes the envelopes
nonlinearly, demanding a richer (non-tropical) invariant.

### Direction 4: Quantitative rigidity — convergence rate forces total curvature
**Hypothesis**: If a positive-gap pair satisfies `gap n ≤ C/n^p` along a
subsequence (fast convergence) while `limsup gap > 0`, then the discrete total
curvature `∑ |Δ²(g-f)|` (second-difference total variation) is infinite.
**Test**: Express `gap` as a telescoping sum of slope increments and show that
forcing it small infinitely often while keeping `limsup` positive is a
total-variation lower bound; formalize `Δ²` and reduce to a summability
dichotomy. Bridge to `Geometry/DiscreteGaussBonnet.lean`'s curvature budget.
**Why now**: `converges_not_affine` is the qualitative `p = 0` shadow of this
statement; making the rate quantitative is the natural next refinement, and the
catalog already hosts the discrete-curvature machinery to connect to.
**If true**: A discrete Gauss–Bonnet-style "convergence costs curvature" budget.
**If false**: A counterexample with fast convergence and finite total curvature
would refute the analogy between gap-convergence and geometric curvature.

### Direction 5: Compactified "meet-twice" geometry on `ZMod n`
**Hypothesis**: Replacing `ℕ` by `ZMod n` (n ≥ 4), there exist pairs whose gap
vanishes at exactly two indices (genuine intersections) yet is bounded strictly
positive between them, and the count of such configurations with a prescribed
maximal gap is a polynomial in `n`.
**Test**: Define `ParallelPair`-on-`ZMod n`, make "meets at exactly two points
with max gap m" a `Decidable` predicate, and `#eval` the count for small `n,m`
to conjecture the polynomial degree before attempting a closed form.
**Why now**: Finiteness makes everything decidable, so the polynomial-count
conjecture can be machine-checked cheaply before any proof, exactly as the
present cycle validated `cesaroLower` numerically before proving it.
**If true**: Recasts the Euclidean "impossible" picture as an honest closed-curve
(elliptic) phenomenon where converge-and-diverge becomes meet-twice.
**If false**: The breakdown of the polynomial count would expose a parity or
divisibility obstruction specific to the circle topology.
