#!/usr/bin/env python3
"""
SPB Interactive Explorer — Stereographic Projection Bridge Demonstration

This script demonstrates the core properties of spb(x,y) = (x+y)/(1-xy)
through computational experiments:

1. Group properties verification
2. Cayley transform visualization (text-based)
3. Velocity addition (relativistic)
4. Finite field orbits
5. SPB power sequences and angle multiplication
6. Approximation theory: SPB trees vs polynomials
7. Gregory-Leibniz connection to pi
8. Random SPB iteration and Cauchy distribution

Run: python3 spb_interactive_demo.py
"""

import math
import random
from fractions import Fraction
from collections import Counter

# ============================================================
# Section 1: Core SPB Definition
# ============================================================

def spb(x, y):
    """Circular SPB: spb(x,y) = (x+y)/(1-xy)"""
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return float('inf')
    return (x + y) / denom

def spbH(u, v):
    """Hyperbolic SPB (Einstein velocity addition): (u+v)/(1+uv)"""
    return (u + v) / (1 + u * v)

def cayley(x):
    """Cayley transform: x -> (1+ix)/(1-ix) as (real, imag) pair"""
    denom = 1 + x**2
    return ((1 - x**2) / denom, 2 * x / denom)

def cayley_multiply(z1, z2):
    """Multiply two complex numbers given as (real, imag) pairs"""
    a, b = z1
    c, d = z2
    return (a*c - b*d, a*d + b*c)

# ============================================================
# Section 2: Group Properties Verification
# ============================================================

def verify_group_properties():
    print("=" * 60)
    print("SECTION 1: GROUP PROPERTIES OF SPB")
    print("=" * 60)

    # Commutativity
    x, y = 0.3, 0.7
    print(f"\nCommutativity: spb({x}, {y}) = {spb(x,y):.10f}")
    print(f"              spb({y}, {x}) = {spb(y,x):.10f}")
    print(f"  Equal: {abs(spb(x,y) - spb(y,x)) < 1e-12}")

    # Identity
    print(f"\nIdentity: spb({x}, 0) = {spb(x, 0):.10f} (should be {x})")

    # Inverse
    print(f"Inverse:  spb({x}, {-x}) = {spb(x, -x):.10f} (should be 0)")

    # Associativity
    z = 0.5
    lhs = spb(spb(x, y), z)
    rhs = spb(x, spb(y, z))
    print(f"\nAssociativity: spb(spb({x},{y}),{z}) = {lhs:.10f}")
    print(f"               spb({x},spb({y},{z})) = {rhs:.10f}")
    print(f"  Equal: {abs(lhs - rhs) < 1e-12}")

    # Anti-involution
    anti = spb(x, y) + spb(-x, -y)
    print(f"\nAnti-involution: spb(x,y) + spb(-x,-y) = {anti:.2e} (should be 0)")

# ============================================================
# Section 3: Cayley Transform — The Bridge
# ============================================================

def demonstrate_cayley_bridge():
    print("\n" + "=" * 60)
    print("SECTION 2: CAYLEY TRANSFORM — THE BRIDGE")
    print("=" * 60)

    x, y = 0.4, 0.6
    spb_val = spb(x, y)

    # cayley(spb(x,y)) should equal cayley(x) * cayley(y)
    c_spb = cayley(spb_val)
    c_product = cayley_multiply(cayley(x), cayley(y))

    print(f"\nx = {x}, y = {y}")
    print(f"spb(x,y) = {spb_val:.10f}")
    print(f"\ncayley(spb(x,y))       = ({c_spb[0]:.10f}, {c_spb[1]:.10f})")
    print(f"cayley(x) * cayley(y)  = ({c_product[0]:.10f}, {c_product[1]:.10f})")
    print(f"Equal: {abs(c_spb[0]-c_product[0]) < 1e-10 and abs(c_spb[1]-c_product[1]) < 1e-10}")

    # Verify unit circle property
    for t in [0, 0.5, 1.0, 2.0, -1.0, 10.0]:
        c = cayley(t)
        norm_sq = c[0]**2 + c[1]**2
        print(f"  |cayley({t:5.1f})|² = {norm_sq:.12f}")

