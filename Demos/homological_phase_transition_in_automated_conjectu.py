"""
Applications of Proof-Theoretic Topology

Demonstrates real-world applications of semantic threshold graph analysis:
1. Automated theorem prover difficulty prediction
2. Knowledge base fragmentation analysis
3. Research frontier detection
"""

import random
from typing import List, Set, Dict, Tuple
from algorithms import (
    symm_diff_card, pairwise_distances, threshold_graph_edges,
    connected_components, cycle_rank, transition_profile,
    find_transition_thresholds, hardness_variance_profile
)


def generate_theorem_family(
    n_easy: int = 10,
    n_medium: int = 8,
    n_hard: int = 5,
    feature_universe: int = 20,
    seed: int = 42
) -> Tuple[List[Set[int]], List[float], List[str]]:
    """Generate a synthetic theorem family with known difficulty structure.

    Creates three clusters of theorems:
    - Easy: tightly clustered around a common core, low hardness
    - Medium: moderate spread, medium hardness
    - Hard: widely scattered, high hardness

    Args:
        n_easy: Number of easy theorems.
        n_medium: Number of medium theorems.
        n_hard: Number of hard theorems.
        feature_universe: Size of the feature alphabet.
        seed: Random seed for reproducibility.

    Returns:
        Tuple of (feature_sets, hardness_values, labels).
    """
    rng = random.Random(seed)

    features = []
    hardness = []
    labels = []

    # Easy cluster: core features {0,...,5}, perturb 1-2 features
    easy_core = set(range(6))
    for _ in range(n_easy):
        f = set(easy_core)
        # Remove 0-1 features
        for x in list(f):
            if rng.random() < 0.15:
                f.discard(x)
        # Add 0-1 random features
        for _ in range(rng.randint(0, 1)):
            f.add(rng.randint(6, feature_universe - 1))
        features.append(f)
        hardness.append(rng.uniform(1, 3))
        labels.append('easy')

    # Medium cluster: core features {3,...,10}, perturb 2-3 features
    medium_core = set(range(3, 11))
    for _ in range(n_medium):
        f = set(medium_core)
        for x in list(f):
            if rng.random() < 0.25:
                f.discard(x)
        for _ in range(rng.randint(0, 3)):
            f.add(rng.randint(0, feature_universe - 1))
        features.append(f)
        hardness.append(rng.uniform(4, 7))
        labels.append('medium')

    # Hard cluster: sparse, diverse features
    for _ in range(n_hard):
        size = rng.randint(3, 8)
        f = set(rng.sample(range(feature_universe), size))
        features.append(f)
        hardness.append(rng.uniform(8, 15))
        labels.append('hard')

    return features, hardness, labels


def difficulty_prediction_demo():
    """Demonstrate difficulty prediction via topological analysis.

    Shows that the cycle-rank transition window correlates with the
    boundary between easy and hard theorem clusters.
    """
    print("=" * 70)
    print("APPLICATION 1: Automated Theorem Prover Difficulty Prediction")
    print("=" * 70)

    features, hardness, labels = generate_theorem_family(seed=42)
    n = len(features)

    print(f"\nGenerated {n} synthetic theorems:")
    print(f"  Easy:   {labels.count('easy')}")
    print(f"  Medium: {labels.count('medium')}")
    print(f"  Hard:   {labels.count('hard')}")

    # Compute transition profile
    thresholds = list(range(25))
    profile = transition_profile(features, thresholds)

    print("\nTransition Profile:")
    print(f"{'ε':>4} {'Components':>11} {'Edges':>6} {'Cycle Rank':>11}")
    for p in profile:
        marker = ""
        if p['components'] == 1 and (
            profile[max(0, thresholds.index(p['epsilon']) - 1)]['components'] > 1
            if p['epsilon'] > 0 else False
        ):
            marker = " ← CONNECTED"
        if p['cycle_rank'] > 0 and (
            profile[max(0, thresholds.index(p['epsilon']) - 1)]['cycle_rank'] <= 0
            if p['epsilon'] > 0 else False
        ):
            marker = " ← CYCLES APPEAR"
        print(f"{p['epsilon']:4d} {p['components']:11d} {p['edges']:6d} {p['cycle_rank']:11d}{marker}")

    # Hardness-variance analysis
    hv_profile = hardness_variance_profile(features, hardness, thresholds)

    print("\nHardness Variance vs Cycle Rank:")
    print(f"{'ε':>4} {'H-Variance':>11} {'Cycle Rank':>11}")
    for hv in hv_profile:
        print(f"{hv['epsilon']:4d} {hv['hardness_variance']:11.2f} {hv['cycle_rank']:11d}")

    transitions = find_transition_thresholds(features)
    print(f"\nKey transitions: {transitions}")
    print("\nInterpretation: The cycle-rank transition window marks the regime")
    print("where easy and hard theorems become topologically entangled.")


