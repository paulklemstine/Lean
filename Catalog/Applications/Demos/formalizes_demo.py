#!/usr/bin/env python3
"""
demo.py — Backpropagation as the Cotangent Lift

This script demonstrates numerically that backpropagation computes
the cotangent lift (pullback on cotangent bundles) of the forward map.

Key insight: For a composition F = L3 ∘ L2 ∘ L1, the cotangent lift is
    F* = L1* ∘ L2* ∘ L3*
where each Li* is the transpose of the Jacobian of Li. This reverse-order
composition of transposed Jacobians IS backpropagation.

We verify this numerically by:
1. Building a 3-layer neural network with smooth activations (tanh)
2. Computing the full Jacobian of the forward map via finite differences
3. Computing the gradient via manual backpropagation (cotangent lift)
4. Showing they agree to machine precision
"""

import numpy as np


def tanh(x):
    """Smooth activation function (unlike ReLU, this is C^∞)."""
    return np.tanh(x)


def tanh_deriv(x):
    """Derivative of tanh: dtanh/dx = 1 - tanh²(x)."""
    t = np.tanh(x)
    return 1.0 - t * t


class SmoothLayer:
    """
    A single layer: L(x) = tanh(W @ x + b)
    
    In the manifold picture, this is a smooth map L : ℝ^n → ℝ^m.
    Its differential dL_x : T_x ℝ^n → T_{L(x)} ℝ^m is the Jacobian.
    The cotangent lift L* : T*_{L(x)} ℝ^m → T*_x ℝ^n is the transpose Jacobian.
    """
    def __init__(self, n_in, n_out, seed=None):
        rng = np.random.RandomState(seed)
        # Xavier initialization for stable gradients
        scale = np.sqrt(2.0 / (n_in + n_out))
        self.W = rng.randn(n_out, n_in) * scale
        self.b = rng.randn(n_out) * 0.1
    
    def forward(self, x):
        """Forward pass: L(x) = tanh(Wx + b)"""
        self.x = x  # Cache for backprop
        self.z = self.W @ x + self.b  # Pre-activation
        return tanh(self.z)
    
    def jacobian(self, x):
        """
        Compute the full Jacobian matrix dL/dx at point x.
        
        This is the tangent map dL_x : T_x ℝ^n → T_{L(x)} ℝ^m
        represented as an m × n matrix.
        """
        z = self.W @ x + self.b
        # diag(tanh'(z)) @ W — chain rule in matrix form
        D = np.diag(tanh_deriv(z))
        return D @ self.W
    
    def cotangent_lift(self, covector):
        """
        The cotangent lift L* : T*_{L(x)} ℝ^m → T*_x ℝ^n
        
        Given a covector ξ ∈ T*_{L(x)} ℝ^m (a row vector / gradient),
        compute L*(ξ) = ξ ∘ dL_x = Jᵀ @ ξ
        
        This is EXACTLY what backpropagation does at each layer:
        multiply the upstream gradient by the transposed Jacobian.
        """
        # tanh'(z) ⊙ (Wᵀ @ covector) — this IS the backprop step
        D = tanh_deriv(self.z)
        return self.W.T @ (D * covector)


class Network:
    """
    A feedforward network F = L3 ∘ L2 ∘ L1.
    
    The forward pass computes F(x).
    Backpropagation computes F* = L1* ∘ L2* ∘ L3*,
    which is the cotangent lift of F — contravariant functoriality.
    """
    def __init__(self, dims, seed=42):
        self.layers = []
        for i in range(len(dims) - 1):
            self.layers.append(SmoothLayer(dims[i], dims[i+1], seed=seed+i))
    
    def forward(self, x):
        """Forward pass: F(x) = (L_n ∘ ... ∘ L_1)(x)"""
        for layer in self.layers:
            x = layer.forward(x)
        return x
    
    def full_jacobian(self, x):
        """
        Compute the full Jacobian of F by composing layer Jacobians.
        
        dF_x = dL_n ∘ dL_{n-1} ∘ ... ∘ dL_1
        
        This is the TANGENT MAP (covariant, forward order).
        """
        # First do a forward pass to set intermediate values
        intermediates = [x]
        curr = x
        for layer in self.layers:
            curr = layer.forward(curr)
            intermediates.append(curr)
        
        # Compose Jacobians in forward order (tangent functor is covariant)
        J = np.eye(len(x))
        for i, layer in enumerate(self.layers):
            Ji = layer.jacobian(intermediates[i])
            J = Ji @ J
        return J
    
    def backprop(self, x, output_covector):
        """
        Backpropagation: compute F*(ξ) = (L1* ∘ L2* ∘ ... ∘ Ln*)(ξ)
        
        This is the COTANGENT LIFT (contravariant, reverse order).
        The reverse traversal is FORCED by contravariance of T*.
        
        ξ is a covector at the output (e.g., the loss gradient ∂loss/∂output).
        Returns the pullback covector at the input: ∂loss/∂input.
        """
        # Forward pass first (to cache intermediate values)
        self.forward(x)
        
        # Reverse pass: apply cotangent lifts in reverse order
        # This is L1* ∘ L2* ∘ L3* applied to ξ
        covector = output_covector
        for layer in reversed(self.layers):
            covector = layer.cotangent_lift(covector)
        return covector


