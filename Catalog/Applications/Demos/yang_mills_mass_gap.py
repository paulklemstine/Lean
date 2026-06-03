#!/usr/bin/env python3
"""
Demo: Yang-Mills Mass Gap — Transfer Matrix Spectral Analysis

Demonstrates the key mathematical results:
1. Transfer matrix eigenvalue spectrum and mass gap computation
2. Strong coupling mass gap divergence
3. Exponential clustering from mass gap
4. Wilson loop area law decay
5. Casimir control of filtration gap
"""

import math
from typing import List, Tuple


def compute_mass_gap(eigenvalues: List[float]) -> float:
    """Compute the mass gap Δ = -log(λ₁/λ₀) from transfer matrix eigenvalues."""
    if len(eigenvalues) < 2:
        raise ValueError("Need at least 2 eigenvalues")
    if eigenvalues[0] <= 0 or eigenvalues[1] <= 0:
        raise ValueError("Eigenvalues must be positive")
    ratio = eigenvalues[1] / eigenvalues[0]
    return -math.log(ratio)


def correlation_function(eigenvalues: List[float], amplitudes: List[float], t: int) -> float:
    """Compute correlation function: corr(t) = Σ aᵢ · (λᵢ/λ₀)^t"""
    lambda0 = eigenvalues[0]
    return sum(a * (lam / lambda0) ** t for a, lam in zip(amplitudes, eigenvalues))


def strong_coupling_gap(beta: float, gap_coeff: float = 1.0) -> float:
    """Mass gap at strong coupling: Δ ≈ c · (-log β)"""
    if beta <= 0:
        raise ValueError("β must be positive")
    return gap_coeff * (-math.log(beta))


def wilson_loop_bound(sigma: float, area: int) -> float:
    """Wilson loop area law bound: |⟨W⟩| ≤ exp(-σ·A)"""
    return math.exp(-sigma * area)


def su2_casimir(j: float) -> float:
    """Casimir eigenvalue for SU(2) representation with spin j: c₂(j) = j(j+1)"""
    return j * (j + 1)


def filtration_gap(sector_eigenvalues: List[float]) -> float:
    """Filtration gap: Δ_F = -log(λ₁/λ₀)"""
    return -math.log(sector_eigenvalues[1] / sector_eigenvalues[0])


def main():
    print("=" * 70)
    print("Yang-Mills Mass Gap: Transfer Matrix Spectral Analysis")
    print("=" * 70)

    # --- Demo 1: Basic mass gap computation ---
    print("\n--- Demo 1: Mass Gap from Transfer Matrix Eigenvalues ---")
    eigenvalues = [1.0, 0.5, 0.25, 0.1, 0.05]
    gap = compute_mass_gap(eigenvalues)
    print(f"Transfer matrix eigenvalues: {eigenvalues}")
    print(f"Mass gap Δ = -log(λ₁/λ₀) = -log({eigenvalues[1]}/{eigenvalues[0]}) = {gap:.4f}")
    print(f"This means the lightest particle has mass Δ = {gap:.4f} in lattice units")

    # --- Demo 2: Strong coupling mass gap ---
    print("\n--- Demo 2: Strong Coupling Mass Gap ---")
    print("At strong coupling (small β), Δ ≈ c · (-log β):")
    for beta in [0.1, 0.01, 0.001, 0.0001]:
        gap = strong_coupling_gap(beta)
        print(f"  β = {beta:.4f}: Δ ≈ {gap:.4f}")
    print("The gap diverges as β → 0⁺ (strong coupling → infinite confinement)")

    # --- Demo 3: Exponential clustering ---
    print("\n--- Demo 3: Exponential Clustering from Mass Gap ---")
    eigenvalues = [1.0, 0.6, 0.3, 0.1]
    amplitudes = [0.0, 0.5, -0.3, 0.2]  # ground state amplitude = 0 (connected correlator)
    gap = compute_mass_gap(eigenvalues)
    print(f"Mass gap Δ = {gap:.4f}")
    print(f"Correlation function decay:")
    for t in range(0, 11, 2):
        corr = correlation_function(eigenvalues, amplitudes, t)
        bound = len(eigenvalues) * math.exp(-gap * t)
        print(f"  t = {t:2d}: corr(t) = {corr:+.6f}, |corr(t)| ≤ {bound:.6f}")

    # --- Demo 4: Wilson loop area law ---
    print("\n--- Demo 4: Wilson Loop Area Law ---")
    sigma = 0.3  # string tension
    print(f"String tension σ = {sigma}")
    print(f"Wilson loop bounds |⟨W(A)⟩| ≤ exp(-σ·A):")
    for area in range(0, 21, 4):
        bound = wilson_loop_bound(sigma, area)
        print(f"  Area = {area:2d}: bound = {bound:.6f}")

    # --- Demo 5: Casimir control of filtration gap ---
    print("\n--- Demo 5: SU(2) Casimir Control ---")
    print("SU(2) Casimir eigenvalues c₂(j) = j(j+1):")
    for j_half in range(5):
        j = j_half / 2
        cas = su2_casimir(j)
        print(f"  j = {j:.1f}: c₂ = {cas:.2f}")

    # Simulate sector eigenvalues with Casimir suppression
    lambda0 = 1.0
    print(f"\nSector eigenvalues with Casimir suppression λ_j = λ₀ · exp(-c₂(j)):")
    sector_eigs = []
    for j_half in range(5):
        j = j_half / 2
        cas = su2_casimir(j)
        lam = lambda0 * math.exp(-cas)
        sector_eigs.append(lam)
        print(f"  j = {j:.1f}: λ_j = {lam:.6f}")

    fgap = filtration_gap(sector_eigs)
    casimir_bound = su2_casimir(0.5)
    print(f"\nFiltration gap Δ_F = {fgap:.4f}")
    print(f"Casimir bound c₂(1/2) = {casimir_bound:.4f}")
    print(f"Casimir controls gap: c₂(1/2) ≤ Δ_F? {casimir_bound <= fgap}")

    # --- Demo 6: Perturbation stability ---
    print("\n--- Demo 6: Perturbation Stability ---")
    original_eigs = [1.0, 0.5]
    gap_original = filtration_gap(original_eigs)
    print(f"Original gap: {gap_original:.4f}")
    for delta in [0.01, 0.05, 0.1, 0.2]:
        perturbed_eigs = [original_eigs[0] * (1 + delta), original_eigs[1] * (1 - delta)]
        gap_perturbed = filtration_gap(perturbed_eigs)
        print(f"  δ = {delta:.2f}: perturbed gap = {gap_perturbed:.4f} "
              f"(change = {abs(gap_perturbed - gap_original):.4f})")

    print("\n" + "=" * 70)
    print("All demonstrations completed successfully.")
    print("Key result: The mass gap is controlled by algebraic (Casimir) data")
    print("of the gauge group, connecting representation theory to confinement.")


