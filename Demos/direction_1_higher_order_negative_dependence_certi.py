"""
Applications of Higher-Order Minor Perturbation Theory

Demonstrates real-world applications across multiple domains:
1. Certified k-DPP sampling with higher-order guarantees
2. Robust correlation estimation in determinantal models
3. Perturbation analysis for quantum chemistry surrogates
"""

import numpy as np
from itertools import combinations
from math import factorial
from typing import List, Tuple, Dict


def minor_perturb_poly(k: int, M: float) -> float:
    """P(k, M) = k · k! · M^(k-1)"""
    if k == 0:
        return 0.0
    return float(k * factorial(k)) * M ** (k - 1)


# ============================================================
# Application 1: Certified k-DPP Sampling
# ============================================================

def certified_kdpp_sampling(K: np.ndarray, k: int, eta: float,
                            n_samples: int = 1000) -> Dict:
    """
    Certified k-DPP sampling with higher-order guarantees.
    
    Given a kernel K and perturbation budget eta, computes:
    - The certified bound on k-point inclusion probability errors
    - Whether the approximate kernel preserves positivity of all k-minors
    - Empirical sampling statistics for validation
    
    In a k-DPP, the probability of selecting subset S with |S|=k is:
      Pr[S] = det(K_S) / Σ_{|T|=k} det(K_T)
    
    Under perturbation K → K', the selection probabilities change by at most:
      |Pr_K[S] - Pr_{K'}[S]| ≤ C · P(k,M) · η
    where C depends on the partition function and its perturbation.
    
    Args:
        K: PSD kernel matrix
        k: Subset size
        eta: Perturbation budget
        n_samples: Number of Monte Carlo samples for validation
    
    Returns:
        Certification results
    """
    n = K.shape[0]
    M = np.max(np.abs(K))
    
    # Compute all k-minors
    subsets = list(combinations(range(n), k))
    minors = {}
    for S in subsets:
        idx = list(S)
        minors[S] = np.linalg.det(K[np.ix_(idx, idx)])
    
    # Partition function
    Z = sum(minors.values())
    
    # Certified bound on each minor
    bound = minor_perturb_poly(k, M) * eta
    
    # Minimum minor (positivity margin)
    min_minor = min(minors.values())
    
    # Critical perturbation for positivity
    P_kM = minor_perturb_poly(k, M)
    eta_crit = min_minor / P_kM if P_kM > 0 and min_minor > 0 else 0
    
    # Perturbed kernel
    E = np.random.uniform(-eta, eta, (n, n))
    E = (E + E.T) / 2
    K_prime = K + E
    
    # Perturbed minors
    perturbed_minors = {}
    for S in subsets:
        idx = list(S)
        perturbed_minors[S] = np.linalg.det(K_prime[np.ix_(idx, idx)])
    
    Z_prime = sum(perturbed_minors.values())
    
    # Compute actual errors in selection probabilities
    prob_errors = []
    for S in subsets:
        p = minors[S] / Z if Z > 0 else 0
        p_prime = perturbed_minors[S] / Z_prime if Z_prime > 0 else 0
        prob_errors.append(abs(p - p_prime))
    
    return {
        'n': n,
        'k': k,
        'M': M,
        'eta': eta,
        'minor_bound': bound,
        'partition_function': Z,
        'partition_function_perturbed': Z_prime,
        'min_minor': min_minor,
        'eta_critical': eta_crit,
        'positivity_safe': eta < eta_crit,
        'max_prob_error': max(prob_errors),
        'mean_prob_error': np.mean(prob_errors),
        'n_subsets': len(subsets)
    }


# ============================================================
# Application 2: Robust Correlation Estimation
# ============================================================

def correlation_stability_analysis(n: int, k: int,
                                   noise_levels: List[float]) -> Dict:
    """
    Analyze stability of k-point correlation functions under noise.
    
    In statistical physics, the k-point correlation function of a
    determinantal model is ρ_k(S) = det(K_S). Under measurement noise
    or model uncertainty, we need certified bounds on correlation errors.
    
    This function generates a random DPP kernel, adds various levels
    of noise, and compares the certified bound against empirical errors.
    
    Args:
        n: System size (number of sites)
        k: Correlation order
        noise_levels: List of η values to test
    
    Returns:
        Analysis results for each noise level
    """
    # Generate a random DPP kernel (eigenvalues in [0,1])
    U = np.linalg.qr(np.random.randn(n, n))[0]
    eigenvalues = np.random.uniform(0, 1, n)
    K = U @ np.diag(eigenvalues) @ U.T
    K = (K + K.T) / 2  # ensure symmetry
    
    M = np.max(np.abs(K))
    
    results = []
    for eta in noise_levels:
        E = np.random.uniform(-eta, eta, (n, n))
        E = (E + E.T) / 2
        K_noisy = K + E
        
        actual_eta = np.max(np.abs(K - K_noisy))
        M_total = max(M, np.max(np.abs(K_noisy)))
        bound = minor_perturb_poly(k, M_total) * actual_eta
        
        # Compute correlation errors for random subsets
        subsets = list(combinations(range(n), k))
        if len(subsets) > 500:
            idx_choice = np.random.choice(len(subsets), 500, replace=False)
            subsets = [subsets[i] for i in idx_choice]
        
        errors = []
        for S in subsets:
            idx = list(S)
            rho = np.linalg.det(K[np.ix_(idx, idx)])
            rho_noisy = np.linalg.det(K_noisy[np.ix_(idx, idx)])
            errors.append(abs(rho - rho_noisy))
        
        results.append({
            'eta': eta,
            'actual_eta': actual_eta,
            'certified_bound': bound,
            'max_empirical_error': max(errors),
            'mean_empirical_error': np.mean(errors),
            'tightness': max(errors) / bound if bound > 0 else 0
        })
    
    return {
        'n': n,
        'k': k,
        'M': M,
        'P_k_M': minor_perturb_poly(k, M),
        'results': results
    }


