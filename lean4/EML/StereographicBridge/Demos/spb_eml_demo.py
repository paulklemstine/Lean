#!/usr/bin/env python3
"""
SPB-EML Bridge: Interactive Python Demo
========================================

Demonstrates the conversion between the Stereographic Projection Bridge (SPB)
and the Exp-Minus-Log (EML) operator, with visualization of key identities.

SPB: spb(x, y) = (x + y) / (1 - x*y)     [geometric world]
EML: eml(x, y) = exp(x) - ln(y)           [arithmetic world]

The bridge identity:  ln(1 + spb(x,y)²) = ln(1+x²) + ln(1+y²) - 2·ln|1-xy|
"""

import numpy as np
try:
    import matplotlib.pyplot as plt
    from matplotlib.patches import FancyArrowPatch
    import matplotlib.gridspec as gridspec
    HAS_MATPLOTLIB = True
except ImportError:
    HAS_MATPLOTLIB = False


# ============================================================
# Core Operators
# ============================================================

def spb(x, y):
    """Stereographic Projection Bridge: (x+y)/(1-xy)"""
    denom = 1 - x * y
    if isinstance(denom, np.ndarray):
        result = np.where(np.abs(denom) < 1e-15, np.inf, (x + y) / denom)
    else:
        if abs(denom) < 1e-15:
            return float('inf')
        result = (x + y) / denom
    return result


def spbH(x, y):
    """Hyperbolic SPB (Einstein velocity addition): (x+y)/(1+xy)"""
    return (x + y) / (1 + x * y)


def eml(x, y):
    """Exp-Minus-Log operator: exp(x) - ln(y)"""
    return np.exp(x) - np.log(y)


def cayley(x):
    """Cayley transform: maps ℝ → S¹ via (1+ix)/(1-ix)"""
    return (1 + 1j * x) / (1 - 1j * x)


def cauchy_entropy(x):
    """H(x) = ln(1 + x²), the Cauchy entropy function"""
    return np.log(1 + x**2)


# ============================================================
# Demo 1: SPB as Tangent Addition
# ============================================================

def demo_tangent_addition():
    """Show that spb(tan α, tan β) = tan(α + β)"""
    print("=" * 60)
    print("DEMO 1: SPB is Tangent Addition")
    print("=" * 60)

    angles = [(np.pi/6, np.pi/4), (np.pi/3, np.pi/6),
              (0.1, 0.2), (0.5, 0.3), (1.0, 0.5)]

    print(f"{'α':>10} {'β':>10} {'tan(α+β)':>15} {'spb(tanα,tanβ)':>15} {'match':>8}")
    print("-" * 60)

    for alpha, beta in angles:
        direct = np.tan(alpha + beta)
        via_spb = spb(np.tan(alpha), np.tan(beta))
        match = np.isclose(direct, via_spb, rtol=1e-12)
        print(f"{alpha:10.4f} {beta:10.4f} {direct:15.8f} {via_spb:15.8f} {'✓' if match else '✗':>8}")

    print()


# ============================================================
# Demo 2: The Norm Identity (Bridge Core)
# ============================================================

def demo_norm_identity():
    """Verify: (1 + spb(x,y)²)(1-xy)² = (1+x²)(1+y²)"""
    print("=" * 60)
    print("DEMO 2: The Fundamental Norm Identity")
    print("=" * 60)
    print("  (1 + spb(x,y)²) · (1-xy)² = (1+x²) · (1+y²)")
    print()

    test_pairs = [(0.5, 0.3), (1.0, 2.0), (-0.7, 0.4),
                  (3.0, -1.5), (0.1, 0.9), (2.5, 0.8)]

    print(f"{'x':>8} {'y':>8} {'LHS':>18} {'RHS':>18} {'error':>12}")
    print("-" * 68)

    for x, y in test_pairs:
        s = spb(x, y)
        lhs = (1 + s**2) * (1 - x*y)**2
        rhs = (1 + x**2) * (1 + y**2)
        err = abs(lhs - rhs)
        print(f"{x:8.2f} {y:8.2f} {lhs:18.10f} {rhs:18.10f} {err:12.2e}")

    print()


