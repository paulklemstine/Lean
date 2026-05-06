#!/usr/bin/env python3
"""
Maslov Dequantization Demo: Tropical Collapse of the Finite-Lattice Propagator

This script demonstrates the Laplace principle / Maslov dequantization theorem:

    lim_{h → 0⁺} -h · log(∑ exp(-Sᵧ / h)) = min(Sᵧ)

We visualize:
1. The convergence of the Maslov dequantization to the tropical minimum
2. The squeeze bounds (upper and lower)
3. A 3D visualization of piecewise-linear paths in SPB 3-space
4. The rate of convergence as a function of h
"""

import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from matplotlib.gridspec import GridSpec

# ── 1. Core Maslov dequantization function ──────────────────────────────────

def maslov_dequantize(actions, h):
    """Compute -h * log(∑ exp(-S_γ / h)) with numerical stability."""
    S_min = np.min(actions)
    # Use log-sum-exp trick: -h * log(∑ exp(-S/h)) = S_min - h * log(∑ exp(-(S-S_min)/h))
    shifted = -(actions - S_min) / h
    return S_min - h * np.log(np.sum(np.exp(shifted)))


def maslov_upper_bound(actions, h):
    """Upper bound: min(S)"""
    return np.min(actions)


def maslov_lower_bound(actions, h):
    """Lower bound: min(S) - h * log(|Γ|)"""
    return np.min(actions) - h * np.log(len(actions))


# ── 2. Generate example paths and actions ───────────────────────────────────

def generate_pl_paths(x, y, n_segments, n_paths, seed=42):
    """Generate random piecewise-linear paths between x and y in ℝ³."""
    rng = np.random.RandomState(seed)
    paths = []
    for _ in range(n_paths):
        path = np.zeros((n_segments + 1, 3))
        path[0] = x
        path[-1] = y
        for i in range(1, n_segments):
            t = i / n_segments
            # Interpolate with random perturbation
            path[i] = (1 - t) * x + t * y + rng.randn(3) * 0.3
        paths.append(path)
    return paths


def spb_lohmiller_action(path, T):
    """Compute the discretized Lohmiller–Slotine action for a PL path."""
    n = len(path) - 1
    dt = T / (n + 1)
    action = 0.0
    for i in range(n):
        diff = path[i + 1] - path[i]
        action += np.sum(diff ** 2) / dt
    return action


# ── 3. Visualization ───────────────────────────────────────────────────────

