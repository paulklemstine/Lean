#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift of the Forward Map

This script demonstrates that backpropagation is exactly the cotangent
(dual / transpose) map applied to the Jacobians of each layer, composed
in reverse order. This is the computational manifestation of the
contravariant cotangent functor T* on the category of smooth manifolds.

Key correspondence:
  Forward pass:  x₀ → f₁ → x₁ → f₂ → ... → fₗ → xₗ
  Backward pass: ξₗ → J_L^T → ξ_{L-1} → ... → J_1^T → ξ₀
  Cotangent lift: T*f = T*f₁ ∘ T*f₂ ∘ ... ∘ T*fₗ  (reversed!)

The backward pass computes vector-Jacobian products (VJPs), which are
exactly the action of the cotangent map on covectors.
"""

import numpy as np


def softplus(x: np.ndarray) -> np.ndarray:
    """Softplus activation — smooth approximation to ReLU."""
    return np.log1p(np.exp(x))


def softplus_deriv(x: np.ndarray) -> np.ndarray:
    """Derivative of softplus: sigmoid function."""
    return 1.0 / (1.0 + np.exp(-x))


def forward_pass(x: np.ndarray, weights: list[np.ndarray],
                 biases: list[np.ndarray]) -> tuple[list[np.ndarray], list[np.ndarray]]:
    """
    Forward pass through an L-layer network with softplus activation.
    Returns activations (x_i) and pre-activations (z_i) at each layer.

    In the language of smooth manifolds, this evaluates the composition
    f = fₗ ∘ ... ∘ f₁ and records intermediate points on the manifold
    for use by the cotangent lift.
    """
    activations = [x]
    pre_activations = []
    for W, b in zip(weights, biases):
        z = W @ activations[-1] + b   # affine map
        pre_activations.append(z)
        activations.append(softplus(z))  # smooth activation
    return activations, pre_activations


def backprop_cotangent(activations: list[np.ndarray],
                       pre_activations: list[np.ndarray],
                       weights: list[np.ndarray],
                       loss_grad: np.ndarray) -> list[np.ndarray]:
    """
    Backpropagation as the cotangent lift T*f.

    Given a covector ξ ∈ T*_{x_L} M_L (the loss gradient), we compute
    the pullback through each layer:

        T*f_i : T*_{x_i} M_i → T*_{x_{i-1}} M_{i-1}
        ξ ↦ J_i^T · ξ

    This is the *contravariant* functorial action: we traverse layers
    in REVERSE order, applying transposed Jacobians — exactly backprop.

    Returns the gradient of the loss with respect to each weight matrix.
    """
    L = len(weights)
    xi = loss_grad  # cotangent vector (covector) at the output

    weight_grads = [None] * L

    for i in range(L - 1, -1, -1):
        # Jacobian of activation at pre-activation z_i
        D_sigma = np.diag(softplus_deriv(pre_activations[i]))

        # Cotangent lift through activation: ξ ← D_σ^T · ξ
        xi = D_sigma.T @ xi

        # Gradient w.r.t. weights: outer product of covector and input
        weight_grads[i] = np.outer(xi, activations[i])

        # Cotangent lift through affine map: ξ ← W_i^T · ξ
        xi = weights[i].T @ xi

    return weight_grads


def numerical_gradient(x: np.ndarray, weights: list[np.ndarray],
                       biases: list[np.ndarray], loss_fn,
                       layer_idx: int, eps: float = 1e-5) -> np.ndarray:
    """
    Compute gradient of loss w.r.t. weights[layer_idx] by finite differences.
    This serves as ground truth to verify the cotangent lift computation.
    """
    W = weights[layer_idx]
    grad = np.zeros_like(W)
    for i in range(W.shape[0]):
        for j in range(W.shape[1]):
            W[i, j] += eps
            acts_p, _ = forward_pass(x, weights, biases)
            loss_p = loss_fn(acts_p[-1])

            W[i, j] -= 2 * eps
            acts_m, _ = forward_pass(x, weights, biases)
            loss_m = loss_fn(acts_m[-1])

            grad[i, j] = (loss_p - loss_m) / (2 * eps)
            W[i, j] += eps  # restore
    return grad


def main():
    """
    Main demonstration: verify that backpropagation (cotangent lift)
    produces the same gradients as numerical differentiation.
    """
    np.random.seed(7)  # chosen for non-trivial activations

    print("=" * 65)
    print(" BACKPROPAGATION AS THE COTANGENT LIFT")
    print(" Demonstrating T*(g ∘ f) = T*f ∘ T*g (contravariant functoriality)")
    print("=" * 65)
    print()

    # ── Network architecture: 3 → 4 → 4 → 2 ──
    dims = [3, 4, 4, 2]
    weights = [np.random.randn(dims[i+1], dims[i]) * 0.8 for i in range(len(dims)-1)]
    biases = [np.random.randn(dims[i+1]) * 0.3 for i in range(len(dims)-1)]

    # Input point on the "parameter manifold"
    x = np.array([1.0, -0.5, 0.8])

    # Target for MSE loss
    target = np.array([1.0, -1.0])

    def mse_loss(y):
        return 0.5 * np.sum((y - target) ** 2)

    # ── Forward pass: evaluate f = f_L ∘ ... ∘ f_1 ──
    activations, pre_activations = forward_pass(x, weights, biases)
    output = activations[-1]
    loss = mse_loss(output)

    print(f"  Input x        = {x}")
    print(f"  Output f(x)    = {np.round(output, 6)}")
    print(f"  Target         = {target}")
    print(f"  MSE Loss       = {loss:.6f}")
    print()

    # ── Loss gradient: covector ξ ∈ T*_{f(x)} ℝ² ──
    loss_grad = output - target  # ∇_y L = y - target

    print("─" * 65)
    print(" COTANGENT LIFT (Backpropagation)")
    print("─" * 65)
    print(f"  Loss gradient ξ = {np.round(loss_grad, 6)}")
    print()

    # ── Backprop = Cotangent lift ──
    bp_grads = backprop_cotangent(activations, pre_activations, weights, loss_grad)

    # ── Numerical gradients (finite differences) for verification ──
    print("  Comparing cotangent lift vs. finite-difference gradients:")
    print()

    all_close = True
    for i in range(len(weights)):
        num_grad = numerical_gradient(x, weights, biases, mse_loss, i)
        max_err = np.max(np.abs(bp_grads[i] - num_grad))
        match = max_err < 1e-4

        print(f"  Layer {i+1} (W{i+1}: {weights[i].shape}):")
        print(f"    Backprop (cotangent lift):  max|grad| = {np.max(np.abs(bp_grads[i])):.6f}")
        print(f"    Numerical (finite diff):    max|grad| = {np.max(np.abs(num_grad)):.6f}")
        print(f"    Max absolute error:         {max_err:.2e}  {'✓ MATCH' if match else '✗ MISMATCH'}")
        print()

        if not match:
            all_close = False

    # ── Demonstrate functoriality: T*(g∘f) = T*f ∘ T*g ──
    print("─" * 65)
    print(" FUNCTORIALITY CHECK: T*(g ∘ f) = T*f ∘ T*g")
    print("─" * 65)
    print()

    # Compute Jacobians at each layer
    jacobians = []
    for i in range(len(weights)):
        D_sigma = np.diag(softplus_deriv(pre_activations[i]))
        J_i = D_sigma @ weights[i]  # Jacobian of layer i
        jacobians.append(J_i)

    # Full Jacobian of composition (forward order)
    J_full = jacobians[-1]
    for i in range(len(jacobians) - 2, -1, -1):
        J_full = J_full @ jacobians[i]

    # Cotangent of full composition: J_full^T
    cotangent_full = J_full.T @ loss_grad

    # Sequential cotangent lifts (reverse order)
    xi = loss_grad
    for i in range(len(jacobians) - 1, -1, -1):
        xi = jacobians[i].T @ xi
    cotangent_sequential = xi

    err = np.max(np.abs(cotangent_full - cotangent_sequential))
    print(f"  T*(g∘f) · ξ  = {np.round(cotangent_full, 8)}")
    print(f"  T*f∘T*g · ξ  = {np.round(cotangent_sequential, 8)}")
    print(f"  Max error     = {err:.2e}  {'✓ MATCH' if err < 1e-12 else '✗ MISMATCH'}")
    print()

    # ── Key insight ──
    print("=" * 65)
    print(" KEY INSIGHT")
    print("=" * 65)
    print()
    print("  Backpropagation IS the cotangent functor T* applied to the")
    print("  forward map f = fₗ ∘ ... ∘ f₁.")
    print()
    print("  • The forward pass evaluates f (covariant: left to right).")
    print("  • The backward pass evaluates T*f (contravariant: right to left).")
    print("  • Each VJP ξ ↦ Jᵢᵀξ is the cotangent lift T*fᵢ.")
    print("  • Functoriality T*(g∘f) = T*f ∘ T*g is the CHAIN RULE.")
    print()
    print("  This is not merely an analogy — it is a precise mathematical")
    print("  identity in the category of smooth manifolds.")
    print()

    if all_close:
        print("  ✓ All gradients match: cotangent lift = backpropagation. QED.")
    else:
        print("  ✗ Some gradients did not match — check implementation.")

    print()


if __name__ == "__main__":
    main()
