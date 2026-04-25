#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift

This script demonstrates numerically that backpropagation through a
multi-layer neural network is identical to composing cotangent maps
(transposed Jacobians) in reverse order — the cotangent lift of the
forward map.

Key insight: For a composition f = f_L ∘ ... ∘ f_1, the gradient
(cotangent vector) propagates as:

    ∇_x L = J_1^T · J_2^T · ... · J_L^T · ∇_y L

This is exactly the cotangent map f* = f_1* ∘ f_2* ∘ ... ∘ f_L*,
which reverses the order of composition — the hallmark of a
contravariant functor.
"""

import numpy as np


# ──────────────────────────────────────────────────────────────
# Layer definitions: each layer is a smooth map R^n → R^m
# The cotangent map is the transpose of the Jacobian.
# ──────────────────────────────────────────────────────────────

def layer_forward(W, b, x, activation=None):
    """Forward pass through a single affine layer + optional activation.
    
    Corresponds to the smooth map f: R^n → R^m, f(x) = σ(Wx + b).
    In the cotangent bundle picture, this is a morphism in Man.
    """
    z = W @ x + b
    if activation == 'tanh':
        return np.tanh(z), z
    elif activation == 'sigmoid':
        return 1.0 / (1.0 + np.exp(-z)), z
    else:
        return z, z


def layer_cotangent_map(W, z, upstream_grad, activation=None):
    """Cotangent map (pullback) f*: T*_y R^m → T*_x R^n.
    
    Given an upstream cotangent vector (gradient) α ∈ T*_y R^m,
    computes f*(α) = α ∘ df = J^T α ∈ T*_x R^n.
    
    This IS backpropagation through one layer.
    """
    # Compute diagonal of activation derivative (local Jacobian factor)
    if activation == 'tanh':
        act_deriv = 1.0 - np.tanh(z) ** 2
    elif activation == 'sigmoid':
        s = 1.0 / (1.0 + np.exp(-z))
        act_deriv = s * (1.0 - s)
    else:
        act_deriv = np.ones_like(z)
    
    # The cotangent map: f*(α) = W^T · diag(σ') · α
    # This is exactly the pullback of the cotangent vector.
    local_grad = act_deriv * upstream_grad  # element-wise: diag(σ') · α
    return W.T @ local_grad  # W^T · (diag(σ') · α)


def full_jacobian(f, x, eps=1e-7):
    """Compute the full Jacobian df/dx numerically.
    
    The Jacobian df_p: T_p X → T_{f(p)} Y is the tangent map.
    Its transpose J^T is the cotangent map f*: T*Y → T*X.
    """
    n = len(x)
    y0 = f(x)
    m = len(y0)
    J = np.zeros((m, n))
    for i in range(n):
        x_plus = x.copy()
        x_plus[i] += eps
        J[:, i] = (f(x_plus) - y0) / eps
    return J


def main():
    """Demonstrate that backprop = cotangent lift of forward map."""
    
    np.random.seed(42)
    print("=" * 65)
    print("  BACKPROPAGATION IS THE COTANGENT LIFT OF THE FORWARD MAP")
    print("=" * 65)
    print()
    
    # ── Network architecture ──
    # Three layers: R^4 → R^5 → R^3 → R^2
    # f = f_3 ∘ f_2 ∘ f_1
    dims = [4, 5, 3, 2]
    activations = ['tanh', 'tanh', None]
    
    # Random weights and biases
    weights = []
    biases = []
    for i in range(len(dims) - 1):
        W = np.random.randn(dims[i+1], dims[i]) * 0.5
        b = np.random.randn(dims[i+1]) * 0.1
        weights.append(W)
        biases.append(b)
    
    # Input point x ∈ R^4 (a point on our "manifold")
    x = np.random.randn(dims[0])
    
    # ── Forward pass: compute f(x) and store intermediates ──
    print("1. FORWARD PASS (computing the forward map f: X → Y)")
    print(f"   Input x = {x.round(4)}")
    
    intermediates = [x]
    pre_activations = []
    h = x.copy()
    for i, (W, b, act) in enumerate(zip(weights, biases, activations)):
        h, z = layer_forward(W, b, h, act)
        intermediates.append(h)
        pre_activations.append(z)
        print(f"   Layer {i+1} output: {h.round(4)}")
    
    y = h  # final output
    print(f"   f(x) = {y.round(4)}")
    print()
    
    # ── Loss function: L(y) = ||y||² / 2 ──
    # The gradient dL ∈ T*_y Y is simply y itself.
    loss = 0.5 * np.sum(y ** 2)
    dL_dy = y.copy()  # cotangent vector at y
    
    print("2. LOSS AND COTANGENT VECTOR")
    print(f"   L(f(x)) = ||f(x)||²/2 = {loss:.6f}")
    print(f"   dL ∈ T*_y Y = {dL_dy.round(4)}")
    print()
    
    # ── Method 1: Backpropagation (composing cotangent maps) ──
    # f* = f_1* ∘ f_2* ∘ f_3*  (contravariant: reversed order!)
    print("3. BACKPROPAGATION (composing cotangent maps f_i*)")
    print("   f* = f₁* ∘ f₂* ∘ f₃*  [contravariant functor!]")
    
    grad_backprop = dL_dy.copy()
    for i in reversed(range(len(weights))):
        grad_backprop = layer_cotangent_map(
            weights[i], pre_activations[i], grad_backprop, activations[i]
        )
        print(f"   After f_{i+1}*: {grad_backprop.round(6)}")
    
    print(f"   ∇_x L (backprop) = {grad_backprop.round(6)}")
    print()
    
    # ── Method 2: Direct Jacobian (tangent map, then transpose) ──
    # Compute J = df/dx, then ∇_x L = J^T · dL/dy
    print("4. DIRECT COMPUTATION (full Jacobian J, then J^T · dL)")
    
    def network_forward(x_in):
        h = x_in.copy()
        for W, b, act in zip(weights, biases, activations):
            h, _ = layer_forward(W, b, h, act)
        return h
    
    J = full_jacobian(network_forward, x)
    grad_direct = J.T @ dL_dy
    
    print(f"   Jacobian shape: {J.shape} (tangent map df: TX → TY)")
    print(f"   ∇_x L (J^T · dL) = {grad_direct.round(6)}")
    print()
    
    # ── Comparison ──
    error = np.linalg.norm(grad_backprop - grad_direct)
    print("5. VERIFICATION: BACKPROP = COTANGENT LIFT")
    print(f"   ||backprop - J^T·dL|| = {error:.2e}")
    print(f"   Match: {'✓ YES' if error < 1e-5 else '✗ NO'}")
    print()
    
    # ── Functoriality check ──
    print("6. FUNCTORIALITY CHECK: (g∘f)* = f* ∘ g*")
    print("   Verifying the contravariant functor property...")
    
    # Compose first two layers as g∘f
    def layers_12(x_in):
        h, _ = layer_forward(weights[0], biases[0], x_in, activations[0])
        h, _ = layer_forward(weights[1], biases[1], h, activations[1])
        return h
    
    J_12 = full_jacobian(layers_12, x)  # Jacobian of g∘f
    
    # Individual Jacobians
    J_1 = full_jacobian(
        lambda v: layer_forward(weights[0], biases[0], v, activations[0])[0], x
    )
    h1 = layer_forward(weights[0], biases[0], x, activations[0])[0]
    J_2 = full_jacobian(
        lambda v: layer_forward(weights[1], biases[1], v, activations[1])[0], h1
    )
    
    # Check: J_{g∘f} = J_g · J_f  (tangent maps compose covariantly)
    J_composed = J_2 @ J_1
    tangent_error = np.linalg.norm(J_12 - J_composed)
    print(f"   Tangent:   ||J(g∘f) - J(g)·J(f)|| = {tangent_error:.2e}")
    
    # Check: (g∘f)* = f* ∘ g*  (cotangent maps compose contravariantly)
    test_covector = np.random.randn(dims[2])
    cotangent_composed = J_12.T @ test_covector  # (g∘f)*
    cotangent_sequential = J_1.T @ (J_2.T @ test_covector)  # f* ∘ g*
    cotangent_error = np.linalg.norm(cotangent_composed - cotangent_sequential)
    print(f"   Cotangent: ||(g∘f)*(α) - f*(g*(α))|| = {cotangent_error:.2e}")
    print(f"   Functoriality: {'✓ VERIFIED' if cotangent_error < 1e-5 else '✗ FAILED'}")
    print()
    
    # ── Key insight ──
    print("=" * 65)
    print("  KEY INSIGHT")
    print("=" * 65)
    print()
    print("  Backpropagation is not merely 'the chain rule applied")
    print("  repeatedly.' It is the cotangent lift functor T* applied")
    print("  to the forward map f: X → Y in the category of smooth")
    print("  manifolds.")
    print()
    print("  • Forward pass = covariant tangent functor T (push-forward)")
    print("  • Backward pass = contravariant cotangent functor T* (pullback)")
    print("  • Chain rule = functoriality: (g∘f)* = f* ∘ g*")
    print()
    print("  This reversal of composition order — the defining property")
    print("  of a contravariant functor — is precisely why we traverse")
    print("  the network backwards during gradient computation.")
    print("=" * 65)


if __name__ == '__main__':
    main()
