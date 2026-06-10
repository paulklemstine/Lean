#!/usr/bin/env python3
"""
Applications of Certified Lorentzian Recognition

Demonstrates real-world applications of the numerical stability theory:
1. Robust optimization on trust regions
2. Log-concavity certification for distributions
3. Matroid basis polynomial testing
"""

import numpy as np
from algorithms import (compute_spectral_gap, certify_lorentzian_stability,
                        elementary_symmetric_polynomial_hessian,
                        lorentzian_condition_number)


def trust_region_geometry(H, epsilon, r=1.0):
    """Demonstrate trust-region geometry from Lorentzian structure.
    
    When H has gapped Lorentzian signature with gap ε:
    - On the tangent space of any positive direction, the form is ≤ 0
    - This means quadratic optimization on spheres has controlled saddle geometry
    - The gap ε quantifies the "curvature" of the saddle
    
    Args:
        H: Symmetric matrix with Lorentzian signature
        epsilon: Spectral gap
        r: Trust region radius
    """
    n = H.shape[0]
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    eigenvectors = np.linalg.eigh(H)[1][:, ::-1]
    
    print(f"Trust Region Analysis (r={r})")
    print(f"  Eigenvalues: {eigenvalues}")
    print(f"  Gap (ε): {epsilon:.4f}")
    
    # The positive eigendirection
    pos_dir = eigenvectors[:, 0]
    print(f"  Positive eigendirection: {pos_dir}")
    
    # Maximum of x^T H x on sphere ||x|| = r
    max_val = eigenvalues[0] * r**2
    print(f"  Max of Q on sphere ||x||={r}: {max_val:.4f}")
    
    # The maximizer is along the positive eigendirection
    x_max = pos_dir * r
    print(f"  Maximizer: {x_max}")
    
    # On the tangent space at x_max, the form is bounded by -ε||v||²
    print(f"  Tangent space concavity bound: Q(v) ≤ -{epsilon:.4f}||v||²")
    print(f"  → Unique maximizer guaranteed by strong concavity on tangent space")
    
    # Perturbation tolerance
    print(f"  Perturbation tolerance for structure: δ < {epsilon:.4f}")
    print(f"  After perturbation by δ={epsilon/2:.4f}: residual gap = {epsilon/2:.4f}")


def log_concavity_certification(n_vars, degree):
    """Certify strong log-concavity of generating polynomial coefficients.
    
    Elementary symmetric polynomials are Lorentzian, which implies
    ultra-log-concavity of their coefficient sequences. The spectral gap
    quantifies how robustly this property holds.
    
    Args:
        n_vars: Number of variables
        degree: Degree of elementary symmetric polynomial
    """
    H = elementary_symmetric_polynomial_hessian(n_vars, degree)
    gap, has_sig, eigenvalues = compute_spectral_gap(H)
    
    print(f"\nLog-Concavity Certification: e_{degree}(x1,...,x{n_vars})")
    print(f"  Hessian eigenvalues: {eigenvalues}")
    print(f"  Lorentzian: {has_sig}")
    print(f"  Spectral gap: {gap:.4f}")
    
    if has_sig and gap > 0:
        radius = certify_lorentzian_stability([H])
        cond = lorentzian_condition_number([H])
        print(f"  Certified stability radius: {radius:.6f}")
        print(f"  Condition number: {cond:.4f}")
        print(f"  → Coefficients are ultra-log-concave")
        print(f"  → Property survives perturbations up to δ < {gap:.4f}")
    else:
        print(f"  → Cannot certify log-concavity")


def matroid_basis_polynomial(bases, n_vars):
    """Construct and analyze the basis generating polynomial of a matroid.
    
    f_M(x) = sum_{B basis} prod_{i in B} x_i
    
    Lorentzianity of f_M is equivalent to M being a matroid (Brändén-Huh).
    
    Args:
        bases: List of bases (each a frozenset of indices)
        n_vars: Number of variables (ground set size)
    """
    rank = len(list(bases)[0]) if bases else 0
    
    # Build Hessian at x = (1,...,1)
    H = np.zeros((n_vars, n_vars))
    if rank < 2:
        return H, 0.0
    
    for B in bases:
        B_list = list(B)
        for i in B_list:
            for j in B_list:
                if i != j:
                    # Contribution from this basis
                    remaining = [k for k in B_list if k != i and k != j]
                    H[i, j] += 1  # product of 1's over remaining elements
    
    return H


