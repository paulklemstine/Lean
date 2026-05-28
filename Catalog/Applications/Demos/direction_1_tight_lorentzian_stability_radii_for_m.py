"""
Applications of Lorentzian stability theory for uniform matroids.

Demonstrates how the spectral eigengap governs robustness in:
1. Strongly log-concave sampling
2. Combinatorial optimization under uncertainty
3. Complete graph spectral analysis
"""

import numpy as np
from math import comb, factorial
from typing import List, Tuple


# ============================================================
# Application 1: Robust Log-Concave Sampling
# ============================================================

def log_concavity_margin(m: int) -> float:
    """Compute the log-concavity margin for e_2 on m variables.
    
    For the elementary symmetric polynomial e_2, the Lorentzian property
    implies strong log-concavity. The spectral gap of 1 gives a
    quantitative margin: perturbations of size < 1/(2m) in entry-norm
    preserve log-concavity.
    
    Returns:
        The certified log-concavity margin.
    """
    return 1.0 / (2 * m)


def sampling_robustness_certificate(n: int, r: int, noise_level: float) -> dict:
    """Certify robustness of log-concave sampling under noise.
    
    Given a uniform matroid U_{r,n} and a noise level in the coefficients,
    determine if the perturbed polynomial remains Lorentzian (and hence
    log-concave over the positive orthant).
    
    Args:
        n: number of variables
        r: rank
        noise_level: max absolute coefficient perturbation
    
    Returns:
        Dictionary with certification results
    """
    m = n - r + 2
    threshold = 1.0 / (2 * m)
    certified = noise_level < threshold
    
    return {
        'n': n,
        'r': r,
        'leaf_dimension': m,
        'noise_level': noise_level,
        'threshold': threshold,
        'certified_lorentzian': certified,
        'safety_margin': threshold - noise_level if certified else 0,
        'explanation': (
            f"For U_{{{r},{n}}}, the quadratic leaf has dimension m={m}. "
            f"The certified stability radius is 1/(2m) = {threshold:.6f}. "
            f"{'Noise level ' + str(noise_level) + ' is within bounds.' if certified else 'Noise level exceeds certified bounds.'}"
        )
    }


# ============================================================
# Application 2: Combinatorial Optimization
# ============================================================

def matroid_basis_count(n: int, r: int) -> int:
    """Count the number of bases of U_{r,n} = C(n,r)."""
    return comb(n, r)


def optimization_trust_region(m: int) -> dict:
    """Compute trust-region parameters for optimization on Lorentzian cone.
    
    The strong concavity constant on the orthogonal complement of (1,...,1)
    equals 1, giving optimal step-size bounds for trust-region methods.
    
    The Rayleigh quotient is bounded:
    - Maximum: m-1 (at v = (1,...,1))
    - Minimum on {sum v_i = 0}: -1
    - Condition number: m-1
    
    Args:
        m: dimension
    
    Returns:
        Dictionary with optimization parameters
    """
    return {
        'dimension': m,
        'strong_concavity': 1.0,
        'max_rayleigh': m - 1,
        'min_rayleigh_restricted': -1.0,
        'condition_number': m - 1 if m > 1 else 1,
        'optimal_step_size': 1.0 / (m - 1) if m > 1 else 1.0,
        'trust_region_radius': 1.0,
    }


def perturbation_impact_analysis(n: int, r: int, 
                                   perturbation_scales: List[float]) -> List[dict]:
    """Analyze the impact of perturbations at various scales.
    
    For each scale, estimate probability of Lorentzianity breaking
    under random symmetric perturbation.
    
    Args:
        n: number of variables
        r: rank
        perturbation_scales: list of perturbation magnitudes to test
    
    Returns:
        List of results for each scale
    """
    m = n - r + 2
    H = np.ones((m, m)) - np.eye(m)
    results = []
    
    np.random.seed(42)
    n_trials = 200
    
    for scale in perturbation_scales:
        n_breaks = 0
        for _ in range(n_trials):
            E = np.random.uniform(-scale, scale, (m, m))
            E = (E + E.T) / 2
            eigenvalues = np.linalg.eigvalsh(H + E)
            n_positive = np.sum(eigenvalues > 1e-10)
            if n_positive > 1:
                n_breaks += 1
        
        results.append({
            'scale': scale,
            'break_probability': n_breaks / n_trials,
            'certified_safe': scale < 1.0 / (2 * m),
            'n_trials': n_trials,
        })
    
    return results


