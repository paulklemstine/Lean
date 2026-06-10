#!/usr/bin/env python3
"""
applications.py — Real-world Applications of Lorentzian Condition Numbers

Demonstrates applications of the condition number theory to:
1. Certified robustness of polynomial perturbations
2. MCMC mixing time estimation via contraction surrogates
3. Matroid sampling quality assessment
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from typing import List, Tuple


def leaf_hessian(m: int) -> np.ndarray:
    """Canonical leaf Hessian J - I."""
    return np.ones((m, m)) - np.eye(m)


def spectral_gap(H: np.ndarray) -> float:
    """Minimum absolute value of negative eigenvalues."""
    eigs = np.linalg.eigvalsh(H)
    neg = eigs[eigs < -1e-12]
    return float(np.min(np.abs(neg))) if len(neg) > 0 else 0.0


def operator_norm(H: np.ndarray) -> float:
    """Largest absolute eigenvalue."""
    return float(np.max(np.abs(np.linalg.eigvalsh(H))))


def has_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> bool:
    """Check at most one positive eigenvalue."""
    return int(np.sum(np.linalg.eigvalsh(H) > tol)) <= 1


# =============================================================================
# Application 1: Certified Robustness Certificate
# =============================================================================

def robustness_certificate(m: int, n_trials: int = 500) -> dict:
    """Generate a robustness certificate for the uniform matroid.
    
    Computes the certified safe perturbation radius and validates it
    empirically with random perturbation tests.
    """
    H = leaf_hessian(m)
    gap = spectral_gap(H)
    opn = operator_norm(H)
    kappa = opn / gap
    
    certified_entry_radius = 1.0 / m**2
    certified_qf_radius = gap  # = 1.0 for uniform matroid
    
    # Test at various perturbation levels
    test_levels = np.logspace(-4, np.log10(2), 30)
    survival = []
    
    for eps in test_levels:
        count = 0
        for _ in range(n_trials):
            E = np.random.randn(m, m)
            E = (E + E.T) / 2
            E *= eps / max(np.max(np.abs(E)), 1e-15)
            if has_lorentzian_signature(H + E):
                count += 1
        survival.append(count / n_trials)
    
    return {
        "m": m,
        "condition_number": kappa,
        "certified_entry_radius": certified_entry_radius,
        "certified_qf_radius": certified_qf_radius,
        "test_levels": test_levels,
        "survival_rates": survival,
    }


# =============================================================================
# Application 2: MCMC Mixing Surrogate
# =============================================================================

def mixing_surrogate_analysis(m_values: List[int]) -> dict:
    """Analyze the contraction surrogate across matroid sizes.
    
    The contraction surrogate 1/κ predicts the mixing rate of
    Markov chains on the associated strongly log-concave distribution.
    """
    results = []
    for m in m_values:
        H = leaf_hessian(m)
        gap = spectral_gap(H)
        opn = operator_norm(H)
        contraction = gap / opn if opn > 0 else 0
        
        # Predicted mixing time ~ κ * log(1/ε)
        kappa = opn / gap if gap > 0 else float('inf')
        predicted_mixing = kappa * np.log(1e6)  # for accuracy 1e-6
        
        results.append({
            "m": m,
            "gap": gap,
            "op_norm": opn,
            "contraction": contraction,
            "condition_number": kappa,
            "predicted_mixing_time": predicted_mixing,
        })
    
    return {"results": results}


# =============================================================================
# Application 3: Polynomial Stability Landscape
# =============================================================================

def stability_landscape(m: int, n_grid: int = 50) -> dict:
    """Compute the stability landscape in a 2D perturbation slice.
    
    Perturbs two entries of the Hessian and maps out the region
    where Lorentzian signature is preserved.
    """
    H = leaf_hessian(m)
    max_eps = 2.0
    x_range = np.linspace(-max_eps, max_eps, n_grid)
    y_range = np.linspace(-max_eps, max_eps, n_grid)
    
    landscape = np.zeros((n_grid, n_grid))
    
    for i, ex in enumerate(x_range):
        for j, ey in enumerate(y_range):
            E = np.zeros((m, m))
            E[0, 1] = ex
            E[1, 0] = ex
            E[0, 2] = ey
            E[2, 0] = ey
            landscape[j, i] = 1.0 if has_lorentzian_signature(H + E) else 0.0
    
    return {
        "m": m,
        "x_range": x_range,
        "y_range": y_range,
        "landscape": landscape,
        "certified_radius": 1.0 / m**2,
    }


if __name__ == "__main__":
    # Application 1: Robustness
    print("Application 1: Certified Robustness")
    print("=" * 50)
    cert = robustness_certificate(6, n_trials=200)
    print(f"  m = {cert['m']}")
    print(f"  κ = {cert['condition_number']:.4f}")
    print(f"  Certified entry radius = {cert['certified_entry_radius']:.6f}")
    print(f"  Certified QF radius = {cert['certified_qf_radius']:.4f}")
    
    # Application 2: Mixing
    print("\nApplication 2: MCMC Mixing Surrogates")
    print("=" * 50)
    mixing = mixing_surrogate_analysis([3, 5, 8, 10, 15, 20, 30])
    for r in mixing["results"]:
        print(f"  m={r['m']:3d}: contraction={r['contraction']:.4f}, "
              f"κ={r['condition_number']:.1f}, "
              f"predicted_mixing={r['predicted_mixing_time']:.0f}")
    
    # Application 3: Landscape
    print("\nApplication 3: Stability Landscape")
    print("=" * 50)
    land = stability_landscape(5, n_grid=40)
    stable_fraction = np.mean(land['landscape'])
    print(f"  m = {land['m']}")
    print(f"  Stable fraction of perturbation space: {stable_fraction:.2%}")
    
    # Plot
    fig, axes = plt.subplots(1, 3, figsize=(16, 5))
    
    # Plot 1: Robustness
    axes[0].semilogx(cert['test_levels'], cert['survival_rates'], 'b.-')
    axes[0].axvline(x=cert['certified_entry_radius'], color='r', 
                     linestyle='--', label='Certified radius')
    axes[0].set_xlabel('Entry perturbation ε')
    axes[0].set_ylabel('Survival rate')
    axes[0].set_title(f'Robustness Certificate (m={cert["m"]})')
    axes[0].legend()
    
    # Plot 2: Mixing
    ms = [r['m'] for r in mixing['results']]
    contractions = [r['contraction'] for r in mixing['results']]
    axes[1].plot(ms, contractions, 'ro-')
    axes[1].plot(ms, [1/m for m in ms], 'b--', label='1/m (theoretical)')
    axes[1].set_xlabel('m')
    axes[1].set_ylabel('Contraction surrogate')
    axes[1].set_title('MCMC Contraction vs m')
    axes[1].legend()
    
    # Plot 3: Landscape
    im = axes[2].imshow(land['landscape'], extent=[-2, 2, -2, 2],
                         origin='lower', cmap='RdYlGn', aspect='equal')
    r = land['certified_radius']
    rect = plt.Rectangle((-r, -r), 2*r, 2*r, fill=False, 
                          edgecolor='blue', linewidth=2, label='Certified safe')
    axes[2].add_patch(rect)
    axes[2].set_xlabel('ε₁ (entry [0,1])')
    axes[2].set_ylabel('ε₂ (entry [0,2])')
    axes[2].set_title(f'Stability Landscape (m={land["m"]})')
    axes[2].legend()
    
    plt.tight_layout()
    plt.savefig('applications_demo.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to applications_demo.png")


#!/usr/bin/env python3
"""
demo.py — Interactive demonstration of Lorentzian Condition Numbers

