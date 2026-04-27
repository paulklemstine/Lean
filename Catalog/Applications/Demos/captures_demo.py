#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift

This script demonstrates numerically that backpropagation computes
exactly the cotangent lift (pullback on cotangent bundles) of a
composition of smooth layer maps.

Mathematical setup:
  Given layers  f₁ : ℝ² → ℝ³  and  f₂ : ℝ³ → ℝ²,
  the forward map is  F = f₂ ∘ f₁ : ℝ² → ℝ².

  The cotangent lift satisfies:
    F* = (f₂ ∘ f₁)* = f₁* ∘ f₂*

  where f_i* is the transpose Jacobian of f_i.

  This reversed composition order IS backpropagation.

We verify numerically:
  1. Compute the full Jacobian J_F and its transpose (cotangent lift of F).
  2. Compute the product J₁ᵀ · J₂ᵀ (backprop: reversed transpose Jacobians).
  3. Show they are identical (up to floating-point precision).
"""

import numpy as np


def layer1(x: np.ndarray) -> np.ndarray:
    """
    Layer f₁ : ℝ² → ℝ³
    A smooth nonlinear map (using tanh activation).
    In the cotangent bundle picture, this is a smooth map between manifolds.
    """
    W1 = np.array([[0.5, -0.3],
                    [0.8,  0.1],
                    [-0.2, 0.7]])
    b1 = np.array([0.1, -0.2, 0.3])
    return np.tanh(W1 @ x + b1)


def layer2(x: np.ndarray) -> np.ndarray:
    """
    Layer f₂ : ℝ³ → ℝ²
    Another smooth nonlinear map.
    """
    W2 = np.array([[0.4, -0.6, 0.2],
                    [0.3,  0.5, -0.1]])
    b2 = np.array([-0.1, 0.2])
    return np.tanh(W2 @ x + b2)


def jacobian(f, x: np.ndarray, eps: float = 1e-7) -> np.ndarray:
    """
    Numerically compute the Jacobian df_x via finite differences.
    This approximates the differential (tangent map) df : T_x M → T_{f(x)} N.
    """
    y0 = f(x)
    n = x.shape[0]
    m = y0.shape[0]
    J = np.zeros((m, n))
    for i in range(n):
        dx = np.zeros(n)
        dx[i] = eps
        J[:, i] = (f(x + dx) - f(x - dx)) / (2 * eps)
    return J


def cotangent_lift(J: np.ndarray) -> np.ndarray:
    """
    The cotangent lift f* is the transpose of the Jacobian.

    If df : T_x M → T_{f(x)} N  is the tangent map (Jacobian J),
    then f* : T*_{f(x)} N → T*_x M  is Jᵀ (transpose Jacobian).

    This is because covectors (elements of T*) transform contravariantly:
      (f*ω)(v) = ω(df · v)  ⟹  f*ω = Jᵀ · ω
    """
    return J.T


def main():
    print("=" * 65)
    print("  BACKPROPAGATION = COTANGENT LIFT OF THE FORWARD MAP")
    print("=" * 65)
    print()

    # Choose a point x ∈ ℝ² (a point on our "input manifold")
    x = np.array([0.7, -0.4])
    print(f"Input point x = {x}")
    print()

    # ─── Forward pass: F = f₂ ∘ f₁ ───
    h = layer1(x)           # Intermediate: h = f₁(x)
    y = layer2(h)           # Output: y = f₂(f₁(x)) = F(x)
    print(f"Hidden activation h = f₁(x) = {np.round(h, 6)}")
    print(f"Output y = F(x) = f₂(f₁(x)) = {np.round(y, 6)}")
    print()

    # ─── Compute Jacobians (tangent maps) ───
    J1 = jacobian(layer1, x)       # df₁ at x
    J2 = jacobian(layer2, h)       # df₂ at h = f₁(x)

    # Full Jacobian of composition
    F = lambda x_: layer2(layer1(x_))
    J_F = jacobian(F, x)           # d(f₂ ∘ f₁) at x

    print("Jacobian J₁ = df₁(x):")
    print(np.round(J1, 6))
    print()
    print("Jacobian J₂ = df₂(f₁(x)):")
    print(np.round(J2, 6))
    print()

    # ─── METHOD 1: Direct cotangent lift of F ───
    # F* = (dF)ᵀ = J_Fᵀ
    F_star_direct = cotangent_lift(J_F)

    # ─── METHOD 2: Backpropagation = reversed composition of cotangent lifts ───
    # (f₂ ∘ f₁)* = f₁* ∘ f₂*  (contravariant functoriality!)
    # = J₁ᵀ · J₂ᵀ
    f1_star = cotangent_lift(J1)   # f₁* = J₁ᵀ
    f2_star = cotangent_lift(J2)   # f₂* = J₂ᵀ
    F_star_backprop = f1_star @ f2_star  # Composition in REVERSED order

    print("─" * 65)
    print("KEY RESULT: Cotangent lift = Backpropagation")
    print("─" * 65)
    print()
    print("Method 1 — Direct cotangent lift F* = J_Fᵀ:")
    print(np.round(F_star_direct, 6))
    print()
    print("Method 2 — Backprop: f₁* ∘ f₂* = J₁ᵀ · J₂ᵀ:")
    print(np.round(F_star_backprop, 6))
    print()

    # ─── Verify equality ───
    error = np.max(np.abs(F_star_direct - F_star_backprop))
    print(f"Max absolute error: {error:.2e}")
    assert error < 1e-5, f"Mismatch! Error = {error}"
    print("✓ VERIFIED: Both methods agree (within numerical precision).")
    print()

    # ─── Demonstrate with a covector (gradient) ───
    print("─" * 65)
    print("GRADIENT COMPUTATION EXAMPLE")
    print("─" * 65)
    print()

    # A loss covector ω ∈ T*_y ℝ² (e.g., gradient of scalar loss w.r.t. output)
    omega = np.array([1.0, -0.5])
    print(f"Loss gradient (covector) ω ∈ T*_y ℝ² = {omega}")
    print()

    # Backprop pulls ω back to T*_x ℝ²:
    #   F*(ω) = f₁*(f₂*(ω)) = J₁ᵀ(J₂ᵀ · ω)
    grad_h = f2_star @ omega       # Step 1: Pull back through f₂
    grad_x = f1_star @ grad_h      # Step 2: Pull back through f₁

    # Direct computation:
    grad_x_direct = F_star_direct @ omega

    print(f"Backprop step 1: f₂*(ω) = J₂ᵀ · ω = {np.round(grad_h, 6)}")
    print(f"Backprop step 2: f₁*(f₂*(ω)) = J₁ᵀ · (J₂ᵀ · ω) = {np.round(grad_x, 6)}")
    print(f"Direct:  F*(ω) = J_Fᵀ · ω = {np.round(grad_x_direct, 6)}")
    print()
    print(f"Error: {np.max(np.abs(grad_x - grad_x_direct)):.2e}")
    print("✓ VERIFIED: Backpropagation computes the cotangent lift.")
    print()

    print("═" * 65)
    print("INSIGHT: The reverse order in backpropagation is not a choice —")
    print("it is FORCED by the contravariance of the cotangent functor")
    print("  T* : Man^op → VectBun")
    print()
    print("Composition of smooth maps:    F = f₂ ∘ f₁  (left to right)")
    print("Cotangent lift (= backprop):   F* = f₁* ∘ f₂*  (right to left)")
    print()
    print("This reversal is the mathematical essence of backpropagation.")
    print("═" * 65)


if __name__ == "__main__":
    main()
