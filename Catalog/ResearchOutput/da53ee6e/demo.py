#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift

This script demonstrates numerically that backpropagation through a
multi-layer network is identical to applying the cotangent lift (transpose
Jacobian) of each layer in reverse order.

Mathematical correspondence:
  Forward pass:  y = f_L ∘ f_{L-1} ∘ ... ∘ f_1 (x)
  Backprop:      ∇_x L = (df_1)^T ∘ (df_2)^T ∘ ... ∘ (df_L)^T (∇_y L)
                        = T*f_1 ∘ T*f_2 ∘ ... ∘ T*f_L (dL)

The reversal of composition order is the hallmark of a *contravariant functor*
— the cotangent bundle functor T* on the category of smooth manifolds.

Usage:
    python3 demo.py
"""

import numpy as np

# ──────────────────────────────────────────────────────────────────────
# Layer definitions: each layer is a smooth map f_ℓ : ℝ^{n_{ℓ-1}} → ℝ^{n_ℓ}
# We use affine + tanh layers for concreteness.
# ──────────────────────────────────────────────────────────────────────

def affine_tanh_forward(x, W, b):
    """Forward map: f(x) = tanh(Wx + b)."""
    z = W @ x + b
    return np.tanh(z), z  # return pre-activation for Jacobian computation


def affine_tanh_jacobian(z, W):
    """
    Jacobian df/dx of f(x) = tanh(Wx + b).
    df/dx = diag(1 - tanh²(z)) · W
    This is the tangent map (pushforward) Tf at x.
    """
    dtanh = 1.0 - np.tanh(z) ** 2  # derivative of tanh
    return np.diag(dtanh) @ W


def cotangent_lift(jacobian, covector):
    """
    Cotangent lift T*f: T*N → T*M.
    Given a covector ξ ∈ T*_{f(x)}N, compute T*f(ξ) = ξ · J = J^T ξ.
    
    This is the KEY operation: the transpose Jacobian acting on covectors.
    In coordinates, (T*f)(ξ)_i = Σ_j ξ_j · (∂f_j/∂x_i)
    """
    return jacobian.T @ covector


# ──────────────────────────────────────────────────────────────────────
# Build a 3-layer network: ℝ⁴ → ℝ³ → ℝ³ → ℝ²
# ──────────────────────────────────────────────────────────────────────

def main():
    np.random.seed(42)
    
    print("=" * 70)
    print("  BACKPROPAGATION = COTANGENT LIFT")
    print("  Numerical verification of the categorical correspondence")
    print("=" * 70)
    
    # Network architecture
    dims = [4, 3, 3, 2]
    L = len(dims) - 1  # number of layers
    
    # Random weights and biases
    weights = []
    biases = []
    for ell in range(L):
        W = np.random.randn(dims[ell + 1], dims[ell]) * 0.5
        b = np.random.randn(dims[ell + 1]) * 0.1
        weights.append(W)
        biases.append(b)
    
    # Input
    x = np.random.randn(dims[0])
    
    # ── FORWARD PASS ──────────────────────────────────────────────────
    # Compute f = f_L ∘ ... ∘ f_1 and store intermediate values
    print(f"\n📐 Network: ℝ^{dims[0]}", end="")
    for d in dims[1:]:
        print(f" → ℝ^{d}", end="")
    print(f"  ({L} layers)\n")
    
    activations = [x]
    pre_activations = []
    jacobians = []
    
    h = x
    for ell in range(L):
        h_new, z = affine_tanh_forward(h, weights[ell], biases[ell])
        J = affine_tanh_jacobian(z, weights[ell])
        activations.append(h_new)
        pre_activations.append(z)
        jacobians.append(J)
        h = h_new
    
    y = h  # final output
    print(f"  Input  x = {x}")
    print(f"  Output y = f(x) = {y}")
    
    # ── LOSS AND ITS DIFFERENTIAL ─────────────────────────────────────
    # Loss: L(y) = ½ ||y - target||²
    # dL_y = y - target  (a covector in T*_{y} ℝ²)
    target = np.array([1.0, -1.0])
    loss = 0.5 * np.sum((y - target) ** 2)
    dL_y = y - target  # ∈ T*_{f(x)} M_L
    
    print(f"\n  Loss ℒ(y) = ½||y - target||² = {loss:.6f}")
    print(f"  dℒ_y = {dL_y}  (terminal covector)")
    
    # ── METHOD 1: FULL JACOBIAN (tangent approach) ────────────────────
    # Compute full Jacobian J = J_L · J_{L-1} · ... · J_1 (covariant)
    # Then gradient = J^T · dL_y
    J_full = np.eye(dims[0])
    for ell in range(L):
        J_full = jacobians[ell] @ J_full
    
    grad_full = J_full.T @ dL_y
    
    print(f"\n── Method 1: Full Jacobian (tangent then transpose) ──")
    print(f"  J_full = J₃ · J₂ · J₁  (shape {J_full.shape})")
    print(f"  ∇_x ℒ = J_full^T · dℒ = {grad_full}")
    
    # ── METHOD 2: COTANGENT LIFT (backpropagation) ────────────────────
    # Apply T*f_1 ∘ T*f_2 ∘ T*f_3 to dL_y
    # This IS backpropagation: propagate covectors backwards
    print(f"\n── Method 2: Cotangent Lift (backpropagation) ──")
    
    covector = dL_y
    print(f"  Start: ξ = dℒ_y = {covector}")
    
    for ell in reversed(range(L)):
        # Apply T*f_{ell+1}: cotangent lift of layer ell+1
        covector = cotangent_lift(jacobians[ell], covector)
        print(f"  After T*f_{ell+1}: ξ = {covector}")
    
    grad_backprop = covector
    
    # ── VERIFICATION ──────────────────────────────────────────────────
    print(f"\n── Verification ──")
    print(f"  Full Jacobian gradient:  {grad_full}")
    print(f"  Backprop gradient:       {grad_backprop}")
    
    error = np.linalg.norm(grad_full - grad_backprop)
    print(f"  ||difference||₂ = {error:.2e}")
    
    assert error < 1e-12, f"Mismatch! Error = {error}"
    
    print(f"\n✅ VERIFIED: Backpropagation = Cotangent Lift")
    print(f"   (error < 1e-12, consistent with floating-point arithmetic)")
    
    # ── KEY INSIGHT ───────────────────────────────────────────────────
    print(f"\n{'=' * 70}")
    print("  KEY INSIGHT")
    print("=" * 70)
    print("""
  The cotangent bundle functor T* : Man^op → Man is contravariant:
  
    T*(g ∘ f) = T*f ∘ T*g    (composition reverses!)
  
  For a network f = f_L ∘ ... ∘ f_1:
  
    T*f = T*f_1 ∘ ... ∘ T*f_L
  
  This reversed composition IS backpropagation. The algorithm is not
  an engineering trick — it is the functorial action of T* on morphisms
  in the category of smooth manifolds.
  
  Forward mode AD = tangent functor T  (covariant)
  Reverse mode AD = cotangent functor T* (contravariant)
  
  The duality between forward and reverse mode is precisely the
  duality between tangent and cotangent bundles in differential geometry.
""")
    
    # ── FUNCTORIALITY CHECK ───────────────────────────────────────────
    print("── Functoriality Check: T*(g ∘ f) = T*f ∘ T*g ──\n")
    
    # Pick two consecutive layers: f = f_1, g = f_2
    J_f = jacobians[0]  # Jacobian of f_1
    J_g = jacobians[1]  # Jacobian of f_2
    J_gf = J_g @ J_f    # Jacobian of g ∘ f
    
    # Test covector
    xi = np.random.randn(dims[2])
    
    # T*(g ∘ f)(ξ) = (J_{g∘f})^T ξ
    lhs = J_gf.T @ xi
    
    # T*f ∘ T*g (ξ) = J_f^T (J_g^T ξ)
    rhs = J_f.T @ (J_g.T @ xi)
    
    print(f"  T*(g∘f)(ξ)     = {lhs}")
    print(f"  T*f ∘ T*g (ξ)  = {rhs}")
    print(f"  ||diff||₂       = {np.linalg.norm(lhs - rhs):.2e}")
    print(f"\n  ✅ Contravariant functoriality confirmed!\n")


if __name__ == "__main__":
    main()
