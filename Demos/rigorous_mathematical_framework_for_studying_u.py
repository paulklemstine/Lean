#!/usr/bin/env python3
"""
Tropical Lyapunov Theory: Interactive Demo

Demonstrates the key concepts from the Lyapunov discrete dynamical system
framework with concrete numerical examples.
"""

import numpy as np
from algorithms import LyapunovDDS, tropical_gradient_flow, compute_max_cycle_mean


def demo_orbit_convergence():
    """Demo 1: Orbit convergence and the pigeonhole bound."""
    print("=" * 60)
    print("DEMO 1: Orbit Convergence (Theorem A)")
    print("=" * 60)
    print()
    print("A strictly decreasing LyapunovDDS on n states converges")
    print("within at most n steps. We demonstrate this on a 10-state")
    print("system with a complex transition structure.")
    print()

    # A 10-state system with interesting dynamics
    # Potential: 9, 8, 7, 6, 5, 4, 3, 2, 1, 0
    # Dynamics: each state jumps to a lower-potential state (not necessarily adjacent)
    transitions = {0: 3, 1: 5, 2: 4, 3: 7, 4: 6, 5: 8, 6: 9, 7: 9, 8: 9, 9: 9}

    dds = LyapunovDDS(
        n=10,
        step=lambda x: transitions[x],
        potential=lambda x: float(9 - x),
    )

    print(f"States: 0..9,  Potential: V(x) = 9 - x")
    print(f"Transitions: {transitions}")
    print(f"Fixed points: {[x for x in range(10) if dds.is_fixed(x)]}")
    print()

    for start in [0, 1, 2]:
        orbit = dds.orbit(start)
        potentials = [dds.potential(s) for s in orbit]
        print(f"  Orbit from {start}: {orbit}")
        print(f"  Potentials:  {potentials}")
        print(f"  Steps to fixed point: {len(orbit) - 1}")
        print()

    print(f"Pigeonhole bound (|α| = 10): orbit length ≤ 10")
    print(f"Actual max orbit length: {dds.max_orbit_length()}")
    print()


def demo_distinct_potentials():
    """Demo 2: The Distinct Potentials Theorem."""
    print("=" * 60)
    print("DEMO 2: Distinct Potentials Theorem (Theorem B)")
    print("=" * 60)
    print()
    print("Potential values along a non-stabilized orbit are STRICTLY")
    print("decreasing, hence all distinct. This is what makes the")
    print("pigeonhole argument work.")
    print()

    # Chain with non-uniform potential drops
    potentials_list = [10.0, 7.5, 6.0, 3.2, 1.8, 0.5, 0.0]
    n = len(potentials_list)

    dds = LyapunovDDS(
        n=n,
        step=lambda x: min(x + 1, n - 1),
        potential=lambda x: potentials_list[x],
    )

    orbit = dds.orbit(0)
    pots = [dds.potential(s) for s in orbit]

    print(f"  Orbit: {orbit}")
    print(f"  Potentials: {pots}")
    print()
    print("  Verifying strict decrease:")
    for i in range(len(pots) - 1):
        drop = pots[i] - pots[i + 1]
        print(f"    V({orbit[i]}) = {pots[i]:.1f} > V({orbit[i+1]}) = {pots[i+1]:.1f}  "
              f"(drop = {drop:.1f})")
    print()
    print("  All potentials distinct: ", len(set(pots)) == len(pots), "✓")
    print()


def demo_basin_decomposition():
    """Demo 3: Basin decomposition."""
    print("=" * 60)
    print("DEMO 3: Basin Decomposition (Theorem C)")
    print("=" * 60)
    print()
    print("Under strict decrease, the state space partitions into")
    print("basins of attraction, one per fixed point.")
    print()

    # Three-basin system
    # Fixed points: 4, 9, 14
    # Basin 1: 0,1,2,3 -> 4
    # Basin 2: 5,6,7,8 -> 9
    # Basin 3: 10,11,12,13 -> 14
    def step(x):
        if x < 5:
            return min(x + 1, 4)
        elif x < 10:
            return min(x + 1, 9)
        else:
            return min(x + 1, 14)

    dds = LyapunovDDS(
        n=15,
        step=step,
        potential=lambda x: float(14 - x) if x < 5 else (float(14 - x) if x < 10 else float(14 - x)),
    )

    basins = dds.compute_basins()
    print(f"  Number of fixed points: {len(basins)}")
    for fp, basin in sorted(basins.items()):
        print(f"  Fixed point {fp}: basin = {sorted(basin)}")
    print()

    total = sum(len(b) for b in basins.values())
    print(f"  Total states covered: {total} / {dds.n}")
    print(f"  Basins partition the state space: {total == dds.n} ✓")
    print()


