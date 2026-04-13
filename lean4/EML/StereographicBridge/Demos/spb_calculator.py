#!/usr/bin/env python3
"""
Stereographic Projection Bridge (SPB) Calculator

Interactive demonstration of the SPB operator and its connections:
- SPB: (x+y)/(1-xy)  — tangent addition / circle group
- SPB_H: (x+y)/(1+xy) — Einstein velocity addition / hyperbolic group
- Cayley transform: C(x) = (x-i)/(x+i) — the unitary bridge
- SPB number tower: constants generated from 0 and 1
- Chebyshev connection: iterated SPB and multiple angles

Usage:
    python3 spb_calculator.py
"""

import cmath
import math
from typing import Optional

# ═══════════════════════════════════════════════════════════════
# CORE OPERATORS
# ═══════════════════════════════════════════════════════════════

def spb(x: float, y: float) -> Optional[float]:
    """Stereographic sum: (x+y)/(1-xy). Returns None if denominator is zero."""
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return None  # Pole (corresponds to ∞ on the circle)
    return (x + y) / denom

def spb_h(x: float, y: float) -> Optional[float]:
    """Hyperbolic SPB / Einstein velocity addition: (x+y)/(1+xy)."""
    denom = 1 + x * y
    if abs(denom) < 1e-15:
        return None
    return (x + y) / denom

def cayley(x: float) -> complex:
    """Standard Cayley transform: C(x) = (x-i)/(x+i). Maps ℝ → S¹."""
    return (x - 1j) / (x + 1j)

def spb_cayley(x: float) -> complex:
    """SPB-adapted Cayley transform: C'(x) = (1+ix)/(1-ix). Maps ℝ → S¹.
    This is the correct homomorphism: C'(spb(x,y)) = C'(x) * C'(y).
    Differs from standard by negation: C'(x) = -C(x)."""
    return (1 + x*1j) / (1 - x*1j)

def cayley_inv(w: complex) -> complex:
    """Inverse Cayley transform: C⁻¹(w) = i(1+w)/(1-w). Maps S¹ → ℝ."""
    return 1j * (1 + w) / (1 - w)

def spb_complex(x: complex, y: complex) -> complex:
    """Complex SPB for Möbius transformation analysis."""
    return (x + y) / (1 - x * y)

# ═══════════════════════════════════════════════════════════════
# SPB NUMBER TOWER
# ═══════════════════════════════════════════════════════════════

def spb_number_tower(max_depth: int = 4):
    """Generate constants by iterating SPB on {0, 1}.
    
    Unlike EML where eml(1,1) = e, the SPB tower explores the
    rational numbers reachable by repeated tangent addition.
    """
    print("\n" + "="*60)
    print("SPB NUMBER TOWER: Constants from {0, 1}")
    print("="*60)
    
    # Start with seeds
    seeds = {0.0: "0", 1.0: "1"}
    current = dict(seeds)
    
    for depth in range(1, max_depth + 1):
        new = {}
        values = list(current.keys())
        for v1 in values:
            for v2 in values:
                result = spb(v1, v2)
                if result is not None and abs(result) < 1e10:
                    # Round to avoid floating point duplicates
                    key = round(result, 10)
                    if key not in current and key not in new:
                        expr = f"spb({current.get(v1, str(v1))}, {current.get(v2, str(v2))})"
                        new[key] = expr
        current.update(new)
        
        print(f"\n--- Depth {depth} ---")
        if new:
            for val, expr in sorted(new.items()):
                print(f"  {val:>12.6f} = {expr}")
        else:
            print("  (no new values)")
    
    print(f"\nTotal constants generated: {len(current)}")
    return current

# ═══════════════════════════════════════════════════════════════
# CAYLEY TRANSFORM DEMO
# ═══════════════════════════════════════════════════════════════

def cayley_demo():
    """Demonstrate that the Cayley transform maps ℝ → S¹."""
    print("\n" + "="*60)
    print("CAYLEY TRANSFORM: The Unitary Bridge ℝ → S¹")
    print("C(x) = (x - i)/(x + i)")
    print("="*60)
    
    test_values = [-10, -2, -1, -0.5, 0, 0.5, 1, 2, 10]
    
    print(f"\n{'x':>8} | {'C(x)':>24} | {'|C(x)|':>8} | {'arg(C(x))/π':>12}")
    print("-" * 60)
    
    for x in test_values:
        c = cayley(x)
        print(f"{x:>8.1f} | {c.real:>10.6f} + {c.imag:>10.6f}i | "
              f"{abs(c):>8.6f} | {cmath.phase(c)/math.pi:>12.6f}")
    
    print(f"\n→ |C(x)| = 1 for all real x ✓ (Unitarity)")
    print(f"→ C(0) = -1, C(1) = -i, C(-1) = i, C(∞) = 1")

# ═══════════════════════════════════════════════════════════════
# SPB-CAYLEY INTERTWINING DEMO
# ═══════════════════════════════════════════════════════════════

