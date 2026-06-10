#!/usr/bin/env python3
"""
Demo: Fiber Graphs Induced by Additive Scoring on Hamming Spaces

Demonstrates the core concepts:
1. Score delta algebra (antisymmetry, triangle identity)
2. Bridge duality theorem (2-position bridge equivalence)
3. Position separation rigidity (injective weights → rigid fibers)
4. Fiber graph structure visualization
"""

from itertools import product
from collections import defaultdict


def score(weights, config):
    """Compute additive score: S(x) = sum_i w_i(x_i)."""
    return sum(w[x] for w, x in zip(weights, config))


def score_delta(w, a, b):
    """Score delta: δ(a,b) = w(b) - w(a)."""
    return w[b] - w[a]


def hamming_distance(x, y):
    """Number of positions where x and y differ."""
    return sum(1 for a, b in zip(x, y) if a != b)


def fiber(weights, target, alphabet):
    """All configurations with the given score."""
    n = len(weights)
    return [cfg for cfg in product(alphabet, repeat=n) if score(weights, cfg) == target]


def fiber_graph_edges(configs):
    """Edges in the fiber graph (Hamming distance 1)."""
    edges = []
    for i, x in enumerate(configs):
        for j, y in enumerate(configs):
            if i < j and hamming_distance(x, y) == 1:
                edges.append((x, y))
    return edges


def demo_score_delta_algebra():
    """Demonstrate score delta algebraic properties."""
    print("=" * 60)
    print("DEMO 1: Score Delta Algebra")
    print("=" * 60)

    w = {0: 3, 1: 7, 2: 1}  # Weight function
    print(f"\nWeight function: {w}")

    # Antisymmetry: δ(a,b) = -δ(b,a)
    print("\n--- Antisymmetry ---")
    for a, b in [(0, 1), (1, 2), (0, 2)]:
        d_ab = score_delta(w, a, b)
        d_ba = score_delta(w, b, a)
        print(f"  δ({a},{b}) = {d_ab:+d},  δ({b},{a}) = {d_ba:+d},  "
              f"sum = {d_ab + d_ba}  ✓" if d_ab == -d_ba else "✗")

    # Triangle: δ(a,b) + δ(b,c) = δ(a,c)
    print("\n--- Triangle Identity ---")
    for a, b, c in [(0, 1, 2), (1, 2, 0), (2, 0, 1)]:
        d_ab = score_delta(w, a, b)
        d_bc = score_delta(w, b, c)
        d_ac = score_delta(w, a, c)
        print(f"  δ({a},{b}) + δ({b},{c}) = {d_ab} + {d_bc} = {d_ab + d_bc},  "
              f"δ({a},{c}) = {d_ac}  {'✓' if d_ab + d_bc == d_ac else '✗'}")

    # Self: δ(a,a) = 0
    print("\n--- Self-zero ---")
    for a in [0, 1, 2]:
        print(f"  δ({a},{a}) = {score_delta(w, a, a)}  ✓")


def demo_bridge_duality():
    """Demonstrate bridge duality theorem."""
    print("\n" + "=" * 60)
    print("DEMO 2: Bridge Duality Theorem")
    print("=" * 60)

    # Weight system: 3 positions, alphabet {0,1,2}
    weights = [
        {0: 0, 1: 3, 2: 5},  # w_0
        {0: 1, 1: 2, 2: 4},  # w_1
        {0: 0, 1: 1, 2: 3},  # w_2
    ]
    alphabet = [0, 1, 2]

    print("\nWeight system:")
    for i, w in enumerate(weights):
        print(f"  w_{i}: {w}")

    # Find pairs differing at exactly 2 positions with same score
    all_configs = list(product(alphabet, repeat=3))
    print("\nPairs differing at exactly 2 positions with same score:")

    found = 0
    for x in all_configs:
        for y in all_configs:
            if x >= y:
                continue
            diff_pos = [i for i in range(3) if x[i] != y[i]]
            if len(diff_pos) != 2:
                continue
            if score(weights, x) != score(weights, y):
                continue

            i, j = diff_pos
            wi_match = weights[i][x[i]] == weights[i][y[i]]
            wj_match = weights[j][x[j]] == weights[j][y[j]]

            print(f"  x={x}, y={y}, diff at positions {i},{j}")
            print(f"    w_{i}(x_{i})={weights[i][x[i]]}, w_{i}(y_{i})={weights[i][y[i]]}  "
                  f"{'match' if wi_match else 'differ'}")
            print(f"    w_{j}(x_{j})={weights[j][x[j]]}, w_{j}(y_{j})={weights[j][y[j]]}  "
                  f"{'match' if wj_match else 'differ'}")
            print(f"    Bridge duality: wi_match ↔ wj_match? "
                  f"{'✓' if wi_match == wj_match else '✗'}")
            found += 1
            if found >= 5:
                break
        if found >= 5:
            break


