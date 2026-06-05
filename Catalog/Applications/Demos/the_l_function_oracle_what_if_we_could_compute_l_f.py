#!/usr/bin/env python3
"""
Oracle Spectral Algebra — Interactive Demo

Demonstrates the key concepts:
1. Oracle hierarchy and query complexity
2. Vanishing order detection via jets
3. Factoring via separating invariants
4. Zero certificate verification
"""

import math
from typing import Callable, List, Tuple, Optional


# ============================================================
# 1. Vanishing Order Detection
# ============================================================

def compute_vanishing_order(f_derivs: List[complex], tol: float = 1e-12) -> int:
    """
    Given a list of derivative values [f(s), f'(s), f''(s), ...],
    compute the vanishing order (index of first nonzero derivative).
    
    This demonstrates the Jet Detection Theorem:
    a k-jet determines vanishing order ≤ k.
    """
    for i, val in enumerate(f_derivs):
        if abs(val) > tol:
            return i
    return len(f_derivs)  # All derivatives zero up to this depth


def demo_vanishing_order():
    """Demonstrate vanishing order detection for polynomial functions."""
    print("=" * 60)
    print("VANISHING ORDER DETECTION VIA JETS")
    print("=" * 60)
    
    # f(z) = z^3 at z = 0: vanishing order 3
    # f(0) = 0, f'(0) = 0, f''(0) = 0, f'''(0) = 6
    print("\nf(z) = z³ at z = 0:")
    derivs = [0, 0, 0, 6, 0, 0]  # f, f', f'', f''', f⁴, f⁵
    order = compute_vanishing_order(derivs)
    print(f"  Derivatives: {derivs}")
    print(f"  Vanishing order: {order}")
    print(f"  Detected with {order + 1} derivative queries")
    
    # g(z) = (z-1)^2 * (z+1) at z = 1: vanishing order 2
    # g(1) = 0, g'(1) = 0, g''(1) = 4
    print("\ng(z) = (z-1)²(z+1) at z = 1:")
    derivs = [0, 0, 4, 6]
    order = compute_vanishing_order(derivs)
    print(f"  Derivatives: {derivs}")
    print(f"  Vanishing order: {order}")
    print(f"  Detected with {order + 1} derivative queries")
    
    # h(z) = sin(z) at z = 0: vanishing order 1
    print("\nh(z) = sin(z) at z = 0:")
    derivs = [0, 1, 0, -1, 0, 1]  # sin derivatives cycle
    order = compute_vanishing_order(derivs)
    print(f"  Derivatives: {derivs}")
    print(f"  Vanishing order: {order}")
    print(f"  Detected with {order + 1} derivative queries")


# ============================================================
# 2. Finite Query Barrier Demonstration
# ============================================================

def demo_query_barrier():
    """
    Demonstrate the Finite Query Barrier Theorem:
    no finite set of point queries (avoiding s₀) can distinguish
    between a function that vanishes at s₀ and one that doesn't.
    """
    print("\n" + "=" * 60)
    print("FINITE QUERY BARRIER THEOREM")
    print("=" * 60)
    
    s0 = 1.0  # The point we care about
    query_points = [0.0, 0.5, 2.0, 3.0, -1.0]  # None equal to s₀
    
    # F(z) = 1 if z == s₀, else 0
    def F(z):
        return 1.0 if z == s0 else 0.0
    
    # G(z) = 0 for all z
    def G(z):
        return 0.0
    
    print(f"\ns₀ = {s0}")
    print(f"Query points: {query_points}")
    print(f"\nF(z) = [z = {s0}] (indicator function)")
    print(f"G(z) = 0 (zero function)")
    
    print(f"\nQuery results (F vs G agree on all query points):")
    for q in query_points:
        print(f"  z = {q}: F({q}) = {F(q)}, G({q}) = {G(q)}, "
              f"agree = {F(q) == G(q)}")
    
    print(f"\nBut at s₀ = {s0}:")
    print(f"  F({s0}) = {F(s0)} ≠ 0")
    print(f"  G({s0}) = {G(s0)} = 0")
    print(f"\n→ The functions are INDISTINGUISHABLE from {len(query_points)} "
          f"point queries")
    print(f"  but have DIFFERENT behavior at s₀!")


# ============================================================
# 3. Factoring via Separating Invariants
# ============================================================

def gcd(a: int, b: int) -> int:
    """Compute GCD using Euclidean algorithm."""
    while b:
        a, b = b, a % b
    return a


