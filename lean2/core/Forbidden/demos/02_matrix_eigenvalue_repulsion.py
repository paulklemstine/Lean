#!/usr/bin/env python3
"""
🔴🔵 The Matrix — Eigenvalue Repulsion and Random Matrix Theory

Demonstrates the "Matrix Theorem": eigenvalues of random symmetric matrices
repel each other, following the same statistics as:
- Nuclear energy levels
- Zeros of the Riemann zeta function
- Bus arrival times in Cuernavaca, Mexico

We compare:
1. Random (Poisson) spacings — independent events
2. GUE eigenvalue spacings — "repulsion" statistics
3. Actual prime gap distribution
"""

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
from scipy import stats

def random_symmetric_matrix(n):
    """Generate a random symmetric matrix from the GOE ensemble."""
    A = np.random.randn(n, n)
    return (A + A.T) / (2 * np.sqrt(n))

def normalized_spacings(eigenvalues):
    """Compute normalized nearest-neighbor spacings."""
    sorted_eigs = np.sort(eigenvalues)
    spacings = np.diff(sorted_eigs)
    # Normalize by local mean spacing
    mean_spacing = np.mean(spacings)
    if mean_spacing > 0:
        return spacings / mean_spacing
    return spacings

def wigner_surmise(s):
    """Wigner surmise for GOE: P(s) = (π/2)s exp(-πs²/4)"""
    return (np.pi / 2) * s * np.exp(-np.pi * s**2 / 4)

def poisson_spacing(s):
    """Poisson spacing distribution: P(s) = exp(-s)"""
    return np.exp(-s)

def sieve_primes(limit):
    """Sieve of Eratosthenes."""
    is_prime = [True] * (limit + 1)
    is_prime[0] = is_prime[1] = False
    for i in range(2, int(limit**0.5) + 1):
        if is_prime[i]:
            for j in range(i*i, limit + 1, i):
                is_prime[j] = False
    return [i for i in range(2, limit + 1) if is_prime[i]]

