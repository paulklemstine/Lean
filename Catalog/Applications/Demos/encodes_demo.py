#!/usr/bin/env python3
"""
Backpropagation as the Cotangent Lift — Numerical Demonstration

This script demonstrates that backpropagation is exactly the cotangent lift
(pullback on cotangent bundles) of the forward map. We show this by:

1. Defining a simple 3-layer neural network as a composition of smooth maps.
2. Computing gradients via the chain rule in "forward mode" (tangent map).
3. Computing gradients via backpropagation (cotangent lift / pullback).
4. Verifying they produce identical results.
5. Demonstrating the key structural property: contravariant functoriality
   reverses the order of composition, which IS backpropagation.

Mathematical correspondence:
  - Forward pass:  Φ = f₃ ∘ f₂ ∘ f₁       (covariant, left-to-right)
  - Backprop:      Φ* = f₁* ∘ f₂* ∘ f₃*   (contravariant, right-to-left)
  - The cotangent functor T* : Man^op → VectBun reverses composition order.
"""

import numpy as np


def sigmoid(x):
    """Smooth activation function (a diffeomorphism on its image)."""
    return 1.0 / (1.0 + np.exp(-np.clip(x, -500, 500)))


def sigmoid_deriv(x):
    """Derivative of sigmoid: σ'(x) = σ(x)(1 - σ(x))."""
    s = sigmoid(x)
    return s * (1.0 - s)


def relu(x):
    """ReLU activation — piecewise linear, tropical max-plus structure."""
    return np.maximum(0, x)


def relu_deriv(x):
    """Subgradient of ReLU."""
    return (x > 0).astype(float)


# =============================================================================
# Layer definitions: each layer is a smooth (or piecewise smooth) map
# f_i : R^{d_{i-1}} -> R^{d_i}
# =============================================================================

class AffineLayer:
    """
    An affine map f(x) = Wx + b, viewed as a smooth map between Euclidean spaces.
    
    In the manifold picture:
      - Forward map (tangent lift):  Tf(v) = W @ v
      - Cotangent lift (pullback):   f*(α) = Wᵀ @ α
    
    The cotangent lift is the transpose — this is why backprop uses transposed
    weight matrices!
    """
    def __init__(self, W, b):
        self.W = W
        self.b = b
    
    def forward(self, x):
        """Forward map: f(x) = Wx + b"""
        return self.W @ x + self.b
    
    def tangent_map(self, v):
        """Tangent map (pushforward): Tf(v) = Wv — covariant."""
        return self.W @ v
    
    def cotangent_lift(self, alpha):
        """Cotangent lift (pullback): f*(α) = Wᵀα — contravariant!"""
        return self.W.T @ alpha


class ActivationLayer:
    """
    A pointwise activation: f(x) = σ(x) applied componentwise.
    
    This is a diffeomorphism (for sigmoid) or piecewise smooth map (for ReLU).
    The Jacobian is diagonal: J = diag(σ'(x₁), ..., σ'(xₙ)).
    
    Tangent map:   Tf(v) = diag(σ'(xᵢ)) @ v
    Cotangent lift: f*(α) = diag(σ'(xᵢ)) @ α   (self-adjoint for diagonal!)
    """
    def __init__(self, activation='sigmoid'):
        self.activation = activation
        self._last_input = None
    
    def forward(self, x):
        self._last_input = x.copy()
        if self.activation == 'sigmoid':
            return sigmoid(x)
        else:
            return relu(x)
    
    def _deriv(self):
        if self.activation == 'sigmoid':
            return sigmoid_deriv(self._last_input)
        else:
            return relu_deriv(self._last_input)
    
    def tangent_map(self, v):
        """Tangent map: multiply by diagonal Jacobian."""
        return self._deriv() * v
    
    def cotangent_lift(self, alpha):
        """Cotangent lift: for diagonal Jacobian, same as tangent map."""
        return self._deriv() * alpha


# =============================================================================
# Neural Network as a composition of smooth maps
# =============================================================================

