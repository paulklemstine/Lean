"""
Applications of Cherry Pair Metric Invariance

Demonstrates real-world applications:
1. Phylogenetic tree reconstruction from DNA distance data
2. Network topology inference from latency measurements
3. Hierarchical clustering validation
"""

import numpy as np
from algorithms import (
    TreeNode, distance_matrix, is_four_point,
    cherry_picking_reconstruct, detect_cherry_pair,
    cherry_separation_margin, noisy_cherry_detection,
    is_cherry_pair_metric
)


def application_phylogenetics():
    """Phylogenetic reconstruction from simulated molecular distances."""
    print("=" * 70)
    print("APPLICATION 1: Phylogenetic Tree Reconstruction")
    print("=" * 70)

    # Simulated evolutionary distances (substitutions per site)
    # Based on a known tree: ((Human, Chimp), (Gorilla, Orangutan))
    species = ["Human", "Chimp", "Gorilla", "Orangutan"]
    D_true = np.array([
        [0.0, 0.02, 0.04, 0.08],
        [0.02, 0.0, 0.04, 0.08],
        [0.04, 0.04, 0.0, 0.08],
        [0.08, 0.08, 0.08, 0.0]
    ])

    print(f"\nTrue evolutionary distances:")
    print(f"{'':>12}", end="")
    for s in species:
        print(f"{s:>10}", end="")
    print()
    for i, s in enumerate(species):
        print(f"{s:>12}", end="")
        for j in range(4):
            print(f"{D_true[i][j]:10.3f}", end="")
        print()

    print(f"\nFour-point condition: {is_four_point(D_true)}")

    # Reconstruct
    T = cherry_picking_reconstruct(D_true)
    cherries = T.cherry_pairs()
    print(f"Detected cherry pairs: ", end="")
    for a, b in cherries:
        print(f"({species[a]}, {species[b]})", end=" ")
    print()

    # Add noise (measurement error)
    np.random.seed(123)
    noise_levels = [0.001, 0.005, 0.01, 0.015]
    margin = cherry_separation_margin(D_true, cherries)
    print(f"\nCherry separation margin: {margin:.4f}")
    print(f"Theoretical noise tolerance: ε < {margin/4:.4f}")

    print(f"\nRobustness under noise:")
    for eps in noise_levels:
        noise = np.random.uniform(-eps, eps, (4, 4))
        noise = (noise + noise.T) / 2
        np.fill_diagonal(noise, 0)
        D_noisy = D_true + noise

        T_noisy = cherry_picking_reconstruct(D_noisy)
        noisy_cherries = T_noisy.cherry_pairs()
        correct = set(noisy_cherries) == set(cherries)
        print(f"  ε = {eps:.4f}: cherries = ", end="")
        for a, b in noisy_cherries:
            print(f"({species[a]}, {species[b]})", end=" ")
        print(f"{'✓' if correct else '✗'}")


def application_network_topology():
    """Network topology inference from round-trip latency measurements."""
    print("\n" + "=" * 70)
    print("APPLICATION 2: Network Topology Inference")
    print("=" * 70)

    # Simulated network: tree topology with routers
    # Topology: ((Server_A, Server_B), (Server_C, Server_D))
    hosts = ["Server_A", "Server_B", "Server_C", "Server_D"]

    # Latencies in milliseconds (tree metric with noise)
    D_true = np.array([
        [0, 10, 30, 30],
        [10, 0, 30, 30],
        [30, 30, 0, 8],
        [30, 30, 8, 0]
    ], dtype=float)

    print(f"\nRound-trip latencies (ms):")
    print(f"{'':>12}", end="")
    for h in hosts:
        print(f"{h:>12}", end="")
    print()
    for i, h in enumerate(hosts):
        print(f"{h:>12}", end="")
        for j in range(4):
            print(f"{D_true[i][j]:12.1f}", end="")
        print()

    print(f"\nTree metric (four-point): {is_four_point(D_true)}")

    T = cherry_picking_reconstruct(D_true)
    cherries = T.cherry_pairs()
    print(f"Inferred co-located pairs: ", end="")
    for a, b in cherries:
        print(f"({hosts[a]}, {hosts[b]})", end=" ")
    print()
    print("→ These servers share a switch/router (tree cherry = shared parent)")


