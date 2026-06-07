#!/usr/bin/env python3
"""
Demonstration of the Entropy-Bounded Computation framework.

Computes concrete numerical examples of the key theorems:
1. Landauer cost of bit erasure
2. Step count bounds from entropy budgets
3. Maxwell's demon efficiency
4. Entropy gap between P and NP search spaces
5. Entropy costs of real-world computations
"""

import math

# Physical constants
k_B = 1.380649e-23  # Boltzmann constant (J/K)
T_room = 300  # Room temperature (K)
kT = k_B * T_room  # Thermal energy at room temperature
LANDAUER_BIT = kT * math.log(2)  # Minimum cost to erase one bit


def landauer_cost(n_bits: int, temperature: float = T_room) -> float:
    """Minimum entropy cost of erasing n_bits at given temperature (in Joules)."""
    return n_bits * k_B * temperature * math.log(2)


def step_count_bound(budget_joules: float, cost_per_step: float) -> float:
    """Maximum number of irreversible steps given an entropy budget."""
    return budget_joules / cost_per_step


def demon_bound(n_particles: int, bits_per_particle: float,
                temperature: float = T_room) -> float:
    """Maximum entropy decrease achievable by Maxwell's demon."""
    return n_particles * bits_per_particle * k_B * temperature * math.log(2)


def entropy_gap(c: float, n: int) -> float:
    """Entropy gap: c*n - c*log(n) for the P vs NP separation."""
    if n <= 0:
        return 0.0
    return c * n - c * math.log(n)


def search_entropy(search_space_size: int, temperature: float = T_room) -> float:
    """Minimum entropy required to search a space of given size."""
    if search_space_size <= 0:
        return 0.0
    return k_B * temperature * math.log(search_space_size)


def main():
    print("=" * 70)
    print("ENTROPY-BOUNDED COMPUTATION: Numerical Demonstrations")
    print("=" * 70)

    # Demo 1: Landauer cost of bit erasure
    print("\n--- Demo 1: Landauer Cost of Bit Erasure ---")
    print(f"Temperature: {T_room} K")
    print(f"kT = {kT:.4e} J")
    print(f"Landauer cost per bit: {LANDAUER_BIT:.4e} J")
    for n in [1, 8, 64, 256, 1024]:
        cost = landauer_cost(n)
        print(f"  Erasing {n:>4} bits costs at least {cost:.4e} J")

    # Demo 2: Step count bounds
    print("\n--- Demo 2: Step Count Bounds ---")
    energies = [
        ("AA battery (1 J)", 1.0),
        ("Human body (100 W × 1 s)", 100.0),
        ("Lightning bolt (1 GJ)", 1e9),
        ("Sun per second (3.8e26 W)", 3.8e26),
    ]
    for name, energy in energies:
        max_steps = step_count_bound(energy, LANDAUER_BIT)
        print(f"  {name}: max {max_steps:.2e} irreversible steps")

    # Demo 3: Maxwell's demon
    print("\n--- Demo 3: Maxwell's Demon Efficiency ---")
    particles = [100, 1000, 1_000_000, 6.022e23]
    for n in particles:
        bound = demon_bound(int(n), 1.0)
        print(f"  {n:.2e} particles, 1 bit/particle: "
              f"max entropy decrease = {bound:.4e} J/K")

    # Demo 4: Entropy gap (P vs NP)
    print("\n--- Demo 4: Entropy Gap (P vs NP Signature) ---")
    print("  The gap c*n - c*ln(n) grows without bound:")
    c = 1.0
    for n in [10, 100, 1000, 10000, 100000, 1000000]:
        gap = entropy_gap(c, n)
        print(f"  n = {n:>10}: gap = {gap:>15.2f}")

    # Demo 5: Search entropy for cryptographic key spaces
    print("\n--- Demo 5: Search Entropy for Key Spaces ---")
    key_lengths = [56, 128, 256, 512, 1024, 4096]
    for bits in key_lengths:
        search_size = 2 ** bits
        entropy = search_entropy(search_size)
        print(f"  {bits:>4}-bit key: search entropy = {entropy:.4e} J "
              f"= {bits} × kT·ln(2)")

    # Demo 6: Comparison of P vs NP entropy costs
    print("\n--- Demo 6: P vs NP Entropy Cost Comparison ---")
    print("  For input size n, P costs O(log n) entropy, NP costs O(n) entropy:")
    for n in [10, 100, 1000, 10000]:
        p_cost = math.log(n) * LANDAUER_BIT
        np_cost = n * LANDAUER_BIT
        ratio = np_cost / p_cost
        print(f"  n = {n:>6}: P cost = {p_cost:.4e} J, "
              f"NP cost = {np_cost:.4e} J, ratio = {ratio:.1f}×")

    # Demo 7: Physical limits of computation
    print("\n--- Demo 7: Ultimate Physical Limits ---")
    h_bar = 1.054571817e-34  # Reduced Planck constant
    energy = 1.0  # 1 Joule
    margolus_levitin = 2 * energy / (math.pi * h_bar)
    max_bit_rate = margolus_levitin / (kT * math.log(2))
    print(f"  Margolus-Levitin bound (1 J): {margolus_levitin:.4e} ops/s")
    print(f"  Max irreversible bit rate: {max_bit_rate:.4e} bits/s")
    print(f"  Modern CPU (~10 GHz): {1e10:.4e} ops/s")
    print(f"  Gap to physical limit: {margolus_levitin / 1e10:.4e}×")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: The Entropy Gap between P and NP search spaces.