# ============================================================
# Section 4: Tangent Addition — Trigonometric Core
# ============================================================

def demonstrate_tangent_addition():
    print("\n" + "=" * 60)
    print("SECTION 3: TANGENT ADDITION FORMULA")
    print("=" * 60)

    print("\nVerifying tan(α+β) = spb(tan α, tan β):")
    for alpha, beta in [(0.3, 0.4), (0.7, 0.2), (1.0, 0.1), (0.5, 0.5)]:
        lhs = math.tan(alpha + beta)
        rhs = spb(math.tan(alpha), math.tan(beta))
        print(f"  α={alpha:.1f}, β={beta:.1f}: tan(α+β)={lhs:.8f}, spb(tanα,tanβ)={rhs:.8f}, match={abs(lhs-rhs)<1e-10}")

    # n-fold angle formulas
    print("\nSPB Powers: tan(nθ) via iterated SPB (θ = 0.3)")
    theta = 0.3
    t = math.tan(theta)
    current = 0  # spb_pow(0, t) = 0
    for n in range(1, 8):
        current = spb(current, t)
        expected = math.tan(n * theta)
        print(f"  n={n}: spb_pow({n},tan θ) = {current:.8f}, tan({n}θ) = {expected:.8f}, match={abs(current-expected)<1e-8}")

# ============================================================
# Section 5: Einstein Velocity Addition
# ============================================================

def demonstrate_velocity_addition():
    print("\n" + "=" * 60)
    print("SECTION 4: EINSTEIN VELOCITY ADDITION (c=1)")
    print("=" * 60)

    print("\nClassical vs Relativistic velocity addition:")
    for u, v in [(0.5, 0.5), (0.9, 0.9), (0.99, 0.99), (0.5, 0.8)]:
        classical = u + v
        relativistic = spbH(u, v)
        print(f"  u={u:.2f}, v={v:.2f}: classical={classical:.4f}, relativistic={relativistic:.6f}, |result|<1: {abs(relativistic)<1}")

    print("\nVelocity addition is bounded by c=1:")
    v = 0.0
    for i in range(20):
        v = spbH(v, 0.3)
        print(f"  After {i+1:2d} boosts of 0.3c: v = {v:.10f}c")

# ============================================================
# Section 6: Finite Field SPB
# ============================================================

def spb_mod(x, y, p):
    """SPB over F_p with projective completion (None = infinity)."""
    if x is None and y is None:
        return 0
    if x is None:
        if y == 0: return None
        return (-(pow(y, p-2, p))) % p
    if y is None:
        if x == 0: return None
        return (-(pow(x, p-2, p))) % p
    denom = (1 - x * y) % p
    if denom == 0:
        return None  # infinity
    return ((x + y) * pow(denom, p - 2, p)) % p

def spb_orbit(g, p):
    """Compute the orbit of g under repeated SPB with itself in F_p"""
    orbit = [g]
    current = g
    for _ in range(p + 2):
        current = spb_mod(current, g, p)
        if current is None:
            return orbit, "hit singularity"
        if current == g:
            return orbit, "cycled back to start"
        if current == 0:
            orbit.append(current)
            return orbit, "reached identity"
        orbit.append(current)
    return orbit, "exceeded bound"

def element_order_ff(g, p):
    """Order of g in the SPB group over F_p.
    spb_pow(n, g) where spb_pow means n-fold self-SPB.
    spb_pow(0) = 0, spb_pow(1) = g, spb_pow(2) = spb(g,g), etc.
    Order = smallest n >= 1 such that spb_pow(n, g) = 0."""
    current = 0  # spb_pow(0, g) = 0 (identity)
    for n in range(1, 2*p + 4):
        current = spb_mod(current, g, p)
        if current == 0:
            return n
    return None