def application_clustering_validation():
    """Validate hierarchical clustering using tree metric theory."""
    print("\n" + "=" * 70)
    print("APPLICATION 3: Hierarchical Clustering Validation")
    print("=" * 70)

    # Test whether a given distance matrix admits a perfect tree representation
    print("\nTest 1: Perfect tree metric")
    D1 = np.array([
        [0, 2, 4, 4],
        [2, 0, 4, 4],
        [4, 4, 0, 2],
        [4, 4, 2, 0]
    ], dtype=float)
    print(f"  Four-point condition: {is_four_point(D1)}")
    print(f"  → Perfect hierarchical clustering exists")

    T1 = cherry_picking_reconstruct(D1)
    print(f"  Cherry pairs: {T1.cherry_pairs()}")
    D1_recon = distance_matrix(T1)
    print(f"  Reconstruction error: {np.max(np.abs(D1 - D1_recon)):.10f}")

    print(f"\nTest 2: Non-tree metric (violates four-point)")
    D2 = np.array([
        [0, 1, 2, 3],
        [1, 0, 3, 2],
        [2, 3, 0, 1],
        [3, 2, 1, 0]
    ], dtype=float)
    print(f"  Four-point condition: {is_four_point(D2)}")
    print(f"  → No perfect hierarchical clustering")

    # Find the four-point violation
    for i in range(4):
        for j in range(i+1, 4):
            for k in range(j+1, 4):
                for l in range(k+1, 4):
                    s1 = D2[i][j] + D2[k][l]
                    s2 = D2[i][k] + D2[j][l]
                    s3 = D2[i][l] + D2[j][k]
                    sums = sorted([s1, s2, s3])
                    if abs(sums[1] - sums[2]) > 1e-10:
                        print(f"  Violation at ({i},{j},{k},{l}): "
                              f"sums = {s1:.0f}, {s2:.0f}, {s3:.0f}")

    print(f"\nTest 3: Near-tree metric (small four-point violation)")
    eps = 0.1
    D3 = D1.copy()
    D3[0][2] += eps
    D3[2][0] += eps
    print(f"  Perturbation ε = {eps}")
    print(f"  Four-point condition: {is_four_point(D3)}")
    T3 = cherry_picking_reconstruct(D3)
    print(f"  Approximate cherry pairs: {T3.cherry_pairs()}")
    print(f"  Same as original: {set(T3.cherry_pairs()) == set(T1.cherry_pairs())}")


if __name__ == "__main__":
    application_phylogenetics()
    application_network_topology()
    application_clustering_validation()


"""
Demonstration of Cherry Pair Metric Invariance

This script provides concrete numerical demonstrations of the key theorems:
1. Cherry pairs are determined by the distance matrix
2. The four-point condition characterizes tree metrics
3. Noisy perturbations preserve cherry structure under separation margins
4. Cherry-picking reconstruction recovers the correct tree
"""

import numpy as np
from algorithms import (
    TreeNode, distance_matrix, is_four_point, detect_cherry_pair,
    is_cherry_pair_metric, cherry_picking_reconstruct,
    cherry_separation_margin, noisy_cherry_detection, pendant_length,
    gromov_product
)


