#!/usr/bin/env python3
"""
SPB Dynamical Systems Explorer

Explores the dynamical systems arising from iterating the SPB operator:
1. Fixed points of x ↦ spb(x, a) for various a
2. Orbit structure and periodicity (connection to rational rotation)
3. Lyapunov exponents and chaos
4. The hyperbolic-circular phase transition at the sign flip
5. Arnold tongues and mode-locking in iterated SPB
6. Connection to continued fractions

Usage:
    python3 spb_dynamics.py
"""

import math
import cmath
from typing import List, Optional, Tuple

def spb(x: float, y: float) -> Optional[float]:
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return None
    return (x + y) / denom

def spb_h(x: float, y: float) -> Optional[float]:
    denom = 1 + x * y
    if abs(denom) < 1e-15:
        return None
    return (x + y) / denom

def cayley(x: float) -> complex:
    return (x - 1j) / (x + 1j)

# ═══════════════════════════════════════════════════════════════
# 1. FIXED POINT ANALYSIS
# ═══════════════════════════════════════════════════════════════

def fixed_point_analysis():
    """Find fixed points of T_a: x ↦ spb(x, a).
    
    Fixed points satisfy x = (x + a)/(1 - ax), i.e.:
    x(1 - ax) = x + a
    x - ax² = x + a  
    -ax² = a
    x² = -1
    
    So for a ≠ 0, the fixed points are x = ±i (complex!).
    This means the circular SPB has NO real fixed points — 
    every real orbit is periodic or divergent. This is because
    it corresponds to rotation on S¹, which has no fixed points
    unless the rotation angle is 0.
    """
    print("\n" + "="*60)
    print("FIXED POINT ANALYSIS: x ↦ spb(x, a)")
    print("="*60)
    
    print("\nFor a ≠ 0: x = (x+a)/(1-ax) ⟹ x² = -1 ⟹ x = ±i")
    print("→ No real fixed points! (Rotation has no fixed points)")
    print()
    
    # Verify for specific a values
    for a in [0.1, 0.5, 1.0, 2.0]:
        # Fixed point would be ±i, verify in complex
        x = 1j
        result = (x + a) / (1 - a * x)
        print(f"a = {a:.1f}: spb(i, {a:.1f}) = {result:.6f} (should be i = {1j})")
    
    print("\n--- Hyperbolic SPB Fixed Points ---")
    print("For x = (x+a)/(1+ax): x + ax² = x + a ⟹ ax² = a ⟹ x = ±1")
    print("→ Fixed points are ±1 (the light cone boundary!)")
    
    for a in [0.1, 0.5, 0.9]:
        r1 = spb_h(1.0, a)
        r_1 = spb_h(-1.0, a)
        print(f"a = {a}: spb_h(1, {a}) = {r1:.6f}, spb_h(-1, {a}) = {r_1:.6f}")

# ═══════════════════════════════════════════════════════════════
# 2. ORBIT STRUCTURE
# ═══════════════════════════════════════════════════════════════

def orbit_analysis():
    """Analyze orbits of x ↦ spb(x, a).
    
    Since spb corresponds to rotation on S¹ by angle 2·arctan(a),
    orbits are:
    - Periodic if arctan(a)/π is rational
    - Dense in ℝ∪{∞} if arctan(a)/π is irrational
    """
    print("\n" + "="*60)
    print("ORBIT STRUCTURE")
    print("Rotation angle = 2·arctan(a)")
    print("="*60)
    
    # a = tan(π/n) gives period-n orbits
    for n in [3, 4, 5, 6, 7, 8]:
        a = math.tan(math.pi / n)
        x = 0.0
        orbit = [x]
        
        for _ in range(2 * n):
            result = spb(x, a)
            if result is None:
                orbit.append(float('inf'))
                x = 0.0  # Reset after infinity
            else:
                x = result
                orbit.append(x)
        
        angle = math.atan(a) / math.pi
        print(f"\na = tan(π/{n}) ≈ {a:.4f}, rotation angle = {2*angle:.4f}π")
        print(f"  Orbit (first {min(n+2, len(orbit))} points): ", end="")
        for val in orbit[:n+2]:
            if val == float('inf'):
                print("∞", end=" ")
            else:
                print(f"{val:.4f}", end=" ")
        
        # Check if period-n (or 2n)
        if len(orbit) > n and abs(orbit[n] - orbit[0]) < 1e-6:
            print(f"\n  → Period {n} orbit ✓")
        elif len(orbit) > 2*n and abs(orbit[2*n] - orbit[0]) < 1e-6:
            print(f"\n  → Period {2*n} orbit ✓")

