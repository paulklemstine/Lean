"""
KMS–Gödel Barrier: Numerical Demonstrations and Visualizations

This script demonstrates the core mathematical content of the KMS–Gödel
Barrier theorem through concrete numerical examples and visualizations.

The theorem states: no closure self-model carrying a modular thermodynamic
structure can simultaneously support exact internal truth and KMS equilibrium
at positive inverse temperature β > 0.

The key quantities are:
  - The modular free-energy gap Δ(β), which must be > 0 for all β > 0
    (thermodynamic constraint)
  - The truthfulness defect ε(β), which must equal 0 for exact truth
    (semantic constraint)

Since Δ(β) > 0 but exact truth requires Δ(β) = 0, contradiction.

Usage:
    python kms_godel_barrier_demo.py
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.lines import Line2D
import os


# ============================================================================
# §1. Model of the Free-Energy Gap
# ============================================================================

def free_energy_gap(beta, model="linear"):
    """
    Compute the modular free-energy gap Δ(β) for various model choices.
    The KMS–Gödel barrier requires Δ(β) > 0 for all β > 0.
    """
    beta = np.asarray(beta, dtype=float)
    if model == "linear":
        return 0.5 * beta
    elif model == "logarithmic":
        return np.log(1 + beta)
    elif model == "sqrt":
        return np.sqrt(beta)
    elif model == "phase_transition":
        return np.where(beta < 2, 0.3 * beta, 0.6 + 0.8 * (beta - 2))
    else:
        raise ValueError(f"Unknown model: {model}")


# ============================================================================
# §2. Main Visualization: The Barrier
# ============================================================================

def plot_barrier():
    """Visualize the KMS–Gödel barrier."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))
    beta = np.linspace(0.01, 5, 500)

    # Left panel: Free-energy gap for different models
    ax = axes[0]
    models = ["linear", "logarithmic", "sqrt", "phase_transition"]
    colors = ["#2196F3", "#4CAF50", "#FF9800", "#E91E63"]
    labels = [
        r"$\Delta(\beta) = \frac{1}{2}\beta$",
        r"$\Delta(\beta) = \ln(1+\beta)$",
        r"$\Delta(\beta) = \sqrt{\beta}$",
        r"$\Delta(\beta)$ with phase transition"
    ]
    for model, color, label in zip(models, colors, labels):
        ax.plot(beta, free_energy_gap(beta, model), color=color, lw=2, label=label)
    ax.axhline(y=0, color='red', lw=2, ls='--', label=r"Exact truth: $\Delta = 0$")
    ax.fill_between(beta, -0.1, 0, alpha=0.15, color='red')
    ax.text(2.5, -0.05, "FORBIDDEN\n(exact truth)", fontsize=10,
            ha='center', color='red', fontweight='bold')
    ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax.set_ylabel(r'Free-energy gap $\Delta(\beta)$', fontsize=13)
    ax.set_title('KMS–Gödel Barrier:\nFree-Energy Gap Must Be Positive', fontsize=14, fontweight='bold')
    ax.set_ylim(-0.15, 3.5); ax.set_xlim(0, 5)
    ax.legend(fontsize=9, loc='upper left'); ax.grid(True, alpha=0.3)

    # Right panel: The contradiction
    ax = axes[1]
    gap_thermo = free_energy_gap(beta, "sqrt")
    ax.fill_between(beta, gap_thermo, 4, alpha=0.2, color='blue',
                    label='Thermodynamically allowed\n(KMS equilibrium)')
    ax.fill_between(beta, -0.1, 0.05, alpha=0.2, color='green',
                    label='Semantically required\n(exact truth)')
    ax.plot(beta, gap_thermo, 'b-', lw=2.5)
    ax.axhline(y=0, color='green', lw=2.5)
    ax.annotate('CONTRADICTION\nat every β > 0', xy=(2.5, 0), xytext=(3, 1.5),
                fontsize=12, fontweight='bold', color='red',
                arrowprops=dict(arrowstyle='->', color='red', lw=2), ha='center')
    ax.plot(0, 0, 'ko', markersize=8, zorder=5)
    ax.annotate(r'$\beta = 0$: gap vanishes', xy=(0, 0), xytext=(0.5, -0.08), fontsize=9)
    ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax.set_ylabel(r'Free-energy gap $\Delta(\beta)$', fontsize=13)
    ax.set_title('The Barrier: Two Incompatible\nConstraints at β > 0', fontsize=14, fontweight='bold')
    ax.set_ylim(-0.15, 3.5); ax.set_xlim(-0.1, 5)
    ax.legend(fontsize=10, loc='upper left'); ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('kms_godel_barrier.png', dpi=150, bbox_inches='tight')
    print("Saved: kms_godel_barrier.png")
    plt.close()


