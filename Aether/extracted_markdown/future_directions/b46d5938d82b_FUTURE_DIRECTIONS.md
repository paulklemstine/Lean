# Future Directions for Idempotent Kantorovich–Rubinstein Theory

## 1. Strong Duality (Primal = Dual)

The central open formalization challenge: prove that the max-plus transport cost
`C(π) = max_{x,y}(π(x,y) + d(x,y))` equals the KR dual discrepancy
`sup_{f 1-Lip}(Λ_μ(f) - Λ_ν(f))`. We proved the measure-Lipschitz bound
(discrepancy ≤ max(μ-ν)) and the coupling-mode correspondence, but the full
primal–dual equality requires a constructive argument: either building an
optimal 1-Lipschitz witness from a coupling, or constructing an optimal coupling
from a separating test function.

**Approach**: For finite spaces, this may reduce to a max-plus linear programming
problem. The c-transform approach (defining f^c(y) = min_x(d(x,y) - f(x)))
should characterize optimal potentials in the tropical setting.

## 2. Entropic/Idempotent Regularization

Add a "tropical entropy" penalty to the primal:
```
W_ε(μ,ν) = inf_π [max_{x,y}(π(x,y) + d(x,y)) - ε · H_trop(π)]
```
where `H_trop(π) = max_{x,y} π(x,y)` is the tropical entropy.
This should smooth the optimization landscape and admit a tropical Sinkhorn
algorithm for computation.

## 3. Geodesics and Interpolation of Maxitive Measures

Define geodesics in the space of maxitive probability profiles:
given μ₀ and μ₁, find a path μ_t that minimizes the "action" in the
tropical Wasserstein metric. For support profiles, this should reduce to
Hausdorff geodesics (Minkowski sums with appropriate scaling).

## 4. Tropical Sinkhorn-like Algorithms

Develop iterative algorithms for computing:
- The KR dual distance (alternating optimization over 1-Lip functions)
- Optimal couplings (tropical matrix scaling)
- Kernel mean embeddings (fixed-point iteration)

The max-plus structure should allow O(n²) per iteration with
guaranteed convergence in finite dimensions.

## 5. Categorical Enrichment

Formalize the category of compact metric spaces enriched over
maxitive measures:
- Objects: compact metric spaces X with MaxitiveProb(X)
- Morphisms: 1-Lipschitz maps T : X → Y
- Functoriality: T#μ is nonexpansive in the KR metric

Prove that this forms a monoidal category with the product metric
and product maxitive profiles.

## 6. Kernel Witness Optimization

Connect the KR distance to kernel mean embeddings more tightly:
- Prove that when the kernel is 1-Lipschitz in each variable,
  the KME distance bounds the KR distance from above
- Show that "characteristic" kernels (those whose KME is injective)
  provide isometric embeddings when they represent all 1-Lip functions
- Develop witness extraction algorithms: given two profiles μ ≠ ν,
  find a kernel witness f achieving the KR supremum

## 7. Connections to Hausdorff Distance

For "crisp" maxitive profiles (0 on a set, -∞ elsewhere),
the KR discrepancy should collapse to the directed Hausdorff distance.
Formalize:
```
iKRDual(1_A, 1_B) = directed_Hausdorff(A, B)
```
This connects the tropical transport theory to classical set-valued analysis.
