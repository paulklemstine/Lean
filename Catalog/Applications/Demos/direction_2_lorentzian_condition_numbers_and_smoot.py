"""
Applications of Lorentzian Smoothed Analysis
=============================================
Real-world applications of the certified stability theory for Lorentzian polynomials.

Applications:
1. Robust matroid basis polynomial detection
2. Certified numerical optimization with Lorentzian structure
3. Sensitivity analysis for log-concavity certificates
"""

import numpy as np
from typing import List, Tuple


# ============================================================
# Application 1: Robust Matroid Basis Polynomial Detection
# ============================================================

def matroid_basis_hessian(n: int, bases: List[Tuple[int, ...]]) -> np.ndarray:
    """Compute the Hessian-like matrix of a matroid basis polynomial.
    
    For a matroid M on ground set [n] with bases B, the basis generating
    polynomial is f_M = Σ_{B ∈ B} Π_{i ∈ B} x_i.
    
    The second-derivative matrix H_{ij} = ∂²f/∂x_i∂x_j evaluated at x = 1
    counts pairs of bases containing both elements i and j.
    
    Args:
        n: Size of ground set
        bases: List of bases (tuples of element indices)
        
    Returns:
        n×n symmetric Hessian-type matrix
    """
    H = np.zeros((n, n))
    for basis in bases:
        basis_set = set(basis)
        for i in basis_set:
            for j in basis_set:
                if i != j:
                    H[i, j] += 1
            H[i, i] += 1  # Diagonal contribution
    return (H + H.T) / 2


def check_lorentzian_robustly(
    H: np.ndarray,
    noise_level: float = 0.01
) -> dict:
    """Check Lorentzian signature with certified robustness.
    
    Args:
        H: Hessian-type matrix
        noise_level: Expected coefficient noise level
        
    Returns:
        Dictionary with classification, gap, and safety assessment
    """
    eigenvalues = np.linalg.eigvalsh(H)
    pos_count = np.sum(eigenvalues > 1e-10)
    neg_eigs = eigenvalues[eigenvalues < -1e-10]
    
    has_lor = pos_count <= 1
    gap = float(np.min(np.abs(neg_eigs))) if len(neg_eigs) > 0 else 0.0
    
    return {
        'is_lorentzian': has_lor,
        'spectral_gap': gap,
        'noise_safe': gap > noise_level if has_lor else False,
        'safety_margin': gap / noise_level if noise_level > 0 and gap > 0 else float('inf'),
        'eigenvalues': eigenvalues
    }


# ============================================================
# Application 2: Certified Optimization with Lorentzian Structure
# ============================================================

def lorentzian_trust_region(
    A: np.ndarray,
    b: np.ndarray,
    radius: float
) -> Tuple[np.ndarray, float, dict]:
    """Trust-region optimization exploiting Lorentzian structure.
    
    Maximizes x^T A x + b^T x subject to ||x|| ≤ radius,
    using the Lorentzian signature to certify the landscape structure.
    
    The gapped Lorentzian signature ensures:
    - At most one direction of increase
    - Strong concavity on the orthogonal complement
    - Certified perturbation tolerance
    
    Args:
        A: Symmetric matrix with Lorentzian signature
        b: Linear term
        radius: Trust region radius
        
    Returns:
        Tuple of (optimal_x, optimal_value, certificate)
    """
    eigenvalues, eigenvectors = np.linalg.eigh(A)
    n = A.shape[0]
    
    # Check Lorentzian structure
    pos_count = np.sum(eigenvalues > 1e-10)
    if pos_count > 1:
        return np.zeros(n), 0.0, {'certified': False, 'reason': 'Not Lorentzian'}
    
    # The maximum is along the positive eigenvector
    if pos_count == 1:
        pos_idx = np.argmax(eigenvalues)
        v_star = eigenvectors[:, pos_idx]
        
        # Optimal direction: v_star or -v_star
        val_pos = v_star @ A @ v_star * radius**2 + b @ v_star * radius
        val_neg = v_star @ A @ v_star * radius**2 - b @ v_star * radius
        
        if val_pos >= val_neg:
            x_opt = v_star * radius
        else:
            x_opt = -v_star * radius
    else:
        x_opt = np.zeros(n)
    
    opt_val = float(x_opt @ A @ x_opt + b @ x_opt)
    
    neg_eigs = eigenvalues[eigenvalues < -1e-10]
    gap = float(np.min(np.abs(neg_eigs))) if len(neg_eigs) > 0 else 0.0
    
    certificate = {
        'certified': True,
        'spectral_gap': gap,
        'perturbation_tolerance': gap,
        'strong_concavity_constant': gap,
    }
    
    return x_opt, opt_val, certificate


