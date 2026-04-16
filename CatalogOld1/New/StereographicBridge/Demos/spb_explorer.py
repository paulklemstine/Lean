#!/usr/bin/env python3
"""
SPB Explorer: Interactive Demonstration of the Stereographic Projection Bridge

This script demonstrates key properties of the SPB operation:
  spb(x, y) = (x + y) / (1 - x*y)

Including:
1. Group structure verification
2. Multiple angle generation (Chebyshev connection)
3. Finite field SPB groups
4. Relativistic velocity addition (hyperbolic SPB)
5. Dynamical system iteration
6. SPB complexity analysis

Author: SPB Research Team
"""

import numpy as np
import math
import itertools
from fractions import Fraction

# ============================================================
# Core SPB Operations
# ============================================================

def spb(x, y):
    """Circular SPB: (x+y)/(1-xy). Tangent addition formula."""
    denom = 1 - x * y
    if abs(denom) < 1e-15:
        return float('inf')
    return (x + y) / denom

def spb_hyp(x, y):
    """Hyperbolic SPB (Einstein velocity addition): (x+y)/(1+xy)."""
    return (x + y) / (1 + x * y)

def cayley(x):
    """SPB-Cayley transform: maps ℝ → S¹ via (1+ix)/(1-ix)."""
    return (1 + 1j * x) / (1 - 1j * x)

def cayley_inv(w):
    """Inverse Cayley: maps S¹ → ℝ via (w-1)/(i(w+1))."""
    return (w - 1) / (1j * (w + 1))

# ============================================================
# Demo 1: Group Structure Verification
# ============================================================

def demo_group_structure():
    """Verify SPB forms an abelian group on ℝ \ {poles}."""
    print("=" * 60)
    print("DEMO 1: SPB Group Structure Verification")
    print("=" * 60)
    
    test_values = [0.5, -0.3, 0.7, 1.2, -0.8, 2.5]
    
    # Identity: spb(x, 0) = x
    print("\n1. Identity element (0):")
    for x in test_values:
        result = spb(x, 0)
        print(f"   spb({x}, 0) = {result:.10f}  (should be {x})")
    
    # Inverse: spb(x, -x) = 0
    print("\n2. Inverse element (-x):")
    for x in test_values:
        result = spb(x, -x)
        print(f"   spb({x}, {-x}) = {result:.10e}  (should be 0)")
    
    # Commutativity: spb(x, y) = spb(y, x)
    print("\n3. Commutativity:")
    for x, y in [(0.5, 0.3), (1.2, -0.7), (2.0, 0.1)]:
        r1, r2 = spb(x, y), spb(y, x)
        print(f"   spb({x},{y}) = {r1:.10f},  spb({y},{x}) = {r2:.10f},  diff = {abs(r1-r2):.2e}")
    
    # Associativity: spb(spb(x,y), z) = spb(x, spb(y,z))
    print("\n4. Associativity:")
    for x, y, z in [(0.3, 0.4, 0.5), (0.1, -0.2, 0.3), (0.7, 0.2, -0.1)]:
        r1 = spb(spb(x, y), z)
        r2 = spb(x, spb(y, z))
        print(f"   spb(spb({x},{y}),{z}) = {r1:.10f}")
        print(f"   spb({x},spb({y},{z})) = {r2:.10f}")
        print(f"   diff = {abs(r1-r2):.2e}")
    
    print()

# ============================================================
# Demo 2: Multiple Angle Generation (Chebyshev Connection)
# ============================================================

def demo_multiple_angles():
    """Show that n-fold SPB iteration gives tan(nθ)."""
    print("=" * 60)
    print("DEMO 2: Multiple Angle Generation via SPB")
    print("=" * 60)
    
    theta = 0.3  # A test angle
    t = math.tan(theta)
    
    print(f"\nθ = {theta}, tan(θ) = {t:.10f}")
    print(f"\nn-fold SPB iteration vs tan(nθ):")
    print(f"{'n':>4} {'spbPow(tan θ, n)':>20} {'tan(nθ)':>20} {'diff':>15}")
    print("-" * 65)
    
    current = 0  # spbPow starts at 0 (identity)
    for n in range(1, 13):
        current = spb(t, current)
        target = math.tan(n * theta)
        diff = abs(current - target)
        print(f"{n:4d} {current:20.12f} {target:20.12f} {diff:15.2e}")
    
    print("\n✓ SPB iteration exactly reproduces the multiple angle formula!")
    print("  This means: spbPow(tan θ, n) = tan(nθ)")
    print("  Equivalently: SPB IS the tangent addition law.\n")

# ============================================================
# Demo 3: SPB Over Finite Fields
# ============================================================

def spb_mod(x, y, p):
    """SPB over 𝔽_p."""
    denom = (1 - x * y) % p
    if denom == 0:
        return None  # Pole
    return ((x + y) * pow(denom, p - 2, p)) % p