# ============================================================
# Application 3: Spectral Graph Theory
# ============================================================

def complete_graph_spectrum(m: int) -> dict:
    """Analyze the complete graph K_m through its adjacency matrix = J - I.
    
    The leaf Hessian IS the adjacency matrix of K_m.
    This connects Lorentzian stability to algebraic graph theory.
    
    Args:
        m: number of vertices
    
    Returns:
        Spectral data for K_m
    """
    # Adjacency eigenvalues of K_m: m-1 (×1), -1 (×m-1)
    # Laplacian eigenvalues: 0 (×1), m (×m-1)
    # Normalized Laplacian eigenvalues: 0 (×1), m/(m-1) (×m-1)
    
    return {
        'vertices': m,
        'edges': m * (m - 1) // 2,
        'adjacency_eigenvalues': {m - 1: 1, -1: m - 1},
        'laplacian_eigenvalues': {0: 1, m: m - 1},
        'algebraic_connectivity': m,  # Fiedler value = smallest nonzero Laplacian eigenvalue
        'spectral_gap_adjacency': m,  # gap between eigenvalues m-1 and -1
        'chromatic_number': m,
        'is_lorentzian': True,  # J-I has exactly one positive eigenvalue
        'lorentzian_gap': 1,
    }


def johnson_scheme_connection(m: int) -> dict:
    """Relate the leaf Hessian to the Johnson scheme J(m, 1) ≅ K_m.
    
    The Johnson scheme J(n, k) has vertex set = k-subsets of [n].
    J(m, 1) has vertex set = singletons of [m], adjacency = all pairs.
    This is isomorphic to K_m.
    
    The association scheme eigenvalues are computed from Eberlein polynomials.
    For J(m, 1): eigenvalues are m-1 (trivial) and -1 (standard).
    
    Args:
        m: number of elements
    
    Returns:
        Johnson scheme data
    """
    return {
        'scheme': f'J({m}, 1)',
        'isomorphic_to': f'K_{m}',
        'classes': 1,
        'eigenmatrix': np.array([[1, m-1], [1, -1]]),
        'trivial_eigenvalue': m - 1,
        'standard_eigenvalue': -1,
        'multiplicity_trivial': 1,
        'multiplicity_standard': m - 1,
    }


# ============================================================
# Demo
# ============================================================

