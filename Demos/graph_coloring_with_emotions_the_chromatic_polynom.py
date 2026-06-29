"""
Emotional Chromatic Theory — Interactive Demo

Demonstrates the key results of emotional chromatic theory:
1. Chromatic polynomials for different graph families
2. Emotional chromatic numbers
3. The pigeonhole principle for complete graphs
4. Odd cycle non-2-colorability
"""

from algorithms import (
    Graph, chromatic_polynomial_complete, chromatic_polynomial_cycle,
    emotional_chromatic_number, count_colorings, emotional_assignment,
    emotional_diversity_gap, EMOTIONS, chromatic_number
)


def demo_complete_graphs():
    """Demonstrate emotional chromatic numbers for complete graphs."""
    print("=" * 60)
    print("COMPLETE GRAPHS: Everyone Knows Everyone")
    print("=" * 60)
    print()
    print("In a clique of n mutual friends, everyone needs a different")
    print("emotion. The emotional chromatic number equals n (for n ≥ 3).")
    print()
    print(f"{'Graph':<8} {'χ(G)':<6} {'χ_E(G)':<8} {'χ_G(6)':<10} {'Gap δ_E':<8}")
    print("-" * 40)
    for n in range(1, 8):
        g = Graph.complete(n)
        chi = chromatic_number(g)
        chi_e = emotional_chromatic_number(g)
        chi_6 = chromatic_polynomial_complete(n, 6)
        gap = emotional_diversity_gap(g, 6)
        print(f"K_{n:<5} {chi:<6} {chi_e:<8} {chi_6:<10} {gap:<8}")
    print()


def demo_cycle_graphs():
    """Demonstrate emotional chromatic numbers for cycles."""
    print("=" * 60)
    print("CYCLE GRAPHS: Circular Friendship Chains")
    print("=" * 60)
    print()
    print("For cycles, χ_E(C_n) = 3 always (since χ(C_n) ≤ 3).")
    print("Odd cycles need 3 colors; even cycles need only 2,")
    print("but the emotional floor of 3 applies.")
    print()
    print(f"{'Graph':<8} {'χ(G)':<6} {'χ_E(G)':<8} {'χ_G(6)':<12} {'Parity':<8}")
    print("-" * 42)
    for n in range(3, 12):
        g = Graph.cycle(n)
        chi = chromatic_number(g)
        chi_e = emotional_chromatic_number(g)
        chi_6 = chromatic_polynomial_cycle(n, 6)
        parity = "odd" if n % 2 == 1 else "even"
        print(f"C_{n:<5} {chi:<6} {chi_e:<8} {chi_6:<12} {parity:<8}")
    print()


def demo_chromatic_polynomial():
    """Show the chromatic polynomial for various k values."""
    print("=" * 60)
    print("CHROMATIC POLYNOMIAL: Counting Valid Assignments")
    print("=" * 60)
    print()
    print("χ_G(k) = number of proper k-colorings")
    print()

    graphs = [
        ("K_3", Graph.complete(3)),
        ("K_4", Graph.complete(4)),
        ("K_5", Graph.complete(5)),
        ("C_5", Graph.cycle(5)),
        ("C_6", Graph.cycle(6)),
        ("K_{2,3}", Graph.complete_bipartite(2, 3)),
    ]

    header = f"{'Graph':<8}" + "".join(f"{'k='+str(k):<10}" for k in range(1, 8))
    print(header)
    print("-" * 78)
    for name, g in graphs:
        vals = [count_colorings(g, k) for k in range(1, 8)]
        row = f"{name:<8}" + "".join(f"{v:<10}" for v in vals)
        print(row)
    print()


def demo_emotional_assignment():
    """Show concrete emotional assignments for small graphs."""
    print("=" * 60)
    print("EMOTIONAL ASSIGNMENTS: Mapping Emotions to People")
    print("=" * 60)
    print()

    graphs = [
        ("Triangle (K_3)", Graph.complete(3)),
        ("Pentagon (C_5)", Graph.cycle(5)),
        ("Square (C_4)", Graph.cycle(4)),
        ("K_4 (four mutual friends)", Graph.complete(4)),
    ]

    for name, g in graphs:
        assignment = emotional_assignment(g)
        chi_e = emotional_chromatic_number(g)
        print(f"{name}: χ_E = {chi_e}")
        if assignment:
            for i, emotion in enumerate(assignment):
                print(f"  Person {i}: {emotion}")
        else:
            print("  Cannot assign 6 emotions (clique too large)")
        print()


def demo_pigeonhole():
    """Demonstrate the pigeonhole principle for complete graphs."""
    print("=" * 60)
    print("PIGEONHOLE PRINCIPLE: Why K_n Needs n Colors")
    print("=" * 60)
    print()
    print("K_n is n-colorable but NOT (n-1)-colorable.")
    print("With n-1 colors for n vertices, two vertices share a color.")
    print("But all vertices are adjacent → contradiction.")
    print()
    for n in range(2, 8):
        g = Graph.complete(n)
        can_n = count_colorings(g, n)
        can_n1 = count_colorings(g, n - 1)
        print(f"K_{n}: χ({n}) = {can_n:>6} colorings, "
              f"χ({n-1}) = {can_n1:>6} colorings")
    print()


