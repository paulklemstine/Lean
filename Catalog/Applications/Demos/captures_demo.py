#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift

This script demonstrates numerically that backpropagation through a
multi-layer neural network computes exactly the same result as composing
cotangent lifts (transpose Jacobians) in reverse order.

Mathematical correspondence:
  Forward pass:  f = f_3 ∘ f_2 ∘ f_1
  Backprop:      f* = f_1* ∘ f_2* ∘ f_3*   (cotangent lift = Jacobian transpose)

We verify this for a concrete 3-layer network with random weights and
ReLU activations, showing that:
  1. Manual backprop (composing Jacobian transposes in reverse) matches
  2. The full Jacobian transpose of the composed map

This is the chain rule for cotangent maps — contravariant functoriality of T*.
"""

import numpy as np


def relu(x):
    """ReLU activation — piecewise linear, corresponding to tropical max."""
    return np.maximum(0, x)


def relu_jacobian(x):
    """Jacobian of ReLU: a diagonal matrix of step functions.

    In tropical geometry terms, this is the indicator of the 'max' branch.
    """
    return np.diag((x > 0).astype(float))


def affine_layer(W, b, x):
    """Forward pass through one affine layer: f(x) = Wx + b."""
    return W @ x + b


def layer_jacobian(W, x_pre_activation):
    """Jacobian of a ReLU(Wx + b) layer.

    J = diag(ReLU'(Wx+b)) @ W

    This is the tangent map df at the given input.
    """
    return relu_jacobian(x_pre_activation) @ W


def cotangent_lift(J):
    """Cotangent lift of a linear map with Jacobian J.

    The cotangent lift is simply the transpose: f* = Jᵀ.
    This is because for covector α and tangent vector v,
    (f*α)(v) = α(J·v) = (Jᵀα)·v, so f*α = Jᵀα.
    """
    return J.T


def main():
    np.random.seed(7)

    # ─── Network Architecture ───────────────────────────────────
    # 4 → 5 → 3 → 2  (three layers)
    dims = [4, 5, 3, 2]
    n_layers = len(dims) - 1

    # Random weights and biases (scaled to keep activations positive)
    weights = [np.random.randn(dims[i+1], dims[i]) * 0.5 for i in range(n_layers)]
    biases = [np.abs(np.random.randn(dims[i+1])) * 0.5 for i in range(n_layers)]

    # Random input (positive to help activations survive ReLU)
    x = np.abs(np.random.randn(dims[0])) + 0.5

    print("=" * 60)
    print("  BACKPROPAGATION = COTANGENT LIFT")
    print("  Contravariant Functoriality of T*")
    print("=" * 60)
    print()

    # ─── Forward Pass ───────────────────────────────────────────
    # Compute activations and pre-activations at each layer
    activations = [x]
    pre_activations = []

    current = x
    for i in range(n_layers):
        pre_act = weights[i] @ current + biases[i]
        pre_activations.append(pre_act)
        current = relu(pre_act)
        activations.append(current)

    output = current
    print(f"Input:  {x}")
    print(f"Output: {output}")
    print()

    # ─── Compute Layer Jacobians (Tangent Maps) ─────────────────
    # Each df_i is the tangent map of layer i
    jacobians = []
    for i in range(n_layers):
        J = layer_jacobian(weights[i], pre_activations[i])
        jacobians.append(J)

    # ─── Method 1: Full Jacobian of Composed Map ────────────────
    # J(f) = J(f_3) @ J(f_2) @ J(f_1)  (chain rule, forward order)
    J_full = np.eye(dims[-1])
    for i in range(n_layers - 1, -1, -1):
        J_full = J_full  # identity on first iteration
        break
    J_full = jacobians[-1]
    for i in range(n_layers - 2, -1, -1):
        J_full = J_full @ jacobians[i]

    print("─── Tangent Map (Forward Composition) ───")
    print(f"J(f₃ ∘ f₂ ∘ f₁) = J(f₃) · J(f₂) · J(f₁)")
    print(f"Shape: {J_full.shape}")
    print()

    # ─── Method 2: Cotangent Lift (Backpropagation) ─────────────
    # f* = f₁* ∘ f₂* ∘ f₃*  (reverse order — contravariance!)
    # For a covector α at the output, backprop computes:
    #   α → J₃ᵀα → J₂ᵀ(J₃ᵀα) → J₁ᵀ(J₂ᵀ(J₃ᵀα))
    # This is (J₁ᵀ · J₂ᵀ · J₃ᵀ)α = (J₃ · J₂ · J₁)ᵀ α = J(f)ᵀ α

    # Compose cotangent lifts in REVERSE order (this IS backprop)
    # f* = f_1* ∘ f_2* ∘ f_3* means we multiply: J_1^T @ J_2^T @ J_3^T
    # Starting from output covector and going backward:
    backprop_matrix = cotangent_lift(jacobians[-1])
    for i in range(n_layers - 2, -1, -1):
        backprop_matrix = cotangent_lift(jacobians[i]) @ backprop_matrix

    # This should equal J_full^T
    J_full_transpose = J_full.T

    print("─── Cotangent Lift (Backpropagation) ───")
    print(f"f* = f₁* ∘ f₂* ∘ f₃*  (reverse composition)")
    print(f"Shape: {backprop_matrix.shape}")
    print()

    # ─── Verification ───────────────────────────────────────────
    error = np.max(np.abs(backprop_matrix - J_full_transpose))

    print("─── Verification ───")
    print(f"‖ backprop_matrix − J(f)ᵀ ‖_∞ = {error:.2e}")
    print()

    if error < 1e-12:
        print("✓ VERIFIED: Backpropagation = Cotangent Lift")
        print()
        print("  The reverse-mode traversal of backpropagation is")
        print("  precisely the contravariant functoriality of T*:")
        print()
        print("     (f_n ∘ ⋯ ∘ f_1)* = f_1* ∘ ⋯ ∘ f_n*")
        print()
        print("  This identity is forced by the chain rule for")
        print("  cotangent maps — backprop has no choice but to")
        print("  traverse layers in reverse order.")
    else:
        print("✗ NUMERICAL ERROR DETECTED")

    print()

    # ─── Demonstrate with a concrete gradient ───────────────────
    print("─── Example: Loss Gradient via Cotangent Lift ───")
    # Suppose loss = ‖output‖², so ∂L/∂output = 2·output
    loss_grad = 2.0 * output
    print(f"Loss gradient at output (covector): {loss_grad}")

    # Backprop: apply cotangent lifts in reverse
    grad = loss_grad
    for i in range(n_layers - 1, -1, -1):
        grad = cotangent_lift(jacobians[i]) @ grad

    # Direct: J(f)ᵀ · loss_grad
    grad_direct = J_full_transpose @ loss_grad

    print(f"Gradient via backprop (cotangent lift): {grad}")
    print(f"Gradient via J(f)ᵀ (direct):           {grad_direct}")
    print(f"Match: {np.allclose(grad, grad_direct)}")
    print()

    # ─── Key Insight ────────────────────────────────────────────
    print("=" * 60)
    print("  KEY INSIGHT")
    print("=" * 60)
    print()
    print("  Backpropagation is not an algorithm — it is a theorem.")
    print("  It is the contravariant functoriality of the cotangent")
    print("  bundle functor T* : Man^op → VectBun, applied to the")
    print("  composition of smooth layer maps.")
    print()
    print("  The 'reverse mode' is not a design choice; it is forced")
    print("  by the mathematical structure of duality.")
    print()


if __name__ == "__main__":
    main()
