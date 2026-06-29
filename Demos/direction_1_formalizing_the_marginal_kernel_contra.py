#!/usr/bin/env python3
"""
Applications of the Marginal Kernel Contraction Theorem.

Demonstrates real-world applications in:
1. Machine learning: DPP-based diverse subset selection
2. Statistical physics: Fluctuation-dissipation analysis
3. Wireless communications: MIMO antenna correlation bounds
"""

import numpy as np
from numpy.linalg import inv, eigvalsh, eigh


def marginal_kernel(L: np.ndarray, beta: float = 1.0) -> np.ndarray:
    """Compute K = βL(I + βL)⁻¹."""
    n = L.shape[0]
    return beta * L @ inv(np.eye(n) + beta * L)


def contraction_operator(L: np.ndarray, beta: float = 1.0) -> np.ndarray:
    """Compute K - K² = Pᵀ(βL)P."""
    n = L.shape[0]
    P = inv(np.eye(n) + beta * L)
    return P.T @ (beta * L) @ P


# ─────────────────────────────────────────────────────────────────────
# Application 1: Diverse Subset Selection with Quality Guarantees
# ─────────────────────────────────────────────────────────────────────

def diverse_subset_selection(
    items: list,
    similarity: np.ndarray,
    quality: np.ndarray,
    beta: float = 1.0
) -> dict:
    """
    Select a diverse subset using DPP marginal probabilities.

    The contraction theorem guarantees that the pairwise correlations
    between selected items are bounded, ensuring diversity.

    Args:
        items: List of item labels
        similarity: n×n similarity matrix (PSD)
        quality: n-vector of item qualities
        beta: Temperature parameter controlling subset size

    Returns:
        Dictionary with selection probabilities and correlation bounds
    """
    n = len(items)
    # Build L-ensemble kernel: L_ij = q_i * s_ij * q_j
    L = np.outer(quality, quality) * similarity

    # Ensure PSD
    eigvals = eigvalsh(L)
    if eigvals.min() < -1e-10:
        L = L - eigvals.min() * np.eye(n)

    K = marginal_kernel(L, beta)

    # Inclusion probabilities
    probs = np.diag(K)

    # Correlation bounds from contraction theorem
    correlation_bounds = probs * (1 - probs)

    # Actual off-diagonal correlations
    actual_correlations = np.array([
        sum(K[i, j]**2 for j in range(n) if j != i)
        for i in range(n)
    ])

    return {
        'items': items,
        'inclusion_probs': probs,
        'correlation_bounds': correlation_bounds,
        'actual_correlations': actual_correlations,
        'slack': correlation_bounds - actual_correlations,
        'expected_subset_size': np.sum(probs),
    }


# ─────────────────────────────────────────────────────────────────────
# Application 2: Fluctuation-Dissipation in Particle Systems
# ─────────────────────────────────────────────────────────────────────

def fluctuation_dissipation_analysis(
    positions: np.ndarray,
    interaction_strength: float = 1.0,
    temperature: float = 1.0
) -> dict:
    """
    Analyze fluctuation-dissipation for a particle system modeled as a DPP.

    The contraction theorem proves that the response (susceptibility)
    is always bounded by the fluctuation (variance), establishing a
    rigorous version of the fluctuation-dissipation theorem.

    Args:
        positions: n×d array of particle positions
        interaction_strength: Coupling constant
        temperature: System temperature

    Returns:
        Analysis dictionary with fluctuation and dissipation data
    """
    n = positions.shape[0]

    # Build interaction kernel (Gaussian)
    dists = np.sqrt(np.sum((positions[:, None] - positions[None, :]) ** 2, axis=-1))
    L = interaction_strength * np.exp(-dists**2)

    beta = 1.0 / temperature
    K = marginal_kernel(L, beta)
    C = contraction_operator(L, beta)

    # Fluctuation: variance of occupation numbers
    fluctuation = np.diag(K) * (1 - np.diag(K))

    # Dissipation: response to external field
    # (diagonal of susceptibility = diagonal of K - K²)
    dissipation = np.diag(C)

    # The FDT says fluctuation = dissipation for equilibrium systems
    # The contraction theorem proves dissipation ≥ 0

    return {
        'n_particles': n,
        'temperature': temperature,
        'fluctuation': fluctuation,
        'dissipation': dissipation,
        'fdt_ratio': dissipation / (fluctuation + 1e-15),
        'total_fluctuation': np.sum(fluctuation),
        'total_dissipation': np.trace(C),
        'eigenvalues_C': eigvalsh(C),
    }