# ============================================================
# Application 3: Quantum Chemistry Observables
# ============================================================

def quantum_observable_certification(n_orbitals: int, k_electrons: int,
                                     approx_error: float) -> Dict:
    """
    Certify perturbation bounds for k-electron determinantal observables.
    
    In quantum chemistry, reduced density matrices and their determinantal
    surrogates involve principal minors of the one-body density matrix.
    When using approximate methods (Hartree-Fock, DFT), the kernel is
    known only approximately. This function computes certified error bars.
    
    The one-body density matrix γ of a Slater determinant has eigenvalues
    0 or 1 (occupation numbers). Under perturbation γ → γ', the k-electron
    observables det(γ_S) change by at most P(k, M) · η.
    
    Args:
        n_orbitals: Number of orbitals
        k_electrons: Number of electrons in the observable
        approx_error: Approximation error in the density matrix
    
    Returns:
        Certification results
    """
    n = n_orbitals
    k = k_electrons
    
    # Generate a density matrix (eigenvalues 0 or 1, with some in between for approx)
    n_occupied = min(k + 2, n)
    U = np.linalg.qr(np.random.randn(n, n))[0]
    eigenvalues = np.zeros(n)
    eigenvalues[:n_occupied] = 1.0
    # Add some fractional occupation to simulate correlation effects
    eigenvalues[n_occupied:min(n_occupied+2, n)] = 0.3
    
    gamma = U @ np.diag(eigenvalues) @ U.T
    gamma = (gamma + gamma.T) / 2
    
    M = np.max(np.abs(gamma))
    
    # Compute certified bound
    P_kM = minor_perturb_poly(k, M)
    certified_bound = P_kM * approx_error
    
    # Simulate approximate density matrix
    E = np.random.uniform(-approx_error, approx_error, (n, n))
    E = (E + E.T) / 2
    gamma_approx = gamma + E
    
    # Compute observables
    subsets = list(combinations(range(n), k))
    if len(subsets) > 200:
        idx_choice = np.random.choice(len(subsets), 200, replace=False)
        subsets = [subsets[i] for i in idx_choice]
    
    exact_obs = []
    approx_obs = []
    for S in subsets:
        idx = list(S)
        exact_obs.append(np.linalg.det(gamma[np.ix_(idx, idx)]))
        approx_obs.append(np.linalg.det(gamma_approx[np.ix_(idx, idx)]))
    
    errors = [abs(e - a) for e, a in zip(exact_obs, approx_obs)]
    
    return {
        'n_orbitals': n,
        'k_electrons': k,
        'M': M,
        'approx_error': approx_error,
        'P_k_M': P_kM,
        'certified_bound': certified_bound,
        'max_empirical_error': max(errors),
        'mean_empirical_error': np.mean(errors),
        'tightness': max(errors) / certified_bound if certified_bound > 0 else 0,
        'n_observables': len(subsets),
        'exact_range': (min(exact_obs), max(exact_obs)),
        'approx_range': (min(approx_obs), max(approx_obs))
    }