def demo_cherry_invariance():
    """Demonstrate that cherry pairs are invariant across realizations."""
    print("=" * 70)
    print("DEMO 1: Cherry Pair Metric Invariance")
    print("=" * 70)

    # Create a tree: ((0,1), (2,3))
    tree = TreeNode(
        left=TreeNode(
            left=TreeNode(label=0), right=TreeNode(label=1),
            left_weight=2.0, right_weight=3.0
        ),
        right=TreeNode(
            left=TreeNode(label=2), right=TreeNode(label=3),
            left_weight=1.0, right_weight=4.0
        ),
        left_weight=1.0, right_weight=2.0
    )

    D = distance_matrix(tree)
    print("\nTree structure: ((leaf 0, leaf 1), (leaf 2, leaf 3))")
    print(f"Edge weights: left cherry (2,3), right cherry (1,4), internal (1,2)")
    print(f"\nDistance matrix D:")
    for i in range(4):
        print(f"  {D[i]}")

    print(f"\nFour-point condition satisfied: {is_four_point(D)}")
    print(f"Structural cherry pairs: {tree.cherry_pairs()}")

    # Check IsCherryPair (metric condition) for all pairs
    print("\nMetric cherry condition (IsCherryPair) for each pair:")
    for a in range(4):
        for b in range(a + 1, 4):
            metric = is_cherry_pair_metric(D, a, b)
            structural = (min(a, b), max(a, b)) in tree.cherry_pairs()
            marker = " ← CHERRY" if structural else ""
            print(f"  ({a},{b}): IsCherryPair = {metric}{marker}")

    # Reconstruct a different tree from the same D
    T2 = cherry_picking_reconstruct(D)
    D2 = distance_matrix(T2)
    print(f"\nReconstructed tree cherry pairs: {T2.cherry_pairs()}")
    print(f"Distance matrices match: {np.allclose(D, D2)}")
    print(f"Cherry pairs preserved: {set(tree.cherry_pairs()) == set(T2.cherry_pairs())}")


def demo_splits_vs_cherries():
    """Demonstrate that IsCherryPair detects splits, not cherries."""
    print("\n" + "=" * 70)
    print("DEMO 2: IsCherryPair Detects Splits, Not Cherries")
    print("=" * 70)

    # Caterpillar tree: 0 -- 1 -- root -- 1 -- 1 -- 1 -- 2 -- 1 -- 3
    caterpillar = TreeNode(
        left=TreeNode(label=0),
        right=TreeNode(
            left=TreeNode(label=1),
            right=TreeNode(
                left=TreeNode(label=2), right=TreeNode(label=3),
                left_weight=1.0, right_weight=1.0
            ),
            left_weight=1.0, right_weight=1.0
        ),
        left_weight=1.0, right_weight=1.0
    )

    D = distance_matrix(caterpillar)
    print("\nCaterpillar tree: 0 - root - (1 - (2, 3))")
    print(f"Distance matrix:")
    for i in range(4):
        print(f"  {D[i]}")

    print(f"\nStructural cherry pairs: {caterpillar.cherry_pairs()}")
    print(f"Only (2,3) is a true cherry — they share a parent.\n")

    print("Metric cherry condition for each pair:")
    for a in range(4):
        for b in range(a + 1, 4):
            metric = is_cherry_pair_metric(D, a, b)
            structural = (min(a, b), max(a, b)) in caterpillar.cherry_pairs()
            note = ""
            if metric and not structural:
                note = " ← SPLIT but NOT a cherry!"
            elif metric and structural:
                note = " ← TRUE cherry"
            print(f"  ({a},{b}): IsCherryPair = {metric}{note}")

    print("\nKey insight: (0,1) satisfies IsCherryPair because the split")
    print("{0,1} | {2,3} exists in the tree. But 0 and 1 don't share a parent!")
    print("This is why IsCherryPair alone cannot characterize cherries.")


def demo_gromov_product():
    """Demonstrate cherry detection via Gromov product maximization."""
    print("\n" + "=" * 70)
    print("DEMO 3: Gromov Product Cherry Detection")
    print("=" * 70)

    # Same caterpillar
    caterpillar = TreeNode(
        left=TreeNode(label=0),
        right=TreeNode(
            left=TreeNode(label=1),
            right=TreeNode(
                left=TreeNode(label=2), right=TreeNode(label=3),
                left_weight=1.0, right_weight=1.0
            ),
            left_weight=1.0, right_weight=1.0
        ),
        left_weight=1.0, right_weight=1.0
    )

    D = distance_matrix(caterpillar)

    print("\nGromov products (i|j)_r for different reference points r:")
    for r in range(4):
        print(f"\n  Reference r = {r}:")
        for i in range(4):
            for j in range(i + 1, 4):
                if i == r or j == r:
                    continue
                gp = gromov_product(D, i, j, r)
                print(f"    ({i}|{j})_{r} = {gp:.1f}")

    detected = detect_cherry_pair(D)
    print(f"\nDetected cherry (max Gromov product): {detected}")
    print(f"True cherry: {caterpillar.cherry_pairs()}")
    print(f"Correct: {(min(*detected), max(*detected)) in caterpillar.cherry_pairs()}")