# ─────────────────────────────────────────────────────────────────────
# Application 3: MIMO Antenna Correlation Bounds
# ─────────────────────────────────────────────────────────────────────

def mimo_correlation_bounds(
    n_antennas: int,
    channel_matrix: np.ndarray,
    snr: float = 10.0
) -> dict:
    """
    Bound antenna correlations in a MIMO wireless system.

    The DPP marginal kernel arises naturally in MIMO capacity analysis.
    The contraction theorem provides bounds on inter-antenna interference.

    Args:
        n_antennas: Number of antennas
        channel_matrix: n×n channel covariance (PSD)
        snr: Signal-to-noise ratio

    Returns:
        Analysis dictionary with correlation bounds
    """
    L = channel_matrix
    beta = snr

    K = marginal_kernel(L, beta)

    # Per-antenna capacity contribution
    per_antenna_capacity = np.log2(1 + beta * eigvalsh(L))

    # Correlation bounds from contraction
    inclusion_probs = np.diag(K)
    max_interference_per_antenna = inclusion_probs * (1 - inclusion_probs)

    # Actual interference
    actual_interference = np.array([
        sum(K[i, j]**2 for j in range(n_antennas) if j != i)
        for i in range(n_antennas)
    ])

    return {
        'n_antennas': n_antennas,
        'snr_dB': 10 * np.log10(snr),
        'per_antenna_capacity': per_antenna_capacity,
        'total_capacity': np.sum(per_antenna_capacity),
        'inclusion_probs': inclusion_probs,
        'max_interference': max_interference_per_antenna,
        'actual_interference': actual_interference,
        'contraction_verified': all(
            actual_interference[i] <= max_interference_per_antenna[i] + 1e-10
            for i in range(n_antennas)
        ),
    }


if __name__ == "__main__":
    np.random.seed(42)

    print("=" * 70)
    print("  APPLICATION 1: Diverse Subset Selection")
    print("=" * 70)
    items = ["Article A", "Article B", "Article C", "Article D", "Article E"]
    similarity = np.array([
        [1.0, 0.8, 0.2, 0.1, 0.3],
        [0.8, 1.0, 0.3, 0.1, 0.2],
        [0.2, 0.3, 1.0, 0.7, 0.4],
        [0.1, 0.1, 0.7, 1.0, 0.5],
        [0.3, 0.2, 0.4, 0.5, 1.0],
    ])
    quality = np.array([0.9, 0.7, 0.8, 0.6, 0.5])

    result = diverse_subset_selection(items, similarity, quality, beta=2.0)
    for i, item in enumerate(items):
        print(f"  {item}: P(select)={result['inclusion_probs'][i]:.4f}, "
              f"corr bound={result['correlation_bounds'][i]:.4f}, "
              f"actual corr={result['actual_correlations'][i]:.4f}, "
              f"slack={result['slack'][i]:.4f}")
    print(f"  Expected subset size: {result['expected_subset_size']:.2f}")
    print()

    print("=" * 70)
    print("  APPLICATION 2: Fluctuation-Dissipation Analysis")
    print("=" * 70)
    positions = np.random.randn(8, 2) * 2
    result = fluctuation_dissipation_analysis(positions, temperature=0.5)
    print(f"  Particles: {result['n_particles']}")
    print(f"  Temperature: {result['temperature']}")
    print(f"  Total fluctuation: {result['total_fluctuation']:.6f}")
    print(f"  Total dissipation: {result['total_dissipation']:.6f}")
    print(f"  FDT ratios: {result['fdt_ratio']}")
    print(f"  Eigenvalues of K-K²: {result['eigenvalues_C']}")
    print()

    print("=" * 70)
    print("  APPLICATION 3: MIMO Antenna Correlation Bounds")
    print("=" * 70)
    n_ant = 4
    H = np.random.randn(n_ant, n_ant)
    channel = H @ H.T / n_ant
    result = mimo_correlation_bounds(n_ant, channel, snr=10.0)
    print(f"  Antennas: {result['n_antennas']}")
    print(f"  SNR: {result['snr_dB']:.1f} dB")
    print(f"  Total capacity: {result['total_capacity']:.2f} bits/s/Hz")
    print(f"  Contraction verified: {result['contraction_verified']}")
    for i in range(n_ant):
        print(f"    Antenna {i}: interference={result['actual_interference'][i]:.6f} "
              f"≤ bound={result['max_interference'][i]:.6f}")