class NeuralNetwork:
    """
    A feedforward neural network: Φ = fₙ ∘ ... ∘ f₁
    
    This is a morphism in the category of smooth manifolds (or piecewise smooth
    manifolds for ReLU networks).
    """
    def __init__(self, layers):
        self.layers = layers
    
    def forward(self, x):
        """
        Forward pass: apply layers left-to-right.
        Φ(x) = fₙ(fₙ₋₁(...f₁(x)...))
        
        This is the COVARIANT direction — following the tangent functor T.
        """
        activations = [x]
        for layer in self.layers:
            x = layer.forward(x)
            activations.append(x)
        return x, activations
    
    def backprop(self, loss_gradient):
        """
        Backpropagation: apply cotangent lifts right-to-left.
        Φ*(α) = f₁* ∘ f₂* ∘ ... ∘ fₙ*(α)
        
        This is the CONTRAVARIANT direction — following the cotangent functor T*.
        The reversal of order is not a computational trick — it is a mathematical
        NECESSITY forced by contravariant functoriality!
        """
        alpha = loss_gradient
        print("  Backpropagation (cotangent lift) traversal:")
        for i, layer in enumerate(reversed(self.layers)):
            layer_idx = len(self.layers) - 1 - i
            alpha = layer.cotangent_lift(alpha)
            print(f"    f_{layer_idx}*(α) = {alpha}")
        return alpha
    
    def forward_mode_gradient(self, direction):
        """
        Forward-mode AD: apply tangent maps left-to-right.
        TΦ(v) = Tfₙ ∘ ... ∘ Tf₁(v)
        
        This is the COVARIANT direction — same order as the forward pass.
        Computing one directional derivative at a time.
        """
        v = direction
        print("  Forward-mode (tangent map) traversal:")
        for i, layer in enumerate(self.layers):
            v = layer.tangent_map(v)
            print(f"    Tf_{i}(v) = {v}")
        return v


def compute_full_jacobian_forward(net, x, input_dim, output_dim):
    """Compute full Jacobian using forward-mode AD (one pass per input dim)."""
    net.forward(x)  # cache activations
    J = np.zeros((output_dim, input_dim))
    for j in range(input_dim):
        e_j = np.zeros(input_dim)
        e_j[j] = 1.0
        # Reset activations for each direction
        net.forward(x)
        J[:, j] = net.forward_mode_gradient(e_j)
    return J


def compute_full_jacobian_reverse(net, x, input_dim, output_dim):
    """Compute full Jacobian using reverse-mode AD (one pass per output dim)."""
    J = np.zeros((output_dim, input_dim))
    for i in range(output_dim):
        e_i = np.zeros(output_dim)
        e_i[i] = 1.0
        net.forward(x)  # refresh cached activations
        J[i, :] = net.backprop(e_i)
    return J


# =============================================================================
# Main demonstration
# =============================================================================

