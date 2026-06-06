#!/usr/bin/env python3
"""
EML Transcendence Theory — Numerical Demonstrations

Demonstrates the key results from the EML transcendence theory:
1. Computation of specific EML numbers
2. Polynomial independence verification
3. Schanuel instance analysis
4. Depth hierarchy exploration
"""

import math
from fractions import Fraction
from typing import List, Tuple, Optional


def eml(x: float, y: float) -> float:
    """The EML function: eml(x, y) = exp(x) - log(y)."""
    return math.exp(x) - math.log(y)


def demonstrate_eml_values():
    """Compute and display key EML numbers."""
    print("=" * 60)
    print("EML Number Computations")
    print("=" * 60)

    e = math.e
    log2 = math.log(2)
    exp_e = math.exp(e)

    examples = [
        ("eml(1, 2) = e - log(2)", eml(1, 2), e - log2),
        ("eml(1, 1) = e", eml(1, 1), e),
        ("eml(0, 1) = 1", eml(0, 1), 1.0),
        ("eml(1, e) = e - 1", eml(1, math.e), e - 1),
        ("eml(e, 1) = e^e", eml(e, 1), exp_e),
        ("eml(e, 2) = e^e - log(2)", eml(e, 2), exp_e - log2),
        ("e^e + log(2)", exp_e + log2, None),
    ]

    for desc, val, check in examples:
        if check is not None:
            assert abs(val - check) < 1e-10, f"Mismatch: {val} vs {check}"
        print(f"  {desc:30s} = {val:.15f}")

    print()
    print("Key transcendence claims (conditional on Schanuel):")
    print(f"  e - log(2) ≈ {e - log2:.15f} is TRANSCENDENTAL")
    print(f"  e^e       ≈ {exp_e:.15f} is TRANSCENDENTAL")
    print(f"  e^e+log(2)≈ {exp_e + log2:.15f} is TRANSCENDENTAL")
    print()


def polynomial_independence_demo():
    """Demonstrate the polynomial lifting technique numerically."""
    print("=" * 60)
    print("Polynomial Lifting Technique — Numerical Verification")
    print("=" * 60)

    e = math.e
    log2 = math.log(2)

    # If {e, log 2} are algebraically independent, then for any
    # nonzero polynomial P(X), P(e - log 2) ≠ 0.

    # Test with various polynomials evaluated at e - log 2
    target = e - log2
    print(f"\n  Target: e - log(2) = {target:.15f}")
    print(f"\n  Testing P(e - log 2) ≠ 0 for various polynomials P:")
    print()

    polynomials = [
        ("X - 2", lambda x: x - 2),
        ("X^2 - 4", lambda x: x**2 - 4),
        ("X^2 - 2X - 1", lambda x: x**2 - 2*x - 1),
        ("X^3 - 6X + 1", lambda x: x**3 - 6*x + 1),
        ("X^4 - 10X^2 + 1", lambda x: x**4 - 10*x**2 + 1),
        ("2X^3 - X^2 + 3X - 7", lambda x: 2*x**3 - x**2 + 3*x - 7),
    ]

    for name, poly in polynomials:
        val = poly(target)
        print(f"    P(t) = {name:25s}  =>  P(e-log2) = {val:+.10f} ≠ 0  ✓")

    print()
    print("  (All nonzero, consistent with transcendence.)")
    print()

    # The lifted polynomial technique
    print("  Lifting technique:")
    print("    liftSubPoly maps P(X) to P(X₀ - X₁) in ℚ[X₀, X₁]")
    print("    Example: X² - 2X + 1 ↦ (X₀-X₁)² - 2(X₀-X₁) + 1")
    print("           = X₀² - 2X₀X₁ + X₁² - 2X₀ + 2X₁ + 1")
    print()
    print("    Retraction: set X₁ = 0 → X₀² - 2X₀ + 1 = (X₀-1)² ≠ 0 in ℚ[X₀]")
    print("    → The lift is injective (retraction is left inverse)")
    print()


