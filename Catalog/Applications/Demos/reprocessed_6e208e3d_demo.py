#!/usr/bin/env python3
"""
demo.py — Backpropagation as Cotangent Lift
============================================

This script numerically demonstrates that backpropagation through a
multi-layer neural network is identical to applying the cotangent lift
(transpose Jacobian) of each layer in reverse order.

Key insight from the formal proof:
  The cotangent functor T* is contravariant:
    T*(g ∘ f) = T*f ∘ T*g
  This is exactly the chain rule, and backpropagation implements it.

We verify this by:
  1. Building a simple 3-layer network with smooth activations.
  2. Computing gradients via backpropagation (reverse-mode AD).
  3. Computing the same gradients via explicit cotangent lifts (Jacobian transposes).
  4. Showing they are identical (up to floating-point precision).
"""

import numpy as np

# ─── Activation functions (smooth, for the manifold perspective) ────────────

def sigmoid(x):
    """Smooth activation: the logistic sigmoid σ(x) = 1/(1+e^{-x})."""
    return 1.0 / (1.0 + np.exp(-np.clip(x, -500, 500)))

def sigmoid_deriv(x):
    """Derivative: σ'(x) = σ(x)(1 - σ(x))."""
    s = sigmoid(x)
    return s * (1.0 - s)

# ─── Network definition ────────────────────────────────────────────────────

def make_network(layer_dims, seed=42):
    """
    Create a simple feedforward network.
    Each layer f_i : R^{d_{i-1}} → R^{d_i} is an affine map + sigmoid.
    
    In the cotangent bundle picture:
      - Forward pass computes Φ = f_L ∘ ... ∘ f_1
      - Backward pass computes T*Φ = T*f_1 ∘ ... ∘ T*f_L
    """
    rng = np.random.RandomState(seed)
    weights = []
    biases = []
    for i in range(len(layer_dims) - 1):
        W = rng.randn(layer_dims[i+1], layer_dims[i]) * 0.5
        b = rng.randn(layer_dims[i+1]) * 0.1
        weights.append(W)
        biases.append(b)
    return weights, biases

# ─── Forward pass (computing the composition Φ = f_L ∘ ... ∘ f_1) ──────────

def forward_pass(x, weights, biases):
    """
    Forward pass through the network.
    
    Stores pre-activations (z_i) and activations (a_i) at each layer.
    In differential geometry terms, we are evaluating the composition
    of smooth maps and recording the base points for cotangent computations.
    """
    activations = [x.copy()]
    pre_activations = []
    
    a = x
    for W, b in zip(weights, biases):
        z = W @ a + b          # Affine map: linear part of f_i
        pre_activations.append(z)
        a = sigmoid(z)         # Smooth nonlinearity: completes f_i
        activations.append(a)
    
    return activations, pre_activations

# ─── Backpropagation (the cotangent lift T*Φ) ──────────────────────────────

def backprop(loss_grad, weights, pre_activations):
    """
    Backpropagation = cotangent lift in action.
    
    Given a cotangent vector ξ ∈ T*_{Φ(x)}Y (the loss gradient),
    we compute T*Φ(ξ) = T*f_1 ∘ T*f_2 ∘ ... ∘ T*f_L (ξ).
    
    Each T*f_i is the transpose of the Jacobian df_i,
    applied in REVERSE order — this is the contravariance of T*.
    """
    delta = loss_grad  # ξ: cotangent vector at the output
    weight_grads = []
    
    # Traverse layers in reverse: T*f_L, then T*f_{L-1}, ..., T*f_1
    for i in reversed(range(len(weights))):
        # The Jacobian of sigmoid at z_i (diagonal matrix)
        diag = sigmoid_deriv(pre_activations[i])
        
        # T*σ_i : multiply by the transpose of diag(σ'(z_i))
        # Since it's diagonal, transpose = itself
        delta = delta * diag
        
        # Record the gradient w.r.t. weights (for training)
        weight_grads.insert(0, delta.copy())
        
        # T*W_i : multiply by W_i^T (transpose of the linear map)
        delta = weights[i].T @ delta
    
    return delta, weight_grads

# ─── Explicit cotangent lift via Jacobian transpose ─────────────────────────

def jacobian_of_layer(W, z):
    """
    Compute the full Jacobian of layer f_i at pre-activation z.
    
    f_i(a) = σ(W·a + b), so df_i = diag(σ'(z)) · W
    
    This is the tangent map (pushforward) on tangent spaces.
    """
    diag = np.diag(sigmoid_deriv(z))
    return diag @ W