#!/usr/bin/env python3
"""
Demonstration of the Marginal Kernel Contraction Theorem for DPPs.

Shows that for any symmetric PSD matrix L and β ≥ 0, the marginal kernel
K = βL(I + βL)⁻¹ satisfies K - K² ≽ 0 (positive semidefinite).

This implies:
  ∑_{j≠i} K_{ij}² ≤ K_{ii}(1 - K_{ii})  for all i

The key algebraic identity: K - K² = P^T (βL) P where P = (I + βL)⁻¹.
"""

import numpy as np
from numpy.linalg import inv, eigvalsh

np.random.seed(42)


def random_psd_matrix(n: int) -> np.ndarray:
    """Generate a random n×n symmetric PSD matrix."""
    A = np.random.randn(n, n)
    return A @ A.T


def marginal_kernel(L: np.ndarray, beta: float) -> np.ndarray:
    """Compute K = βL(I + βL)⁻¹."""
    n = L.shape[0]
    I = np.eye(n)
    return beta * L @ inv(I + beta * L)


def verify_contraction(L: np.ndarray, beta: float) -> dict:
    """Verify the contraction inequality for given L and β."""
    n = L.shape[0]
    K = marginal_kernel(L, beta)
    diff = K - K @ K

    # Check PSD: all eigenvalues ≥ 0
    eigenvalues = eigvalsh(diff)
    min_eigenvalue = eigenvalues.min()
    is_psd = min_eigenvalue >= -1e-10

    # Check diagonal inequality
    diagonal_ok = True
    for i in range(n):
        off_diag_sum = sum(K[i, j]**2 for j in range(n) if j != i)
        bound = K[i, i] * (1 - K[i, i])
        if off_diag_sum > bound + 1e-10:
            diagonal_ok = False

    # Check congruence identity: K - K² = P^T (βL) P
    I = np.eye(n)
    P = inv(I + beta * L)
    congruence = P.T @ (beta * L) @ P
    identity_error = np.max(np.abs(diff - congruence))

    return {
        'n': n,
        'beta': beta,
        'min_eigenvalue': min_eigenvalue,
        'is_psd': is_psd,
        'diagonal_ok': diagonal_ok,
        'identity_error': identity_error,
        'trace_K_minus_K2': np.trace(diff),
        'operator_norm_K_minus_K2': np.max(np.abs(eigenvalues)),
    }


