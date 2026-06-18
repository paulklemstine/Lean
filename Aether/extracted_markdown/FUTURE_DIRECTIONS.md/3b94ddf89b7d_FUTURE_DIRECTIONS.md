# Future Directions: Certified Novelty Detection in Metric Spaces

## 1. Quantitative Packing Bounds with Covering Numbers

The current framework establishes qualitative novelty certification (ε-separation, diameter bounds). A natural next step is to formalize *covering numbers* N(S, ε) and *packing numbers* M(S, ε) for subsets of metric spaces, and prove the classical sandwich inequality M(S, 2ε) ≤ N(S, ε) ≤ M(S, ε). This would yield explicit cardinality bounds: any mutually ε-separated subset of a ball of radius R in ℝ^d has at most (2R/ε + 1)^d elements.

**The key insight is** that the packing-covering duality transforms our qualitative mutual-separation predicate into a quantitative capacity bound, giving a formal upper limit on how many "genuinely novel" outputs can exist in a bounded region.

**Why now?** Mathlib already has `Metric.ball`, `Bornology.IsBounded`, and basic `Finset` cardinality infrastructure. The ε-net theory in finite-dimensional spaces is well-understood and the combinatorial core (pigeonhole on a grid covering) is within reach of current automation.

## 2. Novelty Persistence Under Lipschitz Maps

If f : α → β is L-Lipschitz and x is ε-novel w.r.t. S in α, then f(x) is (ε/L)-novel w.r.t. f(S) in β. This "novelty transport" theorem would formalize how novelty certificates survive transformations — crucial for applications where theorems are compared via embeddings into a common feature space. The converse direction (lower-Lipschitz / bi-Lipschitz maps preserving novelty) would establish that embeddings don't create spurious novelty.

**The key insight is** that Lipschitz maps contract distances by at most factor L, so novelty thresholds scale predictably — and bi-Lipschitz maps give both upper and lower transport, making the embedding faithful.

**Why now?** Mathlib's `LipschitzWith` and `AntilipschitzWith` API is mature and well-connected to the metric space infrastructure we already use. The proofs should compose cleanly with `novel_triangle_transfer`.

## 3. Adaptive Threshold Selection via Minimum Distance

Define the *novelty score* of x w.r.t. S as inf_{s ∈ S} dist(x, s) (or min for finite S). Formalize this as a function and prove: (a) x is ε-novel iff novelty_score(x, S) ≥ ε, (b) the novelty score is 1-Lipschitz in x, (c) the novelty score is anti-monotone in S. This connects our predicate-based framework to a continuous scoring function suitable for optimization.

**The key insight is** that the novelty score is the distance-to-set function restricted to finite sets, inheriting all its regularity properties (1-Lipschitz, lower semicontinuity) while being computable.

**Why now?** Mathlib has `Metric.infDist` and its Lipschitz properties (`lipschitz_infDist`). Specializing to finite sets and connecting to our `IsNovel` predicate is a clean formalization target.

## 4. Hierarchical Novelty via Ultrametric Trees

For structured theorem spaces where similarity is hierarchical (e.g., theorems about groups are more similar to each other than to theorems about topology), the natural metric is an ultrametric: d(x,z) ≤ max(d(x,y), d(y,z)). In ultrametric spaces, our novelty framework simplifies dramatically: every ball is both open and closed, and the packing bound becomes exact rather than approximate. Formalize ultrametric novelty and prove that the mutual-separation predicate decomposes into independent subtree problems.

**The key insight is** that ultrametric spaces have a canonical tree structure where ε-balls are exactly the nodes at height ε, turning the novelty certification problem into a tree search that avoids the curse of dimensionality.

**Why now?** Mathlib has `Metric.IsUltrametricDist` and basic ultrametric lemmas. The tree decomposition of ultrametric balls is folklore but not yet formalized, making it a genuine contribution.

## 5. Compositional Novelty for Structured Proofs

Theorems are not atomic objects — they have structure (hypotheses, conclusions, proof steps). Define a *compositional novelty score* that decomposes a structured object into components and aggregates component-level novelty. Formalize this for product metric spaces: if (x₁, x₂) is the decomposition and S = S₁ × S₂, prove that novelty in the product relates to component novelties via ε² ≤ ε₁² + ε₂² (for the L² product metric). This would enable modular novelty certification where each component is certified independently.

**The key insight is** that product metric spaces let us decompose novelty certification into independent sub-problems, and the Pythagorean relationship between component and total novelty gives tight, composable bounds.

**Why now?** Mathlib's `PseudoMetricSpace` instances for `Prod` and the `Pi` type are well-developed. The componentwise novelty bounds follow from standard metric inequalities that are already available.
