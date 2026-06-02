#!/usr/bin/env python3
"""
demo.py — Numerical demonstrations of impossible figure theory.

Demonstrates:
1. Monodromy computation for Penrose polygons
2. Rotation invariance verification
3. Obstruction degree classification
4. Wedge sum composition
5. Orientation holonomy computation
"""

import math
from typing import List, Tuple

# ─── Core Definitions ───

def monodromy(weights: List[float]) -> float:
    """Compute the monodromy (total height gain) of a weight cycle."""
    return sum(weights)


def rotate_weights(weights: List[float], k: int) -> List[float]:
    """Cyclically rotate weight function by k positions."""
    n = len(weights)
    if n == 0:
        return []
    return [weights[(i + k) % n] for i in range(n)]


def obstruction_degree(weights: List[float]) -> int:
    """Compute the obstruction degree: +1 (ascending), -1 (descending), 0 (realizable)."""
    m = monodromy(weights)
    if m > 1e-12:
        return 1
    elif m < -1e-12:
        return -1
    else:
        return 0


def is_realizable(weights: List[float]) -> bool:
    """Check if a weight cycle is realizable (monodromy ≈ 0)."""
    return abs(monodromy(weights)) < 1e-12


def holonomy(signs: List[int]) -> int:
    """Compute the orientation holonomy (product of ±1 signs)."""
    result = 1
    for s in signs:
        result *= s
    return result


def penrose_polygon(k: int, delta: float) -> List[float]:
    """Create a Penrose k-gon with uniform step size delta."""
    return [delta] * k


# ─── Demonstrations ───

def demo_penrose_family():
    """Demonstrate the Penrose polygon family and their monodromies."""
    print("=" * 60)
    print("DEMO 1: Penrose Polygon Family")
    print("=" * 60)
    delta = 1.0
    for k in range(3, 8):
        weights = penrose_polygon(k, delta)
        m = monodromy(weights)
        deg = obstruction_degree(weights)
        print(f"  Penrose {k}-gon (δ={delta}): monodromy = {m:.1f}, "
              f"degree = {deg:+d}, realizable = {is_realizable(weights)}")
    print()


def demo_rotation_invariance():
    """Verify monodromy is invariant under cyclic rotation."""
    print("=" * 60)
    print("DEMO 2: Rotation Invariance of Monodromy")
    print("=" * 60)
    weights = [1.5, -0.7, 2.3, 0.1, -1.2]
    n = len(weights)
    base_mono = monodromy(weights)
    print(f"  Original weights: {weights}")
    print(f"  Base monodromy:   {base_mono:.4f}")
    for k in range(1, n):
        rotated = rotate_weights(weights, k)
        rot_mono = monodromy(rotated)
        print(f"  Rotation k={k}: weights = {[round(w, 4) for w in rotated]}, "
              f"monodromy = {rot_mono:.4f}, "
              f"invariant = {abs(rot_mono - base_mono) < 1e-12}")
    print()


def demo_obstruction_degree():
    """Classify impossible figures by obstruction degree."""
    print("=" * 60)
    print("DEMO 3: Obstruction Degree Classification")
    print("=" * 60)
    cases = [
        ("Ascending Escher (3-step)", [1.0, 1.0, 1.0]),
        ("Descending Escher (4-step)", [-0.5, -0.5, -0.5, -0.5]),
        ("Balanced (realizable)", [1.0, -2.0, 1.0]),
        ("Mixed impossible", [3.0, -1.0, 0.5]),
        ("Penrose triangle", [1.0, 1.0, 1.0]),
    ]
    for name, weights in cases:
        deg = obstruction_degree(weights)
        m = monodromy(weights)
        label = {1: "ASCENDING", -1: "DESCENDING", 0: "REALIZABLE"}[deg]
        print(f"  {name:30s}: mono={m:+.2f}, degree={deg:+d} [{label}]")
    print()


def demo_wedge_sum():
    """Demonstrate wedge sum composition of impossible figures."""
    print("=" * 60)
    print("DEMO 4: Wedge Sum Composition")
    print("=" * 60)
    cycles = [
        ("Penrose triangle", [1.0, 1.0, 1.0]),
        ("Square cycle", [0.5, 0.5, 0.5, 0.5]),
        ("Balanced pentagon", [1.0, -0.5, 0.3, -0.5, -0.3]),
    ]
    for i, (name1, w1) in enumerate(cycles):
        for j, (name2, w2) in enumerate(cycles):
            if j <= i:
                continue
            m1, m2 = monodromy(w1), monodromy(w2)
            realizable = abs(m1) < 1e-12 and abs(m2) < 1e-12
            print(f"  {name1} ∨ {name2}:")
            print(f"    Monodromy vector: ({m1:.2f}, {m2:.2f})")
            print(f"    Wedge realizable: {realizable}")
    print()


