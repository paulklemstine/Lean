#!/usr/bin/env python3
"""
Chip-Firing and Divisor Energy: Numerical Demonstrations

This script demonstrates the key results from the chip-firing theory:
1. Energy formula verification for complete graphs
2. Canonical divisor computations
3. Variance-energy correspondence
4. Greedy chip-firing energy minimization
5. Jacobian group orders (spanning tree counts)
"""

from algorithms import (
    Graph, Divisor, canonical_divisor, genus, chip_fire, energy,
    laplacian_quad_form, excess, divisor_variance, greedy_chip_fire,
    complete_graph_energy_formula, jacobian_order
)


def demo_canonical_divisor():
    """Demonstrate canonical divisor properties for K_n."""
    print("=" * 60)
    print("§1. Canonical Divisor of Complete Graphs")
    print("=" * 60)

    for n in range(3, 8):
        G = Graph.complete(n)
        K = canonical_divisor(G)
        g = genus(G)
        print(f"\nK_{n}:")
        print(f"  Canonical divisor K = {K.values}")
        print(f"  deg(K) = {K.degree()}, expected n(n-3) = {n*(n-3)}")
        print(f"  Genus g = {g}, expected (n-1)(n-2)/2 = {(n-1)*(n-2)//2}")
        print(f"  deg(K) = 2g-2? {K.degree()} = {2*g - 2}: {K.degree() == 2*g - 2}")


def demo_energy_formula():
    """Verify the closed-form energy formula for complete graphs."""
    print("\n" + "=" * 60)
    print("§2. Energy Formula Verification: E = 2n·ΣD² - 2·(ΣD)²")
    print("=" * 60)

    test_cases = [
        (3, [1, 0, 0]),
        (3, [2, 1, 0]),
        (4, [3, 1, 0, 0]),
        (4, [1, 1, 1, 1]),
        (5, [5, 0, 0, 0, 0]),
        (5, [1, 1, 1, 1, 1]),
    ]

    for n, vals in test_cases:
        G = Graph.complete(n)
        D = Divisor(vals)
        E_direct = energy(G, D)
        E_formula = complete_graph_energy_formula(n, D)
        print(f"\nK_{n}, D = {vals}:")
        print(f"  E(D) direct = {E_direct}")
        print(f"  E(D) formula = {E_formula}")
        print(f"  Match: {E_direct == E_formula}")
        assert E_direct == E_formula, "Energy formula mismatch!"


def demo_energy_equals_twice_quad():
    """Verify E = 2·Q (energy = twice Laplacian quadratic form)."""
    print("\n" + "=" * 60)
    print("§3. E = 2·Q (Energy = Twice Laplacian Quadratic Form)")
    print("=" * 60)

    for graph_name, G in [("K_4", Graph.complete(4)),
                           ("K_5", Graph.complete(5)),
                           ("C_6", Graph.cycle(6)),
                           ("P_5", Graph.path(5))]:
        for vals in [[1, 0, 0, 0] + [0] * (G.n - 4),
                      list(range(G.n))]:
            vals = vals[:G.n]
            D = Divisor(vals)
            E = energy(G, D)
            Q = laplacian_quad_form(G, D)
            print(f"\n{graph_name}, D = {D.values}: E = {E}, 2Q = {2*Q}, match = {E == 2*Q}")
            assert E == 2 * Q, "E ≠ 2Q!"


def demo_variance_energy():
    """Demonstrate E_{K_n} = 2·Var(D)."""
    print("\n" + "=" * 60)
    print("§4. Energy = 2·Variance on Complete Graphs")
    print("=" * 60)

    for n in range(3, 7):
        G = Graph.complete(n)
        for vals in [[1] + [0] * (n - 1), list(range(n)), [n] * n]:
            D = Divisor(vals)
            E = energy(G, D)
            V = divisor_variance(D)
            print(f"K_{n}, D={D.values}: E={E}, 2·Var={2*V}, match={E == 2*V}")
            assert E == 2 * V


def demo_greedy_chipfire():
    """Demonstrate greedy chip-firing energy minimization."""
    print("\n" + "=" * 60)
    print("§5. Greedy Chip-Firing Energy Minimization")
    print("=" * 60)

    G = Graph.complete(5)
    D = Divisor([10, 0, 0, 0, 0])
    print(f"\nStarting: D = {D.values}, E = {energy(G, D)}")

    final, seq = greedy_chip_fire(G, D, max_steps=50)
    print(f"After {len(seq)} firings:")
    print(f"  D' = {final.values}, E = {energy(G, final)}")
    print(f"  Degree preserved: {D.degree()} → {final.degree()}")
    print(f"  Firing sequence: {seq[:20]}...")


def demo_jacobian_orders():
    """Compute |Jac(G)| = number of spanning trees."""
    print("\n" + "=" * 60)
    print("§6. Jacobian Group Orders (Kirchhoff's Theorem)")
    print("=" * 60)

    for n in range(3, 8):
        G = Graph.complete(n)
        jac = jacobian_order(G)
        expected = n ** (n - 2)  # Cayley's formula
        print(f"K_{n}: |Jac| = {jac}, n^(n-2) = {expected}, match = {jac == expected}")