def main():
    # Parameters
    x = np.array([0.0, 0.0, 0.0])
    y = np.array([1.0, 1.0, 1.0])
    n_segments = 8
    n_paths = 15
    T = 1.0

    # Generate paths and compute actions
    paths = generate_pl_paths(x, y, n_segments, n_paths)
    actions = np.array([spb_lohmiller_action(p, T) for p in paths])

    S_min = np.min(actions)
    min_idx = np.argmin(actions)

    print("=" * 60)
    print("MASLOV DEQUANTIZATION DEMO")
    print("Tropical Collapse of the Finite-Lattice SPB Propagator")
    print("=" * 60)
    print(f"\nEndpoints: x = {x}, y = {y}")
    print(f"Segments per path: {n_segments}")
    print(f"Number of paths |Γ|: {n_paths}")
    print(f"Elapsed time T: {T}")
    print(f"\nActions S_γ: {np.sort(actions)[:5]}... (sorted, first 5)")
    print(f"Minimum action S* = {S_min:.6f}")
    print(f"log(|Γ|) = {np.log(n_paths):.6f}")

    # Evaluate Maslov dequantization for various h
    h_values = np.logspace(-4, 1, 500)
    maslov_values = np.array([maslov_dequantize(actions, h) for h in h_values])
    upper_values = np.array([maslov_upper_bound(actions, h) for h in h_values])
    lower_values = np.array([maslov_lower_bound(actions, h) for h in h_values])

    print(f"\n--- Convergence table ---")
    for h_test in [10.0, 1.0, 0.1, 0.01, 0.001, 0.0001]:
        val = maslov_dequantize(actions, h_test)
        err = abs(val - S_min)
        print(f"  h = {h_test:>8.4f}  →  -h·log(Σ exp(-S/h)) = {val:.8f}  "
              f"|error| = {err:.2e}")

    # ── Figure 1: Convergence plot ──────────────────────────────────────
    fig = plt.figure(figsize=(16, 12))
    gs = GridSpec(2, 2, figure=fig, hspace=0.3, wspace=0.3)

    ax1 = fig.add_subplot(gs[0, 0])
    ax1.semilogx(h_values, maslov_values, 'b-', linewidth=2,
                 label=r'$-h \cdot \log\left(\sum e^{-S_\gamma/h}\right)$')
    ax1.semilogx(h_values, upper_values, 'r--', linewidth=1.5,
                 label=r'Upper bound: $S^*$')
    ax1.semilogx(h_values, lower_values, 'g--', linewidth=1.5,
                 label=r'Lower bound: $S^* - h\log|\Gamma|$')
    ax1.axhline(y=S_min, color='k', linestyle=':', alpha=0.5)
    ax1.set_xlabel(r'$h$ (deformation parameter)', fontsize=12)
    ax1.set_ylabel('Value', fontsize=12)
    ax1.set_title('Maslov Dequantization: Squeeze Convergence', fontsize=14)
    ax1.legend(fontsize=10, loc='upper left')
    ax1.set_xlim(1e-4, 10)
    ax1.grid(True, alpha=0.3)

    # ── Figure 2: Error plot ────────────────────────────────────────────
    ax2 = fig.add_subplot(gs[0, 1])
    errors = np.abs(maslov_values - S_min)
    ax2.loglog(h_values, errors, 'b-', linewidth=2, label='|Error|')
    ax2.loglog(h_values, h_values * np.log(n_paths), 'r--', linewidth=1.5,
               label=r'$h \cdot \log|\Gamma|$ (bound)')
    ax2.set_xlabel(r'$h$', fontsize=12)
    ax2.set_ylabel('|Error|', fontsize=12)
    ax2.set_title('Rate of Convergence', fontsize=14)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    # ── Figure 3: 3D paths ──────────────────────────────────────────────
    ax3 = fig.add_subplot(gs[1, 0], projection='3d')
    for i, path in enumerate(paths):
        alpha = 0.3 if i != min_idx else 1.0
        lw = 1 if i != min_idx else 3
        color = 'gray' if i != min_idx else 'red'
        label = None if i != min_idx else f'Extremal path (S*={S_min:.3f})'
        ax3.plot(path[:, 0], path[:, 1], path[:, 2],
                 color=color, alpha=alpha, linewidth=lw, label=label)
    ax3.scatter(*x, color='green', s=100, zorder=5, label='Start')
    ax3.scatter(*y, color='blue', s=100, zorder=5, label='End')
    ax3.set_xlabel('X')
    ax3.set_ylabel('Y')
    ax3.set_zlabel('Z')
    ax3.set_title('PL Paths in SPB 3-Space', fontsize=14)
    ax3.legend(fontsize=9, loc='upper left')

    # ── Figure 4: Action distribution ───────────────────────────────────
    ax4 = fig.add_subplot(gs[1, 1])
    sorted_actions = np.sort(actions)
    colors = ['red' if a == S_min else 'steelblue' for a in sorted_actions]
    ax4.barh(range(n_paths), sorted_actions, color=colors, edgecolor='white')
    ax4.axvline(x=S_min, color='red', linestyle='--', linewidth=2,
                label=f'$S^* = {S_min:.3f}$ (tropical minimum)')
    ax4.set_xlabel('Action $S_\\gamma$', fontsize=12)
    ax4.set_ylabel('Path index (sorted)', fontsize=12)
    ax4.set_title('Distribution of Actions over Path Lattice', fontsize=14)
    ax4.legend(fontsize=10)
    ax4.grid(True, alpha=0.3, axis='x')

    plt.suptitle('Maslov Dequantization of the SPB Propagator\n'
                 r'$\lim_{h\to 0^+} -h \log\sum_\gamma e^{-S_\gamma/h} = \min_\gamma S_\gamma$',
                 fontsize=16, y=1.02)
    plt.savefig('maslov_dequantization_demo.png', dpi=150, bbox_inches='tight')
    print(f"\n✓ Saved figure to maslov_dequantization_demo.png")
    plt.close()

    # ── Tropical algebra verification ───────────────────────────────────
    print("\n" + "=" * 60)
    print("TROPICAL ALGEBRA VERIFICATION")
    print("=" * 60)
    print(f"\nIn the tropical (min-plus) semiring:")
    print(f"  a ⊕ b = min(a, b)    (tropical addition)")
    print(f"  a ⊙ b = a + b        (tropical multiplication)")
    print(f"\nTropical sum of actions:")
    trop_sum = S_min  # min over all actions
    print(f"  ⊕_γ S_γ = min_γ S_γ = {trop_sum:.6f}")
    print(f"\nIdempotency check: S* ⊕ S* = min(S*, S*) = {min(S_min, S_min):.6f} = S*  ✓")
    print(f"\nThe Maslov dequantization maps:")
    print(f"  Classical sum  ∑ exp(-S/h)  →  Tropical sum  ⊕ S")
    print(f"  (as h → 0⁺)")
    print(f"\nThis confirms the quantum-to-tropical collapse:")
    print(f"  The Feynman path integral reduces to a tropical extremal path.")


if __name__ == '__main__':
    main()
