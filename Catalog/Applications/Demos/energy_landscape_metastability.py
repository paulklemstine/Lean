#!/usr/bin/env python3
"""
Energy Landscape Metastability — Demonstration

Demonstrates the key concepts:
1. Hamming distance and configuration space structure
2. Ising model energy landscapes
3. Local minima and metastability detection
4. Speed limit theorem verification
5. Metastability scaling conjecture predictions
"""

from algorithms import (
    hamming_distance, all_configurations, neighbors,
    InteractionHypergraph, nearest_neighbor_hypergraph,
    make_ising_energy, find_local_minima, find_global_minimum,
    is_metastable, relaxation_time, barrier_height,
    verify_speed_limit, predicted_relaxation
)


def demo_hamming_distance():
    """Demonstrate Hamming distance properties."""
    print("=" * 60)
    print("§ 1. Hamming Distance on Configuration Spaces")
    print("=" * 60)
    
    sigma = (0, 1, 0, 1)
    tau = (1, 1, 0, 0)
    rho = (1, 0, 1, 0)
    
    d_st = hamming_distance(sigma, tau)
    d_tr = hamming_distance(tau, rho)
    d_sr = hamming_distance(sigma, rho)
    
    print(f"σ = {sigma}")
    print(f"τ = {tau}")
    print(f"ρ = {rho}")
    print(f"d(σ, τ) = {d_st}")
    print(f"d(τ, ρ) = {d_tr}")
    print(f"d(σ, ρ) = {d_sr}")
    print(f"Triangle inequality: {d_sr} ≤ {d_st} + {d_tr} = {d_st + d_tr}: "
          f"{'✓' if d_sr <= d_st + d_tr else '✗'}")
    print(f"Symmetry: d(σ,τ) = {d_st} = d(τ,σ) = {hamming_distance(tau, sigma)}: "
          f"{'✓' if d_st == hamming_distance(tau, sigma) else '✗'}")
    print()


def demo_ising_landscape():
    """Demonstrate energy landscape analysis for an Ising model."""
    print("=" * 60)
    print("§ 2. Ising Model Energy Landscape (d=4)")
    print("=" * 60)
    
    # Frustrated antiferromagnetic Ising on a 4-cycle
    d = 4
    couplings = {
        (0, 1): -1.0,  # antiferromagnetic
        (1, 2): -1.0,
        (2, 3): -1.0,
        (3, 0): -1.0,
    }
    fields = {i: 0.1 * (i - 1.5) for i in range(d)}  # weak symmetry-breaking field
    
    E = make_ising_energy(d, couplings, fields)
    
    print(f"System: d={d} sites, antiferromagnetic 4-cycle")
    print(f"Step bound (δ): {E.step_bound}")
    print(f"Step bound verified: {E.verify_step_bound()}")
    print()
    
    # List all configurations with energies
    configs = all_configurations(d, 2)
    config_energies = [(c, E.energy(c)) for c in configs]
    config_energies.sort(key=lambda x: x[1])
    
    print("All configurations (sorted by energy):")
    for c, e in config_energies:
        markers = []
        if all(E.energy(c) <= E.energy(n) for n in neighbors(c, 2)):
            markers.append("local min")
        if c == config_energies[0][0]:
            markers.append("global min")
        marker_str = f"  ← {', '.join(markers)}" if markers else ""
        print(f"  {c}  E = {e:+.3f}{marker_str}")
    print()
    
    # Find local minima and metastable states
    local_mins = find_local_minima(E)
    print(f"Local minima: {len(local_mins)}")
    for m in local_mins:
        meta = is_metastable(E, m)
        print(f"  {m}  E = {E.energy(m):+.3f}  metastable: {meta}")
    print()
    
    # Compute barrier heights between local minima
    if len(local_mins) >= 2:
        print("Barrier heights between local minima:")
        for i in range(len(local_mins)):
            for j in range(i + 1, len(local_mins)):
                bh = barrier_height(E, local_mins[i], local_mins[j])
                print(f"  {local_mins[i]} → {local_mins[j]}: barrier = {bh:.3f}")
    print()