def knowledge_base_fragmentation_demo():
    """Demonstrate knowledge base fragmentation analysis.

    Shows how different mathematical subfields appear as disconnected
    components at low thresholds and merge at higher thresholds.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 2: Knowledge Base Fragmentation Analysis")
    print("=" * 70)

    # Simulate three mathematical subfields
    # Algebra: features 0-7
    # Analysis: features 5-12
    # Combinatorics: features 15-22

    algebra = [
        {0, 1, 2, 3, 4, 5},
        {0, 1, 2, 3, 5, 6},
        {0, 1, 3, 4, 5, 7},
        {0, 2, 3, 4, 6, 7},
    ]

    analysis = [
        {5, 6, 7, 8, 9, 10},
        {5, 6, 8, 9, 10, 11},
        {5, 7, 8, 9, 11, 12},
        {6, 7, 8, 10, 11, 12},
    ]

    combinatorics = [
        {15, 16, 17, 18, 19, 20},
        {15, 16, 17, 18, 20, 21},
        {15, 16, 18, 19, 20, 22},
        {16, 17, 18, 19, 21, 22},
    ]

    features = algebra + analysis + combinatorics
    field_labels = ['ALG'] * 4 + ['ANA'] * 4 + ['COMB'] * 4

    print(f"\nSimulated fields: Algebra(4), Analysis(4), Combinatorics(4)")

    thresholds = list(range(25))
    profile = transition_profile(features, thresholds)

    print("\nFragmentation Profile:")
    print(f"{'ε':>4} {'Components':>11} {'Edges':>6} {'Cycle Rank':>11}")
    for p in profile:
        print(f"{p['epsilon']:4d} {p['components']:11d} {p['edges']:6d} {p['cycle_rank']:11d}")

    transitions = find_transition_thresholds(features)
    print(f"\nKey transitions: {transitions}")

    # Show component structure at different thresholds
    D = pairwise_distances(features)
    for eps in [2, 6, 10, 14]:
        edges = threshold_graph_edges(D, eps)
        comps = connected_components(len(features), edges)
        comp_labels = []
        for comp in comps:
            comp_fields = [field_labels[i] for i in comp]
            comp_labels.append(f"{{{', '.join(comp_fields)}}}")
        print(f"\nε={eps}: {len(comps)} components: {', '.join(comp_labels)}")


def research_frontier_detection_demo():
    """Demonstrate research frontier detection.

    Shows how the mesoscopic cycle window identifies the "frontier"
    where theorems are neither trivially related nor completely independent.
    """
    print("\n" + "=" * 70)
    print("APPLICATION 3: Research Frontier Detection")
    print("=" * 70)

    # Create a family with a clear frontier structure
    # Core: well-understood theorems (tight cluster)
    core = [set(range(8)) - {i} for i in range(5)]  # 5 theorems, each missing one feature

    # Frontier: partially connected to core and to each other
    frontier = [
        {0, 1, 2, 10, 11, 12},      # bridges core and unknown
        {3, 4, 5, 10, 13, 14},
        {0, 5, 6, 11, 13, 15},
        {2, 4, 7, 12, 14, 15},
    ]

    # Terra incognita: far from everything
    unknown = [
        {20, 21, 22, 23, 24},
        {20, 21, 25, 26, 27},
        {22, 23, 25, 28, 29},
    ]

    features = core + frontier + unknown
    region_labels = ['CORE'] * 5 + ['FRONTIER'] * 4 + ['UNKNOWN'] * 3

    print(f"\nStatement regions: Core(5), Frontier(4), Unknown(3)")

    thresholds = list(range(30))
    profile = transition_profile(features, thresholds)

    print("\nTopological Evolution:")
    print(f"{'ε':>4} {'Components':>11} {'Edges':>6} {'Cycle Rank':>11} {'Phase':>15}")
    for p in profile:
        if p['components'] > 2:
            phase = "FRAGMENTED"
        elif p['cycle_rank'] == 0:
            phase = "TREE-LIKE"
        elif p['cycle_rank'] < 5:
            phase = "MESOSCOPIC"
        else:
            phase = "SATURATED"
        print(f"{p['epsilon']:4d} {p['components']:11d} {p['edges']:6d} {p['cycle_rank']:11d} {phase:>15}")

    transitions = find_transition_thresholds(features)
    print(f"\nKey transitions: {transitions}")

    # Identify frontier statements
    D = pairwise_distances(features)
    n = len(features)
    cycle_threshold = transitions['cycle_threshold']

    if cycle_threshold >= 0:
        edges = threshold_graph_edges(D, cycle_threshold)
        edge_count = [0] * n
        for i, j in edges:
            edge_count[i] += 1
            edge_count[j] += 1

        print(f"\nAt cycle threshold ε={cycle_threshold}, degree distribution:")
        for i in range(n):
            print(f"  Statement {i} ({region_labels[i]:>8}): degree {edge_count[i]}")

        print("\nInterpretation: Frontier statements typically have moderate degree,")
        print("connecting the well-understood core to the unknown territory.")


if __name__ == "__main__":
    difficulty_prediction_demo()
    knowledge_base_fragmentation_demo()
    research_frontier_detection_demo()


#!/usr/bin/env python3
"""
Proof-Theoretic Topology: Phase Transition Demonstration