Computes and visualizes the certified condition number for uniform matroid
examples, showing how the predicted safe radius relates to numerical stability.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def leaf_hessian(m: int) -> np.ndarray:
    """Construct the canonical leaf Hessian J - I for the uniform matroid on m variables."""
    return np.ones((m, m)) - np.eye(m)


def spectral_gap(H: np.ndarray) -> float:
    """Compute the spectral gap of a Lorentzian-signature matrix.
    
    The spectral gap is the minimum absolute value of the negative eigenvalues,
    measuring how robustly the matrix satisfies the Lorentzian signature condition.
    """
    eigenvalues = np.linalg.eigvalsh(H)
    neg_eigs = eigenvalues[eigenvalues < -1e-12]
    if len(neg_eigs) == 0:
        return 0.0
    return float(np.min(np.abs(neg_eigs)))


def operator_norm(H: np.ndarray) -> float:
    """Compute the operator norm (largest singular value) of a symmetric matrix."""
    return float(np.max(np.abs(np.linalg.eigvalsh(H))))


def condition_number(H: np.ndarray) -> float:
    """Compute the Lorentzian condition number: opNorm / spectralGap."""
    gap = spectral_gap(H)
    if gap < 1e-15:
        return float('inf')
    return operator_norm(H) / gap


def certified_radius(H: np.ndarray) -> float:
    """Compute the certified perturbation radius: 1 / (n^2 * kappa)."""
    n = H.shape[0]
    kappa = condition_number(H)
    if kappa == float('inf') or kappa < 1e-15:
        return 0.0
    return 1.0 / (n**2 * kappa)