def main():
    print("=" * 70)
    print("  MARGINAL KERNEL CONTRACTION THEOREM — DEMONSTRATION")
    print("=" * 70)
    print()

    # Demo 1: Small examples
    print("━" * 70)
    print("Demo 1: Small matrix examples")
    print("━" * 70)
    for n in [2, 3, 5, 10]:
        for beta in [0.1, 1.0, 5.0, 100.0]:
            L = random_psd_matrix(n)
            result = verify_contraction(L, beta)
            status = "✓" if result['is_psd'] and result['diagonal_ok'] else "✗"
            print(f"  {status} n={n:2d}, β={beta:6.1f}: "
                  f"min λ(K-K²)={result['min_eigenvalue']:+.2e}, "
                  f"‖K-K²‖={result['operator_norm_K_minus_K2']:.4f}, "
                  f"identity err={result['identity_error']:.2e}")
    print()

    # Demo 2: Large-scale verification (the "10,000 random matrices" test)
    print("━" * 70)
    print("Demo 2: Large-scale verification (10,000 random PSD matrices)")
    print("━" * 70)
    n_tests = 10000
    n_size = 5
    failures_psd = 0
    failures_diag = 0
    min_eig_overall = float('inf')
    max_norm_overall = 0.0

    for trial in range(n_tests):
        L = random_psd_matrix(n_size)
        beta = np.random.exponential(1.0)
        result = verify_contraction(L, beta)
        if not result['is_psd']:
            failures_psd += 1
        if not result['diagonal_ok']:
            failures_diag += 1
        min_eig_overall = min(min_eig_overall, result['min_eigenvalue'])
        max_norm_overall = max(max_norm_overall, result['operator_norm_K_minus_K2'])

    print(f"  Tests run:      {n_tests}")
    print(f"  Matrix size:    {n_size}×{n_size}")
    print(f"  PSD failures:   {failures_psd}")
    print(f"  Diag failures:  {failures_diag}")
    print(f"  Min eigenvalue: {min_eig_overall:.2e}")
    print(f"  Max ‖K-K²‖:    {max_norm_overall:.6f}")
    print(f"  Bound 1/4:      {0.25:.6f}")
    print(f"  Conjecture ‖K-K²‖ ≤ 1/4 holds: {'✓ YES' if max_norm_overall <= 0.25 + 1e-10 else '✗ NO'}")
    print()

    # Demo 3: The congruence identity verification
    print("━" * 70)
    print("Demo 3: Congruence identity K - K² = Pᵀ(βL)P")
    print("━" * 70)
    L = random_psd_matrix(4)
    beta = 2.0
    K = marginal_kernel(L, beta)
    I = np.eye(4)
    P = inv(I + beta * L)
    diff = K - K @ K
    congruence = P.T @ (beta * L) @ P

    print(f"  L (4×4 PSD matrix):")
    for row in L:
        print(f"    [{', '.join(f'{x:8.4f}' for x in row)}]")
    print(f"\n  β = {beta}")
    print(f"\n  K - K² =")
    for row in diff:
        print(f"    [{', '.join(f'{x:8.4f}' for x in row)}]")
    print(f"\n  Pᵀ(βL)P =")
    for row in congruence:
        print(f"    [{', '.join(f'{x:8.4f}' for x in row)}]")
    print(f"\n  Max absolute difference: {np.max(np.abs(diff - congruence)):.2e}")
    print(f"  Eigenvalues of K - K²: {eigvalsh(diff)}")
    print()

    # Demo 4: Bernoulli variance bound
    print("━" * 70)
    print("Demo 4: Correlation capacity bound (Bernoulli variance ≤ 1/4)")
    print("━" * 70)
    L = random_psd_matrix(6)
    beta = 1.0
    K = marginal_kernel(L, beta)
    for i in range(6):
        off_diag = sum(K[i, j]**2 for j in range(6) if j != i)
        variance = K[i, i] * (1 - K[i, i])
        print(f"  Site {i}: ∑_{{j≠i}} K_ij² = {off_diag:.6f} ≤ "
              f"K_ii(1-K_ii) = {variance:.6f} ≤ 1/4 = {0.25:.6f}"
              f" {'✓' if off_diag <= variance + 1e-10 else '✗'}")


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Visualization: Contraction Operator Heatmap

Visualizes the matrices K, K², and K - K² side by side for a DPP
marginal kernel, showing that K - K² is positive semidefinite
with nonneg entries on the diagonal.
"""
import numpy as np
import matplotlib.pyplot as plt
from numpy.linalg import inv, eigvalsh

np.random.seed(42)

# Generate a random 8x8 PSD matrix
n = 8
A = np.random.randn(n, n)
L = A @ A.T
beta = 1.5

# Compute marginal kernel and contraction
I = np.eye(n)
K = beta * L @ inv(I + beta * L)
K_sq = K @ K
C = K - K_sq

# Create figure
fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# K heatmap
im0 = axes[0].imshow(K, cmap='RdBu_r', vmin=-0.5, vmax=0.5, aspect='equal')
axes[0].set_title(r'Marginal Kernel $K = \beta L(I + \beta L)^{-1}$', fontsize=12)
axes[0].set_xlabel('Column index')
axes[0].set_ylabel('Row index')
plt.colorbar(im0, ax=axes[0], shrink=0.8)

# K² heatmap
im1 = axes[1].imshow(K_sq, cmap='RdBu_r', vmin=-0.5, vmax=0.5, aspect='equal')
axes[1].set_title(r'$K^2$', fontsize=12)
axes[1].set_xlabel('Column index')
plt.colorbar(im1, ax=axes[1], shrink=0.8)

# K - K² heatmap (should be PSD)
im2 = axes[2].imshow(C, cmap='YlOrRd', vmin=0, aspect='equal')
axes[2].set_title(r'Contraction $K - K^2 = P^\top(\beta L)P \succeq 0$', fontsize=12)
axes[2].set_xlabel('Column index')
plt.colorbar(im2, ax=axes[2], shrink=0.8)

# Annotate eigenvalues
eigs = eigvalsh(C)
axes[2].text(0.5, -0.15, f'Eigenvalues: [{", ".join(f"{e:.3f}" for e in eigs)}]',
             transform=axes[2].transAxes, ha='center', fontsize=8, style='italic')

fig.suptitle(f'Marginal Kernel Contraction Theorem (n={n}, β={beta})',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('contraction_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()


#!/usr/bin/env python3
"""
Visualization: Correlation Capacity Surface