if __name__ == "__main__":
    np.random.seed(42)
    
    print("=" * 70)
    print("APPLICATION 1: Certified k-DPP Sampling")
    print("=" * 70)
    
    n = 8
    A = np.random.randn(n, n) / np.sqrt(n)
    K = A @ A.T + 0.1 * np.eye(n)
    
    for k in [2, 3, 4]:
        result = certified_kdpp_sampling(K, k, eta=0.01)
        print(f"\nk={k}: {result['n_subsets']} subsets")
        print(f"  Minor bound: {result['minor_bound']:.6f}")
        print(f"  Max prob error: {result['max_prob_error']:.8f}")
        print(f"  Positivity safe: {result['positivity_safe']}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 2: Correlation Stability")
    print("=" * 70)
    
    noise_levels = [0.001, 0.005, 0.01, 0.05, 0.1]
    analysis = correlation_stability_analysis(8, 3, noise_levels)
    
    print(f"\nn={analysis['n']}, k={analysis['k']}, M={analysis['M']:.4f}")
    print(f"P(k,M) = {analysis['P_k_M']:.4f}")
    print(f"\n{'η':>8} {'Certified':>12} {'Empirical':>12} {'Tightness':>12}")
    print("-" * 50)
    for r in analysis['results']:
        print(f"{r['eta']:>8.4f} {r['certified_bound']:>12.6f} "
              f"{r['max_empirical_error']:>12.6f} {r['tightness']:>12.4f}")
    
    print("\n" + "=" * 70)
    print("APPLICATION 3: Quantum Chemistry Observables")
    print("=" * 70)
    
    for k in [2, 3, 4]:
        result = quantum_observable_certification(10, k, 0.01)
        print(f"\nk={k} electrons, {result['n_orbitals']} orbitals:")
        print(f"  P({k}, {result['M']:.2f}) = {result['P_k_M']:.2f}")
        print(f"  Certified bound: {result['certified_bound']:.6f}")
        print(f"  Max empirical error: {result['max_empirical_error']:.8f}")
        print(f"  Tightness: {result['tightness']:.4f}")


"""
Demo: Higher-Order Minor Perturbation Bounds for DPP Kernels

This script demonstrates the certified perturbation theory for principal minors
of symmetric PSD kernels. It generates random PSD matrices, perturbs them
entrywise, computes principal minors, and compares empirical perturbation errors
against the certified bound P(k,M)*η = k·k!·M^(k-1)·η.
"""

import numpy as np
from itertools import combinations
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def minor_perturb_poly(k: int, M: float) -> float:
    """Certified perturbation polynomial P(k, M) = k · k! · M^(k-1)."""
    if k == 0:
        return 0.0
    return k * factorial(k) * M ** (k - 1)


def random_psd_matrix(n: int, rank: int = None) -> np.ndarray:
    """Generate a random n×n symmetric PSD matrix with entries roughly in [-1, 1]."""
    if rank is None:
        rank = n
    A = np.random.randn(n, rank) / np.sqrt(n)
    K = A @ A.T
    return K


def entrywise_perturb(K: np.ndarray, eta: float) -> np.ndarray:
    """Perturb K entrywise by at most eta, preserving symmetry."""
    n = K.shape[0]
    E = np.random.uniform(-eta, eta, (n, n))
    E = (E + E.T) / 2  # symmetrize
    return K + E


def principal_submatrix(K: np.ndarray, indices: tuple) -> np.ndarray:
    """Extract principal submatrix indexed by given indices."""
    idx = list(indices)
    return K[np.ix_(idx, idx)]


def principal_minor(K: np.ndarray, indices: tuple) -> float:
    """Compute det of principal submatrix."""
    return np.linalg.det(principal_submatrix(K, indices))


def max_entry_bound(K: np.ndarray) -> float:
    """Maximum absolute entry of K."""
    return np.max(np.abs(K))


def demo_basic_bound():
    """Demo 1: Basic perturbation bound verification."""
    print("=" * 70)
    print("DEMO 1: Basic Perturbation Bound Verification")
    print("=" * 70)
    
    np.random.seed(42)
    n = 8
    eta = 0.01
    
    K = random_psd_matrix(n)
    K_prime = entrywise_perturb(K, eta)
    
    M = max(max_entry_bound(K), max_entry_bound(K_prime))
    actual_eta = np.max(np.abs(K - K_prime))
    
    print(f"Matrix size: {n}×{n}")
    print(f"Entry bound M: {M:.4f}")
    print(f"Perturbation eta: {actual_eta:.6f}")
    print()
    
    for k in range(1, 6):
        bound = minor_perturb_poly(k, M) * actual_eta
        
        # Sample random k-subsets and compute actual errors
        all_subsets = list(combinations(range(n), k))
        max_error = 0.0
        for S in all_subsets:
            det_K = principal_minor(K, S)
            det_Kp = principal_minor(K_prime, S)
            error = abs(det_K - det_Kp)
            max_error = max(max_error, error)
        
        ratio = max_error / bound if bound > 0 else 0
        print(f"k={k}: max|det(K_S)-det(K'_S)| = {max_error:.8f}, "
              f"bound = {bound:.8f}, ratio = {ratio:.4f}")
    
    print()


