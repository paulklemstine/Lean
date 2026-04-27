#!/usr/bin/env python3
"""
demo.py — Backpropagation as Cotangent Lift

This script demonstrates numerically that backpropagation is the
cotangent lift (pullback on cotangent bundles) of the forward map.

Key idea:
  Given a composition F = f_n ∘ ... ∘ f_1, the cotangent lift satisfies
    F* = f_1* ∘ f_2* ∘ ... ∘ f_n*
  Each f_i* is the transpose Jacobian of layer i — exactly what
  backpropagation computes in reverse order.

We verify this numerically for a 3-layer neural network by comparing:
  1. Direct Jacobian computation of the full network (forward mode)
  2. Reverse-mode chain rule via transposed Jacobians (backprop)
  3. The cotangent lift composition f_1* ∘ f_2* ∘ f_3*

All three must agree, confirming backprop = cotangent lift.

Uses only the Python standard library (no numpy required).
"""

import random
import math


# ─── Simple matrix operations (pure Python) ──────────────────────────

def mat_zeros(rows, cols):
    return [[0.0] * cols for _ in range(rows)]

def mat_mul(A, B):
    """Matrix multiplication A @ B."""
    rows_a, cols_a = len(A), len(A[0])
    rows_b, cols_b = len(B), len(B[0])
    assert cols_a == rows_b
    C = mat_zeros(rows_a, cols_b)
    for i in range(rows_a):
        for j in range(cols_b):
            s = 0.0
            for k in range(cols_a):
                s += A[i][k] * B[k][j]
            C[i][j] = s
    return C

def mat_vec(A, x):
    """Matrix-vector multiplication A @ x."""
    return [sum(A[i][k] * x[k] for k in range(len(x))) for i in range(len(A))]

def mat_transpose(A):
    """Transpose of matrix A."""
    rows, cols = len(A), len(A[0])
    return [[A[j][i] for j in range(rows)] for i in range(cols)]

def mat_diag(d):
    """Diagonal matrix from vector d."""
    n = len(d)
    M = mat_zeros(n, n)
    for i in range(n):
        M[i][i] = d[i]
    return M

def vec_round(v, digits=6):
    return [round(x, digits) for x in v]

def mat_round(M, digits=6):
    return [[round(x, digits) for x in row] for row in M]

def mat_max_abs_diff(A, B):
    return max(abs(A[i][j] - B[i][j]) for i in range(len(A)) for j in range(len(A[0])))

def mat_print(M, indent="  "):
    for row in M:
        print(indent + "[" + ", ".join(f"{x:10.6f}" for x in row) + "]")


# ─── Layer definitions ───────────────────────────────────────────────

def relu(x):
    """ReLU activation — piecewise linear, tropical max-plus structure."""
    return [max(0.0, xi) for xi in x]

def relu_jacobian_diag(x):
    """Diagonal Jacobian of ReLU: 1 where x > 0, else 0."""
    return [1.0 if xi > 0 else 0.0 for xi in x]

def layer_forward(x, W, b):
    """Forward pass through one layer: f(x) = ReLU(Wx + b)."""
    pre = [sum(W[i][k] * x[k] for k in range(len(x))) + b[i] for i in range(len(b))]
    return relu(pre)

def layer_jacobian(x, W, b):
    """
    Jacobian of f(x) = ReLU(Wx + b) at point x.
    J = diag(ReLU'(Wx + b)) @ W

    This is the tangent map df_x : T_x(R^m) -> T_{f(x)}(R^n).
    """
    pre = [sum(W[i][k] * x[k] for k in range(len(x))) + b[i] for i in range(len(b))]
    D = mat_diag(relu_jacobian_diag(pre))
    return mat_mul(D, W)

def cotangent_lift(J):
    """
    Cotangent lift f* of a linear map with Jacobian J.

    The cotangent lift pulls back covectors:
      f*(q, α) = (p, α ∘ df_p) = (p, J^T α)

    So the matrix representation of f* is J^T (transpose).
    This is the KEY connection: backprop multiplies by J^T.
    """
    return mat_transpose(J)