def demo_speed_limit():
    """Demonstrate the speed limit theorem."""
    print("=" * 60)
    print("§ 3. Speed Limit Theorem Verification")
    print("=" * 60)
    
    # Create a path through configuration space
    d = 4
    couplings = {(i, (i+1) % d): -1.0 for i in range(d)}
    fields = {i: 0.1 for i in range(d)}
    E = make_ising_energy(d, couplings, fields)
    
    # Manual path: flip one spin at a time
    path = [
        (0, 0, 0, 0),
        (1, 0, 0, 0),
        (1, 1, 0, 0),
        (1, 1, 1, 0),
        (1, 1, 1, 1),
    ]
    
    energies = [E.energy(c) for c in path]
    result = verify_speed_limit(energies, E.step_bound)
    
    print(f"Path: {' → '.join(str(c) for c in path)}")
    print(f"Energies: {[f'{e:.3f}' for e in energies]}")
    print(f"Step bound δ = {E.step_bound}")
    print(f"Max single-step change: {result['max_step']:.3f}")
    print(f"Total change |f(n) - f(0)|: {result['total_change']:.3f}")
    print(f"Speed limit bound (n·δ): {result['speed_limit_bound']:.3f}")
    print(f"Step bound satisfied: {'✓' if result['step_bound_satisfied'] else '✗'}")
    print(f"Speed limit satisfied: {'✓' if result['speed_limit_satisfied'] else '✗'}")
    print(f"Steps needed ≥ total_change/δ = {result['total_change']/E.step_bound:.3f}")
    print()


def demo_interaction_hypergraph():
    """Demonstrate interaction hypergraph properties."""
    print("=" * 60)
    print("§ 4. Interaction Hypergraph Structure")
    print("=" * 60)
    
    d = 6
    
    # Nearest-neighbor (depth 2)
    H_nn = nearest_neighbor_hypergraph(d)
    print(f"Nearest-neighbor on d={d} sites:")
    print(f"  Depth: {H_nn.depth}")
    print(f"  Edges: {H_nn.num_edges()}")
    print(f"  Max degree: {H_nn.max_degree()}")
    print(f"  Degrees: {[H_nn.site_degree(i) for i in range(d)]}")
    print()
    
    # 3-local
    from algorithms import k_local_hypergraph
    H_3 = k_local_hypergraph(d, 3)
    print(f"3-local on d={d} sites:")
    print(f"  Depth: {H_3.depth}")
    print(f"  Edges: {H_3.num_edges()}")
    print(f"  Max degree: {H_3.max_degree()}")
    print(f"  Upper bound (2^d = {2**d}): satisfied = {H_3.num_edges() <= 2**d}")
    print()


def demo_metastability_conjecture():
    """Demonstrate the metastability scaling conjecture predictions."""
    print("=" * 60)
    print("§ 5. Metastability Scaling Conjecture")
    print("=" * 60)
    
    print("Predicted minimum relaxation time d^(d-k-1):")
    print(f"{'d':>4} {'k':>4} {'d^(d-k-1)':>12} {'2^d':>8}")
    print("-" * 32)
    for d in range(3, 8):
        for k in range(1, d - 1):
            pred = predicted_relaxation(d, k)
            print(f"{d:4d} {k:4d} {pred:12d} {2**d:8d}")
    print()
    
    # Test for small cases: construct frustrated Ising and measure relaxation
    print("Empirical test: Frustrated Ising models")
    print("-" * 50)
    
    for d in [3, 4, 5]:
        # Antiferromagnetic ring with weak field
        couplings = {(i, (i+1) % d): -1.0 for i in range(d)}
        fields = {0: 0.05}  # tiny symmetry-breaking field
        E = make_ising_energy(d, couplings, fields)
        
        local_mins = find_local_minima(E)
        metastable = [m for m in local_mins if is_metastable(E, m)]
        
        max_relax = 0
        for m in metastable:
            r = relaxation_time(E, m)
            if r > max_relax:
                max_relax = r
        
        print(f"d={d}: {len(local_mins)} local min, {len(metastable)} metastable, "
              f"max relaxation = {max_relax}")
        for k in range(1, d - 1):
            pred = predicted_relaxation(d, k)
            print(f"  k={k}: predicted ≥ {pred}, measured = {max_relax}, "
                  f"{'≥' if max_relax >= pred else '<'} prediction")
    print()


