# Future Directions: Fractal Topology in Lean 4

## 1. Box-Counting Dimension as a Metric Invariant

The log-ratio dimension approximant `logRatioDim S ε` defined in this work converges (when the limit exists) to the box-counting dimension. A natural next step is to formalize the box-counting dimension as `limsup` of `logRatioDim` as `ε → 0`, and prove that it is invariant under bi-Lipschitz maps. The key insight is that bi-Lipschitz maps scale covering numbers by at most a constant factor, so the log-ratio is preserved in the limit. Why now? We have `coveringNumber_antitone` and `coverSet_subset_of_le` which provide the monotonicity scaffolding needed for the limsup argument.

## 2. Self-Similar IFS and the Moran Equation

For an iterated function system (IFS) of N contractions each with ratio r satisfying the open set condition, the Hausdorff dimension equals log(N)/log(1/r). The `contraction_comp` and `contraction_iterate` theorems formalized here are the first steps toward proving this. The key insight is that the n-th iteration of the IFS produces N^n pieces each of diameter proportional to r^n, giving covering number bounds that yield the Moran equation in the limit. Why now? The contraction iteration machinery is in place, and Mathlib's measure theory provides the outer measure constructions needed for Hausdorff measure.

## 3. Hausdorff Dimension via Hausdorff Measure

Mathlib already has `MeasureTheory.OuterMeasure` infrastructure. The Hausdorff d-dimensional measure H^d can be defined as the limit of d-dimensional Hausdorff pre-measures (infima over δ-covers weighted by diameter^d). The Hausdorff dimension is then the critical exponent where H^d transitions from ∞ to 0. The key insight is that covering numbers provide explicit upper bounds on Hausdorff measure: if N(S,ε) balls of radius ε cover S, then H^d(S) ≤ N(S,ε) · (2ε)^d, connecting our covering number theory directly to Hausdorff dimension. Why now? The covering number framework and monotonicity results from this file provide the combinatorial backbone, and Mathlib's outer measure API handles the measure-theoretic boilerplate.

## 4. Topological Dimension and the Dimension Gap Theorem

The Lebesgue covering dimension (the minimum n such that every open cover has a refinement with point-multiplicity ≤ n+1) is always ≤ the Hausdorff dimension. This "dimension gap" is strict for fractals like the Cantor set (topological dimension 0, Hausdorff dimension log2/log3). The key insight is that topological dimension is defined purely combinatorially via nerve complexes of covers, while Hausdorff dimension involves metric scaling — formalizing both and proving the inequality would be a bridge between pure topology and metric geometry. Why now? Mathlib has strong simplicial complex and nerve infrastructure that could support the topological dimension side.

## 5. Packing Dimension and Duality with Covering Dimension

The packing dimension, defined via packing numbers (maximum number of disjoint ε-balls centered in S), is dual to the covering dimension. A natural conjecture is: for any totally bounded set S in a metric space, the packing number P(S,ε) and covering number N(S,ε) satisfy N(S,2ε) ≤ P(S,ε) ≤ N(S,ε/2). The key insight is that any maximal ε-packing is automatically a 2ε-cover (by maximality, every point is within 2ε of a packing center), giving a clean duality between the two notions. Why now? Our covering number infrastructure (`coveringNumber_le_of_cover`, monotonicity lemmas) provides the foundation, and the packing-covering duality would immediately give bounds on packing dimension in terms of box-counting dimension.
