#!/usr/bin/env python3
"""
Demo: Cup-Cap Numbers and the Happy End Problem

Demonstrates the key numerical results from our formalization:
1. Cup-Cap number computation and recurrence verification
2. ES upper bounds for small n
3. Orientation tests and cup/cap finding
4. Convex layer decomposition
"""

from algorithms import (
    cup_cap_number, es_upper_bound, orient,
    is_general_position, find_longest_cup, find_longest_cap,
    convex_layer_decomposition, cup_cap_table,
    verify_recurrence, verify_symmetry
)


def demo_cup_cap_numbers():
    """Demonstrate Cup-Cap number computation."""
    print("=" * 60)
    print("CUP-CAP NUMBERS CC(j,k)")
    print("=" * 60)
    print()

    # Print table
    max_val = 8
    table = cup_cap_table(max_val, max_val)
    header = 'j\\k'
    print(f"{header:>6}", end="")
    for k in range(2, max_val + 1):
        print(f"{k:>8}", end="")
    print()
    print("-" * (6 + 8 * (max_val - 1)))
    for i, row in enumerate(table):
        j = i + 2
        print(f"{j:>6}", end="")
        for val in row:
            print(f"{val:>8}", end="")
        print()
    print()

    # ES upper bounds
    print("Erdős-Szekeres Upper Bounds ES(n) ≤ CC(n,n):")
    known_es = {3: 3, 4: 5, 5: 9, 6: 17}
    for n in range(3, 11):
        bound = es_upper_bound(n)
        known = known_es.get(n, "?")
        print(f"  ES({n}) ≤ CC({n},{n}) = {bound:>10}"
              f"  [known ES({n}) = {known}]")
    print()


def demo_recurrence():
    """Verify the Pascal recurrence."""
    print("=" * 60)
    print("PASCAL RECURRENCE VERIFICATION")
    print("CC(j,k) = CC(j-1,k) + CC(j,k-1) - 1 for j,k ≥ 3")
    print("=" * 60)
    print()

    all_pass = True
    for j in range(3, 10):
        for k in range(3, 10):
            ok = verify_recurrence(j, k)
            if not ok:
                print(f"  FAILED at j={j}, k={k}")
                all_pass = False

    if all_pass:
        print("  All recurrence checks passed for 3 ≤ j,k ≤ 9! ✓")
    print()


def demo_symmetry():
    """Verify CC(j,k) = CC(k,j)."""
    print("=" * 60)
    print("SYMMETRY VERIFICATION: CC(j,k) = CC(k,j)")
    print("=" * 60)
    print()

    all_pass = True
    for j in range(2, 15):
        for k in range(2, 15):
            if not verify_symmetry(j, k):
                print(f"  FAILED at j={j}, k={k}")
                all_pass = False

    if all_pass:
        print("  All symmetry checks passed for 2 ≤ j,k ≤ 14! ✓")
    print()


def demo_orientation():
    """Demonstrate orientation and cup/cap detection."""
    print("=" * 60)
    print("ORIENTATION AND CUP/CAP DETECTION")
    print("=" * 60)
    print()

    # Example: 5 points forming a cup
    cup_points = [(0, 0), (1, -1), (2, -1.5), (3, -1), (4, 0)]
    print("Cup points:", cup_points)
    for i in range(len(cup_points) - 2):
        o = orient(cup_points[i], cup_points[i+1], cup_points[i+2])
        print(f"  orient(p{i}, p{i+1}, p{i+2}) = {o:.2f}"
              f" ({'cup' if o > 0 else 'cap' if o < 0 else 'collinear'})")
    print(f"  General position: {is_general_position(cup_points)}")
    print()

    # Example: 5 points forming a cap
    cap_points = [(0, 0), (1, 1), (2, 1.5), (3, 1), (4, 0)]
    print("Cap points:", cap_points)
    for i in range(len(cap_points) - 2):
        o = orient(cap_points[i], cap_points[i+1], cap_points[i+2])
        print(f"  orient(p{i}, p{i+1}, p{i+2}) = {o:.2f}"
              f" ({'cup' if o > 0 else 'cap' if o < 0 else 'collinear'})")
    print()

    # Mixed example: 6 points
    mixed = [(0, 0), (1, 2), (2, 1), (3, 3), (4, 0.5), (5, 4)]
    print("Mixed points:", mixed)
    print(f"  General position: {is_general_position(mixed)}")
    cup = find_longest_cup(mixed)
    cap = find_longest_cap(mixed)
    print(f"  Longest cup (indices): {cup}, length {len(cup)}")
    print(f"  Longest cap (indices): {cap}, length {len(cap)}")
    print()