def cotangent_lift_explicit(loss_grad, weights, pre_activations):
    """
    Compute the cotangent lift explicitly:
      T*Φ = T*f_1 ∘ T*f_2 ∘ ... ∘ T*f_L
    
    Each T*f_i is the TRANSPOSE of the Jacobian df_i.
    We apply them in reverse order (contravariance!).
    """
    xi = loss_grad  # Start with cotangent vector at output
    
    # Apply T*f_i = (df_i)^T in reverse order
    for i in reversed(range(len(weights))):
        J_i = jacobian_of_layer(weights[i], pre_activations[i])
        # Cotangent lift = Jacobian TRANSPOSE
        xi = J_i.T @ xi
    
    return xi

# ─── Main demonstration ────────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("  BACKPROPAGATION AS COTANGENT LIFT")
    print("  Numerical verification of the categorical perspective")
    print("=" * 70)
    print()
    
    # Network architecture: R^4 → R^8 → R^6 → R^3
    # Three layers of smooth maps between manifolds (Euclidean spaces)
    layer_dims = [4, 8, 6, 3]
    weights, biases = make_network(layer_dims)
    
    # Input point x ∈ M_0 = R^4
    x = np.array([1.0, -0.5, 0.3, 0.8])
    
    # Forward pass: compute Φ(x) = (f_3 ∘ f_2 ∘ f_1)(x)
    activations, pre_activations = forward_pass(x, weights, biases)
    output = activations[-1]
    
    print(f"  Network: R^{layer_dims[0]} → R^{layer_dims[1]} → "
          f"R^{layer_dims[2]} → R^{layer_dims[3]}")
    print(f"  Input x = {x}")
    print(f"  Output Φ(x) = {output}")
    print()
    
    # Loss gradient: a cotangent vector ξ ∈ T*_{Φ(x)} R^3
    # (e.g., gradient of MSE loss)
    target = np.array([0.5, 0.5, 0.5])
    loss_grad = 2.0 * (output - target)  # ∇_y L
    
    print(f"  Loss gradient ξ = {loss_grad}")
    print()
    
    # ── Method 1: Backpropagation ──
    bp_result, _ = backprop(loss_grad, weights, pre_activations)
    
    # ── Method 2: Explicit cotangent lift ──
    ct_result = cotangent_lift_explicit(loss_grad, weights, pre_activations)
    
    # ── Comparison ──
    print("  ─── RESULTS ───")
    print()
    print(f"  Backpropagation result:    {bp_result}")
    print(f"  Cotangent lift result:     {ct_result}")
    print(f"  Difference (L∞ norm):      {np.max(np.abs(bp_result - ct_result)):.2e}")
    print()
    
    match = np.allclose(bp_result, ct_result, atol=1e-14)
    
    if match:
        print("  ✓ VERIFIED: Backpropagation = Cotangent Lift")
        print()
        print("  KEY INSIGHT:")
        print("  ─────────────")
        print("  Backpropagation is not just an algorithm — it is the")
        print("  cotangent functor T* applied to the forward composition.")
        print()
        print("  The chain rule  d(g∘f) = dg ∘ df  becomes, on cotangent spaces:")
        print("    T*(g∘f) = T*f ∘ T*g")
        print()
        print("  This REVERSAL OF ORDER is exactly why backprop traverses")
        print("  layers backwards. It's not a trick — it's contravariance")
        print("  of the cotangent functor.")
    else:
        print("  ✗ Mismatch detected (numerical error)")
    
    print()
    
    # ── Verify functoriality: T*(g∘f) = T*f ∘ T*g ──
    print("  ─── FUNCTORIALITY CHECK ───")
    print()
    
    # Compute Jacobians
    J1 = jacobian_of_layer(weights[0], pre_activations[0])
    J2 = jacobian_of_layer(weights[1], pre_activations[1])
    J3 = jacobian_of_layer(weights[2], pre_activations[2])
    
    # T*(f3 ∘ f2 ∘ f1) via full Jacobian
    J_full = J3 @ J2 @ J1
    result_full = J_full.T @ loss_grad
    
    # T*f1 ∘ T*f2 ∘ T*f3 via individual transposes
    result_composed = J1.T @ (J2.T @ (J3.T @ loss_grad))
    
    print(f"  T*(f₃∘f₂∘f₁)(ξ)         = {result_full}")
    print(f"  (T*f₁ ∘ T*f₂ ∘ T*f₃)(ξ) = {result_composed}")
    print(f"  Difference:                {np.max(np.abs(result_full - result_composed)):.2e}")
    
    func_match = np.allclose(result_full, result_composed, atol=1e-13)
    print(f"  Functoriality: {'✓ VERIFIED' if func_match else '✗ FAILED'}")
    print()
    print("=" * 70)

if __name__ == "__main__":
    main()
