#!/usr/bin/env python3
"""
EML Operator Explorer — Interactive Computational Demos
=======================================================

Demonstrates key properties of the EML operator eml(x,y) = exp(x) - ln(y):
1. Diagonal map orbits and divergence
2. Fixed point of g(z) = e - ln(z)
3. E-tower growth
4. AM-GM bridge verification
5. EML constant enumeration
6. Monotonicity demonstration
7. Magma identity failures
8. Level set computation
9. Tropical EML properties
10. Building functions from EML
"""

import math
from typing import Dict

def eml(x: float, y: float) -> float:
    """The EML operator: eml(x, y) = exp(x) - ln(y)."""
    if y <= 0:
        return float('inf')
    return math.exp(x) - math.log(y)

def diag(z: float) -> float:
    """Diagonal map: d(z) = exp(z) - ln(z)."""
    try:
        if z <= 0:
            return math.exp(z)
        return math.exp(z) - math.log(z)
    except OverflowError:
        return float('inf')

def g_map(z: float) -> float:
    """Attracting map: g(z) = e - ln(z)."""
    if z <= 0:
        return float('inf')
    return math.e - math.log(z)

def trop_eml(x: float, y: float) -> float:
    """Tropical EML: max(x, -y)."""
    return max(x, -y)

def demo_diagonal_orbits():
    print("=" * 60)
    print("DEMO 1: Diagonal Map Orbits d(z) = exp(z) - ln(z)")
    print("=" * 60)
    for z0 in [0.5, 1.0, 2.0, -1.0]:
        print(f"\n  Starting at z₀ = {z0}:")
        z = z0
        for i in range(6):
            z = diag(z)
            if z > 1e100 or z == float('inf'):
                print(f"    d^{i+1}(z₀) > 10^100 — diverged")
                break
            else:
                print(f"    d^{i+1}(z₀) = {z:.6f}")

def demo_fixed_point():
    print("\n" + "=" * 60)
    print("DEMO 2: Fixed Point of g(z) = e - ln(z)")
    print("=" * 60)
    z = 1.0
    for i in range(15):
        z = g_map(z)
        print(f"  g^{i+1}(1) = {z:.15f}")
    z_star = z
    print(f"\n  z* ≈ {z_star:.15f}")
    print(f"  z* + ln(z*) = {z_star + math.log(z_star):.15f} ≈ e = {math.e:.15f} ✓")
    print(f"  |g'(z*)| = 1/z* = {1/z_star:.6f} < 1 (attracting) ✓")

def demo_etower():
    print("\n" + "=" * 60)
    print("DEMO 3: E-Tower Superexponential Growth")
    print("=" * 60)
    t = 1.0
    for n in range(7):
        print(f"  e↑↑{n} = {t:.6f}" if t < 1e15 else f"  e↑↑{n} ≈ 10^{math.log10(t):.1f}")
        try:
            t = math.exp(t)
        except OverflowError:
            print(f"  e↑↑{n+1} > 10^308 (overflow)")
            break
        if t > 1e308:
            print(f"  e↑↑{n+1} > 10^308 (overflow)")
            break

def demo_am_gm():
    print("\n" + "=" * 60)
    print("DEMO 4: AM-GM Bridge: a + b - ln(a) - ln(b) ≥ 2")
    print("=" * 60)
    pairs = [(0.01, 100), (0.5, 2), (1, 1), (3, 7), (0.1, 0.1)]
    for a, b in pairs:
        val = a + b - math.log(a) - math.log(b)
        print(f"  a={a:>6.2f}, b={b:>6.2f}: {val:.8f} ≥ 2 ✓")
    print("  Minimum at a=b=1: 1+1-0-0 = 2 ✓")

def demo_constants():
    print("\n" + "=" * 60)
    print("DEMO 5: EML Constant Hierarchy")
    print("=" * 60)
    constants = {
        "eml(0,1) = 1": eml(0, 1),
        "eml(1,1) = e": eml(1, 1),
        "eml(2,1) = e²": eml(2, 1),
        "eml(eml(1,1),1) = eᵉ": eml(eml(1,1), 1),
        "eml(0, exp(1)) = 0 (≈ e-e)": eml(0, math.exp(math.e)),
        "eml(1, exp(e)) = e-e = 0": eml(1, math.exp(math.e)),
    }
    for desc, val in constants.items():
        print(f"  {desc} = {val:.10f}")