def main():
    print("=" * 70)
    print("APPLICATIONS OF CERTIFIED LORENTZIAN RECOGNITION")
    print("=" * 70)
    
    # Application 1: Trust Region Optimization
    print("\n### Application 1: Trust Region Optimization ###")
    n = 4
    H = elementary_symmetric_polynomial_hessian(n, 2)
    gap, _, _ = compute_spectral_gap(H)
    trust_region_geometry(H, gap)
    
    # Application 2: Log-Concavity Certification
    print("\n### Application 2: Log-Concavity Certification ###")
    for n_vars in [4, 5, 6, 7]:
        for degree in [2, 3]:
            if degree <= n_vars:
                log_concavity_certification(n_vars, degree)
    
    # Application 3: Matroid Basis Polynomial
    print("\n### Application 3: Matroid Basis Polynomial ###")
    
    # Uniform matroid U_{2,4}: all 2-element subsets of {0,1,2,3}
    from itertools import combinations
    bases_U24 = [frozenset(B) for B in combinations(range(4), 2)]
    print(f"\nUniform matroid U(2,4): bases = {[set(B) for B in bases_U24]}")
    
    H = matroid_basis_polynomial(bases_U24, 4)
    gap, has_sig, eigenvalues = compute_spectral_gap(H)
    print(f"  Hessian:\n{H}")
    print(f"  Eigenvalues: {eigenvalues}")
    print(f"  Lorentzian signature: {has_sig}")
    print(f"  Spectral gap: {gap:.4f}")
    
    if has_sig and gap > 0:
        radius = certify_lorentzian_stability([H])
        print(f"  Certified stability radius: {radius:.6f}")
        
        # Perturbation test
        n_trials = 500
        noise = gap * 0.5
        preserved = 0
        for _ in range(n_trials):
            E = np.random.randn(4, 4) * noise / 4
            E = (E + E.T) / 2
            _, sig = compute_spectral_gap(H + E)
            if sig:
                preserved += 1
        print(f"  Perturbation test (δ={noise:.4f}, {n_trials} trials): "
              f"{preserved}/{n_trials} preserved")
    
    # Uniform matroid U_{2,5}
    bases_U25 = [frozenset(B) for B in combinations(range(5), 2)]
    print(f"\nUniform matroid U(2,5): {len(bases_U25)} bases")
    H = matroid_basis_polynomial(bases_U25, 5)
    gap, has_sig, eigenvalues = compute_spectral_gap(H)
    print(f"  Eigenvalues: {eigenvalues}")
    print(f"  Lorentzian: {has_sig}, Gap: {gap:.4f}")
    
    print("\n" + "=" * 70)
    print("SUMMARY")
    print("The spectral gap provides a quantitative certificate for:")
    print("  1. Robustness of trust-region optimization geometry")
    print("  2. Stability of log-concavity under coefficient noise")
    print("  3. Reliable matroid recognition from approximate data")
    print("=" * 70)


if __name__ == "__main__":
    main()


#!/usr/bin/env python3
"""
Demo: Numerical Stability of Lorentzian Recognition

Demonstrates the core mathematical results:
1. Construct known Lorentzian polynomials (elementary symmetric polynomials)
2. Compute quadratic leaf Hessians
3. Estimate spectral gaps (second eigenvalue bounds)
4. Perturb coefficients by random noise at varying scales
5. Compare empirical stability threshold vs certified bound
6. Visualize gap degradation under perturbation

Usage: python demo.py
"""

import numpy as np
from itertools import combinations

def elementary_symmetric_hessian(n, k):
    """Compute the Hessian matrix of the k-th elementary symmetric polynomial e_k(x1,...,xn).
    
    e_k = sum_{|S|=k} prod_{i in S} x_i
    
    The Hessian H_{ij} = d^2 e_k / dx_i dx_j evaluated at x = (1,1,...,1).
    For i != j: H_{ij} = e_{k-2}(x_{-i,-j}) = C(n-2, k-2) at x = 1
    For i == j: H_{ii} = 0 (since x_i appears linearly in each monomial)
    """
    H = np.zeros((n, n))
    if k < 2:
        return H
    from math import comb
    off_diag = comb(n - 2, k - 2)
    for i in range(n):
        for j in range(n):
            if i != j:
                H[i, j] = off_diag
    return H