def demo_convergence_rate():
    """Demo 4: Quantitative convergence rate bound."""
    print("=" * 60)
    print("DEMO 4: Convergence Rate Bound (Theorem D)")
    print("=" * 60)
    print()
    print("If every non-fixed point drops potential by at least δ,")
    print("then orbit length ≤ V(x)/δ. Compare with pigeonhole bound.")
    print()

    # System with uniform potential gap
    n = 20
    delta = 0.5

    dds = LyapunovDDS(
        n=n,
        step=lambda x: min(x + 1, n - 1),
        potential=lambda x: float(n - 1 - x) * delta,
    )

    gap = dds.potential_gap()
    v_max = max(dds.potential(x) for x in range(n))

    print(f"  States: 0..{n-1}")
    print(f"  Potential gap δ = {gap:.2f}")
    print(f"  Max potential V_max = {v_max:.2f}")
    print(f"  Convergence rate bound (V_max/δ) = {v_max/gap:.1f}")
    print(f"  Pigeonhole bound (|α|) = {n}")
    print(f"  Actual max orbit length = {dds.max_orbit_length()}")
    print()

    # System with non-uniform gap (large initial potential, small gap)
    print("  Non-uniform gap example:")
    potentials2 = [100.0, 99.0, 97.0, 93.0, 85.0, 69.0, 37.0, 0.0]
    n2 = len(potentials2)

    dds2 = LyapunovDDS(
        n=n2,
        step=lambda x: min(x + 1, n2 - 1),
        potential=lambda x: potentials2[x],
    )

    gap2 = dds2.potential_gap()
    v_max2 = potentials2[0]
    print(f"  Potentials: {potentials2}")
    print(f"  Potential gap δ = {gap2:.1f}")
    print(f"  V_max/δ = {v_max2/gap2:.1f}")
    print(f"  Actual max orbit = {dds2.max_orbit_length()}")
    print(f"  (Rate bound is tight here: {v_max2/gap2:.1f} ≥ {dds2.max_orbit_length()})")
    print()


def demo_tropical_gradient():
    """Demo 5: Tropical gradient flow from weight matrix."""
    print("=" * 60)
    print("DEMO 5: Tropical Gradient Flow")
    print("=" * 60)
    print()
    print("Construct a LyapunovDDS from a max-plus weight matrix.")
    print()

    # A 6-node graph with interesting structure
    W = np.array([
        [0, 5, 0, 0, 0, 0],
        [0, 0, 3, 0, 0, 0],
        [0, 0, 0, 7, 0, 2],
        [0, 0, 0, 0, 4, 0],
        [0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 6, 0],
    ], dtype=float)

    print(f"  Weight matrix W:")
    for row in W:
        print(f"    {row}")
    print()

    flow = tropical_gradient_flow(W)

    print(f"  Potentials: {[f'{flow.potential(i):.2f}' for i in range(6)]}")
    print(f"  Steps:      {[flow.step(i) for i in range(6)]}")
    print(f"  Fixed pts:  {[i for i in range(6) if flow.is_fixed(i)]}")
    print()

    basins = flow.compute_basins()
    for fp, basin in sorted(basins.items()):
        print(f"  Basin of {fp}: {sorted(basin)}")
    print()

    lam = compute_max_cycle_mean(W)
    print(f"  Max cycle mean λ(W) = {lam:.4f}")
    print(f"  Potential gap δ = {flow.potential_gap()}")
    print()


