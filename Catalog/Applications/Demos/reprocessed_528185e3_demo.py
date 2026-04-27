#!/usr/bin/env python3
"""
demo.py — Tropical Geometry of ReLU Networks
=============================================

This script illustrates the core theorem:
  ReLU networks compute tropical rational maps, and their Lipschitz constant
  is bounded by the tropical degree (number of linear regions).

We demonstrate:
  1. ReLU as tropical addition: relu(x) = max(x, 0) = x ⊕ 0
  2. A 2-layer ReLU network as a tropical polynomial
  3. Linear region counting and Lipschitz constant estimation
  4. The exponential advantage of depth over width

Corresponds to the Lean formalization in Main.lean and
MachineLearning/Neural/TropicalDeepLearningFoundations.lean.
"""

import numpy as np

# ---------------------------------------------------------------------------
# Tropical semiring operations (matching Lean: tropAdd, tropMul)
# ---------------------------------------------------------------------------

def trop_add(a: float, b: float) -> float:
    """Tropical addition: a ⊕ b = max(a, b)
    Lean: def tropAdd (a b : ℝ) : ℝ := max a b"""
    return max(a, b)

def trop_mul(a: float, b: float) -> float:
    """Tropical multiplication: a ⊗ b = a + b
    Lean: def tropMul (a b : ℝ) : ℝ := a + b"""
    return a + b

def relu(x: float) -> float:
    """ReLU function: max(x, 0)
    Lean: def relu₀ (x : ℝ) : ℝ := max x 0
    Key identity: relu(x) = tropAdd x 0 (proved as relu_eq_tropAdd_zero)"""
    return trop_add(x, 0)

# ---------------------------------------------------------------------------
# Tropical polynomial: max of affine functions
# ---------------------------------------------------------------------------

def tropical_polynomial(coeffs: list, x: float) -> float:
    """Evaluate a tropical polynomial: ⊕_i (a_i * x + b_i) = max_i(a_i * x + b_i)
    Each coeff is a tuple (a_i, b_i).
    Lean: def tropPoly3 for the 3-term case."""
    return max(a * x + b for a, b in coeffs)

# ---------------------------------------------------------------------------
# ReLU network as composition of tropical polynomials
# ---------------------------------------------------------------------------

def relu_layer(x: np.ndarray, W: np.ndarray, b: np.ndarray) -> np.ndarray:
    """Single ReLU layer: relu(Wx + b)
    Each neuron computes relu(w_i · x + b_i) = tropAdd(w_i · x + b_i, 0)
    This is a 2-term tropical polynomial per neuron."""
    return np.maximum(W @ x + b, 0)

def relu_network(x: float, weights: list, biases: list) -> float:
    """Multi-layer ReLU network.
    The composition of tropical polynomials is itself a tropical rational map.
    Lean: relu_composition_tropical shows this preserves tropical structure."""
    val = np.array([x])
    for W, b in zip(weights, biases):
        val = relu_layer(val, W, b)
    return val[0]

# ---------------------------------------------------------------------------
# Count linear regions (tropical degree) of a 1D ReLU network
# ---------------------------------------------------------------------------

def count_linear_regions(f, x_min=-10.0, x_max=10.0, n_samples=100000):
    """Count the number of distinct linear regions of a piecewise-linear function.
    The tropical degree equals the number of such regions.
    Lean: max_regions_1d gives the theoretical upper bound."""
    xs = np.linspace(x_min, x_max, n_samples)
    ys = np.array([f(x) for x in xs])

    # Compute slopes between consecutive points
    slopes = np.diff(ys) / np.diff(xs)

    # Count changes in slope (new linear region)
    slope_changes = np.abs(np.diff(slopes)) > 1e-6
    n_regions = 1 + np.sum(slope_changes)
    return n_regions, slopes

def estimate_lipschitz(slopes: np.ndarray) -> float:
    """Estimate the Lipschitz constant as max |slope|.
    This is bounded by the tropical degree times the max weight magnitude."""
    return np.max(np.abs(slopes))

# ---------------------------------------------------------------------------
# Theoretical bounds (matching Lean definitions)
# ---------------------------------------------------------------------------

def max_regions_1d(width: int, depth: int) -> int:
    """Lean: def max_regions_1d (width depth : ℕ) : ℕ := (width + 1) ^ depth
    Proved in depth_exponential."""
    return (width + 1) ** depth

# ---------------------------------------------------------------------------
# Main demonstration
# ---------------------------------------------------------------------------