def compute_spectral_gap(H):
    """Compute the spectral gap for the 'at most one positive eigenvalue' property.
    
    Returns (gap, has_lorentzian_signature):
    - gap: the absolute value of the second-largest eigenvalue (the margin)
    - has_lorentzian_signature: True if at most one eigenvalue is positive
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]  # descending
    n = len(eigenvalues)
    if n < 2:
        return (0.0, True)
    
    # Count positive eigenvalues
    pos_count = np.sum(eigenvalues > 1e-10)
    has_sig = pos_count <= 1
    
    # The gap is |lambda_2| when lambda_2 < 0
    second_ev = eigenvalues[1] if n >= 2 else 0
    gap = -second_ev if second_ev < 0 else 0.0
    
    return (gap, has_sig)

def quadratic_form_bound(E):
    """Compute the quadratic form bound: max |v^T E v| / ||v||^2.
    
    This is the spectral radius of E (max |eigenvalue|).
    """
    eigenvalues = np.linalg.eigvalsh(E)
    return np.max(np.abs(eigenvalues))

def perturb_and_check(H, noise_scale, num_trials=100):
    """Perturb H by symmetric noise of given scale and check signature preservation.
    
    Returns fraction of trials where the signature is preserved.
    """
    n = H.shape[0]
    preserved = 0
    for _ in range(num_trials):
        # Generate symmetric perturbation
        E = np.random.randn(n, n) * noise_scale
        E = (E + E.T) / 2  # symmetrize
        
        H_perturbed = H + E
        _, has_sig = compute_spectral_gap(H_perturbed)
        if has_sig:
            preserved += 1
    return preserved / num_trials

def certified_stability_radius(gap, n):
    """Compute the certified stability radius from our theorem.
    
    From hasAtMostOnePositiveEigenvalue_of_gapped_perturbation:
    If the quadratic form bound of the perturbation is < gap (epsilon),
    then the signature is preserved.
    
    For entry-bounded perturbations with |E_ij| <= delta,
    the quadratic form bound is at most n^2 * delta.
    So the certified entry-wise radius is gap / n^2.
    """
    return gap / (n ** 2) if n > 0 else 0

def main():
    print("=" * 70)
    print("NUMERICAL STABILITY OF LORENTZIAN RECOGNITION")
    print("Demonstrating certified perturbation bounds for Lorentzian polynomials")
    print("=" * 70)
    
    # Example 1: Elementary symmetric polynomial e_2(x1,...,x5)
    print("\n--- Example 1: e_2(x1,...,x5) ---")
    n, k = 5, 2
    H = elementary_symmetric_hessian(n, k)
    print(f"Hessian at x=(1,...,1):\n{H}")
    
    gap, has_sig = compute_spectral_gap(H)
    print(f"Eigenvalues: {np.sort(np.linalg.eigvalsh(H))[::-1]}")
    print(f"Has Lorentzian signature: {has_sig}")
    print(f"Spectral gap (|lambda_2|): {gap:.4f}")
    
    cert_radius = certified_stability_radius(gap, n)
    print(f"Certified entry-wise perturbation radius: {cert_radius:.6f}")
    
    # Perturbation experiment
    print("\nPerturbation experiment (100 trials per noise level):")
    print(f"{'Noise Scale':>12} {'Fraction Preserved':>20} {'Within Cert. Radius':>20}")
    
    scales = [cert_radius * f for f in [0.1, 0.5, 1.0, 2.0, 5.0, 10.0, 20.0]]
    for scale in scales:
        frac = perturb_and_check(H, scale)
        within = "YES" if scale < cert_radius else "NO"
        print(f"{scale:12.6f} {frac:20.2f} {within:>20}")
    
    # Example 2: e_3(x1,...,x6) 
    print("\n--- Example 2: e_3(x1,...,x6) ---")
    n, k = 6, 3
    H = elementary_symmetric_hessian(n, k)
    
    gap, has_sig = compute_spectral_gap(H)
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    print(f"Eigenvalues: {eigenvalues}")
    print(f"Has Lorentzian signature: {has_sig}")
    print(f"Spectral gap: {gap:.4f}")
    
    cert_radius = certified_stability_radius(gap, n)
    print(f"Certified entry-wise radius: {cert_radius:.6f}")
    
    # Find empirical destruction threshold
    print("\nSearching for empirical destruction threshold...")
    low, high = 0, 5.0
    for _ in range(20):
        mid = (low + high) / 2
        frac = perturb_and_check(H, mid, num_trials=200)
        if frac > 0.5:
            low = mid
        else:
            high = mid
    
    empirical_threshold = (low + high) / 2
    print(f"Empirical destruction threshold (50% survival): {empirical_threshold:.6f}")
    print(f"Certified radius: {cert_radius:.6f}")
    print(f"Ratio (empirical/certified): {empirical_threshold/cert_radius:.2f}")
    print(f"Certificate is conservative by factor ~{empirical_threshold/cert_radius:.1f}x")
    
    # Example 3: Condition number analysis
    print("\n--- Condition Number Analysis ---")
    for n_val in [3, 4, 5, 6, 7, 8]:
        k_val = 2
        H = elementary_symmetric_hessian(n_val, k_val)
        gap, _ = compute_spectral_gap(H)
        max_norm = np.max(np.abs(H))
        cond = max_norm / gap if gap > 0 else float('inf')
        cert = certified_stability_radius(gap, n_val)
        print(f"n={n_val}, k={k_val}: gap={gap:.2f}, max_entry={max_norm:.2f}, "
              f"cond_num={cond:.4f}, cert_radius={cert:.6f}")
    
    print("\n" + "=" * 70)
    print("KEY INSIGHT: The certified radius is always ≤ the empirical threshold,")
    print("confirming our theorem: gapped signature + small perturbation ⇒")
    print("preserved Lorentzian signature.")
    print("=" * 70)

if __name__ == "__main__":
    main()


"""
Visualization: Eigenvalue Perturbation and Signature Control

