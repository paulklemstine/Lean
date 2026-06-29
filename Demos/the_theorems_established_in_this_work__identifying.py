#!/usr/bin/env python3
"""
Newton Persistence Demo
=======================

Demonstrates the core results of the Newton persistence framework:
1. Fixed points = polynomial roots (verified numerically)
2. Depth filtration computation
3. Persistence diagrams for various polynomials
4. Frobenius cycle type detection
"""

from algorithms import (
    newton_step, newton_iterate, find_roots,
    depth_filtration, persistence_diagram, newton_graph_adjacency,
    connected_components, spectral_width, poly_eval, poly_derivative,
    compute_orbit
)


def demo_fixed_point_theorem():
    """Demonstrate that Newton fixed points = polynomial roots."""
    print("=" * 60)
    print("DEMO 1: Newton Fixed Point ↔ Polynomial Root")
    print("=" * 60)

    test_cases = [
        ([-1, 0, 1], "x² - 1"),       # roots: ±1
        ([0, 0, 0, 1], "x³"),           # root: 0 (with multiplicity)
        ([-2, 0, 0, 1], "x³ - 2"),     # cube root of 2
        ([1, 1, 1, 1, 1], "x⁴+x³+x²+x+1"),  # cyclotomic
    ]

    for p in [7, 11, 13, 17]:
        print(f"\n--- Over F_{p} ---")
        for coeffs, name in test_cases:
            roots = find_roots(coeffs, p)
            fixed_pts = [x for x in range(p) if newton_step(coeffs, x, p) == x]
            deriv = poly_derivative(coeffs, p)
            simple_fixed = [x for x in fixed_pts
                           if poly_eval(deriv, x, p) != 0]
            simple_roots = [x for x in roots
                           if poly_eval(deriv, x, p) != 0]

            match = "✓" if set(simple_fixed) == set(simple_roots) else "✗"
            print(f"  {match} {name}: roots={roots}, "
                  f"simple fixed pts={simple_fixed}")


def demo_depth_filtration():
    """Show depth filtration for a polynomial."""
    print("\n" + "=" * 60)
    print("DEMO 2: Newton Depth Filtration")
    print("=" * 60)

    coeffs = [-1, 0, 1]  # x² - 1
    for p in [7, 11, 13]:
        print(f"\n--- x² - 1 over F_{p} ---")
        depths = depth_filtration(coeffs, p)
        roots = find_roots(coeffs, p)
        print(f"  Roots: {roots}")
        for d in sorted(set(depths.values())):
            elts = [x for x, dep in depths.items() if dep == d]
            print(f"  Depth {d:2d}: {elts}")


def demo_persistence_diagrams():
    """Compute persistence diagrams for various polynomials."""
    print("\n" + "=" * 60)
    print("DEMO 3: Persistence Diagrams")
    print("=" * 60)

    polynomials = [
        ([-1, 0, 1], "x² - 1"),
        ([-1, 0, 0, 1], "x³ - 1"),
        ([1, -5, 6], "x² - 5x + 6 = (x-2)(x-3)"),
        ([-1, 0, 0, 0, 1], "x⁴ - 1"),
    ]

    p = 13
    print(f"\nOver F_{p}:")
    for coeffs, name in polynomials:
        diagram = persistence_diagram(coeffs, p)
        roots = find_roots(coeffs, p)
        sw = spectral_width(coeffs, p)
        print(f"\n  {name}")
        print(f"    Roots in F_{p}: {roots}")
        print(f"    Persistence pairs: "
              f"{[(pp.birth, pp.death) for pp in diagram]}")
        print(f"    Spectral width: {sw}")


def demo_orbit_periodicity():
    """Show orbit structures in Newton graphs."""
    print("\n" + "=" * 60)
    print("DEMO 4: Newton Orbit Structure")
    print("=" * 60)

    coeffs = [-1, 0, 0, 1]  # x³ - 1
    p = 7
    print(f"\nx³ - 1 over F_{p}:")
    print(f"  Newton graph: ", end="")
    adj = newton_graph_adjacency(coeffs, p)
    print(adj)

    for x in range(p):
        orbit = compute_orbit(coeffs, x, p)
        cycle_str = "→".join(str(c) for c in orbit.cycle)
        tail_str = "→".join(str(t) for t in orbit.tail)
        if tail_str:
            print(f"  x={x}: {tail_str} → [{cycle_str}] (depth={orbit.depth})")
        else:
            print(f"  x={x}: [{cycle_str}] (depth={orbit.depth})")