def demo_convex_layers():
    """Demonstrate convex layer decomposition."""
    print("=" * 60)
    print("CONVEX LAYER DECOMPOSITION (ONION PEELING)")
    print("=" * 60)
    print()

    # 12 points with interesting layer structure
    import math
    points = []
    # Outer ring
    for i in range(6):
        angle = i * math.pi / 3
        points.append((3 * math.cos(angle), 3 * math.sin(angle)))
    # Inner ring
    for i in range(4):
        angle = i * math.pi / 2 + math.pi / 4
        points.append((1.2 * math.cos(angle), 1.2 * math.sin(angle)))
    # Center
    points.append((0.1, 0.05))
    points.append((-0.1, -0.05))

    # Sort by x
    indexed = sorted(enumerate(points), key=lambda p: p[1][0])
    sorted_points = [p for _, p in indexed]
    original_indices = [i for i, _ in indexed]

    print(f"Point set: {len(points)} points")
    layers = convex_layer_decomposition(sorted_points)
    print(f"Number of layers: {len(layers)}")
    for i, layer in enumerate(layers):
        print(f"  Layer {i}: {len(layer)} points, indices = {layer}")
    print()


def demo_tightness_test():
    """Test the cup-cap tightness conjecture for small cases."""
    print("=" * 60)
    print("CUP-CAP TIGHTNESS CONJECTURE TEST")
    print("=" * 60)
    print()

    # For CC(3,3) = 3, need 2 points with no 3-cup and no 3-cap
    print("CC(3,3) = 3: Need 2 points avoiding 3-cup and 3-cap")
    pts = [(0, 0), (1, 1)]
    print(f"  Points: {pts}")
    cup = find_longest_cup(pts)
    cap = find_longest_cap(pts)
    print(f"  Longest cup: {len(cup)}, longest cap: {len(cap)}")
    print(f"  No 3-cup: {len(cup) < 3} ✓")
    print(f"  No 3-cap: {len(cap) < 3} ✓")
    print()

    # For CC(3,4) = 4, need 3 points with no 3-cup and no 4-cap
    print("CC(3,4) = 4: Need 3 points avoiding 3-cup and 4-cap")
    # 3 points in cap position have a 3-cap but no 4-cap (only 3 pts)
    # and no 3-cup if orient < 0
    pts = [(0, 0), (1, 2), (2, 0)]  # This is a cap
    o = orient(pts[0], pts[1], pts[2])
    print(f"  Points: {pts}, orient = {o:.1f}")
    # If orient < 0, it's a cap; no cup of size 3
    print(f"  Is cap: {o < 0}")
    print(f"  No 3-cup: {o < 0} ✓  (orient < 0 means all triples are caps)")
    print(f"  No 4-cap: True ✓  (only 3 points)")
    print()


if __name__ == "__main__":
    demo_cup_cap_numbers()
    demo_recurrence()
    demo_symmetry()
    demo_orientation()
    demo_convex_layers()
    demo_tightness_test()


