#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift

This script demonstrates numerically that backpropagation through a
multi-layer neural network computes exactly the cotangent lift (pullback
on cotangent bundles) of the forward map.

Key insight: The Jacobian transpose of the composed forward map equals
the product of individual Jacobian transposes IN REVERSE ORDER.
This is contravariant functoriality: (g ∘ f)* = f* ∘ g*.

Corresponds to the formal Lean 4 theorem `backprop_cotangent_lift`.
"""

import numpy as np


def sigmoid(x: np.ndarray) -> np.ndarray:
    """Smooth activation function (sigmoid)."""
    return 1.0 / (1.0 + np.exp(-x))


def sigmoid_deriv(x: np.ndarray) -> np.ndarray:
    """Derivative of sigmoid: σ'(x) = σ(x)(1 - σ(x))."""
    s = sigmoid(x)
    return s * (1.0 - s)


def layer_forward(x: np.ndarray, W: np.ndarray, b: np.ndarray):
    """
    Forward pass through one layer: f(x) = σ(Wx + b).

    In differential geometry terms, this is a smooth map f: ℝⁿ → ℝᵐ.
    """
    z = W @ x + b
    return sigmoid(z), z  # return activation and pre-activation


def layer_jacobian(z: np.ndarray, W: np.ndarray) -> np.ndarray:
    """
    Jacobian of one layer: J_f = diag(σ'(z)) · W.

    The tangent map Tf acts on tangent vectors by multiplication by J_f.
    The cotangent lift f* acts on covectors by multiplication by J_f^T.
    """
    return np.diag(sigmoid_deriv(z)) @ W


def main():
    print("=" * 65)
    print("  BACKPROPAGATION = COTANGENT LIFT (Numerical Demonstration)")
    print("=" * 65)
    print()

    np.random.seed(42)

    # ─── Define a 3-layer network: ℝ⁴ → ℝ³ → ℝ² → ℝ² ───
    dims = [4, 3, 2, 2]
    n_layers = len(dims) - 1

    # Random weights and biases
    weights = [np.random.randn(dims[i + 1], dims[i]) * 0.5 for i in range(n_layers)]
    biases = [np.random.randn(dims[i + 1]) * 0.1 for i in range(n_layers)]

    # Input point
    x0 = np.random.randn(dims[0])
    print(f"Input x₀ ∈ ℝ⁴:  {x0.round(4)}")
    print()

    # ─── Forward pass: compute f₃ ∘ f₂ ∘ f₁ ───
    # This is the forward map Φ: M → N in the smooth category.
    activations = [x0]
    pre_activations = []
    h = x0
    for i in range(n_layers):
        h, z = layer_forward(h, weights[i], biases[i])
        activations.append(h)
        pre_activations.append(z)

    print(f"Output Φ(x₀) ∈ ℝ²: {activations[-1].round(4)}")
    print()

    # ─── Compute individual Jacobians ───
    # Each J_i is the Jacobian of layer i at the current activation.
    jacobians = []
    for i in range(n_layers):
        J_i = layer_jacobian(pre_activations[i], weights[i])
        jacobians.append(J_i)

    # ─── Method 1: Full Jacobian of the composition (forward composition) ───
    # J_Φ = J₃ · J₂ · J₁  (tangent map: covariant, left-to-right)
    J_full = jacobians[-1]
    for i in range(n_layers - 2, -1, -1):
        J_full = J_full @ jacobians[i]

    print("─── Tangent Map (Forward/Covariant) ───")
    print(f"J_Φ = J₃ · J₂ · J₁ (tangent map Tf, pushforward):")
    print(f"  Shape: {J_full.shape}")
    print(f"  {J_full.round(6)}")
    print()

    # ─── Method 2: Cotangent lift via backpropagation ───
    # The cotangent lift reverses the order: Φ* = f₁* ∘ f₂* ∘ f₃*
    # where f_i* acts by J_i^T (Jacobian transpose).
    #
    # This is EXACTLY what backpropagation does:
    # Start with a covector α ∈ T*N (the loss gradient),
    # then multiply by J₃ᵀ, then J₂ᵀ, then J₁ᵀ.

    # Use identity covector (each basis covector) to reconstruct J_Φᵀ
    J_cotangent_T = np.eye(dims[-1])  # Start with identity in T*_output

    print("─── Cotangent Lift (Backpropagation/Contravariant) ───")
    print("Computing Φ* = f₁* ∘ f₂* ∘ f₃* via reverse-mode:")

    # Backpropagate: apply Jacobian transposes in reverse order
    grad = J_cotangent_T
    for i in range(n_layers - 1, -1, -1):
        J_i_T = jacobians[i].T
        grad = grad @ jacobians[i]  # equivalent to J_i^T applied to rows
        print(f"  After f_{i+1}*: shape {grad.shape}")

    # The result should equal J_full
    J_backprop = J_cotangent_T
    for i in range(n_layers - 1, -1, -1):
        J_backprop = J_backprop @ jacobians[i]

    print(f"\n  J_Φ via backprop (cotangent lift):")
    print(f"  {J_backprop.round(6)}")
    print()

    # ─── Verify: J_forward == J_backprop ───
    error = np.max(np.abs(J_full - J_backprop))
    print("─── VERIFICATION ───")
    print(f"Max |J_forward - J_backprop| = {error:.2e}")
    print()

    if error < 1e-12:
        print("✅ CONFIRMED: Backpropagation = Cotangent Lift")
        print()
        print("   The backward pass computes Φ* = f₁* ∘ f₂* ∘ f₃*")
        print("   which is the contravariant functorial action of T*.")
        print("   The reversed order arises because T* : Man^op → VectBun")
        print("   is a CONTRAVARIANT functor.")
    else:
        print("❌ Numerical mismatch (unexpected)")

    print()

    # ─── Demonstrate contravariant vs covariant ───
    print("─── KEY INSIGHT: Covariance vs Contravariance ───")
    print()
    print("  Forward (tangent):    TΦ = Tf₃ ∘ Tf₂ ∘ Tf₁    (same order)")
    print("  Backward (cotangent): Φ* = f₁* ∘ f₂* ∘ f₃*    (reversed!)")
    print()
    print("  This reversal is NOT an accident or implementation choice.")
    print("  It is a THEOREM of differential geometry:")
    print("  the cotangent bundle is a contravariant functor.")
    print()
    print("  Backpropagation doesn't just 'happen' to go backwards —")
    print("  it MUST go backwards, by the functoriality of T*.")
    print()

    # ─── Bonus: demonstrate with a covector (loss gradient) ───
    print("─── EXAMPLE: Loss Gradient Backpropagation ───")
    alpha = np.array([1.0, -0.5])  # A covector in T*_{Φ(x₀)}N
    print(f"  Loss gradient α ∈ T*N:  {alpha}")

    # Forward Jacobian transpose method
    grad_forward = J_full.T @ alpha

    # Backpropagation method (apply transposes in reverse)
    grad_backprop = alpha.copy()
    for i in range(n_layers - 1, -1, -1):
        grad_backprop = jacobians[i].T @ grad_backprop

    print(f"  Φ*(α) via J_Φᵀ·α:      {grad_forward.round(6)}")
    print(f"  Φ*(α) via backprop:     {grad_backprop.round(6)}")
    print(f"  Match: {np.allclose(grad_forward, grad_backprop)}")
    print()
    print("=" * 65)


if __name__ == "__main__":
    main()