def demo_noisy_stability():
    """Demonstrate noisy cherry stability."""
    print("\n" + "=" * 70)
    print("DEMO 4: Noisy Cherry Stability")
    print("=" * 70)

    # Create a tree with well-separated cherries
    tree = TreeNode(
        left=TreeNode(
            left=TreeNode(label=0), right=TreeNode(label=1),
            left_weight=1.0, right_weight=1.0
        ),
        right=TreeNode(
            left=TreeNode(label=2), right=TreeNode(label=3),
            left_weight=1.0, right_weight=1.0
        ),
        left_weight=2.0, right_weight=2.0
    )

    D0 = distance_matrix(tree)
    cherries = tree.cherry_pairs()
    margin = cherry_separation_margin(D0, cherries)

    print(f"\nTrue tree metric D₀ (balanced tree with internal edge = 2):")
    for i in range(4):
        print(f"  {D0[i]}")
    print(f"\nTrue cherry pairs: {cherries}")
    print(f"Separation margin δ = {margin:.4f}")
    print(f"Maximum safe perturbation: ε < δ/4 = {margin/4:.4f}")

    # Test with increasing noise levels
    np.random.seed(42)
    print(f"\nPerturbation analysis:")
    print(f"{'ε':>8} | {'Max 4-pt dev (cherry)':>22} | {'Min 4-pt dev (non-cherry)':>26} | {'Correct?':>10}")
    print("-" * 75)

    for eps in [0.01, 0.05, 0.1, 0.2, 0.5, 1.0, 1.5, 2.0]:
        noise = np.random.uniform(-eps, eps, (4, 4))
        noise = (noise + noise.T) / 2
        np.fill_diagonal(noise, 0)
        D = D0 + noise

        # Check cherry deviations
        max_cherry_dev = 0
        min_noncherry_dev = np.inf
        for a in range(4):
            for b in range(a + 1, 4):
                is_cherry = (a, b) in cherries
                for k in range(4):
                    if k == a or k == b:
                        continue
                    for l in range(4):
                        if l == a or l == b:
                            continue
                        dev = abs(D[a][k] + D[b][l] - D[a][l] - D[b][k])
                        if is_cherry:
                            max_cherry_dev = max(max_cherry_dev, dev)
                        else:
                            if dev > 0:
                                min_noncherry_dev = min(min_noncherry_dev, dev)

        separated = max_cherry_dev < min_noncherry_dev
        print(f"{eps:8.3f} | {max_cherry_dev:22.4f} | {min_noncherry_dev:26.4f} | {'✓' if separated else '✗':>10}")


def demo_reconstruction():
    """Demonstrate cherry-picking reconstruction."""
    print("\n" + "=" * 70)
    print("DEMO 5: Cherry-Picking Reconstruction")
    print("=" * 70)

    for n_leaves in [3, 4, 5, 6, 8]:
        # Build a random tree
        tree = _random_tree(list(range(n_leaves)))
        D = distance_matrix(tree)

        is_fp = is_four_point(D)
        T_recon = cherry_picking_reconstruct(D)
        D_recon = distance_matrix(T_recon)
        error = np.max(np.abs(D - D_recon))

        print(f"\nn = {n_leaves}: ", end="")
        print(f"Four-point: {is_fp}, ", end="")
        print(f"Recon error: {error:.2e}, ", end="")
        print(f"Original cherries: {tree.cherry_pairs()}, ", end="")
        print(f"Reconstructed cherries: {T_recon.cherry_pairs()}")
        if set(tree.cherry_pairs()) == set(T_recon.cherry_pairs()):
            print(f"  → Cherry pairs MATCH ✓")
        else:
            print(f"  → Cherry pairs differ (different rooting)")


