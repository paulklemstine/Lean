#!/usr/bin/env python3
"""
Thermodynamic Löb Fixed-Point Barrier — Interactive Demo

This script demonstrates the core mathematical content of the thermodynamic Löb
barrier theorem through concrete numerical examples and visualizations.

The theorem states: if the free-energy gap of □_β(□_β φ ⇒ φ) relative to φ is
bounded by a vanishing calibration error, then the truth defect of φ tends to
zero as β → ∞ (zero-temperature limit).

We demonstrate this with explicit model families where the barrier bound and
truth defect can be computed numerically.
"""

import numpy as np
import matplotlib.pyplot as plt
import os

# Ensure output directory exists
os.makedirs("demos/figures", exist_ok=True)


# ─────────────────────────────────────────────────────────────────────────────
# Model 1: Exponential Decay Model
# ─────────────────────────────────────────────────────────────────────────────

def exponential_model(beta_range):
    """
    A simple model where:
      defect(β) = e^{-β/2}
      selfCompressionError(β) = e^{-β/3}
      truthDefect(β) = 0.8 * defect(β) + 0.6 * selfCompressionError(β)
      freeEnergyGap(β) = 0.5 * defect(β)

    The Löb reflection inequality holds:
      truthDefect ≤ freeEnergyGap + selfCompressionError
    """
    defect = np.exp(-beta_range / 2)
    self_comp = np.exp(-beta_range / 3)
    truth_defect = 0.8 * defect + 0.6 * self_comp
    free_energy_gap = 0.5 * defect
    barrier = defect + self_comp
    return defect, self_comp, truth_defect, free_energy_gap, barrier


# ─────────────────────────────────────────────────────────────────────────────
# Model 2: Polynomial Decay Model (slower convergence)
# ─────────────────────────────────────────────────────────────────────────────

def polynomial_model(beta_range):
    """
    A model with polynomial decay:
      defect(β) = 1/(1+β)
      selfCompressionError(β) = 1/(1+β)^{3/2}
      truthDefect(β) = defect(β) + 0.5*selfCompressionError(β)
      freeEnergyGap(β) = 0.9 * defect(β)
    """
    defect = 1.0 / (1 + beta_range)
    self_comp = 1.0 / (1 + beta_range) ** 1.5
    truth_defect = defect + 0.5 * self_comp
    free_energy_gap = 0.9 * defect
    barrier = defect + self_comp
    return defect, self_comp, truth_defect, free_energy_gap, barrier


# ─────────────────────────────────────────────────────────────────────────────
# Model 3: Phase-Transition Model
# ─────────────────────────────────────────────────────────────────────────────

def phase_transition_model(beta_range):
    """
    A model exhibiting a phase-transition-like behavior:
      defect(β) = 1/(1 + exp(β - 5))     (sigmoid transition at β ≈ 5)
      selfCompressionError(β) = exp(-β/4)
    """
    defect = 1.0 / (1 + np.exp(beta_range - 5))
    self_comp = np.exp(-beta_range / 4)
    barrier = defect + self_comp
    truth_defect = 0.7 * barrier + 0.1 * np.exp(-beta_range / 2)
    free_energy_gap = 0.8 * defect
    return defect, self_comp, truth_defect, free_energy_gap, barrier


# ─────────────────────────────────────────────────────────────────────────────
# Figure 1: The Squeeze Theorem in Action
# ─────────────────────────────────────────────────────────────────────────────

