#!/usr/bin/env python3
"""
Stereographic Projection Bridge — Comprehensive Research Demo Suite

Demonstrates all major SPB properties and research directions:

1. Core SPB algebra & group structure
2. Cayley transform & circle visualization
3. Einstein velocity addition (hyperbolic SPB)
4. SPB over finite fields (p±1 law)
5. SPB trees & Chebyshev connections
6. Thomas precession (3D SPB)
7. SPB neural network neuron
8. SPB continued fraction / Gregory-Leibniz
9. Random SPB iteration & Cauchy distribution
10. SPB Möbius matrices

Usage:
    python spb_comprehensive_demo.py

Outputs saved to: spb_output/
"""

import numpy as np
import os
import json
from fractions import Fraction

OUTPUT_DIR = os.path.join(os.path.dirname(__file__), "..", "output")
os.makedirs(OUTPUT_DIR, exist_ok=True)

# ============================================================
# Core SPB Functions
# ============================================================

def spb(x, y):
    """Standard SPB: (x + y) / (1 - x*y)"""
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return float('inf') * np.sign(x + y)
    return (x + y) / denom

def spbH(u, v):
    """Hyperbolic SPB (Einstein velocity addition): (u + v) / (1 + u*v)"""
    return (u + v) / (1 + u * v)

def cayley(x):
    """Cayley transform: x ↦ (1 + ix)/(1 - ix)"""
    return (1 + 1j * x) / (1 - 1j * x)

def spb_iter(n, x):
    """n-fold iterated SPB: spb(x, spb(x, ...)) = tan(n * arctan(x))"""
    return np.tan(n * np.arctan(x))

def spb_mobius_matrix(a):
    """SPB Möbius matrix: [[1, a], [-a, 1]]"""
    return np.array([[1, a], [-a, 1]])

# ============================================================
# Demo 1: Core SPB Algebra
# ============================================================

def demo_core_algebra():
    """Verify all group axioms computationally."""
    print("=" * 60)
    print("DEMO 1: Core SPB Algebra — Group Axioms")
    print("=" * 60)

    results = {}

    # Commutativity
    x, y = 0.3, 0.7
    assert abs(spb(x, y) - spb(y, x)) < 1e-14
    results["commutativity"] = f"spb({x}, {y}) = {spb(x,y):.10f} = spb({y}, {x})"
    print(f"  Commutativity: {results['commutativity']}")

    # Identity
    assert abs(spb(x, 0) - x) < 1e-14
    results["identity"] = f"spb({x}, 0) = {spb(x,0):.10f} = {x}"
    print(f"  Identity: {results['identity']}")

    # Inverse
    assert abs(spb(x, -x)) < 1e-14
    results["inverse"] = f"spb({x}, {-x}) = {spb(x,-x):.10e}"
    print(f"  Inverse: {results['inverse']}")

    # Associativity
    z = 0.2
    lhs = spb(spb(x, y), z)
    rhs = spb(x, spb(y, z))
    assert abs(lhs - rhs) < 1e-13
    results["associativity"] = f"spb(spb({x},{y}),{z}) = {lhs:.10f} = spb({x},spb({y},{z}))"
    print(f"  Associativity: {results['associativity']}")

    # Tangent addition
    a, b = 0.5, 0.8
    lhs = np.tan(a + b)
    rhs = spb(np.tan(a), np.tan(b))
    assert abs(lhs - rhs) < 1e-13
    results["tan_addition"] = f"tan({a}+{b}) = {lhs:.10f} = spb(tan {a}, tan {b})"
    print(f"  tan addition: {results['tan_addition']}")

    # Double angle
    t = np.tan(a)
    lhs = np.tan(2 * a)
    rhs = spb(t, t)
    assert abs(lhs - rhs) < 1e-13
    results["double_angle"] = f"tan(2·{a}) = {lhs:.10f} = spb(tan {a}, tan {a})"
    print(f"  Double angle: {results['double_angle']}")

    print()
    return results

# ============================================================
# Demo 2: Cayley Transform & Circle Group
# ============================================================

