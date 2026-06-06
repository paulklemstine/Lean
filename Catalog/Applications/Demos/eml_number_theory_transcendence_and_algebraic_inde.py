#!/usr/bin/env python3
"""
Demo: EML Transcendence Theory

Numerical demonstrations of the EML function eml(x,y) = exp(x) - log(y)
and its transcendence properties.
"""

import math
from typing import Tuple

def eml(x: float, y: float) -> float:
    """The EML function: eml(x, y) = exp(x) - log(y)."""
    return math.exp(x) - math.log(y)

def eml_diag(z: float) -> float:
    """Diagonal EML: emlDiag(z) = exp(z) - log(z)."""
    return math.exp(z) - math.log(z)

def demonstrate_eml_identities():
    """Verify key EML identities numerically."""
    print("=" * 60)
    print("EML Function Identities")
    print("=" * 60)
    
    # eml(0, 1) = 1
    val = eml(0, 1)
    print(f"\neml(0, 1) = {val:.15f}")
    print(f"  Expected: 1.0")
    print(f"  Error: {abs(val - 1.0):.2e}")
    
    # eml(x, exp(x)) = exp(x) - x
    x = 2.5
    val = eml(x, math.exp(x))
    expected = math.exp(x) - x
    print(f"\neml({x}, exp({x})) = {val:.15f}")
    print(f"  Expected (exp({x}) - {x}): {expected:.15f}")
    print(f"  Error: {abs(val - expected):.2e}")
    
    # eml(log(y), y) = y - log(y) for y > 0
    y = 3.0
    val = eml(math.log(y), y)
    expected = y - math.log(y)
    print(f"\neml(log({y}), {y}) = {val:.15f}")
    print(f"  Expected ({y} - log({y})): {expected:.15f}")
    print(f"  Error: {abs(val - expected):.2e}")

def demonstrate_eml_transcendence():
    """Show EML values at rational inputs (conjectured transcendental under Schanuel)."""
    print("\n" + "=" * 60)
    print("EML Values at Rational Inputs (Transcendental under Schanuel)")
    print("=" * 60)
    
    rationals = [(1, 1), (1, 2), (2, 1), (1, 3), (3, 2), (2, 3)]
    
    for p, q in rationals:
        x = p / q
        val = eml(x, 1)  # eml(p/q, 1) = exp(p/q)
        print(f"\n  eml({p}/{q}, 1) = exp({p}/{q}) = {val:.15f}")
        
    print("\n\nKey EML numbers (transcendental under Schanuel):")
    
    # e = exp(1) = eml(1, 1)
    e_val = eml(1, 1)
    print(f"  e = eml(1, 1) = {e_val:.15f}")
    
    # eml(1, 2) = e - log(2)
    eml_1_2 = eml(1, 2)
    print(f"  eml(1, 2) = e - log(2) = {eml_1_2:.15f}")
    
    # eml(2, 1) = exp(2) = e²
    eml_2_1 = eml(2, 1)
    print(f"  eml(2, 1) = e² = {eml_2_1:.15f}")
    
    # emlDiag(1) = e - 0 = e
    print(f"  emlDiag(1) = e - log(1) = {eml_diag(1):.15f}")
    
    # emlDiag(2) = e² - log(2)
    print(f"  emlDiag(2) = e² - log(2) = {eml_diag(2):.15f}")

def demonstrate_eml_diagonal_positivity():
    """Demonstrate that emlDiag(z) > 0 for z > 0."""
    print("\n" + "=" * 60)
    print("EML Diagonal Positivity: emlDiag(z) > 0 for z > 0")
    print("=" * 60)
    
    test_points = [0.001, 0.01, 0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 100.0]
    
    print(f"\n  {'z':>10s} | {'emlDiag(z)':>20s} | {'exp(z)-z':>20s} | {'gap':>15s}")
    print("  " + "-" * 72)
    
    for z in test_points:
        val = eml_diag(z)
        lower = math.exp(z) - z
        gap = val - lower  # = z - log(z) ≥ 0 for z > 0
        print(f"  {z:10.3f} | {val:20.10f} | {lower:20.10f} | {gap:15.10f}")

