"""
EML Quantum Density Estimation Demo
=====================================
Future Direction 6.4: EML framework for quantum density reconstruction.

Given measurements of |ψ|² = ρ, the EML (Exp-Mul-Log) framework
recovers the classical density structure via:
  log(ρ(t)) = log(ρ₀) - ∫div(v)dt

This demo shows:
  1. EML exp/log roundtrip and density evolution
  2. Multi-branch density estimation from wave function
  3. Tropical limit of density concentration
  4. Boltzmann weight visualization
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


# ============================================================
# Demo 1: EML Density Evolution
# ============================================================
def demo_eml_evolution():
    """
    Demonstrate the EML density evolution:
    ρ(t) = ρ₀ · exp(-∫div(v)dt)

    In log space, this becomes linear:
    log(ρ(t)) = log(ρ₀) - ∫div(v)dt
    """
    t = np.linspace(0, 5, 500)

    # Different divergence functions
    div_functions = {
        'Constant div=0.5': lambda t: 0.5 * np.ones_like(t),
        'Oscillating': lambda t: 0.5 + 0.3 * np.sin(2 * np.pi * t),
        'Growing': lambda t: 0.1 * t,
        'Decaying': lambda t: 1.0 / (1 + t),
    }

    rho0 = 1.0

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    for idx, (name, div_fn) in enumerate(div_functions.items()):
        ax = axes[idx // 2][idx % 2]

        div_vals = div_fn(t)
        # Cumulative integral of divergence
        div_integral = np.cumsum(div_vals) * (t[1] - t[0])

        # EML density evolution
        rho = rho0 * np.exp(-div_integral)
        log_rho = np.log(rho)

        # Verify: log_rho should equal log(rho0) - div_integral
        log_rho_eml = np.log(rho0) - div_integral
        eml_error = np.max(np.abs(log_rho - log_rho_eml))

        ax2 = ax.twinx()
        l1 = ax.plot(t, rho, 'b-', linewidth=2, label='ρ(t) = ρ₀·exp(-∫div)')
        l2 = ax2.plot(t, log_rho, 'r--', linewidth=2, label='log(ρ(t))')
        l3 = ax2.plot(t, log_rho_eml, 'g:', linewidth=3, alpha=0.5,
                       label='EML: log(ρ₀) - ∫div')

        ax.set_xlabel('Time t', fontsize=11)
        ax.set_ylabel('Density ρ', fontsize=11, color='blue')
        ax2.set_ylabel('Log-density', fontsize=11, color='red')
        ax.set_title(f'{name} (EML error: {eml_error:.2e})', fontsize=12)

        lines = l1 + l2 + l3
        labels = [l.get_label() for l in lines]
        ax.legend(lines, labels, fontsize=8, loc='upper right')
        ax.grid(True, alpha=0.3)

    plt.suptitle('EML Density Evolution: Exponential ↔ Logarithmic', fontsize=14)
    plt.tight_layout()
    plt.savefig('eml_density_evolution.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Demo 1: EML density evolution saved")


# ============================================================
# Demo 2: Multi-Branch Wave Function Density
# ============================================================
def demo_multi_branch():
    """
    Reconstruct branch densities from total |ψ|² measurements.
    ψ = Σ_j √ρ_j · exp(iφ_j/ℏ)
    |ψ|² = Σ_{j,k} √(ρ_j·ρ_k) · cos((φ_j-φ_k)/ℏ)
    """
    x = np.linspace(-5, 5, 1000)
    hbar = 1.0

    # Three branches with different densities and phases
    branches = [
        {'rho': np.exp(-(x + 2)**2 / 0.5), 'phi': 5.0 * x},
        {'rho': np.exp(-(x)**2 / 0.8), 'phi': -3.0 * x},
        {'rho': np.exp(-(x - 2)**2 / 0.5), 'phi': 7.0 * x},
    ]

    # Construct total wave function
    psi_total = np.zeros(len(x), dtype=complex)
    for branch in branches:
        sqrt_rho = np.sqrt(branch['rho'])
        psi_j = sqrt_rho * np.exp(1j * branch['phi'] / hbar)
        psi_total += psi_j

    total_prob = np.abs(psi_total)**2
    sum_densities = sum(b['rho'] for b in branches)

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))

    # Individual branch densities
    colors = ['blue', 'red', 'green']
    for i, branch in enumerate(branches):
        axes[0, 0].plot(x, branch['rho'], color=colors[i], linewidth=2,
                         label=f'Branch {i+1}')
    axes[0, 0].set_xlabel('x', fontsize=12)
    axes[0, 0].set_ylabel('ρ_j(x)', fontsize=12)
    axes[0, 0].set_title('Individual Branch Densities', fontsize=13)
    axes[0, 0].legend(fontsize=11)
    axes[0, 0].grid(True, alpha=0.3)

    # Total probability with interference
    axes[0, 1].plot(x, total_prob, 'k-', linewidth=1.5, label='|ψ|² (with interference)')
    axes[0, 1].plot(x, sum_densities, 'r--', linewidth=2, alpha=0.7,
                     label='Σρ_j (no interference)')
    axes[0, 1].set_xlabel('x', fontsize=12)
    axes[0, 1].set_ylabel('Probability', fontsize=12)
    axes[0, 1].set_title('Total Density: Quantum vs Classical', fontsize=13)
    axes[0, 1].legend(fontsize=11)
    axes[0, 1].grid(True, alpha=0.3)

    # Log-density (EML representation)
    log_prob = np.log(total_prob + 1e-30)
    log_sum = np.log(sum_densities + 1e-30)
    axes[1, 0].plot(x, log_prob, 'k-', linewidth=1.5, label='log|ψ|²')
    axes[1, 0].plot(x, log_sum, 'r--', linewidth=2, alpha=0.7, label='log(Σρ_j)')
    axes[1, 0].set_xlabel('x', fontsize=12)
    axes[1, 0].set_ylabel('Log-density', fontsize=12)
    axes[1, 0].set_title('EML Log-Density Representation', fontsize=13)
    axes[1, 0].legend(fontsize=11)
    axes[1, 0].grid(True, alpha=0.3)

    # ℏ → 0 limit
    hbar_vals = [2.0, 1.0, 0.5, 0.1]
    for hb in hbar_vals:
        psi = np.zeros(len(x), dtype=complex)
        for branch in branches:
            psi += np.sqrt(branch['rho']) * np.exp(1j * branch['phi'] / hb)
        axes[1, 1].plot(x, np.abs(psi)**2, linewidth=1.5, label=f'ℏ={hb}', alpha=0.8)

    axes[1, 1].plot(x, sum_densities, 'k--', linewidth=2, label='Classical limit')
    axes[1, 1].set_xlabel('x', fontsize=12)
    axes[1, 1].set_ylabel('|ψ|²', fontsize=12)
    axes[1, 1].set_title('Quantum → Classical (ℏ → 0)', fontsize=13)
    axes[1, 1].legend(fontsize=9)
    axes[1, 1].grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('eml_density_branches.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 2: Multi-branch density estimation saved")


# ============================================================
# Demo 3: Boltzmann/Born Rule Transition
# ============================================================
def demo_boltzmann_born():
    """
    The Born rule P(k) = |⟨k|ψ⟩|² becomes the Boltzmann distribution
    P(k) = exp(-S_k/ε) / Z in the tropical limit.
    """
    actions = np.array([1.0, 2.5, 0.5, 3.0, 1.8])
    n_states = len(actions)

    eps_vals = np.logspace(-2, 1, 100)

    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    # Probability vs epsilon for each state
    for k in range(n_states):
        probs = []
        for eps in eps_vals:
            weights = np.exp(-actions / eps)
            probs.append(weights[k] / np.sum(weights))
        axes[0].semilogx(eps_vals, probs, linewidth=2, label=f'S_{k}={actions[k]}')

    axes[0].set_xlabel('ε (temperature)', fontsize=12)
    axes[0].set_ylabel('P(k)', fontsize=12)
    axes[0].set_title('Born → Boltzmann Transition', fontsize=13)
    axes[0].legend(fontsize=10)
    axes[0].grid(True, alpha=0.3)

    # Entropy vs epsilon
    entropies = []
    for eps in eps_vals:
        weights = np.exp(-actions / eps)
        probs = weights / np.sum(weights)
        entropy = -np.sum(probs * np.log(probs + 1e-30))
        entropies.append(entropy)

    axes[1].semilogx(eps_vals, entropies, 'b-', linewidth=2)
    axes[1].axhline(y=np.log(n_states), color='r', linestyle='--',
                     label=f'Max entropy = ln({n_states})')
    axes[1].set_xlabel('ε (temperature)', fontsize=12)
    axes[1].set_ylabel('Shannon Entropy', fontsize=12)
    axes[1].set_title('Entropy: Quantum → Classical', fontsize=13)
    axes[1].legend(fontsize=11)
    axes[1].grid(True, alpha=0.3)

    # Bar chart at different temperatures
    eps_show = [0.1, 0.5, 2.0, 10.0]
    x = np.arange(n_states)
    width = 0.2

    for i, eps in enumerate(eps_show):
        weights = np.exp(-actions / eps)
        probs = weights / np.sum(weights)
        axes[2].bar(x + i * width, probs, width, label=f'ε={eps}', alpha=0.8)

    axes[2].set_xlabel('State k', fontsize=12)
    axes[2].set_ylabel('P(k)', fontsize=12)
    axes[2].set_title('Probability Distribution', fontsize=13)
    axes[2].set_xticks(x + 1.5 * width)
    axes[2].set_xticklabels([f'S={a}' for a in actions])
    axes[2].legend(fontsize=10)
    axes[2].grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('eml_density_boltzmann.png', dpi=150, bbox_inches='tight')
    plt.close()
    print(f"\n✓ Demo 3: Boltzmann/Born rule transition saved")


if __name__ == '__main__':
    print("=" * 60)
    print("EML Quantum Density Estimation — Future Direction 6.4")
    print("=" * 60)

    demo_eml_evolution()
    demo_multi_branch()
    demo_boltzmann_born()

    print("\n" + "=" * 60)
    print("All demos complete! Generated 3 PNG files.")
    print("=" * 60)
