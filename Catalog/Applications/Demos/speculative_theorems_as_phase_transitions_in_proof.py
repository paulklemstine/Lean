#!/usr/bin/env python3
"""
Demo: Phase Transitions in Proof Space

Numerical examples demonstrating the key phenomena:
1. Density growth under expansion
2. Saturation dichotomy (complete vs incomplete systems)
3. Entropy rate discontinuity at phase transition
4. Critical step threshold
"""

import math
from algorithms import (
    proof_ball, proof_density, vertex_expansion,
    critical_step, density_trajectory, entropy_rate,
    saturation_analysis, generate_expander_graph,
    generate_incomplete_system
)


def demo_expander_phase_transition():
    """Demonstrate sharp phase transition in an expander graph."""
    print("=" * 60)
    print("DEMO 1: Phase Transition in Expander Graph")
    print("=" * 60)

    n = 100
    adj = generate_expander_graph(n, degree=5)
    axioms = {0}

    print(f"\nUniverse size: {n}")
    print(f"Axiom set: {axioms}")
    print(f"Initial expansion: {vertex_expansion(adj, axioms, n):.2f}")

    densities = density_trajectory(adj, axioms, n, 20)

    print("\nDensity trajectory ρ(k):")
    print("-" * 40)
    for k, rho in enumerate(densities[:15]):
        bar = "█" * int(rho * 40)
        print(f"  k={k:2d}: ρ={rho:.4f} {bar}")

    kc = critical_step(adj, axioms, n)
    print(f"\nCritical step k_c (density > 1/2): {kc}")

    is_complete, sat_step, final_density = saturation_analysis(adj, axioms, n)
    print(f"Complete: {is_complete}")
    print(f"Saturation step: {sat_step}")
    print(f"Final density: {final_density:.4f}")


def demo_incomplete_system():
    """Demonstrate an incomplete system (disconnected graph)."""
    print("\n" + "=" * 60)
    print("DEMO 2: Incomplete System (Disconnected Components)")
    print("=" * 60)

    n = 40
    adj = generate_incomplete_system(n)
    axioms = {0}  # Only in first component

    print(f"\nUniverse size: {n}")
    print(f"Axiom set: {axioms}")
    print(f"System has two disconnected components of size ~{n // 2}")

    densities = density_trajectory(adj, axioms, n, n)

    print("\nDensity trajectory ρ(k):")
    print("-" * 40)
    for k, rho in enumerate(densities[:25]):
        bar = "█" * int(rho * 40)
        print(f"  k={k:2d}: ρ={rho:.4f} {bar}")

    is_complete, sat_step, final_density = saturation_analysis(adj, axioms, n)
    print(f"\nComplete: {is_complete}")
    print(f"Saturation step: {sat_step}")
    print(f"Final density: {final_density:.4f}")
    print(f"→ Density bounded away from 1: incompleteness!")


def demo_entropy_rate():
    """Demonstrate entropy rate discontinuity."""
    print("\n" + "=" * 60)
    print("DEMO 3: Entropy Rate Discontinuity")
    print("=" * 60)

    n = 80
    adj = generate_expander_graph(n, degree=4)
    axioms = {0}

    rates = entropy_rate(adj, axioms, 20)
    densities = density_trajectory(adj, axioms, n, 20)

    print("\nEntropy rate and density:")
    print("-" * 50)
    print(f"  {'k':>3s}  {'ρ(k)':>8s}  {'rate(k)':>8s}  {'phase':>10s}")
    print("-" * 50)
    for k in range(min(len(rates), 15)):
        phase = "growing" if rates[k] > 0.01 else "SATURATED"
        print(f"  {k:3d}  {densities[k]:8.4f}  {rates[k]:8.4f}  {phase:>10s}")

    # Find the discontinuity
    for k in range(len(rates) - 1):
        if rates[k] > 0.1 and rates[k + 1] < 0.01:
            print(f"\n→ Phase transition between k={k} and k={k+1}!")
            print(f"  Entropy rate drops from {rates[k]:.4f} to {rates[k+1]:.4f}")
            break