def has_lorentzian_signature(H: np.ndarray, tol: float = 1e-10) -> bool:
    """Check if H has at most one positive eigenvalue."""
    eigenvalues = np.linalg.eigvalsh(H)
    return int(np.sum(eigenvalues > tol)) <= 1


def perturb_and_test(H: np.ndarray, epsilon: float, n_trials: int = 100) -> float:
    """Test what fraction of random perturbations of size epsilon preserve Lorentzian signature."""
    m = H.shape[0]
    count_preserved = 0
    for _ in range(n_trials):
        E = np.random.randn(m, m) * epsilon
        E = (E + E.T) / 2  # Symmetrize
        E = E * (epsilon / max(np.max(np.abs(E)), 1e-15))  # Normalize to entry bound
        if has_lorentzian_signature(H + E):
            count_preserved += 1
    return count_preserved / n_trials


def demo_condition_numbers():
    """Demonstrate condition number computation for uniform matroids."""
    print("=" * 70)
    print("LORENTZIAN CONDITION NUMBERS FOR UNIFORM MATROIDS")
    print("=" * 70)
    print()
    
    ms = list(range(3, 16))
    kappas = []
    radii = []
    theoretical_radii = []
    
    for m in ms:
        H = leaf_hessian(m)
        kappa = condition_number(H)
        radius = certified_radius(H)
        theo_radius = 1.0 / m**2
        
        kappas.append(kappa)
        radii.append(radius)
        theoretical_radii.append(theo_radius)
        
        print(f"m = {m:3d}: κ = {kappa:8.4f}, "
              f"certified radius = {radius:.6f}, "
              f"theoretical 1/m² = {theo_radius:.6f}")
    
    print()
    print("Note: κ = opNorm/gap = (m-1)/1 = m-1")
    print("      certified radius = 1/(m²·κ) = 1/(m²(m-1))")
    print("      theoretical entry bound = 1/m²")
    print()
    return ms, kappas, radii, theoretical_radii


def demo_perturbation_stability():
    """Demonstrate perturbation stability near the certified radius."""
    print("=" * 70)
    print("PERTURBATION STABILITY TESTING")
    print("=" * 70)
    print()
    
    m = 6
    H = leaf_hessian(m)
    kappa = condition_number(H)
    cert_radius = 1.0 / m**2
    
    print(f"Testing m = {m}, κ = {kappa:.4f}, certified radius = {cert_radius:.6f}")
    print()
    
    epsilons = np.logspace(-4, 0, 20)
    survival_rates = []
    
    for eps in epsilons:
        rate = perturb_and_test(H, eps, n_trials=200)
        survival_rates.append(rate)
        status = "SAFE" if eps < cert_radius else "BEYOND"
        print(f"  ε = {eps:.6f} [{status:6s}]: {rate*100:5.1f}% preserved")
    
    return epsilons, survival_rates, cert_radius


def demo_spectral_decomposition():
    """Show the spectral structure of the leaf Hessian."""
    print()
    print("=" * 70)
    print("SPECTRAL DECOMPOSITION OF LEAF HESSIANS")
    print("=" * 70)
    print()
    
    for m in [4, 8, 12]:
        H = leaf_hessian(m)
        eigs = np.linalg.eigvalsh(H)
        gap = spectral_gap(H)
        op_norm = operator_norm(H)
        
        print(f"m = {m}:")
        print(f"  Eigenvalues: {np.sort(eigs)[::-1]}")
        print(f"  Positive eigenvalue: {m-1} (multiplicity 1)")
        print(f"  Negative eigenvalue: -1 (multiplicity {m-1})")
        print(f"  Spectral gap: {gap:.4f}")
        print(f"  Operator norm: {op_norm:.4f}")
        print(f"  Condition number κ = {op_norm/gap:.4f}")
        print()


