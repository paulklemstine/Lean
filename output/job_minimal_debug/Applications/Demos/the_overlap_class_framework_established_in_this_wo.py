#!/usr/bin/env python3
"""
Overlap Class Spectral Theory — Demonstration

Numerical examples illustrating the main theorems and invariants from
the overlap class spectral theory framework.
"""

from algorithms import (
    overlap_interaction_matrix,
    overlap_complexity,
    total_support_size,
    family_union,
    overlap_edge_count,
    overlap_connected_components,
    spectral_bound,
    is_pairwise_disjoint,
    verify_spectral_bound,
    multiplicity_distribution,
)


def print_matrix(M: list[list[int]], label: str = "Matrix") -> None:
    """Pretty-print a matrix."""
    print(f"\n{label}:")
    for row in M:
        print("  " + "  ".join(f"{x:3d}" for x in row))


def demo_pairwise_disjoint() -> None:
    """Example 1: Pairwise disjoint family."""
    print("=" * 60)
    print("Example 1: Pairwise Disjoint Family")
    print("=" * 60)
    supports = [
        {1, 2, 3},
        {4, 5},
        {6, 7, 8, 9},
    ]
    for i, s in enumerate(supports):
        print(f"  S_{i} = {sorted(s)}")

    M = overlap_interaction_matrix(supports)
    print_matrix(M, "Overlap Interaction Matrix")

    result = verify_spectral_bound(supports)
    print(f"\n  Pairwise disjoint: {is_pairwise_disjoint(supports)}")
    print(f"  Total support size: {result['total_support_size']}")
    print(f"  Overlap complexity: {result['overlap_complexity']}")
    print(f"  Family union size:  {result['family_union_size']}")
    print(f"  Spectral bound:     {result['spectral_bound']}")
    print(f"  Bound holds:        {result['bound_holds']}")
    print(f"  |⋃S| = ∑|S_i| (disjoint case): "
          f"{result['family_union_size']} = {result['total_support_size']}")
    print(f"  Edge count:         {result['edge_count']}")
    print(f"  Components:         {result['num_components']}")


def demo_overlapping() -> None:
    """Example 2: Overlapping family."""
    print("\n" + "=" * 60)
    print("Example 2: Overlapping Family")
    print("=" * 60)
    supports = [
        {1, 2, 3, 4},
        {3, 4, 5, 6},
        {5, 6, 7},
    ]
    for i, s in enumerate(supports):
        print(f"  S_{i} = {sorted(s)}")

    M = overlap_interaction_matrix(supports)
    print_matrix(M, "Overlap Interaction Matrix")

    result = verify_spectral_bound(supports)
    print(f"\n  Pairwise disjoint: {is_pairwise_disjoint(supports)}")
    print(f"  Total support size: {result['total_support_size']}")
    print(f"  Overlap complexity: {result['overlap_complexity']}")
    print(f"  Family union size:  {result['family_union_size']}")
    print(f"  Spectral bound:     {result['spectral_bound']}")
    print(f"  Bound holds:        {result['bound_holds']}")
    print(f"  Edge count:         {result['edge_count']}")
    print(f"  Components:         {result['num_components']}")
    print(f"  Multiplicity dist:  {multiplicity_distribution(supports)}")


def demo_chain() -> None:
    """Example 3: Chain overlap (linear overlap graph)."""
    print("\n" + "=" * 60)
    print("Example 3: Chain Overlap (Linear Graph)")
    print("=" * 60)
    supports = [
        {1, 2, 3},
        {3, 4, 5},
        {5, 6, 7},
        {7, 8, 9},
    ]
    for i, s in enumerate(supports):
        print(f"  S_{i} = {sorted(s)}")

    M = overlap_interaction_matrix(supports)
    print_matrix(M, "Overlap Interaction Matrix")

    components = overlap_connected_components(supports)
    result = verify_spectral_bound(supports)
    print(f"\n  Overlap graph components: {components}")
    print(f"  Total support size: {result['total_support_size']}")
    print(f"  Overlap complexity: {result['overlap_complexity']}")
    print(f"  Family union size:  {result['family_union_size']}")
    print(f"  Spectral bound:     {result['spectral_bound']}")
    print(f"  Bound holds:        {result['bound_holds']}")
    print(f"  Edge count:         {result['edge_count']}")
    print(f"  Multiplicity dist:  {multiplicity_distribution(supports)}")