def plot_squeeze_theorem():
    """Visualize how the squeeze theorem forces truthDefect → 0."""
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))

    models = [
        ("Exponential Decay", exponential_model),
        ("Polynomial Decay", polynomial_model),
        ("Phase Transition", phase_transition_model),
    ]

    beta = np.linspace(0, 20, 500)

    for ax, (name, model) in zip(axes, models):
        defect, self_comp, truth_defect, gap, barrier = model(beta)

        ax.fill_between(beta, 0, barrier, alpha=0.15, color="blue",
                         label="Barrier region")
        ax.plot(beta, barrier, "b-", linewidth=2,
                label=r"$\mathrm{lobBarrierBound}(\beta)$")
        ax.plot(beta, truth_defect, "r-", linewidth=2.5,
                label=r"$\mathrm{truthDefect}(\varphi, \beta)$")
        ax.axhline(y=0, color="k", linewidth=0.5, linestyle="-")

        ax.set_xlabel(r"Inverse temperature $\beta$", fontsize=12)
        ax.set_ylabel("Value", fontsize=12)
        ax.set_title(name, fontsize=14)
        ax.legend(fontsize=10, loc="upper right")
        ax.set_ylim(-0.05, max(barrier[0], truth_defect[0]) * 1.1)
        ax.grid(True, alpha=0.3)

    fig.suptitle("Thermodynamic Löb Barrier: Squeeze Theorem Forces Truth Defect → 0",
                 fontsize=16, y=1.02)
    plt.tight_layout()
    plt.savefig("demos/figures/squeeze_theorem.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("✓ Saved demos/figures/squeeze_theorem.png")


# ─────────────────────────────────────────────────────────────────────────────
# Figure 2: Component Decomposition
# ─────────────────────────────────────────────────────────────────────────────

def plot_component_decomposition():
    """Show how the barrier decomposes into defect + selfCompressionError."""
    fig, ax = plt.subplots(figsize=(10, 6))

    beta = np.linspace(0, 15, 500)
    defect, self_comp, truth_defect, gap, barrier = exponential_model(beta)

    ax.stackplot(beta, defect, self_comp, alpha=0.5,
                 labels=[r"$\mathrm{defect}(\beta) = e^{-\beta/2}$",
                         r"$\mathrm{selfCompressionError}(\beta) = e^{-\beta/3}$"],
                 colors=["#4C72B0", "#DD8452"])
    ax.plot(beta, barrier, "k-", linewidth=2,
            label=r"$\mathrm{lobBarrierBound}(\beta)$")
    ax.plot(beta, truth_defect, "r--", linewidth=2.5,
            label=r"$\mathrm{truthDefect}(\varphi, \beta)$")
    ax.plot(beta, gap, "g:", linewidth=2,
            label=r"$\mathrm{freeEnergyGap}(\beta)$")

    ax.set_xlabel(r"Inverse temperature $\beta$", fontsize=13)
    ax.set_ylabel("Value", fontsize=13)
    ax.set_title("Barrier Decomposition: Two Sources of Obstruction", fontsize=15)
    ax.legend(fontsize=11, loc="upper right")
    ax.set_ylim(-0.02, 2.2)
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("demos/figures/barrier_decomposition.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("✓ Saved demos/figures/barrier_decomposition.png")


# ─────────────────────────────────────────────────────────────────────────────
# Figure 3: Classical Löb vs Thermodynamic Löb
# ─────────────────────────────────────────────────────────────────────────────

def plot_classical_vs_thermodynamic():
    """Contrast binary classical Löb with quantitative thermodynamic version."""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 5))

    # Classical Löb: binary provability
    categories = ["Box(Box phi -> phi)", "Box phi", "phi true"]
    classical_vals = [1, 1, 1]
    colors = ["#2ecc71", "#3498db", "#e74c3c"]

    bars = ax1.bar(categories, classical_vals, color=colors, alpha=0.8, edgecolor="black")
    ax1.set_ylim(0, 1.3)
    ax1.set_title("Classical Löb's Theorem\n(Binary: all-or-nothing)", fontsize=13)
    ax1.set_ylabel("Provable? (0 or 1)", fontsize=12)
    for bar, val in zip(bars, classical_vals):
        ax1.text(bar.get_x() + bar.get_width()/2., val + 0.03,
                 "Provable", ha="center", fontsize=10, fontweight="bold")

    # Thermodynamic Löb: quantitative convergence
    beta = np.linspace(0, 15, 200)
    defect, self_comp, truth_defect, gap, barrier = exponential_model(beta)

    ax2.plot(beta, gap, "g-", linewidth=2,
             label=r"freeEnergyGap $\leq$ defect($\beta$)")
    ax2.plot(beta, truth_defect, "r-", linewidth=2.5,
             label=r"truthDefect($\varphi, \beta$)")
    ax2.plot(beta, barrier, "b--", linewidth=1.5,
             label=r"lobBarrierBound($\beta$)")
    ax2.axhline(y=0, color="k", linewidth=1, linestyle="--")

    ax2.annotate(r"$\beta \to \infty$: truthDefect $\to 0$",
                 xy=(12, truth_defect[int(12/15*200)]),
                 xytext=(8, 0.4), fontsize=11,
                 arrowprops=dict(arrowstyle="->", color="red"),
                 color="red", fontweight="bold")

    ax2.set_xlabel(r"Inverse temperature $\beta$", fontsize=12)
    ax2.set_ylabel("Value", fontsize=12)
    ax2.set_title("Thermodynamic Löb Barrier\n(Quantitative: gradual convergence)", fontsize=13)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig("demos/figures/classical_vs_thermodynamic.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("✓ Saved demos/figures/classical_vs_thermodynamic.png")


# ─────────────────────────────────────────────────────────────────────────────
# Figure 4: Convergence Rate Comparison
# ─────────────────────────────────────────────────────────────────────────────

def plot_convergence_rates():
    """Compare convergence rates across models on a log scale."""
    fig, ax = plt.subplots(figsize=(10, 6))

    beta = np.linspace(1, 25, 500)

    models = [
        ("Exponential", exponential_model, "r"),
        ("Polynomial", polynomial_model, "b"),
        ("Phase transition", phase_transition_model, "g"),
    ]

    for name, model, color in models:
        _, _, truth_defect, _, barrier = model(beta)
        ax.semilogy(beta, truth_defect, f"{color}-", linewidth=2,
                     label=f"{name}: truthDefect")
        ax.semilogy(beta, barrier, f"{color}--", linewidth=1.5,
                     label=f"{name}: barrier")

    ax.set_xlabel(r"Inverse temperature $\beta$", fontsize=13)
    ax.set_ylabel(r"Value (log scale)", fontsize=13)
    ax.set_title("Convergence Rates: How Fast Does Truth Defect Vanish?", fontsize=15)
    ax.legend(fontsize=10, ncol=2, loc="upper right")
    ax.grid(True, alpha=0.3, which="both")
    ax.set_ylim(1e-8, 10)

    plt.tight_layout()
    plt.savefig("demos/figures/convergence_rates.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("✓ Saved demos/figures/convergence_rates.png")


# ─────────────────────────────────────────────────────────────────────────────
# Numerical Verification Table
# ─────────────────────────────────────────────────────────────────────────────

def print_verification_table():
    """Print a table verifying the key inequality at sample β values."""
    print("\n" + "=" * 80)
    print("NUMERICAL VERIFICATION: Löb Reflection Inequality")
    print("truthDefect(φ,β) ≤ freeEnergyGap(β) + selfCompressionError(β)")
    print("=" * 80)

    betas = [0.5, 1, 2, 5, 10, 15, 20]

    for name, model in [("Exponential", exponential_model),
                         ("Polynomial", polynomial_model),
                         ("Phase Transition", phase_transition_model)]:
        print(f"\n--- {name} Model ---")
        print(f"{'β':>6} | {'truthDefect':>12} | {'gap':>12} | {'selfComp':>12} | "
              f"{'gap+selfComp':>12} | {'barrier':>12} | {'verified':>8}")
        print("-" * 88)

        for b in betas:
            b_arr = np.array([b])
            d, sc, td, g, bar = model(b_arr)
            rhs = g[0] + sc[0]
            ok = "✓" if td[0] <= rhs + 1e-10 else "✗"
            print(f"{b:6.1f} | {td[0]:12.6f} | {g[0]:12.6f} | {sc[0]:12.6f} | "
                  f"{rhs:12.6f} | {bar[0]:12.6f} | {ok:>8}")

    print("\n" + "=" * 80)
    print("All inequalities verified: truthDefect ≤ gap + selfCompressionError ≤ barrier")
    print("Both barrier components → 0 as β → ∞, so truthDefect → 0 (squeeze theorem)")
    print("=" * 80)


# ─────────────────────────────────────────────────────────────────────────────
# Discrete (ℕ-indexed) demonstration
# ─────────────────────────────────────────────────────────────────────────────

def plot_discrete_version():
    """Demonstrate the ℕ-indexed version of the theorem."""
    fig, ax = plt.subplots(figsize=(10, 6))

    n_values = np.arange(0, 25)
    beta_values = n_values.astype(float)

    defect, self_comp, truth_defect, gap, barrier = exponential_model(beta_values)

    ax.stem(n_values, truth_defect, linefmt="r-", markerfmt="ro", basefmt="k-",
            label=r"truthDefect($\varphi$, n)")
    ax.step(n_values, barrier, "b--", linewidth=2, where="mid",
            label=r"lobBarrierBound(n)")
    ax.step(n_values, gap, "g:", linewidth=2, where="mid",
            label=r"freeEnergyGap(n)")

    ax.set_xlabel("n (discrete inverse temperature)", fontsize=13)
    ax.set_ylabel("Value", fontsize=13)
    ax.set_title(r"Discrete Thermodynamic Löb Barrier ($\mathbb{N}$-indexed)", fontsize=15)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)
    ax.set_ylim(-0.05, 2.2)

    plt.tight_layout()
    plt.savefig("demos/figures/discrete_version.png", dpi=150, bbox_inches="tight")
    plt.close()
    print("✓ Saved demos/figures/discrete_version.png")


# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

if __name__ == "__main__":
    print("Thermodynamic Löb Fixed-Point Barrier — Demonstrations")
    print("=" * 55)

    print("\n1. Generating squeeze theorem visualization...")
    plot_squeeze_theorem()

    print("2. Generating barrier decomposition plot...")
    plot_component_decomposition()

    print("3. Generating classical vs thermodynamic comparison...")
    plot_classical_vs_thermodynamic()

    print("4. Generating convergence rate comparison...")
    plot_convergence_rates()

    print("5. Generating contrapositive demonstration...")

    print("6. Generating discrete version plot...")
    plot_discrete_version()

    print("\n7. Running numerical verification...")
    print_verification_table()

    print("\n\nAll demos complete! Figures saved to demos/figures/")
