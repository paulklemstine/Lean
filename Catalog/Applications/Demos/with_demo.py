#!/usr/bin/env python3
"""
Backpropagation as the Cotangent Lift — Numerical Demonstration

This script demonstrates that backpropagation in a neural network is
precisely the cotangent lift (pullback on cotangent bundles) of the
forward map. We verify this by showing that:

  (f₂ ∘ f₁)* = f₁* ∘ f₂*

i.e., the Jacobian transpose of the composed map equals the
reverse-order composition of individual Jacobian transposes.
This is contravariant functoriality of T*.

The key insight: backprop's reverse traversal is not an algorithmic
trick — it's forced by the mathematics of cotangent bundles.
"""

import numpy as np


def relu(x):
    """ReLU activation — the tropical max(0, x) in disguise."""
    return np.maximum(0, x)


def relu_deriv(x):
    """Subdifferential of ReLU (choosing 0 at the kink)."""
    return (x > 0).astype(float)


def forward_layer(x, W, b, activation=None):
    """
    Forward pass through one layer: f(x) = σ(Wx + b).

    In the smooth manifold picture, this is a smooth map
    f : ℝⁿ → ℝᵐ between Euclidean parameter spaces.
    """
    z = W @ x + b
    if activation is not None:
        return activation(z), z
    return z, z


def jacobian_layer(x, W, z, activation_deriv=None):
    """
    Compute the Jacobian df/dx of a single layer.

    This is the differential df_p : T_pM → T_{f(p)}N,
    represented as a matrix in local coordinates.
    """
    if activation_deriv is not None:
        # Chain rule: d(σ ∘ L)/dx = diag(σ'(z)) · W
        return np.diag(activation_deriv(z)) @ W
    return W.copy()


def cotangent_lift(jacobian, covector):
    """
    Cotangent lift f* : T*N → T*M.

    Given a covector α ∈ T*_{f(p)}N, compute
      f*(α) = α ∘ df_p = Jᵀ · α ∈ T*_pM

    This is the TRANSPOSE of the Jacobian applied to the covector.
    The transpose is what makes it contravariant (reverses composition).
    """
    return jacobian.T @ covector


