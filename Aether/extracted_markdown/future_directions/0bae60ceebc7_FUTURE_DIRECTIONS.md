# Future Directions — Geodesics and Metric Geometry of Markov Bases

This cycle extended the formal theory of **Markov bases for contingency tables** from
*qualitative* connectivity (`Algebra.MarkovBases.NoThreeWay.noThreeWay_fiber_connected`,
`Algebra.MarkovBases.TwoWay`) to a *quantitative*, metric statement. The new file
`Algebra/MarkovBases/Geodesic.lean` introduces a length-counted walk `Walk u v n` in the
Markov graph of the `2×2×2` no-three-way interaction model and proves that the corner cell
`u 0 0 0` is a graph **isometry** onto an integer interval: the graph distance between any
two equal-margin non-negative tables is *exactly* `|v₀₀₀ − u₀₀₀|` (`noThreeWay_geodesic`),
via a 1-Lipschitz potential lower bound (`walk_corner_bound`) matched by an explicit
length-`|t|` geodesic (`walk_add_smul`). The directions below build on this metric layer.

## 1. The Markov graph of every `2×2×2` fiber is a finite path graph

The natural next theorem is structural: for fixed two-way margins, the Markov graph (vertices
= non-negative tables in the fiber, edges = `±M3`) is isomorphic to a path graph `Pₘ` whose
length `m` equals `(max corner) − (min corner)` over the fiber. Combined with
`noThreeWay_geodesic`, this would give the full **diameter** of each fiber and characterise
the two extreme tables (those with a zero cell), which are the unique degree-one vertices.

The key insight is that `noThreeWay_geodesic` already shows the corner cell is an isometric
embedding into `ℤ`; what remains is to prove the image is a *contiguous* interval, which is
the discrete-convexity computation `twoWay_fiber_card_interval` lifted from `2×2` to the eight
affine-in-`t` cell inequalities of the `2×2×2` model — a pure `omega` argument once the cells
are written as `base + t·M3`.

Why now? The isometry theorem is in hand and the interval lemma already exists one dimension
down, so the path-graph structure is the immediate, low-risk consolidation that turns four
metric facts into a complete classification of the fiber graph.

## 2. Mixing time of the Diaconis–Sturmfels random walk on a fiber

Markov bases exist to drive MCMC sampling: the Diaconis–Sturmfels walk picks `±M3` with equal
probability and moves if the result stays non-negative. On a path graph of length `m` this is
a lazy random walk on `{0,…,m}` with reflecting ends, whose spectral gap and `O(m² log m)`
mixing time are classical. Formalising `mixingTime ≤ C · m²` for the no-three-way fiber would
be the first *quantitative convergence* result for a Markov-basis sampler in Lean.

The key insight is that direction 1 collapses an a-priori 8-dimensional walk to a
one-dimensional birth–death chain indexed by the corner coordinate, so the entire spectral
analysis reduces to the path-graph Laplacian — eigenvalues `2(1 − cos(kπ/m))` — rather than to
the full contingency-table state space.

Why now? Once the fiber is known to be a path graph (direction 1), the hard combinatorics
disappears and the problem becomes a self-contained finite-Markov-chain estimate, for which
Mathlib's growing stochastic-matrix and `Finset` spectral infrastructure is adequate.

## 3. Geodesic theory for the `2×n` two-way independence model

`Algebra.MarkovBases.TwoWay` handles `2×2`; the genuine generalisation is the `2×n`
independence model, whose Markov basis is the set of basic swaps `M(j,k)` on column pairs
`{j,k}`. Here the move lattice has rank `n−1`, the fiber is a higher-dimensional lattice
polytope, and the graph distance is the `ℓ¹`-type cost of rebalancing the first row subject
to column caps — a transportation distance rather than a single absolute difference.

The key insight is that the first row of a `2×n` table with fixed margins is a non-negative
integer vector with fixed sum and per-coordinate upper bounds, so the fiber is an integer
*transportation polytope* slice and the geodesic distance is exactly the minimal number of
unit transports between two such vectors — i.e. half the `ℓ¹` distance of the first rows.

Why now? The `2×2` interval result and the new corner-isometry technique provide the exact
template (potential lower bound + explicit realising walk); replacing the scalar corner by the
first-row vector and `|·|` by `ℓ¹/2` is a direct, well-scoped generalisation.

## 4. Sharp lower bound on Markov complexity for `2×2×n`

The conjecture flagged in `NoThreeWay.lean` is that the `2×2×n` no-three-way model needs the
family of `2×2×2` alternating moves on slice-pairs. Beyond mere existence of a basis, one can
ask for the **Markov complexity**: the largest degree of a move required, and a matching lower
bound showing no smaller-degree basis connects all fibers. The geodesic potential method gives
the lower-bound half for free in each `2×2×2` sub-slice.

The key insight is that a 1-Lipschitz potential per slice-pair (exactly the `walk_corner_bound`
argument, one copy per pair of `k`-layers) yields a vector-valued invariant whose change bounds
walk length from below, turning the connectivity question into an explicit `n−1`-dimensional
lattice-distance computation.

Why now? `walk_corner_bound` is a reusable, parametric potential lemma; instantiating it on
each adjacent slice-pair is mechanical, so the previously open `2×2×n` direction now has a
concrete, falsifiable quantitative target instead of only a yes/no connectivity question.

## 5. Effective Diaconis–Sturmfels for decomposable log-linear models

The deepest direction is to formalise the general principle behind all the above: for a
*decomposable* (graphical) log-linear model, the basic local moves form a Markov basis and the
fiber graph distance decomposes along the junction tree. The `2×2×2` no-three-way model is the
canonical *non*-decomposable boundary case, so proving the decomposable theorem and exhibiting
no-three-way as the first counterexample would frame the whole subject formally.

The key insight is that decomposability lets the global margin map factor through clique-margin
maps, so the corner-isometry / potential argument applies clique-by-clique and the fiber graph
distance is additive over the junction tree — exactly why decomposable models are "easy" and
no-three-way is the textbook hard case.

Why now? With both a complete `2×2` (`TwoWay`) and a complete `2×2×2` (`NoThreeWay` +
`Geodesic`) example formalised, the abstract decomposable framework finally has the two
anchoring instances needed to validate its definitions and to pin down the precise hypothesis
that fails for no-three-way.
