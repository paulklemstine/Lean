#!/usr/bin/env python3
"""
demo.py — Backpropagation as Cotangent Lift

This script numerically demonstrates that backpropagation is the cotangent lift
(pullback on cotangent bundles) of the forward map in smooth manifolds.

Key idea:
  Given a composition F = f_L ∘ ... ∘ f_1, the cotangent lift satisfies
      F* = f_1* ∘ f_2* ∘ ... ∘ f_L*
  which is exactly the backpropagation algorithm applied in reverse layer order.

We verify this by comparing:
  1. Direct computation: (DF)^T · δ  (full Jacobian transpose times output gradient)
  2. Backprop computation: layer-by-layer reverse accumulation of cotangent vectors

The two must agree — this is the content of the theorem backprop_cotangent_lift.
"""

import numpy as np

# ─── Layer definitions ────────────────────────────────────────────────────────
# Each "layer" is a smooth map f_i : R^{n_{i-1}} → R^{n_i}
# For demonstration we use affine maps followed by a smooth activation (tanh).

def make_layer(W, b):
    """Create a smooth layer x ↦ tanh(W @ x + b) and its derivative."""
    def forward(x):
        return np.tanh(W @ x + b)

    def jacobian(x):
        """Jacobian Df(x) — the tangent map."""
        z = W @ x + b
        diag = 1.0 - np.tanh(z) ** 2          # tanh'(z)
        return np.diag(diag) @ W               # chain rule for affine + tanh

    def cotangent_lift(x, covector):
        """
        Cotangent lift f*(x, η) = (x, (Df_x)^T η).

        This is the geometric content: the pullback of a covector η ∈ T*_{f(x)}N
        back to T*_x M via the transpose of the tangent map.
        """
        J = jacobian(x)
        return J.T @ covector                  # (Df)^T η — the cotangent action

    return forward, jacobian, cotangent_lift


# ─── Network construction ────────────────────────────────────────────────────
np.random.seed(42)

# Architecture: R^4 → R^5 → R^3 → R^2  (three layers)
dims = [4, 5, 3, 2]
layers = []
for i in range(len(dims) - 1):
    W = np.random.randn(dims[i + 1], dims[i]) * 0.5
    b = np.random.randn(dims[i + 1]) * 0.1
    layers.append(make_layer(W, b))


def main():
    print("=" * 70)
    print("  Backpropagation as Cotangent Lift — Numerical Verification")
    print("=" * 70)
    print()

    # Input point on the "manifold" (here R^4)
    x0 = np.random.randn(dims[0])
    print(f"Input x₀ ∈ R^{dims[0]}:  {x0.round(4)}")
    print()

    # ── Forward pass: compute intermediate activations ────────────────────
    activations = [x0]
    for fwd, _, _ in layers:
        activations.append(fwd(activations[-1]))

    output = activations[-1]
    print(f"Output F(x₀) ∈ R^{dims[-1]}:  {output.round(6)}")
    print()

    # ── Method 1: Full Jacobian (tangent map) then transpose ──────────────
    # Compute DF_{x₀} by chaining Jacobians: DF = J_L · J_{L-1} · ... · J_1
    full_jacobian = np.eye(dims[0])
    for i, (_, jac, _) in enumerate(layers):
        J_i = jac(activations[i])
        full_jacobian = J_i @ full_jacobian

    print(f"Full Jacobian DF (shape {full_jacobian.shape}):")
    print(full_jacobian.round(6))
    print()

    # Output covector (gradient of loss w.r.t. output)
    delta_L = np.random.randn(dims[-1])
    print(f"Output covector δ_L ∈ T*_{{F(x₀)}} R^{dims[-1]}:  {delta_L.round(6)}")
    print()

    # Direct computation: (DF)^T · δ_L
    direct_result = full_jacobian.T @ delta_L
    print("─" * 70)
    print("Method 1 — Direct cotangent lift via full Jacobian transpose:")
    print(f"  (DF)^T · δ_L = {direct_result.round(8)}")
    print()

    # ── Method 2: Backpropagation = layer-by-layer cotangent lift ─────────
    # F* = f_1* ∘ f_2* ∘ ... ∘ f_L*
    # We apply cotangent lifts in reverse order, starting from δ_L.
    covector = delta_L
    for i in range(len(layers) - 1, -1, -1):
        _, _, cot_lift = layers[i]
        covector = cot_lift(activations[i], covector)
        # Each step: δ_{i} = (Df_{i+1})^T · δ_{i+1}
        # This IS the backpropagation recursion!

    backprop_result = covector
    print("Method 2 — Backpropagation (iterated cotangent lift):")
    print(f"  f₁* ∘ f₂* ∘ f₃*(δ_L) = {backprop_result.round(8)}")
    print()

    # ── Verification ──────────────────────────────────────────────────────
    error = np.linalg.norm(direct_result - backprop_result)
    print("─" * 70)
    print(f"‖Direct − Backprop‖ = {error:.2e}")
    print()

    if error < 1e-12:
        print("✓ VERIFIED: Backpropagation = Cotangent lift of forward map")
        print()
        print("KEY INSIGHT:")
        print("  The chain rule (DF)^T = (Df₁)^T · (Df₂)^T · ... · (Df_L)^T")
        print("  is the contravariant functoriality of the cotangent bundle:")
        print("      (g ∘ f)* = f* ∘ g*")
        print()
        print("  Backpropagation simply evaluates this functor on a composition")
        print("  of smooth layer maps — it is geometry, not an algorithm trick.")
    else:
        print("✗ MISMATCH (numerical error too large)")

    print()
    print("=" * 70)

    # ── Bonus: visualize the cotangent vectors at each layer ──────────────
    print()
    print("Layer-by-layer cotangent flow (backprop trace):")
    print("─" * 70)
    covector = delta_L
    print(f"  Layer {len(layers)} output:  δ_{len(layers)} = {covector.round(6)}")
    for i in range(len(layers) - 1, -1, -1):
        _, _, cot_lift = layers[i]
        covector = cot_lift(activations[i], covector)
        print(f"  Layer {i} input:    δ_{i} = {covector.round(6)}")
    print()
    print("Each arrow δ_{i} ← (Df_{i+1})^T · δ_{i+1} is a cotangent lift.")
    print("The full path IS backpropagation.")


if __name__ == "__main__":
    main()
