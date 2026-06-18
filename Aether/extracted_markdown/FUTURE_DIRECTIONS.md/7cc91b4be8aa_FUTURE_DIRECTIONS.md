# Future Directions: Certified Novelty Detection in Metric Spaces

## 1. Hausdorff Distance Novelty for Convex Bodies

Extend the novelty certification framework from individual points to *sets*,
using Hausdorff distance as the separation metric. For convex bodies in ℝⁿ,
the Hausdorff distance between convex hulls of finite point sets is
computable, and novelty of a new convex body could be certified by showing
its Hausdorff distance exceeds a threshold from all reference bodies.

The key insight is that the Hausdorff distance on compact convex sets in ℝⁿ
forms a proper metric space (Blaschke's selection theorem), so the
noveltyRegion_isOpen theorem lifts to the space of convex bodies, giving
stability of set-level novelty certificates for free.

Why now? Mathlib already has `Metric.hausdorffDist` and basic convexity
infrastructure. The main gap is connecting `hausdorffDist` with `Finset`-based
convex hull computations, which is a tractable formalization target.

## 2. Dimension-Dependent Novelty Bounds via Johnson-Lindenstrauss

Prove that random linear projections ℝⁿ → ℝᵈ (d = O(log |S| / ε²)) preserve
novelty certificates with high probability: if a point is r-novel in the
original space, it remains (1-ε)r-novel in the projection with probability
≥ 1 - δ. This would formalize the theoretical foundation for practical
high-dimensional novelty detection.

The key insight is combining our Lipschitz transfer theorem with the
Johnson-Lindenstrauss lemma: random projections are (1+ε)-Lipschitz with
high probability, so our `lipschitz_novelty_transfer` theorem applies with
K = 1+ε, giving quantitative bounds on the threshold inflation needed.

Why now? The JL lemma itself is not yet in Mathlib but has been formalized
in other proof assistants. Formalizing even a weak version (e.g., for
Gaussian projections) would immediately compose with our framework.

## 3. Novelty Certificates for Riemannian Manifolds

Generalize the framework from metric spaces to Riemannian manifolds, where
the "distance" is geodesic distance. The noveltyRegion_isOpen theorem should
generalize directly since geodesic distance is continuous. The Lipschitz
transfer theorem would apply to smooth maps between manifolds with bounded
differential (where K = sup ‖df‖).

The key insight is that on a complete Riemannian manifold, the geodesic
distance function is 1-Lipschitz in each variable (by the triangle inequality),
so the continuity argument in noveltyRegion_isOpen transfers verbatim. The
interesting new content is bounding the Lipschitz constant of the exponential
map to enable local-to-global certificate transfer.

Why now? Mathlib's manifold infrastructure (`SmoothManifoldWithCorners`,
`ContMDiff`) has matured significantly. The missing piece is a formal
connection between the Riemannian metric tensor and the induced geodesic
distance as a `MetricSpace` instance — a challenging but well-defined target.

## 4. Persistent Novelty and Filtration Stability

Define a *persistent novelty certificate* that tracks how the novelty status
of a point changes as the threshold r varies from 0 to ∞. The "birth time"
of novelty is the infimum of r values for which x is r-novel (i.e., the
distance to the nearest reference point). This connects our framework to
persistent homology — the novelty region for threshold r is the complement
of the Čech complex's union of balls.

The key insight is that our `noveltyRegion_threshold_antitone` theorem already
establishes the filtration structure: {noveltyRegion S r}_{r≥0} is a
decreasing family of open sets. The persistent novelty "barcode" of a point
is simply the interval [d(x, S), ∞), where d(x, S) = inf_{s∈S} d(x, s).
Formalizing this connection would bridge certified novelty detection with
topological data analysis.

Why now? The monotonicity infrastructure is already in place. The key
formalization target is showing that the map r ↦ noveltyRegion S r is
right-continuous in the Hausdorff metric on open sets, which follows from
the continuity of distance functions.

## 5. Compositional Certification with Error Bounds

Extend the composed_novelty_transfer theorem to handle *approximate* Lipschitz
maps — functions that are Lipschitz up to an additive error ε. This models
practical scenarios where embedding functions (e.g., neural networks) satisfy
dist(f(x), f(y)) ≤ K · dist(x, y) + ε rather than exact Lipschitz bounds.
The certificate transfer would then require threshold inflation by both the
multiplicative factor K and the additive error ε.

The key insight is that "approximate Lipschitz" maps compose: if f is
(K₁, ε₁)-approximately Lipschitz and g is (K₂, ε₂)-approximately Lipschitz,
then g ∘ f is (K₂·K₁, K₂·ε₁ + ε₂)-approximately Lipschitz. This
multiplicative accumulation of errors through layers gives concrete bounds on
how many embedding layers can be composed before the certificate becomes
vacuous (threshold exceeds the space diameter).

Why now? The exact Lipschitz composition theorem is already proven. The
approximate version requires only straightforward algebraic manipulation
of the error bounds, making it an immediately tractable extension.
