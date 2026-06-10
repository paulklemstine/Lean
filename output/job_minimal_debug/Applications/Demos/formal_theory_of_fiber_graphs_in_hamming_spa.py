#!/usr/bin/env python3
"""
Fiber Graph Demo: Bridge Duality and Spectral Properties

Demonstrates the core results of the fiber graph theory:
1. Bridge Duality Theorem verification
2. Fiber graph construction and visualization
3. Spectral gap computation
4. Fiber size distribution
"""

import numpy as np
from algorithms import (
    WeightSystem, all_configs, compute_fiber, hamming_distance,
    diff_positions, detect_bridge, verify_bridge_duality,
    build_fiber_graph, spectral_gap, fiber_size_distribution,
)


def demo_bridge_duality():
    """Demonstrate the Bridge Duality Theorem with concrete examples."""
    print("=" * 60)
    print("BRIDGE DUALITY THEOREM DEMONSTRATION")
    print("=" * 60)

    # Example 1: Bridge exists through both positions
    print("\n--- Example 1: Bridges exist ---")
    # n=3, q=3, weights designed so some pairs have matching weights
    weights = np.array([
        [0, 2, 0],   # Position 0: symbols 0 and 2 have same weight
        [1, 3, 1],   # Position 1: symbols 0 and 2 have same weight
        [4, 5, 6],   # Position 2: all distinct
    ])
    ws = WeightSystem(weights)

    x = (0, 0, 0)  # score = 0 + 1 + 4 = 5
    y = (2, 2, 0)  # score = 0 + 1 + 4 = 5
    print(f"x = {x}, score = {ws.score(x)}")
    print(f"y = {y}, score = {ws.score(y)}")
    print(f"Differ at positions: {diff_positions(x, y)}")

    result = verify_bridge_duality(ws, x, y)
    print(f"Bridge through pos 0: {result['bridge_through_i']} (delta = {result['delta_i']})")
    print(f"Bridge through pos 1: {result['bridge_through_j']} (delta = {result['delta_j']})")
    print(f"Duality holds: {result['duality_holds']}")

    # Example 2: No bridge through either position
    print("\n--- Example 2: No bridges ---")
    weights2 = np.array([
        [0, 3, 5],
        [1, 4, 2],
        [10, 10, 10],
    ])
    ws2 = WeightSystem(weights2)

    x2 = (0, 2, 0)  # score = 0 + 2 + 10 = 12
    y2 = (2, 0, 0)  # score = 5 + 1 + 10 = 16... need equal scores
    # Find a pair with equal scores differing at 2 positions
    configs = all_configs(ws2.n, ws2.q)
    found = False
    for c1 in configs:
        for c2 in configs:
            diffs = diff_positions(c1, c2)
            if len(diffs) == 2 and ws2.score(c1) == ws2.score(c2) and c1 < c2:
                result2 = verify_bridge_duality(ws2, c1, c2)
                if not result2['bridge_through_i']:
                    print(f"x = {c1}, score = {ws2.score(c1)}")
                    print(f"y = {c2}, score = {ws2.score(c2)}")
                    print(f"Bridge through pos {result2['positions'][0]}: {result2['bridge_through_i']}")
                    print(f"Bridge through pos {result2['positions'][1]}: {result2['bridge_through_j']}")
                    print(f"Duality holds: {result2['duality_holds']}")
                    found = True
                    break
        if found:
            break
    if not found:
        print("All pairs have bridges in this weight system.")

    # Exhaustive verification
    print("\n--- Exhaustive verification (n=4, q=3, 100 random weight systems) ---")
    violations = 0
    total_pairs = 0
    for trial in range(100):
        ws_rand = WeightSystem.random(4, 3, -10, 10)
        configs = all_configs(ws_rand.n, ws_rand.q)
        for i, c1 in enumerate(configs):
            for c2 in configs[i+1:]:
                if len(diff_positions(c1, c2)) == 2 and ws_rand.score(c1) == ws_rand.score(c2):
                    total_pairs += 1
                    res = verify_bridge_duality(ws_rand, c1, c2)
                    if not res['duality_holds']:
                        violations += 1

    print(f"Total pairs tested: {total_pairs}")
    print(f"Duality violations: {violations}")
    print(f"Bridge Duality Theorem verified: {'YES' if violations == 0 else 'NO'}")


