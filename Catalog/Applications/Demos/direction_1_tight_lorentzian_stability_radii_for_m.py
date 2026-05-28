#!/usr/bin/env python3
"""
Applications of Lorentzian Stability Theory for Uniform Matroids

This module demonstrates real-world applications of the spectral stability
theory for Lorentzian polynomials:

1. Robust Log-Concave Sampling: Certify that approximate matroid generating
   polynomials retain their strongly log-concave property.

2. Combinatorial Optimization Robustness: Quantify how much data uncertainty
   can be tolerated before matroid-based optimization loses its guarantees.

3. Spectral Graph Theory: Connect the leaf Hessian to complete graph
   eigenvalues and association scheme properties.

4. Statistical Physics: Model coefficient perturbations as disorder in
   partition functions and identify phase boundaries.
"""

import numpy as np
from math import comb, factorial
from typing import List, Tuple, Dict


# ============================================================================
# Application 1: Robust Strongly Log-Concave Sampling
# ============================================================================

def sample_from_matroid_distribution(n: int, r: int, weights: np.ndarray,
                                      num_samples: int = 1000) -> List[tuple]:
    """Sample bases from weighted uniform matroid using log-concave sampling.
    
    The uniform matroid U_{r,n} has bases = all r-element subsets of [n].
    With weights w_i on element i, the probability of basis B is proportional
    to prod_{i in B} w_i.
    
    Args:
        n: Ground set size
        r: Rank  
        weights: n-dimensional weight vector (positive entries)
        num_samples: Number of samples to draw
        
    Returns:
        List of sampled bases (as tuples of indices)
    """
    from itertools import combinations
    
    # Enumerate all bases and their weights
    bases = list(combinations(range(n), r))
    probs = np.array([np.prod(weights[list(b)]) for b in bases])
    probs /= probs.sum()
    
    # Sample
    indices = np.random.choice(len(bases), size=num_samples, p=probs)
    return [bases[i] for i in indices]


def certify_sampling_robustness(n: int, r: int, 
                                  weight_noise: float) -> Dict:
    """Certify that noisy weights still yield a valid log-concave sampler.
    
    The key insight: if the coefficient perturbation induced by weight
    noise is within the Lorentzian stability radius, then the perturbed
    polynomial is still Lorentzian, and strongly log-concave sampling
    algorithms remain valid.
    
    Args:
        n: Ground set size
        r: Matroid rank
        weight_noise: Maximum relative noise on weights
        
    Returns:
        Certification result with margin information
    """
    m = n - r + 2  # Leaf dimension
    spectral_gap = 1.0
    
    # Weight noise induces coefficient perturbation
    # For e_r with weights, coefficient of basis B is prod w_i
    # Perturbation bound on leaf Hessian entries from weight noise
    max_entry_perturbation = r * weight_noise * comb(n - 2, r - 2)
    
    # Apply entry-to-quadform bound
    quadform_bound = m * max_entry_perturbation
    
    is_certified = quadform_bound < spectral_gap
    margin = spectral_gap - quadform_bound
    
    return {
        'n': n, 'r': r,
        'weight_noise': weight_noise,
        'entry_perturbation': max_entry_perturbation,
        'quadform_bound': quadform_bound,
        'spectral_gap': spectral_gap,
        'is_certified': is_certified,
        'margin': margin,
        'max_tolerable_noise': spectral_gap / (m * r * comb(n - 2, r - 2))
                               if m * r * comb(n - 2, r - 2) > 0 else float('inf')
    }


# ============================================================================
# Application 2: Combinatorial Optimization Robustness
# ============================================================================

def matroid_intersection_robustness(n: int, r: int,
                                     data_uncertainty: float) -> Dict:
    """Analyze robustness of matroid-based optimization under data uncertainty.
    
    In combinatorial optimization, matroid generating polynomials encode
    the basis structure. The Lorentzian property provides negative correlation
    inequalities that are crucial for approximation algorithms.
    
    If the data is uncertain, we need the Lorentzian property to be robust.
    
    Args:
        n: Ground set size
        r: Matroid rank
        data_uncertainty: Bound on data perturbation
        
    Returns:
        Robustness analysis results
    """
    m = n - r + 2
    
    # The optimization guarantee holds when the generating polynomial
    # remains Lorentzian. The stability radius tells us how much
    # perturbation is tolerable.
    stability_radius_entry = 1.0 / m**2  # Conservative entry-wise bound
    stability_radius_amgm = 1.0 / m       # Tighter AM-GM bound
    
    return {
        'n': n, 'r': r, 'm': m,
        'data_uncertainty': data_uncertainty,
        'conservative_radius': stability_radius_entry,
        'tight_radius': stability_radius_amgm,
        'conservative_safe': data_uncertainty < stability_radius_entry,
        'tight_safe': data_uncertainty < stability_radius_amgm,
        'improvement_factor': m  # How much better the tight bound is
    }


