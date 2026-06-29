#!/usr/bin/env python3
"""
Graph Reconstruction Conjecture — Demonstration

Demonstrates the key results:
1. Edge count reconstruction from the deck
2. Degree sequence reconstruction
3. Kelly's lemma verification
4. Regularity detection
5. DeckFingerprint computation
"""

from algorithms import (
    Graph, compute_deck, reconstruct_edge_count,
    reconstruct_degree_sequence, verify_kelly_edge_identity,
    compute_deck_fingerprint, detect_regularity_from_deck,
    reconstruct_complement_edges, verify_reconstruction
)


def make_complete_graph(n: int) -> Graph:
    """K_n: complete graph on n vertices."""
    edges = [(i, j) for i in range(n) for j in range(i+1, n)]
    return Graph(n, edges)


def make_cycle(n: int) -> Graph:
    """C_n: cycle on n vertices."""
    edges = [(i, (i+1) % n) for i in range(n)]
    return Graph(n, edges)


def make_path(n: int) -> Graph:
    """P_n: path on n vertices."""
    edges = [(i, i+1) for i in range(n-1)]
    return Graph(n, edges)


def make_petersen() -> Graph:
    """The Petersen graph: 10 vertices, 3-regular, 15 edges."""
    outer = [(i, (i+1) % 5) for i in range(5)]
    inner = [(5+i, 5+(i+2) % 5) for i in range(5)]
    spokes = [(i, i+5) for i in range(5)]
    return Graph(10, outer + inner + spokes)


def make_star(n: int) -> Graph:
    """K_{1,n-1}: star graph on n vertices."""
    edges = [(0, i) for i in range(1, n)]
    return Graph(n, edges)


def separator(title: str):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}\n")