def demo_scaling():
    """Demo 2: Scaling of empirical vs certified bounds in k."""
    print("=" * 70)
    print("DEMO 2: Scaling Analysis in k")
    print("=" * 70)
    
    np.random.seed(123)
    n = 10
    eta = 0.005
    n_trials = 20
    
    results = {k: [] for k in range(1, 7)}
    
    for trial in range(n_trials):
        K = random_psd_matrix(n, rank=n)
        K_prime = entrywise_perturb(K, eta)
        M = max(max_entry_bound(K), max_entry_bound(K_prime))
        actual_eta = np.max(np.abs(K - K_prime))
        
        for k in range(1, 7):
            bound = minor_perturb_poly(k, M) * actual_eta
            
            subsets = list(combinations(range(n), k))
            if len(subsets) > 200:
                subsets = [subsets[i] for i in np.random.choice(len(subsets), 200, replace=False)]
            
            max_error = 0.0
            for S in subsets:
                error = abs(principal_minor(K, S) - principal_minor(K_prime, S))
                max_error = max(max_error, error)
            
            results[k].append(max_error / bound if bound > 0 else 0)
    
    print(f"{'k':>3} {'mean ratio':>12} {'max ratio':>12} {'P(k,1)':>12}")
    print("-" * 45)
    for k in range(1, 7):
        ratios = results[k]
        print(f"{k:>3} {np.mean(ratios):>12.6f} {np.max(ratios):>12.6f} "
              f"{minor_perturb_poly(k, 1.0):>12.1f}")
    
    print("\nNote: ratios << 1 confirm the certified bound is valid.")
    print("The bound grows as k·k!, but empirical errors are much smaller.\n")


def demo_positivity_preservation():
    """Demo 3: Positivity margin preservation."""
    print("=" * 70)
    print("DEMO 3: Positivity Margin Preservation (Theorem D)")
    print("=" * 70)
    
    np.random.seed(456)
    n = 6
    k = 3
    
    # Create a well-conditioned PSD matrix
    K = random_psd_matrix(n) + 0.5 * np.eye(n)
    M = max_entry_bound(K)
    
    # Find minimum principal minor
    all_subsets = list(combinations(range(n), k))
    min_minor = min(principal_minor(K, S) for S in all_subsets)
    delta = min_minor
    
    # Compute critical eta
    P_k_M = minor_perturb_poly(k, M)
    eta_critical = delta / P_k_M
    
    print(f"Matrix size: {n}×{n}, subset size k={k}")
    print(f"Entry bound M: {M:.4f}")
    print(f"Min principal minor δ: {delta:.6f}")
    print(f"P({k}, {M:.4f}): {P_k_M:.4f}")
    print(f"Critical η = δ/P(k,M): {eta_critical:.6f}")
    print()
    
    for eta_factor in [0.1, 0.5, 0.9, 1.0, 1.5, 2.0]:
        eta = eta_factor * eta_critical
        n_violations = 0
        n_tests = 50
        
        for _ in range(n_tests):
            K_prime = entrywise_perturb(K, eta)
            for S in all_subsets:
                if principal_minor(K_prime, S) <= 0:
                    n_violations += 1
        
        status = "✓ SAFE" if n_violations == 0 else f"✗ {n_violations} violations"
        print(f"η/η_crit = {eta_factor:.1f}: η = {eta:.6f}, {status}")
    
    print("\nTheorem D guarantees: η < η_crit ⟹ all minors stay positive.\n")


def demo_visualization():
    """Demo 4: Generate visualization plots."""
    print("=" * 70)
    print("DEMO 4: Generating Visualization Plots")
    print("=" * 70)
    
    # Plot 1: P(k, M) growth
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    # P(k, M) vs k for various M
    ks = range(1, 8)
    for M in [0.5, 1.0, 2.0]:
        values = [minor_perturb_poly(k, M) for k in ks]
        axes[0].semilogy(list(ks), values, 'o-', label=f'M={M}')
    axes[0].set_xlabel('k (subset size)')
    axes[0].set_ylabel('P(k, M)')
    axes[0].set_title('Perturbation Polynomial Growth')
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)
    
    # Empirical ratio vs k
    np.random.seed(789)
    n = 8
    eta = 0.01
    ratios_mean = []
    ratios_max = []
    
    for k in range(1, 7):
        trial_ratios = []
        for _ in range(30):
            K = random_psd_matrix(n)
            K_prime = entrywise_perturb(K, eta)
            M = max(max_entry_bound(K), max_entry_bound(K_prime))
            actual_eta = np.max(np.abs(K - K_prime))
            bound = minor_perturb_poly(k, M) * actual_eta
            
            subsets = list(combinations(range(n), k))
            if len(subsets) > 100:
                subsets = [subsets[i] for i in np.random.choice(len(subsets), 100, replace=False)]
            
            max_err = max(abs(principal_minor(K, S) - principal_minor(K_prime, S)) for S in subsets)
            trial_ratios.append(max_err / bound if bound > 0 else 0)
        
        ratios_mean.append(np.mean(trial_ratios))
        ratios_max.append(np.max(trial_ratios))
    
    axes[1].bar(range(1, 7), ratios_max, alpha=0.7, label='Max empirical ratio')
    axes[1].bar(range(1, 7), ratios_mean, alpha=0.7, label='Mean empirical ratio')
    axes[1].axhline(y=1.0, color='r', linestyle='--', label='Certified bound')
    axes[1].set_xlabel('k (subset size)')
    axes[1].set_ylabel('Empirical / Certified')
    axes[1].set_title('Tightness of Bound')
    axes[1].legend()
    axes[1].grid(True, alpha=0.3)
    
    # P(k,M) vs M
    Ms = np.linspace(0.1, 3.0, 50)
    for k in [2, 3, 4, 5]:
        values = [minor_perturb_poly(k, M) for M in Ms]
        axes[2].plot(Ms, values, label=f'k={k}')
    axes[2].set_xlabel('M (entry bound)')
    axes[2].set_ylabel('P(k, M)')
    axes[2].set_title('Polynomial Growth in M')
    axes[2].legend()
    axes[2].grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('perturbation_bounds.png', dpi=150, bbox_inches='tight')
    print("Saved: perturbation_bounds.png")
    plt.close()
    
    print("Visualization complete.\n")


