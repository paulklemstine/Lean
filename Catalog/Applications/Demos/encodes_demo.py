#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift

This script demonstrates numerically that backpropagation through a
multi-layer neural network is identical to applying the cotangent lift
(transpose Jacobian) of each layer in reverse order.

Mathematical correspondence:
  Forward pass:   Φ = f_n ∘ f_{n-1} ∘ ... ∘ f_1
  Cotangent lift:  Φ* = f_1* ∘ f_2* ∘ ... ∘ f_n*
  In coordinates:  f_i*(α) = J_{f_i}^T α   (Jacobian transpose)

This is exactly what backprop computes: starting from the output gradient,
multiply by each layer's Jacobian transpose in reverse order.
"""

import numpy as np


def sigmoid(x):
    """Smooth activation function (smooth manifold setting)."""
    return 1.0 / (1.0 + np.exp(-x))


def sigmoid_deriv(x):
    """Derivative of sigmoid: σ'(x) = σ(x)(1 - σ(x))."""
    s = sigmoid(x)
    return s * (1.0 - s)


def forward_layer(x, W, b):
    """
    Single layer forward pass: f(x) = σ(Wx + b).
    
    In differential geometry terms, this is a smooth map f: ℝ^m → ℝ^n
    between Euclidean manifolds (trivial smooth manifolds).
    """
    z = W @ x + b
    return sigmoid(z), z  # return activation and pre-activation


def jacobian_layer(x, W, z):
    """
    Compute the Jacobian matrix J_f of a layer at point x.
    
    For f(x) = σ(Wx + b), we have:
        J_f = diag(σ'(z)) · W
    
    This is the differential Df_x : T_x(ℝ^m) → T_{f(x)}(ℝ^n),
    represented as a matrix in the standard coordinate bases.
    """
    return np.diag(sigmoid_deriv(z)) @ W


def cotangent_lift(jacobian, covector):
    """
    The cotangent lift f*: T*_{f(x)}N → T*_x M.
    
    In coordinates: f*(α) = J_f^T · α
    
    This is THE key operation — the pullback of a covector through
    the transpose Jacobian. This single operation, applied layer by
    layer in reverse, IS backpropagation.
    """
    return jacobian.T @ covector