if __name__ == "__main__":
    ms, kappas, radii, theo_radii = demo_condition_numbers()
    epsilons, survival_rates, cert_radius = demo_perturbation_stability()
    demo_spectral_decomposition()
    
    # Plot 1: Condition numbers vs m
    fig, axes = plt.subplots(1, 3, figsize=(15, 5))
    
    axes[0].plot(ms, kappas, 'bo-', label='Computed κ(e_r)')
    axes[0].plot(ms, [m-1 for m in ms], 'r--', label='m-1 (exact)')
    axes[0].plot(ms, [m**2 for m in ms], 'g--', alpha=0.5, label='m² (upper bound)')
    axes[0].set_xlabel('Number of variables m')
    axes[0].set_ylabel('Condition number κ')
    axes[0].set_title('Lorentzian Condition Number')
    axes[0].legend()
    axes[0].set_yscale('log')
    
    # Plot 2: Stability test
    axes[1].semilogx(epsilons, survival_rates, 'b.-')
    axes[1].axvline(x=cert_radius, color='r', linestyle='--', label=f'Certified radius 1/m²')
    axes[1].set_xlabel('Perturbation magnitude ε')
    axes[1].set_ylabel('Fraction preserving Lorentzianity')
    axes[1].set_title('Perturbation Stability (m=6)')
    axes[1].legend()
    axes[1].set_ylim(-0.05, 1.05)
    
    # Plot 3: Certified radius vs theoretical
    axes[2].loglog(ms, radii, 'bo-', label='Certified 1/(m²κ)')
    axes[2].loglog(ms, theo_radii, 'r^--', label='Entry bound 1/m²')
    axes[2].set_xlabel('Number of variables m')
    axes[2].set_ylabel('Stability radius')
    axes[2].set_title('Stability Radius Comparison')
    axes[2].legend()
    
    plt.tight_layout()
    plt.savefig('lorentzian_condition_demo.png', dpi=150, bbox_inches='tight')
    print("\nPlot saved to lorentzian_condition_demo.png")


#!/usr/bin/env python3
"""
Visualization: Lorentzian Condition Number Landscape

Visualizes how the condition number κ and certified perturbation radius
vary across uniform matroid families, showing the m² scaling law.
This illustrates the central theorem that algebraic conditioning
controls perturbation robustness.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

def spectral_gap(H):
    eigs = np.linalg.eigvalsh(H)
    neg = eigs[eigs < -1e-12]
    return float(np.min(np.abs(neg))) if len(neg) > 0 else 0.0

def operator_norm(H):
    return float(np.max(np.abs(np.linalg.eigvalsh(H))))

def has_lorentzian_signature(H, tol=1e-10):
    return int(np.sum(np.linalg.eigvalsh(H) > tol)) <= 1


ms = list(range(3, 25))
kappas = []
gaps = []
op_norms = []
entry_radii = []

for m in ms:
    H = leaf_hessian(m)
    g = spectral_gap(H)
    n = operator_norm(H)
    gaps.append(g)
    op_norms.append(n)
    kappas.append(n / g)
    entry_radii.append(1.0 / m**2)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Lorentzian Condition Number Theory: Uniform Matroid Family', 
             fontsize=14, fontweight='bold')

# Panel 1: Condition number
ax = axes[0, 0]
ax.plot(ms, kappas, 'bo-', markersize=5, label='Computed κ = N/g')
ax.plot(ms, [m-1 for m in ms], 'r--', alpha=0.7, label='Exact: m−1')
ax.set_xlabel('Variables m')
ax.set_ylabel('Condition number κ')
ax.set_title('Condition Number vs Dimension')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Spectral data
ax = axes[0, 1]
ax.plot(ms, gaps, 'gs-', markersize=5, label='Spectral gap g = 1')
ax.plot(ms, op_norms, 'r^-', markersize=5, label='Operator norm N = m−1')
ax.set_xlabel('Variables m')
ax.set_ylabel('Value')
ax.set_title('Spectral Data')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Certified radius (log scale)
ax = axes[1, 0]
ax.loglog(ms, entry_radii, 'bo-', markersize=5, label='Certified: 1/m²')
ax.loglog(ms, [1/m for m in ms], 'r--', alpha=0.7, label='QF radius: 1/m')
ax.loglog(ms, [1/(m**2*(m-1)) for m in ms], 'g:', alpha=0.7, label='Tight: 1/(m²κ)')
ax.set_xlabel('Variables m')
ax.set_ylabel('Perturbation radius')
ax.set_title('Certified Stability Radius')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 4: Empirical stability test for m=8
ax = axes[1, 1]
m = 8
H = leaf_hessian(m)
epsilons = np.logspace(-3, 0.3, 25)
survival = []
for eps in epsilons:
    count = 0
    for _ in range(300):
        E = np.random.randn(m, m)
        E = (E + E.T) / 2
        E *= eps / max(np.max(np.abs(E)), 1e-15)
        if has_lorentzian_signature(H + E):
            count += 1
    survival.append(count / 300)

ax.semilogx(epsilons, survival, 'b.-', markersize=4)
ax.axvline(x=1/m**2, color='r', linestyle='--', linewidth=2, label=f'1/m² = {1/m**2:.4f}')
ax.axvline(x=1.0, color='g', linestyle=':', linewidth=2, label='Gap = 1')
ax.set_xlabel('Entry perturbation ε')
ax.set_ylabel('Fraction preserving signature')
ax.set_title(f'Empirical Stability (m={m})')
ax.legend()
ax.set_ylim(-0.05, 1.05)
ax.grid(True, alpha=0.3)

plt.tight_layout()
plt.savefig('viz_condition_landscape.png', dpi=150, bbox_inches='tight')
print("Saved viz_condition_landscape.png")


#!/usr/bin/env python3
"""
Visualization: Mixing Rate vs Condition Number