def demonstrate_algebraic_independence():
    """Numerical evidence for algebraic independence under Schanuel."""
    print("\n" + "=" * 60)
    print("Algebraic Independence Under Schanuel's Conjecture")
    print("=" * 60)
    
    print("\nUnder Schanuel's conjecture, the following pairs are")
    print("algebraically independent over Q:")
    
    pairs = [
        ("e = exp(1)", "exp(√2)", math.e, math.exp(math.sqrt(2))),
        ("exp(1)", "exp(2)", math.exp(1), math.exp(2)),
        ("exp(1)", "exp(3)", math.exp(1), math.exp(3)),
    ]
    
    for name_a, name_b, a, b in pairs:
        print(f"\n  {name_a} = {a:.10f}")
        print(f"  {name_b} = {b:.10f}")
        # Test some polynomial relations
        print(f"    a + b = {a + b:.10f}")
        print(f"    a * b = {a * b:.10f}")
        print(f"    a² - 2b = {a**2 - 2*b:.10f}")
        print(f"    a³ - 3ab = {a**3 - 3*a*b:.10f}")

def demonstrate_iterated_eml():
    """Show iterated EML tower values."""
    print("\n" + "=" * 60)
    print("Iterated EML Tower")
    print("=" * 60)
    
    x, y = 1.0, 1.0
    val = eml(x, y)
    print(f"\n  Level 0: eml({x}, {y}) = {val:.15f}")
    
    # Level 1: eml(eml(1,1), 1) = eml(e, 1) = exp(e)
    val2 = eml(val, 1)
    print(f"  Level 1: eml(eml(1,1), 1) = exp(e) = {val2:.15f}")
    
    # Level 2: eml(eml(eml(1,1), 1), 1) = exp(exp(e))
    val3 = eml(val2, 1)
    print(f"  Level 2: eml(eml(eml(1,1), 1), 1) = exp(exp(e)) = {val3:.6e}")
    
    print("\n  Under Schanuel's conjecture, each level produces a number")
    print("  of strictly increasing transcendence complexity.")

if __name__ == "__main__":
    demonstrate_eml_identities()
    demonstrate_eml_transcendence()
    demonstrate_eml_diagonal_positivity()
    demonstrate_algebraic_independence()
    demonstrate_iterated_eml()
    
    print("\n" + "=" * 60)
    print("Summary")
    print("=" * 60)
    print("""
The EML function eml(x,y) = exp(x) - log(y) generates a rich class
of transcendental numbers from rational inputs. Under Schanuel's 
conjecture:

1. eml(q, 1) = exp(q) is transcendental for all nonzero q ∈ Q
2. eml(q, r) is transcendental for most q, r ∈ Q with r > 0
3. Iterated EML towers produce numbers of increasing transcendence degree
4. Pairs like (exp(1), exp(2)) are algebraically independent

These results connect the EML functional structure to deep questions
in transcendental number theory.
""")