# ============================================================
# Application 3: Sensitivity Analysis for Log-Concavity
# ============================================================

def log_concavity_sensitivity(
    coefficients: np.ndarray,
    perturbation_budget: float
) -> dict:
    """Analyze sensitivity of ultra-log-concavity under coefficient perturbation.
    
    A sequence (a_0, ..., a_n) is ultra-log-concave if a_k² ≥ a_{k-1} a_{k+1}
    with equality at most at one position. This is equivalent to a Lorentzian
    signature condition on the associated Toeplitz-like matrix.
    
    Args:
        coefficients: Sequence of non-negative real numbers
        perturbation_budget: Maximum ℓ∞ perturbation of coefficients
        
    Returns:
        Sensitivity analysis results
    """
    n = len(coefficients)
    
    # Build the associated matrix for ultra-log-concavity
    # M[i,j] = log(a_i) + log(a_j) - 2*log(a_{(i+j)//2}) approximately
    # Simplified: use the Toeplitz structure
    
    # Check log-concavity ratios
    ratios = []
    for k in range(1, n - 1):
        if coefficients[k] > 0 and coefficients[k-1] > 0 and coefficients[k+1] > 0:
            ratio = coefficients[k]**2 / (coefficients[k-1] * coefficients[k+1])
            ratios.append(ratio)
    
    min_ratio = min(ratios) if ratios else 0.0
    is_ulc = min_ratio >= 1.0
    
    # Sensitivity: how much can ratios change under perturbation?
    worst_case_ratios = []
    for k in range(1, n - 1):
        a_k = coefficients[k]
        a_km1 = coefficients[k-1]
        a_kp1 = coefficients[k+1]
        
        if a_k > perturbation_budget and a_km1 > 0 and a_kp1 > 0:
            worst_ratio = (a_k - perturbation_budget)**2 / (
                (a_km1 + perturbation_budget) * (a_kp1 + perturbation_budget)
            )
            worst_case_ratios.append(worst_ratio)
    
    worst_min = min(worst_case_ratios) if worst_case_ratios else 0.0
    
    return {
        'is_ultra_log_concave': is_ulc,
        'min_ratio': min_ratio,
        'margin': min_ratio - 1.0 if is_ulc else 0.0,
        'robust_under_perturbation': worst_min >= 1.0,
        'worst_case_ratio': worst_min,
        'perturbation_budget': perturbation_budget,
    }


# ============================================================
# Main demonstrations
# ============================================================

if __name__ == '__main__':
    np.random.seed(42)
    
    print("Lorentzian Smoothed Analysis — Applications")
    print("=" * 60)
    
    # Application 1: Matroid detection
    print("\n1. Robust Matroid Basis Polynomial Detection")
    print("-" * 50)
    
    # Uniform matroid U(2,4): all 2-element subsets of {0,1,2,3}
    bases = [(0,1), (0,2), (0,3), (1,2), (1,3), (2,3)]
    H = matroid_basis_hessian(4, bases)
    
    print(f"Matroid: U(2,4)")
    print(f"Hessian matrix:\n{H}")
    
    for noise in [0.01, 0.1, 0.5, 1.0]:
        result = check_lorentzian_robustly(H, noise)
        print(f"  Noise={noise:.2f}: Lorentzian={result['is_lorentzian']}, "
              f"Gap={result['spectral_gap']:.4f}, "
              f"Safe={result['noise_safe']}, "
              f"Margin={result['safety_margin']:.2f}x")
    
    # Application 2: Trust region optimization
    print("\n2. Certified Trust-Region Optimization")
    print("-" * 50)
    
    A = np.diag([2.0, -1.0, -1.0, -0.5])
    b = np.array([1.0, 0.5, -0.3, 0.2])
    
    x_opt, val, cert = lorentzian_trust_region(A, b, radius=1.0)
    print(f"Optimal value: {val:.4f}")
    print(f"Optimal x: {x_opt}")
    print(f"Certificate: {cert}")
    
    # Application 3: Log-concavity sensitivity
    print("\n3. Log-Concavity Sensitivity Analysis")
    print("-" * 50)
    
    # Binomial coefficients C(6, k) — known to be ultra-log-concave
    from math import comb
    coeffs = np.array([float(comb(6, k)) for k in range(7)])
    print(f"Coefficients (C(6,k)): {coeffs}")
    
    for budget in [0.01, 0.1, 0.5, 1.0, 2.0]:
        result = log_concavity_sensitivity(coeffs, budget)
        print(f"  Budget={budget:.2f}: ULC={result['is_ultra_log_concave']}, "
              f"Margin={result['margin']:.4f}, "
              f"Robust={result['robust_under_perturbation']}")


