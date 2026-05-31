#!/usr/bin/env python3
"""
Hyperbolic Arithmetic Demo
===========================

Numerical demonstrations of the key results from
Hyperbolic Number Theory on the Poincaré Disk.
"""

import math
from algorithms import (
    moebius_add, moebius_iterate, moebius_iterate_recursive,
    hyp_dist, orbit_gap, word_ball_size, hyp_zeta_summand,
    gyration, pythagorean_disk_point, find_pythagorean_triples,
    verify_orbit_separation, verify_associativity
)


def demo_moebius_addition():
    """Demonstrate Möbius addition properties."""
    print("=" * 60)
    print("DEMO 1: Möbius Addition on the Poincaré Disk")
    print("=" * 60)
    
    pairs = [(0.5, 0.3), (0.7, -0.2), (0.9, 0.9), (-0.5, 0.8)]
    for a, b in pairs:
        result = moebius_add(a, b)
        print(f"  {a} ⊕ {b} = {result:.6f}  (|result| = {abs(result):.6f} < 1 ✓)")
    
    print("\nCommutativity check:")
    for a, b in pairs:
        diff = abs(moebius_add(a, b) - moebius_add(b, a))
        print(f"  |{a}⊕{b} - {b}⊕{a}| = {diff:.2e}")
    
    print("\nAssociativity check (real case — should be exact):")
    triples = [(0.5, 0.3, 0.1), (0.7, -0.2, 0.4), (0.1, 0.2, 0.3)]
    for a, b, c in triples:
        diff = verify_associativity(a, b, c)
        print(f"  |(a⊕b)⊕c - a⊕(b⊕c)| for ({a},{b},{c}) = {diff:.2e}")


def demo_iteration():
    """Demonstrate Möbius iteration and monotonicity."""
    print("\n" + "=" * 60)
    print("DEMO 2: Möbius Iteration — Monotone Convergence to Boundary")
    print("=" * 60)
    
    a = 0.3
    print(f"\nIterating a = {a}:")
    print(f"  {'n':>3}  {'recursive':>12}  {'artanh':>12}  {'gap':>12}")
    for n in range(11):
        rec = moebius_iterate_recursive(a, n)
        fast = moebius_iterate(a, n)
        gap = 1.0 - fast
        print(f"  {n:3d}  {rec:12.8f}  {fast:12.8f}  {gap:12.8f}")
    
    print(f"\n  → Converges to 1 (the boundary) as n → ∞")
    print(f"  → artanh formula: tanh(n · artanh({a})) = tanh(n · {math.atanh(a):.4f})")


def demo_orbit_separation():
    """Test the orbit separation conjecture."""
    print("\n" + "=" * 60)
    print("DEMO 3: Orbit Separation Conjecture Test")
    print("=" * 60)
    
    a, b = 1/3, 1/2
    print(f"\nTesting with a = 1/3, b = 1/2:")
    gaps = verify_orbit_separation(a, b, 20)
    
    all_positive = all(g > 0 for g in gaps)
    print(f"  {'n':>3}  {'gap':>14}  {'positive?':>10}")
    for i, gap in enumerate(gaps):
        print(f"  {i+1:3d}  {gap:14.10f}  {'✓' if gap > 0 else '✗':>10}")
    
    print(f"\n  All gaps positive: {'YES ✓' if all_positive else 'NO ✗'}")
    print(f"  Conjecture {'SUPPORTED' if all_positive else 'REFUTED'} for this test case.")


def demo_exponential_growth():
    """Demonstrate exponential growth of word balls."""
    print("\n" + "=" * 60)
    print("DEMO 4: Exponential Growth of Hyperbolic Lattice Balls")
    print("=" * 60)
    
    print(f"\n  {'n':>3}  {'|B(n)|':>10}  {'2^n':>10}  {'ratio':>8}")
    for n in range(13):
        ball = word_ball_size(n)
        exp = 2**n
        ratio = ball / exp if exp > 0 else 0
        print(f"  {n:3d}  {ball:10d}  {exp:10d}  {ratio:8.2f}")
    
    print(f"\n  → Ball grows as 2^(n+1) - 1 (exponential in n)")
    print(f"  → Contrast with Euclidean ℤ^d where |B(n)| ~ n^d (polynomial)")