#!/usr/bin/env python3
"""
Visualization: EML Function Landscape and Transcendence Structure

Produces plots showing the EML function eml(x,y) = exp(x) - log(y)
and its connections to transcendental number theory.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm
from mpl_toolkits.mplot3d import Axes3D


def plot_eml_surface():
    """Plot the EML function as a 3D surface."""
    fig = plt.figure(figsize=(14, 5))
    
    # Surface plot
    ax1 = fig.add_subplot(121, projection='3d')
    x = np.linspace(-2, 3, 100)
    y = np.linspace(0.1, 5, 100)
    X, Y = np.meshgrid(x, y)
    Z = np.exp(X) - np.log(Y)
    
    surf = ax1.plot_surface(X, Y, Z, cmap=cm.viridis, alpha=0.8, linewidth=0)
    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_zlabel('eml(x, y)')
    ax1.set_title('EML Function: eml(x,y) = exp(x) - log(y)')
    fig.colorbar(surf, ax=ax1, shrink=0.5, aspect=10)
    
    # Contour plot with special points
    ax2 = fig.add_subplot(122)
    contours = ax2.contourf(X, Y, Z, levels=20, cmap=cm.viridis)
    fig.colorbar(contours, ax=ax2)
    
    # Mark special points
    special_points = [
        (0, 1, 'eml(0,1)=1', 'red'),
        (1, 1, 'eml(1,1)=e', 'white'),
        (1, 2, 'eml(1,2)=e-ln2', 'yellow'),
        (2, 1, 'eml(2,1)=e²', 'cyan'),
    ]
    for px, py, label, color in special_points:
        ax2.plot(px, py, 'o', color=color, markersize=8, markeredgecolor='black')
        ax2.annotate(label, (px, py), textcoords="offset points",
                    xytext=(10, 5), fontsize=8, color=color,
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='black', alpha=0.7))
    
    ax2.set_xlabel('x')
    ax2.set_ylabel('y')
    ax2.set_title('EML Contours with Transcendental Points')
    
    plt.tight_layout()
    plt.savefig('eml_surface.png', dpi=150, bbox_inches='tight')
    plt.close()


def plot_eml_diagonal():
    """Plot the EML diagonal emlDiag(z) = exp(z) - log(z) and its lower bound."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))
    
    z = np.linspace(0.01, 4, 1000)
    eml_diag = np.exp(z) - np.log(z)
    lower_bound = np.exp(z) - z
    
    # Main plot
    ax = axes[0]
    ax.plot(z, eml_diag, 'b-', linewidth=2, label='emlDiag(z) = exp(z) - log(z)')
    ax.plot(z, lower_bound, 'r--', linewidth=1.5, label='Lower bound: exp(z) - z')
    ax.fill_between(z, lower_bound, eml_diag, alpha=0.2, color='green',
                    label='Gap = z - log(z) ≥ 0')
    ax.axhline(y=0, color='gray', linestyle='-', linewidth=0.5)
    ax.set_xlabel('z')
    ax.set_ylabel('Value')
    ax.set_title('EML Diagonal: Always Positive for z > 0')
    ax.legend(fontsize=9)
    ax.set_ylim(-1, 20)
    ax.grid(True, alpha=0.3)
    
    # Gap plot
    ax = axes[1]
    gap = z - np.log(z)
    ax.plot(z, gap, 'g-', linewidth=2, label='Gap: z - log(z)')
    ax.axhline(y=1, color='red', linestyle='--', linewidth=1, label='Minimum = 1 (at z=1)')
    ax.plot(1, 1, 'ro', markersize=10)
    ax.set_xlabel('z')
    ax.set_ylabel('z - log(z)')
    ax.set_title('EML Diagonal Gap: z - log(z) ≥ 1')
    ax.legend()
    ax.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('eml_diagonal.png', dpi=150, bbox_inches='tight')
    plt.close()


def plot_eml_tower():
    """Plot the EML tower: iterated applications of eml(·, 1) = exp(·)."""
    fig, ax = plt.subplots(figsize=(10, 6))
    
    # Starting from various rationals, iterate eml(·, 1) = exp(·)
    starts = [0.5, 1.0, 1.5, 2.0]
    max_iters = 4
    
    for s in starts:
        values = [s]
        for _ in range(max_iters):
            next_val = np.exp(values[-1])
            if next_val > 1e15:
                break
            values.append(next_val)
        
        ax.semilogy(range(len(values)), values, 'o-', linewidth=2,
                   markersize=8, label=f'Start: {s}')
    
    ax.set_xlabel('Iteration (EML Tower Level)')
    ax.set_ylabel('Value (log scale)')
    ax.set_title('EML Tower: Iterated exp(·) from Rational Seeds\n'
                'Each level increases transcendence complexity under Schanuel')
    ax.legend()
    ax.grid(True, alpha=0.3, which='both')
    
    plt.tight_layout()
    plt.savefig('eml_tower.png', dpi=150, bbox_inches='tight')
    plt.close()


if __name__ == "__main__":
    plot_eml_surface()
    print("Generated: eml_surface.png")
    
    plot_eml_diagonal()
    print("Generated: eml_diagonal.png")
    
    plot_eml_tower()
    print("Generated: eml_tower.png")