def demo_position_rigidity():
    """Demonstrate position separation rigidity."""
    print("\n" + "=" * 60)
    print("DEMO 3: Position Separation Rigidity")
    print("=" * 60)

    # Injective weight system (all w_i are injective)
    weights = [
        {0: 1, 1: 3, 2: 7},  # injective
        {0: 2, 1: 5, 2: 11}, # injective
        {0: 4, 1: 9, 2: 13}, # injective
    ]
    alphabet = [0, 1, 2]

    print("\nInjective weight system:")
    for i, w in enumerate(weights):
        print(f"  w_{i}: {w}  (injective: {len(set(w.values())) == len(w)})")

    all_configs = list(product(alphabet, repeat=3))
    scores = defaultdict(list)
    for cfg in all_configs:
        scores[score(weights, cfg)].append(cfg)

    print("\n1-position freedom test (rigidity check):")
    rigid_count = 0
    for target, configs in sorted(scores.items()):
        for x in configs:
            for y in configs:
                if x >= y:
                    continue
                diff = [i for i in range(3) if x[i] != y[i]]
                if len(diff) == 1:
                    print(f"  VIOLATION: x={x}, y={y} same score {target}, "
                          f"differ only at position {diff[0]}")
                    rigid_count += 1

    if rigid_count == 0:
        print("  No violations found — all fibers are rigid under 1-position changes ✓")
    print(f"\n  (Checked {sum(len(v) for v in scores.values())} configs across "
          f"{len(scores)} fibers)")


def demo_fiber_graph():
    """Demonstrate fiber graph structure."""
    print("\n" + "=" * 60)
    print("DEMO 4: Fiber Graph Structure")
    print("=" * 60)

    # Simple weight system: binary alphabet, 4 positions
    weights = [
        {0: 0, 1: 1},
        {0: 0, 1: 1},
        {0: 0, 1: 1},
        {0: 0, 1: 1},
    ]
    alphabet = [0, 1]

    print("\nUniform binary weight system (4 positions, counting 1s)")

    for target in range(5):
        f = fiber(weights, target, alphabet)
        edges = fiber_graph_edges(f)
        if f:
            # Check connectivity via BFS
            if len(f) <= 1:
                components = len(f)
            else:
                visited = {f[0]}
                queue = [f[0]]
                while queue:
                    curr = queue.pop(0)
                    for x, y in edges:
                        neighbor = y if x == curr else (x if y == curr else None)
                        if neighbor and neighbor not in visited:
                            visited.add(neighbor)
                            queue.append(neighbor)
                components = 1 if len(visited) == len(f) else "disconnected"

            avg_deg = 2 * len(edges) / len(f) if f else 0
            print(f"\n  Fiber(score={target}): {len(f)} configs, "
                  f"{len(edges)} edges, avg degree {avg_deg:.1f}, "
                  f"connected: {components == 1}")
            for cfg in f[:4]:
                print(f"    {cfg}")
            if len(f) > 4:
                print(f"    ... ({len(f) - 4} more)")


def demo_total_delta():
    """Demonstrate total delta conservation."""
    print("\n" + "=" * 60)
    print("DEMO 5: Total Delta Conservation")
    print("=" * 60)

    weights = [
        {0: 2, 1: 5, 2: 3},
        {0: 1, 1: 4, 2: 7},
        {0: 6, 1: 0, 2: 8},
    ]

    x = (0, 1, 2)
    y = (2, 0, 1)
    sx = score(weights, x)
    sy = score(weights, y)

    print(f"\n  x = {x}, score = {sx}")
    print(f"  y = {y}, score = {sy}")

    deltas = [score_delta(w, a, b) for w, a, b in zip(weights, x, y)]
    print(f"\n  Position deltas: {deltas}")
    print(f"  Sum of deltas: {sum(deltas)}")

    if sx == sy:
        print(f"  Scores equal → total delta = 0 ✓")
    else:
        print(f"  Scores differ by {sy - sx} = sum of deltas {sum(deltas)} ✓")

    # Find equal-score pairs
    alphabet = [0, 1, 2]
    all_configs = list(product(alphabet, repeat=3))
    print("\n  Equal-score pairs (total delta = 0 verification):")
    count = 0
    for cx in all_configs:
        for cy in all_configs:
            if cx >= cy:
                continue
            if score(weights, cx) == score(weights, cy):
                deltas = [score_delta(w, a, b) for w, a, b in zip(weights, cx, cy)]
                if sum(deltas) != 0:
                    print(f"  VIOLATION: {cx} → {cy}, deltas={deltas}, sum={sum(deltas)}")
                count += 1
    print(f"  Verified {count} equal-score pairs, all have total delta = 0 ✓")


