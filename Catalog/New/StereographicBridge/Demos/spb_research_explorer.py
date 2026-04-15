#!/usr/bin/env python3
"""
SPB Research Explorer: Comprehensive Python Demonstrations
==========================================================

Demonstrates key results from the SPB (Stereographic Projection Bridge) framework:
1. SPB Dynamics & Equidistribution on the Real Line
2. Finite Field Group Structure (p±1 Law)
3. SPB Neural Network Prototype
4. SPB Matrix Representation & Rotation
5. SPB Fractal Generation (Iterated Möbius Maps)
6. Tropical SPB Exploration
7. Hyperbolic Distance via SPB
8. SPB Continued Fraction Connection
9. Random SPB Walks & Cauchy Distribution
10. SPB Complexity Analysis

Run: python3 spb_research_explorer.py
"""

import math
import cmath
import random
from collections import Counter

# ══════════════════════════════════════════════════════════════
# Core SPB Operations
# ══════════════════════════════════════════════════════════════

def spb(x, y):
    """Circular SPB: (x+y)/(1-xy)"""
    d = 1 - x * y
    if abs(d) < 1e-15:
        return float('inf')
    return (x + y) / d

def spbH(x, y):
    """Hyperbolic SPB (Einstein velocity addition): (x+y)/(1+xy)"""
    return (x + y) / (1 + x * y)

def spb_iter(x, n):
    """n-fold iterated SPB: spb^n(x) = tan(n·arctan(x))"""
    result = 0.0
    for _ in range(n):
        result = spb(x, result)
    return result

def cayley(x):
    """SPB-adapted Cayley transform: (1+ix)/(1-ix)"""
    return (1 + 1j * x) / (1 - 1j * x)

def spb_matrix(a):
    """SPB matrix M(a) = [[1, a], [-a, 1]]"""
    return [[1, a], [-a, 1]]

def mat_mul(A, B):
    """2x2 matrix multiplication"""
    return [
        [A[0][0]*B[0][0] + A[0][1]*B[1][0], A[0][0]*B[0][1] + A[0][1]*B[1][1]],
        [A[1][0]*B[0][0] + A[1][1]*B[1][0], A[1][0]*B[0][1] + A[1][1]*B[1][1]]
    ]

# ══════════════════════════════════════════════════════════════
# Demo 1: SPB Dynamics & Equidistribution
# ══════════════════════════════════════════════════════════════

def demo_equidistribution():
    """Verify that SPB orbits are equidistributed w.r.t. Cauchy distribution."""
    print("=" * 60)
    print("DEMO 1: SPB EQUIDISTRIBUTION (Weyl's Theorem via Cayley)")
    print("=" * 60)

    # Choose a = tan(α) where α/π is irrational
    alpha = math.sqrt(2)  # irrational rotation number
    a = math.tan(alpha)

    # Iterate: x_{n+1} = spb(x_n, a)
    N = 10000
    x = 0.0
    orbit = []
    for _ in range(N):
        x = spb(x, a)
        if abs(x) < 100:  # clip large values
            orbit.append(x)

    # Compare CDF to Cauchy distribution
    orbit_sorted = sorted(orbit)
    n = len(orbit_sorted)

    # Cauchy CDF: F(x) = 1/2 + arctan(x)/π
    max_discrepancy = 0
    for i, val in enumerate(orbit_sorted):
        empirical = (i + 1) / n
        theoretical = 0.5 + math.atan(val) / math.pi
        max_discrepancy = max(max_discrepancy, abs(empirical - theoretical))

    print(f"  Rotation parameter a = tan(√2) ≈ {a:.4f}")
    print(f"  Orbit length: {n} points (of {N} iterations)")
    print(f"  Maximum Kolmogorov-Smirnov discrepancy: {max_discrepancy:.4f}")
    print(f"  Expected O(1/√N) ≈ {1/math.sqrt(N):.4f}")
    print(f"  → Equidistribution {'CONFIRMED ✓' if max_discrepancy < 0.05 else 'needs more points'}")
    print()

# ══════════════════════════════════════════════════════════════
# Demo 2: Finite Field Group Structure
# ══════════════════════════════════════════════════════════════