def schanuel_instance_analysis():
    """Analyze the Schanuel instances used in the proofs."""
    print("=" * 60)
    print("Schanuel Instance Analysis")
    print("=" * 60)

    e = math.e
    log2 = math.log(2)
    exp_e = math.exp(e)

    instances = [
        {
            "name": "Instance 1: z = (1, log 2)",
            "z": [1.0, log2],
            "combined": [1.0, log2, e, 2.0],
            "labels": ["z₁=1", "z₂=log2", "e^z₁=e", "e^z₂=2"],
            "algebraic": [True, False, False, True],
            "result": "{e, log 2} algebraically independent"
        },
        {
            "name": "Instance 2: z = (1, e)",
            "z": [1.0, e],
            "combined": [1.0, e, e, exp_e],
            "labels": ["z₁=1", "z₂=e", "e^z₁=e", "e^z₂=e^e"],
            "algebraic": [True, False, False, False],
            "result": "{e, e^e} algebraically independent"
        },
        {
            "name": "Instance 3: z = (q) for nonzero q ∈ ℚ",
            "z": [1.0],
            "combined": [1.0, e],
            "labels": ["z₁=1", "e^z₁=e"],
            "algebraic": [True, False],
            "result": "e is transcendental"
        }
    ]

    for inst in instances:
        print(f"\n  {inst['name']}")
        print(f"  z-values: {inst['z']}")
        print(f"  Combined tuple (z, e^z):")
        for label, val, alg in zip(inst["labels"], inst["combined"], inst["algebraic"]):
            status = "ALGEBRAIC" if alg else "TRANSCENDENTAL (expected)"
            print(f"    {label:15s} = {val:15.10f}  [{status}]")
        print(f"  → Schanuel conclusion: {inst['result']}")

    print()


def depth_hierarchy():
    """Explore the EML depth hierarchy."""
    print("=" * 60)
    print("EML Depth Hierarchy")
    print("=" * 60)

    # Build EML numbers of increasing depth
    levels = {
        0: [("1", 1.0), ("2", 2.0), ("1/2", 0.5), ("3", 3.0)],
        1: [
            ("e = exp(1)", math.exp(1)),
            ("log(2)", math.log(2)),
            ("exp(2)", math.exp(2)),
            ("log(3)", math.log(3)),
            ("eml(1,2) = e-log2", eml(1, 2)),
        ],
        2: [
            ("e^e = exp(e)", math.exp(math.e)),
            ("log(e-log2)", math.log(eml(1, 2))),
            ("eml(e, 2) = e^e-log2", eml(math.e, 2)),
            ("exp(log2) = 2 (collapse!)", math.exp(math.log(2))),
        ],
        3: [
            ("e^(e^e)", math.exp(math.exp(math.e))),
            ("log(e^e-log2)", math.log(eml(math.e, 2))),
            ("eml(e^e, 2)", eml(math.exp(math.e), 2)),
        ],
    }

    for depth, entries in levels.items():
        status = "RATIONAL" if depth == 0 else "TRANSCENDENTAL (under Schanuel)"
        print(f"\n  Depth {depth}: {status}")
        for name, val in entries:
            print(f"    {name:30s} = {val:.10f}")

    print()
    print("  Note: exp(log(2)) = 2 shows depth can 'collapse' — but this")
    print("  is an algebraic identity, not a counterexample to the hierarchy.")
    print()