# ============================================================
# Demo 3: Cauchy Entropy Additivity
# ============================================================

def demo_cauchy_entropy():
    """Verify: H(spb(x,y)) = H(x) + H(y) - 2·ln|1-xy|"""
    print("=" * 60)
    print("DEMO 3: Cauchy Entropy Additivity under SPB")
    print("=" * 60)
    print("  H(t) = ln(1 + t²)")
    print("  H(spb(x,y)) = H(x) + H(y) - 2·ln|1-xy|")
    print()

    test_pairs = [(0.5, 0.3), (1.0, 0.5), (-0.8, 0.6),
                  (2.0, -1.0), (0.3, 0.7)]

    print(f"{'x':>8} {'y':>8} {'H(spb)':>15} {'H(x)+H(y)-2ln':>15} {'error':>12}")
    print("-" * 62)

    for x, y in test_pairs:
        s = spb(x, y)
        lhs = cauchy_entropy(s)
        rhs = cauchy_entropy(x) + cauchy_entropy(y) - 2 * np.log(abs(1 - x*y))
        err = abs(lhs - rhs)
        print(f"{x:8.2f} {y:8.2f} {lhs:15.8f} {rhs:15.8f} {err:12.2e}")

    print()


# ============================================================
# Demo 4: SPB via exp/log (EML decomposition)
# ============================================================

def demo_spb_via_eml():
    """Show spb(x,y) = exp(log(x+y) - log(1-xy)) when signs allow"""
    print("=" * 60)
    print("DEMO 4: SPB Expressed via exp/log (EML Building Blocks)")
    print("=" * 60)
    print("  spb(x,y) = exp(ln(x+y) - ln(1-xy))")
    print("  = eml(ln(x+y) - ln(1-xy), 1)    [using eml(t,1) = exp(t)]")
    print()

    # Use pairs where x+y > 0 and 1-xy > 0
    test_pairs = [(0.5, 0.3), (0.1, 0.2), (0.4, 0.5),
                  (0.7, 0.1), (0.3, 0.6)]

    print(f"{'x':>8} {'y':>8} {'spb(x,y)':>15} {'exp(ln-ln)':>15} {'eml form':>15}")
    print("-" * 65)

    for x, y in test_pairs:
        direct = spb(x, y)
        via_exp_log = np.exp(np.log(x + y) - np.log(1 - x*y))
        via_eml = eml(np.log(x + y) - np.log(1 - x*y), 1)
        print(f"{x:8.2f} {y:8.2f} {direct:15.8f} {via_exp_log:15.8f} {via_eml:15.8f}")

    print()


# ============================================================
# Demo 5: exp∘arctan homomorphism
# ============================================================

def demo_exp_arctan_homomorphism():
    """Show exp(arctan(spb(x,y))) = exp(arctan(x)) · exp(arctan(y))"""
    print("=" * 60)
    print("DEMO 5: exp∘arctan is a Homomorphism (SPB → ×)")
    print("=" * 60)
    print("  exp(arctan(spb(x,y))) = exp(arctan(x)) · exp(arctan(y))")
    print("  [when xy < 1]")
    print()

    test_pairs = [(0.5, 0.3), (0.1, 0.8), (-0.3, 0.6),
                  (0.7, -0.2), (0.4, 0.4)]

    print(f"{'x':>8} {'y':>8} {'LHS':>18} {'RHS':>18} {'error':>12}")
    print("-" * 68)

    for x, y in test_pairs:
        s = spb(x, y)
        lhs = np.exp(np.arctan(s))
        rhs = np.exp(np.arctan(x)) * np.exp(np.arctan(y))
        err = abs(lhs - rhs)
        print(f"{x:8.2f} {y:8.2f} {lhs:18.10f} {rhs:18.10f} {err:12.2e}")

    print()