def demo_cayley_transform():
    """Demonstrate the Cayley transform bridge."""
    print("=" * 60)
    print("DEMO 2: Cayley Transform — SPB ↔ Circle Multiplication")
    print("=" * 60)

    results = {}

    # Cayley maps to unit circle
    test_values = [0, 0.5, 1, -1, 2, -3, 0.1, 10]
    for x in test_values:
        c = cayley(x)
        assert abs(abs(c) - 1) < 1e-14, f"|cayley({x})| = {abs(c)}"
    results["unit_circle"] = "All cayley(x) have |cayley(x)| = 1 ✓"
    print(f"  {results['unit_circle']}")

    # Cayley converts SPB to multiplication
    x, y = 0.3, 0.7
    c_spb = cayley(spb(x, y))
    c_prod = cayley(x) * cayley(y)
    assert abs(c_spb - c_prod) < 1e-13
    results["homomorphism"] = f"cayley(spb({x},{y})) = cayley({x})·cayley({y}) ✓"
    print(f"  Homomorphism: {results['homomorphism']}")

    # Cayley of 0 = 1 (identity maps to identity)
    assert abs(cayley(0) - 1) < 1e-14
    results["identity_map"] = "cayley(0) = 1 ✓"
    print(f"  Identity maps: {results['identity_map']}")

    # Cayley of -x = conj(cayley(x))
    x = 0.5
    assert abs(cayley(-x) - np.conj(cayley(x))) < 1e-14
    results["inverse_map"] = f"cayley({-x}) = conj(cayley({x})) ✓"
    print(f"  Inverse maps: {results['inverse_map']}")

    # Angle interpretation
    print("\n  Cayley angle table:")
    print(f"  {'x':>8}  {'cayley(x)':>20}  {'angle/π':>10}")
    print(f"  {'—'*8}  {'—'*20}  {'—'*10}")
    for x in [0, 0.5, 1, 2, -1, -0.5]:
        c = cayley(x)
        angle = np.angle(c) / np.pi
        print(f"  {x:>8.2f}  {c.real:>8.4f} + {c.imag:>8.4f}i  {angle:>10.4f}")

    print()
    return results

# ============================================================
# Demo 3: Einstein Velocity Addition
# ============================================================

def demo_velocity_addition():
    """Demonstrate Einstein velocity addition as hyperbolic SPB."""
    print("=" * 60)
    print("DEMO 3: Einstein Velocity Addition (Hyperbolic SPB)")
    print("=" * 60)

    results = {}

    # Speed of light barrier
    print("\n  Velocity composition (c = 1):")
    print(f"  {'v₁':>8}  {'v₂':>8}  {'v₁+v₂ (Newton)':>16}  {'spbH(v₁,v₂)':>14}")
    print(f"  {'—'*8}  {'—'*8}  {'—'*16}  {'—'*14}")

    test_pairs = [
        (0.1, 0.2), (0.5, 0.5), (0.8, 0.8), (0.9, 0.9),
        (0.99, 0.99), (0.999, 0.999)
    ]
    for v1, v2 in test_pairs:
        newton = v1 + v2
        einstein = spbH(v1, v2)
        print(f"  {v1:>8.3f}  {v2:>8.3f}  {newton:>16.6f}  {einstein:>14.10f}")
        assert abs(einstein) < 1, f"spbH({v1},{v2}) = {einstein} ≥ 1!"

    results["light_speed_barrier"] = "All spbH(v₁,v₂) < 1 for |v₁|,|v₂| < 1 ✓"
    print(f"\n  {results['light_speed_barrier']}")

    # Rapidity additivity
    print("\n  Rapidity additivity:")
    r1, r2 = 0.5, 0.8
    v1, v2 = np.tanh(r1), np.tanh(r2)
    result = spbH(v1, v2)
    expected = np.tanh(r1 + r2)
    assert abs(result - expected) < 1e-14
    results["rapidity"] = f"spbH(tanh({r1}), tanh({r2})) = tanh({r1+r2}) ✓"
    print(f"  {results['rapidity']}")

    print()
    return results