def _random_tree(labels: list, rng=None) -> TreeNode:
    """Build a random binary tree with given leaf labels."""
    if rng is None:
        rng = np.random.RandomState(42)
    if len(labels) == 1:
        return TreeNode(label=labels[0])
    if len(labels) == 2:
        return TreeNode(
            left=TreeNode(label=labels[0]),
            right=TreeNode(label=labels[1]),
            left_weight=rng.uniform(0.5, 3.0),
            right_weight=rng.uniform(0.5, 3.0)
        )
    split = rng.randint(1, len(labels))
    rng.shuffle(labels)
    return TreeNode(
        left=_random_tree(labels[:split], rng),
        right=_random_tree(labels[split:], rng),
        left_weight=rng.uniform(0.5, 3.0),
        right_weight=rng.uniform(0.5, 3.0)
    )


if __name__ == "__main__":
    demo_cherry_invariance()
    demo_splits_vs_cherries()
    demo_gromov_product()
    demo_noisy_stability()
    demo_reconstruction()


"""
Visualizations for Cherry Pair Metric Invariance
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import base64
import io


def fig_to_base64(fig):
    buf = io.BytesIO()
    fig.savefig(buf, format='png', dpi=150, bbox_inches='tight')
    buf.seek(0)
    return "data:image/png;base64," + base64.b64encode(buf.read()).decode('utf-8')


def viz_tree_and_matrix():
    """Visualize a tree and its distance matrix side by side."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Draw tree
    ax = axes[0]
    ax.set_xlim(-1, 7)
    ax.set_ylim(-0.5, 3.5)
    ax.set_aspect('equal')

    # Tree: ((0,1), (2,3))
    # Internal nodes
    root = (3, 3)
    left_int = (1.5, 2)
    right_int = (4.5, 2)

    # Leaves
    leaf_pos = {0: (0.5, 0.5), 1: (2.5, 0.5), 2: (3.5, 0.5), 3: (5.5, 0.5)}

    # Draw edges
    edges = [
        (root, left_int, "1.0"),
        (root, right_int, "2.0"),
        (left_int, leaf_pos[0], "2.0"),
        (left_int, leaf_pos[1], "3.0"),
        (right_int, leaf_pos[2], "1.0"),
        (right_int, leaf_pos[3], "4.0"),
    ]

    for (x1, y1), (x2, y2), w in edges:
        ax.plot([x1, x2], [y1, y2], 'k-', linewidth=2)
        mx, my = (x1 + x2) / 2, (y1 + y2) / 2
        ax.annotate(w, (mx, my), fontsize=10, ha='center',
                    bbox=dict(boxstyle='round,pad=0.2', facecolor='lightyellow'))

    # Draw nodes
    ax.plot(*root, 'ko', markersize=8)
    ax.plot(*left_int, 'ko', markersize=8)
    ax.plot(*right_int, 'ko', markersize=8)

    colors = ['#e74c3c', '#3498db', '#2ecc71', '#f39c12']
    labels = ['Leaf 0', 'Leaf 1', 'Leaf 2', 'Leaf 3']
    for i in range(4):
        ax.plot(*leaf_pos[i], 'o', color=colors[i], markersize=12, zorder=5)
        ax.annotate(labels[i], leaf_pos[i], textcoords="offset points",
                    xytext=(0, -18), ha='center', fontsize=9)

    # Highlight cherry pairs
    for pair, pos1, pos2, color in [
        ((0, 1), leaf_pos[0], leaf_pos[1], '#e74c3c'),
        ((2, 3), leaf_pos[2], leaf_pos[3], '#2ecc71')
    ]:
        rect = mpatches.FancyBboxPatch(
            (min(pos1[0], pos2[0]) - 0.3, -0.1),
            abs(pos1[0] - pos2[0]) + 0.6, 1.0,
            boxstyle="round,pad=0.1", alpha=0.15, facecolor=color, edgecolor=color,
            linewidth=2, linestyle='--')
        ax.add_patch(rect)

    ax.set_title("Tree with Cherry Pairs Highlighted", fontsize=13, fontweight='bold')
    ax.axis('off')

    # Distance matrix
    ax = axes[1]
    D = np.array([
        [0, 5, 6, 9],
        [5, 0, 7, 10],
        [6, 7, 0, 5],
        [7, 10, 5, 0]
    ])

    im = ax.imshow(D, cmap='YlOrRd', aspect='equal')
    for i in range(4):
        for j in range(4):
            ax.text(j, i, f'{D[i][j]:.0f}', ha='center', va='center',
                    fontsize=14, fontweight='bold',
                    color='white' if D[i][j] > 6 else 'black')

    ax.set_xticks(range(4))
    ax.set_yticks(range(4))
    ax.set_xticklabels(labels, fontsize=10)
    ax.set_yticklabels(labels, fontsize=10)
    ax.set_title("Distance Matrix D", fontsize=13, fontweight='bold')
    plt.colorbar(im, ax=ax, shrink=0.8)

    plt.suptitle("Cherry pairs are determined by the distance matrix alone",
                 fontsize=14, y=1.02)
    plt.tight_layout()

    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_tree_matrix.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