def demo_fiber_graph():
    """Demonstrate fiber graph construction and properties."""
    print("\n" + "=" * 60)
    print("FIBER GRAPH STRUCTURE")
    print("=" * 60)

    # Small example
    weights = np.array([
        [0, 1, 2],
        [0, 1, 2],
        [0, 1, 2],
    ])
    ws = WeightSystem(weights)

    print(f"\nWeight system (n={ws.n}, q={ws.q}):")
    for i in range(ws.n):
        print(f"  Position {i}: {list(ws.weights[i])}")

    # Show fiber sizes
    dist = fiber_size_distribution(ws)
    print(f"\nFiber size distribution:")
    for score in sorted(dist.keys()):
        print(f"  Score {score}: {dist[score]} configurations")

    # Build fiber graph for the most populated fiber
    max_score = max(dist, key=dist.get)
    graph = build_fiber_graph(ws, max_score)
    print(f"\nFiber graph for score {max_score}:")
    print(f"  Vertices: {graph['num_vertices']}")
    print(f"  Edges: {graph['num_edges']}")
    print(f"  Configurations: {graph['vertices'][:5]}{'...' if len(graph['vertices']) > 5 else ''}")


def demo_spectral_gap():
    """Demonstrate spectral gap computation and the expansion conjecture."""
    print("\n" + "=" * 60)
    print("SPECTRAL GAP AND EXPANSION CONJECTURE")
    print("=" * 60)

    n_vals = [3, 4, 5]
    q = 3
    num_trials = 50

    for n in n_vals:
        gaps = []
        for _ in range(num_trials):
            ws = WeightSystem.random(n, q, -10, 10, position_separating=True)
            dist = fiber_size_distribution(ws)

            for score, size in dist.items():
                if size >= 3:  # Need at least 3 vertices for interesting gap
                    gap = spectral_gap(ws, score)
                    if gap is not None and gap > 1e-10:
                        gaps.append(gap)

        if gaps:
            min_gap = min(gaps)
            avg_gap = np.mean(gaps)
            predicted_lower = 0.5 / n
            print(f"\nn={n}, q={q} ({len(gaps)} non-trivial fibers from {num_trials} trials):")
            print(f"  Min spectral gap:  {min_gap:.4f}")
            print(f"  Mean spectral gap: {avg_gap:.4f}")
            print(f"  Predicted lower (0.5/n): {predicted_lower:.4f}")
            print(f"  Conjecture holds: {min_gap >= predicted_lower * 0.5}")


def demo_position_separation():
    """Demonstrate position separation rigidity."""
    print("\n" + "=" * 60)
    print("POSITION SEPARATION RIGIDITY")
    print("=" * 60)

    ws = WeightSystem.random(4, 3, -20, 20, position_separating=True)
    print(f"\nPosition-separating weight system (n={ws.n}, q={ws.q}):")
    for i in range(ws.n):
        print(f"  Position {i}: {list(ws.weights[i])}")

    # Verify rigidity: no two distinct configs at Hamming distance 1 have equal score
    configs = all_configs(ws.n, ws.q)
    violations = 0
    for c1 in configs:
        for c2 in configs:
            if hamming_distance(c1, c2) == 1 and ws.score(c1) == ws.score(c2):
                violations += 1

    print(f"\n  Pairs at distance 1 with equal score: {violations}")
    print(f"  Rigidity verified: {'YES' if violations == 0 else 'NO'}")


if __name__ == "__main__":
    np.random.seed(42)

    demo_bridge_duality()
    demo_fiber_graph()
    demo_spectral_gap()
    demo_position_separation()

    print("\n" + "=" * 60)
    print("ALL DEMOS COMPLETE")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Fiber Graph Structure

Plots the fiber graph for a small Hamming space, showing
configurations as nodes colored by fiber, with edges for
Hamming-adjacent same-score pairs.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product


def weight_system_score(weights, config):
    return sum(weights[i][config[i]] for i in range(len(config)))


def hamming_dist(x, y):
    return sum(1 for a, b in zip(x, y) if a != b)