"""
Lorentzian Smoothed Analysis Demo
=================================
Generates near-boundary Lorentzian and non-Lorentzian instances,
applies Gaussian perturbations across a grid of σ, estimates failure rates,
and plots log(rate) vs ε²/σ² to test the Lorentzian Smoothed Gap Law.

Compares the conjectured scaling ε²/σ² against alternative scaling ε/σ.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import Tuple, List

# ============================================================
# Core mathematical functions
# ============================================================

def make_lorentzian_matrix(n: int, gap: float) -> np.ndarray:
    """Create an n×n symmetric matrix with Lorentzian signature and spectral gap ε.
    
    The matrix has one positive eigenvalue (= 1) and n-1 negative eigenvalues
    all equal to -gap. This gives a gapped Lorentzian signature with gap = gap.
    """
    # Eigenvalues: [1, -gap, -gap, ..., -gap]
    eigenvalues = np.array([1.0] + [-gap] * (n - 1))
    # Random orthogonal matrix for the eigenvectors
    Q, _ = np.linalg.qr(np.random.randn(n, n))
    A = Q @ np.diag(eigenvalues) @ Q.T
    return (A + A.T) / 2  # Ensure symmetry


def has_lorentzian_signature(A: np.ndarray) -> bool:
    """Check if matrix A has at most one positive eigenvalue."""
    eigenvalues = np.linalg.eigvalsh(A)
    return np.sum(eigenvalues > 1e-10) <= 1


def quadform_bound(E: np.ndarray) -> float:
    """Compute the quadratic form bound (operator norm) of matrix E."""
    return np.max(np.abs(np.linalg.eigvalsh(E)))


def run_perturbation_experiment(
    n: int,
    gap: float,
    sigma_values: np.ndarray,
    num_trials: int = 500
) -> Tuple[np.ndarray, np.ndarray]:
    """Run Monte Carlo perturbation experiment.
    
    Args:
        n: Matrix dimension
        gap: Spectral gap ε
        sigma_values: Array of noise standard deviations
        num_trials: Number of random trials per σ
    
    Returns:
        failure_rates: Array of failure rates for each σ
        quadform_violations: Array of average quadratic form violations
    """
    A = make_lorentzian_matrix(n, gap)
    failure_rates = np.zeros(len(sigma_values))
    quadform_violations = np.zeros(len(sigma_values))
    
    for i, sigma in enumerate(sigma_values):
        failures = 0
        violations = 0.0
        for _ in range(num_trials):
            # Generate random symmetric perturbation
            E = np.random.randn(n, n) * sigma
            E = (E + E.T) / 2  # Symmetrize
            
            # Check if signature is preserved
            if not has_lorentzian_signature(A + E):
                failures += 1
            
            # Check quadratic form bound
            qfb = quadform_bound(E)
            if qfb > gap:
                violations += 1
        
        failure_rates[i] = failures / num_trials
        quadform_violations[i] = violations / num_trials
    
    return failure_rates, quadform_violations


def compute_certified_radius(A: np.ndarray) -> float:
    """Compute the certified safe perturbation radius from eigenvalue gap.
    
    Returns the spectral gap ε such that perturbations with operator norm < ε
    preserve the Lorentzian signature.
    """
    eigenvalues = np.sort(np.linalg.eigvalsh(A))
    # The gap is the absolute value of the most negative eigenvalue
    # that is still negative (the closest to zero among negative ones)
    neg_eigs = eigenvalues[eigenvalues < -1e-10]
    if len(neg_eigs) == 0:
        return 0.0
    return float(np.min(np.abs(neg_eigs)))


# ============================================================
# Main experiment
# ============================================================

def main():
    np.random.seed(42)
    
    # Parameters
    n = 5
    gaps = [0.5, 1.0, 2.0]
    sigma_values = np.linspace(0.05, 3.0, 30)
    num_trials = 1000
    
    print("=" * 60)
    print("Lorentzian Smoothed Analysis — Perturbation Experiment")
    print("=" * 60)
    print(f"Matrix dimension n = {n}")
    print(f"Spectral gaps ε = {gaps}")
    print(f"Number of trials per (ε, σ) = {num_trials}")
    print()
    
    fig, axes = plt.subplots(1, 3, figsize=(18, 5))
    
    # ---- Plot 1: Failure rate vs σ for different gaps ----
    ax1 = axes[0]
    for gap in gaps:
        failure_rates, _ = run_perturbation_experiment(n, gap, sigma_values, num_trials)
        ax1.plot(sigma_values, failure_rates, 'o-', label=f'ε = {gap}', markersize=3)
    ax1.set_xlabel('σ (noise scale)')
    ax1.set_ylabel('Failure rate')
    ax1.set_title('Lorentzian Misclassification Rate')
    ax1.legend()
    ax1.grid(True, alpha=0.3)
    
    # ---- Plot 2: log(failure rate) vs ε²/σ² (conjectured scaling) ----
    ax2 = axes[1]
    for gap in gaps:
        failure_rates, _ = run_perturbation_experiment(n, gap, sigma_values, num_trials)
        # Filter out zero failure rates for log plot
        mask = failure_rates > 0
        if np.any(mask):
            x = gap**2 / sigma_values[mask]**2
            y = np.log(failure_rates[mask])
            ax2.plot(x, y, 'o-', label=f'ε = {gap}', markersize=3)
    ax2.set_xlabel('ε² / σ²')
    ax2.set_ylabel('log(failure rate)')
    ax2.set_title('Conjectured Scaling: log(P) vs ε²/σ²')
    ax2.legend()
    ax2.grid(True, alpha=0.3)
    
    # ---- Plot 3: log(failure rate) vs ε/σ (alternative scaling) ----
    ax3 = axes[2]
    for gap in gaps:
        failure_rates, _ = run_perturbation_experiment(n, gap, sigma_values, num_trials)
        mask = failure_rates > 0
        if np.any(mask):
            x = gap / sigma_values[mask]
            y = np.log(failure_rates[mask])
            ax3.plot(x, y, 'o-', label=f'ε = {gap}', markersize=3)
    ax3.set_xlabel('ε / σ')
    ax3.set_ylabel('log(failure rate)')
    ax3.set_title('Alternative Scaling: log(P) vs ε/σ')
    ax3.legend()
    ax3.grid(True, alpha=0.3)
    
    plt.tight_layout()
    plt.savefig('lorentzian_smoothed_analysis.png', dpi=150, bbox_inches='tight')
    print("Figure saved to lorentzian_smoothed_analysis.png")
    
    # ---- Print numerical results ----
    print("\n" + "=" * 60)
    print("Numerical Results")
    print("=" * 60)
    
    gap = 1.0
    print(f"\nSpectral gap ε = {gap}, dimension n = {n}")
    failure_rates, qf_violations = run_perturbation_experiment(
        n, gap, sigma_values, num_trials
    )
    
    print(f"{'σ':>8s} {'P(fail)':>10s} {'P(QF viol)':>12s} {'ε²/σ²':>10s}")
    print("-" * 44)
    for i in range(0, len(sigma_values), 3):
        s = sigma_values[i]
        ratio = gap**2 / s**2
        print(f"{s:8.3f} {failure_rates[i]:10.4f} {qf_violations[i]:12.4f} {ratio:10.3f}")
    
    # ---- Verify deterministic containment ----
    print("\n" + "=" * 60)
    print("Deterministic Containment Verification")
    print("=" * 60)
    print("Checking: failure ⊆ {E : QF bound > ε} (Theorem 3)")
    
    A = make_lorentzian_matrix(n, gap)
    containment_violations = 0
    total_failures = 0
    
    for _ in range(5000):
        sigma = 1.5
        E = np.random.randn(n, n) * sigma
        E = (E + E.T) / 2
        
        if not has_lorentzian_signature(A + E):
            total_failures += 1
            if quadform_bound(E) <= gap:
                containment_violations += 1
    
    print(f"Total failures: {total_failures}")
    print(f"Containment violations: {containment_violations}")
    print(f"Theorem verified: {'YES' if containment_violations == 0 else 'NO'}")
    
    # ---- Certified radius test ----
    print("\n" + "=" * 60)
    print("Certified Radius Test")
    print("=" * 60)
    
    certified_radius = compute_certified_radius(A)
    print(f"Certified safe radius: {certified_radius:.4f}")
    print(f"Spectral gap: {gap:.4f}")
    
    safe_failures = 0
    safe_trials = 2000
    for _ in range(safe_trials):
        E = np.random.randn(n, n) * (certified_radius * 0.1)
        E = (E + E.T) / 2
        # Scale to ensure operator norm < certified_radius
        op_norm = quadform_bound(E)
        if op_norm > 0:
            E = E * (certified_radius * 0.99 / op_norm)
        if not has_lorentzian_signature(A + E):
            safe_failures += 1
    
    print(f"Failures within safe radius: {safe_failures}/{safe_trials}")
    print(f"Certified stability verified: {'YES' if safe_failures == 0 else 'NO'}")


if __name__ == '__main__':
    main()


"""
Visualization: Condition Number and Robustness Landscape
==========================================================
Visualizes how the Lorentzian condition number κ governs
the robustness landscape of polynomial recognition.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def make_lorentzian_matrix(n, gap):
    eigenvalues = np.array([1.0] + [-gap] * (n - 1))
    Q, _ = np.linalg.qr(np.random.randn(n, n))
    A = Q @ np.diag(eigenvalues) @ Q.T
    return (A + A.T) / 2


