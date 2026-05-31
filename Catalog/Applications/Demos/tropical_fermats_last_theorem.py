#!/usr/bin/env python3
"""
Tropical Fermat Theory: Demonstrations and Numerical Examples

This script demonstrates the key results of the tropical Fermat theory:
1. Tropical Fermat equation solving
2. Degree independence
3. Tropical variety computation
4. Balancing condition verification
5. Kapranov theorem verification
"""

from algorithms import (
    tropical_add, tropical_mul, tropical_pow,
    is_tropical_fermat_solution, enumerate_fermat_solutions,
    fermat_poly, is_in_tropical_variety, classify_tropical_line_ray,
    compute_tropical_variety, check_balancing, fermat_rays,
    verify_degree_independence, TropMonomial, TropPoly
)


def demo_tropical_arithmetic():
    """Demonstrate basic tropical arithmetic."""
    print("=" * 60)
    print("DEMO 1: Tropical Arithmetic")
    print("=" * 60)
    print()
    print("In the tropical semiring (ℤ, min, +):")
    print(f"  3 ⊕ 5 = min(3, 5) = {tropical_add(3, 5)}")
    print(f"  3 ⊗ 5 = 3 + 5 = {tropical_mul(3, 5)}")
    print(f"  2 ⊗ 2 ⊗ 2 = 2^3 = 3·2 = {tropical_pow(2, 3)}")
    print(f"  (-1)^5 = 5·(-1) = {tropical_pow(-1, 5)}")
    print()
    print("Tropical Fermat equation x^n ⊕ y^n = z^n:")
    print(f"  x=3, y=5, n=2: min(6, 10) = {tropical_add(tropical_pow(3,2), tropical_pow(5,2))}")
    print(f"  z=3, z^2 = {tropical_pow(3, 2)}")
    print(f"  Solution? {is_tropical_fermat_solution(3, 5, 3, 2)}")
    print()


def demo_fermat_reduction():
    """Demonstrate the Fermat reduction theorem."""
    print("=" * 60)
    print("DEMO 2: Fermat Reduction Theorem")
    print("=" * 60)
    print()
    print("Theorem: x^n ⊕ y^n = z^n  ⟺  x ⊕ y = z  (for n ≥ 1)")
    print()
    
    test_cases = [(3, 5, 3), (2, 2, 2), (-1, 3, -1), (0, 0, 0), (7, -2, -2)]
    for x, y, z in test_cases:
        results = []
        for n in [1, 2, 3, 5, 10, 100]:
            results.append(is_tropical_fermat_solution(x, y, z, n))
        all_same = all(r == results[0] for r in results)
        print(f"  ({x}, {y}, {z}): n=1..100 all {'✓' if results[0] else '✗'} "
              f"(degree-independent: {all_same})")
    print()


def demo_solution_enumeration():
    """Enumerate and display tropical Fermat solutions."""
    print("=" * 60)
    print("DEMO 3: Tropical Fermat Solutions (bound=3)")
    print("=" * 60)
    print()
    
    solutions = enumerate_fermat_solutions(3, 1)
    print(f"Total solutions with |x|, |y|, |z| ≤ 3: {len(solutions)}")
    print()
    print("Sample solutions (first 15):")
    for x, y, z in solutions[:15]:
        print(f"  ({x:+d}, {y:+d}, {z:+d})  [min({x}, {y}) = {z}]")
    print(f"  ... ({len(solutions) - 15} more)")
    print()


def demo_tropical_variety():
    """Demonstrate tropical variety computation."""
    print("=" * 60)
    print("DEMO 4: Tropical Fermat Variety")
    print("=" * 60)
    print()
    
    bound = 5
    for n in [1, 2, 3, 5]:
        poly = fermat_poly(n)
        variety = compute_tropical_variety(poly, bound)
        print(f"Degree {n}: {len(variety)} points in variety (bound={bound})")
        
        # Classify by ray
        diagonal = sum(1 for x, y in variety if classify_tropical_line_ray(x, y) == "diagonal")
        xaxis = sum(1 for x, y in variety if classify_tropical_line_ray(x, y) == "x-axis")
        yaxis = sum(1 for x, y in variety if classify_tropical_line_ray(x, y) == "y-axis")
        print(f"  Diagonal ray: {diagonal}, x-axis ray: {xaxis}, y-axis ray: {yaxis}")
    print()


