#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift of the Forward Map

This script demonstrates numerically that backpropagation computes
exactly the cotangent lift (pullback on cotangent bundles) of the
forward map in a neural network.

Key insight: For a composition f = f_n ∘ ... ∘ f_1 of smooth layer maps,
the cotangent lift satisfies (f_n ∘ ... ∘ f_1)* = f_1* ∘ ... ∘ f_n*.
This reversal of composition order IS backpropagation.

We verify this by:
1. Constructing a 3-layer neural network with random weights.
2. Computing the forward pass f = f_3 ∘ f_2 ∘ f_1.
3. Computing the Jacobians J_i of each layer.
4. Showing that backprop (reverse-mode) = J_1^T @ J_2^T @ J_3^T
   equals the full Jacobian transpose (J_3 @ J_2 @ J_1)^T.
"""

import numpy as np


def sigmoid(x):
    """Smooth activation function (sigmoid is a diffeomorphism on its image)."""
    return 1.0 / (1.0 + np.exp(-x))


def sigmoid_deriv(x):
    """Derivative of sigmoid: σ'(x) = σ(x)(1 - σ(x))."""
    s = sigmoid(x)
    return s * (1.0 - s)


def forward_layer(x, W, b):
    """
    A single neural network layer: f(x) = σ(Wx + b).

    In differential geometry terms, this is a smooth map f : ℝ^n → ℝ^m
    (assuming σ is smooth, which sigmoid is).
    """
    return sigmoid(W @ x + b)


def jacobian_layer(x, W, b):
    """
    Compute the Jacobian (differential) df_x : T_x(ℝ^n) → T_{f(x)}(ℝ^m).

    For f(x) = σ(Wx + b), the Jacobian is:
        J = diag(σ'(Wx + b)) @ W

    This is the tangent map (pushforward) at x.
    """
    z = W @ x + b
    return np.diag(sigmoid_deriv(z)) @ W


def cotangent_lift(jacobian):
    """
    The cotangent lift f* : T*_{f(x)}(ℝ^m) → T*_x(ℝ^n).

    For a linear map J : V → W, the dual map J* : W* → V*
    is the transpose: J* = Jᵀ.

    In matrix coordinates, pulling back a covector α ∈ (ℝ^m)*
    gives f*(α) = α ∘ J = Jᵀα ∈ (ℝ^n)*.

    THIS IS THE FUNDAMENTAL OPERATION OF BACKPROPAGATION.
    """
    return jacobian.T


