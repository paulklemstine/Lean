"""
Certified Fermion Sampling — Applications

Real-world applications of the certified noise bounds:
1. Quantum chemistry: electron correlation certification
2. Materials science: band structure noise tolerance
3. Quantum advantage verification: when can we trust noisy hardware?
"""

import numpy as np
from typing import List, Dict


def depolarizing_channel(K: np.ndarray, eps: float) -> np.ndarray:
    n = K.shape[0]
    return (1 - eps) * K + (eps / 2) * np.eye(n)


def iterated_depolarizing(K: np.ndarray, eps: float, d: int) -> np.ndarray:
    contraction = (1 - eps) ** d
    shift = (1 - contraction) / 2
    return contraction * K + shift * np.eye(n)


def certified_neg_dep_bound(d: int, eps: float) -> float:
    eta = 3 * d * eps / 2
    return 2 * (2 * eta + eta ** 2)


# ============================================================
# Application 1: Quantum Chemistry — Electron Correlation
# ============================================================

def hydrogen_chain_correlation(n_sites: int, bond_length: float = 1.4) -> np.ndarray:
    """
    Simplified correlation matrix for a hydrogen chain at half-filling.
    Models the tight-binding Hamiltonian with nearest-neighbor hopping.

    K_ij ∝ sin(π|i-j|/(n+1)) / |i-j| for the ground state.
    """
    K = np.zeros((n_sites, n_sites))
    for i in range(n_sites):
        for j in range(n_sites):
            if i == j:
                K[i, j] = 0.5  # Half-filling
            else:
                dist = abs(i - j)
                K[i, j] = (-1)**(dist + 1) * np.sin(np.pi * 0.5) / (np.pi * dist)
    # Ensure symmetry and eigenvalues in [0, 1]
    K = (K + K.T) / 2
    eigenvalues = np.linalg.eigvalsh(K)
    if np.min(eigenvalues) < 0 or np.max(eigenvalues) > 1:
        K = K - np.min(eigenvalues) * np.eye(n_sites)
        K = K / np.max(np.linalg.eigvalsh(K))
        K = K * 0.95 + 0.025 * np.eye(n_sites)
    return K


def certify_electron_correlations(n_sites: int, eps: float, d: int) -> Dict:
    """
    Certify that noisy quantum hardware produces reliable electron correlations.

    This is the key application: given a quantum circuit that prepares a
    molecular ground state, determine whether the noise level allows
    certified correlation estimates.
    """
    K = hydrogen_chain_correlation(n_sites)
    K_noisy = iterated_depolarizing(K, eps, d)
    bound = certified_neg_dep_bound(d, eps)

    # Check pair correlations
    n_certified = 0
    n_total = 0
    results = []
    for i in range(n_sites):
        for j in range(i + 1, n_sites):
            P_ideal = K[i, i] * K[j, j] - K[i, j] ** 2
            P_noisy = K_noisy[i, i] * K_noisy[j, j] - K_noisy[i, j] ** 2
            certified = P_ideal - bound > 0
            n_total += 1
            if certified:
                n_certified += 1
            results.append({
                'sites': (i, j),
                'P_ideal': P_ideal,
                'P_noisy': P_noisy,
                'certified': certified
            })

    return {
        'n_sites': n_sites,
        'eps': eps,
        'd': d,
        'bound': bound,
        'n_certified': n_certified,
        'n_total': n_total,
        'fraction_certified': n_certified / n_total if n_total > 0 else 0,
        'details': results
    }


# ============================================================
# Application 2: Quantum Advantage Verification
# ============================================================

def quantum_advantage_threshold(n: int, target_fidelity: float = 0.99) -> Dict:
    """
    Determine the noise threshold below which noisy fermion sampling
    maintains quantum advantage.

    For quantum advantage, we need the output distribution to be
    within total variation distance δ of the ideal distribution.
    Our certified bounds translate this to noise requirements.
    """
    K = hydrogen_chain_correlation(n)

    # Find minimum negative dependence gap
    min_P = float('inf')
    for i in range(n):
        for j in range(i + 1, n):
            P = K[i, i] * K[j, j] - K[i, j] ** 2
            if P < min_P:
                min_P = P

    # For certified positive neg dep, need 2(2η + η²) < min_P
    # where η = 3dε/2
    # Solving: η < -1 + sqrt(1 + min_P/2)
    max_eta = -1 + np.sqrt(1 + min_P / 2)

    results = {}
    for d in [10, 50, 100, 200, 500]:
        max_eps = 2 * max_eta / (3 * d)
        results[d] = {
            'max_eps': max_eps,
            'gate_fidelity': 1 - max_eps,
            'total_noise': d * max_eps
        }

    return {
        'n': n,
        'min_neg_dep_gap': min_P,
        'max_eta': max_eta,
        'depth_thresholds': results
    }


