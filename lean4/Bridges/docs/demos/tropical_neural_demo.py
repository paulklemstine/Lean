#!/usr/bin/env python3
"""
Tropical–Neural Bridge Demo
============================

Interactive demonstration of the connections between tropical algebra
and neural networks. Shows:

1. ReLU as tropical activation (max(x, 0))
2. LogSumExp as smooth approximation of max
3. Softmax → argmax as temperature → 0 (Maslov dequantization)
4. Piecewise-linear regions growing exponentially with depth

Usage:
    python tropical_neural_demo.py
"""

import math
import sys

# ─────────────────────────────────────────────
# Demo 1: ReLU Idempotency
# ─────────────────────────────────────────────

def relu(x):
    """ReLU: the bridge between neural networks and tropical algebra."""
    return max(x, 0.0)

def demo_relu_idempotency():
    """Demonstrate that ReLU(ReLU(x)) = ReLU(x) for all x."""
    print("=" * 60)
    print("DEMO 1: ReLU Idempotency — f(f(x)) = f(x)")
    print("=" * 60)
    print()
    test_values = [-5.0, -1.0, -0.001, 0.0, 0.001, 1.0, 5.0, 100.0]
    print(f"{'x':>10} {'ReLU(x)':>12} {'ReLU(ReLU(x))':>15} {'Equal?':>8}")
    print("-" * 50)
    for x in test_values:
        r1 = relu(x)
        r2 = relu(r1)
        print(f"{x:10.3f} {r1:12.3f} {r2:15.3f} {'✓' if r1 == r2 else '✗':>8}")
    print()
    print("Key insight: ReLU is idempotent — applying it once is enough.")
    print("This makes it a *projection* onto the non-negative reals.")
    print()

# ─────────────────────────────────────────────
# Demo 2: LogSumExp Sandwich Theorem
# ─────────────────────────────────────────────

def logsumexp(x, y):
    """LogSumExp: smooth approximation of max."""
    return math.log(math.exp(x) + math.exp(y))

def demo_logsumexp_sandwich():
    """Demonstrate: max(x,y) ≤ LSE(x,y) ≤ max(x,y) + log(2)."""
    print("=" * 60)
    print("DEMO 2: LogSumExp Sandwich Theorem")
    print("  max(x,y) ≤ log(eˣ+eʸ) ≤ max(x,y) + log(2)")
    print("=" * 60)
    print()
    log2 = math.log(2)
    pairs = [(0, 0), (1, 2), (5, 1), (-3, -7), (10, 10), (0, 100)]
    print(f"{'(x, y)':>12} {'max':>8} {'LSE':>10} {'max+ln2':>10} {'gap':>8}")
    print("-" * 55)
    for x, y in pairs:
        m = max(x, y)
        lse = logsumexp(x, y)
        upper = m + log2
        gap = lse - m
        ok_lower = m <= lse + 1e-10
        ok_upper = lse <= upper + 1e-10
        status = "✓" if ok_lower and ok_upper else "✗"
        print(f"({x:3},{y:3})   {m:8.3f} {lse:10.3f} {upper:10.3f} {gap:8.4f} {status}")
    print()
    print(f"Maximum possible gap = log(2) = {log2:.6f}")
    print("Interpretation: tropical (max) and quantum (LSE) differ by at most log(2).")
    print()

# ─────────────────────────────────────────────
# Demo 3: Softmax → Argmax (Temperature Scaling)
# ─────────────────────────────────────────────

def softmax_temp(scores, T):
    """Temperature-scaled softmax. As T→0, approaches argmax (one-hot)."""
    if T < 1e-10:
        idx = scores.index(max(scores))
        return [1.0 if i == idx else 0.0 for i in range(len(scores))]
    scaled = [s / T for s in scores]
    max_s = max(scaled)
    exps = [math.exp(s - max_s) for s in scaled]  # numerically stable
    total = sum(exps)
    return [e / total for e in exps]