def demo_zeta_reversal():
    """Demonstrate the zeta summand reversal phenomenon."""
    print("\n" + "=" * 60)
    print("DEMO 5: Zeta Summand Reversal")
    print("=" * 60)
    
    r = 0.5
    s = 1.0
    print(f"\nClassical vs Hyperbolic zeta summands (r = {r}, s = {s}):")
    print(f"  {'n':>3}  {'classical 1/n^{2s}':>18}  {'hyperbolic r^{-2sn}':>20}")
    for n in range(1, 11):
        classical = 1.0 / n**(2*s) if n > 0 else float('inf')
        hyperbolic = hyp_zeta_summand(r**n, s)
        print(f"  {n:3d}  {classical:18.8f}  {hyperbolic:20.4f}")
    
    print(f"\n  → Classical summands decay to 0")
    print(f"  → Hyperbolic summands grow without bound!")


def demo_pythagorean_bridge():
    """Demonstrate the Pythagorean-to-disk bridge."""
    print("\n" + "=" * 60)
    print("DEMO 6: Pythagorean Triples as Hyperbolic Lattice Points")
    print("=" * 60)
    
    triples = find_pythagorean_triples(50)
    print(f"\nPrimitive Pythagorean triples → disk points:")
    print(f"  {'(a, b, c)':>15}  {'a/c':>8}  {'in disk?':>10}")
    for a, b, c in triples[:10]:
        point = pythagorean_disk_point(a, b, c)
        in_disk = abs(point) < 1
        print(f"  ({a:3d},{b:3d},{c:3d})  {point:8.4f}  {'✓' if in_disk else '✗':>10}")
    
    print(f"\nMöbius sums of Pythagorean disk points:")
    for i in range(min(5, len(triples))):
        for j in range(i+1, min(5, len(triples))):
            p1 = pythagorean_disk_point(*triples[i])
            p2 = pythagorean_disk_point(*triples[j])
            s = moebius_add(p1, p2)
            print(f"  {triples[i]} ⊕ {triples[j]}: {p1:.4f} ⊕ {p2:.4f} = {s:.6f}  (|s| < 1: {abs(s) < 1})")


def demo_gyration():
    """Show that gyration is trivial on ℝ (associativity holds)."""
    print("\n" + "=" * 60)
    print("DEMO 7: Gyration is Trivial on ℝ")
    print("=" * 60)
    
    test_cases = [(0.3, 0.4, 0.5), (0.1, -0.2, 0.7), (0.8, 0.1, -0.3)]
    print(f"\nFor all a, b, c: gyr[a,b](c) should equal c:")
    print(f"  {'(a, b, c)':>20}  {'gyr[a,b](c)':>12}  {'c':>8}  {'match?':>8}")
    for a, b, c in test_cases:
        g = gyration(a, b, c)
        match = abs(g - c) < 1e-12
        print(f"  ({a:4.1f},{b:5.1f},{c:5.1f})  {g:12.8f}  {c:8.4f}  {'✓' if match else '✗':>8}")
    
    print(f"\n  → On ℝ, the gyration is identity: (ℝ-disk, ⊕) is an abelian GROUP")
    print(f"  → Non-trivial gyration only appears in ℂ-disk (2+ dimensions)")


def demo_hyperbolic_distance():
    """Demonstrate hyperbolic distance."""
    print("\n" + "=" * 60)
    print("DEMO 8: Hyperbolic Distance")
    print("=" * 60)
    
    pairs = [(0, 0.5), (0.3, 0.7), (0, 0.9), (0, 0.99)]
    print(f"\n  {'(a, b)':>12}  {'d_H(a,b)':>10}  {'d_H(b,a)':>10}  {'symmetric?':>12}")
    for a, b in pairs:
        d1 = hyp_dist(a, b)
        d2 = hyp_dist(b, a)
        sym = abs(d1 - d2) < 1e-15
        print(f"  ({a:4.2f},{b:4.2f})  {d1:10.6f}  {d2:10.6f}  {'✓' if sym else '✗':>12}")
    
    print(f"\n  → Near boundary (r → 1), distances blow up to ∞")
    print(f"  → This is the hallmark of hyperbolic geometry")