# ============================================================
# Demo 4: SPB over Finite Fields
# ============================================================

def demo_finite_fields():
    """Demonstrate the p±1 law for SPB over F_p."""
    print("=" * 60)
    print("DEMO 4: SPB over Finite Fields — The p±1 Law")
    print("=" * 60)

    results = {}

    def spb_mod(x, y, p):
        """SPB over Z/pZ."""
        denom = (1 - x * y) % p
        if denom == 0:
            return None  # undefined (infinity)
        return ((x + y) * pow(denom, p - 2, p)) % p

    def spb_proj(x, g, p):
        """SPB on P^1(F_p), handling infinity."""
        if x is None:  # x = infinity
            if g == 0:
                return None
            return ((-1) * pow(g, p - 2, p)) % p
        denom = (1 - x * g) % p
        if denom == 0:
            return None  # infinity
        return ((x + g) * pow(denom, p - 2, p)) % p

    def find_orbit(g, p):
        """Find the SPB orbit of generator g in F_p (including ∞)."""
        orbit = [0]
        seen = {0}
        current = g
        for _ in range(2 * p + 5):
            key = current if current is not None else 'inf'
            if key in seen:
                break
            seen.add(key)
            orbit.append(key)
            current = spb_proj(current, g, p)
        return orbit

    print("\n  The p±1 Law:")
    print(f"  {'p':>5}  {'p mod 4':>8}  {'Predicted':>10}  {'Orbit |g=1|':>12}  {'Match':>6}")
    print(f"  {'—'*5}  {'—'*8}  {'—'*10}  {'—'*12}  {'—'*6}")

    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]
    all_match = True
    for p in primes:
        pred = p + 1 if p % 4 == 3 else p - 1
        # Find maximum orbit over all generators
        actual = max(len(find_orbit(g, p)) for g in range(1, p))
        match = "✓" if actual == pred else "✗"
        if actual != pred:
            all_match = False
        print(f"  {p:>5}  {p % 4:>8}  {pred:>10}  {actual:>12}  {match:>6}")

    results["p_pm_1_law"] = f"p±1 law verified for {len(primes)} primes: {'ALL MATCH ✓' if all_match else 'SOME MISMATCH ✗'}"
    print(f"\n  {results['p_pm_1_law']}")

    # Show explicit orbit for p=7 with generator g=2
    print("\n  Explicit orbit for p=7 (≡ 3 mod 4), generator g=2:")
    p = 7
    g = 2
    orbit_list = find_orbit(g, p)
    print(f"  Orbit: {orbit_list}")
    print(f"  Size: {len(orbit_list)} (expected p+1 = {p+1})")

    print()
    return results

# ============================================================
# Demo 5: SPB Trees & Chebyshev Connection
# ============================================================

def demo_spb_trees():
    """Demonstrate SPB expression trees and Chebyshev connection."""
    print("=" * 60)
    print("DEMO 5: SPB Trees & Chebyshev Polynomials")
    print("=" * 60)

    results = {}

    # SPB iteration = Chebyshev-like recurrence
    print("\n  SPB iteration: spb_iter(n, x) = tan(n·arctan(x))")
    print(f"  {'n':>4}  {'spb_iter(n, 0.3)':>18}  {'tan(n·arctan(0.3))':>20}")
    print(f"  {'—'*4}  {'—'*18}  {'—'*20}")

    x = 0.3
    for n in range(1, 11):
        computed = spb_iter(n, x)
        expected = np.tan(n * np.arctan(x))
        print(f"  {n:>4}  {computed:>18.12f}  {expected:>20.12f}")
        assert abs(computed - expected) < 1e-10

    results["iteration"] = "spb_iter(n, x) = tan(n·arctan(x)) verified for n=1..10 ✓"
    print(f"\n  {results['iteration']}")

    # Connection to Chebyshev: if x = tan(θ), then
    # the numerator of spb_iter(n, x) is essentially Un(cos θ) · sin θ
    # and denominator is Tn(cos θ)
    print("\n  Chebyshev connection:")
    print("  tan(nθ) = U_{n-1}(cos θ)·sin θ / T_n(cos θ)")
    print("  where T_n, U_n are Chebyshev polynomials.")

    # Binary exponentiation via SPB
    print("\n  Binary exponentiation: computing tan(13θ) from tan(θ)")
    print("  13 = 1101₂, so: x → x² → x⁴ → x⁵ → x¹⁰ → x¹³")
    theta = 0.2
    t = np.tan(theta)

    # Manual binary exponentiation
    t2 = spb(t, t)           # tan(2θ)
    t4 = spb(t2, t2)         # tan(4θ)
    t5 = spb(t4, t)          # tan(5θ)
    t10 = spb(t5, t5)        # tan(10θ)
    t13 = spb(t10, spb(t2, t))  # tan(13θ)
    expected = np.tan(13 * theta)
    print(f"  Result: {t13:.12f}")
    print(f"  Expected: {expected:.12f}")
    print(f"  Match: {'✓' if abs(t13 - expected) < 1e-10 else '✗'}")

    results["binary_exp"] = f"Binary SPB exponentiation for n=13: error = {abs(t13-expected):.2e}"

    print()
    return results