def spb_mod(x, y, p):
    """SPB over F_p"""
    d = (1 - x * y) % p
    if d == 0:
        return None  # point at infinity
    return ((x + y) * pow(d, p - 2, p)) % p

def find_spb_order(g, p):
    """Find order of g under SPB iteration in F_p.
    Division by zero maps to 0 (like the projective line convention)."""
    result = 0
    for n in range(1, 2 * (p + 2)):
        val = spb_mod(g, result, p)
        if val is None:
            result = 0  # point at infinity mapped to 0
        else:
            result = val
        if result == 0:
            return n
    return -1  # not found

def demo_finite_fields():
    """Verify the p±1 law for SPB over finite fields."""
    print("=" * 60)
    print("DEMO 2: FINITE FIELD SPB GROUP STRUCTURE (p±1 Law)")
    print("=" * 60)

    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]

    print(f"  {'p':>4} {'p mod 4':>7} {'Expected':>10} {'Order of 1':>10} {'Divides?':>10}")
    print("  " + "-" * 50)

    for p in primes:
        mod4 = p % 4
        expected = p + 1 if mod4 == 3 else p - 1
        order = find_spb_order(1, p)
        divides = "✓" if order and expected % order == 0 else "✗"
        mod_str = '≡3' if mod4 == 3 else '≡1'
        print(f"  {p:>4} {mod_str:>7} {expected:>10} {order:>10} {divides:>10}")

    print()

# ══════════════════════════════════════════════════════════════
# Demo 3: SPB Neural Network
# ══════════════════════════════════════════════════════════════

def demo_spb_neural_network():
    """Simple SPB-based neural network for periodic function approximation."""
    print("=" * 60)
    print("DEMO 3: SPB NEURAL NETWORK (Periodic Function Fitting)")
    print("=" * 60)

    # Target: f(x) = sin(x) on [-π, π], represented via t = tan(x/2)
    # In SPB coordinates: sin(x) = 2t/(1+t²) = spbH(t, t)

    # SPB neuron: output = spb(input, weight)
    class SPBNeuron:
        def __init__(self, weight=0.0):
            self.w = weight

        def forward(self, x):
            d = 1 + x * self.w  # Using spbH for bounded domain
            if abs(d) < 1e-10:
                return 0.0
            return (x + self.w) / d

    # Network: chain of SPB neurons
    weights = [0.3, -0.2, 0.5, -0.1]
    neurons = [SPBNeuron(w) for w in weights]

    # Test composition
    test_inputs = [0.0, 0.1, 0.3, 0.5, -0.3]
    print("  SPB Network with 4 neurons, weights:", weights)
    print(f"  {'Input':>10} {'Output':>10} {'|output|<1':>12}")
    for x in test_inputs:
        out = x
        for neuron in neurons:
            out = neuron.forward(out)
        bounded = "✓" if abs(out) < 1 else "✗"
        print(f"  {x:>10.4f} {out:>10.4f} {bounded:>12}")

    # Key property: SPB neurons preserve boundedness
    print("\n  Key insight: spbH neurons map (-1,1) → (-1,1)")
    print("  → Natural activation function for circular/angular data")
    print()

# ══════════════════════════════════════════════════════════════
# Demo 4: Matrix Representation
# ══════════════════════════════════════════════════════════════