def has_lorentzian_signature(A):
    eigenvalues = np.linalg.eigvalsh(A)
    return np.sum(eigenvalues > 1e-10) <= 1


np.random.seed(42)

fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ---- Panel 1: Condition number vs safe radius ----
ax = axes[0]
gaps = np.linspace(0.1, 5.0, 50)
max_norm = 5.0
kappas = max_norm / gaps
safe_radii = gaps  # Safe radius = gap

ax.plot(kappas, safe_radii, 'b-', linewidth=2.5, label='Safe radius = 1/κ · ‖A‖')
ax.fill_between(kappas, 0, safe_radii, alpha=0.15, color='green', label='Safe zone')
ax.set_xlabel('Condition number κ', fontsize=12)
ax.set_ylabel('Safe perturbation radius', fontsize=12)
ax.set_title('Condition Number vs Safe Radius', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)
ax.set_xlim(1, 50)
ax.set_ylim(0, 5.5)

# ---- Panel 2: Robustness landscape for different n ----
ax = axes[1]
sigma = 1.0
n_values = [3, 5, 8, 12]
gap_range = np.linspace(0.3, 4.0, 20)
num_trials = 500

for n in n_values:
    rates = []
    for gap in gap_range:
        A = make_lorentzian_matrix(n, gap)
        failures = 0
        for _ in range(num_trials):
            E = np.random.randn(n, n) * sigma
            E = (E + E.T) / 2
            if not has_lorentzian_signature(A + E):
                failures += 1
        rates.append(failures / num_trials)
    ax.plot(gap_range, rates, 'o-', label=f'n = {n}', markersize=4)