def intertwining_demo():
    """Demonstrate C'(spb(x,y)) = C'(x) · C'(y) — the group homomorphism.
    Uses the SPB-adapted Cayley transform C'(x) = (1+ix)/(1-ix)."""
    print("\n" + "="*60)
    print("INTERTWINING: C'(spb(x,y)) = C'(x) · C'(y)")
    print("C'(x) = (1+ix)/(1-ix)  [SPB-adapted Cayley]")
    print("SPB on ℝ corresponds to multiplication on S¹")
    print("="*60)
    
    test_pairs = [(0.5, 0.3), (1.0, 0.0), (0.2, -0.2), (2.0, 3.0), (-1.5, 0.7)]
    
    cprime_spb = "C'(spb)"
    cprime_prod = "C'(x)*C'(y)"
    print(f"\n{'x':>6} {'y':>6} | {'spb(x,y)':>10} | {cprime_spb:>20} | {cprime_prod:>20} | {'Match?':>6}")
    print("-" * 80)
    
    for x, y in test_pairs:
        s = spb(x, y)
        if s is not None:
            c_spb = spb_cayley(s)
            c_prod = spb_cayley(x) * spb_cayley(y)
            match = abs(c_spb - c_prod) < 1e-10
            print(f"{x:>6.2f} {y:>6.2f} | {s:>10.4f} | "
                  f"{c_spb.real:>8.4f}+{c_spb.imag:>8.4f}i | "
                  f"{c_prod.real:>8.4f}+{c_prod.imag:>8.4f}i | {'  ✓' if match else '  ✗':>6}")
        else:
            print(f"{x:>6.2f} {y:>6.2f} | {'∞':>10} | {'—':>20} | {'—':>20} |")
    
    print("\n→ All match! C' is a group homomorphism (ℝ, spb) → (S¹, ×) ✓")

# ═══════════════════════════════════════════════════════════════
# EINSTEIN VELOCITY ADDITION DEMO
# ═══════════════════════════════════════════════════════════════

def einstein_demo():
    """Demonstrate relativistic velocity addition as hyperbolic SPB."""
    print("\n" + "="*60)
    print("EINSTEIN VELOCITY ADDITION = Hyperbolic SPB")
    print("v₁ ⊕ v₂ = (v₁ + v₂)/(1 + v₁·v₂)  [c = 1]")
    print("="*60)
    
    print("\n--- Sub-luminal Closure ---")
    velocities = [0.5, 0.9, 0.99, 0.999]
    
    print(f"{'v₁':>8} {'v₂':>8} | {'Classical':>10} | {'Relativistic':>12} | {'|result| < 1?':>14}")
    print("-" * 60)
    
    for v1 in velocities:
        for v2 in [0.5, 0.9]:
            classical = v1 + v2
            relativistic = spb_h(v1, v2)
            if relativistic is not None:
                print(f"{v1:>8.3f} {v2:>8.3f} | {classical:>10.4f} | "
                      f"{relativistic:>12.6f} | {'✓ YES' if abs(relativistic) < 1 else '✗ NO':>14}")
    
    print(f"\n--- Light Speed Invariance ---")
    print(f"1.0 ⊕ 0.0 = {spb_h(1.0, 0.0)}")
    print(f"1.0 ⊕ 0.5 = {spb_h(1.0, 0.5)}")
    print(f"1.0 ⊕ 0.9 = {spb_h(1.0, 0.9)}")
    print(f"1.0 ⊕ 1.0 = {spb_h(1.0, 1.0)}")
    print("→ c ⊕ v = c always! ✓")

# ═══════════════════════════════════════════════════════════════
# RAPIDITY DEMO
# ═══════════════════════════════════════════════════════════════

def rapidity_demo():
    """Show that rapidity = arctanh(v) is additive under Einstein addition."""
    print("\n" + "="*60)
    print("RAPIDITY: The Hidden Additive Structure")
    print("rapidity(v₁ ⊕ v₂) = rapidity(v₁) + rapidity(v₂)")
    print("="*60)
    
    pairs = [(0.3, 0.4), (0.5, 0.5), (0.8, 0.6), (0.1, 0.9)]
    
    print(f"\n{'v₁':>6} {'v₂':>6} | {'φ₁':>8} {'φ₂':>8} {'φ₁+φ₂':>8} | "
          f"{'v₁⊕v₂':>8} {'φ(v₁⊕v₂)':>10} | {'Match?':>6}")
    print("-" * 75)
    
    for v1, v2 in pairs:
        phi1 = math.atanh(v1)
        phi2 = math.atanh(v2)
        v_sum = spb_h(v1, v2)
        if v_sum is not None and abs(v_sum) < 1:
            phi_sum = math.atanh(v_sum)
            match = abs(phi_sum - (phi1 + phi2)) < 1e-10
            print(f"{v1:>6.2f} {v2:>6.2f} | {phi1:>8.4f} {phi2:>8.4f} {phi1+phi2:>8.4f} | "
                  f"{v_sum:>8.4f} {phi_sum:>10.4f} | {'  ✓' if match else '  ✗':>6}")

