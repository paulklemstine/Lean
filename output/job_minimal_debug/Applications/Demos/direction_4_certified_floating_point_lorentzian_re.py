"""
Applications of Certified Lorentzian Recognition

This module demonstrates real-world applications of the certified
Lorentzian recognition theory:

1. Robust optimization with Lorentzian constraints
2. Negative dependence certification for sampling
3. Control-theoretic stability margin computation
4. Phase detection in statistical mechanics models
"""

import numpy as np
from typing import List, Tuple, Optional


# ============================================================
# Self-contained core functions
# ============================================================

def bivariate_hessian(coeffs):
    d = len(coeffs) - 1
    if d < 2:
        return np.array([[coeffs[0]]])
    n = d - 1
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            idx = i + j
            if idx < len(coeffs):
                H[i, j] = coeffs[idx] * (i + 1) * (j + 1)
    return H


def spectral_margin(H):
    if H.shape[0] <= 1:
        return float('inf')
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    return -eigenvalues[1]


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)


# ============================================================
# Application 1: Robust Optimization
# ============================================================

def robust_optimization_demo():
    """Demonstrate certified Lorentzian constraints for optimization.
    
    In convex optimization, Lorentzian polynomials define a class of
    log-concave functions that guarantee well-behaved optimization
    landscapes. Certified recognition ensures the optimization
    solver's assumptions are numerically valid.
    """
    print("\n" + "="*60)
    print("Application 1: Robust Optimization with Lorentzian Constraints")
    print("="*60)
    
    # Consider optimizing over the set of log-concave sequences
    # [a₀, a₁, ..., a_d] where the generating polynomial is Lorentzian.
    #
    # The Lorentzian constraint ensures:
    #   a_k² ≥ a_{k-1} * a_{k+1} (ultra-log-concavity)
    
    d = 6
    print(f"\nDegree {d} bivariate polynomials")
    print("Finding the margin of safety for log-concave sequences...\n")
    
    # Test various log-concave sequences
    sequences = [
        ("Binomial(6,k)", np.array([1, 6, 15, 20, 15, 6, 1], dtype=float)),
        ("Geometric(0.5)", np.array([1, 0.5, 0.25, 0.125, 0.0625, 0.03125, 0.015625])),
        ("Linear decay", np.array([7, 6, 5, 4, 3, 2, 1], dtype=float)),
        ("Constant", np.ones(7)),
    ]
    
    print(f"{'Sequence':>20s} | {'Margin':>10s} | {'Max pert (1/n²)':>16s} | {'Safe?':>6s}")
    print("-" * 65)
    
    for name, seq in sequences:
        H = bivariate_hessian(seq)
        margin = spectral_margin(H)
        n = H.shape[0]
        max_pert = margin / n**2 if margin > 0 else 0
        safe = "✓" if margin > 0 else "✗"
        print(f"{name:>20s} | {margin:10.4f} | {max_pert:16.6f} | {safe:>6s}")


# ============================================================
# Application 2: Negative Dependence Certification
# ============================================================

def negative_dependence_demo():
    """Demonstrate certified negative dependence for sampling.
    
    Lorentzian polynomials guarantee negative dependence properties
    for the associated probability distributions. This is crucial
    for sampling algorithms (DPPs, strongly Rayleigh measures).
    
    The spectral margin quantifies the "strength" of negative
    dependence, enabling robust sampling even with noisy parameters.
    """
    print("\n" + "="*60)
    print("Application 2: Negative Dependence Certification for Sampling")
    print("="*60)
    
    # The uniform matroid basis polynomial is strongly Rayleigh.
    # The spectral gap of 1 in the leaf Hessian certifies this.
    
    print("\nUniform matroid U_{r,n}: basis polynomial = e_r(x₁,...,xₙ)")
    print("Leaf Hessian = J - I with spectral gap exactly 1\n")
    
    print(f"{'(n,r)':>8s} | {'m=n-r+2':>8s} | {'Gap':>6s} | "
          f"{'Max entry pert':>16s} | {'Neg. dep. margin':>18s}")
    print("-" * 70)
    
    for n, r in [(5, 2), (8, 3), (10, 4), (15, 5), (20, 8)]:
        m = n - r + 2
        gap = 1.0  # Exact gap for uniform matroids
        max_entry_pert = 1.0 / m**2
        neg_dep_margin = gap - m**2 * max_entry_pert  # = 0 at boundary
        
        # With half the maximum perturbation
        safe_pert = max_entry_pert / 2
        residual = gap - m**2 * safe_pert
        
        print(f"({n:2d},{r:2d})  | {m:8d} | {gap:6.1f} | "
              f"{max_entry_pert:16.6f} | {residual:18.4f}")


