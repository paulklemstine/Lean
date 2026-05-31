#!/usr/bin/env python3
"""
Demo: Primewise Persistent Homology Detects Isogeny Volcano Depth

This script demonstrates the main conjecture by:
1. Building l-isogeny volcano graphs for various parameters
2. Computing BFS neighborhood complexes and persistence barcodes
3. Verifying that first cycle birth radius = volcano depth
4. Generating summary statistics and visualizations
"""

from algorithms import (
    VolcanoGraph, NeighborhoodComplex, depth_prediction,
    compute_accuracy, run_experiment, compute_persistence_barcode,
    subtree_size
)
from typing import Dict, List


def print_header(title: str) -> None:
    print("\n" + "=" * 70)
    print(f"  {title}")
    print("=" * 70)


def demo_basic_volcano() -> None:
    """Demonstrate basic volcano construction and classification."""
    print_header("Demo 1: Basic 2-Isogeny Volcano (depth 3, crater 3)")

    graph = VolcanoGraph(l=2, crater_size=3, max_depth=3)
    print(f"Total vertices: {graph.total_vertices()}")
    print(f"Vertices per depth:")
    for d in range(4):
        verts = graph.get_vertices_at_depth(d)
        print(f"  Depth {d}: {len(verts)} vertices")

    # Show detailed classification for one vertex at each depth
    for d in range(4):
        v = graph.get_vertices_at_depth(d)[0]
        cx = NeighborhoodComplex(graph, v, max_radius=6)
        print(f"\n  Vertex {v} (depth {d}):")
        print(f"    Radius | Vertices | Edges | β₁")
        print(f"    -------+---------+-------+----")
        for r in range(min(6, len(cx.vertex_counts))):
            print(f"    {r:6d} | {cx.vertex_counts[r]:7d} | {cx.edge_counts[r]:5d} | {cx.cycle_rank(r):3d}")
        fcb = cx.first_cycle_birth()
        pred = depth_prediction(graph, v, max_radius=6, crater_cycle_radius=1)
        print(f"    First cycle birth radius: {fcb}")
        print(f"    Predicted depth (fcb-1): {pred}")
        print(f"    Actual depth: {d}")
        print(f"    Prediction correct: {pred == d}")