Shows the correlation capacity K_ii(1-K_ii) as a function of two
key parameters: inverse temperature β and matrix eigenvalue λ.
The contraction theorem ensures the actual off-diagonal correlation
always lies below this surface.
"""
import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

# Parameter ranges
betas = np.linspace(0.01, 10, 100)
lambdas = np.linspace(0.01, 5, 100)
B, LAM = np.meshgrid(betas, lambdas)

# Eigenvalue of K as function of β and λ: κ = βλ/(1+βλ)
kappa = B * LAM / (1 + B * LAM)

# Correlation capacity: κ(1-κ) = βλ/(1+βλ)²
capacity = kappa * (1 - kappa)

fig = plt.figure(figsize=(14, 6))

# 3D surface
ax1 = fig.add_subplot(121, projection='3d')
surf = ax1.plot_surface(B, LAM, capacity, cmap='viridis', alpha=0.8,
                        edgecolor='none')
ax1.set_xlabel(r'$\beta$ (inverse temperature)', fontsize=10)
ax1.set_ylabel(r'$\lambda$ (eigenvalue of $L$)', fontsize=10)
ax1.set_zlabel(r'$\kappa(1-\kappa)$', fontsize=10)
ax1.set_title('Correlation Capacity Surface\n'
              r'$\kappa(\beta, \lambda) = \frac{\beta\lambda}{(1+\beta\lambda)^2}$',
              fontsize=12)
ax1.view_init(elev=25, azim=-60)
fig.colorbar(surf, ax=ax1, shrink=0.5, aspect=10, pad=0.1)

# Contour plot
ax2 = fig.add_subplot(122)
levels = np.linspace(0, 0.25, 26)
contour = ax2.contourf(B, LAM, capacity, levels=levels, cmap='viridis')
ax2.contour(B, LAM, capacity, levels=[0.25], colors='red', linewidths=2,
            linestyles='--')

# Mark the maximum
# Maximum of βλ/(1+βλ)² over λ for fixed β: at λ = 1/β, giving 1/4
opt_betas = np.linspace(0.5, 10, 50)
opt_lambdas = 1.0 / opt_betas
ax2.plot(opt_betas, opt_lambdas, 'r-', linewidth=2,
         label=r'Optimal: $\lambda^* = 1/\beta$ (capacity $= 1/4$)')
ax2.scatter([1.0], [1.0], c='red', s=100, zorder=5,
            label=r'$(\beta, \lambda) = (1, 1)$: capacity $= 1/4$')

ax2.set_xlabel(r'$\beta$ (inverse temperature)', fontsize=11)
ax2.set_ylabel(r'$\lambda$ (eigenvalue of $L$)', fontsize=11)
ax2.set_title('Correlation Capacity Contours', fontsize=12)
ax2.legend(fontsize=9, loc='upper right')
fig.colorbar(contour, ax=ax2, shrink=0.8)

fig.suptitle('The 1/4 Bound: Maximum Correlation Capacity in DPPs',
             fontsize=14, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('correlation_capacity.png', dpi=150, bbox_inches='tight')
plt.close()


#!/usr/bin/env python3
"""
Visualization: Eigenvalue Mapping Under Contraction