# ============================================================================
# Application 3: Spectral Graph Theory Connection
# ============================================================================

def complete_graph_spectral_connection(m: int) -> Dict:
    """Demonstrate the connection between leaf Hessian and complete graph.
    
    The Hessian J - I is exactly the adjacency matrix of the complete graph K_m.
    Its eigenvalues correspond to the trivial and standard representations
    of the symmetric group S_m.
    
    This connects Lorentzian stability to:
    - Spectral graph theory (Ramanujan-like gap properties)
    - Association schemes (Johnson scheme)
    - Random matrix theory
    
    Args:
        m: Number of vertices = dimension
        
    Returns:
        Spectral graph theory analysis
    """
    # Adjacency matrix of K_m
    A_Km = np.ones((m, m)) - np.eye(m)
    eigenvalues = np.linalg.eigvalsh(A_Km)
    eigenvalues.sort()
    
    # Spectral gap of K_m
    lambda_1 = m - 1  # Largest eigenvalue
    lambda_2 = -1     # Second largest (all others are -1)
    
    # Ramanujan bound for comparison: 2*sqrt(d-1) for d-regular graphs
    d = m - 1  # K_m is (m-1)-regular
    ramanujan_bound = 2 * np.sqrt(d - 1) if d > 1 else 0
    
    # The gap lambda_1 - |lambda_2| = (m-1) - 1 = m - 2
    spectral_separation = lambda_1 - abs(lambda_2)
    
    return {
        'm': m,
        'eigenvalues': {'positive': lambda_1, 'negative': lambda_2},
        'spectral_gap': abs(lambda_2),  # Gap = 1 (the stability-controlling quantity)
        'spectral_separation': spectral_separation,
        'ramanujan_bound': ramanujan_bound,
        'is_ramanujan': abs(lambda_2) <= ramanujan_bound,
        'representation_decomposition': {
            'trivial': {'eigenvalue': m - 1, 'dimension': 1},
            'standard': {'eigenvalue': -1, 'dimension': m - 1}
        },
        'graph_properties': {
            'vertices': m,
            'edges': m * (m - 1) // 2,
            'regularity': m - 1,
            'diameter': 1 if m > 1 else 0,
            'chromatic_number': m
        }
    }


# ============================================================================
# Application 4: Statistical Physics — Partition Function Disorder
# ============================================================================

def partition_function_phase_analysis(m: int, temperatures: np.ndarray) -> Dict:
    """Analyze phase structure of the partition function model.
    
    View the elementary symmetric polynomial as a partition function:
      Z = e_2(x_1, ..., x_m) = Σ_{i<j} x_i x_j
    
    Adding "disorder" (coefficient perturbation) corresponds to modifying
    the interaction strengths. The Lorentzian property corresponds to a
    specific phase (one unstable mode), and the stability radius marks
    a phase boundary.
    
    Args:
        m: Number of sites/variables
        temperatures: Array of temperature values to analyze
        
    Returns:
        Phase analysis results
    """
    H = np.ones((m, m)) - np.eye(m)
    
    results = []
    for T in temperatures:
        # At temperature T, add thermal noise proportional to T
        noise_scale = T / m  # Scale noise by dimension
        
        # Check if Lorentzian signature survives
        E = noise_scale * np.eye(m)  # Diagonal disorder
        H_perturbed = H + E
        eigenvalues = np.linalg.eigvalsh(H_perturbed)
        n_positive = np.sum(eigenvalues > 1e-12)
        
        results.append({
            'temperature': T,
            'noise_scale': noise_scale,
            'n_positive_eigenvalues': int(n_positive),
            'is_lorentzian_phase': n_positive <= 1,
            'max_eigenvalue': float(eigenvalues[-1]),
            'min_eigenvalue': float(eigenvalues[0]),
        })
    
    # Find critical temperature
    critical_T = None
    for i in range(len(results) - 1):
        if results[i]['is_lorentzian_phase'] and not results[i+1]['is_lorentzian_phase']:
            critical_T = (results[i]['temperature'] + results[i+1]['temperature']) / 2
            break
    
    return {
        'm': m,
        'phase_data': results,
        'critical_temperature': critical_T,
        'predicted_critical': m,  # Predicted from spectral gap theory
    }