def demo_accuracy_sweep() -> None:
    """Sweep over parameters and show accuracy."""
    print_header("Demo 2: Accuracy Sweep")

    configs = [
        (2, 3, 2),
        (2, 3, 3),
        (2, 3, 4),
        (2, 5, 3),
        (3, 4, 2),
        (3, 4, 3),
        (5, 6, 2),
    ]

    print(f"{'l':>3} {'crater':>7} {'depth':>6} {'vertices':>9} {'accuracy':>9}")
    print("-" * 40)

    for l, c, d in configs:
        result = run_experiment(l=l, crater_size=c, max_depth=d, max_radius=d + c//2 + 1)
        print(f"{l:3d} {c:7d} {d:6d} {result['total_vertices']:9d} {result['accuracy']:9.2%}")


def demo_persistence_barcodes() -> None:
    """Show persistence barcodes at different depths."""
    print_header("Demo 3: Persistence Barcodes")

    graph = VolcanoGraph(l=2, crater_size=4, max_depth=3)
    max_r = 6

    for d in range(4):
        v = graph.get_vertices_at_depth(d)[0]
        barcode = compute_persistence_barcode(graph, v, max_r)
        print(f"\n  Depth {d}, vertex {v}:")
        if barcode:
            for birth, death in barcode:
                bar = "█" * (death - birth + 1)
                print(f"    [{birth}, {death}] {' ' * birth}{bar}")
        else:
            print(f"    (no H₁ generators)")


def demo_subtree_growth() -> None:
    """Verify subtree size formula."""
    print_header("Demo 4: Subtree Growth Verification")

    print(f"{'l':>3} {'r':>3} {'subtreeSize':>12} {'formula':>12} {'match':>6}")
    print("-" * 40)

    for l in [2, 3, 5]:
        for r in range(6):
            st = subtree_size(l, r)
            formula = sum(l**i for i in range(r + 1))
            print(f"{l:3d} {r:3d} {st:12d} {formula:12d} {'✓' if st == formula else '✗':>6}")


def demo_conjecture_test() -> None:
    """Test the main conjecture across many configurations."""
    print_header("Demo 5: Conjecture Verification")

    total_tests = 0
    total_correct = 0
    failures: List[Dict] = []

    import math
    for l in [2, 3, 5]:
        for crater_size in [3, 4, 5, 6]:
            for max_depth in [1, 2, 3, 4]:
                if l == 5 and max_depth > 2:
                    continue  # Skip very large graphs

                graph = VolcanoGraph(l, crater_size, max_depth)
                ccr = crater_size // 2
                max_radius = max_depth + ccr + 1
                for v in graph.vertices:
                    pred = depth_prediction(graph, v, max_radius, ccr)
                    actual = graph.depth[v]
                    total_tests += 1
                    if pred == actual:
                        total_correct += 1
                    else:
                        failures.append({
                            "l": l, "crater": crater_size,
                            "depth": max_depth, "vertex": v,
                            "predicted": pred, "actual": actual
                        })

    print(f"Total tests: {total_tests}")
    print(f"Correct: {total_correct}")
    print(f"Accuracy: {total_correct/total_tests:.4%}")

    if failures:
        print(f"\nFailures ({len(failures)}):")
        for f in failures[:10]:
            print(f"  l={f['l']}, crater={f['crater']}, depth={f['depth']}, "
                  f"v={f['vertex']}: predicted={f['predicted']}, actual={f['actual']}")
    else:
        print("\n✓ All tests passed — conjecture holds for all tested configurations!")


def demo_euler_characteristic() -> None:
    """Verify Euler characteristic properties."""
    print_header("Demo 6: Euler Characteristic")

    graph = VolcanoGraph(l=2, crater_size=3, max_depth=3)

    print(f"{'Depth':>6} {'Radius':>7} {'V':>5} {'E':>5} {'χ':>5} {'β₁':>5} {'χ=1-β₁':>8}")
    print("-" * 45)

    for d in range(4):
        v = graph.get_vertices_at_depth(d)[0]
        cx = NeighborhoodComplex(graph, v, max_radius=5)
        for r in range(min(5, len(cx.vertex_counts))):
            nv = cx.vertex_counts[r]
            ne = cx.edge_counts[r]
            chi = nv - ne
            beta = cx.cycle_rank(r)
            check = "✓" if chi == 1 - beta else "✗"
            print(f"{d:6d} {r:7d} {nv:5d} {ne:5d} {chi:5d} {beta:5d} {check:>8}")


if __name__ == "__main__":
    demo_basic_volcano()
    demo_accuracy_sweep()
    demo_persistence_barcodes()
    demo_subtree_growth()
    demo_conjecture_test()
    demo_euler_characteristic()


#!/usr/bin/env python3
"""
Visualization: Persistence Barcodes for Volcano Depth Detection.

Creates a figure showing persistence barcodes (H₁) for vertices at each
depth level, demonstrating the depth-separation property.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from collections import deque


def build_volcano(l, crater_size, max_depth):
    adj = {}
    depth_map = {}
    vid = 0
    crater = []
    for i in range(crater_size):
        adj[vid] = set()
        depth_map[vid] = 0
        crater.append(vid)
        vid += 1
    for i in range(crater_size):
        u, v = crater[i], crater[(i + 1) % crater_size]
        adj[u].add(v); adj[v].add(u)
    current_layer = crater
    for d in range(1, max_depth + 1):
        next_layer = []
        for parent in current_layer:
            for _ in range(l):
                child = vid; vid += 1
                adj[child] = set(); depth_map[child] = d
                adj[parent].add(child); adj[child].add(parent)
                next_layer.append(child)
        current_layer = next_layer
    return adj, depth_map


def compute_barcode(adj, vertex, max_radius):
    visited = {vertex}
    boundary = {vertex}
    prev_rank = 0
    barcode = []
    for r in range(max_radius + 1):
        edges = set()
        for v in visited:
            for u in adj[v]:
                if u in visited:
                    edges.add((min(u, v), max(u, v)))
        beta1 = max(0, len(edges) - len(visited) + 1)
        new_cycles = beta1 - prev_rank
        for _ in range(new_cycles):
            barcode.append((r, max_radius))
        prev_rank = beta1
        new_boundary = set()
        for v in boundary:
            for u in adj[v]:
                if u not in visited:
                    new_boundary.add(u); visited.add(u)
        boundary = new_boundary
    return barcode


def main():
    configs = [
        (2, 3, 4, "l=2, crater=3, depth=4"),
        (3, 4, 3, "l=3, crater=4, depth=3"),
    ]

    fig, axes = plt.subplots(1, len(configs), figsize=(7 * len(configs), 6))
    if len(configs) == 1:
        axes = [axes]

    colors = plt.cm.viridis(np.linspace(0.2, 0.9, 6))

    for ax, (l, c, max_d, title) in zip(axes, configs):
        adj, depth_map = build_volcano(l, c, max_d)
        max_r = max_d + c // 2 + 2

        y_pos = 0
        y_labels = []
        y_ticks = []

        for d in range(max_d + 1):
            # Find a representative vertex at depth d
            for v in adj:
                if depth_map[v] == d:
                    barcode = compute_barcode(adj, v, max_r)
                    for birth, death in barcode:
                        ax.barh(y_pos, death - birth, left=birth,
                                height=0.6, color=colors[d], edgecolor='black',
                                linewidth=0.5, alpha=0.8)
                        y_pos -= 1
                    if not barcode:
                        y_pos -= 1
                    y_labels.append(f"Depth {d}")
                    y_ticks.append(y_pos + 0.5 * (1 if not barcode else len(barcode)))
                    y_pos -= 0.5
                    break

        ax.set_xlabel('Filtration Radius', fontsize=11)
        ax.set_title(f'H₁ Persistence Barcodes\n{title}', fontsize=12)
        ax.set_yticks(y_ticks)
        ax.set_yticklabels(y_labels, fontsize=9)
        ax.grid(True, axis='x', alpha=0.3)
        ax.axvline(x=0, color='gray', linewidth=0.5)

        # Annotate first cycle birth
        for d in range(max_d + 1):
            fcb = d + c // 2
            ax.axvline(x=fcb, color=colors[d], linewidth=1, linestyle='--', alpha=0.5)

    plt.tight_layout()
    plt.savefig('barcode_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved barcode_visualization.png")


if __name__ == '__main__':
    main()


#!/usr/bin/env python3
"""
Visualization: Isogeny Volcano Structure and Depth Detection.

Creates a figure showing:
1. The volcano graph colored by depth
2. BFS neighborhood expansion from different depths
3. Cycle rank (β₁) vs radius for each depth
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from collections import deque


def build_volcano(l, crater_size, max_depth):
    """Build volcano graph, returns (adj, depth, positions)."""
    adj = {}
    depth_map = {}
    positions = {}
    vid = 0

    # Crater as a regular polygon
    crater = []
    for i in range(crater_size):
        adj[vid] = set()
        depth_map[vid] = 0
        angle = 2 * np.pi * i / crater_size - np.pi / 2
        positions[vid] = (np.cos(angle) * 0.8, np.sin(angle) * 0.8 + max_depth)
        crater.append(vid)
        vid += 1

    for i in range(crater_size):
        u, v = crater[i], crater[(i + 1) % crater_size]
        adj[u].add(v)
        adj[v].add(u)

    current_layer = crater
    for d in range(1, max_depth + 1):
        next_layer = []
        spread = len(current_layer) * l
        for idx, parent in enumerate(current_layer):
            for j in range(l):
                child = vid
                vid += 1
                adj[child] = set()
                depth_map[child] = d
                # Position: spread out below parent
                child_idx = idx * l + j
                x = (child_idx - spread / 2 + 0.5) * (3.0 / max(spread, 1))
                y = max_depth - d
                positions[child] = (x, y)
                adj[parent].add(child)
                adj[child].add(parent)
                next_layer.append(child)
        current_layer = next_layer

    return adj, depth_map, positions


def compute_cycle_rank_profile(adj, depth_map, vertex, max_radius):
    """Compute β₁ at each radius from vertex."""
    visited = {vertex}
    boundary = {vertex}
    profile = []

    for r in range(max_radius + 1):
        # Count edges within visited
        edges = set()
        for v in visited:
            for u in adj[v]:
                if u in visited:
                    edges.add((min(u, v), max(u, v)))
        beta1 = max(0, len(edges) - len(visited) + 1)
        profile.append(beta1)

        # Expand
        new_boundary = set()
        for v in boundary:
            for u in adj[v]:
                if u not in visited:
                    new_boundary.add(u)
                    visited.add(u)
        boundary = new_boundary

    return profile


def main():
    l, crater_size, max_depth = 2, 3, 3
    max_radius = 6
    adj, depth_map, positions = build_volcano(l, crater_size, max_depth)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Volcano graph colored by depth
    ax1 = axes[0]
    colors = plt.cm.viridis(np.linspace(0.2, 0.9, max_depth + 1))

    # Draw edges
    drawn = set()
    for u in adj:
        for v in adj[u]:
            edge = (min(u, v), max(u, v))
            if edge not in drawn:
                drawn.add(edge)
                x = [positions[u][0], positions[v][0]]
                y = [positions[u][1], positions[v][1]]
                ax1.plot(x, y, 'k-', alpha=0.3, linewidth=0.5)

    # Draw vertices
    for v in adj:
        d = depth_map[v]
        ax1.scatter(*positions[v], c=[colors[d]], s=30, zorder=5, edgecolors='black', linewidth=0.3)

    # Legend
    patches = [mpatches.Patch(color=colors[d], label=f'Depth {d}') for d in range(max_depth + 1)]
    ax1.legend(handles=patches, loc='lower right', fontsize=8)
    ax1.set_title(f'{l}-Isogeny Volcano (crater={crater_size}, depth={max_depth})', fontsize=12)
    ax1.set_xlabel('Position')
    ax1.set_ylabel('Layer (crater at top)')
    ax1.set_aspect('equal')

    # Right: Cycle rank profiles
    ax2 = axes[1]
    radii = list(range(max_radius + 1))

    for d in range(max_depth + 1):
        # Pick a representative vertex at this depth
        for v in adj:
            if depth_map[v] == d:
                profile = compute_cycle_rank_profile(adj, depth_map, v, max_radius)
                ax2.plot(radii, profile, 'o-', color=colors[d],
                         label=f'Depth {d} (fcb={d+1})', markersize=4, linewidth=2)
                break

    ax2.set_xlabel('BFS Radius r', fontsize=11)
    ax2.set_ylabel('Cycle Rank β₁(B_r(v))', fontsize=11)
    ax2.set_title('Cycle Rank Profile by Depth', fontsize=12)
    ax2.legend(fontsize=9)
    ax2.set_xticks(radii)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('volcano_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved volcano_visualization.png")


if __name__ == '__main__':
    main()