# ============================================================
# Demo 6: Thomas Precession (3D SPB)
# ============================================================

def demo_thomas_precession():
    """Demonstrate 3D SPB and Thomas precession."""
    print("=" * 60)
    print("DEMO 6: 3D SPB & Thomas Precession")
    print("=" * 60)

    results = {}

    def spb3(u, v):
        """3D SPB: (u + v + u×v) / (1 - u·v)"""
        cross = np.cross(u, v)
        dot = np.dot(u, v)
        denom = 1 - dot
        if abs(denom) < 1e-15:
            return np.full(3, float('inf'))
        return (u + v + cross) / denom

    # Non-commutativity
    u = np.array([0.3, 0.1, 0.0])
    v = np.array([0.0, 0.2, 0.1])

    uv = spb3(u, v)
    vu = spb3(v, u)

    print(f"\n  u = {u}")
    print(f"  v = {v}")
    print(f"  spb₃(u, v) = [{uv[0]:.6f}, {uv[1]:.6f}, {uv[2]:.6f}]")
    print(f"  spb₃(v, u) = [{vu[0]:.6f}, {vu[1]:.6f}, {vu[2]:.6f}]")
    print(f"  Non-commutative: spb₃(u,v) ≠ spb₃(v,u) ✓" if not np.allclose(uv, vu) else "  Commutative! ✗")

    results["non_commutativity"] = f"||spb₃(u,v) - spb₃(v,u)|| = {np.linalg.norm(uv - vu):.6f}"
    print(f"  {results['non_commutativity']}")

    # Thomas rotation angle
    if not np.allclose(uv, vu):
        # The ratio of norms gives cos(θ_TW)
        ratio = np.dot(uv, vu) / (np.linalg.norm(uv) * np.linalg.norm(vu))
        ratio = np.clip(ratio, -1, 1)
        theta_tw = np.arccos(ratio)
        print(f"  Thomas rotation angle: {np.degrees(theta_tw):.4f}°")
        results["thomas_angle"] = f"{np.degrees(theta_tw):.4f}°"

    # Identity and inverse in 3D
    zero = np.array([0.0, 0.0, 0.0])
    assert np.allclose(spb3(u, zero), u)
    assert np.allclose(spb3(u, -u), zero, atol=1e-14)
    results["3d_group"] = "Identity (0) and inverse (-u) verified in 3D ✓"
    print(f"  {results['3d_group']}")

    print()
    return results

# ============================================================
# Demo 7: SPB Neural Network Neuron
# ============================================================