# ============================================================
# Application 3: Materials Science — Band Structure
# ============================================================

def band_structure_correlation(n_k_points: int) -> np.ndarray:
    """
    Correlation matrix from a simple 1D band structure.
    Models a metal at half-filling with n_k_points in the Brillouin zone.
    """
    K = np.zeros((n_k_points, n_k_points))
    for i in range(n_k_points):
        for j in range(n_k_points):
            k_i = 2 * np.pi * i / n_k_points
            k_j = 2 * np.pi * j / n_k_points
            # Fourier transform of Fermi function at half-filling
            if i == j:
                K[i, j] = 0.5
            else:
                K[i, j] = 0.3 * np.sin(k_i - k_j) / (n_k_points * np.sin(np.pi * (i - j) / n_k_points))
    K = (K + K.T) / 2
    # Normalize eigenvalues to [0, 1]
    eigs = np.linalg.eigvalsh(K)
    if np.min(eigs) < 0:
        K = K - (np.min(eigs) - 0.01) * np.eye(n_k_points)
    eigs = np.linalg.eigvalsh(K)
    if np.max(eigs) > 1:
        K = K / (np.max(eigs) + 0.01)
    return K


if __name__ == "__main__":
    print("=" * 70)
    print("APPLICATION 1: Quantum Chemistry — Electron Correlation Certification")
    print("=" * 70)

    for n in [4, 8, 16]:
        for eps in [0.001, 0.01]:
            result = certify_electron_correlations(n, eps, d=50)
            print(f"  n={n:>2}, ε={eps:.3f}, d=50: "
                  f"{result['n_certified']}/{result['n_total']} pairs certified "
                  f"({result['fraction_certified']:.1%}), "
                  f"bound={result['bound']:.6f}")

    print()
    print("=" * 70)
    print("APPLICATION 2: Quantum Advantage Threshold")
    print("=" * 70)

    for n in [4, 8, 16]:
        result = quantum_advantage_threshold(n)
        print(f"\n  n={n}: min neg dep gap = {result['min_neg_dep_gap']:.6f}")
        for d, info in result['depth_thresholds'].items():
            print(f"    d={d:>4}: max ε = {info['max_eps']:.6f}, "
                  f"gate fidelity ≥ {info['gate_fidelity']:.6f}")

    print()
    print("=" * 70)
    print("APPLICATION 3: Materials Science — Band Structure Noise Tolerance")
    print("=" * 70)

    for n in [4, 8]:
        K_band = band_structure_correlation(n)
        K_noisy = iterated_depolarizing(K_band, 0.01, 100)
        max_pert = np.max(np.abs(K_band - K_noisy))
        bound = 3 * 100 * 0.01 / 2
        print(f"  n={n}: actual perturbation = {max_pert:.6f}, "
              f"certified bound = {bound:.6f}")

    print("\nAll applications completed successfully!")


"""
Certified Fermion Sampling in Noisy Quantum Circuits — Demo

Demonstrates the key theorems with concrete numerical examples:
1. Depolarizing channel contraction
2. Error accumulation over circuit depth
3. Certified negative dependence defect bounds
4. Noise threshold for certified sampling
"""

import numpy as np
from typing import Tuple

def depolarizing_channel(K: np.ndarray, eps: float) -> np.ndarray:
    """Apply depolarizing channel: Φ_ε(K) = (1-ε)K + (ε/2)I"""
    n = K.shape[0]
    return (1 - eps) * K + (eps / 2) * np.eye(n)

def iterated_depolarizing(K: np.ndarray, eps: float, d: int) -> np.ndarray:
    """Apply depolarizing channel d times."""
    result = K.copy()
    for _ in range(d):
        result = depolarizing_channel(result, eps)
    return result