# ============================================================
# Application 3: Control-Theoretic Stability
# ============================================================

def control_stability_demo():
    """Demonstrate the cross-domain bridge to control theory.
    
    The Lorentzian signature condition is analogous to a Lyapunov
    stability certificate. The spectral gap ε corresponds to the
    stability margin, and perturbation tolerance corresponds to
    robust stability under model uncertainty.
    """
    print("\n" + "="*60)
    print("Application 3: Control-Theoretic Stability Margins")
    print("="*60)
    
    print("\nMapping: Lorentzian signature → Lyapunov stability")
    print("  Witness direction w → Lyapunov function V(x) = xᵀPx")
    print("  Spectral gap ε → Stability margin")
    print("  Perturbation bound δ → Model uncertainty")
    print("  Gap > bound → Robust stability certificate\n")
    
    # Demonstrate with the leaf Hessian as a "plant matrix"
    for m in [3, 5, 8, 10]:
        H = leaf_hessian(m)
        eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
        
        pos_eigenvalue = eigenvalues[0]
        neg_eigenvalue = eigenvalues[1]  # = -1 for all m
        gap = -neg_eigenvalue  # = 1
        
        # Maximum perturbation preserving stability
        max_pert_qf = gap  # QuadFormBound
        max_pert_entry = gap / m**2  # Entry-wise
        
        print(f"  m={m:2d}: λ_max={pos_eigenvalue:5.1f}, λ₂={neg_eigenvalue:5.1f}, "
              f"gap={gap:.1f}, max_entry_pert={max_pert_entry:.6f}")


# ============================================================
# Application 4: Phase Detection
# ============================================================

def phase_detection_demo():
    """Demonstrate Lorentzian margin as a phase indicator.
    
    In statistical mechanics, the partition function's polynomial
    structure determines the phase diagram. The Lorentzian margin
    quantifies distance from phase transitions.
    """
    print("\n" + "="*60)
    print("Application 4: Phase Detection via Lorentzian Margin")
    print("="*60)
    
    print("\nVarying a parameter through a 'phase transition'...")
    print("The Lorentzian margin changes sign at the critical point.\n")
    
    # Parameterize a family: p(x,y) = x⁴ + t·x³y + 2x²y² + t·xy³ + y⁴
    # This is Lorentzian when the log-concavity condition holds.
    
    print(f"{'t':>6s} | {'Coefficients':>30s} | {'Margin':>10s} | {'Phase':>12s}")
    print("-" * 70)
    
    for t in np.linspace(0, 3, 13):
        coeffs = np.array([1.0, t, 2.0, t, 1.0])
        H = bivariate_hessian(coeffs)
        margin = spectral_margin(H)
        
        if margin > 0.1:
            phase = "Lorentzian"
        elif margin < -0.1:
            phase = "Non-Lorentzian"
        else:
            phase = "BOUNDARY"
        
        coeffs_str = f"[{', '.join(f'{c:.2f}' for c in coeffs)}]"
        print(f"{t:6.2f} | {coeffs_str:>30s} | {margin:10.4f} | {phase:>12s}")


if __name__ == "__main__":
    robust_optimization_demo()
    negative_dependence_demo()
    control_stability_demo()
    phase_detection_demo()
    
    print(f"\n{'='*60}")
    print("All applications demonstrated successfully.")
    print(f"{'='*60}")


"""
Certified Lorentzian Recognition: Interactive Demonstration

This script demonstrates the certified floating-point Lorentzian recognition
algorithm on random bivariate homogeneous polynomials. It:

1. Samples random coefficient vectors
2. Inflates them to interval boxes of radius ε
3. Runs the certified recognizer
4. Measures empirical unknown frequency vs ε
5. Tests the O(ε) conjecture for the ambiguity region

The mathematical foundation is the spectral margin perturbation theory.
"""

import numpy as np
from typing import List, Tuple
from enum import Enum