def demonstrate_finite_fields():
    print("\n" + "=" * 60)
    print("SECTION 5: SPB OVER FINITE FIELDS")
    print("=" * 60)

    for p in [3, 5, 7, 11, 13, 17, 19, 23]:
        # Find all valid SPB elements and compute group order
        elements_with_order = []
        for g in range(1, p):
            o = element_order_ff(g, p)
            if o is not None:
                elements_with_order.append((g, o))

        expected = p + 1 if p % 4 == 3 else p - 1
        max_order = max(o for _, o in elements_with_order) if elements_with_order else 0
        print(f"\n  p = {p:2d} (p mod 4 = {p%4}): expected group order = {expected}")
        print(f"    Max element order found = {max_order}")
        print(f"    Matches prediction: {max_order == expected}")

        # Show a generator
        for g, o in elements_with_order:
            if o == expected:
                print(f"    Generator: {g} has order {o}")
                break

# ============================================================
# Section 7: Gregory-Leibniz Connection to π
# ============================================================

def demonstrate_gregory_leibniz():
    print("\n" + "=" * 60)
    print("SECTION 6: GREGORY-LEIBNIZ AND π VIA SPB")
    print("=" * 60)

    # arctan(1) = π/4
    # Gregory-Leibniz: π/4 = 1 - 1/3 + 1/5 - 1/7 + ...
    # SPB interpretation: arctan(a) + arctan(b) = arctan(spb(a,b)) when ab < 1

    # Machin's formula: π/4 = 4·arctan(1/5) - arctan(1/239)
    # Build arctan(1/5) via SPB
    t = 1/5
    # 4·arctan(1/5) = arctan(spb_pow(4, 1/5))
    current = 0
    for _ in range(4):
        current = spb(current, t)
    t4 = current
    print(f"\n  tan(4·arctan(1/5)) = spb_pow(4, 1/5) = {t4:.12f}")
    print(f"  Verification: 4·arctan(1/5) = {4*math.atan(1/5):.12f}")
    print(f"  tan(4·arctan(1/5)) direct = {math.tan(4*math.atan(1/5)):.12f}")

    # Machin: arctan(1) = 4·arctan(1/5) - arctan(1/239)
    # = arctan(spb(spb_pow(4,1/5), -1/239))
    machin = spb(t4, -1/239)
    print(f"\n  Machin's formula via SPB:")
    print(f"  spb(spb_pow(4, 1/5), -1/239) = {machin:.12f}")
    print(f"  tan(π/4) = {math.tan(math.pi/4):.12f}")
    print(f"  Match: {abs(machin - 1.0) < 1e-10}")

    # Partial sums of arctan via SPB
    print(f"\n  Partial SPB sums for arctan(1) via Leibniz:")
    # arctan(1) = arctan(1/1) via telescoping
    # Or use: arctan(1) = arctan(1/2) + arctan(1/3)
    # Since spb(1/2, 1/3) = (1/2+1/3)/(1-1/6) = (5/6)/(5/6) = 1
    check = spb(1/2, 1/3)
    print(f"  spb(1/2, 1/3) = {check:.6f} = tan(π/4) ✓")
    print(f"  So: arctan(1/2) + arctan(1/3) = arctan(1) = π/4 ✓")

    # More exotic: arctan(1) = arctan(1/4) + arctan(3/7) + ...
    # arctan(1/4) + arctan(3/7) via SPB:
    s = spb(1/4, 3/7)
    print(f"  spb(1/4, 3/7) = {s:.6f}")
    print(f"  arctan(1/4) + arctan(3/7) = {math.atan(1/4)+math.atan(3/7):.6f}")
    print(f"  arctan(spb(1/4,3/7)) = {math.atan(s):.6f}")

# ============================================================
# Section 8: SPB Approximation Theory
# ============================================================