def pairwise_neg_dep_value(K: np.ndarray, i: int, j: int) -> float:
    """Compute P_K(i,j) = K_ii * K_jj - K_ij * K_ji."""
    return K[i, i] * K[j, j] - K[i, j] * K[j, i]

def max_entry_perturbation(K: np.ndarray, K_prime: np.ndarray) -> float:
    """Compute max |K_ij - K'_ij|."""
    return np.max(np.abs(K - K_prime))

def certified_bound(d: int, eps: float) -> float:
    """Certified neg dep defect bound: 2*(2*(3dε/2) + (3dε/2)²)"""
    eta = 3 * d * eps / 2
    return 2 * (2 * eta + eta**2)

def bernoulli_bound(d: int, eps: float) -> float:
    """Bernoulli bound: (1-(1-ε)^d)/2 ≤ dε/2"""
    return d * eps / 2

def actual_perturbation(d: int, eps: float) -> float:
    """Actual perturbation for identity: (1-(1-ε)^d)/2"""
    return (1 - (1 - eps)**d) / 2


print("=" * 70)
print("CERTIFIED FERMION SAMPLING IN NOISY QUANTUM CIRCUITS")
print("=" * 70)

# Demo 1: Depolarizing channel contraction
print("\n--- Demo 1: Depolarizing Channel Contraction ---")
n = 4
K = np.array([[0.8, 0.3, -0.1, 0.2],
              [0.3, 0.6,  0.2, -0.1],
              [-0.1, 0.2, 0.7, 0.1],
              [0.2, -0.1, 0.1, 0.5]])
L = np.array([[0.7, 0.2, 0.0, 0.1],
              [0.2, 0.5, 0.1, 0.0],
              [0.0, 0.1, 0.6, 0.2],
              [0.1, 0.0, 0.2, 0.4]])

eps = 0.1
PhiK = depolarizing_channel(K, eps)
PhiL = depolarizing_channel(L, eps)

diff_before = max_entry_perturbation(K, L)
diff_after = max_entry_perturbation(PhiK, PhiL)
contraction_ratio = diff_after / diff_before if diff_before > 0 else 0

print(f"  n = {n}, ε = {eps}")
print(f"  ‖K - L‖_max = {diff_before:.6f}")
print(f"  ‖Φ(K) - Φ(L)‖_max = {diff_after:.6f}")
print(f"  Contraction ratio = {contraction_ratio:.6f}")
print(f"  Theoretical bound (1-ε) = {1-eps:.6f}")
print(f"  ✓ Contraction verified: {diff_after <= (1-eps) * diff_before + 1e-15}")

# Demo 2: Error accumulation
print("\n--- Demo 2: Error Accumulation Over Circuit Depth ---")
eps_values = [0.001, 0.01, 0.05, 0.1]
depths = [1, 5, 10, 20, 50, 100]
K_test = np.array([[1, 0, 0, 0],
                    [0, 0.8, 0.3, 0],
                    [0, 0.3, 0.6, 0.1],
                    [0, 0, 0.1, 0.4]])

print(f"  {'ε':>8} {'d':>5} {'actual':>12} {'bound 3dε/2':>12} {'Bernoulli':>12} {'verified':>10}")
print(f"  {'-'*8} {'-'*5} {'-'*12} {'-'*12} {'-'*12} {'-'*10}")
for eps in [0.01, 0.05, 0.1]:
    for d in [5, 10, 20, 50]:
        K_noisy = iterated_depolarizing(K_test, eps, d)
        actual = max_entry_perturbation(K_test, K_noisy)
        bound = 3 * d * eps / 2
        bern = actual_perturbation(d, eps)
        ok = actual <= bound + 1e-12
        print(f"  {eps:>8.3f} {d:>5} {actual:>12.6f} {bound:>12.6f} {bern:>12.6f} {'✓' if ok else '✗':>10}")

# Demo 3: Certified negative dependence defect
print("\n--- Demo 3: Certified Negative Dependence Defect ---")
K_ideal = np.array([[0.7, 0.2, -0.1, 0.05],
                     [0.2, 0.6,  0.1, -0.05],
                     [-0.1, 0.1, 0.5, 0.08],
                     [0.05, -0.05, 0.08, 0.4]])

print(f"  {'ε':>8} {'d':>5} {'actual defect':>15} {'certified bound':>16} {'verified':>10}")
print(f"  {'-'*8} {'-'*5} {'-'*15} {'-'*16} {'-'*10}")