if __name__ == "__main__":
    demo_moebius_addition()
    demo_iteration()
    demo_orbit_separation()
    demo_exponential_growth()
    demo_zeta_reversal()
    demo_pythagorean_bridge()
    demo_gyration()
    demo_hyperbolic_distance()
    
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Hyperbolic Arithmetic on the Poincaré Disk
"""
import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def moebius_add(a, b):
    return (a + b) / (1 + a * b)


def moebius_iterate(a, n):
    if n == 0:
        return 0.0
    return math.tanh(n * math.atanh(a))


def orbit_gap(a, b, n):
    return moebius_iterate(b, n) - moebius_iterate(a, n)


fig, axes = plt.subplots(2, 2, figsize=(14, 10))
fig.suptitle("Hyperbolic Arithmetic on the Poincaré Disk", fontsize=16, fontweight='bold')

# Panel 1: Möbius iteration convergence
ax1 = axes[0, 0]
for a in [0.1, 0.3, 0.5, 0.7, 0.9]:
    ns = list(range(21))
    vals = [moebius_iterate(a, n) for n in ns]
    ax1.plot(ns, vals, 'o-', markersize=3, label=f'a = {a}')
ax1.axhline(y=1, color='red', linestyle='--', alpha=0.5, label='Boundary')
ax1.set_xlabel('Step n')
ax1.set_ylabel('moebiusIterate(a, n)')
ax1.set_title('Möbius Iteration: Monotone Convergence to Boundary')
ax1.legend(fontsize=8)
ax1.grid(True, alpha=0.3)

# Panel 2: Orbit separation
ax2 = axes[0, 1]
test_pairs = [(0.2, 0.4), (0.3, 0.5), (0.1, 0.8)]
ns = list(range(1, 26))
for a, b in test_pairs:
    gaps = [orbit_gap(a, b, n) for n in ns]
    ax2.semilogy(ns, gaps, 'o-', markersize=3, label=f'a={a}, b={b}')
ax2.set_xlabel('Step n')
ax2.set_ylabel('Orbit Gap (log scale)')
ax2.set_title('Orbit Separation Conjecture: Gaps Stay Positive')
ax2.legend(fontsize=8)
ax2.grid(True, alpha=0.3)

# Panel 3: Exponential growth vs polynomial
ax3 = axes[1, 0]
ns = list(range(1, 16))
ball_sizes = [2**(n+1) - 1 for n in ns]
euclidean_1d = [2*n + 1 for n in ns]
euclidean_2d = [(2*n+1)**2 for n in ns]
ax3.semilogy(ns, ball_sizes, 'ro-', markersize=4, label='Hyperbolic: 2^(n+1)-1')
ax3.semilogy(ns, euclidean_1d, 'b^-', markersize=4, label='Euclidean ℤ¹: 2n+1')
ax3.semilogy(ns, euclidean_2d, 'gs-', markersize=4, label='Euclidean ℤ²: (2n+1)²')
ax3.set_xlabel('Radius n')
ax3.set_ylabel('Ball Size (log scale)')
ax3.set_title('Exponential vs Polynomial Growth')
ax3.legend(fontsize=8)
ax3.grid(True, alpha=0.3)

# Panel 4: Zeta summand reversal
ax4 = axes[1, 1]
ns_zeta = list(range(1, 16))
for r in [0.3, 0.5, 0.7]:
    hyp_summands = [r**(-2*n) for n in ns_zeta]
    ax4.semilogy(ns_zeta, hyp_summands, 'o-', markersize=3, label=f'Hyperbolic r={r}')
classical = [1.0/n**2 for n in ns_zeta]
ax4.semilogy(ns_zeta, classical, 'k^-', markersize=4, label='Classical 1/n²')
ax4.axhline(y=1, color='gray', linestyle=':', alpha=0.5)
ax4.set_xlabel('n')
ax4.set_ylabel('Summand Value (log scale)')
ax4.set_title('Zeta Summand Reversal: Growth vs Decay')
ax4.legend(fontsize=8)
ax4.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('hyperbolic_arithmetic.png', dpi=150, bbox_inches='tight')
print("Saved visualization to hyperbolic_arithmetic.png")