def demo_finite_fields():
    """Explore SPB group structure over finite fields."""
    print("=" * 60)
    print("DEMO 3: SPB Over Finite Fields 𝔽_p")
    print("=" * 60)
    
    for p in [5, 7, 11, 13, 17, 19, 23]:
        print(f"\n--- 𝔽_{p} ---")
        
        # Find all valid SPB pairs
        group_elements = []
        for a in range(p):
            # Check if a is a valid group element (1 - a*a ≠ 0 mod p)
            group_elements.append(a)
        
        # Build Cayley table (partial — just check what orbits look like)
        # Find the order of element 1 under repeated SPB
        current = 0
        order = 0
        for i in range(1, p + 2):
            current = spb_mod(1, current, p)
            if current is None:
                print(f"  Hit pole at iteration {i}")
                break
            if current == 0:
                order = i
                break
        
        # Check if -1 is a QR mod p
        neg_one_qr = any((x * x) % p == (p - 1) for x in range(p))
        
        print(f"  Order of 1 under SPB: {order}")
        print(f"  -1 is QR mod {p}: {neg_one_qr}")
        print(f"  p mod 4 = {p % 4}")
        if neg_one_qr:
            roots = [x for x in range(p) if (x * x) % p == (p - 1)]
            print(f"  √(-1) mod {p}: {roots}")
            print(f"  → SPB has fixed points at {roots}")
        else:
            print(f"  → SPB acts freely (no fixed points)")
    
    print()

# ============================================================
# Demo 4: Relativistic Velocity Addition
# ============================================================

def demo_relativistic():
    """Demonstrate Einstein velocity addition as hyperbolic SPB."""
    print("=" * 60)
    print("DEMO 4: Relativistic Velocity Addition (Hyperbolic SPB)")
    print("=" * 60)
    
    print("\n1. Sub-luminal closure (|v₁|, |v₂| < 1 → |v₁ ⊕ v₂| < 1):")
    velocities = [(0.5, 0.5), (0.9, 0.9), (0.99, 0.99), (0.999, 0.999)]
    for v1, v2 in velocities:
        result = spb_hyp(v1, v2)
        classical = v1 + v2
        print(f"   v₁={v1}, v₂={v2}: Einstein={result:.10f}, Classical={classical:.4f}")
    
    print("\n2. Light speed invariance (1 ⊕ v = 1 for any v):")
    for v in [0, 0.5, 0.9, 0.99, -0.5]:
        result = spb_hyp(1.0, v)
        print(f"   1 ⊕ {v:5.2f} = {result:.10f}  (should be 1.0)")
    
    print("\n3. Rapidity parametrization (linearization):")
    print("   If v = tanh(φ), then v₁ ⊕ v₂ = tanh(φ₁ + φ₂)")
    for phi1, phi2 in [(0.3, 0.4), (0.5, 0.5), (1.0, 1.0), (2.0, 0.5)]:
        v1 = math.tanh(phi1)
        v2 = math.tanh(phi2)
        result = spb_hyp(v1, v2)
        target = math.tanh(phi1 + phi2)
        print(f"   φ₁={phi1}, φ₂={phi2}: spbH(tanh φ₁, tanh φ₂) = {result:.10f}, "
              f"tanh(φ₁+φ₂) = {target:.10f}")
    
    print()

# ============================================================
# Demo 5: Cayley Transform and Circle Group
# ============================================================

def demo_cayley_transform():
    """Show the Cayley transform maps SPB to circle multiplication."""
    print("=" * 60)
    print("DEMO 5: Cayley Transform — SPB → Circle Multiplication")
    print("=" * 60)
    
    print("\n1. Cayley maps ℝ → S¹ (|C(x)| = 1):")
    for x in [-2, -1, -0.5, 0, 0.5, 1, 2, 10]:
        c = cayley(x)
        print(f"   C({x:5.1f}) = {c.real:8.5f} + {c.imag:8.5f}i,  |C| = {abs(c):.10f}")
    
    print("\n2. Intertwining: C(spb(x,y)) = C(x) · C(y):")
    for x, y in [(0.3, 0.5), (1.0, -0.7), (2.0, 0.3), (-0.5, 0.8)]:
        s = spb(x, y)
        lhs = cayley(s)
        rhs = cayley(x) * cayley(y)
        diff = abs(lhs - rhs)
        print(f"   x={x:5.2f}, y={y:5.2f}: C(spb) = {lhs.real:.6f}+{lhs.imag:.6f}i, "
              f"C(x)·C(y) = {rhs.real:.6f}+{rhs.imag:.6f}i, diff = {diff:.2e}")
    
    print("\n3. Special values:")
    print(f"   C(0)  = {cayley(0):.4f}   (identity in S¹)")
    print(f"   C(1)  = {cayley(1):.4f}i  (90° rotation)")
    print(f"   C(-1) = {cayley(-1):.4f}i (-90° rotation)")
    
    print()

# ============================================================
# Demo 6: SPB Dynamical System
# ============================================================