# ============================================================================
# Main demonstration
# ============================================================================

def main():
    print("=" * 70)
    print("  Applications of Lorentzian Stability Theory")
    print("=" * 70)
    print()
    
    # Application 1: Sampling robustness
    print("APPLICATION 1: Robust Log-Concave Sampling")
    print("-" * 50)
    for noise in [0.001, 0.01, 0.05, 0.1]:
        cert = certify_sampling_robustness(8, 3, noise)
        status = "✓ CERTIFIED" if cert['is_certified'] else "✗ NOT CERTIFIED"
        print(f"  Noise={noise:.3f}: {status} (margin={cert['margin']:.4f})")
    cert = certify_sampling_robustness(8, 3, 0.001)
    print(f"  Max tolerable noise for U_{{3,8}}: {cert['max_tolerable_noise']:.6f}")
    print()
    
    # Application 2: Optimization robustness
    print("APPLICATION 2: Combinatorial Optimization Robustness")
    print("-" * 50)
    for n, r in [(6, 3), (8, 4), (10, 5), (12, 6)]:
        rob = matroid_intersection_robustness(n, r, 0.01)
        print(f"  U_{{{r},{n}}}: conservative_safe={rob['conservative_safe']}, "
              f"tight_safe={rob['tight_safe']}, improvement={rob['improvement_factor']}x")
    print()
    
    # Application 3: Spectral graph theory
    print("APPLICATION 3: Complete Graph Spectral Connection")
    print("-" * 50)
    for m in [3, 5, 8, 12]:
        spec = complete_graph_spectral_connection(m)
        print(f"  K_{m}: eigenvalues={{+{spec['eigenvalues']['positive']}, "
              f"{spec['eigenvalues']['negative']}×{m-1}}}, "
              f"gap={spec['spectral_gap']}, "
              f"Ramanujan={'Yes' if spec['is_ramanujan'] else 'No'}")
    print()
    
    # Application 4: Phase analysis
    print("APPLICATION 4: Partition Function Phase Transition")
    print("-" * 50)
    temps = np.linspace(0.1, 20, 200)
    for m in [4, 6, 8]:
        phase = partition_function_phase_analysis(m, temps)
        print(f"  m={m}: critical T ≈ {phase['critical_temperature']:.2f} "
              f"(predicted: {phase['predicted_critical']})")
    print()


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Lorentzian Stability Radii for Uniform Matroid Families

This script demonstrates the spectral mechanism governing Lorentzian stability
for uniform matroids U_{r,n}. It computes the canonical leaf Hessian, its
spectral gap, and runs perturbation experiments to empirically determine
the stability radius.

Usage:
    python demo.py [n] [r]
    
    If no arguments given, runs interactive mode.
"""

import numpy as np
from math import comb
import sys


def leaf_hessian(m: int) -> np.ndarray:
    """Construct the canonical leaf Hessian J - I for m variables.
    
    This is the Hessian of e_2(x_1, ..., x_m), the second elementary
    symmetric polynomial. It has off-diagonal entries 1 and diagonal entries 0.
    
    Args:
        m: Number of variables in the quadratic leaf
        
    Returns:
        m x m numpy array representing J - I
    """
    return np.ones((m, m)) - np.eye(m)


def spectral_gap(m: int) -> dict:
    """Compute the exact spectral gap of the leaf Hessian.
    
    The Hessian J - I has eigenvalues:
    - m - 1 (multiplicity 1, eigenvector: all-ones)
    - -1 (multiplicity m - 1, orthogonal complement)
    
    The spectral gap is 1 (absolute value of the negative eigenvalue).
    
    Args:
        m: Number of variables
        
    Returns:
        Dictionary with eigenvalue information and gap
    """
    H = leaf_hessian(m)
    eigenvalues = np.linalg.eigvalsh(H)
    eigenvalues.sort()
    
    return {
        'positive_eigenvalue': m - 1,
        'negative_eigenvalue': -1,
        'multiplicity_positive': 1,
        'multiplicity_negative': m - 1,
        'spectral_gap': 1,
        'normalized_gap': 1.0 / (m - 1) if m > 1 else float('inf'),
        'numerical_eigenvalues': eigenvalues,
    }


def quadratic_form(H: np.ndarray, v: np.ndarray) -> float:
    """Compute the quadratic form Q_H(v) = v^T H v."""
    return float(v @ H @ v)


def check_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if a matrix has at most one positive eigenvalue.
    
    This is the Lorentzian signature condition: exactly one positive
    eigenvalue and the rest nonpositive.
    
    Args:
        H: Symmetric matrix
        tol: Tolerance for eigenvalue sign determination
        
    Returns:
        True if at most one eigenvalue is positive
    """
    eigenvalues = np.linalg.eigvalsh(H)
    n_positive = np.sum(eigenvalues > tol)
    return n_positive <= 1