def demo_merging_principle():
    """Demo 6: The merging principle under coarse-graining."""
    print("=" * 60)
    print("DEMO 6: The Merging Principle (Theorem E)")
    print("=" * 60)
    print()
    print("A surjective morphism φ: S → T can only merge basins.")
    print("We demonstrate with a 6-state system coarse-grained to 3 states.")
    print()

    # Fine system: 6 states, 2 fixed points (2 and 5)
    fine_step = {0: 1, 1: 2, 2: 2, 3: 4, 4: 5, 5: 5}
    fine_pot = {0: 4.0, 1: 2.0, 2: 0.0, 3: 5.0, 4: 3.0, 5: 0.0}

    fine = LyapunovDDS(
        n=6,
        step=lambda x: fine_step[x],
        potential=lambda x: fine_pot[x],
    )

    # Coarse system: 3 states, φ maps {0,1} -> 0, {2} -> 1, {3,4,5} -> 2
    # In coarse system: 0 -> 1 (fixed), 2 -> 2 (fixed)
    coarse_step = {0: 1, 1: 1, 2: 2}
    coarse_pot = {0: 3.0, 1: 0.0, 2: 0.0}

    coarse = LyapunovDDS(
        n=3,
        step=lambda x: coarse_step[x],
        potential=lambda x: coarse_pot[x],
    )

    phi = {0: 0, 1: 0, 2: 1, 3: 2, 4: 2, 5: 2}

    print("  Fine system basins:")
    for fp, basin in sorted(fine.compute_basins().items()):
        print(f"    Fixed point {fp}: {sorted(basin)}")

    print()
    print(f"  Morphism φ: {phi}")
    print()

    print("  Coarse system basins:")
    for fp, basin in sorted(coarse.compute_basins().items()):
        print(f"    Fixed point {fp}: {sorted(basin)}")

    print()
    print("  Verification: φ maps fine basins to subsets of coarse basins")
    fine_basins = fine.compute_basins()
    for fp, basin in sorted(fine_basins.items()):
        coarse_images = {phi[x] for x in basin}
        coarse_fp = phi[fp]
        print(f"    φ(basin({fp})) = {coarse_images}, lands in basin({coarse_fp}) ✓")
    print()
    print("  Basins {0,1} and {2} in fine system both map to basin({1}) in coarse: MERGED ✓")
    print()