Generates synthetic theorem-like feature spaces, builds the threshold filtration,
and visualizes the topological phase transition from fragmented to saturated phases
through the mesoscopic cycle window.

Two synthetic families:
1. Clustered-core family: two tight clusters with a separation gap
2. Bridged family: clusters connected by intermediate bridge statements

Usage:
    python demo.py
    # Generates plots saved as PNG files and prints transition profiles.
"""

import random
from typing import List, Set, Tuple, Dict
from collections import deque


# ──────────────────────────────────────────────────────────────────────────────
# Core algorithms (self-contained)
# ──────────────────────────────────────────────────────────────────────────────

def symm_diff_card(A: Set[int], B: Set[int]) -> int:
    return len(A - B) + len(B - A)


def pairwise_distances(feature_sets: List[Set[int]]) -> List[List[int]]:
    n = len(feature_sets)
    D = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(i + 1, n):
            d = symm_diff_card(feature_sets[i], feature_sets[j])
            D[i][j] = d
            D[j][i] = d
    return D


def threshold_graph_edges(D: List[List[int]], epsilon: int) -> List[Tuple[int, int]]:
    n = len(D)
    return [(i, j) for i in range(n) for j in range(i + 1, n) if D[i][j] <= epsilon]


def connected_components(n: int, edges: List[Tuple[int, int]]) -> int:
    adj = {i: [] for i in range(n)}
    for i, j in edges:
        adj[i].append(j)
        adj[j].append(i)
    visited = [False] * n
    count = 0
    for start in range(n):
        if visited[start]:
            continue
        count += 1
        queue = deque([start])
        visited[start] = True
        while queue:
            v = queue.popleft()
            for w in adj[v]:
                if not visited[w]:
                    visited[w] = True
                    queue.append(w)
    return count


def transition_profile(feature_sets: List[Set[int]], thresholds: List[int]):
    n = len(feature_sets)
    D = pairwise_distances(feature_sets)
    results = []
    for eps in thresholds:
        edges = threshold_graph_edges(D, eps)
        n_edges = len(edges)
        n_comps = connected_components(n, edges)
        cr = n_edges - n + n_comps
        results.append((eps, n_comps, n_edges, cr))
    return results


# ──────────────────────────────────────────────────────────────────────────────
# Synthetic families
# ──────────────────────────────────────────────────────────────────────────────

def generate_clustered_core_family(seed: int = 42) -> Tuple[List[Set[int]], str]:
    """Two well-separated clusters with tight internal structure."""
    rng = random.Random(seed)

    features = []
    # Cluster A: features from {0,...,7}, core = {0,1,2,3,4,5}
    core_A = {0, 1, 2, 3, 4, 5}
    for _ in range(8):
        f = set(core_A)
        # Perturb: remove 0-1, add 0-1 from {6,7}
        if rng.random() < 0.4:
            f.discard(rng.choice(list(f)))
        if rng.random() < 0.4:
            f.add(rng.choice([6, 7]))
        features.append(f)

    # Cluster B: features from {20,...,27}, core = {20,21,22,23,24,25}
    core_B = {20, 21, 22, 23, 24, 25}
    for _ in range(8):
        f = set(core_B)
        if rng.random() < 0.4:
            f.discard(rng.choice(list(f)))
        if rng.random() < 0.4:
            f.add(rng.choice([26, 27]))
        features.append(f)

    return features, "Clustered-Core Family (Two Separated Clusters)"


def generate_bridged_family(seed: int = 123) -> Tuple[List[Set[int]], str]:
    """Two clusters connected by bridge statements."""
    rng = random.Random(seed)

    features = []
    # Cluster A: features from {0,...,7}
    core_A = {0, 1, 2, 3, 4, 5}
    for _ in range(6):
        f = set(core_A)
        if rng.random() < 0.3:
            f.discard(rng.choice(list(f)))
        if rng.random() < 0.3:
            f.add(rng.choice([6, 7]))
        features.append(f)

    # Bridge statements: mix features from both clusters
    for _ in range(4):
        f = set()
        # Take some from cluster A range
        for x in rng.sample(range(8), rng.randint(2, 4)):
            f.add(x)
        # Take some from cluster B range
        for x in rng.sample(range(15, 23), rng.randint(2, 4)):
            f.add(x)
        features.append(f)

    # Cluster B: features from {15,...,22}
    core_B = {15, 16, 17, 18, 19, 20}
    for _ in range(6):
        f = set(core_B)
        if rng.random() < 0.3:
            f.discard(rng.choice(list(f)))
        if rng.random() < 0.3:
            f.add(rng.choice([21, 22]))
        features.append(f)

    return features, "Bridged Family (Clusters with Bridge Statements)"


# ──────────────────────────────────────────────────────────────────────────────
# Visualization
# ──────────────────────────────────────────────────────────────────────────────

def plot_transition_profile(
    profile: List[Tuple[int, int, int, int]],
    title: str,
    filename: str,
    n_vertices: int
):
    """Plot connected components, edge count, and cycle rank vs threshold."""
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt

        epsilons = [p[0] for p in profile]
        components = [p[1] for p in profile]
        edges = [p[2] for p in profile]
        cycle_ranks = [p[3] for p in profile]

        fig, axes = plt.subplots(3, 1, figsize=(10, 10), sharex=True)
        fig.suptitle(title, fontsize=14, fontweight='bold')

        # Connected components
        ax = axes[0]
        ax.plot(epsilons, components, 'b-o', markersize=4, linewidth=1.5)
        ax.set_ylabel('Connected Components', fontsize=11)
        ax.axhline(y=1, color='gray', linestyle='--', alpha=0.5, label='Connected')
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

        # Edge count
        ax = axes[1]
        max_edges = n_vertices * (n_vertices - 1) // 2
        ax.plot(epsilons, edges, 'g-o', markersize=4, linewidth=1.5)
        ax.axhline(y=n_vertices, color='orange', linestyle='--', alpha=0.5,
                    label=f'|V| = {n_vertices}')
        ax.axhline(y=max_edges, color='red', linestyle='--', alpha=0.5,
                    label=f'Complete = {max_edges}')
        ax.set_ylabel('Edge Count', fontsize=11)
        ax.legend(fontsize=9)
        ax.grid(True, alpha=0.3)

        # Cycle rank
        ax = axes[2]
        ax.plot(epsilons, cycle_ranks, 'r-o', markersize=4, linewidth=1.5)
        ax.fill_between(epsilons, 0, cycle_ranks, alpha=0.15, color='red')
        ax.axhline(y=0, color='gray', linestyle='--', alpha=0.5)
        ax.set_ylabel('Cycle Rank (β₁)', fontsize=11)
        ax.set_xlabel('Threshold ε', fontsize=11)
        ax.grid(True, alpha=0.3)

        # Highlight mesoscopic window
        cycle_start = None
        for i, cr in enumerate(cycle_ranks):
            if cr > 0 and cycle_start is None:
                cycle_start = epsilons[i]

        if cycle_start is not None:
            for ax_i in axes:
                ax_i.axvline(x=cycle_start, color='purple', linestyle=':',
                            alpha=0.6, label='Cycle onset' if ax_i == axes[0] else None)
            axes[0].legend(fontsize=9)

        plt.tight_layout()
        plt.savefig(filename, dpi=150, bbox_inches='tight')
        plt.close()
        print(f"  Plot saved to {filename}")
        return True

    except ImportError:
        print("  matplotlib not available; skipping plot generation.")
        return False


def print_profile_table(profile, title, n_vertices):
    """Print a formatted transition profile table."""
    print(f"\n{'─' * 60}")
    print(f"  {title}")
    print(f"  {n_vertices} vertices")
    print(f"{'─' * 60}")
    print(f"  {'ε':>4} │ {'Components':>10} │ {'Edges':>6} │ {'Cycle Rank':>10} │ Phase")
    print(f"  {'─' * 4}─┼─{'─' * 10}─┼─{'─' * 6}─┼─{'─' * 10}─┼─{'─' * 15}")

    for eps, comps, edges, cr in profile:
        if comps > 1:
            phase = "FRAGMENTED"
        elif cr == 0:
            phase = "TREE/FOREST"
        elif cr <= 3:
            phase = "MESOSCOPIC ◆"
        else:
            phase = "SATURATED"
        print(f"  {eps:4d} │ {comps:10d} │ {edges:6d} │ {cr:10d} │ {phase}")

    print(f"{'─' * 60}")


# ──────────────────────────────────────────────────────────────────────────────
# Main demonstration
# ──────────────────────────────────────────────────────────────────────────────

def main():
    print("╔══════════════════════════════════════════════════════════════╗")
    print("║   PROOF-THEORETIC TOPOLOGY: PHASE TRANSITION DEMO          ║")
    print("╠══════════════════════════════════════════════════════════════╣")
    print("║  Demonstrating topological transitions in semantic          ║")
    print("║  threshold graph filtrations of synthetic theorem families  ║")
    print("╚══════════════════════════════════════════════════════════════╝")

    # Family 1: Clustered-Core
    print("\n▶ FAMILY 1: Clustered-Core (separated clusters)")
    features_1, title_1 = generate_clustered_core_family()
    n1 = len(features_1)
    thresholds_1 = list(range(30))
    profile_1 = transition_profile(features_1, thresholds_1)

    print_profile_table(profile_1, title_1, n1)
    plot_transition_profile(profile_1, title_1, "transition_clustered.png", n1)

    # Family 2: Bridged
    print("\n▶ FAMILY 2: Bridged (clusters with bridge statements)")
    features_2, title_2 = generate_bridged_family()
    n2 = len(features_2)
    thresholds_2 = list(range(30))
    profile_2 = transition_profile(features_2, thresholds_2)

    print_profile_table(profile_2, title_2, n2)
    plot_transition_profile(profile_2, title_2, "transition_bridged.png", n2)

    # Summary
    print("\n╔══════════════════════════════════════════════════════════════╗")
    print("║                         SUMMARY                            ║")
    print("╠══════════════════════════════════════════════════════════════╣")

    for name, profile, n in [("Clustered-Core", profile_1, n1),
                              ("Bridged", profile_2, n2)]:
        conn_eps = next((eps for eps, c, _, _ in profile if c == 1), None)
        cycle_eps = next((eps for eps, _, _, cr in profile if cr > 0), None)
        max_cr = max(cr for _, _, _, cr in profile)
        max_cr_eps = next(eps for eps, _, _, cr in profile if cr == max_cr)
        max_edges = n * (n - 1) // 2
        complete_eps = next((eps for eps, _, e, _ in profile if e == max_edges), None)

        print(f"║                                                            ║")
        print(f"║  {name:15s}:                                          ║")
        print(f"║    Connectivity threshold:  ε = {str(conn_eps):4s}                     ║")
        print(f"║    Cycle onset threshold:   ε = {str(cycle_eps):4s}                     ║")
        print(f"║    Peak cycle rank:         β₁ = {max_cr:3d} at ε = {max_cr_eps:2d}             ║")
        print(f"║    Complete graph threshold: ε = {str(complete_eps):4s}                    ║")

    print("║                                                            ║")
    print("║  Key observation: Both families exhibit the predicted       ║")
    print("║  three-phase structure:                                     ║")
    print("║    1. FRAGMENTED  → disconnected at low ε                  ║")
    print("║    2. MESOSCOPIC  → nontrivial cycles at intermediate ε    ║")
    print("║    3. SATURATED   → complete graph at high ε               ║")
    print("╚══════════════════════════════════════════════════════════════╝")


if __name__ == "__main__":
    main()