#!/usr/bin/env python3
"""
Visualization: Convex Layer Decomposition (Onion Peeling)

Creates a visual demonstration of the convex layer decomposition
of a point set, showing how peeling the convex hull reveals nested
layers of increasing depth.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def orient(a: tuple[float, float], b: tuple[float, float],
           c: tuple[float, float]) -> float:
    """Orientation of three points."""
    return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0])


def convex_hull(points: list[tuple[float, float]]) -> list[int]:
    """Compute convex hull indices using Andrew's monotone chain."""
    n = len(points)
    if n <= 1:
        return list(range(n))
    if n == 2:
        return [0, 1]

    # Sort by x then y
    idx = sorted(range(n), key=lambda i: (points[i][0], points[i][1]))

    # Lower hull
    lower = []
    for i in idx:
        while len(lower) >= 2:
            if orient(points[lower[-2]], points[lower[-1]], points[i]) <= 0:
                lower.pop()
            else:
                break
        lower.append(i)

    # Upper hull
    upper = []
    for i in reversed(idx):
        while len(upper) >= 2:
            if orient(points[upper[-2]], points[upper[-1]], points[i]) <= 0:
                upper.pop()
            else:
                break
        upper.append(i)

    return list(dict.fromkeys(lower[:-1] + upper[:-1]))


def onion_peel(points: list[tuple[float, float]]) -> list[list[int]]:
    """Compute convex layer decomposition by iterative hull peeling."""
    n = len(points)
    remaining = set(range(n))
    layers = []

    while remaining:
        if len(remaining) <= 2:
            layers.append(sorted(remaining))
            break

        rem_list = sorted(remaining)
        rem_points = [points[i] for i in rem_list]
        hull_local = convex_hull(rem_points)
        hull_global = [rem_list[i] for i in hull_local]

        layers.append(hull_global)
        remaining -= set(hull_global)

    return layers