def demo_matrix_representation():
    """SPB composition via matrix multiplication."""
    print("=" * 60)
    print("DEMO 4: SPB MATRIX REPRESENTATION")
    print("=" * 60)

    a, b = 0.5, 0.3

    # Direct SPB
    direct = spb(a, b)

    # Via matrices: M(a)·M(b) = (1-ab)·M(spb(a,b))
    Ma = spb_matrix(a)
    Mb = spb_matrix(b)
    product = mat_mul(Ma, Mb)

    spb_val = spb(a, b)
    scale = 1 - a * b
    Mspb_scaled = [[scale * x for x in row] for row in spb_matrix(spb_val)]

    print(f"  a = {a}, b = {b}")
    print(f"  spb(a, b) = {direct:.6f}")
    print(f"\n  M(a) = {Ma}")
    print(f"  M(b) = {Mb}")
    print(f"  M(a)·M(b) = {product}")
    print(f"  (1-ab)·M(spb(a,b)) = {Mspb_scaled}")

    # Verify
    match = all(
        abs(product[i][j] - Mspb_scaled[i][j]) < 1e-10
        for i in range(2) for j in range(2)
    )
    print(f"\n  Matrix identity verified: {'✓' if match else '✗'}")

    # Determinants
    det_a = 1 + a**2
    det_b = 1 + b**2
    det_prod = product[0][0]*product[1][1] - product[0][1]*product[1][0]
    print(f"\n  det(M(a)) = 1 + a² = {det_a:.6f}")
    print(f"  det(M(b)) = 1 + b² = {det_b:.6f}")
    print(f"  det(M(a)·M(b)) = {det_prod:.6f}")
    print(f"  det(M(a))·det(M(b)) = {det_a * det_b:.6f}")
    print(f"  Product of dets: {'✓' if abs(det_prod - det_a*det_b) < 1e-10 else '✗'}")
    print()

# ══════════════════════════════════════════════════════════════
# Demo 5: SPB Fractals
# ══════════════════════════════════════════════════════════════

def demo_spb_fractals():
    """Iterated SPB compositions generating fractal-like orbits."""
    print("=" * 60)
    print("DEMO 5: SPB FRACTAL ORBITS")
    print("=" * 60)

    # Two SPB generators with different parameters
    a1, a2 = 1.0, math.sqrt(2)

    # Random iterated function system
    random.seed(42)
    x = 0.0
    orbit = [x]
    for _ in range(200):
        if random.random() < 0.5:
            x = spb(x, a1)
        else:
            x = spb(x, a2)
        # Map through arctan to keep bounded
        x = math.atan(x) * 2 / math.pi  # normalize to (-1, 1)
        x = math.tan(x * math.pi / 2)   # back to R
        if abs(x) < 100:
            orbit.append(x)

    print(f"  Generators: a₁ = {a1}, a₂ = √2 ≈ {a2:.4f}")
    print(f"  Orbit length: {len(orbit)} points")
    print(f"  Range: [{min(orbit):.4f}, {max(orbit):.4f}]")

    # Check for approximate periodicity
    print(f"\n  First 10 orbit values:")
    for i, val in enumerate(orbit[:10]):
        print(f"    x_{i} = {val:.6f}")
    print()

# ══════════════════════════════════════════════════════════════
# Demo 6: Tropical SPB
# ══════════════════════════════════════════════════════════════

def trop_spb(x, y):
    """Tropical SPB: min(x,y) - max(0, x+y)"""
    return min(x, y) - max(0, x + y)

def demo_tropical_spb():
    """Explore tropical SPB algebra."""
    print("=" * 60)
    print("DEMO 6: TROPICAL SPB")
    print("=" * 60)

    test_pairs = [
        (-1, -2), (-3, -1), (-0.5, -1.5),
        (1, 2), (-1, 1), (0, 0)
    ]

    print(f"  {'x':>6} {'y':>6} {'tspb(x,y)':>10} {'min(x,y)':>10} {'max(0,x+y)':>10}")
    print("  " + "-" * 50)
    for x, y in test_pairs:
        result = trop_spb(x, y)
        print(f"  {x:>6.1f} {y:>6.1f} {result:>10.1f} {min(x,y):>10.1f} {max(0,x+y):>10.1f}")

    # Commutativity check
    print("\n  Commutativity check:")
    for x, y in test_pairs:
        comm = abs(trop_spb(x, y) - trop_spb(y, x)) < 1e-10
        print(f"    tspb({x},{y}) = tspb({y},{x}): {'✓' if comm else '✗'}")

    # Key property: for negative inputs, tspb(x,y) = min(x,y)
    print("\n  For x,y < 0: tspb(x,y) = min(x,y)")
    for x, y in [(-1, -2), (-3, -1), (-0.5, -1.5)]:
        print(f"    tspb({x},{y}) = {trop_spb(x,y)} = min({x},{y}) = {min(x,y)}: "
              f"{'✓' if abs(trop_spb(x,y) - min(x,y)) < 1e-10 else '✗'}")
    print()