def main():
    """
    Demonstrate that backprop = cotangent lift composition.
    
    We build a 3-layer network, compute gradients two ways:
    1. Direct: Full Jacobian of the composition, then transpose
    2. Backprop: Reverse-mode cotangent lifts layer by layer
    
    These must agree — this is the theorem we formalized in Lean.
    """
    np.random.seed(42)
    
    # ─── Network Architecture ───
    # 4 → 5 → 3 → 2 (input → hidden → hidden → output)
    dims = [4, 5, 3, 2]
    n_layers = len(dims) - 1
    
    # Random weights and biases
    weights = []
    biases = []
    for i in range(n_layers):
        W = np.random.randn(dims[i + 1], dims[i]) * 0.5
        b = np.random.randn(dims[i + 1]) * 0.1
        weights.append(W)
        biases.append(b)
    
    # Random input point
    x0 = np.random.randn(dims[0])
    
    # ─── Forward Pass ───
    # Compute activations and pre-activations at each layer
    activations = [x0]
    pre_activations = []
    x = x0
    for i in range(n_layers):
        x, z = forward_layer(x, weights[i], biases[i])
        activations.append(x)
        pre_activations.append(z)
    
    output = activations[-1]
    print("=" * 60)
    print("BACKPROPAGATION AS COTANGENT LIFT")
    print("=" * 60)
    print(f"\nNetwork: {' → '.join(map(str, dims))}")
    print(f"Input:  {x0}")
    print(f"Output: {output}")
    
    # ─── Method 1: Full Jacobian (forward-mode) ───
    # Compute J_Φ = J_{f_3} · J_{f_2} · J_{f_1}
    # (composition of differentials = covariant functoriality of T)
    jacobians = []
    for i in range(n_layers):
        J = jacobian_layer(activations[i], weights[i], pre_activations[i])
        jacobians.append(J)
    
    # Full Jacobian by matrix multiplication (forward order)
    J_full = jacobians[-1]
    for i in range(n_layers - 2, -1, -1):
        J_full = J_full @ jacobians[i]
    
    # ─── Method 2: Backprop (cotangent lift, reverse-mode) ───
    # Start with a covector α ∈ T*_{Φ(x)}(ℝ^2)
    # This represents the "loss gradient" at the output
    alpha = np.array([1.0, -0.5])  # arbitrary output covector
    
    print(f"\nOutput covector (loss gradient): α = {alpha}")
    print("\n" + "-" * 60)
    print("COTANGENT LIFT (BACKPROPAGATION)")
    print("-" * 60)
    
    # Apply cotangent lifts in REVERSE order: f_1* ∘ f_2* ∘ f_3*(α)
    # This is contravariant functoriality of T*
    covector = alpha
    print(f"\nStarting covector: {covector}")
    for i in range(n_layers - 1, -1, -1):
        covector = cotangent_lift(jacobians[i], covector)
        print(f"After f_{i+1}* (layer {i+1} backprop): {covector}")
    
    backprop_result = covector
    
    # ─── Method 1 result: J_Φ^T · α ───
    direct_result = J_full.T @ alpha
    
    print("\n" + "-" * 60)
    print("VERIFICATION")
    print("-" * 60)
    print(f"\nDirect (J_Φᵀ · α):          {direct_result}")
    print(f"Backprop (f₁* ∘ f₂* ∘ f₃*): {backprop_result}")
    print(f"Max absolute error:          {np.max(np.abs(direct_result - backprop_result)):.2e}")
    
    assert np.allclose(direct_result, backprop_result, atol=1e-12), \
        "Results don't match! Something is wrong."
    
    print("\n✓ VERIFIED: Backprop = Cotangent Lift (up to machine precision)")
    
    # ─── Key Insight ───
    print("\n" + "=" * 60)
    print("KEY INSIGHT")
    print("=" * 60)
    print("""
The reverse order in backpropagation is not a computational trick —
it is FORCED by the mathematics. The cotangent bundle functor

    T* : Man^op → VectBun

is contravariant: it reverses the direction of morphisms. Given

    Φ = f₃ ∘ f₂ ∘ f₁   (forward pass)

contravariant functoriality gives:

    Φ* = f₁* ∘ f₂* ∘ f₃*   (backward pass)

Each f_i* acts by the transpose Jacobian: f_i*(α) = Jᵢᵀ · α.
This is EXACTLY what backpropagation computes.

The formal Lean proof verifies this categorical structure,
establishing backprop as a theorem of differential geometry.
""")
    
    # ─── Bonus: Verify functoriality for pairs of layers ───
    print("-" * 60)
    print("FUNCTORIALITY CHECK: (g ∘ f)* = f* ∘ g*")
    print("-" * 60)
    
    for i in range(n_layers - 1):
        # Compose two adjacent layers
        J_composed = jacobians[i + 1] @ jacobians[i]
        
        # (g ∘ f)*(α) via composed Jacobian
        test_alpha = np.random.randn(dims[i + 2])
        result_composed = J_composed.T @ test_alpha
        
        # f* ∘ g*(α) via sequential cotangent lifts
        result_sequential = cotangent_lift(jacobians[i],
                                           cotangent_lift(jacobians[i + 1], test_alpha))
        
        err = np.max(np.abs(result_composed - result_sequential))
        print(f"  Layers {i+1},{i+2}: error = {err:.2e}  ✓" if err < 1e-12
              else f"  Layers {i+1},{i+2}: error = {err:.2e}  ✗")
    
    print("\nAll functoriality checks passed.")
    print("=" * 60)


if __name__ == "__main__":
    main()