def find_instability_threshold(m: int, num_trials: int = 200,
                                perturbation_type: str = 'diagonal') -> float:
    """Binary search for the perturbation threshold where Lorentzianity breaks.
    
    Args:
        m: Number of variables
        num_trials: Number of binary search steps
        perturbation_type: Type of perturbation ('diagonal', 'random_symmetric')
        
    Returns:
        Empirical stability radius
    """
    H = leaf_hessian(m)
    
    lo, hi = 0.0, 5.0
    
    for _ in range(num_trials):
        mid = (lo + hi) / 2
        
        if perturbation_type == 'diagonal':
            E = mid * np.eye(m)
        elif perturbation_type == 'random_symmetric':
            R = np.random.randn(m, m)
            R = (R + R.T) / 2
            R = R / np.max(np.abs(R)) if np.max(np.abs(R)) > 0 else R
            E = mid * R
        else:
            raise ValueError(f"Unknown perturbation type: {perturbation_type}")
        
        if check_lorentzian_signature(H + E):
            lo = mid
        else:
            hi = mid
    
    return (lo + hi) / 2


def predicted_radius(n: int, r: int) -> float:
    """Predicted stability radius based on spectral gap theory.
    
    The stability radius is controlled by the canonical leaf gap (= 1)
    divided by the entry-to-quadform bound factor m^2, giving 1/m^2.
    But the tighter AM-GM bound gives 1/m.
    
    For diagonal perturbations, the exact threshold is t = 1.
    
    Args:
        n: Total number of variables
        r: Rank of the uniform matroid
        
    Returns:
        Predicted radius scale
    """
    m = n - r + 2  # Number of leaf variables
    return 1.0  # The diagonal perturbation threshold


def run_demo(n: int, r: int):
    """Run the full demonstration for U_{r,n}.
    
    Args:
        n: Total number of variables
        r: Rank of the uniform matroid
    """
    m = n - r + 2  # Number of leaf variables
    
    print("=" * 70)
    print(f"  Lorentzian Stability Analysis for U_{{{r},{n}}}")
    print(f"  Uniform Matroid Generating Polynomial: e_{r}(x_1,...,x_{n})")
    print("=" * 70)
    print()
    
    # Display the canonical leaf Hessian
    H = leaf_hessian(m)
    print(f"1. CANONICAL LEAF HESSIAN (m = {m} variables)")
    print(f"   Hessian of e_2(x_1,...,x_{m}) = J - I:")
    print()
    for i in range(min(m, 8)):
        row = "   ["
        for j in range(min(m, 8)):
            row += f" {H[i,j]:4.0f}"
        if m > 8:
            row += " ..."
        row += " ]"
        print(row)
    if m > 8:
        print("   [ ...                          ]")
    print()
    
    # Spectral analysis
    spec = spectral_gap(m)
    print(f"2. SPECTRAL ANALYSIS")
    print(f"   Positive eigenvalue: {spec['positive_eigenvalue']} (multiplicity {spec['multiplicity_positive']})")
    print(f"   Negative eigenvalue: {spec['negative_eigenvalue']} (multiplicity {spec['multiplicity_negative']})")
    print(f"   Spectral gap (raw): {spec['spectral_gap']}")
    print(f"   Normalized gap (gap/pos_eigenvalue): {spec['normalized_gap']:.6f}")
    print(f"   Numerical eigenvalues: {np.round(spec['numerical_eigenvalues'], 6)}")
    print()
    
    # Quadratic form decomposition
    print(f"3. QUADRATIC FORM DECOMPOSITION")
    print(f"   Q_{{J-I}}(v) = (Σ v_i)² - Σ v_i²")
    v_test = np.random.randn(m)
    q_direct = quadratic_form(H, v_test)
    q_decomp = np.sum(v_test)**2 - np.sum(v_test**2)
    print(f"   Verification: Q_direct = {q_direct:.6f}, Q_decomposed = {q_decomp:.6f}")
    print(f"   Match: {abs(q_direct - q_decomp) < 1e-10}")
    print()
    
    # Stability radius prediction
    pred = predicted_radius(n, r)
    print(f"4. STABILITY RADIUS PREDICTION")
    print(f"   Diagonal perturbation threshold: t = {pred}")
    print(f"   Entry-wise bound (1/m²): {1.0/m**2:.6f}")
    print(f"   Tighter AM-GM bound (1/m): {1.0/m:.6f}")
    print()
    
    # Empirical stability search
    print(f"5. EMPIRICAL INSTABILITY SEARCH")
    emp_diag = find_instability_threshold(m, perturbation_type='diagonal')
    print(f"   Diagonal perturbation threshold: {emp_diag:.6f}")
    print(f"   Predicted threshold: {pred:.6f}")
    print(f"   Ratio (empirical/predicted): {emp_diag/pred:.6f}")
    print()
    
    # Ratio analysis
    print(f"6. RATIO ANALYSIS")
    gap = spec['spectral_gap']
    binom = comb(n, r)
    print(f"   C(n,r) = C({n},{r}) = {binom}")
    print(f"   Gap g_{{{r},{n}}} = {gap}")
    print(f"   ρ / (C(n,r)^(-1) * g) = {emp_diag * binom / gap:.6f}")
    print()