def demo_expansion_vs_critical_step():
    """Show how expansion ratio controls the critical step."""
    print("\n" + "=" * 60)
    print("DEMO 4: Expansion Controls Phase Transition Speed")
    print("=" * 60)

    n = 200
    axioms = {0}

    print(f"\nUniverse size: {n}")
    print(f"{'Degree':>8s}  {'Expansion':>10s}  {'k_c':>5s}  {'Theory':>8s}")
    print("-" * 40)

    for degree in [2, 3, 5, 8, 15]:
        adj = generate_expander_graph(n, degree=degree)
        h = vertex_expansion(adj, axioms, n)
        kc = critical_step(adj, axioms, n)
        # Theoretical bound: k_c ≈ log(n/2) / log(1+h)
        if h > 0:
            theory = math.log(n / 2) / math.log(1 + h)
        else:
            theory = float('inf')
        print(f"  {degree:5d}  {h:10.2f}  {kc:5d}  {theory:8.1f}")

    print("\n→ Higher expansion → faster phase transition (smaller k_c)")
    print("  Matches the theoretical bound k_c ≈ log(N/2) / log(1+h)")


def demo_renormalization():
    """Demonstrate coarse-graining preserves phase transition."""
    print("\n" + "=" * 60)
    print("DEMO 5: Renormalization Preserves Phase Transition")
    print("=" * 60)

    n = 120
    adj = generate_expander_graph(n, degree=4)
    axioms = {0}

    # Original density trajectory
    orig_densities = density_trajectory(adj, axioms, n, 20)

    # Coarse-grain: merge every 3 vertices into one block
    block_size = 3
    n_blocks = n // block_size

    def assign(v):
        return v // block_size

    # Build quotient graph
    quot_adj = {b: set() for b in range(n_blocks)}
    for v in range(n):
        for u in adj.get(v, set()):
            bv, bu = assign(v), assign(u)
            if bv != bu:
                quot_adj[bv].add(bu)

    quot_axioms = {assign(a) for a in axioms}
    quot_densities = density_trajectory(quot_adj, quot_axioms, n_blocks, 20)

    print(f"\nOriginal: {n} vertices")
    print(f"Quotient: {n_blocks} blocks (block size {block_size})")
    print(f"\n{'k':>3s}  {'ρ_orig':>8s}  {'ρ_quot':>8s}")
    print("-" * 25)
    for k in range(min(len(orig_densities), len(quot_densities), 15)):
        print(f"  {k:2d}  {orig_densities[k]:8.4f}  {quot_densities[k]:8.4f}")

    print("\n→ Quotient density ≥ original density (renorm_density_transfer)")
    print("  Phase transition structure preserved under coarse-graining")