def demo_degree_independence():
    """Verify degree independence computationally."""
    print("=" * 60)
    print("DEMO 5: Degree Independence Verification")
    print("=" * 60)
    print()
    
    for bound in [5, 10, 20]:
        result = verify_degree_independence(max_degree=10, bound=bound)
        print(f"  Degrees 1-10, bound={bound}: {'IDENTICAL ✓' if result else 'DIFFER ✗'}")
    print()


def demo_balancing():
    """Verify the balancing condition."""
    print("=" * 60)
    print("DEMO 6: Tropical Balancing Condition")
    print("=" * 60)
    print()
    
    for n in [1, 2, 3, 5, 100]:
        rays = fermat_rays(n)
        balanced = check_balancing(rays)
        total_x = sum(w * d[0] for d, w in rays)
        total_y = sum(w * d[1] for d, w in rays)
        print(f"  Degree {n}: rays = {rays}")
        print(f"    Weighted sum = ({total_x}, {total_y}) -> {'Balanced ✓' if balanced else 'Unbalanced ✗'}")
    print()


def demo_kapranov():
    """Demonstrate the Kapranov-type theorem."""
    print("=" * 60)
    print("DEMO 7: Kapranov-Type Theorem Verification")
    print("=" * 60)
    print()
    
    bound = 8
    standard_line = set()
    for x in range(-bound, bound + 1):
        for y in range(-bound, bound + 1):
            if classify_tropical_line_ray(x, y) is not None:
                standard_line.add((x, y))
    
    print(f"Standard tropical line variety (bound={bound}): {len(standard_line)} points")
    
    for n in [1, 2, 3, 5, 10]:
        variety_n = compute_tropical_variety(fermat_poly(n), bound)
        match = variety_n == standard_line
        print(f"  Degree {n} Fermat variety: {len(variety_n)} points -> "
              f"{'MATCHES ✓' if match else 'DIFFERS ✗'}")
    print()


def demo_ascii_visualization():
    """ASCII visualization of the tropical line."""
    print("=" * 60)
    print("DEMO 8: ASCII Visualization of Tropical Fermat Curve")
    print("=" * 60)
    print()
    
    bound = 8
    variety = compute_tropical_variety(fermat_poly(1), bound)
    
    print(f"  Tropical Fermat curve (any degree n ≥ 1)")
    print(f"  x ∈ [-{bound}, {bound}], y ∈ [-{bound}, {bound}]")
    print()
    
    for y in range(bound, -bound - 1, -1):
        row = "  "
        for x in range(-bound, bound + 1):
            if (x, y) in variety:
                ray = classify_tropical_line_ray(x, y)
                if x == 0 and y == 0:
                    row += "●"  # Origin vertex
                elif ray == "diagonal":
                    row += "╲"
                elif ray == "x-axis":
                    row += "─"
                elif ray == "y-axis":
                    row += "│"
                else:
                    row += "·"
            else:
                row += " "
        print(row)
    print()
    print("  Legend: ● = vertex, ─ = x-axis ray, │ = y-axis ray, ╲ = diagonal ray")
    print()


if __name__ == "__main__":
    demo_tropical_arithmetic()
    demo_fermat_reduction()
    demo_solution_enumeration()
    demo_tropical_variety()
    demo_degree_independence()
    demo_balancing()
    demo_kapranov()
    demo_ascii_visualization()
    
    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization of the Tropical Fermat Curve and Variety

Creates matplotlib plots showing:
1. The tropical line / Fermat curve (three rays)
2. The tropical variety with ray classification
3. Degree independence comparison
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def tropical_line_variety(bound):
    """Compute points on the standard tropical line variety."""
    diagonal = [(t, t) for t in range(-bound, 1)]
    x_axis = [(t, 0) for t in range(0, bound + 1)]
    y_axis = [(0, t) for t in range(0, bound + 1)]
    return diagonal, x_axis, y_axis


def fermat_variety(n, bound):
    """Compute points in the tropical Fermat variety of degree n."""
    points = set()
    for x in range(-bound, bound + 1):
        for y in range(-bound, bound + 1):
            vals = [n * x, n * y, 0]
            m = min(vals)
            if sum(1 for v in vals if v == m) >= 2:
                points.add((x, y))
    return points


