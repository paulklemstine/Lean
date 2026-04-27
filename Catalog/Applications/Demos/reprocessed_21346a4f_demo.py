#!/usr/bin/env python3
"""
demo.py — Backpropagation as Cotangent Lift

This script demonstrates numerically that backpropagation through a
multi-layer network is identical to the composition of transposed
Jacobians in reverse order — i.e., the cotangent lift (pullback on
cotangent bundles) of the forward map.

Key insight from the formal proof:
  For f = f_L ∘ ... ∘ f_1, the cotangent lift is
      f* = f_1* ∘ f_2* ∘ ... ∘ f_L*
  where f_i* = (Df_i)^T.  This IS backpropagation.

Usage:
    python3 demo.py
"""

import numpy as np

# ──────────────────────────────────────────────────────────
# 1. Define a simple 3-layer network: R^3 → R^4 → R^2 → R
# ──────────────────────────────────────────────────────────

np.random.seed(42)

# Layer parameters (weights only, for clarity)
W1 = np.random.randn(4, 3)   # f1 : R^3 → R^4
W2 = np.random.randn(2, 4)   # f2 : R^4 → R^2
W3 = np.random.randn(1, 2)   # f3 : R^2 → R  (scalar loss)

def relu(x):
    """ReLU activation — piecewise linear, smooth a.e."""
    return np.maximum(0, x)

def relu_deriv(x):
    """Subgradient of ReLU (Jacobian diagonal)."""
    return (x > 0).astype(float)


def forward(x):
    """Forward pass: compute activations at each layer."""
    z1 = W1 @ x
    a1 = relu(z1)
    z2 = W2 @ a1
    a2 = relu(z2)
    z3 = W3 @ a2          # scalar output (loss)
    return z1, a1, z2, a2, z3


# ──────────────────────────────────────────────────────────
# 2. Backpropagation (the standard algorithmic version)
# ──────────────────────────────────────────────────────────

def backprop(x):
    """
    Standard backpropagation.
    Returns the gradient of the scalar output w.r.t. input x.
    """
    z1, a1, z2, a2, z3 = forward(x)

    # ∂loss/∂z3 = 1 (identity for scalar output)
    delta3 = np.ones(1)

    # Propagate back through layer 3:  δ2 = W3^T δ3 ⊙ relu'(z2)
    delta2 = (W3.T @ delta3) * relu_deriv(z2)

    # Propagate back through layer 2:  δ1 = W2^T δ2 ⊙ relu'(z1)
    delta1 = (W2.T @ delta2) * relu_deriv(z1)

    # Propagate back through layer 1:  grad_x = W1^T δ1
    grad_x = W1.T @ delta1

    return grad_x


# ──────────────────────────────────────────────────────────
# 3. Cotangent lift (composition of transposed Jacobians)
# ──────────────────────────────────────────────────────────

def cotangent_lift(x):
    """
    Cotangent lift = f1* ∘ f2* ∘ f3*  (reverse composition of pullbacks).

    Each f_i* is the transpose of the Jacobian of layer i.
    This is the differential-geometric construction that the
    formal theorem identifies with backpropagation.
    """
    z1, a1, z2, a2, z3 = forward(x)

    # Jacobian of each layer (at the relevant point):
    #   J1 = diag(relu'(z1)) @ W1   (Jacobian of relu∘linear)
    #   J2 = diag(relu'(z2)) @ W2
    #   J3 = W3                      (linear layer, no activation)
    J1 = np.diag(relu_deriv(z1)) @ W1
    J2 = np.diag(relu_deriv(z2)) @ W2
    J3 = W3

    # Cotangent lift of the composite f = f3 ∘ f2 ∘ f1:
    #   f* = f1* ∘ f2* ∘ f3*
    #      = J1^T  ∘  J2^T  ∘  J3^T
    #
    # Applied to the "seed" covector η = 1 (gradient of identity loss):
    eta = np.ones(1)

    # f3* : T*R → T*R^2
    step1 = J3.T @ eta

    # f2* : T*R^2 → T*R^4
    step2 = J2.T @ step1

    # f1* : T*R^4 → T*R^3
    step3 = J1.T @ step2

    return step3


# ──────────────────────────────────────────────────────────
# 4. Numerical verification
# ──────────────────────────────────────────────────────────

def finite_difference_gradient(x, eps=1e-7):
    """Finite-difference gradient for sanity check."""
    grad = np.zeros_like(x)
    for i in range(len(x)):
        x_plus = x.copy(); x_plus[i] += eps
        x_minus = x.copy(); x_minus[i] -= eps
        _, _, _, _, z_plus = forward(x_plus)
        _, _, _, _, z_minus = forward(x_minus)
        grad[i] = (z_plus[0] - z_minus[0]) / (2 * eps)
    return grad


def main():
    print("=" * 64)
    print("  BACKPROPAGATION  =  COTANGENT LIFT")
    print("  (Numerical verification of the formal theorem)")
    print("=" * 64)
    print()

    x = np.array([1.0, -0.5, 0.3])

    grad_bp = backprop(x)
    grad_ct = cotangent_lift(x)
    grad_fd = finite_difference_gradient(x)

    print(f"Input x = {x}")
    print()
    print(f"Backpropagation gradient : {grad_bp}")
    print(f"Cotangent lift gradient  : {grad_ct}")
    print(f"Finite-difference check  : {grad_fd}")
    print()

    diff = np.max(np.abs(grad_bp - grad_ct))
    fd_err = np.max(np.abs(grad_bp - grad_fd))

    print(f"Max |backprop − cotangent lift| = {diff:.2e}")
    print(f"Max |backprop − finite diff|    = {fd_err:.2e}")
    print()

    if diff < 1e-14:
        print("✓ EXACT MATCH: Backpropagation IS the cotangent lift.")
        print()
        print("KEY INSIGHT:")
        print("  The chain rule for smooth maps says")
        print("    d(g∘f)_x = dg_{f(x)} ∘ df_x")
        print("  Taking transposes reverses the order:")
        print("    (g∘f)* = f* ∘ g*")
        print("  This reverse-order composition of transposed Jacobians")
        print("  is EXACTLY what backpropagation computes.")
        print("  Backpropagation is not an algorithm — it is a functor.")
    else:
        print("✗ MISMATCH — check implementation.")

    print()
    print("=" * 64)


if __name__ == "__main__":
    main()