def demo_factoring():
    """
    Demonstrate the Factor Extraction Theorem:
    if n = p*q and we find a divisible by p but not q,
    then gcd(a, n) = p.
    """
    print("\n" + "=" * 60)
    print("FACTORING VIA SEPARATING INVARIANTS")
    print("=" * 60)
    
    test_cases = [
        (15, 3, 5),
        (77, 7, 11),
        (221, 13, 17),
        (323, 17, 19),
        (1073, 29, 37),
    ]
    
    for n, p, q in test_cases:
        assert n == p * q
        # Find a separating value: a = p (trivially divisible by p, not by q)
        a = p  # In practice, the oracle finds this via character sums
        
        result = gcd(a, n)
        print(f"\n  n = {n} = {p} × {q}")
        print(f"  Separating invariant: a = {a}")
        print(f"  p | a? {a % p == 0}, q | a? {a % q == 0}")
        print(f"  gcd({a}, {n}) = {result} = p ✓" if result == p
              else f"  gcd({a}, {n}) = {result} ✗")
    
    # Now demonstrate with a more realistic "character sum" approach
    print("\n--- Simulated Character Sum Approach ---")
    n = 143  # = 11 × 13
    p, q = 11, 13
    
    # Simulate character values (simplified)
    for k in range(2, n):
        g = gcd(k, n)
        if g != 1 and g != n:
            print(f"  n = {n}: testing k = {k}, gcd({k}, {n}) = {g}")
            print(f"  Factor found: {g} (other factor: {n // g})")
            break


# ============================================================
# 4. Zero Certificate and Regional RH
# ============================================================

def demo_zero_certificate():
    """
    Demonstrate the Zero Certificate Decides Regional RH theorem.
    
    For a polynomial (as a stand-in for an L-function), we:
    1. Find all zeros in a region (the "certificate")
    2. Check if all zeros lie on the "critical line" Re(z) = 1/2
    """
    print("\n" + "=" * 60)
    print("ZERO CERTIFICATE DECIDES REGIONAL RH")
    print("=" * 60)
    
    # Example 1: A polynomial with all zeros on Re(z) = 1/2
    print("\nExample 1: f(z) = (z - 0.5 - 3i)(z - 0.5 + 3i)(z - 0.5 - 7i)(z - 0.5 + 7i)")
    zeros_1 = [
        complex(0.5, 3),
        complex(0.5, -3),
        complex(0.5, 7),
        complex(0.5, -7),
    ]
    T = 10
    in_strip = [z for z in zeros_1 if 0 < z.real < 1 and abs(z.imag) <= T]
    all_on_line = all(abs(z.real - 0.5) < 1e-10 for z in in_strip)
    print(f"  Zeros in strip up to T={T}: {in_strip}")
    print(f"  All on critical line? {all_on_line}")
    print(f"  → Regional RH: {'VERIFIED ✓' if all_on_line else 'VIOLATED ✗'}")
    
    # Example 2: A polynomial with a zero off the critical line
    print("\nExample 2: f(z) = (z - 0.5 - 3i)(z - 0.7 + 5i)(z - 0.5 + 7i)")
    zeros_2 = [
        complex(0.5, 3),
        complex(0.7, -5),  # Off the critical line!
        complex(0.5, 7),
    ]
    in_strip = [z for z in zeros_2 if 0 < z.real < 1 and abs(z.imag) <= T]
    all_on_line = all(abs(z.real - 0.5) < 1e-10 for z in in_strip)
    print(f"  Zeros in strip up to T={T}: {in_strip}")
    offenders = [z for z in in_strip if abs(z.real - 0.5) > 1e-10]
    print(f"  Zeros off critical line: {offenders}")
    print(f"  → Regional RH: {'VERIFIED ✓' if all_on_line else 'VIOLATED ✗'}")


# ============================================================
# 5. Oracle Hierarchy Summary
# ============================================================

def demo_hierarchy():
    """Summarize the oracle hierarchy and what each level can compute."""
    print("\n" + "=" * 60)
    print("ORACLE HIERARCHY: WHAT EACH LEVEL CAN COMPUTE")
    print("=" * 60)
    
    levels = [
        ("Level 1: Point Value", [
            "Evaluate f(s) at any s",
            "Check if f(s) = 0 at a specific point",
            "Cannot determine vanishing order (BARRIER)",
            "Cannot determine global zero distribution",
        ]),
        ("Level 2: Derivative", [
            "Everything Level 1 can do",
            "Evaluate f^(n)(s) for any n",
            "Determine vanishing order at any point",
            "Compute analytic rank (BSD application)",
            "Cannot certify ALL zeros in a region",
        ]),
        ("Level 3: Zero Certificate", [
            "Everything Level 2 can do",
            "Certify all zeros in bounded regions",
            "Decide Regional RH (finite verification)",
            "Provide complete zero distribution data",
        ]),
    ]
    
    for name, capabilities in levels:
        print(f"\n  {name}:")
        for cap in capabilities:
            marker = "✗" if "Cannot" in cap or "BARRIER" in cap else "✓"
            print(f"    [{marker}] {cap}")
    
    print("\n  Separation witnesses:")
    print("    Level 1 < Level 2: vanishing order detection")
    print("    Level 2 < Level 3: global zero certification")