for eps in [0.01, 0.05, 0.1]:
    for d in [5, 10, 20]:
        K_noisy = iterated_depolarizing(K_ideal, eps, d)
        # Compute actual max neg dep defect
        max_defect = 0.0
        for i in range(n):
            for j in range(n):
                defect = abs(pairwise_neg_dep_value(K_ideal, i, j) -
                            pairwise_neg_dep_value(K_noisy, i, j))
                max_defect = max(max_defect, defect)
        bound = certified_bound(d, eps)
        ok = max_defect <= bound + 1e-12
        print(f"  {eps:>8.3f} {d:>5} {max_defect:>15.8f} {bound:>16.8f} {'✓' if ok else '✗':>10}")

# Demo 4: Noise threshold
print("\n--- Demo 4: Noise Threshold for Certified Sampling ---")
print("  For pair (0,1) of K_ideal:")
P_ideal = pairwise_neg_dep_value(K_ideal, 0, 1)
print(f"  P_K(0,1) = K_00*K_11 - K_01*K_10 = {P_ideal:.6f}")

for eps in [0.001, 0.005, 0.01, 0.05]:
    for d in [10, 50, 100]:
        K_noisy = iterated_depolarizing(K_ideal, eps, d)
        P_noisy = pairwise_neg_dep_value(K_noisy, 0, 1)
        bound = certified_bound(d, eps)
        certified_positive = P_ideal - bound > 0
        actually_positive = P_noisy > 0
        print(f"  ε={eps:.3f}, d={d:>3}: P_noisy={P_noisy:.6f}, "
              f"bound={bound:.6f}, certified_pos={certified_positive}, "
              f"actual_pos={actually_positive}")

# Demo 5: Bernoulli's inequality verification
print("\n--- Demo 5: Bernoulli's Inequality Verification ---")
print(f"  {'ε':>8} {'d':>5} {'(1-ε)^d':>12} {'1-dε':>12} {'gap':>12}")
print(f"  {'-'*8} {'-'*5} {'-'*12} {'-'*12} {'-'*12}")
for eps in [0.01, 0.05, 0.1]:
    for d in [5, 10, 20, 50]:
        actual = (1 - eps)**d
        linear = 1 - d * eps
        gap = actual - linear
        print(f"  {eps:>8.3f} {d:>5} {actual:>12.8f} {linear:>12.8f} {gap:>12.8f}")

# Demo 6: Tightness conjecture test
print("\n--- Demo 6: Tightness Conjecture Test ---")
print("  Testing: dε/4 ≤ (1-(1-ε)^d)/2 ≤ dε/2 for dε ≤ 1/2")
print(f"  {'ε':>8} {'d':>5} {'dε':>8} {'lower':>12} {'actual':>12} {'upper':>12} {'ok':>5}")
print(f"  {'-'*8} {'-'*5} {'-'*8} {'-'*12} {'-'*12} {'-'*12} {'-'*5}")
for eps in [0.001, 0.005, 0.01, 0.05]:
    for d in [10, 20, 50, 100]:
        if d * eps <= 0.5:
            actual = (1 - (1 - eps)**d) / 2
            lower = d * eps / 4
            upper = d * eps / 2
            ok = lower <= actual + 1e-15 and actual <= upper + 1e-15
            print(f"  {eps:>8.4f} {d:>5} {d*eps:>8.4f} {lower:>12.8f} {actual:>12.8f} {upper:>12.8f} {'✓' if ok else '✗':>5}")

print("\n" + "=" * 70)
print("All demos completed successfully!")
print("=" * 70)


"""
Visualization: Negative Dependence Defect Heatmap

Shows the pairwise negative dependence values for ideal and noisy
fermionic states as heatmaps, along with the certified defect bound.
Illustrates how noise degrades the DPP quality certificate.
"""

import numpy as np
import matplotlib.pyplot as plt

def iterated_depolarizing(K, eps, d):
    n = K.shape[0]
    c = (1 - eps) ** d
    return c * K + (1 - c) / 2 * np.eye(n)

def neg_dep_matrix(K):
    n = K.shape[0]
    P = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            P[i, j] = K[i, i] * K[j, j] - K[i, j] * K[j, i]
    return P

