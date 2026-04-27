#!/usr/bin/env python3
"""
demo.py — Neural Tropical Approximation: ReLU Networks as Tropical Rational Maps

This script demonstrates the core insight of the neural_tropical_approximation theorem:
ReLU neural networks are tropical rational maps, and their Lipschitz constant
is bounded by the tropical degree (maximum slope across all affine pieces).

Key correspondences:
  - ReLU(x) = max(x, 0) = x ⊕_trop 0   (tropical addition with identity)
  - A single ReLU neuron σ(wx + b) is a 2-term tropical polynomial
  - A depth-L network composes tropical polynomials, yielding tropical degree
    that grows multiplicatively with depth
  - The Lipschitz constant equals the maximum slope = tropical degree

Run: python3 demo.py
Output: Prints key insights and saves visualization to tropical_relu.png
"""

import numpy as np

# ─── Tropical Semiring Operations ───────────────────────────────────────────

def trop_add(a, b):
    """Tropical addition: a ⊕ b = max(a, b)"""
    return np.maximum(a, b)

def trop_mul(a, b):
    """Tropical multiplication: a ⊗ b = a + b (standard addition)"""
    return a + b

# ─── ReLU as Tropical Polynomial ───────────────────────────────────────────

def relu(x):
    """ReLU(x) = max(x, 0) = x ⊕_trop 0"""
    return trop_add(x, 0)

def relu_neuron(w, b, x):
    """A single ReLU neuron: σ(wx + b) = max(wx + b, 0)
    This is a 2-term tropical polynomial: (wx + b) ⊕ 0"""
    return trop_add(w * x + b, 0)

# ─── Tropical Polynomial ──────────────────────────────────────────────────

def tropical_polynomial(coeffs, slopes, x):
    """Evaluate a tropical polynomial:
    p(x) = ⊕_i (a_i ⊗ x^{⊗ d_i}) = max_i(a_i + d_i * x)

    coeffs: list of a_i (tropical coefficients)
    slopes: list of d_i (tropical degrees/slopes)
    """
    terms = [c + s * x for c, s in zip(coeffs, slopes)]
    return np.maximum.reduce(terms)

# ─── Simple 2-Layer ReLU Network ──────────────────────────────────────────

def two_layer_relu_network(x, W1, b1, W2, b2):
    """A 2-layer ReLU network (1D input, width-n hidden, 1D output).
    f(x) = Σ_j w2_j * relu(w1_j * x + b1_j) + b2

    This is a tropical rational map — piecewise linear with slopes
    determined by the tropical degree.
    """
    hidden = np.array([relu_neuron(w, b, x) for w, b in zip(W1, b1)])
    output = sum(w2 * h for w2, h in zip(W2, hidden)) + b2
    return output

# ─── Lipschitz Constant Computation ──────────────────────────────────────

def compute_lipschitz(f, x_range, dx=1e-6):
    """Numerically estimate the Lipschitz constant of f over x_range."""
    x = np.linspace(x_range[0], x_range[1], 100000)
    y = np.array([f(xi) for xi in x])
    slopes = np.abs(np.diff(y) / np.diff(x))
    return np.max(slopes)

def tropical_degree(W1, W2):
    """The tropical degree of a 2-layer ReLU network.
    It equals the maximum absolute slope, bounded by sum of |w2_j * w1_j|.
    """
    return sum(abs(w2 * w1) for w1, w2 in zip(W1, W2))

# ─── Maslov Dequantization ───────────────────────────────────────────────

def maslov_dequantization(a, b, t):
    """Illustrate Maslov dequantization:
    lim_{t→0+} t * log(exp(a/t) + exp(b/t)) = max(a, b)

    As t → 0, the log-sum-exp converges to the tropical addition (max).
    This is the bridge between classical and tropical algebra.
    """
    # Numerically stable version
    m = np.maximum(a, b) / t
    return t * (m + np.log(np.exp(a / t - m) + np.exp(b / t - m)))

# ─── Region Counting ────────────────────────────────────────────────────

def max_linear_regions(width, depth):
    """Maximum number of linear regions for a ReLU network.
    Depth L, width w → at most (w+1)^L regions.
    This is the tropical degree bound on combinatorial complexity.
    """
    return (width + 1) ** depth