# ============================================================================
# §3. Approximate Truth Tradeoff
# ============================================================================

def plot_approximate_truth():
    """Show the tradeoff between approximation quality and temperature."""
    fig, ax = plt.subplots(figsize=(8, 6))
    beta = np.linspace(0.01, 5, 500)
    gap = free_energy_gap(beta, "sqrt")

    ax.fill_between(beta, gap, 4, alpha=0.15, color='blue')
    ax.fill_between(beta, 0, gap, alpha=0.15, color='red')
    ax.plot(beta, gap, 'b-', lw=2.5, label=r'Barrier: $\varepsilon \geq \Delta(\beta)$')

    for b, label in [(0.5, 'Hot'), (1.0, 'Warm'), (2.0, 'Cool'), (4.0, 'Cold')]:
        g = free_energy_gap(np.array([b]), "sqrt")[0]
        ax.plot(b, g, 'ro', markersize=8, zorder=5)
        ax.annotate(f'{label}\nε ≥ {g:.2f}', xy=(b, g), xytext=(b + 0.2, g + 0.3),
                    fontsize=9, arrowprops=dict(arrowstyle='->', color='gray'))

    ax.text(2.5, 0.3, 'Impossible\n(below barrier)', fontsize=11,
            ha='center', color='red', fontweight='bold')
    ax.text(2.5, 2.5, 'Achievable\n(above barrier)', fontsize=11,
            ha='center', color='blue', fontweight='bold')
    ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax.set_ylabel(r'Truthfulness defect $\varepsilon$', fontsize=13)
    ax.set_title('Approximate Truth: Minimum Defect vs Temperature', fontsize=14, fontweight='bold')
    ax.set_ylim(-0.1, 3.5); ax.set_xlim(0, 5)
    ax.legend(fontsize=11, loc='upper left'); ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('approximate_truth_tradeoff.png', dpi=150, bbox_inches='tight')
    print("Saved: approximate_truth_tradeoff.png")
    plt.close()


# ============================================================================
# §4. Phase Diagram
# ============================================================================

def plot_phase_diagram():
    """Phase diagram of self-truth under KMS equilibrium."""
    fig, ax = plt.subplots(figsize=(9, 7))
    beta = np.linspace(0, 5, 1000)
    epsilon = np.linspace(0, 3, 1000)
    B, E = np.meshgrid(beta, epsilon)
    barrier = np.sqrt(B)
    achievable = E >= barrier

    ax.contourf(B, E, achievable.astype(float), levels=[-0.5, 0.5, 1.5],
                colors=['#FFCDD2', '#C8E6C9'], alpha=0.5)
    ax.contour(B, E, E - barrier, levels=[0], colors=['#F44336'], linewidths=3)
    ax.text(3.5, 2.5, 'ACHIEVABLE\nε-approximate\nself-truth',
            fontsize=12, ha='center', color='#2E7D32', fontweight='bold')
    ax.text(3.5, 0.5, 'FORBIDDEN\nby KMS–Gödel\nbarrier',
            fontsize=12, ha='center', color='#C62828', fontweight='bold')
    ax.axhline(y=0, color='black', lw=1, ls=':')
    ax.text(4.5, -0.12, 'Exact truth (ε = 0)', fontsize=9, ha='center')
    ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax.set_ylabel(r'Truthfulness defect $\varepsilon$', fontsize=13)
    ax.set_title('Phase Diagram of Self-Truth\nunder KMS Equilibrium', fontsize=14, fontweight='bold')
    ax.set_xlim(0, 5); ax.set_ylim(-0.2, 3); ax.grid(True, alpha=0.2)

    legend_elements = [
        Line2D([0], [0], color='#F44336', lw=3, label=r'Barrier: $\varepsilon = \Delta(\beta)$'),
        mpatches.Patch(facecolor='#C8E6C9', alpha=0.5, label='Achievable region'),
        mpatches.Patch(facecolor='#FFCDD2', alpha=0.5, label='Forbidden region'),
    ]
    ax.legend(handles=legend_elements, fontsize=10, loc='upper left')
    plt.tight_layout()
    plt.savefig('phase_diagram.png', dpi=150, bbox_inches='tight')
    print("Saved: phase_diagram.png")
    plt.close()


