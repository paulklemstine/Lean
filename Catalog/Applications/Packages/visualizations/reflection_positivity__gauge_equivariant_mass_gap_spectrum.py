#!/usr/bin/env python3
"""
Visualization: Transfer Matrix Spectrum and Mass Gap

Generates a plot showing the eigenvalue spectrum, mass gap,
and exponential clustering decay.
"""

import math


def generate_eigenvalues(n_sectors: int = 8) -> list:
    """Generate SU(2)-like eigenvalue spectrum."""
    eigenvalues = []
    for j_half in range(n_sectors):
        j = j_half / 2.0
        casimir = j * (j + 1)
        lam = math.exp(-casimir)
        eigenvalues.append(lam)
    return eigenvalues


def compute_correlation(eigenvalues: list, t_max: int = 20) -> tuple:
    """Compute correlation decay with exponential bound."""
    gap = -math.log(eigenvalues[1] / eigenvalues[0])
    times = list(range(t_max + 1))
    correlations = []
    bounds = []
    n = len(eigenvalues)
    lam0 = eigenvalues[0]
    amplitudes = [0.0] + [1.0 / (n - 1)] * (n - 1)  # Connected correlator

    for t in times:
        corr = sum(a * (lam / lam0) ** t for a, lam in zip(amplitudes, eigenvalues))
        bound = n * math.exp(-gap * t)
        correlations.append(abs(corr))
        bounds.append(bound)

    return times, correlations, bounds, gap


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available. Printing numerical results instead.")
        eigenvalues = generate_eigenvalues()
        gap = -math.log(eigenvalues[1] / eigenvalues[0])
        print(f"Eigenvalue spectrum: {[f'{e:.4f}' for e in eigenvalues]}")
        print(f"Mass gap: {gap:.4f}")
        times, corrs, bounds, _ = compute_correlation(eigenvalues)
        for t, c, b in zip(times, corrs, bounds):
            print(f"  t={t:2d}: |corr|={c:.6e}, bound={b:.6e}")
        return

    fig, axes = plt.subplots(2, 2, figsize=(14, 10))
    fig.suptitle('Yang-Mills Mass Gap: Transfer Matrix Spectral Analysis',
                 fontsize=14, fontweight='bold')

    # Panel 1: Eigenvalue spectrum
    ax1 = axes[0, 0]
    eigenvalues = generate_eigenvalues(8)
    spins = [j / 2.0 for j in range(8)]
    casimirs = [j * (j + 1) / 4 for j in range(8)]  # j/2 * (j/2 + 1)
    casimirs = [s * (s + 1) for s in spins]

    ax1.bar(range(len(eigenvalues)), eigenvalues, color='steelblue', alpha=0.8)
    ax1.set_xlabel('Sector index σ')
    ax1.set_ylabel('λ_σ')
    ax1.set_title('Transfer Matrix Sector Eigenvalues')
    ax1.set_xticks(range(len(eigenvalues)))
    ax1.set_xticklabels([f'j={s}' for s in spins], fontsize=8)

    # Add mass gap annotation
    gap = -math.log(eigenvalues[1] / eigenvalues[0])
    ax1.annotate(f'Δ = {gap:.3f}', xy=(0.5, eigenvalues[0] * 0.8),
                 fontsize=11, color='red', fontweight='bold')
    ax1.axhline(y=eigenvalues[1], color='red', linestyle='--', alpha=0.5)
    ax1.annotate('', xy=(0.3, eigenvalues[0]), xytext=(0.3, eigenvalues[1]),
                 arrowprops=dict(arrowstyle='<->', color='red', lw=2))

    # Panel 2: Casimir control
    ax2 = axes[0, 1]
    log_ratios = [math.log(e / eigenvalues[0]) for e in eigenvalues]
    neg_casimirs = [-c for c in casimirs]

    ax2.scatter(casimirs, log_ratios, s=80, color='darkred', zorder=5)
    ax2.plot(casimirs, neg_casimirs, 'k--', label='log(λ_σ/λ₀) = -c₂(σ)', alpha=0.7)
    ax2.set_xlabel('Casimir eigenvalue c₂(σ)')
    ax2.set_ylabel('log(λ_σ / λ₀)')
    ax2.set_title('Casimir Control: log(λ_σ/λ₀) ≤ -c₂(σ)')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    # Panel 3: Correlation decay
    ax3 = axes[1, 0]
    times, corrs, bounds, gap = compute_correlation(eigenvalues)

    ax3.semilogy(times, corrs, 'b-o', markersize=4, label='|corr(t)|')
    ax3.semilogy(times, bounds, 'r--', label=f'n·exp(-Δt), Δ={gap:.3f}')
    ax3.set_xlabel('Euclidean time t')
    ax3.set_ylabel('|Correlation|')
    ax3.set_title('Exponential Clustering from Mass Gap')
    ax3.legend()
    ax3.grid(True, alpha=0.3)

    # Panel 4: Strong coupling mass gap
    ax4 = axes[1, 1]
    betas = np.linspace(0.01, 1.0, 200)
    gaps_leading = [-math.log(b) for b in betas]
    gaps_corrected = [max(0, -math.log(b) - 0.5) for b in betas]

    ax4.plot(betas, gaps_leading, 'b-', linewidth=2, label='Leading: -log(β)')
    ax4.plot(betas, gaps_corrected, 'r-', linewidth=2, label='Corrected: -log(β) - ε')
    ax4.axhline(y=0, color='k', linestyle='-', alpha=0.3)
    ax4.set_xlabel('Coupling β')
    ax4.set_ylabel('Mass gap Δ')
    ax4.set_title('Strong Coupling Mass Gap Divergence')
    ax4.legend()
    ax4.grid(True, alpha=0.3)
    ax4.set_ylim(-0.5, 6)

    plt.tight_layout()
    plt.savefig('mass_gap_spectrum.png', dpi=150, bbox_inches='tight')
    print("Saved: mass_gap_spectrum.png")


if __name__ == "__main__":
    main()