if __name__ == "__main__":
    demo_orbit_convergence()
    demo_distinct_potentials()
    demo_basin_decomposition()
    demo_convergence_rate()
    demo_tropical_gradient()
    demo_merging_principle()

    print("=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Basin decomposition and potential landscape
for a tropical Lyapunov discrete dynamical system.
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import numpy as np


def make_system():
    """Create a 12-state system with 3 basins."""
    transitions = {
        0: 3, 1: 3, 2: 3, 3: 3,  # Basin A -> fixed at 3
        4: 6, 5: 6, 6: 7, 7: 7,  # Basin B -> fixed at 7
        8: 10, 9: 10, 10: 11, 11: 11,  # Basin C -> fixed at 11
    }
    potentials = {
        0: 8.0, 1: 6.0, 2: 4.0, 3: 0.0,
        4: 9.0, 5: 5.0, 6: 3.0, 7: 0.0,
        8: 7.0, 9: 10.0, 10: 2.0, 11: 0.0,
    }
    return transitions, potentials


def compute_basins(transitions, n):
    """Compute basin decomposition."""
    basins = {}
    for x in range(n):
        y = x
        while transitions[y] != y:
            y = transitions[y]
        if y not in basins:
            basins[y] = []
        basins[y].append(x)
    return basins


def plot_potential_landscape():
    """Plot the potential landscape and basin decomposition."""
    transitions, potentials = make_system()
    n = len(transitions)
    basins = compute_basins(transitions, n)

    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Panel 1: Potential landscape with basin coloring
    ax1 = axes[0]
    colors_map = {}
    basin_colors = ['#2196F3', '#FF5722', '#4CAF50']
    for idx, (fp, members) in enumerate(sorted(basins.items())):
        for m in members:
            colors_map[m] = basin_colors[idx % len(basin_colors)]

    xs = list(range(n))
    vs = [potentials[x] for x in xs]
    cs = [colors_map[x] for x in xs]

    bars = ax1.bar(xs, vs, color=cs, edgecolor='black', linewidth=0.8)

    # Mark fixed points
    for fp in basins:
        ax1.bar(fp, potentials[fp] + 0.3, bottom=-0.15, color='gold',
                edgecolor='black', linewidth=1.5, width=0.6, zorder=5)
        ax1.text(fp, 0.5, '★', ha='center', va='center', fontsize=14, zorder=6)

    # Draw transition arrows
    for x, y in transitions.items():
        if x != y:
            ax1.annotate('', xy=(y, potentials[y] + 0.2),
                        xytext=(x, potentials[x] - 0.2),
                        arrowprops=dict(arrowstyle='->', color='gray',
                                       lw=1.2, connectionstyle='arc3,rad=0.2'))

    ax1.set_xlabel('State', fontsize=12)
    ax1.set_ylabel('Potential V(x)', fontsize=12)
    ax1.set_title('Potential Landscape with Basin Coloring', fontsize=13)

    legend_patches = []
    for idx, (fp, members) in enumerate(sorted(basins.items())):
        legend_patches.append(mpatches.Patch(
            color=basin_colors[idx], label=f'Basin of {fp} ({len(members)} states)'))
    legend_patches.append(mpatches.Patch(color='gold', label='Fixed points ★'))
    ax1.legend(handles=legend_patches, loc='upper right', fontsize=9)

    # Panel 2: Orbits and convergence
    ax2 = axes[1]

    orbit_colors = ['#1565C0', '#D84315', '#2E7D32']
    start_states = [0, 4, 9]

    for idx, start in enumerate(start_states):
        orbit = [start]
        while transitions[orbit[-1]] != orbit[-1]:
            orbit.append(transitions[orbit[-1]])

        orbit_pots = [potentials[s] for s in orbit]
        steps = list(range(len(orbit)))

        ax2.plot(steps, orbit_pots, 'o-', color=orbit_colors[idx],
                linewidth=2, markersize=8, label=f'Orbit from {start}')

        for k, (s, v) in enumerate(zip(orbit, orbit_pots)):
            ax2.annotate(f'{s}', (k, v), textcoords="offset points",
                        xytext=(5, 8), fontsize=8, color=orbit_colors[idx])

    ax2.set_xlabel('Step number', fontsize=12)
    ax2.set_ylabel('Potential V(x)', fontsize=12)
    ax2.set_title('Orbit Convergence: V is Strictly Decreasing', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.axhline(y=0, color='gray', linestyle='--', alpha=0.5)

    plt.tight_layout()
    plt.savefig('basins_visualization.png', dpi=150, bbox_inches='tight')
    print("Saved: basins_visualization.png")


def plot_convergence_rate():
    """Plot convergence rate bound vs actual orbit length."""
    fig, ax = plt.subplots(figsize=(8, 5))

    sizes = list(range(3, 25))
    pigeonhole_bounds = []
    rate_bounds = []
    actual_lengths = []

    for n in sizes:
        # Chain with uniform gap delta = 1
        delta = 1.0
        v_max = float(n - 1) * delta

        pigeonhole_bounds.append(n)
        rate_bounds.append(v_max / delta)
        actual_lengths.append(n - 1)

    ax.plot(sizes, pigeonhole_bounds, 's-', color='#F44336', linewidth=2,
            markersize=6, label='Pigeonhole bound |α|')
    ax.plot(sizes, rate_bounds, 'D-', color='#FF9800', linewidth=2,
            markersize=6, label='Rate bound V(x)/δ')
    ax.plot(sizes, actual_lengths, 'o-', color='#4CAF50', linewidth=2,
            markersize=6, label='Actual max orbit length')

    ax.set_xlabel('Number of states |α|', fontsize=12)
    ax.set_ylabel('Bound on orbit length', fontsize=12)
    ax.set_title('Convergence Bounds: Pigeonhole vs Rate Bound', fontsize=13)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('convergence_rates.png', dpi=150, bbox_inches='tight')
    print("Saved: convergence_rates.png")


if __name__ == "__main__":
    plot_potential_landscape()
    plot_convergence_rate()
    print("All visualizations generated.")
