# Tropical Lipschitz Robustness Certificate

## Summary

We formalize and prove a theorem connecting tropical geometry to certified adversarial robustness of neural network classifiers. The main result establishes that the **tropical degree** of a max-plus polynomial (piecewise-linear classifier) provides a computable Lipschitz constant that yields a certified L∞ robustness radius.

## Main Theorem

**Theorem** (`tropical_robustness_certificate`). Let `w : Fin k → Fin n → ℝ` be weight vectors and `b : Fin k → ℝ` be biases defining `k` affine classifiers `g_i(x) = w_i · x + b_i`. Let `x₀` be a point where classifier `i*` wins with margin `m > 0`:

```
∀ j ≠ i*, g_{i*}(x₀) - g_j(x₀) ≥ m
```

Let `d = max_i ‖w_i‖₁` be the tropical degree. Then for all `x` with `‖x - x₀‖_∞ < m/(2d)`, classifier `i*` still wins:

```
∀ j ≠ i*, g_{i*}(x) > g_j(x)
```

## Correction to the Literature

The commonly stated bound uses radius `m/d`, but the correct bound is `m/(2d)`. The factor of 2 arises because an adversarial perturbation affects *both* the winning function and each competing function. The proof requires bounding:

```
g_{i*}(x) - g_j(x) ≥ [g_{i*}(x₀) - g_j(x₀)] - |perturbation of i*| - |perturbation of j|
                     ≥ m - d·ε - d·ε = m - 2dε
```

where `ε = ‖x - x₀‖_∞`. For this to be positive, we need `ε < m/(2d)`.

## Supporting Lemmas

1. **`dotProd_le_l1Norm_mul_linf`**: Hölder's inequality for ℓ₁/ℓ∞ duality — `|w · x| ≤ ‖w‖₁ · max_i |x_i|`.
2. **`dotProd_sub`**: Linearity of dot product in the second argument.
3. **`affine_perturbation_bound`**: Each affine function's perturbation is bounded by `‖w‖₁ · ‖δ‖_∞`.
4. **`l1Norm_nonneg`**: The L₁ norm is nonneg.

## Significance

1. **Bridging tropical geometry and ML safety**: The theorem shows that algebraic invariants (tropical degree) directly yield safety guarantees (robustness radii).
2. **Computationally tractable**: The tropical degree is a simple sum of absolute weights — no optimization or sampling required.
3. **Formally verified**: The proof is machine-checked in Lean 4 with Mathlib, providing the highest standard of mathematical certainty.
4. **Applicable to ReLU networks**: Since ReLU networks compute piecewise-linear functions (tropical rational functions), this certificate applies to their local behavior.

## Proof Architecture

The proof proceeds in three steps:
1. Bound each affine function's perturbation using the Hölder inequality.
2. Show that when all weights are zero, the perturbation is zero (trivial case).
3. When some weight is nonzero, propagate the strict inequality from the L∞ bound on inputs to get strict inequality on the perturbation, preserving the positive margin.

The key subtlety is that strict inequality `|x_i - x₀_i| < m/(2d)` must be carefully propagated. The proof handles this by case-splitting on whether the weight vector is identically zero, using the existence of a nonzero weight to establish strict inequality via `mul_lt_mul_of_pos_left`.

## File

- `Tropical/NeuralNetworks/TropicalLipschitzCertificate.lean`