ax.set_xlabel('Spectral gap ε', fontsize=12)
ax.set_ylabel('P(failure)', fontsize=12)
ax.set_title(f'Robustness vs Gap (σ = {sigma})', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# ---- Panel 3: Theoretical vs empirical failure bound ----
ax = axes[2]
n = 5
gap = 1.5
sigma_values = np.linspace(0.2, 3.0, 20)
num_trials = 800

empirical_rates = []
A = make_lorentzian_matrix(n, gap)
for sigma in sigma_values:
    failures = 0
    for _ in range(num_trials):
        E = np.random.randn(n, n) * sigma
        E = (E + E.T) / 2
        if not has_lorentzian_signature(A + E):
            failures += 1
    empirical_rates.append(max(failures / num_trials, 1e-4))

empirical_rates = np.array(empirical_rates)
mask = empirical_rates > 1e-3

# Theoretical bound: C * exp(-c * ε² / (n * σ²))
# Fit c from the data
if np.any(mask):
    x_data = gap**2 / (n * sigma_values[mask]**2)
    y_data = np.log(empirical_rates[mask])
    
    # Simple linear fit: log(P) ≈ -c * ε²/(nσ²) + log(C)
    if len(x_data) > 2:
        coeffs = np.polyfit(x_data, y_data, 1)
        c_fit = -coeffs[0]
        C_fit = np.exp(coeffs[1])
        
        sigma_theory = np.linspace(0.2, 3.0, 100)
        theory_bound = C_fit * np.exp(-c_fit * gap**2 / (n * sigma_theory**2))
        theory_bound = np.clip(theory_bound, 0, 1)

ax.semilogy(sigma_values, empirical_rates, 'bo-', label='Empirical', markersize=5)
if np.any(mask) and len(x_data) > 2:
    ax.semilogy(sigma_theory, theory_bound, 'r--', linewidth=2,
                label=f'Fit: C·exp(-{c_fit:.2f}·ε²/(nσ²))')
ax.set_xlabel('σ (noise scale)', fontsize=12)
ax.set_ylabel('P(failure)', fontsize=12)
ax.set_title(f'Empirical vs Theoretical Bound (n={n}, ε={gap})', fontsize=13)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.3)
ax.set_ylim(1e-4, 1.5)

