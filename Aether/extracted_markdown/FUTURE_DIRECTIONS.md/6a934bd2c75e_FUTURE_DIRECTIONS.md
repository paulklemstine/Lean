# Future Directions: Operadic Complexity Bounds

## 1. Tight Depth-Width Product Bounds via Operadic Rank

The current framework proves that complexity ≤ depth × width as an upper bound,
but the interesting question is when this bound is *tight*. We conjecture that
for every compositional system satisfying our axioms, there exists a family of
operations {fₙ} where complexity(fₙ) = Θ(depth(fₙ) × width(fₙ)), i.e., the
depth-width product is achieved up to constant factors.

The key insight is that operadic rank — the minimum number of generators needed
to express an operation — should provide a lower bound on the depth-width product.
If an operation requires r generators in the free operad, then any compositional
system computing it needs depth × width ≥ r.

Why now? The `CertifiedNeuralBlock` instance already achieves tightness by
construction (params = layers × neurons exactly for dense layers). The next step
is proving tightness for the EML chain instance and connecting it to the
Kolmogorov-Arnold decomposition depth from `KolmogorovArnoldEMLDeep.lean`.

## 2. Non-Archimedean Depth Hierarchy via p-adic Valuation

The bridge between `CompositionalComplexity` and `ValuationDepthMeasure` suggests
a strict hierarchy theorem: for each k, there exists a function f with vdepth
exactly k that cannot be computed by any compositional system with depth-width
product < k. This would be a non-Archimedean analogue of the classical circuit
depth hierarchy theorem.

The key insight is that the ultrametric composition law (vdepth(f∘g) ≤
max(vdepth(f), vdepth(g)) + 1) is *strictly cheaper* than the additive bound
from `CompositionalComplexity`, so the gap between these two bounds should yield
separation results. Functions requiring many additive depth steps but few
ultrametric steps are "p-adically simple but classically complex."

Why now? The `StratifiedComputation` structure in `PadicValuationDepth.lean`
already provides the strict hierarchy, and the `ValuationComplexityBridge`
structure connects it to our framework. The missing piece is a concrete
construction of witness functions at each level.

## 3. Tropical Operadic Complexity and Linear Region Counting

The `OperadicDeepLearning/Foundations.lean` file contains tropical operadic
analysis connecting ReLU networks to piecewise-linear functions. We conjecture
that the number of linear regions of a compositional ReLU network is bounded by
∏ᵢ width(layerᵢ)^{depth(layerᵢ)}, and that this bound is tight for generic
weight matrices.

The key insight is that depth and width interact multiplicatively for linear
region counts (each layer can multiply the number of regions by its width),
whereas our complexity bound is additive in depth. This suggests that linear
region counting provides a *different* complexity measure that is exponential
in the depth-width product rather than linear.

Why now? The tropical operadic bridge in `Foundations.lean` already formalizes
the connection between neural operads and piecewise-linear maps. Combining this
with our `CompositionalComplexity` framework would give the first formalized
proof that depth separation in neural networks follows from operadic algebraic
structure.

## 4. Compositional Complexity of EML-KA Decompositions

The EML chain system provides a natural compositional complexity instance
where depth = chainDepth (counting exp/log operations) and width corresponds
to the number of terms in a Kolmogorov-Arnold decomposition. We conjecture that
for monomials x^a · y^b, the EML-KA complexity (minimum Q × maxDepth over all
Q-term EML-KA decompositions) equals exactly max(a, b) + 2.

The key insight is that `monomial_emlka_depth` shows depth 3 suffices with 1 term,
but using more terms (larger Q) might allow lower depth — the question is whether
this tradeoff is strict. If depth can be reduced to 2 with Q = max(a,b) terms,
this would show a genuine depth-width tradeoff within the EML system.

Why now? The `monomialEMLKA` construction in `KolmogorovArnoldEMLDeep.lean`
gives depth 3 with 1 term. The `eml_ka_polynomial_term_bound` theorem shows
M-term polynomials have M-term decompositions. What's missing is the lower
bound: proving that certain functions *require* high depth-width product.

## 5. Categorical Generalization: Operadic Depth as a Functor

The `CompositionalComplexity` typeclass should arise naturally as a lax monoidal
functor from an operad category to (ℕ, ≤, +, ×). Specifically, depth should be
a lax monoidal functor to (ℕ, +) and width should be an oplax monoidal functor
to (ℕ, max). The product bound then becomes the statement that the composite
functor depth × width dominates complexity.

The key insight is that the subadditivity and superadditivity axioms are exactly
the laxness conditions for monoidal functors, and the product bound is a
natural transformation between them. Making this precise would connect our
framework to the categorical theory of operads in Mathlib.

Why now? Mathlib's category theory library has extensive support for monoidal
categories and lax functors. The `NeuralOperad` typeclass from `Foundations.lean`
already captures the operadic structure. The gap is formalizing the measurement
functors and proving they satisfy the required coherence conditions.