# Correlation matrix (8x8 for better visualization)
n = 8
np.random.seed(42)
# Create a valid correlation matrix
A = np.random.randn(n, n) * 0.3
K = A @ A.T / n
K = K / (np.max(np.linalg.eigvalsh(K)) + 0.1)
K = (K + K.T) / 2

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

configs = [
    (0.0, 0, 'Ideal (no noise)'),
    (0.01, 20, 'ε=0.01, d=20'),
    (0.01, 100, 'ε=0.01, d=100'),
    (0.05, 10, 'ε=0.05, d=10'),
    (0.05, 50, 'ε=0.05, d=50'),
    (0.1, 20, 'ε=0.1, d=20'),
]

vmin = -0.05
vmax = 0.3

for idx, (eps, d, title) in enumerate(configs):
    ax = axes[idx // 3, idx % 3]
    K_noisy = iterated_depolarizing(K, eps, d) if d > 0 else K
    P = neg_dep_matrix(K_noisy)

    im = ax.imshow(P, cmap='RdYlGn', vmin=vmin, vmax=vmax,
                    interpolation='nearest')
    ax.set_title(title, fontsize=11, fontweight='bold')

    # Add text annotations
    for i in range(n):
        for j in range(n):
            color = 'white' if abs(P[i, j]) > 0.15 else 'black'
            ax.text(j, i, f'{P[i,j]:.2f}', ha='center', va='center',
                   fontsize=6, color=color)

    ax.set_xticks(range(n))
    ax.set_yticks(range(n))
    ax.set_xlabel('Mode j', fontsize=9)
    ax.set_ylabel('Mode i', fontsize=9)

    # Show certified bound
    if d > 0:
        eta = 3 * d * eps / 2
        bound = 2 * (2 * eta + eta**2)
        ax.text(0.02, 0.98, f'Cert. bound: {bound:.4f}',
               transform=ax.transAxes, fontsize=8,
               verticalalignment='top',
               bbox=dict(boxstyle='round', facecolor='wheat', alpha=0.8))

fig.colorbar(im, ax=axes, shrink=0.8, label='Pair Inclusion P(i,j)')
plt.suptitle('Pairwise Negative Dependence Values\n'
             'P(i,j) = K_ii·K_jj - K_ij·K_ji under Depolarizing Noise',
             fontsize=14, fontweight='bold')
plt.tight_layout(rect=[0, 0, 0.92, 0.93])
plt.savefig('viz_neg_dep_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_neg_dep_heatmap.png")


"""
Visualization: Noise Accumulation in Fermionic Quantum Circuits

Shows how the correlation matrix perturbation grows with circuit depth,
comparing the actual perturbation with the certified bound (3dε/2)
and the Bernoulli approximation (dε/2). Demonstrates that our
certified bound correctly envelopes all empirical observations.
"""

import numpy as np
import matplotlib.pyplot as plt

# Parameters
n = 4
eps_values = [0.01, 0.05, 0.1]
depths = np.arange(0, 101)

# Test correlation matrices
K_identity = np.eye(n)
K_mixed = np.array([[0.7, 0.2, -0.1, 0.05],
                     [0.2, 0.6,  0.1, -0.05],
                     [-0.1, 0.1, 0.5, 0.08],
                     [0.05, -0.05, 0.08, 0.4]])
K_extreme = np.array([[ 1.0,  0.5, -0.3,  0.2],
                       [ 0.5,  0.8,  0.4, -0.1],
                       [-0.3,  0.4,  0.6,  0.3],
                       [ 0.2, -0.1,  0.3, -0.5]])

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

for ax, eps in zip(axes, eps_values):
    for K, label, color in [(K_identity, 'K = I', '#2196F3'),
                             (K_mixed, 'K mixed', '#4CAF50'),
                             (K_extreme, 'K extreme', '#FF5722')]:
        perturbations = []
        for d in depths:
            contraction = (1 - eps) ** d
            shift = (1 - contraction) / 2
            K_noisy = contraction * K + shift * np.eye(n)
            pert = np.max(np.abs(K - K_noisy))
            perturbations.append(pert)
        ax.plot(depths, perturbations, color=color, label=f'Actual ({label})',
                linewidth=1.5, alpha=0.8)

    # Certified bound
    ax.plot(depths, 3 * depths * eps / 2, 'k--', linewidth=2, label='Bound: 3dε/2',
            alpha=0.9)
    # Bernoulli approximation
    ax.plot(depths, depths * eps / 2, 'k:', linewidth=1.5, label='Approx: dε/2',
            alpha=0.7)

    ax.set_xlabel('Circuit Depth d', fontsize=12)
    ax.set_ylabel('‖K - K\'‖_max', fontsize=12)
    ax.set_title(f'ε = {eps}', fontsize=14)
    ax.legend(fontsize=8, loc='upper left')
    ax.grid(True, alpha=0.3)
    ax.set_xlim(0, 100)

plt.suptitle('Noise Accumulation in Fermionic Quantum Circuits\n'
             'Certified Bound vs. Actual Perturbation',
             fontsize=14, fontweight='bold')
plt.tight_layout()
plt.savefig('viz_noise_accumulation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_noise_accumulation.png")


"""
Visualization: Noise Threshold Surface

Shows the noise threshold as a function of circuit depth and noise rate,
color-coded by whether the certified negative dependence is maintained.
This is the key practical output: the "safe operating region" for
noisy quantum fermion samplers.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.colors import LinearSegmentedColormap

def certified_neg_dep_bound(d, eps):
    eta = 3 * d * eps / 2
    return 2 * (2 * eta + eta**2)

# Create figure with two panels
fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(14, 6))

# Panel 1: Phase diagram (d vs ε) for different δ values
eps_range = np.linspace(0.001, 0.1, 200)
d_range = np.arange(1, 201)

# For a given δ, the threshold is: 2(2η + η²) = δ where η = 3dε/2
# η = -1 + sqrt(1 + δ/2)
delta_values = [0.05, 0.1, 0.2, 0.3, 0.5]
colors = ['#E91E63', '#FF5722', '#FF9800', '#4CAF50', '#2196F3']

for delta, color in zip(delta_values, colors):
    max_eta = -1 + np.sqrt(1 + delta / 2)
    # η = 3dε/2, so d = 2η/(3ε)
    d_threshold = 2 * max_eta / (3 * eps_range)
    ax1.plot(eps_range * 100, d_threshold, color=color, linewidth=2,
             label=f'δ = {delta}')
    ax1.fill_between(eps_range * 100, 0, d_threshold, color=color, alpha=0.05)

ax1.set_xlabel('Noise Rate ε (%)', fontsize=12)
ax1.set_ylabel('Maximum Circuit Depth d', fontsize=12)
ax1.set_title('Safe Operating Region\nfor Certified Fermion Sampling', fontsize=13)
ax1.legend(title='Neg. dep. gap δ', fontsize=9)
ax1.set_xlim(0, 10)
ax1.set_ylim(0, 200)
ax1.grid(True, alpha=0.3)
ax1.text(0.95, 0.95, 'CERTIFIED\nSAFE',
         transform=ax1.transAxes, fontsize=14, color='green',
         ha='right', va='top', alpha=0.5, fontweight='bold')
ax1.text(0.95, 0.05, 'UNCERTIFIED',
         transform=ax1.transAxes, fontsize=14, color='red',
         ha='right', va='bottom', alpha=0.5, fontweight='bold')

# Panel 2: Certified bound as heatmap
D, E = np.meshgrid(d_range, eps_range)
Bound = certified_neg_dep_bound(D, E)

# Use log scale for better visualization
log_bound = np.log10(Bound + 1e-10)

im = ax2.pcolormesh(E * 100, D, log_bound, cmap='hot_r', shading='auto')
cb = fig.colorbar(im, ax=ax2, label='log₁₀(Certified Bound)')

# Add contour lines
contour_levels = [0.01, 0.05, 0.1, 0.2, 0.5, 1.0]
CS = ax2.contour(E * 100, D, Bound, levels=contour_levels,
                  colors='white', linewidths=1)
ax2.clabel(CS, inline=True, fontsize=8, fmt='%.2f')

ax2.set_xlabel('Noise Rate ε (%)', fontsize=12)
ax2.set_ylabel('Circuit Depth d', fontsize=12)
ax2.set_title('Certified Negative Dependence\nDefect Bound', fontsize=13)

plt.suptitle('Noise Threshold for Certified Fermion Sampling',
             fontsize=15, fontweight='bold', y=1.02)
plt.tight_layout()
plt.savefig('viz_threshold_surface.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved viz_threshold_surface.png")