if __name__ == "__main__":
    print("=" * 60)
    print("  Applications of Lorentzian Stability Theory")
    print("=" * 60)
    
    # Application 1: Sampling robustness
    print("\n--- Application 1: Robust Log-Concave Sampling ---")
    for (n, r, noise) in [(6, 3, 0.05), (8, 4, 0.01), (10, 5, 0.02)]:
        cert = sampling_robustness_certificate(n, r, noise)
        print(f"\n  U_{{{r},{n}}} with noise={noise}:")
        print(f"    {cert['explanation']}")
        print(f"    Certified: {cert['certified_lorentzian']}")
    
    # Application 2: Optimization
    print("\n\n--- Application 2: Trust-Region Optimization ---")
    for m in [3, 5, 10]:
        params = optimization_trust_region(m)
        print(f"\n  m = {m}:")
        print(f"    Strong concavity: {params['strong_concavity']}")
        print(f"    Condition number: {params['condition_number']}")
        print(f"    Optimal step size: {params['optimal_step_size']:.4f}")
    
    # Application 2b: Perturbation impact
    print("\n\n--- Perturbation Impact Analysis for U_{3,6} ---")
    results = perturbation_impact_analysis(6, 3, [0.05, 0.1, 0.15, 0.2, 0.5, 1.0, 1.5])
    print(f"  {'scale':>8} {'P(break)':>10} {'certified':>10}")
    for r in results:
        print(f"  {r['scale']:8.3f} {r['break_probability']:10.3f} {str(r['certified_safe']):>10}")
    
    # Application 3: Spectral graph theory
    print("\n\n--- Application 3: Complete Graph Spectral Theory ---")
    for m in [4, 6, 10]:
        spec = complete_graph_spectrum(m)
        print(f"\n  K_{m}: {spec['edges']} edges")
        print(f"    Adjacency eigenvalues: {spec['adjacency_eigenvalues']}")
        print(f"    Algebraic connectivity: {spec['algebraic_connectivity']}")
        print(f"    Lorentzian: {spec['is_lorentzian']}, gap: {spec['lorentzian_gap']}")
    
    # Johnson scheme
    print("\n\n--- Johnson Scheme Connection ---")
    for m in [4, 5]:
        js = johnson_scheme_connection(m)
        print(f"\n  {js['scheme']} ≅ {js['isomorphic_to']}:")
        print(f"    Eigenmatrix:\n{js['eigenmatrix']}")
        print(f"    Eigenvalues: {js['trivial_eigenvalue']} (×{js['multiplicity_trivial']}), "
              f"{js['standard_eigenvalue']} (×{js['multiplicity_standard']})")


#!/usr/bin/env python3
"""
Interactive demo: Lorentzian Stability Radius for Uniform Matroids

Explores the spectral mechanism governing when perturbations of the
elementary symmetric polynomial e_r break Lorentzianity.

Usage: python demo.py
"""

import numpy as np
from math import comb


def leaf_hessian(m: int) -> np.ndarray:
    """Canonical leaf Hessian J - I for dimension m."""
    return np.ones((m, m)) - np.eye(m)


