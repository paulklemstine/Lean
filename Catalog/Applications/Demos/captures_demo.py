#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift

This script demonstrates that backpropagation computes exactly the
cotangent lift (pullback on cotangent bundles) of the forward map.

We build a small 3-layer neural network and show:
1. Forward pass: covariant composition  F = f3 ∘ f2 ∘ f1
2. Backward pass: contravariant composition  F* = f1* ∘ f2* ∘ f3*
3. The backward pass gradient matches the cotangent lift exactly.

The key mathematical identity is contravariant functoriality:
    (g ∘ f)* = f* ∘ g*

This reversal of composition order IS backpropagation.
"""

import numpy as np


def sigmoid(z):
    """Smooth activation function (a diffeomorphism on its image)."""
    return 1.0 / (1.0 + np.exp(-z))


def sigmoid_deriv(z):
    """Derivative of sigmoid — needed for the cotangent lift."""
    s = sigmoid(z)
    return s * (1.0 - s)


def forward_layer(x, W, b):
    """
    A single neural network layer: f(x) = σ(Wx + b).
    In differential geometry terms, this is a smooth map f : ℝⁿ → ℝᵐ.
    """
    z = W @ x + b
    return sigmoid(z), z  # return activation and pre-activation


def cotangent_lift_layer(grad_output, z, W):
    """
    The cotangent lift f* : T*ℝᵐ → T*ℝⁿ for a single layer.

    Given a covector (gradient) α ∈ T*_{f(x)}ℝᵐ, the pullback is:
        f*(α) = α ∘ df_x = (diag(σ'(z)) · W)ᵀ · α

    This is exactly what backprop computes for one layer.
    """
    # σ'(z) · α  — chain rule through the activation
    delta = grad_output * sigmoid_deriv(z)
    # Wᵀ · delta — pullback through the linear map
    grad_input = W.T @ delta
    # Gradient w.r.t. parameters (for learning)
    grad_W = np.outer(delta, np.ones(W.shape[1]))  # simplified
    return grad_input, delta


def main():
    """
    Demonstrate that backpropagation = cotangent lift.

    We verify the key identity numerically:
        Jacobianᵀ · output_gradient  ==  backprop gradient

    The left side is the cotangent lift computed via the full Jacobian.
    The right side is backprop (layer-by-layer cotangent lift).
    They must agree — this is the theorem.
    """
    np.random.seed(42)

    # ─── Network architecture: 3 → 4 → 4 → 2 ───
    # Three layers define a composite smooth map F: ℝ³ → ℝ²
    W1 = np.random.randn(4, 3) * 0.5
    b1 = np.random.randn(4) * 0.1
    W2 = np.random.randn(4, 4) * 0.5
    b2 = np.random.randn(4) * 0.1
    W3 = np.random.randn(2, 4) * 0.5
    b3 = np.random.randn(2) * 0.1

    x = np.array([1.0, -0.5, 0.3])  # Input point on the manifold ℝ³

    # ═══════════════════════════════════════════════════════════
    # FORWARD PASS: Covariant composition F = f₃ ∘ f₂ ∘ f₁
    # This is the tangent functor direction: push forward.
    # ═══════════════════════════════════════════════════════════
    a1, z1 = forward_layer(x, W1, b1)    # f₁: ℝ³ → ℝ⁴
    a2, z2 = forward_layer(a1, W2, b2)   # f₂: ℝ⁴ → ℝ⁴
    a3, z3 = forward_layer(a2, W3, b3)   # f₃: ℝ⁴ → ℝ²

    print("=" * 60)
    print("BACKPROPAGATION AS THE COTANGENT LIFT")
    print("=" * 60)
    print(f"\nInput x = {x}")
    print(f"Output F(x) = {a3}")

    # ═══════════════════════════════════════════════════════════
    # COTANGENT LIFT via full Jacobian (brute force)
    # Compute J = dF_x by finite differences, then J^T · α
    # ═══════════════════════════════════════════════════════════
    eps = 1e-7
    jacobian = np.zeros((2, 3))
    for i in range(3):
        x_plus = x.copy()
        x_plus[i] += eps
        # Recompute forward pass
        a1p, _ = forward_layer(x_plus, W1, b1)
        a2p, _ = forward_layer(a1p, W2, b2)
        a3p, _ = forward_layer(a2p, W3, b3)
        jacobian[:, i] = (a3p - a3) / eps

    # Choose a covector (output gradient) α ∈ T*_{F(x)}ℝ²
    alpha = np.array([1.0, -0.5])  # An arbitrary covector at the output

    # Cotangent lift via Jacobian: F*(α) = Jᵀ · α
    cotangent_via_jacobian = jacobian.T @ alpha

    # ═══════════════════════════════════════════════════════════
    # BACKWARD PASS: Contravariant composition F* = f₁* ∘ f₂* ∘ f₃*
    # This IS the cotangent lift, computed layer by layer.
    # The reversal of order is FORCED by contravariance.
    # ═══════════════════════════════════════════════════════════
    # Start with α at the output (covector in T*ℝ²)
    grad = alpha

    # f₃*: T*ℝ² → T*ℝ⁴  (first in the backward direction)
    grad, _ = cotangent_lift_layer(grad, z3, W3)

    # f₂*: T*ℝ⁴ → T*ℝ⁴
    grad, _ = cotangent_lift_layer(grad, z2, W2)

    # f₁*: T*ℝ⁴ → T*ℝ³  (last in backward = first in forward)
    grad, _ = cotangent_lift_layer(grad, z1, W1)

    cotangent_via_backprop = grad

    # ═══════════════════════════════════════════════════════════
    # VERIFICATION: Both methods agree (up to numerical precision)
    # This is the theorem: backprop == cotangent lift
    # ═══════════════════════════════════════════════════════════
    print(f"\nCovector α at output = {alpha}")
    print(f"\n--- Cotangent lift via full Jacobian (Jᵀα) ---")
    print(f"  F*(α) = {cotangent_via_jacobian}")
    print(f"\n--- Cotangent lift via backprop (f₁* ∘ f₂* ∘ f₃*)(α) ---")
    print(f"  F*(α) = {cotangent_via_backprop}")

    error = np.linalg.norm(cotangent_via_jacobian - cotangent_via_backprop)
    print(f"\n‖difference‖ = {error:.2e}")

    print("\n" + "=" * 60)
    print("KEY INSIGHT:")
    print("=" * 60)
    print("""
Backpropagation computes the cotangent lift F* = f₁* ∘ f₂* ∘ f₃*
by applying each layer's pullback in REVERSE order.

This reversal is not an algorithmic trick — it is a mathematical
necessity. The cotangent bundle is a CONTRAVARIANT functor:

    T* : Man^{op} → VectBun

Contravariance means:  (g ∘ f)* = f* ∘ g*

The backward pass of backprop is simply the categorical statement
that T* reverses arrows. The entire algorithm is encoded in the
word "contravariant."
""")

    if error < 1e-5:
        print("✓ THEOREM VERIFIED NUMERICALLY: backprop = cotangent lift")
    else:
        print("✗ Numerical mismatch (check implementation)")

    # ═══════════════════════════════════════════════════════════
    # Bonus: Show the Jacobian structure
    # ═══════════════════════════════════════════════════════════
    print(f"\nFull Jacobian dF_x (2×3 matrix):")
    print(f"  {jacobian}")
    print(f"\nThe Jacobian factorizes as: dF = df₃ · df₂ · df₁")
    print(f"Backprop computes Jᵀα without ever forming J explicitly.")
    print(f"For networks with millions of parameters, this saves O(n²) memory.")


if __name__ == "__main__":
    main()
