# Future Directions for Tropical Kernel Mean Embedding Theory

## 1. Tropical MMD and Witness Pseudometric

Define a **tropical maximum mean discrepancy** between weight profiles:

```
tropMMD(k, w₁, w₂) = sup_y |tropKME(k, w₁, y) - tropKME(k, w₂, y)|
```

This gives a pseudometric on the space of tropical distributions. When the kernel is separating, this becomes a metric. Key questions:
- Characterize when `tropMMD` is a metric (not just a pseudometric) for finite real-valued kernels
- Prove the triangle inequality (should follow from the sup of pointwise differences)
- Develop finite-sample bounds: given oracle access to two maxitive measures, how many samples are needed to estimate their tropical discrepancy?

## 2. Extended-Real Kernels and Universal Separation

The current formalization uses `k : α → α → ℝ`, but no real-valued kernel is separating on types with `|α| ≥ 2`. The natural fix is to allow `k : α → α → EReal` (or `WithBot ℝ`), which enables:
- The **tropical Dirac kernel** (`k(x,y) = 0` if `x = y`, `⊥` otherwise) which gives trivial reconstruction
- More interesting **tropical Gaussian kernels** that decay to `⊥` at large distances
- A classification theorem: characterize which extended-real kernels are separating

The arithmetic complications with `EReal` subtraction (especially `⊥ - ⊥ = ⊥`) need careful handling in the formalization.

## 3. Compact-Space Extension via Upper Semicontinuous Weights

Extend from finite types to compact Hausdorff spaces:
- Replace `Fintype α` with `CompactSpace α` and `TopologicalSpace α`
- Weight profiles become upper semicontinuous functions `α → EReal`
- The `iSup` in `tropKME` becomes a topological supremum (attained by compactness + USC)
- The Galois connection should extend with appropriate topological hypotheses
- Connect to existing Mathlib theory of semicontinuous functions

## 4. Tropical Neural Feature Maps and Morphological Convolutions

The tropical KME has a natural interpretation as a **morphological dilation**:

```
tropKME(k, w, y) = (w ⊕_k)(y) = sup_x (w(x) + k(x,y))
```

This is exactly the dilation of `w` by the structuring element `k`. Connect to:
- **Mathematical morphology**: erosion (residuation), opening, closing operators
- **Tropical neural networks**: ReLU networks compute piecewise-linear functions that can be viewed as tropical polynomials; the KME is a single-layer tropical neural network
- **Feature maps**: define `φ_k(x) = k(x, ·)` and show that `tropKME(k, w) = sup_x (w(x) + φ_k(x))`

## 5. Categorical Adjunction Between Maxitive Measures and Tropical Profiles

Formalize the categorical structure:
- Objects: finite types equipped with weight profiles (tropical distributions)
- Morphisms: monotone maps that preserve the max-plus structure
- The embedding `Φ : (α → EReal) → (α → EReal)` and residuation `Ψ : (α → EReal) → (α → EReal)` form an adjunction `Φ ⊣ Ψ` in the poset-enriched category of `α → EReal` with pointwise order
- The monad `Ψ ∘ Φ` is a closure operator; its fixed points are the "tropical kernel representable" profiles
- Connect to idempotent analysis and Maslov dequantization

## Additional Research Questions

- **Algorithmic complexity**: What is the complexity of computing the tropical KME and its residuation for structured kernels (e.g., kernels with bounded treewidth)?
- **Approximation**: Can the tropical KME be approximated by random features, analogous to random Fourier features for classical KME?
- **Learning**: Given samples from a maxitive measure, learn the weight profile by inverting the tropical KME. This is a max-plus regression problem.
- **Tropical hypothesis testing**: Use the tropical discrepancy as a test statistic for distinguishing two maxitive measures, with connections to robust statistics.