def demo_threshold_crossing():
    """Demonstrate the threshold crossing principle."""
    print("=" * 60)
    print("§ 6. Threshold Crossing Principle")
    print("=" * 60)
    
    # A sequence that starts low and ends high
    sequence = [0.0, 0.3, 0.7, 0.5, 0.8, 1.2, 1.5, 1.1, 1.8]
    threshold = 1.0
    
    print(f"Sequence: {sequence}")
    print(f"Threshold B = {threshold}")
    print(f"f(0) = {sequence[0]} < B: {'✓' if sequence[0] < threshold else '✗'}")
    print(f"f(n) = {sequence[-1]} ≥ B: {'✓' if sequence[-1] >= threshold else '✗'}")
    
    # Find crossing point
    for i in range(len(sequence) - 1):
        if sequence[i] < threshold and sequence[i + 1] >= threshold:
            print(f"Crossing at i={i}: f({i})={sequence[i]} < {threshold} ≤ "
                  f"{sequence[i+1]}=f({i+1}) ✓")
            break
    print()


if __name__ == "__main__":
    demo_hamming_distance()
    demo_ising_landscape()
    demo_speed_limit()
    demo_interaction_hypergraph()
    demo_metastability_conjecture()
    demo_threshold_crossing()
    
    print("=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


#!/usr/bin/env python3
"""
Visualization: Energy Landscape for a 4-site Ising Model

Plots the energy of all 16 configurations of a 4-site antiferromagnetic
Ising model, highlighting local minima and metastable states.
"""

import itertools
import matplotlib.pyplot as plt
import numpy as np


def ising_energy(sigma, couplings, fields):
    spins = [2 * s - 1 for s in sigma]
    energy = 0.0
    for (i, j), J in couplings.items():
        energy -= J * spins[i] * spins[j]
    for i, h in fields.items():
        energy -= h * spins[i]
    return energy


def hamming_distance(s1, s2):
    return sum(a != b for a, b in zip(s1, s2))


def main():
    d = 4
    couplings = {(i, (i+1) % d): -1.0 for i in range(d)}
    fields = {i: 0.1 * (i - 1.5) for i in range(d)}

    configs = list(itertools.product([0, 1], repeat=d))
    energies = [ising_energy(c, couplings, fields) for c in configs]

    # Sort by energy
    order = np.argsort(energies)
    configs_sorted = [configs[i] for i in order]
    energies_sorted = [energies[i] for i in order]

    # Identify local minima
    is_local_min = []
    for c in configs_sorted:
        e_c = ising_energy(c, couplings, fields)
        nbrs = [n for n in configs if hamming_distance(c, n) == 1]
        is_min = all(e_c <= ising_energy(n, couplings, fields) for n in nbrs)
        is_local_min.append(is_min)

    global_min_e = min(energies_sorted)

    fig, ax = plt.subplots(figsize=(14, 6))

    colors = []
    for i, (c, e, is_min) in enumerate(zip(configs_sorted, energies_sorted, is_local_min)):
        if is_min and abs(e - global_min_e) < 1e-10:
            colors.append('#2ecc71')  # green: global min
        elif is_min:
            colors.append('#e74c3c')  # red: metastable
        else:
            colors.append('#3498db')  # blue: saddle/other

    bars = ax.bar(range(len(configs_sorted)), energies_sorted, color=colors,
                  edgecolor='white', linewidth=0.5)

    ax.set_xlabel('Configuration (sorted by energy)', fontsize=12)
    ax.set_ylabel('Energy', fontsize=12)
    ax.set_title('Energy Landscape: 4-Site Antiferromagnetic Ising Ring', fontsize=14)

    # Label configurations
    labels = [''.join(str(s) for s in c) for c in configs_sorted]
    ax.set_xticks(range(len(configs_sorted)))
    ax.set_xticklabels(labels, rotation=45, ha='right', fontsize=8)

    # Legend
    from matplotlib.patches import Patch
    legend_elements = [
        Patch(facecolor='#2ecc71', label='Global minimum'),
        Patch(facecolor='#e74c3c', label='Metastable (local min)'),
        Patch(facecolor='#3498db', label='Other'),
    ]
    ax.legend(handles=legend_elements, loc='upper left', fontsize=10)

    ax.axhline(y=0, color='gray', linestyle='--', alpha=0.3)
    ax.grid(axis='y', alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_energy_landscape.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_energy_landscape.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Metastability Scaling Conjecture Predictions

Plots the predicted relaxation time d^(d-k-1) as a function of d
for different interaction depths k, compared to the configuration
space size 2^d.
"""

import matplotlib.pyplot as plt
import numpy as np


def predicted_relaxation(d, k):
    if k + 1 >= d:
        return 1
    return d ** (d - k - 1)


def main():
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

    # ---- Left panel: predicted relaxation vs d for different k ----
    d_values = np.arange(3, 12)
    k_values = [1, 2, 3, 4]
    colors = ['#e74c3c', '#3498db', '#2ecc71', '#9b59b6']

    for k, color in zip(k_values, colors):
        relax = [predicted_relaxation(int(d), k) for d in d_values]
        valid = [(d, r) for d, r in zip(d_values, relax) if k + 1 < d]
        if valid:
            ds, rs = zip(*valid)
            ax1.semilogy(ds, rs, 'o-', color=color, label=f'k={k}', 
                        linewidth=2, markersize=6)

    # Configuration space size for reference
    config_sizes = [2**int(d) for d in d_values]
    ax1.semilogy(d_values, config_sizes, 'k--', alpha=0.5, linewidth=1.5,
                label='Config space 2^d')

    ax1.set_xlabel('Number of sites d', fontsize=12)
    ax1.set_ylabel('Predicted relaxation time', fontsize=12)
    ax1.set_title('Metastability Scaling: d^(d-k-1)', fontsize=14)
    ax1.legend(fontsize=10)
    ax1.grid(True, alpha=0.3)
    ax1.set_xticks(d_values)

    # ---- Right panel: heatmap of d^(d-k-1) ----
    d_range = np.arange(3, 10)
    k_range = np.arange(1, 8)
    
    data = np.zeros((len(k_range), len(d_range)))
    for i, k in enumerate(k_range):
        for j, d in enumerate(d_range):
            if k + 1 < d:
                data[i, j] = np.log10(predicted_relaxation(int(d), int(k)))
            else:
                data[i, j] = np.nan

    im = ax2.imshow(data, aspect='auto', cmap='YlOrRd', origin='lower',
                    extent=[d_range[0]-0.5, d_range[-1]+0.5, 
                            k_range[0]-0.5, k_range[-1]+0.5])

    # Add text annotations
    for i, k in enumerate(k_range):
        for j, d in enumerate(d_range):
            if k + 1 < d:
                val = predicted_relaxation(int(d), int(k))
                if val < 10000:
                    ax2.text(d, k, str(val), ha='center', va='center', fontsize=7,
                            color='black' if data[i,j] < 3 else 'white')
                else:
                    ax2.text(d, k, f'{val:.0e}', ha='center', va='center', fontsize=6,
                            color='white')
            else:
                ax2.text(d, k, '—', ha='center', va='center', fontsize=8,
                        color='gray')

    ax2.set_xlabel('Number of sites d', fontsize=12)
    ax2.set_ylabel('Interaction depth k', fontsize=12)
    ax2.set_title('log₁₀(Predicted Relaxation)', fontsize=14)
    ax2.set_xticks(d_range)
    ax2.set_yticks(k_range)
    
    cbar = plt.colorbar(im, ax=ax2, label='log₁₀(d^(d-k-1))')

    plt.tight_layout()
    plt.savefig('viz_scaling_conjecture.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_scaling_conjecture.png")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Speed Limit Theorem

Demonstrates the speed limit bound |f(n) - f(0)| ≤ n·δ by showing
several energy paths through configuration space, with the theoretical
bound envelope.
"""

import matplotlib.pyplot as plt
import numpy as np
import random


def generate_bounded_walk(n, delta, seed=42):
    """Generate a random walk with |f(i+1) - f(i)| ≤ delta."""
    rng = random.Random(seed)
    f = [0.0]
    for _ in range(n):
        step = rng.uniform(-delta, delta)
        f.append(f[-1] + step)
    return f


def main():
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    delta = 1.0
    n = 50

    # ---- Panel 1: Multiple random walks with bound ----
    ax = axes[0]
    for seed in range(8):
        walk = generate_bounded_walk(n, delta, seed=seed)
        ax.plot(range(n + 1), walk, alpha=0.5, linewidth=1)

    # Speed limit envelope
    steps = np.arange(n + 1)
    ax.fill_between(steps, -steps * delta, steps * delta, alpha=0.15,
                    color='red', label=f'|f(n)-f(0)| ≤ n·δ')
    ax.plot(steps, steps * delta, 'r--', linewidth=2, alpha=0.7)
    ax.plot(steps, -steps * delta, 'r--', linewidth=2, alpha=0.7)

    ax.set_xlabel('Step n', fontsize=11)
    ax.set_ylabel('f(n) - f(0)', fontsize=11)
    ax.set_title(f'Speed Limit: δ = {delta}', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)

    # ---- Panel 2: Barrier crossing ----
    ax = axes[1]
    B = 15.0
    min_steps = int(np.ceil(B / delta))

    # Generate walks that eventually cross barrier
    for seed in [10, 20, 30, 40, 50]:
        walk = generate_bounded_walk(100, delta, seed=seed)
        # Shift to start at 0 and add upward drift
        walk_shifted = [w + 0.3 * i for i, w in enumerate(walk)]
        ax.plot(range(len(walk_shifted)), walk_shifted, alpha=0.5, linewidth=1)

    ax.axhline(y=B, color='red', linewidth=2, linestyle='-', label=f'Barrier B={B}')
    ax.axvline(x=min_steps, color='green', linewidth=2, linestyle='--',
               label=f'Min steps = B/δ = {min_steps}')

    ax.set_xlabel('Step n', fontsize=11)
    ax.set_ylabel('Energy', fontsize=11)
    ax.set_title('Barrier Crossing: B/δ Lower Bound', fontsize=13)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 100)

    # ---- Panel 3: Threshold crossing principle ----
    ax = axes[2]
    np.random.seed(7)
    f_vals = np.cumsum(np.random.uniform(-0.5, 0.8, size=30))
    f_vals = np.concatenate([[0], f_vals])
    threshold = 5.0

    ax.plot(range(len(f_vals)), f_vals, 'b-o', markersize=3, linewidth=1.5,
            label='Sequence f(i)')
    ax.axhline(y=threshold, color='red', linewidth=2, linestyle='--',
               label=f'Threshold B = {threshold}')

    # Find crossing point
    crossing_i = None
    for i in range(len(f_vals) - 1):
        if f_vals[i] < threshold and f_vals[i + 1] >= threshold:
            crossing_i = i
            break

    if crossing_i is not None:
        ax.plot([crossing_i, crossing_i + 1], [f_vals[crossing_i], f_vals[crossing_i + 1]],
                'go-', markersize=10, linewidth=3, zorder=5,
                label=f'Crossing at i={crossing_i}')
        ax.annotate(f'f({crossing_i}) < B ≤ f({crossing_i+1})',
                   xy=(crossing_i + 0.5, threshold),
                   xytext=(crossing_i + 3, threshold + 1.5),
                   fontsize=9, arrowprops=dict(arrowstyle='->', color='green'),
                   color='green')

    ax.set_xlabel('Index i', fontsize=11)
    ax.set_ylabel('f(i)', fontsize=11)
    ax.set_title('Threshold Crossing (Discrete IVT)', fontsize=13)
    ax.legend(fontsize=9, loc='upper left')
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('viz_speed_limit.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved viz_speed_limit.png")


if __name__ == "__main__":
    main()