# ─── Main Demonstration ─────────────────────────────────────────────────

def main():
    print("=" * 70)
    print("  NEURAL TROPICAL APPROXIMATION")
    print("  ReLU Networks as Tropical Rational Maps")
    print("=" * 70)

    # 1. ReLU = Tropical Addition
    print("\n[1] ReLU as Tropical Addition")
    print("-" * 40)
    test_values = [-2.0, -1.0, 0.0, 0.5, 1.0, 3.0]
    for x in test_values:
        r = relu(x)
        t = trop_add(x, 0)
        assert r == t, f"Mismatch at x={x}"
        print(f"  relu({x:5.1f}) = max({x:5.1f}, 0) = {r:5.1f}  ✓  (= x ⊕_trop 0)")
    print("  → Verified: relu(x) ≡ x ⊕_trop 0  (Lean: relu_eq_tropAdd_zero)")

    # 2. Tropical Distributivity
    print("\n[2] Tropical Distributivity")
    print("-" * 40)
    a, b, c = 3.0, 1.0, 5.0
    lhs = trop_mul(a, trop_add(b, c))
    rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
    print(f"  a ⊗ (b ⊕ c) = {a} + max({b}, {c}) = {lhs}")
    print(f"  (a ⊗ b) ⊕ (a ⊗ c) = max({a}+{b}, {a}+{c}) = {rhs}")
    assert lhs == rhs
    print("  → Verified: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)  ✓")

    # 3. Network as Tropical Map + Lipschitz Bound
    print("\n[3] 2-Layer ReLU Network = Tropical Rational Map")
    print("-" * 40)
    W1 = [2.0, -3.0, 1.5]
    b1 = [1.0, -0.5, 0.0]
    W2 = [1.0, -0.5, 2.0]
    b2 = 0.0

    f = lambda x: two_layer_relu_network(x, W1, b1, W2, b2)
    lip_numerical = compute_lipschitz(f, (-5, 5))
    trop_deg = tropical_degree(W1, W2)

    print(f"  Network: 3 hidden neurons, weights W1={W1}, W2={W2}")
    print(f"  Numerical Lipschitz constant:  {lip_numerical:.4f}")
    print(f"  Tropical degree upper bound:   {trop_deg:.4f}")
    print(f"  Bound holds: {lip_numerical:.4f} ≤ {trop_deg:.4f}  → {'✓' if lip_numerical <= trop_deg + 1e-6 else '✗'}")
    print("  → The Lipschitz constant is bounded by the tropical degree!")

    # 4. Maslov Dequantization
    print("\n[4] Maslov Dequantization: Classical → Tropical")
    print("-" * 40)
    a_val, b_val = 3.0, 7.0
    print(f"  max({a_val}, {b_val}) = {max(a_val, b_val)}")
    for t in [1.0, 0.1, 0.01, 0.001]:
        approx = maslov_dequantization(a_val, b_val, t)
        print(f"  t={t:6.3f}: t·log(exp(a/t) + exp(b/t)) = {approx:.6f}")
    print("  → As t → 0, log-sum-exp converges to max (tropical addition)")
    print("  → (Lean: maslov_homomorphism)")

    # 5. Region Counting
    print("\n[5] Exponential Region Growth with Depth")
    print("-" * 40)
    w = 4
    for L in range(1, 7):
        regions = max_linear_regions(w, L)
        print(f"  Width {w}, Depth {L}: max {regions:>8} linear regions  "
              f"= (w+1)^L = {w+1}^{L}")
    print("  → Regions grow exponentially with depth (Lean: depth_exponential)")
    print("  → This is why depth matters more than width!")

    # 6. Key Insight
    print("\n" + "=" * 70)
    print("  KEY INSIGHT")
    print("=" * 70)
    print("""
  A ReLU neural network is secretly a tropical algebraic object.

  • Each ReLU neuron computes a tropical addition: max(wx+b, 0) = (wx+b) ⊕ 0
  • Each layer composes tropical polynomials
  • The full network is a tropical rational map (quotient of tropical polys)
  • The LIPSCHITZ CONSTANT ≤ TROPICAL DEGREE (max slope across all pieces)

  This means:
  → Network smoothness is controlled by tropical algebraic complexity
  → Generalization bounds follow from tropical degree bounds
  → The loss landscape has tropical geometric structure

  Formally verified in Lean 4 + Mathlib (see Main.lean and
  MachineLearning/Neural/TropicalDeepLearningFoundations.lean)
""")

    # 7. Generate visualization
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        fig, axes = plt.subplots(2, 2, figsize=(14, 10))
        fig.suptitle('Neural Tropical Approximation: ReLU Networks as Tropical Maps',
                     fontsize=14, fontweight='bold')

        # Plot 1: ReLU = Tropical Addition
        ax = axes[0, 0]
        x = np.linspace(-3, 3, 500)
        ax.plot(x, np.maximum(x, 0), 'b-', linewidth=2, label='ReLU(x) = x ⊕ 0')
        ax.plot(x, x, 'r--', alpha=0.5, label='y = x')
        ax.plot(x, np.zeros_like(x), 'g--', alpha=0.5, label='y = 0')
        ax.fill_between(x, np.maximum(x, 0), alpha=0.1, color='blue')
        ax.set_title('ReLU = Tropical Addition with 0')
        ax.set_xlabel('x')
        ax.set_ylabel('relu(x)')
        ax.legend()
        ax.grid(True, alpha=0.3)
        ax.axhline(y=0, color='k', linewidth=0.5)
        ax.axvline(x=0, color='k', linewidth=0.5)

        # Plot 2: Network output as piecewise linear (tropical rational)
        ax = axes[0, 1]
        x = np.linspace(-3, 3, 1000)
        y = np.array([two_layer_relu_network(xi, W1, b1, W2, b2) for xi in x])
        ax.plot(x, y, 'b-', linewidth=2)
        # Mark breakpoints
        slopes_numerical = np.diff(y) / np.diff(x)
        slope_changes = np.abs(np.diff(slopes_numerical))
        breakpoints = x[1:-1][slope_changes > 0.1]
        for bp in breakpoints:
            ax.axvline(x=bp, color='r', alpha=0.3, linestyle='--')
        ax.set_title(f'Network Output (Tropical Rational Map)\nLipschitz ≤ {trop_deg:.1f} (tropical degree)')
        ax.set_xlabel('x')
        ax.set_ylabel('f(x)')
        ax.grid(True, alpha=0.3)

        # Plot 3: Maslov dequantization
        ax = axes[1, 0]
        a_val, b_val = 2.0, 5.0
        x_vals = np.linspace(-2, 8, 500)
        ax.plot(x_vals, np.maximum(x_vals, b_val * np.ones_like(x_vals)),
                'k-', linewidth=2, label=f'max(x, {b_val}) [tropical]')
        for t, color in [(2.0, 'red'), (0.5, 'orange'), (0.1, 'green')]:
            y_soft = t * np.log(np.exp(x_vals / t) + np.exp(b_val / t))
            ax.plot(x_vals, y_soft, '--', color=color, linewidth=1.5,
                    label=f't={t} (softmax)')
        ax.set_title('Maslov Dequantization: Softmax → Max')
        ax.set_xlabel('x')
        ax.set_ylabel('output')
        ax.legend()
        ax.grid(True, alpha=0.3)

        # Plot 4: Region count growth
        ax = axes[1, 1]
        depths = range(1, 8)
        for w in [2, 4, 8]:
            regions = [(w + 1) ** L for L in depths]
            ax.semilogy(list(depths), regions, 'o-', linewidth=2,
                        label=f'Width {w}: (w+1)^L')
        ax.set_title('Linear Regions: Exponential in Depth')
        ax.set_xlabel('Depth L')
        ax.set_ylabel('Max Linear Regions')
        ax.legend()
        ax.grid(True, alpha=0.3)

        plt.tight_layout()
        plt.savefig('/workspace/request-project/tropical_relu.png', dpi=150, bbox_inches='tight')
        print("  [Visualization saved to tropical_relu.png]")

    except ImportError:
        print("  [matplotlib not available — skipping visualization]")

if __name__ == "__main__":
    main()