def visualize_layers():
    """Create a multi-panel visualization of convex layer decomposition."""
    np.random.seed(42)

    # Generate 30 points with some structure
    n = 30
    # Mix of ring and random points
    angles = np.random.uniform(0, 2 * np.pi, 12)
    radii = 3 + np.random.uniform(-0.3, 0.3, 12)
    outer = [(r * np.cos(a), r * np.sin(a)) for r, a in zip(radii, angles)]

    angles2 = np.random.uniform(0, 2 * np.pi, 10)
    radii2 = 1.5 + np.random.uniform(-0.3, 0.3, 10)
    middle = [(r * np.cos(a), r * np.sin(a)) for r, a in zip(radii2, angles2)]

    inner = [(np.random.uniform(-0.5, 0.5), np.random.uniform(-0.5, 0.5))
             for _ in range(8)]

    points = outer + middle + inner

    layers = onion_peel(points)
    n_layers = len(layers)

    fig, axes = plt.subplots(1, min(n_layers + 1, 5),
                             figsize=(5 * min(n_layers + 1, 5), 5))
    if n_layers + 1 <= 1:
        axes = [axes]

    colors = plt.cm.Set2(np.linspace(0, 1, max(n_layers, 2)))

    # Full view with all layers
    ax = axes[0]
    for i, layer in enumerate(layers):
        xs = [points[j][0] for j in layer]
        ys = [points[j][1] for j in layer]
        ax.scatter(xs, ys, c=[colors[i]], s=60, zorder=5,
                  label=f'Layer {i}')

        # Draw hull of this layer
        if len(layer) >= 3:
            layer_pts = [points[j] for j in layer]
            hull = convex_hull(layer_pts)
            hull_xs = [layer_pts[h][0] for h in hull] + [layer_pts[hull[0]][0]]
            hull_ys = [layer_pts[h][1] for h in hull] + [layer_pts[hull[0]][1]]
            ax.plot(hull_xs, hull_ys, '-', color=colors[i], linewidth=2,
                   alpha=0.7)

    ax.set_title(f'All {n_layers} Layers', fontsize=12, fontweight='bold')
    ax.legend(fontsize=8, loc='upper right')
    ax.set_aspect('equal')
    ax.grid(True, alpha=0.2)

    # Individual layer panels
    for panel in range(1, min(n_layers + 1, 5)):
        ax = axes[panel]
        layer_idx = panel - 1

        # Show all points faded
        all_xs = [p[0] for p in points]
        all_ys = [p[1] for p in points]
        ax.scatter(all_xs, all_ys, c='lightgray', s=30, zorder=3)

        # Highlight current layer
        layer = layers[layer_idx]
        xs = [points[j][0] for j in layer]
        ys = [points[j][1] for j in layer]
        ax.scatter(xs, ys, c=[colors[layer_idx]], s=80, zorder=5,
                  edgecolors='black', linewidths=1)

        # Draw hull
        if len(layer) >= 3:
            layer_pts = [points[j] for j in layer]
            hull = convex_hull(layer_pts)
            hull_xs = [layer_pts[h][0] for h in hull] + [layer_pts[hull[0]][0]]
            hull_ys = [layer_pts[h][1] for h in hull] + [layer_pts[hull[0]][1]]
            ax.plot(hull_xs, hull_ys, '-', color=colors[layer_idx],
                   linewidth=2.5)
            ax.fill(hull_xs, hull_ys, color=colors[layer_idx], alpha=0.15)

        ax.set_title(f'Layer {layer_idx} ({len(layer)} pts)',
                    fontsize=12, fontweight='bold')
        ax.set_aspect('equal')
        ax.grid(True, alpha=0.2)

    plt.suptitle('Convex Layer Decomposition (Onion Peeling)\n'
                'Novel structure connecting convex depth to the Happy End Problem',
                fontsize=14, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('convex_layers.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved convex_layers.png")


def visualize_depth_growth():
    """Show how convex layer depth grows with point count."""
    np.random.seed(123)

    ns = list(range(5, 101, 5))
    depths = []

    for n in ns:
        # Random points in unit square
        pts = [(np.random.uniform(0, 10), np.random.uniform(0, 10))
               for _ in range(n)]
        layers = onion_peel(pts)
        depths.append(len(layers))

    fig, ax = plt.subplots(figsize=(10, 6))
    ax.plot(ns, depths, 'bo-', linewidth=2, markersize=6,
           label='Observed depth')

    # Expected: ~√n for random points
    sqrt_fit = [0.5 * math.sqrt(n) for n in ns]
    ax.plot(ns, sqrt_fit, 'r--', linewidth=2,
           label=r'~0.5√n (expected for random)')

    ax.set_xlabel('Number of points n', fontsize=12)
    ax.set_ylabel('Convex layer depth', fontsize=12)
    ax.set_title('Convex Layer Depth Growth\n'
                'Random points in [0,10]²', fontsize=14)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('depth_growth.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved depth_growth.png")


if __name__ == "__main__":
    visualize_layers()
    visualize_depth_growth()


#!/usr/bin/env python3
"""
Visualization: Cup-Cap Number Heatmap and ES Growth

Creates a heatmap of CC(j,k) values showing the Pascal-like structure
and a log-scale plot of ES upper bounds vs the conjectured 2^(n-2)+1.
"""

import math
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def cup_cap_number(j: int, k: int) -> int:
    """Compute CC(j,k) = C(j+k-4, j-2) + 1."""
    if j < 2 or k < 2:
        return 0
    return math.comb(j + k - 4, j - 2) + 1


def make_heatmap(max_val: int = 10):
    """Create a heatmap of CC(j,k) values."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

    # Heatmap
    data = np.zeros((max_val - 1, max_val - 1))
    for i, j in enumerate(range(2, max_val + 1)):
        for l, k in enumerate(range(2, max_val + 1)):
            data[i, l] = math.log10(max(1, cup_cap_number(j, k)))

    im = ax1.imshow(data, cmap='YlOrRd', aspect='equal', origin='lower')
    ax1.set_xticks(range(max_val - 1))
    ax1.set_xticklabels(range(2, max_val + 1))
    ax1.set_yticks(range(max_val - 1))
    ax1.set_yticklabels(range(2, max_val + 1))
    ax1.set_xlabel('k (cap size)', fontsize=12)
    ax1.set_ylabel('j (cup size)', fontsize=12)
    ax1.set_title('log₁₀ CC(j,k): Cup-Cap Number Heatmap', fontsize=14)

    # Annotate cells
    for i in range(max_val - 1):
        for l in range(max_val - 1):
            val = cup_cap_number(i + 2, l + 2)
            color = 'white' if data[i, l] > data.max() * 0.6 else 'black'
            if val < 10000:
                ax1.text(l, i, str(val), ha='center', va='center',
                        fontsize=7, color=color)

    plt.colorbar(im, ax=ax1, label='log₁₀(CC)')

    # ES growth plot
    ns = list(range(3, 16))
    cc_values = [cup_cap_number(n, n) for n in ns]
    conj_values = [2**(n-2) + 1 for n in ns]
    known_es = {3: 3, 4: 5, 5: 9, 6: 17}

    ax2.semilogy(ns, cc_values, 'b-o', linewidth=2, markersize=6,
                label='CC(n,n) = C(2n-4, n-2) + 1')
    ax2.semilogy(ns, conj_values, 'r--s', linewidth=2, markersize=6,
                label='ES conjecture: 2^(n-2) + 1')

    known_ns = sorted(known_es.keys())
    known_vals = [known_es[n] for n in known_ns]
    ax2.semilogy(known_ns, known_vals, 'g^', markersize=12,
                label='Known exact ES(n)', zorder=5)

    ax2.set_xlabel('n', fontsize=12)
    ax2.set_ylabel('Number of points', fontsize=12)
    ax2.set_title('ES Upper Bound vs Conjecture', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('cup_cap_heatmap.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved cup_cap_heatmap.png")


def make_recurrence_diagram():
    """Create a diagram showing the Pascal recurrence structure."""
    fig, ax = plt.subplots(figsize=(10, 8))

    max_val = 8
    # Draw the Pascal-like table with arrows
    for j in range(2, max_val + 1):
        for k in range(2, max_val + 1):
            val = cup_cap_number(j, k)
            x = k - 2
            y = max_val - j

            # Color by log value
            intensity = math.log10(max(1, val)) / math.log10(
                max(1, cup_cap_number(max_val, max_val)))
            color = plt.cm.Blues(0.2 + 0.8 * intensity)

            circle = plt.Circle((x, y), 0.4, color=color, ec='black',
                               linewidth=1)
            ax.add_patch(circle)
            ax.text(x, y, str(val), ha='center', va='center',
                   fontsize=8, fontweight='bold')

            # Draw arrows for recurrence
            if j >= 3 and k >= 3:
                # Arrow from (j-1, k)
                ax.annotate('', xy=(x - 0.05, y + 0.45),
                           xytext=(x - 0.05, y + 0.55),
                           arrowprops=dict(arrowstyle='->', color='red',
                                          lw=1.5))
                # Arrow from (j, k-1)
                ax.annotate('', xy=(x - 0.45, y - 0.05),
                           xytext=(x - 0.55, y - 0.05),
                           arrowprops=dict(arrowstyle='->', color='blue',
                                          lw=1.5))

    ax.set_xlim(-0.6, max_val - 1.4)
    ax.set_ylim(-0.6, max_val - 1.4)
    ax.set_aspect('equal')

    # Labels
    for k in range(2, max_val + 1):
        ax.text(k - 2, max_val - 1.2, f'k={k}', ha='center', fontsize=9)
    for j in range(2, max_val + 1):
        ax.text(-0.8, max_val - j, f'j={j}', ha='center', fontsize=9)

    ax.set_title('Cup-Cap Numbers with Pascal Recurrence Structure\n'
                'CC(j,k) = CC(j-1,k) + CC(j,k-1) - 1',
                fontsize=14)
    ax.axis('off')

    plt.tight_layout()
    plt.savefig('recurrence_diagram.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved recurrence_diagram.png")


if __name__ == "__main__":
    make_heatmap()
    make_recurrence_diagram()
