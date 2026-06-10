#!/usr/bin/env python3
"""
Neural Scaling Laws — Numerical Demonstrations

Demonstrates the key mathematical results:
1. Harmonic scaling exponent computation
2. Compute-optimal allocation
3. Spectral-to-scaling exponent map
4. Bottleneck principle visualization
"""

import math


def harmonic_exponent(alpha: float, beta: float) -> float:
    """Compute the harmonic scaling exponent γ = αβ/(α+β)."""
    return alpha * beta / (alpha + beta)


def spectral_to_scaling(s: float) -> float:
    """Map spectral decay rate s > 1 to scaling exponent α = (s-1)/s."""
    assert s > 1, f"Spectral decay rate must be > 1, got {s}"
    return (s - 1) / s


def compute_optimal_allocation(
    alpha: float, beta: float, A: float, B: float, C: float
) -> tuple[float, float, float]:
    """
    Compute optimal (N*, P*, L*) given exponents, coefficients, and compute budget.

    Returns (N_opt, P_opt, L_excess) where L_excess = A*N^{-α} + B*P^{-β}.
    """
    # P* = (βB C^α / (αA 6^α))^{1/(α+β)}
    # Simplified: using C = 6NP, so NP = C/6
    # At optimality: α A N^{-α} = β B P^{-β}
    # With NP = C/6, solve numerically via the ratio

    # The optimal ratio: N/P = (βB/(αA))^{1/(α+β)} * (C/6)^{(β-α)/(α+β) - 1} ...
    # Simpler: parametrize N = t, P = C/(6t), minimize over t
    import scipy.optimize as opt

    def loss(log_t: float) -> float:
        t = math.exp(log_t)
        N = t
        P = C / (6 * t)
        if P <= 0:
            return 1e30
        return A * N ** (-alpha) + B * P ** (-beta)

    # Search over log(N) ∈ [0, log(C/6)]
    result = opt.minimize_scalar(loss, bounds=(0, math.log(C / 6)), method="bounded")
    N_opt = math.exp(result.x)
    P_opt = C / (6 * N_opt)
    L_opt = result.fun
    return N_opt, P_opt, L_opt


def verify_harmonic_identity(alpha: float, beta: float) -> None:
    """Verify γ = 1/(1/α + 1/β) — the harmonic mean identity."""
    gamma_direct = alpha * beta / (alpha + beta)
    gamma_reciprocal = 1.0 / (1.0 / alpha + 1.0 / beta)
    print(f"  α={alpha}, β={beta}")
    print(f"  γ (direct)     = {gamma_direct:.6f}")
    print(f"  γ (reciprocal) = {gamma_reciprocal:.6f}")
    print(f"  Match: {abs(gamma_direct - gamma_reciprocal) < 1e-12}")


def verify_balance_condition(
    alpha: float, beta: float, A: float, B: float, C: float
) -> None:
    """Verify that at optimality, α·R_N = β·R_P."""
    N_opt, P_opt, _ = compute_optimal_allocation(alpha, beta, A, B, C)
    R_N = A * N_opt ** (-alpha)
    R_P = B * P_opt ** (-beta)
    print(f"  α·R_N = {alpha * R_N:.6f}")
    print(f"  β·R_P = {beta * R_P:.6f}")
    print(f"  Ratio: {(alpha * R_N) / (beta * R_P):.6f} (should be ≈ 1.0)")


def demonstrate_bottleneck_principle() -> None:
    """Show that the worse-scaling resource gets more compute."""
    print("\n=== Bottleneck Principle ===")
    alpha, beta = 0.3, 0.7
    gamma = harmonic_exponent(alpha, beta)
    n_share = beta / (alpha + beta)  # N gets β/(α+β) of compute exponent
    p_share = alpha / (alpha + beta)  # P gets α/(α+β) of compute exponent
    print(f"  α={alpha} (data, worse), β={beta} (params, better)")
    print(f"  N share of compute exponent: {n_share:.4f}")
    print(f"  P share of compute exponent: {p_share:.4f}")
    print(f"  Data (bottleneck) gets MORE compute: {n_share > p_share}")
    print(f"  Harmonic exponent γ = {gamma:.4f}")
    print(f"  Arithmetic mean = {(alpha + beta) / 2:.4f}")
    print(f"  γ < min(α,β) = {min(alpha, beta):.4f}: {gamma < min(alpha, beta)}")


def demonstrate_spectral_map() -> None:
    """Show the spectral-to-scaling exponent map."""
    print("\n=== Spectral-to-Scaling Map ===")
    print(f"  {'s':>6} {'α=(s-1)/s':>12} {'Note':>20}")
    for s in [1.5, 2.0, 3.0, 4.0, 5.0, 10.0, 100.0]:
        alpha = spectral_to_scaling(s)
        note = ""
        if s == 2.0:
            note = "typical transformer"
        elif s == 5.0:
            note = "fast decay"
        print(f"  {s:6.1f} {alpha:12.6f} {note:>20}")
    print(f"  s→∞: α→1 (each data point maximally informative)")