# ============================================================
# Demo 6: Cayley Transform Visualization
# ============================================================

def demo_cayley_spb():
    """Show that Cayley maps SPB to multiplication on S¹"""
    print("=" * 60)
    print("DEMO 6: Cayley Transform Maps SPB → S¹ Multiplication")
    print("=" * 60)
    print("  C(spb(x,y)) = C(x) · C(y)   where C(t) = (1+it)/(1-it)")
    print()

    test_pairs = [(0.5, 0.3), (1.0, -0.5), (2.0, 0.7),
                  (-1.0, 0.3), (0.4, 0.4)]

    print(f"{'x':>8} {'y':>8} {'C(spb(x,y))':>25} {'C(x)·C(y)':>25} {'|err|':>10}")
    print("-" * 80)

    for x, y in test_pairs:
        s = spb(x, y)
        lhs = cayley(s)
        rhs = cayley(x) * cayley(y)
        err = abs(lhs - rhs)
        print(f"{x:8.2f} {y:8.2f} {lhs.real:+8.4f}{lhs.imag:+8.4f}i   "
              f"{rhs.real:+8.4f}{rhs.imag:+8.4f}i   {err:10.2e}")

    print()


# ============================================================
# Demo 7: SPB Iteration (Building tan(nθ))
# ============================================================

def demo_spb_iteration():
    """Build tan(nθ) by repeated SPB"""
    print("=" * 60)
    print("DEMO 7: SPB Iteration — Building tan(nθ)")
    print("=" * 60)
    print("  Starting from t = tan(θ), iterate spb(result, t)")
    print()

    theta = np.pi / 7
    t = np.tan(theta)

    print(f"  θ = π/7 ≈ {theta:.6f}")
    print(f"  tan(θ) ≈ {t:.8f}")
    print()

    print(f"{'n':>4} {'tan(nθ) direct':>18} {'via SPB iter':>18} {'error':>12}")
    print("-" * 56)

    result = 0.0  # spb identity
    for n in range(1, 11):
        result = spb(result, t)
        direct = np.tan(n * theta)
        err = abs(result - direct)
        print(f"{n:4d} {direct:18.10f} {result:18.10f} {err:12.2e}")

    print()


# ============================================================
# Demo 8: EML Expression Tree Evaluation
# ============================================================

def demo_eml_trees():
    """Show how EML expression trees generate functions"""
    print("=" * 60)
    print("DEMO 8: EML Expression Trees")
    print("=" * 60)
    print()

    x = 2.0

    print(f"  x = {x}")
    print()
    print("  eml(x, 1)                = exp(x)           =", eml(x, 1))
    print("  exp(x)                                      =", np.exp(x))
    print()
    print("  eml(0, x)                = 1 - ln(x)        =", eml(0, x))
    print("  1 - ln(x)                                   =", 1 - np.log(x))
    print()

    # ln(x) = 1 - eml(0, x)
    ln_x = 1 - eml(0, x)
    print(f"  ln(x) = 1 - eml(0, x)                       = {ln_x:.8f}")
    print(f"  np.log(x)                                    = {np.log(x):.8f}")
    print()

    # Addition: x + y = ln(exp(x) · exp(y))
    y = 3.0
    # Using EML: eml(x,1) * eml(y,1) = exp(x) * exp(y) = exp(x+y)
    prod = eml(x, 1) * eml(y, 1)
    print(f"  x + y via exp/log: ln(eml(x,1)·eml(y,1))   = {np.log(prod):.8f}")
    print(f"  x + y direct                                = {x + y:.8f}")
    print()


# ============================================================
# Demo 9: Finite Field SPB
# ============================================================