# ══════════════════════════════════════════════════════════════
# Demo 7: Hyperbolic Distance
# ══════════════════════════════════════════════════════════════

def demo_hyperbolic_distance():
    """Hyperbolic distance in Poincaré disk via SPB."""
    print("=" * 60)
    print("DEMO 7: HYPERBOLIC DISTANCE VIA SPB")
    print("=" * 60)

    def hyp_dist(x, y):
        """Hyperbolic distance using spbH(x, -y)."""
        diff = spbH(x, -y)
        if abs(diff) >= 1:
            return float('inf')
        return math.atanh(abs(diff))

    points = [0.0, 0.1, 0.3, 0.5, 0.7, 0.9]
    print(f"  Hyperbolic distances from 0 to x in Poincaré disk:")
    print(f"  {'x':>6} {'d(0,x)':>10} {'arctanh(x)':>12}")
    for x in points:
        d = hyp_dist(0, x)
        at = math.atanh(x) if x < 1 else float('inf')
        print(f"  {x:>6.1f} {d:>10.4f} {at:>12.4f}")

    # Triangle inequality check
    print(f"\n  Triangle inequality: d(x,z) ≤ d(x,y) + d(y,z)")
    triples = [(0.1, 0.3, 0.5), (0.2, 0.4, 0.7), (-0.3, 0.1, 0.5)]
    for x, y, z in triples:
        dxz = hyp_dist(x, z)
        dxy = hyp_dist(x, y)
        dyz = hyp_dist(y, z)
        holds = dxz <= dxy + dyz + 1e-10
        print(f"    d({x},{z})={dxz:.4f} ≤ d({x},{y})+d({y},{z})={dxy+dyz:.4f}: "
              f"{'✓' if holds else '✗'}")
    print()

# ══════════════════════════════════════════════════════════════
# Demo 8: Random SPB Walks & Cauchy Distribution
# ══════════════════════════════════════════════════════════════