Shows how the Lorentzian condition number predicts MCMC mixing behavior.
As the condition number grows, the contraction surrogate shrinks, indicating
slower mixing. This is the cross-domain bridge from algebraic combinatorics
to algorithm design.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

def spectral_gap(H):
    eigs = np.linalg.eigvalsh(H)
    neg = eigs[eigs < -1e-12]
    return float(np.min(np.abs(neg))) if len(neg) > 0 else 0.0

def operator_norm(H):
    return float(np.max(np.abs(np.linalg.eigvalsh(H))))


# Compute data for uniform matroids
ms = list(range(3, 51))
kappas = []
contractions = []
radii = []

for m in ms:
    H = leaf_hessian(m)
    g = spectral_gap(H)
    N = operator_norm(H)
    k = N / g if g > 0 else float('inf')
    kappas.append(k)
    contractions.append(g / N if N > 0 else 0)
    radii.append(1.0 / m**2)

fig, axes = plt.subplots(2, 2, figsize=(12, 10))
fig.suptitle('Condition Number Controls Algorithmic Behavior', 
             fontsize=14, fontweight='bold')

# Panel 1: Condition number growth
ax = axes[0, 0]
ax.plot(ms, kappas, 'b-', linewidth=2, label='κ(e_r) = m − 1')
ax.fill_between(ms, kappas, alpha=0.15, color='blue')
ax.set_xlabel('Number of variables m')
ax.set_ylabel('Condition number κ')
ax.set_title('Condition Number Growth')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 2: Contraction surrogate decay
ax = axes[0, 1]
ax.plot(ms, contractions, 'r-', linewidth=2, label='1/κ = contraction surrogate')
ax.plot(ms, [1/m for m in ms], 'g--', alpha=0.7, label='1/m (theoretical)')
ax.set_xlabel('Number of variables m')
ax.set_ylabel('Contraction rate')
ax.set_title('Contraction Surrogate Decay')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 3: Certified radius decay
ax = axes[1, 0]
ax.semilogy(ms, radii, 'b-', linewidth=2, label='Certified radius 1/m²')
ax.semilogy(ms, [1/k for k in kappas], 'r--', linewidth=1.5, 
            label='Contraction surrogate 1/κ')
ax.set_xlabel('Number of variables m')
ax.set_ylabel('Value (log scale)')
ax.set_title('Radius and Contraction vs Dimension')
ax.legend()
ax.grid(True, alpha=0.3)

# Panel 4: The unifying relationship
ax = axes[1, 1]
ax.loglog(kappas, radii, 'bo', markersize=6, alpha=0.7)
ax.loglog(kappas, [1/(k+1)**2 for k in kappas], 'r--', linewidth=1.5,
          label='1/(κ+1)²')