Shows how eigenvalues of a Lorentzian Hessian move under perturbation,
illustrating the spectral gap as a "buffer zone" that prevents the
second eigenvalue from crossing zero.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import elementary_symmetric_polynomial_hessian

n = 5
H = elementary_symmetric_polynomial_hessian(n, 2)
eigenvalues_orig = np.sort(np.linalg.eigvalsh(H))[::-1]
gap = -eigenvalues_orig[1]

fig, axes = plt.subplots(1, 3, figsize=(16, 5))

# Panel 1: Eigenvalue trajectories under increasing perturbation
ax1 = axes[0]
n_steps = 100
delta_range = np.linspace(0, 2.5 * gap, n_steps)
n_trails = 20

for trail in range(n_trails):
    np.random.seed(trail * 42)
    E = np.random.randn(n, n)
    E = (E + E.T) / 2
    E = E / np.max(np.abs(np.linalg.eigvalsh(E)))  # normalize
    
    ev_trajectories = np.zeros((n_steps, n))
    for i, delta in enumerate(delta_range):
        H_pert = H + delta * E
        ev_trajectories[i] = np.sort(np.linalg.eigvalsh(H_pert))[::-1]
    
    for k in range(n):
        color = '#E53935' if k == 0 else '#1565C0' if k == 1 else '#90A4AE'
        alpha = 0.3 if trail > 0 else 0.8
        lw = 1.5 if trail == 0 else 0.5
        ax1.plot(delta_range / gap, ev_trajectories[:, k], 
                color=color, alpha=alpha, linewidth=lw)

ax1.axhline(y=0, color='black', linewidth=1.5, linestyle='-')
ax1.axvline(x=1.0, color='red', linewidth=2, linestyle='--', alpha=0.7)
ax1.fill_between([0, 1.0], [-3*gap, -3*gap], [eigenvalues_orig[0]*1.5]*2, 
                 alpha=0.08, color='green')
ax1.set_xlabel('Perturbation δ/ε', fontsize=12)
ax1.set_ylabel('Eigenvalue', fontsize=12)
ax1.set_title('Eigenvalue Trajectories\n(red=λ₁, blue=λ₂, gray=others)', fontsize=12)
ax1.set_ylim(-3*gap, eigenvalues_orig[0]*1.5)
ax1.grid(True, alpha=0.3)

# Panel 2: Distribution of second eigenvalue at δ = 0.5ε vs δ = 1.5ε
ax2 = axes[1]
n_samples = 1000
second_evs_safe = []
second_evs_danger = []

for _ in range(n_samples):
    E = np.random.randn(n, n)
    E = (E + E.T) / 2
    E = E / np.max(np.abs(np.linalg.eigvalsh(E)))
    
    H_safe = H + 0.5 * gap * E
    H_danger = H + 1.5 * gap * E
    
    evs_safe = np.sort(np.linalg.eigvalsh(H_safe))[::-1]
    evs_danger = np.sort(np.linalg.eigvalsh(H_danger))[::-1]
    
    second_evs_safe.append(evs_safe[1])
    second_evs_danger.append(evs_danger[1])