if __name__ == "__main__":
    demo_basic_bound()
    demo_scaling()
    demo_positivity_preservation()
    demo_visualization()
    
    print("=" * 70)
    print("ALL DEMOS COMPLETE")
    print("=" * 70)


"""
Visualization: Perturbation Bound Scaling

Visualizes how the certified perturbation polynomial P(k,M) = k·k!·M^(k-1)
scales with subset size k and entry bound M, and compares against empirical
errors from random PSD matrix perturbations.
"""

import numpy as np
from itertools import combinations
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def minor_perturb_poly(k, M):
    if k == 0:
        return 0.0
    return float(k * factorial(k)) * M ** (k - 1)


def random_psd_matrix(n, rank=None):
    if rank is None:
        rank = n
    A = np.random.randn(n, rank) / np.sqrt(n)
    return A @ A.T


def entrywise_perturb(K, eta):
    n = K.shape[0]
    E = np.random.uniform(-eta, eta, (n, n))
    E = (E + E.T) / 2
    return K + E


np.random.seed(42)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: P(k, M) growth curves
ax = axes[0, 0]
ks = range(1, 9)
for M in [0.5, 1.0, 1.5, 2.0, 3.0]:
    values = [minor_perturb_poly(k, M) for k in ks]
    ax.semilogy(list(ks), values, 'o-', linewidth=2, markersize=6, label=f'M = {M}')