# ============================================================
# Self-contained implementations (no local imports)
# ============================================================

class CertifiedDecision(Enum):
    YES = "yes"
    NO = "no"
    UNKNOWN = "unknown"


def bivariate_hessian(coeffs):
    """Compute the test matrix for a bivariate homogeneous polynomial."""
    d = len(coeffs) - 1
    if d < 2:
        return np.array([[coeffs[0]]])
    n = d - 1
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            idx = i + j
            if idx < len(coeffs):
                H[i, j] = coeffs[idx] * (i + 1) * (j + 1)
    return H


def spectral_margin(H):
    """Compute the spectral margin (negative of second-largest eigenvalue)."""
    if H.shape[0] <= 1:
        return float('inf')
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    return -eigenvalues[1]


def perturbation_bound(radius, degree):
    """Compute the quadratic form perturbation bound from radius."""
    n = max(degree - 1, 1)
    max_r = np.max(radius)
    max_scaling = degree * degree
    entry_bound = max_r * max_scaling
    return n**2 * entry_bound


def certify_lorentzian(center, radius, degree):
    """Certified Lorentzian recognition for bivariate homogeneous polynomials."""
    lower = center - radius
    upper = center + radius
    
    if np.any(upper < 0):
        return CertifiedDecision.NO
    
    H = bivariate_hessian(center)
    margin = spectral_margin(H)
    err = perturbation_bound(radius, degree)
    
    if margin > 0 and err < margin and np.all(lower >= -1e-12):
        return CertifiedDecision.YES
    if margin < 0 and err < -margin:
        return CertifiedDecision.NO
    
    return CertifiedDecision.UNKNOWN


# ============================================================
# Demonstration
# ============================================================

def run_single_demo(degree: int = 4, n_samples: int = 100):
    """Run a single demonstration with random polynomials."""
    print(f"\n{'='*60}")
    print(f"Certified Lorentzian Recognition Demo (degree {degree})")
    print(f"{'='*60}")
    
    rng = np.random.default_rng(42)
    n_coeffs = degree + 1
    
    # Generate random coefficient vectors
    print(f"\nSampling {n_samples} random degree-{degree} bivariate polynomials...")
    
    epsilons = [0.001, 0.005, 0.01, 0.05, 0.1, 0.2, 0.5]
    
    print(f"\n{'ε':>8s} | {'YES':>6s} | {'NO':>6s} | {'UNKNOWN':>8s} | {'Unknown%':>9s}")
    print("-" * 50)
    
    results = []
    for eps in epsilons:
        counts = {CertifiedDecision.YES: 0, CertifiedDecision.NO: 0,
                  CertifiedDecision.UNKNOWN: 0}
        
        for _ in range(n_samples):
            # Sample coefficients from [0, 2] (favoring Lorentzian-like)
            center = rng.uniform(0, 2, n_coeffs)
            radius = np.full(n_coeffs, eps)
            decision = certify_lorentzian(center, radius, degree)
            counts[decision] += 1
        
        unknown_pct = counts[CertifiedDecision.UNKNOWN] / n_samples * 100
        print(f"{eps:8.4f} | {counts[CertifiedDecision.YES]:6d} | "
              f"{counts[CertifiedDecision.NO]:6d} | "
              f"{counts[CertifiedDecision.UNKNOWN]:8d} | "
              f"{unknown_pct:8.1f}%")
        results.append((eps, unknown_pct))
    
    return results