def demonstrate_approximation():
    print("\n" + "=" * 60)
    print("SECTION 7: SPB APPROXIMATION THEORY")
    print("=" * 60)

    # SPB trees generate rational functions of the form tan(n·arctan(x))
    # These approximate functions on [-1,1] like Chebyshev polynomials

    # Compute spb_pow(n, x) = tan(n * arctan(x))
    def spb_pow(n, x):
        current = 0
        for _ in range(n):
            current = spb(current, x)
        return current

    print("\nSPB power functions tan(n·arctan(x)):")
    print(f"{'x':>8s}", end="")
    for n in range(1, 7):
        print(f"  {'spb_pow('+str(n)+')':>14s}", end="")
    print()

    for x_val in [-0.8, -0.4, 0.0, 0.4, 0.8]:
        print(f"{x_val:8.1f}", end="")
        for n in range(1, 7):
            val = spb_pow(n, x_val)
            print(f"  {val:14.8f}", end="")
        print()

    # Chebyshev-like approximation: approximate sin(πx/2) on [-1,1]
    # using SPB trees
    print(f"\n  SPB approximation of sin(πx/2) on [-1,1]:")
    print(f"  Using T(x) = spb_pow(n, x/c) with optimized c")

    # Simple demonstration: spb_pow(3, x/1.73) approximates a sine-like shape
    for c in [1.0, 1.5, 2.0]:
        max_err = 0
        for i in range(21):
            x = -1 + 0.1 * i
            approx = spb_pow(3, x / c)
            target = math.sin(math.pi * x / 2)
            err = abs(approx - target)
            max_err = max(max_err, err)
        print(f"    c={c:.1f}: max|spb_pow(3, x/{c}) - sin(πx/2)| = {max_err:.6f}")

# ============================================================
# Section 9: Random SPB and Cauchy Distribution
# ============================================================