def demo_odd_cycle():
    """Demonstrate that odd cycles are not 2-colorable."""
    print("=" * 60)
    print("ODD CYCLE THEOREM: Binary Emotions Fail")
    print("=" * 60)
    print()
    print("Odd cycles cannot be properly 2-colored.")
    print("Even cycles can: just alternate colors.")
    print()
    for n in range(3, 10):
        g = Graph.cycle(n)
        chi_2 = count_colorings(g, 2)
        parity = "ODD " if n % 2 == 1 else "EVEN"
        status = "NOT 2-colorable" if chi_2 == 0 else f"2-colorable ({chi_2} ways)"
        print(f"C_{n} ({parity}): {status}")
    print()


def demo_diversity_gap():
    """Demonstrate the emotional diversity gap."""
    print("=" * 60)
    print("EMOTIONAL DIVERSITY GAP: Measuring Flexibility")
    print("=" * 60)
    print()
    print("δ_E(G, k) = k - 3 if G is k-colorable and k ≥ 3, else 0")
    print("Higher gap = more emotional flexibility")
    print()
    graphs = [
        ("K_3", Graph.complete(3)),
        ("K_6", Graph.complete(6)),
        ("C_5", Graph.cycle(5)),
        ("P_5 (path)", Graph.path(5)),
    ]
    print(f"{'Graph':<12}" + "".join(f"{'k='+str(k):<8}" for k in range(1, 8)))
    print("-" * 68)
    for name, g in graphs:
        vals = [emotional_diversity_gap(g, k) for k in range(1, 8)]
        row = f"{name:<12}" + "".join(f"{v:<8}" for v in vals)
        print(row)
    print()


if __name__ == "__main__":
    demo_complete_graphs()
    demo_cycle_graphs()
    demo_chromatic_polynomial()
    demo_emotional_assignment()
    demo_pigeonhole()
    demo_odd_cycle()
    demo_diversity_gap()


"""
Visualization: Chromatic polynomials for different graph families.
Standalone script using matplotlib.
"""

import matplotlib.pyplot as plt
import numpy as np


def chromatic_poly_complete(n: int, k: float) -> float:
    """Chromatic polynomial of K_n at k (continuous extension)."""
    result = 1.0
    for i in range(n):
        result *= (k - i)
    return result


def chromatic_poly_cycle(n: int, k: float) -> float:
    """Chromatic polynomial of C_n at k."""
    return (k - 1) ** n + ((-1) ** n) * (k - 1)


def chromatic_poly_path(n: int, k: float) -> float:
    """Chromatic polynomial of P_n at k."""
    return k * (k - 1) ** (n - 1)


def main():
    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    k_vals = np.linspace(0, 8, 300)

    # Complete graphs
    ax = axes[0]
    for n in [2, 3, 4, 5, 6]:
        y = [chromatic_poly_complete(n, k) for k in k_vals]
        ax.plot(k_vals, y, label=f'K_{n}', linewidth=2)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('k (number of colors/emotions)', fontsize=12)
    ax.set_ylabel('χ_G(k)', fontsize=12)
    ax.set_title('Chromatic Polynomial: Complete Graphs', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(-100, 500)
    ax.grid(True, alpha=0.3)

    # Cycle graphs
    ax = axes[1]
    for n in [3, 4, 5, 6, 7]:
        y = [chromatic_poly_cycle(n, k) for k in k_vals]
        ax.plot(k_vals, y, label=f'C_{n}', linewidth=2)
    ax.axhline(y=0, color='black', linewidth=0.5)
    ax.set_xlabel('k (number of colors/emotions)', fontsize=12)
    ax.set_ylabel('χ_G(k)', fontsize=12)
    ax.set_title('Chromatic Polynomial: Cycle Graphs', fontsize=14)
    ax.legend(fontsize=11)
    ax.set_ylim(-50, 300)
    ax.grid(True, alpha=0.3)

    # Emotional chromatic number visualization
    ax = axes[2]
    graph_types = ['K_2', 'K_3', 'K_4', 'K_5', 'K_6',
                   'C_3', 'C_4', 'C_5', 'C_6', 'C_7']
    chi_vals = [2, 3, 4, 5, 6, 3, 2, 3, 2, 3]
    chi_e_vals = [max(3, c) for c in chi_vals]

    x = np.arange(len(graph_types))
    width = 0.35
    bars1 = ax.bar(x - width/2, chi_vals, width, label='χ(G)', color='steelblue')
    bars2 = ax.bar(x + width/2, chi_e_vals, width, label='χ_E(G)', color='coral')
    ax.axhline(y=3, color='red', linestyle='--', linewidth=1, alpha=0.7, label='Emotional floor (k≥3)')
    ax.set_xticks(x)
    ax.set_xticklabels(graph_types, fontsize=10)
    ax.set_ylabel('Chromatic Number', fontsize=12)
    ax.set_title('Standard vs. Emotional Chromatic Number', fontsize=14)
    ax.legend(fontsize=10)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('chromatic_polynomials.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved chromatic_polynomials.png")


if __name__ == "__main__":
    main()
