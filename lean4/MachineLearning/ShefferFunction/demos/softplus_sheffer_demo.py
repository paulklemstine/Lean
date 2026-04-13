#!/usr/bin/env python3
"""
The Unary Sheffer Function: Computational Demonstrations

This script demonstrates that softplus σ(x) = log(1 + exp(x)),
combined with affine transformations, can approximate all elementary
functions. It provides concrete numerical evidence for the theory.

Usage:
    python softplus_sheffer_demo.py

Outputs numerical tables showing approximation quality.
"""

import numpy as np
from typing import Callable, Tuple

# =============================================================================
# Core Functions
# =============================================================================

def softplus(x: np.ndarray) -> np.ndarray:
    """The Sheffer activation: σ(x) = log(1 + exp(x))"""
    # Numerically stable implementation
    return np.where(x > 20, x, np.log1p(np.exp(np.clip(x, -500, 20))))

def sigmoid(x: np.ndarray) -> np.ndarray:
    """Derivative of softplus: σ'(x) = exp(x)/(1 + exp(x))"""
    return 1.0 / (1.0 + np.exp(-x))

def affine(a: float, b: float):
    """Create affine function x ↦ ax + b"""
    return lambda x: a * x + b

def compose(*funcs):
    """Compose functions: compose(f, g, h)(x) = f(g(h(x)))"""
    def composed(x):
        result = x
        for f in reversed(funcs):
            result = f(result)
        return result
    return composed

# =============================================================================
# Demo 1: Approximating exp(x) via softplus
# =============================================================================

def demo_exp_approximation():
    """
    Theorem (proved in Lean): exp(c) · σ(x - c) → exp(x) as c → ∞
    
    We demonstrate this with concrete values of c.
    """
    print("=" * 70)
    print("DEMO 1: Exponential Approximation")
    print("exp(c) · softplus(x - c) → exp(x) as c → ∞")
    print("=" * 70)
    
    x_test = np.array([-2.0, -1.0, 0.0, 1.0, 2.0])
    exact = np.exp(x_test)
    
    print(f"\n{'c':>6} | ", end="")
    for x in x_test:
        print(f"x={x:5.1f}     ", end="")
    print("\n" + "-" * 70)
    
    for c in [1, 2, 5, 10, 20]:
        approx = np.exp(c) * softplus(x_test - c)
        print(f"{c:6d} | ", end="")
        for i, x in enumerate(x_test):
            rel_err = abs(approx[i] - exact[i]) / exact[i] * 100
            print(f"{rel_err:8.4f}%   ", end="")
        print()
    
    print(f"\n{'exact':>6} | ", end="")
    for v in exact:
        print(f"{v:10.6f} ", end="")
    print()

# =============================================================================
# Demo 2: Approximating log(x) via softplus
# =============================================================================

def demo_log_approximation():
    """
    Using the reflection identity: softplus(x) = x + softplus(-x)
    We can extract: x = softplus(x) - softplus(-x)
    
    Combined with the exp approximation, we can build log.
    For positive x: log(x) ≈ softplus(log(x)) - softplus(-log(x))
    But we need log to compute log(x)...
    
    Alternative: Use the inverse relationship.
    If softplus approximates exp, then inverting the relationship gives log.
    Concretely: softplus(x) ≈ x for large x (linear regime).
    So: softplus(x - C) ≈ x - C for x >> C, giving identity.
    And: softplus(x) - x → 0 as x → ∞, so softplus captures "x" itself.
    
    For log: We use that if y = exp(x), then x = log(y).
    Since exp(c) · σ(y - c) ≈ exp(y) for large c,
    we can invert: log(z) ≈ the value y such that exp(c) · σ(y - c) = z.
    
    More directly: σ(x) ≈ exp(x) for x << 0 (exponential regime).
    So log(z) ≈ σ⁻¹(z) for small z > 0.
    But σ⁻¹(y) = log(exp(y) - 1) for y > 0.
    """
    print("\n" + "=" * 70)
    print("DEMO 2: Logarithm from Softplus")
    print("Using σ(x) ≈ exp(x) for x << 0, so σ⁻¹(z) ≈ log(z) for small z")
    print("σ⁻¹(y) = log(exp(y) - 1)")
    print("=" * 70)
    
    # softplus inverse: log(exp(y) - 1)
    def softplus_inv(y):
        return np.log(np.expm1(y))
    
    x_test = np.array([0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0])
    exact_log = np.log(x_test)
    
    # For small x: softplus(log(x)) ≈ x, so log(x) ≈ softplus_inv(x)
    approx_log = softplus_inv(x_test)
    
    print(f"\n{'x':>10} | {'log(x) exact':>14} | {'σ⁻¹(x)':>14} | {'error':>10}")
    print("-" * 60)
    for i, x in enumerate(x_test):
        err = abs(approx_log[i] - exact_log[i])
        print(f"{x:10.4f} | {exact_log[i]:14.8f} | {approx_log[i]:14.8f} | {err:10.2e}")