Shows how the eigenvalue map f(x) = x(1-x) transforms the spectrum
of K into the spectrum of K - K². The contraction theorem guarantees
all eigenvalues remain nonneg since K's eigenvalues are in [0,1].
"""
import numpy as np
import matplotlib.pyplot as plt

# The contraction function f(x) = x(1-x)
x = np.linspace(-0.2, 1.2, 500)
y = x * (1 - x)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: The eigenvalue map
ax = axes[0]
ax.fill_between(x[(x >= 0) & (x <= 1)], 0, y[(x >= 0) & (x <= 1)],
                alpha=0.2, color='steelblue', label='PSD region')
ax.plot(x, y, 'b-', linewidth=2, label=r'$f(\lambda) = \lambda(1-\lambda)$')
ax.axhline(y=0, color='k', linewidth=0.5)
ax.axvline(x=0, color='k', linewidth=0.5)
ax.axhline(y=0.25, color='red', linewidth=1, linestyle='--',
           label=r'Maximum $f = 1/4$ at $\lambda = 1/2$')
ax.axvline(x=0.5, color='red', linewidth=0.5, linestyle=':')

# Plot example eigenvalues
np.random.seed(42)
n = 8
A = np.random.randn(n, n)
L = A @ A.T
beta = 1.0
eigs_L = np.linalg.eigvalsh(L)
eigs_K = beta * eigs_L / (1 + beta * eigs_L)
eigs_C = eigs_K * (1 - eigs_K)

ax.scatter(eigs_K, eigs_C, c='red', s=80, zorder=5, edgecolors='darkred',
           label=f'Eigenvalues (n={n})')
for ek, ec in zip(eigs_K, eigs_C):
    ax.plot([ek, ek], [0, ec], 'r:', linewidth=0.8, alpha=0.5)

ax.set_xlabel(r'Eigenvalue of $K$', fontsize=12)
ax.set_ylabel(r'Eigenvalue of $K - K^2$', fontsize=12)
ax.set_title('Spectral Contraction Map', fontsize=14)
ax.legend(fontsize=10, loc='upper left')
ax.set_xlim(-0.1, 1.1)
ax.set_ylim(-0.05, 0.35)
ax.grid(True, alpha=0.3)

# Right panel: Histogram of K - K² eigenvalues over many random matrices
ax = axes[1]
all_eigs = []
for trial in range(2000):
    n_trial = np.random.randint(3, 12)
    A_trial = np.random.randn(n_trial, n_trial)
    L_trial = A_trial @ A_trial.T
    beta_trial = np.random.exponential(2.0)
    eigs_L_trial = np.linalg.eigvalsh(L_trial)
    eigs_K_trial = beta_trial * eigs_L_trial / (1 + beta_trial * eigs_L_trial)
    eigs_C_trial = eigs_K_trial * (1 - eigs_K_trial)
    all_eigs.extend(eigs_C_trial)

all_eigs = np.array(all_eigs)
ax.hist(all_eigs, bins=80, density=True, color='steelblue', alpha=0.7,
        edgecolor='navy', linewidth=0.3)
ax.axvline(x=0, color='green', linewidth=2, linestyle='--',
           label=r'$\lambda = 0$ (PSD boundary)')
ax.axvline(x=0.25, color='red', linewidth=2, linestyle='--',
           label=r'$\lambda = 1/4$ (conjectured max)')

ax.set_xlabel(r'Eigenvalue of $K - K^2$', fontsize=12)
ax.set_ylabel('Density', fontsize=12)
ax.set_title('Distribution of Contraction Eigenvalues\n(2000 random PSD matrices)',
             fontsize=13)
ax.legend(fontsize=10)
ax.set_xlim(-0.02, 0.30)
ax.grid(True, alpha=0.3)

# Add annotation
min_eig = all_eigs.min()
ax.annotate(f'Min eigenvalue: {min_eig:.2e}\n(always ≥ 0, as proved)',
            xy=(min_eig, 0), xytext=(0.08, 8),
            fontsize=9, ha='center',
            arrowprops=dict(arrowstyle='->', color='darkgreen'),
            bbox=dict(boxstyle='round,pad=0.3', facecolor='lightyellow'))

fig.suptitle('The Contraction Theorem: Eigenvalues of K − K²',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('eigenvalue_map.png', dpi=150, bbox_inches='tight')
plt.close()