def scan_all_parameters(max_n: int = 15):
    """Scan all valid (n,r) pairs and compute stability ratios.
    
    Args:
        max_n: Maximum value of n to scan
    """
    print("=" * 70)
    print("  COMPREHENSIVE STABILITY RADIUS SCAN (n ≤ {})".format(max_n))
    print("=" * 70)
    print()
    print(f"{'n':>3} {'r':>3} {'m':>3} {'gap':>6} {'emp_rad':>10} {'C(n,r)':>8} {'ratio':>10}")
    print("-" * 55)
    
    ratios = []
    
    for n in range(4, max_n + 1):
        for r in range(2, n - 1):
            m = n - r + 2
            gap = 1.0
            emp_rad = find_instability_threshold(m, num_trials=100, 
                                                  perturbation_type='diagonal')
            binom = comb(n, r)
            ratio = emp_rad * binom / gap
            ratios.append({
                'n': n, 'r': r, 'm': m,
                'gap': gap, 'emp_rad': emp_rad,
                'binom': binom, 'ratio': ratio
            })
            print(f"{n:3d} {r:3d} {m:3d} {gap:6.2f} {emp_rad:10.6f} {binom:8d} {ratio:10.4f}")
    
    print()
    ratios_array = [r['ratio'] for r in ratios]
    print(f"Ratio statistics:")
    print(f"  Min: {min(ratios_array):.4f}")
    print(f"  Max: {max(ratios_array):.4f}")
    print(f"  Mean: {np.mean(ratios_array):.4f}")
    print(f"  Std: {np.std(ratios_array):.4f}")
    
    # Check if ratios are in a narrow band
    K = np.mean(ratios_array)
    in_band = sum(1 for r in ratios_array if 0.9 * K <= r <= 1.1 * K)
    print(f"  Fraction in [0.9K, 1.1K] band: {in_band}/{len(ratios_array)}")
    
    return ratios


if __name__ == "__main__":
    if len(sys.argv) == 3:
        n, r = int(sys.argv[1]), int(sys.argv[2])
        if r < 2 or r > n - 2:
            print(f"Error: Need 2 ≤ r ≤ n-2, got r={r}, n={n}")
            sys.exit(1)
        run_demo(n, r)
    elif len(sys.argv) == 1:
        print("Lorentzian Stability Radius Demo")
        print("================================")
        print()
        print("Running default demo with U_{3,7}...")
        print()
        run_demo(7, 3)
        print()
        print("Running comprehensive scan...")
        print()
        scan_all_parameters(12)
    else:
        print("Usage: python demo.py [n] [r]")
        print("  n: total variables, r: matroid rank")
        print("  Need 2 ≤ r ≤ n-2")