def demo_orientation_holonomy():
    """Demonstrate orientation holonomy and non-orientability detection."""
    print("=" * 60)
    print("DEMO 5: Orientation Holonomy")
    print("=" * 60)
    cases = [
        ("Cylinder (all +1)", [1, 1, 1, 1]),
        ("Möbius band (one flip)", [1, 1, 1, -1]),
        ("Double twist", [1, -1, 1, -1]),
        ("Triple flip", [-1, -1, -1, 1]),
        ("Klein bottle path", [1, -1]),
    ]
    for name, signs in cases:
        h = holonomy(signs)
        num_flips = sum(1 for s in signs if s == -1)
        orient = "orientable" if h == 1 else "NON-ORIENTABLE"
        print(f"  {name:25s}: signs={signs}, holonomy={h:+d}, "
              f"flips={num_flips} ({'odd' if num_flips % 2 else 'even'}), {orient}")
    print()


def demo_height_construction():
    """Demonstrate height function construction for realizable weights."""
    print("=" * 60)
    print("DEMO 6: Height Function Construction")
    print("=" * 60)
    # Realizable case
    weights = [2.0, -1.0, 3.0, -4.0]
    print(f"  Weights: {weights}")
    print(f"  Monodromy: {monodromy(weights):.1f}")
    if is_realizable(weights):
        # Construct height function: h(i) = sum of weights up to i
        n = len(weights)
        heights = [0.0]
        for i in range(n):
            heights.append(heights[-1] + weights[i])
        print(f"  Height function: {[round(h, 2) for h in heights]}")
        print(f"  Consistency check: h(n) - h(0) = {heights[-1] - heights[0]:.1f} = monodromy ✓")
    else:
        print(f"  NOT REALIZABLE — no consistent height function exists")

    # Impossible case
    print()
    weights2 = [1.0, 1.0, 1.0]
    print(f"  Weights: {weights2}")
    print(f"  Monodromy: {monodromy(weights2):.1f}")
    if not is_realizable(weights2):
        print(f"  NOT REALIZABLE — Penrose triangle impossibility!")
        # Show the height spiral
        heights = [0.0]
        for lap in range(3):
            for w in weights2:
                heights.append(heights[-1] + w)
        print(f"  Height spiral (3 laps): {[round(h, 1) for h in heights]}")
        print(f"  Each lap adds {monodromy(weights2):.1f} — the staircase never returns!")
    print()


if __name__ == "__main__":
    print("╔" + "═" * 58 + "╗")
    print("║  IMPOSSIBLE FIGURES: Monodromy & Topological Obstruction  ║")
    print("╚" + "═" * 58 + "╝")
    print()

    demo_penrose_family()
    demo_rotation_invariance()
    demo_obstruction_degree()
    demo_wedge_sum()
    demo_orientation_holonomy()
    demo_height_construction()

    print("All demonstrations completed successfully.")


#!/usr/bin/env python3
"""
visualize_monodromy.py — Visualization of monodromy and impossible figures.
"""
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import numpy as np