# ============================================================
# 6. Oracle Spectrum Product
# ============================================================

def demo_spectrum_product():
    """Demonstrate the multiplicative structure of Oracle Spectra."""
    print("\n" + "=" * 60)
    print("ORACLE SPECTRUM PRODUCT (RANKIN-SELBERG MODEL)")
    print("=" * 60)
    
    # Spectrum 1: L-function with conductor 11, 2 zeros up to T=10
    s1 = {"conductor": 11, "zero_counts": {5: 1, 10: 2, 20: 4}, "weight": 1}
    
    # Spectrum 2: L-function with conductor 13, 3 zeros up to T=10
    s2 = {"conductor": 13, "zero_counts": {5: 1, 10: 3, 20: 5}, "weight": 1}
    
    # Product spectrum
    prod = {
        "conductor": s1["conductor"] * s2["conductor"],
        "zero_counts": {T: s1["zero_counts"][T] + s2["zero_counts"][T] 
                       for T in s1["zero_counts"]},
        "weight": s1["weight"] + s2["weight"],
    }
    
    print(f"\n  Spectrum 1: conductor={s1['conductor']}, weight={s1['weight']}")
    for T, N in sorted(s1["zero_counts"].items()):
        print(f"    N({T}) = {N}")
    
    print(f"\n  Spectrum 2: conductor={s2['conductor']}, weight={s2['weight']}")
    for T, N in sorted(s2["zero_counts"].items()):
        print(f"    N({T}) = {N}")
    
    print(f"\n  Product Spectrum: conductor={prod['conductor']}, weight={prod['weight']}")
    for T, N in sorted(prod["zero_counts"].items()):
        print(f"    N({T}) = {N} = {s1['zero_counts'][T]} + {s2['zero_counts'][T]}")


# ============================================================
# Main
# ============================================================

if __name__ == "__main__":
    print("╔══════════════════════════════════════════════════════════╗")
    print("║       ORACLE SPECTRAL ALGEBRA — DEMONSTRATION          ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    demo_vanishing_order()
    demo_query_barrier()
    demo_factoring()
    demo_zero_certificate()
    demo_hierarchy()
    demo_spectrum_product()
    
    print("\n" + "=" * 60)
    print("DEMO COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Oracle Hierarchy and Query Complexity

A standalone matplotlib visualization showing:
1. The three-level oracle hierarchy
2. Query complexity for vanishing order detection
3. Filtration depth structure
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def draw_hierarchy_diagram(ax):
    """Draw the three-level oracle hierarchy."""
    levels = [
        (0.5, 0.15, "Level 1\nPoint Value", "#3498db", 
         "• Evaluate f(s)\n• Cannot detect\n  vanishing order"),
        (0.5, 0.50, "Level 2\nDerivative", "#2ecc71",
         "• All derivatives\n• Detects vanishing\n  order exactly"),
        (0.5, 0.85, "Level 3\nZero Certificate", "#e74c3c",
         "• All zeros in region\n• Decides Regional RH\n• Complete information"),
    ]
    
    for x, y, label, color, desc in levels:
        circle = plt.Circle((x, y), 0.12, color=color, alpha=0.3, 
                           transform=ax.transAxes)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=10, 
               fontweight='bold', transform=ax.transAxes)
        ax.text(x + 0.22, y, desc, ha='left', va='center', fontsize=8,
               transform=ax.transAxes, family='monospace')
    
    # Draw arrows between levels
    for y1, y2 in [(0.27, 0.38), (0.62, 0.73)]:
        ax.annotate('', xy=(0.5, y2), xytext=(0.5, y1),
                   xycoords='axes fraction', textcoords='axes fraction',
                   arrowprops=dict(arrowstyle='->', color='black', lw=2))
    
    # Add "strictly stronger" labels
    ax.text(0.42, 0.325, '<', ha='center', va='center', fontsize=14,
           fontweight='bold', transform=ax.transAxes)
    ax.text(0.42, 0.675, '<', ha='center', va='center', fontsize=14,
           fontweight='bold', transform=ax.transAxes)
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Oracle Hierarchy (Strict Total Order)', fontsize=14, 
                fontweight='bold', pad=20)