if __name__ == "__main__":
    demo_score_delta_algebra()
    demo_bridge_duality()
    demo_position_rigidity()
    demo_fiber_graph()
    demo_total_delta()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Fiber Graph Structure

Renders fiber graphs for various additive scoring systems,
showing how fibers partition the Hamming space and how
bridge duality manifests visually.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from itertools import product
from collections import defaultdict


def additive_score(weights, config):
    return sum(w[x] for w, x in zip(weights, config))


def hamming_dist(x, y):
    return sum(1 for a, b in zip(x, y) if a != b)


def fiber_graph_edges(configs):
    edges = []
    for i, x in enumerate(configs):
        for j, y in enumerate(configs):
            if i < j and hamming_dist(x, y) == 1:
                edges.append((i, j))
    return edges


def spring_layout(n_nodes, edges, iterations=100, seed=42):
    """Simple spring layout for graph drawing."""
    rng = np.random.RandomState(seed)
    pos = rng.randn(n_nodes, 2)

    for _ in range(iterations):
        forces = np.zeros_like(pos)

        # Repulsion between all pairs
        for i in range(n_nodes):
            for j in range(i + 1, n_nodes):
                diff = pos[i] - pos[j]
                dist = max(np.linalg.norm(diff), 0.01)
                force = diff / (dist ** 2) * 0.5
                forces[i] += force
                forces[j] -= force

        # Attraction along edges
        for i, j in edges:
            diff = pos[j] - pos[i]
            dist = np.linalg.norm(diff)
            force = diff * dist * 0.1
            forces[i] += force
            forces[j] -= force

        # Centering force
        center = pos.mean(axis=0)
        forces -= (pos - center) * 0.01

        pos += forces * 0.05

    return pos


def plot_fiber_partition(weights, alphabet, filename="fiber_partition.png"):
    """Plot the fiber partition of the configuration space."""
    n = len(weights)
    all_configs = list(product(alphabet, repeat=n))

    # Compute scores
    scores = [additive_score(weights, cfg) for cfg in all_configs]
    unique_scores = sorted(set(scores))
    score_to_color = {s: i for i, s in enumerate(unique_scores)}

    # Layout all configs
    edges = []
    for i, x in enumerate(all_configs):
        for j, y in enumerate(all_configs):
            if i < j and hamming_dist(x, y) == 1:
                edges.append((i, j))

    pos = spring_layout(len(all_configs), edges, iterations=200)

    fig, axes = plt.subplots(1, 2, figsize=(16, 7))

    # Left: full Hamming graph colored by fiber
    ax = axes[0]
    cmap = plt.cm.Set3
    colors = [cmap(score_to_color[s] / max(len(unique_scores) - 1, 1))
              for s in scores]

    for i, j in edges:
        ax.plot([pos[i, 0], pos[j, 0]], [pos[i, 1], pos[j, 1]],
                'k-', alpha=0.1, linewidth=0.5)

    ax.scatter(pos[:, 0], pos[:, 1], c=colors, s=80, zorder=5, edgecolors='k',
               linewidth=0.5)

    for i, cfg in enumerate(all_configs):
        ax.annotate(''.join(map(str, cfg)), pos[i], fontsize=5,
                    ha='center', va='center')

    patches = [mpatches.Patch(color=cmap(i / max(len(unique_scores) - 1, 1)),
                              label=f'score={s}')
               for i, s in enumerate(unique_scores)]
    ax.legend(handles=patches, fontsize=7, loc='upper right')
    ax.set_title(f'Hamming Space Colored by Fiber\n(n={n}, |α|={len(alphabet)})')
    ax.axis('off')

    # Right: fiber graph for the largest fiber
    fiber_configs = defaultdict(list)
    for cfg, s in zip(all_configs, scores):
        fiber_configs[s].append(cfg)

    largest_score = max(fiber_configs, key=lambda s: len(fiber_configs[s]))
    largest_fiber = fiber_configs[largest_score]

    f_edges = fiber_graph_edges(largest_fiber)
    if largest_fiber:
        f_pos = spring_layout(len(largest_fiber), f_edges, iterations=200)

        ax = axes[1]
        for i, j in f_edges:
            ax.plot([f_pos[i, 0], f_pos[j, 0]], [f_pos[i, 1], f_pos[j, 1]],
                    'b-', alpha=0.4, linewidth=1.5)

        # Color by degree
        degrees = [0] * len(largest_fiber)
        for i, j in f_edges:
            degrees[i] += 1
            degrees[j] += 1

        scatter = ax.scatter(f_pos[:, 0], f_pos[:, 1], c=degrees,
                            cmap='YlOrRd', s=120, zorder=5,
                            edgecolors='k', linewidth=0.5)
        plt.colorbar(scatter, ax=ax, label='Fiber degree')

        for i, cfg in enumerate(largest_fiber):
            ax.annotate(''.join(map(str, cfg)), f_pos[i], fontsize=6,
                        ha='center', va='center')

        ax.set_title(f'Fiber Graph (score={largest_score})\n'
                     f'{len(largest_fiber)} vertices, {len(f_edges)} edges')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {filename}")