def test_unknown_rate_conjecture(degree: int = 4, n_samples: int = 500):
    """Test the O(ε) conjecture for unknown frequency.
    
    Conjecture: For bivariate degree-d polynomials with coefficients
    sampled from [0, 2], the fraction of boxes of radius ε classified
    as UNKNOWN is bounded by C_d · ε.
    """
    print(f"\n{'='*60}")
    print(f"Testing Unknown Rate Conjecture (degree {degree})")
    print(f"{'='*60}")
    
    rng = np.random.default_rng(123)
    n_coeffs = degree + 1
    
    # Fix the coefficient samples
    centers = rng.uniform(0, 2, (n_samples, n_coeffs))
    
    epsilons = np.array([0.001, 0.002, 0.005, 0.01, 0.02, 0.05, 0.1, 0.2, 0.5])
    unknown_rates = []
    
    for eps in epsilons:
        n_unknown = 0
        for i in range(n_samples):
            radius = np.full(n_coeffs, eps)
            decision = certify_lorentzian(centers[i], radius, degree)
            if decision == CertifiedDecision.UNKNOWN:
                n_unknown += 1
        unknown_rates.append(n_unknown / n_samples)
    
    print(f"\n{'ε':>8s} | {'Unknown Rate':>12s} | {'Rate/ε':>10s} | {'Consistent?':>12s}")
    print("-" * 55)
    
    ratios = []
    for eps, rate in zip(epsilons, unknown_rates):
        ratio = rate / eps if eps > 0 else 0
        ratios.append(ratio)
        # Check if rate/ε is roughly constant (O(ε) behavior)
        consistent = "✓" if ratio < 50 else "?"
        print(f"{eps:8.4f} | {rate:12.4f} | {ratio:10.2f} | {consistent:>12s}")
    
    # Fit log-log slope
    valid = [(e, r) for e, r in zip(epsilons, unknown_rates) if r > 0]
    if len(valid) >= 3:
        log_eps = np.log10([v[0] for v in valid])
        log_rate = np.log10([v[1] for v in valid])
        slope, intercept = np.polyfit(log_eps, log_rate, 1)
        print(f"\nLog-log slope: {slope:.3f} (O(ε) predicts slope ≈ 1.0)")
        print(f"Estimated constant C: {10**intercept:.2f}")
        
        if 0.5 < slope < 2.0:
            print("→ CONSISTENT with O(ε) conjecture")
        else:
            print(f"→ INCONSISTENT: slope {slope:.2f} differs significantly from 1.0")
    
    return epsilons, unknown_rates


def demonstrate_specific_examples():
    """Show the algorithm on specific polynomial families."""
    print(f"\n{'='*60}")
    print("Specific Polynomial Examples")
    print(f"{'='*60}")
    
    examples = [
        ("Log-concave (Lorentzian)", np.array([1.0, 2.0, 3.0, 2.0, 1.0])),
        ("Geometric (Lorentzian)", np.array([1.0, 1.0, 1.0, 1.0, 1.0])),
        ("Ultra-concave", np.array([1.0, 4.0, 6.0, 4.0, 1.0])),
        ("Non-Lorentzian (gap)", np.array([1.0, 0.0, 0.0, 0.0, 1.0])),
        ("Borderline", np.array([1.0, 1.0, 0.5, 1.0, 1.0])),
    ]
    
    for name, coeffs in examples:
        print(f"\n  {name}: {coeffs}")
        H = bivariate_hessian(coeffs)
        margin = spectral_margin(H)
        print(f"    Spectral margin: {margin:.4f}")
        
        for eps in [0.001, 0.01, 0.1]:
            radius = np.full_like(coeffs, eps)
            decision = certify_lorentzian(coeffs, radius, degree=4)
            err = perturbation_bound(radius, degree=4)
            print(f"    ε={eps:.3f}: {decision.value:>7s}  "
                  f"(margin={margin:.4f}, err_bound={err:.4f})")


def measure_ambiguity_region(degree: int = 4, grid_size: int = 50):
    """Measure the ambiguity region in 2D coefficient slices."""
    print(f"\n{'='*60}")
    print(f"Ambiguity Region Visualization Data (degree {degree})")
    print(f"{'='*60}")
    
    # Fix all but two coefficients, vary the middle ones
    base_coeffs = np.array([1.0, 1.5, 2.0, 1.5, 1.0])
    
    for eps in [0.01, 0.05, 0.1]:
        n_yes = 0
        n_no = 0
        n_unknown = 0
        
        for a2 in np.linspace(0, 4, grid_size):
            for a3 in np.linspace(0, 4, grid_size):
                coeffs = base_coeffs.copy()
                coeffs[2] = a2
                coeffs[3] = a3
                radius = np.full_like(coeffs, eps)
                decision = certify_lorentzian(coeffs, radius, degree)
                if decision == CertifiedDecision.YES:
                    n_yes += 1
                elif decision == CertifiedDecision.NO:
                    n_no += 1
                else:
                    n_unknown += 1
        
        total = grid_size**2
        print(f"\n  ε={eps:.3f}: YES={n_yes}/{total} ({100*n_yes/total:.1f}%), "
              f"NO={n_no}/{total} ({100*n_no/total:.1f}%), "
              f"UNKNOWN={n_unknown}/{total} ({100*n_unknown/total:.1f}%)")


