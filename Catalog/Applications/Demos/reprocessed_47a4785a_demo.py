#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift

This script demonstrates numerically that backpropagation computes
exactly the cotangent lift (pullback on cotangent bundles) of the
forward map in a neural network.

Key mathematical identity:
    (f_n ∘ ... ∘ f_1)* = f_1* ∘ ... ∘ f_n*

where f* denotes the cotangent lift (transpose of the Jacobian).
The left side is "compute the full Jacobian, then transpose" while
the right side is "transpose each layer's Jacobian and multiply in
reverse order" — which is exactly backpropagation.

Usage: python3 demo.py
"""

import numpy as np


def relu(x):
    """ReLU activation — piecewise linear, smooth almost everywhere."""
    return np.maximum(0, x)


def relu_jacobian(x):
    """Jacobian of ReLU: diagonal matrix of indicators."""
    return np.diag((x > 0).astype(float))


def affine_layer(W, b, x):
    """Forward pass of an affine layer: y = Wx + b."""
    return W @ x + b


def affine_jacobian(W, x):
    """Jacobian of affine layer w.r.t. input x is just W."""
    return W


# ─── Network Architecture ───────────────────────────────────────────
# A simple 3-layer network: R^3 → R^4 → R^2 → R^1
# Layer 1: affine + ReLU  (3 → 4)
# Layer 2: affine + ReLU  (4 → 2)
# Layer 3: affine (linear output) (2 → 1)

def build_network(seed=42):
    """Build a small neural network with random weights."""
    rng = np.random.RandomState(seed)
    W1 = rng.randn(4, 3)
    b1 = rng.randn(4)
    W2 = rng.randn(2, 4)
    b2 = rng.randn(2)
    W3 = rng.randn(1, 2)
    b3 = rng.randn(1)
    return [(W1, b1), (W2, b2), (W3, b3)]


def forward_pass(layers, x):
    """
    Forward pass through the network.
    Returns all intermediate activations (for backprop).

    In the cotangent bundle picture:
      x ∈ M₀, then f₁(x) ∈ M₁, f₂(f₁(x)) ∈ M₂, etc.
    Each Mᵢ = ℝ^{nᵢ} is a smooth manifold (Euclidean space).
    """
    activations = [x.copy()]
    h = x
    for i, (W, b) in enumerate(layers):
        z = affine_layer(W, b, h)
        # Apply ReLU on all but last layer
        if i < len(layers) - 1:
            h = relu(z)
        else:
            h = z
        activations.append(h.copy())
    return activations


def compute_layer_jacobians(layers, activations):
    """
    Compute the Jacobian of each layer at the given activations.

    For layer i with activation function σ and weight matrix Wᵢ:
      J_i = diag(σ'(Wᵢ xᵢ + bᵢ)) @ Wᵢ

    These are the differentials df_i : T_{x_i} M_i → T_{x_{i+1}} M_{i+1}
    """
    jacobians = []
    h = activations[0]
    for i, (W, b) in enumerate(layers):
        z = W @ h + b
        J_affine = affine_jacobian(W, h)
        if i < len(layers) - 1:
            J_relu = relu_jacobian(z)
            J = J_relu @ J_affine
        else:
            J = J_affine
        jacobians.append(J)
        if i < len(layers) - 1:
            h = relu(z)
        else:
            h = z
    return jacobians


def method1_full_jacobian_transpose(jacobians):
    """
    Method 1: Compute the full Jacobian of the composition,
    then take its transpose.

    Full Jacobian = J_n @ ... @ J_2 @ J_1
    Cotangent lift = (J_n @ ... @ J_1)^T = J_1^T @ ... @ J_n^T

    This is the "mathematical definition" approach.
    """
    J_full = jacobians[0]
    for J in jacobians[1:]:
        J_full = J @ J_full
    # The cotangent lift is the transpose
    return J_full.T


def method2_backpropagation(jacobians):
    """
    Method 2: Backpropagation — compose the cotangent lifts in reverse.

    The cotangent lift of f_i is J_i^T.
    T*(f_n ∘ ... ∘ f_1) = T*(f_1) ∘ ... ∘ T*(f_n)
                        = J_1^T @ J_2^T @ ... @ J_n^T

    This IS backpropagation: start from the output covector and
    pull it back through each layer in reverse order.
    """
    # Compute J_1^T @ J_2^T @ ... @ J_n^T
    result = jacobians[0].T
    for J in jacobians[1:]:
        result = result @ J.T
    return result


def method3_reverse_accumulation(jacobians, output_covector):
    """
    Method 3: Explicit reverse-mode accumulation (actual backprop).

    Given an output covector α ∈ T*_{f(x)} N (e.g., the loss gradient),
    compute f*(α) ∈ T*_x M by pulling back through each layer.

    α_{n} = α
    α_{i-1} = α_i @ J_i^T = J_i^T α_i  (covector pullback)

    This is the actual backpropagation algorithm as implemented in
    PyTorch, TensorFlow, JAX, etc.
    """
    covector = output_covector.copy()
    for J in reversed(jacobians):
        # Pull back the covector through layer i
        # Cotangent lift: f_i*(α) = α ∘ df_i = α @ J_i  (row vector convention)
        covector = covector @ J
    return covector


def main():
    """
    Main demonstration: verify that backpropagation = cotangent lift.

    The key insight: backpropagation's reverse traversal is not an
    algorithmic trick — it is the ONLY correct way to evaluate the
    cotangent functor T* : Man^op → VectBun on a composition.

    The contravariance of T* (reversing arrows) forces the reverse
    evaluation order. Forward-mode would compute the tangent lift
    (pushforward), which is covariant and evaluates left-to-right.
    """
    print("=" * 65)
    print("  BACKPROPAGATION AS THE COTANGENT LIFT")
    print("  Numerical verification of the functoriality theorem")
    print("=" * 65)

    # Build network and compute forward pass
    layers = build_network(seed=42)
    x = np.array([1.0, -0.5, 0.3])

    print(f"\nInput x = {x}")
    print(f"Network: R^3 → R^4 → R^2 → R^1 (3 layers)")

    activations = forward_pass(layers, x)
    output = activations[-1]
    print(f"Output f(x) = {output}")

    # Compute Jacobians of each layer
    jacobians = compute_layer_jacobians(layers, activations)

    print(f"\nLayer Jacobian shapes: {[J.shape for J in jacobians]}")

    # ─── Method 1: Full Jacobian, then transpose ────────────────
    cotangent_from_full = method1_full_jacobian_transpose(jacobians)

    # ─── Method 2: Compose transposes in reverse (backprop) ─────
    cotangent_from_backprop = method2_backpropagation(jacobians)

    # ─── Compare ────────────────────────────────────────────────
    print("\n─── COMPARISON ───")
    print(f"\nMethod 1 (full Jacobian transpose):")
    print(f"  (df)^T = {cotangent_from_full.flatten()}")
    print(f"\nMethod 2 (backpropagation = cotangent lift):")
    print(f"  T*(f)  = {cotangent_from_backprop.flatten()}")

    diff = np.max(np.abs(cotangent_from_full - cotangent_from_backprop))
    print(f"\n  Max difference: {diff:.2e}")
    assert diff < 1e-12, "Methods disagree!"
    print("  ✓ Methods agree to machine precision!")

    # ─── Method 3: Explicit covector pullback ───────────────────
    print("\n─── EXPLICIT COVECTOR PULLBACK ───")
    # Loss gradient at output (a covector in T*_output N)
    alpha = np.array([1.0])  # d(loss)/d(output) = 1 for identity loss
    print(f"  Output covector α = {alpha}")

    pulled_back = method3_reverse_accumulation(jacobians, alpha)
    direct = alpha @ (jacobians[-1] @ jacobians[-2] @ jacobians[0])

    # The pulled-back covector should equal α @ J_full
    J_full = jacobians[0]
    for J in jacobians[1:]:
        J_full = J @ J_full
    expected = alpha @ J_full

    print(f"  Backprop pullback f*(α) = {pulled_back}")
    print(f"  Direct computation α∘df = {expected}")
    diff2 = np.max(np.abs(pulled_back - expected))
    print(f"  Max difference: {diff2:.2e}")
    assert diff2 < 1e-12, "Pullback disagrees!"
    print("  ✓ Covector pullback matches!")

    # ─── Functoriality check ────────────────────────────────────
    print("\n─── FUNCTORIALITY: (g∘f)* = f* ∘ g* ───")
    # Split network into f = layers[0] and g = layers[1] ∘ layers[2]
    J_f = jacobians[0]
    J_g = jacobians[2] @ jacobians[1]

    # (g ∘ f)* = (J_g @ J_f)^T
    lhs = (J_g @ J_f).T

    # f* ∘ g* = J_f^T @ J_g^T
    rhs = J_f.T @ J_g.T

    print(f"  (g∘f)* = \n{lhs}")
    print(f"  f*∘g*  = \n{rhs}")
    diff3 = np.max(np.abs(lhs - rhs))
    print(f"  Max difference: {diff3:.2e}")
    assert diff3 < 1e-12, "Functoriality fails!"
    print("  ✓ Contravariant functoriality verified!")

    # ─── Key Insight ────────────────────────────────────────────
    print("\n" + "=" * 65)
    print("  KEY INSIGHT")
    print("=" * 65)
    print("""
  Backpropagation is not merely an efficient algorithm —
  it is the UNIQUE evaluation strategy dictated by the
  contravariant functoriality of the cotangent bundle.

  The cotangent functor T* : Man^op → VectBun reverses
  arrows: T*(g ∘ f) = T*(f) ∘ T*(g).

  This forces reverse-order evaluation, which IS backprop.
  Forward-mode AD corresponds to the covariant tangent
  functor T : Man → VectBun, which preserves arrow order.

  The duality between forward-mode and reverse-mode AD
  is precisely the duality between tangent and cotangent
  bundles — a fundamental structure in differential geometry.
    """)


if __name__ == "__main__":
    main()
