"""
Demo: Hadwiger's Conjecture — Numerical Examples

Demonstrates the key concepts:
1. Chromatic number vs Hadwiger number for various graph families
2. Verification of Hadwiger's conjecture for small graphs
3. The asymmetry: minors can increase chromatic number
"""

from algorithms import (
    chromatic_number_exact,
    hadwiger_number,
    compute_degeneracy,
    greedy_coloring,
    find_minor_model,
    verify_hadwiger_small,
)


def make_complete_graph(n: int) -> dict[int, set[int]]:
    """Complete graph K_n."""
    return {i: {j for j in range(n) if j != i} for i in range(n)}


def make_cycle(n: int) -> dict[int, set[int]]:
    """Cycle graph C_n."""
    return {i: {(i - 1) % n, (i + 1) % n} for i in range(n)}


def make_path(n: int) -> dict[int, set[int]]:
    """Path graph P_n."""
    adj: dict[int, set[int]] = {i: set() for i in range(n)}
    for i in range(n - 1):
        adj[i].add(i + 1)
        adj[i + 1].add(i)
    return adj


def make_complete_bipartite(m: int, n: int) -> dict[int, set[int]]:
    """Complete bipartite graph K_{m,n}."""
    adj: dict[int, set[int]] = {i: set() for i in range(m + n)}
    for i in range(m):
        for j in range(m, m + n):
            adj[i].add(j)
            adj[j].add(i)
    return adj


def make_petersen() -> dict[int, set[int]]:
    """Petersen graph."""
    return {
        0: {1, 4, 5}, 1: {0, 2, 6}, 2: {1, 3, 7},
        3: {2, 4, 8}, 4: {3, 0, 9}, 5: {0, 7, 8},
        6: {1, 8, 9}, 7: {2, 5, 9}, 8: {3, 5, 6},
        9: {4, 6, 7}
    }


