# Future Directions: The Tropical Diagonal Power Gap

## Synthesis

This cycle investigated the diagonal entries of *tropical (min-plus) matrix powers*
built on the `tropMatMul` algebra of `Tropical.MinPlusAlgebra`. The central discovery
is a clean **sign dichotomy** governing iteration: the diagonal of `Aᵏ` is controlled
entirely by the sign of the diagonal entry `A i i`, with no other structural input.
When `A i i < 0`, the diagonal strictly decreases at every step
(`tropMatPow_diag_gap`) and in fact diverges to `-∞` at the *linear* rate `|A i i|`
per step (`tropMatPow_diag_le`, `tropMatPow_diag_diverges`). When the matrix instead
comes from a non-negative-weight digraph with zero self-loops, every power is
entrywise non-negative (`tropMatPow_nonneg`) and the diagonal is *pinned* at exactly
`0` for all powers (`tropMatPow_diag_stabilize`).

The structural insight that emerged is that the "stay-at-i" self-loop is always an
admissible path in the min-plus product, so a single tropical multiplication can only
*lower* the diagonal, and it lowers it by at most `A i i`. This one-step contraction
(`tropMatPow_diag_step_le`) is the single engine behind every other result: the
linear bound is its iteration, the gap is its sign-specialization, and the
stabilization theorem is the same engine sandwiched against the non-negativity lower
bound. Nothing failed outright this cycle, but the attempt to upgrade the *gap* into a
two-sided estimate (a matching lower bound on the diagonal) revealed that the
self-loop only gives an upper bound; controlling the diagonal from below requires the
minimum mean-cycle value, which is the natural next object of study.

The boundary case `A i i = 0` is exactly the stabilization regime, so the two main
theorems meet sharply at zero: this is the critique of the gap theorem made precise,
and it suggests the right generalization is a *spectral* statement in which the
asymptotic per-step decrement is the tropical (min-plus) eigenvalue rather than the
raw diagonal entry.

## Results Summary

- `tropMatPow_diag_step_le`: proved — one tropical step lowers the diagonal by at most `A i i` (the self-loop bound that powers every later result).
- `tropMatPow_diag_le`: proved — the diagonal of `Aᵏ` is at most `(k+1)·A i i`, a linear upper bound valid for every matrix.
- `tropMatPow_diag_gap`: proved — a negative diagonal entry forces the diagonal sequence to strictly decrease (the "power gap").
- `tropMatPow_diag_diverges`: proved — a negative diagonal entry forces the diagonal to be unbounded below, quantifying erasure of diagonal information.
- `tropMatPow_nonneg`: proved — every tropical power of a non-negative-weight digraph is entrywise non-negative.
- `tropMatPow_diag_stabilize`: proved — for a `WeightedDigraph`, the diagonal of every power is exactly `0`, the zero-gap boundary case.

## Research Directions

### Direction 1: Mean-cycle eigenvalue controls the asymptotic gap
**Hypothesis**: For an irreducible tropical matrix `A`, the limit
`lim_{k→∞} (tropMatPow A k i i) / k` exists and equals the tropical eigenvalue
`λ(A) = min over cycles C of (weight(C)/length(C))`, independent of `i`.
**Test**: Define minimum mean cycle weight in Lean, prove the upper bound from
`tropMatPow_diag_le` generalized to arbitrary cycles, and prove a matching lower
bound by showing every diagonal path decomposes into cycles plus a bounded remainder.
**Why now**: `tropMatPow_diag_le` already gives the exact upper-bound half via the
length-1 self-loop cycle; the only missing ingredient is the cycle-decomposition lower
bound. The key insight is that the self-loop is just the *shortest* cycle, so the true
asymptotic slope is the minimum over all cycles, not just the diagonal entry.
**If true**: It promotes the sign dichotomy to a full quantitative spectral law and
connects this file to tropical Perron–Frobenius theory already present in the catalog
(`Tropical.PerronFrobenius.*`).
**If false**: It would expose a reducible/periodic counterexample where the Cesàro
limit fails to exist, sharpening exactly which irreducibility hypothesis is needed.