def demo_temperature_scaling():
    """Show softmax → argmax as T → 0 (Maslov dequantization)."""
    print("=" * 60)
    print("DEMO 3: Softmax → Argmax (Maslov Dequantization)")
    print("  Temperature T: ∞ → uniform, 1 → softmax, 0 → argmax")
    print("=" * 60)
    print()
    scores = [1.0, 3.0, 2.0]
    temps = [100.0, 10.0, 1.0, 0.1, 0.01, 0.001, 0.0]
    print(f"Scores = {scores}")
    print(f"{'T':>8} {'σ₁':>8} {'σ₂':>8} {'σ₃':>8} {'Regime':>15}")
    print("-" * 55)
    for T in temps:
        probs = softmax_temp(scores, T)
        if T > 10:
            regime = "≈ uniform"
        elif T > 0.1:
            regime = "softmax"
        elif T > 0:
            regime = "≈ argmax"
        else:
            regime = "= argmax"
        print(f"{T:8.3f} {probs[0]:8.4f} {probs[1]:8.4f} {probs[2]:8.4f} {regime:>15}")
    print()
    print("As T → 0: softmax → one-hot on the max element (tropical limit)")
    print("As T → ∞: softmax → uniform distribution (maximum entropy)")
    print()

# ─────────────────────────────────────────────
# Demo 4: Depth–Width Tradeoff (Region Counting)
# ─────────────────────────────────────────────

def max_regions(depth, width):
    """Upper bound on number of linear regions for a depth-d, width-w ReLU network."""
    return min(width ** depth, 2 ** (width * depth))

def demo_depth_width():
    """Show exponential growth of linear regions with depth."""
    print("=" * 60)
    print("DEMO 4: Tropical Complexity — Linear Regions vs Depth")
    print("  ReLU networks compute tropical rational functions")
    print("=" * 60)
    print()
    width = 4
    print(f"Width = {width} neurons per layer")
    print(f"{'Depth':>8} {'Max Regions':>15} {'Log₂(Regions)':>15}")
    print("-" * 42)
    for depth in range(1, 11):
        regions = width ** depth
        log_regions = depth * math.log2(width)
        print(f"{depth:8} {regions:15,} {log_regions:15.1f}")
    print()
    print("Each additional layer multiplies the region count by width.")
    print("This is why deep networks are exponentially more expressive!")
    print()

# ─────────────────────────────────────────────
# Demo 5: Brahmagupta-Fibonacci Identity
# ─────────────────────────────────────────────

def demo_brahmagupta():
    """Demonstrate: (a²+b²)(c²+d²) = (ac-bd)² + (ad+bc)²."""
    print("=" * 60)
    print("DEMO 5: Brahmagupta-Fibonacci Identity")
    print("  (a²+b²)(c²+d²) = (ac-bd)² + (ad+bc)²")
    print("  Connects complex number norms to Pythagorean triples")
    print("=" * 60)
    print()
    cases = [(1, 2, 3, 4), (2, 3, 5, 7), (1, 1, 1, 1), (3, 4, 5, 12)]
    for a, b, c, d in cases:
        lhs = (a**2 + b**2) * (c**2 + d**2)
        rhs_1 = a*c - b*d
        rhs_2 = a*d + b*c
        rhs = rhs_1**2 + rhs_2**2
        print(f"  ({a}²+{b}²)({c}²+{d}²) = {lhs}")
        print(f"  ({a}·{c}-{b}·{d})² + ({a}·{d}+{b}·{c})² = {rhs_1}² + {rhs_2}² = {rhs}")
        print(f"  Match: {'✓' if lhs == rhs else '✗'}")
        print()
    print("This identity is the multiplicativity of the complex number norm:")
    print("  |z₁·z₂|² = |z₁|²·|z₂|²")
    print("It generalizes to quaternions (4 squares) and octonions (8 squares).")
    print()

# ─────────────────────────────────────────────
# Demo 6: Persistence Diagram Stability
# ─────────────────────────────────────────────

def bottleneck_dist(p1, p2):
    """L∞ (bottleneck) distance between two persistence points."""
    return max(abs(p1[0] - p2[0]), abs(p1[1] - p2[1]))

