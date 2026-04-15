#!/usr/bin/env python3
"""
SPB-CORDIC: Computing Trigonometric Functions via SPB

Traditional CORDIC computes sin/cos by successive angle rotations.
SPB-CORDIC uses the identity: tan(α+β) = spb(tan α, tan β)
with pre-stored values tan(arctan(2⁻ᵏ)) = 2⁻ᵏ.

Algorithm:
1. Decompose θ = Σ ±arctan(2⁻ᵏ)
2. Accumulate: t = spb(t, ±2⁻ᵏ)
3. Recover: sin θ = 2t/(1+t²), cos θ = (1-t²)/(1+t²)

Each SPB step: 1 add, 1 multiply, 1 subtract, 1 divide.
"""

import math

def spb(x, y):
    """SPB: (x+y)/(1-xy)"""
    return (x + y) / (1 - x * y)

def spb_cordic_tan(theta, n_iterations=40):
    """
    Compute tan(θ) using SPB-CORDIC.

    Decomposes θ into sum of ±arctan(2⁻ᵏ) and accumulates via SPB.
    """
    # Pre-computed table: arctan(2⁻ᵏ)
    arctan_table = [math.atan(2**(-k)) for k in range(n_iterations)]

    # Decompose angle
    remaining = theta
    t = 0.0  # accumulated tangent (starts at tan(0) = 0)

    for k in range(n_iterations):
        if remaining > 0:
            remaining -= arctan_table[k]
            t = spb(t, 2**(-k))
        else:
            remaining += arctan_table[k]
            t = spb(t, -(2**(-k)))

    return t

def weierstrass_sin_cos(t):
    """
    From t = tan(θ/2), compute sin(θ) and cos(θ).
    sin(θ) = 2t/(1+t²), cos(θ) = (1-t²)/(1+t²)
    """
    t2 = t * t
    sin_val = 2 * t / (1 + t2)
    cos_val = (1 - t2) / (1 + t2)
    return sin_val, cos_val

def spb_cordic_sincos(theta, n_iterations=40):
    """Compute sin(θ) and cos(θ) via SPB-CORDIC + Weierstrass."""
    # Use half-angle: compute tan(θ/2) then apply Weierstrass
    t_half = spb_cordic_tan(theta / 2, n_iterations)
    return weierstrass_sin_cos(t_half)

def demo():
    print("=" * 70)
    print("SPB-CORDIC: Trigonometric Computation via Stereographic Projection")
    print("=" * 70)

    # Test tan computation
    print("\n  tan(θ) via SPB-CORDIC:")
    print(f"  {'θ':<12s} {'SPB-CORDIC':<18s} {'math.tan':<18s} {'rel error':<12s}")
    print(f"  {'─'*12} {'─'*18} {'─'*18} {'─'*12}")

    for theta in [0.1, 0.5, 1.0, math.pi/6, math.pi/4, math.pi/3, 1.5]:
        spb_val = spb_cordic_tan(theta)
        exact_val = math.tan(theta)
        rel_err = abs(spb_val - exact_val) / max(abs(exact_val), 1e-15)
        print(f"  {theta:<12.6f} {spb_val:<18.12f} {exact_val:<18.12f} {rel_err:<12.2e}")

    # Test sin/cos computation
    print(f"\n  sin(θ), cos(θ) via SPB-CORDIC + Weierstrass:")
    print(f"  {'θ':<10s} {'sin(SPB)':<14s} {'sin(exact)':<14s} {'cos(SPB)':<14s} {'cos(exact)':<14s} {'err':<10s}")
    print(f"  {'─'*10} {'─'*14} {'─'*14} {'─'*14} {'─'*14} {'─'*10}")

    for theta in [0.1, 0.5, 1.0, math.pi/6, math.pi/4, math.pi/3]:
        s_spb, c_spb = spb_cordic_sincos(theta)
        s_exact = math.sin(theta)
        c_exact = math.cos(theta)
        err = max(abs(s_spb - s_exact), abs(c_spb - c_exact))
        print(f"  {theta:<10.4f} {s_spb:<14.10f} {s_exact:<14.10f} {c_spb:<14.10f} {c_exact:<14.10f} {err:<10.2e}")

    # Convergence analysis
    print(f"\n  Convergence vs iterations:")
    print(f"  {'iters':<8s} {'tan(1) error':<16s} {'sin(π/4) error':<16s}")
    for n in [5, 10, 15, 20, 30, 40]:
        t_err = abs(spb_cordic_tan(1.0, n) - math.tan(1.0))
        s, c = spb_cordic_sincos(math.pi/4, n)
        s_err = abs(s - math.sin(math.pi/4))
        print(f"  {n:<8d} {t_err:<16.2e} {s_err:<16.2e}")

    # Operation count comparison
    print(f"\n  Operation count per function evaluation:")
    print(f"  {'Method':<20s} {'Adds':<8s} {'Mults':<8s} {'Divs':<8s} {'Shifts':<8s} {'Total':<8s}")
    print(f"  {'─'*20} {'─'*8} {'─'*8} {'─'*8} {'─'*8} {'─'*8}")
    n = 20
    print(f"  {'CORDIC':<20s} {n:<8d} {0:<8d} {0:<8d} {n:<8d} {2*n:<8d}")
    print(f"  {'SPB-CORDIC':<20s} {n:<8d} {n:<8d} {n:<8d} {0:<8d} {3*n:<8d}")
    print(f"  {'Taylor (20 terms)':<20s} {20:<8d} {20:<8d} {20:<8d} {0:<8d} {60:<8d}")

    print(f"\n  SPB-CORDIC trades shifts for multiplies — advantage on FPGAs")
    print(f"  where multiplication units are available but shift logic is limited.")

if __name__ == "__main__":
    demo()
