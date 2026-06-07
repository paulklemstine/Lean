#!/usr/bin/env python3
"""
Demonstration of the Substitution Tiling Spectrum for the Hat Monotile.

This script computes numerical examples illustrating the key theorems:
1. Tile count growth under substitution
2. Area growth law verification
3. Spectral invariance across the hat spectrum
4. Eigenvalue computations
5. Frequency convergence to the Perron eigenvector
"""

import numpy as np
from typing import Tuple, List

# Hat substitution matrix
HAT_MATRIX = np.array([[4, 6], [2, 4]], dtype=float)

# Hat expansion factor
HAT_EXPANSION = 1 + np.sqrt(3)

# Hat area vector
HAT_AREA = np.array([1.0, np.sqrt(3)])


def tile_count(M: np.ndarray, k: int, j: int) -> np.ndarray:
    """Compute tile count vector after k substitutions starting from tile j."""
    Mk = np.linalg.matrix_power(M.astype(int), k)
    return Mk[:, j]


def total_area(M: np.ndarray, k: int, j: int, area: np.ndarray) -> float:
    """Compute total area after k substitutions."""
    counts = tile_count(M, k, j)
    return float(np.dot(counts, area))


def verify_area_growth_law():
    """Verify Theorem 3.1: totalArea(k,j) = lambda^(2k) * area(j)."""
    print("=" * 60)
    print("THEOREM 3.1: Area Growth Law")
    print("=" * 60)
    print(f"Expansion factor lambda = 1 + sqrt(3) = {HAT_EXPANSION:.6f}")
    print(f"lambda^2 = {HAT_EXPANSION**2:.6f} = 4 + 2*sqrt(3)")
    print()
    
    for j in range(2):
        print(f"Starting tile type {j} (area = {HAT_AREA[j]:.6f}):")
        print(f"  {'k':>3} | {'totalArea(k,j)':>16} | {'lambda^(2k)*a_j':>16} | {'match?':>6}")
        print(f"  {'-'*3}-+-{'-'*16}-+-{'-'*16}-+-{'-'*6}")
        for k in range(7):
            actual = total_area(HAT_MATRIX, k, j, HAT_AREA)
            predicted = HAT_EXPANSION**(2*k) * HAT_AREA[j]
            match = abs(actual - predicted) < 1e-6
            print(f"  {k:3d} | {actual:16.4f} | {predicted:16.4f} | {'  YES' if match else '   NO'}")
        print()


def verify_spectral_invariance():
    """Verify Theorem 3.2: Expansion factor is constant across the spectrum."""
    print("=" * 60)
    print("THEOREM 3.2: Spectral Invariance")
    print("=" * 60)
    print("Hat spectrum: area(t) = (1+t) * [1, sqrt(3)]")
    print()
    
    eigenvalues = np.linalg.eigvals(HAT_MATRIX)
    print(f"Eigenvalues of M: {eigenvalues[0]:.6f}, {eigenvalues[1]:.6f}")
    print(f"Predicted: {4 + 2*np.sqrt(3):.6f}, {4 - 2*np.sqrt(3):.6f}")
    print()
    
    print(f"  {'t':>5} | {'scale c(t)':>10} | {'lambda(t)':>10} | {'constant?':>9}")
    print(f"  {'-'*5}-+-{'-'*10}-+-{'-'*10}-+-{'-'*9}")
    
    for t in np.linspace(0, 1, 11):
        c = 1 + t
        area_t = c * HAT_AREA
        # Verify eigenvector equation: M^T * area_t = lambda^2 * area_t
        lhs = HAT_MATRIX.T @ area_t
        lambda_sq = lhs[0] / area_t[0]
        lambda_t = np.sqrt(lambda_sq)
        match = abs(lambda_t - HAT_EXPANSION) < 1e-10
        print(f"  {t:5.2f} | {c:10.4f} | {lambda_t:10.6f} | {'  YES' if match else '   NO'}")
    print()


