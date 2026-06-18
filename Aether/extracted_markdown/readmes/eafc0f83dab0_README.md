# Geodesic Oracle Seekers on the Inverse Stereographic Manifold

## Overview

This module formalizes the construction of **oracle seekers** that optimally solve problems by:

1. **Lifting** the problem from ℝⁿ to Sⁿ via inverse stereographic projection
2. **Navigating** via geodesics (great circles) on the compact sphere
3. **Projecting back** to obtain solutions in ℝⁿ
4. **Converging** in one step via oracle idempotency (O² = O)

## Files

### `Foundation.lean` — Core Theory (Fully Verified, Zero Sorries)
- Oracle foundations: idempotent maps, solution sets, range = fixed points
- Inverse stereographic projection: ℝ → S¹, lands on circle, round-trip identity
- Lifted oracles: preserve S¹, inherit idempotency
- Geodesic distance: pseudometric, triangle inequality, symmetry
- Oracle-geodesic bridge: output has zero distance to its image
- Information gain and Fisher information
- Concrete oracles: constant, clamp, zero, sqrt
- Compactification advantage: all distances < 2π

### `Advanced.lean` — Advanced Theory (Fully Verified, Zero Sorries)
- Oracle lattice: refinement order (preorder)
- Oracle composition algebra
- Binary entropy: non-negativity, H(1/2) = 1 bit
- Convergence: one-step convergence, unique fixed points
- Möbius covariance: composition = matrix multiplication
- Meta-geodesic oracle: selects best oracle from a family
- N-dimensional generalization: ℝⁿ → Sⁿ, sphere landing
- Hypothesis validation: all 8 hypotheses tested and proved

## Key Theorems

| Theorem | Statement | File |
|---------|-----------|------|
| `invStereo_on_circle` | σ⁻¹(t) ∈ S¹ | Foundation |
| `stereo_left_inverse` | σ(σ⁻¹(t)) = t | Foundation |
| `liftOracle_on_circle` | Lifted oracle preserves S¹ | Foundation |
| `geodesicDist_bounded` | d_g(t₁,t₂) < 2π | Foundation |
| `oracle_geodesic_bridge` | d_g(O(x), O²(x)) = 0 | Foundation |
| `infoGain_at_fixed_point` | Info gain = 0 at solutions | Foundation |
| `binaryEntropy_half` | H(1/2) = 1 | Advanced |
| `invStereoN_on_sphere` | ∑(σ⁻¹(x))² = 1 in N-dim | Advanced |
| `mobius_compose` | Möbius composition law | Advanced |