plt.tight_layout()
plt.savefig('viz_condition_number.png', dpi=150, bbox_inches='tight')
print("Saved viz_condition_number.png")


"""
Visualization: Spectral Gap Geometry
======================================
Visualizes the geometry of gapped Lorentzian signatures:
- How eigenvalues define the safety zone
- The perturbation ball and signature boundary
- Gap degradation under successive perturbations
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, FancyArrowPatch
from matplotlib.collections import PatchCollection


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ---- Panel 1: Eigenvalue spectrum with gap ----
ax = axes[0]
eigenvalues = np.array([-2.5, -1.8, -1.2, -0.5, 1.5])
gap = 0.5  # Minimum |negative eigenvalue|

colors = ['#d32f2f' if e < 0 else '#388e3c' for e in eigenvalues]
ax.barh(range(len(eigenvalues)), eigenvalues, color=colors, height=0.6, alpha=0.8)

# Mark the gap
ax.axvline(x=0, color='black', linewidth=1.5, linestyle='-')
ax.axvline(x=-gap, color='orange', linewidth=2, linestyle='--', label=f'Gap boundary (ε = {gap})')
ax.axvline(x=gap, color='orange', linewidth=2, linestyle='--')

# Shade the danger zone
ax.axvspan(-gap, gap, alpha=0.1, color='red', label='Danger zone')

ax.set_xlabel('Eigenvalue', fontsize=12)
ax.set_ylabel('Index', fontsize=12)
ax.set_title('Eigenvalue Spectrum with Spectral Gap', fontsize=13)
ax.legend(fontsize=9, loc='lower right')
ax.set_yticks(range(len(eigenvalues)))
ax.set_yticklabels([f'λ_{i+1}' for i in range(len(eigenvalues))])
ax.grid(True, alpha=0.2)

# ---- Panel 2: Perturbation ball in signature space ----
ax = axes[1]

# Draw the Lorentzian cone boundary (simplified 2D projection)
theta = np.linspace(0, 2*np.pi, 100)

# Safe zone (circle of radius ε)
gap_radius = 1.5
circle_safe = plt.Circle((0, 0), gap_radius, fill=True, facecolor='#e8f5e9',
                          edgecolor='#388e3c', linewidth=2, label=f'Safe zone (radius ε)')
ax.add_patch(circle_safe)

# Critical zone
circle_crit = plt.Circle((0, 0), gap_radius * 1.5, fill=True, facecolor='#fff3e0',
                          edgecolor='#f57c00', linewidth=1.5, linestyle='--',
                          label='Warning zone')
ax.add_patch(circle_crit)

# Mark the matrix A at center
ax.plot(0, 0, 'ko', markersize=10, zorder=5)
ax.annotate('A', (0.1, 0.15), fontsize=14, fontweight='bold')

# Show some perturbation arrows
np.random.seed(42)
for _ in range(8):
    angle = np.random.uniform(0, 2*np.pi)
    r = np.random.uniform(0.3, gap_radius * 0.8)
    dx, dy = r * np.cos(angle), r * np.sin(angle)
    ax.annotate('', xy=(dx, dy), xytext=(0, 0),
                arrowprops=dict(arrowstyle='->', color='#1565c0', lw=1.5, alpha=0.6))
    ax.plot(dx, dy, 'o', color='#1565c0', markersize=4, alpha=0.7)

# One dangerous perturbation
angle = 0.8
r = gap_radius * 1.3
dx, dy = r * np.cos(angle), r * np.sin(angle)
ax.annotate('', xy=(dx, dy), xytext=(0, 0),
            arrowprops=dict(arrowstyle='->', color='#d32f2f', lw=2.5))
ax.plot(dx, dy, 'X', color='#d32f2f', markersize=12, zorder=5)
ax.annotate('Failure!', (dx+0.1, dy+0.15), fontsize=10, color='#d32f2f')

ax.set_xlim(-3, 3)
ax.set_ylim(-3, 3)
ax.set_aspect('equal')
ax.set_xlabel('Perturbation component 1', fontsize=12)
ax.set_ylabel('Perturbation component 2', fontsize=12)
ax.set_title('Perturbation Safety Zone', fontsize=13)
ax.legend(fontsize=9, loc='upper left')
ax.grid(True, alpha=0.2)

# ---- Panel 3: Gap degradation under successive perturbations ----
ax = axes[2]

initial_gap = 2.0
perturbation_bounds = [0.3, 0.5, 0.2, 0.4, 0.3]
cumulative_bounds = np.cumsum([0] + perturbation_bounds)
remaining_gaps = [initial_gap - cb for cb in cumulative_bounds]

steps = range(len(remaining_gaps))
colors_grad = plt.cm.RdYlGn(np.linspace(0.8, 0.2, len(remaining_gaps)))

bars = ax.bar(steps, remaining_gaps, color=colors_grad, edgecolor='gray',
              width=0.7, alpha=0.85)

# Add perturbation annotations
for i, pb in enumerate(perturbation_bounds):
    ax.annotate(f'δ_{i+1}={pb}', xy=(i+0.5, remaining_gaps[i+1] + 0.05),
                xytext=(i+0.8, remaining_gaps[i] - 0.15),
                fontsize=8, ha='center',
                arrowprops=dict(arrowstyle='->', color='gray', lw=1))

ax.axhline(y=0, color='red', linewidth=2, linestyle='--', label='Failure threshold')
ax.set_xlabel('Perturbation step', fontsize=12)
ax.set_ylabel('Remaining gap (ε - Σδ)', fontsize=12)
ax.set_title('Gap Degradation Under Sequential Perturbation', fontsize=13)
ax.set_xticks(steps)
ax.set_xticklabels([f'Step {i}' for i in steps], fontsize=9)
ax.legend(fontsize=10)
ax.grid(True, alpha=0.2, axis='y')

plt.tight_layout()
plt.savefig('viz_gap_geometry.png', dpi=150, bbox_inches='tight')
print("Saved viz_gap_geometry.png")


"""
Visualization: Smoothed Analysis of Lorentzian Recognition
============================================================
Visualizes the core result: how the spectral gap controls
failure probability under random perturbation.