def demo_persistence():
    """Demonstrate stability of persistence diagrams."""
    print("=" * 60)
    print("DEMO 6: Persistence–Tropical Bridge")
    print("  Bottleneck distance = L∞ = tropical metric")
    print("=" * 60)
    print()
    
    # Two persistence diagrams
    diagram1 = [(0.0, 3.0), (1.0, 5.0), (2.0, 2.5)]
    diagram2 = [(0.1, 3.2), (0.9, 4.8), (2.1, 2.4)]
    
    print("Diagram 1 (original):  ", diagram1)
    print("Diagram 2 (perturbed): ", diagram2)
    print()
    print(f"{'Point':>6} {'Birth Δ':>10} {'Death Δ':>10} {'Bottleneck':>12}")
    print("-" * 42)
    
    max_dist = 0
    for i, (p1, p2) in enumerate(zip(diagram1, diagram2)):
        bd = abs(p1[0] - p2[0])
        dd = abs(p1[1] - p2[1])
        bn = bottleneck_dist(p1, p2)
        max_dist = max(max_dist, bn)
        print(f"{i+1:6} {bd:10.3f} {dd:10.3f} {bn:12.3f}")
    
    print(f"\nOverall bottleneck distance: {max_dist:.3f}")
    print("The bottleneck distance is the L∞ norm — a tropical metric!")
    print("Small input perturbations → small diagram perturbations (stability).")
    print()

# ─────────────────────────────────────────────
# Demo 7: Idempotent Density Formula
# ─────────────────────────────────────────────

def count_idempotents(n):
    """Count idempotents in ℤ/nℤ."""
    return sum(1 for e in range(n) if (e * e) % n == e)

def prime_factors(n):
    """Count distinct prime factors of n."""
    factors = set()
    d = 2
    while d * d <= n:
        while n % d == 0:
            factors.add(d)
            n //= d
        d += 1
    if n > 1:
        factors.add(n)
    return factors

def demo_idempotent_density():
    """Verify |Idem(ℤ/nℤ)| = 2^ω(n) where ω counts prime factors."""
    print("=" * 60)
    print("DEMO 7: Idempotent Density Formula")
    print("  |Idem(ℤ/nℤ)| = 2^ω(n)")
    print("=" * 60)
    print()
    print(f"{'n':>5} {'Primes':>15} {'ω(n)':>6} {'2^ω(n)':>8} {'|Idem|':>8} {'Match':>7}")
    print("-" * 55)
    for n in [2, 3, 4, 5, 6, 8, 10, 12, 15, 30, 60, 210]:
        pf = prime_factors(n)
        omega = len(pf)
        predicted = 2 ** omega
        actual = count_idempotents(n)
        match = "✓" if predicted == actual else "✗"
        primes_str = "×".join(str(p) for p in sorted(pf))
        print(f"{n:5} {primes_str:>15} {omega:6} {predicted:8} {actual:8} {match:>7}")
    print()
    print("The formula 2^ω(n) comes from the Chinese Remainder Theorem:")
    print("each prime factor gives a binary choice (0 or 1 idempotent).")
    print()

# ─────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────

def main():
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  UNIFIED FRAMEWORK: Tropical–Neural–Quantum Bridges    ║")
    print("║  Interactive Demonstration Suite                        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()
    
    demo_relu_idempotency()
    demo_logsumexp_sandwich()
    demo_temperature_scaling()
    demo_depth_width()
    demo_brahmagupta()
    demo_persistence()
    demo_idempotent_density()
    
    print("=" * 60)
    print("SUMMARY: The Idempotent Fixed-Point Principle f(f(x)) = f(x)")
    print("=" * 60)
    print()
    print("  All seven demos share the same deep structure:")
    print("  ┌─────────────────────────────────────────────┐")
    print("  │  ReLU idempotency      → Neural networks    │")
    print("  │  LSE sandwich          → Tropical ↔ Quantum │")
    print("  │  Softmax → argmax      → Dequantization     │")
    print("  │  Depth–region growth   → Tropical complexity │")
    print("  │  Brahmagupta-Fibonacci → Division algebras   │")
    print("  │  Persistence stability → Topological DA      │")
    print("  │  Idempotent density    → Number theory       │")
    print("  └─────────────────────────────────────────────┘")
    print()
    print("  The unifying equation: f ∘ f = f")
    print()

if __name__ == "__main__":
    main()