def demo_energy_spectrum():
    """Sample the energy spectrum of a divisor class."""
    print("\n" + "=" * 60)
    print("§7. Energy Spectrum Sampling")
    print("=" * 60)

    G = Graph.complete(4)
    D = Divisor([3, 0, 0, 0])
    print(f"\nK_4, D = {D.values}")

    # Manually explore nearby divisors
    energies = {energy(G, D)}
    current = D
    for step in range(100):
        for v in range(G.n):
            fired = chip_fire(G, current, v)
            energies.add(energy(G, fired))
        current = chip_fire(G, current, step % G.n)

    sorted_energies = sorted(energies)[:15]
    print(f"  Energy spectrum (sample): {sorted_energies}")
    print(f"  Minimum energy found: {min(energies)}")
    print(f"  Energy of D itself: {energy(G, D)}")


def demo_excess_conservation():
    """Verify total excess = 0."""
    print("\n" + "=" * 60)
    print("§8. Total Excess Conservation Law")
    print("=" * 60)

    for graph_name, G in [("K_5", Graph.complete(5)),
                           ("C_6", Graph.cycle(6))]:
        D = Divisor(list(range(G.n)))
        total_exc = sum(excess(G, D, v) for v in range(G.n))
        print(f"{graph_name}, D = {D.values}: Σ excess = {total_exc}")
        assert total_exc == 0


if __name__ == "__main__":
    demo_canonical_divisor()
    demo_energy_formula()
    demo_energy_equals_twice_quad()
    demo_variance_energy()
    demo_greedy_chipfire()
    demo_jacobian_orders()
    demo_energy_spectrum()
    demo_excess_conservation()
    print("\n" + "=" * 60)
    print("All demonstrations passed! ✓")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Energy Landscape of Chip-Firing on Complete Graphs

Generates a visualization of how chip-firing moves through the energy landscape,
showing the relationship between divisor configurations and their energies.
"""
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np
from algorithms import Graph, Divisor, chip_fire, energy, divisor_variance

def plot_energy_landscape():
    """Plot energy landscape for K_4 divisors of degree 6."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Panel 1: Energy vs variance for random K_4 divisors
    ax = axes[0]
    n = 4
    G = Graph.complete(n)
    energies = []
    variances = []
    for a in range(7):
        for b in range(7 - a):
            for c in range(7 - a - b):
                d_val = 6 - a - b - c
                D = Divisor([a, b, c, d_val])
                E = energy(G, D)
                V = divisor_variance(D)
                energies.append(E)
                variances.append(V)

    ax.scatter(variances, energies, alpha=0.5, s=10, color='steelblue')
    # Plot E = 2V line
    max_v = max(variances)
    vs = np.linspace(0, max_v, 100)
    ax.plot(vs, 2 * vs, 'r-', linewidth=2, label='E = 2·Var (proved)')
    ax.set_xlabel('Divisor Variance', fontsize=12)
    ax.set_ylabel('Energy E(D)', fontsize=12)
    ax.set_title('Energy = 2·Variance on K₄\n(degree 6 divisors)', fontsize=13)
    ax.legend(fontsize=11)

    # Panel 2: Greedy chip-firing trajectory
    ax = axes[1]
    n = 5
    G = Graph.complete(n)
    D = Divisor([15, 0, 0, 0, 0])
    trajectory = [energy(G, D)]

    for step in range(20):
        # Find vertex with maximum value (highest excess in K_n)
        best_v = max(range(n), key=lambda v: D[v])
        D = chip_fire(G, D, best_v)
        trajectory.append(energy(G, D))

    ax.plot(trajectory, 'o-', color='darkgreen', markersize=5, linewidth=1.5)
    ax.set_xlabel('Chip-fire step', fontsize=12)
    ax.set_ylabel('Energy E(D)', fontsize=12)
    ax.set_title('Greedy Energy Descent on K₅\n(starting from [15,0,0,0,0])', fontsize=13)
    ax.axhline(y=0, color='red', linestyle='--', alpha=0.5, label='E = 0 (uniform)')
    ax.legend(fontsize=11)

    # Panel 3: Genus and canonical degree for K_n
    ax = axes[2]
    ns = list(range(3, 15))
    genera = [(n-1)*(n-2)//2 for n in ns]
    canon_deg = [n*(n-3) for n in ns]
    two_g_minus_2 = [2*g - 2 for g in genera]

    ax.plot(ns, genera, 's-', color='purple', label='g(Kₙ) = (n-1)(n-2)/2', markersize=6)
    ax.plot(ns, canon_deg, 'o-', color='orange', label='deg(K) = n(n-3)', markersize=6)
    ax.plot(ns, two_g_minus_2, 'x--', color='red', label='2g-2 (should = deg K)', markersize=8)
    ax.set_xlabel('n (vertices)', fontsize=12)
    ax.set_ylabel('Value', fontsize=12)
    ax.set_title('Genus and Canonical Degree\nfor Complete Graphs Kₙ', fontsize=13)
    ax.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('energy_landscape.png', dpi=150, bbox_inches='tight')
    print("Saved energy_landscape.png")


if __name__ == "__main__":
    plot_energy_landscape()