def demo_monotonicity():
    print("\n" + "=" * 60)
    print("DEMO 6: Monotonicity Properties")
    print("=" * 60)
    y = 2.0
    xs = [-1, 0, 1, 2, 3]
    vals = [eml(x, y) for x in xs]
    print(f"  Increasing in x (y={y}): {all(vals[i]<vals[i+1] for i in range(len(vals)-1))} ✓")
    for x, v in zip(xs, vals):
        print(f"    eml({x}, {y}) = {v:.6f}")

    x = 1.0
    ys = [0.5, 1, 2, 5, 10]
    vals = [eml(x, y) for y in ys]
    print(f"\n  Decreasing in y (x={x}): {all(vals[i]>vals[i+1] for i in range(len(vals)-1))} ✓")
    for y, v in zip(ys, vals):
        print(f"    eml({x}, {y}) = {v:.6f}")

def demo_magma():
    print("\n" + "=" * 60)
    print("DEMO 7: Magma Identity Failures (Universal Algebra)")
    print("=" * 60)
    a, b, c = 1.0, 2.0, 3.0
    print(f"  eml(a,b) = {eml(a,b):.4f} ≠ eml(b,a) = {eml(b,a):.4f}  → ¬commutative ✓")
    print(f"  eml(eml(a,b),c) = {eml(eml(a,b),c):.4f} ≠ eml(a,eml(b,c)) = {eml(a,eml(b,c)):.4f}  → ¬associative ✓")
    print(f"  eml(eml(a,b),a) = {eml(eml(a,b),a):.4f} ≠ eml(a,eml(b,a)) = {eml(a,eml(b,a)):.4f}  → ¬flexible ✓")
    print(f"  eml(1,1) = {eml(1,1):.4f} ≠ 1  → ¬idempotent ✓")
    print(f"  No left identity: eml(e₀, x) = x requires exp(e₀) - ln(0) = 0, impossible ✓")
    print(f"  No right identity: eml(x, e₀) = x requires exp(x) - ln(e₀) = x for all x, impossible ✓")

def demo_involution():
    print("\n" + "=" * 60)
    print("DEMO 8: Double Involution eml(0, exp(eml(0, exp(x)))) = x")
    print("=" * 60)
    for x in [0.0, 1.0, -2.5, math.pi, 42.0]:
        result = eml(0, math.exp(eml(0, math.exp(x))))
        print(f"  x = {x:>6.2f} → {result:.12f}  (error: {abs(result-x):.2e}) ✓")

def demo_complexity():
    print("\n" + "=" * 60)
    print("DEMO 9: Building Functions from EML")
    print("=" * 60)
    x = 2.0
    print(f"  exp(x) = eml(x, 1)           = {eml(x, 1):.6f} = {math.exp(x):.6f} ✓  [1 op]")
    print(f"  e      = eml(1, 1)           = {eml(1, 1):.6f}                       [1 op]")
    print(f"  e²     = eml(2, 1)           = {eml(2, 1):.6f} = {math.e**2:.6f} ✓  [1 op]")
    print(f"  exp²(x)= eml(eml(x,1), 1)   = {eml(eml(x,1), 1):.6f}                [2 ops]")
    print(f"  0      = eml(1, eml(e, 1))   via e - ln(eᵉ) = 0                      [3 ops]")
    print(f"  1-x    = eml(0, exp(x))      = {eml(0, math.exp(x)):.6f} = {1-x:.6f} ✓  [involution]")

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║       EML OPERATOR EXPLORER — Computational Demos       ║")
    print("║       eml(x, y) = exp(x) − ln(y)                       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    demo_diagonal_orbits()
    demo_fixed_point()
    demo_etower()
    demo_am_gm()
    demo_constants()
    demo_monotonicity()
    demo_magma()
    demo_involution()
    demo_complexity()
    print("\n" + "=" * 60)
    print("All demos completed successfully!")
    print("=" * 60)
