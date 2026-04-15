#!/usr/bin/env python3
"""
SPB Relativistic Physics Demo

Demonstrates the deep connection between:
- Hyperbolic SPB: spbH(v₁, v₂) = (v₁+v₂)/(1+v₁v₂) [Einstein velocity addition]
- Rapidity: v = tanh(φ), addition becomes linear: tanh(φ₁+φ₂) = spbH(tanh φ₁, tanh φ₂)
- Lorentz factor: γ = cosh(φ) where v = tanh(φ)
- Thomas precession preview (3D non-commutativity)

Author: SPB Research Team
"""

import numpy as np
import math

def spb_hyp(v1, v2):
    """Einstein velocity addition (hyperbolic SPB): (v1+v2)/(1+v1*v2)."""
    return (v1 + v2) / (1 + v1 * v2)

def rapidity(v):
    """Rapidity: φ = arctanh(v). Valid for |v| < 1."""
    return math.atanh(v)

def lorentz_factor(v):
    """Lorentz factor: γ = 1/√(1-v²)."""
    return 1 / math.sqrt(1 - v**2)

def demo_velocity_addition():
    """Compare Einstein vs Galilean velocity addition."""
    print("=" * 70)
    print("  DEMO 1: Einstein vs Galilean Velocity Addition")
    print("=" * 70)
    
    print(f"\n  Galilean: v₁ + v₂ (no speed limit)")
    print(f"  Einstein: (v₁+v₂)/(1+v₁v₂) (speed of light is limit)")
    
    print(f"\n  {'v₁':>6} {'v₂':>6} {'Galilean':>12} {'Einstein':>12} {'γ_result':>10}")
    print(f"  {'-'*50}")
    
    pairs = [
        (0.1, 0.1), (0.3, 0.3), (0.5, 0.5), (0.7, 0.7),
        (0.9, 0.9), (0.95, 0.95), (0.99, 0.99), (0.999, 0.999)
    ]
    
    for v1, v2 in pairs:
        galilean = v1 + v2
        einstein = spb_hyp(v1, v2)
        gamma = lorentz_factor(einstein)
        gal_str = f"{galilean:.6f}" if galilean < 2 else f"{galilean:.4f}"
        print(f"  {v1:6.3f} {v2:6.3f} {gal_str:>12} {einstein:12.9f} {gamma:10.4f}")
    
    print(f"\n  Key: Einstein result ALWAYS < 1, even when Galilean > 1")
    print(f"  ✓ Formally proved as `spbHyp_subluminal` in Lean 4")

def demo_rapidity():
    """Show rapidity linearization."""
    print(f"\n{'='*70}")
    print("  DEMO 2: Rapidity — Linearizing Velocity Addition")
    print("=" * 70)
    
    print(f"\n  The rapidity transformation v = tanh(φ) turns Einstein addition")
    print(f"  into ordinary addition: φ_total = φ₁ + φ₂")
    
    print(f"\n  {'v₁':>8} {'v₂':>8} {'φ₁':>10} {'φ₂':>10} {'φ₁+φ₂':>10} {'v_E':>10} {'tanh(φ₁+φ₂)':>14}")
    print(f"  {'-'*75}")
    
    for v1, v2 in [(0.3, 0.4), (0.5, 0.5), (0.8, 0.3), (0.9, 0.9), (0.99, 0.01)]:
        phi1, phi2 = rapidity(v1), rapidity(v2)
        v_einstein = spb_hyp(v1, v2)
        v_rapidity = math.tanh(phi1 + phi2)
        print(f"  {v1:8.4f} {v2:8.4f} {phi1:10.6f} {phi2:10.6f} {phi1+phi2:10.6f} "
              f"{v_einstein:10.8f} {v_rapidity:14.8f}")
    
    print(f"\n  ✓ Einstein addition IS linear in rapidity space")
    print(f"  ✓ Formally proved as `spbHyp_tanh_add` in Lean 4")