Plots the thermodynamic signature of P ≠ NP: the unbounded gap between
linear entropy (NP search) and logarithmic entropy (P computation).
"""

import math

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np


def plot_entropy_gap():
    """Plot the entropy gap c*n - c*log(n) showing P vs NP separation."""
    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Thermodynamic Signature of P ≠ NP', fontsize=16, fontweight='bold')

    n = np.linspace(1, 1000, 1000)

    # Panel 1: NP vs P entropy costs
    ax = axes[0, 0]
    np_cost = n  # Linear: n bits
    p_cost = np.log(n)  # Logarithmic: log(n) bits
    ax.plot(n, np_cost, 'r-', linewidth=2, label='NP search: n bits')
    ax.plot(n, p_cost, 'b-', linewidth=2, label='P computation: log(n) bits')
    ax.fill_between(n, p_cost, np_cost, alpha=0.2, color='orange',
                     label='Entropy gap')
    ax.set_xlabel('Input size n')
    ax.set_ylabel('Entropy cost (bits)')
    ax.set_title('NP vs P Entropy Costs')
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    # Panel 2: Entropy gap growth
    ax = axes[0, 1]
    gap = n - np.log(n)
    ax.plot(n, gap, 'purple', linewidth=2)
    ax.set_xlabel('Input size n')
    ax.set_ylabel('Gap: n - log(n)')
    ax.set_title('Entropy Gap (grows without bound)')
    ax.grid(True, alpha=0.3)
    # Add annotations for specific values
    for n_val in [100, 500, 900]:
        g = n_val - math.log(n_val)
        ax.annotate(f'n={n_val}\ngap={g:.0f}',
                    xy=(n_val, g), fontsize=8,
                    arrowprops=dict(arrowstyle='->', color='gray'),
                    xytext=(n_val - 100, g + 100))

    # Panel 3: Step count bounds for different budgets
    ax = axes[1, 0]
    budgets = [100, 500, 1000, 5000]
    colors = ['#1f77b4', '#ff7f0e', '#2ca02c', '#d62728']
    c_range = np.linspace(0.1, 10, 200)
    for budget, color in zip(budgets, colors):
        max_steps = budget / c_range
        ax.plot(c_range, max_steps, color=color, linewidth=2,
                label=f'Budget = {budget} bits')
    ax.set_xlabel('Cost per step (bits)')
    ax.set_ylabel('Maximum steps')
    ax.set_title('Step Count Bound: n ≤ B/c')
    ax.legend(fontsize=9)
    ax.set_yscale('log')
    ax.grid(True, alpha=0.3)

    # Panel 4: Maxwell's demon efficiency
    ax = axes[1, 1]
    n_particles = np.arange(1, 101)
    for bits in [0.5, 1.0, 2.0, 4.0]:
        max_decrease = n_particles * bits  # in units of kT·ln(2)
        ax.plot(n_particles, max_decrease, linewidth=2,
                label=f'{bits} bits/particle')
    ax.set_xlabel('Number of particles')
    ax.set_ylabel('Max entropy decrease (kT·ln2 units)')
    ax.set_title("Maxwell's Demon: Entropy Bound")
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('entropy_gap_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: entropy_gap_visualization.png")


def plot_landauer_hierarchy():
    """Plot the Landauer cost hierarchy for different computations."""
    fig, ax = plt.subplots(figsize=(12, 6))

    n = np.arange(2, 100)

    # Different computation types and their entropy costs
    computations = [
        ('Reversible (bijective)', np.zeros_like(n, dtype=float), '#2ca02c'),
        ('Binary search: log₂(n)', np.log2(n), '#1f77b4'),
        ('Sorting: n·log₂(n)', n * np.log2(n), '#ff7f0e'),
        ('Quadratic: n²', n**2, '#d62728'),
        ('Exponential: 2ⁿ', 2.0**np.minimum(n, 30), '#9467bd'),  # cap for display
    ]

    for name, cost, color in computations:
        ax.plot(n, cost, color=color, linewidth=2.5, label=name)

    ax.set_xlabel('Input size n', fontsize=12)
    ax.set_ylabel('Landauer cost (bits)', fontsize=12)
    ax.set_title('Thermodynamic Cost Hierarchy of Computations', fontsize=14)
    ax.set_yscale('log')
    ax.set_ylim(0.5, 1e10)
    ax.legend(fontsize=10, loc='upper left')
    ax.grid(True, alpha=0.3)

    # Annotate the P/NP boundary
    ax.axhline(y=1e6, color='gray', linestyle='--', alpha=0.5)
    ax.text(50, 2e6, 'Typical entropy budget', fontsize=10, color='gray',
            ha='center')

    plt.tight_layout()
    plt.savefig('landauer_hierarchy.png', dpi=150, bbox_inches='tight')
    print("Saved: landauer_hierarchy.png")


if __name__ == "__main__":
    plot_entropy_gap()
    plot_landauer_hierarchy()
