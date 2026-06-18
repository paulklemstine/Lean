# Future Directions — Tropicalized Myhill–Nerode Pseudometrics

## Synthesis

This cycle built a genuine **quantitative bridge** between the catalog's two
previously disjoint halves: the coalgebraic neural Myhill–Nerode apparatus
(`Bridges/CoalgebraicNeuralMyhillNerode.lean`: `NeuralObservationSystem`,
`neural_behavior`, `neural_derivative`, `neural_equiv`) and the
tropical/ultrametric interface (`Bridges/CategoricalTropicalUltrametric.lean`:
`TropicalValuationObject`, idempotent `max`-addition). The new file
`Bridges/TropicalNeuralMyhillNerodeMetric.lean` metrizes observational
distinguishability by a depth-graded discrepancy `obsDist N x y w = (1/2)^|w|`
(when behaviors split on context `w`, else `0`), aggregated *tropically*
(`⊕ = max`, i.e. `iSup`) into `tropDist N x y`, valued in the order-complete
idempotent codomain `ℝ≥0∞`.

## Results Summary

All proven unconditionally, depending only on `propext`, `Classical.choice`,
`Quot.sound`:

1. `tropDist_self` — reflexivity `d x x = 0`.
2. `tropDist_comm` — symmetry `d x y = d y x`.
3. `tropDist_ultratriangle` — **tropical/ultrametric** triangle `d x z ≤ max (d x y) (d y z)`.
4. `tropDist_triangle` — ordinary triangle `d x z ≤ d x y + d y z` (dominated by the tropical one).
5. `tropDist_deriv_le` — the neural derivative is **2-Lipschitz**: `d (∂ₐ x) (∂ₐ y) ≤ 2 · d x y` (sharp).
6. `tropDist_eq_zero_iff` — **exact collapse**: `d x y = 0 ↔ neural_equiv N x y`. The zero-fiber
   of the pseudometric is *exactly* the coalgebraic Myhill–Nerode quotient, with **no**
   separation/richness hypothesis, because the discrepancy is read off `neural_behavior`.

The decisive surprise was negative-turned-positive: naive non-expansiveness of
`neural_derivative` is **false** (prepending a symbol shifts a distinguishing word
one level shallower, doubling its weight), and the honest sharp constant is `2`.
This pins down the exact Lipschitz geometry of coalgebraic dynamics under the
non-archimedean metric.

---

## Direction 1 — Upgrade the order-valued shadow to a true `TropicalValuationObject`

We worked in `ℝ≥0∞` with `(max, +)`, the *order-valued shadow* of a tropical
semiring; we did not instantiate `TropicalValuationObject` from
`CategoricalTropicalUltrametric.lean` because `ℝ≥0∞` lacks a single element that
is both `⊕`-neutral (bottom for `max`) and `⊗`-absorbing. Conjecture: the carrier
`WithBot ℝ≥0∞` (adjoining a tropical `-∞`) carries a `TropicalValuationObject`
instance with `⊕ = max`, `⊗ = +`, `zero = ⊥`, `one = 0`, and the embedding
`(↑) : ℝ≥0∞ → WithBot ℝ≥0∞` sends `tropDist` to a value for which
`tropDist_ultratriangle` is *literally* the object's `add_eq_max'` triangle law.
**The key insight is** that the metric never attains `-∞`, so the obstruction
(the missing absorbing/neutral coincidence) lives entirely outside the image of
`tropDist` and is removed for free by one bottom-adjunction. **Why now?** Both
endpoints already exist and are vetted in the catalog; this is the smallest
possible step that turns an informal "tropical shadow" into a checked functor
into the existing `TropicalValuationObject` API, making the bridge load-bearing
for downstream `UltraNormObj` transfer lemmas. Falsifiable: either the instance
typechecks and `tropDist_ultratriangle` factors through `add_eq_max'`, or some
axiom (`mul_zero`, `add_zero`) genuinely fails on `WithBot ℝ≥0∞`.

## Direction 2 — The cons/guard map is an exact 1/2-contraction (and the derivative is its left inverse)