def demonstrate_chinchilla() -> None:
    """Demonstrate Chinchilla-style compute-optimal training."""
    print("\n=== Chinchilla Compute-Optimal Training ===")
    # Published Chinchilla exponents (approximate)
    alpha, beta = 0.34, 0.34
    A, B = 406.4, 410.7
    gamma = harmonic_exponent(alpha, beta)
    print(f"  Exponents: α={alpha}, β={beta}")
    print(f"  Harmonic exponent: γ = {gamma:.4f}")
    print(f"  (Since α≈β, γ ≈ α/2 = {alpha/2:.4f})")

    for C_exp in [18, 20, 22, 24]:
        C = 10**C_exp
        N_opt, P_opt, L_excess = compute_optimal_allocation(alpha, beta, A, B, C)
        print(f"\n  Compute = 10^{C_exp} FLOPs:")
        print(f"    Optimal N = {N_opt:.2e}")
        print(f"    Optimal P = {P_opt:.2e}")
        print(f"    N/P ratio = {N_opt / P_opt:.2f}")
        print(f"    Excess loss = {L_excess:.4f}")


def main() -> None:
    print("=" * 60)
    print("Neural Scaling Laws — Numerical Demonstrations")
    print("=" * 60)

    # 1. Harmonic identity verification
    print("\n=== Harmonic Mean Identity: γ = 1/(1/α + 1/β) ===")
    verify_harmonic_identity(0.34, 0.34)
    verify_harmonic_identity(0.5, 0.8)
    verify_harmonic_identity(0.3, 0.7)

    # 2. AM-HM inequality
    print("\n=== AM-HM Inequality: γ ≤ (α+β)/2, equality iff α=β ===")
    for a, b in [(0.3, 0.7), (0.5, 0.5), (0.4, 0.6), (0.34, 0.34)]:
        hm = harmonic_exponent(a, b)
        am = (a + b) / 2
        gap = am - hm
        print(f"  α={a}, β={b}: HM={hm:.4f}, AM={am:.4f}, gap={gap:.6f}")

    # 3. Balance condition
    print("\n=== Balance Condition: α·R_N = β·R_P at optimality ===")
    verify_balance_condition(0.34, 0.34, 406.4, 410.7, 1e21)

    # 4. Bottleneck principle
    demonstrate_bottleneck_principle()

    # 5. Spectral map
    demonstrate_spectral_map()

    # 6. Chinchilla demonstration
    demonstrate_chinchilla()

    print("\n" + "=" * 60)
    print("All demonstrations completed successfully.")
    print("=" * 60)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Neural Scaling Laws
Generates plots showing key mathematical results.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib


def harmonic_exponent(alpha: float, beta: float) -> float:
    return alpha * beta / (alpha + beta)