# =============================================================================
# Demo 3: Approximating sigmoid via softplus compositions
# =============================================================================

def demo_sigmoid_from_softplus():
    """
    sigmoid(x) = σ'(x), but also:
    sigmoid(x) = 1 - sigmoid(-x)
    
    Key identity: σ(x) - σ(-x) = x  (reflection identity, proved in Lean!)
    
    So we can build many functions from σ alone with affine ops.
    """
    print("\n" + "=" * 70)
    print("DEMO 3: Building Sigmoid from Softplus")
    print("Using the reflection identity: σ(x) - σ(-x) = x")
    print("And: exp(-σ(-x)) ≈ sigmoid(x) for large enough scaling")
    print("=" * 70)
    
    x_test = np.linspace(-5, 5, 11)
    
    # The derivative of softplus IS sigmoid
    # We approximate it via: [σ(x+ε) - σ(x-ε)] / (2ε)
    eps = 1e-6
    sigmoid_approx = (softplus(x_test + eps) - softplus(x_test - eps)) / (2 * eps)
    sigmoid_exact = sigmoid(x_test)
    
    print(f"\n{'x':>8} | {'sigmoid(x)':>12} | {'approx':>12} | {'error':>10}")
    print("-" * 50)
    for i, x in enumerate(x_test):
        err = abs(sigmoid_approx[i] - sigmoid_exact[i])
        print(f"{x:8.2f} | {sigmoid_exact[i]:12.8f} | {sigmoid_approx[i]:12.8f} | {err:10.2e}")

# =============================================================================
# Demo 4: Building ReLU from softplus
# =============================================================================

def demo_relu_approximation():
    """
    ReLU(x) = max(0, x) ≈ σ(βx)/β for large β.
    
    As β → ∞, softplus(βx)/β → ReLU(x).
    This shows that softplus is a smooth universal approximant to ReLU.
    """
    print("\n" + "=" * 70)
    print("DEMO 4: ReLU as a Limit of Softplus")
    print("ReLU(x) = lim_{β→∞} σ(βx)/β")
    print("=" * 70)
    
    x_test = np.linspace(-3, 3, 13)
    relu_exact = np.maximum(0, x_test)
    
    print(f"\n{'x':>6} | {'ReLU':>8} | ", end="")
    for beta in [1, 5, 10, 50]:
        print(f"β={beta:<4}    ", end="")
    print("\n" + "-" * 60)
    
    for i, x in enumerate(x_test):
        print(f"{x:6.2f} | {relu_exact[i]:8.4f} | ", end="")
        for beta in [1, 5, 10, 50]:
            approx = softplus(beta * x) / beta
            print(f"{approx:8.4f}  ", end="")
        print()

# =============================================================================
# Demo 5: Approximating sin(x) via softplus network
# =============================================================================