def main():
    n, q = 3, 3
    weights = [
        [0, 1, 2],
        [0, 3, 1],
        [0, 2, 4],
    ]

    configs = list(product(range(q), repeat=n))
    scores = {c: weight_system_score(weights, c) for c in configs}

    # Group by score
    fibers = {}
    for c, s in scores.items():
        fibers.setdefault(s, []).append(c)

    # Build fiber graphs
    fig, axes = plt.subplots(2, 3, figsize=(15, 10))
    fig.suptitle('Fiber Graphs in Hamming Space (n=3, q=3)', fontsize=16, fontweight='bold')

    sorted_scores = sorted(fibers.keys())
    colors = plt.cm.Set2(np.linspace(0, 1, len(sorted_scores)))

    for idx, (score, ax) in enumerate(zip(sorted_scores[:6], axes.flat)):
        fiber = fibers[score]
        m = len(fiber)

        # Position nodes in a circle
        if m == 1:
            positions = {fiber[0]: (0.5, 0.5)}
        else:
            angles = np.linspace(0, 2 * np.pi, m, endpoint=False)
            positions = {fiber[k]: (0.5 + 0.35 * np.cos(angles[k]),
                                     0.5 + 0.35 * np.sin(angles[k]))
                        for k in range(m)}

        # Draw edges
        for i, c1 in enumerate(fiber):
            for c2 in fiber[i+1:]:
                if hamming_dist(c1, c2) == 1:
                    x1, y1 = positions[c1]
                    x2, y2 = positions[c2]
                    ax.plot([x1, x2], [y1, y2], 'k-', alpha=0.3, linewidth=1)

        # Draw nodes
        for c in fiber:
            x, y = positions[c]
            ax.plot(x, y, 'o', color=colors[idx], markersize=12, markeredgecolor='black')
            label = ''.join(str(v) for v in c)
            ax.text(x, y, label, ha='center', va='center', fontsize=6, fontweight='bold')

        ax.set_title(f'Score = {score} ({m} configs)', fontsize=12)
        ax.set_xlim(-0.05, 1.05)
        ax.set_ylim(-0.05, 1.05)
        ax.set_aspect('equal')
        ax.axis('off')

    for idx in range(len(sorted_scores), 6):
        axes.flat[idx].axis('off')

    plt.tight_layout()
    plt.savefig('fiber_graph_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved fiber_graph_visualization.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Spectral Gap Distribution

Plots the distribution of spectral gaps across random weight systems,
testing the Fiber Expansion Conjecture.
"""
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from itertools import product


def score(weights, config):
    return sum(weights[i][config[i]] for i in range(len(config)))


def hamming_dist(x, y):
    return sum(1 for a, b in zip(x, y) if a != b)


def compute_spectral_gap(weights, target_score):
    n = len(weights)
    q = len(weights[0])
    configs = list(product(range(q), repeat=n))
    fiber = [c for c in configs if score(weights, c) == target_score]
    m = len(fiber)
    if m < 2:
        return None

    adj = np.zeros((m, m))
    for i in range(m):
        for j in range(i + 1, m):
            if hamming_dist(fiber[i], fiber[j]) == 1:
                adj[i][j] = 1
                adj[j][i] = 1

    degrees = adj.sum(axis=1)
    if np.any(degrees == 0):
        return 0.0

    d_inv_sqrt = np.diag(1.0 / np.sqrt(degrees))
    laplacian = np.eye(m) - d_inv_sqrt @ adj @ d_inv_sqrt
    eigenvalues = np.sort(np.linalg.eigvalsh(laplacian))
    return float(eigenvalues[1]) if len(eigenvalues) > 1 else None


def random_pos_sep_weights(n, q, low=-15, high=15):
    weights = []
    for _ in range(n):
        vals = np.random.choice(range(low, high + 1), size=q, replace=False)
        weights.append(list(vals))
    return weights


def main():
    np.random.seed(42)
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    fig.suptitle('Spectral Gap Distribution (Testing Expansion Conjecture)',
                 fontsize=14, fontweight='bold')

    for ax_idx, n in enumerate([3, 4, 5]):
        q = 3
        gaps = []
        num_trials = 30

        for _ in range(num_trials):
            weights = random_pos_sep_weights(n, q)
            scores_all = {}
            for c in product(range(q), repeat=n):
                s = score(weights, c)
                scores_all[s] = scores_all.get(s, 0) + 1

            for s, count in scores_all.items():
                if count >= 3:
                    gap = compute_spectral_gap(weights, s)
                    if gap is not None and gap > 1e-10:
                        gaps.append(gap)

        ax = axes[ax_idx]
        if gaps:
            ax.hist(gaps, bins=20, color='steelblue', edgecolor='black', alpha=0.7)
            predicted = 0.5 / n
            ax.axvline(predicted, color='red', linestyle='--', linewidth=2,
                      label=f'Predicted lower bound (0.5/{n})')
            ax.set_xlabel('Spectral Gap λ₂')
            ax.set_ylabel('Frequency')
            ax.set_title(f'n={n}, q={q} ({len(gaps)} fibers)')
            ax.legend(fontsize=8)
        else:
            ax.text(0.5, 0.5, 'No non-trivial fibers found',
                   ha='center', va='center', transform=ax.transAxes)
            ax.set_title(f'n={n}, q={q}')

    plt.tight_layout()
    plt.savefig('spectral_gap_distribution.png', dpi=150, bbox_inches='tight')
    print("Saved spectral_gap_distribution.png")


if __name__ == "__main__":
    main()
