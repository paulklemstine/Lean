#!/usr/bin/env python3
"""
Elliptic Curve Visualization over Finite Fields
================================================

Demonstrates:
1. Points on y² = x³ + 7 (secp256k1 equation) over small prime fields
2. The group law (point addition) with visual arrows
3. Why secp256k1 parameters are "nothing up my sleeve"

Usage: python demo_elliptic_curve.py
Outputs: elliptic_curve_visualization.png
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np
from typing import Optional, Tuple, List

# --- Elliptic curve arithmetic over F_p ---

def mod_inverse(a: int, p: int) -> int:
    """Extended Euclidean algorithm for modular inverse."""
    if a == 0:
        raise ValueError("No inverse for 0")
    g, x, _ = extended_gcd(a % p, p)
    if g != 1:
        raise ValueError(f"No inverse: gcd({a}, {p}) = {g}")
    return x % p

def extended_gcd(a: int, b: int) -> Tuple[int, int, int]:
    if a == 0:
        return b, 0, 1
    g, x, y = extended_gcd(b % a, a)
    return g, y - (b // a) * x, x

def ec_points(a: int, b: int, p: int) -> List[Tuple[int, int]]:
    """Find all points on y² = x³ + ax + b over F_p."""
    points = []
    for x in range(p):
        rhs = (x**3 + a*x + b) % p
        for y in range(p):
            if (y*y) % p == rhs:
                points.append((x, y))
    return points

def ec_add(P: Optional[Tuple[int,int]], Q: Optional[Tuple[int,int]], 
           a: int, p: int) -> Optional[Tuple[int,int]]:
    """Add two points on y² = x³ + ax + b over F_p. None = point at infinity."""
    if P is None: return Q
    if Q is None: return P
    x1, y1 = P
    x2, y2 = Q
    if x1 == x2 and y1 == (p - y2) % p:
        return None  # P + (-P) = O
    if x1 == x2 and y1 == y2:
        if y1 == 0:
            return None
        lam = (3 * x1**2 + a) * mod_inverse(2 * y1, p) % p
    else:
        lam = (y2 - y1) * mod_inverse(x2 - x1, p) % p
    x3 = (lam**2 - x1 - x2) % p
    y3 = (lam * (x1 - x3) - y1) % p
    return (x3, y3)

def ec_scalar_mul(k: int, P: Optional[Tuple[int,int]], a: int, p: int) -> Optional[Tuple[int,int]]:
    """Compute kP using double-and-add."""
    result = None
    addend = P
    while k > 0:
        if k & 1:
            result = ec_add(result, addend, a, p)
        addend = ec_add(addend, addend, a, p)
        k >>= 1
    return result

# --- Visualization ---

def plot_ec_finite_field():
    """Plot y² = x³ + 7 over several small prime fields."""
    fig, axes = plt.subplots(2, 3, figsize=(18, 12))
    fig.suptitle("Elliptic Curve y² = x³ + 7 over Finite Fields F_p\n(secp256k1 equation)", 
                 fontsize=16, fontweight='bold')
    
    primes = [11, 17, 23, 31, 43, 67]
    
    for idx, p in enumerate(primes):
        ax = axes[idx // 3][idx % 3]
        points = ec_points(0, 7, p)
        
        if points:
            xs, ys = zip(*points)
            # Color by whether point is a generator
            G = points[0]
            order = 1
            current = G
            generated = {G}
            while True:
                current = ec_add(current, G, 0, p)
                if current is None:
                    order += 1
                    break
                if current in generated:
                    break
                generated.add(current)
                order += 1
            
            colors = ['#e74c3c' if pt in generated else '#3498db' for pt in points]
            ax.scatter(xs, ys, c=colors, s=50, zorder=5, edgecolors='black', linewidth=0.5)
        
        ax.set_xlim(-1, p)
        ax.set_ylim(-1, p)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
        ax.set_title(f'F_{{{p}}} — {len(points)} points', fontsize=12)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        
        # Add Hasse bound annotation
        hasse_lo = p + 1 - int(2 * np.sqrt(p))
        hasse_hi = p + 1 + int(2 * np.sqrt(p))
        ax.text(0.02, 0.98, f'Hasse: [{hasse_lo}, {hasse_hi}]', 
                transform=ax.transAxes, fontsize=8, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.5))
    
    plt.tight_layout()
    plt.savefig('elliptic_curve_visualization.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✅ Saved: elliptic_curve_visualization.png")

def plot_group_law():
    """Visualize the group law: point addition on a real elliptic curve."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # Real curve y² = x³ + 7
    x = np.linspace(-1.913, 4, 1000)
    y_pos = np.sqrt(np.maximum(x**3 + 7, 0))
    y_neg = -y_pos
    
    ax = axes[0]
    ax.plot(x, y_pos, 'b-', linewidth=2, label='y² = x³ + 7')
    ax.plot(x, y_neg, 'b-', linewidth=2)
    ax.set_title('secp256k1: y² = x³ + 7 (over ℝ)', fontsize=14, fontweight='bold')
    ax.set_xlabel('x')
    ax.set_ylabel('y')
    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=0, color='gray', linewidth=0.5)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(-3, 5)
    ax.set_ylim(-12, 12)
    
    # Mark two points and their sum
    x1, y1 = -1.5, np.sqrt((-1.5)**3 + 7)
    x2, y2 = 1.0, np.sqrt(1.0**3 + 7)
    
    ax.plot(x1, y1, 'ro', markersize=10, zorder=5)
    ax.annotate('P', (x1, y1), textcoords="offset points", xytext=(10, 10), fontsize=12, fontweight='bold')
    ax.plot(x2, y2, 'go', markersize=10, zorder=5)
    ax.annotate('Q', (x2, y2), textcoords="offset points", xytext=(10, 10), fontsize=12, fontweight='bold')
    
    # Line through P and Q
    slope = (y2 - y1) / (x2 - x1)
    line_x = np.linspace(-3, 5, 100)
    line_y = y1 + slope * (line_x - x1)
    ax.plot(line_x, line_y, 'r--', alpha=0.5, linewidth=1)
    
    ax.legend(fontsize=11)
    
    # Parameter comparison
    ax2 = axes[1]
    ax2.axis('off')
    
    comparison_text = """
    Parameter Transparency Comparison
    ══════════════════════════════════════════
    
    secp256k1 (Bitcoin)          Dual_EC_DRBG (NSA)
    ─────────────────           ─────────────────
    a = 0  ✅ Simplest           P, Q: opaque 🔴
    b = 7  ✅ Smallest           relationship hidden
    p = 2²⁵⁶-2³²-977 ✅         between P and Q
       (efficient arithmetic)   
                                If designer knows e
    Single generator G ✅        such that P = eQ,
    derived deterministically    they can PREDICT
                                random outputs! 🔴
    
    No hidden relationships     Secret relationship
    No trapdoor possible ✅     = backdoor 🔴
    
    ══════════════════════════════════════════
    
    Verdict: secp256k1 is "nothing up my sleeve"
    Dual_EC_DRBG was compromised by design
    """
    
    ax2.text(0.05, 0.95, comparison_text, transform=ax2.transAxes,
             fontsize=11, verticalalignment='top', fontfamily='monospace',
             bbox=dict(boxstyle='round', facecolor='lightyellow', edgecolor='orange', alpha=0.8))
    ax2.set_title('Why secp256k1 Has No Backdoor', fontsize=14, fontweight='bold')
    
    plt.tight_layout()
    plt.savefig('group_law_and_security.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✅ Saved: group_law_and_security.png")

def plot_scalar_multiplication():
    """Visualize scalar multiplication on a small curve, showing the ECDLP difficulty."""
    p = 67
    a, b = 0, 7
    points = ec_points(a, b, p)
    
    if not points:
        print("No points found!")
        return
    
    G = points[0]
    
    # Compute all multiples of G
    multiples = []
    current = G
    for k in range(1, len(points) + 2):
        if current is None:
            break
        multiples.append((k, current))
        current = ec_add(current, G, a, p)
    
    fig, axes = plt.subplots(1, 2, figsize=(16, 7))
    
    # Plot 1: All multiples colored by k
    ax1 = axes[0]
    if multiples:
        ks, pts = zip(*multiples)
        xs, ys = zip(*pts)
        scatter = ax1.scatter(xs, ys, c=ks, cmap='viridis', s=60, zorder=5, 
                             edgecolors='black', linewidth=0.5)
        plt.colorbar(scatter, ax=ax1, label='Scalar k (in kG)')
    
    ax1.set_title(f'Scalar Multiples kG on E(F_{{{p}}})\ny² = x³ + 7', fontsize=12, fontweight='bold')
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.grid(True, alpha=0.3)
    
    # Draw arrows showing the "jumpy" nature
    for i in range(min(8, len(multiples)-1)):
        k1, p1 = multiples[i]
        k2, p2 = multiples[i+1]
        ax1.annotate('', xy=p2, xytext=p1,
                     arrowprops=dict(arrowstyle='->', color='red', alpha=0.3, lw=1))
    
    # Plot 2: The ECDLP difficulty - k vs x-coordinate
    ax2 = axes[1]
    if multiples:
        ks_list = [m[0] for m in multiples]
        xs_list = [m[1][0] for m in multiples]
        ax2.plot(ks_list, xs_list, 'b.-', markersize=4, linewidth=0.5, alpha=0.7)
    
    ax2.set_title('ECDLP Difficulty: x-coordinate of kG\n(appears random → hard to invert)', 
                  fontsize=12, fontweight='bold')
    ax2.set_xlabel('Scalar k (private key)')
    ax2.set_ylabel('x-coordinate of kG')
    ax2.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('scalar_multiplication_ecdlp.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✅ Saved: scalar_multiplication_ecdlp.png")

if __name__ == '__main__':
    print("=" * 60)
    print("Elliptic Curve Visualization Demo")
    print("Equation: y² = x³ + 7 (secp256k1)")
    print("=" * 60)
    
    print("\n📊 Plotting curves over finite fields...")
    plot_ec_finite_field()
    
    print("📊 Plotting group law and security comparison...")
    plot_group_law()
    
    print("📊 Plotting scalar multiplication (ECDLP difficulty)...")
    plot_scalar_multiplication()
    
    # Verify group properties on a small example
    print("\n🔬 Verifying group law on E(F_67): y² = x³ + 7")
    p = 67
    points = ec_points(0, 7, p)
    print(f"   Number of points: {len(points)} (+ point at infinity)")
    print(f"   Hasse bound: [{p+1 - int(2*p**0.5)}, {p+1 + int(2*p**0.5)}]")
    
    G = points[0]
    print(f"   Generator G = {G}")
    
    # Verify associativity on a sample
    P, Q, R = points[0], points[1], points[2]
    LHS = ec_add(ec_add(P, Q, 0, p), R, 0, p)
    RHS = ec_add(P, ec_add(Q, R, 0, p), 0, p)
    print(f"   Associativity check: (P+Q)+R = {LHS}, P+(Q+R) = {RHS}, equal: {LHS == RHS}")
    
    # Find group order
    order = 1
    current = G
    while current is not None:
        current = ec_add(current, G, 0, p)
        order += 1
    print(f"   Order of G: {order}")
    
    print("\n✅ All demos complete!")