def main():
    # --- 1. Edge Count Reconstruction ---
    separator("1. Edge Count Reconstruction")

    test_graphs = [
        ("K_5 (complete)", make_complete_graph(5)),
        ("C_6 (cycle)", make_cycle(6)),
        ("P_5 (path)", make_path(5)),
        ("K_{1,4} (star)", make_star(5)),
        ("Petersen", make_petersen()),
    ]

    for name, G in test_graphs:
        deck = compute_deck(G)
        reconstructed = reconstruct_edge_count(deck, G.n)
        deck_edges = [card.edge_count() for card in deck]
        print(f"{name:20s}: |E| = {G.edge_count():3d}, "
              f"deck edges = {deck_edges}, "
              f"reconstructed = {reconstructed}, "
              f"✓" if reconstructed == G.edge_count() else "✗")

    # --- 2. Degree Sequence Reconstruction ---
    separator("2. Degree Sequence Reconstruction")

    for name, G in test_graphs:
        deck = compute_deck(G)
        true_seq = G.degree_sequence()
        recon_seq = reconstruct_degree_sequence(deck, G.n)
        match = "✓" if true_seq == recon_seq else "✗"
        print(f"{name:20s}: true = {true_seq}, reconstructed = {recon_seq} {match}")

    # --- 3. Kelly's Lemma Verification ---
    separator("3. Kelly's Lemma (Edge Version)")

    for name, G in test_graphs:
        holds = verify_kelly_edge_identity(G)
        lhs = (G.n - 2) * G.edge_count()
        deck = compute_deck(G)
        rhs = sum(card.edge_count() for card in deck)
        print(f"{name:20s}: (n-2)*|E| = {lhs}, Σ|E(G_v)| = {rhs}, "
              f"Kelly holds: {holds}")

    # --- 4. Regularity Detection from Deck ---
    separator("4. Regularity Detection from Deck")

    for name, G in test_graphs:
        deck = compute_deck(G)
        is_reg, k = detect_regularity_from_deck(deck, G.n)
        if is_reg:
            print(f"{name:20s}: REGULAR (k = {k})")
        else:
            print(f"{name:20s}: NOT regular")

    # --- 5. DeckFingerprint ---
    separator("5. DeckFingerprint Computation")

    for name, G in test_graphs:
        fp = compute_deck_fingerprint(G)
        print(f"\n{name}:")
        print(f"  Vertices: {fp['vertex_count']}")
        print(f"  Edges: {fp['edge_count']}")
        print(f"  Deck edge counts: {fp['deck_edge_counts']}")
        print(f"  Consistency: {fp['consistency_check']}")
        print(f"  Degree sequence: {fp['degree_sequence']}")
        print(f"  Is regular: {fp['is_regular']}")

    # --- 6. Complement Edge Reconstruction ---
    separator("6. Complement Edge Count")

    for name, G in test_graphs:
        deck = compute_deck(G)
        comp_edges = reconstruct_complement_edges(deck, G.n)
        max_edges = G.n * (G.n - 1) // 2
        true_comp = max_edges - G.edge_count()
        match = "✓" if comp_edges == true_comp else "✗"
        print(f"{name:20s}: |E(G)| = {G.edge_count():3d}, "
              f"|E(Gᶜ)| = {comp_edges:3d} (max = {max_edges}) {match}")

    # --- 7. Full Reconstruction Verification ---
    separator("7. Full Verification Report")

    G = make_petersen()
    result = verify_reconstruction(G)
    print("Petersen Graph Full Report:")
    for key, val in result.items():
        print(f"  {key}: {val}")

    # --- 8. Edge Sum Formula Demonstration ---
    separator("8. Edge Sum Formula: Σ|E(G_v)| = (n-2)·|E(G)|")

    for n in range(3, 8):
        G = make_complete_graph(n)
        deck = compute_deck(G)
        deck_sum = sum(card.edge_count() for card in deck)
        formula_val = (n - 2) * G.edge_count()
        print(f"K_{n}: Σ|E(G_v)| = {deck_sum:4d}, "
              f"(n-2)·|E| = {formula_val:4d}, "
              f"match: {deck_sum == formula_val}")

    print("\n" + "="*60)
    print("  All demonstrations complete.")
    print("="*60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Graph Reconstruction — Deck Edge Profiles

Shows how different graph families produce distinct deck fingerprints,
demonstrating that the deck captures enough information to distinguish graphs.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def make_complete_graph_edges(n):
    return [(i, j) for i in range(n) for j in range(i+1, n)]


def make_cycle_edges(n):
    return [(i, (i+1) % n) for i in range(n)]


def make_path_edges(n):
    return [(i, i+1) for i in range(n-1)]


def make_star_edges(n):
    return [(0, i) for i in range(1, n)]


def compute_deck_edge_counts(n, edges):
    """Compute edge count of each vertex-deleted subgraph."""
    edge_set = set(frozenset(e) for e in edges)
    counts = []
    for v in range(n):
        card_edges = sum(1 for e in edge_set if v not in e)
        counts.append(card_edges)
    return sorted(counts)


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Graph Reconstruction: Deck Edge Profiles',
                 fontsize=16, fontweight='bold')

    # Panel 1: Kelly's lemma verification across graph sizes
    ax = axes[0, 0]
    ns = list(range(3, 12))
    families = {
        'Complete (Kₙ)': make_complete_graph_edges,
        'Cycle (Cₙ)': make_cycle_edges,
        'Path (Pₙ)': make_path_edges,
        'Star (K₁,ₙ₋₁)': make_star_edges,
    }
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

    for (name, make_fn), color in zip(families.items(), colors):
        ratios = []
        for n in ns:
            edges = make_fn(n)
            deck_sum = sum(compute_deck_edge_counts(n, edges))
            edge_count = len(set(frozenset(e) for e in edges))
            if edge_count > 0:
                ratio = deck_sum / edge_count
            else:
                ratio = 0
            ratios.append(ratio)
        ax.plot(ns, ratios, 'o-', color=color, label=name, linewidth=2, markersize=6)

    expected = [n - 2 for n in ns]
    ax.plot(ns, expected, 'k--', label='n - 2 (expected)', linewidth=1.5, alpha=0.7)
    ax.set_xlabel('Number of vertices (n)')
    ax.set_ylabel('Σ|E(Gᵥ)| / |E(G)|')
    ax.set_title("Kelly's Lemma: Σ|E(Gᵥ)| = (n-2)·|E(G)|")
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 2: Deck fingerprints for n=8 graphs
    ax = axes[0, 1]
    n = 8
    graph_data = [
        ('K₈', make_complete_graph_edges(n)),
        ('C₈', make_cycle_edges(n)),
        ('P₈', make_path_edges(n)),
        ('K₁,₇', make_star_edges(n)),
    ]

    x = np.arange(n)
    width = 0.2
    for i, ((name, edges), color) in enumerate(zip(graph_data, colors)):
        counts = compute_deck_edge_counts(n, edges)
        ax.bar(x + i * width - 0.3, counts, width, label=name, color=color, alpha=0.8)

    ax.set_xlabel('Deck card index (sorted)')
    ax.set_ylabel('Edge count of card')
    ax.set_title(f'Deck Fingerprints (n={n})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3, axis='y')

    # Panel 3: Degree sequence reconstruction
    ax = axes[1, 0]
    n = 7
    test_graphs = [
        ('K₇', make_complete_graph_edges(n)),
        ('C₇', make_cycle_edges(n)),
        ('P₇', make_path_edges(n)),
        ('K₁,₆', make_star_edges(n)),
    ]

    for i, ((name, edges), color) in enumerate(zip(test_graphs, colors)):
        edge_set = set(frozenset(e) for e in edges)
        total_edges = len(edge_set)
        deck_counts = []
        for v in range(n):
            card_edges = sum(1 for e in edge_set if v not in e)
            deck_counts.append(card_edges)
        degrees = sorted([total_edges - c for c in deck_counts], reverse=True)
        ax.plot(range(n), degrees, 'o-', color=color, label=name,
                linewidth=2, markersize=6)

    ax.set_xlabel('Vertex rank')
    ax.set_ylabel('Degree')
    ax.set_title(f'Reconstructed Degree Sequences (n={n})')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)

    # Panel 4: Regularity detection — variance of deck edge counts
    ax = axes[1, 1]
    ns_range = list(range(3, 15))
    for (name, make_fn), color in zip(families.items(), colors):
        variances = []
        for n in ns_range:
            edges = make_fn(n)
            counts = compute_deck_edge_counts(n, edges)
            variance = np.var(counts)
            variances.append(variance)
        ax.plot(ns_range, variances, 'o-', color=color, label=name,
                linewidth=2, markersize=5)

    ax.set_xlabel('Number of vertices (n)')
    ax.set_ylabel('Variance of deck edge counts')
    ax.set_title('Regularity Detection: Var = 0 ⟺ Regular')
    ax.legend(fontsize=8)
    ax.grid(True, alpha=0.3)
    ax.set_yscale('symlog', linthresh=0.1)

    plt.tight_layout()
    plt.savefig('reconstruction_analysis.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: reconstruction_analysis.png")


if __name__ == "__main__":
    main()