def main():
    print("=" * 70)
    print("  TROPICAL GEOMETRY OF RELU NETWORKS")
    print("  Demonstrating: relu_tropical_lipschitz")
    print("=" * 70)

    # --- 1. ReLU is tropical addition ---
    print("\n[1] ReLU = Tropical Addition with Identity")
    print("-" * 45)
    test_values = [-2.0, -1.0, 0.0, 0.5, 1.0, 3.0]
    for x in test_values:
        r = relu(x)
        t = trop_add(x, 0)
        print(f"  relu({x:5.1f}) = {r:5.1f}  |  tropAdd({x:5.1f}, 0) = {t:5.1f}  |  equal: {r == t}")
    print("  → Lean theorem: relu_eq_tropAdd_zero")

    # --- 2. Tropical distributivity ---
    print("\n[2] Tropical Distributivity: a ⊗ (b ⊕ c) = (a ⊗ b) ⊕ (a ⊗ c)")
    print("-" * 55)
    for a, b, c in [(1, 2, 3), (-1, 5, -3), (0, 0, 0)]:
        lhs = trop_mul(a, trop_add(b, c))
        rhs = trop_add(trop_mul(a, b), trop_mul(a, c))
        print(f"  a={a}, b={b}, c={c}: LHS={lhs}, RHS={rhs}, equal={lhs == rhs}")
    print("  → Lean theorem: tropMul_tropAdd_distrib")

    # --- 3. Network as tropical polynomial ---
    print("\n[3] ReLU Network → Tropical Polynomial → Linear Regions")
    print("-" * 55)

    # Create a small network: 2 layers, width 3
    np.random.seed(42)
    W1 = np.random.randn(3, 1) * 2
    b1 = np.random.randn(3)
    W2 = np.random.randn(1, 3) * 2
    b2 = np.random.randn(1)

    weights = [W1, W2]
    biases = [b1, b2]

    net_fn = lambda x: relu_network(x, weights, biases)
    n_regions, slopes = count_linear_regions(net_fn)
    lip = estimate_lipschitz(slopes)
    theoretical_max = max_regions_1d(width=3, depth=2)

    print(f"  Network: depth=2, width=3")
    print(f"  Observed linear regions (tropical degree): {n_regions}")
    print(f"  Theoretical maximum (w+1)^L = 4^2:        {theoretical_max}")
    print(f"  Observed ≤ Theoretical:                    {n_regions <= theoretical_max}")
    print(f"  Estimated Lipschitz constant:              {lip:.4f}")
    print(f"  → Lean theorem: depth_exponential")

    # --- 4. Depth vs Width: exponential advantage ---
    print("\n[4] Exponential Advantage of Depth over Width")
    print("-" * 50)
    print(f"  {'Config':<25} {'Max Regions':>12}")
    print(f"  {'─' * 25} {'─' * 12}")

    configs = [
        ("width=10, depth=1", 10, 1),
        ("width=10, depth=2", 10, 2),
        ("width=10, depth=3", 10, 3),
        ("width=10, depth=5", 10, 5),
        ("width=100, depth=1", 100, 1),
        ("width=10, depth=10", 10, 10),
    ]
    for label, w, d in configs:
        mr = max_regions_1d(w, d)
        print(f"  {label:<25} {mr:>12,}")

    print(f"\n  Doubling depth squares regions:")
    for w in [3, 5, 10]:
        for L in [1, 2, 3]:
            r1 = max_regions_1d(w, L)
            r2 = max_regions_1d(w, 2 * L)
            print(f"    w={w}, L={L}: regions(L)={r1}, regions(2L)={r2}, "
                  f"regions(L)²={r1**2}, equal={r2 == r1**2}")
    print("  → Lean theorem: depth_double_squares")

    # --- 5. Maslov dequantization ---
    print("\n[5] Maslov Dequantization: a + b = log(exp(a) · exp(b))")
    print("-" * 55)
    for a, b in [(1.0, 2.0), (0.0, 0.0), (-1.0, 3.0), (5.0, -2.0)]:
        lhs = a + b
        rhs = np.log(np.exp(a) * np.exp(b))
        print(f"  a={a:5.1f}, b={b:5.1f}: a+b={lhs:6.2f}, log(exp(a)·exp(b))={rhs:6.2f}, "
              f"match={np.isclose(lhs, rhs)}")
    print("  → Lean theorem: maslov_homomorphism")

    # --- Key insight ---
    print("\n" + "=" * 70)
    print("  KEY INSIGHT")
    print("=" * 70)
    print("""
  Every ReLU network is a tropical rational map. The ReLU activation
  relu(x) = max(x, 0) is tropical addition x ⊕ 0 in the (max, +)
  semiring. Composing layers composes tropical polynomials, and the
  tropical degree (number of linear regions) bounds the Lipschitz
  constant. Depth is exponentially more powerful than width because
  composing tropical polynomials MULTIPLIES degrees, while adding
  neurons only ADDS terms.

  This is formalized and machine-verified in Lean 4 with Mathlib.
""")

if __name__ == "__main__":
    main()