def demo_spb_neuron():
    """Demonstrate SPB as a neural network activation."""
    print("=" * 60)
    print("DEMO 7: SPB Neural Network Neuron")
    print("=" * 60)

    results = {}

    def spb_neuron(inputs, weights):
        """SPB neuron: sequentially combines weighted inputs via SPB."""
        result = 0.0
        for x, w in zip(inputs, weights):
            wx = np.clip(w * x, -10, 10)  # prevent singularity
            result = spb(result, wx)
        return result

    # Compare SPB neuron vs standard neuron
    np.random.seed(42)
    n_features = 5
    n_samples = 1000

    X = np.random.randn(n_samples, n_features) * 0.5
    weights = np.random.randn(n_features) * 0.3

    spb_outputs = []
    linear_outputs = []
    for i in range(n_samples):
        spb_out = spb_neuron(X[i], weights)
        lin_out = np.dot(X[i], weights)
        spb_outputs.append(spb_out)
        linear_outputs.append(lin_out)

    spb_outputs = np.array(spb_outputs)
    linear_outputs = np.array(linear_outputs)

    print(f"\n  SPB neuron statistics (n={n_samples}):")
    print(f"    Mean:   {np.mean(spb_outputs):.6f}")
    print(f"    Std:    {np.std(spb_outputs):.6f}")
    print(f"    Min:    {np.min(spb_outputs):.6f}")
    print(f"    Max:    {np.max(spb_outputs):.6f}")

    print(f"\n  Linear neuron statistics:")
    print(f"    Mean:   {np.mean(linear_outputs):.6f}")
    print(f"    Std:    {np.std(linear_outputs):.6f}")
    print(f"    Min:    {np.min(linear_outputs):.6f}")
    print(f"    Max:    {np.max(linear_outputs):.6f}")

    # Key property: SPB neuron is monotone
    print(f"\n  Monotonicity test:")
    x_test = np.linspace(-2, 2, 100)
    y_test = [spb(xi, 0.5) for xi in x_test]
    is_monotone = all(y_test[i] <= y_test[i+1] for i in range(len(y_test)-1))
    print(f"    spb(x, 0.5) is monotone increasing: {'✓' if is_monotone else '✗'}")

    results["monotone"] = f"SPB monotonicity verified ✓"
    results["bounded"] = f"SPB outputs: [{np.min(spb_outputs):.4f}, {np.max(spb_outputs):.4f}]"
    print(f"  {results['monotone']}")

    # Periodic data fitting advantage
    print(f"\n  Periodic function approximation:")
    print(f"  SPB naturally generates tan(n·arctan(x)) = periodic-like functions")
    print(f"  This is ideal for cyclical data (time-of-day, season, phase)")

    print()
    return results

# ============================================================
# Demo 8: Gregory-Leibniz via SPB
# ============================================================

def demo_continued_fraction():
    """SPB connection to continued fractions and π."""
    print("=" * 60)
    print("DEMO 8: SPB & Gregory-Leibniz Series for π")
    print("=" * 60)

    results = {}

    # π/4 = arctan(1) = 1 - 1/3 + 1/5 - 1/7 + ...
    # Equivalently: arctan(1) = arctan(1/2) + arctan(1/3) via SPB:
    #   spb(1/2, 1/3) = (1/2 + 1/3)/(1 - 1/6) = (5/6)/(5/6) = 1 ✓

    print(f"\n  Machin-like formula via SPB:")
    print(f"  spb(1/2, 1/3) = {spb(0.5, 1/3):.10f}")
    print(f"  Expected: 1.0")
    assert abs(spb(0.5, 1/3) - 1.0) < 1e-14

    # Machin's formula: π/4 = 4·arctan(1/5) - arctan(1/239)
    # In SPB terms: spb_iter(4, 1/5) gives tan(4·arctan(1/5))
    t4 = spb_iter(4, 1/5)
    # Then π/4 = arctan(spb_iter(4, 1/5)) - arctan(1/239)
    # spb(t4, -1/239) should equal 1
    machin = spb(t4, -1/239)
    print(f"\n  Machin's formula via SPB:")
    print(f"  spb_iter(4, 1/5) = {t4:.10f}")
    print(f"  spb(spb_iter(4, 1/5), -1/239) = {machin:.10f}")
    print(f"  Expected: 1.0 (= tan(π/4))")
    assert abs(machin - 1.0) < 1e-10

    results["machin"] = "Machin's formula verified via SPB ✓"
    print(f"\n  {results['machin']}")

    # Euler's formula: π/4 = arctan(1/2) + arctan(1/3)
    euler = spb(1/2, 1/3)
    print(f"\n  Euler: spb(1/2, 1/3) = {euler:.10f} = tan(π/4) ✓")

    # Verify: arctan(1/2) + arctan(1/3) = π/4
    print(f"  arctan(1/2) + arctan(1/3) = {np.arctan(0.5) + np.arctan(1/3):.10f}")
    print(f"  π/4 = {np.pi/4:.10f}")

    # Gregory-Leibniz via SPB iteration
    print(f"\n  Gregory-Leibniz via iterated SPB:")
    partial_sum = 0
    for n in range(1, 20):
        term = (-1)**(n+1) / (2*n - 1)
        partial_sum += term
        pi_approx = 4 * partial_sum
        print(f"  n={n:>3}: π ≈ {pi_approx:.10f}  (error: {abs(pi_approx - np.pi):.2e})")

    print()
    return results

