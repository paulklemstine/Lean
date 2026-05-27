"""
Visualization: Spectral Gap and Perturbation Geometry

This script visualizes how the Lorentzian spectral gap protects against
perturbation, illustrating the core mechanism of the stability theorem.
Shows:
1. Eigenvalue spectrum of a Lorentzian Hessian and its perturbation
2. The cone structure: one positive direction, rest negative
3. How the gap degrades gracefully under perturbation
"""
import numpy as np
import matplotlib.pyplot as plt
from itertools import combinations


def elementary_symmetric_hessian(n, k, x):
    """Compute Hessian of e_k at point x."""
    if k < 2:
        return np.zeros((n, n))
    H = np.zeros((n, n))
    indices = list(range(n))
    for i in range(n):
        for j in range(n):
            if i == j:
                continue
            remaining = [idx for idx in indices if idx != i and idx != j]
            if k - 2 == 0:
                H[i, j] = 1.0
            elif k - 2 <= len(remaining):
                for combo in combinations(remaining, k - 2):
                    prod = 1.0
                    for c in combo:
                        prod *= x[c]
                    H[i, j] += prod
    return H


def main():
    fig, axes = plt.subplots(2, 2, figsize=(14, 11))

    # --- Panel 1: Eigenvalue spectrum of e_3 Hessian ---
    ax1 = axes[0, 0]
    ns = range(4, 16)
    for n in ns:
        H = elementary_symmetric_hessian(n, 3, np.ones(n))
        eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
        colors = ['red' if e > 0 else 'blue' for e in eigs]
        ax1.scatter([n] * len(eigs), eigs, c=colors, s=20, alpha=0.7)

    ax1.axhline(y=0, color='black', linewidth=0.5, linestyle='-')
    ax1.set_xlabel('Dimension $n$', fontsize=12)
    ax1.set_ylabel('Eigenvalue', fontsize=12)
    ax1.set_title('Eigenvalue Spectrum of $H_{e_3}$\n(red = positive, blue = negative)',
                  fontsize=12)
    ax1.grid(True, alpha=0.3)

    # --- Panel 2: Gap degradation under perturbation ---
    ax2 = axes[0, 1]
    n = 8
    k = 3
    H = elementary_symmetric_hessian(n, k, np.ones(n))
    eigs_orig = np.sort(np.linalg.eigvalsh(H))[::-1]
    gap_orig = -eigs_orig[1]

    perturbation_scales = np.linspace(0, 1.5 * gap_orig / n, 50)
    gaps = []
    second_eigs = []

    for delta in perturbation_scales:
        E = delta * np.ones((n, n))
        np.fill_diagonal(E, 0)
        H_pert = H + E
        eigs_pert = np.sort(np.linalg.eigvalsh(H_pert))[::-1]
        second_eigs.append(eigs_pert[1])
        gaps.append(max(0, -eigs_pert[1]))

    ax2.plot(perturbation_scales / (gap_orig / n), gaps, 'b-', linewidth=2,
            label='Residual gap')
    ax2.axhline(y=0, color='red', linewidth=1, linestyle='--', label='Lorentzian boundary')
    ax2.axvline(x=1.0, color='green', linewidth=1.5, linestyle=':',
               label='New threshold $\\delta = \\varepsilon/n$')
    ax2.axvline(x=1.0/n, color='orange', linewidth=1.5, linestyle=':',
               label='Old threshold $\\delta = \\varepsilon/n^2$')
    ax2.fill_between(perturbation_scales / (gap_orig / n), 0, gaps,
                    where=[g > 0 for g in gaps], alpha=0.15, color='blue')
    ax2.set_xlabel('Perturbation $\\delta / (\\varepsilon/n)$', fontsize=12)
    ax2.set_ylabel('Spectral gap', fontsize=12)
    ax2.set_title(f'Gap Degradation ($n={n}$, $e_{k}$)', fontsize=12)
    ax2.legend(fontsize=9)
    ax2.grid(True, alpha=0.3)

    # --- Panel 3: Cauchy-Schwarz bound vs actual quadratic form ---
    ax3 = axes[1, 0]
    n_test = 10
    rng = np.random.RandomState(42)
    B = 1.0
    A = rng.uniform(-B, B, (n_test, n_test))
    A = (A + A.T) / 2

    actual_ratios = []
    for _ in range(5000):
        v = rng.randn(n_test)
        v = v / np.linalg.norm(v)
        qf = v @ A @ v
        actual_ratios.append(abs(qf))

    ax3.hist(actual_ratios, bins=50, density=True, alpha=0.7, color='skyblue',
            edgecolor='navy', label='Observed $|Q_A(v)|/\\|v\\|^2$')
    ax3.axvline(x=n_test * B, color='blue', linewidth=2, linestyle='-',
               label=f'New bound $nB = {n_test}$')
    ax3.axvline(x=n_test**2 * B, color='red', linewidth=2, linestyle='--',
               label=f'Old bound $n^2 B = {n_test**2}$')
    ax3.axvline(x=max(actual_ratios), color='green', linewidth=1.5,
               linestyle=':', label=f'Max observed = {max(actual_ratios):.2f}')
    ax3.set_xlabel('$|Q_A(v)| / \\|v\\|^2$', fontsize=12)
    ax3.set_ylabel('Density', fontsize=12)
    ax3.set_title(f'Distribution of Quadratic Form ($n={n_test}$)', fontsize=12)
    ax3.legend(fontsize=9)
    ax3.grid(True, alpha=0.3)

    # --- Panel 4: Scaled threshold n·C(n,k) convergence ---
    ax4 = axes[1, 1]
    for k in [2, 3, 4]:
        scaled_thresholds = []
        ns_list = []
        for n in range(k + 1, 16):
            H = elementary_symmetric_hessian(n, k, np.ones(n))
            eigs = np.sort(np.linalg.eigvalsh(H))[::-1]
            if len(eigs) >= 2 and eigs[1] < -1e-10:
                gap = -eigs[1]
                # Find destruction threshold via bisection
                lo, hi = 0.0, 100.0
                E = np.ones((n, n))
                np.fill_diagonal(E, 0)
                for _ in range(60):
                    mid = (lo + hi) / 2
                    eigs_p = np.linalg.eigvalsh(H + mid * E)
                    if np.sort(eigs_p)[-2] > 1e-12:
                        hi = mid
                    else:
                        lo = mid
                threshold = (lo + hi) / 2
                scaled = n * threshold / gap
                scaled_thresholds.append(scaled)
                ns_list.append(n)

        ax4.plot(ns_list, scaled_thresholds, 'o-', markersize=5, linewidth=1.5,
                label=f'$e_{k}$')

    ax4.set_xlabel('Dimension $n$', fontsize=12)
    ax4.set_ylabel('$n \\cdot C(n,k) / \\varepsilon$', fontsize=12)
    ax4.set_title('Scaled Threshold Convergence', fontsize=12)
    ax4.legend(fontsize=11)
    ax4.grid(True, alpha=0.3)
    ax4.set_ylim(bottom=0)

    plt.tight_layout()
    plt.savefig('viz_spectral_gap.png', dpi=150, bbox_inches='tight')
    print("Saved viz_spectral_gap.png")


if __name__ == "__main__":
    main()