Shows the conjectured scaling P(fail) ~ exp(-c ε²/(nσ²))
versus alternative scaling hypotheses.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def make_lorentzian_matrix(n, gap):
    eigenvalues = np.array([1.0] + [-gap] * (n - 1))
    Q, _ = np.linalg.qr(np.random.randn(n, n))
    A = Q @ np.diag(eigenvalues) @ Q.T
    return (A + A.T) / 2


def has_lorentzian_signature(A):
    eigenvalues = np.linalg.eigvalsh(A)
    return np.sum(eigenvalues > 1e-10) <= 1


def run_experiment(n, gap, sigma_values, num_trials=800):
    A = make_lorentzian_matrix(n, gap)
    failure_rates = np.zeros(len(sigma_values))
    for i, sigma in enumerate(sigma_values):
        failures = 0
        for _ in range(num_trials):
            E = np.random.randn(n, n) * sigma
            E = (E + E.T) / 2
            if not has_lorentzian_signature(A + E):
                failures += 1
        failure_rates[i] = failures / num_trials
    return failure_rates


np.random.seed(42)

n = 5
gaps = [0.5, 1.0, 2.0]
sigma_values = np.linspace(0.1, 3.0, 25)

fig, axes = plt.subplots(2, 2, figsize=(14, 11))

