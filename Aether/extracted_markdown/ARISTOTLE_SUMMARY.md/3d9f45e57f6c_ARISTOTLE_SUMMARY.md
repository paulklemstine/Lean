# Summary of changes for run 14b874b5-065f-4bd6-9acb-925fbdb04041
Created `Bridges/SoftRobustness.lean` connecting the tropical certified robustness result (`TropicalDegreeRobustness.lean`) with the softmax-hardmax dequantization (`SatakeEMLBridge.lean`) to establish **SOFT certified robustness bounds**. All theorems compile without `sorry` and use only standard axioms (`propext`, `Classical.choice`, `Quot.sound`).

### Definitions
- **`hardRadius`**: `margin / (2 · max(K, K'))` — the hard robustness radius
- **`softRadius`**: `margin / (2 · softMax(c, K, K'))` — the soft robustness radius

### Proven Theorems

1. **`soft_radius_le_hard_radius`**: The soft radius is at most the hard radius (`r_soft ≤ r_hard`), since `softMax ≥ max`.

2. **`soft_certified_robustness`**: If every component of the classifier is `softMax(c, K, K')`-Lipschitz and the margin is positive, then the classifier is certified robust with the soft radius.

3. **`soft_refines_hard`**: Hard robustness implies soft robustness (monotonicity of `CertifiedRobust` in the radius).

4. **`hard_soft_radius_gap`**: The key gap bound:
   `r_hard - r_soft ≤ margin · log(2) / (2 · c · K · K')`
   This quantifies exactly how much robustness guarantee is lost by using the differentiable softMax approximation, and vanishes as `c → ∞` (zero temperature limit).

5. **`soft_robustness_ratio_bound`**: `softRadius / hardRadius = max(K,K') / softMax(c,K,K')`.

6. **`soft_radius_ratio_lower_bound`**: `softRadius / hardRadius ≥ 1 - log(2) / (c · max(K,K'))`, showing the soft bound converges to the hard bound for large `c`.