def demo_sin_approximation():
    """
    sin(x) can be approximated by a neural network with softplus activation.
    
    We use a simple 2-layer network:
    f(x) = Σᵢ wᵢ · σ(aᵢx + bᵢ) + c
    
    Fitted by least squares on a training set.
    """
    print("\n" + "=" * 70)
    print("DEMO 5: Approximating sin(x) with Softplus Network")
    print("f(x) = Σ wᵢ · σ(aᵢx + bᵢ) + c")
    print("=" * 70)
    
    # Simple approach: use random features (extreme learning machine)
    np.random.seed(42)
    n_neurons = 20
    
    # Random weights for hidden layer
    a = np.random.randn(n_neurons) * 2
    b = np.random.randn(n_neurons) * 2
    
    # Training data
    x_train = np.linspace(-2 * np.pi, 2 * np.pi, 200)
    y_train = np.sin(x_train)
    
    # Hidden layer features
    H = np.column_stack([softplus(ai * x_train + bi) for ai, bi in zip(a, b)])
    H = np.column_stack([H, np.ones(len(x_train))])  # bias
    
    # Solve least squares: y = H @ w
    w, _, _, _ = np.linalg.lstsq(H, y_train, rcond=None)
    
    # Test
    x_test = np.linspace(-2 * np.pi, 2 * np.pi, 50)
    y_exact = np.sin(x_test)
    H_test = np.column_stack([softplus(ai * x_test + bi) for ai, bi in zip(a, b)])
    H_test = np.column_stack([H_test, np.ones(len(x_test))])
    y_approx = H_test @ w
    
    max_err = np.max(np.abs(y_approx - y_exact))
    mean_err = np.mean(np.abs(y_approx - y_exact))
    
    print(f"\nNetwork: {n_neurons} softplus neurons")
    print(f"Domain: [-2π, 2π]")
    print(f"Max absolute error:  {max_err:.6f}")
    print(f"Mean absolute error: {mean_err:.6f}")
    
    print(f"\n{'x':>8} | {'sin(x)':>10} | {'approx':>10} | {'error':>10}")
    print("-" * 48)
    for i in range(0, len(x_test), 5):
        err = abs(y_approx[i] - y_exact[i])
        print(f"{x_test[i]:8.4f} | {y_exact[i]:10.6f} | {y_approx[i]:10.6f} | {err:10.6f}")

# =============================================================================
# Demo 6: The Composition Algebra — Self-Similarity
# =============================================================================

def demo_composition_algebra():
    """
    Demonstrate that compositions of softplus with affine maps
    produce a rich family of functions with recognizable shapes.
    """
    print("\n" + "=" * 70)
    print("DEMO 6: Composition Algebra — Self-Similarity Under Composition")
    print("=" * 70)
    
    x = np.linspace(-5, 5, 21)
    
    # σ(x) itself
    f1 = softplus(x)
    # σ(σ(x)) - still has the same S-curve character
    f2 = softplus(softplus(x))
    # σ(2x - 3) - shifted/scaled version
    f3 = softplus(2 * x - 3)
    # σ(σ(x) - 2) - composition with shift
    f4 = softplus(softplus(x) - 2)
    
    print(f"\n{'x':>6} | {'σ(x)':>8} | {'σ(σ(x))':>8} | {'σ(2x-3)':>8} | {'σ(σ(x)-2)':>10}")
    print("-" * 52)
    for i in range(len(x)):
        print(f"{x[i]:6.2f} | {f1[i]:8.4f} | {f2[i]:8.4f} | {f3[i]:8.4f} | {f4[i]:10.4f}")

# =============================================================================
# Demo 7: Key Identities (Verified in Lean 4)
# =============================================================================