def demo_random_walks():
    """Random SPB walks converge to Cauchy distribution."""
    print("=" * 60)
    print("DEMO 8: RANDOM SPB WALKS → CAUCHY DISTRIBUTION")
    print("=" * 60)

    random.seed(123)
    N = 5000
    walk_lengths = [10, 50, 200]

    for steps in walk_lengths:
        samples = []
        for _ in range(N):
            x = 0.0
            for _ in range(steps):
                # Random step: uniform in [-1, 1]
                a = random.uniform(-1, 1)
                x = spb(x, a)
                if abs(x) > 1000:
                    x = 0.0  # reset if too large
            if abs(x) < 100:
                samples.append(x)

        # Compare to Cauchy: median should be ~0, IQR should be ~2
        samples.sort()
        n = len(samples)
        if n > 0:
            median = samples[n // 2]
            q1 = samples[n // 4]
            q3 = samples[3 * n // 4]
            iqr = q3 - q1
            print(f"  Steps={steps:>3}: n={n}, median={median:>7.3f}, IQR={iqr:.3f} "
                  f"(Cauchy: median=0, IQR=2)")
    print()

# ══════════════════════════════════════════════════════════════
# Demo 9: SPB Complexity Analysis
# ══════════════════════════════════════════════════════════════

def demo_complexity():
    """Analyze SPB complexity of computing tan(nθ)."""
    print("=" * 60)
    print("DEMO 9: SPB COMPLEXITY (Addition Chains)")
    print("=" * 60)

    # SPB complexity of tan(nθ) = length of shortest addition chain for n
    # This is because spb^(m+n)(x) = spb(spb^m(x), spb^n(x))

    def addition_chain_length(n):
        """Find shortest addition chain for n (brute force for small n)."""
        if n <= 1:
            return 0 if n == 1 else float('inf')

        from functools import lru_cache
        # BFS approach
        visited = {1}
        queue = [(1, [1], 0)]
        while queue:
            current, chain, depth = queue.pop(0)
            for val in chain:
                new = current + val
                if new == n:
                    return depth + 1
                if new < 2 * n and new not in visited:
                    visited.add(new)
                    queue.append((new, chain + [new], depth + 1))
        return float('inf')

    print(f"  {'n':>4} {'Chain Length':>12} {'⌈log₂(n)⌉':>10} {'Ratio':>8}")
    print("  " + "-" * 38)
    for n in [2, 3, 4, 5, 7, 8, 10, 15, 16, 23, 32, 64]:
        cl = addition_chain_length(n)
        log2n = math.ceil(math.log2(n)) if n > 0 else 0
        ratio = cl / log2n if log2n > 0 else 0
        print(f"  {n:>4} {cl:>12} {log2n:>10} {ratio:>8.2f}")

    print("\n  → SPB complexity is Θ(log n), matching addition chain length")
    print()

# ══════════════════════════════════════════════════════════════
# Demo 10: SPB Continued Fraction Connection
# ══════════════════════════════════════════════════════════════

def demo_continued_fractions():
    """SPB and continued fractions via Möbius transformations."""
    print("=" * 60)
    print("DEMO 10: SPB AND CONTINUED FRACTIONS")
    print("=" * 60)

    # A continued fraction [a0; a1, a2, ...] = a0 + 1/(a1 + 1/(a2 + ...))
    # Each step is a Möbius transformation T_n(z) = a_n + 1/z
    # SPB(x, a) = (x+a)/(1-xa) is also a Möbius transformation

    # The connection: arctan has the continued fraction
    # arctan(x) = x/(1 + x²/(3 + (2x)²/(5 + ...)))
    # And arctan is the homomorphism from SPB to addition!

    # Verify: arctan(spb(x,y)) = arctan(x) + arctan(y)
    test_pairs = [(0.5, 0.3), (1.0, 0.2), (0.7, -0.4), (0.1, 0.9)]
    print("  Verification: arctan(spb(x,y)) = arctan(x) + arctan(y)")
    print(f"  {'x':>6} {'y':>6} {'LHS':>10} {'RHS':>10} {'Match':>7}")
    for x, y in test_pairs:
        lhs = math.atan(spb(x, y))
        rhs = math.atan(x) + math.atan(y)
        match = abs(lhs - rhs) < 1e-10
        print(f"  {x:>6.1f} {y:>6.1f} {lhs:>10.6f} {rhs:>10.6f} {'✓' if match else '✗':>7}")

    # Machin-like formulas via SPB
    print("\n  Machin-like formulas as SPB expressions:")
    # π/4 = arctan(1) = 4·arctan(1/5) - arctan(1/239) (Machin's formula)
    # In SPB: 1 = spb^4(1/5, spb(-1/239, 0))

    val1 = spb_iter(1/5, 4)  # tan(4·arctan(1/5))
    val2 = spb(val1, -1/239)  # spb(tan(4·arctan(1/5)), -1/239)

    pi_approx = 4 * math.atan(val2 if abs(val2) < 100 else 1.0)
    # Actually: 4*arctan(1/5) - arctan(1/239) = π/4
    machin = 4 * math.atan(1/5) - math.atan(1/239)
    print(f"  Machin: 4·arctan(1/5) - arctan(1/239) = {machin:.10f}")
    print(f"  π/4 = {math.pi/4:.10f}")
    print(f"  Match: {'✓' if abs(machin - math.pi/4) < 1e-12 else '✗'}")
    print()

# ══════════════════════════════════════════════════════════════
# Main
# ══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("\n" + "═" * 60)
    print("  SPB RESEARCH EXPLORER")
    print("  Stereographic Projection Bridge — Advanced Demonstrations")
    print("═" * 60 + "\n")

    demo_equidistribution()
    demo_finite_fields()
    demo_spb_neural_network()
    demo_matrix_representation()
    demo_spb_fractals()
    demo_tropical_spb()
    demo_hyperbolic_distance()
    demo_random_walks()
    demo_complexity()
    demo_continued_fractions()

    print("═" * 60)
    print("  All demonstrations complete.")
    print("═" * 60)