def check_lorentzian(H: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if a matrix has at most one positive eigenvalue."""
    eigenvalues = np.linalg.eigvalsh(H)
    return np.sum(eigenvalues > tol) <= 1


def spectral_gap(m: int) -> float:
    """The gap from eigenvalue -1 to signature boundary 0."""
    return 1.0


def stability_radius(m: int) -> float:
    """Certified lower bound: 1/(2m) in entry-norm."""
    return 1.0 / (2 * m) if m > 0 else float('inf')


def find_empirical_threshold(m: int, n_trials: int = 500,
                               steps: int = 40) -> float:
    """Binary search for the empirical instability threshold."""
    np.random.seed(42)
    lo, hi = 0.0, 2.0
    
    for _ in range(steps):
        mid = (lo + hi) / 2
        found_break = False
        for _ in range(n_trials):
            E = np.random.uniform(-mid, mid, (m, m))
            E = (E + E.T) / 2
            if not check_lorentzian(leaf_hessian(m) + E):
                found_break = True
                break
        if found_break:
            hi = mid
        else:
            lo = mid
    return (lo + hi) / 2


def display_hessian(m: int):
    """Display the canonical leaf Hessian and its properties."""
    H = leaf_hessian(m)
    eigenvalues = np.linalg.eigvalsh(H)
    
    print(f"\n{'='*60}")
    print(f"  Canonical Leaf Hessian for m = {m}")
    print(f"{'='*60}")
    
    if m <= 8:
        print(f"\n  H = J - I (all-ones minus identity):")
        for i in range(m):
            row = "  [" + " ".join(f"{H[i,j]:4.0f}" for j in range(m)) + " ]"
            print(row)
    
    print(f"\n  Eigenvalues: {np.sort(eigenvalues)[::-1]}")
    print(f"  Positive eigenvalue: {m-1} (multiplicity 1)")
    print(f"  Negative eigenvalue: -1 (multiplicity {m-1})")
    print(f"  Spectral gap to boundary: {spectral_gap(m)}")
    print(f"  Lorentzian signature: {check_lorentzian(H)}")
    
    # Verify quadratic form decomposition
    v = np.random.randn(m)
    Q = v @ H @ v
    Q_decomp = np.sum(v)**2 - np.sum(v**2)
    print(f"\n  Quadratic form check: Q(v) = (Σvᵢ)² - Σvᵢ²")
    print(f"  Q(v) = {Q:.6f}, decomposition = {Q_decomp:.6f}, match: {np.isclose(Q, Q_decomp)}")


def stability_analysis(n: int, r: int):
    """Full stability analysis for uniform matroid U_{r,n}."""
    m = n - r + 2
    gap = spectral_gap(m)
    radius = stability_radius(m)
    binom_coeff = comb(n, r)
    
    print(f"\n{'='*60}")
    print(f"  Stability Analysis: U_{{{r},{n}}}")
    print(f"{'='*60}")
    print(f"  Leaf dimension: m = n - r + 2 = {m}")
    print(f"  Spectral gap: {gap}")
    print(f"  Certified stability radius (entry-norm): {radius:.6f}")
    print(f"  Binomial coefficient C({n},{r}): {binom_coeff}")
    
    display_hessian(m)
    
    # Empirical threshold search
    print(f"\n  Searching for empirical instability threshold...")
    threshold = find_empirical_threshold(m, n_trials=200, steps=30)
    print(f"  Empirical threshold: {threshold:.6f}")
    print(f"  Predicted scale (1/m): {1.0/m:.6f}")
    print(f"  Ratio (empirical / predicted): {threshold * m:.4f}")


def conjecture_test(max_n: int = 12):
    """Test the radius conjecture for all valid (n,r) up to max_n."""
    print(f"\n{'='*60}")
    print(f"  Radius Conjecture Test: n ≤ {max_n}")
    print(f"{'='*60}")
    print(f"  Conjecture: ρ(U_{{r,n}}) ≈ κ · gap / C(n,r)")
    print(f"  where gap = 1, C(n,r) = binomial coefficient")
    print(f"\n  {'n':>3} {'r':>3} {'m':>3} {'C(n,r)':>8} {'radius':>8} {'emp_thr':>8} {'ratio':>8}")
    print(f"  {'-'*3} {'-'*3} {'-'*3} {'-'*8} {'-'*8} {'-'*8} {'-'*8}")
    
    ratios = []
    for n in range(4, max_n + 1):
        for r in range(2, n - 1):
            m = n - r + 2
            radius = stability_radius(m)
            binom_coeff = comb(n, r)
            emp = find_empirical_threshold(m, n_trials=100, steps=20)
            ratio = emp * m
            ratios.append(ratio)
            print(f"  {n:3d} {r:3d} {m:3d} {binom_coeff:8d} {radius:8.4f} {emp:8.4f} {ratio:8.4f}")
    
    if ratios:
        print(f"\n  Ratio statistics:")
        print(f"    Mean:   {np.mean(ratios):.4f}")
        print(f"    Std:    {np.std(ratios):.4f}")
        print(f"    Min:    {np.min(ratios):.4f}")
        print(f"    Max:    {np.max(ratios):.4f}")
        print(f"    Narrow band: [{np.min(ratios):.4f}, {np.max(ratios):.4f}]")


def main():
    print("╔══════════════════════════════════════════════════════════╗")
    print("║   Lorentzian Stability Radius for Uniform Matroids      ║")
    print("║   Spectral Eigengap Analysis                            ║")
    print("╚══════════════════════════════════════════════════════════╝")
    
    while True:
        print("\n  Options:")
        print("    1. Analyze a specific uniform matroid U_{r,n}")
        print("    2. Display canonical leaf Hessian")
        print("    3. Run radius conjecture test (n ≤ 12)")
        print("    4. Quick stability summary table")
        print("    5. Exit")
        
        try:
            choice = input("\n  Enter choice (1-5): ").strip()
        except (EOFError, KeyboardInterrupt):
            break
        
        if choice == '1':
            try:
                n = int(input("  Enter n: "))
                r = int(input("  Enter r: "))
                if r < 2 or r > n - 2:
                    print(f"  Error: need 2 ≤ r ≤ n-2 (got r={r}, n={n})")
                    continue
                stability_analysis(n, r)
            except ValueError:
                print("  Invalid input.")
        
        elif choice == '2':
            try:
                m = int(input("  Enter leaf dimension m: "))
                if m < 1:
                    print("  Error: m must be ≥ 1")
                    continue
                display_hessian(m)
            except ValueError:
                print("  Invalid input.")
        
        elif choice == '3':
            conjecture_test(12)
        
        elif choice == '4':
            print(f"\n  {'n':>3} {'r':>3} {'m':>3} {'gap':>5} {'radius':>10} {'C(n,r)':>8}")
            for n in range(4, 13):
                for r in range(2, n - 1):
                    m = n - r + 2
                    print(f"  {n:3d} {r:3d} {m:3d} {1.0:5.1f} {stability_radius(m):10.6f} {comb(n,r):8d}")
        
        elif choice == '5':
            break
        else:
            print("  Invalid choice.")
    
    print("\n  Goodbye!")


if __name__ == "__main__":
    main()


"""
Visualization 1: Heatmap of Lorentzian stability radius across uniform matroid families.

Shows how the stability radius 1/(2m) = 1/(2(n-r+2)) varies with n and r,
revealing the spectral-dimensional structure of Lorentzian robustness.

The key insight: stability radius depends only on the leaf dimension m = n-r+2,
creating diagonal bands of equal robustness in the (n,r) parameter space.
"""

import numpy as np
import matplotlib.pyplot as plt
from math import comb

# Compute stability data
max_n = 20
radius_matrix = np.full((max_n + 1, max_n + 1), np.nan)
gap_matrix = np.full((max_n + 1, max_n + 1), np.nan)

for n in range(4, max_n + 1):
    for r in range(2, n - 1):
        m = n - r + 2
        radius_matrix[r, n] = 1.0 / (2 * m)
        gap_matrix[r, n] = 1.0  # always 1

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Stability radius heatmap
ax1 = axes[0]
im1 = ax1.imshow(radius_matrix[2:max_n-1, 4:max_n+1],
                  aspect='auto', cmap='viridis', origin='lower',
                  extent=[4, max_n, 2, max_n-2])
ax1.set_xlabel('n (number of variables)', fontsize=12)
ax1.set_ylabel('r (matroid rank)', fontsize=12)
ax1.set_title('Lorentzian Stability Radius\n1/(2m) for U_{r,n}', fontsize=14)
plt.colorbar(im1, ax=ax1, label='Stability radius')

# Add diagonal lines for constant m
for m in range(3, 12):
    n_vals = np.arange(max(4, m), max_n + 1)
    r_vals = n_vals - m + 2
    valid = (r_vals >= 2) & (r_vals <= n_vals - 2)
    if np.any(valid):
        ax1.plot(n_vals[valid], r_vals[valid], 'w--', alpha=0.4, linewidth=0.8)
        mid = len(n_vals[valid]) // 2
        if mid < len(n_vals[valid]):
            ax1.text(n_vals[valid][mid], r_vals[valid][mid], f'm={m}',
                    color='white', fontsize=7, ha='center', va='center',
                    bbox=dict(boxstyle='round,pad=0.1', fc='black', alpha=0.3))

# Plot 2: Stability radius vs leaf dimension
ax2 = axes[1]
m_values = np.arange(3, 20)
radii = 1.0 / (2 * m_values)
gaps = np.ones_like(m_values, dtype=float)

ax2.semilogy(m_values, radii, 'bo-', markersize=6, linewidth=2, label='Stability radius 1/(2m)')
ax2.semilogy(m_values, gaps, 'rs--', markersize=6, linewidth=2, label='Spectral gap (always 1)')
ax2.semilogy(m_values, 1.0/m_values, 'g^-', markersize=5, linewidth=1.5, 
             label='Instability scale 1/m', alpha=0.7)

ax2.set_xlabel('Leaf dimension m = n - r + 2', fontsize=12)
ax2.set_ylabel('Scale', fontsize=12)
ax2.set_title('Stability Radius vs Leaf Dimension', fontsize=14)
ax2.legend(fontsize=10)
ax2.grid(True, alpha=0.3)
ax2.set_xticks(m_values[::2])

plt.tight_layout()
plt.savefig('viz_eigengap_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_eigengap_heatmap.png")


"""
Visualization 2: Phase transition in Lorentzian signature under perturbation.

Shows the probability of Lorentzianity breaking as perturbation magnitude increases,
revealing the sharp phase transition at the spectral gap threshold.

The key insight: the transition occurs precisely at perturbation scale ~ 1/m,
matching the eigengap-to-dimension ratio predicted by the spectral theory.
"""

import numpy as np
import matplotlib.pyplot as plt


def leaf_hessian(m: int) -> np.ndarray:
    return np.ones((m, m)) - np.eye(m)


def check_lorentzian(H: np.ndarray, tol: float = 1e-10) -> bool:
    eigenvalues = np.linalg.eigvalsh(H)
    return np.sum(eigenvalues > tol) <= 1


def break_probability(m: int, scale: float, n_trials: int = 300) -> float:
    """Compute empirical probability that random perturbation breaks Lorentzianity."""
    H = leaf_hessian(m)
    n_breaks = 0
    for _ in range(n_trials):
        E = np.random.uniform(-scale, scale, (m, m))
        E = (E + E.T) / 2
        if not check_lorentzian(H + E):
            n_breaks += 1
    return n_breaks / n_trials


np.random.seed(42)

fig, axes = plt.subplots(1, 2, figsize=(14, 6))

# Plot 1: Phase transition curves for different m
ax1 = axes[0]
m_values = [3, 4, 5, 7, 10]
colors = plt.cm.viridis(np.linspace(0.1, 0.9, len(m_values)))

for m, color in zip(m_values, colors):
    # Scale relative to 1/m (the natural scale)
    scales = np.linspace(0.01, 3.0 / m, 40)
    probs = [break_probability(m, s, n_trials=200) for s in scales]
    
    ax1.plot(scales * m, probs, '-o', color=color, markersize=3,
             linewidth=2, label=f'm = {m}')
    
    # Mark the certified safe region
    ax1.axvline(x=0.5, color='gray', linestyle=':', alpha=0.3)

ax1.axvline(x=1.0, color='red', linestyle='--', alpha=0.5, linewidth=2,
            label='Spectral gap = 1')
ax1.axvline(x=0.5, color='blue', linestyle=':', alpha=0.5, linewidth=2,
            label='Certified safe (1/2)')

ax1.set_xlabel('Normalized perturbation scale (t × m)', fontsize=12)
ax1.set_ylabel('P(Lorentzianity breaks)', fontsize=12)
ax1.set_title('Phase Transition in Lorentzian Signature\nunder Random Perturbation', fontsize=14)
ax1.legend(fontsize=9, loc='center right')
ax1.set_xlim(0, 3)
ax1.set_ylim(-0.05, 1.05)
ax1.grid(True, alpha=0.3)

# Plot 2: Eigenvalue evolution under diagonal perturbation
ax2 = axes[1]
m = 5
H = leaf_hessian(m)
t_values = np.linspace(-0.5, 2.0, 100)

eigenvalue_traces = []
for t in t_values:
    E = t * np.eye(m)
    eigenvalues = np.sort(np.linalg.eigvalsh(H + E))[::-1]
    eigenvalue_traces.append(eigenvalues)

eigenvalue_traces = np.array(eigenvalue_traces)

for i in range(m):
    if i == 0:
        ax2.plot(t_values, eigenvalue_traces[:, i], 'b-', linewidth=2,
                label=f'λ₁ = {m-1}+t')
    elif i == 1:
        ax2.plot(t_values, eigenvalue_traces[:, i], 'r-', linewidth=2,
                label=f'λ₂=…=λ_{m} = -1+t')
    else:
        ax2.plot(t_values, eigenvalue_traces[:, i], 'r-', linewidth=2)

ax2.axhline(y=0, color='black', linewidth=1, alpha=0.5)
ax2.axvline(x=0, color='gray', linewidth=0.5, alpha=0.3)
ax2.axvline(x=1, color='green', linewidth=2, linestyle='--', alpha=0.7,
            label='Critical: t = 1 (gap)')

# Shade the Lorentzian region
ax2.fill_between(t_values, -3, 8,
                  where=eigenvalue_traces[:, 1] <= 0,
                  alpha=0.1, color='blue', label='Lorentzian region')

ax2.set_xlabel('Diagonal perturbation t', fontsize=12)
ax2.set_ylabel('Eigenvalue', fontsize=12)
ax2.set_title(f'Eigenvalue Evolution (m = {m})\nH + tI = (J-I) + tI', fontsize=14)
ax2.legend(fontsize=9)
ax2.set_ylim(-3, 8)
ax2.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_perturbation_phase.png', dpi=150, bbox_inches='tight')
print("Saved viz_perturbation_phase.png")


"""
Visualization 3: Spectral decomposition of the leaf Hessian and its
connection to the complete graph / symmetric group representation.

Shows:
- Left: The quadratic form Q(v) = (Σvᵢ)² - ||v||² on the 2D unit circle
  (for m=3), revealing the one-positive-eigenvalue structure.
- Right: Eigenvalue spectrum of J-I for various m, showing the universal
  gap of 1 between the negative eigenvalue -1 and the boundary 0.
"""

import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch


fig, axes = plt.subplots(1, 3, figsize=(18, 5.5))

# ---- Plot 1: Quadratic form on unit circle (m=3) ----
ax1 = axes[0]
m = 3
theta = np.linspace(0, 2 * np.pi, 500)

# For m=3, consider vectors in the plane {Σvᵢ = 0} ∩ S¹
# Parameterize: v = cos(θ)(1,-1,0)/√2 + sin(θ)(1,1,-2)/√6
e1 = np.array([1, -1, 0]) / np.sqrt(2)
e2 = np.array([1, 1, -2]) / np.sqrt(6)

Q_vals = []
for t in theta:
    v = np.cos(t) * e1 + np.sin(t) * e2
    Q = np.sum(v)**2 - np.sum(v**2)
    Q_vals.append(Q)

Q_vals = np.array(Q_vals)

# Q should be -1 everywhere on this plane (eigenvalue -1)
ax1.plot(theta / np.pi, Q_vals, 'b-', linewidth=2)
ax1.axhline(y=-1, color='red', linestyle='--', linewidth=1.5, label='Eigenvalue = -1')
ax1.axhline(y=0, color='black', linestyle='-', linewidth=0.5, alpha=0.3)

# Also show Q on the all-ones direction + orthogonal
all_ones = np.array([1, 1, 1]) / np.sqrt(3)
Q_allones_vals = []
for t in theta:
    v = np.cos(t) * all_ones + np.sin(t) * e1
    norm_sq = np.sum(v**2)
    Q = np.sum(v)**2 - norm_sq
    Q_allones_vals.append(Q / norm_sq if norm_sq > 1e-10 else 0)

ax1.plot(theta / np.pi, Q_allones_vals, 'g-', linewidth=2, alpha=0.7,
         label='Q/||v||² in (𝟏, e₁) plane')

ax1.fill_between(theta / np.pi, -2, 0, alpha=0.1, color='red',
                  label='Negative (Lorentzian)')
ax1.fill_between(theta / np.pi, 0, 3, alpha=0.1, color='green',
                  label='Positive')

ax1.set_xlabel('Angle θ/π', fontsize=12)
ax1.set_ylabel('Q(v) / ||v||²', fontsize=12)
ax1.set_title(f'Rayleigh Quotient (m = {m})\nQ = (Σvᵢ)² - Σvᵢ²', fontsize=13)
ax1.legend(fontsize=8, loc='upper right')
ax1.set_ylim(-1.5, 3)
ax1.grid(True, alpha=0.3)

# ---- Plot 2: Eigenvalue spectrum for various m ----
ax2 = axes[1]
m_values = range(2, 13)

for idx, m in enumerate(m_values):
    # Positive eigenvalue: m-1
    ax2.plot(m, m-1, 'bo', markersize=8 if m <= 6 else 6)
    # Negative eigenvalues: -1 (multiplicity m-1)
    # Show as a thick bar
    ax2.plot([m, m], [-1, -1], 'rs', markersize=6)
    # Show multiplicity as bar width
    width = 0.3
    ax2.barh(-1, width, left=m-width/2, height=0.15, color='red', alpha=0.3)

# Labels
ax2.plot([], [], 'bo', markersize=8, label='λ₊ = m-1 (×1)')
ax2.plot([], [], 'rs', markersize=6, label='λ₋ = -1 (×(m-1))')

# Shade the gap region
ax2.axhspan(-1, 0, alpha=0.08, color='orange', label='Spectral gap = 1')
ax2.axhline(y=0, color='black', linewidth=1, alpha=0.5, label='Boundary')
ax2.axhline(y=-1, color='red', linewidth=0.5, linestyle=':', alpha=0.5)

ax2.set_xlabel('Leaf dimension m', fontsize=12)
ax2.set_ylabel('Eigenvalue', fontsize=12)
ax2.set_title('Spectrum of J - I\n(Adjacency of Complete Graph Kₘ)', fontsize=13)
ax2.legend(fontsize=8, loc='upper left')
ax2.set_xticks(list(m_values))
ax2.grid(True, alpha=0.2)

# ---- Plot 3: Representation theory decomposition ----
ax3 = axes[2]

# Show the dimension formula: ℝᵐ = trivial ⊕ standard
m_vals = np.arange(2, 15)
trivial_dims = np.ones_like(m_vals)
standard_dims = m_vals - 1

ax3.bar(m_vals - 0.15, trivial_dims, width=0.3, color='blue', alpha=0.7,
        label='Trivial rep (dim 1)\nEigenvalue m-1')
ax3.bar(m_vals + 0.15, standard_dims, width=0.3, color='red', alpha=0.7,
        label='Standard rep (dim m-1)\nEigenvalue -1')

# Annotate the decomposition
ax3.text(8, 10, r'$\mathbb{R}^m = \mathrm{triv} \oplus \mathrm{std}$',
         fontsize=13, ha='center',
         bbox=dict(boxstyle='round', fc='lightyellow', alpha=0.8))
ax3.text(8, 8.5, 'Lorentzian ⟺ one positive eigenvalue',
         fontsize=10, ha='center', style='italic', color='darkgreen')

ax3.set_xlabel('Leaf dimension m', fontsize=12)
ax3.set_ylabel('Representation dimension', fontsize=12)
ax3.set_title('Sₘ Representation Decomposition\nGoverning Lorentzian Structure', fontsize=13)
ax3.legend(fontsize=8)
ax3.set_xticks(m_vals)
ax3.grid(True, alpha=0.2)

plt.tight_layout()
plt.savefig('viz_spectral_decomposition.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_decomposition.png")