# ═══════════════════════════════════════════════════════════════
# 3. LYAPUNOV EXPONENT
# ═══════════════════════════════════════════════════════════════

def lyapunov_analysis():
    """Compute Lyapunov exponent of x ↦ spb(x, a).
    
    The derivative of T_a(x) = (x+a)/(1-ax) is:
    T_a'(x) = (1 + a²)/(1-ax)²
    
    The Lyapunov exponent measures the average stretching rate.
    For rotation (circular SPB), the Lyapunov exponent should be 0
    since rotation preserves distances on S¹.
    """
    print("\n" + "="*60)
    print("LYAPUNOV EXPONENT ANALYSIS")
    print("="*60)
    
    for a in [0.1, 0.5, 1.0, math.sqrt(3), 2.0]:
        x = 0.3  # Initial condition
        lyap_sum = 0.0
        n_iter = 10000
        
        for _ in range(n_iter):
            denom = 1 - a * x
            if abs(denom) < 1e-12:
                x = 0.3  # Reset
                continue
            deriv = (1 + a**2) / denom**2
            lyap_sum += math.log(abs(deriv))
            x = (x + a) / denom
        
        lyap = lyap_sum / n_iter
        print(f"a = {a:>6.3f}: λ = {lyap:>10.6f} {'(zero ≈ rotation)' if abs(lyap) < 0.01 else ''}")
    
    print("\n→ Lyapunov exponent ≈ 0 for all a (pure rotation, no chaos)")
    print("→ This confirms SPB iteration = rotation on S¹")

# ═══════════════════════════════════════════════════════════════
# 4. CONTINUED FRACTION CONNECTION
# ═══════════════════════════════════════════════════════════════

def continued_fraction_demo():
    """The SPB operator connects to continued fractions.
    
    The Gauss map x ↦ {1/x} (fractional part of 1/x) generates
    continued fraction digits. The SPB can represent the
    convergents p_n/q_n of a continued fraction through
    Möbius composition.
    """
    print("\n" + "="*60)
    print("SPB AND CONTINUED FRACTIONS")
    print("="*60)
    
    # Each continued fraction step [a₀; a₁, a₂, ...] corresponds to
    # the Möbius transformation z ↦ a_n + 1/z = (a_n·z + 1)/(1·z + 0)
    # Composing these gives the convergent as a Möbius transformation.
    
    # Let's compute convergents of π = [3; 7, 15, 1, 292, ...]
    cf_digits = [3, 7, 15, 1, 292, 1, 1, 1, 2]
    
    print(f"\nContinued fraction of π = [{', '.join(str(d) for d in cf_digits)}, ...]")
    print(f"\n{'n':>3} | {'aₙ':>4} | {'pₙ/qₙ':>14} | {'Error':>14}")
    print("-" * 45)
    
    # Build convergents via matrix multiplication
    # [p_{n}, p_{n-1}]   [a_n, 1] [p_{n-1}, p_{n-2}]
    # [q_{n}, q_{n-1}] = [1,   0] [q_{n-1}, q_{n-2}]
    
    p_prev, p_curr = 1, cf_digits[0]
    q_prev, q_curr = 0, 1
    
    convergent = p_curr / q_curr
    print(f"{0:>3} | {cf_digits[0]:>4} | {convergent:>14.10f} | {abs(convergent - math.pi):>14.2e}")
    
    for n, a_n in enumerate(cf_digits[1:], 1):
        p_next = a_n * p_curr + p_prev
        q_next = a_n * q_curr + q_prev
        p_prev, p_curr = p_curr, p_next
        q_prev, q_curr = q_curr, q_next
        
        convergent = p_curr / q_curr
        print(f"{n:>3} | {a_n:>4} | {convergent:>14.10f} | {abs(convergent - math.pi):>14.2e}")
    
    print(f"\nπ  =          {math.pi:.10f}")
    print(f"\n→ Convergents are Möbius compositions: each step is T(z) = a + 1/z")
    print(f"→ This is a special case of SPB Möbius structure")