def main():
    np.random.seed(42)

    # ─── Network Architecture ───
    # Three layers: ℝ^4 → ℝ^3 → ℝ^3 → ℝ^2
    # Each layer is a smooth map between Euclidean spaces (smooth manifolds).
    dims = [4, 3, 3, 2]
    n_layers = len(dims) - 1

    # Random weights and biases
    weights = [np.random.randn(dims[i+1], dims[i]) * 0.5 for i in range(n_layers)]
    biases = [np.random.randn(dims[i+1]) * 0.1 for i in range(n_layers)]

    # Input point on the manifold M_0 = ℝ^4
    x0 = np.random.randn(dims[0])

    print("=" * 65)
    print("  BACKPROPAGATION AS THE COTANGENT LIFT")
    print("  Numerical Verification of Contravariant Functoriality")
    print("=" * 65)
    print()

    # ─── Forward Pass ───
    # Compute f = f_3 ∘ f_2 ∘ f_1 and record intermediate activations
    activations = [x0]
    for i in range(n_layers):
        activations.append(forward_layer(activations[-1], weights[i], biases[i]))

    print(f"Input  x ∈ ℝ^{dims[0]}:  {x0}")
    print(f"Output y ∈ ℝ^{dims[-1]}: {activations[-1]}")
    print()

    # ─── Compute Jacobians (Tangent Maps) ───
    # J_i = df_i at the appropriate point
    jacobians = []
    for i in range(n_layers):
        J = jacobian_layer(activations[i], weights[i], biases[i])
        jacobians.append(J)

    # Full Jacobian of the composition (tangent map of f)
    # df = J_3 @ J_2 @ J_1  (covariant: same order as forward pass)
    J_full = np.eye(dims[0])
    for J in jacobians:
        J_full = J @ J_full

    print("─── TANGENT MAP (Forward-mode / Covariant) ───")
    print(f"Full Jacobian J = J_3 @ J_2 @ J_1, shape {J_full.shape}:")
    print(J_full)
    print()

    # ─── Cotangent Lift (Backpropagation) ───
    # f* = f_1* ∘ f_2* ∘ f_3*  (contravariant: REVERSED order)
    #     = J_1^T @ J_2^T @ J_3^T
    #
    # This is exactly what backpropagation computes!
    # Starting from a covector at the output (the loss gradient),
    # we pull it back through each layer in reverse order.

    # Method 1: Backprop (cotangent lifts composed in reverse)
    backprop_result = np.eye(dims[-1])  # Start with identity covector basis
    for i in reversed(range(n_layers)):
        # Apply cotangent lift of layer i: multiply by J_i^T on the right
        backprop_result = backprop_result @ jacobians[i]
    # backprop_result^T gives us the cotangent map as a matrix
    cotangent_backprop = backprop_result.T

    # Method 2: Direct transpose of full Jacobian
    cotangent_direct = J_full.T

    print("─── COTANGENT LIFT (Reverse-mode / Contravariant) ───")
    print()
    print("Backprop (f_1* ∘ f_2* ∘ f_3*):")
    print(cotangent_backprop)
    print()
    print("Direct transpose (J_full)^T:")
    print(cotangent_direct)
    print()

    # ─── Verify: Backprop = Cotangent Lift ───
    error = np.max(np.abs(cotangent_backprop - cotangent_direct))
    print(f"Max absolute error: {error:.2e}")
    print()

    if error < 1e-12:
        print("✓ VERIFIED: Backprop exactly computes the cotangent lift!")
    else:
        print("✗ ERROR: Numerical mismatch detected.")
    print()

    # ─── The Key Insight ───
    print("=" * 65)
    print("  KEY INSIGHT")
    print("=" * 65)
    print()
    print("  The cotangent functor T* : Man^op → VectBun is")
    print("  CONTRAVARIANT: it reverses composition order.")
    print()
    print("  For f = f_n ∘ ... ∘ f_1 (forward pass),")
    print("       f* = f_1* ∘ ... ∘ f_n* (backpropagation).")
    print()
    print("  This reversal is not a clever trick — it is a")
    print("  THEOREM of differential geometry. Backpropagation")
    print("  is the unique correct algorithm forced by the")
    print("  contravariant functoriality of cotangent bundles.")
    print()

    # ─── Demonstrate with a concrete loss gradient ───
    print("─── Example: Loss Gradient Pullback ───")
    # Suppose loss L : ℝ^2 → ℝ with gradient ∇L = [1.0, -0.5] at output
    loss_grad = np.array([1.0, -0.5])
    print(f"Loss gradient (covector at output): {loss_grad}")

    # Backprop: pull back through layers in reverse
    grad = loss_grad.copy()
    for i in reversed(range(n_layers)):
        grad = cotangent_lift(jacobians[i]) @ grad
    print(f"Pulled back to input (via backprop):  {grad}")

    # Direct: use full Jacobian transpose
    grad_direct = J_full.T @ loss_grad
    print(f"Pulled back to input (via J^T):       {grad_direct}")
    print(f"Match: {np.allclose(grad, grad_direct)}")
    print()

    # ─── Functoriality Check ───
    print("─── Functoriality: (g ∘ f)* = f* ∘ g* ───")
    # Take f = layer 1, g = layer 2
    J1 = jacobians[0]
    J2 = jacobians[1]
    J_comp = J2 @ J1  # Jacobian of g ∘ f

    cotangent_comp = J_comp.T          # (g ∘ f)*
    cotangent_fg = J1.T @ J2.T         # f* ∘ g*

    print(f"(g ∘ f)* = {cotangent_comp.flatten()}")
    print(f"f* ∘ g*  = {cotangent_fg.flatten()}")
    print(f"Equal: {np.allclose(cotangent_comp, cotangent_fg)}")
    print()
    print("This is the fundamental identity: contravariant functors")
    print("reverse composition. Backprop is forced by mathematics.")


if __name__ == "__main__":
    main()