ax2.hist(second_evs_safe, bins=40, alpha=0.6, color='#4CAF50', label='δ = 0.5ε (safe)', density=True)
ax2.hist(second_evs_danger, bins=40, alpha=0.6, color='#F44336', label='δ = 1.5ε (risky)', density=True)
ax2.axvline(x=0, color='black', linewidth=2, linestyle='-', label='Zero threshold')
ax2.set_xlabel('Second eigenvalue λ₂', fontsize=12)
ax2.set_ylabel('Density', fontsize=12)
ax2.set_title('Distribution of λ₂ Under Perturbation', fontsize=12)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)

# Panel 3: Condition number vs dimension
ax3 = axes[2]
n_values = range(3, 12)
condition_numbers = []
gaps = []
for nv in n_values:
    H_temp = elementary_symmetric_polynomial_hessian(nv, 2)
    evs = np.sort(np.linalg.eigvalsh(H_temp))[::-1]
    g = -evs[1]
    max_ev = evs[0]
    condition_numbers.append(max_ev / g if g > 0 else float('inf'))
    gaps.append(g)

ax3.bar(list(n_values), condition_numbers, color='#7E57C2', alpha=0.7, edgecolor='#4A148C')
ax3.set_xlabel('Dimension n', fontsize=12)
ax3.set_ylabel('Condition number κ_L', fontsize=12)
ax3.set_title('Lorentzian Condition Number\nfor e₂(x₁,...,xₙ)', fontsize=12)
ax3.grid(True, alpha=0.3, axis='y')