#!/usr/bin/env python3
"""
Visualization: Eigenvalue Flow Under Perturbation

This script shows how the eigenvalues of the leaf Hessian J - I evolve
as perturbation strength increases, revealing the exact moment when
the Lorentzian signature breaks (a second eigenvalue crosses zero).

Panel 1: Eigenvalue flow for diagonal perturbation (m=6)
Panel 2: Eigenvalue flow for rank-one perturbation
Panel 3: Comparison of thresholds across perturbation types
"""

import numpy as np
import matplotlib.pyplot as plt


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Eigenvalue flow under diagonal perturbation
m = 6
H = leaf_hessian(m)
t_vals = np.linspace(0, 2.0, 300)
all_eigs = []

for t in t_vals:
    E = t * np.eye(m)
    eigs = np.linalg.eigvalsh(H + E)
    eigs.sort()
    all_eigs.append(eigs)

all_eigs = np.array(all_eigs)
colors = ['#d62728', '#ff7f0e', '#2ca02c', '#1f77b4', '#9467bd', '#8c564b']

for k in range(m):
    label = None
    if k == 0:
        label = f'λ = {m-1}+t (positive)'
    elif k == 1:
        label = f'λ = -1+t (×{m-1})'
    axes[0].plot(t_vals, all_eigs[:, k], color=colors[min(k, len(colors)-1)],
                  linewidth=2 if k in [0, m-1] else 1, label=label)

axes[0].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[0].axvline(x=1.0, color='red', linestyle=':', alpha=0.7, linewidth=2)
axes[0].annotate('Threshold t = 1', xy=(1.0, 0), xytext=(1.3, -0.5),
                  fontsize=10, arrowprops=dict(arrowstyle='->', color='red'),
                  color='red')
axes[0].set_xlabel('Perturbation strength t', fontsize=12)
axes[0].set_ylabel('Eigenvalue', fontsize=12)
axes[0].set_title(f'Eigenvalue Flow: (J−I) + tI, m={m}', fontsize=13)
axes[0].legend(fontsize=9)

# Panel 2: Rank-one perturbation
all_eigs_r1 = []
for t in t_vals:
    E = np.zeros((m, m))
    E[0, 0] = t
    eigs = np.linalg.eigvalsh(H + E)
    eigs.sort()
    all_eigs_r1.append(eigs)

all_eigs_r1 = np.array(all_eigs_r1)
for k in range(m):
    axes[1].plot(t_vals, all_eigs_r1[:, k], 
                  color=colors[min(k, len(colors)-1)],
                  linewidth=1.5)

axes[1].axhline(y=0, color='gray', linestyle='--', alpha=0.5)

# Find threshold
for i in range(len(t_vals) - 1):
    eigs = np.linalg.eigvalsh(H + t_vals[i] * np.diag([1] + [0]*(m-1)))
    n_pos = np.sum(eigs > 1e-10)
    if n_pos > 1:
        axes[1].axvline(x=t_vals[i], color='red', linestyle=':', alpha=0.7, linewidth=2)
        break

axes[1].set_xlabel('Perturbation strength t', fontsize=12)
axes[1].set_ylabel('Eigenvalue', fontsize=12)
axes[1].set_title(f'Eigenvalue Flow: (J−I) + t·e₁e₁ᵀ, m={m}', fontsize=13)

# Panel 3: Threshold comparison across dimensions
ms = list(range(3, 18))
thresholds_diag = []
thresholds_r1 = []
thresholds_uniform = []

for m in ms:
    H = leaf_hessian(m)
    
    # Diagonal threshold (exact: t = 1)
    thresholds_diag.append(1.0)
    
    # Rank-one threshold (binary search)
    lo, hi = 0.0, 10.0
    for _ in range(100):
        mid = (lo + hi) / 2
        E = np.zeros((m, m))
        E[0, 0] = mid
        eigs = np.linalg.eigvalsh(H + E)
        if np.sum(eigs > 1e-10) <= 1:
            lo = mid
        else:
            hi = mid
    thresholds_r1.append((lo + hi) / 2)
    
    # Uniform random (average over trials)
    np.random.seed(42)
    trial_thresholds = []
    for _ in range(20):
        R = np.random.randn(m, m)
        R = (R + R.T) / 2
        R /= max(np.max(np.abs(np.linalg.eigvalsh(R))), 1e-10)
        lo, hi = 0.0, 10.0
        for _ in range(80):
            mid = (lo + hi) / 2
            eigs = np.linalg.eigvalsh(H + mid * R)
            if np.sum(eigs > 1e-10) <= 1:
                lo = mid
            else:
                hi = mid
        trial_thresholds.append((lo + hi) / 2)
    thresholds_uniform.append(np.mean(trial_thresholds))