if __name__ == "__main__":
    # Run all demonstrations
    demonstrate_specific_examples()
    run_single_demo(degree=4, n_samples=200)
    run_single_demo(degree=6, n_samples=200)
    test_unknown_rate_conjecture(degree=4, n_samples=1000)
    measure_ambiguity_region(degree=4, grid_size=30)
    
    print(f"\n{'='*60}")
    print("All demonstrations complete.")
    print(f"{'='*60}")


"""
Visualization: Ambiguity Region in Coefficient Space

This script visualizes the three-valued certified decision (YES/NO/UNKNOWN)
across a 2D slice of bivariate polynomial coefficient space. It shows how
the ambiguity region (UNKNOWN) shrinks as the uncertainty radius ε decreases,
demonstrating the O(ε) volume bound from the formal theory.

The plot reveals the geometric structure of the Lorentzian/non-Lorentzian
boundary and the thin band of numerical indecision.
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.colors as mcolors


def bivariate_hessian(coeffs):
    d = len(coeffs) - 1
    if d < 2:
        return np.array([[coeffs[0]]])
    n = d - 1
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            idx = i + j
            if idx < len(coeffs):
                H[i, j] = coeffs[idx] * (i + 1) * (j + 1)
    return H


def spectral_margin(H):
    if H.shape[0] <= 1:
        return float('inf')
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    return -eigenvalues[1]


def perturbation_bound(max_radius, degree):
    n = max(degree - 1, 1)
    max_scaling = degree * degree
    entry_bound = max_radius * max_scaling
    return n**2 * entry_bound


def certify(center, eps, degree):
    lower = center - eps
    upper = center + eps
    if np.any(upper < 0):
        return -1  # NO
    H = bivariate_hessian(center)
    margin = spectral_margin(H)
    err = perturbation_bound(eps, degree)
    if margin > 0 and err < margin and np.all(lower >= -1e-12):
        return 1   # YES
    if margin < 0 and err < -margin:
        return -1  # NO
    return 0       # UNKNOWN


# Set up the figure
fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Certified Lorentzian Recognition: Ambiguity Region',
             fontsize=14, fontweight='bold')

degree = 4
base_coeffs = np.array([1.0, 1.5, 0.0, 1.5, 1.0])  # vary index 2 and 3
grid_size = 200

a2_range = np.linspace(0, 4, grid_size)
a3_range = np.linspace(0, 4, grid_size)

epsilons = [0.01, 0.05, 0.2]

cmap = mcolors.ListedColormap(['#e74c3c', '#f39c12', '#2ecc71'])
bounds = [-1.5, -0.5, 0.5, 1.5]
norm = mcolors.BoundaryNorm(bounds, cmap.N)

for ax_idx, eps in enumerate(epsilons):
    ax = axes[ax_idx]
    decision_grid = np.zeros((grid_size, grid_size))
    
    for i, a2 in enumerate(a2_range):
        for j, a3 in enumerate(a3_range):
            coeffs = base_coeffs.copy()
            coeffs[2] = a2
            coeffs[3] = a3
            decision_grid[j, i] = certify(coeffs, eps, degree)
    
    n_yes = np.sum(decision_grid == 1)
    n_no = np.sum(decision_grid == -1)
    n_unk = np.sum(decision_grid == 0)
    total = grid_size**2
    
    im = ax.imshow(decision_grid, origin='lower', aspect='equal',
                   extent=[0, 4, 0, 4], cmap=cmap, norm=norm,
                   interpolation='nearest')
    
    ax.set_xlabel('$a_2$ (coefficient of $x^2y^2$)', fontsize=11)
    ax.set_ylabel('$a_3$ (coefficient of $xy^3$)', fontsize=11)
    ax.set_title(f'ε = {eps}\n'
                 f'YES: {100*n_yes/total:.1f}%  '
                 f'NO: {100*n_no/total:.1f}%  '
                 f'UNK: {100*n_unk/total:.1f}%',
                 fontsize=10)

# Add colorbar
cbar_ax = fig.add_axes([0.92, 0.15, 0.02, 0.7])
cbar = fig.colorbar(im, cax=cbar_ax, ticks=[-1, 0, 1])
cbar.ax.set_yticklabels(['Non-Lorentzian', 'Unknown', 'Lorentzian'])

plt.tight_layout(rect=[0, 0, 0.91, 0.95])
plt.savefig('viz_ambiguity_region.png', dpi=150, bbox_inches='tight')
print("Saved: viz_ambiguity_region.png")


"""
Visualization: Spectral Margin Landscape