def demo_finite_field_spb():
    """SPB over F_p: verify group orders"""
    print("=" * 60)
    print("DEMO 9: SPB Group over Finite Fields F_p")
    print("=" * 60)
    print("  Prediction: |SPB(F_p)| = p+1 if p≡3(mod 4), p-1 if p≡1(mod 4)")
    print()

    def spb_mod(x, y, p):
        denom = (1 - x * y) % p
        if denom == 0:
            return None
        num = (x + y) % p
        return (num * pow(denom, -1, p)) % p

    primes = [3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43]

    print(f"{'p':>4} {'p mod 4':>8} {'predicted':>10} {'actual':>8} {'match':>6}")
    print("-" * 40)

    for p in primes:
        # Find orbit of 1 under repeated SPB
        predicted = p + 1 if p % 4 == 3 else p - 1

        # Enumerate all elements reachable from the generator
        # Try to find all elements of the group
        elements = set()
        for a in range(p):
            for b in range(p):
                s = spb_mod(a, b, p)
                if s is not None:
                    elements.add(s)

        # Better: find order of generator 1
        x = 1
        order = 1
        current = x
        for _ in range(2 * p):
            current = spb_mod(current, x, p)
            if current is None:
                break
            order += 1
            if current == 0:  # back to identity
                break

        actual = order
        match = "✓" if actual == predicted else "?"
        print(f"{p:4d} {p % 4:8d} {predicted:10d} {actual:8d} {match:>6}")

    print()


# ============================================================
# Demo 10: SPB-EML Conversion Table
# ============================================================

def demo_conversion_table():
    """Complete conversion table between SPB and EML worlds"""
    print("=" * 60)
    print("DEMO 10: SPB ↔ EML Conversion Dictionary")
    print("=" * 60)
    print()
    print("  ┌──────────────────────────────────────────────────────┐")
    print("  │  GEOMETRIC (SPB)  ←→  ARITHMETIC (EML)              │")
    print("  ├──────────────────────────────────────────────────────┤")
    print("  │  spb(x,y)=(x+y)/(1-xy)  ↔  eml(x,y)=eˣ-ln(y)     │")
    print("  │  identity: 0             ↔  identity: eml(0,1)=1   │")
    print("  │  inverse: -x             ↔  inverse: via log/exp   │")
    print("  │  Cayley → S¹ mult        ↔  exp → ℝ₊ mult          │")
    print("  │  arctan (group log)      ↔  ln (ring log)          │")
    print("  │  1+x² (norm factor)      ↔  eˣ (scale factor)      │")
    print("  │  H(t)=ln(1+t²)          ↔  just ln (trivial)      │")
    print("  │  circular group          ↔  multiplicative group   │")
    print("  │  bounded output          ↔  unbounded output       │")
    print("  │  periodic (mod π)        ↔  monotone               │")
    print("  └──────────────────────────────────────────────────────┘")
    print()
    print("  Bridge Homomorphisms:")
    print("    exp ∘ arctan : (ℝ, spb) → (ℝ₊, ×)    [SPB → multiplication]")
    print("    arctan ∘ log : (ℝ₊, ×)  → (ℝ, spb)    [multiplication → SPB]")
    print("    exp          : (ℝ, +)   → (ℝ₊, ×)     [addition → multiplication]")
    print("    arctan       : (ℝ, spb) → (ℝ, +)      [SPB → addition]")
    print()
    print("  The Diamond:")
    print()
    print("              (ℝ, +)")
    print("             ↗       ↘")
    print("        arctan       exp")
    print("       ↗                 ↘")
    print("    (ℝ,spb) ——exp∘arctan——→ (ℝ₊,×)")
    print()


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     SPB-EML Bridge: The Arithmetic–Geometry Duality     ║")
    print("║                  Interactive Demos                       ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demo_tangent_addition()
    demo_norm_identity()
    demo_cauchy_entropy()
    demo_spb_via_eml()
    demo_exp_arctan_homomorphism()
    demo_cayley_spb()
    demo_spb_iteration()
    demo_eml_trees()
    demo_finite_field_spb()
    demo_conversion_table()

    print("All demos complete!")