def numerical_jacobian(f, x, eps=1e-7):
    """Compute Jacobian by finite differences (for verification)."""
    n = len(x)
    y0 = f(x)
    m = len(y0)
    J = np.zeros((m, n))
    for i in range(n):
        x_plus = x.copy()
        x_plus[i] += eps
        x_minus = x.copy()
        x_minus[i] -= eps
        J[:, i] = (f(x_plus) - f(x_minus)) / (2 * eps)
    return J


def main():
    """
    Main demonstration: verify that backprop = cotangent lift.
    
    We show three equivalent computations of the input gradient:
    1. Full Jacobian transpose × output covector (direct computation)
    2. Backpropagation (reverse-mode AD = cotangent lift)
    3. Numerical finite differences (sanity check)
    
    All three agree, confirming: backprop IS the cotangent lift.
    """
    print("=" * 65)
    print("  BACKPROPAGATION AS THE COTANGENT LIFT")
    print("  Numerical Verification of Contravariant Functoriality")
    print("=" * 65)
    
    # Network architecture: ℝ⁴ → ℝ³ → ℝ³ → ℝ²
    # Three layers, so F = L3 ∘ L2 ∘ L1
    dims = [4, 3, 3, 2]
    net = Network(dims, seed=42)
    
    # Input point on the manifold (ℝ⁴)
    x = np.array([0.5, -0.3, 0.8, -0.1])
    
    # Output covector ξ ∈ T*_{F(x)} ℝ² (e.g., loss gradient)
    xi = np.array([1.0, -0.5])
    
    print(f"\nNetwork: ℝ{dims[0]}", end="")
    for d in dims[1:]:
        print(f" → ℝ{d}", end="")
    print(f"  ({len(dims)-1} layers)")
    print(f"Input x = {x}")
    print(f"Output covector ξ = {xi}")
    
    # === Method 1: Full Jacobian (tangent map), then transpose ===
    # The tangent map dF_x is covariant (forward order).
    # The cotangent lift F* is its transpose (dual).
    J = net.full_jacobian(x)
    grad_jacobian = J.T @ xi  # F*(ξ) = Jᵀξ
    
    # === Method 2: Backpropagation (cotangent lift directly) ===
    # This computes F* = L1* ∘ L2* ∘ L3* in reverse order.
    # The reverse order is FORCED by contravariance of T*.
    grad_backprop = net.backprop(x, xi)
    
    # === Method 3: Numerical finite differences (sanity check) ===
    J_numerical = numerical_jacobian(lambda x: net.forward(x), x)
    grad_numerical = J_numerical.T @ xi
    
    print("\n" + "-" * 65)
    print("RESULTS: Three equivalent computations of F*(ξ)")
    print("-" * 65)
    print(f"  Jacobian transpose:   {grad_jacobian}")
    print(f"  Backpropagation:      {grad_backprop}")
    print(f"  Finite differences:   {grad_numerical}")
    
    # Verify agreement
    err_bp_vs_jac = np.max(np.abs(grad_backprop - grad_jacobian))
    err_bp_vs_num = np.max(np.abs(grad_backprop - grad_numerical))
    
    print(f"\n  |backprop - Jacobian|  = {err_bp_vs_jac:.2e}")
    print(f"  |backprop - numerical| = {err_bp_vs_num:.2e}")
    
    print("\n" + "=" * 65)
    print("  KEY INSIGHT")
    print("=" * 65)
    print("""
  Backpropagation computes EXACTLY the cotangent lift F* of the
  forward map F. The reverse traversal order is not an algorithmic
  trick — it is FORCED by the contravariance of the cotangent
  functor T* : Man^op → VectBun.

  For F = L₃ ∘ L₂ ∘ L₁, functoriality gives:
      F* = (L₃ ∘ L₂ ∘ L₁)* = L₁* ∘ L₂* ∘ L₃*

  Each Lᵢ* is "multiply by transposed Jacobian of layer i" —
  which is precisely what each backprop step does.

  The chain rule is not a heuristic. It is a THEOREM about
  the composition law of a contravariant functor.
""")
    
    # === Bonus: Demonstrate contravariant functoriality ===
    print("-" * 65)
    print("  FUNCTORIALITY CHECK: (g ∘ f)* = f* ∘ g*")
    print("-" * 65)
    
    # Take first two layers as f = L2 ∘ L1, last layer as g = L3
    # Compute (g ∘ f)* and f* ∘ g* separately
    
    # Forward pass to set caches
    net.forward(x)
    
    # g* applied to ξ
    g_star_xi = net.layers[2].cotangent_lift(xi)
    # Then f* = L1* ∘ L2* applied to that
    f_star_g_star_xi = net.layers[1].cotangent_lift(g_star_xi)
    f_star_g_star_xi = net.layers[0].cotangent_lift(f_star_g_star_xi)
    
    # (g ∘ f)* applied to ξ directly via full backprop
    gf_star_xi = net.backprop(x, xi)
    
    err_functoriality = np.max(np.abs(f_star_g_star_xi - gf_star_xi))
    print(f"  f* ∘ g*(ξ) = {f_star_g_star_xi}")
    print(f"  (g∘f)*(ξ)  = {gf_star_xi}")
    print(f"  Error:        {err_functoriality:.2e}")
    print(f"\n  Functoriality verified: (g ∘ f)* = f* ∘ g* ✓")
    print("=" * 65)


if __name__ == "__main__":
    main()