def main():
    """
    KEY INSIGHT: Backpropagation is not merely an efficient algorithm for
    computing gradients — it is the unique algorithm dictated by the
    contravariant functoriality of the cotangent bundle functor:
    
        T* : Man^op → VectBun
        
    Given Φ = f₃ ∘ f₂ ∘ f₁, the cotangent functor yields:
        Φ* = f₁* ∘ f₂* ∘ f₃*
        
    This reversal of composition order IS backpropagation.
    The reverse traversal is not a choice — it is a theorem.
    """
    
    np.random.seed(42)
    
    print("=" * 70)
    print("BACKPROPAGATION AS THE COTANGENT LIFT")
    print("Demonstrating contravariant functoriality of T*")
    print("=" * 70)
    
    # Network architecture: R³ → R⁴ → R² → R²
    # Three layers with sigmoid activations
    d0, d1, d2, d3 = 3, 4, 2, 2
    
    W1 = np.random.randn(d1, d0) * 0.5
    b1 = np.random.randn(d1) * 0.1
    W2 = np.random.randn(d2, d1) * 0.5
    b2 = np.random.randn(d2) * 0.1
    W3 = np.random.randn(d3, d2) * 0.5
    b3 = np.random.randn(d3) * 0.1
    
    # Build network as composition of smooth maps
    layers = [
        AffineLayer(W1, b1),     # f₀: R³ → R⁴
        ActivationLayer('sigmoid'),  # f₁: R⁴ → R⁴ (pointwise)
        AffineLayer(W2, b2),     # f₂: R⁴ → R²
        ActivationLayer('sigmoid'),  # f₃: R² → R² (pointwise)
        AffineLayer(W3, b3),     # f₄: R² → R²
        ActivationLayer('sigmoid'),  # f₅: R² → R² (pointwise)
    ]
    
    net = NeuralNetwork(layers)
    x = np.array([1.0, -0.5, 0.3])
    
    # =========================================================================
    # DEMONSTRATION 1: Forward pass vs backward pass direction
    # =========================================================================
    print("\n--- FORWARD PASS (covariant: left-to-right) ---")
    output, activations = net.forward(x)
    print(f"  Input:  x = {x}")
    print(f"  Output: Φ(x) = {output}")
    
    print("\n--- BACKWARD PASS (contravariant: right-to-left) ---")
    loss_grad = np.array([1.0, 0.0])  # ∂ℓ/∂y = e₁ (gradient of first output)
    print(f"  Loss gradient (covector at output): α = {loss_grad}")
    input_grad = net.backprop(loss_grad)
    print(f"  Input gradient (covector at input):  Φ*(α) = {input_grad}")
    
    # =========================================================================
    # DEMONSTRATION 2: Forward-mode vs reverse-mode give same Jacobian
    # =========================================================================
    print("\n" + "=" * 70)
    print("VERIFICATION: Forward-mode and reverse-mode yield the same Jacobian")
    print("(Tangent map TΦ and cotangent lift Φ* are adjoint: ⟨Φ*(α), v⟩ = ⟨α, TΦ(v)⟩)")
    print("=" * 70)
    
    print("\nComputing Jacobian via forward-mode (tangent map, covariant)...")
    J_forward = compute_full_jacobian_forward(net, x, d0, d3)
    
    print("\nComputing Jacobian via reverse-mode (cotangent lift, contravariant)...")
    J_reverse = compute_full_jacobian_reverse(net, x, d0, d3)
    
    print(f"\n  Jacobian (forward-mode):\n{J_forward}")
    print(f"\n  Jacobian (reverse-mode / backprop):\n{J_reverse}")
    print(f"\n  Maximum difference: {np.max(np.abs(J_forward - J_reverse)):.2e}")
    print(f"  Match: {np.allclose(J_forward, J_reverse)}")
    
    # =========================================================================
    # DEMONSTRATION 3: Contravariant functoriality
    # =========================================================================
    print("\n" + "=" * 70)
    print("CONTRAVARIANT FUNCTORIALITY: (g ∘ f)* = f* ∘ g*")
    print("=" * 70)
    
    # Split network into two halves
    net_first = NeuralNetwork(layers[:3])   # f = first 3 layers
    net_second = NeuralNetwork(layers[3:])  # g = last 3 layers
    
    # Forward pass through first half to get intermediate point
    mid, _ = net_first.forward(x)
    
    # Now test (g ∘ f)* = f* ∘ g*
    alpha = np.array([0.7, -0.3])  # arbitrary covector at output
    
    # Method 1: (g ∘ f)*(α) — backprop through entire network
    net.forward(x)
    grad_composed = net.backprop(alpha)
    
    # Method 2: f* ∘ g*(α) — backprop through g, then through f
    net_second.forward(mid)
    grad_g_star = net_second.backprop(alpha)
    net_first.forward(x)
    grad_f_star_g_star = net_first.backprop(grad_g_star)
    
    print(f"\n  (g ∘ f)*(α) = {grad_composed}")
    print(f"  f*(g*(α))   = {grad_f_star_g_star}")
    print(f"  Difference:   {np.max(np.abs(grad_composed - grad_f_star_g_star)):.2e}")
    print(f"  Functoriality verified: {np.allclose(grad_composed, grad_f_star_g_star)}")
    
    # =========================================================================
    # KEY INSIGHT SUMMARY
    # =========================================================================
    print("\n" + "=" * 70)
    print("KEY INSIGHT")
    print("=" * 70)
    print("""
    Backpropagation is NOT an algorithm that someone cleverly invented.
    It is the UNIQUE procedure dictated by a mathematical theorem:
    
        The cotangent bundle functor T* : Man^op → VectBun
        is contravariant, so it reverses the order of composition.
    
    Given a network  Φ = fₙ ∘ ... ∘ f₁  (forward: left to right),
    the gradient is  Φ* = f₁* ∘ ... ∘ fₙ* (backward: right to left).
    
    This reversal IS backpropagation. The algorithm is forced by
    the categorical structure of differential geometry.
    
    In the Lean 4 formalization, this is captured by the theorem
    `backprop_cotangent_lift`, which witnesses the mathematical
    validity of this identification.
    """)


if __name__ == "__main__":
    main()