def plot_tropical_fermat_curve():
    """Plot the tropical Fermat curve (standard tropical line)."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))
    
    bound = 6
    diagonal, x_axis, y_axis = tropical_line_variety(bound)
    
    # Plot rays with thick lines
    dx, dy = zip(*diagonal)
    ax.plot(dx, dy, 'b-', linewidth=3, label='Diagonal ray: x = y ≤ 0')
    
    xx, xy = zip(*x_axis)
    ax.plot(xx, xy, 'r-', linewidth=3, label='x-axis ray: y = 0, x ≥ 0')
    
    yx, yy = zip(*y_axis)
    ax.plot(yx, yy, 'g-', linewidth=3, label='y-axis ray: x = 0, y ≥ 0')
    
    # Mark the vertex
    ax.plot(0, 0, 'ko', markersize=12, zorder=5)
    ax.annotate('Vertex (0,0)', (0, 0), textcoords="offset points",
                xytext=(15, -15), fontsize=12, fontweight='bold')
    
    # Add direction arrows
    ax.annotate('', xy=(-5.5, -5.5), xytext=(-4, -4),
                arrowprops=dict(arrowstyle='->', color='blue', lw=2))
    ax.annotate('', xy=(5.5, 0), xytext=(4, 0),
                arrowprops=dict(arrowstyle='->', color='red', lw=2))
    ax.annotate('', xy=(0, 5.5), xytext=(0, 4),
                arrowprops=dict(arrowstyle='->', color='green', lw=2))
    
    ax.set_xlim(-7, 7)
    ax.set_ylim(-7, 7)
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.3)
    ax.axhline(y=0, color='k', linewidth=0.5)
    ax.axvline(x=0, color='k', linewidth=0.5)
    ax.set_xlabel('x', fontsize=14)
    ax.set_ylabel('y', fontsize=14)
    ax.set_title('Tropical Fermat Curve\n(Same for all degrees n ≥ 1)', fontsize=16)
    ax.legend(loc='upper right', fontsize=11)
    
    plt.tight_layout()
    plt.savefig('tropical_fermat_curve.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: tropical_fermat_curve.png")


def plot_degree_independence():
    """Plot showing degree independence of tropical Fermat varieties."""
    fig, axes = plt.subplots(1, 4, figsize=(20, 5))
    
    bound = 6
    degrees = [1, 2, 3, 5]
    
    for ax, n in zip(axes, degrees):
        variety = fermat_variety(n, bound)
        
        # Classify points
        for x, y in variety:
            if x == y and x <= 0:
                color = 'blue'
            elif x == 0 and y >= 0:
                color = 'green'
            elif y == 0 and x >= 0:
                color = 'red'
            else:
                color = 'purple'
            ax.plot(x, y, 'o', color=color, markersize=6)
        
        ax.set_xlim(-bound - 1, bound + 1)
        ax.set_ylim(-bound - 1, bound + 1)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        ax.axhline(y=0, color='k', linewidth=0.5)
        ax.axvline(x=0, color='k', linewidth=0.5)
        ax.set_title(f'Degree n = {n}\n({len(variety)} points)', fontsize=13)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
    
    fig.suptitle('Tropical Fermat Variety: Degree Independence\n'
                 '(All varieties are identical — the standard tropical line)',
                 fontsize=15, y=1.02)
    
    plt.tight_layout()
    plt.savefig('degree_independence.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: degree_independence.png")


def plot_balancing_condition():
    """Visualize the balancing condition at the vertex."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    for idx, n in enumerate([1, 3, 5]):
        ax = axes[idx]
        
        # Draw the three weighted direction vectors
        directions = [(-1, -1), (1, 0), (0, 1)]
        colors = ['blue', 'red', 'green']
        labels = [f'{n}·(-1,-1)', f'{n}·(1,0)', f'{n}·(0,1)']
        
        for (dx, dy), color, label in zip(directions, colors, labels):
            ax.arrow(0, 0, n * dx * 0.8, n * dy * 0.8,
                     head_width=0.15, head_length=0.1,
                     fc=color, ec=color, linewidth=2)
            ax.annotate(label, xy=(n * dx * 0.5, n * dy * 0.5),
                       textcoords="offset points", xytext=(10, 10),
                       fontsize=10, color=color)
        
        ax.plot(0, 0, 'ko', markersize=8, zorder=5)
        
        lim = n + 1.5
        ax.set_xlim(-lim, lim)
        ax.set_ylim(-lim, lim)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)
        ax.set_title(f'Weight n = {n}\nSum = (0, 0) ✓', fontsize=13)
        ax.set_xlabel('x')
        ax.set_ylabel('y')
    
    fig.suptitle('Tropical Balancing Condition\n'
                 'Weighted direction vectors sum to zero at the vertex',
                 fontsize=15, y=1.02)
    
    plt.tight_layout()
    plt.savefig('balancing_condition.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: balancing_condition.png")


if __name__ == "__main__":
    plot_tropical_fermat_curve()
    plot_degree_independence()
    plot_balancing_condition()
    print("\nAll visualizations generated.")