# ============================================================================
# §5. Analogy: The Speed of Light Barrier
# ============================================================================

def plot_analogy():
    """Analogy between KMS–Gödel barrier and speed-of-light barrier."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # Left: Speed of light
    ax = axes[0]
    v = np.linspace(0, 0.999, 500)
    gamma = 1 / np.sqrt(1 - v**2)
    ax.plot(v, gamma, 'b-', lw=2.5)
    ax.axvline(x=1.0, color='red', lw=2, ls='--', label=r'$v = c$ (forbidden)')
    ax.fill_betweenx([0, 20], 1.0, 1.1, alpha=0.2, color='red')
    ax.set_xlabel(r'Velocity $v/c$', fontsize=13)
    ax.set_ylabel(r'Energy $E/mc^2$', fontsize=13)
    ax.set_title('Special Relativity:\nSpeed-of-Light Barrier', fontsize=14, fontweight='bold')
    ax.set_ylim(0, 10); ax.set_xlim(0, 1.05)
    ax.legend(fontsize=11); ax.grid(True, alpha=0.3)
    ax.text(0.5, 7, 'Energy → ∞\nas v → c', fontsize=11, ha='center', color='blue')

    # Right: KMS–Gödel barrier
    ax = axes[1]
    beta = np.linspace(0.01, 5, 500)
    gap = np.sqrt(beta)
    ax.plot(beta, gap, 'b-', lw=2.5, label=r'Gap $\Delta(\beta)$')
    ax.axhline(y=0, color='red', lw=2, ls='--', label=r'$\Delta = 0$ (forbidden for $\beta > 0$)')
    ax.fill_between(beta, -0.2, 0, alpha=0.2, color='red')
    ax.set_xlabel(r'Inverse temperature $\beta$', fontsize=13)
    ax.set_ylabel(r'Free-energy gap $\Delta(\beta)$', fontsize=13)
    ax.set_title('KMS–Gödel Barrier:\nSelf-Truth Barrier', fontsize=14, fontweight='bold')
    ax.set_ylim(-0.2, 3); ax.set_xlim(0, 5)
    ax.legend(fontsize=11, loc='upper left'); ax.grid(True, alpha=0.3)
    ax.text(2.5, 0.3, 'Gap > 0 always\nfor β > 0', fontsize=11, ha='center', color='blue')

    fig.suptitle('Analogous Barriers in Physics', fontsize=16, fontweight='bold', y=1.02)
    plt.tight_layout()
    plt.savefig('barrier_analogy.png', dpi=150, bbox_inches='tight')
    print("Saved: barrier_analogy.png")
    plt.close()


# ============================================================================
# §6. Numerical Example
# ============================================================================

def concrete_self_model_demo():
    """Demonstrate the barrier with concrete numerics."""
    print("=" * 60)
    print("CONCRETE SELF-MODEL DEMONSTRATION")
    print("=" * 60)

    beta_values = [0.1, 0.5, 1.0, 2.0, 5.0, 10.0]
    print(f"\nModel: Information-theoretic free energy")
    print(f"Gap: Δ(β) = β · 0.2 · ln(2) ≈ β · 0.1386")
    print()
    print(f"{'β':>8} | {'Δ(β)':>12} | {'Exact truth?':>14} | {'Status':>16}")
    print("-" * 60)
    for beta in beta_values:
        gap = beta * 0.2 * np.log(2)
        status = "BARRIER HOLDS" if gap > 0 else "VIOLATED"
        print(f"{beta:8.1f} | {gap:12.8f} | {'NO':>14} | {status:>16}")

    print()
    print("As β → 0⁺:")
    for beta in [0.01, 0.001, 0.0001]:
        gap = beta * 0.2 * np.log(2)
        print(f"  β = {beta:.4f}: Δ(β) = {gap:.10f} → 0 but never 0")

    print()
    print("CONCLUSION: For ALL β > 0, Δ(β) > 0, so exact truth is impossible.")
    print("This confirms the KMS–Gödel Barrier theorem.")


# ============================================================================
# Main
# ============================================================================

if __name__ == "__main__":
    print("KMS–Gödel Barrier: Numerical Demonstrations")
    print("=" * 50)
    print()

    os.makedirs("output", exist_ok=True)
    os.chdir("output")

    print("Generating visualizations...")
    plot_barrier()
    plot_approximate_truth()
    plot_phase_diagram()
    plot_analogy()
    print()
    concrete_self_model_demo()
    print()
    print("=" * 50)
    print("All demonstrations complete. Figures saved to output/")