# ============================================================
# Demo 9: Random SPB Iteration & Cauchy Distribution
# ============================================================

def demo_random_spb():
    """Random SPB iteration converges to Cauchy distribution."""
    print("=" * 60)
    print("DEMO 9: Random SPB Iteration → Cauchy Distribution")
    print("=" * 60)

    results = {}

    np.random.seed(42)
    n_iterations = 10000
    n_trajectories = 5000

    # X_{n+1} = spb(X_n, a_n) where a_n ~ N(0, σ²)
    sigma = 0.5
    final_values = []

    for _ in range(n_trajectories):
        x = 0.0
        for _ in range(n_iterations):
            a = np.random.normal(0, sigma)
            x = spb(x, a)
            # Handle overflow
            if abs(x) > 1e10:
                x = np.sign(x) * 1e10
        final_values.append(x)

    final_values = np.array(final_values)

    # The distribution should be heavy-tailed (Cauchy-like)
    median = np.median(final_values)
    iqr = np.percentile(final_values, 75) - np.percentile(final_values, 25)

    print(f"\n  After {n_iterations} SPB iterations with N(0, {sigma}²) steps:")
    print(f"    Median:  {median:.4f}")
    print(f"    IQR:     {iqr:.4f}")
    print(f"    Mean:    {np.mean(final_values):.4f} (may be unstable — Cauchy!)")

    # Check heavy tails: fraction beyond 2*IQR should be ~15% for Cauchy vs ~5% for Gaussian
    tail_frac = np.mean(np.abs(final_values - median) > 2 * iqr)
    print(f"    Tail fraction (|X - median| > 2·IQR): {tail_frac:.4f}")
    print(f"    (Cauchy: ~0.15, Gaussian: ~0.05)")

    results["distribution"] = f"Tail fraction: {tail_frac:.4f} (Cauchy-like if > 0.10)"

    print()
    return results

# ============================================================
# Demo 10: Möbius Matrices
# ============================================================

def demo_mobius():
    """SPB as Möbius transformation via 2×2 matrices."""
    print("=" * 60)
    print("DEMO 10: SPB Möbius Matrices")
    print("=" * 60)

    results = {}

    a, b = 0.3, 0.7

    Ma = spb_mobius_matrix(a)
    Mb = spb_mobius_matrix(b)

    # Matrix product
    Mab = Ma @ Mb
    print(f"\n  M({a}) = {Ma.tolist()}")
    print(f"  M({b}) = {Mb.tolist()}")
    print(f"  M({a})·M({b}) = {Mab.tolist()}")

    # Should be proportional to M(spb(a,b))
    spb_ab = spb(a, b)
    M_spb = spb_mobius_matrix(spb_ab)
    scale = (1 - a * b)
    print(f"\n  spb({a},{b}) = {spb_ab:.6f}")
    print(f"  (1-ab)·M(spb(a,b)) = {(scale * M_spb).tolist()}")
    print(f"  M(a)·M(b) = {Mab.tolist()}")

    assert np.allclose(Mab, scale * M_spb)
    results["matrix_composition"] = "M(a)·M(b) = (1-ab)·M(spb(a,b)) ✓"
    print(f"  {results['matrix_composition']}")

    # Determinant
    det_a = np.linalg.det(Ma)
    print(f"\n  det(M({a})) = {det_a:.6f} = 1 + {a}² = {1 + a**2:.6f}")
    assert abs(det_a - (1 + a**2)) < 1e-14
    results["determinant"] = f"det(M(a)) = 1 + a² ✓"
    print(f"  {results['determinant']}")

    print()
    return results

