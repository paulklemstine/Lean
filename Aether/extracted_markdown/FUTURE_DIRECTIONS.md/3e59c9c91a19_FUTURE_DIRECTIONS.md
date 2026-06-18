# Future Directions — Tropical Ultrametricity of Arithmetic Height

## Synthesis

This cycle resolved, in the adversarial sense, the central question raised by the
*Tropical ultrametricity of arithmetic height* concept: **the raw arithmetic height
`ratArithHeight q = |q.num| + q.den` is not ultrametric.** The explicit counterexample
`x = 1/2, y = 1/3` (height of `5/6` is `11`, exceeding `max(3,4) = 4`) kills any hope of
a strong triangle inequality for the global height, and we recorded it as a theorem
(`ratArithHeight_not_strong_triangle`) rather than a footnote.

The repair is structural rather than cosmetic. Ultrametricity is a *local* phenomenon:
at each prime `p`, the tropicalized height `tHeight p := padicNorm p` satisfies zero
detection, negation symmetry, and the genuine max-additive law
`tHeight p (x+y) ≤ max (tHeight p x) (tHeight p y)`. The induced distance
`tDist p x y := padicNorm p (x-y)` is a bona fide ultrametric whose closed balls are
nested-or-disjoint (`tBall_subset_of_le_of_inter`, `tBall_eq_of_inter`).

The bridge that ties the two catalog files together is the quantitative domination
`tHeight_le_ratArithHeight : padicNorm p x ≤ (ratArithHeight x : ℚ)` (via the cleaner
`padicNorm_le_den`). The global archimedean height is exactly a *uniform control law*
that simultaneously bounds every local tropical norm — a finite-data shadow of the
product formula.

## Results Summary

* `ratArithHeight_not_strong_triangle` / `not_forall_ratArithHeight_strong_triangle` —
  the raw height violates the ultrametric inequality (falsification).
* `tHeight_eq_zero_iff`, `tHeight_neg`, `tHeight_strong_triangle` — the per-prime
  tropical height is a non-archimedean size function.
* `padicNorm_le_den`, `tHeight_le_ratArithHeight` — the local-norm ≤ global-height
  bridge.
* `tDist_self`, `tDist_comm`, `tDist_eq_zero_iff`, `tDist_ultrametric` — `tDist p` is an
  ultrametric.
* `tBall_subset_of_le_of_inter`, `tBall_eq_of_inter` — balls are nested-or-disjoint, the
  hierarchical-clustering backbone.

All theorems compile `sorry`-free over Mathlib `v4.28.0`, depending only on the standard
axioms (`propext`, `Classical.choice`, `Quot.sound`, plus `Lean.ofReduceBool` for the
`native_decide` counterexample).

## Research Directions

### 1. The product formula recovers the height up to bounded archimedean defect
The local norms `padicNorm p` we proved are bounded by the height; the converse
aggregation should be quantitative. Conjecture: there are absolute constants such that
`ratArithHeight x` is comparable to `|x|_∞ · ∏_{p} padicNorm p x⁻¹` over primes dividing
the denominator, i.e. the height is the archimedean completion of the tropical data. The
key insight is that the denominator factor `x.den` is *exactly* `∏_p p^{padicValNat p x.den}`,
so `padicNorm_le_den` is tight prime-by-prime and the only slack is the numerator's
archimedean size. Why now? We already have `padicNorm_le_den` as the per-prime tight half;
multiplying the finitely many non-trivial places is a finite-support `Finset.prod`
argument that Mathlib's `Rat.den` factorization API directly supports — falsifiable by a
single rational whose two sides differ by more than the conjectured constant.

### 2. The arithmetic balls realize an exact ultrametric hierarchy with computable VC bound
The nested-or-disjoint theorem makes `{tBall p x r}` a laminar family. Conjecture: for a
finite sample `S ⊆ ℚ` of height `≤ H`, the number of distinct `p`-adic balls meeting `S`
is `O(|S| · log_p H)`, giving a pseudo-dimension surrogate that plugs straight into the
`ArithmeticVCDim` Sauer–Shelah pipeline. The key insight is that
`tHeight_le_ratArithHeight` caps the achievable radii at `log_p H` scales, so the laminar
tree has bounded depth and bounded branching. Why now? Both endpoints already exist in the
catalog — `ArithmeticVCDim.ratArithHeight` height stratification and our laminar ball
family — so the missing step is a counting lemma over a finite `Finset ℚ`, which is
falsifiable by exhibiting a sample forcing more balls than the bound.

### 3. The tropical height is a nonexpanding functor into `TropicalValuationObject`
`CategoricalTropicalUltrametric` packages ultrametric seminorms as objects. Conjecture:
the assignment `p ↦ (ℚ, tDist p)` extends to a functor from the poset of primes (under no
relation, i.e. a discrete bridge) into `UltraNormObj`, and every arithmetic translation
`x ↦ x + c` is a nonexpanding morphism: `tDist p (x+c) (y+c) = tDist p x y`. The key
insight is that translation invariance is immediate from `tDist p x y = padicNorm p (x-y)`
since `(x+c)-(y+c) = x-y`, so the morphism axioms reduce to the already-proven
`tDist_ultrametric` and symmetry. Why now? The target structure `UltraNormObj` is fully
formalized in the catalog, and our `tDist` lemmas are exactly its field obligations —
falsifiable if any structure field fails to typecheck against the existing definition.

### 4. A normalized logarithmic height is sub-additive but never strongly so
Define `logHeight x := Real.log (ratArithHeight x)`. Conjecture: `logHeight` satisfies the
*weak* triangle inequality `logHeight (x+y) ≤ logHeight x + logHeight y + log 2` but
provably fails the strong one on a dense set of pairs, sharply separating the archimedean
height from the tropical norms. The key insight is that the failure direction is the same
multiplicative obstruction we isolated (`H(1/2+1/3) = 11 ≈ H(1/2)·H(1/3) = 12`), so the
additive log version inherits a `+log 2`-type defect rather than a max law. Why now? The
counterexample machinery is already in place, and the multiplicative bound
`ratArithHeight (x+y) ≤ 2 · ratArithHeight x · ratArithHeight y` is a finite `omega`/`nlinarith`
target on numerators and denominators — falsifiable by any pair violating the factor `2`.

### 5. Mixed-place metrics interpolate between tropical and archimedean regimes
For a finite set `T` of primes and weights, define `dT x y := max_{p ∈ T} w_p · padicNorm p (x-y)`.
Conjecture: `dT` is ultrametric for every `T` (max of ultrametrics with positive weights),
but the *sum* `∑_{p∈T} w_p · padicNorm p (x-y)` is only a metric, and the gap between them
quantifies how much archimedean behaviour `T` injects. The key insight is that `max` of
strong triangle inequalities is again strong while `∑` degrades to the ordinary triangle
inequality — so the tropical/archimedean dichotomy is precisely the `max`-vs-`sum`
dichotomy from `Computation/PadicValuationDepth.lean`'s composition law. Why now? Our
single-prime `tDist_ultrametric` is the base case, and `Finset.max'`/`Finset.sup` over `T`
lifts it mechanically — falsifiable by three rationals on which the summed version beats a
true ultrametric bound.