def demo_verified_identities():
    """
    Numerically verify the identities that were formally proved in Lean 4.
    """
    print("\n" + "=" * 70)
    print("DEMO 7: Formally Verified Identities (Proved in Lean 4)")
    print("=" * 70)
    
    x_test = np.linspace(-10, 10, 21)
    
    print("\n1. Reflection: σ(x) = x + σ(-x)")
    print(f"   Max error: {np.max(np.abs(softplus(x_test) - (x_test + softplus(-x_test)))):.2e}")
    
    print("\n2. σ(x) ≥ x (softplus dominates identity)")
    violations = np.sum(softplus(x_test) < x_test - 1e-15)
    print(f"   Violations: {violations} out of {len(x_test)}")
    
    print("\n3. σ(x) ≥ 0 (softplus is nonneg)")
    violations = np.sum(softplus(x_test) < -1e-15)
    print(f"   Violations: {violations} out of {len(x_test)}")
    
    print("\n4. σ(0) = log(2)")
    print(f"   σ(0) = {softplus(np.array([0.0]))[0]:.15f}")
    print(f"   log(2) = {np.log(2):.15f}")
    print(f"   Error: {abs(softplus(np.array([0.0]))[0] - np.log(2)):.2e}")
    
    print("\n5. σ'(x) = sigmoid(x) = exp(x)/(1+exp(x))")
    eps = 1e-8
    numerical_deriv = (softplus(x_test + eps) - softplus(x_test - eps)) / (2 * eps)
    analytic_deriv = sigmoid(x_test)
    print(f"   Max derivative error: {np.max(np.abs(numerical_deriv - analytic_deriv)):.2e}")
    
    print("\n6. Strict monotonicity")
    diffs = np.diff(softplus(np.linspace(-100, 100, 10000)))
    print(f"   All consecutive differences > 0: {np.all(diffs > 0)}")
    
    print("\n7. For x ≤ 0: σ(x) ≤ exp(x)")
    x_neg = np.linspace(-10, 0, 100)
    violations = np.sum(softplus(x_neg) > np.exp(x_neg) + 1e-15)
    print(f"   Violations: {violations} out of {len(x_neg)}")

# =============================================================================
# Demo 8: Why Polynomial Activations Fail
# =============================================================================

def demo_polynomial_limitation():
    """
    Demonstrate the polynomial limitation theorem (proved in Lean 4):
    If σ is a polynomial, compositions with affine maps stay polynomial.
    """
    print("\n" + "=" * 70)
    print("DEMO 8: Polynomial Limitation (Proved in Lean 4)")
    print("Using σ(x) = x² as polynomial activation")
    print("=" * 70)
    
    def poly_sigma(x):
        return x ** 2
    
    x = np.linspace(-2, 2, 11)
    
    # Try to approximate sin(x) with polynomial compositions
    # σ(ax + b) = (ax + b)² = a²x² + 2abx + b²  — always quadratic!
    # σ(σ(ax + b)) = (a²x² + 2abx + b²)² — degree 4, still polynomial
    
    f1 = poly_sigma(x)
    f2 = poly_sigma(poly_sigma(x))
    f3 = poly_sigma(2 * poly_sigma(x) - 1)
    
    print(f"\n{'x':>6} | {'x²':>10} | {'(x²)²':>10} | {'(2x²-1)²':>10} | {'sin(x)':>10}")
    print("-" * 58)
    for i in range(len(x)):
        print(f"{x[i]:6.2f} | {f1[i]:10.4f} | {f2[i]:10.4f} | {f3[i]:10.4f} | {np.sin(x[i]):10.4f}")
    
    print("\nAll compositions of x² with affine maps produce polynomials.")
    print("They can NEVER produce sin(x), log(x), or exp(x) exactly.")
    print("This is why non-polynomial activations like softplus are essential!")

# =============================================================================
# Main
# =============================================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════════════════╗")
    print("║     THE UNARY SHEFFER FUNCTION: Computational Demonstrations       ║")
    print("║     σ(x) = log(1 + exp(x))  — The Universal Activation            ║")
    print("╚══════════════════════════════════════════════════════════════════════╝")
    
    demo_exp_approximation()
    demo_log_approximation()
    demo_sigmoid_from_softplus()
    demo_relu_approximation()
    demo_sin_approximation()
    demo_composition_algebra()
    demo_verified_identities()
    demo_polynomial_limitation()
    
    print("\n" + "=" * 70)
    print("ALL DEMOS COMPLETE")
    print("Key insight: softplus + affine maps = universal function generator")
    print("=" * 70)