axes[2].plot(ms, thresholds_diag, 'ko-', markersize=5, label='Diagonal (tI)', linewidth=2)
axes[2].plot(ms, thresholds_r1, 'b^-', markersize=5, label='Rank-one (te₁e₁ᵀ)')
axes[2].plot(ms, thresholds_uniform, 'rs-', markersize=4, label='Random symmetric (avg)')
axes[2].axhline(y=1.0, color='gray', linestyle='--', alpha=0.5, label='Gap = 1')
axes[2].set_xlabel('Leaf dimension m', fontsize=12)
axes[2].set_ylabel('Instability threshold', fontsize=12)
axes[2].set_title('Threshold Comparison Across Perturbation Types', fontsize=13)
axes[2].legend(fontsize=9)

plt.tight_layout()
plt.savefig('eigenvalue_flow.png', dpi=150, bbox_inches='tight')
print("Saved eigenvalue_flow.png")


#!/usr/bin/env python3
"""
Visualization: Perturbation Landscape and Phase Boundary

This script visualizes how Lorentzian signature breaks down under
perturbation, showing the phase boundary between "Lorentzian" and
"non-Lorentzian" regimes for the uniform matroid leaf Hessian.

Panel 1: Quadratic form contour plot on 2D subspace
Panel 2: Phase diagram — Lorentzianity vs perturbation type and magnitude
Panel 3: Stability ratio ρ·C(n,r)/g across parameter space
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)


def check_lorentzian(H, tol=1e-10):
    eigs = np.linalg.eigvalsh(H)
    return int(np.sum(eigs > tol)) <= 1


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Quadratic form on 2D subspace for m=4
m = 4
H = leaf_hessian(m)

# Project onto 2D: v = α·(1,1,1,1)/2 + β·(1,-1,0,0)/√2
e_all = np.ones(m) / np.sqrt(m)
e_orth = np.zeros(m)
e_orth[0] = 1 / np.sqrt(2)
e_orth[1] = -1 / np.sqrt(2)

alphas = np.linspace(-3, 3, 200)
betas = np.linspace(-3, 3, 200)
A, B = np.meshgrid(alphas, betas)
Q = np.zeros_like(A)

for i in range(len(alphas)):
    for j in range(len(betas)):
        v = A[j, i] * e_all + B[j, i] * e_orth
        Q[j, i] = v @ H @ v

contour = axes[0].contourf(A, B, Q, levels=30, cmap='RdBu_r')
axes[0].contour(A, B, Q, levels=[0], colors='black', linewidths=2)
axes[0].set_xlabel('α (all-ones direction)', fontsize=11)
axes[0].set_ylabel('β (orthogonal direction)', fontsize=11)
axes[0].set_title('Quadratic Form Q(αe₊ + βe₋)', fontsize=13)
plt.colorbar(contour, ax=axes[0], shrink=0.8)

# Panel 2: Phase diagram
m_vals = range(3, 16)
t_vals = np.linspace(0, 2.5, 100)

phase = np.zeros((len(list(m_vals)), len(t_vals)))
for i, m in enumerate(m_vals):
    H = leaf_hessian(m)
    for j, t in enumerate(t_vals):
        # Diagonal perturbation
        H_pert = H + t * np.eye(m)
        phase[i, j] = 1 if check_lorentzian(H_pert) else 0

im2 = axes[1].imshow(phase, aspect='auto', origin='lower',
                       extent=[t_vals[0], t_vals[-1], 2.5, 15.5],
                       cmap='RdYlGn', interpolation='nearest')
axes[1].axvline(x=1.0, color='white', linestyle='--', linewidth=2, label='Gap = 1')
axes[1].set_xlabel('Diagonal perturbation t', fontsize=11)
axes[1].set_ylabel('Leaf dimension m', fontsize=11)
axes[1].set_title('Phase Diagram: Lorentzian (green) vs Not (red)', fontsize=13)
axes[1].legend(fontsize=10, loc='upper right')

# Panel 3: Stability ratio heatmap
max_n = 14
ns = range(4, max_n + 1)
ratios = {}

for n in ns:
    for r in range(2, n - 1):
        m = n - r + 2
        # For diagonal perturbation, threshold is exactly 1
        emp_rad = 1.0  # Exact for diagonal
        gap = 1.0
        binom = comb(n, r)
        ratio = emp_rad * binom / gap
        ratios[(n, r)] = ratio

# Create heatmap
max_r = max(r for n, r in ratios.keys())
min_r = 2
ratio_grid = np.full((max_n - 3, max_r - 1), np.nan)

for (n, r), ratio in ratios.items():
    ratio_grid[n - 4, r - 2] = np.log10(ratio)

im3 = axes[2].imshow(ratio_grid.T, aspect='auto', origin='lower',
                       extent=[3.5, max_n + 0.5, 1.5, max_r + 0.5],
                       cmap='viridis', interpolation='nearest')
axes[2].set_xlabel('n (total variables)', fontsize=11)
axes[2].set_ylabel('r (matroid rank)', fontsize=11)
axes[2].set_title('log₁₀(ρ · C(n,r) / g)', fontsize=13)
plt.colorbar(im3, ax=axes[2], shrink=0.8, label='log₁₀(ratio)')

plt.tight_layout()
plt.savefig('perturbation_landscape.png', dpi=150, bbox_inches='tight')
print("Saved perturbation_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Gap Structure of Uniform Matroid Leaf Hessians

This script visualizes the eigenvalue structure of the canonical leaf Hessian
J - I for the uniform matroid, showing how the spectral gap controls
Lorentzian stability under perturbation.

Panel 1: Heatmap of the leaf Hessian J - I
Panel 2: Eigenvalue spectrum showing the gap
Panel 3: Stability radius as a function of leaf dimension m
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)


def find_diagonal_threshold(m, tol=1e-8):
    H = leaf_hessian(m)
    lo, hi = 0.0, 5.0
    for _ in range(100):
        mid = (lo + hi) / 2
        eigs = np.linalg.eigvalsh(H + mid * np.eye(m))
        if np.sum(eigs > 1e-12) <= 1:
            lo = mid
        else:
            hi = mid
    return (lo + hi) / 2


fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Heatmap of leaf Hessian
m = 8
H = leaf_hessian(m)
im = axes[0].imshow(H, cmap='RdBu_r', vmin=-1, vmax=1, interpolation='nearest')
axes[0].set_title(f'Leaf Hessian (J − I), m = {m}', fontsize=13)
axes[0].set_xlabel('Column index j')
axes[0].set_ylabel('Row index i')
plt.colorbar(im, ax=axes[0], shrink=0.8)

# Panel 2: Eigenvalue spectrum for several m values
for m_val in [4, 6, 8, 12, 16]:
    eigs = np.linalg.eigvalsh(leaf_hessian(m_val))
    axes[1].scatter([m_val] * len(eigs), eigs, s=30, alpha=0.7,
                     label=f'm={m_val}' if m_val in [4, 8, 16] else None)

axes[1].axhline(y=0, color='gray', linestyle='--', alpha=0.5)
axes[1].axhline(y=-1, color='red', linestyle=':', alpha=0.7, label='λ = −1 (gap)')
axes[1].set_xlabel('Leaf dimension m', fontsize=12)
axes[1].set_ylabel('Eigenvalue', fontsize=12)
axes[1].set_title('Eigenvalue Spectrum of J − I', fontsize=13)
axes[1].legend(fontsize=9)

# Panel 3: Stability radii vs m
ms = list(range(3, 20))
thresholds_diag = [find_diagonal_threshold(m) for m in ms]
entry_bounds = [1.0 / m**2 for m in ms]
amgm_bounds = [1.0 / m for m in ms]
theoretical = [1.0] * len(ms)

axes[2].plot(ms, theoretical, 'k-', linewidth=2, label='Spectral gap = 1')
axes[2].plot(ms, thresholds_diag, 'bo-', markersize=5, label='Diagonal threshold')
axes[2].plot(ms, amgm_bounds, 'r^--', markersize=5, label='AM-GM bound (1/m)')
axes[2].plot(ms, entry_bounds, 'gs--', markersize=4, label='Entry bound (1/m²)')
axes[2].set_xlabel('Leaf dimension m', fontsize=12)
axes[2].set_ylabel('Stability radius', fontsize=12)
axes[2].set_title('Stability Radii vs Dimension', fontsize=13)
axes[2].legend(fontsize=9)
axes[2].set_yscale('log')
axes[2].set_ylim(0.001, 2)

plt.tight_layout()
plt.savefig('spectral_gap_analysis.png', dpi=150, bbox_inches='tight')
print("Saved spectral_gap_analysis.png")
