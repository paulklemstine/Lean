# Future Directions: ReLU Depth Separation — Counting, Robustness, and a Unified Obstruction

This cycle added two self-contained Lean files that extend the tent-map depth
separation of `MachineLearning.ReLUDepthWidth.Basic`:

* **`Oscillation.lean`** proves the dyadic alternation
  `tent^[k](j/2^k) = j mod 2` (`tent_iterate_dyadic`) — the depth-`k` tent
  network is `0` at even dyadic nodes and `1` at odd ones — and derives a
  crossing lower bound: any continuous `ε<1/2` approximant is forced to hit the
  level `1/2` inside *every one* of the `2^k` dyadic subintervals
  (`tent_forces_crossings`). This upgrades "one steep ramp" to "exponentially
  many ramps", and the obstruction is now about *count*, not weight magnitude.

* **`AbstractObstruction.lean`** isolates the single inequality
  `|f a − f b| ≤ K·|a−b| + 2ε` (`twoPoint_gap_le`) behind every Lipschitz
  depth-separation theorem, and back-applies it to BOTH the bounded-range /
  slope-blowup tent map (`tent_depth_separation_via_gap`) and the moderate-slope
  / range-blowup exponential tower (`iterExp_depth_separation`), unifying two
  catalog phenomena under one lemma. It also reads the same slope budget as a
  robustness statement (`tent_adversarial`): a sub-`2^k`-Lipschitz classifier
  has a `2^{-k}`-separated adversarial pair with maximal true-label gap.

All results are axiom-clean (`propext`, `Classical.choice`, `Quot.sound`).
The following directions are testable and falsifiable; each would either close
or expose a gap in the present frontier.

## 1. Exact width lower bound from the crossing count

`tent_forces_crossings` exhibits `2^k` disjoint subintervals each containing a
solution of `g = 1/2`. The missing step to a clean *width* theorem is the
finite combinatorial fact that a continuous piecewise-linear function with `w`
affine pieces solves `g = c` at most `w` times (counting maximal flat segments
once). Combining the two yields `w ≥ 2^k` for any shallow PL network matching
the deep tent — independent of weight magnitudes. **The key insight is** that
the `2^k` *strict sign changes* of `tent^[k] − 1/2` (established here via the
parity of `tent_iterate_dyadic`) are a topological invariant that no
low-piece-count function can reproduce, so crossing number is a magnitude-free
complexity measure. **Why now?** The disjoint witnessing intervals already
exist as a proven `∃`-family; the only new ingredient is a `StrictMonoOn`/
monotone-piece bookkeeping lemma over a `Finset` of breakpoints, which is finite
and inductive — no new analysis is required, just a counting argument layered on
the proven crossings.

## 2. Matching shallow upper bound: quantitative 1-D interpolation

Pair the lower bound with a constructive `O(K/ε)`-width upper bound: the
piecewise-linear interpolant of a `K`-Lipschitz `f` on a uniform mesh of
`N = ⌈K/ε⌉` nodes is itself a width-`N` one-hidden-layer ReLU network, and its
sup error is at most `K·(mesh size) ≤ ε`. With Direction 1 this would pin the
shallow cost at `Θ(K/ε)` against the deep cost `Θ(log(1/ε))`, a two-sided `Θ`.
**The key insight is** that `twoPoint_gap_le` is *tight*: on each mesh cell the
same triangle inequality that lower-bounds error also *upper*-bounds the
interpolation error, so the abstract lemma already contains both halves of the
characterization. **Why now?** `twoPoint_gap_le` is stated in exactly the
pointwise-Lipschitz form that the interpolation error estimate needs, and
Mathlib's `LipschitzWith` plus `Real` interval API supply the per-cell bound;
the construction reuses the proven `tent`-as-ReLU representation for the network
realization.

## 3. Tensorized higher-dimensional separation on `[0,1]^n`

Lift the tent obstruction to `F(x) = ∏ᵢ tent^[k](xᵢ)` on `[0,1]^n`. Local
steepness is multiplicative under tensor products, so `F` has a `2^{nk}`-scale
oscillation that a single shallow layer must resolve along every axis at once,
giving an `ε^{-n}`-type shallow cost versus depth `O(n·log(1/ε))`. **The key
insight is** that the witnessing pair of `twoPoint_gap_le` tensorizes: choosing
`a, b` to differ in one coordinate at distance `2^{-k}` while `F` swings by the
product of the other coordinates' peak values reduces the `n`-D obstruction to
`n` independent 1-D instances of the *already proven* lemma. **Why now?**
Mathlib's `LipschitzWith.prod`/`pi` and `Finset.prod` lemmas transport the 1-D
Lipschitz and endpoint data coordinatewise, so the curse-of-dimensionality
separation is an instantiation of the unified obstruction rather than new theory.

## 4. Robustness certificate: from one adversarial pair to a dense fragility set

`tent_adversarial` produces a single `2^{-k}`-separated input pair on which a
sub-`2^k`-Lipschitz classifier under-separates the true labels. Strengthen it to
a *measure-theoretic* statement: the set of inputs admitting a `2^{-k}`
adversarial perturbation that flips a `1/2`-threshold decision has Lebesgue
measure bounded below by a constant independent of `k`. **The key insight is**
that the `2^k` proven dyadic ramps each carry an interval of width `Θ(2^{-k})`
on which the deep tent moves by `Θ(1)`, so summing `2^k` such ramps gives an
`Θ(1)`-measure fragile region — slope blow-up forces *pervasive*, not isolated,
adversarial sensitivity. **Why now?** The per-interval ramp data is exactly
`tent_iterate_dyadic` plus `tent_eq_two_mul`/`tent_eq_two_sub`; assembling the
intervals into a measurable union and lower-bounding its measure uses only
`MeasureTheory.Measure.iUnion`-style additivity over the proven disjoint cells.

## 5. A common abstraction: obstruction from any witnessed (δ, Δ) pair

`twoPoint_gap_le` already shows that a witnessing pair `(a, b)` with gap
`Δ = |f a − f b|` at distance `δ = |a − b|` defeats every `K`-Lipschitz
`ε`-approximant once `K·δ + 2ε < Δ`. Promote this to a reusable typeclass-free
*record* `SeparationWitness f := {a, b, δ, Δ, hδ, hΔ}` and prove a single
`no_approx_of_witness` that consumes it, then re-derive `tent`, `iterExp`, and
any future example (Direction 3's tensor `F`) as one-line witness constructions.
**The key insight is** that depth separation is *witness-driven*: the entire
phenomenon is carried by a finite tuple of two points and two scalars, so the
right abstraction is data, not a bespoke theorem per function. **Why now?** Both
witnesses already exist as proven facts in `AbstractObstruction.lean`
(`tent_iterate_zero`/`tent_iterate_peak` give the tent witness;
`iterExp_endpoint_gap_pos` gives the tower witness), so packaging them retires
two near-duplicate proofs and makes every future separation a constructor call.