# Fit a power law
log_k = np.log(kappas)
log_r = np.log(radii)
slope, intercept = np.polyfit(log_k, log_r, 1)
fit_r = np.exp(intercept) * np.array(kappas)**slope
ax.loglog(kappas, fit_r, 'g-', linewidth=1.5, 
          label=f'Fit: r ∝ κ^{{{slope:.2f}}}')

ax.set_xlabel('Condition number κ')
ax.set_ylabel('Certified radius r')
ax.set_title('The Unifying Relationship: κ vs r')
ax.legend()
ax.grid(True, alpha=0.3)

# Add annotation
ax.annotate('Better conditioned\n(more robust)', 
            xy=(3, 0.05), fontsize=9, color='green',
            ha='center')
ax.annotate('Ill-conditioned\n(fragile)', 
            xy=(30, 0.0005), fontsize=9, color='red',
            ha='center')

plt.tight_layout()
plt.savefig('viz_mixing_convergence.png', dpi=150, bbox_inches='tight')
print("Saved viz_mixing_convergence.png")


#!/usr/bin/env python3
"""
Visualization: Spectral Gap Heatmap and Stability Landscape

Shows the stability landscape of the Lorentzian property in perturbation space.
Green regions preserve the Lorentzian signature; red regions break it.
The certified safe radius appears as a blue square inside the green region.
"""

import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Circle, Rectangle


def leaf_hessian(m):
    return np.ones((m, m)) - np.eye(m)

def has_lorentzian_signature(H, tol=1e-10):
    return int(np.sum(np.linalg.eigvalsh(H) > tol)) <= 1

def spectral_gap_of_perturbed(H, E):
    """Return spectral gap of H+E, or 0 if not Lorentzian."""
    combined = H + E
    eigs = np.linalg.eigvalsh(combined)
    if np.sum(eigs > 1e-10) > 1:
        return -1.0  # Not Lorentzian
    neg = eigs[eigs < -1e-12]
    return float(np.min(np.abs(neg))) if len(neg) > 0 else 0.0


fig, axes = plt.subplots(1, 3, figsize=(16, 5))
fig.suptitle('Stability Landscapes: Where Lorentzianity Survives', 
             fontsize=13, fontweight='bold')

for idx, m in enumerate([4, 6, 10]):
    ax = axes[idx]
    H = leaf_hessian(m)
    n_grid = 80
    max_eps = 1.5
    x_range = np.linspace(-max_eps, max_eps, n_grid)
    y_range = np.linspace(-max_eps, max_eps, n_grid)
    
    landscape = np.zeros((n_grid, n_grid))
    
    for i, ex in enumerate(x_range):
        for j, ey in enumerate(y_range):
            E = np.zeros((m, m))
            # Perturb entries (0,1) and (1,2) symmetrically
            E[0, 1] = ex; E[1, 0] = ex
            E[1, 2] = ey; E[2, 1] = ey
            gap = spectral_gap_of_perturbed(H, E)
            landscape[j, i] = gap
    
    # Mask non-Lorentzian regions
    lorentzian_mask = landscape >= 0
    
    im = ax.imshow(landscape, extent=[-max_eps, max_eps, -max_eps, max_eps],
                    origin='lower', cmap='RdYlGn', vmin=-0.5, vmax=1.5,
                    aspect='equal')
    
    # Draw certified radius
    r = 1.0 / m**2
    rect = Rectangle((-r, -r), 2*r, 2*r, fill=False, 
                      edgecolor='blue', linewidth=2, linestyle='--')
    ax.add_patch(rect)
    
    # Draw spectral gap = 1 circle (approximate)
    circle = Circle((0, 0), 1.0, fill=False, edgecolor='white', 
                     linewidth=1.5, linestyle=':')
    ax.add_patch(circle)
    
    ax.set_xlabel('ε₁ (entry perturbation)')
    ax.set_ylabel('ε₂ (entry perturbation)')
    ax.set_title(f'm = {m}, certified radius = 1/{m}² = {r:.4f}')
    ax.set_xlim(-max_eps, max_eps)
    ax.set_ylim(-max_eps, max_eps)

plt.colorbar(im, ax=axes, label='Residual spectral gap (negative = broken)', shrink=0.8)
plt.tight_layout()
plt.savefig('viz_spectral_heatmap.png', dpi=150, bbox_inches='tight')
print("Saved viz_spectral_heatmap.png")