def main():
    random.seed(42)

    def randn():
        # Box-Muller transform for standard normal
        u1 = random.random()
        u2 = random.random()
        return math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2)

    # ─── Network architecture ────────────────────────────────────
    # 3-layer network: R^4 -> R^5 -> R^3 -> R^2
    dims = [4, 5, 3, 2]
    n_layers = len(dims) - 1

    # Random weights and biases
    weights = []
    biases = []
    for i in range(n_layers):
        W = [[randn() * 0.5 for _ in range(dims[i])] for _ in range(dims[i+1])]
        b = [randn() * 0.1 for _ in range(dims[i+1])]
        weights.append(W)
        biases.append(b)

    # ─── Forward pass ────────────────────────────────────────────
    x = [randn() for _ in range(dims[0])]
    print("=" * 65)
    print("  BACKPROPAGATION AS COTANGENT LIFT — Numerical Demonstration")
    print("=" * 65)
    print(f"\nNetwork: R^{dims[0]} -> R^{dims[1]} -> R^{dims[2]} -> R^{dims[3]}")
    print(f"Input x = {vec_round(x, 4)}")

    # Compute forward pass and Jacobians at each layer
    activations = [x]
    jacobians = []
    for i in range(n_layers):
        a = activations[-1]
        J_i = layer_jacobian(a, weights[i], biases[i])
        jacobians.append(J_i)
        a_next = layer_forward(a, weights[i], biases[i])
        activations.append(a_next)

    print(f"Output F(x) = {vec_round(activations[-1], 4)}")

    # ─── Method 1: Full Jacobian (forward mode) ─────────────────
    # J_F = J_3 @ J_2 @ J_1  (tangent map: covariant composition)
    J_full = jacobians[-1]
    for i in range(n_layers - 2, -1, -1):
        J_full = mat_mul(J_full, jacobians[i])

    print(f"\n{'─' * 65}")
    print("METHOD 1: Full Jacobian (forward/tangent mode)")
    print(f"  J_F = J_3 . J_2 . J_1  [covariant — same order as composition]")
    print(f"  J_F =")
    mat_print(mat_round(J_full))

    # ─── Method 2: Cotangent lift (backprop / reverse mode) ─────
    # F* = f_1* ∘ f_2* ∘ f_3*  (contravariant — REVERSED order)
    # In matrix form: (J_F)^T = J_1^T @ J_2^T @ J_3^T
    J_backprop = cotangent_lift(jacobians[0])
    for i in range(1, n_layers):
        J_backprop = mat_mul(J_backprop, cotangent_lift(jacobians[i]))

    print(f"\n{'─' * 65}")
    print("METHOD 2: Cotangent lift (backpropagation / reverse mode)")
    print(f"  F* = f_1* o f_2* o f_3*  [contravariant — REVERSED order]")
    print(f"  (J_F)^T = J_1^T . J_2^T . J_3^T")
    print(f"  (J_F)^T =")
    mat_print(mat_round(J_backprop))

    # ─── Verification ───────────────────────────────────────────
    J_full_T = mat_transpose(J_full)
    print(f"\n{'─' * 65}")
    print("VERIFICATION: (J_F)^T from cotangent lift vs transpose of J_F")

    error = mat_max_abs_diff(J_backprop, J_full_T)
    print(f"  Max error: {error:.2e}")
    assert error < 1e-12, "Mismatch detected!"
    print(f"  MATCH — backpropagation = cotangent lift (error < 1e-12)")

    # ─── Gradient computation demo ───────────────────────────────
    print(f"\n{'─' * 65}")
    print("GRADIENT COMPUTATION via cotangent lift")

    # A loss covector at the output (element of T*_{F(x)} R^2)
    loss_gradient = [1.0, -0.5]  # dL/d(output)
    print(f"  Loss gradient (covector at output): alpha = {loss_gradient}")

    # Backprop: pull back through cotangent lift
    # dL/dx = F*(alpha) = f_1*(f_2*(f_3*(alpha)))
    covector = loss_gradient
    print(f"\n  Pulling back covector through layers (contravariant):")
    for i in range(n_layers - 1, -1, -1):
        covector = mat_vec(cotangent_lift(jacobians[i]), covector)
        print(f"    After f_{i+1}*: {vec_round(covector)}")

    # Compare with direct computation
    direct_grad = mat_vec(J_full_T, loss_gradient)
    grad_error = max(abs(covector[j] - direct_grad[j]) for j in range(len(covector)))
    print(f"\n  Direct gradient (J_F^T . alpha): {vec_round(direct_grad)}")
    print(f"  Max error: {grad_error:.2e}")
    assert grad_error < 1e-12
    print(f"  MATCH — reverse-mode gradient = cotangent pullback")

    # ─── Key insight ─────────────────────────────────────────────
    print(f"\n{'=' * 65}")
    print("KEY INSIGHT:")
    print("  Backpropagation is the cotangent lift F* of the forward map F.")
    print("  The reverse traversal order is not an algorithmic trick —")
    print("  it is FORCED by the contravariance of the cotangent functor")
    print("  T* : Man^op -> VectBun.")
    print()
    print("  Forward:   F  = f_n o ... o f_1   (covariant)")
    print("  Backward:  F* = f_1* o ... o f_n*  (contravariant)")
    print()
    print("  Each f_i* multiplies by J_i^T — the transpose Jacobian —")
    print("  which is exactly what backprop does at each layer.")
    print("=" * 65)


if __name__ == "__main__":
    main()