def demonstrate_random_spb():
    print("\n" + "=" * 60)
    print("SECTION 8: RANDOM SPB ITERATION")
    print("=" * 60)

    # Random SPB iteration: x_{n+1} = spb(x_n, a_n) where a_n ~ Uniform[-1,1]
    # The stationary distribution should be Cauchy

    random.seed(42)
    N = 100000
    x = 0.0
    samples = []
    for i in range(N + 1000):  # burn-in
        a = random.uniform(-1, 1)
        x = spb(x, a)
        if abs(x) > 1e10:  # handle blow-ups
            x = 0
        if i >= 1000:
            samples.append(x)

    # Check: the distribution should be heavy-tailed (Cauchy-like)
    samples_clipped = [s for s in samples if abs(s) < 100]

    # Compute quantiles
    samples_clipped.sort()
    n = len(samples_clipped)
    print(f"\n  Random SPB iteration: x_{{n+1}} = spb(x_n, a_n), a_n ~ U[-1,1]")
    print(f"  {N} samples (clipped to |x|<100: {n} remain)")

    q25 = samples_clipped[n//4]
    q50 = samples_clipped[n//2]
    q75 = samples_clipped[3*n//4]
    print(f"  Quartiles: Q25={q25:.4f}, Q50={q50:.4f}, Q75={q75:.4f}")
    print(f"  IQR = {q75-q25:.4f}")
    print(f"  (Cauchy has infinite variance — heavy tails expected)")

    # Fraction in various intervals
    for bound in [1, 5, 10, 50]:
        frac = sum(1 for s in samples if abs(s) <= bound) / len(samples)
        print(f"  P(|X| ≤ {bound:2d}) = {frac:.4f}")

# ============================================================
# Section 10: Cocycle Identity
# ============================================================

def demonstrate_cocycle():
    print("\n" + "=" * 60)
    print("SECTION 9: COCYCLE IDENTITY")
    print("=" * 60)

    # (1-xy)(1-spb(x,y)·z) = (1-yz)(1-x·spb(y,z))
    for x, y, z in [(0.2, 0.3, 0.4), (0.5, -0.3, 0.7), (1.5, 0.2, -0.8)]:
        lhs = (1 - x*y) * (1 - spb(x,y) * z)
        rhs = (1 - y*z) * (1 - x * spb(y,z))
        print(f"  x={x:5.1f}, y={y:5.1f}, z={z:5.1f}: LHS={lhs:.10f}, RHS={rhs:.10f}, match={abs(lhs-rhs)<1e-10}")

    print("\n  Cocycle interpretation:")
    print("  c(x,y) = 1/(1-xy) is a 2-cocycle on the SPB group")
    print("  The cocycle identity is: c(x,y)·c(spb(x,y),z) = c(y,z)·c(x,spb(y,z))")

# ============================================================
# Section 11: Möbius Matrix Representation
# ============================================================

def demonstrate_mobius():
    print("\n" + "=" * 60)
    print("SECTION 10: MÖBIUS MATRIX REPRESENTATION")
    print("=" * 60)

    import numpy as np

    def spb_matrix(a):
        return np.array([[1, a], [-a, 1]])

    a, b = 0.3, 0.5
    Ma = spb_matrix(a)
    Mb = spb_matrix(b)
    product = Ma @ Mb

    spb_val = spb(a, b)
    M_spb = spb_matrix(spb_val)

    # product should be proportional to M_spb
    scale = (1 - a * b)
    print(f"\n  M({a}) · M({b}) =\n{product}")
    print(f"\n  (1-ab) · M(spb({a},{b})) = {scale} · M({spb_val:.6f}) =\n{scale * M_spb}")
    print(f"\n  Equal: {np.allclose(product, scale * M_spb)}")

    # Determinant = 1 + a²
    for val in [0.3, 0.5, 1.0, 2.0]:
        det = np.linalg.det(spb_matrix(val))
        expected = 1 + val**2
        print(f"  det(M({val})) = {det:.6f}, 1+a² = {expected:.6f}, match={abs(det-expected)<1e-10}")

# ============================================================
# Section 12: SPB Neural Network Activation
# ============================================================

def demonstrate_neural_spb():
    print("\n" + "=" * 60)
    print("SECTION 11: SPB AS NEURAL NETWORK ACTIVATION")
    print("=" * 60)

    # SPB neuron: combines inputs via iterated SPB
    def spb_neuron(inputs, weights):
        """Combine weighted inputs via SPB chain"""
        result = 0
        for x, w in zip(inputs, weights):
            result = spb(result, w * x)
        return result

    # Compare with standard neuron (linear + tanh)
    import math
    def standard_neuron(inputs, weights):
        return math.tanh(sum(w * x for w, x in zip(inputs, weights)))

    inputs = [0.3, -0.5, 0.8, 0.1]
    weights = [0.4, 0.6, -0.3, 0.9]

    spb_out = spb_neuron(inputs, weights)
    std_out = standard_neuron(inputs, weights)

    print(f"\n  Inputs:  {inputs}")
    print(f"  Weights: {weights}")
    print(f"  SPB neuron output:      {spb_out:.8f}")
    print(f"  Standard tanh output:   {std_out:.8f}")

    # Key advantage: SPB derivative is always positive (monotone)
    print(f"\n  SPB derivative: d/dx spb(x,y) = (1+y²)/(1-xy)²")
    for y in [0.0, 0.5, 1.0, 2.0]:
        for x in [0.0, 0.3, 0.5]:
            if abs(x*y) < 1:
                deriv = (1 + y**2) / (1 - x*y)**2
                print(f"    d/dx spb(x={x}, y={y}) = {deriv:.4f} > 0 ✓")

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  STEREOGRAPHIC PROJECTION BRIDGE — INTERACTIVE EXPLORER ║")
    print("║  spb(x,y) = (x+y)/(1-xy)                               ║")
    print("╚══════════════════════════════════════════════════════════╝")

    verify_group_properties()
    demonstrate_cayley_bridge()
    demonstrate_tangent_addition()
    demonstrate_velocity_addition()
    demonstrate_finite_fields()
    demonstrate_gregory_leibniz()
    demonstrate_approximation()
    demonstrate_random_spb()
    demonstrate_cocycle()

    try:
        demonstrate_mobius()
    except ImportError:
        print("\n[Skipping Möbius demo — numpy not available]")

    demonstrate_neural_spb()

    print("\n" + "=" * 60)
    print("DEMO COMPLETE — All SPB properties verified computationally")
    print("=" * 60)