def demo_complete_overlap() -> None:
    """Example 4: High overlap (all sets share elements)."""
    print("\n" + "=" * 60)
    print("Example 4: Complete Overlap Graph (Star)")
    print("=" * 60)
    # All sets share element 0
    supports = [
        {0, 1, 2},
        {0, 3, 4},
        {0, 5, 6},
        {0, 7, 8},
    ]
    for i, s in enumerate(supports):
        print(f"  S_{i} = {sorted(s)}")

    M = overlap_interaction_matrix(supports)
    print_matrix(M, "Overlap Interaction Matrix")

    components = overlap_connected_components(supports)
    result = verify_spectral_bound(supports)
    print(f"\n  Overlap graph components: {components}")
    print(f"  Total support size: {result['total_support_size']}")
    print(f"  Overlap complexity: {result['overlap_complexity']}")
    print(f"  Family union size:  {result['family_union_size']}")
    print(f"  Spectral bound:     {result['spectral_bound']}")
    print(f"  Bound holds:        {result['bound_holds']}")
    print(f"  Edge count (= C(4,2) = 6): {result['edge_count']}")


def demo_refinement_monotonicity() -> None:
    """Example 5: Refinement monotonicity."""
    print("\n" + "=" * 60)
    print("Example 5: Refinement Monotonicity")
    print("=" * 60)
    F = [
        {1, 2, 3, 4, 5},
        {3, 4, 5, 6, 7},
        {5, 6, 7, 8, 9},
    ]
    G = [
        {1, 2, 3},
        {4, 5, 6},
        {7, 8, 9},
    ]
    print("  Original family F:")
    for i, s in enumerate(F):
        print(f"    F_{i} = {sorted(s)}")
    print("  Refined family G (G_i ⊆ F_i):")
    for i, s in enumerate(G):
        print(f"    G_{i} = {sorted(s)}")

    oc_F = overlap_complexity(F)
    oc_G = overlap_complexity(G)
    tss_F = total_support_size(F)
    tss_G = total_support_size(G)

    print(f"\n  OverlapComplexity(F) = {oc_F}")
    print(f"  OverlapComplexity(G) = {oc_G}")
    print(f"  G refines F:  {all(G[i] <= F[i] for i in range(len(F)))}")
    print(f"  OC(G) ≤ OC(F): {oc_G <= oc_F}")
    print(f"  TotalSupportSize(F) = {tss_F}")
    print(f"  TotalSupportSize(G) = {tss_G}")
    print(f"  TSS(G) ≤ TSS(F): {tss_G <= tss_F}")


def demo_spectral_bound_tightness() -> None:
    """Example 6: Tightness of the spectral bound."""
    print("\n" + "=" * 60)
    print("Example 6: Spectral Bound Tightness Analysis")
    print("=" * 60)
    # The bound is |⋃S| ≥ TSS - OC.
    # It is tight when each element appears in at most 2 supports.
    print("\n  Case A: Each element in at most 2 supports (tight bound)")
    A = [{1, 2, 3}, {3, 4, 5}, {5, 6, 7}]
    rA = verify_spectral_bound(A)
    print(f"    TSS = {rA['total_support_size']}, OC = {rA['overlap_complexity']}, "
          f"|⋃| = {rA['family_union_size']}, bound = {rA['spectral_bound']}")
    print(f"    Gap = |⋃| - bound = {rA['family_union_size'] - rA['spectral_bound']}")

    print("\n  Case B: Element in 3 supports (loose bound)")
    B = [{1, 2, 3}, {1, 4, 5}, {1, 6, 7}]
    rB = verify_spectral_bound(B)
    print(f"    TSS = {rB['total_support_size']}, OC = {rB['overlap_complexity']}, "
          f"|⋃| = {rB['family_union_size']}, bound = {rB['spectral_bound']}")
    print(f"    Gap = |⋃| - bound = {rB['family_union_size'] - rB['spectral_bound']}")

    print("\n  Case C: All elements shared (maximum overlap)")
    C = [{1, 2, 3}, {1, 2, 3}, {1, 2, 3}]
    rC = verify_spectral_bound(C)
    print(f"    TSS = {rC['total_support_size']}, OC = {rC['overlap_complexity']}, "
          f"|⋃| = {rC['family_union_size']}, bound = {rC['spectral_bound']}")
    print(f"    Gap = |⋃| - bound = {rC['family_union_size'] - rC['spectral_bound']}")