if __name__ == "__main__":
    main()


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


#!/usr/bin/env python3
"""
Visualization: Wilson Loop Area Law and Confinement

Demonstrates the connection between mass gap and confinement
through the Wilson loop area law.
"""

import math


def main():
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
        import numpy as np
    except ImportError:
        print("matplotlib/numpy not available.")
        sigma = 0.3
        for r in range(1, 11):
            for T in [5, 10, 20]:
                bound = math.exp(-sigma * r * T)
                print(f"  r={r:2d}, T={T:2d}: |W| ≤ {bound:.6e}")
        return

    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    fig.suptitle('Wilson Loop Area Law and Confinement', fontsize=14, fontweight='bold')

    # Panel 1: Wilson loop vs area for different σ
    ax1 = axes[0]
    areas = np.arange(0, 25)
    for sigma in [0.1, 0.3, 0.5, 1.0]:
        bounds = [math.exp(-sigma * a) for a in areas]
        ax1.semilogy(areas, bounds, '-o', markersize=3, label=f'σ = {sigma}')

    ax1.set_xlabel('Area A')
    ax1.set_ylabel('|⟨W(A)⟩|')
    ax1.set_title('Wilson Loop Area Law')
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    # Panel 2: Confining potential V(r) = σ·r
    ax2 = axes[1]
    r_vals = np.linspace(0.1, 5, 100)
    for sigma in [0.1, 0.3, 0.5, 1.0]:
        V = sigma * r_vals
        ax2.plot(r_vals, V, linewidth=2, label=f'σ = {sigma}')

    ax2.set_xlabel('Quark separation r')
    ax2.set_ylabel('Potential V(r)')
    ax2.set_title('Linear Confining Potential')
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    # Panel 3: Mass gap → string tension connection
    ax3 = axes[2]
    gaps = np.linspace(0.05, 2.0, 50)
    string_tensions = gaps  # σ ≥ Δ in our framework
    ax3.plot(gaps, string_tensions, 'b-', linewidth=2)
    ax3.fill_between(gaps, string_tensions, 2.5, alpha=0.1, color='blue')
    ax3.set_xlabel('Mass gap Δ')
    ax3.set_ylabel('String tension σ')
    ax3.set_title('Mass Gap → String Tension')
    ax3.annotate('σ ≥ Δ\n(Confinement region)', xy=(1.0, 1.5),
                 fontsize=11, ha='center', color='blue')
    ax3.grid(True, alpha=0.3)
    ax3.set_xlim(0, 2)
    ax3.set_ylim(0, 2.5)

    plt.tight_layout()
    plt.savefig('wilson_loop_area_law.png', dpi=150, bbox_inches='tight')
    print("Saved: wilson_loop_area_law.png")


if __name__ == "__main__":
    main()