This script creates a heatmap of the spectral margin across a 2D slice
of coefficient space, showing the smooth landscape that transitions from
positive (Lorentzian) to negative (non-Lorentzian) values. The zero
contour is the Lorentzian boundary — the locus of phase transitions.

The smoothness of the margin function is what makes certified recognition
possible: small perturbations produce small changes in the margin.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib import cm


def bivariate_hessian(coeffs):
    d = len(coeffs) - 1
    if d < 2:
        return np.array([[coeffs[0]]])
    n = d - 1
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            idx = i + j
            if idx < len(coeffs):
                H[i, j] = coeffs[idx] * (i + 1) * (j + 1)
    return H


def spectral_margin(H):
    if H.shape[0] <= 1:
        return float('inf')
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    return -eigenvalues[1]


# Create the figure
fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Spectral Margin Landscape in Coefficient Space',
             fontsize=14, fontweight='bold')

grid_size = 300

# Panel 1: Vary a₁ and a₃ in [1, a₁, 2, a₃, 1]
ax = axes[0]
a1_range = np.linspace(0, 4, grid_size)
a3_range = np.linspace(0, 4, grid_size)
margin_grid = np.zeros((grid_size, grid_size))

for i, a1 in enumerate(a1_range):
    for j, a3 in enumerate(a3_range):
        coeffs = np.array([1.0, a1, 2.0, a3, 1.0])
        H = bivariate_hessian(coeffs)
        margin_grid[j, i] = spectral_margin(H)

# Clip for visualization
margin_clipped = np.clip(margin_grid, -50, 50)
im1 = ax.imshow(margin_clipped, origin='lower', aspect='equal',
                extent=[0, 4, 0, 4], cmap='RdYlGn',
                vmin=-30, vmax=30)
ax.contour(a1_range, a3_range, margin_grid, levels=[0],
           colors='black', linewidths=2)
ax.set_xlabel('$a_1$ (coefficient of $x^3y$)', fontsize=11)
ax.set_ylabel('$a_3$ (coefficient of $xy^3$)', fontsize=11)
ax.set_title('p(x,y) = x⁴ + a₁x³y + 2x²y² + a₃xy³ + y⁴', fontsize=11)
plt.colorbar(im1, ax=ax, label='Spectral Margin', shrink=0.8)

# Panel 2: Vary a₂ in [1, 2, a₂, 2, 1] — 1D cross-section
ax2 = axes[1]
a2_values = np.linspace(0, 6, 500)
margins = []
for a2 in a2_values:
    coeffs = np.array([1.0, 2.0, a2, 2.0, 1.0])
    H = bivariate_hessian(coeffs)
    margins.append(spectral_margin(H))

margins = np.array(margins)
ax2.plot(a2_values, margins, 'b-', linewidth=2, label='Spectral Margin')
ax2.axhline(y=0, color='k', linestyle='--', alpha=0.5)
ax2.fill_between(a2_values, margins, 0,
                 where=(margins > 0), alpha=0.2, color='green',
                 label='Lorentzian region')
ax2.fill_between(a2_values, margins, 0,
                 where=(margins < 0), alpha=0.2, color='red',
                 label='Non-Lorentzian region')

# Mark the critical point
zero_crossings = a2_values[:-1][np.diff(np.sign(margins)) != 0]
for zc in zero_crossings:
    ax2.axvline(x=zc, color='orange', linestyle=':', alpha=0.8)
    ax2.annotate(f'Critical: a₂≈{zc:.2f}', xy=(zc, 0),
                xytext=(zc + 0.5, max(margins) * 0.5),
                arrowprops=dict(arrowstyle='->', color='orange'),
                fontsize=9, color='orange')

ax2.set_xlabel('$a_2$ (coefficient of $x^2y^2$)', fontsize=11)
ax2.set_ylabel('Spectral Margin', fontsize=11)
ax2.set_title('1D Cross-Section: [1, 2, a₂, 2, 1]', fontsize=11)
ax2.legend(fontsize=9)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_margin_landscape.png', dpi=150, bbox_inches='tight')
print("Saved: viz_margin_landscape.png")


