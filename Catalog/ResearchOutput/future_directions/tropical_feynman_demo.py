"""
Tropical Feynman Integrals Demo
================================
Future Direction 6.1: Demonstrates the tropical limit of the Feynman path integral.

As ℏ → 0 (or equivalently temperature ε → 0), the quantum path integral
∫ e^{iS/ℏ} Dx transitions to the tropical minimum-action selection:
⊕_paths S = min_paths S.

This demo shows:
  1. Soft tropical path integral converging to the true minimum
  2. Stationary phase selection from multiple paths
  3. Tropical propagator composition (min-plus convolution)
  4. Action additivity → tropical linearity
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.gridspec import GridSpec

# ============================================================
# Demo 1: Maslov Dequantization — Soft Min → Hard Min
# ============================================================
def demo_maslov_convergence():
    """
    Show that the soft-minimum (log-sum-exp) converges to min as ε → 0.
    This is the core of the quantum → tropical transition.
    """
    actions = np.array([3.0, 1.5, 4.0, 2.7, 5.2])
    true_min = np.min(actions)

    epsilons = np.logspace(-2, 1, 200)
    soft_mins = []

    for eps in epsilons:
        weights = np.exp(-actions / eps)
        soft_min = -eps * np.log(np.sum(weights))
        soft_mins.append(soft_min)

    soft_mins = np.array(soft_mins)

    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Left: convergence plot
    axes[0].semilogx(epsilons, soft_mins, 'b-', linewidth=2, label='Soft min (LSE)')
    axes[0].axhline(y=true_min, color='r', linestyle='--', linewidth=2, label=f'True min = {true_min}')
    axes[0].fill_between(epsilons, true_min, soft_mins, alpha=0.15, color='blue')
    axes[0].set_xlabel('ε (coherence parameter)', fontsize=12)
    axes[0].set_ylabel('Tropical Path Integral Value', fontsize=12)
    axes[0].set_title('Maslov Dequantization: Soft → Hard Minimum', fontsize=13)
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)

    # Right: weight distribution at different ε
    eps_vals = [0.01, 0.1, 0.5, 2.0, 10.0]
    x = np.arange(len(actions))
    width = 0.15

    for i, eps in enumerate(eps_vals):
        weights = np.exp(-actions / eps)
        probs = weights / np.sum(weights)
        axes[1].bar(x + i * width, probs, width, label=f'ε={eps}', alpha=0.8)

    axes[1].set_xlabel('Path Index', fontsize=12)
    axes[1].set_ylabel('Probability (Boltzmann weight)', fontsize=12)
    axes[1].set_title('Path Selection: Quantum → Classical', fontsize=13)
    axes[1].set_xticks(x + 2 * width)
    axes[1].set_xticklabels([f'S={a}' for a in actions])
    axes[1].legend(fontsize=9)
    axes[1].grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('tropical_feynman_maslov.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1: Maslov dequantization convergence saved")
    print(f"  True minimum action: {true_min}")
    print(f"  Soft min at ε=0.01: {soft_mins[0]:.6f}")
    print(f"  Soft min at ε=10.0: {soft_mins[-1]:.6f}")


# ============================================================
# Demo 2: Multi-Path Stationary Phase Selection
# ============================================================
def demo_stationary_phase():
    """
    Multiple classical paths with different actions.
    The tropical integral selects the minimum-action (stationary) path.
    """
    np.random.seed(42)
    n_paths = 50
    t = np.linspace(0, 1, 100)

    # Generate random paths (perturbations of geodesics)
    paths = []
    actions = []
    for i in range(n_paths):
        # Random path: x(t) = t + perturbation
        freq = np.random.randint(1, 8)
        amp = np.random.uniform(0.0, 0.5)
        path = t + amp * np.sin(freq * np.pi * t)
        paths.append(path)
        # Action = ∫ (dx/dt)² dt (kinetic energy only)
        dx = np.diff(path)
        action = np.sum(dx**2) * (t[1] - t[0])
        actions.append(action)

    actions = np.array(actions)
    min_idx = np.argmin(actions)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Left: all paths colored by action
    for i, path in enumerate(paths):
        alpha = 0.3 if i != min_idx else 1.0
        lw = 0.5 if i != min_idx else 3.0
        color = plt.cm.viridis(actions[i] / np.max(actions))
        if i == min_idx:
            color = 'red'
        axes[0].plot(t, path, color=color, alpha=alpha, linewidth=lw)
    axes[0].set_xlabel('t', fontsize=12)
    axes[0].set_ylabel('x(t)', fontsize=12)
    axes[0].set_title(f'Classical Paths (min action path in red)', fontsize=13)
    axes[0].grid(True, alpha=0.3)

    # Middle: action histogram
    axes[1].hist(actions, bins=15, color='steelblue', edgecolor='black', alpha=0.7)
    axes[1].axvline(x=actions[min_idx], color='red', linewidth=2,
                     label=f'Min S = {actions[min_idx]:.4f}')
    axes[1].set_xlabel('Action S', fontsize=12)
    axes[1].set_ylabel('Count', fontsize=12)
    axes[1].set_title('Action Distribution', fontsize=13)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    # Right: tropical integral vs ε
    epsilons = np.logspace(-3, 1, 200)
    tropical_integrals = []
    for eps in epsilons:
        weights = np.exp(-actions / eps)
        tropical_integrals.append(-eps * np.log(np.sum(weights)))

    axes[2].semilogx(epsilons, tropical_integrals, 'b-', linewidth=2)
    axes[2].axhline(y=actions[min_idx], color='r', linestyle='--', linewidth=2,
                     label='Classical minimum')
    axes[2].set_xlabel('ε (quantum coherence)', fontsize=12)
    axes[2].set_ylabel('Tropical Path Integral', fontsize=12)
    axes[2].set_title('Quantum → Classical Transition', fontsize=13)
    axes[2].legend(fontsize=11)
    axes[2].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('tropical_feynman_stationary.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 2: Stationary phase selection saved")
    print(f"  Number of paths: {n_paths}")
    print(f"  Minimum action: {actions[min_idx]:.6f} (path {min_idx})")


# ============================================================
# Demo 3: Tropical Propagator Composition
# ============================================================
def demo_tropical_propagator():
    """
    Tropical propagator composition: K_trop(x₂,x₀) = min_x₁ [K₁ + K₂]
    This is the min-plus convolution, the tropical analogue of the
    Feynman path integral composition.
    """
    n = 100
    x = np.linspace(-3, 3, n)

    # Two segment propagators: K₁(x₁, x₀=0) and K₂(x₂, x₁)
    # Free particle: K = (x_f - x_i)² / (2t)
    t1, t2 = 1.0, 1.5

    # K₁: propagation from x₀=0 to x₁ over time t₁
    K1 = x**2 / (2 * t1)

    # For each x₂, compute K₂(x₂, x₁) + K₁(x₁, x₀) and minimize over x₁
    K_composed = np.zeros(n)
    optimal_x1 = np.zeros(n)

    for j, x2 in enumerate(x):
        K2 = (x2 - x)**2 / (2 * t2)
        total = K1 + K2
        min_idx = np.argmin(total)
        K_composed[j] = total[min_idx]
        optimal_x1[j] = x[min_idx]

    # Direct propagator: K_direct(x₂, x₀=0) over time t₁+t₂
    K_direct = x**2 / (2 * (t1 + t2))

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    axes[0].plot(x, K1, 'b-', linewidth=2, label='K₁(x₁, 0)')
    axes[0].set_xlabel('x₁', fontsize=12)
    axes[0].set_ylabel('Action', fontsize=12)
    axes[0].set_title(f'Segment 1 Propagator (t₁={t1})', fontsize=13)
    axes[0].legend(fontsize=11)
    axes[0].grid(True, alpha=0.3)

    axes[1].plot(x, K_composed, 'r-', linewidth=2, label='min_x₁[K₁+K₂]')
    axes[1].plot(x, K_direct, 'b--', linewidth=2, label='K_direct(x₂, 0)')
    axes[1].set_xlabel('x₂', fontsize=12)
    axes[1].set_ylabel('Action', fontsize=12)
    axes[1].set_title('Tropical Composition vs Direct', fontsize=13)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    axes[2].plot(x, optimal_x1, 'g-', linewidth=2)
    axes[2].plot(x, x * t1 / (t1 + t2), 'k--', linewidth=2,
                  label=f'x₁* = x₂·t₁/(t₁+t₂)')
    axes[2].set_xlabel('x₂', fontsize=12)
    axes[2].set_ylabel('Optimal x₁', fontsize=12)
    axes[2].set_title('Optimal Intermediate Point', fontsize=13)
    axes[2].legend(fontsize=11)
    axes[2].grid(True, alpha=0.3)

    max_err = np.max(np.abs(K_composed - K_direct))
    plt.tight_layout()
    plt.savefig('tropical_feynman_propagator.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 3: Tropical propagator composition saved")
    print(f"  Max error (composed vs direct): {max_err:.6e}")
    print(f"  Tropical composition = direct propagator ✓" if max_err < 0.1 else "")


# ============================================================
# Demo 4: Tropical Interference at Caustics
# ============================================================
def demo_tropical_interference():
    """
    When two path actions become equal, we have a tropical caustic —
    the analogue of quantum interference maxima.
    """
    x = np.linspace(-5, 5, 1000)

    # Two action branches (e.g., from double slit)
    S1 = 0.5 * (x - 1)**2 + 0.5
    S2 = 0.5 * (x + 1)**2 + 0.5

    # Tropical interference = min(S1, S2)
    S_trop = np.minimum(S1, S2)

    # Quantum interference at different ε
    eps_vals = [0.05, 0.2, 1.0, 5.0]

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for idx, eps in enumerate(eps_vals):
        ax = axes[idx // 2][idx % 2]

        # Quantum probability: |e^{-S1/ε} + e^{-S2/ε}|
        # (real-valued analogue)
        prob = np.exp(-S1 / eps) + np.exp(-S2 / eps)
        soft_min = -eps * np.log(prob)

        ax.plot(x, S1, 'b--', alpha=0.5, label='S₁')
        ax.plot(x, S2, 'r--', alpha=0.5, label='S₂')
        ax.plot(x, S_trop, 'k-', linewidth=2, label='min(S₁,S₂)')
        ax.plot(x, soft_min, 'g-', linewidth=2, label=f'LSE_ε (ε={eps})')

        # Mark caustic (crossing point)
        caustic_idx = np.argmin(np.abs(S1 - S2))
        ax.axvline(x=x[caustic_idx], color='purple', linestyle=':', alpha=0.5)
        ax.annotate('Caustic', xy=(x[caustic_idx], S_trop[caustic_idx]),
                    fontsize=10, color='purple')

        ax.set_xlabel('x', fontsize=11)
        ax.set_ylabel('Action / Soft Min', fontsize=11)
        ax.set_title(f'ε = {eps} ({"Tropical" if eps < 0.1 else "Quantum" if eps > 2 else "Transition"})',
                     fontsize=12)
        ax.legend(fontsize=9, loc='upper right')
        ax.grid(True, alpha=0.3)
        ax.set_ylim(-0.5, 6)

    plt.suptitle('Tropical Interference: From Quantum (large ε) to Classical (small ε)',
                 fontsize=14, y=1.02)
    plt.tight_layout()
    plt.savefig('tropical_feynman_interference.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 4: Tropical interference at caustics saved")


if __name__ == '__main__':
    print("=" * 60)
    print("Tropical Feynman Integrals — Future Direction 6.1")
    print("=" * 60)

    demo_maslov_convergence()
    demo_stationary_phase()
    demo_tropical_propagator()
    demo_tropical_interference()

    print("\n" + "=" * 60)
    print("All demos complete! Generated 4 PNG files.")
    print("=" * 60)