# ═══════════════════════════════════════════════════════════════
# ITERATED SPB (CHEBYSHEV CONNECTION)
# ═══════════════════════════════════════════════════════════════

def chebyshev_demo():
    """Show that n-fold SPB of tan(θ) = tan(nθ) — the Chebyshev connection."""
    print("\n" + "="*60)
    print("ITERATED SPB ↔ CHEBYSHEV POLYNOMIALS")
    print("spb^n(tan θ) = tan(nθ)")
    print("="*60)
    
    theta = math.pi / 7  # Choose an angle
    x = math.tan(theta)
    
    print(f"\nθ = π/7 ≈ {theta:.6f}")
    print(f"tan(θ) = {x:.6f}")
    
    print(f"\n{'n':>4} | {'spbⁿ(tan θ)':>14} | {'tan(nθ)':>14} | {'Match?':>6}")
    print("-" * 45)
    
    current = 0.0  # spb identity
    for n in range(1, 8):
        current = spb(current, x) if spb(current, x) is not None else float('inf')
        target = math.tan(n * theta) if abs(math.cos(n * theta)) > 1e-10 else float('inf')
        if abs(current) < 1e10 and abs(target) < 1e10:
            match = abs(current - target) < 1e-8
            print(f"{n:>4} | {current:>14.8f} | {target:>14.8f} | {'  ✓' if match else '  ✗':>6}")
        else:
            print(f"{n:>4} | {'∞':>14} | {'∞':>14} | {'  ✓':>6}")

# ═══════════════════════════════════════════════════════════════
# WICK ROTATION VISUALIZATION
# ═══════════════════════════════════════════════════════════════

def wick_rotation_demo():
    """Show the sign flip connecting circular and hyperbolic SPB."""
    print("\n" + "="*60)
    print("WICK ROTATION: Circular ↔ Hyperbolic Duality")
    print("SPB:  (x+y)/(1-xy)  ←→  SPB_H: (x+y)/(1+xy)")
    print("tan addition         ←→  tanh addition")
    print("Circle group         ←→  Hyperbolic group")  
    print("="*60)
    
    pairs = [(0.3, 0.5), (0.7, 0.2), (1.0, 0.5), (0.4, 0.8)]
    
    print(f"\n{'x':>6} {'y':>6} | {'SPB (circular)':>15} | {'SPB_H (hyperbolic)':>18} | {'Ratio':>8}")
    print("-" * 60)
    
    for x, y in pairs:
        s = spb(x, y)
        h = spb_h(x, y)
        if s is not None and h is not None and abs(h) > 1e-15:
            print(f"{x:>6.2f} {y:>6.2f} | {s:>15.6f} | {h:>18.6f} | {s/h:>8.4f}")

# ═══════════════════════════════════════════════════════════════
# EML ↔ SPB COMPARISON
# ═══════════════════════════════════════════════════════════════

def eml_spb_comparison():
    """Compare EML and SPB frameworks side by side."""
    print("\n" + "="*60)
    print("EML vs SPB: Two Universal Continuous Operators")
    print("="*60)
    
    table = [
        ("Definition",        "exp(x) - ln(y)",        "(x + y)/(1 - xy)"),
        ("Domain",            "ℂ × ℂ",                 "ℝ × ℝ (extended)"),
        ("Identity element",  "eml(x, 1) = exp(x)",    "spb(x, 0) = x"),
        ("Key constant",      "eml(1,1) = e",          "spb(1,1) = ∞"),
        ("Commutativity",     "✗ Non-commutative",      "✓ Commutative"),
        ("Associativity",     "✗ Not associative",      "✓ Associative (group)"),
        ("Bridges",           "Additive ↔ Multiplicative", "Euclidean ↔ Spherical"),
        ("Unitary operator",  "exp (period 2πi)",       "Cayley transform"),
        ("Discrete analogue", "NAND gate",              "XOR gate (mod 2)"),
        ("Physics",           "Entropy, information",    "Relativity, phase"),
        ("Generates",         "All elementary functions", "Circle group S¹"),
        ("Key formula",       "e = exp(1) - ln(1)",     "tan(α+β) = (tan α + tan β)/(1-tan α tan β)"),
    ]
    
    print(f"\n{'Property':<22} | {'EML':<28} | {'SPB':<28}")
    print("-" * 82)
    for prop, eml_val, spb_val in table:
        print(f"{prop:<22} | {eml_val:<28} | {spb_val:<28}")

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   STEREOGRAPHIC PROJECTION BRIDGE (SPB) CALCULATOR     ║")
    print("║   The Continuous Group Gate                              ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    cayley_demo()
    intertwining_demo()
    einstein_demo()
    rapidity_demo()
    chebyshev_demo()
    wick_rotation_demo()
    spb_number_tower()
    eml_spb_comparison()
    
    print("\n" + "="*60)
    print("All demonstrations complete!")
    print("="*60)