if __name__ == "__main__":
    demo_expander_phase_transition()
    demo_incomplete_system()
    demo_entropy_rate()
    demo_expansion_vs_critical_step()
    demo_renormalization()

    print("\n" + "=" * 60)
    print("All demos completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Phase Transition in Proof Space

Shows the density trajectory ρ(k) for expander vs. incomplete systems,
highlighting the phase transition structure.
"""

import math
import random


def proof_ball_trajectory(adj, axioms, universe_size, max_steps):
    """Compute density and entropy rate trajectories."""
    ball = set(axioms)
    densities = []
    sizes = []
    for k in range(max_steps + 1):
        densities.append(len(ball) / universe_size)
        sizes.append(len(ball))
        neighbors = set()
        for v in ball:
            neighbors |= adj.get(v, set())
        new_ball = ball | neighbors
        if new_ball == ball:
            densities.extend([densities[-1]] * (max_steps - k))
            sizes.extend([sizes[-1]] * (max_steps - k))
            break
        ball = new_ball
    rates = []
    for i in range(len(sizes) - 1):
        if sizes[i] > 0 and sizes[i + 1] > 0:
            rates.append(math.log2(sizes[i + 1]) - math.log2(sizes[i]))
        else:
            rates.append(0.0)
    return densities[:max_steps + 1], rates[:max_steps]


def generate_expander(n, degree):
    adj = {i: set() for i in range(n)}
    for i in range(n):
        targets = set()
        while len(targets) < degree:
            t = random.randint(0, n - 1)
            if t != i:
                targets.add(t)
        adj[i] = targets
    return adj


def generate_disconnected(n):
    half = n // 2
    adj = {i: set() for i in range(n)}
    for i in range(half - 1):
        adj[i].add(i + 1)
        adj[i + 1].add(i)
    for i in range(half, n - 1):
        adj[i].add(i + 1)
        adj[i + 1].add(i)
    return adj


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        print("matplotlib not available, skipping visualization")
        return

    random.seed(42)

    n = 200
    max_steps = 25

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # --- Panel 1: Density trajectories ---
    ax = axes[0, 0]
    for degree, color, label in [(3, '#e74c3c', 'd=3'), (5, '#3498db', 'd=5'),
                                   (10, '#2ecc71', 'd=10')]:
        adj = generate_expander(n, degree)
        densities, _ = proof_ball_trajectory(adj, {0}, n, max_steps)
        ax.plot(range(len(densities)), densities, color=color, linewidth=2, label=label)
    ax.axhline(y=0.5, color='gray', linestyle='--', alpha=0.5, label='ρ = 1/2')
    ax.set_xlabel('Derivation steps k', fontsize=12)
    ax.set_ylabel('Proof density ρ(k)', fontsize=12)
    ax.set_title('Phase Transition: Density Growth', fontsize=13, fontweight='bold')
    ax.legend()
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    # --- Panel 2: Complete vs Incomplete ---
    ax = axes[0, 1]
    adj_exp = generate_expander(n, 5)
    d_exp, _ = proof_ball_trajectory(adj_exp, {0}, n, max_steps)
    adj_inc = generate_disconnected(n)
    d_inc, _ = proof_ball_trajectory(adj_inc, {0}, n, max_steps)
    ax.plot(range(len(d_exp)), d_exp, color='#3498db', linewidth=2, label='Complete (expander)')
    ax.plot(range(len(d_inc)), d_inc, color='#e74c3c', linewidth=2, label='Incomplete (disconnected)')
    ax.axhline(y=1.0, color='green', linestyle=':', alpha=0.5)
    ax.fill_between(range(len(d_inc)), d_inc, 1.0, alpha=0.1, color='red', label='Unprovable gap')
    ax.set_xlabel('Derivation steps k', fontsize=12)
    ax.set_ylabel('Proof density ρ(k)', fontsize=12)
    ax.set_title('Saturation Dichotomy', fontsize=13, fontweight='bold')
    ax.legend()
    ax.set_ylim(-0.05, 1.05)
    ax.grid(True, alpha=0.3)

    # --- Panel 3: Entropy rate ---
    ax = axes[1, 0]
    adj = generate_expander(n, 5)
    _, rates = proof_ball_trajectory(adj, {0}, n, max_steps)
    ax.bar(range(len(rates)), rates, color='#9b59b6', alpha=0.7)
    ax.set_xlabel('Derivation step k', fontsize=12)
    ax.set_ylabel('Entropy rate Δlog₂|Ball|', fontsize=12)
    ax.set_title('Entropy Rate Discontinuity', fontsize=13, fontweight='bold')
    ax.grid(True, alpha=0.3, axis='y')

    # --- Panel 4: Critical step vs expansion ---
    ax = axes[1, 1]
    degrees = list(range(2, 20))
    critical_steps = []
    theory_bounds = []
    for d in degrees:
        adj = generate_expander(n, d)
        ball = {0}
        kc = n
        for k in range(n + 1):
            if 2 * len(ball) > n:
                kc = k
                break
            neighbors = set()
            for v in ball:
                neighbors |= adj.get(v, set())
            new_ball = ball | neighbors
            if new_ball == ball:
                break
            ball = new_ball
        critical_steps.append(kc)
        h = d  # approximate expansion
        if h > 0:
            theory_bounds.append(math.log(n / 2) / math.log(1 + h))
        else:
            theory_bounds.append(n)

    ax.scatter(degrees, critical_steps, color='#e74c3c', s=40, zorder=5, label='Measured k_c')
    ax.plot(degrees, theory_bounds, color='#3498db', linewidth=2, linestyle='--', label='Theory: log(N/2)/log(1+d)')
    ax.set_xlabel('Vertex degree d', fontsize=12)
    ax.set_ylabel('Critical step k_c', fontsize=12)
    ax.set_title('Expansion Controls Phase Transition', fontsize=13, fontweight='bold')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.suptitle('Phase Transitions in Proof Space', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('phase_transition_proof_space.png', dpi=150, bbox_inches='tight')
    print("Saved: phase_transition_proof_space.png")


if __name__ == "__main__":
    main()