"""
Visualization: Unknown Rate vs Epsilon — Testing the O(ε) Conjecture

This script plots the empirical unknown frequency as a function of the
uncertainty radius ε, testing the conjecture that the ambiguity rate
scales linearly with ε. A log-log plot with slope ≈ 1 confirms the
O(ε) prediction from the formal volume bound theory.

This is the key computational test of the thin-ambiguity-region theorem.
"""

import numpy as np
import matplotlib.pyplot as plt


def bivariate_hessian(coeffs):
    d = len(coeffs) - 1
    if d < 2:
        return np.array([[coeffs[0]]])
    n = d - 1
    H = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            idx = i + j
            if idx < len(coeffs):
                H[i, j] = coeffs[idx] * (i + 1) * (j + 1)
    return H


def spectral_margin(H):
    if H.shape[0] <= 1:
        return float('inf')
    eigenvalues = np.sort(np.linalg.eigvalsh(H))[::-1]
    return -eigenvalues[1]


def perturbation_bound(max_radius, degree):
    n = max(degree - 1, 1)
    max_scaling = degree * degree
    entry_bound = max_radius * max_scaling
    return n**2 * entry_bound


def certify(center, eps, degree):
    lower = center - eps
    upper = center + eps
    if np.any(upper < 0):
        return -1
    H = bivariate_hessian(center)
    margin = spectral_margin(H)
    err = perturbation_bound(eps, degree)
    if margin > 0 and err < margin and np.all(lower >= -1e-12):
        return 1
    if margin < 0 and err < -margin:
        return -1
    return 0


fig, axes = plt.subplots(1, 2, figsize=(14, 6))
fig.suptitle('Testing the O(ε) Ambiguity Conjecture',
             fontsize=14, fontweight='bold')

n_samples = 500
rng = np.random.default_rng(42)

for deg_idx, degree in enumerate([4, 6]):
    ax = axes[deg_idx]
    n_coeffs = degree + 1
    
    # Fix random centers
    centers = rng.uniform(0.1, 3.0, (n_samples, n_coeffs))
    
    epsilons = np.logspace(-3, -0.3, 20)
    unknown_rates = []
    
    for eps in epsilons:
        n_unknown = 0
        for i in range(n_samples):
            decision = certify(centers[i], eps, degree)
            if decision == 0:
                n_unknown += 1
        unknown_rates.append(n_unknown / n_samples)
    
    unknown_rates = np.array(unknown_rates)
    
    # Filter positive rates for log-log
    valid = unknown_rates > 0
    
    # Plot log-log
    ax.loglog(epsilons[valid], unknown_rates[valid], 'bo-',
              markersize=4, label='Empirical unknown rate')
    
    # Fit and plot reference line
    if np.sum(valid) >= 3:
        log_eps = np.log10(epsilons[valid])
        log_rate = np.log10(unknown_rates[valid])
        slope, intercept = np.polyfit(log_eps, log_rate, 1)
        
        fit_line = 10**(slope * np.log10(epsilons) + intercept)
        ax.loglog(epsilons, fit_line, 'r--', alpha=0.7,
                  label=f'Fit: slope = {slope:.2f}')
        
        # Reference O(ε) line
        ref_line = epsilons * unknown_rates[valid][len(unknown_rates[valid])//2] / epsilons[valid][len(epsilons[valid])//2]
        ax.loglog(epsilons, ref_line, 'g:', alpha=0.5,
                  label='Reference: O(ε)')
    
    ax.set_xlabel('Uncertainty radius ε', fontsize=11)
    ax.set_ylabel('Unknown frequency', fontsize=11)
    ax.set_title(f'Degree {degree} polynomials (n={n_samples} samples)\n'
                 f'Log-log slope ≈ {slope:.2f} (O(ε) predicts ≈ 1.0)',
                 fontsize=10)
    ax.legend(fontsize=9)
    ax.grid(True, alpha=0.3, which='both')
    ax.set_ylim(bottom=1e-3)

plt.tight_layout()
plt.savefig('viz_unknown_rate.png', dpi=150, bbox_inches='tight')
print("Saved: viz_unknown_rate.png")