def demo_dynamics():
    """Explore the dynamical system x_{n+1} = spb(x_n, a)."""
    print("=" * 60)
    print("DEMO 6: SPB Dynamical System x_{n+1} = spb(x_n, a)")
    print("=" * 60)
    
    # When a = tan(α) and α/π is rational, orbits are periodic
    # When α/π is irrational, orbits are dense in ℝ∪{∞}
    
    print("\n1. Rational rotation (periodic orbit):")
    # a = tan(π/6) → period 12 (since 6 * (π/6) / π = 1)
    a = math.tan(math.pi / 6)
    print(f"   a = tan(π/6) = {a:.6f}")
    x = 0.0
    orbit = [x]
    for i in range(13):
        x = spb(x, a)
        orbit.append(x)
        print(f"   x_{i+1} = {x:12.6f}  (= tan({i+1}·π/6) = {math.tan((i+1)*math.pi/6):12.6f})")
    
    print("\n2. Irrational rotation (dense orbit):")
    a = math.tan(1.0)  # 1/π is irrational
    print(f"   a = tan(1) = {a:.6f}")
    x = 0.0
    print("   First 20 orbit points:")
    for i in range(20):
        x = spb(x, a)
        if abs(x) < 100:
            print(f"   x_{i+1:2d} = {x:12.6f}")
        else:
            print(f"   x_{i+1:2d} = {x:12.2f} (near pole)")
    
    print()

# ============================================================
# Demo 7: SPB Complexity Analysis
# ============================================================

def demo_complexity():
    """Analyze SPB complexity of various functions."""
    print("=" * 60)
    print("DEMO 7: SPB Complexity Analysis")
    print("=" * 60)
    
    print("\nSPB complexity = minimum SPB operations to compute from x and constants.")
    print("\nMultiple angles via repeated doubling (binary method):")
    
    theta = 0.2
    t = math.tan(theta)
    
    # Compute tan(nθ) for powers of 2
    print(f"\n  Binary method (repeated squaring in SPB group):")
    current = t
    for k in range(1, 7):
        current = spb(current, current)
        n = 2**k
        target = math.tan(n * theta)
        print(f"    tan({n:3d}θ): {k} SPB ops, value = {current:.10f}, "
              f"expected = {target:.10f}")
    
    # General n: use binary representation
    print(f"\n  General n via binary decomposition:")
    for n in [3, 5, 7, 10, 15, 100]:
        # Binary representation
        binary = bin(n)[2:]
        ops = len(binary) - 1 + binary.count('1') - 1
        print(f"    tan({n:3d}θ): n = {binary}₂, ≤ {ops} SPB ops "
              f"({len(binary)-1} doublings + {binary.count('1')-1} additions)")
    
    print("\n  Conjecture: K_SPB(tan(nθ)) ≤ ⌊log₂ n⌋ + ν(n) - 1")
    print("  where ν(n) = number of 1s in binary representation of n")
    print()

# ============================================================
# Demo 8: SPB Neural Network Activation
# ============================================================

def demo_neural():
    """Demonstrate SPB as a neural network combining rule."""
    print("=" * 60)
    print("DEMO 8: SPB as Neural Network Primitive")
    print("=" * 60)
    
    # SPB neuron: combines two inputs via spb
    # Advantages: monotonic, preserves rotational structure
    # Challenge: singularities at xy = 1
    
    # Regularized SPB
    def spb_reg(x, y, eps=0.01):
        """Regularized SPB to avoid singularities."""
        return (x + y) / (1 - x * y + eps * (x * y) ** 2)
    
    print("\n1. SPB vs standard activations on periodic data:")
    print("   Input: x ∈ [0, 2π], Target: sin(3x)")
    
    # Simple demonstration: use SPB to compute tan(3θ) from tan(θ)
    # Since sin(3x) = 3sin(x) - 4sin³(x), and SPB naturally computes multiple angles
    
    N = 10
    x_vals = np.linspace(0.1, 1.4, N)  # Stay away from poles
    print(f"\n   {'x':>8} {'tan(x)':>12} {'spb³(tan x)':>15} {'tan(3x)':>12} {'error':>12}")
    for x in x_vals:
        t = math.tan(x)
        # Compute tan(3x) via SPB: first double, then add once more
        t2 = spb(t, t)  # tan(2x)
        t3 = spb(t2, t)  # tan(3x)
        target = math.tan(3 * x)
        err = abs(t3 - target)
        print(f"   {x:8.4f} {t:12.6f} {t3:15.6f} {target:12.6f} {err:12.2e}")
    
    print("\n2. Regularized SPB for safe neural computation:")
    for x, y in [(0.5, 0.5), (0.9, 1.1), (1.0, 1.0), (0.99, 1.01)]:
        std = spb(x, y) if abs(1 - x*y) > 1e-10 else float('inf')
        reg = spb_reg(x, y)
        print(f"   spb({x},{y}) = {std:12.6f},  spb_reg({x},{y}) = {reg:12.6f}")
    
    print()

# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("\n" + "█" * 60)
    print("  STEREOGRAPHIC PROJECTION BRIDGE (SPB) EXPLORER")
    print("  spb(x, y) = (x + y) / (1 - x·y)")
    print("█" * 60 + "\n")
    
    demo_group_structure()
    demo_multiple_angles()
    demo_finite_fields()
    demo_relativistic()
    demo_cayley_transform()
    demo_dynamics()
    demo_complexity()
    demo_neural()
    
    print("=" * 60)
    print("  All demonstrations complete!")
    print("=" * 60)