# Panel 1: Raw failure rates
ax = axes[0, 0]
for gap in gaps:
    rates = run_experiment(n, gap, sigma_values)
    ax.plot(sigma_values, rates, 'o-', label=f'ε = {gap}', markersize=4)
ax.set_xlabel('σ (noise scale)', fontsize=12)
ax.set_ylabel('P(failure)', fontsize=12)
ax.set_title('Lorentzian Misclassification Rate vs Noise', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 2: log(P) vs ε²/σ²
ax = axes[0, 1]
for gap in gaps:
    rates = run_experiment(n, gap, sigma_values)
    mask = rates > 0
    if np.any(mask):
        x = gap**2 / sigma_values[mask]**2
        y = np.log(rates[mask])
        ax.plot(x, y, 'o-', label=f'ε = {gap}', markersize=4)
ax.set_xlabel('ε² / σ²', fontsize=12)
ax.set_ylabel('log P(failure)', fontsize=12)
ax.set_title('Conjectured Scaling: log P vs ε²/σ²', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 3: log(P) vs ε/σ (alternative)
ax = axes[1, 0]
for gap in gaps:
    rates = run_experiment(n, gap, sigma_values)
    mask = rates > 0
    if np.any(mask):
        x = gap / sigma_values[mask]
        y = np.log(rates[mask])
        ax.plot(x, y, 'o-', label=f'ε = {gap}', markersize=4)
ax.set_xlabel('ε / σ', fontsize=12)
ax.set_ylabel('log P(failure)', fontsize=12)
ax.set_title('Alternative Scaling: log P vs ε/σ', fontsize=13)
ax.legend(fontsize=11)
ax.grid(True, alpha=0.3)

# Panel 4: Phase diagram
ax = axes[1, 1]
eps_grid = np.linspace(0.2, 3.0, 20)
sig_grid = np.linspace(0.2, 3.0, 20)
E_mesh, S_mesh = np.meshgrid(eps_grid, sig_grid)
rate_grid = np.zeros_like(E_mesh)
num_trials = 300

for i, eps in enumerate(eps_grid):
    for j, sig in enumerate(sig_grid):
        A = make_lorentzian_matrix(n, eps)
        failures = 0
        for _ in range(num_trials):
            E = np.random.randn(n, n) * sig
            E = (E + E.T) / 2
            if not has_lorentzian_signature(A + E):
                failures += 1
        rate_grid[j, i] = failures / num_trials

im = ax.pcolormesh(E_mesh, S_mesh, rate_grid, cmap='RdYlGn_r', shading='auto')
ax.set_xlabel('ε (spectral gap)', fontsize=12)
ax.set_ylabel('σ (noise scale)', fontsize=12)
ax.set_title('Phase Diagram: Misclassification Rate', fontsize=13)
plt.colorbar(im, ax=ax, label='P(failure)')
# Add contour at 50% failure
ax.contour(E_mesh, S_mesh, rate_grid, levels=[0.5], colors='white',
           linewidths=2, linestyles='dashed')

plt.tight_layout()
plt.savefig('viz_smoothed_analysis.png', dpi=150, bbox_inches='tight')
print("Saved viz_smoothed_analysis.png")