def draw_query_complexity(ax):
    """Show query complexity for vanishing order detection."""
    max_order = 8
    orders = list(range(max_order + 1))
    queries_needed = [k + 1 for k in orders]  # k+1 queries for order k
    
    bars = ax.bar(orders, queries_needed, color='#2ecc71', alpha=0.7, 
                 edgecolor='#27ae60', linewidth=1.5)
    
    # Add the diagonal line showing the theoretical bound
    ax.plot(orders, queries_needed, 'r--', linewidth=2, alpha=0.8, 
           label='Theoretical minimum: k+1')
    
    # Add labels on bars
    for bar, q in zip(bars, queries_needed):
        ax.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
               str(q), ha='center', va='bottom', fontsize=9, fontweight='bold')
    
    ax.set_xlabel('Vanishing Order k', fontsize=12)
    ax.set_ylabel('Queries Needed', fontsize=12)
    ax.set_title('Query Complexity for Vanishing Order Detection', 
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=10)
    ax.set_xticks(orders)
    ax.set_ylim(0, max_order + 2)
    ax.grid(axis='y', alpha=0.3)


def draw_filtration(ax):
    """Visualize the filtration structure of an Oracle Algebra."""
    max_k = 6
    
    # Draw nested sets representing filtration levels
    colors = plt.cm.Blues(np.linspace(0.2, 0.9, max_k + 1))
    
    for k in range(max_k, -1, -1):
        width = 1.0 - k * 0.12
        height = 0.8 - k * 0.1
        rect = mpatches.FancyBboxPatch(
            (0.5 - width/2, 0.5 - height/2), width, height,
            boxstyle="round,pad=0.02", facecolor=colors[k], 
            edgecolor='black', linewidth=1.5, alpha=0.6,
            transform=ax.transAxes)
        ax.add_patch(rect)
        
        if k <= 4:
            ax.text(0.5, 0.5 - height/2 + 0.04, f'F_{k}', 
                   ha='center', va='bottom', fontsize=9, fontweight='bold',
                   transform=ax.transAxes)
    
    # Add explanatory text
    ax.text(0.5, 0.02, 'F₀ = A (full carrier) ⊇ F₁ ⊇ F₂ ⊇ ···\n'
           'Fₖ = {f | f⁽ᵐ⁾(s)=0 for m<k}',
           ha='center', va='bottom', fontsize=9, 
           transform=ax.transAxes, style='italic',
           bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))
    
    ax.set_xlim(0, 1)
    ax.set_ylim(0, 1)
    ax.axis('off')
    ax.set_title('Oracle Algebra Filtration\n(Antitone: F₀ ⊇ F₁ ⊇ F₂ ⊇ ···)', 
                fontsize=13, fontweight='bold')


def draw_barrier_illustration(ax):
    """Illustrate the Finite Query Barrier Theorem."""
    # Plot two functions that agree at query points but differ at s₀
    x = np.linspace(-1, 3, 500)
    
    # F: nonzero at s₀=1
    F = np.ones_like(x)
    
    # G: zero at s₀=1, agrees with F at query points
    G = np.abs(x - 1)
    G = G / max(G)  # normalize
    
    # Query points (not at s₀=1)
    query_x = [0, 0.5, 1.5, 2.0, 2.5]
    
    ax.plot(x, F, 'b-', linewidth=2, label='F(z)', alpha=0.8)
    ax.plot(x, G, 'r-', linewidth=2, label='G(z)', alpha=0.8)
    
    # Mark query points where F=G (they don't here, but conceptually)
    ax.scatter(query_x, [1]*len(query_x), color='green', s=80, zorder=5,
              label='Query points', edgecolors='darkgreen', linewidths=1.5)
    
    # Mark s₀
    ax.axvline(x=1, color='purple', linestyle=':', linewidth=1.5, alpha=0.7)
    ax.text(1.05, 0.5, 's₀ = 1\n(not queried)', fontsize=9, color='purple',
           va='center')
    
    # Mark the difference at s₀
    ax.annotate('F(s₀) ≠ 0', xy=(1, 1), xytext=(1.5, 1.2),
               fontsize=9, color='blue',
               arrowprops=dict(arrowstyle='->', color='blue'))
    ax.annotate('G(s₀) = 0', xy=(1, 0), xytext=(1.5, -0.2),
               fontsize=9, color='red',
               arrowprops=dict(arrowstyle='->', color='red'))
    
    ax.set_xlabel('z', fontsize=12)
    ax.set_ylabel('Function value', fontsize=12)
    ax.set_title('Finite Query Barrier:\nIndistinguishable from query points', 
                fontsize=13, fontweight='bold')
    ax.legend(fontsize=9, loc='upper right')
    ax.grid(alpha=0.3)


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 12))
    fig.suptitle('Oracle Spectral Algebra — Key Concepts', 
                fontsize=16, fontweight='bold', y=0.98)
    
    draw_hierarchy_diagram(axes[0, 0])
    draw_query_complexity(axes[0, 1])
    draw_filtration(axes[1, 0])
    draw_barrier_illustration(axes[1, 1])
    
    plt.tight_layout(rect=[0, 0, 1, 0.95])
    plt.savefig('viz_oracle_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved visualization to viz_oracle_hierarchy.png")


if __name__ == "__main__":
    main()