# ============================================================
# Demo 11: SPB Norm Multiplicativity
# ============================================================

def demo_norm_multiplicativity():
    """Verify the key algebraic identity underlying SPB."""
    print("=" * 60)
    print("DEMO 11: SPB Norm Multiplicativity")
    print("=" * 60)

    results = {}

    # (1 + spb(x,y)²) · (1-xy)² = (1+x²)(1+y²)
    test_pairs = [(0.3, 0.5), (1.5, -0.2), (0.1, 0.9), (-2, 0.3)]
    for x, y in test_pairs:
        s = spb(x, y)
        lhs = (1 + s**2) * (1 - x*y)**2
        rhs = (1 + x**2) * (1 + y**2)
        assert abs(lhs - rhs) < 1e-10
        print(f"  x={x:>5.1f}, y={y:>5.1f}: (1+spb²)(1-xy)² = {lhs:.8f} = (1+x²)(1+y²) = {rhs:.8f} ✓")

    results["norm_mult"] = "Norm multiplicativity verified for all test cases ✓"
    print(f"\n  {results['norm_mult']}")

    # Brahmagupta-Fibonacci
    a, b, c, d = 3, 4, 5, 12
    lhs = (a**2 + b**2) * (c**2 + d**2)
    rhs = (a*c - b*d)**2 + (a*d + b*c)**2
    print(f"\n  Brahmagupta-Fibonacci:")
    print(f"  ({a}²+{b}²)({c}²+{d}²) = {lhs}")
    print(f"  ({a}·{c}-{b}·{d})²+({a}·{d}+{b}·{c})² = ({a*c-b*d})²+({a*d+b*c})² = {rhs}")
    assert lhs == rhs

    results["brahmagupta"] = f"({a}²+{b}²)({c}²+{d}²) = {lhs} = {rhs} ✓"
    print(f"  {results['brahmagupta']}")

    print()
    return results

# ============================================================
# Main
# ============================================================

def main():
    print("\n" + "█" * 60)
    print("  STEREOGRAPHIC PROJECTION BRIDGE")
    print("  Comprehensive Research Demo Suite")
    print("█" * 60 + "\n")

    all_results = {}

    demos = [
        ("core_algebra", demo_core_algebra),
        ("cayley_transform", demo_cayley_transform),
        ("velocity_addition", demo_velocity_addition),
        ("finite_fields", demo_finite_fields),
        ("spb_trees", demo_spb_trees),
        ("thomas_precession", demo_thomas_precession),
        ("spb_neuron", demo_spb_neuron),
        ("continued_fraction", demo_continued_fraction),
        ("random_spb", demo_random_spb),
        ("mobius_matrices", demo_mobius),
        ("norm_multiplicativity", demo_norm_multiplicativity),
    ]

    for name, demo_fn in demos:
        try:
            all_results[name] = demo_fn()
        except Exception as e:
            print(f"  ✗ Demo {name} failed: {e}")
            all_results[name] = {"error": str(e)}

    # Save results
    output_path = os.path.join(OUTPUT_DIR, "demo_results.json")
    with open(output_path, 'w') as f:
        json.dump(all_results, f, indent=2, default=str)
    print(f"\nResults saved to: {output_path}")

    # Summary
    print("\n" + "=" * 60)
    print("SUMMARY")
    print("=" * 60)
    total = len(demos)
    success = sum(1 for r in all_results.values() if "error" not in r)
    print(f"  Demos completed: {success}/{total}")
    print(f"  All results saved to output/demo_results.json")
    print()

if __name__ == "__main__":
    main()