ax.set_xlabel('k (subset size)', fontsize=12)
ax.set_ylabel('P(k, M)', fontsize=12)
ax.set_title('Perturbation Polynomial P(k, M) = k · k! · M^(k-1)', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 2: Empirical tightness ratio
ax = axes[0, 1]
n = 8
eta = 0.01
n_trials = 40

mean_ratios = []
max_ratios = []
k_range = range(1, 7)

for k in k_range:
    trial_ratios = []
    for _ in range(n_trials):
        K = random_psd_matrix(n)
        K_prime = entrywise_perturb(K, eta)
        M = max(np.max(np.abs(K)), np.max(np.abs(K_prime)))
        actual_eta = np.max(np.abs(K - K_prime))
        bound = minor_perturb_poly(k, M) * actual_eta

        subsets = list(combinations(range(n), k))
        if len(subsets) > 100:
            subsets = [subsets[i] for i in np.random.choice(len(subsets), 100, replace=False)]

        max_err = max(abs(np.linalg.det(K[np.ix_(list(S), list(S))]) -
                         np.linalg.det(K_prime[np.ix_(list(S), list(S))]))
                      for S in subsets)
        trial_ratios.append(max_err / bound if bound > 0 else 0)

    mean_ratios.append(np.mean(trial_ratios))
    max_ratios.append(np.max(trial_ratios))

x = list(k_range)
ax.bar(x, max_ratios, alpha=0.6, color='steelblue', label='Max ratio (over trials)')
ax.bar(x, mean_ratios, alpha=0.8, color='coral', label='Mean ratio')
ax.axhline(y=1.0, color='red', linestyle='--', linewidth=2, label='Certified bound = 1')
ax.set_xlabel('k (subset size)', fontsize=12)
ax.set_ylabel('Empirical Error / Certified Bound', fontsize=12)
ax.set_title('Tightness: How Close Are Empirical Errors?', fontsize=13)
ax.legend(fontsize=10)
ax.set_ylim(0, 1.15)
ax.grid(True, alpha=0.3)

# Panel 3: Bound vs eta (linearity check)
ax = axes[1, 0]
n = 6
K = random_psd_matrix(n) + 0.3 * np.eye(n)
M = np.max(np.abs(K))
etas = np.logspace(-4, -1, 20)

for k in [2, 3, 4]:
    certified = [minor_perturb_poly(k, M) * e for e in etas]
    empirical = []
    for e in etas:
        K_prime = entrywise_perturb(K, e)
        actual_e = np.max(np.abs(K - K_prime))
        subsets = list(combinations(range(n), k))
        max_err = max(abs(np.linalg.det(K[np.ix_(list(S), list(S))]) -
                         np.linalg.det(K_prime[np.ix_(list(S), list(S))]))
                      for S in subsets)
        empirical.append(max_err)
    ax.loglog(etas, certified, '--', linewidth=2, label=f'Certified k={k}')
    ax.loglog(etas, empirical, 'o', markersize=5, label=f'Empirical k={k}')

ax.set_xlabel('η (perturbation)', fontsize=12)
ax.set_ylabel('|det(K_S) - det(K\'_S)|', fontsize=12)
ax.set_title('Linearity in η: Certified vs Empirical', fontsize=13)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Panel 4: k! growth comparison
ax = axes[1, 1]
ks = range(1, 10)
pkm = [minor_perturb_poly(k, 1.0) for k in ks]
factorials = [factorial(k) for k in ks]
k_fact_k = [k * factorial(k) for k in ks]
k_sq = [k**2 for k in ks]
k_exp = [2**k for k in ks]

ax.semilogy(list(ks), pkm, 'o-', linewidth=2.5, markersize=8, color='red', label='P(k, 1) = k·k!')
ax.semilogy(list(ks), factorials, 's--', linewidth=1.5, color='blue', alpha=0.7, label='k!')
ax.semilogy(list(ks), k_sq, '^--', linewidth=1.5, color='green', alpha=0.7, label='k²')
ax.semilogy(list(ks), k_exp, 'v--', linewidth=1.5, color='purple', alpha=0.7, label='2^k')
ax.set_xlabel('k (subset size)', fontsize=12)
ax.set_ylabel('Growth Rate', fontsize=12)
ax.set_title('Polynomial Growth: P(k,1) vs Standard Scalings', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Higher-Order Minor Perturbation: Certified Bounds', fontsize=15, y=1.01)
plt.tight_layout()
plt.savefig('viz_bound_scaling.png', dpi=150, bbox_inches='tight')
print("Saved: viz_bound_scaling.png")


"""
Visualization: Correlation Stability Heatmap

Visualizes the stability of k-point correlation functions (principal minors)
under kernel perturbation. Shows heatmaps of original vs perturbed correlations
and the certified error bounds.
"""

import numpy as np
from itertools import combinations
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def minor_perturb_poly(k, M):
    if k == 0:
        return 0.0
    return float(k * factorial(k)) * M ** (k - 1)


np.random.seed(42)

fig, axes = plt.subplots(2, 3, figsize=(16, 10))

n = 6
# Create a nice PSD matrix
U = np.linalg.qr(np.random.randn(n, n))[0]
eigenvalues = np.array([0.9, 0.7, 0.5, 0.3, 0.2, 0.1])
K = U @ np.diag(eigenvalues) @ U.T
K = (K + K.T) / 2

eta = 0.02
E = np.random.uniform(-eta, eta, (n, n))
E = (E + E.T) / 2
K_prime = K + E

M = max(np.max(np.abs(K)), np.max(np.abs(K_prime)))

# Row 1: k=2 pairwise correlations
k = 2
subsets = list(combinations(range(n), k))
n_sub = len(subsets)

original_vals = np.array([np.linalg.det(K[np.ix_(list(S), list(S))]) for S in subsets])
perturbed_vals = np.array([np.linalg.det(K_prime[np.ix_(list(S), list(S))]) for S in subsets])
errors = np.abs(original_vals - perturbed_vals)
bound = minor_perturb_poly(k, M) * np.max(np.abs(K - K_prime))

labels = [f'{S}' for S in subsets]

ax = axes[0, 0]
ax.bar(range(n_sub), original_vals, alpha=0.7, color='steelblue', label='Original')
ax.bar(range(n_sub), perturbed_vals, alpha=0.5, color='coral', label='Perturbed')
ax.set_xticks(range(n_sub))
ax.set_xticklabels(labels, rotation=45, fontsize=7)
ax.set_ylabel('det(K_S)', fontsize=11)
ax.set_title(f'k=2: Pairwise Correlations', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

ax = axes[0, 1]
ax.bar(range(n_sub), errors, alpha=0.8, color='orange')
ax.axhline(y=bound, color='red', linestyle='--', linewidth=2, label=f'Certified bound = {bound:.4f}')
ax.set_xticks(range(n_sub))
ax.set_xticklabels(labels, rotation=45, fontsize=7)
ax.set_ylabel('|det(K_S) - det(K\'_S)|', fontsize=11)
ax.set_title(f'k=2: Perturbation Errors', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Heatmap: pairwise correlation matrix
ax = axes[0, 2]
corr_matrix = np.zeros((n, n))
for i in range(n):
    for j in range(n):
        if i == j:
            corr_matrix[i, j] = K[i, i]
        else:
            corr_matrix[i, j] = np.linalg.det(K[np.ix_([i, j], [i, j])])
im = ax.imshow(corr_matrix, cmap='YlOrRd', aspect='auto')
ax.set_title('Pairwise Correlation Matrix', fontsize=12)
ax.set_xlabel('Site j', fontsize=11)
ax.set_ylabel('Site i', fontsize=11)
plt.colorbar(im, ax=ax, label='det(K_{i,j})')

# Row 2: k=3 triple correlations
k = 3
subsets = list(combinations(range(n), k))
n_sub = len(subsets)

original_vals = np.array([np.linalg.det(K[np.ix_(list(S), list(S))]) for S in subsets])
perturbed_vals = np.array([np.linalg.det(K_prime[np.ix_(list(S), list(S))]) for S in subsets])
errors = np.abs(original_vals - perturbed_vals)
bound = minor_perturb_poly(k, M) * np.max(np.abs(K - K_prime))

labels = [f'{S}' for S in subsets]

ax = axes[1, 0]
ax.bar(range(n_sub), original_vals, alpha=0.7, color='steelblue', label='Original')
ax.bar(range(n_sub), perturbed_vals, alpha=0.5, color='coral', label='Perturbed')
ax.set_xticks(range(0, n_sub, 2))
ax.set_xticklabels([labels[i] for i in range(0, n_sub, 2)], rotation=45, fontsize=6)
ax.set_ylabel('det(K_S)', fontsize=11)
ax.set_title(f'k=3: Triple Correlations', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

ax = axes[1, 1]
ax.bar(range(n_sub), errors, alpha=0.8, color='orange')
ax.axhline(y=bound, color='red', linestyle='--', linewidth=2, label=f'Certified bound = {bound:.4f}')
ax.set_xticks(range(0, n_sub, 2))
ax.set_xticklabels([labels[i] for i in range(0, n_sub, 2)], rotation=45, fontsize=6)
ax.set_ylabel('|det(K_S) - det(K\'_S)|', fontsize=11)
ax.set_title(f'k=3: Perturbation Errors', fontsize=12)
ax.legend(fontsize=9)
ax.grid(True, alpha=0.3)

# Sorted errors vs bound
ax = axes[1, 2]
all_errors = []
all_bounds = []
for k in range(1, 5):
    subsets = list(combinations(range(n), k))
    b = minor_perturb_poly(k, M) * np.max(np.abs(K - K_prime))
    for S in subsets:
        err = abs(np.linalg.det(K[np.ix_(list(S), list(S))]) -
                  np.linalg.det(K_prime[np.ix_(list(S), list(S))]))
        all_errors.append(err)
        all_bounds.append(b)

sorted_idx = np.argsort(all_errors)[::-1]
all_errors = np.array(all_errors)[sorted_idx]
all_bounds = np.array(all_bounds)[sorted_idx]

ax.semilogy(range(len(all_errors)), all_errors, 'b.', markersize=3, label='Empirical errors')
ax.semilogy(range(len(all_bounds)), all_bounds, 'r-', linewidth=1.5, label='Certified bounds')
ax.set_xlabel('Subset index (sorted by error)', fontsize=11)
ax.set_ylabel('Error magnitude', fontsize=11)
ax.set_title('All Errors vs Certified Bounds (k=1..4)', fontsize=12)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle(f'k-Point Correlation Stability Under Perturbation (n={n}, η={eta})',
             fontsize=14, y=1.01)
plt.tight_layout()
plt.savefig('viz_correlation_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved: viz_correlation_heatmap.png")


"""
Visualization: Positivity Margin Preservation

Visualizes Theorem D: if det(K_S) ≥ δ and P(k,M)·η < δ, then det(K'_S) > 0.
Shows the phase transition between safe and unsafe perturbation regimes.
"""

import numpy as np
from itertools import combinations
from math import factorial
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def minor_perturb_poly(k, M):
    if k == 0:
        return 0.0
    return float(k * factorial(k)) * M ** (k - 1)


def random_psd_matrix(n, condition=1.0):
    U = np.linalg.qr(np.random.randn(n, n))[0]
    eigs = np.random.uniform(condition, condition + 1.0, n)
    K = U @ np.diag(eigs) @ U.T
    return (K + K.T) / 2


np.random.seed(2024)

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Phase diagram - which perturbation levels preserve positivity?
ax = axes[0]
n = 6
k = 3

n_trials = 50
eta_fractions = np.linspace(0.01, 3.0, 40)
survival_rates = []

K = random_psd_matrix(n, condition=0.5)
M = np.max(np.abs(K))

# Find min minor
subsets = list(combinations(range(n), k))
min_minor = min(np.linalg.det(K[np.ix_(list(S), list(S))]) for S in subsets)
delta = min_minor
P_kM = minor_perturb_poly(k, M)
eta_crit = delta / P_kM if P_kM > 0 else 1.0

for frac in eta_fractions:
    eta = frac * eta_crit
    successes = 0
    for _ in range(n_trials):
        E = np.random.uniform(-eta, eta, (n, n))
        E = (E + E.T) / 2
        K_prime = K + E
        all_pos = all(np.linalg.det(K_prime[np.ix_(list(S), list(S))]) > 0 for S in subsets)
        if all_pos:
            successes += 1
    survival_rates.append(successes / n_trials)

ax.plot(eta_fractions, survival_rates, 'b-', linewidth=2.5)
ax.axvline(x=1.0, color='red', linestyle='--', linewidth=2, label='η = η_crit')
ax.fill_between(eta_fractions, 0, 1, where=[f <= 1.0 for f in eta_fractions],
                alpha=0.15, color='green', label='Certified safe zone')
ax.set_xlabel('η / η_critical', fontsize=12)
ax.set_ylabel('Fraction with all minors > 0', fontsize=12)
ax.set_title(f'Positivity Survival (n={n}, k={k})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(-0.05, 1.05)

# Panel 2: Minimum minor under perturbation
ax = axes[1]
n = 6
k = 3

K = random_psd_matrix(n, condition=0.3)
M = np.max(np.abs(K))
P_kM = minor_perturb_poly(k, M)

etas_test = np.linspace(0, 0.03, 30)
certified_lower = []
empirical_min = []

subsets = list(combinations(range(n), k))
min_det_K = min(np.linalg.det(K[np.ix_(list(S), list(S))]) for S in subsets)

for eta in etas_test:
    certified_lower.append(max(0, min_det_K - P_kM * eta))

    # Monte Carlo minimum
    min_vals = []
    for _ in range(30):
        E = np.random.uniform(-eta, eta, (n, n))
        E = (E + E.T) / 2
        K_prime = K + E
        min_det = min(np.linalg.det(K_prime[np.ix_(list(S), list(S))]) for S in subsets)
        min_vals.append(min_det)
    empirical_min.append(np.mean(min_vals))

ax.plot(etas_test, [min_det_K] * len(etas_test), 'g--', linewidth=1.5, label='Original min minor')
ax.plot(etas_test, certified_lower, 'r-', linewidth=2.5, label='Certified lower bound')
ax.plot(etas_test, empirical_min, 'b-', linewidth=2, label='Empirical mean min')
ax.fill_between(etas_test, certified_lower, min_det_K, alpha=0.1, color='orange')
ax.set_xlabel('η (perturbation)', fontsize=12)
ax.set_ylabel('Minimum k-minor value', fontsize=12)
ax.set_title(f'Minor Lower Bound vs η (n={n}, k={k})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)

# Panel 3: Critical eta vs k
ax = axes[2]
n = 8
K = random_psd_matrix(n, condition=0.5)
M = np.max(np.abs(K))

ks = range(1, 7)
eta_crits = []
min_minors = []

for k in ks:
    subsets = list(combinations(range(n), k))
    min_det = min(np.linalg.det(K[np.ix_(list(S), list(S))]) for S in subsets)
    P_kM = minor_perturb_poly(k, M)
    eta_c = min_det / P_kM if P_kM > 0 else float('inf')
    eta_crits.append(eta_c)
    min_minors.append(min_det)

ax2 = ax.twinx()
bars = ax.bar(list(ks), eta_crits, alpha=0.7, color='steelblue', label='η_critical')
line = ax2.plot(list(ks), min_minors, 'ro-', linewidth=2, markersize=8, label='Min minor δ')
ax.set_xlabel('k (subset size)', fontsize=12)
ax.set_ylabel('Critical η', fontsize=12, color='steelblue')
ax2.set_ylabel('Minimum minor δ', fontsize=12, color='red')
ax.set_title(f'Critical Perturbation Budget (n={n})', fontsize=13)
ax.tick_params(axis='y', labelcolor='steelblue')
ax2.tick_params(axis='y', labelcolor='red')

lines1, labels1 = ax.get_legend_handles_labels()
lines2, labels2 = ax2.get_legend_handles_labels()
ax.legend(lines1 + lines2, labels1 + labels2, fontsize=10)
ax.grid(True, alpha=0.3)

plt.suptitle('Positivity Preservation Under Perturbation', fontsize=15, y=1.01)
plt.tight_layout()
plt.savefig('viz_positivity_margin.png', dpi=150, bbox_inches='tight')
print("Saved: viz_positivity_margin.png")