def demo_frobenius_conjecture():
    """Test the Frobenius depth conjecture on specific examples."""
    print("\n" + "=" * 60)
    print("DEMO 5: Frobenius Depth Conjecture Test")
    print("=" * 60)

    # x^5 - 1: roots are 5th roots of unity
    # Over F_p, the number of roots depends on gcd(5, p-1)
    coeffs = [-1, 0, 0, 0, 0, 1]  # x⁵ - 1
    print("\nx⁵ - 1 over various primes:")
    print(f"  {'p':>5} | {'#roots':>6} | {'depths':>30} | {'components':>5}")
    print(f"  {'-'*5} | {'-'*6} | {'-'*30} | {'-'*5}")

    for p in [7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47]:
        roots = find_roots(coeffs, p)
        depths = depth_filtration(coeffs, p)
        depth_hist = {}
        for d in depths.values():
            depth_hist[d] = depth_hist.get(d, 0) + 1
        comps = connected_components(coeffs, p)
        hist_str = str(dict(sorted(depth_hist.items())))
        print(f"  {p:>5} | {len(roots):>6} | {hist_str:>30} | {len(comps):>5}")


def demo_product_basin_separation():
    """Demonstrate that roots of f are fixed under N_{f*g}."""
    print("\n" + "=" * 60)
    print("DEMO 6: Basin Separation for Product Polynomials")
    print("=" * 60)

    # f = x - 2, g = x - 3, f*g = x² - 5x + 6
    f_coeffs = [-2, 1]      # x - 2
    g_coeffs = [-3, 1]      # x - 3
    fg_coeffs = [6, -5, 1]  # x² - 5x + 6

    for p in [7, 11, 13]:
        print(f"\n--- Over F_{p} ---")
        roots_f = find_roots(f_coeffs, p)
        roots_g = find_roots(g_coeffs, p)
        roots_fg = find_roots(fg_coeffs, p)

        print(f"  Roots of f={roots_f}, g={roots_g}, f*g={roots_fg}")

        for r in roots_f:
            ns = newton_step(fg_coeffs, r, p)
            fixed = "✓ FIXED" if ns == r else f"✗ maps to {ns}"
            print(f"  Root {r} of f under N_{{fg}}: {fixed}")

        for r in roots_g:
            ns = newton_step(fg_coeffs, r, p)
            fixed = "✓ FIXED" if ns == r else f"✗ maps to {ns}"
            print(f"  Root {r} of g under N_{{fg}}: {fixed}")