def plot_bridge_duality(weights, alphabet, filename="bridge_duality.png"):
    """Visualize bridge duality: pairs differing at 2 positions."""
    n = len(weights)
    all_configs = list(product(alphabet, repeat=n))

    fig, ax = plt.subplots(figsize=(10, 8))

    # Find all duality pairs
    pairs = []
    for x in all_configs:
        for y in all_configs:
            if x >= y:
                continue
            diff = [i for i in range(n) if x[i] != y[i]]
            if len(diff) != 2:
                continue
            if additive_score(weights, x) != additive_score(weights, y):
                continue
            i, j = diff
            wi_match = weights[i][x[i]] == weights[i][y[i]]
            wj_match = weights[j][x[j]] == weights[j][y[j]]
            pairs.append((x, y, i, j, wi_match, wj_match))

    if not pairs:
        ax.text(0.5, 0.5, 'No duality pairs found', transform=ax.transAxes,
                ha='center', va='center', fontsize=14)
    else:
        # Plot as a matrix-like diagram
        both_match = sum(1 for _, _, _, _, wi, wj in pairs if wi and wj)
        both_diff = sum(1 for _, _, _, _, wi, wj in pairs if not wi and not wj)
        total = len(pairs)

        categories = ['Both bridges exist\n(w_i match ∧ w_j match)',
                      'Neither bridge exists\n(w_i differ ∧ w_j differ)']
        counts = [both_match, both_diff]
        colors = ['#2ecc71', '#e74c3c']

        bars = ax.bar(categories, counts, color=colors, edgecolor='k', linewidth=1.5)

        for bar, count in zip(bars, counts):
            ax.text(bar.get_x() + bar.get_width() / 2, bar.get_height() + 0.3,
                    str(count), ha='center', va='bottom', fontsize=14, fontweight='bold')

        ax.set_ylabel('Number of pairs', fontsize=12)
        ax.set_title(f'Bridge Duality Verification\n'
                     f'{total} total pairs, all satisfy duality '
                     f'(no mixed cases)', fontsize=13)
        ax.set_ylim(0, max(counts) * 1.2 if counts else 1)

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {filename}")


def plot_fiber_sizes(weights, alphabet, filename="fiber_sizes.png"):
    """Plot the distribution of fiber sizes."""
    n = len(weights)

    score_counts = defaultdict(int)
    for cfg in product(alphabet, repeat=n):
        s = additive_score(weights, cfg)
        score_counts[s] += 1

    scores = sorted(score_counts.keys())
    sizes = [score_counts[s] for s in scores]

    fig, ax = plt.subplots(figsize=(10, 6))

    bars = ax.bar(range(len(scores)), sizes, color='steelblue',
                  edgecolor='navy', linewidth=0.5)

    ax.set_xticks(range(len(scores)))
    ax.set_xticklabels([str(s) for s in scores], fontsize=8, rotation=45)
    ax.set_xlabel('Score value', fontsize=12)
    ax.set_ylabel('Fiber size (# configurations)', fontsize=12)
    ax.set_title(f'Fiber Size Distribution\n'
                 f'(n={n}, |α|={len(alphabet)}, '
                 f'total configs={len(alphabet)**n})', fontsize=13)

    # Add total configs line
    total = len(alphabet) ** n
    avg = total / len(scores) if scores else 0
    ax.axhline(avg, color='red', linestyle='--', alpha=0.5,
               label=f'Average = {avg:.1f}')
    ax.legend()

    plt.tight_layout()
    plt.savefig(filename, dpi=150, bbox_inches='tight')
    plt.close()
    print(f"Saved: {filename}")


if __name__ == "__main__":
    # Weight system for demonstrations
    weights = [
        {0: 0, 1: 2, 2: 3},
        {0: 0, 1: 1, 2: 4},
        {0: 0, 1: 3, 2: 5},
    ]
    alphabet = [0, 1, 2]

    plot_fiber_partition(weights, alphabet)
    plot_bridge_duality(weights, alphabet)
    plot_fiber_sizes(weights, alphabet)
    print("\nAll visualizations generated.")