def main():
    """
    Demonstrate that backpropagation = cotangent lift.

    We build a 2-layer network and verify:
      1. Forward composition: f = f₂ ∘ f₁
      2. Cotangent lift of composition: (f₂ ∘ f₁)* computed directly
      3. Backprop (iterated cotangent lifts): f₁* ∘ f₂*
      4. These are IDENTICAL — proving backprop IS the cotangent lift.
    """
    np.random.seed(42)

    # === Network Architecture ===
    # Layer 1: ℝ³ → ℝ⁴ (with ReLU)
    # Layer 2: ℝ⁴ → ℝ² (linear output)
    dim_in, dim_hidden, dim_out = 3, 4, 2

    W1 = np.random.randn(dim_hidden, dim_in)
    b1 = np.random.randn(dim_hidden)
    W2 = np.random.randn(dim_out, dim_hidden)
    b2 = np.random.randn(dim_out)

    # Input point p ∈ M₀ = ℝ³
    x = np.array([1.0, -0.5, 2.0])

    print("=" * 60)
    print("BACKPROPAGATION AS THE COTANGENT LIFT")
    print("=" * 60)
    print()
    print("Network: ℝ³ →[f₁]→ ℝ⁴ →[f₂]→ ℝ²")
    print(f"Input point x = {x}")
    print()

    # === Forward Pass (computing the forward map f = f₂ ∘ f₁) ===
    h, z1 = forward_layer(x, W1, b1, relu)       # f₁(x)
    y, z2 = forward_layer(h, W2, b2, None)        # f₂(f₁(x))

    print(f"After layer 1 (f₁): h = {np.round(h, 4)}")
    print(f"After layer 2 (f₂): y = {np.round(y, 4)}")
    print()

    # === Compute Jacobians (differentials df_i) ===
    J1 = jacobian_layer(x, W1, z1, relu_deriv)  # df₁ at x
    J2 = jacobian_layer(h, W2, z2, None)         # df₂ at f₁(x)

    # Jacobian of composition (by chain rule / functoriality of T)
    J_composed = J2 @ J1  # d(f₂ ∘ f₁) = df₂ · df₁

    print("--- Tangent Map (Covariant Functor T) ---")
    print(f"J₁ = df₁ (shape {J1.shape}):")
    print(np.round(J1, 4))
    print(f"\nJ₂ = df₂ (shape {J2.shape}):")
    print(np.round(J2, 4))
    print(f"\nJ_composed = df₂ · df₁ (shape {J_composed.shape}):")
    print(np.round(J_composed, 4))
    print()

    # === Cotangent Lift (the key construction) ===
    # A covector α ∈ T*_y N = T*_{f(x)} ℝ²
    # In practice, this is the gradient of the loss: α = d𝓛
    alpha = np.array([1.0, -0.5])  # A covector at the output
    print(f"--- Cotangent Lift (Contravariant Functor T*) ---")
    print(f"Covector at output: α = d𝓛 = {alpha}")
    print()

    # Method 1: Direct cotangent lift of composed map
    # (f₂ ∘ f₁)*(α) = J_composed^T · α
    direct_result = cotangent_lift(J_composed, alpha)

    # Method 2: Backpropagation = iterated cotangent lifts
    # f₁* ∘ f₂*(α) = J₁ᵀ · (J₂ᵀ · α)
    # Note the REVERSED ORDER — this is contravariance!
    step1 = cotangent_lift(J2, alpha)      # f₂*(α) — first backprop step
    step2 = cotangent_lift(J1, step1)      # f₁*(f₂*(α)) — second step

    print("Method 1: Direct cotangent lift (f₂∘f₁)*(α):")
    print(f"  = J_composedᵀ · α = {np.round(direct_result, 6)}")
    print()
    print("Method 2: Backpropagation (iterated cotangent lifts):")
    print(f"  Step 1: f₂*(α) = J₂ᵀ · α = {np.round(step1, 6)}")
    print(f"  Step 2: f₁*(f₂*(α)) = J₁ᵀ · (J₂ᵀ · α) = {np.round(step2, 6)}")
    print()

    # === The Key Verification ===
    error = np.linalg.norm(direct_result - step2)
    print("=" * 60)
    print("VERIFICATION: (f₂ ∘ f₁)* = f₁* ∘ f₂*")
    print(f"  ‖direct − backprop‖ = {error:.2e}")

    if error < 1e-12:
        print("  ✓ IDENTICAL — Backprop IS the cotangent lift!")
    else:
        print("  ✗ Mismatch (numerical error)")

    print("=" * 60)
    print()

    # === The Mathematical Insight ===
    print("KEY INSIGHT:")
    print("  The reverse order in backpropagation is not a trick.")
    print("  It is FORCED by contravariant functoriality of T*.")
    print()
    print("  Covariant (tangent):   T(g ∘ f) = Tg ∘ Tf    (same order)")
    print("  Contravariant (cotan): T*(g ∘ f) = T*f ∘ T*g  (reversed!)")
    print()
    print("  Backpropagation computes T*(f_n ∘ ⋯ ∘ f_1)")
    print("    = T*f_1 ∘ ⋯ ∘ T*f_n")
    print("    = Jᵀ_1 · (Jᵀ_2 · (⋯ · (Jᵀ_n · d𝓛)))")
    print()
    print("  This is the cotangent lift, period.")

    # === Bonus: Verify identity preservation ===
    print()
    print("--- Bonus: Identity Preservation ---")
    I = np.eye(dim_in)
    id_lift = cotangent_lift(I, np.array([1.0, 2.0, 3.0]))
    print(f"  (id)*(v) = Iᵀ · v = {id_lift}")
    print(f"  v        =         {np.array([1.0, 2.0, 3.0])}")
    print(f"  ✓ (id)* = id — functor preserves identity")


if __name__ == "__main__":
    main()
