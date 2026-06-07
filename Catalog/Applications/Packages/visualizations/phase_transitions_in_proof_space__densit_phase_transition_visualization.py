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