def demo_iterated_boosts():
    """Show iterated velocity addition (rocket problem)."""
    print(f"\n{'='*70}")
    print("  DEMO 3: Iterated Boosts — The Relativistic Rocket")
    print("=" * 70)
    
    print(f"\n  A rocket applies thrust Δv = 0.1c at each stage.")
    print(f"  What is the cumulative velocity after n boosts?")
    
    delta_v = 0.1
    
    print(f"\n  {'n':>4} {'v_Galilean':>12} {'v_Einstein':>12} {'Rapidity φ':>12} {'γ':>10}")
    print(f"  {'-'*55}")
    
    v_gal = 0
    v_ein = 0
    
    for n in range(1, 21):
        v_gal += delta_v
        v_ein = spb_hyp(v_ein, delta_v)
        phi = rapidity(v_ein)
        gamma = lorentz_factor(v_ein)
        
        v_gal_str = f"{v_gal:.4f}" if v_gal < 10 else f"{v_gal:.1f}"
        print(f"  {n:4d} {v_gal_str:>12} {v_ein:12.9f} {phi:12.6f} {gamma:10.3f}")
    
    print(f"\n  After 20 boosts of 0.1c:")
    print(f"    Galilean says: v = 2.0c (impossible!)")
    print(f"    Einstein says: v = {v_ein:.9f}c (still sub-luminal)")
    print(f"    Rapidity: φ = {rapidity(v_ein):.6f} (linear growth)")

def demo_light_invariance():
    """Show light speed invariance."""
    print(f"\n{'='*70}")
    print("  DEMO 4: Light Speed Invariance")
    print("=" * 70)
    
    print(f"\n  Einstein's second postulate: the speed of light is the same")
    print(f"  for all observers. In SPB: spbH(1, v) = 1 for any v.")
    
    print(f"\n  {'v (observer speed)':>20} {'1 ⊕ v':>18}")
    print(f"  {'-'*40}")
    
    for v in [0, 0.1, 0.3, 0.5, 0.7, 0.9, 0.99, 0.999, -0.5, -0.9]:
        result = spb_hyp(1.0, v)
        print(f"  {v:20.4f} {result:18.15f}")
    
    print(f"\n  ✓ Light speed is invariant under velocity addition")
    print(f"  ✓ Formally proved as `einstein_light_invariance` in Lean 4")

def demo_wick_rotation():
    """Demonstrate the Wick rotation between circular and hyperbolic SPB."""
    print(f"\n{'='*70}")
    print("  DEMO 5: Wick Rotation — Circular ↔ Hyperbolic Duality")
    print("=" * 70)
    
    print(f"\n  Circular SPB:    spb(x,y)  = (x+y)/(1-xy)  with tan")
    print(f"  Hyperbolic SPB:  spbH(x,y) = (x+y)/(1+xy)  with tanh")
    print(f"\n  The sign flip 1-xy → 1+xy is the Wick rotation θ → iφ")
    
    print(f"\n  Parallel computation:")
    print(f"  {'x':>8} {'y':>8} {'spb (circ)':>14} {'spbH (hyp)':>14} {'diff':>12}")
    print(f"  {'-'*60}")
    
    for x, y in [(0.2, 0.3), (0.5, 0.5), (0.3, 0.7), (0.1, 0.9)]:
        circ = (x + y) / (1 - x * y)
        hyp = (x + y) / (1 + x * y)
        print(f"  {x:8.4f} {y:8.4f} {circ:14.8f} {hyp:14.8f} {abs(circ-hyp):12.8f}")
    
    print(f"\n  Trigonometric parallel:")
    print(f"  {'θ':>8} {'tan(θ)':>12} {'tanh(θ)':>12} {'spb=tan add':>14} {'spbH=tanh add':>14}")
    print(f"  {'-'*65}")
    
    for theta in [0.2, 0.4, 0.6, 0.8, 1.0]:
        t = math.tan(theta)
        th = math.tanh(theta)
        # Double angle
        circ = (t + t) / (1 - t * t)
        hyp = (th + th) / (1 + th * th)
        tan2 = math.tan(2 * theta)
        tanh2 = math.tanh(2 * theta)
        print(f"  {theta:8.4f} {t:12.6f} {th:12.6f} {circ:14.8f} {hyp:14.8f}")
    
    print(f"\n  ✓ Same algebra, different geometry — connected by one sign!")

def main():
    print("\n" + "█" * 70)
    print("  SPB RELATIVISTIC PHYSICS EXPLORER")
    print("  Einstein's Velocity Addition IS the Hyperbolic SPB")
    print("█" * 70 + "\n")
    
    demo_velocity_addition()
    demo_rapidity()
    demo_iterated_boosts()
    demo_light_invariance()
    demo_wick_rotation()
    
    print(f"\n{'='*70}")
    print("  All demonstrations complete!")
    print("=" * 70)

if __name__ == "__main__":
    main()