def plot_harmonic_surface():
    """Plot the harmonic exponent γ as a function of (α, β)."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Surface plot of γ = αβ/(α+β)
    alpha_vals = np.linspace(0.05, 1.5, 100)
    beta_vals = np.linspace(0.05, 1.5, 100)
    A, B = np.meshgrid(alpha_vals, beta_vals)
    G = A * B / (A + B)

    ax = axes[0]
    c = ax.contourf(A, B, G, levels=30, cmap='viridis')
    ax.contour(A, B, G, levels=10, colors='white', linewidths=0.5, alpha=0.5)
    # Diagonal line α = β
    ax.plot([0.05, 1.5], [0.05, 1.5], 'r--', linewidth=2, label='α = β (balanced)')
    ax.set_xlabel('α (data exponent)', fontsize=12)
    ax.set_ylabel('β (param exponent)', fontsize=12)
    ax.set_title('Compute Scaling Exponent γ = αβ/(α+β)', fontsize=13)
    ax.legend(fontsize=10)
    plt.colorbar(c, ax=ax, label='γ')

    # Comparison: HM vs AM along a slice
    ax2 = axes[1]
    beta_fixed = 0.5
    alphas = np.linspace(0.05, 2.0, 200)
    hm = alphas * beta_fixed / (alphas + beta_fixed)
    am = (alphas + beta_fixed) / 2
    gm = np.sqrt(alphas * beta_fixed)
    min_vals = np.minimum(alphas, beta_fixed)

    ax2.plot(alphas, hm, 'b-', linewidth=2.5, label=f'HM = αβ/(α+β) [γ]')
    ax2.plot(alphas, am, 'r--', linewidth=2, label='AM = (α+β)/2')
    ax2.plot(alphas, gm, 'g-.', linewidth=2, label='GM = √(αβ)')
    ax2.plot(alphas, min_vals, 'k:', linewidth=2, label='min(α,β)')
    ax2.axvline(x=beta_fixed, color='gray', linestyle=':', alpha=0.5)
    ax2.set_xlabel('α (data exponent)', fontsize=12)
    ax2.set_ylabel('Value', fontsize=12)
    ax2.set_title(f'Mean Comparisons (β = {beta_fixed})', fontsize=13)
    ax2.legend(fontsize=10)
    ax2.set_ylim(0, 1.5)

    plt.tight_layout()
    plt.savefig('scaling_harmonic_exponent.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: scaling_harmonic_exponent.png")


def plot_spectral_map():
    """Plot the spectral-to-scaling exponent map."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # α(s) = (s-1)/s
    s_vals = np.linspace(1.01, 10, 500)
    alpha_vals = (s_vals - 1) / s_vals

    ax = axes[0]
    ax.plot(s_vals, alpha_vals, 'b-', linewidth=2.5)
    ax.axhline(y=1, color='r', linestyle='--', alpha=0.5, label='Limit α = 1')
    ax.fill_between(s_vals, 0, alpha_vals, alpha=0.1, color='blue')
    ax.set_xlabel('Spectral decay rate s', fontsize=12)
    ax.set_ylabel('Scaling exponent α = (s-1)/s', fontsize=12)
    ax.set_title('Spectral-to-Scaling Map', fontsize=13)
    ax.legend(fontsize=11)
    ax.set_ylim(0, 1.1)

    # Compute exponent for different spectral pairs
    ax2 = axes[1]
    s_data_vals = np.linspace(1.5, 6, 100)
    for s_param in [2.0, 3.0, 5.0]:
        alpha_data = (s_data_vals - 1) / s_data_vals
        beta_param = (s_param - 1) / s_param
        gamma_vals = alpha_data * beta_param / (alpha_data + beta_param)
        ax2.plot(s_data_vals, gamma_vals, linewidth=2,
                 label=f's_param = {s_param} (β = {beta_param:.2f})')

    ax2.set_xlabel('Data spectral decay s_data', fontsize=12)
    ax2.set_ylabel('Compute exponent γ', fontsize=12)
    ax2.set_title('Compute Exponent from Spectral Pairs', fontsize=13)
    ax2.legend(fontsize=10)

    plt.tight_layout()
    plt.savefig('scaling_spectral_map.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: scaling_spectral_map.png")


def plot_compute_optimal():
    """Plot compute-optimal allocation and scaling curves."""
    fig, axes = plt.subplots(1, 2, figsize=(14, 5))

    # Loss curves at different compute budgets
    ax = axes[0]
    alpha, beta, A, B = 0.34, 0.34, 406.4, 410.7

    C_values = np.logspace(17, 25, 200)
    optimal_losses = []

    for C in C_values:
        budget = C / 6
        # Optimal N: minimize A*(N)^{-α} + B*(budget/N)^{-β}
        log_n = np.linspace(1, np.log(budget) - 1, 1000)
        N_vals = np.exp(log_n)
        P_vals = budget / N_vals
        losses = A * N_vals**(-alpha) + B * P_vals**(-beta)
        optimal_losses.append(np.min(losses))

    optimal_losses = np.array(optimal_losses)
    ax.loglog(C_values, optimal_losses, 'b-', linewidth=2.5, label='L*(C) - E')

    # Fit power law
    log_C = np.log(C_values)
    log_L = np.log(optimal_losses)
    slope = np.polyfit(log_C, log_L, 1)[0]
    gamma_pred = harmonic_exponent(alpha, beta)

    ax.set_xlabel('Compute C (FLOPs)', fontsize=12)
    ax.set_ylabel('Excess Loss L* - E', fontsize=12)
    ax.set_title(f'Compute Scaling (measured γ ≈ {-slope:.3f}, predicted {gamma_pred:.3f})', fontsize=12)
    ax.legend(fontsize=11)
    ax.grid(True, alpha=0.3)

    # Optimal N, P vs C
    ax2 = axes[1]
    N_opts, P_opts = [], []
    for C in C_values:
        budget = C / 6
        log_n = np.linspace(1, np.log(budget) - 1, 1000)
        N_vals = np.exp(log_n)
        P_vals = budget / N_vals
        losses = A * N_vals**(-alpha) + B * P_vals**(-beta)
        idx = np.argmin(losses)
        N_opts.append(N_vals[idx])
        P_opts.append(P_vals[idx])

    n_exp = np.polyfit(np.log(C_values), np.log(N_opts), 1)[0]
    p_exp = np.polyfit(np.log(C_values), np.log(P_opts), 1)[0]
    pred_n = beta / (alpha + beta)
    pred_p = alpha / (alpha + beta)

    ax2.loglog(C_values, N_opts, 'b-', linewidth=2, label=f'N* (slope ≈ {n_exp:.3f}, pred {pred_n:.3f})')
    ax2.loglog(C_values, P_opts, 'r-', linewidth=2, label=f'P* (slope ≈ {p_exp:.3f}, pred {pred_p:.3f})')
    ax2.set_xlabel('Compute C (FLOPs)', fontsize=12)
    ax2.set_ylabel('Optimal N or P', fontsize=12)
    ax2.set_title('Compute-Optimal Allocation', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('scaling_compute_optimal.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("Saved: scaling_compute_optimal.png")


if __name__ == "__main__":
    matplotlib.use('Agg')
    plot_harmonic_surface()
    plot_spectral_map()
    plot_compute_optimal()
    print("All visualizations generated.")