def plot_penrose_family():
    """Plot monodromy vs. polygon order for the Penrose family."""
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))

    # Panel 1: Monodromy vs. polygon order
    ax = axes[0]
    ks = range(3, 20)
    delta = 1.0
    monodromies = [k * delta for k in ks]
    ax.bar(list(ks), monodromies, color='steelblue', alpha=0.8)
    ax.set_xlabel('Polygon Order k', fontsize=12)
    ax.set_ylabel('Monodromy (k·δ)', fontsize=12)
    ax.set_title('Penrose k-gon Monodromy', fontsize=14)
    ax.axhline(y=0, color='red', linestyle='--', linewidth=1, label='Realizability threshold')
    ax.legend()

    # Panel 2: Height spiral for Penrose triangle
    ax = axes[1]
    weights = [1.0, 1.0, 1.0]
    n = len(weights)
    laps = 5
    angles = []
    heights = []
    h = 0.0
    for lap in range(laps):
        for i, w in enumerate(weights):
            angle = 2 * np.pi * (lap * n + i) / n
            angles.append(angle)
            heights.append(h)
            h += w
    angles.append(2 * np.pi * laps)
    heights.append(h)

    ax.plot(angles, heights, 'b-', linewidth=2)
    for lap in range(laps + 1):
        ax.axvline(x=2 * np.pi * lap, color='gray', linestyle=':', alpha=0.3)
    ax.set_xlabel('Angle (radians)', fontsize=12)
    ax.set_ylabel('Height', fontsize=12)
    ax.set_title('Penrose Triangle Height Spiral', fontsize=14)
    ax.annotate('Never returns!', xy=(angles[-1], heights[-1]),
                fontsize=10, color='red', ha='right')

    # Panel 3: Obstruction degree classification
    ax = axes[2]
    np.random.seed(42)
    monos = np.random.randn(500) * 3
    colors = ['green' if abs(m) < 0.1 else ('blue' if m > 0 else 'red') for m in monos]
    ax.scatter(range(len(monos)), monos, c=colors, s=10, alpha=0.6)
    ax.axhline(y=0, color='black', linewidth=1)
    ax.set_xlabel('Sample Index', fontsize=12)
    ax.set_ylabel('Monodromy', fontsize=12)
    ax.set_title('Obstruction Degree Classification', fontsize=14)
    from matplotlib.lines import Line2D
    legend_elements = [
        Line2D([0], [0], marker='o', color='w', markerfacecolor='blue', label='Ascending (+1)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='green', label='Realizable (0)'),
        Line2D([0], [0], marker='o', color='w', markerfacecolor='red', label='Descending (-1)'),
    ]
    ax.legend(handles=legend_elements, fontsize=9)

    plt.tight_layout()
    plt.savefig('monodromy_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved monodromy_analysis.png")


def plot_orientation_holonomy():
    """Visualize orientation holonomy on cycles."""
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    for idx, (title, signs) in enumerate([
        ("Cylinder (orientable)", [1, 1, 1, 1, 1]),
        ("Möbius band (non-orientable)", [1, 1, 1, 1, -1]),
    ]):
        ax = axes[idx]
        n = len(signs)
        theta = np.linspace(0, 2 * np.pi, n + 1)

        # Draw the cycle
        for i in range(n):
            x1, y1 = np.cos(theta[i]), np.sin(theta[i])
            x2, y2 = np.cos(theta[i + 1]), np.sin(theta[i + 1])
            color = 'blue' if signs[i] == 1 else 'red'
            width = 2 if signs[i] == 1 else 3
            ax.annotate('', xy=(x2, y2), xytext=(x1, y1),
                       arrowprops=dict(arrowstyle='->', color=color, lw=width))

        # Draw vertices
        for i in range(n):
            ax.plot(np.cos(theta[i]), np.sin(theta[i]), 'ko', markersize=8)
            ax.annotate(f'v{i}', xy=(np.cos(theta[i]) * 1.15, np.sin(theta[i]) * 1.15),
                       fontsize=10, ha='center', va='center')

        hol = 1
        for s in signs:
            hol *= s
        num_neg = sum(1 for s in signs if s == -1)
        ax.set_title(f'{title}\nHolonomy = {hol:+d}, Flips = {num_neg}', fontsize=12)
        ax.set_xlim(-1.5, 1.5)
        ax.set_ylim(-1.5, 1.5)
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('orientation_holonomy.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved orientation_holonomy.png")


def plot_wedge_sum():
    """Visualize wedge sum of cycles and monodromy vectors."""
    fig, ax = plt.subplots(1, 1, figsize=(8, 8))

    # Plot monodromy vectors for various wedge sums
    cycle_data = [
        ("Penrose △", [1, 1, 1]),
        ("Square", [0.5, 0.5, 0.5, 0.5]),
        ("Balanced", [1, -0.5, 0.3, -0.5, -0.3]),
        ("Descending", [-1, -1, -1]),
    ]

    points = []
    labels = []
    for i, (name1, w1) in enumerate(cycle_data):
        for j, (name2, w2) in enumerate(cycle_data):
            m1, m2 = sum(w1), sum(w2)
            points.append((m1, m2))
            if i <= j:
                labels.append(f"{name1}∨{name2}")
            else:
                labels.append("")

    xs = [p[0] for p in points]
    ys = [p[1] for p in points]

    realizable = [abs(x) < 0.01 and abs(y) < 0.01 for x, y in points]
    colors = ['green' if r else 'red' for r in realizable]

    ax.scatter(xs, ys, c=colors, s=100, zorder=5, edgecolors='black')
    for (x, y), label in zip(points, labels):
        if label:
            ax.annotate(label, (x, y), textcoords="offset points",
                       xytext=(5, 5), fontsize=7)

    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
    ax.axvline(x=0, color='gray', linestyle='--', alpha=0.5)
    ax.plot(0, 0, 'g*', markersize=20, zorder=10, label='Realizable point')

    ax.set_xlabel('Monodromy of Cycle 1 (m₁)', fontsize=12)
    ax.set_ylabel('Monodromy of Cycle 2 (m₂)', fontsize=12)
    ax.set_title('Wedge Sum Monodromy Space ℝ²\n(Realizable iff m₁ = m₂ = 0)', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3)
    ax.set_aspect('equal')

    plt.tight_layout()
    plt.savefig('wedge_monodromy_space.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved wedge_monodromy_space.png")


if __name__ == "__main__":
    plot_penrose_family()
    plot_orientation_holonomy()
    plot_wedge_sum()
    print("All visualizations generated.")