def viz_noisy_stability():
    """Visualize noisy cherry stability: four-point deviation vs noise level."""
    fig, ax = plt.subplots(figsize=(10, 6))

    # True tree metric: balanced ((0,1),(2,3)) with edge weights 1,1,2,2,1,1
    D0 = np.array([
        [0, 2, 6, 6],
        [2, 0, 6, 6],
        [6, 6, 0, 2],
        [6, 6, 2, 0]
    ], dtype=float)

    epsilon_values = np.linspace(0, 2.5, 50)
    n_trials = 100
    np.random.seed(42)

    cherry_devs_mean = []
    cherry_devs_max = []
    noncherry_devs_mean = []
    noncherry_devs_min = []

    for eps in epsilon_values:
        trial_cherry_max = []
        trial_noncherry_min = []

        for _ in range(n_trials):
            noise = np.random.uniform(-eps, eps, (4, 4))
            noise = (noise + noise.T) / 2
            np.fill_diagonal(noise, 0)
            D = D0 + noise

            # Cherry pair (0,1): check deviation with k=2,l=3
            dev_01 = abs(D[0][2] + D[1][3] - D[0][3] - D[1][2])
            dev_23 = abs(D[2][0] + D[3][1] - D[2][1] - D[3][0])
            cherry_max = max(dev_01, dev_23)

            # Non-cherry pair (0,2): check deviation with k=1,l=3
            dev_02 = abs(D[0][1] + D[2][3] - D[0][3] - D[2][1])
            dev_03 = abs(D[0][1] + D[3][2] - D[0][2] - D[3][1])
            dev_12 = abs(D[1][0] + D[2][3] - D[1][3] - D[2][0])
            dev_13 = abs(D[1][0] + D[3][2] - D[1][2] - D[3][0])
            noncherry_min = min(dev_02, dev_03, dev_12, dev_13)

            trial_cherry_max.append(cherry_max)
            trial_noncherry_min.append(noncherry_min)

        cherry_devs_mean.append(np.mean(trial_cherry_max))
        cherry_devs_max.append(np.percentile(trial_cherry_max, 95))
        noncherry_devs_mean.append(np.mean(trial_noncherry_min))
        noncherry_devs_min.append(np.percentile(trial_noncherry_min, 5))

    ax.fill_between(epsilon_values, 0, cherry_devs_max, alpha=0.2, color='green',
                    label='Cherry deviation (95th pct)')
    ax.plot(epsilon_values, cherry_devs_mean, 'g-', linewidth=2,
            label='Cherry deviation (mean)')
    ax.plot(epsilon_values, [4 * e for e in epsilon_values], 'g--', linewidth=1,
            label='Theoretical bound: 4ε')

    ax.fill_between(epsilon_values, noncherry_devs_min,
                    [max(noncherry_devs_mean) * 1.2] * len(epsilon_values),
                    alpha=0.2, color='red')
    ax.plot(epsilon_values, noncherry_devs_mean, 'r-', linewidth=2,
            label='Non-cherry deviation (mean)')
    ax.plot(epsilon_values, noncherry_devs_min, 'r--', linewidth=1,
            label='Non-cherry deviation (5th pct)')

    # Separation region
    sep_margin = 8.0
    ax.axhline(y=sep_margin, color='purple', linestyle=':', alpha=0.5,
               label=f'Separation margin δ = {sep_margin}')
    ax.axvline(x=sep_margin / 4, color='orange', linestyle=':', alpha=0.5,
               label=f'Critical ε = δ/4 = {sep_margin/4}')

    ax.set_xlabel('Perturbation magnitude ε', fontsize=12)
    ax.set_ylabel('Four-point deviation', fontsize=12)
    ax.set_title('Noisy Cherry Stability: Separation Under Perturbation',
                 fontsize=14, fontweight='bold')
    ax.legend(fontsize=9, loc='upper left')
    ax.set_ylim(0, 12)
    ax.grid(True, alpha=0.3)

    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_noisy_stability.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