### Direction 2: Power stabilization (Kleene star) for non-negative digraphs
**Hypothesis**: For a `WeightedDigraph` on `n` vertices, the tropical powers stabilize
entrywise after at most `n-1` steps: `tropMatPow W.weights k = tropMatPow W.weights (n-1)`
for all `k ≥ n-1`, and this stable matrix is the all-pairs shortest-path matrix.
**Test**: Prove monotone non-increase of every entry across powers, then a pigeonhole
"no shortest path repeats a vertex" argument bounding the stabilization index by `n-1`.
**Why now**: `tropMatPow_nonneg` and `tropMatPow_diag_stabilize` already establish the
diagonal half of the stable matrix; the off-diagonal entries are the remaining content.
The key insight is that non-negativity forbids negative cycles, which is precisely the
condition under which shortest paths are simple and stabilization must occur.
**If true**: It yields a fully verified Floyd–Warshall correctness statement phrased in
tropical-algebra terms, bridging `Tropical.GraphTheory.KleeneStarUpdate` and this file.
**If false**: A counterexample would have to violate the simple-path bound, revealing a
zero-weight cycle subtlety in the `self_loop_zero` hypothesis.

### Direction 3: Quantitative one-wayness from the linear gap
**Hypothesis**: If every diagonal entry of `A` is at most `-c < 0`, then recovering `A`
from `tropMatPow A k` is information-theoretically obstructed on the diagonal: the map
`A ↦ tropMatPow A k` collapses the diagonal coordinates into a band of width `O(1)`
around `-(k+1)c`, so at least `Ω(k)` bits of diagonal magnitude are non-invertible.
**Test**: Formalize a preimage-ambiguity statement analogous to `trop_preimage_nonunique`
but for powers, exhibiting two matrices with distinct diagonals yet identical `k`-th power.
**Why now**: `tropMatPow_diag_diverges` shows the diagonal is driven to `-∞` at a known
linear rate, so the forward map provably destroys diagonal scale. The key insight is
that divergence *is* loss of information: an unbounded, sign-determined drift cannot be
inverted from a single observed power.
**If true**: It gives the first power-level (rather than single-product) one-wayness
result in the catalog's tropical-cryptography line.
**If false**: The failure would pinpoint a normalization (e.g. trace subtraction) that
restores invertibility, which is itself a useful protocol design constraint.

### Direction 4: Two-sided gap and strict antitonicity off the diagonal
**Hypothesis**: For a strictly negative-diagonal `A`, not only the diagonal but the
entire sequence `k ↦ tropMatPow A k i j` is eventually strictly antitone for every
fixed pair `(i,j)`, with eventual slope equal to the eigenvalue `λ(A) < 0`.
**Test**: Strengthen `tropMatPow_diag_gap` (currently diagonal-only) to a general entry
statement by routing every optimal path through a negative cycle and showing each extra
power can append one more traversal.
**Why now**: The current gap theorem is proven *only* on the diagonal because the
self-loop argument is diagonal-specific; this cycle showed precisely where the argument
stops. The key insight is that any vertex on a negative cycle plays the role the
self-loop plays for the diagonal, so the gap should propagate off-diagonal.
**If false (boundary)**: The result must break exactly when `(i,j)` lies in a part of
the graph not reachable from any negative cycle — characterizing that "frozen" region
is itself the interesting output.

### Direction 5: Robustness of the gap under perturbation
**Hypothesis**: The diagonal gap is `2`-Lipschitz stable: if `‖A - A'‖_∞ ≤ ε` then
`|tropMatPow A k i i - tropMatPow A' k i i| ≤ (k+1)·ε`, so the divergence rate is
robust to bounded noise on the matrix entries.
**Test**: Iterate `tropMatMul_combined_lipschitz` from `Tropical.MinPlusAlgebra` across
the `k` factors of the power and accumulate the per-step Lipschitz constant.
**Why now**: The Lipschitz machinery already exists in the catalog and the power is
literally a `k`-fold product, so the bound should telescope. The key insight is that the
gap is not a fragile algebraic accident but a *metrically stable* feature, which is what
makes it usable in noisy cryptographic or learning settings.
**If true**: It certifies that the one-wayness in Direction 3 survives bounded
implementation noise, connecting this file to the certified-robustness bridge.
**If false**: A super-linear blowup would reveal that tropical iteration amplifies
perturbations, a cautionary result for any min-plus neural layer.