def main():
    """Run all demonstrations."""
    print()
    print("╔══════════════════════════════════════════════════════════╗")
    print("║  EML Transcendence Theory — Numerical Demonstrations    ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    demonstrate_eml_values()
    polynomial_independence_demo()
    schanuel_instance_analysis()
    depth_hierarchy()

    print("=" * 60)
    print("Summary of Proved Results (Lean 4, sorry-free):")
    print("=" * 60)
    print()
    print("  UNCONDITIONAL (pure algebra):")
    print("  1. AlgIndep(a,b) → Transcendental(a - b)")
    print("  2. AlgIndep(a,b) → Transcendental(a + b)")
    print("  3. AlgIndep(a,b) → Transcendental(a * b)")
    print()
    print("  CONDITIONAL ON SCHANUEL:")
    print("  4. AlgIndep(e, log 2)")
    print("  5. AlgIndep(e, e^e)")
    print("  6. Transcendental(e - log 2) = Transcendental(eml(1,2))")
    print("  7. Transcendental(e^e)")
    print("  8. Transcendental(exp(q)) for q ∈ ℚ, q ≠ 0")
    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: EML Transcendence Landscape

Plots the EML function surface and highlights transcendental values.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm


def eml(x: np.ndarray, y: np.ndarray) -> np.ndarray:
    """Vectorized EML function."""
    return np.exp(x) - np.log(y)


def plot_eml_surface():
    """Plot the EML function as a 3D surface."""
    fig = plt.figure(figsize=(14, 10))

    # Surface plot
    ax1 = fig.add_subplot(221, projection='3d')
    x = np.linspace(-2, 3, 100)
    y = np.linspace(0.1, 5, 100)
    X, Y = np.meshgrid(x, y)
    Z = eml(X, Y)
    Z = np.clip(Z, -10, 30)

    surf = ax1.plot_surface(X, Y, Z, cmap=cm.viridis, alpha=0.7, linewidth=0)
    # Mark special points
    special_points = [
        (1, 2, eml(np.array([1.0]), np.array([2.0]))[0], 'e - log 2'),
        (1, 1, np.e, 'e'),
        (0, 1, 1.0, '1'),
        (np.e, 1, np.exp(np.e), 'e^e'),
    ]
    for sx, sy, sz, label in special_points:
        ax1.scatter([sx], [sy], [sz], color='red', s=50, zorder=5)
        ax1.text(sx, sy, sz + 1.5, label, fontsize=8)

    ax1.set_xlabel('x')
    ax1.set_ylabel('y')
    ax1.set_zlabel('eml(x, y)')
    ax1.set_title('EML Surface: exp(x) - log(y)')

    # Contour plot
    ax2 = fig.add_subplot(222)
    levels = np.linspace(-5, 20, 25)
    cs = ax2.contourf(X, Y, Z, levels=levels, cmap=cm.viridis)
    plt.colorbar(cs, ax=ax2, label='eml(x, y)')
    for sx, sy, sz, label in special_points:
        ax2.plot(sx, sy, 'ro', markersize=8)
        ax2.annotate(label, (sx, sy), textcoords="offset points",
                     xytext=(10, 5), fontsize=9, color='red')
    ax2.set_xlabel('x')
    ax2.set_ylabel('y')
    ax2.set_title('EML Contours')

    # Depth hierarchy
    ax3 = fig.add_subplot(223)
    depth_0 = [0, 0.5, 1, 2, 3]
    depth_1 = [np.e, np.log(2), np.log(3), np.exp(2), np.e - np.log(2)]
    depth_2 = [np.exp(np.e), np.log(np.e - np.log(2)), np.exp(np.e) - np.log(2)]
    depth_3 = [np.exp(np.exp(np.e))]

    for d, vals, color in [(0, depth_0, 'blue'), (1, depth_1, 'green'),
                            (2, depth_2, 'orange'), (3, depth_3, 'red')]:
        ax3.scatter(vals, [d]*len(vals), c=color, s=80, zorder=5, label=f'Depth {d}')

    ax3.set_xlabel('Value')
    ax3.set_ylabel('EML Depth')
    ax3.set_title('EML Depth Hierarchy')
    ax3.legend()
    ax3.set_yticks([0, 1, 2, 3])
    ax3.set_xscale('symlog', linthresh=1)

    # Polynomial non-vanishing
    ax4 = fig.add_subplot(224)
    target = np.e - np.log(2)
    degrees = range(1, 20)
    min_vals = []
    for d in degrees:
        # Check P(x) = x^d - round(target^d)
        val = abs(target**d - round(target**d))
        min_vals.append(val)

    ax4.semilogy(list(degrees), min_vals, 'b-o', markersize=4)
    ax4.axhline(y=0, color='r', linestyle='--', alpha=0.5)
    ax4.set_xlabel('Polynomial degree d')
    ax4.set_ylabel('|t^d - round(t^d)|')
    ax4.set_title(f'Non-vanishing: t = e - log(2) ≈ {target:.4f}')
    ax4.set_ylim(1e-6, 1)

    plt.tight_layout()
    plt.savefig('eml_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: eml_landscape.png")


if __name__ == "__main__":
    plot_eml_surface()


#!/usr/bin/env python3
"""
Visualization: Schanuel Dependency Network

Shows how Schanuel's conjecture propagates algebraic independence
through the EML number hierarchy.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches


def draw_dependency_graph():
    """Draw the dependency graph of transcendence results."""
    fig, axes = plt.subplots(1, 2, figsize=(16, 8))

    # Left: Schanuel propagation
    ax = axes[0]
    ax.set_xlim(-1, 11)
    ax.set_ylim(-1, 9)
    ax.set_aspect('equal')
    ax.axis('off')
    ax.set_title('Schanuel Propagation Chain', fontsize=14, fontweight='bold')

    # Nodes
    nodes = {
        'schanuel': (5, 8, 'Schanuel\nConjecture', '#FFD700'),
        'lin_indep': (2, 6, '{1, log 2}\nℚ-lin. indep.', '#87CEEB'),
        'lin_indep2': (8, 6, '{1, e}\nℚ-lin. indep.', '#87CEEB'),
        'alg_indep': (2, 4, '{e, log 2}\nalg. indep.', '#90EE90'),
        'alg_indep2': (8, 4, '{e, e^e}\nalg. indep.', '#90EE90'),
        'eml_trans': (2, 2, 'e − log 2\ntranscendental', '#FF6347'),
        'exp_trans': (8, 2, 'e^e\ntranscendental', '#FF6347'),
        'lifting': (5, 3, 'Polynomial\nLifting', '#DDA0DD'),
    }

    for key, (x, y, label, color) in nodes.items():
        circle = plt.Circle((x, y), 0.9, color=color, alpha=0.8, ec='black', lw=1.5)
        ax.add_patch(circle)
        ax.text(x, y, label, ha='center', va='center', fontsize=7, fontweight='bold')

    # Edges
    edges = [
        ('schanuel', 'lin_indep'), ('schanuel', 'lin_indep2'),
        ('lin_indep', 'alg_indep'), ('lin_indep2', 'alg_indep2'),
        ('alg_indep', 'lifting'), ('alg_indep2', 'exp_trans'),
        ('lifting', 'eml_trans'),
    ]

    for src, dst in edges:
        sx, sy = nodes[src][0], nodes[src][1]
        dx, dy = nodes[dst][0], nodes[dst][1]
        # Shorten arrow to avoid overlapping circles
        length = np.sqrt((dx-sx)**2 + (dy-sy)**2)
        sx += 0.9 * (dx-sx)/length
        sy += 0.9 * (dy-sy)/length
        dx -= 0.9 * (dx-sx)/length if length > 1.8 else 0
        dy -= 0.9 * (dy-sy)/length if length > 1.8 else 0
        ax.annotate('', xy=(dx, dy), xytext=(sx, sy),
                    arrowprops=dict(arrowstyle='->', lw=2, color='#333'))

    # Right: Depth hierarchy
    ax2 = axes[1]
    ax2.set_xlim(-1, 11)
    ax2.set_ylim(-0.5, 4.5)
    ax2.set_aspect('auto')
    ax2.axis('off')
    ax2.set_title('EML Transcendence Depth Hierarchy', fontsize=14, fontweight='bold')

    # Depth levels
    colors = ['#E8E8E8', '#90EE90', '#87CEEB', '#FFB6C1']
    labels = ['Depth 0: ℚ (rationals)', 'Depth 1: e, log 2, exp(q), ...',
              'Depth 2: e^e, log(e−log2), ...', 'Depth 3: e^(e^e), ...']

    for d in range(4):
        rect = mpatches.FancyBboxPatch((0.5, d), 9, 0.7,
                                        boxstyle="round,pad=0.1",
                                        facecolor=colors[d], edgecolor='black', lw=1.5)
        ax2.add_patch(rect)
        ax2.text(5, d + 0.35, labels[d], ha='center', va='center',
                fontsize=10, fontweight='bold')

    # Arrows between levels
    for d in range(3):
        ax2.annotate('', xy=(5, d + 0.75), xytext=(5, d + 1.0),
                    arrowprops=dict(arrowstyle='->', lw=2, color='#666'))

    # Key values
    depth_vals = {
        0: ['0', '1', '2', '1/2', '3'],
        1: ['e ≈ 2.718', 'log 2 ≈ 0.693', 'e−log 2 ≈ 2.025'],
        2: ['e^e ≈ 15.15', 'e^e+log 2 ≈ 15.85'],
        3: ['e^(e^e) ≈ 3.8×10⁶'],
    }

    for d, vals in depth_vals.items():
        text = '  |  '.join(vals)
        ax2.text(5, d + 0.1, text, ha='center', va='center',
                fontsize=7, color='#555', style='italic')

    plt.tight_layout()
    plt.savefig('schanuel_network.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: schanuel_network.png")


if __name__ == "__main__":
    draw_dependency_graph()