if __name__ == "__main__":
    demo_fixed_point_theorem()
    demo_depth_filtration()
    demo_persistence_diagrams()
    demo_orbit_periodicity()
    demo_frobenius_conjecture()
    demo_product_basin_separation()
    print("\n" + "=" * 60)
    print("All demos complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Newton Functional Graph over F_p

Produces a circular layout of the Newton graph for a polynomial over
a finite field, with nodes colored by depth in the Newton filtration.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from typing import List, Dict, Tuple
import math


def poly_eval_mod(coeffs: List[int], x: int, p: int) -> int:
    result = 0
    power = 1
    for c in coeffs:
        result = (result + c * power) % p
        power = (power * x) % p
    return result


def poly_derivative_mod(coeffs: List[int], p: int) -> List[int]:
    if len(coeffs) <= 1:
        return [0]
    return [(i * coeffs[i]) % p for i in range(1, len(coeffs))]


def newton_step_mod(coeffs: List[int], x: int, p: int) -> int:
    deriv = poly_derivative_mod(coeffs, p)
    fx = poly_eval_mod(coeffs, x, p)
    fpx = poly_eval_mod(deriv, x, p)
    if fpx == 0:
        return x
    inv_fpx = pow(fpx, p - 2, p)
    return (x - fx * inv_fpx) % p


def compute_depths(coeffs: List[int], p: int) -> Dict[int, int]:
    depths = {}
    for x in range(p):
        current = x
        visited = {}
        step = 0
        while current not in visited and step <= p:
            visited[current] = step
            current = newton_step_mod(coeffs, current, p)
            step += 1
        if current in visited and newton_step_mod(coeffs, current, p) == current:
            # current is a fixed point
            depths[x] = visited.get(x, step)
            # Compute actual depth as distance to first fixed point
            c = x
            d = 0
            for _ in range(p + 1):
                if newton_step_mod(coeffs, c, p) == c:
                    depths[x] = d
                    break
                c = newton_step_mod(coeffs, c, p)
                d += 1
            else:
                depths[x] = -1
        else:
            depths[x] = -1
    return depths


def plot_newton_graph(coeffs: List[int], p: int, title: str, ax=None):
    if ax is None:
        fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    adj = {x: newton_step_mod(coeffs, x, p) for x in range(p)}
    depths = compute_depths(coeffs, p)

    # Circular layout
    angles = {x: 2 * math.pi * x / p - math.pi / 2 for x in range(p)}
    positions = {x: (math.cos(angles[x]), math.sin(angles[x])) for x in range(p)}

    # Color by depth
    max_depth = max(d for d in depths.values() if d >= 0) if any(d >= 0 for d in depths.values()) else 1
    cmap = plt.cm.viridis

    # Draw edges
    for x, y in adj.items():
        if x != y:
            x1, y1 = positions[x]
            x2, y2 = positions[y]
            dx_arrow = x2 - x1
            dy_arrow = y2 - y1
            ax.annotate("", xy=(x2, y2), xytext=(x1, y1),
                        arrowprops=dict(arrowstyle="->", color="gray",
                                       alpha=0.4, lw=0.8,
                                       connectionstyle="arc3,rad=0.1"))

    # Draw nodes
    for x in range(p):
        px, py = positions[x]
        d = depths[x]
        if d >= 0:
            color = cmap(d / max(max_depth, 1))
        else:
            color = "red"

        is_root = poly_eval_mod(coeffs, x, p) == 0
        size = 300 if is_root else 150
        marker = '*' if is_root else 'o'
        edgecolor = 'gold' if is_root else 'black'
        linewidth = 2 if is_root else 0.5

        ax.scatter(px, py, s=size, c=[color], marker=marker,
                  edgecolors=edgecolor, linewidths=linewidth, zorder=5)
        ax.annotate(str(x), (px, py), textcoords="offset points",
                   xytext=(0, -12), ha='center', fontsize=7)

    ax.set_xlim(-1.4, 1.4)
    ax.set_ylim(-1.4, 1.4)
    ax.set_aspect('equal')
    ax.set_title(title, fontsize=12, fontweight='bold')
    ax.axis('off')

    return ax


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 14))

    polynomials = [
        ([-1, 0, 1], 13, "x² − 1 over F₁₃"),
        ([-1, 0, 0, 1], 13, "x³ − 1 over F₁₃"),
        ([-1, 0, 0, 0, 0, 1], 11, "x⁵ − 1 over F₁₁"),
        ([6, -5, 1], 13, "(x−2)(x−3) over F₁₃"),
    ]

    for ax, (coeffs, p, title) in zip(axes.flat, polynomials):
        plot_newton_graph(coeffs, p, title, ax)

    # Add legend
    legend_elements = [
        mpatches.Patch(facecolor=plt.cm.viridis(0.0), label='Depth 0 (root)'),
        mpatches.Patch(facecolor=plt.cm.viridis(0.5), label='Medium depth'),
        mpatches.Patch(facecolor=plt.cm.viridis(1.0), label='Maximum depth'),
        mpatches.Patch(facecolor='red', label='Cyclic (no fixed pt)'),
    ]
    fig.legend(handles=legend_elements, loc='lower center', ncol=4,
              fontsize=10, frameon=True)

    plt.suptitle("Newton Functional Graphs over Finite Fields",
                fontsize=16, fontweight='bold', y=0.98)
    plt.tight_layout(rect=[0, 0.05, 1, 0.96])
    plt.savefig("newton_graphs.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved newton_graphs.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Persistence Diagrams for Newton Basins

Shows how persistence diagrams vary across primes for a fixed polynomial,
revealing arithmetic structure through topological statistics.
"""

import matplotlib.pyplot as plt
import numpy as np
from typing import List, Dict, Tuple
from collections import Counter


def poly_eval_mod(coeffs: List[int], x: int, p: int) -> int:
    result = 0
    power = 1
    for c in coeffs:
        result = (result + c * power) % p
        power = (power * x) % p
    return result


def poly_derivative_mod(coeffs: List[int], p: int) -> List[int]:
    if len(coeffs) <= 1:
        return [0]
    return [(i * coeffs[i]) % p for i in range(1, len(coeffs))]


def newton_step_mod(coeffs: List[int], x: int, p: int) -> int:
    deriv = poly_derivative_mod(coeffs, p)
    fx = poly_eval_mod(coeffs, x, p)
    fpx = poly_eval_mod(deriv, x, p)
    if fpx == 0:
        return x
    inv_fpx = pow(fpx, p - 2, p)
    return (x - fx * inv_fpx) % p


def find_roots(coeffs: List[int], p: int) -> List[int]:
    return [x for x in range(p) if poly_eval_mod(coeffs, x, p) == 0]


def depth_to_fixed(coeffs: List[int], x: int, p: int) -> int:
    current = x
    for step in range(p + 1):
        nxt = newton_step_mod(coeffs, current, p)
        if nxt == current:
            return step
        current = nxt
    return -1


def get_persistence_data(coeffs: List[int], p: int) -> List[Tuple[int, int]]:
    roots = find_roots(coeffs, p)
    if not roots:
        return []

    # For each root, find the max depth in its basin
    pairs = []
    for r in roots:
        max_depth = 0
        for x in range(p):
            d = depth_to_fixed(coeffs, x, p)
            if d >= 0:
                # Check if this element converges to r
                current = x
                for _ in range(d):
                    current = newton_step_mod(coeffs, current, p)
                if current == r:
                    max_depth = max(max_depth, d)
        pairs.append((0, max_depth))
    return pairs


def main():
    fig, axes = plt.subplots(2, 3, figsize=(16, 10))

    coeffs = [-1, 0, 0, 0, 0, 1]  # x^5 - 1
    primes = [7, 11, 13, 17, 19, 23]

    for ax, p in zip(axes.flat, primes):
        pairs = get_persistence_data(coeffs, p)
        roots = find_roots(coeffs, p)

        # Plot persistence diagram
        if pairs:
            births = [b for b, d in pairs]
            deaths = [d for b, d in pairs]
            max_val = max(max(deaths) + 1, 2)

            # Diagonal
            ax.plot([0, max_val], [0, max_val], 'k--', alpha=0.3, lw=1)

            # Points
            ax.scatter(births, deaths, s=100, c='steelblue', edgecolors='navy',
                      linewidths=1, zorder=5, alpha=0.8)

            # Jitter duplicate points slightly
            counter = Counter(pairs)
            for (b, d), count in counter.items():
                if count > 1:
                    ax.annotate(f"×{count}", (b, d), textcoords="offset points",
                               xytext=(8, 5), fontsize=9, color='darkred')

            ax.set_xlim(-0.5, max_val)
            ax.set_ylim(-0.5, max_val)
        else:
            ax.text(0.5, 0.5, "No roots", transform=ax.transAxes,
                   ha='center', va='center', fontsize=14, color='gray')

        ax.set_xlabel("Birth", fontsize=10)
        ax.set_ylabel("Death", fontsize=10)
        ax.set_title(f"x⁵ − 1 over F_{p}\n{len(roots)} roots",
                    fontsize=11, fontweight='bold')
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)

    plt.suptitle("Persistence Diagrams: Newton Basins of x⁵ − 1",
                fontsize=14, fontweight='bold')
    plt.tight_layout()
    plt.savefig("persistence_diagrams.png", dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved persistence_diagrams.png")


if __name__ == "__main__":
    main()