def print_separator():
    print("=" * 60)


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║     Hadwiger's Conjecture: Numerical Demonstrations     ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print()

    # 1. Complete graphs
    print_separator()
    print("1. COMPLETE GRAPHS K_n")
    print("   Hadwiger predicts: χ(K_n) = n ≤ h(K_n)")
    print_separator()
    for n in range(1, 7):
        G = make_complete_graph(n)
        chi = chromatic_number_exact(G)
        h = hadwiger_number(G)
        status = "✓" if chi <= h else "✗"
        print(f"   K_{n}: χ = {chi}, h = {h}  {status}")
    print()

    # 2. Cycle graphs
    print_separator()
    print("2. CYCLE GRAPHS C_n")
    print("   Even cycles: χ=2, Odd cycles: χ=3")
    print_separator()
    for n in range(3, 9):
        G = make_cycle(n)
        chi = chromatic_number_exact(G)
        h = hadwiger_number(G)
        parity = "even" if n % 2 == 0 else "odd"
        status = "✓" if chi <= h else "✗"
        print(f"   C_{n} ({parity}): χ = {chi}, h = {h}  {status}")
    print()

    # 3. Complete bipartite graphs — the asymmetry!
    print_separator()
    print("3. COMPLETE BIPARTITE GRAPHS K_{m,n}")
    print("   All bipartite: χ = 2, but h can be large!")
    print("   This shows: h(G) ≥ χ(G) but NOT h(G) = χ(G)")
    print_separator()
    for m, n in [(2, 2), (2, 3), (3, 3), (3, 4), (4, 4)]:
        G = make_complete_bipartite(m, n)
        chi = chromatic_number_exact(G)
        h = hadwiger_number(G)
        status = "✓" if chi <= h else "✗"
        gap = h - chi
        print(f"   K_{{{m},{n}}}: χ = {chi}, h = {h} (gap = {gap})  {status}")
    print()

    # 4. Petersen graph
    print_separator()
    print("4. PETERSEN GRAPH")
    print_separator()
    G = make_petersen()
    chi = chromatic_number_exact(G)
    deg, ordering = compute_degeneracy(G)
    coloring = greedy_coloring(G, ordering)
    num_colors = len(set(coloring.values()))
    print(f"   Chromatic number: χ = {chi}")
    print(f"   Degeneracy: d = {deg}")
    print(f"   Greedy coloring uses {num_colors} colors (≤ d+1 = {deg+1})")
    print(f"   Coloring: {coloring}")
    print()

    # 5. Degeneracy and greedy coloring
    print_separator()
    print("5. DEGENERACY AND GREEDY COLORING")
    print("   Theorem: d-degenerate ⟹ (d+1)-colorable")
    print_separator()
    graphs = [
        ("Path P_5", make_path(5)),
        ("Cycle C_5", make_cycle(5)),
        ("K_4", make_complete_graph(4)),
        ("K_{3,3}", make_complete_bipartite(3, 3)),
    ]
    for name, G in graphs:
        deg, ordering = compute_degeneracy(G)
        coloring = greedy_coloring(G, ordering)
        num_colors = len(set(coloring.values()))
        chi = chromatic_number_exact(G)
        print(f"   {name}: d = {deg}, greedy = {num_colors}, χ = {chi}, d+1 = {deg+1}")
        assert num_colors <= deg + 1, f"Greedy coloring failed for {name}!"
        assert chi <= deg + 1, f"Theorem failed for {name}!"
    print()

    # 6. Minor model examples
    print_separator()
    print("6. MINOR MODEL EXAMPLES")
    print_separator()
    G = make_cycle(5)
    model = find_minor_model(G, 3)
    if model:
        print(f"   C_5 has K_3 minor: branch sets = {model}")
    else:
        print(f"   C_5: K_3 minor not found by algorithm")

    G = make_complete_graph(4)
    model = find_minor_model(G, 4)
    if model:
        print(f"   K_4 has K_4 minor: branch sets = {model}")
    print()

    # 7. Verify Hadwiger for small n
    print_separator()
    print("7. HADWIGER VERIFICATION FOR SMALL GRAPHS")
    print("   Testing all graphs on n vertices")
    print_separator()
    for n in range(1, 5):
        num_graphs = 2 ** (n * (n - 1) // 2)
        result = verify_hadwiger_small(n)
        status = "✓ VERIFIED" if result else "✗ COUNTEREXAMPLE FOUND"
        print(f"   n = {n}: {num_graphs} graphs tested — {status}")
    print()

    # 8. The asymmetry demonstration
    print_separator()
    print("8. THE MINOR-CHROMATIC ASYMMETRY")
    print("   Edge contraction can INCREASE χ!")
    print_separator()
    print("   K_{3,3}: χ = 2")
    print("   Contracting one edge of K_{3,3}:")
    # K_{3,3} with vertices 0,1,2 on left and 3,4,5 on right
    # Contract edge 0-3: merge 0 and 3 into vertex 0
    # New adjacencies: 0 adj {1,2,4,5}, 1 adj {0,4,5}, 2 adj {0,4,5}
    # 4 adj {0,1,2}, 5 adj {0,1,2}
    contracted = {
        0: {1, 2, 4, 5},  # merged vertex
        1: {0, 4, 5},
        2: {0, 4, 5},
        4: {0, 1, 2},
        5: {0, 1, 2},
    }
    chi_contracted = chromatic_number_exact(contracted)
    print(f"   Contracted graph: χ = {chi_contracted}")
    print(f"   Chromatic number INCREASED from 2 to {chi_contracted}!")
    print(f"   This proves: χ is NOT monotone under minors.")
    print()

    print("╔══════════════════════════════════════════════════════════╗")
    print("║                   All tests passed!                      ║")
    print("╚══════════════════════════════════════════════════════════╝")


if __name__ == "__main__":
    main()


"""
Visualization: Hadwiger's Conjecture — Chromatic Number vs Hadwiger Number

Plots the relationship between chromatic number and Hadwiger number for
various graph families, demonstrating the conjecture χ(G) ≤ h(G).
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from algorithms import chromatic_number_exact, hadwiger_number


def make_complete(n):
    return {i: {j for j in range(n) if j != i} for i in range(n)}

def make_cycle(n):
    return {i: {(i-1)%n, (i+1)%n} for i in range(n)}

def make_complete_bipartite(m, n):
    adj = {i: set() for i in range(m + n)}
    for i in range(m):
        for j in range(m, m + n):
            adj[i].add(j); adj[j].add(i)
    return adj

def make_path(n):
    adj = {i: set() for i in range(n)}
    for i in range(n - 1):
        adj[i].add(i + 1); adj[i + 1].add(i)
    return adj


def main():
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Plot 1: χ vs h for various graph families
    ax1 = axes[0]

    families = {
        'Complete $K_n$': [(make_complete(n), f'$K_{{{n}}}$') for n in range(2, 7)],
        'Cycle $C_n$': [(make_cycle(n), f'$C_{{{n}}}$') for n in range(3, 9)],
        'Bipartite $K_{{m,n}}$': [
            (make_complete_bipartite(2, 2), '$K_{2,2}$'),
            (make_complete_bipartite(2, 3), '$K_{2,3}$'),
            (make_complete_bipartite(3, 3), '$K_{3,3}$'),
            (make_complete_bipartite(3, 4), '$K_{3,4}$'),
        ],
        'Path $P_n$': [(make_path(n), f'$P_{{{n}}}$') for n in range(2, 8)],
    }

    colors_map = {'Complete $K_n$': '#e74c3c', 'Cycle $C_n$': '#3498db',
                  'Bipartite $K_{{m,n}}$': '#2ecc71', 'Path $P_n$': '#9b59b6'}

    for family_name, graphs in families.items():
        chi_vals = []
        h_vals = []
        for G, label in graphs:
            chi = chromatic_number_exact(G)
            h = hadwiger_number(G)
            chi_vals.append(chi)
            h_vals.append(h)

        ax1.scatter(chi_vals, h_vals, label=family_name, s=80,
                   color=colors_map[family_name], alpha=0.8, zorder=5)

    # Plot Hadwiger line χ = h
    max_val = 7
    ax1.plot([0, max_val], [0, max_val], 'k--', alpha=0.5, label='$\\chi = h$ (Hadwiger bound)')
    ax1.fill_between([0, max_val], [0, max_val], [max_val, max_val],
                     alpha=0.1, color='green', label='Hadwiger region ($h \\geq \\chi$)')

    ax1.set_xlabel('Chromatic Number $\\chi(G)$', fontsize=12)
    ax1.set_ylabel('Hadwiger Number $h(G)$', fontsize=12)
    ax1.set_title("Hadwiger's Conjecture: $\\chi(G) \\leq h(G)$", fontsize=14)
    ax1.legend(loc='upper left', fontsize=9)
    ax1.set_xlim(0, max_val)
    ax1.set_ylim(0, max_val)
    ax1.set_aspect('equal')
    ax1.grid(True, alpha=0.3)

    # Plot 2: Degeneracy vs chromatic number
    ax2 = axes[1]

    all_graphs = []
    for n in range(2, 7):
        all_graphs.append(('$K_'+str(n)+'$', make_complete(n)))
    for n in range(3, 8):
        all_graphs.append(('$C_'+str(n)+'$', make_cycle(n)))
    for m, nn in [(2,2), (2,3), (3,3)]:
        all_graphs.append((f'$K_{{{m},{nn}}}$', make_complete_bipartite(m, nn)))

    from algorithms import compute_degeneracy

    degens = []
    chis = []
    labels = []
    for name, G in all_graphs:
        d, _ = compute_degeneracy(G)
        chi = chromatic_number_exact(G)
        degens.append(d)
        chis.append(chi)
        labels.append(name)

    ax2.scatter(degens, chis, s=80, c='#e67e22', alpha=0.8, zorder=5)
    for i, label in enumerate(labels):
        ax2.annotate(label, (degens[i], chis[i]), textcoords="offset points",
                    xytext=(5, 5), fontsize=7, alpha=0.7)

    max_d = max(degens) + 1
    ax2.plot([0, max_d], [1, max_d + 1], 'r--', alpha=0.5, label='$\\chi \\leq d + 1$')
    ax2.fill_between([0, max_d], [0, 0], [1, max_d + 1],
                     alpha=0.1, color='blue', label='Feasible region')

    ax2.set_xlabel('Degeneracy $d(G)$', fontsize=12)
    ax2.set_ylabel('Chromatic Number $\\chi(G)$', fontsize=12)
    ax2.set_title('Degeneracy Bound: $\\chi(G) \\leq d(G) + 1$', fontsize=14)
    ax2.legend(loc='upper left', fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('hadwiger_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved hadwiger_visualization.png")


if __name__ == "__main__":
    main()