if __name__ == "__main__":
    demo_pairwise_disjoint()
    demo_overlapping()
    demo_chain()
    demo_complete_overlap()
    demo_refinement_monotonicity()
    demo_spectral_bound_tightness()
    print("\n" + "=" * 60)
    print("All demonstrations complete.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Overlap Interaction Matrix and Spectral Bounds

Generates heatmaps of the overlap interaction matrix and a scatter plot
comparing the spectral bound to the true union size across random families.
"""

import random
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors
import numpy as np


def overlap_interaction_matrix(supports):
    n = len(supports)
    M = [[0] * n for _ in range(n)]
    for i in range(n):
        for j in range(n):
            M[i][j] = len(supports[i] & supports[j])
    return M


def overlap_complexity(supports):
    from itertools import combinations
    return sum(
        len(supports[i] & supports[j])
        for i, j in combinations(range(len(supports)), 2)
    )


def total_support_size(supports):
    return sum(len(s) for s in supports)


def family_union(supports):
    result = set()
    for s in supports:
        result |= s
    return result


def random_support_family(n_sets, universe_size, max_set_size):
    """Generate a random family of sets."""
    universe = list(range(universe_size))
    return [
        set(random.sample(universe, min(random.randint(1, max_set_size), universe_size)))
        for _ in range(n_sets)
    ]


def plot_interaction_matrix():
    """Plot interaction matrices for three example families."""
    families = {
        "Disjoint": [{1, 2, 3}, {4, 5, 6}, {7, 8, 9}],
        "Chain": [{1, 2, 3}, {3, 4, 5}, {5, 6, 7}, {7, 8, 9}],
        "Star": [{0, 1, 2}, {0, 3, 4}, {0, 5, 6}, {0, 7, 8}],
    }

    fig, axes = plt.subplots(1, 3, figsize=(14, 4))
    for ax, (name, supports) in zip(axes, families.items()):
        M = np.array(overlap_interaction_matrix(supports))
        n = len(supports)
        im = ax.imshow(M, cmap="YlOrRd", vmin=0)
        ax.set_title(f"{name} Family", fontsize=13, fontweight="bold")
        ax.set_xlabel("Support index j")
        ax.set_ylabel("Support index i")
        ax.set_xticks(range(n))
        ax.set_yticks(range(n))
        for i in range(n):
            for j in range(n):
                color = "white" if M[i, j] > M.max() * 0.6 else "black"
                ax.text(j, i, str(M[i, j]), ha="center", va="center",
                        fontsize=14, color=color, fontweight="bold")
        plt.colorbar(im, ax=ax, fraction=0.046, pad=0.04)

    plt.suptitle("Overlap Interaction Matrices", fontsize=15, fontweight="bold", y=1.02)
    plt.tight_layout()
    plt.savefig("overlap_matrices.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved overlap_matrices.png")


def plot_spectral_bound_analysis():
    """Scatter plot: spectral bound vs actual union size."""
    random.seed(42)
    n_trials = 500

    union_sizes = []
    spectral_bounds = []
    complexities = []
    is_tight = []

    for _ in range(n_trials):
        n_sets = random.randint(2, 8)
        universe_size = random.randint(5, 30)
        max_set_size = random.randint(2, min(10, universe_size))
        supports = random_support_family(n_sets, universe_size, max_set_size)

        tss = total_support_size(supports)
        oc = overlap_complexity(supports)
        us = len(family_union(supports))
        sb = max(0, tss - oc)

        union_sizes.append(us)
        spectral_bounds.append(sb)
        complexities.append(oc)
        is_tight.append(us == sb)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: Spectral bound vs union size
    ax = axes[0]
    tight_mask = [t for t in is_tight]
    colors = ["#2ecc71" if t else "#3498db" for t in tight_mask]
    ax.scatter(spectral_bounds, union_sizes, c=colors, alpha=0.5, s=20, edgecolors="none")
    max_val = max(max(union_sizes), max(spectral_bounds)) + 2
    ax.plot([0, max_val], [0, max_val], "r--", linewidth=1.5, label="|⋃S| = bound (tight)")
    ax.set_xlabel("Spectral Bound (TSS - OC)", fontsize=12)
    ax.set_ylabel("Actual Union Size |⋃S|", fontsize=12)
    ax.set_title("Spectral Bound vs Union Size", fontsize=13, fontweight="bold")
    ax.legend(fontsize=10)
    ax.set_xlim(-1, max_val)
    ax.set_ylim(-1, max_val)
    n_tight = sum(is_tight)
    ax.text(0.05, 0.95, f"Tight: {n_tight}/{n_trials} ({100*n_tight/n_trials:.1f}%)",
            transform=ax.transAxes, fontsize=11, verticalalignment="top",
            bbox=dict(boxstyle="round", facecolor="wheat", alpha=0.8))

    # Plot 2: Gap vs overlap complexity
    ax = axes[1]
    gaps = [u - s for u, s in zip(union_sizes, spectral_bounds)]
    ax.scatter(complexities, gaps, alpha=0.4, s=20, c="#e74c3c", edgecolors="none")
    ax.set_xlabel("Overlap Complexity", fontsize=12)
    ax.set_ylabel("Gap (|⋃S| - Spectral Bound)", fontsize=12)
    ax.set_title("Bound Tightness vs Complexity", fontsize=13, fontweight="bold")
    ax.axhline(y=0, color="gray", linestyle="--", linewidth=1)

    plt.suptitle("Spectral Inclusion-Exclusion Bound Analysis",
                 fontsize=15, fontweight="bold", y=1.02)
    plt.tight_layout()
    plt.savefig("spectral_bound_analysis.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved spectral_bound_analysis.png")


def plot_refinement_monotonicity():
    """Show how refinement decreases overlap complexity."""
    random.seed(123)
    universe_size = 20
    n_sets = 5
    base_supports = random_support_family(n_sets, universe_size, 10)

    # Create a sequence of refinements by progressively removing elements
    steps = 8
    complexities_seq = []
    tss_seq = []
    current = [set(s) for s in base_supports]

    for step in range(steps):
        complexities_seq.append(overlap_complexity(current))
        tss_seq.append(total_support_size(current))
        # Refine by removing one element from each non-empty set
        new = []
        for s in current:
            s2 = set(s)
            if len(s2) > 1:
                s2.discard(random.choice(list(s2)))
            new.append(s2)
        current = new

    fig, ax = plt.subplots(figsize=(8, 5))
    ax.plot(range(steps), complexities_seq, "o-", color="#e74c3c",
            linewidth=2, markersize=8, label="Overlap Complexity")
    ax.plot(range(steps), tss_seq, "s-", color="#3498db",
            linewidth=2, markersize=8, label="Total Support Size")
    ax.set_xlabel("Refinement Step", fontsize=12)
    ax.set_ylabel("Value", fontsize=12)
    ax.set_title("Refinement Monotonicity", fontsize=14, fontweight="bold")
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    plt.tight_layout()
    plt.savefig("refinement_monotonicity.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("Saved refinement_monotonicity.png")


if __name__ == "__main__":
    plot_interaction_matrix()
    plot_spectral_bound_analysis()
    plot_refinement_monotonicity()
    print("\nAll visualizations generated.")