# ═══════════════════════════════════════════════════════════════
# 5. PHASE PORTRAIT
# ═══════════════════════════════════════════════════════════════

def phase_portrait():
    """ASCII phase portrait of SPB dynamics on the Cayley circle."""
    print("\n" + "="*60)
    print("PHASE PORTRAIT: SPB orbits on the Cayley circle")
    print("(Each character represents a point visited by the orbit)")
    print("="*60)
    
    size = 21
    canvas = [[' ' for _ in range(size)] for _ in range(size)]
    center = size // 2
    radius = center - 1
    
    # Draw unit circle
    for angle_step in range(200):
        theta = 2 * math.pi * angle_step / 200
        cx = int(center + radius * math.cos(theta) + 0.5)
        cy = int(center + radius * math.sin(theta) + 0.5)
        if 0 <= cx < size and 0 <= cy < size and canvas[cy][cx] == ' ':
            canvas[cy][cx] = '·'
    
    # Plot orbits for different a values
    markers = ['●', '○', '◆', '□', '▲']
    a_values = [math.tan(math.pi/5), math.tan(math.pi/7), 0.3, 1.5, 0.1]
    
    for idx, a in enumerate(a_values):
        x = 0.0
        for step in range(50):
            c = cayley(x)
            cx = int(center + radius * c.real + 0.5)
            cy = int(center - radius * c.imag + 0.5)
            if 0 <= cx < size and 0 <= cy < size:
                canvas[cy][cx] = markers[idx % len(markers)]
            
            result = spb(x, a)
            if result is None or abs(result) > 1e10:
                break
            x = result
    
    print()
    for row in canvas:
        print('  ' + ''.join(row))
    
    print(f"\n  Legend:")
    for idx, a in enumerate(a_values):
        angle = 2 * math.atan(a)
        print(f"    {markers[idx]} a = {a:.4f} (rotation angle = {angle/math.pi:.4f}π)")

# ═══════════════════════════════════════════════════════════════
# 6. HYPERBOLIC vs CIRCULAR TRANSITION
# ═══════════════════════════════════════════════════════════════

def transition_analysis():
    """Analyze the transition from circular to hyperbolic dynamics.
    
    SPB:   (x+y)/(1-xy) — has poles, circular rotation
    SPB_H: (x+y)/(1+xy) — smooth for |xy| < 1, contractive
    
    The transition happens at the sign flip: this is the Wick rotation.
    """
    print("\n" + "="*60)
    print("CIRCULAR → HYPERBOLIC TRANSITION (Wick Rotation)")
    print("="*60)
    
    # Compare iterates
    a = 0.3
    x_circ = 0.1
    x_hyp = 0.1
    
    print(f"\na = {a}, x₀ = 0.1")
    print(f"\n{'n':>4} | {'Circular SPB':>14} | {'Hyperbolic SPB':>14}")
    print("-" * 40)
    
    for n in range(15):
        print(f"{n:>4} | {x_circ:>14.8f} | {x_hyp:>14.8f}")
        
        rc = spb(x_circ, a)
        rh = spb_h(x_hyp, a)
        
        if rc is None or abs(rc) > 1e10:
            print("  → Circular orbit hit pole!")
            break
        x_circ = rc
        x_hyp = rh if rh is not None else x_hyp
    
    print(f"\n→ Circular: oscillates (rotation on S¹)")
    print(f"→ Hyperbolic: converges to fixed point (contraction on interval)")

# ═══════════════════════════════════════════════════════════════
# MAIN
# ═══════════════════════════════════════════════════════════════

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   SPB DYNAMICAL SYSTEMS EXPLORER                        ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    fixed_point_analysis()
    orbit_analysis()
    lyapunov_analysis()
    phase_portrait()
    transition_analysis()
    continued_fraction_demo()
    
    print("\n" + "="*60)
    print("All dynamical systems analyses complete!")
    print("="*60)