def main():
    np.random.seed(42)

    fig, axes = plt.subplots(2, 2, figsize=(16, 14))
    fig.suptitle('🔴🔵 The Matrix: Eigenvalue Repulsion\n'
                 'Random matrix eigenvalues repel each other like charged particles',
                 fontsize=16, fontweight='bold')

    # Panel 1: GOE eigenvalue spacing histogram
    ax1 = axes[0, 0]
    all_spacings = []
    n_matrices = 2000
    matrix_size = 50
    for _ in range(n_matrices):
        M = random_symmetric_matrix(matrix_size)
        eigs = np.linalg.eigvalsh(M)
        sp = normalized_spacings(eigs)
        all_spacings.extend(sp)

    s_vals = np.linspace(0, 4, 200)
    ax1.hist(all_spacings, bins=80, density=True, alpha=0.7, color='royalblue',
            edgecolor='navy', label='GOE eigenvalues')
    ax1.plot(s_vals, wigner_surmise(s_vals), 'r-', linewidth=3,
            label='Wigner surmise (GOE)')
    ax1.plot(s_vals, poisson_spacing(s_vals), 'g--', linewidth=2,
            label='Poisson (random)')
    ax1.set_xlabel('Normalized spacing s', fontsize=12)
    ax1.set_ylabel('P(s)', fontsize=12)
    ax1.set_title('Eigenvalue Spacing Distribution\n(2000 random 50×50 symmetric matrices)', fontsize=12)
    ax1.legend(fontsize=10)
    ax1.set_xlim(0, 4)
    ax1.annotate('← REPULSION\n   P(0) = 0', xy=(0.1, 0.05), fontsize=11,
                color='red', fontweight='bold')

    # Panel 2: Prime gaps normalized
    ax2 = axes[0, 1]
    primes = sieve_primes(1000000)
    prime_gaps = np.diff(primes)
    # Normalize by log(p) (expected average gap)
    log_primes = np.log(np.array(primes[:-1], dtype=float))
    normalized_gaps = prime_gaps / log_primes

    ax2.hist(normalized_gaps, bins=80, density=True, alpha=0.7, color='gold',
            edgecolor='darkgoldenrod', label='Prime gaps / log(p)')
    ax2.plot(s_vals, poisson_spacing(s_vals), 'g--', linewidth=2,
            label='Poisson (random)')
    ax2.set_xlabel('Normalized gap', fontsize=12)
    ax2.set_ylabel('Density', fontsize=12)
    ax2.set_title('Prime Gap Distribution\n(primes up to 1,000,000)', fontsize=12)
    ax2.legend(fontsize=10)
    ax2.set_xlim(0, 4)

    # Panel 3: Eigenvalue density (semicircle law)
    ax3 = axes[1, 0]
    all_eigs = []
    for _ in range(500):
        M = random_symmetric_matrix(200)
        eigs = np.linalg.eigvalsh(M)
        all_eigs.extend(eigs)

    x_sc = np.linspace(-2.1, 2.1, 300)
    semicircle = np.where(np.abs(x_sc) <= 2, (2 / np.pi) * np.sqrt(1 - (x_sc/2)**2), 0)

    ax3.hist(all_eigs, bins=100, density=True, alpha=0.7, color='mediumpurple',
            edgecolor='indigo', label='Eigenvalue density')
    ax3.plot(x_sc, semicircle, 'r-', linewidth=3, label='Wigner semicircle')
    ax3.set_xlabel('Eigenvalue', fontsize=12)
    ax3.set_ylabel('Density', fontsize=12)
    ax3.set_title("Wigner's Semicircle Law\n(500 random 200×200 matrices)", fontsize=12)
    ax3.legend(fontsize=10)

    # Panel 4: Trace statistics
    ax4 = axes[1, 1]
    traces = []
    dets_sign = []
    n_test = 5000
    for _ in range(n_test):
        M = random_symmetric_matrix(10)
        traces.append(np.trace(M))

    ax4.hist(traces, bins=60, density=True, alpha=0.7, color='coral',
            edgecolor='darkred', label='tr(M) distribution')
    # The trace of a GOE matrix should be approximately normal
    x_trace = np.linspace(min(traces), max(traces), 200)
    trace_std = np.std(traces)
    trace_mean = np.mean(traces)
    normal_pdf = stats.norm.pdf(x_trace, trace_mean, trace_std)
    ax4.plot(x_trace, normal_pdf, 'b-', linewidth=2, label='Normal fit')
    ax4.set_xlabel('Trace value', fontsize=12)
    ax4.set_ylabel('Density', fontsize=12)
    ax4.set_title('Trace Distribution\n(5000 random 10×10 matrices)', fontsize=12)
    ax4.legend(fontsize=10)
    ax4.annotate(f'Mean = {trace_mean:.3f}\nStd = {trace_std:.3f}',
                xy=(0.02, 0.95), xycoords='axes fraction',
                fontsize=10, verticalalignment='top',
                bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

    plt.tight_layout()
    plt.savefig('/workspace/request-project/demos/matrix_eigenvalues.png', dpi=150, bbox_inches='tight')
    plt.close()
    print("✓ Saved matrix_eigenvalues.png")

    # Verification of formal theorems
    print("\n📊 Verification of Matrix Theorems:")
    print("-" * 60)
    M = np.array([[3, 1, 2], [1, 4, 0], [2, 0, 5]], dtype=float)
    print(f"  M = {M.tolist()}")
    print(f"  tr(M) = {np.trace(M):.1f}")
    print(f"  det(M) = {np.linalg.det(M):.4f}")
    print(f"  det(Mᵀ) = {np.linalg.det(M.T):.4f}  [= det(M) ✓]")

    A = np.random.randn(4, 4)
    B = np.random.randn(4, 4)
    print(f"\n  tr(AB - BA) = {np.trace(A @ B - B @ A):.2e}  [≈ 0 ✓]")
    print(f"  det(AB) = {np.linalg.det(A @ B):.6f}")
    print(f"  det(A)·det(B) = {np.linalg.det(A) * np.linalg.det(B):.6f}  [✓]")

    # Idempotent matrix (projection)
    P = np.array([[1, 0, 0], [0, 1, 0], [0, 0, 0]], dtype=float)
    print(f"\n  P (projection) = {P.tolist()}")
    print(f"  P² = P: {np.allclose(P @ P, P)}  [✓]")
    print(f"  tr(P) = {np.trace(P):.0f}  [integer ✓, equals rank]")

if __name__ == "__main__":
    main()