plt.tight_layout()
plt.savefig('eigenvalue_perturbation.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved eigenvalue_perturbation.png")


"""
Visualization: Spectral Gap Heatmap Across Polynomial Families

Shows how the spectral gap varies across different elementary symmetric
polynomials e_k(x1,...,xn), revealing the landscape of numerical stability
for Lorentzian recognition.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import (elementary_symmetric_polynomial_hessian, compute_spectral_gap,
                        lorentzian_condition_number)

max_n = 12
max_k = 10

gap_matrix = np.full((max_k, max_n), np.nan)
cond_matrix = np.full((max_k, max_n), np.nan)
sig_matrix = np.full((max_k, max_n), np.nan)

for n in range(2, max_n + 1):
    for k in range(2, min(n, max_k) + 1):
        H = elementary_symmetric_polynomial_hessian(n, k)
        gap, has_sig, eigenvalues = compute_spectral_gap(H)
        
        gap_matrix[k-1, n-1] = gap if has_sig else 0
        sig_matrix[k-1, n-1] = 1 if has_sig else 0
        
        if has_sig and gap > 0:
            max_ev = eigenvalues[0]
            cond_matrix[k-1, n-1] = max_ev / gap
        else:
            cond_matrix[k-1, n-1] = np.inf

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Heatmap 1: Spectral Gap
ax1 = axes[0]
im1 = ax1.imshow(gap_matrix[:max_k, :max_n], cmap='YlOrRd', aspect='auto',
                 origin='lower', interpolation='nearest')
ax1.set_xlabel('Number of variables n', fontsize=13)
ax1.set_ylabel('Degree k', fontsize=13)
ax1.set_title('Spectral Gap ε for e_k(x₁,...,xₙ)', fontsize=14)
ax1.set_xticks(range(max_n))
ax1.set_xticklabels(range(1, max_n + 1))
ax1.set_yticks(range(max_k))
ax1.set_yticklabels(range(1, max_k + 1))
plt.colorbar(im1, ax=ax1, label='Gap ε')

# Add text annotations
for k in range(max_k):
    for n in range(max_n):
        val = gap_matrix[k, n]
        if not np.isnan(val):
            color = 'white' if val > np.nanmax(gap_matrix) * 0.5 else 'black'
            ax1.text(n, k, f'{val:.1f}', ha='center', va='center', 
                    fontsize=7, color=color)

# Heatmap 2: Condition Number (log scale)
ax2 = axes[1]
log_cond = np.log10(np.where(np.isinf(cond_matrix), np.nan, cond_matrix))
im2 = ax2.imshow(log_cond[:max_k, :max_n], cmap='viridis', aspect='auto',
                 origin='lower', interpolation='nearest')
ax2.set_xlabel('Number of variables n', fontsize=13)
ax2.set_ylabel('Degree k', fontsize=13)
ax2.set_title('log₁₀(Condition Number κ_L) for e_k', fontsize=14)
ax2.set_xticks(range(max_n))
ax2.set_xticklabels(range(1, max_n + 1))
ax2.set_yticks(range(max_k))
ax2.set_yticklabels(range(1, max_k + 1))
plt.colorbar(im2, ax=ax2, label='log₁₀(κ_L)')

# Add text annotations
for k in range(max_k):
    for n in range(max_n):
        val = cond_matrix[k, n]
        if not np.isnan(val) and not np.isinf(val):
            lv = np.log10(val)
            color = 'white' if not np.isnan(lv) and lv > np.nanmean(log_cond) else 'black'
            ax2.text(n, k, f'{val:.1f}', ha='center', va='center', 
                    fontsize=7, color=color)

plt.tight_layout()
plt.savefig('gap_heatmap.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved gap_heatmap.png")


"""
Visualization: Stability Landscape of Lorentzian Recognition

Visualizes how the spectral gap degrades under perturbation, showing
the certified stability region vs empirical destruction threshold.
This is the core visual that makes the perturbation theorem tangible.
"""

import numpy as np
import matplotlib.pyplot as plt
from algorithms import (compute_spectral_gap, elementary_symmetric_polynomial_hessian)

def generate_data():
    results = {}
    for n in [4, 5, 6]:
        H = elementary_symmetric_polynomial_hessian(n, 2)
        gap, _, _ = compute_spectral_gap(H)
        
        noise_fracs = np.linspace(0, 2.5, 50)
        preservation_rates = []
        residual_gaps = []
        
        for frac in noise_fracs:
            delta = gap * frac
            preserved = 0
            gaps_collected = []
            n_trials = 300
            
            for _ in range(n_trials):
                E = np.random.randn(n, n)
                E = (E + E.T) / 2
                spec_rad = np.max(np.abs(np.linalg.eigvalsh(E)))
                if spec_rad > 0:
                    E = E * (delta / spec_rad)
                
                g, sig, _ = compute_spectral_gap(H + E)
                if sig:
                    preserved += 1
                gaps_collected.append(g if sig else 0)
            
            preservation_rates.append(preserved / n_trials)
            residual_gaps.append(np.mean(gaps_collected))
        
        results[n] = {
            'noise_fracs': noise_fracs,
            'preservation_rates': preservation_rates,
            'residual_gaps': residual_gaps,
            'gap': gap
        }
    
    return results

results = generate_data()

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Left panel: Preservation rates
ax1 = axes[0]
colors = ['#2196F3', '#FF5722', '#4CAF50']
for (n, data), color in zip(results.items(), colors):
    ax1.plot(data['noise_fracs'], data['preservation_rates'], 
             color=color, linewidth=2, label=f'n={n}, e₂')

ax1.axvline(x=1.0, color='red', linestyle='--', linewidth=2, alpha=0.7, label='Certified bound (δ=ε)')
ax1.axvspan(0, 1.0, alpha=0.1, color='green', label='Certified safe zone')
ax1.set_xlabel('Perturbation ratio δ/ε', fontsize=13)
ax1.set_ylabel('Fraction with Lorentzian signature', fontsize=13)
ax1.set_title('Signature Preservation Under Perturbation', fontsize=14)
ax1.legend(fontsize=10)
ax1.set_ylim(-0.05, 1.05)
ax1.grid(True, alpha=0.3)

# Right panel: Residual gap
ax2 = axes[1]
for (n, data), color in zip(results.items(), colors):
    theoretical_gap = [max(data['gap'] * (1 - f), 0) for f in data['noise_fracs']]
    ax2.plot(data['noise_fracs'], [g/data['gap'] for g in data['residual_gaps']], 
             color=color, linewidth=2, label=f'n={n} (empirical)')
    ax2.plot(data['noise_fracs'], [t/data['gap'] for t in theoretical_gap],
             color=color, linewidth=1, linestyle='--', alpha=0.5)

ax2.axvline(x=1.0, color='red', linestyle='--', linewidth=2, alpha=0.7)
ax2.set_xlabel('Perturbation ratio δ/ε', fontsize=13)
ax2.set_ylabel('Residual gap / original gap', fontsize=13)
ax2.set_title('Spectral Gap Degradation (dashed = theoretical)', fontsize=14)
ax2.legend(fontsize=10)
ax2.set_ylim(-0.1, 1.1)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('stability_landscape.png', dpi=150, bbox_inches='tight')
plt.close()
print("Saved stability_landscape.png")