Define `guard a : σ → σ` only abstractly via behavior: prepending `a` to every
context. Conjecture: there is a "prepend" semantics for which
`d (guard a x) (guard a y) = (1/2) · d x y` *exactly* (not merely `≤`), and
`neural_derivative` post-composes it to the identity on the behavior class,
explaining the sharp factor `2` of `tropDist_deriv_le` as the inverse contraction
ratio. **The key insight is** that `obsDist (guard a x) (guard a y) w` is supported
only on contexts beginning with `a` and there equals `(1/2)·obsDist x y (tail)`, so
the supremum scales by exactly `1/2` — the Banach contraction constant of the
coalgebra's structure map. **Why now?** It converts the cycle's "failure analysis"
into a positive theorem and connects directly to `Bridges/BanachFixedPointBridge.lean`:
final-coalgebra semantics becomes the unique fixed point of a `1/2`-contraction,
giving an honest fixed-point route to behavioral equivalence. Falsifiable by a
3-state machine where the contraction ratio is computed and compared to `1/2`.

## Direction 3 — Truncated-depth pseudometrics converge and bound the partition-refinement budget

Define `tropDist_le k x y = ⨆ {w // |w| ≤ k} , obsDist x y w`, the budget-`O(|α|^k)`
finite approximation. Conjecture: `tropDist_le k` increases to `tropDist` with the
quantitative rate `tropDist x y − tropDist_le k x y ≤ (1/2)^{k+1}`, and
`tropDist_le k x y = 0 ↔ neural_equiv_upto N k x y` (the catalog's existing
finite-depth equivalence). **The key insight is** that the depth weighting makes
the tail of the supremum a geometric series, so a *finite* observation budget
certifies distance to *exponential* precision — exactly the post-quantum
"O(|α|^k) observation budget" promised informally in
`CoalgebraicNeuralMyhillNerode.lean`, now with a proven error bar. **Why now?**
`neural_equiv_upto` and its stabilization lemmas already exist in the catalog;
this direction wires them to a metric convergence rate, turning partition
refinement into an anytime algorithm with certified approximation error.
Falsifiable: exhibit states whose distance gap exceeds `(1/2)^{k+1}` at some `k`.

## Direction 4 — Quotient isometry: `tropDist` descends to a true metric on the Nerode quotient

By `tropDist_eq_zero_iff`, `tropDist` is constant on `neural_setoid` classes.
Conjecture: it descends to the quotient `σ / neural_setoid` as a genuine
*metric* (not merely pseudometric) satisfying the strong/ultrametric triangle
inequality, making the canonical compressed realization of
`CoalgebraicNeuralMyhillNerode.lean` into an **ultrametric space** whose points
are minimized neural states. **The key insight is** that the Myhill–Nerode
quotient is not just a set of equivalence classes but the *underlying set of an
ultrametric space*, so minimization and metric geometry are the same operation.
**Why now?** The quotient construction (`neural_setoid`, minimality/uniqueness
theorems) is already in the catalog; adding the descended ultrametric upgrades
"minimal automaton" to "ultrametric completion", opening the door to
fixed-point/completeness arguments and to Mathlib's `EMetricSpace` API.
Falsifiable: the descended map fails `d [x] [y] = 0 → [x] = [y]` (it cannot, by
the collapse theorem) or fails the `EMetricSpace` axioms.

## Direction 5 — Lipschitz robustness transfer to certified ML compression

The catalog advertises `lipschitz`, `robustness`, `compression`, `certified`.
Conjecture: for any two neural observation systems related by a behavior-preserving
simulation, the induced map on states is `1`-Lipschitz for `tropDist`, and hence
compression-by-quotient is a *non-expansive certified transformation*: nearby
behaviors stay nearby after minimization, with the constant `2` of
`tropDist_deriv_le` controlling how a single gradient/derivative step can amplify
state separation. **The key insight is** that adversarial state perturbations are
exactly small-`tropDist` perturbations, so a certified robustness radius is a
`tropDist`-ball, and the proven Lipschitz bounds compose into end-to-end
certificates across layers (each `neural_derivative` step costs at most a factor
`2`). **Why now?** This fuses the metric proven here with the
`CategoricalTropicalUltrametric.lean` "bounds transfer functorially" thesis and
the `Computation/PadicValuationDepth.lean` ultrametric-Lipschitz machinery,
yielding the catalog's stated grand goal — an algorithmic pipeline from
coalgebraic observations to compressed, *robustness-certified* tropical state
spaces. Falsifiable: a depth-`k` network whose end-to-end separation amplification
exceeds the predicted `2^k` Lipschitz product.