def verify_eigenvalue_properties():
    """Verify Theorems 4.2-4.4: Spectral data of the hat matrix."""
    print("=" * 60)
    print("THEOREMS 4.2-4.4: Hat Matrix Spectral Data")
    print("=" * 60)
    
    trace = np.trace(HAT_MATRIX)
    det = np.linalg.det(HAT_MATRIX)
    eigenvalues = sorted(np.linalg.eigvals(HAT_MATRIX), reverse=True)
    
    print(f"Trace(M) = {trace:.0f} (expected: 8)")
    print(f"Det(M) = {det:.0f} (expected: 4)")
    print()
    print(f"Dominant eigenvalue:    {eigenvalues[0]:.6f} (expected: {4 + 2*np.sqrt(3):.6f})")
    print(f"Subdominant eigenvalue: {eigenvalues[1]:.6f} (expected: {4 - 2*np.sqrt(3):.6f})")
    print()
    print(f"Product of eigenvalues: {eigenvalues[0] * eigenvalues[1]:.6f} (= det = 4)")
    print(f"Sum of eigenvalues:     {eigenvalues[0] + eigenvalues[1]:.6f} (= trace = 8)")
    print()
    print(f"Pisot-like property: 0 < {eigenvalues[1]:.6f} < 1? {0 < eigenvalues[1] < 1}")
    print()


def verify_frequency_convergence():
    """Demonstrate frequency convergence to the Perron eigenvector."""
    print("=" * 60)
    print("FREQUENCY CONVERGENCE (Pisot-like property)")
    print("=" * 60)
    print("Tile type ratios converge to [1, sqrt(3)] direction")
    print(f"Expected ratio H*/H = sqrt(3) = {np.sqrt(3):.6f}")
    print()
    
    for j in range(2):
        print(f"Starting from tile type {j}:")
        print(f"  {'k':>3} | {'H count':>10} | {'H* count':>10} | {'ratio H*/H':>12} | {'error':>12}")
        print(f"  {'-'*3}-+-{'-'*10}-+-{'-'*10}-+-{'-'*12}-+-{'-'*12}")
        for k in range(1, 10):
            counts = tile_count(HAT_MATRIX, k, j)
            ratio = counts[1] / counts[0] if counts[0] > 0 else float('inf')
            error = abs(ratio - 1/np.sqrt(3))
            print(f"  {k:3d} | {counts[0]:10.0f} | {counts[1]:10.0f} | {ratio:12.8f} | {error:12.2e}")
        print()


def verify_irrational_obstruction():
    """Demonstrate Theorem 3.3: Irrational expansion obstructs commensurability."""
    print("=" * 60)
    print("THEOREM 3.3: Irrational Expansion Obstruction")
    print("=" * 60)
    print()
    print(f"lambda^2 = {HAT_EXPANSION**2:.10f} = 4 + 2*sqrt(3)")
    print(f"sqrt(3) = {np.sqrt(3):.10f}")
    print()
    print("If the system were rationally commensurable:")
    print("  area(1)/area(0) = sqrt(3) would need to be rational")
    print("  But sqrt(3) is irrational (3 is prime)")
    print()
    print("Additionally, lambda^2 = 4 + 2*sqrt(3) is irrational")
    print("So the eigenvector equation would give:")
    print(f"  sum_i M(i,j0) * q_i = lambda^2 = {HAT_EXPANSION**2:.6f}")
    print("  Left side is rational, right side is irrational: CONTRADICTION")
    print()


def growth_bound_demo():
    """Demonstrate Theorem 3.4: Total count upper bound."""
    print("=" * 60)
    print("THEOREM 3.4: Total Count Upper Bound")
    print("=" * 60)
    print(f"a_min = min(1, sqrt(3)) = 1")
    print(f"Bound: totalCount(k,j) <= lambda^(2k) * a_j / a_min")
    print()
    
    a_min = min(HAT_AREA)
    for j in range(2):
        print(f"Starting from tile type {j}:")
        print(f"  {'k':>3} | {'totalCount':>12} | {'upper bound':>12} | {'satisfied?':>10}")
        print(f"  {'-'*3}-+-{'-'*12}-+-{'-'*12}-+-{'-'*10}")
        for k in range(8):
            counts = tile_count(HAT_MATRIX, k, j)
            total = int(np.sum(counts))
            bound = HAT_EXPANSION**(2*k) * HAT_AREA[j] / a_min
            satisfied = total <= bound + 1e-6
            print(f"  {k:3d} | {total:12d} | {bound:12.1f} | {'    YES' if satisfied else '     NO'}")
        print()