def viz_gromov_products():
    """Visualize Gromov products showing cherry detection."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Caterpillar tree
    D_cat = np.array([
        [0, 3, 4, 4],
        [3, 0, 3, 3],
        [4, 3, 0, 2],
        [4, 3, 2, 0]
    ], dtype=float)

    # Balanced tree
    D_bal = np.array([
        [0, 2, 6, 6],
        [2, 0, 6, 6],
        [6, 6, 0, 2],
        [6, 6, 2, 0]
    ], dtype=float)

    for idx, (D, title) in enumerate([(D_cat, "Caterpillar Tree"),
                                       (D_bal, "Balanced Tree")]):
        ax = axes[idx]
        pairs = [(i, j) for i in range(4) for j in range(i + 1, 4)]
        pair_labels = [f"({i},{j})" for i, j in pairs]

        # Compute Gromov products for each reference point
        bar_width = 0.2
        x = np.arange(len(pairs))

        for r_idx, r in enumerate([0, 1, 2, 3]):
            gps = []
            for i, j in pairs:
                if i == r or j == r:
                    gps.append(0)
                else:
                    gps.append((D[r][i] + D[r][j] - D[i][j]) / 2)
            offset = (r_idx - 1.5) * bar_width
            bars = ax.bar(x + offset, gps, bar_width, label=f'r={r}',
                          alpha=0.7)

        ax.set_xticks(x)
        ax.set_xticklabels(pair_labels, fontsize=10)
        ax.set_ylabel('Gromov Product', fontsize=11)
        ax.set_title(title, fontsize=13, fontweight='bold')
        ax.legend(fontsize=9)
        ax.grid(True, axis='y', alpha=0.3)

        # Mark the maximum (cherry)
        max_gp = 0
        max_pair = ""
        for r in range(4):
            for i, j in pairs:
                if i == r or j == r:
                    continue
                gp = (D[r][i] + D[r][j] - D[i][j]) / 2
                if gp > max_gp:
                    max_gp = gp
                    max_pair = f"({i},{j})"
        ax.annotate(f'Cherry: {max_pair}', xy=(0.95, 0.95),
                    xycoords='axes fraction', ha='right', va='top',
                    fontsize=11, fontweight='bold',
                    bbox=dict(boxstyle='round', facecolor='lightyellow'))

    plt.suptitle("Gromov Product Maximization Identifies Cherry Pairs",
                 fontsize=14, y=1.02)
    plt.tight_layout()

    result = fig_to_base64(fig)
    fig.savefig('/workspace/request-project/viz_gromov.png', dpi=150, bbox_inches='tight')
    plt.close(fig)
    return result


if __name__ == "__main__":
    b64_1 = viz_tree_and_matrix()
    print(f"Tree/matrix visualization: {len(b64_1)} chars")
    b64_2 = viz_noisy_stability()
    print(f"Noisy stability visualization: {len(b64_2)} chars")
    b64_3 = viz_gromov_products()
    print(f"Gromov products visualization: {len(b64_3)} chars")