if __name__ == "__main__":
    print("SUBSTITUTION TILING SPECTRUM — NUMERICAL DEMONSTRATIONS")
    print("=" * 60)
    print()
    
    verify_area_growth_law()
    verify_spectral_invariance()
    verify_eigenvalue_properties()
    verify_frequency_convergence()
    verify_irrational_obstruction()
    growth_bound_demo()
    
    print("All demonstrations complete.")


#!/usr/bin/env python3
"""
Visualization: Hat Substitution Spectrum eigenvalue structure
and tile count growth.
"""
import numpy as np
import matplotlib.pyplot as plt
import matplotlib

matplotlib.rcParams['font.size'] = 12


def plot_eigenvalue_spectrum():
    """Plot eigenvalues and Pisot-like property of the hat matrix."""
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))

    # Panel 1: Eigenvalues on the real line
    ax = axes[0]
    lam1 = 4 + 2 * np.sqrt(3)
    lam2 = 4 - 2 * np.sqrt(3)

    ax.axhline(y=0, color='gray', linewidth=0.5)
    ax.axvline(x=1, color='gray', linewidth=0.5, linestyle='--', label='|λ|=1')

    ax.plot(lam1, 0, 'ro', markersize=12, label=f'λ₁ = 4+2√3 ≈ {lam1:.3f}')
    ax.plot(lam2, 0, 'bs', markersize=12, label=f'λ₂ = 4-2√3 ≈ {lam2:.3f}')

    ax.fill_betweenx([-0.3, 0.3], 0, 1, alpha=0.15, color='green', label='|λ|<1 (contracting)')
    ax.fill_betweenx([-0.3, 0.3], 1, 8, alpha=0.1, color='red', label='|λ|>1 (expanding)')

    ax.set_xlim(-0.5, 8.5)
    ax.set_ylim(-0.5, 0.5)
    ax.set_xlabel('Eigenvalue')
    ax.set_title('Hat Matrix Eigenvalues\n(Pisot-like structure)')
    ax.legend(fontsize=9, loc='upper left')

    # Panel 2: Tile count growth
    ax = axes[1]
    M = np.array([[4, 6], [2, 4]])
    ks = range(0, 8)
    counts_0 = [np.sum(np.linalg.matrix_power(M, k)[:, 0]) for k in ks]
    counts_1 = [np.sum(np.linalg.matrix_power(M, k)[:, 1]) for k in ks]
    growth = [lam1**k for k in ks]

    ax.semilogy(ks, counts_0, 'ro-', label='Start from H', markersize=6)
    ax.semilogy(ks, counts_1, 'bs-', label='Start from H*', markersize=6)
    ax.semilogy(ks, growth, 'k--', alpha=0.5, label=f'λ₁^k (growth rate)')

    ax.set_xlabel('Substitution steps k')
    ax.set_ylabel('Total tile count')
    ax.set_title('Tile Count Growth\n(exponential at rate λ₁)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    # Panel 3: Frequency convergence
    ax = axes[2]
    target_ratio = 1 / np.sqrt(3)
    ratios_0 = []
    ratios_1 = []
    for k in range(1, 12):
        c0 = np.linalg.matrix_power(M, k)[:, 0]
        c1 = np.linalg.matrix_power(M, k)[:, 1]
        ratios_0.append(c0[1] / c0[0] if c0[0] > 0 else 0)
        ratios_1.append(c1[1] / c1[0] if c1[0] > 0 else 0)

    ks2 = range(1, 12)
    ax.plot(ks2, ratios_0, 'ro-', label='Start from H', markersize=6)
    ax.plot(ks2, ratios_1, 'bs-', label='Start from H*', markersize=6)
    ax.axhline(y=target_ratio, color='green', linestyle='--',
               label=f'Perron ratio 1/√3 ≈ {target_ratio:.4f}')

    ax.set_xlabel('Substitution steps k')
    ax.set_ylabel('Ratio H*/H')
    ax.set_title('Frequency Convergence\n(to Perron eigenvector)')
    ax.legend()
    ax.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('hat_spectrum_analysis.png', dpi=150, bbox_inches='tight')
    plt.show()
    print("Saved: hat_spectrum_analysis.png")


if __name__ == "__main__":
    plot_eigenvalue_spectrum()
